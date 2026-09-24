---
title: '教程：安装并加固单节点极狐GitLab实例'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

在本教程中，您将学习如何安装并安全配置一个单节点极狐GitLab实例，该实例最多可支持 [20 RPS 或 1,000 名用户](../../administration/reference_architectures/1k_users.md)。

要安装单节点极狐GitLab实例并进行安全配置：

1. [加固服务器](#secure-the-server)
1. [安装极狐GitLab](#install-gitlab)
1. [配置极狐GitLab](#configure-gitlab)
1. [后续步骤](#next-steps)

<a id="before-you-begin"></a>

## 准备工作

- 一个域名，以及正确的 [DNS 设置](https://gitlab.cn/docs/omnibus/settings/dns/)。
- 一个基于 Debian 的服务器，最低配置要求：
  - 8 vCPU
  - 7.2 GB 内存
  - 为所有仓库提供足够的硬盘空间。
    阅读更多关于[存储要求](../../install/requirements.md)的信息。

<a id="secure-the-server"></a>

## 加固服务器

在安装极狐GitLab之前，先对服务器进行一些加固配置。

<a id="configure-the-firewall"></a>

### 配置防火墙

您需要开放端口 22（SSH）、80（HTTP）和 443（HTTPS）。您可以通过云服务商的控制台或在服务器层面进行配置。

在本示例中，您将使用 `ufw` 配置防火墙。您将拒绝所有端口访问，允许 80 和 443 端口，最后对 22 端口进行速率限制。`ufw` 可以拒绝在最近 30 秒内尝试发起 6 次或更多连接的 IP 地址。

1. 安装 `ufw`：

   ```shell
   sudo apt install ufw
   ```

1. 启用并启动 `ufw` 服务：

   ```shell
   sudo systemctl enable --now ufw
   ```

1. 拒绝除必需端口外的所有其他端口：

   ```shell
   sudo ufw default deny
   sudo ufw allow http
   sudo ufw allow https
   sudo ufw limit ssh/tcp
   ```

1. 最后，激活设置。以下命令仅需在首次安装软件包时运行一次。当提示时，回答 yes（`y`）：

   ```shell
   sudo ufw enable
   ```

1. 验证规则是否生效：

   ```shell
   $ sudo ufw status

   Status: active

   To                         Action      From
   --                         ------      ----
   80/tcp                     ALLOW       Anywhere
   443                        ALLOW       Anywhere
   22/tcp                     LIMIT       Anywhere
   80/tcp (v6)                ALLOW       Anywhere (v6)
   443 (v6)                   ALLOW       Anywhere (v6)
   22/tcp (v6)                LIMIT       Anywhere (v6)
   ```

<a id="configure-the-ssh-server"></a>

### 配置 SSH 服务器

为了进一步加固服务器，将 SSH 配置为接受公钥认证，并禁用一些存在潜在安全风险的功能。

1. 使用编辑器打开 `/etc/ssh/sshd_config`，并确保以下内容存在：

   ```plaintext
   PubkeyAuthentication yes
   PasswordAuthentication yes
   UsePAM yes
   UseDNS no
   AllowTcpForwarding no
   X11Forwarding no
   PrintMotd no
   PermitTunnel no
   # 允许客户端传递区域环境变量
   AcceptEnv LANG LC_*
   # 覆盖默认的无子系统
   Subsystem       sftp    /usr/lib/openssh/sftp-server
   # 协议调整，在 FIPS 或 FedRAMP 部署中可能需要/推荐
   # 并且仅使用强大和经过验证的算法选择
   Protocol 2
   Ciphers aes128-ctr,aes192-ctr,aes256-ctr
   HostKeyAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521
   KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521
   Macs hmac-sha2-256,hmac-sha2-512
   ```

1. 保存文件并重启 SSH 服务器：

   ```shell
   sudo systemctl restart ssh
   ```

   如果重启 SSH 失败，请检查 `/etc/ssh/sshd_config` 中是否存在任何重复条目。

<a id="ensure-only-authorized-users-are-using-ssh-for-git-access"></a>

### 确保仅授权用户使用 SSH 进行 Git 访问

接下来，确保用户无法通过 SSH 拉取项目，除非他们拥有能够通过 SSH 执行 Git 操作的有效极狐GitLab 帐户。

要确保仅授权用户使用 SSH 进行 Git 访问：

1. 将以下内容添加到 `/etc/ssh/sshd_config` 文件：

   ```plaintext
   # 确保只有授权用户在使用 Git
   AcceptEnv GIT_PROTOCOL
   ```

1. 保存文件并重启 SSH 服务器：

   ```shell
   sudo systemctl restart ssh
   ```

<a id="make-some-kernel-adjustments"></a>

### 进行一些内核调整

内核调整并不能完全消除攻击威胁，但可以增加一层额外的安全性。

1. 使用编辑器在 `/etc/sysctl.d` 下新建一个文件，例如 `/etc/sysctl.d/99-gitlab-hardening.conf`，并添加以下内容。

   > [!note]
   > 命名和源目录决定了处理顺序，这一点很重要，因为最后处理的参数可能会覆盖之前的参数。

   ```plaintext
   ##
   ## 以下配置有助于缓解越界、空指针解引用、堆和缓冲区溢出漏洞、
   ## use-after-free 等被利用的风险。虽然不能 100% 解决问题，但严重阻碍了漏洞利用。
   ##
   # 默认值为 65536，4096 有助于缓解利用中使用内存问题
   vm.mmap_min_addr=4096
   # 默认值为 0，随机化内存中的虚拟地址空间，使漏洞利用更难
   kernel.randomize_va_space=2
   # 限制内核指针访问（例如 cat /proc/kallsyms）以阻止辅助利用
   kernel.kptr_restrict=2
   # 限制 dmesg 中的详细内核错误信息
   kernel.dmesg_restrict=1
   # 限制 eBPF
   kernel.unprivileged_bpf_disabled=1
   net.core.bpf_jit_harden=2
   # 防止常见的 use-after-free 漏洞利用
   vm.unprivileged_userfaultfd=0

   ## 网络调优 ##
   ##
   ## 防止 IP 堆栈层的常见攻击
   ##
   # 防止 SYNFLOOD 拒绝服务攻击
   net.ipv4.tcp_syncookies=1
   # 防止 time wait 暗杀攻击
   net.ipv4.tcp_rfc1337=1
   # IP 欺骗/源路由保护
   net.ipv4.conf.all.rp_filter=1
   net.ipv4.conf.default.rp_filter=1
   net.ipv6.conf.all.accept_ra=0
   net.ipv6.conf.default.accept_ra=0
   net.ipv4.conf.all.accept_source_route=0
   net.ipv4.conf.default.accept_source_route=0
   net.ipv6.conf.all.accept_source_route=0
   net.ipv6.conf.default.accept_source_route=0
   # IP 重定向保护
   net.ipv4.conf.all.accept_redirects=0
   net.ipv4.conf.default.accept_redirects=0
   net.ipv4.conf.all.secure_redirects=0
   net.ipv4.conf.default.secure_redirects=0
   net.ipv6.conf.all.accept_redirects=0
   net.ipv6.conf.default.accept_redirects=0
   net.ipv4.conf.all.send_redirects=0
   net.ipv4.conf.default.send_redirects=0
   ```

1. 在下次服务器重启时，这些值将自动加载。要立即加载它们：

   ```shell
   sudo sysctl --system
   ```

做得很好，您已完成加固服务器的步骤！现在可以安装极狐GitLab了。

<a id="install-gitlab"></a>

## 安装极狐GitLab

现在您的服务器已设置好，开始安装极狐GitLab：

1. 安装并配置必要的依赖项：

   ```shell
   sudo apt update
   sudo apt install -y curl openssh-server ca-certificates perl locales
   ```

1. 配置系统语言：

   1. 编辑 `/etc/locale.gen`，确保 `en_US.UTF-8` 未被注释。
   1. 重新生成语言：

      ```shell
      sudo locale-gen
      ```

1. 添加极狐GitLab 软件包仓库并安装软件包：

   ```shell
   curl --location "https://packages.gitlab.cn/repository/raw/scripts/setup.sh" | sudo bash
   ```

1. 安装极狐GitLab 软件包。使用 `GITLAB_ROOT_PASSWORD` 设置一个强密码，并将 `EXTERNAL_URL` 替换为您自己的域名。别忘了在 URL 中包含 `https`，这样会签发 Let's Encrypt 证书。

   ```shell
   sudo GITLAB_ROOT_PASSWORD="strong password" EXTERNAL_URL="https://gitlab.example.com" apt install gitlab-ee
   ```

   要了解有关 Let's Encrypt 证书或使用您自己的证书的更多信息，请阅读如何[使用 TLS 配置极狐GitLab](https://gitlab.cn/docs/omnibus/settings/ssl/)。

   如果您设置的密码未被应用，请阅读有关[重置 root 帐户密码](../../security/reset_user_password.md#reset-the-root-password)的更多信息。
1. 几分钟后，极狐GitLab 安装完成。使用您在 `EXTERNAL_URL` 中设置的 URL 登录。用户名为 `root`，密码为您在 `GITLAB_ROOT_PASSWORD` 中设置的密码。

现在是配置极狐GitLab 的时候了！

<a id="configure-gitlab"></a>

## 配置极狐GitLab

极狐GitLab 附带了一些合理的默认配置选项。在本节中，我们将更改它们以增加更多功能，并使极狐GitLab 更安全。

对于某些选项，您将使用 **管理员** 区域的 UI，对于另一些选项，您将编辑 `/etc/gitlab/gitlab.rb`，即极狐GitLab 配置文件。

<a id="configure-nginx"></a>

### 配置 NGINX

NGINX 用于提供访问极狐GitLab 实例的 Web 界面。有关如何更安全地配置 NGINX 的更多信息，请阅读关于[加固 NGINX](../../security/hardening_configuration_recommendations.md#nginx) 的内容。

<a id="configure-emails"></a>

### 配置电子邮件

接下来，您将设置并配置电子邮件服务。电子邮件对于验证新注册、重置密码以及通知您极狐GitLab 活动非常重要。

<a id="configure-smtp"></a>

#### 配置 SMTP

在本教程中，您将设置一个 [SMTP](https://gitlab.cn/docs/omnibus/settings/smtp/) 服务器，并使用 [Mailgun](https://www.mailgun.com/) SMTP 提供商。

首先，创建一个包含登录凭据的加密文件，然后为 Linux 软件包配置 SMTP：

1. 创建一个 YAML 文件（例如 `smtp.yaml`），其中包含 SMTP 服务器的凭据。

   您的 SMTP 密码不能包含 Ruby 或 YAML 中使用的任何字符串分隔符（例如 `'`），以避免在处理配置设置时出现意外行为。

   ```shell
   user_name: '<SMTP user>'
   password: '<SMTP password>'
   ```

1. 加密该文件：

   ```shell
   cat smtp.yaml | sudo gitlab-rake gitlab:smtp:secret:write
   ```

   默认情况下，加密文件存储在 `/var/opt/gitlab/gitlab-rails/shared/encrypted_settings/smtp.yaml.enc` 下。
1. 删除 YAML 文件：

   ```shell
   rm -f smtp.yaml
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并设置其余的 SMTP 设置。确保 **不** 存在 `gitlab_rails['smtp_user_name']` 和 `gitlab_rails['smtp_password']`，因为我们已将它们设置为加密形式。

   ```ruby
   gitlab_rails['smtp_enable'] = true
   gitlab_rails['smtp_address'] = "smtp.mailgun.org" # or smtp.eu.mailgun.org
   gitlab_rails['smtp_port'] = 587
   gitlab_rails['smtp_authentication'] = "plain"
   gitlab_rails['smtp_enable_starttls_auto'] = true
   gitlab_rails['smtp_domain'] = "<mailgun domain>"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

现在您应该能够发送电子邮件了。要测试配置是否成功：

1. 进入 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 在控制台提示符下运行以下命令，让极狐GitLab 发送一封测试邮件：

   ```ruby
   Notify.test_email('<email_address>', 'Message Subject', 'Message Body').deliver_now
   ```

如果您无法发送电子邮件，请参阅 [SMTP 故障排查部分](https://gitlab.cn/docs/omnibus/settings/smtp/#troubleshooting)。

<a id="require-email-verification-for-locked-accounts"></a>

#### 要求为锁定的帐户进行电子邮件验证

帐户电子邮件验证为极狐GitLab 帐户安全提供了额外的保护层。当满足某些条件时，例如在 24 小时内出现三次或更多次登录失败尝试，帐户将被锁定。

前提条件：

- 您必须是管理员。

要求为锁定的帐户进行电子邮件验证：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **登录限制**。
1. 选中 **为锁定的帐户启用电子邮件验证** 复选框。
1. 选择 **保存更改**。

有关更多信息，请阅读有关[帐户电子邮件验证](../../security/email_verification.md)的内容。

<a id="sign-outgoing-email-with-smime"></a>

#### 使用 S/MIME 签名外发邮件

极狐GitLab 发送的通知邮件可以使用 [S/MIME](https://en.wikipedia.org/wiki/S/MIME) 进行签名，以提高安全性。

必须提供一对密钥和证书文件：

- 两个文件必须是 PEM 编码。
- 密钥文件必须未加密，以便极狐GitLab 无需用户干预即可读取。
- 仅支持 RSA 密钥。
- 可选。您可以提供一组证书颁发机构 (CA) 证书（PEM 编码）以包含在每个签名中。这通常是中间 CA。

1. 从 CA 购买证书。
1. 编辑 `/etc/gitlab/gitlab.rb` 并调整文件路径：

   ```ruby
   gitlab_rails['gitlab_email_smime_enabled'] = true
   gitlab_rails['gitlab_email_smime_key_file'] = '/etc/gitlab/ssl/gitlab_smime.key'
   gitlab_rails['gitlab_email_smime_cert_file'] = '/etc/gitlab/ssl/gitlab_smime.crt'
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

有关更多信息，请阅读关于[使用 S/MIME 签名外发邮件](../../administration/smime_signing_email.md)的内容。

<a id="next-steps"></a>

## 后续步骤

在本教程中，您学习了如何设置服务器使其更安全，如何安装极狐GitLab，以及如何配置极狐GitLab 以达到一些安全标准。您还可以采取一些[其他步骤](../../security/hardening_application_recommendations.md)来加固极狐GitLab，包括：

- 禁用注册。默认情况下，新的极狐GitLab 实例启用了用户注册。如果您不打算公开您的极狐GitLab 实例，您应该禁用注册。
- 使用特定电子邮件域允许或拒绝注册。
- 为新用户设置最小密码长度限制。
- 为所有用户强制执行双因素认证。

除了加固极狐GitLab 实例外，您还可以配置许多其他内容，例如配置您自己的 Runner 以利用极狐GitLab 提供的 CI/CD 功能，或正确备份您的实例。

您可以阅读有关[安装后需要采取的步骤](../../install/next_steps.md)的更多信息。