---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
ignore_in_report: true
title: 使用 `gitlab-backup-cli` 备份和恢复极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: Experiment

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.0 [引入](https://gitlab.com/groups/gitlab-org/-/epics/11908)。此功能为[实验性功能](../../policy/development_stages_support.md)，受[极狐GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)约束。

{{< /history >}}

此工具正在开发中，最终旨在替代[用于备份和恢复极狐GitLab 的 Rake 任务](backup_gitlab.md)。你可以在以下史诗中追踪此工具的开发进展：[下一代可扩展备份与恢复](https://gitlab.com/groups/gitlab-org/-/epics/11577)。

欢迎在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/457155)中提供对此工具的反馈。

## 进行备份

<a id="taking-a-backup"></a>

要备份当前的极狐GitLab 实例：

```shell
sudo gitlab-backup-cli backup all
```

### 备份对象存储

<a id="backing-up-object-storage"></a>

当前仅支持 Google Cloud。关于增加更多供应商的计划，请参见[史诗 11577](https://gitlab.com/groups/gitlab-org/-/epics/11577)。

#### GCP

`gitlab-backup-cli` 会创建并运行任务，通过 Google Cloud [Storage Transfer Service](https://cloud.google.com/storage-transfer-service/) 将极狐GitLab 数据复制到单独的备份存储桶中。

前提条件：

- 查看[服务账号概述](https://cloud.google.com/iam/docs/service-account-overview)以使用服务账号进行身份验证。
- 本文档假定你正在设置并使用专门用于管理备份的 Google Cloud 服务账号。
- 如果未提供其他凭证，并且你在 Google Cloud 内部运行，则该工具会尝试使用其运行所在基础设施的访问权限。出于[安全考虑](#security-considerations)，你应该使用单独凭证运行该工具，并限制应用程序对已创建备份的访问。

创建备份：

1. [创建角色](https://cloud.google.com/iam/docs/creating-custom-roles)：
   1. 创建一个包含以下定义的文件 `role.yaml`：

   ```yaml
   ---
   description: Role for backing up GitLab object storage
   includedPermissions:
      - storagetransfer.jobs.create
      - storagetransfer.jobs.get
      - storagetransfer.jobs.run
      - storagetransfer.jobs.update
      - storagetransfer.operations.get
      - storagetransfer.projects.getServiceAccount
   stage: GA
   title: GitLab Backup Role
   ```

   1. 应用该角色：

      ```shell
      gcloud iam roles create --project=<YOUR_PROJECT_ID> <ROLE_NAME> --file=role.yaml
      ```

1. 为备份创建服务账号，并将其添加到角色中：

   ```shell
   gcloud iam service-accounts create "gitlab-backup-cli" --display-name="GitLab Backup Service Account"
   # 从以下命令的输出中获取服务账号电子邮件地址
   gcloud iam service-accounts list
   # 将该账号添加到先前创建的角色中
   gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> --member="serviceAccount:<SERVICE_ACCOUNT_EMAIL>" --role="roles/<ROLE_NAME>"
   ```

1. 要使用服务账号进行身份验证，请参见[服务账号凭证](https://cloud.google.com/iam/docs/service-account-overview#credentials)。凭证可以保存到文件，或存储在预定义的环境变量中。
1. 在 [Google Cloud Storage](https://cloud.google.com/storage/) 中创建一个用于备份的目标存储桶。此处的选项很大程度上取决于你的需求。
1. 运行备份：

   ```shell
   sudo gitlab-backup-cli backup all --backup-bucket=<BUCKET_NAME>
   ```

   如果你想备份容器镜像仓库存储桶，请添加选项 `--registry-bucket=<REGISTRY_BUCKET_NAME>`。
1. 备份会在存储桶中为每种对象存储类型在 `backups/<BACKUP_ID>/<BUCKET>` 下创建一个备份。

## 备份目录结构

<a id="backup-directory-structure"></a>

示例备份目录结构：

```plaintext
backups
└── 1714053314_2024_04_25_17.0.0-pre
    ├── artifacts.tar.gz
    ├── backup_information.json
    ├── builds.tar.gz
    ├── ci_secure_files.tar.gz
    ├── db
    │   ├── ci_database.sql.gz
    │   └── database.sql.gz
    ├── lfs.tar.gz
    ├── packages.tar.gz
    ├── pages.tar.gz
    ├── registry.tar.gz
    ├── repositories
    │   ├── default
    │   │   ├── @hashed
    │   │   └── @snippets
    │   └── manifests
    │       └── default
    ├── terraform_state.tar.gz
    └── uploads.tar.gz
```

`db` 目录用于备份极狐GitLab PostgreSQL 数据库，通过 `pg_dump` 创建[SQL 转储文件](https://www.postgresql.org/docs/16/backup-dump.html)。`pg_dump` 的输出通过管道传输到 `gzip`，以创建压缩的 SQL 文件。

`repositories` 目录用于备份极狐GitLab 数据库中的 Git 仓库。

## 备份 ID

<a id="backup-id"></a>

备份 ID 用于标识各个备份。如果你需要恢复极狐GitLab 且有多个备份可用，则需要备份存档的备份 ID。

备份保存在 `backup_path` 指定的目录中，该路径在 `config/gitlab.yml` 文件中指定。

- 默认情况下，备份存储在 `/var/opt/gitlab/backups`。
- 默认情况下，备份目录以 `backup_id` 命名，其中 `<backup-id>` 标识备份创建的时间和极狐GitLab 版本。

例如，如果备份目录名称为 `1714053314_2024_04_25_17.0.0-pre`，则创建时间由 `1714053314_2024_04_25` 表示，极狐GitLab 版本为 17.0.0-pre。

## 备份元数据文件 (`backup_information.json`)

<a id="backup-metadata-file-backup_informationjson"></a>

{{< history >}}

- 元数据版本 2 在 [极狐GitLab 16.11](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/149441) 中引入。

{{< /history >}}

`backup_information.json` 位于备份目录中，它存储有关备份的元数据。例如：

```json
{
  "metadata_version": 2,
  "backup_id": "1714053314_2024_04_25_17.0.0-pre",
  "created_at": "2024-04-25T13:55:14Z",
  "gitlab_version": "17.0.0-pre"
}
```

## 恢复备份

<a id="restore-a-backup"></a>

{{< history >}}

- 在极狐GitLab 17.6 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/469247)。

{{< /history >}}

前提条件：

- 你拥有使用 `gitlab-backup-cli` 创建的备份的备份 ID。

要恢复当前极狐GitLab 实例的备份：

- 运行以下命令：

  ```shell
  sudo gitlab-backup-cli restore all <backup_id>
  ```

### 恢复对象存储数据

<a id="restore-object-storage-data"></a>

你可以从 Google Cloud Storage 恢复数据。[史诗 11577](https://gitlab.com/groups/gitlab-org/-/epics/11577) 提议增加对其它供应商的支持。

前提条件：

- 你拥有使用 `gitlab-backup-cli` 创建的备份的备份 ID。
- 你为恢复位置配置了所需权限。
- 你设置了对象存储配置 `gitlab.rb` 或 `gitlab.yml` 文件，并且与备份环境匹配。
- 你在 staging 环境中测试了恢复过程。

要恢复对象存储数据：

- 运行以下命令：

  ```shell
  sudo gitlab-backup restore <backup_id>
  ```

恢复过程：

- 不会先清空目标存储桶。
- 会覆盖目标存储桶中具有相同文件名的现有文件。
- 可能需要相当长的时间，具体取决于恢复的数据量。

在恢复期间始终监控你的系统资源。在验证恢复成功之前，请保留你的原始文件。

## 已知问题

<a id="known-issues"></a>

使用 `gitlab-backup-cli` 时，你可能会遇到以下问题。

### 架构兼容性

<a id="architecture-compatibility"></a>

如果你在 [1K 架构](../reference_architectures/1k_users.md)以外的架构上使用 `gitlab-backup-cli` 工具，你可能会遇到问题。此工具仅在 1K 架构上受支持，并且仅推荐用于相关环境。

### 备份策略

<a id="backup-strategy"></a>

备份期间对现有文件的更改可能会导致极狐GitLab 实例出现问题。出现此问题是因为该工具的初始版本不使用[复制策略](backup_gitlab.md#backup-strategy-option)。

此问题的解决方法是：

- 将极狐GitLab 实例转换为[维护模式](../maintenance_mode/_index.md)。
- 在备份期间限制服务器的流量以保留实例资源。

我们正在研究复制策略的替代方案，请参见[议题 428520](https://gitlab.com/gitlab-org/gitlab/-/issues/428520)。

## 备份哪些数据？

<a id="what-data-is-backed-up"></a>

1. Git 仓库数据
1. 数据库
1. Blobs

## 不备份哪些数据？

<a id="what-data-is-not-backed-up"></a>

1. 密钥和配置

   - 按照有关如何[备份密钥和配置](backup_gitlab.md#storing-configuration-files)的文档进行操作。

1. 瞬时和缓存数据

   - Redis：缓存
   - Redis：Sidekiq 数据
   - 日志
   - Elasticsearch
   - 可观测性数据 / Prometheus 指标

## 安全注意事项

<a id="security-considerations"></a>

你应该创建一个单独的用户账号，仅具有执行备份所需的权限，而不是使用相同的凭证。使用与应用程序相同的凭证运行备份是一种不良的安全实践，原因如下：

- 最小权限原则 - 备份过程需要比正常应用程序操作更广泛的权限（例如对所有数据的读取权限）。用户或进程应仅具有执行其功能所需的最低访问权限。
- 泄露风险 - 如果应用程序凭证被泄露，攻击者可以访问应用程序及其所有备份数据，从而也暴露历史数据。
- 职责分离 - 对备份和应用程序使用单独的凭证有助于保持职责分离。这种分离使得单个被泄露的账号更难造成广泛的损害。
- 审计追踪 - 单独的备份凭证可以更轻松地独立于常规应用程序操作来跟踪和审计备份活动。
- 精细的访问控制 - 不同的凭证允许更精细的访问控制。备份凭证可以被授予对数据的只读访问权限，而应用程序凭证可能需要特定表或模式的读写访问权限。
- 合规要求 - 许多法规标准和合规框架（如 GDPR、HIPAA 或 PCI-DSS）要求或强烈建议职责分离和访问控制，而这通过使用单独凭证更容易实现。
- 更轻松的生命周期管理 - 应用程序和备份进程可能具有不同的生命周期。使用单独的凭证使得独立管理这些生命周期更加容易。例如，你可以轮换或撤销凭证而不影响另一个进程。
- 防范应用程序漏洞 - 如果应用程序存在允许 SQL 注入或其他形式未经授权数据访问的漏洞，使用单独的备份凭证可以为备份过程增加额外的保护层。