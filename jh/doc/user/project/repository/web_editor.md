---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Web Editor 直接在极狐GitLab UI 中创建、上传和编辑文本文件。
title: Web Editor
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Web Editor 是一款基于浏览器的工具，无需本地设置即可对极狐GitLab 代码仓库进行更改。您可以：

- 编辑单个文件，并在提交前预览更改。
- 创建新文件和目录。
- 上传和替换文件。
- 创建分支和标签以进行版本控制。
- [锁定文件](../file_lock.md#lock-a-file-or-directory)以防止并发编辑冲突。
- 无需在本地设置 Git 即可为项目做贡献。

极狐GitLab 使用您的[主电子邮件地址](../../profile/_index.md#change-the-email-displayed-on-your-commits)
作为 Web Editor 提交的作者信息。

如需更改多个文件，请使用 [Web IDE](../web_ide/_index.md)。

> [!note]
> 要管理[受保护分支](branches/protected.md)中的文件，
> 您必须拥有相应的[权限](../../permissions.md)。

<a id="manage-files"></a>

## 管理文件

您可以使用 Web Editor 直接从极狐GitLab UI 创建、编辑、上传和删除文件。

<a id="create-a-file"></a>

### 创建文件

要在 Web Editor 中创建文本文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您要创建新文件的目录。
1. 在目录名称旁边，选择加号图标 ({{< icon name="plus" >}}) > **新建文件**。
1. 在分支名称旁边，输入文件名和扩展名。例如，`my_file.md`。
1. 为文件添加内容。
1. 选择**提交更改**。
1. 在**提交信息**字段中，输入提交原因。
1. 选择以下选项之一：

   - 要在预填的目标分支中创建文件，请选择**提交更改**。
   - 要在新分支中创建文件并提交更改：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保清除**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

   - 要在新分支中创建文件、提交更改并创建合并请求：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保选中**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

要打开预填内容的新文件编辑器，请在 URL 中使用 `content` 查询参数。例如：

```plaintext
https://gitlab.com/<your-namespace>/<your-project>/-/new/main?content=your+content+here
```

<a id="from-a-template"></a>

#### 从模板创建

要在 Web Editor 中从模板创建文本文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您要创建新文件的目录。
1. 在目录名称旁边，选择加号图标 ({{< icon name="plus" >}}) > **新建文件**。
1. 在**文件名**中，输入极狐GitLab 提供模板的名称：
   - `.gitignore`
   - `.gitlab-ci.yml`
   - `LICENSE`
   - `Dockerfile`
1. 从**应用模板**下拉列表中，选择一个模板。
1. 可选。根据需要更新模板。
1. 从[创建文件](#create-a-file)流程的第 6 步继续。

<a id="edit-a-file"></a>

### 编辑文件

要在 Web Editor 中编辑文本文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您要编辑的文件。
1. 选择**编辑** > **编辑单个文件**。
1. 进行更改。
1. 选择**提交更改**。
1. 在**提交信息**字段中，输入提交原因。
1. 选择以下选项之一：

   - 要从预填的目标分支编辑文件，请选择**提交更改**。
   - 要从新分支编辑文件并提交更改：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保清除**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

   - 要从新分支编辑文件、提交更改并创建合并请求：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保选中**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。
     1. 填写字段并选择**创建合并请求**。

> [!note]
> 如果您在编辑期间，有人编辑并提交了对同一文件的更改，
> 您将无法提交您的更改。此时会显示以下错误消息：
> `Someone edited the file the same time you did. Please check out the file and
> make sure your change will not unintentionally remove theirs.`

<a id="link-to-specific-lines"></a>

#### 链接到特定行

要链接到 Web Editor 中的单行或多行，请在 URL 的文件名部分添加哈希信息。例如：

- `MY_FILE.js#L3` 会高亮显示 `MY_FILE.js`中的第 3 行。
- `MY_FILE.js#L3-10` 会高亮显示 `MY_FILE.js`中的第 3 至 10 行。

编辑文件时，您也可以通过选择行号来链接到单行。

<a id="edit-files-in-a-forked-merge-request"></a>

#### 在 forked 的合并请求中编辑文件

先决条件：

- 您必须处理来自 fork 的合并请求。
- 必须启用[允许上游成员提交](../merge_requests/allow_collaboration.md#allow-commits-from-upstream-members)。

如果您正在处理来自 forked 项目的合并请求，您可以编辑文件并提交更改。为此：

1. 转到该合并请求。
1. 转到您要编辑的文件。
1. 选择**编辑** > **编辑单个文件**。
1. 选择**提交更改**。
1. 在**提交信息**中，输入提交原因。
   此时会提供以下信息：`Your changes can be committed to <branch-name> because a merge request is open.`
1. 选择**提交更改**。

<a id="preview-a-file"></a>

### 预览文件

在 Web Editor 中创建或编辑文件时，您可以在提交前预览内容。

要预览内容，请选择**预览**标签页。您看到的内容取决于文件扩展名：

- Markdown 文件会在内容旁边显示实时预览，并随您的输入而更新。
- 其他标记文件（如 AsciiDoc、Org 和 reStructuredText）会显示渲染后的标记。
- 所有其他文件会显示您更改的差异。

要返回内容，请选择**编写**标签页。

当您编辑的不是标记文件时，该标签页会标记为**预览更改**。

<a id="upload-a-file"></a>

### 上传文件

要在 Web Editor 中上传文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您要上传文件的目录。
1. 在目录名称旁边，选择加号图标 ({{< icon name="plus" >}}) > **上传文件**。
1. 拖放或上传您要添加的文件。
1. 在**提交信息**字段中，输入提交原因。
1. 选择以下选项之一：

   - 要从预填的目标分支上传文件，请选择**提交更改**。
   - 要从新分支上传文件并提交更改：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保清除**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

   - 要从新分支上传文件、提交更改并创建合并请求：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保选中**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。
     1. 填写字段并选择**创建合并请求**。

<a id="delete-a-file"></a>

### 删除文件

要在 Web Editor 中删除文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您要删除的文件。
1. 选择**删除**。
1. 在**提交信息**中，输入提交原因。
1. 在以下选项中选择：

   - 要从预填的目标分支删除文件，请选择**提交更改**。
   - 要从新分支删除文件并提交更改：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保清除**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

   - 要从新分支删除文件、提交更改并创建合并请求：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保选中**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

> [!note]
> 如果您在编辑期间，有人编辑并提交了对同一文件的更改，
> 您将无法提交您的更改。此时会显示以下错误消息：
> `Someone edited the file the same time you did. Please check out the file and
> make sure your change will not unintentionally remove theirs.`

<a id="replace-a-file"></a>

### 替换文件

要在 Web Editor 中替换文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您要替换的文件。
1. 选择**替换**。
1. 拖放或上传您要上传并替换现有文件的文件。
1. 在**提交信息**中，输入提交原因。
1. 在以下选项中选择：

   - 要从预填的目标分支替换文件，请选择**提交更改**。
   - 要从新分支替换文件并提交更改：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保清除**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

   - 要从新分支替换文件、提交更改并创建合并请求：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保选中**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

<a id="cancel-file-changes"></a>

### 取消文件更改

要在 Web Editor 中取消更改、编辑、上传或删除文件：

1. 选择**取消**。
1. 选择以下之一：

   - 确认要取消更改：选择**确定**。
   - 不取消更改：选择**取消**。

<a id="file-operations-from-the-actions-menu"></a>

### 从操作菜单执行文件操作

**操作** ({{< icon name="ellipsis_v" >}}) 菜单将文件操作整合到下拉列表中。通过此菜单，您可以：

- 编辑文件。
- 上传文件。
- 删除文件。
- 替换文件。

要完成这些操作：

1. 在极狐GitLab 中打开该文件。
1. 在右上角，文件名旁边，选择**操作** ({{< icon name="ellipsis_v" >}})。
1. 选择您想要的操作。

<a id="create-a-directory"></a>

## 创建目录

要在 Web Editor 中创建目录：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到您要创建新目录的目录。
1. 在目录名称旁边，选择加号图标 ({{< icon name="plus" >}}) > **新建目录**。
1. 在**目录名称**字段中，输入您的目录名称。
1. 在**提交信息**中，输入提交原因。
1. 在以下选项中选择：

   - 要从预填的目标分支创建目录，请选择**提交更改**。
   - 要从新分支创建目录并提交更改：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保清除**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

   - 要从新分支创建目录、提交更改并创建合并请求：

     1. 选择**提交到新分支**。
     1. 输入分支名称。
     1. 确保选中**为此更改创建合并请求**复选框。
     1. 选择**提交更改**。

<a id="create-a-branch"></a>

## 创建分支

要在 Web Editor 中创建[分支](branches/_index.md)：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在代码仓库名称旁边，选择加号图标 ({{< icon name="plus" >}}) > **新建分支**。
1. 填写字段。
1. 选择**创建分支**。

<a id="create-a-tag"></a>

## 创建标签

您可以创建[标签](tags/_index.md)来标记里程碑，例如生产版本和候选版本。要在 Web Editor 中创建标签：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在代码仓库名称旁边，选择加号图标 ({{< icon name="plus" >}}) > **新建标签**。
1. 填写字段。
1. 选择**创建标签**。

<a id="editor-accessibility-options"></a>

## 编辑器无障碍选项

Web 编辑器基于 [Monaco Editor](https://github.com/microsoft/monaco-editor)，
它提供了多项[无障碍功能](https://github.com/microsoft/monaco-editor/wiki/Monaco-Editor-Accessibility-Guide)，
包括：

| 功能                          | Windows 或 Linux 快捷键      | macOS 快捷键                                    | 详情 |
|----------------------------------|-----------------------------------|------------------------------------------------------|---------|
| 键盘导航命令列表 | <kbd>F1</kbd>                     | <kbd>F1</kbd>                                        | 一份[命令列表](https://github.com/microsoft/monaco-editor/wiki/Monaco-Editor-Accessibility-Guide#keyboard-navigation)，可让编辑器更易于在不用鼠标的情况下使用。 |
| Tab 捕获                     | <kbd>Control</kbd>+<kbd>m</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>m</kbd> | 启用 [Tab 捕获](https://github.com/microsoft/monaco-editor/wiki/Monaco-Editor-Accessibility-Guide#tab-trapping)后，将转到页面上下一个可聚焦元素，而不是插入制表符。 |
