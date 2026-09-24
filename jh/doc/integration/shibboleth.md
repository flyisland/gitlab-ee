---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Shibboleth 作为认证提供者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 使用 [极狐GitLab SAML 集成](saml.md) 来集成特定的 Shibboleth 身份提供者 (IdPs)。对于 Shibboleth 联邦支持（发现服务），请使用本文档。

要在极狐GitLab 中启用 Shibboleth 支持，请使用 Apache 而不是 NGINX。Apache 使用 `mod_shib2` 模块进行 Shibboleth 认证，并可将属性作为标头传递给 OmniAuth Shibboleth 提供程序。

你可以使用 Linux 软件包中提供的捆绑 NGINX，通过反向代理设置在不同的实例上运行 Shibboleth 服务提供程序。但是，如果你不这样做，捆绑的 NGINX 就很难配置。

要启用 Shibboleth OmniAuth 提供程序，你必须：

- [安装 Apache 模块](https://shibboleth.atlassian.net/wiki/spaces/SP3/pages/2065335062/Apache)
- [配置 Apache 模块](https://jihulab.com/gitlab-cn/gitlab-recipes/tree/master/web-server/apache)

要启用 Shibboleth：

1. 保护 OmniAuth Shibboleth 回调 URL：

   ```apache
   <Location /users/auth/shibboleth/callback>
     AuthType shibboleth
     ShibRequestSetting requireSession 1
     ShibUseHeaders On
     require valid-user
   </Location>

   Alias /shibboleth-sp /usr/share/shibboleth
   <Location /shibboleth-sp>
     Satisfy any
   </Location>

   <Location /Shibboleth.sso>
     SetHandler shib
   </Location>
   ```

1. 从重写中排除 Shibboleth URL。添加 `RewriteCond %{REQUEST_URI} !/Shibboleth.sso` 和 `RewriteCond %{REQUEST_URI} !/shibboleth-sp`。示例配置：

   ```apache
   # Apache equivalent of Nginx try files
   RewriteEngine on
   RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_URI} !/Shibboleth.sso
   RewriteCond %{REQUEST_URI} !/shibboleth-sp
   RewriteRule .* http://127.0.0.1:8080%{REQUEST_URI} [P,QSA]
   RequestHeader set X_FORWARDED_PROTO 'https'
   ```

1. 将 Shibboleth 添加到 `/etc/gitlab/gitlab.rb` 作为 OmniAuth 提供程序。
   用户属性从 Apache 反向代理作为标头发送到极狐GitLab，其名称来自 Shibboleth 属性映射。
   因此，`args` 哈希的值应采用 `"HTTP_ATTRIBUTE"` 的形式。
   哈希中的键是 [OmniAuth::Strategies::Shibboleth class](https://github.com/omniauth/omniauth-shibboleth-redux/blob/master/lib/omniauth/strategies/shibboleth.rb) 的参数，并由 [`omniauth-shibboleth-redux`](https://github.com/omniauth/omniauth-shibboleth-redux) gem 记录（请注意与极狐GitLab 打包的 gem 版本）。

   文件应如下所示：

   ```ruby
   external_url 'https://gitlab.example.com'
   gitlab_rails['internal_api_url'] = 'https://gitlab.example.com'

   # disable Nginx
   nginx['enable'] = false

   gitlab_rails['omniauth_allow_single_sign_on'] = true
   gitlab_rails['omniauth_block_auto_created_users'] = false
   gitlab_rails['omniauth_providers'] = [
     {
       "name"  => "shibboleth",
       "label" => "Text for Login Button",
       "args"  => {
           "shib_session_id_field"     => "HTTP_SHIB_SESSION_ID",
           "shib_application_id_field" => "HTTP_SHIB_APPLICATION_ID",
           "uid_field"                 => 'HTTP_EPPN',
           "name_field"                => 'HTTP_CN',
           "info_fields"               => { "email" => 'HTTP_MAIL'}
       }
     }
   ]
   ```

   如果某些用户似乎已通过 Shibboleth 和 Apache 认证，但极狐GitLab 以包含“e-mail is invalid”的 URI 拒绝其账户，则你的 Shibboleth 身份提供者或属性授权机构可能声明了多个电子邮件地址。在这种情况下，请考虑将 `multi_values` 参数设置为 `first`。
1. 要使更改生效：
   - 对于 Linux 软件包安装，[重新配置](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 极狐GitLab。
   - 对于自编译安装，[重启](../administration/restart_gitlab.md#self-compiled-installations) 极狐GitLab。

在登录页面上，现在应该会在常规登录表单下方出现一个 **使用 Shibboleth 登录** 的图标。选择该图标以开始认证过程。你将根据 Shibboleth 模块配置重定向到相应的 IdP 服务器。如果一切顺利，你将返回到极狐GitLab 并登录。

