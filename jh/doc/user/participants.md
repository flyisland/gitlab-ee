---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "Users who interacted with GitLab work items and merge requests including authors, assignees, and users who commented, added reactions, or were mentioned."
title: 参与者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

参与者是与工作项和合并请求进行过交互的用户。
他们包括作者、指派人、审核人（针对合并请求），以及在评论或描述中发表过评论、
添加了表情符号反应或被提及的用户。

参与者可用于工作项（如议题、任务、史诗）和合并请求。

<a id="view-participants"></a>

## 查看参与者

<a id="for-work-items"></a>

### 对于工作项

要查看工作项的参与者：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后选择您的工作项。
1. 在右侧边栏的 **参与者** 部分，查看所有参与了该工作项的用户。

<a id="for-merge-requests"></a>

### 对于合并请求

要查看合并请求的参与者：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求** 并找到您的合并请求。
1. 在右侧边栏的 **参与者** 部分，查看所有参与了该合并请求的用户。

<a id="participant-visibility-and-permissions"></a>

## 参与者可见性和权限

参与者列表仅显示具有访问工作项或合并请求所需权限的用户：

- **基本要求** - 用户需要对工作项或合并请求具有读取权限才能显示为参与者。
- **内部评论** - 在内部评论中被提及的用户仅当具有读取内部评论的权限时才会显示为参与者。
- **提及添加参与者** - 通过 `@用户名` 提及的用户或像 `@团队名称` 的群组提及，如果他们具有工作项或合并请求访问权限，则会被添加为参与者。

> [!warning]
> 群组提及（如 `@团队名称`）会将所有直接群组成员添加为参与者。请谨慎对常见词使用 `@`，因为这可能会无意中提及现有群组。

<a id="participants-and-email-notifications"></a>

## 参与者与邮件通知

成为工作项或合并请求的参与者会影响您的电子邮件通知设置。
了解这种关系有助于您有效管理通知偏好。

参与者状态与通知的关系：

- 自动参与：当您在工作项或合并请求中发表评论、编辑或被提及时，您会自动成为参与者。这可能会根据您的通知级别设置触发电子邮件通知。
- 通知级别：您的 [通知级别](profile/notifications.md#notification-levels) 决定了哪些活动会生成电子邮件通知。
- 订阅参与者：即使您尚未参与，也可以手动为工作项或合并请求 [订阅通知](profile/notifications.md#subscribe-to-notifications-for-a-specific-issue-merge-request-or-epic)。这会将您添加到参与者列表，并根据您的默认通知级别开启通知。
- 提及通知：当有人在评论或描述中用 `@用户名` 提及您时，无论您的通知级别设置如何，您都会收到通知并成为参与者。
- 机密内容：对于机密工作项，只有具有适当权限的用户才会显示为参与者并接收通知。更多信息，请参阅 [参与者可见性和权限](#participant-visibility-and-permissions)。

有关管理通知偏好的更多信息，请参阅 [通知电子邮件](profile/notifications.md)