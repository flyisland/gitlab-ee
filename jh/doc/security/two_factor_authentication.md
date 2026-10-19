---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 强制实施双因素认证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[双因素认证 (2FA)](../user/profile/account/two_factor_authentication.md) 是一种身份验证方法，要求用户提供两种不同的因素来证明其身份：

- 用户名和密码。
- 第二种身份验证方法，例如由应用程序生成的验证码。

2FA 使未经授权的人员更难访问账号，因为他们需要同时具备两种因素。

> [!note]
> 如果您[正在使用并强制实施 SSO](../user/group/saml_sso/_index.md#sso-enforcement)，您可能已经在身份提供商 (IdP) 侧强制实施了 2FA。此时在极狐GitLab 上也强制实施 2FA 可能没有必要。

<a id="enforce-2fa-for-all-users"></a>

## 为所有用户强制实施 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理员可以通过两种不同的方式为所有用户强制实施 2FA：

- 在下次登录时强制实施。
- 在下次登录时建议，但允许在强制实施前有一段宽限期。

  配置的宽限期过后，用户可以登录，但无法离开位于 `/-/profile/two_factor_auth`的 2FA 配置区域。

您可以使用 UI 或 API 为所有用户强制实施 2FA。

<a id="use-the-ui"></a>

### 使用 UI

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**登录限制**：
   - 选择**强制实施双因素认证**以启用此功能。
   - 在**双因素宽限期**中，输入小时数。如果您想在下次登录尝试时
     强制实施 2FA，请输入 `0`。

<a id="use-the-api"></a>

### 使用 API

使用[应用程序设置 API](../api/settings.md) 修改以下设置：

- `require_two_factor_authentication`。
- `two_factor_grace_period`。

有关更多信息，请参阅[可通过 API 调用访问的设置列表](../api/settings.md#available-settings)。

<a id="enforce-2fa-for-administrators"></a>

## 为管理员强制实施 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理员可以为以下两类用户强制实施 2FA：

- 管理员用户。
- 已被分配[自定义管理员角色](../user/custom_roles/_index.md)的普通用户。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**登录限制**部分：
   1. 选择**为管理员强制实施双因素认证**。
   1. 在**双因素宽限期**中，输入小时数。如果您想在下次登录尝试时
      强制实施 2FA，请输入 `0`。
1. 选择**保存更改**。

> [!note]
> 如果您使用外部提供商登录极狐GitLab，此设置不会为用户强制实施 2FA。应改为在该外部提供商上启用 2FA。

<a id="enforce-2fa-for-all-users-in-a-group"></a>

## 为群组中的所有用户强制实施 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以为群组或子群组中的所有用户强制实施 2FA。

2FA 强制实施适用于群组的[直接成员和继承成员](../user/project/members/_index.md#membership-types)。如果在子群组上强制实施 2FA，继承成员必须注册一种身份验证因素。继承成员是祖先群组的成员。

> [!note]
> 电子邮件 OTP 不满足 2FA 要求。成员必须配置基于应用的 TOTP 或 WebAuthn。

先决条件：

- 您必须拥有该群组的所有者角色。

要为群组强制实施 2FA：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 选择**此群组中的所有用户都必须设置双因素认证**。
1. 可选。在**延迟 2FA 强制实施（小时）**中，输入您希望宽限期
   持续的小时数。
   如果顶级群组及其子群组和项目中存在多个不同的宽限期，
   则使用最短的宽限期。
1. 选择**保存更改**。

访问令牌不需要提供第二种身份验证因素，因为它们基于 API。在强制实施 2FA 之前生成的令牌仍然有效。

极狐GitLab [传入电子邮件](../administration/incoming_email.md)功能不遵循 2FA 强制实施。用户可以使用传入电子邮件功能（例如创建议题或评论合并请求），而无需先使用 2FA 进行身份验证。即使强制实施了 2FA，也是如此。

<a id="2fa-in-subgroups"></a>

### 子群组中的 2FA

默认情况下，每个子群组都可以配置可能与顶级群组不同的 2FA 要求。

当用户是层级结构中多个群组的成员时，最严格的 2FA 要求适用于所有层级。

例如，当在顶级群组中强制实施 2FA 时：

- 顶级群组的所有成员都必须使用 2FA。
- 所有后代子群组的成员都必须使用 2FA。

当顶级群组中未强制实施 2FA 时：

- 如果启用了**允许对子群组实施更严格的 2FA 强制实施**，则每个子群组
  可以独立强制实施 2FA 要求。
  如果子群组启用了 2FA 要求：
  - 顶级群组的所有成员都必须使用 2FA。
  - 任何同级子群组的所有成员都必须使用 2FA。
- 如果禁用了**允许对子群组实施更严格的 2FA 强制实施**，则子群组
  无法独立强制实施 2FA 要求。层级结构中的任何成员都不需要 2FA。

> [!note]
> 当启用**此群组中的所有用户都必须设置双因素认证**时，它始终
> 优先于**允许对子群组实施更严格的 2FA 强制实施**。

要阻止子群组设置单独的 2FA 要求：

1. 转到顶级群组的**设置** > **通用**。
1. 展开**权限和群组功能**部分。
1. 清除**允许对子群组实施更严格的 2FA 强制实施**复选框。

<a id="2fa-in-projects"></a>

### 项目中的 2FA

如果属于启用或强制实施 2FA 的群组的项目被[共享](../user/project/members/sharing_projects_groups.md)给未启用或未强制实施 2FA 的群组，则未启用 2FA 的群组的成员可以在不使用 2FA 的情况下访问该项目。例如：

- 群组 A 已启用并强制实施 2FA。群组 B 未启用 2FA。
- 如果属于群组 A 的项目 P 被共享给群组 B，则群组 B 的成员
  可以在不使用 2FA 的情况下访问项目 P。

为确保不会发生这种情况，请为启用 2FA 的群组[阻止项目共享](../user/project/members/sharing_projects_groups.md#prevent-a-project-from-being-shared-with-groups)。

> [!warning]
> 如果您将成员添加到已启用 2FA 的群组或子群组中的项目，
> 则这些单独添加的成员不需要 2FA。

<a id="disable-2fa"></a>

## 禁用 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为单个用户或所有用户禁用 2FA。

此操作是永久性的且不可逆。用户必须重新激活 2FA 才能再次使用它。

> [!warning]
> 为用户禁用 2FA 不会禁用[为所有用户强制实施 2FA](#enforce-2fa-for-all-users)
> 或[为群组中的所有用户强制实施 2FA](#enforce-2fa-for-all-users-in-a-group)
> 设置。您还必须禁用任何已强制实施的 2FA 设置，这样用户下次登录极狐GitLab 时
> 就不会被要求再次设置 2FA。

<a id="for-all-users"></a>

### 为所有用户

即使强制实施 2FA 已禁用，也要为所有用户禁用 2FA，请使用以下 Rake 任务。

- 对于使用 Linux 软件包的安装：

  ```shell
  sudo gitlab-rake gitlab:two_factor:disable_for_all_users
  ```

- 对于自行编译的安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:two_factor:disable_for_all_users RAILS_ENV=production
  ```

<a id="for-a-single-user"></a>

### 为单个用户

<a id="administrators"></a>

#### 管理员

可以使用 [Rails 控制台](../administration/operations/rails_console.md)为单个管理员禁用 2FA：

```ruby
admin = User.find_by_username('<USERNAME>')
user_to_disable = User.find_by_username('<USERNAME>')

TwoFactor::DestroyService.new(admin, user: user_to_disable).execute
```

管理员会收到 2FA 已被禁用的通知。

<a id="non-administrators"></a>

#### 非管理员

您可以使用 Rails 控制台或 [API 端点](../api/users.md#disable-two-factor-authentication-for-a-user)为非管理员禁用 2FA。

您可以为自己的账号禁用 2FA。

您不能使用 API 端点为管理员禁用 2FA。

<a id="enterprise-users"></a>

#### 企业用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

顶级群组所有者可以通过 UI 或 [API](../api/group_enterprise_users.md#disable-two-factor-authentication-for-an-enterprise-user) 为[企业用户](../user/enterprise_user/_index.md)禁用双因素认证 (2FA)。要为不属于该群组的企业用户禁用 2FA，您必须使用 API。

要从 UI 禁用 2FA：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 找到带有**企业**和 **2FA** 徽章的用户。
1. 选择**更多操作** ({{< icon name="ellipsis_v" >}}) 并选择**禁用双重身份验证**。

<a id="2fa-for-git-over-ssh-operations"></a>

## 用于基于 SSH 的 Git 操作的 2FA

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 默认情况下此功能不可用。要使其可用，管理员可以[启用功能标志](../administration/feature_flags/_index.md)，名称为 `two_factor_for_cli`。此功能尚未准备好用于生产环境。此功能标志还会影响[启用 2FA 时 Git 操作的会话时长](../administration/settings/account_and_limit_settings.md#customize-session-duration-for-git-operations-when-2fa-is-enabled)。

您可以为基于 SSH 的 Git 操作强制实施 2FA。但是，您应改用 `ED25519_SK` 或 `ECDSA_SK` SSH 密钥。有关更多信息，请参阅[支持的 SSH 密钥类型](../user/ssh.md#supported-ssh-key-types)。2FA 仅对 Git 操作强制实施，来自 GitLab Shell 的内部命令（例如 `personal_access_token`）除外。

要执行一次性密码 (OTP) 验证，请运行：

```shell
ssh git@<hostname> 2fa_verify
```

然后通过以下任一方式进行身份验证：

- 输入正确的 OTP。
- 如果[启用了 FortiAuthenticator](../user/profile/account/two_factor_authentication.md#add-a-fortiauthenticator-authenticator)，
  则响应设备推送通知。

身份验证成功后，您可以在 15 分钟（默认）内使用关联的 SSH 密钥执行基于 SSH 的 Git 操作。

<a id="security-limitation"></a>

### 安全限制

2FA 无法保护 SSH 私钥已泄露的用户。

一旦验证了 OTP，任何人都可以在配置的[会话时长](../administration/settings/account_and_limit_settings.md#customize-session-duration-for-git-operations-when-2fa-is-enabled)内使用该 SSH 私钥运行基于 SSH 的 Git 操作。
