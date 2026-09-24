---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: A reference guide of commonly used Git commands for managing code, branches, commits, and repository history with examples and best practices.
title: 常用 Git 命令
---

Git 命令可在整个开发工作流中节省时间。此参考页面包含用于常见任务（如代码更改、分支管理、历史记录审查）的常用命令。每个命令部分提供确切的语法、实用示例以及指向其他文档的链接。

<a id="git-add"></a>

## `git add` 命令

使用 `git add` 将文件添加到暂存区。

```shell
git add <file_path>
```

可以使用 `git add .` 递归暂存当前工作目录中的所有更改，或使用 `git add --all` 暂存 Git 仓库中的所有更改。

更多信息，请参见[将文件添加到你的分支](add_files.md)。

<a id="git-blame"></a>

## `git blame` 命令

使用 `git blame` 报告哪些用户更改了文件的哪些部分。

```shell
git blame <file_name>
```

你可以使用 `git blame -L <line_start>, <line_end>` 检查特定行数范围。

更多信息，请参见[Git 文件追溯](../../user/project/repository/files/git_blame.md)。

### 示例

要检查 `example.txt` 中谁最近修改了第 5 行：

```shell
$ git blame -L 5, 5 example.txt
123abc (Zhang Wei 2021-07-04 12:23:04 +0000 5)
```

<a id="git-bisect"></a>

## `git bisect` 命令

使用 `git bisect` 以二分搜索查找引入 bug 的提交。

首先确定一个“坏”提交（包含 bug）和一个“好”提交（不包含 bug）。

```shell
git bisect start
git bisect bad                 # 当前版本是坏的
git bisect good v2.6.13-rc2    # v2.6.13-rc2 已知是好的
```

`git bisect` 然后选择两点之间的一个提交，并要求你使用 `git bisect good` 或 `git bisect bad` 来标识该提交是“好”还是“坏”。重复该过程，直到找到提交。

<a id="git-checkout"></a>

## `git checkout` 命令

使用 `git checkout` 切换到指定分支。

```shell
git checkout <branch_name>
```

要创建并切换到新分支，请使用 `git checkout -b <branch_name>`。

更多信息，请参见[为你的更改创建 Git 分支](branch.md)。

<a id="git-clone"></a>

## `git clone` 命令

使用 `git clone` 复制现有的 Git 仓库。

```shell
git clone <repository>
```

更多信息，请参见[将 Git 仓库克隆到本地计算机](clone.md)。

<a id="git-commit"></a>

## `git commit` 命令

使用 `git commit` 将暂存的更改提交到仓库。

```shell
git commit -m "<commit_message>"
```

如果提交消息包含空行，第一行成为提交主题，其余部分成为提交正文。使用主题简要概括更改，使用提交正文提供更多详细信息。

更多信息，请参见[暂存、提交和推送更改](commit.md)。

<a id="git-commit---amend"></a>

## `git commit --amend` 命令

使用 `git commit --amend` 修改最近的提交。

```shell
git commit --amend
```

<a id="git-diff"></a>

## `git diff` 命令

使用 `git diff` 查看本地未暂存的更改与克隆或拉取的最新版本之间的差异。

```shell
git diff
```

你可以显示本地更改与分支最新版本之间的差异（或 diff）。在提交到分支之前查看 diff 以了解你的本地更改。

要比较与特定分支的差异，请运行：

```shell
git diff <branch>
```

在输出中：

- 添加的行以加号 (`+`) 开头，显示为绿色。
- 删除或修改的行以减号 (`-`) 开头，显示为红色。

<a id="git-init"></a>

## `git init` 命令

使用 `git init` 初始化目录，以便 Git 将其作为仓库进行跟踪。

```shell
git init
```

一个包含配置和日志文件的 `.git` 文件被添加到该目录中。你不应直接编辑 `.git` 文件。

默认分支设置为 `main`。你可以使用 `git branch -m <branch_name>` 更改默认分支的名称，或者使用 `git init -b <branch_name>` 初始化。

<a id="git-pull"></a>

## `git pull` 命令

使用 `git pull` 获取自上次克隆或拉取项目后其他用户所做的所有更改。

```shell
git pull <optional_remote> <branch_name>
```

<a id="git-push"></a>

## `git push` 命令

使用 `git push` 更新远程引用。

```shell
git push
```

更多信息，请参见[暂存、提交和推送更改](commit.md)。

<a id="git-reflog"></a>

## `git reflog` 命令

使用 `git reflog` 显示 Git 引用日志的更改列表。

```shell
git reflog
```

默认情况下，`git reflog` 显示 `HEAD` 的更改列表。

更多信息，请参见[撤销更改](undo.md)。

<a id="git-remote-add"></a>

## `git remote add` 命令

使用 `git remote add` 告诉 Git 链接到本地目录中的哪个极狐GitLab 远程仓库。

```shell
git remote add <remote_name> <repository_url>
```

当你克隆一个仓库时，默认源仓库关联的远程名称为 `origin`。

关于配置额外远程仓库的更多信息，请参见[派生](../../user/project/repository/forking_workflow.md)。

<a id="git-log"></a>

## `git log` 命令

使用 `git log` 按时间顺序显示提交列表。

```shell
git log
```

<a id="git-show"></a>

## `git show` 命令

使用 `git show` 显示 Git 中对象的相关信息。

### 示例

要查看 `HEAD` 指向的提交：

```shell
$ git show HEAD
commit ab123c (HEAD -> main, origin/main, origin/HEAD)
```

<a id="git-merge"></a>

## `git merge` 命令

使用 `git merge` 将一个分支的更改合并到另一个分支。

关于 `git merge` 的替代方案，请参见[使用变基解决合并冲突](git_rebase.md)。

### 示例

要将 `feature_branch` 中的更改应用到 `target_branch`：

```shell
git checkout target_branch
git merge feature_branch
```

<a id="git-rebase"></a>

## `git rebase` 命令

使用 `git rebase` 重写分支的提交历史。

```shell
git rebase <branch_name>
```

你可以使用 `git rebase` 来[解决合并冲突](git_rebase.md)。

在大多数情况下，你希望对默认分支进行变基。

<a id="git-reset"></a>

## `git reset` 命令

使用 `git reset` 撤消提交并倒回提交历史，从更早的提交继续。

```shell
git reset
```

更多信息，请参见[撤消更改](undo.md)。

<a id="git-status"></a>

## `git status` 命令

使用 `git status` 显示工作目录和暂存文件的状态。

```shell
git status
```

当你添加、更改或删除文件时，Git 会显示这些更改。