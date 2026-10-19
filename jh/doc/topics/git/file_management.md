---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 常用命令和工作流。
title: 文件管理
---

Git 提供文件管理功能，帮助您跟踪变更、与他人协作，并高效管理大型文件。

<a id="file-history"></a>

## 文件历史

使用 `git log` 查看文件的完整历史，了解它随时间发生的变化。文件历史会向您显示：

- 每次变更的作者。
- 每次修改的日期和时间。
- 每次提交中所做的具体变更。

例如，要查看 `gitlab` 代码仓库根目录下 `CONTRIBUTING.md` 文件的 `history` 信息，请运行：

```shell
git log CONTRIBUTING.md
```

输出示例：

```shell
commit b350bf041666964c27834885e4590d90ad0bfe90
Author: Nick Malcolm <nmalcolm@gitlab.com>
Date:   Fri Dec 8 13:43:07 2023 +1300

    Update security contact and vulnerability disclosure info

commit 8e4c7f26317ff4689610bf9d031b4931aef54086
Author: Brett Walker <bwalker@gitlab.com>
Date:   Fri Oct 20 17:53:25 2023 +0000

    Fix link to Code of Conduct

    and condense some of the verbiage
```

<a id="check-previous-changes-to-a-file"></a>

## 检查文件的先前变更

使用 `git blame` 查看谁对文件做了最后一次变更以及变更时间。这有助于了解文件内容的背景、解决冲突，并确定某项具体变更的责任人。

如果您想查找本地目录中 `README.md` 文件的 `blame` 信息：

1. 打开终端或命令提示符。
1. 进入您的 Git 代码仓库。
1. 运行以下命令：

   ```shell
   git blame README.md
   ```

1. 要浏览结果页面，请按 <kbd>Space</kbd>。
1. 要退出结果，请按 <kbd>Q</kbd>。

此输出会显示文件内容，并附有标注，显示每一行的提交 SHA、作者和日期。例如：

```shell
58233c4f1054c (Dan Rhodes           2022-05-13 07:02:20 +0000  1) ## Contributor License Agreement
b87768f435185 (Jamie Hurewitz       2017-10-31 18:09:23 +0000  2)
8e4c7f26317ff (Brett Walker         2023-10-20 17:53:25 +0000  3) Contributions to this repository are subject to the
58233c4f1054c (Dan Rhodes           2022-05-13 07:02:20 +0000  4)
```

<a id="git-lfs"></a>

## Git LFS

Git 大文件存储（LFS）是一个扩展，可帮助您管理 Git 代码仓库中的大型文件。它会在 Git 中用文本指针替换大型文件，并将文件内容存储在远程服务器上。

先决条件：

- 下载并安装适用于您操作系统的相应版本的 [Git LFS CLI 扩展](https://git-lfs.com)。
- [将您的项目配置为使用 Git LFS](lfs/_index.md)。
- 安装 Git LFS pre-push hook。为此，请在代码仓库的根目录中运行 `git lfs install`。

<a id="add-and-track-files"></a>

### 添加并跟踪文件

要将大型文件添加到您的 Git 代码仓库并使用 Git LFS 跟踪它：

1. 为某一类型的所有文件配置跟踪。将 `iso` 替换为您所需的文件类型：

   ```shell
   git lfs track "*.iso"
   ```

   此命令会创建一个 `.gitattributes` 文件，其中包含使用 Git LFS 处理所有
   ISO 文件的指令。以下行会添加到您的 `.gitattributes` 文件中：

   ```plaintext
   *.iso filter=lfs -text
   ```

1. 将该类型的文件 `.iso` 添加到您的代码仓库。
1. 跟踪 `.gitattributes` 文件和 `.iso` 文件的变更：

   ```shell
   git add .
   ```

1. 确保您已添加这两个文件：

   ```shell
   git status
   ```

   `.gitattributes` 文件必须包含在您的提交中。
   如果未包含，Git 不会使用 Git LFS 跟踪该 ISO 文件。

   > [!note]
   > 确保您正在更改的文件未列在 `.gitignore` 文件中。
   > 如果已列出，Git 会在本地提交该变更，但不会将其推送到您的上游代码仓库。
1. 将这两个文件提交到您本地的代码仓库副本：

   ```shell
   git commit -m "Add an ISO file and .gitattributes"
   ```

1. 将您的变更推送到上游。将 `main` 替换为您的分支名称：

   ```shell
   git push origin main
   ```

1. 创建一个合并请求。

> [!note]
> 当您将新的文件类型添加到 Git LFS 跟踪时，该类型的现有文件
> 不会转换为 Git LFS。只有在您开始跟踪之后添加的该类型文件才会添加到 Git LFS。使用 `git lfs migrate` 将现有文件转换为使用 Git LFS。

<a id="stop-tracking-a-file"></a>

### 停止跟踪文件

当您停止使用 Git LFS 跟踪某个文件时，该文件仍保留在磁盘上，因为它仍然是您代码仓库历史的一部分。

要停止使用 Git LFS 跟踪文件：

1. 运行 `git lfs untrack` 命令并提供该文件的路径：

   ```shell
   git lfs untrack doc/example.iso
   ```

1. 使用 `touch` 命令将其转换回标准文件：

   ```shell
   touch doc/example.iso
   ```

1. 跟踪该文件的变更：

   ```shell
   git add .
   ```

1. 提交并推送您的变更。
1. 创建一个合并请求并请求评审。
1. 将该请求合并到目标分支。

> [!note]
> 如果您删除了由 Git LFS 跟踪的对象，而未使用 `git lfs untrack` 停止跟踪它，
> 该对象会在 `git status` 中显示为 `modified`。

<a id="stop-tracking-all-files-of-a-single-type"></a>

### 停止跟踪单一类型的所有文件

要停止在 Git LFS 中跟踪某一类型的所有文件：

1. 运行 `git lfs untrack` 命令并提供要停止跟踪的文件类型：

   ```shell
   git lfs untrack "*.iso"
   ```

1. 使用 `touch` 命令将这些文件转换回标准文件：

   ```shell
   touch *.iso
   ```

1. 跟踪这些文件的变更：

   ```shell
   git add .
   ```

1. 提交并推送您的变更。
1. 创建一个合并请求并请求评审。
1. 将该请求合并到目标分支。

<a id="exclusive-file-locks"></a>

## 独占文件锁

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

独占文件锁有助于防止冲突，并确保一次只有一个人可以编辑文件。它适用于以下情况：

- 无法合并的二进制文件。例如设计文件和视频。
- 在编辑期间需要独占访问的文件。

独占文件锁适用于代码仓库中的所有分支。如果您只需要在默认分支上锁定文件，请改用[默认分支文件和目录锁](../../user/project/file_lock.md#default-branch-file-and-directory-locks)。

先决条件：

- 您必须已[安装 Git LFS](lfs/_index.md)。
- 您必须具有该项目的维护者角色。

<a id="configure-file-locks"></a>

### 配置文件锁

要为特定文件类型配置文件锁：

1. 使用带有 `--lockable` 选项的 `git lfs track` 命令。例如，要配置 PNG 文件：

   ```shell
   git lfs track "*.png" --lockable
   ```

   此命令会创建或更新您的 `.gitattributes` 文件，内容如下：

    ```plaintext
    *.png filter=lfs diff=lfs merge=lfs -text lockable
    ```

1. 将 `.gitattributes` 文件推送到远程代码仓库，以使更改生效。

> [!note]
> 文件类型注册为可锁定后，会自动标记为只读。

<a id="configure-file-locks-without-lfs"></a>

#### 不使用 LFS 配置文件锁

要在不使用 Git LFS 的情况下将文件类型注册为可锁定：

1. 手动编辑 `.gitattributes` 文件：

   ```shell
   *.pdf lockable
   ```

1. 将 `.gitattributes` 文件推送到远程代码仓库。

<a id="lock-and-unlock-files"></a>

### 锁定和解锁文件

要使用独占文件锁锁定或解锁文件：

1. 在您的代码仓库目录中打开终端窗口。
1. 运行以下命令之一：

   {{< tabs >}}

   {{< tab title="锁定文件" >}}

   ```shell
   git lfs lock path/to/file.png
   ```

   {{< /tab >}}

   {{< tab title="解锁文件" >}}

   ```shell
   git lfs unlock path/to/file.png
   ```

   {{< /tab >}}

   {{< tab title="通过 ID 解锁文件" >}}

   ```shell
   git lfs unlock --id=123
   ```

   {{< /tab >}}

   {{< tab title="强制解锁文件" >}}

   ```shell
   git lfs unlock --id=123 --force
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="view-locked-files"></a>

### 查看已锁定的文件

要查看已锁定的文件：

1. 在您的代码仓库中打开终端窗口。
1. 运行以下命令：

   ```shell
   git lfs locks
   ```

   输出会列出已锁定的文件、锁定这些文件的用户以及文件 ID。

在极狐GitLab UI 中：

- 代码仓库文件树会为 Git LFS 跟踪的文件显示 LFS 徽章。
- 独占锁定的文件会显示挂锁图标。

> [!note]
> 当您重命名独占锁定的文件时，锁会丢失。您必须再次锁定它才能保持锁定状态。

<a id="lock-and-edit-a-file"></a>

### 锁定并编辑文件

要锁定文件、编辑它，并可选地解锁它：

1. 锁定该文件：

   ```shell
   git lfs lock <file_path>
   ```

1. 编辑该文件。
1. 可选。完成后解锁该文件：

   ```shell
   git lfs unlock <file_path>
   ```
