---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 集成管理
description: "在极狐GitLab 私有化部署实例上配置和管理项目与群组集成的设置。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 有关用户文档，请参阅[项目集成](../../user/project/integrations/_index.md)。

项目和群组管理员可以配置并启用集成。作为实例管理员，您可以：

- 为集成设置默认配置参数。
- 配置允许名单，以控制极狐GitLab 实例上可以启用哪些集成。

<a id="configure-default-settings-for-an-integration"></a>

## 为集成配置默认设置

先决条件：

- 您必须拥有该实例的管理员访问权限。

要为集成配置默认设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择一个集成。
1. 填写各字段。
1. 选择**保存更改**。

> [!warning]
> 这可能会影响您极狐GitLab 实例上的所有或大部分群组和项目。请查看以下详细信息。

如果这是您首次为某个集成设置实例级设置：

- 如果您在实例级设置中开启了**启用集成**开关，则该集成会为所有尚未配置此集成的群组和项目启用。
- 已配置该集成的群组和项目不受影响，但可以随时选择使用继承的设置。

当您进一步更改实例默认设置时：

- 这些更改会立即应用于所有将该集成设置为使用默认设置的群组和项目。
- 这些更改会立即应用于较新的群组和项目，即在您上次保存该集成默认设置之后创建的群组和项目。如果您的实例级默认设置开启了**启用集成**开关，则该集成会自动为所有此类群组和项目启用。
- 为该集成选择了自定义设置的群组和项目不会立即受到影响，但可以随时选择使用最新的默认设置。

如果同一集成还配置了[群组级设置](../../user/project/integrations/_index.md#manage-group-default-settings-for-a-project-integration)，则该群组中的项目会继承群组级设置，而不是实例级设置。

只能继承集成的整体设置。按字段继承已在[史诗 2137](https://gitlab.com/groups/gitlab-org/-/work_items/2137)中提出。

<a id="remove-default-settings-for-an-integration"></a>

### 移除集成的默认设置

先决条件：

- 您必须拥有该实例的管理员访问权限。

要移除集成的默认设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择一个集成。
1. 选择**重置**并确认。

重置实例级默认设置会从所有将该集成设置为使用默认设置的项目中移除该集成。

<a id="view-projects-that-use-custom-settings"></a>

### 查看使用自定义设置的项目

先决条件：

- 您必须拥有该实例的管理员访问权限。

要查看您实例中[使用自定义设置](../../user/project/integrations/_index.md#use-custom-settings-for-a-project-or-group-integration)的项目：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择一个集成。
1. 选择**使用自定义设置的项目**标签页。

<a id="integration-allowlist"></a>

## 集成允许名单

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

默认情况下，项目和群组管理员可以启用集成。但是，实例管理员可以配置允许名单，以控制极狐GitLab 实例上可以启用哪些集成。

已启用但后来被允许名单设置阻止的集成会被禁用。如果这些集成再次被允许，则会使用其现有配置重新启用。

如果您配置了空的允许名单，则该实例上不允许任何集成。配置允许名单后，新的极狐GitLab 集成默认不在允许名单中。

<a id="allow-some-integrations"></a>

### 允许部分集成

先决条件：

- 您必须拥有该实例的管理员访问权限。

要仅允许允许名单中的集成：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**集成设置**部分。
1. 选择**仅允许此允许名单中的集成**。
1. 为您要在该实例上允许的每个集成选中复选框。
1. 选择**保存更改**。

<a id="allow-all-integrations"></a>

### 允许所有集成

先决条件：

- 您必须拥有该实例的管理员访问权限。

要允许极狐GitLab 实例上的所有集成：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**集成设置**部分。
1. 选择**允许所有集成**。
1. 选择**保存更改**。
