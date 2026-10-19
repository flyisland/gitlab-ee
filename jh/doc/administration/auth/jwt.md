---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 JWT 作为身份验证提供商
description: 在极狐GitLab 中配置基于 JWT 的 SSO，并启用即时用户预配
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用 JWT OmniAuth 提供商，您必须向 JWT 注册您的应用程序。JWT 会为您提供一个密钥供您使用。

1. 在极狐GitLab 服务器上，打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自行编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置[通用设置](../../integration/omniauth.md#configure-common-settings)，
   将 `jwt` 添加为单点登录提供商。这样可为没有现有极狐GitLab 账号的用户
   启用即时账号预配。
1. 添加提供商配置。

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: "jwt",
       label: "Provider name", # optional label for login button, defaults to "Jwt"
       args: {
         secret: "YOUR_APP_SECRET",
         algorithm: "HS256", # Supported algorithms: "RS256", "RS384", "RS512", "ES256", "ES384", "ES512", "HS256", "HS384", "HS512"
         uid_claim: "email",
         required_claims: ["name", "email"],
         info_map: { name: "name", email: "email" },
         auth_url: "https://example.com/",
         valid_within: 3600 # 1 hour
       }
     }
   ]
   ```

   对于自行编译安装：

   ```yaml
   - { name: 'jwt',
       label: 'Provider name', # optional label for login button, defaults to "Jwt"
       args: {
         secret: 'YOUR_APP_SECRET',
         algorithm: 'HS256', # Supported algorithms: 'RS256', 'RS384', 'RS512', 'ES256', 'ES384', 'ES512', 'HS256', 'HS384', 'HS512'
         uid_claim: 'email',
         required_claims: ['name', 'email'],
         info_map: { name: 'name', email: 'email' },
         auth_url: 'https://example.com/',
         valid_within: 3600 # 1 hour
       }
     }
   ```

   有关各配置选项的更多信息，请参阅
   [OmniAuth JWT 使用文档](https://github.com/mbleigh/omniauth-jwt#usage)。

   > [!warning]
   > 错误配置这些设置可能导致实例不安全。

1. 将 `YOUR_APP_SECRET` 更改为客户端密钥，并将 `auth_url` 设置为您的重定向 URL。
1. 保存配置文件。
1. 要使更改生效，如果您：
   - 使用 Linux 软件包安装极狐GitLab，请[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 自行编译安装极狐GitLab，请[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

现在，登录页面上常规登录表单下方应显示一个 JWT 图标。选择该图标即可开始身份验证流程。JWT 会要求用户登录并授权极狐GitLab 应用程序。如果一切顺利，用户将被重定向到极狐GitLab 并完成登录。
