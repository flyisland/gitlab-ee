---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Linux 软件包配置独立的 Redis 服务器。此设置适用于不需要 Redis 复制或故障转移的小型极狐GitLab 安装。
title: 使用 Linux 软件包的独立 Redis
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

可以使用 Linux 软件包配置独立的 Redis 服务器。在此配置中，Redis 不进行扩展，并且是单点故障。不过，在扩展环境中，目标是让环境能够处理更多用户或提高吞吐量。Redis 本身通常很稳定，可以处理大量请求，因此只使用单个实例是可以接受的权衡。有关极狐GitLab 扩展选项的概览，请参阅[参考架构](../reference_architectures/_index.md)页面。

<a id="set-up-the-standalone-redis-instance"></a>

## 设置独立 Redis 实例

以下步骤是使用 Linux 软件包配置 Redis 服务器所需的最少步骤：

1. 通过 SSH 登录 Redis 服务器。
1. 使用极狐GitLab 下载页面中的步骤 1 和步骤 2，[下载并安装](https://gitlab.cn/install)您需要的 Linux
   软件包。不要完成下载页面上的任何其他步骤。
1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   ## Enable Redis and disable all other services
   ## https://docs.gitlab.com/omnibus/roles/
   roles ['redis_master_role']

   ## Redis configuration
   redis['bind'] = '0.0.0.0'
   redis['port'] = 6379
   redis['password'] = '<redis_password>'

   ## Disable automatic database migrations
   ## Only the primary GitLab application server should handle migrations
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 记下 Redis 节点的 IP 地址或主机名、端口和
   Redis 密码。在[配置极狐GitLab 应用服务器](#set-up-the-gitlab-rails-application-instance)时需要这些信息。

支持[高级配置选项](https://gitlab.cn/docs/omnibus/settings/redis/)，如有需要可以添加。

<a id="set-up-the-gitlab-rails-application-instance"></a>

## 设置 GitLab Rails 应用实例

在安装了极狐GitLab 的实例上：

1. 编辑 `/etc/gitlab/gitlab.rb` 文件并添加以下内容：

   ```ruby
   ## Disable Redis
   redis['enable'] = false

   gitlab_rails['redis_host'] = 'redis.example.com'
   gitlab_rails['redis_port'] = 6379

   ## Required if Redis authentication is configured on the Redis node
   gitlab_rails['redis_password'] = '<redis_password>'
   ```

1. 将更改保存到 `/etc/gitlab/gitlab.rb`。
1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="use-valkey-instead-of-redis"></a>

## 使用 Valkey 代替 Redis

您可以使用 [Valkey](https://valkey.io/) 作为 Redis 的直接替代品。
Valkey 使用与 Redis 相同的配置选项。

要在独立节点上使用 Valkey 代替 Redis：

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   ## Enable Redis and disable all other services
   ## https://docs.gitlab.com/omnibus/roles/
   roles ['redis_master_role']

   ## Switch to Valkey
   redis['backend'] = 'valkey'

   ## Redis configuration
   redis['bind'] = '0.0.0.0'
   redis['port'] = 6379
   redis['password'] = '<redis_password>'

   ## Disable automatic database migrations
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

GitLab Rails 应用配置保持不变。像配置 Redis 一样配置 `gitlab_rails['redis_host']`、
`gitlab_rails['redis_port']` 和 `gitlab_rails['redis_password']`。

<a id="known-issues"></a>

### 已知问题

- 由于已知的[议题 589642](https://gitlab.com/gitlab-org/gitlab/-/issues/589642)，管理区域会错误地报告 Valkey 版本。此问题
  不会影响所安装的 Valkey 版本或其运行方式。

<a id="troubleshooting"></a>

## 故障排除

请参阅 [Redis 故障排除指南](troubleshooting.md)。
