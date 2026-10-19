---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过电子邮件回复
description: 配置通过电子邮件回复议题和合并请求评论的功能。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

可以设置极狐GitLab，让用户通过回复通知电子邮件来评论议题和合并请求。

<a id="prerequisite"></a>

## 先决条件

确保已设置[接收电子邮件](incoming_email.md)。

<a id="how-replying-by-email-works"></a>

## 通过电子邮件回复的工作方式

通过电子邮件回复分为三个步骤：

1. 极狐GitLab 发送通知电子邮件。
1. 您回复该通知电子邮件。
1. 极狐GitLab 收到您对通知电子邮件的回复。

<a id="gitlab-sends-a-notification-email"></a>

### 极狐GitLab 发送通知电子邮件

当极狐GitLab 发送通知电子邮件时：

- `Reply-To` 标头设置为您配置的电子邮件地址。
- 如果该地址包含 `%{key}` 占位符，则会替换为特定的回复密钥。
- 回复密钥会添加到 `References` 标头中。

<a id="you-reply-to-the-notification-email"></a>

### 您回复通知电子邮件

当您回复通知电子邮件时，您的电子邮件客户端会：

- 将电子邮件发送到从通知电子邮件中获取的 `Reply-To`地址。
- 将 `In-Reply-To` 标头设置为通知电子邮件中 `Message-ID` 标头的值。
- 将 `References` 标头设置为 `Message-ID`的值加上通知电子邮件的 `References` 标头的值。

<a id="gitlab-receives-your-reply-to-the-notification-email"></a>

### 极狐GitLab 收到您对通知电子邮件的回复

当极狐GitLab 收到您的回复时，它会在[接受的标头列表](incoming_email.md#accepted-headers)中查找回复密钥。

如果找到回复密钥，您的回复会作为评论显示在相关议题、合并请求、提交或其他触发该通知的条目上。

有关 `Message-ID`、`In-Reply-To` 和 `References` 标头的更多信息，请参阅 [RFC 5322](https://www.rfc-editor.org/rfc/rfc5322#section-3.6.4)。

<a id="retention-policy-for-notifications"></a>

## 通知的保留策略

某些接收电子邮件功能需要极狐GitLab 存储有关已发送电子邮件通知的元数据。这些记录会保留两年。如果电子邮件通知超过两年，您将无法通过电子邮件回复该通知。这包括通过电子邮件回复议题和合并请求讨论串。
