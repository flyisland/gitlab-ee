---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 多节点极狐GitLab 的负载均衡器
description: 在多节点实例中使用负载均衡器。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在多节点极狐GitLab 配置中，您需要一个负载均衡器将流量路由到应用服务器。具体使用哪个负载均衡器或确切的配置不在极狐GitLab 文档的讨论范围内。如果您正在管理像极狐GitLab 这样的高可用系统，我们希望您已经有首选的负载均衡器。一些示例包括 HAProxy（开源）、F5 Big-IP LTM 和 Citrix NetScaler。本文档概述了极狐GitLab 应使用的端口和协议。

<a id="ssl"></a>

## SSL

您希望如何在多节点环境中处理 SSL？有几种不同的选项：

- 每个应用节点终止 SSL
- 负载均衡器终止 SSL，且负载均衡器与应用节点之间的通信不安全
- 负载均衡器终止 SSL，且负载均衡器与应用节点之间的通信安全

<a id="application-nodes-terminate-ssl"></a>

### 应用节点终止 SSL

将负载均衡器配置为以“TCP”而非“HTTP(S)”协议传递端口 443 上的连接。这样会将连接原样传递到应用节点的 NGINX 服务。NGINX 持有 SSL 证书并监听端口 443。

有关管理 SSL 证书和配置 NGINX 的详细信息，请参阅 [HTTPS 文档](https://gitlab.cn/docs/omnibus/settings/ssl/)。

<a id="load-balancers-terminate-ssl-without-backend-ssl"></a>

### 负载均衡器终止 SSL，后端不使用 SSL

将负载均衡器配置为使用 `HTTP(S)` 协议而非 `TCP`。负载均衡器负责管理 SSL 证书并终止 SSL。

由于负载均衡器与极狐GitLab 之间的通信不安全，因此需要一些额外的配置。有关详细信息，请参阅[代理 SSL 文档](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-a-reverse-proxy-or-load-balancer-ssl-termination)。

<a id="load-balancers-terminate-ssl-with-backend-ssl"></a>

### 负载均衡器终止 SSL，后端使用 SSL

将负载均衡器配置为使用 `HTTP(S)` 协议而非 `TCP`。负载均衡器负责管理最终用户看到的 SSL 证书。

在此场景中，负载均衡器与 NGINX 之间的流量是安全的。由于连接全程安全，因此无需为代理 SSL 添加配置。但是，必须为极狐GitLab 添加配置以设置 SSL 证书。有关管理 SSL 证书和配置 NGINX 的详细信息，请参阅 [HTTPS 文档](https://gitlab.cn/docs/omnibus/settings/ssl/)。

<a id="ports"></a>

## 端口

<a id="basic-ports"></a>

### 基本端口

| 负载均衡器端口 | 后端端口 | 协议                     |
| ------- | ------------ | ------------------------ |
| 80      | 80           | HTTP (*1*)               |
| 443     | 443          | TCP 或 HTTPS (*1*) (*2*) |
| 22      | 22           | TCP                      |

- (*1*)：您的负载均衡器必须支持 WebSocket 连接，以支持 [GitLab Duo Non-Agentic Chat](../user/gitlab_duo_chat/_index.md)、议题和合并请求中的实时标记更新以及 [Web 终端](../ci/environments/_index.md#web-terminals-deprecated)等功能。不支持 WebSocket 的负载均衡器（例如 AWS Classic Load Balancer）无法与极狐GitLab 配合使用这些功能。使用 HTTP 或 HTTPS 代理时，您的负载均衡器必须配置为将 `Connection` 和 `Upgrade` 逐跳请求头转发到后端服务器。这里指的是 HTTP 请求头转发，而不是直接服务器返回（DSR）模式。
- (*2*)：对端口 443 使用 HTTPS 协议时，您必须为负载均衡器添加 SSL 证书。如果您希望在极狐GitLab 应用服务器上终止 SSL，请改用 TCP 协议。

<a id="gitlab-pages-ports"></a>

### GitLab Pages 端口

如果您使用支持自定义域名的 GitLab Pages，则需要一些额外的端口配置。GitLab Pages 需要单独的虚拟 IP 地址。配置 DNS，将 `/etc/gitlab/gitlab.rb`中的 `pages_external_url` 指向新的虚拟 IP 地址。有关更多信息，请参阅 [GitLab Pages 文档](pages/_index.md)。

| 负载均衡器端口 | 后端端口  | 协议  |
| ------- | ------------- | --------- |
| 80      | 视情况而定 (*1*)  | HTTP      |
| 443     | 视情况而定 (*1*)  | TCP (*2*) |

- (*1*)：GitLab Pages 的后端端口取决于 `gitlab_pages['external_http']` 和 `gitlab_pages['external_https']` 设置。有关更多详细信息，请参阅 [GitLab Pages 文档](pages/_index.md)。
- (*2*)：GitLab Pages 的端口 443 应始终使用 TCP 协议。用户可以使用自定义 SSL 配置自定义域名，如果在负载均衡器上终止 SSL，则无法做到这一点。

<a id="alternate-ssh-port"></a>

### 备用 SSH 端口

一些组织的策略禁止打开 SSH 端口 22。在这种情况下，配置一个备用 SSH 主机名可能会有所帮助，它允许用户在端口 443 上使用 SSH。与前面记录的其他极狐GitLab HTTP 配置相比，备用 SSH 主机名需要一个新的虚拟 IP 地址。

为备用 SSH 主机名（例如 `altssh.gitlab.example.com`）配置 DNS。

| 负载均衡器端口 | 后端端口 | 协议 |
| ------- | ------------ | -------- |
| 443     | 22           | TCP      |

<a id="readiness-check"></a>

## 就绪检查

强烈建议多节点部署将负载均衡器配置为使用[就绪检查](monitoring/health_check.md#readiness)，以确保节点在接收流量之前已准备好接受流量。在使用 Puma 时这一点尤为重要，因为在重启期间有一小段时间 Puma 不接受请求。

> [!warning]
> 在极狐GitLab 15.4 至 15.8 版本中，将 `all=1` 参数与就绪检查一起使用可能会导致 [Praefect 内存使用量增加](https://gitlab.com/gitlab-org/gitaly/-/issues/4751)，并引发内存错误。

<a id="troubleshooting"></a>

## 故障排除

<a id="the-health-check-is-returning-a-408-http-code-via-the-load-balancer"></a>

### 健康检查通过负载均衡器返回 `408` HTTP 状态码

如果您使用 [AWS Classic Load Balancer](https://docs.aws.amazon.com/en_en/elasticloadbalancing/latest/classic/elb-ssl-security-policy.html#ssl-ciphers)，则必须在 NGINX 中启用 `AES256-GCM-SHA384` 密码算法。有关更多信息，请参阅 [NGINX 默认不再允许 AES256-GCM-SHA384 SSL 密码算法](../update/versions/gitlab_15_changes.md#1500)。

极狐GitLab 版本的默认密码算法可在 [`files/gitlab-cookbooks/gitlab/attributes/default.rb`](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/master/files/gitlab-cookbooks/gitlab/attributes/default.rb) 文件中查看，选择与目标极狐GitLab 版本对应的 Git 标签（例如 `15.0.5+ee.0`）。如果您的负载均衡器有要求，您可以为 NGINX 定义[自定义 SSL 密码算法](https://gitlab.cn/docs/omnibus/settings/ssl/#use-custom-ssl-ciphers)。

<a id="some-pages-and-links-are-downloaded-instead-of-rendered-in-the-browser"></a>

### 某些页面和链接被下载而不是在浏览器中呈现

某些极狐GitLab 功能需要使用 WebSocket。在某些负载均衡器未启用 WebSocket 支持的场景中，您可能会遇到某些链接或页面被下载而不是在浏览器中呈现的情况。下载的文件可能包含类似以下内容：

```plaintext
One or more reserved bits are on: reserved1 = 1, reserved2 = 0, reserved3 = 0
```

您的负载均衡器必须能够支持 HTTP WebSocket 请求。如果链接以这种方式被下载，请检查您的负载均衡器配置，并确保已启用 HTTP WebSocket 请求。
