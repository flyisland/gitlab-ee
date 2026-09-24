---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Prerequisites for installation.
title: 极狐GitLab 安装要求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 有特定的安装要求。

<a id="storage"></a>

## 存储

所需的存储空间在很大程度上取决于您希望在极狐GitLab 中拥有的仓库大小。
作为指导，您应至少拥有与所有仓库总和一样多的可用空间。

Linux 软件包安装大约需要 2.5 GB 的存储空间。
结合 PostgreSQL、日志、临时文件和操作系统开销，
对于一个没有仓库数据的基本极狐GitLab 安装，至少需要规划 40 GB 的磁盘空间。
为了存储灵活性，请考虑通过逻辑卷管理挂载您的硬盘。
您应该使用转速至少为 7200 RPM 的硬盘或固态硬盘，以减少响应时间。

由于文件系统性能可能会影响极狐GitLab 的整体性能，您应该
[避免使用基于云的文件系统进行存储](../administration/nfs.md#avoid-using-cloud-based-file-systems)。

<a id="cpu"></a>

## CPU

CPU 要求取决于用户数量和预期工作负载。
工作负载包括用户的活动、自动化和镜像的使用以及仓库大小。

对于每秒最多 20 个请求或 1,000 个用户，您应该拥有 8 个 vCPU。
对于更多用户或更高的工作负载，
请参见[参考架构](../administration/reference_architectures/_index.md)。

<a id="memory"></a>

## 内存

内存要求取决于用户数量和预期工作负载。
工作负载包括用户的活动、自动化和镜像的使用以及仓库大小。

对于每秒最多 20 个请求或 1,000 个用户，您应该拥有 16 GB 的内存。
对于更多用户或更高的工作负载，
请参见[参考架构](../administration/reference_architectures/_index.md)。

在某些情况下，极狐GitLab 至少可以在 8 GB 内存下运行。
有关更多信息，请参见
[在内存受限的环境中运行极狐GitLab](https://gitlab.cn/docs/omnibus/settings/memory_constrained_envs/)。

<a id="postgresql"></a>

## PostgreSQL

[PostgreSQL](https://www.postgresql.org/) 是唯一受支持的数据库，并与 Linux 软件包捆绑在一起。
您也可以使用[外部 PostgreSQL 数据库](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)
[必须正确配置](#postgresql-settings)。

根据[用户数量](../administration/reference_architectures/_index.md)，
PostgreSQL 服务器应具备：

- 对于大多数极狐GitLab 实例，至少 5 到 10 GB 的存储空间
- 对于极狐GitLab 旗舰版，至少 12 GB 的存储空间
  （需要导入 1 GB 的漏洞数据）

对于以下极狐GitLab 版本，请使用以下 PostgreSQL 版本：

| 极狐GitLab 版本 | Helm Chart 版本 | 最低 PostgreSQL 版本 | 最高 PostgreSQL 版本 |
| -------------- | ------------------ | -------------------------- | -------------------------- |
| 18.x           | 9.x                | [16.5](https://jihulab.com/gitlab-cn/gitlab/-/issues/508672) | 17.x（[针对极狐GitLab 17.10 及更高版本测试](https://jihulab.com/gitlab-cn/gitlab/-/issues/521159)）          |
| 17.x           | 8.x                | [14.14](https://jihulab.com/gitlab-cn/gitlab/-/issues/508672) | 16.x（[针对极狐GitLab 16.10 及更高版本测试](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/145298)） |
| 16.x           | 7.x                | 13.6                       | 15.x（[针对极狐GitLab 16.1 及更高版本测试](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/119344)） |
| 15.x           | 6.x                | 12.10                      | 14.x（[仅针对极狐GitLab 15.11 测试](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/114624)），13.x |

PostgreSQL 次要版本[仅包含错误和安全修复](https://www.postgresql.org/support/versioning/)。
始终使用最新的次要版本，以避免 PostgreSQL 中的已知问题。
有关更多信息，请参见[议题 364763](https://jihulab.com/gitlab-cn/gitlab/-/issues/364763)。

要使用比指定版本更高的 PostgreSQL 主要版本，请检查
[Linux 软件包是否捆绑了更高版本](http://gitlab-org.gitlab.io/omnibus-gitlab/licenses.html)。

您还必须确保在每个极狐GitLab 数据库中加载了一些扩展。
有关更多信息，请参见[管理 PostgreSQL 扩展](postgresql_extensions.md)。

<a id="gitlab-geo"></a>

### GitLab Geo

对于[极狐GitLab Geo](../administration/geo/_index.md)，您应该使用 Linux 软件包或
[经过验证的云提供商](../administration/reference_architectures/_index.md#recommended-cloud-providers-and-services)
来安装极狐GitLab。
不保证与其他外部数据库的兼容性。

有关更多信息，请参见[运行 Geo 的要求](../administration/geo/_index.md#requirements-for-running-geo)。

<a id="locale-compatibility"></a>

### 区域设置兼容性

当您更改 `glibc` 中的区域设置数据时，PostgreSQL 数据库文件
在不同操作系统之间不再完全兼容。
为避免索引损坏，
请在以下情况下[检查区域设置兼容性](../administration/geo/replication/troubleshooting/common.md#check-os-locale-data-compatibility)：

- 在服务器之间移动二进制 PostgreSQL 数据。
- 升级您的 Linux 发行版。
- 更新或更改第三方容器镜像。

有关更多信息，请参见[升级 PostgreSQL 的操作系统](../administration/postgresql/upgrading_os.md)。

<a id="gitlab-schemas"></a>

### 极狐GitLab 模式

您应该专门为极狐GitLab、[Geo](../administration/geo/_index.md)、
[Gitaly 集群（Praefect）](../administration/gitaly/praefect/_index.md) 或其他组件创建或使用数据库。
除非遵循以下内容，否则不要创建或修改数据库、模式、用户或其他属性：

- 极狐GitLab 文档中的步骤
- 极狐GitLab 支持或工程师的指示

主要的极狐GitLab 应用程序使用三种模式：

- 默认的 `public` 模式
- `gitlab_partitions_static`（自动创建）
- `gitlab_partitions_dynamic`（自动创建）

在 Rails 数据库迁移期间，极狐GitLab 可能会创建或修改模式或表。
数据库迁移会根据极狐GitLab 代码库中的模式定义进行测试。
如果您修改任何模式，[极狐GitLab 升级](../update/_index.md)可能会失败。

<a id="postgresql-settings"></a>

### PostgreSQL 设置

以下是外部管理的 PostgreSQL 实例的一些必需设置。

| 可调设置        | 必需值 | 更多信息 |
|:-----------------------|:---------------|:-----------------|
| `work_mem`             | 最小 `8 MB`  | 此值为 Linux 软件包默认值。在大型部署中，如果查询创建临时文件，您应该增加此设置。 |
| `maintenance_work_mem` | 最小 `64 MB` | 对于较大的数据库服务器，您需要[更多](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8377#note_1728173087)。 |
| `max_connections`      | 最小 `400`   | 根据您的极狐GitLab 组件计算。有关详细指导，请参见[调整 PostgreSQL](../administration/postgresql/tune.md) 页面。 |
| `shared_buffers`       | 最小 `2 GB`  | 对于较大的数据库服务器，您需要更多。Linux 软件包默认设置为服务器 RAM 的 25%。 |
| `statement_timeout`    | 15000 到 60000 | 语句超时可防止因锁定和数据库拒绝新客户端而导致的失控问题。您应该使用 15 到 60 秒之间的值（15000 到 60000 毫秒），其中一分钟与 Puma rack 超时设置相匹配。 |
| `hot_standby_feedback` | `on` | 对于配置了多个节点和[数据库负载均衡](../administration/postgresql/database_load_balancing.md#configuring-database-load-balancing)的配置，确保所有副本节点都启用了 `hot_standby_feedback`，以防止滞后累积。 |

您可以为特定数据库配置某些 PostgreSQL 设置，而不是为服务器上的所有数据库配置。

- 当在同一服务器上托管多个数据库时，您可能将配置限制在特定数据库。
- 有关在何处应用配置的指导，请咨询您的数据库管理员或供应商。
- 对于 GCP Cloud SQL，您可以在特定数据库或用户上设置 `statement_timeout`，但不能[作为数据库标志](https://cloud.google.com/sql/docs/postgres/flags#list-flags-postgres)。
  例如：`ALTER DATABASE gitlab SET statement_timeout = '60s';`

<a id="puma"></a>

## Puma

推荐的 [Puma](https://puma.io/) 设置取决于您的[安装方式](install_methods.md)。
默认情况下，Linux 软件包使用推荐的设置。

要调整 Puma 设置：

- 对于 Linux 软件包，请参见 [Puma 设置](../administration/operations/puma.md)。
- 对于极狐GitLab Helm Chart，请参见
  [`webservice` chart](https://gitlab.cn/docs/charts/charts/gitlab/webservice/)。

<a id="workers"></a>

### 工作进程

推荐的 Puma 工作进程数量在很大程度上取决于 CPU 和内存容量。
默认情况下，Linux 软件包使用推荐的工作进程数量。
有关如何计算此数量的更多信息，
请参见 [`puma.rb`](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/master/files/gitlab-cookbooks/gitlab/libraries/puma.rb?ref_type=heads#L46-69)。

一个节点绝不能少于两个 Puma 工作进程。
例如，一个节点应具有：

- 对于 2 个 CPU 核心和 8 GB 内存，使用两个工作进程
- 对于 4 个 CPU 核心和 4 GB 内存，使用两个工作进程
- 对于 4 个 CPU 核心和 8 GB 内存，使用四个工作进程
- 对于 8 个 CPU 核心和 8 GB 内存，使用六个工作进程
- 对于 8 个 CPU 核心和 16 GB 内存，使用八个工作进程

默认情况下，每个 Puma 工作进程限制为 1.2 GB 内存。
您可以在 `/etc/gitlab/gitlab.rb` 中[调整此设置](../administration/operations/puma.md#tuning-memory-use)。

只要有足够的 CPU 和内存容量可用，您也可以增加 Puma 工作进程的数量。
更多的工作进程将减少响应时间，并提高处理并行请求的能力。
运行测试以验证适合您[安装方式](install_methods.md)的最佳工作进程数量。

<a id="threads"></a>

### 线程

推荐的 Puma 线程数量取决于系统总内存。
一个节点应使用：

- 对于最大 2 GB 内存的操作系统，使用一个线程
- 对于超过 2 GB 内存的操作系统，使用四个线程

更多线程会导致过度交换并降低性能。

<a id="redis"></a>

## Redis

[Redis](https://redis.io/) 或 [Valkey](https://valkey.io/) 存储所有用户会话和后台任务，
平均每个用户大约需要 25 kB。

需要 Redis 7.2 或 Valkey 7.2。
有关生命周期结束日期的更多信息，请参见
[Redis 文档](https://redis.io/docs/latest/operate/oss_and_stack/install/version-mgmt/)。

- 使用独立实例（带或不带高可用性）。
  不支持 Redis 集群。
- 适当设置[淘汰策略](../administration/redis/replication_and_failover_external.md#setting-the-eviction-policy)。

<a id="sidekiq"></a>

## Sidekiq

[Sidekiq](https://sidekiq.org/) 使用多线程进程处理后台作业。
此进程最初消耗超过 200 MB 的内存，
并且可能由于内存泄漏而随时间增长。

在一个拥有超过 10,000 个计费用户的非常活跃的服务器上，
Sidekiq 进程可能会消耗超过 1 GB 的内存。

<a id="prometheus"></a>

## Prometheus

默认情况下，[Prometheus](https://prometheus.io) 及其相关的导出器已启用以监控极狐GitLab。
这些进程消耗大约 200 MB 的内存。

有关更多信息，请参见
[使用 Prometheus 监控极狐GitLab](../administration/monitoring/prometheus/_index.md)。

<a id="supported-web-browsers"></a>

## 支持的 Web 浏览器

极狐GitLab 支持以下 Web 浏览器：

- [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/new/)
- [Google Chrome](https://www.google.com/chrome/)
- [Chromium](https://www.chromium.org/getting-involved/dev-channel/)
- [Apple Safari](https://www.apple.com/safari/)
- [Microsoft Edge](https://www.microsoft.com/en-us/edge?form=MA13QK)

极狐GitLab 支持：

- 这些浏览器的最新两个主要版本
- 受支持主要版本的当前次要版本

不支持在这些浏览器中禁用 JavaScript 的情况下运行极狐GitLab。

<a id="related-topics"></a>

## 相关主题

- [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)
- [保护您的安装](../security/_index.md)