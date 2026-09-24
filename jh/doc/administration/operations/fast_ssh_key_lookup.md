---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
description: Configure a faster SSH authorization method for GitLab instances with many users.
title: SSH 密钥的快速查找
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

When the number of users grows, SSH operations become slow because OpenSSH performs a
linear search through the `authorized_keys` file to authenticate users.
This process requires significant time and disk I/O, which delays users attempting to
push or pull to a repository.
If users add or remove keys frequently, the operating system may not cache the
`authorized_keys` file, which causes repeated disk reads.

Instead of using the `authorized_keys` file, you can configure 极狐GitLab Shell to look up
SSH keys. It is faster because the lookup is indexed in the 极狐GitLab database.

> [!note]
> For standard (non-deploy key) users, consider using [SSH 证书](ssh_certificates.md).
> They are faster than database lookups, but are not a drop-in replacement for the `authorized_keys` file.

<a id="fast-lookup-is-required-for-geo"></a>

## Geo 需要快速查找

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Unlike [云原生极狐GitLab](https://gitlab.cn/docs/charts), by default Linux package installations
manage an `authorized_keys` file that is located in the `git` user's home directory. For most installations,
this file is located under `/var/opt/gitlab/.ssh/authorized_keys`. Use this command to locate the
`authorized_keys` on your system:

```shell
getent passwd git | cut -d: -f6 | awk '{print $1"/.ssh/authorized_keys"}'
```

The `authorized_keys` file contains all the public SSH keys for users allowed to access 极狐GitLab. However, to maintain a
single source of truth, [Geo](../geo/_index.md) must be configured to perform SSH fingerprint
lookups with database lookup.

When you [set up Geo](../geo/setup/_index.md), you must follow the steps below
for both the primary and secondary nodes. Do not select **Write to `authorized keys` file** on the
primary node, because it is reflected automatically on the secondary if database replication is working.

<a id="set-up-fast-lookup"></a>

## 设置快速查找

极狐GitLab Shell provides a way to authorize SSH users with a fast, indexed lookup
to the 极狐GitLab database. 极狐GitLab Shell uses the fingerprint of the SSH key to
check whether the user is authorized to access 极狐GitLab.

Fast lookup can be enabled with the following SSH servers:

- [`gitlab-sshd`](gitlab_sshd.md)
- OpenSSH

You can run both services simultaneously by using separate ports for each service.

<a id="with-gitlab-sshd"></a>

### 使用 `gitlab-sshd`

For setup information, see [`gitlab-sshd`](gitlab_sshd.md).
After `gitlab-sshd` is enabled, 极狐GitLab Shell and `gitlab-sshd` are configured
to use fast lookup automatically.

<a id="with-openssh"></a>

### 使用 OpenSSH

Prerequisites:

- OpenSSH 6.9 or later, because `AuthorizedKeysCommand` must
  accept a fingerprint. To check your version, run `sshd -V`.
- Administrator access.

To set up fast lookup with OpenSSH:

1. Add the following to your `sshd_config` file:

   ```plaintext
   Match User git    # 仅将 AuthorizedKeysCommands 应用于 git 用户
     AuthorizedKeysCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-keys-check git %u %k
     AuthorizedKeysCommandUser git
   Match all    # 结束匹配，设置再次应用于所有用户
   ```

   This file is usually located in:

   - Linux 软件包安装：`/etc/ssh/sshd_config`
   - Docker 安装：`/assets/sshd_config`
   - 自行编译安装：If you followed the instructions for
     [从源代码安装极狐GitLab Shell](../../install/self_compiled/_index.md#install-gitlab-shell), the command should be
     located at `/home/git/gitlab-shell/bin/gitlab-shell-authorized-keys-check`.
     Consider creating a wrapper script somewhere else because this command must be owned by `root`,
     and not be writable by a group or others.
     Also consider changing the ownership of this command as needed, but this might require temporary
     ownership changes during `gitlab-shell` upgrades.

1. Reload OpenSSH:

   ```shell
   # Debian 或 Ubuntu 安装
   sudo service ssh reload

   # CentOS 安装
   sudo service sshd reload
   ```

1. Confirm that SSH is working:

   1. Comment out your user's key in the `authorized_keys` file. To do this, start the line with `#`.
   1. From your local machine, attempt to pull a repository or run:

      ```shell
      ssh -T git@gitlab.example.com
      ```

      A successful pull or [欢迎消息](../../user/ssh.md#verify-your-ssh-connection)
      means that 极狐GitLab found the key in the database because the key is not present in the file.

If there are lookup failures, the `authorized_keys` file is still scanned.
Git SSH performance might still be slow for many users, as long as the large file exists.

To resolve this, you can disable writes to the `authorized_keys` file:

1. Confirm SSH works. This step is important because otherwise the file quickly becomes out-of-date.
1. Disable writes to the `authorized_keys` file:

   1. 在右上角，选择 **管理员**。
   1. 选择 **设置** > **网络**。
   1. 展开 **性能优化**。
   1. 清除 **使用 `authorized_keys` 文件验证 SSH 密钥** 复选框。
   1. 选择 **保存变更**。

1. Verify the change:

   1. Remove your SSH key in the UI.
   1. Add a new key.
   1. Try to pull a repository.

1. Back up and delete your `authorized_keys` file.
   The current users' keys are already present in the database, so there is no need for migration
   or for users to re-add their keys.

<a id="how-to-go-back-to-using-the-authorized-keys-file"></a>

### 如何恢复使用 `authorized_keys` 文件

This overview is brief. Refer to the previous instructions for more context.

1. Enable writes to the `authorized_keys` file.
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏中，选择 **设置** > **网络**。
   1. 展开 **性能优化**。
   1. 选中 **使用 `authorized_keys` 文件验证 SSH 密钥** 复选框。
1. [Rebuild the `authorized_keys` file](../raketasks/maintenance.md#rebuild-authorized_keys-file).
1. Remove the `AuthorizedKeysCommand` lines from `/etc/ssh/sshd_config` or from `/assets/sshd_config` if you are using Docker
   from a Linux package installation.
1. Reload `sshd`: `sudo service sshd reload`.

<a id="selinux-support"></a>

## SELinux 支持

极狐GitLab supports `authorized_keys` database lookups with [SELinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux).

Because the SELinux policy is static, 极狐GitLab doesn't support changing
internal web server ports. Administrators would have to create a special `.te`
file for the environment because it isn't generated dynamically.

<a id="additional-documentation"></a>

### 其他文档

Additional technical documentation for `gitlab-sshd` may be found in the
极狐GitLab Shell documentation.

<a id="troubleshooting"></a>

## 故障排除

<a id="ssh-traffic-slow-or-high-cpu-load"></a>

### SSH 流量慢或高 CPU 负载

If your SSH traffic is [slow](https://github.com/linux-pam/linux-pam/issues/270)
or causing high CPU load:

- Check the size of `/var/log/btmp`.
- Ensure it is rotated on a regular basis, or after reaching a certain size.

If this file is very large, 极狐GitLab SSH fast lookup can cause the bottleneck to be hit more frequently,
thus decreasing performance even further. Consider disabling
[在您的 `sshd_config` 中禁用 `UsePAM`](https://linux.die.net/man/5/sshd_config) to avoid reading `/var/log/btmp` altogether.

Running `strace` and `lsof` on a running `sshd: git` process returns debugging information.
To get an `strace` on an in-progress Git over SSH connection for IP `x.x.x.x`, run:

```plaintext
sudo strace -s 10000 -p $(sudo netstat -tp | grep x.x.x.x | egrep 'ssh.*: git' | sed -e 's/.*ESTABLISHED *//' -e 's#/.*##')
```

Or get an `lsof` for a running Git over SSH process:

```plaintext
sudo lsof -p $(sudo netstat -tp | egrep 'ssh.*: git' | head -1 | sed -e 's/.*ESTABLISHED *//' -e 's#/.*##')
```