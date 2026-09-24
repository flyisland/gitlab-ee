---
stage: 软件供应链安全
group: 认证
info: 要了解指派给此页面所属阶段/群组的技术文档作者，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 OpenID Connect 作为认证提供者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以将极狐GitLab 作为客户端应用程序，使用 [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html) 作为 OmniAuth 提供者。

要启用 OpenID Connect OmniAuth 提供者，你必须向 OpenID Connect 提供者注册你的应用程序。OpenID Connect 提供者会向你提供客户端的详细信息和密钥以供使用。

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

1. 配置 [通用设置](../../integration/omniauth.md#configure-common-settings)，将 `openid_connect` 添加为单点登录提供者。这会为没有极狐GitLab 账户的用户启用即时账户供应。

1. 添加提供者配置。

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

   对于 Linux 软件包安装，若有多身份提供者：

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
   > 有关每个配置选项的更多信息，请参阅 [OmniAuth OpenID Connect 使用文档](https://github.com/omniauth/omniauth_openid_connect#usage) 和 [OpenID Connect Core 1.0 规范](https://openid.net/specs/openid-connect-core-1_0.html)。

1. 对于提供者配置，更改提供者的值以匹配你的 OpenID Connect 客户端设置。使用以下内容作为指南：

   - `<your_oidc_label>` 是显示在登录页面上的标签。
   - `<custom_provider_icon>`（可选）是显示在登录页面上的图标。极狐GitLab 内置了主要社交登录平台的图标，但你可以通过指定此参数来覆盖这些图标。极狐GitLab 接受本地路径和绝对 URL。
     极狐GitLab 内置了大多数主要社交登录平台的图标，但你可以通过指定外部 URL 或你自己的图标文件的绝对或相对路径来覆盖这些图标。
     - 对于本地绝对路径，将提供者设置配置为 `icon: <path>/<to>/<your-icon>`。
       - 将图标文件存储在 `/opt/gitlab/embedded/service/gitlab-rails/public/<path>/<to>/<your-icon>` 中。
       - 在 `https://gitlab.example/<path>/<to>/<your-icon>` 处访问图标文件。
     - 对于本地相对路径，将提供者设置配置为 `icon: <your-icon>`。
       - 将图标文件存储在 `/opt/gitlab/embedded/service/gitlab-rails/public/images/<your-icon>` 中。
       - 在 `https://gitlab.example.com/images/<your-icon>` 处访问图标文件。
   - `<your_oidc_url>`（可选）是指向 OpenID Connect 提供者的 URL（例如 `https://example.com/auth/realms/your-realm`）。如果未提供此值，则 URL 会从 `client_options` 按以下格式构建：`<client_options.scheme>://<client_options.host>:<client_options.port>`。
   - 如果 `discovery` 设置为 `true`，则 OpenID Connect 提供者会尝试使用 `<your_oidc_url>/.well-known/openid-configuration` 自动发现客户端选项。默认为 `false`。
   - `client_auth_method`（可选）指定用于向 OpenID Connect 提供者认证客户端的方法。
     - 支持的值为：
       - `basic` - HTTP 基本认证。
       - `jwt_bearer` - 基于 JWT 的认证（私钥和客户端密钥签名）。
       - `mtls` - 双向 TLS 或 X.509 证书验证。
       - 任何其它值都会将客户端 ID 和密钥作为请求正文发送。
     - 如果未指定，此值默认为 `basic`。
   - `<uid_field>`（可选）是 `user_info.raw_attributes` 中用于定义 `uid` 值的字段名（例如 `preferred_username`）。如果你未提供此值，或在 `user_info.raw_attributes` 详情中缺少使用该配置值的字段，则 `uid` 将使用 `sub` 字段。
   - `send_scope_to_token_endpoint` 默认为 `true`，因此 `scope` 参数通常包含在发送到令牌端点的请求中。然而，如果你的 OpenID Connect 提供者不在此类请求中接受 `scope` 参数，请将其设置为 `false`。
   - `pkce`（可选）：启用 [代码交换的证明密钥](https://www.rfc-editor.org/rfc/rfc7636)。
   - `client_options` 是 OpenID Connect 客户端特定的选项。具体如下：
     - `identifier` 是在 OpenID Connect 服务提供者中配置的客户端标识符。
     - `secret` 是在 OpenID Connect 服务提供者中配置的客户端密钥。例如，[OmniAuth OpenID Connect](https://github.com/omniauth/omniauth_openid_connect) 要求提供此项。如果服务提供者不需要密钥，可以提供任何值，它会被忽略。
     - `redirect_uri` 是登录成功后重定向用户的极狐GitLab URL（例如 `http://example.com/users/auth/openid_connect/callback`）。
     - 除非自动发现功能被禁用或不成功，否则以下 `client_options` 是可选的：
       - `authorization_endpoint` 是授权最终用户的端点 URL。
       - `token_endpoint` 是提供访问令牌的端点 URL。
       - `userinfo_endpoint` 是提供用户信息的端点 URL。
       - `jwks_uri` 是令牌签名者发布其密钥的端点 URL。

1. 保存配置文件。
1. 要使更改生效，如果你：

   - 使用了 Linux 软件包安装极狐GitLab，请 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 自编译了你的极狐GitLab 安装，请 [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

在登录页面，常规登录表单下方会出现一个 OpenID Connect 选项。选择此选项开始认证过程。如果需要客户端确认，OpenID Connect 提供者会要求你登录并授权极狐GitLab 应用程序。然后你将重定向到极狐GitLab 并登录。

## 配置示例

以下配置说明了在使用 Linux 软件包安装时如何针对不同提供者设置 OpenID。

### 配置 Google

请参阅 [Google 文档](https://developers.google.com/identity/openid-connect/openid-connect) 了解更多详情：

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

### 配置 Microsoft Azure

Microsoft Azure 的 OpenID Connect (OIDC) 协议使用 [Microsoft 身份平台 (v2) 端点](https://learn.microsoft.com/en-us/previous-versions/azure/active-directory/azuread-dev/azure-ad-endpoint-comparison)。首先，登录 [Azure 门户](https://portal.azure.com)。对于你的应用，你需要以下信息：

- 租户 ID。你可能已经有了。更多信息，请参阅 [Microsoft Azure 租户](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-create-new-tenant) 文档。
- 客户端 ID 和客户端密钥。按照 [Microsoft 快速入门注册应用程序](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app) 文档中的说明获取应用程序的租户 ID、客户端 ID 和客户端密钥。

注册 Microsoft Azure 应用程序时，必须授予 API 权限以允许极狐GitLab 检索所需的详细信息。你必须至少提供 `openid`、`profile` 和 `email` 权限。有关更多信息，请参阅 [Microsoft 关于配置 Web API 应用权限的文档](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-configure-app-access-web-apis#add-permissions-to-access-microsoft-graph)。

> [!note]
> 所有通过 Azure 供应的账户必须定义电子邮件地址。如果未定义电子邮件地址，Azure 会分配一个随机生成的地址。如果你已配置 [新用户的域限制](../settings/sign_up_restrictions.md#allow-or-deny-account-creation-by-using-specific-email-domains)，此随机地址可能会阻止账户创建。

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

Microsoft 已记录其平台如何与 [OIDC 协议](https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc) 配合使用。

#### Microsoft Entra 自定义签名密钥

如果你的应用使用了 [SAML 声明映射功能](https://learn.microsoft.com/en-us/entra/identity-platform/saml-claims-customization) 而具有自定义签名密钥，你必须按以下方式配置 OpenID 提供者：

- 通过省略 `args.discovery` 或将其设置为 `false` 来禁用 OpenID Connect 发现。
- 在 `client_options` 中，指定以下内容：
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

如果你看到带有 `KidNotFound` 消息的认证失败，很可能是由于缺少或不正确的 `appid` 查询参数。如果 Microsoft 返回的 ID 令牌无法通过 `jwks_uri` 端点提供的密钥进行验证，极狐GitLab 会抛出此错误。

有关更多信息，请参阅 [Microsoft Entra 关于验证令牌的文档](https://learn.microsoft.com/en-us/entra/identity-platform/access-tokens#validate-tokens)。

#### 迁移到通用 OpenID Connect 配置

你可以从 `azure_activedirectory_v2` 和 `azure_oauth2` 迁移到通用 OpenID Connect 配置。

首先，设置 `uid_field`。`uid_field` 以及你可选作 `uid_field` 的 `sub` 声明因提供者而异。在未设置 `uid_field` 的情况下登录会导致在极狐GitLab 中创建额外身份，这些身份必须手动修改：

| 提供者                                                                                                        | `uid_field` | 支持信息  |
|-----------------------------------------------------------------------------------------------------------------|-------|-----------------------------------------------------------------------|
| [`omniauth-azure-oauth2`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/vendor/gems/omniauth-azure-oauth2) | `sub` | 在 `info` 对象中提供附加属性 `oid` 和 `tid`。 |
| [`omniauth-azure-activedirectory-v2`](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/)         | `oid` | 迁移时必须将 `oid` 配置为 `uid_field`。 |
| [`omniauth_openid_connect`](https://github.com/omniauth/omniauth_openid_connect/)                               | `sub` | 指定 `uid_field` 以使用其他字段。 |

要迁移到通用 OpenID Connect 配置，你必须更新配置。

对于 Linux 软件包安装，请按如下方式更新配置：

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

在 YAML 文件中添加 [提供者的配置](https://docs.gitlab.com/charts/charts/globals/#providers)（例如 `provider.yaml`）：

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

当你迁移从 `azure_oauth2` 到 `omniauth_openid_connect` 作为升级到极狐GitLab 17.0 或更高版本的一部分时，为你的组织设置的 `sub` 声明值可能有所不同。`azure_oauth2` 使用 Microsoft V1 端点，而 `azure_activedirectory_v2` 和 `omniauth_openid_connect` 都使用 Microsoft V2 端点，具有共同的 `sub` 值。

- **对于在 Entra ID 中具有电子邮件地址的用户**，要允许回退到电子邮件地址并更新用户身份，
  请配置以下内容：
  - 在 Linux 软件包安装中，[`omniauth_auto_link_user`](../../integration/omniauth.md#link-existing-users-to-omniauth-users)。
  - 在 Helm 安装中，[`autoLinkUser`](https://docs.gitlab.com/charts/charts/globals/#omniauth)。
- **对于没有电子邮件地址的用户**，管理员必须采取以下操作之一：
  - 设置其他认证方法或启用极狐GitLab 用户名和密码登录。然后用户可以登录并通过其个人资料手动关联其 Azure 身份。
  - 在现有 `azure_oauth2` 的基础上实施 OpenID Connect 作为新提供者，以便用户可以通过 OAuth 2.0 登录，并关联其 OpenID Connect 身份（与上一种方法类似）。只要启用了 `auto_link_user`，此方法对具有电子邮件地址的用户也有效。
  - 手动更新 `extern_uid`。为此，请使用 [API 或 Rails 控制台](../../integration/omniauth.md#change-apps-or-configuration) 更新每个用户的 `extern_uid`。
    如果实例已经升级到 17.0 或更高版本，并且用户已尝试登录，则可能需要此方法。

> [!note]
> 如果在供应极狐GitLab 账户时 `email` 声明缺失或为空，`azure_oauth2` 可能使用了 Entra ID 的 `upn` 声明作为电子邮件地址。

### 配置 Microsoft Azure Active Directory B2C

极狐GitLab 需要特殊配置才能与 [Azure Active Directory B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/overview) 配合使用。首先，登录 [Azure 门户](https://portal.azure.com)。对于你的应用，你需要从 Azure 获取以下信息：

- 租户 ID。你可能已经有了。更多信息，请查看 [Microsoft Azure 租户](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-create-new-tenant) 文档。
- 客户端 ID 和客户端密钥。按照 [Microsoft 教程](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=app-reg-ga) 文档中的说明获取应用的客户端 ID 和客户端密钥。
- 用户流程或策略名称。按照 [Microsoft 教程](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-user-flow) 中的说明操作。

配置应用：

1. 设置应用的 `Redirect URI`。例如，如果你的极狐GitLab 域名为 `gitlab.example.com`，则将应用 `Redirect URI` 设置为 `https://gitlab.example.com/users/auth/openid_connect/callback`。
1. [启用 ID 令牌](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=app-reg-ga#enable-id-token-implicit-grant)。
1. 将以下 API 权限添加到应用：

   - `openid`
   - `offline_access`

#### 配置自定义策略

Azure B2C [提供两种定义用户登录业务逻辑的方式](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview)：

- [用户流程](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview#user-flows)
- [自定义策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview#custom-policies)

之所以需要自定义策略，是因为标准的 Azure B2C 用户流程不会发送极狐GitLab 创建或关联用户所需的 OpenID `email` 声明。因此，标准用户流程无法与 [`allow_single_sign_on` 或 `auto_link_user` 参数](../../integration/omniauth.md#configure-common-settings) 配合使用。使用标准 Azure B2C 策略，极狐GitLab 无法创建新账户或通过电子邮件地址关联到现有账户。

有关 Azure AD B2C 如何在用户流程和自定义策略中颁发令牌和声明的更多信息，请参阅 Microsoft 关于 [用户流程和自定义策略](https://learn.microsoft.com/azure/active-directory-b2c/user-flow-overview) 以及 [声明架构配置](https://learn.microsoft.com/azure/active-directory-b2c/claimsschema) 的文档。

首先，[创建自定义策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy)。
Microsoft 的说明中使用了 [自定义策略初学者包](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#custom-policy-starter-pack) 中的 `SocialAndLocalAccounts`，但 `LocalAccounts` 是针对本地 Active Directory 账户进行身份验证的。在 [上传策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#upload-the-policies) 之前，请执行以下操作：

1. 要导出 `email` 声明，请修改 `SignUpOrSignin.xml`。将以下行：

   ```xml
   <OutputClaim ClaimTypeReferenceId="email" />
   ```

   替换为：

   ```xml
   <OutputClaim ClaimTypeReferenceId="signInNames.emailAddress" PartnerClaimType="email" />
   ```

1. 要使 OIDC 发现与 B2C 协同工作，请配置一个与 [OIDC 规范](https://openid.net/specs/openid-connect-discovery-1_0.html#rfc.section.4.3) 兼容的签发者。
   请参阅 [令牌兼容性设置](https://learn.microsoft.com/en-us/azure/active-directory-b2c/configure-tokens?pivots=b2c-custom-policy#token-compatibility-settings)。
   在 `TrustFrameworkBase.xml` 中的 `JwtIssuer` 下，将 `IssuanceClaimPattern` 设置为 `AuthorityWithTfp`：

   ```xml
   <ClaimsProvider>
     <DisplayName>Token 签发者</DisplayName>
     <TechnicalProfiles>
       <TechnicalProfile Id="JwtIssuer">
         <DisplayName>JWT 签发者</DisplayName>
         <Protocol Name="None" />
         <OutputTokenFormat>JWT</OutputTokenFormat>
         <Metadata>
           <Item Key="IssuanceClaimPattern">AuthorityWithTfp</Item>
           ...
   ```

1. [上传策略](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#upload-the-policies)。如果要更新现有策略，请覆盖现有文件。

1. 要确定签发者 URL，请使用登录策略。签发者 URL 的格式如下：

   ```markdown
   https://<YOUR-DOMAIN>/tfp/<YOUR-TENANT-ID>/<YOUR-SIGN-IN-POLICY-NAME>/v2.0/
   ```

   URL 中的策略名称是小写的。例如，`B2C_1A_signup_signin` 策略显示为 `b2c_1a_signup_sigin`。

   请确保包含末尾的斜杠。

1. 验证 OIDC 发现 URL 和签发者 URL 的操作，并将 `.well-known/openid-configuration` 附加到签发者 URL 后面：

   ```markdown
   https://<YOUR-DOMAIN>/tfp/<YOUR-TENANT-ID>/<YOUR-SIGN-IN-POLICY-NAME>/v2.0/.well-known/openid-configuration
   ```

   例如，如果 `domain` 是 `example.b2clogin.com`，租户 ID 是 `fc40c736-476c-4da1-b489-ee48cee84386`，你可以使用 `curl` 和 `jq` 来提取签发者：

   ```shell
   $ curl --silent "https://example.b2clogin.com/tfp/fc40c736-476c-4da1-b489-ee48cee84386/b2c_1a_signup_signin/v2.0/.well-known/openid-configuration" | jq .issuer
   "https://example.b2clogin.com/tfp/fc40c736-476c-4da1-b489-ee48cee84386/b2c_1a_signup_signin/v2.0/"
   ```

1. 使用用于 `signup_signin` 的自定义策略配置签发者 URL。例如，这是针对 Linux 软件包安装的 `b2c_1a_signup_signin` 自定义策略的配置：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
   {
     name: "openid_connect", # 不要更改此参数
     label: "Azure B2C OIDC", # 登录按钮的可选标签，默认为 "Openid Connect"
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

#### 排查 Azure B2C 问题

- 确保 XML 策略文件中所有出现的 `yourtenant.onmicrosoft.com`、`ProxyIdentityExperienceFrameworkAppId` 和 `IdentityExperienceFrameworkAppId` 都与你的 B2C 租户主机名和各自的客户端 ID 匹配。
- 将 `https://jwt.ms` 作为重定向 URI 添加到应用，并使用 [自定义策略测试器](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows?pivots=b2c-custom-policy#test-the-custom-policy)。确保有效负载包含与用户电子邮件访问权限匹配的 `email`。
- 启用自定义策略后，用户在尝试登录后可能会看到 `Invalid username or password`。这可能是 `IdentityExperienceFramework` 应用的配置问题。请参阅 [此 Microsoft 评论](https://learn.microsoft.com/en-us/answers/questions/50355/unable-to-sign-on-using-custom-policy?childtoview=122370#comment-122370)，其中建议检查应用清单是否包含以下设置：

  - `"accessTokenAcceptedVersion": null`
  - `"signInAudience": "AzureADMyOrg"`

此配置与创建 `IdentityExperienceFramework` 应用时使用的 `Supported account types` 设置相对应。

<a id="configure-keycloak"></a>

### 配置 Keycloak

极狐GitLab 可以处理使用 HTTPS 的 OpenID 提供程序。虽然你可以设置一个使用 HTTP 的 Keycloak 服务器，但极狐GitLab 只能与使用 HTTPS 的 Keycloak 服务器通信。

配置 Keycloak 使用公钥算法对令牌进行签名。例如，使用 RSA256 或 RSA512，而不是 HS256 或 HS358。公钥加密算法：

- 更易于配置。
- 更安全，因为泄露私钥会带来严重的安全后果。

1. 打开 Keycloak 管理控制台。
1. 选择 **领域设置** > **令牌** > **默认签名算法**。
1. 配置签名算法。

Linux 软件包安装的示例配置：

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "openid_connect", # 不要更改此参数
    label: "Keycloak", # 登录按钮的可选标签，默认为 "Openid Connect"
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
> 以下说明是为了完整性而包含的，但仅在绝对必要时才使用对称密钥加密。

要使用对称密钥加密：

1. 从 Keycloak 数据库中提取密钥。Keycloak 不会在 Web 界面中公开此值。Web 界面中看到的客户端密钥是 OAuth 2.0 客户端密钥，与用于签名 JSON Web 令牌的密钥不同。

   例如，如果你使用 PostgreSQL 作为 Keycloak 的后端数据库：

   - 登录数据库控制台。
   - 运行以下 SQL 查询以提取密钥：

     ```sql
     $ psql -U keycloak
     psql (13.3 (Debian 13.3-1.pgdg100+1))
     输入 "help" 来获取帮助。

     keycloak=# SELECT c.name, value FROM component_config CC INNER JOIN component C ON(CC.component_id = C.id) WHERE C.realm_id = 'master' and provider_id = 'hmac-generated' AND CC.name = 'secret';
     -[ RECORD 1 ]---------------------------------------------------------------------------------
     name  | hmac-generated
     value | lo6cqjD6Ika8pk7qc3fpFx9ysrhf7E62-sqGc8drp3XW-wr93zru8PFsQokHZZuJJbaUXvmiOftCZM3C4KW3-g
     -[ RECORD 2 ]---------------------------------------------------------------------------------
     name  | fallback-HS384
     value | UfVqmIs--U61UYsRH-NYBH3_mlluLONpg_zN7CXEwkJcO9xdRNlzZfmfDLPtf2xSTMvqu08R2VhLr-8G-oZ47A
     ```

     在此示例中，有两个私钥：一个用于 HS256（`hmac-generated`），另一个用于 HS384（`fallback-HS384`）。我们使用第一个 `value` 来配置 极狐GitLab。

1. 将 `value` 转换为标准的 base64。如 [“Invalid signature with HS256 token”帖子](https://keycloak.discourse.group/t/invalid-signature-with-hs256-token/3228/9) 中所讨论的，`value` 是按照 [RFC 4648 第 5 节的“Base 64 Encoding with URL and Filename Safe Alphabet”](https://datatracker.ietf.org/doc/html/rfc4648#section-5) 进行编码的。必须将其转换为 [RFC 2045 中定义的标准 base64](https://datatracker.ietf.org/doc/html/rfc2045)。以下 Ruby 脚本可以完成此操作：

   ```ruby
   require 'base64'

   value = "lo6cqjD6Ika8pk7qc3fpFx9ysrhf7E62-sqGc8drp3XW-wr93zru8PFsQokHZZuJJbaUXvmiOftCZM3C4KW3-g"
   Base64.encode64(Base64.urlsafe_decode64(value))
   ```

   这将生成以下值：

   ```markdown
   lo6cqjD6Ika8pk7qc3fpFx9ysrhf7E62+sqGc8drp3XW+wr93zru8PFsQokH\nZZuJJbaUXvmiOftCZM3C4KW3+g==\n
   ```

1. 在 `jwt_secret_base64` 中指定此 base64 编码的密钥。例如：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect", # 不要更改此参数
       label: "Keycloak", # 登录按钮的可选标签，默认为 "Openid Connect"
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

如果看到 `JSON::JWS::VerificationFailed` 错误，则说明你指定的密钥有误。

<a id="casdoor"></a>

### Casdoor

极狐GitLab 可以处理使用 HTTPS 的 OpenID 提供程序。使用 HTTPS 通过 OpenID 与 Casdoor 连接到 极狐GitLab。

对于你的应用，请在 Casdoor 上完成以下步骤：

1. 获取客户端 ID 和客户端密钥。
1. 添加你的 极狐GitLab 重定向 URL。例如，如果你的 极狐GitLab 域名为 `gitlab.example.com`，请确保 Casdoor 应用具有以下 `Redirect URI`：`https://gitlab.example.com/users/auth/openid_connect/callback`。

有关更多详细信息，请参阅 [Casdoor 文档](https://casdoor.org/docs/integration/ruby/gitlab/)。

Linux 软件包安装的示例配置（文件路径：`/etc/gitlab/gitlab.rb`）：

```ruby
gitlab_rails['omniauth_providers'] = [
    {
        name: "openid_connect", # 不要更改此参数
        label: "Casdoor", # 登录按钮的可选标签，默认为 "Openid Connect"
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

自行编译安装的示例配置（文件路径：`config/gitlab.yml`）：

```yaml
  - { name: 'openid_connect', # 不要更改此参数
      label: 'Casdoor', # 登录按钮的可选标签，默认为 "Openid Connect"
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

## 配置多个 OpenID Connect 提供程序

你可以配置你的应用程序使用多个 OpenID Connect (OIDC) 提供程序。通过在配置文件中显式设置 `strategy_class` 来实现。

你应该在以下任何一种场景中执行此操作：

- [迁移到 OpenID Connect 协议](#migrate-to-generic-openid-connect-configuration)。
- 提供不同级别的身份验证。

以下示例配置展示了如何提供不同级别的身份验证，一种带有 2FA，另一种不带。

对于 Linux 软件包安装：

```ruby
gitlab_rails['omniauth_providers'] = [
  {
    name: "openid_connect",
    label: "Provider name", # 登录按钮的可选标签，默认为 "Openid Connect"
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
    label: "Provider name 2FA", # 登录按钮的可选标签，默认为 "Openid Connect"
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

对于自行编译安装：

```yaml
  - { name: 'openid_connect',
      label: 'Provider name', # 登录按钮的可选标签，默认为 "Openid Connect"
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
      label: 'Provider name 2FA', # 登录按钮的可选标签，默认为 "Openid Connect"
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

在此用例中，你可能希望根据公司目录中现有的已知标识符，在不同提供程序之间同步 `extern_uid`。

为此，你需要设置 `uid_field`。以下示例代码显示了如何执行此操作：

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

更多信息，请参阅 [极狐GitLab API 用户方法文档](https://python-gitlab.readthedocs.io/en/stable/gl_objects/users.html#examples)。

<a id="configure-users-based-on-oidc-group-membership"></a>

## 根据 OIDC 群组成员身份配置用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以配置 OIDC 群组成员身份以实现：

- 要求用户是特定群组的成员。
- 根据群组成员身份，为用户分配 [外部](../external_users.md)、管理员或 [审计员](../auditor_users.md) 角色。

极狐GitLab 在每次登录时检查这些群组，并根据需要更新用户属性。此功能不允许你自动将用户添加到 极狐GitLab [群组](../../user/group/_index.md) 中。

为特定群组定义的值必须反映身份提供程序返回的值。例如，Microsoft Entra OIDC 返回的是 GroupID，因此 `required_groups` 配置将类似于 `required_groups: ["55db8574-c392-4e8b-892d-1e086394be9c"]`。

<a id="required-groups"></a>

### 所需群组

你的 IdP 必须在 OIDC 响应中将群组信息传递给 极狐GitLab。要使用此响应要求用户是特定群组的成员，请配置 极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应的何处查找群组。
- 使用 `required_groups` 设置要求登录的群组成员身份。

如果你不设置 `required_groups` 或将其留空，则任何由 IdP 通过 OIDC 认证的用户都可以使用 极狐GitLab。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

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

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

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

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="external-groups"></a>

### 外部群组

你的 IdP 必须在 OIDC 响应中将群组信息传递给 极狐GitLab。要使用此响应根据群组成员身份将用户标识为 [外部用户](../external_users.md)，请配置 极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应的何处查找群组。
- 使用 `external_groups` 设置哪些群组成员身份应将用户标识为 [外部用户](../external_users.md)。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

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

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

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

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="auditor-groups"></a>

### 审计员群组

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你的 IdP 必须在 OIDC 响应中将群组信息传递给 极狐GitLab。要使用此响应基于群组成员身份将用户分配为审计员，请配置 极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应的何处查找群组。
- 使用 `auditor_groups` 设置哪些群组成员身份授予用户审计员访问权限。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

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

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

{{< /tab >}}

{{< /tabs >}}
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

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations) 使更改生效。

{{< /tab >}}

{{< /tabs >}}

### 管理员群组

您的 IdP 必须在 OIDC 响应中将群组信息传递给极狐GitLab。要使用此响应根据群组成员资格将用户分配为管理员，请配置极狐GitLab 以识别：

- 使用 `groups_attribute` 设置在 OIDC 响应中查找群组的位置。
- 使用 `admin_groups` 设置确定哪些群组成员资格会授予用户管理员访问权限。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

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

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 使更改生效。

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

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

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations) 使更改生效。

{{< /tab >}}

{{< /tabs >}}

### 配置 ID 令牌的自定义持续时间

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.8 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/377654)。

{{< /history >}}

默认情况下，极狐GitLab ID 令牌在 120 秒后过期。

要为您的 ID 令牌配置自定义持续时间：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['oidc_provider_openid_id_token_expire_in_seconds'] = 3600
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 使更改生效。

{{< /tab >}}

{{< tab title="自行编译 (源码)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     oidc_provider:
      openid_id_token_expire_in_seconds: 3600
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#self-compiled-installations) 使更改生效。

{{< /tab >}}

{{< /tabs >}}

## 逐步认证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- 状态：实验性

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请查看历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

在某些情况下，默认的身份验证方法无法保护关键资源或高风险操作。
逐步认证为特权操作或敏感操作增加了一层额外的保护。
例如，访问 **管理员** 区域。

通过逐步认证，用户必须使用已注册的[双因素认证方法](../../user/profile/account/two_factor_authentication.md)完成额外的认证，然后才能访问某些功能。

OIDC 标准包含身份验证上下文类引用 (`ACR`)。`ACR` 概念有助于为不同场景（例如管理员模式）配置和实现逐步认证。

此功能是一个[实验](../../policy/development_stages_support.md)，可能随时更改，恕不另行通知。此功能尚未准备好用于生产环境。如果您想使用此功能，应首先在生产环境之外进行测试。

### 为管理员模式启用逐步认证

{{< history >}}

- 在极狐GitLab 17.11 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/474650)，[带有功能标志](../feature_flags/_index.md) `omniauth_step_up_auth_for_admin_mode`。默认禁用。

{{< /history >}}
要为管理员模式启用逐步认证：

1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），为特定的 OmniAuth 提供者启用逐步认证。

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Provider name',
           args: {
             name: 'openid_connect',
             # ...
             allow_authorize_params: ["claims"], # 与 `step_up_auth => admin_mode => params` 中定义的参数匹配
           },
           step_up_auth: {
             admin_mode: {
               # `id_token` 字段定义了令牌必须包含的声明。
               # 您可以在 `required` 或 `included` 字段中指定声明，或两者都指定。
               # 令牌必须包含您在所有这些字段中定义的每个声明的匹配值。
               id_token: {
                 # `required` 字段定义了 ID 令牌中必须包含的键值对。
                 # 这些值必须与定义的值完全匹配。
                 # 在此示例中，'acr'（身份验证上下文类引用）声明
                 # 必须具有值 'gold' 才能通过逐步认证挑战。
                 # 这确保了特定的身份验证保证级别。
                 required: {
                   acr: 'gold'
                 },
                 # `included` 字段也定义了 ID 令牌中必须包含的键值对。
                 # 可以在一个数组中定义多个可接受的值。如果未使用数组，则该值必须完全匹配。
                 # 在此示例中，'amr'（身份验证方法引用）声明
                 # 必须具有 'mfa' 或 'fpt' 的值才能通过逐步认证挑战。
                 # 这对于用户必须提供额外认证因素的场景非常有用。
                 included: {
                   amr: ['mfa', 'fpt']
                 },
               },
               # `params` 字段定义了在认证过程中发送的任何附加参数。
               # 在此示例中，`claims` 参数被添加到授权请求中，并指示
               # 身份提供者在 ID 令牌中包含一个值为 'gold' 的 'acr' 声明。
               # 'essential: true' 表示此声明是成功认证所必需的。
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
               # 可选：为逐步认证失败的用户提供自定义文档链接
               # 当逐步认证失败时会显示此链接，引导用户访问
               # 组织特定的认证文档。
               documentation_link: 'https://internal.example.com/path/to/documentation'
             },
           }
         }
   ```

1. 保存配置文件并重启极狐GitLab 使更改生效。

> [!note]
> 尽管 OIDC 是标准化的，但不同的身份提供者 (IdP) 可能有独特的要求。
> `params` 设置允许使用灵活的哈希来定义逐步认证所需的参数。
> 这些值可能因每个 IdP 的要求而异。

### 使用 Keycloak 要求逐步认证

Keycloak 通过定义认证级别和自定义浏览器登录流程来支持逐步认证。

要使用 Keycloak 为管理员模式要求逐步认证：

1. 在极狐GitLab 中[配置 Keycloak](#configure-keycloak)。
1. 按照 Keycloak 文档中的步骤[在 Keycloak 中创建带逐步认证的浏览器登录流程](https://www.keycloak.org/docs/latest/server_admin/#_step-up-flow)。
1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），在 Keycloak OIDC 提供者配置中启用逐步认证。

   Keycloak 定义了两种不同的认证级别：`silver` 和 `gold`。以下示例使用 `gold` 表示增强的安全级别。

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Keycloak',
           args: {
             name: 'openid_connect',
             # ...
             allow_authorize_params: ["claims"] # 与 `step_up_auth => admin_mode => params` 中定义的参数匹配
           },
           step_up_auth: {
             admin_mode: {
               id_token: {
                 # 在此示例中，'acr' 声明必须具有 'gold' 值，该值也在 Keycloak 文档中定义。
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
               # 可选：为 Keycloak 特定的逐步认证帮助添加自定义文档链接
               documentation_link: 'https://internal.example.com/path/to/documentation'
             },
           }
         }
   ```

1. 保存配置文件并重启极狐GitLab 使更改生效。

### 使用 Microsoft Entra ID 要求逐步认证

Microsoft Entra ID（原名 Azure Active Directory）通过[条件访问认证上下文](https://learn.microsoft.com/en-us/entra/identity-platform/developer-guide-conditional-access-authentication-context)支持逐步认证。
您应该与您的 Microsoft Entra ID 管理员合作，以确定正确的配置。

请考虑以下几个方面：

- 认证上下文 ID 仅通过 `acrs` 声明请求，而不是通过其他身份提供者使用的 ID 令牌声明 `acr`。
- 认证上下文 ID 使用从 `c1` 到 `c99` 的固定值，每个值代表一个具有条件访问策略的特定认证上下文。
- 默认情况下，Microsoft Entra ID 不会在 ID 令牌中包含 `acrs` 声明。要启用此功能，您必须[配置可选声明](https://learn.microsoft.com/en-us/entra/identity-platform/optional-claims?tabs=appui#configure-optional-claims-in-your-application)。
- 当逐步认证成功时，响应会以 JSON 字符串数组形式返回 `acrs` 声明。例如：`acrs: ["c1", "c2", "c3"]`。

要使用 Microsoft Entra ID 为管理员模式要求逐步认证：

1. 在极狐GitLab 中[配置 Microsoft Entra ID](#configure-microsoft-azure)。
1. 按照 Microsoft Entra ID 文档中的步骤[在 Microsoft Entra ID 中定义条件访问认证上下文](https://learn.microsoft.com/en-us/entra/identity-platform/developer-guide-conditional-access-authentication-context)。
1. 在 Microsoft Entra ID 中，定义[要包含在 ID 令牌中的可选声明 `acrs`](https://openid.net/specs/openid-connect-core-1_0.html#IDToken)。
1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），在 Microsoft Entra ID 提供者配置中启用逐步认证：

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
         label: 'Azure OIDC',
         args: {
           name: 'openid_connect',
           # ...
           allow_authorize_params: ["claims"] # 与 `step_up_auth => admin_mode => params` 中定义的参数匹配
         },
         step_up_auth: {
           admin_mode: {
             id_token: {
               # 在此示例中，Microsoft Entra ID 管理员已将 `c20`
               # 定义为具有所需安全级别的认证上下文 ID，
               # 并将可选声明 `acrs` 配置为包含在 ID 令牌中。
               # `included` 字段声明 ID 令牌声明 `acrs` 必须包含值 `c20`。
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
             # 可选：为 Microsoft Entra ID 逐步认证添加自定义文档链接
             documentation_link: 'https://internal.example.com/path/to/documentation'
           },
         }
       }
   ```

1. 保存配置文件并重启极狐GitLab 使更改生效。

### 为群组添加逐步认证提供者

{{< history >}}

- 在极狐GitLab 18.4 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/556943)，[带有功能标志](../feature_flags/_index.md) `omniauth_step_up_auth_for_namespace`。默认禁用。

{{< /history >}}

您还可以为您实例中的所有群组添加可用的逐步认证提供者。这不会强制群组使用逐步认证，每个群组仍需单独[设置](#force-step-up-authentication-for-a-group)此功能。

要为群组添加逐步认证提供者：

1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），为特定的 OmniAuth 提供者启用逐步认证。

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Provider name',
           args: {
             name: 'openid_connect',
             # ...
             allow_authorize_params: ["claims"], # 与 `step_up_auth => admin_mode => params` 中定义的参数匹配
           },
           step_up_auth: {
             # 与管理员模式的逐步认证配置不同，这里使用 `namespace`
             # 对象。这是因为您是为访问整个群组
             # 而不仅仅是管理员模式添加逐步认证。
             namespace : {
               # `id_token` 字段定义了令牌必须包含的声明。
               # 您可以在 `required` 或 `included` 字段中指定声明，或两者都指定。
               # 令牌必须包含您在所有这些字段中定义的每个声明的匹配值。
               id_token: {
                 # `required` 字段定义了 ID 令牌中必须包含的键值对。
                 # 这些值必须与定义的值完全匹配。
                 # 在此示例中，'acr'（身份验证上下文类引用）声明
                 # 必须具有值 'gold' 才能通过逐步认证挑战。
                 # 这确保了特定的身份验证保证级别。
                 required: {
                   acr: 'gold'
                 },
                 # `included` 字段也定义了 ID 令牌中必须包含的键值对。
                 # 可以在一个数组中定义多个可接受的值。如果未使用数组，则该值必须完全匹配。
                 # 在此示例中，'amr'（身份验证方法引用）声明
                 # 必须具有 'mfa' 或 'fpt' 的值才能通过逐步认证挑战。
                 # 这对于用户必须提供额外认证因素的场景非常有用。
                 included: {
                   amr: ['mfa', 'fpt']
                 },
               },
               # `params` 字段定义了在认证过程中发送的任何附加参数。
               # 在此示例中，`claims` 参数被添加到授权请求中，并指示
               # 身份提供者在 ID 令牌中包含一个值为 'gold' 的 'acr' 声明。
               # 'essential: true' 表示此声明是成功认证所必需的。
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

1. 保存配置文件并重启极狐GitLab 使更改生效。

### 为群组强制启用逐步认证

您可以强制用户在访问群组之前完成逐步认证。此设置针对每个群组单独管理，但需要之前为整个实例添加了逐步认证提供者。

先决条件：

- [为您实例中的群组添加了逐步认证提供者](#add-a-step-up-authentication-provider-for-groups)。
- 您必须具有所有者角色。

要为群组强制启用逐步认证：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 在“逐步认证”下，选择一个可用的认证提供者。
1. 选择 **保存更改**。

### 为逐步认证添加自定义文档链接

当逐步认证失败时，极狐GitLab 可以显示自定义文档链接，以帮助用户了解您组织的认证要求。此功能允许管理员提供组织特定的指导，将用户引导至内部文档或帮助资源。

要添加自定义文档链接：

1. 编辑您的极狐GitLab 配置文件（`gitlab.yml` 或 `/etc/gitlab/gitlab.rb`），向 `step_up_auth => admin_mode` 添加 `documentation_link` 字段

   ```yaml
   production: &base
     omniauth:
       providers:
       - { name: 'openid_connect',
           label: 'Corporate SSO',
           # ... 其他提供者配置 ...
           step_up_auth: {
             admin_mode: {
               # ... id_token 和 params 配置 ...
               documentation_link: 'https://internal.example.com/path/to/documentation'
             }
           }
         }
   ```

1. 保存配置文件并重启极狐GitLab 使更改生效。

当用户逐步认证失败时，他们会看到一条有用的错误消息，其中包含指向认证失败提供者的相关文档链接。这些链接仅针对实际逐步认证失败的提供者显示，使指导更具相关性和可操作性。

> [!note]
> 文档链接的最佳实践：
>
> - 为安全起见，请使用 HTTPS 的 URL。
> - 链接到解释您组织特定认证要求的内部文档。
> - 包括如何启用 `MFA` 或其他所需认证方法的信息。

### 禁用会话过期

默认情况下，逐步认证会话根据身份提供者 (IdP) 令牌过期时间过期，通常约为 10 分钟。

您可以使用 `session_expiration_enabled` 设置控制会话过期：

| 设置                                          | 行为 |
| -------------------------------------------- | -------- |
| `session_expiration_enabled: true` (默认)     | 逐步认证根据 IdP 令牌 `exp` 声明过期。这通常约为 10 分钟。 |
| `session_expiration_enabled: false`          | 逐步认证在整个用户会话期间保持有效，直到用户登出。 |

> [!warning]
> 禁用会话过期意味着用户在每次会话中只认证一次，
> 而不是定期重新验证其身份。仅当您的安全要求允许
> 会话生命周期的逐步认证时，才禁用此设置。

要禁用会话过期：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "openid_connect",
       label: "Provider name",
       args: {
         name: "openid_connect",
         # ... 其他参数 ...
       },
       step_up_auth: {
         session_expiration_enabled: false,  # 禁用会话过期
         admin_mode: {
           # ... admin_mode 配置 ...
         },
         namespace: {
           # ... namespace 配置 ...
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

{{< tab title="自行编译 (源码)" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   production: &base
     omniauth:
       providers:
         - { name: 'openid_connect',
             label: 'Provider name',
             args: {
               name: 'openid_connect',
               # ... 其他参数 ...
             },
             step_up_auth: {
               session_expiration_enabled: false,
               admin_mode: {
                 # ... admin_mode 配置 ...
               },
               namespace: {
                 # ... namespace 配置 ...
               }
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

## 故障排查

1. 确保 `discovery` 设置为 `true`。如果将其设置为 `false`，则必须指定 OpenID 工作所需的所有 URL 和密钥。
1. 检查您的系统时钟以确保时间已正确同步。
1. 正如 [OmniAuth OpenID Connect 文档](https://github.com/omniauth/omniauth_openid_connect)中所述，确保 `issuer` 对应于发现 URL 的基本 URL。例如，`https://accounts.google.com` 用于 URL `https://accounts.google.com/.well-known/openid-configuration`。
1. 如果 `client_auth_method` 未定义或设置为 `basic`，OpenID Connect 客户端会使用 HTTP 基本认证来发送 OAuth 2.0 访问令牌。如果您在检索 `userinfo` 端点时看到 401 错误，请检查您的 OpenID Web 服务器配置。例如，对于 [`oauth2-server-php`](https://github.com/bshaffer/oauth2-server-php)，您可能需要[向 Apache 添加一个配置参数](https://github.com/bshaffer/oauth2-server-php/issues/926#issuecomment-387502778)。
1. **仅限逐步认证**：确保 `step_up_auth => admin_mode => params` 中定义的任何参数也在 `args => allow_authorize_params` 中定义。这包括用于重定向到 IdP 授权端点的请求查询参数中的参数。