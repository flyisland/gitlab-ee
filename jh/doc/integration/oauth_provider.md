---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab 配置为 OAuth 2.0 认证身份提供商
---

[OAuth 2.0](https://oauth.net/2/) 代表资源所有者，为客户端应用程序提供安全的委托式服务器资源访问。OAuth 2 允许授权服务器在资源所有者或最终用户批准的情况下，向第三方客户端颁发访问令牌。

您可以将极狐GitLab 用作 OAuth 2 认证身份提供商，只需向实例添加以下类型的 OAuth 2 应用程序：

- [用户拥有的应用程序](#create-a-user-owned-application)。
- [群组拥有的应用程序](#create-a-group-owned-application)。
- [实例范围的应用程序](#create-an-instance-wide-application)。

这些方法仅在[权限级别](../user/permissions.md)上有所不同。默认回调 URL 是 SSL URL `https://your-gitlab.example.com/users/auth/gitlab/callback`。您也可以使用非 SSL URL，但建议使用 SSL URL。

向实例添加 OAuth 2 应用程序后，您可以使用 OAuth 2 来：

- 让用户使用其 JihuLab.com 账号登录您的应用程序。
- 当为关联群组配置了 SAML 时，让用户使用 [SAML SSO](../user/group/saml_sso/_index.md) 登录您的应用程序。
- 将 JihuLab.com 设置为您的极狐GitLab 实例的认证来源。更多信息，请参见[将您的服务器与 JihuLab.com 集成](gitlab.md)。
- 创建应用程序后，外部服务可以使用 [OAuth 2 API](../api/oauth2.md) 管理访问令牌。

<a id="create-a-user-owned-application"></a>

## 创建用户拥有的应用程序

要为您的用户创建新应用程序：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **应用程序**。
1. 选择**添加新应用程序**。
1. 输入**名称**和**重定向 URI**。
1. 按[已授权应用程序](#view-all-authorized-applications)中的定义选择 OAuth 2 **作用域**。
1. 在**重定向 URI**中，输入用户通过极狐GitLab 授权后跳转到的 URL。
1. 选择**保存应用程序**。极狐GitLab 会提供：

   - **应用程序 ID** 字段中的 OAuth 2 客户端 ID。
   - OAuth 2 客户端密钥，可通过在**密钥**字段中选择**复制**获取。
   - **更新密钥** 功能。使用此功能可为该应用程序生成并复制新密钥。更新密钥后，在更新凭据之前，现有应用程序将无法正常工作。

<a id="create-a-group-owned-application"></a>

## 创建群组拥有的应用程序

要为群组创建新应用程序：

1. 转到所需的群组。
1. 在左侧边栏中，选择**设置** > **应用程序**。
1. 输入**名称**和**重定向 URI**。
1. 按[已授权应用程序](#view-all-authorized-applications)中的定义选择 OAuth 2 作用域。
1. 在**重定向 URI**中，输入用户通过极狐GitLab 授权后跳转到的 URL。
1. 选择**保存应用程序**。极狐GitLab 会提供：

   - **应用程序 ID** 字段中的 OAuth 2 客户端 ID。
   - OAuth 2 客户端密钥，可通过在**密钥**字段中选择**复制**获取。
   - **更新密钥** 功能。使用此功能可为该应用程序生成并复制新密钥。更新密钥后，在更新凭据之前，现有应用程序将无法正常工作。

<a id="create-an-instance-wide-application"></a>

## 创建实例范围的应用程序

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 管理员访问权限。

要为您的极狐GitLab 实例创建应用程序：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**应用程序**。
1. 选择**新建应用程序**。

在**管理**区域中创建应用程序时，将其标记为**受信任**。该应用程序会自动跳过用户授权步骤。

<a id="view-all-authorized-applications"></a>

## 查看所有已授权的应用程序

要查看您使用极狐GitLab 凭据授权的所有应用程序：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **应用程序**。
1. 查看**已授权的应用程序**部分。

极狐GitLab OAuth 2 应用程序支持作用域，允许应用程序执行不同的操作。所有可用的作用域见下表。

| 作用域                    | 描述 |
|--------------------------|-------------|
| `api`                    | 授予对 API 的完整读写访问权限，包括所有群组和项目、容器镜像仓库、依赖代理和软件包仓库。 |
| `read_api`               | 授予对 API 的读取访问权限，包括所有群组和项目、容器镜像仓库和软件包仓库。 |
| `read_user`              | 授予通过 `/user` API 端点对已认证用户个人资料的只读访问权限，包括用户名、公开邮箱和全名。还授予对 `/users` 下只读 API 端点的访问权限。 |
| `create_runner`          | 授予创建 Runner 的访问权限。 |
| `manage_runner`          | 授予管理 Runner 的访问权限。 |
| `k8s_proxy`              | 授予使用极狐GitLab Kubernetes Agent 执行 Kubernetes API 调用的权限。 |
| `read_repository`        | 授予使用 Git-over-HTTP 或代码仓库文件 API 对私有项目代码仓库的只读访问权限。 |
| `write_repository`       | 授予使用 Git-over-HTTP（不使用 API）对私有项目代码仓库的读写访问权限。 |
| `read_registry`          | 授予对私有项目容器镜像仓库镜像的只读访问权限。 |
| `write_registry`         | 授予对私有项目容器镜像仓库镜像的写入访问权限。推送镜像需要同时具有读取和写入权限。 |
| `read_virtual_registry`  | 授予通过私有项目中的依赖代理和虚拟仓库对容器镜像的只读访问权限。 |
| `write_virtual_registry` | 授予通过私有项目中的依赖代理对容器镜像的读取、写入和删除访问权限。 |
| `read_observability`     | 授予对极狐GitLab 可观测性的只读访问权限。 |
| `write_observability`    | 授予对极狐GitLab 可观测性的写入访问权限。 |
| `ai_features`            | 授予对极狐GitLab Duo 相关 API 端点的访问权限。 |
| `sudo`                   | 授予在以管理员用户身份认证时，以系统中任意用户身份执行 API 操作的权限。 |
| `admin_mode`             | 授予在启用管理员模式时，以管理员身份执行 API 操作的权限。 |
| `read_service_ping`      | 授予在以管理员用户身份认证时，通过 API 下载 Service Ping 负载的访问权限。 |
| `openid`                 | 授予使用 [OpenID Connect](openid_connect_provider.md) 通过极狐GitLab 进行认证的权限。还授予对用户个人资料和群组成员关系的只读访问权限。 |
| `profile`                | 授予使用 [OpenID Connect](openid_connect_provider.md) 对用户个人资料数据的只读访问权限。 |
| `email`                  | 授予使用 [OpenID Connect](openid_connect_provider.md) 对用户主邮箱地址的只读访问权限。 |

您可以随时选择**撤销**来撤销任何访问权限。

<a id="access-token-expiration"></a>

## 访问令牌过期

默认情况下，访问令牌在两小时（7200 秒）后过期。使用访问令牌的集成必须使用 `refresh_token` 属性生成新令牌。即使访问令牌本身已过期，刷新令牌仍可使用。有关如何刷新已过期访问令牌的信息，请参见 [OAuth 2.0 令牌文档](../api/oauth2.md)。

在极狐GitLab 私有化部署上，管理员可以配置令牌有效期。更多信息，请参见[修改 OAuth 访问令牌最长有效期](../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-oauth-access-tokens)。

删除应用程序时，与该应用程序关联的所有授权和令牌也会一并删除。

<a id="hashed-oauth-application-secrets"></a>

## 哈希处理的 OAuth 应用程序密钥

默认情况下，极狐GitLab 以哈希格式将 OAuth 应用程序密钥存储在数据库中。这些密钥仅在创建 OAuth 应用程序后立即对用户可用。在极狐GitLab 的早期版本中，应用程序密钥以纯文本形式存储在数据库中。

<a id="other-ways-to-use-oauth-2-in-gitlab"></a>

## 在极狐GitLab 中使用 OAuth 2 的其他方式

您可以：

- 使用[应用程序 API](../api/applications.md) 创建和管理 OAuth 2 应用程序。
- 让用户使用第三方 OAuth 2 提供商登录极狐GitLab。更多信息，请参见 [OmniAuth 文档](omniauth.md)。
- 使用极狐GitLab 导入器配合 OAuth 2，以授予对代码仓库的访问权限，而无需共享您的 JihuLab.com 账号凭据。
