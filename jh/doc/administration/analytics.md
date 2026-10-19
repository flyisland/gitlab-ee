---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 为极狐GitLab 中的数据分析启用并配置 ClickHouse。
title: 使用 ClickHouse 生成分析报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[贡献分析](../user/group/contribution_analytics/_index.md)报告、[CI/CD 分析仪表板](../user/analytics/ci_cd_analytics.md)和[价值流仪表板](../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports)的贡献者数量指标可以使用 ClickHouse 作为数据源。

先决条件：

- 在您的实例上[配置 ClickHouse](../integration/clickhouse.md)。
- 管理员访问权限。

要启用 ClickHouse：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 在**分析**部分，选中**启用 ClickHouse** 复选框。
