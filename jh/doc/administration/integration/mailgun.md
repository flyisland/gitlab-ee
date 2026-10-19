---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
description: 为极狐GitLab 私有化部署实例配置 Mailgun webhook，以跟踪电子邮件投递失败。
title: Mailgun
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当您使用 Mailgun 为极狐GitLab 实例发送电子邮件，并且已在极狐GitLab 中开启并配置 [Mailgun](https://www.mailgun.com/) 集成时，您可以接收其 webhook 以跟踪投递失败。要设置该集成，您必须：

1. [配置您的 Mailgun 域名](#configure-your-mailgun-domain)。
1. [启用 Mailgun 集成](#enable-mailgun-integration)。

完成集成后，Mailgun 的 `temporary_failure` 和 `permanent_failure` webhook 会发送到您的极狐GitLab 实例。

<a id="configure-your-mailgun-domain"></a>

## 配置您的 Mailgun 域名

在极狐GitLab 中开启 Mailgun 之前，请先设置您自己的 Mailgun 端点以接收 webhook。

使用 [Mailgun webhook 指南](https://www.mailgun.com/blog/product/a-guide-to-using-mailguns-webhooks/)：

1. 添加一个 webhook，将 **Event type** 设置为 **Permanent Failure**。
1. 输入您实例的 URL，并包含 `/-/mailgun/webhooks` 路径。

   例如：

   ```plaintext
   https://myinstance.gitlab.com/-/mailgun/webhooks
   ```

1. 再添加一个 webhook，将 **Event type** 设置为 **Temporary Failure**。
1. 输入您实例的 URL，并使用相同的 `/-/mailgun/webhooks` 路径。

<a id="enable-mailgun-integration"></a>

## 启用 Mailgun 集成

为 webhook 端点配置好 Mailgun 域名后，
您就可以开启 Mailgun 集成了：

1. 以[管理员](../../user/permissions.md)用户身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，转到 **设置** > **通用**，然后展开 **Mailgun** 部分。
1. 选中 **启用 Mailgun 事件接收器** 复选框。
1. 输入 Mailgun HTTP webhook 签名密钥，具体如
   [Mailgun 文档](https://documentation.mailgun.com/docs/mailgun/user-manual/get-started/)所述，
   并显示在您 Mailgun 账号的 API 安全（`https://app.mailgun.com/app/account/security/api_keys`）部分中。
1. 选择 **保存更改**。
