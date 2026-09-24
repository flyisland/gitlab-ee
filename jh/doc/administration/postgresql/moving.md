---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab 数据库移动到不同的 PostgreSQL 实例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

有时需要将数据库从一个 PostgreSQL 实例移动到另一个。例如，如果你正在使用 AWS Aurora 并准备启用数据库负载均衡，则需要将数据库移动到 RDS for PostgreSQL。

要将数据库从一个实例移动到另一个实例，请执行以下操作：

1. 收集源 PostgreSQL 和目标 PostgreSQL 端点信息：

   ```shell
   SRC_PGHOST=<source postgresql host>
   SRC_PGUSER=<source postgresql user>

   DST_PGHOST=<destination postgresql host>
   DST_PGUSER=<destination postgresql user>
   ```

1. 停止极狐GitLab：

   ```shell
   sudo gitlab-ctl stop
   ```

1. 从源数据库导出数据库：

   ```shell
   /opt/gitlab/embedded/bin/pg_dump -h $SRC_PGHOST -U $SRC_PGUSER -c -C -f gitlabhq_production.sql gitlabhq_production
   /opt/gitlab/embedded/bin/pg_dump -h $SRC_PGHOST -U $SRC_PGUSER -c -C -f praefect_production.sql praefect_production
   ```

   > [!note]
   > 在极少数情况下，执行 `pg_dump` 并恢复后，你可能注意到数据库性能问题。这可能是由于 `pg_dump` 不包含 [优化器用于制定查询计划决策的统计信息](https://www.postgresql.org/docs/16/app-pgdump.html)。如果恢复后性能下降，可以通过找到有问题的查询，然后对查询使用的表运行 ANALYZE 来解决问题。

1. 将数据库恢复到目标数据库（这会覆盖任何同名的现有数据库）：

   ```shell
   /opt/gitlab/embedded/bin/psql -h $DST_PGHOST -U $DST_PGUSER -f praefect_production.sql postgres
   /opt/gitlab/embedded/bin/psql -h $DST_PGHOST -U $DST_PGUSER -f gitlabhq_production.sql postgres
   ```

1. 可选。如果从不使用 PgBouncer 的数据库迁移到使用 PgBouncer 的数据库，必须手动将 [`pg_shadow_lookup` 函数](../gitaly/praefect/configure.md#manual-database-setup)添加到应用程序数据库（通常为 `gitlabhq_production`）。
1. 在 `/etc/gitlab/gitlab.rb` 文件中为目标 PostgreSQL 实例配置极狐GitLab 应用程序服务器的适当连接详细信息：

   ```ruby
   gitlab_rails['db_host'] = '<destination postgresql host>'
   ```

   有关极狐GitLab 多节点设置的更多信息，请参考 [参考架构](../reference_architectures/_index.md)。

1. 重新配置以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 重启极狐GitLab：

   ```shell
   sudo gitlab-ctl start
   ```