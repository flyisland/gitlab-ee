---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建 Civo Kubernetes 集群
---

每个新的 Civo 账号都会获得 [$250 赠金](https://dashboard.civo.com/signup)，用于开始使用极狐GitLab 与 Civo Kubernetes 的集成。您也可以使用市场应用在 Civo Kubernetes 集群上安装极狐GitLab。

了解如何通过[基础设施即代码（IaC）](../../_index.md)在 Civo Kubernetes 上创建新集群。此过程使用 Civo 和 Kubernetes Terraform 提供商来创建 Civo Kubernetes 集群。您可以使用极狐GitLab Kubernetes Agent 将集群连接到极狐GitLab。

**开始之前**：

- 一个 [Civo 账号](https://dashboard.civo.com/signup)。
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

1. 在极狐GitLab 中，在顶部栏中选择**搜索或跳转到**。
1. 选择**查看我的所有项目**。
1. 在页面右侧，选择**新建项目**。
1. 选择**导入项目**。
1. 选择**通过 URL 导入代码仓库**。
1. 在 **Git 代码仓库 URL**中，输入 `https://gitlab.com/civocloud/gitlab-terraform-civo.git`。
1. 填写各字段并选择**创建项目**。

此项目为您提供：

- 一个 [Civo 上的集群](https://gitlab.com/civocloud/gitlab-terraform-civo/-/blob/master/civo.tf)，其中包含名称、区域、节点数量和 Kubernetes 版本的默认值。
- 安装在集群中的[极狐GitLab Kubernetes Agent](https://gitlab.com/civocloud/gitlab-terraform-civo/-/blob/master/agent.tf)。

<a id="register-the-agent"></a>

## 注册代理

要创建极狐GitLab Kubernetes Agent：

1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 选择**连接集群**。
1. 在**选择一个代理** 下拉列表中，选择 `civo-agent`，然后选择**注册**。
1. 极狐GitLab 会为该代理生成一个代理访问令牌。请妥善保存此密钥令牌，稍后会用到。
1. 极狐GitLab 会提供代理服务器（KAS）的地址，稍后也会用到。

<a id="configure-your-project"></a>

## 配置您的项目

使用 CI/CD 环境变量来配置您的项目。

**必需配置**：

1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 将变量 `CIVO_TOKEN` 设置为您的 Civo 账号中的令牌。
1. 将变量 `TF_VAR_agent_token` 设置为上一步中获得的代理令牌。
1. 将变量 `TF_VAR_kas_address` 设置为上一步中的代理服务器地址。

![必需配置](img/variables_civo_v17_3.png)

**可选配置**：

文件 [`variables.tf`](https://gitlab.com/civocloud/gitlab-terraform-civo/-/blob/master/variables.tf) 包含其他变量，您可以根据需要进行覆盖：

- `TF_VAR_civo_region`：设置集群的区域。
- `TF_VAR_cluster_name`：设置集群的名称。
- `TF_VAR_cluster_description`：为集群设置描述。要在 Civo 集群详情页上创建指向您的极狐GitLab 项目的引用，请将此值设置为 `$CI_PROJECT_URL`。此值可帮助您确定在 Civo 仪表板上看到的集群是由哪个项目预配的。
- `TF_VAR_target_nodes_size`：设置集群所用节点的规格
- `TF_VAR_num_target_nodes`：设置 Kubernetes 节点的数量。
- `TF_VAR_agent_version`：设置极狐GitLab Kubernetes Agent 的版本。
- `TF_VAR_agent_namespace`：设置极狐GitLab Kubernetes Agent 的 Kubernetes 命名空间。

有关更多资源选项，请参阅 [Civo Terraform 提供商](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/kubernetes_cluster)和 [Kubernetes Terraform 提供商](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)文档。

<a id="provision-your-cluster"></a>

## 预配您的集群

配置项目后，手动触发集群的预配。在极狐GitLab 中：

1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择**新建流水线**。
1. 选择**运行流水线**，然后从列表中选择新建的流水线。
1. 在 **deploy** 作业旁边，选择**手动操作**（{{< icon name="status_manual" >}}）。

当流水线成功完成后，您可以看到新集群：

- 在 Civo 仪表板中：在您的 Kubernetes 标签页上。
- 在极狐GitLab 中：在项目的左侧边栏中，选择**运维** > **Kubernetes 集群**。

如果您未设置 `TF_VAR_civo_region` 变量，集群将创建在 'lon1' 区域。

<a id="use-your-cluster"></a>

## 使用您的集群

预配集群后，它会连接到极狐GitLab，并可用于部署。要检查连接：

1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 在列表中，查看**连接状态**列。

有关连接功能的更多信息，请参阅[极狐GitLab Kubernetes Agent 文档](../_index.md)。

<a id="remove-the-cluster"></a>

## 移除集群

您的流水线中默认包含一个清理作业。

要移除所有已创建的资源：

1. 在左侧边栏中，选择**构建** > **流水线**，然后选择最近的流水线。
1. 在 **destroy-environment** 作业旁边，选择**手动操作**（{{< icon name="status_manual" >}}）。

<a id="civo-support"></a>

## Civo 支持

此 Civo 集成由 Civo 提供支持。请将您的支持请求发送至 [Civo 支持](https://www.civo.com/contact)。
