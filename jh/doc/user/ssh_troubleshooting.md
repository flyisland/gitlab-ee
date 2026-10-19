---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SSH 故障排除
---

使用 SSH 密钥时，您可能会遇到以下问题。

<a id="tls-server-sent-certificate-containing-rsa-key-larger-than-8192-bits"></a>

## TLS：服务器发送的证书包含大于 8192 位的 RSA 密钥

Go 将 RSA 密钥限制为最大 8192 位。要检查密钥长度：

```shell
openssl rsa -in <your-key-file> -text -noout | grep "Key:"
```

将任何超过 8192 位的密钥替换为更短的密钥。

<a id="password-prompt-with-git-clone"></a>

## 使用 `git clone` 时提示输入密码

运行 `git clone` 时，系统可能会提示您输入密码，例如 `git@gitlab.example.com's password:`。这表明您的 SSH 设置存在问题。

- 确保您正确生成了 SSH 密钥对，并将 SSH
  公钥添加到了您的极狐GitLab 个人资料中。
- 确保您的 SSH 密钥格式与服务器操作系统配置兼容。例如，ED25519 密钥对可能无法在[某些 FIPS 系统](https://gitlab.com/gitlab-org/gitlab/-/issues/367429)上使用。
- 尝试使用 `ssh-agent` 手动注册您的 SSH 私钥。
- 尝试通过运行 `ssh -Tv git@example.com` 来调试连接。
  将 `example.com` 替换为您的极狐GitLab URL。
- 确保您遵循了[在 Microsoft Windows 上使用 SSH](ssh_advanced.md#use-ssh-on-microsoft-windows)中的所有说明。
- 确保您已[验证极狐GitLab SSH 所有权和权限](../security/ssh_keys_restrictions.md#verify-gitlab-ssh-ownership-and-permissions)。如果您有多个主机，请确保所有主机上的权限均正确。

<a id="could-not-resolve-hostname-error"></a>

## `Could not resolve hostname` 错误

当您[验证 SSH 连接](ssh.md#verify-your-ssh-connection)时，可能会收到以下错误：

```shell
ssh: Could not resolve hostname gitlab.example.com: nodename nor servname provided, or not known
```

如果您收到此错误，说明 SSH 无法找到您所提供名称对应的主机。SSH 尝试解析的名称是 `Could not resolve hostname` 后面的文本。将该名称与以下原因进行对比。

| 原因 | 解决方法 |
|-------|------------|
| 名称中包含代码仓库路径，例如 `gitlab.com:alice/my-project.git`。当您将克隆 URL 复制到命令中时会出现这种情况。 | 仅使用主机名，例如 `ssh -T git@gitlab.com`。 |
| 名称拼写错误，或者不是您的极狐GitLab 实例的 URL。 | 更正名称，然后再次运行该命令。 |
| 您的网络无法解析该名称。此原因在极狐GitLab 私有化部署中更常见。 | 确认您可以访问该实例，并连接到其所需的任何 VPN。 |
| 您的终端保留了过期的名称解析缓存。 | 重启终端，然后再次运行该命令。 |

<a id="key-enrollment-failed-invalid-format-error"></a>

## `Key enrollment failed: invalid format` 错误

当您[为 FIDO2 硬件安全密钥生成 SSH 密钥对](ssh_advanced.md#generate-an-ssh-key-pair-for-a-fido2-hardware-security-key)时，可能会收到以下错误：

```shell
Key enrollment failed: invalid format
```

您可以通过尝试以下操作来排查此问题：

- 使用 `sudo` 运行 `ssh-keygen` 命令。
- 验证您的 FIDO2 硬件安全密钥支持
  所提供的密钥类型。
- 通过运行 `ssh -V` 验证 OpenSSH 的版本是否为 8.2 或更高。

<a id="error-permission-denied-publickey"></a>

## 错误：`Permission denied (publickey)`

`Permission denied (publickey)` 错误通常表示存在以下一个或多个问题：

- 未添加公钥：验证公钥是否已
  [添加到您的极狐GitLab 账号](ssh.md#add-an-ssh-key-to-your-gitlab-account)。
  此问题在新用户或新机器上很常见。
- 不支持该密钥类型：该密钥类型[不受支持](ssh.md#supported-ssh-key-types)，或者
  包含极狐GitLab 无法识别的标头。
- 使用了错误的私钥：如果您有
  [多个本地 SSH 密钥](ssh.md#check-for-existing-ssh-key-pairs)，请验证
  使用的是正确的密钥。SSH 默认使用 `~/.ssh/id_rsa` 或 `id_ed25519`。您可能需要
  [指定要使用的密钥](ssh_advanced.md#use-ssh-keys-in-another-directory)。
- 无法访问私钥：
  [验证](ssh.md#check-for-existing-ssh-key-pairs)私钥在
  您的本地设备上是否可访问。
- 本地权限不正确：验证您的密钥权限。
  私钥应使用 `600`，`.ssh` 目录应使用 `700`。
- 未在 `ssh-agent`中加载 SSH 密钥：验证您的本地 SSH 客户端是否可以使用该密钥。
  此问题在重启后或新终端会话中很常见。

<a id="error-ssh-host-keys-are-not-available-on-this-system"></a>

## 错误：`SSH host keys are not available on this system.`

如果极狐GitLab 无法访问主机 SSH 密钥，当您访问 `gitlab.example/help/instance_configuration` 时，会在 **SSH 主机密钥指纹** 标题下看到以下错误消息，而不是实例 SSH 指纹：

```plaintext
SSH host keys are not available on this system. Please use ssh-keyscan command or contact your GitLab administrator for more information.
```

要解决此错误：

- 在 Helm chart（Kubernetes）部署中，更新 `values.yaml`，在 `webservice` 部分下将 [`sshHostKeys.mount`](https://gitlab.cn/docs/charts/charts/gitlab/webservice/) 设置为 `true`。
- 在极狐GitLab 私有化部署实例上，检查 `/etc/ssh` 目录中的主机密钥。

<a id="general-ssh-troubleshooting"></a>

## 常规 SSH 故障排除

如果前面的章节未能解决您的问题，请以详细模式运行 SSH 连接。详细模式可以返回有关连接的有用信息。

要以详细模式运行 SSH，请使用以下命令，并将 `gitlab.example.com` 替换为
您的极狐GitLab 实例 URL：

```shell
ssh -Tvvv git@gitlab.example.com
```
