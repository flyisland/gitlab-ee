---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Pumble
description: "配置极狐GitLab 发送通知到 Pumble 频道。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.3 引入。

{{< /history >}}

您可以配置极狐GitLab 发送通知到 Pumble 频道：

1. 创建频道的 webhook。
1. 将 webhook 添加到极狐GitLab。

<a id="create-a-webhook-for-your-pumble-channel"></a>

## 为您的 Pumble 频道创建 webhook

1. 按照 Pumble 文档中的 [Pumble 的传入 webhook](https://pumble.com/help/integrations/add-pumble-apps/incoming-webhooks-for-pumble/) 步骤操作。
1. 复制 webhook URL。

<a id="configure-settings-in-gitlab"></a>

## 在极狐GitLab 中配置设置

先决条件：

- 实例启用的管理员访问权限。
- 群组启用的所有者角色。
- 项目启用的维护者或所有者角色。

获得 Pumble 频道的 webhook URL 后，配置极狐GitLab 发送通知：

1. 为群组或项目启用集成：
    1. 在群组或项目中，左侧边栏中，选择 **设置** > **集成**。
1. 为实例启用集成：
    1. 在右上角，选择 **管理员**。
    1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Pumble** 集成。
1. 确保 **活动** 开关已开启。
1. 选择您希望在 Pumble 中接收的极狐GitLab 事件对应的复选框。
1. 粘贴 Pumble 频道的 **Webhook** URL。
1. 配置其余选项。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

Pumble 频道开始接收所有适用的极狐GitLab 事件。