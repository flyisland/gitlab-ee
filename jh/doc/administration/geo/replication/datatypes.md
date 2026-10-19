---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 支持的 Geo 数据类型
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Geo 数据类型是指一个或多个极狐GitLab 功能存储相关信息所需的特定数据类别。

为了使用 Geo 复制这些功能产生的数据，我们采用多种策略来访问、传输和验证这些数据。

<a id="data-types"></a>

## 数据类型

我们区分以下几种不同的数据类型：

- [Git 代码仓库](#git-repositories)
- [容器仓库](#container-repositories)
- [Blob](#blobs)
- [数据库](#databases)

请参阅下方列表，了解我们复制的每个功能或组件、其对应的数据类型、复制和验证方法：

| 类型                 | 功能 / 组件                             | 复制方法                           | 验证方法           |
|:---------------------|:------------------------------------------------|:---------------------------------------------|:------------------------------|
| 数据库             | PostgreSQL 中的应用数据                  | 原生                                       | 原生                        |
| 数据库             | Redis                                           | 不适用[^replication-note]            | 不适用                |
| 数据库             | SSH 公钥                                 | PostgreSQL 复制                       | PostgreSQL 复制        |
| Git                  | 项目代码仓库                              | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 项目 Wiki 代码仓库                         | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 项目设计代码仓库                      | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 代码片段                                        | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 群组 Wiki 代码仓库                           | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Blob                 | 用户上传内容 _（文件系统）_                    | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 用户上传内容 _（对象存储）_                 | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | LFS 对象 _（文件系统）_                     | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | LFS 对象 _（对象存储）_                  | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | CI 作业产物 _（文件系统）_                | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | CI 作业产物 _（对象存储）_             | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 已归档的 CI 构建跟踪 _（文件系统）_        | 使用 API 的 Geo                                 | 未实现             |
| Blob                 | 已归档的 CI 构建跟踪 _（对象存储）_     | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 软件包仓库 _（文件系统）_                | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 软件包仓库 _（对象存储）_             | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | Packages Helm 元数据缓存 _（文件系统）_    | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | Packages Helm 元数据缓存 _（对象存储）_ | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | Terraform 模块仓库 _（文件系统）_       | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | Terraform 模块仓库 _（对象存储）_    | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 版本化 Terraform 状态 _（文件系统）_       | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 版本化 Terraform 状态 _（对象存储）_    | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 外部合并请求差异 _(文件系统)_    | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 外部合并请求差异 _(对象存储)_ | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 流水线产物 _(文件系统)_              | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 流水线产物 _(对象存储)_           | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | Pages _(文件系统)_                           | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | Pages _(对象存储)_                        | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 项目级 CI 安全文件 _(文件系统)_   | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 项目级 CI 安全文件 _(对象存储)_ | 使用 API/受管的 Geo[^object-storage-provider-replication]           | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 事件指标图像 _(文件系统)_          | 使用 API/受管的 Geo                         | SHA256 校验和               |
| Blob                 | 事件指标图像 _(对象存储)_       | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 告警指标图像 _(文件系统)_             | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 告警指标图像 _(对象存储)_          | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | 依赖代理镜像 _(文件系统)_         | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 依赖代理镜像 _(对象存储)_      | 使用 API/受管的 Geo[^object-storage-provider-replication]            | SHA256 校验和[^object-storage-verification-note]  |
| Blob                 | Packages NuGet 符号 _(文件系统)_      |  使用 API 的 Geo                                   | SHA256 校验和 |
| Blob                 | Packages NuGet 符号 _(对象存储)_              |  使用 API/受管的 Geo[^object-storage-provider-replication]                           | SHA256 校验和[^object-storage-verification-note] |
| 容器仓库 | 容器镜像仓库 _(文件系统)_              | 使用 API/Docker API 的 Geo                      | SHA256 校验和               |
| 容器仓库 | 容器镜像仓库 _(对象存储)_           | 使用 API/受管/Docker API 的 Geo[^object-storage-provider-replication] | SHA256 校验和[^object-storage-verification-note]  |

[^replication-note]: Redis 复制可作为使用 Redis sentinel 的 HA 的一部分。它不用于 Geo 站点之间。
[^object-storage-provider-replication]: 对象存储复制可由 Geo 执行，也可由您的对象存储提供商/设备的原生复制功能执行。
[^object-storage-verification-note]: 有关功能标志 `geo_object_storage_verification`（默认启用）的信息，请参阅[对象存储验证](object_storage.md#object-storage-verification)。

<a id="git-repositories"></a>

### Git 代码仓库

一个极狐GitLab 实例可以有一个或多个代码仓库分片。每个分片都有一个 Gitaly 实例，负责允许访问和操作本地存储的 Git 代码仓库。它可以运行在：

- 只有单个磁盘的机器上。
- 有多个磁盘挂载为单个挂载点（例如使用 RAID 阵列）的机器上。
- 使用 LVM 的机器上。

极狐GitLab 不需要特殊的文件系统，可以与挂载的存储设备配合使用。但是，使用远程文件系统时可能存在性能限制和一致性问题。

Geo 会在 Gitaly 中触发垃圾回收，以在 Geo 从站点上对复刻的代码仓库进行去重。

通信由 Gitaly gRPC API 完成，有三种可能的同步方式：

- 使用常规 Git clone/fetch 从一个 Geo 站点到另一个 Geo 站点（使用特殊认证）。
- 使用代码仓库快照（用于第一种方法失败或代码仓库损坏时）。
- 从**管理**区域手动触发（结合了其他列出的可能方式）。

每个项目最多可以有 3 个不同的代码仓库：

- 项目代码仓库，用于存储源代码。
- Wiki 代码仓库，用于存储 Wiki 内容。
- 设计代码仓库，用于索引设计产物（资源实际存储在 LFS 中）。

它们都位于同一分片中，并共享相同的基础名称，在 Wiki 和设计代码仓库的情况下分别带有 `-wiki` 和 `-design` 后缀。

除此之外，还有代码片段代码仓库。它们可以连接到项目或某个特定用户。两种类型都会同步到从站点。

<a id="container-repositories"></a>

### 容器仓库

容器仓库存储在容器镜像仓库中。它们是极狐GitLab 特有的概念，构建在作为数据存储的容器镜像仓库之上。

<a id="blobs"></a>

### Blob

极狐GitLab 将文件和 Blob（例如议题附件或 LFS 对象）存储到以下位置之一：

- 特定位置的文件系统。
- [对象存储](../../object_storage.md)解决方案。对象存储解决方案可以是：
  - 基于云的，例如 Amazon S3 和 Google Cloud Storage。
  - 自托管的 S3 兼容对象存储。
  - 暴露对象存储兼容 API 的存储设备。

当使用文件系统存储而非对象存储时，如果使用多个节点运行极狐GitLab，请使用网络挂载的文件系统。

关于复制和验证：

- 我们使用内部 API 请求传输文件和 Blob。
- 使用对象存储时，您可以：
  - 使用云提供商的复制功能。
  - 让极狐GitLab 为您复制。

<a id="databases"></a>

### 数据库

极狐GitLab 依赖存储在多个数据库中的数据，用于不同的用例。PostgreSQL 是 Web 界面中用户生成内容（例如议题内容、评论以及权限和凭据）的唯一事实来源。

PostgreSQL 还可以保存一定程度的缓存数据，例如 HTML 渲染的 Markdown 和缓存的合并请求差异。这也可以配置为卸载到对象存储。

我们使用 PostgreSQL 自身的复制功能将数据从主站点复制到从站点。

我们使用 Redis 既作为缓存存储，也用于保存后台作业系统的持久数据。由于这两种用例的数据都专属于同一个 Geo 站点，我们不在站点之间复制这些数据。

Elasticsearch 是用于高级搜索的可选数据库。它可以改进源代码级别以及议题、合并请求和讨论中用户生成内容的搜索。Geo 不支持 Elasticsearch。故障转移后，请[恢复高级搜索的数据](../disaster_recovery/planned_failover.md#recover-data-for-advanced-search)。

<a id="replicated-data-types"></a>

## 已复制的数据类型

某些数据类型的复制功能受默认启用的功能标志控制。这些功能标志无法按项目启用或禁用，建议在生产环境中使用。[有权访问 GitLab Rails 控制台的极狐GitLab 管理员](../../feature_flags/_index.md)可以选择为您的实例禁用它们。您可以在下表的备注列中找到每种数据类型的功能标志名称。

> [!warning]
> 不在此列表中，或文档中说明未复制的功能，
> 不会复制到从站点。如果未手动复制这些功能的数据就进行故障转移，
> 会导致数据丢失。
> 要在从站点上使用这些功能，或成功执行故障转移，
> 您必须使用其他方式复制其数据。

| 功能                                                                                                               | 已复制                                                                    | 已验证                                                                      | 极狐GitLab 管理的对象存储复制                                       | 极狐GitLab 管理的对象存储验证                                      | 备注 |
|:----------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------|:------------------------------------------------------------------------------|:--------------------------------------------------------------------------------|:--------------------------------------------------------------------------------|:------|
| [PostgreSQL 中的应用数据](../../postgresql/_index.md)                                                           | {{< yes >}}                                                                 | {{< yes >}}                                                                 | 不适用                                                                  | 不适用                                                                  | 无  |
| [项目代码仓库](../../../user/project/repository/_index.md)                                                       | {{< yes >}}                                                                 | {{< yes >}}                                                                 | 不适用                                                                  | 不适用                                                                  | 复制受以下功能标志控制： `geo_project_repository_replication`，默认启用。<br /><br /> 所有项目，包括[已归档项目](../../../user/project/working_with_projects.md#archive-a-project)，都会被复制。 |
| [项目 Wiki 代码仓库](../../../user/project/wiki/_index.md)                                                        | {{< yes >}}                                                    | {{< yes >}}                                                    | 不适用                                                                  | 不适用                                                                  | 复制受以下功能标志控制： `geo_project_wiki_repository_replication`，默认启用。 |
| [群组 Wiki 代码仓库](../../../user/project/wiki/group.md)                                                          | {{< yes >}}                                                                       | {{< yes >}}                                                                       | 不适用                                                                  | 不适用                                                                  | 复制受以下功能标志控制： `geo_group_wiki_repository_replication`，默认启用。 |
| [用户上传内容](../../uploads.md)                                                                                           | {{< yes >}}                                                                 | {{< yes >}}                                                                 | {{< yes >}}                                                                        | {{< yes >}}[^object-storage-verification]                                                      | 复制受以下功能标志控制： `geo_upload_replication`，默认启用。 |
| [LFS 对象](../../lfs/_index.md)                                                                                    | {{< yes >}}                                                                   | {{< yes >}}                                                                   | {{< yes >}}                                                                     | {{< yes >}}[^object-storage-verification]                                                        | 复制受以下功能标志控制： `geo_lfs_object_replication`，默认启用。 |
| [代码片段](../../../user/snippets.md)                                                                        | {{< yes >}}                                                                 | {{< yes >}}                                                                 | 不适用                                                                  | 不适用                                                                  | 复制受以下功能标志控制： `geo_snippet_repository_replication`，默认启用。包括个人代码片段和项目代码片段。 |
| [CI 作业产物](../../../ci/jobs/job_artifacts.md)                                                              | {{< yes >}}                                                                 | {{< yes >}}                                                                | {{< yes >}}                                                                     | {{< yes >}}[^object-storage-verification]                                                          | 复制受以下功能标志控制： `geo_job_artifact_replication`，默认启用。在主站点上，除非 `geo_job_artifact_force_primary_checksumming` 也被禁用，否则校验和计算会继续。请参阅[启用或禁用复制](#enable-or-disable-replication-for-some-data-types)。 |
| 流水线产物                                                                                                 | {{< yes >}}                                                                      | {{< yes >}}                                                                      | {{< yes >}}                                                                             | {{< yes >}}[^object-storage-verification]                                                          | 复制受以下功能标志控制： `geo_pipeline_artifact_replication`，默认启用。在流水线完成后保留额外的产物。 |
| [项目级 CI 安全文件](../../../ci/secure_files/_index.md)                    | {{< yes >}}                                                                      | {{< yes >}}                                                                      | {{< yes >}}                                                                       | {{< yes >}}[^object-storage-verification]                                                                | 复制受以下功能标志控制： `geo_ci_secure_file_replication`，默认启用。 |
| [容器镜像仓库](../../packages/container_registry.md)                                                            | {{< yes >}}                                                          | {{< yes >}}                                                                       | {{< yes >}}                                                            | {{< yes >}}                                                                         | 复制受以下功能标志控制： `geo_container_repository_replication`，默认启用。请参阅[说明](container_registry.md)设置容器镜像仓库复制。 |
| [Terraform 模块仓库](../../../user/packages/terraform_module_registry/_index.md)                                | {{< yes >}}                                                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                             | {{< yes >}}[^object-storage-verification]                                                                 | 复制受以下功能标志控制： `geo_package_file_replication`，默认启用。 |
| [项目设计代码仓库](../../../user/project/issues/design_management.md)                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                       | 不适用                                                                 | 不适用                                                                 | 复制受以下功能标志控制： `geo_design_management_repository_replication`，默认启用。设计还需要复制 LFS 对象和上传内容。 |
| [软件包仓库](../../../user/packages/package_registry/_index.md)                                                  | {{< yes >}}                                                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                         | {{< yes >}}[^object-storage-verification]                                                                | 复制受以下功能标志控制： `geo_package_file_replication`，默认启用。 |
| [Packages Helm 元数据缓存](../../../user/packages/helm_repository/_index.md)                                      | {{< yes >}}                                                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                              | {{< yes >}}                                                                                               | 复制受以下功能标志控制： `geo_packages_helm_metadata_cache_replication`，默认启用。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/219409)于极狐GitLab 18.10。 |
| [版本化 Terraform 状态](../../terraform_state.md)                                                                 | {{< yes >}}                                                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                              | {{< yes >}}[^object-storage-verification]                                                                 | 复制受以下功能标志控制： `geo_terraform_state_version_replication`，默认启用。 |
| [外部合并请求差异](../../merge_request_diffs.md)                                                          | {{< yes >}}                                                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                              | {{< yes >}}[^object-storage-verification]                                                                 | 复制受以下功能标志控制： `geo_merge_request_diff_replication`，默认启用。 |
| [Pages](../../pages/_index.md)                                                                                  | {{< yes >}}                                                                          | {{< yes >}}                                                                       | {{< yes >}}                                                                             | {{< yes >}}[^object-storage-verification]                                                               | 复制受以下功能标志控制： `geo_pages_deployment_replication`，默认启用。 |
| [事件指标图像](../../../operations/incident_management/incidents.md#metrics)                                | {{< yes >}}                                                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                         | {{< yes >}}[^object-storage-verification]                                                                 | 复制和验证通过上传内容数据类型处理。 |
| [告警指标图像](../../../operations/incident_management/alerts.md#metrics-tab)                                  | {{< yes >}}                                                                       | {{< yes >}}                                                                       | {{< yes >}}                                                                         | {{< yes >}}[^object-storage-verification]                                                                 | 复制和验证通过上传内容数据类型处理。 |
| [依赖代理镜像](../../../user/packages/dependency_proxy/_index.md)                                           | {{< yes >}}                                                       | {{< yes >}}                                                                           | {{< yes >}}                                                                           | {{< yes >}}[^object-storage-verification]                                                                 | 复制受以下功能标志控制： `geo_dependency_proxy_blob_replication` 和 `geo_dependency_proxy_manifest_replication`，默认启用。 |
| [Packages NuGet 符号](../../../user/packages/nuget_repository/_index.md#symbol-packages)                             | {{< yes >}}                                                                  | {{< yes >}}                                                                      | {{< yes >}}                                                                           | {{< yes >}}[^object-storage-verification]                                               | 复制受以下功能标志控制： `geo_packages_nuget_symbol_replication`，默认启用。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/422929)于极狐GitLab 18.10。 |
| Packages Debian ProjectComponentFile                                                                                  | {{< yes >}}                                                                   | {{< yes >}}                                                                      | {{< yes >}}                                                                        | {{< yes >}}                                                                        | 受以下功能标志控制： `geo_packages_debian_project_component_file_replication`，默认禁用。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/333611)于极狐GitLab 19.1。 |

[^object-storage-verification]: 有关功能标志 `geo_object_storage_verification`（默认启用）的信息，请参阅[对象存储验证](object_storage.md#object-storage-verification)。

<a id="enable-or-disable-replication-for-some-data-types"></a>

### 启用或禁用复制（针对某些数据类型）

要禁用，例如软件包文件复制：

```ruby
Feature.disable(:geo_package_file_replication)
```

要启用，例如软件包文件复制：

```ruby
Feature.enable(:geo_package_file_replication)
```

禁用 `geo_<replicable>_replication` 标志会停止从站点上的复制和验证。在主站点上，只要相应的 `geo_<replicable>_force_primary_checksumming` 标志处于启用状态（默认），校验和计算就会继续。要同时停止主站点上的校验和计算，请禁用这两个标志：

```ruby
Feature.disable(:geo_package_file_replication)
Feature.disable(:geo_package_file_force_primary_checksumming)
```

<a id="data-types-not-replicated"></a>

## 未复制的数据类型

Geo 不会复制以下功能的数据：

| 功能                                                                                             | 原因                                                                                                                                    | 跟踪议题 |
|:----------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|:---------------|
| [服务端 Git 钩子](../../server_hooks.md)                                                      | 当前实现复杂、客户兴趣低，以及有钩子的替代方案。                                      | [史诗 1867](https://gitlab.com/groups/gitlab-org/-/work_items/1867) |
| [Elasticsearch](../../../integration/advanced_search/elasticsearch.md)                              | 需要进一步的产品探索，且 Elasticsearch (ES) 集群可以重建。从站点使用与主站点相同的 ES 集群。 | [议题 1186](https://gitlab.com/gitlab-org/gitlab/-/work_items/1186) |
| [精确代码搜索 (Zoekt)](../../../integration/zoekt/_index.md)                                   | 无                                                                                                                                      | [议题 509597](https://gitlab.com/gitlab-org/gitlab/-/work_items/509597) |
| [漏洞导出](../../../user/application_security/vulnerability_report/_index.md#exporting) | 导出是临时的，且包含敏感信息。它们可以按需重新生成。                                               | [史诗 3111](https://gitlab.com/groups/gitlab-org/-/work_items/3111) |
| Packages NPM 元数据缓存                                                                         | 不会显著改善灾难恢复能力，也不会改善从站点的响应时间。                                           | [议题 408278](https://gitlab.com/gitlab-org/gitlab/-/work_items/408278) |
| Packages Debian GroupComponentFile                                                                  | 无                                                                                                                                      | [议题 556945](https://gitlab.com/gitlab-org/gitlab/-/work_items/556945) |
| Packages Debian GroupDistribution                                                                   | 无                                                                                                                                      | [议题 556947](https://gitlab.com/gitlab-org/gitlab/-/work_items/556947) |
| Packages Debian ProjectDistribution                                                                 | 无                                                                                                                                      | [议题 556946](https://gitlab.com/gitlab-org/gitlab/-/work_items/556946) |
| Packages RPM RepositoryFile                                                                         | 无                                                                                                                                      | [议题 379055](https://gitlab.com/gitlab-org/gitlab/-/work_items/379055) |
| VirtualRegistries Maven Cache Entry                                                                 | 无                                                                                                                                      | [议题 473033](https://gitlab.com/gitlab-org/gitlab/-/work_items/473033) |
| SBOM 漏洞扫描数据                                                                        | 数据是临时的且生命周期短，对从站点的灾难恢复能力影响有限。                      | [议题 398199](https://gitlab.com/gitlab-org/gitlab/-/work_items/398199) |
