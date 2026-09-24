---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Monitor DevSecOps adoption in your GitLab instance, track feature usage, and get insights into team performance.
title: 实例 DevOps 采用情况
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

DevOps 采用情况为您提供整个实例对开发、安全和运维功能的采用概览，以及 DevOps 分数。

有关该功能的更多信息，另请参阅[群组的 DevOps 采用情况](../../user/group/devops_adoption/_index.md)。

<a id="devops-score"></a>

## DevOps 分数

> [!note]
> 要查看 DevOps 分数，您必须激活极狐GitLab 实例的 [Service Ping](../settings/usage_statistics.md#service-ping)。
> DevOps 分数是一种比较工具，因此您的分数数据必须首先由极狐GitLab Inc. 进行集中处理。
> 如果未激活 Service Ping，则 DevOps 分数值为 0。

您可以使用 DevOps 分数将您的 DevOps 状况与其他组织进行比较。

**DevOps 分数** 显示过去 30 天内您实例上主要极狐GitLab 功能的使用情况，并取该时间段内可计费用户数的平均值。

- **您的分数** 表示您的各项功能分数的平均值。
- **您的用量** 表示过去 30 天内每名可计费用户的某项功能平均用量。
- **领先者用量** 是根据极狐GitLab 收集的 [Service Ping 数据](../settings/usage_statistics.md#service-ping) 从表现最佳实例中计算得出。

Service Ping 数据在极狐GitLab 服务器上聚合以进行分析。
您的用量信息 **不会发送** 到任何其他极狐GitLab 实例。
如果您刚刚开始使用极狐GitLab，则可能需要几周时间来收集数据，之后此功能才可用。

<a id="view-devops-adoption"></a>

## 查看 DevOps 采用情况

先决条件：

- 具有管理员访问权限。

要查看您实例的 DevOps 采用情况：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **分析** > **DevOps 采用情况**。

<a id="add-a-group-to-devops-adoption"></a>

## 添加群组到 DevOps 采用情况

先决条件：

- 您必须拥有该群组的报告者、开发者、维护者或所有者角色。

要添加群组到 DevOps 采用情况：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **分析** > **DevOps 采用情况**。
1. 从 **添加或移除群组** 下拉列表中，选择要添加的群组。

<a id="remove-a-group-from-devops-adoption"></a>

## 从 DevOps 采用情况中移除群组

先决条件：

- 您必须拥有该群组的报告者、开发者、维护者或所有者角色。

要从 DevOps 采用情况中移除群组：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **分析** > **DevOps 采用情况**。
1. 任选其一：
   - 从 **添加或移除群组** 下拉列表中，取消选择要移除的群组。
   - 在 **群组采用情况** 表中，在要移除的群组所在行，选择 **从表格中移除群组** ({{< icon name="remove" >}})。