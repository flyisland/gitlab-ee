---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 在极狐GitLab 中启用并配置 ClickHouse 进行数据分析。
title: 使用 ClickHouse 进行数据分析报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- ClickHouse 数据收集器在极狐GitLab 16.3 中引入，由名为 `clickhouse_data_collection` 的 [功能标志](feature_flags/_index.md) 控制，默认为禁用状态。
- 功能标志 `clickhouse_data_collection` 在极狐GitLab 17.0 中移除，并替换为应用程序设置。

{{< /history >}}

<a id="use-clickhouse-for-analytics-reports"></a>

# 使用 ClickHouse 进行数据分析报告

[贡献分析](../user/group/contribution_analytics/_index.md) 报告、[CI/CD 分析仪表板](../user/analytics/ci_cd_analytics.md) 和 [价值流仪表板](../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports) 的贡献者计数指标可以使用 ClickHouse 作为数据源。

前置条件：

- 在你的实例上 [配置 ClickHouse](../integration/clickhouse.md)。
- 管理员访问权限。

启用 ClickHouse：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **分析** 部分，勾选 **启用 ClickHouse** 复选框。

  