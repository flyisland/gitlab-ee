---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: "Microsoft Teams 通知"
description: "Configure the Microsoft Teams integration to receive notifications from极狐GitLab in Microsoft Teams."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以将 Microsoft Teams 通知与极狐GitLab 集成，并在 Microsoft Teams 中显示有关极狐GitLab 项目的通知。要集成这两个服务，你必须：

1. [配置 Microsoft Teams](#configure-microsoft-teams) 来启用一个 webhook 以监听变更。
2. [配置你的极狐GitLab 项目](#configure-your-gitlab-project) 以推送通知到 Microsoft Teams webhook。

<a id="configure-microsoft-teams"></a>

## 配置 Microsoft Teams

> [!warning]
> Microsoft [宣布](https://devblogs.microsoft.com/microsoft365dev/retirement-of-office-365-connectors-within-microsoft-teams/) 了 Microsoft Teams 中 Office 365 连接器的停用。新的集成必须使用 Power Automate 工作流。现有的基于连接器的集成必须在 2025 年 12 月之前迁移。

要配置 Microsoft Teams 以接收来自极狐GitLab 的通知，你必须有一个工作流，该工作流接受极狐GitLab webhook 载荷并向你的频道发布消息。你可以创建：

- 使用模板的 Power Automate 工作流。
- 自定义工作流。

<a id="create-a-power-automate-workflow"></a>

### 创建一个 Power Automate 工作流

1. 在 Microsoft Teams 中，在你想接收通知的聊天旁边，选择 **更多聊天选项** ({{< icon name="ellipsis_h" >}})。
1. 选择 **工作流**。
1. 搜索并选择 **发送 webhook 警报至频道** 工作流模板。
1. 在 **参数** 下，输入团队和频道，然后选择 **保存**。
1. 工作流创建后，在工作流对话框中，选择 **复制 webhook 链接**。
1. 复制提供的 webhook URL。你将使用此 webhook URL 来配置极狐GitLab。
1. 关闭工作流对话框。

<a id="modify-the-workflow-to-accept-gitlab-payloads"></a>

#### 修改工作流以接受极狐GitLab 载荷

默认工作流模板期望 Adaptive Card 格式，但极狐GitLab 发送的是 Office 365 连接器卡格式。要修改工作流：

1. 转到 Power Automate 并使用你的 Microsoft 帐户登录。
1. 选择 **我的流** 并找到你创建的工作流。
1. 选择 **编辑** 以修改工作流。
1. 选择现有的 **在聊天或频道中发布卡片** 操作并将其删除。
1. 选择 **添加操作** 并搜索 **在聊天或频道中发布消息**。
1. 配置操作：
   - **发布身份**：Flow bot
   - **发布位置**：Channel
   - **团队**：选择你的团队
   - **频道**：选择你的频道
   - **消息**：在文本框的右侧，选择 **插入表达式** 并输入 `triggerOutputs()?['body']?['attachments'][0]?['content']`。选择 **添加**。
1. 选择 **保存**。

<a id="create-a-custom-workflow"></a>

### 创建自定义工作流

要对消息格式有更多控制，创建一个自定义工作流：

1. 转到 Power Automate，选择 **创建** > **即时云端流**。
1. 命名你的工作流，并选择 **当收到 HTTP 请求时** 作为触发器，然后选择 **创建**。
1. 选择 **添加操作** 并搜索 **在聊天或频道中发布消息** (Microsoft Teams)。
1. 在触发器配置中，将 JSON 架构保留为空以接受任何载荷。
1. 配置操作：
   - **发布身份**：Flow bot
   - **发布位置**：Channel
   - **团队**：选择你的团队
   - **频道**：选择你的频道
   - **消息**：在文本框的右侧，选择 **插入表达式** 并输入 `triggerOutputs()?['body']?['attachments'][0]?['content']`。选择 **添加**。
1. 选择 **保存**。
1. 在工作流中，选择 **手动** 触发器。从触发器中复制 **HTTP URL**。你将使用此 URL 配置极狐GitLab。

<a id="configure-your-gitlab-project"></a>

## 配置你的极狐GitLab 项目

在配置 Microsoft Teams 以接收通知后，你必须配置极狐GitLab 以发送通知：

1. 以管理员身份登录极狐GitLab。
1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择 **Microsoft Teams 通知**。
1. 要启用集成，选择 **激活**。
1. 在 **触发器** 部分，选中每个事件旁边的复选框以启用它：
   - 推送
   - 议题
   - 机密议题
   - 合并请求
   - 备注
   - 机密备注
   - 标签推送
   - 流水线
   - Wiki 页面
1. 在 **Webhook** 中，粘贴你在创建 Power Automate 或自定义工作流时复制的 URL。
1. 可选。如果启用了流水线触发器，选中 **仅在流水线损坏时通知** 复选框以仅在流水线损坏时推送通知。
1. 可选。如果启用了流水线触发器，选中 **仅在状态变更时通知** 复选框以仅在引用的流水线状态变更时发送通知。
1. 选择你想要发送通知的分支。
1. 选择 **保存更改**。

