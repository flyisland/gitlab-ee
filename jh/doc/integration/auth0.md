---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Auth0 作为 OAuth 2.0 身份验证提供程序
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用 Auth0 OmniAuth 提供程序，您必须创建一个 Auth0 账户和一个应用程序。

1. 登录 [Auth0 控制台](https://auth0.com/auth/login)。您也可以使用同一链接创建账户。
1. 选择 **新建应用/API**。
1. 输入 **应用程序名称**。例如，“GitLab”。
1. 创建应用程序后，您应该会看到 **快速开始** 选项。忽略这些选项，改为选择 **设置**。
1. 在设置屏幕的顶部，您应该会在 Auth0 控制台中看到您的 **域**、**客户端 ID** 和 **客户端密钥**。记下这些设置，以便稍后完成配置文件。例如：
   - 域：`test1234.auth0.com`
   - 客户端 ID：`t6X8L2465bNePWLOvt9yi41i`
   - 客户端密钥：`KbveM3nqfjwCbrhaUy_gDu2dss8TIlHIdzlyf33pB7dEK5u_NyQdp65O_o02hXs2`
1. 填写 **允许的回调 URL**：
   - `http://<your_gitlab_url>/users/auth/auth0/callback`（或）
   - `https://<your_gitlab_url>/users/auth/auth0/callback`
1. 填写 **允许的来源 (CORS)**：
   - `http://<your_gitlab_url>`（或）
   - `https://<your_gitlab_url>`
1. 在您的极狐GitLab 服务器上，打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置 [通用设置](omniauth.md#configure-common-settings) 以添加 `auth0` 作为单点登录提供程序。这将为没有现有极狐GitLab 账户的用户启用即时账户配置。
1. 添加提供程序配置：

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "auth0",
       # label: "提供者名称", # 登录按钮的可选标签，默认为 "Auth0"
       args: {
         client_id: "<your_auth0_client_id>",
         client_secret: "<your_auth0_client_secret>",
         domain: "<your_auth0_domain>",
         scope: "openid profile email"
       }
     }
   ]
   ```

   对于自编译安装：

   ```yaml
   - { name: 'auth0',
       # label: '提供者名称', # 登录按钮的可选标签，默认为 "Auth0"
       args: {
         client_id: '<your_auth0_client_id>',
         client_secret: '<your_auth0_client_secret>',
         domain: '<your_auth0_domain>',
         scope: 'openid profile email' }
     }
   ```

1. 将 `<your_auth0_client_id>` 替换为 Auth0 控制台页面中的客户端 ID。
1. 将 `<your_auth0_client_secret>` 替换为 Auth0 控制台页面中的客户端密钥。
1. 将 `<your_auth0_domain>` 替换为 Auth0 控制台页面中的域。
1. 根据您的安装方法重新配置或重启极狐GitLab：
   - 如果您使用 Linux 软件包安装，请 [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 如果您是自编译安装，请 [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

在登录页面上，现在应该在常规登录表单下方显示一个 Auth0 图标。选择该图标以开始身份验证过程。Auth0 会要求用户登录并授权极狐GitLab 应用程序。如果用户成功通过身份验证，则用户将返回到极狐GitLab 并登录。

## 故障排除

### 使用自签名证书从 GitHub Enterprise 导入失败

当您使用自签名证书从 GitHub Enterprise 导入项目时，导入会失败。

要解决此问题，您必须禁用 SSL 验证：

1. 在配置文件中将 `verify_ssl` 设置为 `false`。

   - 对于 Linux 软件包安装：

     ```ruby
     gitlab_rails['omniauth_providers'] = [
       {
         name: "github",
         # label: "提供者名称", # 登录按钮的可选标签，默认为 "Auth0"
         app_id: "YOUR_APP_ID",
         app_secret: "YOUR_APP_SECRET",
         url: "https://github.example.com/",
         verify_ssl: false,
         args: { scope: "user:email" }
       }
     ]
     ```

   - 对于自编译安装：

     ```yaml
     - { name: 'github',
         # label: '提供者名称', # 登录按钮的可选标签，默认为 "Auth0"
         app_id: 'YOUR_APP_ID',
         app_secret: 'YOUR_APP_SECRET',
         url: "https://github.example.com/",
         verify_ssl: false,
         args: { scope: 'user:email' } }
     ```

1. 在极狐GitLab 服务器上将全局 Git `sslVerify` 选项更改为 `false`。

   - 对于运行 [极狐GitLab 15.3](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/6800) 及更高版本的 Linux 软件包安装：

     ```ruby
     gitaly['gitconfig'] = [
        {key: "http.sslVerify", value: "false"},
     ]
     ```

   - 对于运行极狐GitLab 15.2 及更早版本（旧方法）的 Linux 软件包安装：

     ```ruby
     omnibus_gitconfig['system'] = { "http" => ["sslVerify = false"] }
     ```

   - 对于运行 [极狐GitLab 15.3](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/6800) 及更高版本的自编译安装，编辑 Gitaly 配置 (`gitaly.toml`)：

     ```toml
     [[git.config]]
     key = "http.sslVerify"
     value = "false"
     ```

   - 对于运行极狐GitLab 15.2 及更早版本（旧方法）的自编译安装：

     ```shell
     git config --global http.sslVerify false
     ```

1. 如果您使用 Linux 软件包安装，请 [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；如果您是自编译安装，请 [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

### 使用 GitHub Enterprise 登录返回 500 错误

此错误可能是由于您的极狐GitLab 实例与 GitHub Enterprise 之间的网络连接问题造成的。

要检查连接问题：

1. 前往极狐GitLab 服务器上的 [`production.log`](../administration/logs/_index.md#productionlog) 并查找以下错误：

   ``` plaintext
   Faraday::ConnectionFailed (execution expired)
   ```

1. [启动 Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session) 并运行以下命令。将 `<github_url>` 替换为您的 GitHub Enterprise 实例的 URL：

   ```ruby
   uri = URI.parse("https://<github_url>") # 将 `<github_url>` 替换为实际的 URL
   http = Net::HTTP.new(uri.host, uri.port)
   http.use_ssl = true
   http.verify_mode = 1
   response = http.request(Net::HTTP::Get.new(uri.request_uri))
   ```

1. 如果返回类似的 `execution expired` 错误，则确认该错误是由连接问题引起的。请确保极狐GitLab 服务器可以访问您的 GitHub Enterprise 实例。

### 不允许在没有预先存在的极狐GitLab 账户的情况下使用您的 GitHub 账户登录

当您登录极狐GitLab 时，会收到以下错误：

```plaintext
不允许在没有预先存在的极狐GitLab 账户的情况下使用您的 GitHub 账户登录。请先创建一个极狐GitLab 账户，然后将其连接到您的 GitHub 账户。
```

要解决此问题，您必须在极狐GitLab 中激活 GitHub 登录：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码和身份验证**。
1. 在 **服务登录** 部分，选择 **连接到 GitHub**。