---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 解锁因认证尝试失败而被锁定的账号。
title: 已锁定的用户账号
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 会在多次认证尝试失败后锁定用户账号。要解锁账号，请等待自动解锁期结束，或[重置密码](https://jihulab.com/users/password/new)。

以下情况可能导致认证尝试失败：

- 登录时密码错误。
- 登录时通行密钥错误。
- 在双因素认证（2FA）验证中，一次性密码（OTP）或通行密钥代码错误。
- 更新个人资料设置时密码错误。
- 更改密码时当前密码错误。
- 启用管理员模式时 2FA 代码错误。

锁定和解锁行为取决于交付方式以及用户的 2FA 状态：

- 在 JihuLab.com 或使用[账号邮箱验证](email_verification.md)的极狐GitLab 实例上：
  - 启用了 2FA 或使用外部身份（SAML、OAuth）的账号在失败 10 次或更多次后会被锁定。这些账号会在 10 分钟后自动解锁。
  - 未启用 2FA 或外部身份的账号在 24 小时内失败三次或更多次后会被锁定。这些账号会在 24 小时后自动解锁，或通过邮箱验证确认身份后解锁。
- 在未使用账号邮箱验证的极狐GitLab 实例上：
  - 所有账号在失败 10 次或更多次后会被锁定。这些账号会在 10 分钟后自动解锁。

在极狐GitLab 私有化部署上，使用[应用程序设置 API](../api/settings.md#update-application-settings) 配置 `max_login_attempts` 和 `failed_login_attempts_unlock_period_in_minutes` 锁定限制。

<a id="manually-unlock-user-accounts"></a>

## 手动解锁用户账号

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 拥有实例的管理员访问权限。

在极狐GitLab 私有化部署实例上，管理员可以在解锁期结束前手动解锁账号。

{{< tabs >}}

{{< tab title="管理区域" >}}

要从管理区域解锁账号：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 使用搜索栏找到被锁定的用户。
1. 从 **用户管理** 下拉列表中，选择 **解锁**。

该用户现在可以登录。

{{< /tab >}}

{{< tab title="Rails 控制台" >}}

要从 Rails 控制台解锁用户账号：

1. 启动 [Rails 控制台会话](../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 找到要解锁的用户：

   - 按用户名：

     ```ruby
     user = User.find_by_username('exampleuser')
     ```

   - 按用户 ID：

     ```ruby
     user = User.find(123)
     ```

   - 按邮箱地址：

     ```ruby
     user = User.find_by(email: 'user@example.com')
     ```

1. 解锁该用户：

   ```ruby
   user.unlock_access!
   ```

1. 退出控制台：

   ```ruby
   exit
   ```

该用户现在可以登录。

{{< /tab >}}

{{< /tabs >}}
