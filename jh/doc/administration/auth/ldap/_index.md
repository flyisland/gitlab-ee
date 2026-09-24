---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 将 LDAP 与极狐GitLab 集成
description: 集成目录服务，实现集中式身份验证。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 与 [LDAP - 轻量级目录访问协议](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol) 集成，以支持用户身份验证。

此集成适用于大多数符合 LDAP 标准的目录服务器，包括：

- Microsoft Active Directory。
- Apple Open Directory。
- OpenLDAP。
- 389 Server。

> [!note]
> 极狐GitLab 不支持 [Microsoft Active Directory 信任](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc771568(v=ws.10))。

通过 LDAP 添加的用户：

- 通常使用[许可席位](../../../subscriptions/manage_seats.md#billable-users)。
- 可以使用其极狐GitLab 用户名或邮箱以及 LDAP 密码通过 Git 进行身份验证，即使 Git 的密码身份验证
  [已禁用](../../settings/sign_in_restrictions.md#allow-password-authentication-for-git-over-https)。

当以下情况发生时，LDAP 专有名称（DN）会与现有极狐GitLab 用户关联：

- 现有用户首次使用 LDAP 登录极狐GitLab。
- LDAP 邮箱地址是现有极狐GitLab 用户的主邮箱地址。如果在极狐GitLab 用户数据库中未找到 LDAP 邮箱属性，则会创建一个新用户。

如果现有极狐GitLab 用户希望为自己启用 LDAP 登录，他们应该：

1. 检查其极狐GitLab 邮箱地址是否与其 LDAP 邮箱地址匹配。
1. 使用其 LDAP 凭据登录极狐GitLab。

> [!note]
> 用户将其 LDAP 身份链接到极狐GitLab 账户后，将无法再使用标准的用户名和密码身份验证流程。相反，用户必须使用其 LDAP 凭据进行身份验证。尝试使用用户名和密码身份验证登录将返回[无效的登录名或密码错误](ldap-troubleshooting.md#users-see-an-error-invalid-login-or-password)。

<a id="security"></a>

## 安全性

极狐GitLab 会验证用户是否仍在 LDAP 中处于活动状态。

当用户出现以下情况时，会被视为在 LDAP 中处于非活动状态：

- 被完全从目录中移除。
- 位于配置的 `base` DN 或 `user_filter` 搜索范围之外。
- 在 Active Directory 中通过用户账户控制属性被标记为禁用或停用。这意味着属性
  `userAccountControl:1.2.840.113556.1.4.803` 的第 2 位已设置。

要检查用户在 LDAP 中是处于活动还是非活动状态，请使用以下 PowerShell 命令和 [Active Directory 模块](https://learn.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2022-ps) 检查 Active Directory：

```powershell
Get-ADUser -Identity <username> -Properties userAccountControl | Select-Object Name, userAccountControl
```

极狐GitLab 会检查 LDAP 用户的状态：

- 使用任何身份验证提供程序登录时。
- 对于使用令牌或 SSH 密钥的活动 Web 会话或 Git 请求，每小时检查一次。
- 使用 LDAP 用户名和密码执行基于 HTTP 的 Git 请求时。
- 在[用户同步](ldap_synchronization.md#user-sync)期间每天检查一次。

如果用户不再在 LDAP 中处于活动状态，他们将：

- 被注销。
- 被置于 `ldap_blocked` 状态。
- 在 LDAP 中重新激活之前，无法使用任何身份验证提供程序登录。

<a id="security-risks"></a>

### 安全风险

仅当您的 LDAP 用户无法执行以下操作时，才应使用 LDAP 集成：

- 更改其在 LDAP 服务器上的 `mail`、`email` 或 `userPrincipalName` 属性。这些用户可能会接管您极狐GitLab 服务器上的任何账户。
- 共享邮箱地址。具有相同邮箱地址的 LDAP 用户可以共享同一个极狐GitLab 账户。

<a id="configure-ldap"></a>

## 配置 LDAP

先决条件：

- 您必须拥有一个邮箱地址才能使用 LDAP，无论您是否使用该邮箱地址登录。

要配置 LDAP，您需要编辑配置文件中的设置：

- 您的配置文件必须包含以下[基本配置设置](#basic-configuration-settings)：
  - `label`
  - `host`
  - `port`
  - `uid`
  - `base`
  - `encryption`
- 您可以在配置文件中包含以下可选设置：
  - [可选的基本配置设置](#basic-configuration-settings)。
  - [SSL 设置](#ssl-configuration-settings)。
  - [属性设置](#attribute-configuration-settings)。
  - [LDAP 同步设置](#ldap-sync-configuration-settings)。
- 您还可以将 LDAP 配置为：
  - [使用多个服务器](#use-multiple-ldap-servers)。
  - [筛选用户](#set-up-ldap-user-filter)。
  - [自动将 LDAP 用户名转换为小写](#enable-ldap-username-lowercase)。
  - [禁用 LDAP Web 登录](#disable-ldap-web-sign-in)。
  - [为极狐GitLab 提供智能卡身份验证](#provide-smart-card-authentication-for-gitlab)
  - [使用加密凭据](#use-encrypted-credentials)。

您编辑的文件因极狐GitLab 设置而异：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_enabled'] = true
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'label' => 'LDAP',
       'host' => 'ldap.mydomain.com',
       'port' => 636,
       'uid' => 'sAMAccountName',
       'bind_dn' => 'CN=Gitlab,OU=Users,DC=domain,DC=com',
       'password' => '<bind_user_password>',
       'encryption' => 'simple_tls',
       'verify_certificates' => true,
       'timeout' => 10,
       'active_directory' => false,
       'user_filter' => '(employeeType=developer)',
       'base' => 'dc=example,dc=com',
       'lowercase_usernames' => 'false',
       'retry_empty_result_with_codes' => [80],
       'allow_username_or_email_login' => false,
       'block_auto_created_users' => false
     }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             label: 'LDAP'
             host: 'ldap.mydomain.com'
             port: 636
             uid: 'sAMAccountName'
             bind_dn: 'CN=Gitlab,OU=Users,DC=domain,DC=com'
             password: '<bind_user_password>'
             encryption: 'simple_tls'
             verify_certificates: true
             timeout: 10
             active_directory: false
             user_filter: '(employeeType=developer)'
             base: 'dc=example,dc=com'
             lowercase_usernames: false
             retry_empty_result_with_codes: [80]
             allow_username_or_email_login: false
             block_auto_created_users: false
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

有关更多信息，请参阅
[如何为使用 Helm chart 安装的极狐GitLab 实例配置 LDAP](https://gitlab.cn/docs/charts/charts/globals/#ldap)。

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_enabled'] = true
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'label' => 'LDAP',
               'host' => 'ldap.mydomain.com',
               'port' => 636,
               'uid' => 'sAMAccountName',
               'bind_dn' => 'CN=Gitlab,OU=Users,DC=domain,DC=com',
               'password' => '<bind_user_password>',
               'encryption' => 'simple_tls',
               'verify_certificates' => true,
               'timeout' => 10,
               'active_directory' => false,
               'user_filter' => '(employeeType=developer)',
               'base' => 'dc=example,dc=com',
               'lowercase_usernames' => 'false',
               'retry_empty_result_with_codes' => [80],
               'allow_username_or_email_login' => false,
               'block_auto_created_users' => false
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       enabled: true
       servers:
         main:
           label: 'LDAP'
           host: 'ldap.mydomain.com'
           port: 636
           uid: 'sAMAccountName'
           bind_dn: 'CN=Gitlab,OU=Users,DC=domain,DC=com'
           password: '<bind_user_password>'
           encryption: 'simple_tls'
           verify_certificates: true
           timeout: 10
           active_directory: false
           user_filter: '(employeeType=developer)'
           base: 'dc=example,dc=com'
           lowercase_usernames: false
           retry_empty_result_with_codes: [80]
           allow_username_or_email_login: false
           block_auto_created_users: false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

有关各种 LDAP 选项的更多信息，请参阅
[`gitlab.yml.example`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example) 中的 `ldap` 设置。

{{< /tab >}}

{{< /tabs >}}

配置 LDAP 后，要测试配置，请使用
[LDAP 检查 Rake 任务](../../raketasks/ldap.md#check)。

<a id="basic-configuration-settings"></a>

### 基本配置设置

以下基本设置可用：

| 设置                         | 必需    | 类型                          | 描述 |
|---------------------------------|-------------|-------------------------------|-------------|
| `label`                         | {{< yes >}} | 字符串                        | 您的 LDAP 服务器的友好名称。它显示在您的登录页面上。示例：`'Paris'` 或 `'Acme, Ltd.'` |
| `host`                          | {{< yes >}} | 字符串                        | 您的 LDAP 服务器的 IP 地址或域名。当定义了 `hosts` 时忽略。示例：`'ldap.mydomain.com'` |
| `port`                          | {{< yes >}} | 整数                       | 用于连接您的 LDAP 服务器的端口。当定义了 `hosts` 时忽略。示例：`389` 或 `636`（用于 SSL） |
| `uid`                           | {{< yes >}} | 字符串                        | 映射到用户用于登录的用户名的 LDAP 属性。应为属性，而不是映射到 `uid` 的值。不影响极狐GitLab 用户名（请参阅[属性部分](#attribute-configuration-settings)）。示例：`'sAMAccountName'` 或 `'uid'` 或 `'userPrincipalName'` |
| `base`                          | {{< yes >}} | 字符串                        | 我们可以在其中搜索用户的基础。示例：`'ou=people,dc=gitlab,dc=example'` 或 `'DC=mydomain,DC=com'` |
| `encryption`                    | {{< yes >}} | 字符串                        | 加密方法（`method` 键已弃用，推荐使用 `encryption`）。它可以具有以下三个值之一：`'start_tls'`、`'simple_tls'` 或 `'plain'`。`simple_tls` 对应于 LDAP 库中的“Simple TLS”。`start_tls` 对应于 StartTLS，不要与常规 TLS 混淆。如果您指定 `simple_tls`，通常使用端口 636，而 `start_tls`（StartTLS）则使用端口 389。`plain` 也在端口 389 上运行。 |
| `hosts`                         | {{< no >}}  | 字符串和整数数组 | 用于打开连接的主机和端口对数组。每个配置的服务器都应具有相同的数据集。这并非用于配置多个不同的 LDAP 服务器，而是用于配置故障转移。主机按配置顺序尝试。示例：`[['ldap1.mydomain.com', 636], ['ldap2.mydomain.com', 636]]` |
| `bind_dn`                       | {{< no >}}  | 字符串                        | 您绑定的用户的完整 DN。示例：`'america\momo'` 或 `'CN=Gitlab,OU=Users,DC=domain,DC=com'` |
| `password`                      | {{< no >}}  | 字符串                        | 绑定用户的密码。 |
| `verify_certificates`           | {{< no >}}  | 布尔值                       | 默认为 `true`。如果加密方法为 `start_tls` 或 `simple_tls`，则启用 SSL 证书验证。如果设置为 `false`，则不执行对 LDAP 服务器 SSL 证书的验证。 |
| `timeout`                       | {{< no >}}  | 整数                       | 默认为 `10`。为 LDAP 查询设置超时时间（以秒为单位）。这有助于避免在 LDAP 服务器无响应时阻塞请求。值为 `0` 表示没有超时。 |
| `active_directory`              | {{< no >}}  | 布尔值                       | 此设置指定 LDAP 服务器是否为 Active Directory LDAP 服务器。对于非 AD 服务器，它会跳过 AD 特定查询。如果您的 LDAP 服务器不是 AD，请将此设置为 false。 |
| `allow_username_or_email_login` | {{< no >}}  | 布尔值                       | 默认为 `false`。如果启用，极狐GitLab 会忽略用户在登录时提交的 LDAP 用户名中第一个 `@` 之后的所有内容。如果您在 ActiveDirectory 上使用 `uid: 'userPrincipalName'`，则必须禁用此设置，因为 `userPrincipalName` 包含 `@`。 |
| `block_auto_created_users`      | {{< no >}}  | 布尔值                       | 默认为 `false`。为了严格控制极狐GitLab 安装上的可计费用户数量，请启用此设置以保持新用户处于阻止状态，直到管理员批准。 |
| `user_filter`                   | {{< no >}}  | 字符串                        | 筛选 LDAP 用户。遵循 [RFC 4515](https://www.rfc-editor.org/rfc/rfc4515.html) 的格式。极狐GitLab 不支持 `omniauth-ldap` 的自定义筛选语法。`user_filter` 字段语法示例：<br/><br/>- `'(employeeType=developer)'`<br/>- `'(&(objectclass=user)(\|(samaccountname=momo)(samaccountname=toto)))'` |
| `lowercase_usernames`           | {{< no >}}  | 布尔值                       | 如果启用，极狐GitLab 会将名称转换为小写。 |
| `retry_empty_result_with_codes` | {{< no >}}  | 数组                         | 一个 LDAP 查询响应代码数组，如果结果/内容为空，则尝试重试该操作。对于 Google Secure LDAP，请将此值设置为 `[80]`。 |

> [!note]
> 极狐GitLab 不受 [Microsoft 公告 ADV190023](https://msrc.microsoft.com/update-guide/en-us/advisory/ADV190023) 中引入的 Microsoft Active Directory 服务更严格的绑定要求的影响。有关更多信息，请参阅[议题 201894](https://gitlab.com/gitlab-org/gitlab/-/issues/201894#note_2807513217)。

<a id="ssl-configuration-settings"></a>

### SSL 配置设置

您可以在 `tls_options` 名称/值对下配置 SSL 配置设置。以下设置均为可选：

| 设置       | 描述 | 示例 |
|---------------|-------------|----------|
| `ca_file`     | 指定包含 PEM 格式 CA 证书的文件的路径，例如，如果您需要内部 CA。 | `'/etc/ca.pem'` |
| `ssl_version` | 指定 OpenSSL 使用的 SSL 版本，如果 OpenSSL 默认值不合适。 | `'TLSv1_1'` |
| `ciphers`     | 与 LDAP 服务器通信时使用的特定 SSL 密码算法。 | `'ALL:!EXPORT:!LOW:!aNULL:!eNULL:!SSLv2'` |
| `cert`        | 客户端证书。 | `'-----BEGIN CERTIFICATE----- <REDACTED> -----END CERTIFICATE -----'` |
| `key`         | 客户端私钥。 | `'-----BEGIN PRIVATE KEY----- <REDACTED> -----END PRIVATE KEY -----'` |

以下示例说明了如何在 `tls_options` 中设置 `ca_file` 和 `ssl_version`：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_enabled'] = true
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'label' => 'LDAP',
       'host' => 'ldap.mydomain.com',
       'port' => 636,
       'uid' => 'sAMAccountName',
       'encryption' => 'simple_tls',
       'base' => 'dc=example,dc=com',
       'tls_options' => {
         'ca_file' => '/path/to/ca_file.pem',
         'ssl_version' => 'TLSv1_2'
       }
     }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             label: 'LDAP'
             host: 'ldap.mydomain.com'
             port: 636
             uid: 'sAMAccountName'
             base: 'dc=example,dc=com'
             encryption: 'simple_tls'
             tls_options:
               ca_file: '/path/to/ca_file.pem'
               ssl_version: 'TLSv1_2'
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

有关更多信息，请参阅
[如何为使用 Helm chart 安装的极狐GitLab 实例配置 LDAP](https://gitlab.cn/docs/charts/charts/globals/#ldap)。

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_enabled'] = true
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'label' => 'LDAP',
               'host' => 'ldap.mydomain.com',
               'port' => 636,
               'uid' => 'sAMAccountName',
               'encryption' => 'simple_tls',
               'base' => 'dc=example,dc=com',
               'tls_options' => {
                 'ca_file' => '/path/to/ca_file.pem',
                 'ssl_version' => 'TLSv1_2'
               }
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       enabled: true
       servers:
         main:
           label: 'LDAP'
           host: 'ldap.mydomain.com'
           port: 636
           uid: 'sAMAccountName'
           encryption: 'simple_tls'
           base: 'dc=example,dc=com'
           tls_options:
             ca_file: '/path/to/ca_file.pem'
             ssl_version: 'TLSv1_2'
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

<a id="attribute-configuration-settings"></a>

### 属性配置设置

极狐GitLab 使用这些 LDAP 属性为 LDAP 用户创建账户。指定的属性可以是：

- 作为字符串的属性名称。例如，`'mail'`。
- 按顺序尝试的属性名称数组。例如，`['mail', 'email']`。

用户的 LDAP 登录名是 [指定为 `uid`](#basic-configuration-settings) 的 LDAP 属性。

以下所有 LDAP 属性都是可选的。您只需指定与默认值不同的属性。如果您指定了一个，例如 `username`，则无需指定其他属性。将应用默认值。

如果您定义了其中任何一个，则必须在 `attributes` 哈希中定义。

| 设置      | 描述 | 默认值 |
|--------------|-------------|----------|
| `username`   | 极狐GitLab 账户将预配的 `@username`。如果该值包含邮箱地址，则极狐GitLab 用户名是邮箱地址中 `@` 之前的部分。 | 默认为 [指定为 `uid`](#basic-configuration-settings) 的 LDAP 属性（`['uid', 'userid', 'sAMAccountName']`）。 |
| `email`      | 用户邮箱的 LDAP 属性。 | `['mail', 'email', 'userPrincipalName']` |
| `name`       | 用户显示名称的 LDAP 属性。如果 `name` 为空，则全名取自 `first_name` 和 `last_name`。属性 `'cn'` 或 `'displayName'` 通常包含全名。或者，您可以通过指定不存在的属性（例如 `'somethingNonExistent'`）来强制使用 `first_name` 和 `last_name`。 | `'cn'` |
| `first_name` | 用户名字的 LDAP 属性。当为 `name` 配置的属性不存在时使用。 | `'givenName'` |
| `last_name`  | 用户姓氏的 LDAP 属性。当为 `name` 配置的属性不存在时使用。 | `'sn'` |

使用 `displayName` 作为用户名称以及属性数组作为 `email` 的示例配置：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       # Other configuration settings ...
       'attributes' => {
         'username' => 'uid',
         'email' => ['mail', 'email', 'userPrincipalName'],
         'name' => 'displayName',
         'first_name' => 'givenName',
         'last_name' => 'sn'
       }
     }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             # Other configuration settings ...
             attributes:
               username: 'uid'
               email:
                 - 'mail'
                 - 'email'
                 - 'userPrincipalName'
               name: 'displayName'
               first_name: 'givenName'
               last_name: 'sn'
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               # Other configuration settings ...
               'attributes' => {
                 'username' => 'uid',
                 'email' => ['mail', 'email', 'userPrincipalName'],
                 'name' => 'displayName',
                 'first_name' => 'givenName',
                 'last_name' => 'sn'
               }
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       servers:
         main:
           # Other configuration settings ...
           attributes:
             username: 'uid'
             email:
               - 'mail'
               - 'email'
               - 'userPrincipalName'
             name: 'displayName'
             first_name: 'givenName'
             last_name: 'sn'
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

<a id="ldap-sync-configuration-settings"></a>

### LDAP 同步配置设置

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这些 LDAP 同步配置设置是可选的，但 `group_base` 除外，当配置了 `external_groups` 时，它是必需的：

| 设置           | 描述 | 示例 |
|-------------------|-------------|----------|
| `group_base`      | 用于搜索群组的基础。所有有效群组都将此基础作为其 DN 的一部分。 | `'ou=groups,dc=gitlab,dc=example'` |
| `admin_group`     | 包含极狐GitLab 管理员的群组的 CN。不是 `cn=administrators` 或完整 DN。 | `'administrators'` |
| `audit_group`     | 包含极狐GitLab 审计员的群组的 CN。不是 `cn=auditors` 或完整 DN。 | `'auditors'` |
| `external_groups` | 包含应被视为外部用户的群组的 CN 数组。不是 `cn=interns` 或完整 DN。 | `['interns', 'contractors']` |
| `sync_ssh_keys`   | 包含用户公共 SSH 密钥的 LDAP 属性。 | `'sshPublicKey'` 或 false（如果未设置） |

> [!note]
> 如果 Sidekiq 配置在与 Rails 服务器不同的服务器上，您还必须将 LDAP 配置添加到每个 Sidekiq 服务器，LDAP 同步才能正常工作。

<a id="use-multiple-ldap-servers"></a>

### 使用多个 LDAP 服务器

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您的用户位于多个 LDAP 服务器上，您可以配置极狐GitLab 使用它们。要添加其他 LDAP 服务器：

1. 复制[`main` LDAP 配置](#configure-ldap)。
1. 使用其他服务器的详细信息编辑每个复制的配置。
   - 对于每个其他服务器，选择一个不同的提供程序 ID，例如 `main`、`secondary` 或 `tertiary`。使用小写字母数字字符。极狐GitLab 使用提供程序 ID 将每个用户与特定的 LDAP 服务器关联。
   - 对于每个条目，使用唯一的 `label` 值。这些值用于登录页面上的选项卡名称。

以下示例演示了如何使用最小配置来配置三个 LDAP 服务器：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_enabled'] = true
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'label' => 'GitLab AD',
       'host' => 'ad.mydomain.com',
       'port' => 636,
       'uid' => 'sAMAccountName',
       'encryption' => 'simple_tls',
       'base' => 'dc=example,dc=com',
     },

     'secondary' => {
       'label' => 'GitLab Secondary AD',
       'host' => 'ad-secondary.mydomain.com',
       'port' => 636,
       'uid' => 'sAMAccountName',
       'encryption' => 'simple_tls',
       'base' => 'dc=example,dc=com',
     },

     'tertiary' => {
       'label' => 'GitLab Tertiary AD',
       'host' => 'ad-tertiary.mydomain.com',
       'port' => 636,
       'uid' => 'sAMAccountName',
       'encryption' => 'simple_tls',
       'base' => 'dc=example,dc=com',
     }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             label: 'GitLab AD'
             host: 'ad.mydomain.com'
             port: 636
             uid: 'sAMAccountName'
             base: 'dc=example,dc=com'
             encryption: 'simple_tls'
           secondary:
             label: 'GitLab Secondary AD'
             host: 'ad-secondary.mydomain.com'
             port: 636
             uid: 'sAMAccountName'
             base: 'dc=example,dc=com'
             encryption: 'simple_tls'
           tertiary:
             label: 'GitLab Tertiary AD'
             host: 'ad-tertiary.mydomain.com'
             port: 636
             uid: 'sAMAccountName'
             base: 'dc=example,dc=com'
             encryption: 'simple_tls'
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_enabled'] = true
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'label' => 'GitLab AD',
               'host' => 'ad.mydomain.com',
               'port' => 636,
               'uid' => 'sAMAccountName',
               'encryption' => 'simple_tls',
               'base' => 'dc=example,dc=com',
             },

             'secondary' => {
               'label' => 'GitLab Secondary AD',
               'host' => 'ad-secondary.mydomain.com',
               'port' => 636,
               'uid' => 'sAMAccountName',
               'encryption' => 'simple_tls',
               'base' => 'dc=example,dc=com',
             },

             'tertiary' => {
               'label' => 'GitLab Tertiary AD',
               'host' => 'ad-tertiary.mydomain.com',
               'port' => 636,
               'uid' => 'sAMAccountName',
               'encryption' => 'simple_tls',
               'base' => 'dc=example,dc=com',
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       enabled: true
       servers:
         main:
           label: 'GitLab AD'
           host: 'ad.mydomain.com'
           port: 636
           uid: 'sAMAccountName'
           base: 'dc=example,dc=com'
           encryption: 'simple_tls'
         secondary:
           label: 'GitLab Secondary AD'
           host: 'ad-secondary.mydomain.com'
           port: 636
           uid: 'sAMAccountName'
           base: 'dc=example,dc=com'
           encryption: 'simple_tls'
         tertiary:
           label: 'GitLab Tertiary AD'
           host: 'ad-tertiary.mydomain.com'
           port: 636
           uid: 'sAMAccountName'
           base: 'dc=example,dc=com'
           encryption: 'simple_tls'
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

有关各种 LDAP 选项的更多信息，请参阅
[`gitlab.yml.example`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example) 中的 `ldap` 设置。

{{< /tab >}}

{{< /tabs >}}

此示例将生成一个包含以下选项卡的登录页面：

- **极狐GitLab AD**。
- **极狐GitLab Secondary AD**。
- **极狐GitLab Tertiary AD**。

<a id="set-up-ldap-user-filter"></a>

### 设置 LDAP 用户筛选器

要将所有极狐GitLab 访问权限限制为 LDAP 服务器上 LDAP 用户的子集，首先缩小配置的 `base`。但是，如有必要，要进一步筛选用户，您可以设置 LDAP 用户筛选器。该筛选器必须符合 [RFC 4515](https://www.rfc-editor.org/rfc/rfc4515.html)。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'user_filter' => '(employeeType=developer)'
     }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             user_filter: '(employeeType=developer)'
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'user_filter' => '(employeeType=developer)'
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ldap:
       servers:
         main:
           user_filter: '(employeeType=developer)'
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

要限制对 Active Directory 群组嵌套成员的访问，请使用以下语法：

```plaintext
(memberOf:1.2.840.113556.1.4.1941:=CN=My Group,DC=Example,DC=com)
```

有关 `LDAP_MATCHING_RULE_IN_CHAIN` 筛选器的更多信息，请参阅
[搜索筛选器语法](https://learn.microsoft.com/en-us/windows/win32/adsi/search-filter-syntax)。

用户筛选器中对嵌套成员的支持不应与
[群组同步嵌套群组](ldap_synchronization.md#supported-ldap-group-typesattributes) 支持混淆。

极狐GitLab 不支持 OmniAuth LDAP 使用的自定义筛选器语法。

<a id="escape-special-characters-in-user_filter"></a>

#### 在 `user_filter` 中转义特殊字符

`user_filter` DN 可以包含特殊字符。例如：

- 逗号：

  ```plaintext
  OU=GitLab, Inc,DC=gitlab,DC=com
  ```

- 开括号和闭括号：

  ```plaintext
  OU=GitLab (Inc),DC=gitlab,DC=com
  ```

这些字符必须按照
[RFC 4515](https://www.rfc-editor.org/rfc/rfc4515.html#section-4) 中的文档进行转义。

- 使用 `\2C` 转义逗号。例如：

  ```plaintext
  OU=GitLab\2C Inc,DC=gitlab,DC=com
  ```

- 使用 `\28` 转义开括号，使用 `\29` 转义闭括号。例如：

  ```plaintext
  OU=GitLab \28Inc\29,DC=gitlab,DC=com
  ```

<a id="enable-ldap-username-lowercase"></a>

### 启用 LDAP 用户名小写化

某些 LDAP 服务器（取决于其配置）可能返回大写用户名。这可能导致一些令人困惑的问题，例如创建具有大写名称的链接或命名空间。

极狐GitLab 可以通过启用配置选项 `lowercase_usernames` 来自动将 LDAP 服务器提供的用户名转换为小写。默认情况下，此配置选项为 `false`。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = {
     'main' => {
       'lowercase_usernames' => true
     }
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         servers:
           main:
             lowercase_usernames: true
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'lowercase_usernames' => true
             }
           }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `config/gitlab.yaml`：

   ```yaml
   production:
     ldap:
       servers:
         main:
           lowercase_usernames: true
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

<a id="disable-ldap-web-sign-in"></a>

### 禁用 LDAP Web 登录

当首选 SAML 等替代方案时，阻止通过 Web UI 使用 LDAP 凭据可能很有用。这允许 LDAP 用于群组同步，同时允许您的 SAML 身份提供程序处理其他检查，例如自定义 2FA。

当 LDAP Web 登录被禁用时，用户不会在登录页面上看到 **LDAP** 选项卡。这不会禁用使用 LDAP 凭据进行 Git 访问。

禁用 LDAP Web 登录不会阻止这些用户访问 Web UI：他们仍然可以使用极狐GitLab 密码登录。要仅要求通过您的身份提供程序登录，还请
[为具有 SSO 身份的用户禁用密码和通行密钥身份验证](../../settings/sign_in_restrictions.md#disable-password-and-passkey-authentication-for-users-with-an-sso-identity)。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['prevent_ldap_sign_in'] = true
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       ldap:
         preventSignin: true
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['prevent_ldap_sign_in'] = true
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 编辑 `config/gitlab.yaml`：

   ```yaml
   production:
     ldap:
       prevent_ldap_sign_in: true
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

<a id="provide-smart-card-authentication-for-gitlab"></a>

### 为极狐GitLab 提供智能卡身份验证

有关将智能卡与 LDAP 服务器和极狐GitLab 一起使用的更多信息，请参阅[智能卡身份验证](../smartcard.md)。

<a id="use-encrypted-credentials"></a>

### 使用加密凭据

您可以选择使用加密文件存储 LDAP 凭据，而不是将 LDAP 集成凭据以明文形式存储在配置文件中。

先决条件：

- 要使用加密凭据，您必须首先启用
  [加密配置](../../encrypted_configuration.md)。

LDAP 的加密配置存在于加密的 YAML 文件中。该文件的未加密内容应为 LDAP 配置中 `servers` 块的密钥设置的子集。

加密文件支持的配置项包括：

- `bind_dn`
- `password`

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 如果最初您在 `/etc/gitlab/gitlab.rb` 中的 LDAP 配置如下所示：

   ```ruby
     gitlab_rails['ldap_servers'] = {
       'main' => {
         'bind_dn' => 'admin',
         'password' => '123'
       }
     }
   ```

1. 编辑加密的密钥：

   ```shell
   sudo gitlab-rake gitlab:ldap:secret:edit EDITOR=vim
   ```

1. 输入 LDAP 密钥的未加密内容：

   ```yaml
   main:
     bind_dn: admin
     password: '123'
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并删除 `bind_dn` 和 `password` 的设置。
1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes 密钥存储 LDAP 密码。有关更多信息，
请阅读 [Helm LDAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#ldap-password)。

{{< /tab >}}

{{< tab title="Docker" >}}

1. 如果最初您在 `docker-compose.yml` 中的 LDAP 配置如下所示：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['ldap_servers'] = {
             'main' => {
               'bind_dn' => 'admin',
               'password' => '123'
             }
           }
   ```

1. 进入容器内部，并编辑加密的密钥：

   ```shell
   sudo docker exec -t <container_name> bash
   gitlab-rake gitlab:ldap:secret:edit EDITOR=vim
   ```

1. 输入 LDAP 密钥的未加密内容：

   ```yaml
   main:
     bind_dn: admin
     password: '123'
   ```

1. 编辑 `docker-compose.yml` 并删除 `bind_dn` 和 `password` 的设置。
1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 如果最初您在 `/home/git/gitlab/config/gitlab.yml` 中的 LDAP 配置如下所示：

   ```yaml
   production:
     ldap:
       servers:
         main:
           bind_dn: admin
           password: '123'
   ```

1. 编辑加密的密钥：

   ```shell
   bundle exec rake gitlab:ldap:secret:edit EDITOR=vim RAILS_ENVIRONMENT=production
   ```

1. 输入 LDAP 密钥的未加密内容：

   ```yaml
   main:
    bind_dn: admin
    password: '123'
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并删除 `bind_dn` 和 `password` 的设置。
1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="updating-ldap-dn-and-email"></a>

## 更新 LDAP DN 和邮箱

当 LDAP 服务器在极狐GitLab 中创建用户时，用户的 LDAP DN 会作为标识符链接到其极狐GitLab 账户。

当用户尝试使用 LDAP 登录时，极狐GitLab 会尝试使用该用户账户上保存的 DN 查找用户。

- 如果极狐GitLab 通过 DN 找到用户，并且用户的邮箱地址：
  - 与极狐GitLab 账户的邮箱地址匹配，则极狐GitLab 不采取进一步操作。
  - 已更改，则极狐GitLab 会更新其记录的用户邮箱以匹配 LDAP 中的邮箱。
- 如果极狐GitLab 无法通过 DN 找到用户，它会尝试通过邮箱查找用户。如果极狐GitLab：
  - 通过邮箱找到用户，则极狐GitLab 会更新存储在用户极狐GitLab 账户中的 DN。现在两个值都与 LDAP 中存储的信息匹配。
  - 无法通过邮箱地址找到用户（DN 和邮箱地址都已更改），请参阅
    [用户 DN 和邮箱已更改](ldap-troubleshooting.md#user-dn-and-email-have-changed)。

<a id="disable-anonymous-ldap-authentication"></a>

## 禁用匿名 LDAP 身份验证

极狐GitLab 不支持 TLS 客户端身份验证。请在您的 LDAP 服务器上完成以下步骤。

1. 禁用匿名身份验证。
1. 启用以下身份验证类型之一：
   - 简单身份验证。
   - 简单身份验证和安全层（SASL）身份验证。

您的 LDAP 服务器中的 TLS 客户端身份验证设置不能是强制性的，并且客户端不能通过 TLS 协议进行身份验证。

<a id="users-deleted-from-ldap"></a>

## 从 LDAP 中删除的用户

从 LDAP 服务器中删除的用户：

- 会立即被阻止登录极狐GitLab。
- [不再消耗许可证](../../moderate_users.md)。

但是，这些用户可以继续使用 SSH 进行 Git 操作，直到下次
[LDAP 检查缓存运行](ldap_synchronization.md#adjust-ldap-sync-schedule)。

要立即删除账户，您可以手动
[阻止该用户](../../moderate_users.md#block-a-user)。

<a id="update-user-email-addresses"></a>

## 更新用户邮箱地址

当使用 LDAP 登录时，LDAP 服务器上的邮箱地址被视为用户的真实信息来源。

更新用户邮箱地址必须在管理该用户的 LDAP 服务器上完成。极狐GitLab 的邮箱地址在以下任一情况下更新：

- 用户下次登录时。
- 下次运行[用户同步](ldap_synchronization.md#user-sync)时。

更新后的用户之前的邮箱地址将成为次要邮箱地址，以保留该用户的提交历史。

您可以在我们的 [LDAP 故障排查部分](ldap-troubleshooting.md#user-dn-and-email-have-changed) 中找到有关用户更新预期行为的更多详细信息。

<a id="google-secure-ldap"></a>

## Google Secure LDAP

[Google Cloud Identity](https://cloud.google.com/identity/) 提供 Secure LDAP 服务，可以配置为与极狐GitLab 一起用于身份验证和群组同步。有关详细的配置说明，请参阅 [Google Secure LDAP](google_secure_ldap.md)。

<a id="synchronize-users-and-groups"></a>

## 同步用户和群组

有关在 LDAP 和极狐GitLab 之间同步用户和群组的更多信息，请参阅
[LDAP 同步](ldap_synchronization.md)。

<a id="move-from-ldap-to-saml"></a>

## 从 LDAP 迁移到 SAML

1. [添加 SAML 配置](../../../integration/saml.md) 到：
   - [Linux 软件包安装的 `gitlab.rb`](../../../integration/saml.md)。
   - [Helm chart 安装的 `values.yml`](../../../integration/saml.md)。

1. 可选。[从登录页面禁用 LDAP 身份验证](#disable-ldap-web-sign-in)。
1. 可选。要修复链接用户的问题，您可以先[移除这些用户的 LDAP 身份](ldap-troubleshooting.md#remove-the-identity-records-that-relate-to-the-removed-ldap-server)。
1. 确认用户能够登录其账户。如果用户无法登录，请检查该用户的 LDAP 是否仍然存在，并在必要时将其移除。如果此问题仍然存在，请检查日志以识别问题。
1. 在配置文件中，更改：
   - 将 `omniauth_auto_link_user` 仅更改为 `saml`。
   - 将 `omniauth_auto_link_ldap_user` 更改为 false。
   - 将 `ldap_enabled` 更改为 `false`。
     您也可以注释掉 LDAP 提供程序设置。

<a id="troubleshooting"></a>

## 故障排查

请参阅我们的 [LDAP 故障排查管理员指南](ldap-troubleshooting.md)。
