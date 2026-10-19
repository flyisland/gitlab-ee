---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 暂停和恢复复制
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 仅使用 Linux 软件包管理的数据库的 Geo 安装支持暂停和恢复复制。不支持外部数据库。
>
> 如果主站点已发生灾难性故障且无法恢复，请勿暂停复制。这可能会产生无法访问的恢复目标，从而阻止从站点成功提升。

在某些情况下，例如在[升级](upgrading_the_geo_sites.md)或[计划内故障转移](../disaster_recovery/planned_failover.md)期间，暂停主站点和从站点之间的复制是可取的。

如果您计划在升级期间允许用户在从站点上活动，请勿为[零停机升级](../../../update/zero_downtime.md)暂停复制。暂停期间，从站点会变得越来越过时。一个已知影响是，越来越多的 Git 拉取会被重定向或代理到主站点。可能还有其他未知影响。

例如，暂停具有单独 URL 的从站点可能会导致从站点 URL 的登录中断。您会落到主站点的根 URL，而在从站点 URL 上没有新会话。

<a id="pause-and-resume"></a>

## 暂停和恢复

暂停和恢复复制是通过从站点中特定节点上的命令行工具完成的。根据您的数据库架构，这会针对 `postgresql` 或 `patroni` 服务：

- 如果您在从站点上使用单个节点运行所有服务，则必须在此单个节点上运行命令。
- 如果您的从站点上有独立的 PostgreSQL 节点，则必须在此独立 PostgreSQL 节点上运行命令。
- 如果您的从站点使用 Patroni 集群，则必须在从站点的 Patroni 备用领导节点上运行这些命令。

如果您未在从站点上使用单个节点运行所有服务，请确保 PostgreSQL 或 Patroni 节点上的 `/etc/gitlab/gitlab.rb` 包含配置行 `gitlab_rails['geo_node_name'] = 'node_name'`，其中 `node_name` 与应用节点上的 `geo_node_name` 相同。

**暂停：（在从站点执行）**

另外请注意，如果在暂停复制后重启 PostgreSQL（无论是通过重启虚拟机还是使用 `gitlab-ctl restart postgresql` 重启服务），PostgreSQL 会自动恢复复制，这在升级期间或计划内故障转移场景中是不希望发生的。

```shell
gitlab-ctl geo-replication-pause
```

**恢复：（在从站点执行）**

```shell
gitlab-ctl geo-replication-resume
```
