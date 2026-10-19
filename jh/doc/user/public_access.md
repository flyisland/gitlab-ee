---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目与群组可见性
description: Public, private, and internal.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 中的项目与群组可以是私有、内部或公开的。

项目或群组的可见性级别不影响项目或群组成员之间能否看到彼此。
项目与群组旨在用于协作。只有所有成员都了解彼此，这种协作才有可能。

项目或群组成员可以看到他们所属的项目或群组的所有成员。
项目或群组成员可以看到他们有权访问的项目和群组中所有成员的成员身份来源（原始项目或群组）。

<a id="private-projects-and-groups"></a>

## 私有项目与群组

对于私有项目，只有私有项目或群组的成员可以：

- 克隆项目。
- 查看公共访问目录 (`/public`)。

具有访客角色的用户无法克隆项目。

私有群组只能包含私有子群组和项目。

> [!note]
> 当你[与另一个群组共享私有群组](project/members/sharing_projects_groups.md#invite-a-group-to-a-group)时，
> 无法访问该私有群组的用户可以通过端点 `https://jihulab.com/groups/<inviting-group-name>/-/autocomplete_sources/members` 查看有权访问邀请群组的用户列表。
> 但是，私有群组的名称和路径会被隐藏，并且不会显示用户的成员身份来源。

<a id="internal-projects-and-groups"></a>

## 内部项目与群组

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

对于内部项目，任何经过身份验证的用户，包括具有访客角色的用户，都可以：

- 克隆项目。
- 查看公共访问目录 (`/public`)。

只有内部成员可以查看内部内容。

[外部用户](../administration/external_users.md) 无法克隆项目。

内部群组可以包含内部或私有的子群组和项目。

<a id="public-projects-and-groups"></a>

## 公开项目与群组

对于公开项目，任何用户，包括未经身份验证的用户，都可以：

- 克隆项目。
- 查看公共访问目录 (`/public`)。

公开群组可以包含公开、内部或私有的子群组和项目。

> [!note]
> 如果管理员限制了[**公开**可见性级别](../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)，
> 那么公共访问目录 (`/public`) 仅对经过身份验证的用户可见。

<a id="change-project-visibility"></a>

## 更改项目可见性

你可以更改项目的可见性。

先决条件：

- 你必须具有项目的所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 从 **项目可见性** 下拉列表中，选择一个选项。
   项目的可见性设置必须至少与其父群组的可见性一样严格。
1. 选择 **保存更改**。

<a id="change-the-visibility-of-individual-features-in-a-project"></a>

## 更改项目中单个功能的可见性

你可以更改项目中单个功能的可见性。

先决条件：

- 你必须具有项目的维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 要启用或禁用某个功能，打开或关闭功能开关。
1. 选择 **保存更改**。

<a id="change-group-visibility"></a>

## 更改群组可见性

你可以更改群组中所有项目的可见性。

先决条件：

- 你必须具有群组的所有者角色。
- 项目和子群组必须已经具有至少与父群组新设置一样严格的可见性设置。例如，如果群组中的某个项目或子群组是公开的，则无法将该群组设置为私有。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **命名、描述、可见性**。
1. 对于 **可见性级别**，选择一个选项。
   项目的可见性设置必须至少与其父群组的可见性一样严格。
1. 选择 **保存更改**。

<a id="restrict-use-of-public-or-internal-projects"></a>

## 限制使用公开或内部项目

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理员可以限制用户在创建项目或代码片段时可以选择的可见性级别。此设置有助于防止用户意外公开暴露其代码仓。

更多信息，请参见[限制可见性级别](../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。

