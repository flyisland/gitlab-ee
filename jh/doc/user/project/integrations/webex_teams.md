---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Webex Teams
description: "通过 Webhook 从 极狐GitLab 向 Webex Teams 空间发送事件通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以配置 极狐GitLab 向 Webex Teams 空间发送通知：

1. 为空间创建一个 Webhook。
1. 将 Webhook 添加到 极狐GitLab。

<a id="create-a-webhook-for-the-space"></a>

## 为空间创建 Webhook

1. 访问 [Incoming Webhooks 应用页面](https://apphub.webex.com/applications/incoming-webhooks-cisco-systems-38054-23307-75252)。
1. 选择 **Connect**，并根据需要登录 Webex Teams。
1. 为 Webhook 输入一个名称，并选择接收通知的空间。
1. 选择 **ADD**。
1. 复制 **Webhook URL**。

<a id="configure-settings-in-gitlab"></a>

## 在 极狐GitLab 中配置设置

先决条件：

- 实例启用需要管理员访问权限。
- 群组启用需要所有者角色。
- 项目启用需要维护者或所有者角色。

获得 Webex Teams 空间的 Webhook URL 后，你可以配置 极狐GitLab 发送通知：

1. 启用集成：
   - 在项目或群组级别：
     1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
     1. 选择 **设置** > **集成**。
   - 在实例级别：
     1. 在右上角，选择 **管理员**。
     1. 选择 **设置** > **集成**。
1. 选择 **Webex Teams** 集成。
1. 确保 **激活** 开关已启用。
1. 选中对应你希望在 Webex Teams 中接收的 极狐GitLab 事件的复选框。
1. 粘贴 Webex Teams 空间的 **Webhook** URL。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

Webex Teams 空间开始接收所有适用的 极狐GitLab 事件。