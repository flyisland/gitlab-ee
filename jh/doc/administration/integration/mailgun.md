---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: Mailgun
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当您使用 Mailgun 为您的极狐GitLab 实例发送电子邮件，并且在极狐GitLab 中启用并配置了 [Mailgun](https://www.mailgun.com/) 集成时，您可以接收其 webhook 以跟踪发送失败。要设置集成，您必须：

1. [配置您的 Mailgun 域](#configure-your-mailgun-domain)。
1. [启用 Mailgun 集成](#enable-mailgun-integration)。

完成集成后，Mailgun 的 `temporary_failure` 和 `permanent_failure` webhook 将被发送到您的极狐GitLab 实例。

<a id="configure-your-mailgun-domain"></a>

## 配置您的 Mailgun 域

{{< history >}}

- 在极狐GitLab 15.0 中，`/-/members/mailgun/permanent_failures` URL 已弃用。
- 在极狐GitLab 15.0 中，URL 已更改为同时处理临时和永久失败。

{{< /history >}}

在极狐GitLab 中启用 Mailgun 之前，您需要设置自己的 Mailgun 端点以接收 webhook。

使用 [Mailgun webhook 指南](https://www.mailgun.com/blog/product/a-guide-to-using-mailguns-webhooks/)：

1. 添加一个 webhook，将 **事件类型** 设置为 **永久失败**。
1. 输入您实例的 URL，并包含 `/-/mailgun/webhooks` 路径。

   例如：

   ```plaintext
   https://myinstance.gitlab.com/-/mailgun/webhooks
   ```

1. 添加另一个 webhook，将 **事件类型** 设置为 **临时失败**。
1. 输入您实例的 URL，并使用相同的 `/-/mailgun/webhooks` 路径。

<a id="enable-mailgun-integration"></a>

## 启用 Mailgun 集成

为 webhook 端点配置 Mailgun 域后，您就可以启用 Mailgun 集成：

1. 以[管理员](../../user/permissions.md)用户身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，转到 **设置** > **通用**，然后展开 **Mailgun** 部分。
1. 选中 **启用 Mailgun** 复选框。
1. 输入 Mailgun HTTP webhook 签名密钥，如 [Mailgun 文档](https://documentation.mailgun.com/docs/mailgun/user-manual/get-started/) 中所述，并可在您的 Mailgun 帐户的 API 安全 (`https://app.mailgun.com/app/account/security/api_keys`) 部分找到。
1. 选择 **保存更改**。

