---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 S/MIME 签名发出的邮件
description: 为发出的邮件配置 S/MIME。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 发出的通知邮件可使用 S/MIME 签名，以提高安全性。

需要注意 S/MIME 证书与 TLS/SSL 证书并不相同，它们用于不同目的：TLS 创建安全通道，而 S/MIME 对消息本身进行签名和/或加密。

<a id="enable-smime-signing"></a>

## 启用 S/MIME 签名

此设置必须明确启用，并且必须提供一对密钥和证书文件：

- 两个文件都必须采用 PEM 编码。
- 密钥文件必须未加密，以便 极狐GitLab 能够无需用户干预即可读取。
- 仅支持 RSA 密钥。

也可以选择提供一组 CA 证书（PEM 编码），以包含在每个签名中。这通常是一个中间 CA。

> [!warning]
> 注意私钥的访问级别以及第三方可见性。

对于 Linux 安装包：

1. 编辑 `/etc/gitlab/gitlab.rb` 并调整文件路径：

   ```ruby
   gitlab_rails['gitlab_email_smime_enabled'] = true
   gitlab_rails['gitlab_email_smime_key_file'] = '/etc/gitlab/ssl/gitlab_smime.key'
   gitlab_rails['gitlab_email_smime_cert_file'] = '/etc/gitlab/ssl/gitlab_smime.crt'
   # 可选
   gitlab_rails['gitlab_email_smime_ca_certs_file'] = '/etc/gitlab/ssl/gitlab_smime_cas.crt'
   ```

1. 保存文件并[重新配置 极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

密钥必须可由 极狐GitLab 系统用户（默认为 `git`）读取。

对于自行编译的安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
   email_smime:
     # 如果需要启用电子邮件 S/MIME 签名，请取消注释并设置为 true（默认：false）
     enabled: true
     # S/MIME 私钥文件，PEM 格式，未加密
     # 默认为相对于 Rails.root（极狐GitLab 应用程序的根目录）的 '.gitlab_smime_key'。
     key_file: /etc/pki/smime/private/gitlab.key
     # S/MIME 公钥证书，PEM 格式，将附加到签名的邮件中
     # 默认为相对于 Rails.root（极狐GitLab 应用程序的根目录）的 '.gitlab_smime_cert'。
     cert_file: /etc/pki/smime/certs/gitlab.crt
     # S/MIME 额外的 CA 公钥证书，PEM 格式，将附加到签名的邮件中
     # 可选
     ca_certs_file: /etc/pki/smime/certs/gitlab_cas.crt
   ```

1. 保存文件并[重启 极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。

密钥必须可由 极狐GitLab 系统用户（默认为 `git`）读取。

<a id="how-to-convert-smime-pkcs-12-format-to-pem-encoding"></a>

### 如何将 S/MIME PKCS #12 格式转换为 PEM 编码

通常，S/MIME 证书以二进制公钥加密标准 (PKCS) #12 格式（`.pfx` 或 `.p12` 扩展名）处理，其中在单个加密文件中包含以下内容：

- 公共证书
- 中间证书（如果有）
- 私钥

要从 PKCS #12 文件中导出 PEM 编码的所需文件，可以使用 `openssl` 命令：

```shell
#-- 导出 PEM 编码的私钥（无密码，未加密）
openssl pkcs12 -in gitlab.p12 -nocerts -nodes -out gitlab.key

#-- 导出 PEM 编码的证书（包括 CA 在内的完整证书链）
openssl pkcs12 -in gitlab.p12 -nokeys -out gitlab.crt
```