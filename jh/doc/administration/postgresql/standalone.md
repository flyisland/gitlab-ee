---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 适用于 Linux 软件包安装的独立 PostgreSQL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您希望将数据库服务与极狐GitLab 应用服务器分开托管，可以使用 Linux 软件包中一同打包的 PostgreSQL 二进制文件来实现。作为[最多支持 40 RPS 或 2,000 名用户的参考架构](../reference_architectures/2k_users.md)的一部分，推荐采用此方式。

<a id="setting-it-up"></a>

## 进行设置

1. 通过 SSH 登录到 PostgreSQL 服务器。
1. 使用极狐GitLab 下载页面中的步骤 1 和步骤 2，[下载并安装](https://gitlab.cn/install)您需要的 Linux 软件包。不要完成下载页面上的任何其他步骤。
1. 为 PostgreSQL 生成密码哈希。这里假设您使用默认用户名 `gitlab`（推荐）。该命令会要求输入密码并确认。在下一步中，将这条命令输出的值用作 `POSTGRESQL_PASSWORD_HASH`的值。

   ```shell
   sudo gitlab-ctl pg-password-md5 gitlab
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容，同时相应地更新占位符的值。

   - `POSTGRESQL_PASSWORD_HASH` - 上一步输出的值
   - `APPLICATION_SERVER_IP_BLOCKS` - 以空格分隔的 IP 子网或 IP 地址列表，这些是连接到数据库的极狐GitLab 应用服务器。示例：`%w(123.123.123.123/32 123.123.123.234/32)`

   ```ruby
   # Disable all components except PostgreSQL
   roles(['postgres_role'])
   prometheus['enable'] = false
   alertmanager['enable'] = false
   pgbouncer_exporter['enable'] = false
   redis_exporter['enable'] = false
   gitlab_exporter['enable'] = false

   postgresql['listen_address'] = '0.0.0.0'
   postgresql['port'] = 5432

   # Replace POSTGRESQL_PASSWORD_HASH with a generated md5 value
   postgresql['sql_user_password'] = 'POSTGRESQL_PASSWORD_HASH'

   # Replace APPLICATION_SERVER_IP_BLOCKS with Network Address (XXX.XXX.XXX.XXX/YY)
   postgresql['trust_auth_cidr_addresses'] = %w(APPLICATION_SERVER_IP_BLOCKS)

   # Disable automatic database migrations
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 记下 PostgreSQL 节点的主机名或 IP 地址、端口以及明文密码。稍后配置极狐GitLab 应用服务器时需要用到这些信息。
1. [启用监控](replication_and_failover.md#enable-monitoring)

支持高级配置选项，如有需要可以添加。
