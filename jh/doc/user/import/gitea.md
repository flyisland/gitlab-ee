---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Gitea 迁移
description: "从 Gitea 迁移到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将您的项目从 Gitea 导入到极狐GitLab。

Gitea 导入器会导入 Gitea 中的部分条目。

| Gitea 条目                    | 是否导入 |
|:------------------------------|:---------|
| 代码仓库描述                  | {{< yes >}} |
| Git 代码仓库数据              | {{< yes >}} |
| 议题                          | {{< yes >}} |
| 合并请求                      | {{< yes >}} |
| 里程碑                        | {{< yes >}} |
| 标记                          | {{< yes >}} |
| 合并请求中的差异评论          |          |

<a id="importer-workflow"></a>

## 导入器工作流

Gitea 导入器支持在 JihuLab.com 和极狐GitLab 私有化部署上对用户贡献进行迁移后映射。该导入器还支持一种[替代方法](#alternative-method-of-mapping)进行映射。

导入时：

- 代码仓库的公开访问权限会保留。如果代码仓库在 Gitea 中是私有的，那么在极狐GitLab 中也会创建为私有。
- 导入的议题、合并请求和评论在极狐GitLab 中带有 **已导入** 标记。
- 由于 Gitea 不是 OAuth 提供商，作者或指派人无法映射到您极狐GitLab 实例上的用户。此时会将项目创建者（通常是启动导入流程的用户）设置为作者。对于议题，您仍可以看到原始的 Gitea 作者。
- 极狐GitLab 不会自动创建不存在的命名空间或群组，如果命名空间或群组名称已被占用，也不会回退到您的个人命名空间。

<a id="prerequisites"></a>

## 先决条件

- Gitea 1.0.0 或更高版本。
- 您必须启用 [Gitea 导入源](../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)，或请极狐GitLab 管理员启用它。在 JihuLab.com 上默认启用。
- 在目标群组上具有维护者或所有者角色才能导入。

<a id="import-your-gitea-repositories"></a>

## 导入您的 Gitea 代码仓库

导入过程中，您需要创建个人访问令牌，并与 Gitea 执行一次性授权，以授予极狐GitLab 访问您代码仓库的权限。

要导入您的 Gitea 代码仓库：

1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新建项目/仓库**。
1. 要启动导入授权流程，请选择 **Gitea**。
1. 转到 `https://your-gitea-instance/user/settings/applications`。将 `your-gitea-instance` 替换为您的 Gitea 实例的主机名。
1. 选择 **生成新令牌**。
1. 输入令牌描述。
1. 选择 **生成令牌**。
1. 复制令牌哈希。
1. 返回极狐GitLab，并将该令牌提供给 Gitea 导入器。
1. 选择 **列出您的 Gitea 代码仓库**，等待极狐GitLab 读取您代码仓库的信息。完成后，极狐GitLab 会显示导入器页面，供您选择要导入的代码仓库。在此处，您可以查看 Gitea 代码仓库的导入状态：

   - 正在导入的代码仓库显示为已开始状态。
   - 已成功导入的代码仓库显示为绿色，状态为已完成。
   - 尚未导入的代码仓库在表格右侧显示 **导入**。
   - 已导入的代码仓库在表格右侧显示 **重新导入**。

1. 要完成 Gitea 代码仓库的导入，您可以：

   - 一次性导入所有 Gitea 项目。在左上角，选择 **导入所有项目**。
   - 通过按名称筛选项目，仅导入选定的项目。如果您应用了筛选条件，**导入所有项目** 只会导入选定的项目。
   - 如果您有相应权限，可以为项目选择不同的名称和不同的命名空间。

<a id="alternative-method-of-mapping"></a>

## 替代映射方法

在极狐GitLab 18.5 及更早版本中，您可以禁用 `gitea_user_mapping` 功能标志，以使用替代的用户贡献映射方法进行导入。

> [!flag]
> 此功能的可用性由功能标志控制。不建议使用此功能，并且以下情况不支持此功能：
>
> - 迁移到 JihuLab.com。
> - 迁移到极狐GitLab 私有化部署 18.6 及更高版本。
>
> 在此映射方法中发现的问题不太可能被修复。请改用没有这些限制的[迁移后方法](mapping/post_migration_mapping.md)。
>
> 更多信息，请参见[议题 512211](https://gitlab.com/gitlab-org/gitlab/-/work_items/512211)。

使用此方法时，用户贡献默认分配给项目创建者（通常是启动导入流程的用户）。
