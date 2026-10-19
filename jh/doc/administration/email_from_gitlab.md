---
stage: Facilitated functionality
group: Facilitated functionality
info: For more information, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
description: 向所有用户或特定群组和项目发送电子邮件通知。
gitlab_dedicated: yes
title: 来自极狐GitLab 的电子邮件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理员可以向实例上的所有人类用户，或特定群组或项目中的用户发送电子邮件通知。用户将在其主电子邮件地址收到该电子邮件。

您可以使用此功能向用户通知：

- 关于新项目、新功能或新产品发布。
- 关于新部署，或预计将发生停机。

有关源自极狐GitLab 的电子邮件通知的信息，请阅读[极狐GitLab 通知电子邮件](../user/profile/notifications.md)。

<a id="sending-emails-to-users-from-gitlab"></a>

## 从极狐GitLab 向用户发送电子邮件

您可以向所有用户发送电子邮件通知，也可以仅向特定群组或项目中的用户发送。每 10 分钟可以发送一次电子邮件通知。

要发送电子邮件：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在右上角，**新建用户**按钮旁边，选择**向用户发送电子邮件**（{{< icon name="mail" >}}）。
1. 填写各字段。电子邮件正文仅支持纯文本，不支持 HTML、Markdown 或其他富文本格式。
1. 从**选择群组或项目**下拉列表中，选择收件人。
1. 选择**发送消息**。

<a id="unsubscribing-from-emails"></a>

## 退订电子邮件

用户可以通过电子邮件中的退订链接，选择退订来自极狐GitLab 的电子邮件。为保持此功能简单易用，退订无需身份验证。

退订后，用户会收到一封电子邮件通知，告知退订已完成。提供退订选项的端点受速率限制。
