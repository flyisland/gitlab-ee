---
stage: Verify
group: CI Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 面向管理员的 Runner 集群仪表板
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

作为极狐GitLab 管理员，您可以使用 Runner 集群仪表板来评估实例 Runner 的健康状况。Runner 集群仪表板显示：

- 由 Runner 基础设施引起的近期 CI 错误
- 最繁忙的 Runner 上执行的并发作业数量
- 实例 Runner 使用的计算分钟
- 作业排队时间

![显示状态、使用情况和性能指标的 Runner 集群仪表板。](img/runner_fleet_dashboard_v17_1.png)

<a id="dashboard-metrics"></a>

## 仪表板指标

{{< details >}}

Status: 测试版

{{< /details >}}

Runner 集群仪表板中提供以下指标：

> [!note]
> 要查看 **Runner 使用量** 和 **选中作业的等待时间** 指标，您必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。
>
> > <!-- Video published on 2023-12-19 -->

| 指标                          | 描述 |
|-------------------------------|-------------|
| Online                        | 整个实例中处于在线状态的 Runner 数量。 |
| Offline                       | 处于离线状态的 Runner 数量。已注册但从未连接到极狐GitLab 的 Runner 不计入此数量。 |
| Active runners                | 处于活跃状态的 Runner 总数。 |
| Runner 使用量（上个月） | **需要 ClickHouse**：上个月每个项目或群组 Runner 使用的总计算分钟。您可以将此数据导出为 CSV 文件以进行成本分析。 |
| 选中作业的等待时间       | **需要 ClickHouse**：作业在队列中等待 Runner 获取它的平均时间。此指标可帮助您了解您的 Runner 是否能够在您组织设定的服务级别目标（SLO）范围内处理 CI/CD 作业队列。此数据每 24 小时更新一次。 |

<a id="view-the-runner-fleet-dashboard"></a>

## 查看 Runner 集群仪表板

先决条件：

- 您必须是管理员。
- 要查看 **Runner 使用量** 和 **选中作业的等待时间** 指标，您必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。

查看 Runner 集群仪表板：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择 **队列仪表盘**。

<a id="export-compute-minutes-used-by-instance-runners"></a>

## 导出实例 Runner 使用的计算分钟

先决条件：

- 您必须拥有实例的管理员访问权限。
- 您必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。

要分析 Runner 使用情况，您可以导出一个 CSV 文件，其中包含作业数量和已执行的 Runner 分钟数。该 CSV 文件显示每个项目的 Runner 类型和作业状态。导出完成后，CSV 文件会发送到您的电子邮箱。

导出实例 Runner 使用的计算分钟：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择 **队列仪表盘**。
1. 选择 **导出 CSV**。
