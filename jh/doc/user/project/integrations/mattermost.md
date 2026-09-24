---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Mattermost 通知
description: "配置 Mattermost 通知，以便在 Mattermost 频道中接收来自极狐GitLab 的通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Mattermost 通知集成，将极狐GitLab 事件（例如 `issue created`）的通知发送到 Mattermost。您必须同时配置 [Mattermost](#configure-mattermost-to-receive-gitlab-notifications) 和 [极狐GitLab](#configure-gitlab-to-send-notifications-to-mattermost)。

您还可以使用 [Mattermost 斜杠命令](mattermost_slash_commands.md) 在 Mattermost 中控制极狐GitLab。

<a id="configure-mattermost-to-receive-gitlab-notifications"></a>

## 配置 Mattermost 以接收极狐GitLab 通知

要使用 Mattermost 集成，您必须在 Mattermost 中创建传入 Webhook 集成：

1. 登录您的 Mattermost 实例。
1. [启用传入 Webhook](https://docs.mattermost.com/configure/integrations-configuration-settings.html#enable-incoming-webhooks)。
1. [添加传入 Webhook](https://developers.mattermost.com/integrate/webhooks/incoming/#create-an-incoming-webhook)。
1. 选择显示名称、描述和频道。这些可以在极狐GitLab 中覆盖。
1. 保存并复制极狐GitLab 所需的 **Webhook URL**。

您的 Mattermost 实例可能会阻止传入 Webhook。请咨询您的 Mattermost 管理员，在以下位置启用它们：

- 在 Mattermost 5.12 及更高版本中：**Mattermost 系统控制台** > **集成** > **集成管理**。
- 在 Mattermost 5.11 及更早版本中：**Mattermost 系统控制台** > **集成** > **自定义集成**。

显示名称覆盖默认处于关闭状态。请咨询您的管理员，在同一部分中将其启用。

<a id="configure-gitlab-to-send-notifications-to-mattermost"></a>

## 配置极狐GitLab 以向 Mattermost 发送通知

在 Mattermost 实例设置好传入 Webhook 后，您可以设置极狐GitLab 以发送通知：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Mattermost 通知**。
1. 选择要为其生成通知的极狐GitLab 事件。对于您选择的每个事件，输入最多 10 个要接收通知的 Mattermost 频道。您无需添加井号（`#`）。
1. 填写集成配置：

   - **Webhook**：Mattermost 上的传入 Webhook URL，类似于 `http://mattermost.example/hooks/5xo…`。
   - **用户名**：可选。发送到 Mattermost 的消息中显示的用户名。要更改机器人的用户名，请提供一个值。
   - **仅通知失败的流水线**：如果您选择了 **流水线** 事件，并且只想接收有关失败流水线的通知。
   - **仅在状态更改时通知**：如果您选择了 **流水线** 事件，并且只想在引用的流水线状态更改时接收通知。
   - **要发送通知的分支**：要发送通知的分支。
   - **要通知的标记**：可选。触发通知的议题或合并请求所需的标记。留空以通知所有议题和合并请求。
   - **要通知的标记行为**：当您使用 **要通知的标记** 过滤器时，当议题或合并请求包含过滤器中指定的任何标记时，会发送消息。您也可以选择仅当议题或合并请求包含过滤器中定义的所有标记时才触发消息。
