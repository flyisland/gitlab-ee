---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 并发限制
---

为避免运行 Gitaly 的服务器不堪重负，您可以限制以下内容的并发：

- RPC。
- 打包对象。

这些限制可以设为固定值，或设置为自适应。

> [!warning]
> 为您的环境启用限制时应谨慎，且仅应在特定情况下使用，例如为了防御意外流量。
> 一旦达到限制，确实会导致用户断开连接，从而对用户产生负面影响。
> 为了获得稳定一致的性能，您应首先探索其他方案，例如调整节点规格，以及[检查大型仓库](../../user/project/repository/monorepos/_index.md)或工作负载。

<a id="limit-rpc-concurrency"></a>

## 限制 RPC 并发

在克隆或拉取仓库时，后台会运行多种 RPC。尤其值得注意的是 Git 打包 RPC：

- `SSHUploadPackWithSidechannel`（用于 Git SSH）。
- `PostUploadPackWithSidechannel`（用于 Git HTTP）。

这些 RPC 会消耗大量资源，在以下场景中影响尤为显著：

- 流量意外飙升。
- 对未遵循最佳实践的[大型仓库](../../user/project/repository/monorepos/_index.md)执行操作。

您可以在 Gitaly 配置文件中使用并发限制，避免在上述场景下让这些进程压垮您的 Gitaly 服务器。例如：

```ruby
# 在 /etc/gitlab/gitlab.rb 中
gitaly['configuration'] = {
   # ...
   concurrency: [
      {
         rpc: '/gitaly.SmartHTTPService/PostUploadPackWithSidechannel',
         max_per_repo: 20,
         max_queue_wait: '1s',
         max_queue_size: 10,
      },
      {
         rpc: '/gitaly.SSHService/SSHUploadPackWithSidechannel',
         max_per_repo: 20,
         max_queue_wait: '1s',
         max_queue_size: 10,
      },
   ],
}
```

- `rpc` 是要针对每个仓库设置并发限制的 RPC 名称。
- `max_per_repo` 是针对给定 RPC、每个仓库的最大同时处理 RPC 调用数。
- `max_queue_wait` 是请求在并发队列中等待被 Gitaly 拾取的最长时间。
- `max_queue_size` 是并发队列（每个 RPC 方法）在请求被 Gitaly 拒绝前可增长的最大长度。

这会限制指定 RPC 的同时处理 RPC 调用数。该限制按仓库应用。在上述示例中：

- 该 Gitaly 服务器上的每个仓库最多允许同时处理 20 个 `PostUploadPackWithSidechannel` 和 `SSHUploadPackWithSidechannel` RPC 调用。
- 如果某个仓库已用尽 20 个槽位，再有请求进来将被排队。
- 如果某个请求在队列中等待超过 1 秒，将被拒绝并抛出错误。
- 如果队列长度超过 10，后续请求将被拒绝并抛出错误。

> [!note]
> 当达到这些限制时，用户会被断开连接。

您可以通过 Gitaly 日志和 Prometheus 观察此队列的行为。更多信息，请参阅[相关文档](monitoring.md#monitor-gitaly-concurrency-limiting)。

<a id="separate-limits-for-unauthenticated-requests"></a>

### 为未认证请求设置单独限制

{{< history >}}

- 在极狐GitLab 18.7 [使用功能标志](../../operations/feature_flags.md)引入，功能标志名为 `gitaly_limit_unauthenticated`。默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请查看历史记录。
> 此功能可供测试，但尚未准备好用于生产环境。

默认情况下，RPC 并发限制对无论是否认证的所有请求均生效。不过，您可以针对未认证请求配置单独、更严格的限制，以保护您的 Gitaly 服务器免受匿名流量可能导致的滥用或资源耗尽。

当您为一个 RPC 配置 `unauthenticated` 字段后，Gitaly 会使用单独的限制器：

- **已认证请求**使用主要并发限制（在 RPC 配置的顶层设置）。
- **未认证请求**使用在 `unauthenticated` 字段中指定的限制。

这种分隔允许您：

- 对未认证流量施加更严格的限制，同时为已认证用户维持更高的吞吐量。
- 防止来自匿名克隆或拉取的拒绝服务场景。
- 确保已认证用户优先访问 Gitaly 资源。

如果您不配置 `unauthenticated` 字段，所有请求（已认证和未认证）将共享相同的并发限制。

#### 何时使用单独的未认证限制

在以下情况下，请考虑配置单独的未认证限制：

- 您的极狐GitLab 实例允许公共仓库访问，并且经历了大量匿名流量。
- 您希望在高负载期间优先保障已认证用户。
- 您需要防御来自未认证来源的潜在滥用。
- 您观察到已认证和未认证请求之间存在资源争抢。

#### 为未认证请求配置静态限制

以下示例展示了如何为已认证和未认证请求分别配置静态限制：

```ruby
# 在 /etc/gitlab/gitlab.rb 中
gitaly['configuration'] = {
   # ...
   concurrency: [
      {
         rpc: '/gitaly.SmartHTTPService/PostUploadPackWithSidechannel',
         # 已认证请求的限制
         max_per_repo: 20,
         max_queue_wait: '1s',
         max_queue_size: 10,
         # 未认证请求的单独限制
         unauthenticated: {
            max_per_repo: 5,
            max_queue_wait: '500ms',
            max_queue_size: 5,
         },
      },
   ],
}
```

在此示例中：

- 已认证请求每个仓库最多可进行 20 个并发操作。
- 未认证请求每个仓库被限制为 5 个并发操作。
- 未认证请求的队列等待时间更短（500 毫秒对比 1 秒），队列也更小（5 对比 10）。

#### 为未认证请求配置自适应限制

与主配置一样，`unauthenticated` 字段同时支持静态和自适应并发限制。您可以为未认证请求配置自适应限制：

```ruby
# 在 /etc/gitlab/gitlab.rb 中
gitaly['configuration'] = {
   # ...
   concurrency: [
      {
         rpc: '/gitaly.SmartHTTPService/PostUploadPackWithSidechannel',
         # 已认证请求的自适应限制
         adaptive: true,
         min_limit: 10,
         initial_limit: 20,
         max_limit: 40,
         max_queue_wait: '1s',
         max_queue_size: 10,
         # 未认证请求的自适应限制
         unauthenticated: {
            adaptive: true,
            min_limit: 2,
            initial_limit: 5,
            max_limit: 10,
            max_queue_wait: '500ms',
            max_queue_size: 5,
         },
      },
   ],
}
```

此配置允许已认证和未认证限制根据系统资源使用情况独立自适应调整，同时保持两种流量类型的隔离。

<a id="limit-pack-objects-concurrency"></a>

## 限制打包对象并发

在处理 SSH 和 HTTPS 流量进行克隆或拉取仓库时，Gitaly 会触发 `git-pack-objects` 进程。这些进程会生成一个 `pack-file`，并可能消耗大量资源，尤其是在流量意外激增或对大型仓库进行并发拉取时。在 JihuLab.com 上，我们还观察到网络连接较慢的客户端会引发问题。

您可以在 Gitaly 配置文件中设置打包对象并发限制，防止这些进程压垮您的 Gitaly 服务器。此设置会限制每个远程 IP 地址的同时打包对象进程数量。

> [!warning]
> 仅在特定情况下（如防御意外流量）且经过谨慎评估后，才应在您的环境中启用这些限制。当达到限制时，用户会被断开连接。为了获得稳定一致的性能，您应首先探索其他方案，例如调整节点规格，以及[检查大型仓库](../../user/project/repository/monorepos/_index.md)或工作负载。

示例配置：

```ruby
# 在 /etc/gitlab/gitlab.rb 中
gitaly['pack_objects_limiting'] = {
   'max_concurrency' => 15,
   'max_queue_length' => 200,
   'max_queue_wait' => '60s',
}
```

- `max_concurrency` 是每个键的最大同时进行打包对象进程数。
- `max_queue_length` 是并发队列（每个键）在请求被 Gitaly 拒绝前可增长的最大长度。
- `max_queue_wait` 是请求在并发队列中等待被 Gitaly 拾取的最长时间。

在上述示例中：

- 每个远程 IP 在单个 Gitaly 节点上最多允许 15 个同时进行的打包对象进程。
- 如果某个 IP 已用尽其 15 个槽位，再有请求进来将被排队。
- 如果某个请求在队列中等待超过 1 分钟，将被拒绝并抛出错误。
- 如果队列长度超过 200，后续请求将被拒绝并抛出错误。

当打包对象缓存启用时，仅当缓存未命中时，打包对象限制才会生效。更多信息，请参阅[打包对象缓存](configure_gitaly.md#pack-objects-cache)。

您可以通过 Gitaly 日志和 Prometheus 观察此队列的行为。更多信息，请参阅[监控 Gitaly 打包对象并发限制](monitoring.md#monitor-gitaly-pack-objects-concurrency-limiting)。

<a id="calibrating-concurrency-limits"></a>

## 校准并发限制

在设置并发限制时，您应根据具体的工作负载模式选择合适的值。本节提供如何有效校准这些限制的指导。

### 使用 Prometheus 指标和日志进行校准

Prometheus 指标可提供关于使用模式以及每种 RPC 对 Gitaly 节点资源影响的量化洞察。以下几个关键指标对此分析特别有价值：

- 每个 RPC 的资源消耗指标。Gitaly 将大部分繁重操作委派给 `git` 进程，因此通常被调用的外部命令是 Git 二进制文件。Gitaly 将这些命令收集的指标以日志和 Prometheus 指标的形式暴露出来。
  - `gitaly_command_cpu_seconds_total` - 调用外部进程所花费的 CPU 时间总和，带有 `grpc_service`、`grpc_method`、`cmd` 和 `subcmd` 标签。
  - `gitaly_command_real_seconds_total` - 调用外部进程所花费的真实时间总和，带有类似标签。
- 每个 RPC 的近期限制指标：
  - `gitaly_concurrency_limiting_in_progress` - 正在处理的并发请求数。
  - `gitaly_concurrency_limiting_queued` - 某个仓库的某个 RPC 处于等待状态的请求数。
  - `gitaly_concurrency_limiting_acquiring_seconds` - 由于并发限制，请求在处理前等待的时长。

这些指标提供了在给定时间点资源利用状况的高层视图。其中 `gitaly_command_cpu_seconds_total` 指标在识别消耗大量 CPU 资源的特定 RPC 方面尤为有效。如[监控 Gitaly](monitoring.md) 中所述，还有更多指标可用于更详细的分析。

虽然指标能捕获整体资源使用模式，但它们通常不提供按仓库的细分数据。因此，日志可作为补充数据源。要分析日志：

1. 筛选出由高影响 RPC 标识的日志。
1. 按仓库或项目聚合筛选后的日志。
1. 在时间序列图表上可视化聚合结果。

这种结合使用指标和日志的方法，可全面展现系统级资源使用和仓库特定模式。诸如 Kibana 或类似日志聚合平台的分析工具可辅助此过程。

### 调整限制

如果发现初始限制不够高效，您可能需要调整。使用自适应限制时，精确的限制值没那么关键，因为系统会根据资源使用情况自动调整。

请记住，并发限制是按仓库划分的。限制值为 30 意味着每个仓库最多允许 30 个同时进行的请求。如果达到限制，请求将被排队，仅当队列已满或达到最大等待时间时才会被拒绝。

<a id="adaptive-concurrency-limiting"></a>

## 自适应并发限制

{{< history >}}

- 在极狐GitLab 16.6 引入。

{{< /history >}}

Gitaly 支持两种并发限制：

- [RPC 并发限制](#limit-rpc-concurrency)，允许您为每个 Gitaly RPC 配置最大同时进行请求数。该限制按 RPC 和仓库划分。
- [打包对象并发限制](#limit-pack-objects-concurrency)，按 IP 限制并发 Git 数据传输请求的数量。

若超过此限制，则以下其一：

- 请求被放入队列。
- 如果队列已满或请求在队列中停留时间过长，请求将被拒绝。

这两种并发限制均可静态配置。尽管静态限制能提供良好的保护效果，但存在一些缺点：

- 静态限制并非适用于所有使用模式。不存在一刀切的值。如果限制太低，大型仓库会受到负面影响。如果限制太高，保护效果便会大打折扣。
- 维护一个合理的并发限制值颇为繁琐，尤其是在每个仓库的工作负载随时间变化时。
- 即使服务器处于空闲状态，请求也可能被拒绝，因为该限制未考虑服务器负载。

通过配置自适应并发限制，您可以克服所有这些缺点并保留并发限制的优势。自适应并发限制是可选的，并建立在两种并发限制类型之上。它使用加法增加/乘法减少（AIMD）算法。每个自适应限制：

- 在典型进程运行期间，逐渐增加至某个上限。
- 当宿主机出现资源问题时快速降低。

此机制为机器提供了一定的“呼吸”空间，并加快当前正在处理的请求。

![图表展示了一个 Gitaly 自适应并发限制，该限制根据系统资源使用情况，遵循 AIMD 算法进行调整](img/gitaly_adaptive_concurrency_limit_v16_6.png)

自适应限制器每 30 秒校准一次限制，并：

- 每次将限制增加 1，直到达到上限。
- 当顶层 cgroup 的内存使用率超过 90%（不包括高度可回收的页缓存），或 CPU 节流时间达到观察时间的 50% 或以上时，将限制减半。

否则，限制每次增加 1，直到达到上限。

自适应限制可针对每个 RPC 或打包对象缓存单独启用。然而，限制是在同一时间校准的。自适应限制具有以下配置项：

- `adaptive` 设置自适应功能是否启用。
- `max_limit` 是最大并发限制。Gitaly 会将当前限制增加直至达到该值。这应该是一个在典型条件下系统完全可以支持的大方值。
- `min_limit` 是所配置 RPC 的最小并发限制。当宿主机出现资源问题时，Gitaly 会迅速降低限制，直至达到该值。将 `min_limit` 设为 0 可能会完全停止处理，这通常不可取。
- `initial_limit` 在两者之间提供一个合理的起点。

<a id="enable-adaptiveness-for-rpc-concurrency"></a>

### 为 RPC 并发启用自适应

先决条件：

- 由于自适应限制依赖于[控制组](configure_gitaly.md#control-groups)，因此在使用自适应限制前必须先启用控制组。

以下是一个为 RPC 并发配置自适应限制的示例：

```ruby
# 在 /etc/gitlab/gitlab.rb 中
gitaly['configuration'] = {
    # ...
    cgroups: {
        # 启用 cgroups 支持的最低要求配置。
        repositories: {
            count: 1
        },
    },
    concurrency: [
        {
            rpc: '/gitaly.SmartHTTPService/PostUploadPackWithSidechannel',
            max_queue_wait: '1s',
            max_queue_size: 10,
            adaptive: true,
            min_limit: 10,
            initial_limit: 20,
            max_limit: 40
        },
        {
            rpc: '/gitaly.SSHService/SSHUploadPackWithSidechannel',
            max_queue_wait: '10s',
            max_queue_size: 20,
            adaptive: true,
            min_limit: 10,
            initial_limit: 50,
            max_limit: 100
        },
   ],
}
```

更多信息，请参阅 [RPC 并发](#limit-rpc-concurrency)。

<a id="enable-adaptiveness-for-pack-objects-concurrency"></a>

### 为打包对象并发启用自适应

先决条件：

- 由于自适应限制依赖于[控制组](configure_gitaly.md#control-groups)，因此在使用自适应限制前必须先启用控制组。

以下是一个为打包对象并发配置自适应限制的示例：

```ruby
# 在 /etc/gitlab/gitlab.rb 中
gitaly['pack_objects_limiting'] = {
   'max_queue_length' => 200,
   'max_queue_wait' => '60s',
   'adaptive' => true,
   'min_limit' => 10,
   'initial_limit' => 20,
   'max_limit' => 40
}
```

更多信息，请参阅[打包对象并发](#limit-pack-objects-concurrency)。

<a id="calibrating-adaptive-concurrency-limits"></a>

### 校准自适应并发限制

自适应并发限制与极狐GitLab 保护 Gitaly 资源的通常方式截然不同。自适应限制并非依赖可能过于严格或过于宽松的静态阈值，而是实时智能响应实际资源状况。

这种方法消除了通过如[校准并发限制](#calibrating-concurrency-limits)中所述的大量校准来寻找“完美”阈值的需求。在故障场景下，自适应限制器会以指数方式降低限制（例如 60 → 30 → 15 → 10），然后在系统稳定时通过逐步提升限制自动恢复。

在校准自适应限制时，您可以优先考虑灵活性而非精确性。

#### RPC 分类和配置示例

繁重的 Gitaly RPC（应予以保护）大致可分为两类：

- 纯粹的 Git 数据操作。
- 时间敏感的 RPC。

每种类型具有不同的特点，影响并发限制的配置方式。以下示例说明了限制配置背后的逻辑，并可将其作为起点使用。

##### 纯粹的 Git 数据操作

这些 RPC 涉及 Git 的拉取、推送和获取操作，并具有以下特点：

- 长时间运行的进程。
- 显著的资源利用率。
- 计算成本高昂。
- 非时间敏感。通常可以接受额外的延迟。

`SmartHTTPService` 和 `SSHService` 中的 RPC 属于纯粹的 Git 数据操作类别。配置示例：

```ruby
{
  rpc: "/gitaly.SmartHTTPService/PostUploadPackWithSidechannel", # 或 `/gitaly.SmartHTTPService/SSHUploadPackWithSidechannel`
  adaptive: true,
  min_limit: 10,  # 即使在极端负载下也保持的最低并发数
  initial_limit: 40,  # 服务初始化时的起始并发数
  max_limit: 60,  # 理想条件下的最大并发数
  max_queue_wait: "60s",
  max_queue_size: 300
}
```

##### 时间敏感的 RPC

这些 RPC 服务于极狐GitLab 本身和其他具有不同特点的客户端：

- 通常是在线 HTTP 请求或 Sidekiq 后台作业的一部分。
- 延迟要求较低。
- 通常资源密集度较低。

对于这些 RPC，极狐GitLab 中的超时配置应作为 `max_queue_wait` 参数的参考。例如，`get_tree_entries` 在极狐GitLab 中通常有中等超时 30 秒：

```ruby
{
  rpc: "/gitaly.CommitService/GetTreeEntries",
  adaptive: true,
  min_limit: 5,  # 资源压力下维持的最低吞吐量
  initial_limit: 10,  # 初始并发设置
  max_limit: 20,  # 最佳条件下的最大并发数
  max_queue_size: 50,
  max_queue_wait: "30s"
}
```

<a id="monitoring-adaptive-limiting"></a>

### 监控自适应限制

要观察自适应限制在生产环境中的行为，请参考[监控 Gitaly 自适应并发限制](monitoring.md#monitor-gitaly-adaptive-concurrency-limiting)中描述的监控工具和指标。观察自适应限制行为有助于确认限制是否正确响应资源压力并按照预期进行调整。