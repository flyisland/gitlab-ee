---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 双因素认证
description: 启用多重身份验证，增强账号保护。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

双因素认证（2FA）为您的极狐GitLab 账号提供了额外的安全保护。其他人若要访问您的账号，不仅需要您的用户名和密码，还需要访问您的第二重身份验证因素。

极狐GitLab 支持以下 2FA 方式：

- 通行密钥。登录时，极狐GitLab 会提示您使用通行密钥进行身份验证。开启 2FA 后，通行密钥会成为额外的默认 2FA 选项。更多信息，请参见[通行密钥](../../../auth/passkeys.md)。
- 一次性密码（[OTP](https://datatracker.ietf.org/doc/html/rfc6238)）认证器。登录时，极狐GitLab 会提示您输入由 OTP 认证器生成的验证码。
- WebAuthn 设备。登录时，极狐GitLab 会提示您证明对 WebAuthn 设备的所有权。这通常是实体设备，例如 YubiKey、手机或笔记本电脑。
- 邮件 OTP。登录时，极狐GitLab 会提示您输入发送到您电子邮箱的验证码。

如果您设置了设备，也请设置 OTP，这样即使设备丢失，您仍能访问自己的账号。

<a id="enable-two-factor-authentication"></a>

## 启用双因素认证

要启用 2FA，请验证您的电子邮箱地址，并注册 OTP 认证器、WebAuthn 设备或邮件 OTP。

<a id="register-an-otp-authenticator"></a>

### 注册 OTP 认证器

> [!warning]
> 如果您无法访问自己的 OTP 认证器，可能会被锁定在账号之外。
>
> 要尽量降低此风险：
>
> - 在认证器应用中启用云备份。
> - 将备份密码、密钥或恢复凭据保存在安全的位置。
> - 查阅您所用 OTP 认证器的文档。
>
> 如果您已经被锁定，请参见[恢复选项和 2FA 重置](two_factor_authentication_troubleshooting.md#recovery-options-and-2fa-reset)。

要注册 OTP 认证器：

1. 配置极狐GitLab。
   1. 在右上角，选择您的头像。
   1. 选择**编辑资料**。
   1. 在左侧边栏中，选择**访问** > **密码和认证**。
   1. 在**一次性密码认证器**部分，选择**注册认证器**。
      此时会显示二维码和您的 OTP 详细信息。
1. 配置您的设备。
   1. 在您的设备上安装兼容的 OTP 应用。例如：
      - 基于云（推荐，因为即使硬件设备丢失，您也可以恢复访问）：
        - [Authy](https://authy.com/)。
        - [Cisco Duo](https://duo.com/)。
      - 其他（专有）：
        - [Google Authenticator](https://support.google.com/accounts/answer/1066447?hl=en)。
        - [Microsoft Authenticator](https://www.microsoft.com/en-us/security/mobile-authenticator-app)。
      - 其他（自由软件）
        - [Aegis Authenticator](https://getaegis.app/)。
        - [FreeOTP](https://freeotp.github.io/)。
   1. 在应用中，通过以下两种方式之一添加新条目：
      - 用您设备的摄像头扫描极狐GitLab 显示的二维码，自动添加条目。
      - 手动输入提供的详细信息以添加条目。
1. 完成注册：
   1. 输入您当前的密码。
   1. 输入由您的认证器生成的六位 PIN 码。
   1. 选择**使用双因素应用注册**。

如果您输入了正确的 PIN 码，极狐GitLab 会显示一个[恢复代码](#recovery-codes)列表。请下载它们并妥善保管。

如果您的 OTP 认证器支持云备份，请考虑立即配置该功能。更多信息，请参见您所用认证器的文档。

<a id="register-a-webauthn-device"></a>

### 注册 WebAuthn 设备

WebAuthn [受以下浏览器支持](https://caniuse.com/#search=webauthn)：

- 桌面浏览器：
  - Chrome
  - Edge
  - Firefox
  - Opera
  - Safari
- 移动浏览器：
  - Chrome for Android
  - Firefox for Android
  - iOS Safari（自 iOS 13.3 起）

要注册兼容 WebAuthn 的设备：

1. 如果使用实体设备，请将其插入您的计算机。
1. 在右上角，选择您的头像。
1. 选择**编辑资料**。
1. 在左侧边栏中，选择**访问** > **密码和认证**。
1. 在 **WebAuthn 设备**部分，选择**注册设备**。
1. 选择**设置新设备**。
1. 按照浏览器窗口中的说明操作。
1. 根据您的设备，您可能需要按下按钮或触摸传感器。
1. 输入您的极狐GitLab 账号密码和设备名称。
   如果您已通过身份提供商登录，则可能无需输入此密码。
1. 选择**注册设备**。

您应该会收到一条消息，表明您已成功设置设备。

当您使用兼容 WebAuthn 的设备设置 2FA 时，该设备会与特定计算机上的特定浏览器关联。根据浏览器和 WebAuthn 设备的不同，您或许可以配置设置，以便在其他浏览器或计算机上使用该 WebAuthn 设备。

如果这是您首次设置 2FA，则必须[下载恢复代码](#recovery-codes)，以便在无法访问账号时恢复对账号的访问。

> [!warning]
> 如果您清除浏览器数据，可能会无法访问您的账号。

<a id="enable-email-otp"></a>

### 启用邮件 OTP

邮件 OTP 允许您通过向电子邮箱发送六位验证码来[验证您的身份](../../../security/email_verification.md)。

先决条件：

- 您的实例必须已启用邮件 OTP。

要为您的账号启用邮件 OTP：

1. 在右上角，选择您的头像。
1. 选择**编辑资料**。
1. 在左侧边栏中，选择**访问** > **密码和认证**。
1. 选择**启用邮件 OTP**。
1. 输入您当前的密码，然后选择**更新邮件 OTP 设置**。

<a id="add-a-cisco-duo-authenticator"></a>

### 添加 Cisco Duo 认证器

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以在极狐GitLab 中将 Cisco Duo 用作 OTP 提供商。


先决条件：

- 您的账号必须同时存在于 Cisco Duo 和极狐GitLab 中，且两个应用中的用户名相同。
- 您必须已[配置 Cisco Duo](https://admin.duosecurity.com/)，并拥有集成密钥、密钥和 API 主机名。

更多信息，请参见 [Cisco Duo API 文档](https://duo.com/docs/authapi)。

1. 打开极狐GitLab 配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 添加提供商配置。

   对于 Linux 软件包安装：

   ```ruby
    gitlab_rails['duo_auth_enabled'] = true
    gitlab_rails['duo_auth_integration_key'] = '<duo_integration_key_value>'
    gitlab_rails['duo_auth_secret_key'] = '<duo_secret_key_value>'
    gitlab_rails['duo_auth_hostname'] = '<duo_api_hostname>'
   ```

   对于自编译安装：

   ```yaml
   duo_auth:
     enabled: true
     hostname: <duo_api_hostname>
     integration_key: <duo_integration_key_value>
     secret_key: <duo_secret_key_value>
   ```

1. 保存配置文件。
1. 对于 Linux 软件包安装，[重新配置极狐GitLab](../../../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   对于自编译安装，[重启极狐GitLab](../../../administration/restart_gitlab.md#self-compiled-installations)。

<a id="add-a-fortiauthenticator-authenticator"></a>

### 添加 FortiAuthenticator 认证器

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 在极狐GitLab 私有化部署上，默认情况下此功能不可用。要按用户启用此功能，管理员可以
> [启用功能标志](../../../administration/feature_flags/_index.md)，名称为 `forti_authenticator`。
> 在 JihuLab.com 上，此功能不可用。

您可以在极狐GitLab 中将 FortiAuthenticator 用作 OTP 提供商。用户必须：

- 同时存在于 FortiAuthenticator 和极狐GitLab 中，且用户名相同。
- 已在 FortiAuthenticator 中配置 FortiToken。

您需要 FortiAuthenticator 的用户名和访问令牌。下面显示的 `access_token` 是 FortiAuthenticator
访问密钥。要获取该令牌，请参见 [Fortinet 文档库](https://docs.fortinet.com/document/fortiauthenticator/6.2.0/rest-api-solution-guide/158294/the-fortiauthenticator-api)中的 REST API 解决方案指南。
已使用 FortiAuthenticator 6.2.0 版本进行测试。

在极狐GitLab 中配置 FortiAuthenticator。在您的极狐GitLab 服务器上：

1. 打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 添加提供商配置。

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['forti_authenticator_enabled'] = true
   gitlab_rails['forti_authenticator_host'] = 'forti_authenticator.example.com'
   gitlab_rails['forti_authenticator_port'] = 443
   gitlab_rails['forti_authenticator_username'] = '<some_username>'
   gitlab_rails['forti_authenticator_access_token'] = 's3cr3t'
   ```

   对于自编译安装：

   ```yaml
   forti_authenticator:
     enabled: true
     host: forti_authenticator.example.com
     port: 443
     username: <some_username>
     access_token: s3cr3t
   ```

1. 保存配置文件。
1. [重新配置](../../../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)
   （Linux 软件包安装）或[重启](../../../administration/restart_gitlab.md#self-compiled-installations)
   （自编译安装）。

<a id="add-a-fortitoken-cloud-authenticator"></a>

### 添加 FortiToken Cloud 认证器

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 在极狐GitLab 私有化部署上，默认情况下此功能不可用。要按用户启用此功能，管理员可以
> [启用功能标志](../../../administration/feature_flags/_index.md)，名称为 `forti_token_cloud`。
> 在 JihuLab.com 上，此功能不可用。
> 此功能尚未准备好用于生产环境。

您可以在极狐GitLab 中将 FortiToken Cloud 用作 OTP 提供商。用户必须：

- 同时存在于 FortiToken Cloud 和极狐GitLab 中，且用户名相同。
- 已在 FortiToken Cloud 中配置 FortiToken。

您需要 `client_id` 和 `client_secret` 来配置 FortiToken Cloud。要获取这些信息，请参见 [Fortinet 文档库](https://docs.fortinet.com/document/fortitoken-cloud/latest/rest-api/456035/overview)中的 REST API 指南。

在极狐GitLab 中配置 FortiToken Cloud。在您的极狐GitLab 服务器上：

1. 打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 添加提供商配置。

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['forti_token_cloud_enabled'] = true
   gitlab_rails['forti_token_cloud_client_id'] = '<your_fortinet_cloud_client_id>'
   gitlab_rails['forti_token_cloud_client_secret'] = '<your_fortinet_cloud_client_secret>'
   ```

   对于自编译安装：

   ```yaml
   forti_token_cloud:
     enabled: true
     client_id: YOUR_FORTI_TOKEN_CLOUD_CLIENT_ID
     client_secret: YOUR_FORTI_TOKEN_CLOUD_CLIENT_SECRET
   ```

1. 保存配置文件。
1. [重新配置](../../../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)（Linux 软件包安装）或
   [重启](../../../administration/restart_gitlab.md#self-compiled-installations)（自编译安装）。

<a id="recovery-codes"></a>

## 恢复代码

使用 OTP 认证器成功启用 2FA 后，系统会立即提示您下载一组生成的恢复代码。如果您无法访问自己的 OTP 认证器，可以使用其中一个恢复代码登录您的账号。

您应复制并打印这些代码，或使用**下载代码**将其下载并保存到安全的位置。如果您选择下载，该文件名为 `gitlab-recovery-codes.txt`。

> [!note]
>
> - 每个恢复代码只能用于登录您的账号一次。
> - WebAuthn 设备不会生成恢复代码。

有关重新生成或恢复恢复代码的信息，请参见[恢复选项和 2FA 重置](two_factor_authentication_troubleshooting.md#recovery-options-and-2fa-reset)。

<a id="sign-in-with-two-factor-authentication"></a>

## 使用双因素认证登录

启用 2FA 后，您需要输入用户名和密码，然后使用第二重身份验证方式确认您的身份。登录过程会因您注册的 2FA 方式不同而略有差异。

<a id="sign-in-with-an-otp-authenticator"></a>

### 使用 OTP 认证器登录

出现提示时，输入来自您 OTP 认证器的 PIN 码或一个恢复代码以登录。

<a id="sign-in-with-a-webauthn-device"></a>

### 使用 WebAuthn 设备登录

在受支持的浏览器中，输入凭据后，系统应会自动提示您激活 WebAuthn 设备（例如，触摸或按下其按钮）。

随后会显示一条消息，表明您的设备已响应身份验证请求，您已自动登录。

<a id="sign-in-with-email-otp"></a>

### 使用邮件 OTP 登录

出现提示时，输入发送到您电子邮箱的六位验证码。该验证码在 60 分钟内有效。

如果您无法使用该访问代码，可以：

- 请求新代码。在登录页面上，选择**重新发送代码**。
- 将代码发送到另一个已验证的电子邮箱地址。在登录页面上，选择**将代码发送到与此账号关联的另一个地址**。
- 参见[邮件 OTP 故障排除](two_factor_authentication_troubleshooting.md#email-otp-troubleshooting)。

<a id="sign-in-with-a-personal-access-token"></a>

### 使用个人访问令牌登录

启用 2FA 后，您无法使用密码通过 Git over HTTPS 或[极狐GitLab API](../../../api/rest/_index.md) 进行身份验证。您必须改用[个人访问令牌](../personal_access_tokens.md)。

<a id="disable-two-factor-authentication"></a>

## 禁用双因素认证

您可以单独或同时禁用 OTP 认证器和 WebAuthn 设备。要同时禁用它们：

1. 在右上角，选择您的头像。
1. 选择**编辑资料**。
1. 在左侧边栏中，选择**访问** > **密码和认证**。
1. 选择**禁用 2FA**。
1. 在对话框中，输入您当前的密码，然后选择**禁用 2FA**。

群组或实例设置可能要求您的账号使用 2FA。在 JihuLab.com 上，基于密码的登录必须完成邮件 OTP 验证。

<a id="oauth-credential-helpers"></a>

## OAuth 凭据助手

以下 Git 凭据助手使用 OAuth 向极狐GitLab 进行身份验证。这与双因素认证兼容。首次进行身份验证时，助手会打开 Web 浏览器，极狐GitLab 会要求您授权该应用。后续身份验证无需任何交互。

<a id="git-credential-manager"></a>

### Git Credential Manager

[Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager)（GCM）默认使用 OAuth 进行身份验证。GCM 无需任何手动配置即可支持 JihuLab.com。要将 GCM 与极狐GitLab 私有化部署配合使用，请参见 [GitLab 支持](https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/gitlab.md)。

这样您就无需在每次推送时重新进行身份验证，GCM 支持缓存以及多种平台特定的凭据存储，可在会话之间持久保留。无论您使用个人访问令牌还是 OAuth，此功能都很有用。

Git for Windows 包含 Git Credential Manager。

Git Credential Manager 主要由 GitHub, Inc. 开发。它是一个开源项目，由社区提供支持。

<a id="git-credential-oauth"></a>

### git-credential-oauth

[git-credential-oauth](https://github.com/hickford/git-credential-oauth) 无需任何手动配置即可支持 JihuLab.com 和多个流行的公共主机。要与极狐GitLab 私有化部署配合使用，请参见 [git-credential-oauth 自定义主机文档](https://github.com/hickford/git-credential-oauth#custom-hosts)。

许多 Linux 发行版都将 git-credential-oauth 作为软件包包含在内。

git-credential-oauth 是一个由社区支持的开源项目。

<a id="information-for-gitlab-administrators"></a>

## 面向极狐GitLab 管理员的信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 请注意，在[恢复极狐GitLab 备份](../../../administration/backup_restore/_index.md)后，2FA 仍能正常工作。
- 为确保 2FA 能通过 OTP 服务器正确进行身份验证，请使用 NTP 之类的服务同步极狐GitLab
  服务器的时间。否则，身份验证可能总是因时间差异而失败。
- 当从多个主机名或 FQDN 访问极狐GitLab 实例时，极狐GitLab 的 WebAuthn 实现无法正常工作。每次 WebAuthn 注册都会与注册时的当前主机名关联，
  无法用于其他主机名或 FQDN。

  例如，如果用户尝试从 `first.host.xyz` 和 `second.host.xyz` 访问极狐GitLab 实例：

  - 用户使用 `first.host.xyz` 登录并注册其 WebAuthn 密钥。
  - 用户退出登录，并尝试使用 `first.host.xyz` 登录 - WebAuthn 身份验证成功。
  - 用户退出登录，并尝试使用 `second.host.xyz` 登录 - WebAuthn 身份验证失败，因为
    该 WebAuthn 密钥仅在 `first.host.xyz` 上注册过。

- 要在系统或群组级别强制使用 2FA，请参见[强制使用双因素认证](../../../security/two_factor_authentication.md)。
