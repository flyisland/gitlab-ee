---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解代码仓库大小的计算和显示方式、大小限制，以及减少 Git 代码仓库存储的方法。
title: 代码仓库大小
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Git 代码仓库的大小会显著影响性能和存储成本。由于压缩、内务处理和其他因素，不同实例之间可能略有差异。

<a id="size-calculation"></a>

## 大小计算

代码仓库大小是代码仓库中所有文件的累计大小。该计算类似于在代码仓库的
[哈希存储路径](../../../administration/repository_storage_paths.md)上执行 `du --summarize --bytes`。
代码仓库发生变化时会重新计算大小，但每 15 分钟最多计算一次。

代码仓库大小是项目大小的子集。项目大小显示在项目概览页面的**项目信息**下，包括代码仓库以及 LFS 对象、作业产物、软件包和 Wiki。

<a id="view-repository-size"></a>

### 查看代码仓库大小

先决条件：

- 项目的维护者或所有者角色，或命名空间的所有者角色。

查看代码仓库大小：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **使用配额**。
1. 选择**存储**标签页。
1. 在用量明细中，查看**代码仓库**行中的值。

有关项目所用存储的更多信息，请参阅[存储](../../storage_usage_quotas.md)。

<a id="size-and-storage-limits"></a>

## 大小和存储限制

管理员可以为极狐GitLab 私有化部署设置[代码仓库大小限制](../../../administration/settings/account_and_limit_settings.md#repository-size-limit)。对于 JihuLab.com，大小限制是[预定义的](../../jihulab_com/_index.md#account-and-limit-settings)。

当项目达到其大小限制时，推送、创建合并请求和上传 LFS 对象等某些操作会受到限制。

<a id="before-you-rewrite-git-history"></a>

## 重写 Git 历史之前

在重写 Git 历史并从代码仓库中删除数据之前，您必须考虑以下各节中的信息。

<a id="local-clones-must-be-changed"></a>

### 必须更改本地克隆

所有拥有该代码仓库克隆的人必须执行以下操作之一：

- 删除其本地副本，并克隆该代码仓库的新副本。
- 获取所有远程更改，并确保所有正在进行的工作都基于这些更改进行变基。

如果操作不当，推送本地更改的用户可能会恢复本应删除的文件。

<a id="running-pipelines-can-cause-cleanup-to-fail"></a>

### 运行流水线可能导致清理失败

如果在清理期间仍有流水线在运行，它们可能会与代码仓库交互，导致清理无法正常工作。

<a id="garbage-collection-grace-period"></a>

### 垃圾回收宽限期

极狐GitLab 运行 Git 垃圾回收时带有 30 分钟的宽限期。此过程会清理同时满足以下两个条件的对象：

- 无法从任何引用访问。
- 至少存在 30 分钟。

如果您想删除的数据可以从任何提交访问，或者存在时间不足 30 分钟，Git 垃圾回收不会将其删除。

因此，在运行内务处理后，您必须至少等待 30 分钟，然后再选择**清理不可达对象**。

<a id="history-cannot-be-rewritten-on-forked-project"></a>

### 无法在 forked 项目上重写历史

内置方法无法用于 forked 的代码仓库。极狐GitLab 对象在 forks 之间的存储方式使得 Git 无法对 forks 之间共享的对象进行垃圾回收。

<a id="workaround-archive-the-project"></a>

### 变通方法：归档项目

如果您在清理之前[归档](../working_with_projects.md#archive-a-project)项目，代码仓库将变为只读。这可以确保在清理进行期间没有人可以进行更改。

归档代码仓库还会移除 fork 关系。这意味着您可以清理数据。但如果数据已被拉取到 fork 中，则也需要在那里进行清理。

<a id="methods-to-reduce-repository-size"></a>

## 减小代码仓库大小的方法

可以使用以下方法来减小代码仓库的大小：

- [从历史中清除文件](#purge-files-from-repository-history)：从整个 Git 历史中删除大文件。
- [清理代码仓库](#clean-up-repository)：移除内部 Git 引用和未引用的对象。
- [移除 blob](#remove-blobs)：永久删除包含敏感或机密信息的 blob。

在减小代码仓库大小之前，您应该[创建代码仓库的完整备份](../../../administration/backup_restore/_index.md)。
这些方法不可逆，可能会影响项目的历史和数据。

当您使用任何可用的方法减小代码仓库大小时，无需阻止对项目的访问。您可以在项目仍对用户可访问的情况下执行这些操作。这些方法没有任何已知的性能影响，也不会导致停机。但是，您应该在活动较少的时段执行这些操作，以尽量减少对用户的潜在影响。

<a id="purge-files-from-repository-history"></a>

### 从代码仓库历史中清除文件

您可以使用 `git filter-repo` [清除文件](../../../topics/git/repository.md#purge-files-from-repository-history)，以从 Git 历史中删除大文件。请勿使用此方法删除密码或密钥等敏感数据。
而应使用[移除 blob](#remove-blobs) 或[遮盖文本](#redact-text-from-repository)。

此过程：

- 修改整个 Git 历史。
- 可能影响打开的合并请求。
- 可能影响现有的流水线。
- 需要重新克隆本地代码仓库。
- 不影响 LFS 对象。
- 不指定提交签名。
- 不可逆。

> [!note]
> 有关提交的信息（包括文件内容）会缓存在数据库中，即使已从代码仓库中移除，这些信息仍然可见。

<a id="clean-up-repository"></a>

### 清理代码仓库

使用此方法可以从代码仓库中移除内部 Git 引用和未引用的对象。请勿使用此方法删除敏感数据。
要删除敏感数据，请使用[移除 blob 方法](#remove-blobs)。

此过程：

- 运行 `git gc --prune=30.minutes.ago` 以移除未引用的对象。
- 解除未使用的 LFS 对象的链接，释放存储空间。
- 重新计算磁盘上的代码仓库大小。
- 不可逆。

> [!warning]
> 移除内部 Git 引用会导致关联的合并请求提交、流水线和变更详情变得不可用。

先决条件：

- 要移除的对象列表。使用 [`git filter-repo`](https://github.com/newren/git-filter-repo) 在 `commit-map` 文件中生成对象列表。

清理代码仓库：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 转到**设置** > **代码仓库**。
1. 展开**代码仓库维护**。
1. 上传要移除的对象列表。例如，`filter-repo` 目录中的 `commit-map` 文件。

   如果您的 `commit-map` 文件太大，后台清理过程可能会超时并失败。
   因此，代码仓库大小不会如预期般减小。要解决此问题，请拆分文件并
   分部分上传。从 `20000` 开始，根据需要减少。例如：

   ```shell
   split -l 20000 filter-repo/commit-map filter-repo/commit-map-
   ```

1. 选择**开始清理**。

清理完成后，极狐GitLab 会发送一封电子邮件通知，其中包含重新计算的代码仓库大小。

<a id="remove-data-from-a-repository"></a>

## 从代码仓库中移除数据

要从代码仓库中移除敏感或机密数据，请使用以下方法之一：

- 要完全移除文件，请[移除 blob](#remove-blobs)。
- 要保留文件，但将机密文本替换为替换文本 `***REMOVED***`，请[遮盖文本](#redact-text-from-repository)。

<a id="remove-blobs"></a>

### 移除 blob

Git 二进制大对象（blob）存储文件内容而不包含元数据。每个 blob 都有一个唯一的 SHA 哈希，表示代码仓库中文件的特定版本。

使用此方法可以永久删除包含敏感或机密信息的 blob。

此过程：

- 重写 Git 历史。
- 丢弃提交签名。
- 可能导致打开的合并请求无法合并，需要手动变基。
- 可能导致引用旧提交 SHA 的流水线中断。
- 可能影响基于旧提交历史的历史标签和分支。
- 需要重新克隆本地代码仓库。
- 不可逆。

> [!note]
> 您也可以将字符串替换为替换字符串 `***REMOVED***`。有关更多信息，请参阅
> [从代码仓库中遮盖文本](#redact-text-from-repository)。

先决条件：

- 您必须拥有项目的所有者角色。
- [要移除的对象 ID 列表](#get-a-list-of-object-ids)。
- 您的项目不能是：
  - 公共上游项目的 fork。
  - 带有下游 forks 的公共上游项目。

> [!note]
> 为确保成功移除 blob，请考虑在该过程中临时限制代码仓库访问。在移除 blob 期间推送的新提交可能导致操作失败。

从代码仓库中移除 blob：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**代码仓库维护**。
1. 选择**移除 blob**。
1. 输入要移除的 blob ID 列表，每个 ID 占一行。
1. 选择**移除 blob**。
1. 在确认对话框中，输入您的项目路径。
1. 选择**是，移除 blob**。
1. 等待 blob 移除完成后再继续：
   - 如果启用了[电子邮件通知](../../profile/notifications.md)，
     请等待收到一封说明代码仓库历史重写已完成的电子邮件。
   - 如果未启用电子邮件通知，请至少等待 5 分钟。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开标有**高级**的部分。
1. 选择**运行内务处理**。等待至少 30 分钟以完成操作。
1. 在同一个**设置** > **通用** > **高级**部分中，选择**清理不可达对象**。
   此操作大约需要 5-10 分钟完成。

> [!note]
> 如果包含敏感信息的项目已被 forked，内务处理任务可能会成功执行，但无法完成此过程。内务处理必须维护
> [特殊对象池代码仓库](../../../administration/housekeeping.md#object-pool-repositories)的完整性，
> 该代码仓库包含 forked 数据。
> 如需帮助，请联系极狐GitLab 支持。

<a id="get-a-list-of-object-ids"></a>

#### 获取对象 ID 列表

要移除 blob，您需要一份要移除的对象列表。
要获取这些 ID，请使用 `ls-tree` 命令或[列出代码仓库树 API 端点](../../../api/repositories.md#list-all-repository-trees-in-a-project)。
以下说明使用 `ls-tree` 命令。

先决条件：

- 代码仓库必须已克隆到您的本地计算机。

获取给定提交或分支上按大小排序的 blob 列表：

1. 打开终端并转到您的代码仓库目录。
1. 运行以下命令：

   ```shell
   git ls-tree -r -t --long --full-name <COMMIT/BRANCH> | sort -nk 4
   ```

   示例输出：

   ```plaintext
   100644 blob 8150ee86f923548d376459b29afecbe8495514e9  133508 doc/howto/img/remote-development-new-workspace-button.png
   100644 blob cde4360b3d3ee4f4c04c998d43cfaaf586f09740  214231 doc/howto/img/dependency_proxy_macos_config_new.png
   100644 blob 2ad0e839a709e73a6174e78321e87021b20be445  216452 doc/howto/img/gdk-in-gitpod.jpg
   100644 blob 115dd03fc0828a9011f012abbc58746f7c587a05  242304 doc/howto/img/gitpod-button-repository.jpg
   100644 blob c41ebb321a6a99f68ee6c353dd0ed29f52c1dc80  491158 doc/howto/img/dependency_proxy_macos_config.png
   ```

   输出中的第三列是 blob 的对象 ID。例如：`8150ee86f923548d376459b29afecbe8495514e9`。

<a id="redact-text-from-repository"></a>

### 从代码仓库中遮盖文本

永久删除意外提交的敏感或机密信息，确保其在代码仓库历史中不再可访问。将字符串列表替换为 `***REMOVED***`。

> [!warning]
> 此操作不可逆。重写历史并运行内务处理后，更改将永久生效。

在极狐GitLab 中遮盖文件虽然可以移除已泄露的密钥，但也会：

- 重写 Git 历史。基于旧提交历史的历史标签和分支可能无法正常工作。
- 具有破坏性。现有的本地克隆与更新后的代码仓库不兼容，必须重新克隆。
- 更新提交哈希，因为遮盖会更新其内容。
- 在重写过程中丢弃提交签名。
- 破坏依赖提交哈希的功能，包括：
  - 打开的合并请求。打开的合并请求可能无法合并，需要手动变基。
  - 指向先前提交的链接，这会导致 404 错误。
- 可能破坏引用旧提交 SHA 的流水线，需要重新配置。

为了更好地保持代码仓库完整性，您应该改为：

- 撤销或轮换已泄露的密钥。
- 实施[极狐GitLab 的密钥检测功能](../../application_security/secret_detection/_index.md)。

此方法：

- 主动防止未来的密钥泄露。
- 在确保安全合规的同时维护 Git 历史。

有关更多信息，请参阅[密钥推送保护](../../application_security/secret_detection/secret_push_protection/_index.md)。

或者，要从代码仓库中完全删除特定文件，请参阅
[移除 blob](#remove-blobs)。

先决条件：

- 您必须拥有项目的所有者角色。

从代码仓库中遮盖文本：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**代码仓库维护**。
1. 选择**遮盖文本**。
1. 在抽屉中，输入要遮盖的文本。接受正则表达式和 glob 模式。
1. 选择**遮盖匹配的字符串**。
1. 在确认对话框中，输入您的项目路径。
1. 选择**是，遮盖匹配的字符串**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**高级**。
1. 选择**运行内务处理**。等待至少 30 分钟以完成操作。
1. 在同一个**设置** > **通用** > **高级**部分中，选择**清理不可达对象**。
   此操作大约需要 5-10 分钟完成。

> [!note]
> 如果包含敏感信息的项目已被 forked，内务处理任务可能无法完成此遮盖过程，以维护特殊对象池代码仓库
> [（其中包含 forked 数据）](../../../administration/housekeeping.md#object-pool-repositories)的完整性。
> 如需帮助，请联系极狐GitLab 支持。

<a id="troubleshooting"></a>

## 故障排除

以下各节提供了您可能遇到的问题的解决方案。

<a id="incorrect-repository-statistics-shown-in-the-gui"></a>

### GUI 中显示的代码仓库统计信息不正确

如果极狐GitLab 界面中显示的代码仓库大小或提交数量与导出的 `.tar.gz` 或本地代码仓库不一致：

1. 请极狐GitLab 管理员使用 Rails 控制台强制更新。
1. 管理员应运行以下命令：

   ```ruby
   p = Project.find_by_full_path('<namespace>/<project>')
   p.statistics.refresh!
   ```

1. 清除项目统计信息并触发重新计算：

   ```ruby
   p.repository.expire_all_method_caches
   UpdateProjectStatisticsWorker.perform_async(p.id, ["commit_count","repository_size","storage_size","lfs_objects_size","container_registry_size"])
   ```

1. 检查产物存储总空间：

   ```ruby
   builds_with_artifacts = p.builds.with_downloadable_artifacts.all

   artifact_storage = 0
   builds_with_artifacts.find_each do |build|
     artifact_storage += build.artifacts_size
   end

   puts "#{artifact_storage} bytes"
   ```

<a id="space-not-being-freed-after-cleanup"></a>

### 清理后空间未释放

如果您已完成代码仓库清理过程，但存储用量保持不变：

- 请注意，不可达对象会在代码仓库中保留两周的宽限期。
- 这些对象不包含在导出中，但仍占用文件系统空间。
- 两周后，这些对象会被自动清理，从而更新存储用量统计信息。
- 要加快此过程，请让管理员运行[“清理不可达对象”内务处理任务](../../../administration/housekeeping.md)。

<a id="blobs-are-not-removed"></a>

### blob 未被移除

当 blob 成功移除时，极狐GitLab 会在项目审计日志中添加一条记录，并向发起该操作的人发送电子邮件通知。

如果 blob 移除失败，极狐GitLab 会向发起者发送一封主题为
`<project_name> | Project history rewrite failure`的电子邮件通知。邮件正文包含完整的错误消息。

可能的错误和解决方案：

- `validating object ID: invalid object ID`：对象 ID 列表包含语法错误或不正确的对象 ID。要
  解决此问题：
  1. 重新生成[对象 ID 列表](#get-a-list-of-object-ids)。
  1. 重新运行[移除 blob 步骤](#remove-blobs)。
- `source repository checksum altered`：当有人在移除 blob 过程中推送提交时会发生此错误。要
  解决此问题：
  1. 暂时阻止对代码仓库的所有推送。
  1. 重新运行[移除 blob 步骤](#remove-blobs)。
  1. 在过程成功完成后重新启用推送。

<a id="repository-size-limit-reached"></a>

### 已达到代码仓库大小限制

如果您已达到代码仓库大小限制：

- 尝试移除一些数据并创建一个新提交。
- 如果不成功，请考虑将一些 blob 移至 [Git LFS](../../../topics/git/lfs/_index.md)，或从历史中移除旧的依赖更新。
- 如果仍然无法推送更改，请联系您的极狐GitLab 管理员，暂时[提高您项目的限制](../../../administration/settings/account_and_limit_settings.md#repository-size-limit)。
- 作为最后的手段，创建一个新项目并迁移您的数据。

> [!note]
> 在新提交中删除文件不会立即减小代码仓库大小，因为较早的提交和 blob 仍然存在。
> 要有效减小大小，您必须使用 [`git filter-repo`](https://github.com/newren/git-filter-repo) 等工具重写历史。
