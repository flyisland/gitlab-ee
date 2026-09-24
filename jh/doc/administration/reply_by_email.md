---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过邮件回复
description: 配置议题和合并请求的评论通过邮件回复。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 可以设置为允许用户通过回复通知邮件来评论议题和合并请求。

<a id="prerequisite"></a>

## 前提条件

确保已设置[接收邮件](incoming_email.md)。

<a id="how-replying-by-email-works"></a>

## 邮件回复的工作原理

邮件回复分为三个步骤：

1. 极狐GitLab 发送一封通知邮件。
1. 你回复该通知邮件。
1. 极狐GitLab 收到你对通知邮件的回复。

<a id="gitlab-sends-a-notification-email"></a>

### 极狐GitLab 发送通知邮件

当极狐GitLab 发送通知邮件时：

- `Reply-To` 头被设置为已配置的邮件地址。
- 如果该地址包含 `%{key}` 占位符，它会被替换为一个特定的回复密钥。
- 该回复密钥被添加到 `References` 头。

<a id="you-reply-to-the-notification-email"></a>

### 你回复通知邮件

当你回复通知邮件时，你的邮件客户端会：

- 将邮件发送至从通知邮件中获取的 `Reply-To` 地址。
- 将 `In-Reply-To` 头设置为通知邮件中 `Message-ID` 头的值。
- 将 `References` 头设置为 `Message-ID` 的值加上通知邮件中 `References` 头的值。

<a id="gitlab-receives-your-reply-to-the-notification-email"></a>

### 极狐GitLab 收到你对通知邮件的回复

当极狐GitLab 收到你的回复时，它会在[接受的标头列表](incoming_email.md#accepted-headers)中查找回复密钥。

如果找到回复密钥，你的回复将以评论的形式显示在相关的议题、合并请求、提交或其他触发通知的条目上。

有关 `Message-ID`、`In-Reply-To` 和 `References` 头的更多信息，请参见 [RFC 5322](https://www.rfc-editor.org/rfc/rfc5322#section-3.6.4)。

<a id="retention-policy-for-notifications"></a>

## 通知的保留策略

部分收件邮件功能需要极狐GitLab 存储有关已发送通知邮件的元数据。我们会将这些记录保留两年。如果某封通知邮件已超过两年，则你无法再通过回复该邮件进行评论。这包括通过邮件回复议题和合并请求的讨论。

