---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安装极狐GitLab Relay (KAS)
description: 管理极狐GitLab Relay (KAS)。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab Relay (KAS) 是随极狐GitLab 一起安装的组件。它作为中心通信中继，用于极狐GitLab 与外部系统之间的双向 gRPC 通信，包括：

- Runner：使用[作业路由器](../../ci/runners/job_router/_index.md)和 [Runner 控制器](../../ci/runners/job_router/runner_controllers.md)所必需。
- Kubernetes 集群：使用 [极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md) 所必需。

KAS 以前称为 Kubernetes Agent Server。更名是为了反映其角色已超越 Kubernetes。

极狐GitLab Relay (KAS) 已安装并可在 JihuLab.com 上通过 `grpcs://kas.jihulab.com` 使用。
WebSocket 地址 `wss://kas.jihulab.com` 也可用。
如果您使用极狐GitLab 私有化部署，默认情况下极狐GitLab Relay (KAS) 已安装并可用。

<a id="installation-options"></a>

## 安装选项

作为极狐GitLab 管理员，您可以控制极狐GitLab Relay (KAS) 的安装：

- 对于 [Linux 软件包安装](#for-linux-package-installations)。
- 对于 [GitLab Helm chart 安装](#for-gitlab-helm-chart)。

<a id="for-linux-package-installations"></a>

### 对于 Linux 软件包安装

Linux 软件包安装的极狐GitLab Relay (KAS) 可以在单个节点上启用，也可以同时在多个节点上启用。
默认情况下，极狐GitLab Relay (KAS) 已启用。当 `external_url` 使用 HTTPS 且没有相对 URL 根路径，并且内置 NGINX 使用 HTTP/2 终止 TLS 时，Agent 通过 `grpcs://gitlab.example.com` 连接到它。
否则，例如当 [TLS 在负载均衡器处终止](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-a-reverse-proxy-or-load-balancer-ssl-termination)时，
Agent 通过 WebSocket 在 `wss://gitlab.example.com/-/kubernetes-agent/` 或
`ws://gitlab.example.com/-/kubernetes-agent/` 上连接。两种情况下 WebSocket 都保持可用。

<a id="disable-on-a-single-node"></a>

#### 在单个节点上禁用

要在单个节点上禁用极狐GitLab Relay (KAS)：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_kas['enable'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

<a id="turn-on-kas-on-multiple-nodes"></a>

#### 在多个节点上开启 KAS

KAS 实例通过在 Redis 中的已知位置注册各自的私有地址来相互通信。每个 KAS 都必须配置为提供其私有地址详情，以便其他实例可以访问它。

要在多个节点上开启 KAS：

1. 添加[通用配置](#common-configuration)。
1. 添加以下选项之一的配置：

   - [选项 1 - 显式手动配置](#option-1---explicit-manual-configuration)
   - [选项 2 - 基于 CIDR 的自动配置](#option-2---automatic-cidr-based-configuration)
   - [选项 3 - 基于监听器配置的自动配置](#option-3---automatic-configuration-based-on-listener-configuration)

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. （可选）如果您使用具有独立 GitLab Rails 和 Sidekiq 节点的多服务器环境，请在 Sidekiq 节点上启用 KAS。

<a id="common-configuration"></a>

##### 通用配置

对于每个 KAS 节点，编辑 `/etc/gitlab/gitlab.rb` 文件并添加以下配置：

```ruby
gitlab_kas_external_url 'grpcs://kas.gitlab.example.com/'

gitlab_kas['api_secret_key'] = '<32_bytes_long_base64_encoded_value>'
gitlab_kas['private_api_secret_key'] = '<32_bytes_long_base64_encoded_value>'

# private_api_listen_address examples, pick one:

gitlab_kas['private_api_listen_address'] = 'A.B.C.D:8155' # Listen on a particular IPv4. Each node must use its own unique IP.
# gitlab_kas['private_api_listen_address'] = '[A:B:C::D]:8155' # Listen on a particular IPv6. Each node must use its own unique IP.
# gitlab_kas['private_api_listen_address'] = 'kas-N.gitlab.example.com:8155' # Listen on all IPv4 and IPv6 interfaces that the DNS name resolves to. Each node must use its own unique domain.
# gitlab_kas['private_api_listen_address'] = ':8155' # Listen on all IPv4 and IPv6 interfaces.
# gitlab_kas['private_api_listen_address'] = '0.0.0.0:8155' # Listen on all IPv4 interfaces.
# gitlab_kas['private_api_listen_address'] = '[::]:8155' # Listen on all IPv6 interfaces.

# Uncomment below to enable KAS to KAS TLS communication
# gitlab_kas['private_api_certificate_file'] = '<path_to_kas_server_crt_file>'
# gitlab_kas['private_api_key_file'] = '<path_to_kas_server_certificate_key>'

gitlab_kas['env'] = {
  # 'OWN_PRIVATE_API_HOST' => '<server-name-from-cert>' # Add if you want to use TLS for KAS->KAS communication. This name is used to verify the TLS certificate host name instead of the host in the URL of the destination KAS.
  'SSL_CERT_DIR' => "/opt/gitlab/embedded/ssl/certs/",
}

gitlab_rails['gitlab_kas_external_url'] = 'grpcs://gitlab.example.com'
gitlab_rails['gitlab_kas_internal_url'] = 'grpc://kas.internal.gitlab.example.com'
gitlab_rails['gitlab_kas_external_k8s_proxy_url'] = 'https://gitlab.example.com/-/kubernetes-agent/k8s-proxy/'
```

不要将 `private_api_listen_address` 设置为监听内部地址，例如：

- `localhost`
- 回环 IP 地址，如 `127.0.0.1` 或 `::1`
- UNIX 套接字

其他 KAS 节点无法访问这些地址。

对于单节点配置，您可以将 `private_api_listen_address` 设置为监听内部地址。

<a id="option-1---explicit-manual-configuration"></a>

##### 选项 1 - 显式手动配置

对于每个 KAS 节点，编辑 `/etc/gitlab/gitlab.rb` 文件并显式设置 `OWN_PRIVATE_API_URL` 环境变量：

```ruby
gitlab_kas['env'] = {
  # OWN_PRIVATE_API_URL examples, pick one. Each node must use its own unique IP or DNS name.
  # Use grpcs:// when using TLS on the private API endpoint.

  'OWN_PRIVATE_API_URL' => 'grpc://A.B.C.D:8155' # IPv4
  # 'OWN_PRIVATE_API_URL' => 'grpcs://A.B.C.D:8155' # IPv4 + TLS
  # 'OWN_PRIVATE_API_URL' => 'grpc://[A:B:C::D]:8155' # IPv6
  # 'OWN_PRIVATE_API_URL' => 'grpc://kas-N-private-api.gitlab.example.com:8155' # DNS name
}
```

<a id="option-2---automatic-cidr-based-configuration"></a>

##### 选项 2 - 基于 CIDR 的自动配置

例如，如果 KAS 主机被动态分配了 IP 地址和主机名，您可能无法在 `OWN_PRIVATE_API_URL` 变量中设置确切的 IP 地址或主机名。

如果您无法设置确切的 IP 地址或主机名，可以配置 `OWN_PRIVATE_API_CIDR`，让 KAS 基于一个或多个 [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) 动态构建
`OWN_PRIVATE_API_URL`：

这种方法允许每个 KAS 节点使用静态配置，只要 CIDR 不变即可正常工作。

对于每个 KAS 节点，编辑 `/etc/gitlab/gitlab.rb` 文件以动态构建
`OWN_PRIVATE_API_URL` URL：

1. 在通用配置中注释掉 `OWN_PRIVATE_API_URL` 以关闭此变量。
1. 配置 `OWN_PRIVATE_API_CIDR` 以指定 KAS 节点监听的网络。
   当您启动 KAS 时，它会通过选择与指定 CIDR 匹配的主机地址来确定要使用的私有 IP 地址。
1. 配置 `OWN_PRIVATE_API_PORT` 以使用不同的端口。默认情况下，KAS 使用 `private_api_listen_address` 参数中的端口。
1. 如果您在私有 API 端点上使用 TLS，请配置 `OWN_PRIVATE_API_SCHEME=grpcs`。默认情况下，KAS 使用 `grpc` 方案。

```ruby
gitlab_kas['env'] = {
  # 'OWN_PRIVATE_API_CIDR' => '10.0.0.0/8', # IPv4 example
  # 'OWN_PRIVATE_API_CIDR' => '2001:db8:8a2e:370::7334/64', # IPv6 example
  # 'OWN_PRIVATE_API_CIDR' => '10.0.0.0/8,2001:db8:8a2e:370::7334/64', # multiple CIRDs example

  # 'OWN_PRIVATE_API_PORT' => '8155',
  # 'OWN_PRIVATE_API_SCHEME' => 'grpc',
}
```

<a id="option-3---automatic-configuration-based-on-listener-configuration"></a>

##### 选项 3 - 基于监听器配置的自动配置

KAS 节点可以根据 `private_api_listen_network` 和 `private_api_listen_address` 设置来确定哪些 IP 地址可用：

- 如果 `private_api_listen_address` 设置为固定的 IP 地址和端口号（例如 `ip:port`），则使用此 IP 地址。
- 如果 `private_api_listen_address` 没有 IP 地址（例如 `:8155`），或者具有未指定的 IP 地址
  （例如 `[::]:8155` 或 `0.0.0.0:8155`），KAS 会将所有非回环和非链路本地 IP 地址分配给该节点。
  IPv4 和 IPv6 地址会根据 `private_api_listen_network`的值进行过滤。
- 如果 `private_api_listen_address` 是 `hostname:PORT`（例如 `kas-N-private-api.gitlab.example.com:8155`），KAS
  会解析 DNS 名称并将所有 IP 地址分配给该节点。
  在此模式下，KAS 仅监听第一个 IP 地址（此行为由 [Go 标准库](https://pkg.go.dev/net#Listen)定义）。
  IPv4 和 IPv6 地址会根据 `private_api_listen_network`的值进行过滤。

在所有 IP 地址上公开 KAS 的私有 API 地址之前，请确保此操作不与您组织的安全策略冲突。私有 API 端点要求所有请求都提供有效的身份验证令牌。

对于每个 KAS 节点，编辑 `/etc/gitlab/gitlab.rb` 文件：

示例 1. 监听所有 IPv4 和 IPv6 接口：

```ruby
# gitlab_kas['private_api_listen_network'] = 'tcp' # this is the default value, no need to set it.
gitlab_kas['private_api_listen_address'] = ':8155' # Listen on all IPv4 and IPv6 interfaces
```

示例 2. 监听所有 IPv4 接口：

```ruby
gitlab_kas['private_api_listen_network'] = 'tcp4'
gitlab_kas['private_api_listen_address'] = ':8155'
```

示例 3. 监听所有 IPv6 接口：

```ruby
gitlab_kas['private_api_listen_network'] = 'tcp6'
gitlab_kas['private_api_listen_address'] = ':8155'
```

您可以使用环境变量来覆盖构建 `OWN_PRIVATE_API_URL` 时使用的方案和端口：

```ruby
gitlab_kas['env'] = {
  # 'OWN_PRIVATE_API_PORT' => '8155',
  # 'OWN_PRIVATE_API_SCHEME' => 'grpc',
}
```

<a id="use-a-load-balancer-or-reverse-proxy-with-multiple-kas-instances"></a>

##### 在多个 KAS 实例中使用负载均衡器或反向代理

> [!warning]
> 当您在 KAS 前面放置负载均衡器或反向代理时，请为外部和内部流量配置单独的端点，
> 以防止公开内部 API。

KAS 在不同端口上提供流量：

- 端口 8150（`listen_address`）：Agent 连接（WebSocket/gRPC）
- 端口 8153（`internal_api_listen_address`）：GitLab Rails API (gRPC)

  > [!warning]
  > 不要公开暴露端口 8153。虽然该端口会进行身份验证，但它应仅可由 GitLab Rails 实例访问。

要在使用负载均衡器或反向代理时保护 KAS，请配置两个单独的端点：

- 外部端点：端口 8150（用于 Agent）
- 内部端点：端口 8153（仅用于 GitLab Rails，受网络或防火墙限制）

这种分离可确保内部 API 与公共访问保持隔离。

例如，在 NGINX 中配置具有网络限制的内部端点：

```nginx
# Internal endpoint (network-restricted)
server {
  listen 8443 ssl http2;
  server_name kas-internal.example.com;

  # Optional: allow 10.0.1.0/24; deny all;

  location /gitlab.agent. {
    grpc_pass grpc://kas-backend:8153;
  }
}
```

配置极狐GitLab 以使用单独的端点（`/etc/gitlab/gitlab.rb`）：

```ruby
gitlab_rails['gitlab_kas_external_url'] = 'wss://kas-external.example.com'
gitlab_rails['gitlab_kas_internal_url'] = 'grpcs://kas-internal.example.com:8443'
gitlab_rails['gitlab_kas_external_k8s_proxy_url'] = 'https://kas-external.example.com/k8s-proxy/'
```

关键配置要点：

- 为内部流量使用单独的域、端口或 IP 限制。
- 对于云负载均衡器，为端口 8150 和 8153 配置单独的目标组。

<a id="gitlab-relay-kas-node-settings"></a>

##### 极狐GitLab Relay (KAS) 节点设置

| 设置                                             | 描述 |
|-----------------------------------------------------|-------------|
| `gitlab_kas['private_api_listen_network']`          | KAS 监听的网络族。对于 IPv4 和 IPv6 网络，默认为 `tcp`。对于 IPv4 设置为 `tcp4`，对于 IPv6 设置为 `tcp6`。 |
| `gitlab_kas['private_api_listen_address']`          | KAS 监听的地址。设置为 `0.0.0.0:8155` 或集群中其他节点可访问的 IP 和端口。 |
| `gitlab_kas['api_secret_key']`                      | 用于 KAS 与极狐GitLab 之间身份验证的共享密钥。该值必须经过 Base64 编码且长度正好为 32 字节。 |
| `gitlab_kas['private_api_secret_key']`              | 用于不同 KAS 实例之间身份验证的共享密钥。该值必须经过 Base64 编码且长度正好为 32 字节。 |
| `gitlab_kas['private_api_certificate_file']`        | KAS 服务器证书文件的完整路径。当 `OWN_PRIVATE_API_SCHEME` 或 `OWN_PRIVATE_API_URL` 为 `grpcs` 时必需。 |
| `gitlab_kas['private_api_key_file']`                | KAS 服务器证书密钥文件的完整路径。当 `OWN_PRIVATE_API_SCHEME` 或 `OWN_PRIVATE_API_URL` 为 `grpcs` 时必需。 |
| `OWN_PRIVATE_API_SCHEME`                            | 可选值，用于指定构建 `OWN_PRIVATE_API_URL` 时使用的方案。可以是 `grpc` 或 `grpcs`。 |
| `OWN_PRIVATE_API_URL`                               | KAS 用于服务发现的环境变量。设置为您正在配置的节点的主机名或 IP 地址。该节点必须可由集群中的其他节点访问。 |
| `OWN_PRIVATE_API_HOST`                              | 可选值，用于验证 TLS 证书主机名。[^outbound-tls] 客户端会将此值与服务器 TLS 证书文件中的主机名进行比较。 |
| `OWN_PRIVATE_API_PORT`                              | 可选值，用于指定构建 `OWN_PRIVATE_API_URL` 时使用的端口。 |
| `OWN_PRIVATE_API_CIDR`                              | 可选值，用于指定构建 `OWN_PRIVATE_API_URL` 时从可用网络中使用哪些 IP 地址。 |
| `gitlab_kas['client_timeout_seconds']`              | 客户端连接到 KAS 的超时时间。 |
| `gitlab_kas_external_url`                           | 集群内 `agentk` 面向用户的 URL。可以是完全限定的域或子域，[^subdomain-example] 也可以是极狐GitLab 外部 URL。[^instance-path-example] 如果留空，则默认为极狐GitLab 外部 URL。 |
| `gitlab_rails['gitlab_kas_external_url']`           | 集群内 `agentk` 面向用户的 URL。如果留空，则默认为 `gitlab_kas_external_url`。 |
| `gitlab_rails['gitlab_kas_external_k8s_proxy_url']` | Kubernetes API 代理面向用户的 URL。如果留空，则默认为基于 `gitlab_kas_external_url`的 URL。 |
| `gitlab_rails['gitlab_kas_internal_url']`           | 极狐GitLab 后端用于与 KAS 通信的内部 URL。 |

[^outbound-tls]: 当 `OWN_PRIVATE_API_URL` 或 `OWN_PRIVATE_API_SCHEME` 以 `grpcs` 开头时，启用出站连接的 TLS。
[^subdomain-example]: 例如，`grpcs://kas.gitlab.example.com/`。
[^instance-path-example]: 例如，`grpcs://gitlab.example.com`。

<a id="configure-a-standalone-kas-node"></a>

#### 配置独立的 KAS 节点

配置 Omnibus 以将 KAS 与其他组件分开运行。

在每个 Rails 节点上：

```ruby
## KAS Config
gitlab_kas['enable'] = false

gitlab_rails['gitlab_kas_enabled'] = true
gitlab_rails['gitlab_kas_external_url'] = 'grpcs://kas.example.com/'
gitlab_rails['gitlab_kas_internal_url'] = 'grpc://<KAS_NODE_IP_OR_DOMAIN>:8153' # If you want to configure multiple KAS nodes that are behind an internal LB, then use 'grpc://<LB_IP_OR_DOMAIN>:<port>'
gitlab_rails['gitlab_kas_external_k8s_proxy_url'] = 'https://kas.example.com/-/kubernetes-agent/k8s-proxy/'
```

在每个 KAS 节点上：

```ruby
### External URL
external_url 'https://kas.example.com'

### Avoid running unnecessary services ###
gitaly['enable'] = false
gitlab_workhorse['enable'] = false
nginx['enable'] = true
postgresql['enable'] = false
prometheus['enable'] = false
puma['enable'] = false
redis['enable'] = false
sidekiq['enable'] = false

### Prevent database connections during 'gitlab-ctl reconfigure' ###
gitlab_rails['rake_cache_clear'] = false
gitlab_rails['auto_migrate'] = false

gitlab_kas['redis_password'] = '<redis_password>'

# Uncomment below if using Redis high availability with Sentinel
# gitlab_kas['redis_sentinels'] = [
#  {host: '<REDIS_IP>', port: 26379},
#  {host: '<REDIS_IP>', port: 26379},
#  {host: '<REDIS_IP>', port: 26379},
# ]
# gitlab_kas['redis_sentinels_master_name'] = 'gitlab-redis'
# gitlab_kas['redis_sentinels_password'] = '<redis_sentinels_password>'

### GitLab Relay (KAS) ###
gitlab_kas['enable'] = true
gitlab_kas_external_url 'grpcs://kas.example.com/'
gitlab_kas['api_secret_key'] = '<32_bytes_long_base64_encoded_value>'
gitlab_kas['private_api_secret_key'] = '<32_bytes_long_base64_encoded_value>'
gitlab_kas['private_api_listen_address'] = '<KAS_NODE_PRIVATE_IP>:8155'

gitlab_kas['listen_address'] = '<KAS_NODE_PRIVATE_IP>:8150'
gitlab_kas['observability_listen_address'] = '<KAS_NODE_PRIVATE_IP>:8151'
gitlab_kas['internal_api_listen_address'] = '<KAS_NODE_PRIVATE_IP>:8153'
gitlab_kas['kubernetes_api_listen_address'] = '<KAS_NODE_PRIVATE_IP>:8154'

```

<a id="for-gitlab-helm-chart"></a>

### 对于 GitLab Helm Chart

请参阅[如何使用 GitLab-KAS chart](https://gitlab.cn/docs/charts/charts/gitlab/kas/)。

<a id="kubernetes-api-proxy-cookie"></a>

## Kubernetes API 代理 cookie

极狐GitLab Relay (KAS) 通过以下方式将 Kubernetes API 请求代理到极狐GitLab Kubernetes Agent：

- [CI/CD 作业](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/kubernetes_ci_access.md)。
- [GitLab 用户凭据](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/kubernetes_user_access.md)。

要使用用户凭据进行身份验证，Rails 会为极狐GitLab 前端设置一个 cookie。此 cookie 称为 `_gitlab_kas`，它包含加密的
会话 ID，类似于 [`_gitlab_session` cookie](../../user/profile/_index.md#cookies-used-for-sign-in)。
每个请求都必须将 `_gitlab_kas` cookie 发送到 KAS 代理端点，以对用户进行身份验证和授权。

<a id="enable-receptive-agents"></a>

## 启用接收型 Agent

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

[接收型 Agent](../../user/clusters/agent/_index.md#receptive-agents) 允许极狐GitLab 与无法建立到极狐GitLab 实例的网络连接、但可由极狐GitLab 连接的 Kubernetes 集群集成。

先决条件：

- 管理员访问权限。

要启用接收型 Agent：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **极狐GitLab Kubernetes Agent**。
1. 打开**启用接收模式**开关。

<a id="configure-kubernetes-api-proxy-response-header-allowlist"></a>

## 配置 Kubernetes API 代理响应头允许名单

KAS 中的 Kubernetes API 代理对响应头使用允许名单。
默认情况下，允许安全和知名的 Kubernetes 和 HTTP 头。

有关允许的响应头列表，请参阅[响应头允许名单](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/internal/module/kubernetes_api/server/proxy_headers.go)。

如果您需要不在默认允许名单中的响应头，可以在 KAS 配置中添加您的响应头。

要添加额外的允许响应头：

```yaml
agent:
  kubernetes_api:
    extra_allowed_response_headers:
      - 'X-My-Custom-Header-To-Allow'
```

对添加更多响应头的支持记录在[议题 550614](https://gitlab.com/gitlab-org/gitlab/-/issues/550614)中。

<a id="troubleshooting"></a>

## 故障排除

如果您在使用极狐GitLab Relay (KAS) 时遇到问题，请通过运行以下命令查看服务日志：

```shell
kubectl logs -f -l=app=kas -n <YOUR-GITLAB-NAMESPACE>
```

在 Linux 软件包安装中，日志位于 `/var/log/gitlab/gitlab-kas/`。

您还可以[排查单个 Agent 的问题](../../user/clusters/agent/troubleshooting.md)。

<a id="configuration-file-not-found"></a>

### 找不到配置文件

如果您收到以下错误消息：

```plaintext
time="2020-10-29T04:44:14Z" level=warning msg="Config: failed to fetch" agent_id=2 error="configuration file not found: \".gitlab/agents/test-agent/config.yaml\
```

以下路径之一不正确：

- 注册 Agent 的代码仓库。
- Agent 配置文件。

要解决此问题，请确保路径正确。

<a id="error-dial-tcp-gitlab_internal_ip443-connect-connection-refused"></a>

### 错误：`dial tcp <GITLAB_INTERNAL_IP>:443: connect: connection refused`

如果您运行的是极狐GitLab 私有化部署，并且：

- 实例未运行在终止 SSL 的代理后面。
- 实例本身未在极狐GitLab 实例上配置 HTTPS。
- 实例的主机名在本地解析为其内部 IP 地址。

当极狐GitLab Relay (KAS) 尝试连接到极狐GitLab API 时，可能会出现以下错误：

```json
{"level":"error","time":"2021-08-16T14:56:47.289Z","msg":"GetAgentInfo()","correlation_id":"01FD7QE35RXXXX8R47WZFBAXTN","grpc_service":"gitlab.agent.reverse_tunnel.rpc.ReverseTunnel","grpc_method":"Connect","error":"Get \"https://gitlab.example.com/api/v4/internal/kubernetes/agent_info\": dial tcp 172.17.0.4:443: connect: connection refused"}
```

要为 Linux 软件包安装解决此问题，请在 `/etc/gitlab/gitlab.rb`中设置以下参数。将 `gitlab.example.com` 替换为您极狐GitLab 实例的主机名：

```ruby
gitlab_kas['gitlab_address'] = 'http://gitlab.example.com'
```

<a id="error-x509-certificate-signed-by-unknown-authority"></a>

### 错误：`x509: certificate signed by unknown authority`

如果您在尝试访问极狐GitLab URL 时遇到此错误，这意味着它不信任极狐GitLab 证书。

您可能会在极狐GitLab 应用服务器的 KAS 日志中看到类似的错误：

```json
{"level":"error","time":"2023-03-07T20:19:48.151Z","msg":"AgentInfo()","grpc_service":"gitlab.agent.agent_configuration.rpc.AgentConfiguration","grpc_method":"GetConfiguration","error":"Get \"https://gitlab.example.com/api/v4/internal/kubernetes/agent_info\": x509: certificate signed by unknown authority"}
```

要解决此错误，请在 `/etc/gitlab/trusted-certs` 目录中安装内部 CA 的公共证书。

或者，您可以配置 KAS 从自定义目录读取证书。为此，请将以下配置添加到 `/etc/gitlab/gitlab.rb` 文件中：

```ruby
gitlab_kas['env'] = {
   'SSL_CERT_DIR' => "/opt/gitlab/embedded/ssl/certs/"
 }
```

要应用更改：

1. 重新配置极狐GitLab：

```shell
sudo gitlab-ctl reconfigure
```

1. 重启极狐GitLab Relay (KAS)：

```shell
gitlab-ctl restart gitlab-kas
```

<a id="error-grpcdeadlineexceeded-in-clustersagentsnotifygitpushworker"></a>

### 错误：`GRPC::DeadlineExceeded in Clusters::Agents::NotifyGitPushWorker`

此错误通常发生在客户端在默认超时期限（5 秒）内未收到响应时。要解决此问题，您可以通过修改 `/etc/gitlab/gitlab.rb` 配置文件来增加客户端超时时间。

<a id="steps-to-resolve"></a>

#### 解决步骤

1. 添加或更新以下配置以增加超时值：

```ruby
gitlab_kas['client_timeout_seconds'] = "10"
```

1. 通过重新配置极狐GitLab 应用更改：

```shell
gitlab-ctl reconfigure
```

<a id="note"></a>

#### 注意

您可以根据具体需求调整超时值。建议进行测试，以确保问题得到解决且不影响系统性能。

<a id="error-blocked-kubernetes-api-proxy-response-header"></a>

### 错误：`Blocked Kubernetes API proxy response header`

如果 HTTP 响应头在从 Kubernetes 集群通过 Kubernetes API 代理发送给用户时丢失，请检查 KAS 日志或 Sentry 实例中是否有以下错误：

```plaintext
Blocked Kubernetes API proxy response header. Please configure extra allowed headers for your instance in the KAS config with `extra_allowed_response_headers` and have a look at the troubleshooting guide at https://docs.gitlab.com/administration/clusters/kas/#troubleshooting.
```

此错误意味着 Kubernetes API 代理阻止了响应头，因为它们未在响应头允许名单中定义。

有关添加响应头的更多信息，请参阅[配置响应头允许名单](#configure-kubernetes-api-proxy-response-header-allowlist)。

对添加更多响应头的支持记录在[议题 550614](https://gitlab.com/gitlab-org/gitlab/-/issues/550614)中。
