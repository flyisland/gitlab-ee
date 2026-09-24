---
stage: Verify
group: CI Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 管理员 Runner 队列仪表板
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.6 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/424495)。

{{< /history >}}

作为极狐GitLab 管理员，你可以使用 Runner 队列仪表板来评估实例 Runner 的健康状况。
Runner 队列仪表板显示：

- 由 Runner 基础设施引起的近期 CI 错误
- 在最繁忙的 Runner 上执行的并发作业数量
- 实例 Runner 使用的计算分钟数
- 作业排队时间

![显示状态、使用情况和性能指标的 Runner 队列仪表板。](img/runner_fleet_dashboard_v17_1.png)

## 仪表板指标

{{< history >}}

- **Runner usage** 和 **Wait time to pick up job** 指标作为一个[实验](../../policy/development_stages_support.md#experiment)在极狐GitLab 16.7 [引入](https://gitlab.com/groups/gitlab-org/-/epics/11180)，带有名为 `ci_data_ingestion_to_click_house` 和 `clickhouse_ci_analytics` 的[功能标志](../../administration/feature_flags/_index.md)。默认禁用。
- **Runner usage** 和 **Wait time to pick up job** 指标在极狐GitLab 17.1 [变更](https://gitlab.com/gitlab-org/gitlab/-/issues/424789)为 [beta](../../policy/development_stages_support.md#beta)。

{{< /history >}}

Runner 队列仪表板中提供以下指标：

> [!note]
> 要查看 **Runner usage** 和 **Wait time to pick a job** 指标，你必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。

| 指标                        | 描述 |
|-------------------------------|-------------|
| Online                        | 整个实例中在线的 Runner 数量。 |
| Offline                       | 当前离线的 Runner 数量。已注册但从未连接到极狐GitLab 的 Runner 不包含在此计数中。 |
| Active runners                | 当前活跃的 Runner 总数。 |
| Runner usage (previous month)<sup>1</sup> | **需要 ClickHouse**：每个项目或群组 Runner 在上个月使用的总计算分钟数。你可以将此数据导出为 CSV 文件以进行成本分析。 |
| Wait time to pick a job<sup>1</sup>       | **需要 ClickHouse**：作业在队列中等待 Runner 将其选中的平均时间。此指标可帮助你了解你的 Runner 是否有能力在你组织的目标服务水平目标 (SLO) 内为 CI/CD 作业队列提供服务。此数据每 24 小时更新一次。 |

**脚注**：

1. 此功能处于 [beta](../../policy/development_stages_support.md#beta) 阶段，如有更改，恕不另行通知。
   更多信息，请参见[史诗 11180](https://gitlab.com/groups/gitlab-org/-/epics/11180)。

## 查看 Runner 队列仪表板

先决条件：

- 你必须是一名管理员。
- 要查看 **Runner usage** 和 **Wait time to pick a job** 的指标，你必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。

要查看 Runner 队列仪表板：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runner**。
1. 选择 **队列仪表板**。

## 导出实例 Runner 使用的计算分钟数

先决条件：

- 你必须具有实例的管理员访问权限。
- 你必须配置 [ClickHouse 集成](../../integration/clickhouse.md)。

要分析 Runner 使用情况，你可以导出一个 CSV 文件，其中包含作业数量和已执行的 Runner 分钟数。该
CSV 文件显示每个项目的 Runner 类型和作业状态。导出完成后，CSV 将发送到你的电子邮件。

要导出实例 Runner 使用的计算分钟数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runner**。
1. 选择 **队列仪表板**。
1. 选择 **导出 CSV**。

