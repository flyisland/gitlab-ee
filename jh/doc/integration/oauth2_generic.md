---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Generic OAuth2 gem 作为 OAuth 2.0 身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 如果您的提供商支持 OpenID 规范，您应使用 [`omniauth-openid-connect`](../administration/auth/oidc.md) 作为身份验证提供商。

[`omniauth-oauth2-generic` gem](https://gitlab.com/satorix/omniauth-oauth2-generic) 允许在极狐GitLab
与您的 OAuth 2.0 提供商之间实现单点登录（SSO），也适用于任何与该 gem 兼容的 OAuth 2.0 提供商。

此策略允许配置以下 OmniAuth SSO 流程：

1. 策略将客户端引导至您的授权 URL（可配置），并携带指定的 ID 和密钥。
1. OAuth 2.0 提供商处理请求、用户的身份验证，以及（可选）访问用户个人资料的授权。
1. OAuth 2.0 提供商将客户端引导回极狐GitLab，策略在此处获取访问令牌。
1. 策略使用访问令牌从可配置的“用户资料”URL 请求用户信息。
1. 策略使用可配置的格式解析响应中的用户信息。
1. 极狐GitLab 查找或创建返回的用户，并将其登录。

此策略：

- 只能用于单点登录，不提供任何 OAuth 2.0 提供商授予的其他访问权限。例如，导入项目或用户。
- 仅支持授权码授予流程，这是像极狐GitLab 这样的客户端-服务器应用程序最常用的流程。
- 无法从多个 URL 获取用户信息。
- 无法从 JWT 格式的访问令牌中获取用户信息。
- 除 JSON 外，尚未针对其他用户信息格式进行测试。

<a id="configure-the-oauth-20-provider"></a>

## 配置 OAuth 2.0 提供商

要配置提供商：

1. 在您要进行身份验证的 OAuth 2.0 提供商中注册您的应用程序。

   注册应用程序时提供的重定向 URI 应为：

   ```plaintext
   http://your-gitlab.host.com/users/auth/oauth2_generic/callback
   ```

   现在您应该能够获取客户端 ID 和客户端密钥。这些信息出现的位置因提供商而异。它们也可能被称为应用程序 ID 和应用程序密钥。
1. 在您的极狐GitLab 服务器上，完成以下步骤。

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `oauth2_generic` 添加为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时账号预配。
   1. 编辑 `/etc/gitlab/gitlab.rb`，添加您的提供商配置。例如：

      ```ruby
      gitlab_rails['omniauth_providers'] = [
        {
          name: "oauth2_generic",
          label: "Provider name", # optional label for login button, defaults to "Oauth2 Generic"
          app_id: "<your_app_client_id>",
          app_secret: "<your_app_client_secret>",
          args: {
            client_options: {
              site: "<your_auth_server_url>",
              user_info_url: "/oauth2/v1/userinfo",
              authorize_url: "/oauth2/v1/authorize",
              token_url: "/oauth2/v1/token"
            },
            user_response_structure: {
              root_path: [],
              id_path: ["sub"],
              attributes: {
                email: "email",
                name: "name"
              }
            },
            authorize_params: {
              scope: "openid profile email"
            },
            strategy_class: "OmniAuth::Strategies::OAuth2Generic"
          }
        }
      ]
      ```

   1. 保存文件并重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   {{< /tab >}}

   {{< tab title="Helm chart（Kubernetes）" >}}

   1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `oauth2_generic` 添加为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时账号预配。
   1. 导出 Helm values：

      ```shell
      helm get values gitlab > gitlab_values.yaml
      ```

   1. 将以下内容放入名为 `oauth2_generic.yaml`的文件中，用作
      [Kubernetes 密钥](https://gitlab.cn/docs/charts/charts/globals/#providers)：

      ```yaml
      name: "oauth2_generic"
      label: "Provider name" # optional label for login button defaults to "Oauth2 Generic"
      app_id: "<your_app_client_id>"
      app_secret: "<your_app_client_secret>"
      args:
        client_options:
          site: "<your_auth_server_url>"
          user_info_url: "/oauth2/v1/userinfo"
          authorize_url: "/oauth2/v1/authorize"
          token_url: "/oauth2/v1/token"
        user_response_structure:
          root_path: []
          id_path: ["sub"]
          attributes:
            email: "email"
            name: "name"
        authorize_params:
          scope: "openid profile email"
        strategy_class: "OmniAuth::Strategies::OAuth2Generic"
      ```

   1. 创建 Kubernetes 密钥：

      ```shell
      kubectl create secret generic -n <namespace> gitlab-oauth2-generic --from-file=provider=oauth2_generic.yaml
      ```

   1. 编辑 `gitlab_values.yaml` 并添加提供商配置：

      ```yaml
      global:
        appConfig:
          omniauth:
            providers:
              - secret: gitlab-oauth2-generic
      ```

   1. 保存文件并应用新的 values：

      ```shell
      helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
      ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `oauth2_generic` 添加为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时账号预配。
   1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

      ```yaml
      production: &base
        omniauth:
          providers:
            - { name: "oauth2_generic",
                label: "Provider name", # optional label for login button, defaults to "Oauth2 Generic"
                app_id: "<your_app_client_id>",
                app_secret: "<your_app_client_secret>",
                args: {
                  client_options: {
                    site: "<your_auth_server_url>",
                    user_info_url: "/oauth2/v1/userinfo",
                    authorize_url: "/oauth2/v1/authorize",
                    token_url: "/oauth2/v1/token"
                  },
                  user_response_structure: {
                    root_path: [],
                    id_path: ["sub"],
                    attributes: {
                      email: "email",
                      name: "name"
                    }
                  },
                  authorize_params: {
                    scope: "openid profile email"
                  },
                  strategy_class: "OmniAuth::Strategies::OAuth2Generic"
                }
              }
      ```

   1. 保存文件并重启极狐GitLab：

      ```shell
      # For systems running systemd
      sudo systemctl restart gitlab.target

      # For systems running SysV init
      sudo service gitlab restart
      ```

   {{< /tab >}}

   {{< /tabs >}}

现在，登录页面上常规登录表单下方应出现一个新图标。选择该图标以开始您的提供商身份验证流程。这会将浏览器引导至您的 OAuth 2.0 提供商的身份验证页面。如果一切顺利，您将返回到您的极狐GitLab 实例并完成登录。
