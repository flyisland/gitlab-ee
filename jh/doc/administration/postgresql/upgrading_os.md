---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级 PostgreSQL 操作系统
---

> [!warning]
> [Geo](../geo/_index.md) 不能用于将 PostgreSQL 数据库从一个操作系统迁移到另一个操作系统。如果尝试这样做，辅助站点可能看起来 100% 已复制，但实际上某些数据未被复制，从而导致数据丢失。这是因为 Geo 依赖于 PostgreSQL 流复制，而这受本文档所述限制的影响。另请参阅 [Geo 故障排查 - 检查操作系统语言环境数据兼容性](../geo/replication/troubleshooting/common.md#check-os-locale-data-compatibility)。

如果升级运行 PostgreSQL 的操作系统，任何[语言环境数据变更都可能损坏数据库索引](https://wiki.postgresql.org/wiki/Locale_data_changes)。特别是升级到 `glibc` 2.28 很可能导致此问题。为避免此问题，请按复杂度大致递增的顺序，使用以下选项之一进行迁移：

- 推荐。 [备份与恢复](#backup-and-restore)。
- 推荐。 [重建所有索引](#rebuild-all-indexes)。
- [仅重建受影响的索引](#rebuild-only-affected-indexes)。

在尝试任何迁移之前，务必进行备份，并在类似生产环境中验证迁移过程。如果停机时长可能成为问题，可以考虑在类似生产环境中使用生产数据副本，对不同的方法进行时序安排。

如果您运行的是水平扩展的极狐GitLab 环境，且 PostgreSQL 所在节点上没有其他服务运行，我们建议单独升级 PostgreSQL 节点的操作系统。为降低复杂性和风险，请勿将此过程与其他变更（尤其是那些无需停机的变更，例如仅运行 Puma 或 Sidekiq 的节点的操作系统升级）合并进行。

有关极狐GitLab 计划如何解决此问题的更多信息，请参见[史诗 8573](https://jihulab.com/groups/gitlab-cn/-/epics/8573)。

## 备份与恢复
<a id="backup-and-restore"></a>

备份与恢复将重新创建整个数据库，包括索引。

1. 安排计划性停机窗口。在所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 使用 `pg_dump` 或
   [极狐GitLab 备份工具，排除除 `db` 之外的所有数据类型](../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)
   （即仅备份数据库）备份 PostgreSQL 数据库。
1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后[更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 从备份恢复 PostgreSQL 数据库。
1. 在所有节点上，启动极狐GitLab。

优点：

- 简单直接。
- 消除索引和表中的任何数据库膨胀，减少磁盘使用。

缺点：

- 停机时间随数据库大小增加而增加，在某个时间点会成为问题。这取决于许多因素，但如果您的数据库超过 100 GB，则可能需要大约 24 小时。

### 备份与恢复，搭配 Geo 辅助站点
<a id="backup-and-restore-with-geo-secondary-sites"></a>

1. 安排计划性停机窗口。在所有站点的所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在主站点，使用 `pg_dump` 或
   [极狐GitLab 备份工具，排除除 `db` 之外的所有数据类型](../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)
   （即仅备份数据库）备份 PostgreSQL 数据库。
1. 在所有站点的所有 PostgreSQL 节点上，升级操作系统。
1. 在所有站点的所有 PostgreSQL 节点上，升级操作系统后[更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有站点的所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 在主站点，从备份恢复 PostgreSQL 数据库。
1. 可选，开始使用主站点，但存在没有辅助站点作为热备用的风险。
1. 再次设置到辅助站点的 PostgreSQL 流复制。
1. 如果辅助站点接收用户流量，则在启动极狐GitLab 之前，让只读副本数据库追赶上来。
1. 在所有站点的所有节点上，启动极狐GitLab。

## 重建所有索引
<a id="rebuild-all-indexes"></a>

[重建所有索引](https://www.postgresql.org/docs/16/sql-reindex.html)。

1. 安排计划性停机窗口。在所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后[更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 在[数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，重建所有索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX DATABASE gitlabhq_production;
   ```

1. 重建数据库后，必须刷新所有受影响排序规则的版本。要更新系统目录以记录当前排序规则版本：

   ```sql
   ALTER DATABASE gitlabhq_production REFRESH COLLATION VERSION;
   ```

   当 PostgreSQL 启动时，`template1` 或 `postgres` 等系统数据库也可能出现排序规则问题。检查错误消息中的提示，并刷新那些数据库中的排序规则。

1. 在所有节点上，启动极狐GitLab。

优点：

- 简单直接。
- 根据多种因素，可能比备份与恢复更快。
- 消除索引中的数据库膨胀，减少磁盘使用。

缺点：

- 停机时间随数据库大小增加而增加，在某个时间点会成为问题。

### 重建所有索引，搭配 Geo 辅助站点
<a id="rebuild-all-indexes-with-geo-secondary-sites"></a>

1. 安排计划性停机窗口。在所有站点的所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后[更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 在主站点，在[数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，重建所有索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX DATABASE gitlabhq_production;
   ```

1. 重建数据库后，必须刷新所有受影响排序规则的版本。要更新系统目录以记录当前排序规则版本：

   ```sql
   ALTER DATABASE <database_name> REFRESH COLLATION VERSION;
   ```

1. 如果辅助站点接收用户流量，则在启动极狐GitLab 之前，让只读副本数据库追赶上来。
1. 在所有站点的所有节点上，启动极狐GitLab。

## 仅重建受影响的索引
<a id="rebuild-only-affected-indexes"></a>

此方法类似于极狐GitLab.com 使用的方法。要了解此过程以及如何处理不同类型的索引，请参阅关于[升级 PostgreSQL 数据库集群操作系统](https://gitlab.cn/blog/upgrading-database-os/)的博客文章。

1. 安排计划性停机窗口。在所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后[更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. [确定哪些索引受到影响](https://wiki.postgresql.org/wiki/Locale_data_changes#What_indexes_are_affected)。
1. 在[数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，对每个受影响的索引执行重新索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX INDEX <index name> CONCURRENTLY;
   ```

1. 重新索引有问题的索引后，必须刷新排序规则。要更新系统目录以记录当前排序规则版本：

   ```sql
   ALTER DATABASE <database_name> REFRESH COLLATION VERSION;
   ```

1. 在所有节点上，启动极狐GitLab。

优点：

- 停机期间不花费时间在未受影响的索引上。

缺点：

- 更容易出错。
- 需要 PostgreSQL 的专业知识来处理迁移期间的意外问题。
- 保留数据库膨胀。

### 仅重建受影响的索引，搭配 Geo 辅助站点
<a id="rebuild-only-affected-indexes-with-geo-secondary-sites"></a>

1. 安排计划性停机窗口。在所有站点的所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后[更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. [确定哪些索引受到影响](https://wiki.postgresql.org/wiki/Locale_data_changes#What_indexes_are_affected)。
1. 在主站点，在[数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，对每个受影响的索引执行重新索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX INDEX <index name> CONCURRENTLY;
   ```

1. 重新索引有问题的索引后，必须刷新排序规则。要更新系统目录以记录当前排序规则版本：

   ```sql
   ALTER DATABASE <database_name> REFRESH COLLATION VERSION;
   ```

1. 现有的 PostgreSQL 流复制应将重新索引的更改复制到只读副本数据库。
1. 在所有站点的所有节点上，启动极狐GitLab。

## 检查 `glibc` 版本
<a id="checking-glibc-versions"></a>

要查看所使用的 `glibc` 版本，请运行 `ldd --version`。

下表显示了不同操作系统所附带的 `glibc` 版本：

| 操作系统            | `glibc` 版本 |
|---------------------|-------------|
| CentOS 7            | 2.17        |
| RedHat Enterprise 8 | 2.28        |
| RedHat Enterprise 9 | 2.34        |
| Ubuntu 18.04        | 2.27        |
| Ubuntu 20.04        | 2.31        |
| Ubuntu 22.04        | 2.35        |
| Ubuntu 24.04        | 2.39        |

例如，假设您要从 CentOS 7 升级到 RedHat Enterprise 8。在这种情况下，在此升级后的操作系统上使用 PostgreSQL 需要采用上述两种方法之一，因为 `glibc` 从 2.17 升级到了 2.28。如果未能正确处理排序规则变更，将导致极狐GitLab 出现严重故障，例如 Runner 不接取带标签的作业。

另一方面，如果 PostgreSQL 已经在 `glibc` 2.28 或更高版本上运行且没有问题，那么您的索引应该无需进一步操作即可继续工作。例如，如果您已在 RedHat Enterprise 8（`glibc` 2.28）上运行 PostgreSQL 一段时间，并希望升级到 RedHat Enterprise 9（`glibc` 2.34），则不应出现与排序规则相关的问题。

### 验证 `glibc` 排序规则版本
<a id="verifying-glibc-collation-versions"></a>

对于 PostgreSQL 13 及更高版本，您可以使用以下 SQL 查询验证数据库排序规则版本是否与系统匹配：

```sql
SELECT collname AS COLLATION_NAME,
       collversion AS VERSION,
       pg_collation_actual_version(oid) AS actual_version
FROM pg_collation
WHERE collprovider = 'c';
```

### 排序规则匹配示例
<a id="matching-collation-example"></a>

例如，在 Ubuntu 22.04 系统上，索引正确的系统输出如下：

```sql
gitlabhq_production=# SELECT collname AS COLLATION_NAME,
       collversion AS VERSION,
       pg_collation_actual_version(oid) AS actual_version
FROM pg_collation
WHERE collprovider = 'c';
 collation_name | version | actual_version
----------------+---------+----------------
 C              |         |
 POSIX          |         |
 ucs_basic      |         |
 C.utf8         |         |
 en_US.utf8     | 2.35    | 2.35
 en_US          | 2.35    | 2.35
(6 rows)
```

### 排序规则不匹配示例
<a id="mismatched-collation-example"></a>

另一方面，如果您已从 Ubuntu 18.04 升级到 22.04 但未进行重新索引，则可能会看到：

```sql
gitlabhq_production=# SELECT collname AS COLLATION_NAME,
       collversion AS VERSION,
       pg_collation_actual_version(oid) AS actual_version
FROM pg_collation
WHERE collprovider = 'c';
 collation_name | version | actual_version
----------------+---------+----------------
 C              |         |
 POSIX          |         |
 ucs_basic      |         |
 C.utf8         |         |
 en_US.utf8     | 2.27    | 2.35
 en_US          | 2.27    | 2.35
(6 rows)
```

## 流复制
<a id="streaming-replication"></a>

索引损坏问题会影响 PostgreSQL 流复制。您必须先[重建所有索引](#rebuild-all-indexes)或[仅重建受影响的索引](#rebuild-only-affected-indexes)，然后才能允许对具有不同语言环境数据的副本进行读取。

## 额外的 Geo 变通方案
<a id="additional-geo-variations"></a>

前面记录的升级过程并非一成不变。使用 Geo 时，由于有冗余的基础设施，可能还有更多选项。您可以考虑修改以适应您的用例，但务必权衡其增加的复杂性。以下是一些示例：

为了在升级主站点和另一个辅助站点的操作系统期间保留一个辅助站点作为热备用，以防发生灾难：

1. 将辅助站点的数据与主站点的变更隔离开来：暂停辅助站点。
1. 对主站点执行操作系统升级。
1. 如果操作系统升级失败且主站点无法恢复，则提升辅助站点，将用户路由到该站点，然后稍后重试。这将使您没有一个最新的辅助站点。

为了在操作系统升级期间为用户提供对极狐GitLab 的只读访问（部分停机）：

1. 在主站点上启用[维护模式](../maintenance_mode/_index.md)，而不是停止它。
1. 提升辅助站点，但暂不将用户路由到该站点。
1. 对提升后的站点执行操作系统升级。
1. 将用户路由到提升后的站点，而不是旧的主站点。
1. 将旧的主站点设置为新的辅助站点。

> [!warning]
> 即使辅助站点已经拥有数据库的只读副本，您也不能在提升之前升级其操作系统。如果尝试这样做，由于索引损坏，辅助站点可能会漏掉某些 Git 仓库或文件的复制。
> 请参阅[流复制](#streaming-replication)。