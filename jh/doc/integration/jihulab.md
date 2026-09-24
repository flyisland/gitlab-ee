---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 将您的服务器和 JihuLab.com 集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

从 JihuLab.com 导入项目，并使用你的 JihuLab.com 账户登录到你的极狐GitLab 实例。

要启用 JihuLab.com OmniAuth 提供者，你必须在 JihuLab.com 上注册你的应用程序。JihuLab.com 会为你生成一个应用程序 ID 和密钥。

1. 登录 JihuLab.com。
1. 在左侧边栏中，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **应用程序**。
1. 提供 **添加新应用程序** 所需的详细信息。
   - 名称：可以是任何名称。考虑使用类似 `<Organization>'s GitLab` 或 `<Your Name>'s GitLab` 或其他描述性名称。
   - 重定向 URI：

     ```plaintext
     # 你也可以使用非 SSL URL，但建议使用 SSL URL。
     https://your-gitlab.example.com/import/gitlab/callback
     https://your-gitlab.example.com/users/auth/gitlab/callback
     ```

   第一个链接是导入器所需，第二个用于认证。

   如果你：

   - 计划使用导入器，可以保持范围不变。
   - 仅想使用此应用程序进行认证，建议使用更简化的范围。`read_user` 就足够了。

1. 选择 **保存应用程序**。
1. 你现在应该看到一个 **应用程序 ID** 和 **密钥**。继续配置时保持此页面打开。
1. 在你的极狐GitLab 服务器上，打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自编译安装：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置 [公共设置](omniauth.md#configure-common-settings) 以添加 `gitlab` 作为单点登录提供者。这为没有现有极狐GitLab 账户的用户启用及时账户配置。
1. 添加提供者配置：

   对于 Linux 软件包安装，针对 **JihuLab.com** 进行认证：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "gitlab",
       # label: "Provider name", # 登录按钮的可选标签，默认为 "GitLab.com"
       app_id: "YOUR_APP_ID",
       app_secret: "YOUR_APP_SECRET",
       args: { scope: "read_user" } # 可选：默认为应用程序的范围
     }
   ]
   ```

   或者，对于 Linux 软件包安装，针对不同的极狐GitLab 实例进行认证：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "gitlab",
       label: "Provider name", # 登录按钮的可选标签，默认为 "GitLab.com"
       app_id: "YOUR_APP_ID",
       app_secret: "YOUR_APP_SECRET",
       args: { scope: "read_user", # 可选：默认为应用程序的范围
               client_options: { site: "https://gitlab.example.com" } }
     }
   ]
   ```

   对于自编译安装，针对 **JihuLab.com** 进行认证：

   ```yaml
   - { name: 'gitlab',
       # label: 'Provider name', # 登录按钮的可选标签，默认为 "GitLab.com"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
   ```

   或者，对于自编译安装，针对不同的极狐GitLab 实例进行认证：

   ```yaml
   - { name: 'gitlab',
       label: 'Provider name', # 登录按钮的可选标签，默认为 "GitLab.com"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
       args: { "client_options": { "site": 'https://gitlab.example.com' } }
   ```

   {{< alert type="note" >}}

   在极狐GitLab 15.1 及更早版本中，`site` 参数需要一个 `/api/v4` 后缀。我们建议在升级到极狐GitLab 15.2 或更高版本后删除这个后缀。

   {{< /alert >}}

1. 将 `'YOUR_APP_ID'` 更改为 JihuLab.com 应用程序页面上的应用程序 ID。
1. 将 `'YOUR_APP_SECRET'` 更改为 JihuLab.com 应用程序页面上的密钥。
1. 保存配置文件。
1. 使用适当的方法实施这些更改：
   - 对于 Linux 软件包安装，[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 对于自编译安装，[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

在登录页面上，现在应该有一个 JihuLab.com 图标，跟随常规登录表单。选择该图标开始认证过程。JihuLab.com 要求用户登录并授权极狐GitLab 应用程序。如果一切顺利，用户会返回到你的极狐GitLab 实例并登录。

<a id="reduce-access-privileges-on-sign-in"></a>

## 减少登录时的访问权限

{{< history >}}

- 在极狐GitLab 14.8 中引入，使用名为 `omniauth_login_minimal_scopes` 的功能标志。默认情况下禁用。
- 在极狐GitLab 14.9 中在 JihuLab.com 上启用。
- 在极狐GitLab 15.2 中，功能标志 `omniauth_login_minimal_scopes` 被移除。

{{< /history >}}

如果你使用极狐GitLab 实例进行认证，当使用 OAuth 应用程序进行登录时，你可以减少访问权限。

任何 OAuth 应用程序都可以使用授权参数 `gl_auth_type=login` 来宣传应用程序的目的。如果应用程序配置了 `api` 或 `read_api`，则访问令牌会在登录时以 `read_user` 的形式发布，因为不需要更高的权限。

极狐GitLab OAuth 客户端被配置为传递此参数，但其他应用程序也可以传递它。
