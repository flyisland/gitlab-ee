---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Auth0 作为 OAuth 2.0 身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用 Auth0 OmniAuth 提供商，您必须创建一个 Auth0 账号和一个应用。

1. 登录 [Auth0 控制台](https://auth0.com/auth/login)。您也可以通过同一链接创建账号。
1. 选择 **新建应用/API**。
1. 输入 **应用程序名称**。例如，'GitLab'。
1. 创建应用后，您应该会看到 **快速开始** 选项。
   请忽略这些选项，改为选择 **设置**。
1. 在设置屏幕顶部，您应该会在 Auth0 控制台中看到您的 **域**、**客户端 ID** 和
   **客户端密钥**。请记下这些设置，以便稍后完成配置文件。例如：
   - 域： `test1234.auth0.com`
   - 客户端 ID： `t6X8L2465bNePWLOvt9yi41i`
   - 客户端密钥： `KbveM3nqfjwCbrhaUy_gDu2dss8TIlHIdzlyf33pB7dEK5u_NyQdp65O_o02hXs2`
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

   对于自行编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置[通用设置](omniauth.md#configure-common-settings)
   以添加 `auth0` 作为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时
   账号预配。
1. 添加提供商配置：

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "auth0",
       # label: "Provider name", # optional label for login button, defaults to "Auth0"
       args: {
         client_id: "<your_auth0_client_id>",
         client_secret: "<your_auth0_client_secret>",
         domain: "<your_auth0_domain>",
         scope: "openid profile email"
       }
     }
   ]
   ```

   对于自行编译安装：

   ```yaml
   - { name: 'auth0',
       # label: 'Provider name', # optional label for login button, defaults to "Auth0"
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
1. 根据您的安装方式，重新配置或重启极狐GitLab：
   - 如果您使用 Linux 软件包安装，
     [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 如果您自行编译安装，
     [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

现在，登录页面上常规登录表单下方应该会显示一个 Auth0 图标。选择该图标以开始身份验证流程。Auth0 会要求用户登录并授权极狐GitLab 应用。如果用户身份验证成功，用户将返回极狐GitLab 并完成登录。
