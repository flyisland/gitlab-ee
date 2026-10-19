---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部用户
description: 为外部成员授予针对特定资源的有限访问权限，并限制其权限。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

外部用户对实例中的内部或私有群组和项目拥有有限的访问权限。与普通用户不同，外部用户必须被显式添加到群组或项目中。但是，与普通用户一样，外部用户也会被分配成员角色，并获得所有相关的[权限](../user/permissions.md#project-permissions)。

外部用户：

- 可以访问公开群组、项目和代码片段。
- 可以访问他们是成员的内部或私有群组和项目。
- 可以在他们是成员的任何顶级群组中创建子群组、项目和代码片段。
- 不能在其个人命名空间中创建群组、项目或代码片段。

外部用户通常是在组织外部的用户只需要访问某个特定项目时创建的。为外部用户分配角色时，您应了解与该角色相关的[项目可见性](../user/public_access.md#change-project-visibility)和[权限](../user/project/settings/_index.md#configure-project-features-and-permissions)。例如，如果为某个私有项目中的外部用户分配了访客角色，他们将无法访问代码。

> [!note]
> 外部用户会被计为计费用户，并占用一个许可证席位。
>
> 如果您[创建了外部提供商列表](../integration/omniauth.md#create-an-external-providers-list)，
> 使用所列提供商登录的用户会被自动标记为外部用户。

<a id="create-an-external-user"></a>

## 创建外部用户

先决条件：

- 管理员访问权限。

要创建新的外部用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择**新建用户**。
1. 在**账户**部分，输入所需的账户信息。
1. 可选。在**访问权限**部分，配置任何项目限制或用户类型设置。
1. 选中**外部**复选框。
1. 选择**创建用户**。

您还可以通过以下方式创建外部用户：

- [SAML 群组](../integration/saml.md#external-groups)。
- [LDAP 群组](auth/ldap/ldap_synchronization.md#external-groups)。
- [外部提供商列表](../integration/omniauth.md#create-an-external-providers-list)。
- [用户 API](../api/users.md)。

<a id="make-new-users-external-by-default"></a>

## 默认将新用户设为外部用户

您可以将实例配置为默认将所有新用户设为外部用户。您可以稍后修改这些用户账户，以移除外部用户标记。

配置此功能时，您还可以定义一个用于识别电子邮件地址的正则表达式。电子邮件匹配的新用户会被排除，不会被标记为外部用户。此正则表达式必须：

- 使用 Ruby 格式。
- 可转换为 JavaScript。
- 设置忽略大小写标志（`/regex pattern/i`）。

例如：

- `\.int@example\.com$`：匹配以 `.int@domain.com` 结尾的电子邮件地址。
- `^(?:(?!\.ext@example\.com).)*$\r?`：匹配不包含 `.ext@example.com`的电子邮件地址。

> [!warning]
> 添加正则表达式可能会增加正则表达式拒绝服务（ReDoS）攻击的风险。

先决条件：

- 您必须是极狐GitLab 私有化部署实例的管理员。

要默认将新用户设为外部用户：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**账户和限制**部分。
1. 选中**默认将新用户设为外部用户**复选框。
1. 可选。在**电子邮件排除模式**字段中，输入正则表达式。
1. 选择**保存更改**。
