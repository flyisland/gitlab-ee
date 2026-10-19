---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 19 升级说明
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页包含极狐GitLab 19 的次要版本和补丁版本的升级信息。
请务必针对以下方面查看这些说明：

- 您的安装类型。
- 当前版本与目标版本之间的所有版本。

有关 Helm chart 安装的更多信息，请参阅
[Helm chart 10.0 升级说明](https://gitlab.cn/docs/charts/releases/10_0/)。

<a id="required-upgrade-stops"></a>

## 必需的升级停靠点

为了给实例管理员提供可预测的升级计划，
以下版本为必需的升级停靠点：

- `19.2`
- `19.5`
- `19.8`
- `19.11`

<a id="upgrade-notes-reference"></a>

## 升级说明参考

以下是极狐GitLab 每个次要版本的升级说明参考列表。
每个列表项都指向包含更多信息的特定章节。

标有安装方法的项目，如 `(Geo)` 或 `(Linux package)`，
仅适用于该方法。所有其他项目适用于所有安装方法。

<a id="upgrade-to-194"></a>

### 升级到 19.4

升级到极狐GitLab 19.4 之前，请查看以下内容：

- [19.4.0] - [使用 `SKIP_REPOSITORIES_PATHS` 的恢复操作会保留现有代码仓库](#restores-that-use-skip_repositories_paths-keep-existing-repositories)

<a id="upgrade-to-192"></a>

### 升级到 19.2

升级到极狐GitLab 19.2 之前，请查看以下内容：

- [19.2.0] - [极狐GitLab Duo 自部署版本 AI 网关 URL 在升级后被清除](#gitlab-duo-self-hosted-ai-gateway-urls-cleared-after-upgrade) (Linux package)
- [19.2.0] - [新群组要求合并请求 API 调用包含 SHA 参数](#new-groups-require-sha-parameter-for-merge-requests-api-calls)

<a id="upgrade-to-190"></a>

### 升级到 19.0

升级到极狐GitLab 19.0 之前，请查看以下内容：

- [19.0.0 - 19.0.1] - [容器镜像仓库元数据数据库在 prefer 模式下默认启用](#container-registry-metadata-database-enabled-by-default-in-prefer-mode) (Linux package, self-compiled)
- [19.0.0] - [容器镜像仓库 S3 存储驱动被 s3_v2 取代](#container-registry-s3-storage-driver-replaced-by-s3_v2) (Linux package, self-compiled)
- [19.0.0 - 19.1.0] - [Linux 软件包 RPM 安装中遗留的 `.agents` 和 `.claude` 目录](#orphaned-agents-and-claude-directories-on-linux-package-rpm-installs) (Linux package)
- [19.0.0] - [PostgreSQL 17 最低版本要求](#postgresql-17-minimum-requirement)
- [19.0.0] - [Linux 软件包停止支持 Ubuntu 20.04](#linux-package-support-for-ubuntu-2004-discontinued) (Linux package)
- [19.0.0] - [移除 Redis 6 支持](#redis-6-support-removed) (Linux package)
- [19.0.0] - [Mattermost 从 Linux 软件包中移除](#mattermost-removed-from-the-linux-package) (Linux package)
- [19.0.0] - [Linux 软件包停止支持 SUSE 发行版](#linux-package-support-for-suse-distributions-discontinued) (Linux package)
- [19.0.0] - [Spamcheck 从 Linux 软件包和 GitLab Helm chart 中移除](#spamcheck-removed-from-linux-package-and-gitlab-helm-chart) (Linux package, Helm chart)
- [19.0.0] - [NGINX Ingress 被 Gateway API 与 Envoy Gateway 取代](#nginx-ingress-replaced-by-gateway-api-with-envoy-gateway) (Helm chart)
- [19.0.0] - [内置的 PostgreSQL、Redis 和 MinIO 从 GitLab Helm chart 中移除](#bundled-postgresql-redis-and-minio-removed-from-gitlab-helm-chart) (Helm chart)
- [19.0.0 - 19.0.1] - [Geo 容器代码仓库同步静默跳过 OCI 镜像索引标签](#geo-container-repository-sync-silently-skips-oci-image-index-tags) (Geo)
- [16.0.0 - 19.0.1] - [项目为 `nil` 时 Geo 设计管理复制出现 `NoMethodError`](#geo-design-management-replication-nomethoderror-when-project-is-nil) (Geo)

<a id="upgrade-notes"></a>

## 升级说明

极狐GitLab 19 的具体升级说明。

<a id="restores-that-use-skip_repositories_paths-keep-existing-repositories"></a>

### 使用 `SKIP_REPOSITORIES_PATHS` 的恢复操作会保留现有代码仓库

- 影响：所有安装方法
- 受影响版本：19.4.0

在极狐GitLab 19.4 及更高版本中，当 `SKIP_REPOSITORIES_PATHS` 将代码仓库排除在恢复范围之外时，恢复操作会保留实例上已有的代码仓库。这适用于您在恢复时指定该选项，以及备份是使用该选项创建的情况，包括在早期版本上创建的备份，因为恢复操作也会从备份清单（`backup_information.yml`）中读取排除的路径。

以前，在这两种情况下，除非同时指定了 `REPOSITORIES_PATHS`，否则恢复操作会首先删除其恢复到的存储中的所有代码仓库。被排除的代码仓库也会随之被删除，并且由于它们也被排除在恢复本身之外，该备份无法将它们恢复。

完整恢复（既不应用 `REPOSITORIES_PATHS` 也不应用 `SKIP_REPOSITORIES_PATHS`）仍会删除不属于备份的代码仓库。

如果您的恢复流程依赖之前的行为来清除代码仓库，请改为执行完整恢复，或在恢复之前删除这些代码仓库。

有关更多信息，请参阅
[恢复特定代码仓库](../../administration/backup_restore/restore_gitlab.md#restore-specific-repositories)
和 [议题 610910](https://gitlab.com/gitlab-org/gitlab/-/issues/610910)。

<a id="gitlab-duo-self-hosted-ai-gateway-urls-cleared-after-upgrade"></a>

### 极狐GitLab Duo 自部署版本 AI 网关 URL 在升级后被清除

- 影响：Linux 软件包
- 受影响版本：19.2.0
- 修复版本：19.2.1

当实例直接升级到极狐GitLab 19.2.0 时，
极狐GitLab Duo 自部署版本服务端点设置可能被清除。
**管理区域** > **极狐GitLab Duo** > **配置** > **服务端点** 下的以下字段在升级后可能变为空：

- **本地 AI 网关 URL**
- **极狐GitLab Duo Agent Platform 服务的本地 URL**

其他相关设置也可能恢复为默认值。
极狐GitLab Duo 自部署版本功能将停止工作，直到手动重新输入 URL。

升级到极狐GitLab 19.2.1 或更高版本时不会出现此问题。

如果您已升级到 19.2.0 并受到影响，请在 **管理区域** > **极狐GitLab Duo** > **配置** > **服务端点** 中恢复正确的
AI 网关端点 URL
并保存更改。
有关更多信息，请参阅 [议题 606458](https://gitlab.com/gitlab-org/gitlab/-/work_items/606458)。

<a id="new-groups-require-sha-parameter-for-merge-requests-api-calls"></a>

### 新群组要求合并请求 API 调用包含 SHA 参数

- 影响：所有安装方法
- 受影响版本：19.2.0

极狐GitLab 19.2 在群组和实例级别引入了 `require_sha_for_merge` 设置。
启用后，[合并合并请求](../../api/merge_requests.md#merge-a-merge-request)
API 端点将拒绝不包含有效提交 `sha` 参数的调用。

升级到极狐GitLab 19.2 后创建的群组默认启用 `require_sha_for_merge`，
除非该设置被实例或祖先群组使用 `lock_require_sha_for_merge` 锁定。如果该设置被锁定，新群组将继承锁定的值。现有群组不受影响。

更新到 19.2 后，如果您的自动化或 API 客户端在调用合并端点时未包含 `sha` 参数，这些客户端对所有新群组的调用都将失败，除非您禁用该要求并锁定设置。

要为所有新群组禁用此要求，请通过 [应用程序设置 API](../../api/settings.md#available-settings) 将 `require_sha_for_merge` 设置为 `false` 并启用
`lock_require_sha_for_merge`。

<a id="container-registry-metadata-database-enabled-by-default-in-prefer-mode"></a>

### 容器镜像仓库元数据数据库在 prefer 模式下默认启用

- 影响：Linux 软件包，自编译
- 受影响版本：19.0.0, 19.0.1

在极狐GitLab 19.0 中，对于未在 `/etc/gitlab/gitlab.rb` 中显式设置 `registry['database']['enabled']` 的现有安装，容器镜像仓库元数据数据库默认为 `prefer` 模式。在 prefer 模式下，镜像仓库会尝试使用元数据数据库。如果现有镜像仓库数据尚未导入数据库，镜像仓库会在启动时回退到传统的文件系统元数据。

由于一个错误（[议题 600955](https://gitlab.com/gitlab-org/gitlab/-/work_items/600955)），
镜像仓库路由器在 prefer 回退检测运行之前被初始化。这导致所有 `/gitlab/v1/` 路由上出现空指针解引用 panic，当镜像仓库 UI 轮询群组级存储大小时导致 `HTTP 500` 错误。实际的 Docker 推送和拉取协议（`/v2/`）不受此错误影响。

该错误已在极狐GitLab 19.0.2 中修复，其中包含容器镜像仓库 `v4.40.1-gitlab`。

如果您正在运行 19.0.0 或 19.0.1，并在 `/var/log/gitlab/registry/current` 中看到 `runtime error: invalid memory address or nil pointer dereference` panic 反复出现，位于 `handlers.(*repositoryHandler).HandleGetRepository`，请应用以下变通方法：

1. 将以下内容添加到 `/etc/gitlab/gitlab.rb`：

   ```ruby
   registry['database'] = {
     'enabled' => false
   }
   ```

1. 重新配置并重启镜像仓库：

   ```shell
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart registry
   ```

升级到 19.0.2 或更高版本后，请移除该覆盖并重新配置以恢复默认行为。

有关更多信息，请参阅
[容器镜像仓库元数据数据库文档](../../administration/packages/container_registry_metadata_database.md)。

<a id="container-registry-s3-storage-driver-replaced-by-s3_v2"></a>

### 容器镜像仓库 S3 存储驱动被 s3_v2 取代

- 影响：Linux 软件包，自编译
- 受影响版本：19.0.0

在极狐GitLab 19.0 中，传统的 `s3` 容器镜像仓库存储驱动（AWS SDK v1）已被移除。
`s3` 和 `s3aws` 驱动名称现在是 `s3_v2` 驱动（AWS SDK v2）的别名。
由于之前的驱动名称仍然有效，从未重新配置过的实例在升级时也会迁移到 AWS SDK v2。

此更改影响两类安装：

- 使用 S3 兼容对象存储后端（如 Ceph RGW、MinIO 或 OVH S3）的安装。
- 使用 AWS S3 并限制出站网络流量的安装。
  有关更多信息，请参阅 [AWS S3 上的预签名 URL 主机名](#presigned-url-hostnames-on-aws-s3)。

`s3_v2` 驱动为非 AWS S3 兼容后端引入了两个破坏性更改：

- `regionendpoint` 需要包含协议方案的完整 URI。`s3_v2` 驱动要求
  `https://`（或 `http://`）出现在 `regionendpoint` 值中。像
  `storage.example.com` 这样的裸主机名不再有效，并会导致启动错误：

  ```plaintext
  endpoint rule error, Custom endpoint `storage.example.com` was not a valid URI
  ```

  更新您的配置以包含协议方案：

  ```ruby
  registry['storage'] = {
    's3_v2' => {
      'regionendpoint' => 'https://storage.example.com',
      # ...
    }
  }
  ```

- AWS SDK v2 默认发送增强校验和。`s3_v2` 驱动在上传时发送
  `x-amz-content-sha256` 和 CRC64NVME 校验和。Ceph RGW、较旧版本的 MinIO、
  OVH S3 和其他 S3 兼容后端可能会以 HTTP 400（`XAmzContentSHA256Mismatch`）拒绝这些请求。添加 `'checksum_disabled' => true` 以禁用此行为。

  `checksum_disabled` 设置仅在上传（`PutObject`）调用时抑制校验和。
  `DeleteObjects` 代码路径还会发送 CRC32 校验和标头，而部分 S3 兼容后端不支持该标头。如果您的后端拒绝此标头，即使将
  `checksum_disabled` 设置为 `true`，触发 blob 删除的镜像推送也会因 `MissingContentMD5` 或 `InvalidRequest` 错误而失败。

  要解决此问题，请将您的 S3 兼容存储后端升级到支持 CRC32 校验和标头的版本。有关所需的最低版本，请查阅您的存储提供商的文档。

  `gitlab.rb` 配置中不存在针对 `DeleteObjects` 代码路径的变通方法。
  有关更多信息，请参阅
  [议题 2309](https://gitlab.com/gitlab-org/container-registry/-/issues/2309)。

对于 Ceph RGW 和大多数 S3 兼容后端，请按如下方式更新您的配置：

```ruby
registry['storage'] = {
  's3_v2' => {
    'accesskey' => '<your-access-key>',
    'secretkey' => '<your-secret-key>',
    'bucket' => '<your-bucket>',
    'region' => '<your-region>',
    'regionendpoint' => 'https://<your-s3-endpoint>',
    'pathstyle' => true,
    'checksum_disabled' => true
  }
}
```

有关更多信息，请参阅
[容器镜像仓库对象存储文档](../../administration/packages/container_registry.md#use-object-storage)。

<a id="presigned-url-hostnames-on-aws-s3"></a>

#### AWS S3 上的预签名 URL 主机名

当镜像仓库提供 blob 时，它会将客户端重定向到预签名的 S3 URL。
AWS SDK v2 会解析您镜像仓库配置中区域的 S3 端点，
因此这些预签名 URL 可以使用区域主机名，例如 `s3.us-east-1.amazonaws.com`
而不是 AWS SDK v1 可能返回的全局 `s3.amazonaws.com` 主机名。

镜像仓库本身继续工作，但客户端必须能够访问新的主机名。
在使用代理、防火墙或安全 Web 网关过滤出站流量的环境中，
仅包含 `s3.amazonaws.com` 的允许列表会阻止重定向目标。
镜像拉取随后会因过滤设备（而非 S3）返回的 `403 Forbidden` 响应而失败。

升级前，请在任何过滤容器镜像客户端出站流量的设备上，为您的存储桶区域添加区域主机名到允许列表。
请使用您所在区域的具体区域主机名，例如 `s3.eu-west-2.amazonaws.com`，
而不是覆盖所有 Amazon S3 的通配符。

如果您的实例使用 S3 VPC 端点或其他固定端点，请将 `regionendpoint` 设置为该
端点，以便预签名 URL 使用您控制的主机名。
有关更多信息，请参阅 [使用对象存储](../../administration/packages/container_registry.md#use-object-storage)。

升级后要验证 blob 拉取：

1. 拉取一个大于几兆字节的镜像，以便拉取由 blob 重定向提供，而不是来自缓存：

   ```shell
   docker pull gitlab.example.com:5050/mygroup/myproject/myimage:latest
   ```

1. 如果拉取失败，直接请求一个 blob 以查看重定向目标：

   ```shell
   curl --head "https://gitlab.example.com:5050/v2/mygroup/myproject/myimage/blobs/<digest>"
   ```

   检查 `location` 响应标头，查看客户端被重定向到的主机名，
   然后确认该主机名已获得您的出站控制允许。

<a id="geo-design-management-replication-nomethoderror-when-project-is-nil"></a>

### 项目为 `nil` 时 Geo 设计管理复制出现 `NoMethodError`

- 影响：Geo
- 受影响版本：16.0.0 - 19.0.1

在 Geo 辅助站点上，当关联项目已被删除，留下孤立的 `DesignManagement::Repository` 记录时，设计管理代码仓库的复制过程中可能出现 `NoMethodError`。极狐GitLab 19.0.2 修复了此问题。

有关更多信息，请参阅 [议题 597049](https://gitlab.com/gitlab-org/gitlab/-/issues/597049)。

<a id="postgresql-17-minimum-requirement"></a>

### PostgreSQL 17 最低版本要求

- 影响：所有安装方法
- 受影响版本：19.0.0

现在支持的最低 PostgreSQL 版本是 17。在安装极狐GitLab 19.0 之前：

- 如果您使用内置的 PostgreSQL 16，
  请[升级内置的 PostgreSQL 服务器](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。
- 如果您使用[外部 PostgreSQL](../../administration/postgresql/external.md) 实例，
  请将其升级到 PostgreSQL 17。

<a id="geo-container-repository-sync-silently-skips-oci-image-index-tags"></a>

### Geo 容器代码仓库同步静默跳过 OCI 镜像索引标签

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo（容器镜像仓库）
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 修复的补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 19.0    | 19.0.0 - 19.0.1         | 19.0.2            |

在 Geo 辅助站点上，容器代码仓库同步静默跳过了其清单为 OCI 镜像索引（`application/vnd.oci.image.index.v1+json`）的标签。
多架构镜像和 BuildKit 缓存标签通常使用此清单类型。没有引发错误，标签计数也匹配，但从辅助站点对受影响标签执行 `docker pull` 会返回 `manifest unknown`。相同的根本原因也在辅助站点上留下了同步无法移除的孤立标签。

将主站点和辅助站点都升级到修复版本后，新同步的标签将是正确的。先前受影响的容器仓库将在下一个验证周期收敛，该周期可能长达重新验证间隔（默认为 90 天）。要立即修复受影响的容器仓库，请
[在辅助站点上重新同步容器代码仓库](../../administration/geo/replication/container_registry.md#manually-trigger-a-container-registry-sync-event)。

有关更多信息，请参阅 [议题 600486](https://gitlab.com/gitlab-org/gitlab/-/work_items/600486)。

<a id="geo-verification-concurrency-limit-applied-as-a-global-total"></a>

### Geo 验证并发限制作为全局总数应用

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：19.3.0

**验证并发限制** Geo 站点设置现在作为单个全局限制应用，限制站点上所有数据类型组合并发运行的验证作业数量。以前，配置的值在应用前会除以数据类型数量，因此有效并发较低，并且会随着数据类型的添加或整合而变化。

为保持正在使用的有效并发并避免验证负载激增，极狐GitLab
19.3 会自动将每个站点存储的 **验证并发限制** 重新调整为
`max(1, floor(previous_value / number_of_data_types))`。因此，管理 UI 中显示的值和 API 返回的值会减小。升级后请查看并重新调整该设置。如果您通过 API 或基础设施即代码管理此设置，请更新您存储的值以匹配。

有关更多信息，请参阅 [议题 596579](https://gitlab.com/gitlab-org/gitlab/-/work_items/596579)。

<a id="linux-package-support-for-ubuntu-2004-discontinued"></a>

### Linux 软件包停止支持 Ubuntu 20.04

- 影响：Linux 软件包
- 受影响版本：19.0.0

Ubuntu 20.04 已于 2025 年 5 月达到标准支持终止。从极狐GitLab 19.0 开始，不再为 Ubuntu 20.04 提供 Linux 软件包。极狐GitLab 18.11 是最后一个为此发行版提供软件包的版本。在升级到极狐GitLab 19.0 之前，请迁移到 Ubuntu 22.04 或其他
[支持的操作系统](../../install/package/_index.md#supported-platforms)。

<a id="redis-6-support-removed"></a>

### 移除 Redis 6 支持

- 影响：Linux 软件包
- 受影响版本：19.0.0

极狐GitLab 19.0 移除了对 Redis 6 的支持。如果您使用外部 Redis 6 部署，请在升级前迁移到 Redis 7.0 或更高版本，或 Valkey 7.2。建议使用 Redis 7.2 或 Valkey 7.2。Redis 7.0 已在上游达到生命周期终止（EOL），但在某些情况下由供应商积极维护，例如 Amazon ElastiCache for Redis 7.1。Linux 软件包中包含的内置 Redis 自极狐GitLab 16.2 起已使用 Redis 7，不受影响。

<a id="mattermost-removed-from-the-linux-package"></a>

### Mattermost 从 Linux 软件包中移除

- 影响：Linux 软件包
- 受影响版本：19.0.0

内置的 Mattermost 已在极狐GitLab 19.0 中从 Linux 软件包中移除。如果您当前使用内置的 Mattermost，请参阅
[从 Linux 软件包迁移到 Mattermost Standalone](https://docs.mattermost.com/administration-guide/onboard/migrate-gitlab-omnibus.html)
获取迁移说明。如果您不使用内置的 Mattermost，则不受影响。

在升级到极狐GitLab 19.0 之前，请从 `/etc/gitlab/gitlab.rb` 中移除或注释掉所有 `mattermost[...]` 设置。
如果任何 `mattermost[...]` 键仍然存在，`gitlab-ctl reconfigure` 会在软件包安装后立即中止，并显示：

```plaintext
RuntimeError: Removed configurations found in gitlab.rb. Aborting reconfigure.
```

> [!warning]
> 从某些 18.11.x 版本升级时的行为有所不同：
>
> - 18.11.0 至 18.11.6：升级不会检测过时的 Mattermost 配置，
>   因此即使清理不完整，升级也会在没有警告的情况下继续。
>   在升级前，不要依赖 `gitlab-ctl check-config --version 19.0.x` 来验证
>   Mattermost 键的移除（[议题 9916](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9916)）。
> - 18.11.7：即使所有 `mattermost[...]` 键都已从 `gitlab.rb` 中移除，升级也会被阻止。该阻止是由极狐GitLab 在节点缓存中无条件生成的过时 Mattermost 密钥导致的误报。
>   要解除升级阻止，请使用以下选项之一：
>   - 在升级到 19.0 之前，先升级到 18.11.9 或更高版本。
>   - 应用[手动变通方法](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/10001#workaround)。

<a id="linux-package-support-for-suse-distributions-discontinued"></a>

### Linux 软件包停止支持 SUSE 发行版

- 影响：Linux 软件包
- 受影响版本：19.0.0

Linux 软件包对 SUSE 发行版的支持在极狐GitLab 19.0 中终止，这影响 openSUSE Leap 15.6、SUSE Linux Enterprise Server 12.5 和 SUSE Linux Enterprise Server 15.6。极狐GitLab 18.11 是最后一个为这些发行版提供 Linux 软件包的版本。要继续使用 SUSE 发行版，请迁移到[极狐GitLab 的 Docker 部署](../../install/docker/installation.md)。

<a id="spamcheck-removed-from-linux-package-and-gitlab-helm-chart"></a>

### Spamcheck 从 Linux 软件包和 GitLab Helm chart 中移除

- 影响：Linux 软件包，Helm chart
- 受影响版本：19.0.0

[Spamcheck](../../administration/reporting/spamcheck.md) 已在极狐GitLab 19.0 中从 Linux 软件包和
GitLab Helm chart 中移除。当前未使用 Spamcheck 的客户不受影响。如果您
使用内置的 Spamcheck，您可以使用
[Docker](https://gitlab.com/gitlab-org/gl-security/security-engineering/security-automation/spam/spamcheck) 单独部署它。
无需数据迁移。

<a id="nginx-ingress-replaced-by-gateway-api-with-envoy-gateway"></a>

### NGINX Ingress 被 Gateway API 与 Envoy Gateway 取代

- 影响：Helm chart
- 受影响版本：19.0.0

Gateway API 与 Envoy Gateway 在极狐GitLab 19.0 中成为 GitLab Helm chart 的默认网络配置，取代了已于 2026 年 3 月达到生命周期终止的 NGINX Ingress。如果无法立即迁移到 Envoy Gateway，您可以显式重新启用内置的 NGINX Ingress，该 Ingress 在计划于极狐GitLab 20.0 中移除之前仍然可用。此更改不影响 Linux 软件包中使用的 NGINX，也不影响使用外部管理的 Ingress 或 Gateway API 控制器的 Helm chart 实例。

有关详细的迁移步骤，请参阅
[Helm chart 10.0 升级说明](https://gitlab.cn/docs/charts/releases/10_0/)。

<a id="bundled-postgresql-redis-and-minio-removed-from-gitlab-helm-chart"></a>

### 内置的 PostgreSQL、Redis 和 MinIO 从 GitLab Helm chart 中移除

- 影响：Helm chart
- 受影响版本：19.0.0

内置的 Bitnami PostgreSQL、Bitnami Redis 和 MinIO chart 已在极狐GitLab 19.0 中从 GitLab Helm chart 和 GitLab Operator 中移除，且无替代品。这些组件仅用于概念验证和测试环境，不建议用于生产环境。如果您使用任何这些内置服务运行实例，请在升级到极狐GitLab 19.0 之前，按照
[迁移指南](https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/)
配置外部服务。

<a id="orphaned-agents-and-claude-directories-on-linux-package-rpm-installs"></a>

### Linux 软件包 RPM 安装中遗留的 `.agents` 和 `.claude` 目录

- 影响：Linux 软件包 (RPM)
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 修复的补丁级别 |
  |:--------|:------------------------|:------------------|
  | 19.0    | 19.0.0 - 19.0.2         | 19.0.3            |
  | 19.1    | 19.1.0                  | 19.1.1            |

受影响补丁版本的 Linux 软件包错误地在 `/opt/gitlab/embedded/service/gitlab-rails/` 下包含了两个目录：

- `.agents/`
- `.claude/`

从修复的补丁级别开始，以及默认在极狐GitLab 19.2 及更高版本中，这些目录已从软件包负载中排除。有关更多信息，请参阅
[议题 603547](https://gitlab.com/gitlab-org/gitlab/-/issues/603547)。

在基于 RPM 的发行版上，如果目录中仍包含文件，RPM 不会移除它不再拥有的目录。即使您将 Linux 软件包 RPM 安装升级到修复版本之后，这些目录仍可能留在磁盘上：

- `/opt/gitlab/embedded/service/gitlab-rails/.agents`
- `/opt/gitlab/embedded/service/gitlab-rails/.claude`

RPM 不会自动移除这些遗留目录。请检查这些目录是否存在，如果存在，请手动移除：

1. 检查目录是否存在：

   ```shell
   ls -la /opt/gitlab/embedded/service/gitlab-rails/.agents \
          /opt/gitlab/embedded/service/gitlab-rails/.claude
   ```

1. 如果目录存在，请移除它们：

   ```shell
   sudo rm -rf /opt/gitlab/embedded/service/gitlab-rails/.agents \
               /opt/gitlab/embedded/service/gitlab-rails/.claude
   ```

基于 DEB 的发行版不受影响，因为 `dpkg` 会在升级期间移除它不再拥有的目录。
