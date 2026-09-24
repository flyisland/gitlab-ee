---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Block, deactivate, ban, or trust users to control instance access and activity.
title: 管理用户
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您是实例管理员，您有多种选择来管理和控制用户访问权限。

> [!note]
> 本主题专门与私有化部署实例中的用户管理相关。有关群组的信息，请参阅[群组文档](../user/group/moderate_users.md)。

<a id="view-users"></a>

## 查看用户

要查看实例中的所有用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。

选择一个用户以查看其账户信息。

<a id="view-users-by-type"></a>

### 按类型查看用户

{{< history >}}

- 按类型筛选用户 在极狐GitLab 18.1 引入。

{{< /history >}}

已建立且稳定的极狐GitLab 实例通常会有大量的人类用户和机器人用户。您可以筛选用户列表，仅显示人类用户或[机器人用户](internal_users.md)。

要按类型查看用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中输入筛选条件。
   - 要显示人类用户，请输入 **Type=人类**。
   - 要显示机器人用户，请输入 **Type=机器人**。
1. 按 <kbd>Enter</kbd> 键。

<a id="billable-users"></a>

## 计费用户

您可以通过 Rails 控制台查看和更新实例中的[计费用户](../subscriptions/manage_seats.md#billable-users)。

<a id="check-daily-and-historical-billable-users"></a>

### 检查每日和历史计费用户

要获取极狐GitLab 实例中的每日和历史计费用户列表：

1. [启动 Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)。
1. 统计实例中的用户数量：

   ```ruby
   User.billable.count
   ```

1. 获取过去一年中实例的历史最大用户数：

   ```ruby
   ::HistoricalData.max_historical_user_count(from: 1.year.ago.beginning_of_day, to: Time.current.end_of_day)
   ```

<a id="update-daily-and-historical-billable-users"></a>

### 更新每日和历史计费用户

要手动触发更新极狐GitLab 实例中的每日和历史计费用户：

1. [启动 Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)。
1. 强制更新每日计费用户：

   ```ruby
   identifier = Analytics::UsageTrends::Measurement.identifiers[:billable_users]
   ::Analytics::UsageTrends::CounterJobWorker.new.perform(identifier, User.minimum(:id), User.maximum(:id), Time.zone.now)
   ```

1. 强制更新历史最大计费用户数：

   ```ruby
   ::HistoricalDataWorker.new.perform
   ```

<a id="users-pending-approval"></a>

## 待审批用户

处于待审批状态的用户需要管理员进行操作。用户注册可能处于待审批状态，因为管理员启用了以下任一选项：

- [要求管理员审批新用户账户创建](settings/sign_up_restrictions.md#require-administrator-approval-for-new-user-accounts) 设置。
- [用户上限](settings/sign_up_restrictions.md#user-cap)。
- [受限访问](settings/sign_up_restrictions.md#restricted-access)且没有可用的许可席位，此时[非活跃用户](settings/sign_up_restrictions.md#dormant-user-reactivation)尝试重新登录。
- [阻止自动创建的用户（OmniAuth）](../integration/omniauth.md#configure-common-settings)
- [阻止自动创建的用户（LDAP）](auth/ldap/_index.md#basic-configuration-settings)

当启用此设置时，如果用户注册账户：

- 该用户将被置于**待审批**状态。
- 用户会看到一条消息，告知他们其账户正在等待管理员审批。

待审批用户：

- 在功能上与[已封禁](#block-a-user)用户相同。
- 无法登录。
- 无法访问 Git 仓库或极狐GitLab API。
- 不会收到来自极狐GitLab 的任何通知。
- 不会占用[席位](../subscriptions/manage_seats.md#billable-users)。

管理员必须[批准其注册](#approve-or-reject-a-new-user-account)才能允许他们登录。

<a id="view-user-sign-ups-pending-approval"></a>

### 查看待审批的用户注册

{{< history >}}

- 按状态筛选用户 在极狐GitLab 17.0 引入。

{{< /history >}}

要查看待审批的用户注册：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中，按 **State=待审批** 筛选，然后按 <kbd>Enter</kbd> 键。

<a id="approve-or-reject-a-new-user-account"></a>

### 批准或拒绝新用户账号

{{< history >}}

- 按状态筛选用户 在极狐GitLab 17.0 引入。

{{< /history >}}

可以从**管理员**区域批准或拒绝待审批的用户注册。

要批准或拒绝用户注册：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中，按 **State=待审批** 筛选，然后按 <kbd>Enter</kbd> 键。
1. 找到您要批准或拒绝的用户注册，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **批准** 或 **拒绝**。

批准用户：

- 激活其账户。
- 将用户状态更改为活跃。
- 占用一个订阅[席位](../subscriptions/manage_seats.md#billable-users)。

拒绝用户：

- 阻止用户登录或访问实例信息。
- 删除该用户。

<a id="view-users-pending-role-promotion"></a>

## 查看等待角色晋升的用户

如果[管理员审批角色晋升](settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)已开启，那么将现有用户提升到计费角色的成员资格请求需要管理员审批。

要查看等待角色晋升的用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 选择 **角色晋升**。

将显示请求了最高角色的用户列表。
您可以**批准**或**拒绝**这些请求。

<a id="block-and-unblock-users"></a>

## 封禁和解封用户

极狐GitLab 管理员可以封禁和解封用户。
当您不希望某个用户访问实例，但又想保留其数据时，应该封禁该用户。

被封禁的用户：

- 无法登录或访问任何仓库。
  - 这些仓库中的任何关联数据仍然保留。
- 无法使用[Slack 中的斜杠命令](../user/project/integrations/gitlab_slack_application.md#slash-commands)。
- 不占用[席位](../subscriptions/manage_seats.md#billable-users)。

<a id="block-a-user"></a>

### 封禁用户

先决条件：

- 您必须是该实例的管理员。

您可以阻止用户访问实例。

要封禁用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 找到您要封禁的用户，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **封禁**。

要举报其他用户的滥用行为，请参阅[举报滥用行为](../user/report_abuse.md)。有关管理员区域中滥用举报的更多信息，请参阅[解决滥用举报](review_abuse_reports.md#resolving-abuse-reports)。

<a id="unblock-a-user"></a>

### 解封用户

{{< history >}}

- 按状态筛选用户 在极狐GitLab 17.0 引入。

{{< /history >}}

您可以解封用户，使其重新获得对实例的访问权限。

要解封用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中，按 **State=已封禁** 筛选，然后按 <kbd>Enter</kbd> 键。
1. 找到您要解封的用户，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **解封**。

用户的状态将设置为活跃，并且他们会占用一个[席位](../subscriptions/manage_seats.md#billable-users)。

> [!note]
> 也可以使用 [极狐GitLab API](../api/user_moderation.md#unblock-access-to-a-user) 解封用户。

对于 LDAP 用户，解封选项可能不可用。要启用解封选项，首先需要删除 LDAP 身份：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中，按 **State=已封禁** 筛选，然后按 <kbd>Enter</kbd> 键。
1. 选择一个用户。
1. 选择**身份**选项卡。
1. 找到 LDAP 提供商并选择**删除**。

<a id="deactivate-and-reactivate-users"></a>

## 停用和重新激活用户

极狐GitLab 管理员可以停用和重新激活用户。
如果用户近期没有活动，并且您不希望他们占用实例上的席位，则应该停用该用户。

极狐GitLab 根据 `last_active_at` 时间戳判断用户近期活动情况，该时间戳是以下两者中较近的一个：

- `last_activity_on`：用户在极狐GitLab 中最后一次记录活动的时间戳（例如创建议题、合并请求或评论）。
- `current_sign_in_at`：用户最近登录的时间戳。

如果用户的当前登录时间戳晚于其最后记录的活动时间，则该用户被认为是近期活跃的，即使他们自登录以来没有使用过任何极狐GitLab 功能。

被停用的用户：

- 可以登录极狐GitLab。
  - 如果被停用的用户登录，他们会被自动重新激活。
- 无法访问仓库或 API。
- 无法使用[Slack 中的斜杠命令](../user/project/integrations/gitlab_slack_application.md#slash-commands)。
- 不占用席位。有关更多信息，请参阅[计费用户](../subscriptions/manage_seats.md#billable-users)。

停用用户时，他们的项目、群组和历史记录将保留。

<a id="deactivate-a-user"></a>

### 停用用户

先决条件：

- 该用户在过去 90 天内没有任何活动。

要停用用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 找到您想要停用的用户，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **停用**。
1. 在对话框中，选择 **停用**。

用户会收到一封电子邮件通知，告知其账户已被停用。在这封邮件之后，他们将不再收到通知。
有关更多信息，请参阅[用户停用电子邮件](settings/email.md#user-deactivation-emails)。

要通过极狐GitLab API 停用用户，请参阅[停用用户](../api/user_moderation.md#deactivate-a-user)。有关永久用户限制的信息，请参阅[封禁和解封用户](#block-and-unblock-users)。

要从 JihuLab.com 订阅中移除用户，请参阅
[从您的订阅中移除用户](../subscriptions/manage_seats.md#remove-users-from-subscription)。

<a id="automatically-deactivate-dormant-users"></a>

### 自动停用非活跃用户

{{< history >}}

- 可自定义的时间段 在极狐GitLab 15.4 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/336747)。
- 非活跃周期下限设置为 90 天 在极狐GitLab 15.5 引入。

{{< /history >}}

管理员可以开启自动停用满足以下任一条件的用户：

- 创建时间超过一周且从未登录。
- 在指定时间段内没有任何活动（默认且最短为 90 天）。

要自动停用非活跃成员：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 展开**账户和限制**部分。
1. 在**非活跃用户**下，勾选**在非活动一段时间后停用非活跃用户**。
1. 在**停用前的非活跃天数**下，输入停用前的天数。最小值为 90 天。
1. 选择**保存更改**。

启用此功能后，极狐GitLab 会每天运行一个作业来停用非活跃用户。

每天最多可停用 100,000 个用户。

默认情况下，用户的账户被停用时会收到电子邮件通知。
您可以禁用[用户停用电子邮件](settings/email.md#user-deactivation-emails)。

> [!note]
> 极狐GitLab 生成的机器人会被排除在自动停用非活跃用户的范围之外。

<a id="automatically-delete-unconfirmed-users"></a>

### 自动删除未确认用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.1 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/352514)，并带有名为 `delete_unconfirmed_users_setting` 的[功能标志](feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 16.2 [默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/124982)。

{{< /history >}}

先决条件：

- 您必须是管理员。

您可以启用自动删除满足以下两个条件的用户：

- 从未确认其电子邮件地址。
- 在过去指定天数之前注册了极狐GitLab。

您可以使用[设置 API](../api/settings.md) 或在 Rails 控制台中配置这些设置：

```ruby
 Gitlab::CurrentSettings.update(delete_unconfirmed_users: true)
 Gitlab::CurrentSettings.update(unconfirmed_users_delete_after_days: 365)
```

当 `delete_unconfirmed_users` 设置启用后，极狐GitLab 每小时运行一次作业来删除这些未确认用户。
该作业仅删除注册超过 `unconfirmed_users_delete_after_days` 天的用户。

此作业仅在 `email_confirmation_setting` 设置为 `soft` 或 `hard` 时运行。

每天最多可删除 240,000 个用户。

<a id="reactivate-a-user"></a>

### 重新激活用户

{{< history >}}

- 按状态筛选用户 在极狐GitLab 17.0 引入。

{{< /history >}}

要重新激活用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中，按 **State=已停用** 筛选，然后按 <kbd>Enter</kbd> 键。
1. 对于您要重新激活的用户，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **激活**。

用户的状态设置为活跃，并且他们会占用一个[席位](../subscriptions/manage_seats.md#billable-users)。

> [!note]
> 被停用的用户自己也可以通过 UI 重新登录来重新激活账户。
> 也可以使用 [极狐GitLab API](../api/user_moderation.md#reactivate-a-user) 重新激活用户。
>
> 当[受限访问](settings/sign_up_restrictions.md#restricted-access)处于活动状态且没有可用许可席位时，尝试重新登录的非活跃用户会被设置为待审批状态，而不是被重新激活。

<a id="ban-and-unban-users"></a>

## 禁止和解除禁止用户

{{< history >}}

- 隐藏被禁止用户的合并请求 在极狐GitLab 15.8 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/107836)，并带有名为 `hide_merge_requests_from_banned_users` 的[功能标志](feature_flags/_index.md)。默认禁用。
- 隐藏被禁止用户的评论 在极狐GitLab 15.11 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/112973)，并带有名为 `hidden_notes` 的[功能标志](feature_flags/_index.md)。默认禁用。
- 隐藏被禁止用户的项目 在极狐GitLab 16.2 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/121488)，并带有名为 `hide_projects_of_banned_users` 的[功能标志](feature_flags/_index.md)。默认禁用。
- 隐藏被禁止用户的合并请求 在极狐GitLab 18.0 [全面上线](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/188770)。功能标志 `hide_merge_requests_from_banned_users` 已移除。

{{< /history >}}

极狐GitLab 管理员可以禁止和解除禁止用户。
当您想要阻止某个用户并隐藏其在实例上的活动时，应该禁止该用户。

被禁止的用户：

- 无法登录或访问任何仓库。
  - 任何关联的项目、议题、合并请求或评论都会被隐藏。
- 无法使用[Slack 中的斜杠命令](../user/project/integrations/gitlab_slack_application.md#slash-commands)。
- 不占用[席位](../subscriptions/manage_seats.md#billable-users)。

<a id="ban-a-user"></a>

### 禁止用户

您可以通过禁止用户来阻止他们并隐藏其贡献。

要禁止用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在您想要禁止的成员旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 从下拉列表中，选择 **禁止成员**。

<a id="unban-a-user"></a>

### 解除禁止用户

{{< history >}}

- 按状态筛选用户 在极狐GitLab 17.0 引入。

{{< /history >}}

要解除禁止用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中，按 **State=已禁止** 筛选，然后按 <kbd>Enter</kbd> 键。
1. 在您想要解除禁止的成员旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 从下拉列表中，选择 **解除禁止成员**。

用户的状态将设置为活跃，他们会占用一个[席位](../subscriptions/manage_seats.md#billable-users)。

<a id="delete-a-user"></a>

## 删除用户

要删除用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 对于您要删除的用户，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **删除用户**。
1. 输入用户名。
1. 选择以下任一选项：
   - **删除用户**，仅删除用户。
   - **删除用户及其贡献**，删除用户及其贡献，例如合并请求、议题以及他们作为唯一群组所有者的群组。

> [!note]
> 只有当用户是群组的继承或直接所有者时，您才能删除该用户。如果该用户是群组的唯一所有者，则无法删除。

<a id="trust-and-untrust-users"></a>

## 信任和不信任用户

{{< history >}}

- 在极狐GitLab 16.5 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/132402)。
- 按状态筛选用户 在极狐GitLab 17.0 引入。

{{< /history >}}

默认情况下，用户是不受信任的，并且会被阻止创建被认为是垃圾内容的议题、评论和代码片段。当您信任一个用户后，他们可以创建议题、评论和代码片段而不会被阻止。

<a id="trust-a-user"></a>

### 信任用户

要信任用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 选择一个用户。
1. 从**用户管理**下拉列表中，选择**信任用户**。
1. 在确认对话框中，选择**信任用户**。

<a id="untrust-a-user"></a>

### 不信任用户

要不信任用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **用户**。
1. 在搜索框中，按 **State=已信任** 筛选，然后按 <kbd>Enter</kbd> 键。
1. 选择一个用户。
1. 从**用户管理**下拉列表中，选择**不信任用户**。
1. 在确认对话框中，选择**不信任用户**。

<a id="troubleshooting"></a>

## 故障排除

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

在管理用户时，您可能需要根据特定条件对用户执行批量操作。以下 Rails 控制台脚本展示了一些示例。您可以[启动 Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)并使用类似以下的脚本：

### 停用近期无活动的用户

管理员可以停用近期无活动的用户。

> [!warning]
> 更改数据的命令如果运行不正确或条件不满足，可能会造成损害。务必先在测试环境中运行命令，并准备好备份实例以便恢复。

```ruby
days_inactive = 90
inactive_users = User.active.where("last_activity_on <= ?", days_inactive.days.ago)

inactive_users.each do |user|
    puts "user '#{user.username}': #{user.last_activity_on}"
    user.deactivate!
end
```

### 封禁近期无活动的用户

管理员可以封禁近期无活动的用户。

> [!warning]
> 更改数据的命令如果运行不正确或条件不满足，可能会造成损害。务必先在测试环境中运行命令，并准备好备份实例以便恢复。

```ruby
days_inactive = 90
inactive_users = User.active.where("last_activity_on <= ?", days_inactive.days.ago)

inactive_users.each do |user|
    puts "user '#{user.username}': #{user.last_activity_on}"
    user.block!
end
```

### 封禁或删除没有项目或群组的用户

管理员可以封禁或删除没有项目或群组的用户。

> [!warning]
> 更改数据的命令如果运行不正确或条件不满足，可能会造成损害。务必先在测试环境中运行命令，并准备好备份实例以便恢复。

```ruby
users = User.where('id NOT IN (select distinct(user_id) from project_authorizations)')

# 有多少用户被移除？
users.count

# 如果这个数量看起来合理：

# 您可以选择封禁用户：
users.each { |user|  user.blocked? ? nil  : user.block! }

# 或者您可以删除他们：
  # 需要 'current user'（您的用户）用于审计目的
current_user = User.find_by(username: '<your username>')

users.each do |user|
  DeleteUserWorker.perform_async(current_user.id, user.id)
end
```