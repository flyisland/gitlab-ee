---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Instance, group, and project analytics.
title: 分析 极狐GitLab 使用情况
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 群组级别分析在 13.9 移到了 极狐GitLab 专业版。

{{< /history >}}

极狐GitLab 提供了分析功能，可让您深入了解软件开发生命周期。
利用这些功能跟踪生产力、代码质量、部署性能和安全。
分析功能适用于实例、群组和[项目](../project/settings/_index.md#turn-off-project-analytics)，
并且需要不同的[角色和权限](../permissions.md#project-analytics)。
这样，您就可以在对团队重要的规模上分析数据。

<a id="analytics-features"></a>

## 分析功能

<a id="end-to-end-insight--visibility-analytics"></a>

### 端到端洞察与可见性分析

使用这些功能来了解整个软件开发生命周期。

| 功能 | 描述 | 项目级别 | 群组级别 | 实例级别 |
| --- | --- | --- | --- | --- |
| [价值流仪表板](value_streams_dashboard.md) | 了解 DevSecOps 趋势、模式以及数字化转型改进机会。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [价值流管理分析](../group/value_stream_analytics/_index.md) | 通过可自定义的阶段了解价值实现时间。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| DevOps 采用情况 [按群组](../group/devops_adoption/_index.md) 和 [按实例](../../administration/analytics/devops_adoption.md) | 组织在 DevOps 采用方面的成熟度，包括随时间推移的功能采用情况以及按群组的功能分布。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [使用趋势](../../administration/analytics/usage_trends.md) | 实例数据概览以及数据量随时间的变化。 | {{< no >}} | {{< no >}} | {{< yes >}} |
| [洞察](../project/insights/_index.md) | 可自定义的报告，用于探索议题、已合并的合并请求和分类健康状况。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [分析仪表板](analytics_dashboards.md) | 内置和可自定义的仪表板，用于可视化收集的数据。 | {{< yes >}} | {{< yes >}} | {{< no >}} |

<a id="productivity-analytics"></a>

### 生产力分析

使用这些功能来了解团队在议题和合并请求方面的生产力。

| 功能 | 描述 | 项目级别 | 群组级别 | 实例级别 |
| --- | --- | --- | --- | --- |
| [议题分析](../group/issues_analytics/_index.md) | 每月创建的议题的可视化。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [合并请求分析](merge_request_analytics.md) | 合并请求概览，包括平均合并时间、吞吐量和活动详情。 | {{< yes >}} | {{< no >}} | {{< no >}} |
| [生产力分析](productivity_analytics.md) | 合并请求生命周期，可过滤至作者级别。 | {{< no >}} | {{< yes >}} | {{< no >}} |
| [代码审查分析](code_review_analytics.md) | 打开的合并请求及其活动信息。 | {{< yes >}} | {{< no >}} | {{< no >}} |

<a id="developer-analytics"></a>

### 开发者分析

使用这些功能来了解开发者生产力和代码覆盖率。

| 功能 | 描述 | 项目级别 | 群组级别 | 实例级别 |
| --- | --- | --- | --- | --- |
| [贡献分析](../group/contribution_analytics/_index.md) | 群组成员所做的[贡献事件](../profile/contributions_calendar.md)概览，包括推送事件、合并请求和议题的条形图。 | {{< no >}} | {{< yes >}} | {{< no >}} |
| [贡献者分析](contributor_analytics.md) | 项目成员提交的概览，包含提交数的折线图。 | {{< yes >}} | {{< no >}} | {{< no >}} |
| [代码库分析](../group/repositories_analytics/_index.md) | 代码库中使用的编程语言和代码覆盖率统计。 | {{< yes >}} | {{< yes >}} | {{< no >}} |

<a id="cicd-analytics"></a>

### CI/CD 分析

使用这些功能来了解 CI/CD 性能。

| 功能 | 描述 | 项目级别 | 群组级别 | 实例级别 |
| --- | --- | --- | --- | --- |
| [CI/CD 分析](ci_cd_analytics.md) | 流水线持续时间和成功或失败。 | {{< yes >}} | {{< no >}} | {{< no >}} |
| [DORA 指标](dora_metrics.md) | DORA 指标随时间变化。 | {{< yes >}} | {{< yes >}} | {{< no >}} |

<a id="security-analytics"></a>

### 安全分析

使用这些功能来了解安全漏洞和指标。

| 功能 | 描述 | 项目级别 | 群组级别 | 实例级别 |
| --- | --- | --- | --- | --- |
| [安全仪表板](../application_security/security_dashboard/_index.md) | 安全扫描器检测到的漏洞的指标、评级和图表的集合。 | {{< yes >}} | {{< yes >}} | {{< no >}} |

<a id="metric-glossary"></a>

## 指标术语表

以下术语表提供了分析功能中使用的常见开发指标的定义，
并解释了它们在 极狐GitLab 中的度量方式。

| 指标 | 定义 | 极狐GitLab 中的度量方式 |
| --- | --- | --- |
| 平均变更时间（MTTC） | 从想法到交付的平均持续时间。 | 从创建议题到其相关合并请求部署到生产环境为止。 |
| 平均检测时间（MTTD） | 错误在生产环境中未被检测到的平均持续时间。 | 从错误部署到生产环境到创建报告该错误的议题为止。 |
| 平均合并时间（MTTM） | 合并请求的平均生命周期。 | 从创建合并请求到合并为止。不包括已关闭或未合并的合并请求。有关更多信息，请参见[合并请求分析](merge_request_analytics.md)。 |
| 平均恢复 / 修复 / 解决时间（MTTR） | 错误在生产环境中未修复的平均持续时间。 | 从错误部署到生产环境到错误修复部署为止。 |
| 速率（Velocity） | 在特定时间段内完成的议题总负担。通常以点数或权重衡量，通常每个迭代。 | 在特定时间段内关闭的议题的总点数或权重。例如，“每个迭代 30 点”。 |

有关更多定义，另请参见[价值流仪表板指标和下钻报告](value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports)。