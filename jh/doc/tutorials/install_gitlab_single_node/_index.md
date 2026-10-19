---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：安装并保护单节点极狐GitLab 实例'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

在本教程中，您将学习如何安装并安全地配置一个单节点极狐GitLab 实例，该实例最多可支持 [20 RPS 或 1,000 名用户](../../administration/reference_architectures/1k_users.md)。

要安装单节点极狐GitLab 实例并将其配置为安全状态：

1. [保护服务器](#secure-the-server)
1. [安装极狐GitLab](#install-gitlab)
1. [配置极狐GitLab](#configure-gitlab)
1. [后续步骤](#next-steps)

<a id="before-you-begin"></a>

## 开始之前

- 一个域名，以及正确的 [DNS 设置](https://gitlab.cn/docs/omnibus/settings/dns/)。
- 一台基于 Debian 的服务器，至少满足以下规格：
  - 8 vCPU
  - 7.2 GB 内存
  - 有足够的硬盘空间来存放您的所有代码仓库。
    详细了解
    [存储要求](../../install/requirements.md)。

<a id="secure-the-server"></a>

## 保护服务器

在安装极狐GitLab 之前，先配置您的服务器，使其更安全一些。

<a id="configure-the-firewall"></a>

### 配置防火墙

您需要开放 22（SSH）、80（HTTP）和 443（HTTPS）端口。您可以通过云服务商的控制台，或在服务器层面完成此操作。

在本示例中，您将使用 [`ufw`](https://wiki.ubuntu.com/UncomplicatedFirewall) 配置防火墙。您将拒绝访问所有端口，允许端口 80 和 443，最后对端口 22 的访问进行速率限制。`ufw` 可以拒绝在过去 30 秒内尝试发起 6 次或更多连接的 IP 地址的连接。

1. 安装 `ufw`：

   ```shell
   sudo apt install ufw
   ```

1. 启用并启动 `ufw` 服务：

   ```shell
   sudo systemctl enable --now ufw
   ```

1. 拒绝除所需端口之外的所有其他端口：

   ```shell
   sudo ufw default deny
   sudo ufw allow http
   sudo ufw allow https
   sudo ufw limit ssh/tcp
   ```

1. 最后，激活这些设置。以下操作只需在首次安装该软件包时运行一次。出现提示时回答 yes（`y`）：

   ```shell
   sudo ufw enable
   ```

1. 验证规则已存在：

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

为了进一步保护您的服务器，请将 SSH 配置为接受公钥认证，并禁用一些存在潜在安全风险的功能。

1. 使用编辑器打开 `/etc/ssh/sshd_config`，并确保其中包含以下内容：

   ```plaintext
   PubkeyAuthentication yes
   PasswordAuthentication yes
   UsePAM yes
   UseDNS no
   AllowTcpForwarding no
   X11Forwarding no
   PrintMotd no
   PermitTunnel no
   # Allow client to pass locale environment variables
   AcceptEnv LANG LC_*
   # override default of no subsystems
   Subsystem       sftp    /usr/lib/openssh/sftp-server
   # Protocol adjustments, these would be needed/recommended in a FIPS or
   # FedRAMP deployment, and use only strong and proven algorithm choices
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

   如果重启 SSH 失败，请检查 `/etc/ssh/sshd_config`中是否存在重复条目。

<a id="ensure-only-authorized-users-are-using-ssh-for-git-access"></a>

### 确保只有授权用户才能使用 SSH 进行 Git 访问

接下来，确保用户只有在拥有可执行基于 SSH 的 Git 操作的有效极狐GitLab 账号时，才能通过 SSH 拉取项目。

要确保只有授权用户才能使用 SSH 进行 Git 访问：

1. 将以下内容添加到您的 `/etc/ssh/sshd_config` 文件中：

   ```plaintext
   # Ensure only authorized users are using Git
   AcceptEnv GIT_PROTOCOL
   ```

1. 保存文件并重启 SSH 服务器：

   ```shell
   sudo systemctl restart ssh
   ```

<a id="make-some-kernel-adjustments"></a>

### 进行一些内核调整

内核调整并不能完全消除攻击威胁，但它们会增加一层额外的安全防护。

1. 使用编辑器在 `/etc/sysctl.d` 下新建一个文件，例如
   `/etc/sysctl.d/99-gitlab-hardening.conf`，并添加以下内容。

   > [!note]
   > 命名和源目录决定处理顺序，这一点很重要，因为最后处理的参数可能会覆盖先前的参数。

   ```plaintext
   ##
   ## The following help mitigate out of bounds, null pointer dereference, heap and
   ## buffer overflow bugs, use-after-free etc from being exploited. It does not 100%
   ## fix the issues, but seriously hampers exploitation.
   ##
   # Default is 65536, 4096 helps mitigate memory issues used in exploitation
   vm.mmap_min_addr=4096
   # Default is 0, randomize virtual address space in memory, makes vuln exploitation
   # harder
   kernel.randomize_va_space=2
   # Restrict kernel pointer access (for example, cat /proc/kallsyms) for exploit assistance
   kernel.kptr_restrict=2
   # Restrict verbose kernel errors in dmesg
   kernel.dmesg_restrict=1
   # Restrict eBPF
   kernel.unprivileged_bpf_disabled=1
   net.core.bpf_jit_harden=2
   # Prevent common use-after-free exploits
   vm.unprivileged_userfaultfd=0

   ## Networking tweaks ##
   ##
   ## Prevent common attacks at the IP stack layer
   ##
   # Prevent SYNFLOOD denial of service attacks
   net.ipv4.tcp_syncookies=1
   # Prevent time wait assassination attacks
   net.ipv4.tcp_rfc1337=1
   # IP spoofing/source routing protection
   net.ipv4.conf.all.rp_filter=1
   net.ipv4.conf.default.rp_filter=1
   net.ipv6.conf.all.accept_ra=0
   net.ipv6.conf.default.accept_ra=0
   net.ipv4.conf.all.accept_source_route=0
   net.ipv4.conf.default.accept_source_route=0
   net.ipv6.conf.all.accept_source_route=0
   net.ipv6.conf.default.accept_source_route=0
   # IP redirection protection
   net.ipv4.conf.all.accept_redirects=0
   net.ipv4.conf.default.accept_redirects=0
   net.ipv4.conf.all.secure_redirects=0
   net.ipv4.conf.default.secure_redirects=0
   net.ipv6.conf.all.accept_redirects=0
   net.ipv6.conf.default.accept_redirects=0
   net.ipv4.conf.all.send_redirects=0
   net.ipv4.conf.default.send_redirects=0
   ```

1. 在服务器下次重启时，这些值将自动加载。要立即加载它们：

   ```shell
   sudo sysctl --system
   ```

做得好，您已完成保护服务器的步骤！现在可以安装极狐GitLab 了。

<a id="install-gitlab"></a>

## 安装极狐GitLab

服务器已设置完毕，现在安装极狐GitLab：

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

1. 安装极狐GitLab 软件包。通过
   `GITLAB_ROOT_PASSWORD` 提供一个强密码，并将 `EXTERNAL_URL`
   替换为您自己的地址。别忘了在 URL 中包含 `https`，以便签发 Let's Encrypt
   证书。

   ```shell
   sudo GITLAB_ROOT_PASSWORD="strong password" EXTERNAL_URL="https://gitlab.example.com" apt install gitlab-ee
   ```

   要详细了解 Let's Encrypt 证书，或使用您自己的证书，请阅读如何[使用 TLS 配置极狐GitLab](https://gitlab.cn/docs/omnibus/settings/ssl/)。

   如果您设置的密码未被采用，请阅读有关
   [重置 root 账号密码](../../security/reset_user_password.md#reset-the-root-password)的内容。
1. 几分钟后，极狐GitLab 即安装完成。使用您在 `EXTERNAL_URL`中设置的 URL 登录。使用 `root` 作为用户名，并使用您在 `GITLAB_ROOT_PASSWORD`中设置的密码。

现在该配置极狐GitLab 了！

<a id="configure-gitlab"></a>

## 配置极狐GitLab

极狐GitLab 自带一些合理的默认配置选项。在本节中，我们将更改这些选项以增加更多功能，并让极狐GitLab 更加安全。

对于其中一些选项，您将使用**管理员**区域 UI，而对于另一些选项，您将编辑 `/etc/gitlab/gitlab.rb`，即极狐GitLab 配置文件。

<a id="configure-nginx"></a>

### 配置 NGINX

NGINX 用于提供访问极狐GitLab 实例的 Web 界面。有关将 NGINX 配置得更安全的更多信息，请阅读
[加固 NGINX](../../security/hardening_configuration_recommendations.md#nginx)。

<a id="configure-emails"></a>

### 配置电子邮件

接下来，您将设置并配置电子邮件服务。电子邮件对于验证新用户账号、重置密码以及通知您极狐GitLab 活动非常重要。

<a id="configure-smtp"></a>

#### 配置 SMTP

在本教程中，您将设置一个 [SMTP](https://gitlab.cn/docs/omnibus/settings/smtp/)
服务器，并使用 [Mailgun](https://www.mailgun.com/) SMTP 提供商。

首先，创建一个包含登录凭据的加密文件，然后为 Linux 软件包配置 SMTP：

1. 创建一个 YAML 文件（例如 `smtp.yaml`），其中包含
   SMTP 服务器的凭据。

   您的 SMTP 密码不得包含 Ruby 或 YAML 中使用的任何字符串分隔符
   （例如 `'`），以避免在处理配置设置时出现意外行为。

   ```shell
   user_name: '<SMTP user>'
   password: '<SMTP password>'
   ```

1. 加密该文件：

   ```shell
   cat smtp.yaml | sudo gitlab-rake gitlab:smtp:secret:write
   ```

   默认情况下，加密文件存储在
   `/var/opt/gitlab/gitlab-rails/shared/encrypted_settings/smtp.yaml.enc`。
1. 删除该 YAML 文件：

   ```shell
   rm -f smtp.yaml
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并设置其余的 SMTP 设置。
   确保 `gitlab_rails['smtp_user_name']` 和 `gitlab_rails['smtp_password']`
   不存在，因为我们已经将它们设置为加密形式。

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

现在您应该能够发送电子邮件了。要测试配置是否生效：

1. 进入 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 在控制台提示符下运行以下命令，让极狐GitLab 发送一封测试电子邮件：

   ```ruby
   Notify.test_email('<email_address>', 'Message Subject', 'Message Body').deliver_now
   ```

如果您无法发送电子邮件，请参阅 [SMTP 故障排除部分](https://gitlab.cn/docs/omnibus/settings/smtp/#troubleshooting)。

<a id="require-email-verification-for-locked-accounts"></a>

#### 要求为锁定账号进行电子邮件验证

账号电子邮件验证为极狐GitLab 账号安全提供了额外一层保护。当满足某些条件时，例如在 24 小时内有三次或更多次登录失败尝试，账号将被锁定。

先决条件：

- 您必须是管理员。

要为锁定账号进行电子邮件验证：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**登录限制**。
1. 选中**锁定账号的电子邮件验证**复选框。
1. 选择**保存更改**。

有关更多信息，请阅读[账号电子邮件验证](../../security/email_verification.md)。

<a id="sign-outgoing-email-with-smime"></a>

#### 使用 S/MIME 对发出的电子邮件进行签名

极狐GitLab 发送的通知电子邮件可以使用 [S/MIME](https://en.wikipedia.org/wiki/S/MIME) 进行签名，以提高安全性。

必须提供一对密钥和证书文件：

- 两个文件都必须采用 PEM 编码。
- 密钥文件必须未加密，以便极狐GitLab 无需用户干预即可读取。
- 仅支持 RSA 密钥。
- 可选。您可以提供一个证书颁发机构（CA）证书捆绑包
  （PEM 编码），以包含在每个签名中。这通常是
  中间 CA。

1. 从 CA 购买您的证书。
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

有关更多信息，请阅读[使用 S/MIME 对发出的电子邮件进行签名](../../administration/smime_signing_email.md)。

<a id="next-steps"></a>

## 后续步骤

在本教程中，您学习了如何将服务器设置得更安全、如何安装极狐GitLab，以及如何配置极狐GitLab 以满足某些安全标准。您可以采取的其他一些[加固极狐GitLab 的步骤](../../security/hardening_application_recommendations.md)包括：

- 禁用新用户账号。默认情况下，新的极狐GitLab 实例会启用新用户账号。如果您不
  打算将极狐GitLab 实例公开，则应禁用新用户账号。
- 使用特定电子邮件域名允许或拒绝新用户账号。
- 为新用户设置最小密码长度限制。
- 对所有用户强制实施双重身份验证。

除了加固极狐GitLab 实例之外，您还可以配置许多其他内容，例如配置您自己的 runner 以利用极狐GitLab 提供的 CI/CD 功能，或正确备份您的实例。

您可以阅读更多关于[安装后要采取的步骤](../../install/next_steps.md)的内容。
