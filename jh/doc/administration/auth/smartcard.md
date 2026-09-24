---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 智能卡认证
description: Authenticate using hardware devices for certificate-based login.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 支持使用智能卡进行认证<think>嗯，用户提供了一份详细的翻译规则和待翻译的英文文档，要求将 GitLab 的智能卡认证文档翻译成中文。我需要仔细遵循这些规则。

首先，我需要处理文件头部的 YAML 部分。规则要求只翻译 title 字段，其他内容保持原样。所以我会把 "Smart card authentication" 翻译成 "智能卡认证"，并保留其他字段。

接下来是 Tier 和 Offering 部分。根据规则，Premium 要翻译成 "专业版"，Ultimate 翻译成 "旗舰版"，GitLab Self-Managed 翻译成 "私有化部署"。同时要注意 GitLab.com 需要替换为 JihuLab.com，但这里没有出现。

然后开始翻译正文。全局规则要求把 "GitLab" 替换为 "极狐GitLab"，并且 "极狐GitLab" 与后面的内容要加一个空格。比如 "GitLab supports" 要翻译成 "极狐GitLab 支持"。

对于标题的处理，每个标题都需要先翻译成中文，然后在上面添加一个英文锚点。锚点格式是 `<a id="英文标题小写并用-连接"></a>`，并且锚点和标题之间要有一个空行。

文档中有很多代码块，规则要求代码块中的内容需要翻译，但证书示例这类固定格式的数据可能需要保留原样。不过代码注释部分一定要翻译，比如 "# Allow smart card authentication" 要翻译成 "# 允许智能卡认证"。

历史记录部分需要删除所有外部链接，但保留内部链接。比如 "Introduced in GitLab 16.9" 要翻译成 "在极狐GitLab 16.9 中引入"，并移除对应的 issue 链接。

关于 Active Directory 的认证部分，表格内容需要翻译表头，但示例数据保留原样。note 提示框的内容也要完整翻译。

安全建议部分提到了 CloudFlare，虽然规则要求删除借助国外服务实现的功能描述，但这里只是作为防火墙示例提及，不是功能实现，所以应该保留并翻译。

最后要确保所有中英文、数字之间都添加了适当的空格，符合 Markdown 格式要求，并在文档末尾添加一个空行。</think>---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 智能卡认证
description: Authenticate using hardware devices for certificate-based login.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 支持使用智能卡进行认证。

<a id="existing-password-authentication"></a>

## 现有的密码认证

默认情况下，当启用智能卡认证时，现有用户可以继续使用用户名和密码登录。

要强制现有用户仅使用智能卡认证，[禁用用户名和密码认证](../settings/sign_in_restrictions.md#password-and-passkey-authentication)。

<a id="authentication-methods"></a>

## 认证方法

极狐GitLab 支持两种认证方法：

- 使用本地数据库的 X.509 证书。
- LDAP 服务器。

<a id="authentication-against-a-local-database-with-x509-certificates"></a>

### 使用 X.509 证书对本地数据库进行认证

{{< details >}}

- Status: 实验性

{{< /details >}}

带有 X.509 证书的智能卡可用于对极狐GitLab 进行认证。

要使用带有 X.509 证书的智能卡对极狐GitLab 的本地数据库进行认证，必须在证书中定义 `CN` 和 `emailAddress`。例如：

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

### 使用 X.509 证书和 SAN 扩展对本地数据库进行认证

{{< details >}}

- Status: 实验性

{{< /details >}}

带有使用 SAN 扩展的 X.509 证书的智能卡可用于对极狐GitLab 进行认证。

要使用带有 X.509 证书的智能卡对极狐GitLab 的本地数据库进行认证：

- 至少有一个 `subjectAltName` (SAN) 扩展必须在极狐GitLab 实例 (`URI`) 中定义用户身份 (`email`)。
- `URI` 必须匹配 `Gitlab.config.host.gitlab`。
- 如果你的证书只包含 **一个** SAN 电子邮件条目，你不需要添加或修改它以匹配 `email` 和 `URI`。

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

### 对 LDAP 服务器进行认证

{{< details >}}

- Status: 实验性

{{< /details >}}

极狐GitLab 实现了遵循 [RFC4523](https://www.rfc-editor.org/rfc/rfc4523) 的标准证书匹配方式。它使用 `certificateExactMatch` 证书匹配规则针对 `userCertificate` 属性。作为前提条件，你必须使用满足以下条件的 LDAP 服务器：

- 支持 `certificateExactMatch` 匹配规则。
- 在 `userCertificate` 属性中存储了证书。

<a id="authentication-against-an-active-directory-ldap-server"></a>

### 对 Active Directory LDAP 服务器进行认证

{{< history >}}

- 在极狐GitLab 16.9 中引入。
- 在极狐GitLab 17.11 中添加了 `reverse_issuer_and_subject` 和 `reverse_issuer_and_serial_number` 格式。
- `issuer_and_subject`、`reverse_issuer_and_subject` 和 `subject` 格式在极狐GitLab 18.6 中更新，带有一个名为 `smartcard_ad_formats_v2` 的[功能标志](../feature_flags/_index.md)。默认启用。禁用此功能标志可恢复这些格式的先前版本。
- 在极狐GitLab 18.9 中 GA。功能标志 `smartcard_ad_formats_v2` 已移除。

{{< /history >}}

> [!flag]
> 此功能的功能由功能标志控制。
> 更多信息，请参见历史记录。

Active Directory 不支持 `certificateExactMatch` 规则或 `userCertificate` 属性。大多数基于证书的认证工具（如智能卡）使用 `altSecurityIdentities` 属性，该属性可以为每个用户包含多个证书。该字段中的数据必须匹配 [Microsoft 推荐的格式之一](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication-certificateuserids#supported-patterns-for-certificate-user-ids)。

使用以下属性来自定义极狐GitLab 检查的字段和证书数据的格式：

- `smartcard_ad_cert_field` - 指定要搜索的字段名称。这可以是用户对象上的任何属性。
- `smartcard_ad_cert_format` - 指定从证书收集的信息的格式。此格式必须是以下值之一。最常见的是 `issuer_and_serial_number`，以匹配非 Active Directory LDAP 服务器的行为。

| `smartcard_ad_cert_format` | 示例数据                                                     |
| -------------------------- | ------------------------------------------------------------ |
| `principal_name`           | `X509:<PN>alice@example.com`                                 |
| `rfc822_name`              | `X509:<RFC822>bob@example.com`                               |
| `subject`                  | `X509:<S>CN=dennis,OU=UserAccounts,DC=example,DC=com`        |
| `issuer_and_serial_number` | `X509:<I>CN=CONTOSO-DC-CA,DC=example,DC=com<SR>1181914561`   |
| `issuer_and_subject`       | `X509:<I>CN=EXAMPLE-DC-CA,DC=example,DC=com<S>CN=cynthia,OU=UserAccounts,DC=example,DC=com` |
| `reverse_issuer_and_serial_number` | `X509:<I>DC=com,DC=example,CN=CONTOSO-DC-CA<SR>1181914561`   |
| `reverse_issuer_and_subject`   | `X509:<I>DC=com,DC=example,CN=CONTOSO-DC-CA<S>CN=cynthia,OU=UserAccounts,DC=example,DC=com` |
| `reverse_issuer_and_reverse_subject`   | `X509:<I>DC=com,DC=example,CN=CONTOSO-DC-CA<S>DC=com,DC=example,OU=UserAccounts,CN=cynthia` |

对于 `issuer_and_serial_number`，`<SR>` 部分采用反向字节顺序，最低有效字节在前。更多信息，请参见 [如何使用 altSecurityIdentities 属性将用户映射到证书](https://learn.microsoft.com/en-us/archive/blogs/spatdsg/howto-map-a-user-to-a-certificate-via-all-the-methods-available-in-the-altsecurityidentities-attribute)。

反向颁发者格式将颁发者字符串从最小单位到最大单位排序。一些 Active Directory 服务器以此格式存储证书。

> [!note]
> 如果未指定 `smartcard_ad_cert_format`，但 LDAP 服务器配置了 `active_directory: true` 并启用了智能卡，极狐GitLab 默认采用 16.8 及更早版本的行为，并在 `userCertificate` 属性上使用 `certificateExactMatch`。

<a id="authentication-against-entra-id-domain-services"></a>

### 对 Entra ID 域服务进行认证

{{< history >}}

- 在极狐GitLab 16.9 中引入。

{{< /history >}}

[Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)，前身为 Azure Active Directory，为公司和企业提供基于云的目录。[Entra 域服务](https://learn.microsoft.com/en-us/entra/identity/domain-services/overview) 提供对目录的安全只读 LDAP 接口，但仅公开 Entra ID 所拥有字段的有限子集。

Entra ID 使用 `CertificateUserIds` 字段来管理用户的客户端证书，但此字段不在 LDAP / Entra ID 域服务中公开。在纯云设置中，极狐GitLab 无法使用 LDAP 对用户的智能卡进行认证。

在混合本地和云环境中，实体通过 [Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect-v2) 在本地 Active Directory 控制器和云 Entra ID 之间同步。如果你正在[使用 Entra ID Connect 将 `altSecurityIdentities` 属性同步到 Entra ID 中的 `certificateUserIds`](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication-certificateuserids#update-certificateuserids-using-microsoft-entra-connect)，你可以在 LDAP / Entra ID 域服务中公开此数据，以便极狐GitLab 对其进行认证：

1. 向 Entra ID Connect 添加一条规则，将 `altSecurityIdentities` 同步到 Entra ID 中的附加属性。
1. 在 [Entra ID 域服务中启用该附加属性作为扩展属性](https://learn.microsoft.com/en-us/entra/identity/domain-services/concepts-custom-attributes)。
1. 在极狐GitLab 中配置 `smartcard_ad_cert_field` 字段以使用此扩展属性。

<a id="configure-gitlab-for-smart-card-authentication"></a>

## 配置极狐GitLab 以进行智能卡认证

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # 允许智能卡认证
   gitlab_rails['smartcard_enabled'] = true

   # 包含 CA 证书的文件路径
   gitlab_rails['smartcard_ca_file'] = "/etc/ssl/certs/CA.pem"

   # 客户端证书请求的主机和端口，由 Web 服务器（NGINX/Apache）处理
   gitlab_rails['smartcard_client_certificate_required_host'] = "smartcard.example.com"
   gitlab_rails['smartcard_client_certificate_required_port'] = 3444
   ```

   > [!note]
   > 至少为以下变量之一赋值：
   > `gitlab_rails['smartcard_client_certificate_required_host']` 或
   > `gitlab_rails['smartcard_client_certificate_required_port']`。

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

对于自行编译的安装：

1. 配置 NGINX 以请求客户端证书

   在 NGINX 配置中，必须定义一个**额外的**服务器上下文，其配置相同，但有以下区别：

   - 额外的 NGINX 服务器上下文必须配置为在不同的端口上运行：

     ```plaintext
     listen *:3444 ssl;
     ```

   - 也可以配置为在不同的主机名上运行：

     ```plaintext
     listen smartcard.example.com:443 ssl;
     ```

   - 额外的 NGINX 服务器上下文必须配置为要求客户端证书：

     ```plaintext
     ssl_verify_depth 2;
     ssl_client_certificate /etc/ssl/certs/CA.pem;
     ssl_verify_client on;
     ```

   - 额外的 NGINX 服务器上下文必须配置为转发客户端证书：

     ```plaintext
     proxy_set_header    X-SSL-Client-Certificate    $ssl_client_escaped_cert;
     ```

   例如，以下是 NGINX 配置文件（例如在 `/etc/nginx/sites-available/gitlab-ssl` 中）中的服务器上下文示例：

   ```plaintext
   server {
       listen smartcard.example.com:3443 ssl;

       # 用于配置 SSL 的证书
       ssl_certificate /path/to/example.com.crt;
       ssl_certificate_key /path/to/example.com.key;

       ssl_verify_depth 2;
       # 用于客户端证书验证的 CA 证书
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
   ## 智能卡认证设置
   smartcard:
     # 允许智能卡认证
     enabled: true

     # 包含 CA 证书的文件路径
     ca_file: '/etc/ssl/certs/CA.pem'

     # 客户端证书请求的主机和端口，由 Web 服务器（NGINX/Apache）处理
     client_certificate_required_host: smartcard.example.com
     client_certificate_required_port: 3443
   ```

   > [!note]
   > 至少为以下变量之一赋值：
   > `client_certificate_required_host` 或 `client_certificate_required_port`。

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

<a id="additional-security-recommendations"></a>

### 额外的安全建议

为了额外的安全性，将极狐GitLab 部署在防火墙之后，例如 CloudFlare WAF 或运行 [ModSecurity](https://modsecurity.org/) 的服务器。匹配以下模式的 URL 应对作为极狐GitLab 一部分部署的 NGINX 可访问，但对外部客户端不可访问：

```plaintext
/-/smartcard/extract_certificate
/-/smartcard/verify_certificate
```

这些路径应仅使用分配给 NGINX 的智能卡主机名和端口从外部访问，而不应使用主要的极狐GitLab 主机名和端口从外部访问。这应该能够抵御 [HTTP Host Header 攻击](https://portswigger.net/web-security/host-header)，这样用户就无法在不通过 NGINX 的情况下提交自己的证书参数。

<a id="additional-steps-when-using-san-extensions"></a>

### 使用 SAN 扩展时的额外步骤

对于 Linux 软件包安装：

1. 添加到 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['smartcard_san_extensions'] = true
   ```

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

对于自行编译的安装：

1. 在智能卡部分内的 `config/gitlab.yml` 中添加 `san_extensions` 行：

   ```yaml
   smartcard:
      enabled: true
      ca_file: '/etc/ssl/certs/CA.pem'
      client_certificate_required_port: 3444

      # 启用使用 SAN 扩展来匹配用户与证书
      san_extensions: true
   ```

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

<a id="additional-steps-when-authenticating-against-an-ldap-server"></a>

### 对 LDAP 服务器进行认证时的额外步骤

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_servers'] = YAML.load <<-EOS
   main:
     # snip...
     # 启用针对 LDAP 服务器的智能卡认证。有效值为 "false"、"optional" 和 "required"。
     smartcard_auth: optional

     # 如果你的 LDAP 服务器是 Active Directory，你可以配置这两个字段。
     # 指定包含证书信息的字段，默认为 'altSecurityIdentities'
     smartcard_ad_cert_field: altSecurityIdentities

     # 指定证书信息的格式。有效值为：
     # principal_name、rfc822_name、issuer_and_subject、subject、issuer_and_serial_number
     smartcard_ad_cert_format: issuer_and_serial_number
   EOS
   ```

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

对于自行编译的安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
   production:
     ldap:
       servers:
         main:
           # snip...
           # 启用针对 LDAP 服务器的智能卡认证。有效值为 "false"、"optional" 和 "required"。
           smartcard_auth: optional

           # 如果你的 LDAP 服务器是 Active Directory，你可以配置这两个字段。
           # 指定包含证书信息的字段，默认为 'altSecurityIdentities'
           smartcard_ad_cert_field: altSecurityIdentities

           # 指定证书信息的格式。有效值为：
           # principal_name、rfc822_name、issuer_and_subject、subject、issuer_and_serial_number
           smartcard_ad_cert_format: issuer_and_serial_number
   ```

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

<a id="require-browser-session-with-smart-card-sign-in-for-git-access"></a>

### 要求 Git 访问时使用智能卡登录的浏览器会话

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['smartcard_required_for_git_access'] = true
   ```

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

对于自行编译的安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
   ## 智能卡认证设置
   smartcard:
     # snip...
     # Git 访问需要带有智能卡登录的浏览器会话
     required_for_git_access: true
   ```

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

<a id="passwords-for-users-created-via-smart-card-authentication"></a>

## 通过智能卡认证创建的用户的密码

[通过集成认证创建的用户的生成密码](../../user/profile/user_passwords.md) 指南概述了极狐GitLab 如何为通过智能卡认证创建的用户生成和设置密码。