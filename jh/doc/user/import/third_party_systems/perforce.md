---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Perforce P4 迁移
description: "从 Perforce P4 迁移到 Git。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Perforce P4](https://www.perforce.com/) 提供了一组工具，其中也包含一个类似 Git 的集中式专有版本控制系统。

下面列出了 Perforce P4 与 Git 之间的主要区别：

- 与 Git 的轻量级分支相比，Perforce P4 的分支是重量级的。在 Perforce P4 中创建分支时，
  它会为该分支中的每个文件在其专有数据库中创建一条集成记录，无论实际更改了多少个文件。
  而在 Git 中，单个 SHA 即可作为指针，指向更改后整个代码仓库的状态，这在采用功能分支工作流时很有帮助。
- 在 Git 中，分支之间的上下文切换没那么复杂。
- 使用 Git 时，本地计算机上拥有项目及其历史的完整副本，
  意味着每次操作都非常快。您可以创建分支或合并、在隔离环境中试验，然后在
  与他人共享更改之前进行清理。
- Git 让代码评审变得更简单，因为您可以在不将更改合并到默认分支的情况下共享它们。
  Perforce P4 需要在服务器上使用 Shelving 功能，其他人才能在合并前评审更改。

<a id="migrate-to-git"></a>

## 迁移到 Git

Git 包含一个子命令（`git p4`），用于在 Perforce P4 代码仓库和 Git 代码仓库之间迁移。

更多信息，请参见：

- [`git-p4` 手册页](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-p4.html)
- [`git-p4` 文档](https://git-scm.com/docs/git-p4)
- [Git 书籍迁移指南](https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git#_perforce_import)

`git p4` 和 `git filter-branch` 在创建小而高效的 Git 包文件方面表现不佳。您可能需要在首次将代码仓库发送到极狐GitLab 服务器之前，先妥善地重新打包代码仓库。更多信息，请参见
[此 StackOverflow 问题](https://stackoverflow.com/questions/28720151/git-gc-aggressive-vs-git-repack)。
