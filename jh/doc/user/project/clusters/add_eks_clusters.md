---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过集群证书连接 EKS 集群（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 14.5 中已弃用。请使用 [基础设施即代码](../../infrastructure/iac/_index.md)
> 来创建新集群。

通过极狐GitLab，你可以创建新集群并添加托管在 Amazon Elastic Kubernetes Service (EKS) 上的现有集群。

## 连接现有 EKS 集群

<a id="connect-an-existing-eks-cluster"></a>

如果你已有 EKS 集群并希望将其连接到极狐GitLab，请使用 [Kubernetes 的极狐GitLab agent](../../clusters/agent/_index.md)。

## 创建新的 EKS 集群

<a id="create-a-new-eks-cluster"></a>

要从极狐GitLab 创建新集群，请使用 [基础设施即代码](../../infrastructure/iac/_index.md)。

### 如何通过集群证书在 EKS 上创建新集群（已弃用）

<a id="how-to-create-a-new-cluster-on-eks-through-cluster-certificates-deprecated"></a>

{{< history >}}

- 在极狐GitLab 14.0 中[弃用]。

{{< /history >}}

先决条件：

- 一个 [Amazon Web Services](https://aws.amazon.com/) 账户。
- 管理 IAM 资源的权限。

对于实例级集群，请参阅 [私有化部署极狐GitLab 实例的附加要求](#additional-requirements-for-gitlab-self-managed-instances)。

要通过基于证书的方法为你的项目、群组或实例创建新的 Kubernetes 集群，请执行以下步骤：

1. [为你的集群定义访问控制（RBAC 或 ABAC）](cluster_access.md)。
1. [在极狐GitLab 中创建集群](#create-a-new-eks-cluster-in-gitlab)。
1. [在 Amazon 中准备集群](#prepare-the-cluster-in-amazon)。
1. [在极狐GitLab 中配置集群数据](#configure-your-clusters-data-in-gitlab)。

后续步骤：

1. [创建默认存储类](#create-a-default-storage-class)。
1. [将应用部署到 EKS](#deploy-the-app-to-eks)。

#### 在极狐GitLab 中创建新的 EKS 集群

<a id="create-a-new-eks-cluster-in-gitlab"></a>

要通过集群证书为你的项目、群组或实例创建新的 EKS 集群，请执行以下操作：

1. 前往：
   - 项目的 **运维** > **Kubernetes 集群**页面，创建项目级集群。
   - 群组的 **Kubernetes** 页面，创建群组级集群。
   - **管理员**区域的 **Kubernetes** 页面，创建实例级集群。
1. 选择 **集成集群证书**。
1. 在 **创建新集群** 选项卡下，选择 **Amazon EKS** 以显示后续步骤所需的
   `Account ID` 和 `External ID`。
1. 在 [IAM 管理控制台](https://console.aws.amazon.com/iam/home)中，创建一个 IAM 策略：
   1. 从左侧面板中选择 **策略**。
   1. 选择 **创建策略**，这将打开一个新窗口。
   1. 选择 **JSON** 选项卡，并粘贴以下代码片段替换现有内容。这些权限允许极狐GitLab 创建
      资源，但不能删除它们：

      ```json
      {
          "Version": "2012-10-17",
          "Statement": [
              {
                  "Effect": "Allow",
                  "Action": [
                      "autoscaling:CreateAutoScalingGroup",
                      "autoscaling:DescribeAutoScalingGroups",
                      "autoscaling:DescribeScalingActivities",
                      "autoscaling:UpdateAutoScalingGroup",
                      "autoscaling:CreateLaunchConfiguration",
                      "autoscaling:DescribeLaunchConfigurations",
                      "cloudformation:CreateStack",
                      "cloudformation:DescribeStacks",
                      "ec2:AuthorizeSecurityGroupEgress",
                      "ec2:AuthorizeSecurityGroupIngress",
                      "ec2:RevokeSecurityGroupEgress",
                      "ec2:RevokeSecurityGroupIngress",
                      "ec2:CreateSecurityGroup",
                      "ec2:createTags",
                      "ec2:DescribeImages",
                      "ec2:DescribeKeyPairs",
                      "ec2:DescribeRegions",
                      "ec2:DescribeSecurityGroups",
                      "ec2:DescribeSubnets",
                      "ec2:DescribeVpcs",
                      "eks:CreateCluster",
                      "eks:DescribeCluster",
                      "iam:AddRoleToInstanceProfile",
                      "iam:AttachRolePolicy",
                      "iam:CreateRole",
                      "iam:CreateInstanceProfile",
                      "iam:CreateServiceLinkedRole",
                      "iam:GetRole",
                      "iam:listAttachedRolePolicies",
                      "iam:ListRoles",
                      "iam:PassRole",
                      "ssm:GetParameters"
                  ],
                  "Resource": "*"
              }
          ]
      }
      ```

      如果在此过程中发生错误，极狐GitLab 不会回滚更改。你必须手动移除资源。你可以通过删除
      相应的 [CloudFormation 堆栈](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html) 来完成此操作。

   1. 选择 **审查策略**。
   1. 为该策略输入合适的名称，然后选择 **创建策略**。现在可以关闭此窗口。

### 在 Amazon 中准备集群

<a id="prepare-the-cluster-in-amazon"></a>

1. [为你的集群创建 **EKS IAM 角色**](#create-an-eks-iam-role-for-your-cluster)（**角色 A**）。
1. [为极狐GitLab 与 Amazon 认证创建**另一个 EKS IAM 角色**](#create-another-eks-iam-role-for-gitlab-authentication-with-amazon)（**角色 B**）。

#### 为你的集群创建 EKS IAM 角色

<a id="create-an-eks-iam-role-for-your-cluster"></a>

在 [IAM 管理控制台](https://console.aws.amazon.com/iam/home)中，
按照 [Amazon EKS 集群 IAM 角色指南](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html)创建 **EKS IAM 角色**（**角色 A**）。
此角色是必需的，以便 Amazon EKS 管理的 Kubernetes 集群可以代表你调用其他 AWS 服务来管理你使用的资源。

为使极狐GitLab 正确管理 EKS 集群，除了指南建议的策略外，还必须包含 `AmazonEKSClusterPolicy`。

#### 为极狐GitLab 与 Amazon 认证创建另一个 EKS IAM 角色

<a id="create-another-eks-iam-role-for-gitlab-authentication-with-amazon"></a>

在 [IAM 管理控制台](https://console.aws.amazon.com/iam/home)中，
为极狐GitLab 与 AWS 认证创建另一个 IAM 角色（**角色 B**）：

1. 在 AWS IAM 控制台上，从左侧面板中选择 **角色**。
1. 选择 **创建角色**。
1. 在 **选择受信任实体的类型**下，选择 **另一个 AWS 账户**。
1. 在 **账户 ID** 字段中输入极狐GitLab 提供的账户 ID。
1. 勾选 **需要外部 ID**。
1. 在 **外部 ID** 字段中输入极狐GitLab 提供的外部 ID。
1. 选择 **下一步：权限**，然后选择你刚刚创建的策略。
1. 选择 **下一步：标签**，并可选择输入你想关联到此角色的任何标签。
1. 选择 **下一步：审查**。
1. 在提供的字段中输入角色名称和可选的描述。
1. 选择 **创建角色**。新角色名称会显示在顶部。选择其名称并复制新创建角色的
   `角色 ARN`。

### 在极狐GitLab 中配置你的集群数据

<a id="configure-your-clusters-data-in-gitlab"></a>

1. 返回极狐GitLab，将复制的角色 ARN 填入 **角色 ARN** 字段。
1. 在 **集群区域** 字段中，输入你计划用于新集群的[区域](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)。极狐GitLab 在验证你的角色时会确认你对此区域的访问权限。
1. 选择 **通过 AWS 认证**。
1. 调整你的[集群设置](#cluster-settings)。
1. 选择 **创建 Kubernetes 集群** 按钮。

大约 10 分钟后，你的集群即可准备就绪。

> [!note]
> 如果你已[安装并配置](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#get-started-kubectl) `kubectl` 并希望用它管理集群，则必须在 AWS 配置中添加你的 AWS 外部 ID。有关如何配置 AWS CLI 的更多信息，请参阅 [在 AWS CLI 中使用 IAM 角色](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-xaccount)。

#### 集群设置

<a id="cluster-settings"></a>

创建新集群时，你可以使用以下设置：

| 设置                     | 描述 |
| ----------------------- | ----------- |
| Kubernetes 集群名称      | 你的集群名称。 |
| 环境范围                 | [关联的环境](multiple_kubernetes_clusters.md#setting-the-environment-scope)。 |
| 服务角色                 | **EKS IAM 角色**（**角色 A**）。 |
| Kubernetes 版本          | 集群的 [Kubernetes 版本](../../clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。 |
| 密钥对名称               | 可用于连接到工作节点的[密钥对](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)。 |
| VPC                     | 用于 EKS 集群资源的 [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)。 |
| 子网                     | VPC 中运行工作节点的[子网](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)。需要两个。 |
| 安全组                   | 应用于在工作节点子网中创建的 EKS 管理弹性网络接口的[安全组](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html)。 |
| 实例类型                 | 工作节点的[实例类型](https://aws.amazon.com/ec2/instance-types/)。 |
| 节点数量                 | 工作节点的数量。 |
| 极狐GitLab 托管集群       | 如果希望极狐GitLab 管理此集群的命名空间和服务账户，请勾选此项。 |

## 创建默认存储类

<a id="create-a-default-storage-class"></a>

Amazon EKS 默认没有存储类，这意味着对持久卷的请求不会自动满足。作为 Auto DevOps 的一部分，部署的 PostgreSQL 实例会请求持久存储，如果没有默认存储类，它将无法启动。

如果尚不存在默认存储类，请参阅 [存储类](https://docs.aws.amazon.com/eks/latest/userguide/storage.html#storage-classes) 进行创建。

或者，通过将项目变量 [`POSTGRES_ENABLED`](../../../topics/autodevops/cicd_variables.md) 设置为 `false` 来禁用 PostgreSQL。

## 将应用部署到 EKS

<a id="deploy-the-app-to-eks"></a>

在禁用 RBAC 并部署服务后，
现在可以利用 [Auto DevOps](../../../topics/autodevops/_index.md)
来构建、测试和部署应用。

如果尚未启用，请[启用 Auto DevOps](../../../topics/autodevops/_index.md#per-project)。
如果创建了指向负载均衡器的通配符 DNS 条目，请在 Auto DevOps 设置下的 `domain` 字段中输入该条目。
否则，部署的应用将无法在集群外部访问。

![部署应用到 EKS 的流水线。](img/pipeline_v11_0.png)

极狐GitLab 会创建一个新的流水线，开始构建、测试和部署应用。

流水线完成后，你的应用将在 EKS 中运行，并对用户可用。选择 **运维** > **环境**。

![已部署环境的状态和访问选项。](img/environment_v11_0.png)

极狐GitLab 会显示环境列表及其部署状态，以及浏览应用、查看监控指标乃至在运行 Pod 上访问 shell 的选项。

## 私有化部署极狐GitLab 实例的附加要求

<a id="additional-requirements-for-gitlab-self-managed-instances"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果你使用的是私有化部署极狐GitLab，则需要配置
Amazon 凭证。极狐GitLab 使用这些凭证来代入 Amazon IAM 角色以创建你的集群。

创建一个 IAM 用户并确保其拥有代入用户创建 EKS 集群所需的角色的权限。

例如，以下策略文档允许代入账号 `123456789012` 中名称以 `gitlab-eks-` 开头的角色：

```json
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "arn:aws:iam::123456789012:role/gitlab-eks-*"
  }
}
```

### 配置 Amazon 认证

<a id="configure-amazon-authentication"></a>

先决条件：

- 管理员访问权限。

要在极狐GitLab 中配置 Amazon 认证，请在 Amazon AWS 控制台中为 IAM 用户生成访问密钥，并执行以下步骤：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **Amazon EKS**。
1. 勾选 **启用 Amazon EKS 集成**。
1. 输入你的 **账户 ID**。
1. 输入你的 [访问密钥和 ID](#eks-access-key-and-id)。
1. 选择 **保存更改**。

#### EKS 访问密钥和 ID

<a id="eks-access-key-and-id"></a>

你可以使用实例配置文件在需要时从 AWS 动态检索临时凭证。
在这种情况下，将 `访问密钥 ID` 和 `秘密访问密钥` 字段留空，
并[将 IAM 角色传递给 EC2 实例](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)。

否则，请将你的访问密钥凭证输入到 **访问密钥 ID** 和 **秘密访问密钥** 中。

## 问题排查

<a id="troubleshooting"></a>

创建新集群时常会遇到以下错误。

### 验证 失败：角色 ARN 必须是有效的 Amazon 资源名称

<a id="validation-failed-role-arn-must-be-a-valid-amazon-resource-name"></a>

检查 `Provision Role ARN` 是否正确。有效的 ARN 示例：

```plaintext
arn:aws:iam::123456789012:role/gitlab-eks-provision'
```

### 访问 被拒绝：用户无权在资源：`arn:aws:iam::y` 上执行：`sts:AssumeRole`

<a id="access-denied-user-is-not-authorized-to-perform-stsassumerole-on-resource-arnawsiamy"></a>

当[配置 Amazon 认证](#configure-amazon-authentication)中定义的凭证无法代入 Provision Role ARN 定义的角色时，会发生此错误：

```plaintext
User `arn:aws:iam::x` 无权在资源 `arn:aws:iam::y` 上执行 `sts:AssumeRole`
```

检查：

1. 初始 AWS 凭证[具有 AssumeRole 策略](#additional-requirements-for-gitlab-self-managed-instances)。
1. 配置角色有权在给定区域中创建集群。
1. 账户 ID 和[外部 ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html)
   与 AWS 中 **信任关系** 选项卡下定义的值匹配：

   ![用于 EKS 集群创建的 AWS IAM 角色的信任关系设置。](img/aws_iam_role_trust_v13_7.png)

### 无法加载此 VPC 的安全 组

<a id="could-not-load-security-groups-for-this-vpc"></a>

在配置表单中填充选项时，极狐GitLab 返回此错误
是因为极狐GitLab 已成功代入你提供的角色，但该角色没有足够的权限来检索表单所需的资源。请确保
你已为该角色分配了正确的权限。

### 密钥对未加载

<a id="key-pairs-are-not-loaded"></a>

极狐GitLab 从指定的 **集群区域** 中加载密钥对。确保该区域中存在该密钥对。

#### 集群创建期间出现 `ROLLBACK_FAILED`

<a id="rollback-failed-during-cluster-creation"></a>

创建过程停止，因为极狐GitLab 在创建一个或多个资源时遇到错误。你可以检查相关的
[CloudFormation 堆栈](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-view-stack-data-resources.html)
以查找创建失败的特定资源。

如果 `Cluster` 资源失败并显示错误
`提供的角色没有关联 Amazon EKS 托管策略。`，
则 **角色名称** 中指定的角色配置不正确。

> [!note]
> 此角色应是通过遵循
> [EKS 集群 IAM 角色](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html)指南创建的角色。
> 除该指南建议的策略外，你还必须为此角色包含 `AmazonEKSClusterPolicy` 策略，以便极狐GitLab 正确管理 EKS 集群。