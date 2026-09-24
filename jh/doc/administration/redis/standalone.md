---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure a standalone Redis server with the Linux package. Use this setup for small GitLab installations that do not require Redis replication or failover.
title: 使用 Linux 安装包配置独立 Redis
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Linux 安装包可用于配置独立 Redis 服务器。
在此配置中，Redis 不进行扩展，并且是单点故障。然而，在扩展环境中，目标是让环境能够处理更多用户或提高吞吐量。Redis 本身通常很稳定，可以处理许多请求，因此仅使用单个实例是可以接受的权衡。有关极狐GitLab 扩展选项的概述，请参见[参考架构](../reference_architectures/_index.md)页面。

<a id="set-up-the-standalone-redis-instance"></a>

## 设置独立 Redis 实例

以下步骤是使用 Linux 安装包配置 Redis 服务器所需的最低配置：

1. 通过 SSH 登录 Redis 服务器。
1. [下载并安装](https://gitlab.cn/install/)您需要的 Linux 安装包，使用极狐GitLab 下载页面中的**步骤 1 和 2**。
   请勿完成下载页面上的任何其他步骤。

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   ## 启用 Redis 并禁用所有其他服务
   ## https://gitlab.cn/docs/omnibus/roles/
   roles ['redis_master_role']

   ## Redis 配置
   redis['bind'] = '0.0.0.0'
   redis['port'] = 6379
   redis['password'] = '<redis_password>'

   ## 禁用自动数据库迁移
   ## 只有主极狐GitLab 应用服务器应处理迁移
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。
1. 记下 Redis 节点的 IP 地址或主机名、端口和 Redis 密码。这些在[配置极狐GitLab 应用服务器](#set-up-the-gitlab-rails-application-instance)时是必需的。

[高级配置选项](https://gitlab.cn/docs/omnibus/settings/redis/)受支持，如有需要可以添加。

<a id="set-up-the-gitlab-rails-application-instance"></a>

## 设置极狐GitLab Rails 应用实例

在安装了极狐GitLab 的实例上：

1. 编辑 `/etc/gitlab/gitlab.rb` 文件并添加以下内容：

   ```ruby
   ## 禁用 Redis
   redis['enable'] = false

   gitlab_rails['redis_host'] = 'redis.example.com'
   gitlab_rails['redis_port'] = 6379

   ## 如果 Redis 节点上配置了 Redis 认证，则为必填项
   gitlab_rails['redis_password'] = '<redis_password>'
   ```

1. 将更改保存到 `/etc/gitlab/gitlab.rb`。

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。

<a id="use-valkey-instead-of-redis"></a>

## 使用 Valkey 替代 Redis

{{< history >}}

- 在极狐GitLab 18.9 中作为测试版引入。
- 在极狐GitLab 19.0 中 GA。

{{< /history >}}

您可以使用 [Valkey](https://valkey.io/) 作为 Redis 的直接替代品。
Valkey 使用与 Redis 相同的配置选项。

要在独立节点上使用 Valkey 替代 Redis：

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   ## 启用 Redis 并禁用所有其他服务
   ## https://gitlab.cn/docs/omnibus/roles/
   roles ['redis_master_role']

   ## 切换到 Valkey
   redis['backend'] = 'valkey'

   ## Redis 配置
   redis['bind'] = '0.0.0.0'
   redis['port'] = 6379
   redis['password'] = '<redis_password>'

   ## 禁用自动数据库迁移
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。

极狐GitLab Rails 应用配置保持不变。像配置 Redis 一样配置 `gitlab_rails['redis_host']`、`gitlab_rails['redis_port']` 和 `gitlab_rails['redis_password']`。

<a id="known-issues"></a>

### 已知问题

- 由于已知问题 589642，管理区域报告 Valkey 版本不正确。此问题不影响已安装的 Valkey 版本或其功能。

<a id="troubleshooting"></a>

## 故障排除

参见 [Redis 故障排除指南](troubleshooting.md)。