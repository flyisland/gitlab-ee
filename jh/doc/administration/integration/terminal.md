---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Web 终端（已弃用）
description: Information about Web terminals.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 此功能在 极狐GitLab 14.5 中已弃用。
- 在 极狐GitLab 15.0 中，私有化部署上已禁用。

{{< /history >}}

> [!flag]
> 在私有化部署上，默认情况下此功能不可用。要使其可用，管理员可以[启用功能标志](../feature_flags/_index.md)，名为 `certificate_based_clusters`。

- 阅读更多关于未弃用的[通过 Web IDE 访问的 Web 终端](../../user/project/web_ide/_index.md)。
- 阅读更多关于未弃用的[从运行中的 CI 作业访问的 Web 终端](../../ci/interactive_web_terminal/_index.md)。

---

随着 [Kubernetes 集成](../../user/infrastructure/clusters/_index.md) 的引入，极狐GitLab 可以存储和使用 Kubernetes 集群的凭证。极狐GitLab 使用这些凭证为环境提供对 [Web 终端](../../ci/environments/_index.md#web-terminals-deprecated) 的访问。

> [!note]
> 只有至少具有项目[维护者角色](../../user/permissions.md)的用户才能访问 Web 终端。

<a id="how-web-terminals-work"></a>

Web 终端的工作原理

可以在[本文档](https://jihulab.com/gitlab-cn/gitlab-workhorse/blob/master/doc/channel.md)中找到 Web 终端架构及其工作方式的详细概述。简要来说：

- 极狐GitLab 依赖用户提供自己的 Kubernetes 凭证，并在部署时适当地标记他们创建的 Pod。
- 当用户进入环境的终端页面时，会收到一个 JavaScript 应用程序，该应用程序会打开一个 WebSocket 连接回极狐GitLab。
- WebSocket 在 [Workhorse](https://jihulab.com/gitlab-cn/gitlab-workhorse) 中处理，而不是在 Rails 应用服务器中。
- Workhorse 向 Rails 查询连接详情和用户权限。Rails 在后台使用 [Sidekiq](../sidekiq/sidekiq_troubleshooting.md) 向 Kubernetes 查询这些信息。
- Workhorse 充当用户浏览器和 Kubernetes API 之间的代理服务器，在两者之间传递 WebSocket 帧。
- Workhorse 定期轮询 Rails，如果用户不再有权访问终端，或者连接详情发生变化，则终止 WebSocket 连接。

<a id="security"></a>

安全性

极狐GitLab 和 [极狐GitLab Runner](https://gitlab.cn/docs/runner) 采取了一些预防措施，以确保交互式 Web 终端数据在它们之间加密，并通过授权守卫保护一切。下面将更详细地描述。

- 交互式 Web 终端完全禁用，除非配置了 [`[session_server]`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-session_server-section)。
- 每次 runner 启动时，它都会生成一个 `x509` 证书，用于 `wss`（Web Socket Secure）连接。
- 对于每个创建的作业，都会生成一个随机 URL，该 URL 在作业结束时被丢弃。此 URL 用于建立 WebSocket 连接。会话的 URL 格式为 `(IP|HOST):PORT/session/$SOME_HASH`，其中 `IP/HOST` 和 `PORT` 是配置的 [`listen_address`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-session_server-section)。
- 每个创建的会话 URL 都有一个需要发送的授权头，以建立 `wss` 连接。
- 会话 URL 不会以任何方式暴露给用户。极狐GitLab 内部保存所有状态并相应地进行代理。

<a id="enabling-and-disabling-terminal-support"></a>

启用和禁用终端支持

由于 Web 终端使用 WebSocket，Workhorse 前面的每个 HTTP/HTTPS 反向代理都必须配置为将 `Connection` 和 `Upgrade` 头传递到链中的下一个。极狐GitLab 默认配置为这样做。

然而，如果你在极狐GitLab 前面运行[负载均衡器](../load_balancer.md)，你可能需要对配置进行一些更改。这些指南记录了针对一些流行反向代理的必要步骤：

- [Apache](https://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html)
- [NGINX](https://www.f5.com/company/blog/nginx/websocket-nginx/)
- [HAProxy](https://www.haproxy.com/blog/websockets-load-balancing-with-haproxy)
- [Varnish](https://varnish-cache.org/docs/4.1/users-guide/vcl-example-websockets.html)

Workhorse 不会让 WebSocket 请求通过非 WebSocket 端点，因此全局启用对这些头的支持是安全的。如果你喜欢更窄的规则集，可以将其限制为以 `/terminal.ws` 结尾的 URL。这种方法可能仍会产生一些误报。

如果你自行编译了安装，可能需要对配置进行一些更改。阅读[从源代码升级基础版和企业版](../../update/upgrading_from_source.md#new-configuration-for-nginx-or-apache)以获取更多详细信息。

要在极狐GitLab 中禁用 Web 终端支持，请停止在链中的第一个 HTTP 反向代理中传递 `Connection` 和 `Upgrade` 逐跳头。对于大多数用户，这是与 Linux 软件包安装捆绑的 NGINX 服务器。在这种情况下，你需要：

- 找到 `gitlab.rb` 文件中的 `nginx['proxy_set_headers']` 部分
- 确保整个块未被注释，然后注释掉或删除 `Connection` 和 `Upgrade` 行。

对于你自己的负载均衡器，只需逆转前面列出的指南推荐的配置更改。

当这些头未传递时，Workhorse 会向尝试使用 Web 终端的用户返回 `400 Bad Request` 响应。反过来，他们会收到 `Connection failed` 消息。

<a id="limiting-websocket-connection-time"></a>

限制 WebSocket 连接时间

默认情况下，终端会话不会过期。

前提条件：

- 管理员访问权限。

要限制极狐GitLab 实例中的终端会话生命周期：

1. 在右上角，选择 **Admin**。
1. 在左侧边栏中，选择 **Settings** > **General**。
1. 展开 **Web terminal**。
1. 设置 `max session time`。