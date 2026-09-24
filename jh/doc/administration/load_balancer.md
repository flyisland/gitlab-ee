---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 多节点极狐GitLab 的负载均衡器
description: Use a load balancer with multi-node a multi-node instance.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在多节点极狐GitLab 配置中，你需要一个负载均衡器来将流量路由到应用服务器。具体选用哪种负载均衡器或如何配置超出了极狐GitLab 文档的范围。我们希望，如果你正在管理像极狐GitLab 这样的高可用系统，你应该已经有一个熟悉的负载均衡器。例如包括 HAProxy（开源）、F5 Big-IP LTM 和 Citrix NetScaler。本文档列出了极狐GitLab 需要使用的端口和协议。

## SSL

在多节点环境中你希望如何处理 SSL？有几种不同的选择：

- 每个应用节点终止 SSL
- 负载均衡器终止 SSL，负载均衡器和应用节点之间的通信不安全
- 负载均衡器终止 SSL，负载均衡器和应用节点之间的通信保持安全

### 应用节点终止 SSL

将负载均衡器配置为以 `TCP` 协议而非 `HTTP(S)` 协议转发 443 端口的连接。这样连接会原封不动地传递到应用节点的 NGINX 服务。NGINX 拥有 SSL 证书并监听 443 端口。

有关管理 SSL 证书和配置 NGINX 的详细信息，请参见 [HTTPS 文档](https://gitlab.cn/docs/omnibus/settings/ssl/)。

### 负载均衡器终止 SSL 且没有后端 SSL

将负载均衡器配置为使用 `HTTP(S)` 协议而非 `TCP` 协议。负载均衡器负责管理 SSL 证书并终止 SSL。

由于负载均衡器与极狐GitLab 之间的通信不安全，因此需要一些额外的配置。详细信息请参见[代理 SSL 文档](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-a-reverse-proxy-or-load-balancer-ssl-termination)。

### 负载均衡器终止 SSL 且包含后端 SSL

将负载均衡器配置为使用 `HTTP(S)` 协议而非 `TCP` 协议。负载均衡器负责管理最终用户所见的 SSL 证书。

在这种情况下，负载均衡器和 NGINX 之间的流量是安全的。因为整个连接都是安全的，所以无需为代理 SSL 添加配置。但是，必须为极狐GitLab 添加配置以设置 SSL 证书。有关管理 SSL 证书和配置 NGINX 的详细信息，请参见 [HTTPS 文档](https://gitlab.cn/docs/omnibus/settings/ssl/)。

## 端口

### 基本端口

| 负载均衡器端口 | 后端端口 | 协议                  |
| ------- | ------------ | ------------------------ |
| 80      | 80           | HTTP（*1*）               |
| 443     | 443          | TCP 或 HTTPS（*1*）（*2*） |
| 22      | 22           | TCP                      |

- （*1*）：对于[极狐GitLab Duo 非 Agentic 聊天](../user/gitlab_duo_chat/_index.md)、议题和合并请求中的实时标签更新以及 [Web 终端](../ci/environments/_index.md#web-terminals-deprecated)等功能，你的负载均衡器必须支持 WebSocket 连接。不支持 WebSocket 的负载均衡器（例如 AWS Classic Load Balancer）在这些功能上与极狐GitLab 不兼容。当使用 HTTP 或 HTTPS 代理时，必须将负载均衡器配置为将 `Connection` 和 `Upgrade` 逐跳头转发到后端服务器。这指的是 HTTP 头转发，而非直接服务器返回（DSR）模式。
- （*2*）：当 443 端口使用 HTTPS 协议时，你必须在负载均衡器上添加 SSL 证书。如果希望改为在极狐GitLab 应用服务器上终止 SSL，请使用 TCP 协议。

### 极狐GitLab Pages 端口

如果你使用自定义域支持的极狐GitLab Pages，则需要一些额外的端口配置。
极狐GitLab Pages 需要一个独立的虚拟 IP 地址。将 DNS 配置为将 `/etc/gitlab/gitlab.rb` 中的 `pages_external_url` 指向新的虚拟 IP 地址。更多信息请参见[极狐GitLab Pages 文档](pages/_index.md)。

| 负载均衡器端口 | 后端端口  | 协议  |
| ------- | ------------- | --------- |
| 80      | 视情况而定（*1*）  | HTTP      |
| 443     | 视情况而定（*1*）  | TCP（*2*） |

- （*1*）：极狐GitLab Pages 的后端端口取决于 `gitlab_pages['external_http']` 和 `gitlab_pages['external_https']` 设置。更多细节请参见[极狐GitLab Pages 文档](pages/_index.md)。
- （*2*）：极狐GitLab Pages 的 443 端口应始终使用 TCP 协议。用户可以配置带有自定义 SSL 的自定义域，如果在负载均衡器上终止 SSL，这将无法实现。

### 备用 SSH 端口

一些组织的安全策略禁止开放 SSH 22 端口。在这种情况下，配置一个备用 SSH 主机名可能很有帮助，它允许用户通过 443 端口使用 SSH。与前面记录的其他极狐GitLab HTTP 配置相比，备用 SSH 主机名需要一个独立的虚拟 IP 地址。

为备用 SSH 主机名配置 DNS，例如 `altssh.gitlab.example.com`。

| 负载均衡器端口 | 后端端口 | 协议 |
| ------- | ------------ | -------- |
| 443     | 22           | TCP      |

## 就绪检查

强烈建议多节点部署配置负载均衡器使用[就绪检查](monitoring/health_check.md#readiness)，以确保节点在接收流量前已准备好处理请求。当使用 Puma 时这一点尤其重要，因为在重启期间会有一个短暂的时间段 Puma 不接受请求。

> [!warning]
> 在极狐GitLab 15.4 至 15.8 版本中，结合就绪检查使用 `all=1` 参数可能会导致 [Praefect 内存使用量增加](https://gitlab.com/gitlab-org/gitaly/-/issues/4751)并引发内存错误。

## 故障排除

### 通过负载均衡器返回 `408` HTTP 状态码的就绪检查

如果你在极狐GitLab 15.0 或更高版本中使用 [AWS Classic Load Balancer](https://docs.aws.amazon.com/en_en/elasticloadbalancing/latest/classic/elb-ssl-security-policy.html#ssl-ciphers)，你必须在 NGINX 中启用 `AES256-GCM-SHA384` 密码套件。有关更多信息，请参见[默认情况下 NGINX 不再允许 AES256-GCM-SHA384 SSL 密码套件](../update/versions/gitlab_15_changes.md#1500)。

极狐GitLab 版本的默认密码套件可在 [`files/gitlab-cookbooks/gitlab/attributes/default.rb`](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/master/files/gitlab-cookbooks/gitlab/attributes/default.rb) 文件中查看，选择与你目标极狐GitLab 版本对应的 Git 标签（例如 `15.0.5+ee.0`）。如果你的负载均衡器有要求，你可以为 NGINX 定义[自定义 SSL 密码套件](https://gitlab.cn/docs/omnibus/settings/ssl/#use-custom-ssl-ciphers)。

### 某些页面和链接被下载而不是在浏览器中渲染

一些极狐GitLab 功能需要使用 WebSocket。在某些场景下，如果负载均衡器未启用 WebSocket 支持，你可能会遇到某些链接或页面被下载而不是在浏览器中渲染的情况。下载的文件内容可能类似于以下内容：

```plaintext
一个或多个保留位被置位：reserved1 = 1, reserved2 = 0, reserved3 = 0
```

你的负载均衡器必须能够支持 HTTP WebSocket 请求。如果链接以这种方式被下载，请检查负载均衡器配置并确保已启用 HTTP WebSocket 请求。