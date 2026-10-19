---
stage: Systems
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Gitaly 集群故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在对 Gitaly 集群（Praefect）进行故障排除时，请参考以下信息。有关故障排除 Gitaly 的信息，请参阅[故障排除 Gitaly](troubleshooting.md)。

<a id="check-cluster-health"></a>

## 检查集群健康状况

`check` Praefect 子命令运行一系列检查以确定 Gitaly 集群的健康状况。

```shell
gitlab-ctl praefect check
```

如果 Praefect 是通过 Praefect chart 部署的，则直接运行二进制文件。

```shell
/usr/local/bin/praefect check
```

以下部分描述了所运行的检查。

<a id="praefect-migrations"></a>

### Praefect 数据库迁移

由于数据库迁移必须是最新的才能使 Praefect 正常工作，因此检查 Praefect 迁移是否是最新的。

如果此检查失败：

1. 查看数据库中的 `schema_migrations` 表以查看哪些迁移已经运行。
1. 运行 `praefect sql-migrate` 以更新迁移。

<a id="node-connectivity-and-disk-access"></a>

### 节点连接性和磁盘访问

检查 Praefect 是否可以访问其所有 Gitaly 节点，以及每个 Gitaly 节点是否具有读写访问其所有存储的权限。

如果此检查失败：

1. 确认网络地址和令牌设置正确：
   - 在 Praefect 配置中。
   - 在每个 Gitaly 节点的配置中。
1. 在 Gitaly 节点上，检查 `gitaly` 进程是否以 `git` 身份运行。可能存在权限问题，阻止 Gitaly 访问其存储目录。
1. 确认连接 Praefect 和 Gitaly 节点的网络没有问题。

<a id="database-read-and-write-access"></a>

### 数据库读写访问

检查 Praefect 是否可以从数据库中读取和写入数据。

如果此检查失败：

1. 查看 Praefect 数据库是否处于恢复模式。在恢复模式下，表可能是只读的。要检查，请运行：

   ```sql
   select pg_is_in_recovery()
   ```

1. 确认 Praefect 用于连接 PostgreSQL 的用户具有数据库的读写访问权限。
1. 查看数据库是否已进入只读模式。要检查，请运行：

   ```sql
   show default_transaction_read_only
   ```

<a id="inaccessible-repositories"></a>

### 无法访问的仓库

检查由于缺少主分配或主分配不可用而无法访问的仓库数量。

如果此检查失败：

1. 查看是否有 Gitaly 节点停机。运行 `praefect ping-nodes` 进行检查。
1. 检查 Praefect 数据库是否负载过高。如果 Praefect 数据库响应缓慢，可能会导致健康检查无法持久化到数据库，导致 Praefect 认为节点不健康。

<a id="praefect-errors-in-logs"></a>

## Praefect 日志中的错误

如果收到错误，请检查 `/var/log/gitlab/gitlab-rails/production.log`。

以下是常见错误和潜在原因：

- 500 响应代码
  - `ActionView::Template::Error (7:permission denied)`
    - `praefect['configuration'][:auth][:token]` 和 `gitlab_rails['gitaly_token']` 在极狐GitLab 服务器上不匹配。
    - Sidekiq 服务器上的 `gitlab_rails['repositories_storages']` 存储配置缺失。
  - `Unable to save project. Error: 7:permission denied`
    - 极狐GitLab 服务器上的 `praefect['configuration'][:virtual_storage]` 中的密钥与一个或多个 Gitaly 服务器上的 `gitaly['auth_token']` 的值不匹配。
- 503 响应代码
  - `GRPC::Unavailable (14:failed to connect to all addresses)`
    - 极狐GitLab 无法到达 Praefect。
  - `GRPC::Unavailable (14:all SubCons are in TransientFailure...)`
    - Praefect 无法到达其一个或多个子 Gitaly 节点。尝试运行 Praefect 连接检查器进行诊断。

<a id="praefect-database-experiencing-high-cpu-load"></a>

## Praefect 数据库遇到高 CPU 负载

一些常见原因导致 Praefect 数据库 CPU 使用率升高，包括：

- Prometheus 指标抓取运行一个昂贵的查询。在 `gitlab.rb` 中设置 `praefect['configuration'][:prometheus_exclude_database_from_default_metrics] = true`。
- [读取分发缓存](praefect.md#reads-distribution-caching)被禁用，在用户流量高时增加了对数据库的查询次数。确保启用了读取分发缓存。

<a id="determine-primary-gitaly-node"></a>

## 确定主 Gitaly 节点

要确定仓库的主节点，请使用 [`praefect metadata`](#view-repository-metadata) 子命令。

<a id="view-repository-metadata"></a>

## 查看仓库元数据

Gitaly 集群维护有关集群上存储的仓库的[元数据数据库](_index.md#components)。使用 `praefect metadata` 子命令检查元数据以进行故障排除。

您可以通过其 Praefect 分配的仓库 ID 检索仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -repository-id <repository-id>
```

当物理存储上的物理路径以 `@cluster` 开头时，您可以[在物理路径中找到仓库 ID](_index.md#praefect-generated-replica-paths)。

您还可以通过其虚拟存储和相对路径检索仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -virtual-storage <virtual-storage> -relative-path <relative-path>
```

<a id="examples"></a>

### 示例

要检索具有 Praefect 分配的仓库 ID 为 1 的仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -repository-id 1
```

要检索虚拟存储 `default` 和相对路径 `@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git` 的仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -virtual-storage default -relative-path @hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git
```

这些示例中的任一个都检索示例仓库的以下元数据：

```plaintext
Repository ID: 54771
Virtual Storage: "default"
Relative Path: "@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git"
Replica Path: "@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git"
Primary: "gitaly-1"
Generation: 1
Replicas:
- Storage: "gitaly-1"
  Assigned: true
  Generation: 1, fully up to date
  Healthy: true
  Valid Primary: true
  Verified At: 2021-04-01 10:04:20 +0000 UTC
- Storage: "gitaly-2"
  Assigned: true
  Generation: 0, behind by 1 changes
  Healthy: true
  Valid Primary: false
  Verified At: unverified
- Storage: "gitaly-3"
  Assigned: true
  Generation: replica not yet created
  Healthy: false
  Valid Primary: false
  Verified At: unverified
```

<a id="available-metadata"></a>

### 可用元数据

通过 `praefect metadata` 检索的元数据包括下表中的字段。

| 字段             | 描述                                                                                                        |
|:------------------|:-------------------------------------------------------------------------------------------------------------------|
| `Repository ID`   | Praefect 分配给仓库的永久唯一 ID。与极狐GitLab 用于仓库的 ID 不同。      |
| `Virtual Storage` | 仓库存储所在的虚拟存储的名称。                                                           |
| `Relative Path`   | 虚拟存储中仓库的路径。                                                                          |
| `Replica Path`    | 仓库副本在 Gitaly 节点的磁盘上的存储位置。                                                |
| `Primary`         | 当前仓库的主节点。                                                                                 |
| `Generation`      | Praefect 用于追踪仓库更改。仓库中的每次写入都会增加仓库的世代。 |
| `Replicas`        | 存在或预计存在的副本列表。                                                            |

对于每个副本，以下元数据可用：

| `Replicas` 字段 | 描述                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|:-----------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Storage`        | 包含副本的 Gitaly 存储名称。                                                                                                                                                                                                                                                                                                                                                                                                  |
| `Assigned`       | 指示副本是否预计存在于存储中。如果 Gitaly 节点从集群中移除或存储包含一个额外副本后仓库的复制因子减少，可能为 `false`。                                                                                                                                                                                                                       |
| `Generation`     | 副本的最新确认世代。它表示：<br><br>- 如果世代与仓库的世代匹配，则副本完全是最新的。<br>- 如果副本的世代小于仓库的世代，则副本过时。<br>- 如果副本在存储中完全不存在，则为 `replica not yet created`。                                                                                                          |
| `Healthy`        | 指示托管此副本的 Gitaly 节点是否被 Praefect 节点的共识认为健康。                                                                                                                                                                                                                                                                                                                               |
| `Valid Primary`  | 指示副本是否适合作为主节点。如果仓库的主节点不是有效的主节点，则在下次写入仓库时发生故障转移，如果有其他副本是有效的主节点。副本是有效的主节点，如果：<br><br>- 它存储在健康的 Gitaly 节点上。<br>- 它完全是最新的。<br>- 它不是由减少复制因子引起的待删除作业的目标。<br>- 它是分配的。 |
| `Verified At` | 指示由[验证工作者](praefect.md#repository-verification)成功验证副本的最后时间。如果副本尚未验证，则在显示最后成功验证时间的位置显示 `unverified`。在极狐GitLab 15.0 中引入。 |

<a id="command-fails-with-repository-not-found"></a>

### 命令因 'repository not found' 而失败

如果提供的 `-virtual-storage` 值不正确，命令会返回以下错误：

```plaintext
get metadata: rpc error: code = NotFound desc = repository not found
```

文档示例指定 `-virtual-storage default`。检查 Praefect 服务器设置 `/etc/gitlab/gitlab.rb` 中的 `praefect['configuration'][:virtual_storage]`。

<a id="check-that-repositories-are-in-sync"></a>

## 检查仓库是否同步

在[某些情况下](_index.md#known-issues)，Praefect 数据库可能会与底层 Gitaly 节点不同步。要检查给定仓库是否在所有节点上完全同步，请在您的 Rails 节点上运行 [`gitlab:praefect:replicas` Rake 任务](../raketasks/praefect.md#replica-checksums)。此 Rake 任务对所有 Gitaly 节点上的仓库进行校验。

Praefect 的 [dataloss](recovery.md#check-for-data-loss) 命令仅检查 Praefect 数据库中的仓库状态，在这种情况下不能用于检测同步问题。

<a id="dataloss-command-shows-failed-geo-sync-repositories-as-out-of-sync"></a>

### `dataloss` 命令显示 `@failed-geo-sync` 仓库不同步

`@failed-geo-sync` 是一个遗留路径，曾在极狐GitLab 16.1 和更早版本中被 Geo 使用，当项目同步失败时被弃用。

在极狐GitLab 16.2 及以后版本中，您可以安全地删除此路径。`@failed-geo-sync` 目录位于 Gitaly 节点上的[仓库路径](../repository_storage_paths.md)下。

<a id="relation-does-not-exist-errors"></a>

## 关系不存在错误

默认情况下，Praefect 数据库表是由 `gitlab-ctl reconfigure` 任务自动创建的。

然而，在初始配置时 Praefect 数据库表未被创建，并且如果：

- 未执行 `gitlab-ctl reconfigure` 命令。
- 执行过程中发生错误。

可能会抛出关系不存在的错误。

例如：

- `ERROR:  relation "node_status" does not exist at character 13`
- `ERROR:  relation "replication_queue_lock" does not exist at character 40`
- 此错误：

  ```json
  {"level":"error","msg":"Error updating node: pq: relation \"node_status\" does not exist","pid":210882,"praefectName":"gitlab1x4m:0.0.0.0:2305","time":"2021-04-01T19:26:19.473Z","virtual_storage":"praefect-cluster-1"}
  ```

要解决此问题，数据库架构迁移可以通过 `praefect` 命令的 `sql-migrate` 子命令进行：

```shell
$ sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml sql-migrate
praefect sql-migrate: OK (applied 21 migrations)
```

<a id="requests-fail-with-repository-scoped-invalid-repository-errors"></a>

## 请求因 'repository scoped: invalid Repository' 错误失败

这表明虚拟存储名称在[Praefect 配置](praefect.md#praefect)中使用的名称与极狐GitLab 使用的 `gitaly['configuration'][:storage][<index>][:name]` 设置中的存储名称不匹配。

通过匹配 Praefect 和极狐GitLab 配置中使用的虚拟存储名称来解决此问题。

<a id="gitaly-cluster-performance-issues-on-cloud-platforms"></a>

## 云平台上的 Gitaly 集群性能问题

Praefect 不需要太多的 CPU 或内存，可以在小型虚拟机上运行。云服务可能会对小型虚拟机使用的资源设置其他限制，例如磁盘 IO 和网络流量。

Praefect 节点生成大量网络流量。如果其网络带宽被云服务限制，则可能会观察到以下症状：

- Git 操作性能差。
- 网络延迟高。
- Praefect 使用的内存高。

可能的解决方案：

- 提供更大的虚拟机以获得更大的网络流量许可。
- 使用您的云服务的监控和日志记录来检查 Praefect 节点是否未耗尽其流量许可。

<a id="gitlab-ctl-reconfigure-fails-with-a-praefect-configuration-error"></a>

## `gitlab-ctl reconfigure` 因 Praefect 配置错误而失败

如果 `gitlab-ctl reconfigure` 失败，您可能会看到此错误：

```plaintext
STDOUT: praefect: configuration error: error reading config file: toml: cannot store TOML string into a Go int
```

当 `praefect['database_port']` 或 `praefect['database_direct_port']` 被配置为字符串而不是整数时，会发生此错误。

<a id="common-replication-errors"></a>

## 常见复制错误

以下是一些常见的复制错误及可能的解决方案。

<a id="lock-file-exists"></a>

### 锁文件存在

锁文件用于防止对同一个引用进行多个更新。有时锁文件会变得陈旧，复制失败并显示错误 `error: cannot lock ref`。

要清除陈旧的 `*.lock` 文件，您可以在[Rails 控制台](../operations/rails_console.md)上触发 `OptimizeRepositoryRequest`：

```ruby
p = Project.find <Project ID>
client = Gitlab::GitalyClient::RepositoryService.new(p.repository)
client.optimize_repository
```

如果触发 `OptimizeRepositoryRequest` 不起作用，请手动检查文件以确认创建日期并决定是否可以手动删除 `*.lock` 文件。任何创建超过 24 小时的锁文件都可以安全地删除。

<a id="git-fsck-errors"></a>

### Git `fsck` 错误

具有无效对象的 Gitaly 仓库可能会导致复制失败，并在 Gitaly 日志中出现错误，例如：

- `exit status 128, stderr: "fatal: git upload-pack: not our ref"`。
- `"fatal: bad object 58....e0f... ssh://gitaly/internal.git did not send all necessary objects`。

只要有一个 Gitaly 节点仍有健康的仓库副本，就可以通过以下方式修复这些问题：

1. [从 Praefect 数据库中删除仓库](recovery.md#manually-remove-repositories)。
1. 使用 [Praefect `track-repository` 子命令](recovery.md#manually-add-a-single-repository-to-the-tracking-database)重新跟踪它。

这将使用权威 Gitaly 节点上的仓库副本覆盖所有其他 Gitaly 节点上的副本。在运行这些命令之前，请确保已经对仓库进行了最近的备份。

1. 将坏的仓库移出位置：

   ```shell
   run `mv <REPOSITORY_PATH> <REPOSITORY_PATH>.backup`
   ```

   例如：

   ```shell
   mv /var/opt/gitlab/git-data/repositories/@cluster/repositories/de/74/2335 /var/opt/gitlab/git-data/repositories/@cluster/repositories/de/74/2335.backup
   ```

1. 运行 Praefect 命令以触发复制：

   ```shell
   # 验证您拥有正确的仓库。
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage gitaly -relative-path '<relative_path>' -db-only

   # 使用 '--apply' 标志再次运行以从 Praefect 跟踪数据库中删除仓库
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage gitaly -relative-path '<relative_path>' -db-only --apply

   # 重新跟踪仓库，覆盖次级节点
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repository -virtual-storage gitaly -authoritative-storage '<healthy_gitaly>' -relative-path '<relative_path>' -replica-path '<replica_path>'-replicate-immediately
   ```

<a id="replication-fails-silently"></a>

### 复制静默失败

如果 [Praefect `dataloss`](recovery.md#check-for-data-loss) 显示[仓库部分不可用](recovery.md#unavailable-replicas-of-available-repositories)，并且 [`accept-dataloss` 命令](recovery.md#accept-data-loss)无法同步仓库，日志中没有出现错误，这可能是由于 Praefect 数据库中 `storage_repositories` 表的 `repository_id` 字段不匹配。要检查是否存在不匹配：

1. 连接到 Praefect 数据库。
1. 运行以下查询：

   ```sql
   select * from storage_repositories where relative_path = '<relative-path>';
   ```

   使用[以 `@hashed` 开头的仓库路径](../repository_storage_paths.md#hashed-storage)替换 `<relative-path>`。

<a id="alternate-directory-does-not-exists"></a>

### 替代目录不存在

极狐GitLab 使用[Git 替代机制进行重复数据消除](../../development/git_object_deduplication.md)。`alternates` 是一个文本文件，用于指向 `@pool` 仓库中的 `objects` 目录以获取对象。如果此文件指向无效路径，则复制可能会失败，并出现以下错误之一：

- `"error":"no alternates directory exists", "warning","msg":"alternates file does not point to valid git repository"`
- `"error":"unexpected alternates content:`
- `remote: error: unable to normalize alternate object path`

要调查此错误的原因：

1. 使用[Rails 控制台](../operations/rails_console.md)检查项目是否属于一个池：

   ```ruby
   project = Project.find_by_id(<project id>)
   project.pool_repository
   ```

1. 检查池仓库路径是否存在于磁盘上，并且它是否与[alternates 文件](../../development/git_object_deduplication.md)内容匹配。
1. 检查项目中 `objects` 目录中的[alternates 文件](../../development/git_object_deduplication.md)是否可达。
