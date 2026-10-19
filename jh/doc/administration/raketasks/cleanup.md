---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 清理 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供用于清理极狐GitLab 实例的 Rake 任务。

<a id="remove-unreferenced-lfs-files"></a>

## 移除未引用的 LFS 文件

> [!warning]
> 请勿在极狐GitLab 升级后的 12 小时内运行此操作。这是为了确保所有后台迁移均已完成，否则可能导致数据丢失。

当您从代码仓库的历史记录中移除 LFS 文件后，它们会变成孤立文件并继续占用磁盘空间。使用此 Rake 任务，您可以从数据库中移除无效引用，从而允许对 LFS 文件进行垃圾回收。例如：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:cleanup:orphan_lfs_file_references PROJECT_PATH="gitlab-org/gitlab-foss"
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:cleanup:orphan_lfs_file_references RAILS_ENV=production PROJECT_PATH="gitlab-org/gitlab-foss"
```

{{< /tab >}}

{{< /tabs >}}

您也可以使用 `PROJECT_ID` 而非 `PROJECT_PATH` 来指定项目。

例如：

```shell
$ sudo gitlab-rake gitlab:cleanup:orphan_lfs_file_references PROJECT_ID="13083"

I, [2019-12-13T16:35:31.764962 #82356]  INFO -- :  Looking for orphan LFS files for project GitLab Org / GitLab Foss
I, [2019-12-13T16:35:31.923659 #82356]  INFO -- :  Removed invalid references: 12
```

默认情况下，此任务不会删除任何内容，只会显示它可以删除多少个文件引用。如果您确实想要删除这些引用，请使用 `DRY_RUN=false` 运行该命令。您也可以使用 `LIMIT={number}` 参数来限制删除的引用数量。

此 Rake 任务只会移除对 LFS 文件的引用。未引用的 LFS 文件会在之后被垃圾回收（每天一次）。如果您需要立即对它们进行垃圾回收，请运行下文所述的 `rake gitlab:cleanup:orphan_lfs_files`。

<a id="remove-unreferenced-lfs-files-immediately"></a>

### 立即移除未引用的 LFS 文件

未引用的 LFS 文件每天会被移除一次，但如有需要，您也可以立即移除它们。要立即移除未引用的 LFS 文件：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:cleanup:orphan_lfs_files
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:cleanup:orphan_lfs_files
```

{{< /tab >}}

{{< /tabs >}}

示例输出：

```shell
$ sudo gitlab-rake gitlab:cleanup:orphan_lfs_files
I, [2020-01-08T20:51:17.148765 #43765]  INFO -- : Removed unreferenced LFS files: 12
```

<a id="clean-up-project-upload-files"></a>

## 清理项目上传文件

如果项目上传文件不存在于极狐GitLab 数据库中，请清理它们。

<a id="clean-up-project-upload-files-from-file-system"></a>

### 从文件系统清理项目上传文件

如果本地项目上传文件不存在于极狐GitLab 数据库中，请清理它们。该任务会尝试在找到其所属项目时修复该文件，否则会将文件移动到失物招领目录。要从文件系统清理项目上传文件：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:cleanup:project_uploads
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:cleanup:project_uploads RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

示例输出：

```shell
$ sudo gitlab-rake gitlab:cleanup:project_uploads

I, [2018-07-27T12:08:27.671559 #89817]  INFO -- : Looking for orphaned project uploads to clean up. Dry run...
D, [2018-07-27T12:08:28.293568 #89817] DEBUG -- : Processing batch of 500 project upload file paths, starting with /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out
I, [2018-07-27T12:08:28.689869 #89817]  INFO -- : Can move to lost and found /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/test.out
I, [2018-07-27T12:08:28.755624 #89817]  INFO -- : Can fix /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/qux/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt
I, [2018-07-27T12:08:28.760257 #89817]  INFO -- : Can move to lost and found /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png
I, [2018-07-27T12:08:28.764470 #89817]  INFO -- : To cleanup these files run this command with DRY_RUN=false

$ sudo gitlab-rake gitlab:cleanup:project_uploads DRY_RUN=false
I, [2018-07-27T12:08:32.944414 #89936]  INFO -- : Looking for orphaned project uploads to clean up...
D, [2018-07-27T12:08:33.293568 #89817] DEBUG -- : Processing batch of 500 project upload file paths, starting with /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out
I, [2018-07-27T12:08:33.689869 #89817]  INFO -- : Did move to lost and found /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/test.out
I, [2018-07-27T12:08:33.755624 #89817]  INFO -- : Did fix /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/qux/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt
I, [2018-07-27T12:08:33.760257 #89817]  INFO -- : Did move to lost and found /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png
```

如果使用对象存储，请运行[一体化 Rake 任务](uploads/migrate.md#all-in-one-rake-task)，以确保所有上传内容都已迁移到对象存储，并且 uploads 文件夹中没有磁盘文件。

<a id="clean-up-project-upload-files-from-object-storage"></a>

### 从对象存储清理项目上传文件

如果对象存储上传文件不存在于极狐GitLab 数据库中，请将它们移动到失物招领目录。要从对象存储清理项目上传文件：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:cleanup:remote_upload_files
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:cleanup:remote_upload_files RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

示例输出：

```shell
$ sudo gitlab-rake gitlab:cleanup:remote_upload_files

I, [2018-08-02T10:26:13.995978 #45011]  INFO -- : Looking for orphaned remote uploads to remove. Dry run...
I, [2018-08-02T10:26:14.120400 #45011]  INFO -- : Can be moved to lost and found: @hashed/6b/DSC_6152.JPG
I, [2018-08-02T10:26:14.120482 #45011]  INFO -- : Can be moved to lost and found: @hashed/79/02/7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451/711491b29d3eb08837798c4909e2aa4d/DSC00314.jpg
I, [2018-08-02T10:26:14.120634 #45011]  INFO -- : To cleanup these files run this command with DRY_RUN=false
```

```shell
$ sudo gitlab-rake gitlab:cleanup:remote_upload_files DRY_RUN=false

I, [2018-08-02T10:26:47.598424 #45087]  INFO -- : Looking for orphaned remote uploads to remove...
I, [2018-08-02T10:26:47.753131 #45087]  INFO -- : Moved to lost and found: @hashed/6b/DSC_6152.JPG -> lost_and_found/@hashed/6b/DSC_6152.JPG
I, [2018-08-02T10:26:47.764356 #45087]  INFO -- : Moved to lost and found: @hashed/79/02/7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451/711491b29d3eb08837798c4909e2aa4d/DSC00314.jpg -> lost_and_found/@hashed/79/02/7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451/711491b29d3eb08837798c4909e2aa4d/DSC00314.jpg
```

<a id="remove-orphan-artifact-files"></a>

## 移除孤立的产物文件

> [!note]
> 这些命令不适用于存储在[对象存储](../object_storage.md)中的产物。

当您发现磁盘上的作业产物文件和/或目录数量超出应有数量时，可以运行：

```shell
sudo gitlab-rake gitlab:cleanup:orphan_job_artifact_files
```

此命令会：

- 扫描整个产物文件夹。
- 检查哪些文件在数据库中仍有记录。
- 如果未找到数据库记录，则从磁盘中删除该文件和目录。

默认情况下，此任务不会删除任何内容，只会显示它可以删除什么。如果您确实想要删除这些文件，请使用 `DRY_RUN=false` 运行该命令：

```shell
sudo gitlab-rake gitlab:cleanup:orphan_job_artifact_files DRY_RUN=false
```

您也可以使用 `LIMIT` 限制要删除的文件数量（默认为 `100`）：

```shell
sudo gitlab-rake gitlab:cleanup:orphan_job_artifact_files LIMIT=100
```

这最多只会从磁盘中删除 100 个文件。您可以使用此选项删除一小批文件以进行测试。

提供 `DEBUG=1` 会显示每个被检测为孤立的文件的完整路径。

如果已安装 `ionice`，该任务会使用它来确保该命令不会对磁盘造成过多负载。您可以使用 `NICENESS` 配置优先级级别。以下是有效级别，但请查阅 `man 1 ionice` 以确认。

- `0` 或 `None`
- `1` 或 `Realtime`
- `2` 或 `Best-effort`（默认）
- `3` 或 `Idle`

<a id="remove-orphaned-pool-repository-records-for-removed-storages"></a>

## 移除已删除存储的孤立池代码仓库记录

如果您从配置中永久移除某个 Gitaly 存储，该存储上对象去重池的数据库记录可能会被遗留。这些记录无法通过常规内务处理清理，因为它们引用的存储已不存在。

此 Rake 任务会删除满足以下条件的 `pool_repositories` 数据库记录：

- 位于您指定的某个存储上。
- 没有源项目。
- 未被任何项目引用。

仍被项目引用的记录绝不会被删除，而是会在任务输出中报告。

> [!warning]
> 只能传入已永久移除且数据已消失的存储。如果给定的任何存储仍存在于您当前的 Gitaly 配置中，该任务将拒绝运行。已删除的记录只能从生成的 CSV 文件中恢复。请在具有完整 Gitaly 存储配置的节点上运行此任务，例如 Rails 节点。在只有部分配置的节点上，安全检查无法检测到某个存储仍在使用中。

默认情况下，该任务以 dry-run 模式运行：它会将要删除的记录写入 `OUTPUT_FILE`中指定的 CSV 文件，而不删除任何内容。请先查看该文件：

```shell
sudo gitlab-rake gitlab:pool_repositories:cleanup_orphaned_on_missing_shards \
  SHARD_NAMES=old-storage-1,old-storage-2 OUTPUT_FILE=/tmp/orphaned_pools.csv
```

要删除记录，请再次运行命令并设置 `DRY_RUN=false`。将必需的 `DELETED_IDS_FILE` 设置为与 `OUTPUT_FILE` 不同的路径：

```shell
sudo gitlab-rake gitlab:pool_repositories:cleanup_orphaned_on_missing_shards \
  SHARD_NAMES=old-storage-1,old-storage-2 OUTPUT_FILE=/tmp/deleted_pools.csv \
  DELETED_IDS_FILE=/tmp/deleted_pool_ids.csv DRY_RUN=false
```

`OUTPUT_FILE` 是一个恢复 CSV，包含所有数据库列和分片名称。请妥善保管此文件以便恢复。该任务会在删除前将每个批次写入并刷新到 CSV，然后仅删除仍满足原始条件的已备份 ID。已备份的记录如果获得了源项目或成员项目，则可能保留下来。没有备份的新符合条件记录会等待下一次运行。

实际运行还会创建由 `DELETED_IDS_FILE` 指定的文件，这是一个审计 CSV，其中包含来自实际 `DELETE RETURNING` 结果的单个 `Pool ID` 列。此文件标识已删除的记录，而恢复 CSV 可能包含保留下来的记录。删除后但在写入审计之前发生崩溃，可能导致审计不完整。恢复数据已经写入。试运行只需要 `OUTPUT_FILE`，并且只创建恢复 CSV。

完成日志会报告恢复 CSV 中的记录总数和已删除 ID 总数。CSV 文件仅包含表头和数据，没有总计行。如果要写入的任何文件已存在，该任务将拒绝运行。每次运行请使用新的输出路径。

<a id="remove-expired-activesession-lookup-keys"></a>

## 移除过期的 ActiveSession 查找键

要移除过期的 ActiveSession 查找键：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:cleanup:sessions:active_sessions_lookup_keys
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:cleanup:sessions:active_sessions_lookup_keys RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="container-registry-garbage-collection"></a>

## 容器镜像仓库垃圾回收

容器镜像仓库可能会占用大量磁盘空间。为清理未使用的层，该镜像仓库包含一个[垃圾回收命令](../packages/container_registry.md#container-registry-garbage-collection)。
