---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Linux 软件包安装的 PostgreSQL 复制和故障转移问题
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在使用 PostgreSQL 复制和故障转移时，您可能会遇到以下问题。

<a id="consul-and-postgresql-changes-not-taking-effect"></a>

## Consul 和 PostgreSQL 更改未生效

由于潜在影响，`gitlab-ctl reconfigure` 只会重载 Consul 和 PostgreSQL，而不会重启服务。但并非所有更改都能通过重载激活。

要重启任一服务，请运行 `gitlab-ctl restart SERVICE`。

对于 PostgreSQL，默认情况下重启主节点通常是安全的。自动故障转移默认有 1 分钟超时。只要数据库在此之前恢复，就无需执行其他操作。

在 Consul 服务器节点上，请务必以受控方式[重启 Consul 服务](../consul.md#restart-consul)。

<a id="pgbouncer-error-error-pgbouncer-cannot-connect-to-server"></a>

## PgBouncer 错误 `错误：pgbouncer 无法连接到服务器`

在运行 `gitlab-rake gitlab:db:configure` 时，或者您可能会在 PgBouncer 日志文件中看到此错误。

```plaintext
PG::ConnectionBad: 错误：pgbouncer 无法连接到服务器
```

问题可能在于您的 PgBouncer 节点的 IP 地址未包含在数据库节点上 `/etc/gitlab/gitlab.rb` 中的 `trust_auth_cidr_addresses` 设置中。

您可以通过检查主数据库节点上的 PostgreSQL 日志来确认是否为此问题。如果您看到以下错误，则说明 `trust_auth_cidr_addresses` 是问题所在。

```plaintext
2018-03-29_13:59:12.11776 FATAL:  主机 "123.123.123.123" 没有 pg_hba.conf 条目，用户 "pgbouncer"，数据库 "gitlabhq_production"，SSL 关闭
```

要解决此问题，请将 IP 地址添加到 `/etc/gitlab/gitlab.rb`。

```ruby
postgresql['trust_auth_cidr_addresses'] = %w(123.123.123.123/32 <other_cidrs>)
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="pgbouncer-nodes-dont-fail-over-after-patroni-switchover"></a>

## Patroni 切换后 PgBouncer 节点不进行故障转移

由于一个影响 16.5.0 之前极狐GitLab 版本的[已知问题](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8166)，在 [Patroni 切换](replication_and_failover.md#manual-failover-procedure-for-patroni)后，PgBouncer 节点不会自动进行故障转移。在此示例中，极狐GitLab 未能检测到已暂停的数据库，然后尝试对未暂停的数据库执行 `RESUME`：

```plaintext
INFO -- : 正在运行：gitlab-ctl pgb-notify --pg-database gitlabhq_production --newhost database7.example.com --user pgbouncer --hostuser gitlab-consul
ERROR -- : STDERR: 运行命令出错：GitlabCtl::Errors::ExecutionError
ERROR -- : STDERR: 错误：错误：数据库 gitlabhq_production 未暂停
```

为确保 [Patroni 切换](replication_and_failover.md#manual-failover-procedure-for-patroni)成功，您必须使用以下命令在所有 PgBouncer 节点上手动重启 PgBouncer 服务：

```shell
gitlab-ctl restart pgbouncer
```

<a id="reinitialize-a-replica"></a>

## 重新初始化副本

如果副本无法启动或重新加入集群，或者当它滞后且无法赶上时，可能需要重新初始化副本：

1. [检查复制状态](replication_and_failover.md#check-replication-status) 以确认需要重新初始化的服务器。例如：

   ```plaintext
   + Cluster: postgresql-ha (6970678148837286213) ------+---------+--------------+----+-----------+
   | Member                              | Host         | Role    | State        | TL | Lag in MB |
   +-------------------------------------+--------------+---------+--------------+----+-----------+
   | gitlab-database-1.example.com       | 172.18.0.111 | Replica | running      | 55 |         0 |
   | gitlab-database-2.example.com       | 172.18.0.112 | Replica | start failed |    |   unknown |
   | gitlab-database-3.example.com       | 172.18.0.113 | Leader  | running      | 55 |           |
   +-------------------------------------+--------------+---------+--------------+----+-----------+
   ```

1. 登录到损坏的服务器并重新初始化数据库和复制。Patroni 会关闭该服务器上的 PostgreSQL，删除数据目录，并从头重新初始化：

   ```shell
   sudo gitlab-ctl patroni reinitialize-replica --member gitlab-database-2.example.com
   ```

   这可以在任何 Patroni 节点上运行，但请注意，不带 `--member` 的 `sudo gitlab-ctl patroni reinitialize-replica` 会重启运行该命令的服务器。
   您应该在损坏的服务器上本地运行它，以降低意外数据丢失的风险。
1. 监控日志：

   ```shell
   sudo gitlab-ctl tail patroni
   ```

<a id="reset-the-patroni-state-in-consul"></a>

## 重置 Consul 中的 Patroni 状态

> [!warning]
> 重置 Consul 中的 Patroni 状态是一个具有潜在破坏性的过程。请确保您首先拥有健康的数据库备份。

作为最后的手段，您可以完全重置 Consul 中的 Patroni 状态。

如果您的 Patroni 集群处于未知或不良状态，并且没有节点可以启动，则可能需要执行此操作：

```plaintext
+ Cluster: postgresql-ha (6970678148837286213) ------+---------+---------+----+-----------+
| Member                              | Host         | Role    | State   | TL | Lag in MB |
+-------------------------------------+--------------+---------+---------+----+-----------+
| gitlab-database-1.example.com       | 172.18.0.111 | Replica | stopped |    |   unknown |
| gitlab-database-2.example.com       | 172.18.0.112 | Replica | stopped |    |   unknown |
| gitlab-database-3.example.com       | 172.18.0.113 | Replica | stopped |    |   unknown |
+-------------------------------------+--------------+---------+---------+----+-----------+
```

在删除 Consul 中的 Patroni 状态之前，请先[尝试解决 Patroni 节点上的 `gitlab-ctl` 错误](#errors-running-gitlab-ctl)。

此过程会导致在第一个 Patroni 节点启动时重新初始化 Patroni 集群。

要重置 Consul 中的 Patroni 状态：

1. 记下曾经是主节点，或者应用程序认为是当前主节点的 Patroni 节点，如果当前状态显示多个或没有：
   - 查看 PgBouncer 节点上的 `/var/opt/gitlab/consul/databases.ini`，其中包含当前主节点的主机名。
   - 查看所有数据库节点上的 Patroni 日志 `/var/log/gitlab/patroni/current`（或较旧的轮转和压缩日志 `/var/log/gitlab/patroni/@40000*`），以查看集群最近将哪个服务器识别为主节点：

     ```plaintext
     INFO: no action. I am a secondary (database1.local) and following a leader (database2.local)
     ```

1. 在所有节点上停止 Patroni：

   ```shell
   sudo gitlab-ctl stop patroni
   ```

1. 重置 Consul 中的状态：

   ```shell
   /opt/gitlab/embedded/bin/consul kv delete -recurse /service/postgresql-ha/
   ```

1. 启动一个 Patroni 节点，该节点会初始化 Patroni 集群以选举主节点。
   强烈建议启动之前的主节点（在第一步中记下的），以免丢失由于集群状态损坏而可能未复制的现有写入：

   ```shell
   sudo gitlab-ctl start patroni
   ```

1. 启动所有其他作为副本加入 Patroni 集群的 Patroni 节点：

   ```shell
   sudo gitlab-ctl start patroni
   ```

如果您仍然遇到问题，下一步是恢复最后一个健康的备份。

<a id="errors-in-the-patroni-log-about-a-pg_hbaconf-entry-for-127001"></a>

## Patroni 日志中关于 `127.0.0.1` 的 `pg_hba.conf` 条目的错误

Patroni 日志中的以下日志条目表明复制未正常工作，需要进行配置更改：

```plaintext
FATAL:  主机 "127.0.0.1" 没有用于复制连接的 pg_hba.conf 条目，用户 "gitlab_replicator"
```

要解决此问题，请确保环回接口包含在 CIDR 地址列表中：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   postgresql['trust_auth_cidr_addresses'] = %w(<other_cidrs> 127.0.0.1/32)
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 检查[所有副本是否已同步](replication_and_failover.md#check-replication-status)

<a id="patroni-members-showing-as-pending-restart"></a>

## Patroni 成员显示为待重启

`gitlab-ctl patroni members` 的输出可能显示辅助站点上的 Patroni 成员状态为待重启：

```shell
secondary-site:postgresql-1> gitlab-ctl patroni members
+ Cluster: postgresql-ha ------------------------------------------------------------------+
| Member         | Host      | Role           | State   | TL | Lag in MB | Pending restart |
+----------------+-----------+----------------+---------+----+-----------+-----------------+
| patroni-1 | 10.20.0.1 | Replica        | running | 27 |         0 | *               |
| patroni-2 | 10.20.0.2 | Replica        | running | 27 |         5 | *               |
| patroni-3 | 10.20.0.3 | Standby Leader | running | 27 |           | *               |
+----------------+-----------+----------------+---------+----+-----------+----------
```

待重启状态意味着这些节点正在等待重启以应用某些配置更改。

要了解这些待重启的设置是什么，请在需要验证的实例中执行以下命令：

```shell
sudo gitlab-psql -c "select name, setting,  short_desc, sourcefile, sourceline  from pg_settings where pending_restart"
```

要应用待处理的配置更改，请重启受影响的节点：

1. 对于副本节点，运行 `sudo gitlab-ctl restart patroni`。
1. 对于主节点，请考虑先执行故障转移或运行 `sudo gitlab-ctl reload patroni` 以避免停机。

<a id="error-requested-start-point-is-ahead-of-the-write-ahead-log-wal-flush-position"></a>

## 错误：请求的起始点位于预写日志 (WAL) 刷新位置之前

Patroni 日志中的此错误表明数据库未进行复制：

```plaintext
FATAL:  无法从 WAL 流接收数据：
ERROR:  请求的起始点 0/5000000 位于此服务器的 WAL 刷新位置 0/4000388 之前
```

此示例错误来自一个最初配置错误且从未复制的副本。

通过[重新初始化副本](#reinitialize-a-replica)来修复它。

<a id="patroni-fails-to-start-with-memoryerror"></a>

## Patroni 启动失败并出现 `MemoryError`

Patroni 可能无法启动，并记录错误和堆栈跟踪：

```plaintext
MemoryError
Traceback (most recent call last):
  File "/opt/gitlab/embedded/bin/patroni", line 8, in <module>
    sys.exit(main())
[..]
  File "/opt/gitlab/embedded/lib/python3.7/ctypes/__init__.py", line 273, in _reset_cache
    CFUNCTYPE(c_int)(lambda: None)
```

如果堆栈跟踪以 `CFUNCTYPE(c_int)(lambda: None)` 结尾，则此代码会在 Linux 服务器因安全原因进行了加固时触发 `MemoryError`。

该代码会导致 Python 写入临时可执行文件，如果找不到可以执行此操作的文件系统，则会失败。例如，如果在 `/tmp` 文件系统上设置了 `noexec`，则会失败并出现 `MemoryError`（[在议题中了解更多](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/6184)）。

<a id="errors-running-gitlab-ctl"></a>

## 运行 `gitlab-ctl` 时出错

Patroni 节点可能会进入 `gitlab-ctl` 命令失败且 `gitlab-ctl reconfigure` 无法修复该节点的状态。

如果这与 PostgreSQL 版本升级同时发生，请[遵循其他步骤](#postgresql-major-version-upgrade-fails-on-a-patroni-replica)。

一个常见症状是，如果数据库服务器无法启动，`gitlab-ctl` 无法确定其所需的安装信息：

```plaintext
在 /opt/gitlab/embedded/nodes/<HOSTNAME>.json 中找到格式错误的配置 JSON 文件。
这通常发生在您上次运行 `gitlab-ctl reconfigure` 未成功完成时。
```

```plaintext
在当前节点上重新初始化副本时出错：在 /opt/gitlab/embedded/nodes/<HOSTNAME>.json 中未找到属性，是否已运行 reconfigure？
```

同样，节点文件 (`/opt/gitlab/embedded/nodes/<HOSTNAME>.json`) 应包含大量信息，但可能仅创建为：

```json
{
  "name": "<HOSTNAME>"
}
```

以下修复过程包括重新初始化此副本：此节点上 PostgreSQL 的当前状态将被丢弃：

1. 关闭 Patroni 和（如果存在）PostgreSQL 服务：

   ```shell
   sudo gitlab-ctl status
   sudo gitlab-ctl stop patroni
   sudo gitlab-ctl stop postgresql
   ```

1. 删除 `/var/opt/gitlab/postgresql/data`，以防其状态阻止 PostgreSQL 启动：

   ```shell
   cd /var/opt/gitlab/postgresql
   sudo rm -rf data
   ```

   > [!warning]
   > 执行此步骤时要小心，以避免数据丢失。
   > 此步骤也可以通过重命名 `data/` 来实现：
   > 确保有足够的可用磁盘空间用于主数据库的新副本，
   > 并在副本修复后删除额外的目录。

1. 在 PostgreSQL 未运行的情况下，现在可以成功创建节点文件：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 启动 Patroni：

   ```shell
   sudo gitlab-ctl start patroni
   ```

1. 监控日志并检查集群状态：

   ```shell
   sudo gitlab-ctl tail patroni
   sudo gitlab-ctl patroni members
   ```

1. 再次运行 `reconfigure`：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 如果 `gitlab-ctl patroni members` 指示需要，则重新初始化副本：

   ```shell
   sudo gitlab-ctl patroni reinitialize-replica
   ```

如果此过程不起作用，并且集群无法选举主节点，[还有另一种修复方法](#reset-the-patroni-state-in-consul)，但只能作为最后的手段使用。

<a id="postgresql-major-version-upgrade-fails-on-a-patroni-replica"></a>

## Patroni 副本上的 PostgreSQL 主版本升级失败

在 `gitlab-ctl pg-upgrade` 期间，Patroni 副本可能会陷入循环，导致升级失败。

一组示例症状如下：

1. 定义了一个 `postgresql` 服务，该服务通常不应出现在 Patroni 节点上。它存在是因为 `gitlab-ctl pg-upgrade` 添加了它以创建一个新的空数据库：

   ```plaintext
   run: patroni: (pid 1972) 1919s; run: log: (pid 1971) 1919s
   down: postgresql: 1s, normally up, want up; run: log: (pid 1973) 1919s
   ```

1. PostgreSQL 在 `/var/log/gitlab/postgresql/current` 中生成 `PANIC` 日志条目，因为 Patroni 正在删除 `/var/opt/gitlab/postgresql/data` 作为重新初始化副本的一部分：

   ```plaintext
   DETAIL:  无法打开文件 "pg_xact/0000"：没有那个文件或目录。
   WARNING:  由于另一个服务器进程崩溃而终止连接
   LOG:  所有服务器进程已终止；重新初始化
   PANIC:  无法打开文件 "global/pg_control"：没有那个文件或目录
   ```

1. 在 `/var/log/gitlab/patroni/current` 中，Patroni 记录以下内容。本地 PostgreSQL 版本与集群主节点不同：

   ```plaintext
   INFO: 尝试从主节点 'HOSTNAME' 引导
   pg_basebackup: 不兼容的服务器版本 12.6
   pg_basebackup: 正在删除数据目录 "/var/opt/gitlab/postgresql/data"
   ERROR: 获取备份时出错：pg_basebackup 退出，代码为 1
   ```

此解决方法适用于 Patroni 集群处于以下状态时：

- [主节点已成功升级到新的主版本](replication_and_failover.md#upgrading-postgresql-major-version-in-a-patroni-cluster)。
- 在副本上升级 PostgreSQL 的步骤失败。

此解决方法通过将节点设置为使用新的 PostgreSQL 版本，然后将其重新初始化为升级主节点时创建的新集群中的副本，来完成 Patroni 副本上的 PostgreSQL 升级：

1. 在所有节点上检查集群状态，以确认哪个是主节点以及副本处于什么状态

   ```shell
   sudo gitlab-ctl patroni members
   ```

1. 副本：检查哪个版本的 PostgreSQL 处于活动状态：

   ```shell
   sudo ls -al /opt/gitlab/embedded/bin | grep postgres
   ```

1. 副本：确保节点文件正确且 `gitlab-ctl` 可以运行。如果副本也存在任何[运行 `gitlab-ctl` 时出错](#errors-running-gitlab-ctl)的问题，此步骤可解决这些问题：

   ```shell
   sudo gitlab-ctl stop patroni
   sudo gitlab-ctl reconfigure
   ```

1. 副本：重新链接 PostgreSQL 二进制文件到所需版本，以修复 `不兼容的服务器版本` 错误：

   1. 编辑 `/etc/gitlab/gitlab.rb` 并指定所需版本：

      ```ruby
      postgresql['version'] = 13
      ```

   1. 重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 检查二进制文件是否已重新链接。PostgreSQL 分发的二进制文件因主版本而异，通常会有少量不正确的符号链接：

      ```shell
      sudo ls -al /opt/gitlab/embedded/bin | grep postgres
      ```

1. 副本：确保 PostgreSQL 已针对指定版本完全重新初始化：

   ```shell
   cd /var/opt/gitlab/postgresql
   sudo rm -rf data
   sudo gitlab-ctl reconfigure
   ```

1. 副本：可选择在两个额外的终端会话中监控数据库：

   - 随着 `pg_basebackup` 运行，磁盘使用量会增加。使用以下命令跟踪副本初始化进度：

     ```shell
     cd /var/opt/gitlab/postgresql
     watch du -sh data
     ```

   - 在日志中监控过程：

     ```shell
     sudo gitlab-ctl tail patroni
     ```

1. 副本：启动 Patroni 以重新初始化副本：

   ```shell
   sudo gitlab-ctl start patroni
   ```

1. 副本：完成后，从 `/etc/gitlab/gitlab.rb` 中删除硬编码的版本：

   1. 编辑 `/etc/gitlab/gitlab.rb` 并移除 `postgresql['version']`。
   1. 重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 检查是否链接了正确的二进制文件：

      ```shell
      sudo ls -al /opt/gitlab/embedded/bin | grep postgres
      ```

1. 在所有节点上检查集群状态：

   ```shell
   sudo gitlab-ctl patroni members
   ```

如果需要，在另一个副本上重复此过程。

<a id="postgresql-replicas-stuck-in-loop-while-being-created"></a>

## PostgreSQL 副本在创建时陷入循环

如果 PostgreSQL 副本似乎正在迁移但随后循环重启，请检查副本和主服务器上的 `/opt/gitlab-data/postgresql/` 文件夹权限。

您还可能在日志中看到此错误消息：
`无法获取 COPY 数据流：错误：无法打开文件 "<file>" 权限被拒绝`。

<a id="issues-with-other-components"></a>

## 其他组件的问题

如果您遇到此处未列出的组件问题，请务必查看其特定文档页面的故障排除部分：

- [Consul](../consul.md#troubleshooting-consul)
- [PostgreSQL](https://gitlab.cn/docs/omnibus/settings/database/#troubleshooting)

