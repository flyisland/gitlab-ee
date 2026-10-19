---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 为极狐GitLab 实例上的项目配置自定义和内置项目模板。
title: 实例的项目模板
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

项目模板使用文件和配置填充新项目。在您的实例上，您可以
从您管理的群组配置自定义项目模板，并控制内置项目模板
是否对用户可用。

<a id="custom-project-templates"></a>

## 自定义项目模板

为加快实例上项目的创建速度，请配置一个包含模板项目的群组。然后，用户可以根据您的模板创建
[新项目](../user/project/_index.md#create-a-project-from-a-custom-template)，其中包含您指定的通用工具和配置。

要了解从模板项目复制哪些数据，请参阅
[从模板中复制的内容](../user/group/custom_project_templates.md#what-is-copied-from-the-templates)。

在将模板项目提供给实例使用之前，请选择一个群组
来管理这些模板。为防止模板发生任何意外更改，请为此目的创建一个新群组，而不是复用现有群组。如果您复用了
为其他目的创建的现有群组，则具有维护者角色的用户
可能会在不了解副作用的情况下编辑模板项目。

<a id="select-a-group-to-manage-template-projects"></a>

### 选择用于管理模板项目的群组

先决条件：

- 管理员访问权限。

要为您的实例选择用于管理项目模板的群组：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **模板**。
1. 展开 **自定义项目模板**。
1. 选择一个要使用的群组。
1. 选择 **保存更改**。

将群组配置为项目模板来源后，添加到该群组的新项目
将成为可用模板。

<a id="configure-a-project-for-use-as-a-template"></a>

### 将项目配置为模板

创建用于管理模板项目的群组后，请配置每个模板项目的
可见性和功能可用性。

先决条件：

- 您必须是实例的管理员，或者是具有
  允许您配置项目的角色的用户。

1. 确保项目直接属于该群组，而不是通过子群组。
   所选群组的子群组中的项目不能用作模板。
1. 要配置哪些用户可以选择项目模板，请设置
   [项目的可见性](../user/public_access.md#change-project-visibility)：
   - **公开** 和 **内部** 项目可由任何已认证用户选择。
   - **私有** 项目只能由该项目的成员选择。
1. 查看项目的
   [功能设置](../user/project/settings/_index.md#configure-project-features-and-permissions)。
   所有已启用的项目功能都应设置为 **所有具有访问权限的人**，但
   **GitLab Pages** 和 **安全与合规** 除外。

复制到每个新项目的代码仓库和数据库信息与
使用极狐GitLab 项目导入和导出功能导出的数据相同。
这包括模板项目的完整 Git 提交历史。
有关更多信息，请参阅[使用文件导出迁移极狐GitLab 数据](../user/project/settings/import_export.md)。

在导入过程中，某些项会被修改。例如，受保护分支
和受保护标签的访问级别会重置为维护者。有关
更多信息，请参阅
[已导入项的更改](../user/project/settings/import_export.md#changes-to-imported-items)。

要创建没有提交历史的模板，请使用包含所有要包含的文件的单个提交
来初始化您的模板项目。

<a id="built-in-project-templates"></a>

## 内置项目模板

[内置项目模板](../user/project/_index.md#create-a-project-from-a-built-in-template)
使用入门文件填充新项目。
默认情况下，这些模板对所有用户可用。
作为管理员，您可以关闭实例的此设置，并可选择强制执行，以便
群组所有者无法覆盖它。
群组所有者也可以
[为其群组控制此设置](../user/group/manage.md#control-built-in-project-templates)。

该设置使用级联继承：

- 默认情况下，根群组继承实例值。
- 子群组从其最近的祖先群组继承该值。
- 群组特定值会覆盖继承的值。
- 当您为实例强制执行该设置时，所有群组都会继承它。
- 当您为群组强制执行该设置时，所有子群组都会继承它。
- 当您更改实例设置时，新值会级联到所有群组。
- 当您更改群组设置时，新值会级联到所有子群组。

<a id="configure-built-in-project-templates"></a>

### 配置内置项目模板

先决条件：

- 您必须是管理员。

要控制实例的内置项目模板：

1. 在右上角，选择 **管理员**。
1. 选择 **设置** > **模板**。
1. 展开 **内置项目模板**。
1. 选中或清除 **启用内置项目模板** 复选框。
1. 可选。要防止群组更改此设置，请选中 **对所有群组强制执行**
   复选框。
1. 选择 **保存更改**。
