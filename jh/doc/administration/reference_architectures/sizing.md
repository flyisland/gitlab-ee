---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Guide to define Reference Architecture size and component-specific adjustments.
title: 评估参考架构规模
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要选择合适的参考架构，你应该使用系统化的方法来评估和调整基于参考架构的极狐GitLab 环境规模。

要确定合适的参考架构以及任何必要的组件调整，以下信息可帮助你进行分析：

- 每秒请求数 (RPS) 模式。
- 工作负载特征。
- 资源饱和度。

## 开始之前

<a id="before-you-begin"></a>

如果你的环境比较复杂，可以使用这些信息来选择合适的参考架构。
你可能不需要如此详细的信息，也可以使用[适用于不太复杂环境的信息](_index.md)来评估环境规模。

> [!note]
> 需要专家指导？正确调整架构规模对于实现最佳性能至关重要。我们的
> [专业服务](https://gitlab.cn/professional-services/) 团队可以评估你的特定架构，并为性能、稳定性和可用性优化提供量身定制的建议。

要遵循本文档，你必须已为极狐GitLab 实例部署了 Prometheus 监控。Prometheus 为正确的规模评估提供了所需的准确指标。

如果你尚未配置 Prometheus：

1. 使用 [Prometheus](../monitoring/prometheus/_index.md) 配置监控。参考架构文档提供了每种环境规模下 Prometheus 配置的详细信息。对于云原生极狐GitLab，你可以使用
   [`kube-prometheus-stack`](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) Helm Chart 来配置指标抓取。
1. 收集 7-14 天的数据，以获取有意义的数据模式。
1. 阅读本文档的其余部分。

如果你无法配置 Prometheus 监控：

- [将当前环境的规格](#analyze-current-environment-and-validate-recommendations)与最接近的参考架构进行比较，以估算规模。
- 使用 [GitLab RPS 分析器](https://gitlab.com/gitlab-org/professional-services-automation/tools/utilities/gitlab-rps-analyzer#gitlab-rps-analyzer) 通过 GitLabSOS 或 KubeSOS 日志来评估参考架构规模。但请注意，这不如使用指标可靠。

如果是从其他平台迁移，没有现有的极狐GitLab 指标，则无法应用以下 PromQL 查询。
但是，总体的评估方法依然有效：

1. 根据预期的工作负载估算最接近的参考架构。
1. 识别预期的[额外工作负载](_index.md#additional-workloads)。
1. 评估大型仓库的数量。
1. 纳入增长预测。
1. 选择一个具有[适当缓冲](_index.md#if-in-doubt-start-large-monitor-and-then-scale-down)的参考架构。

### 运行 PromQL 查询

<a id="running-promql-queries"></a>

运行 PromQL 查询取决于你所使用的监控方案。如 [Prometheus 监控文档](../monitoring/prometheus/_index.md#how-prometheus-works)中所述，可以通过直接连接到 Prometheus 或使用诸如 Grafana 之类的仪表板工具来访问监控数据。

## 确定你的基线规模

<a id="determine-your-baseline-size"></a>

每秒请求数 (RPS) 是调整极狐GitLab 基础设施规模的主要指标。不同的流量类型（API、Web、Git 操作）会对不同的组件造成压力，因此需要分别分析每种类型，以确定真实的容量需求。

### 提取峰值流量指标

<a id="extract-peak-traffic-metrics"></a>

运行以下查询以了解你的最大负载。这些查询会显示：

- 绝对峰值，即你曾见过的最高尖峰。绝对峰值显示了最坏情况。
- 持续峰值，即第 95 百分位数，被认为是你典型的“繁忙”水平。持续峰值揭示了典型的高负载时段。

如果绝对峰值是罕见的异常情况，那么根据持续负载来确定规模可能是合适的。

根据保留时间调整查询中的时间范围（如果有更长的历史记录，可以将 `[7d]` 改为 `[30d]`）。

> [!note]
> 对于高活跃度的环境，`max_over_time` 或 `quantile_over_time` 查询可能会超时。
> 如果发生这种情况，请移除外部聚合函数，并使用图表来可视化内部查询。
> 例如，对于 API 流量峰值，使用：
>
> ```prometheus
> sum(rate(gitlab_transaction_duration_seconds_count{controller=~"Grape", action!~".*/internal/.*"}[1m]))
> ```
>
> 然后从监测时段内的图表结果中直观地识别出峰值。

#### 查询绝对峰值

<a id="query-absolute-peaks"></a>

要识别在指定时间段内观察到的最大 RPS：

1. 运行以下查询：

   - API 流量峰值，用于衡量来自自动化、外部工具和 webhook 的峰值 API 请求：

     ```prometheus
     max_over_time(
       sum(rate(gitlab_transaction_duration_seconds_count{controller=~"Grape", action!~".*/internal/.*", action!="POST /api/jobs/request"}[1m]))[7d:1m]
     )
     ```

   - Web 流量峰值，用于衡量用户在浏览器中的峰值 UI 交互：

     ```prometheus
     max_over_time(
       sum(rate(gitlab_transaction_duration_seconds_count{controller!~"Grape|HealthController|MetricsController|Repositories::GitHttpController|GraphqlController"}[1m]))[7d:1m]
     )
     ```

   - Git 拉取和克隆峰值，用于衡量峰值仓库克隆和获取操作：

     ```prometheus
     max_over_time(
       (sum(rate(gitlab_transaction_duration_seconds_count{action="git_upload_pack"}[1m])) or vector(0) +
       sum(rate(gitaly_service_client_requests_total{grpc_method="SSHUploadPack"}[1m])) or vector(0))[7d:1m]
     )
     ```

   - Git 推送峰值，用于衡量峰值代码推送操作：

     ```prometheus
     max_over_time(
       (sum(rate(gitlab_transaction_duration_seconds_count{action="git_receive_pack"}[1m])) or vector(0) +
       sum(rate(gitaly_service_client_requests_total{grpc_method="SSHReceivePack"}[1m])) or vector(0))[7d:1m]
     )
     ```

1. 记录结果。

#### 查询持续峰值

<a id="query-sustained-peaks"></a>

要识别典型的高负载水平，过滤掉罕见的尖峰：

1. 运行以下查询：

   - API 持续峰值：

     ```prometheus
     quantile_over_time(0.95,
       sum(rate(gitlab_transaction_duration_seconds_count{controller=~"Grape", action!~".*/internal/.*", action!="POST /api/jobs/request"}[1m]))[7d:1m]
     )
     ```

   - Web 持续峰值：

     ```prometheus
     quantile_over_time(0.95,
       sum(rate(gitlab_transaction_duration_seconds_count{controller!~"Grape|HealthController|MetricsController|Repositories::GitHttpController|GraphqlController"}[1m]))[7d:1m]
     )
     ```

   - Git 拉取和克隆持续峰值：

     ```prometheus
     quantile_over_time(0.95,
       (sum(rate(gitlab_transaction_duration_seconds_count{action="git_upload_pack"}[1m])) or vector(0) +
       sum(rate(gitaly_service_client_requests_total{grpc_method="SSHUploadPack"}[1m])) or vector(0))[7d:1m]
     )
     ```

   - Git 推送持续峰值：

     ```prometheus
     quantile_over_time(0.95,
      (sum(rate(gitlab_transaction_duration_seconds_count{action="git_receive_pack"}[1m])) or vector(0) +
      sum(rate(gitaly_service_client_requests_total{grpc_method="SSHReceivePack"}[1m])) or vector(0))[7d:1m]
     )
     ```

1. 记录结果。

### 将流量映射到参考架构

<a id="map-traffic-to-reference-architectures"></a>

要将流量映射到参考架构，请使用你之前记录的结果：

1. 查阅[可用的参考架构](_index.md#available-reference-architectures)，查看每种流量类型建议使用哪种参考架构。
1. 填写分析表格。请使用下表作为指引：

   | 流量类型              | 峰值 RPS | 峰值建议 RA             | 持续 RPS | 持续建议 RA             |
   |:----------------------|:---------|:------------------------|:--------------|:---------------------------|
   | API                   | ________ | _____ (最高 ___ RPS)    | _____________ | _____ (最高 ____ RPS)      |
   | Web                   | ________ | _____ (最高 ___ RPS)    | _____________ | _____ (最高 ____ RPS)      |
   | Git 拉取和克隆        | ________ | _____ (最高 ___ RPS)    | _____________ | _____ (最高 ____ RPS)      |
   | Git 推送              | ________ | _____ (最高 ___ RPS)    | _____________ | _____ (最高 ____ RPS)      |

1. 比较 **峰值建议 RA** 列中的所有参考架构，并选择最大的一个。对 **持续建议 RA** 列重复此操作。
1. 记录基线：
   - 建议的最大峰值 RA。
   - 建议的最大持续 RA。

### 选择一个参考架构

<a id="choose-a-reference-architecture"></a>

此时，有两个候选的参考架构规模：

- 一个基于绝对峰值。
- 一个基于持续负载。

要选择一个参考架构：

1. 如果峰值和持续负载建议相同的 RA，则使用该 RA。
1. 如果峰值建议的 RA 大于持续负载建议的 RA。计算差距。峰值 RPS 是否在持续 RA 上限的 10-15% 以内？

一般准则：

- 如果峰值 RPS 超出持续 RA 限制不到 10-15%，则可以考虑使用持续 RA，风险在可接受范围内，因为参考架构有内置的余量。
- 超过 15%，则从基于峰值的 RA 开始，然后进行监控，如果指标支持缩减规模，则进行调整。
  - 示例 1：峰值为 110 RPS，大型 RA 处理能力为“最高 100 RPS” → 超出 10% → 大型就足够了（参考架构有内置余量）
  - 示例 2：峰值为 150 RPS，大型 RA 处理能力为“最高 100 RPS” → 超出 50% → 使用超大型（最高 200 RPS）
  - 示例 3：峰值为 100 RPS（大型/100 RPS），但持续负载为 50 RPS（中型/60 RPS）。原始的 RPS 图显示自动化尖峰导致了峰值，而大部分时间负载低于 50 RPS。用户评估是从保守的大型开始然后缩减，还是从中型开始并[针对特定工作负载进行扩展](#identify-component-adjustments)（风险更高）。

对于低于 40 RPS 且需要高可用性的环境，请查阅[高可用性章节](_index.md#high-availability-ha)，以确定是否需要通过支持的缩减切换到 60 RPS / 3，000 用户的架构。

### 开始之前

<a id="before-you-proceed"></a>

完成本节后，你已经确定了基线参考架构规模。这构成了基础，但后续章节将识别特定的工作负载是否需要超出标准配置的组件调整。

在继续之前，请确保你已记录了本节收集的详细信息。你可以使用以下内容作为指引：

```markdown
参考架构评估摘要：

- 选择的参考架构：_____
- 理由基于 _____ RPS [绝对峰值/持续负载]

| 流量类型              | 峰值 RPS | 持续 RPS (95th) |
|:----------------------|:---------|:---------------------|
| API                   | ________ | ____________________ |
| Web                   | ________ | ____________________ |
| Git 拉取和克隆        | ________ | ____________________ |
| Git 推送              | ________ | ____________________ |

用于工作负载分析的最高 RPS 峰值时间戳：_____
```

## 理解 RPS 组成和工作负载模式

<a id="understanding-rps-composition-and-workload-patterns"></a>

总 RPS 是调整规模的主要指标，但工作负载组成会显著影响组件的资源需求。不同类型的请求以不同的强度对不同的组件造成压力。

### 按请求类型划分的 RPS 分解

<a id="rps-breakdown-by-request-type"></a>

参考架构的 RPS 目标基于生产数据的典型工作负载组成假设：

- **API 请求**（约占总 RPS 的 80%）- 自动化、集成、webhook 和 API 驱动的工具
- **Web 请求**（约占总 RPS 的 10%）- UI 交互、页面导航和用户驱动的操作
- **Git 操作**（约占总 RPS 的 10%）- 仓库克隆和拉取，推送速率较低

**非典型组成** - 环境中某一请求类型的比例显著超出典型比例（即使在目标 RPS 范围内，也可能需要进行组件特定的调整）

### 识别非典型工作负载模式

<a id="identifying-atypical-workload-patterns"></a>

使用[提取峰值流量指标](#extract-peak-traffic-metrics)中的 RPS 提取查询来了解你的工作负载组成。将你的分布与典型模式进行比较：

**API 密集型工作负载**（API > 总 RPS 的 90%）：

- 大量自动化、广泛的集成或 API 驱动的工具
- 主要影响：Rails (Webservice)、PostgreSQL、Gitaly
- 考虑：增加 Webservice/Rails 容量，数据库读取副本

**Web 密集型工作负载**（Web > 总 RPS 的 20%）：

- 庞大的活跃用户群，大量 UI 交互
- 主要影响：Rails (Webservice)、PostgreSQL
- 考虑：增加 Webservice 容量，数据库优化

**Git 密集型工作负载**（Git > 总 RPS 的 15%，或拉取速率明显高于同规模典型水平）：

- 拥有频繁拉取、单体仓库模式或带有仓库克隆的 CI/CD 密集型工作流的庞大团队
- 主要影响：Gitaly，网络带宽
- 考虑：Gitaly 垂直扩展，仓库优化，网络增强型虚拟机

### 评估方法

<a id="assessment-approach"></a>

1. 使用提供的 PromQL 查询提取 RPS 分解
1. 计算每种请求类型占总数的百分比
1. 识别是否有任何类型显著超出典型比例
1. 如果是非典型，请参阅[识别组件调整](#identify-component-adjustments)以获取扩展指导

> [!note]
> 微小的变化（任何类别中 5-10 RPS 的差异）不需要更改架构。根据生产环境的实际组件饱和度指标（CPU、内存、队列深度）进行监控，而不是仅根据 RPS 比较来做决策。组件在 70% 以下的持续利用率通常有足够的容量，无论 RPS 的微小变化如何。

## 识别组件调整

<a id="identify-component-adjustments"></a>

工作负载评估可以识别出需要在基础参考架构之外进行组件调整的特定使用模式。RPS 决定了整体规模，而工作负载模式决定了形态。两个 RPS 相同的环境可能有着截然不同的资源需求。

不同的工作负载会对极狐GitLab 架构的不同部分造成压力：

- 以 CI/CD 为主的环境处理数千个作业，同时保持中等 RPS，这会给 Sidekiq 和 Gitaly 带来压力。
- 具有大量 API 自动化的环境显示高 RPS，但会将负载集中在数据库和 Rails 层。

### 分析峰值负载期间的顶级端点

<a id="analyze-top-endpoints-during-peak-load"></a>

使用前面章节中的峰值时间戳，识别在最大负载期间哪些端点接收了最多流量。

> [!note]
> 如果你的 RPS 指标在非工作时间显示持续的高流量（超过峰值的 50%），这表明存在超出典型模式的大规模自动化。
> 例如，峰值流量在工作时间达到 100 RPS，但在夜间和周末保持 50+ RPS，这表明有显著的自动化工作负载。在[评估组件调整](#determine-component-adjustments)时请考虑这一点。

1. 运行此查询并启用可视化（条形图用于查看随时间变化的分布，或饼图用于查看总体分布）：

   ```prometheus
   topk(20,
     sum by (controller, action) (
       rate(gitlab_transaction_duration_seconds_count{controller!~"HealthController|MetricsController", action!~".*/internal/.*"}[1m])
     )
   )
   ```

1. 查看在绝对 RPS 峰值期间，顶级端点的分布结果。结果可能显示：

   - 没有可见的端点模式。在这种情况下，继续使用之前选择的参考架构。确保有健全的监控措施以衡量任何工作负载变化的影响。
   - 大部分是对非 Git 流量的重度 API 使用。在这种情况下，webhooks 以及议题、群组和项目的 API 调用表明这是一个数据库密集型模式。
   - 大部分是 Git 或 Sidekiq 相关的端点。在这种情况下，合并请求差异、流水线作业、分支、提交、文件操作、CI/CD 作业、安全扫描和导入操作表明这是一个 Sidekiq/Gitaly 密集型模式。

1. 记录发现：

   ```markdown
   已识别的工作负载模式：

   - [ ] 数据库密集型
   - [ ] Sidekiq 或 Gitaly 密集型
   - [ ] 未检测到
   ```

### 确定组件调整

<a id="determine-component-adjustments"></a>

上述指标提供了额外工作负载的初始信号。由于参考架构内置了余量，这些工作负载可能无需调整即可处理。但是，如果存在强烈的信号并且已知有高水平的自动化，请考虑以下调整。

根据之前识别的工作负载模式，不同的组件需要扩展：

| 工作负载类型              | 何时应用                                                                                                                                                                                     | 需要扩展的组件 |
|:--------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------|
| 数据库密集型              | <ul><li>对非 Git 流量的大量 API 使用（webhooks、议题、群组和项目）</li><li>已知的[大规模自动化或集成工作负载](_index.md#additional-workloads)</li></ul>                                      | <ul><li>增加 Rails 资源</li><li>[数据库扩展](#database-scaling)</li></ul> |
| Sidekiq/Gitaly 密集型**   | <ul><li>大量的 Git 操作、CI/CD 作业、安全扫描、导入操作和 Git 服务器钩子</li><li>已知的以 CI/CD 为主的使用模式</li></ul>                                                                    | <ul><li>提高 Sidekiq 规格</li><li>Gitaly 垂直扩展</li><li>[数据库扩展](#database-scaling)</li><li>高级：配置特定的[作业类](../sidekiq/processing_specific_job_classes.md)</li></ul> |

#### 扩展指导

<a id="scaling-guidance"></a>

资源调整因工作负载强度和饱和度指标而异：

1. 从 1.25 倍至 1.5 倍当前资源开始。
1. 根据实施后的监控数据进行优化。

如果你计划部署云原生极狐GitLab，本次评估中识别出的工作负载模式对 Kubernetes 配置有额外的影响：

- 高非工作时间流量。确保最小 Pod 数量足以应对基线负载，而不是允许在空闲时段缩减至零。例如，工作时间为 100 RPS，夜间由于自动化原因稳定在 50 RPS，那么最小 Pod 数量配置需要与基线非工作时间负载相匹配。
- 快速流量尖峰。默认的 HPA 设置可能无法足够快地扩展。在初始部署期间监控 Pod 的扩缩容行为，以防止在这些转换期间出现请求排队。例如，从空闲时段到工作时段，或特定的自动化尖峰，可能会导致从 50 RPS 快速飙升至 200 RPS。

##### 数据库扩展

<a id="database-scaling"></a>

数据库扩展策略取决于工作负载特征，可能需要多种方法：

1. 垂直扩展以解决即时容量限制，这：
   - 对于写入密集型工作负载是必需的，因为副本不会减轻主节点的负载。
   - 能立即增加读取和写入操作的容量。
1. 带有读取副本的[数据库负载均衡](../postgresql/database_load_balancing.md)（推荐），这：
   - 特别有利于读取密集型工作负载（85-95% 读取）。
   - 将读取流量分布到多个节点。
   - 可以与垂直扩展结合添加。
1. 如果写入性能仍然成为瓶颈，继续垂直扩展。

使用此 Prometheus 查询来识别读/写分布：

```prometheus
# 读取操作百分比
(
  (sum(rate(gitlab_transaction_db_count_total[5m])) - sum(rate(gitlab_transaction_db_write_count_total[5m]))) /
  sum(rate(gitlab_transaction_db_count_total[5m]))
) * 100
```

### 开始之前

<a id="before-you-proceed-1"></a>

完成本节后，你已经识别了工作负载模式并确定了任何所需的组件调整。

在继续之前，请记录完整的工作负载评估：

```markdown
已识别的工作负载模式：

- [ ] 数据库密集型
- [ ] Sidekiq 或 Gitaly 密集型
- [ ] 未检测到
- 需要的组件调整：_____
```

在下一节中，你将评估可能需要额外基础设施考虑因素的特殊数据特征。

## 评估特殊的基础设施需求

<a id="assess-special-infrastructure-requirements"></a>

仓库特征和网络使用模式可能会显著影响极狐GitLab 的性能，其影响超出 RPS 指标所能揭示的范围。

大型单体仓库、大量的二进制文件和网络密集型操作需要进行标准规模调整未包含的基础设施调整。

### 大型单体仓库

<a id="large-monorepos"></a>

大型单体仓库（几个 GB 或更大）从根本上改变了 Git 操作的执行方式。克隆一个 10 GB 的仓库所消耗的资源比克隆数百个典型仓库还要多。

这些仓库不仅影响 Gitaly，还会根据工作负载影响 Rails、Sidekiq 和数据库。

剖析过程侧重于识别那些显著超出典型大小的仓库：

- 中型单体仓库：2 GB - 10 GB。需要适度的调整。
- 大型单体仓库：>10 GB。需要进行重大的基础设施变更。

要识别仓库的大小：

1. 前往项目的[使用量配额](../../user/storage_usage_quotas.md#view-storage)。
1. 查看[**仓库**存储类型](../../user/project/repository/repository_size.md)。
1. 计算仓库大于 2 GB 和大于 10 GB 的项目数量。
1. 记录结果：

   ```plaintext
   中型单体仓库数量 (2GB - 10GB)：_____
   大型单体仓库数量 (>10GB)：_____
   ```

#### 针对单体仓库的基础设施调整

<a id="infrastructure-adjustments-for-monorepos"></a>

大型仓库需要垂直扩展和运维调整。这些仓库会影响整个技术栈的性能，从 Git 操作和 CPU 使用率到内存消耗和网络带宽。

| 场景                     | 组件调整 |
|:-------------------------|:----------------------|
| 多个中型单体仓库         | <ul><li>Gitaly：1.5 倍-2 倍规格</li><li>Rails：1.25 倍-1.5 倍规格</li></ul> |
| 大型单体仓库             | <ul><li>Gitaly：2 倍-4 倍规格</li><li>Rails：1.5 倍-2 倍规格</li><li>考虑将单体仓库分片到专用的 Gitaly 节点</li></ul> |

有关单体仓库环境的其他优化策略，包括用于二进制文件的 Git LFS 和浅克隆，请参阅[提升单体仓库性能](../../user/project/repository/monorepos/_index.md)。

### 网络密集型工作负载

<a id="network-heavy-workloads"></a>

网络饱和会导致难以诊断的独特问题。与影响特定操作的 CPU 或内存瓶颈不同，网络饱和可能导致所有极狐GitLab 功能出现看似随机的超时。

常见的网络负载来源：

- 重度容器镜像仓库使用（大镜像，频繁拉取）。
- LFS 操作（二进制文件，媒体资产）。
- 大型 CI/CD 产物（构建输出，测试结果）。
- 单体仓库克隆（尤其是在 CI/CD 流水线中）。

#### 衡量网络使用情况

<a id="measure-network-usage"></a>

计算峰值和基线网络消耗，以识别潜在的瓶颈。
对两者都进行评估，以区分偶发性尖峰（由突发容量处理）和持续高流量（需要网络增强型虚拟机）。

1. 运行以下查询：

   ```prometheus
   # 出站流量 (Gbps) - 前 10 个节点
   topk(10, sum by (instance) (rate(node_network_transmit_bytes_total{device!="lo"}[5m]) * 8 / 1000000000))


   # 入站流量 (Gbps) - 前 10 个节点
   topk(10, sum by (instance) (rate(node_network_receive_bytes_total{device!="lo"}[5m]) * 8 / 1000000000))

   ```

1. 记录在你的监控周期内观察到的峰值尖峰和典型基线：

   ```plaintext
   峰值出站流量：_____ Gbps（基线：_____ Gbps）
   峰值入站流量：_____ Gbps（基线：_____ Gbps）
   ```

#### 网络容量需求

<a id="network-capacity-requirements"></a>

以下阈值仅为近似指导原则。实际的网络带宽保证因云服务提供商和虚拟机类型而异。务必验证你所使用的特定实例类型的网络规格（基线和突发限制），以确保它们与你的工作负载模式保持一致。

根据出站和入站流量测量结果：
| 网络负载 | 阈值 | 为什么使用此阈值 | 需要采取的行动 |
|:-------------|:----------|:-------------------------------------------------------------------|:----------------|
| 标准 | <1 Gbps | 在大多数标准实例的基线带宽范围内 | 标准实例即可满足 |
| 中等 | 1-3 Gbps | 可能超过 AWS 基线，但在 GCP/Azure 标准实例范围内 | <ul><li>AWS：监控是否有节流，可能需要网络增强型</li><li>GCP/Azure：标准实例通常足够</li></ul> |
| 高 | 3-10 Gbps | 超过 AWS 基线。接近某些标准实例的上限 | <ul><li>AWS：需要网络增强型虚拟机</li><li>GCP/Azure：验证实例带宽规格</li></ul> |
| 非常高 | >10 Gbps | 超出大多数标准实例的能力 | <ul><li>所有提供商都需要网络增强型虚拟机</li><li>对于大型产物，禁用[对象代理下载](../object_storage.md#proxy-download)</li></ul> |

<a id="before-you-proceed"></a>

### 在继续之前

在继续之前，请记录完整的数据概况评估：

```txt
数据概况总结：
- 中型单体仓库（2GB-10GB）：_____
- 大型单体仓库（>10GB）：_____
- 需要 Gitaly 调整：_____
- 需要 Rails 调整：_____
- 峰值出站流量：_____ Gbps（持续基线：_____ Gbps）
- 峰值入站流量：_____ Gbps（持续基线：_____ Gbps）
- 网络基础设施变更：_____
```

<a id="analyze-current-environment-and-validate-recommendations"></a>

## 分析当前环境并验证建议

了解现有环境可以为建议提供关键背景：

- 如果当前环境在没有性能问题的情况下处理工作负载，它可以作为验证规模估算的有价值参考。
- 相反，存在性能问题的环境需要进行仔细分析，以避免持续出现规模不足。

<a id="document-the-current-environment"></a>

### 记录当前环境

收集全面的环境数据以确定当前状态：

- 架构详情：
  - 类型：高可用（HA）或非高可用（非 HA）。
  - 部署方式：Linux 软件包或云原生极狐GitLab。
- 组件规格：
  - 每个组件的节点数量和规格。
  - 自定义配置或偏差。

<a id="identify-the-nearest-reference-architecture"></a>

### 确定最接近的参考架构

1. 将当前环境与[可用的参考架构](_index.md)进行比较。考虑以下方面：

   - 每个组件的总计算资源。
   - 节点分布和架构模式（HA 与非 HA）。
   - 相对于参考架构规模的组件规格。

1. 记录您的发现：

   ```plaintext
   最接近的参考架构：_____
   自定义配置或偏差：
   - _____
   - _____
   ```

<a id="compare-current-environment-to-recommended-architecture"></a>

### 比较当前环境与建议的架构

将当前环境与您从前几个部分得出的建议参考架构进行比较。如果当前环境：

- 没有性能问题且当前资源 < 建议的 RA：
  - 建议比较保守，并提供了未来余量。
  - 按建议的 RA 进行。
  - 实施后监控以寻找潜在的优化机会。
- 没有性能问题且当前资源 ≈ 建议的 RA：
  - 强有力地验证了您的规模评估。
  - 当前环境确认建议的规模是合适的。
- 没有性能问题且当前资源 > 建议的 RA：
  - 当前环境可能过度配置，或存在需要分析的额外资源有效原因。检查 Rails、Gitaly、数据库和 Sidekiq 上的 CPU/内存[资源利用率](../monitoring/prometheus/_index.md#sample-prometheus-queries)。

    低利用率（<40%）表明过度配置。高利用率可能表明存在 RPS 分析未捕获的特定工作负载需求。
  - 审查建议是否需要针对未发现的要求进行调整。

如果当前环境存在性能问题：

- 仅将当前规格作为最低基线。前几部分的建议应超过当前规格。
- 如果建议远低于当前规模，请调查：
  - 评估中未捕获的工作负载模式。
  - 需要针对性扩展的组件特定瓶颈。

<a id="before-you-proceed"></a>

### 在继续之前

完成本节后，您已分析当前环境并与建议进行了比较。

在继续之前，请记录完整的环境比较：

```plaintext
当前环境分析：
- 当前 RA（最接近）：_____
- 建议的 RA（来自 RPS 和工作负载分析）：_____
- 资源比较：[ ] 当前 < 建议 [ ] 当前 ≈ 建议 [ ] 当前 > 建议
- 性能状态：[ ] 无问题 [ ] 有问题
- 需要调整：_____
- 备注：_____
```

在下一节中，您将评估增长预测，以确保规模在一段时间内保持适当。

## 规划未来容量

基础设施变更需要大量的前期时间进行采购、迁移和测试。增长估算可确保建议的架构在整个实施期间及以后仍然可行。

历史趋势与业务计划相结合，可提供最准确的增长预测。

### 分析历史增长模式

过去的增长模式比业务预测更能帮助预测未来轨迹：

1. 使用[确定基线规模](#determine-your-baseline-size)中的信息，将当前 RPS 与 6-12 个月前进行比较。
1. 识别增长加速或减速趋势。

### 纳入业务规划因素

影响基础设施需求的预期业务变化：

- 团队扩展或整合。
- 新项目开发。
- 现有项目的开发活动增加。

评估这些因素（或其他组织变化）是否会影响环境负载，并需要基础设施调整。记录相关变化及其预期时间表。

#### 确定增长缓冲策略

根据历史趋势和业务预测，选择合适的增长容纳策略：

- 稳定或最小增长：继续监控。参考架构包含内置余量。
- 中等增长：规划能够处理预计未来 RPS 的 RA 规模。
- 预期显著增长：考虑按照预计的未来 RPS 而非当前 RPS 来确定规模。

<a id="before-you-proceed"></a>

### 在继续之前

完成本节后，增长预测已纳入规模决策。

记录完整的增长分析：

```plaintext
增长评估总结：
- 历史 RPS 比较：_____
- 业务增长因素：_____
- 增长类别：[ ] 稳定/最小 [ ] 中等 [ ] 显著
- 策略：[ ] 当前 RA 足够 [ ] 按预计增长确定规模
```

在下一节中，您将所有发现汇总为最终的架构建议。

## 汇总发现

汇总前面所有部分的发现，以确定最佳的参考架构和所需的调整。

### 确定最终架构

收集每个部分的关键输出以形成规模决策：

1. 从基于[RPS 分析](#determine-your-baseline-size)确定的参考架构开始。
1. 根据[工作负载模式](#identify-component-adjustments)和[数据特征](#assess-special-infrastructure-requirements)应用任何所需的组件调整。如果未确定任何模式或标准配置足够，请跳过此步骤。
1. 根据[当前状态](#analyze-current-environment-and-validate-recommendations)进行验证。如果当前环境表现良好但超出建议，请记录原因。如果存在性能问题，请确保建议超过当前规格。
1. 在[规划未来容量](#plan-for-future-capacity)中考虑增长。确定当前 RA 是否足够，或是否需要为预计增长确定规模。

### 记录最终建议

根据全面评估，记录完整的架构建议：

```plaintext
最终架构建议
==================================

- 所选 RA：[规模] 基于 [绝对/持续] 峰值 RPS [值]
- 需要组件调整：
  - [ ] 无需调整 - 标准 RA 配置足够
  - [ ] 需要调整：
      - Rails：_____
      - Sidekiq：_____
      - 数据库：_____
      - Gitaly：_____
      - 网络考虑：□ 标准实例 □ 网络优化实例
- 所选 RA 与现有环境一致：[是/否/不适用]
- 增长容纳：[当前 RA 足够 / 为增长扩容]

评估总结：
├── RPS 分析
│   ├── 绝对峰值 RPS：_____ → 基线 RA：_____
│   └── 持续峰值 RPS：_____ → 持续 RA：_____
├── 工作负载类型
│   └── 类型：[ ] 数据库密集型 [ ] Sidekiq 密集型 [ ] 无
├── 数据概况
│   ├── 大型仓库（>2GB）：_____ | 单体仓库（>10GB）：_____
│   └── 网络：峰值 _____ Gbps | 基线 _____ Gbps
├── 当前状态
│   ├── 最接近的 RA：_____
|   └── 差异和自定义：_____
└── 增长
    ├── 增长预测：_____
    └── 增长缓冲策略：_____
```

完成所有部分后，规模评估即告完成。最终建议包括：

- 基础参考架构规模。
- 特定于组件的调整。
- 增长容纳策略。

持续的监控对于验证假设和随着工作负载模式演变而调整基础设施至关重要。