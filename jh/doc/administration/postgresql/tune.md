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

当以下情况出现时，你应该调优 PostgreSQL：

- 其他极狐GitLab 组件以影响数据库的方式重新配置或扩展。
- 极狐GitLab 环境的性能受损。
- 极狐GitLab 使用[外部 PostgreSQL 服务](external.md)。

请将此信息与极狐GitLab 的[所需 PostgreSQL 设置](../../install/requirements.md#postgresql-settings)结合使用。

<a id="plan-your-database-connections"></a>

## 规划数据库连接

> [!note]
> 极狐GitLab 16.0 及更高版本为 `main` 和 `ci` 表
> [使用两组数据库连接](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections)。
> 即使同一个 PostgreSQL 数据库同时服务于两组表，这也会使连接使用量翻倍。

极狐GitLab 使用来自多个组件的数据库连接。正确的连接规划可以防止数据库连接耗尽和性能问题。

每个极狐GitLab 组件根据其配置使用数据库连接。
Sidekiq 和 Puma 在初始化时建立到 PostgreSQL 的连接池。
如果出现连接高峰或需求暂时增加，连接池中的连接数之后可能会增加：

- 使用环境变量 `DB_POOL_HEADROOM` 配置数据库池余量。
- 当你调优 PostgreSQL 时，要为池余量做好规划，但不要更改它。
  如果有更多容量可用，极狐GitLab 部署能更好地响应更高的需求：
  部署更多的 Sidekiq 或 Puma 工作器。

<a id="puma"></a>

### Puma

```plaintext
Puma 连接数 = puma['worker_processes'] × (puma['max_threads'] + DB_POOL_HEADROOM)
```

默认情况下：

- `puma['worker_processes']` 基于 CPU 核心数。
- `puma['max_threads']` 为 `4`。
- `DB_POOL_HEADROOM` 为 `10`。

每个工作器计算：每个 Puma 工作器使用 4 个线程 + 10 个余量，总计 14 个连接。

默认计算，假设 8 vCPU：8 个工作器 × 每个工作器 14 个连接，总计 112 个 Puma 连接。

<a id="sidekiq"></a>

### Sidekiq

```plaintext
Sidekiq 连接数 = Sidekiq 进程数 × (sidekiq['concurrency'] + 1 + DB_POOL_HEADROOM)
```

默认情况下：

- Sidekiq 进程数为 `1`。
- `sidekiq['concurrency']` 为 `20`。
- `DB_POOL_HEADROOM` 为 `10`。

默认计算：1 个 Sidekiq 进程 × (20 并发 + 1 + 10 余量)，总计 31 个 Sidekiq 连接。

<a id="geo-log-cursor-geo-installations-only"></a>

### Geo 日志游标（仅限 Geo 安装）

[Geo 日志游标](../../development/geo.md#geo-log-cursor-daemon)守护进程在次要站点上的所有极狐GitLab Rails 节点上运行。

```plaintext
Geo 日志游标连接数 = 1 + DB_POOL_HEADROOM
```

默认计算：1 + 10 余量，总计 11 个 Geo 连接。

<a id="total-connection-requirements"></a>

### 总连接需求

对于单节点安装：

```plaintext
总连接数 = 2 × (Puma + Sidekiq + Geo)
```

对于多节点安装，乘以运行每个组件的节点数量：

```plaintext
总连接数 = 2 × ((Puma × Rails 节点数) + (Sidekiq × Sidekiq 节点数) + (Geo × 次要 Rails 节点数))
```

乘以 2 是为了覆盖极狐GitLab 16.0 及更高版本中的
[双数据库连接](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections)。

对于 Geo 安装：

- 主站点：使用 `Geo = 0`。Geo 日志游标不在主站点上运行。
- 次要站点：为一个次要站点计算 Geo 日志游标数据库连接，并将
  相同的计算应用于所有次要站点。
- 每个 Geo 站点都连接到自己独立的数据库，因此你无需跨多个 Geo 站点汇总连接。
- 使用所有 Geo 站点中最高的连接需求，将主 PostgreSQL 数据库和所有副本数据库上的 `max_connections` 设置为相同的值。

<a id="examples"></a>

### 示例

<a id="single-node-installation"></a>

#### 单节点安装

此示例基于极狐GitLab 参考架构，面向
[20 RPS（每秒请求数）或 1000 用户](../reference_architectures/1k_users.md)：

| 组件       | 节点数 | 配置                        | 每个组件的连接数 | 组件总计，双数据库 |
|-----------|-------|----------------------------|-------------|------------|
| Puma      | 1     | 8 个工作器，每个 4 个线程         | 每个工作器 14 个  | 224        |
| Sidekiq   | 1     | 1 个进程，20 并发              | 每个进程 31 个   | 62         |
| 总计       |       |                            |             | 286        |

<a id="multi-node-installation"></a>

#### 多节点安装

此示例基于极狐GitLab 参考架构，面向
[40 RPS（每秒请求数）或 2000 用户](../reference_architectures/2k_users.md)：

| 组件       | 节点数 | 配置                            | 每个组件的连接数 | 组件总计，双数据库 |
|-----------|-------|--------------------------------|-------------|------------|
| Puma      | 2     | 每个节点 8 个工作器，每个 4 个线程         | 每个工作器 14 个  | 448        |
| Sidekiq   | 1     | 4 个进程，每个 20 并发               | 每个进程 31 个   | 248        |
| 总计       |       |                                |             | 696        |

<a id="single-node-installation-with-geo"></a>

#### 带 Geo 的单节点安装

此示例基于极狐GitLab 参考架构，面向
[20 RPS（每秒请求数）或 1000 用户](../reference_architectures/1k_users.md)。

| 每个 Geo 站点的组件                     | 节点数 | 配置                        | 每个组件的连接数 | 组件总计，双数据库 |
|---------------------------------------|-------|----------------------------|-------------|------------|
| Puma                                  | 1     | 8 个工作器，每个 4 个线程           | 每个工作器 14 个  | 224        |
| Sidekiq                               | 1     | 1 个进程，20 并发              | 每个进程 31 个   | 62         |
| Geo 日志游标（仅限次要站点）                  | 1     | 1 个进程                    | 每个进程 11 个   | 22         |
| 总计                                   |       |                            |             | 308        |

<a id="multi-node-installation-with-geo"></a>

#### 带 Geo 的多节点安装

此示例基于极狐GitLab 参考架构，面向
[40 RPS（每秒请求数）或 2000 用户](../reference_architectures/2k_users.md)：

| 每个 Geo 站点的组件                     | 节点数 | 配置                            | 每个组件的连接数 | 组件总计，双数据库 |
|---------------------------------------|-------|--------------------------------|-------------|------------|
| Puma                                  | 2     | 每个节点 8 个工作器，每个 4 个线程           | 每个工作器 14 个  | 448        |
| Sidekiq                               | 1     | 4 个进程，每个 20 并发               | 每个进程 31 个   | 248        |
| Geo 日志游标（仅限次要站点）                  | 2     | 每个 Rails 节点 1 个进程            | 每个进程 11 个   | 44         |
| 总计                                   |       |                                |             | 740        |