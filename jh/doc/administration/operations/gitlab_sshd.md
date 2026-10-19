---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为您的极狐GitLab 实例配置 OpenSSH 的轻量级替代方案。
title: '`gitlab-sshd`'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

`gitlab-sshd` 是一个[独立的 SSH 服务器](https://gitlab.com/gitlab-org/gitlab-shell/-/tree/main/internal/sshd)，使用 Go 编写。它是 OpenSSH 的轻量级替代方案。它属于 `gitlab-shell` 软件包的一部分，并处理 [SSH 操作](https://gitlab.com/gitlab-org/gitlab-shell/-/blob/71a7f34a476f778e62f8fe7a453d632d395eaf8f/doc/features.md)。

OpenSSH 使用受限 shell 的方式，而 `gitlab-sshd`：

- 作为现代多线程服务器应用运行。
- 使用远程过程调用（RPC），而不是 SSH 传输协议。
- 比 OpenSSH 占用更少内存。
- 支持[按 IP 地址限制群组访问](../../user/group/access_and_permissions.md#restrict-group-access-by-ip-address)，
  适用于在代理后面运行的应用。

有关实现的更多细节，请参阅[博客文章](https://about.gitlab.com/blog/why-we-have-implemented-our-own-sshd-solution-on-gitlab-sass/)。

如果您正在考虑从 OpenSSH 切换到 `gitlab-sshd`，请考虑以下事项：

- PROXY 协议：`gitlab-sshd` 支持 PROXY 协议，使其能够在 HAProxy 等代理服务器
  后面运行。此功能默认未启用，但[可以启用](#proxy-protocol-support)。
- SSH 证书：`gitlab-sshd` 支持实例级 SSH 证书身份验证，
  通过 `config.yml`中配置的受信任 CA 密钥实现。有关更多信息，请参阅
  [使用 `gitlab-sshd`的实例级 SSH 证书](gitlab_sshd_ssh_certificates.md)。
- 2FA 恢复代码：`gitlab-sshd` 不支持重新生成 2FA 恢复代码。
  尝试运行 `2fa_recovery_codes` 会导致以下错误：
  `remote: ERROR: Unknown command: 2fa_recovery_codes`。有关详情，请参阅
  [相关讨论](https://gitlab.com/gitlab-org/gitlab-shell/-/issues/766#note_1906707753)。
- 算法配置：`gitlab-sshd` 不读取 `/etc/ssh/sshd_config`。
  有关更多信息，请参阅[配置 SSH 算法](#configure-ssh-algorithms)。
- Git 协议 v2：`gitlab-sshd` 无需额外配置即可接受 `GIT_PROTOCOL` 环境变量。
  [配置 Git 协议 v2](../git_protocol.md)中描述的 `AcceptEnv` 设置
  仅适用于 OpenSSH。

GitLab Shell 的功能不仅限于 Git 操作，还可用于与极狐GitLab 进行各种基于 SSH 的交互。

<a id="enable-gitlab-sshd"></a>

## 启用 `gitlab-sshd`

要使用 `gitlab-sshd`：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

以下说明将在与 OpenSSH 不同的端口上启用 `gitlab-sshd`：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_sshd['enable'] = true
   gitlab_sshd['listen_address'] = '[::]:2222' # Adjust the port accordingly
   ```

1. 可选。默认情况下，如果 `/var/opt/gitlab/gitlab-sshd`中不存在 SSH 主机密钥，
   Linux 软件包安装会为 `gitlab-sshd` 生成这些密钥。如果您希望禁用此自动生成功能，请添加以下行：

   ```ruby
   gitlab_sshd['generate_host_keys'] = false
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

默认情况下，`gitlab-sshd` 以 `git` 用户身份运行。因此，`gitlab-sshd` 无法
在低于 1024 的特权端口号上运行。这意味着用户必须
使用 `gitlab-sshd` 端口访问 Git，或使用负载均衡器
将 SSH 流量定向到 `gitlab-sshd` 端口以隐藏此问题。

用户可能会看到主机密钥警告，因为新生成的主机密钥
与 OpenSSH 主机密钥不同。如果这是一个问题，请考虑禁用主机密钥
生成，并将现有的 OpenSSH 主机密钥复制到
`/var/opt/gitlab/gitlab-sshd`。

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

以下说明将 OpenSSH 切换为 `gitlab-sshd`：

1. 将 `gitlab-shell` chart 的 `sshDaemon` 选项设置为
   [`gitlab-sshd`](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-shell/#installation-command-line-options)。
   例如：

   ```yaml
   gitlab:
     gitlab-shell:
       sshDaemon: gitlab-sshd
   ```

1. 执行 Helm 升级。

默认情况下，`gitlab-sshd` 监听：

- 端口 22 上的外部请求（`global.shell.port`）。
- 端口 2222 上的内部请求（`gitlab.gitlab-shell.service.internalPort`）。

您可以[在 Helm chart 中配置不同的端口](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-shell/#configuration)。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-ssh-algorithms"></a>

## 配置 SSH 算法

`gitlab-sshd` 是一个独立的 SSH 服务器，不读取 `/etc/ssh/sshd_config`。请改用极狐GitLab 设置来配置它提供的算法。您可以设置密钥交换算法、密码算法、消息认证码（MAC）算法，以及客户端身份验证所接受的公钥算法。

这些设置仅在[启用 `gitlab-sshd`](#enable-gitlab-sshd) 时生效。它们仅适用于 `gitlab-sshd` 监听的端口。如果 OpenSSH 在另一个端口上提供 Git SSH 流量，您需要在 `/etc/ssh/sshd_config`中单独配置。

> [!warning]
> 从 `public_key_algorithms`中移除算法会导致受影响的客户端
> 无法进行身份验证。
> 该示例排除了 `ssh-rsa`，这会影响只能生成 SHA-1 RSA
> 签名的客户端。
> RSA SSH 证书仍然可用，因为客户端使用
> `rsa-sha2-256-cert-v01@openssh.com` 或 `rsa-sha2-512-cert-v01@openssh.com` 提供这些证书，其
> 底层算法仍然允许。
> 只有仅限于 `ssh-rsa-cert-v01@openssh.com`的客户端会受到影响。
> 在应用此更改之前，请检查您的客户端。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

要限制 `gitlab-sshd` 提供的算法：

1. 编辑 `/etc/gitlab/gitlab.rb`。例如，要排除使用 SHA-1 的算法：

   ```ruby
   gitlab_sshd['kex_algorithms'] = %w(mlkem768x25519-sha256 curve25519-sha256 ecdh-sha2-nistp256 ecdh-sha2-nistp384 ecdh-sha2-nistp521 diffie-hellman-group16-sha512)
   gitlab_sshd['macs'] = %w(hmac-sha2-512-etm@openssh.com hmac-sha2-256-etm@openssh.com)
   gitlab_sshd['public_key_algorithms'] = %w(ssh-ed25519 sk-ssh-ed25519@openssh.com sk-ecdsa-sha2-nistp256@openssh.com ecdsa-sha2-nistp256 ecdsa-sha2-nistp384 ecdsa-sha2-nistp521 rsa-sha2-256 rsa-sha2-512)
   ```

   没有默认密码算法使用 SHA-1，因此 `ciphers` 设置无需更改。
   要单独限制密码算法，请设置 `gitlab_sshd['ciphers']`。

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

生成的配置会写入
`/var/opt/gitlab/gitlab-shell/config.yml`的 `sshd` 部分。

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

这些设置仅在 `sshDaemon` 设置为 `gitlab-sshd` 时生效。
`sshDaemon`的默认值为 `openssh`。

1. 设置 [`gitlab.gitlab-shell.config` 选项](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-shell/#installation-command-line-options)。
   例如，要排除使用 SHA-1 的算法：

   ```yaml
   gitlab:
     gitlab-shell:
       sshDaemon: gitlab-sshd
       config:
         kexAlgorithms:
           - mlkem768x25519-sha256
           - curve25519-sha256
           - ecdh-sha2-nistp256
           - ecdh-sha2-nistp384
           - ecdh-sha2-nistp521
           - diffie-hellman-group16-sha512
         macs:
           - hmac-sha2-512-etm@openssh.com
           - hmac-sha2-256-etm@openssh.com
         publicKeyAlgorithms:
           - ssh-ed25519
           - sk-ssh-ed25519@openssh.com
           - sk-ecdsa-sha2-nistp256@openssh.com
           - ecdsa-sha2-nistp256
           - ecdsa-sha2-nistp384
           - ecdsa-sha2-nistp521
           - rsa-sha2-256
           - rsa-sha2-512
   ```

1. 执行 Helm 升级。

{{< /tab >}}

{{< /tabs >}}

每个设置都会替换该算法类型的默认列表。未设置的设置将保留其默认值。

<a id="default-algorithms"></a>

### 默认算法

当您将某项设置留空时，`gitlab-sshd` 会使用
GitLab Shell 所基于的
[`golang.org/x/crypto/ssh`](https://pkg.go.dev/golang.org/x/crypto/ssh) 软件包的默认值。当极狐GitLab 更新该依赖项时，默认值会发生变化。
在极狐GitLab 18.3 之前，GitLab Shell 使用自己硬编码的列表。

默认值较为宽松，包含使用 SHA-1 的算法。请显式配置这些设置以排除它们。

当您配置这些设置时，以下行为适用：

- GitLab Shell 无法识别的算法名称会从列表中删除，而不是
  报告为错误，因此一个失误可能导致实际列表与预期不同。
  请始终确认更改已生效。
  有关更多信息，请参阅[议题 870](https://gitlab.com/gitlab-org/gitlab-shell/-/issues/870)。
- `public_key_algorithms`中的失误行为不同，且更为严重。
  该值会在每次连接时检查，而不是在启动时检查，因此
  `gitlab-ctl reconfigure` 会成功且服务器会启动，但客户端无法进行身份验证。
  有关更多信息，请参阅[议题 871](https://gitlab.com/gitlab-org/gitlab-shell/-/issues/871)。
- 扫描中会出现两个您未配置的名称。
  当您列出 `curve25519-sha256` 时，会自动添加 `curve25519-sha256@libssh.org`。
  `kex-strict-s-v00@openssh.com` 始终会出现，因为它是严格的密钥交换标记，
  而不是算法。

GitLab Shell
[`config.yml.example`](https://gitlab.com/gitlab-org/gitlab-shell/-/blob/main/config.yml.example)
文件中的示例 `sshd` 列表说明了格式。它们不是实际生效的默认值。

要确认更改已生效，请从客户端扫描正在运行的服务器。例如：

```shell
ssh-audit <hostname> -p <port>
```

<a id="host-key-algorithms"></a>

### 主机密钥算法

您无法直接配置主机密钥算法。`gitlab-sshd` 会根据其加载的主机密钥推导这些算法，因此 RSA 主机密钥会导致服务器提供 `rsa-sha2-256`、`rsa-sha2-512` 和 `ssh-rsa`。`public_key_algorithms` 设置不会改变这一点，因为它仅适用于客户端身份验证。有关更多信息，请参阅[议题 806](https://gitlab.com/gitlab-org/gitlab-shell/-/issues/806)。

要阻止服务器提供 `ssh-rsa`，请排除 RSA 主机密钥。

> [!warning]
> 移除主机密钥会改变客户端看到的主机密钥指纹。
> 用户会收到主机密钥警告，并且固定到已移除密钥的客户端会失败，直到其
> `known_hosts` 条目更新为止。
> 在进行此更改之前，请告知您的用户。

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_sshd['host_keys_glob'] = 'ssh_host_{ecdsa,ed25519}_key'
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

`gitlab-sshd` 会匹配主机密钥目录中的模式，该目录默认为
`/var/opt/gitlab/gitlab-sshd`。
如果该模式未匹配到任何文件，`gitlab-sshd` 将无法启动。

<a id="metrics"></a>

## 指标

`gitlab-sshd` 在监控端点上公开 [Prometheus 指标](../monitoring/prometheus/gitlab_metrics.md)，该端点通过 `gitlab-shell` 配置中的 `web_listen` 配置。`gitlab-sshd` 在该地址的 `/metrics` 路径上提供这些指标。

| 指标                                                   | 类型      | 描述 |
|:---------------------------------------------------------|:----------|:------------|
| `gitlab_shell_sshd_in_flight_connections`                | Gauge     | 当前由 `gitlab-sshd` 提供服务的连接数。 |
| `gitlab_shell_sshd_concurrent_limited_sessions_total`    | Counter   | 达到并发会话限制的次数。 |
| `gitlab_shell_sshd_session_duration_seconds`             | Histogram | 由 `gitlab-sshd` 提供服务的 SSH 会话持续时间。 |
| `gitlab_shell_sshd_session_established_duration_seconds` | Histogram | 建立 SSH 会话的延迟，用作 `gitlab_sshd` 服务 Apdex 的延迟。 |
| `gitlab_sli:shell_sshd_sessions:total`                   | Counter   | 已建立的 SSH 会话数（身份验证后的会话通道）。 |
| `gitlab_sli:shell_sshd_sessions:errors_total`            | Counter   | 已失败的 SSH 会话数。 |
| `gitlab_sli:shell_sshd_connections:total`                | Counter   | 到达身份验证阶段的 SSH 连接数。 |
| `gitlab_sli:shell_sshd_connections:errors_total`         | Counter   | 因服务器端错误而失败的 SSH 连接数。 |

<a id="session-level-and-connection-level-slis"></a>

### 会话级和连接级 SLI

`gitlab-sshd` 公开两组用于 SSH 可靠性的服务等级指标（SLI）计数器：

- 会话级（`gitlab_sli:shell_sshd_sessions:*`）统计身份验证后的会话
  通道。
  此计数器不会观察到身份验证阶段发生的失败。
- 连接级（`gitlab_sli:shell_sshd_connections:*`）统计每个到达
  身份验证阶段的连接，并将身份验证或会话阶段的服务器端错误
  视为失败。
  与会话级计数器不同，连接级计数器会捕获身份验证阶段的
  失败，例如 `authorized_keys` 查找错误。
  连接级计数器不包括从未通过传输握手的连接，
  例如端口扫描器和健康检查。

连接级计数器对用户可见的失败提供了更广泛的覆盖，是 SSH 可靠性监控的首选信号。

<a id="other-gitlab-shell-metrics"></a>

### 其他 GitLab Shell 指标

`gitlab-sshd` 还会公开 GitLab Shell 与其他
服务交互的指标。这些指标是 GitLab Shell 通用插桩的一部分，并非特定于 SSH 守护进程。
这些指标涵盖与 Gitaly、极狐GitLab 内部 API、Git LFS 和拓扑
服务的连接。当 `gitlab-sshd` 处理 SSH 连接时，`gitlab-sshd` 会在自己的进程中运行这些操作，并在与 SSH 指标相同的 `/metrics` 端点上公开生成的计数器。
当您使用 OpenSSH 而不是 `gitlab-sshd` 时，GitLab Shell 会为每个
连接作为短生命周期进程运行。这些短生命周期进程会增加相同的计数器，但不会公开指标端点，因此这些计数器无法被抓取。

| 指标                                           | 类型      | 描述 |
|:-------------------------------------------------|:----------|:------------|
| `gitlab_shell_gitaly_connections_total`          | Counter   | 已建立的 Gitaly 连接数，按 `status`（`ok` 或 `fail`）标记。 |
| `gitlab_shell_http_requests_total`               | Counter   | 对极狐GitLab 内部 API 的请求数，按 `code` 和 `method` 标记。 |
| `gitlab_shell_http_request_duration_seconds`     | Histogram | 对极狐GitLab 内部 API 请求的延迟，按 `code` 和 `method` 标记。 |
| `gitlab_shell_http_in_flight_requests`           | Gauge     | 当前正在执行的极狐GitLab 内部 API 请求。 |
| `lfs_http_connections_total`                     | Counter   | 已建立的 Git LFS-over-HTTP 连接数。 |
| `lfs_ssh_connections_total`                      | Counter   | 已建立的 Git LFS-over-SSH 连接数。 |
| `gitlab_shell_topology_connections_total`        | Counter   | 已建立的拓扑服务连接数，按 `status`（`ok` 或 `fail`）标记。 |
| `gitlab_shell_topology_requests_total`           | Counter   | 拓扑服务 `Classify` 请求数，按 `status`（`ok` 或 `fail`）标记。 |
| `gitlab_shell_topology_request_duration_seconds` | Histogram | 拓扑服务 `Classify` 请求的延迟。 |

<a id="proxy-protocol-support"></a>

## PROXY 协议支持

`gitlab-sshd` 前面的负载均衡器会导致极狐GitLab 报告代理 IP 地址，而不是客户端 IP 地址。要获取真实 IP 地址，`gitlab-sshd` 支持
[PROXY 协议](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

要启用 PROXY 协议：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_sshd['proxy_protocol'] = true
   # Proxy protocol policy ("use", "require", "reject", "ignore"), "use" is the default value
   gitlab_sshd['proxy_policy'] = "use"
   ```

   有关 `gitlab_sshd['proxy_policy']` 选项的更多信息，请参阅
   [`go-proxyproto` 库](https://github.com/pires/go-proxyproto/blob/4ba2eb817d7a57a4aafdbd3b82ef0410806b533d/policy.go#L20-L35)。

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 设置 [`gitlab.gitlab-shell.config` 选项](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-shell/#installation-command-line-options)。例如：

   ```yaml
   gitlab:
     gitlab-shell:
       config:
         proxyProtocol: true
         proxyPolicy: "use"
   ```

1. 执行 Helm 升级。

{{< /tab >}}

{{< /tabs >}}
