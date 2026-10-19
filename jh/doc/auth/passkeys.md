---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通行密钥
description: 使用通行密钥进行无密码身份认证和双因素认证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.6 中引入，[通过一个功能标志](../../../administration/feature_flags/_index.md)命名为 `passkeys`。默认在私有化部署中禁用。
- 在极狐GitLab 18.9 中正式可用。功能标志默认启用。
- 移除了功能标志 `passkeys`（在极狐GitLab 19.0 中）。

{{< /history >}}

通行密钥提供了一种安全且便捷的方式，让您无需使用密码即可登录极狐GitLab 帐户。通行密钥提供了防钓鱼的登录方式，同时保护用户免受弱密码漏洞和凭证泄露的威胁。

<a id="how-passkeys-work"></a>

## 通行密钥如何工作

通行密钥使用公钥加密技术，安全地对您进行极狐GitLab 身份认证。当您创建通行密钥时：

- 您的设备会生成一个唯一的加密密钥对。
- 私钥安全地保存在您的设备上，永远不会被共享。
- 极狐GitLab 只存储公钥，该公钥不能被用来冒充您。
- 当您登录时，您的设备会使用生物识别认证或 PIN 解锁私钥，以证明您的身份。

这种方法确保了即使极狐GitLab 服务器遭到入侵，攻击者也无法使用您的通行密钥访问您的帐户。

<a id="security-considerations"></a>

### 安全考虑

- 保留备用认证方法：始终维护访问您帐户的替代方式，例如恢复代码或其他双因素认证方法。
- 维护设备安全：确保您的设备受到强 PIN、密码或生物识别锁的保护。
- 定期检查：定期检查您注册的通行密钥，并移除不再使用的设备。
- 请勿使用共享设备：不要在共享或公共设备上设置通行密钥。

<a id="view-your-passkeys"></a>

## 查看您的通行密钥

要查看您注册的通行密钥信息，包括通行密钥名称、设备类型和使用详情：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码与认证**。
1. 在 **通行密钥登录** 部分，查看您的通行密钥。

<a id="add-a-passkey"></a>

## 添加通行密钥

先决条件：

- 您必须拥有支持 WebAuthn 标准的设备。
  - 桌面浏览器：Chrome、Firefox、Safari 和 Edge。
  - 移动设备：iOS 16 及更高版本，Android 9 及更高版本，并开启生物识别认证或设备 PIN。
  - 安全密钥：支持 FIDO2 或 WebAuthn 的硬件安全密钥。
- 通行密钥登录不得被您的[群组](../user/group/saml_sso/_index.md#disable-password-and-passkey-authentication-for-enterprise-users)或[实例](../administration/settings/sign_in_restrictions.md#password-and-passkey-authentication)禁用。

> [!note]
> 通过外部身份提供商创建的用户帐户可能需要创建新的极狐GitLab 密码。
> 更多信息，请参阅[外部认证帐户的密码](../user/profile/user_passwords.md#passwords-for-externally-authenticated-accounts)。

要添加通行密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码与认证**。
1. 在 **通行密钥登录** 部分，选择 **添加通行密钥**。
1. 按照您设备或浏览器上的提示操作。
1. 输入您当前的密码以确认您的身份。
1. 输入您的通行密钥的名称。
1. 选择 **添加通行密钥**。

<a id="sign-in-with-a-passkey"></a>

## 使用通行密钥登录

要使用通行密钥而不是密码登录极狐GitLab：

1. 前往极狐GitLab 登录页面。

   - 在 JihuLab.com 上，访问 `https://jihulab.com/users/sign_in`。
   - 在私有化部署的极狐GitLab上，请使用您的实例域名。例如，`https://gitlab.example.com/users/sign_in`。

1. 在其他登录选项下，选择 **通行密钥**。
1. 按照您设备上的提示，使用您的指纹、面部识别或设备 PIN 进行认证。

<a id="use-a-passkey-for-two-factor-authentication"></a>

## 使用通行密钥进行双因素认证

如果您已经为帐户启用了[双因素认证](../user/profile/account/two_factor_authentication.md) (2FA)，通行密钥将作为额外的且默认的双因素认证选项可用。

要使用通行密钥作为双因素认证方法：

1. 前往极狐GitLab 登录页面。

   - 在 JihuLab.com 上，访问 `https://jihulab.com/users/sign_in`。
   - 在私有化部署的极狐GitLab上，请使用您的实例域名。例如，`https://gitlab.example.com/users/sign_in`。

1. 输入您的用户名和密码。
1. 当系统提示时，使用您的通行密钥进行认证。
1. 按照您设备上的提示，使用您的指纹、面部识别或设备 PIN 进行认证。

> [!note]
> 如果当前设备无法使用通行密钥，请改用您的备用双因素认证方法。

<a id="delete-a-passkey"></a>

## 删除通行密钥

如果您不再使用某个设备，或者想用新的通行密钥替换它，请删除该通行密钥。如果您删除唯一的通行密钥，极狐GitLab 也将对您的帐户禁用通行密钥登录。

要删除通行密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码与认证**。
1. 在 **通行密钥登录** 部分，找到您要删除的通行密钥。
1. 在该通行密钥旁边，选择 **删除** ({{< icon name="remove" >}})。
1. 在确认对话框中，确认删除。

   - 如果您有多个通行密钥，选择 **删除通行密钥**。
   - 如果您只有一个通行密钥，选择 **禁用通行密钥登录**。

> [!warning]
> 已删除的通行密钥无法恢复。如果您希望再次使用该设备进行认证，必须添加新的通行密钥。

<a id="troubleshooting"></a>

## 故障排查

<a id="problems-adding-a-passkey"></a>

### 添加通行密钥时出现问题

如果您无法添加通行密钥：

- 验证您的设备和浏览器是否支持 WebAuthn 和生物识别认证。
- 确保您的浏览器为最新版本。
- 检查您的设备是否已设置设备 PIN、指纹或面部识别。
- 尝试使用不同的浏览器或设备。
- 检查该设备是否已注册为 WebAuthn 双因素认证方法。
  - 如果该设备已注册为 WebAuthn 双因素认证方法：

    1. 从您的双因素认证方法中删除该 WebAuthn 设备。
    1. 将其注册为通行密钥。
    1. 如果您想再次启用双因素认证，请配置一种备用双因素认证方法（例如认证器应用程序）。极狐GitLab 会自动将您的通行密钥添加为默认的双因素认证方式。

<a id="cannot-sign-in-with-passkey"></a>

### 无法使用通行密钥登录

如果您无法使用通行密钥登录：

- 确保您使用的是创建通行密钥时所用的同一设备。
- 验证您的生物识别认证或设备 PIN 是否正常工作。
- 尝试清除浏览器的缓存和 Cookie。
- 使用您的备用双因素认证方法或密码登录，然后检查您的通行密钥设置。

<a id="lost-or-replaced-device"></a>

### 设备丢失或更换

如果您丢失了设备或更换了新设备，请使用密码登录并设置新的通行密钥。

要在新设备上设置通行密钥：

1. 使用您的密码登录极狐GitLab。
1. 如果您将通行密钥用作双因素认证方法，请使用备用方法登录。
1. 从您的帐户设置中删除旧的通行密钥。
1. 在新设备上设置新的通行密钥。

