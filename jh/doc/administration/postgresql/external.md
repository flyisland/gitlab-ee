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

如果你在云服务提供商上运行极狐GitLab，你可以选择使用托管的 PostgreSQL 服务。例如，AWS 提供了运行 PostgreSQL 的托管关系数据库服务（RDS）。

或者，你也可以选择在 Linux 软件包之外单独管理你自己的 PostgreSQL 实例或集群。

如果你使用云托管服务，或者提供自己的 PostgreSQL 实例，请根据[数据库要求文档](../../install/requirements.md#postgresql)设置 PostgreSQL。

<a id="gitlab-rails-database"></a>

## 极狐GitLab Rails 数据库

设置外部 PostgreSQL 服务器后：

1. 登录到你的数据库服务器。
1. 使用你选择的密码创建一个 `gitlab` 用户，创建 `gitlabhq_production` 数据库，并将该用户设为该数据库的所有者。你可以在[自编译安装文档](../../install/self_compiled/_index.md#7-database)中看到此设置的示例。
1. 如果你正在使用云托管服务，可能需要为你的 `gitlab` 用户授予额外的角色：
   - Amazon RDS 需要 [`rds_superuser`](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Roles) 角色。
   - Azure Database for PostgreSQL 需要 [`azure_pg_admin`](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-create-users#how-to-create-additional-admin-users-in-azure-database-for-postgresql) 角色。Azure Database for PostgreSQL - Flexible Server 需要 [在安装扩展之前将其加入许可列表](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions)。
   - Google Cloud SQL 需要 [`cloudsqlsuperuser`](https://cloud.google.com/sql/docs/postgres/users#default-users) 角色。

   这是为了在安装和升级期间安装扩展。作为替代方案，[请确保手动安装扩展，并了解未来极狐GitLab 升级过程中可能出现的相关问题](../../install/postgresql_extensions.md)。
1. 在 `/etc/gitlab/gitlab.rb` 文件中，为外部 PostgreSQL 服务配置极狐GitLab 应用服务器的相应连接详情：

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

   有关极狐GitLab 多节点设置的更多信息，请参考[参考架构](../reference_architectures/_index.md)。

1. 重新配置以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 重启 PostgreSQL 以启用 TCP 端口：

   ```shell
   sudo gitlab-ctl restart
   ```

<a id="container-registry-metadata-database"></a>

## 容器镜像仓库元数据数据库

如果你计划使用[容器镜像仓库元数据数据库](../packages/container_registry_metadata_database.md)，你还应该创建注册表数据库和用户。

设置外部 PostgreSQL 服务器后：

1. 登录到你的数据库服务器。
1. 使用以下 SQL 命令创建用户和数据库：

   ```sql
   -- Create the registry user
   CREATE USER registry WITH PASSWORD '<your_registry_password>';

   -- Create the registry database
   CREATE DATABASE registry OWNER registry;
   ```

1. 对于云托管服务，根据需要授予额外的角色：

   {{< tabs >}}

   {{< tab title="Amazon RDS" >}}

   ```sql
   GRANT rds_superuser TO registry;
   ```

   {{< /tab >}}

   {{< tab title="Azure 数据库" >}}

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

1. 你现在可以启用并开始使用容器镜像仓库元数据数据库。

<a id="troubleshooting"></a>

## 故障排除

<a id="resolve-ssl-syscall-error-eof-detected-error"></a>

### 解决 `SSL SYSCALL error: EOF detected` 错误

在使用外部 PostgreSQL 实例时，你可能会看到类似以下的错误：

```shell
pg_dump: error: 来自服务器的错误信息：SSL SYSCALL error: EOF detected
```

要解决此错误，请确保你满足[最低 PostgreSQL 要求](../../install/requirements.md#postgresql)。在将你的 RDS 实例升级到[受支持的版本](../../install/requirements.md#postgresql)后，你应该能够执行备份而不出现此错误。

