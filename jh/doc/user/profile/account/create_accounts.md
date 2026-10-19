---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中创建用户账号。
title: 创建用户
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

用户账号是极狐GitLab 协作的基础。每个需要访问您极狐GitLab 项目的人都必须拥有一个账号。用户账号用于控制访问权限、跟踪贡献，并维护整个实例的安全。

您可以通过不同方式在极狐GitLab 中创建用户账号：

- 为重视自主性的团队手动创建用户账号
- 由管理员驱动创建，以实现受控的入职流程
- 为满足企业环境需求而集成身份验证
- 通过控制台访问实现自动化和批量操作

您还可以使用[用户 API 端点](../../../api/users.md#create-a-user)自动创建用户。

请根据您组织的规模、安全要求和工作流选择合适的方法。

<a id="create-a-user-on-the-sign-in-page"></a>

## 在登录页面上创建用户

默认情况下，任何访问您极狐GitLab 实例的用户都可以创建账号。如果您之前[禁用了此设置](../../../administration/settings/sign_up_restrictions.md#disable-new-user-account-creation)，则必须重新启用它。

用户可以通过以下任一方式创建自己的账号：

- 在登录页面上选择 **立即注册** 链接。
- 访问您极狐GitLab 实例的新用户账号链接（例如：`https://gitlab.example.com/users/sign_up`）。

<a id="create-a-user-in-the-admin-area"></a>

## 在管理区域中创建用户

先决条件：

- 您必须是该实例的管理员。

创建用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 选择 **新用户**。
1. 在 **帐户** 部分，输入所需的账号信息。
1. 可选。在 **访问类型** 部分，配置任何项目限制或用户类型设置。
1. 选择 **创建用户**。

极狐GitLab 会向该用户发送一封包含登录链接的电子邮件，用户首次登录时必须创建密码。您也可以直接为该用户[设置密码](../../../security/reset_user_password.md#use-the-ui)。

<a id="create-a-user-with-an-authentication-integration"></a>

## 通过身份验证集成创建用户

极狐GitLab 可以通过身份验证集成自动创建用户账号。用户在以下情况下会被创建：

- 在身份提供商中通过 [SCIM](../../group/saml_sso/scim_setup.md) 预配。
- 首次通过以下方式登录：
  - [LDAP](../../../administration/auth/ldap/_index.md)
  - [群组 SAML](../../group/saml_sso/_index.md)
  - 已开启 `allow_single_sign_on` 设置的 [OmniAuth 提供商](../../../integration/omniauth.md)

<a id="create-a-user-through-the-rails-console"></a>

## 通过 Rails 控制台创建用户

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 更改数据的命令如果未正确运行或未在适当条件下运行，可能会造成损害。
> 请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

通过 Rails 控制台创建用户：

1. 启动 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 根据您的极狐GitLab 版本运行相应命令：

   {{< tabs >}}

   {{< tab title="16.10 and earlier" >}}

   ```ruby
   u = User.new(username: 'test_user', email: 'test@example.com', name: 'Test User', password: 'password', password_confirmation: 'password')
   # u.assign_personal_namespace
   u.skip_confirmation! # Use only if you want the user to be automatically confirmed. If you do not use this, the user receives a confirmation email.
   u.save!
   ```

   {{< /tab >}}

   {{< tab title="16.11 through 17.6" >}}

   ```ruby
   u = User.new(username: 'test_user', email: 'test@example.com', name: 'Test User', password: 'password', password_confirmation: 'password')
   u.assign_personal_namespace(Organizations::Organization.default_organization)
   u.skip_confirmation! # Use only if you want the user to be automatically confirmed. If you do not use this, the user receives a confirmation email.
   u.save!
   ```

   {{< /tab >}}

   {{< tab title="17.7 and later" >}}

   ```ruby
   u = Users::CreateService.new(nil,
     username: 'test_user',
     email: 'test@example.com',
     name: 'Test User',
     password: '123password',
     password_confirmation: '123password',
     organization_id: Organizations::Organization.first.id,
     skip_confirmation: true
   ).execute
   ```

   > [!note]
   > 如果您[禁用了新用户账号](../../../administration/settings/sign_up_restrictions.md#disable-new-user-account-creation)，
   > 则必须以管理员身份运行此命令。在上一条命令中，将 `Users::CreateService.new(nil,`
   > 替换为 `Users::CreateService.new(User.find_by(admin: true),`

   {{< /tab >}}

   {{< /tabs >}}
