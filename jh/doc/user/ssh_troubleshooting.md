---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SSH 故障排查
---

使用 SSH 密钥时，你可能会遇到以下问题。

<a id="tls-server-sent-certificate-containing-rsa-key-larger-than-8192-bits"></a>

TLS：服务器发送的证书包含大于 8192 位的 RSA 密钥

在极狐GitLab 16.3 及更高版本中，Go 将 RSA 密钥限制为最大 8192 位。要检查密钥的长度：

```shell
openssl rsa -in <your-key-file> -text -noout | grep "Key:"
```

将任何超过 8192 位的密钥替换为更短的密钥。

<a id="password-prompt-with-git-clone"></a>

使用 `git clone` 时的密码提示

当你运行 `git clone` 时，可能会提示你输入密码，例如 `git@gitlab.example.com's password:`。这表示你的 SSH 设置有问题。

- 确保你正确生成了 SSH 密钥对，并将 SSH 公钥添加到了你的极狐GitLab 个人资料中。
- 确保你的 SSH 密钥格式与你的服务器操作系统配置兼容。例如，ED25519 密钥对可能无法在[某些 FIPS 系统](https://jihulab.com/gitlab-cn/gitlab/-/issues/367429)上工作。
- 尝试使用 `ssh-agent` 手动注册你的 SSH 私钥。
- 尝试通过运行 `ssh -Tv git@example.com` 来调试连接。将 `example.com` 替换为你的极狐GitLab URL。
- 确保你遵循了[在 Microsoft Windows 上使用 SSH](ssh_advanced.md#use-ssh-on-microsoft-windows) 中的所有说明。
- 确保你已经[验证了极狐GitLab SSH 所有权和权限](../security/ssh_keys_restrictions.md#verify-gitlab-ssh-ownership-and-permissions)。如果你有多台主机，请确保所有主机上的权限都正确。

<a id="could-not-resolve-hostname-error"></a>

`无法解析主机名` 错误

当你[验证你的 SSH 连接](ssh.md#verify-your-ssh-connection)时，可能会收到以下错误：

```plaintext
ssh：无法解析主机名 gitlab.example.com：未提供节点名或服务名，或者未知
```

如果你收到此错误，请重启终端并重试该命令。

<a id="key-enrollment-failed-invalid-format-error"></a>

`密钥注册失败：格式无效` 错误

当你[为 FIDO2 硬件安全密钥生成 SSH 密钥对](ssh_advanced.md#generate-an-ssh-key-pair-for-a-fido2-hardware-security-key)时，可能会收到以下错误：

```plaintext
密钥注册失败：格式无效
```

你可以通过尝试以下方法来排查此问题：

- 使用 `sudo` 运行 `ssh-keygen` 命令。
- 验证你的 FIDO2 硬件安全密钥是否支持所提供的密钥类型。
- 通过运行 `ssh -V` 验证 OpenSSH 版本是否为 8.2 或更高版本。

<a id="error-permission-denied-publickey"></a>

错误：`权限被拒绝（公钥）`

`权限被拒绝（公钥）` 错误通常表示以下一个或多个问题：

- 未添加公钥：验证公钥是否已[添加到你的极狐GitLab 帐户](ssh.md#add-an-ssh-key-to-your-gitlab-account)。此问题在新用户或新机器上很常见。
- 密钥类型不受支持：密钥类型[不受支持](ssh.md#supported-ssh-key-types)或包含极狐GitLab 无法识别的标头。
- 使用了错误的私钥：如果你有[多个本地 SSH 密钥](ssh.md#check-for-existing-ssh-key-pairs)，请验证是否使用了正确的密钥。SSH 默认使用 `~/.ssh/id_rsa` 或 `id_ed25519`。你可能需要[定义要使用的密钥](ssh_advanced.md#use-ssh-keys-in-another-directory)。
- 私钥不可访问：[验证](ssh.md#check-for-existing-ssh-key-pairs)私钥在你的本地设备上是否可访问。
- 本地权限不正确：验证你的密钥权限。私钥应使用 `600`，`.ssh` 目录应使用 `700`。
- SSH 密钥未加载到 `ssh-agent` 中：验证密钥是否可供你的本地 SSH 客户端使用。此问题在重启后或新的终端会话中很常见。

<a id="error-ssh-host-keys-are-not-available-on-this-system"></a>

错误：`此系统上 SSH 主机密钥不可用。`

如果极狐GitLab 无法访问主机 SSH 密钥，当你访问 `gitlab.example/help/instance_configuration` 时，你会在 **SSH 主机密钥指纹** 标题下看到以下错误消息，而不是实例 SSH 指纹：

```plaintext
此系统上 SSH 主机密钥不可用。请使用 ssh-keyscan 命令或联系你的极狐GitLab 管理员以获取更多信息。
```

要解决此错误：

- 在 Helm Chart（Kubernetes）部署中，更新 `values.yaml`，在 `webservice` 部分将 [`sshHostKeys.mount`](https://gitlab.cn/docs/charts/charts/gitlab/webservice/) 设置为 `true`。
- 在极狐GitLab 私有化部署实例上，检查 `/etc/ssh` 目录中的主机密钥。

<a id="general-ssh-troubleshooting"></a>

常规 SSH 故障排查

如果前面的部分未能解决你的问题，请以详细模式运行 SSH 连接。详细模式可以返回有关连接的有用信息。

要以详细模式运行 SSH，请使用以下命令并将 `gitlab.example.com` 替换为你的极狐GitLab 实例 URL：

```shell
ssh -Tvvv git@gitlab.example.com
```

