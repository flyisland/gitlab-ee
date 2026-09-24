---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为你的极狐GitLab 实例配置 OpenSSH 的轻量级替代方案。
title: '`gitlab-sshd`'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

`gitlab-sshd` 是[一个用 Go 语言编写的独立 SSH 服务器](https://gitlab.com/gitlab-org/gitlab-shell/-/tree/main/internal/sshd)。它是 OpenSSH 的轻量级替代方案。它是 `gitlab-shell` 软件包的一部分，用于处理 [SSH 操作](https://gitlab.com/gitlab-org/gitlab-shell/-/blob/71a7f34a476f778e62f8fe7a453d632d395eaf8f/doc/features.md)。

虽然 OpenSSH 使用受限的 shell 方法，但 `gitlab-sshd`：

- 作为现代多线程服务器应用程序运行。
- 使用远程过程调用 (RPC) 而不是 SSH 传输协议。
- 比 OpenSSH 使用更少的内存。
- 支持针对在代理后面运行的应用程序的[按 IP 地址限制群组访问](../../user/group/access_and_permissions.md#restrict-group-access-by-ip-address)。

有关实现的更多详细信息，请参阅[博客文章](https://gitlab.cn/blog/why-we-have-implemented-our-own-sshd-solution-on-gitlab-sass/)。

如果你正在考虑从 OpenSSH 切换到 `gitlab-sshd`，请考虑以下事项：

- PROXY 协议：`gitlab-sshd` 支持 PROXY 协议，允许它在 HAProxy 等代理服务器后面运行。此功能默认未启用，但[可以启用](#proxy-protocol-support)。
- SSH 证书：`gitlab-sshd` 支持通过使用 `config.yml` 中配置的受信任 CA 密钥进行实例级 SSH 证书认证。更多信息，请参阅[`gitlab-sshd` 的实例级 SSH 证书](gitlab_sshd_ssh_certificates.md)。
- 2FA 恢复码：`gitlab-sshd` 不支持 2FA 恢复码的重新生成。尝试运行 `2fa_recovery_codes` 会导致错误：`remote: ERROR: Unknown command: 2fa_recovery_codes`。详细信息请参阅[讨论](https://gitlab.com/gitlab-org/gitlab-shell/-/issues/766#note_1906707753)。

GitLab Shell 的功能不仅限于 Git 操作，还可用于与极狐GitLab 进行各种基于 SSH 的交互。

<a id="enable-gitlab-sshd"></a>

## 启用 `gitlab-sshd`

要使用 `gitlab-sshd`：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

以下说明在与 OpenSSH 不同的端口上启用 `gitlab-sshd`：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_sshd['enable'] = true
   gitlab_sshd['listen_address'] = '[::]:2222' # 相应地调整端口
   ```

1. 可选。默认情况下，如果 `/var/opt/gitlab/gitlab-sshd` 中不存在 SSH 主机密钥，Linux 软件包安装会为 `gitlab-sshd` 生成这些密钥。如果你想禁用此自动生成，请添加此行：

   ```ruby
   gitlab_sshd['generate_host_keys'] = false
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

默认情况下，`gitlab-sshd` 以 `git` 用户身份运行。因此，`gitlab-sshd` 无法在低于 1024 的特权端口号上运行。这意味着用户必须使用 `gitlab-sshd` 端口访问 Git，或者使用负载均衡器将 SSH 流量定向到 `git-sshd` 端口以隐藏这一点。

用户可能会看到主机密钥警告，因为新生成的主机密钥与 OpenSSH 主机密钥不同。如果这是个问题，请考虑禁用主机密钥生成并将现有的 OpenSSH 主机密钥复制到 `/var/opt/gitlab/gitlab-sshd` 中。

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

以下说明将 OpenSSH 切换到 `gitlab-sshd`：

1. 将 `gitlab-shell` 图表的 `sshDaemon` 选项设置为 [`gitlab-sshd`](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-shell/#installation-command-line-options)。例如：

   ```yaml
   gitlab:
     gitlab-shell:
       sshDaemon: gitlab-sshd
   ```

1. 执行 Helm 升级。

默认情况下，`gitlab-sshd` 监听：

- 端口 22 (`global.shell.port`) 上的外部请求。
- 端口 2222 (`gitlab.gitlab-shell.service.internalPort`) 上的内部请求。

你可以[在 Helm Chart 中配置不同的端口](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-shell/#configuration)。

{{< /tab >}}

{{< /tabs >}}

<a id="proxy-protocol-support"></a>

## PROXY 协议支持

`gitlab-sshd` 前面的负载均衡器会导致极狐GitLab 报告代理 IP 地址而不是客户端 IP 地址。为了获取真实 IP 地址，`gitlab-sshd` 支持 [PROXY 协议](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt)。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

要启用 PROXY 协议：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_sshd['proxy_protocol'] = true
   # 代理协议策略（"use"、"require"、"reject"、"ignore"），"use" 是默认值
   gitlab_sshd['proxy_policy'] = "use"
   ```

   有关 `gitlab_sshd['proxy_policy']` 选项的更多信息，请参阅 [`go-proxyproto` 库](https://github.com/pires/go-proxyproto/blob/4ba2eb817d7a57a4aafdbd3b82ef0410806b533d/policy.go#L20-L35)。

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

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