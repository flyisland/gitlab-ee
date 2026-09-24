---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从并发版本系统迁移
description: "从并发版本系统迁移到 Git。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[并发版本系统](https://savannah.nongnu.org/projects/cvs) (CVS) 是一种集中式版本控制系统，类似于 [Subversion](https://subversion.apache.org/)。

有关 CVS 和 Git 之间差异的概述，请参阅此 [Stack Overflow 帖子](https://stackoverflow.com/a/824241/974710)。
有关更完整的差异列表，请参阅维基百科文章[比较不同版本控制软件](https://en.wikipedia.org/wiki/Comparison_of_version_control_software)。

<a id="migrate-to-git"></a>

## 迁移到 Git

我们不提供从 CVS 迁移到 Git 的工具。有关迁移的信息，请参见以下资源：

- [使用 `cvs-fast-export` 工具迁移](https://gitlab.com/esr/cvs-fast-export)
- [Stack Overflow 上有关导入 CVS 仓库的帖子](https://stackoverflow.com/questions/11362676/how-to-import-and-keep-updated-a-cvs-repository-in-git/11490134#11490134)
- [`git-cvsimport` 工具的手册页](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-cvsimport.html)
- [使用 `reposurgeon` 迁移](http://www.catb.org/~esr/reposurgeon/repository-editing.html#conversion)