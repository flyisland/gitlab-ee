---
stage: Data Access
group: Database Health
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 调整 PostgreSQL autovacuum
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用本页面调整 PostgreSQL autovacuum，并排查常见的 autovacuum 问题。

<a id="how-autovacuum-works"></a>

## autovacuum 的工作原理

PostgreSQL 使用[多版本并发控制 (MVCC)](https://www.postgresql.org/docs/current/mvcc-intro.html)。
当您更新或删除一行时，PostgreSQL 不会立即移除旧的行版本。相反，PostgreSQL 会将旧版本标记为已死亡，并保留它，直到没有任何正在运行的事务仍能看到它。autovacuum 是移除这些死亡行版本（也称为死亡元组）的后台进程。它回收这些元组占用的空间，更新计划器统计信息，并维护可见性映射。

autovacuum 对数据库健康至关重要。没有它，死亡行会累积成表和索引膨胀。膨胀会拖慢查询、浪费磁盘空间，并延长备份和维护时间。
autovacuum 还能防止
[事务 ID 回卷](https://www.postgresql.org/docs/current/routine-vacuuming.html#VACUUM-FOR-WRAPAROUND)，否则数据库将停止接受写入。

<a id="when-autovacuum-runs"></a>

### autovacuum 何时运行

autovacuum 会定期检查每个表，并在死亡元组数量超过以下阈值时运行 vacuum：

```plaintext
autovacuum_vacuum_threshold + autovacuum_vacuum_scale_factor × number_of_live_tuples
```

默认情况下，PostgreSQL 将 `autovacuum_vacuum_scale_factor` 设置为 `0.2`。因此，PostgreSQL 只有在表中 20% 的行变为死亡后才会对该表执行 vacuum。对于大表，20% 意味着大量死亡元组。这样，表会在 autovacuum 采取行动之前长时间膨胀。为减少这种延迟，极狐GitLab Linux 软件包安装默认将 `autovacuum_vacuum_scale_factor` 降低到 `0.02`（2%）。最大或更新最频繁的表可能仍需要更低的单表值。请参阅[单独调整大表](#tune-large-tables-individually)。

<a id="recommended-autovacuum-settings"></a>

## 推荐的 autovacuum 设置

极狐GitLab Linux 软件包安装附带的 autovacuum 默认值适用于大多数工作负载。当[监控](#monitor-autovacuum)显示 autovacuum 无法跟上死亡元组的产生速度时，请更改这些设置。目标是让 autovacuum 以与您的工作负载产生死亡元组相同的速度回收它们，同时不让数据库的 I/O 资源枯竭。

影响最大的更改通常是提高 `autovacuum_vacuum_cost_limit`、提高 `autovacuum_max_workers`，以及降低最大表的比例因子。请将本节中的值视为起点，并针对您自己的工作负载进行验证。

<a id="cluster-wide-settings"></a>

### 集群范围设置

对于极狐GitLab Linux 软件包安装，请在 `/etc/gitlab/gitlab.rb`中设置集群范围的值，然后运行
`sudo gitlab-ctl reconfigure`。

```ruby
postgresql['autovacuum_max_workers'] = "<value>"
postgresql['autovacuum_vacuum_cost_limit'] = "<value>"
postgresql['autovacuum_vacuum_cost_delay'] = "<value>"
postgresql['maintenance_work_mem'] = "<value>"
```

对于[外部 PostgreSQL 实例](external.md)，请在 `postgresql.conf`中设置相同的参数，
然后重新加载 PostgreSQL：

```ini
autovacuum_max_workers = <value>
autovacuum_vacuum_cost_limit = <value>
autovacuum_vacuum_cost_delay = <value>
maintenance_work_mem = <value>
autovacuum_work_mem = <value>
```

使用 `SELECT pg_reload_conf();` 或重新加载服务来重新加载 PostgreSQL。对于这两种安装类型，诸如 `autovacuum_max_workers` 之类的设置都需要完全重启 PostgreSQL。仅重新加载或重新配置是不够的。

以下设置对 autovacuum 能否跟上进度影响最大：

| 设置                          | 推荐值           | 描述                                                                                                                                                                                                                                                                                                                                                 |
|----------------------------------|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `autovacuum_max_workers`         | 约为 vCPU 数量的 25% | 同时运行的 autovacuum 进程的最大数量。对于大型多核数据库主机，默认值通常过低。每个工作进程都会增加内存和 I/O 负载。                                                                                                                                                                                  |
| `autovacuum_vacuum_scale_factor` | `0.01` 到 `0.02`            | 在 autovacuum 运行之前，表中必须变为死亡的行所占的比例。极狐GitLab 将 PostgreSQL 默认值降低到 `0.02`。对于大型、频繁更新的表，请进一步降低该值。请参阅[单独调整大表](#tune-large-tables-individually)。                                                                                                          |
| `autovacuum_vacuum_cost_limit`   | SSD 为 800                 | autovacuum 在暂停之前累积的 I/O 成本。设置为 `-1` 时，它会继承 `vacuum_cost_limit`的值。该值远低于现代 SSD 存储的吞吐量。请显式设置它。提高它通常是影响最大的更改。                                                                                                         |
| `autovacuum_vacuum_cost_delay`   | 2 ms                        | autovacuum 达到成本限制后暂停的时间。降低它可使 autovacuum 更积极。切勿将其设置为 `0`。请参阅[应避免的设置](#settings-to-avoid)。                                                                                                                                                                                      |
| `maintenance_work_mem`           | 1 GB 到 2 GB                | 用于索引创建等维护操作的内存。当 `autovacuum_work_mem` 为 `-1` 时，每个 autovacuum 工作进程也会使用这么多内存来跟踪死亡元组。值过低会导致工作进程在大表上反复扫描索引。请根据可用 RAM 和工作进程数量来确定其大小。                                                                   |
| `autovacuum_work_mem`            | 512 MB                      | 每个 autovacuum 工作进程用于跟踪死亡元组的内存。设置为 `-1` 时，工作进程会继承 `maintenance_work_mem`。此时 autovacuum 的总内存会随工作进程数量而扩展。PostgreSQL 17 移除了此内存的 1 GB 上限。提高工作进程数量时，请显式限制它。Linux 软件包安装无法在 `gitlab.rb`中设置此参数。 |
| `autovacuum_naptime`             | 几秒（可选）    | autovacuum 在两次检查数据库之间等待的时间。对于变动频繁的数据库，请降低该值，以便 autovacuum 更快响应。                                                                                                                                                                                                                                  |

<a id="tune-large-tables-individually"></a>

### 单独调整大表

即使集群范围的比例因子很低，最大的表也可能膨胀。对于这些表，请直接在 PostgreSQL 中设置更低的单表比例因子或阈值。对于非常大、频繁更新的表，比例因子通常约为 `0.01`（1%）：

```sql
ALTER TABLE <table_name> SET (autovacuum_vacuum_scale_factor = 0.01);
```

单表设置仅覆盖该表的集群范围值。使用[监控](#monitor-autovacuum)找出哪些表落后，并先在非生产环境中测试更改。

<a id="settings-to-avoid"></a>

### 应避免的设置

> [!warning]
> 不要禁用 autovacuum（`autovacuum = off`）。没有 autovacuum，死亡元组会累积。数据库
> 随后会走向事务 ID 回卷。回卷会导致数据库停止
> 接受写入。

避免以下配置：

- `autovacuum_vacuum_cost_delay = 0` 会移除 I/O 节流。此时 autovacuum 会不间断地运行，
  并可能使磁盘 I/O 饱和。查询会变慢。
- 在最大的表上使用默认比例因子。这些表会因此很少被 vacuum。请改为设置更低的
  单表值。
- 依赖 `-1` 继承来设置 `autovacuum_vacuum_cost_limit`。此时有效值存在于
  另一个设置中，您可能会忽略它。请显式设置它。

<a id="monitor-autovacuum"></a>

## 监控 autovacuum

<a id="database-diagnostics-page"></a>

### 数据库诊断页面

数据库诊断页面显示每个数据库的 vacuum 活动和 autovacuum 设置。

先决条件：

- 您必须具有管理员访问权限。

查看该页面：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **数据库诊断**。

该页面有两个部分与 autovacuum 相关。每个部分为安装中的每个数据库各显示一张卡片。

**VACUUM 信息**部分包含 **清理活动**面板。该面板为当前正在运行的每个 vacuum 显示一行。各列为表格、类型、已运行、阶段、堆已扫描、已处理的索引、死元组、索引通过和延迟时间。一行可以带有以下徽章：

- **防回卷**：该 vacuum 正在防止事务 ID 回卷。此 vacuum 不会
  自动取消。请勿终止它。如果终止，数据库可能会为了保护数据而关闭。
- **长时间运行**：该 vacuum 已运行超过 6 小时。大表可能需要这么长时间，
  但一个永远无法完成的 vacuum 可能被阻塞或资源不足。
- **内存压力**：该 vacuum 需要多次索引扫描。死亡元组存储在堆扫描完成之前
  就已填满。请提高 `maintenance_work_mem` 或 `autovacuum_work_mem`。

**Autovacuum configuration**部分包含以下面板：

- **Effective settings**：数据库实际使用的 autovacuum 设置，读取自
  `pg_settings`。**Status** 列会标记检查发现的每个错误配置。当
  `autovacuum_vacuum_cost_limit` 为 `-1` 时，该面板还会显示它从
  `vacuum_cost_limit` 继承的有效限制。
- **Per-table overrides**：在其存储参数中设置了 autovacuum 参数的表。
  该面板显示每个表的大小、估计行数和覆盖项。禁用 autovacuum 的表会带有 **Autovacuum disabled** 徽章。该面板最多列出 50 个表，
  禁用 autovacuum 的表排在最前。当没有任何表有覆盖项时，该面板会隐藏。
- **Scale factor risk**：生效比例因子仍然很高的大表。当检查未发现此类表时，
  该面板会隐藏。

有些发现涉及某个表，而不是单个设置。这些发现会作为提醒显示在面板上方。有关每项发现背后的条件，请参阅 [autovacuum 发现项](#autovacuum-findings)。

> [!note]
> **清理活动**面板需要 PostgreSQL 17 或更高版本。在更早的版本上，该面板为
> 空。延迟时间 列需要 PostgreSQL 18 或更高版本。类型和已运行 列，以及
> **防回卷** 徽章，需要能够读取其他后端活动的数据库角色。请授予该角色
> `pg_monitor` 成员资格。没有此成员资格时，进度
> 列仍然可用，但类型、已运行和防回卷字段会显示 `Not available`。

这两个部分都从主数据库读取，因为 autovacuum 仅在那里运行。

<a id="report-diagnostics-on-the-console"></a>

### 在控制台上报告诊断信息

当您无法访问 UI，或希望从脚本获取报告时，请使用 Rake 任务。

对于 Linux 软件包安装：

```shell
sudo gitlab-rake gitlab:db:diagnostics
```

默认情况下，该任务会报告每个数据库。要选择数据库，请传入它们的名称：

```shell
sudo gitlab-rake "gitlab:db:diagnostics[main,ci]"
```

要仅运行 autovacuum 检查，请使用它自己的任务。它接受相同的数据库名称：

```shell
sudo gitlab-rake "gitlab:db:diagnostics:autovacuum_settings[main,ci]"
```

报告会先打印摘要，然后为每项检查打印一个部分。**Autovacuum settings**部分会列出每个数据库的发现项、有效设置、单表覆盖项和比例因子风险。

当该任务发现错误时，会以状态 `1` 退出，因此监控作业可以使用该退出代码。

在终端中，当该任务运行多项检查时，会显示一个菜单以打开每个部分。当它运行一项检查时，或者当您通过管道传输或重定向输出时，该任务会打印整个报告。

> [!note]
> Rake 任务仅报告设置。它不显示 vacuum 活动。Vacuum 活动
> 仅在[数据库诊断页面](#database-diagnostics-page)上提供。

<a id="autovacuum-findings"></a>

### autovacuum 发现项

数据库诊断页面和 Rake 任务使用相同的检查。两者报告相同的发现项。前五项发现各涉及一个设置，并显示在**Effective settings**面板的 **Status** 列中。最后两项涉及表，并作为提醒显示。

| 发现项             | 设置                          | 严重性 | 报告条件                                                                                                                                                                                                                                                                                                                                             | 操作                                                                                                                                                                                                                  |
|---------------------|----------------------------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Disabled            | `autovacuum`                     | 错误    | `autovacuum` 为 `off`。死亡元组永远不会被自动回收。这会导致膨胀风险，并最终导致事务 ID 回卷。                                                                                                                                                                                                                          | 开启 autovacuum。请参阅[应避免的设置](#settings-to-avoid)。                                                                                                                                                        |
| Throttling disabled | `autovacuum_vacuum_cost_delay`   | 错误    | 成本延迟为 `0`。此时 autovacuum 会全速运行。这可能导致写入风暴和复制延迟。                                                                                                                                                                                                                                               | 设置非零延迟。请参阅[应避免的设置](#settings-to-avoid)。                                                                                                                                                      |
| Low                 | `autovacuum_max_workers`         | 警告  | 配置的工作进程少于三个。对于大型或已拆分的数据库，这可能过少。                                                                                                                                                                                                                                                          | 提高工作进程数量。请参阅[集群范围设置](#cluster-wide-settings)。                                                                                                                                            |
| Low                 | `autovacuum_vacuum_cost_limit`   | 警告  | 有效限制为 `200` 或更低。对于现代存储，该限制可能过低。当该设置为 `-1` 时，检查使用从 `vacuum_cost_limit` 继承的值。Linux 软件包安装默认附带 `-1`。`vacuum_cost_limit`的 PostgreSQL 默认值为 `200`。因此，此发现项会出现在默认的 Linux 软件包安装上。 | 显式设置该限制。请参阅[集群范围设置](#cluster-wide-settings)。                                                                                                                                          |
| Inherited           | `autovacuum_work_mem`            | 警告  | 该设置为 `-1`。每个工作进程会继承 `maintenance_work_mem`。                                                                                                                                                                                                                                                                                         | 显式设置它以限制每个工作进程使用的内存。Linux 软件包安装无法在 `gitlab.rb`中设置此参数；请改为调整 `maintenance_work_mem`。请参阅[集群范围设置](#cluster-wide-settings)。 |
| Tables disabled     | 单表 `autovacuum_enabled`   | 错误    | 一个或多个表在其存储参数中设置了 `autovacuum_enabled = false`。它们的死亡元组永远不会被自动回收。**Per-table overrides**面板会标记每个此类表。                                                                                                                                                            | 使用 `ALTER TABLE <table_name> RESET (autovacuum_enabled);` 为每个表重新开启 autovacuum。                                                                                                                     |
| Scale factor risk   | `autovacuum_vacuum_scale_factor` | 警告  | 集群范围的比例因子为 `0.1` 或更高，并且 20 个最大的表之一为 10 GiB 或更大，且生效比例因子为 `0.1` 或更高。Linux 软件包安装附带 `0.02`。因此，此发现项主要出现在保留 PostgreSQL 默认值 `0.2`的外部 PostgreSQL 实例上。                                             | 降低集群范围的比例因子，或在列出的表上设置单表值。请参阅[单独调整大表](#tune-large-tables-individually)。                                                              |

生效比例因子在设置了单表覆盖项时为该覆盖项，否则为集群范围的值。单表的 `autovacuum_vacuum_threshold` 不会使表豁免。该检查会跳过禁用了
autovacuum 的表。

> [!note]
> 这些检查仅报告明确的错误配置。这些检查还使用比
> [推荐的 autovacuum 设置](#recommended-autovacuum-settings)中的值更低的阈值。某个设置可能
> 通过检查，但对您的工作负载来说仍然过低。例如，三个 autovacuum 工作进程
> 可以通过检查，但对于拥有许多 vCPU 的主机来说偏低。

<a id="check-dead-tuples-and-freeze-age"></a>

### 检查死亡元组和冻结年龄

数据库诊断页面和 Rake 任务都不会报告每个表的死亡元组或冻结年龄。请改为查询数据库以获取该信息。在 Linux 软件包安装上，使用以下命令连接：

```shell
sudo gitlab-psql
```

要查找死亡元组最多的表，以及 autovacuum 上次处理它们的时间：

```sql
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum, last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC
LIMIT 20;
```

`n_dead_tup` 计数不断上升，而 `last_autovacuum` 陈旧或为空，意味着 autovacuum 无法跟上该表。请参阅
[autovacuum 无法跟上某个表](#autovacuum-cannot-keep-up-with-a-table)。

要查找每个表的冻结年龄：

```sql
SELECT n.nspname AS schema_name, c.relname AS table_name, age(c.relfrozenxid) AS xid_age
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY xid_age DESC
LIMIT 20;
```

`xid_age` 统计 PostgreSQL 上次冻结该表之后运行的事务数。请将其与 `autovacuum_freeze_max_age` 进行比较。**Effective settings**面板会报告该值。当某个
表超过该值时，PostgreSQL 会对它启动防回卷 autovacuum。冻结年龄
持续上升意味着 autovacuum 无法足够快地冻结行。请参阅[事务 ID 回卷即将发生](#transaction-id-wraparound-is-approaching)。

<a id="troubleshoot-common-issues"></a>

## 排查常见问题

<a id="autovacuum-cannot-keep-up-with-a-table"></a>

### autovacuum 无法跟上某个表

某个表累积死亡元组的速度快于 autovacuum 移除它们的速度。死亡元组计数持续上升，表发生膨胀，针对它的查询变慢。此问题有两个常见原因：

- 变更速率高。数据库迁移，或频繁更新行的端点，产生
  死亡元组的速度快于 autovacuum 清理它们的速度。
- 使用集群范围设置的繁忙表。大型、频繁更新的表通常需要
  它们自己的 autovacuum 设置。

要找出哪些表落后，请检查每个表的死亡元组计数和 autovacuum 上次运行的时间。请参阅[监控 autovacuum](#monitor-autovacuum)。要解决该问题：

- 设置更低的单表比例因子或阈值。有关更多信息，请参阅
  [单独调整大表](#tune-large-tables-individually)。
- 提高 `autovacuum_vacuum_cost_limit` 和 `autovacuum_max_workers`。有关更多信息，请参阅
  [推荐的 autovacuum 设置](#recommended-autovacuum-settings)。
- 如果迁移或应用程序更改是变动的来源，请暂停或回退它。

<a id="transaction-id-wraparound-is-approaching"></a>

### 事务 ID 回卷即将发生

PostgreSQL 为每个事务分配一个 ID (XID)。随着最旧的未冻结 XID 变老，PostgreSQL 会运行
防回卷 autovacuum 来冻结旧行。如果这些 vacuum 无法完成，数据库最终会停止接受写入以保护您的数据。

要跟踪此风险，请监控每个数据库和表的冻结年龄。请参阅
[监控 autovacuum](#monitor-autovacuum)。冻结年龄上升意味着 autovacuum 冻结
行的速度不够快。

要解决它，请确保 autovacuum 正在运行且未被阻塞。请参阅 [autovacuum 无法跟上某个表](#autovacuum-cannot-keep-up-with-a-table)。如果数据库已停止接受写入，请遵循[数据库不接受命令以避免回卷数据丢失](../troubleshooting/postgresql.md#database-is-not-accepting-commands-to-avoid-wraparound-data-loss)中的恢复步骤。

<a id="autovacuum-uses-too-many-resources"></a>

### autovacuum 使用过多资源

autovacuum 会产生 I/O 流量，可能拖慢其他查询。PostgreSQL 通过基于成本的延迟来限制此流量。该延迟在所有正在运行的 autovacuum 工作进程之间平衡分配。因此，无论运行多少个工作进程，总 I/O 影响大致相同。

要减少对其他查询的影响，请提高 `autovacuum_vacuum_cost_delay`，使工作进程更频繁地暂停。更高的延迟会减慢 vacuum 速度。请在延迟与跟上死亡元组的需求之间取得平衡。切勿将延迟设置为 `0`。这会完全移除节流。有关更多信息，请参阅[应避免的设置](#settings-to-avoid)。
