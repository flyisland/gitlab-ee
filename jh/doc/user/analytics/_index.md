---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 实例、群组和项目分析。
title: 分析极狐GitLab 使用情况
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供分析功能，让您可以深入了解软件开发生命周期。使用这些功能来跟踪生产力、代码质量、部署性能和安全状况。分析功能适用于实例、群组和[项目](../project/settings/_index.md#turn-off-project-analytics)，并且需要不同的[角色和权限](../permissions.md#project-analytics)。这样，您就可以按照对团队有意义的规模来分析数据。

<a id="end-to-end-insight--visibility-analytics"></a>

## 端到端洞察与可见性分析

使用这些功能来深入了解您的整体软件开发生命周期。

| 功能 | 描述 | 项目级 | 群组级 | 实例级 |
| ------- | ----------- | ------------- | ----------- | -------------- |
| [价值流仪表板](value_streams_dashboard.md) | 深入了解 DevSecOps 趋势、模式以及数字化转型改进的机会。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [价值流管理分析](../group/value_stream_analytics/_index.md) | 通过可自定义的阶段深入了解实现价值所需的时间。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| DevOps 采用情况[按群组](../group/devops_adoption/_index.md)和[按实例](../../administration/analytics/devops_adoption.md) | 组织在 DevOps 采用方面的成熟度，包括随时间变化的功能采用情况以及按群组划分的功能分布。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [使用趋势](../../administration/analytics/usage_trends.md) | 实例数据概览以及数据量随时间的变化。 | {{< no >}} | {{< no >}} | {{< yes >}} |
| [洞察](../project/insights/_index.md) | 可自定义的报告，用于探索议题、已合并的合并请求和排查规范性。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [分析仪表板](analytics_dashboards.md) | 内置且可自定义的仪表板，用于可视化收集到的数据。 | {{< yes >}} | {{< yes >}} | {{< no >}} |

<a id="productivity-analytics"></a>

## 生产力分析

使用这些功能来深入了解团队在议题和合并请求方面的生产力。

| 功能 | 描述 | 项目级 | 群组级 | 实例级 |
| ------- | ----------- | ------------- | ----------- | -------------- |
| [议题分析](../group/issues_analytics/_index.md) | 可视化每月创建的议题。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
| [合并请求分析](merge_request_analytics.md) | 合并请求概览，包括平均合并时间、吞吐量和活动详情。 | {{< yes >}} | {{< no >}} | {{< no >}} |
| [生产力分析](productivity_analytics.md) | 合并请求生命周期，可筛选至作者级别。 | {{< no >}} | {{< yes >}} | {{< no >}} |
| [代码评审分析](code_review_analytics.md) | 未关闭的合并请求，以及有关合并请求活动的信息。 | {{< yes >}} | {{< no >}} | {{< no >}} |

<a id="developer-analytics"></a>

## 开发者分析

使用这些功能来深入了解开发者生产力和代码覆盖率。

| 功能 | 描述 | 项目级 | 群组级 | 实例级 |
| ------- | ----------- | ------------- | ----------- | -------------- |
| [贡献分析](../group/contribution_analytics/_index.md) | 群组成员所做[贡献事件](../profile/contributions_calendar.md)的概览，包括推送事件、合并请求和议题的柱状图。 | {{< no >}} | {{< yes >}} | {{< no >}} |
| [贡献者分析](contributor_analytics.md) | 项目成员所做提交的概览，包括提交数量的折线图。 | {{< yes >}} | {{< no >}} | {{< no >}} |
| [代码仓库分析](../group/repositories_analytics/_index.md) | 代码仓库中使用的编程语言以及代码覆盖率统计信息。 | {{< yes >}} | {{< yes >}} | {{< no >}} |

<a id="cicd-analytics"></a>

## CI/CD 分析

使用这些功能来深入了解 CI/CD 性能。

| 功能 | 描述 | 项目级 | 群组级 | 实例级 |
| ------- | ----------- | ------------- | ----------- | -------------- |
| [CI/CD 分析](ci_cd_analytics.md) | 流水线时长以及成功或失败情况。 | {{< yes >}} | {{< no >}} | {{< no >}} |
| [DORA 指标](dora_metrics.md) | 随时间变化的 DORA 指标。 | {{< yes >}} | {{< yes >}} | {{< no >}} |

<a id="security-analytics"></a>

## 安全分析

使用这些功能来深入了解安全漏洞和指标。

| 功能 | 描述 | 项目级 | 群组级 | 实例级 |
| ------- | ----------- | ------------- | ----------- | -------------- |
| [安全仪表板](../application_security/security_dashboard/_index.md) | 安全扫描器检测到的漏洞的指标、评级和图表集合。 | {{< yes >}} | {{< yes >}} | {{< no >}} |
