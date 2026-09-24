---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查单体仓库性能问题
---

查看以下关于单体仓库性能问题的建议。

<a id="slowness-during-git-clone-or-git-fetch"></a>

## `git clone` 或 `git fetch` 期间速度缓慢

导致克隆和拉取缓慢的几个主要原因如下。

<a id="high-cpu-utilization"></a>

### 高 CPU 使用率

如果你的 Gitaly 节点的 CPU 使用率较高，你还可以通过 [根据特定值过滤](observability.md#cpu-and-memory) 来查看克隆操作占用了多少 CPU。

具体来说，`command.cpu_time_ms` 字段可以显示克隆和拉取占用了多少 CPU。

在大多数情况下，服务器的大部分负载来自 `git-pack-objects` 进程，该进程在克隆和拉取过程中启动。单体仓库通常非常繁忙，CI/CD 系统会向服务器发送大量的克隆和拉取命令。

高 CPU 使用率是导致性能缓慢的常见原因。以下可能的原因并不相互排斥：

- [Gitaly 需要处理的克隆过多](#cause-too-many-large-clones)。
- [Gitaly Cluster（Praefect）读取分布不佳](#cause-poor-read-distribution)。

<a id="cause-too-many-large-clones"></a>

#### 原因：大型克隆过多

你可能对 Gitaly 发起了过多的大型克隆。由于以下因素，Gitaly 可能难以跟上：

- 仓库大小。
- 克隆和拉取的量。
- CPU 容量不足。

为了帮助 Gitaly 处理大量克隆，你可能需要通过一些优化策略来减轻 Gitaly 服务器的负担，例如：

- 启用 [pack-objects-cache](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache) 以减少 `git-pack-objects` 必须执行的工作。
- 将 CI/CD 设置中的 [Git 策略](_index.md#use-git-fetch-in-cicd-operations) 从 `clone` 改为 `fetch` 或 `none`。
- [停止拉取标签](_index.md#change-git-fetch-behavior-with-flags)，除非你的测试需要它们。
- 尽可能 [使用浅克隆](_index.md#use-shallow-clones-and-filters-in-cicd-processes)。

另一个选择是增加 Gitaly 服务器的 CPU 容量。

<a id="cause-poor-read-distribution"></a>

#### 原因：读取分布不佳

你可能在 Gitaly Cluster（Praefect）上的读取分布不佳。

要观察大部分读取流量是否流向主 Gitaly 节点而不是分布到整个集群，请使用 [读取分布 Prometheus 指标](observability.md#read-distribution)。

如果辅助 Gitaly 节点没有接收到太多流量，可能是辅助节点始终处于不同步状态。在单体仓库中，这个问题会更加严重。

单体仓库通常既庞大又繁忙。这会导致两种影响。首先，单体仓库经常被推送，并且有大量的 CI 作业在运行。有时，删除分支等写操作在向辅助节点发起代理调用时会失败。这会触发 Gitaly Cluster（Praefect）中的复制作业，以便辅助节点最终能够赶上。

复制作业本质上是辅助节点到主节点的一次 `git fetch`，由于单体仓库通常非常庞大，这次拉取可能需要很长时间。

如果在前一个复制作业完成之前下一次调用又失败了，并且这种情况持续发生，你可能会陷入这样一种状态：你的单体仓库在辅助节点上始终处于落后状态。这会导致所有流量都流向主节点。

这些代理写操作失败的一个原因是 Git `$GIT_DIR/packed-refs` 文件的一个已知问题。该文件必须被锁定才能删除其中的条目，这可能导致竞态条件，当并发删除发生时，删除操作会失败。

极狐GitLab 的工程师已经开发了缓解措施，尝试批量引用删除。

开启以下 [功能标志](../../../../administration/feature_flags/_index.md) 以允许极狐GitLab 批量 ref 删除。启用这些功能标志不需要停机。

- `merge_request_cleanup_ref_worker_async`
- `pipeline_cleanup_ref_worker_async`
- `pipeline_delete_gitaly_refs_in_batches`
- `merge_request_delete_gitaly_refs_in_batches`

[史诗 4220] 提议在极狐GitLab 中添加 RefTable 支持，这被认为是一个长期解决方案。