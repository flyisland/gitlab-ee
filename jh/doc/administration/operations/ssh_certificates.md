---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 OpenSSH AuthorizedPrincipalsCommand 进行用户查找
description: 配置 SSH 证书认证的授权 principals
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

对于私有化部署的极狐GitLab 实例，默认的 SSH 认证要求用户先上传他们的 SSH 公钥才能使用 SSH 传输。

在集中式环境（例如企业环境）中，此要求可能会产生运维开销。当 SSH 密钥是临时的（例如在签发后 24 小时过期）时，这一点尤为突出。

在这些设置中，外部自动化流程必须不断将新密钥上传到极狐GitLab。

> [!warning]
> 需要 OpenSSH 6.9 或更高版本，因为 `AuthorizedKeysCommand` 必须能够接受指纹。请检查服务器上的 OpenSSH 版本。

如果您使用 `gitlab-sshd` 而不是 OpenSSH，可以直接在 `gitlab-sshd` 配置文件中配置实例级别的 SSH 证书认证，不需要 OpenSSH。有关更多信息，请参见[使用 `gitlab-sshd` 的实例级别 SSH 证书](gitlab_sshd_ssh_certificates.md)。

如果您是 JihuLab.com 群组所有者，则应该改用群组范围的 SSH 证书功能，该功能使用极狐GitLab SSH 服务器，并且不需要 OpenSSH 配置。有关更多信息，请参见[管理群组 SSH 证书](../../user/group/ssh_certificates.md)。

<a id="why-use-openssh-certificates"></a>

## 为什么使用 OpenSSH 证书？

使用 OpenSSH 证书时，关于哪个极狐GitLab 用户拥有该密钥的信息被编码在密钥本身中。OpenSSH 保证用户无法伪造这一点，因为他们需要访问私有 CA 签名密钥。

正确设置后，这完全消除了将用户 SSH 密钥上传到极狐GitLab 的要求。

<a id="setting-up-ssh-certificate-lookup-via-gitlab-shell"></a>

## 通过 GitLab Shell 设置 SSH 证书查找

如何全面设置 SSH 证书超出了本文档的范围。请参阅 [OpenSSH 的 `PROTOCOL.certkeys`](https://cvsweb.openbsd.org/cgi-bin/cvsweb/src/usr.bin/ssh/PROTOCOL.certkeys?annotate=HEAD) 了解其工作原理，例如 [RedHat 的有关文档](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/sec-using_openssh_certificate_authentication)。

我们假设您已经设置了 SSH 证书，并且已经将 CA 的 `TrustedUserCAKeys` 添加到了 `sshd_config` 中，例如：

```plaintext
TrustedUserCAKeys /etc/security/mycompany_user_ca.pub
```

通常，在这种设置下，`TrustedUserCAKeys` 不会限制在 `Match User git` 范围内，因为它也会用于登录极狐GitLab 服务器本身的系统登录，但您的设置可能会有所不同。如果 CA 仅用于极狐GitLab，请考虑将其放在 `Match User git` 部分（如下所述）。

该 CA 签发的 SSH 证书 **必须** 有一个与用户在极狐GitLab 上的用户名对应的 "密钥 ID"，例如（为简洁省略了一些输出）：

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

从技术上讲，这并非绝对正确，例如，如果它是一个 SSH 证书，您通常以 `prod-aearnfjord` 用户身份登录服务器，它可以是 `prod-aearnfjord`，但之后您必须指定自己的 `AuthorizedPrincipalsCommand` 来进行映射，而不是使用我们提供的默认命令。

重要的是，`AuthorizedPrincipalsCommand` 必须能够将 "密钥 ID" 映射到极狐GitLab 用户名，因为我们提供的默认命令假定两者之间存在一对一的映射。这样做的全部意义在于，允许我们从密钥本身提取极狐GitLab 用户名，而不是依赖于默认的公钥到用户名的映射。

然后，在您的 `sshd_config` 中为 `git` 用户设置 `AuthorizedPrincipalsCommand`。希望您可以使用极狐GitLab 自带的默认命令：

```plaintext
Match User git
    AuthorizedPrincipalsCommandUser root
    AuthorizedPrincipalsCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-principals-check %i sshUsers
```

此命令会发出类似以下内容的输出：

```shell
command="/opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell username-{KEY_ID}",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty {PRINCIPAL}
```

其中 `{KEY_ID}` 是传递给脚本的 `%i` 参数（例如 `aeanfjord`），而 `{PRINCIPAL}` 是传递给它的主体（例如 `sshUsers`）。

您需要自定义其中的 `sshUsers` 部分。它应该是所有可以登录极狐GitLab 的用户的密钥中保证包含的某个主体，或者您必须提供一个主体列表，其中至少有一个主体存在于用户密钥中，例如：

```plaintext
    [...]
    AuthorizedPrincipalsCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-principals-check %i sshUsers windowsUsers
```

<a id="principals-and-security"></a>

## 主体与安全

您可以提供任意数量的主体，它们会转换为多行 `authorized_keys` 输出，正如 `sshd_config(5)` 中的 `AuthorizedPrincipalsFile` 文档所述。

通常，在 OpenSSH 中使用 `AuthorizedKeysCommand` 时，主体是允许登录该服务器的某个 "组"。但是，在极狐GitLab 中，它仅用于满足 OpenSSH 的要求，我们实际上只关心 "密钥 ID" 是否正确。一旦提取了该 ID，极狐GitLab 就会对该用户执行自己的 ACL（例如，该用户可以访问哪些项目）。

因此，您可以过于宽松地接受主体。例如，如果用户无权访问极狐GitLab，则会产生一条错误消息，指出这是一个无效用户。

<a id="interaction-with-the-authorized_keys-file"></a>

## 与 `authorized_keys` 文件的交互

如果按照前述方式设置了 SSH 证书，它们可以与 `authorized_keys` 文件配合使用，以便 `authorized_keys` 文件用作后备。

当 `AuthorizedPrincipalsCommand` 无法认证用户时，OpenSSH 会转而检查 `~/.ssh/authorized_keys` 文件或使用 `AuthorizedKeysCommand`。因此，您可能仍需要结合 SSH 证书使用[在数据库中快速查找已授权的 SSH 密钥](fast_ssh_key_lookup.md)。

对于大多数用户而言，SSH 证书通过使用 `AuthorizedPrincipalsCommand` 来处理认证，而 `~/.ssh/authorized_keys` 文件主要作为部署密钥等特定情况的后备。但是，根据您的设置，您可能会发现仅对典型用户使用 `AuthorizedPrincipalsCommand` 就足够了。在这种情况下，`authorized_keys` 文件仅在自动化部署密钥访问或其他特定场景下才需要。

考虑典型用户的密钥数量（尤其是如果它们频繁更新）与部署密钥之间的平衡，以帮助您确定是否有必要为您的环境维护 `authorized_keys` 后备。

<a id="other-security-caveats"></a>

## 其他安全注意事项

用户仍然可以通过手动将 SSH 公钥上传到其个人资料来绕过 SSH 证书认证，依靠 `~/.ssh/authorized_keys` 后备来认证它。

有一个开放的议题，旨在添加一个设置，以阻止用户上传非部署密钥的 SSH 密钥。

您可以自行构建检查来强制执行此限制。例如，提供一个自定义的 `AuthorizedKeysCommand`，它检查从 `gitlab-shell-authorized-keys-check` 返回的发现的 key-ID 是否为部署密钥（所有非部署密钥都应被拒绝）。

<a id="disabling-the-global-warning-about-users-lacking-ssh-keys"></a>

## 禁用关于用户缺少 SSH 密钥的全局警告

默认情况下，极狐GitLab 会向尚未将 SSH 密钥上传到其个人资料的用户显示警告：“您将无法通过 SSH 拉取或推送项目代码”。

使用 SSH 证书时，这是适得其反的，因为不期望用户上传自己的密钥。

要全局禁用此警告，请转到“应用设置 -> 账户和限制设置”，然后禁用“显示用户添加 SSH 密钥消息”设置。

此设置专门为使用 SSH 证书而添加，但如果您出于其他原因想隐藏该警告，也可以在不使用它们的情况下将其关闭。