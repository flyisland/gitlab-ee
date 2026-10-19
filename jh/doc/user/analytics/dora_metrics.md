---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Gain insights into DevOps performance and identify opportunities for workflow improvements.
title: DevOps 研究与评估 (DORA) 指标
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="devops-research-and-assessment-dora-metrics"></a>

# DevOps 研究与评估 (DORA) 指标

[DevOps Research and Assessment (DORA)](https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance) 指标提供了关于你 DevOps 表现的基于证据的洞察。
这四个关键测量指标展示了你团队交付变更的速度，以及这些变更在生产环境中表现如何。
当持续跟踪时，DORA 指标能突出你软件交付流程中的改进机会。

使用 DORA 指标进行战略决策，向利益相关者证明流程改进投资的合理性，或将你团队的表现与行业基准进行比较，以识别竞争优势。

DORA 的四个指标衡量了 DevOps 的两个关键方面：

- **速度指标** 跟踪组织交付软件的速度：
  - [部署频率](#deployment-frequency)：代码部署到生产环境的频率
  - [变更前置时间](#lead-time-for-changes)：代码到达生产环境所需的时间
- **稳定性指标** 衡量软件的可靠性：
  - [变更失败率](#change-failure-rate)：部署导致生产失败的频率
  - [恢复服务时间](#time-to-restore-service)：失败后服务恢复的速度

对速度和稳定性指标的双重关注有助于领导者在交付工作流中找到速度和质量之间的最佳平衡。

<a id="deployment-frequency"></a>

## 部署频率

{{< history >}}

- 在 极狐GitLab 16.0 中，对 `all` 和 `monthly` 间隔的频率计算公式引入了修复。

{{< /history >}}

部署频率是指在给定时间范围内（每小时、每天、每周、每月或每年）成功部署到生产环境的频率。

软件领导者可以利用部署频率指标来了解团队成功部署软件到生产环境的频率，以及团队响应客户请求或新市场机会的速度。
高部署频率意味着你可以更快获得反馈，更快速地迭代以交付改进和功能。

<a id="how-deployment-frequency-is-calculated"></a>

### 部署频率的计算方式

在 极狐GitLab 中，部署频率是根据给定环境中每天的平均部署次数来衡量的，基于部署的结束时间（其 `finished_at` 属性）。
极狐GitLab 根据指定日期内已完成的部署数量来计算部署频率。仅计算成功的部署（`Deployment.statuses = success`）。

计算时会考虑生产 `environment tier` 或名为 `production/prod` 的环境。环境必须属于生产部署层级，其部署信息才会显示在图表中。

你可以通过在 [`.gitlab/insights.yml` 文件](../project/insights/_index.md#configuration) 的 `environment_tiers` 参数下指定 `other` 来为不同环境配置 DORA 指标。

> [!note]
> 与其他使用中位数的 DORA 指标不同，部署频率计算的是**平均值**，因为中位数能提供更准确和可靠的性能视图，所以更受青睐。
> 这种差异是因为部署频率是在采用 DORA 框架之前添加到极狐GitLab 中的，并且在该指标被纳入其他报告时，其计算方法保持不变。
> [议题 499591](https://jihulab.com/gitlab-cn/gitlab/-/issues/499591) 提议为每个指标提供自定义计算方法的选项，可选择平均值或中位数。

<a id="how-to-improve-deployment-frequency"></a>

### 如何改进部署频率

第一步是针对群组和项目之间的代码发布节奏进行基准测试。接下来，你应考虑：

- 添加自动化测试。
- 添加自动化代码验证。
- 将变更拆分为更小的迭代。

<a id="lead-time-for-changes"></a>

## 变更前置时间

变更前置时间是指代码变更进入生产环境所需的时间。

**变更前置时间**与**前置时间**不同。在价值流分析中，前置时间衡量的是议题工作从提出（议题创建）到完成并交付（议题关闭）所需的时间。

对于软件领导者而言，变更前置时间反映了 CI/CD 流水线的效率，并可直观显示工作交付给客户的速度。
随着时间的推移，变更前置时间应不断缩短，而团队绩效应不断提高。较短的变更前置时间意味着 CI/CD 流水线更高效。

<a id="how-lead-time-for-changes-is-calculated"></a>

### 变更前置时间的计算方式

极狐GitLab 根据成功将合并请求交付到生产环境所需的秒数来计算变更前置时间：从合并请求合并时间（点击合并按钮时）到代码在生产环境中成功运行，计算中不包含 `coding_time`。数据在部署完成后立即汇总，会有轻微延迟。

默认情况下，变更前置时间仅支持测量一次包含多个部署作业的分支操作（例如，从开发到预发布再到生产的默认分支）。当合并请求在预发布环境合并，然后在生产环境合并时，极狐GitLab 会将其视为两个已部署的合并请求，而不是一个。

<a id="deployments-finishing-before-merge"></a>

#### 在合并前完成的部署

在极少数情况下，部署可能在其关联的合并请求合并之前完成。

这种情况可能发生在：

- 部署流程独立于合并工作流触发时。
- 在代码审查完成前进行手动部署干预时。

在这种情形下，极狐GitLab 使用公式：`GREATEST(0, deployment_finished_at - merge_request_merged_at)`。
`GREATEST` 函数通过返回 `0` 而非负值，确保前置时间值永远不为负数。
此函数在保持数据完整性的同时，避免了数据库约束冲突。

<a id="how-to-improve-lead-time-for-changes"></a>

### 如何改进变更前置时间

第一步是针对群组和项目之间 CI/CD 流水线的效率进行基准测试。接下来，你应考虑：

- 使用价值流分析来识别流程中的瓶颈。
- 将变更拆分为更小的迭代。
- 添加自动化。
- 提高流水线的性能。

<a id="time-to-restore-service"></a>

## 恢复服务时间

{{< history >}}

- 在 极狐GitLab 15.1 中引入。

{{< /history >}}

恢复服务时间是指组织从生产环境故障中恢复所需的时间。

对于软件领导者而言，恢复服务时间反映了组织从生产故障中恢复所需的时间。
较短的恢复服务时间意味着组织可以尝试新的创新功能，以推动竞争优势并提升业务成果。

<a id="how-time-to-restore-service-is-calculated"></a>

### 恢复服务时间的计算方式

在 极狐GitLab 中，恢复服务时间是通过衡量生产环境中事件保持开启状态的中位时间来计量的。
极狐GitLab 计算给定时间段内生产环境事件开启的秒数。这基于以下假设：

- [极狐GitLab 事件](../../operations/incident_management/incidents.md) 已被跟踪。
- 所有事件都与生产环境相关。
- 事件和部署具有严格的一对一关系。一个事件仅与一个生产部署相关，而任何生产部署至多关联一个事件。

<a id="how-to-improve-time-to-restore-service"></a>

### 如何改进恢复服务时间

第一步是针对群组和项目之间团队对服务中断和故障的响应及恢复情况进行基准测试。接下来，你应考虑：

- 提高对生产环境的可观测性。
- 改进响应工作流程。
- 提高部署频率并缩短变更前置时间，以便更高效地将修复部署到生产环境。

<a id="change-failure-rate"></a>

## 变更失败率

变更失败率是指变更在生产环境中导致故障的频率。

软件领导者可以利用变更失败率指标来洞察所交付代码的质量。
高变更失败率可能表明部署流程效率低下或自动化测试覆盖不足。

<a id="how-change-failure-rate-is-calculated"></a>

### 变更失败率的计算方式

在 极狐GitLab 中，变更失败率通过给定时间段内导致生产环境事件的部署百分比来衡量。
极狐GitLab 通过将事件数量除以生产环境的部署数量来计算变更失败率。此计算基于以下假设：

- [极狐GitLab 事件](../../operations/incident_management/incidents.md) 已被跟踪。
- 所有事件均为生产事件，无论其环境如何。
- 变更失败率主要用作高层级的稳定性跟踪指标，这就是为什么在某一天中，所有事件和部署都会汇总为一个联合的每日比率。关于在部署和事件之间添加特定关系的建议见 [议题 444295](https://jihulab.com/gitlab-cn/gitlab/-/issues/444295)。
- 变更失败率会将重复事件计算为独立条目，这会导致重复计数。[议题 480920](https://jihulab.com/gitlab-cn/gitlab/-/issues/480920) 提出了一个更精确计算的解决方案。

例如，如果你有 10 次部署（假设每天一次部署），其中第一天有两个事件，最后一天有一个事件，那么你的变更失败率为 0.3。

<a id="how-to-improve-change-failure-rate"></a>

### 如何改进变更失败率

第一步是针对群组和项目之间的质量和稳定性进行基准测试。接下来，你应考虑：

- 在稳定性和吞吐量（部署频率和变更前置时间）之间找到适当的平衡，而不是为了速度牺牲质量。
- 提高代码审查流程的有效性。
- 添加自动化测试。

<a id="dora-custom-calculation-rules"></a>

## DORA 自定义计算规则

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署
- Status: Experiment

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 15.4 中引入，[带有一个功能标志](../../administration/feature_flags/_index.md) 名为 `dora_configuration`。默认禁用。此功能是一个 [实验](../../policy/development_stages_support.md)。

{{< /history >}}

> [!flag]
> 此功能的可用性由一个功能标志控制。
> 更多信息请参见历史记录。

此功能是一个 [实验](../../policy/development_stages_support.md)。
要加入测试此功能的用户列表，[这里有一个建议的测试流程](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/96561#steps-to-check-on-localhost)。
如果你发现错误，请[在此处提交议题](https://jihulab.com/groups/gitlab-cn/-/epics/11490)。
要分享你的用例和反馈，请在 [史诗 11490](https://jihulab.com/groups/gitlab-cn/-/epics/11490) 中发表评论。

<a id="multi-branch-rule-for-lead-time-for-changes"></a>

### 变更前置时间的多分支规则

与默认的[变更前置时间计算方式](#how-lead-time-for-changes-is-calculated)不同，此计算规则允许对每个操作使用单个部署作业来测量多分支操作。
例如，从开发分支的开发作业，到预发布分支的预发布作业，再到生产分支的生产作业。

此计算规则通过更新 `dora_configurations` 表，添加属于开发流程的目标分支来实现。
这样，极狐GitLab 就能将这些分支识别为一个整体，并过滤掉其他合并请求。

此配置会更改所选项目的每日 DORA 指标计算方式，但不会影响其他项目、群组或用户。

此功能仅支持项目级传播。

为此，在 Rails 控制台中运行以下命令：

```ruby
my_project = Project.find_by_full_path('group/subgroup/project')
Dora::Configuration.create!(project: my_project, branches_for_lead_time_for_changes: ['master', 'main'])
```

要更新现有配置，请运行以下命令：

```ruby
my_project = Project.find_by_full_path('group/subgroup/project')
record = Dora::Configuration.where(project: my_project).first
record.branches_for_lead_time_for_changes = ['development', 'staging', 'master', 'main']
record.save!
```

<a id="measure-dora-metrics"></a>

## 衡量 DORA 指标

<a id="without-using-gitlab-cicd-pipelines"></a>

### 不使用极狐GitLab CI/CD 流水线

部署频率是根据部署记录计算的，部署记录是为典型的推送式部署创建的。
这些部署记录不会为拉取式部署创建，例如当容器镜像通过代理连接到极狐GitLab 时。

要在此类情况下跟踪 DORA 指标，你可以使用 Deployments API [创建部署记录](../../api/deployments.md#create-a-deployment)。
你必须设置环境名称，并为该环境配置层级，因为层级变量是针对给定环境指定的，而非针对部署。
更多信息，请参见如何[跟踪外部部署工具的部署](../../ci/environments/external_deployment_tools.md)。

<a id="with-jira"></a>

### 搭配 Jira 使用

- 部署频率和变更前置时间是基于极狐GitLab CI/CD 和合并请求（MR）计算的，无需 Jira 数据。
- 恢复服务时间和变更失败率需要 [极狐GitLab 事件](../../operations/incident_management/manage_incidents.md) 来进行计算。有关更多信息，请参阅如何使用[外部事件](#with-external-incidents)以及 [Jira 事件复制指南](https://gitlab.com/smathur/jira-incident-replicator)来衡量这些指标。

<a id="with-external-incidents"></a>

### 通过外部事件

对于 PagerDuty，你可以[设置一个 webhook](../../operations/incident_management/manage_incidents.md#using-the-pagerduty-webhook) 来为每个 PagerDuty 事件自动创建一个极狐GitLab 事件。
此配置需要你在 PagerDuty 和极狐GitLab 中都进行更改。

对于其他事件管理工具，你可以设置 [HTTP 集成](../../operations/incident_management/integrations.md#alerting-endpoints)，并使用它自动执行以下操作：

1. [当发送警报时创建事件](../../operations/incident_management/manage_incidents.md#automatically-when-an-alert-is-triggered)。
1. [通过恢复警报自动关闭事件](../../operations/incident_management/manage_incidents.md#automatically-close-incidents-via-recovery-alerts)。

<a id="analytics-features"></a>

## 分析功能

DORA 指标显示在以下分析功能中：

- [价值流仪表板](value_streams_dashboard.md) 包括 [DORA 指标对比面板](value_streams_dashboard.md#devsecops-metrics-comparison) 和 [DORA 执行者评分面板](value_streams_dashboard.md#dora-performers-score)。
- [CI/CD 分析图表](ci_cd_analytics.md) 展示 DORA 指标随时间的历史记录。
- [洞察报告](../project/insights/_index.md) 提供了使用 [DORA 查询参数](../project/insights/_index.md#dora-query-parameters) 创建自定义图表的选项。
- [GraphQL API](../../api/graphql/reference/_index.md) （带有交互式 [GraphQL 浏览器](../../api/graphql/_index.md#interactive-graphql-explorer)）和 [REST API](../../api/dora/metrics.md) 支持指标的检索。

<a id="project-and-group-availability"></a>

## 项目与群组可用性

下表概述了 DORA 指标在项目和群组中的可用性。

| 指标                       | 级别             | 备注 |
|---------------------------|-------------------|----------|
| `deployment_frequency`    | 项目           | 单位为部署次数。 |
| `deployment_frequency`    | 群组             | 单位为部署次数。聚合方式为平均值。  |
| `lead_time_for_changes`   | 项目           | 单位为秒。聚合方式为中位数。 |
| `lead_time_for_changes`   | 群组             | 单位为秒。聚合方式为中位数。 |
| `time_to_restore_service` | 项目和群组 | 单位为天。聚合方式为中位数。（在 极狐GitLab 15.1 及更高版本的 UI 图表中可用） |
| `change_failure_rate`     | 项目和群组 | 部署百分比。（在 极狐GitLab 15.2 及更高版本的 UI 图表中可用） |

<a id="data-aggregation"></a>

## 数据聚合

下表概述了 DORA 指标在不同图表中的数据聚合情况。

| 指标名称 | 测量值 | [价值流仪表板](value_streams_dashboard.md) 中的数据聚合 | [CI/CD 分析图表](ci_cd_analytics.md) 中的数据聚合 | [自定义洞察报告](../project/insights/_index.md#dora-query-parameters) 中的数据聚合 |
|---------------------------|-------------------|-----------------------------------------------------|------------------------|----------|
| 部署频率 | 成功部署次数 | 按月的每日平均值 | 每日平均值 | `day`（默认）或 `month` |
| 变更前置时间 | 成功将提交交付到生产环境所需的秒数 | 按月的每日中位数 | 中位时间 | `day`（默认）或 `month` |
| 恢复服务时间 | 事件开启的秒数 | 按月的每日中位数 | 每日中位数 | `day`（默认）或 `month` |
| 变更失败率 | 导致生产环境事件的部署百分比 | 按月的每日中位数 | 失败部署百分比 | `day`（默认）或 `month` |