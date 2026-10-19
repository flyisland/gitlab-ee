---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义角色
description: 创建具有定制权限的自定义角色，以满足特定的组织需求。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

自定义角色允许您创建仅包含组织所需的特定[自定义权限](abilities.md)的角色。每个自定义角色都基于现有的默认角色。例如，您可以创建一个基于访客角色的自定义角色，但同时包含查看项目代码仓库中代码的权限。

极狐GitLab 提供两种类型的自定义角色：

- 自定义成员角色：
  - 可以分配给群组或项目的成员。
  - 在任何子群组或项目中获得相同的权限。更多信息，请参见[成员资格类型](../project/members/_index.md#membership-types)。
  - [占用席位](../../subscriptions/manage_seats.md#gitlabcom-billing-and-usage)并成为[计费用户](../../subscriptions/manage_seats.md#billable-users)。
    - 仅包含 `read_code` 权限的自定义访客成员角色不占用席位。
  - 可以分配给 SAML 或 LDAP 群组的成员。
- 自定义管理员角色：
  - 可以分配给实例上的任何用户。
  - 获得执行特定管理员操作的权限。
  - 可以分配给 LDAP 群组的成员。

<a id="create-a-custom-member-role"></a>

## 创建自定义成员角色

要创建自定义成员角色，您需要选择一个默认的极狐GitLab 角色并添加额外的[权限](abilities.md)。基础角色定义了自定义角色可用的最低权限。您不能使用[审计员](../../administration/auditor_users.md)作为基础角色。

自定义权限可以允许通常仅限于维护者或所有者角色的操作。例如，具有管理 CI/CD 变量权限的自定义角色，也可以管理由其他维护者或所有者添加的 CI/CD 变量。

自定义成员角色可用于群组和项目：

- 在 JihuLab.com 上，在创建自定义角色的顶级群组下可用。
- 在极狐GitLab 私有化部署上，在整个实例中可用。

先决条件：

- 对于 JihuLab.com，您必须拥有该群组的所有者角色。
- 对于极狐GitLab 私有化部署，您必须拥有该实例的管理员访问权限。
- 您的自定义角色数量必须少于 10 个。

要创建自定义成员角色：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   - 对于极狐GitLab 私有化部署，在右上角，选择**管理员**。
1. 选择**设置** > **角色和权限**。
1. 选择**新建角色**。
1. 仅限极狐GitLab 私有化部署实例。选择**成员角色**。
1. 为自定义角色输入名称和描述。
1. 从**基础角色**下拉列表中，选择一个默认角色。
1. 为自定义角色选择任意权限。
1. 选择**创建角色**。

您也可以[使用 API](../../api/graphql/reference/_index.md#mutationmemberrolecreate) 创建自定义角色。

<a id="create-a-custom-admin-role"></a>

## 创建自定义管理员角色

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

要创建自定义管理员角色，您需要添加允许执行通常仅限于管理员的操作的[权限](abilities.md)。每个自定义管理员角色可以拥有一个或多个权限。

先决条件：

- 您必须拥有该实例的管理员访问权限。
- 您的自定义角色数量必须少于 10 个。

要创建自定义管理员角色：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **角色和权限**。
1. 选择**新建角色**。
1. 选择**管理员角色**。
1. 为自定义角色输入名称和描述。
1. 为自定义角色选择任意权限。
1. 选择**创建角色**。

您也可以[使用 API](../../api/graphql/reference/_index.md#mutationmemberroleadmincreate) 创建自定义角色。

<a id="edit-a-custom-role"></a>

## 编辑自定义角色

您可以编辑自定义角色的名称、描述和权限，但不能编辑基础角色。如果您需要更改基础角色，必须创建一个新的自定义角色。

先决条件：

- 对于 JihuLab.com，您必须拥有该群组的所有者角色。
- 对于极狐GitLab 私有化部署，您必须拥有该实例的管理员访问权限。

要编辑自定义角色：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   - 对于极狐GitLab 私有化部署，在右上角，选择**管理员**。
1. 选择**设置** > **角色和权限**。
1. 在自定义角色旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **编辑角色**。
1. 修改该角色。
1. 选择**保存角色**。

您也可以使用 API 编辑[自定义成员角色](../../api/graphql/reference/_index.md#mutationmemberroleupdate)或[自定义管理员角色](../../api/graphql/reference/_index.md#mutationmemberroleadminupdate)。

<a id="view-details-of-a-custom-role"></a>

## 查看自定义角色的详细信息

**角色和权限**页面列出了所有可用的默认角色和自定义角色的基本信息。这包括名称、描述以及分配给每个自定义角色的用户数量等信息。每个自定义角色都包含 `Custom member role` 或 `Custom admin role` 徽章。

您还可以查看自定义角色的更详细信息，包括角色 ID、基础角色和特定权限。

先决条件：

- 对于 JihuLab.com，您必须拥有该群组的所有者角色。
- 对于极狐GitLab 私有化部署，您必须拥有该实例的管理员访问权限。

要查看自定义角色的详细信息：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   - 对于极狐GitLab 私有化部署，在右上角，选择**管理员**。
1. 选择**设置** > **角色和权限**。
1. 在自定义角色旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **查看详细信息**。

<a id="delete-a-custom-role"></a>

## 删除自定义角色

您不能删除仍分配给用户的自定义角色。请参见[为用户分配自定义角色](#assign-a-custom-member-role)。

先决条件：

- 对于 JihuLab.com，您必须拥有该群组的所有者角色。
- 对于极狐GitLab 私有化部署，您必须拥有该实例的管理员访问权限。

要删除自定义角色：

1. 在左侧边栏中：
   - 对于 JihuLab.com，在顶部栏中，选择**搜索或跳转到**并找到您的群组。
   - 对于极狐GitLab 私有化部署，在右上角，选择**管理员**。
1. 选择**设置** > **角色和权限**。
1. 在自定义角色旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **删除角色**。
1. 在确认对话框中，选择**删除角色**。

您也可以使用 API 删除[自定义成员角色](../../api/graphql/reference/_index.md#mutationmemberroledelete)或[自定义管理员角色](../../api/graphql/reference/_index.md#mutationmemberroleadmindelete)。

<a id="assign-a-custom-member-role"></a>

## 分配自定义成员角色

您可以为群组和项目的成员分配或修改角色。您可以对现有用户执行此操作，也可以在将用户添加到[群组](../group/_index.md#add-users-to-a-group)、[项目](../project/members/_index.md#add-users-to-a-project)或[实例](../profile/account/create_accounts.md)时执行此操作。

先决条件：

- 对于群组，您必须拥有该群组的所有者角色。
- 对于项目，您必须拥有该项目的维护者或所有者角色。

要为现有用户分配自定义成员角色：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组或项目。
1. 选择**管理** > **成员**。
1. 在**角色**列中，为现有成员选择角色。**角色详细信息**抽屉会打开。
1. 从**角色**下拉列表中，选择要分配给该成员的角色。
1. 选择**更新角色**以分配该角色。

您也可以[使用 API](../../api/graphql/reference/_index.md#mutationmemberroletouserassign) 分配或修改自定义角色分配。

<a id="assign-a-custom-admin-role"></a>

## 分配自定义管理员角色

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以为实例中的用户分配或修改管理员角色。您可以对现有用户执行此操作，也可以在将用户添加到[实例](../profile/account/create_accounts.md)时执行此操作。

先决条件：

- 您必须是极狐GitLab 实例的管理员。

要为现有用户分配自定义管理员角色：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 为用户选择**编辑**。
1. 在**访问**部分，将访问级别设置为**常规**或**审计员**。
1. 从**管理区域**下拉列表中，选择一个自定义管理员角色。

您也可以[使用 API](../../api/graphql/reference/_index.md#mutationmemberroletouserassign) 分配或修改自定义角色分配。

<a id="assign-a-custom-role-to-an-invited-group"></a>

## 为受邀群组分配自定义角色

当您[邀请一个群组加入另一个群组](../project/members/sharing_projects_groups.md#invite-a-group-to-a-group)时，您可以为该群组中的每个用户分配自定义角色。

分配的角色会与用户在其原始群组中的角色和权限进行比较。通常，用户会被分配访问级别最低的角色。但是，如果用户在其原始群组中拥有自定义角色：

- 仅使用基础角色进行访问级别比较。不比较自定义权限。
- 如果两个自定义角色具有相同的基础角色，用户将保留其原始群组中的自定义角色。

下表提供了受邀加入群组的用户可用的最高角色的示例：

| 场景                                                | 拥有访客角色的用户 | 拥有访客角色 + `read_code`的用户 | 拥有访客角色 + `read_vulnerability`的用户 | 拥有开发者角色的用户     | 拥有开发者角色 + `admin_vulnerability`的用户 |
| ------------------------------------------------------- | -------------------- | ---------------------------------- | ------------------------------------------- | ---------------------------- | ------------------------------------------------ |
| **以访客角色受邀**                             | 访客                | 访客                            | 访客                                     | 访客                        | 访客                                          |
| **以访客角色 + `read_code` 受邀**               | 访客                | 访客 + `read_code`              | 访客 + `read_vulnerability`              | 访客 + `read_code`          | 访客 + `read_code`                            |
| **以访客角色 + `read_vulnerability` 受邀**      | 访客                | 访客 + `read_code`              | 访客 + `read_vulnerability`              | 访客 + `read_vulnerability` | 访客 + `read_vulnerability`                   |
| **以开发者角色受邀**                         | 访客                | 访客 + `read_code`              | 访客 + `read_vulnerability`              | 开发者                    | 开发者                                      |
| **以开发者角色 + `admin_vulnerability` 受邀** | 访客                | 访客 + `read_code`              | 访客 + `read_vulnerability`              | 开发者                    | 开发者 + `admin_vulnerability`              |

您只能在邀请一个群组加入另一个群组时分配自定义角色。[议题 468329](https://gitlab.com/gitlab-org/gitlab/-/issues/468329) 提议在邀请群组加入项目时分配自定义角色。

<a id="supported-objects"></a>

## 支持的对象

您可以将自定义角色和权限分配给以下对象：

| 对象 | 版本       | 议题 |
|--------|---------------|-------|
| 用户  | 15.9          | 已发布 |
| 群组 | 17.7          | 部分支持。在项目中分配群组的进一步支持已在[议题 468329](https://gitlab.com/gitlab-org/gitlab/-/issues/468329)中提议 |
| 令牌 | 不支持 | [议题 434354](https://gitlab.com/gitlab-org/gitlab/-/issues/434354) |

<a id="assign-a-custom-role-to-an-external-group"></a>

## 为外部群组分配自定义角色

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以为外部 LDAP 或 SAML 群组中的所有用户分配自定义成员角色，或仅为从 LDAP 群组同步的用户分配自定义管理员角色。

要为 LDAP 或 SAML 群组分配自定义角色：

- [为 SAML 群组分配自定义成员角色](../group/saml_sso/group_sync.md#configure-saml-group-links)。
- [为 LDAP 群组分配自定义成员角色](../group/access_and_permissions.md#manage-group-memberships-with-ldap)。
- [为 LDAP 群组分配自定义管理员角色](../../administration/auth/ldap/ldap_synchronization.md#assign-a-custom-admin-role-to-an-ldap-group)。

<a id="contribute-new-permissions"></a>

## 贡献新权限

如果某个权限不存在，您可以：

- 在[议题 391760](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)中讨论个别的自定义角色和权限请求。
- 使用[权限提案议题模板](https://gitlab.com/gitlab-org/gitlab/-/work_items/new?description_template=Permission%20Proposal)创建议题以请求该权限。
- 为 GitLab 贡献并添加该权限。
