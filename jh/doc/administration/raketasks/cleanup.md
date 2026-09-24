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

极狐GitLab 提供了清理极狐GitLab 实例的 Rake 任务。

<a id="remove-unreferenced-lfs-files"></a>

## 移除未引用的 LFS 文件

> [!warning]
> 不要在极狐GitLab 升级后的 12 小时内执行此操作。这是为了确保所有后台迁移都已完成，否则可能会导致数据丢失。

当你从仓库历史中删除 LFS 文件时，它们会变成孤儿文件并继续占用磁盘空间。使用此 Rake 任务，你可以从数据库中移除无效引用，从而允许对 LFS 文件进行垃圾回收。例如：

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

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

你还可以使用 `PROJECT_ID` 而不是 `PROJECT_PATH` 来指定项目。

例如：

```shell
$ sudo gitlab-rake gitlab:cleanup:orphan_lfs_file_references PROJECT_ID="13083"

I, [2019-12-13T16:35:31.764962 #82356]  INFO -- :  正在查找项目 极狐GitLab Org / 极狐GitLab Foss 的孤儿 LFS 文件
I, [2019-12-13T16:35:31.923659 #82356]  INFO -- :  已删除无效引用：12
```

默认情况下，此任务不会删除任何内容，但会显示它可以删除多少文件引用。如果确实要删除引用，请使用 `DRY_RUN=false` 运行该命令。你还可以使用 `LIMIT={number}` 参数来限制删除的引用数量。

此 Rake 任务仅移除对 LFS 文件的引用。未引用的 LFS 文件稍后（每天一次）被垃圾回收。如果你需要立即对其进行垃圾回收，请运行下面描述的 `rake gitlab:cleanup:orphan_lfs_files`。

<a id="remove-unreferenced-lfs-files-immediately"></a>

### 立即移除未引用的 LFS 文件

未引用的 LFS 文件每天会被删除，但如果你需要，可以立即移除它们。要立即移除未引用的 LFS 文件：

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

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
I, [2020-01-08T20:51:17.148765 #43765]  INFO -- :  已移除未引用的 LFS 文件：12
```

<a id="clean-up-project-upload-files"></a>

## 清理项目上传文件

如果项目上传文件在极狐GitLab 数据库中不存在，则清理它们。

<a id="clean-up-project-upload-files-from-file-system"></a>

### 从文件系统清理项目上传文件

如果本地项目上传文件在极狐GitLab 数据库中不存在，则清理它们。该任务会尝试修复文件（如果能找到其所属项目），否则将文件移动到失物招领目录。要从文件系统清理项目上传文件：

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

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

I, [2018-07-27T12:08:27.671559 #89817]  INFO -- :  正在查找要清理的孤立项目上传文件。试运行...
D, [2018-07-27T12:08:28.293568 #89817] DEBUG -- :  正在处理 500 个项目上传文件路径的批次，从 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out 开始
I, [2018-07-27T12:08:28.689869 #89817]  INFO -- :  可以移动到失物招领处 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/test.out
I, [2018-07-27T12:08:28.755624 #89817]  INFO -- :  可以修复 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/qux/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt
I, [2018-07-27T12:08:28.760257 #89817]  INFO -- :  可以移动到失物招领处 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png
I, [2018-07-27T12:08:28.764470 #89817]  INFO -- :  要清理这些文件，请使用 DRY_RUN=false 运行此命令

$ sudo gitlab-rake gitlab:cleanup:project_uploads DRY_RUN=false
I, [2018-07-27T12:08:32.944414 #89936]  INFO -- :  正在查找要清理的孤立项目上传文件...
D, [2018-07-27T12:08:33.293568 #89817] DEBUG -- :  正在处理 500 个项目上传文件路径的批次，从 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out 开始
I, [2018-07-27T12:08:33.689869 #89817]  INFO -- :  已移动到失物招领处 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/test.out -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/test.out
I, [2018-07-27T12:08:33.755624 #89817]  INFO -- :  已修复 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/qux/foo/bar/89a0f7b0b97008a4a18cedccfdcd93fb/foo.txt
I, [2018-07-27T12:08:33.760257 #89817]  INFO -- :  已移动到失物招领处 /opt/gitlab/embedded/service/gitlab-rails/public/uploads/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png -> /opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/project-lost-found/foo/bar/1dd6f0f7eefd2acc4c2233f89a0f7b0b/image.png
```

如果使用对象存储，运行[一体化 Rake 任务](uploads/migrate.md#all-in-one-rake-task)以确保所有上传文件已迁移到对象存储，并且上传文件夹中没有磁盘上的文件。

<a id="clean-up-project-upload-files-from-object-storage"></a>

### 从对象存储清理项目上传文件

如果对象存储中的上传文件在极狐GitLab 数据库中不存在，则将其移动到失物招领目录。要从对象存储清理项目上传文件：

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

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

I, [2018-08-02T10:26:13.995978 #45011]  INFO -- :  正在查找要移除的孤立远程上传文件。试运行...
I, [2018-08-02T10:26:14.120400 #45011]  INFO -- :  可以移动到失物招领处：@hashed/6b/DSC_6152.JPG
I, [2018-08-02T10:26:14.120482 #45011]  INFO -- :  可以移动到失物招领处：@hashed/79/02/7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451/711491b29d3eb08837798c4909e2aa4d/DSC00314.jpg
I, [2018-08-02T10:26:14.120634 #45011]  INFO -- :  要清理这些文件，请使用 DRY_RUN=false 运行此命令
```

```shell
$ sudo gitlab-rake gitlab:cleanup:remote_upload_files DRY_RUN=false

I, [2018-08-02T10:26:47.598424 #45087]  INFO -- :  正在查找要移除的孤立远程上传文件...
I, [2018-08-02T10:26:47.753131 #45087]  INFO -- :  已移动到失物招领处：@hashed/6b/DSC_6152.JPG -> lost_and_found/@hashed/6b/DSC_6152.JPG
I, [2018-08-02T10:26:47.764356 #45087]  INFO -- :  已移动到失物招领处：@hashed/79/02/7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451/711491b29d3eb08837798c4909e2aa4d/DSC00314.jpg -> lost_and_found/@hashed/79/02/7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451/711491b29d3eb08837798c4909e2aa4d/DSC00314.jpg
```

<a id="remove-orphan-artifact-files"></a>

## 移除孤立产物文件

> [!note]
> 这些命令不适用于存储在[对象存储](../object_storage.md)上的产物。

当你发现磁盘上的产物文件或目录比应有的多时，可以运行：

```shell
sudo gitlab-rake gitlab:cleanup:orphan_job_artifact_files
```

该命令：
- 扫描整个产物文件夹。
- 检查哪些文件在数据库中仍有记录。
- 如果找不到数据库记录，文件及目录将从磁盘中删除。

默认情况下，此任务不会删除任何内容，但会显示它可以删除什么。如果确实要删除文件，请使用 `DRY_RUN=false` 运行该命令：

```shell
sudo gitlab-rake gitlab:cleanup:orphan_job_artifact_files DRY_RUN=false
```

你还可以使用 `LIMIT` 限制要删除的文件数量（默认为 `100`）：

```shell
sudo gitlab-rake gitlab:cleanup:orphan_job_artifact_files LIMIT=100
```

这仅从磁盘中最多删除 100 个文件。你可以使用此方法删除一小部分以进行测试。

提供 `DEBUG=1` 将显示每个被检测为孤立文件的完整路径。

如果安装了 `ionice`，该任务将使用它来确保命令不会对磁盘造成过多负载。你可以使用 `NICENESS` 配置优先级级别。以下是有效级别，但请查阅 `man 1 ionice` 以确认。

- `0` 或 `None`
- `1` 或 `Realtime`
- `2` 或 `Best-effort`（默认）
- `3` 或 `Idle`

<a id="remove-expired-activesession-lookup-keys"></a>

## 移除过期的 ActiveSession 查找键

要移除过期的 ActiveSession 查找键：

{{< tabs >}}

{{< tab title="Linux 安装包（Omnibus）" >}}

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

容器镜像仓库可能占用大量磁盘空间。为了清理未使用的层，该仓库包含一个[垃圾回收命令](../packages/container_registry.md#container-registry-garbage-collection)。

</output>