---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级外部 PostgreSQL 数据库
---

在升级 PostgreSQL 数据库引擎时，请务必遵循 PostgreSQL 社区和云提供商推荐的所有步骤。PostgreSQL 数据库升级分为两类：

- 小版本升级：这类升级仅包含错误修复和安全补丁。它们始终与你现有的应用程序数据库模型向后兼容。

  小版本升级过程包括替换 PostgreSQL 二进制文件并重启数据库服务。数据目录保持不变。

- 大版本升级：这类升级会更改内部存储格式和数据库 catalog。因此，查询优化器所使用的对象统计信息
  [不会迁移到新版本](https://www.postgresql.org/docs/16/pgupgrade.html)，
  必须通过 `ANALYZE` 重建。

  未遵循文档化的大版本升级流程通常会导致数据库性能不佳，并造成数据库服务器 CPU 使用率过高。

所有主流云提供商都支持使用 `pg_upgrade` 实用程序对数据库实例进行原位大版本升级。但是，你必须遵循升级前和升级后的步骤，以降低性能下降或数据库中断的风险。

请仔细阅读你所使用的外部数据库平台的大版本升级步骤：

- [Amazon RDS for PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html#USER_UpgradeDBInstance.PostgreSQL.MajorVersion.Process)
- [Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-major-version-upgrade)
- [Google Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres/upgrade-major-db-version-inplace)
- [PostgreSQL 社区 `pg_upgrade`](https://www.postgresql.org/docs/16/pgupgrade.html)

<a id="always-analyze-your-database-after-a-major-version-upgrade"></a>

## 在大版本升级后始终对数据库执行 `ANALYZE` 操作

必须运行 [`ANALYZE` 操作](https://www.postgresql.org/docs/16/sql-analyze.html)以刷新 `pg_statistic` 表，因为优化器统计信息[不会通过 `pg_upgrade` 迁移](https://www.postgresql.org/docs/16/pgupgrade.html)。这应该在已升级的 PostgreSQL 服务/实例/集群上的所有数据库中执行。

在规划维护窗口时，你应将 `ANALYZE` 的持续时间考虑在内，因为此操作可能会显著降低极狐GitLab 的性能。

要加快 `ANALYZE` 操作，可使用 [`vacuumdb` 实用程序](https://www.postgresql.org/docs/16/app-vacuumdb.html)，配合 `--analyze-only --jobs=njobs` 参数，通过同时运行 `njobs` 个命令来并行执行 `ANALYZE` 命令。