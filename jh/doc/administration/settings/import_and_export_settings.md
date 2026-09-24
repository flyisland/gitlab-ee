---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 导入和导出设置
description: "在您的极狐GitLab 私有化部署实例上配置导入源、导出限制、文件大小、用户映射和占位用户的设置。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

与导入和导出功能相关的设置。

<a id="configure-allowed-import-sources"></a>

## 配置允许的导入源

在您从其他系统导入项目之前，必须为该系统启用[导入源](../../user/jihulab_com/_index.md#default-import-sources)。

1. 以具有管理员访问级别的用户身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置** 部分。
1. 选中要允许的每个 **导入源**。
1. 选择 **保存更改**。

<a id="disable-unused-import-sources"></a>

## 禁用未使用的导入源

只从您信任的来源导入项目。如果您从不信任的来源导入项目，攻击者可能会窃取您的敏感数据。例如，带有恶意 `.gitlab-ci.yml` 文件的导入项目可能允许攻击者窃取群组 CI/CD 变量。

极狐GitLab 私有化部署管理员可以通过禁用不需要的导入源来减少攻击面：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 滚动到 **导入源**。
1. 清除不需要的导入器的复选框。

<a id="enable-project-export"></a>

## 启用项目导出

要启用[项目及其数据](../../user/project/settings/import_export.md#export-a-project-and-its-data)的导出：

1. 以具有管理员访问级别的用户身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置** 部分。
1. 滚动到 **项目导出**。
1. 选中 **已启用** 复选框。
1. 选择 **保存更改**。

<a id="enable-migration-of-groups-and-projects-by-direct-transfer"></a>

## 启用通过直接转移迁移群组和项目

默认情况下，通过直接转移迁移群组和项目处于禁用状态。要启用通过直接转移迁移群组和项目：

1. 以具有管理员访问级别的用户身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置** 部分。
1. 滚动到 **允许通过直接转移迁移极狐GitLab 群组和项目**。
1. 选中 **已启用** 复选框。
1. 选择 **保存更改**。

相同的设置
[在 API 中可用](../../api/settings.md#available-settings)，作为
`bulk_import_enabled` 属性。

<a id="enable-export-of-groups-and-projects-for-offline-transfer"></a>

## 启用群组和项目的离线传输导出

> [!flag]
> 此功能的可用性由功能标志控制。

先决条件：

- 您必须是管理员。

开启此设置以允许用户创建群组和项目的[离线传输](../../user/import/gitlab_instances/offline-transfer-migrations.md)导出。

要启用群组和项目的离线传输导出：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置** 部分。
1. 滚动到 **允许通过离线传输导出极狐GitLab 群组和项目**。
1. 选中 **已启用** 复选框。
1. 选择 **保存更改**。

相同的设置
[在 API 中可用](../../api/settings.md#available-settings)，作为
`offline_transfer_exports_enabled` 属性。

<a id="enable-import-of-groups-and-projects-by-offline-transfer"></a>

## 启用群组和项目的离线传输导入

> [!flag]
> 此功能的可用性由功能标志控制。

先决条件：

- 您必须是管理员。

开启此设置以允许用户从[离线传输](../../user/import/gitlab_instances/offline-transfer-migrations.md)导出中导入群组和项目。

要启用群组和项目的离线传输导入：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置** 部分。
1. 滚动到 **允许通过离线传输导入极狐GitLab 群组和项目**。
1. 选中 **已启用** 复选框。
1. 选择 **保存更改**。

相同的设置
[在 API 中可用](../../api/settings.md#available-settings)，作为
`offline_transfer_imports_enabled` 属性。

<a id="allow-s3-compatible-object-storage-for-offline-transfer"></a>

## 允许离线传输使用兼容 S3 的对象存储

> [!flag]
> 此功能的可用性由功能标志控制。

先决条件：

- 您必须是管理员。

默认情况下，[离线传输](../../user/import/gitlab_instances/offline-transfer-migrations.md)仅支持 AWS S3 和 Google Cloud Storage。开启此设置以同时允许兼容 S3 的提供商，例如 MinIO。

> [!warning]
> 当您启用此设置时，能够执行离线传输的用户可以在离线传输对象存储配置中提供任意的
> `endpoint` URL。极狐GitLab 随后会向该端点发送请求。仅当您信任能够执行离线传输的用户时，才启用此设置。

要允许离线传输使用兼容 S3 的对象存储：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置** 部分。
1. 滚动到 **允许离线传输使用兼容 S3 的对象存储**。
1. 选中 **已启用** 复选框。
1. 选择 **保存更改**。

<a id="allow-application-default-credentials-for-offline-transfer"></a>

## 允许离线传输使用应用程序默认凭据

> [!flag]
> 此功能的可用性由功能标志控制。

开启此设置以允许[离线传输](../../user/import/gitlab_instances/offline-transfer-migrations.md)通过使用[应用程序默认凭据](../object_storage.md#google-cloud-application-default-credentials)（ADC）与 Google Cloud Storage 进行身份验证。

对于所有其他对象存储提供商，创建导出或导入的用户需提供凭据。使用 ADC 时，无需用户提供凭据。极狐GitLab 仅存储 Google Cloud 项目 ID，并根据实例环境为每个请求解析凭据，这些凭据来自 Compute Engine 元数据服务器或 `GOOGLE_APPLICATION_CREDENTIALS` 环境变量。

先决条件：

- 您必须是管理员。

> [!warning]
> 使用 ADC 的离线传输将拥有实例服务账号所持有的所有 Cloud Storage 权限。该服务账号通常比任何单个用户拥有更多权限，因此创建 ADC 传输的用户可以访问他们没有凭据的存储桶。

为限制此风险，极狐GitLab 应用以下无法关闭的限制：

- 只有具有管理员访问权限的用户才能创建使用 ADC 的离线传输导出或导入。其他用户会收到错误
  `Only administrators can use Application Default Credentials for offline transfer.`
- 存储桶名称必须以 `gitlab-offline-transfer-` 开头。此前缀使 ADC 传输远离实例用于自身对象存储的存储桶，例如上传、作业产物和 LFS 对象。
- ADC 在 JihuLab.com 上不可用。

您为传输提供的 Google Cloud 项目 ID 不限制该传输可以访问的存储桶。存储桶名称在 Cloud Storage 中是全局唯一的，因此 ADC 传输可以使用服务账号能够访问且名称以 `gitlab-offline-transfer-` 开头的任何存储桶，无论其位于哪个 Google Cloud 项目中。

当用户创建传输时，极狐GitLab 会检查这些限制。如果您关闭此设置，用户将无法再创建 ADC 传输，但已开始的传输将继续运行。

要允许离线传输使用应用程序默认凭据：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置** 部分。
1. 滚动到 **允许离线传输使用 Google Cloud 应用程序默认凭据**。
1. 选中 **已启用** 复选框。
1. 选择 **保存更改**。

相同的设置
[在 API 中可用](../../api/settings.md#available-settings)，作为
`allow_application_default_credentials_for_offline_transfer` 属性。

<a id="enable-silent-admin-exports"></a>

## 启用管理员静默导出

启用管理员静默导出，以防止实例管理员触发[项目或群组文件导出](../../user/project/settings/import_export.md)或下载导出文件时生成[审计事件](../compliance/audit_event_reports.md)。非管理员的导出仍会生成审计事件。

要启用管理员静默项目与群组文件导出：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**，然后展开 **导入和导出设置**。
1. 滚动到 **管理员静默导出**。
1. 选中 **已启用** 复选框。

<a id="allow-contribution-mapping-to-administrators"></a>

## 允许将贡献映射到管理员

要允许将导入的用户贡献映射到管理员：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**，然后展开 **导入和导出设置**。
1. 滚动到 **允许将贡献映射到管理员**。
1. 选中 **已启用** 复选框。

<a id="skip-confirmation-when-administrators-reassign-placeholder-users"></a>

## 管理员重新分配占位用户时跳过确认

先决条件：

- 确保极狐GitLab 实例上[未禁用用户模拟](../../api/rest/authentication.md#disable-impersonation)。

要在管理员重新分配占位用户时跳过确认：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 在 **管理员重新分配占位用户时跳过确认** 下，选中 **已启用** 复选框。

启用此设置后，管理员可以将贡献和成员资格重新分配给具有以下任一状态的非机器人用户：

- `active`
- `banned`
- `blocked`
- `blocked_pending_approval`
- `deactivated`
- `ldap_blocked`

<a id="max-export-size"></a>

## 最大导出大小

要修改极狐GitLab 中导出的最大文件大小：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**，然后展开 **导入和导出设置**。
1. 通过更改 **最大导出大小 (MiB)** 中的值来增大或减小。

<a id="max-import-size"></a>

## 最大导入大小

要修改极狐GitLab 中导入的最大文件大小：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 通过更改 **最大导入大小 (MiB)** 中的值来增大或减小。

此设置仅适用于[从极狐GitLab 导出文件导入的代码仓库](../../user/project/settings/import_export.md#import-a-project-and-its-data)。

此设置仅控制极狐GitLab 自身强制执行的限制。极狐GitLab 前面的任何 HTTP 代理或负载均衡器都会强制执行其自身的独立请求大小限制，您必须单独配置。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

调整内置 NGINX 的 `client_max_body_size` 设置。

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

调整 Ingress 控制器或 Gateway API 配置，具体取决于您的部署使用哪一个。

{{< /tab >}}

{{< /tabs >}}

有关 JihuLab.com 的代码仓库大小限制，请阅读[账户和限制设置](../../user/jihulab_com/_index.md#account-and-limit-settings)。

<a id="maximum-remote-file-size-for-imports"></a>

## 导入的远程文件大小上限

默认情况下，从外部对象存储（例如 AWS）导入的远程文件大小上限为 10 GiB。

要修改此设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 在 **最大导入远程文件大小 (MiB)** 中，输入一个值。设置为 `0` 表示不限制文件大小。

<a id="maximum-download-file-size-for-imports-by-direct-transfer"></a>

## 通过直接转移导入的最大下载文件大小

默认情况下，通过直接转移导入的最大下载文件大小为 5 GiB。

要修改此设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 在 **最大下载文件大小 (MiB)** 中，输入一个值。设置为 `0` 表示不限制文件大小。

<a id="maximum-decompressed-file-size-for-imported-archives"></a>

## 导入归档的最大解压后文件大小

当您使用[文件导出](../../user/project/settings/import_export.md)或[直接转移](../../user/group/import/_index.md)导入项目时，您可以指定导入归档的最大解压后文件大小。默认值为 25 GiB。

当您导入压缩文件时，解压后的大小不能超过最大解压后文件大小限制。如果解压后的大小超过配置的限制，将返回以下错误：

```plaintext
Decompressed archive size validation failed.
```

要修改此设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 为 **导入归档的最大解压后文件大小 (MiB)** 设置另一个值。

<a id="timeout-for-decompressing-archived-files"></a>

## 解压归档文件的超时时间

当您[导入项目](../../user/project/settings/import_export.md)时，您可以指定解压导入归档的最大超时时间。默认值为 210 秒。

要修改极狐GitLab 中导入的最大解压后文件大小：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 为 **解压归档文件的超时时间（秒）** 设置另一个值。

<a id="maximum-number-of-concurrent-import-jobs-across-the-instance"></a>

## 实例范围内并发导入作业的最大数量

每个导入作业在其整个持续时间内占用一个 Sidekiq 线程。编排导入的工作进程（基于文件的项目和群组导入、直接转移，以及 GitHub、Bitbucket Cloud 和 Bitbucket Server 导入器的阶段作业）可能运行很长时间，因此如果同时运行过多，它们可能会占用整个 Sidekiq 线程池并阻塞其他后台工作。

`import_jobs_concurrency_limit` 设置限制了这些长时间运行的作业可以同时运行的数量。该限制独立应用于每种工作进程类型，而不是作为单个共享总数。超出某工作进程类型限制的作业将等待，直到该类型的正在运行的作业完成。

默认值为每种工作进程类型 `100` 个并发作业。要更改它，请向 `/api/v4/application/settings` 发送 API 请求，并携带 `import_jobs_concurrency_limit`。有关更多信息，请参阅[应用程序设置 API](../../api/settings.md)。

<a id="maximum-number-of-simultaneous-import-jobs"></a>

## 同时导入作业的最大数量

在单个项目导入中，您可以限制导入器同时调度的子作业（例如，每个议题或拉取请求一个作业）的数量。使用此设置来控制单个导入同时调度的作业数量。它适用于：

- [GitHub 导入器](../../user/project/import/github.md)
- [Bitbucket Cloud 导入器](../../user/import/bitbucket_cloud.md)
- [Bitbucket Server 导入器](../../user/import/bitbucket_server.md)

这与 [`import_jobs_concurrency_limit`](#maximum-number-of-concurrent-import-jobs-across-the-instance) 不同：该设置限制整个实例中长时间运行的编排和阶段工作进程，但独立于每种工作进程类型，而此设置限制单个导入中的短期子作业。由于子作业完成得很快，它们的默认值要高得多。

导入合并请求时不应用作业限制，因为合并请求的硬编码限制已经避免了服务器过载。

默认作业限制为：

- GitHub 导入器：1000。
- Bitbucket Cloud 和 Bitbucket Server 导入器：100。Bitbucket 导入器的默认值较低，因为尚未确定一个好的默认值。实例管理员应尝试使用更高的限制。

要修改此设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **导入和导出设置**。
1. 为所需的导入器设置 **同时导入作业的最大数量** 的另一个值。

<a id="maximum-number-of-simultaneous-batch-export-jobs"></a>

## 同时批量导出作业的最大数量

直接转移导出会消耗大量资源。为防止耗尽数据库或 Sidekiq 进程，管理员可以配置 `concurrent_relation_batch_export_limit` 设置。

默认值为 `8` 个作业，这对应于[最多 40 RPS 或 2,000 用户的参考架构](../reference_architectures/2k_users.md)。如果您遇到 `PG::QueryCanceled: ERROR: canceling statement due to statement timeout` 错误或因 Sidekiq 内存限制导致作业中断，您可能需要减少此数字。如果您有足够的资源，可以增加此数字以处理更多并发导出作业。

要修改此设置，请向 `/api/v4/application/settings` 发送 API 请求，并携带 `concurrent_relation_batch_export_limit`。有关更多信息，请参阅[应用程序设置 API](../../api/settings.md)。

<a id="concurrent-project-file-exports"></a>

### 并发项目文件导出

项目文件导出在内存和磁盘空间有限的 Sidekiq 节点上运行，因此过多的并发导出可能会使这些节点饱和，并延迟实例上的所有导出。为限制同时运行的项目文件导出数量，管理员可以配置 `concurrent_relation_export_limit` 设置。

默认值为 `25` 个导出。在达到限制时请求的导出将保持排队状态，并随着正在运行的导出完成，按请求顺序开始。

要修改此设置，请向 `/api/v4/application/settings` 发送 API 请求，并携带 `concurrent_relation_export_limit`。有关更多信息，请参阅[应用程序设置 API](../../api/settings.md)。

<a id="export-batch-size"></a>

### 导出批次大小

为进一步管理内存使用和数据库负载，请使用 `relation_export_batch_size` 设置来控制导出操作期间每批处理的记录数。

默认值为每批 `50` 条记录。要修改此设置，请向 `/api/v4/application/settings` 发送 API 请求，并携带 `relation_export_batch_size`。有关更多信息，请参阅[应用程序设置 API](../../api/settings.md)。

<a id="error-help-page-documentation-base-url-is-blocked-execution-expired"></a>

## 错误：`Help page documentation base url is blocked: execution expired`

在启用[导入源](#configure-allowed-import-sources)等应用程序设置时，您可能会收到 `Help page documentation base url is blocked: execution expired` 错误。要解决此错误：

1. 将 `docs.gitlab.com` 或[重定向的帮助文档页面 URL](help_page.md#redirect-help-pages) 添加到[允许列表](../../security/webhooks.md#allow-outbound-requests-to-certain-ip-addresses-and-domains)中。
1. 选择 **保存更改**。
