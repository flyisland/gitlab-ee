---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建 Azure AKS 集群
---

您可以通过[基础设施即代码（IaC）](../../_index.md)在 Azure Kubernetes Service（AKS）上创建集群。此过程使用 Azure 和 Kubernetes Terraform 提供商来创建 AKS 集群。您可以使用极狐GitLab Kubernetes Agent 将集群连接到极狐GitLab。

**开始之前**：

- 一个 Microsoft Azure 账号，并配置好一组
  [安全凭证](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest)。
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

要导入项目：

1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**导入项目**。
1. 选择**通过 URL 导入代码仓库**。
1. 在 **Git 代码仓库 URL**中，输入 `https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks.git`。
1. 填写各字段并选择**创建项目**。

此项目为您提供：

- 一个 [Azure Kubernetes Service（AKS）](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks/-/blob/main/aks.tf)集群。
- 安装在集群中的[极狐GitLab Kubernetes Agent](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks/-/blob/main/agent.tf)。

<a id="register-the-agent"></a>

## 注册代理

要创建极狐GitLab Kubernetes Agent：

1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 选择**连接集群（代理）**。
1. 在**选择一个代理** 下拉列表中，选择 `aks-agent`，然后选择**注册代理**。
1. 极狐GitLab 会为该代理生成注册令牌。请安全存储此密钥令牌，稍后会用到。
1. 极狐GitLab 会提供代理服务器（KAS）的地址，稍后也会用到。

<a id="configure-your-project"></a>

## 配置您的项目

使用 CI/CD 环境变量来配置您的项目。

**必需配置**：

1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 将变量 `ARM_CLIENT_ID` 设置为您的 Azure 客户端 ID。
1. 将变量 `ARM_CLIENT_SECRET` 设置为您的 Azure 客户端密钥。
1. 将变量 `ARM_TENANT_ID` 设置为您的服务主体。
1. 将变量 `TF_VAR_agent_token` 设置为上一步中显示的代理令牌。
1. 将变量 `TF_VAR_kas_address` 设置为上一步中显示的代理服务器地址。

**可选配置**：

文件 [`variables.tf`](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks/-/blob/main/variables.tf) 包含其他变量，您可以根据需要进行覆盖：

- `TF_VAR_location`：设置集群的区域。
- `TF_VAR_cluster_name`：设置集群的名称。
- `TF_VAR_kubernetes_version`：设置 Kubernetes 的版本。
- `TF_VAR_create_resource_group`：启用或禁用新资源组的创建。（默认设置为 true）。
- `TF_VAR_resource_group_name`：设置资源组的名称。
- `TF_VAR_agent_namespace`：为极狐GitLab Kubernetes Agent 设置 Kubernetes 命名空间。

有关更多资源选项，请参阅 [Azure Terraform 提供商](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)和 [Kubernetes Terraform 提供商](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)文档。

<a id="provision-your-cluster"></a>

## 预配您的集群

配置项目后，手动触发集群的预配。在极狐GitLab 中：

1. 在左侧边栏中，选择**构建** > **流水线**。
1. 在**运行**（{{< icon name="play" >}}）旁边，选择下拉列表图标（{{< icon name="chevron-lg-down" >}}）。
1. 选择**部署**以手动触发部署作业。

当流水线成功完成后，您可以查看新集群：

- 在 Azure 中：从 [Azure 门户](https://portal.azure.com/#home)中，选择 **Kubernetes 服务** > **查看**。
- 在极狐GitLab 中：在左侧边栏中，选择**运维** > **Kubernetes 集群**。

<a id="use-your-cluster"></a>

## 使用您的集群

预配集群后，它会连接到极狐GitLab，并可供部署使用。要检查连接：

1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 在列表中，查看**连接状态**列。

有关连接功能的更多信息，请参阅[极狐GitLab Kubernetes Agent 文档](../_index.md)。

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
