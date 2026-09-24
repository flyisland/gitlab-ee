---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用外部 PostgreSQL 实例的 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本文档适用于使用非 Linux 软件包管理的 PostgreSQL 实例的情况，包括
[云托管实例](../../reference_architectures/_index.md#best-practices-for-the-database-services)，
或手动安装和配置的 PostgreSQL 实例。

请确保使用的 PostgreSQL 版本与
[Linux 软件包内置版本](../../package_information/postgresql_versions.md)一致，
以[避免版本不匹配](../_index.md#requirements-for-running-geo)，
以防 Geo 站点需要重建。

> [!note]
> 如果你正在使用极狐GitLab Geo，我们强烈建议你使用 Linux 软件包安装的实例或
> [经过验证的云托管实例](../../reference_architectures/_index.md#recommended-cloud-providers-and-services)，
> 因为我们针对这些环境进行开发和测试。
> 我们无法保证与其他外部数据库的兼容性。

<a id="primary-site"></a>

## **主**站点

1. SSH 登录到**主站点上的 Rails 节点**并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   ##
   ## Geo 主角色
   ## - 自动配置相关标志以启用 Geo
   ##
   roles ['geo_primary_role']

   ##
   ## Geo 站点的唯一标识符。详见
   ## https://gitlab.cn/docs/administration/geo_sites/#common-settings
   ##
   gitlab_rails['geo_node_name'] = '<site_name_here>'
   ```

1. 重新配置 **Rails 节点**以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 在 **Rails 节点**上执行以下命令，将该站点定义为主站点：

   ```shell
   gitlab-ctl set-geo-primary-node
   ```

   此命令会使用你在 `/etc/gitlab/gitlab.rb` 中定义的 `external_url`。

### 配置外部数据库以进行复制

要设置外部数据库，你可以选择：

- 自行设置[流复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION-SLOTS)（例如 Amazon RDS 或不受 Linux 软件包管理的裸金属服务器）。
- 按如下方式手动执行 Linux 软件包安装的配置。

#### 利用云提供商工具复制主数据库

假设你在 AWS EC2 上设置了使用 RDS 的主站点，
现在只需在不同区域创建一个只读副本，AWS 便会管理复制过程。
请根据需求设置网络 ACL、子网和安全组，以便次站点 Rails 节点能够访问该数据库。

以下是针对主流云提供商创建只读副本的说明：

- Amazon RDS - [创建只读副本](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Create)
- Azure Database for PostgreSQL - [创建和管理只读副本](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-read-replicas-portal)
- Google Cloud SQL - [创建只读副本](https://cloud.google.com/sql/docs/postgres/replication/create-replica)

设置好只读副本后，可以跳转到[配置次站点](#configure-secondary-site-to-use-the-external-read-replica)。

> [!warning]
> 不支持使用逻辑复制方式（如 [AWS Database Migration Service](https://aws.amazon.com/dms/) 或 [Google Cloud Database Migration Service](https://cloud.google.com/database-migration)）
> 将本地主数据库复制到 RDS 次站点。

#### 手动配置主数据库以进行复制

[`geo_primary_role`](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)
通过修改 `pg_hba.conf` 和 `postgresql.conf` 来配置**主**节点的数据库，使其可被复制。
请手动对外部数据库配置进行以下更改，并在之后重启 PostgreSQL 以使更改生效：

```plaintext
##
## Geo 主角色
## - pg_hba.conf
##
host    all         all               <可信主 IP>/32       md5
host    replication gitlab_replicator <可信主 IP>/32       md5
host    all         all               <可信次 IP>/32     md5
host    replication gitlab_replicator <可信次 IP>/32     md5
```

```plaintext
##
## Geo 主角色
## - postgresql.conf
##
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 50
max_replication_slots = 1 # 次站点实例数量
hot_standby = on
```

<a id="secondary-sites"></a>

## **次**站点

### 手动配置副本数据库

请手动对外部副本数据库的 `pg_hba.conf` 和 `postgresql.conf` 进行以下更改，
并在之后重启 PostgreSQL 以使更改生效：

```plaintext
##
## Geo 次角色
## - pg_hba.conf
##
host    all         all               <可信次 IP>/32     md5
host    replication gitlab_replicator <可信次 IP>/32     md5
host    all         all               <可信主 IP>/24       md5
```

```plaintext
##
## Geo 次角色
## - postgresql.conf
##
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 10
hot_standby = on
```

### 配置**次**站点以使用外部只读副本

对于 Linux 软件包安装，[`geo_secondary_role`](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)
有三个主要功能：

1. 配置副本数据库。
1. 配置跟踪数据库。
1. 启用 [Geo 日志游标](../_index.md#geo-log-cursor)（本节未涵盖）。

要配置与外部只读副本数据库的连接并启用日志游标：

1. 分别 SSH 登录到**次**站点的每个 **Rails、Sidekiq 和 Geo 日志游标**节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   ##
   ## Geo 次角色
   ## - 自动配置相关标志以启用 Geo
   ##
   roles ['geo_secondary_role']

   # 注意：此密码在两个数据库之间共享，
   # 请确保在两个数据库中定义相同的密码
   gitlab_rails['db_password'] = '<your_primary_db_password_here>'

   gitlab_rails['db_username'] = 'gitlab'
   gitlab_rails['db_host'] = '<database_read_replica_host>'

   # 禁用捆绑的 Omnibus PostgreSQL，因为我们使用外部 PostgreSQL
   postgresql['enable'] = false
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)。

### 配置跟踪数据库

**次**站点使用一个单独的 PostgreSQL 实例作为跟踪数据库，
用于跟踪复制状态并自动从潜在的复制问题中恢复。
当设置 `roles ['geo_secondary_role']` 时，Linux 软件包会自动配置一个跟踪数据库。
如果你想将此数据库运行在 Linux 软件包安装之外，请按照以下说明操作。

#### 理解内部和外部跟踪数据库

你可以将跟踪数据库配置为：

- 内部（`geo_postgresql['enable'] = true`）：跟踪数据库作为 Rails 应用同一服务器上的受管 PostgreSQL 实例运行。这是默认设置。
- 外部（`geo_postgresql['enable'] = false`）：跟踪数据库运行在单独的服务器或云托管服务上。

在多节点次站点设置中，如果你在某个 Rails 节点上启用了跟踪数据库，它将变为该站点中所有其他 Rails 节点的“外部”数据库。
所有其他 Rails 节点必须设置 `geo_postgresql['enable'] = false` 并指定连接信息以连接到该跟踪数据库。

#### 云托管数据库服务

如果你对跟踪数据库使用云托管服务，可能需要为跟踪数据库用户（默认为 `gitlab_geo`）授予额外的角色：

- Amazon RDS 需要 [`rds_superuser`](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Roles) 角色。
- Azure Database for PostgreSQL 需要 [`azure_pg_admin`](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-create-users#how-to-create-additional-admin-users-in-azure-database-for-postgresql) 角色。
- Google Cloud SQL 需要 [`cloudsqlsuperuser`](https://cloud.google.com/sql/docs/postgres/users#default-users) 角色。

这是为了在安装和升级期间安装扩展。作为替代方案，
[请确保手动安装这些扩展，并了解在未来的极狐GitLab 升级中可能出现的问题](../../../install/postgresql_extensions.md)。

> [!note]
> 如果你想使用 Amazon RDS 作为跟踪数据库，请确保它能够访问次数据库。
> 不幸的是，仅仅分配相同的安全组是不够的，因为出站规则不适用于 RDS PostgreSQL 数据库。
> 因此，你需要显式为只读副本的安全组添加入站规则，
> 允许来自跟踪数据库的 TCP 流量通过 5432 端口。

#### 创建跟踪数据库

在你的 PostgreSQL 实例中创建并配置跟踪数据库：

1. 根据[数据库要求文档](../../../install/requirements.md#postgresql)设置 PostgreSQL。
1. 创建一个 `gitlab_geo` 用户，设置你选择的密码，创建 `gitlabhq_geo_production` 数据库，并将该用户设为数据库所有者。
   你可以在[自编译安装文档](../../../install/self_compiled/_index.md#7-database)中找到设置示例。
1. 如果你**未**使用云托管 PostgreSQL 数据库，请确保次站点能够与跟踪数据库通信，
   方法是手动修改与跟踪数据库关联的 `pg_hba.conf`。
   之后请记得重启 PostgreSQL 以使更改生效：

   ```plaintext
   ##
   ## Geo 跟踪数据库角色
   ## - pg_hba.conf
   ##
   host    all         all               <可信跟踪 IP>/32      md5
   host    all         all               <可信次 IP>/32     md5
   # 在多节点设置中，为所有需要连接的 Rails 节点添加条目
   ```

#### 配置极狐GitLab

配置极狐GitLab 以使用此数据库。以下步骤适用于 Linux 软件包和 Docker 部署。

1. SSH 登录到极狐GitLab **次**服务器并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 使用 PostgreSQL 实例所在机器的连接参数和凭据编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   geo_secondary['db_username'] = 'gitlab_geo'
   geo_secondary['db_password'] = '<your_tracking_db_password_here>'

   geo_secondary['db_host'] = '<tracking_database_host>'
   geo_secondary['db_port'] = <tracking_database_port>      # 改为正确端口
   geo_postgresql['enable'] = false     # 不使用内部托管实例
   ```

   在多节点设置中，将此配置应用于每个需要连接到外部跟踪数据库的 Rails 节点。

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)。

#### 设置数据库架构

对于 Linux 软件包和 Docker 部署，[之前步骤](#configure-gitlab)中的重新配置命令应自动处理以下步骤。

1. 此任务创建数据库架构。要求数据库用户是超级用户。

   ```shell
   sudo gitlab-rake db:create:geo
   ```

1. 应用 Rails 数据库迁移（架构和数据更新）也由重新配置执行。如果设置了 `geo_secondary['auto_migrate'] = false` 或
   手动创建了架构，则需要执行此步骤：

   ```shell
   sudo gitlab-rake db:migrate:geo
   ```