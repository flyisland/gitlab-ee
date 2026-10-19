---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 调优 PostgreSQL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在以下情况下，您应调优 PostgreSQL：

- 其他极狐GitLab 组件以影响数据库的方式重新配置或扩容。
- 您的极狐GitLab 环境性能受到影响。
- 极狐GitLab 使用[外部 PostgreSQL 服务](external.md)。

<a id="required-settings-for-external-instances"></a>

## 外部实例的必需设置

以下设置是外部管理的 PostgreSQL 实例所必需的。

| 可调优设置        | 必需值 | 更多信息 |
|:-----------------------|:---------------|:-----------------|
| `work_mem`             | 最低 `8 MB`  | 此值是 Linux 软件包的默认值。在大型部署中，如果查询会创建临时文件，您应增大此设置。 |
| `maintenance_work_mem` | 最低 `64 MB` | 对于更大的数据库服务器，您需要[更多内存](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8377#note_1728173087)。 |
| `max_connections`      | 最低 `400`   | 根据数据库主机能够承载的量来设置。请参阅[确定数据库主机的容量](#determine-your-database-host-capacity-max_connections)。连接需求公式给出的是前端需求，而非此值。 |
| `shared_buffers`       | 最低 `2 GB`  | 对于更大的数据库服务器，您需要更多内存。Linux 软件包的默认值设置为服务器 RAM 的 25%。 |
| `statement_timeout`    | 15000 到 60000 | 语句超时可防止锁失控以及数据库拒绝新客户端的问题。您应使用 15 到 60 秒（15000 到 60000 毫秒）之间的值，其中一分钟与 Puma rack 超时设置相匹配。 |
| `hot_standby_feedback` | `on` | 对于配置了多个节点和[数据库负载均衡](database_load_balancing.md#configure-database-load-balancing)的配置，请确保所有副本节点都启用了 `hot_standby_feedback`，以防止延迟累积。 |

您可以为特定数据库配置某些 PostgreSQL 设置，而不是为服务器上的所有数据库配置。

- 当在同一服务器上托管多个数据库时，您可以将配置限制为特定数据库。
- 有关在何处应用配置的指导，请咨询您的数据库管理员或供应商。
- 对于 GCP Cloud SQL，您可以在特定数据库或用户上设置 `statement_timeout`，但不能[作为数据库标志](https://cloud.google.com/sql/docs/postgres/flags#list-flags-postgres)设置。
  例如：`ALTER DATABASE gitlab SET statement_timeout = '60s';`

<a id="plan-your-database-connections"></a>

## 规划您的数据库连接

此公式计算应用程序的前端连接需求 - 即 Rails 向数据库（或向 PgBouncer）打开的连接数。这不是用于 PostgreSQL `max_connections`的值。有关如何确定 `max_connections`的大小，请参阅[确定数据库主机的容量](#determine-your-database-host-capacity-max_connections)。

> [!note]
> 极狐GitLab 16.0 及更高版本为 `main` 和 `ci` 表使用
> [两组数据库连接](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections)。
> 这会使连接使用量翻倍，即使同一 PostgreSQL 数据库
> 同时为这两组表提供服务也是如此。

极狐GitLab 使用来自多个组件的数据库连接。正确的连接规划可防止数据库连接耗尽和性能问题。

每个极狐GitLab 组件根据其配置使用数据库连接。
Sidekiq 和 Puma 在初始化时建立到 PostgreSQL 的连接池。
如果出现连接峰值或需求临时增加，池中的连接数稍后可能会增加：

- 使用环境变量 `DB_POOL_HEADROOM` 配置数据库池余量。
- 在调优 PostgreSQL 时，请为池余量做好规划，但不要更改它。
  如果有更多可用容量，极狐GitLab 部署能更好地应对更高的需求：
  部署更多的 Sidekiq 或 Puma 工作进程。

<a id="puma"></a>

### Puma

```plaintext
Puma connections = puma['worker_processes'] × (puma['max_threads'] + DB_POOL_HEADROOM)
```

默认情况下：

- `puma['worker_processes']` 基于 CPU 核心数。
- `puma['max_threads']` 为 `4`。
- `DB_POOL_HEADROOM` 为 `10`。

每个工作进程的计算：每个 Puma 工作进程使用 4 个线程 + 10 个余量，共 14 个连接。

默认计算，假设 8 个 vCPU：8 个工作进程 × 每个工作进程 14 个连接，共 112 个 Puma 连接。

<a id="sidekiq"></a>

### Sidekiq

```plaintext
Sidekiq connections = Number of Sidekiq processes × (sidekiq['concurrency'] + 1 + DB_POOL_HEADROOM)
```

默认情况下：

- Sidekiq 进程数为 `1`。
- `sidekiq['concurrency']` 为 `20`。
- `DB_POOL_HEADROOM` 为 `10`。

默认计算：1 个 Sidekiq 进程 ×（20 个并发 + 1 + 10 个余量），共 31 个 Sidekiq 连接。

<a id="geo-log-cursor-geo-installations-only"></a>

### Geo Log Cursor（仅限 Geo 安装）

[Geo Log Cursor](../../development/geo.md#geo-log-cursor-daemon) 守护进程在从站点中的所有 GitLab Rails 节点上运行。

```plaintext
Geo log cursor connections = 1 + DB_POOL_HEADROOM
```

默认计算：1 + 10 个余量，共 11 个 Geo 连接。

<a id="total-connection-requirements"></a>

### 总连接需求

对于单节点安装：

```plaintext
Total connections = 2 × (Puma + Sidekiq + Geo)
```

对于多节点安装，乘以运行每个组件的节点数：

```plaintext
Total connections = 2 × ((Puma × Rails nodes) + (Sidekiq × Sidekiq nodes) + (Geo × secondary Rails nodes))
```

乘以 2 是为了计入[双重数据库连接](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections)。

对于 Geo 安装：

- 主站点：使用 `Geo = 0`。Geo Log Cursor 不在主站点上运行。
- 从站点：计算一个从站点的 Geo Log Cursor 数据库连接，并将
  相同的计算应用于所有从站点。
- 每个 Geo 站点连接到各自的数据库，因此您无需跨多个 Geo 站点汇总连接。
- 在主 PostgreSQL 数据库和所有副本数据库上将 `max_connections` 设置为相同的值，
  使用所有 Geo 站点中最高的连接需求。

<a id="examples"></a>

### 示例

<a id="single-node-installation"></a>

#### 单节点安装

此示例基于 [20 RPS（每秒请求数）或 1000 个用户](../reference_architectures/1k_users.md)的极狐GitLab 参考架构：

| 组件 | 节点数 | 配置             | 每个组件的连接数 | 组件总计，双重数据库 |
|-----------|-------|---------------------------|---------------------------|---------------------------------|
| Puma      | 1     | 8 个工作进程，每个 4 个线程 | 每个工作进程 14 个             | 224                             |
| Sidekiq   | 1     | 1 个进程，20 个并发 | 每个进程 31 个            | 62                              |
| 总计     |       |                           |                           | 286                             |

<a id="multi-node-installation"></a>

#### 多节点安装

此示例基于 [40 RPS（每秒请求数）或 2000 个用户](../reference_architectures/2k_users.md)的极狐GitLab 参考架构：

| 组件 | 节点数 | 配置                      | 每个组件的连接数 | 组件总计，双重数据库 |
|-----------|-------|------------------------------------|---------------------------|--------------------------------|
| Puma      | 2     | 每个节点 8 个工作进程，每个 4 个线程 | 每个工作进程 14 个             | 448                            |
| Sidekiq   | 1     | 4 个进程，每个 20 个并发   | 每个进程 31 个            | 248                            |
| 总计     |       |                                    |                           | 696                            |

<a id="single-node-installation-with-geo"></a>

#### 带 Geo 的单节点安装

此示例基于 [20 RPS（每秒请求数）或 1000 个用户](../reference_architectures/1k_users.md)的极狐GitLab 参考架构。

| 每个 Geo 站点的组件                | 节点数 | 配置             | 每个组件的连接数 | 组件总计，双重数据库 |
|---------------------------------------|-------|---------------------------|---------------------------|--------------------------------|
| Puma                                  | 1     | 8 个工作进程，每个 4 个线程 | 每个工作进程 14 个             | 224                            |
| Sidekiq                               | 1     | 1 个进程，20 个并发 | 每个进程 31 个            | 62                             |
| Geo Log Cursor（仅限从站点） | 1     | 1 个进程                 | 每个进程 11 个            | 22                             |
| 总计                                 |       |                           |                           | 308                            |

<a id="multi-node-installation-with-geo"></a>

#### 带 Geo 的多节点安装

此示例基于 [40 RPS（每秒请求数）或 2000 个用户](../reference_architectures/2k_users.md)的极狐GitLab 参考架构：

| 每个 Geo 站点的组件                | 节点数 | 配置                      | 每个组件的连接数 | 组件总计，双重数据库 |
|---------------------------------------|-------|------------------------------------|---------------------------|--------------------------------|
| Puma                                  | 2     | 每个节点 8 个工作进程，每个 4 个线程 | 每个工作进程 14 个             | 448                            |
| Sidekiq                               | 1     | 4 个进程，每个 20 个并发   | 每个进程 31 个            | 248                            |
| Geo Log Cursor（仅限从站点） | 2     | 每个 Rails 节点 1 个进程           | 每个进程 11 个            | 44                             |
| 总计                                 |       |                                    |                           | 740                            |

<a id="determine-your-database-host-capacity-max_connections"></a>

## 确定数据库主机的容量（`max_connections`）

`max_connections` 受限于数据库主机实际能够承载的量 - 这是 CPU、内存和 IO 容量的函数。它并非源自应用程序的连接需求公式。

- 作为一般规则，将 `max_connections` 设置为 vCPU 数量的倍数，通常在 2-10 倍范围内。这只是一个起点：
  主机能够维持的值还取决于可用内存、IO 容量和工作负载。
- 如需更精细的调优，请使用 [PGTune](https://pgtune.leopard.in.ua/)，它会考虑内存、存储
  类型和工作负载。
- 如果您使用托管的 PostgreSQL 数据库（RDS、Cloud SQL、Azure Database for PostgreSQL），请参阅
  供应商的文档。
- 更改 `max_connections` 值需要重启所有 PostgreSQL 节点。

对于 Geo 安装，请在主 PostgreSQL 数据库和
所有副本数据库上将 `max_connections` 设置为相同的值。有关 Geo 特定的指导，请参阅[总连接需求](#total-connection-requirements)。

<a id="size-connections-for-your-topology"></a>

## 为您的拓扑确定连接大小

根据 PgBouncer 是否位于应用程序和数据库之间，使用以下指导。

<a id="without-pgbouncer"></a>

### 不使用 PgBouncer

应用程序直接连接到 PostgreSQL，因此需求计算中的每个连接都必须由后端提供服务。

1. 使用
   [规划您的数据库连接](#plan-your-database-connections)公式计算总前端连接需求。
1. 在主机能够承载的前提下，将 PostgreSQL `max_connections` 至少设置为该值。
   请参阅[确定数据库主机的容量](#determine-your-database-host-capacity-max_connections)。
1. 如果总连接需求超出主机能够承载的量 - 粗略地说，当它超过
   2-10 倍 vCPU 范围，或使 CPU、内存或 IO 超出健康水平时 - 不要将
   `max_connections` 提高到与之匹配。这明确表明该安装需要连接池。
   添加 PgBouncer 并按[使用 PgBouncer](#with-pgbouncer)中所述确定其大小。

<a id="with-pgbouncer"></a>

### 使用 PgBouncer

PgBouncer 对连接进行池化，因此应用程序的前端需求和数据库的后端连接是分别确定大小的。

在 PgBouncer 术语中：

- `pgbouncer['max_client_conn']` 是前端池：从 Rails 到 PgBouncer 的连接。
- `pgbouncer['default_pool_size']` 是后端池：从 PgBouncer 到数据库的连接。
  此值按池（每个数据库/用户对）确定大小。由于极狐GitLab 为 `main` 和 `ci`
  打开单独的池，因此后端池预算必须计入每个
  PgBouncer 节点的两个池。

在使用 PgBouncer 时确定连接大小：

1. 使用
   [规划您的数据库连接](#plan-your-database-connections)公式计算最坏情况下的前端连接需求。
1. 将该总数除以 PgBouncer 节点数，并将结果乘以 2，作为每个
   节点的 `pgbouncer['max_client_conn']`。
1. 根据
   [数据库主机能够承载的量](#determine-your-database-host-capacity-max_connections)确定 PostgreSQL `max_connections`，
   而不是根据前端需求公式。
1. 将该 `max_connections` 值除以 PgBouncer 节点数，并将结果用作
   每个节点的 `pgbouncer['default_pool_size']`。

有关这些参数的详细参考，请参阅
PgBouncer 文档中的[精细调优](pgbouncer.md#fine-tuning)。
