---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 截止日期
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 17.7 中，设置截止日期所需的最低角色从报告者变更为计划者。

{{< /history >}}

在工作项中使用截止日期来跟踪截止时间，确保功能按时交付。

支持截止日期的工作项包括：

- [议题](_index.md)
- [史诗](../../group/epics/_index.md)
- [任务](../../tasks.md)
- [目标与关键结果](../../okrs.md)
- [事件](../../../operations/incident_management/incidents.md)

在未关闭的工作项截止日期的前一天，会向所有参与者发送邮件通知。
<!-- 有关议题截止时间来源，请参阅 <https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/initializers/1_settings.rb> 中的 'issue_due_scheduler_worker' -->
通知会在服务器时区（对于 JihuLab.com 为 UTC）的 00:50 发送，针对所有截止日期为下一个自然日的未关闭工作项。

截止日期也会显示在你的 [待办事项](../../todos.md) 中。

<a id="view-issues-with-due-dates"></a>

## 查看带截止日期的议题

你可以在 **工作项** 页面查看议题及其截止日期。
如果议题包含截止日期，它会显示在议题标题下方：

![一个带有 2024 年截止日期的议题。](img/overdue_issue_v17_9.png)

过去的截止日期会以红色图标（{{< icon name="calendar-overdue" >}}）显示。

要在项目中查看并排序包含截止日期的议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 进行筛选。
1. 要按截止日期排序，选择当前的排序方式，然后选择 **截止日期**。
1. 可选。要反转排序顺序，选择 **排序方向**（{{< icon name="sort-lowest" >}}）。

<a id="set-a-due-date-for-an-issue"></a>

## 为议题设置截止日期

所有有权查看议题的用户都可以看到其截止日期。

<a id="when-creating-an-issue"></a>

### 创建议题时

如果你具有计划者、报告者、开发者、维护者或所有者角色，在创建议题时，选择 **截止日期** 以显示日历。
此日期使用服务器时区，而非当前用户的时区。

要移除日期，选中日期文本，然后删除文本。

<a id="in-an-existing-issue"></a>

### 在已有议题中

前提条件：

- 你必须具有计划者、报告者、开发者、维护者或所有者角色。

操作步骤：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 进行筛选，并选择你的议题。
1. 在右侧边栏的 **日期** 部分，选择 **编辑**。
1. 选择你想要的日期，然后选择 **应用** 以保存更改。

<a id="with-a-quick-action"></a>

### 使用快速操作

在议题的描述或评论中使用快速操作来设置截止日期：

- [`/due`](../quick_actions.md#due)：设置截止日期。
- [`/remove_due_date`](../quick_actions.md#remove_due_date)：移除已有的截止日期。

<a id="export-issue-due-dates-to-a-calendar"></a>

## 将议题截止日期导出到日历

带截止日期的议题也可以导出为 iCalendar 订阅源。可以将该订阅源的 URL 添加到日历应用中。

- **项目工作项** 页面
- **群组工作项** 页面

1. 前往包含你想要订阅的议题列表的页面。
   例如：

   - [分配给你的议题](managing_issues.md#view-all-issues-assigned-to-you)
   - [特定项目中的议题](managing_issues.md#issue-list)
   - [群组中](../../group/_index.md) 所有项目的议题

1. 在右侧，从 **操作**（{{< icon name="ellipsis_v" >}}）下拉列表中，选择 **订阅日历** 以显示 `.ics` 文件。
1. 复制页面的完整链接（包括完整的查询字符串），并在你偏好的日历应用中使用它。