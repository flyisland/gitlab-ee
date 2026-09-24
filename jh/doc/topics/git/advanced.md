---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 高级 Git 操作
description: Rebase, cherry-pick, revert changes, repository, and file management.
---

高级 Git 操作可以帮助你执行维护和管理代码的任务。
这些操作比[基础 Git 操作](basics.md)更为复杂。
它们可以让你：

- 重写提交历史。
- 回滚和撤销更改。
- 管理远程仓库连接。

它们提供了以下优势：

- 代码质量：维护干净、线性的项目历史。
- 问题解决：提供了修复错误或调整仓库状态的工具。
- 工作流优化：简化复杂开发流程。
- 协作：促进大型或复杂项目中的顺畅团队合作。

要有效地使用 Git 操作，理解仓库、分支、提交和合并请求等关键概念非常重要。
有关更多信息，请参见[开始学习 Git](get_started.md)。

<a id="best-practices"></a>

## 最佳实践

使用高级 Git 操作时，你应该：

- 创建备份或在[单独的分支](branch.md)上操作。
- 在影响共享分支历史的操作之前与团队沟通。
- 重写历史时使用描述性的[提交信息](../../tutorials/update_commit_messages/_index.md)。
- 更新你的 Git 知识以保持与最佳实践和新特性同步。
  有关更多信息，请参见 [Git 文档](https://git-scm.com/docs)。
- 在测试仓库中练习高级操作。

<a id="rebase-and-resolve-conflicts"></a>

## 变基与解决冲突

`git rebase` 命令会用另一个分支的内容更新你的分支。
它确认你的分支中的更改不会与目标分支中的更改冲突。
如果你遇到了[合并冲突](../../user/project/merge_requests/conflicts.md)，你可以通过变基来修复它。

有关更多信息，请参见[通过变基解决合并冲突](git_rebase.md)。

<a id="cherry-pick-changes"></a>

## 拣选更改

`git cherry-pick` 命令会将特定提交从一个分支应用到另一个分支。
你可以用它来：

- 将错误修复从默认分支向后移植到之前的发布分支。
- 将更改从派生（fork）复制到上游仓库。
- 应用特定更改而不合并整个分支。

有关更多信息，请参见[使用 Git 拣选更改](cherry_pick.md)。

<a id="revert-and-undo-changes"></a>

## 回滚与撤销更改

以下 Git 命令可以帮助你回滚和撤销更改：

- `git revert`：创建一个新的提交，用于撤销之前提交的更改。
  这可以帮助你撤销错误或不再需要的更改。
- `git reset`：重置并撤销尚未提交的更改。
- `git restore`：恢复丢失或删除的更改。

有关更多信息，请参见[撤销更改](undo.md)。

<a id="reduce-repository-size"></a>

## 减小仓库大小

Git 仓库的大小会影响性能和存储成本。
由于压缩、清理和其他因素，不同实例上的大小可能会略有不同。
有关仓库大小的更多信息，请参见[仓库大小](../../user/project/repository/repository_size.md)。

你可以使用 Git 从仓库历史中清除文件并减小其大小。
有关更多信息，请参见[减小仓库大小](repository.md)。

<a id="file-management"></a>

## 文件管理

你可以使用 Git 管理仓库中的文件。它可以帮助你追踪更改、协作他人以及管理大文件。以下选项可用：

- `git log`：查看仓库中文件的更改。
- `git blame`：识别文件中的一行代码最后是谁修改的。
- `git lfs`：管理、追踪和锁定仓库中的文件。

有关更多信息，请参见[文件管理](file_management.md)。

<a id="update-git-remote-urls"></a>

## 更新 Git 远程 URL

`git remote set-url` 命令更新远程仓库的 URL。
在以下情况使用它：

- 你从另一个 Git 仓库托管平台导入了现有项目。
- 你的组织将项目迁移到了使用新域名的新的极狐GitLab 实例。
- 项目在同一个极狐GitLab 实例中被重命名为新路径。

有关更多信息，请参见[更新 Git 远程 URL](../../tutorials/update_git_remote_url/_index.md)。

<a id="related-topics"></a>

## 相关主题

- [入门](get_started.md)
- [基础 Git 操作](basics.md)
- [常用 Git 命令](commands.md)