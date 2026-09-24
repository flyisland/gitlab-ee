---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gitaly 集群 (Praefect) 恢复选项与工具
---

Gitaly 集群 (Praefect) 可从主节点故障和不可用的仓库中恢复。Gitaly 集群 (Praefect) 可执行数据恢复，并具备 Praefect 跟踪数据库工具。

<a id="manage-gitaly-nodes-on-a-gitaly-cluster-praefect"></a>

## 管理 Gitaly 集群 (Praefect) 上的 Gitaly 节点

您可以在 Gitaly 集群 (Praefect) 上添加和替换 Gitaly 节点。

<a id="add-new-gitaly-nodes"></a>

### 添加新的 Gitaly 节点

要添加新的 Gitaly 节点：

1. 按照 [文档](configure.md#gitaly) 安装新的 Gitaly 节点。
1. 在 `praefect['virtual_storages']` 下将新节点添加到您的 [Praefect 配置](configure.md#praefect) 中。
1. 运行以下命令重新配置并重启 Praefect：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart praefect
   ```

复制行为取决于您的复制因子设置。

<a id="custom-replication-factor"></a>

#### 自定义复制因子

如果设置了自定义复制因子，Praefect 不会自动将现有仓库复制到新的 Gitaly 节点。您必须使用 `set-replication-factor` Praefect 命令为每个仓库设置 [复制因子](configure.md#configure-replication-factor)。新仓库将根据 [复制因子](configure.md#configure-replication-factor) 进行复制。

<a id="default-replication-factor"></a>

#### 默认复制因子

如果使用默认复制因子，Praefect 会自动将所有数据复制到任何新添加的 Gitaly 节点，以维持复制因子。

<a id="replace-an-existing-gitaly-node"></a>

### 替换现有的 Gitaly 节点

您可以使用具有相同名称或不同名称的新节点来替换现有的 Gitaly 节点。在移除旧节点之前：

- 如果设置了复制因子，其值必须大于 1 以防止数据丢失。
- 如果未设置复制因子，则仓库会在虚拟存储下的每个节点上复制。

当主 Gitaly 节点被移除时，由该节点管理的仓库将变得不可用，直到：

- 替换该节点并进行复制。
- 一个新的替换节点变得可用，其中包含被替换主节点的数据。

当节点不可用时，对受影响仓库的读取请求将失败并返回 `404` 错误。Gitaly 会在下一次对受影响仓库的写入尝试时，通过触发故障转移以建立新的主节点来自动解决此问题。

<a id="with-a-node-with-the-same-name"></a>

#### 使用相同名称的节点

要使用相同名称的替换节点，请使用 [仓库验证器](configure.md#enable-deletions) 扫描存储并删除悬空的元数据记录。[手动优先验证](configure.md#prioritize-verification-manually) 被替换的存储以加快此过程。

<a id="with-a-node-with-a-different-name"></a>

#### 使用不同名称的节点

为 Gitaly 集群 (Praefect) 使用不同名称的节点替换节点的步骤取决于是否设置了 [复制因子](configure.md#configure-replication-factor)。

如果设置了自定义复制因子，请使用 [`praefect set-replication-factor`](configure.md#configure-replication-factor) 再次为每个仓库设置复制因子，以分配新的存储。

例如，如果虚拟存储中的两个节点的复制因子为 2，并且添加了一个新节点 (`gitaly-3`)，您应该将复制因子增加到 3：

```shell
$ sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml set-replication-factor -virtual-storage default -relative-path @hashed/3f/db/3fdba35f04dc8c462986c992bcf875546257113072a909c162f7e470e581e278.git -replication-factor 3

current assignments: gitaly-1, gitaly-2, gitaly-3
```

这确保了仓库被复制到新节点，并且 `repository_assignments` 表会更新为新 Gitaly 节点的名称。

如果设置了 [默认复制因子](configure.md#configure-replication-factor)，新节点不会自动包含在复制中。您必须按照前面描述的步骤操作。

在您 [验证](#check-for-data-loss) 仓库已成功复制到新节点后：

1. 从 `praefect['virtual_storages']` 下的 [Praefect 配置](configure.md#praefect) 中移除 `gitaly-1` 节点。
1. 重新配置并重启 Praefect：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart praefect
   ```

引用旧 Gitaly 节点的数据库状态可以忽略。

另一种方法是，在配置好新的 Gitaly 节点后，将所有仓库从旧存储重新分配给新存储：

1. 连接到 Praefect 数据库：

   ```shell
   /opt/gitlab/embedded/bin/psql -h <psql host> -U <user> -d <database name>
   ```

1. 更新 `repository_assignments` 表，将旧的 Gitaly 节点名称（例如 `old-gitaly`）替换为新的 Gitaly 节点名称（例如 `new-gitaly`）：

   ```sql
   UPDATE repository_assignments SET storage='new-gitaly' WHERE storage='old-gitaly';
   ```

这将触发相应的复制任务，使系统恢复到所需状态。

<a id="primary-node-failure"></a>

## 主节点故障

Gitaly 集群 (Praefect) 通过将一个健康的次级节点提升为新的主节点来从故障的主 Gitaly 节点中恢复。Gitaly 集群 (Praefect)：

- 选择一个拥有完全最新仓库副本的健康次级节点作为新的主节点。
- 如果没有完全最新的次级节点，则选择距主节点未提交写入最少的次级节点作为新的主节点。
- 如果健康的次级节点上没有完全最新的副本，仓库将变得不可用。使用 [Praefect `dataloss` 子命令](#check-for-data-loss) 来检测此情况。

<a id="unavailable-repositories"></a>

### 不可用的仓库

如果仓库的所有最新副本都不可用，则该仓库不可用。不可用的仓库无法通过 Praefect 访问，以防止提供可能破坏自动化工具的过时数据。

<a id="check-for-data-loss"></a>

### 检查数据丢失

Praefect `dataloss` 子命令可识别不可用的仓库。这有助于识别潜在的数据丢失，以及因所有最新副本均不可用而无法再访问的仓库。

以下参数可用：

- `-virtual-storage` 指定要检查的虚拟存储。默认行为是显示不可用的仓库，因为可能需要管理员介入。
- [`-partially-unavailable`](#unavailable-replicas-of-available-repositories) 指定是否在输出中包含那些可用但某些分配副本不可用的仓库。

> [!note]
> `dataloss` 仍处于 [测试版](../../../policy/development_stages_support.md#beta) 状态，输出格式可能会发生变化。

要检查具有过时主节点或不可用仓库的仓库，请运行：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dataloss [-virtual-storage <virtual-storage>]
```

如果未指定，将检查每个已配置的虚拟存储：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dataloss
```

输出中会列出没有健康且完全最新副本的仓库。每个仓库会打印以下信息：

- 仓库相对于存储目录的路径用于标识每个仓库，并将相关信息分组。
- 如果仓库不可用，磁盘路径旁边会打印 `(unavailable)`。
- 主字段列出仓库的当前主节点。如果仓库没有主节点，该字段显示 `No Primary`。
- In-Sync Storages 列出已复制了最近一次成功写入及之前所有写入的副本。
- Outdated Storages 列出包含过时仓库副本的副本。此处还会列出应包含仓库副本但实际上没有的副本。副本旁边会列出副本缺少的最大更改数。请注意，过时的副本可能完全最新或包含更新的更改，但 Praefect 无法保证。

其他信息包括：

- 每个节点的状态旁边会列出该节点是否被分配来托管仓库。`assigned host` 会打印在已分配存储该仓库的节点旁边。如果节点包含仓库副本但未被分配存储该仓库，则省略该文本。此类副本不由 Praefect 保持同步，但可作为复制源以使已分配的副本达到最新。
- `unhealthy` 会打印在位于不健康的 Gitaly 节点上的副本旁边。

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

当每个仓库都可用时，会打印一条确认信息。例如：

```shell
Virtual storage: default
  All repositories are available!
```

<a id="unavailable-replicas-of-available-repositories"></a>

#### 可用仓库的不可用副本

要同时列出那些可用但某些分配节点不可用的仓库信息，请使用 `-partially-unavailable` 标志。

如果有健康、最新的副本可用，仓库即为可用。某些分配的次级副本在等待复制最新更改时可能暂时无法访问。

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

设置 `-partially-unavailable` 标志后，如果每个分配的副本都完全最新且健康，则会打印一条确认信息。

例如：

```shell
Virtual storage: default
  All repositories are fully available on all assigned storages!
```

<a id="check-repository-checksums"></a>

### 检查仓库校验和

要在所有 Gitaly 节点上检查项目的仓库校验和，请在主极狐GitLab 节点上运行 [副本 Rake 任务](../../raketasks/praefect.md#replica-checksums)。

<a id="accept-data-loss"></a>

### 接受数据丢失

> [!warning]
> `accept-dataloss` 会通过覆盖其他版本的仓库而导致永久性数据丢失。在使用前必须先进行 [数据恢复工作](#data-recovery)。

如果无法将某个最新的副本重新联机，您可能需要接受数据丢失。在接受数据丢失时，Praefect 会将仓库的选定副本标记为最新版本，并将其复制到其他分配的 Gitaly 节点。此过程会覆盖任何其他版本的仓库，因此必须谨慎操作。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml accept-dataloss
-virtual-storage <virtual-storage> -relative-path <relative-path> -authoritative-storage <storage-name>
```

<a id="enable-writes-or-accept-data-loss"></a>

### 启用写入或接受数据丢失

> [!warning]
> `accept-dataloss` 会通过覆盖其他版本的仓库而导致永久性数据丢失。在使用前必须先进行 [数据恢复工作](#data-recovery)。

Praefect 提供以下子命令来重新启用写入或接受数据丢失。如果无法将某个最新的节点重新联机，您可能需要接受数据丢失：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml accept-dataloss -virtual-storage <virtual-storage> -relative-path <relative-path> -authoritative-storage <storage-name>
```

在接受数据丢失时，Praefect：

1. 将仓库的选定副本标记为最新版本。
1. 将该副本复制到其他分配的 Gitaly 节点。

   此过程会覆盖任何其他仓库副本，因此必须谨慎操作。

<a id="data-recovery"></a>

## 数据恢复

如果 Gitaly 节点因任何原因未能完成复制任务，它将托管受影响仓库的过时版本。Praefect 提供了自动协调的工具。这些工具可协调过时的仓库，使其重新完全保持最新。

Praefect 会自动协调不同步的仓库。默认每隔五分钟执行一次。对于健康 Gitaly 节点上的每个过时仓库，Praefect 会从另一个健康 Gitaly 节点上选择一个随机的、完全最新的仓库副本作为复制源。仅当目标仓库没有其他待处理的复制任务时，才会安排复制任务。

协调频率可以通过配置更改。该值可以是任何有效的 [Go 时间间隔值](https://pkg.go.dev/time#ParseDuration)。低于 0 的值将禁用此功能。

示例：

```ruby
praefect['configuration'] = {
   # ...
   reconciliation: {
      # ...
      scheduling_interval: '5m', # 默认值
   },
}
```

```ruby
praefect['configuration'] = {
   # ...
   reconciliation: {
      # ...
      scheduling_interval: '30s', # 每 30 秒协调一次
   },
}
```

```ruby
praefect['configuration'] = {
   # ...
   reconciliation: {
      # ...
      scheduling_interval: '0', # 禁用该功能
   },
}
```

<a id="manually-remove-repositories"></a>

### 手动移除仓库

`remove-repository` Praefect 子命令可从 Gitaly 集群 (Praefect) 中移除仓库，以及与给定仓库关联的所有状态，包括：

- 所有相关 Gitaly 节点上的磁盘仓库。
- Praefect 跟踪的任何数据库状态。

默认情况下，该命令以演练模式运行。例如：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage <virtual-storage> -relative-path <repository>
```

- 将 `<virtual-storage>` 替换为包含该仓库的虚拟存储名称。
- 将 `<repository>` 替换为要移除的仓库的相对路径。
- 添加 `-db-only` 可移除 Praefect 跟踪数据库条目，而无需移除磁盘仓库。使用此选项可移除孤立的数据库条目，并在意外指定了有效仓库时保护磁盘仓库数据免遭删除。如果数据库条目被意外删除，请使用 [`track-repository` 命令](#manually-add-a-single-repository-to-the-tracking-database) 重新跟踪仓库。
- 添加 `-apply` 可在非演练模式下运行命令并移除仓库。例如：

  ```shell
  sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage <virtual-storage> -relative-path <repository> -apply
  ```

- `-virtual-storage` 是仓库所在的虚拟存储。虚拟存储在 `/etc/gitlab/gitlab.rb` 中的 `praefect['configuration']['virtual_storage]` 下配置，类似于：

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

- `-repository` 是仓库在存储中的相对路径，[以 `@hashed` 开头](../../repository_storage_paths.md#hashed-storage)。例如：

  ```plaintext
  @hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git
  ```

运行 `remove-repository` 后，仓库的部分内容可能仍然存在。这可能是因为：

- 删除错误。
- 正在进行的针对仓库的 RPC 调用。

如果发生这种情况，请再次运行 `remove-repository`。

<a id="praefect-tracking-database-maintenance"></a>

## Praefect 跟踪数据库维护

本节记录了 Praefect 跟踪数据库的常见维护任务。

<a id="list-untracked-repositories"></a>

### 列出未跟踪的仓库

`list-untracked-repositories` Praefect 子命令列出 Gitaly 集群 (Praefect) 中满足以下条件的仓库：

- 至少存在于一个 Gitaly 存储上。
- 未在 Praefect 跟踪数据库中跟踪。

添加 `-older-than` 选项可避免显示以下仓库：

- 正在创建过程中的仓库。
- Praefect 跟踪数据库中尚不存在记录的仓库。

将 `<duration>` 替换为时间间隔（例如 `5s`、`10m` 或 `1h`）。默认为 `6h`。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-untracked-repositories -older-than <duration>
```

仅考虑创建时间早于指定时间间隔的仓库。

该命令输出：

- 结果到 `STDOUT` 和命令的日志。
- 错误到 `STDERR`。

每个条目都是一个完整的 JSON 字符串，末尾带有换行符（可使用 `-delimiter` 标志配置）。例如：

```plaintext
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-untracked-repositories
{"virtual_storage":"default","storage":"gitaly-1","relative_path":"@hashed/ab/cd/abcd123456789012345678901234567890123456789012345678901234567890.git"}
{"virtual_storage":"default","storage":"gitaly-1","relative_path":"@hashed/ab/cd/abcd123456789012345678901234567890123456789012345678901234567891.git"}
```

<a id="manually-add-a-single-repository-to-the-tracking-database"></a>

### 手动将单个仓库添加到跟踪数据库

> [!warning]
> 由于一个 [已知问题](https://jihulab.com/gitlab-cn/gitaly/-/issues/5402)，在极狐GitLab 16.0 及更早版本中，您无法使用 Praefect 生成的副本路径 (`@cluster`) 将仓库添加到 Praefect 跟踪数据库。这些仓库与极狐GitLab 使用的仓库路径不关联，因此无法访问。

`track-repository` Praefect 子命令将磁盘上的仓库添加到 Praefect 跟踪数据库以进行跟踪。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repository -virtual-storage <virtual-storage> -authoritative-storage <storage-name> -relative-path <repository> -replica-path <disk_path> -replicate-immediately
```

- `-virtual-storage` 是仓库所在的虚拟存储。虚拟存储在 `/etc/gitlab/gitlab.rb` 中的 `praefect['configuration'][:virtual_storage]` 下配置，类似于：

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

- `-relative-path` 是虚拟存储中的相对路径。通常 [以 `@hashed` 开头](../../repository_storage_paths.md#hashed-storage)。例如：

  ```plaintext
  @hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git
  ```

- `-replica-path` 是物理存储上的相对路径。可以以 [`@cluster` 开头或匹配 `relative_path`](../../repository_storage_paths.md#gitaly-cluster-praefect-storage)。
- `-authoritative-storage` 是我们希望 Praefect 视为主节点的存储。如果 [每个仓库的复制](configure.md#configure-replication-factor) 被设置为复制策略，则此参数为必需。
- `-replicate-immediately` 使命令立即将仓库复制到其次级节点。否则，复制任务将被安排在数据库中执行，并由 Praefect 后台进程接管。

该命令输出：

- 结果到 `STDOUT` 和命令的日志。
- 错误到 `STDERR`。

如果出现以下情况，此命令将失败：

- 仓库已被 Praefect 跟踪数据库跟踪。
- 仓库在磁盘上不存在。

<a id="manually-add-many-repositories-to-the-tracking-database"></a>

### 手动将多个仓库添加到跟踪数据库

> [!warning]
> 由于一个 [已知问题](https://jihulab.com/gitlab-cn/gitaly/-/issues/5402)，在极狐GitLab 16.0 及更早版本中，您无法使用 Praefect 生成的副本路径 (`@cluster`) 将仓库添加到 Praefect 跟踪数据库。这些仓库与极狐GitLab 使用的仓库路径不关联，因此无法访问。

使用 API 进行的迁移会自动将仓库添加到 Praefect 跟踪数据库。

如果您是手动从现有基础设施复制仓库，则可以使用 `track-repositories` Praefect 子命令。此子命令可将大量磁盘仓库添加到 Praefect 跟踪数据库。

```shell
# Omnibus 极狐GitLab 安装
sudo gitlab-ctl praefect track-repositories --input-path /path/to/input.json

# 源码安装
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repositories -input-path /path/to/input.json
```

该命令会验证所有条目：

- 格式正确且包含必需字段。
- 对应于磁盘上的一个有效 Git 仓库。
- 未被 Praefect 跟踪数据库跟踪。

如果任何条目未通过这些检查，命令将在尝试跟踪任何仓库之前中止。

- `input-path` 是指向一个文件的路径，该文件包含以换行符分隔的 JSON 对象列表，表示仓库。对象必须包含以下键：
  - `relative_path`：对应于 [`track-repository`](#manually-add-a-single-repository-to-the-tracking-database) 中的 `repository`。
  - `authoritative-storage`：Praefect 应视为主节点的存储。
  - `virtual-storage`：仓库所在的虚拟存储。

    例如：

    ```json
    {"relative_path":"@hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git","replica_path":"@cluster/fe/d3/1","authoritative_storage":"gitaly-1","virtual_storage":"default"}
    {"relative_path":"@hashed/f8/9f/f89f8d0e735a91c5269ab08d72fa27670d000e7561698d6e664e7b603f5c4e40.git","replica_path":"@cluster/7b/28/2","authoritative_storage":"gitaly-2","virtual_storage":"default"}
    ```

- `-replicate-immediately` 使命令立即将仓库复制到其次级节点。否则，复制任务将被安排在数据库中执行，并由 Praefect 后台进程接管。

<a id="list-virtual-storage-details"></a>

### 列出虚拟存储详情

`list-storages` Praefect 子命令列出虚拟存储及其关联的存储节点。如果指定了：

- 使用 `-virtual-storage` 指定虚拟存储，则仅列出指定虚拟存储的存储节点。
- 未指定，则以表格格式列出所有虚拟存储及其关联的存储节点。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-storages -virtual-storage <virtual_storage_name>
```

该命令输出：

- 结果到 `STDOUT` 和命令的日志。
- 错误到 `STDERR`。