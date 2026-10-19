---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Microsoft Azure 作为 OAuth 2.0 身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以启用 Microsoft Azure OAuth 2.0 OmniAuth 提供商，并使用您的 Microsoft Azure 凭据登录极狐GitLab。

> [!note]
> 如果您是首次将极狐GitLab 与 Azure/Entra ID 集成，
> 请配置 [OpenID Connect 协议](../administration/auth/oidc.md#configure-microsoft-azure)，
> 该协议使用 Microsoft 标识平台 (v2.0) 端点。

<a id="migrate-to-generic-openid-connect-configuration"></a>

## 迁移到通用 OpenID Connect 配置

在极狐GitLab 17.0 及更高版本中，使用 `azure_oauth2`的实例必须迁移到通用 OpenID Connect 配置。有关更多信息，请参阅[迁移到 OpenID Connect 协议](../administration/auth/oidc.md#migrate-to-generic-openid-connect-configuration)。

<a id="register-an-azure-application"></a>

## 注册 Azure 应用程序

要启用 Microsoft Azure OAuth 2.0 OmniAuth 提供商，您必须注册一个 Azure 应用程序并获取客户端 ID 和密钥。

1. 登录 [Azure 门户](https://portal.azure.com)。
1. 如果您有多个 Azure Active Directory 租户，请切换到所需的租户。记下租户 ID。
1. [注册应用程序](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
   并提供以下信息：
   - 重定向 URI，它需要您的极狐GitLab 安装的 Azure OAuth 回调 URL。`https://gitlab.example.com/users/auth/azure_activedirectory_v2/callback`。
   - 应用程序类型，必须设置为 **Web**。
1. 保存客户端 ID 和客户端密钥。客户端密钥仅
   显示一次。

   如有需要，您可以[创建新的应用程序密钥](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal#option-3-create-a-new-client-secret)。

`client ID` 和 `client secret` 是与 OAuth 2.0 相关的术语。在某些 Microsoft 文档中，这些术语被称为 `Application ID` 和
`Application Secret`。

<a id="add-api-permissions-scopes"></a>

## 添加 API 权限（作用域）

创建应用程序后，[将其配置为公开 Web API](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-configure-app-expose-web-apis)。
在 Microsoft Graph API 下添加以下委派权限：

- `email`
- `openid`
- `profile`

或者，添加 `User.Read.All` 应用程序权限。

<a id="enable-microsoft-oauth-in-gitlab"></a>

## 在极狐GitLab 中启用 Microsoft OAuth

> [!note]
> 对于新项目，您应使用
> [OpenID Connect 协议](../administration/auth/oidc.md#configure-microsoft-azure)，
> 该协议使用 Microsoft 标识平台 (v2.0) 端点。

1. 在您的极狐GitLab 服务器上，打开配置文件。

   - 对于 Linux 软件包安装：

     ```shell
     sudo editor /etc/gitlab/gitlab.rb
     ```

   - 对于自行编译安装：

     ```shell
     cd /home/git/gitlab

     sudo -u git -H editor config/gitlab.yml
     ```

1. 配置[通用设置](omniauth.md#configure-common-settings)
   以将 `azure_activedirectory_v2` 添加为单点登录提供商。这会为没有现有极狐GitLab 账号的用户启用即时
   账号预配。
1. 添加提供商配置。将 `<client_id>`、`<client_secret>` 和 `<tenant_id>`
   替换为您注册 Azure 应用程序时获得的值。

   - 对于 Linux 软件包安装：

     ```ruby
     gitlab_rails['omniauth_providers'] = [
       {
         "name" => "azure_activedirectory_v2",
         "label" => "Provider name", # optional label for login button, defaults to "Azure AD v2"
         "args" => {
           "client_id" => "<client_id>",
           "client_secret" => "<client_secret>",
           "tenant_id" => "<tenant_id>",
         }
       }
     ]

     ```

   - 对于[其他 Azure 云](https://learn.microsoft.com/en-us/entra/identity-platform/authentication-national-cloud)，
     在 `args` 部分下配置 `base_azure_url`。例如，对于 Azure Government Community Cloud (GCC)：

     ```ruby
     gitlab_rails['omniauth_providers'] = [
       {
         "name" => "azure_activedirectory_v2",
         "label" => "Provider name", # optional label for login button, defaults to "Azure AD v2"
         "args" => {
           "client_id" => "<client_id>",
           "client_secret" => "<client_secret>",
           "tenant_id" => "<tenant_id>",
           "base_azure_url" => "https://login.microsoftonline.us"
         }
       }
     ]
     ```

   - 对于自行编译安装：

     对于 v2.0 端点：

     ```yaml
     - { name: 'azure_activedirectory_v2',
         label: 'Provider name', # optional label for login button, defaults to "Azure AD v2"
         args: { client_id: "<client_id>",
                 client_secret: "<client_secret>",
                 tenant_id: "<tenant_id>" } }
     ```

     对于[其他 Azure 云](https://learn.microsoft.com/en-us/entra/identity-platform/authentication-national-cloud)，
     在 `args` 部分下配置 `base_azure_url`。例如，对于 Azure Government Community Cloud (GCC)：

     ```yaml
     - { name: 'azure_activedirectory_v2',
         label: 'Provider name', # optional label for login button, defaults to "Azure AD v2"
         args: { client_id: "<client_id>",
                 client_secret: "<client_secret>",
                 tenant_id: "<tenant_id>",
                 base_azure_url: "https://login.microsoftonline.us" } }
     ```

   您还可以选择在 `args` 部分中为 [OAuth 2.0 作用域](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)添加 `scope` 参数。默认值为 `openid profile email`。

1. 保存配置文件。
1. 如果您使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；
   如果您是自行编译安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。
1. 刷新极狐GitLab 登录页面。登录表单下方应显示一个 Microsoft 图标。
1. 选择该图标。登录 Microsoft 并授权该极狐GitLab 应用程序。

阅读[为现有用户启用 OmniAuth](omniauth.md#enable-omniauth-for-an-existing-user)，了解现有极狐GitLab 用户如何连接到他们新的 Azure AD 账号。

<a id="troubleshooting"></a>

## 故障排除

<a id="user-sign-in-banner-message-extern-uid-has-already-been-taken"></a>

### 用户登录横幅消息：Extern UID has already been taken

登录时，您可能会收到一条错误消息，内容为 `Extern UID has already been taken`。

要解决此问题，请使用 [Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session)检查是否存在与该账号关联的现有用户：

1. 查找 `extern_uid`：

   ```ruby
   id = Identity.where(extern_uid: '<extern_uid>')
   ```

1. 打印内容以查找与该 `extern_uid` 关联的用户名：

   ```ruby
   pp id
   ```

如果该 `extern_uid` 已关联到某个账号，您可以使用该用户名登录。

如果该 `extern_uid` 未关联到任何用户名，这可能是因为删除错误导致产生了幽灵记录。

运行以下命令删除该身份以释放 `extern uid`：

```ruby
 Identity.find('<id>').delete
```
