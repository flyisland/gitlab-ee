---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将您的服务器与 JihuLab.com 集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

从 JihuLab.com 导入项目，并使用您的 JihuLab.com 账号登录您的极狐GitLab 实例。

要启用 JihuLab.com OmniAuth 提供商，您必须在 JihuLab.com 上注册您的应用程序。
JihuLab.com 会为您生成应用程序 ID 和密钥，供您使用。

1. 登录 JihuLab.com。
1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **应用程序**。
1. 为**添加新应用程序**提供所需的详细信息。
   - 名称：可以是任意名称。可以考虑类似 `<Organization>'s GitLab` 或 `<Your Name>'s GitLab` 或其他具有描述性的名称。
   - 重定向 URI：

     ```plaintext
     # You can also use a non-SSL URL, but you should use SSL URLs.
     https://your-gitlab.example.com/import/gitlab/callback
     https://your-gitlab.example.com/users/auth/gitlab/callback
     ```

   第一个链接是导入器所必需的，第二个链接用于身份验证。

   如果您：

   - 计划使用导入器，可以保持作用域不变。
   - 只想将此应用程序用于身份验证，则应使用更精简的作用域集合。`read_user` 就足够了。

1. 选择**保存应用程序**。
1. 现在您应该会看到**应用程序 ID** 和**密钥**。请保持此页面打开，以便继续
   配置。
1. 在您的极狐GitLab 服务器上，打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自行编译安装：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置[通用设置](omniauth.md#configure-common-settings)
   以添加 `gitlab` 作为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时
   账号预配。
1. 添加提供商配置：

   对于针对 **JihuLab.com** 进行身份验证的 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "gitlab",
       # label: "Provider name", # optional label for login button, defaults to "GitLab.com"
       app_id: "YOUR_APP_ID",
       app_secret: "YOUR_APP_SECRET",
       args: { scope: "read_user" } # optional: defaults to the scopes of the application
     }
   ]
   ```

   或者，对于针对其他极狐GitLab 实例进行身份验证的 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "gitlab",
       label: "Provider name", # optional label for login button, defaults to "GitLab.com"
       app_id: "YOUR_APP_ID",
       app_secret: "YOUR_APP_SECRET",
       args: { scope: "read_user", # optional: defaults to the scopes of the application
               client_options: { site: "https://gitlab.example.com" } }
     }
   ]
   ```

   对于针对 **JihuLab.com** 进行身份验证的自行编译安装：

   ```yaml
   - { name: 'gitlab',
       # label: 'Provider name', # optional label for login button, defaults to "GitLab.com"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
   ```

   或者，对于针对其他极狐GitLab 实例进行身份验证的自行编译安装：

   ```yaml
   - { name: 'gitlab',
       label: 'Provider name', # optional label for login button, defaults to "GitLab.com"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
       args: { "client_options": { "site": 'https://gitlab.example.com' } }
   ```

1. 将 `'YOUR_APP_ID'` 更改为 JihuLab.com 应用程序页面中的应用程序 ID。
1. 将 `'YOUR_APP_SECRET'` 更改为 JihuLab.com 应用程序页面中的密钥。
1. 保存配置文件。
1. 使用适当的方法实施这些更改：
   - 对于 Linux 软件包安装，[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 对于自行编译安装，[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

在登录页面上，常规登录表单下方现在应该会显示一个 JihuLab.com 图标。选择该图标以开始身份验证过程。JihuLab.com 会要求用户登录并授权该极狐GitLab 应用程序。如果一切顺利，用户将返回到您的极狐GitLab 实例并完成登录。

<a id="reduce-access-privileges-on-sign-in"></a>

## 登录时减少访问权限

如果您使用极狐GitLab 实例进行身份验证，则可以在使用 OAuth 应用程序登录时减少访问权限。

任何 OAuth 应用程序都可以通过授权参数来声明应用程序的用途：`gl_auth_type=login`。如果该应用程序配置了 `api` 或 `read_api`，则访问令牌会以 `read_user` 颁发用于登录，因为不需要更高的权限。

极狐GitLab OAuth 客户端已配置为传递此参数，但其他应用程序也可以传递它。
