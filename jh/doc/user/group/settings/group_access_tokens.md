---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组访问令牌
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

群组访问令牌为群组及其项目提供经过身份验证的访问。它们类似于个人访问令牌和项目访问令牌，但附加到群组而不是用户或项目。你不能使用群组访问令牌来创建其他群组、项目或个人访问令牌。

你可以使用群组访问令牌进行以下身份验证：

- 与[极狐GitLab API](../../../api/rest/authentication.md#personal-project-and-group-access-tokens)。
- 通过 HTTPS 使用 Git 进行身份验证。使用：
  - 任意非空值作为用户名。
  - 群组访问令牌作为密码。

前提条件：

- 群组的所有者角色。

> [!note]
> 在 JihuLab.com 上，群组访问令牌需要专业版或旗舰版订阅。它们在[试用](https://gitlab.cn/free-trial/#what-is-included-in-my-free-trial-what-is-excluded)期间不可用。
>
> 在私有化部署实例上，群组访问令牌可在任何许可证下使用。

<a id="view-your-access-tokens"></a>

## 查看您的访问令牌

{{< history >}}

- 在极狐GitLab 16.0 及更早版本中，令牌使用信息每 24 小时更新一次。
- 令牌使用信息的更新频率在极狐GitLab 16.1 中从 24 小时调为 10 分钟。
- 查看 IP 地址的功能在极狐GitLab 17.8 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/428577)，通过名为 `pat_ip` 的[功能标志](../../../administration/feature_flags/_index.md)提供，默认在 17.9 中启用。
- 查看 IP 地址的功能在极狐GitLab 17.10 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/513302)。功能标志 `pat_ip` 已移除。

{{< /history >}}

群组访问令牌页面会显示你的访问令牌信息。

在此页面，你可以执行以下操作：

- 创建、轮换和吊销群组访问令牌。
- 查看所有活跃和非活跃的群组访问令牌。
- 查看令牌信息，包括作用域、分配的角色和到期日期。
- 查看使用信息，包括使用日期以及最后五个不同的连接 IP 地址。
  > [!note]
  > 当令牌执行 Git 操作或通过 [REST](../../../api/rest/_index.md) 或 [GraphQL](../../../api/graphql/_index.md) API 验证操作时，极狐GitLab 会定期更新令牌使用信息。令牌使用时间每 10 分钟更新一次，令牌使用的 IP 地址每分钟更新一次。

查看群组访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。
1. 在左侧边栏中，选择 **设置Settings** > **访问令牌**。

活跃且可用的令牌保存在 **活跃群组访问令牌** 部分。已过期、已轮换或已吊销的令牌保存在 **非活跃群组访问令牌** 部分。

<a id="create-a-group-access-token"></a>

## 创建群组访问令牌

{{< history >}}

- 在极狐GitLab 16.0 中，创建永不过期的群组访问令牌的功能[已移除](https://gitlab.com/gitlab-org/gitlab/-/issues/392855)。
- 在极狐GitLab 17.6 中，最大允许生命周期[延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)，通过名为 `buffered_token_expiration_limit` 的[功能标志](../../../administration/feature_flags/_index.md)提供，默认禁用。
- 群组访问令牌描述在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/443819)。

{{< /history >}}

> [!flag]
> 延长的最大允许生命周期限制的可用性由一个功能标志控制。
> 更多信息，请参阅历史记录。

<a id="with-the-ui"></a>

### 使用 UI

创建群组访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。
1. 在左侧边栏中，选择 **设置Settings** > **访问令牌**。
1. 选择 **添加新令牌**。
1. 在 **令牌名称** 中，输入一个名称。令牌名称对所有有权查看该群组的用户可见。
1. 可选。在 **令牌描述** 中，输入该令牌的描述。
1. 在 **到期日期** 中，输入令牌的到期日期。
   - 令牌将在当天 UTC 午夜到期。
   - 如果不输入日期，到期日期将自动设为从今天起 365 天后。
   - 默认情况下，到期日期不能超过从今天起 365 天。在极狐GitLab 17.6 及更高版本中，管理员可以[修改访问令牌的最大生命周期](../../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。
1. 为令牌选择一个角色。
1. 选择一个或多个[群组访问令牌作用域](#group-access-token-scopes)。
1. 选择 **创建群组访问令牌**。

随后会显示一个群组访问令牌。请将群组访问令牌保存到安全的地方。离开或刷新页面后，你将无法再次查看它。

所有群组访问令牌都会继承为个人访问令牌配置的[默认前缀设置](../../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)。

> [!warning]
> 群组访问令牌被视为内部用户。
> 如果内部用户创建了群组访问令牌，则该令牌可以访问
> 所有可见性级别设置为 Internal 的项目。

<a id="with-the-rails-console"></a>

### 使用 Rails 控制台

如果你是管理员，可以在 Rails 控制台中创建群组访问令牌：

1. 在 [Rails 控制台](../../../administration/operations/rails_console.md)中运行以下命令：

   ```ruby
   # Set the GitLab administration user to use. If user ID 1 is not available or is not an administrator, use 'admin = User.admins.first' instead to select an administrator.
   admin = User.find(1)

   # Set the group you want to create a token for. For example, group with ID 109.
   group = Group.find(109)

   # Create the group bot user. For further group access tokens, the username should be `group_{group_id}_bot_{random_string}` and email address `group_{group_id}_bot_{random_string}@noreply.{Gitlab.config.gitlab.host}`.
   random_string = SecureRandom.hex(16)
   service_response = Users::CreateService.new(admin, { name: 'group_token', username: "group_#{group.id}_bot_#{random_string}", email: "group_#{group.id}_bot_#{random_string}@noreply.#{Gitlab.config.gitlab.host}", user_type: :project_bot }).execute
   bot = service_response.payload[:user] if service_response.success?

   # Confirm the group bot.
   bot.confirm

   # Add the bot to the group with the required role.
   group.add_member(bot, :maintainer)

   # Give the bot a personal access token.
   token = bot.personal_access_tokens.create(scopes:[:api, :write_repository], name: 'group_token')

   # Get the token value.
   gtoken = token.token
   ```

1. 测试生成的群组访问令牌是否可用：

   1. 在极狐GitLab REST API 的 `PRIVATE-TOKEN` 标头中使用群组访问令牌。例如：

      - [在群组中创建史诗](../../../api/epics.md#create-an-epic)。
      - [在群组的一个项目中创建项目流水线](../../../api/pipelines.md#create-a-new-pipeline)。
      - [在群组的一个项目中创建议题](../../../api/issues.md#create-an-issue)。

   1. 使用群组令牌通过 HTTPS [克隆群组的项目](../../../topics/git/clone.md#clone-with-https)。

<a id="group-access-token-scopes"></a>

### 群组访问令牌作用域

{{< history >}}

- `k8s_proxy` 在极狐GitLab 16.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/422408)，通过名为 `k8s_proxy_pat` 的[功能标志](../../../administration/feature_flags/_index.md)提供，默认启用。
- 功能标志 `k8s_proxy_pat` 在极狐GitLab 16.5 中[移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/131518)。
- `self_rotate` 在极狐GitLab 17.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/178111)，默认启用。

{{< /history >}}

作用域定义了使用群组访问令牌进行身份验证时可用的操作。

| 作用域                    | 描述 |
| ------------------------ | ----------- |
| `api`                    | 授予对作用域内群组及相关项目 API 的完整读写权限，包括[容器镜像仓库](../../packages/container_registry/_index.md)、[依赖代理](../../packages/dependency_proxy/_index.md)和[软件包仓库](../../packages/package_registry/_index.md)。 |
| `read_api`               | 授予对作用域内群组及相关项目 API 的读取权限，包括[软件包仓库](../../packages/package_registry/_index.md)。 |
| `read_repository`        | 授予对群组中所有代码仓库的读取权限（拉取）。 |
| `write_repository`       | 授予对群组中所有代码仓库的读写权限（拉取和推送）。 |
| `read_registry`          | 如果群组中的任何项目是私有的并且需要授权，则授予对[容器镜像仓库](../../packages/container_registry/_index.md)镜像的读取权限（拉取）。仅在启用容器镜像仓库时可用。 |
| `write_registry`         | 授予对[容器镜像仓库](../../packages/container_registry/_index.md)的写入权限（推送）。要推送镜像，必须包含 `read_registry` 作用域。仅在启用容器镜像仓库时可用。 |
| `read_virtual_registry`  | 授予通过[依赖代理](../../packages/dependency_proxy/_index.md)对容器镜像的读取权限（拉取）。仅在启用依赖代理时可用。 |
| `write_virtual_registry` | 授予通过[依赖代理](../../packages/dependency_proxy/_index.md)对容器镜像的读写权限（拉取、推送和删除）。仅在启用依赖代理时可用。 |
| `create_runner`          | 授予在群组中创建 Runner 的权限。 |
| `manage_runner`          | 授予在群组中管理 Runner 的权限。 |
| `ai_features`            | 授予为极狐GitLab Duo、代码建议 API 和极狐GitLab Duo Chat API 执行 API 操作的权限。专为与 JetBrains 的极狐GitLab Duo 插件配合使用而设计。对于所有其他扩展，请参阅各扩展文档。不适用于私有化部署版 16.5、16.6 和 16.7。在私有化部署实例上，此作用域仅在启用极狐GitLab Duo 时可用。 |
| `k8s_proxy`              | 授予使用群组中 Kubernetes 的代理执行 Kubernetes API 调用的权限。 |
| `self_rotate`            | 授予使用[个人访问令牌 API](../../../api/personal_access_tokens.md#rotate-a-personal-access-token) 轮换此令牌的权限。不允许轮换其他令牌。 |

<a id="rotate-a-group-access-token"></a>

## 轮换群组访问令牌

{{< history >}}

- 查看已过期和已吊销令牌的功能在极狐GitLab 17.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)，通过名为 `retain_resource_access_token_user_after_revoke` 的[功能标志](../../../administration/feature_flags/_index.md)提供，默认禁用。
- 查看已过期和已吊销令牌直到其被自动删除的功能在极狐GitLab 17.9 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/471683)。功能标志 `retain_resource_access_token_user_after_revoke` 已移除。

{{< /history >}}

轮换令牌会创建一个具有与原始令牌相同权限和作用域的新令牌。
原始令牌立即变为无效，极狐GitLab 会保留两个版本以供审计。你可以在访问令牌页面上查看活跃和非活跃的令牌。

在私有化部署实例上，你可以修改[非活跃令牌的保留期](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

> [!warning]
> 此操作不可撤销。依赖已轮换访问令牌的工具将停止工作，直到你引用新令牌。

轮换群组访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。
1. 在左侧边栏中，选择 **设置Settings** > **访问令牌**。
1. 针对相应令牌，选择 **轮换**（{{< icon name="retry" >}}）。
1. 在确认对话框中，选择 **轮换**。

<a id="revoke-a-group-access-token"></a>

## 吊销群组访问令牌

{{< history >}}

- 查看已过期和已吊销令牌的功能在极狐GitLab 17.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)，通过名为 `retain_resource_access_token_user_after_revoke` 的[功能标志](../../../administration/feature_flags/_index.md)提供，默认禁用。
- 查看已过期和已吊销令牌直到其被自动删除的功能在极狐GitLab 17.9 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/471683)。功能标志 `retain_resource_access_token_user_after_revoke` 已移除。

{{< /history >}}

吊销令牌会立即使其失效并阻止进一步使用。已吊销的令牌不会立即删除，但你可以过滤令牌列表仅显示活跃令牌。默认情况下，极狐GitLab 会在 30 天后删除已吊销的群组和项目访问令牌。有关更多信息，请参阅[非活跃令牌保留](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

> [!warning]
> 此操作不可撤销。依赖已吊销访问令牌的工具将停止工作，直到你添加新令牌。

吊销群组访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。
1. 在左侧边栏中，选择 **设置Settings** > **访问令牌**。
1. 针对相应令牌，选择 **吊销**（{{< icon name="remove" >}}）。
1. 在确认对话框中，选择 **吊销**。

<a id="access-token-expiration"></a>

## 访问令牌过期

个人、群组和项目访问令牌在到期日期的 UTC 午夜到期。
到期后，它们将无法再用于验证请求。

在极狐GitLab 16.0 及更高版本中，新访问令牌必须具有到期日期。如果在创建令牌时未显式设置到期日期，则会自动应用从当前日期起 365 天的到期日期。在极狐GitLab 旗舰版中，管理员可以为访问令牌配置[最大允许生命周期](../../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。

根据你的极狐GitLab 版本和产品，升级极狐GitLab 版本时，现有访问令牌可能会自动应用到期日期。有关更多信息，请参阅[永不过期的访问令牌](../../../update/deprecations.md#non-expiring-access-tokens)。

<a id="group-access-token-expiry-emails"></a>

### 群组访问令牌到期提醒邮件

{{< history >}}

- 60 天和 30 天到期通知在极狐GitLab 17.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/464040)，通过名为 `expiring_pats_30d_60d_notifications` 的[功能标志](../../../administration/feature_flags/_index.md)提供，默认禁用。
- 60 天和 30 天通知在极狐GitLab 17.7 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/173792)。功能标志 `expiring_pats_30d_60d_notifications` 已移除。
- 向继承群组成员的通知在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/463016)，通过名为 `pat_expiry_inherited_members_notification` 的[功能标志](../../../administration/feature_flags/_index.md)提供，默认禁用。
- 功能标志 `pat_expiry_inherited_members_notification` 在极狐GitLab 17.10 中[默认启用](https://gitlab.com/gitlab-org/gitlab/-/issues/393772)。
- 功能标志 `pat_expiry_inherited_members_notification` 在极狐GitLab 17.11 中已移除。

{{< /history >}}

极狐GitLab 每天 UTC 时间凌晨 1:00 运行一次检查，以识别即将到期的群组访问令牌。
具有所有者角色的直接成员会在令牌到期前 7 天通过电子邮件收到通知。在极狐GitLab 17.6 及更高版本中，还会在令牌到期前 30 天和 60 天发送通知。

在极狐GitLab 17.7 及更高版本中，具有所有者角色的继承成员也可以收到这些邮件。
你可以在[极狐GitLab 实例](../../../administration/settings/email.md#group-and-project-access-token-expiry-emails-to-inherited-members)或[特定群组](../manage.md#expiry-emails-for-group-and-project-access-tokens)上为每个群组配置此项。
如果应用于父级群组，此设置将被所有后代群组和项目继承。

已过期的令牌会显示在非活跃群组访问令牌部分，直到它们被自动删除。在私有化部署实例上，你可以修改此[保留期](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

<a id="bot-users-for-groups"></a>

## 群组机器人用户

当你创建群组访问令牌时，极狐GitLab 会创建一个机器人用户并将其与令牌关联。

机器人用户具有以下属性：

- 它们被授予与关联访问令牌的角色和作用域相对应的权限。
- 它们是群组的成员并继承子群组和项目中的成员资格，但不能直接添加到任何其他群组或项目。
- 它们是[不计费用户](../../../subscriptions/manage_seats.md#criteria-for-non-billable-users)，不计入你的许可证限制。
- 它们的贡献与机器人用户账户关联。
- 当被移除时，它们的贡献将转移到一个[幽灵用户](../../profile/account/delete_account.md#associated-records)。

创建机器人用户时，会定义以下属性：

| 属性 | 值                                                                                                    | 示例 |
| --------- | ---------------------------------------------------------------------------------------------------- | ------- |
| 名称      | 关联访问令牌的名称。                                                                                | `Main token - Read registry` |
| 用户名  | 按以下格式生成：`group_{group_id}_bot_{random_string}`                                              | `group_123_bot_4ffca233d8298ea1` |
| 电子邮件     | 按以下格式生成：`group_{group_id}_bot_{random_string}@noreply.{Gitlab.config.gitlab.host}`          | `group_123_bot_4ffca233d8298ea1@noreply.example.com` |

<a id="restrict-the-creation-of-group-and-project-access-tokens"></a>

## 限制群组和项目访问令牌的创建

为了限制潜在滥用，你可以限制用户在顶级群组及其任何后代子群组或项目中创建访问令牌。任何现有令牌在到期或手动吊销之前仍然有效。

限制访问令牌的创建：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的顶级群组。
1. 选择 **设置Settings** > **通用**。
1. 展开 **权限和群组功能**。
1. 清除 **用户可以在此群组中创建群组访问令牌和项目访问令牌** 复选框。
1. 选择 **保存更改**。

