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

Geo 数据类型是指一个或多个极狐GitLab 功能为存储相关信息而需要的特定数据类别。

为了使用 Geo 复制这些功能产生的数据，我们采用多种策略来访问、传输和验证这些数据。

<a id="data-types"></a>

## 数据类型

我们区分以下不同的数据类型：

- [Git 代码仓库](#git-repositories)
- [容器仓库](#container-repositories)
- [Blob](#blobs)
- [数据库](#databases)

请参阅下面的列表，了解我们复制的每个功能或组件、其对应的数据类型、复制和验证方法：

| 类型                 | 功能 / 组件                             | 复制方法                                   | 验证方法           |
|:---------------------|:------------------------------------------------|:---------------------------------------------|:------------------------------|
| 数据库             | PostgreSQL 中的应用程序数据                  | 原生                                       | 原生                        |
| 数据库             | Redis                                           | 不适用 <sup>1</sup>                  | 不适用                |
| 数据库             | 高级搜索（Elasticsearch 或 OpenSearch）   | 原生                                       | 原生                        |
| 数据库             | 精确代码搜索（Zoekt）                       | 原生                                       | 原生                        |
| 数据库             | SSH 公钥                                 | PostgreSQL 复制                       | PostgreSQL 复制        |
| Git                  | 项目代码仓库                              | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 项目 Wiki 代码仓库                         | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 项目设计代码仓库                      | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 项目代码片段                                | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 个人代码片段                               | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Git                  | 群组 Wiki 代码仓库                           | 使用 Gitaly 的 Geo                              | Gitaly 校验和               |
| Blob                 | 用户上传 _(文件系统)_                    | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 用户上传 _(对象存储)_                 | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | LFS 对象 _(文件系统)_                     | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | LFS 对象 _(对象存储)_                  | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | CI 作业产物 _(文件系统)_                | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | CI 作业产物 _(对象存储)_             | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 已归档的 CI 构建日志 _(文件系统)_        | 使用 API 的 Geo                                 | 未实现             |
| Blob                 | 已归档的 CI 构建日志 _(对象存储)_     | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 容器镜像仓库 _(文件系统)_              | 使用 API/Docker API 的 Geo                      | SHA256 校验和               |
| Blob                 | 容器镜像仓库 _(对象存储)_           | 使用 API/受管/Docker API 的 Geo <sup>2</sup>     | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 软件包仓库 _(文件系统)_                | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 软件包仓库 _(对象存储)_             | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 软件包 Helm 元数据缓存 _(文件系统)_    | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 软件包 Helm 元数据缓存 _(对象存储)_ | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | Terraform 模块仓库 _(文件系统)_       | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | Terraform 模块仓库 _(对象存储)_    | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 版本化 Terraform 状态 _(文件系统)_       | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 版本化 Terraform 状态 _(对象存储)_    | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 外部合并请求差异 _(文件系统)_    | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 外部合并请求差异 _(对象存储)_ | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 流水线产物 _(文件系统)_              | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 流水线产物 _(对象存储)_           | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | Pages _(文件系统)_                           | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | Pages _(对象存储)_                        | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | CI 安全文件 _(文件系统)_                 | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | CI 安全文件 _(对象存储)_              | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 事件指标图片 _(文件系统)_          | 使用 API/受管的 Geo                             | SHA256 校验和               |
| Blob                 | 事件指标图片 _(对象存储)_       | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 告警指标图片 _(文件系统)_             | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 告警指标图片 _(对象存储)_          | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 依赖代理镜像 _(文件系统)_         | 使用 API 的 Geo                                 | SHA256 校验和               |
| Blob                 | 依赖代理镜像 _(对象存储)_      | 使用 API/受管的 Geo <sup>2</sup>                | SHA256 校验和 <sup>3</sup>  |
| Blob                 | 软件包 NuGet 符号 _(文件系统)_      |  使用 API 的 Geo                                   | SHA256 校验和 |
| Blob                 | 软件包 NuGet 符号 _(对象存储)_              |  使用 API/Docker API 的 Geo                           | SHA256 校验和 <sup>3</sup> |
| 容器仓库 | 容器镜像仓库 _(文件系统)_              | 使用 API/Docker API 的 Geo                      | SHA256 校验和               |
| 容器仓库 | 容器镜像仓库 _(对象存储)_           | 使用 API/受管/Docker API 的 Geo <sup>2</sup>     | SHA256 校验和 <sup>3</sup>  |

**脚注**：

1. Redis 复制可作为使用 Redis Sentinel 的高可用性方案的一部分。它不用于 Geo 站点之间。
1. 对象存储复制可以由 Geo 或您的对象存储提供商/设备原生复制功能执行。
1. 对象存储验证在极狐GitLab 16.4 中[引入](https://gitlab.com/groups/gitlab-org/-/work_items/8056)，[带有一个功能标志](../../feature_flags/_index.md)，名为 `geo_object_storage_verification`。默认已启用。

<a id="git-repositories"></a>

### Git 代码仓库

一个极狐GitLab 实例可以有一个或多个代码仓库分片。每个分片都有一个 Gitaly 实例，负责允许访问和操作本地存储的 Git 代码仓库。它可以运行在：

- 具有单个磁盘的机器上。
- 具有多个磁盘挂载为单个挂载点（如 RAID 阵列）的机器上。
- 使用 LVM 的机器上。

极狐GitLab 不需要特殊的文件系统，可以与挂载的存储设备一起使用。但是，使用远程文件系统时可能存在性能限制和一致性问题。

Geo 会在 Gitaly 中触发垃圾回收，以对 Geo 从站点上的分叉代码仓库进行去重。

Gitaly gRPC API 负责通信，有三种可能的同步方式：

- 使用常规 Git clone/fetch 从一个 Geo 站点到另一个站点（使用特殊身份验证）。
- 使用代码仓库快照（用于第一种方法失败或代码仓库损坏时）。
- 从 **管理员** 区域手动触发（结合了其他列出的可能方式）。

每个项目最多可以有 3 个不同的代码仓库：

- 项目代码仓库，存储源代码。
- Wiki 代码仓库，存储 Wiki 内容。
- 设计代码仓库，设计产物在此建立索引（资源实际存储在 LFS 中）。

它们都位于同一个分片中，并共享相同的基本名称，Wiki 和设计代码仓库分别带有 `-wiki` 和 `-design` 后缀。

除此之外，还有代码片段仓库。它们可以连接到项目或某个特定用户。两种类型都会同步到从站点。

<a id="container-repositories"></a>

### 容器仓库

容器仓库存储在容器镜像仓库中。它们是极狐GitLab 特定的概念，构建在容器镜像仓库之上作为数据存储。

<a id="blobs"></a>

### Blob

极狐GitLab 将文件和 Blob（如议题附件或 LFS 对象）存储到：

- 特定位置的文件系统中。
- [对象存储](../../object_storage.md) 解决方案。对象存储解决方案可以是：
  - 基于云的，如 Amazon S3 和 Google Cloud Storage。
  - 自托管的兼容 S3 的对象存储。
  - 提供兼容对象存储 API 的存储设备。

当使用文件系统存储而不是对象存储时，在多个节点上运行极狐GitLab 时，请使用网络挂载的文件系统。

关于复制和验证：

- 我们使用内部 API 请求传输文件和 Blob。
- 使用对象存储时，您可以：
  - 使用云提供商的复制功能。
  - 让极狐GitLab 为您复制。

<a id="databases"></a>

### 数据库

极狐GitLab 依赖存储在多个数据库中的数据，用于不同的用例。PostgreSQL 是 Web 界面中用户生成内容（如议题内容、评论以及权限和凭据）的唯一事实来源。

PostgreSQL 还可以保存一些缓存数据，如 HTML 渲染的 Markdown 和缓存的合并请求差异。这也可以配置为卸载到对象存储。

我们使用 PostgreSQL 自身的复制功能将数据从主站点复制到从站点。

我们将 Redis 用作缓存存储，并为后台作业系统保存持久数据。由于这两种用例的数据都专属于同一个 Geo 站点，我们不会在站点之间复制它们。

Elasticsearch 是用于高级搜索的可选数据库。它可以改进源代码级别以及议题、合并请求和讨论中用户生成内容的搜索。Geo 不支持 Elasticsearch。

<a id="replicated-data-types"></a>

## 复制的数据类型

<a id="replicated-data-types-behind-a-feature-flag"></a>

### 受功能标志控制的复制的数据类型

> [!flag]
> 此功能的可用性由功能标志控制。

<a id="enable-or-disable-replication-for-some-data-types"></a>

#### 启用或禁用复制（适用于某些数据类型）

某些数据类型的复制是在默认启用的功能标志后面发布的。
[有权访问 GitLab Rails 控制台的极狐GitLab 管理员](../../feature_flags/_index.md) 可以选择为您的实例禁用它。您可以在下表的备注列中找到每种数据类型的功能标志名称。

要禁用，例如软件包文件复制：

```ruby
Feature.disable(:geo_package_file_replication)
```

要启用，例如软件包文件复制：

```ruby
Feature.enable(:geo_package_file_replication)
```

> [!warning]
> 不在此列表中的功能，或 **已复制** 列中为 **否** 的功能，
> 不会复制到从站点。如果不手动复制这些功能的数据就进行故障转移，
> 将导致数据丢失。
> 要在从站点上使用这些功能，或成功执行故障转移，
> 您必须使用其他方式复制其数据。

| 功能                                                                                                               | 已复制（在极狐GitLab 版本中添加）                                          | 已验证（在极狐GitLab 版本中添加）                                            | 极狐GitLab 管理的对象存储复制（在极狐GitLab 版本中添加）             | 极狐GitLab 管理的对象存储验证（在极狐GitLab 版本中添加）            | 备注 |
|:----------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------|:------------------------------------------------------------------------------|:--------------------------------------------------------------------------------|:--------------------------------------------------------------------------------|:------|
| [PostgreSQL 中的应用程序数据](../../postgresql/_index.md)                                                           | **是** (10.2)                                                                | **是** (10.2)                                                                | 不适用                                                                  | 不适用                                                                  |       |
| [项目代码仓库](../../../user/project/repository/_index.md)                                                       | **是** (10.2)                                                                | **是** (10.7)                                                                | 不适用                                                                  | 不适用                                                                  | 在 16.2 中迁移到自助服务框架。有关更多详细信息，请参阅 GitLab 议题 [#367925](https://gitlab.com/gitlab-org/gitlab/-/issues/367925)。<br /><br />受功能标志 `geo_project_repository_replication` 控制，在 (16.3) 中默认启用。<br /><br /> 所有项目，包括[已归档项目](../../../user/project/working_with_projects.md#archive-a-project)，都会被复制。 |
| [项目 Wiki 代码仓库](../../../user/project/wiki/_index.md)                                                        | **是** (10.2)<sup>2</sup>                                                    | **是** (10.7)<sup>2</sup>                                                    | 不适用                                                                  | 不适用                                                                  | 在 15.11 中迁移到自助服务框架。有关更多详细信息，请参阅 GitLab 议题 [#367925](https://gitlab.com/gitlab-org/gitlab/-/issues/367925)。<br /><br />受功能标志 `geo_project_wiki_repository_replication` 控制，在 (15.11) 中默认启用。 |
| [群组 Wiki 代码仓库](../../../user/project/wiki/group.md)                                                          | [**是** (13.10)](https://gitlab.com/gitlab-org/gitlab/-/issues/208147)       | [**是** (16.3)](https://gitlab.com/gitlab-org/gitlab/-/issues/323897)        | 不适用                                                                  | 不适用                                                                  | 受功能标志 `geo_group_wiki_repository_replication` 控制，默认启用。 |
| [用户上传](../../uploads.md)                                                                                           | **是** (10.2)                                                                | **是** (14.6)                                                                | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 复制受功能标志 `geo_upload_replication` 控制，默认启用。验证曾受功能标志 `geo_upload_verification` 控制，已在 14.8 中移除。 |
| [LFS 对象](../../lfs/_index.md)                                                                                     | **是** (10.2)                                                                | **是** (14.6)                                                                | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 极狐GitLab 11.11.x 和 12.0.x 版本受[一个阻止任何新 LFS 对象复制的错误](https://gitlab.com/gitlab-org/gitlab/-/issues/32696)影响。<br /><br />复制受功能标志 `geo_lfs_object_replication` 控制，默认启用。验证曾受功能标志 `geo_lfs_object_verification` 控制，已在 14.7 中移除。 |
| [个人代码片段](../../../user/snippets.md)                                                                        | **是** (10.2)                                                                | **是** (10.2)                                                                | 不适用                                                                  | 不适用                                                                  |       |
| [项目代码片段](../../../user/snippets.md)                                                                         | **是** (10.2)                                                                | **是** (10.2)                                                                | 不适用                                                                  | 不适用                                                                  |       |
| [CI 作业产物](../../../ci/jobs/job_artifacts.md)                                                                 | **是** (10.4)                                                                | **是** (14.10)                                                               | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 验证受功能标志 `geo_job_artifact_replication` 控制，在 14.10 中默认启用。 |
| [流水线产物](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/models/ci/pipeline_artifact.rb)        | [**是** (13.11)](https://gitlab.com/gitlab-org/gitlab/-/issues/238464)       | [**是** (13.11)](https://gitlab.com/gitlab-org/gitlab/-/issues/238464)       | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 在流水线完成后持久化附加产物。 |
| [CI 安全文件](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/models/ci/secure_file.rb)                    | [**是** (15.3)](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/91430) | [**是** (15.3)](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/91430) | [**是** (15.3)](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/91430)   | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 验证受功能标志 `geo_ci_secure_file_replication` 控制，在 15.3 中默认启用。 |
| [容器镜像仓库](../../packages/container_registry.md)                                                            | **是** (12.3)<sup>1</sup>                                                    | **是** (15.10)                                                               | **是** (12.3)<sup>1</sup>                                                      | **是** (15.10)                                                                 | 请参阅[说明](container_registry.md)以设置容器镜像仓库复制。 |
| [Terraform 模块仓库](../../../user/packages/terraform_module_registry/_index.md)                                | **是** (14.0)                                                                | **是** (14.0)                                                                | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 受功能标志 `geo_package_file_replication` 控制，默认启用。 |
| [项目设计代码仓库](../../../user/project/issues/design_management.md)                                       | **是** (12.7)                                                                | **是** (16.1)                                                                | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 设计还需要复制 LFS 对象和上传。 |
| [软件包仓库](../../../user/packages/package_registry/_index.md)                                                  | **是** (13.2)                                                                | **是** (13.10)                                                               | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 受功能标志 `geo_package_file_replication` 控制，默认启用。 |
| [软件包 Helm 元数据缓存](../../../user/packages/helm_repository/_index.md)                                      | [**是** (18.10)](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/219409) | [**是** (18.10)](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/219409) | [**是** (18.10)](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/219409) | [**是** (18.10)](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/219409) | 受功能标志 `geo_packages_helm_metadata_cache_replication` 控制，在 18.10 中默认启用。 |
| [版本化 Terraform 状态](../../terraform_state.md)                                                                 | **是** (13.5)                                                                | **是** (13.12)                                                               | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 复制受功能标志 `geo_terraform_state_version_replication` 控制，默认启用。验证曾受功能标志 `geo_terraform_state_version_verification` 控制，该标志已在 14.0 中移除。 |
| [外部合并请求差异](../../merge_request_diffs.md)                                                          | **是** (13.5)                                                                | **是** (14.6)                                                                | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 复制受功能标志 `geo_merge_request_diff_replication` 控制，默认启用。验证曾受功能标志 `geo_merge_request_diff_verification` 控制，已在 14.7 中移除。 |
| [版本化代码片段](../../../user/snippets.md#versioned-snippets)                                                    | [**是** (13.7)](https://gitlab.com/groups/gitlab-org/-/work_items/2809)           | [**是** (14.2)](https://gitlab.com/groups/gitlab-org/-/work_items/2810)           | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 验证在 13.11 中通过功能标志 `geo_snippet_repository_verification` 实现，该功能标志在 14.2 中移除。 |
| [Pages](../../pages/_index.md)                                                                                  | [**是** (14.3)](https://gitlab.com/groups/gitlab-org/-/work_items/589)            | **是** (14.6)                                                                | [**是** (15.1)](https://gitlab.com/groups/gitlab-org/-/work_items/5551)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 受功能标志 `geo_pages_deployment_replication` 控制，默认启用。验证曾受功能标志 `geo_pages_deployment_verification` 控制，已在 14.7 中移除。 |
| [项目级 CI 安全文件](../../../ci/secure_files/_index.md)                                                       | **是** (15.3)                                                                | **是** (15.3)                                                                | **是** (15.3)                                                                  | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) |       |
| [事件指标图片](../../../operations/incident_management/incidents.md#metrics)                                | **是** (15.5)                                                                | **是** (15.5)                                                                | **是** (15.5)                                                                  | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 复制/验证通过上传数据类型处理。 |
| [告警指标图片](../../../operations/incident_management/alerts.md#metrics-tab)                                  | **是** (15.5)                                                                | **是** (15.5)                                                                | **是** (15.5)                                                                  | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 复制/验证通过上传数据类型处理。 |
| [服务端 Git 钩子](../../server_hooks.md)                                                                        | [未计划](https://gitlab.com/groups/gitlab-org/-/work_items/1867)              | 否                                                                            | 不适用                                                                  | 不适用                                                                  | 由于当前实现复杂性、客户兴趣低以及钩子替代方案的可用性，未计划。 |
| [Elasticsearch](../../../integration/advanced_search/elasticsearch.md)                                    | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/1186)             | 否                                                                            | 否                                                                              | 否                                                                              | 未计划，因为需要进一步的产品发现，并且 Elasticsearch (ES) 集群可以重建。从站点使用与主站点相同的 ES 集群。 |
| [依赖代理镜像](../../../user/packages/dependency_proxy/_index.md)                                           | [**是** (15.7)](https://gitlab.com/groups/gitlab-org/-/work_items/8833)           | [**是** (15.7)](https://gitlab.com/groups/gitlab-org/-/work_items/8833)           | [**是** (15.7)](https://gitlab.com/groups/gitlab-org/-/work_items/8833)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) |       |
| [软件包 NuGet 符号](../../../user/packages/nuget_repository/_index.md#symbol-packages)                                                                                                 | [**是** (18.10)](https://gitlab.com/gitlab-org/gitlab/-/issues/422929)           | [**是** (18.10)](https://gitlab.com/gitlab-org/gitlab/-/issues/422929)           | [**是** (15.7)](https://gitlab.com/groups/gitlab-org/-/work_items/8833)             | [**是** (16.4)<sup>3</sup>](https://gitlab.com/groups/gitlab-org/-/work_items/8056) | 受功能标志 `geo_packages_nuget_symbol_replication` 控制，默认启用。   |
| [漏洞导出](../../../user/application_security/vulnerability_report/_index.md#exporting) | [未计划](https://gitlab.com/groups/gitlab-org/-/work_items/3111)              | 否                                                                            | 否                                                                              | 否                                                                              | 未计划，因为它们是临时且敏感的信息。它们可以按需重新生成。 |
| 软件包 NPM 元数据缓存                                                                                           | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/408278)           | 否                                                                            | 否                                                                              | 否                                                                              | 未计划，因为它不会显著改善灾难恢复能力或从站点的响应时间。 |
| 软件包 Debian GroupComponentFile                                                                                    | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/556945)           | 否                                                                            | 否                                                                              | 否                                                                              |       |
| 软件包 Debian ProjectComponentFile                                                                                  | [**是** (19.1)](https://gitlab.com/gitlab-org/gitlab/-/issues/333611)       | [**是** (19.1)](https://gitlab.com/gitlab-org/gitlab/-/issues/333611)       | [**是** (19.1)](https://gitlab.com/gitlab-org/gitlab/-/issues/333611)         | [**是** (19.1)](https://gitlab.com/gitlab-org/gitlab/-/issues/333611)         | 受功能标志 `geo_packages_debian_project_component_file_replication` 控制，默认禁用。 |
| 软件包 Debian GroupDistribution                                                                                     | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/556947)           | 否                                                                            | 否                                                                              | 否                                                                              |       |
| 软件包 Debian ProjectDistribution                                                                                   | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/556946)           | 否                                                                            | 否                                                                              | 否                                                                              |       |
| 软件包 RPM RepositoryFile                                                                                           | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/379055)           | 否                                                                            | 否                                                                              | 否                                                                              |       |
| VirtualRegistries Maven 缓存条目                                                                                   | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/473033)           | 否                                                                            | 否                                                                              | 否                                                                              |       |
| SBOM 漏洞扫描数据                                                                                           | [未计划](https://gitlab.com/gitlab-org/gitlab/-/issues/398199)           | 否                                                                            | 否                                                                              | 否                                                                              | 未计划，因为数据是临时的，生命周期短，对从站点的灾难恢复能力影响有限。 |

**脚注**：

1. 在 15.5 中迁移到自助服务框架。有关更多详细信息，请参阅 GitLab 议题 [#337436](https://gitlab.com/gitlab-org/gitlab/-/issues/337436)。
1. 在 15.11 中迁移到自助服务框架。受功能标志 `geo_project_wiki_repository_replication` 控制，默认启用。有关更多详细信息，请参阅 GitLab 议题 [#367925](https://gitlab.com/gitlab-org/gitlab/-/issues/367925)。
1. 对象存储验证在极狐GitLab 16.4 中[引入](https://gitlab.com/groups/gitlab-org/-/work_items/8056)，[带有一个功能标志](../../feature_flags/_index.md)，名为 `geo_object_storage_verification`。默认已启用。
