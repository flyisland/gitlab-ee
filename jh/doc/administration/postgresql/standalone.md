---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Linux 包安装的独立 PostgreSQL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果你希望将数据库服务与 极狐GitLab 应用服务器分开托管，你可以使用随 Linux 安装包一起打包的 PostgreSQL 二进制文件来实现。这是我们[参考架构（最高支持 40 RPS 或 2,000 用户）](../reference_architectures/2k_users.md) 的一部分，推荐使用。

<a id="setting-it-up"></a>

设置

1. 通过 SSH 登录到 PostgreSQL 服务器。
1. [下载并安装](https://gitlab.cn/install/) 你需要的 Linux 安装包，使用 极狐GitLab 下载页面上的步骤 1 和 2。不要执行下载页面上的其他任何步骤。
1. 为 PostgreSQL 生成密码哈希值。这里假设你使用的是默认用户名 `gitlab`（推荐）。该命令会要求输入密码并确认。请将此命令输出的值用作下一步中的 `POSTGRESQL_PASSWORD_HASH` 值。

   ```shell
   sudo gitlab-ctl pg-password-md5 gitlab
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容，适当更新占位符值。

   - `POSTGRESQL_PASSWORD_HASH` - 上一步输出的值
   - `APPLICATION_SERVER_IP_BLOCKS` - 以空格分隔的 IP 子网或 IP 地址列表，代表连接到数据库的 极狐GitLab 应用服务器。示例：`%w(123.123.123.123/32 123.123.123.234/32)`

   ```ruby
   # 禁用除 PostgreSQL 之外的所有组件
   roles(['postgres_role'])
   prometheus['enable'] = false
   alertmanager['enable'] = false
   pgbouncer_exporter['enable'] = false
   redis_exporter['enable'] = false
   gitlab_exporter['enable'] = false

   postgresql['listen_address'] = '0.0.0.0'
   postgresql['port'] = 5432

   # 将 POSTGRESQL_PASSWORD_HASH 替换为生成的 md5 值
   postgresql['sql_user_password'] = 'POSTGRESQL_PASSWORD_HASH'

   # 将 APPLICATION_SERVER_IP_BLOCKS 替换为网络地址 (XXX.XXX.XXX.XXX/YY)
   postgresql['trust_auth_cidr_addresses'] = %w(APPLICATION_SERVER_IP_BLOCKS)

   # 禁用自动数据库迁移
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置 极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 记录下 PostgreSQL 节点的 IP 地址或主机名、端口以及明文密码。这些信息是后续配置 极狐GitLab 应用服务器时所需的。
1. [启用监控](replication_and_failover.md#enable-monitoring)

支持高级配置选项，并且可以根据需要添加。