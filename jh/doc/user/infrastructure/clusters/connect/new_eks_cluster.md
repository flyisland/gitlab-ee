---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建 Amazon EKS 集群
---

您可以通过[基础设施即代码 (IaC)](../../_index.md) 在 Amazon Elastic Kubernetes Service (EKS) 上创建集群。该过程使用 AWS 和 Kubernetes Terraform 提供程序来创建 EKS 集群。您可以使用 极狐GitLab Kubernetes agent 将集群连接到 极狐GitLab。

**准备工作**：

- 一个 Amazon Web Services (AWS) 账户，以及配置好的[安全凭证](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html)。
- 一个可运行的 [Runner](https://gitlab.cn/docs/runner/install/) 用于运行 极狐GitLab CI/CD 流水线。

**步骤**：

1. [导入示例项目](#import-the-example-project)。
1. [注册 agent](#register-the-agent)。
1. [配置您的项目](#configure-your-project)。
1. [供应您的集群](#provision-your-cluster)。

<a id="import-the-example-project"></a>

## 导入示例项目

要从 极狐GitLab 使用基础设施即代码创建集群，您必须先创建一个用于管理该集群的项目。在本教程中，您将从一个示例项目开始，并根据需要进行修改。

首先，通过[通过 URL 导入示例项目](../../../import/third_party_systems/repo_by_url.md)开始。

导入项目的步骤：

1. 在 极狐GitLab 顶部栏，选择 **搜索或跳转到**。
1. 选择 **查看我的所有项目**。
1. 在页面右侧，选择 **新建项目**。
1. 选择 **导入项目**。
1. 选择 **通过 URL 导入仓库**。
1. 在 **Git 仓库 URL** 中，输入 `https://jihulab.com/gitlab-cn/configure/examples/gitlab-terraform-eks.git`。
1. 填写字段并选择 **创建项目**。

该项目提供了：

- 一个 Amazon [虚拟私有云 (VPC)](https://jihulab.com/gitlab-cn/configure/examples/gitlab-terraform-eks/-/blob/main/vpc.tf)。
- 一个 Amazon [弹性 Kubernetes 服务 (EKS)](https://jihulab.com/gitlab-cn/configure/examples/gitlab-terraform-eks/-/blob/main/eks.tf) 集群。
- 已安装在集群中的 [极狐GitLab Kubernetes agent](https://jihulab.com/gitlab-cn/configure/examples/gitlab-terraform-eks/-/blob/main/agent.tf)。

<a id="register-the-agent"></a>

## 注册 agent

{{< history >}}

- 在 极狐GitLab 14.9 中更改。一个名为 `certificate_based_clusters` 的[功能标志](../../../../administration/feature_flags/_index.md) 更改了 **操作** 菜单，使其专注于 agent 而非证书。默认禁用。

{{< /history >}}

要创建 极狐GitLab Kubernetes agent：

1. 在左侧边栏，选择 **运维** > **Kubernetes 集群**。
1. 选择 **连接集群（agent）**。
1. 从 **选择 agent** 下拉列表中选择 `eks-agent`，然后选择 **注册 agent**。
1. 极狐GitLab 会为 agent 生成一个注册令牌。请安全存储这个秘密令牌，因为稍后您会用到它。
1. 极狐GitLab 还会提供 agent 服务器 (KAS) 的地址，您稍后也会用到。

<a id="set-up-aws-credentials"></a>

## 设置 AWS 凭证

当您希望使用 AWS 对 极狐GitLab 进行认证时，请设置您的 AWS 凭证。

1. 创建一个 [IAM 用户](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html) 或 [IAM 角色](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)。
1. 确保您的 IAM 用户或角色拥有适合您项目的权限。对于此示例项目，您必须拥有以下 JSON 块中列出的权限。在设置自己的项目时，您可以扩展这些权限。

   ```json
   // IAM custom Policy definition
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "VisualEditor0",
         "Effect": "Allow",
         "Action": [
           "ec2:*",
           "eks:*",
           "elasticloadbalancing:*",
           "autoscaling:*",
           "cloudwatch:*",
           "logs:*",
           "kms:DescribeKey",
           "kms:TagResource",
           "kms:UntagResource",
           "kms:ListResourceTags",
           "kms:CreateKey",
           "kms:CreateAlias",
           "kms:ListAliases",
           "kms:DeleteAlias",
           "iam:AddRoleToInstanceProfile",
           "iam:AttachRolePolicy",
           "iam:CreateInstanceProfile",
           "iam:CreateRole",
           "iam:CreateServiceLinkedRole",
           "iam:GetRole",
           "iam:ListAttachedRolePolicies",
           "iam:ListRolePolicies",
           "iam:ListRoles",
           "iam:PassRole",
           "iam:DetachRolePolicy",
           "iam:ListInstanceProfilesForRole",
           "iam:DeleteRole",
           "iam:CreateOpenIDConnectProvider",
           "iam:CreatePolicy",
           "iam:TagOpenIDConnectProvider",
           "iam:GetPolicy",
           "iam:GetPolicyVersion",
           "iam:GetOpenIDConnectProvider",
           "iam:DeleteOpenIDConnectProvider",
           "iam:ListPolicyVersions",
           "iam:DeletePolicy"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

1. [为用户或角色创建访问密钥](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)。
1. 保存您的访问密钥和秘密。您需要使用它们来通过 极狐GitLab 对 AWS 进行认证。

<a id="configure-your-project"></a>

## 配置您的项目

使用 CI/CD 环境变量来配置您的项目。

**必需配置**：

1. 在左侧边栏，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 将变量 `AWS_ACCESS_KEY_ID` 设置为您的 AWS 访问密钥 ID。
1. 将变量 `AWS_SECRET_ACCESS_KEY` 设置为您的 AWS 秘密访问密钥。
1. 将变量 `TF_VAR_agent_token` 设置为上一个任务中显示的 agent 令牌。
1. 将变量 `TF_VAR_kas_address` 设置为上一个任务中显示的 agent 服务器地址。

**可选配置**：

[`variables.tf`](https://jihulab.com/gitlab-cn/configure/examples/gitlab-terraform-eks/-/blob/main/variables.tf) 文件中包含您可以根据需要覆盖的其他变量：

- `TF_VAR_region`：设置集群的区域。
- `TF_VAR_cluster_name`：设置集群的名称。
- `TF_VAR_cluster_version`：设置 Kubernetes 的版本。
- `TF_VAR_instance_type`：设置 Kubernetes 节点的实例类型。
- `TF_VAR_instance_count`：设置 Kubernetes 节点的数量。
- `TF_VAR_agent_namespace`：设置 极狐GitLab Kubernetes agent 的 Kubernetes 命名空间。

查看 [AWS Terraform 提供程序](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)和 [Kubernetes Terraform 提供程序](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) 文档以获取更多资源选项。

<a id="provision-your-cluster"></a>

## 供应您的集群

配置项目后，手动触发集群的供应。在 极狐GitLab 中：

1. 在左侧边栏，进入 **构建** > **流水线**。
1. 在 **播放** ({{< icon name="play" >}}) 旁边，选择下拉列表图标 ({{< icon name="chevron-lg-down" >}})。
1. 选择 **部署** 以手动触发部署作业。

当流水线成功完成后，您可以查看新的集群：

- 在 AWS 中：在 [EKS 控制台](https://console.aws.amazon.com/eks/home) 中，选择 **Amazon EKS** > **集群**。
- 在 极狐GitLab 中：在左侧边栏，选择 **运维** > **Kubernetes 集群**。

<a id="use-your-cluster"></a>

## 使用您的集群

供应集群后，它已连接到 极狐GitLab，并准备好进行部署。要检查连接：

1. 在左侧边栏，选择 **运维** > **Kubernetes 集群**。
1. 在列表中，查看 **连接状态** 列。

有关连接功能的更多信息，请参见[极狐GitLab Kubernetes agent 文档](../_index.md)。

<a id="remove-the-cluster"></a>

## 移除集群

默认情况下，流水线中不包含清理作业。要移除所有已创建的资源，您必须在运行清理作业之前修改 极狐GitLab CI/CD 模板。

要移除所有资源：

1. 将以下内容添加到您的 `.gitlab-ci.yml` 文件：

   ```yaml
   stages:
     - init
     - validate
     - test
     - build
     - deploy
     - cleanup

   destroy:
     extends: .terraform:destroy
     needs: []
   ```

1. 在左侧边栏，选择 **构建** > **流水线**，然后选择最近的流水线。
1. 对于 `destroy` 作业，选择 **播放** ({{< icon name="play" >}})。