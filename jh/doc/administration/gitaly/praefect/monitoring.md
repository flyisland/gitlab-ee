---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 监控 Gitaly 集群（Praefect）
---

要监控 Gitaly 集群（Praefect），您可以使用 Prometheus 指标。有两个独立的指标端点可供抓取指标：

- 默认的 `/metrics` 端点。
- `/db_metrics`，其中包含需要数据库查询的指标。

<a id="default-prometheus-metrics-endpoint"></a>

## 默认 Prometheus `/metrics` 端点

以下指标可从 `/metrics` 端点获取：

- `gitaly_praefect_read_distribution`，用于跟踪[读取分布](_index.md#distributed-reads)的计数器。
  它有两个标签：

  - `virtual_storage`。
  - `storage`。

  它们反映为此 Praefect 实例定义的配置。

- `gitaly_praefect_replication_latency_bucket`，一个直方图，用于衡量复制作业开始后完成复制所需的时间。
- `gitaly_praefect_replication_delay_bucket`，一个直方图，用于衡量从创建复制作业到作业开始之间经过的时间。
- `gitaly_praefect_connections_total`，与 Praefect 的连接总数。
- `gitaly_praefect_method_types`，每个节点的访问器和变更器 RPC 的数量。

要监控[强一致性](_index.md#strong-consistency)，您可以使用以下 Prometheus 指标：

- `gitaly_praefect_transactions_total`，创建并投票的事务数量。
- `gitaly_praefect_subtransactions_per_transaction_total`，节点为单个事务投票的次数。如果在单个事务中更新多个引用，则可能发生多次。
- `gitaly_praefect_voters_per_transaction_total`：参与事务的 Gitaly 节点数量。
- `gitaly_praefect_transactions_delay_seconds`，等待事务提交所引入的服务端延迟。
- `gitaly_hook_transaction_voting_delay_seconds`，等待事务提交所引入的客户端延迟。

要监控[代码仓库验证](configure.md#repository-verification)，请使用以下 Prometheus 指标：

- `gitaly_praefect_verification_jobs_dequeued_total`，工作进程拾取的验证作业数量。
- `gitaly_praefect_verification_jobs_completed_total`，工作进程完成的验证作业数量。`result` 标签表示作业的最终结果：
  - `valid` 表示存储上存在预期的副本。
  - `invalid` 表示存储上不存在预期存在的副本。
  - `error` 表示作业失败，必须重试。
- `gitaly_praefect_stale_verification_leases_released_total`，已释放的过期验证租约数量。

您还可以监控 [Praefect 日志](../../logs/_index.md#praefect-logs)。

<a id="database-metrics-db_metrics-endpoint"></a>

## 数据库指标 `/db_metrics` 端点

以下指标可从 `/db_metrics` 端点获取：

- `gitaly_praefect_unavailable_repositories`，没有健康且最新副本的代码仓库数量。
- `gitaly_praefect_replication_queue_depth`，复制队列中的作业数量。
- `gitaly_praefect_verification_queue_depth`，待验证的副本总数。
