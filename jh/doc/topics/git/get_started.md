---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Git 版本控制系统。
title: Git 入门
---

Git 是一种版本控制系统，您可以用它跟踪代码的变更，并与他人协作。极狐GitLab 是一个基于 Web 的 Git 代码仓库管理器，提供 CI/CD 及其他功能，帮助您管理软件开发生命周期。

您可以使用极狐GitLab Web 界面执行许多 Git 操作，但了解 Git 命令能为您带来额外的灵活性和控制力。

学习 Git 是更大工作流的一部分：

![在极狐GitLab DevOps 生命周期的创建阶段使用 Git。](img/get_started_git_v16_11.png)

选择您的学习路径：

- [安装 Git](how_to_install_git/_index.md)
- [教程：完成您的首次 Git 提交](../../tutorials/make_first_git_commit/_index.md)
- 了解 Git 概念：继续阅读

<a id="repositories"></a>

## 代码仓库

Git 代码仓库是一个目录，包含项目的所有文件、文件夹和版本历史。它是 Git 管理和跟踪代码变更的中心枢纽。

当您初始化一个 Git 代码仓库或克隆一个现有代码仓库时，Git 会在项目目录内创建一个隐藏目录
`.git`。
该目录包含 Git 用于管理代码仓库的所有必要元数据和对象，
包括对文件所做全部变更的完整历史。
Git 在文件级别跟踪变更，因此您可以查看各个
文件随时间所做的修改。

更多信息，请参见[代码仓库](../../user/project/repository/_index.md)。

<a id="working-directories"></a>

## 工作目录

工作目录是您修改代码的地方。当您克隆一个 Git 代码仓库时，您会在工作目录中创建该代码仓库的本地副本。您可以编辑文件、添加新文件并测试代码。要协作，您可以：

- 提交：在工作目录中进行更改后，将这些更改提交到本地代码仓库。
- 推送：将您的更改推送到托管在极狐GitLab 上的远程 Git 代码仓库。这样其他团队成员就能看到您的更改。
- 拉取：从远程代码仓库拉取他人所做的更改，确保您的本地代码仓库已更新为最新更改。

更多信息，请参见[常用 Git 命令](commands.md)。

<a id="branches"></a>

## 分支

在 Git 中，您可以使用分支同时处理不同的功能、缺陷修复或实验，而不会相互干扰。分支使您能够创建一个隔离的环境，在其中进行和测试更改，而不影响默认分支。在极狐GitLab 中，默认分支通常称为 `main`。

<a id="merge-a-branch"></a>

### 合并分支

功能完成或缺陷修复后，您可以将分支合并到默认分支。
您可以在[合并请求](../../user/project/merge_requests/_index.md)中执行此操作。
合并是一种安全的方式，可以将更改从一个分支引入另一个分支，同时保留更改的历史。

如果分支之间存在冲突，例如，您在两个分支中修改了相同的代码行，
极狐GitLab 会将这些标记为[合并冲突](../../user/project/merge_requests/conflicts.md)。
必须通过审阅和编辑代码手动解决这些冲突。

<a id="delete-a-branch"></a>

### 删除分支

成功合并后，如果不再需要该分支，您可以将其删除。删除不必要的分支有助于保持代码仓库井然有序、易于管理。

> [!note]
> 为确保不丢失任何工作，在最终合并后删除分支之前，请确认所有更改都已并入默认分支。

更多信息，请参见[分支](../../user/project/repository/branches/_index.md)。

<a id="understand-the-git-workflow"></a>

## 了解 Git 工作流

通过 Git 工作流，您可以管理代码、与他人协作，并保持项目井然有序。标准的 Git 工作流包括以下步骤：

1. 克隆代码仓库：通过将代码仓库克隆到您的机器上，创建其本地副本。
   这样您就可以在不影响原始代码仓库的情况下处理项目。
1. 创建新分支：在进行任何更改之前，建议创建一个新分支。
   这可确保您的更改是隔离的，不会干扰他人在
   默认分支上的工作。
1. 进行更改：在工作目录中修改文件。
   您可以添加新功能、修复缺陷或进行其他修改。
1. 暂存更改：修改文件后，暂存您要提交的更改。
   暂存会告诉 Git 哪些更改应包含在下一次提交中。
1. 提交更改：将暂存的更改提交到本地代码仓库。
   提交会保存您工作的快照，并创建文件更改的历史记录。
1. 推送更改：要与他人分享您的更改，请将其推送到远程代码仓库。
   这样其他协作者就能看到您的更改。
1. 合并分支：在您的更改经过评审和批准后，将分支合并到
   默认分支。例如 `main`。此步骤会将您的更改并入项目。

<a id="forks"></a>

## Forks

某些组织，尤其是从事开源项目的组织，可能会使用
不同的工作流。例如，[forks](../../user/project/repository/forking_workflow.md)。

fork 是代码仓库的一个个人副本，存在于您自己的命名空间中。在为开源项目做贡献或您的团队使用集中式代码仓库时，请使用此工作流。

<a id="install-git"></a>

## 安装 Git

要使用 Git 命令并为极狐GitLab 项目做贡献，您应该下载并安装 Git 客户端到您的计算机上。

安装过程因操作系统而异。
例如，Windows、macOS 或 Linux。
有关如何安装 Git 的信息，请参见[安装 Git](how_to_install_git/_index.md)。

<a id="git-commands"></a>

## Git 命令

要从命令行与 Git 交互，您可以使用 Git 命令：

- `git clone`：将代码仓库克隆到您的本地机器。
- `git branch`：列出、创建或删除本地代码仓库中的分支。
- `git checkout`：在本地代码仓库的不同分支之间切换。
- `git add`：暂存更改以供提交。
- `git commit`：将暂存的更改提交到本地代码仓库。
- `git push`：将本地提交推送到远程代码仓库。
- `git pull`：从远程代码仓库获取更改并将其合并到您的本地分支。

如需更全面的信息和详细说明，
请参见[常用 Git 命令](commands.md)指南。

<a id="use-ssh-with-git"></a>

### 将 SSH 与 Git 配合使用

使用远程代码仓库时，您应使用 SSH 进行安全通信。

极狐GitLab 使用 SSH 协议与 Git 安全通信。
当您使用 SSH 密钥向极狐GitLab 远程服务器进行身份验证时，无需每次都提供用户名和密码。

要将 SSH 与极狐GitLab 配合使用，您必须：

1. 在本地系统上生成 SSH 密钥对。
1. 将您的 SSH 密钥添加到极狐GitLab 账号。
1. 验证您与极狐GitLab 的 SSH 连接。

更多信息，请参见[将 SSH 密钥与极狐GitLab 配合使用](../../user/ssh.md)。
