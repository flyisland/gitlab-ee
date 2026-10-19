---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 配置 SSH 密钥限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

`ssh-keygen` 允许用户创建位数低至 768 位的 RSA 密钥，这远低于美国 NIST 等标准组织推荐的密钥长度，因此并不安全。一些部署极狐GitLab 的组织需要强制实施最小密钥强度，以满足内部安全策略或监管合规要求。

同样，极狐GitLab 强烈建议使用 ED25519、ED25519_SK、ECDSA、ECDSA_SK 或 RSA，而不是较旧的 DSA。管理员应认真考虑限制允许的 SSH 密钥算法，以维护安全性。

极狐GitLab 允许您限制允许使用的 SSH 密钥技术，并为每种技术指定最小密钥长度。

先决条件：

- 管理员访问权限。

要配置 SSH 密钥限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性与访问控制**，为每种密钥类型设置所需的值：
   - **RSA SSH 密钥**。
   - **DSA SSH 密钥**。
   - **ECDSA SSH 密钥**。
   - **ED25519 SSH 密钥**。
   - **ECDSA_SK SSH 密钥**。
   - **ED25519_SK SSH 密钥**。
1. 选择**保存更改**。

如果对任何密钥类型施加了限制，用户将无法上传不符合要求的新 SSH 密钥。任何不符合要求的现有密钥将被禁用但不会被移除，用户也无法使用它们拉取或推送代码。

如果您有受限制的密钥，在个人资料的 **SSH 密钥**部分会显示一个警告图标（{{< icon name="warning" >}}）。要了解该密钥为何受限制，请将鼠标悬停在该图标上。

<a id="default-settings"></a>

## 默认设置

默认情况下，JihuLab.com 和极狐GitLab 私有化部署针对[支持的密钥类型](../user/ssh.md#supported-ssh-key-types)的设置如下：

- 禁止使用 DSA SSH 密钥。
- 允许使用 RSA SSH 密钥。
- 允许使用 ECDSA SSH 密钥。
- 允许使用 ED25519 SSH 密钥。
- 允许使用 ECDSA_SK SSH 密钥。
- 允许使用 ED25519_SK SSH 密钥。

<a id="override-ssh-settings-on-the-gitlab-server"></a>

## 在极狐GitLab 服务器上覆盖 SSH 设置

极狐GitLab 与系统安装的 SSH 守护进程集成，并指定一个用户（通常名为 `git`），所有访问请求都通过该用户处理。通过 SSH 连接到极狐GitLab 服务器的用户，其身份由 SSH 密钥而非用户名来识别。

在极狐GitLab 服务器上执行的 SSH 客户端操作均以该用户身份运行。您可以修改此 SSH 配置。例如，您可以为该用户指定一个私有 SSH 密钥，用于身份验证请求。但是，这种做法不受支持，并且强烈不建议这样做，因为它会带来重大的安全风险。

极狐GitLab 会检查此情况，如果您的服务器以此方式配置，会引导您查看本节。例如：

```shell
$ gitlab-rake gitlab:check

Git user has default SSH configuration? ... no
  Try fixing it:
  mkdir ~/gitlab-check-backup-1504540051
  sudo mv /var/lib/git/.ssh/id_rsa ~/gitlab-check-backup-1504540051
  sudo mv /var/lib/git/.ssh/id_rsa.pub ~/gitlab-check-backup-1504540051
  For more information see:
  doc/user/ssh.md#overriding-ssh-settings-on-the-gitlab-server
  Please fix the error above and rerun the checks.
```

> [!warning]
> 请尽快移除自定义配置。这些自定义设置
> 明确不受支持，并且可能随时停止工作。

<a id="verify-gitlab-ssh-ownership-and-permissions"></a>

## 验证极狐GitLab SSH 所有权和权限

极狐GitLab SSH 文件夹和文件必须具有以下权限：

- 文件夹 `/var/opt/gitlab/.ssh/` 必须由 `git` 群组和 `git` 用户拥有，权限设置为 `700`。
- `authorized_keys` 文件的权限必须设置为 `600`。
- `authorized_keys.lock` 文件的权限必须设置为 `644`。

要验证这些权限是否正确，请运行以下命令：

```shell
stat -c "%a %n" /var/opt/gitlab/.ssh/.
```

<a id="set-permissions"></a>

### 设置权限

如果权限不正确，请登录应用服务器并运行：

```shell
cd /var/opt/gitlab/
chown git:git /var/opt/gitlab/.ssh/
chmod 700  /var/opt/gitlab/.ssh/
chmod 600  /var/opt/gitlab/.ssh/authorized_keys
chmod 644  /var/opt/gitlab/.ssh/authorized_keys.lock
```
