---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组 Wiki
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果你使用极狐GitLab 群组来管理多个项目，一些文档可能跨越多个群组。你可以创建群组 Wiki，而不是[项目 Wiki](_index.md)，以确保所有群组成员都拥有正确的访问权限来进行贡献。群组 Wiki 与[项目 Wiki](_index.md)类似，但存在一些限制：

- 不支持 [Git LFS](../../../topics/git/lfs/_index.md)。
- 对群组 Wiki 的更改不会显示在[群组的活动动态](../../group/manage.md#group-activity-analytics)中。

有关更新，请关注[追踪与项目 Wiki 功能对等的史诗](https://gitlab.com/groups/gitlab-org/-/epics/2782)。

与项目 Wiki 类似，拥有开发者、维护者或所有者角色的群组成员可以编辑群组 Wiki。群组 Wiki 仓库可以使用[群组仓库存储迁移 API](../../../api/group_repository_storage_moves.md)进行移动。

<a id="view-a-group-wiki"></a>

## 查看群组 Wiki

要访问群组 Wiki：

1. 在顶部栏中，选择**搜索或跳转到**并找到你的群组。
1. 要显示 Wiki，可以：
   - 在左侧边栏中，选择**计划** > **Wiki**。
   - 在群组的任何页面，使用 <kbd>g</kbd>+<kbd>w</kbd>
     [Wiki 键盘快捷键](../../shortcuts.md)。

<a id="export-a-group-wiki"></a>

## 导出群组 Wiki

在群组中拥有所有者角色的用户可以在导入或导出群组时[导入或导出群组 Wiki](../settings/import_export.md#migrate-groups-by-uploading-an-export-file-deprecated)。

当账户降级或极狐GitLab 试用结束时，在群组 Wiki 中创建的内容不会被删除。只要 Wiki 的群组所有者被导出，群组 Wiki 数据就会被导出。

如果该功能不再可用，要从导出文件访问群组 Wiki 数据，你必须：

1. 使用此命令解压[导出文件 tar 包](../settings/import_export.md#migrate-groups-by-uploading-an-export-file-deprecated)，将 `FILENAME` 替换为你的文件名：
   `tar -xvzf FILENAME.tar.gz`
1. 浏览到 `repositories` 目录。此目录包含一个扩展名为 `.wiki.bundle` 的 [Git bundle](https://git-scm.com/docs/git-bundle)。
1. 将 Git bundle 克隆到一个新的仓库中，将 `FILENAME` 替换为你的 bundle 名称：`git clone FILENAME.wiki.bundle`

Wiki 中的所有文件都可以在此 Git 仓库中找到。

<a id="configure-group-wiki-visibility"></a>

## 配置群组 Wiki 可见性

极狐GitLab 中默认启用 Wiki。群组[管理员](../../permissions.md)可以通过群组设置启用或禁用群组 Wiki。

要打开群组设置：

1. 在顶部栏中，选择**搜索或跳转到**并找到你的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 滚动到 **Wiki** 并选择以下选项之一：
   - **已启用**：对于公开群组，每个人都可以访问 Wiki。对于内部群组，只有已认证的用户可以访问 Wiki。
   - **私有**：只有群组成员可以访问 Wiki。
   - **已禁用**：Wiki 不可访问，且无法下载。
1. 选择**保存更改**。

<a id="delete-the-contents-of-a-group-wiki"></a>

## 删除群组 Wiki 的内容

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此操作会删除 Wiki 中的所有数据。

你可以使用 Rails 控制台删除群组 Wiki 的内容。然后你可以用新内容填充 Wiki。

> [!warning]
> 此命令会直接更改数据，如果运行不正确，可能会造成破坏。
> 你应该先在测试环境中运行这些说明。准备好实例的备份，以便在必要时可以恢复实例。

先决条件：

- 你必须是管理员。

要删除群组 Wiki 中的所有数据并重新创建为空白状态：

1. 启动一个 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下命令：

   ```ruby
   # 输入你的群组路径
   g = Group.find_by_full_path('<group-name>')

   # 此命令从文件系统中删除 Wiki 群组。
   g.wiki.repository.remove

   # 刷新 Wiki 仓库状态。
   g.wiki.repository.expire_exists_cache
   ```

Wiki 中的所有数据已被清除，Wiki 已准备好供使用。

<a id="related-topics"></a>

## 相关主题

- [面向管理员的 Wiki 设置](../../../administration/wikis/_index.md)
- [项目 Wiki API](../../../api/wikis.md)
- [群组仓库存储迁移 API](../../../api/group_repository_storage_moves.md)
- [群组 Wiki API](../../../api/group_wikis.md)
- [Wiki 键盘快捷键](../../shortcuts.md#wiki-pages)