---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Google Chat
description: "配置 Google Chat 集成，以便在 Google Chat 空间中接收来自极狐GitLab 的通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在极狐GitLab 中配置项目，向 [Google Chat](https://chat.google.com/)中您选择的任意空间发送通知。

对于同一个极狐GitLab 对象（例如议题或合并请求），Google Chat 中默认开启讨论串通知。更多信息，请参见[议题 438452](https://gitlab.com/gitlab-org/gitlab/-/issues/438452)。

<a id="configure-the-integration"></a>

## 配置集成

<a id="in-google-chat"></a>

### 在 Google Chat 中

要在 Google Chat 中配置集成：

1. 前往您希望接收极狐GitLab 通知的空间。
1. 在左上角，空间名称旁边，选择向下箭头 ({{< icon name="chevron-down" >}}) > **应用和集成**。
1. 在 **Webhook** 部分，选择**添加 Webhook**。
1. 在**传入 Webhook** 对话框中：
   - 在**名称**中，为您的 Webhook 输入一个名称（例如 `GitLab integration`）。
   - 可选。在**头像 URL**中，为您的机器人输入一个头像。
1. 选择**保存**。
1. 在 Webhook URL 旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **复制链接**。

有关 Webhook 的更多信息，请参见
[Google Chat 文档](https://developers.google.com/workspace/chat/quickstart/webhooks)。

<a id="in-gitlab"></a>

### 在极狐GitLab 中

要在极狐GitLab 中配置集成：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Google Chat**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 在 **Webhook**中，[粘贴您从 Google Chat 复制的 URL](#in-google-chat)。
1. 在**触发器**部分，为您希望在 Google Chat 空间中接收通知的每个极狐GitLab 事件选中复选框。
1. 可选。在**通知设置**部分：
   - 选中**仅通知失败的流水线**复选框，
     以仅接收失败流水线的通知。
   - 选中**仅在状态变化时通知**复选框，
     以仅在 ref 的流水线状态变化时接收通知。
   - 从**要发送通知的分支**下拉列表中，
     选择您希望接收通知的分支。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。
