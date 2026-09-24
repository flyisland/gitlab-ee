---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 系统记录
description: Track and view system-generated activity notes on work items.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

系统记录是简短的描述，帮助您了解极狐GitLab 对象生命周期中发生的事件的历史，例如：

- [告警](../../operations/incident_management/alerts.md)。
- [设计](issues/design_management.md)。
- [议题](issues/_index.md)。
- [合并请求](merge_requests/_index.md)。
- [目标与关键结果](../okrs.md)（OKR）。
- [任务](../tasks.md)。

极狐GitLab 会在系统记录中记录由 Git 或极狐GitLab 应用程序触发的事件信息。系统记录使用 `<作者> <操作> <时间之前>` 格式。

<a id="show-or-filter-system-notes"></a>

## 显示或过滤系统记录

默认情况下，系统记录不显示。当显示时，它们会按最旧优先的顺序显示。如果您更改了过滤器或排序选项，您的选择会在各个部分中被记住。对于除合并请求外的所有条目类型，过滤选项为：

- **显示所有活动** 同时显示评论和历史。
- **仅显示评论** 隐藏系统记录。
- **仅显示历史** 隐藏用户评论。

合并请求提供更细粒度的过滤选项。

<a id="on-an-epic"></a>

### 史诗

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏，选择 **计划** > **工作项**。
1. 在过滤器栏，选择过滤器 **类型**，运算符 **是**，值 **史诗**。
1. 确定您需要的史诗，并选择其标题。
1. 转到 **动态** 部分。
1. 对于 **排序或过滤**，选择 **显示所有活动**。

<a id="on-an-issue"></a>

### 议题

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏，选择 **计划** > **工作项**，然后按 **类型** = **议题** 进行过滤，并选择您的议题。
1. 转到 **动态**。
1. 对于 **排序或过滤**，选择 **显示所有活动**。

<a id="on-a-merge-request"></a>

### 合并请求

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏，选择 **代码** > **合并请求**，并找到您的合并请求。
1. 转到 **动态**。
1. 对于 **排序或过滤**，选择 **显示所有活动** 以查看所有系统记录。
   要缩小所返回的系统记录类型，请选择以下一项或多项：

   - **审批**
   - **指派人与审查者**
   - **评论**
   - **提交与分支**
   - **编辑**
   - **标签**
   - **锁定状态**
   - **提及**
   - **合并请求状态**
   - **跟踪**

<a id="privacy-considerations"></a>

## 隐私考虑

您只能看到链接到您可以访问的对象的系统记录。

例如，如果某人在其私有项目中的某个议题中提及了您的议题 111：

- 项目成员会在议题 111 中看到以下记录：`Alex Garcia 在 agarcia/private-project#222 中提及`。
- 非该项目成员则完全看不到该记录。