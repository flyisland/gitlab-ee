---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 OpenSSH AuthorizedPrincipalsCommand 进行用户查找
description: 为 SSH 证书身份验证配置授权主体。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 私有化部署实例的默认 SSH 身份验证要求用户先上传 SSH 公钥，然后才能使用 SSH 传输。

在集中式环境（例如企业环境）中，这一要求可能会带来运维开销。当 SSH 密钥是临时密钥时尤其如此，例如在签发 24 小时后过期的密钥。

在这些环境中，外部自动化流程必须不断向极狐GitLab 上传新密钥。

> [!warning]
> 需要 OpenSSH 6.9 及更高版本，因为 `AuthorizedKeysCommand` 必须
> 能够接受指纹。请检查服务器上的 OpenSSH 版本。

如果您使用 `gitlab-sshd` 而不是 OpenSSH，可以直接在 `gitlab-sshd` 配置文件中配置实例级 SSH 证书身份验证，而无需使用 OpenSSH。有关更多信息，请参见[使用 `gitlab-sshd`的实例级 SSH 证书](gitlab_sshd_ssh_certificates.md)。

如果您是 JihuLab.com 群组所有者，则应改用群组范围的 SSH 证书功能，该功能使用极狐GitLab SSH 服务器，且不需要 OpenSSH 配置。有关更多信息，请参见[管理群组 SSH 证书](../../user/group/ssh_certificates.md)。

<a id="why-use-openssh-certificates"></a>

## 为什么要使用 OpenSSH 证书？

使用 OpenSSH 证书时，密钥属于哪个极狐GitLab 用户的信息会编码在密钥本身中。用户无法伪造此信息，因为他们需要访问私有 CA 签名密钥。

正确设置后，OpenSSH 证书不再需要将用户 SSH 密钥上传到极狐GitLab。

<a id="set-up-ssh-certificate-lookup-with-gitlab-shell"></a>

## 使用 GitLab Shell 设置 SSH 证书查找

完整的 SSH 证书设置不在本页讨论范围内。有关 SSH 证书的工作原理，请参见 OpenSSH [`PROTOCOL.certkeys` 规范](https://cvsweb.openbsd.org/cgi-bin/cvsweb/src/usr.bin/ssh/PROTOCOL.certkeys?annotate=HEAD)以及
[Red Hat 关于 OpenSSH 证书身份验证的文档](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/sec-using_openssh_certificate_authentication)。

开始之前，请确保您已设置好 SSH 证书，并将 CA 的 `TrustedUserCAKeys` 添加到 `sshd_config`中，例如：

```plaintext
TrustedUserCAKeys /etc/security/mycompany_user_ca.pub
```

通常，在此类设置中，`TrustedUserCAKeys` 不会限定在 `Match User git` 下，因为它还会用于登录极狐GitLab 服务器本身的系统登录，但您的设置可能有所不同。如果该 CA 仅用于极狐GitLab，可以考虑将其放在 `Match User git` 部分中（如下所述）。

该 CA 签发的每个 SSH 证书都必须有一个与该用户的极狐GitLab 用户名对应的“密钥 ID”。`AuthorizedPrincipalsCommand` 会将此密钥 ID 映射到极狐GitLab 用户名，这样极狐GitLab 就会从证书中提取用户名，而不是依赖公钥到用户名的映射。极狐GitLab 随附的默认命令假定密钥 ID 与极狐GitLab 用户名之间是一对一映射。

以下示例显示了一个密钥 ID 为 `aearnfjord`的证书（为简洁起见，省略了部分输出）：

```shell
$ ssh-add -L | grep cert | ssh-keygen -L -f -

(stdin):1:
        Type: ssh-rsa-cert-v01@openssh.com user certificate
        Public key: RSA-CERT SHA256:[...]
        Signing CA: RSA SHA256:[...]
        Key ID: "aearnfjord"
        Serial: 8289829611021396489
        Valid: from 2018-07-18T09:49:00 to 2018-07-19T09:50:34
        Principals:
                sshUsers
                [...]
        [...]
```

密钥 ID 不必直接与极狐GitLab 用户名匹配。例如，以 `prod-aearnfjord` 身份登录服务器的用户，其密钥 ID 可能是 `prod-aearnfjord`。在这种情况下，您必须提供自己的 `AuthorizedPrincipalsCommand` 来执行映射，而不是使用默认命令。

接下来，在 `sshd_config`中为 `git` 用户设置 `AuthorizedPrincipalsCommand`。在大多数情况下，您可以使用极狐GitLab 随附的默认命令：

```plaintext
Match User git
    AuthorizedPrincipalsCommandUser root
    AuthorizedPrincipalsCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-principals-check %i sshUsers
```

该命令输出的内容大致如下：

```shell
command="/opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell username-{KEY_ID}",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty {PRINCIPAL}
```

其中 `{KEY_ID}` 是传递给脚本的 `%i` 参数（例如 `aeanfjord`），而 `{PRINCIPAL}` 是传递给它的主体（例如 `sshUsers`）。

您需要自定义其中的 `sshUsers` 部分。它应该是某个主体，确保对于所有能够登录极狐GitLab 的用户来说都是密钥的一部分，或者您必须提供一个主体列表，其中至少有一个主体对应用户，例如：

```plaintext
    [...]
    AuthorizedPrincipalsCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-principals-check %i sshUsers windowsUsers
```

<a id="principals-and-security"></a>

## 主体与安全

您可以提供任意数量的主体。每个主体都会成为 `authorized_keys` 输出中的单独一行，如 `sshd_config(5)`中针对 `AuthorizedPrincipalsFile` 所述。

在 OpenSSH 中，`AuthorizedKeysCommand`中的主体通常是允许登录服务器的“组”。极狐GitLab 使用该主体只是为了满足 OpenSSH 的这一要求，真正重要的是密钥 ID 是否正确。极狐GitLab 提取密钥 ID 后，会针对该用户实施自己的访问控制，例如该用户可以访问哪些项目。

您可以在接受的主体上放宽要求。例如，如果用户无权访问极狐GitLab，身份验证会失败并显示无效用户错误。

<a id="interaction-with-the-authorized_keys-file"></a>

## 与 `authorized_keys` 文件的交互

SSH 证书与 `authorized_keys` 文件协同工作，后者充当回退方案。当 `AuthorizedPrincipalsCommand` 无法对用户进行身份验证时，OpenSSH 会回退到 `~/.ssh/authorized_keys` 文件或 `AuthorizedKeysCommand`。因此，使用 SSH 证书时，您可能仍需要[在数据库中快速查找已授权的 SSH 密钥](fast_ssh_key_lookup.md)。

对大多数用户而言，`AuthorizedPrincipalsCommand` 负责处理身份验证，而 `authorized_keys` 文件仅用于特定情况，例如部署密钥。根据您的设置，仅靠 `AuthorizedPrincipalsCommand` 可能就足以满足典型用户的需求，这样 `authorized_keys` 文件就只用于自动化部署密钥访问。

要决定是否维护 `authorized_keys` 回退方案，请权衡典型用户的密钥数量（尤其是频繁续期的密钥）与部署密钥的数量。

<a id="other-security-caveats"></a>

## 其他安全注意事项

用户仍然可以通过手动将 SSH 公钥上传到其个人资料并依赖 `~/.ssh/authorized_keys` 回退方案来绕过 SSH 证书身份验证。[议题 23260](https://gitlab.com/gitlab-org/gitlab/-/issues/23260)中提出了一个用于阻止用户上传非部署密钥的 SSH 密钥的设置。

要自行强制执行此限制，请提供自定义的 `AuthorizedKeysCommand`。该命令会检查从 `gitlab-shell-authorized-keys-check` 返回的密钥 ID 是否为部署密钥，并拒绝所有非部署密钥。

<a id="disable-the-global-warning-about-users-lacking-ssh-keys"></a>

## 禁用关于用户缺少 SSH 密钥的全局警告

默认情况下，极狐GitLab 会向尚未将 SSH 密钥上传到个人资料的用户显示“在您将 SSH 密钥添加到个人资料之前，您将无法通过 SSH 拉取或推送代码仓库”的警告。此警告在配合 SSH 证书使用时适得其反，因为并不期望用户上传自己的密钥。

要全局禁用此警告：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **常规**。
1. 在**账户和限制**部分，清除**通知未上传 SSH 密钥的用户，在添加密钥之前他们无法通过 SSH 推送**复选框。

此设置是专门为配合 SSH 证书使用而添加的。您也可以在没有 SSH 证书的情况下将其关闭，以出于其他原因隐藏该警告。
