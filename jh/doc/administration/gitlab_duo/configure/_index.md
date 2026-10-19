---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为您的极狐GitLab 实例配置极狐GitLab Duo。
title: 配置极狐GitLab Duo
---

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

极狐GitLab Duo 是一款 AI 原生助手，可在整个软件开发生命周期中为您提供帮助。

您可以将极狐GitLab Duo 配置为使用：

- 基于云的 AI 网关（默认）：由极狐GitLab 托管、使用厂商语言模型的 AI 网关。
- 自部署模型：您自己的 AI 网关和语言模型，
  可完全掌控您的数据和安全。
- 混合配置：部分功能使用自部署模型，
  其他功能使用基于云的模型。

<a id="prerequisites"></a>

## 先决条件

- 静默模式已[关闭](../../silent_mode/_index.md#turn-off-silent-mode)。
- [您的实例已使用激活码激活](../../license.md#activate-gitlab-ee)。
  - 您不能使用许可证密钥。
  - 您不能将极狐GitLab Duo 与离线许可证一起使用，但[极狐GitLab Duo 自部署版本](../../gitlab_duo_self_hosted/_index.md)除外。
- 运行您实例的主机必须能够通过 DNS 解析公共主机名，即使使用 HTTP/S 代理服务器也是如此。

<a id="allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo"></a>

## 允许从极狐GitLab 实例到极狐GitLab Duo 的出站连接

- 极狐GitLab 应用节点必须通过 HTTP/2 连接到位于 `https://duo-workflow-svc.runway.gitlab.net`的极狐GitLab Duo Workflow。应用与服务之间通过 gRPC 通信。
- 对于极狐GitLab Duo Agent Platform 功能，您的防火墙和 HTTP/S 代理服务器必须允许通过 `https://` 出站连接到 `duo-workflow-svc.runway.gitlab.net`的 `443` 端口，并支持
  HTTP/2 流量。
- 如果您的实例通过 HTTP/S 代理服务器连接，该主机仍必须
  能够通过 DNS 解析公共主机名。如果只能
  通过代理服务器解析主机名，则极狐GitLab Duo 健康检查、
  极狐GitLab Credits 仪表板和极狐GitLab Duo Agent Platform 等极狐GitLab Duo 功能可能会超时或失败。
  更多信息，请参见[议题 602538](https://gitlab.com/gitlab-org/gitlab/-/issues/602538)。
- AI 功能通过长连接 HTTP 连接流式传输响应。如果 HTTP/S 代理服务器
  或防火墙强制执行最大请求时长或空闲超时，可能会在没有错误的情况下
  中断长响应。请将代理的超时配置为比路径中其他组件更长。

<a id="allow-inbound-connections-from-clients-to-the-gitlab-instance"></a>

## 允许从客户端到极狐GitLab 实例的入站连接

您的极狐GitLab 实例必须允许来自 IDE 客户端的入站连接。

1. 允许带有以下请求头的 WebSocket 协议升级请求：
   - `Connection: upgrade`
   - `Upgrade: websocket`
   - `HTTP/2` 协议支持
   - 标准 WebSocket 安全请求头：`Sec-WebSocket-*`
1. 启用 `wss://`（WebSocket Secure）协议支持。
1. 添加要允许的特定端点：
   - 主端点：`wss://<customer-instance>/-/cable`
   - 确保 `HTTP/2` 协议不会降级为 `HTTP/1.1`。
   - 端口：`443`（HTTPS/WSS）

如果您遇到问题：

- 检查对 `wss://gitlab.example.com/-/cable` 和其他 `.com` 域名的 WebSocket 流量限制。
- 如果您使用 Apache 等反向代理，可能会在日志中看到极狐GitLab Duo Chat 连接问题，
  例如 **WebSocket connection to .... failures**。

要解决此问题，请编辑您的代理设置。

对于 Apache 2.4.47 及更高版本，请在 `ProxyPass` 指令中添加 `upgrade=websocket`，
以便 Apache 为 WebSocket 流量升级连接：

```apache
# Needs proxy_http and proxy_wstunnel enabled
ProxyPass / http://127.0.0.1:8181/ upgrade=websocket
ProxyPassReverse / http://127.0.0.1:8181/
```

对于更早的 Apache 版本，请使用重写规则将 WebSocket 流量路由到 `ws://` 协议：

```apache
# Enable WebSocket reverse Proxy
# Needs proxy_wstunnel enabled
  RewriteCond %{HTTP:Upgrade} websocket [NC]
  RewriteCond %{HTTP:Connection} upgrade [NC]
  RewriteRule ^/?(.*) "ws://127.0.0.1:8181/$1" [P,L]
```

代理上缺少 WebSocket 升级还会破坏其他通过 Action Cable（`/-/cable`）流式传输的极狐GitLab 功能，
例如合并请求和流水线状态的实时更新。

<a id="allow-connections-from-the-runner"></a>

## 允许来自 Runner 的连接

对于使用 Runner 的极狐GitLab Duo Agent Platform 功能（例如任务流），
Runner 必须能够连接到极狐GitLab 实例。

必须允许与[从客户端到极狐GitLab 实例的入站连接](#allow-inbound-connections-from-clients-to-the-gitlab-instance)相同的连接，作为从 Runner 到极狐GitLab 实例的出站连接。

此外，Runner 必须能够连接到：

| 目标 | 端口 | 用途 |
|-------------|------|---------|
| `gitlab.com` | `443` | 在运行时从软件包仓库下载极狐GitLab Duo CLI 二进制文件 |
| `registry.gitlab.com` | `443` | 下载默认 Docker 镜像（除非使用[自定义镜像](../../../user/duo_agent_platform/flows/execution/images.md#change-the-default-docker-image)） |

如果您的组织无法允许访问 `gitlab.com`，您可以使用
已安装极狐GitLab Duo CLI 的[自定义 Docker 镜像](../../../user/duo_agent_platform/flows/execution/images.md#change-the-default-docker-image)。

> [!note]
> Runner 与极狐GitLab Duo Agent Platform 服务的连接通过
> 极狐GitLab 实例路由。Runner 不会直接连接到 `duo-workflow-svc.runway.gitlab.net`。
> 对 `duo-workflow-svc.runway.gitlab.net`的 `443` 端口的防火墙要求适用于
> 极狐GitLab 实例，而不是 Runner。您的 Runner 网络配置必须允许出站 HTTPS
> 流量到极狐GitLab 实例。

<a id="share-usage-data-with-gitlab"></a>

## 与极狐GitLab 共享使用数据

为帮助提升服务质量，您可以将极狐GitLab Duo Agent Platform 功能的使用数据共享给极狐GitLab。

当您开启数据收集后，极狐GitLab 会记录极狐GitLab Duo 功能使用情况的相关信息。此数据仅用于服务改进和调试，不用于训练 AI 模型。

有关收集哪些数据的更多信息，请参见 [Agent Platform 使用数据](../../../user/gitlab_duo/data_usage.md#agent-platform-usage-data)。

先决条件：

- 使用极狐GitLab 18.9.1 或更高版本

要开启扩展日志记录：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 选中**收集使用数据**复选框。
1. 选择**保存更改**。

<a id="data-usage-with-self-hosted-models"></a>

### 使用自部署模型时的数据使用

如果您使用自部署 AI 网关和自部署模型，详细日志会存储在您自己的基础设施上，不会与极狐GitLab 共享。要与极狐GitLab 共享数据，您必须将自部署 AI 网关配置为将跟踪数据发送到外部可观测性服务。

您可以使用 [Service Ping](../../settings/usage_statistics.md#service-ping)
将使用数据发送给极狐GitLab。此数据不同于[遥测数据](../../../user/gitlab_duo/data_usage.md#telemetry)。

<a id="run-a-health-check-for-gitlab-duo"></a>

## 运行极狐GitLab Duo 健康检查

{{< details >}}

- Status: 测试版

{{< /details >}}

您可以确定您的实例是否满足使用极狐GitLab Duo 的要求。健康检查完成后，会显示通过或失败结果以及问题类型。如果健康检查有任何测试失败，用户可能无法在您的实例中使用极狐GitLab Duo 功能。

这是一项[测试版](../../../policy/development_stages_support.md)功能。

先决条件：

- 您必须是管理员。

要运行健康检查：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 在右上角，选择**运行健康检查**。
1. 可选。在极狐GitLab 17.5 及更高版本中，健康检查完成后，您可以选择**下载报告**以保存健康检查结果的详细报告。

将执行以下测试：

| 测试                      | 描述 |
|---------------------------|-------------|
| AI 网关                | 仅限极狐GitLab Duo 自部署版本模型。测试 AI 网关 URL 是否配置为环境变量。使用 AI 网关的自部署模型部署需要此连接。 |
| 网络                   | 测试您的实例能否连接到 `customers.jihulab.com` 和 `cloud.jihulab.com`。<br><br>如果您的实例无法连接到任一目标，请确保您的防火墙或代理服务器设置[允许连接](#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)。 |
| 同步           | 测试您的订阅：<br>- 是否已使用激活码激活，并可与 `customers.jihulab.com` 同步。<br>- 是否具有正确的访问凭据。<br>- 是否最近已同步。如果尚未同步，或访问凭据缺失或已过期，您可以[手动同步](../../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)您的订阅数据。 |
| 代码建议          | 仅限极狐GitLab Duo 自部署版本模型。测试代码建议是否可用：<br>- 您的许可证是否包含对代码建议的访问权限。<br>- 您是否具有使用该功能所需的权限。 |
| 极狐GitLab Duo Agent Platform | 测试后端服务是否正常运行且可访问。Agent Platform 和极狐GitLab Duo Agentic Chat 等 Agent 功能需要此服务。<br><br>对于极狐GitLab Duo 自部署版本，在您[为极狐GitLab Duo Agent Platform 功能选择自部署模型](../../gitlab_duo_self_hosted/configure_duo_features.md#select-a-self-hosted-model-for-a-feature)之前，此测试不会通过。<br><br>还会验证以下内置任务流先决条件：<br>- 已启用实例级任务流执行设置。<br>- 已启用实例级内置任务流设置。<br>- 至少注册并连接了一个带有`gitlab--duo` 标签的活动实例 Runner，并使用与 Docker 兼容的执行器。|
| 系统交换           | 测试您的实例中是否可以使用代码建议。如果系统交换评估失败，用户可能无法使用极狐GitLab Duo 功能。 |
| 用量计费           | 测试您的实例能否连接到用量计费端点，包括 Customers Portal、AI 网关和 Duo Workflow Service。 |

对于 17.10 之前的极狐GitLab 实例，如果您在健康检查中遇到任何问题，请参见[故障排除页面](../../../user/gitlab_duo/troubleshooting.md)。

<a id="other-hosting-options"></a>

## 其他托管选项

默认情况下，极狐GitLab Duo 使用受支持的 AI 厂商语言模型，并通过由极狐GitLab 托管的基于云的 AI 网关发送数据。

如果您想托管自己的语言模型或 AI 网关：

- 您可以[使用极狐GitLab Duo 自部署版本托管 AI 网关并使用任何受支持的自部署模型](../../gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)。
  此选项可让您完全掌控您的数据和安全。
- 使用[混合配置](../../gitlab_duo_self_hosted/_index.md#hybrid-ai-gateway-and-model-configuration)，
  即您为部分功能托管自己的 AI 网关和模型，但将其他功能配置为使用极狐GitLab AI 网关和厂商模型。
