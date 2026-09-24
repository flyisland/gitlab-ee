---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation on Git file blame.
title: Git 文件追溯
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Git blame](https://git-scm.com/docs/git-blame) 提供关于文件中每一行的更多信息，包括最后修改时间、作者和提交哈希。

<a id="view-blame-for-a-file"></a>

## 查看文件追溯

{{< history >}}

- 直接在文件视图中查看追溯功能于极狐GitLab 16.7 引入，通过一个名为 `inline_blame` 的功能标志，默认禁用。

{{< /history >}}

前提条件：

- 文件必须包含可读的文本内容。极狐GitLab 界面仅为 `.rb`、`.js`、`.md`、`.txt`、`.yml` 等类似格式的文本文件显示 `git blame` 结果。二进制文件（如图片和 PDF）不支持。

要查看文件的追溯：

1. 在顶部导航栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 在左侧边栏中，选择 **代码** > **代码仓**。
1. 选择你要查看的文件。
1. 任选其一：
   - 要更改当前文件的视图，在文件头中选择 **追溯**。
   - 要打开完整的追溯页面，选择右上角的 **追溯**。
1. 前往你想查看的行。

当你选择 **追溯** 后，会显示以下信息：

![Git 追溯输出](img/file_blame_output_v18_11.png "追溯按钮输出")

要查看提交的精确日期和时间，将鼠标悬停在日期上。
要显示提交年龄的颜色图例，请参见[显示年龄指示器图例](#show-age-indicator-legend)。

<a id="blame-previous-commit"></a>

### 追溯前一次提交

要查看特定行的更早版本：

1. 在顶部导航栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 在左侧边栏中，选择 **代码** > **代码仓**。
1. 选择你要查看的文件。
1. 选择右上角的 **追溯**，然后前往你想查看的行。
1. 选择 **查看此更改之前的追溯**（{{< icon name="doc-versions" >}}），直到找到你感兴趣的更改。

<a id="ignore-specific-revisions"></a>

### 忽略特定修订

{{< history >}}

- 于极狐GitLab 17.10 引入，通过一个名为 `blame_ignore_revs` 的功能标志，默认禁用。
- 于极狐GitLab 17.10 在 JihuLab.com 和私有化部署上启用。
- 于极狐GitLab 17.11 GA，功能标志 `blame_ignore_revs` 已移除。

{{< /history >}}

要配置 Git 追溯忽略特定修订：

1. 在你的仓库根目录中创建一个 `.git-blame-ignore-revs` 文件。
1. 每行添加你想要忽略的提交哈希。
   例如：

   ```plaintext
   a24cb33c0e1390b0719e9d9a4a4fc0e4a3a069cc
   676c1c7e8b9e2c9c93e4d5266c6f3a50ad602a4c
   ```

1. 在追溯视图中打开一个文件。
1. 选择 **追溯偏好**（{{< icon name="preferences" >}}）。
1. 勾选 **忽略特定修订** 复选框。

追溯视图将刷新并跳过 `.git-blame-ignore-revs` 文件中指定的修订，转而显示之前的有意义更改。

<a id="show-age-indicator-legend"></a>

### 显示年龄指示器图例

{{< history >}}

- 于极狐GitLab 18.11 引入。

{{< /history >}}

在内联追溯视图中，你可以显示或隐藏年龄指示器图例。
图例中会显示从 **较新** 到 **较旧** 的颜色标尺，帮助你理解每次提交的年龄。

要显示或隐藏年龄指示器图例：

1. 在追溯视图中打开一个文件。
1. 选择 **追溯偏好**（{{< icon name="preferences" >}}）。
1. 勾选或取消勾选 **显示年龄指示器图例** 复选框。