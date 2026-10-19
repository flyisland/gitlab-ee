---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Linux 软件包实例升级
description: 升级 Linux 软件包实例时遇到的问题的解决方案。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为帮助进行故障排除，请运行以下命令。

```shell
sudo gitlab-ctl status
sudo gitlab-rake gitlab:check SANITIZE=true
```

有关以下内容的更多信息：

- 使用 `gitlab-ctl` 进行维护，请参阅[维护命令](https://gitlab.cn/docs/omnibus/maintenance/)。
- 使用 `gitlab-rake` 进行配置检查，请参阅
  [检查极狐GitLab 配置](../../administration/raketasks/maintenance.md#check-gitlab-configuration)。

<a id="no-new-version-found-after-upgrading-operating-system"></a>

## 升级操作系统后未找到新版本

升级极狐GitLab 之前，有时需要先升级操作系统。升级操作系统时，您可能还需要更新操作系统软件包管理器配置中的极狐GitLab 软件包源 URL。

如果您的软件包管理器未找到可用的升级，但本应有可用的升级，请重新添加极狐GitLab 软件包仓库。有关更多信息，请参阅[使用 Linux 软件包安装极狐GitLab](../../install/package/_index.md)的相关信息。

后续的极狐GitLab 升级将根据您升级后的操作系统进行获取。

<a id="500-errors-with-pgundefinedcolumn-error-message-in-logs"></a>

## 日志中出现 `PG::UndefinedColumn: ERROR:..` 消息的 500 错误

升级后，如果日志中开始出现 `500` 错误，并显示类似 `PG::UndefinedColumn: ERROR:...` 的消息，这些错误可能由以下原因引起：

- [数据库迁移](../background_migrations.md)尚未完成。请等待迁移完成。
- 数据库迁移已完成，但极狐GitLab 需要加载新的 schema。要加载新的 schema，
  请[重启极狐GitLab](../../administration/restart_gitlab.md)。

<a id="error-failed-to-connect-to-the-internal-gitlab-api"></a>

## 错误：Failed to connect to the internal GitLab API

如果在单独的 GitLab Pages 服务器上收到错误 `Failed to connect to the internal GitLab API`，
请参阅 [GitLab Pages 管理故障排除](../../administration/pages/troubleshooting.md#failed-to-connect-to-the-internal-gitlab-api)

<a id="an-error-occurred-during-the-signature-verification"></a>

## 签名验证期间发生错误

如果在运行 `apt-get update` 时收到此错误：

```plaintext
An error occurred during the signature verification
```

使用以下命令更新极狐GitLab 软件包服务器的 GPG 密钥：

```shell
[ -x /usr/bin/apt-key ] &&
    [ -s /etc/apt/trusted.gpg ] &&
    apt-key --keyring /etc/apt/trusted.gpg del packages@gitlab.com
curl --fail --silent --show-error \
     --output /etc/apt/trusted.gpg.d/gitlab.asc \
     --url "https://packages.gitlab.cn/repository/raw/gpg/public.gpg.key"
apt-get update
```

<a id="error-command-timed-out-after-3600s"></a>

## 错误：`Command timed out after 3600s`

如果数据库 schema 和数据变更（数据库迁移）必须运行超过一小时，升级将失败并出现 `timed out` 错误：

```plaintext
FATAL: Mixlib::ShellOut::CommandTimeout: rails_migration[gitlab-rails] (gitlab::database_migrations line 51)
had an error: Mixlib::ShellOut::CommandTimeout: bash[migrate gitlab-rails database]
(/opt/gitlab/embedded/cookbooks/cache/cookbooks/gitlab/resources/rails_migration.rb line 16)
had an error: Mixlib::ShellOut::CommandTimeout: Command timed out after 3600s:
```

要修复此错误：

1. 运行剩余的数据库迁移：

   ```shell
   sudo gitlab-rake db:migrate
   ```

   此命令可能需要很长时间才能完成。请使用 `screen` 或其他机制，确保
   在您的 SSH 会话断开时程序不会中断。

1. 完成升级：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 热重载 `puma` 和 `sidekiq` 服务：

   ```shell
   sudo gitlab-ctl hup puma
   sudo gitlab-ctl restart sidekiq
   ```

<a id="missing-asset-files"></a>

## 缺少资产文件

升级后，极狐GitLab 可能无法正确提供以下资产：

- 图片
- JavaScript
- 样式表

极狐GitLab 可能会生成 500 错误，或者 Web UI 可能无法正常渲染。

在横向扩展的极狐GitLab 环境中，如果负载均衡器后面的某一台 Web 服务器出现此问题，则该问题会间歇性发生。

[用于重新编译](../../administration/raketasks/maintenance.md#precompile-the-assets)资产的 Rake 任务不适用于从 `/opt/gitlab/embedded/service/gitlab-rails/public/assets` 提供预编译资产的 Linux 软件包安装。

以下各节概述了可能的原因和解决方案。

<a id="old-processes"></a>

### 旧进程

旧进程最可能的原因是旧的 Puma 进程仍在运行。旧的 Puma 进程可能会指示客户端从极狐GitLab 的先前版本请求资产文件。由于这些文件已不存在，因此会返回 HTTP 404 错误。

重启是确保这些旧 Puma 进程不再运行的最佳方式。或者，您可以：

1. 停止 Puma：

   ```shell
   gitlab-ctl stop puma
   ```

1. 检查是否有任何剩余的 Puma 进程，并将其终止：

   ```shell
   ps -ef | egrep 'puma[: ]'
   kill <processid>
   ```

1. 使用 `ps` 验证 Puma 进程已停止运行。
1. 启动 Puma

   ```shell
   gitlab-ctl start puma
   ```

<a id="duplicate-sprockets-files"></a>

### 重复的 sprockets 文件

编译后的资产文件在每个版本中都有唯一的文件名。sprockets 文件提供从应用程序代码中的文件名到唯一文件名的映射。

```plaintext
/opt/gitlab/embedded/service/gitlab-rails/public/assets/.sprockets-manifest*.json
```

确保只有一个 sprockets 文件。[Rails 使用第一个](https://github.com/rails/sprockets-rails/blob/118ce60b1ffeb7a85640661b014cd2ee3c4e3e56/lib/sprockets/railtie.rb#L201)。

Linux 软件包升级期间会运行重复 sprockets 文件检查：

```plaintext
GitLab discovered stale file(s) from the previous install that need to be cleaned up.
The following files need to be removed:

/opt/gitlab/embedded/service/gitlab-rails/public/assets/.sprockets-manifest-e16fdb7dd73cfdd64ed9c2cc0e35718a.json
```

解决此问题的选项包括：

- 如果您有软件包升级的输出，请移除指定的文件。然后重启 Puma：

  ```shell
  gitlab-ctl restart puma
  ```

- 如果您没有该消息，请执行重新安装以再次生成它。有关更多信息，请参阅
  [安装不完整](#incomplete-installation)。
- 移除所有 sprockets 文件，然后按照[安装不完整](#incomplete-installation)的说明操作。

<a id="incomplete-installation"></a>

### 安装不完整

安装不完整可能是缺少资产文件问题的原因。

验证软件包以确定是否存在此问题：

- 对于 Debian 发行版：

  ```shell
  apt-get install debsums
  debsums -c gitlab-ee
  ```

- 对于 Red Hat/SUSE (RPM) 发行版：

  ```shell
  rpm -V gitlab-ee
  ```

要重新安装软件包以修复安装不完整的问题：

1. 检查已安装的版本：

   - 对于 Debian 发行版：

     ```shell
     apt --installed list gitlab-ee
     ```

   - 对于 Red Hat/SUSE (RPM) 发行版：

     ```shell
     rpm -qa gitlab-ee
     ```

1. 重新安装软件包，并指定已安装的版本。例如 14.4.0 企业版：

   - 对于 Debian 发行版：

     ```shell
     apt-get install --reinstall gitlab-jh=14.4.0-jh.0
     ```

   - 对于 Red Hat/SUSE (RPM) 发行版：

     ```shell
     yum reinstall gitlab-jh-14.4.0
     ```

<a id="nginx-gzip-support-disabled"></a>

### NGINX Gzip 支持已禁用

检查 `nginx['gzip_enabled']` 是否已被禁用：

```shell
grep gzip /etc/gitlab/gitlab.rb
```

这可能会阻止某些资产被提供。请阅读相关议题中的[更多信息](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6087#note_558194395)。

<a id="activerecordlockwaittimeout-error-retrying-after-sleep"></a>

## ActiveRecord::LockWaitTimeout 错误，休眠后重试

在极少数情况下，Sidekiq 处于忙碌状态并锁定了迁移尝试更改的表。要解决此问题：

1. 将极狐GitLab 置于只读模式。
1. 停止 Sidekiq：

   ```shell
   gitlab-ctl stop sidekiq
   ```

<a id="gpg-signature-verification-error-bad-gpg-signature"></a>

## GPG 签名验证错误：Bad GPG signature

在运行 `yum update` 或 `dnf update` 时，您可能会收到以下错误：

```plaintext
Error: Failed to download metadata for repo 'gitlab_gitlab-ee-source': repomd.xml GPG signature verification error: Bad GPG signature
```

要解决此问题：

1. 运行 `dnf clean all`。
1. [获取最新的签名密钥](https://gitlab.cn/docs/omnibus/update/package_signatures/?tab=CentOS%2FOpenSUSE%2FSLES#fetch-latest-signing-key)。
1. 再次尝试升级。

如果在 `dnf clean all` 之后错误仍然存在，请手动移除受影响的仓库缓存目录。在此示例中：

1. 移除 `/var/cache/dnf/gitlab_gitlab-ee-source`。
1. 运行 `dnf makecache`。
