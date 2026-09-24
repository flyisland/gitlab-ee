---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 排查双因素认证问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="error-http-basic-access-denied-if-a-password-was-provided-for-git-authentication-..."></a>

## 错误：`HTTP Basic: Access denied. If a password was provided for Git authentication ...`

当发起请求时，您可能会遇到如下错误：

```plaintext
HTTP Basic: Access denied。如果为 Git 认证提供了密码，密码不正确或您需要使用令牌而不是密码。
如果提供了令牌，令牌可能不正确、已过期或授权范围不当。
```

出现此错误的原因：

- 您已启用 2FA，并尝试使用用户名和密码进行认证。
- 您使用的是 JihuLab.com，且您的账户要求 2FA（参见[电子邮件 OTP 排查](#email-otp-troubleshooting)）。
- 您未启用 2FA，并尝试使用错误的用户名或密码进行认证。
- 您未启用 2FA，且[强制所有用户使用 2FA](../../../security/two_factor_authentication.md#enforce-2fa-for-all-users) 设置处于活动状态。
- 您未启用 2FA，且未选中[**允许通过 HTTP(S) 使用密码进行 Git 认证**](../../../administration/settings/sign_in_restrictions.md#allow-password-authentication-for-git-over-https) 复选框。

要解决此错误：

- 使用具有正确授权范围的[个人访问令牌](../personal_access_tokens.md)：
  - 对于通过 HTTP(S) 的 Git 请求：`read_repository` 或 `write_repository`
  - 对于[极狐GitLab 容器镜像仓库](../../packages/container_registry/authenticate_with_container_registry.md) 请求：`read_registry` 或 `write_registry`
  - 对于[依赖代理](../../packages/dependency_proxy/_index.md#authenticate-with-the-dependency-proxy-for-container-images) 请求：`read_registry` 和 `write_registry`
- 如果您配置了 LDAP，请使用 [LDAP 密码](../../../administration/auth/ldap/_index.md)。
- 使用 [OAuth 凭证助手](two_factor_authentication.md#oauth-credential-helpers)。

<a id="error-invalid-pin-code"></a>

## 错误：`invalid pin code`

`invalid pin code` 错误可能表示认证应用与极狐GitLab 实例之间存在时间同步问题。

要解决此问题，请为生成 2FA 码的设备开启时间同步。

{{< tabs >}}

{{< tab title="Android" >}}

1. 进入 **设置** > **系统** > **日期和时间**。
1. 开启 **自动设置时间**。如果该设置已开启，请先关闭，等待几秒钟，然后再次开启。

{{< /tab >}}

{{< tab title="iOS" >}}

1. 进入 **设置** > **通用** > **日期与时间**。
1. 开启 **自动设置**。如果该设置已开启，请先关闭，等待几秒钟，然后再次开启。

{{< /tab >}}

{{< /tabs >}}

<a id="error-permission-denied-publickey-when-generating-recovery-codes"></a>

## 错误：生成恢复码时出现 `Permission denied (publickey)`

您可能会遇到错误 `Permission denied (publickey)`。此问题通常发生在您使用非默认 SSH 密钥对文件路径并尝试[通过 SSH 生成恢复码](two_factor_authentication_troubleshooting.md#regenerate-recovery-codes-with-ssh)时。

要解决此问题，请使用 `ssh-agent` [配置 SSH 指向其他目录](../../ssh_advanced.md#use-ssh-keys-in-another-directory)。

<a id="email-otp-troubleshooting"></a>

## 电子邮件 OTP 排查

在使用电子邮件 OTP 时，您可能会遇到以下问题。

> [!note]
> 从 2026 年 4 月起，JihuLab.com 上任何使用用户名和密码的登录或 API 请求都必须进行多因素认证。
> 如果未配置其他因素，[电子邮件 OTP](two_factor_authentication.md#sign-in-with-email-otp) 是 JihuLab.com 上的强制第二因素。

<a id="enhanced-authentication-banner-and-passcode-requirement"></a>

### 增强认证横幅和验证码要求

**即将推出增强认证**横幅表示极狐GitLab 将开始在密码登录时对您的账户强制使用[电子邮件一次性验证码](two_factor_authentication.md#sign-in-with-email-otp)。通过 SSO 登录或已配置 2FA 的用户不受影响。

该横幅在强制实施前 14 天显示。在强制实施前 7 天，极狐GitLab 会在每次密码登录时向您发送一次性验证码。在此期间，您可以跳过输入验证码。

强制实施日期过后，您必须在每次密码登录时输入一次性验证码。为避免被锁定，请确保您可以访问主电子邮件地址，或[更改您的主电子邮件地址](../_index.md#change-your-primary-email)。

<a id="didnt-receive-email-verification-code-or-code-has-expired"></a>

### 未收到电子邮件验证码或验证码已过期

等待一分钟让邮件送达，然后检查垃圾邮件文件夹。在 JihuLab.com 上，邮件发送自 `gitlab@mg.gitlab.com`，并且可以[验证真伪](https://handbook.gitlab.com/handbook/security/corporate/systems/google/mail/verification/#verify-an-email-from-gitlabcom-is-genuine)。

如果验证码未到达或已过期，请在登录页面上选择 **重新发送验证码**。每次重新发送都会生成新验证码并使前一个失效，因此在请求另一个之前请等待每封邮件。

<a id="cannot-access-your-email-address"></a>

### 无法访问您的电子邮件地址

如果您无法访问主电子邮件地址，请使用与您账户关联的其他电子邮件地址。在登录页面，选择 **向与此账户关联的其他地址发送验证码**。

如果您无法访问任何关联的电子邮件地址：

- 如果您之前配置了 SSO，请使用 SSO 登录，而不是用户名和密码。
- 如果您是 JihuLab.com 企业用户，请您的群组所有者[更改您的电子邮件地址](../../enterprise_user/_index.md#change-the-email-addresses-for-an-enterprise-user)。
- 在私有化部署版上，联系您的极狐GitLab 管理员。
- [联系极狐GitLab 技术支持](https://gitlab.cn/support/)。

<a id="email-otp-cannot-be-enabled-or-disabled"></a>

### 无法启用或禁用电子邮件 OTP

以下情况下无法禁用电子邮件 OTP：

- 您的实例要求 2FA，且您尚未注册 [OTP 验证器](two_factor_authentication.md#register-an-otp-authenticator) 或 [WebAuthn 设备](two_factor_authentication.md#register-a-webauthn-device)。
- 您的账户计划在未来某个日期自动启用。

以下情况下无法启用电子邮件 OTP：

- 您的群组、实例或管理员策略要求您使用 OTP 验证器或 WebAuthn 设备。
- 您的账户使用外部身份提供商。
- 您的账户计划在未来某个日期自动启用。

<a id="recovery-options-and-2fa-reset"></a>

## 恢复选项与 2FA 重置

<a id="use-a-recovery-code"></a>

### 使用恢复码

当您启用一次性密码（OTP）验证器时，极狐GitLab 会为您提供一系列[恢复码](two_factor_authentication.md#recovery-codes)。您可以使用这些码登录您的账户。

要使用恢复码：

1. 在极狐GitLab 登录页面，输入您的用户名或电子邮件和密码。
1. 当提示输入双因素码时，输入恢复码。

使用恢复码后，您不能再次使用相同的码。其他恢复码仍然有效。

<a id="regenerate-recovery-codes-with-the-ui"></a>

### 通过 UI 重新生成恢复码

如果您仍然可以访问您的账户，可以通过用户设置重新生成恢复码。

要通过 UI 重新生成恢复码：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码与认证**。
1. 在 **恢复码** 部分，选择 **重新生成恢复码**。
1. 在对话框中，输入当前密码并选择 **重新生成恢复码**。

> [!note]
> 每次重新生成 2FA 恢复码时，请保存它们。您不能使用之前创建的任何 2FA 码。

<a id="regenerate-recovery-codes-with-ssh"></a>

### 通过 SSH 重新生成恢复码

如果您已[将 SSH 密钥添加到您的极狐GitLab 账户](../../ssh.md#add-an-ssh-key-to-your-gitlab-account)，则可以通过 SSH 重新生成恢复码。

先决条件：

- 可以访问与注册到极狐GitLab 账户的 SSH 公钥关联的私有 SSH 密钥。

> [!note]
> 您不能使用 `gitlab-sshd` 重新生成恢复码。

要通过 SSH 重新生成恢复码：

1. 在终端中，验证 SSH 代理正在您的设备上运行。
   - 在 macOS 和 Linux 上，运行以下命令：

     ```shell
     eval "$(ssh-agent -s)"
     ```

   - 在 Microsoft Windows 上，在 PowerShell 中运行以下命令：

     ```pwsh
     Set-Service -Name ssh-agent -StartupType Automatic; Start-Service ssh-agent
     ```

     更多信息，请参见 [Windows 的 SSH 设置说明](../../ssh_advanced.md#use-ssh-on-microsoft-windows)。

1. 使用以下命令将私钥加载到 SSH 代理中：
   - 在 macOS 和 Linux 上，运行：

     ```shell
     ssh-add <directory to private SSH key>
     ```

   更多信息，请参见 [在其他目录中使用 SSH 密钥](../../ssh_advanced.md#use-ssh-keys-in-another-directory)。

1. 使用以下命令打开 SSH 连接：

   ```shell
   ssh git@gitlab.com 2fa_recovery_codes
   ```

   在私有化部署实例上，将 `gitlab.com` 替换为极狐GitLab 服务器主机名（`gitlab.example.com`）。

1. 在确认消息上，输入 `yes`。
1. 保存极狐GitLab 生成的恢复码。您之前的恢复码将失效。
1. 在登录页面，输入您的用户名或电子邮件和密码。
1. 当提示输入双因素码时，输入您的新恢复码之一。

登录后，立即使用新设备设置 2FA。

<a id="restore-2fa-codes-from-authenticator-backup"></a>

### 从验证器备份恢复 2FA 码

除了极狐GitLab 恢复码外，许多验证器应用还提供自己的备份和恢复方法。如果您丢失了设备，只要事先启用了备份功能，您可能可以通过在新设备上登录验证器应用来恢复 2FA 码。

先决条件：

- 您必须在失去设备访问权限之前启用验证器的备份功能。

> [!note]
> 极狐GitLab 建议使用恢复码作为主要恢复方法。确保在启用 2FA 时保存恢复码。

极狐GitLab 技术支持无法协助处理与第三方验证器应用相关的恢复问题。

更多信息，请参阅您使用的特定验证器应用的文档。常见验证器的文档可通过以下位置获取：

- [Microsoft Authenticator](https://support.microsoft.com/en-us/account-billing/restore-account-credentials-from-microsoft-authenticator-ce53096e-1e1c-4840-9e32-1618bc33cd43)
- [Google Authenticator](https://support.google.com/accounts/answer/1066447)
- [Authy](https://www.twilio.com/en-us/blog/how-the-authy-two-factor-backups-work)
- [1Password](https://support.1password.com/recovery-codes/?mac#recover-your-account)

<a id="reset-2fa-on-your-account"></a>

### 重置您账户的 2FA

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果以上恢复选项无效，您可以创建一个支持请求来禁用您账户的 2FA。此服务仅适用于拥有 JihuLab.com 订阅的账户。

极狐GitLab 技术支持无法为基础版账户重置 2FA。如果您无法恢复 2FA 方法，您将永久被锁定在账户之外，必须创建一个新账户。更多信息，请参阅[博客公告](https://gitlab.cn/blog/gitlab-support-no-longer-processing-mfa-resets-for-free-users/)。

要创建支持请求：

1. 前往 [GitLab Support](https://support.gitlab.com)。
1. 选择 **提交工单**。
1. 使用您的 GitLab 支持账户登录。
   您的支持账户与 GitLab 账户不同，不受 2FA 问题影响。
1. 在问题下拉列表中，选择 **JihuLab.com 用户账户和登录问题**。
1. 填写支持表单中的字段。
1. 选择 **提交**。

重新获得账户访问权限后，请尽快重新启用 2FA 以保持账户安全。

<a id="reset-2fa-for-enterprise-users"></a>

### 为企业用户重置 2FA

如果您是付费计划中的顶级群组所有者，可以为企业用户禁用 2FA。更多信息，请参见[为企业用户禁用 2FA](../../../security/two_factor_authentication.md#enterprise-users)。