---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 高级 Git 操作
description: 变基、拣选、还原更改、代码仓库和文件管理。
---

高级 Git 操作可帮助您执行维护和管理代码的任务。这些操作比[基础 Git 操作](basics.md)更复杂。通过这些操作，您可以：

- 重写提交历史。
- 还原和撤销更改。
- 管理远程代码仓库连接。

它们为您带来以下好处：

- 代码质量：维护干净、线性的项目历史。
- 解决问题：提供修复错误或调整代码仓库状态的工具。
- 工作流优化：简化复杂的开发流程。
- 协作：在大型或复杂项目中促进更顺畅的团队合作。

要有效使用 Git 操作，了解代码仓库、分支、提交和合并请求等关键概念非常重要。
有关更多信息，请参阅[开始学习 Git](get_started.md)。

<a id="best-practices"></a>

## 最佳实践

使用高级 Git 操作时，您应该：

- 创建备份，或在[单独的分支](branch.md)上操作。
- 在使用会影响共享分支历史的操作之前，先与团队沟通。
- 重写历史时，使用描述性的[提交信息](../../tutorials/update_commit_messages/_index.md)。
- 更新您的 Git 知识，以跟上最佳实践和新功能。
  有关更多信息，请参阅 [Git 文档](https://git-scm.com/docs)。
- 在测试代码仓库中练习高级操作。

<a id="rebase-and-resolve-conflicts"></a>

## 变基并解决冲突

`git rebase` 命令使用另一个分支的内容更新您的分支。
它会确认您分支中的更改与目标分支中的更改不冲突。
如果您遇到[合并冲突](../../user/project/merge_requests/conflicts.md)，
可以通过变基来修复。

有关更多信息，请参阅[通过变基解决合并冲突](git_rebase.md)。

<a id="cherry-pick-changes"></a>

## 拣选更改

`git cherry-pick` 命令将一个分支中的特定提交应用到另一个分支。
可用于：

- 将缺陷修复从默认分支向后移植到之前的发布分支。
- 将更改从 fork 复制到上游代码仓库。
- 应用特定更改，而无需合并整个分支。

有关更多信息，请参阅[使用 Git 拣选更改](cherry_pick.md)。

<a id="revert-and-undo-changes"></a>

## 还原和撤销更改

以下 Git 命令可帮助您还原和撤销更改：

- `git revert`：创建一个新提交，用于撤销之前提交中所做的更改。
  这有助于您撤销错误或不再需要的更改。
- `git reset`：重置并撤销尚未提交的更改。
- `git restore`：恢复丢失或删除的更改。

有关更多信息，请参阅[还原更改](undo.md)。

<a id="reduce-repository-size"></a>

## 减小代码仓库大小

Git 代码仓库的大小可能会影响性能和存储成本。由于压缩、清理和其他因素，不同实例之间可能略有差异。
有关代码仓库大小的更多信息，请参阅[代码仓库大小](../../user/project/repository/repository_size.md)。

您可以使用 Git 从代码仓库历史中清除文件并减小其大小。有关更多信息，请参阅[减小代码仓库大小](repository.md)。

<a id="file-management"></a>

## 文件管理

您可以使用 Git 管理代码仓库中的文件。它可帮助您跟踪更改、与他人协作并管理大型文件。以下选项可用：

- `git log`：查看代码仓库中文件的更改。
- `git blame`：确定文件中某行代码的最后修改者。
- `git lfs`：管理、跟踪和锁定代码仓库中的文件。

有关更多信息，请参阅[文件管理](file_management.md)。

<a id="update-git-remote-urls"></a>

## 更新 Git 远程 URL

`git remote set-url` 命令用于更新远程代码仓库的 URL。
在以下情况下使用：

- 您从另一个 Git 代码仓库托管平台导入了现有项目。
- 您的组织将项目迁移到了具有新域名的新的极狐GitLab 实例。
- 项目在同一极狐GitLab 实例中被重命名为新路径。

有关更多信息，请参阅[更新 Git 远程 URL](../../tutorials/update_git_remote_url/_index.md)。
