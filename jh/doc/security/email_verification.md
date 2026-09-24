---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 账户邮箱验证
description: Confirm user identity with email verification.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.2 中引入，带有功能标志 `require_email_verification`，默认禁用。
- 在极狐GitLab 18.1 中 GA，功能标志 `require_email_verification` 已移除。

{{< /history >}}

账户邮箱验证为极狐GitLab 账户提供了额外的安全保障。当满足特定条件时，账户会被锁定。如果您的账户被锁定，您必须验证邮箱或重置密码才能登录极狐GitLab。

> [!note]
> 在私有化部署的极狐GitLab 上，此功能默认禁用。使用[应用程序设置 API](../api/settings.md) 来启用 `require_email_verification_on_account_locked` 属性。

在 JihuLab.com 上，如果您未收到验证邮件，请在联系支持团队前选择 **重发验证码**。

<a id="accounts-without-two-factor-authentication-2fa"></a>

## 未启用双重验证（2FA）的账户

账户会在以下情况被锁定：

- 24 小时内出现三次或以上登录失败。
- 用户尝试从新的 IP 地址登录。

未启用 2FA 的锁定账户不会自动解锁。

成功登录后，一封包含六位数验证码的邮件会发送到您账户的主邮箱地址。如果您无法访问主邮箱地址，可以选择将验证码发送到任意一个备用邮箱地址。

验证码在 60 分钟后过期。

要解锁账户，请登录并输入验证码。您也可以[重置您的密码](https://jihulab.com/users/password/new)。

<a id="accounts-with-2fa-or-oauth"></a>

## 启用了 2FA 或 OAuth 的账户

当出现以下情况时，账户将被锁定：十次或更多次登录失败，或者超过[可配置的锁定用户策略](unlock_user.md#gitlab-self-managed-and-gitlab-dedicated-users)中定义的次数。

启用了 2FA 或 OAuth 的账户在十分钟后自动解锁，或者超过[可配置的锁定用户策略](unlock_user.md#gitlab-self-managed-and-gitlab-dedicated-users)中定义的次数后自动解锁。
要手动解锁账户，请重置密码。