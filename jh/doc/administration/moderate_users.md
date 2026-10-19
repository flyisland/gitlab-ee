---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 阻止、停用、封禁或信任用户，以控制实例访问和活动。
gitlab_dedicated: yes
title: 管理用户
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您是实例管理员，您有多种选项来管理和控制用户访问。

> [!note]
> 本主题专门介绍极狐GitLab 私有化部署中的用户管理。有关群组的信息，请参阅[群组文档](../user/group/moderate_users.md)。

<a id="view-users"></a>

## 查看用户

要查看实例中的所有用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。

选择某个用户以查看其账号信息。

<a id="view-users-by-type"></a>

### 按类型查看用户

已运行较长时间的极狐GitLab 实例通常会有大量人类用户和机器人用户。您可以筛选用户列表，仅显示人类用户或[机器人用户](internal_users.md)。

要按类型查看用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，输入筛选条件。
   - 要显示人类用户，请输入**类型=人类**。
   - 要显示机器人用户，请输入**类型=机器人**。
1. 按 <kbd>Enter</kbd>。

<a id="billable-users"></a>

## 计费用户

您可以通过 Rails 控制台查看和更新实例中的[计费用户](../subscriptions/manage_seats.md#billable-users)。

<a id="check-daily-and-historical-billable-users"></a>

### 查看每日和历史计费用户

要获取极狐GitLab 实例中每日和历史计费用户的列表：

1. [启动 Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)。
1. 统计实例中的用户数量：

   ```ruby
   User.billable.count
   ```

1. 获取实例过去一年中的历史最大用户数量：

   ```ruby
   ::HistoricalData.max_historical_user_count(from: 1.year.ago.beginning_of_day, to: Time.current.end_of_day)
   ```

<a id="update-daily-and-historical-billable-users"></a>

### 更新每日和历史计费用户

要手动触发极狐GitLab 实例中每日和历史计费用户的更新：

1. [启动 Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)。
1. 强制更新每日计费用户：

   ```ruby
   identifier = Analytics::UsageTrends::Measurement.identifiers[:billable_users]
   ::Analytics::UsageTrends::CounterJobWorker.new.perform(identifier, User.minimum(:id), User.maximum(:id), Time.zone.now)
   ```

1. 强制更新历史最大计费用户：

   ```ruby
   ::HistoricalDataWorker.new.perform
   ```

<a id="users-pending-approval"></a>

## 待审批的用户

处于待审批状态的用户需要管理员执行操作。新用户账号可能处于待审批状态，因为管理员启用了以下任一选项：

- [要求管理员批准新用户账号创建](settings/sign_up_restrictions.md#require-administrator-approval-for-new-user-accounts)设置。
- [用户上限](../subscriptions/manage_seats.md#user-cap)。
- [受限访问](../subscriptions/manage_seats.md#restricted-access)，且没有可用的已授权席位，当[休眠用户](../subscriptions/manage_seats.md#dormant-user-reactivation)尝试重新登录时。
- [阻止自动创建的用户（OmniAuth）](../integration/omniauth.md#configure-common-settings)
- [阻止自动创建的用户（LDAP）](auth/ldap/_index.md#basic-configuration-settings)

当此设置启用时，用户注册账号后：

- 该用户处于**待审批**状态。
- 该用户会看到一条消息，告知其账号正在等待管理员批准。

待审批的用户：

- 在功能上与[已阻止](#block-a-user)的用户相同。
- 无法登录。
- 无法访问 Git 代码仓库或极狐GitLab API。
- 不会收到来自极狐GitLab 的任何通知。
- 不占用[席位](../subscriptions/manage_seats.md#billable-users)。

管理员必须[批准该新用户账号](#approve-or-reject-a-new-user-account)，才能允许其登录。

<a id="view-new-user-accounts-pending-approval"></a>

### 查看待审批的新用户账号

要查看待审批的新用户账号：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=等待批准**筛选，然后按 <kbd>Enter</kbd>。

<a id="approve-or-reject-a-new-user-account"></a>

### 批准或拒绝新用户账号

待审批的新用户账号可以在**管理**区域中批准或拒绝。

要批准或拒绝新用户账号：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=等待批准**筛选，然后按 <kbd>Enter</kbd>。
1. 对于您要批准或拒绝的新用户账号，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择**批准**或**拒绝**。

批准用户：

- 激活其账号。
- 将用户状态更改为活跃。
- 占用一个订阅[席位](../subscriptions/manage_seats.md#billable-users)。

拒绝用户：

- 阻止该用户登录或访问实例信息。
- 删除该用户。

<a id="view-users-pending-role-promotion"></a>

## 查看等待角色提升的用户

如果[角色提升的管理员批准](settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)已开启，将现有用户提升为计费角色的成员资格请求需要管理员批准。

要查看等待角色提升的用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择**角色提升**。

将显示请求最高角色的用户列表。您可以**批准**或**拒绝**这些请求。

<a id="block-and-unblock-users"></a>

## 阻止和解除阻止用户

极狐GitLab 管理员可以阻止和解除阻止用户。当您不希望某用户访问实例，但希望保留其数据时，应阻止该用户。

已阻止的用户：

- 无法登录或访问任何代码仓库。
  - 任何关联数据仍保留在这些代码仓库中。
- 无法使用 [Slack 中的斜杠命令](../user/project/integrations/gitlab_slack_application.md#slash-commands)。
- 不占用[席位](../subscriptions/manage_seats.md#billable-users)。

<a id="block-a-user"></a>

### 阻止用户

先决条件：

- 您必须是该实例的管理员。

您可以阻止用户访问实例。

要阻止用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 对于您要阻止的用户，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择**阻止**。

要举报其他用户的滥用行为，请参阅[举报滥用行为](../user/report_abuse.md)。有关**管理**区域中滥用报告的更多信息，请参阅[解决滥用报告](review_abuse_reports.md#resolving-abuse-reports)。

<a id="unblock-a-user"></a>

### 解除阻止用户

您可以解除阻止用户，使其重新获得对实例的访问权限。

要解除阻止用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=已禁用**筛选，然后按 <kbd>Enter</kbd>。
1. 对于您要解除阻止的用户，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择**解除阻止**。

该用户的状态将设置为活跃，并占用一个[席位](../subscriptions/manage_seats.md#billable-users)。

> [!note]
> 也可以使用[极狐GitLab API](../api/user_moderation.md#unblock-access-to-a-user) 解除阻止用户。

对于被 LDAP 阻止的用户，解除阻止选项不可用。要使用 LDAP 重新同步该用户，并仅在检查通过时解除阻止，请参阅[重新同步被 LDAP 阻止的用户](#resync-a-user-blocked-by-ldap)。

要不受 LDAP 检查结果影响解除阻止该用户，请删除 LDAP 身份：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=已禁用**筛选，然后按 <kbd>Enter</kbd>。
1. 选择一个用户。
1. 选择**身份**标签页。
1. 找到 LDAP 提供商并选择**删除**。

<a id="resync-a-user-blocked-by-ldap"></a>

### 重新同步被 LDAP 阻止的用户

先决条件：

- 您必须是该实例的管理员。
- 必须为该实例配置 LDAP。

您可以重新同步单个被 LDAP 阻止的用户，而无需等待该用户登录或等待下一次计划的 LDAP 用户同步。

要重新同步被 LDAP 阻止的用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=已禁用**筛选，然后按 <kbd>Enter</kbd>。
1. 对于您要重新同步的用户，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择**使用 LDAP 重新同步**。
1. 在确认对话框中，选择**使用 LDAP 重新同步**。

如果检查通过，极狐GitLab 会解除阻止该用户。如果检查失败，该用户将保持被阻止状态。

<a id="deactivate-and-reactivate-users"></a>

## 停用和重新激活用户

极狐GitLab 管理员可以停用和重新激活用户。如果某用户近期没有活动，且您不希望其占用实例上的席位，则应停用该用户。

极狐GitLab 根据 `last_active_at` 时间戳确定用户的近期活动，该时间戳取以下两者中较新的一个：

- `last_activity_on`：用户在极狐GitLab 中最后一次记录活动的时间戳（例如创建议题、合并请求或评论）。
- `current_sign_in_at`：用户最近一次登录的时间戳。

如果用户当前的登录时间戳比其最后记录的活动时间更新，则该用户被视为近期活跃，即使其自登录以来未使用任何极狐GitLab 功能。

已停用的用户：

- 可以登录极狐GitLab。
  - 如果已停用的用户登录，其账号会自动重新激活。
- 无法访问代码仓库或 API。
- 无法使用 [Slack 中的斜杠命令](../user/project/integrations/gitlab_slack_application.md#slash-commands)。
- 不占用席位。更多信息，请参阅[计费用户](../subscriptions/manage_seats.md#billable-users)。

当您停用用户时，其项目、群组和历史记录会保留。

<a id="deactivate-a-user"></a>

### 停用用户

先决条件：

- 该用户在过去 90 天内没有活动。

要停用用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 对于您要停用的用户，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择**停用**。
1. 在对话框中，选择**停用**。

该用户会收到一封电子邮件通知，告知其账号已被停用。收到此电子邮件后，他们将不再收到通知。更多信息，请参阅[用户停用电子邮件](settings/email.md#user-deactivation-emails)。

要使用极狐GitLab API 停用用户，请参阅[停用用户](../api/user_moderation.md#deactivate-a-user)。有关永久用户限制的信息，请参阅[阻止和解除阻止用户](#block-and-unblock-users)。

要将用户从 JihuLab.com 订阅中移除，请参阅[从订阅中移除用户](../subscriptions/manage_seats.md#remove-users-from-subscription)。

<a id="automatically-deactivate-dormant-users"></a>

### 自动停用休眠用户

管理员可以启用自动停用以下用户：

- 创建时间超过一周且从未登录。
- 在指定时间段内没有活动（默认值和最小值为 90 天）。

要自动停用休眠成员：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**账号和限制**部分。
1. 在**休眠用户**下，勾选**在一段时间不活动后停用休眠用户**。
1. 在**停用前的不活动天数**下，输入停用前的天数。最小值为 90 天。
1. 选择**保存更改**。

启用此功能后，极狐GitLab 会每天运行一个作业来停用休眠用户。

每天最多可停用 100,000 个用户。

默认情况下，用户账号被停用时会收到电子邮件通知。您可以禁用[用户停用电子邮件](settings/email.md#user-deactivation-emails)。

> [!note]
> 极狐GitLab 生成的机器人不参与休眠用户的自动停用。

<a id="automatically-delete-unconfirmed-users"></a>

### 自动删除未确认的用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须是管理员。

您可以启用自动删除同时满足以下条件的用户：

- 从未确认其电子邮件地址。
- 注册极狐GitLab 的时间超过指定天数。

您可以使用[设置 API](../api/settings.md) 或在 Rails 控制台中配置这些设置：

```ruby
 Gitlab::CurrentSettings.update(delete_unconfirmed_users: true)
 Gitlab::CurrentSettings.update(unconfirmed_users_delete_after_days: 365)
```

当 `delete_unconfirmed_users` 设置启用时，极狐GitLab 会每小时运行一个作业来删除未确认的用户。该作业仅删除注册时间超过 `unconfirmed_users_delete_after_days` 天的用户。

该作业仅在 `email_confirmation_setting` 设置为 `soft` 或 `hard` 时运行。

每天最多可删除 240,000 个用户。

该作业还会删除通过 SAML 或 SCIM 预配的、电子邮件地址未确认的用户。

<a id="reactivate-a-user"></a>

### 重新激活用户

要重新激活用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=已冻结**筛选，然后按 <kbd>Enter</kbd>。
1. 对于您要重新激活的用户，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择**激活**。

该用户的状态将设置为活跃，并占用一个[席位](../subscriptions/manage_seats.md#billable-users)。

> [!note]
> 已停用的用户也可以通过 UI 重新登录来自行重新激活其账号。
> 也可以使用[极狐GitLab API](../api/user_moderation.md#reactivate-a-user) 重新激活用户。
>
> 当受限访问处于活动状态且没有
> 可用的已授权席位时，尝试重新登录的休眠用户会被设置为
> 待审批，而不是被重新激活。

<a id="ban-and-unban-users"></a>

## 封禁和解除封禁用户

极狐GitLab 管理员可以封禁和解除封禁用户。当您希望阻止某用户并在实例中隐藏其活动时，应封禁该用户。

已封禁的用户：

- 无法登录或访问任何代码仓库。
  - 任何关联的项目、议题、合并请求或评论都会被隐藏。
- 无法使用 [Slack 中的斜杠命令](../user/project/integrations/gitlab_slack_application.md#slash-commands)。
- 不占用[席位](../subscriptions/manage_seats.md#billable-users)。

<a id="ban-a-user"></a>

### 封禁用户

您可以封禁用户以阻止他们并隐藏其贡献。

要封禁用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在您要封禁的成员旁边，选择垂直省略号（{{< icon name="ellipsis_v" >}}）。
1. 从下拉列表中，选择**封禁成员**。

<a id="unban-a-user"></a>

### 解除封禁用户

要解除封禁用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=已封禁**筛选，然后按 <kbd>Enter</kbd>。
1. 在您要封禁的成员旁边，选择垂直省略号（{{< icon name="ellipsis_v" >}}）。
1. 从下拉列表中，选择**解除封禁成员**。

该用户的状态将设置为活跃，并占用一个[席位](../subscriptions/manage_seats.md#billable-users)。

<a id="delete-a-user"></a>

## 删除用户

要删除用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 对于您要删除的用户，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择**删除用户**。
1. 输入用户名。
1. 选择以下任一选项：
   - **删除用户**，仅删除该用户。
   - **删除用户和贡献**，删除该用户及其贡献，例如合并请求、议题，以及该用户是唯一群组所有者的群组。

> [!note]
> 只有当用户是群组的继承所有者或直接所有者时，您才能删除该用户。如果该用户是唯一的群组所有者，则无法删除该用户。

<a id="trust-and-untrust-users"></a>

## 信任和取消信任用户

默认情况下，用户不受信任，并且会被阻止创建被视为垃圾内容的议题、评论和代码片段。当您信任某用户后，他们可以创建议题、评论和代码片段而不会被阻止。

<a id="trust-a-user"></a>

### 信任用户

要信任用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择一个用户。
1. 从**用户管理**下拉列表中，选择**信任用户**。
1. 在确认对话框中，选择**信任用户**。

<a id="untrust-a-user"></a>

### 取消信任用户

要取消信任用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 在搜索框中，按**状态=已信任**筛选，然后按 <kbd>Enter</kbd>。
1. 选择一个用户。
1. 从**用户管理**下拉列表中，选择**取消信任用户**。
1. 在确认对话框中，选择**取消信任用户**。

<a id="troubleshooting"></a>

## 故障排除

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

在管理用户时，您可能需要根据特定条件对用户执行批量操作。以下 Rails 控制台脚本展示了一些示例。您可以[启动 Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)并使用类似以下的脚本：

<a id="deactivate-users-that-have-no-recent-activity"></a>

### 停用近期没有活动的用户

管理员可以停用近期没有活动的用户。

> [!warning]
> 更改数据的命令如果未正确运行或在不当条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
days_inactive = 90
inactive_users = User.active.where("last_activity_on <= ?", days_inactive.days.ago)

inactive_users.each do |user|
    puts "user '#{user.username}': #{user.last_activity_on}"
    user.deactivate!
end
```

<a id="block-users-that-have-no-recent-activity"></a>

### 阻止近期没有活动的用户

管理员可以阻止近期没有活动的用户。

> [!warning]
> 更改数据的命令如果未正确运行或在不当条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
days_inactive = 90
inactive_users = User.active.where("last_activity_on <= ?", days_inactive.days.ago)

inactive_users.each do |user|
    puts "user '#{user.username}': #{user.last_activity_on}"
    user.block!
end
```

<a id="block-or-delete-users-that-have-no-projects-or-groups"></a>

### 阻止或删除没有项目或群组的用户

管理员可以阻止或删除没有项目或群组的用户。

> [!warning]
> 更改数据的命令如果未正确运行或在不当条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
users = User.where('id NOT IN (select distinct(user_id) from project_authorizations)')

# How many users are removed?
users.count

# If that count looks sane:

# You can either block the users:
users.each { |user|  user.blocked? ? nil  : user.block! }

# Or you can delete them:
  # need 'current user' (your user) for auditing purposes
current_user = User.find_by(username: '<your username>')

users.each do |user|
  DeleteUserWorker.perform_async(current_user.id, user.id)
end
```
