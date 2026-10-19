---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 关于 Git 文件追溯的文档。
title: Git 文件追溯
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Git blame](https://git-scm.com/docs/git-blame) 提供文件中每一行的更多信息，包括最后修改时间、作者和提交哈希。

<a id="view-blame-for-a-file"></a>

## 查看文件的追溯信息

先决条件：

- 文件必须包含可读的文本内容。极狐GitLab UI 会为文本文件（如 `.rb`、`.js`、`.md`、`.txt`、`.yml` 及类似格式）显示 `git blame` 结果。不支持二进制文件，例如图片和 PDF。

要查看文件的追溯信息：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 选择您要查看的文件。
1. 执行以下任一操作：
   - 要更改当前文件的视图，请在文件标题栏中选择**追溯**。
   - 要打开完整的追溯页面，请在右上角选择**追溯**。
1. 转到您要查看的行。

当您选择**追溯**时，会显示以下信息：

![Git blame 输出](img/file_blame_output_v18_11.png "追溯按钮输出")

要查看提交的精确日期和时间，请将鼠标悬停在日期上。要显示提交时间的颜色图例，请参阅[显示时间指示器图例](#show-age-indicator-legend)。

<a id="blame-previous-commit"></a>

### 追溯此变更之前的提交

要查看特定行的更早修订版本：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 选择您要查看的文件。
1. 在右上角选择**追溯**，然后转到您要查看的行。
1. 选择**查看此变更之前的追溯**（{{< icon name="doc-versions" >}}），
   直到找到您感兴趣的变更。

<a id="ignore-specific-revisions"></a>

### 忽略特定修订版本

要将 Git blame 配置为忽略特定修订版本：

1. 在代码仓库的根目录中，创建一个 `.git-blame-ignore-revs` 文件。
1. 添加您要忽略的提交哈希，每行一个。
   例如：

   ```plaintext
   a24cb33c0e1390b0719e9d9a4a4fc0e4a3a069cc
   676c1c7e8b9e2c9c93e4d5266c6f3a50ad602a4c
   ```

1. 在追溯视图中打开一个文件。
1. 选择**追溯偏好设置**（{{< icon name="preferences" >}}）。
1. 选中**忽略特定修订版本**复选框。

追溯视图会刷新并跳过 `.git-blame-ignore-revs` 文件中指定的修订版本，改为显示之前有意义的变更。

<a id="show-age-indicator-legend"></a>

### 显示时间指示器图例

在内联追溯视图中，您可以显示或隐藏时间指示器图例。该图例显示从**较新**到**较旧**的颜色刻度，帮助您解读每个提交的时间。

要显示或隐藏时间指示器图例：

1. 在追溯视图中打开一个文件。
1. 选择**追溯偏好设置**（{{< icon name="preferences" >}}）。
1. 选中或清除**显示时间指示器图例**复选框。

<a id="resize-the-blame-column"></a>

### 调整追溯列的宽度

在内联追溯视图中，拖动追溯列与文件内容之间的分隔线即可调整追溯列的宽度。您的浏览器会保存所选宽度，并在您下次在追溯视图中查看文件时使用该宽度。

追溯列的宽度最小为 250 像素，最大为 600 像素。在较小的屏幕上，该列使用最小宽度，且无法调整大小。

要调整追溯列的宽度：

1. 在追溯视图中打开一个文件。
1. 将鼠标悬停在追溯列与文件内容之间的分隔线上。
1. 当出现调整大小光标时，向左或向右拖动分隔线以调整宽度。
