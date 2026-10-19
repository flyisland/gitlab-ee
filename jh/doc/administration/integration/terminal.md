---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Web 终端（已废弃）
description: 关于 Web 终端的信息。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 在极狐GitLab 私有化部署上，此功能默认不可用。要使其可用，管理员可以[启用功能标志](../feature_flags/_index.md) `certificate_based_clusters`。

- 详细了解未废弃的[可通过 Web IDE 访问的 Web 终端](../../user/project/web_ide/_index.md)。
- 详细了解未废弃的[可从运行中的 CI 作业访问的 Web 终端](../../ci/interactive_web_terminal/_index.md)。

---

随着 [Kubernetes 集成](../../user/infrastructure/clusters/_index.md)的引入，
极狐GitLab 可以存储并使用 Kubernetes 集群的凭据。
极狐GitLab 使用这些凭据为环境提供 [Web 终端](../../ci/environments/_index.md#web-terminals-deprecated)的访问权限。

> [!note]
> 只有对项目拥有至少[维护者角色](../../user/permissions.md)的用户才能访问 Web 终端。

<a id="how-web-terminals-work"></a>

## Web 终端的工作原理

关于 Web 终端架构及其工作原理的详细概述，请参见[此文档](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/development/workhorse/channel.md)。简要来说：

- 极狐GitLab 依赖用户提供自己的 Kubernetes 凭据，并在部署时
  为其创建的 Pod 添加适当的标签。
- 当用户进入某个环境的终端页面时，系统会向其提供一个
  JavaScript 应用，该应用会向极狐GitLab 建立 WebSocket 连接。
- WebSocket 由 [Workhorse](https://gitlab.com/gitlab-org/gitlab-workhorse) 处理，
  而不是由 Rails 应用服务器处理。
- Workhorse 向 Rails 查询连接详情和用户权限。Rails
  在后台使用 [Sidekiq](../sidekiq/sidekiq_troubleshooting.md) 向 Kubernetes 查询这些信息。
- Workhorse 充当用户浏览器与 Kubernetes
  API 之间的代理服务器，在两者之间传递 WebSocket 帧。
- Workhorse 会定期轮询 Rails，如果用户不再拥有访问终端的权限，
  或者连接详情已更改，则终止 WebSocket 连接。

<a id="security"></a>

## 安全

极狐GitLab 和[极狐GitLab Runner](https://gitlab.cn/docs/runner/) 会采取一些
预防措施，确保两者之间的交互式 Web 终端数据保持加密，并且一切都受到授权防护的保护。下文将对此进行更详细的说明。

- 除非配置了 [`[session_server]`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-session_server-section)，否则交互式 Web 终端将完全禁用。
- 每次 runner 启动时，它都会生成一个 `x509` 证书，用于 `wss`（Web Socket Secure）连接。
- 对于每个创建的作业，都会生成一个随机 URL，该 URL 会在作业结束时丢弃。此 URL 用于建立 Web Socket 连接。会话的 URL 格式为 `(IP|HOST):PORT/session/$SOME_HASH`，其中 `IP/HOST` 和 `PORT` 是配置的 [`listen_address`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-session_server-section)。
- 创建的每个会话 URL 都有一个需要发送的授权标头，用于建立 `wss` 连接。
- 会话 URL 不会以任何方式暴露给用户。极狐GitLab 在内部保存所有状态并进行相应的代理。

<a id="enabling-and-disabling-terminal-support"></a>

## 启用和禁用终端支持

> [!note]
> AWS Classic Load Balancer 不支持 Web Socket。
> 如果您希望 Web 终端正常工作，请使用 AWS Network Load Balancer。
> 阅读 [AWS Elastic Load Balancing 产品比较](https://aws.amazon.com/elasticloadbalancing/features/#compare)
> 了解更多信息。

由于 Web 终端使用 WebSocket，Workhorse 前面的每个 HTTP/HTTPS 反向代理
都必须配置为将 `Connection` 和 `Upgrade` 标头传递给链中的下一个代理。极狐GitLab 默认已配置为这样做。

但是，如果您在极狐GitLab 前面运行[负载均衡器](../load_balancer.md)，则可能需要对配置进行一些更改。以下指南记录了一些常用反向代理的必要步骤：

- [Apache](https://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html)
- [NGINX](https://www.f5.com/company/blog/nginx/websocket-nginx)
- [HAProxy](https://www.haproxy.com/blog/websockets-load-balancing-with-haproxy)
- [Varnish](https://varnish-cache.org/docs/4.1/users-guide/vcl-example-websockets.html)

Workhorse 不会让 WebSocket 请求通过到非 WebSocket 端点，因此
全局启用对这些标头的支持是安全的。如果您希望使用更窄的规则集，可以将其限制为以 `/terminal.ws` 结尾的 URL。这种方法仍可能导致一些误报。

如果您是自行编译安装的，则可能需要对配置进行一些更改。阅读[从源代码升级基础版和企业版](../../update/upgrading_from_source.md#new-configuration-for-nginx-or-apache)了解更多详情。

要在极狐GitLab 中禁用 Web 终端支持，请停止在链中的第一个 HTTP 反向代理中传递 `Connection` 和 `Upgrade` 逐跳标头。对于大多数用户来说，这是 Linux 软件包安装所捆绑的 NGINX 服务器。在这种情况下，您需要：

- 找到 `gitlab.rb` 文件中的 `nginx['proxy_set_headers']` 部分
- 确保整个块未被注释，然后注释掉或删除
  `Connection` 和 `Upgrade` 行。

对于您自己的负载均衡器，只需反向执行前面列出的指南所建议的配置更改即可。

当这些标头未传递时，Workhorse 会向尝试使用 Web 终端的用户返回 `400 Bad Request` 响应。相应地，他们会收到 `Connection failed` 消息。

<a id="limiting-websocket-connection-time"></a>

## 限制 WebSocket 连接时间

默认情况下，终端会话不会过期。

先决条件：

- 管理员访问权限。

要限制极狐GitLab 实例中的终端会话生存期：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **Web 终端**。
1. 设置 `max session time`。
