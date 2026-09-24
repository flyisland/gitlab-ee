---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the file tree browser to navigate repository files and directories.
title: 文件树浏览器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 18.0 中引入，以 [功能标志](../../../../administration/feature_flags/_index.md) 的形式命名为 `repository_file_tree_browser`。默认禁用。
- 在 GitLab 18.9 中于 JihuLab.com 和私有化部署上启用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。

文件树浏览器是一个抽屉式面板，以可折叠的树状结构显示您的仓库文件和目录。使用它来浏览您的仓库，无需滚动长长的文件列表。

文件树浏览器可帮助您：

- 导航嵌套的目录结构。
- 查看仓库的层次结构。
- 在保持目录结构上下文的同时切换文件。

<a id="show-or-hide-the-file-tree-browser"></a>

## 显示或隐藏文件树浏览器

要显示或隐藏文件树浏览器：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 进入您的仓库文件，路径为 `/<project>/-/tree/<branch>`。
1. 在左上角，选择文件树浏览器图标 ({{< icon name="file-tree" >}})。

您也可以按 <kbd>Shift</kbd>+<kbd>F</kbd> 来切换文件树浏览器。

<a id="navigate-files-and-directories"></a>

## 浏览文件和目录

文件树浏览器以可展开和折叠的文件和目录形式显示您的仓库结构。

要在文件树浏览器中导航：

1. 打开文件树浏览器。可通过以下任一方式：

   - 在左上角，选择文件树浏览器图标 ({{< icon name="file-tree" >}})。
   - 按 <kbd>Shift</kbd>+<kbd>F</kbd>。

1. 要展开目录，选择目录名称旁边的 {{< icon name="chevron-right" >}}。
1. 要查看文件，选择文件名。

当您直接导航到嵌套文件时，文件树浏览器会自动展开父目录并高亮当前文件。

<a id="search-files"></a>

## 搜索文件

使用搜索面板按名称查找仓库中的文件。

要搜索文件：

1. 打开文件树浏览器。可通过以下任一方式：

   - 在左上角，选择文件树浏览器图标 ({{< icon name="file-tree" >}})。
   - 按 <kbd>Shift</kbd>+<kbd>F</kbd>。

1. 要打开搜索面板，选择 **搜索文件** 或按 <kbd>F</kbd>。
1. 输入您要查找的部分文件名。
   结果列表显示匹配的文件及其父目录。
1. 选择或使用箭头键并按 <kbd>Enter</kbd> 导航到文件。

如果没有文件匹配您的搜索，搜索面板会显示 **未找到结果**。

<a id="keyboard-shortcuts"></a>

## 键盘快捷键

文件树浏览器支持以下键盘快捷键：

| 快捷键                       | 操作 |
|-----------------------------|------|
| <kbd>Shift</kbd>+<kbd>F</kbd> | 显示或隐藏文件树浏览器。 |
| <kbd>F</kbd>                  | 打开搜索面板。 |

有关可用键盘快捷键的完整列表，请参见 [极狐GitLab 键盘快捷键](../../../shortcuts.md)。

<a id="tree-navigation"></a>

### 树导航

文件树浏览器实现了 [W3C ARIA treeview 模式](https://www.w3.org/WAI/ARIA/apg/patterns/treeview/) 以支持键盘导航：

| 按键                                                   | 功能 |
|--------------------------------------------------------|------|
| <kbd>Enter</kbd> 或 <kbd>Space</kbd>                  | 选中获得焦点的文件或目录 |
| <kbd>Down arrow</kbd>                                 | 将焦点移至下一个文件或目录，而不打开或关闭目录。如果焦点在最后一项上，则无效。 |
| <kbd>Up arrow</kbd>                                   | 将焦点移至上一个文件或目录，而不打开或关闭目录。如果焦点在第一项上，则无效。 |
| <kbd>Right arrow</kbd>                                | 当焦点位于已关闭的目录上时，打开该目录。当焦点位于已打开的目录上时，将焦点移至其内部的第一个项目。如果焦点在文件上，则无效。 |
| <kbd>Left arrow</kbd>                                 | 当焦点位于已打开的目录上时，关闭该目录。当焦点在文件或嵌套项目上时，将焦点移至其父目录。如果焦点位于已关闭的根目录上，则无效。 |
| <kbd>Home</kbd> <sup>1</sup>                           | 将焦点移至第一个文件或目录，而不打开或关闭目录。 |
| <kbd>End</kbd> <sup>1</sup>                            | 将焦点移至最后一个文件或目录，而不展开已关闭的目录。 |
| <kbd>a</kbd>-<kbd>z</kbd>, <kbd>A</kbd>-<kbd>Z</kbd>  | 将焦点移至下一个名称以键入字符开头的文件或目录。如果没有找到匹配项，则搜索会回到第一项。忽略已关闭目录中的项目。 |
| <kbd>*</kbd> (星号)                                    | 展开与获得焦点的项目同级的所有已关闭目录。焦点不会移动。 |

**脚注**：

1. <kbd>Home</kbd> 和 <kbd>End</kbd> 键可能并非在所有键盘上都可用。