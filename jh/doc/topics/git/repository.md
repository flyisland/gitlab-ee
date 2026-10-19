---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 要从 Git 代码仓库中移除不需要的大文件并减小其存储大小，请使用 filter-repo 命令。
title: 减小代码仓库大小
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Git 代码仓库的大小会显著影响性能和存储成本。由于压缩、内务整理和其他因素，不同实例之间的大小可能略有差异。

有关代码仓库大小的更多信息，请参阅：

- [代码仓库大小](../../user/project/repository/repository_size.md)
  - [代码仓库大小如何计算](../../user/project/repository/repository_size.md#size-calculation)
  - [大小和存储限制](../../user/project/repository/repository_size.md#size-and-storage-limits)
  - [用于减小代码仓库大小的极狐GitLab UI 方法](../../user/project/repository/repository_size.md#methods-to-reduce-repository-size)

<a id="purge-files-from-repository-history"></a>

## 从代码仓库历史中清除文件

使用此方法可从整个 Git 历史中移除大文件。

它不适用于从代码仓库中移除密码或密钥等敏感数据。有关提交的信息（包括文件内容）会缓存在数据库中，即使已从代码仓库中移除，这些信息仍可见。要移除敏感数据，请使用[移除 blob](../../user/project/repository/repository_size.md#remove-blobs)中所述的方法。

先决条件：

- 您必须安装 [`git filter-repo`](https://github.com/newren/git-filter-repo/blob/main/INSTALL.md)。
- 可选。安装 [`git-sizer`](https://github.com/github/git-sizer#getting-started)。

> [!warning]
> 清除文件是一项破坏性操作。继续操作之前，请确保您已备份代码仓库。

要从极狐GitLab 代码仓库中清除文件：

1. [导出项目](../../user/project/settings/import_export.md#export-a-project-and-its-data)（其中包含
   代码仓库的副本），并下载它。

   - 对于大型项目，您可以使用[项目关系导出 API](../../api/project_relations_export.md)。

1. 解压缩并提取备份：

   ```shell
   tar xzf project-backup.tar.gz
   ```

1. 使用 `--bare` 和 `--mirror` 选项克隆代码仓库：

   ```shell
   git clone --bare --mirror /path/to/project.bundle
   ```

1. 进入 `project.git` 目录：

   ```shell
   cd project.git
   ```

1. 更新远程 URL：

   ```shell
   git remote set-url origin https://gitlab.example.com/<namespace>/<project_name>.git
   ```

1. 使用 `git filter-repo` 或 `git-sizer` 分析代码仓库：

   - `git filter-repo`：

     ```shell
     git filter-repo --analyze
     head filter-repo/analysis/*-{all,deleted}-sizes.txt
     ```

   - `git-sizer`：

     ```shell
     git-sizer
     ```

1. 使用以下 `git filter-repo` 选项之一清除代码仓库的历史：

   - `--path` 和 `--invert-paths` 用于清除特定文件：

     ```shell
     git filter-repo --path path/to/file.ext --invert-paths
     ```

   - `--strip-blobs-bigger-than` 用于清除所有大于例如 10M 的文件：

     ```shell
     git filter-repo --strip-blobs-bigger-than 10M
     ```

   有关更多示例，请参阅
   [`git filter-repo` 文档](https://htmlpreview.github.io/?https://github.com/newren/git-filter-repo/blob/docs/html/git-filter-repo.html#EXAMPLES)。

1. 备份 `commit-map`：

   ```shell
   cp filter-repo/commit-map ./_filter_repo_commit_map_$(date +%s)
   ```

1. 取消设置 mirror 标志：

   ```shell
    git config --unset remote.origin.mirror
   ```

1. 强制推送更改：

   ```shell
   git push origin --force 'refs/heads/*'
   git push origin --force 'refs/tags/*'
   git push origin --force 'refs/replace/*'
   ```

   有关引用的更多信息，请参阅
   Gitaly 使用的 Git 引用。

   > [!note]
   > 此步骤对[受保护分支](../../user/project/repository/branches/protected.md)和
   > [受保护标签](../../user/project/protected_tags.md)会失败。要继续操作，请暂时移除保护。
1. 在执行下一步之前，至少等待 30 分钟。
1. 运行[清理代码仓库](../../user/project/repository/repository_size.md#clean-up-repository)流程。
   此流程只会清理超过 30 分钟的对象。
   有关更多信息，请参阅[清理后空间未释放](../../user/project/repository/repository_size.md#space-not-being-freed-after-cleanup)。
