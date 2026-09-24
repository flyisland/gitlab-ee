---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 监控 Gitaly
---

使用可用日志和 [Prometheus 指标](../monitoring/prometheus/_index.md) 监控 Gitaly。

指标定义可通过以下方式获取：

- 直接从为 Gitaly 配置的 Prometheus `/metrics` 端点获取。
- 在已针对 Prometheus 配置的 Grafana 实例上使用 [Grafana Explore](https://grafana.com/docs/grafana/latest/explore/)。

Gitaly 可配置为根据请求并发数（自适应或非自适应）限制请求。

<a id="monitor-gitaly-concurrency-limiting"></a>

## 监控 Gitaly 并发限制

你可以使用 Gitaly 日志和 Prometheus 观察 [并发排队请求](concurrency_limiting.md#limit-rpc-concurrency) 的特定行为。

在 [Gitaly 日志](../logs/_index.md#gitaly-logs) 中，你可以识别与 pack-objects 并发限制相关的日志条目，例如：

| 日志字段                        | 描述 |
|----------------------------------|-------------|
| `limit.concurrency_queue_length` | 表示当前正在进行的调用的 RPC 类型特定队列的当前长度。它提供了对因并发限制而等待处理的请求数量的洞察。 |
| `limit.concurrency_queue_ms`     | 表示请求因并发 RPC 限制而在队列中等待的时长（毫秒）。该字段有助于理解并发限制对请求处理时间的影响。 |
| `limit.concurrency_dropped`      | 如果请求因达到限制而被丢弃，此字段指定原因：`max_time`（请求在队列中等待的时间超过最大允许时间）或 `max_size`（队列达到最大大小）。 |
| `limit.limiting_key`             | 标识用于限制的键。 |
| `limit.limiting_type`            | 指定被限制的进程类型。在此上下文中为 `per-rpc`，表示并发限制按单个 RPC 应用。 |

例如：

```json
{
  "limit.concurrency_queue_length": 1,
  "limit.concurrency_queue_ms": 0,
  "limit.limiting_key": "@hashed/79/02/7902699be42c8a8e46fbbb450172651786b22c56a189f7625a6da49081b2451.git",
  "limit.limiting_type": "per-rpc"
}
```

在 Prometheus 中，查找以下指标：

- `gitaly_concurrency_limiting_in_progress` 表示当前正在处理的并发请求数。
- `gitaly_concurrency_limiting_queued` 表示因达到并发限制而等待的指定仓库的 RPC 请求数。
- `gitaly_concurrency_limiting_acquiring_seconds` 表示请求因并发限制在开始处理之前需等待的时长。
- `gitaly_requests_dropped_total` 提供因请求限制而丢弃的请求总数。`reason` 标签指示请求被丢弃的原因：
  - `max_size`，因为达到了并发队列大小。
  - `max_time`，因为请求超过了 Gitaly 中配置的最大队列等待时间。

<a id="monitor-gitaly-pack-objects-concurrency-limiting"></a>

## 监控 Gitaly pack-objects 并发限制

你可以使用 Gitaly 日志和 Prometheus 观察 [pack-objects 限制](concurrency_limiting.md#limit-pack-objects-concurrency) 的特定行为。

在 [Gitaly 日志](../logs/_index.md#gitaly-logs) 中，你可以识别与 pack-objects 并发限制相关的日志条目，例如：

| 日志字段                        | 描述 |
|:---------------------------------|:------------|
| `limit.concurrency_queue_length` | pack-objects 进程的队列当前长度。表示因并发进程限制已达到而等待处理的请求数。 |
| `limit.concurrency_queue_ms`     | 请求在队列中等待的时长（毫秒）。表示请求因并发限制而必须等待的时间。 |
| `limit.limiting_key`             | 发送者的远程 IP。 |
| `limit.limiting_type`            | 被限制的进程类型。此情况下为 `pack-objects`。 |

示例配置：

```json
{
  "limit.concurrency_queue_length": 1,
  "limit.concurrency_queue_ms": 0,
  "limit.limiting_key": "1.2.3.4",
  "limit.limiting_type": "pack-objects"
}
```

在 Prometheus 中，查找以下指标：

- `gitaly_pack_objects_in_progress` 表示当前并发处理的 pack-objects 进程数。
- `gitaly_pack_objects_queued` 表示因达到并发限制而等待的 pack-objects 请求数。
- `gitaly_pack_objects_acquiring_seconds` 表示 pack-object 进程的请求因并发限制在开始处理之前需等待的时长。

<a id="monitor-gitaly-adaptive-concurrency-limiting"></a>

## 监控 Gitaly 自适应并发限制

{{< history >}}

- 在极狐GitLab 16.6 中引入。

{{< /history >}}

你可以使用 Gitaly 日志和 Prometheus 观察 [自适应并发限制](concurrency_limiting.md#adaptive-concurrency-limiting) 的特定行为。

自适应并发限制是静态并发限制的扩展，因此所有适用于 [静态并发限制](#monitor-gitaly-concurrency-limiting) 的指标和日志在监控自适应限制时也仍然相关。此外，自适应限制引入了几个特定指标，有助于监控限制的动态调整。

<a id="adaptive-limiting-logs"></a>

### 自适应限制日志

在 [Gitaly 日志](../logs/_index.md#gitaly-logs) 中，当当前限制被调整时，你可以识别与自适应并发限制相关的日志。 你可以通过日志内容（`msg`）过滤 "Multiplicative decrease" 和 "Additive increase" 消息。

这些调试日志仅在调试严重级别可用，并且可能很详细，但它们提供了自适应限制调整的详细洞察。

| 日志字段        | 描述 |
|:-----------------|:------------|
| `limit`          | 正在被调整的限制的名称。 |
| `previous_limit` | 增加或减少之前的先前限制。 |
| `new_limit`      | 增加或减少之后的新限制。 |
| `watcher`        | 决定节点处于压力之下的资源监视器。例如：`CgroupCpu` 或 `CgroupMemory`。 |
| `reason`         | 限制调整背后的原因。 |
| `stats.*`        | 调整决策背后的一些统计信息。它们用于调试目的。 |

示例日志：

```json
{
  "msg": "Multiplicative decrease",
  "limit": "pack-objects",
  "new_limit": 14,
  "previous_limit": 29,
  "reason": "cgroup CPU throttled too much",
  "watcher": "CgroupCpu",
  "stats.time_diff": 15.0,
  "stats.throttled_duration": 13.0,
  "stat.sthrottled_threshold": 0.5
}
```

<a id="adaptive-limiting-metrics"></a>

### 自适应限制指标

在 Prometheus 中，查找以下指标：

适用于静态和自适应限制的通用并发限制指标：

- `gitaly_concurrency_limiting_in_progress` - 正在处理的请求数。
- `gitaly_concurrency_limiting_queued` - 因并发限制而等待在队列中的请求数。
- `gitaly_concurrency_limiting_acquiring_seconds` - 请求因并发限制在开始处理之前等待所花费的时间。

自适应并发限制特定指标：

- `gitaly_concurrency_limiting_current_limit` - 显示每种 RPC 类型的自适应并发限制的当前限制值的仪表盘。仅自适应限制包含在此指标中。
- `gitaly_concurrency_limiting_backoff_events_total` - 表示退避事件总数的计数器，表示由于资源压力导致限制减少的时间和原因。
- `gitaly_concurrency_limiting_watcher_errors_total` - 跟踪 Gitaly 无法检索资源数据时发生的错误的计数器，这可能影响 Gitaly 评估当前资源状况的能力。

在调查自适应限制问题时，将这些指标与通用并发限制指标和日志相关联，以全面了解系统行为。

<a id="monitor-gitaly-cgroups"></a>

## 监控 Gitaly cgroups

你可以使用 Prometheus 观察 [控制组（cgroups）](configure_gitaly.md#control-groups) 的状态：

- `gitaly_cgroups_reclaim_attempts_total`，一个仪表盘，记录内存回收尝试的总次数。此数字在每次服务器重启时重置。
- `gitaly_cgroups_cpu_usage`，一个仪表盘，衡量每个 cgroup 的 CPU 使用情况。
- `gitaly_cgroup_procs_total`，一个仪表盘，衡量 Gitaly 在 cgroups 控制下产生的进程总数。
- `gitaly_cgroup_cpu_cfs_periods_total`，一个计数器，用于 [`nr_periods`](https://docs.kernel.org/scheduler/sched-bwc.html#statistics) 的值。
- `gitaly_cgroup_cpu_cfs_throttled_periods_total`，一个计数器，用于 [`nr_throttled`](https://docs.kernel.org/scheduler/sched-bwc.html#statistics) 的值。
- `gitaly_cgroup_cpu_cfs_throttled_seconds_total`，一个计数器，用于 [`throttled_time`](https://docs.kernel.org/scheduler/sched-bwc.html#statistics) 的值（以秒为单位）。

<a id="pack-objects-cache"></a>

## `pack-objects` 缓存

以下 [`pack-objects` 缓存](configure_gitaly.md#pack-objects-cache) 指标可用：

- `gitaly_pack_objects_cache_enabled`，一个仪表盘，当缓存启用时设置为 `1`。可用标签：`dir` 和 `max_age`。
- `gitaly_pack_objects_cache_lookups_total`，缓存查找的计数器。可用标签：`result`。
- `gitaly_pack_objects_generated_bytes_total`，写入缓存的字节数的计数器。
- `gitaly_pack_objects_served_bytes_total`，从缓存读取的字节数的计数器。
- `gitaly_streamcache_filestore_disk_usage_bytes`，缓存文件总大小的仪表盘。可用标签：`dir`。
- `gitaly_streamcache_index_entries`，缓存中条目数的仪表盘。可用标签：`dir`。

其中一些指标以 `gitaly_streamcache` 开头，因为它们由 Gitaly 中的 `streamcache` 内部库包生成。

示例：

```plaintext
gitaly_pack_objects_cache_enabled{dir="/var/opt/gitlab/git-data/repositories/+gitaly/PackObjectsCache",max_age="300"} 1
gitaly_pack_objects_cache_lookups_total{result="hit"} 2
gitaly_pack_objects_cache_lookups_total{result="miss"} 1
gitaly_pack_objects_generated_bytes_total 2.618649e+07
gitaly_pack_objects_served_bytes_total 7.855947e+07
gitaly_streamcache_filestore_disk_usage_bytes{dir="/var/opt/gitlab/git-data/repositories/+gitaly/PackObjectsCache"} 2.6200152e+07
gitaly_streamcache_filestore_removed_total{dir="/var/opt/gitlab/git-data/repositories/+gitaly/PackObjectsCache"} 1
gitaly_streamcache_index_entries{dir="/var/opt/gitlab/git-data/repositories/+gitaly/PackObjectsCache"} 1
```

<a id="monitor-gitaly-server-side-backups"></a>

## 监控 Gitaly 服务器端备份

{{< history >}}

- 在极狐GitLab 16.7 中引入。

{{< /history >}}

使用以下指标监控 [服务器端仓库备份](configure_gitaly.md#configure-server-side-backups)：

- `gitaly_backup_latency_seconds`，一个直方图，衡量服务器端备份每个阶段所用时间的秒数。不同阶段包括 `refs`、`bundle` 和 `custom_hooks`，表示每个阶段处理的数据类型。
- `gitaly_backup_bundle_bytes`，一个直方图，衡量 Gitaly 备份服务将 Git 包推送到对象存储的上传数据速率。

特别是当你的极狐GitLab 实例包含大型仓库时，使用这些指标。

<a id="queries"></a>

## 查询

以下是一些用于监控 Gitaly 的查询：

- 使用以下 Prometheus 查询观察 Gitaly 在生产环境中提供的[连接类型](tls_support.md)：

  ```prometheus
  sum(rate(gitaly_connections_total[5m])) by (type)
  ```

- 使用以下 Prometheus 查询监控你的极狐GitLab 安装的[认证行为](tls_support.md#observe-type-of-gitaly-connections)：

  ```prometheus
  sum(rate(gitaly_authentications_total[5m])) by (enforced, status)
  ```

  在一个认证配置正确且存在活跃流量的系统中，你会看到类似以下内容：

  ```prometheus
  {enforced="true",status="ok"}  4424.985419441742
  ```

  可能还有其他速率为 0 的数字，但你只需要注意非零数字。

  唯一的非零数字应该是 `enforced="true",status="ok"`。如果你有其他非零数字，说明你的配置有问题。

  `status="ok"` 数字反映了你当前的请求速率。在上面的例子中，Gitaly 每秒处理大约 4000 个请求。

- 使用以下 Prometheus 查询观察生产中使用的 [Git 协议版本](../git_protocol.md)：

  ```prometheus
  sum(rate(gitaly_git_protocol_requests_total[1m])) by (grpc_method,git_protocol,grpc_service)
  ```