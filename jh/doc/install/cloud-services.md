---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用托管云服务管理极狐GitLab 组件的指南。
title: 为极狐GitLab 组件使用云服务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以使用托管云服务来管理 PostgreSQL、Redis/Valkey 和对象存储，而无需自行管理。

> [!note]
> 对于使用 GitLab Helm chart 的云原生部署，必须使用外部 PostgreSQL 和 Redis/Valkey
> 服务。这些组件不包含在 chart 中。

<a id="use-managed-cloud-postgresql"></a>

## 使用托管的云 PostgreSQL

使用运行[受支持版本](requirements.md#postgresql)的外部 PostgreSQL 服务。
有关设置说明，请参阅
[使用外部 PostgreSQL 数据库](../administration/postgresql/external.md)。

仅支持完整的 PostgreSQL 部署。实现 PostgreSQL 线路协议但并非完整 PostgreSQL 部署的服务，例如 [Amazon Aurora](https://aws.amazon.com/rds/aurora/)
和 [Google AlloyDB](https://cloud.google.com/alloydb)，与极狐GitLab 不兼容。

已知可用的服务包括：

- [Google Cloud SQL](https://cloud.google.com/sql/docs/postgres/high-availability#normal)
- [Amazon RDS](https://aws.amazon.com/rds/)
- [Azure Database for PostgreSQL Flexible Server](https://azure.microsoft.com/en-gb/products/postgresql/)

<a id="performance-and-high-availability"></a>

### 性能和高可用性

对于较大规模的环境，请启用
[数据库负载均衡](../administration/postgresql/database_load_balancing.md) 并配置只读副本。
副本数量应与等效 Linux 软件包部署中使用的数量保持一致。
使用只读副本时，请确保所有副本节点都设置了 `hot_standby_feedback = on`，以防止
复制延迟累积。

对于较大规模环境中的 GCP Cloud SQL，请使用
[Enterprise Plus 版本](https://cloud.google.com/sql/docs/editions-intro) 以获得最佳性能。

> [!note]
> GCP Cloud SQL 不支持将 `statement_timeout` 作为数据库标志。请改为按数据库或用户设置：
> `ALTER DATABASE gitlab SET statement_timeout = '60s';`

<a id="gitlab-geo"></a>

### 极狐GitLab Geo

[极狐GitLab Geo](../administration/geo/_index.md) 需要在主站点和辅助站点之间进行跨区域 PostgreSQL 复制。并非所有托管数据库服务都支持此功能。

已知限制：

- Amazon RDS Multi-AZ DB 集群：不支持跨区域复制。请改用标准的
  [RDS Multi-AZ DB 实例](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html)
  并配置跨区域只读副本。
- GCP Cloud SQL：Geo 的只读副本只能在同一个 VPC 和同一个 GCP
  项目内创建。对于位于不同项目的辅助站点，Cloud SQL 无法直接创建副本。
  请手动配置 [PostgreSQL 逻辑复制](https://cloud.google.com/sql/docs/postgres/replication/configure-external-replica)，
  然后按照 [极狐GitLab Geo 外部 PostgreSQL 设置](../administration/geo/setup/external_database.md) 进行操作。

<a id="connection-pooling"></a>

### 连接池

如果您的工作负载需要 PostgreSQL 直接处理之外的额外连接池，请自行部署 PgBouncer 实例。

> [!note]
> 极狐GitLab 内置的 PgBouncer 仅适用于内置的 PostgreSQL，不能与
> 外部数据库服务一起使用。

以下由提供商管理的连接池解决方案不被推荐：

- AWS RDS Proxy：未经极狐GitLab 验证。
- Azure Database for PostgreSQL PgBouncer：单线程且可观测性有限。
  在高负载下可能成为瓶颈。

<a id="use-managed-cloud-redis-and-valkey"></a>

## 使用托管的云 Redis 和 Valkey

使用运行[受支持版本](requirements.md#redis-or-valkey)的外部 Redis 或 Valkey 服务。
有关设置说明，请参阅
[Redis 作为托管服务](../administration/redis/replication_and_failover_external.md#redis-as-a-managed-service-in-a-cloud-provider)。

该服务必须支持：

- 独立（主从）模式，而非 Redis 集群模式
- 通过复制实现高可用性
- 可配置的[逐出策略](../administration/redis/replication_and_failover_external.md#setting-the-eviction-policy)

> [!note]
> 不支持无服务器 Redis 和 Valkey 变体。

已知可用的服务包括：

- [Google Memorystore](https://cloud.google.com/memorystore)
- [Amazon ElastiCache for Valkey](https://aws.amazon.com/elasticache/valkey/)

> [!note]
> 在 AWS 上，请使用 ElastiCache for Valkey 7.2。AWS 不提供 ElastiCache for Redis 7.2。
> ElastiCache for Redis 7.1 基于 Redis 7.0 OSS 构建，不建议用于新部署。
> [Azure Cache for Redis](https://azure.microsoft.com/en-gb/products/cache) 和
> [Azure Managed Redis](https://azure.microsoft.com/en-gb/products/managed-redis) 目前均不提供
> Redis 7.2 或受支持的 Valkey 版本。对于 Azure 部署，请在虚拟机上自行管理 Redis 或 Valkey。

对于较大规模的环境，请为缓存和持久数据分别运行独立的 Redis 实例。Redis 是
单线程的，单个共享实例在规模扩大时会成为瓶颈。

<a id="use-managed-cloud-object-storage"></a>

## 使用托管的云对象存储

使用任何兼容 S3 的对象存储服务。
有关已测试提供商的完整列表和配置详情，请参阅
[对象存储](../administration/object_storage.md)。
