---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 评估和规划极狐GitLab 部署规模的指南。
title: 评估和规划部署规模
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在安装之前，或在评估现有环境的规模是否合适时，评估极狐GitLab 环境的工作负载并确定适当的部署要求。

<a id="workload-characterization"></a>

## 工作负载特征描述

即使在用户数量或请求量相近的情况下，极狐GitLab 环境的基础设施需求也可能存在显著差异。Git 操作、CI/CD 活动、API 使用和自动化的组合决定了哪些组件会承受压力，以及它们需要如何扩展。

工作负载特征描述不是将环境映射到固定的规模层级，而是描述环境的特征画像。您在测量环境后得出的特征描述，将指导哪些组件级要求和扩展考量适用。

| 特征描述 | 典型画像 |
|:-----------------|:----------------|
| 小型 | Git 活动较少，自动化程度极低，CI/CD 并发度低。 |
| 中型 | Git 活动适中，CI/CD 使用标准，有一定自动化。 |
| 大型 | CI/CD 繁重，存在活跃的单体仓库，API 自动化程度高。 |
| 超大型 | 工作负载密集，集成广泛，所有组件并发度都很高。 |

这些特征描述是描述性的，而非规定性的。它们是您通过测量环境得出的结论，而不是预先选择的类别。许多环境并不能清晰地归入单一特征描述。一个 Web 和 API 活动较少但 Git 操作繁重的环境，与一个情况相反的环境，其定位是不同的。

对于小型和中型环境，本页面的指导旨在自给自足。对于大型和超大型环境，其运维复杂性通常需要与[专业服务](https://about.gitlab.com/professional-services/)合作，或考虑使用 JihuLab.com 作为替代方案，从而完全免除运维负担。

<a id="workload-considerations"></a>

## 工作负载考量

某些工作负载模式需要的不仅仅是本指南所涵盖的基于 RPS 的标准方法。在您提取 RPS 指标后，稍后将介绍其中两种情况：[大型单体仓库和其他特定于基础设施的因素](#assess-special-infrastructure-requirements)，以及[非典型工作负载模式](#understanding-rps-composition-and-workload-patterns)，例如繁重的自动化、CI/CD 使用或安全扫描。

极狐GitLab Duo Agent Platform 除了标准工作负载规模评估之外，还引入了自身的基础设施考量。在为将使用它的环境确定规模之前，请参阅[极狐GitLab Duo Agent Platform 的扩展](../administration/reference_architectures/_index.md#scaling-for-gitlab-duo-agent-platform)。

<a id="autoscaling"></a>

### 自动扩缩

Rails (Puma) 和 Sidekiq 是无状态的，支持自动扩缩组。请按平均持续负载为这些组件确定规模，并让自动扩缩处理峰值。

Gitaly 是有状态的，不支持自动扩缩。请使用下面的指导，按峰值负载为 Gitaly 节点确定规模。

如果自动扩缩是一项要求，通常更倾向于[云原生部署](../administration/reference_architectures/_index.md#cloud-native)，而不是基于虚拟机的自动扩缩组。必须在单个节点上运行的组件（例如数据库迁移和 [Mailroom](../administration/incoming_email.md)）由 Kubernetes 处理比由虚拟机自动扩缩组处理更可靠，因此在选择基于虚拟机的自动扩缩之前，请考虑这一限制。

<a id="before-you-begin"></a>

## 开始之前

这些说明使用 Prometheus 指标来准确评估您的环境。如果您的环境比较简单，[参考架构](../administration/reference_architectures/_index.md)可能无需这种级别的分析即可提供足够的指导。

> [!note]
> 需要专家指导？正确确定架构规模对于实现最佳性能至关重要。GitLab 的[专业服务](https://about.gitlab.com/professional-services/)团队可以评估您的具体架构，并针对性能、稳定性和可用性优化提供量身定制的建议。

要遵循本文档，您必须在极狐GitLab 实例上部署 Prometheus 监控。Prometheus 提供正确评估规模所需的准确指标。

如果您尚未配置 Prometheus：

1. 使用 [Prometheus](../administration/monitoring/prometheus/_index.md) 配置监控。参考架构文档提供了针对每种环境规模的 Prometheus 配置详情。对于云原生极狐GitLab，您可以使用 [`kube-prometheus-stack`](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) Helm Chart 来配置指标抓取。
1. 收集 7-14 天的数据，以获取有意义的数据模式。
1. 阅读本文档的其余内容。

如果您无法配置 Prometheus 监控：

- 将[当前环境](#analyze-current-environment-and-validate-recommendations)规格与最接近的参考架构进行比较，以估算规模。
- 使用 [GitLab RPS Analyzer](https://gitlab.com/gitlab-org/professional-services-automation/tools/utilities/gitlab-rps-analyzer#gitlab-rps-analyzer) 通过 GitLabSOS 或 KubeSOS 日志评估参考架构规模。但请注意，这不如指标可靠。

如果从其他平台迁移，在没有现有极狐GitLab 指标的情况下，无法应用以下 PromQL 查询。不过，总体评估方法仍然有效：

1. 根据预期工作负载估算最接近的参考架构。
1. 确定预期的[额外工作负载](../administration/reference_architectures/_index.md#additional-workloads)。
1. 评估大型代码仓库的数量。
1. 纳入增长预测。
1. 选择具有[适当缓冲](../administration/reference_architectures/_index.md#if-in-doubt-start-large-monitor-and-then-scale-down)的参考架构。

<a id="running-promql-queries"></a>

### 运行 PromQL 查询

运行 PromQL 查询取决于您使用的监控解决方案。如 [Prometheus 监控文档](../administration/monitoring/prometheus/_index.md#how-prometheus-works)所述，可以通过直接连接到 Prometheus 或使用 Grafana 等仪表板工具来访问监控数据。

<a id="determine-your-baseline-size"></a>

## 确定您的基准规模

每秒请求数 (RPS) 是确定极狐GitLab 基础设施规模的主要指标。不同的流量类型（API、Web、Git 操作）会给不同的组件带来压力，因此需要分别分析每种类型，以找出真实的容量需求。

<a id="extract-peak-traffic-metrics"></a>

### 提取峰值流量指标

运行这些查询以了解您的最大负载。这些查询会向您展示：

- 绝对峰值，即您见过的最高尖峰。绝对峰值展示最坏情况。
- 持续峰值，即第 95 百分位数，被视为您典型的“繁忙”水平。持续峰值揭示典型的高负载时段。

如果绝对峰值是罕见的异常情况，那么按持续负载确定规模可能是合适的。

根据保留期调整查询中的时间范围（如果有更长的历史记录，将 `[7d]` 改为 `[30d]`）。

> [!note]
> 对于高活动量的环境，`max_over_time` 或 `quantile_over_time` 查询可能会超时。
> 如果发生这种情况，请移除外层聚合函数，并用图表可视化内层查询。
> 例如，对于 API 流量峰值，使用：
>
> ```prometheus
> sum(rate(gitlab_transaction_duration_seconds_count{controller=~"Grape", action!~".*/internal/.*"}[1m]))
> ```
>
> 然后从监控期间绘制的图表结果中目视识别峰值。

<a id="query-absolute-peaks"></a>

#### 查询绝对峰值

要确定指定时间段内观测到的最大 RPS：

1. 运行以下查询：

   - API 流量峰值，用于衡量来自自动化、外部工具和 Webhook 的 API 请求峰值：

     ```prometheus
     max_over_time(
       sum(rate(gitlab_transaction_duration_seconds_count{controller=~"Grape", action!~".*/internal/.*", action!="POST /api/jobs/request"}[1m]))[7d:1m]
     )
     ```

   - Web 流量峰值，用于衡量浏览器中用户的 UI 交互峰值：

     ```prometheus
     max_over_time(
       sum(rate(gitlab_transaction_duration_seconds_count{controller!~"Grape|HealthController|MetricsController|Repositories::GitHttpController|GraphqlController"}[1m]))[7d:1m]
     )
     ```

   - Git 拉取和克隆峰值，用于衡量代码仓库克隆和拉取操作的峰值：

     ```prometheus
     max_over_time(
       (sum(rate(gitlab_transaction_duration_seconds_count{action="git_upload_pack"}[1m])) or vector(0) +
       sum(rate(gitaly_service_client_requests_total{grpc_method="SSHUploadPack"}[1m])) or vector(0))[7d:1m]
     )
     ```

   - Git 推送峰值，用于衡量代码推送操作的峰值：

     ```prometheus
     max_over_time(
       (sum(rate(gitlab_transaction_duration_seconds_count{action="git_receive_pack"}[1m])) or vector(0) +
       sum(rate(gitaly_service_client_requests_total{grpc_method="SSHReceivePack"}[1m])) or vector(0))[7d:1m]
     )
     ```

1. 记录结果。

<a id="query-sustained-peaks"></a>

#### 查询持续峰值

要确定典型的高负载水平，同时过滤掉罕见的尖峰：

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

<a id="map-traffic-to-reference-architectures"></a>

### 将流量映射到参考架构

如何将流量映射到参考架构取决于您的部署路径。

Linux 软件包 (Omnibus) 或云原生混合：

1. 查阅[可用的参考架构](../administration/reference_architectures/_index.md#available-reference-architectures)，了解每种流量类型建议使用哪种参考架构。
1. 填写分析表。使用下表作为指南：

   | 流量类型       | 峰值 RPS | 峰值建议 RA     | 持续 RPS | 持续建议 RA |
   |:-------------------|:---------|:----------------------|:--------------|:-----------------------|
   | API                | ________ | _____ (最高 ___ RPS) | _____________ | _____ (最高 ____ RPS) |
   | Web                | ________ | _____ (最高 ___ RPS) | _____________ | _____ (最高 ____ RPS) |
   | Git 拉取和克隆     | ________ | _____ (最高 ___ RPS) | _____________ | _____ (最高 ____ RPS) |
   | Git 推送           | ________ | _____ (最高 ___ RPS) | _____________ | _____ (最高 ____ RPS) |

1. 比较**峰值建议 RA** 列中的所有参考架构，并选择最大的规模。对**持续建议 RA** 列重复此操作。
1. 记录基准：
   - 建议的最大峰值 RA。
   - 建议的最大持续 RA。

云原生：

云原生架构按单一的整体 RPS 区间确定规模，而不是按每种流量类型的目标确定规模，因为 API 流量通常占负载的绝大部分（请参阅[按请求类型划分的 RPS](#rps-breakdown-by-request-type)）。

1. 将您的峰值和持续整体 RPS 与可用规模进行比较：

   | 特征描述 | 云原生规模                                  | 目标 RPS |
   |:------------------|:----------------------------------------------------|:-----------|
   | 小型             | [小型 (S)](../administration/reference_architectures/cloud_native.md#small-s)               | ≤100 RPS   |
   | 中型            | [中型 (M)](../administration/reference_architectures/cloud_native.md#medium-m)             | ≤200 RPS   |
   | 大型             | [大型 (L)](../administration/reference_architectures/cloud_native.md#large-l)               | ≤500 RPS   |
   | 超大型       | [超大型 (XL)](../administration/reference_architectures/cloud_native.md#extra-large-xl) | ≤1000 RPS  |

1. 记录基准：
   - 建议的峰值规模。
   - 建议的持续规模。

<a id="choose-a-reference-architecture"></a>

### 选择参考架构

此时，有两个候选规模：一个基于绝对峰值，一个基于持续负载。

选择规模时：

1. 如果峰值和持续建议的规模相同，则使用该规模。
1. 如果峰值建议的规模大于持续建议的规模，请计算差距。峰值 RPS 是否在持续规模上限的 10-15% 以内？

一般指导原则：

- 如果峰值 RPS 超出持续规模上限不到 10-15%，则可以考虑持续规模，风险可接受，因为参考架构具有内置余量。
- 如果超出 15%，则从基于峰值的规模开始，然后进行监控，如果指标支持缩减规模，则进行调整。

Linux 软件包 / 云原生混合示例：

- 峰值为 110 RPS，对应 5,000 用户架构（最高 100 RPS）→ 超出 10% → 5,000 用户架构应该足够。
- 峰值为 150 RPS，对应 5,000 用户架构（最高 100 RPS）→ 超出 50% → 使用 10,000 用户架构（最高 200 RPS）。
- 峰值为 100 RPS（5,000 用户架构），但持续为 50 RPS（3,000 用户架构，最高 60 RPS）。原始 RPS 图表显示自动化尖峰导致峰值，而大多数时间负载低于 50 RPS。评估是保守地从 5,000 用户架构开始然后缩减规模，还是从 3,000 用户架构开始并采用[特定于工作负载的扩展](#identify-component-adjustments)（风险更高）。

云原生示例：

- 峰值为 120 RPS（中型），但持续为 80 RPS（小型）。评估是保守地从中型开始然后缩减规模，还是从采用[特定于工作负载的扩展](#identify-component-adjustments)的小型开始（风险更高）。

对于低于 40 RPS 且要求高可用性 (HA) 的环境，请查阅[高可用性部分](../administration/reference_architectures/_index.md#high-availability-ha)，以确定是否需要切换到 60 RPS / 3,000 用户架构并采用受支持的缩减。

<a id="before-you-proceed"></a>

### 继续之前

完成本节后，您已经确定了基准参考架构规模。这构成了基础，但以下各节将确定特定工作负载是否需要超出标准配置的组件调整。

在继续之前，请确保您已记录本节中收集的详细信息。您可以使用以下内容作为指南：

```markdown
Reference architecture assessment summary:

- Selected reference architecture: _____
- Justification based on _____ RPS [absolute/sustained]

| Traffic Type       | Peak RPS | Sustained RPS (95th) |
|:-------------------|:---------|:---------------------|
| API                | ________ | ____________________ |
| Web                | ________ | ____________________ |
| Git pull and clone | ________ | ____________________ |
| Git push           | ________ | ____________________ |

Highest RPS Peak timestamp for workload analysis: _____
```

<a id="understanding-rps-composition-and-workload-patterns"></a>

## 了解 RPS 构成和工作负载模式

总 RPS 是主要的规模评估指标，但工作负载构成会显著影响组件资源需求。不同的请求类型会以不同的强度给不同的组件带来压力。

<a id="rps-breakdown-by-request-type"></a>

### 按请求类型划分的 RPS

参考架构 RPS 目标假设基于生产数据的典型工作负载构成：

- **API 请求**（约占总 RPS 的 80%）- 自动化、集成、Webhook 和 API 驱动的工具
- **Web 请求**（约占总 RPS 的 10%）- UI 交互、页面导航和用户驱动的操作
- **Git 操作**（约占总 RPS 的 10%）- 代码仓库克隆和拉取，推送率较低

**非典型构成** - 某一种请求类型显著超出典型比例的环境（即使在目标 RPS 范围内，也可能需要特定于组件的调整）

<a id="identifying-atypical-workload-patterns"></a>

### 识别非典型工作负载模式

使用[提取峰值流量指标](#extract-peak-traffic-metrics)中的 RPS 提取查询来了解您的工作负载构成。将您的分布与典型模式进行比较：

**API 密集型工作负载**（API 占总 RPS 的 90% 以上）：

- 繁重的自动化、广泛的集成或 API 驱动的工具
- 主要影响：Rails (Webservice)、PostgreSQL、Gitaly
- 考虑：增加 Webservice/Rails 容量、数据库只读副本

**Web 密集型工作负载**（Web 占总 RPS 的 20% 以上）：

- 拥有大量活跃用户且 UI 交互频繁
- 主要影响：Rails (Webservice)、PostgreSQL
- 考虑：增加 Webservice 容量、数据库优化

**Git 密集型工作负载**（Git 占总 RPS 的 15% 以上，或拉取率明显高于您规模的典型值）：

- 拥有大型团队且拉取频繁、采用单体仓库模式，或包含代码仓库克隆的 CI/CD 密集型工作流
- 主要影响：Gitaly、网络带宽
- 考虑：Gitaly 垂直扩展、代码仓库优化、网络增强型虚拟机

<a id="assessment-approach"></a>

### 评估方法

1. 使用提供的 PromQL 查询提取 RPS 构成
1. 计算每种请求类型占总量的百分比
1. 确定是否有任何类型显著超出典型比例
1. 如果是非典型情况，请参阅[识别组件调整](#identify-component-adjustments)了解扩展指导

> [!note]
> 小幅波动（任何类别中 5-10 RPS 的差异）不需要更改架构。请监控生产环境中实际的组件饱和度指标（CPU、内存、队列深度），而不是仅根据 RPS 比较做出决策。持续利用率低于 70% 的组件通常具有足够的容量，无论 RPS 有怎样的微小波动。

<a id="identify-component-adjustments"></a>

## 识别组件调整

工作负载评估会识别出需要超出基础参考架构进行组件调整的特定使用模式。RPS 决定整体规模，而工作负载模式决定形态。两个 RPS 相同的环境可能有截然不同的资源需求。

不同的工作负载会给极狐GitLab 架构的不同部分带来压力：

- CI/CD 密集型环境在处理数千个作业的同时维持中等 RPS，会给 Sidekiq 和 Gitaly 带来压力。
- 具有广泛 API 自动化的环境显示高 RPS，但将负载集中在数据库和 Rails 层。

<a id="analyze-top-endpoints-during-peak-load"></a>

### 分析峰值负载期间的热门端点

使用前面部分的峰值时间戳，确定在最大负载期间哪些端点接收了最多的流量。

> [!note]
> 如果您的 RPS 指标显示非工作时段流量持续偏高（超过峰值的 50%），这表明存在超出典型模式的繁重自动化。例如，峰值流量在工作时间达到 100 RPS，但在夜间和周末仍保持 50+ RPS，这表明存在大量自动化工作负载。在[评估组件调整](#determine-component-adjustments)时请考虑这一点。

1. 启用可视化运行此查询（随时间分布的条形图，或一般分布的饼图）：

   ```prometheus
   topk(20,
     sum by (controller, action) (
       rate(gitlab_transaction_duration_seconds_count{controller!~"HealthController|MetricsController", action!~".*/internal/.*"}[1m])
     )
   )
   ```

1. 查看绝对 RPS 峰值期间热门端点分布的结果。结果可能有：

   - 没有可见的端点模式。在这种情况下，继续使用之前选择的参考架构。确保部署稳健的监控，以衡量任何工作负载变化的影响。
   - 大部分是用于非 Git 流量的繁重 API 使用。在这种情况下，Webhook 以及议题、群组和项目 API 调用表明存在数据库密集型模式。
   - 大部分是 Git 或 Sidekiq 相关端点。在这种情况下，合并请求差异、流水线作业、分支、提交、文件操作、CI/CD 作业、安全扫描和导入操作表明存在 Sidekiq/Gitaly 密集型模式。

1. 记录发现：

   ```markdown
   Workload pattern identified:

   - [ ] Database-intensive
   - [ ] Sidekiq- or Gitaly-intensive
   - [ ] None detected
   ```

<a id="determine-component-adjustments"></a>

### 确定组件调整

上述指标提供了额外工作负载的初步信号。由于参考架构具有内置余量，这些工作负载可能无需调整即可处理。但是，如果存在强烈的指标且已知自动化程度很高，请考虑以下调整。

根据之前识别的工作负载模式，不同的组件需要扩展：

| 工作负载类型              | 何时应用                                                                                                                                                                                | 需要扩展的组件 |
|:---------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------|
| 数据库密集型         | <ul><li>用于非 Git 流量的繁重 API 使用（Webhook、议题、群组和项目）</li><li>已知的[大量自动化或集成工作负载](../administration/reference_architectures/_index.md#additional-workloads)</li></ul> | <ul><li>增加 Rails 资源</li><li>[数据库扩展](#database-scaling)</li></ul> |
| Sidekiq/Gitaly 密集型** | <ul><li>繁重的 Git 操作、CI/CD 作业、安全扫描、导入操作和 Git 服务器钩子</li><li>已知的 CI/CD 密集型使用模式</li></ul>                                      | <ul><li>增加 Sidekiq 规格</li><li>Gitaly 垂直扩展</li><li>[数据库扩展](#database-scaling)</li><li>高级：配置特定的[作业类](../administration/sidekiq/processing_specific_job_classes.md)</li></ul> |

<a id="scaling-guidance"></a>

#### 扩展指导

资源调整因工作负载强度和饱和度指标而异：

1. 从当前资源的 1.25 倍至 1.5 倍开始。
1. 实施后根据监控数据进一步调整。

如果您计划部署云原生极狐GitLab，本评估中识别的工作负载模式对 Kubernetes 配置还有额外影响：

- 非工作时段流量高。确保最小 Pod 数量足以应对基准负载，而不是在空闲时段允许缩减到零。例如，工作时间 100 RPS 且夜间因自动化持续保持 50 RPS 时，最小 Pod 数量配置需要与基准非工作时段负载保持一致。
- 流量快速激增。默认 HPA 设置可能扩展速度不够快。在初始推出期间监控 Pod 扩展行为，以防止在这些过渡期间出现请求排队。例如，从空闲到工作时段或特定自动化尖峰导致从 50 RPS 快速激增到 200 RPS。

<a id="database-scaling"></a>

##### 数据库扩展

数据库扩展策略取决于工作负载特征，可能需要多种方法：

1. 垂直扩展以解决即时的容量限制，它：
   - 对于写入密集型工作负载是必需的，因为副本不会减少主库负载。
   - 为读和写操作提供即时的容量增加。
1. [数据库负载均衡](../administration/postgresql/database_load_balancing.md)（推荐）配合只读副本，它：
   - 对读取密集型工作负载（85-95% 为读取）尤其有益。
   - 将读取流量分布到多个节点。
   - 可以与垂直扩展结合使用。
1. 如果写入性能仍然是瓶颈，则继续垂直扩展。

使用此 Prometheus 查询来识别读/写分布：

```prometheus
# Percentage of READ operations
(
  (sum(rate(gitlab_transaction_db_count_total[5m])) - sum(rate(gitlab_transaction_db_write_count_total[5m]))) /
  sum(rate(gitlab_transaction_db_count_total[5m]))
) * 100
```

<a id="before-you-proceed-1"></a>

### 继续之前

完成本节后，您已经识别了工作负载模式并确定了任何所需的组件调整。

在继续之前，记录完整的工作负载评估：

```markdown
Workload pattern identified:

- [ ] Database-intensive
- [ ] Sidekiq- or Gitaly-intensive
- [ ] None detected
- Component adjustments needed: _____
```

在下一节中，您将评估可能需要额外基础设施考量的特殊数据特征。

<a id="assess-special-infrastructure-requirements"></a>

## 评估特殊基础设施要求

代码仓库特征和网络使用模式可能会显著影响极狐GitLab 性能，其影响超出 RPS 指标所揭示的范围。

大型单体仓库、大量二进制文件和网络密集型操作需要标准规模评估未考虑的基础设施调整。

<a id="large-monorepos"></a>

### 大型单体仓库

大型单体仓库（数 GB 或更大）会从根本上改变 Git 操作的执行方式。克隆一个 10 GB 的代码仓库所消耗的资源，比克隆数百个典型代码仓库还要多。

这些代码仓库不仅影响 Gitaly，还根据工作负载影响 Rails、Sidekiq 和数据库。

分析过程侧重于识别显著超出典型大小的代码仓库：

- 中型单体仓库：2 GB - 10 GB。这些需要适度的调整。
- 大型单体仓库：>10 GB。这些需要重大的基础设施变更。

要识别代码仓库的大小：

1. 转到项目的[使用配额](../user/storage_usage_quotas.md#view-storage)。
1. 查看[**代码仓库**存储类型](../user/project/repository/repository_size.md)。
1. 计算代码仓库大于 2 GB 和大于 10 GB 的项目数量。
1. 记录结果：

   ```plaintext
   Number of medium monorepos (2GB - 10GB): _____
   Number of large monorepos (>10GB): _____
   ```

<a id="infrastructure-adjustments-for-monorepos"></a>

#### 单体仓库的基础设施调整

大型代码仓库既需要垂直扩展，也需要运维调整。这些代码仓库会影响整个技术栈的性能，从 Git 操作和 CPU 使用到内存消耗和网络带宽。

| 场景                 | 组件调整 |
|:-------------------------|:----------------------|
| 多个中型单体仓库 | <ul><li>Gitaly：1.5 倍至 2 倍规格</li><li>Rails：1.25 倍至 1.5 倍规格</li></ul> |
| 大型单体仓库          | <ul><li>Gitaly：2 倍至 4 倍规格</li><li>Rails：1.5 倍至 2 倍规格</li><li>考虑将单体仓库分片到专用 Gitaly 节点</li></ul> |

单体仓库环境的其他优化策略记录在[改善单体仓库性能](../user/project/repository/monorepos/_index.md)中，包括用于二进制文件的 Git LFS 和浅克隆。

<a id="network-heavy-workloads"></a>

### 网络密集型工作负载

网络饱和会导致一些独特的问题，这些问题通常难以诊断。与影响特定操作的 CPU 或内存瓶颈不同，网络饱和可能导致所有极狐GitLab 功能出现看似随机的超时。

常见的网络负载来源：

- 大量容器镜像仓库使用（大型镜像、频繁拉取）。
- LFS 操作（二进制文件、媒体资源）。
- 大型 CI/CD 产物（构建输出、测试结果）。
- 单体仓库克隆（尤其是在 CI/CD 流水线中）。

<a id="measure-network-usage"></a>

#### 衡量网络使用情况

计算峰值和基准网络消耗，以识别潜在的瓶颈。评估两者，以区分偶发尖峰（由突发容量处理）和持续高流量（需要网络增强型虚拟机）。

1. 运行以下查询：

   ```prometheus
   # Outbound traffic (Gbps) - top 10 nodes
   topk(10, sum by (instance) (rate(node_network_transmit_bytes_total{device!="lo"}[5m]) * 8 / 1000000000))


   # Inbound traffic (Gbps) - top 10 nodes
   topk(10, sum by (instance) (rate(node_network_receive_bytes_total{device!="lo"}[5m]) * 8 / 1000000000))

   ```

1. 记录监控期间观测到的峰值尖峰和典型基准：

   ```plaintext
   Peak outbound traffic: _____ Gbps (baseline: _____ Gbps)
   Peak inbound traffic: _____ Gbps (baseline: _____ Gbps)
   ```

<a id="network-capacity-requirements"></a>

#### 网络容量要求

以下阈值仅为近似指导。实际网络带宽保证因云提供商和虚拟机类型而异。请始终核实您特定实例类型的网络规格（基准和突发限制），以确保它们与您的工作负载模式相符。

根据出站和入站流量测量：

| 网络负载 | 阈值 | 为何采用此阈值                                                 | 所需操作 |
|:-------------|:----------|:-------------------------------------------------------------------|:----------------|
| 标准     | <1 Gbps   | 在大多数标准实例的基准带宽范围内               | 标准实例足够 |
| 中等     | 1-3 Gbps  | 可能超出 AWS 基准，但在 GCP/Azure 标准实例范围内    | <ul><li>AWS：监控是否限流，可能需要网络增强型</li><li>GCP/Azure：标准实例通常足够</li></ul> |
| 高         | 3-10 Gbps | 超出 AWS 基准。接近某些标准实例的上限 | <ul><li>AWS：需要网络增强型虚拟机</li><li>GCP/Azure：核实实例带宽规格</li></ul> |
| 极高    | >10 Gbps  | 超出大多数标准实例的能力                        | <ul><li>所有提供商都需要网络增强型虚拟机</li><li>对于大型产物，禁用[对象代理下载](../administration/object_storage.md#proxy-download)</li></ul> |

<a id="before-you-proceed-2"></a>

### 继续之前

在继续之前，记录完整的数据分析评估：

```txt
Data Profile Summary:
- Medium monorepos (2GB-10GB): _____
- Large monorepos (>10GB): _____
- Gitaly adjustments needed: _____
- Rails adjustments needed: _____
- Peak outbound traffic: _____ Gbps (sustained baseline: _____ Gbps)
- Peak inbound traffic: _____ Gbps (sustained baseline: _____ Gbps)
- Network infrastructure changes: _____
```

<a id="analyze-current-environment-and-validate-recommendations"></a>

## 分析当前环境并验证建议

了解现有环境为建议提供了关键背景：

- 如果当前环境处理工作负载时没有性能问题，它可以作为规模估算的宝贵验证。
- 相反，存在性能问题的环境需要仔细分析，以避免延续规模不足的问题。

<a id="document-the-current-environment"></a>

### 记录当前环境

收集全面的环境数据以确定当前状态：

- 架构详情：
  - 类型：高可用性 (HA) 或非高可用性 (non-HA)。
  - 部署方法：Linux 软件包或云原生极狐GitLab。
- 组件规格：
  - 每个组件的节点数量和规格。
  - 自定义配置或偏差。

<a id="identify-the-nearest-reference-architecture"></a>

### 识别最接近的参考架构

1. 将当前环境与[可用的参考架构](../administration/reference_architectures/_index.md)进行比较。考虑以下方面：

   - 每个组件的总计算资源。
   - 节点分布和架构模式（HA 与非 HA）。
   - 相对于参考架构规模的组件规格。

1. 记录您的发现：

   ```plaintext
   Nearest Reference Architecture: _____
   Custom configurations or deviations:
   - _____
   - _____
   ```

<a id="compare-current-environment-to-recommended-architecture"></a>

### 将当前环境与推荐架构进行比较

将当前环境与您在前面各节中得出的推荐参考架构进行比较。如果当前环境：

- 没有性能问题且当前资源 < 推荐 RA：
  - 建议是保守的，并提供了未来的余量。
  - 继续采用推荐的 RA。
  - 实施后监控潜在的优化机会。
- 没有性能问题且当前资源 ≈ 推荐 RA：
  - 有力地验证了您的规模评估。
  - 当前环境确认推荐规模是合适的。
- 没有性能问题且当前资源 > 推荐 RA：
  - 当前环境可能过度预配，或者有需要分析的合理理由来使用额外资源。
    检查 Rails、Gitaly、数据库和 Sidekiq 上的 CPU/内存[资源利用率](../administration/monitoring/prometheus/_index.md#sample-prometheus-queries)。

    低利用率（<40%）表明过度预配。高利用率可能表明 RPS 分析未捕获的特定工作负载要求。
  - 审查建议是否需要针对未发现的要求进行调整。

如果当前环境存在性能问题：

- 仅将当前规格用作最低基准。前面各节的建议应超过当前规格。
- 如果建议显著低于当前规格，请调查：
  - 评估中未捕获的工作负载模式。
  - 需要针对性扩展的特定于组件的瓶颈。

<a id="before-you-proceed-3"></a>

### 继续之前

完成本节后，您已经分析了当前环境并与建议进行了比较。

在继续之前，记录完整的环境比较：

```plaintext
Current Environment Analysis:
- Current RA (nearest): _____
- Recommended RA (from RPS and workload analysis): _____
- Resource comparison: [ ] Current < Recommended [ ] Current ≈ Recommended [ ] Current > Recommended
- Performance status: [ ] No issues [ ] Has issues
- Adjustments needed: _____
- Notes: _____
```

在下一节中，您将评估增长预测，以确保规模随时间推移仍然合适。

<a id="plan-for-future-capacity"></a>

## 规划未来容量

基础设施变更需要大量的采购、迁移和测试前置时间。增长估算可确保推荐的架构在整个实施期间及之后仍然可行。

历史趋势与业务计划相结合，可提供最准确的增长预测。

<a id="analyze-historical-growth-patterns"></a>

### 分析历史增长模式

过去的增长模式比业务预测更能帮助预测未来轨迹：

1. 使用[您的基准规模](#determine-your-baseline-size)中的信息，将当前 RPS 与 6-12 个月前进行比较。
1. 识别增长加速或减速趋势。

<a id="incorporate-business-planning-factors"></a>

### 纳入业务规划因素

影响基础设施需求的预期业务变化：

- 团队扩张或整合。
- 新项目开发。
- 现有项目的开发活动增加。

评估这些因素（或其他组织变化）中的任何一个是否可能影响环境负载并需要基础设施调整。记录相关变化及其预期时间线。

<a id="determine-growth-buffer-strategy"></a>

#### 确定增长缓冲策略

根据历史趋势和业务预测，选择适当的增长容纳策略：

- 稳定或最小增长：继续监控。参考架构包含内置余量。
- 适度增长：规划按预计未来 RPS 确定规模的 RA。
- 预期显著增长：考虑按预计未来 RPS 而非当前 RPS 确定规模。

<a id="before-you-proceed-4"></a>

### 继续之前

完成本节后，增长预测已纳入规模决策。

记录完整的增长分析：

```plaintext
Growth Assessment Summary:
- Historical RPS comparison: _____
- Business growth factors: _____
- Growth category: [ ] Stable/Minimal [ ] Moderate [ ] Significant
- Strategy: [ ] Current RA sufficient [ ] Size for projected growth
```

在下一节中，您将把所有发现汇总为最终的架构建议。

<a id="compile-findings"></a>

## 汇总发现

汇总前面所有各节的发现，以确定最佳参考架构和所需的调整。

<a id="determine-final-architecture"></a>

### 确定最终架构

收集每个部分的关键输出，以形成规模决策：

1. 从基于 [RPS 分析](#determine-your-baseline-size)确定的参考架构开始。
1. 根据[工作负载模式](#identify-component-adjustments)和[数据特征](#assess-special-infrastructure-requirements)应用任何所需的组件调整。如果未识别出任何模式，或标准配置已足够，则跳过此步骤。
1. 对照[当前状态](#analyze-current-environment-and-validate-recommendations)进行验证。如果当前环境运行良好但超出建议，请记录原因。如果存在性能问题，请确保建议超过当前规格。
1. 在[未来容量规划](#plan-for-future-capacity)中容纳增长。确定当前 RA 是否足够，或者是否需要按预计增长确定规模。

<a id="document-final-recommendation"></a>

### 记录最终建议

基于全面评估，记录完整的架构建议：

```plaintext
Final Architecture Recommendation
==================================

- Selected RA: [Size] based on [Absolute/Sustained] Peak RPS of [value]
- Component adjustments required:
  - [ ] No adjustments needed - standard RA configuration sufficient
  - [ ] Adjustments required:
      - Rails: _____
      - Sidekiq: _____
      - Database: _____
      - Gitaly: _____
      - Network considerations: □ Standard instances □ Network-optimized instances
- Selected RA is aligned with existing environment: [Yes/No/Not applicable]
- Growth accommodation: [Current RA sufficient / Sized up for growth]

Assessment Summary:
├── RPS Analysis
│   ├── Absolute Peak RPS: _____ → Baseline RA: _____
│   └── Sustained Peak RPS: _____ → Sustained RA: _____
├── Workload Type
│   └── Type: [ ] Database-Intensive [ ] Sidekiq-Intensive [ ] None
├── Data Profile
│   ├── Large repos (>2GB): _____ | Monorepos (>10GB): _____
│   └── Network: Peak _____ Gbps | Baseline _____ Gbps
├── Current State
│   ├── Nearest RA: _____
|   └── Discrepancies and customizations: _____
└── Growth
    ├── Growth projection: _____
    └── Growth buffer strategy: _____
```

完成所有部分后，规模评估即告完成。最终建议包括：

- 基础参考架构规模。
- 特定于组件的调整
- 增长容纳策略。

定期监控仍然至关重要，以验证假设并随着工作负载模式的演变调整基础设施。
