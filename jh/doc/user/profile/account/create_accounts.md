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

用户账号是极狐GitLab 协作的基础。每个需要访问您的极狐GitLab 项目的人员都需要一个账号。用户账号控制访问权限、跟踪贡献并维护您实例的安全性。

您可以通过不同方式在极狐GitLab 中创建用户账号：

- 注重自主性的团队可自助注册
- 管理员驱动的创建，用于受控的入职
- 面向企业环境的认证集成
- 用于自动化和批量操作的控制台访问

您还可以使用[用户 API 端点](../../../api/users.md#create-a-user)自动创建用户。

根据您组织的规模、安全要求和工作流程选择合适的方法。

<a id="create-a-user-on-the-sign-in-page"></a>

## 在登录页面创建用户

默认情况下，任何访问您的极狐GitLab 实例的用户都可以注册账号。
如果您之前[禁用了此设置](../../../administration/settings/sign_up_restrictions.md#disable-new-user-account-creation)，则必须将其重新开启。

用户可以通过以下任一方式创建自己的账号：

- 选择登录页面上的 **立即注册** 链接。
- 导航到您的极狐GitLab 实例的新用户账号链接（例如：`https://gitlab.example.com/users/sign_up`）。

<a id="create-a-user-in-the-admin-area"></a>

## 在管理区域创建用户

先决条件：

- 您必须是该实例的管理员。

要创建用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 选择 **新用户**。
1. 在 **账号** 部分，输入所需的账号信息。
1. 可选。在 **访问** 部分，配置任何项目限制或用户类型设置。
1. 选择 **创建用户**。

极狐GitLab 会向用户发送一封带有登录链接的电子邮件，用户首次登录时必须创建密码。您也可以直接为用户[设置密码](../../../security/reset_user_password.md#use-the-ui)。

<a id="create-a-user-with-an-authentication-integration"></a>

## 通过认证集成创建用户

极狐GitLab 可以通过认证集成自动创建用户账号。
用户在以下情况下创建：

- 在身份提供商中通过 [SCIM](../../group/saml_sso/scim_setup.md) 预配时。
- 首次通过以下方式登录时：
  - [LDAP](../../../administration/auth/ldap/_index.md)
  - [群组 SAML](../../group/saml_sso/_index.md)
  - 启用了 `allow_single_sign_on` 设置的 [OmniAuth 提供商](../../../integration/omniauth.md)

<a id="create-a-user-through-the-rails-console"></a>

## 通过 Rails 控制台创建用户

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 更改数据的命令如果未正确运行或在适当条件下运行，可能会导致损坏。
> 始终先在测试环境中运行命令，并准备好备份实例以便恢复。

要通过 Rails 控制台创建用户：

1. 启动一个 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 根据您的极狐GitLab 版本运行命令：

   {{< tabs >}}

   {{< tab title="16.10 及更早版本" >}}

   ```ruby
   u = User.new(username: 'test_user', email: 'test@example.com', name: 'Test User', password: 'password', password_confirmation: 'password')
   # u.assign_personal_namespace
   u.skip_confirmation! # 仅在您希望用户自动确认时使用。如果不使用，用户将收到确认电子邮件。
   u.save!
   ```

   {{< /tab >}}

   {{< tab title="16.11 至 17.6" >}}

   ```ruby
   u = User.new(username: 'test_user', email: 'test@example.com', name: 'Test User', password: 'password', password_confirmation: 'password')
   u.assign_personal_namespace(Organizations::Organization.default_organization)
   u.skip_confirmation! # 仅在您希望用户自动确认时使用。如果不使用，用户将收到确认电子邮件。
   u.save!
   ```

   {{< /tab >}}

   {{< tab title="17.7 及更高版本" >}}

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
   > 如果您已[禁用新用户账号](../../../administration/settings/sign_up_restrictions.md#disable-new-user-account-creation)，
   > 则必须以管理员身份运行此命令。在前面的命令中，将 `Users::CreateService.new(nil,`
   > 替换为 `Users::CreateService.new(User.find_by(admin: true),`

   {{< /tab >}}

   {{< /tabs >}}