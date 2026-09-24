---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 移动由极狐GitLab 管理的仓库
description: Move projects, snippets, and groups between servers and storages.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

将所有由极狐GitLab 管理的仓库移动到另一个文件系统或另一台服务器。

<a id="move-data-in-a-gitlab-instance"></a>

## 在极狐GitLab 实例中移动数据

使用极狐GitLab API 移动 Git 仓库：

- 在服务器之间移动。
- 在不同存储之间移动。
- 从单节点 Gitaly 移动到 Gitaly Cluster（Praefect）。

极狐GitLab 仓库可以与项目、群组和代码片段关联。每种类型都有单独的 API 用于移动仓库。要移动极狐GitLab 实例上的所有仓库，必须为每种存储移动每种类型的仓库。

在移动过程中，每个仓库都会被设为只读，直到移动完成才可写入。

要移动仓库：

1. 确保所有[本地和集群存储](../gitaly/configure_gitaly.md#mixed-configuration)都可以被极狐GitLab 实例访问。在此示例中，分别是 `<original_storage_name>` 和 `<cluster_storage_name>`。
1. [配置仓库存储权重](../repository_storage_paths.md#configure-where-new-repositories-are-stored)，使新存储接收所有新项目。这样可以防止在迁移过程中在现有存储上创建新项目。
1. 为项目、代码片段和群组安排仓库移动。
1. 如果你使用了 [Geo](../geo/_index.md)，请[重新同步所有仓库](../geo/replication/troubleshooting/synchronization_verification.md#resync-resources-for-the-selected-component)。
1. 如果在 Sidekiq Pod 上使用了水平 Pod 自动扩缩器（HPA），请在迁移期间[禁用 Sidekiq Pod 的 HPA](https://gitlab.cn/docs/charts/gitlab/sidekiq/#disable-hpa-scaling) 以防止扩缩。

<a id="move-projects"></a>

### 移动项目

你可以移动所有项目或单个项目。

要通过 API 移动所有项目：

1. 使用 API 为存储分片上的所有项目[安排仓库存储移动](../../api/project_repository_storage_moves.md#create-repository-storage-moves-for-all-projects-on-a-storage-shard)。例如：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
        --header "Content-Type: application/json" \
        --data '{"source_storage_name":"<original_storage_name>","destination_storage_name":"<cluster_storage_name>"}' \
        "https://gitlab.example.com/api/v4/project_repository_storage_moves"
   ```

1. 使用 API [查询最近的仓库移动](../../api/project_repository_storage_moves.md#list-all-project-repository-storage-moves)。响应会指示：
   - 移动已成功完成。`state` 字段为 `finished`。
   - 移动正在进行中。重新查询仓库移动，直到它成功完成。
   - 移动失败。大多数失败是暂时的，可以通过重新安排移动来解决。

1. 移动完成后，使用 API [查询项目](../../api/projects.md#list-all-projects) 并确认所有项目都已移动。不应有任何项目的 `repository_storage` 字段仍设置为旧存储。例如：

   ```shell
   curl --header "PRIVATE-TOKEN: <your_access_token>" --header "Content-Type: application/json" \
   "https://gitlab.example.com/api/v4/projects?repository_storage=<original_storage_name>"
   ```

   或者，使用 Rails 控制台确认所有项目都已移动：

   ```ruby
   ProjectRepository.for_repository_storage('<original_storage_name>')
   ```

1. 根据需要，对每个存储重复上述步骤。

如果你不想移动所有项目，请按照[移动单个项目](../../api/project_repository_storage_moves.md#create-a-repository-storage-move-for-a-project)的说明操作。

<a id="move-snippets"></a>

### 移动代码片段

你可以移动所有代码片段或单个代码片段。

要通过 API 移动所有代码片段：

1. [为存储分片上的所有代码片段安排仓库存储移动](../../api/snippet_repository_storage_moves.md#schedule-repository-storage-moves-for-all-snippets-on-a-storage-shard)。例如：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
        --header "Content-Type: application/json" \
        --data '{"source_storage_name":"<original_storage_name>","destination_storage_name":"<cluster_storage_name>"}' \
        "https://gitlab.example.com/api/v4/snippet_repository_storage_moves"
   ```

1. [查询最近的仓库移动](../../api/snippet_repository_storage_moves.md#list-all-snippet-repository-storage-moves)。响应会指示：
   - 移动已成功完成。`state` 字段为 `finished`。
   - 移动正在进行中。重新查询仓库移动，直到它成功完成。
   - 移动失败。大多数失败是暂时的，可以通过重新安排移动来解决。

1. 移动完成后，使用 Rails 控制台确认所有代码片段都已移动：

   ```ruby
   SnippetRepository.for_repository_storage('<original_storage_name>')
   ```

   该命令不应该返回位于原始存储的任何代码片段。

1. 根据需要，对每个存储重复上述步骤。

如果你不想移动所有代码片段，请按照[移动单个代码片段](../../api/snippet_repository_storage_moves.md#schedule-a-repository-storage-move-for-a-snippet)的说明操作。

<a id="move-groups"></a>

### 移动群组

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以移动所有群组或单个群组。

要通过 API 移动所有群组：

1. [为存储分片上的所有群组安排仓库存储移动](../../api/group_repository_storage_moves.md#create-group-repository-storage-moves-for-a-storage-shard)。例如：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
        --header "Content-Type: application/json" \
        --data '{"source_storage_name":"<original_storage_name>","destination_storage_name":"<cluster_storage_name>"}' \
        "https://gitlab.example.com/api/v4/group_repository_storage_moves"
   ```

1. [查询最近的仓库移动](../../api/group_repository_storage_moves.md#list-all-group-repository-storage-moves)。响应会指示：
   - 移动已成功完成。`state` 字段为 `finished`。
   - 移动正在进行中。重新查询仓库移动，直到它成功完成。
   - 移动失败。大多数失败是暂时的，可以通过重新安排移动来解决。

1. 移动完成后，使用 Rails 控制台确认所有群组都已移动：

   ```ruby
   GroupWikiRepository.for_repository_storage('<original_storage_name>')
   ```

   该命令不应该返回位于原始存储的任何群组。

1. 根据需要，对每个存储重复上述步骤。

如果你不想移动所有群组，请按照[移动单个群组](../../api/group_repository_storage_moves.md#create-a-group-repository-storage-move)的说明操作。

<a id="migrate-to-another-gitlab-instance"></a>

## 迁移到另一个极狐GitLab 实例

如果你要迁移到新的极狐GitLab 环境，则无法[使用 API 移动数据](#在极狐GitLab-实例中移动数据)。例如：

- 从单节点极狐GitLab 迁移到水平扩展架构。
- 从私有数据中心中的极狐GitLab 实例迁移到云提供商。

在这种情况下，根据具体情况，你可以通过多种方式将所有仓库从 `/var/opt/gitlab/git-data/repositories` 复制到 `/mnt/gitlab/repositories`：

- 目标目录为空。
- 目标目录包含一份过时的仓库副本。
- 当你有数千个仓库时。

> [!warning]
> 每种方法都可能或确实会覆盖目标目录 `/mnt/gitlab/repositories` 中的数据。你必须正确指定源和目标。

<a id="use-backup-and-restore-recommended"></a>

### 使用备份和恢复（推荐）

对于 Gitaly 或 Gitaly Cluster（Praefect）目标，你应该使用极狐GitLab 的[备份和恢复功能](../backup_restore/_index.md)。Git 仓库由 Gitaly 作为数据库在极狐GitLab 服务器上访问、管理和存储。如果使用 `rsync` 等工具直接访问和复制 Gitaly 文件，可能会导致数据丢失。你可以：

- 通过[并发处理多个仓库](../backup_restore/backup_gitlab.md#back-up-git-repositories-concurrently)来提高备份性能。
- 通过使用[跳过功能](../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)仅创建仓库的备份。

对于 Gitaly Cluster（Praefect）目标，你必须使用备份和恢复方法。

<a id="use-tar"></a>

### 使用 `tar`

在以下情况下，你可以使用 `tar` 管道移动仓库：

- 指定了 Gitaly 目标，而不是 Gitaly Cluster 目标。
- 目标目录 `/mnt/gitlab/repositories` 为空。

这种方法开销低，而且 `tar` 通常已预装在系统中。但是，你无法恢复中断的 `tar` 管道。如果 `tar` 被中断，你必须清空目标目录并重新复制所有数据。

要查看 `tar` 进程的进度，将 `-xf` 替换为 `-xvf`。

```shell
sudo -u git sh -c 'tar -C /var/opt/gitlab/git-data/repositories -cf - -- . |\
  tar -C /mnt/gitlab/repositories -xf -'
```

<a id="use-a-tar-pipe-to-another-server"></a>

#### 使用 `tar` 管道复制到另一台服务器

对于 Gitaly 目标，你可以使用 `tar` 管道将数据复制到另一台服务器。如果你的 `git` 用户可以通过 SSH 认证为 `git@<newserver>` 访问新服务器，你可以通过 SSH 管道传输数据。

如果你想在数据通过网络传输之前对其进行压缩（这会增加 CPU 使用率），可以将 `ssh` 替换为 `ssh -C`。

```shell
sudo -u git sh -c 'tar -C /var/opt/gitlab/git-data/repositories -cf - -- . |\
  ssh git@newserver tar -C /mnt/gitlab/repositories -xf -'
```

<a id="use-rsync"></a>

### 使用 `rsync`

在以下情况下，你可以使用 `rsync` 移动仓库：

- 指定了 Gitaly 目标，而不是 Gitaly Cluster 目标。
- 目标目录已包含部分或过时的仓库副本，这意味使用 `tar` 重新复制所有数据效率低下。

> [!warning]
> 使用 `rsync` 时必须使用 `--delete` 选项。不带 `--delete` 选项使用 `rsync` 可能会导致数据丢失和仓库损坏。

下面命令中的 `/.` 非常重要，否则你可能会在目标目录中得到错误的目录结构。如果你想查看进度，将 `-a` 替换为 `-av`。

```shell
sudo -u git  sh -c 'rsync -a --delete /var/opt/gitlab/git-data/repositories/. \
  /mnt/gitlab/repositories'
```

<a id="use-rsync-to-another-server"></a>

#### 使用 `rsync` 复制到另一台服务器

对于 Gitaly 目标，如果源系统上的 `git` 用户可以通过 SSH 访问目标服务器，你可以使用 `rsync` 通过网络发送仓库。

```shell
sudo -u git sh -c 'rsync -a --delete /var/opt/gitlab/git-data/repositories/. \
  git@newserver:/mnt/gitlab/repositories'
```

<a id="related-topics"></a>

## 相关主题

- [配置 Gitaly](../gitaly/configure_gitaly.md)
- [Gitaly Cluster（Praefect）](../gitaly/praefect/_index.md)
- [项目仓库存储移动 API](../../api/project_repository_storage_moves.md)
- [群组仓库存储移动 API](../../api/group_repository_storage_moves.md)
- [代码片段仓库存储移动 API](../../api/snippet_repository_storage_moves.md)