---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 移动由极狐GitLab 管理的代码仓库
description: 在服务器和存储之间移动项目、代码片段和群组。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

将所有由极狐GitLab 管理的代码仓库移动到另一个文件系统或另一台服务器。

<a id="move-data-in-a-gitlab-instance"></a>

## 在极狐GitLab 实例中移动数据

使用极狐GitLab API 移动 Git 代码仓库：

- 在服务器之间。
- 在不同存储之间。
- 从单节点 Gitaly 到 Gitaly 集群（Praefect）。

极狐GitLab 代码仓库可以与项目、群组和代码片段关联。每种类型都有单独的 API 用于移动代码仓库。要移动极狐GitLab 实例上的所有代码仓库，必须为每个存储移动每种类型的代码仓库。

在移动期间，每个代码仓库都变为只读，直到移动完成前都不可写入。

要移动代码仓库：

1. 确保所有[本地和集群存储](../gitaly/configure_gitaly.md#mixed-configuration)均可被极狐GitLab 实例访问。在
   此示例中，这些存储是 `<original_storage_name>` 和 `<cluster_storage_name>`。
1. [配置代码仓库存储权重](../repository_storage_paths.md#configure-where-new-repositories-are-stored)，
   使新存储接收所有新项目。这样可在迁移进行期间阻止在现有存储上创建新项目。
1. 为项目、代码片段和群组安排代码仓库移动。
1. 如果您使用 [Geo](../geo/_index.md)，
   [重新同步所有代码仓库](../geo/replication/resync_reverify.md#resync-resources-for-the-selected-component)。
1. 在 Sidekiq pod 上使用水平 Pod 自动扩缩器时，[为 Sidekiq pod 禁用 HPA](https://gitlab.cn/docs/charts/gitlab/sidekiq/#disable-hpa-scaling)，以防止迁移期间进行扩缩。

<a id="move-projects"></a>

### 移动项目

您可以移动所有项目或单个项目。

要使用 API 移动所有项目：

1. 使用 API [为存储分片上的所有项目安排代码仓库存储移动](../../api/project_repository_storage_moves.md#create-repository-storage-moves-for-all-projects-on-a-storage-shard)。
   例如：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
        --header "Content-Type: application/json" \
        --data '{"source_storage_name":"<original_storage_name>","destination_storage_name":"<cluster_storage_name>"}' \
        "https://gitlab.example.com/api/v4/project_repository_storage_moves"
   ```

1. 使用 API [查询最近的代码仓库移动](../../api/project_repository_storage_moves.md#list-all-project-repository-storage-moves)。
   响应会表明以下情况之一：
   - 移动已成功完成。`state` 字段为 `finished`。
   - 移动正在进行中。请重新查询代码仓库移动，直到其成功完成。
   - 移动已失败。大多数失败是暂时性的，可通过重新安排移动来解决。

1. 移动完成后，使用 API [查询项目](../../api/projects.md#list-all-projects)并确认
   所有项目都已移动。不应有任何项目返回的 `repository_storage` 字段仍设置为
   旧存储。例如：

   ```shell
   curl --header "PRIVATE-TOKEN: <your_access_token>" --header "Content-Type: application/json" \
   "https://gitlab.example.com/api/v4/projects?repository_storage=<original_storage_name>"
   ```

   或者，使用 Rails 控制台确认所有项目都已移动：

   ```ruby
   ProjectRepository.for_repository_storage('<original_storage_name>')
   ```

1. 根据需要为每个存储重复此操作。

如果您不想移动所有项目，请按照[移动单个项目](../../api/project_repository_storage_moves.md#create-a-repository-storage-move-for-a-project)的说明操作。

<a id="move-snippets"></a>

### 移动代码片段

您可以移动所有代码片段或单个代码片段。

要使用 API 移动所有代码片段：

1. [为存储分片上的所有代码片段安排代码仓库存储移动](../../api/snippet_repository_storage_moves.md#schedule-repository-storage-moves-for-all-snippets-on-a-storage-shard)。例如：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
        --header "Content-Type: application/json" \
        --data '{"source_storage_name":"<original_storage_name>","destination_storage_name":"<cluster_storage_name>"}' \
        "https://gitlab.example.com/api/v4/snippet_repository_storage_moves"
   ```

1. [查询最近的代码仓库移动](../../api/snippet_repository_storage_moves.md#list-all-snippet-repository-storage-moves)。
   响应会表明以下情况之一：
   - 移动已成功完成。`state` 字段为 `finished`。
   - 移动正在进行中。请重新查询代码仓库移动，直到其成功完成。
   - 移动已失败。大多数失败是暂时性的，可通过重新安排移动来解决。

1. 移动完成后，使用 Rails 控制台确认所有代码片段都已移动：

   ```ruby
   SnippetRepository.for_repository_storage('<original_storage_name>')
   ```

   该命令不应返回原存储中的代码片段。

1. 根据需要为每个存储重复此操作。

如果您不想移动所有代码片段，请按照[单个代码片段](../../api/snippet_repository_storage_moves.md#schedule-a-repository-storage-move-for-a-snippet)的说明操作。

<a id="move-groups"></a>

### 移动群组

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以移动所有群组或单个群组。

要使用 API 移动所有群组：

1. [为存储分片上的所有群组安排代码仓库存储移动](../../api/group_repository_storage_moves.md#create-group-repository-storage-moves-for-a-storage-shard)。
   例如：

   ```shell
   curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
        --header "Content-Type: application/json" \
        --data '{"source_storage_name":"<original_storage_name>","destination_storage_name":"<cluster_storage_name>"}' \
        "https://gitlab.example.com/api/v4/group_repository_storage_moves"
   ```

1. [查询最近的代码仓库移动](../../api/group_repository_storage_moves.md#list-all-group-repository-storage-moves)。
   响应会表明以下情况之一：
   - 移动已成功完成。`state` 字段为 `finished`。
   - 移动正在进行中。请重新查询代码仓库移动，直到其成功完成。
   - 移动已失败。大多数失败是暂时性的，可通过重新安排移动来解决。

1. 移动完成后，使用 Rails 控制台确认所有群组都已移动：

   ```ruby
   GroupWikiRepository.for_repository_storage('<original_storage_name>')
   ```

   该命令不应返回原存储中的群组。

1. 根据需要为每个存储重复此操作。

如果您不想移动所有群组，请按照[单个群组](../../api/group_repository_storage_moves.md#create-a-group-repository-storage-move)的说明操作。

<a id="migrate-to-another-gitlab-instance"></a>

## 迁移到另一个极狐GitLab 实例

如果您要迁移到新的极狐GitLab 环境，则无法[使用 API 移动数据](#move-data-in-a-gitlab-instance)。例如：

- 从单节点极狐GitLab 迁移到横向扩展架构。
- 从私有数据中心中的极狐GitLab 实例迁移到云服务商。

在这种情况下，根据具体场景，您可以通过多种方式将所有代码仓库从 `/var/opt/gitlab/git-data/repositories` 复制到
`/mnt/gitlab/repositories`：

- 目标目录为空。
- 目标目录包含代码仓库的过时副本。
- 您有数千个代码仓库。

> [!warning]
> 每种方式都可能或确实会覆盖目标目录 `/mnt/gitlab/repositories` 中的数据。您必须正确
> 指定源和目标。

<a id="use-backup-and-restore-recommended"></a>

### 使用备份和恢复（推荐）

对于 Gitaly 或 Gitaly 集群（Praefect）目标，您应使用极狐GitLab
[备份和恢复功能](../backup_restore/_index.md)。Git 代码仓库由 Gitaly 作为数据库在极狐GitLab 服务器上访问、管理和存储。如果您使用 `rsync` 等工具直接访问和复制 Gitaly 文件，可能会遇到数据丢失。您可以：

- 通过[并发处理多个代码仓库](../backup_restore/backup_gitlab.md#back-up-git-repositories-concurrently)
  提高备份性能。
- 使用[跳过功能](../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)
  仅创建代码仓库的备份。

对于 Gitaly 集群（Praefect）目标，您必须使用备份和恢复方法。

<a id="use-tar"></a>

### 使用 `tar`

在以下情况下，您可以使用 `tar` 管道移动代码仓库：

- 您指定的是 Gitaly 目标，而不是 Gitaly 集群目标。
- 目标目录 `/mnt/gitlab/repositories` 为空。

此方法开销较低，而且 `tar` 通常已预装在您的系统中。但是，您无法恢复被中断的 `tar` 管道。如果 `tar` 被中断，您必须清空目标目录并重新复制所有数据。

要查看 `tar` 进程的进度，请将 `-xf` 替换为 `-xvf`。

```shell
sudo -u git sh -c 'tar -C /var/opt/gitlab/git-data/repositories -cf - -- . |\
  tar -C /mnt/gitlab/repositories -xf -'
```

<a id="use-a-tar-pipe-to-another-server"></a>

#### 使用 `tar` 管道传输到另一台服务器

对于 Gitaly 目标，您可以使用 `tar` 管道将数据复制到另一台服务器。如果您的 `git` 用户以 `git@<newserver>` 身份对新服务器具有 SSH 访问权限，您可以通过 SSH 传输数据。

如果您想在数据通过网络传输之前压缩数据（这会增加 CPU 使用率），可以将 `ssh` 替换为 `ssh -C`。

```shell
sudo -u git sh -c 'tar -C /var/opt/gitlab/git-data/repositories -cf - -- . |\
  ssh git@newserver tar -C /mnt/gitlab/repositories -xf -'
```

<a id="use-rsync"></a>

### 使用 `rsync`

在以下情况下，您可以使用 `rsync` 移动代码仓库：

- 您指定的是 Gitaly 目标，而不是 Gitaly 集群目标。
- 目标目录已包含代码仓库的部分或过时副本，这意味着使用 `tar` 再次复制所有数据
  效率低下。

> [!warning]
> 使用 `rsync` 时必须使用 `--delete` 选项。不带 `--delete` 使用 `rsync` 可能导致数据丢失和
> 代码仓库损坏。有关更多信息，请参见[议题 270422](https://gitlab.com/gitlab-org/gitlab/-/issues/270422)。

以下命令中的 `/.` 非常重要，否则目标目录中可能会出现错误的目录结构。如果您想查看进度，请将 `-a` 替换为 `-av`。

```shell
sudo -u git  sh -c 'rsync -a --delete /var/opt/gitlab/git-data/repositories/. \
  /mnt/gitlab/repositories'
```

<a id="use-rsync-to-another-server"></a>

#### 使用 `rsync` 传输到另一台服务器

对于 Gitaly 目标，如果源系统上的 `git` 用户对目标服务器具有 SSH 访问权限，您可以使用 `rsync` 通过网络发送代码仓库。

```shell
sudo -u git sh -c 'rsync -a --delete /var/opt/gitlab/git-data/repositories/. \
  git@newserver:/mnt/gitlab/repositories'
```
