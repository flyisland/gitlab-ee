---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 将 LDAP 与极狐GitLab 集成
description: 集成目录服务以实现集中式身份验证。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 与 [LDAP - 轻量目录访问协议](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol)集成，以支持用户身份验证。

此集成适用于大多数兼容 LDAP 的目录服务器，包括：

- Microsoft Active Directory。
- Apple Open Directory。
- OpenLDAP。
- 389 Server。

> [!note]
> 极狐GitLab 不支持 [Microsoft Active Directory 信任](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc771568(v=ws.10))。

通过 LDAP 添加的用户：

- 通常使用[已授权的席位](../../../subscriptions/manage_seats.md#billable-users)。
- 可以使用其极狐GitLab 用户名，或使用其电子邮件和 LDAP 密码通过 Git 进行身份验证，
  即使 Git 的密码身份验证
  [已禁用](../../settings/sign_in_restrictions.md#allow-password-authentication-for-git-over-https)。

在以下情况下，LDAP 可分辨名称（DN）会与现有极狐GitLab 用户关联：

- 现有用户首次使用 LDAP 登录极狐GitLab 时。
- LDAP 电子邮件地址是现有极狐GitLab 用户的主电子邮件地址时。如果在极狐GitLab 用户数据库中
  找不到 LDAP 电子邮件属性，则会创建一个新用户。

如果现有极狐GitLab 用户希望为自己启用 LDAP 登录，应：

1. 检查其极狐GitLab 电子邮件地址是否与其 LDAP 电子邮件地址匹配。
1. 使用其 LDAP 凭据登录极狐GitLab。

> [!note]
> 用户将 LDAP 身份关联到其极狐GitLab 账号后，就无法再使用标准的
> 用户名和密码身份验证流程。用户必须改用其 LDAP
> 凭据进行身份验证。尝试使用用户名和密码身份验证登录时，会返回
> [无效的登录名或密码错误](ldap-troubleshooting.md#users-see-an-error-invalid-login-or-password)。

<a id="security"></a>

## 安全性

极狐GitLab 会验证用户在 LDAP 中是否仍处于活动状态。

当用户出现以下情况时，会被视为在 LDAP 中处于非活动状态：

- 被完全从目录中移除。
- 位于配置的 `base` DN 或 `user_filter` 搜索范围之外。
- 在 Active Directory 中通过用户账户控制属性被标记为已禁用或已停用。这意味着属性
  `userAccountControl:1.2.840.113556.1.4.803`的第 2 位已设置。

要检查用户在 LDAP 中是活动还是非活动状态，请使用以下 PowerShell 命令和 [Active Directory 模块](https://learn.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2022-ps)检查 Active Directory：

```powershell
Get-ADUser -Identity <username> -Properties userAccountControl | Select-Object Name, userAccountControl
```

极狐GitLab 会在以下情况下检查 LDAP 用户的状态：

- 使用任何身份验证提供商登录时。
- 对于活动的 Web 会话或使用令牌或 SSH 密钥的 Git 请求，每小时检查一次。
- 使用 LDAP 用户名和密码执行 Git over HTTP 请求时。
- 在[用户同步](ldap_synchronization.md#user-sync)期间每天检查一次。

如果用户不再在 LDAP 中处于活动状态，则会被：

- 登出。
- 置于 `ldap_blocked` 状态。
- 在 LDAP 中重新激活之前，无法使用任何身份验证提供商登录。

<a id="security-risks"></a>

### 安全风险

只有当您的 LDAP 用户无法执行以下操作时，才应使用 LDAP 集成：

- 在 LDAP 服务器上更改其 `mail`、`email` 或 `userPrincipalName` 属性。这些
  用户可能会接管您极狐GitLab 服务器上的任何账号。
- 共享电子邮件地址。具有相同电子邮件地址的 LDAP 用户可以共享同一个极狐GitLab
  账号。

<a id="configure-ldap"></a>

## 配置 LDAP

先决条件：

- 您必须有一个电子邮件地址才能使用 LDAP，无论您是否
  使用该电子邮件地址登录。

要配置 LDAP，您需要在配置文件中编辑设置：

- 您的配置文件必须包含以下[基本配置设置](#basic-configuration-settings)：
  - `label`
  - `host`
  - `port`
  - `uid`
  - `base`
  - `encryption`
- 您可以在配置文件中包含以下可选设置：
  - [可选基本配置设置](#basic-configuration-settings)。
  - [SSL 设置](#ssl-configuration-settings)。
  - [属性设置](#attribute-configuration-settings)。
  - [LDAP 同步设置](#ldap-sync-configuration-settings)。
- 您还可以将 LDAP 配置为：
  - [使用多个服务器](#use-multiple-ldap-servers)。
  - [筛选用户](#set-up-ldap-user-filter)。
  - [自动将 LDAP 用户名设置为小写](#enable-ldap-username-lowercase)。
  - [禁用 LDAP Web 登录](#disable-ldap-web-sign-in)。
  - [为极狐GitLab 提供智能卡身份验证](#provide-smart-card-authentication-for-gitlab)
  - [使用加密凭据](#use-encrypted-credentials)。

您编辑的文件因极狐GitLab 部署方式而异：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

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

1. 保存文件并应用新的 values：

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

{{< tab title="自行编译（源代码）" >}}

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
[`gitlab.yml.example`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example)中的 `ldap` 设置。

{{< /tab >}}

{{< /tabs >}}

配置 LDAP 后，要测试配置，请使用
[LDAP 检查 Rake 任务](../../raketasks/ldap.md#check)。

<a id="basic-configuration-settings"></a>

### 基本配置设置

以下基本设置可用：

| 设置                         | 必需    | 类型                          | 描述 |
|---------------------------------|-------------|-------------------------------|-------------|
| `label`                         | {{< yes >}} | String                        | 您的 LDAP 服务器的友好名称。它会显示在您的登录页面上。示例：`'Paris'` 或 `'Acme, Ltd.'` |
| `host`                          | {{< yes >}} | String                        | 您的 LDAP 服务器的 IP 地址或域名。定义 `hosts` 时忽略此项。示例：`'ldap.mydomain.com'` |
| `port`                          | {{< yes >}} | Integer                       | 您的 LDAP 服务器上用于连接的端口。定义 `hosts` 时忽略此项。示例：`389` 或 `636`（用于 SSL） |
| `uid`                           | {{< yes >}} | String                        | 映射到用户用于登录的用户名的 LDAP 属性。应为属性，而不是映射到 `uid`的值。不影响极狐GitLab 用户名（请参阅[属性部分](#attribute-configuration-settings)）。示例：`'sAMAccountName'` 或 `'uid'` 或 `'userPrincipalName'` |
| `base`                          | {{< yes >}} | String                        | 用于搜索用户的基础。示例：`'ou=people,dc=gitlab,dc=example'` 或 `'DC=mydomain,DC=com'` |
| `encryption`                    | {{< yes >}} | String                        | 加密方法（`method` 键已弃用，改用 `encryption`）。它可以有三个值之一：`'start_tls'`、`'simple_tls'` 或 `'plain'`。`simple_tls` 对应 LDAP 库中的 'Simple TLS'。`start_tls` 对应 StartTLS，不要与常规 TLS 混淆。如果您指定 `simple_tls`，通常使用端口 636，而 `start_tls`（StartTLS）则使用端口 389。`plain` 也使用端口 389。 |
| `hosts`                         | {{< no >}}  | Array of strings and integers | 用于打开连接的主机和端口对数组。每个配置的服务器应具有相同的数据集。这不是用于配置多个不同的 LDAP 服务器，而是用于配置故障转移。主机按配置顺序尝试。示例：`[['ldap1.mydomain.com', 636], ['ldap2.mydomain.com', 636]]` |
| `bind_dn`                       | {{< no >}}  | String                        | 您用于绑定的用户的完整 DN。示例：`'america\momo'` 或 `'CN=Gitlab,OU=Users,DC=domain,DC=com'` |
| `password`                      | {{< no >}}  | String                        | 绑定用户的密码。 |
| `verify_certificates`           | {{< no >}}  | Boolean                       | 默认为 `true`。如果加密方法为 `start_tls` 或 `simple_tls`，则启用 SSL 证书验证。如果设置为 `false`，则不执行 LDAP 服务器 SSL 证书的验证。 |
| `timeout`                       | {{< no >}}  | Integer                       | 默认为 `10`。为 LDAP 查询设置超时时间（以秒为单位）。这有助于在 LDAP 服务器无响应时避免阻塞请求。值为 `0` 表示没有超时。 |
| `active_directory`              | {{< no >}}  | Boolean                       | 此设置指定 LDAP 服务器是否为 Active Directory LDAP 服务器。对于非 AD 服务器，它会跳过 AD 特定的查询。如果您的 LDAP 服务器不是 AD，请将其设置为 false。 |
| `allow_username_or_email_login` | {{< no >}}  | Boolean                       | 默认为 `false`。如果启用，极狐GitLab 会忽略用户在登录时提交的 LDAP 用户名中第一个 `@` 之后的所有内容。如果您在 ActiveDirectory 上使用 `uid: 'userPrincipalName'`，则必须禁用此设置，因为 `userPrincipalName` 包含 `@`。 |
| `block_auto_created_users`      | {{< no >}}  | Boolean                       | 默认为 `false`。为了严格控制极狐GitLab 安装中的计费用户数量，请启用此设置，使新用户在管理员清除之前保持被阻止状态。 |
| `user_filter`                   | {{< no >}}  | String                        | 筛选 LDAP 用户。遵循 [RFC 4515](https://www.rfc-editor.org/rfc/rfc4515.html)的格式。极狐GitLab 不支持 `omniauth-ldap`的自定义筛选语法。`user_filter` 字段语法示例：<br/><br/>- `'(employeeType=developer)'`<br/>- `'(&(objectclass=user)(\|(samaccountname=momo)(samaccountname=toto)))'` |
| `lowercase_usernames`           | {{< no >}}  | Boolean                       | 如果启用，极狐GitLab 会将名称转换为小写。 |
| `retry_empty_result_with_codes` | {{< no >}}  | Array                         | 一个 LDAP 查询响应代码数组，当结果/内容为空时尝试重试操作。对于 Google Secure LDAP，将此值设置为 `[80]`。 |

> [!note]
> 极狐GitLab 不受 [Microsoft 公告 ADV190023](https://msrc.microsoft.com/update-guide/en-us/advisory/ADV190023)
> 引入的 Microsoft Active Directory Services 更严格绑定要求的影响。
> 有关更多信息，请参阅[议题 201894](https://gitlab.com/gitlab-org/gitlab/-/issues/201894#note_2807513217)。

<a id="ssl-configuration-settings"></a>

### SSL 配置设置

您可以在 `tls_options` 名称/值对下配置 SSL 配置设置。以下设置均为可选：

| 设置       | 描述 | 示例 |
|---------------|-------------|----------|
| `ca_file`     | 指定包含 PEM 格式 CA 证书的文件的路径，例如，如果您需要内部 CA。 | `'/etc/ca.pem'` |
| `ssl_version` | 指定 OpenSSL 要使用的 SSL 版本，如果 OpenSSL 默认值不合适。 | `'TLSv1_1'` |
| `ciphers`     | 与 LDAP 服务器通信时要使用的特定 SSL 密码算法。 | `'ALL:!EXPORT:!LOW:!aNULL:!eNULL:!SSLv2'` |
| `cert`        | 客户端证书。 | `'-----BEGIN CERTIFICATE----- <REDACTED> -----END CERTIFICATE -----'` |
| `key`         | 客户端私钥。 | `'-----BEGIN PRIVATE KEY----- <REDACTED> -----END PRIVATE KEY -----'` |

以下示例说明如何在 `tls_options`中设置 `ca_file` 和 `ssl_version`：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

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

1. 保存文件并应用新的 values：

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

{{< tab title="自行编译（源代码）" >}}

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

极狐GitLab 使用这些 LDAP 属性为 LDAP 用户创建账号。指定的属性可以是：

- 字符串形式的属性名。例如，`'mail'`。
- 按顺序尝试的属性名数组。例如，`['mail', 'email']`。

用户的 LDAP 登录名是[指定为 `uid`的 LDAP 属性](#basic-configuration-settings)。

以下所有 LDAP 属性均为可选。您只需指定与默认值不同的属性。如果您指定了其中一个，例如 `username`，则无需指定其他属性。将应用默认值。

如果您定义了其中任何一个，则必须在 `attributes` 哈希中定义。

| 设置      | 描述 | 默认值 |
|--------------|-------------|----------|
| `username`   | 极狐GitLab 账号将预配的 `@username`。如果值包含电子邮件地址，则极狐GitLab 用户名是电子邮件地址中 `@` 之前的部分。 | 默认为[指定为 `uid`的 LDAP 属性](#basic-configuration-settings)（`['uid', 'userid', 'sAMAccountName']`）。 |
| `email`      | 用户电子邮件的 LDAP 属性。 | `['mail', 'email', 'userPrincipalName']` |
| `name`       | 用户显示名称的 LDAP 属性。如果 `name` 为空，则全名取自 `first_name` 和 `last_name`。属性 `'cn'` 或 `'displayName'` 通常包含全名。或者，您可以通过指定一个不存在的属性（如 `'somethingNonExistent'`）来强制使用 `first_name` 和 `last_name`。 | `'cn'` |
| `first_name` | 用户名字的 LDAP 属性。当为 `name` 配置的属性不存在时使用。 | `'givenName'` |
| `last_name`  | 用户姓氏的 LDAP 属性。当为 `name` 配置的属性不存在时使用。 | `'sn'` |

使用 `displayName` 作为用户名，并使用属性数组作为 `email`的示例配置：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

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

1. 保存文件并应用新的 values：

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

{{< tab title="自行编译（源代码）" >}}

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

这些 LDAP 同步配置设置是可选的，但 `group_base` 除外，它在配置 `external_groups` 时是必需的：

| 设置           | 描述 | 示例 |
|-------------------|-------------|----------|
| `group_base`      | 用于搜索群组的基础。所有有效群组的 DN 中都包含此基础。 | `'ou=groups,dc=gitlab,dc=example'` |
| `group_filter`    | 筛选在 `group_base` 下搜索的 LDAP 群组。遵循 [RFC 4515](https://www.rfc-editor.org/rfc/rfc4515.html)的格式。 | `'(objectclass=group)'` |
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

如果您的用户分布在多个 LDAP 服务器上，您可以将极狐GitLab 配置为使用它们。要添加其他 LDAP 服务器：

1. 复制 [`main` LDAP 配置](#configure-ldap)。
1. 使用其他服务器的详细信息编辑每个复制的配置。
   - 对于每个其他服务器，选择不同的提供商 ID，如 `main`、`secondary` 或 `tertiary`。使用小写
     字母数字字符。极狐GitLab 使用提供商 ID 将每个用户与特定的 LDAP 服务器关联。
   - 对于每个条目，使用唯一的 `label` 值。这些值用于登录页面上的标签页名称。

以下示例展示了如何使用最小配置来配置三个 LDAP 服务器：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

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

1. 保存文件并应用新的 values：

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

{{< tab title="自行编译（源代码）" >}}

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
[`gitlab.yml.example`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example)中的 `ldap` 设置。

{{< /tab >}}

{{< /tabs >}}

此示例会生成一个包含以下标签页的登录页面：

- **GitLab AD**。
- **GitLab Secondary AD**。
- **GitLab Tertiary AD**。

<a id="set-up-ldap-user-filter"></a>

### 设置 LDAP 用户筛选

要将所有极狐GitLab 访问限制为 LDAP 服务器上 LDAP 用户的子集，首先缩小配置的 `base`。但是，如果有必要进一步筛选用户，您可以设置 LDAP 用户筛选。筛选必须符合 [RFC 4515](https://www.rfc-editor.org/rfc/rfc4515.html)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

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

1. 保存文件并应用新的 values：

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

{{< tab title="自行编译（源代码）" >}}

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

要限制对 Active Directory 群组的嵌套成员的访问，请使用以下语法：

```plaintext
(memberOf:1.2.840.113556.1.4.1941:=CN=My Group,DC=Example,DC=com)
```

有关 `LDAP_MATCHING_RULE_IN_CHAIN` 筛选的更多信息，请参阅[搜索筛选语法](https://learn.microsoft.com/en-us/windows/win32/adsi/search-filter-syntax)。

用户筛选中的嵌套成员支持不应与[群组同步嵌套群组](ldap_synchronization.md#supported-ldap-group-typesattributes)支持混淆。

极狐GitLab 不支持 OmniAuth LDAP 使用的自定义筛选语法。

<a id="escape-special-characters-in-user_filter"></a>

#### 在 `user_filter`中转义特殊字符

`user_filter` DN 可以包含特殊字符。例如：

- 逗号：

  ```plaintext
  OU=GitLab, Inc,DC=gitlab,DC=com
  ```

- 左括号和右括号：

  ```plaintext
  OU=GitLab (Inc),DC=gitlab,DC=com
  ```

这些字符必须按照 [RFC 4515](https://www.rfc-editor.org/rfc/rfc4515.html#section-4)中的说明进行转义。

- 使用 `\2C` 转义逗号。例如：

  ```plaintext
  OU=GitLab\2C Inc,DC=gitlab,DC=com
  ```

- 使用 `\28` 转义左括号，使用 `\29` 转义右括号。例如：

  ```plaintext
  OU=GitLab \28Inc\29,DC=gitlab,DC=com
  ```

<a id="enable-ldap-username-lowercase"></a>

### 启用 LDAP 用户名小写

某些 LDAP 服务器根据其配置可能会返回大写用户名。这可能导致一些令人困惑的问题，例如创建带有大写名称的链接或命名空间。

极狐GitLab 可以通过启用配置选项 `lowercase_usernames` 自动将 LDAP 服务器提供的用户名转换为小写。默认情况下，此配置选项为 `false`。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

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

1. 保存文件并应用新的 values：

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

{{< tab title="自行编译（源代码）" >}}

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

当首选 SAML 等替代方案时，阻止通过 Web UI 使用 LDAP 凭据会很有用。这允许将 LDAP 用于群组同步，同时允许您的 SAML 身份提供商处理自定义 2FA 等额外检查。

禁用 LDAP Web 登录后，用户在登录页面上看不到 **LDAP** 标签页。这不会禁用将 LDAP 凭据用于 Git 访问。

禁用 LDAP Web 登录不会阻止这些用户访问 Web UI：他们仍然可以使用极狐GitLab 密码登录。要仅要求通过您的身份提供商登录，还请[为具有 SSO 身份的用户禁用密码身份验证](../../settings/sign_in_restrictions.md#disable-password-and-passkey-authentication-for-users-with-an-sso-identity)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['prevent_ldap_sign_in'] = true
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

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

1. 保存文件并应用新的 values：

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

{{< tab title="自行编译（源代码）" >}}

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

您可以选择使用加密文件来存储 LDAP 凭据，而不是将 LDAP 集成凭据以明文形式存储在配置文件中。

先决条件：

- 要使用加密凭据，您必须首先启用
  [加密配置](../../encrypted_configuration.md)。

LDAP 的加密配置存在于加密的 YAML 文件中。该文件的未加密内容应是 LDAP 配置中 `servers` 块中密钥设置的子集。

加密文件支持的配置项为：

- `bind_dn`
- `password`

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 如果最初您在 `/etc/gitlab/gitlab.rb`中的 LDAP 配置如下所示：

   ```ruby
     gitlab_rails['ldap_servers'] = {
       'main' => {
         'bind_dn' => 'admin',
         'password' => '123'
       }
     }
   ```

1. 编辑加密密钥：

   ```shell
   sudo gitlab-rake gitlab:ldap:secret:edit EDITOR=vim
   ```

1. 输入 LDAP 密钥的未加密内容：

   ```yaml
   main:
     bind_dn: admin
     password: '123'
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并移除 `bind_dn` 和 `password`的设置。
1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

使用 Kubernetes 密钥存储 LDAP 密码。有关更多信息，
请阅读 [Helm LDAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#ldap-password)。

{{< /tab >}}

{{< tab title="Docker" >}}

1. 如果最初您在 `docker-compose.yml`中的 LDAP 配置如下所示：

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

1. 进入容器，并编辑加密密钥：

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

1. 编辑 `docker-compose.yml` 并移除 `bind_dn` 和 `password`的设置。
1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 如果最初您在 `/home/git/gitlab/config/gitlab.yml`中的 LDAP 配置如下所示：

   ```yaml
   production:
     ldap:
       servers:
         main:
           bind_dn: admin
           password: '123'
   ```

1. 编辑加密密钥：

   ```shell
   bundle exec rake gitlab:ldap:secret:edit EDITOR=vim RAILS_ENVIRONMENT=production
   ```

1. 输入 LDAP 密钥的未加密内容：

   ```yaml
   main:
    bind_dn: admin
    password: '123'
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并移除 `bind_dn` 和 `password`的设置。
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

## 更新 LDAP DN 和电子邮件

当 LDAP 服务器在极狐GitLab 中创建用户时，用户的 LDAP DN 会作为标识符关联到其极狐GitLab 账号。

当用户尝试使用 LDAP 登录时，极狐GitLab 会尝试使用该用户账号上保存的 DN 查找用户。

- 如果极狐GitLab 通过 DN 找到用户，并且用户的电子邮件地址：
  - 与极狐GitLab 账号的电子邮件地址匹配，极狐GitLab 不会采取进一步操作。
  - 已更改，极狐GitLab 会更新其用户电子邮件记录以匹配 LDAP 中的记录。
- 如果极狐GitLab 无法通过其 DN 找到用户，则会尝试通过其电子邮件查找用户。如果极狐GitLab：
  - 通过其电子邮件找到用户，极狐GitLab 会更新用户极狐GitLab 账号中存储的 DN。现在两个值
    都与 LDAP 中存储的信息匹配。
  - 无法通过其电子邮件地址找到用户（DN 和电子邮件地址都已更改），请参阅
    [用户 DN 和电子邮件已更改](ldap-troubleshooting.md#user-dn-and-email-have-changed)。

<a id="disable-anonymous-ldap-authentication"></a>

## 禁用匿名 LDAP 身份验证

极狐GitLab 不支持 TLS 客户端身份验证。请在您的 LDAP 服务器上完成以下步骤。

1. 禁用匿名身份验证。
1. 启用以下身份验证类型之一：
   - 简单身份验证。
   - 简单身份验证和安全层（SASL）身份验证。

您 LDAP 服务器中的 TLS 客户端身份验证设置不能是强制性的，并且客户端不能使用 TLS 协议进行身份验证。

<a id="users-deleted-from-ldap"></a>

## 从 LDAP 中删除的用户

从 LDAP 服务器中删除的用户：

- 会立即被阻止登录极狐GitLab。
- [不再占用许可证](../../moderate_users.md)。

但是，这些用户可以继续使用 SSH 进行 Git 操作，直到下一次 [LDAP 检查缓存运行](ldap_synchronization.md#adjust-ldap-sync-schedule)。

要立即删除账号，您可以手动[阻止该用户](../../moderate_users.md#block-a-user)。

<a id="update-user-email-addresses"></a>

## 更新用户电子邮件地址

当使用 LDAP 登录时，LDAP 服务器上的电子邮件地址被视为用户的真实来源。

更新用户电子邮件地址必须在管理该用户的 LDAP 服务器上进行。极狐GitLab 的电子邮件地址会在以下情况下更新：

- 用户下次登录时。
- 下一次运行[用户同步](ldap_synchronization.md#user-sync)时。

更新后用户之前的电子邮件地址会成为辅助电子邮件地址，以保留该用户的提交历史。

您可以在我们的 [LDAP 故障排除部分](ldap-troubleshooting.md#user-dn-and-email-have-changed)中找到有关用户更新预期行为的更多详细信息。

<a id="google-secure-ldap"></a>

## Google Secure LDAP

[Google Cloud Identity](https://cloud.google.com/identity/) 提供了一项 Secure
LDAP 服务，可以与极狐GitLab 一起配置用于身份验证和群组同步。
有关详细配置说明，请参阅 [Google Secure LDAP](google_secure_ldap.md)。

<a id="synchronize-users-and-groups"></a>

## 同步用户和群组

有关在 LDAP 和极狐GitLab 之间同步用户和群组的更多信息，请参阅
[LDAP 同步](ldap_synchronization.md)。

<a id="move-from-ldap-to-saml"></a>

## 从 LDAP 迁移到 SAML

1. [添加 SAML 配置](../../../integration/saml.md)到：
   - [Linux 软件包安装的 `gitlab.rb`](../../../integration/saml.md)。
   - [Helm chart 安装的 `values.yml`](../../../integration/saml.md)。

1. 可选。[从登录页面禁用 LDAP 身份验证](#disable-ldap-web-sign-in)。
1. 可选。要解决用户关联问题，您可以先[移除这些用户的 LDAP 身份](ldap-troubleshooting.md#remove-the-identity-records-that-relate-to-the-removed-ldap-server)。
1. 确认用户能够登录其账号。如果用户无法登录，请检查该用户的 LDAP 是否仍然存在，必要时将其移除。如果此问题仍然存在，请检查日志以确定问题所在。
1. 在配置文件中，更改：
   - `omniauth_auto_link_user` 为仅 `saml`。
   - `omniauth_auto_link_ldap_user` 为 false。
   - `ldap_enabled` 为 `false`。
     您也可以注释掉 LDAP 提供商设置。

<a id="troubleshooting"></a>

## 故障排除

请参阅我们的 [LDAP 故障排除管理员指南](ldap-troubleshooting.md)。
