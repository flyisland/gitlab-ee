---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Ensure GitLab Duo is configured and operating correctly.
title: 在 极狐GitLab 私有化部署 实例上配置 GitLab Duo
gitlab_dedicated: no
---

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

为了确保 GitLab Duo 配置正确并且可以连接到 极狐GitLab：

- 必须确保出站和入站连接均可用。网络防火墙可能导致卡顿或延迟。
- 不得开启 [静默模式](../../administration/silent_mode/_index.md)。
- 必须[使用激活码激活你的实例](../../administration/license.md#activate-gitlab-ee)。不能使用[离线许可证](https://gitlab.cn/pricing/licensing-faq/cloud-licensing/#what-is-an-offline-cloud-license)或旧版许可证。
- 建议使用 极狐GitLab 17.2 及更高版本以获得最佳体验。早期版本可能仍能工作，但体验可能会降低。

默认情况下，处于试验或测试阶段的 GitLab Duo 功能是关闭的，并且[必须手动开启](../../user/gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)。

<a id="allow-outbound-connections-from-the-gitlab-instance"></a>

## 允许 极狐GitLab 实例发起出站连接

检查你的出站和入站设置：

- 你的防火墙和 HTTP/S 代理服务器必须允许使用 `https://` 在端口 `443` 出站连接到 `cloud.jihulab.com` 和 `customers.jihulab.com`。
- 若使用 HTTP/S 代理，`gitLab_workhorse` 和 `gitLab_rails` 都必须设置必要的[网页代理环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.html)。
- 在多节点 极狐GitLab 安装中，请在所有 **Rails** 和 **Sidekiq** 节点上配置 HTTP/S 代理。
- 极狐GitLab 应用节点必须能够连接到 [GitLab Duo 工作流服务](https://duo-workflow.jihulab.com)。

<a id="allow-inbound-connections-from-clients-to-the-gitlab-instance"></a>

## 允许客户端到 极狐GitLab 实例的入站连接

- 极狐GitLab 实例必须允许来自 极狐GitLab Web 前端 的入站连接，端口 443，协议 `https://` 和 `wss://`。
- 同时必须允许 `HTTP2` 和 `'upgrade'` 头，因为 GitLab Duo 同时使用 REST 和 WebSocket。
- 检查针对到 `wss://jihulab.example.com/-/cable` 以及其他 `.com` 域的 WebSocket（`wss://`）流量限制。对 `wss://` 流量的网络策略限制可能会导致某些 GitLab Duo Chat 服务出现问题，建议更新策略以允许这些服务。
- 如果你使用诸如 Apache 的反向代理，可能会在日志中看到 GitLab Duo Chat 连接问题，例如 **WebSocket 连接到 .... 失败**。

为解决该问题，尝试编辑你的 Apache 代理设置：

```apache
# 启用 WebSocket 反向代理
# 需要启用 proxy_wstunnel
  RewriteCond %{HTTP:Upgrade} websocket [NC]
  RewriteCond %{HTTP:Connection} upgrade [NC]
  RewriteRule ^/?(.*) "ws://127.0.0.1:8181/$1" [P,L]
```

<a id="run-a-health-check-for-gitlab-duo"></a>

## 运行 GitLab Duo 健康检查

{{< details >}}

- 状态：测试版

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 17.3 中引入。
- 在 极狐GitLab 17.5 中新增下载健康检查报告。

{{< /history >}}

你可以判断你的实例是否满足使用 GitLab Duo 的要求。健康检查完成后会显示通过或失败的结果以及问题类型。如果健康检查中的任何测试失败，用户可能无法在你的实例中使用 GitLab Duo 功能。

这是一个[测试版](../../policy/development_stages_support.md)功能。

前提条件：

- 必须是管理员。

运行健康检查：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **GitLab Duo**。
1. 在右上角，选择 **运行健康检查**。
1. 可选。在 极狐GitLab 17.5 及更高版本中，健康检查完成后，你可以选择 **下载报告** 以保存健康检查结果的详细报告。

会执行以下测试：

| 测试     | 说明                                                                                                                                                                                                                                                                               |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 网络     | 测试你的实例是否能连接到 `customers.jihulab.com` 和 `cloud.jihulab.com`。<br><br>如果你的实例无法连接到其中任一目的地，请确保你的防火墙或代理服务器设置[允许连接](setup.md)。                                                                                                      |
| 同步     | 测试你的订阅是否：<br>- 已使用激活码激活，并能与 `customers.jihulab.com` 同步。<br>- 拥有正确的访问凭据。<br>- 最近完成了同步。如果尚未同步或访问凭据缺失或过期，你可以[手动同步](../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)你的订阅数据。 |
| 系统交换 | 测试你的实例是否可以使用代码建议。如果系统交换评估失败，用户可能无法使用 GitLab Duo 功能。                                                                                                                                                                                         |

对于版本早于 17.10 的 极狐GitLab 实例，如果你在运行健康检查时遇到任何问题，请参阅[故障排查页面](../../user/gitlab_duo/troubleshooting.md)。

<a id="other-hosting-options"></a>

## 其它托管选项

默认情况下，GitLab Duo 使用受支持的 国内 SOTA 模型，并通过由 极狐GitLab 托管的云端 AI Gateway传输数据。

如果你希望托管自己的语言模型或 AI Gateway：

- 你可以[使用 自部署模型的 GitLab Duo 来托管 AI Gateway并使用任意受支持的自部署模型](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)。该选项可让你完全控制数据和安全性。
- 使用[混合配置](../../administration/gitlab_duo_self_hosted/_index.md#hybrid-ai-gateway-and-model-configuration)，即为部分功能托管你自己的 AI Gateway和模型，而将其它功能配置为使用 极狐GitLab AI Gateway和 国内 SOTA 模型。

<a id="hide-sidebar-widget-that-shows-gitlab-duo-core-availability"></a>

## 隐藏显示 GitLab Duo Core 可用性的侧边栏组件

在左侧边栏靠近底部，有一个组件显示 GitLab Duo Core 的可用性。要隐藏该组件，禁用 `duo_agent_platform_widget_self_managed` 功能标志。

![显示 GitLab Duo Core 可用性的组件](img/widget_v18_5.png)
