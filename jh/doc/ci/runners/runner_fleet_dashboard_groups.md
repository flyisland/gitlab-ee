---
stage: Verify
group: CI Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组 Runner 机群仪表板
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.0 中作为测试版引入，带有一个名为 `runners_dashboard_for_groups` 的功能标志。默认禁用。
- 功能标志 `runners_dashboard_for_groups` 在极狐GitLab 17.2 中移除。

{{< /history >}}

群组中具有维护者或所有者角色的用户可以使用 runner 机群仪表板来评估群组 runner 的健康状况。

![群组 Runner 机群仪表板](img/runner_fleet_dashboard_groups_v17_1.png)

<a id="dashboard-metrics"></a>

## 仪表板指标

runner 机群仪表板中提供以下指标：

| 指标                          | 描述 |
|-------------------------------|-------------|
| 在线                          | 在线 runner 数量。在 **管理员** 区域中，此指标显示整个实例的 runner 数量。在群组中，此指标显示该群组及其子群组的 runner 数量。 |
| 离线                          | 离线 runner 数量。 |
| 活跃 runner                   | 活跃 runner 数量。 |
| Runner 用量（上个月）<sup>1</sup> | 每个项目在群组 runner 上使用的计算分钟数。包括导出为 CSV 以进行成本分析的选项。 |
| 等待接取作业的时间<sup>1</sup>     | 显示 runner 的平均等待时间。该指标提供洞察，了解 runner 是否有能力处理组织中目标服务水平目标下的 CI/CD 作业队列。生成此指标小部件的数据每 24 小时更新一次。 |

**脚注**：

1. 对于极狐GitLab 私有化部署，要查看 **Runner 用量** 和 **等待接取作业的时间** 指标，您必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。

<a id="view-the-runner-fleet-dashboard-for-groups"></a>

## 查看群组 Runner 机群仪表板

先决条件：

- 您必须具有该群组的维护者角色。
- 对于极狐GitLab 私有化部署，要查看 **Runner 用量** 和 **等待接取作业的时间** 指标，请配置 [ClickHouse 集成](../../integration/clickhouse.md)。

要查看群组 runner 机群仪表板：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
2. 在左侧边栏中，选择 **构建** > **Runners**。
3. 选择 **机群仪表板**。