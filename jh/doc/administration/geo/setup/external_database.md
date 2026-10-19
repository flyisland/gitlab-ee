---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用外部 PostgreSQL 实例的 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您使用的 PostgreSQL 实例不是由 Linux 软件包管理的，则本文档与您相关。这包括[云托管实例](../../../install/cloud-services.md#use-managed-cloud-postgresql)，或手动安装和配置的 PostgreSQL 实例。

请确保您使用的 PostgreSQL 版本是 [Linux 软件包随附的版本](../../package_information/postgresql_versions.md)之一，以便在需要重建 Geo 站点时[避免版本不匹配](../_index.md#requirements-for-running-geo)。

> [!note]
> 如果您使用极狐GitLab Geo，强烈建议运行通过 Linux 软件包安装的实例，或使用
> [经过验证的云托管实例](../../reference_architectures/_index.md#infrastructure-and-services)，
> 因为我们是基于这些实例进行积极开发和测试的。
> 我们无法保证与其他外部数据库的兼容性。

<a id="primary-site"></a>

## 主站点

1. 通过 SSH 登录主站点上的 Rails 节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加：

   ```ruby
   ##
   ## Geo Primary role
   ## - configure dependent flags automatically to enable Geo
   ##
   roles ['geo_primary_role']

   ##
   ## The unique identifier for the Geo site. See
   ## https://gitlab.cn/docs/jh/administration/geo_sites/#common-settings
   ##
   gitlab_rails['geo_node_name'] = '<site_name_here>'
   ```

1. 重新配置 Rails 节点以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 在 Rails 节点上执行以下命令，将该站点定义为主站点：

   ```shell
   gitlab-ctl set-geo-primary-node
   ```

   此命令使用您在 `/etc/gitlab/gitlab.rb`中定义的 `external_url`。

<a id="configure-the-external-database-to-be-replicated"></a>

### 配置要复制的外部数据库

要设置外部数据库，您可以：

- 自行设置[流复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION-SLOTS)（例如 Amazon RDS，或不由 Linux 软件包管理的裸机）。
- 按如下方式手动配置您的 Linux 软件包安装。

<a id="leverage-your-cloud-providers-tools-to-replicate-the-primary-database"></a>

#### 利用云提供商的工具复制主数据库

假设您在 AWS EC2 上设置了一个使用 RDS 的主站点。现在您只需在不同区域创建一个只读副本，复制过程由 AWS 管理。请确保您已根据自身需求设置网络 ACL（访问控制列表）、子网和安全组，以便从站点 Rails 节点可以访问该数据库。

以下说明详细介绍了如何为常见云提供商创建只读副本：

- Amazon RDS - [创建只读副本](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Create)
- Azure Database for PostgreSQL - [在 Azure Database for PostgreSQL 中创建和管理只读副本](https://learn.microsoft.com/en-us/azure/postgresql/read-replica/concepts-read-replicas)
- Google Cloud SQL - [创建只读副本](https://cloud.google.com/sql/docs/postgres/replication/create-replica)

只读副本设置完成后，您可以跳到[配置从站点](#configure-secondary-site-to-use-the-external-read-replica)

> [!warning]
> 不支持使用逻辑复制方法（例如 [AWS Database Migration Service](https://aws.amazon.com/dms/)
> 或 [Google Cloud Database Migration Service](https://cloud.google.com/database-migration)）来执行诸如
> 从本地主数据库复制到 RDS 从数据库之类的操作。

<a id="manually-configure-the-primary-database-for-replication"></a>

#### 手动配置主数据库以进行复制

[`geo_primary_role`](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)
通过更改 `pg_hba.conf` 和 `postgresql.conf` 来配置主节点的数据库以进行复制。请对您的外部数据库配置手动进行以下配置更改，并确保之后重启 PostgreSQL 以使更改生效：

```plaintext
##
## Geo Primary Role
## - pg_hba.conf
##
host    all         all               <trusted primary IP>/32       md5
host    replication gitlab_replicator <trusted primary IP>/32       md5
host    all         all               <trusted secondary IP>/32     md5
host    replication gitlab_replicator <trusted secondary IP>/32     md5
```

```plaintext
##
## Geo Primary Role
## - postgresql.conf
##
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 50
max_replication_slots = 1 # number of secondary instances
hot_standby = on
```

<a id="secondary-sites"></a>

## 从站点

<a id="manually-configure-the-replica-database"></a>

### 手动配置副本数据库

请对您外部副本数据库的 `pg_hba.conf` 和 `postgresql.conf` 手动进行以下配置更改，并确保之后重启 PostgreSQL 以使更改生效：

```plaintext
##
## Geo Secondary Role
## - pg_hba.conf
##
host    all         all               <trusted secondary IP>/32     md5
host    replication gitlab_replicator <trusted secondary IP>/32     md5
host    all         all               <trusted primary IP>/24       md5
```

```plaintext
##
## Geo Secondary Role
## - postgresql.conf
##
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 10
hot_standby = on
```

<a id="configure-secondary-site-to-use-the-external-read-replica"></a>

### 配置从站点以使用外部只读副本

对于 Linux 软件包安装，
[`geo_secondary_role`](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)
有三个主要功能：

1. 配置副本数据库。
1. 配置跟踪数据库。
1. 启用 [Geo 日志游标](../_index.md#geo-log-cursor)（本节不涉及）。

要配置与外部只读副本数据库的连接并启用日志游标：

1. 通过 SSH 登录从站点上的每个 Rails、Sidekiq 和 Geo 日志游标节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容

   ```ruby
   ##
   ## Geo Secondary role
   ## - configure dependent flags automatically to enable Geo
   ##
   roles ['geo_secondary_role']

   # note this is shared between both databases,
   # make sure you define the same password in both
   gitlab_rails['db_password'] = '<your_primary_db_password_here>'

   gitlab_rails['db_username'] = 'gitlab'
   gitlab_rails['db_host'] = '<database_read_replica_host>'

   # Disable the bundled Omnibus PostgreSQL because we are
   # using an external PostgreSQL
   postgresql['enable'] = false
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)

<a id="configure-the-tracking-database"></a>

### 配置跟踪数据库

从站点使用单独的 PostgreSQL 安装作为跟踪数据库，以跟踪复制状态并自动从潜在的复制问题中恢复。当设置了 `roles ['geo_secondary_role']` 时，Linux 软件包会自动配置跟踪数据库。如果您想在 Linux 软件包安装之外运行此数据库，请使用以下说明。

<a id="understanding-internal-and-external-tracking-databases"></a>

#### 了解内部和外部跟踪数据库

您可以将跟踪数据库配置为以下任一种：

- 内部（`geo_postgresql['enable'] = true`）：跟踪数据库作为受管 PostgreSQL 实例运行在与 Rails 应用相同的服务器上。这是默认设置。
- 外部（`geo_postgresql['enable'] = false`）：跟踪数据库运行在单独的服务器上，或作为云托管服务运行。

在多节点从站点设置中，如果您在一个 Rails 节点上启用跟踪数据库，它对该站点中的所有其他 Rails 节点来说就变成了“外部”数据库。所有其他 Rails 节点必须设置 `geo_postgresql['enable'] = false` 并指定连接详细信息以连接到该跟踪数据库。

<a id="cloud-managed-database-services"></a>

#### 云托管数据库服务

如果您使用云托管服务作为跟踪数据库，您可能需要为跟踪数据库用户授予额外的角色（默认情况下，该用户为
`gitlab_geo`）：

- Amazon RDS 需要 [`rds_superuser`](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Roles) 角色。
- Azure Database for PostgreSQL 需要 [`azure_pg_admin`](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-create-users#how-to-create-additional-admin-users-in-azure-database-for-postgresql) 角色。
- Google Cloud SQL 需要 [`cloudsqlsuperuser`](https://cloud.google.com/sql/docs/postgres/users#default-users) 角色。

这是为了在安装和升级期间安装扩展。作为替代方案，[手动安装所需的扩展](../../postgresql/extensions.md)。

> [!note]
> 如果您想使用 Amazon RDS 作为跟踪数据库，请确保它可以访问
> 从数据库。遗憾的是，仅分配相同的安全组是不够的，因为
> 出站规则不适用于 RDS PostgreSQL 数据库。因此，您需要显式地向
> 只读副本的安全组添加一条入站规则，允许来自
> 跟踪数据库的任意 TCP 流量通过端口 5432。

<a id="create-the-tracking-database"></a>

#### 创建跟踪数据库

在您的 PostgreSQL 实例中创建并配置跟踪数据库：

1. 根据
   [数据库要求文档](../../../install/requirements.md#postgresql)设置 PostgreSQL。
1. 设置一个 `gitlab_geo` 用户并设置您选择的密码，创建 `gitlabhq_geo_production` 数据库，并使该用户成为该数据库的所有者。
   您可以在[自编译安装文档](../../../install/self_compiled/_index.md#7-database)中看到此设置的示例。
1. 如果您未使用云托管 PostgreSQL 数据库，请通过手动更改与
   跟踪数据库关联的 `pg_hba.conf`，确保您的从
   站点可以与跟踪数据库通信。
   请记得之后重启 PostgreSQL 以使更改生效：

   ```plaintext
   ##
   ## Geo Tracking Database Role
   ## - pg_hba.conf
   ##
   host    all         all               <trusted tracking IP>/32      md5
   host    all         all               <trusted secondary IP>/32     md5
   # In multi-node setups, add entries for all Rails nodes that will connect
   ```

<a id="configure-gitlab"></a>

#### 配置极狐GitLab

配置极狐GitLab 以使用此数据库。这些步骤适用于 Linux 软件包和 Docker 部署。

1. 通过 SSH 登录极狐GitLab 从服务器，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 使用 PostgreSQL 实例所在机器的连接参数和凭据
   编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   geo_secondary['db_username'] = 'gitlab_geo'
   geo_secondary['db_password'] = '<your_tracking_db_password_here>'

   geo_secondary['db_host'] = '<tracking_database_host>'
   geo_secondary['db_port'] = <tracking_database_port>      # change to the correct port
   geo_postgresql['enable'] = false     # don't use internal managed instance
   ```

   在多节点设置中，请将此配置应用于每个需要连接到外部跟踪数据库的 Rails 节点。

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)

<a id="set-up-the-database-schema"></a>

#### 设置数据库架构

对于 Linux 软件包和 Docker 部署，[前面列出的步骤](#configure-gitlab)中的重新配置命令应会自动处理这些步骤。

1. 此任务会创建数据库架构。它要求数据库用户为超级用户。

   ```shell
   sudo gitlab-rake db:create:geo
   ```

1. 应用 Rails 数据库迁移（架构和数据更新）也由重新配置执行。如果设置了 `geo_secondary['auto_migrate'] = false`，或
   架构是手动创建的，则需要执行此步骤：

   ```shell
   sudo gitlab-rake db:migrate:geo
   ```
