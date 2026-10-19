---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Gitaly 集群（Praefect）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在对 Gitaly 集群（Praefect）进行故障排除时，请参考以下信息。有关 Gitaly 故障排除的信息，请参阅[故障排除 Gitaly](../troubleshooting.md)。

<a id="prerequisites"></a>

## 先决条件

您必须具有管理员访问权限。

<a id="check-cluster-health"></a>

## 检查集群健康状况

`check` Praefect 子命令会运行一系列检查，以确定 Gitaly 集群（Praefect）的健康状况。

```shell
gitlab-ctl praefect check
```

如果 Praefect 是通过 Praefect chart 部署的，请直接运行该二进制文件。

```shell
/usr/local/bin/praefect check
```

以下各节介绍了所运行的检查。

<a id="praefect-migrations"></a>

### Praefect 迁移

检查 Praefect 迁移是否为最新，因为数据库迁移必须是最新的，Praefect 才能正常工作。

如果此检查失败：

1. 查看数据库中的 `schema_migrations` 表，了解已运行了哪些迁移。
1. 运行 `praefect sql-migrate` 使迁移保持最新。

<a id="node-connectivity-and-disk-access"></a>

### 节点连接性和磁盘访问

检查 Praefect 是否可以访问其所有 Gitaly 节点，以及每个 Gitaly 节点是否对其所有存储具有读写访问权限。

如果此检查失败：

1. 确认网络地址和令牌已正确设置：
   - 在 Praefect 配置中。
   - 在每个 Gitaly 节点的配置中。
1. 在 Gitaly 节点上，检查 `gitaly` 进程是否以 `git` 身份运行。可能存在权限问题，导致 Gitaly
   无法访问其存储目录。
1. 确认连接 Praefect 与 Gitaly 节点的网络没有问题。

<a id="database-read-and-write-access"></a>

### 数据库读写访问

检查 Praefect 是否可以从数据库读取数据以及向数据库写入数据。

如果此检查失败：

1. 查看 Praefect 数据库是否处于恢复模式。在恢复模式下，表可能为只读。要检查，请运行：

   ```sql
   select pg_is_in_recovery()
   ```

1. 确认 Praefect 用于连接 PostgreSQL 的用户对该数据库具有读写访问权限。
1. 查看数据库是否已被置于只读模式。要检查，请运行：

   ```sql
   show default_transaction_read_only
   ```

<a id="inaccessible-repositories"></a>

### 无法访问的代码仓库

检查有多少代码仓库因缺少主节点分配或其主节点不可用而无法访问。

如果此检查失败：

1. 查看是否有任何 Gitaly 节点已宕机。运行 `praefect ping-nodes` 进行检查。
1. 检查 Praefect 数据库是否存在高负载。如果 Praefect 数据库响应缓慢，可能导致健康检查无法持久化
   到数据库，从而使 Praefect 认为节点不健康。

<a id="error-authoritative-repository-does-not-exist"></a>

## 错误：`authoritative repository does not exist`

如果您的 Praefect 配置使用 TLS 连接到 Gitaly 节点（地址以 `tls://` 开头），以 `git` 用户身份手动运行的 Praefect 子命令不会自动继承 runit 服务包装器所设置的 `SSL_CERT_DIR` 环境变量。

如果没有此环境变量，连接到 Gitaly 的命令会失败，并出现类似 `authoritative repository does not exist`的错误，即使该代码仓库存在于磁盘上也是如此。

要避免此错误，请切换到 `git` 用户的 shell，并在运行任何 Praefect 子命令之前显式设置 `SSL_CERT_DIR`：

```shell
sudo -u git -- env SSL_CERT_DIR=/opt/gitlab/embedded/ssl/certs/ \
  /opt/gitlab/embedded/bin/praefect \
  -config /var/opt/gitlab/praefect/config.toml <subcommand> [options]
```

在 Linux 软件包（Omnibus）安装中，此路径与 runit 服务包装器中为 Praefect 配置的路径一致。

<a id="praefect-errors-in-logs"></a>

## 日志中的 Praefect 错误

如果收到错误，请检查 `/var/log/gitlab/gitlab-rails/production.log`。

以下是一些常见错误及其可能的原因：

- 500 响应代码
  - `ActionView::Template::Error (7:permission denied)`
    - 极狐GitLab 服务器上的 `praefect['configuration'][:auth][:token]` 与 `gitlab_rails['gitaly_token']` 不匹配。
    - Sidekiq 服务器上缺少 `gitlab_rails['repositories_storages']` 存储配置。
  - `Unable to save project. Error: 7:permission denied`
    - 极狐GitLab 服务器上 `praefect['configuration'][:virtual_storage]` 中的密钥令牌与
      一个或多个 Gitaly 服务器上 `gitaly['auth_token']` 中的值不匹配。
- 503 响应代码
  - `GRPC::Unavailable (14:failed to connect to all addresses)`
    - 极狐GitLab 无法访问 Praefect。
  - `GRPC::Unavailable (14:all SubCons are in TransientFailure...)`
    - Praefect 无法访问其一个或多个子 Gitaly 节点。请尝试运行
      Praefect 连接检查器进行诊断。

<a id="praefect-database-experiencing-high-cpu-load"></a>

## Praefect 数据库出现高 CPU 负载

Praefect 数据库出现 CPU 使用率升高的一些常见原因包括：

- Prometheus 指标抓取[运行开销高昂的查询](https://gitlab.com/gitlab-org/gitaly/-/issues/3796)。在 `gitlab.rb`中设置
  `praefect['configuration'][:prometheus_exclude_database_from_default_metrics] = true`。
- [读取分布缓存](configure.md#reads-distribution-caching)已禁用，导致用户流量较高时对
  数据库的查询数量增加。请确保已启用读取分布缓存。

<a id="determine-primary-gitaly-node"></a>

## 确定主 Gitaly 节点

要确定某个代码仓库的主节点，请使用 [`praefect metadata`](#view-repository-metadata) 子命令。

<a id="view-repository-metadata"></a>

## 查看代码仓库元数据

Gitaly 集群（Praefect）维护一个[元数据数据库](_index.md#components)，其中包含有关集群上所存储代码仓库的信息。使用 `praefect metadata` 子命令检查元数据以进行故障排除。

您可以通过以下任一方式检索代码仓库的元数据：

- 虚拟存储和[相对路径](../../repository_storage_paths.md#from-project-name-to-hashed-path)。
- [Praefect 分配的代码仓库 ID](_index.md#praefect-generated-replica-paths)。

{{< tabs >}}

{{< tab title="虚拟存储和相对路径" >}}

要通过虚拟存储和相对路径检索代码仓库的元数据：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **项目**，然后选择该项目。
1. 记下该项目的**存储名称**和**相对路径**的值。
1. 使用这些值，运行以下命令：

   ```shell
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -virtual-storage <virtual-storage> -relative-path <relative-path>
   ```

{{< /tab >}}

{{< tab title="Praefect 分配的仓库 ID" >}}

> [!note]
> 代码仓库 ID 与项目 ID 不同。

要通过 Praefect 分配的代码仓库 ID 检索代码仓库的元数据：

1. 记下代码仓库副本路径的最后一部分。例如，对于 `@cluster/repositories/6f/96/54771`，代码仓库 ID 为 `54771`。
1. 使用该值，运行以下命令：

   ```shell
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -repository-id <repository-id>
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="examples"></a>

### 示例

要检索虚拟存储为 `default`、相对路径为 `@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git`的代码仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -virtual-storage default -relative-path @hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git
```

要检索 Praefect 分配的代码仓库 ID 为 1 的代码仓库的元数据：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -repository-id 1
```

这两个示例中的任一个都会检索出以下示例代码仓库的元数据：

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

`praefect metadata` 检索到的元数据包含下表中的字段。

| 字段             | 描述                                                                                                        |
|:------------------|:-------------------------------------------------------------------------------------------------------------------|
| `Repository ID`   | Praefect 分配给该代码仓库的永久唯一 ID。与极狐GitLab 用于代码仓库的 ID 不同。      |
| `Virtual Storage` | 该代码仓库所存储的虚拟存储的名称。                                                           |
| `Relative Path`   | 代码仓库在虚拟存储中的路径。                                                                          |
| `Replica Path`    | 代码仓库的副本存储在 Gitaly 节点磁盘上的位置。                                                |
| `Primary`         | 该代码仓库的当前主节点。                                                                                 |
| `Generation`      | Praefect 用于跟踪代码仓库变更。代码仓库中的每次写入都会增加该代码仓库的世代。 |
| `Replicas`        | 已存在或预期存在的副本列表。                                                            |

对于每个副本，可以使用以下元数据：

| `Replicas` 字段 | 描述                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|:-----------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Storage`        | 包含该副本的 Gitaly 存储的名称。                                                                                                                                                                                                                                                                                                                                                                                                  |
| `Assigned`       | 指示该副本是否预期存在于该存储中。如果某个 Gitaly 节点已从集群中移除，或者在该代码仓库的复制因子降低后该存储中仍包含额外副本，则可以为 `false`。                                                                                                                                                                                                                       |
| `Generation`     | 该副本最新确认的世代。它表示：<br><br>- 如果该世代与代码仓库的世代匹配，则该副本完全是最新的。<br>- 如果该副本的世代小于代码仓库的世代，则该副本已过时。<br>- 如果该副本在该存储上尚不存在，则为 `replica not yet created`。                                                                                                          |
| `Healthy`        | 指示托管此副本的 Gitaly 节点是否被 Praefect 节点共识视为健康。                                                                                                                                                                                                                                                                                                                               |
| `Valid Primary`  | 指示该副本是否适合作为主节点提供服务。如果该代码仓库的主节点不是有效主节点，则在对该代码仓库的下一次写入时，如果存在另一个有效主节点的副本，就会发生故障转移。副本是有效主节点的条件为：<br><br>- 它存储在健康的 Gitaly 节点上。<br>- 它完全是最新的。<br>- 它不是因降低复制因子而待执行的删除作业的目标。<br>- 它已被分配。 |
| `Verified At` | 指示[验证工作进程](configure.md#repository-verification)对该副本的最后一次成功验证。如果该副本尚未被验证，则显示 `unverified` 来代替最后一次成功验证的时间。 |

<a id="command-fails-with-repository-not-found"></a>

### 命令失败并显示“repository not found”

如果为 `-virtual-storage` 提供的值不正确，该命令会返回以下错误：

```plaintext
get metadata: rpc error: code = NotFound desc = repository not found
```

文档中的示例指定了 `-virtual-storage default`。请检查 `/etc/gitlab/gitlab.rb`中的 Praefect 服务器设置 `praefect['configuration'][:virtual_storage]`。

<a id="check-that-repositories-are-in-sync"></a>

## 检查代码仓库是否同步

在[某些情况下](_index.md#known-issues)，Praefect 数据库可能会与底层 Gitaly 节点不同步。要检查给定代码仓库是否在所有节点上完全同步，请在 Rails 节点上运行 [`gitlab:praefect:replicas` Rake 任务](../../raketasks/praefect.md#replica-checksums)。此 Rake 任务会对所有 Gitaly 节点上的代码仓库进行校验和计算。

[Praefect `dataloss`](recovery.md#check-for-data-loss) 命令只检查 Praefect 数据库中代码仓库的状态，在此场景下不能依赖它来检测同步问题。

<a id="dataloss-command-shows-failed-geo-sync-repositories-as-out-of-sync"></a>

### `dataloss` 命令将 `@failed-geo-sync` 代码仓库显示为不同步

`@failed-geo-sync` 是极狐GitLab 16.1 及更早版本中 Geo 在项目同步失败时使用的旧路径，现已[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/375640)。

在极狐GitLab 16.2 及更高版本中，您可以安全地删除此路径。`@failed-geo-sync` 目录位于 Gitaly 节点上的[代码仓库路径](../../repository_storage_paths.md)下。

<a id="relation-does-not-exist-errors"></a>

## 关系不存在错误

默认情况下，Praefect 数据库表由 `gitlab-ctl reconfigure` 任务自动创建。

但是，Praefect 数据库表不会在初始重新配置时创建，并且在以下任一情况下可能会抛出关系不存在的错误：

- 未执行 `gitlab-ctl reconfigure` 命令。
- 执行期间发生错误。

例如：

- `ERROR:  relation "node_status" does not exist at character 13`
- `ERROR:  relation "replication_queue_lock" does not exist at character 40`
- 此错误：

  ```json
  {"level":"error","msg":"Error updating node: pq: relation \"node_status\" does not exist","pid":210882,"praefectName":"gitlab1x4m:0.0.0.0:2305","time":"2021-04-01T19:26:19.473Z","virtual_storage":"praefect-cluster-1"}
  ```

要解决此问题，可以使用 `praefect` 命令的 `sql-migrate` 子命令执行数据库架构迁移：

```shell
$ sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml sql-migrate
praefect sql-migrate: OK (applied 21 migrations)
```

<a id="requests-fail-with-repository-scoped-invalid-repository-errors"></a>

## 请求失败并显示“repository scoped: invalid Repository”错误

这表明 [Praefect 配置](configure.md#praefect)中使用的虚拟存储名称与极狐GitLab 的 [`gitaly['configuration'][:storage][<index>][:name]` 设置](configure.md#gitaly)中使用的存储名称不匹配。

通过使 Praefect 和极狐GitLab 配置中使用的虚拟存储名称相匹配来解决此问题。

<a id="gitaly-cluster-praefect-performance-issues-on-cloud-platforms"></a>

## 云平台上 Gitaly 集群（Praefect）的性能问题

Praefect 不需要大量 CPU 或内存，可以在小型虚拟机上运行。云服务可能会对小型虚拟机可使用的资源施加其他限制，例如磁盘 IO 和网络流量。

Praefect 节点会产生大量网络流量。如果其网络带宽被云服务限流，可能会观察到以下症状：

- Git 操作性能不佳。
- 网络延迟高。
- Praefect 内存使用率高。

可能的解决方案：

- 预配更大的虚拟机，以获得更大的网络流量配额。
- 使用云服务的监控和日志记录来检查 Praefect 节点是否未耗尽它们的流量配额。

<a id="gitlab-ctl-reconfigure-fails-with-a-praefect-configuration-error"></a>

## `gitlab-ctl reconfigure` 因 Praefect 配置错误而失败

如果 `gitlab-ctl reconfigure` 失败，您可能会看到此错误：

```plaintext
STDOUT: praefect: configuration error: error reading config file: toml: cannot store TOML string into a Go int
```

当 `praefect['database_port']` 或 `praefect['database_direct_port']` 被配置为字符串而不是整数时，会发生此错误。

<a id="common-replication-errors"></a>

## 常见复制错误

以下是一些常见复制错误及其可能的解决方案。

<a id="lock-file-exists"></a>

### 锁文件存在

锁文件用于防止对同一 ref 进行多次更新。有时锁文件会变得陈旧，复制会失败并显示错误 `error: cannot lock ref`。

要清除陈旧的 `*.lock` 文件，您可以在 [Rails 控制台](../../operations/rails_console.md)上触发 `OptimizeRepositoryRequest`：

```ruby
p = Project.find <Project ID>
client = Gitlab::GitalyClient::RepositoryService.new(p.repository)
client.optimize_repository
```

如果触发 `OptimizeRepositoryRequest` 不起作用，请手动检查这些文件以确认创建日期，并决定是否可以手动删除 `*.lock` 文件。任何创建时间超过 24 小时的锁文件都可以安全删除。

<a id="git-fsck-errors"></a>

### Git `fsck` 错误

包含无效对象的 Gitaly 代码仓库可能导致复制失败，并在 Gitaly 日志中出现如下错误：

- `exit status 128, stderr: "fatal: git upload-pack: not our ref"`。
- `"fatal: bad object 58....e0f... ssh://gitaly/internal.git did not send all necessary objects`。

只要其中一个 Gitaly 节点仍拥有该代码仓库的健康副本，就可以通过以下方式修复这些问题：

1. [从 Praefect 数据库中移除该代码仓库](recovery.md#manually-remove-repositories)。
1. 使用 [Praefect `track-repository` 子命令](recovery.md#manually-add-a-single-repository-to-the-tracking-database)重新跟踪它。

这将使用来自权威 Gitaly 节点的代码仓库副本覆盖所有其他 Gitaly 节点上的副本。在运行这些命令之前，请确保已对该代码仓库进行最近的备份。

1. 将损坏的代码仓库移出原位：

   ```shell
   run `mv <REPOSITORY_PATH> <REPOSITORY_PATH>.backup`
   ```

   例如：

   ```shell
   mv /var/opt/gitlab/git-data/repositories/@cluster/repositories/de/74/2335 /var/opt/gitlab/git-data/repositories/@cluster/repositories/de/74/2335.backup
   ```

1. 运行 Praefect 命令以触发复制：

   ```shell
   # Validate you have the correct repository.
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage gitaly -relative-path '<relative_path>' -db-only

   # Run again with '--apply' flag to remove repository from the Praefect tracking database
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage gitaly -relative-path '<relative_path>' -db-only --apply

   # Re-track the repository, overwriting the secondary nodes
   sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repository -virtual-storage gitaly -authoritative-storage '<healthy_gitaly>' -relative-path '<relative_path>' -replica-path '<replica_path>'-replicate-immediately
   ```

<a id="replication-fails-silently"></a>

### 复制静默失败

如果 [Praefect `dataloss`](recovery.md#check-for-data-loss) 显示[代码仓库部分不可用](recovery.md#unavailable-replicas-of-available-repositories)，并且 [`accept-dataloss` 命令](recovery.md#accept-data-loss)无法同步该代码仓库，且日志中没有任何错误，这可能是由于 Praefect 数据库中 `storage_repositories` 表的 `repository_id` 字段不匹配所致。要检查是否不匹配：

1. 连接到 Praefect 数据库。
1. 运行以下查询：

   ```sql
   select * from storage_repositories where relative_path = '<relative-path>';
   ```

   将 `<relative-path>` 替换为[以 `@hashed` 开头](../../repository_storage_paths.md#hashed-storage)的代码仓库路径。

<a id="alternate-directory-does-not-exist"></a>

### 备用目录不存在

极狐GitLab 使用 Git alternates 机制进行去重。`alternates` 是一个文本文件，它指向
`@pool` 代码仓库上的 `objects` 目录以获取对象。如果此文件指向无效路径，复制可能会失败并出现以下错误之一：

- `"error":"no alternates directory exists", "warning","msg":"alternates file does not point to valid git repository"`
- `"error":"unexpected alternates content:`
- `remote: error: unable to normalize alternate object path`

要调查此错误的原因：

1. 使用 [Rails 控制台](../../operations/rails_console.md)检查该项目是否属于某个池：

   ```ruby
   project = Project.find_by_id(<project id>)
   project.pool_repository
   ```

1. 检查池代码仓库路径是否存在于磁盘上，以及它是否与 `alternates` 文件内容匹配。
1. 检查 `alternates` 文件中的路径是否可从项目中的 `objects` 目录访问。

执行这些检查后，请携带所收集的信息联系极狐GitLab 支持。

<a id="projects-are-stuck-in-read-only-state-after-failed-repository-storage-moves"></a>

### 代码仓库存储移动失败后项目卡在只读状态

在将水平 Pod 自动扩缩器（HPA）与 Sidekiq pod 一起使用时，由于作业执行期间 pod 扩缩，代码仓库存储移动可能会静默失败。如果代码仓库存储移动因此问题而失败，失败的项目可能会一直卡在只读状态。

要恢复受影响的代码仓库：

1. [将受影响的项目重置为读写状态](../../read_only_gitlab.md#make-the-repositories-read-only)。
1. [为 Sidekiq pod 禁用 HPA](https://gitlab.cn/docs/charts/charts/gitlab/sidekiq/#disable-hpa-scaling)
1. [使用 REST API 重新运行存储移动](../../operations/moving_repositories.md)，针对各个项目。
1. 迁移完成后恢复 HPA 配置。
