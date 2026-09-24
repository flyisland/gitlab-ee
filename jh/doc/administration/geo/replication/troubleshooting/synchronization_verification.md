---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Geo 同步和验证错误
description: "对 Geo 同步和验证失败进行故障排除，涵盖手动重试流程、批量操作、错误诊断和数据一致性恢复。"
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您在 `Admin > Geo > Sites` 或 [同步状态 Rake 任务](common.md#sync-status-rake-task) 中注意到复制或验证失败，您可以尝试通过以下一般步骤解决这些失败：

1. Geo 会自动重试失败的操作。如果失败是新出现的且数量较少，或者您怀疑根本原因已解决，那么您可以等待，看看失败是否消失。
1. 如果失败已存在较长时间，则已经发生了多次重试，自动重试的间隔已增加到最长 4 小时（具体取决于失败类型）。如果您怀疑根本原因已解决，可以[手动重试复制或验证](#manually-retry-replication-or-verification)以避免等待。
1. 如果失败仍然存在，请使用以下各节尝试解决。

<a id="diagnostic-procedures"></a>

## 诊断流程

在尝试手动重试之前，您可以使用以下增强的诊断流程来更好地了解同步问题的范围和性质。

<a id="model-status-check"></a>

### 模型状态检查

此流程为所有 [Geo 数据类型模型类](#geo-data-type-model-classes) 提供详细的状态信息，并有助于识别校验和失败。当可复制对象的校验和无法计算时，就会发生这些失败。它们有时也被称为“主站点验证失败”。

您可以通过 UI 或 Rails 控制台查看校验和失败。

{{< tabs >}}

{{< tab title="UI" >}}

在主站点上，使用[数据管理页面](../../../admin_area.md#data-management)。

{{< /tab >}}

{{< tab title="Rails 控制台" >}}

您可以使用以下脚本为每种模型类型输出详细信息，包括：

- 记录总数
- 失败、已验证和待处理记录的数量
- 用于调查的失败记录样本

> [!note]
> `ModelMapper` 类是在 [极狐GitLab 18.3](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/196293) 中新增的。
> 对于旧版本，您需要手动指定 [Geo 数据类型模型类](#geo-data-type-model-classes) 的列表。

1. 在主站点上，[启动 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下脚本以获取全面概览：

   ```ruby
   def output_geo_verification_failures
     model_classes = ::Gitlab::Geo::ModelMapper.available_models

     model_classes.each do |klass|
       total = klass.count
       state_klass = klass.verification_state_table_class
       failed_examples = []

       puts "\n=== #{klass.name} ==="
       puts "Total: #{total}"
       ::Geo::VerificationState::VERIFICATION_STATE_VALUES.each do |key, value|
         records = state_klass.where(verification_state: value)
         failed_examples = records if key == 'verification_failed'

         puts "#{key.gsub('verification_', '').camelize}: #{records.size}"
       end

       if failed_examples.any?
         puts "\nSample failed records:"
         failed_examples.limit(3).each { |record| puts "  ID: #{record.id}, Checksum: #{record.verification_checksum || 'nil'}, Error: #{record.verification_failure}" }
       end
     end

     nil
   end

   output_geo_verification_failures
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="registry-status-check"></a>

### 注册表状态检查

此流程为所有 Geo 注册表类型提供详细的状态信息，并有助于识别失败模式。

1. 在从站点上[启动 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下脚本以获取全面概览：

   ```ruby
   def output_geo_failures()
     registry_classes = [
       Geo::UploadRegistry,
       Geo::JobArtifactRegistry,
       Geo::PackageFileRegistry,
       Geo::PagesDeploymentRegistry,
       Geo::ProjectRepositoryRegistry,
       Geo::TerraformStateVersionRegistry,
       Geo::MergeRequestDiffRegistry,
       Geo::LfsObjectRegistry,
       Geo::PipelineArtifactRegistry,
       Geo::CiSecureFileRegistry,
       Geo::ContainerRepositoryRegistry
     ]

     registry_classes.each do |klass|
       puts "\n=== #{klass.name} ==="
       puts "Total: #{klass.count}"
       puts "Failed: #{klass.failed.count}"
       puts "Synced: #{klass.synced.count}"
       puts "Pending: #{klass.pending.count}"
       puts "Started: #{klass.with_state(:started).count}"

       if klass.failed.count > 0
          puts "\nSample failed records:"
          klass.failed.limit(3).each { |record| puts "  ID: #{record.id}, Error: #{record.last_sync_failure}" }
       end
     end

     nil
   end

   output_geo_failures()
   ```

1. 此脚本为每种注册表类型输出详细信息，包括：
   - 记录总数
   - 失败、已同步和待处理记录的数量
   - 用于调查的失败记录样本

<a id="manually-retry-replication-or-verification"></a>

## 手动重试复制或验证

在从 Geo 站点的 [Rails 控制台](../../../operations/rails_console.md#starting-a-rails-console-session) 中，您可以：

- [手动重新同步和重新验证单个组件](#resync-and-reverify-individual-components)
- [手动重新同步和重新验证多个组件](#resync-and-reverify-multiple-components)

<a id="resync-and-reverify-individual-components"></a>

### 重新同步和重新验证单个组件

在从站点上，访问 **管理员** > **Geo** > **复制** 以强制重新同步或重新验证单个条目。

但是，如果这不起作用，您可以使用 Rails 控制台执行相同的操作。以下各节介绍如何在 [Rails 控制台](../../../operations/rails_console.md#starting-a-rails-console-session) 中使用内部应用程序命令，以同步或异步方式对单个记录执行复制或验证。

<a id="obtaining-a-replicator-instance"></a>

#### 获取 Replicator 实例

> [!warning]
> 更改数据的命令如果未正确运行或未在正确条件下运行，可能会造成损害。
> 始终先在测试环境中运行命令，并准备好备份实例以供恢复。

在执行任何同步或验证操作之前，您需要获取一个 Replicator 实例。

首先，根据您要执行的操作，在主站点或从站点[启动 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。

主站点：

- 您可以为资源计算校验和

从站点：

- 您可以同步资源
- 您可以为资源计算校验和，并将该校验和与主站点的校验和进行验证

接下来，运行以下代码片段之一以获取 Replicator 实例。

<a id="given-a-model-records-id"></a>

##### 给定模型记录的 ID

- 将 `123` 替换为实际 ID。
- 将 `Packages::PackageFile` 替换为任何 [Geo 数据类型模型类](#geo-data-type-model-classes)。

```ruby
model_record = Packages::PackageFile.find_by(id: 123)
replicator = model_record.replicator
```

<a id="given-a-registry-records-id"></a>

##### 给定注册表记录的 ID

- 将 `432` 替换为实际 ID。注册表记录的 ID 值可能与它跟踪的模型记录的 ID 值相同，也可能不同。
- 将 `Geo::PackageFileRegistry` 替换为任何 [Geo 注册表类](#geo-registry-classes)。

在从 Geo 站点中：

```ruby
registry_record = Geo::PackageFileRegistry.find_by(id: 432)
replicator = registry_record.replicator
```

<a id="given-an-error-message-in-a-registry-records-last_sync_failure"></a>

##### 给定注册表记录的 `last_sync_failure` 中的错误消息

- 将 `Geo::PackageFileRegistry` 替换为任何 [Geo 注册表类](#geo-registry-classes)。
- 将 `error message here` 替换为实际错误消息。

```ruby
registry = Geo::PackageFileRegistry.find_by("last_sync_failure LIKE '%error message here%'")
replicator = registry.replicator
```

<a id="given-an-error-message-in-a-registry-records-verification_failure"></a>

##### 给定注册表记录的 `verification_failure` 中的错误消息

- 将 `Geo::PackageFileRegistry` 替换为任何 [Geo 注册表类](#geo-registry-classes)。
- 将 `error message here` 替换为实际错误消息。

```ruby
registry = Geo::PackageFileRegistry.find_by("verification_failure LIKE '%error message here%'")
replicator = registry.replicator
```

<a id="performing-operations-with-a-replicator-instance"></a>

#### 使用 Replicator 实例执行操作

在您将 Replicator 实例存储在 `replicator` 变量中之后，您可以执行许多操作：

<a id="sync-in-the-console"></a>

##### 在控制台中同步

此代码片段仅在从站点中有效。

这会在控制台中同步执行同步代码，因此您可以观察同步资源需要多长时间，或查看完整的错误回溯。

```ruby
replicator.sync
```

（可选）将控制台的日志级别设置为比配置的日志级别更详细，然后执行同步：

```ruby
Rails.logger.level = :debug
```

<a id="checksum-or-verify-in-the-console"></a>

##### 在控制台中计算校验和或验证

此代码片段在任何主站点或从站点中均有效。

在主站点中，它会为资源计算校验和，并将结果存储在主极狐GitLab 数据库中。在从站点中，它会为资源计算校验和，将其与主极狐GitLab 数据库中的校验和（由主站点生成）进行比较，并将结果存储在 Geo 跟踪数据库中。

这会在控制台中同步执行校验和与验证代码，因此您可以观察需要多长时间，或查看完整的错误回溯。

```ruby
replicator.verify
```

<a id="sync-in-a-sidekiq-job"></a>

##### 在 Sidekiq 作业中同步

此代码片段仅在从站点中有效。

它会将作业加入队列，供 Sidekiq 执行资源的[同步](#sync-in-the-console)。

```ruby
replicator.enqueue_sync
```

<a id="verify-in-a-sidekiq-job"></a>

##### 在 Sidekiq 作业中验证

此代码片段在任何主站点或从站点中均有效。

它会将作业加入队列，供 Sidekiq 执行资源的[计算校验和或验证](#checksum-or-verify-in-the-console)。

```ruby
replicator.verify_async
```

<a id="get-a-model-record"></a>

##### 获取模型记录

此代码片段在任何主站点或从站点中均有效。

```ruby
replicator.model_record
```

<a id="get-a-registry-record"></a>

##### 获取注册表记录

此代码片段仅在从站点中有效，因为注册表表存储在 Geo 跟踪数据库中。

```ruby
replicator.registry
```

<a id="geo-data-type-model-classes"></a>

#### Geo 数据类型模型类

Geo 数据类型是极狐GitLab 的一个或多个功能存储相关数据所需的一类特定数据，并由 Geo 复制到从站点。

- **Blob 类型**：
  - `Ci::JobArtifact`
  - `Ci::PipelineArtifact`
  - `Ci::SecureFile`
  - `LfsObject`
  - `MergeRequestDiff`
  - `Packages::PackageFile`
  - `PagesDeployment`
  - `Terraform::StateVersion`
  - `Upload`
  - `DependencyProxy::Manifest`
  - `DependencyProxy::Blob`
- **Git 代码仓库类型**：
  - `DesignManagement::Repository`
  - `ProjectRepository`
  - `ProjectWikiRepository`
  - `SnippetRepository`
  - `GroupWikiRepository`
- **其他类型**：
  - `ContainerRepository`

类的主要种类是 Registry、Model 和 Replicator。如果您拥有这些类之一的实例，则可以获取其他类。Registry 和 Model 主要管理 PostgreSQL 数据库状态。Replicator 知道如何复制或验证非 PostgreSQL 数据（文件/Git 代码仓库/容器仓库）。

<a id="geo-registry-classes"></a>

#### Geo 注册表类

在极狐GitLab Geo 的上下文中，**注册表记录** 指的是 Geo 跟踪数据库中的注册表表。每条记录跟踪主极狐GitLab 数据库中的单个可复制对象，例如 LFS 文件或项目 Git 代码仓库。与可查询的 Geo 注册表表对应的 Rails 模型有：

- **Blob 类型**：
  - `Geo::CiSecureFileRegistry`
  - `Geo::DependencyProxyBlobRegistry`
  - `Geo::DependencyProxyManifestRegistry`
  - `Geo::JobArtifactRegistry`
  - `Geo::LfsObjectRegistry`
  - `Geo::MergeRequestDiffRegistry`
  - `Geo::PackageFileRegistry`
  - `Geo::PagesDeploymentRegistry`
  - `Geo::PipelineArtifactRegistry`
  - `Geo::ProjectWikiRepositoryRegistry`
  - `Geo::SnippetRepositoryRegistry`
  - `Geo::TerraformStateVersionRegistry`
  - `Geo::UploadRegistry`
- **Git 代码仓库类型**：
  - `Geo::DesignManagementRepositoryRegistry`
  - `Geo::ProjectRepositoryRegistry`
  - `Geo::ProjectWikiRepositoryRegistry`
  - `Geo::SnippetRepositoryRegistry`
  - `Geo::GroupWikiRepositoryRegistry`
- **其他类型**：
  - `Geo::ContainerRepositoryRegistry`

<a id="resync-and-reverify-multiple-components"></a>

### 重新同步和重新验证多个组件

当组件资源同步或验证失败时，您可以触发批量操作来重新启动复制队列。这些操作会将重试次数和计划时间重置为 0，从而使系统更快地处理失败的资源，而不是等待最多 1 小时。

> [!note]
> 这些操作不会立即处理资源。相反，它们会重新排队处理同步和验证的后台作业。实际的复制工作通过标准的 Geo 复制过程异步进行。

<a id="how-resync-and-reverification-works"></a>

#### 重新同步和重新验证的工作原理

当您触发重新同步或重新验证操作时，系统会将匹配的记录标记为 `pending`。Geo 重新同步和重新验证后台工作进程会获取这些记录，并根据正常的队列优先级进行处理。此机制允许您加快处理失败的资源，而无需立即阻塞操作。

> [!note]
> 无法重新验证未成功同步的记录。只有已同步的记录才能被验证。

您可以从 UI 或 Rails 控制台触发批量操作。

<a id="from-the-ui"></a>

#### 从 UI 触发

您可以从 UI 安排对某个组件的所有资源进行全面重新同步：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在 **复制详情** 下，选择所需的组件。

<a id="resync-resources-for-the-selected-component"></a>

##### 重新同步所选组件的资源

1. 选择 **全部重新同步**：这会重置所选资源的所有记录的状态，无论它们是否已同步。
1. 选择 **重新同步所有失败项**：这会重置所有同步失败的记录。

<a id="reverify-resources-for-the-selected-component"></a>

##### 重新验证所选组件的资源

1. 选择 **全部重新验证**：这会重置所选资源的所有记录的状态，无论它们是否已验证。
1. 选择 **重新验证所有失败项**：这会重置所有验证失败但同步成功的记录。

<a id="reverify-one-component-on-all-sites"></a>

##### 在所有站点上重新验证一个组件

如果主站点的校验和存疑，那么您需要让主站点重新计算校验和。这样就实现了“全面重新验证”，因为每次在主站点上重新计算校验和后，都会生成事件并传播到所有从站点，促使它们重新计算自己的校验和并比较值。任何不匹配都会将注册表标记为 `sync failed`，从而安排同步重试。

您可以通过 UI 重新计算主站点的校验和：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **数据管理**。
1. 在下拉列表中选择所需的组件。
1. 选择 **全部校验和**。

> [!warning]
> **全部重新同步**、**全部重新验证** 和 **全部校验和** 会触发对所有资源的更新，无论它们是否已同步或验证。
> 当实例中存在数千个某种对象类型（例如 CI 作业产物）时，不应执行此操作。

<a id="from-the-rails-console"></a>

#### 从 Rails 控制台触发

> [!warning]
> 更改数据的命令如果未正确运行或未在正确条件下运行，可能会造成损害。
> 始终先在测试环境中运行命令，并准备好备份实例以供恢复。

以下各节介绍如何在 [Rails 控制台](../../../operations/rails_console.md#starting-a-rails-console-session) 中使用内部应用程序命令来执行批量复制或验证。

<a id="sync-all-resources-of-one-component-that-failed-to-sync"></a>

##### 同步某个组件中所有同步失败的资源

以下脚本：

- 遍历所有失败的代码仓库。
- 显示 Geo 同步和验证元数据，包括上次失败的原因。
- 尝试重新同步代码仓库。
- 如果发生失败，报告失败及其原因。
- 可能需要一些时间才能完成。每个代码仓库检查必须完成后才能报告结果。如果您的会话超时，请采取措施让进程继续运行，例如启动 `screen` 会话，或使用 [Rails runner](../../../operations/rails_console.md#using-the-rails-runner) 和 `nohup` 运行它。

在从 Geo 站点上运行此脚本。

```ruby
Geo::ProjectRepositoryRegistry.failed.find_each do |registry|
   begin
     puts "ID: #{registry.id}, Project ID: #{registry.project_id}, Last Sync Failure: '#{registry.last_sync_failure}'"
     registry.replicator.sync
     puts "Sync initiated for registry ID: #{registry.id}"
   rescue => e
     puts "ID: #{registry.id}, Project ID: #{registry.project_id}, Failed: '#{e}'", e.backtrace.join("\n")
   end
end; nil
```

<a id="reverify-all-resources-that-failed-to-checksum-on-the-primary-site"></a>

##### 重新验证主站点上所有计算校验和失败的资源

系统会自动重新验证主站点上所有计算校验和失败的资源，但它使用渐进式退避方案来避免过多的失败量。

（可选）例如，如果您已完成一次尝试性的干预，您可以手动触发更早的重新验证：

1. SSH 登录主站点中的 GitLab Rails 节点。
1. 打开 [Rails 控制台](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 将 `Upload` 替换为任何 [Geo 数据类型模型类](#geo-data-type-model-classes)，将所有资源标记为 `pending verification`：

   ```ruby
   Upload.verification_state_table_class.where(verification_state: 3).each_batch do |relation|
     relation.update_all(verification_state: 0)
   end
   ```

<a id="errors"></a>

## 错误

<a id="message-the-file-is-missing-on-the-geo-primary-site"></a>

### 消息：`The file is missing on the Geo primary site`

同步失败 `The file is missing on the Geo primary site` 在首次设置从 Geo 站点时很常见，这是由主站点上的数据不一致导致的。

操作极狐GitLab 时，系统或人为错误可能导致数据不一致和文件缺失。例如，实例管理员手动删除了本地文件系统上的几个产物。此类更改未正确传播到数据库，从而导致不一致。这些不一致会持续存在并可能引发问题。Geo 从站点可能会继续尝试复制这些文件，因为它们仍被数据库引用，但实际上已不存在。

> [!note]
> 如果最近从本地存储迁移到对象存储，请参阅专门的
> [对象存储故障排除部分](../../../object_storage.md#inconsistencies-after-migrating-to-object-storage)。

<a id="identify-inconsistencies"></a>

#### 识别不一致

当存在文件缺失或不一致时，您可能会在 `geo.log` 中看到如下条目。请注意 `"primary_missing_file" : true` 字段：

```json
{
   "bytes_downloaded" : 0,
   "class" : "Geo::BlobDownloadService",
   "correlation_id" : "01JT69C1ECRBEMZHA60E5SAX8E",
   "download_success" : false,
   "download_time_s" : 0.196,
   "gitlab_host" : "gitlab.example.com",
   "mark_as_synced" : false,
   "message" : "Blob download",
   "model_record_id" : 55,
   "primary_missing_file" : true,
   "reason" : "Not Found",
   "replicable_name" : "upload",
   "severity" : "WARN",
   "status_code" : 404,
   "time" : "2025-05-01T16:02:44.836Z",
   "url" : "http://gitlab.example.com/api/v4/geo/retrieve/upload/55"
}
```

在 **管理员** > **Geo** > **站点** 下查看特定可复制对象的同步状态时，UI 中也会反映相同的错误。在此场景中，某个特定上传文件缺失：

![Geo 上传可复制对象仪表板显示所有失败错误。](img/geo_uploads_file_missing_v17_11.png)

![Geo 上传可复制对象仪表板显示文件缺失错误。](img/geo_uploads_file_missing_details_v17_11.png)

<a id="clean-up-inconsistencies"></a>

#### 清理不一致

> [!warning]
> 在执行任何删除命令之前，请确保手头有最新且可用的备份。

要消除这些错误，首先确定哪些特定资源受到影响。然后，运行相应的 `destroy` 命令，以确保删除操作在所有 Geo 站点及其数据库中传播。基于前面的场景，一个**上传**导致了这些错误，下面以此为例。

1. 将识别出的不一致映射到相应的 [Geo 模型类](#geo-data-type-model-classes) 名称。后续步骤需要用到类名。在此场景中，对于上传，它对应于 `Upload`。
1. 在 **Geo 主站点** 上启动一个 [Rails 控制台](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 基于上一步的 *Geo 模型类*，查询所有因文件缺失而验证失败的资源。调整或移除 `limit(20)` 以显示更多结果。观察列出的资源应与 UI 中显示的失败资源匹配：

   ```ruby
   Upload.verification_failed.where("verification_failure like '%File is not checksummable%'").limit(20)

   => #<Upload:0x00007b362bb6c4e8
    id: 55,
    size: 13346,
    path: "503d99159e2aa8a3ac23602058cfdf58/openbao.png",
    checksum: "db29d233de49b25d2085dcd8610bac787070e721baa8dcedba528a292b6e816b",
    model_id: 1,
    model_type: "Project",
    uploader: "FileUploader",
    created_at: Thu, 01 May 2025 15:54:10.549178000 UTC +00:00,
    store: 1,
    mount_point: nil,
    secret: "[FILTERED]",
    version: 2,
    uploaded_by_user_id: 1,
    organization_id: nil,
    namespace_id: nil,
    project_id: 1,
    verification_checksum: nil>
   ```

1. 可选地，使用受影响资源的 `id` 来确定它们是否仍然需要：

   ```ruby
   Upload.find(55)

   => #<Upload:0x00007b362bb6c4e8
    id: 55,
    size: 13346,
    path: "503d99159e2aa8a3ac23602058cfdf58/openbao.png",
    checksum: "db29d233de49b25d2085dcd8610bac787070e721baa8dcedba528a292b6e816b",
    model_id: 1,
    model_type: "Project",
    uploader: "FileUploader",
    created_at: Thu, 01 May 2025 15:54:10.549178000 UTC +00:00,
    store: 1,
    mount_point: nil,
    secret: "[FILTERED]",
    version: 2,
    uploaded_by_user_id: 1,
    organization_id: nil,
    namespace_id: nil,
    project_id: 1,
    verification_checksum: nil>
   ```

   - 如果您确定受影响的资源需要恢复，则可以探索以下选项（非详尽）来恢复它们：
     - 检查从站点是否有该对象，并手动将其复制到主站点。
     - 查看旧备份，并手动将对象复制回主站点。
     - 抽查一些资源以尝试确定销毁这些记录可能没问题，例如，如果它们都是非常旧的产物，那么它们可能不是关键数据。

1. 使用已识别资源的 `id`，通过使用 `destroy` 单独或批量删除它们。确保使用正确的 *Geo 模型类* 名称。
   - 删除单个资源：

     ```ruby
     Upload.find(55).destroy
     ```

   - 删除所有受影响的资源：

     ```ruby
     def destroy_uploads_not_checksummable
       uploads = Upload.verification_failed.where("verification_failure like '%File is not checksummable%'");1
       puts "Found #{uploads.count} resources that failed verification with 'File is not checksummable'."
       puts "Enter 'y' to continue: "
       prompt = STDIN.gets.chomp
       if prompt != 'y'
         puts "Exiting without action..."
         return
       end

       puts "Destroying all..."
       uploads.destroy_all
     end

     destroy_uploads_not_checksummable
     ```

对所有受影响的资源和 Geo 数据类型重复上述步骤。

<a id="message-error-during-verificationerrorfile-is-not-checksummable"></a>

### 消息：`"Error during verification","error":"File is not checksummable"`

错误 `"Error during verification","error":"File is not checksummable"` 由主站点上的不一致引起。自极狐GitLab 18.9 起，错误消息包含有关原因的更多详细信息：

- `File is not checksummable - file does not exist at: <path>`：文件从存储中缺失。
  显示的路径有助于识别缺失的文件。
  要修复此错误，请按照 [The file is missing on the Geo primary site](#message-the-file-is-missing-on-the-geo-primary-site) 中的说明进行操作。
- `File is not checksummable - <ModelClass> <ID> is excluded from verification`：该记录不再属于复制范围，因此 Geo 无法验证它。
  当主站点从复制范围中移除记录而不删除它时，此行为是预期的。
  例如，极狐GitLab 在存储优化期间将旧的 `MergeRequestDiff` 记录移动到 `without_files` 状态。
  注册表一致性工作进程会随时间自动移除这些注册表条目。

要立即移除受影响的 `MergeRequestDiff` 注册表条目，请在从站点上从 [Rails 控制台](../../../operations/rails_console.md) 运行以下命令：

```ruby
Geo::MergeRequestDiffRegistry.where("verification_failure LIKE '%excluded from verification%'").find_each(&:destroy)
```

<a id="failed-verification-of-uploads-on-the-primary-geo-site"></a>

### 主 Geo 站点上的上传验证失败

如果主 Geo 站点上某些上传的验证失败，且 `verification_checksum = nil` 且 `verification_failure` 包含 ``Error during verification: undefined method `underscore' for NilClass:Class`` 或 ``The model which owns this upload is missing.``，这是由于孤立的上传记录。拥有该上传的父记录（上传的“模型”）不知何故已被删除，但上传记录仍然存在。这通常是由于应用程序中的错误引起的，该错误在实现批量删除“模型”时忘记批量删除其关联的上传记录。因此，这些验证失败并非验证本身失败，而是 Postgres 中错误数据的结果。

您可以在主 Geo 站点上的 `geo.log` 文件中找到这些错误。

要确认模型记录确实缺失，您可以在主 Geo 站点上运行 Rake 任务：

```shell
sudo gitlab-rake gitlab:uploads:check
```

您可以通过从 [Rails 控制台](../../../operations/rails_console.md) 运行以下脚本，在主 Geo 站点上删除这些上传记录以消除这些失败：

```ruby
def delete_orphaned_uploads(dry_run: true)
  if dry_run
    p "This is a dry run. Upload rows will only be printed."
  else
    p "This is NOT A DRY RUN! Upload rows will be deleted from the DB!"
  end

  subquery = Geo::UploadState.where("(verification_failure LIKE 'Error during verification: The model which owns this upload is missing.%' OR verification_failure = 'Error during verification: undefined method `underscore'' for NilClass:Class') AND verification_checksum IS NULL")
  uploads = Upload.where(upload_state: subquery)
  p "Found #{uploads.count} uploads with a model that does not exist"

  uploads_deleted = 0
  begin
    uploads.each do |upload|

      if dry_run
        p upload
      else
        uploads_deleted=uploads_deleted + 1
        p upload.destroy!
      end
    rescue => e
      puts "checking upload #{upload.id} failed with #{e.message}"
    end
  end

  p "#{uploads_deleted} remote objects were destroyed." unless dry_run
end
```

前面的脚本定义了一个名为 `delete_orphaned_uploads` 的方法，您可以像这样调用它来进行试运行：

```ruby
delete_orphaned_uploads(dry_run: true)
```

并实际删除孤立的上传行：

```ruby
delete_orphaned_uploads(dry_run: false)
```

<a id="orphaned-exclusive-lease-keys-blocking-repository-sync"></a>

### 孤立的排他锁键阻止代码仓库同步

当排他锁键孤立时，代码仓库同步可能会被阻止，导致同步操作最多中断 8 小时。

**症状：**

- 代码仓库同步被阻止：受影响代码仓库的复制状态在 `pending` 和 `failed` 状态之间交替。
- `geo.log` 中带有 “Cannot obtain an exclusive lease” 消息的日志行数增加。
- 没有针对受影响代码仓库运行的活跃同步作业。
- 影响单个代码仓库最多 8 小时，直到租约过期。

**诊断：**

1. 通过检查 Geo 管理界面，确认该代码仓库未在积极同步。
1. 检查 `geo.log` 中 “Cannot obtain an exclusive lease” 消息的数量是否增加：

   ```shell
   grep "Cannot obtain an exclusive lease" /var/log/gitlab/geo/geo.log
   ```

1. 验证所有这些日志行都包含一个 `lease_key` 字段，其值为
   `geo_sync_ssf_service:project_repository:<repository id>`，其中 `<repository id>`
   是受影响代码仓库的唯一 ID。
1. 验证 Sidekiq 中没有针对受影响代码仓库运行的活跃同步作业。

**变通方法：**

> [!warning]
> 推荐的方法是等待 8 小时租约过期。仅当立即同步至关重要且您已确认没有同步作业在积极运行时，才应手动释放租约。

要手动释放孤立的租约键：

1. 在从站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 找到受影响代码仓库的项目 ID（将 `<project-path>` 替换为实际项目路径）：

   ```ruby
   project = Project.find_by_full_path('<project-path>')
   project_id = project.id
   ```

1. 在同一会话中，释放孤立的租约：

   ```ruby
   replicator = Geo::ProjectRepositoryRegistry.find_by(project_id: project_id).replicator
   sync_service = Geo::FrameworkRepositorySyncService.new(replicator)
   uuid = Gitlab::ExclusiveLease.get_uuid(sync_service.lease_key)

   if uuid
     Gitlab::ExclusiveLease.cancel(sync_service.lease_key, uuid)
     puts "Lease released for project ID #{project_id}"
   else
     puts "No active lease found for project ID #{project_id}"
   end
   ```

1. 验证租约已释放并触发新的同步：

   ```ruby
   replicator.sync
   ```

> [!note]
> 释放租约后，代码仓库同步将根据正常的 Geo 同步计划重试，或者您可以如上所示手动触发同步。

<a id="error-error-syncing-repository-13fatal-could-not-read-username"></a>

### 错误：`Error syncing repository: 13:fatal: could not read Username`

`last_sync_failure` 错误
`Error syncing repository: 13:fatal: could not read Username for 'https://gitlab.example.com': terminal prompts disabled`
表明在 Geo 克隆或获取请求期间 JWT 认证失败。

首先，检查系统时钟是否已同步。运行 [健康检查 Rake 任务](common.md#health-check-rake-task)，或
手动检查从站点上的所有 Sidekiq 节点和主站点上的所有 Puma 节点上的 `date` 是否相同。

如果系统时钟已同步，则 JWT 令牌可能在其两个单独的 HTTP 请求之间执行 Git fetch 计算时过期。请参阅 [议题 464101](https://gitlab.com/gitlab-org/gitlab/-/issues/464101)，该问题存在于所有极狐GitLab 版本中，直到在极狐GitLab 17.1.0、17.0.5 和 16.11.7 中修复。

要验证您是否遇到此问题：

1. 在 [Rails 控制台](../../../operations/rails_console.md#starting-a-rails-console-session) 中猴子补丁代码，将令牌的有效期从 1 分钟增加到 10 分钟。在从站点上的 Rails 控制台中运行此命令：

   ```ruby
   module Gitlab; module Geo; class BaseRequest
     private
     def geo_auth_token(message)
       signed_data = Gitlab::Geo::SignedData.new(geo_node: requesting_node, validity_period: 10.minutes).sign_and_encode_data(message)

       "#{GITLAB_GEO_AUTH_TOKEN_TYPE} #{signed_data}"
     end
   end;end;end
   ```

1. 在同一 Rails 控制台中，重新同步受影响的项目：

   ```ruby
   Project.find_by_full_path('<mygroup/mysubgroup/myproject>').replicator.resync
   ```

1. 查看同步状态：

   ```ruby
   Project.find_by_full_path('<mygroup/mysubgroup/myproject>').replicator.registry
   ```

1. 如果 `last_sync_failure` 不再包含错误 `fatal: could not read Username`，则您
   受此问题影响。状态现在应为 `2`，这意味着它已同步。如果是这样，您应该升级到
   包含修复的极狐GitLab 版本。您可能还希望点赞或评论
   [议题 466681](https://gitlab.com/gitlab-org/gitlab/-/issues/466681)，该问题本可以降低此问题的严重性。

要变通解决此问题，您必须热修补从站点中的所有 Sidekiq 节点以延长 JWT 过期时间：

1. 编辑 `/opt/gitlab/embedded/service/gitlab-rails/ee/lib/gitlab/geo/signed_data.rb`。
1. 找到 `Gitlab::Geo::SignedData.new(geo_node: requesting_node)` 并添加 `, validity_period: 10.minutes`：

   ```diff
   - Gitlab::Geo::SignedData.new(geo_node: requesting_node)
   + Gitlab::Geo::SignedData.new(geo_node: requesting_node, validity_period: 10.minutes)
   ```

1. 重启 Sidekiq：

   ```shell
   sudo gitlab-ctl restart sidekiq
   ```

1. 除非您升级到包含修复的版本，否则每次极狐GitLab 升级后都必须重复此变通方法。

<a id="error-error-syncing-repository-13creating-repository-cloning-repository-exit-status-128"></a>

### 错误：`Error syncing repository: 13:creating repository: cloning repository: exit status 128`

对于无法成功同步的项目，您可能会看到此错误。

创建代码仓库期间退出代码 128 表示 Git 在克隆时遇到致命错误。这可能是由于代码仓库损坏、网络问题、认证问题、资源限制或项目没有关联的 Git 代码仓库。有关此类失败的具体原因的更多详细信息，请参阅 Gitaly 日志。

当不确定从何处开始时，请通过 [在命令行上手动执行 `git fsck` 命令](../../../repository_checks.md#run-a-check-using-the-command-line) 对主站点上的源代码仓库运行完整性检查。

<a id="exit-status-128-caused-by-http-504-from-a-load-balancer"></a>

#### 由负载均衡器的 HTTP 504 导致的退出状态 128

对于大型代码仓库，从站点上的 Gitaly 日志可能会显示：

```plaintext
error: RPC failed; HTTP 504 curl 22 The requested URL returned error: 504
fatal: expected 'packfile'
```

当主站点前面的负载均衡器或代理在 Git 克隆 packfile 传输期间终止连接时，会发生此错误。这通常发生在 AWS Application Load Balancers (ALB) 上，其默认空闲超时为 60 秒。对于大型代码仓库，如果 Gitaly 在数据传输开始前需要时间准备 packfile，则 ALB 可能会在发送任何数据之前断开连接并触发错误。

要解决此问题：

1. 增加主站点前面的负载均衡器的空闲超时，以适应大型代码仓库克隆。对于 AWS ALB，请在 AWS 管理控制台的负载均衡器属性中更新空闲超时设置。
1. 重置失败的注册表：
   1. 在从站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
   1. 识别并重置受影响的代码仓库：

      ```ruby
      project_ids = Geo::ProjectRepositoryRegistry.failed
                      .where("last_sync_failure LIKE '%exit status 128%'")
                      .pluck(:project_id)

      puts "Found #{project_ids.count} repositories failing with exit status 128"

      # state: 0 sets the registry back to pending so Geo retries the sync
      Geo::ProjectRepositoryRegistry.where(project_id: project_ids).update_all(
        state: 0,
        retry_count: 0,
        retry_at: nil,
        last_sync_failure: nil
      )

      puts "Reset #{project_ids.count} registries to pending"
      ```

1. 等待 Geo 自动重试同步，或
   [手动重试复制](#manually-retry-replication-or-verification)。

<a id="error-gitmodulesurl-disallowed-submodule-url"></a>

### 错误：`gitmodulesUrl: disallowed submodule url`

某些项目代码仓库持续无法同步，并出现错误
`Error syncing repository: 13:creating repository: cloning repository: exit status 128`。但是，
对于某些代码仓库，Gitaly 日志中的具体错误消息不同：`gitmodulesUrl: disallowed submodule url`。
当代码仓库的 `.gitmodules` 文件中包含无效的子模块 URL 时，会发生此失败。

**根本原因：** 此问题由 Git 代码仓库中的**历史提交**引起，这些提交包含 URL 格式错误的 `.gitmodules` 文件。该问题发生在 Geo 尝试将代码仓库从主站点克隆到从站点时运行的 Git 一致性检查（`git fsck`）期间。

问题出在代码仓库的提交历史中。`.gitmodules` 文件中的子模块 URL 包含无效格式，在路径中使用 `:` 而不是 `/`：

- 无效：`https://example.gitlab.com:group/project.git`
- 有效：`https://example.gitlab.com/group/project.git`

**为什么这会破坏 Geo 同步：**

1. **Git 的严格验证**：从极狐GitLab 17.0 和更新的 Git 版本开始，Git 在克隆操作期间执行更严格的 `fsck` 检查
1. **历史数据持久性**：即使当前的 `.gitmodules` 文件是正确的，Git 也会将代码仓库中的所有历史版本存储为“blob”
1. **克隆时失败**：当 Geo 尝试克隆代码仓库时，Git 的 `fsck` 会检查**所有对象**（包括历史对象），并在发现格式错误的 URL 时失败
1. **完全同步失败**：整个克隆操作失败，阻止代码仓库到达从站点

**重要提示：** 编辑当前的 `.gitmodules` 文件并不能解决此问题，因为问题数据存在于代码仓库的 Git 历史中，而不仅仅在文件的当前版本中。

此问题在极狐GitLab 17.0 及更高版本中已知，是更严格的代码仓库一致性检查的结果。此新行为源于 Git 本身的更改，其中添加了此检查。它并非特定于极狐GitLab Geo 或 Gitaly。有关更多信息，请参阅
[议题 468560](https://gitlab.com/gitlab-org/gitlab/-/issues/468560)。

<a id="workaround"></a>

#### 变通方法

1. **备份项目**

   在继续之前，请确保使用 [项目导出选项](../../../../user/project/settings/import_export.md) 事先备份项目。

1. **识别有问题的 blob ID**

   对于每个受影响的项目，使用以下方法之一识别有问题的 blob ID：

   - 使用 `git fsck`：克隆代码仓库，然后运行 `git fsck` 以确认问题：

     ```shell
     git clone https://example.gitlab.com/group/project.git
     cd project
     git fsck
     ```

     输出显示有问题的 blob：

     ```plaintext
     Checking object directories: 100% (256/256), done.
     error in blob <SHA>: gitmodulesUrl: disallowed submodule url: https://example.gitlab.com:group/project.git
     Checking objects: 100% (12/12), done.
     ```

   - 检查 Gitaly 日志。查找包含 `gitmodulesUrl` 的错误消息
     以找到特定的 blob SHA。

1. **移除 blob**

   对于每个受影响的项目，[移除上一步中识别出的有问题的 blob ID](../../../../user/project/repository/repository_size.md#remove-blobs)。

   **重要限制：** 如果这些代码仓库中的任何一个属于 fork 网络，则 blob 移除方法可能不起作用（无法以这种方式移除对象池中包含的 blob）。

1. **如有必要，修复 .gitmodules 中的无效 URL**

   检查每个受影响代码仓库中 `.gitmodules` 文件的状态

   如果 `.gitmodules` 仍包含无效 URL，例如 `https://example.gitlab.com:foo/bar.git` 而不是 `https://example.gitlab.com/foo/bar.git`，则客户需要：

   - 修复 `.gitmodules` 文件中的 URL
   - 推送包含有效 URL 的提交

> [!warning]
> 修复后，所有在受影响项目上工作的开发者必须删除其当前的本地副本
> 并重新克隆代码仓库。否则，他们可能会在推送更改时重新引入有问题的 blob。

<a id="error-fetch-remote-signal-terminated-context-deadline-exceeded-at-exactly-3-hours"></a>

### 错误：`fetch remote: signal: terminated: context deadline exceeded` 恰好发生在 3 小时

如果在同步 Git 代码仓库时，Git fetch 恰好在三个小时后失败：

1. 编辑 `/etc/gitlab/gitlab.rb` 以将 Git 超时从默认的 10800 秒增加：

   ```ruby
   # Git timeout in seconds
   gitlab_rails['gitlab_shell_git_timeout'] = 21600
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="error-failed-to-open-tcp-connection-to-localhost5000-on-secondary-when-configuring-registry-replication"></a>

### 配置注册表复制时从站点上的错误 `Failed to open TCP connection to localhost:5000`

在从站点上配置容器镜像仓库复制时，您可能会遇到以下错误：

```plaintext
Failed to open TCP connection to localhost:5000 (Connection refused - connect(2) for \"localhost\" port 5000)"
```

如果从站点上未启用容器镜像仓库，则会发生此错误。要修复它，请检查容器镜像仓库
是否 [在从站点上启用](../../../packages/container_registry.md#enable-the-container-registry)。如果 [Let's Encrypt 集成已禁用](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually)，则容器镜像仓库也会被禁用，您必须 [手动配置它](../../../packages/container_registry.md#configure-container-registry-under-its-own-domain)。

<a id="error-verification-timed-out-after-28800"></a>

### 错误：`Verification timed out after 28800`

**可能的原因：** 重复的注册表记录导致各种注册表类型的验证冲突。

**诊断：**

1. 在从站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 检查不同类型中的重复注册表：

   ```ruby
   # Check for duplicate upload registries
   upload_ids = Geo::UploadRegistry.group(:file_id).having('COUNT(*) > 1').pluck(:file_id)
   puts "Duplicate upload IDs count: #{upload_ids.size}"
   puts 'Duplicate Upload IDs:', upload_ids

   # Check for duplicate job artifact registries
   artifact_ids = Geo::JobArtifactRegistry.group(:artifact_id).having('COUNT(*) > 1').pluck(:artifact_id)
   puts "Duplicate artifact IDs count: #{artifact_ids.size}"
   puts 'Duplicate Artifact IDs:', artifact_ids

   # Check for duplicate package file registries
   package_file_ids = Geo::PackageFileRegistry.group(:package_file_id).having('COUNT(*) > 1').pluck(:package_file_id)
   puts "Duplicate package file IDs count: #{package_file_ids.size}"
   puts 'Duplicate Package File IDs:', package_file_ids

   # Check for duplicate LFS object registries
   lfs_object_ids = Geo::LfsObjectRegistry.group(:lfs_object_id).having('COUNT(*) > 1').pluck(:lfs_object_id)
   puts "Duplicate LFS object IDs count: #{lfs_object_ids.size}"
   puts 'Duplicate LFS Object IDs:', lfs_object_ids

   # Check for duplicate pages deployment registries
   pages_deployment_ids = Geo::PagesDeploymentRegistry.group(:pages_deployment_id).having('COUNT(*) > 1').pluck(:pages_deployment_id)
   puts "Duplicate pages deployment IDs count: #{pages_deployment_ids.size}"
   puts 'Duplicate Pages Deployment IDs:', pages_deployment_ids

   # Check for duplicate terraform state version registries
   terraform_state_ids = Geo::TerraformStateVersionRegistry.group(:terraform_state_version_id).having('COUNT(*) > 1').pluck(:terraform_state_version_id)
   puts "Duplicate terraform state version IDs count: #{terraform_state_ids.size}"
   puts 'Duplicate Terraform State Version IDs:', terraform_state_ids
   ```

**解决方案：**

1. 在从站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 移除每个受影响类型的重复注册表条目：

   ```ruby
   # Remove duplicate upload registries
   upload_ids = Geo::UploadRegistry.group(:file_id).having('COUNT(*) > 1').pluck(:file_id)
   if upload_ids.any?
     Geo::UploadRegistry.where(file_id: upload_ids).delete_all
     puts "Removed #{upload_ids.size} duplicate upload registry entries"
   end

   # Remove duplicate job artifact registries
   artifact_ids = Geo::JobArtifactRegistry.group(:artifact_id).having('COUNT(*) > 1').pluck(:artifact_id)
   if artifact_ids.any?
     Geo::JobArtifactRegistry.where(artifact_id: artifact_ids).delete_all
     puts "Removed #{artifact_ids.size} duplicate job artifact registry entries"
   end

   # Remove duplicate package file registries
   package_file_ids = Geo::PackageFileRegistry.group(:package_file_id).having('COUNT(*) > 1').pluck(:package_file_id)
   if package_file_ids.any?
     Geo::PackageFileRegistry.where(package_file_id: package_file_ids).delete_all
     puts "Removed #{package_file_ids.size} duplicate package file registry entries"
   end

   # Remove duplicate LFS object registries
   lfs_object_ids = Geo::LfsObjectRegistry.group(:lfs_object_id).having('COUNT(*) > 1').pluck(:lfs_object_id)
   if lfs_object_ids.any?
     Geo::LfsObjectRegistry.where(lfs_object_id: lfs_object_ids).delete_all
     puts "Removed #{lfs_object_ids.size} duplicate LFS object registry entries"
   end

   # Remove duplicate pages deployment registries
   pages_deployment_ids = Geo::PagesDeploymentRegistry.group(:pages_deployment_id).having('COUNT(*) > 1').pluck(:pages_deployment_id)
   if pages_deployment_ids.any?
     Geo::PagesDeploymentRegistry.where(pages_deployment_id: pages_deployment_ids).delete_all
     puts "Removed #{pages_deployment_ids.size} duplicate pages deployment registry entries"
   end

   # Remove duplicate terraform state version registries
   terraform_state_ids = Geo::TerraformStateVersionRegistry.group(:terraform_state_version_id).having('COUNT(*) > 1').pluck(:terraform_state_version_id)
   if terraform_state_ids.any?
     Geo::TerraformStateVersionRegistry.where(terraform_state_version_id: terraform_state_ids).delete_all
     puts "Removed #{terraform_state_ids.size} duplicate terraform state version registry entries"
   end
   ```

1. 验证所有注册表类型的清理情况：

   ```ruby
   # Verify no remaining duplicates
   upload_duplicates = Geo::UploadRegistry.group(:file_id).having('COUNT(*) > 1').count
   artifact_duplicates = Geo::JobArtifactRegistry.group(:artifact_id).having('COUNT(*) > 1').count
   package_duplicates = Geo::PackageFileRegistry.group(:package_file_id).having('COUNT(*) > 1').count
   lfs_duplicates = Geo::LfsObjectRegistry.group(:lfs_object_id).having('COUNT(*) > 1').count
   pages_duplicates = Geo::PagesDeploymentRegistry.group(:pages_deployment_id).having('COUNT(*) > 1').count
   terraform_duplicates = Geo::TerraformStateVersionRegistry.group(:terraform_state_version_id).having('COUNT(*) > 1').count

   puts "Remaining duplicates:"
   puts "  Uploads: #{upload_duplicates.size}"
   puts "  Job Artifacts: #{artifact_duplicates.size}"
   puts "  Package Files: #{package_duplicates.size}"
   puts "  LFS Objects: #{lfs_duplicates.size}"
   puts "  Pages Deployments: #{pages_duplicates.size}"
   puts "  Terraform State Versions: #{terraform_duplicates.size}"
   ```

<a id="error-checksum-does-not-match-the-primary-checksum"></a>

### 错误：`Checksum does not match the primary checksum`

**可能的原因：** 代码仓库或容器镜像仓库验证间隔更改导致校验和不一致。

**诊断：**

1. 在从站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 检查失败的代码仓库或容器镜像仓库：

   ```ruby
   failed_repos = Geo::ProjectRepositoryRegistry.failed.limit(100)
   failed_repos.each do |repo|
     puts "Project ID: #{repo.project_id}"
     puts "Primary checksum: #{repo.verification_checksum_mismatched}"
     puts "Secondary checksum: #{repo.verification_checksum}"
     puts "Error: #{repo.last_sync_failure}"
     puts "---"
   end
   ```

   ```ruby
   failed_container_repos = Geo::ContainerRepositoryRegistry.failed.limit(100)
   failed_container_repos.each do |repo|
     puts "Container Repo Id: #{repo.model_record_id}"
     puts "Primary checksum: #{repo.verification_checksum_mismatched}"
     puts "Secondary checksum: #{repo.verification_checksum}"
     puts "Error: #{repo.last_sync_failure}"
     puts "---"
   end
   ```

**解决方案：**

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 强制对特定项目或容器镜像仓库重新验证：

   ```ruby
   project_ids = [1, 2, 3] # Replace with actual failing project IDs

   project_ids.each do |project_id|
     project = Project.find(project_id)
     puts "Reverifying project: #{project.full_path}"

     project_state = project.project_state
     project_state.update!(verification_state: 0)

     puts "Project #{project_id} marked for reverification"
   end
   ```

   ```ruby
   container_repo_ids = [1, 2, 3]

   container_repo_ids.each do |repo_id|
     container_repo = ContainerRepository.find(repo_id)
     puts "Reverifying container repository: #{container_repo.path}"

     state = container_repo.container_repository_state
     state.update!(verification_state: 0)

     puts "Container Repo #{repo_id} marked for reverification"
   end
   ```

<a id="object-type-specific-troubleshooting-for-error-during-verification-file-is-not-checksummable"></a>

### 针对 `Error during verification: File is not checksummable` 的对象类型特定故障排除

不同的 Geo 数据类型具有独特的特征和常见的失败模式。本节提供针对特定对象类型的定向故障排除。

<a id="uploads"></a>

#### 上传

**诊断：**

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 识别文件缺失的上传。根据需要更新 `limit(5)` 以查看更多结果：

   ```ruby
   checksummable_failures = Upload.verification_failed
                                   .where("verification_failure LIKE '%File is not checksummable%'")

   puts "Found #{checksummable_failures.count} uploads with missing files"

   checksummable_failures.limit(5).each_with_index do |record, index|
     puts "Record #{index + 1}:"
     puts "  ID: #{record.id}"
     puts "  Path: #{record.path}"
     puts "  Model: #{record.model_type} (ID: #{record.model_id})"
     puts "  Created: #{record.created_at}"
     puts "---"
   end
   ```

**解决方案：**

要解决这些失败，请按照 [主 Geo 站点上的上传验证失败](#failed-verification-of-uploads-on-the-primary-geo-site) 中的步骤进行操作。

<a id="pages-deployments"></a>

#### Pages 部署

**诊断：**

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 检查有问题的 Pages 部署：

   ```ruby
   checksummable_failures = PagesDeployment.verification_failed
                                           .where("verification_failure LIKE '%File is not checksummable%'")

   checksummable_failures.each_with_index do |record, index|
     puts "Record #{index + 1}:"
     puts "  ID: #{record.id}"
     puts "  Project: #{record.project.full_path}"
     puts "  Created: #{record.created_at}"
     puts "  File exists: #{record.file.exists?}"
     puts "---"
   end
   ```

**解决方案：**

> [!warning]
> 在删除任何 Pages 部署记录之前，请确保您有最新且可用的备份。与您的团队协调，确认这些部署可以安全移除。

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 与团队确认部署可以安全移除后：

   ```ruby
   def destroy_pages_deployments_not_checksummable(dry_run: true)
     deployments = PagesDeployment.verification_failed.where("verification_failure LIKE '%File is not checksummable%'")
     puts "Found #{deployments.count} pages deployments that failed verification with 'File is not checksummable'."

     if dry_run
       puts "DRY RUN - No changes made"
       deployments.each { |d| puts "Would remove: ID #{d.id}, Project: #{d.project.full_path}" }
       return
     end

     puts "Enter 'y' to continue: "
     prompt = STDIN.gets.chomp
     if prompt != 'y'
       puts "Exiting without action..."
       return
     end

     puts "Destroying all..."
     deployments.destroy_all
     puts "Done!"
   end

   # Run in dry run mode first
   destroy_pages_deployments_not_checksummable(dry_run: true)
   ```

<a id="lfs-objects"></a>

#### LFS 对象

**诊断：**

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 检查有问题的 LFS 对象：

   ```ruby
   checksummable_failures = LfsObject.verification_failed
                                     .where("verification_failure LIKE '%File is not checksummable%'")

   checksummable_failures.each_with_index do |record, index|
     puts "Record #{index + 1}:"
     puts "  OID: #{record.oid}"
     puts "  Size: #{record.size} bytes"
     puts "  File Store: #{record.file_store}"
     puts "  Created: #{record.created_at}"

     # Show associated projects
     associations = record.lfs_objects_projects.includes(:project)
     puts "  Associated projects (#{associations.count}):"
     associations.each do |assoc|
       project = assoc.project
       if project
         puts "    - #{project.full_path}"
       else
         puts "    - Project ID: #{assoc.project_id} (not found)"
       end
     end
     puts "---"
   end
   ```

**解决方案：**

> [!warning]
> 移除 LFS 对象会影响所有引用它们的项目。确保您有备份，并在删除前与项目维护者协调。

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 移除文件缺失的 LFS 对象：

   ```ruby
   def destroy_lfs_not_checksummable(dry_run: true)
     lfs_objects = LfsObject.verification_failed.where("verification_failure like '%File is not checksummable%'")
     puts "Found #{lfs_objects.count} LFS objects that failed verification with 'File is not checksummable'."

     if dry_run
       puts "DRY RUN - No changes made"
       lfs_objects.each { |obj| puts "Would remove: OID #{obj.oid}, Size: #{obj.size}" }
       return
     end

     puts "Enter 'y' to continue with deletion: "
     prompt = STDIN.gets.chomp
     if prompt != 'y'
       puts "Exiting without action..."
       return
     end

     puts "Destroying all..."
     lfs_objects.each do |lfs_object|
       lfs_object.lfs_objects_projects.destroy_all
       lfs_object.destroy!
     end
     puts "Done!"
   end

   # Run in dry run mode first
   destroy_lfs_not_checksummable(dry_run: true)
   ```

<a id="job-artifacts"></a>

#### 作业产物

**诊断：**

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 检查文件缺失的产物：

   ```ruby
   failed_artifacts = Ci::JobArtifact.verification_failed.where("verification_failure LIKE '%File is not checksummable%'")

   failed_artifacts.each do |registry|
     artifact = Ci::JobArtifact.find_by(id: registry.id)
     if artifact
       puts "Artifact ID: #{artifact.id}"
       puts "Job ID: #{artifact.job_id}"
       puts "Project ID: #{artifact.project_id}"
       puts "File exists: #{artifact.file.exists?}"
       puts "File path: #{artifact.file.path}"
     else
       puts "Artifact ID #{artifact.id} not found in database"
     end
     puts "---"
   end
   ```

**解决方案：**

> [!warning]
> 在删除任何作业产物记录之前，请确保您有最新且可用的备份。与您的团队协调，确认这些产物可以安全移除。

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 清理文件缺失的产物：

   ```ruby
   def cleanup_missing_artifacts(dry_run: true)
     missing_file_artifacts = []

     Ci::JobArtifact.find_each do |artifact|
       unless artifact.file.exists?
         missing_file_artifacts << artifact.id
         puts "Missing file for artifact #{artifact.id}" if dry_run
       end
     end

     puts "Found #{missing_file_artifacts.size} artifacts with missing files"

     unless dry_run
       Ci::JobArtifact.where(id: missing_file_artifacts).destroy_all
       puts "Removed #{missing_file_artifacts.size} artifacts with missing files"
     end
   end

   # Run in dry run mode first
   cleanup_missing_artifacts(dry_run: true)
   ```

<a id="package-files"></a>

#### 软件包文件

当主站点上的存储中缺少软件包文件时，会发生此错误。

要识别受影响的软件包文件：

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 查询受影响的记录。根据需要更新 `limit(5)` 以查看更多结果：

   ```ruby
   checksummable_failures = Packages::PackageFile.verification_failed
                                                  .where("verification_failure LIKE '%File is not checksummable%'")

   puts "Found #{checksummable_failures.count} package files with missing files"

   checksummable_failures.limit(5).each_with_index do |record, index|
     puts "Record #{index + 1}:"
     puts "  ID: #{record.id}"
     puts "  File Name: #{record.file_name}"
     puts "  Package ID: #{record.package_id}"
     puts "  Created: #{record.created_at}"
     puts "---"
   end
   ```

> [!warning]
> 在删除任何软件包文件记录之前，请确保您有最新且可用的备份。
> 与您的团队协调，确认这些软件包文件可以安全移除。

要移除受影响的软件包文件：

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 删除受影响的记录：

   ```ruby
   def destroy_packages_not_checksummable(dry_run: true)
     packages = Packages::PackageFile.verification_failed
                  .where("packages_package_file_states.verification_failure LIKE '%File is not checksummable%'")
     puts "Found #{packages.count} packages that failed verification with 'File is not checksummable'."

     if dry_run
       puts "DRY RUN - No changes made"
       packages.each { |p| puts "Would remove: ID #{p.id}, File: #{p.file_name}" }
       return
     end

     puts "Enter 'y' to continue: "
     prompt = STDIN.gets.chomp
     if prompt != 'y'
       puts "Exiting without action..."
       return
     end

     puts "Destroying all..."
     packages.destroy_all
     puts "Done!"
   end

   # Run in dry run mode first
   destroy_packages_not_checksummable(dry_run: true)
   ```

<a id="pipeline-artifacts"></a>

#### 流水线产物

**诊断：**

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 检查文件缺失的产物：

   ```ruby
   failed_pipeline_artifacts = Ci::PipelineArtifact.verification_failed.where("verification_failure LIKE '%checksummable%'")

   failed_pipeline_artifacts.each do |registry|
     artifact = Ci::PipelineArtifact.find_by(id: registry.id)
     if artifact
       puts "Artifact ID: #{artifact.id}"
       puts "Pipeline ID: #{artifact.pipeline_id}"
       puts "Project ID: #{artifact.project_id}"
       puts "File exists: #{artifact.file.exists?}"
       puts "File path: #{artifact.file.path}"
     else
       puts "Artifact ID #{artifact.id} not found in database"
     end
     puts "---"
   end
   ```

**解决方案：**

> [!warning]
> 在删除任何流水线产物记录之前，请确保您有最新且可用的备份。与您的团队协调，确认这些产物可以安全移除。

1. 在主站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。
1. 移除文件缺失的流水线产物：

   ```ruby
   def destroy_pipeline_artifacts_not_checksummable
     artifacts = Ci::PipelineArtifact.verification_failed.where("verification_failure like '%File is not checksummable%'")
     puts "Found #{artifacts.count} pipeline artifacts that failed verification with 'File is not checksummable'."
     puts "Enter 'y' to continue: "
     prompt = STDIN.gets.chomp
     if prompt != 'y'
       puts "Exiting without action..."
       return
     end

     puts "Destroying all..."
     artifacts.destroy_all
     puts "Done!"
   end

   destroy_pipeline_artifacts_not_checksummable
   ```

<a id="blobs-out-of-sync-due-to-timeout"></a>

### 由于超时导致 Blob 不同步

当大文件超过默认的 8 小时 blob 下载超时时，Blob（例如 LFS 对象、作业产物和软件包文件）可能无法同步，并出现
`Sync timed out after 28800`。

要解决此问题，请按顺序首先使用受支持的选项：

1. [增加 blob 下载超时](#increase-the-blob-download-timeout) 并让 Geo
   重试，以便框架处理下载、验证和同步状态。
1. 如果 blob 仍然无法同步，请 [识别并验证受影响的 blob](#identify-and-validate-timed-out-blobs)
   并 [从主站点复制文件](#copy-files-from-primary-to-secondary)。
1. 作为最后的手段，[从 Rails 控制台重新同步 blob](#resync-timed-out-blobs-automatically-from-the-rails-console)。

<a id="increase-the-blob-download-timeout"></a>

#### 增加 blob 下载超时

在极狐GitLab 18.10 及更高版本中，blob 下载超时可按 Geo 站点配置。

要增加 blob 下载超时，请将 `<secondary_id>` 替换为您的从站点 ID，并将 `<token>` 替换为管理员 API 令牌：

```shell
curl --header "PRIVATE-TOKEN: <token>" \
  --request PUT \
  --data '{"blob_download_timeout": 43200}' \
  "https://gitlab.example.com/api/v4/geo_nodes/<secondary_id>"
```

增加超时后，等待 Geo 自动重试，或
[手动重试复制](#manually-retry-replication-or-verification)。

<a id="identify-and-validate-timed-out-blobs"></a>

#### 识别并验证超时的 blob

如果在增加超时后 blob 仍然失败，请识别受影响的对象并确认文件存在于主站点上。以下示例使用 LFS 对象；
对于其他 blob 类型，请使用匹配的 [Geo 注册表类](#geo-registry-classes) 和模型。

1. 在从站点上识别受影响的对象：

   ```ruby
   registries = Geo::LfsObjectRegistry.failed.where("last_sync_failure LIKE '%timed out%'")

   puts "Found #{registries.count} LFS objects that failed with a timeout"
   registries.each do |registry|
     lfs_object = LfsObject.find_by(id: registry.lfs_object_id)
     size_gb = lfs_object ? (lfs_object.size / 1024.0 / 1024.0 / 1024.0).round(2) : 'unknown'
     puts "  Registry ID: #{registry.id}, LFS Object ID: #{registry.lfs_object_id}, Size: #{size_gb} GB, Failure: #{registry.last_sync_failure}, Retries: #{registry.retry_count}"
   end
   ```

1. 使用上一步中的 `lfs_object_id` 值，确认文件存在于
   主站点上：

   ```ruby
   [lfs_object_id1, lfs_object_id2, lfs_object_id3].each do |id|
     lfs_object = LfsObject.find_by(id: id)

     if lfs_object.nil?
       puts "LFS Object ID: #{id} not found"
       next
     end

     puts "LFS Object ID: #{id}, Size: #{(lfs_object.size / 1024.0 / 1024.0 / 1024.0).round(2)} GB, File exists?: #{lfs_object.file.exists?}, Path: #{lfs_object.file.path}"
   end
   ```

<a id="copy-files-from-primary-to-secondary"></a>

#### 将文件从主站点复制到从站点

如果文件存在于主站点但缺失于从站点，请使用上一步中的路径定位文件：

- 对于对象存储：路径是配置的 LFS 存储桶中的对象键。从主存储桶中找到并
  下载文件，然后将其上传到从存储桶中的相同键。
- 对于本地存储：路径相对于主站点上的 `/var/opt/gitlab/gitlab-rails/shared/lfs-objects/`。
  将文件复制到从站点上的相同相对路径。

<a id="mark-blobs-as-synced"></a>

#### 将 blob 标记为已同步

文件存在于从站点后，将它们标记为已同步并触发验证。以下示例使用 LFS 对象；对于其他 blob 类型，请使用匹配的
[Geo 注册表类](#geo-registry-classes)：

```ruby
[lfs_object_id1, lfs_object_id2, lfs_object_id3].each do |lfs_object_id|
  begin
    registry = Geo::LfsObjectRegistry.find_by(lfs_object_id: lfs_object_id)

    if registry.nil?
      puts "Registry not found for LFS Object #{lfs_object_id}"
      next
    end

    registry.update!(
      state: 2,
      success: true,
      last_synced_at: Time.current,
      last_sync_failure: nil,
      retry_count: 0,
      retry_at: nil
    )
    registry.replicator.verify

    puts "LFS Object #{lfs_object_id}: marked as synced and verification triggered"
  rescue => e
    puts "Error processing LFS Object #{lfs_object_id}: #{e.message}"
  end
end
```

<a id="resync-timed-out-blobs-automatically-from-the-rails-console"></a>

#### 从 Rails 控制台自动重新同步超时的 blob

仅在受支持的选项
（[增加 blob 下载超时](#increase-the-blob-download-timeout)、
[API](../../../../api/geo_nodes.md) 和
[管理区域中的 Geo 复制详细信息](#from-the-ui)）未能解决失败后，才将此过程用作最后的手段。它在 Geo 框架之外运行同步，因此请尽可能优先使用受支持的选项。

以下辅助函数使用较长的读取超时直接从主站点流式传输 blob（这避免了同步作业的固定超时），根据主站点验证其大小和内容校验和，通过框架的上传器存储它，将注册表标记为已同步，并重新触发验证。

此方法适用于任何 blob 类型的可复制对象：`Ci::JobArtifact`、
`Ci::PipelineArtifact`、`Ci::SecureFile`、`LfsObject`、`Packages::PackageFile`、
`PagesDeployment`、`Terraform::StateVersion` 和 `Upload`。Git 代码仓库和
容器仓库使用不同的同步路径，不在此范围内。

> [!warning]
> 更改数据的命令如果未正确运行或在正确的条件下运行，可能会造成损害。
> 始终先在测试环境中运行命令，并准备好备份实例以供恢复。

1. 在从站点上 [启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)。

1. 定义辅助函数：

   ```ruby
   require 'net/http'
   require 'digest'
   require 'tempfile'

   # Content-hash attribute for each blob model. Types that are not listed, or
   # whose hash attribute is nil, fall back to size-only verification.
   GEO_BLOB_VERIFICATION = {
     'Ci::JobArtifact' => :file_sha256,
     'Ci::PipelineArtifact' => :file_sha256,
     'Packages::PackageFile' => :file_sha256,
     'PagesDeployment' => :file_sha256,
     'Upload' => :checksum,
     'Ci::SecureFile' => :checksum,
     'LfsObject' => :oid
   }

   # Streams an HTTP GET to the block, following redirects. The Geo
   # authentication header is sent only on the first request. On a redirect to a
   # pre-signed object storage URL (when proxy_download is disabled) it is
   # dropped, because the pre-signed URL is already authenticated.
   def geo_stream_get(uri, headers, limit = 5, &block)
     raise 'too many redirects' if limit < 0

     Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
       open_timeout: 60, read_timeout: 86_400, write_timeout: 86_400) do |http|
       request = Net::HTTP::Get.new(uri)
       headers.each { |key, value| request[key] = value }

       http.request(request) do |response|
         case response.code.to_i
         when 200
           response.read_body { |chunk| yield chunk }
         when 301, 302, 303, 307, 308
           raise 'redirect with no Location' unless response['location']

           return geo_stream_get(URI(response['location']), {}, limit - 1, &block)
         else
           raise "HTTP #{response.code}: #{response.message}"
         end
       end
     end
   end

   def manual_geo_blob_sync(registry_class, registry_id)
     registry = registry_class.find_by(id: registry_id)
     return "no #{registry_class.name} ##{registry_id}" unless registry

     replicator = registry.replicator
     model = replicator.model_record
     return 'missing model record (gone on primary?)' unless model

     uploader = replicator.carrierwave_uploader
     downloader = Gitlab::Geo::Replication::BlobDownloader.new(replicator: replicator)
     uri = URI(downloader.resource_url)
     # request_headers is a private BlobDownloader method, accessed here with
     # send. It returns a short-lived Geo JWT. This relies on an internal API
     # and might need updating after a GitLab upgrade.
     auth = downloader.send(:request_headers)

     sha_attr = GEO_BLOB_VERIFICATION[model.class.name]
     want_size = model.respond_to?(:size) ? model.size : nil
     want_sha = sha_attr && model.respond_to?(sha_attr) ? model.public_send(sha_attr) : nil

     tmp = Tempfile.new(['geo-blob', '.bin'], '/tmp')
     tmp.binmode

     begin
       geo_stream_get(uri, auth) { |chunk| tmp.write(chunk) }
       tmp.flush

       raise "size mismatch (#{tmp.size}/#{want_size})" if want_size && tmp.size != want_size

       if want_sha && Digest::SHA256.file(tmp.path).hexdigest != want_sha
         raise 'checksum mismatch - not marking as synced'
       end

       # Store the blob through the same uploader method the Geo framework
       # uses (BlobDownloader#download_file), so local and object storage are
       # both handled the same way.
       uploader.replace_file_without_saving!(CarrierWave::SanitizedFile.new(tmp))

       registry.update!(state: 2, last_synced_at: Time.current, retry_at: nil,
         retry_count: 0, last_sync_failure: nil)
       registry.update!(bytes: tmp.size) if registry.respond_to?(:bytes)

       # The raw update! above bypasses the after_synced state-machine
       # callback, so re-trigger verification explicitly to reconcile a
       # previously verification_failed registry.
       replicator.verify

       "OK #{registry_class.name}##{registry_id} (#{tmp.size} bytes)"
     ensure
       tmp.close!
     end
   end
   ```

1. 为受影响的注册表记录运行辅助函数。将注册表类
   替换为任何 [Geo 注册表类](#geo-registry-classes)，并将 `123` 替换为
   实际的注册表 ID：

   ```ruby
   manual_geo_blob_sync(Geo::LfsObjectRegistry, 123)
   ```

1. 可选。要重新同步因该错误而失败的所有同类型 blob：

   ```ruby
   Geo::LfsObjectRegistry
     .where("last_sync_failure LIKE '%Sync timed out after%'")
     .pluck(:id)
     .each { |id| puts manual_geo_blob_sync(Geo::LfsObjectRegistry, id) }; nil
   ```

如果辅助函数仍然超时或失败，则对象可能缺失或在主站点上不可读。有关更多信息，请参阅
[The file is missing on the Geo primary site](#message-the-file-is-missing-on-the-geo-primary-site)。

<a id="error-projects---error-during-verification-repository-does-not-exist"></a>

### 错误：`Projects - Error during verification: Repository does not exist`

**根本原因：** 没有 Git 代码仓库的项目导致验证失败。

**症状：**

- 项目在验证期间显示 “Repository does not exist” 错误
- 对于合法没有代码仓库的项目，Geo UI 中会报告错误
- 对不存在的代码仓库进行无效的同步尝试

**变通方法：**

在主站点上为不存在的项目创建项目代码仓库：

```ruby
failed_projects = Project.verification_failed.where("verification_failure LIKE '%Repository does not exist%'")
puts "Found #{failed_projects.count} project repos with 'Repository does not exist' verification failure"
failed_projects.find_each do |p|
  puts "#{p.full_path} #{p.ensure_repository.inspect}"
end
```

<a id="error-expected200--actual403-forbidden"></a>

### 错误：`Expected(200) <=> Actual(403 Forbidden)`

**根本原因：** 缺少 `ListBucket` 权限导致 S3 API 返回 403 而不是 404。

**症状：**

- 使用 S3 端点的日志中出现 403 错误
- 对 S3 存储桶的 HEAD 请求失败
- 对象存储支持的数据类型的同步失败

**解决方案：**

这需要基础设施团队介入，将 `ListBucket` 权限添加到极狐GitLab 使用的 S3 IAM 策略中。

<a id="message-synchronization-failed---error-syncing-repository"></a>

### 消息：`Synchronization failed - Error syncing repository`

> [!warning]
> 如果大型代码仓库受此问题影响，
> 它们的重新同步可能需要很长时间，并对您的 Geo 站点、存储和网络系统造成显著负载。

以下错误消息表示同步代码仓库时出现一致性检查错误：

```plaintext
Synchronization failed - Error syncing repository [..] fatal: fsck error in packed object
```

多种问题都可能触发此错误。例如，电子邮件地址问题：

```plaintext
Error syncing repository: 13:fetch remote: "error: object <SHA>: badEmail: invalid author/committer line - bad email
   fatal: fsck error in packed object
   fatal: fetch-pack: invalid index-pack output
```

另一个可能触发此错误的问题是 `object <SHA>: hasDotgit: contains '.git'`。检查具体错误，因为您可能在所有代码仓库中遇到多个问题。

第二个同步错误也可能由代码仓库检查问题引起：

```plaintext
Error syncing repository: 13:Received RST_STREAM with error code 2.
```

可以通过 [立即同步所有同步失败的组件资源](#sync-all-resources-of-one-component-that-failed-to-sync) 来观察这些错误。

移除导致一致性错误的格式错误对象涉及重写代码仓库历史，这通常不是一个选项。

要忽略这些一致性检查，请重新配置从 Geo 站点上的 Gitaly，以忽略这些 `git fsck` 问题。以下配置示例：

- [使用更新的配置结构](../../../../update/versions/gitlab_16_changes.md#gitaly-configuration-structure-change)。
- 忽略五种常见的检查失败。

[Gitaly 文档有更多详细信息](../../../gitaly/consistency_checks.md)
关于其他 Git 检查失败和早期版本的极狐GitLab。

```ruby
gitaly['configuration'] = {
  git: {
    config: [
      { key: "fsck.duplicateEntries", value: "ignore" },
      { key: "fsck.badFilemode", value: "ignore" },
      { key: "fsck.missingEmail", value: "ignore" },
      { key: "fsck.badEmail", value: "ignore" },
      { key: "fsck.hasDotgit", value: "ignore" },
      { key: "fetch.fsck.duplicateEntries", value: "ignore" },
      { key: "fetch.fsck.badFilemode", value: "ignore" },
      { key: "fetch.fsck.missingEmail", value: "ignore" },
      { key: "fetch.fsck.badEmail", value: "ignore" },
      { key: "fetch.fsck.hasDotgit", value: "ignore" },
      { key: "receive.fsck.duplicateEntries", value: "ignore" },
      { key: "receive.fsck.badFilemode", value: "ignore" },
      { key: "receive.fsck.missingEmail", value: "ignore" },
      { key: "receive.fsck.badEmail", value: "ignore" },
      { key: "receive.fsck.hasDotgit", value: "ignore" },
    ],
  },
}
```

`fsck` 错误的完整列表可以在 [Git 文档](https://git-scm.com/docs/git-fsck#_fsck_messages) 中找到。

极狐GitLab [包含一项增强功能](https://gitlab.com/gitlab-org/gitaly/-/merge_requests/5879)，可能解决其中一些问题。

[Gitaly 议题 5625](https://gitlab.com/gitlab-org/gitaly/-/issues/5625) 提议确保即使源代码仓库包含
有问题的提交，Geo 也能复制代码仓库。

<a id="related-error-does-not-appear-to-be-a-git-repository"></a>

### 相关错误 `does not appear to be a git repository`

您也可能会收到错误消息 `Synchronization failed - Error syncing repository` 以及以下日志消息。此错误表明预期的 Geo remote 不存在于从 Geo 站点文件系统上代码仓库的 `.git/config` 文件中：

```json
{
  "created": "@1603481145.084348757",
  "description": "Error received from peer unix:/var/opt/gitlab/gitaly/gitaly.socket",
  …
  "grpc_message": "exit status 128",
  "grpc_status": 13
}
{  …
  "grpc.request.fullMethod": "/gitaly.RemoteService/FindRemoteRootRef",
  "grpc.request.glProjectPath": "<namespace>/<project>",
  …
  "level": "error",
  "msg": "fatal: 'geo' does not appear to be a git repository
          fatal: Could not read from remote repository. …",
}
```

要解决此问题：

1. 登录从 Geo 站点的 Web 界面。
1. 备份 [`.git` 文件夹](../../../repository_storage_paths.md#translate-hashed-storage-paths)。
1. 可选。 [抽查](../../../logs/log_parsing.md#find-all-projects-affected-by-a-fatal-git-problem)
   其中一些 ID 是否确实对应
   于已知有 Geo 复制失败的项目。
   使用 `fatal: 'geo'` 作为 `grep` 术语，并调用以下 API：

   ```shell
   curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/<first_failed_geo_sync_ID>"
   ```

1. 进入 [Rails 控制台](../../../operations/rails_console.md) 并运行：

   ```ruby
   failed_project_registries = Geo::ProjectRepositoryRegistry.failed

   if failed_project_registries.any?
     puts "Found #{failed_project_registries.count} failed project repository registry entries:"

     failed_project_registries.each do |registry|
       puts "ID: #{registry.id}, Project ID: #{registry.project_id}, Last Sync Failure: '#{registry.last_sync_failure}'"
     end
   else
     puts "No failed project repository registry entries found."
   end
   ```

1. 运行以下命令为每个项目执行新的同步：

   ```ruby
   failed_project_registries.each do |registry|
     registry.replicator.sync
     puts "Sync initiated for registry ID: #{registry.id}, Project ID: #{registry.project_id}"
   end
   ```

<a id="failures-during-backfill"></a>

## 回填期间的失败

在 [回填](../../_index.md#backfill) 期间，失败被安排在回填队列末尾重试，因此这些失败只有在回填完成后才会清除。

<a id="message-unexpected-disconnect-while-reading-sideband-packet"></a>

## 消息：`unexpected disconnect while reading sideband packet`

不稳定的网络状况可能导致 Gitaly 在尝试从主站点获取大型代码仓库数据时失败。这些状况可能导致此错误：

```plaintext
curl 18 transfer closed with outstanding read data remaining & fetch-pack:
unexpected disconnect while reading sideband packet
```

如果代码仓库必须在站点之间从头复制，则更有可能发生此错误。

Geo 会重试几次，但如果传输持续被网络故障中断，则可以使用诸如 `rsync` 之类的替代方法来绕过 `git` 并为任何 Geo 无法复制的代码仓库创建初始副本。

我们建议逐个传输每个失败的代码仓库，并在每次传输后检查一致性。按照 [`rsync` 到另一台服务器的说明](../../../operations/moving_repositories.md#use-rsync-to-another-server)
将每个受影响的代码仓库从主站点传输到从站点。

<a id="find-repository-check-failures-in-a-geo-secondary-site"></a>

## 在 Geo 从站点中查找代码仓库检查失败

> [!note]
> 所有代码仓库数据类型已在极狐GitLab 16.3 中迁移到 Geo 自助服务框架。有一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/426659)计划在 Geo 自助服务框架中实现此功能。

对于极狐GitLab 16.2 及更早版本：

当 [为所有项目启用](../../../repository_checks.md#enable-repository-checks-for-all-projects) 时，[代码仓库检查](../../../repository_checks.md) 也会在 Geo 从站点上执行。元数据存储在 Geo 跟踪数据库中。

Geo 从站点上的代码仓库检查失败不一定意味着复制问题。以下是解决这些失败的一般方法。

1. 如下所述找到受影响的代码仓库，以及它们的 [记录的错误](../../../repository_checks.md#what-to-do-if-a-check-failed)。
1. 尝试诊断特定的 `git fsck` 错误。可能的错误范围很广，尝试将它们放入搜索引擎。
1. 测试受影响代码仓库的典型功能。从从站点拉取，查看文件。
1. 检查主站点上的代码仓库副本是否具有相同的 `git fsck` 错误。如果您计划故障转移，请考虑优先确保从站点拥有与主站点相同的信息。确保您有主站点的备份，并遵循 [计划故障转移指南](../../disaster_recovery/planned_failover.md)。
1. 推送到主站点，检查更改是否复制到从站点。
1. 如果复制未自动工作，请尝试手动同步代码仓库。

[启动一个 Rails 控制台会话](../../../operations/rails_console.md#starting-a-rails-console-session)
以执行以下基本故障排除步骤。

> [!warning]
> 更改数据的命令如果未正确运行或在正确的条件下运行，可能会造成损害。始终先在测试环境中运行命令，并准备好备份实例以供恢复。

<a id="get-the-number-of-repositories-that-failed-the-repository-check"></a>

### 获取未通过代码仓库检查的代码仓库数量

```ruby
Geo::ProjectRegistry.where(last_repository_check_failed: true).count
```

<a id="find-the-repositories-that-failed-the-repository-check"></a>

### 查找未通过代码仓库检查的代码仓库

```ruby
Geo::ProjectRegistry.where(last_repository_check_failed: true)
```

<a id="hard-delete-a-repository-from-gitaly-cluster-and-resync"></a>

## 从 Gitaly 集群硬删除代码仓库并重新同步

> [!warning]
> 此过程风险较高，且操作力度较大。请仅在其他故障排除方法均无效时，将其作为最后手段使用。在代码仓库重新同步之前，此过程会导致暂时性数据丢失。

此过程会从从站点的 Gitaly 集群中删除代码仓库，然后重新同步。只有在您了解相关风险，并且以下条件全部满足时，才应考虑使用此过程：

- `git clone` 在主站点的代码仓库上正常工作。
- `p.replicator.sync_repository`（其中 `p` 是项目模型实例）在从站点上记录 Gitaly 错误。
- 标准故障排除未能解决该问题。

先决条件：

- 确保您对从站点的 Rails 控制台和 Praefect 节点均具有管理访问权限。
- 验证代码仓库在主站点上可访问且运行正常。
- 制定备份计划，以防需要回滚此过程。

操作步骤如下：

1. 登录从站点的 Rails 控制台。
1. 实例化一个项目模型，并使用以下选项之一将其保存到变量 `p` 中：

   - 如果您知道受影响的项目 ID（例如，`60087`）：

     ```ruby
     p = Project.find(60087)
     ```

   - 如果您知道极狐GitLab 中受影响的项目路径（例如，`my-group/my-project`）：

     ```ruby
     p = Project.find_by_full_path('my-group/my-project')
     ```

1. 输出项目 Git 代码仓库的虚拟存储，并记下以备后用：

   ```ruby
   p.repository.storage
   ```

   示例输出：

   ```ruby
   irb(main):002:0> p.repository.storage
   => "default"
   ```

1. 输出项目 Git 代码仓库的相对路径，并记下以备后用：

   ```ruby
   p.repository.disk_path + '.git'
   ```

   示例输出：

   ```ruby
   irb(main):003:0> p.repository.disk_path + '.git'
   => "@hashed/66/b2/66b2fc8562b3432399acc2d0108fcd2782b32bd31d59226c7a03a20b32c76ee8.git"
   ```

1. 通过 SSH 登录从站点的 Praefect 节点。
1. 按照[手动从 Gitaly 集群中移除代码仓库](../../../gitaly/praefect/recovery.md#manually-remove-repositories) 的过程操作，使用您在前面的步骤中记下的虚拟存储和相对路径。

   从站点上的 Git 代码仓库现已删除。

1. 在 Rails 控制台中，重新同步之前，设置一个关联 ID。此 ID 可帮助您搜索本次会话中运行的命令相关的所有日志：

   ```ruby
   Gitlab::ApplicationContext.push({})
   ```

   示例输出：

   ```ruby
   [2] pry(main)> Gitlab::ApplicationContext.push({})
   => #<Labkit::Context:0x0000000122aa4060 @data={"correlation_id"=>"53da64ae800bd4794a2b61ab1c80b028"}>
   ```

1. 同步项目 Git 代码仓库：

   ```ruby
   p.replicator.sync_repository
   ```

Git 代码仓库现在应从主站点重新同步到从站点。通过 Geo 管理界面监控同步过程，或在 Rails 控制台中检查代码仓库的同步状态。

<a id="infrastructure-and-performance-considerations"></a>

## 基础设施和性能注意事项

某些同步问题是由基础设施层面的问题或性能限制引起的。

<a id="high-concurrency-issues"></a>

### 高并发问题

过高的 Geo 验证并发可能会使数据库过载并导致同步失败。

**症状：**

- 数据库连接超时
- 数据库服务器 CPU 使用率高
- 尽管基础设施健康，同步进度仍然缓慢

**诊断和解决方法：**

通过 [UI](../tuning.md#changing-the-syncverification-concurrency-values) 降低主站点的并发设置

<a id="manual-sync-status-updates"></a>

## 手动同步状态更新

在某些情况下，解决根本问题后，您可能需要手动将对象类型标记为已同步。当问题只能通过手动将文件上传到从站点的对象存储桶来解决时，会出现这种情况。通常不需要执行此操作，但可能因版本缺陷而发生。以下展示了如何将这些手动上传的对象类型（此处为 uploads）标记为已同步。

> [!warning]
> 仅当您已验证文件确实存在于从站点且可访问时，才将对象标记为已同步。

```ruby
def mark_upload_synced(upload_id)
  upload = Upload.find(upload_id)
  registry = upload.replicator.registry
  registry.start
  registry.synced!
  puts "Marked upload #{upload_id} as synced"
end

# Mark specific uploads as synced
upload_ids = [107221, 107320] # Replace with actual IDs
upload_ids.each { |id| mark_upload_synced(id) }
```

<a id="resetting-geo-secondary-site-replication"></a>

## 重置 Geo 从站点复制

如果您遇到从站点处于损坏状态的情况，并希望重置复制状态以从头开始，以下步骤可能会有所帮助：

1. 停止 Sidekiq 和 Geo 日志游标。

   可以让 Sidekiq 优雅停止，但需要使其停止获取新作业，并等待当前作业处理完成。

   您需要先发送 **SIGTSTP** 终止信号，然后在所有作业完成后发送 **SIGTERM**。否则，只需使用 `gitlab-ctl stop` 命令。

   ```shell
   gitlab-ctl status sidekiq
   # run: sidekiq: (pid 10180) <- this is the PID you will use
   kill -TSTP 10180 # change to the correct PID

   gitlab-ctl stop sidekiq
   gitlab-ctl stop geo-logcursor
   ```

   您可以查看 [Sidekiq 日志](../../../logs/_index.md#sidekiq-logs) 以了解 Sidekiq 作业处理何时完成：

   ```shell
   gitlab-ctl tail sidekiq
   ```

1. 清除 Gitaly 和 Gitaly 集群 (Praefect) 数据。

   {{< tabs >}}

   {{< tab title="Gitaly" >}}

   ```shell
   mv /var/opt/gitlab/git-data/repositories /var/opt/gitlab/git-data/repositories.old
   sudo gitlab-ctl reconfigure
   ```

   {{< /tab >}}

   {{< tab title="Gitaly Cluster (Praefect)" >}}

   1. 可选。禁用 Praefect 内部负载均衡器。
   1. 在每个 Praefect 服务器上停止 Praefect：

      ```shell
      sudo gitlab-ctl stop praefect
      ```

   1. 重置 Praefect 数据库：

      ```shell
      sudo /opt/gitlab/embedded/bin/psql -U praefect -d template1 -h localhost -c "DROP DATABASE praefect_production WITH (FORCE);"
      sudo /opt/gitlab/embedded/bin/psql -U praefect -d template1 -h localhost -c "CREATE DATABASE praefect_production WITH OWNER=praefect ENCODING=UTF8;"
      ```

   1. 重命名/删除每个 Gitaly 节点上的代码仓库数据：

      ```shell
      sudo mv /var/opt/gitlab/git-data/repositories /var/opt/gitlab/git-data/repositories.old
      sudo gitlab-ctl reconfigure
      ```

   1. 在您的 Praefect 部署节点上运行 reconfigure 以设置数据库：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 在每个 Praefect 服务器上启动 Praefect：

      ```shell
      sudo gitlab-ctl start praefect
      ```

   1. 可选。如果您禁用了 Praefect 内部负载均衡器，请重新激活它。

   {{< /tab >}}

   {{< /tabs >}}

   > [!note]
   > 一旦您确认不再需要 `/var/opt/gitlab/git-data/repositories.old`，您可能希望在未来将其删除，以节省磁盘空间。

1. 可选。重命名其他数据文件夹并创建新文件夹。

   > [!warning]
   > 从站点上可能仍存在已从主站点删除的文件，但此删除操作尚未反映。如果您跳过此步骤，这些文件不会从 Geo 从站点中删除。

   任何上传的内容（如文件附件、头像或 LFS 对象）都存储在这些路径之一的子文件夹中：

   - `/var/opt/gitlab/gitlab-rails/shared`
   - `/var/opt/gitlab/gitlab-rails/uploads`

   要全部重命名：

   ```shell
   gitlab-ctl stop

   mv /var/opt/gitlab/gitlab-rails/shared /var/opt/gitlab/gitlab-rails/shared.old
   mkdir -p /var/opt/gitlab/gitlab-rails/shared

   mv /var/opt/gitlab/gitlab-rails/uploads /var/opt/gitlab/gitlab-rails/uploads.old
   mkdir -p /var/opt/gitlab/gitlab-rails/uploads

   gitlab-ctl start postgresql
   gitlab-ctl start geo-postgresql
   ```

   重新配置以重新创建文件夹，并确保权限和所有权正确：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 重置跟踪数据库。

   > [!warning]
   > 如果您跳过了可选步骤 3，请确保 `geo-postgresql` 和 `postgresql` 服务都在运行。

   ```shell
   gitlab-rake db:drop:geo DISABLE_DATABASE_ENVIRONMENT_CHECK=1   # on a secondary app node
   gitlab-ctl reconfigure     # on the tracking database node
   gitlab-rake db:migrate:geo # on a secondary app node
   ```

1. 重新启动之前停止的服务。

   ```shell
   gitlab-ctl start
   ```
