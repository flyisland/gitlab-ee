---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 UI、Rake 任务、Rails 控制台或 API 更改用户密码。
title: 重置用户密码
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以使用 UI、Rake 任务、Rails 控制台或[用户 API](../api/users.md#modify-a-user) 重置用户密码。

<a id="prerequisites"></a>

## 先决条件

- 您必须是该实例的管理员。
- 密码必须满足所有[密码要求](../user/profile/user_passwords.md#password-requirements)。

<a id="use-the-ui"></a>

## 使用 UI

要在 UI 中重置用户密码：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 找到要更新的用户账号，选择**编辑**。
1. 在**密码**部分，输入并确认新密码。
1. 选择**保存更改**。

极狐GitLab 会更新该用户密码。

<a id="use-a-rake-task"></a>

## 使用 Rake 任务

要使用 Rake 任务重置用户密码：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake "gitlab:password:reset"
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake "gitlab:password:reset"
```

{{< /tab >}}

{{< /tabs >}}

极狐GitLab 会要求输入用户名、密码并确认密码。完成后，用户密码即被更新。

Rake 任务可以接受用户名作为参数。例如，要重置用户名为 `sidneyjones`的用户的密码：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

  ```shell
  sudo gitlab-rake "gitlab:password:reset[sidneyjones]"
  ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

  ```shell
  bundle exec rake "gitlab:password:reset[sidneyjones]"
  ```

{{< /tab >}}

{{< /tabs >}}

<a id="use-a-rails-console"></a>

## 使用 Rails 控制台

要从 Rails 控制台重置用户密码：

先决条件：

- 您必须知道关联的用户名、用户 ID 或电子邮件地址。

1. 启动 [Rails 控制台会话](../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 查找用户：

   - 按用户名：

     ```ruby
     user = User.find_by_username 'exampleuser'
     ```

   - 按用户 ID：

     ```ruby
     user = User.find(123)
     ```

   - 按电子邮件地址：

     ```ruby
     user = User.find_by(email: 'user@example.com')
     ```

1. 通过为 `user.password` 和 `user.password_confirmation` 设置值来重置密码。例如，要设置一个新的随机
   密码：

   ```ruby
   new_password = ::User.random_password
   user.password = new_password
   user.password_confirmation = new_password
   user.password_automatically_set = false
   ```

   要为新的密码设置特定值：

   ```ruby
   new_password = 'examplepassword'
   user.password = new_password
   user.password_confirmation = new_password
   user.password_automatically_set = false
   ```

1. 可选。通知用户管理员更改了其密码：

   ```ruby
   user.send_only_admin_changed_your_password_notification!
   ```

1. 保存更改：

   ```ruby
   user.save!
   ```

1. 退出控制台：

   ```ruby
   exit
   ```

<a id="reset-the-root-password"></a>

## 重置 root 密码

您可以通过前面介绍的 [Rake 任务](#use-a-rake-task)或 [Rails 控制台](#use-a-rails-console)流程重置 root 密码。

- 如果 root 账号名称未更改，请使用用户名 `root`。
- 如果 root 账号名称已更改，且您不知道新的用户名，
  您可以尝试使用用户 ID 为 `1`的 Rails 控制台。在几乎所有
  情况下，第一个用户就是默认的管理员账号。

<a id="troubleshooting"></a>

## 故障排除

在重置用户密码时，可使用以下信息排查问题。

<a id="email-confirmation-issues"></a>

### 电子邮件确认问题

如果新密码不起作用，可能是电子邮件确认问题。您可以尝试在 Rails 控制台中修复此问题。例如，如果新的 `root` 密码不起作用：

1. 启动 [Rails 控制台](../administration/operations/rails_console.md)。
1. 查找该用户并跳过重新确认：

   ```ruby
   user = User.find(1)
   user.skip_reconfirmation!
   ```

1. 再次尝试登录。

<a id="unmet-password-requirements"></a>

### 未满足密码要求

密码可能太短、太弱，或未满足复杂度要求。请确保您尝试设置的密码满足所有[密码要求](../user/profile/user_passwords.md#password-requirements)。

<a id="expired-password"></a>

### 密码已过期

如果用户密码之前已过期，您可能需要更新密码过期日期。有关更多信息，请参阅 [LDAP 用户通过 SSH 执行 Git fetch 时出现密码过期错误](../topics/git/troubleshooting_git.md#your-password-expired-error-on-git-fetch-with-ssh-for-ldap-user)。
