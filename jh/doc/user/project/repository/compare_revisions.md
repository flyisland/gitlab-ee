---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Compare branches, tags, and commits to view the differences between revisions in a repository.
title: 比较修订版本
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 **比较修订版本** 来查看修订版本之间更改的提交和文件列表。

你可以比较：

- 一个分支与另一个分支。
- 一个标签与一个分支或标签。
- 一个提交与另一个提交或分支。

<a id="compare-methods"></a>

比较方法

极狐GitLab 提供了两种比较修订版本的方法：

- **仅来自源分支的传入更改**（默认）：显示在两个修订版本的最新公共提交之后，来自源分支的差异。此方法排除了在源分支创建后对目标分支所做的不相关更改。使用此方法可以仅查看源修订版本引入的更改。

  此方法使用 `git diff <from>...<to>` Git 命令。它从合并基础（公共祖先提交）比较到目标，而不是直接比较实际提交。

- **包含源分支创建后对目标分支的更改**：显示两个修订版本之间的所有差异，包括对源分支和目标分支所做的更改。使用此方法可以查看仓库历史中两个点之间的完整差异。

  此方法使用 `git diff <from> <to>` Git 命令。它直接比较实际提交，显示它们之间的所有更改。

<a id="compare-branches-tags-or-commits"></a>

比较分支、标签或提交

要比较修订版本：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **代码** > **比较修订版本**。
1. 选择 **源** 修订版本：

   - 要搜索分支，输入分支名称。精确匹配会优先显示。
   - 要搜索标签，输入标签名称。
   - 要搜索提交，输入提交 SHA。
   - 要使用操作符细化搜索：
     - `^` 匹配名称开头：`^feat` 匹配 `feat/user-authentication`。
     - `$` 匹配名称结尾：`widget$` 匹配 `feat/search-box-widget`。
     - `*` 使用通配符匹配：`branch*cache*` 匹配 `fix/branch-search-cache-expiration`。
     - 你可以组合操作符：`^chore/*migration$` 匹配 `chore/user-data-migration`。

1. 选择 **目标** 仓库和修订版本。
1. 在 **显示更改** 下方，选择 **仅来自源分支的传入更改**（默认）或 **包含源分支创建后对目标分支的更改**。
1. 选择 **比较**。
1. 可选。要交换 **源** 和 **目标**，选择 **交换修订版本** ({{< icon name="substitute" >}})。

比较页面会显示修订版本之间更改的提交和文件列表。

<a id="view-on-environment"></a>

在环境中查看

在比较修订版本时，你可以直接在部署环境中预览文件。

先决条件：

- 为你的项目配置了[路由映射](../../../ci/review_apps/_index.md#route-maps)。
- 你希望预览的文件包含在路由映射配置中。
- 一个可访问的环境。

要在部署环境中预览文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **代码** > **比较修订版本**。
1. 选择你要比较的 **源** 和 **目标** 分支或提交。
1. 在文件差异视图中，找到包含在路由映射配置中的文件。
1. 选择文件的 **更多操作** 菜单 ({{< icon name="ellipsis_v" >}})。
1. 选择 **在 [环境名称] 上查看**。

文件会在新标签页中打开，显示其在部署环境中的样子。

<a id="related-topics"></a>

相关主题

- [分支](branches/_index.md)
- [标签](tags/_index.md)
- [提交](commits/_index.md)
- [Git 命令](../../../topics/git/commands.md)