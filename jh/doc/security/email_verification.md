---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 账号邮箱验证
description: 通过邮箱验证确认用户身份。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

账号邮箱验证为极狐GitLab 账号安全提供了额外一层保护。在以下情况下需要进行邮箱验证：

- 由于多次登录尝试失败，您的账号已被[锁定](unlock_user.md)。
- 您的账号已[启用](../user/profile/account/two_factor_authentication.md#enable-email-otp)基于邮箱的一次性密码（OTP）。
- 您从新的或不受信任的 IP 地址登录。

> [!note]
> 在极狐GitLab 私有化部署上，此功能默认禁用。请使用[应用程序设置 API](../api/settings.md)
> 启用 `require_email_verification_on_account_locked` 属性。

要完成邮箱验证，请登录您的账号，并输入发送到您主邮箱地址的六位验证码。如果您无法访问主邮箱地址，也可以将验证码发送到您的任意备用邮箱地址。

验证码在 60 分钟后过期。

在 JihuLab.com 上，如果您没有收到验证邮件，请先选择**重新发送验证码**，然后再联系支持团队。
