---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 OpenID Connect 作为身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将极狐GitLab 作为客户端应用程序，使用 [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html)
作为 OmniAuth 提供商。

要启用 OpenID Connect OmniAuth 提供商，您必须向 OpenID Connect 提供商注册您的应用程序。
OpenID Connect 提供商将为您提供客户端的详细信息和密钥供您使用。

1. 在极狐GitLab 服务器上，打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置[通用设置](../../integration/omniauth.md#configure-common-settings)
   以添加 `openid_connect` 作为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时
   账号预配。

1. 添加提供商配置。

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect", # do not change this parameter
       label: "Provider name", # optional label for login button, defaults to "Openid Connect"
       icon: "<custom_provider_icon>",
       args: {
         name: "openid_connect",
         scope: ["openid","profile","email"],
         response_type: "code",
         issuer: "<your_oidc_url>",
         discovery: true,
         client_auth_method: "query",
         uid_field: "<uid_field>",
         send_scope_to_token_endpoint: "false",
         pkce: true,
         client_options: {
           identifier: "<your_oidc_client_id>",
           secret: "<your_oidc_client_secret>",
           redirect_uri: "<your_gitlab_url>/users/auth/openid_connect/callback"
         }
       }
     }
   ]
   ```

   对于使用多个身份提供商的 Linux 软件包安装：

   ```ruby
   { 'name' => 'openid_connect',
     'label' => '...',
     'icon' => '...',
     'args' => {
       'name' => 'openid_connect',
       'strategy_class': 'OmniAuth::Strategies::OpenIDConnect',
       'scope' => ['openid', 'profile', 'email'],
       'discovery' => true,
       'response_type' => 'code',
       'issuer' => 'https://...',
       'client_auth_method' => 'query',
       'uid_field' => '...',
       'client_options' => {
         `identifier`: "<your_oidc_client_id>",
         `secret`: "<your_oidc_client_secret>",
         'redirect_uri' => 'https://.../users/auth/openid_connect/callback'
      }
    }
   },
   { 'name' => 'openid_connect_2fa',
     'label' => '...',
     'icon' => '...',
     'args' => {
       'name' => 'openid_connect_2fa',
       'strategy_class': 'OmniAuth::Strategies::OpenIDConnect',
       'scope' => ['openid', 'profile', 'email'],
       'discovery' => true,
       'response_type' => 'code',
       'issuer' => 'https://...',
       'client_auth_method' => 'query',
       'uid_field' => '...',
       'client_options' => {
        ...
        'redirect_uri' => 'https://.../users/auth/openid_connect_2fa/callback'
      }
    }
   }
   ```

   对于自编译安装：

   ```yaml
     - { name: 'openid_connect', # do not change this parameter
         label: 'Provider name', # optional label for login button, defaults to "Openid Connect"
         icon: '<custom_provider_icon>',
         args: {
           name: 'openid_connect',
           scope: ['openid','profile','email'],
           response_type: 'code',
           issuer: '<your_oidc_url>',
           discovery: true,
           client_auth_method: 'query',
           uid_field: '<uid_field>',
           send_scope_to_token_endpoint: false,
           pkce: true,
           client_options: {
             identifier: '<your_oidc_client_id>',
             secret: '<your_oidc_client_secret>',
             redirect_uri: '<your_gitlab_url>/users/auth/openid_connect/callback'
           }
         }
       }
   ```

   > [!note]
   > 有关每个配置选项的更多信息，请参阅 [OmniAuth OpenID Connect 使用文档](https://github.com/omniauth/omniauth_openid_connect#usage)和 [OpenID Connect Core 1.0 规范](https://openid.net/specs/openid-connect-core-1_0.html)。

1. 对于提供商配置，更改提供商的值以匹配您的
   OpenID Connect 客户端设置。使用以下内容作为指南：

   - `<your_oidc_label>` 是登录页面上显示的标记。
   - `<custom_provider_icon>`（可选）是登录页面上显示的图标。
     主要社交登录平台的图标已内置于极狐GitLab 中，
     但您可以通过指定此参数来覆盖这些图标。极狐GitLab 同时接受
     本地路径和绝对 URL。
     极狐GitLab 包含大多数主要社交登录平台的图标，
     但您可以通过指定外部 URL 或
     指向您自己的图标文件的绝对或相对路径来覆盖这些图标。
     - 对于本地绝对路径，将提供商设置配置为 `icon: <path>/<to>/<your-icon>`。
       - 将图标文件存储在 `/opt/gitlab/embedded/service/gitlab-rails/public/<path>/<to>/<your-icon>`。
       - 通过 `https://gitlab.example/<path>/<to>/<your-icon>` 访问图标文件。
     - 对于本地相对路径，将提供商设置配置为 `icon: <your-icon>`。
       - 将图标文件存储在 `/opt/gitlab/embedded/service/gitlab-rails/public/images/<your-icon>`。
       - 通过 `https://gitlab.example.com/images/<your-icon>` 访问图标文件。
   - `<your_oidc_url>`（可选）是指向 OpenID Connect
     提供商的 URL（例如，`https://example.com/auth/realms/your-realm`）。
     如果未提供此值，则 URL 将根据 `client_options`
     按以下格式构建：`<client_options.scheme>://<client_options.host>:<client_options.port>`。
   - 如果 `discovery` 设置为 `true`，OpenID Connect 提供商将尝试使用
     `<your_oidc_url>/.well-known/openid-configuration` 自动
     发现客户端选项。
     默认为 `false`。
   - `client_auth_method`（可选）指定用于向 OpenID Connect 提供商
     验证客户端的方法。
     - 支持的值为：
       - `basic` - HTTP 基本身份验证。
       - `jwt_bearer` - 基于 JWT 的身份验证（私钥和客户端密钥签名）。
       - `mtls` - 双向 TLS 或 X.509 证书验证。
       - 任何其他值都会在请求正文中提交客户端 ID 和密钥。
     - 如果未指定，此值默认为 `basic`。
   - `<uid_field>`（可选）是 `user_info.raw_attributes`中的字段名称，
     用于定义 `uid`的值（例如，`preferred_username`）。
     如果您未提供此值，或者 `user_info.raw_attributes` 详细信息中缺少
     配置值对应的字段，则 `uid` 使用 `sub` 字段。
   - `send_scope_to_token_endpoint` 默认为 `true`，因此 `scope` 参数
     通常包含在对令牌端点的请求中。
     但是，如果您的 OpenID Connect 提供商不接受此类请求中的 `scope` 参数，
     请将其设置为 `false`。
   - `pkce`（可选）：启用 [Proof Key for Code Exchange](https://www.rfc-editor.org/rfc/rfc7636)。
   - `client_options` 是 OpenID Connect 客户端特定的选项。具体来说：
     - `identifier` 是在 OpenID Connect 服务提供商中配置的客户端标识符。
     - `secret` 是在 OpenID Connect 服务提供商中配置的客户端密钥。例如，
       [OmniAuth OpenID Connect](https://github.com/omniauth/omniauth_openid_connect) 需要此项。如果服务提供商不需要密钥，
       请提供任意值，该值将被忽略。
     - `redirect_uri` 是登录成功后用于重定向用户的极狐GitLab URL
       （例如，`http://example.com/users/auth/openid_connect/callback`）。
     - 以下 `client_options` 是可选的，除非自动发现被禁用或不成功：
       - `authorization_endpoint` 是授权最终用户的端点 URL。
       - `token_endpoint` 是提供访问令牌的端点 URL。
       - `userinfo_endpoint` 是提供用户信息的端点 URL。
       - `jwks_uri` 是令牌签名者发布其密钥的端点 URL。

1. 保存配置文件。
1. 要使更改生效，如果您：

   - 使用 Linux 软件包安装极狐GitLab，请[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 自编译安装极狐GitLab，请[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

在登录页面上，常规登录表单下方会显示 OpenID Connect 选项。选择此选项以开始身份验证过程。如果客户端要求确认，OpenID Connect 提供商将要求您登录并授权极狐GitLab 应用程序。您将被重定向到极狐GitLab 并登录。

<a id="example-configurations"></a>

## 示例配置

以下配置说明了在使用 Linux 软件包安装时，如何为不同的提供商设置 OpenID。

<a id="configure-google"></a>

### 配置 Google

有关更多详细信息，请参阅 [Google 文档](https://developers.google.com/identity/openid-connect/openid-connect)：

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "openid_connect", # do not change this parameter
    label: "Google OpenID", # optional label for login button, defaults to "Openid Connect"
    args: {
      name: "openid_connect",
      scope: ["openid", "profile", "email"],
      response_type: "code",
      issuer: "https://accounts.google.com",
      client_auth_method: "query",
      discovery: true,
      uid_field: "preferred_username",
      pkce: true,
      client_options: {
        identifier: "<YOUR PROJECT CLIENT ID>",
        secret: "<YOUR PROJECT CLIENT SECRET>",
        redirect_uri: "https://example.com/users/auth/openid_connect/callback",
       }
     }
  }
]
```

<a id="configure-microsoft-azure"></a>

### 配置 Microsoft Azure

Microsoft Azure 的 OpenID Connect (OIDC) 协议使用 [Microsoft 标识平台 (v2) 端点](https://learn.microsoft.com/en-us/previous-versions/azure/active-directory/azuread-dev/azure-ad-endpoint-comparison)。
要开始使用，请登录 [Azure 门户](https://portal.azure.com)。对于您的应用，您需要以下信息：

- 租户 ID。您可能已经拥有一个。有关更多信息，请参阅
  [Microsoft Azure 租户](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-create-new-tenant)文档。
- 客户端 ID 和客户端密钥。按照
  [Microsoft 快速入门：注册应用程序](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)文档中的说明
  获取您应用的租户 ID、客户端 ID 和客户端密钥。

注册 Microsoft Azure 应用程序时，您必须授予 API 权限，以允许极狐GitLab
检索所需的详细信息。您必须至少提供 `openid`、`profile` 和 `email` 权限。有关更多信息，请参阅 [Microsoft 关于为 Web API 配置应用权限的文档](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-configure-app-access-web-apis#add-permissions-to-access-microsoft-graph)。

> [!note]
> 由 Azure 预配的所有账号都必须定义电子邮件地址。如果未定义电子邮件地址，Azure 会分配一个随机生成的地址。如果您已配置[新用户的域名限制](../settings/sign_up_restrictions.md#allow-or-deny-account-creation-by-using-specific-email-domains)，此随机地址可能会导致账号无法创建。

Linux 软件包安装的示例配置块：

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "openid_connect", # do not change this parameter
    label: "Azure OIDC", # optional label for login button, defaults to "Openid Connect"
    args: {
      name: "openid_connect",
      scope: ["openid", "profile", "email"],
      response_type: "code",
      issuer:  "https://login.microsoftonline.com/<YOUR-TENANT-ID>/v2.0",
      client_auth_method: "query",
      discovery: true,
      uid_field: "preferred_username",
      pkce: true,
      client_options: {
        identifier: "<YOUR APP CLIENT ID>",
        secret: "<YOUR APP CLIENT SECRET>",
        redirect_uri: "https://gitlab.example.com/users/auth/openid_connect/callback"
      }
    }
  }
]
```

Microsoft 已记录其平台如何与 [OIDC 协议](https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc)配合工作。

<a id="microsoft-entra-custom-signing-keys"></a>

#### Microsoft Entra 自定义签名密钥

如果您的应用程序因为使用了 [SAML 声明映射功能](https://learn.microsoft.com/en-us/entra/identity-platform/saml-claims-customization)而具有自定义签名密钥，则必须按以下方式配置 OpenID 提供商：

- 通过省略 `args.discovery` 或将其设置为 `false` 来禁用 OpenID Connect 发现。
- 在 `client_options`中，指定以下内容：
  - 带有 `appid` 查询参数的 `jwks_uri`：`https://login.microsoftonline.com/<YOUR-TENANT-ID>/discovery/v2.0/keys?appid=<YOUR APP CLIENT ID>`。
  - `end_session_endpoint`。
  - `authorization_endpoint`。
  - `userinfo_endpoint`。

Linux 软件包安装的示例配置：

```ruby
gitlab_rails['omniauth_providers'] = [
 {
    name: "openid_connect", # do not change this parameter
    label: "Azure OIDC", # optional label for login button, defaults to "Openid Connect"
    args: {
      name: "openid_connect",
      scope: ["openid", "profile", "email"],
      response_type: "code",
      issuer:  "https://login.microsoftonline.com/<YOUR-TENANT-ID>/v2.0",
      client_auth_method: "basic",
      discovery: false,
      uid_field: "preferred_username",
      pkce: true,
      client_options: {
        identifier: "<YOUR APP CLIENT ID>",
        secret: "<YOUR APP CLIENT SECRET>",
        redirect_uri: "https://gitlab.example.com/users/auth/openid_connect/callback",
        end_session_endpoint: "https://login.microsoftonline.com/<YOUR-TENANT-ID>/oauth2/v2.0/logout",
        authorization_endpoint: "https://login.microsoftonline.com/<YOUR-TENANT-ID>/oauth2/v2.0/authorize",
        token_endpoint: "https://login.microsoftonline.com/<YOUR-TENANT-ID>/oauth2/v2.0/token",
        userinfo_endpoint: "https://graph.microsoft.com/oidc/userinfo",
        jwks_uri: "https://login.microsoftonline.com/<YOUR-TENANT-ID>/discovery/v2.0/keys?appid=<YOUR APP CLIENT ID>"
      }
    }
  }
]
```

如果您看到带有 `KidNotFound` 消息的身份验证失败，这可能是因为缺少或不正确的 `appid` 查询参数。如果 Microsoft 返回的 ID 令牌无法使用 `jwks_uri` 端点提供的密钥进行验证，极狐GitLab 会引发该错误。

有关更多信息，请参阅 [Microsoft Entra 关于验证令牌的文档](https://learn.microsoft.com/en-us/entra/identity-platform/access-tokens#validate-tokens)。

<a id="migrate-to-generic-openid-connect-configuration"></a>

#### 迁移到通用 OpenID Connect 配置

您可以从 `azure_activedirectory_v2` 和 `azure_oauth2` 迁移到通用 OpenID Connect 配置。

首先，设置 `uid_field`。`uid_field` 和您可以选择作为 `uid_field`的 `sub` 声明都因提供商而异。未设置 `uid_field` 就登录会导致在极狐GitLab 中创建额外的身份，这些身份必须手动修改：

| 提供商                                                                                                        | `uid_field` | 支持信息  |
|-----------------------------------------------------------------------------------------------------------------|-------|-----------------------------------------------------------------------|
| [`omniauth-azure-activedirectory-v2`](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/)         | `oid` | 迁移时，您必须将 `oid` 配置为 `uid_field`。 |
| [`omniauth_openid_connect`](https://github.com/omniauth/omniauth_openid_connect/)                               | `sub` | 指定 `uid_field` 以使用其他字段。 |

要迁移到通用 OpenID Connect 配置，您必须更新配置。

对于 Linux 软件包安装，按如下方式更新配置：

{{< tabs >}}

{{< tab title="Azure OAuth 2.0" >}}

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "azure_oauth2",
    label: "Azure OIDC", # optional label for login button, defaults to "Openid Connect"
    args: {
      name: "azure_oauth2", # this matches the existing azure_oauth2 provider name, and only the strategy_class immediately below configures OpenID Connect
      strategy_class: "OmniAuth::Strategies::OpenIDConnect",
      scope: ["openid", "profile", "email"],
      response_type: "code",
      issuer:  "https://login.microsoftonline.com/<YOUR-TENANT-ID>/v2.0",
      client_auth_method: "query",
      discovery: true,
      uid_field: "sub",
      send_scope_to_token_endpoint: "false",
      client_options: {
        identifier: "<YOUR APP CLIENT ID>",
        secret: "<YOUR APP CLIENT SECRET>",
        redirect_uri: "https://gitlab.example.com/users/auth/azure_oauth2/callback"
      }
    }
  }
]
```

{{< /tab >}}

{{< tab title="Azure Active Directory v2" >}}

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "azure_activedirectory_v2",
    label: "Azure OIDC", # optional label for login button, defaults to "Openid Connect"
    args: {
      name: "azure_activedirectory_v2",
      strategy_class: "OmniAuth::Strategies::OpenIDConnect",
      scope: ["openid", "profile", "email"],
      response_type: "code",
      issuer:  "https://login.microsoftonline.com/<YOUR-TENANT-ID>/v2.0",
      client_auth_method: "query",
      discovery: true,
      uid_field: "oid",
      send_scope_to_token_endpoint: "false",
      client_options: {
        identifier: "<YOUR APP CLIENT ID>",
        secret: "<YOUR APP CLIENT SECRET>",
        redirect_uri: "https://gitlab.example.com/users/auth/azure_activedirectory_v2/callback"
      }
    }
  }
]
```

{{< /tab >}}

{{< /tabs >}}

对于 Helm 安装：

在 YAML 文件（例如 `provider.yaml`）中添加[提供商的配置](https://gitlab.cn/docs/charts/charts/globals/#providers)：

{{< tabs >}}

{{< tab title="Azure OAuth 2.0" >}}

```ruby
{
  "name": "azure_oauth2",
  "args": {
    "name": "azure_oauth2",
    "strategy_class": "OmniAuth::Strategies::OpenIDConnect",
    "scope": [
      "openid",
      "profile",
      "email"
    ],
    "response_type": "code",
    "issuer": "https://login.microsoftonline.com/<YOUR-TENANT-ID>/v2.0",
    "client_auth_method": "query",
    "discovery": true,
    "uid_field": "sub",
    "send_scope_to_token_endpoint": false,
    "client_options": {
      "identifier": "<YOUR APP CLIENT ID>",
      "secret": "<YOUR APP CLIENT SECRET>",
      "redirect_uri": "https://gitlab.example.com/users/auth/azure_oauth2/callback"
    }
  }
}
```

{{< /tab >}}

{{< tab title="Azure Active Directory v2" >}}

```ruby
{
  "name": "azure_activedirectory_v2",
  "args": {
    "name": "azure_activedirectory_v2",
    "strategy_class": "OmniAuth::Strategies::OpenIDConnect",
    "scope": [
      "openid",
      "profile",
      "email"
    ],
    "response_type": "code",
    "issuer": "https://login.microsoftonline.com/<YOUR-TENANT-ID>/v2.0",
    "client_auth_method": "query",
    "discovery": true,
    "uid_field": "sub",
    "send_scope_to_token_endpoint": false,
    "client_options": {
      "identifier": "<YOUR APP CLIENT ID>",
      "secret": "<YOUR APP CLIENT SECRET>",
      "redirect_uri": "https://gitlab.example.com/users/auth/activedirectory_v2/callback"
    }
  }
}
```

{{< /tab >}}

{{< /tabs >}}

当您在升级到极狐GitLab 17.0 或更高版本的过程中从 `azure_oauth2` 迁移到 `omniauth_openid_connect` 时，为您的组织设置的 `sub` 声明值可能会有所不同。`azure_oauth2` 使用 Microsoft V1 端点，而 `azure_activedirectory_v2` 和 `omniauth_openid_connect` 都使用具有通用 `sub` 值的 Microsoft V2 端点。

- **对于在 Entra ID 中拥有电子邮件地址的用户**，要允许回退到电子邮件地址并更新用户的身份，
  请使用以下方法之一：
  - 启用自动关联。在 Linux 软件包安装中，配置 [`omniauth_auto_link_user`](../../integration/omniauth.md#automatic-linking)。
    在 Helm 安装中，配置 [`autoLinkUser`](https://gitlab.cn/docs/charts/charts/globals/#omniauth)。
  - 使用引导式关联流程，该流程会提示用户使用其现有凭据登录，以在关联前确认所有权。
    有关更多信息，请参阅[使用 OmniAuth 登录时关联现有账号](../../integration/omniauth.md#link-an-existing-account-when-signing-in-with-omniauth)。
- **对于没有电子邮件地址的用户**，管理员必须采取以下操作之一：
  - 设置另一种身份验证方法，或启用使用极狐GitLab 用户名和密码登录。然后，用户可以使用其个人资料手动登录并关联其 Azure 身份。
  - 在现有 `azure_oauth2` 之外将 OpenID Connect 实现为新提供商，以便用户可以通过 OAuth 2.0 登录，并关联其 OpenID Connect 身份（类似于前一种方法）。只要启用了 `auto_link_user`，此方法也适用于拥有电子邮件地址的用户。
  - 手动更新 `extern_uid`。为此，请使用 [API 或 Rails 控制台](../../integration/omniauth.md#change-apps-or-configuration)为每个用户更新 `extern_uid`。
    如果实例已升级到 17.0 或更高版本，并且用户已尝试登录，则可能需要使用此方法。

> [!note]
> 如果在预配极狐GitLab 账号时缺少 `email` 声明或该声明为空，`azure_oauth2` 可能已使用 Entra ID 的 `upn` 声明作为电子邮件地址。

<a id="configure-microsoft-azure-active-directory-b2c"></a>

### 配置 Microsoft Azure Active Directory B2C

极狐GitLab 需要特殊
配置才能与 [Azure Active Directory B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/overview) 配合使用。要开始使用，请登录 [Azure 门户](https://portal.azure.com)。
对于您的应用，您需要从 Azure 获取以下信息：

- 租户 ID。您可能已经拥有一个。有关更多信息，请查看
  [Microsoft Azure 租户](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-create-new-tenant)文档。
- 客户端 ID 和客户端密钥。按照
  [Microsoft 教程](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=app-reg-ga)文档中的说明获取
  您应用的客户端 ID 和客户端密钥。
- 用户流或策略名称。按照 [Microsoft 教程](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-user-flow)中的说明操作。

配置应用：

1. 设置应用 `Redirect URI`。例如，如果您的极狐GitLab 域为 `gitlab.example.com`，
   请将应用 `Redirect URI` 设置为 `https://gitlab.example.com/users/auth/openid_connect/callback`。
1. [启用 ID 令牌](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=app-reg-ga#enable-id-token-implicit-grant)。
1. 向应用添加以下 API 权限：

   - `openid`
   - `offline_access`

<a id="configure-custom-policies"></a>

#### 配置自定义策略

Azure B2C [提供两种定义用户登录业务逻辑的方式](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview)：

- [用户流](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview#user-flows)
- [自定义策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview#custom-policies)

需要使用自定义策略，因为标准 Azure B2C 用户流不会发送极狐GitLab 创建或关联用户所需的 OpenID `email` 声明。因此，标准用户流无法与 [`allow_single_sign_on` 或 `auto_link_user` 参数](../../integration/omniauth.md#configure-common-settings)配合使用。使用标准 Azure B2C 策略时，极狐GitLab 无法创建新账号，也无法通过电子邮件地址关联到现有账号。

有关 Azure AD B2C 如何在用户流和自定义策略中颁发令牌和声明的更多信息，请参阅 Microsoft 关于[用户流和自定义策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview)以及[声明架构配置](https://learn.microsoft.com/en-us/azure/active-directory-b2c/claimsschema)的文档。

首先，[创建自定义策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy)。

Microsoft 说明在[自定义策略入门包](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#custom-policy-starter-pack)中使用 `SocialAndLocalAccounts`，但 `LocalAccounts` 是针对本地 Active Directory 账号进行身份验证。在您[上传策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#upload-the-policies)之前，请执行以下操作：

1. 要导出 `email` 声明，请修改 `SignUpOrSignin.xml`。将以下行：

   ```xml
   <OutputClaim ClaimTypeReferenceId="email" />
   ```

   替换为：

   ```xml
   <OutputClaim ClaimTypeReferenceId="signInNames.emailAddress" PartnerClaimType="email" />
   ```

1. 要使 OIDC 发现能够与 B2C 配合使用，请使用与
   [OIDC 规范](https://openid.net/specs/openid-connect-discovery-1_0.html#rfc.section.4.3)兼容的颁发者配置策略。
   请参阅[令牌兼容性设置](https://learn.microsoft.com/en-us/azure/active-directory-b2c/configure-tokens?pivots=b2c-custom-policy#token-compatibility-settings)。
   在 `TrustFrameworkBase.xml`中的 `JwtIssuer` 下，将 `IssuanceClaimPattern` 设置为 `AuthorityWithTfp`：

   ```xml
   <ClaimsProvider>
     <DisplayName>Token Issuer</DisplayName>
     <TechnicalProfiles>
       <TechnicalProfile Id="JwtIssuer">
         <DisplayName>JWT Issuer</DisplayName>
         <Protocol Name="None" />
         <OutputTokenFormat>JWT</OutputTokenFormat>
         <Metadata>
           <Item Key="IssuanceClaimPattern">AuthorityWithTfp</Item>
           ...
   ```

1. [上传策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#upload-the-policies)。如果您要更新现有策略，
   请覆盖现有文件。

1. 要确定颁发者 URL，请使用登录策略。颁发者 URL 的格式为：

   ```markdown
   https://<YOUR-DOMAIN>/tfp/<YOUR-TENANT-ID>/<YOUR-SIGN-IN-POLICY-NAME>/v2.0/
   ```

   URL 中的策略名称为小写。例如，`B2C_1A_signup_signin`
   策略显示为 `b2c_1a_signup_signin`。

   确保包含末尾的正斜杠。

1. 验证 OIDC 发现 URL 和颁发者 URL 的操作，并将
   `.well-known/openid-configuration` 附加到颁发者 URL：

   ```markdown
   https://<YOUR-DOMAIN>/tfp/<YOUR-TENANT-ID>/<YOUR-SIGN-IN-POLICY-NAME>/v2.0/.well-known/openid-configuration
   ```

   例如，如果 `domain` 为 `example.b2clogin.com` 且租户 ID 为
   `fc40c736-476c-4da1-b489-ee48cee84386`，您可以使用 `curl` 和 `jq` 提取颁发者：

   ```shell
   $ curl --silent "https://example.b2clogin.com/tfp/fc40c736-476c-4da1-b489-ee48cee84386/b2c_1a_signup_signin/v2.0/.well-known/openid-configuration" | jq .issuer
   "https://example.b2clogin.com/tfp/fc40c736-476c-4da1-b489-ee48cee84386/b2c_1a_signup_signin/v2.0/"
   ```

1. 使用用于 `signup_signin`的自定义策略配置颁发者 URL。例如，这是
   Linux 软件包安装中为 `b2c_1a_signup_signin` 使用自定义策略的配置：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
   {
     name: "openid_connect", # do not change this parameter
     label: "Azure B2C OIDC", # optional label for login button, defaults to "Openid Connect"
     args: {
       name: "openid_connect",
       scope: ["openid"],
       response_mode: "query",
       response_type: "id_token",
       issuer:  "https://<YOUR-DOMAIN>/tfp/<YOUR-TENANT-ID>/b2c_1a_signup_signin/v2.0/",
       client_auth_method: "query",
       discovery: true,
       send_scope_to_token_endpoint: true,
       pkce: true,
       client_options: {
         identifier: "<YOUR APP CLIENT ID>",
         secret: "<YOUR APP CLIENT SECRET>",
         redirect_uri: "https://gitlab.example.com/users/auth/openid_connect/callback"
       }
     }
   }]
   ```

<a id="troubleshooting-azure-b2c"></a>

#### 故障排除 Azure B2C

- 确保所有出现的 `yourtenant.onmicrosoft.com`、`ProxyIdentityExperienceFrameworkAppId` 和 `IdentityExperienceFrameworkAppId` 与您的 B2C 租户主机名以及
  XML 策略文件中各自的客户端 ID 匹配。
- 将 `https://jwt.ms` 添加为应用的重定向 URI，并使用[自定义策略测试器](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#test-the-custom-policy)。
  确保负载包含与用户电子邮件访问权限匹配的 `email`。
- 启用自定义策略后，用户可能会在尝试登录后看到 `Invalid username or password`。
  这可能是 `IdentityExperienceFramework`
  应用的配置问题。请参阅[此 Microsoft 评论](https://learn.microsoft.com/en-us/answers/questions/50355/unable-to-sign-on-using-custom-policy?childtoview=122370#comment-122370)，其中建议您检查应用清单
  是否包含以下设置：

  - `"accessTokenAcceptedVersion": null`
  - `"signInAudience": "AzureADMyOrg"`

此配置与创建 `IdentityExperienceFramework` 应用时使用的 `Supported account types` 设置相对应。

<a id="configure-keycloak"></a>

### 配置 Keycloak

极狐GitLab 可与使用 HTTPS 的 OpenID 提供商配合使用。尽管您可以设置
使用 HTTP 的 Keycloak 服务器，但极狐GitLab 只能与
使用 HTTPS 的 Keycloak 服务器通信。

将 Keycloak 配置为使用公钥算法对令牌进行签名。
例如，使用 RSA256 或 RSA512 而不是 HS256 或 HS358。
公钥加密算法：

- 更易于配置。
- 更安全，因为泄露私钥会产生严重的安全后果。

1. 打开 Keycloak 管理控制台。
1. 选择 **领域设置** > **令牌** > **默认签名算法**。
1. 配置签名算法。

Linux 软件包安装的示例配置块：

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "openid_connect", # do not change this parameter
    label: "Keycloak", # optional label for login button, defaults to "Openid Connect"
    args: {
      name: "openid_connect",
      scope: ["openid", "profile", "email"],
      response_type: "code",
      issuer:  "https://keycloak.example.com/realms/myrealm",
      client_auth_method: "query",
      discovery: true,
      uid_field: "preferred_username",
      pkce: true,
      client_options: {
        identifier: "<YOUR CLIENT ID>",
        secret: "<YOUR CLIENT SECRET>",
        redirect_uri: "https://gitlab.example.com/users/auth/openid_connect/callback"
      }
    }
  }
]
```

<a id="configure-keycloak-with-a-symmetric-key-algorithm"></a>

#### 使用对称密钥算法配置 Keycloak

> [!warning]
> 以下说明仅为完整性而提供，但只有在绝对必要时才使用对称密钥
> 加密。

要使用对称密钥加密：

1. 从 Keycloak 数据库中提取密钥。Keycloak 不会在 Web 界面中公开此
   值。Web 界面中看到的客户端密钥是
   OAuth 2.0 客户端密钥，与用于签名 JSON Web 令牌的密钥不同。

   例如，如果您使用 PostgreSQL 作为 Keycloak 的后端数据库：

   - 登录数据库控制台。
   - 运行以下 SQL 查询以提取密钥：

     ```sql
     $ psql -U keycloak
     psql (13.3 (Debian 13.3-1.pgdg100+1))
     Type "help" for help.

     keycloak=# SELECT c.name, value FROM component_config CC INNER JOIN component C ON(CC.component_id = C.id) WHERE C.realm_id = 'master' and provider_id = 'hmac-generated' AND CC.name = 'secret';
     -[ RECORD 1 ]---------------------------------------------------------------------------------
     name  | hmac-generated
     value | lo6cqjD6Ika8pk7qc3fpFx9ysrhf7E62-sqGc8drp3XW-wr93zru8PFsQokHZZuJJbaUXvmiOftCZM3C4KW3-g
     -[ RECORD 2 ]---------------------------------------------------------------------------------
     name  | fallback-HS384
     value | UfVqmIs--U61UYsRH-NYBH3_mlluLONpg_zN7CXEwkJcO9xdRNlzZfmfDLPtf2xSTMvqu08R2VhLr-8G-oZ47A
     ```

     在此示例中，有两个私钥：一个用于 HS256（`hmac-generated`），
     另一个用于 HS384（`fallback-HS384`）。我们使用第一个 `value` 来配置极狐GitLab。

1. 将 `value` 转换为标准 base64。如[“HS256 令牌签名无效”帖子](https://keycloak.discourse.group/t/invalid-signature-with-hs256-token/3228/9)中所述，
   `value` 使用 RFC 4648 的[“使用 URL 和文件名安全字母表的 Base 64 编码”部分](https://datatracker.ietf.org/doc/html/rfc4648#section-5)进行编码。
   必须将其转换为 [RFC 2045 中定义的标准 base64](https://datatracker.ietf.org/doc/html/rfc2045)。
   以下 Ruby 脚本可完成此操作：

   ```ruby
   require 'base64'

   value = "lo6cqjD6Ika8pk7qc3fpFx9ysrhf7E62-sqGc8drp3XW-wr93zru8PFsQokHZZuJJbaUXvmiOftCZM3C4KW3-g"
   Base64.encode64(Base64.urlsafe_decode64(value))
   ```

   这将产生以下值：

   ```markdown
   lo6cqjD6Ika8pk7qc3fpFx9ysrhf7E62+sqGc8drp3XW+wr93zru8PFsQokH\nZZuJJbaUXvmiOftCZM3C4KW3+g==\n
   ```

1. 在 `jwt_secret_base64`中指定此 base64 编码的密钥。例如：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect", # do not change this parameter
       label: "Keycloak", # optional label for login button, defaults to "Openid Connect"
       args: {
         name: "openid_connect",
         scope: ["openid", "profile", "email"],
         response_type: "code",
         issuer:  "https://keycloak.example.com/auth/realms/myrealm",
         client_auth_method: "query",
         discovery: true,
         uid_field: "preferred_username",
         jwt_secret_base64: "<YOUR BASE64-ENCODED SECRET>",
         pkce: true,
         client_options: {
           identifier: "<YOUR CLIENT ID>",
           secret: "<YOUR CLIENT SECRET>",
           redirect_uri: "https://gitlab.example.com/users/auth/openid_connect/callback"
         }
       }
     }
   ]
   ```

如果您看到 `JSON::JWS::VerificationFailed` 错误，则说明您指定的密钥有误。

<a id="casdoor"></a>

### Casdoor

极狐GitLab 可与使用 HTTPS 的 OpenID 提供商配合使用。使用 HTTPS 通过 OpenID 与 Casdoor 连接到极狐GitLab。

对于您的应用，请在 Casdoor 上完成以下步骤：

1. 获取客户端 ID 和客户端密钥。
1. 添加您的极狐GitLab 重定向 URL。例如，如果您的极狐GitLab 域为 `gitlab.example.com`，
   请确保 Casdoor 应用具有以下
   `Redirect URI`：`https://gitlab.example.com/users/auth/openid_connect/callback`。

有关更多详情，请参阅 [Casdoor 文档](https://casdoor.ai/docs/integration/ruby/gitlab/)。

Linux 软件包安装的示例配置（文件路径：`/etc/gitlab/gitlab.rb`）：

```ruby
gitlab_rails['omniauth_providers'] = [
    {
        name: "openid_connect", # do not change this parameter
        label: "Casdoor", # optional label for login button, defaults to "Openid Connect"
        args: {
            name: "openid_connect",
            scope: ["openid", "profile", "email"],
            response_type: "code",
            issuer:  "https://<CASDOOR_HOSTNAME>",
            client_auth_method: "query",
            discovery: true,
            uid_field: "sub",
            client_options: {
                identifier: "<YOUR CLIENT ID>",
                secret: "<YOUR CLIENT SECRET>",
                redirect_uri: "https://gitlab.example.com/users/auth/openid_connect/callback"
            }
        }
    }
]
```

自编译安装的示例配置（文件路径：`config/gitlab.yml`）：

```yaml
  - { name: 'openid_connect', # do not change this parameter
      label: 'Casdoor', # optional label for login button, defaults to "Openid Connect"
      args: {
        name: 'openid_connect',
        scope: ['openid', 'profile', 'email'],
        response_type: 'code',
        issuer: 'https://<CASDOOR_HOSTNAME>',
        discovery: true,
        client_auth_method: 'query',
        uid_field: 'sub',
        client_options: {
          identifier: '<YOUR CLIENT ID>',
          secret: '<YOUR CLIENT SECRET>',
          redirect_uri: 'https://gitlab.example.com/users/auth/openid_connect/callback'
        }
      }
    }
```

<a id="configure-multiple-openid-connect-providers"></a>

## 配置多个 OpenID Connect 提供商

您可以将应用程序配置为使用多个 OpenID Connect (OIDC) 提供商。为此，请在配置文件中显式设置 `strategy_class`。

您应在以下任一情况下执行此操作：

- [迁移到 OpenID Connect 协议](#migrate-to-generic-openid-connect-configuration)。
- 提供不同级别的身份验证。

以下示例配置展示了如何提供不同级别的身份验证，一个选项使用 2FA，另一个不使用 2FA。

对于 Linux 软件包安装：

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "openid_connect",
    label: "Provider name", # optional label for login button, defaults to "Openid Connect"
    icon: "<custom_provider_icon>",
    args: {
      name: "openid_connect",
      strategy_class: "OmniAuth::Strategies::OpenIDConnect",
      scope: ["openid","profile","email"],
      response_type: "code",
      issuer: "<your_oidc_url>",
      discovery: true,
      client_auth_method: "query",
      uid_field: "<uid_field>",
      send_scope_to_token_endpoint: "false",
      pkce: true,
      client_options: {
        identifier: "<your_oidc_client_id>",
        secret: "<your_oidc_client_secret>",
        redirect_uri: "<your_gitlab_url>/users/auth/openid_connect/callback"
      }
    }
  },
  {
    name: "openid_connect_2fa",
    label: "Provider name 2FA", # optional label for login button, defaults to "Openid Connect"
    icon: "<custom_provider_icon>",
    args: {
      name: "openid_connect_2fa",
      strategy_class: "OmniAuth::Strategies::OpenIDConnect",
      scope: ["openid","profile","email"],
      response_type: "code",
      issuer: "<your_oidc_url>",
      discovery: true,
      client_auth_method: "query",
      uid_field: "<uid_field>",
      send_scope_to_token_endpoint: "false",
      pkce: true,
      client_options: {
        identifier: "<your_oidc_client_id>",
        secret: "<your_oidc_client_secret>",
        redirect_uri: "<your_gitlab_url>/users/auth/openid_connect_2fa/callback"
      }
    }
  }
]
```

对于自编译安装：

```yaml
  - { name: 'openid_connect',
      label: 'Provider name', # optional label for login button, defaults to "Openid Connect"
      icon: '<custom_provider_icon>',
      args: {
        name: 'openid_connect',
        strategy_class: "OmniAuth::Strategies::OpenIDConnect",
        scope: ['openid', 'profile', 'email'],
        response_type: 'code',
        issuer: '<your_oidc_url>',
        discovery: true,
        client_auth_method: 'query',
        uid_field: '<uid_field>',
        send_scope_to_token_endpoint: false,
        pkce: true,
        client_options: {
          identifier: '<your_oidc_client_id>',
          secret: '<your_oidc_client_secret>',
          redirect_uri: '<your_gitlab_url>/users/auth/openid_connect/callback'
        }
      }
    }
  - { name: 'openid_connect_2fa',
      label: 'Provider name 2FA', # optional label for login button, defaults to "Openid Connect"
      icon: '<custom_provider_icon>',
      args: {
        name: 'openid_connect_2fa',
        strategy_class: "OmniAuth::Strategies::OpenIDConnect",
        scope: ['openid', 'profile', 'email'],
        response_type: 'code',
        issuer: '<your_oidc_url>',
        discovery: true,
        client_auth_method: 'query',
        uid_field: '<uid_field>',
        send_scope_to_token_endpoint: false,
        pkce: true,
        client_options: {
          identifier: '<your_oidc_client_id>',
          secret: '<your_oidc_client_secret>',
          redirect_uri: '<your_gitlab_url>/users/auth/openid_connect_2fa/callback'
        }
      }
    }
```

在此用例中，您可能希望根据企业目录中已有的已知标识符，在不同提供商之间同步 `extern_uid`。

为此，您可以设置 `uid_field`。以下示例代码展示了如何执行此操作：

```python
def sync_missing_provider(self, user: User, extern_uid: str)
  existing_identities = []
  for identity in user.identities:
      existing_identities.append(identity.get("provider"))

  local_extern_uid = extern_uid.lower()
  for provider in ("openid_connect_2fa", "openid_connect"):
      identity = [
          identity
          for identity in user.identities
          if identity.get("provider") == provider
          and identity.get("extern_uid").lower() != local_extern_uid
      ]
      if provider not in existing_identities or identity:
          if identity and identity[0].get("extern_uid") != "":
              logger.error(f"Found different identity for provider {provider} for user {user.id}")
              continue
          else:
              logger.info(f"Add identity 'provider': {provider}, 'extern_uid': {extern_uid} for user {user.id}")
              user.provider = provider
              user.extern_uid = extern_uid
              user = self.save_user(user)
  return user
```

有关更多信息，请参阅[极狐GitLab API 用户方法文档](https://python-gitlab.readthedocs.io/en/stable/gl_objects/users.html#examples)。

<a id="configure-users-based-on-oidc-group-membership"></a>

## 根据 OIDC 群组成员资格配置用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以配置 OIDC 群组成员资格以：

- 要求用户是特定群组的成员。
- 根据群组成员资格为用户分配[外部](../external_users.md)、管理员或
  [审计员](../auditor_users.md)角色。

极狐GitLab 会在每次登录时检查这些群组，并根据需要更新用户属性。此功能不允许您自动将用户添加到极狐GitLab [群组](../../user/group/_index.md)。

为特定群组定义的值必须反映身份提供商返回的值。
例如，Microsoft Entra OIDC 返回 GroupID，因此 `required_groups` 配置将类似于 `required_groups: ["55db8574-c392-4e8b-892d-1e086394be9c"]`。

<a id="required-groups"></a>

### 必需的群组

您的身份提供商 (IdP) 必须在 OIDC 响应中将群组信息传递给极狐GitLab。要使用此响应来要求用户是特定群组的成员，请配置极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应中查找群组的位置。
- 使用 `required_groups` 设置登录所需的群组成员资格。

如果您未设置 `required_groups` 或将该设置留空，则任何通过 OIDC 由 IdP 身份验证的用户都可以使用极狐GitLab。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect",
       label: "Provider name",
       args: {
         name: "openid_connect",
         scope: ["openid","profile","email"],
         response_type: "code",
         issuer: "<your_oidc_url>",
         discovery: true,
         client_auth_method: "query",
         uid_field: "<uid_field>",
         client_options: {
           identifier: "<your_oidc_client_id>",
           secret: "<your_oidc_client_secret>",
           redirect_uri: "<your_gitlab_url>/users/auth/openid_connect/callback",
           gitlab: {
             groups_attribute: "groups",
             required_groups: ["Developer"]
           }
         }
       }
     }
   ]
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
        - { name: 'openid_connect',
            label: 'Provider name',
         args: {
           name: 'openid_connect',
           scope: ['openid','profile','email'],
           response_type: 'code',
           issuer: '<your_oidc_url>',
           discovery: true,
           client_auth_method: 'query',
           uid_field: '<uid_field>',
           client_options: {
             identifier: '<your_oidc_client_id>',
             secret: '<your_oidc_client_secret>',
             redirect_uri: '<your_gitlab_url>/users/auth/openid_connect/callback',
             gitlab: {
               groups_attribute: "groups",
               required_groups: ["Developer"]
             }
           }
         }
       }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="external-groups"></a>

### 外部群组

您的 IdP 必须在 OIDC 响应中将群组信息传递给极狐GitLab。要使用此响应根据群组成员资格将用户识别为[外部用户](../external_users.md)，请配置极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应中查找群组的位置。
- 使用 `external_groups` 设置确定哪些群组成员资格应将用户识别为[外部用户](../external_users.md)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect",
       label: "Provider name",
       args: {
         name: "openid_connect",
         scope: ["openid","profile","email"],
         response_type: "code",
         issuer: "<your_oidc_url>",
         discovery: true,
         client_auth_method: "query",
         uid_field: "<uid_field>",
         client_options: {
           identifier: "<your_oidc_client_id>",
           secret: "<your_oidc_client_secret>",
           redirect_uri: "<your_gitlab_url>/users/auth/openid_connect/callback",
           gitlab: {
             groups_attribute: "groups",
             external_groups: ["Freelancer"]
           }
         }
       }
     }
   ]
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
        - { name: 'openid_connect',
            label: 'Provider name',
         args: {
           name: 'openid_connect',
           scope: ['openid','profile','email'],
           response_type: 'code',
           issuer: '<your_oidc_url>',
           discovery: true,
           client_auth_method: 'query',
           uid_field: '<uid_field>',
           client_options: {
             identifier: '<your_oidc_client_id>',
             secret: '<your_oidc_client_secret>',
             redirect_uri: '<your_gitlab_url>/users/auth/openid_connect/callback',
             gitlab: {
               groups_attribute: "groups",
               external_groups: ["Freelancer"]
             }
           }
         }
       }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="auditor-groups"></a>

### 审计员群组

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您的 IdP 必须在 OIDC 响应中将群组信息传递给极狐GitLab。要使用此响应根据群组成员资格将用户分配为审计员，请配置极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应中查找群组的位置。
- 使用 `auditor_groups` 设置确定哪些群组成员资格授予用户审计员访问权限。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect",
       label: "Provider name",
       args: {
         name: "openid_connect",
         scope: ["openid","profile","email","groups"],
         response_type: "code",
         issuer: "<your_oidc_url>",
         discovery: true,
         client_auth_method: "query",
         uid_field: "<uid_field>",
         client_options: {
           identifier: "<your_oidc_client_id>",
           secret: "<your_oidc_client_secret>",
           redirect_uri: "<your_gitlab_url>/users/auth/openid_connect/callback",
           gitlab: {
             groups_attribute: "groups",
             auditor_groups: ["Auditor"]
           }
         }
       }
     }
   ]
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
        - { name: 'openid_connect',
            label: 'Provider name',
         args: {
           name: 'openid_connect',
           scope: ['openid','profile','email','groups'],
           response_type: 'code',
           issuer: '<your_oidc_url>',
           discovery: true,
           client_auth_method: 'query',
           uid_field: '<uid_field>',
           client_options: {
             identifier: '<your_oidc_client_id>',
             secret: '<your_oidc_client_secret>',
             redirect_uri: '<your_gitlab_url>/users/auth/openid_connect/callback',
             gitlab: {
               groups_attribute: "groups",
               auditor_groups: ["Auditor"]
             }
           }
         }
       }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="administrator-groups"></a>

### 管理员群组

您的 IdP 必须在 OIDC 响应中将群组信息传递给极狐GitLab。要使用此响应根据群组成员资格将用户分配为管理员，请配置极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应中查找群组的位置。
- 使用 `admin_groups` 设置确定哪些群组成员资格授予用户管理员访问权限。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect",
       label: "Provider name",
       args: {
         name: "openid_connect",
         scope: ["openid","profile","email"],
         response_type: "code",
         issuer: "<your_oidc_url>",
         discovery: true,
         client_auth_method: "query",
         uid_field: "<uid_field>",
         client_options: {
           identifier: "<your_oidc_client_id>",
           secret: "<your_oidc_client_secret>",
           redirect_uri: "<your_gitlab_url>/users/auth/openid_connect/callback",
           gitlab: {
             groups_attribute: "groups",
             admin_groups: ["Admin"]
           }
         }
       }
     }
   ]
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
        - { name: 'openid_connect',
            label: 'Provider name',
         args: {
           name: 'openid_connect',
           scope: ['openid','profile','email'],
           response_type: 'code',
           issuer: '<your_oidc_url>',
           discovery: true,
           client_auth_method: 'query',
           uid_field: '<uid_field>',
           client_options: {
             identifier: '<your_oidc_client_id>',
             secret: '<your_oidc_client_secret>',
             redirect_uri: '<your_gitlab_url>/users/auth/openid_connect/callback',
             gitlab: {
               groups_attribute: "groups",
               admin_groups: ["Admin"]
             }
           }
         }
       }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-a-custom-duration-for-id-tokens"></a>

### 为 ID 令牌配置自定义有效期

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

默认情况下，极狐GitLab ID 令牌在 120 秒后过期。

要为您的 ID 令牌配置自定义有效期：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['oidc_provider_openid_id_token_expire_in_seconds'] = 3600
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     oidc_provider:
      openid_id_token_expire_in_seconds: 3600
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="step-up-authentication"></a>

## 加强身份验证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

在某些情况下，默认身份验证方法无法保护关键资源或高风险操作。加强身份验证为特权操作或敏感操作增加了一层额外保护。例如，访问管理区域。

使用加强身份验证时，用户必须先通过已注册的[双重身份验证方法](../../user/profile/account/two_factor_authentication.md)完成额外的身份验证，然后才能访问某些功能。

OIDC 标准包含身份验证上下文类引用（`ACR`）。`ACR` 概念有助于为不同场景（例如管理员模式）配置和实现加强身份验证。

此功能为[实验](../../policy/development_stages_support.md)，可能会在不另行通知的情况下发生变化。此功能尚未准备好用于生产环境。如果您想使用此功能，应先在非生产环境中进行测试。

<a id="enable-step-up-authentication-for-admin-mode"></a>

### 为管理员模式启用加强身份验证

要为管理员模式启用加强身份验证：

1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），为特定的 OmniAuth 提供商启用
   加强身份验证。

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Provider name',
           args: {
             name: 'openid_connect',
             # ...
             allow_authorize_params: ["claims"], # Match this to the parameters defined in `step_up_auth => admin_mode => params`
           },
           step_up_auth: {
             admin_mode: {
               # The `id_token` field defines the claims that must be included with the token.
               # You can specify claims in one or both of the `required` or `included` fields.
               # The token must include matching values for every claim you define in these fields.
               id_token: {
                 # The `required` field defines key-value pairs that must be included with the ID token.
                 # The values must match exactly what is defined.
                 # In this example, the 'acr' (Authentication Context Class Reference) claim
                 # must have the value 'gold' to pass the step-up authentication challenge.
                 # This ensures a specific level of authentication assurance.
                 required: {
                   acr: 'gold'
                 },
                 # The `included` field also defines key-value pairs that must be included with the ID token.
                 # Multiple accepted values can be defined in an array. If an array is not used, the value must match exactly.
                 # In this example, the 'amr' (Authentication Method References) claim
                 # must have a value of either 'mfa' or 'fpt' to pass the step-up authentication challenge.
                 # This is useful for scenarios where the user must provide additional authentication factors.
                 included: {
                   amr: ['mfa', 'fpt']
                 },
               },
               # The `params` field defines any additional parameters that are sent during the authentication process.
               # In this example, the `claims` parameter is added to the authorization request and instructs the
               # identity provider to include an 'acr' claim with the value 'gold' in the ID token.
               # The 'essential: true' indicates that this claim is required for successful authentication.
               params: {
                 claims: {
                   id_token: {
                     acr: {
                       essential: true,
                       values: ['gold']
                     }
                   }
                 }
               },
               # Optional: Provide a custom documentation link for users who fail step-up authentication
               # This link is displayed when step-up authentication fails, directing users to
               # organization-specific authentication documentation.
               documentation_link: 'https://internal.example.com/path/to/documentation'
             },
           }
         }
   ```

1. 保存配置文件并重启极狐GitLab，使更改生效。

> [!note]
> 尽管 OIDC 是标准化的，但不同的身份提供商（IdP）可能有各自独特的要求。
> `params` 设置允许使用灵活的哈希来定义加强身份验证所需的参数。
> 这些值可能因每个 IdP 的要求而异。

<a id="require-step-up-authentication-with-keycloak"></a>

### 使用 Keycloak 要求加强身份验证

Keycloak 通过定义身份验证级别和自定义浏览器登录流程来支持加强身份验证。

要使用 Keycloak 为管理员模式要求加强身份验证：

1. 在极狐GitLab 中[配置 Keycloak](#configure-keycloak)。
1. 按照 Keycloak 文档中的步骤[在 Keycloak 中创建带加强身份验证的浏览器登录流程](https://www.keycloak.org/docs/latest/server_admin/#_step-up-flow)。
1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），在 Keycloak OIDC 提供商配置中启用
   加强身份验证。

   Keycloak 定义了两个不同的身份验证级别：`silver` 和 `gold`。以下示例
   使用 `gold` 来表示更高的安全级别。

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Keycloak',
           args: {
             name: 'openid_connect',
             # ...
             allow_authorize_params: ["claims"] # Match this to the parameters defined in `step_up_auth => admin_mode => params`
           },
           step_up_auth: {
             admin_mode: {
               id_token: {
                 # In this example, the 'acr' claim must have the value 'gold' that is also defined in the Keycloak documentation.
                 required: {
                   acr: 'gold'
                 }
               },
               params: {
                 claims: {
                   id_token: {
                     acr: { essential: true, values: ['gold'] }
                   }
                 },
               },
               # Optional: Add a custom documentation link for Keycloak-specific step-up authentication help
               documentation_link: 'https://internal.example.com/path/to/documentation'
             },
           }
         }
   ```

1. 保存配置文件并重启极狐GitLab，使更改生效。

<a id="require-step-up-authentication-with-microsoft-entra-id"></a>

### 使用 Microsoft Entra ID 要求加强身份验证

Microsoft Entra ID（以前称为 Azure Active Directory）通过
[条件访问身份验证上下文](https://learn.microsoft.com/en-us/entra/identity-platform/developer-guide-conditional-access-authentication-context)支持加强身份验证。
您应与 Microsoft Entra ID 管理员协作，定义正确的配置。

请考虑以下方面：

- 身份验证上下文 ID 仅通过 `acrs` 声明请求，而不通过其他
  身份提供商使用的 ID 令牌声明 `acr` 请求。
- 身份验证上下文 ID 使用从 `c1` 到 `c99`的固定值，每个值代表一个特定的
  带条件访问策略的身份验证上下文。
- 默认情况下，Microsoft Entra ID 不会在 ID 令牌中包含 `acrs` 声明。要启用此功能，您必须
  [配置可选声明](https://learn.microsoft.com/en-us/entra/identity-platform/optional-claims?tabs=appui#configure-optional-claims-in-your-application)。
- 当加强身份验证成功时，响应会以字符串 JSON 数组的形式返回
  [`acrs` 声明](https://learn.microsoft.com/en-us/entra/identity-platform/access-token-claims-reference#payload-claims)。例如：`acrs: ["c1", "c2", "c3"]`。

要使用 Microsoft Entra ID 为管理员模式要求加强身份验证：

1. 在极狐GitLab 中[配置 Microsoft Entra ID](#configure-microsoft-azure)。
1. 按照 Microsoft Entra ID 文档中的步骤
   [在 Microsoft Entra ID 中定义条件访问身份验证上下文](https://learn.microsoft.com/en-us/entra/identity-platform/developer-guide-conditional-access-authentication-context)。
1. 在 Microsoft Entra ID 中，定义[要包含在 ID 令牌中的可选声明 `acrs`](https://openid.net/specs/openid-connect-core-1_0.html#IDToken)。
1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），在 Microsoft Entra ID 提供商配置中启用
   加强身份验证：

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
         label: 'Azure OIDC',
         args: {
           name: 'openid_connect',
           # ...
           allow_authorize_params: ["claims"] # Match this to the parameters defined in `step_up_auth => admin_mode => params`
         },
         step_up_auth: {
           admin_mode: {
             id_token: {
               # In this example, the Microsoft Entra ID administrators have defined `c20`
               # as the authentication context ID with the desired security level and
               # an optional claim `acrs` to be included in the ID token.
               # The `included` field declares that the id token claim `acrs` must include the value `c20`.
               included: {
                 acrs: ["c20"],
               },
             },
             params: {
               claims: {
                 id_token: {
                   acrs: { essential: true, value: 'c20' }
                 }
               },
             },
             # Optional: Add a custom documentation link for Microsoft Entra ID step-up authentication
             documentation_link: 'https://internal.example.com/path/to/documentation'
           },
         }
       }
   ```

1. 保存配置文件并重启极狐GitLab，使更改生效。

<a id="add-a-step-up-authentication-provider-for-groups"></a>

### 为群组添加强身份验证提供商

您还可以添加强身份验证提供商，供实例中的所有群组使用。这不会强制群组使用加强身份验证，每个群组仍必须单独[设置](#force-step-up-authentication-for-a-group)此功能。

要为群组添加强身份验证提供商：

1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），为特定的 OmniAuth 提供商启用
   加强身份验证。

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Provider name',
           args: {
             name: 'openid_connect',
             # ...
             allow_authorize_params: ["claims"], # Match this to the parameters defined in `step_up_auth => admin_mode => params`
           },
           step_up_auth: {
             # Unlike step-up authentication configuration for Admin Mode, you use the `namespace`
             # object. This is because you're adding step-up authentication to access the entire
             # group, not just Admin Mode.
             namespace : {
               # The `id_token` field defines the claims that must be included with the token.
               # You can specify claims in one or both of the `required` or `included` fields.
               # The token must include matching values for every claim you define in these fields.
               id_token: {
                 # The `required` field defines key-value pairs that must be included with the ID token.
                 # The values must match exactly what is defined.
                 # In this example, the 'acr' (Authentication Context Class Reference) claim
                 # must have the value 'gold' to pass the step-up authentication challenge.
                 # This ensures a specific level of authentication assurance.
                 required: {
                   acr: 'gold'
                 },
                 # The `included` field also defines key-value pairs that must be included with the ID token.
                 # Multiple accepted values can be defined in an array. If an array is not used, the value must match exactly.
                 # In this example, the 'amr' (Authentication Method References) claim
                 # must have a value of either 'mfa' or 'fpt' to pass the step-up authentication challenge.
                 # This is useful for scenarios where the user must provide additional authentication factors.
                 included: {
                   amr: ['mfa', 'fpt']
                 },
               },
               # The `params` field defines any additional parameters that are sent during the authentication process.
               # In this example, the `claims` parameter is added to the authorization request and instructs the
               # identity provider to include an 'acr' claim with the value 'gold' in the ID token.
               # The 'essential: true' indicates that this claim is required for successful authentication.
               params: {
                 claims: {
                   id_token: {
                     acr: {
                       essential: true,
                       values: ['gold']
                     }
                   }
                 }
               }
             },
           }
         }
   ```

1. 保存配置文件并重启极狐GitLab，使更改生效。

<a id="force-step-up-authentication-for-a-group"></a>

### 为群组强制使用加强身份验证

您可以强制用户在访问群组之前完成加强身份验证。此设置按群组单独管理，但需要事先为整个实例添加强身份验证提供商。

先决条件：

- [实例中用于群组的加强身份验证提供商](#add-a-step-up-authentication-provider-for-groups)。
- 您必须具有所有者角色。

要为群组强制使用加强身份验证：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **常规**。
1. 展开**权限和群组功能**部分。
1. 在加强身份验证下，选择一个可用的身份验证提供商。
1. 选择**保存更改**。

<a id="add-custom-documentation-links-for-step-up-authentication"></a>

### 为加强身份验证添加自定义文档链接

当加强身份验证失败时，极狐GitLab 可以显示自定义文档链接，帮助用户了解您所在组织的身份验证要求。此功能允许管理员提供组织特定的指引，引导用户访问内部文档或帮助资源。

要添加自定义文档链接：

1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），向 `step_up_auth => admin_mode` 添加 `documentation_link` 字段

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Corporate SSO',
           # ... other provider configuration ...
           step_up_auth: {
             admin_mode: {
               # ... id_token and params configuration ...
               documentation_link: 'https://internal.example.com/path/to/documentation'
             }
           }
         }
   ```

1. 保存配置文件并重启极狐GitLab，使更改生效。

当用户未通过加强身份验证时，他们会看到一条有用的错误消息，其中包含指向失败提供商相关文档的链接。这些链接仅针对实际未通过加强身份验证的提供商显示，从而使指引更具相关性和可操作性。

> [!note]
> 文档链接的最佳实践：
>
> - 出于安全考虑，使用 HTTPS URL。
> - 链接到说明您所在组织特定身份验证要求的内部文档。
> - 包含有关如何启用 `MFA` 或其他必需身份验证方法的信息。

<a id="disable-session-expiration"></a>

### 禁用会话过期

默认情况下，加强身份验证会话根据身份提供商（IdP）令牌过期时间过期，通常约为 10 分钟。

您可以使用 `session_expiration_enabled` 设置控制会话过期：

| 设置                                      | 行为 |
| -------------------------------------------- | -------- |
| `session_expiration_enabled: true`（默认） | 加强身份验证根据 IdP 令牌 `exp` 声明过期。通常约为 10 分钟。 |
| `session_expiration_enabled: false`          | 加强身份验证在整个用户会话期间保持有效，直到用户退出登录。 |

> [!warning]
> 禁用会话过期意味着用户每个会话只需进行一次身份验证，
> 而不是定期重新验证其身份。仅当您的安全要求允许会话生命周期内的加强身份验证时，
> 才禁用此设置。

要禁用会话过期：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect",
       label: "Provider name",
       args: {
         name: "openid_connect",
         # ... other args ...
       },
       step_up_auth: {
         session_expiration_enabled: false,  # Disable session expiration
         admin_mode: {
           # ... admin_mode config ...
         },
         namespace: {
           # ... namespace config ...
         }
       }
     }
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'openid_connect',
             label: 'Provider name',
             args: {
               name: 'openid_connect',
               # ... other args ...
             },
             step_up_auth: {
               session_expiration_enabled: false,
               admin_mode: {
                 # ... admin_mode config ...
               },
               namespace: {
                 # ... namespace config ...
               }
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

1. 确保 `discovery` 设置为 `true`。如果将其设置为 `false`，则必须
   指定使 OpenID 正常工作所需的所有 URL 和密钥。
1. 检查您的系统时钟，确保时间已正确同步。
1. 如 [OmniAuth OpenID Connect 文档](https://github.com/omniauth/omniauth_openid_connect)中所述，
   确保 `issuer` 与 Discovery URL 的基础 URL 相对应。例如，
   URL `https://accounts.google.com/.well-known/openid-configuration`
   使用 `https://accounts.google.com`。
1. 如果未定义 `client_auth_method` 或将其设置为 `basic`，OpenID Connect 客户端会使用 HTTP 基本身份验证
   发送 OAuth 2.0 访问令牌。
   如果您在检索 `userinfo` 端点时看到 401 错误，请检查
   您的 OpenID Web 服务器配置。例如，对于
   [`oauth2-server-php`](https://github.com/bshaffer/oauth2-server-php)，您可能需要
   [向 Apache 添加配置参数](https://github.com/bshaffer/oauth2-server-php/issues/926#issuecomment-387502778)。
1. **仅限加强身份验证**：确保在
   `step_up_auth => admin_mode => params`中定义的任何参数也在 `args => allow_authorize_params`中定义。
   这包括用于重定向到 IdP 授权端点的请求查询参数中的
   参数。
