---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Microsoft Azure 作为 OAuth 2.0 认证提供商
---

<a id="use-microsoft-azure-as-oauth-2.0-authentication-provider"></a>

# 使用 Microsoft Azure 作为 OAuth 2.0 认证提供商

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以启用 Microsoft Azure OAuth 2.0 OmniAuth 提供程序，并使用你的 Microsoft Azure 凭据登录 极狐GitLab。

> [!note]
> 如果你是首次将 极狐GitLab 与 Azure/Entra ID 集成，请配置 [OpenID Connect 协议](../administration/auth/oidc.md#configure-microsoft-azure)，该协议使用 Microsoft 身份平台 (v2.0) 端点。

<a id="migrate-to-generic-openid-connect-configuration"></a>

## 迁移到通用 OpenID Connect 配置

在 极狐GitLab 17.0 及更高版本中，使用 `azure_oauth2` 的实例必须迁移到通用 OpenID Connect 配置。更多信息，请参阅 [迁移到 OpenID Connect 协议](../administration/auth/oidc.md#migrate-to-generic-openid-connect-configuration)。

<a id="register-an-azure-application"></a>

## 注册 Azure 应用程序

要启用 Microsoft Azure OAuth 2.0 OmniAuth 提供程序，你必须注册一个 Azure 应用程序并获取客户端 ID 和密钥。

1. 登录 [Azure 门户](https://portal.azure.com)。
1. 如果你有多个 Azure Active Directory 租户，请切换到所需的租户。记下租户 ID。
1. [注册应用程序](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app) 并提供以下信息：
   - 重定向 URI，需要你的 极狐GitLab 安装的 Azure OAuth 回调 URL。`https://gitlab.example.com/users/auth/azure_activedirectory_v2/callback`。
   - 应用程序类型，必须设置为 **Web**。
1. 保存客户端 ID 和客户端密钥。客户端密钥仅显示一次。

   如果需要，你可以 [创建新的应用程序密钥](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal#option-3-create-a-new-client-secret)。

`客户端 ID` 和 `客户端密钥` 是与 OAuth 2.0 相关的术语。在某些 Microsoft 文档中，这些术语被称为 `应用程序 ID` 和 `应用程序密钥`。

<a id="add-api-permissions-scopes"></a>

## 添加 API 权限（作用域）

创建应用程序后，[将其配置为公开 Web API](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-configure-app-expose-web-apis)。在 Microsoft Graph API 下添加以下委派权限：

- `email`
- `openid`
- `profile`

或者，添加 `User.Read.All` 应用程序权限。

<a id="enable-microsoft-oauth-in-gitlab"></a>

## 在 极狐GitLab 中启用 Microsoft OAuth

> [!note]
> 对于新项目，你应该使用 [OpenID Connect 协议](../administration/auth/oidc.md#configure-microsoft-azure)，该协议使用 Microsoft 身份平台 (v2.0) 端点。

1. 在你的 极狐GitLab 服务器上，打开配置文件。

   - 对于 Linux 安装包方式：

     ```shell
     sudo editor /etc/gitlab/gitlab.rb
     ```

   - 对于自编译安装方式：

     ```shell
     cd /home/git/gitlab

     sudo -u git -H editor config/gitlab.yml
     ```

1. 配置 [通用设置](omniauth.md#configure-common-settings) 将 `azure_activedirectory_v2` 添加为单点登录提供商。这将为没有现有 极狐GitLab 帐户的用户启用即时帐户供应。
1. 添加提供商配置。将 `<client_id>`、`<client_secret>` 和 `<tenant_id>` 替换为你注册 Azure 应用程序时获得的值。

   - 对于 Linux 安装包方式：

     ```ruby
     gitlab_rails['omniauth_providers'] = [
       {
         "name" => "azure_activedirectory_v2",
         "label" => "Provider name", # 登录按钮的可选标签，默认为 "Azure AD v2"
         "args" => {
           "client_id" => "<client_id>",
           "client_secret" => "<client_secret>",
           "tenant_id" => "<tenant_id>",
         }
       }
     ]

     ```

   - 对于[其他 Azure 云](https://learn.microsoft.com/en-us/entra/identity-platform/authentication-national-cloud)，在 `args` 部分下配置 `base_azure_url`。例如，对于 Azure Government Community Cloud (GCC)：

     ```ruby
     gitlab_rails['omniauth_providers'] = [
       {
         "name" => "azure_activedirectory_v2",
         "label" => "Provider name", # 登录按钮的可选标签，默认为 "Azure AD v2"
         "args" => {
           "client_id" => "<client_id>",
           "client_secret" => "<client_secret>",
           "tenant_id" => "<tenant_id>",
           "base_azure_url" => "https://login.microsoftonline.us"
         }
       }
     ]
     ```

   - 对于自编译安装方式：

     对于 v2.0 端点：

     ```yaml
     - { name: 'azure_activedirectory_v2',
         label: 'Provider name', # 登录按钮的可选标签，默认为 "Azure AD v2"
         args: { client_id: "<client_id>",
                 client_secret: "<client_secret>",
                 tenant_id: "<tenant_id>" } }
     ```

     对于[其他 Azure 云](https://learn.microsoft.com/en-us/entra/identity-platform/authentication-national-cloud)，在 `args` 部分下配置 `base_azure_url`。例如，对于 Azure Government Community Cloud (GCC)：

     ```yaml
     - { name: 'azure_activedirectory_v2',
         label: 'Provider name', # 登录按钮的可选标签，默认为 "Azure AD v2"
         args: { client_id: "<client_id>",
                 client_secret: "<client_secret>",
                 tenant_id: "<tenant_id>",
                 base_azure_url: "https://login.microsoftonline.us" } }
     ```

   你还可以选择性地在 `args` 部分添加 [OAuth 2.0 作用域](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow) 的 `scope` 参数。默认为 `openid profile email`。

1. 保存配置文件。
1. 如果你使用 Linux 安装包安装，则[重新配置 极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；如果你自行编译安装，则[重启 极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。
1. 刷新 极狐GitLab 登录页面。一个 Microsoft 图标应该显示在登录表单下方。
1. 选择该图标。登录 Microsoft 并授权 极狐GitLab 应用程序。

请阅读 [为现有用户启用 OmniAuth](omniauth.md#enable-omniauth-for-an-existing-user) 了解现有 极狐GitLab 用户如何连接到其新的 Azure AD 帐户。

<a id="troubleshooting"></a>

## 故障排除

<a id="user-sign-in-banner-message-extern-uid-has-already-been-taken"></a>

### 用户登录横幅消息：外部 UID 已被占用

登录时，你可能会收到一个错误，提示 `外部 UID 已被占用`。

要解决此问题，请使用 [Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session) 检查是否有现有用户与该帐户关联：

1. 查找 `extern_uid`：

   ```ruby
   id = Identity.where(extern_uid: '<extern_uid>')
   ```

1. 打印内容以查找附加到该 `extern_uid` 的用户名：

   ```ruby
   pp id
   ```

如果 `extern_uid` 附加到一个帐户，你可以使用该用户名登录。

如果 `extern_uid` 未附加到任何用户名，这可能是由于删除错误导致幽灵记录。

运行以下命令删除身份以释放 `extern uid`：

```ruby
 Identity.find('<id>').delete
```