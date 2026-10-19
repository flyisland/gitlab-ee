---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 S/MIME 对发出的电子邮件进行签名
description: 为发出的电子邮件配置 S/MIME。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 发送的通知电子邮件可以使用 S/MIME 签名，以提高安全性。

请注意，S/MIME 证书与 TLS/SSL 证书并不相同，用途也不同：TLS 创建安全通道，而 S/MIME 对消息本身进行签名和/或加密。

<a id="enable-smime-signing"></a>

## 启用 S/MIME 签名

必须显式启用此设置，并提供一对密钥和证书文件：

- 两个文件都必须采用 PEM 编码。
- 密钥文件必须未加密，以便极狐GitLab 无需用户干预即可读取。
- 仅支持 RSA 密钥。

您还可以选择提供一个 CA 证书捆绑包（PEM 编码），将其包含在每个签名中。这通常是中间 CA。

> [!warning]
> 请注意您的私钥的访问级别以及对第三方的可见性。

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb` 并调整文件路径：

   ```ruby
   gitlab_rails['gitlab_email_smime_enabled'] = true
   gitlab_rails['gitlab_email_smime_key_file'] = '/etc/gitlab/ssl/gitlab_smime.key'
   gitlab_rails['gitlab_email_smime_cert_file'] = '/etc/gitlab/ssl/gitlab_smime.crt'
   # Optional
   gitlab_rails['gitlab_email_smime_ca_certs_file'] = '/etc/gitlab/ssl/gitlab_smime_cas.crt'
   ```

1. 保存文件并[重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation)，以使更改生效。

该密钥必须可由极狐GitLab 系统用户（默认为 `git`）读取。

对于自行编译的安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
   email_smime:
     # Uncomment and set to true if you need to enable email S/MIME signing (default: false)
     enabled: true
     # S/MIME private key file in PEM format, unencrypted
     # Default is '.gitlab_smime_key' relative to Rails.root (the root of the GitLab app).
     key_file: /etc/pki/smime/private/gitlab.key
     # S/MIME public certificate key in PEM format, will be attached to signed messages
     # Default is '.gitlab_smime_cert' relative to Rails.root (the root of the GitLab app).
     cert_file: /etc/pki/smime/certs/gitlab.crt
     # S/MIME extra CA public certificates in PEM format, will be attached to signed messages
     # Optional
     ca_certs_file: /etc/pki/smime/certs/gitlab_cas.crt
   ```

1. 保存文件并[重启极狐GitLab](restart_gitlab.md#self-compiled-installations)，以使更改生效。

该密钥必须可由极狐GitLab 系统用户（默认为 `git`）读取。

<a id="how-to-convert-smime-pkcs-12-format-to-pem-encoding"></a>

### 如何将 S/MIME PKCS #12 格式转换为 PEM 编码

通常，S/MIME 证书以二进制公钥密码标准（PKCS）#12 格式处理（`.pfx` 或 `.p12` 扩展名），该格式在单个加密文件中包含以下内容：

- 公共证书
- 中间证书（如果有）
- 私钥

要从 PKCS #12 文件中导出所需的 PEM 编码文件，可以使用 `openssl` 命令：

```shell
#-- Extract private key in PEM encoding (no password, unencrypted)
openssl pkcs12 -in gitlab.p12 -nocerts -nodes -out gitlab.key

#-- Extract certificates in PEM encoding (full certs chain including CA)
openssl pkcs12 -in gitlab.p12 -nokeys -out gitlab.crt
```
