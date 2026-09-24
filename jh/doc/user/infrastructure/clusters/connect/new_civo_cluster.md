---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建 Civo Kubernetes 集群
---

每个新的 Civo 账户可获得 [$250 信用额度](https://dashboard.civo.com/signup)，以开始使用极狐GitLab 与 Civo Kubernetes 的集成。您还可以使用市场应用在您的 Civo Kubernetes 集群上安装极狐GitLab。

了解如何通过 [基础设施即代码 (IaC)](../../_index.md) 在 Civo Kubernetes 上创建新集群。此过程使用 Civo 和 Kubernetes Terraform 提供程序来创建 Civo Kubernetes 集群。您可以使用极狐GitLab Kubernetes 代理将集群连接到极狐GitLab。

**开始之前**：

- 一个 [Civo 账户](https://dashboard.civo.com/signup)。
- 一个 [Runner](https://gitlab.cn/docs/runner/install/)，您可以用其运行极狐GitLab CI/CD 流水线。

**步骤**：

1. [导入示例项目](#import-the-example-project)。
1. [注册代理](#register-the-agent)。
1. [配置项目](#configure-your-project)。
1. [预配集群](#provision-your-cluster)。

<a id="import-the-example-project"></a>

## 导入示例项目

要从极狐GitLab 使用基础设施即代码创建集群，您必须创建一个项目来管理该集群。在本教程中，您将从一个示例项目开始，然后根据需要进行修改。

首先，[通过 URL 导入示例项目](../../../import/third_party_systems/repo_by_url.md)。

要导入项目：

1. 在极狐GitLab 顶部栏中，选择 **搜索或跳转到**。
1. 选择 **查看所有我的项目**。
1. 在页面右侧，选择 **新建项目**。
1. 选择 **导入项目**。
1. 选择 **通过 URL 导入仓库**。
1. 在 **Git 仓库 URL** 中，输入 `https://jihulab.com/civocloud/gitlab-terraform-civo.git`。
1. 填写字段并选择 **创建项目**。

该项目为您提供：

- 一个 [Civo 上的集群](https://jihulab.com/civocloud/gitlab-terraform-civo/-/blob/master/civo.tf)，包含名称、区域、节点数量和 Kubernetes 版本的默认设置。
- 在集群中安装的 [极狐GitLab Kubernetes 代理](https://jihulab.com/civocloud/gitlab-terraform-civo/-/blob/master/agent.tf)。

<a id="register-the-agent"></a>

## 注册代理

要创建极狐GitLab Kubernetes 代理：

1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 选择 **连接集群**。
1. 从 **选择代理** 下拉列表中，选择 `civo-agent` 并选择 **注册**。
1. 极狐GitLab 会为此代理生成一个代理访问令牌。请安全存储此密钥令牌，因为您稍后会用到它。
1. 极狐GitLab 会提供代理服务器 (KAS) 的地址，您稍后也会用到。

<a id="configure-your-project"></a>

## 配置项目

使用 CI/CD 环境变量来配置您的项目。

**必需的配置**：

1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 将变量 `CIVO_TOKEN` 设置为您的 Civo 账户令牌。
1. 将变量 `TF_VAR_agent_token` 设置为您在上一步中收到的代理令牌。
1. 将变量 `TF_VAR_kas_address` 设置为您在上一步中收到的代理服务器地址。

![必需的配置](img/variables_civo_v17_3.png)

**可选配置**：

文件 [`variables.tf`](https://jihulab.com/civocloud/gitlab-terraform-civo/-/blob/master/variables.tf) 包含其他您可以根据需要覆盖的变量：

- `TF_VAR_civo_region`：设置您集群的区域。
- `TF_VAR_cluster_name`：设置您集群的名称。
- `TF_VAR_cluster_description`：设置集群的描述。要在 Civo 集群详情页上创建到极狐GitLab 项目的引用，请将此值设置为 `$CI_PROJECT_URL`。此值可帮助您确定哪个项目负责预配您在 Civo 仪表板上看到的集群。
- `TF_VAR_target_nodes_size`：设置用于集群的节点大小
- `TF_VAR_num_target_nodes`：设置 Kubernetes 节点的数量。
- `TF_VAR_agent_version`：设置极狐GitLab Kubernetes 代理的版本。
- `TF_VAR_agent_namespace`：设置极狐GitLab Kubernetes 代理的 Kubernetes 命名空间。

请参阅 [Civo Terraform 提供程序](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/kubernetes_cluster) 和 [Kubernetes Terraform 提供程序](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) 文档以获取更多资源配置项。

<a id="provision-your-cluster"></a>

## 预配集群

配置项目后，手动触发集群的预配。在极狐GitLab 中：

1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择 **新建流水线**。
1. 选择 **运行流水线**，然后从列表中选择新创建的流水线。
1. 在 **部署** 作业旁边，选择 **手动操作** ({{< icon name="status_manual" >}})。

当流水线成功完成后，您可以看到您的新集群：

- 在 Civo 仪表板中：在您的 Kubernetes 标签页上。
- 在极狐GitLab 中：从项目侧边栏中选择 **运维** > **Kubernetes 集群**。

如果您未设置 `TF_VAR_civo_region` 变量，集群将在 'lon1' 区域创建。

<a id="use-your-cluster"></a>

## 使用集群

预配集群后，它将连接到极狐GitLab 并准备好进行部署。要检查连接：

1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 在列表中，查看 **连接状态** 列。

有关连接功能的更多信息，请参阅 [极狐GitLab Kubernetes 代理文档](../_index.md)。

<a id="remove-the-cluster"></a>

## 移除集群

默认情况下，您的流水线中包含一个清理作业。

要移除所有已创建的资源：

1. 在左侧边栏中，选择 **构建** > **流水线**，然后选择最新的流水线。
1. 在 **销毁环境** 作业旁边，选择 **手动操作** ({{< icon name="status_manual" >}})。

<a id="civo-support"></a>

## Civo 支持

此 Civo 集成由 Civo 提供支持。请将您的支持请求发送至 [Civo 支持](https://www.civo.com/contact)。