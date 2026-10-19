---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 备份极狐GitLab
description: 备份您的极狐GitLab 私有化部署实例。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 备份可保护您的数据，并有助于灾难恢复。

最佳备份策略取决于您的极狐GitLab 部署配置、数据量和存储位置。这些因素决定了要使用哪些备份方法、将备份存储在何处，以及如何安排备份计划。

对于规模较大的极狐GitLab 实例，替代备份策略包括：

- 增量备份。
- 特定代码仓库的备份。
- 跨多个存储位置的备份。

<a id="data-included-in-a-backup"></a>

## 备份中包含的数据

极狐GitLab 提供命令行界面来备份您的整个实例。默认情况下，备份会创建一个压缩的 tar 文件归档。该文件包含：

- 数据库数据和配置
- 账号和群组设置
- CI/CD 产物和作业日志
- Git 代码仓库和 LFS 对象
- 外部合并请求差异
- 软件包仓库数据和容器镜像仓库镜像
- 项目和群组 Wiki
- 项目级附件和上传文件
- 安全文件
- GitLab Pages 内容
- Terraform 状态
- 代码片段

<a id="data-not-included-in-a-backup"></a>

## 备份中不包含的数据

> [!warning]
> 强烈建议您阅读[存储配置文件](#storing-configuration-files)，以便单独备份这些文件。

- Redis（以及因此产生的 Sidekiq 作业）
- Linux 软件包（Omnibus）/ Docker / 自编译安装中的[对象存储](#object-storage)
- [全局服务器钩子](../server_hooks.md#create-global-server-hooks-for-all-repositories)
- [文件钩子](../file_hooks.md)
- 极狐GitLab 配置文件（`/etc/gitlab`）
- TLS 和 SSH 相关的密钥与证书
- 其他系统文件

<a id="simple-backup-procedure"></a>

## 简单备份流程

对于 PostgreSQL 数据库小于 100 GB，且备份命令对您的代码仓库数据仍然实用的极狐GitLab 环境，请按以下步骤操作：

1. 运行备份命令。
1. 如适用，备份对象存储。
1. 手动备份系统配置文件。

另请参阅：

- [备份命令详情](#backup-command)
- [对象存储配置](#object-storage)
- [配置文件指南](#storing-configuration-files)

<a id="scaling-backups"></a>

## 扩展备份

随着极狐GitLab 数据量的增长，备份命令的执行时间会变长。诸如并发备份 Git 代码仓库和增量代码仓库备份等备份选项，有助于缩短执行时间。到某个程度后，备份命令本身会变得不实用。例如，它可能需要 24 小时或更长时间。

从极狐GitLab 18.0 开始，对于包含大量引用（分支、标签）的代码仓库，代码仓库备份性能已显著提升。对于受影响的代码仓库，此改进可将备份时间从数小时缩短至数分钟。无需更改配置即可受益于此增强功能。

在某些情况下，可能需要调整架构以使备份能够扩展。

延伸阅读：

- [增量代码仓库备份](#incremental-repository-backups)。
- [并发备份 Git 代码仓库](#back-up-git-repositories-concurrently)。
- [备份和恢复大型极狐GitLab 环境](backup_large_reference_architectures.md)。
- [替代备份策略](#alternative-backup-strategies)。
- [关于缩短极狐GitLab 代码仓库备份时间的博客文章](https://about.gitlab.com/blog/how-we-decreased-gitlab-repo-backup-times-from-48-hours-to-41-minutes/)。

<a id="what-data-needs-to-be-backed-up"></a>

## 哪些数据需要备份？

以下数据需要备份。

<a id="postgresql-databases"></a>

### PostgreSQL 数据库

在最简单的情况下，极狐GitLab 在与所有其他极狐GitLab 服务相同的虚拟机上，有一个 PostgreSQL 服务器中的一个 PostgreSQL 数据库。但根据配置不同，极狐GitLab 可能在多个 PostgreSQL 服务器中使用多个 PostgreSQL 数据库。

一般来说，这些数据是 Web 界面中大多数用户生成内容的唯一事实来源，例如议题和合并请求内容、评论、权限和凭据。

PostgreSQL 还保存一些缓存数据，例如渲染为 HTML 的 Markdown，以及默认情况下的合并请求差异。不过，合并请求差异也可以配置为[卸载](#blobs)到文件系统或对象存储。

Gitaly 集群 (Praefect) 使用 PostgreSQL 数据库作为唯一事实来源来管理其 Gitaly 节点。

常用的 PostgreSQL 工具 [`pg_dump`](https://www.postgresql.org/docs/16/app-pgdump.html) 会生成一个备份文件，可用于恢复 PostgreSQL 数据库。[备份命令](#backup-command)在底层使用该工具。

遗憾的是，数据库越大，`pg_dump` 执行所需的时间就越长。根据您的具体情况，到某个程度后（例如数天），其耗时将变得不实用。如果您的数据库超过 100 GB，`pg_dump` 以及由此延伸的[备份命令](#backup-command)很可能无法使用。更多信息，请参阅[替代备份策略](#alternative-backup-strategies)。

<a id="git-repositories"></a>

### Git 代码仓库

一个极狐GitLab 实例可以有一个或多个代码仓库分片。每个分片是一个 Gitaly 实例或 Gitaly 集群 (Praefect)，负责允许对本地存储的 Git 代码仓库进行访问和操作。Gitaly 可以运行在具有以下配置的机器上：

- 单块磁盘。
- 多块磁盘挂载为单个挂载点（例如使用 RAID 阵列）。
- 使用 LVM。

每个项目最多可以有 3 个不同的代码仓库：

- 项目代码仓库，用于存储源代码。
- Wiki 代码仓库，用于存储 Wiki 内容。
- 设计代码仓库，用于索引设计产物（资源实际存储在 LFS 中）。

它们都位于同一分片中，并共享相同的基础名称，对于 Wiki 和设计代码仓库的情况，分别带有`-wiki` 和`-design` 后缀。

个人和项目代码片段以及群组 Wiki 内容存储在 Git 代码仓库中。

项目复刻在极狐GitLab 站点中使用池代码仓库进行去重。

备份命令会为每个代码仓库生成一个 Git bundle，并将它们全部打包成 tar。这会将池代码仓库数据复制到每个复刻中。在我们的测试中，100 GB 的 Git 代码仓库备份并上传到 S3 花费了两个多小时。当 Git 数据达到约 400 GB 时，备份命令很可能无法用于常规备份。更多信息，请参阅[替代备份策略](#alternative-backup-strategies)。

<a id="blobs"></a>

### Blob

极狐GitLab 将 Blob（或文件，例如议题附件或 LFS 对象）存储在以下位置之一：

- 文件系统中的特定位置。
- [对象存储](../object_storage.md)解决方案。对象存储解决方案可以是：
  - 基于云的，如 Amazon S3 和 Google Cloud Storage。
  - 自托管的 S3 兼容对象存储。
  - 提供对象存储兼容 API 的存储设备。

<a id="object-storage"></a>

#### 对象存储

备份命令不会备份未存储在文件系统上的 Blob。如果您使用对象存储，请务必通过您的对象存储提供商启用备份。

特定提供商的备份指南：

- [Amazon S3 备份](https://docs.aws.amazon.com/aws-backup/latest/devguide/s3-backups.html)
- [Google Cloud Storage Transfer Service](https://cloud.google.com/storage-transfer-service)
- [Google Cloud Storage 对象版本控制](https://docs.cloud.google.com/storage/docs/object-versioning)

另请参阅：

- [备份命令详情](#backup-command)
- [对象存储配置](../object_storage.md)

<a id="container-registry"></a>

### 容器镜像仓库

极狐GitLab 容器镜像仓库存储可以配置在以下位置之一：

- 文件系统中的特定位置。
- 对象存储解决方案。对象存储解决方案可以是：
  - 基于云的，如 Amazon S3 和 Google Cloud Storage。
  - 自托管的 S3 兼容对象存储。
  - 提供对象存储兼容 API 的存储设备。

当镜像仓库数据存储在对象存储中时，备份命令不会备份这些数据。

<a id="metadata-database"></a>

#### 元数据数据库

如果您已启用[容器镜像仓库元数据数据库](https://gitlab.cn/docs/charts/charts/registry/metadata_database/)，则必须在备份期间配置对镜像仓库数据库的访问。请按照您的极狐GitLab 安装说明配置所需的凭据：

- [Linux 软件包安装说明](https://gitlab.cn/docs/omnibus/settings/backups/#container-registry-metadata-database-backup-credentials)
- [GitLab Helm chart](https://gitlab.cn/docs/charts/charts/gitlab/toolbox/#registry-metadata-database-credentials)

另请参阅：

- [极狐GitLab 容器镜像仓库](../packages/container_registry.md)
- [对象存储配置](../object_storage.md)

<a id="storing-configuration-files"></a>

### 存储配置文件

> [!warning]
> 极狐GitLab 提供的备份 Rake 任务不会存储您的配置文件。
> 主要原因在于，您的数据库包含用于双重身份验证和 CI/CD 安全变量的加密信息等项目。将加密信息
> 与其密钥存储在同一位置，从一开始就违背了使用加密的目的。
> 例如，密钥文件包含您的数据库加密密钥。如果您丢失了它，
> 那么极狐GitLab 应用将无法解密数据库中的任何加密值。
>
> 此外，密钥文件可能会在升级后发生变化。

您应该备份配置目录。至少，您必须备份：

{{< tabs >}}

{{< tab title="Linux 软件包" >}}

- `/etc/gitlab/gitlab-secrets.json`
- `/etc/gitlab/gitlab.rb`

更多信息，请参阅[备份和恢复 Linux 软件包（Omnibus）配置](https://gitlab.cn/docs/omnibus/settings/backups/#backup-and-restore-omnibus-gitlab-configuration)。

{{< /tab >}}

{{< tab title="自行编译" >}}

- `/home/git/gitlab/config/secrets.yml`
- `/home/git/gitlab/config/gitlab.yml`

{{< /tab >}}

{{< tab title="Docker" >}}

- 备份存储配置文件的卷。如果您按照文档创建了
  极狐GitLab 容器，它应该位于
  `/srv/gitlab/config` 目录中。

{{< /tab >}}

{{< tab title="GitLab Helm chart" >}}

- 按照[备份密钥](https://gitlab.cn/docs/charts/backup-restore/backup/#back-up-the-secrets)
  说明操作。

{{< /tab >}}

{{< /tabs >}}

您可能还希望备份任何 TLS 密钥和证书（`/etc/gitlab/ssl`、`/etc/gitlab/trusted-certs`），以及您的 [SSH 主机密钥](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079)，以便在必须执行整机恢复时避免中间人攻击警告。

如果密钥文件丢失（这种情况不太可能发生），请参阅
[当密钥文件丢失时](troubleshooting_backup_gitlab.md#when-the-secrets-file-is-lost)。

<a id="other-data"></a>

### 其他数据

极狐GitLab 将 Redis 同时用作缓存存储，以及保存后台作业系统 Sidekiq 的持久数据。所提供的备份命令不会备份 Redis 数据。这意味着，要使用备份命令进行一致的备份，必须没有待处理或正在运行的后台作业。

Elasticsearch 是用于高级搜索的可选数据库。它可以在源代码级别以及议题、合并请求和讨论中的用户生成内容中改进搜索。备份命令不会备份 Elasticsearch 数据。Elasticsearch 数据可以在恢复后从 PostgreSQL 数据重新生成。

手动备份选项：

- [Redis 备份流程](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/#backing-up-redis-data)
- [Elasticsearch 备份流程](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshot-restore.html)

另请参阅：[备份命令详情](#backup-command)。

<a id="requirements"></a>

### 要求

为了能够备份和恢复，请确保您的系统上已安装 Rsync。如果您通过以下方式安装极狐GitLab：

- 使用 Linux 软件包，则已安装 Rsync。
- 使用自编译方式，请检查是否已安装 `rsync`，如果未安装则安装它。

<a id="backup-command"></a>

### 备份命令

- 备份命令不会备份 Linux 软件包（Omnibus）/ Docker / 自编译安装中对象存储里的项目。
- 当您的安装使用 PgBouncer 时（无论是出于性能原因，还是与 Patroni 集群一起使用），备份命令需要额外的参数。
- 您只能将备份恢复到创建它时完全相同版本和类型（基础版/企业版）的极狐GitLab。

**重要注意事项：**

- [对象存储限制](#object-storage)
- [PgBouncer 配置要求](#back-up-and-restore-for-installations-using-pgbouncer)

要创建备份：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

使用 `kubectl` 在 GitLab toolbox pod 上运行 `backup-utility` 脚本来运行备份任务。更多详情，请参阅 [charts 备份文档](https://gitlab.cn/docs/charts/backup-restore/backup/)。

{{< /tab >}}

{{< tab title="Docker" >}}

从主机运行备份。

```shell
docker exec -t <container name> gitlab-backup create
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

如果您的极狐GitLab 部署有多个节点，您需要选择一个节点来运行备份命令。您必须确保指定的节点：

- 是持久性的，且不受自动扩缩影响。
- 已安装 GitLab Rails 应用。如果 Puma 或 Sidekiq 正在运行，则说明 Rails 已安装。
- 有足够的存储空间和内存来生成备份文件。

示例输出：

```plaintext
Dumping database tables:
- Dumping table events... [DONE]
- Dumping table issues... [DONE]
- Dumping table keys... [DONE]
- Dumping table merge_requests... [DONE]
- Dumping table milestones... [DONE]
- Dumping table namespaces... [DONE]
- Dumping table notes... [DONE]
- Dumping table projects... [DONE]
- Dumping table protected_branches... [DONE]
- Dumping table schema_migrations... [DONE]
- Dumping table services... [DONE]
- Dumping table snippets... [DONE]
- Dumping table taggings... [DONE]
- Dumping table tags... [DONE]
- Dumping table users... [DONE]
- Dumping table users_projects... [DONE]
- Dumping table web_hooks... [DONE]
- Dumping table wikis... [DONE]
Dumping repositories:
- Dumping repository abcd... [DONE]
Creating backup archive: <backup-id>_gitlab_backup.tar [DONE]
Deleting tmp directories...[DONE]
Deleting old backups... [SKIPPING]
```

有关备份流程的详细信息，请参阅[备份归档流程](backup_archive_process.md)。

<a id="backup-options"></a>

### 备份选项

极狐GitLab 提供的用于备份实例的命令行工具可以接受更多选项。

<a id="backup-strategy-option"></a>

#### 备份策略选项

默认备份策略本质上是使用 Linux 命令 `tar` 和 `gzip` 将数据从各自的数据位置流式传输到备份中。这在大多数情况下都能正常工作，但当数据快速变化时可能会出现问题。

当 `tar` 读取数据时数据发生变化，可能会出现 `file changed as we read it` 错误，并导致备份过程失败。在这种情况下，您可以使用名为 `copy`的备份策略。该策略会在调用 `tar` 和 `gzip` 之前将数据文件复制到临时位置，从而避免该错误。

一个副作用是备份过程最多会额外占用 1 倍的磁盘空间。该过程会尽最大努力在每个阶段清理临时文件，以免问题累积，但对于大型安装来说，这可能是一个相当大的变化。

要使用 `copy` 策略而非默认的流式策略，请在 Rake 任务命令中指定 `STRATEGY=copy`。例如：

```shell
sudo gitlab-backup create STRATEGY=copy
```

<a id="backup-filename"></a>

#### 备份文件名

> [!warning]
> 如果您使用自定义备份文件名，则无法
> [限制备份的生命周期](#limit-backup-lifetime-for-local-files-prune-old-backups)。

备份文件按照[特定默认值](backup_archive_process.md#backup-id)创建文件名。不过，您可以通过设置 `BACKUP` 环境变量来覆盖文件名中的`<backup-id>`部分。例如：

```shell
sudo gitlab-backup create BACKUP=dump
```

生成的文件名为 `dump_gitlab_backup.tar`。这对于使用 rsync 和增量备份的系统很有用，并且可以显著提高传输速度。

<a id="backup-compression"></a>

#### 备份压缩

默认情况下，在备份以下内容时会应用 Gzip 快速压缩：

- PostgreSQL 数据库转储。
- Blob，例如上传文件、作业产物、外部合并请求差异。

另请参阅：

- [PostgreSQL 数据库](#postgresql-databases)
- [Blob](#blobs)

默认命令是 `gzip -c -1`。您可以使用 `COMPRESS_CMD` 覆盖此命令。同样，您可以使用 `DECOMPRESS_CMD` 覆盖解压缩命令。

注意事项：

- 压缩命令在流水线中使用，因此您的自定义命令必须输出到 `stdout`。
- 如果您指定的命令未随极狐GitLab 打包，则必须自行安装它。
- 生成的文件名仍将以`.gz` 结尾。
- 恢复期间使用的默认解压缩命令是 `gzip -cd`。因此，如果您将压缩命令覆盖为 `gzip -cd` 无法解压缩的格式，则必须在恢复期间覆盖解压缩命令。
- 不要在备份命令之后放置环境变量。例如，`gitlab-backup create COMPRESS_CMD="pigz -c --best"`不会按预期工作。

<a id="default-compression-gzip-with-fastest-method"></a>

##### 默认压缩：使用最快方法的 Gzip

```shell
gitlab-backup create
```

<a id="gzip-with-slowest-method"></a>

##### 使用最慢方法的 Gzip

```shell
COMPRESS_CMD="gzip -c --best" gitlab-backup create
```

如果备份时使用了 `gzip`，则恢复不需要任何选项：

```shell
gitlab-backup restore
```

<a id="no-compression"></a>

##### 不压缩

如果您的备份目标具有内置的自动压缩功能，那么您可能希望跳过压缩。

`tee` 命令将 `stdin` 管道传输到 `stdout`。

```shell
COMPRESS_CMD=tee gitlab-backup create
```

恢复时：

```shell
DECOMPRESS_CMD=tee gitlab-backup restore
```

<a id="parallel-compression-with-pigz"></a>

##### 使用 `pigz` 进行并行压缩

> [!warning]
> 虽然我们支持使用 `COMPRESS_CMD` 和 `DECOMPRESS_CMD` 来覆盖默认的 Gzip 压缩库，但我们只例行测试使用默认选项的默认 Gzip 库。您有责任测试和验证备份的可行性。无论是否覆盖压缩命令，我们通常都强烈建议将其作为备份的最佳实践。如果您在使用其他压缩库时遇到问题，应回退到默认设置。使用替代库进行故障排除和修复错误对极狐GitLab 来说是较低优先级的事项。

使用 4 个进程通过 `pigz` 压缩备份的示例：

```shell
sudo COMPRESS_CMD="pigz --stdout --fast --processes 4" gitlab-backup create
```

由于 `pigz` 压缩为 `gzip` 格式，因此不需要使用 `pigz` 来解压缩由 `pigz` 压缩的备份。不过，它相比 `gzip` 仍可能有性能优势。使用 `pigz` 解压缩备份的示例：

```shell
sudo DECOMPRESS_CMD="pigz --decompress --stdout" gitlab-backup restore
```

> [!note]
> `pigz` 不包含在极狐GitLab Linux 软件包中。您必须自行安装它。

<a id="parallel-compression-with-zstd"></a>

##### 使用 `zstd` 进行并行压缩

> [!warning]
> 虽然我们支持使用 `COMPRESS_CMD` 和 `DECOMPRESS_CMD` 来覆盖默认的 Gzip 压缩库，但我们只例行测试使用默认选项的默认 Gzip 库。您有责任测试和验证备份的可行性。无论是否覆盖压缩命令，我们通常都强烈建议将其作为备份的最佳实践。如果您在使用其他压缩库时遇到问题，应回退到默认设置。使用替代库进行故障排除和修复错误对极狐GitLab 来说是较低优先级的事项。

使用 4 个线程通过 `zstd` 压缩备份的示例：

```shell
sudo COMPRESS_CMD="zstd --compress --stdout --fast --threads=4" gitlab-backup create
```

使用 `zstd` 解压缩备份的示例：

```shell
sudo DECOMPRESS_CMD="zstd --decompress --stdout" gitlab-backup restore
```

> [!note]
> `zstd` 不包含在极狐GitLab Linux 软件包中。您必须自行安装它。

<a id="confirm-archive-can-be-transferred"></a>

#### 确认归档可以传输

为确保生成的归档可以通过 rsync 传输，您可以设置 `GZIP_RSYNCABLE=yes` 选项。这会将`--rsyncable` 选项设置给 `gzip`，仅在结合设置[备份文件名选项](#backup-filename)时有用。

`gzip`中的`--rsyncable` 选项并不保证在所有发行版上都可用。要验证它在您的发行版中是否可用，请运行 `gzip --help` 或查阅手册页。

```shell
sudo gitlab-backup create BACKUP=dump GZIP_RSYNCABLE=yes
```

<a id="excluding-specific-data-from-the-backup"></a>

#### 从备份中排除特定数据

根据您的安装类型，在创建备份时可以跳过略有不同的组件。

{{< tabs >}}

{{< tab title="Linux package (Omnibus) / Docker / Self-compiled" >}}

<!-- source: <https://gitlab.com/gitlab-org/gitlab/-/blob/d693aa7f894c7306a0d20ab6d138a7b95785f2ff/lib/backup/manager.rb#L117-133> -->

- `db`（数据库）
- `repositories`（Git 代码仓库数据，包括 Wiki）
- `uploads`（附件）
- `builds`（CI 作业输出日志）
- `artifacts`（CI 作业产物）
- `pages`（Pages 内容）
- `lfs`（LFS 对象）
- `terraform_state`（Terraform 状态）
- `registry`（容器镜像仓库镜像）
- `packages`（软件包）
- `ci_secure_files`（项目级安全文件）
- `agent_plan_content`（工作项的 Agent 计划内容）
- `ci_catalog_bundles`（CI 目录组件包）
- `external_diffs`（外部合并请求差异）

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

<!-- source: <https://gitlab.com/gitlab-org/build/CNG/-/blob/f65c53cbadfd5d123a4ddeaed297eb2a2034a5cd/gitlab-toolbox/scripts/bin/backup-utility#L19> -->

- `db`（数据库）
- `repositories`（Git 代码仓库数据，包括 Wiki）
- `uploads`（附件）
- `artifacts`（CI 作业产物和输出日志）
- `pages`（Pages 内容）
- `lfs`（LFS 对象）
- `terraform_state`（Terraform 状态）
- `registry`（容器镜像仓库镜像）
- `packages`（软件包仓库）
- `ci_secure_files`（项目级安全文件）
- `agent_plan_content`（工作项的 Agent 计划内容）
- `ci_catalog_bundles`（CI 目录组件包）
- `external_diffs`（合并请求差异）

{{< /tab >}}

{{< /tabs >}}

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create SKIP=db,uploads
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

请参阅 charts 备份文档中的[跳过组件](https://gitlab.cn/docs/charts/backup-restore/backup/#skipping-components)。

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create SKIP=db,uploads RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

`SKIP=`还用于：

- [跳过 tar 文件的创建](#skipping-tar-creation)（`SKIP=tar`）。
- [跳过将备份上传到远程存储](#skip-uploading-backups-to-remote-storage)（`SKIP=remote`）。

<a id="skipping-tar-creation"></a>

#### 跳过 tar 创建

> [!note]
> 当使用[对象存储](#upload-backups-to-a-remote-cloud-storage)进行备份时，无法跳过 tar 创建。

创建备份的最后一步是生成包含所有部分的`.tar` 文件。在某些情况下，创建`.tar` 文件可能是白费力气，甚至直接有害，因此您可以通过将 `tar` 添加到 `SKIP` 环境变量来跳过此步骤。示例用例：

- 当备份被其他备份软件接管时。
- 通过避免每次都必须解压备份来加速增量备份。（在这种情况下，不得指定 `PREVIOUS_BACKUP` 和 `BACKUP`，否则会解压指定的备份，但最后不会生成`.tar` 文件。）

将 `tar` 添加到 `SKIP` 变量会使包含备份的文件和目录保留在用于中间文件的目录中。这些文件在创建新备份时会被覆盖，因此您应确保将它们复制到其他地方，因为系统上只能有一个备份。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create SKIP=tar
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create SKIP=tar RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="create-server-side-repository-backups"></a>

#### 创建服务器端代码仓库备份

与其将大型代码仓库备份存储在备份归档中，不如将代码仓库备份配置为：托管每个代码仓库的 Gitaly 节点负责创建备份并将其流式传输到对象存储。这有助于减少创建和恢复备份所需的网络资源。

1. [在 Gitaly 中配置服务器端备份目标](../gitaly/configure_gitaly.md#configure-server-side-backups)。
1. 使用代码仓库服务器端选项创建备份。请参阅以下示例。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create REPOSITORIES_SERVER_SIDE=true
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create REPOSITORIES_SERVER_SIDE=true
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

```shell
kubectl exec <Toolbox pod name> -it -- backup-utility --repositories-server-side
```

当您使用[基于 cron 的备份](https://gitlab.cn/docs/charts/backup-restore/backup/#cron-based-backup)时，请将`--repositories-server-side` 标志添加到额外参数中。

{{< /tab >}}

{{< /tabs >}}

<a id="back-up-git-repositories-concurrently"></a>

#### 并发备份 Git 代码仓库

当使用[多个代码仓库存储](../repository_storage_paths.md)时，可以并发备份或恢复代码仓库，以帮助充分利用 CPU 时间。以下变量可用于修改 Rake 任务的默认行为：

- `GITLAB_BACKUP_MAX_CONCURRENCY`：同时备份的最大项目数。默认为逻辑 CPU 数量。
- `GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY`：每个存储上同时备份的最大项目数。这允许代码仓库备份分散到各个存储上。默认为 `2`。

例如，有 4 个代码仓库存储时：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create GITLAB_BACKUP_MAX_CONCURRENCY=4 GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY=1
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create GITLAB_BACKUP_MAX_CONCURRENCY=4 GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY=1
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

```yaml
toolbox:
#...
    extra: {}
    extraEnv:
      GITLAB_BACKUP_MAX_CONCURRENCY: 4
      GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY: 1

```

{{< /tab >}}

{{< /tabs >}}

<a id="incremental-repository-backups"></a>

#### 增量代码仓库备份

> [!note]
> 只有代码仓库支持增量备份。因此，如果您使用 `INCREMENTAL=yes`，该任务
> 会创建一个自包含的备份 tar 归档。这是因为除代码仓库外的所有子任务
> 仍在创建完整备份（它们会覆盖现有的完整备份）。
> 有关支持所有子任务增量备份的功能请求，请参阅[议题 19256](https://gitlab.com/gitlab-org/gitlab/-/issues/19256)。

增量代码仓库备份可能比完整代码仓库备份更快，因为它们只将自上次备份以来的更改打包到每个代码仓库的备份包中。`gitlab-backup` 生成的备份归档是可移植且自包含的，因为它们包含从原始完整备份开始恢复每个代码仓库所需的所有步骤。

要将增量备份恢复到新的极狐GitLab 实例（没有预先存在的数据），您必须从完整备份创建增量备份。创建基础备份时不要跳过任何备份组件。

使用服务器端代码仓库备份时，增量代码仓库备份文件会单独存储在对象存储中。每个增量都依赖于回溯到原始完整备份的所有先前步骤。

> [!warning]
> 不要从对象存储中删除增量备份文件。如果中间文件被删除（例如，通过对象存储生命周期策略），备份链就会中断，备份将无法恢复。

更多详情，请参阅[恢复增量代码仓库备份](restore_gitlab.md#restoring-an-incremental-repository-backup)。

使用 `PREVIOUS_BACKUP=<backup-id>`选项来选择要使用的备份。默认情况下，备份文件按照[备份 ID](backup_archive_process.md#backup-id) 部分所述创建。您可以通过设置 [`BACKUP` 环境变量](#backup-filename)来覆盖文件名中的`<backup-id>`部分。

要创建增量备份，请运行：

```shell
sudo gitlab-backup create INCREMENTAL=yes PREVIOUS_BACKUP=<backup-id>
```

要从已打包的备份创建[未打包](#skipping-tar-creation)的增量备份，请使用 `SKIP=tar`：

```shell
sudo gitlab-backup create INCREMENTAL=yes SKIP=tar
```

<a id="back-up-specific-repository-storages"></a>

#### 备份特定代码仓库存储

当使用[多个代码仓库存储](../repository_storage_paths.md)时，可以使用 `REPOSITORIES_STORAGES` 选项单独备份特定代码仓库存储中的代码仓库。该选项接受以逗号分隔的存储名称列表。

例如：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create REPOSITORIES_STORAGES=storage1,storage2
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create REPOSITORIES_STORAGES=storage1,storage2
```

{{< /tab >}}

{{< /tabs >}}

<a id="back-up-specific-repositories"></a>

#### 备份特定代码仓库

您可以使用 `REPOSITORIES_PATHS` 选项备份特定代码仓库。同样，您可以使用 `SKIP_REPOSITORIES_PATHS` 跳过某些代码仓库。这两个选项都接受以逗号分隔的项目或群组路径列表。如果您指定群组路径，则该群组及后代群组中所有项目的所有代码仓库都会被包含或跳过，具体取决于您使用的选项。

例如，要备份群组 A（`group-a`）中所有项目的所有代码仓库、群组 B 中项目 C（`group-b/project-c`）的代码仓库，并跳过群组 A 中的项目 D（`group-a/project-d`）：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create REPOSITORIES_PATHS=group-a,group-b/project-c SKIP_REPOSITORIES_PATHS=group-a/project-d
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create REPOSITORIES_PATHS=group-a,group-b/project-c SKIP_REPOSITORIES_PATHS=group-a/project-d
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

```shell
REPOSITORIES_PATHS=group-a SKIP_REPOSITORIES_PATHS=group-a/project_a2 backup-utility --skip db,registry,uploads,artifacts,lfs,packages,external_diffs,terraform_state,ci_secure_files,agent_plan_content,ci_catalog_bundles,pages
```

{{< /tab >}}

{{< /tabs >}}

<a id="upload-backups-to-a-remote-cloud-storage"></a>

#### 将备份上传到远程（云）存储

> [!note]
> 当使用对象存储进行备份时，无法[跳过 tar 创建](#skipping-tar-creation)。

您可以让备份脚本将其创建的`.tar` 文件上传到远程存储。在以下示例中，我们使用 Amazon S3 作为存储，但您也可以使用
其他云提供商，如 Google Cloud Storage 和 Azure，或本地挂载的共享。

另请参阅：

- [Fog 库文档](https://fog.github.io/)
- [其他存储提供商](https://fog.github.io/storage/)
- [极狐GitLab 对象存储指南](../object_storage.md)
- [上传到本地挂载的共享](#upload-to-locally-mounted-shares)
- [将对象存储与极狐GitLab 一起使用](../object_storage.md)

<a id="using-amazon-s3"></a>

##### 使用 Amazon S3

对于 Linux 软件包（Omnibus）：

1. 将以下内容添加到`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['backup_upload_connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-west-1',
     # Choose one authentication method
     # IAM Profile
     'use_iam_profile' => true
     # OR AWS Access and Secret key
     'aws_access_key_id' => 'AKIAKIAKI',
     'aws_secret_access_key' => 'secret123'
   }
   gitlab_rails['backup_upload_remote_directory'] = 'my.s3.bucket'
   # Consider using multipart uploads when file size reaches 100 MB. Enter a number in bytes.
   # gitlab_rails['backup_multipart_chunk_size'] = 104857600
   ```

1. 如果您使用 IAM Profile 身份验证方法，请确保要运行 `backup-utility`的实例设置了以下策略（将`<backups-bucket>`替换为正确的存储桶名称）：

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "s3:PutObject",
                   "s3:GetObject",
                   "s3:DeleteObject"
               ],
               "Resource": "arn:aws:s3:::<backups-bucket>/*"
           }
       ]
   }
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效

<a id="s3-encrypted-buckets"></a>

##### S3 加密存储桶

AWS 支持以下[服务器端加密模式](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)：

- Amazon S3 托管密钥（SSE-S3）
- 存储在 AWS Key Management Service 中的客户主密钥（CMK）（SSE-KMS）
- 客户提供的密钥（SSE-C）

将您选择的模式与极狐GitLab 一起使用。每种模式都有相似但略有不同的配置方法。

<a id="sse-s3"></a>

###### SSE-S3

要启用 SSE-S3，请在备份存储选项中，将 `server_side_encryption` 字段设置为 `AES256`。例如，在 Linux 软件包（Omnibus）中：

```ruby
gitlab_rails['backup_upload_storage_options'] = {
  'server_side_encryption' => 'AES256'
}
```

<a id="sse-kms"></a>

###### SSE-KMS

要启用 SSE-KMS，您需要
[通过其 Amazon Resource Name (ARN) 获取 KMS 密钥，格式为 `arn:aws:kms:region:acct-id:key/key-id`](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html)。
在 `backup_upload_storage_options` 配置设置下，设置：

- `server_side_encryption` 为 `aws:kms`。
- `server_side_encryption_kms_key_id` 为密钥的 ARN。

例如，在 Linux 软件包（Omnibus）中：

```ruby
gitlab_rails['backup_upload_storage_options'] = {
  'server_side_encryption' => 'aws:kms',
  'server_side_encryption_kms_key_id' => 'arn:aws:<YOUR KMS KEY ID>:'
}
```

<a id="sse-c"></a>

###### SSE-C

SSE-C 要求您设置以下加密选项：

- `backup_encryption`：AES256。
- `backup_encryption_key`：未编码的 32 字节（256 位）密钥。如果这不是恰好 32 字节，上传将失败。

例如，在 Linux 软件包（Omnibus）中：

```ruby
gitlab_rails['backup_encryption'] = 'AES256'
gitlab_rails['backup_encryption_key'] = '<YOUR 32-BYTE KEY HERE>'
```

如果密钥包含二进制字符且无法以 UTF-8 编码，请改用 `GITLAB_BACKUP_ENCRYPTION_KEY` 环境变量指定密钥。例如：

```ruby
gitlab_rails['env'] = { 'GITLAB_BACKUP_ENCRYPTION_KEY' => "\xDE\xAD\xBE\xEF" * 8 }
```

<a id="digital-ocean-spaces"></a>

##### Digital Ocean Spaces

此示例可用于阿姆斯特丹（AMS3）的存储桶：

1. 将以下内容添加到`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['backup_upload_connection'] = {
     'provider' => 'AWS',
     'region' => 'ams3',
     'aws_access_key_id' => 'AKIAKIAKI',
     'aws_secret_access_key' => 'secret123',
     'endpoint'              => 'https://ams3.digitaloceanspaces.com'
   }
   gitlab_rails['backup_upload_remote_directory'] = 'my.s3.bucket'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效

如果您在使用 Digital Ocean Spaces 时看到 `400 Bad Request` 错误消息，
原因可能是使用了备份加密。由于 Digital Ocean Spaces
不支持加密，请删除或注释掉包含 `gitlab_rails['backup_encryption']`的行。

<a id="other-s3-providers"></a>

##### 其他 S3 提供商

并非所有 S3 提供商都与 Fog 库完全兼容。例如，如果您在尝试上传后看到 `411 Length Required` 错误消息，您可能需要将 `aws_signature_version` 值从默认值降级为 `2`，[原因见此议题](https://github.com/fog/fog-aws/issues/428)。

对于自编译安装：

1. 编辑 `home/git/gitlab/config/gitlab.yml`：

   ```yaml
     backup:
       # snip
       upload:
         # Fog storage connection settings, see https://fog.github.io/storage/ .
         connection:
           provider: AWS
           region: eu-west-1
           aws_access_key_id: AKIAKIAKI
           aws_secret_access_key: 'secret123'
           # If using an IAM Profile, leave aws_access_key_id & aws_secret_access_key empty
           # ie. aws_access_key_id: ''
           # use_iam_profile: 'true'
         # The remote 'directory' to store your backups. For S3, this would be the bucket name.
         remote_directory: 'my.s3.bucket'
         # Specifies Amazon S3 storage class to use for backups, this is optional
         # storage_class: 'STANDARD'
         #
         # Turns on AWS Server-Side Encryption with Amazon Customer-Provided Encryption Keys for backups, this is optional
         #   'encryption' must be set in order for this to have any effect.
         #   'encryption_key' should be set to the 256-bit encryption key for Amazon S3 to use to encrypt or decrypt.
         #   To avoid storing the key on disk, the key can also be specified via the `GITLAB_BACKUP_ENCRYPTION_KEY` your data.
         # encryption: 'AES256'
         # encryption_key: '<key>'
         #
         #
         # Turns on AWS Server-Side Encryption with Amazon S3-Managed keys (optional)
         # https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html
         # For SSE-S3, set 'server_side_encryption' to 'AES256'.
         # For SSE-KMS, set 'server_side_encryption' to 'aws:kms'. Set
         # 'server_side_encryption_kms_key_id' to the ARN of customer master key.
         # storage_options:
         #   server_side_encryption: 'aws:kms'
         #   server_side_encryption_kms_key_id: 'arn:aws:kms:YOUR-KEY-ID-HERE'
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效

<a id="using-google-cloud-storage"></a>

##### 使用 Google Cloud Storage

要使用 Google Cloud Storage 保存备份，您必须首先从 Google 控制台
创建一个访问密钥：

1. 转到 [Google 存储设置页面](https://console.cloud.google.com/storage/settings)。
1. 选择**互操作性**，然后创建一个访问密钥。
1. 记下**访问密钥**和**密钥**，并在以下配置中
   替换它们。
1. 在存储桶高级设置中，确保选择了访问控制选项
   **设置对象级和存储桶级权限**。
1. 确保您已创建存储桶。

对于 Linux 软件包（Omnibus）：

1. 编辑`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['backup_upload_connection'] = {
     'provider' => 'Google',
     'google_storage_access_key_id' => 'Access Key',
     'google_storage_secret_access_key' => 'Secret',

     ## If you have CNAME buckets (foo.example.com), you might run into SSL issues
     ## when uploading backups ("hostname foo.example.com.storage.googleapis.com
     ## does not match the server certificate"). In that case, uncomment the following
     ## setting. See: https://github.com/fog/fog/issues/2834
     #'path_style' => true
   }
   gitlab_rails['backup_upload_remote_directory'] = 'my.google.bucket'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效

对于自编译安装：

1. 编辑 `home/git/gitlab/config/gitlab.yml`：

   ```yaml
     backup:
       upload:
         connection:
           provider: 'Google'
           google_storage_access_key_id: 'Access Key'
           google_storage_secret_access_key: 'Secret'
         remote_directory: 'my.google.bucket'
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效

<a id="using-azure-blob-storage"></a>

##### 使用 Azure Blob 存储

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['backup_upload_connection'] = {
    'provider' => 'AzureRM',
    'azure_storage_account_name' => '<AZURE STORAGE ACCOUNT NAME>',
    'azure_storage_access_key' => '<AZURE STORAGE ACCESS KEY>',
    'azure_storage_domain' => 'blob.core.windows.net', # Optional
   }
   gitlab_rails['backup_upload_remote_directory'] = '<AZURE BLOB CONTAINER>'
   ```

   如果您使用[托管标识](../object_storage.md#azure-workload-and-managed-identities)，请省略 `azure_storage_access_key`：

   ```ruby
   gitlab_rails['backup_upload_connection'] = {
     'provider' => 'AzureRM',
     'azure_storage_account_name' => '<AZURE STORAGE ACCOUNT NAME>',
     'azure_storage_domain' => '<AZURE STORAGE DOMAIN>' # Optional
   }
   gitlab_rails['backup_upload_remote_directory'] = '<AZURE BLOB CONTAINER>'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效

{{< /tab >}}

{{< tab title="自行编译" >}}

1. 编辑 `home/git/gitlab/config/gitlab.yml`：

   ```yaml
     backup:
       upload:
         connection:
           provider: 'AzureRM'
           azure_storage_account_name: '<AZURE STORAGE ACCOUNT NAME>'
           azure_storage_access_key: '<AZURE STORAGE ACCESS KEY>'
         remote_directory: '<AZURE BLOB CONTAINER>'
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效

{{< /tab >}}

{{< /tabs >}}

更多详情，请参阅 [Azure 参数表](../object_storage.md#azure-blob-storage)。

<a id="specifying-a-custom-directory-for-backups"></a>

##### 为备份指定自定义目录

此选项仅适用于远程存储。如果您想对备份进行分组，可以传入 `DIRECTORY` 环境变量：

```shell
sudo gitlab-backup create DIRECTORY=daily
sudo gitlab-backup create DIRECTORY=weekly
```

<a id="skip-uploading-backups-to-remote-storage"></a>

#### 跳过将备份上传到远程存储

如果您已将极狐GitLab 配置为[将备份上传到远程存储](#upload-backups-to-a-remote-cloud-storage)，您可以使用 `SKIP=remote` 选项跳过将备份上传到远程存储。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create SKIP=remote
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create SKIP=remote RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="upload-to-locally-mounted-shares"></a>

#### 上传到本地挂载的共享

您可以使用 Fog 的 [`Local`](https://github.com/fog/fog-local#usage) 存储提供商，将备份发送到本地挂载的共享（例如 `NFS`、`CIFS` 或 `SMB`）。

为此，您必须设置以下配置键：

- `backup_upload_connection.local_root`：备份复制到的挂载目录。
- `backup_upload_remote_directory`：`backup_upload_connection.local_root` 目录的子目录。如果它不存在，则会创建它。
  如果您想将 tar 包复制到挂载目录的根目录，请使用`.`。

挂载时，`local_root` 键中设置的目录必须归以下之一所有：

- `git` 用户。因此，对于 `CIFS` 和 `SMB`，使用 `git` 用户的 `uid=`进行挂载。
- 您执行备份任务所使用的用户。对于 Linux 软件包（Omnibus），这是 `git` 用户。

由于文件系统性能可能会影响极狐GitLab 的整体性能，[我们不建议使用基于云的文件系统进行存储](../nfs.md#avoid-using-cloud-based-file-systems)。

<a id="avoid-conflicting-configuration"></a>

##### 避免配置冲突

不要将以下配置键设置为同一路径：

- `gitlab_rails['backup_path']`（自编译安装为 `backup.path`）。
- `gitlab_rails['backup_upload_connection'].local_root`（自编译安装为 `backup.upload.connection.local_root`）。

`backup_path` 配置键设置备份文件的本地位置。`upload` 配置键用于将备份文件上传到单独的服务器时，可能是出于归档目的。

如果这些配置键设置为同一位置，上传功能会失败，因为上传位置已存在备份。此失败会导致上传功能删除该备份，因为它认为这是上传尝试失败后残留的文件。

<a id="configure-uploads-to-locally-mounted-shares"></a>

##### 配置上传到本地挂载的共享

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['backup_upload_connection'] = {
     :provider => 'Local',
     :local_root => '/mnt/backups'
   }

   # The directory inside the mounted folder to copy backups to
   # Use '.' to store them in the root directory
   gitlab_rails['backup_upload_remote_directory'] = 'gitlab_backups'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="自行编译" >}}

1. 编辑 `home/git/gitlab/config/gitlab.yml`：

   ```yaml
   backup:
     upload:
       # Fog storage connection settings, see https://fog.github.io/storage/ .
       connection:
         provider: Local
         local_root: '/mnt/backups'
       # The directory inside the mounted folder to copy backups to
       # Use '.' to store them in the root directory
       remote_directory: 'gitlab_backups'
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="backup-archive-permissions"></a>

#### 备份归档权限

极狐GitLab 创建的备份归档（`1393513186_2014_02_27_gitlab_backup.tar`）默认所有者为 `git`/`git`，权限为 0600。这是为了避免其他系统用户读取极狐GitLab 数据。如果您需要备份归档具有不同的权限，可以使用 `archive_permissions` 设置。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['backup_archive_permissions'] = 0644 # Makes the backup archives world-readable
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="自行编译" >}}

1. 编辑`/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   backup:
     archive_permissions: 0644 # Makes the backup archives world-readable
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="configuring-cron-to-make-daily-backups"></a>

#### 配置 cron 以进行每日备份

> [!warning]
> 以下 cron 作业不会备份您的极狐GitLab 配置文件或 SSH 主机密钥。

**重要：**请记住还要备份：

- [极狐GitLab 配置文件](#storing-configuration-files)
- [SSH 主机密钥](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079)

您可以安排一个 cron 作业来备份您的代码仓库和极狐GitLab 元数据。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `root` 用户的 crontab：

   ```shell
   sudo su -
   crontab -e
   ```

1. 在那里添加以下行，以安排每天凌晨 2 点进行备份：

   ```plaintext
   0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1
   ```

{{< /tab >}}

{{< tab title="自行编译" >}}

1. 编辑 `git` 用户的 crontab：

   ```shell
   sudo -u git crontab -e
   ```

1. 在底部添加以下行：

   ```plaintext
   # Create a full backup of the GitLab repositories and SQL database every day at 2am
   0 2 * * * cd /home/git/gitlab && PATH=/usr/local/bin:/usr/bin:/bin bundle exec rake gitlab:backup:create RAILS_ENV=production CRON=1
   ```

{{< /tab >}}

{{< /tabs >}}

`CRON=1` 环境设置指示备份脚本在没有错误时隐藏所有进度输出。建议这样做以减少 cron 垃圾信息。不过，在对备份问题进行故障排除时，请将 `CRON=1` 替换为`--trace` 以进行详细日志记录。

<a id="limit-backup-lifetime-for-local-files-prune-old-backups"></a>

#### 限制本地文件的备份生命周期（清理旧备份）

> [!warning]
> 如果您为备份使用了自定义文件名，则本节所述流程将不起作用。

为防止常规备份占用所有磁盘空间，您可能希望为备份设置有限的生命周期。下次备份任务运行时，早于 `backup_keep_time`的备份将被清理。

此配置选项仅管理本地文件。极狐GitLab 不会清理存储在第三方对象存储中的旧文件，因为用户可能没有列出和删除文件的权限。建议您为对象存储配置适当的保留策略。

另请参阅：

- [自定义文件名配置](#backup-filename)
- [将备份上传到远程云存储](#upload-backups-to-a-remote-cloud-storage)
- [AWS S3 生命周期策略](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html)

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑`/etc/gitlab/gitlab.rb`：

   ```ruby
   ## Limit backup lifetime to 7 days - 604800 seconds
   gitlab_rails['backup_keep_time'] = 604800
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="自行编译" >}}

1. 编辑`/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   backup:
     ## Limit backup lifetime to 7 days - 604800 seconds
     keep_time: 604800
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)
   以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="back-up-and-restore-for-installations-using-pgbouncer"></a>

#### 使用 PgBouncer 的安装的备份和恢复

不要通过 PgBouncer 连接备份或恢复极狐GitLab。这些
任务必须[绕过 PgBouncer 并直接连接到 PostgreSQL 主数据库节点](#bypassing-pgbouncer)，
否则会导致极狐GitLab 中断。

当极狐GitLab 备份或恢复任务与 PgBouncer 一起使用时，会显示以下错误消息：

```ruby
ActiveRecord::StatementInvalid: PG::UndefinedTable
```

每次极狐GitLab 备份运行时，极狐GitLab 开始产生 500 错误，并且关于缺失
表的错误将[由 PostgreSQL 记录](../logs/_index.md#postgresql-logs)：

```plaintext
ERROR: relation "tablename" does not exist at character 123
```

发生这种情况是因为该任务使用 `pg_dump`，它会设置空的搜索路径，并在每个 SQL 查询中显式包含 schema，以应对 CVE-2018-1058。

由于在事务池模式下使用 PgBouncer 时会重用连接，
PostgreSQL 无法搜索默认的 `public` schema。因此，
这种对搜索路径的清除会导致表和列看起来缺失。

技术参考：

- [Schema 处理实现](https://gitlab.com/gitlab-org/gitlab/-/issues/23211)
- [CVE-2018-1058 详情](https://www.postgresql.org/about/news/postgresql-103-968-9512-9417-and-9322-released-1834/)

<a id="bypassing-pgbouncer"></a>

##### 绕过 PgBouncer

有两种方法可以解决此问题：

1. [使用环境变量覆盖数据库设置](#environment-variable-overrides)以用于备份任务。
1. 重新配置节点以[直接连接到 PostgreSQL 主数据库节点](../postgresql/pgbouncer.md#procedure-for-bypassing-pgbouncer)。

<a id="environment-variable-overrides"></a>

###### 环境变量覆盖

默认情况下，极狐GitLab 使用存储在配置文件（`database.yml`）中的数据库配置。不过，您可以通过设置以 `GITLAB_BACKUP_`为前缀的环境变量，来覆盖备份和恢复任务的数据库设置：

- `GITLAB_BACKUP_PGHOST`
- `GITLAB_BACKUP_PGUSER`
- `GITLAB_BACKUP_PGPORT`
- `GITLAB_BACKUP_PGPASSWORD`
- `GITLAB_BACKUP_PGSSLMODE`
- `GITLAB_BACKUP_PGSSLKEY`
- `GITLAB_BACKUP_PGSSLCERT`
- `GITLAB_BACKUP_PGSSLROOTCERT`
- `GITLAB_BACKUP_PGSSLCRL`
- `GITLAB_BACKUP_PGSSLCOMPRESSION`

例如，要使用 Linux 软件包（Omnibus）将数据库主机和端口覆盖为 192.168.1.10 和端口 5432：

```shell
sudo GITLAB_BACKUP_PGHOST=192.168.1.10 GITLAB_BACKUP_PGPORT=5432 /opt/gitlab/bin/gitlab-backup create
```

如果您在[多个数据库](../postgresql/_index.md)上运行极狐GitLab，可以通过在环境变量中包含数据库名称来覆盖数据库设置。例如，如果您的 `main` 和 `ci` 数据库托管在不同的数据库服务器上，您可以在 `GITLAB_BACKUP_`前缀后附加它们的名称，保持 `PG*`名称不变：

```shell
sudo GITLAB_BACKUP_MAIN_PGHOST=192.168.1.10 GITLAB_BACKUP_CI_PGHOST=192.168.1.12 /opt/gitlab/bin/gitlab-backup create
```

有关这些参数作用的更多详情，请参阅 [PostgreSQL 文档](https://www.postgresql.org/docs/16/libpq-envars.html)。

<a id="gitaly-backup-for-repository-backup-and-restore"></a>

#### 用于代码仓库备份和恢复的 `gitaly-backup`

备份 Rake 任务使用 `gitaly-backup` 二进制文件从 Gitaly 创建和恢复代码仓库备份。`gitaly-backup` 取代了之前从极狐GitLab 直接调用 Gitaly 上 RPC 的备份方法。

备份 Rake 任务必须能够找到此可执行文件。在大多数情况下，您不需要更改二进制文件的路径，因为它应该可以在默认路径`/opt/gitlab/embedded/bin/gitaly-backup` 下正常工作。如果您有特定原因需要更改路径，可以在 Linux 软件包（Omnibus）中配置：

1. 将以下内容添加到`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['backup_gitaly_backup_path'] = '/path/to/gitaly-backup'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

<a id="alternative-backup-strategies"></a>

## 替代备份策略

由于每个部署可能有不同的能力，您应首先审查哪些数据需要备份，以更好地了解是否以及如何利用它们。

例如，如果您使用 Amazon RDS，您可能选择使用其内置的备份和恢复功能来处理您的极狐GitLab PostgreSQL 数据，并在使用备份命令时
排除 PostgreSQL 数据。

另请参阅：

- [哪些数据需要备份](#what-data-needs-to-be-backed-up)
- [PostgreSQL 数据库](#postgresql-databases)
- [从备份中排除特定数据](#excluding-specific-data-from-the-backup)
- [备份命令](#backup-command)

在以下情况下，考虑将文件系统数据传输或快照作为备份策略的一部分：

- 您的极狐GitLab 实例包含大量 Git 代码仓库数据，且极狐GitLab 备份脚本太慢。
- 您的极狐GitLab 实例有很多复刻项目，且常规备份任务会为所有项目重复 Git 数据。
- 您的极狐GitLab 实例出现问题，无法使用常规备份和导入 Rake 任务。

> [!warning]
> Gitaly 集群 (Praefect)[不支持快照备份](../gitaly/praefect/_index.md#snapshot-backup-and-recovery)。

在考虑使用文件系统数据传输或快照时：

- 不要使用这些方法从一个操作系统迁移到另一个操作系统。源和目标的操作系统应尽可能相似。例如，
  不要使用这些方法从 Ubuntu 迁移到 RHEL。
- 数据一致性非常重要。您应在
  进行文件系统传输（例如使用 `rsync`）或创建快照之前停止极狐GitLab（`sudo gitlab-ctl stop`），以确保内存中的所有数据都已刷新到磁盘。极狐GitLab 由多个子系统（Gitaly、数据库、文件存储）组成，它们有自己的缓冲区、队列和存储层。极狐GitLab 事务可能跨越这些子系统，这会导致事务的一部分通过不同路径写入磁盘。在活动系统上，文件系统传输和快照运行无法捕获仍在内存中的部分事务。

示例：Amazon Elastic Block Store (EBS)

- 一个使用 Linux 软件包（Omnibus）的极狐GitLab 服务器托管在 Amazon AWS 上。
- 一个包含 ext4 文件系统的 EBS 驱动器挂载在`/var/opt/gitlab`。
- 在这种情况下，您可以通过创建 EBS 快照来进行应用备份。
- 该备份包含所有代码仓库、上传文件和 PostgreSQL 数据。

示例：逻辑卷管理器 (LVM) 快照 + rsync

- 一个使用 Linux 软件包（Omnibus）的极狐GitLab 服务器，在`/var/opt/gitlab` 挂载了一个 LVM 逻辑卷。
- 使用 rsync 复制`/var/opt/gitlab` 目录并不可靠，因为 rsync 运行期间会有太多文件发生变化。
- 与其对`/var/opt/gitlab` 执行 rsync，我们创建一个临时 LVM 快照，并将其作为只读文件系统挂载在`/mnt/gitlab_backup`。
- 现在我们可以运行更长时间的 rsync 作业，在远程服务器上创建一致的副本。
- 该副本包含所有代码仓库、上传文件和 PostgreSQL 数据。

如果您在虚拟化服务器上运行极狐GitLab，您可能还可以创建整个极狐GitLab 服务器的虚拟机快照。不过，虚拟机快照通常需要您关闭服务器电源，这限制了此解决方案的实际用途。

<a id="back-up-repository-data-separately"></a>

### 单独备份代码仓库数据

首先，确保在[跳过代码仓库](#excluding-specific-data-from-the-backup)的同时备份现有极狐GitLab 数据：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-backup create SKIP=repositories
```

{{< /tab >}}

{{< tab title="自行编译" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:create SKIP=repositories RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

对于手动备份磁盘上的 Git 代码仓库数据，有多种可能的策略：

- 使用[极狐GitLab Geo](../geo/_index.md) 并依赖 Geo 从站点上的代码仓库数据。
- [阻止写入并复制 Git 代码仓库数据](#prevent-writes-and-copy-the-git-repository-data)。
- [通过将代码仓库标记为只读来创建在线备份（实验）](#online-backup-through-marking-repositories-as-read-only-experimental)。
- 对 Gitaly 存储磁盘创建[磁盘快照](#disk-snapshots)。

<a id="disk-snapshots"></a>

#### 磁盘快照

磁盘快照是一种尽力而为的备份策略，适用于以下情况：

- 无法使用常规极狐GitLab 备份脚本。
- 您使用独立 Gitaly，且无法在备份期间将所有代码仓库标记为只读。
- 其他备份策略（如 `rsync`、`tar` 或 `scp`）引入过多延迟。

在创建磁盘快照之前，您必须[将极狐GitLab 置于只读状态](../read_only_gitlab.md)。Git 确保磁盘上的文件尽管有文件系统活动，仍保持物理一致。虽然代码仓库损坏不太可能发生，但 Gitaly 磁盘快照很可能与极狐GitLab 应用期望的内容在逻辑上不一致。将恢复的 Gitaly 快照与其他极狐GitLab 组件匹配很困难。

磁盘快照仅支持独立 Gitaly 节点。Gitaly 集群 (Praefect)中对磁盘快照的支持正在[议题 7128](https://gitlab.com/gitlab-org/gitaly/-/work_items/7128)中跟踪。

创建磁盘快照的方法取决于 Gitaly 节点的部署位置。所有主要云服务都提供对附加到活动实例的磁盘创建快照的机制，因此请查看您所使用的云提供商的文档。

一些客户[建议](https://gitlab.com/gitlab-org/gitaly/-/work_items/1476)采用混合方法，即在每个备份间隔创建两个磁盘快照。第一个快照在 Gitaly 正在积极处理流量时创建。此快照包含两个增量中较大的一个，耗时更长。创建第一个快照后，将极狐GitLab 置于维护模式，然后创建第二个快照，其完成速度快得多。此策略可以减少停机时间，但极狐GitLab 内部并不使用这种方法。

从磁盘快照恢复时，有必要验证恢复的代码仓库的完整性。可以使用 `git-fsck(1)` 执行此检查。更多信息，请参阅[使用命令行运行检查](../repository_checks.md#run-a-check-using-the-command-line)。

<a id="prevent-writes-and-copy-the-git-repository-data"></a>

#### 阻止写入并复制 Git 代码仓库数据

必须以一致的方式复制 Git 代码仓库。如果在并发写入操作期间复制代码仓库，可能会出现不一致。这可能导致逻辑损坏、提交缺失或备份数据不完整。

要阻止对 Git 代码仓库数据的写入，有两种可能的方法：

- 使用[维护模式](../maintenance_mode/_index.md)将极狐GitLab 置于只读状态。
- 在备份代码仓库之前停止所有 Gitaly 服务，以创建明确的停机时间：

  ```shell
  sudo gitlab-ctl stop gitaly
  # execute git data copy step
  sudo gitlab-ctl start gitaly
  ```

您可以使用任何方法复制 Git 代码仓库数据，只要阻止对所复制数据的写入（以防止不一致和损坏问题）。按偏好和安全性排序，推荐的方法有：

1. 使用带有 archive 模式、delete 和 checksum 选项的 `rsync`，例如：

   ```shell
   rsync -aR --delete --checksum source destination # be extra safe with the order as it will delete existing data if inverted
   ```

1. 使用 [`tar` 管道将整个代码仓库目录复制到另一台服务器或位置](../operations/moving_repositories.md#use-a-tar-pipe-to-another-server)。
1. 使用 `sftp`、`scp`、`cp` 或任何其他复制方法。

<a id="online-backup-through-marking-repositories-as-read-only-experimental"></a>

#### 通过将代码仓库标记为只读来创建在线备份（实验）

一种无需实例范围停机即可备份代码仓库的方法是，在复制底层数据时以编程方式将项目标记为只读。

这可能有以下几个缺点：

- 代码仓库在一段时间内处于只读状态，该时间随代码仓库大小而增加。
- 由于将每个项目标记为只读，备份完成时间更长，可能导致不一致。例如，
  第一个被备份的项目最后可用数据与
  最后一个被备份的项目之间可能存在日期差异。
- 复刻网络应完全只读，同时其中的项目被备份，以防止池代码仓库发生潜在变化。

在 [Geo 团队 Runbooks 项目](https://gitlab.com/gitlab-org/geo-team/runbooks/-/tree/main/experimental-online-backup-through-rsync)中有一个尝试自动化此过程的实验性脚本。
