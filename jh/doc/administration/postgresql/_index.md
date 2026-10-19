---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置 PostgreSQL 以实现扩展
description: 配置 PostgreSQL 以实现扩展。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本节将指导您配置 PostgreSQL 数据库，以便在我们的某个[参考架构](../reference_architectures/_index.md)中与极狐GitLab 配合使用。

<a id="configuration-options"></a>

## 配置选项

请从以下 PostgreSQL 配置选项中选择一项：

<a id="standalone-postgresql-for-linux-package-installations"></a>

### 适用于 Linux 软件包安装的独立 PostgreSQL

此设置适用于您通过 [Linux 软件包](https://gitlab.cn/install)（基础版或企业版）安装极狐GitLab，并且只想启用捆绑的 PostgreSQL 服务的情况。

了解如何为 Linux 软件包安装[设置独立的 PostgreSQL 实例](standalone.md)。

<a id="provide-your-own-postgresql-instance"></a>

### 提供您自己的 PostgreSQL 实例

此设置适用于您通过 [Linux 软件包](https://gitlab.cn/install)（基础版或企业版）安装极狐GitLab，或[自行编译](../../install/self_compiled/_index.md)安装，但希望使用自己的外部 PostgreSQL 服务器的情况。

了解如何[设置外部 PostgreSQL 实例](external.md)。

设置外部数据库时，有一些指标可用于监控和故障排除。设置外部数据库时，需要配置监控和日志记录设置，以便对各类数据库相关问题进行故障排除。详细了解[外部数据库的监控和日志记录设置](external_metrics.md)。

<a id="postgresql-replication-and-failover-for-linux-package-installations"></a>

### 适用于 Linux 软件包安装的 PostgreSQL 复制和故障转移

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此设置适用于您通过 [Linux **企业版**软件包](https://gitlab.cn/install?version=ee)安装极狐GitLab 的情况。

PostgreSQL、PgBouncer 和 Patroni 等所需的所有工具都捆绑在该软件包中，因此您可以使用它来设置整个 PostgreSQL 基础设施（主节点、副本）。

了解如何为 Linux 软件包安装[设置 PostgreSQL 复制和故障转移](replication_and_failover.md)。
