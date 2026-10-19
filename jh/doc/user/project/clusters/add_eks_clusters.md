---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过集群证书连接 EKS 集群（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 14.5 中废弃。请使用[基础设施即代码](../../infrastructure/iac/_index.md)
> 创建新集群。

通过极狐GitLab，您可以创建新集群，并添加托管在 Amazon Elastic
Kubernetes Service (EKS) 上的现有集群。

<a id="connect-an-existing-eks-cluster"></a>

## 连接现有 EKS 集群

如果您已有 EKS 集群，并希望将其连接到极狐GitLab，
请使用[极狐GitLab Kubernetes Agent](../../clusters/agent/_index.md)。

<a id="create-a-new-eks-cluster"></a>

## 创建新 EKS 集群

要从极狐GitLab 创建新集群，请使用[基础设施即代码](../../infrastructure/iac/_index.md)。

<a id="how-to-create-a-new-cluster-on-eks-through-cluster-certificates-deprecated"></a>

### 如何通过集群证书在 EKS 上创建新集群（已废弃）

先决条件：

- 一个 [Amazon Web Services](https://aws.amazon.com/) 账号。
- 管理 IAM 资源的权限。

有关实例级集群，请参阅[极狐GitLab 私有化部署实例的附加要求](#additional-requirements-for-gitlab-self-managed-instances)。

要通过基于证书的方法为您的项目、群组或实例创建新的 Kubernetes 集群：

1. [为您的集群定义访问控制（RBAC 或 ABAC）](cluster_access.md)。
1. [在极狐GitLab 中创建集群](#create-a-new-eks-cluster-in-gitlab)。
1. [在 Amazon 中准备集群](#prepare-the-cluster-in-amazon)。
1. [在极狐GitLab 中配置集群数据](#configure-your-clusters-data-in-gitlab)。

后续步骤：

1. [创建默认存储类](#create-a-default-storage-class)。
1. [将应用部署到 EKS](#deploy-the-app-to-eks)。

<a id="create-a-new-eks-cluster-in-gitlab"></a>

#### 在极狐GitLab 中创建新 EKS 集群

要通过集群证书为您的项目、群组或实例创建新的 EKS 集群：

1. 前往您的：
   - 项目的**运维** > **Kubernetes 集群**页面，用于项目级集群。
   - 群组的 **Kubernetes** 页面，用于群组级集群。
   - **管理**区域的 **Kubernetes** 页面，用于实例级集群。
1. 选择 **使用集群证书集成**。
1. 在 **创建新集群** 标签页下，选择 **Amazon EKS**，以显示后续步骤所需的
   `Account ID` 和 `External ID`。
1. 在 [IAM 管理控制台](https://console.aws.amazon.com/iam/home)中，创建一个 IAM 策略：
   1. 在左侧面板中，选择 **策略**。
   1. 选择 **创建策略**，将打开一个新窗口。
   1. 选择 **JSON** 标签页，并将以下代码片段粘贴到原有内容的位置。
      这些权限授予极狐GitLab 创建资源的能力，但不包括删除资源：

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

      如果在此过程中遇到错误，极狐GitLab 不会回滚更改。您必须手动移除资源。您可以通过删除
      相关的 [CloudFormation 堆栈](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html)来完成。

   1. 选择 **审核策略**。
   1. 为该策略输入合适的名称，然后选择 **创建策略**。现在您可以关闭此窗口。

<a id="prepare-the-cluster-in-amazon"></a>

### 在 Amazon 中准备集群

1. [为您的集群创建 **EKS IAM 角色**](#create-an-eks-iam-role-for-your-cluster)（**角色 A**）。
1. [为极狐GitLab 与 Amazon 的身份验证创建**另一个 EKS IAM 角色**](#create-another-eks-iam-role-for-gitlab-authentication-with-amazon)（**角色 B**）。

<a id="create-an-eks-iam-role-for-your-cluster"></a>

#### 为您的集群创建 EKS IAM 角色

在 [IAM 管理控制台](https://console.aws.amazon.com/iam/home)中，
按照 [Amazon EKS 集群 IAM 角色说明](https://docs.aws.amazon.com/eks/latest/userguide/cluster-iam-role.html)创建 **EKS IAM 角色**（**角色 A**）。
此角色是必需的，以便由 Amazon EKS 管理的 Kubernetes 集群可以代表您调用其他 AWS 服务，来管理您与该服务一起使用的资源。

为了让极狐GitLab 正确管理 EKS 集群，除了指南建议的策略外，您还必须包含
`AmazonEKSClusterPolicy`。

<a id="create-another-eks-iam-role-for-gitlab-authentication-with-amazon"></a>

#### 为极狐GitLab 与 Amazon 的身份验证创建另一个 EKS IAM 角色

在 [IAM 管理控制台](https://console.aws.amazon.com/iam/home)中，为极狐GitLab 与 AWS 的身份验证创建另一个 IAM 角色（**角色 B**）：

1. 在 AWS IAM 控制台中，从左侧面板选择 **角色**。
1. 选择 **创建角色**。
1. 在 **选择受信任实体类型** 下，选择 **另一个 AWS 账号**。
1. 将极狐GitLab 中的账号 ID 输入到 **账号 ID** 字段中。
1. 勾选 **要求外部 ID**。
1. 将极狐GitLab 中的外部 ID 输入到 **外部 ID** 字段中。
1. 选择 **下一步：权限**，然后选择您刚刚创建的策略。
1. 选择 **下一步：标签**，并可选地输入您希望与此角色关联的任何标签。
1. 选择 **下一步：审核**。
1. 在提供的字段中输入角色名称和可选描述。
1. 选择 **创建角色**。新角色名称会显示在顶部。选择其名称，并从新创建的角色中复制
   `Role ARN`。

<a id="configure-your-clusters-data-in-gitlab"></a>

### 在极狐GitLab 中配置集群数据

1. 回到极狐GitLab，将复制的角色 ARN 输入到 **角色 ARN** 字段中。
1. 在 **集群区域** 字段中，输入您计划用于新集群的[区域](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)。极狐GitLab 在验证您的角色时会确认您是否有权访问此区域。
1. 选择 **使用 AWS 进行身份验证**。
1. 调整您的[集群设置](#cluster-settings)。
1. 选择 **创建 Kubernetes 集群** 按钮。

大约 10 分钟后，您的集群即可使用。

> [!note]
> 如果您已[安装并配置](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#get-started-kubectl)了 `kubectl`，并希望使用它来管理集群，则必须在 AWS 配置中添加您的 AWS 外部 ID。有关如何配置 AWS CLI 的更多信息，请参阅[在 AWS CLI 中使用 IAM 角色](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-xaccount)。

<a id="cluster-settings"></a>

#### 集群设置

创建新集群时，您有以下设置：

| 设置                 | 描述 |
| ----------------------- |------------ |
| Kubernetes 集群名称 | 您的集群名称。 |
| 环境范围       | [关联的环境](multiple_kubernetes_clusters.md#setting-the-environment-scope)。 |
| 服务角色            | **EKS IAM 角色**（**角色 A**）。 |
| Kubernetes 版本      | 您的集群的 [Kubernetes 版本](../../clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。 |
| 密钥对名称           | 您可用于连接到工作节点的[密钥对](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)。 |
| VPC                     | 用于您的 EKS 集群资源的 [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)。 |
| 子网                 | 您的 VPC 中工作节点运行的[子网](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)。需要两个。 |
| 安全组          | 应用于在您的工作节点子网中创建的 EKS 管理的弹性网络接口的[安全组](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html)。 |
| 实例类型           | 您的工作节点的[实例类型](https://aws.amazon.com/ec2/instance-types/)。 |
| 节点数量              | 工作节点的数量。 |
| 极狐GitLab 管理的集群  | 如果您希望极狐GitLab 为此集群管理命名空间和服务账号，请勾选此项。 |

<a id="create-a-default-storage-class"></a>

## 创建默认存储类

Amazon EKS 默认没有开箱即用的存储类，这意味着对持久卷的请求不会自动得到满足。作为 Auto DevOps 的一部分，部署的 PostgreSQL 实例会请求持久存储，如果没有默认存储类，它就无法启动。

如果默认存储类尚不存在，要创建它，请参阅[存储类](https://docs.aws.amazon.com/eks/latest/userguide/storage.html#storage-classes)。

或者，通过将项目变量
[`POSTGRES_ENABLED`](../../../topics/autodevops/cicd_variables.md) 设置为 `false` 来禁用 PostgreSQL。

<a id="deploy-the-app-to-eks"></a>

## 将应用部署到 EKS

在禁用 RBAC 并部署服务后，
现在可以利用 [Auto DevOps](../../../topics/autodevops/_index.md)
来构建、测试和部署应用。

如果尚未启用，请[启用 Auto DevOps](../../../topics/autodevops/_index.md#per-project)。
如果创建了指向负载均衡器的通配符 DNS 条目，请在 Auto DevOps 设置下的 `domain` 字段中输入它。否则，部署的应用无法在集群外部访问。

![一条流水线正在将应用部署到 EKS。](img/pipeline_v11_0.png)

极狐GitLab 会创建一条新的流水线，开始构建、测试和部署应用。

流水线完成后，您的应用将在 EKS 中运行，并可供用户使用。选择**运维** > **环境**。

![已部署环境的状态和访问选项。](img/environment_v11_0.png)

极狐GitLab 会显示环境列表及其部署状态，以及浏览应用、查看监控指标，甚至访问运行中 pod 上的 shell 的选项。

<a id="additional-requirements-for-gitlab-self-managed-instances"></a>

## 极狐GitLab 私有化部署实例的附加要求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您使用的是极狐GitLab 私有化部署，则需要配置 Amazon 凭证。极狐GitLab 使用这些凭证代入 Amazon IAM 角色，以创建您的集群。

创建一个 IAM 用户，并确保其具有代入您的用户创建 EKS 集群所需角色的权限。

例如，以下策略文档允许代入账号 `123456789012`中名称以 `gitlab-eks-` 开头的角色：

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

<a id="configure-amazon-authentication"></a>

### 配置 Amazon 身份验证

先决条件：

- 管理员访问权限。

要在极狐GitLab 中配置 Amazon 身份验证，请在 Amazon AWS 控制台中为
IAM 用户生成访问密钥，然后按照以下步骤操作：

1. 在右上角，选择 **管理**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **Amazon EKS**。
1. 勾选 **启用 Amazon EKS 集成**。
1. 输入您的 **账号 ID**。
1. 输入您的[访问密钥和 ID](#eks-access-key-and-id)。
1. 选择 **保存更改**。

<a id="eks-access-key-and-id"></a>

#### EKS 访问密钥和 ID

您可以使用实例配置文件在需要时从 AWS 动态检索临时凭证。在这种情况下，将 `Access key ID` 和 `Secret access key` 字段留空，并[将 IAM 角色传递给 EC2 实例](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)。

否则，将您的访问密钥凭证输入到 **访问密钥 ID** 和**秘密访问密钥**中。

<a id="troubleshooting"></a>

## 故障排除

创建新集群时通常会遇到以下错误。

<a id="validation-failed-role-arn-must-be-a-valid-amazon-resource-name"></a>

### Validation failed: Role ARN must be a valid Amazon Resource Name

检查 `Provision Role ARN` 是否正确。有效 ARN 的示例：

```plaintext
arn:aws:iam::123456789012:role/gitlab-eks-provision'
```

<a id="access-denied-user-is-not-authorized-to-perform-stsassumerole-on-resource-arnawsiamy"></a>

### Access denied: User is not authorized to perform: `sts:AssumeRole` on resource: `arn:aws:iam::y`

当[配置 Amazon 身份验证](#configure-amazon-authentication)中定义的凭证无法代入
Provision Role ARN 所定义的角色时，会出现此错误：

```plaintext
User `arn:aws:iam::x` is not authorized to perform: `sts:AssumeRole` on resource: `arn:aws:iam::y`
```

检查以下各项：

1. 初始 AWS 凭证集[具有 AssumeRole 策略](#additional-requirements-for-gitlab-self-managed-instances)。
1. Provision Role 有权在给定区域中创建集群。
1. 账号 ID 和
   [外部 ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_third-party.html)
   与 AWS 中 **信任关系** 标签页定义的值匹配：

   ![用于 EKS 集群创建的 AWS IAM 角色的信任关系设置。](img/aws_iam_role_trust_v13_7.png)

<a id="could-not-load-security-groups-for-this-vpc"></a>

### Could not load Security Groups for this VPC

在填充配置表单中的选项时，极狐GitLab 返回此错误，因为极狐GitLab 已成功代入您提供的角色，但该角色没有足够的权限来检索表单所需的资源。请确保您已为该角色分配正确的权限。

<a id="key-pairs-are-not-loaded"></a>

### Key Pairs are not loaded

极狐GitLab 会从指定的 **集群区域** 加载密钥对。请确保该区域中存在该密钥对。

<a id="rollback_failed-during-cluster-creation"></a>

#### 集群创建期间出现 `ROLLBACK_FAILED`

创建过程已停止，因为极狐GitLab 在创建一个或多个资源时遇到错误。您可以检查关联的
[CloudFormation 堆栈](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-view-stack-data-resources.html)
以找出创建失败的具体资源。

如果 `Cluster` 资源失败并出现错误
`The provided role doesn't have the Amazon EKS Managed Policies associated with it.`，
则 **角色名称**中指定的角色配置不正确。

> [!note]
> 此角色应为按照
> [EKS 集群 IAM 角色](https://docs.aws.amazon.com/eks/latest/userguide/cluster-iam-role.html)指南创建的角色。
> 除了指南建议的策略外，您还必须为此角色包含
> `AmazonEKSClusterPolicy` 策略，以便极狐GitLab 正确管理 EKS 集群。
