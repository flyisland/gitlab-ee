---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Webex Teams
description: "通过 Webhook 将极狐GitLab 的事件通知发送到 Webex Teams 空间。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以配置极狐GitLab，将通知发送到 Webex Teams 空间：

1. 为该空间创建 Webhook。
1. 将该 Webhook 添加到极狐GitLab。

<a id="create-a-webhook-for-the-space"></a>

## 为该空间创建 Webhook

1. 转到 [Incoming Webhooks 应用页面](https://apphub.webex.com/applications/incoming-webhooks-cisco-systems-38054-23307-75252)。
1. 选择 **Connect**，如有需要，登录 Webex Teams。
1. 输入 Webhook 的名称，并选择用于接收通知的空间。
1. 选择 **ADD**。
1. 复制 **Webhook URL**。

<a id="configure-settings-in-gitlab"></a>

## 在极狐GitLab 中配置设置

先决条件：

- 具有管理员访问权限，才能为实例开启该集成。
- 具有所有者角色，才能为群组开启该集成。
- 具有维护者或所有者角色，才能为项目开启该集成。

获得 Webex Teams 空间的 Webhook URL 后，您可以配置极狐GitLab 发送通知：

1. 开启集成：
   - 为您的群组或项目：
     1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
     1. 选择**设置** > **集成**。
   - 为您的实例：
     1. 在右上角，选择**管理员**。
     1. 选择**设置** > **集成**。
1. 选择 **Webex Teams** 集成。
1. 在**启用集成**下，选中**活跃**复选框。
1. 选中您希望在 Webex Teams 中接收的极狐GitLab 事件对应的复选框。
1. 粘贴 Webex Teams 空间的 **Webhook** URL。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

Webex Teams 空间将开始接收所有适用的极狐GitLab 事件。
