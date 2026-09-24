---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 作为 OpenID Connect 身份提供者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用极狐GitLab作为 [OpenID Connect](https://openid.net/developers/how-connect-works/)（OIDC）身份提供者来访问其他服务。
OIDC 是一个身份层，它执行许多与 OpenID 2.0 相同的任务，但它是 API 友好的，并且可以被原生和移动应用程序使用。

客户端可以使用 OIDC 来：

- 根据极狐GitLab 执行的身份验证来验证最终用户的身份。
- 以可互操作且类似 REST 的方式获取有关最终用户的基本配置文件信息。

您可以将 [OmniAuth::OpenIDConnect](https://github.com/omniauth/omniauth_openid_connect) 用于 Rails 应用程序，还有许多其他可用的 [客户端实现](https://openid.net/developers/certified-openid-connect-implementations/)。

极狐GitLab 使用 `doorkeeper-openid_connect` gem 来提供 OIDC 服务。有关更多信息，请参见 [`doorkeeper-openid_connect` 仓库](https://github.com/doorkeeper-gem/doorkeeper-openid_connect "Doorkeeper::OpenidConnect repository")。

如果某些用户仅将极狐GitLab 用作 OIDC 提供者，并且不需要访问极狐GitLab 项目或群组，请考虑在其顶级群组中为其分配 [最小访问权限](../user/permissions.md#users-with-minimal-access) 角色。
最小访问权限用户不会消耗订阅中的席位，并且在 [限制访问](../administration/settings/sign_up_restrictions.md#restricted-access) 处于活动状态且没有可用席位时仍然可以访问。

<a id="enable-oidc-for-oauth-applications"></a>

## 为 OAuth 应用程序启用 OIDC

要为 OAuth 应用程序启用 OIDC，您需要在应用程序设置中选择 `openid` 范围。有关更多信息，请参见 [将极狐GitLab 配置为 OAuth 2.0 认证身份提供者](oauth_provider.md)。

<a id="settings-discovery"></a>

## 设置发现

如果您的客户端可以从发现 URL 导入 OIDC 设置，极狐GitLab 提供端点来访问此信息：

- 对于 JihuLab.com，请使用 `https://jihulab.com/.well-known/openid-configuration`。
- 对于极狐GitLab 私有化部署，请使用 `https://<your-gitlab-instance>/.well-known/openid-configuration`

<a id="shared-information"></a>

## 共享信息

以下用户信息与客户端共享：

| 声明                | 类型      | 描述 | 包含在 ID 令牌中 | 包含在 `userinfo` 端点中 |
|:---------------------|:----------|:------------|:---------------------|:------------------------------|
| `sub`                | `string`  | 用户 ID | 是 | 是 |
| `auth_time`          | `integer` | 用户上次认证的时间戳 | 是 | 否 |
| `name`               | `string`  | 用户的全名 | 是 | 是 |
| `nickname`           | `string`  | 用户的极狐GitLab 用户名 | 是 | 是 |
| `preferred_username` | `string`  | 用户的极狐GitLab 用户名 | 是 | 是 |
| `email`              | `string`  | 用户的主要电子邮件地址 | 是 | 是 |
| `email_verified`     | `boolean` | 用户的电子邮件地址是否已验证 | 是 | 是 |
| `website`            | `string`  | 用户网站的 URL | 是 | 是 |
| `profile`            | `string`  | 用户极狐GitLab 个人资料的 URL | 是 | 是 |
| `picture`            | `string`  | 用户极狐GitLab 头像的 URL | 是 | 是 |
| `groups`             | `array`   | 用户是成员的群组路径，无论是直接成员还是通过上级群组。 | 否 | 是 |
| `groups_direct`      | `array`   | 用户是其直接成员的群组路径。 | 是 | 否 |
| `https://gitlab.org/claims/groups/owner`      | `array`   | 用户是直接成员且具有所有者角色的群组名称 | 否 | 是 |
| `https://gitlab.org/claims/groups/maintainer` | `array`   | 用户是直接成员且具有维护者角色的群组名称 | 否 | 是 |
| `https://gitlab.org/claims/groups/developer`  | `array`   | 用户是直接成员且具有开发者角色的群组名称 | 否 | 是 |

`email` 和 `email_verified` 声明仅在应用程序有权访问 `email` 范围且用户的公共电子邮件地址时才会包含。所有其他声明可从 OIDC 客户端使用的 `/oauth/userinfo` 端点获取。
