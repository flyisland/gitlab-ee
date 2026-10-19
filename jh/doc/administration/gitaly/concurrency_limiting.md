---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 并发限制
---

为避免运行 Gitaly 的服务器过载，您可以限制以下内容的并发：

- RPC。
- 打包对象。

这些限制可以是固定的，也可以设置为自适应。

> [!warning]
> 在您的环境中启用限制时应谨慎，并且仅在特定情况下启用，
> 例如防范意外流量。
> 达到限制时，确实会导致连接断开，从而对用户产生负面影响。
> 为了获得一致且稳定的性能，您应首先探索其他方案，例如
> 调整节点规格，以及[审查大型代码仓库](../../user/project/repository/monorepos/_index.md)或工作负载。

<a id="limit-rpc-concurrency"></a>

## 限制 RPC 并发

在克隆或拉取代码仓库时，会在后台运行各种 RPC。尤其是 Git 打包 RPC：

- `SSHUploadPackWithSidechannel`（用于 Git SSH）。
- `PostUploadPackWithSidechannel`（用于 Git HTTP）。

这些 RPC 可能会消耗大量资源，在以下情况下会产生显著影响：

- 意外的高流量。
- 针对不遵循最佳实践的[大型代码仓库](../../user/project/repository/monorepos/_index.md)运行。

在这些情况下，您可以使用 Gitaly 配置文件中的并发限制，防止这些进程使您的 Gitaly 服务器过载。例如：

```ruby
# in /etc/gitlab/gitlab.rb
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

- `rpc` 是要为其设置每个代码仓库并发限制的 RPC 名称。
- `max_per_repo` 是给定 RPC 每个代码仓库的最大在途 RPC 调用数。
- `max_queue_wait` 是请求在并发队列中等待 Gitaly
  处理的最长时间。
- `max_queue_size` 是并发队列（每个 RPC 方法）在请求被
  Gitaly 拒绝之前可以增长到的最大大小。

这会限制给定 RPC 的在途 RPC 调用数。该限制按代码仓库应用。在上面的示例中：

- Gitaly 服务器服务的每个代码仓库最多可以有 20 个同时进行的 `PostUploadPackWithSidechannel` 和
  `SSHUploadPackWithSidechannel` RPC 调用在途。
- 如果某个代码仓库已用完其 20 个名额，又有另一个请求进来，该请求会被
  排队。
- 如果请求在队列中等待超过 1 秒，则会被拒绝并返回错误。
- 如果队列增长超过 10，后续请求会被拒绝并返回错误。

> [!note]
> 达到这些限制时，用户会被断开连接。

您可以使用 Gitaly 日志和 Prometheus 观察此队列的行为。更多信息，请参阅[相关文档](monitoring.md#monitor-gitaly-concurrency-limiting)。

<a id="separate-limits-for-unauthenticated-requests"></a>

### 未认证请求的单独限制

默认情况下，RPC 并发限制适用于所有请求，无论认证状态如何。但是，您可以为未认证请求配置单独的、更严格的限制，以保护您的 Gitaly 服务器免受匿名流量可能造成的滥用或资源耗尽。

当您为某个 RPC 配置 `unauthenticated` 字段时，Gitaly 会使用单独的限流器：

- **已认证请求**使用主并发限制（在
  RPC 配置的顶层配置）。
- **未认证请求**使用
  `unauthenticated` 字段中指定的限制。

这种分离允许您：

- 对未认证流量应用更严格的限制，同时为已认证用户保持更高的
  吞吐量。
- 防范来自匿名克隆或拉取的拒绝服务场景。
- 确保已认证用户优先访问 Gitaly 资源。

如果您不配置 `unauthenticated` 字段，所有请求（包括已认证和未认证）共享相同的并发限制。

<a id="when-to-use-separate-unauthenticated-limits"></a>

#### 何时使用单独的未认证限制

在以下情况下，请考虑配置单独的未认证限制：

- 您的极狐GitLab 实例允许公开代码仓库访问，并且经历大量
  匿名流量。
- 您希望在高负载期间优先处理已认证用户。
- 您需要防范来自未认证来源的潜在滥用。
- 您观察到已认证和未认证请求之间存在资源争用。

<a id="configure-static-limits-for-unauthenticated-requests"></a>

#### 为未认证请求配置静态限制

以下示例展示了如何为已认证和未认证请求配置单独的静态限制：

```ruby
# in /etc/gitlab/gitlab.rb
gitaly['configuration'] = {
   # ...
   concurrency: [
      {
         rpc: '/gitaly.SmartHTTPService/PostUploadPackWithSidechannel',
         # Limits for authenticated requests
         max_per_repo: 20,
         max_queue_wait: '1s',
         max_queue_size: 10,
         # Separate limits for unauthenticated requests
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

- 已认证请求每个代码仓库最多可以有 20 个并发操作。
- 未认证请求每个代码仓库限制为 5 个并发操作。
- 未认证请求具有更短的队列等待时间（500ms 对 1s）和
  更小的队列（5 对 10）。

<a id="configure-adaptive-limits-for-unauthenticated-requests"></a>

#### 为未认证请求配置自适应限制

`unauthenticated` 字段同时支持静态和自适应并发限制，就像主配置一样。您可以为未认证请求配置自适应限制：

```ruby
# in /etc/gitlab/gitlab.rb
gitaly['configuration'] = {
   # ...
   concurrency: [
      {
         rpc: '/gitaly.SmartHTTPService/PostUploadPackWithSidechannel',
         # Adaptive limits for authenticated requests
         adaptive: true,
         min_limit: 10,
         initial_limit: 20,
         max_limit: 40,
         max_queue_wait: '1s',
         max_queue_size: 10,
         # Adaptive limits for unauthenticated requests
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

此配置允许已认证和未认证限制根据系统资源使用情况独立调整，同时保持两种流量类型之间的分离。

<a id="limit-pack-objects-concurrency"></a>

## 限制打包对象并发

Gitaly 在处理 SSH 和 HTTPS 流量以克隆或拉取代码仓库时会触发 `git-pack-objects` 进程。这些进程会生成 `pack-file`，并且可能消耗大量资源，尤其是在意外高流量或从大型代码仓库并发拉取等情况下。在 JihuLab.com 上，我们还会观察到互联网连接缓慢的客户端存在的问题。

您可以通过在 Gitaly 配置文件中设置打包对象并发限制，防止这些进程使您的 Gitaly 服务器过载。此设置限制每个远程 IP 地址的在途打包对象进程数。

> [!warning]
> 仅在您的环境中谨慎启用这些限制，并且仅在特定情况下启用，例如防范意外流量。达到这些限制时，它们会
> 断开用户连接。为了获得一致且稳定的性能，您应首先探索其他方案，例如调整节点规格，以及
> [审查大型代码仓库](../../user/project/repository/monorepos/_index.md)或工作负载。

配置示例：

```ruby
# in /etc/gitlab/gitlab.rb
gitaly['configuration'] = {
   # ...
   pack_objects_limiting: {
      max_concurrency: 15,
      max_queue_length: 200,
      max_queue_wait: '60s',
   },
}
```

- `max_concurrency` 是每个键的最大在途打包对象进程数。
- `max_queue_length` 是并发队列（每个键）在请求被 Gitaly 拒绝之前可以增长到的最大大小。
- `max_queue_wait` 是请求在并发队列中等待 Gitaly 处理的最长时间。

在上面的示例中：

- 每个远程 IP 在 Gitaly 节点上最多可以有 15 个同时进行的打包对象进程在途。
- 如果某个已用完其 15 个名额的 IP 又有另一个请求进来，该请求会被排队。
- 如果请求在队列中等待超过 1 分钟，则会被拒绝并返回错误。
- 如果队列增长超过 200，后续请求会被拒绝并返回错误。

当启用打包对象缓存时，只有在缓存未命中时才会触发打包对象限制。更多信息，请参阅[打包对象缓存](configure_gitaly.md#pack-objects-cache)。

您可以使用 Gitaly 日志和 Prometheus 观察此队列的行为。更多信息，请参阅[监控 Gitaly 打包对象并发限制](monitoring.md#monitor-gitaly-pack-objects-concurrency-limiting)。

<a id="calibrating-concurrency-limits"></a>

## 校准并发限制

在设置并发限制时，您应根据具体的工作负载模式选择适当的值。本节提供有关如何有效校准这些限制的指导。

<a id="using-prometheus-metrics-and-logs-for-calibration"></a>

### 使用 Prometheus 指标和日志进行校准

Prometheus 指标提供有关使用模式以及每种 RPC 对 Gitaly 节点资源影响的定量洞察。有几个关键指标对此分析特别有价值：

- 每个 RPC 的资源消耗指标。Gitaly 将大多数繁重操作卸载到 `git` 进程，因此通常通过 shell 调用的命令是 Git 二进制文件。
  Gitaly 将这些命令收集的指标以日志和 Prometheus 指标的形式公开。
  - `gitaly_command_cpu_seconds_total` - 通过 shell 调用所花费的 CPU 时间总和，带有 `grpc_service`、`grpc_method`、`cmd` 和 `subcmd` 标签。
  - `gitaly_command_real_seconds_total` - 通过 shell 调用所花费的实际时间总和，带有类似的标签。
- 每个 RPC 的近期限制指标：
  - `gitaly_concurrency_limiting_in_progress` - 正在处理的并发请求数。
  - `gitaly_concurrency_limiting_queued` - 给定代码仓库的某个 RPC 处于等待状态的请求数。
  - `gitaly_concurrency_limiting_acquiring_seconds` - 请求因并发限制而在处理前等待的时长。

这些指标提供给定时间点资源利用率的高层视图。`gitaly_command_cpu_seconds_total` 指标对于识别消耗大量 CPU 资源的特定 RPC 特别有效。还有其他指标可用于更详细的分析，详见
[监控 Gitaly](monitoring.md)。

虽然指标捕获整体资源使用模式，但它们通常不提供按代码仓库的细分。因此，日志可作为补充数据源。要分析日志：

1. 按识别出的高影响 RPC 筛选日志。
1. 按代码仓库或项目聚合筛选后的日志。
1. 在时间序列图上可视化聚合结果。

这种同时使用指标和日志的组合方法，可提供对系统范围资源使用和代码仓库特定模式的全面可见性。Kibana 或类似日志聚合平台等分析工具可以促进此过程。

<a id="adjusting-limits"></a>

### 调整限制

如果您发现初始限制不够高效，可能需要调整它们。使用自适应限制时，精确的限制不那么关键，因为系统会根据资源使用情况自动调整。

请记住，并发限制的作用域是代码仓库。限制为 30 意味着每个代码仓库最多允许 30 个同时在途请求。如果达到限制，请求会被排队，只有在队列已满或达到最大等待时间时才会被拒绝。

<a id="adaptive-concurrency-limiting"></a>

## 自适应并发限制

Gitaly 支持两种并发限制：

- [RPC 并发限制](#limit-rpc-concurrency)，允许您为每个
  Gitaly RPC 配置最大同时进行的在途请求数。该限制的作用域是 RPC 和代码仓库。
- [打包对象并发限制](#limit-pack-objects-concurrency)，按 IP 限制并发 Git 数据传输请求数。

如果超过此限制，则：

- 请求会被放入队列。
- 如果队列已满或请求在队列中停留时间过长，请求会被拒绝。

这两种并发限制都可以静态配置。虽然静态限制可以产生良好的保护效果，但它们有一些缺点：

- 静态限制并非适用于所有使用模式。没有放之四海而皆准的值。如果限制太低，大型代码仓库会
  受到负面影响。如果限制太高，保护基本上就失效了。
- 维护一个合理的并发限制值很繁琐，尤其是当每个代码仓库的工作负载随时间变化时。
- 即使服务器空闲，请求也可能被拒绝，因为该速率没有考虑服务器上的负载。

您可以通过配置自适应并发限制来克服所有这些缺点，同时保留并发限制的好处。自适应并发限制是可选的，并建立在这两种并发限制类型之上。它使用加法增加/乘法减少（AIMD）算法。每个自适应限制：

- 在典型进程运行期间逐渐增加到某个上限。
- 当主机出现资源问题时快速降低。

此机制为机器提供了一些余量来“喘息”，并加速当前在途请求。

![显示 Gitaly 自适应并发限制根据系统资源使用情况按照 AIMD 算法进行调整的图表](img/gitaly_adaptive_concurrency_limit_v16_6.png)

自适应限流器每 30 秒校准一次限制，并且：

- 将限制增加一，直到达到上限。
- 当顶层 cgroup 的内存使用超过 90%（不包括高度可回收的页面缓存），
  或 CPU 在观察时间的 50% 或更多时间内受到节流时，将限制减半。

否则，限制会增加一，直到达到上限。

自适应限制针对每个 RPC 或打包对象缓存单独启用。但是，限制是同时校准的。自适应限制有以下配置：

- `adaptive` 设置是否启用自适应性。
- `max_limit` 是最大并发限制。Gitaly 会增加当前限制，直到达到此数值。这应该是一个系统在典型条件下能够完全支持的宽松值。
- `min_limit` 是所配置 RPC 的最小并发限制。当主机出现资源问题时，Gitaly 会快速降低限制，直到达到此值。将 `min_limit` 设置为 0 可能会完全停止处理，这通常是不希望发生的。
- `initial_limit` 在这些极端值之间提供一个合理的起点。

<a id="enable-adaptiveness-for-rpc-concurrency"></a>

### 为 RPC 并发启用自适应性

先决条件：

- 由于自适应限制依赖于[控制组](configure_gitaly.md#control-groups)，因此在使用自适应限制之前必须启用控制组。

以下是为 RPC 并发配置自适应限制的示例：

```ruby
# in /etc/gitlab/gitlab.rb
gitaly['configuration'] = {
    # ...
    cgroups: {
        # Minimum required configuration to enable cgroups support.
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

### 为打包对象并发启用自适应性

先决条件：

- 由于自适应限制依赖于[控制组](configure_gitaly.md#control-groups)，因此在使用自适应限制之前必须启用控制组。

以下是为打包对象并发配置自适应限制的示例：

```ruby
# in /etc/gitlab/gitlab.rb
gitaly['configuration'] = {
   # ...
   pack_objects_limiting: {
      max_queue_length: 200,
      max_queue_wait: '60s',
      adaptive: true,
      min_limit: 10,
      initial_limit: 20,
      max_limit: 40,
   },
}
```

更多信息，请参阅[打包对象并发](#limit-pack-objects-concurrency)。

<a id="calibrating-adaptive-concurrency-limits"></a>

### 校准自适应并发限制

自适应并发限制与极狐GitLab 保护 Gitaly 资源的通常方式非常不同。自适应限制不是依赖可能过于严格或过于宽松的静态阈值，而是实时智能地响应实际资源状况。

这种方法无需如[校准并发限制](#calibrating-concurrency-limits)中所述通过大量校准来寻找“完美”的阈值。在故障场景中，自适应限流器会以指数方式降低限制（例如，60 → 30 → 15 → 10），然后在系统稳定时通过逐步提高限制自动恢复。

在校准自适应限制时，您可以优先考虑灵活性而非精确性。

<a id="rpc-categories-and-configuration-examples"></a>

#### RPC 类别和配置示例

应受保护的昂贵 Gitaly RPC 可分为两种一般类型：

- 纯 Git 数据操作。
- 时间敏感的 RPC。

每种类型都有不同的特征，会影响并发限制的配置方式。以下示例说明了限制配置背后的理由。它们也可以用作起点。

<a id="pure-git-data-operations"></a>

##### 纯 Git 数据操作

这些 RPC 涉及 Git 拉取、推送和获取操作，并具有以下特征：

- 长时间运行的进程。
- 显著的资源利用。
- 计算开销大。
- 对时间不敏感。额外的延迟通常是可以接受的。

`SmartHTTPService` 和 `SSHService`中的 RPC 属于纯 Git 数据操作类别。配置示例：

```ruby
{
  rpc: "/gitaly.SmartHTTPService/PostUploadPackWithSidechannel", # or `/gitaly.SmartHTTPService/SSHUploadPackWithSidechannel`
  adaptive: true,
  min_limit: 10,  # Minimum concurrency to maintain even under extreme load
  initial_limit: 40,  # Starting concurrency when service initializes
  max_limit: 60,  # Maximum concurrency under ideal conditions
  max_queue_wait: "60s",
  max_queue_size: 300
}
```

<a id="time-sensitive-rpcs"></a>

##### 时间敏感的 RPC

这些 RPC 为极狐GitLab 本身和其他具有不同特征的客户端提供服务：

- 通常是在线 HTTP 请求或 Sidekiq 后台作业的一部分。
- 延迟特征更短。
- 通常资源消耗较少。

对于这些 RPC，极狐GitLab 中的超时配置应影响 `max_queue_wait` 参数。例如，`get_tree_entries` 在极狐GitLab 中通常具有 30 秒的中等超时：

```ruby
{
  rpc: "/gitaly.CommitService/GetTreeEntries",
  adaptive: true,
  min_limit: 5,  # Minimum throughput maintained under resource pressure
  initial_limit: 10,  # Initial concurrency setting
  max_limit: 20,  # Maximum concurrency under optimal conditions
  max_queue_size: 50,
  max_queue_wait: "30s"
}
```

<a id="monitoring-adaptive-limiting"></a>

### 监控自适应限制

要观察自适应限制在生产环境中的行为，请参阅[监控 Gitaly 自适应并发限制](monitoring.md#monitor-gitaly-adaptive-concurrency-limiting)中描述的监控工具和指标。观察自适应限制行为有助于确认限制是否正确响应资源压力并按预期调整。
