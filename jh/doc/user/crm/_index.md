---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 客户关系管理 (CRM)
description: 客户管理、组织、联系人及权限。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 14.6 中引入，带有一个名为 `customer_relations` 的功能标志。默认禁用。
- 在极狐GitLab 14.8 及更高版本中，您只能[在顶级群组中创建联系人和组织](https://gitlab.com/gitlab-org/gitlab/-/issues/350634)。
- 在极狐GitLab 15.0 中[在 JihuLab.com 和私有化部署实例上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/346082)。
- 在极狐GitLab 15.1 中[功能标志移除](https://gitlab.com/gitlab-org/gitlab/-/issues/346082)。
- 在极狐GitLab 17.7 中，将[最低用户角色从报告者更改为计划者](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)。

{{< /history >}}

> [!note]
> 此功能目前未在进行活跃开发，但欢迎[社区贡献](https://about.gitlab.com/community/contribute/)。要确定该功能是否满足您的需求，请查看[史诗 5323](https://jihulab.com/groups/gitlab-cn/-/epics/5323) 中的开放工作项。

通过客户关系管理 (CRM)，您可以创建联系人（个人）和组织（公司）的记录，并将其与工作项关联起来。

默认情况下，联系人和组织只能在顶级群组中创建。
若要在其他群组中创建联系人和组织，请[配置联系人来源](#configure-the-contact-source)。

您可以使用联系人和组织将工作与客户挂钩，以便进行计费和报告。
关于未来的规划，请参见[议题 2256](https://gitlab.com/gitlab-org/gitlab/-/issues/2256)。

## <a id="permissions"></a>

权限

| 权限                         | 访客 | 计划者 | 群组报告者 | 群组开发者、维护者和所有者 |
|------------------------------------|-------|---------|----------------|----------------------------------------|
| 查看联系人/组织                   |       | ✓       | ✓              | ✓                                      |
| 查看工作项联系人                 |       | ✓       | ✓              | ✓                                      |
| 添加/移除工作项联系人             |       | ✓       | ✓              | ✓                                      |
| 创建/编辑联系人/组织              |       |         |                | ✓                                      |

## <a id="enable-customer-relations-management-crm"></a>

启用客户关系管理 (CRM)

{{< history >}}

- 在极狐GitLab 16.9 中[默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/108378)。

{{< /history >}}

客户关系管理功能在群组级别启用。如果您的群组包含子群组，并且您想在子群组中使用 CRM 功能，则也必须为该子群组启用 CRM 功能。

要为群组或子群组启用客户关系管理：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或子群组。
1. 选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 选择 **启用客户关系**。
1. 选择 **保存更改**。

## <a id="configure-the-contact-source"></a>

配置联系人来源

{{< history >}}

- 在极狐GitLab 17.6 中[可用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/167475)。

{{< /history >}}

默认情况下，联系人来自工作项的顶级群组。

群组的联系人来源将应用于所有子群组，除非子群组已配置了自己的联系人来源。

要为群组或子群组配置联系人来源：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或子群组。
1. 选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 选择 **联系人来源** > **搜索群组**。
1. 选择希望从中获取联系人的群组。
1. 选择 **保存更改**。

## <a id="contacts"></a>

联系人

### <a id="view-contacts-linked-to-a-group"></a>

查看关联到群组的联系人

先决条件：

- 您必须具有该群组的计划者、报告者、开发者、维护者或所有者角色。

要查看群组的联系人：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。

### <a id="create-a-contact"></a>

创建联系人

先决条件：

- 您必须具有该群组的开发者、维护者或所有者角色。

要创建联系人：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 选择 **新建联系人**。
1. 填写所有必填字段。
1. 选择 **创建新联系人**。

您也可以使用 GraphQL API [创建](../../api/graphql/reference/_index.md#mutationcustomerrelationscontactcreate)联系人。

### <a id="edit-a-contact"></a>

编辑联系人

先决条件：

- 您必须具有该群组的开发者、维护者或所有者角色。

要编辑现有联系人：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 在要编辑的联系人旁边，选择 **编辑** ({{< icon name="pencil" >}})。
1. 编辑必填字段。
1. 选择 **保存更改**。

您也可以使用 GraphQL API [编辑](../../api/graphql/reference/_index.md#mutationcustomerrelationscontactupdate)联系人。

#### <a id="change-the-state-of-a-contact"></a>

更改联系人状态

每个联系人都可能处于两种状态之一：

- **活跃**：此状态下的联系人可以添加到工作项。
- **非活跃**：此状态下的联系人不能添加到工作项。

要更改联系人状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 在要编辑的联系人旁边，选择 **编辑** ({{< icon name="pencil" >}})。
1. 选中或清除 **活跃** 复选框。
1. 选择 **保存更改**。

## <a id="organizations"></a>

组织

### <a id="view-organizations"></a>

查看组织

先决条件：

- 您必须具有该群组的计划者、报告者、开发者、维护者或所有者角色。

要查看群组的组织：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 在右上角，选择 **组织**。

### <a id="create-an-organization"></a>

创建组织

先决条件：

- 您必须具有该群组的开发者、维护者或所有者角色。

要创建组织：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 在右上角，选择 **组织**。
1. 选择 **新建组织**。
1. 填写所有必填字段。
1. 选择 **创建新组织**。

您也可以使用 GraphQL API [创建](../../api/graphql/reference/_index.md#mutationcustomerrelationsorganizationcreate)组织。

### <a id="edit-an-organization"></a>

编辑组织

先决条件：

- 您必须具有该群组的开发者、维护者或所有者角色。

要编辑现有组织：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 在右上角，选择 **组织**。
1. 在要编辑的组织旁边，选择 **编辑** ({{< icon name="pencil" >}})。
1. 编辑必填字段。
1. 选择 **保存更改**。

您也可以使用 GraphQL API [编辑](../../api/graphql/reference/_index.md#mutationcustomerrelationsorganizationupdate)组织。

## <a id="tickets"></a>

工单

如果您使用[服务台](../project/service_desk/_index.md)并从邮件创建工单，那么工单会关联到与发件人和抄送中的电子邮箱地址匹配的联系人。

### <a id="view-work-items-linked-to-a-contact"></a>

查看关联到联系人的工作项

先决条件：

- 您必须具有该群组的计划者、报告者、开发者、维护者或所有者角色。

要查看联系人的工作项，您可以从工作项侧边栏中选择一个联系人，或者：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 在要查看其工作项的联系人旁边，选择 **查看工作项** ({{< icon name="work-items" >}})。

### <a id="view-work-items-linked-to-an-organization"></a>

查看关联到组织的工作项

先决条件：

- 您必须具有该群组的计划者、报告者、开发者、维护者或所有者角色。

要查看组织的工作项：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **客户关系**。
1. 在右上角，选择 **组织**。
1. 在要查看其工作项的组织旁边，选择 **查看工作项** ({{< icon name="work-items" >}})。

### <a id="view-contacts-linked-to-a-work-item"></a>

查看关联到工作项的联系人

先决条件：

- 您必须具有该群组的计划者、报告者、开发者、维护者或所有者角色。

您可以在右侧边栏中查看与工作项关联的联系人。

要查看联系人的详细信息，请将鼠标悬停在联系人姓名上。

您也可以使用 [GraphQL](../../api/graphql/reference/_index.md#mutationcustomerrelationsorganizationcreate) API 查看工作项联系人。

### <a id="add-contacts-to-a-work-item"></a>

向工作项添加联系人

先决条件：

- 您必须具有该群组的计划者、报告者、开发者、维护者或所有者角色。

要向工作项添加[活跃](#change-the-state-of-a-contact)联系人，请使用带 `[contact:address@example.com]` 的 [`/add_contacts` 快速操作](../project/quick_actions.md#add_contacts)。

您也可以使用 [GraphQL](../../api/graphql/reference/_index.md#mutationissuesetcrmcontacts) API 添加、移除或替换工作项联系人。

### <a id="remove-contacts-from-a-work-item"></a>

从工作项移除联系人

先决条件：

- 您必须具有该群组的计划者、报告者、开发者、维护者或所有者角色。

要从工作项移除联系人，请使用带 `[contact:address@example.com]` 的 [`/remove_contacts` 快速操作](../project/quick_actions.md#remove_contacts)。

您也可以使用 [GraphQL](../../api/graphql/reference/_index.md#mutationissuesetcrmcontacts) API 添加、移除或替换工作项联系人。

## <a id="autocomplete-contacts"></a>

联系人自动补全

{{< history >}}

- 在极狐GitLab 14.8 中引入，带有一个名为 `contacts_autocomplete` 的功能标志。默认禁用。
- 在极狐GitLab 15.0 中[在 JihuLab.com 和私有化部署实例上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/352123)。
- 在极狐GitLab 15.2 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/352123)。功能标志 `contacts_autocomplete` 已移除。

{{< /history >}}

当您使用 `/add_contacts` 快速操作时，在它后面输入 `[contact:` 将弹出包含[活跃](#change-the-state-of-a-contact)联系人的自动补全列表：

```plaintext
/add_contacts [contact:
```

当您使用 `/remove_contacts` 快速操作时，在它后面输入 `[contact:` 将弹出包含已添加到工作项的联系人的自动补全列表：

```plaintext
/remove_contacts [contact:
```

## <a id="moving-objects-with-crm-entries"></a>

移动包含 CRM 条目的对象

当您移动工作项或项目，且**父群组联系人来源匹配**时，工作项将保留其联系人。

当您移动工作项或项目，且**父群组联系人来源发生变化**时，工作项将丢失其联系人。

当您移动一个已[配置联系人来源](#configure-the-contact-source)的群组，或者其**联系人来源保持不变**时，工作项将保留其联系人。

当您移动一个群组，且其**联系人来源发生变化**时：

- 所有独有的联系人和组织将迁移到新的顶级群组。
- 已存在的联系人（通过电子邮箱地址识别）将被视为重复项并被删除。
- 已存在的组织（通过名称识别）将被视为重复项并被删除。
- 所有工作项保留其联系人，或者更新为指向具有相同电子邮箱地址的联系人。

如果您没有在新顶级群组中创建联系人和组织的权限，则群组转移将失败。