---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 强制双因素认证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[双因素认证 (2FA)](../user/profile/account/two_factor_authentication.md)
是一种要求用户提供两个不同因素来证明其身份的认证方法：

- 用户名和密码。
- 第二个认证方法，例如由应用程序生成的验证码。

2FA 使未授权人员更难访问账户，因为他们需要两个因素。

> [!note]
> 如果你正在[使用并强制实施 SSO](../user/group/saml_sso/_index.md#sso-enforcement)，你可能已经在身份提供商 (IdP) 端强制实施了 2FA。在极狐GitLab 上再强制实施 2FA 可能没有必要。

## 为所有用户强制实施 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理员可以通过两种不同的方式为所有用户强制实施 2FA：

- 在下次登录时强制实施。
- 在下次登录时建议，但允许在强制实施前有一个宽限期。

  在配置的宽限期过后，用户可以登录，但不能离开 `/-/profile/two_factor_auth` 处的 2FA 配置区域。

你可以使用 UI 或 API 为所有用户强制实施 2FA。

### 使用 UI

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **登录限制**：
   - 选择 **强制双因素认证** 以启用此功能。
   - 在 **双因素宽限期** 中，输入小时数。如果你想在下次登录尝试时强制实施 2FA，请输入 `0`。

### 使用 API

使用[应用程序设置 API](../api/settings.md) 修改以下设置：

- `require_two_factor_authentication`。
- `two_factor_grace_period`。

更多信息，请参见[可以通过 API 调用访问的设置列表](../api/settings.md#available-settings)。

## 为管理员强制实施 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.8 中引入。
- 在极狐GitLab 18.3 中引入了对拥有自定义管理员角色的普通用户强制实施 2FA 的支持。

{{< /history >}}

管理员可以为以下两类用户强制实施 2FA：

- 管理员用户。
- 已被分配[自定义管理员角色](../user/custom_roles/_index.md)的普通用户。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **登录限制** 部分：
   1. 选择 **为管理员强制双因素认证**。
   1. 在 **双因素宽限期** 中，输入小时数。如果你想在下次登录尝试时强制实施 2FA，请输入 `0`。
1. 选择 **保存更改**。

> [!note]
> 如果你使用外部提供商登录极狐GitLab，此设置 **不会** 为用户强制实施 2FA。2FA 应在该外部提供商上启用。

## 为群组中的所有用户强制实施 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以为群组或子群组中的所有用户强制实施 2FA。

2FA 强制执行适用于[直接成员和继承成员](../user/project/members/_index.md#membership-types)
群组成员。如果在子群组上强制执行 2FA，继承的成员必须注册一个认证因素。
继承的成员是祖先群组的成员。

> [!note]
> 邮件一次性密码不满足 2FA 要求。成员必须配置基于应用程序的 TOTP 或 WebAuthn。

前提条件：

- 你必须拥有该群组的所有者角色。

要为群组强制实施 2FA：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 选择 **此群组中的所有用户必须设置双因素认证**。
1. 可选。在 **延迟 2FA 强制执行 (小时)** 中，输入你希望宽限期持续的小时数。
   如果在顶级群组及其子群组和项目中有多个不同的宽限期，则使用最短的宽限期。
1. 选择 **保存更改**。

访问令牌不需要提供第二个认证因素，因为它们是基于 API 的。在强制执行 2FA 之前生成的令牌仍然有效。

极狐GitLab [接收邮件](../administration/incoming_email.md) 功能不遵循 2FA 强制执行。用户可以使用接收邮件的功能，例如创建议题或对合并请求进行评论，而无需先使用 2FA 进行认证。即使强制执行 2FA，这也适用。

### 子群组中的 2FA

默认情况下，每个子群组都可以配置可能与顶级群组不同的 2FA 要求。

当用户是层次结构中多个群组的成员时，最严格的 2FA 要求将适用于所有级别。

例如，当在顶级群组中强制执行 2FA 时：

- 顶级群组的所有成员都必须使用 2FA。
- 所有后代子群组的成员都必须使用 2FA。

当在顶级群组中未强制执行 2FA 时：

- 如果启用了 **允许子群组进行更严格的双因素认证强制执行**，每个子群组
  可以独立强制执行 2FA 要求。
  如果子群组启用了 2FA 要求：
  - 顶级群组的所有成员都必须使用 2FA。
  - 任何同级子群组的所有成员都必须使用 2FA。
- 如果禁用了 **允许子群组进行更严格的双因素认证强制执行**，子群组
  不能独立强制执行 2FA 要求。层次结构中的任何成员都不需要 2FA。

> [!note]
> 当启用 **此群组中的所有用户必须设置双因素认证** 时，它始终
> 优先于 **允许子群组进行更严格的双因素认证强制执行**。

要防止子群组设置单独的 2FA 要求：

1. 转到顶级群组的 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 清除 **允许子群组进行更严格的双因素认证强制执行** 复选框。

### 项目中的 2FA

如果启用了或强制执行了 2FA 的群组中的某个项目被[共享](../user/project/members/sharing_projects_groups.md)
给一个未启用或强制执行 2FA 的群组，则未启用 2FA 的群组的成员可以在不使用 2FA 的情况下访问该项目。例如：

- 群组 A 已启用并强制执行 2FA。群组 B 未启用 2FA。
- 如果属于群组 A 的项目 P 被共享给群组 B，则群组 B
  的成员可以在不使用 2FA 的情况下访问项目 P。

要确保不会发生这种情况，请[阻止共享项目](../user/project/members/sharing_projects_groups.md#prevent-a-project-from-being-shared-with-groups)
给启用了 2FA 的群组。

> [!warning]
> 如果你将成员添加到已启用 2FA 的群组或子群组中的项目，
> 2FA **不会** 要求这些单独添加的成员启用。

## 禁用 2FA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以为一个用户或所有用户禁用 2FA。

此操作是永久且不可逆的。用户必须重新激活 2FA 才能再次使用。

> [!warning]
> 为用户禁用 2FA 不会禁用[为所有用户强制实施 2FA](#为所有用户强制实施-2fa)
> 或[为群组中的所有用户强制实施 2FA](#为群组中的所有用户强制实施-2fa)
> 设置。你还必须禁用任何强制 2FA 设置，这样用户在下次登录极狐GitLab 时才不会再次被要求设置 2FA。

### 为所有用户

要在即使强制 2FA 已被禁用的情况下为所有用户禁用 2FA，请使用以下 Rake 任务。

- 对于使用 Linux 软件包的安装实例：

  ```shell
  sudo gitlab-rake gitlab:two_factor:disable_for_all_users
  ```

- 对于自编译的安装实例：

  ```shell
  sudo -u git -H bundle exec rake gitlab:two_factor:disable_for_all_users RAILS_ENV=production
  ```

### 为单个用户

#### 管理员

可以使用 [Rails 控制台](../administration/operations/rails_console.md)
为单个管理员禁用 2FA：

```ruby
admin = User.find_by_username('<USERNAME>')
user_to_disable = User.find_by_username('<USERNAME>')

TwoFactor::DestroyService.new(admin, user: user_to_disable).execute
```

管理员会收到 2FA 已被禁用的通知。

#### 非管理员

你可以使用 Rails 控制台或
[API 端点](../api/users.md#disable-two-factor-authentication-for-a-user) 为非管理员用户禁用 2FA。

你可以为自己的账户禁用 2FA。

你不能使用 API 端点来禁用管理员的 2FA。

#### 企业用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

顶级群组的所有者可以为[企业用户](../user/enterprise_user/_index.md)禁用双因素认证 (2FA)。

要禁用 2FA：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 找到一个带有 **企业用户** 和 **2FA** 徽章的用户。
1. 选择 **更多操作** ({{< icon name="ellipsis_v" >}}) 并选择 **禁用双因素认证**。

你还可以[使用 API](../api/group_enterprise_users.md#disable-two-factor-authentication-for-an-enterprise-user) 为企业用户禁用 2FA，包括不再是群组成员的企业用户。

## 用于 SSH 操作的 Git 的 2FA

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 默认情况下此功能不可用。要使其可用，管理员可以[启用功能标志](../administration/feature_flags/_index.md)名为 `two_factor_for_cli`。此功能尚未准备好用于生产环境。当 2FA 启用时，此功能标志还会影响[Git 操作的会话持续时间](../administration/settings/account_and_limit_settings.md#customize-session-duration-for-git-operations-when-2fa-is-enabled)。

你可以强制对 SSH 操作的 Git 执行 2FA。然而，你应该使用 `ED25519_SK` 或 `ECDSA_SK`
SSH 密钥来代替。更多信息，请参见[支持的 SSH 密钥类型](../user/ssh.md#supported-ssh-key-types)。
2FA 仅对 Git 操作强制执行，并且不包括来自极狐GitLab Shell 的内部命令，例如
`personal_access_token`。

要执行一次性密码 (OTP) 验证，请运行：

```shell
ssh git@<hostname> 2fa_verify
```

然后通过以下任一方式进行认证：

- 输入正确的 OTP。
- 如果启用了 [FortiAuthenticator](../user/profile/account/two_factor_authentication.md#add-a-fortiauthenticator-authenticator)，响应设备推送通知。

认证成功后，你可以在 15 分钟（默认）内使用关联的 SSH 密钥执行 Git 操作。

### 安全限制

2FA 不会保护私钥已泄露的用户。

一旦 OTP 通过验证，任何拥有该私有 SSH 密钥的人都可以在配置的[会话持续时间](../administration/settings/account_and_limit_settings.md#customize-session-duration-for-git-operations-when-2fa-is-enabled)内运行 Git 操作。