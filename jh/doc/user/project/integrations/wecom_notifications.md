---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Custom HTTP callbacks, used to send events.
title: 企业微信集成和通知
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

> - [引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/3214)于极狐GitLab 16.2，[功能标志](../../../administration/feature_flags.md)为 `wecom_integration`。默认禁用。

如果您想在企业微信的群组中查看极狐GitLab 项目中的事件变更，如创建议题、流水线故障或更新合并请求等，您可以将企业微信与极狐GitLab 进行集成。

## 企业微信集成

<a id="configure_wecom_bot"></a>

### 配置企业微信

在您需要接收极狐GitLab 事件通知的企业微信群组中添加机器人：

1. 打开您需要接收极狐GitLab 事件通知的企业微信群组，选择右上角的三个点。
1. 选择 **群机器人** > **添加机器人**。
1. 选择右上角的 **添加**。
1. 在添加机器人页面中，输入机器人名字，并选择 **添加**。
1. 记录您创建的机器人的 **Webhook 地址** 中的 key，以供后续配置使用。

以企业微信中的某个机器人的 Webhook 地址为例：

```
https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=0ef24289-7a4a-4984-ad3e-b0e1903d0847
```

在此示例中，`0ef24289-7a4a-4984-ad3e-b0e1903d0847` 即为该机器人的 **webhook key**。记录这个值，以供后续配置使用。

### 配置极狐GitLab

1. 启动极狐GitLab Rails 控制台，在控制台中运行 `Feature.enable(:wecom_integration)`，完成企业微信特性开关的启用。
2. 以管理员身份登录极狐GitLab，在左侧边栏中选择 **管理中心** > **设置** > **集成**。
3. 在右侧页面中，选择 **添加集成** 下方的 **企业微信通知**。
4. 在 **企业微信通知** 页面中，勾选 **启用集成** 下方的 **启用** 复选框。
5. 在 **触发器** 下方勾选您想在企业微信群组中接收通知的事件类型。如推送、议题和合并请求等。
6. 将您在[配置企业微信](#configure_wecom_bot)中记录的 webhook key 添加到相应的触发器中，以接收事件通知。每个触发器支持添加多个机器人的 webhook key，以英文逗号分隔。
7. 按需选择或填写 **语言**、**只通知运行失败的流水线**、**要发送通知的分支**、**待通知标签** 和 **待通知标签行为**。
8. 选择 **保存更改**。

至此，您已经完成了企业微信和极狐GitLab 集成所需的所有配置工作。

## 企业微信通知

当触发器的以下事件发生时，极狐GitLab 会向您配置成功的企业微信群组中发送相关通知。

| 触发器名称   | 触发事件           |
|---------|----------------|
| 推送      | 向仓库推送新内容。      |
| 议题      | 创建、更新或关闭议题。    |
| 私密议题    | 创建、更新或关闭私密议题。  |
| 合并请求    | 创建、合并或更新合并请求。  |
| 备注      | 添加评论。          |
| 私密备注    | 添加私密评论。        |
| 标签推送    | 向仓库推送新标签。      |
| 流水线     | 流水线状态发生变更。     |
| Wiki 页面 | 创建或更新 Wiki 页面。 |
| 部署      | 开始或完成部署。       |
| 漏洞      | 记录新漏洞。         |
| 警报      | 记录新警报。         |
