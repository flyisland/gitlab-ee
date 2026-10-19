---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 一份常用 Git 命令参考指南，介绍如何使用这些命令管理代码、分支、提交和代码仓库历史，并附有示例和最佳实践。
title: 常用 Git 命令
---

Git 命令可以在整个开发工作流中为您节省时间。本参考页面收录了常见任务中经常使用的命令，例如代码更改、分支管理和历史查看。每个命令小节都提供了确切的语法、实用示例以及更多文档的链接。

<a id="git-add"></a>

## `git add`

使用 `git add` 将文件添加到暂存区。

```shell
git add <file_path>
```

您可以使用 `git add .` 递归暂存当前工作目录中的更改，或使用 `git add --all` 暂存 Git 代码仓库中的所有更改。

更多信息，请参见[将文件添加到您的分支](add_files.md)。

<a id="git-blame"></a>

## `git blame`

使用 `git blame` 查看哪些用户更改了文件中的哪些部分。

```shell
git blame <file_name>
```

您可以使用 `git blame -L <line_start>,<line_end>` 检查特定的行范围。

更多信息，请参见 [Git 文件追溯](../../user/project/repository/files/git_blame.md)。

<a id="example"></a>

### 示例

要查看最近修改 `example.txt` 第五行的用户：

```shell
$ git blame -L 5,5 example.txt
123abc (Zhang Wei 2021-07-04 12:23:04 +0000 5)
```

<a id="git-bisect"></a>

## `git bisect`

使用 `git bisect` 通过二分查找找出引入缺陷的提交。

首先确定一个“坏”提交（包含缺陷）和一个“好”提交（不包含缺陷）。

```shell
git bisect start
git bisect bad                 # Current version is bad
git bisect good v2.6.13-rc2    # v2.6.13-rc2 is known to be good
```

`git bisect` 随后会选取这两个点之间的一个提交，并要求您使用
`git bisect good` 或 `git bisect bad` 判断该提交是“好”还是“坏”。重复此过程，直到找到该提交。

<a id="git-checkout"></a>

## `git checkout`

使用 `git checkout` 切换到特定分支。

```shell
git checkout <branch_name>
```

要创建新分支并切换到该分支，请使用 `git checkout -b <branch_name>`。

更多信息，请参见[为您的更改创建 Git 分支](branch.md)。

<a id="git-clone"></a>

## `git clone`

使用 `git clone` 复制现有的 Git 代码仓库。

```shell
git clone <repository>
```

更多信息，请参见[将 Git 代码仓库克隆到本地计算机](clone.md)。

<a id="git-commit"></a>

## `git commit`

使用 `git commit` 将暂存的更改提交到代码仓库。

```shell
git commit -m "<commit_message>"
```

如果提交信息包含空行，第一行将成为提交主题，其余部分则成为提交正文。使用主题简要概括更改，使用提交正文提供更多细节。

更多信息，请参见[暂存、提交和推送更改](commit.md)。

<a id="git-commit---amend"></a>

## `git commit --amend`

使用 `git commit --amend` 修改最近一次提交。

```shell
git commit --amend
```

<a id="git-diff"></a>

## `git diff`

使用 `git diff` 查看本地未暂存的更改与您克隆或拉取的最新版本之间的差异。

```shell
git diff
```

您可以显示本地更改与分支最新版本之间的差异（即 diff）。在将本地更改提交到分支之前，查看差异以了解这些更改。

要将您的更改与特定分支进行比较，请运行：

```shell
git diff <branch>
```

在输出中：

- 新增的行以加号（`+`）开头，并以绿色显示。
- 删除或更改的行以减号（`-`）开头，并以红色显示。

<a id="git-init"></a>

## `git init`

使用 `git init` 初始化目录，使 Git 将其作为代码仓库进行跟踪。

```shell
git init
```

该目录中会添加一个包含配置和日志文件的 `.git` 文件。您不应直接编辑 `.git` 文件。

默认分支设置为 `main`。您可以使用 `git branch -m <branch_name>` 更改默认分支的名称，或使用 `git init -b <branch_name>` 进行初始化。

<a id="git-pull"></a>

## `git pull`

使用 `git pull` 获取用户在上次克隆或拉取项目之后所做的所有更改。

```shell
git pull <optional_remote> <branch_name>
```

<a id="git-push"></a>

## `git push`

使用 `git push` 更新远程引用。

```shell
git push
```

更多信息，请参见[暂存、提交和推送更改](commit.md)。

<a id="git-reflog"></a>

## `git reflog`

使用 `git reflog` 显示 Git 引用日志的更改列表。

```shell
git reflog
```

默认情况下，`git reflog` 显示 `HEAD`的更改列表。

更多信息，请参见[撤销更改](undo.md)。

<a id="git-remote-add"></a>

## `git remote add`

使用 `git remote add` 告诉 Git 极狐GitLab 中的哪个远程代码仓库与本地目录相关联。

```shell
git remote add <remote_name> <repository_url>
```

克隆代码仓库时，默认情况下源代码仓库会与远程名称 `origin` 相关联。

有关配置其他远程仓库的更多信息，请参见 [forks](../../user/project/repository/forking_workflow.md)。

<a id="git-log"></a>

## `git log`

使用 `git log` 按时间顺序显示提交列表。

```shell
git log
```

<a id="git-show"></a>

## `git show`

使用 `git show` 显示 Git 中某个对象的信息。

<a id="example-1"></a>

### 示例

要查看 `HEAD` 指向哪个提交：

```shell
$ git show HEAD
commit ab123c (HEAD -> main, origin/main, origin/HEAD)
```

<a id="git-merge"></a>

## `git merge`

使用 `git merge` 将一个分支的更改与另一个分支合并。

有关 `git merge` 替代方案的更多信息，请参见[变基以解决合并冲突](git_rebase.md)。

<a id="example-2"></a>

### 示例

要将 `feature_branch`中的更改应用到 `target_branch`：

```shell
git checkout target_branch
git merge feature_branch
```

<a id="git-rebase"></a>

## `git rebase`

使用 `git rebase` 重写分支的提交历史。

```shell
git rebase <branch_name>
```

您可以使用 `git rebase` [解决合并冲突](git_rebase.md)。

在大多数情况下，您需要针对默认分支进行变基。

<a id="git-reset"></a>

## `git reset`

使用 `git reset` 撤销提交、回退提交历史，并从更早的提交继续。

```shell
git reset
```

更多信息，请参见[撤销更改](undo.md)。

<a id="git-status"></a>

## `git status`

使用 `git status` 显示工作目录和已暂存文件的状态。

```shell
git status
```

当您添加、更改或删除文件时，Git 可以向您显示这些更改。
