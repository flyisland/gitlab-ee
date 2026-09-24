---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 集成管理
description: "Configure and manage settings for project and group integrations on GitLab Self-Managed instances."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 本页面包含面向管理员的项目和群组集成文档。有关用户文档，请参见[项目集成](../../user/project/integrations/_index.md)。

项目和群组管理员可以配置和启用集成。
作为实例管理员，您可以：

- 为集成设置默认配置参数。
- 配置允许列表，以控制在极狐GitLab 实例上可以启用哪些集成。

<a id="configure-default-settings-for-an-integration"></a>

## 配置集成默认设置

前提条件：

- 您必须拥有实例的管理员访问权限。

要配置集成的默认设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择一个集成。
1. 填写字段。
1. 选择 **保存更改**。

> [!warning]
> 这可能会影响您 极狐GitLab 实例上的全部或大部分群组和项目。请仔细查看以下详情。

如果这是您首次为集成设置实例级设置：

- 如果您在实例级设置中开启了 **启用集成** 开关，则该集成将为所有尚未配置此集成的群组和项目启用。
- 已配置该集成的群组和项目不会受到影响，但可以随时选择使用继承的设置。

当您进一步更改实例默认值时：

- 这些更改会立即应用到所有设置为使用默认设置的群组和项目。
- 这些更改会立即应用到在您上次为该集成保存默认值之后创建的新群组和项目。如果您的实例级默认设置中 **启用集成** 开关为开启状态，该集成会自动为所有这些群组和项目启用。
- 为该集成选择了自定义设置的群组和项目不会立即受到影响，并且可以随时选择使用最新的默认设置。

如果同时还为同一个集成配置了[群组级设置](../../user/project/integrations/_index.md#manage-group-default-settings-for-a-project-integration)，则该群组中的项目将继承群组级设置，而非实例级设置。

只能继承集成的整个设置。按字段继承的提案已在[史诗 2137](https://jihulab.com/groups/gitlab-cn/-/epics/2137)中提出。

<a id="remove-default-settings-for-an-integration"></a>

### 移除集成默认设置

前提条件：

- 您必须拥有实例的管理员访问权限。

要移除集成的默认设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择一个集成。
1. 选择 **重置** 并确认。

重置实例级默认设置会将该集成从所有设置为使用默认设置的项目中移除。

<a id="view-projects-that-use-custom-settings"></a>

### 查看使用自定义设置的项目

前提条件：

- 您必须拥有实例的管理员访问权限。

要查看实例中[使用自定义设置](../../user/project/integrations/_index.md#use-custom-settings-for-a-project-or-group-integration)的项目：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择一个集成。
1. 选择 **使用自定义设置的项目** 选项卡。

<a id="integration-allowlist"></a>

## 集成允许列表

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.7。

{{< /history >}}

默认情况下，项目和群组管理员可以启用集成。
但是，实例管理员可以配置允许列表，以控制在极狐GitLab 实例上可以启用哪些集成。

稍后被允许列表设置阻止的已启用集成将被禁用。
如果这些集成再次被允许，它们会以其现有配置重新启用。

如果您配置了一个空的允许列表，实例上将不允许任何集成。
在您配置允许列表后，新的极狐GitLab 集成默认不在允许列表中。

<a id="allow-some-integrations"></a>

### 允许部分集成

前提条件：

- 您必须拥有实例的管理员访问权限。

要仅允许允许列表中的集成：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 展开 **集成设置** 部分。
1. 选择 **仅允许此允许列表中的集成**。
1. 为您希望在实例上允许的每个集成选中复选框。
1. 选择 **保存更改**。

<a id="allow-all-integrations"></a>

### 允许所有集成

前提条件：

- 您必须拥有实例的管理员访问权限。

要允许极狐GitLab 实例上的所有集成：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 展开 **集成设置** 部分。
1. 选择 **允许所有集成**。
1. 选择 **保存更改**。