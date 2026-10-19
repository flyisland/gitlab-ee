---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo 后台作业
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Geo 将所有同步和验证意图持久化在 Geo 跟踪数据库的注册表中，而不是 Sidekiq 作业参数中。
如果作业被终止，注册表记录会保留其状态，基于 cron 的调度器会重新将工作加入队列。这种设计使 Geo 从根本上具备崩溃安全性。

<a id="registry-sync-states"></a>

## 注册表同步状态

每种可复制的数据类型在从站点上都有一个注册表记录，用于跟踪同步状态：

| 状态 | 描述 |
|-------|-------------|
| `pending` | 需要同步。由同步调度器 cron 拾取。 |
| `started` | 同步进行中。如果工作进程被终止，记录将保持此状态。 |
| `synced` | 已成功复制。 |
| `failed` | 同步失败。具有 `retry_at` 时间戳，用于指数退避重试。 |

如果同步作业被终止，注册表将保持在 `started` 状态。
`Geo::SyncTimeoutCronWorker` 每 10 分钟运行一次，检测同步作业状态，并将注册表标记为 `failed` 并带有重试退避。
然后，同步调度器 cron 工作进程会重新将注册表加入同步队列。

<a id="recovery-mechanisms"></a>

## 恢复机制

以下 cron 工作进程提供自动恢复。它们的调度在 [`ee/config/schedule.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/config/schedule.yml) 中定义，并且是可配置的。

cron 作业名称与 [**管理员**区域](../../admin_area.md#background-jobs) 中 Sidekiq 仪表板的 **Cron** 选项卡中显示的名称匹配。

| 机制 | 工作进程 | Cron 作业名称 | 默认调度 | 用途 |
|-----------|--------|---------------|------------------|---------|
| 同步超时恢复 | `Geo::SyncTimeoutCronWorker` | `geo_sync_timeout_cron_worker` | 每 10 分钟（从节点） | 将卡在 `started` 状态的注册表标记为 `failed` 并带有重试退避。 |
| 数据块同步调度器 | `Geo::RegistrySyncWorker` | `geo_registry_sync_worker` | 每 1 分钟（从节点） | 轮询 `pending` 和 `failed` 数据块注册表，并将 `Geo::SyncWorker` 加入队列。 |
| 代码仓库同步调度器 | `Geo::RepositoryRegistrySyncWorker` | `geo_repository_registry_sync_worker` | 每 1 分钟（从节点） | 轮询 `pending` 和 `failed` 代码仓库注册表，并将 `Geo::SyncWorker` 加入队列。 |
| 注册表一致性 | `Geo::Secondary::RegistryConsistencyWorker` | `geo_secondary_registry_consistency_worker` | 每 1 分钟（从节点） | 为未跟踪的可复制项创建缺失的注册表记录。检测孤立的注册表。 |
| 验证超时 | `Geo::VerificationTimeoutWorker` | 由 `geo_verification_cron_worker` 触发 | 每 1 分钟（主节点和从节点） | 将卡在 `verification_started` 的验证标记为 `verification_failed`。 |
| 验证调度器 | `Geo::VerificationCronWorker` | `geo_verification_cron_worker` | 每 1 分钟（主节点和从节点） | 触发验证批次、超时、重新验证和状态回填工作进程。 |

<a id="queue-safety-reference"></a>

## 队列安全参考

以下部分提供 Geo Sidekiq 队列的每个工作进程的安全信息。

<a id="cron-workers"></a>

### Cron 工作进程

Cron 工作进程是自动调度的，如果其队列被清空，将在下一个 cron 周期重新运行。
所有 cron 工作进程队列都可以安全清空。

| 工作进程 | 功能 | 清空队列是否安全 | 清空的负面影响 | 恢复机制 |
|--------|-------------|:-------------------:|-----------------------------------|-------------------|
| `Geo::RegistrySyncWorker` | 轮询待处理的和失败的数据块注册表。将 `Geo::SyncWorker` 加入队列。 | 是 | 同步延迟到下一个 cron 周期。 | 每 1 分钟重新运行。 |
| `Geo::RepositoryRegistrySyncWorker` | 轮询待处理的和失败的代码仓库注册表。将 `Geo::SyncWorker` 加入队列。 | 是 | 同步延迟到下一个 cron 周期。 | 每 1 分钟重新运行。 |
| `Geo::SyncTimeoutCronWorker` | 查找卡在 `started` 状态的注册表。将它们标记为 `failed` 并带有重试退避。 | 是 | 卡在 `started` 状态的注册表在下一个周期之前不会转换为 `failed`。同步在下一个周期后恢复。 | 每 10 分钟重新运行。 |
| `Geo::Secondary::RegistryConsistencyWorker` | 扫描所有注册表类型。创建缺失的注册表。检测孤立的注册表并将 `Geo::DestroyWorker` 加入队列。 | 是 | 在下一个周期之前，不会创建缺失的注册表，也不会清理孤立的注册表。 | 每 1 分钟重新运行。 |
| `Geo::VerificationCronWorker` | 触发所有验证子工作进程。 | 是 | 验证延迟到下一个 cron 周期。 | 每 1 分钟重新运行。 |
| `Geo::VerificationTimeoutWorker` | 恢复卡在 `verification_started` 状态的记录。 | 是 | 卡在 `verification_started` 状态的记录在下一个周期之前不会转换。 | 每 1 分钟重新运行。 |
| `Geo::PruneEventLogWorker` | 删除所有从节点都已消费的旧事件日志条目（仅主节点）。 | 是 | 事件日志会增长，直到工作进程再次运行。不会丢失数据。 | 每 5 分钟重新运行。 |
| `Geo::MetricsUpdateWorker` | 计算节点状态，更新 Prometheus 指标，将状态发送到主节点。 | 是 | 指标会变得陈旧，直到工作进程再次运行。 | 每 1 分钟重新运行。 |
| `Geo::SidekiqCronConfigWorker` | 根据节点类型（主节点或从节点）启用和禁用 cron 作业。 | 是 | 在下次运行前，cron 作业配置可能不正确。 | 每 1 分钟重新运行。 |

<a id="sync-workers-secondary"></a>

### 同步工作进程（从节点）

| 工作进程 | 功能 | 清空队列是否安全 | 清空的负面影响 | 恢复机制 |
|--------|-------------|:-------------------:|-----------------------------------|-------------------|
| `Geo::SyncWorker` | 从主站点下载单个数据块或获取单个代码仓库。 | 是 | 进行中作业的注册表保持在 `started` 状态。同步延迟到恢复。 | `SyncTimeoutCronWorker` 将卡住的注册表转换为 `failed`。同步调度器重新加入队列。 |
| `Geo::ContainerRepositorySyncWorker` | 从主站点同步单个容器镜像仓库。 | 是 | 注册表保留其状态。同步延迟到恢复。 | 同步调度器重新加入队列。 |
| `Geo::BulkRegistryResyncWorker` | 触发注册表类的批量重新同步。 | 是 | 批量重新同步不会开始。各个注册表保留其状态。 | 调用方重新加入队列。 |

<a id="event-workers-primary-and-secondary"></a>

### 事件工作进程（主节点和从节点）

> [!warning]
> 当您清空事件工作进程队列时，队列中的事件可能会丢失。
> 丢失的事件可能导致从站点上的数据暂时过期。

| 工作进程 | 功能 | 清空队列是否安全 | 清空的负面影响 | 恢复机制 |
|--------|-------------|:-------------------:|-----------------------------------|-------------------|
| `Geo::EventWorker` | 在从站点处理 Geo 复制事件（`created`、`updated`、`deleted`）。 | 谨慎使用。 | 丢失 `updated` 事件可能导致资源过期，直到重新验证或下一个更新事件。丢失 `deleted` 事件可能在从站点留下孤立文件（浪费磁盘，不丢失数据）。丢失 `created` 事件没有持久影响。有 3 次 Sidekiq 重试。 | 即使所有重试都失败，注册表记录仍然存在，同步调度器会重新加入队列。`RegistryConsistencyWorker` 也会检测孤立的注册表。 |
| `Geo::BatchEventCreateWorker` | 在主站点批量插入 Geo 事件。 | 谨慎使用。 | 如果清空，队列中的事件将丢失。从站点可能直到重新验证才会得知更改。 | 从站点上的 `RegistryConsistencyWorker` 最终会检测到缺失的注册表（每 1 分钟）。 |
| `Geo::CreateRepositoryUpdatedEventWorker` | 当主站点上的代码仓库更新时创建 Geo 事件。 | 谨慎使用。 | 与 `Geo::BatchEventCreateWorker` 相同。 | 与 `Geo::BatchEventCreateWorker` 相同。 |

<a id="verification-workers-primary-and-secondary"></a>

### 验证工作进程（主节点和从节点）

| 工作进程 | 功能 | 清空队列是否安全 | 清空的负面影响 | 恢复机制 |
|--------|-------------|:-------------------:|-----------------------------------|-------------------|
| `Geo::VerificationBatchWorker` | 对记录批次进行校验和计算。 | 是 | 验证延迟。 | Cron 重新加入队列。`VerificationTimeoutWorker` 捕获卡住的记录。 |
| `Geo::ReverificationBatchWorker` | 标记已验证的记录以进行定期重新验证。 | 是 | 重新验证延迟。 | Cron 重新加入队列。 |
| `Geo::VerificationStateBackfillWorker` | 为可复制类型回填验证状态表。 | 是 | 回填延迟。独占租约在 30 分钟后过期。 | 自行重新加入队列。 |
| `Geo::BulkPrimaryVerificationWorker` | 在主站点触发模型类的批量验证。 | 是 | 批量验证不会开始。 | 调用方重新加入队列。 |
| `Geo::BulkRegistryReverificationWorker` | 在从站点触发注册表类的批量重新验证。 | 是 | 批量重新验证不会开始。 | 调用方重新加入队列。 |

<a id="destroy-workers-secondary"></a>

### 销毁工作进程（从节点）

> [!warning]
> 当您清空销毁工作进程队列时，
> 丢失的作业可能在从站点留下孤立的文件或代码仓库。

| 工作进程 | 功能 | 清空队列是否安全 | 清空的负面影响 | 恢复机制 |
|--------|-------------|:-------------------:|-----------------------------------|-------------------|
| `Geo::DestroyWorker` | 在主站点删除后，删除从站点上复制的文件或代码仓库。 | 谨慎使用。 | 孤立的文件或代码仓库保留在从站点上，浪费磁盘空间。不丢失数据。有 3 次 Sidekiq 重试。 | `RegistryConsistencyWorker` 检测孤立的注册表并重新将 `DestroyWorker` 加入队列。 |
