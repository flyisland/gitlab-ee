---
stage: Shared responsibility based on functional area
group: Shared responsibility based on functional area
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 极狐GitLab 性能监控
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

借助极狐GitLab 性能监控，在性能瓶颈影响用户之前就将其检测出来。当出现响应时间缓慢或内存问题时，可通过 SQL 查询、Ruby 处理和系统资源的详细指标，精确定位其确切原因。

实施性能监控的管理员可以立即收到潜在问题的告警，避免这些问题演变为影响整个实例的故障。跟踪事务时间、查询执行性能和内存使用情况，为您的组织维持极狐GitLab 的最佳性能。

有关如何配置极狐GitLab 性能监控的更多信息，请参阅：

- [Prometheus 文档](../prometheus/_index.md)。
- [Grafana 配置](grafana_configuration.md)。
- [性能栏](performance_bar.md)。

收集的指标分为两类：

1. 事务特定指标。
1. 采样指标。

<a id="transaction-metrics"></a>

## 事务指标

事务指标是指可以与单个事务关联的指标。这包括事务持续时间、所执行 SQL 查询的耗时以及渲染 HAML 视图所花费的时间等统计数据。这些指标会针对每个已处理的 Rack 请求和 Sidekiq 作业进行收集。

<a id="sampled-metrics"></a>

## 采样指标

采样指标是指无法与单个事务关联的指标。例如垃圾回收统计信息和保留的 Ruby 对象。这些指标按固定间隔收集。该间隔由两部分组成：

1. 用户定义的间隔。
1. 在间隔之上添加的随机生成的偏移量，同一偏移量不能连续使用两次。

实际间隔可以介于所定义间隔的一半到该间隔的 1.5 倍之间。例如，对于用户定义的 15 秒间隔，实际间隔可以介于 7.5 到 22.5 之间。该间隔在每次采样运行时都会重新生成，而不是生成一次后在该进程的整个生命周期内重复使用。

用户定义的间隔可以通过环境变量指定。可识别以下环境变量：

- `RUBY_SAMPLER_INTERVAL_SECONDS`
- `DATABASE_SAMPLER_INTERVAL_SECONDS`
- `ACTION_CABLE_SAMPLER_INTERVAL_SECONDS`
- `PUMA_SAMPLER_INTERVAL_SECONDS`
- `THREADS_SAMPLER_INTERVAL_SECONDS`
- `GLOBAL_SEARCH_SAMPLER_INTERVAL_SECONDS`
- `PG_ASH_SAMPLER_INTERVAL_SECONDS`

<a id="active-session-history"></a>

## 活动会话历史

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 实验

{{< /details >}}

活动会话历史会对主数据库上的 `pg_stat_activity` 进行采样，因此您可以查看数据库在过去某个时间点的运行情况。极狐GitLab 内置了 [pg_ash](https://github.com/NikolayS/pg_ash) 来收集和存储这些样本。

此功能属于实验，尚未准备好用于生产环境。请先在生产环境之外进行测试。

`pg_ash` 默认未安装，采样默认关闭。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

要安装 `pg_ash`：

```shell
sudo gitlab-rake gitlab:db:pg_ash:install
```

要检查安装情况：

```shell
sudo gitlab-rake gitlab:db:pg_ash:status
```

要移除 `pg_ash` 及其保存的所有样本：

```shell
sudo gitlab-rake gitlab:db:pg_ash:uninstall
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

要安装 `pg_ash`：

```shell
kubectl exec -it <toolbox-pod-name> -- gitlab-rake gitlab:db:pg_ash:install
```

要检查安装情况：

```shell
kubectl exec -it <toolbox-pod-name> -- gitlab-rake gitlab:db:pg_ash:status
```

要移除 `pg_ash` 及其保存的所有样本：

```shell
kubectl exec -it <toolbox-pod-name> -- gitlab-rake gitlab:db:pg_ash:uninstall
```

{{< /tab >}}

{{< tab title="Docker" >}}

要安装 `pg_ash`：

```shell
sudo docker exec -t <container-name> gitlab-rake gitlab:db:pg_ash:install
```

要检查安装情况：

```shell
sudo docker exec -t <container-name> gitlab-rake gitlab:db:pg_ash:status
```

要移除 `pg_ash` 及其保存的所有样本：

```shell
sudo docker exec -t <container-name> gitlab-rake gitlab:db:pg_ash:uninstall
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

要安装 `pg_ash`：

```shell
sudo -u git -H bundle exec rake gitlab:db:pg_ash:install RAILS_ENV=production
```

要检查安装情况：

```shell
sudo -u git -H bundle exec rake gitlab:db:pg_ash:status RAILS_ENV=production
```

要移除 `pg_ash` 及其保存的所有样本：

```shell
sudo -u git -H bundle exec rake gitlab:db:pg_ash:uninstall RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

要开启采样：

1. 以具有管理员访问权限的用户身份登录。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **指标和分析**。
1. 展开**活动会话历史**部分。
1. 选中**开启会话采样**复选框。
1. 可选。更改**采样间隔（秒）**。默认值为一秒。
1. 选择**保存更改**。

Sidekiq 进程中的一个后台线程负责采集样本。同一时间只有一个进程进行采样，因此您设置的间隔就是整个实例的间隔。采样需要极狐GitLab Prometheus 指标端点，该端点默认开启。采样会在 Sidekiq 停止时停止，因此重启或部署可能会丢失样本。

对任一设置的更改无需重启即可生效，但不会立即生效。每个 Sidekiq 进程最多需要 90 秒来读取新值。

`PG_ASH_SAMPLER_INTERVAL_SECONDS` 设置 Sidekiq 进程检查是否应接管采样进程的频率。它不设置采样间隔。

<a id="rollup-and-retention"></a>

### 汇总与保留

采样开启期间，Sidekiq cron 作业会汇总并移除旧样本：

| 作业 | 运行频率 | 作用 |
|-----|------|--------|
| `pg_ash_rollup_minute_worker` | 每分钟 | 将原始样本汇总为每分钟一行。 |
| `pg_ash_rollup_hour_worker` | 每小时 | 将每分钟的行汇总为每小时一行。 |
| `pg_ash_rotate_worker` | 每天 00:03 至 05:03 之间每小时 | 每天移除最旧一天的原始样本。其他运行属于重试。 |
| `pg_ash_rollup_cleanup_worker` | 每天 03:07 至 05:07 之间每小时 | 移除超过其保留期限的每分钟和每小时行。 |

时间采用 [cron 作业时区](../../settings/sidekiq.md#cron-jobs-time-zone)，默认为 UTC。

在 `pg_ash`的默认设置下，原始样本保留一整天加上当天，每分钟行保留 30 天，每小时行保留五年。保留期限值位于 `ash.config` 表中。针对这些值的管理员设置已在[议题 608100](https://gitlab.com/gitlab-org/gitlab/-/work_items/608100)中提出。

原始样本只有在汇总之后才会被移除。如果某次轮转无法确认这一点，则会失败，并且 `gitlab_pg_ash_consecutive_rotate_failures` 指标会增加。`gitlab:db:pg_ash:status` Rake 任务会显示相同的计数器。

当您关闭采样时，这些作业会停止。在此之前收集的数据会一直保留，直到您卸载 `pg_ash`。
