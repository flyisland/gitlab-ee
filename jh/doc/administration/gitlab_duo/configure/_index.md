---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure GitLab Duo for your GitLab instance.
title: 配置极狐GitLab Duo
---

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

极狐GitLab Duo 是一个 AI 原生助手，可在软件开发生命周期中为您提供帮助。

您可以将极狐GitLab Duo 配置为使用：

- 云端 AI 网关（默认）：由 GitLab 托管的 AI 网关，包含供应商语言模型。
- 自部署模型：您自己的 AI 网关和语言模型，可完全掌控数据与安全。
- 混合配置：部分功能使用自部署模型，其他功能使用云端模型。

<a id="prerequisites"></a>

## 先决条件

- [关闭了沉默模式](../../silent_mode/_index.md#turn-off-silent-mode)。
- [您的实例已使用激活码激活](../../license.md#activate-gitlab-ee)。
  - 您不能使用许可证密钥。
  - 您不能通过离线许可证使用极狐GitLab Duo，但[自部署极狐GitLab Duo](../../gitlab_duo_self_hosted/_index.md) 除外。

<a id="allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo"></a>

## 允许从极狐GitLab 实例到极狐GitLab Duo 的出站连接

- 极狐GitLab 应用节点必须通过 HTTP/2 连接到极狐GitLab Duo 工作流（地址为 `https://duo-workflow.jihulab.com`）。应用与服务通过 gRPC 通信。
- 对于极狐GitLab Duo Agent Platform 功能，您的防火墙和 HTTP/S 代理服务器必须允许通过 `https://` 和 HTTP/2 流量支持，向端口 `443` 的 `duo-workflow.jihulab.com` 发起出站连接。

<a id="allow-inbound-connections-from-clients-to-the-gitlab-instance"></a>

## 允许从客户端到极狐GitLab 实例的入站连接

您的极狐GitLab 实例必须允许来自 IDE 客户端的入站连接。

1. 允许带有以下标头的 WebSocket 协议升级请求：
   - `Connection: upgrade`
   - `Upgrade: websocket`
   - `HTTP/2` 协议支持
   - 标准 WebSocket 安全标头：`Sec-WebSocket-*`
1. 启用 `wss://`（WebSocket Secure）协议支持。
1. 添加要允许的特定端点：
   - 主端点：`wss://<customer-instance>/-/cable`
   - 确保 `HTTP/2` 协议不会被降级为 `HTTP/1.1`。
   - 端口：`443`（HTTPS/WSS）

如果您遇到问题：

- 检查是否存在对 `wss://gitlab.example.com/-/cable` 及其他 `.com` 域名的 WebSocket 流量限制。
- 如果使用了 Apache 等反向代理，可能会在日志中看到极狐GitLab Duo Chat 连接问题，例如 **WebSocket 连接到 .... 失败**。

要解决此问题，请编辑代理设置：

```apache
# Enable WebSocket reverse Proxy
# Needs proxy_wstunnel enabled
  RewriteCond %{HTTP:Upgrade} websocket [NC]
  RewriteCond %{HTTP:Connection} upgrade [NC]
  RewriteRule ^/?(.*) "ws://127.0.0.1:8181/$1" [P,L]
```

<a id="allow-connections-from-the-runner"></a>

## 允许从 runner 连接

对于使用 runner 的极狐GitLab Duo Agent Platform 功能（例如流），runner 必须能够连接到极狐GitLab 实例。

必须将相同的[从客户端到极狐GitLab 实例的入站连接](#allow-inbound-connections-from-clients-to-the-gitlab-instance)作为从 runner 到极狐GitLab 实例的出站连接予以放行。

此外，runner 必须能够连接到以下目标：

| 目标 | 端口 | 用途 |
|-------------|------|---------|
| `registry.npmjs.org` | `443` | 在运行时下载 Duo CLI 软件包 |
| `registry.gitlab.com` | `443` | 下载默认 Docker 镜像（除非使用[自定义镜像](../../../user/duo_agent_platform/flows/execution.md#change-the-default-docker-image)） |

如果您的组织无法访问公共 npm 仓库，可以使用已安装必要依赖的[自定义 Docker 镜像](../../../user/duo_agent_platform/flows/execution.md#change-the-default-docker-image)。

<a id="share-usage-data-with-gitlab"></a>

## 与极狐GitLab 共享使用数据

{{< history >}}

- 在极狐GitLab 18.9.1 中引入。

{{< /history >}}

为了帮助提升服务质量，您可以将极狐GitLab Duo Agent Platform 功能的使用数据共享给极狐GitLab。

开启数据收集后，极狐GitLab 会记录极狐GitLab Duo 功能的使用信息。这些数据仅用于服务改进和调试，不会用于 AI 模型训练。

有关收集哪些数据的详细信息，请参阅 [Agent Platform 使用数据](../../../user/gitlab_duo/data_usage.md#agent-platform-usage-data)。

先决条件：

- 拥有极狐GitLab 18.9.1 或更高版本

要开启扩展日志记录：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 选中 **收集使用数据** 复选框。
1. 选择 **保存更改**。

<a id="data-usage-with-self-hosted-models"></a>

### 自部署模型的数据使用

如果您使用自托管 AI 网关和自部署模型，详细日志会存储在您的基础设施上，不会与极狐GitLab 共享。要与极狐GitLab 共享数据，您必须配置自托管 AI 网关，使其将追踪信息发送到外部可观测性服务。

您可以使用 [Service Ping](../../settings/usage_statistics.md#service-ping) 将使用数据发送给极狐GitLab。此数据与[遥测数据](../../../user/gitlab_duo/data_usage.md#telemetry)不同。

<a id="run-a-health-check-for-gitlab-duo"></a>

## 运行极狐GitLab Duo 健康检查

{{< details >}}

- 状态：测试版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.3 中引入。
- 在极狐GitLab 17.5 中添加了下载健康检查报告的功能。

{{< /history >}}

您可以确定实例是否满足使用极狐GitLab Duo 的要求。健康检查完成后，会显示通过或失败结果以及问题类型。如果健康检查未通过任何一项测试，您实例中的用户可能无法使用极狐GitLab Duo 功能。

这是一个[测试版](../../../policy/development_stages_support.md)功能。

先决条件：

- 您必须是管理员。

要运行健康检查：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在右上角，选择 **运行健康检查**。
1. 可选。在极狐GitLab 17.5 及更高版本中，健康检查完成后，您可以选择 **下载报告** 以保存详细的结果报告。

将运行以下测试：

| 测试 | 描述 |
|---------------------------|-------------|
| AI 网关 | 仅适用于自部署模型的极狐GitLab Duo。测试 AI 网关 URL 是否已配置为环境变量。对于使用 AI 网关的自部署模型部署，此连接是必需的。 |
| 网络 | 测试您的实例能否连接到 `customers.jihulab.com` 和 `cloud.jihulab.com`。<br><br>如果您的实例无法连接到任一目标，请确保防火墙或代理服务器设置[允许连接](#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)。 |
| 同步 | 测试您的订阅是否：<br>- 已使用激活码激活，并可与 `customers.jihulab.com` 同步。<br>- 拥有正确的访问凭据。<br>- 最近已同步过。如果没有同步，或者访问凭据缺失或已过期，您可以[手动同步](../../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)订阅数据。 |
| 代码建议 | 仅适用于自部署模型的极狐GitLab Duo。测试代码建议是否可用：<br>- 您的许可证包含代码建议的访问权限。<br>- 您拥有使用该功能的必要权限。 |
| 极狐GitLab Duo Agent Platform | 测试后端服务是否正常运行且可访问。Agent Platform 和极狐GitLab Duo Agentic Chat 等 Agent 功能需要此服务。 |
| 系统交换 | 测试您的实例中是否可以使用代码建议。如果系统交换评估失败，用户可能无法使用极狐GitLab Duo 功能。 |

对于版本早于 17.10 的极狐GitLab 实例，如果您遇到任何健康检查问题，请参阅[故障排查页面](../../../user/gitlab_duo/troubleshooting.md)。

<a id="other-hosting-options"></a>

## 其他托管选项

默认情况下，极狐GitLab Duo 使用受支持的 AI 供应商语言模型，并通过 GitLab 托管的云端 AI 网关发送数据。

如果您希望托管自己的语言模型或 AI 网关：

- 您可以[使用自部署极狐GitLab Duo 来托管 AI 网关，并使用任何受支持的自部署模型](../../gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)。此选项可让您完全掌控数据和安全性。
- 使用[混合配置](../../gitlab_duo_self_hosted/_index.md#hybrid-ai-gateway-and-model-configuration)，您可以为部分功能托管自己的 AI 网关和模型，同时将其他功能配置为使用极狐GitLab AI 网关和供应商模型。