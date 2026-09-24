---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建 Azure AKS 集群
---

您可以借助[基础设施即代码 (IaC)](../../_index.md) 在 Azure Kubernetes Service (AKS) 上创建集群。该过程使用 Azure 和 Kubernetes Terraform provider 创建 AKS 集群。您可以通过 Kubernetes 的极狐GitLab 代理将集群连接到极狐GitLab。

**开始之前**：

- 一个已配置[安全凭证](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)的 Microsoft Azure 账户。
- 一个可用于运行极狐GitLab CI/CD 流水线的 [Runner](https://gitlab.cn/docs/runner/install/)。

**步骤**：

1. [导入示例项目](#导入示例项目)。
1. [注册代理](#注册代理)。
1. [配置项目](#配置项目)。
1. [部署集群](#部署集群)。

<a id="import-the-example-project"></a>

## 导入示例项目

要从极狐GitLab 使用基础设施即代码创建集群，您必须创建一个用于管理该集群的项目。在本教程中，您将从一个示例项目开始，并根据需要对其进行修改。

首先通过 [URL 导入示例项目](../../../import/third_party_systems/repo_by_url.md)。

导入项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/代码库**。
1. 选择 **导入项目**。
1. 选择 **通过 URL 导入代码库**。
1. 在 **Git 仓库 URL** 中输入 `https://jihulab.com/gitlab-cn/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks.git`。
1. 填写必填字段，然后选择 **创建项目**。

这个项目为您提供了：

- 一个 [Azure Kubernetes Service (AKS)](https://jihulab.com/gitlab-cn/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks/-/blob/main/aks.tf) 集群。
- 安装在集群中的 [Kubernetes 的极狐GitLab 代理](https://jihulab.com/gitlab-cn/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks/-/blob/main/agent.tf)。

<a id="register-the-agent"></a>

## 注册代理

要创建 Kubernetes 的极狐GitLab 代理：

1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 选择 **连接集群（代理）**。
1. 从 **选择代理** 下拉列表中，选择 `aks-agent`，然后选择 **注册代理**。
1. 极狐GitLab 会为该代理生成一个注册令牌。请安全存储此密钥令牌，因为稍后会用到它。
1. 极狐GitLab 会提供代理服务器 (KAS) 地址，该地址稍后也会用到。

<a id="configure-your-project"></a>

## 配置项目

使用 CI/CD 环境变量来配置项目。

**必需配置**：

1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 将变量 `ARM_CLIENT_ID` 设置为您的 Azure 客户端 ID。
1. 将变量 `ARM_CLIENT_SECRET` 设置为您的 Azure 客户端密钥。
1. 将变量 `ARM_TENANT_ID` 设置为您的服务主体。
1. 将变量 `TF_VAR_agent_token` 设置为上一步中显示的代理令牌。
1. 将变量 `TF_VAR_kas_address` 设置为上一步中显示的代理服务器地址。

**可选配置**：

文件 [`variables.tf`](https://jihulab.com/gitlab-cn/ci-cd/deploy-stage/environments-group/examples/gitlab-terraform-aks/-/blob/main/variables.tf) 包含其他您可以根据需要覆盖的变量：

- `TF_VAR_location`：设置集群的区域。
- `TF_VAR_cluster_name`：设置集群的名称。
- `TF_VAR_kubernetes_version`：设置 Kubernetes 的版本。
- `TF_VAR_create_resource_group`：允许启用或禁用新资源组的创建（默认设置为 true）。
- `TF_VAR_resource_group_name`：设置资源组名称。
- `TF_VAR_agent_namespace`：为 Kubernetes 的极狐GitLab 代理设置 Kubernetes 命名空间。

有关更多资源选项，请参阅 [Azure Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) 和 [Kubernetes Terraform provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) 文档。

<a id="provision-your-cluster"></a>

## 部署集群

配置项目后，手动触发集群的部署。在极狐GitLab 中：

1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 在 **运行** ({{< icon name="play" >}}) 旁边，选择下拉列表图标 ({{< icon name="chevron-lg-down" >}})。
1. 选择 **部署** 以手动触发部署作业。

当流水线成功完成时，您可以查看新集群：

- 在 Azure 中：从 [Azure 门户](https://portal.azure.com/#home) 选择 **Kubernetes 服务** > **查看**。
- 在极狐GitLab 中：在左侧边栏中，选择 **运维** > **Kubernetes 集群**。

<a id="use-your-cluster"></a>

## 使用集群

部署集群后，它将连接到极狐GitLab 并可以用于部署。要检查连接：

1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 在列表中，查看 **连接状态** 列。

有关连接功能的更多信息，请参阅 [Kubernetes 的极狐GitLab 代理文档](../_index.md)。

<a id="remove-the-cluster"></a>

## 删除集群

默认情况下，清理作业不包含在您的流水线中。要删除所有已创建的资源，您必须修改极狐GitLab CI/CD 模板，然后才能运行清理作业。

要删除所有资源：

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

1. 在左侧边栏中，选择 **构建** > **流水线**，然后选择最近的流水线。
1. 对于 `destroy` 作业，选择 **运行** ({{< icon name="play" >}})。