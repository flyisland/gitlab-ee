---
stage: Systems
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Gitaly 集群恢复选项和工具
---

极狐GitLab 集群可以从主节点故障和不可用的仓库中恢复。极狐GitLab 集群可以执行数据恢复，并具有 Praefect 跟踪数据库工具。

<a id="manage-gitaly-nodes-on-a-gitaly-cluster"></a>

## 管理极狐GitLab 集群上的 Gitaly 节点

您可以在极狐GitLab 集群上添加和替换 Gitaly 节点。

<a id="add-new-gitaly-nodes"></a>

### 添加新的 Gitaly 节点

要添加新的 Gitaly 节点：

1. 按照[文档](praefect.md#gitaly)安装新的 Gitaly 节点。
1. 在 `praefect['virtual_storages']` 下将新节点添加到您的 [Praefect 配置](praefect.md#praefect)中。
1. 运行以下命令重新配置并重启 Praefect：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart praefect
   ```

复制行为取决于您的复制因子设置。

<a id="custom-replication-factor"></a>

#### 自定义复制因子

如果设置了自定义复制因子，Praefect 不会自动将现有仓库复制到新的 Gitaly 节点。您必须使用 `set-replication-factor` Praefect 命令为每个仓库设置[复制因子](praefect.md#configure-replication-factor)。新的仓库将根据[复制因子](praefect.md#configure-replication-factor)进行复制。

<a id="default-replication-factor"></a>

#### 默认复制因子

如果使用默认复制因子，Praefect 会自动将所有数据复制到配置中添加的任何新的 Gitaly 节点，以保持复制因子。

<a id="replace-an-existing-gitaly-node"></a>

### 替换现有的 Gitaly 节点

您可以使用相同名称或不同名称用新节点替换现有的 Gitaly 节点。在删除旧节点之前：

- 如果设置了复制因子，则必须大于 1，以防止数据丢失。
- 如果没有设置复制因子，则在虚拟存储下的每个节点上复制仓库。

<a id="with-a-node-with-the-same-name"></a>

#### 使用相同名称的节点

要为替换节点使用相同名称，请使用[仓库验证器](praefect.md#enable-deletions)扫描存储并删除悬挂的元数据记录。[手动优先验证](praefect.md#prioritize-verification-manually)替换存储以加速过程。

<a id="with-a-node-with-a-different-name"></a>

#### 使用不同名称的节点

为极狐GitLab 集群的替换节点使用不同名称的步骤取决于是否设置了[复制因子](praefect.md#configure-replication-factor)。

<a id="replication-factor-set"></a>

##### 设置了复制因子

如果设置了自定义复制因子，请使用 [`praefect set-replication-factor`](praefect.md#configure-replication-factor) 再次设置每个仓库的复制因子，以获得新存储分配。

例如，如果虚拟存储中的两个节点的复制因子为 2，并且添加了新节点 (`gitaly-3`)，您应该将复制因子增加到 3：

```shell
$ sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml set-replication-factor -virtual-storage default -relative-path @hashed/3f/db/3fdba35f04dc8c462986c992bcf875546257113072a909c162f7e470e581e278.git -replication-factor 3

current assignments: gitaly-1, gitaly-2, gitaly-3
```

这确保了仓库被复制到新节点，并且 `repository_assignments` 表更新了新 Gitaly 节点的名称。

如果设置了[默认复制因子](praefect.md#configure-replication-factor)，则新节点不会自动包含在复制中。您必须遵循上述步骤。

在您[验证](#check-for-data-loss)仓库成功复制到新节点后：

1. 从 `praefect['virtual_storages']` 下的 [Praefect 配置](praefect.md#praefect)中删除 `gitaly-1` 节点。
1. 重新配置并重启 Praefect：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart praefect
   ```

可以忽略指向旧 Gitaly 节点的数据库状态。

另一种选择是在配置新 Gitaly 节点后，将所有仓库从旧存储重新分配到新存储：

1. 连接到 Praefect 数据库：

   ```shell
   /opt/gitlab/embedded/bin/psql -h <psql host> -U <user> -d <database name>
   ```

1. 更新 `repository_assignments` 表，将旧 Gitaly 节点名称（例如 `old-gitaly`）替换为新 Gitaly 节点名称（例如 `new-gitaly`）：

   ```sql
   UPDATE repository_assignments SET storage='new-gitaly' WHERE storage='old-gitaly';
   ```

这将触发适当的复制作业，使系统恢复到所需状态。

<a id="primary-node-failure"></a>

## 主节点故障

极狐GitLab 集群通过将健康的次要节点提升为新的主节点来从故障的主 Gitaly 节点恢复。极狐GitLab 集群：

- 选择一个健康的次要节点作为新的主节点，该节点拥有最新的仓库副本。
- 如果没有完全更新的次要节点可用，则选择具有最少未复制写入的次要节点作为新的主节点。
- 如果健康的次要节点上没有完全更新的副本，仓库将变得不可用。使用 [Praefect `dataloss` 子命令](#check-for-data-loss)来检测它。

<a id="unavailable-repositories"></a>

### 不可用的仓库

如果所有最新副本都不可用，则仓库不可用。不可用的仓库无法通过 Praefect 访问，以防止提供可能破坏自动化工具的过时数据。

<a id="check-for-data-loss"></a>

### 检查数据丢失

Praefect `dataloss` 子命令识别不可用的仓库。这有助于识别潜在的数据丢失和由于所有最新副本不可用而不再可访问的仓库。

以下参数可用：

- `-virtual-storage` 指定要检查的虚拟存储。因为它们可能需要管理员干预，默认行为是显示不可用的仓库。
- [`-partially-unavailable`](#unavailable-replicas-of-available-repositories) 指定是否在输出中包含可用但有些分配副本不可用的仓库。

{{< alert type="note" >}}

`dataloss` 仍处于 [beta](../../policy/development_stages_support.md#beta) 阶段，输出格式可能会更改。

{{< /alert >}}

要检查有过时主节点的仓库或不可用的仓库，请运行：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dataloss [-virtual-storage <virtual-storage>]
```

如果未指定任何配置的虚拟存储，则会检查每个配置的虚拟存储：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dataloss
```

在输出中列出没有健康和完全更新副本的仓库。为每个仓库打印以下信息：

- 仓库的相对路径到存储目录标识每个仓库并分组相关信息。
- 如果仓库不可用，则在磁盘路径旁打印 `(unavailable)`。
- 主字段列出仓库的当前主节点。如果仓库没有主节点，该字段显示 `No Primary`。
- In-Sync Storages 列出已复制最新成功写入及其所有前写入的副本。
- Outdated Storages 列出包含过时仓库副本的副本。列出的副本没有仓库副本但应该包含它。副本缺失的最大变化数列在副本旁边。重要的是要注意，过时的副本可能是完全更新的或包含更改，但 Praefect 无法保证。

附加信息包括：

- 是否分配节点以托管仓库与每个节点的状态一起列出。`assigned host` 在分配存储仓库的节点旁打印。如果节点包含仓库副本但未分配存储仓库，则省略文本。这种副本不会由 Praefect 保持同步，但可能充当复制源以使分配的副本更新。
- `unhealthy` 在位于不健康 Gitaly 节点上的副本旁打印。

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

当每个仓库可用时打印确认。例如：

```shell
Virtual storage: default
  All repositories are available!
```

<a id="unavailable-replicas-of-available-repositories"></a>

#### 可用仓库的不可用副本

要列出信息的仓库可用但在某些分配节点上不可用，请使用 `-partially-unavailable` 标志。

如果有健康的、更新的副本可用，则仓库是可用的。分配的次要副本可能会暂时不可访问，因为它们正在等待复制最新更改。

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

设置 `-partially-unavailable` 标志后，如果每个分配副本都完全更新并健康，则打印确认。

例如：

```shell
Virtual storage: default
  All repositories are fully available on all assigned storages!
```

<a id="check-repository-checksums"></a>

### 检查仓库校验和

要检查项目的仓库校验和在所有 Gitaly 节点上，请在主极狐GitLab 节点上运行[副本 Rake 任务](../raketasks/praefect.md#replica-checksums)。

<a id="accept-data-loss"></a>

### 接受数据丢失

{{< alert type="warning" >}}

`accept-dataloss` 通过覆盖仓库的其他版本导致永久数据丢失。在使用它之前必须执行数据[恢复工作](#data-recovery)。

{{< /alert >}}

如果无法使其中一个最新副本重新上线，您可能需要接受数据丢失。接受数据丢失时，Praefect 将仓库的选定副本标记为最新版本，并将其复制到其他分配的 Gitaly 节点。此过程会覆盖仓库的任何其他版本，因此必须小心。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml accept-dataloss -virtual-storage <virtual-storage> -relative-path <relative-path> -authoritative-storage <storage-name>
```

<a id="enable-writes-or-accept-data-loss"></a>

### 启用写入或接受数据丢失

{{< alert type="warning" >}}

`accept-dataloss` 通过覆盖仓库的其他版本导致永久数据丢失。在使用它之前必须执行数据[恢复工作](#data-recovery)。

{{< /alert >}}

Praefect 提供以下子命令来重新启用写入或接受数据丢失。如果无法使其中一个最新节点重新上线，您可能必须接受数据丢失：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml accept-dataloss -virtual-storage <virtual-storage> -relative-path <relative-path> -authoritative-storage <storage-name>
```

接受数据丢失时，Praefect：

1. 将选定的仓库副本标记为最新版本。
1. 将副本复制到其他分配的 Gitaly 节点。

   此过程会覆盖仓库的任何其他副本，因此必须小心。

<a id="data-recovery"></a>

## 数据恢复

如果 Gitaly 节点由于任何原因失败复制作业，它最终会托管受影响仓库的过时版本。Praefect 提供自动对账工具。这些工具对账过时的仓库，使它们再次完全更新。

Praefect 会自动对账未更新的仓库。默认情况下，这每五分钟进行一次。对于健康的 Gitaly 节点上的每个过时仓库，Praefect 会选择一个在另一个健康 Gitaly 节点上随机、完全更新的仓库副本进行复制。仅当目标仓库没有其他复制作业待处理时，才会安排复制作业。

可以通过配置更改对账频率。该值可以是任何有效的[Go 持续时间值](https://pkg.go.dev/time#ParseDuration)。值低于 0 禁用此功能。

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
      scheduling_interval: '30s', # 每 30 秒对账一次
   },
}
```

```ruby
praefect['configuration'] = {
   # ...
   reconciliation: {
      # ...
      scheduling_interval: '0', # 禁用此功能
   },
}
```

<a id="manually-remove-repositories"></a>

### 手动删除仓库

{{< history >}}

- 在极狐GitLab 15.3 中[引入](https://gitlab.com/gitlab-org/gitaly/-/merge_requests/4715)，支持从 Praefect 跟踪数据库中删除仓库。

{{< /history >}}

`remove-repository` Praefect 子命令从极狐GitLab 集群中删除仓库，以及与给定仓库相关的所有状态，包括：

- 在所有相关 Gitaly 节点上的磁盘仓库。
- 由 Praefect 跟踪的任何数据库状态。

默认情况下，命令在 dry-run 模式下运行。例如：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage <virtual-storage> -relative-path <repository>
```

- 将 `<virtual-storage>` 替换为包含仓库的虚拟存储的名称。
- 将 `<repository>` 替换为要删除的仓库的相对路径。
- 在极狐GitLab 15.3 及更高版本中，添加 `-db-only` 以删除 Praefect 跟踪数据库条目而不删除磁盘上的仓库。使用此选项删除孤立的数据库条目，并保护磁盘上的仓库数据免于删除当有效仓库被意外指定时。如果数据库条目被意外删除，请使用[`track-repository` 命令](#manually-add-a-single-repository-to-the-tracking-database)重新跟踪仓库。
- 添加 `-apply` 以在 dry-run 模式之外运行命令并删除仓库。例如：

  ```shell
  sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml remove-repository -virtual-storage <virtual-storage> -relative-path <repository> -apply
  ```

- `-virtual-storage` 是仓库所在的虚拟存储。虚拟存储在 `/etc/gitlab/gitlab.rb` 中配置在 `praefect['configuration']['virtual_storage]` 下，如下所示：

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

  在此示例中，指定的虚拟存储是 `default` 或 `storage-1`。

- `-repository` 是存储中的仓库相对路径[以 `@hashed` 开头](../repository_storage_paths.md#hashed-storage)。例如：

  ```plaintext
  @hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git
  ```

在运行 `remove-repository` 之后，仓库的某些部分可能会继续存在。这可能是因为：

- 删除错误。
- 目标仓库的飞行中的 RPC 调用。

如果发生这种情况，请再次运行 `remove-repository`。

<a id="praefect-tracking-database-maintenance"></a>

## Praefect 跟踪数据库维护

本节记录了 Praefect 跟踪数据库的常见维护任务。

<a id="list-untracked-repositories"></a>

### 列出未跟踪的仓库

{{< history >}}

- 在极狐GitLab 15.0 中添加了 `older-than` 选项。

{{< /history >}}

`list-untracked-repositories` Praefect 子命令列出极狐GitLab 集群的仓库，这些仓库同时：

- 至少在一个 Gitaly 存储中存在。
- 未在 Praefect 跟踪数据库中跟踪。

添加 `-older-than` 选项以避免显示以下仓库：

- 正在创建过程中。
- Praefect 跟踪数据库中尚无记录。

将 `<duration>` 替换为时间持续时间（例如，`5s`、`10m` 或 `1h`）。默认值为 `6h`。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-untracked-repositories -older-than <duration>
```

仅考虑创建时间在指定持续时间之前的仓库。

命令输出：

- 结果到 `STDOUT` 和命令的日志。
- 错误到 `STDERR`。

每个条目都是一个完整的 JSON 字符串，以换行符结尾（可通过 `-delimiter` 标志配置）。例如：

```plaintext
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-untracked-repositories
{"virtual_storage":"default","storage":"gitaly-1","relative_path":"@hashed/ab/cd/abcd123456789012345678901234567890123456789012345678901234567890.git"}
{"virtual_storage":"default","storage":"gitaly-1","relative_path":"@hashed/ab/cd/abcd123456789012345678901234567890123456789012345678901234567891.git"}
```

<a id="manually-add-a-single-repository-to-the-tracking-database"></a>

### 手动将单个仓库添加到跟踪数据库

{{< alert type="warning" >}}

由于已知问题，无法使用 Praefect 生成的副本路径（`@cluster`）将仓库添加到 Praefect 跟踪数据库。这些仓库不与极狐GitLab 使用的仓库路径关联，并且不可访问。

{{< /alert >}}

`track-repository` Praefect 子命令将磁盘上的仓库添加到 Praefect 跟踪数据库以进行跟踪。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repository -virtual-storage <virtual-storage> -authoritative-storage <storage-name> -relative-path <repository> -replica-path <disk_path> -replicate-immediately
```

- `-virtual-storage` 是仓库所在的虚拟存储。虚拟存储在 `/etc/gitlab/gitlab.rb` 中配置在 `praefect['configuration'][:virtual_storage]` 下，如下所示：

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

  在此示例中，指定的虚拟存储是 `default` 或 `storage-1`。

- `-relative-path` 是虚拟存储中的相对路径。通常[以 `@hashed` 开头](../repository_storage_paths.md#hashed-storage)。例如：

  ```plaintext
  @hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git
  ```

- `-replica-path` 是物理存储上的相对路径。可以以[`@cluster` 开头或匹配 `relative_path`](../repository_storage_paths.md#gitaly-cluster-storage)。
- `-authoritative-storage` 是我们希望 Praefect 视为主要存储的存储。如果设置了[每仓库复制](praefect.md#configure-replication-factor)作为复制策略，则必填。
- `-replicate-immediately` 使命令立即将仓库复制到其次要存储。否则，复制作业会在数据库中安排执行，并由 Praefect 后台进程处理。

命令输出：

- 结果到 `STDOUT` 和命令的日志。
- 错误到 `STDERR`。

如果出现以下情况，此命令失败：

- 仓库已经在 Praefect 跟踪数据库中被跟踪。
- 仓库不存在于磁盘上。

<a id="manually-add-many-repositories-to-the-tracking-database"></a>

### 手动将多个仓库添加到跟踪数据库

{{< history >}}

- 在极狐GitLab 15.4 中引入。

{{< /history >}}

{{< alert type="warning" >}}

由于已知问题，无法使用 Praefect 生成的副本路径（`@cluster`）将仓库添加到 Praefect 跟踪数据库。这些仓库不与极狐GitLab 使用的仓库路径关联，并且不可访问。

{{< /alert >}}

通过 API 进行的迁移会自动将仓库添加到 Praefect 跟踪数据库。

如果您手动从现有基础设施复制仓库，则可以使用 `track-repositories` Praefect 子命令。此子命令批量添加磁盘上的仓库到 Praefect 跟踪数据库。

```shell
# Omnibus 极狐GitLab 安装
sudo gitlab-ctl praefect track-repositories --input-path /path/to/input.json

# 源安装
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml track-repositories -input-path /path/to/input.json
```

命令验证所有条目：

- 格式正确并包含必填字段。
- 对应磁盘上的有效 Git 仓库。
- 未在 Praefect 跟踪数据库中跟踪。

如果任何条目未通过这些检查，命令在尝试跟踪仓库之前中止。

- `input-path` 是包含格式为换行符分隔的 JSON 对象的仓库列表的文件路径。对象必须包含以下键：
  - `relative_path`：对应于[`track-repository`](#manually-add-a-single-repository-to-the-tracking-database)中的 `repository`。
  - `authoritative-storage`：Praefect 视为主要存储的存储。
  - `virtual-storage`：仓库所在的虚拟存储。

    例如：

    ```json
    {"relative_path":"@hashed/f5/ca/f5ca38f748a1d6eaf726b8a42fb575c3c71f1864a8143301782de13da2d9202b.git","replica_path":"@cluster/fe/d3/1","authoritative_storage":"gitaly-1","virtual_storage":"default"}
    {"relative_path":"@hashed/f8/9f/f89f8d0e735a91c5269ab08d72fa27670d000e7561698d6e664e7b603f5c4e40.git","replica_path":"@cluster/7b/28/2","authoritative_storage":"gitaly-2","virtual_storage":"default"}
    ```

- `-replicate-immediately`，使命令立即将仓库复制到其次要存储。否则，复制作业会在数据库中安排执行，并由 Praefect 后台进程处理。

<a id="list-virtual-storage-details"></a>

### 列出虚拟存储详细信息

{{< history >}}

- 在极狐GitLab 15.1 中引入。

{{< /history >}}

`list-storages` Praefect 子命令列出虚拟存储及其关联的存储节点。如果虚拟存储：

- 使用 `-virtual-storage` 指定，则仅列出指定虚拟存储的存储节点。
- 未指定，则列出所有虚拟存储及其关联的存储节点，以表格式显示。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml list-storages -virtual-storage <virtual_storage_name>
```

命令输出：

- 结果到 `STDOUT` 和命令的日志。
- 错误到 `STDERR`。
