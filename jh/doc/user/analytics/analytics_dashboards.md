---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 分析仪表盘
description: Visualize metrics about DevSecOps and AI features for your projects and groups, and track performance trends.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 中作为[实验](../../policy/development_stages_support.md#experiment)功能引入，[有功能标志](../../administration/feature_flags/_index.md)名为 `combined_analytics_dashboards`。默认禁用。
- `combined_analytics_dashboards` 在极狐GitLab 16.11 中默认[启用]。
- `combined_analytics_dashboards` 在极狐GitLab 17.1 中[移除]。
- `filters` 配置在极狐GitLab 17.9 中[引入]，默认禁用。
- 内联可视化配置在极狐GitLab 17.9 中[引入]。
- 在 18.2 中从极狐GitLab 旗舰版[移动到]极狐GitLab 专业版。

{{< /history >}}

<a id="analytics-dashboards"></a>

# 分析仪表盘

分析仪表盘帮助你可视化内置仪表盘上收集的数据。

在 [epic 13801](https://jihulab.com/groups/gitlab-cn/-/epics/13801) 和 [epic 19430](https://jihulab.com/groups/gitlab-cn/-/work_items/19430) 中提出了增强的仪表盘体验。

<a id="data-sources"></a>

## 数据源

{{< history >}}

- 产品分析和自定义可视化数据源在极狐GitLab 17.7 中[移除]。

{{< /history >}}

数据源是连接到数据库或数据集的一种连接，可以被你的仪表盘过滤器和可视化用于查询和获取结果。

<a id="built-in-dashboards"></a>

## 内置仪表盘

为帮助你快速开始使用分析功能，极狐GitLab 提供了内置仪表盘，包含预定义的可视化。这些仪表盘标有 **由极狐GitLab**。

提供以下内置仪表盘：

- [**价值流仪表盘**](value_streams_dashboard.md) 显示与 DevOps 性能、安全暴露和工作流优化相关的指标。
- [**极狐GitLab Duo 和 SDLC 趋势**](duo_and_sdlc_trends.md) 显示 AI 工具对项目或群组的软件开发生命周期 (SDLC) 指标的影响。
- [**DORA 指标仪表盘**](dora_metrics_charts.md) 显示每个 DORA 指标随时间变化的演变。
- [**合并请求分析**](merge_request_analytics.md) 显示合并请求吞吐量和平均合并时间的指标。

<a id="view-project-dashboards"></a>

## 查看项目仪表盘

先决条件：

- 你必须具有该项目的报告者、开发者、维护者或所有者角色。

要查看项目的仪表盘列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **分析** > **分析仪表盘**。
1. 从可用仪表盘列表中，选择你想要查看的仪表盘。

<a id="view-group-dashboards"></a>

## 查看群组仪表盘

{{< history >}}

- [引入]于极狐GitLab 16.2，[有功能标志](../../administration/feature_flags/_index.md)名为 `group_analytics_dashboards`。默认禁用。
- 在极狐GitLab 16.8 [GA]。
- 功能标志 `group_analytics_dashboards` 在极狐GitLab 16.11 中[移除]。

{{< /history >}}

先决条件：

- 你必须具有该群组的报告者、开发者、维护者或所有者角色。

要查看群组的仪表盘列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **分析** > **分析仪表盘**。
1. 从可用仪表盘列表中，选择你想要查看的仪表盘。