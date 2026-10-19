---
stage: GitLab Dedicated
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
（TFVC）是一种类似于 Git 的集中式版本控制系统。

TFVC 与 Git 的主要区别如下：

- TFVC 使用客户端-服务器架构，是集中式的，而 Git 是分布式的。Git 的工作流更灵活，
  因为您操作的是整个代码仓库的副本。例如，您可以快速切换分支或执行合并，而无需
  与远程服务器通信。
- 集中式版本控制系统中的变更以文件为单位（变更集），而在 Git 中，提交的文件以
  完整形式存储（快照）。

更多信息，请参见：

- Microsoft 的 [Git 与 TFVC 对比](https://learn.microsoft.com/en-us/azure/devops/repos/tfvc/comparison-git-tfvc?view=azure-devops)。
- Wikipedia 的[版本控制软件对比](https://en.wikipedia.org/wiki/Comparison_of_version_control_software)。

<a id="migrate-to-git"></a>

## 迁移到 Git

我们不提供从 TFVC 迁移到 Git 的工具。有关迁移的信息：

- 如果您在 Microsoft Windows 上迁移，请参见：
  - [`git-tfs`](https://github.com/git-tfs/git-tfs) 工具。
  - 此 [TFS 到 Git 迁移信息](https://github.com/git-tfs/git-tfs/blob/master/doc/usecases/migrate_tfs_to_git.md)。
- 如果您使用基于 Unix 的系统，请参见此 [TFVC 到 Git 迁移工具](https://github.com/turbo/gtfotfs)。
