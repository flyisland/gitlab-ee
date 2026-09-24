---
stage: 软件供应链安全
group: 认证
info: 要确定与此页面相关的阶段/组所分配的技术文档工程师，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: LDAP 故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您是管理员，请使用以下信息来排查 LDAP 问题。

## 常见问题及工作流程

<a id="common-problems-workflows"></a>

### 连接

<a id="connection"></a>

#### 连接被拒绝

如果在尝试连接到 LDAP 服务器时收到 `连接被拒绝` 错误消息，请检查极狐GitLab 使用的 LDAP `端口` 和 `加密` 设置。常见的组合是 `加密：'plain'` 和 `端口：389`，或 `加密：'simple_tls'` 和 `端口：636`。

#### 连接超时

如果极狐GitLab 无法访问您的 LDAP 端点，您会看到类似以下的消息：

```plaintext
无法从 Ldapmain 为您进行认证，原因是“连接超时 - 用户指定的超时时间”。
```

如果您配置的 LDAP 提供程序和/或端点处于离线状态或因其他原因无法被极狐GitLab 访问，那么任何 LDAP 用户都将无法认证和登录。
极狐GitLab 不会缓存或存储 LDAP 用户的凭据以在 LDAP 中断期间提供认证。

如果您看到此错误，请联系您的 LDAP 提供程序或管理员。

#### 转介错误

如果在日志中看到 `LDAP 搜索错误：转介`，或者在排查 LDAP 群组同步时，此错误可能表示存在配置问题。LDAP 配置文件 `/etc/gitlab/gitlab.rb`（Omnibus）或 `config/gitlab.yml`（源码）采用 YAML 格式，并且对缩进敏感。请检查 `group_base` 和 `admin_group` 配置键是否相对于服务器标识符缩进了 2 个空格。默认标识符是 `main`，示例如下所示：

```yaml
main: # 'main' 是此 LDAP 服务器的极狐GitLab 'provider ID'
  label: 'LDAP'
  host: 'ldap.example.com'
  # ...
  group_base: 'cn=my_group,ou=groups,dc=example,dc=com'
  admin_group: 'my_admin_group'
```

#### 查询 LDAP

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下操作允许您使用 Rails 控制台在 LDAP 中执行搜索。根据您的目的，直接查询[用户](#query-a-user-in-ldap)或[群组](#query-a-group-in-ldap)，或者甚至[使用 `ldapsearch`](#ldapsearch) 可能更合适。

```ruby
adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain')
options = {
    # :base 是必需的
    # 使用 .base 或 .group_base
    base: adapter.config.group_base,

    # :filter 是可选的
    # 'cn' 在 :base 下查找所有 "cn"
    # '*' 是搜索字符串 - 这里是通配符
    filter: Net::LDAP::Filter.eq('cn', '*'),

    # :attributes 是可选的
    # 我们要获取返回的属性
    attributes: %w(dn cn memberuid member submember uniquemember memberof)
}
adapter.ldap_search(options)
```

在过滤器中使用 OID 时，请将 `Net::LDAP::Filter.eq` 替换为 `Net::LDAP::Filter.construct`:

```ruby
adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain')
options = {
    # :base 是必需的
    # 使用 .base 或 .group_base
    base: adapter.config.base,

    # :filter 是可选的
    # 此过滤器包含 OID 1.2.840.113556.1.4.1941
    # 它将在 LDAP 目录中搜索组 gitlab_grp 的所有直接和嵌套成员
    filter: Net::LDAP::Filter.construct("(memberOf:1.2.840.113556.1.4.1941:=CN=gitlab_grp,DC=example,DC=com)"),

    # :attributes 是可选的
    # 我们要获取返回的属性
    attributes: %w(dn cn memberuid member submember uniquemember memberof)
}
adapter.ldap_search(options)
```

有关此代码如何运行的示例，请[查看 `Adapter` 模块](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/ee/lib/ee/gitlab/auth/ldap/adapter.rb)。

### 用户登录

<a id="user-sign-ins"></a>

#### 未找到任何用户

如果[您已确认](#ldap-check)可以建立与 LDAP 的连接，但极狐GitLab 在输出中未显示 LDAP 用户，则最可能的原因之一是：

- `bind_dn` 用户没有足够的权限遍历用户树。
- 用户不属于[已配置的 `base`](_index.md#configure-ldap)。
- [已配置的 `user_filter`](_index.md#set-up-ldap-user-filter) 阻止了对这些用户的访问。

在这种情况下，您可以使用现有的 LDAP 配置（位于 `/etc/gitlab/gitlab.rb` 中）通过 [`ldapsearch`](#ldapsearch) 来确认以上哪一个原因是正确的。

#### 用户无法登录

用户可能因多种原因而无法登录。首先，您可以问自己以下问题：

- 该用户是否属于 LDAP 中[已配置的 `base`](_index.md#configure-ldap) 之下？用户必须在此 `base` 下才能登录。
- 该用户是否通过了[已配置的 `user_filter`](_index.md#set-up-ldap-user-filter) 的筛选？如果未配置筛选器，则可以忽略此问题。如果已配置，则用户也必须通过此筛选器才能被允许登录。
  - 请参阅我们关于[调试 `user_filter`](#debug-ldap-user-filter) 的文档。

如果上述问题都没问题，那么下一步是在重现问题时查看日志本身。

- 让用户尝试登录并使其失败。
- [查看输出](#gitlab-logs)中是否有关于登录的错误或其他消息。您可能会在此页面上看到其他错误消息之一，在这种情况下，该部分可以帮助解决问题。

如果日志未能定位问题的根本原因，请使用 [Rails 控制台](#rails-console)[查询此用户](#query-a-user-in-ldap)，以查看极狐GitLab 是否能够从 LDAP 服务器读取该用户。

也可以通过[调试用户同步](#sync-all-users)来进行进一步调查。

#### 用户看到错误 `无效的登录名或密码。`

{{< history >}}

- 在极狐GitLab 16.10 引入。

{{< /history >}}

如果用户看到此错误，可能是因为他们尝试使用**标准**登录表单而不是**LDAP**登录表单进行登录。

要解决此问题，请让用户在**LDAP**登录表单中输入他们的 LDAP 用户名和密码。

#### 登录时凭据无效

如果在 LDAP 上使用的登录凭据是准确的，请确保对于相关用户来说，以下几点是成立的：

- 确保您用于绑定的用户有足够的权限读取用户的树并遍历它。
- 检查 `user_filter` 是否未阻止原本有效的用户。
- 运行 [LDAP 检查命令](#ldap-check)，以确保 LDAP 设置正确，并且[极狐GitLab 可以看到您的用户](#no-users-are-found)。

#### 您的 LDAP 账户访问被拒绝

存在一个[错误](https://gitlab.com/gitlab-org/gitlab/-/issues/235930)，可能会影响具有[审计员级别访问权限](../../auditor_users.md)的用户。当从专业版/旗舰版降级时，审计员用户尝试登录可能会看到以下消息：`您的 LDAP 账户访问被拒绝`。

解决方法：更改受影响用户的访问级别。

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择受影响用户的姓名。
1. 在右上角，选择**编辑**。
1. 将用户的访问级别从 `Regular` 更改为 `Administrator`（反之亦然）。
1. 在页面底部，选择**保存更改**。
1. 在右上角，再次选择**编辑**。
1. 恢复用户的原始访问级别（`Regular` 或 `Administrator`），然后再次选择**保存更改**。

现在用户应该可以登录了。

#### 电子邮件已被占用

用户尝试使用正确的 LDAP 凭据登录，但被拒绝访问，并且 [production.log](../../logs/_index.md#productionlog) 显示类似以下的错误：

```plaintext
(LDAP) 保存用户 <用户 DN> (email@example.com) 时出错：["电子邮件已被占用"]
```

此错误指的是 LDAP 中的电子邮件地址 `email@example.com`。在极狐GitLab 中，电子邮件地址必须是唯一的，并且 LDAP 链接到用户的主电子邮件地址（而不是其可能众多的辅助电子邮件地址之一）。另一个用户（甚至是同一用户）将 `email@example.com` 设置为辅助电子邮件，这导致了此错误。

我们可以使用 [Rails 控制台](#rails-console) 来检查这个冲突的电子邮件地址来自哪里。在控制台中，运行以下命令：

```ruby
# 这将在主电子邮件和辅助电子邮件中搜索
user = User.find_by_any_email('email@example.com')
user.username
```

这会显示哪个用户拥有此电子邮件地址。必须采取以下两步之一：

- 为了在使用 LDAP 登录时为此用户创建一个新的极狐GitLab 用户/用户名，请删除该辅助电子邮件以消除冲突。
- 要使用现有的极狐GitLab 用户/用户名与此用户配合 LDAP 使用，请将此电子邮件作为辅助电子邮件删除，并将其设为主电子邮件，这样极狐GitLab 就会将此配置文件与 LDAP 身份关联起来。

用户可以[在其个人资料中](../../../user/profile/_index.md#access-your-user-profile)执行这两个步骤中的任何一个，或者管理员也可以执行。

#### 项目限制错误

以下错误表明某个限制或约束已激活，但关联的数据字段不包含任何数据：

- `项目限制不能为空。`
- `项目限制不是数字。`

要解决此问题：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开以下两项：
   - **账户和限制**。
   - **新用户账户限制**。
1. 例如，检查**默认项目限制**或**允许的新用户账户域名**字段，并确保配置了相关的值。

#### 调试 LDAP 用户筛选器

[`ldapsearch`](#ldapsearch) 允许您测试已配置的[用户筛选器](_index.md#set-up-ldap-user-filter)，以确认它返回了您期望返回的用户。

```shell
ldapsearch -H ldaps://$host:$port -D "$bind_dn" -y bind_dn_password.txt  -b "$base" "$user_filter" sAMAccountName
```

- 以 `$` 开头的变量引用配置文件 LDAP 部分中的变量。
- 如果您使用的是纯认证方法，请将 `ldaps://` 替换为 `ldap://`。端口 `389` 是默认的 `ldap://` 端口，`636` 是默认的 `ldaps://` 端口。
- 我们假设 `bind_dn` 用户的密码在 `bind_dn_password.txt` 中。

#### 同步所有用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

手动[用户同步](ldap_synchronization.md#user-sync)的输出可以显示极狐GitLab 尝试根据 LDAP 同步其用户时发生的情况。进入 [Rails 控制台](#rails-console)，然后运行：

```ruby
Rails.logger.level = Logger::DEBUG

LdapSyncWorker.new.perform
```

接下来，[了解如何阅读输出](#example-console-output-after-a-user-sync)。

##### 用户同步后的控制台输出示例

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[手动用户同步](#sync-all-users)的输出非常详细，单个用户成功同步的输出可能如下所示：

```shell
正在同步用户 John, email@example.com
  Identity Load (0.9ms)  SELECT  "identities".* FROM "identities" WHERE "identities"."user_id" = 20 AND (provider LIKE 'ldap%') LIMIT 1
使用以下 LDIF 实例化 Gitlab::Auth::Ldap::Person：
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

这里包含很多信息，所以让我们来看看哪些对调试可能有帮助。

首先，极狐GitLab 查找所有之前通过 LDAP 登录过的用户，并对它们进行迭代。每次用户同步都会以包含用户当前在极狐GitLab 中的用户名和电子邮件的行开始：

```shell
正在同步用户 John, email@example.com
```

如果您在输出中没有找到特定用户的极狐GitLab 电子邮件，那么该用户尚未通过 LDAP 登录过。

接下来，极狐GitLab 在其 `identities` 表中搜索此用户与已配置的 LDAP 提供程序之间的现有链接：

```sql
  Identity Load (0.9ms)  SELECT  "identities".* FROM "identities" WHERE "identities"."user_id" = 20 AND (provider LIKE 'ldap%') LIMIT 1
```

身份对象包含极狐GitLab 用于在 LDAP 中查找用户的 DN。如果找不到 DN，则改用电子邮件。我们可以看到在 LDAP 中找到了此用户：

```shell
使用以下 LDIF 实例化 Gitlab::Auth::Ldap::Person：
dn: cn=John Smith,ou=people,dc=example,dc=com
cn: John Smith
mail: email@example.com
memberof: cn=admin_staff,ou=people,dc=example,dc=com
uid: John
```

如果使用 DN 或电子邮件在 LDAP 中都未找到该用户，您可能会看到以下消息：

```shell
LDAP 搜索错误：没有此类对象
```

在这种情况下，用户将被阻止：

```shell
  User Update (0.4ms)  UPDATE "users" SET "state" = $1, "updated_at" = $2 WHERE "users"."id" = $3  [["state", "ldap_blocked"], ["updated_at", "2019-10-18 15:46:22.902177"], ["id", 20]]
```

在 LDAP 中找到用户后，输出的其余部分会更新极狐GitLab 数据库的任何更改。

#### 在 LDAP 中查询用户

这将测试极狐GitLab 是否能访问 LDAP 并读取特定用户。它可以暴露在连接和/或查询 LDAP 时可能被忽略的错误，这些错误在极狐GitLab UI 中可能无声地失败。

```ruby
Rails.logger.level = Logger::DEBUG

adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain') # 如果 LDAP 提供程序是 `main`
Gitlab::Auth::Ldap::Person.find_by_uid('<uid>', adapter)
```

### 群组成员资格

<a id="group-memberships"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

#### 未授予成员资格

有时您可能认为某个用户应该通过 LDAP 群组同步被添加到某个极狐GitLab 群组中，但由于某种原因却没有发生。您可以检查以下几个方面来调试这种情况。

- 确保 LDAP 配置中指定了 `group_base`。要使用群组同步正常工作，[此配置](ldap_synchronization.md#group-sync)是必需的。
- 确保将正确的[ LDAP 组链接添加到了极狐GitLab 群组](ldap_synchronization.md#add-group-links)。
- 检查用户是否具有 LDAP 身份：
  1. 以管理员用户身份登录极狐GitLab。
  1. 在右上角，选择**管理员**。
  1. 在左侧边栏中，选择**概览** > **用户**。
  1. 搜索该用户。
  1. 通过选择用户名打开用户。不要选择**编辑**。
  1. 选择**身份**选项卡。应该有一个 LDAP 身份，其 `标识符` 为一个 LDAP DN。如果没有，则此用户尚未通过 LDAP 登录过，必须先登录。
- 您已经等待了一个小时或[配置的间隔时间](ldap_synchronization.md#adjust-ldap-sync-schedule)以便群组同步。要加快此过程，可以转到极狐GitLab 群组 **管理** > **成员**，然后按**立即同步**（同步一个群组），或[运行群组同步 Rake 任务](../../raketasks/ldap.md#run-a-group-sync)（同步所有群组）。

如果所有检查都看起来没问题，可以在 Rails 控制台中进行更深入的调试。

1. 进入 [Rails 控制台](#rails-console)。
1. 选择一个要测试的极狐GitLab 群组。此群组应已配置了 LDAP 组链接。
1. 启用调试日志，找到选定的极狐GitLab 群组，然后[将其与 LDAP 同步](#sync-one-group)。
1. 查看同步的输出。如何阅读输出，请参见[示例日志输出](#example-console-output-after-a-group-sync)。
1. 如果您仍然无法找出用户未被添加的原因，请[直接查询 LDAP 群组](#query-a-group-in-ldap)，以查看列出了哪些成员。
1. 用户的 DN 或 UID 是否在查询到的群组列表中？此处的某个 DN 或 UID 应与之前检查的 LDAP 身份中的 '标识符' 匹配。如果不匹配，则该用户似乎不在该 LDAP 群组中。

#### 启用 LDAP 同步时无法将服务账户用户添加到群组

当为群组启用了 LDAP 同步时，您不能使用“邀请”对话框邀请新的群组成员。

要在极狐GitLab 16.8 及更高版本中解决此问题，您可以使用[群组成员 API 端点](../../../api/group_members.md#add-a-group-member)邀请或移除服务账户。

#### 未授予管理员权限

当您[将管理员角色分配给 LDAP 群组](ldap_synchronization.md#assign-an-admin-role-to-an-ldap-group)，但配置的用户未获得正确的管理员权限时，请确认以下条件是否成立：

- 还[配置了 `group_base`](ldap_synchronization.md#group-sync)。
- `gitlab.rb` 中配置的 `admin_group` 是一个 CN，而不是 DN 或数组。
- 此 CN 属于已配置的 `group_base` 的范围之内。
- `admin_group` 的成员已经使用其 LDAP 凭据登录过极狐GitLab。极狐GitLab 仅向账户已连接到 LDAP 的用户授予管理员访问权限。

如果上述所有条件均成立，但用户仍未获得访问权限，请在 Rails 控制台中[运行手动群组同步](#sync-all-groups)，并[查看输出](#example-console-output-after-a-group-sync)，查看极狐GitLab 同步 `admin_group` 时发生的情况。

#### 同步按钮卡在 UI 中

群组的**群组** > **成员**页面上的**立即同步**按钮可能会卡住。按下该按钮并重新加载页面后，该按钮会被卡住。然后无法再次选择该按钮。

**立即同步**按钮可能因多种原因卡住，需要根据具体情况进行调试。以下是该问题的两种可能原因及可能的解决方案。

##### 无效的成员资格

如果群组中的某些成员或请求加入的成员无效，**立即同步**按钮会卡住。您可以在一个[相关的问题](https://gitlab.com/gitlab-org/gitlab/-/issues/348226)中跟踪改进此问题可视性的进展。您可以使用 [Rails 控制台](#rails-console)来确认此问题是否导致**立即同步**按钮卡住：

```ruby
# 找到有问题的群组
group = Group.find_by(name: 'my_gitlab_group')

# 查找群组本身的错误
group.valid?
group.errors.map(&:full_messages)

# 查找群组成员和请求者的错误
group.requesters.map(&:valid?)
group.requesters.map(&:errors).map(&:full_messages)
group.members.map(&:valid?)
group.members.map(&:errors).map(&:full_messages)
```

显示的错误可以识别问题并指明解决方案。例如，支持团队曾看到以下错误：

```ruby
irb(main):018:0> group.members.map(&:errors).map(&:full_messages)
=> [["成员的电子邮件地址不允许加入此群组。请前往群组的“设置 > 通用”页面，并检查“按电子邮件域限制成员资格”。"]]
```

此错误表明管理员选择[按电子邮件域限制群组成员资格](../../../user/group/access_and_permissions.md#restrict-group-access-by-domain)，但域名中存在拼写错误。修复域名设置后，**立即同步**按钮又恢复正常功能。

##### Sidekiq 节点上缺少 LDAP 配置

当极狐GitLab 部署在多个节点上，而[运行 Sidekiq 的节点上的 `/etc/gitlab/gitlab.rb`](../../sidekiq/_index.md#configure-ldap-and-user-or-group-synchronization) 中缺少 LDAP 配置时，**立即同步**按钮会卡住。在这种情况下，Sidekiq 作业似乎会消失。

Sidekiq 节点上需要 LDAP，因为 LDAP 有许多异步运行的作业，这些作业需要本地 LDAP 配置：

- [用户同步](ldap_synchronization.md#user-sync)。
- [群组同步](ldap_synchronization.md#group-sync)。

您可以通过在每个运行 Sidekiq 的节点上运行[用于检查 LDAP 的 Rake 任务](#ldap-check)来测试是否缺少 LDAP 配置。如果 LDAP 在此节点上设置正确，它将连接到 LDAP 服务器并返回用户。

要解决此问题，请在 Sidekiq 节点上[配置 LDAP](../../sidekiq/_index.md#configure-ldap-and-user-or-group-synchronization)。配置后，运行[用于检查 LDAP 的 Rake 任务](#ldap-check)以确认极狐GitLab 节点可以连接到 LDAP。

#### 同步所有群组

> [!note]
> 要在调试不需要时手动同步所有群组，请[改用 Rake 任务](../../raketasks/ldap.md#run-a-group-sync)。

手动[群组同步](ldap_synchronization.md#group-sync)的输出可以显示极狐GitLab 根据 LDAP 同步其 LDAP 群组成员资格时发生的情况。进入 [Rails 控制台](#rails-console)，然后运行：

```ruby
Rails.logger.level = Logger::DEBUG

LdapAllGroupsSyncWorker.new.perform
```

接下来，[了解如何阅读输出](#example-console-output-after-a-group-sync)。

##### 群组同步后的控制台输出示例

与用户同步的输出一样，[手动群组同步](#sync-all-groups)的输出也非常详细。不过，它包含了许多有用的信息。

表示同步实际开始的位置：

```shell
开始为 'my_group' 组同步 'ldapmain' 提供程序
```

以下条目显示了极狐GitLab 在 LDAP 服务器中看到的所有用户 DN 的数组。这些 DN 是单个 LDAP 群组的用户，而不是极狐GitLab 群组。如果您有多个 LDAP 群组链接到此极狐GitLab 群组，您会看到多个像这样的日志条目——每个 LDAP 群组一个。如果您在此日志条目中没有看到某个 LDAP 用户 DN，则 LDAP 在我们进行查找时未返回该用户。请验证该用户确实在该 LDAP 群组中。

```shell
'ldap_group_1' LDAP 群组中的成员：["uid=john0,ou=people,dc=example,dc=com",
"uid=mary0,ou=people,dc=example,dc=com", "uid=john1,ou=people,dc=example,dc=com",
"uid=mary1,ou=people,dc=example,dc=com", "uid=john2,ou=people,dc=example,dc=com",
"uid=mary2,ou=people,dc=example,dc=com", "uid=john3,ou=people,dc=example,dc=com",
"uid=mary3,ou=people,dc=example,dc=com", "uid=john4,ou=people,dc=example,dc=com",
"uid=mary4,ou=people,dc=example,dc=com"]
```

在每个条目之后不久，您会看到一个解析后的成员访问级别的哈希。此哈希表示极狐GitLab 认为应该有权访问此群组的所有用户 DN，以及对应的访问级别（角色）。此哈希是可加的，可能会根据其他 LDAP 群组查找添加更多 DN，或修改现有条目。此条目的最后一次出现应准确指示极狐GitLab 认为应添加到该群组的所有用户。

> [!note]
> 10 是 `访客`，20 是 `报告者`，25 是 `安全经理`，30 是 `开发者`，40 是 `维护者`，50 是 `所有者`。

```shell
解析后的 'my_group' 群组成员访问级别：{"uid=john0,ou=people,dc=example,dc=com"=>30,
"uid=mary0,ou=people,dc=example,dc=com"=>30, "uid=john1,ou=people,dc=example,dc=com"=>30,
"uid=mary1,ou=people,dc=example,dc=com"=>30, "uid=john2,ou=people,dc=example,dc=com"=>30,
"uid=mary2,ou=people,dc=example,dc=com"=>30, "uid=john3,ou=people,dc=example,dc=com"=>30,
"uid=mary3,ou=people,dc=example,dc=com"=>30, "uid=john4,ou=people,dc=example,dc=com"=>30,
"uid=mary4,ou=people,dc=example,dc=com"=>30}
```

看到像下面这样的警告并不罕见。这些警告表明极狐GitLab 本应将用户添加到群组，但在极狐GitLab 中找不到该用户。通常这无需担心。

如果您认为某个用户应该已经在极狐GitLab 中存在，但看到此条目，可能是由于极狐GitLab 中存储的 DN 不匹配。请参阅[用户 DN 和电子邮件已更改](#user-dn-and-email-have-changed)来更新用户的 LDAP 身份。
```shell
User with DN `uid=john0,ou=people,dc=example,dc=com` should have access
to 'my_group' group but there is no user in GitLab with that
identity. Membership will be updated when the user signs in for
the first time.
```

最后，以下条目表示该群组的同步已完成：

```shell
Finished syncing all providers for 'my_group' group
```

当所有已配置的群组链接同步完成后，极狐GitLab 会查找需要同步的任何管理员或外部用户：

```shell
Syncing admin users for 'ldapmain' provider
```

其输出类似于单个群组的情况，随后此行表示同步已完成：

```shell
Finished syncing admin users for 'ldapmain' provider
```

如果您尚未[分配管理员角色](ldap_synchronization.md#assign-an-admin-role-to-an-ldap-group)，则会看到以下消息：

```shell
No `admin_group` configured for 'ldapmain' provider. Skipping
```

<a id="sync-one-group"></a>

#### 同步单个群组

[同步所有群组](#sync-all-groups) 可能会在输出中产生大量干扰信息，当您只想排查单个极狐GitLab 群组成员资格问题时，这可能会分散注意力。在这种情况下，您可以按如下方式仅同步该群组并查看其调试输出：

```ruby
Rails.logger.level = Logger::DEBUG

# 查找 极狐GitLab 群组。
# 如果输出为 `nil`，表示未找到该群组。
# 如果输出中包含一堆群组属性，则表示已成功找到您的群组。
group = Group.find_by(name: 'my_gitlab_group')

# 对照 LDAP 同步此群组
EE::Gitlab::Auth::Ldap::Sync::Group.execute_all_providers(group)
```

该输出与[从同步所有群组中获得的输出](#example-console-output-after-a-group-sync)相似。

<a id="query-a-group-in-ldap"></a>

#### 在 LDAP 中查询群组

当您想要确认极狐GitLab 能否读取 LDAP 群组并查看其所有成员时，可以运行以下命令：

```ruby
# 查找适配器和群组本身
adapter = Gitlab::Auth::Ldap::Adapter.new('ldapmain') # 如果 `main` 是 LDAP 提供者
ldap_group = EE::Gitlab::Auth::Ldap::Group.find_by_cn('group_cn_here', adapter)

# 查找 LDAP 群组的成员
ldap_group.member_dns
ldap_group.member_uids
```

<a id="ldap-synchronization-does-not-remove-group-creator-from-group"></a>

#### LDAP 同步不会将群组创建者从群组中移除

如果该用户不存在于群组中，[LDAP 同步](ldap_synchronization.md)应该从该群组中移除其创建者。如果运行 LDAP 同步没有这样做：

1. 将用户添加到 LDAP 群组。
2. 等待 LDAP 群组同步完成运行。
3. 从 LDAP 群组中移除用户。

<a id="user-dn-and-email-have-changed"></a>

### 用户 DN 和电子邮件已更改

如果 LDAP 中的主电子邮件**和** DN 都发生更改，极狐GitLab 将无法识别用户的正确 LDAP 记录。因此，极狐GitLab 会阻止该用户。为了让极狐GitLab 能够找到 LDAP 记录，请至少用以下任一方式更新用户现有的极狐GitLab 个人资料：

- 新主电子邮件。
- DN 值。

以下脚本会更新所有指定用户的电子邮件，避免他们被阻止或无法访问其账户。

> [!note]
> 以下脚本要求首先删除任何使用新电子邮件地址的新账户。电子邮件地址在极狐GitLab 中必须唯一。

前往 [Rails 控制台](#rails-console) 然后运行：

```ruby
# 每个条目都必须包含旧用户名和新电子邮件
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

然后您可以[运行 UserSync](#sync-all-users) 来同步这些用户各自的最新 DN。

<a id="could-not-authenticate-from-azureactivedirectoryv2-because-invalid-grant"></a>

## 由于 `Invalid grant` 导致无法从 AzureActivedirectoryV2 进行身份验证

从 LDAP 转换到 SAML 时，您可能会在 Azure 中遇到如下错误：

```plaintext
身份验证失败！invalid_credentials：OAuth2::Error，invalid_grant。
```

当以下两个条件都满足时，会出现此问题：

- 在为这些用户配置 SAML 之后，这些用户的 LDAP 身份仍然存在。
- 您为这些用户禁用了 LDAP。

您将在日志中同时收到 LDAP 和 Azure 元数据，这将在 Azure 中生成错误。

对于单个用户的解决方法是，在**管理员** > **身份**中移除该用户的 LDAP 身份。

要移除多个 LDAP 身份，请使用下文针对 `由于 "Unknown provider" 导致无法从 Ldapmain 验证您的身份` 错误的任一解决方法。

<a id="error-could-not-authenticate-you-from-ldapmain-because-unknown-provider"></a>

## 错误：`由于 "Unknown provider" 导致无法从 Ldapmain 验证您的身份`

当使用 LDAP 服务器进行身份验证时，您可能会收到以下错误：

```plaintext
由于 "Unknown provider (ldapsecondary). available providers: ["ldapmain"]" 导致无法从 Ldapmain 验证您的身份。
```

当使用的账户之前使用已从您的极狐GitLab 配置中重命名或移除的 LDAP 服务器进行过身份验证时，会出现此错误。例如：

- 最初，在极狐GitLab 配置中，`ldap_servers` 设置了 `main` 和 `secondary`。
- `secondary` 设置被移除或重命名为 `main`。
- 尝试登录的用户有一个针对 `secondary` 的 `identify` 记录，但该记录不再配置。

使用 [Rails 控制台](../../operations/rails_console.md) 列出受影响的用户并检查他们拥有哪些 LDAP 服务器的身份：

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

当 LDAP 服务器彼此是副本，并且受影响的用户应该能够使用已配置的 LDAP 服务器登录时，此解决方案适用。
例如，如果现在使用负载均衡器来管理 LDAP 高可用性，而不再需要单独的辅助登录选项。

> [!note]
> 如果 LDAP 服务器不是彼此的副本，此解决方案将阻止受影响的用户登录。

要[重命名对不再配置的 LDAP 服务器的引用](../../raketasks/ldap.md#other-options)，请运行：

```shell
sudo gitlab-rake gitlab:ldap:rename_provider[ldapsecondary,ldapmain]
```

<a id="remove-the-identity-records-that-relate-to-the-removed-ldap-server"></a>

### 移除与已移除 LDAP 服务器相关的 `identity` 记录

先决条件：

- 确保已启用 `auto_link_ldap_user`。

使用此解决方案，在删除身份后，受影响的用户可以使用已配置的 LDAP 服务器登录，并且极狐GitLab 会创建一个新的 `identity` 记录。

由于被移除的 LDAP 服务器是 `ldapsecondary`，请在 [Rails 控制台](../../operations/rails_console.md) 中删除所有 `ldapsecondary` 身份：

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

## 许可证过期导致使用多个 LDAP 服务器时出错

使用[多个 LDAP 服务器](_index.md#use-multiple-ldap-servers)需要有效的许可证。过期的许可证可能会导致：

- Web 界面中出现 `502` 错误。
- 日志中出现以下错误（实际策略名称取决于 `/etc/gitlab/gitlab.rb` 中配置的名称）：

  ```plaintext
  找不到名为 `Ldapsecondary` 的策略。请确保它是必需的，或使用 :strategy_class 选项显式设置它。(Devise::OmniAuth::StrategyNotFound)
  ```

要解决此错误，您必须在没有 Web 界面的情况下为极狐GitLab 实例应用新的许可证：

1. 移除或注释掉所有非主 LDAP 服务器的 极狐GitLab 配置行。
2. [重新配置 极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)，使其临时只使用一个 LDAP 服务器。
3. 进入 [Rails 控制台并添加许可证密钥](../../license_file.md#add-a-license-through-the-console)。
4. 在 极狐GitLab 配置中重新启用其他 LDAP 服务器，并再次重新配置 极狐GitLab。

<a id="users-are-being-removed-from-group-and-re-added-again"></a>

## 用户被从群组中移除后又重新添加

如果用户在群组同步期间被添加到群组，但在下次同步时被移除，并且这种情况反复发生，请确保该用户没有多个或冗余的 LDAP 身份。

如果这些身份中的某个是为不再使用的旧 LDAP 提供者添加的，请[移除与已删除 LDAP 服务器相关的 `identity` 记录](#remove-the-identity-records-that-relate-to-the-removed-ldap-server)。

<a id="debugging-tools"></a>

## 调试工具

<a id="ldap-check"></a>

### LDAP 检查

[用于检查 LDAP 的 Rake 任务](../../raketasks/ldap.md#check) 是一个很有价值的工具，可以帮助确定极狐GitLab 能否成功建立与 LDAP 的连接，甚至能否读取用户。

如果无法建立连接，很可能是因为您的配置有问题，或者防火墙阻止了连接。

- 确保没有防火墙阻止连接，并且 LDAP 服务器对极狐GitLab 主机可访问。
- 在 Rake 检查输出中查找错误消息，这可能会引导您检查 LDAP 配置，以确认配置值（特别是 `host`、`port`、`bind_dn` 和 `password`）是否正确。
- 在[日志](#gitlab-logs)中查找[错误](#connection)，以进一步调试连接失败。

如果极狐GitLab 可以成功连接到 LDAP 但不返回任何用户，请[查看未找到用户时的处理方式](#no-users-are-found)。

<a id="gitlab-logs"></a>

### 极狐GitLab 日志

如果用户账户因 LDAP 配置而被阻止或解除阻止，则会有一条消息[记录到 `application_json.log`](../../logs/_index.md#application_jsonlog) 中。

如果在 LDAP 查找期间发生意外错误（配置错误、超时），登录将被拒绝，并且会有一条消息[记录到 `production.log`](../../logs/_index.md#productionlog) 中。

<a id="ldapsearch"></a>

### ldapsearch

`ldapsearch` 是一个允许您查询 LDAP 服务器的实用工具。您可以使用它来测试您的 LDAP 设置，并确保您所使用的设置能获得预期的结果。

使用 `ldapsearch` 时，请确保使用已在 `gitlab.rb` 配置中指定的相同设置，以便确认在使用这些确切设置时会发生什么。

在极狐GitLab 主机上运行此命令也有助于确认极狐GitLab 主机与 LDAP 之间没有障碍。

例如，考虑以下极狐GitLab 配置：

```shell
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # 记住在下面用 'EOS' 关闭此块
   main: # 'main' 是此 LDAP 服务器的 极狐GitLab 'provider ID'
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

您将运行以下 `ldapsearch` 命令来查找 `bind_dn` 用户：

```shell
ldapsearch -D "cn=admin,dc=ldap-testing,dc=example,dc=com" \
  -w Password1 \
  -p 389 \
  -h 127.0.0.1 \
  -b "dc=ldap-testing,dc=example,dc=com"
```

`bind_dn`、`password`、`port`、`host` 和 `base` 都与 `gitlab.rb` 中配置的完全相同。

<a id="use-ldapsearch-with-start_tls-encryption"></a>

#### 结合 `start_tls` 加密使用 ldapsearch

前面的示例以明文方式在端口 389 上执行 LDAP 测试。如果您使用 [`start_tls` 加密](_index.md#basic-configuration-settings)，则在 `ldapsearch` 命令中应包含：

- `-Z` 标志。
- LDAP 服务器的 FQDN。

您必须包含这些，因为在 TLS 协商期间，会根据证书评估 LDAP 服务器的 FQDN：

```shell
ldapsearch -D "cn=admin,dc=ldap-testing,dc=example,dc=com" \
  -w Password1 \
  -p 389 \
  -h "testing.ldap.com" \
  -b "dc=ldap-testing,dc=example,dc=com" -Z
```

<a id="use-ldapsearch-with-simple_tls-encryption"></a>

#### 结合 `simple_tls` 加密使用 ldapsearch

如果您使用 [`simple_tls` 加密](_index.md#basic-configuration-settings)（通常在端口 636 上），请在 `ldapsearch` 命令中包含以下内容：

- 带有 `-H` 标志和端口的 LDAP 服务器 FQDN。
- 完整的构造 URI。

```shell
ldapsearch -D "cn=admin,dc=ldap-testing,dc=example,dc=com" \
  -w Password1 \
  -H "ldaps://testing.ldap.com:636" \
  -b "dc=ldap-testing,dc=example,dc=com"
```

更多信息，请参阅[官方 `ldapsearch` 文档](https://linux.die.net/man/1/ldapsearch)。

<a id="using-adfind-windows"></a>

### 使用 **AdFind**（Windows）

您可以使用 [`AdFind`](https://learn.microsoft.com/en-us/archive/technet-wiki/7535.adfind-command-examples) 实用工具（在基于 Windows 的系统上）来测试 LDAP 服务器是否可访问以及身份验证是否正常工作。AdFind 是由 [Joe Richards](https://www.joeware.net/freetools/tools/adfind/index.htm) 构建的免费软件实用工具。

**返回所有对象**

您可以使用过滤器 `objectclass=*` 来返回所有目录对象。

```shell
adfind -h ad.example.org:636 -ssl -u "CN=GitLabSRV,CN=Users,DC=GitLab,DC=org" -up Password1 -b "OU=GitLab INT,DC=GitLab,DC=org" -f (objectClass=*)
```

**使用过滤器返回单个对象**

您还可以通过**指定**对象名称或完整 **DN** 来检索单个对象。在此示例中，我们只指定对象名称 `CN=Leroy Fox`。

```shell
adfind -h ad.example.org:636 -ssl -u "CN=GitLabSRV,CN=Users,DC=GitLab,DC=org" -up Password1 -b "OU=GitLab INT,DC=GitLab,DC=org" -f "(&(objectcategory=person)(CN=Leroy Fox))"
```

<a id="rails-console"></a>

### Rails 控制台

> [!warning]
> 使用 Rails 控制台很容易创建、读取、修改和销毁数据。请确保完全按照列出的命令运行。

Rails 控制台是帮助调试 LDAP 问题的宝贵工具。它允许您通过运行命令并查看极狐GitLab 对它们的响应，直接与应用程序进行交互。

有关如何使用 Rails 控制台的说明，请参阅本[指南](../../operations/rails_console.md#starting-a-rails-console-session)。

<a id="enable-debug-output"></a>

#### 启用调试输出

这将提供调试输出，显示极狐GitLab 正在做什么以及使用了什么。此值不会持久化，仅在 Rails 控制台的此会话中启用。

要在 rails 控制台中启用调试输出，请[进入 rails 控制台](#rails-console) 并运行：

```ruby
Rails.logger.level = Logger::DEBUG
```

<a id="get-all-error-messages-associated-with-groups-subgroups-members-and-requesters"></a>

#### 获取与群组、子群组、成员和请求者相关的所有错误消息

收集与群组、子群组、成员和请求者相关的错误消息。这将捕获可能不会出现在 Web 界面中的错误消息。这对于排查 [LDAP 群组同步](ldap_synchronization.md#group-sync) 问题以及用户及其在群组和子群组中的成员身份的意外行为特别有帮助。

```ruby
# 查找群组和子群组
group = Group.find_by_full_path("parent_group")
subgroup = Group.find_by_full_path("parent_group/child_group")

# 群组和子群组错误
group.valid?
group.errors.map(&:full_messages)

subgroup.valid?
subgroup.errors.map(&:full_messages)

# 成员和请求者的群组和子群组错误
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