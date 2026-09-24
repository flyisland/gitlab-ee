---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Telegram
description: "配置 Telegram 集成，以便在 Telegram 聊天或频道中接收来自极狐GitLab 的通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以配置极狐GitLab，将通知发送到 Telegram 聊天或频道。
要设置 Telegram 集成，您必须：

1. [创建 Telegram 机器人](#create-a-telegram-bot)。
1. [配置 Telegram 机器人](#configure-the-telegram-bot)。
1. [在极狐GitLab 中设置 Telegram 集成](#set-up-the-telegram-integration-in-gitlab)。

<a id="create-a-telegram-bot"></a>

## 创建 Telegram 机器人

要在 Telegram 中创建机器人：

1. 与 `@BotFather` 开始新聊天。
1. 按照 Telegram 文档中的说明[创建新机器人](https://core.telegram.org/bots/features#creating-a-new-bot)。

创建机器人时，`BotFather` 会为您提供 API 令牌。请妥善保管此令牌，因为您需要使用它在 Telegram 中验证机器人身份。

<a id="configure-the-telegram-bot"></a>

## 配置 Telegram 机器人

要在 Telegram 中配置机器人：

1. 将机器人添加为新频道或现有频道的管理员。
1. 为机器人分配 `Post Messages` 权限以接收事件。
1. 为频道创建标识符。
   - 对于公共频道，输入公共链接并复制频道标识符（例如，`https://t.me/MY_IDENTIFIER`）。
   - 对于私有频道，使用您的 API 令牌调用 [`getUpdates`](https://telegram-bot-sdk.readme.io/reference/getupdates) 方法并复制频道标识符（例如，`-2241293890657`）。

<a id="set-up-the-telegram-integration-in-gitlab"></a>

## 在极狐GitLab 中设置 Telegram 集成

先决条件：

- 具有管理员访问权限，以便为实例启用集成。
- 具有所有者角色，以便为群组启用集成。
- 具有维护者或所有者角色，以便为项目启用集成。

将机器人邀请到 Telegram 频道后，您可以配置极狐GitLab 发送通知：

1. 要启用集成：
   - 对于您的群组或项目：
     1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
     1. 选择 **设置** > **集成**。
   - 对于您的实例：
     1. 在右上角，选择 **管理员**。
     1. 选择 **设置** > **集成**。
1. 选择 **Telegram**。
1. 在 **启用集成** 下，选中 **启用** 复选框。
1. 可选。在 **主机名** 中，输入您的[本地机器人 API 服务器](https://core.telegram.org/bots/api#using-a-local-bot-api-server)的主机名。
1. 在 **令牌** 中，[粘贴来自 Telegram 机器人的令牌值](#create-a-telegram-bot)。
1. 在 **触发器** 部分，选中您希望在 Telegram 中接收的极狐GitLab 事件的复选框。
1. 在 **通知设置** 部分：
   - 在 **频道标识符** 中，[粘贴 Telegram 频道标识符](#configure-the-telegram-bot)。
   - 可选。在 **消息线程 ID** 中，粘贴目标消息线程（论坛超级群组中的主题）的唯一标识符。
   - 可选。选中 **仅通知失败的流水线** 复选框，
     以仅接收失败流水线的通知。
   - 可选。选中 **仅在状态更改时通知** 复选框，
     以仅在引用的流水线状态更改时接收通知。
   - 可选。从 **要发送通知的分支** 下拉列表中，
     选择您希望接收通知的分支。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

现在，Telegram 频道可以接收所有选定的极狐GitLab 事件。
