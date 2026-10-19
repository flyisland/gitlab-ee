---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 LDAP
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您是管理员，请使用以下信息对 LDAP 进行故障排除。

<a id="common-problems--workflows"></a>

## 常见问题与工作流

<a id="connection"></a>

### 连接

<a id="connection-refused"></a>

#### 连接被拒绝

如果您在尝试连接 LDAP 服务器时收到 `Connection Refused` 错误消息，请检查极狐GitLab 使用的 LDAP `port` 和 `encryption` 设置。常见的组合是 `encryption: 'plain'` 和 `port: 389`，或者 `encryption: 'simple_tls'` 和 `port: 636`。

<a id="connection-times-out"></a>

#### 连接超时

如果极狐GitLab 无法访问您的 LDAP 端点，您会看到类似以下的消息：

```plaintext
Could not authenticate you from Ldapmain because "Connection timed out - user specified timeout".
```

如果您配置的 LDAP 提供商和/或端点处于离线状态，或者极狐GitLab 无法访问它，则任何 LDAP 用户都无法进行身份验证和登录。极狐GitLab 不会缓存或存储 LDAP 用户的凭据，以便在 LDAP 中断期间提供身份验证。

如果您看到此错误，请联系您的 LDAP 提供商或管理员。

<a id="referral-error"></a>

#### 引用错误

如果您在日志中看到 `LDAP search error: Referral`，或者在排查 LDAP 群组同步问题时看到该错误，这可能表示存在配置问题。LDAP 配置 `/etc/gitlab/gitlab.rb`（Omnibus）或 `config/gitlab.yml`（源码安装）采用 YAML 格式，对缩进敏感。请检查 `group_base` 和 `admin_group` 配置键是否比服务器标识符多缩进 2 个空格。默认标识符是 `main`，示例片段如下：

```yaml
main: # 'main' is the GitLab 'provider ID' of this LDAP server
  label: 'LDAP'
  host: 'ldap.example.com'
  # ...
  group_base: 'cn=my_group,ou=groups,dc=example,dc=com'
  admin_group: 'my_admin_group'
```

<a id="query-ldap"></a>

#### 查询 LDAP

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下内容允许您使用 Rails 控制台在 LDAP 中执行搜索。根据您要执行的操作，直接查询[用户](#query-a-user-in-ldap)或[群组](#query-a-group-in-ldap)，甚至[使用 `ldapsearch`](#ldapsearch) 可能更合适。

```ruby
adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain')
options = {
    # :base is required
    # use .base or .group_base
    base: adapter.config.group_base,

    # :filter is optional
    # 'cn' looks for all "cn"s under :base
    # '*' is the search string - here, it's a wildcard
    filter: Net::LDAP::Filter.eq('cn', '*'),

    # :attributes is optional
    # the attributes we want to get returned
    attributes: %w(dn cn memberuid member submember uniquemember memberof)
}
adapter.ldap_search(options)
```

在过滤器中使用 OID 时，请将 `Net::LDAP::Filter.eq` 替换为 `Net::LDAP::Filter.construct`：

```ruby
adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain')
options = {
    # :base is required
    # use .base or .group_base
    base: adapter.config.base,

    # :filter is optional
    # This filter includes OID 1.2.840.113556.1.4.1941
    # It will search for all direct and nested members of the group gitlab_grp in the LDAP directory
    filter: Net::LDAP::Filter.construct("(memberOf:1.2.840.113556.1.4.1941:=CN=gitlab_grp,DC=example,DC=com)"),

    # :attributes is optional
    # the attributes we want to get returned
    attributes: %w(dn cn memberuid member submember uniquemember memberof)
}
adapter.ldap_search(options)
```

有关其运行方式的示例，请[查看 `Adapter` 模块](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/ee/gitlab/auth/ldap/adapter.rb)。

<a id="user-sign-ins"></a>

### 用户登录

<a id="no-users-are-found"></a>

#### 未找到任何用户

如果您已[确认](#ldap-check)可以建立到 LDAP 的连接，但极狐GitLab 在输出中未显示 LDAP 用户，则很可能是以下情况之一：

- `bind_dn` 用户没有足够的权限遍历用户树。
- 用户不在[配置的 `base`](_index.md#configure-ldap) 之下。
- [配置的 `user_filter`](_index.md#set-up-ldap-user-filter) 阻止了对这些用户的访问。

在这种情况下，您可以使用 [ldapsearch](#ldapsearch) 并结合 `/etc/gitlab/gitlab.rb`中现有的 LDAP 配置，来确认上述哪种情况属实。

<a id="users-cannot-sign-in"></a>

#### 用户无法登录

用户可能因多种原因而无法登录。首先，您可以问自己以下几个问题：

- 该用户是否在 LDAP 中[配置的 `base`](_index.md#configure-ldap) 之下？用户必须位于此 `base` 之下才能登录。
- 该用户是否通过了[配置的 `user_filter`](_index.md#set-up-ldap-user-filter)？如果未配置，则可以忽略此问题。如果已配置，则用户还必须通过此过滤器才能被允许登录。
  - 请参阅我们关于[调试 `user_filter`](#debug-ldap-user-filter)的文档。

如果上述问题都没有问题，那么接下来应在复现问题时查看日志本身。

- 请用户尝试登录并让其失败。
- [查看输出](#gitlab-logs)，寻找有关登录的任何错误或其他消息。您可能会看到本页上的其他错误消息之一，此时相应章节可以帮助解决问题。

如果日志无法揭示问题的根源，请使用 [Rails 控制台](#rails-console) [查询该用户](#query-a-user-in-ldap)，看看极狐GitLab 能否在 LDAP 服务器上读取该用户。

[调试用户同步](#sync-all-users)也可能有助于进一步调查。

<a id="users-see-an-error-invalid-login-or-password"></a>

#### 用户看到错误 `Invalid login or password.`

如果用户看到此错误，可能是因为他们尝试使用 **标准** 登录表单而不是 **LDAP** 登录表单进行登录。

要解决此问题，请让用户在 **LDAP** 登录表单中输入其 LDAP 用户名和密码。

<a id="invalid-credentials-on-sign-in"></a>

#### 登录时凭据无效

如果所使用的登录凭据在 LDAP 上是正确的，请确保相关用户满足以下条件：

- 确保您用于绑定的用户有足够的权限读取并遍历该用户的树。
- 检查 `user_filter` 是否阻止了其他有效用户。
- 运行 [LDAP 检查命令](#ldap-check)，以确保 LDAP 设置正确，并且[极狐GitLab 可以看到您的用户](#no-users-are-found)。

<a id="access-denied-for-your-ldap-account"></a>

#### 您的 LDAP 账号访问被拒绝

存在[一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/issues/235930)，可能会影响具有[审计员级别访问权限](../../auditor_users.md)的用户。从专业版/旗舰版降级时，尝试登录的审计员用户可能会看到以下消息：`Access denied for your LDAP account`。

变通方法是更改受影响用户的访问级别。

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择受影响用户的名称。
1. 在右上角，选择**编辑**。
1. 将该用户的访问级别从 `Regular` 更改为 `Administrator`（或反之）。
1. 在页面底部，选择**保存更改**。
1. 在右上角，再次选择**编辑**。
1. 恢复该用户原来的访问级别（`Regular` 或 `Administrator`），然后再次选择**保存更改**。

该用户现在应该可以登录了。

<a id="email-has-already-been-taken"></a>

#### 电子邮件已被占用

某用户使用正确的 LDAP 凭据尝试登录，但被拒绝访问，并且 [production.log](../../logs/_index.md#productionlog)中显示类似以下的错误：

```plaintext
(LDAP) Error saving user <USER DN> (email@example.com): ["Email has already been taken"]
```

此错误指的是 LDAP 中的电子邮件地址 `email@example.com`。电子邮件地址在极狐GitLab 中必须唯一，并且 LDAP 链接到用户的主电子邮件（而不是其可能众多的次要电子邮件中的任何一个）。另一个用户（甚至同一用户）将电子邮件 `email@example.com` 设置为次要电子邮件，从而引发了此错误。

我们可以使用 [Rails 控制台](#rails-console) 检查这个冲突的电子邮件地址来自哪里。在控制台中，运行以下命令：

```ruby
# This searches for an email among the primary AND secondary emails
user = User.find_by_any_email('email@example.com')
user.username
```

这会显示哪个用户拥有此电子邮件地址。此时必须采取以下两个步骤之一：

- 要在使用 LDAP 登录时为此用户创建新的极狐GitLab 用户/用户名，请移除该次要电子邮件以消除冲突。
- 要为此用户使用现有的极狐GitLab 用户/用户名与 LDAP 配合使用，请移除此次要电子邮件并将其设为主电子邮件，以便极狐GitLab 将此配置文件与 LDAP 身份关联。

用户可以在[其个人资料中](../../../user/profile/_index.md#access-your-user-profile)执行上述任一步骤，管理员也可以执行。

<a id="projects-limit-errors"></a>

#### 项目数限制错误

以下错误表明某个限制或约束已启用，但关联的数据字段不包含任何数据：

- `Projects limit can't be blank`。
- `Projects limit is not a number`。

要解决此问题：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开以下两项：
   - **账号和限制**。
   - **新用户账号限制**。
1. 检查例如**默认项目数限制**或**新用户账号允许的域**字段，并确保配置了相关的值。

<a id="debug-ldap-user-filter"></a>

#### 调试 LDAP 用户过滤器

[`ldapsearch`](#ldapsearch) 允许您测试已配置的[用户过滤器](_index.md#set-up-ldap-user-filter)，以确认它返回您期望返回的用户。

```shell
ldapsearch -H ldaps://$host:$port -D "$bind_dn" -y bind_dn_password.txt  -b "$base" "$user_filter" sAMAccountName
```

- 以 `$` 开头的变量引用配置文件 LDAP 部分中的变量。
- 如果您使用明文身份验证方法，请将 `ldaps://` 替换为 `ldap://`。端口 `389` 是 `ldap://` 的默认端口，`636` 是 `ldaps://` 的默认端口。
- 我们假设 `bind_dn` 用户的密码位于 `bind_dn_password.txt`中。

<a id="sync-all-users"></a>

#### 同步所有用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

手动[用户同步](ldap_synchronization.md#user-sync)的输出可以向您展示极狐GitLab 尝试将其用户与 LDAP 同步时发生的情况。进入 [Rails 控制台](#rails-console)，然后运行：

```ruby
Rails.logger.level = Logger::DEBUG

LdapSyncWorker.new.perform
```

接下来，[了解如何阅读输出](#example-console-output-after-a-user-sync)。

<a id="example-console-output-after-a-user-sync"></a>

##### 用户同步后的控制台输出示例

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[手动用户同步](#sync-all-users)的输出非常冗长，单个用户成功同步的输出可能如下所示：

```shell
Syncing user John, email@example.com
  Identity Load (0.9ms)  SELECT  "identities".* FROM "identities" WHERE "identities"."user_id" = 20 AND (provider LIKE 'ldap%') LIMIT 1
Instantiating Gitlab::Auth::Ldap::Person with LDIF:
dn: cn=John Smith,ou=people,dc=example,dc=com
cn: John Smith
mail: email@example.com
memberof: cn=admin_staff,ou=people,dc=example,dc=com
uid: John

  UserSyncedAttributesMetadata Load (0.9ms)  SELECT  "user_synced_attributes_metadata".* FROM "user_synced_attributes_metadata" WHERE "user_synced_attributes_metadata"."user_id" = 20 LIMIT 1
   (0.3ms)  BEGIN
  Namespace Load (1.0ms)  SELECT  "namespaces".* FROM "namespaces" WHERE "namespaces"."owner_id" = 20 AND "namespaces"."type" IS NULL LIMIT 1
  Route Load (0.8ms)  SELECT  "routes".* FROM "routes" WHERE "routes"."source_id" = 27 AND "routes"."source_type" = 'Namespace' LIMIT 1
  Ci::Runner Load (1.1ms)  SELECT "ci_runners".* FROM "ci_runners" INNER JOIN "ci_runner_namespaces" ON "ci_runners"."id" = "ci_runner_namespaces"."runner_id" WHERE "ci_runner_namespaces"."namespace_id" = 27
   (0.7ms)  COMMIT
   (0.4ms)  BEGIN
  Route Load (0.8ms)  SELECT "routes".* FROM "routes" WHERE (LOWER("routes"."path") = LOWER('John'))
  Namespace Load (1.0ms)  SELECT  "namespaces".* FROM "namespaces" WHERE "namespaces"."id" = 27 LIMIT 1
  Route Exists (0.9ms)  SELECT  1 AS one FROM "routes" WHERE LOWER("routes"."path") = LOWER('John') AND "routes"."id" != 50 LIMIT 1
  User Update (1.1ms)  UPDATE "users" SET "updated_at" = '2019-10-17 14:40:59.751685', "last_credential_check_at" = '2019-10-17 14:40:59.738714' WHERE "users"."id" = 20
```

这里内容很多，让我们逐一介绍调试时可能有帮助的部分。

首先，极狐GitLab 会查找所有之前使用 LDAP 登录过的用户，并对它们进行迭代。每个用户的同步都以下面这一行开始，其中包含该用户当前的极狐GitLab 用户名和电子邮件：

```shell
Syncing user John, email@example.com
```

如果您在输出中找不到某个用户的极狐GitLab 电子邮件，则该用户尚未使用 LDAP 登录过。

接下来，极狐GitLab 会在其 `identities` 表中搜索此用户与已配置的 LDAP 提供商之间的现有链接：

```sql
  Identity Load (0.9ms)  SELECT  "identities".* FROM "identities" WHERE "identities"."user_id" = 20 AND (provider LIKE 'ldap%') LIMIT 1
```

该身份对象包含极狐GitLab 用于在 LDAP 中查找该用户的 DN。如果找不到 DN，则改用电子邮件。我们可以看到此用户在 LDAP 中被找到了：

```shell
Instantiating Gitlab::Auth::Ldap::Person with LDIF:
dn: cn=John Smith,ou=people,dc=example,dc=com
cn: John Smith
mail: email@example.com
memberof: cn=admin_staff,ou=people,dc=example,dc=com
uid: John
```

如果使用 DN 或电子邮件都未能在 LDAP 中找到该用户，您可能会看到以下消息：

```shell
LDAP search error: No Such Object
```

在这种情况下，该用户会被阻止：

```shell
  User Update (0.4ms)  UPDATE "users" SET "state" = $1, "updated_at" = $2 WHERE "users"."id" = $3  [["state", "ldap_blocked"], ["updated_at", "2019-10-18 15:46:22.902177"], ["id", 20]]
```

在 LDAP 中找到该用户后，输出的其余部分会用任何更改更新极狐GitLab 数据库。

<a id="query-a-user-in-ldap"></a>

#### 在 LDAP 中查询用户

这会测试极狐GitLab 能否访问 LDAP 并读取特定用户。它可以暴露连接和/或查询 LDAP 时可能出现的、在极狐GitLab UI 中似乎静默失败的潜在错误。

```ruby
Rails.logger.level = Logger::DEBUG

adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain') # If `main` is the LDAP provider
Gitlab::Auth::Ldap::Person.find_by_uid('<uid>', adapter)
```

<a id="merge-request-approval-rules"></a>

### 合并请求审批规则

当发生 LDAP 连接问题时，用户可能会在同步操作期间从合并请求审批规则中被移除。这可能导致审批规则变为空并被标记为无效。

<a id="approval-rules-fail-when-ldap-connectivity-is-lost"></a>

#### LDAP 连接丢失时审批规则失败

如果您的 LDAP 服务器暂时不可用或绑定账号失败：

- 配置在基于 LDAP 的审批规则中的用户可能会在下一个同步周期中被移除。
- 没有剩余用户的审批规则会变为[无效](../../../user/project/merge_requests/approvals/_index.md#invalid-rules)。
- 标准审批规则会被标记为**自动批准**，不再阻止合并。
- 合并请求审批策略规则会被标记为**需要操作**，并继续阻止合并。

要防止标准审批规则被静默绕过：

- 确保您的 LDAP 服务器具有高可用性和可靠的连接。
- 监控 LDAP 同步操作是否失败。
- 对于关键安全要求，请使用[合并请求审批策略](../../../user/application_security/policies/merge_request_approval_policies.md)而不是标准审批规则。审批策略提供更强的强制执行能力，并且不会失效放行。

有关审批规则行为的更多信息，请参阅[无效规则](../../../user/project/merge_requests/approvals/_index.md#invalid-rules)。

如果用户因 LDAP 问题而从审批规则中被移除，当 LDAP 连接恢复时，他们不会自动被重新添加。您可能需要手动恢复审批规则或从备份中恢复。

<a id="group-memberships"></a>

### 群组成员关系

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="memberships-not-granted"></a>

#### 未授予成员关系

有时您可能认为某个特定用户应通过 LDAP 群组同步添加到极狐GitLab 群组，但由于某种原因并未发生。您可以检查以下几项来调试该情况。

- 确保 LDAP 配置指定了 `group_base`。[此配置](ldap_synchronization.md#group-sync)是群组同步正常工作的必要条件。
- 确保已将正确的 [LDAP 群组链接添加到极狐GitLab 群组](ldap_synchronization.md#add-group-links)。
- 检查该用户是否具有 LDAP 身份：
  1. 以管理员用户身份登录极狐GitLab。
  1. 在右上角，选择**管理员**。
  1. 在左侧边栏中，选择**概览** > **用户**。
  1. 搜索该用户。
  1. 通过选择其名称打开该用户。不要选择**编辑**。
  1. 选择**身份**标签页。应该有一个 LDAP 身份，其 `Identifier` 为 LDAP DN。如果没有，则该用户尚未使用 LDAP 登录，必须先登录。
- 您已等待一小时或[配置的间隔时间](ldap_synchronization.md#adjust-ldap-sync-schedule)让群组同步。要加快此过程，可以转到极狐GitLab 群组的**管理** > **成员**，然后按**立即同步**（同步一个群组），或者[运行群组同步 Rake 任务](../../raketasks/ldap.md#run-a-group-sync)（同步所有群组）。

如果所有检查看起来都没问题，请在 Rails 控制台中进行更高级的调试。

1. 进入 [Rails 控制台](#rails-console)。
1. 选择一个极狐GitLab 群组进行测试。该群组应已配置 LDAP 群组链接。
1. 启用调试日志记录，找到所选的极狐GitLab 群组，并[将其与 LDAP 同步](#sync-one-group)。
1. 查看同步的输出。请参阅[示例日志输出](#example-console-output-after-a-group-sync)了解如何阅读输出。
1. 如果您仍然无法看出该用户为何未被添加，请[直接查询 LDAP 群组](#query-a-group-in-ldap)以查看列出了哪些成员。
1. 该用户的 DN 或 UID 是否在查询到的群组的某个列表中？此处的某个 DN 或 UID 应与之前检查的 LDAP 身份中的“Identifier”匹配。如果不匹配，则该用户似乎不在该 LDAP 群组中。

<a id="cannot-add-service-account-user-to-group-when-ldap-sync-is-enabled"></a>

#### 启用 LDAP 同步时无法将服务账号用户添加到群组

当为群组启用 LDAP 同步时，您无法使用“邀请”对话框邀请新的群组成员。

要解决此问题，您可以使用[群组成员 API 端点](../../../api/group_members.md#add-a-group-member)邀请服务账号加入群组或将其从群组中移除。

<a id="administrator-privileges-not-granted"></a>

#### 未授予管理员权限

当[您为 LDAP 群组分配管理员角色](ldap_synchronization.md#assign-an-admin-role-to-an-ldap-group)，但配置的用户未被授予正确的管理员权限时，请确认以下条件是否成立：

- [也配置了 `group_base`](ldap_synchronization.md#group-sync)。
- `gitlab.rb`中配置的 `admin_group` 是 CN，而不是 DN 或数组。
- 此 CN 位于配置的 `group_base` 范围内。
- `admin_group`的成员已使用其 LDAP 凭据登录极狐GitLab。极狐GitLab 仅向账号已连接到 LDAP 的用户授予管理员访问权限。

如果上述所有条件都成立，但用户仍未获得访问权限，请在 Rails 控制台中[运行手动群组同步](#sync-all-groups)，并[查看输出](#example-console-output-after-a-group-sync)，了解极狐GitLab 同步 `admin_group` 时发生的情况。

<a id="sync-now-button-stuck-in-the-ui"></a>

#### UI 中的“立即同步”按钮卡住

群组的**群组** > **成员**页面上的**立即同步**按钮可能会卡住。该按钮在被按下并重新加载页面后会卡住。之后该按钮便无法再次选择。

**立即同步**按钮可能因多种原因而卡住，需要针对具体情况进行调试。以下是该问题的两种可能原因及可能的解决方案。

<a id="invalid-memberships"></a>

##### 无效的成员关系

如果群组的某些成员或请求成员无效，**立即同步**按钮会卡住。您可以在[相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/348226)中跟踪改善此问题可见性的进展。您可以使用 [Rails 控制台](#rails-console) 来确认此问题是否导致**立即同步**按钮卡住：

```ruby
# Find the group in question
group = Group.find_by(name: 'my_gitlab_group')

# Look for errors on the Group itself
group.valid?
group.errors.map(&:full_messages)

# Look for errors among the group's members and requesters
group.requesters.map(&:valid?)
group.requesters.map(&:errors).map(&:full_messages)
group.members.map(&:valid?)
group.members.map(&:errors).map(&:full_messages)
```

显示的错误可以识别问题并指出解决方案。例如，支持团队曾看到以下错误：

```ruby
irb(main):018:0> group.members.map(&:errors).map(&:full_messages)
=> [["The member's email address is not allowed for this group. Go to the group's 'Settings > General' page, and check 'Restrict membership by email domain'."]]
```

此错误表明某位管理员选择[按电子邮件域限制群组成员关系](../../../user/group/access_and_permissions.md#restrict-group-access-by-domain)，但域中存在拼写错误。修复域设置后，**立即同步**按钮恢复正常工作。

<a id="missing-ldap-configuration-on-sidekiq-nodes"></a>

##### Sidekiq 节点上缺少 LDAP 配置

当极狐GitLab 扩展到多个节点，并且[运行 Sidekiq 的节点上的 `/etc/gitlab/gitlab.rb`](../../sidekiq/_index.md#configure-ldap-and-user-or-group-synchronization)中缺少 LDAP 配置时，**立即同步**按钮会卡住。在这种情况下，Sidekiq 作业似乎会消失。

Sidekiq 节点上需要 LDAP，因为 LDAP 有多个异步运行的作业需要本地 LDAP 配置：

- [用户同步](ldap_synchronization.md#user-sync)。
- [群组同步](ldap_synchronization.md#group-sync)。

您可以通过在每个运行 Sidekiq 的节点上运行[检查 LDAP 的 Rake 任务](#ldap-check)来测试是否是缺少 LDAP 配置导致的问题。如果此节点上的 LDAP 设置正确，它会连接到 LDAP 服务器并返回用户。

要解决此问题，请在 Sidekiq 节点上[配置 LDAP](../../sidekiq/_index.md#configure-ldap-and-user-or-group-synchronization)。配置完成后，运行[检查 LDAP 的 Rake 任务](#ldap-check)以确认极狐GitLab 节点可以连接到 LDAP。

<a id="sync-all-groups"></a>

#### 同步所有群组

> [!note]
> 当无需调试而手动同步所有群组时，
> 请[改用 Rake 任务](../../raketasks/ldap.md#run-a-group-sync)。

手动[群组同步](ldap_synchronization.md#group-sync)的输出可以向您展示极狐GitLab 将其 LDAP 群组成员关系与 LDAP 同步时发生的情况。进入 [Rails 控制台](#rails-console)，然后运行：

```ruby
Rails.logger.level = Logger::DEBUG

LdapAllGroupsSyncWorker.new.perform
```

接下来，[了解如何阅读输出](#example-console-output-after-a-group-sync)。

<a id="example-console-output-after-a-group-sync"></a>

##### 群组同步后的控制台输出示例

与用户同步的输出类似，[手动群组同步](#sync-all-groups)的输出也非常冗长。不过，它包含大量有用的信息。

指示同步实际开始的位置：

```shell
Started syncing 'ldapmain' provider for 'my_group' group
```

以下条目显示了极狐GitLab 在 LDAP 服务器中看到的所有用户 DN 的数组。这些 DN 是单个 LDAP 群组的用户，而不是极狐GitLab 群组的用户。如果您有多个 LDAP 群组链接到此极狐GitLab 群组，您会看到多个这样的日志条目——每个 LDAP 群组一个。如果您在此日志条目中看不到某个 LDAP 用户 DN，则说明在我们进行查找时 LDAP 未返回该用户。请验证该用户确实在该 LDAP 群组中。

```shell
Members in 'ldap_group_1' LDAP group: ["uid=john0,ou=people,dc=example,dc=com",
"uid=mary0,ou=people,dc=example,dc=com", "uid=john1,ou=people,dc=example,dc=com",
"uid=mary1,ou=people,dc=example,dc=com", "uid=john2,ou=people,dc=example,dc=com",
"uid=mary2,ou=people,dc=example,dc=com", "uid=john3,ou=people,dc=example,dc=com",
"uid=mary3,ou=people,dc=example,dc=com", "uid=john4,ou=people,dc=example,dc=com",
"uid=mary4,ou=people,dc=example,dc=com"]
```

在每个条目之后不久，您会看到一个已解析成员访问级别的哈希。此哈希表示极狐GitLab 认为应有权访问此群组的所有用户 DN，以及各自的访问级别（角色）。此哈希是累加的，根据额外的 LDAP 群组查找，可能会添加更多 DN，或修改现有条目。此条目的最后一次出现应准确指示极狐GitLab 认为应添加到该群组的用户。

> [!note]
> 10 是 `Guest`，20 是 `Reporter`，25 是 `Security Manager`，30 是 `Developer`，40 是 `Maintainer`
> 而 50 是 `Owner`。

```shell
Resolved 'my_group' group member access: {"uid=john0,ou=people,dc=example,dc=com"=>30,
"uid=mary0,ou=people,dc=example,dc=com"=>30, "uid=john1,ou=people,dc=example,dc=com"=>30,
"uid=mary1,ou=people,dc=example,dc=com"=>30, "uid=john2,ou=people,dc=example,dc=com"=>30,
"uid=mary2,ou=people,dc=example,dc=com"=>30, "uid=john3,ou=people,dc=example,dc=com"=>30,
"uid=mary3,ou=people,dc=example,dc=com"=>30, "uid=john4,ou=people,dc=example,dc=com"=>30,
"uid=mary4,ou=people,dc=example,dc=com"=>30}
```

看到类似以下的警告并不罕见。这些警告表明极狐GitLab 本应将用户添加到群组，但在极狐GitLab 中找不到该用户。通常这无需担心。

如果您认为某个特定用户应该已存在于极狐GitLab 中，但您看到了此条目，则可能是由于极狐GitLab 中存储的 DN 不匹配。请参阅[用户 DN 和电子邮件已更改](#user-dn-and-email-have-changed)以更新该用户的 LDAP 身份。

```shell
User with DN `uid=john0,ou=people,dc=example,dc=com` should have access
to 'my_group' group but there is no user in GitLab with that
identity. Membership will be updated when the user signs in for
the first time.
```

最后，以下条目表示此群组的同步已完成：

```shell
Finished syncing all providers for 'my_group' group
```

当所有配置的群组链接都已同步后，极狐GitLab 会查找任何管理员或外部用户进行同步：

```shell
Syncing admin users for 'ldapmain' provider
```

输出看起来与单个群组的情况类似，然后这一行表示同步已完成：

```shell
Finished syncing admin users for 'ldapmain' provider
```

如果您尚未[分配管理员角色](ldap_synchronization.md#assign-an-admin-role-to-an-ldap-group)，您会看到以下消息：

```shell
No `admin_group` configured for 'ldapmain' provider. Skipping
```

<a id="sync-one-group"></a>

#### 同步一个群组

[同步所有群组](#sync-all-groups)会在输出中产生大量噪音，当您只对排查单个极狐GitLab 群组的成员关系感兴趣时，这会分散注意力。在这种情况下，您可以只同步此群组并查看其调试输出，方法如下：

```ruby
Rails.logger.level = Logger::DEBUG

# Find the GitLab group.
# If the output is `nil`, the group could not be found.
# If a bunch of group attributes are in the output, your group was found successfully.
group = Group.find_by(name: 'my_gitlab_group')

# Sync this group against LDAP
EE::Gitlab::Auth::Ldap::Sync::Group.execute_all_providers(group)
```

输出与[同步所有群组时得到的输出](#example-console-output-after-a-group-sync)类似。

<a id="query-a-group-in-ldap"></a>

#### 在 LDAP 中查询群组

当您想确认极狐GitLab 能否读取某个 LDAP 群组并查看其所有成员时，可以运行以下命令：

```ruby
# Find the adapter and the group itself
adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain') # If `main` is the LDAP provider
ldap_group = EE::Gitlab::Auth::Ldap::Group.find_by_cn('group_cn_here', adapter)

# Find the members of the LDAP group
ldap_group.member_dns
ldap_group.member_uids
```

<a id="ldap-synchronization-does-not-remove-group-creator-from-group"></a>

#### LDAP 同步不会将群组创建者从群组中移除

如果该用户不存在于群组中，[LDAP 同步](ldap_synchronization.md)应将该 LDAP 群组的创建者从该群组中移除。如果运行 LDAP 同步未执行此操作：

1. 将该用户添加到 LDAP 群组。
1. 等待 LDAP 群组同步运行完成。
1. 将该用户从 LDAP 群组中移除。

<a id="user-dn-and-email-have-changed"></a>

### 用户 DN 和电子邮件已更改

如果 LDAP 中的主电子邮件和 DN 都发生更改，极狐GitLab 无法识别用户的正确 LDAP 记录。因此，极狐GitLab 会阻止该用户。为了让极狐GitLab 能够找到该 LDAP 记录，请至少使用以下任一项更新该用户现有的极狐GitLab 个人资料：

- 新的主电子邮件。
- DN 值。

以下脚本会更新所有提供的用户的电子邮件，以免他们被阻止或无法访问其账号。

> [!note]
> 以下脚本要求先移除任何使用新电子邮件地址的新账号。电子邮件地址在极狐GitLab 中必须唯一。

转到 [Rails 控制台](#rails-console)，然后运行：

```ruby
# Each entry must include the old username and the new email
emails = {
  'ORIGINAL_USERNAME' => 'NEW_EMAIL_ADDRESS',
  ...
}

emails.each do |username, email|
  user = User.find_by_username(username)
  user.email = email
  user.skip_reconfirmation!
  user.save!
end
```

然后您可以[运行 UserSync](#sync-all-users) 来同步这些用户各自最新的 DN。

<a id="could-not-authenticate-from-azureactivedirectoryv2-because-invalid-grant"></a>

## 由于 `Invalid grant` 而无法从 AzureActivedirectoryV2 进行身份验证

从 LDAP 转换为 SAML 时，您可能会在 Azure 中收到如下错误：

```plaintext
Authentication failure! invalid_credentials: OAuth2::Error, invalid_grant.
```

当以下两种情况都成立时，会出现此问题：

- 在为这些用户配置 SAML 之后，这些用户的 LDAP 身份仍然存在。
- 您为这些用户禁用了 LDAP。

您会在日志中同时收到 LDAP 和 Azure 元数据，从而在 Azure 中生成该错误。

针对单个用户的变通方法是在**管理员** > **身份**中移除该用户的 LDAP 身份。

要移除多个 LDAP 身份，请使用下面 `Could not authenticate you from Ldapmain because "Unknown provider"` 错误的任一变通方法。

<a id="error-could-not-authenticate-you-from-ldapmain-because-unknown-provider"></a>

## 错误：`Could not authenticate you from Ldapmain because "Unknown provider"`

使用 LDAP 服务器进行身份验证时，您可能会收到以下错误：

```plaintext
Could not authenticate you from Ldapmain because "Unknown provider (ldapsecondary). available providers: ["ldapmain"]".
```

此错误是由于使用了之前通过某个 LDAP 服务器进行身份验证的账号，而该服务器已从您的极狐GitLab 配置中重命名或移除。例如：

- 最初，在极狐GitLab 配置的 `ldap_servers`中设置了 `main` 和 `secondary`。
- `secondary` 设置被移除或重命名为 `main`。
- 尝试登录的用户拥有 `secondary`的 `identify` 记录，但该服务器已不再配置。

使用 [Rails 控制台](../../operations/rails_console.md) 列出受影响的用户，并检查他们拥有哪些 LDAP 服务器的身份：

```ruby
ldap_identities = Identity.where(provider: "ldapsecondary")
ldap_identities.each do |identity|
  u=User.find_by_id(identity.user_id)
  ui=Identity.where(user_id: identity.user_id)
  puts "user: #{u.username}\n   #{u.email}\n   last activity: #{u.last_activity_on}\n   #{identity.provider} ID: #{identity.id} external: #{identity.extern_uid}"
  puts "   all identities:"
  ui.each do |alli|
    puts "    - #{alli.provider} ID: #{alli.id} external: #{alli.extern_uid}"
  end
end;nil
```

您可以通过两种方式解决此错误。

<a id="rename-references-to-the-ldap-server"></a>

### 重命名对 LDAP 服务器的引用

当 LDAP 服务器互为副本，且受影响的用户应能够使用某个已配置的 LDAP 服务器登录时，此解决方案适用。例如，如果现在使用负载均衡器来管理 LDAP 高可用性，并且不再需要单独的次要登录选项。

> [!note]
> 如果 LDAP 服务器彼此不是副本，此解决方案会导致受影响的用户无法登录。

要[重命名对不再配置的 LDAP 服务器的引用](../../raketasks/ldap.md#other-options)，请运行：

```shell
sudo gitlab-rake gitlab:ldap:rename_provider[ldapsecondary,ldapmain]
```

<a id="remove-the-identity-records-that-relate-to-the-removed-ldap-server"></a>

### 移除与已移除的 LDAP 服务器相关的 `identity` 记录

先决条件：

- 确保已启用 `auto_link_ldap_user`。

使用此解决方案，在删除身份后，受影响的用户可以使用已配置的 LDAP 服务器登录，并且极狐GitLab 会创建新的 `identity` 记录。

由于被移除的 LDAP 服务器是 `ldapsecondary`，请在 [Rails 控制台](../../operations/rails_console.md)中删除所有 `ldapsecondary` 身份：

```ruby
ldap_identities = Identity.where(provider: "ldapsecondary")
ldap_identities.each do |identity|
  puts "Destroying identity: #{identity.id} #{identity.provider}: #{identity.extern_uid}"
  identity.destroy!
rescue => e
  puts 'Error generated when destroying identity:\n ' + e.to_s
end; nil
```

<a id="expired-license-causes-errors-with-multiple-ldap-servers"></a>

## 许可证过期会导致多个 LDAP 服务器出现错误

使用[多个 LDAP 服务器](_index.md#use-multiple-ldap-servers)需要有效的许可证。许可证过期可能导致：

- Web 界面中出现 `502` 错误。
- 日志中出现以下错误（实际策略名称取决于 `/etc/gitlab/gitlab.rb`中配置的名称）：

  ```plaintext
  Could not find a strategy with name `Ldapsecondary'. Please ensure it is required or explicitly set it using the :strategy_class option. (Devise::OmniAuth::StrategyNotFound)
  ```

要解决此错误，您必须在无法使用 Web 界面的情况下为极狐GitLab 实例应用新许可证：

1. 移除或注释掉所有非主 LDAP 服务器的极狐GitLab 配置行。
1. [重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)，使其暂时只使用一个 LDAP 服务器。
1. 进入 [Rails 控制台并添加许可证密钥](../../license_file.md#add-a-license-through-the-console)。
1. 在极狐GitLab 配置中重新启用额外的 LDAP 服务器，并再次重新配置极狐GitLab。

<a id="users-are-being-removed-from-group-and-re-added-again"></a>

## 用户被从群组中移除后又再次被添加

如果某个用户在群组同步期间被添加到群组，并在下一次同步时被移除，且这种情况反复发生，请确保该用户没有多个或冗余的 LDAP 身份。

如果其中某个身份是为不再使用的旧 LDAP 提供商添加的，请[移除与已移除的 LDAP 服务器相关的 `identity` 记录](#remove-the-identity-records-that-relate-to-the-removed-ldap-server)。

<a id="debugging-tools"></a>

## 调试工具

<a id="ldap-check"></a>

### LDAP 检查

[检查 LDAP 的 Rake 任务](../../raketasks/ldap.md#check)是一个很有价值的工具，可帮助确定极狐GitLab 能否成功建立到 LDAP 的连接，甚至能否读取用户。

如果无法建立连接，很可能是由于您的配置存在问题，或者防火墙阻止了连接。

- 确保没有防火墙阻止连接，并且极狐GitLab 主机可以访问 LDAP 服务器。
- 在 Rake 检查输出中查找错误消息，这可能会引导您检查 LDAP 配置，以确认配置值（特别是 `host`、`port`、`bind_dn` 和 `password`）是否正确。
- 在[日志](#gitlab-logs)中查找[错误](#connection)，以进一步调试连接失败。

如果极狐GitLab 能够成功连接到 LDAP 但未返回任何用户，请[参阅未找到任何用户时的处理方法](#no-users-are-found)。

<a id="gitlab-logs"></a>

### 极狐GitLab 日志

如果某个用户账号因 LDAP 配置而被阻止或解除阻止，会有一条消息[记录到 `application_json.log`](../../logs/_index.md#application_jsonlog)。

如果在 LDAP 查找期间出现意外错误（配置错误、超时），登录会被拒绝，并有一条消息[记录到 `production.log`](../../logs/_index.md#productionlog)。

<a id="ldapsearch"></a>

### ldapsearch

`ldapsearch` 是一个允许您查询 LDAP 服务器的实用工具。您可以使用它来测试您的 LDAP 设置，并确保您使用的设置能获得您期望的结果。

使用 `ldapsearch` 时，请务必使用您已在 `gitlab.rb` 配置中指定的相同设置，以便确认使用这些确切设置时会发生什么。

在极狐GitLab 主机上运行此命令还有助于确认极狐GitLab 主机与 LDAP 之间没有阻碍。

例如，考虑以下极狐GitLab 配置：

```shell
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
   main: # 'main' is the GitLab 'provider ID' of this LDAP server
     label: 'LDAP'
     host: '127.0.0.1'
     port: 389
     uid: 'uid'
     encryption: 'plain'
     bind_dn: 'cn=admin,dc=ldap-testing,dc=example,dc=com'
     password: 'Password1'
     active_directory: true
     allow_username_or_email_login: false
     block_auto_created_users: false
     base: 'dc=ldap-testing,dc=example,dc=com'
     user_filter: ''
     attributes:
       username: ['uid', 'userid', 'sAMAccountName']
       email:    ['mail', 'email', 'userPrincipalName']
       name:       'cn'
       first_name: 'givenName'
       last_name:  'sn'
     group_base: 'ou=groups,dc=ldap-testing,dc=example,dc=com'
     admin_group: 'gitlab_admin'
EOS
```

您将运行以下 `ldapsearch` 来查找 `bind_dn` 用户：

```shell
ldapsearch -D "cn=admin,dc=ldap-testing,dc=example,dc=com" \
  -w Password1 \
  -p 389 \
  -h 127.0.0.1 \
  -b "dc=ldap-testing,dc=example,dc=com"
```

`bind_dn`、`password`、`port`、`host` 和 `base` 都与 `gitlab.rb`中配置的完全相同。

<a id="use-ldapsearch-with-start_tls-encryption"></a>

#### 将 ldapsearch 与 `start_tls` 加密配合使用

前面的示例以明文方式对端口 389 执行 LDAP 测试。如果您使用 [`start_tls` 加密](_index.md#basic-configuration-settings)，请在 `ldapsearch` 命令中包含：

- `-Z` 标志。
- LDAP 服务器的 FQDN。

您必须包含这些内容，因为在 TLS 协商期间，LDAP 服务器的 FQDN 会与其证书进行比对：

```shell
ldapsearch -D "cn=admin,dc=ldap-testing,dc=example,dc=com" \
  -w Password1 \
  -p 389 \
  -h "testing.ldap.com" \
  -b "dc=ldap-testing,dc=example,dc=com" -Z
```

<a id="use-ldapsearch-with-simple_tls-encryption"></a>

#### 将 ldapsearch 与 `simple_tls` 加密配合使用

如果您使用 [`simple_tls` 加密](_index.md#basic-configuration-settings)（通常在端口 636 上），请在 `ldapsearch` 命令中包含以下内容：

- 使用 `-H` 标志指定 LDAP 服务器 FQDN 和端口。
- 完整构造的 URI。

```shell
ldapsearch -D "cn=admin,dc=ldap-testing,dc=example,dc=com" \
  -w Password1 \
  -H "ldaps://testing.ldap.com:636" \
  -b "dc=ldap-testing,dc=example,dc=com"
```

有关更多信息，请参阅[官方 `ldapsearch` 文档](https://linux.die.net/man/1/ldapsearch)。

<a id="using-adfind-windows"></a>

### 使用 **AdFind**（Windows）

您可以使用 [`AdFind`](https://learn.microsoft.com/en-us/archive/technet-wiki/7535.adfind-command-examples) 实用工具（在基于 Windows 的系统上）来测试您的 LDAP 服务器是否可访问以及身份验证是否正常工作。AdFind 是由 [Joe Richards](https://www.joeware.net/freetools/tools/adfind/index.htm) 构建的免费软件实用工具。

**返回所有对象**

您可以使用过滤器 `objectclass=*` 返回所有目录对象。

```shell
adfind -h ad.example.org:636 -ssl -u "CN=GitLabSRV,CN=Users,DC=GitLab,DC=org" -up Password1 -b "OU=GitLab INT,DC=GitLab,DC=org" -f (objectClass=*)
```

**使用过滤器返回单个对象**

您还可以通过指定对象名称或完整 DN 来检索单个对象。在此示例中，我们仅指定对象名称 `CN=Leroy Fox`。

```shell
adfind -h ad.example.org:636 -ssl -u "CN=GitLabSRV,CN=Users,DC=GitLab,DC=org" -up Password1 -b "OU=GitLab INT,DC=GitLab,DC=org" -f "(&(objectcategory=person)(CN=Leroy Fox))"
```

<a id="rails-console"></a>

### Rails 控制台

> [!warning]
> 使用 Rails 控制台创建、读取、修改和销毁数据非常容易。请务必完全按照所列命令运行。

Rails 控制台是帮助调试 LDAP 问题的宝贵工具。它允许您通过运行命令并查看极狐GitLab 如何响应来直接与应用程序交互。

有关如何使用 Rails 控制台的说明，请参阅此[指南](../../operations/rails_console.md#starting-a-rails-console-session)。

<a id="enable-debug-output"></a>

#### 启用调试输出

这会提供调试输出，显示极狐GitLab 正在做什么以及使用什么。此值不会被持久化，仅在 Rails 控制台的此会话中启用。

要在 Rails 控制台中启用调试输出，请[进入 Rails 控制台](#rails-console) 并运行：

```ruby
Rails.logger.level = Logger::DEBUG
```

<a id="get-all-error-messages-associated-with-groups-subgroups-members-and-requesters"></a>

#### 获取与群组、子群组、成员和请求者相关的所有错误消息

收集与群组、子群组、成员和请求者相关的错误消息。这会捕获可能不会出现在 Web 界面中的错误消息。这对于排查 [LDAP 群组同步](ldap_synchronization.md#group-sync)问题以及用户及其在群组和子群组中的成员关系出现的意外行为尤其有帮助。

```ruby
# Find the group and subgroup
group = Group.find_by_full_path("parent_group")
subgroup = Group.find_by_full_path("parent_group/child_group")

# Group and subgroup errors
group.valid?
group.errors.map(&:full_messages)

subgroup.valid?
subgroup.errors.map(&:full_messages)

# Group and subgroup errors for the members AND requesters
group.requesters.map(&:valid?)
group.requesters.map(&:errors).map(&:full_messages)
group.members.map(&:valid?)
group.members.map(&:errors).map(&:full_messages)
group.members_and_requesters.map(&:errors).map(&:full_messages)

subgroup.requesters.map(&:valid?)
subgroup.requesters.map(&:errors).map(&:full_messages)
subgroup.members.map(&:valid?)
subgroup.members.map(&:errors).map(&:full_messages)
subgroup.members_and_requesters.map(&:errors).map(&:full_messages)
```
