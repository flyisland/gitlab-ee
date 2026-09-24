---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户密码
description: 通过强制执行要求和密码重置程序保护用户密码安全。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您使用密码登录 极狐GitLab，一个强密码非常重要。弱密码或可猜测的密码会让未授权人员更容易登录您的账户。

某些组织要求您在设置密码时满足一定的要求。

使用[双重身份验证](account/two_factor_authentication.md)提升您账户的安全性。

<a id="password-requirements"></a>

## 密码要求

密码要求适用于以下情况：

- 注册时设置密码。
- 重置密码。
- 修改密码。
- 管理员创建或更新您的账户时。

默认情况下，极狐GitLab 强制执行以下要求：

- 最小密码长度：8 个字符。
- 最大密码长度：128 个字符。
- 不得匹配包含 4,500 多个已知泄露密码的列表。
- 不得包含您的姓名、用户名或电子邮箱地址的任何部分。
- 不得包含可预测的词语（例如，`gitlab` 或 `devops`）。

在私有化部署的 极狐GitLab 上，管理员可以[修改密码复杂度要求](../../administration/settings/sign_up_restrictions.md#modify-password-complexity-requirements)。

<a id="compromised-password-detection"></a>

## 受损密码检测

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.0 中引入，使用名为 `notify_compromised_passwords` 的[功能标志](../../administration/feature_flags/_index.md)，默认禁用。
- 在 极狐GitLab 18.1 中于 JihuLab.com 上启用。功能标志 `notify_compromised_passwords` 已移除。

{{< /history >}}

极狐GitLab 可以在您的 JihuLab.com 凭据因其他服务或平台的数据泄露而受损时通知您。极狐GitLab 凭据已加密，并且 极狐GitLab 本身无法直接访问它们。

当检测到受损凭据时，极狐GitLab 会显示安全横幅并发送邮件提醒，其中包含如何修改密码并增强账户安全性的说明。

当使用[外部提供商](../../administration/auth/_index.md)进行身份验证，或您的账户已被[锁定](../../security/unlock_user.md)时，受损密码检测不可用。

<a id="choose-your-password"></a>

## 设置密码

您可以在[创建用户账户](account/create_accounts.md)时选择密码。

<a id="passwords-for-externally-authenticated-accounts"></a>

### 外部认证账户的密码

如果您的账户是通过外部[认证和授权提供商](../../administration/auth/_index.md)创建的，极狐GitLab 会自动生成一个随机密码以保持数据一致性。

此密码具有以下属性：

- 长度为 128 个字符
- 使用 Devise gem 的 [`friendly_token` 方法](https://github.com/heartcombo/devise/blob/f26e05c20079c9acded3c0ee16da0df435a28997/lib/devise.rb#L492) 生成
- 唯一且安全

通常，您无需知道或使用此密码。但是，您可能需要输入它以创建通行密钥或在其他类似情况下使用。

如果您需要输入 极狐GitLab 密码，可以按照[重置密码流程](#reset-your-password)创建一个您可以使用的全新密码。

这不会影响您外部身份提供商的密码。

<a id="change-your-password"></a>

## 修改密码

您可以修改密码。新密码必须满足密码要求。

要修改密码：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码和认证**。
1. 选择 **修改密码**。
1. 在 **当前密码** 文本框中，输入您的当前密码。
1. 在 **新密码** 和 **确认密码** 文本框中，输入您的新密码。
1. 选择 **保存密码**。

<a id="reset-your-password"></a>

## 重置密码

{{< history >}}

- 密码重置邮件发送至任何已验证的邮箱地址，在 极狐GitLab 16.1 中引入。

{{< /history >}}

如果您忘记密码，可以提交重置密码的请求。

要重置密码：

1. 进入 极狐GitLab 登录页面。
   - 在 JihuLab.com 上，可以通过 [https://jihulab.com/users/sign_in](https://jihulab.com/users/sign_in/) 访问。
   - 在私有化部署的 极狐GitLab 上，请使用您的域名。例如，`gitlab.example.com/users/sign_in`。
1. 选择 **忘记密码？**。
1. 输入您的电子邮箱。
1. 选择 **重置密码**。

您将被重定向到登录页面。如果提供的邮箱已验证并与现有账户关联，极狐GitLab 会发送密码重置邮件。

> [!note]
> 您的账户可以有多个已验证的邮箱地址，与您账户关联的任何邮箱地址均可被验证。但是，一旦密码重置，仅主要邮箱地址可用于登录。

<a id="credential-storage"></a>

## 凭证存储

极狐GitLab 以哈希格式存储用户密码，而不是明文形式。为哈希密码，极狐GitLab 使用 [Devise](https://github.com/heartcombo/devise) 认证库。

密码哈希使用以下安全措施：

- 哈希算法：
  - Bcrypt：默认使用。
  - PBKDF2+SHA512：在启用 FIPS 模式时使用。
- 拉伸：密码经过[拉伸](https://en.wikipedia.org/wiki/Key_stretching)处理，以防止暴力破解攻击。拉伸因子取决于哈希算法：
  - Bcrypt：10
  - PBKDF2+SHA512：20,000
- 加盐：为每个密码生成一个随机的[加密盐](https://en.wikipedia.org/wiki/Salt_(cryptography))，以抵御预先计算的哈希和字典攻击。每个密码都有一个唯一的盐。

OAuth 访问令牌也以 PBKDF2+SHA512 格式存储在数据库中，并经过 20,000 次拉伸。