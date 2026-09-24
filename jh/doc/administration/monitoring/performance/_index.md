---
stage: Shared responsibility based on functional area
group: Shared responsibility based on functional area
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 性能监控
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在性能瓶颈影响用户之前，通过极狐GitLab 性能监控检测它们。当出现缓慢的响应时间或内存问题时，可通过 SQL 查询、Ruby 处理及系统资源的详细指标精准定位原因。

实施性能监控的管理员会收到潜在问题的即时警报，防止其演变成实例级故障。跟踪事务时间、查询执行性能和内存使用情况，为组织维持最优的极狐GitLab 性能。

有关如何配置极狐GitLab 性能监控的更多信息，请参见：

- [Prometheus 文档](../prometheus/_index.md)。
- [Grafana 配置](grafana_configuration.md)。
- [性能栏](performance_bar.md)。

收集两类指标：

1. 事务特定指标。
1. 采样指标。

<a id="transaction-metrics"></a>

## 事务指标

事务指标是可与单个事务关联的指标，包括事务持续时间、任何已执行 SQL 查询的耗时，以及渲染 HAML 视图所花费的时间等统计信息。这些指标会针对每个已处理的 Rack 请求和 Sidekiq 作业收集。

<a id="sampled-metrics"></a>

## 采样指标

采样指标是无法与单个事务关联的指标，例如垃圾回收统计信息和保留的 Ruby 对象。这些指标按固定间隔收集，该间隔由两部分组成：

1. 用户定义的间隔。
1. 在间隔之上叠加的随机偏移量，同一偏移量不得连续使用两次。

实际间隔可能介于已定义间隔的一半至该间隔的 1.5 倍之间。例如，若用户定义的间隔为 15 秒，实际间隔可能在 7.5 秒至 22.5 秒之间。每次采样运行都会重新生成间隔，而非只生成一次并在进程整个生命周期内重复使用。

用户定义的间隔可通过环境变量指定。支持以下环境变量：

- `RUBY_SAMPLER_INTERVAL_SECONDS`
- `DATABASE_SAMPLER_INTERVAL_SECONDS`
- `ACTION_CABLE_SAMPLER_INTERVAL_SECONDS`
- `PUMA_SAMPLER_INTERVAL_SECONDS`
- `THREADS_SAMPLER_INTERVAL_SECONDS`
- `GLOBAL_SEARCH_SAMPLER_INTERVAL_SECONDS`