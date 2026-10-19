---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在您的极狐GitLab 实例中监控 DevSecOps 采用情况，跟踪功能使用情况，并深入了解团队绩效。
title: 按实例查看 DevOps 采用情况
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

DevOps 采用情况让您总览整个实例对开发、安全和运维功能的采用情况，以及 DevOps 评分。

有关此功能的更多信息，另请参阅[按群组查看 DevOps 采用情况](../../user/group/devops_adoption/_index.md)。

<a id="devops-score"></a>

## DevOps 评分

> [!note]
> 要查看 DevOps 评分，您必须激活极狐GitLab 实例的[Service Ping](../settings/usage_statistics.md#service-ping)。
> DevOps 评分是一种比较工具，因此您的评分数据必须首先由 GitLab Inc. 集中处理。
> 如果未激活 Service Ping，DevOps 评分值为 0。

您可以使用 DevOps 评分将您的 DevOps 状态与其他组织进行比较。

**DevOps 评分**显示您的实例在过去 30 天内对主要极狐GitLab 功能的使用情况，并按该时间段内的计费用户数取平均值。

- **您的评分**表示您的各项功能评分的平均值。
- **您的使用情况**表示过去 30 天内每位计费用户对某项功能的平均使用量。
- **领先者使用情况**根据极狐GitLab 收集的[Service Ping 数据](../settings/usage_statistics.md#service-ping)，从表现最佳的实例计算得出。

Service Ping 数据在极狐GitLab 服务器上汇总以供分析。您的使用信息不会发送到任何其他极狐GitLab 实例。如果您刚开始使用极狐GitLab，可能需要几周时间收集数据，此功能才会可用。

<a id="view-devops-adoption"></a>

## 查看 DevOps 采用情况

先决条件：

- 管理员访问权限。

要查看您实例的 DevOps 采用情况：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**分析** > **DevOps 采用情况**。

<a id="add-a-group-to-devops-adoption"></a>

## 将群组添加到 DevOps 采用情况

先决条件：

- 您必须拥有该群组的报告者、开发者、维护者或所有者角色。

要将群组添加到 DevOps 采用情况：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**分析** > **DevOps 采用情况**。
1. 从**添加或移除群组**下拉列表中，选择您要添加的群组。

<a id="remove-a-group-from-devops-adoption"></a>

## 从 DevOps 采用情况中移除群组

先决条件：

- 您必须拥有该群组的报告者、开发者、维护者或所有者角色。

要从 DevOps 采用情况中移除群组：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**分析** > **DevOps 采用情况**。
1. 执行以下任一操作：

- 从**添加或移除群组**下拉列表中，清除您要移除的群组。
- 在**按群组查看采用情况**表格中，找到您要移除的群组所在行，选择
  **从表格中移除群组** ({{< icon name="remove" >}})。
