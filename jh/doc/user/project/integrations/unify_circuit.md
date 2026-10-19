---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Unify Circuit
description: "配置极狐GitLab 向 Unify Circuit 对话发送事件通知。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Unify Circuit 集成会将极狐GitLab 中的通知发送到 Circuit 对话。

<a id="set-up-unify-circuit"></a>

## 设置 Unify Circuit

在 Unify Circuit 中，[添加 webhook](https://www.circuit.com/unifyportalfaqdetail?articleId=164448) 并复制其 URL。

在极狐GitLab 中：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Unify Circuit**。
1. 打开**活跃**开关。
1. 选中与您希望在 Unify Circuit 中接收的极狐GitLab 事件对应的复选框。
1. 粘贴您从 Unify Circuit 配置步骤中复制的 **Webhook URL**。
1. 选中**仅通知失败的流水线**复选框，以便仅在失败时通知。
1. 选中**仅在状态变化时通知**复选框，以便仅在 ref 的流水线状态发生变化时发送通知。
1. 在**要发送通知的分支**下拉列表中，选择要为哪些类型的分支发送通知。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

您的 Unify Circuit 对话现在开始接收极狐GitLab 事件通知。
