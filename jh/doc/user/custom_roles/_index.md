---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义角色
description: Create custom roles with tailored permissions to meet specific organizational needs.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.4 中，通过 UI 创建和删除自定义角色的功能已引入。
- 在极狐GitLab 16.7 中，通过 UI 向群组添加具有自定义角色的用户、更改用户的自定义角色或从群组成员中移除自定义角色的功能已引入。
- 在极狐GitLab 16.9 中，在私有化部署实例上创建和删除实例级自定义角色的功能已引入。
- 在极狐GitLab 17.7 中，自定义管理员角色作为 [实验](../../policy/development_stages_support.md) 引入，通过一个名为 `custom_ability_read_admin_dashboard` 的功能标志。
- 在极狐GitLab 17.9 中，通过 UI 管理自定义管理员角色的功能已引入，通过一个名为 `custom_admin_roles` 的功能标志。默认禁用。
- 在极狐GitLab 18.3 中，自定义管理员角色 GA。功能标志 `custom_admin_roles` 默认启用。

{{< /history >}}

自定义角色允许您创建仅包含组织所需的特定 [自定义权限](abilities.md) 的角色。每个自定义角色都基于一个现有的默认角色。例如，您可以创建一个基于访客角色的自定义角色，但同时包含在项目仓库中查看代码的权限。

极狐GitLab 提供两种类型的自定义角色：

- 自定义成员角色：
  - 可以分配给群组或项目的成员。
  - 在任何子群组或项目中获得相同的权限。更多信息，请参见 [成员类型](../project/members/_index.md#membership-types)。
  - [占用一个席位](../../subscriptions/manage_seats.md#gitlabcom-billing-and-usage) 并成为 [计费用户](../../subscriptions/manage_seats.md#billable-users)。
    - 仅包含 `read_code` 权限的自定义访客成员角色不占用席位。
  - 可以分配给 SAML 或 LDAP 群组的成员。
- 自定义管理员角色：
  - 可以分配给实例上的任何用户。
  - 获得执行特定管理员操作的权限。
  - 可以分配给 LDAP 群组的成员。

<a id="create-a-custom-member-role"></a>

## 创建自定义成员角色

要创建自定义成员角色，您需要选择一个默认的极狐GitLab 角色并添加额外的 [权限](abilities.md)。基础角色定义了自定义角色可用的最低权限。您不能使用 [审计员](../../administration/auditor_users.md) 作为基础角色。

自定义权限可以允许通常仅限于维护者或所有者角色的操作。例如，具有管理 CI/CD 变量权限的自定义角色也允许管理由其他维护者或所有者添加的 CI/CD 变量。

自定义成员角色可用于群组和项目：

- 在 JihuLab.com 上，在创建自定义角色的顶级群组下。
- 在私有化部署实例中，在整个实例范围内可用。

前提条件：

- 对于 JihuLab.com，您必须具有群组的所有者角色。
- 对于私有化部署实例，您必须具有实例的管理员访问权限。
- 您必须拥有少于 10 个自定义角色。

要创建自定义成员角色：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
   - 对于私有化部署实例，在右上角选择 **管理员**。
1. 选择 **设置** > **角色与权限**。
1. 选择 **新建角色**。
1. 仅私有化部署实例。选择 **成员角色**。
1. 输入自定义角色的名称和描述。
1. 从 **基础角色** 下拉列表中，选择一个默认角色。
1. 为自定义角色选择任意权限。
1. 选择 **创建角色**。

您也可以 [使用 API](../../api/graphql/reference/_index.md#mutationmemberrolecreate) 创建自定义角色。

<a id="create-a-custom-admin-role"></a>

## 创建自定义管理员角色

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

要创建自定义管理员角色，您需要添加 [权限](abilities.md)，这些权限允许通常仅限于管理员的操作。每个自定义管理员角色可以拥有一个或多个权限。

前提条件：

- 您必须具有实例的管理员访问权限。
- 您必须拥有少于 10 个自定义角色。

要创建自定义管理员角色：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **角色与权限**。
1. 选择 **新建角色**。
1. 选择 **管理员角色**。
1. 输入自定义角色的名称和描述。
1. 为自定义角色选择任意权限。
1. 选择 **创建角色**。

您也可以 [使用 API](../../api/graphql/reference/_index.md#mutationmemberroleadmincreate) 创建自定义角色。

<a id="edit-a-custom-role"></a>

## 编辑自定义角色

{{< history >}}

- 在极狐GitLab 17.0 中引入。

{{< /history >}}

您可以编辑自定义角色的名称、描述和权限，但不能编辑基础角色。如果需要更改基础角色，则必须创建一个新的自定义角色。

前提条件：

- 对于 JihuLab.com，您必须具有群组的所有者角色。
- 对于私有化部署实例，您必须具有实例的管理员访问权限。

要编辑自定义角色：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
   - 对于私有化部署实例，在右上角选择 **管理员**。
1. 选择 **设置** > **角色与权限**。
1. 在自定义角色旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **编辑角色**。
1. 修改角色。
1. 选择 **保存角色**。

您也可以使用 API 编辑 [自定义成员角色](../../api/graphql/reference/_index.md#mutationmemberroleupdate) 或 [自定义管理员角色](../../api/graphql/reference/_index.md#mutationmemberroleadminupdate)。

<a id="view-details-of-a-custom-role"></a>

## 查看自定义角色详情

**角色与权限** 页面列出了所有可用的默认和自定义角色的基本信息。这包括名称、描述以及分配给每个自定义角色的用户数量等信息。每个自定义角色都包含一个 `自定义成员角色` 或 `自定义管理员角色` 徽章。

您还可以查看有关自定义角色的更详细信息，包括角色 ID、基础角色和特定权限。

前提条件：

- 对于 JihuLab.com，您必须具有群组的所有者角色。
- 对于私有化部署实例，您必须具有实例的管理员访问权限。

要查看自定义角色详情：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
   - 对于私有化部署实例，在右上角选择 **管理员**。
1. 选择 **设置** > **角色与权限**。
1. 在自定义角色旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **查看详情**。

<a id="delete-a-custom-role"></a>

## 删除自定义角色

您不能删除仍分配给用户的自定义角色。请参见 [将自定义角色分配给用户](#assign-a-custom-member-role)。

前提条件：

- 对于 JihuLab.com，您必须具有群组的所有者角色。
- 对于私有化部署实例，您必须具有实例的管理员访问权限。

要删除自定义角色：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
   - 对于私有化部署实例，在右上角选择 **管理员**。
1. 选择 **设置** > **角色与权限**。
1. 在自定义角色旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **删除角色**。
1. 在确认对话框中，选择 **删除角色**。

您也可以使用 API 删除 [自定义成员角色](../../api/graphql/reference/_index.md#mutationmemberroledelete) 或 [自定义管理员角色](../../api/graphql/reference/_index.md#mutationmemberroleadmindelete)。

<a id="assign-a-custom-member-role"></a>

## 分配自定义成员角色

您可以为群组和项目的成员分配或修改角色。您可以在现有用户或向 [群组](../group/_index.md#add-users-to-a-group)、[项目](../project/members/_index.md#add-users-to-a-project) 或 [实例](../profile/account/create_accounts.md) 添加用户时执行此操作。

前提条件：

- 对于群组，您必须具有群组的所有者角色。
- 对于项目，您必须具有项目的维护者或所有者角色。

要将自定义成员角色分配给现有用户：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或项目。
1. 选择 **管理** > **成员**。
1. 在 **角色** 列中，选择现有成员的角色。**角色详情** 抽屉将打开。
1. 从 **角色** 下拉列表中，选择要分配给成员的角色。
1. 选择 **更新角色** 以分配角色。

您也可以 [使用 API](../../api/graphql/reference/_index.md#mutationmemberroletouserassign) 分配或修改自定义角色分配。

<a id="assign-a-custom-admin-role"></a>

## 分配自定义管理员角色

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以为实例中的用户分配或修改管理员角色。您可以在现有用户或向 [实例](../profile/account/create_accounts.md) 添加用户时执行此操作。

前提条件：

- 您必须是极狐GitLab 实例的管理员。

要将自定义管理员角色分配给现有用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 为用户选择 **编辑**。
1. 在 **访问** 部分，将访问级别设置为 **常规** 或 **审计员**。
1. 从 **管理员区域** 下拉列表中，选择一个自定义管理员角色。

您也可以 [使用 API](../../api/graphql/reference/_index.md#mutationmemberroletouserassign) 分配或修改自定义角色分配。

<a id="assign-a-custom-role-to-an-invited-group"></a>

## 将自定义角色分配给受邀群组

{{< history >}}

- 在极狐GitLab 17.4 中，对受邀群组的自定义角色支持已引入，通过一个名为 `assign_custom_roles_to_group_links_sm` 的功能标志。默认禁用。
- 在极狐GitLab 17.4 中，在私有化部署实例上启用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。更多信息，请参见历史记录。

当您 [邀请一个群组到另一个群组](../project/members/sharing_projects_groups.md#invite-a-group-to-a-group) 时，您可以为群组中的每个用户分配自定义角色。

分配的角色会与用户在其原始群组中的角色和权限进行比较。通常，用户会被分配访问级别最小的角色。但是，如果用户在其原始群组中拥有自定义角色：

- 仅使用基础角色进行访问级别比较。自定义权限不进行比较。
- 如果两个自定义角色具有相同的基础角色，用户将保留其原始群组中的自定义角色。

下表提供了邀请到群组的用户可用的最大角色示例：

| 场景 | 具有访客角色的用户 | 具有访客角色 + `read_code` 的用户 | 具有访客角色 + `read_vulnerability` 的用户 | 具有开发者角色的用户 | 具有开发者角色 + `admin_vulnerability` 的用户 |
| --- | --- | --- | --- | --- | --- |
| **以访客角色邀请** | 访客 | 访客 | 访客 | 访客 | 访客 |
| **以访客角色 + `read_code` 邀请** | 访客 | 访客 + `read_code` | 访客 + `read_vulnerability` | 访客 + `read_code` | 访客 + `read_code` |
| **以访客角色 + `read_vulnerability` 邀请** | 访客 | 访客 + `read_code` | 访客 + `read_vulnerability` | 访客 + `read_vulnerability` | 访客 + `read_vulnerability` |
| **以开发者角色邀请** | 访客 | 访客 + `read_code` | 访客 + `read_vulnerability` | 开发者 | 开发者 |
| **以开发者角色 + `admin_vulnerability` 邀请** | 访客 | 访客 + `read_code` | 访客 + `read_vulnerability` | 开发者 | 开发者 + `admin_vulnerability` |

您只能在邀请一个群组到另一个群组时分配自定义角色。

<a id="assign-a-custom-role-to-an-external-group"></a>

## 将自定义角色分配给外部群组

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以将自定义成员角色分配给外部 LDAP 或 SAML 群组中的所有用户，或者仅将自定义管理员角色分配给从 LDAP 群组同步的用户。

要将自定义角色分配给 LDAP 或 SAML 群组：

- [将自定义成员角色分配给 SAML 群组](../group/saml_sso/group_sync.md#configure-saml-group-links)。
- [将自定义成员角色分配给 LDAP 群组](../group/access_and_permissions.md#manage-group-memberships-with-ldap)。
- [将自定义管理员角色分配给 LDAP 群组](../../administration/auth/ldap/ldap_synchronization.md#assign-a-custom-admin-role-to-an-ldap-group)。