---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 暂停和恢复复制
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 暂停和恢复复制仅支持使用 Linux 软件包管理数据库的 Geo 安装。不支持外部数据库。
>
> **如果主站点发生灾难性故障且无法恢复，请勿暂停复制**。这可能会创建无法到达的恢复目标，从而阻止辅助站点成功提升。

在某些情况下，例如在[升级](upgrading_the_geo_sites.md)或[计划性故障转移](../disaster_recovery/planned_failover.md)期间，需要暂停主站点和辅助站点之间的复制。

如果你计划在升级期间允许用户在辅助站点上进行活动，请不要为了[零停机升级](../../../update/zero_downtime.md)而暂停复制。在暂停期间，辅助站点会变得越来越过时。
一个已知的影响是，越来越多的 Git 获取会被重定向或代理到主站点。可能还有其他未知影响。

例如，暂停具有单独 URL 的辅助站点可能会破坏通过辅助站点 URL 登录的功能。你将跳转到主站点的根 URL，而不会在辅助站点的 URL 上建立新会话。

<a id="pause-and-resume"></a>

## 暂停和恢复

暂停和恢复复制是通过辅助站点上特定节点的命令行工具完成的。根据你的数据库架构，此操作针对 `postgresql` 或 `patroni` 服务：

- 如果你在辅助站点上为所有服务使用单个节点，则必须在此单个节点上运行命令。
- 如果你在辅助站点上有独立的 PostgreSQL 节点，则必须在此独立的 PostgreSQL 节点上运行命令。
- 如果你的辅助站点使用 Patroni 集群，则必须在辅助 Patroni 备用领导者节点上运行这些命令。

如果你没有在辅助站点上为所有服务使用单个节点，请确保你的 PostgreSQL 或 Patroni 节点上的 `/etc/gitlab/gitlab.rb` 包含配置行 `gitlab_rails['geo_node_name'] = 'node_name'`，其中 `node_name` 与应用节点上的 `geo_node_name` 相同。

**要暂停：（从辅助站点）**

另外，请注意，如果在暂停复制后重新启动 PostgreSQL（无论是通过重新启动虚拟机还是通过 `gitlab-ctl restart postgresql` 重新启动服务），PostgreSQL 会自动恢复复制，这在升级或计划性故障转移场景中并不是你想要的。

```shell
gitlab-ctl geo-replication-pause
```

**要恢复：（从辅助站点）**

```shell
gitlab-ctl geo-replication-resume
```