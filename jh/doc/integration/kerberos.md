---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab 与 Kerberos 集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 可以集成 [Kerberos](https://web.mit.edu/kerberos/) 作为身份验证机制。

- 您可以配置极狐GitLab，让用户使用其 Kerberos 凭据登录。
- 您可以使用 Kerberos [防止](https://web.mit.edu/sipb/doc/working/guide/guide/node20.html)任何人拦截或窃听传输的密码。

Kerberos 仅适用于使用极狐GitLab 企业版的实例。

> [!warning]
> 除非将该集成[设置为使用专用端口](#http-git-access-with-kerberos-token-passwordless-authentication)，
> 否则极狐GitLab CI/CD 无法与启用了 Kerberos 的极狐GitLab 实例配合使用。

<a id="configuration"></a>

## 配置

要让极狐GitLab 提供基于 Kerberos 令牌的身份验证，请完成以下先决条件。您仍需为 Kerberos 的使用配置系统，例如指定领域。极狐GitLab 会使用系统的 Kerberos 设置。

<a id="gitlab-keytab"></a>

### 极狐GitLab keytab

1. 在极狐GitLab 服务器上为 HTTP 服务创建 Kerberos 服务主体。
   如果您的极狐GitLab 服务器是 `gitlab.example.com`，Kerberos 领域是
   `EXAMPLE.COM`，请在 Kerberos 数据库中创建服务主体 `HTTP/gitlab.example.com@EXAMPLE.COM`。
1. 在极狐GitLab 服务器上为该服务主体创建 keytab。例如，
   `/etc/http.keytab`。

keytab 是敏感文件，必须可由极狐GitLab 用户读取。请适当设置所有权并保护该文件：

```shell
sudo chown git /etc/http.keytab
sudo chmod 0600 /etc/http.keytab
```

<a id="configure-gitlab"></a>

### 配置极狐GitLab

<a id="self-compiled-installations"></a>

#### 自行编译安装

> [!note]
> 对于自行编译安装，请确保 `kerberos` gem 组
> [已安装](../install/self_compiled/_index.md#install-gems)。

1. 编辑 [`gitlab.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example)的 `kerberos` 部分，以启用基于 Kerberos 票据的
   身份验证。在大多数情况下，您只需启用 Kerberos 并指定
   keytab 的位置：

   ```yaml
   omniauth:
     enabled: true
     allow_single_sign_on: ['kerberos']

   kerberos:
     # Allow the HTTP Negotiate authentication method for Git clients
     enabled: true

     # Kerberos 5 keytab file. The keytab file must be readable by the GitLab user,
     # and should be different from other keytabs in the system.
     # (default: use default keytab from Krb5 config)
     keytab: /etc/http.keytab
   ```

1. [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations) 以使更改生效。

<a id="linux-package-installations"></a>

#### Linux 软件包安装

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['omniauth_allow_single_sign_on'] = ['kerberos']

   gitlab_rails['kerberos_enabled'] = true
   gitlab_rails['kerberos_keytab'] = "/etc/http.keytab"
   ```

   为避免极狐GitLab 在用户首次通过 Kerberos 登录时自动创建用户，
   请勿为 `gitlab_rails['omniauth_allow_single_sign_on']` 设置 `kerberos`。
1. [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

极狐GitLab 现在提供 `negotiate` 身份验证方法，用于登录和 HTTP Git 访问，使支持此身份验证协议的 Git 客户端能够使用 Kerberos 令牌进行身份验证。

<a id="enable-single-sign-on"></a>

#### 启用单点登录

配置[通用设置](omniauth.md#configure-common-settings)以将 `kerberos` 添加为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时账号预配。

<a id="create-and-link-kerberos-accounts"></a>

## 创建并关联 Kerberos 账号

您可以将 Kerberos 账号关联到现有的极狐GitLab 账号，也可以设置极狐GitLab 在 Kerberos 用户尝试登录时创建新账号。

<a id="link-a-kerberos-account-to-an-existing-gitlab-account"></a>

### 将 Kerberos 账号关联到现有极狐GitLab 账号

如果您是管理员，可以将 Kerberos 账号关联到现有的极狐GitLab 账号。为此：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择一个用户，然后选择**身份**选项卡。
1. 从**提供商**下拉列表中，选择 **Kerberos**。
1. 确保**标识符**与 Kerberos 用户名对应。
1. 选择**保存更改**。

如果您不是管理员：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **密码和身份验证**。
1. 在**服务登录**部分，选择**连接 Kerberos**。
   如果您没有看到**服务登录** Kerberos 选项，请遵循
   [启用单点登录](#enable-single-sign-on)中的要求。

无论哪种情况，您现在都应该能够使用 Kerberos 凭据登录您的极狐GitLab 账号。

<a id="create-accounts-on-first-sign-in"></a>

### 在首次登录时创建账号

用户首次使用其 Kerberos 账号登录极狐GitLab 时，极狐GitLab 会创建一个匹配的账号。在继续之前，请查看 Linux 软件包和自行编译安装的[通用配置设置](omniauth.md#configure-common-settings)选项。您还必须包含 `kerberos`。

掌握这些信息后：

1. 在 `allow_single_sign_on` 设置中包含 `'kerberos'`。
1. 目前，接受默认的 `block_auto_created_users` 选项，即 true。
1. 当用户尝试使用 Kerberos 凭据登录时，极狐GitLab
   会创建一个新账号。
   1. 如果 `block_auto_created_users` 为 true，Kerberos 用户可能会看到
      类似以下的消息：

      ```shell
      Your account has been blocked. Please contact your GitLab
      administrator if you think this is an error.
      ```

      1. 作为管理员，您可以确认这个新的、被阻止的账号：
         1. 在右上角，选择**管理员**。
         1. 在左侧边栏中，选择**概览** > **用户**，然后查看**已阻止**选项卡。
      1. 您可以启用该用户。
   1. 如果 `block_auto_created_users` 为 false，则 Kerberos 用户
      通过身份验证并登录到极狐GitLab。

> [!warning]
> 建议您保留 `block_auto_created_users`的默认值。
> 在管理员不知情的情况下在极狐GitLab 上创建账号的 Kerberos 用户
> 可能带来安全风险。

<a id="link-kerberos-and-ldap-accounts-together"></a>

## 将 Kerberos 和 LDAP 账号关联在一起

如果您的用户使用 Kerberos 登录，但您还启用了 [LDAP 集成](../administration/auth/ldap/_index.md)，则您的用户会在首次登录时关联到其 LDAP 账号。为此，必须满足一些先决条件：

Kerberos 用户名必须与 LDAP 用户的 UID 匹配。您可以在极狐GitLab [LDAP 配置](../administration/auth/ldap/_index.md#configure-ldap)
中选择将哪个 LDAP 属性用作 UID，
但对于 Active Directory，这应该是 `sAMAccountName`。

Kerberos 领域必须与 LDAP 用户可分辨名称的域部分匹配。
例如，如果 Kerberos 领域是 `AD.EXAMPLE.COM`，则 LDAP
用户的可分辨名称应以 `dc=ad,dc=example,dc=com` 结尾。

综合来看，这些规则意味着只有当您的用户的 Kerberos 用户名形式为 `foo@AD.EXAMPLE.COM`，且其 LDAP 可分辨名称形如 `sAMAccountName=foo,dc=ad,dc=example,dc=com` 时，关联才会生效。

<a id="custom-allowed-realms"></a>

### 自定义允许的领域

当用户的 Kerberos 领域与用户 LDAP DN 中的域不匹配时，您可以配置自定义允许的领域。该配置值必须指定用户可能拥有的所有域。任何其他域都会被忽略，且不会关联 LDAP 身份。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['kerberos_simple_ldap_linking_allowed_realms'] = ['example.com','kerberos.example.com']
   ```

1. 保存文件并[重新配置](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)
   极狐GitLab 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   kerberos:
     simple_ldap_linking_allowed_realms: ['example.com','kerberos.example.com']
   ```

1. 保存文件并[重启](../administration/restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="http-git-access"></a>

## HTTP Git 访问

关联的 Kerberos 账号使您能够使用 Kerberos 账号以及标准的极狐GitLab 凭据执行 `git pull` 和 `git push`。

拥有已关联 Kerberos 账号的极狐GitLab 用户还可以使用 Kerberos 令牌
执行 `git pull` 和 `git push`。也就是说，无需在每次操作时发送其密码。

> [!warning]
> 版本低于 7.64.1 的 `libcurl` 存在一个[已知问题](https://github.com/curl/curl/issues/1261)，
> 即它在协商时不会重用连接。
> 当推送内容大于 `http.postBuffer`
> 配置时，这会导致授权问题。请确保 Git 至少使用 `libcurl` 7.64.1 以避免此问题。要
> 了解已安装的 `libcurl` 版本，请运行 `curl-config --version`。

<a id="http-git-access-with-kerberos-token-passwordless-authentication"></a>

### 使用 Kerberos 令牌进行 HTTP Git 访问（无密码身份验证）

由于[当前 Git 版本中的一个缺陷](https://lore.kernel.org/git/YKNVop80H8xSTCjz@coredump.intra.peff.net/T/#mab47fd7dcb61fee651f7cc8710b8edc6f62983d5)，如果 HTTP 服务器提供 `negotiate` 身份验证方法，`git` CLI 命令就只会使用该方法，即使该方法失败（例如客户端没有 Kerberos 令牌时）。因此，如果 Kerberos 身份验证失败，就无法回退到嵌入式用户名和密码（也称为 `basic`）身份验证。

为了让极狐GitLab 用户能够在当前 Git 版本中使用 `basic` 或 `negotiate` 身份验证，可以在不同的端口（例如 `8443`）上提供基于 Kerberos 票据的身份验证，而标准端口仅提供 `basic` 身份验证。

> [!note]
> [Git 2.4 及更高版本](https://github.com/git/git/blob/master/Documentation/RelNotes/2.4.0.adoc?plain=1#L225-L228)支持在
> 以交互方式或通过凭据管理器传递用户名和密码时回退到 `basic` 身份验证。但如果用户名和密码是作为 URL 的一部分传递的，则无法回退。例如，
> 这可能发生在[使用 CI/CD 作业令牌进行身份验证](../ci/jobs/ci_job_token.md)的极狐GitLab CI/CD 作业中。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['kerberos_use_dedicated_port'] = true
   gitlab_rails['kerberos_port'] = 8443
   gitlab_rails['kerberos_https'] = true
   ```

1. [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码，HTTPS）" >}}

1. 编辑极狐GitLab 的 NGINX 配置文件
   （例如 `/etc/nginx/sites-available/gitlab-ssl`），并配置 NGINX
   除标准 HTTPS 端口外还监听端口 `8443`：

   ```conf
   server {
     listen 0.0.0.0:443 ssl;
     listen [::]:443 ipv6only=on ssl default_server;
     listen 0.0.0.0:8443 ssl;
     listen [::]:8443 ipv6only=on ssl;
   ```

1. 更新 [`gitlab.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example)的 `kerberos` 部分：

   ```yaml
   kerberos:
     # Dedicated port: Git before 2.4 does not fall back to Basic authentication if Negotiate fails.
     # To support both Basic and Negotiate methods with older versions of Git, configure
     # nginx to proxy GitLab on an extra port (for example: 8443) and uncomment the following lines
     # to dedicate this port to Kerberos authentication. (default: false)
     use_dedicated_port: true
     port: 8443
     https: true
   ```

1. [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations) 和 NGINX 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

此更改后，必须将 Git 远程 URL 更新为 `https://gitlab.example.com:8443/mygroup/myproject.git`，才能使用基于 Kerberos 票据的身份验证。

<a id="support-for-active-directory-kerberos-environments"></a>

## 对 Active Directory Kerberos 环境的支持

在 Active Directory 域中使用基于 Kerberos 票据的身份验证时，
可能需要增大 NGINX 允许的最大请求头大小，因为 Kerberos 协议的扩展可能导致 HTTP 身份验证请求头大于默认的 8 kB。请在 [NGINX 配置](https://nginx.org/en/docs/http/ngx_http_core_module.html#large_client_header_buffers)中将 `large_client_header_buffers` 配置为更大的值。

<a id="use-keytabs-created-using-aes-only-encryption-with-windows-ad"></a>

### 在 Windows AD 中使用仅 AES 加密创建的 Keytab

当您创建仅使用高级加密标准 (AES) 加密的 keytab 时，必须在 AD 服务器上为该账号选中**此账号支持 Kerberos AES <128/256> 位加密**复选框。复选框是 128 位还是 256 位取决于您创建 keytab 时使用的加密强度。要检查这一点，请在 Active Directory 服务器上：

1. 打开**用户和组**工具。
1. 找到您用于创建 keytab 的账号。
1. 右键单击该账号并选择**属性**。
1. 在**账号**选项卡的**账号选项**中，选中相应的 AES 加密支持复选框。
1. 保存并关闭。
