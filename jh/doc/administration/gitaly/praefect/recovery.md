---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gitaly 集群（Praefect）的恢复选项和工具
---

Gitaly 集群（Praefect）可以从主节点故障和不可用的代码仓库中恢复。Gitaly 集群（Praefect）
可以执行数据恢复，并具有 Praefect 跟踪数据库工具。

<a id="manage-gitaly-nodes-on-a-gitaly-cluster-praefect"></a>

## 在 Gitaly 集群（Praefect）上管理 Gitaly 节点

您可以在 Gitaly 集群（Praefect）上添加和替换 Gitaly 节点。

<a id="add-new-gitaly-nodes"></a>

### 添加新的 Gitaly 节点

要添加新的 Gitaly 节点：

1. 按照[文档](configure.md#gitaly)安装新的 Gitaly 节点。
1. 在 `praefect['virtual_storages']` 下的 [Praefect 配置](configure.md#praefect)中添加新节点。
1. 运行以下命令重新配置并重启 Praefect：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart praefect
   ```

复制行为取决于您的复制因子设置。

<a id="custom-replication-factor"></a>

#### 自定义复制因子

如果设置了自定义复制因子，Praefect 不会自动将现有代码仓库复制到新的 Gitaly 节点。您必须使用 `set-replication-factor` Praefect 命令为每个代码仓库设置[复制因子](configure.md#configure-replication-factor)。新代码仓库会根据[复制因子](configure.md#configure-replication-factor)进行复制。

<a id="default-replication-factor"></a>

#### 默认复制因子

如果使用默认复制因子，Praefect 会自动将所有数据复制到添加到配置中的任何新 Gitaly 节点，以维持复制因子。

<a id="replace-an-existing-gitaly-node"></a>

### 替换现有的 Gitaly 节点

您可以将现有 Gitaly 节点替换为同名或不同名的新节点。

<a id="replacing-primary-nodes"></a>

#### 替换主节点

Gitaly 集群（Praefect）会为每个代码仓库单独选举一个主节点。当您移除某个代码仓库的主节点时，结果取决于是否仍存在最新的副本。

如果剩余的健康节点上存在最新的副本，该代码仓库保持可用。读取操作由该最新副本提供，Praefect 会在下一次需要主节点的请求中，从有效候选中选举新的主节点。用户不受影响。

如果不存在最新的副本（被移除的节点持有最后一份当前副本），该代码仓库将变为不可用。Praefect 对读取操作返回 `404`，而不是提供过期的副本。该代码仓库会一直不可用，直到以下任一操作恢复最新副本：

- 该节点被恢复（同名）并重新复制。
- 包含该代码仓库数据的替换节点变为可用（不同名）。

由于不可用的代码仓库没有有效的主节点候选可供选举，读取操作无法恢复它：没有可路由请求的目标。下一次写入会通过提升最佳可用副本（未复制变更最少的那个）来重新建立主节点，这可能导致仅存在于被移除节点上的写入数据丢失。要完全避免这种情况，请在移除节点前，确保该节点上的每个代码仓库在剩余的健康节点上都有最新的副本。

Gitaly 集群（Praefect）不提供手动触发主节点重新选举的命令。最接近的选项是 [`accept-dataloss`](#accept-data-loss) 子命令，它会将指定的存储设置为某个相对路径的主节点，并从该存储而不是旧主节点开始复制。

<a id="prepare-to-remove-a-node"></a>

#### 准备移除节点

在移除旧节点之前，请确保它持有的每个代码仓库在另一个健康节点上都有最新的副本：

1. 确认复制因子允许冗余：
   - 如果设置了复制因子，它必须大于 `1`。复制因子为 `1` 时，移除节点会导致数据丢失。
   - 如果未设置复制因子，代码仓库会复制到虚拟存储中的每个节点，因此其他地方已经存在副本。
1. 确保池代码仓库复制到与其上游代码仓库及其 fork 相同的节点。池代码仓库
   在复制方面与其他代码仓库同等对待，但较旧的集群可能存在池代码仓库
   未与其依赖的代码仓库位于同一位置的情况。
1. 使用 [`dataloss`](#check-for-data-loss) 子命令确认每个受影响的代码仓库在您保留的节点上都有最新的、已分配的副本。
1. 将极狐GitLab 实例置于[维护模式](../../maintenance_mode/_index.md)，以便在您移除节点期间，
   集群不会处理新的写入。

<a id="use-the-same-name"></a>

#### 使用相同的名称

要为替换节点使用相同的名称，请使用[代码仓库验证器](configure.md#enable-deletions)扫描存储并移除悬空的元数据记录。[手动优先验证](configure.md#prioritize-verification-manually)被替换的存储，以加快该过程。

<a id="use-a-different-name"></a>

#### 使用不同的名称

为替换节点使用不同的名称时，如何将代码仓库迁移到新节点取决于您的[复制因子](configure.md#configure-replication-factor)配置。

如果设置了自定义复制因子，现有代码仓库不会自动复制到新添加的节点。请使用以下方法之一填充新节点：

- 使用 [`praefect set-replication-factor`](configure.md#configure-replication-factor) **提高复制因子**。
  这会从未分配的已配置存储中随机选择一个额外的存储。它不会
  优先选择新添加的节点。在具有多个未分配存储的集群中，新副本可能
  落在其中任何一个上，包括您打算停用的节点。在增加冗余时使用此方法，而不是在
  旧节点容量受限时使用。

  例如，如果虚拟存储中的两个节点的复制因子为 2，并且添加了一个新节点（`gitaly-3`），您可以将复制因子提高到 3：

  ```shell
  $ sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml set-replication-factor -virtual-storage default -relative-path @hashed/3f/db/3fdba35f04dc8c462986c992bcf875546257113072a909c162f7e470e581e278.git -replication-factor 3

  current assignments: gitaly-1, gitaly-2, gitaly-3
  ```

  这确保代码仓库被复制到新节点，并且 `repository_assignments` 表会更新为新的 Gitaly 节点名称。

- 通过更新 `repository_assignments` 表，**在相同复制因子下重新分配**。这会在不添加副本的情况下
  将旧存储替换为新存储，是在您排空节点或
  源容量有限时推荐的方法。请参阅本节后面的重新分配步骤。

如果设置了[默认复制因子](configure.md#configure-replication-factor)，Praefect 会自动将所有代码仓库复制到任何新添加的节点，以维持该因子。无需按代码仓库执行操作。

在您[验证](#check-for-data-loss)代码仓库已成功复制到新节点后：

1. 从 `praefect['virtual_storages']` 下的 [Praefect 配置](configure.md#praefect)中移除 `gitaly-1` 节点。
1. 重新配置并重启 Praefect：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart praefect
   ```

引用旧 Gitaly 节点的数据库状态可以忽略。

另一种方法是在配置新 Gitaly 节点后，将所有代码仓库从旧存储重新分配到新存储：

1. 连接到 Praefect 数据库：

   ```shell
   /opt/gitlab/embedded/bin/psql -h <psql host> -U <user> -d <database name>
   ```

1. 更新 `repository_assignments` 表，将旧的 Gitaly 节点名称（例如 `old-gitaly`）替换为新的 Gitaly 节点名称
   （例如 `new-gitaly`）：

   ```sql
   UPDATE repository_assignments SET storage='new-gitaly' WHERE storage='old-gitaly';
   ```

这会触发相应的复制作业，使系统恢复到所需状态。在您移除旧节点之前，请使用 [`dataloss`](#check-for-data-loss) 子命令确认每个受影响的代码仓库在新节点上都有最新的、已分配的副本。

<a id="primary-node-failure"></a>

## 主节点故障

Gitaly 集群（Praefect）通过将健康的从节点提升为新的主节点，从主 Gitaly 节点故障中恢复。
Gitaly 集群（Praefect）：

- 选举具有该代码仓库完整最新副本的健康从节点作为新的主节点。
- 如果没有完整最新的从节点可用，则选举尚未从主节点复制的写入最少的从节点作为新的主节点。
- 如果健康从节点上没有该代码仓库的完整最新副本，该代码仓库将变为不可用。使用 [Praefect `dataloss` 子命令](#check-for-data-loss)来检测它。

<a id="unavailable-repositories"></a>

### 不可用的代码仓库

如果某个代码仓库的所有最新副本都不可用，则该代码仓库不可用。不可用的代码仓库无法通过 Praefect 访问，以防止提供可能破坏自动化工具的过期数据。

<a id="check-for-data-loss"></a>

### 检查数据丢失

Praefect `dataloss` 子命令可识别不可用的代码仓库。这有助于识别潜在的数据丢失以及因所有最新副本都不可用而不再可访问的代码仓库。

以下参数可用：

- `-virtual-storage` 指定要检查的虚拟存储。由于它们可能需要
  管理员介入，默认行为是显示不可用的代码仓库。
- [`-partially-unavailable`](#unavailable-replicas-of-available-repositories)
  指定是否在输出中包含那些可用但
  部分已分配副本不可用的代码仓库。

> [!note]
> `dataloss` 仍处于 [beta](../../../policy/development_stages_support.md#beta) 阶段，输出格式可能会发生变化。

要检查主节点过期的代码仓库或不可用的代码仓库，请运行：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dataloss [-virtual-storage <virtual-storage>]
```

如果未指定，则会检查每个已配置的虚拟存储：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dataloss
```

输出中会列出没有健康且完整最新副本可用的代码仓库。每个代码仓库会打印以下信息：

- 代码仓库相对于存储目录的相对路径用于标识每个代码仓库，并对相关信息进行分组。
- 如果代码仓库不可用，会在磁盘路径旁边打印 `(unavailable)`。
- primary 字段列出代码仓库的当前主节点。如果代码仓库没有主节点，该字段显示
  `No Primary`。
- In-Sync Storages 列出已复制最新成功写入及其之前所有写入的副本。
- Outdated Storages 列出包含该代码仓库过期副本的副本。没有该代码仓库副本
  但应包含它的副本也会在此列出。副本缺失的最大变更数
  会列在副本旁边。需要注意的是，过期副本可能已完全最新或包含
  更新的变更，但 Praefect 无法保证。

其他信息包括：

- 每个节点的状态旁边会列出该节点是否被分配用于托管该代码仓库。
  被分配用于存储该代码仓库的节点旁边会打印 `assigned host`。如果节点包含该代码仓库的副本
  但未被分配用于存储该代码仓库，则省略该文本。此类副本不会被 Praefect 保持同步，
  但可以作为复制源，使已分配的副本保持最新。
- 位于不健康 Gitaly 节点上的副本旁边会打印 `unhealthy`。

示例输出：

```shell
Virtual storage: default
  Outdated repositories:
    @hashed/3f/db/3fdba35f04dc8c462986c992bcf875546257113072a909c162f7e470e581e278.git (unavailable):
      Primary: gitaly-1
      In-Sync Storages:
        gitaly-2, assigned host, unhealthy
      Outdated Storages:
        gitaly-1 is behind by 3 changes or less, assigned host
        gitaly-3 is behind by 3 changes or less
```

当每个代码仓库都可用时，会打印确认信息。例如：

```shell
Virtual storage: default
  All repositories are available!
```

<a id="unavailable-replicas-of-available-repositories"></a>

#### 可用代码仓库的不可用副本

要同时列出那些可用但从某些已分配节点不可用的代码仓库的信息，请使用 `-partially-unavailable` 标志。

如果存在健康、最新的副本可用，则该代码仓库可用。部分已分配的从副本在等待复制最新变更期间，可能会暂时无法访问。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dataloss [-virtual-storage <virtual-storage>] [-partially-unavailable]
```

示例输出：

```shell
Virtual storage: default
  Outdated repositories:
    @hashed/3f/db/3fdba35f04dc8c462986c992bcf875546257113072a909c162f7e470e581e278.git:
      Primary: gitaly-1
      In-Sync Storages:
        gitaly-1, assigned host
      Outdated Storages:
        gitaly-2 is behind by 3 changes or less, assigned host
        gitaly-3 is behind by 3 changes or less
```

设置 `-partially-unavailable` 标志后，如果每个已分配的副本都完全最新且健康，则会打印确认信息。

例如：

```shell
Virtual storage: default
  All repositories are fully available on all assigned storages!
```

<a id="check-repository-checksums"></a>

### 检查代码仓库校验和

要检查项目代码仓库在所有 Gitaly 节点上的校验和，请在主极狐GitLab 节点上运行[副本 Rake 任务](../../raketasks/praefect.md#replica-checksums)。

<a id="accept-data-loss"></a>

### 接受数据丢失

> [!warning]
> `accept-dataloss` 会通过覆盖代码仓库的其他版本导致永久性数据丢失。使用它之前
> 必须执行数据[恢复工作](#data-recovery)。

如果无法将其中一个最新副本恢复在线，您可能不得不接受数据丢失。接受数据丢失时，Praefect 会将所选代码仓库副本标记为最新版本，并将其复制到其他已分配的 Gitaly 节点。此过程会覆盖该代码仓库的任何其他版本，因此必须谨慎操作。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml accept-dataloss
-virtual-storage <virtual-storage> -relative-path <relative-path> -authoritative-storage <storage-name>
```

<a id="enable-writes-or-accept-data-loss"></a>

### 启用写入或接受数据丢失

> [!warning]
> `accept-dataloss` 会通过覆盖代码仓库的其他版本导致永久性数据丢失。
> 使用它之前必须执行数据[恢复工作](#data-recovery)。

Praefect 提供以下子命令来重新启用写入或接受数据丢失。如果无法将其中一个最新节点恢复在线，您可能不得不接受数据丢失：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml accept-dataloss -virtual-storage <virtual-storage> -relative-path <relative-path> -authoritative-storage <storage-name>
```

接受数据丢失时，Praefect：

1. 将所选代码仓库副本标记为最新版本。
1. 将该副本复制到其他已分配的 Gitaly 节点。

   此过程会覆盖该代码仓库的任何其他副本，因此必须谨慎操作。

<a id="data-recovery"></a>

## 数据恢复

如果 Gitaly 节点因任何原因导致复制作业失败，它最终会托管受影响代码仓库的过期版本。Praefect 提供自动协调工具。这些工具会协调过期的代码仓库，使其再次完全最新。

Praefect 会自动协调未保持最新的代码仓库。默认情况下，每五分钟执行一次。对于健康 Gitaly 节点上的每个过期代码仓库，Praefect 会在另一个健康 Gitaly 节点上随机选择一个完全最新的代码仓库副本作为复制源。仅当目标代码仓库没有其他待处理的复制作业时，才会安排复制作业。

协调频率可以通过配置更改。该值可以是任何有效的 [Go duration 值](https://pkg.go.dev/time#ParseDuration)。小于 0 的值会禁用该功能。

示例：

```ruby
praefect['configuration'] = {
   # ...
   reconciliation: {
      # ...
      scheduling_interval: '5m', # the default value
   },
}
```

```ruby
praefect['configuration'] = {
   # ...
   reconciliation: {
      # ...
      scheduling_interval: '30s', # reconcile every 30 seconds
   },
}
```

```ruby
praefect['configuration'] = {
   # ...
   reconciliation: {
      # ...
      scheduling_interval: '0', # disable the feature
   },
}
```

<a id="manually-remove-repositories"></a>

### 手动移除代码仓库

`remove-repository` Praefect 子命令会从 Gitaly 集群（Praefect）中移除代码仓库，以及与该代码仓库相关的所有状态，包括：

- 所有相关 Gitaly 节点上的磁盘代码仓库。
- Praefect 跟踪的任何数据库状态。

默认情况下，该命令以试运行模式运行。例如：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage <virtual-storage> -relative-path <repository>
```

- 将 `<virtual-storage>` 替换为包含该代码仓库的虚拟存储名称。
- 将 `<repository>` 替换为要移除的代码仓库的相对路径。
- 添加 `-db-only` 可移除 Praefect 跟踪数据库条目而不移除磁盘上的代码仓库。使用此选项可移除孤立的数据库条目，并在
  意外指定了有效代码仓库时保护磁盘上的代码仓库数据不被删除。如果数据库条目被意外删除，请使用
  [`track-repository` 命令](#manually-add-a-single-repository-to-the-tracking-database)重新跟踪该代码仓库。
- 添加 `-apply` 可在试运行模式之外运行该命令并移除代码仓库。例如：

  ```shell
  sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage <virtual-storage> -relative-path <repository> -apply
  ```

- `-virtual-storage` 是代码仓库所在的虚拟存储。虚拟存储在 `/etc/gitlab/gitlab.rb`中的 `praefect['configuration']['virtual_storage]` 下配置，如下所示：

  ```ruby
  praefect['configuration'] = {
    # ...
    virtual_storage: [
      {
        # ...
        name: 'default',
      },
      {
        # ...
        name: 'storage-1',
      },
    ],
  }
  ```

  在此示例中，要指定的虚拟存储是 `default` 或 `storage-1`。

- `-repository` 是代码仓库在存储中的相对路径[以 `@hashed` 开头](../../repository_storage_paths.md#hashed-storage)。
  例如：

  ```plaintext
  @hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git
  ```

运行 `remove-repository` 后，代码仓库的部分内容可能仍然存在。这可能是因为：

- 删除错误。
- 针对该代码仓库的进行中 RPC 调用。

如果发生这种情况，请再次运行 `remove-repository`。

<a id="praefect-tracking-database-maintenance"></a>

## Praefect 跟踪数据库维护

本节记录了 Praefect 跟踪数据库的常见维护任务。

<a id="list-untracked-repositories"></a>

### 列出未跟踪的代码仓库

`list-untracked-repositories` Praefect 子命令会列出 Gitaly 集群（Praefect）中同时满足以下条件的代码仓库：

- 至少存在于一个 Gitaly 存储上。
- 未在 Praefect 跟踪数据库中跟踪。

添加 `-older-than` 选项可避免显示以下代码仓库：

- 正在创建过程中。
- 在 Praefect 跟踪数据库中尚无记录。

将 `<duration>` 替换为时间长度（例如 `5s`、`10m` 或 `1h`）。默认为 `6h`。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-untracked-repositories -older-than <duration>
```

仅考虑创建时间早于指定时长的代码仓库。

该命令输出：

- 结果输出到 `STDOUT` 以及命令的日志。
- 错误输出到 `STDERR`。

每个条目都是一个完整的 JSON 字符串，末尾带换行符（可使用 `-delimiter` 标志配置）。例如：

```plaintext
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-untracked-repositories
{"virtual_storage":"default","storage":"gitaly-1","relative_path":"@hashed/ab/cd/abcd123456789012345678901234567890123456789012345678901234567890.git"}
{"virtual_storage":"default","storage":"gitaly-1","relative_path":"@hashed/ab/cd/abcd123456789012345678901234567890123456789012345678901234567891.git"}
```

<a id="manually-add-a-single-repository-to-the-tracking-database"></a>

### 手动将单个代码仓库添加到跟踪数据库

`track-repository` Praefect 子命令会将磁盘上的代码仓库添加到 Praefect 跟踪数据库中以进行跟踪。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repository -virtual-storage <virtual-storage> -authoritative-storage <storage-name> -relative-path <repository> -replica-path <disk_path> -replicate-immediately
```

- `-virtual-storage` 是代码仓库所在的虚拟存储。虚拟存储在 `/etc/gitlab/gitlab.rb`中的 `praefect['configuration'][:virtual_storage]` 下配置，如下所示：

  ```ruby
  praefect['configuration'] = {
    # ...
    virtual_storage: [
      {
        # ...
        name: 'default',
      },
      {
        # ...
        name: 'storage-1',
      },
    ],
  }
  ```

  在此示例中，要指定的虚拟存储是 `default` 或 `storage-1`。

- `-relative-path` 是虚拟存储中的相对路径。通常[以 `@hashed` 开头](../../repository_storage_paths.md#hashed-storage)。
  例如：

  ```plaintext
  @hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git
  ```

- `-replica-path` 是物理存储上的相对路径。可以以 [`@cluster` 开头或与 `relative_path` 匹配](../../repository_storage_paths.md#gitaly-cluster-praefect-storage)。
- `-authoritative-storage` 是我们希望 Praefect 视为主节点的存储。如果
  将[按代码仓库复制](configure.md#configure-replication-factor)设置为复制策略，则此项为必填。
- `-replicate-immediately` 会使该命令立即将代码仓库复制到其从节点。
  否则，复制作业会被安排在数据库中执行，并由 Praefect 后台进程处理。

该命令输出：

- 结果输出到 `STDOUT` 以及命令的日志。
- 错误输出到 `STDERR`。

在以下情况下，该命令会失败：

- 该代码仓库已被 Praefect 跟踪数据库跟踪。
- 该代码仓库在磁盘上不存在。

<a id="manually-add-many-repositories-to-the-tracking-database"></a>

### 手动将多个代码仓库添加到跟踪数据库

使用 API 的迁移会自动将代码仓库添加到 Praefect 跟踪数据库。

如果您改为从现有基础设施手动复制代码仓库，可以使用 `track-repositories` Praefect 子命令。此子命令会将大量磁盘上的代码仓库添加到 Praefect 跟踪数据库。

```shell
# Omnibus GitLab install
sudo gitlab-ctl praefect track-repositories --input-path /path/to/input.json

# Source install
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repositories -input-path /path/to/input.json
```

该命令会验证所有条目：

- 格式正确且包含必填字段。
- 对应磁盘上的有效 Git 代码仓库。
- 未在 Praefect 跟踪数据库中跟踪。

如果任何条目未通过这些检查，该命令会在尝试跟踪代码仓库之前中止。

- `input-path` 是包含代码仓库列表的文件的路径，该列表格式为以换行符分隔的 JSON 对象。对象必须包含以下键：
  - `relative_path`：对应 [`track-repository`](#manually-add-a-single-repository-to-the-tracking-database)中的 `repository`。
  - `authoritative-storage`：Praefect 要视为主节点的存储。
  - `virtual-storage`：代码仓库所在的虚拟存储。

    例如：

    ```json
    {"relative_path":"@hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git","replica_path":"@cluster/fe/d3/1","authoritative_storage":"gitaly-1","virtual_storage":"default"}
    {"relative_path":"@hashed/f8/9f/f89f8d0e735a91c5269ab08d72fa27670d000e7561698d6e664e7b603f5c4e40.git","replica_path":"@cluster/7b/28/2","authoritative_storage":"gitaly-2","virtual_storage":"default"}
    ```

- `-replicate-immediately` 会使该命令立即将代码仓库复制到其从节点。
  否则，复制作业会被安排在数据库中执行，并由 Praefect 后台进程处理。

<a id="list-virtual-storage-details"></a>

### 列出虚拟存储详细信息

`list-storages` Praefect 子命令会列出虚拟存储及其关联的存储节点。如果某个虚拟存储：

- 使用 `-virtual-storage` 指定，则仅列出指定虚拟存储的存储节点。
- 未指定，则以表格格式列出所有虚拟存储及其关联的存储节点。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-storages -virtual-storage <virtual_storage_name>
```

该命令输出：

- 结果输出到 `STDOUT` 以及命令的日志。
- 错误输出到 `STDERR`。
