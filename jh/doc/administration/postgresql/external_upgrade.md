---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级外部 PostgreSQL 数据库
---

升级 PostgreSQL 数据库引擎时，务必遵循 PostgreSQL 社区和您的云提供商推荐的所有步骤。PostgreSQL 数据库的升级分为两种：

- 次要版本升级：仅包含缺陷和安全修复。它们始终与您现有的应用程序数据库模型向后兼容。

  次要版本升级过程包括替换 PostgreSQL 二进制文件并重启数据库服务。数据目录保持不变。

- 主要版本升级：会更改内部存储格式和数据库系统目录（catalog）。因此，查询优化器使用的对象统计信息
  [不会转移到新版本](https://www.postgresql.org/docs/16/pgupgrade.html)，
  必须使用 `ANALYZE` 重新构建。

  不遵循文档所述的主要版本升级过程，往往会导致数据库性能低下和数据库服务器 CPU 使用率过高。

所有主流云提供商都支持使用 `pg_upgrade` 实用程序对数据库实例进行原地主要版本升级。但是，您必须遵循升级前和升级后的步骤，以降低性能下降或数据库中断的风险。

请仔细阅读您的外部数据库平台的主要版本升级步骤：

- [Amazon RDS for PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html#USER_UpgradeDBInstance.PostgreSQL.MajorVersion.Process)
- [Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/configure-maintain/concepts-major-version-upgrade)
- [Google Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres/upgrade-major-db-version-inplace)
- [PostgreSQL 社区 `pg_upgrade`](https://www.postgresql.org/docs/16/pgupgrade.html)

> [!note]
> 对于使用逻辑复制的 PostgreSQL 升级（例如 Amazon RDS Blue/Green
> Deployments），请在开始前禁用极狐GitLab 中的运行时 DDL：
>
> ```shell
> sudo gitlab-rails runner "Feature.enable(:disallow_database_ddl_feature_flags)"
> ```
>
> 升级完成后立即重新启用：
>
> ```shell
> sudo gitlab-rails runner "Feature.disable(:disallow_database_ddl_feature_flags)"
> ```
>
> 将 DDL 禁用超过几天可能会降低性能。启用该功能标志还会暂停后台迁移，因此在启用该标志期间，极狐GitLab 升级会失败。

<a id="verify-postgresql-extensions-after-a-major-version-upgrade"></a>

## 主要版本升级后验证 PostgreSQL 扩展

主要版本升级会替换 PostgreSQL 服务器二进制文件，但不会更新您数据库中已安装的扩展。升级后：

- 您从未安装过的扩展仍会缺失，即使较新的极狐GitLab 版本需要它们。
- 已安装的扩展会保持上一个服务器版本中的版本，直到您更新它们。

完成主要版本升级后：

1. 以超级用户身份连接到极狐GitLab 数据库。

1. 确认所有[必需的扩展](../../install/requirements.md#extensions)均已存在：

   ```sql
   SELECT extname, extversion FROM pg_extension ORDER BY extname;
   ```

   如果某个扩展缺失，请安装它。有关说明，请参阅
   [管理 PostgreSQL 扩展](extensions.md)。

1. 列出所有版本落后于新服务器上可用版本的扩展：

   ```sql
   SELECT extname, extversion AS installed, default_version AS available
   FROM pg_extension
   JOIN pg_available_extensions ON name = extname
   WHERE extversion <> default_version;
   ```

1. 更新上一个查询返回的每个扩展：

   ```sql
   ALTER EXTENSION <extension_name> UPDATE;
   ```

对已升级实例上的每个极狐GitLab 数据库重复这些步骤，包括[容器镜像仓库数据库](external.md#container-registry-metadata-database)（如果您使用了该数据库）。

<a id="always-analyze-your-database-after-a-major-version-upgrade"></a>

## 主要版本升级后务必对数据库执行 `ANALYZE`

主要版本升级后，必须运行 [`ANALYZE` 操作](https://www.postgresql.org/docs/16/sql-analyze.html)来刷新 `pg_statistic` 表，因为优化器统计信息[不会由 `pg_upgrade` 转移](https://www.postgresql.org/docs/16/pgupgrade.html)。应对已升级的 PostgreSQL 服务/实例/集群上的所有数据库执行此操作。

在规划维护窗口时，您应将 `ANALYZE`的持续时间考虑在内，因为此操作可能会显著降低极狐GitLab 的性能。

<a id="restart-gitlab-after-a-database-upgrade"></a>

## 数据库升级后重启极狐GitLab

在任何 PostgreSQL 引擎升级（无论次要版本还是主要版本）后，您都必须重启极狐GitLab（Sidekiq、Puma、PgBouncer 和 Praefect，如适用），
因为数据库服务重启会使现有连接失效，这些组件可能需要重启才能成功重新连接。

在规划维护窗口时，您应将升级完成后立即重启极狐GitLab 所需的时间考虑在内。
