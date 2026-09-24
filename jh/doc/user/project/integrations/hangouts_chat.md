---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Google Chat
description: "Configure the Google Chat integration to receive notifications from极狐GitLab in a Google Chat space."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在极狐GitLab 中配置您的项目，以向 [Google Chat](https://chat.google.com/) 中您选择的空间发送通知。

在极狐GitLab 16.10 及更高版本中，对于同一个极狐GitLab 对象（例如，议题或合并请求），默认在 Google Chat 中启用线索化通知。更多信息，请参见[议题 438452](https://jihulab.com/gitlab-cn/gitlab/-/issues/438452)。

<a id="configure-the-integration"></a>

## 配置集成

<a id="in-google-chat"></a>

### 在 Google Chat 中

要在 Google Chat 中配置集成：

1. 转到您希望接收极狐GitLab 通知的空间。
1. 在左上角，空间名称旁边，选择向下箭头 ({{< icon name="chevron-down" >}}) > **应用与集成**。
1. 在 **Webhooks** 部分中，选择 **添加 Webhooks**。
1. 在 **传入 Webhooks** 对话框中：
   - 在 **名称** 中，输入您的 webhook 的名称（例如，`极狐GitLab 集成`）。
   - 可选。在 **头像 URL** 中，输入您的机器人的头像。
1. 选择 **保存**。
1. 在 webhook URL 旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **复制链接**。

有关 webhooks 的更多信息，请参阅 [Google Chat 文档](https://developers.google.com/workspace/chat/quickstart/webhooks)。

<a id="in-gitlab"></a>

### 在极狐GitLab 中

要在极狐GitLab 中配置集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Google Chat**。
1. 在 **启用集成** 下，选择 **启用** 复选框。
1. 在 **Webhook** 中，[粘贴您从 Google Chat 复制的 URL](#in-google-chat)。
1. 在 **触发器** 部分，选择每个极狐GitLab 事件旁边的复选框，以便在您的 Google Chat 空间中接收通知。
1. 可选。在 **通知设置** 部分：
   - 选择 **仅通知失败的流水线** 复选框，以仅接收失败流水线的通知。
   - 选择 **仅当状态改变时通知** 复选框，以仅在引用的流水线状态更改时接收通知。
   - 从 **要发送通知的分支** 下拉列表中，选择您希望接收通知的分支。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

