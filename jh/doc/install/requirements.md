---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 安装先决条件。
title: 极狐GitLab 安装要求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 私有化部署有特定的硬件、组件和基础设施要求，这些要求会因您的部署规模和工作负载而异。对于较大规模或分布式部署，请使用[规模指南](sizing.md)来确定适合您环境的规格。

<a id="hardware"></a>

## 硬件

您可以将极狐GitLab 部署在单个节点上，也可以分布式部署在多个节点上。下面列出了单节点安装的最低硬件要求。对于分布式部署，要求按组件类型分配，并随负载扩展。请使用[规模指南](sizing.md)根据预期负载和工作负载构成来确定合适的规格。

<a id="cpu"></a>

### CPU

对于单节点安装，8 vCPU 是基准配置。支持基于 ARM 的处理器。对于分布式部署，CPU 按组件类型分配，并随负载扩展。

> [!note]
> 由于性能不稳定，不建议使用突发性能实例类型。

<a id="memory"></a>

### 内存

对于单节点安装，16 GB 是基准配置。对于分布式部署，内存按组件类型分配，并随负载扩展。

对于内存受限环境中的单节点安装，极狐GitLab 可以在至少 8 GB 内存下运行。有关更多信息，请参阅[在内存受限环境中运行极狐GitLab](https://gitlab.cn/docs/omnibus/settings/memory_constrained_envs/)。

> [!note]
> 尽可能禁用交换空间。交换空间可能导致负载下性能显著下降。
> 如果无法禁用交换空间，请预配足够的内存，使极狐GitLab 永远不会使用它。

<a id="storage"></a>

### 存储

存储要求因组件而异。对于单节点安装，请在一台机器上汇总所有要求。对于分布式部署，请将每项要求应用到相应的节点类型：

| 组件 | 最低存储 | 说明 |
|-----------|----------------|-------|
| 应用节点（Rails、Sidekiq、Puma） | 40 GB | 软件包安装（约 2.5 GB）加上操作系统、日志和临时文件。 |
| 代码仓库存储（Gitaly） | 至少与所有代码仓库的总和相当 | 请参阅 [Gitaly 磁盘要求](../administration/gitaly/_index.md#disk-requirements)。 |
| 数据库（PostgreSQL） | 5-12 GB | 请参阅 [PostgreSQL 存储要求](#storage-requirements)。 |

避免使用 NFS、Amazon EFS 和 Azure Files 等网络文件系统，因为它们可能显著影响性能。有关更多信息，请参阅[避免使用基于云的文件系统](../administration/nfs.md#avoid-using-cloud-based-file-systems)。

> [!note]
> 为获得最佳性能，请使用 SSD 存储。这对 I/O 密集型的 Gitaly 尤为重要。
> 由于性能不稳定，不建议使用突发性能磁盘类型。

<a id="infrastructure"></a>

## 基础设施

极狐GitLab 可运行在多种基础设施类型上。以下各节介绍支持的平台和高可用性要求。

<a id="supported-infrastructure"></a>

### 支持的基础设施

只要底层环境满足本指南中所述的硬件和组件要求，极狐GitLab 就可以运行在云提供商和您自己的基础设施上。
常用的云提供商包括 AWS、GCP 和 Azure。
[极狐GitLab 支持](https://gitlab.cn/support)涵盖极狐GitLab 本身；底层基础设施或平台的问题不在其范围内。

对于 Cloud Native 部署，极狐GitLab 可运行在任何满足
[GitLab Helm chart 先决条件](https://gitlab.cn/docs/charts/installation/tools/)的 Kubernetes 发行版上。
网络、存储类和身份验证等 Kubernetes 平台特定行为不在极狐GitLab 支持的范围内。

<a id="high-availability"></a>

### 高可用性

HA 部署有特定的网络要求：

- 节点之间的延迟必须低于 5 毫秒，以支持同步复制。
- 建议跨可用区部署以提高韧性。请使用奇数个可用区以满足法定人数要求。
- 跨多个数据中心部署需要具备同步能力的延迟、冗余网络链路，以及同一地理区域内奇数个数据中心。

> [!warning]
> 单个极狐GitLab 实例不得跨越多个地理区域。对于多区域
> 部署，请使用 [极狐GitLab Geo](../administration/geo/_index.md)，它专为
> 地理分布式安装而设计。
> 多数据中心部署中与基础设施相关的问题可能不在极狐GitLab 支持的范围内。

<a id="component-requirements"></a>

## 组件要求

<a id="postgresql"></a>

### PostgreSQL

[PostgreSQL](https://www.postgresql.org/) 是唯一受支持的数据库，可通过以下方式使用：

- 作为 Linux 软件包中的[内置实例](https://gitlab.cn/docs/omnibus/settings/database/)。
- 作为外部服务，例如：
  - [托管云提供商服务](cloud-services.md#use-managed-cloud-postgresql)。
  - [CloudNativePG operator](https://cloudnative-pg.io/)。
  - [非打包的 PostgreSQL 服务器](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)。

对于外部实例，请参阅：

- [必需设置](../administration/postgresql/tune.md#required-settings-for-external-instances)，适用于外部管理的实例。
- [数据库模式](../administration/postgresql/external.md#database-schemas)，了解模式相关指导。
- [何时检查区域设置兼容性](../administration/postgresql/upgrading_os.md#when-to-check-locale-compatibility)，了解区域设置相关注意事项。

<a id="supported-versions"></a>

#### 支持的版本

对于以下极狐GitLab 版本，请使用这些 PostgreSQL 版本：

| 极狐GitLab 版本 | Helm chart 版本 | 最低 PostgreSQL 版本 | 最高 PostgreSQL 版本 |
| -------------- | ------------------ | -------------------------- | -------------------------- |
| 19.x           | 10.x               | 17.x                       | 18.x（[已针对极狐GitLab 18.7 及更高版本测试](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/209519)） |
| 18.x           | 9.x                | [16.5](https://gitlab.com/gitlab-org/gitlab/-/issues/508672) | 17.x（[已针对 GitLab 17.10 及更高版本测试](https://gitlab.com/gitlab-org/gitlab/-/issues/521159)） |
| 17.x           | 8.x                | [14.14](https://gitlab.com/gitlab-org/gitlab/-/issues/508672) | 16.x（[已针对极狐GitLab 16.10 及更高版本测试](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/145298)） |
| 16.x           | 7.x                | 13.6                       | 15.x（[已针对极狐GitLab 16.1 及更高版本测试](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/119344)） |

PostgreSQL 次要版本[仅包含缺陷和安全修复](https://www.postgresql.org/support/versioning/)。请始终使用最新的次要版本，以避免 PostgreSQL 中的已知问题。有关更多信息，请参阅[议题 364763](https://gitlab.com/gitlab-org/gitlab/-/issues/364763)。

如需使用比指定版本更高的 PostgreSQL 主要版本，请检查 [Linux 软件包中是否内置了更高版本](http://gitlab-org.gitlab.io/omnibus-gitlab/licenses.html)。

<a id="storage-requirements"></a>

#### 存储要求

根据[用户数量](../administration/reference_architectures/_index.md)，
PostgreSQL 服务器应具备：

- 对于大多数极狐GitLab 实例，至少 5 到 10 GB 存储。
- 对于极狐GitLab 旗舰版，至少 12 GB 存储
  （必须导入 1 GB 漏洞数据）。

<a id="extensions"></a>

#### 扩展

要安装扩展，PostgreSQL 需要超级用户权限。有关说明，请参阅
[管理 PostgreSQL 扩展](../administration/postgresql/extensions.md)。

| 扩展            | 最低极狐GitLab 版本 | 类型        | 数据库 |
|----------------------|------------------------|-------------|----------|
| `amcheck`            | 18.4                   | 必需    | 主库 |
| `btree_gist`         | 13.1                   | 必需    | 主库 |
| `pg_trgm`            | 8.6                    | 必需    | 主库 |
| `plpgsql`            | 11.7                   | 必需    | 主库、[Geo 从站点跟踪数据库](../administration/geo/_index.md)（最低版本 9.0） |
| `pg_stat_statements` | -                      | 推荐 | 全部 |

<a id="gitaly-cluster-praefect"></a>

#### Gitaly 集群（Praefect）

[Gitaly 集群](../administration/gitaly/praefect/_index.md)需要一个独立于主极狐GitLab 数据库的专用 PostgreSQL 实例。
要实现完整的 HA，请使用第三方 PostgreSQL 解决方案。对于 Gitaly 不需要数据库级冗余的环境，使用 Linux 软件包的非 HA PostgreSQL 实例就足够了。有关更多详细信息，请参阅 [`omnibus-gitlab#7292`](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7292) 和
[`gitaly#3398`](https://gitlab.com/gitlab-org/gitaly/-/issues/3398)。

<a id="redis-or-valkey"></a>

### Redis 或 Valkey

[Redis](https://redis.io/) 或 [Valkey](https://valkey.io/) 存储所有用户会话和后台任务。您可以自行管理 Redis 或 Valkey，也可以使用[托管云提供商服务](cloud-services.md#use-managed-cloud-redis-and-valkey)。

Redis 或 Valkey 支持的版本为：

| 数据存储 | 推荐版本 | 最低版本 |
| --------- | ------------------- | --------------- |
| Redis     | 7.2                 | 7.0[^reached-end-life] |
| Valkey    | 7.2                 | 7.2             |

[^reached-end-life]: Redis 7.0 在上游已达到生命周期终止（EOL），但在某些情况下仍由供应商积极
维护。例如，Amazon ElastiCache for Redis 7.1 使用自己的版本号，
但基于 Redis 7.0 构建。

有关 Redis 生命周期终止日期的更多信息，请参阅
[Redis 文档](https://redis.io/docs/latest/operate/oss_and_stack/install/version-mgmt/)。

- 使用独立实例（可带或不带高可用性）。
  不支持 Redis Cluster。
- 不支持无服务器 Redis 和 Valkey 变体。
- 根据需要设置[逐出策略](../administration/redis/replication_and_failover_external.md#setting-the-eviction-policy)。

<a id="puma"></a>

### Puma

推荐的 [Puma](https://puma.io/) 设置取决于您的[安装方式](install_methods.md)。默认情况下，Linux 软件包使用推荐的设置。

要调整 Puma 设置：

- 对于 Linux 软件包，请参阅 [Puma 设置](../administration/operations/puma.md)。
- 对于 GitLab Helm chart，请参阅
  [`webservice` chart](https://gitlab.cn/docs/charts/charts/gitlab/webservice/)。

有关工作进程和线程规模的指导，请参阅 [Puma 工作进程和线程规模](../administration/operations/puma.md#worker-and-thread-sizing)。

<a id="sidekiq"></a>

### Sidekiq

[Sidekiq](https://sidekiq.org/) 使用多个线程处理后台作业。每个进程至少需要 200 MB 内存，并且在负载下可能显著增长。对于用户数超过 10,000 的环境，请为每个 Sidekiq 进程分配至少 1 GB 内存。

<a id="object-storage"></a>

### 对象存储

分布式部署需要对象存储，所有安装都建议使用对象存储。它存储二进制数据，包括 LFS 对象、CI/CD 产物、上传内容、容器镜像仓库数据和备份。

使用任何兼容 S3 的对象存储服务。有关配置和已测试提供商的列表，请参阅[对象存储](../administration/object_storage.md)。

<a id="optional-components"></a>

## 可选组件

这些组件不是核心极狐GitLab 安装所必需的，但在使用时会有单独的基础设施或资源要求。

<a id="container-registry"></a>

### 容器镜像仓库

[极狐GitLab 容器镜像仓库](../administration/packages/container_registry.md)存储极狐GitLab 项目的 Docker 和 OCI 镜像，
并且需要：

- 一个域名。
- TLS 证书。
- 文件系统或兼容 S3 的对象存储。

对于高流量环境，容器镜像仓库可以运行在独立于主极狐GitLab 实例的专用基础设施上。

<a id="gitlab-pages"></a>

### GitLab Pages

[GitLab Pages](../administration/pages/_index.md) 为项目和群组托管静态网站。它作为单独的守护进程运行，并且需要通配符 DNS 记录。自定义域名支持需要辅助 IP 地址和 TLS 证书。

<a id="elasticsearch-and-opensearch"></a>

### Elasticsearch 和 OpenSearch

[高级搜索](../integration/advanced_search/elasticsearch.md)为极狐GitLab 内容提供更快速、更强大的搜索。
它需要单独的 Elasticsearch 或 OpenSearch 集群。
集群规模取决于已索引数据的量。

<a id="prometheus"></a>

### Prometheus

[Prometheus](https://prometheus.io) 监控随 Linux 软件包内置，并默认启用。
有关配置或禁用它的信息，请参阅
[使用 Prometheus 监控极狐GitLab](../administration/monitoring/prometheus/_index.md)。

<a id="zoekt"></a>

### Zoekt

[Zoekt](../integration/zoekt/_index.md) 提供跨代码仓库的精确代码搜索，并作为单独的服务运行。有关资源要求，请参阅
[Zoekt 管理](../integration/zoekt/_index.md)。

<a id="clickhouse"></a>

### ClickHouse

[ClickHouse](../integration/clickhouse.md) 是一个开源列式数据库，用于产品分析功能。它作为单独的数据库服务运行。有关资源要求，请参阅
[ClickHouse 配置](../integration/clickhouse.md)。

<a id="ai-gateway"></a>

### AI 网关

[AI 网关](install_ai_gateway.md)为极狐GitLab Duo AI 功能提供后端服务。它作为独立服务运行，可部署在 Docker 或 Kubernetes 上。有关资源要求，请参阅安装指南。

<a id="secrets-manager"></a>

### 密钥管理器

[极狐GitLab 密钥管理器](../administration/secrets_manager/_index.md)提供由 OpenBao 驱动的原生密钥管理。它作为单独的 Kubernetes 服务运行，并且需要专用的 PostgreSQL 数据库和负载均衡器。

<a id="supported-web-browsers"></a>

## 支持的 Web 浏览器

极狐GitLab 支持以下 Web 浏览器：

- [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/new/)
- [Google Chrome](https://www.google.com/chrome/)
- [Chromium](https://www.chromium.org/getting-involved/dev-channel/)
- [Apple Safari](https://www.apple.com/safari/)
- [Microsoft Edge](https://www.microsoft.com/en-us/edge?form=MA13QK)

极狐GitLab 以 [Baseline](https://web-platform-dx.github.io/baseline/) 广泛可用
浏览器集为目标。这些浏览器版本支持在所有核心浏览器中稳定的 Web 平台功能。一项功能在至少 30 个月后才会达到广泛可用状态。广泛可用浏览器集包括这些浏览器的桌面版和移动版。

不支持在这些浏览器中禁用 JavaScript 运行极狐GitLab。
