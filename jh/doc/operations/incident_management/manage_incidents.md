---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中创建、分配、更新和解决事件，以及更改升级策略。
title: 管理事件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.0 中引入了将[事件](_index.md)添加到迭代的功能。

{{< /history >}}

本页面汇总了有关[事件](incidents.md)或与之相关的所有操作指南。

<a id="create-an-incident"></a>

## 创建事件

您可以手动或自动创建事件。

<a id="add-an-incident-to-an-iteration"></a>

## 将事件添加到迭代

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要将事件添加到[迭代](../../user/group/iterations/_index.md)：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 转到您的事件：
   - 对于议题列表中的事件，选择 **计划** > **工作项**，然后按 **类型** = **事件** 进行筛选。
   - 对于监控列表中的事件，选择 **监控** > **事件**。
1. 选择您的事件。
1. 在右侧边栏中，在 **迭代** 部分选择 **编辑**。
1. 从下拉列表中，选择要添加此事件的迭代。
1. 选择下拉列表外的任何区域。

或者，您也可以使用 [`/iteration` 快速操作](../../user/project/quick_actions.md#iteration)。

<a id="from-the-incidents-page"></a>

### 从事件页面创建

先决条件：

- 您必须对项目具有报告者、开发者、维护者或所有者角色。

从 **事件** 页面创建事件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **监控** > **事件**。
1. 选择 **创建事件**。

<a id="from-the-work-items-page"></a>

### 从工作项页面创建

先决条件：

- 您必须对项目具有报告者、开发者、维护者或所有者角色。

从 **工作项** 页面创建事件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后选择 **新建项**。
1. 从 **类型** 下拉列表中，选择 **事件**。页面上仅显示与事件相关的字段。
1. 选择 **创建事件**。

<a id="from-an-alert"></a>

### 从告警创建

在查看[告警](alerts.md)时创建事件议题。事件描述将从告警中填充。

先决条件：

- 您必须对项目具有开发者、维护者或所有者角色。

从告警创建事件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **监控** > **告警**。
1. 选择您想要的告警。
1. 选择 **创建事件**。

事件创建后，要查看来自告警的事件，选择 **查看事件**。

当您[关闭事件](#close-an-incident)（该事件链接到告警）时，极狐GitLab 会将[告警状态](alerts.md#change-an-alerts-status)更改为 **已解决**。您因此获得告警状态变更的功劳。

<a id="automatically-when-an-alert-is-triggered"></a>

### 告警触发时自动创建

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在项目设置中，您可以开启[告警触发时自动创建事件](alerts.md#trigger-actions-from-alerts)。

<a id="using-the-pagerduty-webhook"></a>

### 使用 PagerDuty Webhook

{{< history >}}

- 在极狐GitLab 15.7 中引入了对 [PagerDuty V3 Webhook](https://support.pagerduty.com/docs/webhooks) 的支持。

{{< /history >}}

您可以设置一个与 PagerDuty 的 webhook，为每个 PagerDuty 事件自动创建极狐GitLab 事件。此配置需要同时在 PagerDuty 和极狐GitLab 中进行更改。

先决条件：

- 您必须对项目具有维护者或所有者角色。

要设置与 PagerDuty 的 webhook：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **监控**。
1. 展开 **事件**。
1. 选择 **PagerDuty 集成** 选项卡。
1. 开启 **活动** 开关。
1. 选择 **保存集成**。
1. 复制 **Webhook URL** 的值以备后续步骤使用。
1. 要将 webhook URL 添加到 PagerDuty webhook 集成，请按照 [PagerDuty 文档](https://support.pagerduty.com/docs/webhooks#manage-v3-webhook-subscriptions)中描述的步骤操作。

为了确认集成成功，从 PagerDuty 触发一个测试事件，检查极狐GitLab 是否从事件中创建了极狐GitLab 事件。

<a id="view-a-list-of-incidents"></a>

## 查看事件列表

要查看[事件](incidents.md#incidents-list)列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **监控** > **事件**。

要查看事件的[详情页面](incidents.md#incident-details)，从列表中选择它。

<a id="who-can-view-an-incident"></a>

### 谁可以查看事件

{{< history >}}

- 在极狐GitLab 17.7 中，将最低用户角色从报告者更改为计划者。

{{< /history >}}

您能否查看事件取决于[项目可见性级别](../../user/public_access.md)和事件的机密性状态：

- 公开项目且为非机密事件：任何人都可以查看事件。
- 私有项目且为非机密事件：您必须对项目具有访客、计划者、报告者、开发者、维护者或所有者角色。
- 机密事件（无论项目可见性如何）：您必须对项目具有计划者、报告者、开发者、维护者或所有者角色。

<a id="assign-to-a-user"></a>

## 分配给用户

将事件分配给正在积极响应的用户。

先决条件：

- 您必须对项目具有报告者、开发者、维护者或所有者角色。

分配用户：

1. 在事件中，在右侧边栏中，**指派人** 旁边，选择 **编辑**。
1. 从下拉列表中，选择一位或[多位用户](../../user/project/issues/multiple_assignees_for_issues.md)添加为 **指派人**。
1. 选择下拉列表外的任何区域。

<a id="change-severity"></a>

## 更改严重程度

有关可用严重性级别的完整介绍，请参见[事件列表](incidents.md#incidents-list)主题。

先决条件：

- 您必须对项目具有报告者、开发者、维护者或所有者角色。

要更改事件的严重程度：

1. 在事件中，在右侧边栏中，**严重程度** 旁边，选择 **编辑**。
1. 从下拉列表中，选择新的严重程度。

您也可以使用 [`/severity` 快速操作](../../user/project/quick_actions.md#severity)更改严重程度。

<a id="change-status"></a>

## 更改状态

{{< history >}}

- 在极狐GitLab 14.9 中引入，有一个名为 `incident_escalations` 的功能标志，默认禁用。
- 在极狐GitLab 14.10 中于 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 15.1 中移除了功能标志 `incident_escalations`。

{{< /history >}}

先决条件：

- 您必须对项目具有开发者、维护者或所有者角色。

要更改事件的状态：

1. 在事件中，在右侧边栏中，**状态** 旁边，选择 **编辑**。
1. 从下拉列表中，选择新的状态。

**已触发** 是新事件的默认状态。

<a id="as-an-on-call-responder"></a>

### 作为值班响应者

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

值班响应者可以通过更改状态来响应[事件寻呼](paging.md#escalating-an-incident)。

更改状态具有以下影响：

- 更改为 **已确认**：根据项目的[升级策略](escalation_policies.md)限制值班寻呼。
- 更改为 **已解决**：静默该事件的所有值班寻呼。
- 从 **已解决** 更改为 **已触发**：重新开始事件升级。

在极狐GitLab 15.1 及更早版本中，更改[从告警创建的事件](#from-an-alert)的状态也会更改告警状态。在 [GitLab 15.2 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/356057) 中，告警状态独立，不会因事件状态变化而改变。

<a id="change-escalation-policy"></a>

## 更改升级策略

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 您必须对项目具有开发者、维护者或所有者角色。

要更改事件的升级策略：

1. 在事件中，在右侧边栏中，**升级策略** 旁边，选择 **编辑**。
1. 从下拉列表中，选择升级策略。

默认情况下，新事件没有选择任何升级策略。

选择升级策略会[将事件状态更改](#change-status)为 **已触发** 并开始[将事件升级给值班响应者](paging.md#escalating-an-incident)。

在极狐GitLab 15.1 及更早版本中，[从告警创建的事件](#from-an-alert)的升级策略反映告警的升级策略，且无法更改。在 [GitLab 15.2 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/356057) 中，事件升级策略独立，且可以更改。

<a id="close-an-incident"></a>

## 关闭事件

先决条件：

- 您必须对项目具有报告者、开发者、维护者或所有者角色。

要关闭事件，在右上角选择 **事件操作** ({{< icon name="ellipsis_v" >}})，然后选择 **关闭事件**。

当您关闭链接到[告警](alerts.md)的事件时，链接的告警状态会变为 **已解决**。您因此获得告警状态变更的功劳。

<a id="automatically-close-incidents-via-recovery-alerts"></a>

### 通过恢复告警自动关闭事件

开启当极狐GitLab 从 HTTP 或 Prometheus webhook 收到恢复告警时自动关闭事件。

先决条件：

- 您必须对项目具有维护者或所有者角色。

配置此设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **监控**。
1. 展开 **事件** 部分。
1. 勾选 **自动关闭关联事件** 复选框。
1. 选择 **保存更改**。

当极狐GitLab 收到[恢复告警](integrations.md#recovery-alerts)时，它会关闭关联的事件。此操作会作为系统笔记记录在事件上，表明它是由极狐GitLab 告警机器人自动关闭的。

<a id="delete-an-incident"></a>

## 删除事件

先决条件：

- 您必须对项目具有所有者角色。

要删除事件：

1. 在事件中，选择 **事件操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **删除事件**。

或者：

1. 在事件中，选择 **编辑**。
1. 选择 **删除事件**。

<a id="other-actions"></a>

## 其他操作

由于极狐GitLab 中的事件基于[议题](../../user/project/issues/_index.md)，它们共享以下操作：

- [添加待办事项](../../user/todos.md#create-a-to-do-item)
- [添加标签](../../user/project/labels.md#assign-and-unassign-labels)
- [分配里程碑](../../user/project/milestones/_index.md#assign-a-milestone-to-an-item)
- [将事件设为机密](../../user/project/issues/confidential_issues.md)
- [设置截止日期](../../user/project/issues/due_dates.md)
- [切换通知](../../user/profile/notifications.md#subscribe-to-notifications-for-a-specific-issue-merge-request-or-epic)
- [跟踪花费的时间](../../user/project/time_tracking.md)