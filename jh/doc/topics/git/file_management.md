---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Common commands and workflows.
title: 文件管理
---

Git 提供了文件管理功能，可帮助你跟踪更改、与他人协作以及高效管理大文件。

<a id="file-history"></a>

## 文件历史

使用 `git log` 查看文件的完整历史记录，并了解其随时间的变化。
文件历史记录会显示：

- 每次更改的作者。
- 每次修改的日期和时间。
- 每个提交中所做的具体更改。

例如，要查看 `gitlab` 仓库根目录下 `CONTRIBUTING.md` 文件的 `history` 信息，请运行：

```shell
git log CONTRIBUTING.md
```

示例输出：

```shell
commit b350bf041666964c27834885e4590d90ad0bfe90
Author: Nick Malcolm <nmalcolm@gitlab.com>
Date:   Fri Dec 8 13:43:07 2023 +1300

    更新了安全联系人和漏洞披露信息

commit 8e4c7f26317ff4689610bf9d031b4931aef54086
Author: Brett Walker <bwalker@gitlab.com>
Date:   Fri Oct 20 17:53:25 2023 +0000

    修复了行为准则的链接

    并精简了一些措辞
```

<a id="check-previous-changes-to-a-file"></a>

## 检查文件的先前更改

使用 `git blame` 查看谁最后更改了文件以及更改时间。
这有助于理解文件内容的上下文、解决冲突以及确定负责特定更改的人员。

如果你想查找本地目录中 `README.md` 文件的 `blame` 信息：

1. 打开终端或命令提示符。
1. 进入你的 Git 仓库。
1. 运行以下命令：

   ```shell
   git blame README.md
   ```

1. 要浏览结果页面，请按 <kbd>Space</kbd>。
1. 要退出结果，请按 <kbd>Q</kbd>。

此输出会显示文件内容，并附有注解，显示每行的提交 SHA、作者和日期。例如：

```shell
58233c4f1054c (Dan Rhodes           2022-05-13 07:02:20 +0000  1) ## 贡献者许可协议
b87768f435185 (Jamie Hurewitz       2017-10-31 18:09:23 +0000  2)
8e4c7f26317ff (Brett Walker         2023-10-20 17:53:25 +0000  3) 对此仓库的贡献须遵守以下
58233c4f1054c (Dan Rhodes           2022-05-13 07:02:20 +0000  4)
```

<a id="git-lfs"></a>

## Git LFS

Git Large File Storage (LFS) 是一个扩展，可帮助你管理 Git 仓库中的大文件。
它用 Git 中的文本指针替换大文件，并将文件内容存储在远程服务器上。

先决条件：

- 为你的操作系统下载并安装合适版本的 [CLI extension for Git LFS](https://git-lfs.com)。
- [Configure your project to use Git LFS](lfs/_index.md)。
- 安装 Git LFS pre-push hook。为此，请在仓库的根目录中运行 `git lfs install`。

<a id="add-and-track-files"></a>

### 添加和跟踪文件

要将大文件添加到 Git 仓库并使用 Git LFS 进行跟踪：

1. 为特定类型的所有文件配置跟踪。将 `iso` 替换为你想要的文件类型：

   ```shell
   git lfs track "*.iso"
   ```

   此命令会创建一个 `.gitattributes` 文件，其中包含使用 Git LFS 处理所有
   ISO 文件的指令。以下行会被添加到你的 `.gitattributes` 文件中：

   ```plaintext
   *.iso filter=lfs -text
   ```

1. 将该类型的文件，例如 `.iso`，添加到你的仓库中。
1. 跟踪 `.gitattributes` 文件和 `.iso` 文件的更改：

   ```shell
   git add .
   ```

1. 确保你已添加这两个文件：

   ```shell
   git status
   ```

   你的提交中必须包含 `.gitattributes` 文件。
   如果未包含，Git 就不会使用 Git LFS 跟踪 ISO 文件。

   > [!note]
   > 确保你正在更改的文件未被列在 `.gitignore` 文件中。
   > 如果它们在 `.gitignore` 文件中，Git 会在本地提交更改，但不会将其推送到你的上游仓库。
1. 将两个文件提交到你的仓库本地副本中：

   ```shell
   git commit -m "添加一个 ISO 文件和 .gitattributes"
   ```

1. 将你的更改推送到上游。将 `main` 替换为你的分支名称：

   ```shell
   git push origin main
   ```

1. 创建一个合并请求。

> [!note]
> 当你将新文件类型添加到 Git LFS 跟踪时，此类型的现有文件
> 不会转换为 Git LFS。只有在你开始跟踪后添加的此类型文件才会被添加到 Git LFS。使用 `git lfs migrate` 将现有文件转换为使用 Git LFS。

<a id="stop-tracking-a-file"></a>

### 停止跟踪文件

当你停止使用 Git LFS 跟踪某个文件时，该文件会保留在磁盘上，因为它仍然是
你仓库历史记录的一部分。

要停止使用 Git LFS 跟踪文件：

1. 运行 `git lfs untrack` 命令并提供文件路径：

   ```shell
   git lfs untrack doc/example.iso
   ```

1. 使用 `touch` 命令将其转换回标准文件：

   ```shell
   touch doc/example.iso
   ```

1. 跟踪文件的更改：

   ```shell
   git add .
   ```

1. 提交并推送你的更改。
1. 创建一个合并请求并请求审核。
1. 将请求合并到目标分支。

> [!note]
> 如果你删除了一个由 Git LFS 跟踪的对象，而没有使用 `git lfs untrack` 对其进行跟踪，
> 则该对象在 `git status` 中会显示为 `modified`。

<a id="stop-tracking-all-files-of-a-single-type"></a>

### 停止跟踪单一类型的所有文件

要停止在 Git LFS 中跟踪特定类型的所有文件：

1. 运行 `git lfs untrack` 命令并提供要停止跟踪的文件类型：

   ```shell
   git lfs untrack "*.iso"
   ```

1. 使用 `touch` 命令将文件转换回标准文件：

   ```shell
   touch *.iso
   ```

1. 跟踪文件的更改：

   ```shell
   git add .
   ```

1. 提交并推送你的更改。
1. 创建一个合并请求并请求审核。
1. 将请求合并到目标分支。

<a id="exclusive-file-locks"></a>

## 独占文件锁

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

独占文件锁有助于防止冲突，并确保一次只有一个人可以编辑文件。
它适用于：

- 无法合并的二进制文件。例如，设计文件和视频。
- 编辑时需要独占访问的文件。

独占文件锁适用于仓库中的所有分支。如果你只需要锁定默认分支上的文件，请改用 [default branch file and directory locks](../../user/project/file_lock.md#default-branch-file-and-directory-locks)。

先决条件：

- 你必须已 [Git LFS installed](lfs/_index.md)。
- 你必须具有项目的维护者角色。

<a id="configure-file-locks"></a>

### 配置文件锁

要为特定文件类型配置文件锁：

1. 使用带有 `--lockable` 选项的 `git lfs track` 命令。例如，要配置 PNG 文件：

   ```shell
   git lfs track "*.png" --lockable
   ```

   此命令会创建或更新你的 `.gitattributes` 文件，内容如下：

    ```plaintext
    *.png filter=lfs diff=lfs merge=lfs -text lockable
    ```

1. 将 `.gitattributes` 文件推送到远程仓库以使更改生效。

> [!note]
> 文件类型被注册为可锁定后，它会自动被标记为只读。

<a id="configure-file-locks-without-lfs"></a>

#### 在不使用 LFS 的情况下配置文件锁

要在不使用 Git LFS 的情况下将文件类型注册为可锁定：

1. 手动编辑 `.gitattributes` 文件：

   ```shell
   *.pdf lockable
   ```

1. 将 `.gitattributes` 文件推送到远程仓库。

<a id="lock-and-unlock-files"></a>

### 锁定和解锁文件

要使用独占文件锁锁定或解锁文件：

1. 在仓库目录中打开一个终端窗口。
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

### 查看锁定的文件

要查看锁定的文件：

1. 在仓库中打开一个终端窗口。
1. 运行以下命令：

   ```shell
   git lfs locks
   ```

   输出会列出锁定的文件、锁定它们的用户以及文件 ID。

在 极狐GitLab UI 中：

- 仓库文件树会为 Git LFS 跟踪的文件显示一个 LFS 徽章。
- 独占锁定的文件会显示一个挂锁图标。

> [!note]
> 当你重命名一个独占锁定的文件时，锁会丢失。你必须再次锁定它才能保持其锁定状态。

<a id="lock-and-edit-a-file"></a>

### 锁定并编辑文件

要锁定文件、编辑它，并可以选择解锁它：

1. 锁定文件：

   ```shell
   git lfs lock <file_path>
   ```

1. 编辑文件。
1. 可选。完成后解锁文件：

   ```shell
   git lfs unlock <file_path>
   ```

<a id="related-topics"></a>

## 相关主题

- [File management with the GitLab UI](../../user/project/repository/files/_index.md)
- [Git Large File Storage (LFS) documentation](lfs/_index.md)
- [File locking](../../user/project/file_lock.md)