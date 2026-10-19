---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Geo PostgreSQL 复制
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下各节列出了修复复制错误消息（在 [`geo:check` 输出](common.md#health-check-rake-task)中由 `Database replication working? ... no` 表示）的故障排除步骤。此处提供的说明主要假设单节点 Geo Linux 软件包部署，可能需要根据不同的环境进行调整。

<a id="removing-an-inactive-replication-slot"></a>

## 移除非活跃复制槽

当连接到复制槽的复制客户端（从站点）断开连接时，复制槽会被标记为“非活跃”。非活跃复制槽会导致 WAL 文件被保留，因为当客户端重新连接且复制槽再次变为活跃时，这些文件会被发送给客户端。如果从站点无法重新连接，请使用以下步骤移除其对应的非活跃复制槽：

1. 在 Geo 主站点的数据库节点上[启动 PostgreSQL 控制台会话](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database)：

   ```shell
   sudo gitlab-psql -d gitlabhq_production
   ```

   > [!note]
   > 使用 `gitlab-rails dbconsole` 不起作用，因为管理复制槽需要超级用户权限。

1. 查看复制槽，如果它们处于非活跃状态则将其移除：

   ```sql
   SELECT * FROM pg_replication_slots;
   ```

   `active` 为 `f`的槽是非活跃的。

- 如果该槽应当处于活跃状态，因为您有一个使用该槽配置的从站点：
  - 查看从站点的 [PostgreSQL 日志](../../../logs/_index.md#postgresql-logs)，
    以了解复制未运行的原因。
  - 如果从站点不再能够重新连接：

    1. 使用 PostgreSQL 控制台会话移除该槽：

       ```sql
       SELECT pg_drop_replication_slot('<name_of_inactive_slot>');
       ```

    1. [重新启动复制过程（非 Patroni 数据库）](../../setup/database.md#step-3-initiate-the-replication-process)，
       这会正确地重新创建复制槽。

       > [!note]
       > 当您在从站点上启动复制过程时，Patroni 管理的数据库的复制槽不会被重新创建。
       > 您必须先使用[主站点上的 `patroni['replication_slots']` 设置](../../setup/database.md#step-1-configure-patroni-permanent-replication-slot-on-the-primary-site)配置它们。

- 如果您不再使用该槽（例如，您不再启用 Geo），请按照[移除该 Geo 站点](../remove_geo_site.md)的步骤操作。

<a id="message-warning-oldest-xmin-is-far-in-the-past-and-pg_wal-size-growing"></a>

## 消息：`WARNING: oldest xmin is far in the past` 且 `pg_wal` 大小不断增长

如果复制槽处于非活跃状态，与该槽对应的 `pg_wal` 日志会被永久保留（或直到该槽再次变为活跃）。这会导致磁盘使用量持续增长，并且以下消息会反复出现在
[PostgreSQL 日志](../../../logs/_index.md#postgresql-logs)中：

```plaintext
WARNING: oldest xmin is far in the past
HINT: Close open transactions soon to avoid wraparound problems.
You might also need to commit or roll back old prepared transactions, or drop stale replication slots.
```

要解决此问题，您应[移除非活跃复制槽](#removing-an-inactive-replication-slot)并重新启动复制。

<a id="message-error--replication-slots-can-only-be-used-if-max_replication_slots--0"></a>

## 消息：`ERROR:  replication slots can only be used if max_replication_slots > 0`？

这意味着需要在主数据库上设置 `max_replication_slots` PostgreSQL 变量。此设置默认为 1。如果您有更多从站点，可能需要增大此值。

请务必重启 PostgreSQL 以使此设置生效。有关更多详细信息，请参阅
[PostgreSQL 复制设置](../../setup/database.md#postgresql-replication)指南。

<a id="message-replication-slot-geo_secondary_my_domain_com-does-not-exist"></a>

## 消息：`replication slot "geo_secondary_my_domain_com" does not exist`

当 PostgreSQL 没有该名称对应的从站点复制槽时，会出现此错误：

```plaintext
FATAL:  could not start WAL streaming: ERROR:  replication slot "geo_secondary_my_domain_com" does not exist
```

您可能需要在从站点上重新运行[复制过程](../../setup/database.md)。

<a id="message-command-exceeded-allowed-execution-time-when-setting-up-replication"></a>

## 消息：设置复制时出现 `Command exceeded allowed execution time`？

这可能发生在从站点上[启动复制过程](../../setup/database.md#step-3-initiate-the-replication-process)时，表明您的初始数据集太大，无法在默认超时时间（30 分钟）内完成复制。

重新运行 `gitlab-ctl replicate-geo-database`，但为 `--backup-timeout` 指定一个更大的值：

```shell
sudo gitlab-ctl \
   replicate-geo-database \
   --host=<primary_node_hostname> \
   --slot-name=<secondary_slot_name> \
   --backup-timeout=21600
```

这样初始复制最多有六个小时来完成，而不是默认的 30 分钟。请根据您的安装情况按需调整。

<a id="message-panic-could-not-write-to-file-pg_xlogxlogtemp123-no-space-left-on-device"></a>

## 消息：`PANIC: could not write to file 'pg_xlog/xlogtemp.123': No space left on device`

确定主数据库中是否有任何未使用的复制槽。这可能会导致大量日志数据在 `pg_xlog`中堆积。

[移除非活跃槽](#removing-an-inactive-replication-slot)可以减少 `pg_xlog`中使用的空间量。

<a id="message-error-canceling-statement-due-to-conflict-with-recovery"></a>

## 消息：`ERROR: canceling statement due to conflict with recovery`

此错误消息在典型使用情况下很少出现，系统具有足够的恢复能力可以自行恢复。

但是，在某些情况下，从站点上的某些数据库查询可能会运行过长时间，这会增加此错误消息的出现频率。这可能导致某些查询由于在每次复制时都被取消而永远无法完成。

这些长时间运行的查询[计划在未来移除](https://gitlab.com/gitlab-org/gitlab/-/issues/34269)，但作为变通方法，我们建议启用
[`hot_standby_feedback`](https://www.postgresql.org/docs/16/hot-standby.html#HOT-STANDBY-CONFLICT)。
这会增加主站点上出现膨胀的可能性，因为它会阻止 `VACUUM` 移除最近失效的行。但是，它已在 GitLab.com 的生产环境中成功使用。

要启用 `hot_standby_feedback`，请在从站点的 `/etc/gitlab/gitlab.rb`中添加以下内容：

```ruby
postgresql['hot_standby_feedback'] = 'on'
```

然后重新配置极狐GitLab：

```shell
sudo gitlab-ctl reconfigure
```

为帮助我们解决此问题，请考虑在[该议题](https://gitlab.com/gitlab-org/gitlab/-/issues/4489)上发表评论。

<a id="message-server-certificate-for-postgresql-does-not-match-host-name"></a>

## 消息：`server certificate for "PostgreSQL" does not match host name`

如果您看到此错误：

```plaintext
FATAL:  could not connect to the primary server: server certificate for "PostgreSQL" does not match host name
```

出现此问题的原因是 Linux 软件包自动创建的 PostgreSQL 证书包含通用名称 `PostgreSQL`，但复制连接的是不同的主机，而极狐GitLab 默认尝试使用
`verify-full` SSL 模式。

要解决此问题，您可以：

- 在 `replicate-geo-database` 命令中使用 `--sslmode=verify-ca` 参数。
- 对于已复制的数据库，将 `sslmode=verify-full` 改为 `sslmode=verify-ca`，
  位置在 `/var/opt/gitlab/postgresql/data/gitlab-geo.conf`，然后运行 `gitlab-ctl restart postgresql`。
- [为 PostgreSQL 配置 SSL](https://gitlab.cn/docs/omnibus/settings/database/#configuring-ssl)，
  使用自定义证书（在 CN 或 SAN 中包含用于连接数据库的主机名），
  而不是使用自动生成的证书。

<a id="message-log--invalid-cidr-mask-in-address"></a>

## 消息：`LOG:  invalid CIDR mask in address`

这发生在 `postgresql['md5_auth_cidr_addresses']` 中格式错误的地址上。

```plaintext
2020-03-20_23:59:57.60499 LOG:  invalid CIDR mask in address "***"
2020-03-20_23:59:57.60501 CONTEXT:  line 74 of configuration file "/var/opt/gitlab/postgresql/data/pg_hba.conf"
```

要解决此问题，请更新 `/etc/gitlab/gitlab.rb`中 `postgresql['md5_auth_cidr_addresses']` 下的 IP 地址，使其符合 CIDR 格式（例如 `10.0.0.1/32`）。

<a id="message-log--invalid-ip-mask-md5-name-or-service-not-known"></a>

## 消息：`LOG:  invalid IP mask "md5": Name or service not known`

当您在 `postgresql['md5_auth_cidr_addresses']` 中添加了不带子网掩码的 IP 地址时，会出现此问题。

```plaintext
2020-03-21_00:23:01.97353 LOG:  invalid IP mask "md5": Name or service not known
2020-03-21_00:23:01.97354 CONTEXT:  line 75 of configuration file "/var/opt/gitlab/postgresql/data/pg_hba.conf"
```

要解决此问题，请在 `/etc/gitlab/gitlab.rb`中 `postgresql['md5_auth_cidr_addresses']` 下添加子网掩码，使其符合 CIDR 格式（例如 `10.0.0.1/32`）。

<a id="message-found-data-in-the-gitlabhq_production-database"></a>

## 消息：`Found data in the gitlabhq_production database`

如果您在运行 `gitlab-ctl replicate-geo-database` 时收到错误 `Found data in the gitlabhq_production database!`，说明在 `projects` 表中检测到了数据。当检测到一个或多个项目时，该操作会被中止，以防止意外数据丢失。要绕过此消息，请向该命令传递 `--force` 选项。

<a id="message-fatal--could-not-map-anonymous-shared-memory-cannot-allocate-memory"></a>

## 消息：`FATAL:  could not map anonymous shared memory: Cannot allocate memory`

如果您看到此消息，意味着从站点的 PostgreSQL 尝试请求的内存高于可用内存。有一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/381585)在跟踪此问题。

Patroni 日志中的错误消息示例（对于 Linux 软件包安装，位于 `/var/log/gitlab/patroni/current`）：

```plaintext
2023-11-21_23:55:18.63727 FATAL:  could not map anonymous shared memory: Cannot allocate memory
2023-11-21_23:55:18.63729 HINT:  This error usually means that PostgreSQL's request for a shared memory segment exceeded available memory, swap space, or huge pages. To reduce the request size (currently 17035526144 bytes), reduce PostgreSQL's shared memory usage, perhaps by reducing shared_buffers or max_connections.
```

变通方法是增加从站点 PostgreSQL 节点的可用内存，使其与主站点 PostgreSQL 节点的内存需求相匹配。

<a id="error-could-not-open-certificate-file-rootpostgresqlpostgresqlcrt"></a>

## 错误：`could not open certificate file "/root/.postgresql/postgresql.crt"`

当您运行 `gitlab-ctl replicate-geo-database` 时，可能会遇到以下错误之一：

```plaintext
could not open certificate file "/root/.postgresql/postgresql.crt": Permission denied
```

```plaintext
could not open certificate file "/root/.postgresql/postgresql.crt": No such file or directory
```

出现此问题的原因是 `gitlab-ctl replicate-geo-database` 以 root 身份运行，而 `gitlab-ctl replicate-geo-database` 内部调用的 `pg_basebackup` 会在 `/root/.postgresql/root.crt`中查找 SSL CA 证书。当您使用 `sslmode=verify-ca` 或 `sslmode=verify-full` 时，需要此证书。

要解决此问题：

1. 在从站点上也为 root 用户安装该证书。
   使用您从主站点复制的同一个 `server.crt` 文件：

   ```shell
   install \
      -D \
      -o root \
      -g root \
      -m 0400 \
      -T server.crt /root/.postgresql/root.crt
   ```

1. 再次运行复制命令。

> [!note]
> 当身份验证因其他原因失败时，也可能出现此问题，
> 例如 `gitlab_replicator` 用户的密码不正确。
> 如果为 root 安装证书后仍未解决问题，
> 请确认您的复制凭据是否正确。

<a id="investigate-causes-of-database-replication-lag"></a>

## 调查数据库复制延迟的原因

如果 `sudo gitlab-rake gitlab:geo:status`的输出显示 `Database replication lag` 随时间推移仍然显著偏高，可以检查数据库复制中的主节点，以确定数据库复制过程不同部分的延迟状态。这些值称为 `write_lag`、`flush_lag` 和 `replay_lag`。有关更多信息，请参阅
[PostgreSQL 官方文档](https://www.postgresql.org/docs/16/monitoring-stats.html#MONITORING-PG-STAT-REPLICATION-VIEW)。

从主 Geo 节点的数据库运行以下命令以提供相关输出：

```shell
gitlab-psql -xc 'SELECT write_lag,flush_lag,replay_lag FROM pg_stat_replication;'

-[ RECORD 1 ]---------------
write_lag  | 00:00:00.072392
flush_lag  | 00:00:00.108168
replay_lag | 00:00:00.108283
```

如果其中一个或多个值显著偏高，这可能表明存在问题，应进一步调查。在确定原因时，请考虑：

- `write_lag` 表示自 WAL 字节由主节点发送、随后被从节点接收，但尚未刷新或应用以来的时间。
- `write_lag` 值偏高可能表明主节点和从节点之间的网络性能下降或网络速度不足。
- `flush_lag` 值偏高可能表明从节点存储设备的磁盘 I/O 性能下降或不够理想。
- `replay_lag` 值偏高可能表明 PostgreSQL 中存在长时间运行的事务，或 CPU 等所需资源已饱和。
- `write_lag` 与 `flush_lag` 之间的时间差表明 WAL 字节已发送到底层存储系统，但尚未报告已刷新。
  这些数据很可能未完全写入持久存储，而是保存在某种易失性写缓存中。
- `flush_lag` 与 `replay_lag` 之间的差值表明 WAL 字节已成功持久化到存储，但数据库系统无法重放它们。

<a id="stuck-at-message-pg_basebackup-initiating-base-backup-waiting-for-checkpoint-to-complete"></a>

## 卡在 `Message: pg_basebackup: initiating base backup, waiting for checkpoint to complete`

如果初始复制卡在 `Message: pg_basebackup: initiating base backup, waiting for checkpoint to complete`，这意味着 Geo 主站点未被积极使用。这主要发生在非生产环境的极狐GitLab 服务器上或全新的极狐GitLab 安装上。

变通方法是触发一些数据库写入。例如，您可以登录主站点并创建一些议题和评论。

另一种变通方法是在主站点的数据库上运行 SQL 查询 `CHECKPOINT;`：

```shell
sudo gitlab-psql -xc 'CHECKPOINT;'
```
