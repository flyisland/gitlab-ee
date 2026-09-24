---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Unlock accounts that are locked after failed sign-in attempts.
title: 锁定用户账户
---

极狐GitLab 在用户多次尝试登录失败后锁定用户账户。

<a id="gitlab-com-users"></a>

## JihuLab.com 用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果启用了双因素身份验证 (2FA)，账户在 3 次失败登录尝试后被锁定。账户在 30 分钟后自动解锁。

如果未启用 2FA，用户账户在 24 小时内 3 次失败登录尝试后被锁定。账户保持锁定，直到：

- 用户再次登录并通过[电子邮件验证码](email_verification.md)确认其身份。
- 极狐GitLab 支持团队验证用户身份并手动解锁账户。

<a id="gitlab-self-managed-and-gitlab-dedicated-users"></a>

## 私有化部署用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 可配置的锁定用户策略在极狐GitLab 16.5 中引入。

{{< /history >}}

默认情况下，用户账户在 10 次失败登录尝试后被锁定。账户在 10 分钟后自动解锁。

在极狐GitLab 16.5 及更高版本中，管理员可以使用[应用程序设置 API](../api/settings.md#update-application-settings) 修改 `max_login_attempts` 或 `failed_login_attempts_unlock_period_in_minutes` 设置。

管理员可以使用以下任务立即解锁账户：

<a id="unlock-user-accounts-from-the-admin-area"></a>

### 从管理员区域解锁用户账户

前提条件

- 您必须是极狐GitLab 私有化部署的管理员。

要从管理员区域解锁账户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 使用搜索栏查找被锁定的用户。
1. 从 **用户管理** 下拉列表中，选择 **解锁**。

用户现在可以登录。

<a id="unlock-user-accounts-from-a-rails-console"></a>

### 从 Rails 控制台解锁用户账户

前提条件

- 您必须是极狐GitLab 私有化部署的管理员。
- 您必须知道关联的用户名、用户 ID 或电子邮件地址。

要从 Rails 控制台解锁用户账户：

1. 启动一个 [Rails 控制台会话](../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 查找要解锁的用户：

   - 按用户名：

     ```ruby
     user = User.find_by_username('exampleuser')
     ```

   - 按用户 ID：

     ```ruby
     user = User.find(123)
     ```

   - 按电子邮件地址：

     ```ruby
     user = User.find_by(email: 'user@example.com')
     ```

1. 解锁用户：

   ```ruby
   user.unlock_access!
   ```

1. 退出控制台：

   ```ruby
   exit
   ```

用户现在可以登录。