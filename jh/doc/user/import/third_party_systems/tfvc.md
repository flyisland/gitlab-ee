---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Team Foundation 版本控制迁移
description: "从 Team Foundation 版本控制迁移到 Git。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Team Foundation 版本控制](https://learn.microsoft.com/en-us/azure/devops/repos/tfvc/what-is-tfvc?view=azure-devops)
(TFVC) 是一种类似于 Git 的集中式版本控制系统。

TFVC 与 Git 的主要区别在于：

- TFVC 采用客户端-服务器架构的集中式模式，而 Git 是分布式的。Git 拥有更灵活的工作流，
  因为你操作的是整个仓库的副本。例如，你可以快速切换分支或合并，而无需与远程服务器通信。
- 集中式版本控制系统中的变更是按文件进行的（变更集），而在 Git 中，提交的文件会完整存储（快照）。

更多信息，请参阅：

- Microsoft 的 [Git 与 TFVC 对比](https://learn.microsoft.com/en-us/azure/devops/repos/tfvc/comparison-git-tfvc?view=azure-devops)。
- Wikipedia 的 [版本控制软件对比](https://en.wikipedia.org/wiki/Comparison_of_version_control_software)。

## 迁移到 Git

我们不提供从 TFVC 迁移到 Git 的工具。有关迁移的信息：

- 如果您在 Microsoft Windows 上迁移，请参阅：
  - [`git-tfs`](https://github.com/git-tfs/git-tfs) 工具。
  - 此 [TFS 到 Git 迁移信息](https://github.com/git-tfs/git-tfs/blob/master/doc/usecases/migrate_tfs_to_git.md)。
- 如果您使用的是基于 Unix 的系统，请参阅此 [TFVC 到 Git 迁移工具](https://github.com/turbo/gtfotfs)。

