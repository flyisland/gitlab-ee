---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "与极狐GitLab 工作项和合并请求交互过的用户，包括作者、指派人，以及发表评论、添加表情回应或被提及的用户。"
title: 参与者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

参与者是与工作项和合并请求交互过的用户。他们包括作者、指派人、审核人（针对合并请求），以及发表评论、添加表情回应或在评论或描述中被提及的用户。

参与者适用于工作项（如议题、任务、史诗）和合并请求。

<a id="view-participants"></a>

## 查看参与者

<a id="for-work-items"></a>

### 对于工作项

要查看工作项的参与者：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
1. 在左侧边栏中，选择**计划** > **工作项**，然后选择您的工作项。
1. 在右侧边栏的**参与者**部分，查看参与该工作项的所有用户。

<a id="for-merge-requests"></a>

### 对于合并请求

要查看合并请求中的参与者：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**代码** > **合并请求**，找到您的合并请求。
1. 在右侧边栏的**参与者**部分，查看参与该合并请求的所有用户。

<a id="participant-visibility-and-permissions"></a>

## 参与者可见性和权限

参与者列表仅显示拥有访问该工作项或合并请求所需权限的用户：

- **基本要求** - 用户需要拥有该工作项或合并请求的读取权限，才能显示为参与者。
- **内部评论** - 在内部评论中被提及的用户，只有在拥有读取内部评论的权限时，才会显示为参与者。
- **提及会添加参与者** - 通过 `@username` 或群组提及（如 `@team-name`）被提及的用户，如果拥有该工作项或合并请求的访问权限，就会被添加为参与者。

> [!warning]
> 群组提及（如 `@team-name`）会将所有直接群组成员添加为参与者。
> 在常见词前使用 `@` 时请务必小心，因为这可能会无意中提及
> 现有的群组。

<a id="participants-and-email-notifications"></a>

## 参与者与电子邮件通知

成为工作项或合并请求的参与者会影响您的电子邮件通知设置。了解这种关系有助于您有效地管理通知偏好。

参与者状态与通知的关系：

- 自动参与：当您在工作项或合并请求中发表评论、编辑或被提及时，
  您会自动成为参与者。
  这可能会根据您的通知级别设置触发电子邮件通知。
- 通知级别：您的[通知级别](profile/notifications.md#notification-levels)
  决定哪些活动会生成电子邮件通知。
- 已订阅的参与者：即使您尚未参与，也可以手动
  [订阅通知](profile/notifications.md#subscribe-to-notifications-for-a-specific-issue-merge-request-or-epic)
  以接收某个工作项或合并请求的通知。
  这会将您添加到参与者列表，并根据您的默认通知级别开启通知。
- 提及通知：当有人在评论或描述中通过 `@username` 提及您时，无论您的通知级别设置如何，您都会收到通知并成为参与者。
- 机密内容：对于机密工作项，只有拥有相应权限的用户才会显示为参与者并接收通知。
  更多信息，请参阅[参与者可见性和权限](#participant-visibility-and-permissions)。

有关管理通知偏好的更多信息，请参阅[通知电子邮件](profile/notifications.md)
