---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户密码
description: 通过强制执行密码要求和密码重置流程保护用户密码。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您使用密码登录极狐GitLab，那么强密码非常重要。弱密码或容易被猜到的密码会让未经授权的人员更容易登录您的账号。

有些组织要求您在选择密码时满足特定要求。

使用[双因素认证](account/two_factor_authentication.md)提升您账号的安全性。

<a id="password-requirements"></a>

## 密码要求

密码要求在以下情况下适用：

- 在注册期间选择密码时。
- 重置密码时。
- 更改密码时。
- 由管理员创建或更新您的账号时。

默认情况下，极狐GitLab 强制执行以下要求：

- 最小密码长度：8 个字符。
- 最大密码长度：128 个字符。
- 不得与 4,500 多个已知的泄露密码列表匹配。
- 不得包含您的姓名、用户名或电子邮件地址的一部分。
- 不得包含可预测的单词（例如 `gitlab` 或 `devops`）。

在极狐GitLab 私有化部署上，管理员可以[修改密码复杂度要求](../../administration/settings/sign_up_restrictions.md#modify-password-complexity-requirements)。

<a id="compromised-password-detection"></a>

## 泄露密码检测

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果您的 JihuLab.com 凭据因其他服务或平台的数据泄露而暴露，极狐GitLab 可以通知您。极狐GitLab 凭据经过加密，极狐GitLab 本身无法直接访问这些凭据。

当检测到泄露的凭据时，极狐GitLab 会显示安全横幅并发送电子邮件提醒，其中包含有关如何更改密码和加强账号安全的说明。

当[使用外部提供商](../../administration/auth/_index.md)进行身份验证时，或者如果您的账号已被[锁定](../../security/unlock_user.md)，则无法使用泄露密码检测。

<a id="choose-your-password"></a>

## 选择您的密码

您可以在[创建用户账号](account/create_accounts.md)时选择密码。

<a id="passwords-for-externally-authenticated-accounts"></a>

### 外部身份验证账号的密码

如果您的账号是使用外部[身份验证和授权提供商](../../administration/auth/_index.md)创建的，极狐GitLab 会自动生成一个随机密码以保持数据一致性。

此密码具有以下属性：

- 长度为 128 个字符
- 使用 Devise gem 的
  [`friendly_token` 方法](https://github.com/heartcombo/devise/blob/f26e05c20079c9acded3c0ee16da0df435a28997/lib/devise.rb#L492)生成
- 唯一且安全

通常，您不需要知道或使用此密码。但是，您可能需要输入它来创建通行密钥或在其他类似情况下使用。

如果您需要输入极狐GitLab 密码，可以按照[重置密码流程](#reset-your-password)创建一个可以使用的新密码。

这不会影响您的外部身份提供商的密码。

<a id="change-your-password"></a>

## 更改您的密码

您可以更改您的密码。新密码必须满足密码要求。

要更改您的密码：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码和认证方式**。
1. 选择 **更改密码**。
1. 在 **当前密码** 文本框中，输入您当前的密码。
1. 在 **新密码** 和 **密码确认** 文本框中，输入您的新密码。
1. 选择 **保存密码**。

<a id="reset-your-password"></a>

## 重置您的密码

如果您忘记了密码，可以提交请求来重置密码。

要重置您的密码：

1. 转到极狐GitLab 登录页面。
   - 在 JihuLab.com 上，可通过 [https://jihulab.com/users/sign_in](https://jihulab.com/users/sign_in) 访问。
   - 在极狐GitLab 私有化部署上，使用您的域名。例如，`gitlab.example.com/users/sign_in`。
1. 选择 **忘记密码？**。
1. 输入您的电子邮件。
1. 选择 **重置密码**。

您将被重定向到登录页面。如果提供的电子邮件已验证并与现有账号关联，极狐GitLab 会发送一封密码重置电子邮件。

> [!note]
> 您的账号可以有多个已验证的电子邮件地址，并且与您账号关联的任何电子邮件地址
> 都可以验证。但是，密码重置后，只有主电子邮件地址
> 可用于登录。

<a id="credential-storage"></a>

## 凭据存储

极狐GitLab 以哈希格式存储用户密码，而不是纯文本。为了对密码进行哈希处理，极狐GitLab 使用
[Devise](https://github.com/heartcombo/devise) 身份验证库。

密码哈希使用以下安全措施：

- 哈希算法：
  - Bcrypt：默认使用。
  - PBKDF2+SHA512：启用 FIPS 模式时使用。
- 拉伸：密码经过[拉伸](https://en.wikipedia.org/wiki/Key_stretching)处理，以防范
  暴力破解攻击。拉伸因子取决于哈希算法：
  - Bcrypt：10
  - PBKDF2+SHA512：20,000
- 加盐：为每个密码生成一个随机[加密盐](https://en.wikipedia.org/wiki/Salt_(cryptography))
  以防范预计算哈希和
  字典攻击。每个密码都有唯一的盐。

OAuth 访问令牌也以 PBKDF2+SHA512 格式存储在数据库中，并拉伸 20,000 次。
