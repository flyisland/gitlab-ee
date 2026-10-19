---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 GitHub 作为 OAuth 2.0 身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将极狐GitLab 实例与 GitHub.com 和 GitHub Enterprise 集成。
您可以从 GitHub 导入项目，或使用 GitHub 凭据登录极狐GitLab。

<a id="create-an-oauth-app-in-github"></a>

## 在 GitHub 中创建 OAuth 应用

要启用 GitHub OmniAuth 提供商，您需要从 GitHub 获取 OAuth 2.0 客户端 ID 和客户端密钥：

1. 登录 GitHub。
1. [创建 OAuth 应用](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app)
   并提供以下信息：
   - 极狐GitLab 实例的 URL，例如 `https://gitlab.example.com`。
   - 授权回调 URL，例如 `https://gitlab.example.com/users/auth/github/callback`。
     如果您的极狐GitLab 实例使用非默认端口，请包含端口号。

<a id="check-for-security-vulnerabilities"></a>

### 检查安全漏洞

对于某些集成，[OAuth 2 隐蔽重定向](https://oauth.net/advisories/2014-1-covert-redirect/)漏洞可能会危及极狐GitLab 账号。要缓解此漏洞，请将完整的 `/users/auth/github/callback` 路径附加到您的极狐GitLab 实例 URL。

但是，GitHub 不会验证 `redirect_uri`的子域部分。因此，您网站任意子域上的子域接管、XSS 或开放重定向都可能引发隐蔽重定向攻击。

<a id="enable-github-oauth-in-gitlab"></a>

## 在极狐GitLab 中启用 GitHub OAuth

1. 配置[通用设置](omniauth.md#configure-common-settings)
   以将 `github` 添加为单点登录提供商。这会为没有现有极狐GitLab 账号的用户启用即时账号预配。
1. 使用以下信息编辑极狐GitLab 配置文件：

   | GitHub 设置 | 极狐GitLab 配置文件中的值 | 描述             |
   |----------------|----------------------------------------|-------------------------|
   | 客户端 ID      | `YOUR_APP_ID`                          | OAuth 2.0 客户端 ID     |
   | 客户端密钥  | `YOUR_APP_SECRET`                      | OAuth 2.0 客户端密钥 |
   | URL            | `https://github.example.com/`          | GitHub 部署 URL   |

   - 对于 Linux 软件包安装：

     1. 打开 `/etc/gitlab/gitlab.rb` 文件。

        对于 GitHub.com，更新以下部分：

        ```ruby
        gitlab_rails['omniauth_providers'] = [
          {
            name: "github",
            # label: "Provider name", # optional label for login button, defaults to "GitHub"
            app_id: "YOUR_APP_ID",
            app_secret: "YOUR_APP_SECRET",
            args: { scope: "user:email" }
          }
        ]
        ```

        对于 GitHub Enterprise，更新以下部分，并将
        `https://github.example.com/` 替换为您的 GitHub URL：

        ```ruby
        gitlab_rails['omniauth_providers'] = [
          {
            name: "github",
            # label: "Provider name", # optional label for login button, defaults to "GitHub"
            app_id: "YOUR_APP_ID",
            app_secret: "YOUR_APP_SECRET",
            url: "https://github.example.com/",
            args: { scope: "user:email" }
          }
        ]
        ```

     1. 保存文件并[重新配置](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)
        极狐GitLab。

   - 对于自行编译安装：

     1. 打开 `config/gitlab.yml` 文件。

        对于 GitHub.com，更新以下部分：

        ```yaml
        - { name: 'github',
            # label: 'Provider name', # optional label for login button, defaults to "GitHub"
            app_id: 'YOUR_APP_ID',
            app_secret: 'YOUR_APP_SECRET',
            args: { scope: 'user:email' } }
        ```

        对于 GitHub Enterprise，更新以下部分，并将
        `https://github.example.com/` 替换为您的 GitHub URL：

        ```yaml
        - { name: 'github',
            # label: 'Provider name', # optional label for login button, defaults to "GitHub"
            app_id: 'YOUR_APP_ID',
            app_secret: 'YOUR_APP_SECRET',
            url: "https://github.example.com/",
            args: { scope: 'user:email' } }
        ```

     1. 保存文件并[重启](../administration/restart_gitlab.md#self-compiled-installations)
        极狐GitLab。

1. 刷新极狐GitLab 登录页面。登录表单下方应显示一个 GitHub 图标。
1. 选择该图标。登录 GitHub 并授权该极狐GitLab 应用。

<a id="troubleshooting"></a>

## 故障排除

<a id="imports-from-github-enterprise-with-a-self-signed-certificate-fail"></a>

### 从使用自签名证书的 GitHub Enterprise 导入失败

当您使用自签名证书从 GitHub Enterprise 导入项目时，导入会失败。

要解决此问题，您必须禁用 SSL 验证：

1. 在配置文件中将 `verify_ssl` 设置为 `false`。

   - 对于 Linux 软件包安装：

     ```ruby
     gitlab_rails['omniauth_providers'] = [
       {
         name: "github",
         # label: "Provider name", # optional label for login button, defaults to "GitHub"
         app_id: "YOUR_APP_ID",
         app_secret: "YOUR_APP_SECRET",
         url: "https://github.example.com/",
         verify_ssl: false,
         args: { scope: "user:email" }
       }
     ]
     ```

   - 对于自行编译安装：

     ```yaml
     - { name: 'github',
         # label: 'Provider name', # optional label for login button, defaults to "GitHub"
         app_id: 'YOUR_APP_ID',
         app_secret: 'YOUR_APP_SECRET',
         url: "https://github.example.com/",
         verify_ssl: false,
         args: { scope: 'user:email' } }
     ```

1. 在极狐GitLab 服务器上将全局 Git `sslVerify` 选项更改为 `false`。

   - 对于 Linux 软件包安装：

     ```ruby
     gitaly['configuration'] = {
       git: {
         config: [
           { key: "http.sslVerify", value: "false" },
         ],
       },
     }
     ```

   - 对于自行编译安装，编辑 Gitaly 配置（`gitaly.toml`）：

     ```toml
     [[git.config]]
     key = "http.sslVerify"
     value = "false"
     ```

1. 如果您使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；
   如果您是自行编译安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

<a id="signing-in-using-github-enterprise-returns-a-500-error"></a>

### 使用 GitHub Enterprise 登录时返回 500 错误

此错误可能是由于您的极狐GitLab 实例与 GitHub Enterprise 之间的网络连接问题导致的。

要检查连接问题：

1. 转到极狐GitLab 服务器上的 [`production.log`](../administration/logs/_index.md#productionlog)
   并查找以下错误：

   ``` plaintext
   Faraday::ConnectionFailed (execution expired)
   ```

1. [启动 rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session)
   并运行以下命令。将 `<github_url>` 替换为您的
   GitHub Enterprise 实例的 URL：

   ```ruby
   uri = URI.parse("https://<github_url>") # replace `GitHub-URL` with the real one here
   http = Net::HTTP.new(uri.host, uri.port)
   http.use_ssl = true
   http.verify_mode = 1
   response = http.request(Net::HTTP::Get.new(uri.request_uri))
   ```

1. 如果返回类似的 `execution expired` 错误，则确认该错误是由连接问题导致的。请确保极狐GitLab 服务器可以访问您的 GitHub Enterprise 实例。

<a id="signing-in-using-your-github-account-without-a-pre-existing-gitlab-account-is-not-allowed"></a>

### 不允许使用没有预先存在的极狐GitLab 账号的 GitHub 账号登录

当您登录极狐GitLab 时，会出现以下错误：

```plaintext
Signing in using your GitHub account without a pre-existing
GitLab account is not allowed. Create a GitLab account first,
and then connect it to your GitHub account
```

要解决此问题，您必须在极狐GitLab 中激活 GitHub 登录：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **密码和身份验证**。
1. 在**服务登录**部分，选择**连接到 GitHub**。
