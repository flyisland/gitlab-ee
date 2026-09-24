```yaml
---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: To remove unwanted large files from a Git repository and reduce its storage size, use the filter-repo command.
title: 减少仓库大小
---

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Git 仓库的大小会显著影响性能与存储成本。  
由于压缩、整理及其他因素，不同实例间的仓库大小可能略有差异。

有关仓库大小的更多信息，请参见：

- [仓库大小](../../user/project/repository/repository_size.md)
  - [仓库大小如何计算](../../user/project/repository/repository_size.md#size-calculation)
  - [大小与存储限制](../../user/project/repository/repository_size.md#size-and-storage-limits)
  - [极狐GitLab UI 中减小仓库大小的方法](../../user/project/repository/repository_size.md#methods-to-reduce-repository-size)

<a id="purge-files-from-repository-history"></a>

## 从仓库历史中清理文件

使用此方法可将大文件从整个 Git 历史中移除。

此方法不适合从仓库中移除密码或密钥等敏感数据。  
包括文件内容在内的提交信息会缓存于数据库中，即使已从仓库中移除，仍可能可见。  
要移除敏感数据，请使用 [移除 blob](../../user/project/repository/repository_size.md#remove-blobs) 中描述的方法。

准备工作：

- 你必须安装 [`git filter-repo`](https://github.com/newren/git-filter-repo/blob/main/INSTALL.md)。
- 可选。安装 [`git-sizer`](https://github.com/github/git-sizer#getting-started)。

> [!warning]
> 清理文件是一项破坏性操作。继续之前，请确保已备份仓库。

要从极狐GitLab 仓库中清理文件：

1. [导出项目](../../user/project/settings/import_export.md#export-a-project-and-its-data)（包含你的仓库副本）并下载。

   - 对于大型项目，你可以使用 [Project relations export API](../../api/project_relations_export.md)。

1. 解压备份：

   ```shell
   tar xzf project-backup.tar.gz
   ```

1. 使用 `--bare` 和 `--mirror` 选项克隆仓库：

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

1. 使用 `git filter-repo` 或 `git-sizer` 分析仓库：

   - `git filter-repo`：

     ```shell
     git filter-repo --analyze
     head filter-repo/analysis/*-{all,deleted}-sizes.txt
     ```

   - `git-sizer`：

     ```shell
     git-sizer
     ```

1. 使用以下任一 `git filter-repo` 选项清理仓库历史：

   - `--path` 和 `--invert-paths` 清理指定文件：

     ```shell
     git filter-repo --path path/to/file.ext --invert-paths
     ```

   - `--strip-blobs-bigger-than` 清理所有大于例如 10M 的文件：

     ```shell
     git filter-repo --strip-blobs-bigger-than 10M
     ```

   更多示例请参见 [`git filter-repo` 文档](https://htmlpreview.github.io/?https://github.com/newren/git-filter-repo/blob/docs/html/git-filter-repo.html#EXAMPLES)。

1. 备份 `commit-map`：

   ```shell
   cp filter-repo/commit-map ./_filter_repo_commit_map_$(date +%s)
   ```

1. 取消镜像标志：

   ```shell
    git config --unset remote.origin.mirror
   ```

1. 强制推送更改：

   ```shell
   git push origin --force 'refs/heads/*'
   git push origin --force 'refs/tags/*'
   git push origin --force 'refs/replace/*'
   ```

   有关引用的更多信息，请参见 Gitaly 使用的 Git 引用。

   > [!note]
   > 此步骤对 [受保护分支](../../user/project/repository/branches/protected.md) 和 [受保护标签](../../user/project/protected_tags.md) 会失败。要继续操作，请临时移除保护。
1. 等待至少 30 分钟再继续下一步。
1. 运行 [清理仓库](../../user/project/repository/repository_size.md#clean-up-repository) 处理。  
   此处理仅清理 30 分钟前的对象。  
   更多信息，请参见 [清理后空间未释放](../../user/project/repository/repository_size.md#space-not-being-freed-after-cleanup)。

```