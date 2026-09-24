---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 命名空间
description: 了解不同类型的命名空间。
---

命名空间用于组织极狐GitLab 中的项目。由于每个命名空间相互独立，您可以在多个命名空间中使用相同的项目名称。

为命名空间选择名称时，请注意：

- [命名规则](../reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)
- [保留的群组名称](../reserved_names.md#reserved-group-names)

> [!note]
> 包含句点（`.`）的命名空间在[发布 Terraform 模块](../packages/terraform_module_registry/_index.md#publish-a-terraform-module)时，会导致 SSL 证书验证和源路径出现问题。

<a id="types-of-namespaces"></a>

## 命名空间类型

极狐GitLab 有两种类型的命名空间：

- **用户**：您的个人命名空间基于您的用户名。在个人命名空间中：
  - 您无法创建子群组。
  - 您所属的群组不会继承您的个人命名空间权限或功能。
  - 您创建的所有项目都位于此命名空间范围内。
  - 更改用户名也会更改项目和命名空间的 URL。在更改用户名之前，请阅读[代码仓重定向](../project/repository/_index.md#repository-path-changes)的相关内容。

- **群组**：群组或子群组命名空间基于群组或子群组名称。在群组和子群组命名空间中：
  - 您可以创建多个子群组来管理多个项目。
  - 子群组会继承父群组的部分设置。您可以在子群组的 **设置** 中查看这些设置。
  - 您可以为每个子群组和项目单独配置设置。
  - 您可以独立于名称来管理群组或子群组的 URL。

<a id="determine-which-type-of-namespace-youre-in"></a>

## 确定您所在的命名空间类型

要确定您是在群组命名空间还是个人命名空间中，可以查看 URL。例如：

| 命名空间所属 | URL | 命名空间 |
| ------------- | --- | --------- |
| 名为 `alex` 的用户。 | `https://gitlab.example.com/alex` | `alex` |
| 名为 `alex-team` 的群组。 | `https://gitlab.example.com/alex-team` | `alex-team` |
| 名为 `alex-team` 的群组，包含名为 `marketing` 的子群组。 |  `https://gitlab.example.com/alex-team/marketing` | `alex-team/marketing` |

<a id="determine-the-namespace-id"></a>

## 确定命名空间 ID

命名空间 ID 即群组 ID 或项目 ID。使用群组 ID 与群组交互，使用项目 ID 与项目交互。

您可以在 UI 中找到群组和项目 ID：

- [查找群组 ID](../group/_index.md#find-the-group-id)。
- [查找项目 ID](../project/working_with_projects.md#find-the-project-id)。


