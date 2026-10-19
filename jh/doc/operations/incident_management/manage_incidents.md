---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中创建、指派、更新和解决事件，并更改升级策略。
title: 管理事件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本页面汇总了您可以使用[事件](incidents.md)或围绕事件执行的所有操作的说明。

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

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您的事件：
   - 对于议题列表中的事件，选择**计划** > **工作项**，
     然后按**类型** = **事件**筛选。
   - 对于监控列表中的事件，选择**监控** > **事件**。
1. 选择您的事件。
1. 在右侧边栏的**迭代**部分，选择**编辑**。
1. 从下拉列表中，选择要将此事件添加到的迭代。
1. 选择下拉列表外的任意区域。

或者，您可以使用 [`/iteration` 快速操作](../../user/project/quick_actions.md#iteration)。

<a id="from-the-incidents-page"></a>

### 从事件页面创建

先决条件：

- 您必须具有该项目的报告者、开发者、维护者或所有者角色。

要从**事件**页面创建事件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**监控** > **事件**。
1. 选择**创建事件**。

<a id="from-the-work-items-page"></a>

### 从工作项页面创建

先决条件：

- 您必须具有该项目的报告者、开发者、维护者或所有者角色。

要从**工作项**页面创建事件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**计划** > **工作项**，然后选择**新建项**。
1. 从**类型**下拉列表中，选择**事件**。页面上仅提供与
   事件相关的字段。
1. 选择**创建事件**。

<a id="from-an-alert"></a>

### 从告警创建

在查看[告警](alerts.md)时创建事件议题。事件描述会根据告警内容自动填充。

先决条件：

- 您必须具有该项目的开发者、维护者或所有者角色。

要从告警创建事件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**监控** > **告警**。
1. 选择您想要的告警。
1. 选择**创建事件**。

创建事件后，要从告警查看该事件，请选择**查看事件**。

当您[关闭与告警关联的事件](#close-an-incident)时，极狐GitLab 会[将告警状态更改](alerts.md#change-an-alerts-status)为**已解决**。随后该告警的状态变更会记入您的名下。

<a id="automatically-when-an-alert-is-triggered"></a>

### 在触发告警时自动创建

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在项目设置中，您可以开启每当触发告警时[自动创建事件](alerts.md#trigger-actions-from-alerts)。

<a id="using-the-pagerduty-webhook"></a>

### 使用 PagerDuty webhook

您可以设置 PagerDuty webhook，为每个 PagerDuty 事件自动创建一个极狐GitLab 事件。此配置需要您在 PagerDuty 和极狐GitLab 中均进行更改。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

要设置 PagerDuty webhook：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **监控**。
1. 展开**事件**。
1. 选择 **PagerDuty 集成**选项卡。
1. 开启**活跃**开关。
1. 选择**保存集成**。
1. 复制 **Webhook URL**的值，以便在后续步骤中使用。
1. 要将 webhook URL 添加到 PagerDuty webhook 集成，请按照 [PagerDuty 文档](https://support.pagerduty.com/main/docs/webhooks#manage-v3-webhook-subscriptions)中描述的步骤操作。

要确认集成成功，请从 PagerDuty 触发一个测试事件，检查是否会根据该事件创建一个极狐GitLab 事件。

<a id="view-a-list-of-incidents"></a>

## 查看事件列表

要查看[事件](incidents.md#incidents-list)列表：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**监控** > **事件**。

要查看事件的[详情页面](incidents.md#incident-details)，请从列表中选择该事件。

<a id="who-can-view-an-incident"></a>

### 谁可以查看事件

您能否查看事件取决于[项目可见性级别](../../user/public_access.md)以及事件的机密性状态：

- 公开项目和非机密事件：任何人都可以查看该事件。
- 私有项目和非机密事件：您必须具有该项目的访客、计划者、报告者、开发者、维护者或所有者角色。
- 机密事件（无论项目可见性如何）：您必须具有该项目的计划者、报告者、开发者、维护者或所有者角色。

<a id="assign-to-a-user"></a>

## 指派给用户

将事件指派给正在积极响应的用户。

先决条件：

- 您必须具有该项目的报告者、开发者、维护者或所有者角色。

要指派用户：

1. 在事件中，在右侧边栏的**指派人**旁边，选择**编辑**。
1. 从下拉列表中，选择一个或[多个用户](../../user/project/issues/multiple_assignees_for_issues.md)添加为**指派人**。
1. 选择下拉列表外的任意区域。

<a id="change-severity"></a>

## 更改严重性

有关可用严重性级别的完整说明，请参阅[事件列表](incidents.md#incidents-list)主题。

先决条件：

- 您必须具有该项目的报告者、开发者、维护者或所有者角色。

要更改事件的严重性：

1. 在事件中，在右侧边栏的**严重性**旁边，选择**编辑**。
1. 从下拉列表中，选择新的严重性。

您也可以使用 [`/severity` 快速操作](../../user/project/quick_actions.md#severity)更改严重性。

<a id="change-status"></a>

## 更改状态

先决条件：

- 您必须具有该项目的开发者、维护者或所有者角色。

要更改事件的状态：

1. 在事件中，在右侧边栏的**状态**旁边，选择**编辑**。
1. 从下拉列表中，选择新的严重性。

**已触发**是新事件的默认状态。

<a id="as-an-on-call-responder"></a>

### 作为值班响应者

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

值班响应者可以通过更改状态来响应[事件寻呼](paging.md#escalating-an-incident)。

更改状态会产生以下影响：

- 更改为**已确认**：根据项目的[升级策略](escalation_policies.md)限制值班寻呼。
- 更改为**已解决**：静默该事件的所有值班寻呼。
- 从**已解决**更改为**已触发**：重新开始该事件的升级。

对于[从告警创建的事件](#from-an-alert)，告警状态是独立的，不会随事件状态的变化而变化。

<a id="change-escalation-policy"></a>

## 更改升级策略

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 您必须具有该项目的开发者、维护者或所有者角色。

要更改事件的升级策略：

1. 在事件中，在右侧边栏的**升级策略**旁边，选择**编辑**。
1. 从下拉列表中，选择升级策略。

默认情况下，新事件不会选择升级策略。

选择升级策略会[将事件状态更改](#change-status)为**已触发**，并开始[将事件升级给值班响应者](paging.md#escalating-an-incident)。

对于[从告警创建的事件](#from-an-alert)，事件升级策略是独立的，可以更改。

<a id="close-an-incident"></a>

## 关闭事件

先决条件：

- 您必须具有该项目的报告者、开发者、维护者或所有者角色。

要关闭事件，请在右上角选择**事件操作**（{{< icon name="ellipsis_v" >}}），然后选择**关闭事件**。

当您关闭与[告警](alerts.md)关联的事件时，关联告警的状态会变为**已解决**。随后该告警的状态变更会记入您的名下。

<a id="automatically-close-incidents-via-recovery-alerts"></a>

### 通过恢复告警自动关闭事件

开启当极狐GitLab 收到来自 HTTP 或 Prometheus webhook 的恢复告警时自动关闭事件。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

要配置该设置：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **监控**。
1. 展开**事件**部分。
1. 选择**自动关闭关联事件**复选框。
1. 选择**保存更改**。

当极狐GitLab 收到[恢复告警](integrations.md#recovery-alerts)时，它会关闭关联的事件。此操作会作为系统评论记录在事件上，表明该事件
由极狐GitLab 告警机器人自动关闭。

<a id="delete-an-incident"></a>

## 删除事件

先决条件：

- 您必须具有项目的所有者角色。

要删除事件：

1. 在事件中，选择**事件操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择**删除事件**。

或者：

1. 在事件中，选择**编辑**。
1. 选择**删除事件**。

<a id="other-actions"></a>

## 其他操作

由于极狐GitLab 中的事件构建在[议题](../../user/project/issues/_index.md)之上，它们具有以下共同操作：

- [添加待办事项](../../user/todos.md#create-a-to-do-item)
- [添加标记](../../user/project/labels.md#assign-and-unassign-labels)
- [指派里程碑](../../user/project/milestones/_index.md#assign-a-milestone-to-an-item)
- [将事件设为机密](../../user/project/issues/confidential_issues.md)
- [设置截止日期](../../user/project/issues/due_dates.md)
- [切换通知](../../user/profile/notifications.md#subscribe-to-notifications-for-a-specific-issue-merge-request-or-epic)
- [跟踪花费的时间](../../user/project/time_tracking.md)
