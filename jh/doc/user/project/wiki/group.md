---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 创建、编辑和管理群组 Wiki，以便在群组内的所有项目之间共享文档。
title: 群组 Wiki
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您使用极狐GitLab 群组来管理多个项目，部分文档可能会跨越多个群组。您可以创建群组 Wiki，而不是[项目 Wiki](_index.md)，以确保所有群组成员都拥有正确的访问权限来参与贡献。群组 Wiki 与[项目 Wiki](_index.md) 类似，但存在一些限制：

- 不支持 [Git LFS](../../../topics/git/lfs/_index.md)。
- 对群组 Wiki 的更改不会显示在[群组活动动态](../../group/manage.md#group-activity-analytics)中。

如需了解最新动态，请关注[跟踪与项目 Wiki 功能对等的史诗](https://gitlab.com/groups/gitlab-org/-/work_items/2782)。

与项目 Wiki 类似，拥有开发者、维护者或所有者角色的群组成员可以编辑群组 Wiki。群组 Wiki 代码仓库可以使用[群组代码仓库存储移动 API](../../../api/group_repository_storage_moves.md) 进行移动。

<a id="view-a-group-wiki"></a>

## 查看群组 Wiki

要访问群组 Wiki：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**计划** > **Wiki**。

<a id="export-a-group-wiki"></a>

## 导出群组 Wiki

群组中拥有所有者角色的用户可以在导入或导出群组时[导入或导出群组 Wiki](../settings/import_export.md#migrate-groups-by-uploading-an-export-file-deprecated)。

当账号降级或极狐GitLab 试用结束时，群组 Wiki 中创建的内容不会被删除。只要导出 Wiki 所属的群组，群组 Wiki 数据就会随之导出。

如果该功能不再可用，要从导出文件中访问群组 Wiki 数据，您必须：

1. 使用以下命令解压[导出文件 tarball](../settings/import_export.md#migrate-groups-by-uploading-an-export-file-deprecated)，将 `FILENAME` 替换为您的文件名：
   `tar -xvzf FILENAME.tar.gz`
1. 浏览到 `repositories` 目录。该目录包含一个扩展名为 `.wiki.bundle`的 [Git bundle](https://git-scm.com/docs/git-bundle)。
1. 将该 Git bundle 克隆到新的代码仓库中，将 `FILENAME` 替换为您的 bundle 名称：`git clone FILENAME.wiki.bundle`

Wiki 中的所有文件都可在该 Git 代码仓库中找到。

<a id="configure-group-wiki-visibility"></a>

## 配置群组 Wiki 可见性

极狐GitLab 中默认启用 Wiki。群组[管理员](../../permissions.md)可以通过群组设置启用或禁用群组 Wiki。

要打开群组设置：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 滚动到 **Wiki** 并选择以下选项之一：
   - **已启用**：对于公开群组，所有人都可以访问 Wiki。对于内部群组，只有已认证用户可以访问 Wiki。
   - **私有**：只有群组成员可以访问 Wiki。
   - **已禁用**：Wiki 不可访问，也无法下载。
1. 选择**保存更改**。

<a id="delete-the-contents-of-a-group-wiki"></a>

## 删除群组 Wiki 的内容

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此操作会删除 Wiki 中的所有数据。

您可以使用 Rails 控制台删除群组 Wiki 的内容。之后，您可以用新内容填充该 Wiki。

> [!warning]
> 此命令会直接更改数据，如果运行不当可能会造成破坏。
> 您应先在测试环境中运行这些说明。请准备好实例的备份，以便在必要时恢复实例。

先决条件：

- 您必须是管理员。

要删除群组 Wiki 中的所有数据并将其重建为空白状态：

1. 启动 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下命令：

   ```ruby
   # Enter your group's path
   g = Group.find_by_full_path('<group-name>')

   # This command deletes the wiki group from the filesystem.
   g.wiki.repository.remove

   # Refresh the wiki repository state.
   g.wiki.repository.expire_exists_cache
   ```

Wiki 中的所有数据均已清除，该 Wiki 已可供使用。
