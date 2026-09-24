---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 传入邮件
description: 配置传入邮件。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 具有多项基于接收传入电子邮件消息的功能：

- [通过邮件回复](reply_by_email.md)：允许极狐GitLab 用户通过回复通知邮件来评论议题和合并请求。
- [通过邮件创建议题](../user/project/issues/create_issues.md#by-sending-an-email)：允许极狐GitLab 用户通过向用户专属的电子邮件地址发送邮件来创建新议题。
- [通过邮件创建新的合并请求](../user/project/merge_requests/creating_merge_requests.md#by-sending-an-email)：允许极狐GitLab 用户通过向用户专属的电子邮件地址发送邮件来创建新的合并请求。
- [服务台](../user/project/service_desk/_index.md)：通过极狐GitLab 为您的客户提供电子邮件支持。

<a id="requirements"></a>

## 要求

您应使用一个仅接收专门发送给极狐GitLab 实例消息的电子邮件地址。任何非专门发送给极狐GitLab 的传入电子邮件消息都会收到拒绝通知。

处理传入电子邮件消息需要一个支持 [IMAP](https://en.wikipedia.org/wiki/Internet_Message_Access_Protocol) 的电子邮件账户。极狐GitLab 需要以下三种策略之一：

- 电子邮件子地址（推荐）
- 捕获所有邮件的邮箱
- 专用电子邮件地址（仅支持通过邮件回复）

下面逐一介绍这些选项。

<a id="email-sub-addressing"></a>

### 电子邮件子地址

[子地址](https://en.wikipedia.org/wiki/Email_address#Sub-addressing) 是一项邮件服务器功能，发送到 `user+arbitrary_tag@example.com` 的任何邮件最终都会进入 `user@example.com` 的邮箱。Gmail、Google Apps、Yahoo! Mail、Outlook.com 和 iCloud 等提供商以及您可以在本地运行的 [Postfix 邮件服务器](reply_by_email_postfix_setup.md) 均支持此功能。Microsoft Exchange Server [不支持子地址](#microsoft-exchange-server)，Microsoft Office 365 [默认不支持子地址](#microsoft-office-365)。

> [!note]
> 如果您的提供商或服务器支持电子邮件子地址，则应使用它。
> 专用电子邮件地址仅支持通过邮件回复功能。
> 捕获所有邮件的邮箱支持与子地址相同的功能，
> 但仍首选子地址，因为只使用一个电子邮件地址，
> 从而可以将捕获所有邮件的邮箱保留用于极狐GitLab 之外的其他用途。

<a id="catch-all-mailbox"></a>

### 捕获所有邮件的邮箱

域的[捕获所有邮件的邮箱](https://en.wikipedia.org/wiki/Catch-all) 会接收发送到该域的所有电子邮件消息，这些消息不匹配邮件服务器上存在的任何地址。

捕获所有邮件的邮箱支持与电子邮件子地址相同的功能，但您仍应使用电子邮件子地址，以便将捕获所有邮件的邮箱保留用于其他用途。

<a id="dedicated-email-address"></a>

### 专用电子邮件地址

要设置此解决方案，您必须创建一个专用的电子邮件地址来接收用户对极狐GitLab 通知的回复。但是，此方法仅支持回复，不支持传入电子邮件的其他功能。

<a id="accepted-headers"></a>

## 接受的标头

当配置的电子邮件地址出现在以下任一标头中时，邮件会被正确处理（按检查顺序排序）：

- `To`
- `Delivered-To`
- `X-Delivered-To`
- `Envelope-To` 或 `X-Envelope-To`
- `Received`
- `X-Original-To`
- `X-Forwarded-To`
- `Cc`

`References` 标头也被接受，但它专门用于将邮件回复与现有讨论线程关联起来，不用于通过邮件创建议题。

[服务台](../user/project/service_desk/_index.md) 也会检查接受的标头。

通常，`To` 字段包含主要接收者的电子邮件地址。但是，在以下情况下，它可能不包含配置的极狐GitLab 电子邮件地址：

- 该地址位于 `BCC` 字段中。
- 邮件被转发。

`Received` 标头可以包含多个电子邮件地址。这些地址会按出现顺序检查，使用第一个匹配项。

<a id="rejected-headers"></a>

## 拒绝的标头

为防止自动电子邮件系统创建不需要的议题，极狐GitLab 会忽略所有包含以下标头的传入电子邮件：

- `Auto-Submitted`，其值不是 `no`
- `X-Autoreply`，其值为 `yes`

<a id="set-it-up"></a>

## 设置

如果您想将 Gmail / Google Apps 用于传入电子邮件，请确保您已[启用 IMAP 访问](https://support.google.com/mail/answer/7126229) 并[允许不够安全的应用程序访问账户](https://support.google.com/accounts/answer/6010255)，或者[开启两步验证](https://support.google.com/accounts/answer/185839) 并使用[应用专用密码](https://support.google.com/mail/answer/185833)。

如果您想使用 Office 365，并且已开启双因素身份验证，请确保您使用的是[应用专用密码](https://support.microsoft.com/en-US/accounts-billing/work-school/create-app-passwords-for-your-work-or-school-account)，而不是邮箱的常规密码。

要在 Ubuntu 上设置一个支持 IMAP 访问的基本 Postfix 邮件服务器，请遵循 [Postfix 设置文档](reply_by_email_postfix_setup.md)。

<a id="security-concerns"></a>

### 安全注意事项

> [!warning]
> 选择用于接收传入电子邮件的域时请务必小心。

例如，假设您公司的顶级域是 `hooli.com`。您公司的所有员工都通过 Google Workspace 在该域拥有电子邮件地址，并且您公司的私有 Slack 实例要求提供有效的 `@hooli.com` 电子邮件地址才能创建用户账户。

如果您还在 `hooli.com` 托管一个面向公众的极狐GitLab 实例，并将传入电子邮件域设置为 `hooli.com`，则攻击者可能会在注册 Slack 时使用项目的唯一地址作为电子邮件，从而滥用“通过邮件创建议题”或[通过邮件创建新的合并请求](../user/project/merge_requests/creating_merge_requests.md#by-sending-an-email) 功能。这将发送一封确认邮件，从而在攻击者拥有的项目上创建一个新议题或合并请求，使他们能够选择确认链接并在您公司的私有 Slack 实例上验证其账户。

您应该在子域上接收传入电子邮件，例如 `incoming.hooli.com`，并确保您不使用任何仅基于访问诸如 `*.hooli.com.` 之类的电子邮件域进行身份验证的服务。或者，为极狐GitLab 电子邮件通信使用专用域，例如 `hooli-gitlab.com`。

有关此漏洞利用的真实示例，请参阅极狐GitLab 议题 [#30366](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/30366)。

> [!warning]
> 使用已配置为减少垃圾邮件的邮件服务器。
> 例如，在默认配置下运行的 Postfix 邮件服务器可能会导致滥用。配置的邮箱上收到的所有消息都会被处理，非专门发送给极狐GitLab 实例的消息会收到拒绝通知。
> 如果发件人地址被伪造，拒绝通知将发送到被伪造的 `FROM` 地址，这可能导致邮件服务器的 IP 或域出现在阻止列表中。

用户无需先使用双因素身份验证 (2FA) 进行身份验证即可使用传入电子邮件功能。即使您已为实例[强制执行双因素身份验证](../security/two_factor_authentication.md)，此规则也适用。

<a id="linux-package-installations"></a>

### Linux 软件包安装

1. 在 `/etc/gitlab/gitlab.rb` 中找到 `incoming_email` 部分，开启该功能并填写您的特定 IMAP 服务器和电子邮件账户的详细信息（请参阅下面的[示例](#configuration-examples)）。

1. 重新配置极狐GitLab 以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure

   # Needed when enabling or disabling for the first time but not for password changes.
   # See https://gitlab.com/gitlab-org/gitlab-foss/-/issues/23560#note_61966788
   sudo gitlab-ctl restart
   ```

1. 验证所有内容是否配置正确：

   ```shell
   sudo gitlab-rake gitlab:incoming_email:check
   ```

通过邮件回复现在应该可以正常工作了。

<a id="self-compiled-installations"></a>

### 自行编译安装

1. 进入极狐GitLab 安装目录：

   ```shell
   cd /home/git/gitlab
   ```

1. 手动安装 `gitlab-mail_room` gem：

   ```shell
   gem install gitlab-mail_room
   ```

   > [!note]
   > 此步骤对于避免线程死锁并支持最新的 MailRoom 功能是必需的。

1. 在 `config/gitlab.yml` 中找到 `incoming_email` 部分，开启该功能并填写您的特定 IMAP 服务器和电子邮件账户的详细信息（请参阅下面的[示例](#configuration-examples)）。

如果您使用 systemd 单元来管理极狐GitLab：

1. 将 `gitlab-mailroom.service` 添加为 `gitlab.target` 的依赖项：

   ```shell
   sudo systemctl edit gitlab.target
   ```

   在打开的编辑器中，添加以下内容并保存文件：

   ```plaintext
   [Unit]
   Wants=gitlab-mailroom.service
   ```

1. 如果您在同一台机器上运行 Redis 和 PostgreSQL，则应添加对 Redis 的依赖。运行：

   ```shell
   sudo systemctl edit gitlab-mailroom.service
   ```

   在打开的编辑器中，添加以下内容并保存文件：

   ```plaintext
   [Unit]
   Wants=redis-server.service
   After=redis-server.service
   ```

1. 启动 `gitlab-mailroom.service`：

   ```shell
   sudo systemctl start gitlab-mailroom.service
   ```

1. 验证所有内容是否配置正确：

   ```shell
   sudo -u git -H bundle exec rake gitlab:incoming_email:check RAILS_ENV=production
   ```

如果您使用 SysV init 脚本管理极狐GitLab：

1. 在 `/etc/default/gitlab` 的 init 脚本中开启 `mail_room`：

   ```shell
   sudo mkdir -p /etc/default
   echo 'mail_room_enabled=true' | sudo tee -a /etc/default/gitlab
   ```

1. 重启极狐GitLab：

   ```shell
   sudo service gitlab restart
   ```

1. 验证所有内容是否配置正确：

   ```shell
   sudo -u git -H bundle exec rake gitlab:incoming_email:check RAILS_ENV=production
   ```

通过邮件回复现在应该可以正常工作了。

<a id="configuration-examples"></a>

### 配置示例

<a id="postfix"></a>

#### Postfix

Postfix 邮件服务器的示例配置。假设邮箱为 `incoming@gitlab.example.com`。

Linux 软件包安装示例：

```ruby
gitlab_rails['incoming_email_enabled'] = true

# The email address including the %{key} placeholder that will be replaced to reference the
# item being replied to. This %{key} should be included in its entirety within the email
# address and not replaced by another value.
# For example: emailaddress+%{key}@gitlab.example.com.
# The placeholder must appear in the "user" part of the address (before the `@`).
gitlab_rails['incoming_email_address'] = "incoming+%{key}@gitlab.example.com"

# Email account username
# With third party providers, this is usually the full email address.
# With self-hosted email servers, this is usually the user part of the email address.
gitlab_rails['incoming_email_email'] = "incoming"
# Email account password
gitlab_rails['incoming_email_password'] = "[REDACTED]"

# IMAP server host
gitlab_rails['incoming_email_host'] = "gitlab.example.com"
# IMAP server port
gitlab_rails['incoming_email_port'] = 143
# Whether the IMAP server uses SSL
gitlab_rails['incoming_email_ssl'] = false
# Whether the IMAP server uses StartTLS
gitlab_rails['incoming_email_start_tls'] = false

# The mailbox where incoming mail will end up. Usually "inbox".
gitlab_rails['incoming_email_mailbox_name'] = "inbox"
# The IDLE command timeout.
gitlab_rails['incoming_email_idle_timeout'] = 60

# If you are using Microsoft Graph instead of IMAP, set this to false to retain
# messages in the inbox because deleted messages are auto-expunged after some time.
gitlab_rails['incoming_email_delete_after_delivery'] = true

# Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
# Only applies to IMAP. Microsoft Graph will auto-expunge any deleted messages.
gitlab_rails['incoming_email_expunge_deleted'] = true
```

自行编译安装示例：

```yaml
incoming_email:
    enabled: true

    # The email address including the %{key} placeholder that will be replaced to reference the
    # item being replied to. This %{key} should be included in its entirety within the email
    # address and not replaced by another value.
    # For example: emailaddress+%{key}@gitlab.example.com.
    # The placeholder must appear in the "user" part of the address (before the `@`).
    address: "incoming+%{key}@gitlab.example.com"

    # Email account username
    # With third party providers, this is usually the full email address.
    # With self-hosted email servers, this is usually the user part of the email address.
    user: "incoming"
    # Email account password
    password: "[REDACTED]"

    # IMAP server host
    host: "gitlab.example.com"
    # IMAP server port
    port: 143
    # Whether the IMAP server uses SSL
    ssl: false
    # Whether the IMAP server uses StartTLS
    start_tls: false

    # The mailbox where incoming mail will end up. Usually "inbox".
    mailbox: "inbox"
    # The IDLE command timeout.
    idle_timeout: 60

    # If you are using Microsoft Graph instead of IMAP, set this to false to retain
    # messages in the inbox because deleted messages are auto-expunged after some time.
    delete_after_delivery: true

    # Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
    # Only applies to IMAP. Microsoft Graph will auto-expunge any deleted messages.
    expunge_deleted: true
```

<a id="gmail"></a>

#### Gmail

Gmail/Google Workspace 的示例配置。假设邮箱为 `gitlab-incoming@gmail.com`。

> [!note]
> `incoming_email_email` 不能是 Gmail 别名账户。

Linux 软件包安装示例：

```ruby
gitlab_rails['incoming_email_enabled'] = true

# The email address including the %{key} placeholder that will be replaced to reference the
# item being replied to. This %{key} should be included in its entirety within the email
# address and not replaced by another value.
# For example: emailaddress+%{key}@gmail.com.
# The placeholder must appear in the "user" part of the address (before the `@`).
gitlab_rails['incoming_email_address'] = "gitlab-incoming+%{key}@gmail.com"

# Email account username
# With third party providers, this is usually the full email address.
# With self-hosted email servers, this is usually the user part of the email address.
gitlab_rails['incoming_email_email'] = "gitlab-incoming@gmail.com"
# Email account password
gitlab_rails['incoming_email_password'] = "[REDACTED]"

# IMAP server host
gitlab_rails['incoming_email_host'] = "imap.gmail.com"
# IMAP server port
gitlab_rails['incoming_email_port'] = 993
# Whether the IMAP server uses SSL
gitlab_rails['incoming_email_ssl'] = true
# Whether the IMAP server uses StartTLS
gitlab_rails['incoming_email_start_tls'] = false

# The mailbox where incoming mail will end up. Usually "inbox".
gitlab_rails['incoming_email_mailbox_name'] = "inbox"
# The IDLE command timeout.
gitlab_rails['incoming_email_idle_timeout'] = 60

# If you are using Microsoft Graph instead of IMAP, set this to false if you want to retain
# messages in the inbox because deleted messages are auto-expunged after some time.
gitlab_rails['incoming_email_delete_after_delivery'] = true

# Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
# Only applies to IMAP. Microsoft Graph will auto-expunge any deleted messages.
gitlab_rails['incoming_email_expunge_deleted'] = true
```

自行编译安装示例：

```yaml
incoming_email:
    enabled: true

    # The email address including the %{key} placeholder that will be replaced to reference the
    # item being replied to. This %{key} should be included in its entirety within the email
    # address and not replaced by another value.
    # For example: emailaddress+%{key}@gmail.com.
    # The placeholder must appear in the "user" part of the address (before the `@`).
    address: "gitlab-incoming+%{key}@gmail.com"

    # Email account username
    # With third party providers, this is usually the full email address.
    # With self-hosted email servers, this is usually the user part of the email address.
    user: "gitlab-incoming@gmail.com"
    # Email account password
    password: "[REDACTED]"

    # IMAP server host
    host: "imap.gmail.com"
    # IMAP server port
    port: 993
    # Whether the IMAP server uses SSL
    ssl: true
    # Whether the IMAP server uses StartTLS
    start_tls: false

    # The mailbox where incoming mail will end up. Usually "inbox".
    mailbox: "inbox"
    # The IDLE command timeout.
    idle_timeout: 60

    # If you are using Microsoft Graph instead of IMAP, set this to falseto retain
    # messages in the inbox because deleted messages are auto-expunged after some time.
    delete_after_delivery: true

    # Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
    # Only applies to IMAP. Microsoft Graph will auto-expunge any deleted messages.
    expunge_deleted: true
```

<a id="microsoft-exchange-server"></a>

#### Microsoft Exchange Server

启用 IMAP 的 Microsoft Exchange Server 的示例配置。由于 Exchange 不支持子地址，因此只有两个选项：

- [捕获所有邮件的邮箱](#catch-all-mailbox)（推荐用于仅使用 Exchange 的环境）
- [专用电子邮件地址](#dedicated-email-address)（仅支持通过邮件回复）

<a id="catch-all-mailbox-1"></a>

##### 捕获所有邮件的邮箱

假设捕获所有邮件的邮箱为 `incoming@exchange.example.com`。

Linux 软件包安装示例：

```ruby
gitlab_rails['incoming_email_enabled'] = true

# The email address including the %{key} placeholder that will be replaced to reference the
# item being replied to. This %{key} should be included in its entirety within the email
# address and not replaced by another value.
# For example: emailaddress-%{key}@exchange.example.com.
# The placeholder must appear in the "user" part of the address (before the `@`).
# Exchange does not support sub-addressing, so a catch-all mailbox must be used.
gitlab_rails['incoming_email_address'] = "incoming-%{key}@exchange.example.com"

# Email account username
# Typically this is the userPrincipalName (UPN)
gitlab_rails['incoming_email_email'] = "incoming@ad-domain.example.com"
# Email account password
gitlab_rails['incoming_email_password'] = "[REDACTED]"

# IMAP server host
gitlab_rails['incoming_email_host'] = "exchange.example.com"
# IMAP server port
gitlab_rails['incoming_email_port'] = 993
# Whether the IMAP server uses SSL
gitlab_rails['incoming_email_ssl'] = true

# Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
# Only applies to IMAP. Microsoft Graph will auto-expunge any deleted messages.
gitlab_rails['incoming_email_expunge_deleted'] = true
```

自行编译安装示例：

```yaml
incoming_email:
    enabled: true

    # The email address including the %{key} placeholder that will be replaced to reference the
    # item being replied to. This %{key} should be included in its entirety within the email
    # address and not replaced by another value.
    # For example: emailaddress-%{key}@exchange.example.com.
    # The placeholder must appear in the "user" part of the address (before the `@`).
    # Exchange does not support sub-addressing, so a catch-all mailbox must be used.
    address: "incoming-%{key}@exchange.example.com"

    # Email account username
    # Typically this is the userPrincipalName (UPN)
    user: "incoming@ad-domain.example.com"
    # Email account password
    password: "[REDACTED]"

    # IMAP server host
    host: "exchange.example.com"
    # IMAP server port
    port: 993
    # Whether the IMAP server uses SSL
    ssl: true

    # If you are using Microsoft Graph instead of IMAP, set this to false to retain
    # messages in the inbox because deleted messages are auto-expunged after some time.
    delete_after_delivery: true

    # Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
    expunge_deleted: true
```

<a id="dedicated-email-address-1"></a>

##### 专用电子邮件地址

> [!note]
> 仅支持[通过邮件回复](reply_by_email.md)。
> 不支持[服务台](../user/project/service_desk/_index.md)。

假设专用电子邮件地址为 `incoming@exchange.example.com`。

Linux 软件包安装示例：

```ruby
gitlab_rails['incoming_email_enabled'] = true

# Exchange does not support sub-addressing, and we're not using a catch-all mailbox so %{key} is not used here
gitlab_rails['incoming_email_address'] = "incoming@exchange.example.com"

# Email account username
# Typically this is the userPrincipalName (UPN)
gitlab_rails['incoming_email_email'] = "incoming@ad-domain.example.com"
# Email account password
gitlab_rails['incoming_email_password'] = "[REDACTED]"

# IMAP server host
gitlab_rails['incoming_email_host'] = "exchange.example.com"
# IMAP server port
gitlab_rails['incoming_email_port'] = 993
# Whether the IMAP server uses SSL
gitlab_rails['incoming_email_ssl'] = true

# Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
gitlab_rails['incoming_email_expunge_deleted'] = true
```

自行编译安装示例：

```yaml
incoming_email:
    enabled: true

    # Exchange does not support sub-addressing,
    # and we're not using a catch-all mailbox so %{key} is not used here
    address: "incoming@exchange.example.com"

    # Email account username
    # Typically this is the userPrincipalName (UPN)
    user: "incoming@ad-domain.example.com"
    # Email account password
    password: "[REDACTED]"

    # IMAP server host
    host: "exchange.example.com"
    # IMAP server port
    port: 993
    # Whether the IMAP server uses SSL
    ssl: true

    # If you are using Microsoft Graph instead of IMAP, set this to false to retain
    # messages in the inbox because deleted messages are auto-expunged after some time.
    delete_after_delivery: true

    # Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
    expunge_deleted: true
```

<a id="microsoft-office-365"></a>

#### Microsoft Office 365

启用 IMAP 的 Microsoft Office 365 的示例配置。

<a id="sub-addressing-mailbox"></a>

##### 子地址邮箱

> [!note]
> 自 2020 年 9 月起，[Office 365 已添加子地址支持](https://support.microsoft.com/en-us/office/uservoice-pages-430e1a78-e016-472a-a10f-dc2a3df3450a)。此功能默认未开启，必须通过 PowerShell 开启。

这一系列 PowerShell 命令在 Office 365 的组织级别开启[子地址](#email-sub-addressing)。这允许组织中的所有邮箱接收子地址邮件。

要开启子地址：

1. 从 [PowerShell 库](https://www.powershellgallery.com/packages/ExchangeOnlineManagement/3.7.1) 下载并安装 `ExchangeOnlineManagement` 模块。
1. 在 PowerShell 中，运行以下命令：

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   Import-Module ExchangeOnlineManagement
   Connect-ExchangeOnline
   Set-OrganizationConfig -DisablePlusAddressInRecipients $false
   Disconnect-ExchangeOnline
   ```

此 Linux 软件包安装示例假设邮箱为 `incoming@office365.example.com`：

```ruby
gitlab_rails['incoming_email_enabled'] = true

# The email address including the %{key} placeholder that will be replaced to reference the
# item being replied to. This %{key} should be included in its entirety within the email
# address and not replaced by another value.
# For example: emailaddress+%{key}@office365.example.com.
# The placeholder must appear in the "user" part of the address (before the `@`).
gitlab_rails['incoming_email_address'] = "incoming+%{key}@office365.example.com"

# Email account username
# Typically this is the userPrincipalName (UPN)
gitlab_rails['incoming_email_email'] = "incoming@office365.example.com"
# Email account password
gitlab_rails['incoming_email_password'] = "[REDACTED]"

# IMAP server host
gitlab_rails['incoming_email_host'] = "outlook.office365.com"
# IMAP server port
gitlab_rails['incoming_email_port'] = 993
# Whether the IMAP server uses SSL
gitlab_rails['incoming_email_ssl'] = true

# Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
gitlab_rails['incoming_email_expunge_deleted'] = true
```

此自行编译安装示例假设邮箱为 `incoming@office365.example.com`：

```yaml
incoming_email:
    enabled: true

    # The email address including the %{key} placeholder that will be replaced to reference the
    # item being replied to. This %{key} should be included in its entirety within the email
    # address and not replaced by another value.
    # For example: emailaddress+%{key}@office365.example.com.
    # The placeholder must appear in the "user" part of the address (before the `@`).
    address: "incoming+%{key}@office365.example.comm"

    # Email account username
    # Typically this is the userPrincipalName (UPN)
    user: "incoming@office365.example.comm"
    # Email account password
    password: "[REDACTED]"

    # IMAP server host
    host: "outlook.office365.com"
    # IMAP server port
    port: 993
    # Whether the IMAP server uses SSL
    ssl: true

    # Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
    expunge_deleted: true
```

<a id="catch-all-mailbox-2"></a>

##### 捕获所有邮件的邮箱

此 Linux 软件包安装示例假设捕获所有邮件的邮箱为 `incoming@office365.example.com`：

```ruby
gitlab_rails['incoming_email_enabled'] = true

# The email address including the %{key} placeholder that will be replaced to reference the
# item being replied to. This %{key} should be included in its entirety within the email
# address and not replaced by another value.
# For example: emailaddress-%{key}@office365.example.com.
# The placeholder must appear in the "user" part of the address (before the `@`).
gitlab_rails['incoming_email_address'] = "incoming-%{key}@office365.example.com"

# Email account username
# Typically this is the userPrincipalName (UPN)
gitlab_rails['incoming_email_email'] = "incoming@office365.example.com"
# Email account password
gitlab_rails['incoming_email_password'] = "[REDACTED]"

# IMAP server host
gitlab_rails['incoming_email_host'] = "outlook.office365.com"
# IMAP server port
gitlab_rails['incoming_email_port'] = 993
# Whether the IMAP server uses SSL
gitlab_rails['incoming_email_ssl'] = true

# Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
gitlab_rails['incoming_email_expunge_deleted'] = true
```

此自行编译安装示例假设捕获所有邮件的邮箱为 `incoming@office365.example.com`：

```yaml
incoming_email:
    enabled: true

    # The email address including the %{key} placeholder that will be replaced to reference the
    # item being replied to. This %{key} should be included in its entirety within the email
    # address and not replaced by another value.
    # For example: emailaddress+%{key}@office365.example.com.
    # The placeholder must appear in the "user" part of the address (before the `@`).
    address: "incoming-%{key}@office365.example.com"

    # Email account username
    # Typically this is the userPrincipalName (UPN)
    user: "incoming@ad-domain.example.com"
    # Email account password
    password: "[REDACTED]"

    # IMAP server host
    host: "outlook.office365.com"
    # IMAP server port
    port: 993
    # Whether the IMAP server uses SSL
    ssl: true

    # Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
    expunge_deleted: true
```

<a id="dedicated-email-address-2"></a>

##### 专用电子邮件地址

> [!note]
> 仅支持[通过邮件回复](reply_by_email.md)。
> 不支持[服务台](../user/project/service_desk/_index.md)。

此 Linux 软件包安装示例假设专用电子邮件地址为 `incoming@office365.example.com`：

```ruby
gitlab_rails['incoming_email_enabled'] = true

gitlab_rails['incoming_email_address'] = "incoming@office365.example.com"

# Email account username
# Typically this is the userPrincipalName (UPN)
gitlab_rails['incoming_email_email'] = "incoming@office365.example.com"
# Email account password
gitlab_rails['incoming_email_password'] = "[REDACTED]"

# IMAP server host
gitlab_rails['incoming_email_host'] = "outlook.office365.com"
# IMAP server port
gitlab_rails['incoming_email_port'] = 993
# Whether the IMAP server uses SSL
gitlab_rails['incoming_email_ssl'] = true

# Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
gitlab_rails['incoming_email_expunge_deleted'] = true
```

此自行编译安装示例假设专用电子邮件地址为 `incoming@office365.example.com`：

```yaml
incoming_email:
    enabled: true

    address: "incoming@office365.example.com"

    # Email account username
    # Typically this is the userPrincipalName (UPN)
    user: "incoming@office365.example.com"
    # Email account password
    password: "[REDACTED]"

    # IMAP server host
    host: "outlook.office365.com"
    # IMAP server port
    port: 993
    # Whether the IMAP server uses SSL
    ssl: true

    # Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery
    expunge_deleted: true
```

<a id="microsoft-graph"></a>

#### Microsoft Graph

极狐GitLab 可以使用 Microsoft Graph API 而不是 IMAP 读取传入电子邮件。由于 [Microsoft 正在弃用使用基本身份验证的 IMAP](https://techcommunity.microsoft.com/blog/exchange/announcing-oauth-2-0-support-for-imap-and-smtp-auth-protocols-in-exchange-online/1330432)，新的 Microsoft Exchange Online 邮箱需要使用 Microsoft Graph API。

要为 Microsoft Graph 配置极狐GitLab，您需要在 Azure Active Directory 中注册一个 OAuth 2.0 应用程序，该应用程序对所有邮箱具有 `Mail.ReadWrite` 权限。有关更多详细信息，请参阅 [MailRoom 分步指南](https://github.com/tpitale/mail_room/#microsoft-graph-configuration) 和 [Microsoft 说明](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)。

配置 OAuth 2.0 应用程序时，请记录以下内容：

- 您的 Azure Active Directory 的租户 ID
- 您的 OAuth 2.0 应用程序的客户端 ID
- 您的 OAuth 2.0 应用程序的客户端密钥

<a id="restrict-mailbox-access"></a>

##### 限制邮箱访问

为使 MailRoom 作为服务账号工作，您在 Azure Active Directory 中创建的应用程序需要将 `Mail.ReadWrite` 属性设置为读取/写入所有邮箱中的邮件。

为缓解安全风险，您应配置应用程序访问策略，以限制所有账户的邮箱访问，如 [Microsoft 文档](https://learn.microsoft.com/en-us/exchange/permissions-exo/application-rbac) 中所述。

此 Linux 软件包安装示例假设您使用以下邮箱：`incoming@example.onmicrosoft.com`：

<a id="configure-microsoft-graph"></a>

##### 配置 Microsoft Graph

```ruby
gitlab_rails['incoming_email_enabled'] = true

# The email address including the %{key} placeholder that will be replaced to reference the
# item being replied to. This %{key} should be included in its entirety within the email
# address and not replaced by another value.
# For example: emailaddress+%{key}@example.onmicrosoft.com.
# The placeholder must appear in the "user" part of the address (before the `@`).
gitlab_rails['incoming_email_address'] = "incoming+%{key}@example.onmicrosoft.com"

# Email account username
gitlab_rails['incoming_email_email'] = "incoming@example.onmicrosoft.com"
gitlab_rails['incoming_email_delete_after_delivery'] = false

gitlab_rails['incoming_email_inbox_method'] = 'microsoft_graph'
gitlab_rails['incoming_email_inbox_options'] = {
   'tenant_id': '<YOUR-TENANT-ID>',
   'client_id': '<YOUR-CLIENT-ID>',
   'client_secret': '<YOUR-CLIENT-SECRET>',
   'poll_interval': 60  # Optional
}
```

对于 Microsoft Cloud for US Government 或[其他 Azure 部署](https://learn.microsoft.com/en-us/graph/deployments)，请配置 `azure_ad_endpoint` 和 `graph_endpoint` 设置。

- Microsoft Cloud for US Government 示例：

```ruby
gitlab_rails['incoming_email_inbox_options'] = {
   'azure_ad_endpoint': 'https://login.microsoftonline.us',
   'graph_endpoint': 'https://graph.microsoft.us',
   'tenant_id': '<YOUR-TENANT-ID>',
   'client_id': '<YOUR-CLIENT-ID>',
   'client_secret': '<YOUR-CLIENT-SECRET>',
   'poll_interval': 60  # Optional
}
```

自行编译安装尚不支持 Microsoft Graph API。有关更多详细信息，请参阅[议题 326169](https://gitlab.com/gitlab-org/gitlab/-/issues/326169)。

<a id="use-encrypted-credentials"></a>

### 使用加密凭据

您可以选择使用加密文件存储传入电子邮件凭据，而不是将传入电子邮件凭据以明文形式存储在配置文件中。

先决条件：

- 要使用加密凭据，您必须首先开启[加密配置](encrypted_configuration.md)。

加密文件支持的配置项为：

- `user`
- `password`

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 如果您在 `/etc/gitlab/gitlab.rb` 中的传入电子邮件配置最初如下所示：

   ```ruby
   gitlab_rails['incoming_email_email'] = "incoming-email@mail.example.com"
   gitlab_rails['incoming_email_password'] = "examplepassword"
   ```

1. 编辑加密的密钥：

   ```shell
   sudo gitlab-rake gitlab:incoming_email:secret:edit EDITOR=vim
   ```

1. 输入传入电子邮件密钥的未加密内容：

   ```yaml
   user: 'incoming-email@mail.example.com'
   password: 'examplepassword'
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并删除 `incoming_email` 中针对 `email` 和 `password` 的设置。
1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes 密钥存储传入电子邮件密码。有关更多信息，请参阅 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-incoming-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

1. 如果您在 `docker-compose.yml` 中的传入电子邮件配置最初如下所示：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['incoming_email_email'] = "incoming-email@mail.example.com"
           gitlab_rails['incoming_email_password'] = "examplepassword"
   ```

1. 进入容器内部，并编辑加密的密钥：

   ```shell
   sudo docker exec -t <container_name> bash
   gitlab-rake gitlab:incoming_email:secret:edit EDITOR=editor
   ```

1. 输入传入电子邮件密钥的未加密内容：

   ```yaml
   user: 'incoming-email@mail.example.com'
   password: 'examplepassword'
   ```

1. 编辑 `docker-compose.yml` 并删除 `incoming_email` 中针对 `email` 和 `password` 的设置。
1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 如果您在 `/home/git/gitlab/config/gitlab.yml` 中的传入电子邮件配置最初如下所示：

   ```yaml
   production:
     incoming_email:
       user: 'incoming-email@mail.example.com'
       password: 'examplepassword'
   ```

1. 编辑加密的密钥：

   ```shell
   bundle exec rake gitlab:incoming_email:secret:edit EDITOR=vim RAILS_ENVIRONMENT=production
   ```

1. 输入传入电子邮件密钥的未加密内容：

   ```yaml
   user: 'incoming-email@mail.example.com'
   password: 'examplepassword'
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并删除 `incoming_email:` 中针对 `user` 和 `password` 的设置。
1. 保存文件并重启极狐GitLab 和 Mailroom

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排查

<a id="incoming-emails-are-rejected-by-providers-with-email-address-limit"></a>

### 传入电子邮件被提供商以电子邮件地址长度限制为由拒绝

您的极狐GitLab 实例可能无法接收传入电子邮件，因为某些电子邮件提供商对电子邮件地址的本地部分（`@` 之前）施加了 64 个字符的限制。所有超过此限制的地址发送的电子邮件都会被拒绝。

作为变通方法，请保持较短的路径：

- 确保 `incoming_email_address` 中 `%{key}` 之前配置的本地部分尽可能短，且不超过 31 个字符。
- 将指定的项目放置在更高的群组层级。
- 将[群组](../user/group/manage.md#change-a-groups-path)和[项目](../user/project/working_with_projects.md#rename-a-repository)重命名为更短的名称。

在[议题 460206](https://gitlab.com/gitlab-org/gitlab/-/issues/460206) 中跟踪此功能。
