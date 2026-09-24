---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Gitea 迁移
description: "从 Gitea 迁移到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.8 引入，极狐GitLab 不再自动创建不存在的命名空间或群组。当命名空间或群组名称被占用时，极狐GitLab 也不再回退使用用户的个人命名空间。
- 在极狐GitLab 16.0 中引入要求维护者角色而非开发者角色的限制，并向后移植到极狐GitLab 15.11.1 和极狐GitLab 15.10.5。
- 在极狐GitLab 16.11 中新增了导入路径中包含 `.` 的项目的功能。
- 在极狐GitLab 17.2 中，某些导入项上会显示 **已导入** 标记。
- 在极狐GitLab 17.8 中，于 JihuLab.com 上更改为 [迁移后用户贡献和成员映射](mapping/post_migration_mapping.md)。
- 在极狐GitLab 17.8 中，迁移后用户和贡献成员映射在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

将你的项目从 Gitea 迁移到极狐GitLab。

Gitea 导入器会从 Gitea 导入部分项。

| Gitea 项                    | 已导入 |
|:------------------------------|:---------|
| 仓库描述        | {{< yes >}} |
| Git 仓库数据           | {{< yes >}} |
| 议题                        | {{< yes >}} |
| 拉取请求                 | {{< yes >}} |
| 里程碑                    | {{< yes >}} |
| 标签                        | {{< yes >}} |
| 拉取请求的差异评论 |          |

<a id="importer-workflow"></a>

## 导入器工作流

Gitea 导入器支持 JihuLab.com 和私有化部署实例上用户贡献的迁移后映射。导入器也支持另一种 [备用映射方法](#alternative-method-of-mapping)。

导入时：

- 仓库的公开访问权限被保留。如果仓库在 Gitea 中是私有的，那么在极狐GitLab 中也会被创建为私有。
- 导入的议题、合并请求和评论在极狐GitLab 中会显示 **已导入** 标记。
- 由于 Gitea 不是 OAuth 提供程序，作者或指派人无法映射到你极狐GitLab 实例上的用户。项目创建者（通常是启动导入过程的用户）会被设置为作者。对于议题，你仍然可以查看原始的 Gitea 作者。

<a id="prerequisites"></a>

## 先决条件

- Gitea 版本 1.0.0 或更高版本。
- 你必须启用 [Gitea 导入源](../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)，或要求你的极狐GitLab 管理员启用。JihuLab.com 上默认启用。
- 在导入的目标群组中具有维护者或所有者角色。

<a id="import-your-gitea-repositories"></a>

## 导入你的 Gitea 仓库

在导入过程中，你需要创建一个个人访问令牌，并与 Gitea 进行一次性授权，以授予极狐GitLab 访问你的仓库的权限。

导入你的 Gitea 仓库：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
1. 要开始导入授权过程，选择 **Gitea**。
1. 前往 `https://your-gitea-instance/user/settings/applications`。将 `your-gitea-instance` 替换为你的 Gitea 实例的主机名。
1. 选择 **生成新令牌**。
1. 输入令牌描述。
1. 选择 **生成令牌**。
1. 复制令牌哈希值。
1. 返回极狐GitLab，并将令牌提供给 Gitea 导入器。
1. 选择 **列出你的 Gitea 仓库**，然后等待极狐GitLab 读取你的仓库信息。完成后，极狐GitLab 会显示导入器页面，供你选择要导入的仓库。在这里，你可以查看 Gitea 仓库的导入状态：

   - 正在导入的仓库显示为开始状态。
   - 已成功导入的仓库显示为绿色并带有完成状态。
   - 尚未导入的仓库在表格右侧显示 **导入**。
   - 已经导入的仓库在表格右侧显示 **重新导入**。

1. 要完成 Gitea 仓库的导入，你可以：

   - 一次性导入所有 Gitea 项目。在左上角选择 **导入所有项目**。
   - 通过按名称筛选项目，仅导入选定的项目。如果你应用了筛选器，**导入所有项目** 只会导入选定的项目。
   - 如果你有权限，可以为项目选择不同的名称和不同的命名空间。

<a id="alternative-method-of-mapping"></a>

## 备用映射方法

在极狐GitLab 18.5 及更早版本中，你可以禁用 `gitea_user_mapping` 功能标志，以使用备用的用户贡献映射方法进行导入。

> [!flag]
> 此功能的可用性由功能标志控制。此方法不推荐使用，且不适用于：
>
> - 迁移到 JihuLab.com。
> - 迁移到私有化部署 18.6 及更高版本。
>
> 此映射方法中发现的问题不太可能修复。请改用无这些限制的 [迁移后方法](mapping/post_migration_mapping.md)。

使用此方法时，用户贡献默认会分配给项目创建者（通常是启动导入过程的用户）。