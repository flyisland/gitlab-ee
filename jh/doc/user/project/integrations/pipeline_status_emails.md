---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线状态邮件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以向一组电子邮件地址发送有关群组或项目中流水线状态变更的通知。

被屏蔽用户触发的流水线通知不会发送。

<a id="enable-pipeline-status-email-notifications"></a>

## 启用流水线状态邮件通知

先决条件：

- 您必须具有项目的维护者或所有者角色，或者群组的所有者角色。

要启用流水线状态邮件：

1. 在您的项目或群组中，在左侧边栏中选择 **设置** > **集成**。
1. 选择 **流水线状态邮件**。
1. 确保选中 **激活** 复选框。
1. 在 **收件人** 中，输入以逗号分隔的电子邮件地址列表。
   无效的电子邮件地址会被自动过滤，不会收到通知。
1. 可选。要仅接收失败流水线的通知，请选择 **仅通知失败的流水线**。
1. 可选。要仅在流水线状态变更时接收通知，请选择 **仅在状态变更时通知**。
1. 可选。要接收父流水线和子流水线的通知，请选择 **通知子流水线**。
1. 选择要发送通知的分支。
1. 选择 **保存更改**。