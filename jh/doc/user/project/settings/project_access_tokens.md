---
stage: 软件供应链安全
group: 认证
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目访问令牌
description: 认证、创建、撤销及令牌过期。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.1 中为试用订阅[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/386041)。

{{< /history >}}

项目访问令牌提供对特定项目的认证访问。它们类似于群组访问令牌和个人访问令牌，但作用域限定于关联的项目，而不是群组或用户。你不能使用项目访问令牌访问其他项目中的资源，也不能创建其他群组、项目或个人访问令牌。

你可以使用项目访问令牌进行认证：

- 通过 [极狐GitLab API](../../../api/rest/authentication.md#personal-project-and-group-access-tokens)。
- 通过 HTTPS 使用 Git。使用：
  - 任何非空值作为用户名。
  - 项目访问令牌作为密码。

前提条件：

- 在项目中具有维护者或所有者角色。

> [!note]
> 在 JihuLab.com 上，项目访问令牌需要专业版或旗舰版订阅。在
> [试用](https://gitlab.cn/free-trial/#what-is-included-in-my-free-trial-what-is-excluded)期间，
> 你只能创建一个项目访问令牌。
>
> 在私有化部署实例上，项目访问令牌在任何许可证下均可用。

<a id="view-your-access-tokens"></a>

## 查看你的访问令牌

{{< history >}}

- 在极狐GitLab 16.0 及更早版本中，令牌使用信息每 24 小时更新一次。
- 令牌使用信息更新频率[已更改](https://gitlab.com/gitlab-org/gitlab/-/issues/410168)，在极狐GitLab 16.1 中从 24 小时更改为 10 分钟。
- 查看 IP 地址的功能[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/428577)于极狐GitLab 17.8，[带有功能标志](../../../administration/feature_flags/_index.md) `pat_ip`。在 17.9 中默认启用。
- 查看 IP 地址的功能[已全面可用](https://gitlab.com/gitlab-org/gitlab/-/issues/513302)于极狐GitLab 17.10。功能标志 `pat_ip` 已移除。

{{< /history >}}

项目访问令牌页面显示有关你的访问令牌的信息。

在此页面上，你可以执行以下操作：

- 创建、轮换和撤销项目访问令牌。
- 查看所有活跃和非活跃的项目访问令牌。
- 查看令牌信息，包括作用域、分配的角色和到期日期。
- 查看使用信息，包括使用日期以及最近五个不同的连接 IP 地址。
  > [!note]
  > 当令牌执行 Git 操作或通过 [REST](../../../api/rest/_index.md) 或 [GraphQL](../../../api/graphql/_index.md) API 认证操作时，极狐GitLab 会定期更新令牌使用信息。令牌使用时间每 10 分钟更新一次，令牌使用 IP 地址每分钟更新一次。

要查看你的项目访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **访问令牌**。

活跃且可用的令牌存储在 **活跃的项目访问令牌** 部分。已过期、已轮换或已撤销的令牌存储在 **非活跃的项目访问令牌** 部分。

<a id="create-a-project-access-token"></a>

## 创建项目访问令牌

{{< history >}}

- 创建永不过期的项目访问令牌的功能在极狐GitLab 16.0 中[已移除](https://gitlab.com/gitlab-org/gitlab/-/issues/392855)。
- 最大允许生命周期限制在极狐GitLab 17.6 中[已延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)，[带有功能标志](../../../administration/feature_flags/_index.md) `buffered_token_expiration_limit`。默认禁用。
- 项目访问令牌描述[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/443819)于极狐GitLab 17.7。

{{< /history >}}

> [!flag]
> 延长最大允许生命周期限制的可用性由功能标志控制。
> 更多信息，请参见历史记录。

要创建项目访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **访问令牌**。
1. 选择 **添加新令牌**。
1. 在 **令牌名称** 中，输入一个名称。令牌名称对任何有权查看项目的用户可见。
1. 可选。在 **令牌描述** 中，输入令牌的描述。
1. 在 **到期日期** 中，输入令牌的到期日期。
   - 令牌在该日期的 UTC 午夜到期。
   - 如果你不输入日期，到期日期将设置为从今天起 365 天。
   - 默认情况下，到期日期不能超过从今天起 365 天。在极狐GitLab 17.6 及更高版本中，管理员可以[修改访问令牌的最大生命周期](../../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。
1. 为令牌选择一个角色。
1. 选择一个或多个[项目访问令牌作用域](#project-access-token-scopes)。
1. 选择 **创建项目访问令牌**。

项目访问令牌会显示出来。请将项目访问令牌保存在安全的地方。离开或刷新页面后，你将无法再次查看它。

所有项目访问令牌都继承为个人访问令牌配置的[默认前缀设置](../../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)。

> [!warning]
> 项目访问令牌被视为内部用户。
> 如果内部用户创建了一个项目访问令牌，该令牌可以访问所有可见性级别设置为 Internal 的项目。

<a id="project-access-token-scopes"></a>

### 项目访问令牌作用域

{{< history >}}

- `k8s_proxy` [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/422408)于极狐GitLab 16.4，[带有功能标志](../../../administration/feature_flags/_index.md) `k8s_proxy_pat`。默认启用。
- 功能标志 `k8s_proxy_pat` 在极狐GitLab 16.5 中[已移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/131518)。
- `self_rotate` [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/178111)于极狐GitLab 17.9。默认启用。

{{< /history >}}

作用域定义了使用项目访问令牌进行认证时可用的操作。

| 作用域 | 描述 |
| ------------------ | ----------- |
| `api` | 授予对作用域项目 API 的完全读写访问权限，包括[容器镜像仓库](../../packages/container_registry/_index.md)、[依赖代理](../../packages/dependency_proxy/_index.md)和[软件包仓库](../../packages/package_registry/_index.md)。 |
| `read_api` | 授予对作用域项目 API 的读取访问权限，包括[软件包仓库](../../packages/package_registry/_index.md)。 |
| `read_registry` | 如果项目是私有的且需要授权，则授予对[容器镜像仓库](../../packages/container_registry/_index.md)镜像的读取（拉取）权限。仅在启用容器镜像仓库时可用。 |
| `write_registry` | 授予对[容器镜像仓库](../../packages/container_registry/_index.md)的写入（推送）权限。要推送镜像，必须包含 `read_registry` 作用域。仅在启用容器镜像仓库时可用。 |
| `read_repository` | 授予对项目中代码仓的读取（拉取）权限。 |
| `write_repository` | 授予对项目中代码仓的读取和写入（拉取和推送）权限。 |
| `create_runner` | 授予在项目中创建 Runner 的权限。 |
| `manage_runner` | 授予在项目中管理 Runner 的权限。 |
| `ai_features` | 授予为极狐GitLab Duo 执行 API 操作的权限。这不适用于私有化部署版本 16.5、16.6 和 16.7。在私有化部署实例上，此作用域仅在启用极狐GitLab Duo 时可用。 |
| `k8s_proxy` | 授予使用项目中 Kubernetes 的 agent 执行 Kubernetes API 调用的权限。 |
| `self_rotate` | 授予使用[个人访问令牌 API](../../../api/personal_access_tokens.md#rotate-a-personal-access-token) 轮换此令牌的权限。不允许轮换其他令牌。 |

> [!warning]
> 如果你启用了[外部授权](../../../administration/settings/external_authorization.md)，
> 个人访问令牌无法访问容器或软件包仓库。要恢复访问，
> 请关闭外部授权。

<a id="rotate-a-project-access-token"></a>

## 轮换项目访问令牌

{{< history >}}

- 查看已过期和已撤销令牌的功能[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)于极狐GitLab 17.3，[带有功能标志](../../../administration/feature_flags/_index.md) `retain_resource_access_token_user_after_revoke`。默认禁用。
- 查看已过期和已撤销令牌直到其被自动删除的功能在极狐GitLab 17.9 中[已全面可用](https://gitlab.com/gitlab-org/gitlab/-/issues/471683)。功能标志 `retain_resource_access_token_user_after_revoke` 已移除。

{{< /history >}}

轮换令牌会创建一个具有与原令牌相同权限和作用域的新令牌。
原令牌立即变为非活跃状态，极狐GitLab 会保留这两个版本以供审计。你可以在访问令牌页面上查看活跃和非活跃的令牌。

在私有化部署实例上，你可以修改[非活跃令牌的保留期](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

> [!warning]
> 此操作无法撤销。依赖已轮换访问令牌的工具将停止工作，直到你引用新令牌。

要轮换项目访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **访问令牌**。
1. 对于相关令牌，选择 **轮换** ({{< icon name="retry" >}})。
1. 在确认对话框中，选择 **轮换**。

<a id="revoke-a-project-access-token"></a>

## 撤销项目访问令牌

{{< history >}}

- 查看已过期和已撤销令牌的功能[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)于极狐GitLab 17.3，[带有功能标志](../../../administration/feature_flags/_index.md) `retain_resource_access_token_user_after_revoke`。默认禁用。
- 查看已过期和已撤销令牌直到其被自动删除的功能在极狐GitLab 17.9 中[已全面可用](https://gitlab.com/gitlab-org/gitlab/-/issues/471683)。功能标志 `retain_resource_access_token_user_after_revoke` 已移除。

{{< /history >}}

撤销令牌会立即使其失效并阻止进一步使用。已撤销的令牌不会被立即删除，但你可以过滤令牌列表以仅显示活跃令牌。默认情况下，极狐GitLab 会在 30 天后删除已撤销的群组和项目访问令牌。更多信息，请参见[非活跃令牌保留](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

> [!warning]
> 此操作无法撤销。依赖已撤销访问令牌的工具将停止工作，直到你添加新令牌。

要撤销项目访问令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **访问令牌**。
1. 对于相关令牌，选择 **撤销** ({{< icon name="remove" >}})。
1. 在确认对话框中，选择 **撤销**。

<a id="access-token-expiration"></a>

## 访问令牌过期

个人、群组和项目访问令牌在到期日期的 UTC 午夜到期。过期后，它们不能再用于认证请求。

在极狐GitLab 16.0 及更高版本中，新访问令牌必须有一个到期日期。如果在创建令牌时未明确设置到期日期，则会应用从当前日期起 365 天的到期日期。在极狐GitLab 旗舰版中，管理员可以为访问令牌配置[最大允许生命周期](../../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。

根据你的极狐GitLab 版本和提供方式，在升级极狐GitLab 版本时，你现有的访问令牌可能会自动应用到期日期。更多信息，请参见[非过期访问令牌](../../../update/deprecations.md#non-expiring-access-tokens)。

<a id="project-access-token-expiry-emails"></a>

### 项目访问令牌到期电子邮件

{{< history >}}

- 60 天和 30 天到期通知[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/464040)于极狐GitLab 17.6，[带有功能标志](../../../administration/feature_flags/_index.md) `expiring_pats_30d_60d_notifications`。默认禁用。
- 60 天和 30 天通知在极狐GitLab 17.7 中[已全面可用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/173792)。功能标志 `expiring_pats_30d_60d_notifications` 已移除。
- 向继承的群组成员发送通知[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/463016)于极狐GitLab 17.7，[带有功能标志](../../../administration/feature_flags/_index.md) `pat_expiry_inherited_members_notification`。默认禁用。
- 功能标志 `pat_expiry_inherited_members_notification` 在极狐GitLab 17.10 中[默认启用](https://gitlab.com/gitlab-org/gitlab/-/issues/393772)。
- 功能标志 `pat_expiry_inherited_members_notification` 在极狐GitLab 17.11 中已移除。

{{< /history >}}

极狐GitLab 每天凌晨 1:00 UTC 运行一次检查，以识别即将到期的项目访问令牌。
具有所有者或维护者角色的直接成员会在令牌到期前七天收到电子邮件通知。在极狐GitLab 17.6 及更高版本中，还会在令牌到期前 30 天和 60 天发送通知。

在极狐GitLab 17.7 及更高版本中，具有继承的所有者或维护者角色的成员也可以收到这些电子邮件。你可以在[极狐GitLab 实例](../../../administration/settings/email.md#group-and-project-access-token-expiry-emails-to-inherited-members)或[特定的父群组](../../group/manage.md#expiry-emails-for-group-and-project-access-tokens)上为每个群组和项目配置此功能。如果应用于父群组，此设置将被所有后代群组和项目继承。

已过期的令牌会显示在非活跃的项目访问令牌部分，直到它们被自动删除。在私有化部署实例上，你可以修改此[保留期](../../../administration/settings/account_and_limit_settings.md#inactive-project-and-group-access-token-retention-period)。

<a id="bot-users-for-projects"></a>

## 项目的机器人用户

{{< history >}}

- [已更改](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)于极狐GitLab 17.2，[带有功能标志](../../../administration/feature_flags/_index.md) `retain_resource_access_token_user_after_revoke`。默认禁用。启用后，新的机器人用户将被创建为无到期日期的成员，并且当令牌稍后被撤销或过期时，机器人用户会保留 30 天。
- 非活跃机器人用户保留在极狐GitLab 17.9 中[已全面可用](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)。功能标志 `retain_resource_access_token_user_after_revoke` 已移除。

{{< /history >}}

当你创建项目访问令牌时，极狐GitLab 会创建一个机器人用户并将其与该令牌关联。

机器人用户具有以下属性：

- 它们被授予与关联访问令牌的角色和作用域相对应的权限。
- 它们是项目的成员，但不能从项目中移除，也不能直接添加到任何其他群组或项目。
- 它们是[不计费用户](../../../subscriptions/manage_seats.md#criteria-for-non-billable-users)，不计入你的许可限制。
- 它们的贡献与机器人用户账户关联。
- 当被移除时，它们的贡献会转移给一个[幽灵用户](../../profile/account/delete_account.md#associated-records)。

创建机器人用户时，会定义以下属性：

| 属性 | 值 | 示例 |
| --------- | -------------------------------------------------------------------------------------------------------- | ------- |
| 名称 | 关联访问令牌的名称。 | `Main token - Read registry` |
| 用户名 | 以此格式生成：`project_{project_id}_bot_{random_string}` | `project_123_bot_4ffca233d8298ea1` |
| 电子邮件 | 以此格式生成：`project_{project_id}_bot_{random_string}@noreply.{Gitlab.config.gitlab.host}` | `project_123_bot_4ffca233d8298ea1@noreply.example.com` |

<a id="restrict-the-creation-of-project-access-tokens"></a>

## 限制项目访问令牌的创建

为了限制潜在的滥用，你可以限制用户在顶级群组中为项目创建访问令牌。任何现有的令牌将保持有效，直到它们过期或被手动撤销。

更多信息，请参见[限制群组和项目访问令牌的创建](../../group/settings/group_access_tokens.md#restrict-the-creation-of-group-and-project-access-tokens)。

<a id="related-topics"></a>

## 相关主题

- [个人访问令牌](../../profile/personal_access_tokens.md)
- [群组访问令牌](../../group/settings/group_access_tokens.md)
- [项目访问令牌 API](../../../api/project_access_tokens.md)