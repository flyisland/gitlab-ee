---
stage: AI 驱动
group: AI 框架
info: 如需确定与此页面相关的阶段/群组对应的技术文档作者，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: AI 网关
---

<a id="ai-gateway"></a>

# AI 网关

AI 网关是一项独立服务，可让你访问 AI 原生的极狐GitLab Duo 功能。

极狐GitLab 在云端运营着一个 AI 网关实例。
此实例供 GitLab.com、[极狐GitLab 私有化部署](configure/gitlab_self_managed.md)和 GitLab Dedicated 使用。

你也可以通过[极狐GitLab Duo 私有化部署模型](../gitlab_duo_self_hosted/_index.md)在私有化部署实例上使用自部署的 AI 网关实例。

<a id="automatic-data-routing"></a>

## 自动数据路由

极狐GitLab 利用负载均衡器，将 AI 网关请求自动路由到最近可用的部署。该路由机制优先考虑低延迟和高效处理用户请求。

你无法手动控制此路由过程。
影响数据路由的因素如下：

- 网络延迟：主要路由机制侧重于最小化延迟。如果网络状况决定，数据可能会在非最近区域处理。
- 服务可用性：在发生区域性中断或服务中断时，请求可能会自动重新路由，以确保服务不中断。
- 第三方依赖项：极狐GitLab AI 基础设施依赖第三方模型提供商，这些提供商有自己的数据处理实践。

<a id="direct-and-indirect-connections"></a>

### 直接和间接连接

默认情况下，IDE 直接与 AI 网关通信，绕过极狐GitLab 单体架构。
这种直接连接提高了路由效率。

要更改此行为，请为代码建议配置[直接和间接连接](../../user/project/repository/code_suggestions/_index.md#direct-and-indirect-connections)。

<a id="tracing-requests-to-specific-regions"></a>

### 追踪请求到特定区域

你无法直接将你的 AI 请求追踪到特定区域。

如果你需要帮助追踪特定请求，极狐GitLab 支持团队可以访问和分析包含请求头信息及实例 UUID 的日志。
这些日志提供了对路由路径的洞察，并有助于识别请求的处理区域。

<a id="data-sovereignty"></a>

## 数据主权

多区域 AI 网关部署不强制执行严格的数据主权。
请求不保证会流向或保留在特定区域。

此服务不是数据驻留解决方案。

<a id="deployment-regions"></a>

### 部署区域

极狐GitLab 在以下区域部署 AI 网关：

- 北美 (`us-east4`)
- 欧洲 (`europe-west2`, `europe-west3`, and `europe-west9`)
- 亚太 (`asia-northeast1` and `asia-northeast3`)

AI 网关使用的大语言模型的确切位置由第三方模型提供商决定。
这些模型不保证驻留在与 AI 网关部署相同的地理区域。
即使 AI 网关在某个区域处理初始请求，数据也可能流向模型提供商运营的其他区域。
数据会根据性能和可用性路由到最优区域。