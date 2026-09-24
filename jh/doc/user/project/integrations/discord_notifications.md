---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Discord 通知
description: 配置 Discord 通知集成，以在 Discord 频道中接收来自极狐GitLab 的通知。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Discord 通知集成会将来自极狐GitLab 的事件通知发送到为其创建 Webhook 的 Discord 频道。

若要将极狐GitLab 事件通知发送到 Discord 频道，[在 Discord 中创建 Webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) 并在极狐GitLab 中对其进行配置。

<a id="create-webhook"></a>

## 创建 Webhook

1. 打开你想接收极狐GitLab 事件通知的 Discord 频道。
1. 从频道菜单中，选择 **编辑频道**。
1. 选择 **集成**。
1. 如果当前没有 Webhook，请选择 **创建 Webhook**。否则，选择 **查看 Webhooks**，然后选择 **新建 Webhook**。
1. 输入用于发布消息的机器人名称。
1. 可选。编辑头像。
1. 从 **WEBHOOK URL** 字段中复制 URL。
1. 选择 **保存**。

<a id="configure-created-webhook-in-gitlab"></a>

## 在极狐GitLab 中配置已创建的 Webhook

{{< history >}}

- 事件 Webhook 覆盖在极狐GitLab 16.3 中引入。
- Webhook URL 验证在极狐GitLab 18.0 中引入。

{{< /history >}}

前提条件：

- 你必须使用 Discord URL (`https://discord.com/api/webhooks/webhook-snowflake/webhook-token`)。

在 Discord 频道中创建了 Webhook URL 后，你可以在极狐GitLab 中设置 Discord 通知集成。

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择 **Discord 通知**。
1. 确保 **活跃** 开关已启用。
1. 将你[之前创建的](#create-webhook) Webhook URL 粘贴到 **Webhook** 字段中。
1. 勾选与你要向 Discord 发送通知的极狐GitLab 事件对应的复选框。
1. 可选地，对于你所选的每个复选框，输入一个新的 Discord Webhook URL，该 URL 覆盖 **Webhook** 字段中的默认值，且你已[配置](#create-webhook)。
1. 配置其余选项，并选择 **保存更改** 按钮。

你为其创建 Webhook 的 Discord 频道现在会收到已配置的极狐GitLab 事件的通知。