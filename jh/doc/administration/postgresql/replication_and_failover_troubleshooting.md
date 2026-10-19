---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Linux 软件包安装的 PostgreSQL 复制和故障转移
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在使用 PostgreSQL 复制和故障转移时，您可能会遇到以下问题。

<a id="consul-and-postgresql-changes-not-taking-effect"></a>

## Consul 和 PostgreSQL 的更改未生效

由于可能产生的影响，`gitlab-ctl reconfigure` 只会重新加载 Consul 和 PostgreSQL，而不会重启这些服务。但是，并非所有更改都能通过重新加载来生效。

要重启任一服务，请运行 `gitlab-ctl restart SERVICE`

对于 PostgreSQL，默认情况下重启主节点通常是安全的。自动故障转移默认超时时间为 1 分钟。只要数据库在此之前恢复，就无需执行其他操作。

在 Consul 服务器节点上，务必以受控方式[重启 Consul 服务](../consul.md#restart-consul)。

<a id="pgbouncer-error-error-pgbouncer-cannot-connect-to-server"></a>

## PgBouncer 错误 `ERROR: pgbouncer cannot connect to server`

在运行 `gitlab-rake gitlab:db:configure` 时，您可能会遇到此错误，或者您可能会在 PgBouncer 日志文件中看到该错误。

```plaintext
PG::ConnectionBad: ERROR:  pgbouncer cannot connect to server
```

问题可能在于，您的 PgBouncer 节点的 IP 地址未包含在数据库节点上 `/etc/gitlab/gitlab.rb`中的 `trust_auth_cidr_addresses` 设置中。

您可以通过检查主数据库节点上的 PostgreSQL 日志来确认这是否是问题所在。如果您看到以下错误，则说明问题出在 `trust_auth_cidr_addresses`。

```plaintext
2018-03-29_13:59:12.11776 FATAL:  no pg_hba.conf entry for host "123.123.123.123", user "pgbouncer", database "gitlabhq_production", SSL off
```

要解决此问题，请将该 IP 地址添加到 `/etc/gitlab/gitlab.rb`。

```ruby
postgresql['trust_auth_cidr_addresses'] = %w(123.123.123.123/32 <other_cidrs>)
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="reinitialize-a-replica"></a>

## 重新初始化副本

如果副本无法启动或重新加入集群，或者当它落后且无法赶上时，可能需要重新初始化副本：

1. [检查复制状态](replication_and_failover.md#check-replication-status)以确认需要重新初始化哪个服务器。例如：

   ```plaintext
   + Cluster: postgresql-ha (6970678148837286213) ------+---------+--------------+----+-----------+
   | Member                              | Host         | Role    | State        | TL | Lag in MB |
   +-------------------------------------+--------------+---------+--------------+----+-----------+
   | gitlab-database-1.example.com       | 172.18.0.111 | Replica | running      | 55 |         0 |
   | gitlab-database-2.example.com       | 172.18.0.112 | Replica | start failed |    |   unknown |
   | gitlab-database-3.example.com       | 172.18.0.113 | Leader  | running      | 55 |           |
   +-------------------------------------+--------------+---------+--------------+----+-----------+
   ```

1. 登录到故障服务器并重新初始化数据库和复制。Patroni 会关闭该服务器上的 PostgreSQL，删除数据目录，并从头重新初始化：

   ```shell
   sudo gitlab-ctl patroni reinitialize-replica --member gitlab-database-2.example.com
   ```

   这可以在任何 Patroni 节点上运行，但请注意，不带 `--member`的 `sudo gitlab-ctl patroni reinitialize-replica` 会重启运行它的服务器。您应在故障服务器上本地运行它，以降低意外数据丢失的风险。
1. 监控日志：

   ```shell
   sudo gitlab-ctl tail patroni
   ```

如果仍然遇到问题，请删除数据目录并手动重新初始化副本：

1. 停止 Patroni：

   ```shell
   sudo gitlab-ctl stop patroni
   ```

   > [!warning]
   > 此步骤会永久删除此节点上的所有 PostgreSQL 数据。请确保您在正确的副本节点（而非主节点）上运行此操作。

   ```shell
   sudo rm -rf /var/opt/gitlab/postgresql/data
   ```

1. 重新配置极狐GitLab：

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

<a id="reset-the-patroni-state-in-consul"></a>

## 重置 Consul 中的 Patroni 状态

> [!warning]
> 重置 Consul 中的 Patroni 状态是一个可能具有破坏性的过程。请确保您首先拥有健康的数据库备份。

作为最后的手段，您可以完全重置 Consul 中的 Patroni 状态。

如果您的 Patroni 集群处于未知或不良状态，且没有任何节点能够启动，则可能需要这样做：

```plaintext
+ Cluster: postgresql-ha (6970678148837286213) ------+---------+---------+----+-----------+
| Member                              | Host         | Role    | State   | TL | Lag in MB |
+-------------------------------------+--------------+---------+---------+----+-----------+
| gitlab-database-1.example.com       | 172.18.0.111 | Replica | stopped |    |   unknown |
| gitlab-database-2.example.com       | 172.18.0.112 | Replica | stopped |    |   unknown |
| gitlab-database-3.example.com       | 172.18.0.113 | Replica | stopped |    |   unknown |
+-------------------------------------+--------------+---------+---------+----+-----------+
```

在删除 Consul 中的 Patroni 状态之前，请先在 Patroni 节点上[尝试解决 `gitlab-ctl` 错误](#errors-running-gitlab-ctl)。

当第一个 Patroni 节点启动时，此过程会导致 Patroni 集群被重新初始化。

要重置 Consul 中的 Patroni 状态：

1. 记下曾是主节点的 Patroni 节点，或者如果当前状态显示有多个或没有主节点，则记下应用程序认为的当前主节点：
   - 查看 PgBouncer 节点上的 `/var/opt/gitlab/consul/databases.ini`，其中包含当前主节点的主机名。
   - 查看所有数据库节点上的 Patroni 日志 `/var/log/gitlab/patroni/current`（或较旧的轮转和压缩日志 `/var/log/gitlab/patroni/@40000*`），以了解集群最近将哪个服务器识别为主节点：

     ```plaintext
     INFO: no action. I am a secondary (database1.local) and following a leader (database2.local)
     ```

1. 停止所有节点上的 Patroni：

   ```shell
   sudo gitlab-ctl stop patroni
   ```

1. 重置 Consul 中的状态：

   ```shell
   /opt/gitlab/embedded/bin/consul kv delete -recurse /service/postgresql-ha/
   ```

1. 启动一个 Patroni 节点，它会初始化 Patroni 集群以选举主节点。强烈建议启动之前的主节点（在第一步中记下的那个），以免丢失由于集群状态损坏而可能尚未复制的现有写入：

   ```shell
   sudo gitlab-ctl start patroni
   ```

1. 启动所有其他 Patroni 节点，它们会作为副本加入 Patroni 集群：

   ```shell
   sudo gitlab-ctl start patroni
   ```

如果您仍然看到问题，下一步是恢复最近一次健康的备份。

<a id="errors-in-the-patroni-log-about-a-pg_hbaconf-entry-for-127001"></a>

## Patroni 日志中关于 `127.0.0.1`的 `pg_hba.conf` 条目的错误

Patroni 日志中的以下日志条目表明复制未正常工作，需要进行配置更改：

```plaintext
FATAL:  no pg_hba.conf entry for replication connection from host "127.0.0.1", user "gitlab_replicator"
```

要解决此问题，请确保回环接口包含在 CIDR 地址列表中：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   postgresql['trust_auth_cidr_addresses'] = %w(<other_cidrs> 127.0.0.1/32)
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 检查[所有副本是否已同步](replication_and_failover.md#check-replication-status)

<a id="patroni-members-showing-as-pending-restart"></a>

## Patroni 成员显示为待重启

`gitlab-ctl patroni members`的输出可能会显示从站点上的 Patroni 成员状态为待重启：

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

要了解这些待重启设置是什么，请在您需要验证的实例中执行以下操作：

```shell
sudo gitlab-psql -c "select name, setting,  short_desc, sourcefile, sourceline  from pg_settings where pending_restart"
```

要应用待处理的配置更改，请重启受影响的节点：

1. 对于副本节点，运行 `sudo gitlab-ctl restart patroni`。
1. 对于主节点，请考虑先执行故障转移，或运行 `sudo gitlab-ctl reload patroni` 以避免停机。

<a id="error-requested-start-point-is-ahead-of-the-write-ahead-log-wal-flush-position"></a>

## 错误：请求的起始点超前于预写日志 (WAL) 刷新位置

Patroni 日志中的此错误表明数据库未在进行复制：

```plaintext
FATAL:  could not receive data from WAL stream:
ERROR:  requested starting point 0/5000000 is ahead of the WAL flush position of this server 0/4000388
```

此示例错误来自一个最初配置错误且从未进行过复制的副本。

[通过重新初始化副本](#reinitialize-a-replica)来修复它。

<a id="patroni-fails-to-start-with-memoryerror"></a>

## Patroni 因 `MemoryError` 而无法启动

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

如果堆栈跟踪以 `CFUNCTYPE(c_int)(lambda: None)` 结尾，则当 Linux 服务器出于安全考虑进行了加固时，此代码会触发 `MemoryError`。

该代码会导致 Python 写入临时可执行文件，如果找不到可用于此操作的文件系统，则会失败。例如，如果在 `/tmp` 文件系统上设置了 `noexec`，则会失败并出现 `MemoryError`（[在议题中了解更多](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6184)）。

<a id="errors-running-gitlab-ctl"></a>

## 运行 `gitlab-ctl` 时出错

Patroni 节点可能会进入一种状态，导致 `gitlab-ctl` 命令失败，且 `gitlab-ctl reconfigure` 无法修复该节点。

如果这恰好与 PostgreSQL 的版本升级同时发生，请[遵循不同的过程](#postgresql-major-version-upgrade-fails-on-a-patroni-replica)

一个常见的症状是，如果数据库服务器无法启动，`gitlab-ctl` 无法确定其所需的安装信息：

```plaintext
Malformed configuration JSON file found at /opt/gitlab/embedded/nodes/<HOSTNAME>.json.
This usually happens when your last run of `gitlab-ctl reconfigure` didn't complete successfully.
```

```plaintext
Error while reinitializing replica on the current node: Attributes not found in
/opt/gitlab/embedded/nodes/<HOSTNAME>.json, has reconfigure been run yet?
```

同样，节点文件（`/opt/gitlab/embedded/nodes/<HOSTNAME>.json`）应包含大量信息，但可能只创建了以下内容：

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
   > 请谨慎执行此步骤，以免数据丢失。
   > 此步骤也可以通过重命名 `data/` 来实现：
   > 请确保有足够的可用磁盘空间来存放主数据库的新副本，
   > 并在副本修复后删除多余的目录。

1. 在 PostgreSQL 未运行的情况下，节点文件现在可以成功创建：

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

1. 再次重新运行 `reconfigure`：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 如果 `gitlab-ctl patroni members` 表明需要，则重新初始化副本：

   ```shell
   sudo gitlab-ctl patroni reinitialize-replica
   ```

如果此过程不起作用，且集群无法选举出主节点，[还有另一种修复方法](#reset-the-patroni-state-in-consul)，但只能作为最后的手段使用。

<a id="postgresql-major-version-upgrade-fails-on-a-patroni-replica"></a>

## Patroni 副本上的 PostgreSQL 主版本升级失败

在 `gitlab-ctl pg-upgrade` 期间，Patroni 副本可能会陷入循环，导致升级失败。

一组示例症状如下：

1. 定义了一个 `postgresql` 服务，这通常不应出现在 Patroni 节点上。它之所以存在，是因为 `gitlab-ctl pg-upgrade` 添加了它以创建一个新的空数据库：

   ```plaintext
   run: patroni: (pid 1972) 1919s; run: log: (pid 1971) 1919s
   down: postgresql: 1s, normally up, want up; run: log: (pid 1973) 1919s
   ```

1. 当 Patroni 作为重新初始化副本的一部分删除 `/var/opt/gitlab/postgresql/data` 时，PostgreSQL 会在 `/var/log/gitlab/postgresql/current`中生成 `PANIC` 日志条目：

   ```plaintext
   DETAIL:  Could not open file "pg_xact/0000": No such file or directory.
   WARNING:  terminating connection because of crash of another server process
   LOG:  all server processes terminated; reinitializing
   PANIC:  could not open file "global/pg_control": No such file or directory
   ```

1. 在 `/var/log/gitlab/patroni/current`中，Patroni 记录了以下内容。本地 PostgreSQL 版本与集群主节点不同：

   ```plaintext
   INFO: trying to bootstrap from leader 'HOSTNAME'
   pg_basebackup: incompatible server version 12.6
   pg_basebackup: removing data directory "/var/opt/gitlab/postgresql/data"
   ERROR: Error when fetching backup: pg_basebackup exited with code=1
   ```

此变通方法适用于 Patroni 集群处于以下状态时：

- [主节点已成功升级到新的主版本](replication_and_failover.md#upgrading-postgresql-major-version-in-a-patroni-cluster)。
- 在副本上升级 PostgreSQL 的步骤失败。

此变通方法通过将节点设置为使用新的 PostgreSQL 版本，然后将其作为副本重新初始化到主节点升级时创建的新集群中，从而完成 Patroni 副本上的 PostgreSQL 升级：

1. 检查所有节点上的集群状态，以确认哪个是主节点以及副本处于什么状态

   ```shell
   sudo gitlab-ctl patroni members
   ```

1. 副本：检查哪个版本的 PostgreSQL 处于活动状态：

   ```shell
   sudo ls -al /opt/gitlab/embedded/bin | grep postgres
   ```

1. 副本：确保节点文件正确且 `gitlab-ctl` 可以运行。如果副本也存在这些错误，这将解决[运行 `gitlab-ctl` 时出错](#errors-running-gitlab-ctl)的问题：

   ```shell
   sudo gitlab-ctl stop patroni
   sudo gitlab-ctl reconfigure
   ```

1. 副本：将 PostgreSQL 二进制文件重新链接到所需版本，以修复 `incompatible server version` 错误：

   1. 编辑 `/etc/gitlab/gitlab.rb` 并指定所需版本：

      ```ruby
      postgresql['version'] = 13
      ```

   1. 重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 检查二进制文件是否已重新链接。为 PostgreSQL 分发的二进制文件在不同主版本之间会有所不同，通常会有少量不正确的符号链接：

      ```shell
      sudo ls -al /opt/gitlab/embedded/bin | grep postgres
      ```

1. 副本：确保 PostgreSQL 已针对指定版本完全重新初始化：

   ```shell
   cd /var/opt/gitlab/postgresql
   sudo rm -rf data
   sudo gitlab-ctl reconfigure
   ```

1. 副本：可选地，在两个额外的终端会话中监控数据库：

   - 随着 `pg_basebackup` 运行，磁盘使用量会增加。使用以下命令跟踪副本初始化的进度：

     ```shell
     cd /var/opt/gitlab/postgresql
     watch du -sh data
     ```

   - 在日志中监控该过程：

     ```shell
     sudo gitlab-ctl tail patroni
     ```

1. 副本：启动 Patroni 以重新初始化副本：

   ```shell
   sudo gitlab-ctl start patroni
   ```

1. 副本：完成后，从 `/etc/gitlab/gitlab.rb`中移除硬编码的版本：

   1. 编辑 `/etc/gitlab/gitlab.rb` 并移除 `postgresql['version']`。
   1. 重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 检查是否链接了正确的二进制文件：

      ```shell
      sudo ls -al /opt/gitlab/embedded/bin | grep postgres
      ```

1. 检查所有节点上的集群状态：

   ```shell
   sudo gitlab-ctl patroni members
   ```

如果需要，请在其他副本上重复此过程。

<a id="postgresql-replicas-stuck-in-loop-while-being-created"></a>

## PostgreSQL 副本在创建时陷入循环

如果 PostgreSQL 副本似乎进行了迁移，但随后在循环中重启，请检查副本和主服务器上的 `/opt/gitlab-data/postgresql/` 文件夹权限。

您还可以在日志中看到此错误消息：
`could not get COPY data stream: ERROR: could not open file "<file>" Permission denied`。

<a id="issues-with-other-components"></a>

## 其他组件的问题

如果您遇到此处未列出的组件问题，请务必查看其特定文档页面中的故障排除部分：

- [Consul](../consul.md#troubleshooting-consul)
- [PostgreSQL](https://gitlab.cn/docs/omnibus/settings/database/#troubleshooting)
