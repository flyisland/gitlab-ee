---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 JWT 作为认证提供程序
description: Configure JWT-based SSO in 极狐GitLab with Just-In-Time user provisioning
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用 JWT OmniAuth 提供程序，你必须向 JWT 注册你的应用程序。
JWT 会为你提供一个密钥供你使用。

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

1. 配置[通用设置](../../integration/omniauth.md#configure-common-settings)将 `jwt` 添加为单点登录提供程序。这将为没有现有极狐GitLab 帐户的用户启用即时帐户供应。
1. 添加提供程序配置。

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     { name: "jwt",
       label: "Provider name", # 登录按钮的可选标签，默认为 "Jwt"
       args: {
         secret: "YOUR_APP_SECRET",
         algorithm: "HS256", # 支持的算法："RS256"、"RS384"、"RS512"、"ES256"、"ES384"、"ES512"、"HS256"、"HS384"、"HS512"
         uid_claim: "email",
         required_claims: ["name", "email"],
         info_map: { name: "name", email: "email" },
         auth_url: "https://example.com/",
         valid_within: 3600 # 1 小时
       }
     }
   ]
   ```

   对于自编译安装：

   ```yaml
   - { name: 'jwt',
       label: 'Provider name', # 登录按钮的可选标签，默认为 "Jwt"
       args: {
         secret: 'YOUR_APP_SECRET',
         algorithm: 'HS256', # 支持的算法：'RS256'、'RS384'、'RS512'、'ES256'、'ES384'、'ES512'、'HS256'、'HS384'、'HS512'
         uid_claim: 'email',
         required_claims: ['name', 'email'],
         info_map: { name: 'name', email: 'email' },
         auth_url: 'https://example.com/',
         valid_within: 3600 # 1 小时
       }
     }
   ```

   有关每个配置选项的更多信息，请参阅 [OmniAuth JWT 使用文档](https://github.com/mbleigh/omniauth-jwt#usage)。

   > [!warning]
   > 错误配置这些设置可能导致实例不安全。

1. 将 `YOUR_APP_SECRET` 更改为客户端密钥，并将 `auth_url` 设置为你的重定向 URL。
1. 保存配置文件。
1. 为使更改生效，如果你：
   - 使用 Linux 软件包安装了极狐GitLab，请[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 自编译了极狐GitLab 安装，请[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

在登录页面上，常规登录表单下方现在应该有一个 JWT 图标。
选择该图标以开始认证过程。JWT 会要求用户登录并授权极狐GitLab 应用程序。如果一切顺利，用户将被重定向到极狐GitLab 并登录。