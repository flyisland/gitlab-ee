---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 仓库整理
description: Git 仓库的整理任务。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 支持并自动化 Git 仓库的整理任务，以确保它们能够尽可能高效地提供服务。整理任务包括：

- 压缩 Git 对象和修订版本。
- 移除不可达对象。
- 移除陈旧数据，如锁文件。
- 维护提升性能的数据结构。
- 更新对象池以改进跨 forks 的对象去重。

> [!warning]
> 不要手动执行 Git 命令来执行由极狐GitLab 管理的 Git 仓库的整理。这样做可能导致仓库损坏和数据丢失。

<a id="housekeeping-strategy"></a>

## 整理策略

Gitaly 可以通过两种方式在 Git 仓库中执行整理任务：

- [急切式整理](#eager-housekeeping) 独立于仓库状态执行特定的整理任务。
- [启发式整理](#heuristical-housekeeping) 基于一组启发式规则执行整理任务，这些规则根据仓库状态确定需要执行哪些整理任务。

<a id="eager-housekeeping"></a>

### 急切式整理

“急切式”整理策略独立于仓库状态执行整理任务。这是[手动触发](#manual-trigger)和基于推送的触发器所使用的默认策略。

急切式整理策略由极狐GitLab 应用程序控制。根据导致整理任务运行的触发器，极狐GitLab 要求 Gitaly 执行特定的整理任务。即使仓库已处于优化状态，Gitaly 也会执行这些任务。因此，对于大型仓库，这种策略可能效率低下，因为执行整理任务可能会很慢。

<a id="heuristical-housekeeping"></a>

### 启发式整理

{{< history >}}

- 在极狐GitLab 14.9 中为[手动触发](#manual-trigger)和基于推送的触发器引入，具有名为 `optimized_housekeeping` 的功能标志。默认启用。
- 在极狐GitLab 14.10 中于 JihuLab.com 上启用。
- 在极狐GitLab 15.8 中 GA。功能标志 `optimized_housekeeping` 已移除。

{{< /history >}}

启发式（或“机会式”）整理策略分析仓库状态，仅当发现一个或多个数据结构优化不足时才执行整理任务。这是[计划整理](#scheduled-housekeeping)所使用的策略。

启发式整理使用以下信息来决定需要运行哪些任务：

- 松散和过时对象的数量。
- 包含已压缩对象的 packfile 数量。
- 松散引用的数量。
- commit-graph 的存在。

判断上述任何分析的数据结构是否需要优化，取决于仓库的大小：

- 对象的总大小越大，对象的重新打包就越频繁。
- 引用的总数越多，引用的重新打包就越不频繁。

Gitaly 这样做是为了抵消以下事实：这些数据结构越大，优化它们所需的时间就越长。这在大型 monorepo（接收大量流量）中尤为重要，以避免过于频繁地对其进行优化。

你可以更改 Gitaly 被要求优化仓库的频率。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **代码仓**。
1. 展开 **仓库维护**。
1. 在 **整理** 部分，配置整理选项。
1. 选择 **保存更改**。

- **启用自动仓库整理**：定期要求 Gitaly 运行仓库优化。如果长期禁用此设置，极狐GitLab 服务器上的 Git 仓库访问速度会变慢，仓库也会占用更多磁盘空间。
- **优化仓库周期**：向 Git 推送多少次后要求 Gitaly 优化仓库。

<a id="running-housekeeping-tasks"></a>

## 运行整理任务

极狐GitLab 运行整理任务的方式有多种：

- 项目管理员可以[手动触发](#manual-trigger)仓库整理任务。
- 极狐GitLab 可以在一定数量的 Git 推送后自动安排整理任务。
- 极狐GitLab 可以[安排一个作业](#scheduled-housekeeping)，在可配置的时间范围内为所有仓库运行整理任务。

<a id="manual-trigger"></a>

### 手动触发

仓库管理员可以手动触发仓库中的整理任务。通常不需要这样做，因为极狐GitLab 会自动运行整理任务。手动触发在以下情况下可能有用：

- 已知某个仓库需要进行整理。
- 已禁用基于推送的自动安排整理任务。

要手动触发整理任务：

1. 在顶栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 选择 **运行整理**。

这会为项目仓库启动一个异步后台工作器。该后台工作器会要求 Gitaly 执行一系列优化。

整理还会每 `200` 次推送从项目中[移除未引用的 LFS 文件](raketasks/cleanup.md#remove-unreferenced-lfs-files)，释放项目的存储空间。

<a id="prune-unreachable-objects"></a>

### 清理不可达对象

作为计划整理的一部分，不可达对象会被清理。不过，你也可以手动触发清理。触发整理会以两周的宽限期清理不可达对象。当你手动触发清理不可达对象时，宽限期缩短为 30 分钟。

> [!warning]
> 清理不可达对象并不能保证移除泄露的密钥和其他敏感信息。有关如何移除已提交但未推送的密钥的信息，请参阅[从提交中移除密钥的教程](../user/application_security/secret_detection/remove_secrets_tutorial.md)。
> 此外，你还可以[单独移除 blob](../user/project/repository/repository_size.md#remove-blobs)。请参考该文档了解执行该操作可能产生的后果。
>
> 如果并发进程（如 `git push`）已创建一个对象但尚未创建对该对象的引用，而在对象被删除后又添加了对该对象的引用，你的仓库可能会损坏。宽限期的存在是为了降低此类竞争条件的可能性。
> 例如，如果在有时非常缓慢的连接上频繁推送大量对象，清理不可达对象带来的风险要比在公司内部高性能连接环境中高得多。使用此选项时，请考虑项目的使用情况，并选择一个安静时段。

要手动触发不可达对象清理：

1. 在顶栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 选择 **运行整理**。
1. 等待 30 分钟让操作完成。
1. 返回你选择 **运行整理** 的页面，并选择 **清理不可达对象**。

<a id="scheduled-housekeeping"></a>

### 计划整理

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

尽管极狐GitLab 会根据推送次数自动执行整理任务，但它不会维护那些完全没有收到任何推送的仓库。因此，休眠仓库或只接收读取请求的仓库可能无法受益于仓库整理策略的改进。

管理员可以启用一个后台作业，以可自定义的间隔对所有仓库执行整理，来解决此问题。此后台作业以随机顺序处理由 Gitaly 节点托管的所有仓库，并对其进行急切式整理。如果处理时间超过配置的间隔，Gitaly 节点将停止处理仓库。

<a id="configure-scheduled-housekeeping"></a>

#### 配置计划整理

Git 仓库的后台维护在 Gitaly 中配置。默认情况下，Gitaly 每天中午 12:00 执行持续 10 分钟的后台仓库维护。

你可以在 Gitaly 配置中更改此默认设置。

对于使用 Gitaly 集群（Praefect）的环境，可以错开各个 Gitaly 节点的计划整理开始时间，以避免计划整理在多个节点上同时运行。

如果一次计划整理运行达到了指定的 `duration`，正在运行的任务将被优雅地取消。在随后的计划整理运行中，Gitaly 会随机打乱仓库列表的处理顺序。

以下代码片段为 `default` 存储启用了从 23:00 开始、持续 1 小时的每日后台仓库维护：

{{< tabs >}}

{{< tab title="自编译（源代码）" >}}

```toml
[daily_maintenance]
start_hour = 23
start_minute = 00
duration = 1h
storages = ["default"]
```

使用以下代码片段完全禁用后台仓库维护：

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

使用以下代码片段完全禁用后台仓库维护：

```ruby
gitaly['configuration'] = {
  daily_maintenance: {
    disabled: true,
  },
}
```

{{< /tab >}}

{{< /tabs >}}

当计划整理执行时，你可以在 [Gitaly 日志](logs/_index.md#gitaly-logs)中看到以下条目：

```json
# 计划整理开始时
{"level":"info","msg":"maintenance: daily scheduled","pid":197260,"scheduled":"2023-09-27T13:10:00+13:00","time":"2023-09-27T00:08:31.624Z"}

# 计划整理完成时
{"actual_duration":321181874818,"error":null,"level":"info","max_duration":"1h0m0s","msg":"maintenance: daily completed","pid":197260,"time":"2023-09-27T00:15:21.182Z"}
```

`actual_duration`（以纳秒为单位）表示计划维护执行所花费的时间。在上例中，计划整理在 5 分钟多一点的时间内完成。

<a id="object-pool-repositories"></a>

## 对象池仓库

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

对象池仓库被极狐GitLab 用于跨 forks 对对象进行去重。创建第一个 fork 时，我们会：

1. 创建一个对象池仓库，其中包含即将被 fork 的仓库的所有对象。
1. 使用 Git 的 alternates 机制将该仓库与此新对象池链接。
1. 重新打包仓库，使其使用对象池中的对象。这样，它就可以丢弃自己的对象副本。

该仓库的任何 forks 现在都可以链接到该对象池，因此只需保留与主仓库不同的对象。

极狐GitLab 需要在对象池中执行特殊的整理操作：

- Gitaly 永远不能从对象池中删除不可达对象，因为连接到它的任何 fork 都可能使用它们。
- 出于同样的原因，Gitaly 必须保持所有对象可达。因此，对象池会维护对不可达的“悬空”对象的引用，以确保它们不会被删除。
- 极狐GitLab 必须定期更新对象池，以拉取主仓库中添加的新对象。否则，对象池在去重对象方面会变得越来越低效。

这些整理操作由专门的 `FetchIntoObjectPool` RPC 执行，该 RPC 处理所有这些特殊任务，同时也执行我们为标准 Git 仓库执行的常规整理任务。

每当主成员进行垃圾回收时，对象池都会自动进行优化。因此，可以在该项目中使用相同的 Git GC 周期来配置节奏。

如果你需要从 [Rails 控制台](operations/rails_console.md)手动调用该 RPC，可以调用 `project.pool_repository.object_pool.fetch`。这是一个可能长时间运行的任务，不过 Gitaly 大约 8 小时后会超时。
