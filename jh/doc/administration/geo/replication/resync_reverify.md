---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 重新同步并重新验证 Geo 数据
description: "从 UI 或 Rails 控制台手动重新同步并重新验证单个 Geo 组件或多个组件。"
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

重新同步和重新验证是标准的运维操作。您可以使用它们重试复制或验证，而无需等待自动重试间隔，也可以在复制或验证失败后进行恢复。

在 Geo 从站点的 [Rails 控制台](../../operations/rails_console.md#starting-a-rails-console-session)中，您可以：

- [手动重新同步并重新验证单个组件](#resync-and-reverify-individual-components)
- [手动重新同步并重新验证多个组件](#resync-and-reverify-multiple-components)

<a id="resync-and-reverify-individual-components"></a>

## 重新同步并重新验证单个组件

在从站点上，访问**管理员** > **Geo** > **复制**，以强制重新同步或重新验证单个条目。

但是，如果这样做不起作用，您可以使用 Rails 控制台执行相同的操作。以下各节介绍如何在 [Rails 控制台](../../operations/rails_console.md#starting-a-rails-console-session)中使用内部应用程序命令，以同步或异步方式对单个记录执行复制或验证。

<a id="obtaining-a-replicator-instance"></a>

### 获取 Replicator 实例

> [!warning]
> 更改数据的命令如果未正确运行或未在合适的条件下运行，可能会造成损害。
> 请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

在执行任何同步或验证操作之前，您需要获取一个 Replicator 实例。

首先，根据您要执行的操作，在主站点或从站点中[启动 Rails 控制台会话](../../operations/rails_console.md#starting-a-rails-console-session)。

主站点：

- 您可以计算资源的校验和

从站点：

- 您可以同步资源
- 您可以计算资源的校验和，并将该校验和与主站点的校验和进行比对验证

接下来，运行以下代码片段之一以获取 Replicator 实例。

<a id="given-a-model-records-id"></a>

#### 已知模型记录的 ID

- 将 `123` 替换为实际 ID。
- 将 `Packages::PackageFile` 替换为任意一个
  [Geo 数据类型模型类](#geo-data-type-model-classes)。

```ruby
model_record = Packages::PackageFile.find_by(id: 123)
replicator = model_record.replicator
```

<a id="given-a-registry-records-id"></a>

#### 已知注册表记录的 ID

- 将 `432` 替换为实际 ID。注册表记录的 ID 值可能与其所跟踪的模型记录的 ID 值相同，也可能不同。
- 将 `Geo::PackageFileRegistry` 替换为任意一个 [Geo 注册表类](#geo-registry-classes)。

在 Geo 从站点中：

```ruby
registry_record = Geo::PackageFileRegistry.find_by(id: 432)
replicator = registry_record.replicator
```

<a id="given-an-error-message-in-a-registry-records-last_sync_failure"></a>

#### 已知注册表记录的 `last_sync_failure`中的错误消息

- 将 `Geo::PackageFileRegistry` 替换为任意一个 [Geo 注册表类](#geo-registry-classes)。
- 将 `error message here` 替换为实际的错误消息。

```ruby
registry = Geo::PackageFileRegistry.find_by("last_sync_failure LIKE '%error message here%'")
replicator = registry.replicator
```

<a id="given-an-error-message-in-a-registry-records-verification_failure"></a>

#### 已知注册表记录的 `verification_failure`中的错误消息

- 将 `Geo::PackageFileRegistry` 替换为任意一个 [Geo 注册表类](#geo-registry-classes)。
- 将 `error message here` 替换为实际的错误消息。

```ruby
registry = Geo::PackageFileRegistry.find_by("verification_failure LIKE '%error message here%'")
replicator = registry.replicator
```

<a id="performing-operations-with-a-replicator-instance"></a>

### 使用 Replicator 实例执行操作

将 Replicator 实例存储在 `replicator` 变量中后，您可以执行许多操作：

<a id="sync-in-the-console"></a>

#### 在控制台中同步

此代码片段仅在从站点中有效。

这会在控制台中同步执行同步代码，因此您可以观察同步资源所需的时间，或查看完整的错误回溯。

```ruby
replicator.sync
```

您也可以选择将控制台的日志级别设置为比配置的日志级别更详细，然后执行同步：

```ruby
Rails.logger.level = :debug
```

<a id="checksum-or-verify-in-the-console"></a>

#### 在控制台中计算校验和或验证

此代码片段在任何主站点或从站点中均有效。

在主站点中，它会计算资源的校验和，并将结果存储在主极狐GitLab 数据库中。在从站点中，它会计算资源的校验和，将其与主极狐GitLab 数据库中的校验和（由主站点生成）进行比对，并将结果存储在 Geo 跟踪数据库中。

这会在控制台中同步执行计算校验和与验证的代码，因此您可以观察所需的时间，或查看完整的错误回溯。

```ruby
replicator.verify
```

<a id="sync-in-a-sidekiq-job"></a>

#### 在 Sidekiq 作业中同步

此代码片段仅在从站点中有效。

它会将作业加入队列，由 Sidekiq 执行资源的[同步](#sync-in-the-console)。

```ruby
replicator.enqueue_sync
```

<a id="verify-in-a-sidekiq-job"></a>

#### 在 Sidekiq 作业中验证

此代码片段在任何主站点或从站点中均有效。

它会将作业加入队列，由 Sidekiq 对资源[计算校验和或验证](#checksum-or-verify-in-the-console)。

```ruby
replicator.verify_async
```

<a id="get-a-model-record"></a>

#### 获取模型记录

此代码片段在任何主站点或从站点中均有效。

```ruby
replicator.model_record
```

<a id="get-a-registry-record"></a>

#### 获取注册表记录

此代码片段仅在从站点中有效，因为注册表存储在 Geo 跟踪数据库中。

```ruby
replicator.registry
```

<a id="geo-data-type-model-classes"></a>

### Geo 数据类型模型类

Geo 数据类型是一种特定类别的数据，一个或多个极狐GitLab 功能需要它来存储相关数据，并由 Geo 复制到从站点。

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

主要的类类型有 Registry、Model 和 Replicator。如果您拥有其中某个类的实例，就可以获取其他类。Registry 和 Model 主要管理 PostgreSQL 数据库状态。Replicator 知道如何复制或验证非 PostgreSQL 数据（文件/Git 代码仓库/容器仓库）。

<a id="geo-registry-classes"></a>

### Geo 注册表类

在极狐GitLab Geo 的语境中，**注册表记录**指的是 Geo 跟踪数据库中的注册表。每条记录跟踪主极狐GitLab 数据库中的一个可复制对象，例如 LFS 文件或项目 Git 代码仓库。可查询的 Geo 注册表所对应的 Rails 模型包括：

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

## 重新同步并重新验证多个组件

当组件资源同步或验证失败时，您可以触发批量操作来重新启动复制队列。这些操作会将重试次数和计划时间重置为 0，使系统更快地处理失败的资源，而无需等待长达 1 小时。

> [!note]
> 这些操作不会立即处理资源。它们会重新将处理同步和验证的后台作业加入队列。实际的复制工作会通过标准的 Geo 复制过程异步进行。

<a id="how-resync-and-reverification-works"></a>

### 重新同步和重新验证的工作方式

当您触发重新同步或重新验证操作时，系统会将匹配的记录标记为 `pending`。Geo 重新同步和重新验证后台工作进程会获取这些记录，并按照正常的队列优先级进行处理。此机制允许您加快处理失败的资源，而不会立即阻塞该操作。

> [!note]
> 无法重新验证未成功同步的记录。只有已同步的记录才能被验证。

您可以从 UI 或 Rails 控制台触发批量操作。

<a id="from-the-ui"></a>

### 从 UI 操作

您可以从 UI 中为某个组件的所有资源安排完整重新同步：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在**复制详情**下，选择所需的组件。

<a id="resync-resources-for-the-selected-component"></a>

#### 重新同步所选组件的资源

1. 选择**全部重新同步**：这会重置所选资源的所有记录状态，无论它们是否已同步。
1. 选择**重新同步所有失败项**：这会重置所有同步失败的记录。

<a id="reverify-resources-for-the-selected-component"></a>

#### 重新验证所选组件的资源

1. 选择**全部重新验证**：这会重置所选资源的所有记录状态，无论它们是否已验证。
1. 选择**重新验证所有失败项**：这会重置所有验证失败但同步成功的记录。

<a id="reverify-one-component-on-all-sites"></a>

#### 在所有站点上重新验证一个组件

如果主站点的校验和存在问题，那么您需要让主站点重新计算校验和。这样就能实现“完整重新验证”，因为在主站点上重新计算每个校验和后，会生成事件并传播到所有从站点，使它们重新计算校验和并比对值。任何不匹配都会将注册表标记为 `sync failed`，从而安排同步重试。

您可以从 UI 中重新计算主站点的校验和：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **数据管理**。
1. 在下拉列表中选择所需的组件。
1. 选择**全部校验和**。

> [!warning]
> **全部重新同步**、**全部重新验证**和**全部校验和**会触发所有资源的更新，无论它们是否已同步或已验证。
> 当实例中存在数千个某种对象类型（例如 CI 作业产物）时，不应执行此操作。

<a id="from-the-rails-console"></a>

### 从 Rails 控制台操作

> [!warning]
> 更改数据的命令如果未正确运行或未在合适的条件下运行，可能会造成损害。
> 请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

以下各节介绍如何在 [Rails 控制台](../../operations/rails_console.md#starting-a-rails-console-session)中使用内部应用程序命令来执行批量复制或验证。

<a id="sync-all-resources-of-one-component-that-failed-to-sync"></a>

#### 同步某个组件中所有同步失败的资源

以下脚本：

- 遍历所有失败的代码仓库。
- 显示 Geo 同步和验证元数据，包括上次失败的原因。
- 尝试重新同步该代码仓库。
- 如果发生失败，报告失败原因。
- 可能需要一些时间才能完成。每个代码仓库检查都必须完成后才能报告结果。如果会话超时，请采取措施让进程继续运行，例如启动 `screen` 会话，或使用 [Rails runner](../../operations/rails_console.md#using-the-rails-runner) 和 `nohup` 运行它。

在 Geo 从站点上运行此脚本。

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

#### 重新验证主站点上所有校验和失败的资源

系统会自动重新验证主站点上所有校验和失败的资源，但它使用渐进式退避方案来避免失败量过大。

您也可以选择手动提前触发重新验证，例如在您完成一次尝试性干预后：

1. SSH 登录到主站点中的 GitLab Rails 节点。
1. 打开 [Rails 控制台](../../operations/rails_console.md#starting-a-rails-console-session)。
1. 将 `LfsObject` 替换为任意一个 [Geo 数据类型模型类](#geo-data-type-model-classes)，
   将所有资源标记为 `pending verification`：

   ```ruby
   LfsObject.verification_state_table_class.where(verification_state: 3).each_batch do |relation|
     relation.update_all(verification_state: 0)
   end
   ```
