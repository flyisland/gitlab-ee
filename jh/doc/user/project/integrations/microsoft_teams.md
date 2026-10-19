---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Microsoft Teams 通知
description: "配置 Microsoft Teams 集成，以在 Microsoft Teams 中接收来自极狐GitLab 的通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将 Microsoft Teams 通知与极狐GitLab 集成，并在 Microsoft Teams 中显示有关极狐GitLab 项目的通知。要集成这些服务，您必须：

1. [配置 Microsoft Teams](#configure-microsoft-teams)，添加一个用于监听变更的 webhook。
1. [配置您的极狐GitLab 项目](#configure-your-gitlab-project)，将通知推送到 Microsoft Teams webhook。

<a id="configure-microsoft-teams"></a>

## 配置 Microsoft Teams

> [!warning]
> Microsoft [宣布](https://devblogs.microsoft.com/microsoft365dev/retirement-of-office-365-connectors-within-microsoft-teams/)停用 Microsoft Teams 中的 Office 365 连接器。
> 新集成必须使用 Power Automate 工作流。现有的基于连接器的集成必须在 2025 年 12 月之前完成迁移。

要配置 Microsoft Teams 以接收来自极狐GitLab 的通知，您必须有一个能够接收极狐GitLab webhook 负载并将消息发布到您频道的工作流。您可以创建：

- 使用模板的 Power Automate 工作流。
- 自定义工作流。

<a id="create-a-power-automate-workflow"></a>

### 创建 Power Automate 工作流

1. 在 Microsoft Teams 中，在您希望接收通知的聊天旁边，选择**更多聊天选项**（{{< icon name="ellipsis_h" >}}）。
1. 选择**工作流**。
1. 搜索并选择 **发送 webhook 警报至频道** 工作流模板。
1. 在**参数**下，输入团队和频道，然后选择**保存**。
1. 创建工作流后，在“工作流”对话框中，选择**复制 webhook 链接**。
1. 复制提供的 webhook URL。您将使用此 webhook URL 配置极狐GitLab。
1. 关闭“工作流”对话框。

<a id="modify-the-workflow-to-accept-gitlab-payloads"></a>

#### 修改工作流以接收极狐GitLab 负载

默认工作流模板要求使用自适应卡片格式，但极狐GitLab 发送的是 Office 365 连接器卡片格式。要修改工作流：

1. 转到 Power Automate，并使用您的 Microsoft 账户登录。
1. 选择**我的流**，找到您创建的工作流。
1. 选择**编辑**以修改工作流。
1. 选择现有的**在聊天或频道中发布卡片**操作并将其删除。
1. 选择**添加操作**，然后搜索**在聊天或频道中发布消息**。
1. 配置该操作：
   - **发布身份**：Flow bot
   - **发布位置**：频道
   - **团队**：选择您的团队
   - **频道**：选择您的频道
   - **消息**：在文本框右侧，选择**插入表达式**，然后输入 `triggerOutputs()?['body']?['attachments'][0]?['content']`。选择**添加**。
1. 选择**保存**。

<a id="create-a-custom-workflow"></a>

### 创建自定义工作流

如需对消息格式进行更多控制，请创建自定义工作流：

1. 转到 Power Automate，然后选择**创建** > **即时云端流**。
1. 为工作流命名，并选择**收到 HTTP 请求时**作为触发器，然后选择**创建**。
1. 选择**添加操作**，然后搜索**在聊天或频道中发布消息**（Microsoft Teams）。
1. 在触发器配置中，将 JSON 架构留空以接收任何负载。
1. 配置该操作：
   - **发布身份**：Flow bot
   - **发布位置**：频道
   - **团队**：选择您的团队
   - **频道**：选择您的频道
   - **消息**：在文本框右侧，选择**插入表达式**，然后输入 `triggerOutputs()?['body']?['attachments'][0]?['content']`。选择**添加**。
1. 选择**保存**。
1. 在工作流中，选择**手动**触发器。从触发器中复制 **HTTP URL**。您将使用此 URL 配置极狐GitLab。

<a id="configure-your-gitlab-project"></a>

## 配置您的极狐GitLab 项目

配置 Microsoft Teams 以接收通知后，您必须配置极狐GitLab 以发送通知：

1. 以管理员身份登录极狐GitLab。
1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Microsoft Teams 通知**。
1. 要开启该集成，请选择**活跃**。
1. 在**触发器**部分，选中您需要的每个事件旁边的复选框：
   - 推送
   - 议题
   - 机密议题
   - 合并请求
   - 评论
   - 机密评论
   - 标签推送
   - 流水线
   - Wiki 页面
1. 在 **Webhook**中，粘贴您在创建 Power Automate 或自定义工作流时复制的 URL。
1. 可选。如果您选择流水线触发器，请选中**仅通知失败的流水线**复选框，以便仅在流水线失败时推送通知。
1. 可选。如果您选择流水线触发器，请选中**仅在状态变更时通知**复选框，以便仅在 ref 的流水线状态发生变化时发送通知。
1. 选择您要为其发送通知的分支。
1. 选择**保存更改**。
