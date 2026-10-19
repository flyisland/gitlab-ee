---
stage: AI Platform
group: AI Core Infra
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: AI 网关
---

AI 网关是一项独立服务，用于访问 AI 原生的极狐GitLab Duo 功能。

极狐GitLab 运营着一个部署在云端的 AI 网关实例。
JihuLab.com 和[极狐GitLab 私有化部署](configure/_index.md)均使用此实例。

您也可以在极狐GitLab 私有化部署上使用自托管的 AI 网关实例，通过[极狐GitLab Duo 自部署版本](../gitlab_duo_self_hosted/_index.md)实现。

<a id="region-support"></a>

## 区域支持

AI 网关仅服务于单个区域：中国大陆、香港和澳门。您无法选择其他部署区域。

<a id="automatic-data-routing"></a>

## 自动数据路由

极狐GitLab 使用 Cloudflare 和 Google Cloud Platform (GCP) 负载均衡器，将 AI
网关请求自动路由到最近的可用部署。此路由机制优先考虑低延迟和高效处理用户请求。

您无法手动控制此路由过程。以下因素会影响数据的路由位置：

- 网络延迟：主要路由机制侧重于尽量降低延迟。
  如果网络状况需要，数据可能由非最近的部署处理。
- 服务可用性：如果发生部署中断或服务中断，
  请求可能会被自动重新路由，以确保服务不中断。
- 第三方依赖项：极狐GitLab AI 基础设施依赖第三方模型提供商，
  例如 [PPIO](https://ppio.com/)、[万界](https://fangzhou.wanjiedata.com/)和
  [网宿](https://online.wangsu.com/)，它们有各自的数据处理方式。

<a id="direct-and-indirect-connections"></a>

### 直接连接和间接连接

默认情况下，IDE 直接与 AI 网关通信，绕过极狐GitLab 单体应用。这种直接连接可提高路由效率。

要更改此行为，请为代码建议配置[直接连接和间接连接](../../user/project/repository/code_suggestions/_index.md#direct-and-indirect-connections)。

<a id="tracing-requests-to-specific-regions"></a>

### 将请求追踪到特定区域

您无法直接将 AI 请求追踪到特定区域。

如果您需要协助追踪某个特定请求，极狐GitLab 支持可以访问并
分析包含 Cloudflare 请求头和实例 UUID 的日志。
这些日志可提供有关路由路径的洞察，并有助于确定请求的处理区域。

<a id="data-sovereignty"></a>

## 数据主权

AI 网关将中国大陆、香港和澳门作为单个区域提供服务。此部署不强制执行严格的数据主权。

此服务不是数据驻留解决方案。

<a id="deployment-regions"></a>

### 部署区域

极狐GitLab 将 AI 网关部署在覆盖中国大陆、香港和澳门的单个区域中。

AI 网关所使用的 LLM 模型的确切位置由第三方模型提供商决定。
