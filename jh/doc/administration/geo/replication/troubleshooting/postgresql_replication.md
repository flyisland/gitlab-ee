---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Geo PostgreSQL 复制故障
---

<a id="troubleshooting-geo-postgresql-replication"></a>

# 排查 Geo PostgreSQL 复制故障

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下部分概述了修复复制错误消息的故障排除步骤（在 [`geo:check` 输出](common.md#health-check-rake-task) 中由 `Database replication working? ... no` 标识）。此处提供的说明主要针对单节点 Geo Linux 软件包部署，并且可能需要根据不同环境进行调整。

<a id="removing-an-inactive-replication-slot"></a>

## 移除不活跃的复制槽

当复制客户端（辅助站点）与复制槽断开连接时，该槽会被标记为“不活跃”。不活跃的复制槽会导致 WAL 文件被保留，因为当客户端重新连接时，这些文件会被发送给客户端，且复制槽会重新变为活跃状态。如果辅助站点无法重新连接，请使用以下步骤移除其对应的不活跃复制槽：

1. 在 Geo 主站点的数据库节点上[启动一个 PostgreSQL 控制台会话](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database)：

   ```shell
   sudo gitlab-psql -d gitlabhq_production
   ```

   > [!note]
   > 使用 `gitlab-rails dbconsole` 无效，因为管理复制槽需要超级用户权限。

1. 查看复制槽，如果它们处于不活跃状态，则将其移除：

   ```sql
   SELECT * FROM pg_replication_slots;
   ```

   当 `active` 为 `f` 时，表示复制槽处于不活跃状态。

- 如果你有一个使用该槽的**辅助**站点，该槽本应是活跃状态：
  - 查看**辅助**站点的 [PostgreSQL 日志](../../../logs/_index.md#postgresql-logs)，了解复制未运行的原因。
  - 如果辅助站点无法重新连接：

    1. 在 PostgreSQL 控制台会话中删除该槽：

       ```sql
       SELECT pg_drop_replication_slot('<name_of_inactive_slot>');
       ```

    1. [重新启动复制流程](../../setup/database.md#step-3-initiate-the-replication-process)，这将正确重新创建复制槽。

- 如果你不再使用该槽（例如，你已不再启用 Geo），请按照[删除该 Geo 站点](../remove_geo_site.md)的步骤操作。

<a id="message-warning-oldest-xmin-is-far-in-the-past-and-pg-wal-size-growing"></a>

## 消息：`WARNING: oldest xmin is far in the past` 与 `pg_wal` 大小不断增长

如果复制槽处于不活跃状态，与该槽对应的 `pg_wal` 日志将被永久保留（或直到该槽再次变为活跃状态）。这会导致磁盘使用量持续增长，并在 [PostgreSQL 日志](../../../logs/_index.md#postgresql-logs) 中反复出现以下消息：

```plaintext
WARNING: oldest xmin is far in the past
HINT: Close open transactions soon to avoid wraparound problems.
You might also need to commit or roll back old prepared transactions, or drop stale replication slots.
```

要修复此问题，你应[移除不活跃的复制槽](#removing-an-inactive-replication-slot)并重新启动复制。

<a id="message-error-replication-slots-can-only-be-used-if-max-replication-slots--0"></a>

## 消息：`ERROR:  replication slots can only be used if max_replication_slots > 0`？

这表示需要在**主**数据库上设置 `max_replication_slots` PostgreSQL 变量。此设置的默认值为 1。如果你有更多**辅助**站点，可能需要增大此值。

确保重启 PostgreSQL 以使更改生效。更多详细信息参见 [PostgreSQL 复制设置](../../setup/database.md#postgresql-replication) 指南。

<a id="message-replication-slot-geo-secondary-my-domain-com-does-not-exist"></a>

## 消息：`replication slot "geo_secondary_my_domain_com" does not exist`

当 PostgreSQL 没有为该名称的**辅助**站点创建复制槽时，就会出现此错误：

```plaintext
FATAL:  could not start WAL streaming: ERROR:  replication slot "geo_secondary_my_domain_com" does not exist
```

你可能需要在**辅助**站点上重新运行[复制流程](../../setup/database.md)。

<a id="message-command-exceeded-allowed-execution-time-when-setting-up-replication"></a>

## 消息：设置复制时出现 `Command exceeded allowed execution time`？

在**辅助**站点上[启动复制流程](../../setup/database.md#step-3-initiate-the-replication-process)时，可能会出现此情况，这表明你的初始数据集太大，无法在默认超时（30 分钟）内完成复制。

重新运行 `gitlab-ctl replicate-geo-database`，但为 `--backup-timeout` 指定更大的值：

```shell
sudo gitlab-ctl \
   replicate-geo-database \
   --host=<primary_node_hostname> \
   --slot-name=<secondary_slot_name> \
   --backup-timeout=21600
```

这将为初始复制提供最多六个小时的时间，而不是默认的 30 分钟。请根据你的安装情况进行调整。

<a id="message-panic-could-not-write-to-file-pg-xlogxlogtemp123-no-space-left-on-device"></a>

## 消息：`PANIC: could not write to file 'pg_xlog/xlogtemp.123': No space left on device`

请确定**主**数据库中是否存在任何未使用的复制槽。这可能导致 `pg_xlog` 中积累大量日志数据。

[移除不活跃的槽](#removing-an-inactive-replication-slot)可以减少 `pg_xlog` 中的磁盘使用量。

<a id="message-error-canceling-statement-due-to-conflict-with-recovery"></a>

## 消息：`ERROR: canceling statement due to conflict with recovery`

此错误消息在典型使用场景下偶尔出现，系统具有很强的恢复能力。

然而，在某些条件下，辅助站点上的某些数据库查询可能运行过长，这会增加此错误消息的出现频率。这可能导致某些查询由于在每次复制时都被取消而永远无法完成。

这些长时间运行的查询计划在未来移除，但作为临时解决方案，我们建议启用 [`hot_standby_feedback`](https://www.postgresql.org/docs/16/hot-standby.html#HOT-STANDBY-CONFLICT)。这可能会增加**主**站点产生膨胀的风险，因为它会阻止 `VACUUM` 删除最近消亡的行。不过，该方案已在 GitLab.com 的生产环境中成功使用。

要在**辅助**站点上启用 `hot_standby_feedback`，请将以下内容添加到 `/etc/gitlab/gitlab.rb` 中：

```ruby
postgresql['hot_standby_feedback'] = 'on'
```

然后重新配置极狐GitLab：

```shell
sudo gitlab-ctl reconfigure
```

<a id="message-server-certificate-for-postgresql-does-not-match-host-name"></a>

## 消息：`server certificate for "PostgreSQL" does not match host name`

如果你看到此错误：

```plaintext
FATAL:  could not connect to the primary server: server certificate for "PostgreSQL" does not match host name
```

发生此问题是因为 Linux 软件包自动创建的 PostgreSQL 证书包含通用名称 `PostgreSQL`，但复制连接到的是其他主机，并且极狐GitLab 默认尝试使用 `verify-full` SSL 模式。

要修复此问题，你可以选择以下任一方法：

- 在 `replicate-geo-database` 命令中使用 `--sslmode=verify-ca` 参数。
- 对于已复制的数据库，将 `/var/opt/gitlab/postgresql/data/gitlab-geo.conf` 中的 `sslmode=verify-full` 更改为 `sslmode=verify-ca`，并运行 `gitlab-ctl restart postgresql`。
- 使用自定义证书（在 CN 或 SAN 中包含用于连接数据库的主机名）[为 PostgreSQL 配置 SSL](https://gitlab.cn/docs/omnibus/settings/database/#configuring-ssl)，而不是使用自动生成的证书。

<a id="message-log-invalid-cidr-mask-in-address"></a>

## 消息：`LOG:  invalid CIDR mask in address`

当 `postgresql['md5_auth_cidr_addresses']` 中的地址格式错误时，就会发生这种情况。

```plaintext
2020-03-20_23:59:57.60499 LOG:  invalid CIDR mask in address "***"
2020-03-20_23:59:57.60501 CONTEXT:  line 74 of configuration file "/var/opt/gitlab/postgresql/data/pg_hba.conf"
```

要修复此问题，请更新 `/etc/gitlab/gitlab.rb` 下 `postgresql['md5_auth_cidr_addresses']` 中的 IP 地址，使其符合 CIDR 格式（例如，`10.0.0.1/32`）。

<a id="message-log-invalid-ip-mask-md5-name-or-service-not-known"></a>

## 消息：`LOG:  invalid IP mask "md5": Name or service not known`

当你在 `postgresql['md5_auth_cidr_addresses']` 中添加的 IP 地址缺少子网掩码时，就会发生这种情况。

```plaintext
2020-03-21_00:23:01.97353 LOG:  invalid IP mask "md5": Name or service not known
2020-03-21_00:23:01.97354 CONTEXT:  line 75 of configuration file "/var/opt/gitlab/postgresql/data/pg_hba.conf"
```

要修复此问题，请在 `/etc/gitlab/gitlab.rb` 下 `postgresql['md5_auth_cidr_addresses']` 中添加子网掩码，使其符合 CIDR 格式（例如，`10.0.0.1/32`）。

<a id="message-found-data-in-the-gitlabhq-production-database"></a>

## 消息：`Found data in the gitlabhq_production database`

如果你在运行 `gitlab-ctl replicate-geo-database` 时收到错误 `Found data in the gitlabhq_production database!`，则表示在 `projects` 表中检测到了数据。当检测到一个或多个项目时，操作将中止以防止意外数据丢失。要绕过此消息，请向命令添加 `--force` 选项。

<a id="message-fatal-could-not-map-anonymous-shared-memory-cannot-allocate-memory"></a>

## 消息：`FATAL:  could not map anonymous shared memory: Cannot allocate memory`

如果你看到此消息，则表示辅助站点的 PostgreSQL 尝试请求的内存超过可用内存。这种情况已被跟踪，例如在 Patroni 日志中（对于 Linux 软件包安装，位于 `/var/log/gitlab/patroni/current`）：

```plaintext
2023-11-21_23:55:18.63727 FATAL:  could not map anonymous shared memory: Cannot allocate memory
2023-11-21_23:55:18.63729 HINT:  This error usually means that PostgreSQL's request for a shared memory segment exceeded available memory, swap space, or huge pages. To reduce the request size (currently 17035526144 bytes), reduce PostgreSQL's shared memory usage, perhaps by reducing shared_buffers or max_connections.
```

解决方法是增加辅助站点 PostgreSQL 节点的可用内存，以匹配主站点 PostgreSQL 节点的内存需求。

<a id="message-could-not-open-certificate-file-rootpostgresqlpostgresqlcrt"></a>

## 消息：`could not open certificate file "/root/.postgresql/postgresql.crt"`

如果你看到此错误：

```plaintext
sql: error: connection to server at "x.x.x.x", port 5432 failed:
could not open certificate file "/root/.postgresql/postgresql.crt": Permission denied...
```

发生此错误是因为 PostgreSQL 客户端（例如 `psql` 或使用 `libpq` 的应用程序）在特定默认位置（例如 `/root/.postgresql/postgresql.crt`）查找客户端 SSL 证书。然而，这条错误消息可能会产生误导。它通常在其他认证原因失败时出现，例如使用了不正确的极狐GitLab 复制器用户密码。在排查 SSL 证书问题之前，请先确认你的认证凭据是否正确。

<a id="investigate-causes-of-database-replication-lag"></a>

## 调查数据库复制延迟的原因

如果 `sudo gitlab-rake geo:status` 的输出显示 `Database replication lag` 长时间保持显著较高，可以检查数据库复制中的主节点，以确定复制过程中不同部分的延迟状态。这些值被称为 `write_lag`、`flush_lag` 和 `replay_lag`。有关更多信息，请参阅[官方 PostgreSQL 文档](https://www.postgresql.org/docs/16/monitoring-stats.html#MONITORING-PG-STAT-REPLICATION-VIEW)。

从 Geo 主节点的数据库运行以下命令以提供相关输出：

```shell
gitlab-psql -xc 'SELECT write_lag,flush_lag,replay_lag FROM pg_stat_replication;'

-[ RECORD 1 ]---------------
write_lag  | 00:00:00.072392
flush_lag  | 00:00:00.108168
replay_lag | 00:00:00.108283
```

如果其中一个或多个值显著较高，这可能表明存在问题，应进行进一步调查。在确定原因时，请考虑以下因素：

- `write_lag` 表示自 WAL 字节由主站点发送、被辅助站点接收但尚未刷新或应用以来的时间。
- 较高的 `write_lag` 值可能表示主站点与辅助站点之间的网络性能下降或网络速度不足。
- 较高的 `flush_lag` 值可能表示辅助节点存储设备的磁盘 I/O 性能下降或欠佳。
- 较高的 `replay_lag` 值可能表示 PostgreSQL 中存在长时间运行的事务，或者某个必要资源（如 CPU）饱和。
- `write_lag` 与 `flush_lag` 之间的时间差表示 WAL 字节已被发送到底层存储系统，但存储系统尚未报告它们已刷新。这些数据很可能尚未完全写入持久化存储，可能保存在某种易失性写缓存中。
- `flush_lag` 与 `replay_lag` 之间的差异表示 WAL 字节已成功持久化到存储，但无法被数据库系统重放。

<a id="stuck-at-message-pg-basebackup-initiating-base-backup-waiting-for-checkpoint-to-complete"></a>

## 卡在 `Message: pg_basebackup: initiating base backup, waiting for checkpoint to complete`

如果初始复制卡在 `Message: pg_basebackup: initiating base backup, waiting for checkpoint to complete`，这意味着 Geo 主站点未被积极使用。这通常发生在非生产环境极狐GitLab 服务器或全新的极狐GitLab 安装上。

解决方法是产生一些数据库写入操作。例如，你可以登录主站点并创建一些议题和评论。

另一种解决方法是在主站点的数据库上运行 SQL 查询 `CHECKPOINT;`：

```shell
sudo gitlab-psql -xc 'CHECKPOINT;'
```