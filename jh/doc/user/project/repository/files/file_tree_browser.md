---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用文件树浏览器浏览代码仓库文件和目录。
title: 文件树浏览器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

文件树浏览器是一个抽屉，以可折叠的树形结构显示代码仓库中的文件和目录。您可以使用它浏览代码仓库，而无需在冗长的文件列表中滚动。

文件树浏览器可帮助您：

- 浏览嵌套的目录结构。
- 查看代码仓库层级。
- 在文件之间切换，同时保持对目录结构的了解。

<a id="show-or-hide-the-file-tree-browser"></a>

## 显示或隐藏文件树浏览器

要显示或隐藏文件树浏览器：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到代码仓库文件，路径为 `/<project>/-/tree/<branch>`。
1. 在左上角，选择文件树浏览器图标（{{< icon name="file-tree" >}}）。

<a id="navigate-files-and-directories"></a>

## 浏览文件和目录

文件树浏览器显示代码仓库的结构，其中的文件和目录可以展开和折叠。

要在文件树浏览器中浏览：

1. 在左上角，选择文件树浏览器图标（{{< icon name="file-tree" >}}）。
1. 要展开目录，请选择目录名称旁边的 {{< icon name="chevron-right" >}}。
1. 要查看文件，请选择文件名。

当您直接导航到嵌套文件时，文件树浏览器会自动展开父目录并高亮显示当前文件。

<a id="search-files"></a>

## 搜索文件

使用搜索面板按名称查找代码仓库中的文件。

要搜索文件：

1. 在左上角，选择文件树浏览器图标（{{< icon name="file-tree" >}}）。
1. 要打开搜索面板，请选择**搜索文件**。
1. 输入您要查找的文件名的一部分。
   结果列表会显示匹配的文件及其父目录。
1. 选择您要前往的文件。

如果没有文件与您的搜索匹配，搜索会显示**未找到结果**。

<a id="keyboard-shortcuts"></a>

## 键盘快捷键

文件树浏览器支持以下键盘快捷键：

| 快捷键                      | 操作 |
|-------------------------------|--------|
| <kbd>Shift</kbd>+<kbd>F</kbd> | 显示或隐藏文件树浏览器。 |
| <kbd>F</kbd>                  | 打开搜索面板。 |

有关可用键盘快捷键的完整列表，请参阅[极狐GitLab 键盘快捷键](../../../shortcuts.md)。

<a id="tree-navigation"></a>

### 树形导航

文件树浏览器实现了 [W3C ARIA treeview 模式](https://www.w3.org/WAI/ARIA/apg/patterns/treeview/)，
用于键盘导航：

| 按键                                                  | 功能 |
|------------------------------------------------------|----------|
| <kbd>Enter</kbd> 或 <kbd>Space</kbd>                 | 选择当前聚焦的文件或目录 |
| <kbd>Down arrow</kbd>                                | 将焦点移到下一个文件或目录，不打开或关闭目录。如果焦点位于最后一项，则不执行任何操作。 |
| <kbd>Up arrow</kbd>                                  | 将焦点移到上一个文件或目录，不打开或关闭目录。如果焦点位于第一项，则不执行任何操作。 |
| <kbd>Right arrow</kbd>                               | 当焦点位于已关闭的目录时，打开该目录。当焦点位于已打开的目录时，将焦点移到其中的第一项。如果焦点位于文件，则不执行任何操作。 |
| <kbd>Left arrow</kbd>                                | 当焦点位于已打开的目录时，关闭该目录。当焦点位于文件或嵌套项时，将焦点移到其父目录。如果焦点位于已关闭的根目录，则不执行任何操作。 |
| <kbd>Home</kbd> <sup>1</sup>                                     | 将焦点移到第一个文件或目录，不打开或关闭目录。 |
| <kbd>End</kbd> <sup>1</sup>                                       | 将焦点移到最后一个文件或目录，不展开已关闭的目录。 |
| <kbd>a</kbd>-<kbd>z</kbd>, <kbd>A</kbd>-<kbd>Z</kbd> | 将焦点移到名称以所输入字符开头的下一个文件或目录。如果未找到匹配项，搜索会回绕到第一项。忽略已关闭目录中的项。 |
| <kbd>*</kbd>（星号）                              | 展开与聚焦项处于同一层级的所有已关闭目录。焦点不会移动。 |

**脚注**：

1. <kbd>Home</kbd> 和 <kbd>End</kbd> 键可能并非在所有键盘上都可用。
