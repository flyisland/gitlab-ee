---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 备份和恢复大型参考架构
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 备份可确保大规模极狐GitLab 部署的数据一致性，并支持灾难恢复。此流程：

- 协调跨分布式存储组件的数据备份
- 保护大小高达数 TB 的 PostgreSQL 数据库
- 保护外部服务中的对象存储数据
- 维护大型 Git 仓库集合的备份完整性
- 创建配置文件和密钥文件的可恢复副本
- 支持以最短停机时间恢复系统数据

对于运行支持 3,000 名以上用户的参考架构的极狐GitLab 环境，请遵循这些过程，并特别注意基于云的数据库和对象存储。

> [!note]
> 本文档适用于以下环境：
>
> - [Linux 包 (Omnibus) 和云原生混合参考架构 60 RPS / 3,000 名用户及以上](../reference_architectures/_index.md)
> - 用于 PostgreSQL 数据的 [Amazon RDS](https://aws.amazon.com/rds/)
> - 用于对象存储的 [Amazon S3](https://aws.amazon.com/s3/)
> - [对象存储](../object_storage.md)，用于存储所有可能的内容，包括 [blobs](backup_gitlab.md#blobs) 和 [容器镜像仓库](backup_gitlab.md#container-registry)

<a id="configure-daily-backups"></a>

## 配置每日备份

<a id="configure-backup-of-postgresql-data"></a>

### 配置 PostgreSQL 数据的备份

[备份命令](backup_gitlab.md) 使用 `pg_dump`，这 [不适用于超过 100 GB 的数据库](backup_gitlab.md#postgresql-databases)。你必须选择具有原生、强大备份功能的 PostgreSQL 解决方案。

{{< tabs >}}

{{< tab title="AWS" >}}

1. [配置 AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/creating-a-backup-plan.html) 以备份 RDS（和 S3）数据。为了获得最大保护，请 [配置连续备份和快照备份](https://docs.aws.amazon.com/aws-backup/latest/devguide/point-in-time-recovery.html)。
1. 配置 AWS Backup 将备份复制到另一个区域。当 AWS 制作备份时，备份只能在其存储的区域中恢复。
1. 在 AWS Backup 至少运行一次计划备份后，你可以根据需要 [创建按需备份](https://docs.aws.amazon.com/aws-backup/latest/devguide/recov-point-create-on-demand-backup.html)。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-backup-of-object-storage-data"></a>

### 配置对象存储数据的备份

推荐使用 [对象存储](../object_storage.md)（而非 [NFS](../nfs.md)) 来存储极狐GitLab 数据，包括 [blobs](backup_gitlab.md#blobs) 和 [容器镜像仓库](backup_gitlab.md#container-registry)。

{{< tabs >}}

{{< tab title="AWS" >}}

配置 AWS Backup 以备份 S3 数据。这可以在 [配置 PostgreSQL 数据备份](#configure-backup-of-postgresql-data) 的同时完成。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-backup-of-git-repositories"></a>

### 配置 Git 仓库的备份

设置 cronjob 以执行 Gitaly 服务器端备份：

{{< tabs >}}

{{< tab title="Linux 包 (Omnibus)" >}}

1. 在所有 Gitaly 节点上配置 Gitaly 服务器端备份目标，按照 [配置服务器端备份](../gitaly/configure_gitaly.md#configure-server-side-backups) 进行操作。此存储桶仅供 Gitaly 用于存储仓库数据。
1. Gitaly 将之前配置的指定对象存储桶中的所有 Git 仓库数据备份，而备份实用工具 (`gitlab-backup`) 会上传额外的备份数据。此数据包括一个包含恢复所需基本元数据的 `tar` 文件。你可以使用与其他备份相同的存储桶或单独的存储桶。确保按照 [将备份上传到远程（云）存储](backup_gitlab.md#upload-backups-to-a-remote-cloud-storage) 正确设置上传存储桶，将此备份数据正确上传到远程（云）存储。
1. （可选）为巩固此备份数据的持久性，可将之前配置的任何存储桶添加到其各自的对象存储提供商，通过 [对象存储数据的备份](#configure-backup-of-object-storage-data) 进行备份。
1. SSH 进入极狐GitLab Rails 节点，即运行 Puma 或 Sidekiq 的节点。
1. 对 Git 数据执行完整备份。使用 `REPOSITORIES_SERVER_SIDE` 变量，并跳过 PostgreSQL 数据：

   ```shell
   sudo gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db
   ```

   这将使 Gitaly 节点将 Git 数据和部分元数据上传到远程存储。默认情况下，`gitlab-backup` 命令不会备份对象存储，因此无需显式跳过上传、产物和 LFS 等 blobs。

1. 记录备份的 [备份 ID](backup_archive_process.md#backup-id)，下一步需要使用。例如，如果备份命令输出 `2024-02-22 02:17:47 UTC -- Backup 1708568263_2024_02_22_16.9.0-ce is done.`，则备份 ID 为 `1708568263_2024_02_22_16.9.0-ce`。
1. 检查完整备份是否在 Gitaly 备份存储桶和常规备份存储桶中都创建了数据。
1. 再次运行 [备份命令](backup_gitlab.md#backup-command)，这次指定 [Git 仓库的增量备份](backup_gitlab.md#incremental-repository-backups) 和备份 ID。使用上一步的示例 ID，命令为：

   ```shell
   sudo gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db INCREMENTAL=yes PREVIOUS_BACKUP=1708568263_2024_02_22_16.9.0-ce
   ```

   此命令不使用 `PREVIOUS_BACKUP` 的值，但该值是命令所必需的。有一个议题是关于消除这一不必要要求的，参见 [issue 429141](https://gitlab.com/gitlab-org/gitlab/-/issues/429141)。

1. 检查增量备份是否成功，并向对象存储添加了数据。
1. [配置 cron 以实现每日备份](backup_gitlab.md#configuring-cron-to-make-daily-backups)。编辑 `root` 用户的 crontab：

   ```shell
   sudo su -
   crontab -e
   ```

1. 然后，添加以下行，计划在每天凌晨 2 点进行备份。为限制恢复备份所需的增量数量，将在每月的第一天执行 Git 仓库的完整备份，其余日子则执行增量备份：

   ```plaintext
   0 2 1 * * /opt/gitlab/bin/gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db CRON=1
   0 2 2-31 * * /opt/gitlab/bin/gitlab-backup create REPOSITORIES_SERVER_SIDE=true SKIP=db INCREMENTAL=yes PREVIOUS_BACKUP=1708568263_2024_02_22_16.9.0-ce CRON=1
   ```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 在所有 Gitaly 节点上配置 Gitaly 服务器端备份目标，按照 [配置服务器端备份](../gitaly/configure_gitaly.md#configure-server-side-backups) 进行操作。此存储桶仅供 Gitaly 用于存储仓库数据。
1. Gitaly 将之前配置的指定对象存储桶中的所有 Git 仓库数据备份，而备份实用工具 (`gitlab-backup`) 会上传额外的备份数据。此数据包括一个包含恢复所需基本元数据的 `tar` 文件。你可以使用与其他备份相同的存储桶或单独的存储桶。确保按照 [将备份上传到远程（云）存储](backup_gitlab.md#upload-backups-to-a-remote-cloud-storage) 正确设置上传存储桶，将此备份数据正确上传到远程（云）存储。
1. （可选）为巩固此备份数据的持久性，可将之前配置的任何存储桶添加到其各自的对象存储提供商，通过 [对象存储数据的备份](#configure-backup-of-object-storage-data) 进行备份。
1. SSH 进入极狐GitLab Rails 节点，即运行 Puma 或 Sidekiq 的节点。
1. 对 Git 数据执行完整备份。使用 `REPOSITORIES_SERVER_SIDE` 变量并跳过所有其他数据：

   ```shell
   kubectl exec <Toolbox pod name> -it -- backup-utility --repositories-server-side --skip db,builds,pages,registry,uploads,artifacts,lfs,packages,external_diffs,terraform_state,pages,ci_secure_files
   ```

   这将使 Gitaly 节点将 Git 数据和部分元数据上传到远程存储。请参见 [Toolbox 包含的工具](https://gitlab.cn/docs/charts/charts/gitlab/toolbox/#toolbox-included-tools)。

1. 检查完整备份是否在 Gitaly 备份存储桶和常规备份存储桶中都创建了数据。服务器端仓库备份不支持通过 `backup-utility` 进行增量仓库备份，请参见 [charts issue 3421](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3421)。
1. [配置 cron 以实现每日备份](https://gitlab.cn/docs/charts/backup-restore/backup/#cron-based-backup)。具体来说，设置 `gitlab.toolbox.backups.cron.extraArgs` 以包含：

   ```shell
   --repositories-server-side --skip db --skip repositories --skip uploads --skip builds --skip artifacts --skip pages --skip lfs --skip terraform_state --skip registry --skip packages --skip ci_secure_files
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="configure-backup-of-configuration-files"></a>

### 配置配置文件的备份

如果你的配置和密钥是在部署外部定义然后部署到其中的，那么备份策略的实施取决于你的具体设置和要求。例如，你可以将密钥存储在 [AWS Secret Manager](https://aws.amazon.com/secrets-manager/) 中，并 [复制到多个区域](https://docs.aws.amazon.com/secretsmanager/latest/userguide/create-manage-multi-region-secrets.html)，然后配置脚本自动备份密钥。

如果你的配置和密钥仅在部署内部定义：

1. [存储配置文件](backup_gitlab.md#storing-configuration-files) 描述了如何提取配置和密钥文件。
1. 这些文件应上传到一个单独的、限制更严格的对象存储账户。

<a id="restore-a-backup"></a>

## 恢复备份

恢复极狐GitLab 实例的备份。

<a id="prerequisites"></a>

### 先决条件

在恢复备份之前：

1. 选择一个 [正常工作的目标极狐GitLab 实例](restore_gitlab.md#the-destination-gitlab-instance-must-already-be-working)。
1. 确保目标极狐GitLab 实例位于存储 AWS 备份的区域。
1. 检查 [目标极狐GitLab 实例使用的极狐GitLab 版本和类型（基础版或企业版）与创建备份数据时的版本和类型完全相同](restore_gitlab.md#the-destination-gitlab-instance-must-have-the-exact-same-version)，例如 CE 15.1.4。
1. [将备份的密钥恢复到目标极狐GitLab 实例](restore_gitlab.md#gitlab-secrets-must-be-restored)。
1. 确保 [目标极狐GitLab 实例配置了相同的仓库存储](restore_gitlab.md#certain-gitlab-configuration-must-match-the-original-backed-up-environment)。额外的存储是可以的。
1. 确保 [对象存储已配置](restore_gitlab.md#certain-gitlab-configuration-must-match-the-original-backed-up-environment)。
1. 要使用新的密钥或配置，并避免在恢复过程中遇到任何意外的配置更改：

   - 所有节点上的 Linux 包安装：
     1. [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation) 目标极狐GitLab 实例。
     1. [重新启动](../restart_gitlab.md#restart-a-linux-package-installation) 目标极狐GitLab 实例。

   - Helm Chart (Kubernetes) 安装：

     1. 在所有极狐GitLab Linux 包节点上运行：

        ```shell
        sudo gitlab-ctl reconfigure
        sudo gitlab-ctl start
        ```

     1. 通过部署 Chart，确保你有一个正在运行的极狐GitLab 实例。通过执行以下命令确保 Toolbox Pod 已启用并正在运行：

        ```shell
        kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
        ```

     1. Webservice、Sidekiq 和 Toolbox Pod 必须重新启动。重新启动这些 Pod 最安全的方法是运行：

        ```shell
        kubectl delete pods -lapp=sidekiq,release=<helm release name>
        kubectl delete pods -lapp=webservice,release=<helm release name>
        kubectl delete pods -lapp=toolbox,release=<helm release name>
        ```

1. 确认目标极狐GitLab 实例仍然正常工作。例如：

   - 向 [健康检查端点](../monitoring/health_check.md) 发送请求。
   - [运行极狐GitLab 检查 Rake 任务](../raketasks/maintenance.md#check-gitlab-configuration)。

1. 停止连接到 PostgreSQL 数据库的极狐GitLab 服务。

   - 在所有运行 Puma 或 Sidekiq 的节点上的 Linux 包安装，运行：

     ```shell
     sudo gitlab-ctl stop
     ```

   - Helm Chart (Kubernetes) 安装：

     1. 记下数据库客户端的当前副本数，以备后续重启：

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

每个存储桶作为 AWS 内的单独备份存在，每个备份都可以恢复到现有或新的存储桶。

1. 要恢复存储桶，需要具有正确权限的 IAM 角色：
   - `AWSBackupServiceRolePolicyForBackup`
   - `AWSBackupServiceRolePolicyForRestores`
   - `AWSBackupServiceRolePolicyForS3Restore`
   - `AWSBackupServiceRolePolicyForS3Backup`
1. 如果使用现有存储桶，则必须启用 [访问控制列表](https://docs.aws.amazon.com/AmazonS3/latest/userguide/managing-acls.html)。
1. [使用内置工具恢复 S3 存储桶](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-s3.html)。
1. 在恢复作业运行时，你可以继续 [恢复 PostgreSQL 数据](#restore-postgresql-data)。

{{< /tab >}}

{{< /tabs >}}

<a id="restore-postgresql-data"></a>

### 恢复 PostgreSQL 数据

{{< tabs >}}

{{< tab title="AWS" >}}

1. [使用内置工具恢复 AWS RDS 数据库](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-rds.html)，这将创建一个新的 RDS 实例。
1. 因为新的 RDS 实例具有不同的端点，你必须重新配置目标极狐GitLab 实例以指向新数据库：

   - 对于 Linux 包安装，请遵循 [使用非打包的 PostgreSQL 数据库管理服务器](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)。
   - 对于 Helm Chart (Kubernetes) 安装，请遵循 [使用外部数据库配置极狐GitLab Chart](https://gitlab.cn/docs/charts/advanced/external-db/)。

1. 在继续之前，请等待新的 RDS 实例创建完毕并可供使用。

{{< /tab >}}

{{< /tabs >}}

<a id="restore-git-repositories"></a>

### 恢复 Git 仓库

首先，作为 [恢复对象存储数据](#restore-object-storage-data) 的一部分，你应该已经：

- 恢复了包含 Gitaly 服务器端 Git 仓库备份的存储桶。
- 恢复了包含 `*_gitlab_backup.tar` 文件的存储桶。

{{< tabs >}}

{{< tab title="Linux 包 (Omnibus)" >}}

1. SSH 进入极狐GitLab Rails 节点，即运行 Puma 或 Sidekiq 的节点。
1. 在你的备份存储桶中，根据时间戳选择一个 `*_gitlab_backup.tar` 文件，该时间戳与你恢复的 PostgreSQL 和对象存储数据保持一致。
1. 将 `tar` 文件下载到 `/var/opt/gitlab/backups/`。
1. 恢复备份，指定你要恢复的备份的 ID，从名称中省略 `_gitlab_backup.tar`：

   ```shell
   # 此命令将覆盖你的极狐GitLab 数据库内容！
   sudo gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce SKIP=db
   ```

   如果你的备份 tar 文件与已安装的极狐GitLab 版本之间存在版本不匹配，恢复命令将中止并显示错误消息。安装 [正确的极狐GitLab 版本](https://packages.gitlab.cn/ui/browse/gitlab)，然后重试。

1. 重新配置、启动并 [检查](../raketasks/maintenance.md#check-gitlab-configuration) 极狐GitLab：

   1. 在所有 PostgreSQL 节点上运行：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 在所有 Puma 或 Sidekiq 节点上运行：

      ```shell
      sudo gitlab-ctl start
      ```

   1. 在一个 Puma 或 Sidekiq 节点上运行：

      ```shell
      sudo gitlab-rake gitlab:check SANITIZE=true
      ```

1. 检查 [数据库值是否可以使用当前密钥解密](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)，尤其是在 `/etc/gitlab/gitlab-secrets.json` 已恢复，或者另一台服务器是恢复目标的情况下：

   在 Puma 或 Sidekiq 节点上运行：
```shell
sudo gitlab-rake gitlab:doctor:secrets
```

1. 为了进一步确认，你可以执行
   [上传文件的完整性检查](../raketasks/check.md#uploaded-files-integrity)：

   在 Puma 或 Sidekiq 节点上运行：

   ```shell
   sudo gitlab-rake gitlab:artifacts:check
   sudo gitlab-rake gitlab:lfs:check
   sudo gitlab-rake gitlab:uploads:check
   ```

   如果发现丢失或损坏的文件，并不总是意味着备份和恢复过程失败。
   例如，这些文件可能在源极狐GitLab 实例上就已丢失或损坏。你可能需要交叉参考之前的备份。
   如果你正在将极狐GitLab 迁移到新环境，可以在源极狐GitLab 实例上运行相同的检查，以确定
   完整性检查结果是预先存在的还是与备份和恢复过程相关。

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 通过 SSH 登录到 toolbox pod。
1. 在你的备份存储桶中，根据时间戳选择一个 `*_gitlab_backup.tar` 文件，该时间戳应与你恢复的 PostgreSQL 和对象存储数据一致。
1. 将 `tar` 文件下载到 `/var/opt/gitlab/backups/`。
1. 恢复备份，指定你要恢复的备份 ID，从名称中省略 `_gitlab_backup.tar`：

   ```shell
   # 此命令将覆盖 Gitaly 的内容！
   kubectl exec <Toolbox pod name> -it -- backup-utility --restore -t 11493107454_2018_04_25_10.6.4-ce --skip db,builds,pages,registry,uploads,artifacts,lfs,packages,external_diffs,terraform_state,pages,ci_secure_files
   ```

   如果备份 tar 文件与已安装的极狐GitLab 版本不匹配，恢复命令将中止并显示错误信息。
   安装[正确的极狐GitLab 版本](https://packages.gitlab.cn/ui/browse/gitlab)，然后重试。

1. 重启并[检查](../raketasks/maintenance.md#check-gitlab-configuration)极狐GitLab：

   1. 启动已停止的部署，使用[前提条件](#prerequisites)中记录的副本数量：

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
   [数据库值是否可以使用当前密钥解密](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)，
   尤其是在恢复了 `/etc/gitlab/gitlab-secrets.json` 或恢复目标为不同服务器的情况下：

   在 Toolbox pod 中运行：

   ```shell
   sudo gitlab-rake gitlab:doctor:secrets
   ```

1. 为了进一步确认，你可以执行
   [上传文件的完整性检查](../raketasks/check.md#uploaded-files-integrity)：

   这些命令可能需要很长时间，因为它们会遍历所有行。因此，请在极狐GitLab Rails 节点中运行以下命令，而不是在 Toolbox pod 中：

   ```shell
   sudo gitlab-rake gitlab:artifacts:check
   sudo gitlab-rake gitlab:lfs:check
   sudo gitlab-rake gitlab:uploads:check
   ```

   如果发现丢失或损坏的文件，并不总是意味着备份和恢复过程失败。
   例如，这些文件可能在源极狐GitLab 实例上就已丢失或损坏。你可能需要交叉参考之前的备份。
   如果你正在将极狐GitLab 迁移到新环境，可以在源极狐GitLab 实例上运行相同的检查，以确定
   完整性检查结果是预先存在的还是与备份和恢复过程相关。

{{< /tab >}}

{{< /tabs >}}

恢复应该已完成。