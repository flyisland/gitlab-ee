---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 集成您的服务器与 JihuLab.com
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

从 JihuLab.com 导入项目，并使用您的 JihuLab.com 账户登录您的极狐GitLab 实例。

要启用 JihuLab.com OmniAuth 提供程序，您必须在 JihuLab.com 上注册您的应用程序。
JihuLab.com 会生成一个应用程序 ID 和密钥供您使用。

1. 登录 JihuLab.com。
1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **Access** > **应用程序**。
1. 为 **新增应用程序** 提供所需的详细信息。
   - 名称：可以是任意内容。建议使用类似 `<组织名称> 的极狐GitLab` 或 `<您的姓名> 的极狐GitLab` 或其他描述性名称。
   - 重定向 URI：

     ```plaintext
     # 您也可以使用非 SSL URL，但建议使用 SSL URL。
     https://your-gitlab.example.com/import/gitlab/callback
     https://your-gitlab.example.com/users/auth/gitlab/callback
     ```

   第一个链接用于导入器，第二个用于认证。

   如果您：

   - 计划使用导入器，可以保持作用域不变。
   - 只想将此应用程序用于认证，应使用更精简的作用域集。`read_user` 就足够了。

1. 选择 **保存应用程序**。
1. 您现在应该会看到 **应用程序 ID** 和 **密钥**。请保持此页面打开以继续配置。
1. 在您的极狐GitLab 服务器上，打开配置文件。

   对于 Linux 安装包：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于源码编译安装：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置 [通用设置](omniauth.md#configure-common-settings)
   以添加 `gitlab` 作为单点登录提供程序。这将为没有现有极狐GitLab 账户的用户启用即时账户预配。
1. 添加提供程序配置：

   对于针对 **JihuLab.com** 进行认证的 Linux 安装包：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "gitlab",
       # label: "提供程序名称", # 登录按钮的可选标签，默认为 "JihuLab.com"
       app_id: "YOUR_APP_ID",
       app_secret: "YOUR_APP_SECRET",
       args: { scope: "read_user" } # 可选：默认为应用程序的作用域
     }
   ]
   ```

   或者，对于针对不同的极狐GitLab 实例进行认证的 Linux 安装包：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "gitlab",
       label: "提供程序名称", # 登录按钮的可选标签，默认为 "JihuLab.com"
       app_id: "YOUR_APP_ID",
       app_secret: "YOUR_APP_SECRET",
       args: { scope: "read_user", # 可选：默认为应用程序的作用域
               client_options: { site: "https://gitlab.example.com" } }
     }
   ]
   ```

   对于针对 **JihuLab.com** 进行认证的源码编译安装：

   ```yaml
   - { name: 'gitlab',
       # label: '提供程序名称', # 登录按钮的可选标签，默认为 "JihuLab.com"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
   ```

   或者，对于针对不同的极狐GitLab 实例进行认证的源码编译安装：

   ```yaml
   - { name: 'gitlab',
       label: '提供程序名称', # 登录按钮的可选标签，默认为 "JihuLab.com"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
       args: { "client_options": { "site": 'https://gitlab.example.com' } }
   ```

   > [!note]
   > 在极狐GitLab 15.1 及更早版本中，`site` 参数需要 `/api/v4` 后缀。
   > 升级到极狐GitLab 15.2 或更高版本后，应移除此后缀。
1. 将 `'YOUR_APP_ID'` 更改为来自 JihuLab.com 应用程序页面的应用程序 ID。
1. 将 `'YOUR_APP_SECRET'` 更改为来自 JihuLab.com 应用程序页面的密钥。
1. 保存配置文件。
1. 使用适当的方法实施这些更改：
   - 对于 Linux 安装包，[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 对于源码编译安装，[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

在登录页面上，常规登录表单下方现在应有一个 JihuLab.com 图标。选择该图标以开始认证过程。
JihuLab.com 会要求用户登录并授权极狐GitLab 应用程序。如果一切顺利，用户将返回到您的极狐GitLab 实例并登录。

<a id="reduce-access-privileges-on-sign-in"></a>

## 减少登录时的访问权限

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 14.8 中引入，带有一个名为 `omniauth_login_minimal_scopes` 的功能标志。默认禁用。
- 在极狐GitLab 14.9 中[于 JihuLab.com 启用](https://gitlab.com/gitlab-org/gitlab/-/issues/351331)。
- 功能标志 `omniauth_login_minimal_scopes` 在极狐GitLab 15.2 中移除。

{{< /history >}}

如果您使用极狐GitLab 实例进行认证，可以在使用 OAuth 应用程序登录时降低访问权限。

任何 OAuth 应用程序都可以通过授权参数声明其用途：`gl_auth_type=login`。如果应用程序配置了 `api` 或 `read_api`，则会为登录颁发具有 `read_user` 权限的访问令牌，因为不需要更高的权限。

极狐GitLab OAuth 客户端已配置为传递此参数，但其他应用程序也可以传递它。