---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用外部 PostgreSQL 服务配置极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您将极狐GitLab 托管在云服务商上，可以选择使用 PostgreSQL 的托管服务。例如，AWS 提供运行 PostgreSQL 的托管关系数据库服务（RDS）。

或者，您也可以选择在 Linux 软件包之外管理自己的 PostgreSQL 实例或集群。

如果您使用云托管服务，或提供自己的 PostgreSQL 实例，请按照[数据库要求文档](../../install/requirements.md#postgresql)设置 PostgreSQL。

<a id="gitlab-rails-database"></a>

## GitLab Rails 数据库

设置好外部 PostgreSQL 服务器后：

1. 登录到您的数据库服务器。
1. 创建一个密码由您自行设置的 `gitlab` 用户，创建 `gitlabhq_production` 数据库，并将该用户设为该数据库的所有者。您可以在[自行编译安装文档](../../install/self_compiled/_index.md#7-database)中查看此设置的示例。
1. 如果您使用的是云托管服务，可能需要为 `gitlab` 用户授予额外的角色：
   - Amazon RDS 需要 [`rds_superuser`](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Roles) 角色。
   - Azure Database for PostgreSQL 需要 [`azure_pg_admin`](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-create-users#how-to-create-additional-admin-users-in-azure-database-for-postgresql) 角色。Azure Database for PostgreSQL - Flexible Server 需要[先将扩展加入允许名单才能安装](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions)。
   - Google Cloud SQL 需要 [`cloudsqlsuperuser`](https://cloud.google.com/sql/docs/postgres/users#default-users) 角色。

   这是为了在安装和升级期间安装扩展。作为替代方案，您可以[手动安装所需的扩展](extensions.md)。
1. 在 `/etc/gitlab/gitlab.rb` 文件中，使用适用于您的外部 PostgreSQL 服务的连接信息配置极狐GitLab 应用服务器：

   ```ruby
   # Disable the bundled Omnibus provided PostgreSQL
   postgresql['enable'] = false

   # PostgreSQL connection details
   gitlab_rails['db_adapter'] = 'postgresql'
   gitlab_rails['db_encoding'] = 'unicode'
   gitlab_rails['db_host'] = '10.1.0.5' # IP/hostname of database server
   gitlab_rails['db_port'] = 5432
   gitlab_rails['db_password'] = 'DB password'
   ```

   有关极狐GitLab 多节点设置的更多信息，请参阅[参考架构](../reference_architectures/_index.md)。

1. 重新配置以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 重启 PostgreSQL 以启用 TCP 端口：

   ```shell
   sudo gitlab-ctl restart
   ```

<a id="database-schemas"></a>

## 数据库 schema

请仅为极狐GitLab、[Geo](../geo/_index.md)、[Gitaly 集群（Praefect）](../gitaly/praefect/_index.md)或其他组件创建或使用数据库。除非遵循以下内容，否则请勿创建或修改数据库、schema、用户或其他属性：

- 极狐GitLab 文档中的操作步骤。
- 极狐GitLab 支持或工程师的指示。

极狐GitLab 主应用使用三个 schema：

- 默认的 `public` schema。
- `gitlab_partitions_static`（自动创建）。
- `gitlab_partitions_dynamic`（自动创建）。

在 Rails 数据库迁移期间，极狐GitLab 可能会创建或修改 schema 或表。数据库迁移会针对极狐GitLab 代码库中的 schema 定义进行测试。如果您修改了任何 schema，[极狐GitLab 升级](../../update/_index.md)可能会失败。

<a id="container-registry-metadata-database"></a>

## 容器镜像仓库元数据数据库

如果您计划使用[容器镜像仓库元数据数据库](../packages/container_registry_metadata_database.md)，还应创建 registry 数据库和用户。

设置好外部 PostgreSQL 服务器后：

1. 登录到您的数据库服务器。
1. 使用以下 SQL 命令创建用户和数据库：

   ```sql
   -- Create the registry user
   CREATE USER registry WITH PASSWORD '<your_registry_password>';

   -- Create the registry database
   CREATE DATABASE registry OWNER registry;
   ```

1. 对于云托管服务，请根据需要授予额外的角色：

   {{< tabs >}}

   {{< tab title="Amazon RDS" >}}

   ```sql
   GRANT rds_superuser TO registry;
   ```

   {{< /tab >}}

   {{< tab title="Azure database" >}}

   ```sql
   GRANT azure_pg_admin TO registry;
   ```

   {{< /tab >}}

   {{< tab title="Google Cloud SQL" >}}

   ```sql
   GRANT cloudsqlsuperuser TO registry;
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 现在您可以启用并开始使用容器镜像仓库元数据数据库。

<a id="troubleshooting"></a>

## 故障排除

<a id="resolve-ssl-syscall-error-eof-detected-error"></a>

### 解决 `SSL SYSCALL error: EOF detected` 错误

使用外部 PostgreSQL 实例时，您可能会看到类似如下的错误：

```shell
pg_dump: error: Error message from server: SSL SYSCALL error: EOF detected
```

要解决此错误，请确保满足[最低 PostgreSQL 要求](../../install/requirements.md#postgresql)。将您的 RDS 实例升级到[受支持的版本](../../install/requirements.md#postgresql)后，您应该能够执行备份而不会出现此错误。更多信息请参阅[议题 364763](https://gitlab.com/gitlab-org/gitlab/-/issues/364763)。
