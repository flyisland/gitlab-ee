---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Discord 通知
description: "配置 Discord 通知集成，以便在 Discord 频道中接收来自极狐GitLab 的通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Discord 通知集成会将极狐GitLab 的事件通知发送到创建 Webhook 时指定的频道。

要将极狐GitLab 事件通知发送到 Discord 频道，请[在 Discord 中创建 Webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)，
并在极狐GitLab 中进行配置。

<a id="create-webhook"></a>

## 创建 Webhook

1. 打开您希望接收极狐GitLab 事件通知的 Discord 频道。
1. 在频道菜单中，选择**编辑频道**。
1. 选择**集成**。
1. 如果尚无任何 Webhook，请选择**创建 Webhook**。否则，请选择**查看 Webhook**，然后选择**新建 Webhook**。
1. 输入用于发布消息的机器人名称。
1. 可选。编辑头像。
1. 从 **WEBHOOK URL** 文本框中复制 URL。
1. 选择**保存**。

<a id="configure-created-webhook-in-gitlab"></a>

## 在极狐GitLab 中配置已创建的 Webhook

先决条件：

- 您必须使用 Discord URL（`https://discord.com/api/webhooks/webhook-snowflake/webhook-token`）。

在 Discord 频道中创建 Webhook URL 后，您可以在极狐GitLab 中设置 Discord 通知集成。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Discord 通知**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 在 **Webhook** 文本框中，粘贴您[之前创建](#create-webhook)的 Webhook URL。
1. 选中与您希望向 Discord 发送通知的极狐GitLab 事件对应的复选框。
1. 可选。对于您选中的每个复选框，输入您已[配置](#create-webhook)的另一个 Discord Webhook URL，
   以覆盖 **Webhook** 文本框中的 URL。
1. 配置其余选项，然后选择**保存更改**。

您为其创建 Webhook 的 Discord 频道现在会收到已配置的极狐GitLab 事件通知。
