---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 IBM DevOps ClearCase 迁移
description: "从 IBM DevOps ClearCase 迁移到 Git。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[IBM DevOps ClearCase](https://www.ibm.com/products/devops-code-clearcase) 是 IBM 开发的一套工具，
其中还包含一个类似于 Git 的集中式版本控制系统。

下表说明了 ClearCase 与 Git 之间的主要区别：

| 功能           | ClearCase                    | Git |
|:------------------|:-----------------------------|:----|
| 代码仓库模型  | 客户端-服务器                | 分布式 |
| 修订 ID      | 分支 + 编号              | 全局字母数字 ID |
| 变更范围   | 文件                         | 目录树快照 |
| 并发模型 | 合并                        | 合并 |
| 存储方式    | 增量                       | 完整内容 |
| 客户端            | CLI、Eclipse、CC Client      | CLI、Eclipse、Git 客户端/GUI |
| 服务器            | UNIX、Windows 旧版系统 | UNIX、macOS |
| 许可证           | 专有                  | GPL |

<a id="migrate-to-git"></a>

## 迁移到 Git

我们不提供从 IBM DevOps ClearCase 迁移到 Git 的工具。有关迁移的信息，请参阅以下资源：

- [Git 与 ClearCase 的桥接工具](https://github.com/charleso/git-cc)
- [从 ClearCase 迁移到 Git](https://therub.org/2013/07/19/clearcase-to-git/)
- [将 ClearCase 与 Git 双向同步](https://therub.org/2013/10/22/dual-syncing-clearcase-and-git/)
- [从 ClearCase 迁移到 Git](https://sateeshkumarb.wordpress.com/2011/01/15/moving-to-git-from-clearcase/)
