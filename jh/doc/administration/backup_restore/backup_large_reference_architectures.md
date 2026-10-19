---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 备份和恢复大型极狐GitLab 环境
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 备份可保持数据一致性，并为大型极狐GitLab 环境提供灾难恢复能力。此过程：

- 协调跨分布式存储组件的数据备份
- 保留大小可达数 TB 的 PostgreSQL 数据库
- 保护外部服务中的对象存储数据
- 为大型 Git 代码仓库集合维护备份完整性
- 创建配置文件和密钥文件的可恢复副本
- 以最短停机时间恢复系统数据

当因数据库或代码仓库规模导致标准备份过程不可行时，或者当您的环境使用外部数据库、对象存储或分布式代码仓库存储时，请使用这些过程。本指南适用于基于参考架构的环境以及具有这些特征的其他环境。

<a id="configure-daily-backups"></a>

## 配置每日备份

<a id="configure-backup-of-postgresql-data"></a>

### 配置 PostgreSQL 数据备份

[备份命令](backup_gitlab.md)使用 `pg_dump`，它[不适用于超过 100 GB 的数据库](backup_gitlab.md#postgresql-databases)。您必须选择具有原生、强大备份能力的 PostgreSQL 解决方案。

{{< tabs >}}

{{< tab title="AWS" >}}

1. [配置 AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/creating-a-backup-plan.html) 以备份 RDS（和 S3）数据。为获得最大保护，请[同时配置连续备份和快照备份](https://docs.aws.amazon.com/aws-backup/latest/devguide/point-in-time-recovery.html)。
1. 配置 AWS Backup 将备份复制到单独的区域。当 AWS 执行备份时，备份只能在存储该备份的区域中恢复。
1. 在 AWS Backup 至少运行一次计划备份后，您可以根据需要[创建按需备份](https://docs.aws.amazon.com/aws-backup/latest/devguide/recov-point-create-on-demand-backup.html)。

{{< /tab >}}

{{< tab title="Google" >}}

安排 [Google Cloud SQL 数据的每日自动备份](https://cloud.google.com/sql/docs/postgres/backup-recovery/backing-up#schedulebackups)。
每日备份[最多可保留](https://cloud.google.com/sql/docs/postgres/backup-recovery/backups#retention)一年，事务日志默认可保留 7 天，用于时间点恢复。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-backup-of-object-storage-data"></a>

### 配置对象存储数据备份

建议使用[对象存储](../object_storage.md)（[而非 NFS](../nfs.md)）来存储极狐GitLab 数据，包括 [blob](backup_gitlab.md#blobs) 和[容器镜像仓库](backup_gitlab.md#container-registry)。

{{< tabs >}}

{{< tab title="AWS" >}}

配置 AWS Backup 以备份 S3 数据。这可以在[配置 PostgreSQL 数据备份](#configure-backup-of-postgresql-data)的同时完成。

{{< /tab >}}

{{< tab title="Google" >}}

1. [在 GCS 中创建备份存储桶](https://docs.cloud.google.com/storage/docs/creating-buckets)。
1. [创建 Storage Transfer Service 作业](https://docs.cloud.google.com/storage-transfer/docs/create-transfers)，将每个极狐GitLab 对象存储桶复制到备份存储桶。
   您可以创建一次这些作业，并[安排它们每天运行](https://docs.cloud.google.com/storage-transfer/docs/schedule-transfer-jobs)。
   但这会混合新旧对象存储数据，因此在极狐GitLab 中删除的文件仍会存在于备份中。
   这会在恢复后浪费存储空间，但除此之外并无问题。这些文件对
   极狐GitLab 用户不可访问，因为它们不存在于极狐GitLab 数据库中。您可以在恢复后删除
   [其中一些孤立文件](../raketasks/cleanup.md#clean-up-project-upload-files-from-object-storage)，
   但此清理 Rake 任务仅对部分文件生效。

   1. 对于 `When to overwrite`，选择 `Never`。极狐GitLab 对象存储文件应当是固定不变的。如果恶意行为者成功修改了极狐GitLab 文件，此选择可能会有所帮助。
   1. 对于 `When to delete`，选择 `Never`。如果您将备份存储桶同步到源，那么当文件被意外或恶意从源删除时，您将无法恢复。

1. 或者，也可以将对象存储备份到按天分隔的存储桶或子目录中。这避免了恢复后出现孤立文件的问题，并在需要时支持文件版本备份。但这会大幅增加备份存储成本。这可以通过[由 Cloud Scheduler 触发的 Cloud Function](https://docs.cloud.google.com/scheduler/docs/tut-gcf-pub-sub) 或由 cronjob 运行的脚本来完成。部分示例如下：

   ```shell
   # Set GCP project so you don't have to specify it in every command
   gcloud config set project example-gcp-project-name

   # Grant the Storage Transfer Service's hidden service account permission to write to the backup bucket. The integer 123456789012 is the GCP project's ID.
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.objectAdmin gs://backup-bucket

   # Grant the Storage Transfer Service's hidden service account permission to list and read objects in the source buckets. The integer 123456789012 is the GCP project's ID.
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-artifacts
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-ci-secure-files
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-dependency-proxy
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-lfs
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-mr-diffs
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-packages
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-pages
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-registry
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-terraform-state
   gsutil iam ch serviceAccount:project-123456789012@storage-transfer-service.iam.gserviceaccount.com:roles/storage.legacyBucketReader,roles/storage.objectViewer gs://gitlab-bucket-uploads

   # Create transfer jobs for each bucket, targeting a subdirectory in the backup bucket.
   today=$(date +%F)
   gcloud transfer jobs create gs://gitlab-bucket-artifacts/ gs://backup-bucket/$today/artifacts/ --name "$today-backup-artifacts"
   gcloud transfer jobs create gs://gitlab-bucket-ci-secure-files/ gs://backup-bucket/$today/ci-secure-files/ --name "$today-backup-ci-secure-files"
   gcloud transfer jobs create gs://gitlab-bucket-dependency-proxy/ gs://backup-bucket/$today/dependency-proxy/ --name "$today-backup-dependency-proxy"
   gcloud transfer jobs create gs://gitlab-bucket-lfs/ gs://backup-bucket/$today/lfs/ --name "$today-backup-lfs"
   gcloud transfer jobs create gs://gitlab-bucket-mr-diffs/ gs://backup-bucket/$today/mr-diffs/ --name "$today-backup-mr-diffs"
   gcloud transfer jobs create gs://gitlab-bucket-packages/ gs://backup-bucket/$today/packages/ --name "$today-backup-packages"
   gcloud transfer jobs create gs://gitlab-bucket-pages/ gs://backup-bucket/$today/pages/ --name "$today-backup-pages"
   gcloud transfer jobs create gs://gitlab-bucket-registry/ gs://backup-bucket/$today/registry/ --name "$today-backup-registry"
   gcloud transfer jobs create gs://gitlab-bucket-terraform-state/ gs://backup-bucket/$today/terraform-state/ --name "$today-backup-terraform-state"
   gcloud transfer jobs create gs://gitlab-bucket-uploads/ gs://backup-bucket/$today/uploads/ --name "$today-backup-uploads"
   ```

   1. 这些传输作业在运行后不会自动删除。您可以在脚本中实现对旧作业的清理。
   1. 示例脚本不会删除旧备份。您可以根据所需的保留策略实现对旧备份的清理。
1. 确保备份在 Cloud SQL 备份的同一时间或之后执行，以减少数据不一致。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-backup-of-git-repositories"></a>

### 配置 Git 代码仓库备份

设置 cronjob 以执行 Gitaly 服务器端备份：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 按照[配置服务器端备份](../gitaly/configure_gitaly.md#configure-server-side-backups)，在所有 Gitaly 节点上配置 Gitaly 服务器端备份目标。
   此存储桶专供 Gitaly 用于存储代码仓库数据。
1. 当 Gitaly 将全部 Git 代码仓库数据备份到之前配置的指定对象存储桶时，
   备份实用工具（`gitlab-backup`）会上传额外的备份数据。此数据包括一个包含恢复所需基本元数据的 `tar` 文件。
   您可以使用与其他备份相同的存储桶，也可以使用单独的存储桶。按照
   [将备份上传到远程（云）存储](backup_gitlab.md#upload-backups-to-a-remote-cloud-storage)设置上传存储桶，确保此备份数据正确上传到远程（云）存储。
1. （可选）为增强此备份数据的持久性，可将之前配置的任何存储桶添加到
   [对象存储数据备份](#configure-backup-of-object-storage-data)中，由其各自的对象存储提供商进行备份。
1. SSH 登录到 GitLab Rails 节点，即运行 Puma 或 Sidekiq 的节点。
1. 对 Git 数据进行完整备份。使用 `REPOSITORIES_SERVER_SIDE` 变量，并跳过 PostgreSQL 数据：

   ```shell
   sudo gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db
   ```

   这会使 Gitaly 节点将 Git 数据和部分元数据上传到远程存储。上传文件、产物和 LFS 等 blob 无需显式跳过，因为 `gitlab-backup` 命令默认不备份对象存储。

1. 记下备份的[备份 ID](backup_archive_process.md#backup-id)，下一步需要用到。例如，如果备份命令输出
   `2024-02-22 02:17:47 UTC -- Backup 1708568263_2024_02_22_16.9.0-ce is done.`，则备份 ID 为 `1708568263_2024_02_22_16.9.0-ce`。
1. 检查完整备份是否在 Gitaly 备份存储桶和常规备份存储桶中都创建了数据。
1. 再次运行[备份命令](backup_gitlab.md#backup-command)，这次指定 [Git 代码仓库增量备份](backup_gitlab.md#incremental-repository-backups)和备份 ID。使用上一步中的示例 ID，命令为：

   ```shell
   sudo gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db INCREMENTAL=yes PREVIOUS_BACKUP=1708568263_2024_02_22_16.9.0-ce
   ```

   此命令不使用 `PREVIOUS_BACKUP`的值，但该命令要求提供它。有一个议题用于移除此不必要的需求，请参见[议题 429141](https://gitlab.com/gitlab-org/gitlab/-/issues/429141)。

1. 检查增量备份是否成功，并向对象存储添加了数据。
1. [配置 cron 以执行每日备份](backup_gitlab.md#configuring-cron-to-make-daily-backups)。编辑 `root` 用户的 crontab：

   ```shell
   sudo su -
   crontab -e
   ```

1. 在其中添加以下行，以安排每月每天的凌晨 2 点执行备份。为限制恢复备份所需的增量数量，将在每月 1 日执行 Git 代码仓库的完整备份，其余日期执行增量备份：

   ```plaintext
   0 2 1 * * /opt/gitlab/bin/gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db CRON=1
   0 2 2-31 * * /opt/gitlab/bin/gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db INCREMENTAL=yes PREVIOUS_BACKUP=1708568263_2024_02_22_16.9.0-ce CRON=1
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 按照[配置服务器端备份](../gitaly/configure_gitaly.md#configure-server-side-backups)，在所有 Gitaly 节点上配置 Gitaly 服务器端备份目标。此存储桶专供 Gitaly 用于存储代码仓库数据。
1. 当 Gitaly 将全部 Git 代码仓库数据备份到之前配置的指定对象存储桶时，
   备份实用工具（`gitlab-backup`）会上传额外的备份数据。此数据包括一个包含恢复所需基本元数据的 `tar` 文件。
   您可以使用与其他备份相同的存储桶，也可以使用单独的存储桶。按照
   [将备份上传到远程（云）存储](backup_gitlab.md#upload-backups-to-a-remote-cloud-storage)设置上传存储桶，确保此备份数据正确上传到远程（云）存储。
1. （可选）为增强此备份数据的持久性，可将之前配置的任何存储桶添加到
   [对象存储数据备份](#configure-backup-of-object-storage-data)中，由其各自的对象存储提供商进行备份。
1. SSH 登录到 GitLab Rails 节点，即运行 Puma 或 Sidekiq 的节点。
1. 对 Git 数据进行完整备份。使用 `REPOSITORIES_SERVER_SIDE` 变量并跳过所有其他数据：

   ```shell
   kubectl exec <Toolbox pod name> -it -- backup-utility --repositories-server-side --skip db,builds,pages,registry,uploads,artifacts,lfs,packages,external_diffs,terraform_state,pages,ci_secure_files
   ```

   这会使 Gitaly 节点将 Git 数据和部分元数据上传到远程存储。请参见 [Toolbox 包含的工具](https://gitlab.cn/docs/charts/charts/gitlab/toolbox/#toolbox-included-tools)。

1. 检查完整备份是否在 Gitaly 备份存储桶和常规备份存储桶中都创建了数据。`backup-utility` 在服务器端代码仓库备份中不支持增量代码仓库备份，请参见 [charts 议题 3421](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3421)。
1. [配置 cron 以执行每日备份](https://gitlab.cn/docs/charts/backup-restore/backup/#cron-based-backup)。具体来说，将 `gitlab.toolbox.backups.cron.extraArgs` 设置为包含：

   ```shell
   --repositories-server-side --skip db --skip repositories --skip uploads --skip builds --skip artifacts --skip pages --skip lfs --skip terraform_state --skip registry --skip packages --skip ci_secure_files
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="configure-backup-of-configuration-files"></a>

### 配置配置文件备份

如果您的配置和密钥在部署之外定义，然后再部署到其中，那么备份策略的实施取决于您的具体设置和要求。例如，您可以将密钥存储在 [AWS 密钥管理器](https://aws.amazon.com/secrets-manager/)中，并[复制到多个区域](https://docs.aws.amazon.com/secretsmanager/latest/userguide/replicate-secrets.html)，然后配置脚本自动备份密钥。

如果您的配置和密钥仅在部署内部定义：

1. [存储配置文件](backup_gitlab.md#storing-configuration-files)介绍了如何提取配置文件和密钥文件。
1. 这些文件应上传到单独的、限制更严格的对象存储账号。

<a id="restore-a-backup"></a>

## 恢复备份

恢复极狐GitLab 实例的备份。

<a id="prerequisites"></a>

### 先决条件

恢复备份之前：

1. 选择一个[可正常工作的目标极狐GitLab 实例](restore_gitlab.md#the-destination-gitlab-instance-must-already-be-working)。
1. 确保目标极狐GitLab 实例位于存储您的 AWS 备份的区域中。
1. 检查[目标极狐GitLab 实例使用的极狐GitLab 版本和类型（基础版或企业版）与创建备份数据时完全一致](restore_gitlab.md#the-destination-gitlab-instance-must-have-the-exact-same-version)。例如，基础版 15.1.4。
1. [将备份的密钥恢复到目标极狐GitLab 实例](restore_gitlab.md#gitlab-secrets-must-be-restored)。
1. 确保[目标极狐GitLab 实例配置了相同的代码仓库存储](restore_gitlab.md#certain-gitlab-configuration-must-match-the-original-backed-up-environment)。
   额外的存储没有问题。
1. 确保[已配置对象存储](restore_gitlab.md#certain-gitlab-configuration-must-match-the-original-backed-up-environment)。
1. 要使用新的密钥或配置，并避免在恢复期间处理任何意外的配置更改：

   - 所有节点上的 Linux 软件包安装：
     1. [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)目标极狐GitLab 实例。
     1. [重启](../restart_gitlab.md#restart-a-linux-package-installation)目标极狐GitLab 实例。

   - Helm chart（Kubernetes）安装：

     1. 在所有极狐GitLab Linux 软件包节点上运行：

        ```shell
        sudo gitlab-ctl reconfigure
        sudo gitlab-ctl start
        ```

     1. 通过部署 chart 确保您有一个正在运行的极狐GitLab 实例。
        执行以下命令，确保 Toolbox pod 已启用并正在运行：

        ```shell
        kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
        ```

     1. 必须重启 Webservice、Sidekiq 和 Toolbox pod。
        重启这些 pod 最安全的方式是运行：

        ```shell
        kubectl delete pods -lapp=sidekiq,release=<helm release name>
        kubectl delete pods -lapp=webservice,release=<helm release name>
        kubectl delete pods -lapp=toolbox,release=<helm release name>
        ```

1. 确认目标极狐GitLab 实例仍可正常工作。例如：

   - 向[健康检查端点](../monitoring/health_check.md)发出请求。
   - [运行极狐GitLab 检查 Rake 任务](../raketasks/maintenance.md#check-gitlab-configuration)。

1. 停止连接到 PostgreSQL 数据库的极狐GitLab 服务。

   - 在所有运行 Puma 或 Sidekiq 的节点上的 Linux 软件包安装，运行：

     ```shell
     sudo gitlab-ctl stop
     ```

   - Helm chart（Kubernetes）安装：

     1. 记下数据库客户端当前的副本数，以便后续重启：

        ```shell
        kubectl get deploy -n <namespace> -lapp=sidekiq,release=<helm release name> -o jsonpath='{.items[].spec.replicas}{"\n"}'
        kubectl get deploy -n <namespace> -lapp=webservice,release=<helm release name> -o jsonpath='{.items[].spec.replicas}{"\n"}'
        kubectl get deploy -n <namespace> -lapp=prometheus,release=<helm release name> -o jsonpath='{.items[].spec.replicas}{"\n"}'
        ```

     1. 停止数据库客户端，以防止锁干扰恢复过程：

        ```shell
        kubectl scale deploy -lapp=sidekiq,release=<helm release name> -n <namespace> --replicas=0
        kubectl scale deploy -lapp=webservice,release=<helm release name> -n <namespace> --replicas=0
        kubectl scale deploy -lapp=prometheus,release=<helm release name> -n <namespace> --replicas=0
        ```

<a id="restore-object-storage-data"></a>

### 恢复对象存储数据

{{< tabs >}}

{{< tab title="AWS" >}}

每个存储桶在 AWS 中作为单独的备份存在，每个备份都可以恢复到现有或
新存储桶。

1. 要恢复存储桶，需要具有正确权限的 IAM 角色：

   - `AWSBackupServiceRolePolicyForBackup`
   - `AWSBackupServiceRolePolicyForRestores`
   - `AWSBackupServiceRolePolicyForS3Restore`
   - `AWSBackupServiceRolePolicyForS3Backup`

1. 如果使用现有存储桶，则必须
   [启用访问控制列表](https://docs.aws.amazon.com/AmazonS3/latest/userguide/managing-acls.html)。
1. [使用内置工具恢复 S3 存储桶](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-s3.html)。
1. 在恢复作业运行期间，您可以继续执行[恢复 PostgreSQL 数据](#restore-postgresql-data)。

{{< /tab >}}

{{< tab title="Google" >}}

1. [创建 Storage Transfer Service 作业](https://docs.cloud.google.com/storage-transfer/docs/create-transfers)，将备份数据传输到极狐GitLab 存储桶。
1. 在传输作业运行期间，您可以继续执行[恢复 PostgreSQL 数据](#restore-postgresql-data)。

{{< /tab >}}

{{< /tabs >}}

<a id="restore-postgresql-data"></a>

### 恢复 PostgreSQL 数据

{{< tabs >}}

{{< tab title="AWS" >}}

1. [使用内置工具恢复 AWS RDS 数据库](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-rds.html)，
   这会创建一个新的 RDS 实例。
1. 由于新的 RDS 实例具有不同的端点，您必须重新配置目标极狐GitLab 实例
   以指向新数据库：

   - 对于 Linux 软件包安装，请遵循
     [使用非软件包形式的 PostgreSQL 数据库管理服务器](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)。

   - 对于 Helm chart（Kubernetes）安装，请遵循
     [使用外部数据库配置 GitLab chart](https://gitlab.cn/docs/charts/advanced/external-db/)。

1. 在继续之前，请等待新的 RDS 实例创建完成并可供使用。

{{< /tab >}}

{{< tab title="Google" >}}

1. [使用内置工具恢复 Google Cloud SQL 数据库](https://docs.cloud.google.com/sql/docs/postgres/backup-recovery/restoring)。
1. 如果恢复到新的数据库实例，则重新配置极狐GitLab 以指向新数据库：

   - 对于 Linux 软件包安装，请遵循
     [使用非软件包形式的 PostgreSQL 数据库管理服务器](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)。

   - 对于 Helm chart（Kubernetes）安装，请遵循
     [使用外部数据库配置 GitLab chart](https://gitlab.cn/docs/charts/advanced/external-db/)。

1. 在继续之前，请等待 Cloud SQL 实例可供使用。

{{< /tab >}}

{{< /tabs >}}

<a id="restore-git-repositories"></a>

### 恢复 Git 代码仓库

首先，作为[恢复对象存储数据](#restore-object-storage-data)的一部分，您应该已经：

- 恢复了包含 Git 代码仓库的 Gitaly 服务器端备份的存储桶。
- 恢复了包含 `*_gitlab_backup.tar` 文件的存储桶。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. SSH 登录到 GitLab Rails 节点，即运行 Puma 或 Sidekiq 的节点。
1. 在您的备份存储桶中，根据时间戳选择一个 `*_gitlab_backup.tar` 文件，与您恢复的 PostgreSQL 和对象存储数据保持一致。
1. 将 `tar` 文件下载到 `/var/opt/gitlab/backups/`。
1. 恢复备份，指定您要恢复的备份 ID，从名称中省略 `_gitlab_backup.tar`：

   ```shell
   # This command will overwrite the contents of your GitLab database!
   sudo gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce SKIP=db
   ```

   如果您的备份 tar 文件与已安装的极狐GitLab 版本之间存在版本不匹配，
   恢复命令会中止并显示错误消息。
   请安装[正确的极狐GitLab 版本](https://packages.gitlab.cn/#browse/browse)，然后重试。

1. 重新配置、启动并[检查](../raketasks/maintenance.md#check-gitlab-configuration)极狐GitLab：

   1. 在所有 PostgreSQL 节点中运行：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 在所有 Puma 或 Sidekiq 节点中运行：

      ```shell
      sudo gitlab-ctl start
      ```

   1. 在一个 Puma 或 Sidekiq 节点中运行：

      ```shell
      sudo gitlab-rake gitlab:check SANITIZE=true
      ```

1. 检查
   [数据库值是否可以解密](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)，
   尤其是在恢复了 `/etc/gitlab/gitlab-secrets.json`的情况下，或者如果恢复的目标是
   其他服务器：

   在 Puma 或 Sidekiq 节点中运行：

   ```shell
   sudo gitlab-rake gitlab:doctor:secrets
   ```

1. 为增加保障，您可以
   [对上传文件进行完整性检查](../raketasks/check.md#uploaded-files-integrity)：

   在 Puma 或 Sidekiq 节点中运行：

   ```shell
   sudo gitlab-rake gitlab:artifacts:check
   sudo gitlab-rake gitlab:lfs:check
   sudo gitlab-rake gitlab:uploads:check
   ```

   如果发现文件缺失或损坏，并不总是意味着备份和恢复过程失败。
   例如，这些文件可能在源极狐GitLab 实例上就已缺失或损坏。您可能需要交叉参考之前的备份。
   如果您要将极狐GitLab 迁移到新环境，可以在源极狐GitLab 实例上运行相同的检查，以确定
   完整性检查结果是先前就存在的，还是与备份和恢复过程相关。

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. SSH 登录到 toolbox pod。
1. 在您的备份存储桶中，根据时间戳选择一个 `*_gitlab_backup.tar` 文件，与您恢复的 PostgreSQL 和对象存储数据保持一致。
1. 将 `tar` 文件下载到 `/var/opt/gitlab/backups/`。
1. 恢复备份，指定您要恢复的备份 ID，从名称中省略 `_gitlab_backup.tar`：

   ```shell
   # This command will overwrite the contents of Gitaly!
   kubectl exec <Toolbox pod name> -it -- backup-utility --restore -t 11493107454_2018_04_25_10.6.4-ce --skip db,builds,pages,registry,uploads,artifacts,lfs,packages,external_diffs,terraform_state,pages,ci_secure_files
   ```

   如果您的备份 tar 文件与已安装的极狐GitLab 版本之间存在版本不匹配，
   恢复命令会中止并显示错误消息。
   请安装[正确的极狐GitLab 版本](https://packages.gitlab.cn/#browse/browse)，然后重试。

1. 重启并[检查](../raketasks/maintenance.md#check-gitlab-configuration)极狐GitLab：

   1. 使用[先决条件](#prerequisites)中记下的副本数，启动已停止的部署：

      ```shell
      kubectl scale deploy -lapp=sidekiq,release=<helm release name> -n <namespace> --replicas=<original value>
      kubectl scale deploy -lapp=webservice,release=<helm release name> -n <namespace> --replicas=<original value>
      kubectl scale deploy -lapp=prometheus,release=<helm release name> -n <namespace> --replicas=<original value>
      ```

   1. 在 Toolbox pod 中运行：

      ```shell
      sudo gitlab-rake gitlab:check SANITIZE=true
      ```

1. 检查
   [数据库值是否可以解密](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)，
   尤其是在恢复了 `/etc/gitlab/gitlab-secrets.json`的情况下，或者如果恢复的目标是
   其他服务器：

   在 Toolbox pod 中运行：

   ```shell
   sudo gitlab-rake gitlab:doctor:secrets
   ```

1. 为增加保障，您可以
   [对上传文件进行完整性检查](../raketasks/check.md#uploaded-files-integrity)：

   这些命令可能需要很长时间，因为它们会遍历所有行。因此，请在 GitLab Rails 节点中
   运行以下命令，而不是在 Toolbox pod 中：

   ```shell
   sudo gitlab-rake gitlab:artifacts:check
   sudo gitlab-rake gitlab:lfs:check
   sudo gitlab-rake gitlab:uploads:check
   ```

   如果发现文件缺失或损坏，并不总是意味着备份和恢复过程失败。
   例如，这些文件可能在源极狐GitLab 实例上就已缺失或损坏。您可能需要交叉参考之前的备份。
   如果您要将极狐GitLab 迁移到新环境，可以在源极狐GitLab 实例上运行相同的检查，以确定
   完整性检查结果是先前就存在的，还是与备份和恢复过程相关。

{{< /tab >}}

{{< /tabs >}}

恢复应已完成。
