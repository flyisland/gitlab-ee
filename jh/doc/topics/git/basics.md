---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 基本 Git 操作
description: Learn basic Git operations to manage your repositories.
---

基础 Git 操作帮助您管理 Git 仓库并修改代码。
它们为您带来以下好处：

- 版本控制：维护项目历史记录，以便跟踪变更，并在需要时回退到之前的版本。
- 协作：支持协作，使代码共享和同时工作更加容易。
- 组织：使用分支和合并请求来组织和管理您的工作。
- 代码质量：通过合并请求促进代码审查，帮助维护代码质量和一致性。
- 备份与恢复：将变更推送到远程仓库，确保您的工作得到备份并可恢复。

要有效使用 Git 操作，了解仓库、分支、提交和合并请求等关键概念非常重要。更多信息，请参见[开始学习 Git](get_started.md)。

有关常用 Git 命令的更多信息，请参见 [Git 命令](commands.md)。

<a id="create-a-project"></a>

## 创建项目

`git push` 命令将您本地仓库的变更发送到远程仓库。
您可以从本地仓库创建项目，或导入现有的仓库。
添加仓库后，极狐GitLab 会在您选择的命名空间中创建项目。
更多信息，请参见[创建项目](project.md)。

<a id="clone-a-repository"></a>

## 克隆仓库

`git clone` 命令在您的计算机上创建远程仓库的副本。
您可以在本地处理代码，并将变更推送回远程仓库。
更多信息，请参见[克隆 Git 仓库](clone.md)。

<a id="create-a-branch"></a>

## 创建分支

`git checkout -b <分支名称>` 命令在您的仓库中创建新分支。
分支是您仓库中文件的副本，您可以对其进行修改而不影响默认分支。
更多信息，请参见[创建分支](branch.md)。

<a id="stage-commit-and-push-changes"></a>

## 暂存、提交和推送变更

`git add`、`git commit` 和 `git push` 命令会用您的变更更新远程仓库。
Git 根据检出分支的最新版本来跟踪这些变更。
更多信息，请参见[暂存、提交和推送变更](commit.md)。

<a id="stash-changes"></a>

## 储藏变更

`git stash` 命令可临时保存您不想立即提交的变更。
您可以切换分支或执行其他操作，而无需提交未完成的变更。
更多信息，请参见[储藏变更](stash.md)。

<a id="add-files-to-a-branch"></a>

## 向分支添加文件

`git add <文件名>` 命令可将文件添加到 Git 仓库或分支中。
您可以添加新文件、修改现有文件或删除文件。
更多信息，请参见[向分支添加文件](add_files.md)。

<a id="merge-requests"></a>

## 合并请求

合并请求是将变更从一个分支合并到另一个分支的请求。
合并请求提供了一种协作和审查代码变更的方式。
更多信息，请参见[合并请求](../../user/project/merge_requests/_index.md)
和[合并您的分支](merge.md)。

<a id="update-your-fork"></a>

## 更新您的派生

派生是仓库及其所有分支的个人副本，您可以在自己选择的命名空间中创建。
您可以在自己的派生中进行更改，并使用 `git push` 提交它们。
更多信息，请参见[更新派生](forks.md)。

<a id="related-topics"></a>

## 相关主题

- [开始学习 Git](get_started.md)
  - [安装 Git](how_to_install_git/_index.md)
  - [常用 Git 命令](commands.md)
- [高级操作](advanced.md)
- [Git 故障排除](troubleshooting_git.md)
- [Git 速查表](https://gitlab.cn/images/press/git-cheat-sheet.pdf)