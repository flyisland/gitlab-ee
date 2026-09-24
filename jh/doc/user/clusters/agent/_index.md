---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 Kubernetes 集群连接到极狐GitLab
description: Kubernetes 集成、GitOps、CI/CD、代理部署和集群管理。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.10 中，Flux 被推荐为 GitOps 解决方案。

{{< /history >}}

您可以将 Kubernetes 集群与极狐GitLab 连接，以部署、管理和监控您的云原生解决方案。

要连接 Kubernetes 集群到极狐GitLab，您必须先在集群中[安装一个代理](install/_index.md)。

代理在集群中运行，您可以使用它：

- 与位于防火墙或 NAT 后面的集群进行通信。
- 实时访问集群中的 API 端点。
- 推送有关集群中发生的事件的信息。
- 启用 Kubernetes 对象缓存，这些对象以极低的延迟保持最新状态。

有关代理的用途和架构的更多详细信息，请查看[架构文档](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/-/blob/master/doc/architecture.md)。

您必须为要连接到极狐GitLab 的每个集群部署一个单独的代理。该代理的设计具有强大的多租户支持。为了简化维护和操作，应该每个集群只运行一个代理。

代理总是在一个极狐GitLab 项目中注册。代理注册和安装后，代理与集群的连接可以与其他项目、群组和用户共享。这种方法意味着你可以从极狐GitLab 本身管理和配置你的代理实例，并且可以将单个安装扩展到多个租户。

<a id="supported-kubernetes-versions-for-gitlab-features"></a>

## 极狐GitLab 功能支持的 Kubernetes 版本

极狐GitLab 支持以下 Kubernetes 版本。如果您想在 Kubernetes 集群中运行极狐GitLab，您可能需要不同版本的 Kubernetes：

- 对于[Helm Chart](https://gitlab.cn/docs/charts/installation/cloud/)。
- 对于[极狐GitLab Operator](https://gitlab.cn/docs/operator/installation/)。

您可以随时将 Kubernetes 版本升级到受支持的版本：

- 1.35（支持结束于极狐GitLab 版本 19.10 发布时或 1.38 成为支持版本时）
- 1.34（支持结束于极狐GitLab 版本 19.7 发布时或 1.37 成为支持版本时）
- 1.33（支持结束于极狐GitLab 版本 19.2 发布时或 1.36 成为支持版本时）

极狐GitLab 的目标是在新次要 Kubernetes 版本初始发布三个月后提供支持。极狐GitLab 在任何时候都至少支持三个可用于生产环境的 Kubernetes 次要版本。

当新版本的 Kubernetes 发布时：

- 此页面将在大约四周内更新早期冒烟测试的结果。
- 如果新版本支持的发布延迟，此页面将在大约八周内更新预期的极狐GitLab 支持版本。

安装代理时，请使用与你的 Kubernetes 版本兼容的 Helm 版本。其他 Helm 版本可能无法使用。有关兼容版本的列表，请参阅 [Helm 版本支持政策](https://helm.sh/docs/topics/version_skew/)。

当极狐GitLab 不再支持仅支持已弃用 API 的 Kubernetes 版本时，对已弃用 API 的支持可能会从极狐GitLab 代码库中移除。

某些极狐GitLab 功能可能在未列出的版本上也能工作。该史诗追踪 Kubernetes 版本的支持情况。

<a id="kubernetes-deployment-workflows"></a>

## Kubernetes 部署工作流

您可以从两种主要工作流中选择。推荐使用 GitOps 工作流。

<a id="gitops-workflow"></a>

### GitOps 工作流

极狐GitLab 建议使用 [Flux for GitOps](gitops.md)。要开始，请参阅[教程：为 GitOps 设置 Flux](getting_started.md)。

<a id="gitlab-cicd-workflow"></a>

### 极狐GitLab CI/CD 工作流

在[**CI/CD** 工作流](ci_cd_workflow.md)中，您配置极狐GitLab CI/CD 使用 Kubernetes API 来查询和更新您的集群。

此工作流被视为**推送式（push-based）**，因为极狐GitLab 将请求从极狐GitLab CI/CD 推送到您的集群。

适用场景：

- 当您有流水线驱动的流程时。
- 当您需要迁移到代理，但 GitOps 工作流不支持您的用例时。

此工作流的安全模型较弱。您不应使用 CI/CD 工作流进行生产部署。

<a id="agent-connection-technical-details"></a>

## 代理连接技术细节

代理打开一个通往 KAS 的双向通道进行通信。该通道用于代理与 KAS 之间的所有通信：

- 每个代理最多可以维持 500 个逻辑 gRPC 流，包括活跃和空闲的流。
- gRPC 流使用的 TCP 连接数量由 gRPC 自身决定。
- 每个连接的最大生存期为两小时，并有一小时的宽限期。
  - KAS 前面的代理可能影响连接的最大生存期。在 JihuLab.com 上，这是[两小时](https://jihulab.com/gitlab-cookbooks/gitlab-haproxy/-/blob/68df3484087f0af368d074215e17056d8ab69f1c/attributes/default.rb#L217)。宽限期为最大生存期的 50%。

有关通道路由的详细信息，请参阅[代理中的 KAS 请求路由](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/-/blob/master/doc/kas_request_routing.md)。

<a id="receptive-agents"></a>

## 接受型代理

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.4 中引入。

{{< /history >}}

接受型代理允许极狐GitLab 与无法建立与极狐GitLab 实例的网络连接但可以被极狐GitLab 连接的 Kubernetes 集集群成。例如，在以下情况可能会发生：

1. 极狐GitLab 在私有网络中运行或位于防火墙后，仅可通过 VPN 访问。
2. Kubernetes 集群托管在云提供商上，但暴露在互联网上或可从私有网络访问。

启用此功能后，极狐GitLab 将使用提供的 URL 连接到代理。您可以同时使用代理和接受型代理。

<a id="kubernetes-integration-glossary"></a>

## Kubernetes 集成词汇表

本词汇表提供了与极狐GitLab Kubernetes 集成相关的术语定义。

| 术语 | 定义 | 范围 |
| --- | --- | --- |
| 用于 Kubernetes 的极狐GitLab 代理 | 整体产品，包括相关功能以及底层组件 `agentk` 和 `kas`。 | 极狐GitLab，Kubernetes，Flux |
| `agentk` | 集群侧组件，用于维持与极狐GitLab 的安全连接，以实现 Kubernetes 管理和部署自动化。 | 极狐GitLab |
| 用于 Kubernetes 的极狐GitLab 代理服务器 (`kas`) | 极狐GitLab 的 GitLab 侧组件，处理 Kubernetes 代理集成的操作和逻辑。管理极狐GitLab 与 Kubernetes 集群之间的连接和通信。 | 极狐GitLab |
| 拉取式部署 | 一种部署方法，Flux 检查 Git 仓库中的更改并自动将这些更改应用到集群。 | 极狐GitLab，Kubernetes |
| 推送式部署 | 一种部署方法，更新从极狐GitLab CI/CD 流水线发送到 Kubernetes 集群。 | 极狐GitLab |
| Flux | 一个开源的 GitOps 工具，与代理集成以实现拉取式部署。 | GitOps，Kubernetes |
| GitOps | 一套实践，涉及使用 Git 进行版本控制和协作，以管理和自动化云和 Kubernetes 资源。 | DevOps，Kubernetes |
| Kubernetes 命名空间 | Kubernetes 集群中的一个逻辑分区，用于在多个用户或环境之间划分集群资源。 | Kubernetes |