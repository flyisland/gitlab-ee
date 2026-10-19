---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Pumble
description: "配置极狐GitLab 向 Pumble 频道发送通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以配置极狐GitLab 向 Pumble 频道发送通知：

1. 为该频道创建 webhook。
1. 将该 webhook 添加到极狐GitLab。

<a id="create-a-webhook-for-your-pumble-channel"></a>

## 为您的 Pumble 频道创建 webhook

1. 按照 Pumble 文档中 [Pumble 的传入 Webhook](https://pumble.com/help/integrations/add-pumble-apps/incoming-webhooks-for-pumble/)的步骤操作。
1. 复制 webhook URL。

<a id="configure-settings-in-gitlab"></a>

## 在极狐GitLab 中配置设置

先决条件：

- 需要管理员访问权限，才能为实例开启该集成。
- 需要所有者角色，才能为群组开启该集成。
- 需要维护者或所有者角色，才能为项目开启该集成。

获得 Pumble 频道的 webhook URL 后，配置极狐GitLab 以发送通知：

1. 为您的群组或项目开启该集成：
   1. 在您的群组或项目中，在左侧边栏中，选择**设置** > **集成**。
1. 为您的实例开启该集成：
   1. 在右上角，选择**管理员**。
   1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Pumble** 集成。
1. 在**启用集成**下，选中**活跃**复选框。
1. 选中您希望在 Pumble 中接收的极狐GitLab 事件对应的复选框。
1. 粘贴 Pumble 频道的 **Webhook** URL。
1. 配置其余选项。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

Pumble 频道将开始接收所有适用的极狐GitLab 事件。
