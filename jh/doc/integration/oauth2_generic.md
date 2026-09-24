---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Generic OAuth2 gem 作为 OAuth 2.0 认证提供者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 如果你的提供者支持 OpenID 规范，你应该使用 [`omniauth-openid-connect`](../administration/auth/oidc.md) 作为你的认证提供者。

[`omniauth-oauth2-generic` gem](https://gitlab.com/satorix/omniauth-oauth2-generic) 允许在极狐GitLab 和你的 OAuth 2.0 提供者之间，或任何与此 gem 兼容的 OAuth 2.0 提供者之间进行单点登录（SSO）。

此策略允许配置此 OmniAuth SSO 流程：

1. 策略将客户端引导至你的授权 URL（**可配置**），并携带指定的 ID 和密钥。
1. OAuth 2.0 提供者处理请求、用户身份验证，以及（可选）访问用户资料的授权。
1. OAuth 2.0 提供者将客户端重定向回极狐GitLab，策略在此获取访问令牌。
1. 策略使用访问令牌从 **可配置** 的“用户资料”URL 请求用户信息。
1. 策略使用 **可配置** 的格式解析响应中的用户信息。
1. 极狐GitLab 查找或创建返回的用户并登录。

此策略：

- 只能用于单点登录，不提供任何 OAuth 2.0 提供者授予的其他访问权限。例如，导入项目或用户。
- 仅支持授权码授予流程，这是像极狐GitLab 这样的客户端-服务器应用程序最常见的流程。
- 无法从多个 URL 获取用户信息。
- 无法从 JWT 格式的访问令牌中获取用户信息。
- 除 JSON 外，尚未测试其他用户信息格式。

<a id="configure-the-oauth-2.0-provider"></a>

## 配置 OAuth 2.0 提供者

要配置提供者：

1. 在你要进行身份验证的 OAuth 2.0 提供者中注册你的应用程序。

   注册应用程序时提供的重定向 URI 应为：

   ```plaintext
   http://your-gitlab.host.com/users/auth/oauth2_generic/callback
   ```

   你现在应该能够获取客户端 ID 和客户端密钥。这些信息出现的位置因提供者而异。也可能被称为应用程序 ID 和应用程序密钥。

1. 在你的极狐GitLab 服务器上，完成以下步骤。

   {{< tabs >}}

   {{< tab title="Linux package (Omnibus)" >}}

   1. 配置 [通用设置](omniauth.md#configure-common-settings) 以添加 `oauth2_generic` 作为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户配置。
   1. 编辑 `/etc/gitlab/gitlab.rb` 以添加提供者的配置。例如：

      ```ruby
      gitlab_rails['omniauth_providers'] = [
        {
          name: "oauth2_generic",
          label: "Provider name", # 登录按钮的可选标签，默认为 "Oauth2 Generic"
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

   {{< tab title="Helm chart (Kubernetes)" >}}

   1. 配置 [通用设置](omniauth.md#configure-common-settings) 以添加 `oauth2_generic` 作为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户配置。
   1. 导出 Helm 值：

      ```shell
      helm get values gitlab > gitlab_values.yaml
      ```

   1. 将以下内容放入名为 `oauth2_generic.yaml` 的文件中，用作 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#providers)：

      ```yaml
      name: "oauth2_generic"
      label: "Provider name" # 登录按钮的可选标签，默认为 "Oauth2 Generic"
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

   1. 创建 Kubernetes Secret：

      ```shell
      kubectl create secret generic -n <namespace> gitlab-oauth2-generic --from-file=provider=oauth2_generic.yaml
      ```

   1. 编辑 `gitlab_values.yaml` 并添加提供者配置：

      ```yaml
      global:
        appConfig:
          omniauth:
            providers:
              - secret: gitlab-oauth2-generic
      ```

   1. 保存文件并应用新值：

      ```shell
      helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
      ```

   {{< /tab >}}

   {{< tab title="Self-compiled (source)" >}}

   1. 配置 [通用设置](omniauth.md#configure-common-settings) 以添加 `oauth2_generic` 作为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户配置。
   1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

      ```yaml
      production: &base
        omniauth:
          providers:
            - { name: "oauth2_generic",
                label: "Provider name", # 登录按钮的可选标签，默认为 "Oauth2 Generic"
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
      # 对于使用 systemd 的系统
      sudo systemctl restart gitlab.target

      # 对于使用 SysV init 的系统
      sudo service gitlab restart
      ```

   {{< /tab >}}

   {{< /tabs >}}

在登录页面上，常规登录表单下方现在应该会出现一个新图标。选择该图标以开始提供者的身份验证流程。这将引导浏览器到你的 OAuth 2.0 提供者的身份验证页面。如果一切顺利，你将返回到你的极狐GitLab 实例并登录。