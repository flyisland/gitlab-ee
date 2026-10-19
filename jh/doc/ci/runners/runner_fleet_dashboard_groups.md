---
stage: Verify
group: CI Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组的 Runner 集群仪表板
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

拥有群组维护者或所有者角色的用户可以使用 Runner 集群仪表板来评估群组 Runner 的健康状况。

![群组的 Runner 集群仪表板](img/runner_fleet_dashboard_groups_v17_1.png)

<a id="dashboard-metrics"></a>

## 仪表板指标

Runner 集群仪表板中提供以下指标：

| 指标                        | 描述 |
|-------------------------------|-------------|
| 在线                        | 在线 Runner 的数量。在**管理**区域中，此指标显示整个实例的 Runner 数量。在群组中，此指标显示该群组及其子群组的 Runner 数量。 |
| 离线                       | 离线 Runner 的数量。 |
| 活跃 Runner                | 活跃 Runner 的数量。 |
| Runner 使用量（上个月）[^self-managed-view] | 群组 Runner 上每个项目使用的计算分钟数。包含导出为 CSV 以进行成本分析的选项。 |
| 选中作业的等待时间[^self-managed-view]       | 显示 Runner 的平均等待时间。此指标可帮助您了解 Runner 是否能够按照您组织的目标服务级别目标处理 CI/CD 作业队列。生成此指标组件的数据每 24 小时更新一次。 |

[^self-managed-view]: 对于极狐GitLab 私有化部署，要查看 **Runner 使用量**和**选中作业的等待时间**指标，
    您必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。

<a id="view-the-runner-fleet-dashboard-for-groups"></a>

## 查看群组的 Runner 集群仪表板

先决条件：

- 您必须拥有该群组的维护者角色。
- 对于极狐GitLab 私有化部署，要查看 **Runner 使用量**和**选中作业的等待时间**指标，
  请配置 [ClickHouse 集成](../../integration/clickhouse.md)。

要查看群组的 Runner 集群仪表板：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runner**。
1. 选择**队列仪表盘**。
