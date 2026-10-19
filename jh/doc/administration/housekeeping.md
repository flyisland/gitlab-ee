---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 例行维护
description: 例行维护任务，用于 Git 代码仓库。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 支持并自动执行 Git 代码仓库中的例行维护任务，以确保代码仓库能够尽可能高效地提供服务。例行维护任务包括：

- 压缩 Git 对象和修订版本。
- 移除不可达对象。
- 移除锁定文件等陈旧数据。
- 维护可提升性能的数据结构。
- 更新对象池，以改进跨 forks 的对象去重。

> [!warning]
> 请勿手动执行 Git 命令，对极狐GitLab 所控制的 Git
> 代码仓库执行例行维护。这样做可能导致代码仓库损坏
> 和数据丢失。

<a id="housekeeping-strategy"></a>

## 例行维护策略

Gitaly 可以通过两种方式在 Git 代码仓库中执行例行维护任务：

- [主动例行维护](#eager-housekeeping)会执行特定的例行维护任务，
  与代码仓库所处的状态无关。
- [启发式例行维护](#heuristical-housekeeping)会根据一组启发式规则
  执行例行维护任务，这些规则根据代码仓库状态确定需要
  执行哪些例行维护任务。

<a id="eager-housekeeping"></a>

### 主动例行维护

“主动”例行维护策略会在代码仓库中执行例行维护任务，与代码仓库状态无关。这是[手动触发](#manual-trigger)和基于推送的触发所使用的默认策略。

主动例行维护策略由极狐GitLab 应用控制。根据触发例行维护作业运行的原因，极狐GitLab 会要求 Gitaly 执行特定的例行维护任务。即使代码仓库已处于优化状态，Gitaly 也会执行这些任务。因此，在大型代码仓库中，执行例行维护任务可能很慢，该策略的效率可能不高。

<a id="heuristical-housekeeping"></a>

### 启发式例行维护

启发式（或“机会式”）例行维护策略会分析代码仓库状态，仅在发现一个或多个数据结构优化不足时才执行例行维护任务。这是[计划例行维护](#scheduled-housekeeping)所使用的策略。

启发式例行维护使用以下信息来决定需要运行的任务：

- 松散对象和陈旧对象的数量。
- 包含已压缩对象的 packfile 数量。
- 松散引用的数量。
- 是否存在 commit-graph。

是否需要优化所分析的数据结构，取决于代码仓库的大小：

- 所有对象的总大小越大，对象重新打包的频率越高。
- 引用总数越多，引用重新打包的频率越低。

Gitaly 这样做是为了抵消一个事实：这些数据结构越大，优化它们所需的时间就越多。对于大型 monorepo（会收到大量流量）来说，避免过于频繁地优化它们尤为重要。

您可以更改要求 Gitaly 优化代码仓库的频率。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**代码仓库维护**。
1. 在**例行维护**部分，配置例行维护选项。
1. 选择**保存更改**。

- **启用自动仓库例行维护**：定期要求 Gitaly 运行代码仓库优化。如果
  长时间禁用此设置，极狐GitLab 服务器上的 Git 代码仓库访问会变得
  更慢，代码仓库也会占用更多磁盘空间。
- **优化代码库周期**：在多少次 Git 推送后要求 Gitaly 优化代码仓库。

<a id="running-housekeeping-tasks"></a>

## 运行例行维护任务

极狐GitLab 运行例行维护任务的方式有多种：

- 项目管理员可以[手动触发](#manual-trigger)代码仓库
  例行维护任务。
- 极狐GitLab 可以在若干次 Git 推送后自动计划例行维护任务。
- 极狐GitLab 可以[计划一个作业](#scheduled-housekeeping)，在可配置的时间范围内
  为所有代码仓库运行例行维护任务。

<a id="manual-trigger"></a>

### 手动触发

代码仓库管理员可以手动触发代码仓库中的例行维护任务。通常不需要这样做，因为极狐GitLab 会自动运行例行维护任务。手动触发在以下情况下可能有用：

- 已知某个代码仓库需要例行维护。
- 基于推送的例行维护任务自动计划已被禁用。

手动触发例行维护任务：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**高级**。
1. 选择**运行例行维护**。

这会为项目的代码仓库启动一个异步后台工作进程。该后台工作进程会要求 Gitaly 执行若干优化。

例行维护还会每 `200` 次推送[移除未引用的 LFS 文件](raketasks/cleanup.md#remove-unreferenced-lfs-files)，从而为您的项目释放存储空间。

<a id="prune-unreachable-objects"></a>

### 清理不可达对象

不可达对象会作为计划例行维护的一部分被清理。不过，您也可以触发手动清理。触发例行维护会清理不可达对象，宽限期为两周。当您手动触发不可达对象的清理时，宽限期会缩短为 30 分钟。

> [!warning]
> 清理不可达对象并不保证会移除泄露的密钥和其他敏感信息。有关如何移除
> 已提交但未推送的密钥的信息，请参阅[从提交中移除密钥教程](../user/application_security/secret_detection/remove_secrets_tutorial.md)。
> 此外，您还可以[逐个移除 blob](../user/project/repository/repository_size.md#remove-blobs)。有关执行该操作可能带来的
> 后果，请参阅该文档。
>
> 如果某个并发进程（如 `git push`）已创建了一个对象，但尚未创建
> 对该对象的引用，那么在对象被删除后又添加对该对象的引用，
> 您的代码仓库可能会损坏。宽限期的存在就是为了
> 降低此类竞态条件的可能性。
> 例如，如果经常通过有时非常慢的连接推送许多大型对象，
> 那么清理不可达对象所带来的风险会远高于在企业
> 环境中（项目只能从公司内部通过高性能连接访问）的风险。
> 使用此选项时，请考虑项目的使用情况，并选择一段空闲时间。

手动触发不可达对象的清理：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**高级**。
1. 选择**运行例行维护**。
1. 等待 30 分钟，让操作完成。
1. 返回您选择**运行例行维护**的页面，然后选择 **清理不可达对象**。

<a id="scheduled-housekeeping"></a>

### 计划例行维护

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

虽然极狐GitLab 会根据推送次数自动执行例行维护任务，但它不会维护完全收不到任何推送的代码仓库。因此，休眠的代码仓库或仅收到读取请求的代码仓库可能无法从代码仓库例行维护策略的改进中受益。

管理员可以启用一个后台作业，以可自定义的时间间隔在所有代码仓库中执行例行维护，以解决此问题。该后台作业会以随机顺序处理某个 Gitaly 节点托管的所有代码仓库，并主动对它们执行例行维护任务。如果处理时间超过配置的时间间隔，该 Gitaly 节点会停止处理代码仓库。

<a id="configure-scheduled-housekeeping"></a>

#### 配置计划例行维护

Git 代码仓库的后台维护在 Gitaly 中配置。默认情况下，Gitaly 每天中午 12:00 执行后台代码仓库维护，持续 10 分钟。

您可以在 Gitaly 配置中更改此默认值。

对于使用 Gitaly 集群（Praefect）的环境，计划例行维护的启动时间可以在各 Gitaly 节点之间错开，以免计划例行维护同时在多个节点上运行。

如果计划例行维护运行达到了指定的 `duration`，正在运行的任务会被优雅取消。在后续的计划例行维护运行中，Gitaly 会随机打乱要处理的代码仓库列表。

以下代码片段为 `default` 存储启用每日后台代码仓库维护，从 23:00 开始，持续 1 小时：

{{< tabs >}}

{{< tab title="自行编译（源代码）" >}}

```toml
[daily_maintenance]
start_hour = 23
start_minute = 00
duration = 1h
storages = ["default"]
```

使用以下代码片段可完全禁用后台代码仓库
维护：

```toml
[daily_maintenance]
disabled = true
```

{{< /tab >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```ruby
gitaly['configuration'] = {
  daily_maintenance: {
    disabled: false,
    start_hour: 23,
    start_minute: 00,
    duration: '1h',
    storages: ['default'],
  },
}
```

使用以下代码片段可完全禁用后台代码仓库
维护：

```ruby
gitaly['configuration'] = {
  daily_maintenance: {
    disabled: true,
  },
}
```

{{< /tab >}}

{{< /tabs >}}

执行计划例行维护时，您可以在 [Gitaly 日志](logs/_index.md#gitaly-logs)中看到以下条目：

```json
# When the scheduled housekeeping starts
{"level":"info","msg":"maintenance: daily scheduled","pid":197260,"scheduled":"2023-09-27T13:10:00+13:00","time":"2023-09-27T00:08:31.624Z"}

# When the scheduled housekeeping completes
{"actual_duration":321181874818,"error":null,"level":"info","max_duration":"1h0m0s","msg":"maintenance: daily completed","pid":197260,"time":"2023-09-27T00:15:21.182Z"}
```

`actual_duration`（以纳秒为单位）表示计划维护执行了多长时间。在上面的示例中，计划例行维护在 5 分钟多一点的时间内完成。

<a id="object-pool-repositories"></a>

## 对象池代码仓库

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

极狐GitLab 使用对象池代码仓库在代码仓库的各个 fork 之间去重对象。创建第一个 fork 时，我们会：

1. 创建一个对象池代码仓库，其中包含即将创建 fork 的代码仓库的
   所有对象。
1. 使用 Git 的 alternates 机制将该代码仓库链接到这个新的对象池。
1. 重新打包该代码仓库，使其使用对象池中的对象。这样它
   就可以丢弃自己的对象副本。

现在，该代码仓库的任何 fork 都可以链接到该对象池，因此只需保留与主代码仓库不同的对象。

极狐GitLab 需要在对象池中执行特殊的例行维护操作：

- Gitaly 绝不能从对象池中删除不可达对象，因为它们
  可能被连接到该对象池的任何 fork 使用。
- 出于同样的原因，Gitaly 必须保持所有对象可达。因此，对象池
  会维护对不可达“悬空”对象的引用，使它们
  永远不会被删除。
- 极狐GitLab 必须定期更新对象池，以拉取主代码仓库中
  新增的对象。否则，对象池在去重对象方面的
  效率会越来越低。

这些例行维护操作由专门的 `FetchIntoObjectPool` RPC 执行，该 RPC 处理所有这些特殊任务，同时也执行我们为标准 Git 代码仓库执行的常规例行维护任务。

每当主成员被垃圾回收时，对象池都会自动得到优化。因此，可以使用该项目中相同的 Git GC 周期来配置频率。

如果您需要从 [Rails 控制台](operations/rails_console.md)手动调用该 RPC，可以调用 `project.pool_repository.object_pool.fetch`。这可能是一个长时间运行的任务，不过 Gitaly 会在约 8 小时后超时。
