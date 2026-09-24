---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: Configure project templates and make them available to all projects on your GitLab instance.
title: 实例的自定义项目模板
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为了加速实例上项目的创建，请配置一个包含模板项目的群组。用户随后可以[基于您的模板创建新项目](../user/project/_index.md#create-a-project-from-a-custom-template)，其中包含您指定的通用工具和配置。

要了解模板项目中复制了哪些数据，请参阅[从模板复制的数据](../user/group/custom_project_templates.md#what-is-copied-from-the-templates)。

在将模板项目提供给您的实例之前，请选择一个群组来管理模板。为了防止模板发生任何意外更改，请为此目的创建一个新群组，而不是重复使用现有的群组。如果您重复使用为其他目的创建的现有群组，则拥有维护者角色的用户可能会在未理解副作用的情况下编辑模板项目。

<a id="select-a-group-to-manage-template-projects"></a>

## 选择管理模板项目的群组

先决条件：

- 管理员访问权限。

要为您的实例选择管理项目模板的群组：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **模板**。
1. 展开 **自定义项目模板**。
1. 选择要使用的群组。
1. 选择 **保存更改**。

在将群组配置为项目模板源后，添加到此群组的新项目将可用作模板。

<a id="configure-a-project-for-use-as-a-template"></a>

## 配置项目以用作模板

创建管理模板项目的群组后，配置每个模板项目的可见性和功能可用性。

先决条件：

- 您必须是实例的管理员，或者是具有允许您配置项目的角色的用户。

1. 确保项目直接属于该群组，而不是通过子群组。所选群组的子群组中的项目不能用作模板。
1. 要配置哪些用户可以选择项目模板，请设置[项目的可见性](../user/public_access.md#change-project-visibility)：
   - **公开** 和 **内部** 项目可供任何已认证用户选择。
   - **私有** 项目只能由该项目的成员选择。
1. 查看项目的[功能设置](../user/project/settings/_index.md#configure-project-features-and-permissions)。所有已启用的项目功能应设置为 **所有有权限访问的人**，**极狐GitLab Pages** 和 **安全与合规** 除外。

复制到每个新项目的仓库和数据库信息与通过极狐GitLab项目导入和导出的数据相同。这包括模板项目的完整 Git 提交历史。有关更多信息，请参阅[使用文件导出来迁移极狐GitLab数据](../user/project/settings/import_export.md)。

要创建没有提交历史的模板，请使用包含所有您想包含的文件的单次提交来初始化您的模板项目。

<a id="related-topics"></a>

## 相关主题

- [群组的自定义项目模板](../user/group/custom_project_templates.md)。