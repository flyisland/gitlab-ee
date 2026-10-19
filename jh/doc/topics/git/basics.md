---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 基本 Git 操作
description: 了解用于管理代码仓库的基本 Git 操作。
---

基本 Git 操作可帮助您管理 Git 代码仓库，并对代码进行更改。它们为您带来以下好处：

- 版本控制：维护项目历史记录，以跟踪更改，并在需要时恢复到之前的版本。
- 协作：支持协作，让共享代码和同时工作变得更加容易。
- 组织：使用分支和合并请求来组织和管理您的工作。
- 代码质量：通过合并请求促进代码评审，并帮助保持代码质量和一致性。
- 备份和恢复：将更改推送到远程代码仓库，确保您的工作得到备份且可恢复。

要有效使用 Git 操作，了解代码仓库、分支、提交和合并请求等关键概念非常重要。更多信息，请参阅[开始学习 Git](get_started.md)。

有关常用 Git 命令的更多信息，请参阅 [Git 命令](commands.md)。

<a id="create-a-project"></a>

## 创建项目

`git push` 命令将本地代码仓库的更改发送到远程代码仓库。
您可以从本地代码仓库创建项目，或导入现有代码仓库。
添加代码仓库后，极狐GitLab 会在您选择的命名空间中创建一个项目。
更多信息，请参阅[创建项目](project.md)。

<a id="clone-a-repository"></a>

## 克隆代码仓库

`git clone` 命令会在您的计算机上创建远程代码仓库的副本。
您可以在本地处理代码，并将更改推送回远程代码仓库。
更多信息，请参阅[克隆 Git 代码仓库](clone.md)。

<a id="create-a-branch"></a>

## 创建分支

`git checkout -b <name-of-branch>` 命令会在您的代码仓库中创建一个新分支。
分支是代码仓库中文件的一个副本，您可以修改它而不影响默认分支。
更多信息，请参阅[创建分支](branch.md)。

<a id="stage-commit-and-push-changes"></a>

## 暂存、提交和推送更改

`git add`、`git commit` 和 `git push` 命令会用您的更改更新远程代码仓库。
Git 会针对已检出分支的最新版本跟踪更改。
更多信息，请参阅[暂存、提交和推送更改](commit.md)。

<a id="stash-changes"></a>

## 储藏更改

`git stash` 命令会临时保存您不想立即提交的更改。
您可以在不提交未完成更改的情况下切换分支或执行其他操作。
更多信息，请参阅[储藏更改](stash.md)。

<a id="add-files-to-a-branch"></a>

## 将文件添加到分支

`git add <filename>` 命令会将文件添加到 Git 代码仓库或分支。
您可以添加新文件、修改现有文件或删除文件。
更多信息，请参阅[将文件添加到分支](add_files.md)。

<a id="merge-requests"></a>

## 合并请求

合并请求是将更改从一个分支合并到另一个分支的请求。合并请求提供了一种协作和评审代码更改的方式。
更多信息，请参阅[合并请求](../../user/project/merge_requests/_index.md)
和[合并您的分支](merge.md)。

<a id="update-your-fork"></a>

## 更新您的 fork

fork 是代码仓库及其所有分支的个人副本，您在您选择的命名空间中创建它。您可以在自己的 fork 中进行更改，并使用 `git push` 提交这些更改。
更多信息，请参阅[更新 fork](forks.md)。
