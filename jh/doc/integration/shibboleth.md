---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Shibboleth 作为身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 使用 [极狐GitLab SAML 集成](saml.md)来集成特定的 Shibboleth 身份提供商 (IdP)。如需 Shibboleth 联合支持（发现服务），请使用本文档。

要在极狐GitLab 中启用 Shibboleth 支持，请使用 Apache 而不是 NGINX。Apache 使用 `mod_shib2` 模块进行 Shibboleth 身份验证，并可以将属性作为请求头传递给 OmniAuth Shibboleth 提供商。

您可以使用 Linux 软件包中内置的 NGINX，通过反向代理设置在另一实例上运行 Shibboleth 服务提供商。但如果您不这样做，内置的 NGINX 将难以配置。

要启用 Shibboleth OmniAuth 提供商，您必须：

- [安装 Apache 模块](https://shibboleth.atlassian.net/wiki/spaces/SP3/pages/2065335062/Apache)。
- [配置 Apache 模块](https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/web-server/apache)。

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

1. 将 Shibboleth 作为 OmniAuth 提供商添加到 `/etc/gitlab/gitlab.rb`。
   用户属性会以请求头的形式从 Apache 反向代理发送到极狐GitLab，其名称来自 Shibboleth 属性映射。
   因此，`args` 哈希的值应采用 `"HTTP_ATTRIBUTE"` 的形式。
   哈希中的键是 [OmniAuth::Strategies::Shibboleth 类](https://github.com/omniauth/omniauth-shibboleth-redux/blob/master/lib/omniauth/strategies/shibboleth.rb)的参数，由 [`omniauth-shibboleth-redux`](https://github.com/omniauth/omniauth-shibboleth-redux) gem 提供文档说明（请注意极狐GitLab 打包的 gem 版本）。

   该文件应如下所示：

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

   如果您的部分用户似乎已通过 Shibboleth 和 Apache 完成身份验证，但极狐GitLab 拒绝其账号，并返回包含“e-mail is invalid”的 URI，那么您的 Shibboleth 身份提供商或属性权威可能声明了多个电子邮件地址。在这种情况下，请考虑将 `multi_values` 参数设置为 `first`。
1. 要使更改生效：
   - 对于 Linux 软件包安装，请[重新配置](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab。
   - 对于自行编译安装，请[重启](../administration/restart_gitlab.md#self-compiled-installations)极狐GitLab。

在登录页面上，常规登录表单下方现在应显示一个**使用以下方式登录：Shibboleth** 图标。选择该图标以开始身份验证流程。您将被重定向到与您的 Shibboleth 模块配置相对应的 IdP 服务器。如果一切顺利，您将返回极狐GitLab 并完成登录。
