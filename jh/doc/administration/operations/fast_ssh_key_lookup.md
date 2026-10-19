---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
description: 为拥有大量用户的极狐GitLab 实例配置更快的 SSH 授权方法。
title: SSH 密钥快速查找
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当用户数量增长时，SSH 操作会变慢，因为 OpenSSH 会线性搜索 `authorized_keys` 文件来认证用户。此过程需要大量时间和磁盘 I/O，从而延迟用户向代码仓库推送或拉取的操作。如果用户频繁添加或删除密钥，操作系统可能不会缓存 `authorized_keys` 文件，从而导致重复的磁盘读取。

除了使用 `authorized_keys` 文件，您还可以配置 GitLab Shell 来查找 SSH 密钥。这种方式更快，因为查找在极狐GitLab 数据库中建立了索引。

> [!note]
> 对于标准用户（非部署密钥），请考虑使用 [SSH 证书](ssh_certificates.md)。
> 它们比数据库查找更快，但不能直接替代 `authorized_keys` 文件。

<a id="fast-lookup-is-required-for-geo"></a>

## Geo 需要快速查找

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

与 [Cloud Native GitLab](https://gitlab.cn/docs/charts/) 不同，默认情况下 Linux 软件包安装
会管理位于 `git` 用户主目录中的 `authorized_keys` 文件。对于大多数安装，该文件位于 `/var/opt/gitlab/.ssh/authorized_keys`。使用以下命令在您的系统上定位
`authorized_keys`：

```shell
getent passwd git | cut -d: -f6 | awk '{print $1"/.ssh/authorized_keys"}'
```

`authorized_keys` 文件包含所有允许访问极狐GitLab 的用户的公共 SSH 密钥。但是，为了维护单一事实来源，必须将 [Geo](../geo/_index.md) 配置为使用数据库查找来执行 SSH 指纹查找。

当您[设置 Geo](../geo/setup/_index.md) 时，必须为主节点和从节点执行以下步骤。请勿在主节点上选择**写入 `authorized keys` 文件**，因为如果数据库复制正常工作，该更改会自动反映到从节点上。

<a id="set-up-fast-lookup"></a>

## 设置快速查找

GitLab Shell 提供了一种通过对极狐GitLab 数据库进行快速、带索引的查找
来授权 SSH 用户的方式。GitLab Shell 使用 SSH 密钥的指纹
来检查用户是否有权访问极狐GitLab。

可以使用以下 SSH 服务器启用快速查找：

- [`gitlab-sshd`](gitlab_sshd.md)
- OpenSSH

您可以通过为每个服务使用不同的端口来同时运行这两个服务。

<a id="with-gitlab-sshd"></a>

### 使用 `gitlab-sshd`

有关设置信息，请参阅 [`gitlab-sshd`](gitlab_sshd.md)。
启用 `gitlab-sshd` 后，GitLab Shell 和 `gitlab-sshd` 会自动配置
为使用快速查找。

<a id="with-openssh"></a>

### 使用 OpenSSH

先决条件：

- OpenSSH 6.9 或更高版本，因为 `AuthorizedKeysCommand` 必须
  接受指纹。要检查您的版本，请运行 `sshd -V`。
- 管理员访问权限。

要使用 OpenSSH 设置快速查找：

1. 将以下内容添加到您的 `sshd_config` 文件中：

   ```plaintext
   Match User git    # Apply the AuthorizedKeysCommands to the git user only
     AuthorizedKeysCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-keys-check git %u %k
     AuthorizedKeysCommandUser git
   Match all    # End match, settings apply to all users again
   ```

   该文件通常位于：

   - Linux 软件包安装：`/etc/ssh/sshd_config`
   - Docker 安装：`/assets/sshd_config`
   - 自编译安装：如果您按照
     [从源代码安装 GitLab Shell](../../install/self_compiled/_index.md#install-gitlab-shell)的说明操作，该命令应
     位于 `/home/git/gitlab-shell/bin/gitlab-shell-authorized-keys-check`。
     请考虑在其他位置创建包装脚本，因为此命令必须由 `root` 拥有，
     且不能被用户组或其他用户写入。
     另请考虑根据需要更改此命令的所有权，但这可能需要在 `gitlab-shell` 升级期间临时
     更改所有权。

1. 重新加载 OpenSSH：

   ```shell
   # Debian or Ubuntu installations
   sudo service ssh reload

   # CentOS installations
   sudo service sshd reload
   ```

1. 确认 SSH 正常工作：

   1. 在 `authorized_keys` 文件中注释掉您用户的密钥。为此，请在该行开头添加 `#`。
   1. 从您的本地机器尝试拉取代码仓库，或运行：

      ```shell
      ssh -T git@gitlab.example.com
      ```

      成功拉取或出现[欢迎消息](../../user/ssh.md#verify-your-ssh-connection)
      意味着极狐GitLab 在数据库中找到了该密钥，因为该密钥不在文件中。

如果存在查找失败，仍会扫描 `authorized_keys` 文件。只要该大文件存在，对于大量用户而言 Git SSH 性能可能仍然很慢。

要解决此问题，您可以禁用对 `authorized_keys` 文件的写入：

1. 确认 SSH 正常工作。此步骤很重要，否则该文件会很快过时。
1. 禁用对 `authorized_keys` 文件的写入：

   1. 在右上角，选择**管理员**。
   1. 选择**设置** > **网络**。
   1. 展开**性能优化**。
   1. 清除**使用 `authorized_keys` 文件认证 SSH 密钥**复选框。
   1. 选择**保存更改**。

1. 验证更改：

   1. 在 UI 中移除您的 SSH 密钥。
   1. 添加一个新密钥。
   1. 尝试拉取代码仓库。

1. 备份并删除您的 `authorized_keys` 文件。
   当前用户的密钥已存在于数据库中，因此无需迁移，
   用户也无需重新添加其密钥。

<a id="how-to-go-back-to-using-the-authorized_keys-file"></a>

### 如何恢复使用 `authorized_keys` 文件

本概述较为简略。有关更多背景信息，请参阅前面的说明。

1. 启用对 `authorized_keys` 文件的写入。
   1. 在右上角，选择**管理员**。
   1. 在左侧边栏中，选择**设置** > **网络**。
   1. 展开**性能优化**。
   1. 选中**使用 `authorized_keys` 文件认证 SSH 密钥**复选框。
1. [重建 `authorized_keys` 文件](../raketasks/maintenance.md#rebuild-authorized_keys-file)。
1. 从 `/etc/ssh/sshd_config`中移除 `AuthorizedKeysCommand` 行；如果您在 Linux 软件包安装中使用 Docker，
   则从 `/assets/sshd_config`中移除。
1. 重新加载 `sshd`：`sudo service sshd reload`。

<a id="selinux-support"></a>

## SELinux 支持

极狐GitLab 支持使用 [SELinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux) 进行 `authorized_keys` 数据库查找。

由于 SELinux 策略是静态的，极狐GitLab 不支持更改内部 Web 服务器端口。管理员必须为环境创建特殊的 `.te` 文件，因为它不是动态生成的。

<a id="additional-documentation"></a>

### 其他文档

有关 `gitlab-sshd`的其他技术文档可在
GitLab Shell 文档中找到。

<a id="troubleshooting"></a>

## 故障排除

<a id="ssh-traffic-slow-or-high-cpu-load"></a>

### SSH 流量缓慢或 CPU 负载高

如果您的 SSH 流量[缓慢](https://github.com/linux-pam/linux-pam/issues/270)或导致 CPU 负载高：

- 检查 `/var/log/btmp`的大小。
- 确保定期轮转该文件，或在达到特定大小后轮转。

如果此文件非常大，极狐GitLab SSH 快速查找会导致更频繁地触及瓶颈，从而进一步降低性能。请考虑[禁用 `UsePAM`（在 `sshd_config` 中）](https://linux.die.net/man/5/sshd_config)，以完全避免读取 `/var/log/btmp`。

对正在运行的 `sshd: git` 进程运行 `strace` 和 `lsof` 会返回调试信息。要获取 IP 为 `x.x.x.x`的进行中 Git over SSH 连接的 `strace`，请运行：

```plaintext
sudo strace -s 10000 -p $(sudo netstat -tp | grep x.x.x.x | egrep 'ssh.*: git' | sed -e 's/.*ESTABLISHED *//' -e 's#/.*##')
```

或获取正在运行的 Git over SSH 进程的 `lsof`：

```plaintext
sudo lsof -p $(sudo netstat -tp | egrep 'ssh.*: git' | head -1 | sed -e 's/.*ESTABLISHED *//' -e 's#/.*##')
```
