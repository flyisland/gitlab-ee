---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 恢复极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 恢复操作可从备份中恢复数据，以维持系统连续性并从数据丢失中恢复。恢复操作：

- 恢复数据库记录和配置
- 恢复 Git 代码仓库、容器镜像仓库镜像和上传的内容
- 恢复软件包仓库数据和 CI/CD 产物
- 恢复账号和群组设置
- 恢复项目和群组 Wiki
- 恢复项目级安全文件
- 恢复外部合并请求差异

恢复过程要求现有的极狐GitLab 安装与备份版本相同。请遵循[先决条件](#restore-prerequisites)，并在生产环境中使用前测试完整的恢复过程。

<a id="restore-prerequisites"></a>

## 恢复先决条件

<a id="the-destination-gitlab-instance-must-already-be-working"></a>

### 目标极狐GitLab 实例必须已经正常工作

您需要有一个正常工作的极狐GitLab 安装才能执行恢复。这是因为执行恢复操作的系统用户（`git`）通常不允许创建或删除导入数据所需的 SQL 数据库（`gitlabhq_production`）。

<a id="the-destination-gitlab-instance-must-not-have-existing-data"></a>

### 目标极狐GitLab 实例不得有现有数据

恢复过程根据数据类型以不同方式处理现有数据：

- PostgreSQL 数据在恢复过程中会自动清除。
- Git 代码仓库：如果已存在同名代码仓库，恢复将失败并显示“代码仓库已存在”错误。有关更多信息，请参阅[议题 118459](https://gitlab.com/gitlab-org/gitlab/-/issues/118459)。
- 文件系统数据在恢复前会尽可能移动到单独的目录。
- 对象存储数据不会自动清除。您必须在恢复前手动清除对象存储桶，以避免保留孤立数据。

为获得可靠的恢复过程，例如在自动化生产环境到预发布环境的恢复时，请使用与备份相同版本的全新极狐GitLab 安装。

恢复 SQL 数据会跳过由 PostgreSQL 扩展拥有的视图。

<a id="the-destination-gitlab-instance-must-have-the-exact-same-version"></a>

### 目标极狐GitLab 实例必须具有完全相同的版本

您只能将备份恢复到创建备份时完全相同的极狐GitLab 版本和类型（基础版或企业版）。例如，基础版 15.1.4。

如果您的备份与当前安装的版本不同，则必须在恢复备份前[降级](../../update/package/downgrade.md)或[升级](../../update/package/_index.md)您的极狐GitLab 安装。

<a id="gitlab-secrets-must-be-restored"></a>

### 必须恢复极狐GitLab 密钥

要恢复备份，您还必须恢复极狐GitLab 密钥。如果您要迁移到新的极狐GitLab 实例，则必须从旧服务器复制极狐GitLab 密钥文件。这些密钥包括数据库加密密钥、CI/CD 变量以及用于双因素认证的变量。缺少这些密钥会导致多种问题，包括启用了双因素认证的用户无法访问，以及极狐GitLab Runner 无法登录。

> [!warning]
> **恢复到不同的 FQDN 时，WebAuthn 设备将被禁用：**
> WebAuthn 注册（例如 YubiKey）在密码学上绑定到其创建时的源（域/主机名）。如果您将备份恢复到 FQDN 与原始实例不同的极狐GitLab 实例，则所有 WebAuthn 设备都将被禁用。恢复完成后，用户需要重新注册其 WebAuthn 设备。
>
> 有关 WebAuthn 和主机名要求的更多信息，请参阅[双因素认证](../../user/profile/account/two_factor_authentication.md#information-for-gitlab-administrators)。

根据您的安装方法，恢复以下内容：

{{< tabs >}}

{{< tab title="Linux package" >}}

```plaintext
/etc/gitlab/gitlab-secrets.json
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

[恢复密钥](https://gitlab.cn/docs/charts/backup-restore/restore/#restoring-the-secrets)。

如有必要，[GitLab Helm chart 密钥可以转换为 Linux 软件包格式](https://gitlab.cn/docs/charts/installation/migration/helm_to_package/)。

{{< /tab >}}

{{< tab title="Docker" >}}

如果您已将 `/etc/gitlab` 挂载到 `/srv/gitlab/config` 下：

```plaintext
/srv/gitlab/config/gitlab-secrets.json
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```plaintext
/home/git/gitlab/.secret
```

{{< /tab >}}

{{< /tabs >}}

另请参阅：

- [CI/CD 变量](../../ci/variables/_index.md)
- [双因素认证](../../user/profile/account/two_factor_authentication.md)
- [密钥问题排查](troubleshooting_backup_gitlab.md#when-the-secrets-file-is-lost)

<a id="certain-gitlab-configuration-must-match-the-original-backed-up-environment"></a>

### 某些极狐GitLab 配置必须与原始备份环境匹配

您可能希望单独恢复之前的 `/etc/gitlab/gitlab.rb`（适用于 Linux 软件包安装）或 `/home/git/gitlab/config/gitlab.yml`（适用于自编译安装）以及任何 TLS 或 SSH 密钥和证书。

某些配置与 PostgreSQL 中的数据相关联。例如：

- 如果原始环境有三个代码仓库存储（例如，`default`、`my-storage-1` 和 `my-storage-2`），则目标环境也必须在配置中至少定义这些存储名称。
- 从使用本地存储的环境恢复备份时，即使目标环境使用对象存储，也会恢复到本地存储。对象存储的迁移必须在恢复之前或之后完成。

有关更多信息，请参阅[备份中不包含的数据](backup_gitlab.md#data-not-included-in-a-backup)。

<a id="restoring-directories-that-are-mount-points"></a>

### 恢复作为挂载点的目录

如果您要恢复到作为挂载点的目录，则必须确保这些目录在尝试恢复之前为空。否则，极狐GitLab 会尝试在恢复新数据之前移动这些目录，从而导致错误。

详细了解[配置 NFS 挂载](../nfs.md)。

<a id="restore-for-linux-package-installations"></a>

## 恢复 Linux 软件包安装

此过程假定：

- 您已安装了与创建备份时完全相同的极狐GitLab 版本和类型（基础版/企业版）。
- 您已至少运行过一次 `sudo gitlab-ctl reconfigure`。
- 极狐GitLab 正在运行。如果没有，请使用 `sudo gitlab-ctl start` 启动它。

首先确保您的备份 tar 文件位于 `gitlab.rb` 配置中 `gitlab_rails['backup_path']` 描述的备份目录中。默认目录是 `/var/opt/gitlab/backups`。备份文件需要由 `git` 用户拥有。

```shell
sudo cp 11493107454_2018_04_25_10.6.4-ce_gitlab_backup.tar /var/opt/gitlab/backups/
sudo chown git:git /var/opt/gitlab/backups/11493107454_2018_04_25_10.6.4-ce_gitlab_backup.tar
```

停止连接到数据库的进程。让极狐GitLab 的其余部分继续运行：

```shell
sudo gitlab-ctl stop puma
sudo gitlab-ctl stop sidekiq
# Verify
sudo gitlab-ctl status
```

接下来，确保您已完成[恢复先决条件](#restore-prerequisites)步骤，并在从原始安装复制极狐GitLab 密钥文件后运行了 `gitlab-ctl reconfigure`。

接下来，恢复备份，指定您要恢复的备份 ID：

> [!warning]
> 以下命令会覆盖您的极狐GitLab 数据库内容！

```shell
# NOTE: "_gitlab_backup.tar" is omitted from the name
sudo gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce
```

如果您的备份 tar 文件与已安装的极狐GitLab 版本之间存在版本不匹配，恢复命令将中止并显示错误消息：

```plaintext
GitLab version mismatch:
  Your current GitLab version (16.5.0-ee) differs from the GitLab version in the backup!
  Please switch to the following version and try again:
  version: 16.4.3-ee
```

安装正确的极狐GitLab 版本，然后重试。

> [!warning]
> 当您的安装使用 PgBouncer（出于性能原因或与 Patroni 集群一起使用）时，恢复命令需要[附加参数](backup_gitlab.md#back-up-and-restore-for-installations-using-pgbouncer)。

在 PostgreSQL 节点上运行 reconfigure：

```shell
sudo gitlab-ctl reconfigure
```

接下来，启动并检查极狐GitLab：

```shell
sudo gitlab-ctl start
sudo gitlab-rake gitlab:check SANITIZE=true
```

验证数据库值是否可以解密，尤其是在恢复了 `/etc/gitlab/gitlab-secrets.json` 或恢复目标是不同服务器的情况下。

```shell
sudo gitlab-rake gitlab:doctor:secrets
```

为了更加放心，您可以对上传的文件执行完整性检查：

```shell
sudo gitlab-rake gitlab:artifacts:check
sudo gitlab-rake gitlab:lfs:check
sudo gitlab-rake gitlab:uploads:check
```

恢复完成后，建议生成数据库统计信息以改善数据库性能并避免 UI 中的不一致：

1. 进入[数据库控制台](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database)。
1. 运行以下命令：

   ```sql
   SET STATEMENT_TIMEOUT=0 ; ANALYZE VERBOSE;
   ```

关于将该命令集成到恢复命令中的讨论正在进行中，有关更多详细信息，请参阅[议题 276184](https://gitlab.com/gitlab-org/gitlab/-/issues/276184)。

恢复后验证指南：

- [检查极狐GitLab 配置](../raketasks/maintenance.md#check-gitlab-configuration)
- [验证数据库值可以使用当前密钥解密](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)
- [上传文件完整性检查](../raketasks/check.md#uploaded-files-integrity)：

<a id="restore-for-docker-image-and-gitlab-helm-chart-installations"></a>

## 恢复 Docker 镜像和 GitLab Helm chart 安装

对于在 Kubernetes 集群上使用 Docker 镜像或 GitLab Helm chart 的极狐GitLab 安装，恢复任务期望恢复目录为空。但是，使用 Docker 和 Kubernetes 卷挂载时，可能会在卷根目录创建一些系统级目录，例如 Linux 操作系统中常见的 `lost+found` 目录。这些目录通常由 `root` 拥有，这可能会导致访问权限错误，因为恢复 Rake 任务以 `git` 用户身份运行。要恢复极狐GitLab 安装，用户必须确认恢复目标目录为空。

对于这两种安装类型，备份 tarball 必须位于备份位置（默认位置是 `/var/opt/gitlab/backups`）。

<a id="restore-for-helm-chart-installations"></a>

### 恢复 Helm chart 安装

GitLab Helm chart 使用[恢复 GitLab Helm chart 安装](https://gitlab.cn/docs/charts/backup-restore/restore/#restoring-a-gitlab-installation)中记录的过程。

<a id="restore-for-docker-image-installations"></a>

### 恢复 Docker 镜像安装

如果您使用 [Docker Swarm](../../install/docker/installation.md#install-gitlab-by-using-docker-swarm-mode)，则容器可能会在恢复过程中重启，因为 Puma 会关闭，因此容器健康检查会失败。要解决此问题，请临时禁用健康检查机制。

1. 编辑 `docker-compose.yml`：

   ```yaml
   healthcheck:
     disable: true
   ```

1. 部署堆栈：

   ```shell
   docker stack deploy --compose-file docker-compose.yml mystack
   ```

有关更多信息，请参阅[议题 6846](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6846 "GitLab restore can fail owing to `gitlab-healthcheck`")。

可以从主机运行恢复任务：

```shell
# Stop the processes that are connected to the database
docker exec -it <name of container> gitlab-ctl stop puma
docker exec -it <name of container> gitlab-ctl stop sidekiq

# Verify that the processes are all down before continuing
docker exec -it <name of container> gitlab-ctl status

# Run the restore. NOTE: "_gitlab_backup.tar" is omitted from the name
docker exec -it <name of container> gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce

# Restart the GitLab container
docker restart <name of container>

# Check GitLab
docker exec -it <name of container> gitlab-rake gitlab:check SANITIZE=true
```

<a id="restore-for-self-compiled-installations"></a>

## 恢复自编译安装

1. 首先，确保您的备份 tar 文件位于 `gitlab.yml` 配置中描述的备份目录中：

   ```yaml
   ## Backup settings
   backup:
     path: "tmp/backups"   # Relative paths are relative to Rails.root (default: tmp/backups/)
   ```

   默认目录是 `/home/git/gitlab/tmp/backups`，并且需要由 `git` 用户拥有。

1. 开始备份过程：

   ```shell
   # Stop processes that are connected to the database
   sudo service gitlab stop

   sudo -u git -H bundle exec rake gitlab:backup:restore RAILS_ENV=production
   ```

   示例输出：

   ```plaintext
   Unpacking backup... [DONE]
   Restoring database tables:
   -- create_table("events", {:force=>true})
     -> 0.2231s
   [...]
   - Loading fixture events...[DONE]
   - Loading fixture issues...[DONE]
   - Loading fixture keys...[SKIPPING]
   - Loading fixture merge_requests...[DONE]
   - Loading fixture milestones...[DONE]
   - Loading fixture namespaces...[DONE]
   - Loading fixture notes...[DONE]
   - Loading fixture projects...[DONE]
   - Loading fixture protected_branches...[SKIPPING]
   - Loading fixture schema_migrations...[DONE]
   - Loading fixture services...[SKIPPING]
   - Loading fixture snippets...[SKIPPING]
   - Loading fixture taggings...[SKIPPING]
   - Loading fixture tags...[SKIPPING]
   - Loading fixture users...[DONE]
   - Loading fixture users_projects...[DONE]
   - Loading fixture web_hooks...[SKIPPING]
   - Loading fixture wikis...[SKIPPING]
   Restoring repositories:
   - Restoring repository abcd... [DONE]
   - Object pool 1 ...
   Deleting tmp directories...[DONE]
   ```

1. 如有必要，恢复 `/home/git/gitlab/.secret`。
1. 重启极狐GitLab：

   ```shell
   sudo service gitlab restart
   ```

<a id="restoring-only-one-or-a-few-projects-or-groups-from-a-backup"></a>

## 从备份中仅恢复一个或几个项目或群组

虽然用于恢复极狐GitLab 实例的 Rake 任务不支持恢复单个项目或群组，但您可以通过将备份恢复到单独的临时极狐GitLab 实例，然后从那里导出您的项目或群组来使用变通方法：

1. [安装一个新的极狐GitLab](../../install/_index.md) 实例，其版本与您要恢复的备份实例相同。
1. 将备份恢复到该新实例，然后导出您的[项目](../../user/project/settings/import_export.md)或[群组](../../user/project/settings/import_export.md#migrate-groups-by-uploading-an-export-file-deprecated)。有关导出内容和不导出内容的更多信息，请参阅导出功能的文档。
1. 导出完成后，转到旧实例并导入它。
1. 导入完您想要的项目或群组后，您可以删除新的临时极狐GitLab 实例。

关于提供直接恢复单个项目或群组的功能请求正在[议题 #17517](https://gitlab.com/gitlab-org/gitlab/-/issues/17517) 中讨论。

<a id="restoring-an-incremental-repository-backup"></a>

## 恢复增量代码仓库备份

当您使用 `gitlab-backup` 创建[增量代码仓库备份](backup_gitlab.md#incremental-repository-backups)时，生成的备份归档包含完整恢复所需的所有代码仓库数据。要恢复，请使用与[恢复任何其他常规备份归档](#restore-for-linux-package-installations)相同的说明。

在内部，增量代码仓库备份仅存储上次备份之后所做的更改。当您创建增量备份时，`gitlab-backup` 会将从原始完整备份开始的每个步骤捆绑到备份归档中。这意味着归档是自包含的，即使各个代码仓库备份捆绑包相互依赖。

使用[服务端代码仓库备份](backup_gitlab.md#create-server-side-repository-backups)时，备份归档不包含代码仓库数据。相反，代码仓库数据由每个 Gitaly 节点存储在对象存储中，每个增量存储为单独的对象。在服务端恢复中，Gitaly 读取备份清单并按顺序应用每个增量。

> [!warning]
> 不要从对象存储中删除增量备份文件。如果中间文件被删除（例如，通过对象存储生命周期策略），备份链将中断，备份将无法恢复。

<a id="restore-options"></a>

## 恢复选项

极狐GitLab 提供的用于从备份恢复的命令行工具可以接受更多选项。

<a id="specify-backup-to-restore-when-there-are-more-than-one"></a>

### 存在多个备份时指定要恢复的备份

备份文件使用[以备份 ID 开头的命名方案](backup_archive_process.md#backup-id)。当存在多个备份时，您必须通过设置环境变量 `BACKUP=<backup-id>` 来指定要恢复哪个 `<backup-id>_gitlab_backup.tar` 文件。

<a id="disable-prompts-during-restore"></a>

### 在恢复期间禁用提示

从备份恢复期间，恢复脚本会提示确认：

<!-- vale gitlab_base.Spelling = NO -->
- 如果启用了**写入 authorized_keys** 设置，则在恢复脚本删除并重建 `authorized_keys` 文件之前。
<!-- vale gitlab_base.Spelling = YES -->
- 恢复数据库时，在恢复脚本删除所有现有表之前。
- 恢复数据库后，如果恢复架构时出现错误，则在继续之前，因为可能会出现进一步的问题。

要禁用这些提示，请将 `GITLAB_ASSUME_YES` 环境变量设置为 `1`。

- Linux 软件包安装：

  ```shell
  sudo GITLAB_ASSUME_YES=1 gitlab-backup restore
  ```

- 自编译安装：

  ```shell
  sudo -u git -H GITLAB_ASSUME_YES=1 bundle exec rake gitlab:backup:restore RAILS_ENV=production
  ```

`force=yes` 环境变量也会禁用这些提示。

<a id="excluding-tasks-on-restore"></a>

### 在恢复时排除任务

您可以通过添加环境变量 `SKIP` 来排除恢复时的特定任务，其值是以逗号分隔的以下选项列表：

- `db`（数据库）
- `uploads`（附件）
- `builds`（CI 作业输出日志）
- `artifacts`（CI 作业产物）
- `lfs`（LFS 对象）
- `terraform_state`（Terraform 状态）
- `registry`（容器镜像仓库镜像）
- `pages`（Pages 内容）
- `repositories`（Git 代码仓库数据）
- `packages`（软件包）

要排除特定任务：

- Linux 软件包安装：

  ```shell
  sudo gitlab-backup restore BACKUP=<backup-id> SKIP=db,uploads
  ```

- 自编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:backup:restore BACKUP=<backup-id> SKIP=db,uploads RAILS_ENV=production
  ```

<a id="restore-specific-repository-storages"></a>

### 恢复特定的代码仓库存储

> [!warning]
> 极狐GitLab 17.1 及更早版本[受竞态条件影响](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/158412)，可能导致数据丢失。该问题影响已 fork 并使用极狐GitLab [对象池](../repository_storage_paths.md#hashed-object-pools)的代码仓库。为避免数据丢失，请仅使用极狐GitLab 17.2 或更高版本恢复备份。

使用[多个代码仓库存储](../repository_storage_paths.md)时，可以使用 `REPOSITORIES_STORAGES` 选项单独恢复特定代码仓库存储中的代码仓库。该选项接受以逗号分隔的存储名称列表。

例如：

- Linux 软件包安装：

  ```shell
  sudo gitlab-backup restore BACKUP=<backup-id> REPOSITORIES_STORAGES=storage1,storage2
  ```

- 自编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:backup:restore BACKUP=<backup-id> REPOSITORIES_STORAGES=storage1,storage2
  ```

<a id="restore-specific-repositories"></a>

### 恢复特定的代码仓库

> [!warning]
> 极狐GitLab 17.1 及更早版本[受竞态条件影响](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/158412)，可能导致数据丢失。该问题影响已 fork 并使用极狐GitLab [对象池](../repository_storage_paths.md#hashed-object-pools)的代码仓库。为避免数据丢失，请仅使用极狐GitLab 17.2 或更高版本恢复备份。

您可以使用 `REPOSITORIES_PATHS` 和 `SKIP_REPOSITORIES_PATHS` 选项恢复特定的代码仓库。这两个选项都接受以逗号分隔的项目和群组路径列表。如果您指定群组路径，则该群组及其后代群组中所有项目的所有代码仓库都将被包含或跳过，具体取决于您使用的选项。群组和项目都必须存在于指定的备份或目标实例中。

> [!note]
> `REPOSITORIES_PATHS` 和 `SKIP_REPOSITORIES_PATHS` 选项仅适用于 Git 代码仓库。它们不适用于项目或群组数据库条目。如果您使用 `SKIP=db` 创建了代码仓库备份，则它本身不能用于将特定代码仓库恢复到新实例。

设置 `REPOSITORIES_PATHS` 或 `SKIP_REPOSITORIES_PATHS` 只会恢复特定的代码仓库。在这种恢复期间，实例上已存在的代码仓库不会被移除。因此，您可以连续运行多次此类恢复，而不会因后续恢复而移除先前恢复的代码仓库。

完整恢复（未指定任一选项）会移除不属于所恢复备份的任何代码仓库。这会清除过时的代码仓库，例如属于备份创建后创建的项目的代码仓库。

例如，要恢复 A 群组（`group-a`）中所有项目的所有代码仓库、B 群组中 C 项目（`group-b/project-c`）的代码仓库，并跳过 A 群组中的 D 项目（`group-a/project-d`）：

- Linux 软件包安装：

  ```shell
  sudo gitlab-backup restore BACKUP=<backup-id> REPOSITORIES_PATHS=group-a,group-b/project-c SKIP_REPOSITORIES_PATHS=group-a/project-d
  ```

- 自编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:backup:restore BACKUP=<backup-id> REPOSITORIES_PATHS=group-a,group-b/project-c SKIP_REPOSITORIES_PATHS=group-a/project-d
  ```

要恢复备份中的所有内容，但 A 群组中 D 项目（`group-a/project-d`）的代码仓库除外：

- Linux 软件包安装：

  ```shell
  sudo gitlab-backup restore BACKUP=<backup-id> SKIP_REPOSITORIES_PATHS=group-a/project-d
  ```

- 自编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:backup:restore BACKUP=<backup-id> SKIP_REPOSITORIES_PATHS=group-a/project-d
  ```

<a id="restore-untarred-backups"></a>

### 恢复未打包的备份

如果找到[未打包的备份](backup_gitlab.md#skipping-tar-creation)（使用 `SKIP=tar` 创建），并且没有使用 `BACKUP=<backup-id>` 选择备份，则使用未打包的备份。

例如：

- Linux 软件包安装：

  ```shell
  sudo gitlab-backup restore
  ```

- 自编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:backup:restore
  ```

<a id="restoring-using-server-side-repository-backups"></a>

### 使用服务端代码仓库备份进行恢复

收集服务端备份时，恢复过程默认使用[创建服务端代码仓库备份](backup_gitlab.md#create-server-side-repository-backups)中显示的服务端恢复机制。您可以配置备份恢复，使托管每个代码仓库的 Gitaly 节点负责直接从对象存储拉取必要的备份数据。

1. [在 Gitaly 中配置服务端备份目标](../gitaly/configure_gitaly.md#configure-server-side-backups)。
1. 启动服务端备份恢复过程，指定您要恢复的备份的 [ID](backup_archive_process.md#backup-id)：

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
sudo gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce
```

{{< /tab >}}

{{< tab title="Self-compiled" >}}

```shell
sudo -u git -H bundle exec rake gitlab:backup:restore BACKUP=11493107454_2018_04_25_10.6.4-ce
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

```shell
kubectl exec <Toolbox pod name> -it -- backup-utility --restore -t <backup_ID> --repositories-server-side
```

使用[基于 cron 的备份](https://gitlab.cn/docs/charts/backup-restore/backup/#cron-based-backup)时，请将 `--repositories-server-side` 标志添加到附加参数中。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排查

以下是您可能遇到的潜在问题及相应的解决方案。

<a id="restoring-database-backup-using-output-warnings-from-a-linux-package-installation"></a>

### 从 Linux 软件包安装恢复数据库备份时出现输出警告

如果您使用备份恢复过程，可能会遇到以下警告消息：

```plaintext
ERROR: must be owner of extension pg_trgm
ERROR: must be owner of extension btree_gist
ERROR: must be owner of extension plpgsql
WARNING:  no privileges could be revoked for "public" (two occurrences)
WARNING:  no privileges were granted for "public" (two occurrences)
```

请注意，尽管有这些警告消息，备份仍会成功恢复。

Rake 任务以 `gitlab` 用户身份运行，该用户对数据库没有超级用户访问权限。当恢复启动时，它也以 `gitlab` 用户身份运行，但它也会尝试更改其无权访问的对象。这些对象对数据库备份或恢复没有影响，但会显示警告消息。

有关更多信息，请参阅：

- PostgreSQL 议题跟踪器：
  - [不是超级用户](https://www.postgresql.org/message-id/201110220712.30886.adrian.klaver@gmail.com)。
  - [具有不同的所有者](https://www.postgresql.org/message-id/2039.1177339749@sss.pgh.pa.us)。
- Stack Overflow：[产生的错误](https://stackoverflow.com/questions/4368789/error-must-be-owner-of-language-plpgsql)。

<a id="restoring-fails-due-to-git-server-hook"></a>

### 由于 Git 服务器钩子导致恢复失败

从备份恢复时，当以下情况成立时，您可能会遇到错误：

- 使用[极狐GitLab 15.10 及更早版本](../server_hooks.md)的方法配置了 Git 服务器钩子（`custom_hook`）
- 您的极狐GitLab 版本是 15.11 及更高版本
- 您创建了指向极狐GitLab 管理位置之外目录的符号链接

错误如下所示：

```plaintext
{"level":"fatal","msg":"restore: pipeline: 1 failures encountered:\n - @hashed/path/to/hashed_repository.git (path/to_project): manager: restore custom hooks, \"@hashed/path/to/hashed_repository/<BackupID>_<GitLabVersion>-ee/001.custom_hooks.tar\": rpc error: code = Internal desc = setting custom hooks: generating prepared vote: walking directory: copying file to hash: read /mnt/gitlab-app/git-data/repositories/+gitaly/tmp/default-repositories.old.<timestamp>.<temporaryfolder>/custom_hooks/compliance-triggers.d: is a directory\n","pid":3256017,"time":"2023-08-10T20:09:44.395Z"}
```

要解决此问题，您可以更新极狐GitLab 15.11 及更高版本的 Git [服务器钩子](../server_hooks.md)，并创建新的备份。

<a id="successful-restore-with-repositories-showing-as-empty-when-using-fapolicyd"></a>

### 使用 `fapolicyd` 时恢复成功但代码仓库显示为空

当使用 `fapolicyd` 增强安全性时，极狐GitLab 可能会报告恢复成功，但代码仓库显示为空。有关更多故障排查帮助，请参阅 [Gitaly 故障排查文档](../gitaly/troubleshooting.md#repositories-are-shown-as-empty-after-a-gitlab-restore)。
