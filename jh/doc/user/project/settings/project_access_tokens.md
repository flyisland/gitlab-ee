---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目访问令牌
description: 认证、创建、撤销以及令牌过期。
availability_details: no
---

{{< details >}}

Offering: JihuLab.com，私有化部署

{{< /details >}}

项目访问令牌提供对特定项目的认证访问。它们与群组访问令牌和个人访问令牌类似，但作用范围限定在关联的项目，而不是群组或用户。您不能使用项目访问令牌访问其他项目中的资源，也不能创建其他群组、项目或个人访问令牌。

您可以使用项目访问令牌进行以下认证：

- 使用[极狐GitLab API](../../../api/rest/authentication.md#personal-project-and-group-access-tokens)。
- 通过 HTTPS 使用 Git。使用：
  - 任意非空值作为用户名。
  - 项目访问令牌作为密码。

先决条件：

- 项目中的维护者或所有者角色。

> [!note]
> 在 JihuLab.com 上，项目访问令牌需要专业版或旗舰版订阅。在
> [试用](https://about.gitlab.com/free-trial/#what-is-included-in-my-free-trial-what-is-excluded)期间，
> 您只能创建一个项目访问令牌。
>
> 在极狐GitLab 私有化部署上，任何许可证均可使用项目访问令牌。

<a id="create-a-project-access-token"></a>

## 创建项目访问令牌

> [!flag]
> 扩展的最大允许生命周期限制的可用性由功能标志控制。

要创建项目访问令牌：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **访问令牌**。
1. 选择**添加新令牌**。
1. 在**令牌名称**中，输入名称。任何有权查看项目的用户都可以看到该令牌名称。
1. 可选。在**令牌描述**中，输入令牌的描述。
1. 在**过期日期**中，输入令牌的过期日期。
   - 令牌在该日期的 UTC 午夜过期。
   - 如果您不输入日期，过期日期将设置为自今天起 365 天。
   - 默认情况下，过期日期不能超过自今天起 365 天。在极狐GitLab 17.6 及更高版本中，
     管理员可以[修改访问令牌的最大生命周期](../../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。
1. 为令牌选择角色。
1. 选择一个或多个[项目访问令牌范围](../../../security/tokens/access_token_scopes.md)。
1. 选择**创建项目访问令牌**。

系统会显示一个项目访问令牌。请将项目访问令牌保存在安全的地方。离开或刷新页面后，您将无法再次查看它。

所有项目访问令牌都会继承为个人访问令牌配置的
[默认前缀设置](../../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)。

> [!warning]
> 项目访问令牌被视为内部用户。
> 如果内部用户创建了项目访问令牌，该令牌可以访问
> 所有可见性级别设置为“内部”的项目。

<a id="view-your-access-tokens"></a>

## 查看您的访问令牌

项目访问令牌页面显示有关您的访问令牌的信息。

在此页面上，您可以执行以下操作：

- 创建、轮换和撤销项目访问令牌。
- 查看所有活跃和非活跃的项目访问令牌。
- 查看令牌信息，包括范围、分配的角色和过期日期。
- 查看使用信息，包括使用日期和最近五个不同的连接 IP 地址。
  > [!note]
  > 当令牌执行 Git 操作或通过 [REST](../../../api/rest/_index.md) 或
  > [GraphQL](../../../api/graphql/_index.md) API 认证操作时，极狐GitLab 会定期更新令牌使用信息。令牌使用时间每 10 分钟更新一次。
  > 令牌使用 IP 地址每分钟更新一次。

要查看您的项目访问令牌：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **访问令牌**。

活跃且可用的访问令牌存储在**活跃项目访问令牌**部分。已过期、已轮换或已撤销的令牌存储在**非活跃项目访问令牌**部分。

<a id="rotate-a-project-access-token"></a>

## 轮换项目访问令牌

轮换令牌可创建一个与原始令牌具有相同权限和范围的新令牌。原始令牌会立即变为非活跃状态，极狐GitLab 会保留两个版本以供审计。您可以在访问令牌页面上查看活跃和非活跃的令牌。

在极狐GitLab 私有化部署上，您可以修改
[非活跃令牌的保留期限](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

> [!warning]
> 此操作无法撤销。依赖已轮换访问令牌的工具将停止工作，直到您引用新的令牌。

要轮换项目访问令牌：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **访问令牌**。
1. 对于相关令牌，选择**轮换**（{{< icon name="retry" >}}）。
1. 在确认对话框中，选择**轮换**。

<a id="revoke-a-project-access-token"></a>

## 撤销项目访问令牌

撤销令牌可使其立即失效并阻止进一步使用。已撤销的令牌不会立即删除，但您可以筛选令牌列表以仅显示活跃令牌。默认情况下，极狐GitLab 会在 30 天后删除已撤销的群组和项目访问令牌。有关更多信息，请参阅
[非活跃令牌保留](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

> [!warning]
> 此操作无法撤销。依赖已撤销访问令牌的工具将停止工作，直到您添加新的令牌。

要撤销项目访问令牌：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **访问令牌**。
1. 对于相关令牌，选择**撤销**（{{< icon name="remove" >}}）。
1. 在确认对话框中，选择**撤销**。

<a id="access-token-expiration"></a>

## 访问令牌过期

个人、群组和项目访问令牌会在过期日期的 UTC 午夜过期。过期后，它们将无法再用于认证请求。

新的访问令牌必须具有过期日期。如果在创建令牌时未明确设置过期日期，则会应用自当前日期起 365 天的过期日期。在极狐GitLab 旗舰版中，管理员可以为访问令牌配置
[最大允许生命周期](../../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。

根据您的极狐GitLab 版本和交付方式，在升级极狐GitLab 版本时，您现有的访问令牌可能会自动应用过期日期。有关更多信息，
请参阅[永不过期的访问令牌](../../../update/deprecations.md#non-expiring-access-tokens)。

<a id="project-access-token-expiry-emails"></a>

### 项目访问令牌过期电子邮件

极狐GitLab 每天在 UTC 凌晨 1:00 运行一次检查，以识别即将过期的项目访问令牌。具有维护者或所有者角色的直接成员会在令牌过期前七天收到电子邮件通知。在极狐GitLab 17.6 及更高版本中，还会在令牌过期前 30 天和 60 天发送通知。

在极狐GitLab 17.7 及更高版本中，具有继承的维护者或所有者角色的成员也可以收到这些电子邮件。您可以在
[极狐GitLab 实例](../../../administration/settings/email.md#group-and-project-access-token-expiry-emails-to-inherited-members)
或[特定父群组](../../group/manage.md#expiry-emails-for-group-and-project-access-tokens)上为每个群组和项目配置此功能。
如果应用于父群组，此设置会被所有后代群组和项目继承。

已过期的令牌会显示在非活跃项目访问令牌部分，直到它们被自动删除。在极狐GitLab 私有化部署上，您可以修改此
[保留期限](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

<a id="bot-users-for-projects"></a>

## 项目的机器人用户

当您创建项目访问令牌时，极狐GitLab 会创建一个机器人用户并将其与该令牌关联。

机器人用户具有以下属性：

- 它们被授予与关联访问令牌的角色和范围相对应的权限。
- 它们是项目的成员，但不能从项目中移除，也不能直接添加到任何其他群组或项目。
- 它们是[非计费用户](../../../subscriptions/manage_seats.md#criteria-for-non-billable-users)，不计入您的许可证限制。
- 它们的贡献与机器人用户账号关联。
- 当被移除时，它们的贡献会转移到一个
  [幽灵用户](../../profile/account/delete_account.md#associated-records)。

创建机器人用户时，会定义以下属性：

| 属性 | 值                                                                                                    | 示例 |
| --------- | -------------------------------------------------------------------------------------------------------- | ------- |
| 名称      | 关联访问令牌的名称。                                                                 | `Main token - Read registry` |
| 用户名  | 按以下格式生成：`project_{project_id}_bot_{random_string}`                                     | `project_123_bot_4ffca233d8298ea1` |
| 邮箱     | 按以下格式生成：`project_{project_id}_bot_{random_string}@noreply.{Gitlab.config.gitlab.host}` | `project_123_bot_4ffca233d8298ea1@noreply.example.com` |

<a id="restrict-the-creation-of-project-access-tokens"></a>

## 限制项目访问令牌的创建

为了限制潜在的滥用，您可以限制用户在顶级群组中为项目创建访问令牌。任何现有令牌在过期或被手动撤销之前仍然有效。

有关更多信息，请参阅[限制群组和项目访问令牌的创建](../../group/settings/group_access_tokens.md#restrict-the-creation-of-group-and-project-access-tokens)。
