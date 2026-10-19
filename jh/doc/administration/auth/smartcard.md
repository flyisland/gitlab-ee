---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 智能卡身份验证
description: 使用硬件设备进行基于证书的登录。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 支持使用智能卡进行身份验证。

<a id="existing-password-authentication"></a>

## 现有的密码身份验证

默认情况下，启用智能卡身份验证后，现有用户仍可使用用户名和密码登录。

要强制现有用户仅使用智能卡身份验证，请[禁用用户名和密码身份验证](../settings/sign_in_restrictions.md#password-and-passkey-authentication)。

<a id="authentication-methods"></a>

## 身份验证方法

极狐GitLab 支持两种身份验证方法：

- 使用本地数据库的 X.509 证书。
- LDAP 服务器。

<a id="authentication-against-a-local-database-with-x509-certificates"></a>

### 使用 X.509 证书对本地数据库进行身份验证

{{< details >}}

- Status: 实验

{{< /details >}}

带有 X.509 证书的智能卡可用于向极狐GitLab 进行身份验证。

要使用带有 X.509 证书的智能卡对极狐GitLab 的本地数据库进行身份验证，必须在证书中定义 `CN` 和 `emailAddress`。例如：

```plaintext
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 12856475246677808609 (0xb26b601ecdd555e1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: O=Random Corp Ltd, CN=Random Corp
        Validity
            Not Before: Oct 30 12:00:00 2018 GMT
            Not After : Oct 30 12:00:00 2019 GMT
        Subject: CN=Gitlab User, emailAddress=gitlab-user@example.com
```

<a id="authentication-against-a-local-database-with-x509-certificates-and-san-extension"></a>

### 使用 X.509 证书和 SAN 扩展对本地数据库进行身份验证

{{< details >}}

- Status: 实验

{{< /details >}}

使用 SAN 扩展的 X.509 证书智能卡可用于向极狐GitLab 进行身份验证。

要使用带有 X.509 证书的智能卡对极狐GitLab 的本地数据库进行身份验证：

- `subjectAltName` (SAN) 扩展中至少有一个
  必须在极狐GitLab 实例（`URI`）内定义用户身份（`email`）。
- `URI` 必须与 `Gitlab.config.host.gitlab` 匹配。
- 如果您的证书只包含一个 SAN 电子邮件条目，则无需
  添加或修改它来匹配 `email` 与 `URI`。

例如：

```plaintext
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 12856475246677808609 (0xb26b601ecdd555e1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: O=Random Corp Ltd, CN=Random Corp
        Validity
            Not Before: Oct 30 12:00:00 2018 GMT
            Not After : Oct 30 12:00:00 2019 GMT
        ...
        X509v3 extensions:
            X509v3 Key Usage:
                Key Encipherment, Data Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Subject Alternative Name:
                email:gitlab-user@example.com, URI:http://gitlab.example.com/
```

<a id="authentication-against-an-ldap-server"></a>

### 对 LDAP 服务器进行身份验证

{{< details >}}

- Status: 实验

{{< /details >}}

极狐GitLab 按照 [RFC4523](https://www.rfc-editor.org/info/rfc4523/) 实现了一种标准的证书匹配方式。它针对 `userCertificate` 属性使用 `certificateExactMatch` 证书匹配规则。作为先决条件，您必须使用满足以下条件的 LDAP 服务器：

- 支持 `certificateExactMatch` 匹配规则。
- 将证书存储在 `userCertificate` 属性中。

<a id="authentication-against-an-active-directory-ldap-server"></a>

### 对 Active Directory LDAP 服务器进行身份验证

Active Directory 不支持 `certificateExactMatch` 规则或 `userCertificate` 属性。大多数基于证书的身份验证工具（例如智能卡）使用 `altSecurityIdentities` 属性，该属性可为每个用户包含多个证书。该字段中的数据必须匹配 [Microsoft 推荐的格式之一](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication-certificateuserids#supported-patterns-for-certificate-user-ids)。

使用以下属性来自定义极狐GitLab 检查的字段以及证书数据的格式：

- `smartcard_ad_cert_field` - 指定要搜索的字段名称。这可以是用户对象上的任意属性。
- `smartcard_ad_cert_format` - 指定从证书中收集的信息的格式。该格式必须是以下值之一。最常见的是
  `issuer_and_serial_number`，以匹配非 Active Directory LDAP 服务器的行为。

| `smartcard_ad_cert_format` | 示例数据                                                 |
| -------------------------- | ------------------------------------------------------------ |
| `principal_name`           | `X509:<PN>alice@example.com`                                 |
| `rfc822_name`              | `X509:<RFC822>bob@example.com`                               |
| `subject`                  | `X509:<S>CN=dennis,OU=UserAccounts,DC=example,DC=com`        |
| `issuer_and_serial_number` | `X509:<I>CN=CONTOSO-DC-CA,DC=example,DC=com<SR>1181914561`   |
| `issuer_and_subject`       | `X509:<I>CN=EXAMPLE-DC-CA,DC=example,DC=com<S>CN=cynthia,OU=UserAccounts,DC=example,DC=com` |
| `reverse_issuer_and_serial_number` | `X509:<I>DC=com,DC=example,CN=CONTOSO-DC-CA<SR>1181914561`   |
| `reverse_issuer_and_subject`   | `X509:<I>DC=com,DC=example,CN=CONTOSO-DC-CA<S>CN=cynthia,OU=UserAccounts,DC=example,DC=com` |
| `reverse_issuer_and_reverse_subject`   | `X509:<I>DC=com,DC=example,CN=CONTOSO-DC-CA<S>DC=com,DC=example,OU=UserAccounts,CN=cynthia` |

对于 `issuer_and_serial_number`，`<SR>` 部分采用反向字节序，最低有效字节在前。有关更多信息，请参阅[如何使用 altSecurityIdentities 属性将用户映射到证书](https://learn.microsoft.com/en-us/archive/blogs/spatdsg/howto-map-a-user-to-a-certificate-via-all-the-methods-available-in-the-altsecurityidentities-attribute)。

反向颁发者格式按从最小单位到最大单位对颁发者字符串进行排序。某些
Active Directory 服务器以这种格式存储证书。

> [!note]
> 如果未指定 `smartcard_ad_cert_format`，但 LDAP 服务器配置了 `active_directory: true` 并启用了智能卡，极狐GitLab 将默认采用 16.8 及更早版本的行为，并在 `userCertificate` 属性上使用 `certificateExactMatch`。

<a id="authentication-against-entra-id-domain-services"></a>

### 对 Entra ID Domain Services 进行身份验证

[Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/what-is-entra)（前身为 Azure Active Directory）为公司和企业组织提供基于云的目录。[Entra Domain Services](https://learn.microsoft.com/en-us/entra/identity/domain-services/overview) 为该目录提供安全的只读 LDAP 接口，但仅公开 Entra ID 所拥有字段的有限子集。

Entra ID 使用 `CertificateUserIds` 字段来管理用户的客户端证书，但该字段未在 LDAP / Entra ID Domain Services 中公开。在纯云环境中，极狐GitLab 无法使用 LDAP 对用户的智能卡进行身份验证。

在本地与云混合环境中，实体通过 [Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect-v2) 在本地 Active Directory 控制器与云端 Entra ID 之间同步。如果您[使用 Entra ID Connect 将 `altSecurityIdentities` 属性同步到 Entra ID 中的 `certificateUserIds`](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication-certificateuserids#update-certificateuserids-using-microsoft-entra-connect)，则可以在 LDAP / Entra ID Domain Services 中公开此数据，以便极狐GitLab 对其进行身份验证：

1. 在 Entra ID Connect 中添加一条规则，将 `altSecurityIdentities` 同步到 Entra ID 中的另一个属性。
1. 将该额外属性启用为 [Entra ID Domain Services 中的扩展属性](https://learn.microsoft.com/en-us/entra/identity/domain-services/concepts-custom-attributes)。
1. 在极狐GitLab 中配置 `smartcard_ad_cert_field` 字段以使用此扩展属性。

<a id="configure-gitlab-for-smart-card-authentication"></a>

## 为智能卡身份验证配置极狐GitLab

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # Allow smart card authentication
   gitlab_rails['smartcard_enabled'] = true

   # Path to a file containing a CA certificate
   gitlab_rails['smartcard_ca_file'] = "/etc/ssl/certs/CA.pem"

   # Host and port where the client side certificate is requested by the
   # webserver (NGINX/Apache)
   gitlab_rails['smartcard_client_certificate_required_host'] = "smartcard.example.com"
   gitlab_rails['smartcard_client_certificate_required_port'] = 3444
   ```

   > [!note]
   > 为以下变量中的至少一个赋值：
   > `gitlab_rails['smartcard_client_certificate_required_host']` 或
   > `gitlab_rails['smartcard_client_certificate_required_port']`。

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   极狐GitLab 以使更改生效。

对于自行编译安装：

1. 配置 NGINX 以请求客户端证书

   在 NGINX 配置中，必须定义一个额外的 server 上下文，其配置相同，但以下内容除外：

   - 额外的 NGINX server 上下文必须配置为在不同的
     端口上运行：

     ```plaintext
     listen *:3444 ssl;
     ```

   - 它也可以配置为在不同的主机名上运行：

     ```plaintext
     listen smartcard.example.com:443 ssl;
     ```

   - 额外的 NGINX server 上下文必须配置为要求客户端
     证书：

     ```plaintext
     ssl_verify_depth 2;
     ssl_client_certificate /etc/ssl/certs/CA.pem;
     ssl_verify_client on;
     ```

   - 额外的 NGINX server 上下文必须配置为转发客户端
     证书：

     ```plaintext
     proxy_set_header    X-SSL-Client-Certificate    $ssl_client_escaped_cert;
     ```

   例如，以下是 NGINX 配置文件（例如 `/etc/nginx/sites-available/gitlab-ssl`）中的
   一个 server 上下文示例：

   ```plaintext
   server {
       listen smartcard.example.com:3443 ssl;

       # certificate for configuring SSL
       ssl_certificate /path/to/example.com.crt;
       ssl_certificate_key /path/to/example.com.key;

       ssl_verify_depth 2;
       # CA certificate for client side certificate verification
       ssl_client_certificate /etc/ssl/certs/CA.pem;
       ssl_verify_client on;

       location / {
           proxy_set_header    Host                        $http_host;
           proxy_set_header    X-Real-IP                   $remote_addr;
           proxy_set_header    X-Forwarded-For             $proxy_add_x_forwarded_for;
           proxy_set_header    X-Forwarded-Proto           $scheme;
           proxy_set_header    Upgrade                     $http_upgrade;
           proxy_set_header    Connection                  $connection_upgrade;

           proxy_set_header    X-SSL-Client-Certificate    $ssl_client_escaped_cert;

           proxy_read_timeout 300;

           proxy_pass http://gitlab-workhorse;
       }
   }
   ```

1. 编辑 `config/gitlab.yml`：

   ```yaml
   ## Smart card authentication settings
   smartcard:
     # Allow smart card authentication
     enabled: true

     # Path to a file containing a CA certificate
     ca_file: '/etc/ssl/certs/CA.pem'

     # Host and port where the client side certificate is requested by the
     # webserver (NGINX/Apache)
     client_certificate_required_host: smartcard.example.com
     client_certificate_required_port: 3443
   ```

   > [!note]
   > 为以下变量中的至少一个赋值：
   > `client_certificate_required_host` 或 `client_certificate_required_port`。

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使更改生效。

<a id="additional-security-recommendations"></a>

### 额外的安全建议

为了增强安全性，请将极狐GitLab 部署在防火墙后面，例如 CloudFlare WAF 或运行 [ModSecurity](https://modsecurity.org/)的服务器。匹配以下模式的 URL 应可由作为极狐GitLab 一部分部署的 NGINX 访问，但不应可由外部客户端访问：

```plaintext
/-/smartcard/extract_certificate
/-/smartcard/verify_certificate
```

这些路径应仅能通过分配给 NGINX 的智能卡主机名和端口从外部访问，而不能通过极狐GitLab 的主主机名和端口从外部访问。这应能抵御 [HTTP Host 标头攻击](https://portswigger.net/web-security/host-header)，使用户无法在不经过 NGINX 的情况下提交自己的证书参数。

<a id="additional-steps-when-using-san-extensions"></a>

### 使用 SAN 扩展时的额外步骤

对于 Linux 软件包安装：

1. 添加到 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['smartcard_san_extensions'] = true
   ```

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   极狐GitLab 以使更改生效。

对于自行编译安装：

1. 在智能卡部分中，将 `san_extensions` 行添加到 `config/gitlab.yml`：

   ```yaml
   smartcard:
      enabled: true
      ca_file: '/etc/ssl/certs/CA.pem'
      client_certificate_required_port: 3444

      # Enable the use of SAN extensions to match users with certificates
      san_extensions: true
   ```

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使更改生效。

<a id="additional-steps-when-authenticating-against-an-ldap-server"></a>

### 对 LDAP 服务器进行身份验证时的额外步骤

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = YAML.load <<-EOS
   main:
     # snip...
     # Enable smart card authentication against the LDAP server. Valid values
     # are "false", "optional", and "required".
     smartcard_auth: optional

     # If your LDAP server is Active Directory, you can configure these two fields.
     # Specify which field contains certificate information, 'altSecurityIdentities' by default
     smartcard_ad_cert_field: altSecurityIdentities

     # Specify format of certificate information. Valid values are:
     # principal_name, rfc822_name, issuer_and_subject, subject, issuer_and_serial_number
     smartcard_ad_cert_format: issuer_and_serial_number
   EOS
   ```

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   极狐GitLab 以使更改生效。

对于自行编译安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
   production:
     ldap:
       servers:
         main:
           # snip...
           # Enable smart card authentication against the LDAP server. Valid values
           # are "false", "optional", and "required".
           smartcard_auth: optional

           # If your LDAP server is Active Directory, you can configure these two fields.
           # Specify which field contains certificate information, 'altSecurityIdentities' by default
           smartcard_ad_cert_field: altSecurityIdentities

           # Specify format of certificate information. Valid values are:
           # principal_name, rfc822_name, issuer_and_subject, subject, issuer_and_serial_number
           smartcard_ad_cert_format: issuer_and_serial_number
   ```

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使更改生效。

<a id="require-browser-session-with-smart-card-sign-in-for-git-access"></a>

### 要求 Git 访问使用智能卡登录的浏览器会话

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['smartcard_required_for_git_access'] = true
   ```

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   极狐GitLab 以使更改生效。

对于自行编译安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
   ## Smart card authentication settings
   smartcard:
     # snip...
     # Browser session with smart card sign-in is required for Git access
     required_for_git_access: true
   ```

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使更改生效。

<a id="passwords-for-users-created-via-smart-card-authentication"></a>

## 通过智能卡身份验证创建的用户的密码

[通过集成身份验证创建的用户的生成密码](../../user/profile/user_passwords.md)指南概述了极狐GitLab 如何为通过智能卡身份验证创建的用户生成和设置密码。
