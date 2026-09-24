---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Gitaly 集群 (Praefect) 问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

排查 Gitaly 集群 (Praefect) 时，请参考以下信息。有关排查 Gitaly 的信息，请参见[排查 Gitaly](../troubleshooting.md)。

<a id="prerequisites"></a>

## 先决条件

你必须拥有管理员访问权限。

<a id="check-cluster-health"></a>

## 检查集群健康状况

`check` Praefect 子命令会运行一系列检查，以确定 Gitaly 集群 (Praefect) 的健康状况。

```shell
gitlab-ctl praefect check
```

如果使用 Praefect 图表部署 Praefect，请直接运行二进制文件。

```shell
/usr/local/bin/praefect check
```

以下部分介绍了所运行的检查。

<a id="praefect-migrations"></a>

### Praefect 迁移

因为数据库迁移必须是最新的，Praefect 才能正常工作，所以此检查会检查 Praefect 迁移是否是最新的。

如果此检查失败：

1. 查看数据库中的 `schema_migrations` 表，了解已运行的迁移。
1. 运行 `praefect sql-migrate` 使迁移更新到最新。

<a id="node-connectivity-and-disk-access"></a>

### 节点连接性和磁盘访问

检查 Praefect 是否可以访问其所有 Gitaly 节点，以及每个 Gitaly 节点是否对其所有存储具有读写访问权限。

如果此检查失败：

1. 确认网络地址和令牌设置正确：
   - 在 Praefect 配置中。
   - 在每个 Gitaly 节点的配置中。
1. 在 Gitaly 节点上，检查 `gitaly` 进程是否以 `git` 用户身份运行。可能存在权限问题，导致 Gitaly 无法访问其存储目录。
1. 确认连接 Praefect 与 Gitaly 节点的网络没有问题。

<a id="database-read-and-write-access"></a>

### 数据库读写访问

检查 Praefect 是否可以从数据库读取数据和写入数据。

如果此检查失败：

1. 查看 Praefect 数据库是否处于恢复模式。在恢复模式下，表可能是只读的。要检查，请运行：

   ```sql
   select pg_is_in_recovery()
   ```

1. 确认 Praefect 用于连接 PostgreSQL 的用户对数据库具有读写访问权限。
1. 查看数据库是否已被置于只读模式。要检查，请运行：

   ```sql
   show default_transaction_read_only
   ```

<a id="inaccessible-repositories"></a>

### 无法访问的代码仓库

检查有多少代码仓库由于缺少主节点分配或其主节点不可用而无法访问。

如果此检查失败：

1. 查看是否有任何 Gitaly 节点宕机。运行 `praefect ping-nodes` 进行检查。
1. 检查 Praefect 数据库上的负载是否很高。如果 Praefect 数据库响应缓慢，可能导致健康检查无法持久化到数据库，从而使 Praefect 认为节点不健康。

<a id="praefect-errors-in-logs"></a>

## 日志中的 Praefect 错误

如果收到错误，请检查 `/var/log/gitlab/gitlab-rails/production.log`。

以下是常见错误和可能的原因：

- 500 响应代码
  - `ActionView::Template::Error (7:permission denied)`
    - GitLab 服务器上的 `praefect['configuration'][:auth][:token]` 和 `gitlab_rails['gitaly_token']` 不匹配。
    - Sidekiq 服务器上缺少 `gitlab_rails['repositories_storages']` 存储配置。
  - `Unable to save project. Error: 7:permission denied`
    - GitLab 服务器上 `praefect['configuration'][:virtual_storage]` 中的密钥令牌与一个或多个 Gitaly 服务器上的 `gitaly['auth_token']` 值不匹配。
- 503 响应代码
  - `GRPC::Unavailable (14:failed to connect to all addresses)`
    - GitLab 无法访问 Praefect。
  - `GRPC::Unavailable (14:all SubCons are in TransientFailure...)`
    - Praefect 无法访问其一个或多个子 Gitaly 节点。尝试运行 Praefect 连接检查器来进行诊断。

<a id="praefect-database-experiencing-high-cpu-load"></a>

## Praefect 数据库出现高 CPU 负载

Praefect 数据库 CPU 使用率升高的常见原因包括：

- Prometheus 指标抓取[运行了昂贵的查询](https://gitlab.com/gitlab-org/gitaly/-/issues/3796)。在 `gitlab.rb` 中设置 `praefect['configuration'][:prometheus_exclude_database_from_default_metrics] = true`。
- [读取分布缓存](configure.md#reads-distribution-caching)已禁用，在用户流量较高时增加了对数据库的查询次数。请确保读取分布缓存已启用。

<a id="determine-primary-gitaly-node"></a>

## 确定主 Gitaly 节点

要确定代码仓库的主节点，请使用 [`praefect metadata`](#view-repository-metadata) 子命令。

<a id="view-repository-metadata"></a>

## 查看仓库元数据

Gitaly 集群 (Praefect) 维护着一个[元数据数据库](_index.md#components)，其中包含有关集群上存储的仓库的信息。使用 `praefect metadata` 子命令检查元数据以进行故障排除。

你可以通过以下任一方式检索仓库的元数据：

- 虚拟存储和[相对路径](../../repository_storage_paths.md#from-project-name-to-hashed-path)。
- [Praefect 分配的仓库 ID](_index.md#praefect-generated-replica-paths)。

{{< tabs >}}

{{< tab title="虚拟存储和相对路径" >}}

要通过虚拟存储和相对路径检索仓库的元数据：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **项目** 并选择项目。
1. 记下项目的 **存储名称** 和 **相对路径** 的值。
1. 使用这些值运行以下命令：

   ```shell
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -virtual-storage <virtual-storage> -relative-path <relative-path>
   ```

{{< /tab >}}

{{< tab title="Praefect 分配的仓库 ID" >}}

> [!note]
> 仓库 ID 与项目 ID 不同。

要通过 Praefect 分配的仓库 ID 检索仓库的元数据：

1. 记下仓库副本路径的最后一个组成部分。例如，对于 `@cluster/repositories/6f/96/54771`，仓库 ID 为 `54771`。
1. 使用该值运行以下命令：

   ```shell
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -repository-id <repository-id>
   ```

{{< /tab >}}

{{< /tabs >}}

### 示例

要检索虚拟存储为 `default` 且相对路径为 `@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git` 的仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -virtual-storage default -relative-path @hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git
```

要检索 Praefect 分配的仓库 ID 为 1 的仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -repository-id 1
```

以上任一示例都会检索以下示例仓库的元数据：

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

`praefect metadata` 检索的元数据包括下表中的字段。

| 字段               | 描述                                                                                                              |
|:-------------------|:--------------------------------------------------------------------------------------------------------------------|
| `Repository ID`    | Praefect 分配给仓库的永久唯一 ID。与 GitLab 用于仓库的 ID 不同。                                                    |
| `Virtual Storage`  | 仓库所在的虚拟存储的名称。                                                                                          |
| `Relative Path`    | 仓库在虚拟存储中的路径。                                                                                            |
| `Replica Path`     | 仓库副本存储在 Gitaly 节点磁盘上的位置。                                                                            |
| `Primary`          | 仓库的当前主节点。                                                                                                  |
| `Generation`       | Praefect 用于跟踪仓库更改。每次在仓库中进行写入都会增加仓库的世代。                                                  |
| `Replicas`         | 存在或预期存在的副本列表。                                                                                          |

对于每个副本，可用以下元数据：

| `Replicas` 字段 | 描述                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|:-----------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Storage`        | 包含副本的 Gitaly 存储的名称。                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `Assigned`       | 指示副本是否应该存在于存储中。如果 Gitaly 节点从集群中移除，或者如果存储中在仓库的复制因子降低后包含额外副本，则可能为 `false`。                                                                                                                                                                                                                                                                                                                                 |
| `Generation`     | 副本最新确认的世代。表示：<br><br>- 如果世代与仓库的世代匹配，则副本完全是最新的。<br>- 如果副本的世代低于仓库的世代，则副本已过时。<br>- 如果副本尚未存在于存储中，则显示 `replica not yet created`。                                                                                                                                                                                                                                                                    |
| `Healthy`        | 表示托管此副本的 Gitaly 节点是否被 Praefect 节点共识认为健康。                                                                                                                                                                                                                                                                                                                                                                                               |
| `Valid Primary`  | 指示副本是否适合用作主节点。如果仓库的主节点不是有效主节点，则在下次写入仓库时，如果存在另一个有效的副本作为主节点，就会发生故障转移。副本是有效主节点的条件包括：<br><br>- 存储在健康的 Gitaly 节点上。<br>- 完全是最新的。<br>- 未被因减少复制因子而产生的待处理删除作业所针对。<br>- 已分配。                                                                                                                                                                                             |
| `Verified At`    | 表示[验证工作器](configure.md#repository-verification)最后一次成功验证副本的时间。如果副本尚未验证，则显示 `unverified` 而不是上次成功验证的时间。                                                                                                                                                                                                                                                                                                            |

<a id="command-fails-with-repository-not-found"></a>

### 命令失败并提示 'repository not found'

如果为 `-virtual-storage` 提供的值不正确，该命令将返回以下错误：

```plaintext
get metadata: rpc error: code = NotFound desc = repository not found
```

文档中的示例指定了 `-virtual-storage default`。检查 `/etc/gitlab/gitlab.rb` 中的 Praefect 服务器设置 `praefect['configuration'][:virtual_storage]`。

<a id="check-that-repositories-are-in-sync"></a>

## 检查仓库是否同步

在[某些情况](_index.md#known-issues)下，Praefect 数据库可能会与底层 Gitaly 节点不同步。要检查给定仓库在所有节点上是否完全同步，请在 Rails 节点上运行 [`gitlab:praefect:replicas` Rake 任务](../../raketasks/praefect.md#replica-checksums)。此 Rake 任务会校验所有 Gitaly 节点上的仓库。

[Praefect `dataloss`](recovery.md#check-for-data-loss) 命令仅检查 Praefect 数据库中仓库的状态，不能依赖它来检测此情况下的同步问题。

<a id="dataloss-command-shows-failed-geo-sync-repositories-as-out-of-sync"></a>

### `dataloss` 命令显示 `@failed-geo-sync` 仓库不同步

`@failed-geo-sync` 是旧路径，在 GitLab 16.1 及更早版本中由 Geo 在项目同步失败时使用，现已[弃用](https://jihulab.com/gitlab-cn/gitlab/-/issues/375640)。

在 GitLab 16.2 及更高版本中，你可以安全地删除此路径。`@failed-geo-sync` 目录位于 Gitaly 节点上的[仓库路径](../../repository_storage_paths.md)下。

<a id="relation-does-not-exist-errors"></a>

## 关系不存在的错误

默认情况下，Praefect 数据库表由 `gitlab-ctl reconfigure` 任务自动创建。

但是，如果在初始重新配置时未创建 Praefect 数据库表，并且在以下情况下，可能会引发关系不存在的错误：

- 未执行 `gitlab-ctl reconfigure` 命令。
- 执行过程中发生错误。

例如：

- `ERROR:  relation "node_status" does not exist at character 13`
- `ERROR:  relation "replication_queue_lock" does not exist at character 40`
- 此错误：

  ```json
  {"level":"error","msg":"Error updating node: pq: relation \"node_status\" does not exist","pid":210882,"praefectName":"gitlab1x4m:0.0.0.0:2305","time":"2021-04-01T19:26:19.473Z","virtual_storage":"praefect-cluster-1"}
  ```

要解决此问题，可以使用 `praefect` 命令的 `sql-migrate` 子命令进行数据库模式迁移：

```shell
$ sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml sql-migrate
praefect sql-migrate: OK (applied 21 migrations)
```

<a id="requests-fail-with-repository-scoped-invalid-repository-errors"></a>

## 请求失败并提示 'repository scoped: invalid Repository' 错误

这表明 [Praefect 配置](configure.md#praefect)中使用的虚拟存储名称与 GitLab 的 [`gitaly['configuration'][:storage][<index>][:name]` 设置](configure.md#gitaly)中使用的存储名称不匹配。

通过将 Praefect 和 GitLab 配置中使用的虚拟存储名称匹配来解决此问题。

<a id="gitaly-cluster-praefect-performance-issues-on-cloud-platforms"></a>

## 云平台上 Gitaly 集群 (Praefect) 性能问题

Praefect 不需要大量的 CPU 或内存，并且可以在小型虚拟机上运行。云服务可能会对小型虚拟机可用的资源施加其他限制，例如磁盘 IO 和网络流量。

Praefect 节点会产生大量网络流量。如果其网络带宽被云服务限制，可能会观察到以下症状：

- Git 操作性能不佳。
- 网络延迟高。
- Praefect 内存使用率高。

可能的解决方案：

- 配置更大的虚拟机以获得更大的网络流量配额。
- 使用云服务的监控和日志记录功能检查 Praefect 节点是否耗尽了其流量配额。

<a id="gitlab-ctl-reconfigure-fails-with-a-praefect-configuration-error"></a>

## `gitlab-ctl reconfigure` 因 Praefect 配置错误而失败

如果 `gitlab-ctl reconfigure` 失败，你可能会看到此错误：

```plaintext
STDOUT: praefect: configuration error: error reading config file: toml: cannot store TOML string into a Go int
```

当 `praefect['database_port']` 或 `praefect['database_direct_port']` 配置为字符串而非整数时会发生此错误。

<a id="common-replication-errors"></a>

## 常见复制错误

以下是常见的复制错误及可能的解决方案。

<a id="lock-file-exists"></a>

### 锁文件存在

锁文件用于防止对同一引用进行多次更新。有时锁文件会变得陈旧，复制会失败并显示错误 `error: cannot lock ref`。

要清除陈旧的 `*.lock` 文件，你可以在 [Rails 控制台](../../operations/rails_console.md)上触发 `OptimizeRepositoryRequest`：

```ruby
p = Project.find <Project ID>
client = Gitlab::GitalyClient::RepositoryService.new(p.repository)
client.optimize_repository
```

如果触发 `OptimizeRepositoryRequest` 不起作用，请手动检查文件以确认创建日期，并决定是否可以手动删除 `*.lock` 文件。任何创建时间超过 24 小时的锁文件都可以安全删除。

<a id="git-fsck-errors"></a>

### Git `fsck` 错误

具有无效对象的 Gitaly 仓库可能会导致复制失败，并在 Gitaly 日志中出现类似以下错误：

- `exit status 128, stderr: "fatal: git upload-pack: not our ref"`。
- `"fatal: bad object 58....e0f... ssh://gitaly/internal.git did not send all necessary objects`。

只要其中一个 Gitaly 节点仍然有该仓库的健康副本，就可以通过以下方法修复这些问题：

1. [从 Praefect 数据库中删除仓库](recovery.md#manually-remove-repositories)。
1. 使用 [Praefect `track-repository` 子命令](recovery.md#manually-add-a-single-repository-to-the-tracking-database)重新跟踪它。

这将使用来自权威 Gitaly 节点的仓库副本覆盖所有其他 Gitaly 节点上的副本。在运行这些命令之前，请确保已对该仓库进行了最近的备份。

1. 将有问题的仓库移开：

   ```shell
   run `mv <REPOSITORY_PATH> <REPOSITORY_PATH>.backup`
   ```

   例如：

   ```shell
   mv /var/opt/gitlab/git-data/repositories/@cluster/repositories/de/74/2335 /var/opt/gitlab/git-data/repositories/@cluster/repositories/de/74/2335.backup
   ```

1. 运行 Praefect 命令以触发复制：

   ```shell
   # 验证你使用的是正确的仓库。
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage gitaly -relative-path '<relative_path>' -db-only

   # 使用 '--apply' 标志再次运行，以从 Praefect 跟踪数据库中删除仓库
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage gitaly -relative-path '<relative_path>' -db-only --apply

   # 重新跟踪仓库，覆盖辅助节点
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repository -virtual-storage gitaly -authoritative-storage '<healthy_gitaly>' -relative-path '<relative_path>' -replica-path '<replica_path>'-replicate-immediately
   ```

<a id="replication-fails-silently"></a>

### 复制静默失败

如果 [Praefect `dataloss`](recovery.md#check-for-data-loss) 显示[仓库部分不可用](recovery.md#unavailable-replicas-of-available-repositories)，并且 [`accept-dataloss` 命令](recovery.md#accept-data-loss)未能同步仓库，且日志中没有出现错误，这可能是由于 Praefect 数据库中 `storage_repositories` 表的 `repository_id` 字段不匹配。要检查是否存在不匹配：

1. 连接到 Praefect 数据库。
1. 运行以下查询：

   ```sql
   select * from storage_repositories where relative_path = '<relative-path>';
   ```

   将 `<relative-path>` 替换为[以 `@hashed` 开头的仓库路径](../../repository_storage_paths.md#hashed-storage)。

<a id="alternate-directory-does-not-exists"></a>

### 备用目录不存在

GitLab 使用 Git alternates 机制进行去重。 `alternates` 是一个文本文件，指向 `@pool` 仓库上的 `objects` 目录以获取对象。如果此文件指向无效路径，复制可能会失败并显示以下错误之一：

- `"error":"no alternates directory exists", "warning","msg":"alternates file does not point to valid git repository"`
- `"error":"unexpected alternates content:`
- `remote: error: unable to normalize alternate object path`

要调查此错误的原因：

1. 使用 [Rails 控制台](../../operations/rails_console.md)检查项目是否属于某个池：

   ```ruby
   project = Project.find_by_id(<project id>)
   project.pool_repository
   ```

1. 检查池仓库路径是否存在于磁盘上，以及是否与 `alternates` 文件内容匹配。
1. 检查 `alternates` 文件中的路径是否可从项目中的 `objects` 目录访问。

执行这些检查后，联系 GitLab 支持并提供收集到的信息。

<a id="projects-are-stuck-in-read-only-state-after-failed-repository-storage-moves"></a>

### 仓库存储移动失败后项目卡在只读状态

当将 Horizontal Pod Autoscaler (HPA) 与 Sidekiq pod 一起使用时，由于作业执行期间的 pod 扩缩容，仓库存储移动可能会静默失败。如果仓库存储移动因此问题而失败，失败的项目可能会一直卡在只读状态。

要恢复受影响的仓库：

1. [将受影响的项目重置为读写状态](../../read_only_gitlab.md#make-the-repositories-read-only)。
1. [为 Sidekiq pod 禁用 HPA](https://gitlab.cn/docs/charts/charts/gitlab/sidekiq/#disable-hpa-scaling)
1. [通过 REST API 重新运行单个项目的存储移动](../../operations/moving_repositories.md)。
1. 迁移完成后恢复 HPA 配置。