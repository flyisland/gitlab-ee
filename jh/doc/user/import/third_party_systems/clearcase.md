---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 IBM DevOps ClearCase 迁移
description: "从 IBM DevOps ClearCase 迁移到 Git。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[IBM DevOps ClearCase](https://www.ibm.com/products/devops-code-clearcase) 是 IBM 开发的一系列工具，其中包含一个类似于 Git 的集中式版本控制系统。

下表说明了 ClearCase 和 Git 之间的主要区别：

| 特性           | ClearCase                    | Git |
|:------------------|:-----------------------------|:----|
| 仓库模型  | 客户端-服务器                | 分布式 |
| 版本 ID      | 分支 + 编号              | 全局字母数字 ID |
| 变更范围   | 文件                         | 目录树快照 |
| 并发模型 | 合并                        | 合并 |
| 存储方法    | 增量                       | 完整内容 |
| 客户端            | CLI、Eclipse、CC Client      | CLI、Eclipse、Git 客户端/GUI |
| 服务器            | UNIX、Windows 旧系统 | UNIX、macOS |
| 许可证           | 专有                  | GPL |

## 迁移到 Git

我们未提供从 IBM DevOps ClearCase 迁移到 Git 的工具。有关迁移信息，请参阅以下资源：

- [Bridge for Git and ClearCase](https://github.com/charleso/git-cc)
- [ClearCase to Git](https://therub.org/2013/07/19/clearcase-to-git/)
- [Dual syncing ClearCase to Git](https://therub.org/2013/10/22/dual-syncing-clearcase-and-git/)
- [Moving to Git from ClearCase](https://sateeshkumarb.wordpress.com/2011/01/15/moving-to-git-from-clearcase/)