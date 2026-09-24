---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置 PostgreSQL 以进行扩展
description: 配置 PostgreSQL 以进行扩展。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在本节中，你将学习如何配置 PostgreSQL 数据库，以在其中一个[参考架构](../reference_architectures/_index.md)中与极狐GitLab 配合使用。

<a id="configuration-options"></a>

## 配置选项

选择以下 PostgreSQL 配置选项之一：

<a id="standalone-postgresql-for-linux-package-installations"></a>

### 用于 Linux 软件包安装的单机 PostgreSQL

此设置适用于你已使用 [Linux 软件包](https://gitlab.cn/install/)（CE 或 EE）安装极狐GitLab 的情况，该安装使用捆绑的 PostgreSQL，并仅启用了其服务。

阅读如何[设置单机 PostgreSQL 实例](standalone.md)以用于 Linux 软件包安装。

<a id="provide-your-own-postgresql-instance"></a>

### 提供你自己的 PostgreSQL 实例

此设置适用于你已使用 [Linux 软件包](https://gitlab.cn/install/)（CE 或 EE）安装极狐GitLab，或[自行编译](../../install/self_compiled/_index.md)安装，但希望使用自己的外部 PostgreSQL 服务器的情况。

阅读如何[设置外部 PostgreSQL 实例](external.md)。

在设置外部数据库时，有一些用于监控和故障排除的指标非常有用。
在设置外部数据库时，需要监控和日志记录设置来解决各种数据库相关问题。
阅读更多关于[外部数据库的监控和日志记录设置](external_metrics.md)的信息。

<a id="postgresql-replication-and-failover-for-linux-package-installations"></a>

### 用于 Linux 软件包安装的 PostgreSQL 复制和故障转移

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此设置适用于你已使用 [Linux **企业版（EE）** 软件包](https://gitlab.cn/install/?version=ee)安装极狐GitLab 的情况。

所需的全部工具（如 PostgreSQL、PgBouncer 和 Patroni）都捆绑在软件包中，因此你可以使用它设置完整的 PostgreSQL 基础设施（主库、副本）。

阅读如何为 Linux 软件包安装[设置 PostgreSQL 复制和故障转移](replication_and_failover.md)。

<a id="related-topics"></a>

## 相关主题

- [使用捆绑的 PgBouncer 服务](pgbouncer.md)
- [数据库负载均衡](database_load_balancing.md)
- [将极狐GitLab 数据库移动到另一个 PostgreSQL 实例](moving.md)
- 针对极狐GitLab 开发的数据库指南
- [升级外部数据库](external_upgrade.md)
- [升级 PostgreSQL 的操作系统](upgrading_os.md)