---
stage: None - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
group: Unassigned - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Send email notifications to all users or specific groups and projects.
title: 来自极狐GitLab 的邮件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理员可以给所有用户，或所选群组或项目的用户发送邮件。用户将在其主邮箱地址收到邮件。

您可以使用此功能通知用户：

- 关于新项目、新功能或新产品发布。
- 关于新部署，或预计的停机时间。

有关来自极狐GitLab 的邮件通知信息，请阅读 [极狐GitLab 通知邮件](../user/profile/notifications.md)。

<a id="sending-emails-to-users-from-gitlab"></a>

## 从极狐GitLab 向用户发送邮件

您可以向所有用户发送邮件通知，或仅向特定群组或项目中的用户发送。您可以每 10 分钟发送一次邮件通知。

发送邮件：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在右上角，**新建用户** 按钮旁边，选择 **向用户发送邮件** ({{< icon name="mail" >}})。
1. 填写字段。邮件正文仅支持纯文本，不支持 HTML、Markdown 或其他富文本格式。
1. 从 **选择群组或项目** 下拉列表中，选择收件人。
1. 选择 **发送消息**。

<a id="unsubscribing-from-emails"></a>

## 取消订阅邮件

用户可以通过点击邮件中的取消订阅链接，选择取消接收来自极狐GitLab 的邮件。为保持此功能的简洁性，取消订阅操作无需认证。

取消订阅后，用户会收到一封确认取消订阅的邮件通知。提供取消订阅选项的端点受到速率限制。