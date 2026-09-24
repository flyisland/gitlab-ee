---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Perforce P4 迁移
description: "从 Perforce P4 迁移到 Git。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Perforce P4](https://www.perforce.com/) 提供了一套工具，其中也包括一个类似于 Git 的集中式、专有的版本控制系统。

以下是 Perforce P4 与 Git 的主要区别：

- 与 Git 的轻量级分支相比，Perforce P4 的分支是重量级的。当你在 Perforce P4 中创建一个分支时，它会在其专有数据库里为分支中的每个文件创建一条集成记录，无论实际有多少文件被更改。而使用 Git 时，一个单独的 SHA 可以指向整个仓库在更改后的状态，这在采用功能分支工作流时非常有帮助。
- 在 Git 中进行分支间的上下文切换没有那么复杂。
- 使用 Git，你的本地计算机上拥有项目及其历史的完整副本，这意味着每一次事务都非常快速。你可以自由地创建分支或合并，在隔离环境中进行实验，然后在将更改分享给他人之前进行清理。
- Git 让代码审查变得不那么复杂，因为你可以分享你的更改，而无需将它们合并到默认分支。Perforce P4 则需要在服务器上使用暂存功能，以便其他人可以在合并前审查更改。

## 迁移到 Git

Git 包含一个子命令 (`git p4`)，用于在 Perforce P4 仓库和 Git 仓库之间进行转换。

更多信息，请参见：

- [`git-p4` 手册页](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-p4.html)
- [`git-p4` 文档](https://git-scm.com/docs/git-p4)
- [Git book 迁移指南](https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git#_perforce_import)

`git p4` 和 `git filter-branch` 在创建小型且高效的 Git 包文件方面并不擅长。你可能需要在首次将仓库推送到你的极狐GitLab 服务器之前，正确地重新打包你的仓库。更多信息，请参见[这个 StackOverflow 问题](https://stackoverflow.com/questions/28720151/git-gc-aggressive-vs-git-repack)。