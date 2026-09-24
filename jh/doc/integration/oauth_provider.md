---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置极狐GitLab 作为 OAuth 2.0 身份验证提供者
---

{{< history >}}

- OAuth 应用的群组 SAML SSO 支持在极狐GitLab 18.2 中引入，通过一个名为 `ff_oauth_redirect_to_sso_login` 的功能标志。默认禁用。
- OAuth 应用的群组 SAML SSO 支持在极狐GitLab 18.3 中在 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 18.5 中 GA。功能标志 `ff_oauth_redirect_to_sso_login` 已移除。

{{< /history >}}

[OAuth 2.0](https://oauth.net/2/) 提供安全的委托服务器资源访问给客户端应用，代表资源所有者。OAuth 2 允许授权服务器在资源所有者或最终用户的批准下向第三方客户端颁发访问令牌。

您可以通过向实例添加以下类型的 OAuth 2 应用，将极狐GitLab 用作 OAuth 2 身份验证提供者：

- [用户拥有的应用](#create-a-user-owned-application)。
- [群组拥有的应用](#create-a-group-owned-application)。
- [实例范围的应用](#create-an-instance-wide-application)。

这些方法仅在[权限级别](../user/permissions.md)上有所不同。默认回调 URL 是 SSL URL `https://your-gitlab.example.com/users/auth/gitlab/callback`。您也可以使用非 SSL URL，但建议使用 SSL URL。

向实例添加 OAuth 2 应用后，您可以使用 OAuth 2 来：

- 使用户能够使用其 JihuLab.com 账户登录您的应用。
- 使用户能够在关联群组配置了 SAML 时，使用 [SAML SSO](../user/group/saml_sso/_index.md) 登录您的应用。
- 设置 JihuLab.com 用于对您的极狐GitLab 实例进行身份验证。更多信息，请参见[将您的服务器与 JihuLab.com 集成](gitlab.md)。
- 创建应用后，外部服务可以使用 [OAuth 2 API](../api/oauth2.md) 管理访问令牌。

<a id="create-a-user-owned-application"></a>

## 创建用户拥有的应用

为您的用户创建新应用：

1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **应用**。
1. 选择 **添加新应用**。
1. 输入 **名称** 和 **重定向 URI**。
1. 根据[已授权应用](#view-all-authorized-applications)中的定义选择 OAuth 2 **范围**。
1. 在 **重定向 URI** 中，输入用户授权极狐GitLab 后跳转的 URL。
1. 选择 **保存应用**。极狐GitLab 会提供：

   - **应用 ID** 字段中的 OAuth 2 客户端 ID。
   - OAuth 2 客户端密钥，可通过在 **密钥** 字段中选择 **复制** 来访问。
   - **更新密钥** 功能。使用此功能为此应用生成并复制新密钥。更新密钥会阻止现有应用在凭据更新之前正常工作。

<a id="create-a-group-owned-application"></a>

## 创建群组拥有的应用

为群组创建新应用：

1. 前往所需的群组。
1. 在左侧边栏中，选择 **设置** > **应用**。
1. 输入 **名称** 和 **重定向 URI**。
1. 根据[已授权应用](#view-all-authorized-applications)中的定义选择 OAuth 2 范围。
1. 在 **重定向 URI** 中，输入用户授权极狐GitLab 后跳转的 URL。
1. 选择 **保存应用**。极狐GitLab 会提供：

   - **应用 ID** 字段中的 OAuth 2 客户端 ID。
   - OAuth 2 客户端密钥，可通过在 **密钥** 字段中选择 **复制** 来访问。
   - **更新密钥** 功能。使用此功能为此应用生成并复制新密钥。更新密钥会阻止现有应用在凭据更新之前正常工作。

<a id="create-an-instance-wide-application"></a>

## 创建实例范围的应用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

前提条件：

- 管理员访问权限。

为您的极狐GitLab 实例创建应用：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **应用**。
1. 选择 **新应用**。

在 **管理员** 区域创建应用时，将其标记为 **受信任**。此应用的用户授权步骤将自动跳过。

<a id="view-all-authorized-applications"></a>

## 查看所有已授权应用

{{< history >}}

- `k8s_proxy` 在极狐GitLab 16.4 中引入，通过一个名为 `k8s_proxy_pat` 的功能标志。默认启用。
- 功能标志 `k8s_proxy_pat` 在极狐GitLab 16.5 中移除。

{{< /history >}}

要查看您已使用极狐GitLab 凭据授权的所有应用：

1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **应用**。
1. 查看 **已授权应用** 部分。

极狐GitLab OAuth 2 应用支持范围，允许应用执行不同的操作。请参见下表了解所有可用的范围。

| 范围 | 描述 |
|------|------|
| `api` | 授予对 API 的完整读写访问权限，包括所有群组和项目、容器镜像仓库、依赖代理和软件包仓库。 |
| `read_api` | 授予对 API 的只读访问权限，包括所有群组和项目、容器镜像仓库和软件包仓库。 |
| `read_user` | 通过 `/user` API 端点授予对已认证用户资料的只读访问权限，包括用户名、公开电子邮件和全名。还授予对 `/users` 下只读 API 端点的访问权限。 |
| `create_runner` | 授予创建 runner 的权限。 |
| `manage_runner` | 授予管理 runner 的权限。 |
| `k8s_proxy` | 授予使用 Kubernetes 代理执行 Kubernetes API 调用的权限。 |
| `read_repository` | 授予通过 Git-over-HTTP 或仓库文件 API 对私有项目仓库的只读访问权限。 |
| `write_repository` | 授予通过 Git-over-HTTP（不使用 API）对私有项目仓库的读写访问权限。 |
| `read_registry` | 授予对私有项目容器镜像仓库镜像的只读访问权限。 |
| `write_registry` | 授予对私有项目容器镜像仓库镜像的写入访问权限。推送镜像需要读写权限。 |
| `read_virtual_registry` | 授予通过私有项目和虚拟仓库中的依赖代理对容器镜像的只读访问权限。 |
| `write_virtual_registry` | 授予通过私有项目中的依赖代理对容器镜像的读取、写入和删除访问权限。 |
| `read_observability` | 授予对极狐GitLab 可观测性的只读访问权限。 |
| `write_observability` | 授予对极狐GitLab 可观测性的写入访问权限。 |
| `ai_features` | 授予对极狐GitLab Duo 相关 API 端点的访问权限。 |
| `sudo` | 当以管理员用户身份认证时，授予以系统中任何用户身份执行 API 操作的权限。 |
| `admin_mode` | 当启用管理员模式时，授予以管理员身份执行 API 操作的权限。 |
| `read_service_ping` | 当以管理员用户身份认证时，授予通过 API 下载 Service Ping 负载的访问权限。 |
| `openid` | 授予使用 OpenID Connect 进行极狐GitLab 认证的权限。还授予对用户资料和群组成员资格的只读访问权限。 |
| `profile` | 授予使用 OpenID Connect 对用户资料数据的只读访问权限。 |
| `email` | 授予使用 OpenID Connect 对用户主要电子邮件地址的只读访问权限。 |

您可以随时通过选择 **撤销** 来撤销任何访问权限。

<a id="access-token-expiration"></a>

## 访问令牌过期

访问令牌在两小时后过期。使用访问令牌的集成必须使用 `refresh_token` 属性生成新的令牌。即使 `access_token` 本身过期后，刷新令牌仍可使用。有关如何刷新过期访问令牌的更多详细信息，请参见 [OAuth 2.0 令牌文档](../api/oauth2.md)。

此过期设置在极狐GitLab 代码库中通过 Doorkeeper 的 `access_token_expires_in` 配置进行设置，Doorkeeper 是提供极狐GitLab 作为 OAuth 提供者功能的库。过期设置不可配置。

当应用被删除时，与该应用关联的所有授权和令牌也会被删除。

<a id="hashed-oauth-application-secrets"></a>

## 哈希 OAuth 应用密钥

默认情况下，极狐GitLab 以哈希格式将 OAuth 应用密钥存储在数据库中。这些密钥仅在创建 OAuth 应用后立即可供用户使用。在早期版本的极狐GitLab 中，应用密钥以明文形式存储在数据库中。

<a id="other-ways-to-use-oauth-2-in-gitlab"></a>

## 在极狐GitLab 中使用 OAuth 2 的其他方式

您可以：

- 使用 [Applications API](../api/applications.md) 创建和管理 OAuth 2 应用。
- 使用户能够使用第三方 OAuth 2 提供者登录极狐GitLab。更多信息，请参见 [OmniAuth 文档](omniauth.md)。
- 将极狐GitLab 导入器与 OAuth 2 结合使用，以授予对仓库的访问权限，而无需共享您的 JihuLab.com 账户凭据。