---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 配置 SSH 密钥限制
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: 私有化部署

{{< /details >}}

`ssh-keygen` 允许用户创建低至 768 位的 RSA 密钥，这远低于美国 NIST 等标准组织推荐的密钥大小，并不安全。一些部署极狐GitLab 的组织需要强制执行最低密钥强度，以满足内部安全策略或监管合规要求。

同样，极狐GitLab 强烈建议使用 ED25519、ED25519_SK、ECDSA、ECDSA_SK 或 RSA，而非较旧的 DSA。管理员应认真考虑限制允许的 SSH 密钥算法以维护安全。

极狐GitLab 允许您限制允许的 SSH 密钥技术，并为每种技术指定最小密钥长度。

前提条件：

- 管理员访问权限。

要配置 SSH 密钥限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性与访问控制**，并为每种密钥类型设置所需的值：
   - **RSA SSH 密钥**。
   - **DSA SSH 密钥**。
   - **ECDSA SSH 密钥**。
   - **ED25519 SSH 密钥**。
   - **ECDSA_SK SSH 密钥**。
   - **ED25519_SK SSH 密钥**。
1. 选择 **保存更改**。

如果对任何密钥类型施加了限制，用户将无法上传不符合要求的新 SSH 密钥。任何不符合要求的现有密钥将被禁用但不会被删除，用户无法使用它们拉取或推送代码。

如果您有受限的密钥，在个人资料的 **SSH 密钥** 部分会显示一个警告图标（{{< icon name="warning" >}}）。要了解该密钥受限的原因，请将鼠标悬停在图标上。

## 默认设置

<a id="default-settings"></a>

默认情况下，JihuLab.com 和极狐GitLab 私有化部署对[支持的密钥类型](../user/ssh.md#supported-ssh-key-types)的设置如下：

- DSA SSH 密钥被禁止。
- RSA SSH 密钥被允许。
- ECDSA SSH 密钥被允许。
- ED25519 SSH 密钥被允许。
- ECDSA_SK SSH 密钥被允许。
- ED25519_SK SSH 密钥被允许。

## 覆盖极狐GitLab 服务器上的 SSH 设置

<a id="override-ssh-settings-on-the-gitlab-server"></a>

极狐GitLab 与系统安装的 SSH 守护进程集成，并指定一个用户（通常名为 `git`）来处理所有访问请求。通过 SSH 连接到极狐GitLab 服务器的用户通过其 SSH 密钥而非用户名进行身份识别。

在极狐GitLab 服务器上执行的 SSH 客户端操作均以该用户身份运行。您可以修改此 SSH 配置。例如，您可以指定一个私钥供该用户用于身份验证请求。然而，这种做法不受支持且强烈不建议，因为它会带来严重的安全风险。

极狐GitLab 会检查此情况，如果您的服务器以此方式配置，会将您引导至本节。例如：

```shell
$ gitlab-rake gitlab:check

Git 用户是否有默认 SSH 配置？ ... 否
  尝试修复：
  mkdir ~/gitlab-check-backup-1504540051
  sudo mv /var/lib/git/.ssh/id_rsa ~/gitlab-check-backup-1504540051
  sudo mv /var/lib/git/.ssh/id_rsa.pub ~/gitlab-check-backup-1504540051
  更多信息请参见：
  doc/user/ssh.md#overriding-ssh-settings-on-the-gitlab-server
  请修复上述错误并重新运行检查。
```

> [!warning]
> 请尽快移除自定义配置。这些自定义明确不受支持，且可能随时停止工作。

## 验证极狐GitLab SSH 所有权和权限

<a id="verify-gitlab-ssh-ownership-and-permissions"></a>

极狐GitLab SSH 文件夹和文件必须具有以下权限：

- 文件夹 `/var/opt/gitlab/.ssh/` 必须由 `git` 组和 `git` 用户拥有，权限设置为 `700`。
- `authorized_keys` 文件必须具有权限 `600`。
- `authorized_keys.lock` 文件必须具有权限 `644`。

要验证这些权限是否正确，请运行以下命令：

```shell
stat -c "%a %n" /var/opt/gitlab/.ssh/.
```

### 设置权限

<a id="set-permissions"></a>

如果权限不正确，请登录应用服务器并运行：

```shell
cd /var/opt/gitlab/
chown git:git /var/opt/gitlab/.ssh/
chmod 700  /var/opt/gitlab/.ssh/
chmod 600  /var/opt/gitlab/.ssh/authorized_keys
chmod 644  /var/opt/gitlab/.ssh/authorized_keys.lock
```