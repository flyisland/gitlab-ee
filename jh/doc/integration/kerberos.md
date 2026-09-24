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

极狐GitLab 可以与 [Kerberos](https://web.mit.edu/kerberos/) 集成作为一种认证机制。

- 您可以配置极狐GitLab，以便用户可以使用其 Kerberos 凭据登录。
- 您可以使用 Kerberos 来[防止](https://web.mit.edu/sipb/doc/working/guide/guide/node20.html)任何人拦截或窃听传输的密码。

Kerberos 仅适用于使用极狐GitLab 企业版 (EE) 的实例。如果您正在运行极狐GitLab 基础版 (CE)，您可以[从极狐GitLab CE 转换为极狐GitLab EE](../update/convert_to_ee/package.md)。

> [!warning]
> 极狐GitLab CI/CD 无法与启用了 Kerberos 的极狐GitLab 实例配合使用，除非集成[设置为使用专用端口](#http-git-access-with-kerberos-token-passwordless-authentication)。

<a id="configuration"></a>

## 配置

为了让极狐GitLab 提供基于 Kerberos 令牌的认证，请执行以下先决条件。您仍然需要为 Kerberos 使用配置系统，例如指定域。极狐GitLab 会使用系统的 Kerberos 设置。

<a id="gitlab-keytab"></a>

### 极狐GitLab keytab

1. 在您的极狐GitLab 服务器上为 HTTP 服务创建 Kerberos 服务主体。如果您的极狐GitLab 服务器是 `gitlab.example.com`，Kerberos 域是 `EXAMPLE.COM`，请在 Kerberos 数据库中创建服务主体 `HTTP/gitlab.example.com@EXAMPLE.COM`。
1. 在极狐GitLab 服务器上为该服务主体创建 keytab。例如，`/etc/http.keytab`。

keytab 是一个敏感文件，必须可由极狐GitLab 用户读取。适当设置所有权并保护该文件：

```shell
sudo chown git /etc/http.keytab
sudo chmod 0600 /etc/http.keytab
```

<a id="configure-gitlab"></a>

### 配置极狐GitLab

<a id="self-compiled-installations"></a>

#### 自编译安装

> [!note]
> 对于自编译安装，请确保 `kerberos` gem 组[已安装](../install/self_compiled/_index.md#install-gems)。

1. 编辑 [`gitlab.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example) 的 `kerberos` 部分，以启用基于 Kerberos 票据的认证。在大多数情况下，您只需要启用 Kerberos 并指定 keytab 的位置：

   ```yaml
   omniauth:
     enabled: true
     allow_single_sign_on: ['kerberos']

   kerberos:
     # 允许 Git 客户端使用 HTTP Negotiate 认证方法
     enabled: true

     # Kerberos 5 keytab 文件。该 keytab 文件必须可由极狐GitLab 用户读取，
     # 并且应与系统中的其他 keytab 不同。
     # （默认：使用 Krb5 配置中的默认 keytab）
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

   为避免极狐GitLab 在用户首次通过 Kerberos 登录时自动创建用户，请不要为 `gitlab_rails['omniauth_allow_single_sign_on']` 设置 `kerberos`。
1. [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

极狐GitLab 现在提供 `negotiate` 认证方法用于登录和 HTTP Git 访问，使支持此认证协议的 Git 客户端能够使用 Kerberos 令牌进行认证。

<a id="enable-single-sign-on"></a>

#### 启用单点登录

配置[通用设置](omniauth.md#configure-common-settings)以添加 `kerberos` 作为单点登录提供者。这将为没有现有极狐GitLab 账户的用户启用即时账户配置。

<a id="create-and-link-kerberos-accounts"></a>

## 创建和链接 Kerberos 账户

您可以将 Kerberos 账户链接到现有的极狐GitLab 账户，或者设置极狐GitLab 在 Kerberos 用户尝试登录时创建新账户。

<a id="link-a-kerberos-account-to-an-existing-gitlab-account"></a>

### 将 Kerberos 账户链接到现有的极狐GitLab 账户

{{< history >}}

- Kerberos SPNEGO 在极狐GitLab 15.4 中重命名为 Kerberos。

{{< /history >}}

如果您是管理员，可以将 Kerberos 账户链接到现有的极狐GitLab 账户。操作步骤如下：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 选择一个用户，然后选择 **身份** 选项卡。
1. 从 **提供者** 下拉列表中，选择 **Kerberos**。
1. 确保 **标识符** 与 Kerberos 用户名相对应。
1. 选择 **保存更改**。

如果您不是管理员：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码与认证**。
1. 在 **服务登录** 部分，选择 **连接 Kerberos**。
   如果您没有看到 **服务登录** Kerberos 选项，请按照[启用单点登录](#enable-single-sign-on)中的要求操作。

无论哪种情况，您现在应该能够使用 Kerberos 凭据登录您的极狐GitLab 账户。

<a id="create-accounts-on-first-sign-in"></a>

### 首次登录时创建账户

用户首次使用其 Kerberos 账户登录极狐GitLab 时，极狐GitLab 会创建匹配的账户。在继续之前，请查看 Linux 软件包和自编译实例的[通用配置设置](omniauth.md#configure-common-settings)选项。您还必须包含 `kerberos`。

掌握这些信息后：

1. 在 `allow_single_sign_on` 设置中包含 `'kerberos'`。
1. 暂时接受默认的 `block_auto_created_users` 选项，即 true。
1. 当用户尝试使用 Kerberos 凭据登录时，极狐GitLab 会创建一个新账户。
   1. 如果 `block_auto_created_users` 为 true，Kerberos 用户可能会看到类似以下的消息：

      ```shell
      您的账户已被阻止。如果您认为这是一个错误，请联系您的极狐GitLab 管理员。
      ```

      1. 作为管理员，您可以确认新的、被阻止的账户：
         1. 在右上角，选择 **管理员**。
         1. 在左侧边栏中，选择 **概览** > **用户**，并查看 **已阻止** 选项卡。
      1. 您可以启用该用户。
   1. 如果 `block_auto_created_users` 为 false，Kerberos 用户将通过认证并登录到极狐GitLab。

> [!warning]
> 我们建议您保留 `block_auto_created_users` 的默认值。
> 在管理员不知情的情况下在极狐GitLab 上创建账户的 Kerberos 用户可能构成安全风险。

<a id="link-kerberos-and-ldap-accounts-together"></a>

## 将 Kerberos 和 LDAP 账户链接在一起

如果您的用户使用 Kerberos 登录，但您还启用了 [LDAP 集成](../administration/auth/ldap/_index.md)，则您的用户在首次登录时会链接到其 LDAP 账户。为此，必须满足一些先决条件：

Kerberos 用户名必须与 LDAP 用户的 UID 匹配。您可以在极狐GitLab 的 [LDAP 配置](../administration/auth/ldap/_index.md#configure-ldap)中选择哪个 LDAP 属性用作 UID，但对于 Active Directory，应为 `sAMAccountName`。

Kerberos 域必须与 LDAP 用户的 Distinguished Name 的域部分匹配。例如，如果 Kerberos 域是 `AD.EXAMPLE.COM`，则 LDAP 用户的 Distinguished Name 应以 `dc=ad,dc=example,dc=com` 结尾。

综合来看，这些规则意味着只有当用户的 Kerberos 用户名格式为 `foo@AD.EXAMPLE.COM`，且其 LDAP Distinguished Name 类似于 `sAMAccountName=foo,dc=ad,dc=example,dc=com` 时，链接才能生效。

<a id="custom-allowed-realms"></a>

### 自定义允许的域

当用户的 Kerberos 域与用户 LDAP DN 中的域不匹配时，您可以配置自定义允许的域。配置值必须指定用户可能拥有的所有域。任何其他域将被忽略，并且不会链接 LDAP 身份。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['kerberos_simple_ldap_linking_allowed_realms'] = ['example.com','kerberos.example.com']
   ```

1. 保存文件并[重新配置](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   kerberos:
     simple_ldap_linking_allowed_realms: ['example.com','kerberos.example.com']
   ```

1. 保存文件并[重启](../administration/restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="http-git-access"></a>

## HTTP Git 访问

链接的 Kerberos 账户使您能够使用 Kerberos 账户以及标准的极狐GitLab 凭据进行 `git pull` 和 `git push`。

拥有链接的 Kerberos 账户的极狐GitLab 用户还可以使用 Kerberos 令牌进行 `git pull` 和 `git push`。也就是说，无需在每次操作时发送密码。

> [!warning]
> 存在一个[已知问题](https://github.com/curl/curl/issues/1261)，即 `libcurl` 版本低于 7.64.1 时，在协商过程中不会重用连接。这会导致当推送大于 `http.postBuffer` 配置时出现授权问题。确保 Git 至少使用 `libcurl` 7.64.1 以避免此问题。要了解已安装的 `libcurl` 版本，请运行 `curl-config --version`。

<a id="http-git-access-with-kerberos-token-passwordless-authentication"></a>

### 使用 Kerberos 令牌的 HTTP Git 访问（无密码认证）

由于[当前 Git 版本中的一个错误](https://lore.kernel.org/git/YKNVop80H8xSTCjz@coredump.intra.peff.net/T/#mab47fd7dcb61fee651f7cc8710b8edc6f62983d5)，如果 HTTP 服务器提供 `negotiate` 认证方法，`git` CLI 命令仅使用该方法，即使该方法失败（例如客户端没有 Kerberos 令牌）。因此，如果 Kerberos 认证失败，无法回退到嵌入的用户名和密码（也称为 `basic`）认证。

为了让极狐GitLab 用户能够在当前 Git 版本中使用 `basic` 或 `negotiate` 认证，可以在不同的端口（例如 `8443`）上提供基于 Kerberos 票据的认证，而标准端口仅提供 `basic` 认证。

> [!note]
> [Git 2.4 及更高版本](https://github.com/git/git/blob/master/Documentation/RelNotes/2.4.0.adoc?plain=1#L225-L228)支持在交互式或通过凭据管理器传递用户名和密码时回退到 `basic` 认证。但当用户名和密码作为 URL 的一部分传递时，则无法回退。例如，在极狐GitLab CI/CD 作业中，如果[使用 CI/CD 作业令牌进行认证](../ci/jobs/ci_job_token.md)，就可能发生这种情况。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['kerberos_use_dedicated_port'] = true
   gitlab_rails['kerberos_port'] = 8443
   gitlab_rails['kerberos_https'] = true
   ```

1. [重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自编译（源代码）使用 HTTPS" >}}

1. 编辑极狐GitLab 的 NGINX 配置文件（例如 `/etc/nginx/sites-available/gitlab-ssl`），并配置 NGINX 在标准 HTTPS 端口之外监听端口 `8443`：

   ```conf
   server {
     listen 0.0.0.0:443 ssl;
     listen [::]:443 ipv6only=on ssl default_server;
     listen 0.0.0.0:8443 ssl;
     listen [::]:8443 ipv6only=on ssl;
   ```

1. 更新 [`gitlab.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example) 的 `kerberos` 部分：

   ```yaml
   kerberos:
     # 专用端口：Git 2.4 之前的版本在 Negotiate 失败时不会回退到 Basic 认证。
     # 为了支持旧版本 Git 同时使用 Basic 和 Negotiate 方法，请配置
     # nginx 在额外端口（例如：8443）上代理极狐GitLab，并取消以下行的注释
     # 以将此端口专用于 Kerberos 认证。（默认：false）
     use_dedicated_port: true
     port: 8443
     https: true
   ```

1. [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations) 和 NGINX 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

此更改后，必须将 Git 远程 URL 更新为 `https://gitlab.example.com:8443/mygroup/myproject.git` 才能使用基于 Kerberos 票据的认证。

<a id="upgrading-from-password-based-to-ticket-based-kerberos-sign-ins"></a>

## 从基于密码的 Kerberos 登录升级到基于票据的登录

在极狐GitLab 的早期版本中，用户登录时必须向极狐GitLab 提交其 Kerberos 用户名和密码。

我们在极狐GitLab 15.0 中[移除了](https://jihulab.com/gitlab-cn/gitlab/-/issues/2908)基于密码的 Kerberos 登录。

<a id="support-for-active-directory-kerberos-environments"></a>

## 对 Active Directory Kerberos 环境的支持

在 Active Directory 域中使用基于 Kerberos 票据的认证时，可能需要增加 NGINX 允许的最大标头大小，因为 Kerberos 协议的扩展可能导致 HTTP 认证标头大于默认的 8 kB。在 [NGINX 配置](https://nginx.org/en/docs/http/ngx_http_core_module.html#large_client_header_buffers)中将 `large_client_header_buffers` 配置为更大的值。

<a id="use-keytabs-created-using-aes-only-encryption-with-windows-ad"></a>

### 使用仅 AES 加密创建的 Keytab 与 Windows AD

当您使用仅高级加密标准 (AES) 加密创建 keytab 时，必须在 AD 服务器中为该账户选中 **此账户支持 Kerberos AES <128/256> 位加密** 复选框。复选框是 128 位还是 256 位取决于创建 keytab 时使用的加密强度。要检查这一点，请在 Active Directory 服务器上：

1. 打开 **用户和组** 工具。
1. 找到用于创建 keytab 的账户。
1. 右键单击该账户并选择 **属性**。
1. 在 **账户** 选项卡的 **账户选项** 中，选中相应的 AES 加密支持复选框。
1. 保存并关闭。