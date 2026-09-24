---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 双因素认证
description: 启用多重身份验证以增强账户保护。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="two-factor-authentication"></a>

# 双因素认证

双因素认证（2FA）为您的极狐GitLab 账户提供了额外的安全层级。其他人若想访问您的账户，不仅需要您的用户名和密码，还需要访问您的第二个身份验证因素。

极狐GitLab 支持以下 2FA 方法：

- 一次性密码（[OTP](https://datatracker.ietf.org/doc/html/rfc6238)）认证器。登录时，极狐GitLab 会提示您输入由 OTP 认证器生成的代码。
- WebAuthn 设备。登录时，极狐GitLab 会提示您证明您拥有 WebAuthn 设备。这通常是一个物理设备，如 YubiKey、手机或笔记本电脑。
- 邮件 OTP。登录时，极狐GitLab 会提示您输入发送到您邮箱地址的代码。

如果您设置了设备，也请设置一个 OTP，这样即使丢失设备您仍然可以访问账户。

<a id="enable-two-factor-authentication"></a>

## 启用双因素认证

要启用 2FA，请验证您的邮箱地址并注册一个 OTP 认证器、WebAuthn 设备或邮件 OTP。

<a id="register-an-otp-authenticator"></a>

### 注册 OTP 认证器

> [!warning]
> 如果您无法访问 OTP 认证器，您可能会被锁定在账户外。
>
> 为降低此风险：
>
> - 在您的认证器应用中启用云备份。
> - 将您的备份密码、密钥或恢复凭证保存在安全的位置。
> - 查阅您所使用的 OTP 认证器的文档。

注册 OTP 认证器：

1. 配置极狐GitLab。
   1. 在右上角，选择您的头像。
   1. 选择 **编辑资料**。
   1. 在左侧边栏中，选择 **访问** > **密码和认证**。
   1. 在 **一次性密码认证器** 部分，选择 **注册认证器**。
      会显示一个二维码和您的 OTP 详情。
1. 配置您的设备。
   1. 在您的设备上安装一个兼容的 OTP 应用。例如：
      - 基于云的（推荐，因为如果您丢失硬件设备可以恢复访问）：
        - [Authy](https://authy.com/)。
        - [Cisco Duo](https://duo.com/)。
      - 其他（专有）：
        - [Google Authenticator](https://support.google.com/accounts/answer/1066447?hl=en)。
        - [Microsoft Authenticator](https://www.microsoft.com/en-us/security/mobile-authenticator-app)。
      - 其他（自由软件）
        - [Aegis Authenticator](https://getaegis.app/)。
        - [FreeOTP](https://freeotp.github.io/)。
   1. 在应用中，通过以下两种方式之一添加新条目：
      - 使用设备的摄像头扫描极狐GitLab 显示的二维码，自动添加条目。
      - 手动输入提供的详细信息来添加条目。
1. 完成注册：
   1. 输入您的当前密码。
   1. 输入从您的认证器生成的六位数字 PIN 码。
   1. 选择 **使用双因素应用注册**。

如果输入的 PIN 码正确，极狐GitLab 会显示一组[恢复代码](#recovery-codes)。
下载它们并将其保存在安全的地方。

如果您的 OTP 认证器支持云备份，请考虑现在配置该功能。更多信息，请参阅您所使用的认证器的文档。

<a id="register-a-webauthn-device"></a>

### 注册 WebAuthn 设备

{{< history >}}

- WebAuthn 设备的可选一次性密码认证在 GitLab 15.10 引入，使用名为 `webauthn_without_totp` 的功能标志。
- 在 GitLab 17.6 [GA]。功能标志 `webauthn_without_totp` 已移除。

{{< /history >}}

WebAuthn 由以下浏览器[支持](https://caniuse.com/#search=webauthn)：

- 桌面浏览器：
  - Chrome
  - Edge
  - Firefox
  - Opera
  - Safari
- 移动浏览器：
  - Chrome for Android
  - Firefox for Android
  - iOS Safari（iOS 13.3 起）

注册与 WebAuthn 兼容的设备：

1. 如果使用物理设备，请将其插入电脑。
1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **密码和认证**。
1. 在 **WebAuthn 设备** 部分，选择 **注册设备**。
1. 选择 **设置新设备**。
1. 按照浏览器窗口中的提示操作。
1. 根据您的设备，可能需要按下按钮或触摸传感器。
1. 输入您的极狐GitLab 账户密码和设备名称。
   如果您通过身份提供商登录，可能不需要输入此密码。
1. 选择 **注册设备**。

您应该会收到一条消息，表明您已成功设置设备。

当您使用与 WebAuthn 兼容的设备设置 2FA 时，该设备会链接到特定计算机上的特定浏览器。根据浏览器和 WebAuthn 设备的不同，您可能可以配置设置以在不同的浏览器或计算机上使用该 WebAuthn 设备。

如果这是您第一次设置 2FA，您必须[下载恢复代码](#recovery-codes)，以便在丢失访问时恢复对账户的访问。

> [!warning]
> 如果您清除浏览器数据，可能会失去对账户的访问。

<a id="enable-email-otp"></a>

### 启用邮件 OTP

{{< history >}}

- 在 GitLab 18.7 引入，使用名为 `email_based_mfa` 的功能标志。默认禁用。
- 在 GitLab 18.7 于 JihuLab.com 上启用，并将在 2026 年逐步向所有用户推出。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。更多信息，请参阅历史。

邮件 OTP 通过向您的邮箱地址发送六位数验证码来验证您的身份。

为您的账户启用邮件 OTP：

1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **密码和认证**。
1. 选择 **启用邮件 OTP**。
1. 输入您的当前密码并选择 **更新邮件 OTP 设置**。

<a id="add-a-cisco-duo-authenticator"></a>

### 添加 Cisco Duo 认证器

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 15.10 引入。

{{< /history >}}

您可以在极狐GitLab 中使用 Cisco Duo 作为 OTP 提供商。

DUO® 是 Cisco Systems, Inc. 和/或其在美国及其他特定国家/地区分支机构的注册商标。

前提条件：

- 您的账户必须同时存在于 Cisco Duo 和极狐GitLab 中，且两个应用中的用户名相同。
- 您必须已经[配置了 Cisco Duo](https://admin.duosecurity.com/) 并拥有集成密钥、密钥和 API 主机名。

更多信息，请参阅 [Cisco Duo API 文档](https://duo.com/docs/authapi)。

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
   gitlab_rails['duo_auth_enabled'] = false
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
> 在私有化部署的极狐GitLab 上，默认此功能不可用。要使每个用户可用，管理员可以[启用功能标志](../../../administration/feature_flags/_index.md) `forti_authenticator`。
> 在 JihuLab.com 和 GitLab Dedicated 上，此功能不可用。

您可以在极狐GitLab 中使用 FortiAuthenticator 作为 OTP 提供商。用户必须：

- 在 FortiAuthenticator 和极狐GitLab 中存在相同的用户名。
- 已在 FortiAuthenticator 中配置 FortiToken。

您需要 FortiAuthenticator 的用户名和访问令牌。如下所示的 `access_token` 是 FortiAuthenticator 的访问密钥。要获取令牌，请参阅 [Fortinet 文档库](https://docs.fortinet.com/document/fortiauthenticator/6.2.0/rest-api-solution-guide/158294/the-fortiauthenticator-api) 中的 REST API 解决方案指南。
已在 FortiAuthenticator 6.2.0 版本上测试。

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
   （Linux 软件包安装）或 [重启](../../../administration/restart_gitlab.md#self-compiled-installations)
   （自编译安装）。

<a id="add-a-fortitoken-cloud-authenticator"></a>

### 添加 FortiToken Cloud 认证器

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 在私有化部署的极狐GitLab 上，默认此功能不可用。要使每个用户可用，管理员可以[启用功能标志](../../../administration/feature_flags/_index.md) `forti_token_cloud`。
> 在 JihuLab.com 和 GitLab Dedicated 上，此功能不可用。
> 此功能尚未准备好用于生产环境。

您可以在极狐GitLab 中使用 FortiToken Cloud 作为 OTP 提供商。用户必须：

- 在 FortiToken Cloud 和极狐GitLab 中存在相同的用户名。
- 已在 FortiToken Cloud 中配置 FortiToken。

您需要 `client_id` 和 `client_secret` 来配置 FortiToken Cloud。要获取这些，请参阅 [Fortinet 文档库](https://docs.fortinet.com/document/fortitoken-cloud/latest/rest-api/456035/overview) 中的 REST API 指南。

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

在成功使用 OTP 认证器启用 2FA 后，系统会立即提示您下载一组生成的恢复代码。如果您以后无法访问 OTP 认证器，可以使用其中一个恢复代码登录您的账户。

您应该复制并打印这些代码，或使用 **下载代码** 将它们下载下来，存储在安全的地方。如果您选择下载，文件名将是 `gitlab-recovery-codes.txt`。

> [!note]
>
> - 每个代码只能用于登录您的账户一次。
> - 不会为 WebAuthn 设备生成恢复代码。

有关重新生成或恢复恢复代码的信息，请参阅[恢复选项和 2FA 重置](two_factor_authentication_troubleshooting.md#recovery-options-and-2fa-reset)。（注：此处链接为相对路径，原文如此）

<a id="sign-in-with-two-factor-authentication"></a>

## 使用双因素认证登录

启用 2FA 后，您需要输入用户名和密码，然后使用第二种身份验证方法来确认您的身份。登录过程根据您注册的 2FA 方法略有不同。

<a id="sign-in-with-an-otp-authenticator"></a>

### 使用 OTP 认证器登录

当系统提示时，输入您的 OTP 认证器中的 PIN 码或一个恢复代码来登录。

<a id="sign-in-with-a-webauthn-device"></a>

### 使用 WebAuthn 设备登录

在支持的浏览器中，输入凭据后，系统应会自动提示您激活您的 WebAuthn 设备（例如，通过触摸或按下其按钮）。

会显示一条消息，表明您的设备已响应认证请求，您已自动登录。

<a id="sign-in-with-email-otp"></a>

### 使用邮件 OTP 登录

当系统提示时，输入发送到您邮箱的六位数验证码。该代码在 60 分钟内有效。

如果您无法使用验证码，您可以：

- 请求新代码。在登录页面上，选择 **重新发送代码**。
- 将代码发送到另一个已验证的邮箱地址。在登录页面上，选择 **发送代码到与此账户关联的另一个地址**。
- 请参阅[邮件 OTP 故障排除](two_factor_authentication_troubleshooting.md#email-otp-troubleshooting)。（原文如此）

<a id="sign-in-with-a-personal-access-token"></a>

### 使用个人访问令牌登录

启用 2FA 后，您不能使用密码通过 HTTPS 或 [极狐GitLab API](../../../api/rest/_index.md) 进行 Git 身份验证。您必须使用[个人访问令牌](../personal_access_tokens.md) 代替。

<a id="disable-two-factor-authentication"></a>

## 禁用双因素认证

{{< history >}}

- 在 GitLab 17.6 中引入了单独或同时禁用 OTP 认证器和 WebAuthn 设备的功能。

{{< /history >}}

您可以单独或同时禁用 OTP 认证器和 WebAuthn 设备。要同时禁用它们：

1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **密码和认证**。
1. 选择 **禁用 2FA**。
1. 在对话框中，输入您的当前密码并选择 **禁用 2FA**。

群组或实例设置可能要求您的账户使用 2FA。
在 JihuLab.com 上，基于密码的登录必须完成邮件 OTP 验证。

<a id="oauth-credential-helpers"></a>

## OAuth 凭据助手

以下 Git 凭据助手使用 OAuth 向极狐GitLab 进行身份验证。这与双因素认证兼容。首次验证时，助手会打开 Web 浏览器，极狐GitLab 会要求您授权该应用。后续认证无需交互。

<a id="git-credential-manager"></a>

### Git Credential Manager

[Git Credential Manager](https://github.com/GitCredentialManager/git-credential-manager)（GCM）默认使用 OAuth 进行身份验证。GCM 支持 JihuLab.com 而无需任何手动配置。要将 GCM 用于私有化部署的极狐GitLab，请参阅 [GitLab 支持](https://github.com/GitCredentialManager/git-credential-manager/blob/main/docs/gitlab.md)。

为了避免每次推送都需要重新认证，GCM 支持缓存以及各种平台特定的凭据存储，这些存储可在会话之间持久化。无论您使用个人访问令牌还是 OAuth，此功能都很有用。

Git for Windows 包含 Git Credential Manager。

Git Credential Manager 主要由 GitHub, Inc. 开发。它是一个开源项目，由社区支持。

<a id="git-credential-oauth"></a>

### git-credential-oauth

[git-credential-oauth](https://github.com/hickford/git-credential-oauth) 支持 JihuLab.com 和多个流行的公共主机，无需任何手动配置。要用于私有化部署的极狐GitLab，请参阅 [git-credential-oauth 自定义主机文档](https://github.com/hickford/git-credential-oauth#custom-hosts)。

许多 Linux 发行版都将 git-credential-oauth 作为软件包提供。

git-credential-oauth 是一个开源项目，由社区支持。

<a id="information-for-gitlab-administrators"></a>

## 极狐GitLab 管理员须知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 请注意，在[恢复极狐GitLab 备份](../../../administration/backup_restore/_index.md)后，2FA 仍需正常工作。
- 为确保 2FA 与 OTP 服务器正确授权，请使用 NTP 等服务同步极狐GitLab 服务器的时间。否则，由于时间差异，授权可能总是失败。
- 当极狐GitLab 实例通过多个主机名或 FQDN 访问时，极狐GitLab 的 WebAuthn 实现不起作用。每个 WebAuthn 注册都与注册时的当前主机名绑定，不能用于其他主机名或 FQDN。

  例如，如果用户尝试从 `first.host.xyz` 和 `second.host.xyz` 访问极狐GitLab 实例：

  - 用户使用 `first.host.xyz` 登录并注册其 WebAuthn 密钥。
  - 用户退出，然后尝试使用 `first.host.xyz` 登录 - WebAuthn 认证成功。
  - 用户退出，然后尝试使用 `second.host.xyz` 登录 - WebAuthn 认证失败，因为 WebAuthn 密钥仅在 `first.host.xyz` 上注册。

- 要在系统或群组级别强制实施 2FA，请参阅[强制双因素认证](../../../security/two_factor_authentication.md)。