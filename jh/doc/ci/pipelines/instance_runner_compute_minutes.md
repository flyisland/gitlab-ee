---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 计算分钟、购买、用量跟踪、配额管理，适用于 JihuLab.com 上的实例 Runner 以及极狐GitLab 私有化部署。
title: 实例 Runner 的计算用量
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

项目在管理员管理的[实例 Runner](../runners/runners_scope.md#instance-runners) 上运行作业时可消耗的计算分钟用量是有限的。此限制通过极狐GitLab 服务器上的实例 Runner 计算配额进行跟踪。当命名空间超出配额时，将[强制执行配额](#enforcement)。

管理员管理的实例 Runner 是指[由极狐GitLab 实例管理员管理](../../administration/cicd/compute_minutes.md)的 Runner。

> [!note]
> 在 JihuLab.com 上，实例 Runner 既由管理员管理，也由极狐GitLab 托管，因为该实例由极狐GitLab 管理。

<a id="compute-quota-enforcement"></a>

## 计算配额的强制执行

<a id="monthly-reset"></a>

### 每月重置

计算分钟用量每月重置为 `0`。计算配额会[重置为每月分配量](https://gitlab.cn/pricing)。

例如，如果您的每月配额为 10,000 计算分钟：

1. 4 月 1 日，您有 10,000 计算分钟可用。
1. 4 月期间，您使用了配额中 10,000 计算分钟中的 6,000。
1. 5 月 1 日，累计计算用量重置为 0，您在 5 月有 10,000
   计算分钟可用。

上个月的用量数据会保留，以展示随时间变化的消耗历史视图。

<a id="notifications"></a>

### 通知

当剩余计算分钟出现以下情况时，会显示应用内横幅并向命名空间所有者发送电子邮件通知：

- 低于配额的 25%。
- 低于配额的 5%。
- 完全用完（剩余零分钟）。

<a id="enforcement"></a>

### 强制执行

当当前月份的计算配额用完时，实例 Runner 会停止处理新作业。在已经启动的流水线中：

- 任何必须由实例 Runner 处理的待处理作业（尚未启动）或重试作业都会被丢弃。
- 在实例 Runner 上运行的作业可以继续运行，直到整个命名空间的用量超出配额 1,000 计算分钟。超过 1,000 计算分钟的宽限期后，任何仍在运行的作业也会被丢弃。

项目和群组 Runner 不受计算配额影响，会继续处理作业。

由于实例 Runner 停止处理作业，这可能看起来像 Runner 可用性问题，而不是计算配额问题。

<a id="view-usage"></a>

## 查看用量

您可以查看群组或个人命名空间的计算用量（包括[额外分钟数](../../subscriptions/gitlab_com/compute_minutes.md)），以了解计算用量趋势以及还剩多少计算分钟。

在某些情况下，配额限制会被以下标签之一替代：

- **无限**：适用于具有无限计算配额的命名空间。
- **不支持**：适用于未启用实例 Runner 的命名空间。

<a id="view-usage-for-a-group"></a>

### 查看群组的用量

先决条件：

- 您必须具有该群组的所有者角色。

要查看您群组的计算用量：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。该群组不能是子群组。
1. 选择**设置** > **用量配额**。
1. 选择**流水线**标签页。

项目列表仅显示当前月份有计算用量或实例 Runner 用量的项目。该列表包含命名空间及其子群组中的所有项目，按计算用量降序排列。

<a id="view-usage-for-a-personal-namespace"></a>

### 查看个人命名空间的用量

您可以查看个人命名空间的计算用量：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**用量配额**。

项目列表仅显示当前月份有计算用量或实例 Runner 用量的[个人项目](../../user/project/working_with_projects.md)。
