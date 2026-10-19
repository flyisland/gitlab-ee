---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 monorepo 性能
---

查看这些关于 monorepo 性能问题的建议。

<a id="slowness-during-git-clone-or-git-fetch"></a>

## `git clone` 或 `git fetch` 期间速度缓慢

克隆和拉取速度缓慢有几个关键原因。

<a id="high-cpu-utilization"></a>

### CPU 使用率过高

如果 Gitaly 节点上的 CPU 使用率过高，您还可以通过[按特定值筛选](observability.md#cpu-and-memory)来检查克隆占用了多少 CPU。

特别是，`command.cpu_time_ms` 字段可以指示克隆和拉取占用了多少 CPU。

在大多数情况下，服务器负载的大部分来自克隆和拉取期间启动的 `git-pack-objects` 进程。monorepo 通常非常繁忙，CI/CD 系统会向服务器发送大量克隆和拉取命令。

CPU 使用率过高是性能缓慢的常见原因。可能存在以下并非互斥的原因：

- [Gitaly 需要处理的克隆过多](#cause-too-many-large-clones)。
- [Gitaly 集群（Praefect）上的读取分布不佳](#cause-poor-read-distribution)。

<a id="cause-too-many-large-clones"></a>

#### 原因：大型克隆过多

Gitaly 需要处理的大型克隆可能过多。由于多种因素，Gitaly 可能难以跟上：

- 代码仓库的大小。
- 克隆和拉取的量。
- CPU 容量不足。

为帮助 Gitaly 处理大量大型克隆，您可能需要通过一些优化策略来减轻 Gitaly 服务器的负担，例如：

- 开启 [pack-objects-cache](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache) 以减少 `git-pack-objects` 必须完成的工作。
- 将 CI/CD 设置中的 [Git 策略](_index.md#use-git-fetch-in-cicd-operations)从 `clone` 改为 `fetch` 或 `none`。
- [停止拉取标签](_index.md#change-git-fetch-behavior-with-flags)，除非您的测试需要这些标签。
- 尽可能[使用浅克隆](_index.md#use-shallow-clones-and-filters-in-cicd-processes)。

另一种选择是增加 Gitaly 服务器上的 CPU 容量。

<a id="cause-poor-read-distribution"></a>

#### 原因：读取分布不佳

您可能在 Gitaly 集群（Praefect）上的读取分布不佳。

要观察大部分读取流量是否都流向主 Gitaly 节点，而不是分布到整个集群，请使用[读取分布 Prometheus 指标](observability.md#read-distribution)。

如果 Gitaly 从节点没有收到太多流量，可能是因为从节点一直处于不同步状态。这个问题在 monorepo 中会加剧。

monorepo 通常既庞大又繁忙。这会导致两种影响。首先，monorepo 经常被推送，并且有大量 CI 作业在运行。有时，诸如删除分支之类的写操作会导致对从节点的代理调用失败。这会在 Gitaly 集群（Praefect）中触发复制作业，以便从节点最终能够跟上。

复制作业本质上是由从节点向主节点发起的一次 `git fetch`，而由于 monorepo 通常非常大，这次获取可能需要很长时间。

如果下一次调用在上一个复制作业完成之前就失败，并且这种情况持续发生，您最终可能会陷入 monorepo 的从节点始终落后的状态。这会导致所有流量都流向主节点。

这些代理写入失败的一个原因是 Git `$GIT_DIR/packed-refs` 文件的已知问题。要删除文件中的某个条目，必须锁定该文件，这可能导致竞态条件，在并发删除发生时导致删除失败。

GitLab 的工程师已开发出缓解措施，尝试批量处理引用删除。

开启以下[功能标志](../../../../administration/feature_flags/_index.md)，以允许极狐GitLab 批量删除引用。启用这些功能标志无需停机。

- `merge_request_cleanup_ref_worker_async`
- `pipeline_cleanup_ref_worker_async`
- `pipeline_delete_gitaly_refs_in_batches`
- `merge_request_delete_gitaly_refs_in_batches`

[史诗 4220](https://gitlab.com/groups/gitlab-org/-/epics/4220) 提议在极狐GitLab 中添加 RefTable 支持，这被视为长期解决方案。
