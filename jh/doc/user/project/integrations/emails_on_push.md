---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 推送邮件通知
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用推送邮件通知，可以在推送到极狐GitLab 项目时接收邮件通知。
您可以选择触发这些通知的推送事件。

通过推送邮件通知，您可以指定一个电子邮件地址列表，以接收每次推送的提交和差异。

<a id="set-up-the-integration"></a>

## 设置集成

先决条件：

- 您必须具有项目的维护者或所有者角色。

设置推送邮件通知：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧侧边栏，选择 **设置** > **集成**。
1. 选择 **推送邮件通知**。
1. 在 **启用集成** 下，选中 **激活** 复选框。
1. 在 **收件人** 中，输入以空格或换行分隔的电子邮件地址列表。
   无效的电子邮件地址会自动过滤掉，不会收到通知。
1. 配置以下选项：

   - **推送事件** - 当收到推送事件时触发邮件。
   - **标签推送事件** - 当创建并推送标签时触发邮件。
   - **从提交者发送** - 如果域与极狐GitLab 实例使用的域（如 `user@gitlab.com`）匹配，则从提交者的电子邮件地址发送通知。
   - **禁用代码差异** - 不在通知正文中包含可能的敏感代码差异。

