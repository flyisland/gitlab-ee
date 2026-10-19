---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级 PostgreSQL 的操作系统
---

<a id="when-to-check-locale-compatibility"></a>

## 何时检查区域设置兼容性

`glibc`中区域设置数据的变化可能导致 PostgreSQL 数据库文件在不同操作系统之间变得不兼容，从而引发索引损坏。在以下情况下，请检查区域设置兼容性：

- 升级运行 PostgreSQL 的操作系统。
- 在服务器之间移动二进制 PostgreSQL 数据。
- 更新或更改包含 PostgreSQL 的第三方容器镜像。

要检查区域设置兼容性，请参阅[检查操作系统区域设置数据兼容性](../geo/replication/troubleshooting/common.md#check-os-locale-data-compatibility)。

> [!warning]
> [Geo](../geo/_index.md) 不能用于将 PostgreSQL 数据库从一个操作系统迁移到另一个操作系统。如果您尝试这样做，从站点可能看起来已 100% 复制，但实际上部分数据并未复制，从而导致数据丢失。这是因为 Geo 依赖 PostgreSQL 流复制，而流复制存在本文档所述的局限性。另请参阅 [Geo 故障排除 - 检查操作系统区域设置数据兼容性](../geo/replication/troubleshooting/common.md#check-os-locale-data-compatibility)。

如果您升级运行 PostgreSQL 的操作系统，任何[区域设置数据的变化都可能损坏您的数据库索引](https://wiki.postgresql.org/wiki/Locale_data_changes)。特别是升级到 `glibc` 2.28 时很可能会引发此问题。为避免此问题，请使用以下选项之一进行迁移，大致按复杂度排序：

- 推荐。[备份和恢复](#backup-and-restore)。
- 推荐。[重建所有索引](#rebuild-all-indexes)。
- [仅重建受影响的索引](#rebuild-only-affected-indexes)。

在尝试任何迁移之前，请务必先备份，并在类生产环境中验证迁移过程。如果停机时间可能成为问题，请考虑在类生产环境中使用生产数据副本对不同的方法进行计时。

如果您运行的是横向扩展的极狐GitLab 环境，并且运行 PostgreSQL 的节点上没有运行其他服务，那么我们建议单独升级 PostgreSQL 节点的操作系统。为降低复杂度和风险，请勿将此过程与其他变更合并进行，尤其是那些不需要停机的变更，例如升级仅运行 Puma 或 Sidekiq 的节点的操作系统。

有关 GitLab 计划如何解决此问题的更多信息，请参阅[史诗 8573](https://gitlab.com/groups/gitlab-org/-/work_items/8573)。

<a id="backup-and-restore"></a>

## 备份和恢复

备份和恢复会重新创建整个数据库，包括索引。

1. 安排一个停机窗口。在所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 使用 `pg_dump` 或
   [极狐GitLab 备份工具（排除除 `db` 之外的所有数据类型）](../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)
   备份 PostgreSQL 数据库（这样只备份数据库）。
1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后
   [更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 从备份恢复 PostgreSQL 数据库。
1. 在所有节点上，启动极狐GitLab。

优点：

- 简单直接。
- 清除索引和表中的数据库膨胀，减少磁盘占用。

缺点：

- 停机时间随数据库大小而增加，到某个程度会成为问题。这取决于许多
  因素，但如果您的数据库超过 100 GB，则可能需要大约 24 小时。

<a id="backup-and-restore-with-geo-secondary-sites"></a>

### 备份和恢复（含 Geo 从站点）

1. 安排一个停机窗口。在所有站点的所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在主站点上，使用 `pg_dump` 或
   [极狐GitLab 备份工具（排除除 `db` 之外的所有数据类型）](../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)
   备份 PostgreSQL 数据库（这样只备份数据库）。
1. 在所有站点的所有 PostgreSQL 节点上，升级操作系统。
1. 在所有站点的所有 PostgreSQL 节点上，升级操作系统后
   [更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有站点的所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 在主站点上，从备份恢复 PostgreSQL 数据库。
1. 可选：开始使用主站点，但需承担没有从站点作为热备的风险。
1. 再次设置到从站点的 PostgreSQL 流复制。
1. 如果从站点接收来自用户的流量，则在启动极狐GitLab 之前，让只读副本数据库追赶进度。
1. 在所有站点的所有节点上，启动极狐GitLab。

<a id="rebuild-all-indexes"></a>

## 重建所有索引

[重建所有索引](https://www.postgresql.org/docs/16/sql-reindex.html)。

1. 安排一个停机窗口。在所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后
   [更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 在[数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，重建所有索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX DATABASE gitlabhq_production;
   ```

1. 重建数据库索引后，必须为所有受影响的排序规则刷新版本。
   要更新系统目录以记录当前排序规则版本：

   ```sql
   ALTER DATABASE gitlabhq_production REFRESH COLLATION VERSION;
   ```

   像 `template1` 或 `postgres` 这样的系统数据库在 PostgreSQL 启动时也可能出现排序规则问题。请检查错误消息中的提示，并同样刷新这些数据库中的排序规则。

1. 在所有节点上，启动极狐GitLab。

优点：

- 简单直接。
- 可能比备份和恢复更快，具体取决于许多因素。
- 清除索引中的数据库膨胀，减少磁盘占用。

缺点：

- 停机时间随数据库大小而增加，到某个程度会成为问题。

<a id="rebuild-all-indexes-with-geo-secondary-sites"></a>

### 重建所有索引（含 Geo 从站点）

1. 安排一个停机窗口。在所有站点的所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后
   [更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. 在主站点上，在
   [数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，重建所有索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX DATABASE gitlabhq_production;
   ```

1. 重建数据库索引后，必须为所有受影响的排序规则刷新版本。
   要更新系统目录以记录当前排序规则版本：

   ```sql
   ALTER DATABASE <database_name> REFRESH COLLATION VERSION;
   ```

1. 如果从站点接收来自用户的流量，则在启动极狐GitLab 之前，让只读副本数据库追赶进度。
1. 在所有站点的所有节点上，启动极狐GitLab。

<a id="rebuild-only-affected-indexes"></a>

## 仅重建受影响的索引

这与上游 GitLab.com 所采用的方法类似。要了解有关此过程以及如何处理不同类型索引的更多信息，请参阅关于[升级 PostgreSQL 数据库集群的操作系统](https://about.gitlab.com/blog/upgrading-database-os/)的博客文章。

1. 安排一个停机窗口。在所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后
   [更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. [确定哪些索引受到影响](https://wiki.postgresql.org/wiki/Locale_data_changes#What_indexes_are_affected)。
1. 在[数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，重建每个受影响的索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX INDEX <index name> CONCURRENTLY;
   ```

1. 重建有问题的索引后，必须刷新排序规则。要更新系统目录以
   记录当前排序规则版本：

   ```sql
   ALTER DATABASE <database_name> REFRESH COLLATION VERSION;
   ```

1. 在所有节点上，启动极狐GitLab。

优点：

- 停机时间不会花费在重建未受影响的索引上。

缺点：

- 更容易出错。
- 需要 PostgreSQL 专家知识，以处理迁移过程中出现的意外问题。
- 保留数据库膨胀。

<a id="rebuild-only-affected-indexes-with-geo-secondary-sites"></a>

### 仅重建受影响的索引（含 Geo 从站点）

1. 安排一个停机窗口。在所有站点的所有节点上，停止不必要的极狐GitLab 服务：

   ```shell
   gitlab-ctl stop
   gitlab-ctl start postgresql
   ```

1. 在所有 PostgreSQL 节点上，升级操作系统。
1. 在所有 PostgreSQL 节点上，升级操作系统后
   [更新极狐GitLab 软件包源](../../update/package/_index.md)。
1. 在所有 PostgreSQL 节点上，安装相同极狐GitLab 版本的新极狐GitLab 软件包。
1. [确定哪些索引受到影响](https://wiki.postgresql.org/wiki/Locale_data_changes#What_indexes_are_affected)。
1. 在主站点上，在
   [数据库控制台](../troubleshooting/postgresql.md#start-a-database-console)中，重建每个受影响的索引：

   ```sql
   SET statement_timeout = 0;
   REINDEX INDEX <index name> CONCURRENTLY;
   ```

1. 重建有问题的索引后，必须刷新排序规则。要更新系统目录以
   记录当前排序规则版本：

   ```sql
   ALTER DATABASE <database_name> REFRESH COLLATION VERSION;
   ```

1. 现有的 PostgreSQL 流复制应将重建索引的变更复制到
   只读副本数据库。
1. 在所有站点的所有节点上，启动极狐GitLab。

<a id="checking-glibc-versions"></a>

## 检查 `glibc` 版本

要查看所使用的 `glibc` 版本，请运行 `ldd --version`。

下表显示了不同操作系统随附的 `glibc` 版本：

| 操作系统            | `glibc` 版本 |
|---------------------|-----------------|
| CentOS 7            | 2.17            |
| RedHat Enterprise 8 | 2.28            |
| RedHat Enterprise 9 | 2.34            |
| Ubuntu 18.04        | 2.27            |
| Ubuntu 20.04        | 2.31            |
| Ubuntu 22.04        | 2.35            |
| Ubuntu 24.04        | 2.39            |

例如，假设您要从 CentOS 7 升级到 RedHat
Enterprise 8。在这种情况下，在此升级后的操作系统上使用 PostgreSQL
需要采用上述两种方法之一，因为 `glibc` 从 2.17 升级到了 2.28。未能正确处理排序规则变化会导致极狐GitLab 出现严重故障，例如 runner 无法获取带有标签的作业。

另一方面，如果 PostgreSQL 已经在 `glibc` 2.28
或更高版本上运行且没有问题，那么您的索引应继续正常工作，无需进一步操作。例如，如果您已经在
RedHat Enterprise 8（`glibc` 2.28）上运行 PostgreSQL 一段时间，并想升级
到 RedHat Enterprise 9（`glibc` 2.34），则不应有排序规则相关问题。

<a id="verifying-glibc-collation-versions"></a>

### 验证 `glibc` 排序规则版本

对于 PostgreSQL 13 及更高版本，您可以使用以下 SQL 查询验证数据库排序规则版本是否与系统匹配：

```sql
SELECT collname AS COLLATION_NAME,
       collversion AS VERSION,
       pg_collation_actual_version(oid) AS actual_version
FROM pg_collation
WHERE collprovider = 'c';
```

<a id="matching-collation-example"></a>

### 排序规则匹配示例

例如，在 Ubuntu 22.04 系统上，索引正确的系统的输出如下所示：

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

<a id="mismatched-collation-example"></a>

### 排序规则不匹配示例

另一方面，如果您从 Ubuntu 18.04 升级到 22.04 而未重建索引，则可能会看到：

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

<a id="streaming-replication"></a>

## 流复制

损坏索引问题会影响 PostgreSQL 流复制。在允许对具有不同区域设置数据的副本进行读取之前，您必须[重建所有索引](#rebuild-all-indexes)或[仅重建受影响的索引](#rebuild-only-affected-indexes)。

<a id="additional-geo-variations"></a>

## 其他 Geo 变体

前面记录的升级过程并非一成不变。使用 Geo 时可能有更多选项，因为存在冗余基础设施。您可以考虑根据您的用例进行修改，但请务必权衡其带来的额外复杂度。以下是一些示例：

在主站点和其他从站点的操作系统升级期间，保留一个从站点作为热备以应对灾难：

1. 将从站点的数据与主站点上的变更隔离：暂停从站点。
1. 在主站点上执行操作系统升级。
1. 如果操作系统升级失败且主站点无法恢复，
   则提升从站点，将用户路由到该站点，并稍后重试。
   这会使您没有最新的从站点。

在操作系统升级期间为用户提供对极狐GitLab 的只读访问（部分停机）：

1. 在主站点上启用[维护模式](../maintenance_mode/_index.md)，而不是停止
   主站点。
1. 提升从站点，但暂时不要将用户路由到该站点。
1. 在提升后的站点上执行操作系统升级。
1. 将用户路由到提升后的站点，而不是旧的主站点。
1. 将旧的主站点设置为新的从站点。

> [!warning]
> 即使从站点已经有数据库的只读副本，您也不能在提升之前升级
> 其操作系统。如果您尝试这样做，那么由于索引损坏，从站点可能
> 会遗漏某些 Git 代码仓库或文件的复制。
> 请参阅[流复制](#streaming-replication)。
