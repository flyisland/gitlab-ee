---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建 Amazon EKS 集群
---

您可以通过[基础设施即代码（IaC）](../../_index.md)在 Amazon Elastic Kubernetes Service（EKS）上创建集群。此过程使用 AWS 和 Kubernetes Terraform provider 来创建 EKS 集群。您可以使用极狐GitLab Kubernetes Agent 将集群连接到极狐GitLab。

**开始之前**：

- 一个 Amazon Web Services（AWS）账号，并已配置一组
  [安全凭证](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html)。
- [一个 Runner](https://gitlab.cn/docs/runner/install/)，可用于运行极狐GitLab CI/CD 流水线。

**步骤**：

1. [导入示例项目](#import-the-example-project)。
1. [注册极狐GitLab Kubernetes Agent](#register-the-agent)。
1. [配置您的项目](#configure-your-project)。
1. [预配您的集群](#provision-your-cluster)。

<a id="import-the-example-project"></a>

## 导入示例项目

要使用基础设施即代码从极狐GitLab 创建集群，您必须创建一个用于管理该集群的项目。在本教程中，您将从一个示例项目开始，并根据需要对其进行修改。

首先，[通过 URL 导入示例项目](../../../import/third_party_systems/repo_by_url.md)。

导入项目：

1. 在极狐GitLab 中，在顶部栏中选择**搜索或跳转到**。
1. 选择**查看我的所有项目**。
1. 在页面右侧，选择**新建项目**。
1. 选择**导入项目**。
1. 选择**通过 URL 导入代码仓库**。
1. 在 **Git 代码仓库 URL**中，输入 `https://gitlab.com/gitlab-org/configure/examples/gitlab-terraform-eks.git`。
1. 填写各字段并选择**创建项目**。

此项目为您提供：

- 一个 Amazon [虚拟私有云（VPC）](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-eks/-/blob/main/vpc.tf)。
- 一个 Amazon [Elastic Kubernetes Service（EKS）](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-eks/-/blob/main/eks.tf)集群。
- 安装在集群中的[极狐GitLab Kubernetes Agent](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-eks/-/blob/main/agent.tf)。

<a id="register-the-agent"></a>

## 注册 Agent

要创建极狐GitLab Kubernetes Agent：

1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 选择**连接集群（Agent）**。
1. 在**选择 Agent** 下拉列表中，选择 `eks-agent`，然后选择**注册 Agent**。
1. 极狐GitLab 会为该 Agent 生成一个注册令牌。请安全保存此密钥令牌，稍后会用到。
1. 极狐GitLab 会提供 Agent 服务器（KAS）的地址，稍后也会用到。

<a id="set-up-aws-credentials"></a>

## 设置 AWS 凭证

当您希望使用极狐GitLab 对 AWS 进行身份验证时，请设置您的 AWS 凭证。

1. 创建一个 [IAM 用户](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html)或 [IAM 角色](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)。
1. 确保您的 IAM 用户或角色对您的项目具有适当的权限。对于此示例项目，您必须具有以下 JSON 块中列出的权限。在设置您自己的项目时，您可以扩展这些权限。

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

1. [为该用户或角色创建访问密钥](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)。
1. 保存您的访问密钥和密钥。您需要使用它们来通过极狐GitLab 对 AWS 进行身份验证。

<a id="configure-your-project"></a>

## 配置您的项目

使用 CI/CD 环境变量来配置您的项目。

**必需配置**：

1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 将变量 `AWS_ACCESS_KEY_ID` 设置为您的 AWS 访问密钥 ID。
1. 将变量 `AWS_SECRET_ACCESS_KEY` 设置为您的 AWS 秘密访问密钥。
1. 将变量 `TF_VAR_agent_token` 设置为上一任务中显示的 Agent 令牌。
1. 将变量 `TF_VAR_kas_address` 设置为上一任务中显示的 Agent 服务器地址。

**可选配置**：

文件 [`variables.tf`](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-eks/-/blob/main/variables.tf) 包含其他变量，您可以根据需要进行覆盖：

- `TF_VAR_region`：设置集群的区域。
- `TF_VAR_cluster_name`：设置集群的名称。
- `TF_VAR_cluster_version`：设置 Kubernetes 的版本。
- `TF_VAR_instance_type`：设置 Kubernetes 节点的实例类型。
- `TF_VAR_instance_count`：设置 Kubernetes 节点的数量。
- `TF_VAR_agent_namespace`：为极狐GitLab Kubernetes Agent 设置 Kubernetes 命名空间。

查看 [AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) 和 [Kubernetes Terraform provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) 文档，了解更多资源选项。

<a id="provision-your-cluster"></a>

## 预配您的集群

配置项目后，手动触发集群的预配。在极狐GitLab 中：

1. 在左侧边栏中，转到**构建** > **流水线**。
1. 在**运行**（{{< icon name="play" >}}）旁边，选择下拉列表图标（{{< icon name="chevron-lg-down" >}}）。
1. 选择**部署**以手动触发部署作业。

当流水线成功完成后，您可以查看新集群：

- 在 AWS 中：从 [EKS 控制台](https://console.aws.amazon.com/eks/home)中，选择 **Amazon EKS** > **集群**。
- 在极狐GitLab 中：在左侧边栏中，选择**运维** > **Kubernetes 集群**。

<a id="use-your-cluster"></a>

## 使用您的集群

预配集群后，它会连接到极狐GitLab，并可用于部署。要检查连接：

1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 在列表中，查看**连接状态**列。

有关该连接功能的更多信息，请参阅[极狐GitLab Kubernetes Agent 文档](../_index.md)。

<a id="remove-the-cluster"></a>

## 移除集群

默认情况下，您的流水线中不包含清理作业。要移除所有已创建的资源，您必须在运行清理作业之前修改极狐GitLab CI/CD 模板。

要移除所有资源：

1. 将以下内容添加到您的 `.gitlab-ci.yml` 文件中：

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

1. 在左侧边栏中，选择**构建** > **流水线**，然后选择最近的流水线。
1. 对于 `destroy` 作业，选择**运行**（{{< icon name="play" >}}）。
