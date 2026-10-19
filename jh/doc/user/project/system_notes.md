---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 系统评论
description: 跟踪并查看工作项上由系统生成的活动评论。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

系统评论是简短的描述，帮助您了解极狐GitLab 对象生命周期中发生的事件历史，例如：

- [警报](../../operations/incident_management/alerts.md)。
- [设计](issues/design_management.md)。
- [议题](issues/_index.md)。
- [合并请求](merge_requests/_index.md)。
- [目标与关键成果](../okrs.md)（OKR）。
- [任务](../tasks.md)。

极狐GitLab 在系统评论中记录由 Git 或极狐GitLab 应用程序触发的事件信息。系统评论使用 `<Author> <action> <time ago>` 格式。

<a id="show-or-filter-system-notes"></a>

## 显示或筛选系统评论

默认情况下，系统评论不显示。显示时，按从最早到最新的顺序排列。如果您更改筛选或排序选项，您的选择会在各个部分中保留。对于除合并请求以外的所有条目类型，筛选选项包括：

- **显示所有活动**同时显示评论和历史。
- **仅显示评论**隐藏系统评论。
- **仅显示历史**隐藏用户评论。

合并请求提供更细粒度的筛选选项。

<a id="on-an-epic"></a>

### 在史诗上

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**计划** > **工作项**。
1. 在筛选栏中，选择筛选条件**类型**、运算符**是**和值**史诗**。
1. 找到您想要的史诗，然后选择其标题。
1. 转到**活动**部分。
1. 对于**排序或筛选**，选择**显示所有活动**。

<a id="on-an-issue"></a>

### 在议题上

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**计划** > **工作项**，然后按**类型** = **议题**筛选并选择您的议题。
1. 转到**活动**。
1. 对于**排序或筛选**，选择**显示所有活动**。

<a id="on-a-merge-request"></a>

### 在合并请求上

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **合并请求**，然后找到您的合并请求。
1. 转到**活动**。
1. 对于**排序或筛选**，选择**显示所有活动**以查看所有系统评论。
   要缩小返回的系统评论类型范围，请选择以下一项或多项：

   - **审批**
   - **指派人与审核人**
   - **评论**
   - **提交与分支**
   - **编辑**
   - **标记**
   - **锁定状态**
   - **提及**
   - **合并请求状态**
   - **跟踪**

<a id="privacy-considerations"></a>

## 隐私注意事项

您只能看到与您可访问的对象关联的系统评论。

例如，如果某人在其私有项目的议题中提及您的议题 111：

- 项目成员会在议题 111 中看到以下评论：`Alex Garcia mentioned in agarcia/private-project#222`。
- 非项目成员完全看不到该评论。
