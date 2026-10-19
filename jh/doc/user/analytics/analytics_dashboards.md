---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 分析仪表板
description: 可视化项目和群组的 DevSecOps 与 AI 功能相关指标，并跟踪性能趋势。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

分析仪表板可帮助您在内置仪表板上可视化已收集的数据。

增强的仪表板体验已在 [史诗 13801](https://gitlab.com/groups/gitlab-org/-/work_items/13801) 和 [史诗 19430](https://gitlab.com/groups/gitlab-org/-/work_items/19430)中提出。

<a id="data-sources"></a>

## 数据源

数据源是与数据库或数据集合的连接，您的仪表板筛选器和可视化可以使用它来查询和检索结果。

<a id="built-in-dashboards"></a>

## 内置仪表板

为帮助您开始使用分析功能，极狐GitLab 提供了带有预定义可视化的内置仪表板。这些仪表板标记为 **由极狐GitLab**。

以下内置仪表板可用：

- [**价值流仪表板**](value_streams_dashboard.md)显示与 DevOps 性能、安全暴露和工作流优化相关的指标。
- [**极狐GitLab Duo 和 SDLC 趋势**](duo_and_sdlc_trends.md)显示 AI 工具对项目或群组的软件开发生命周期（SDLC）指标的影响。
- [**DORA 指标仪表板**](dora_metrics_charts.md)显示每个 DORA 指标随时间的演变。
- [**合并请求分析**](merge_request_analytics.md)显示合并请求吞吐量和平均合并时间的指标。

<a id="view-project-dashboards"></a>

## 查看项目仪表板

先决条件：

- 您必须拥有该项目的报告者、开发者、维护者或所有者角色。

查看项目的仪表板列表：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**分析** > **分析仪表板**。
1. 从可用仪表板列表中，选择您要查看的仪表板。

<a id="view-group-dashboards"></a>

## 查看群组仪表板

先决条件：

- 您必须拥有该群组的报告者、开发者、维护者或所有者角色。

查看群组的仪表板列表：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**分析** > **分析仪表板**。
1. 从可用仪表板列表中，选择您要查看的仪表板。
