---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用内置的 PgBouncer 服务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> PgBouncer 已内置在 `gitlab-ee` 软件包中，但可免费使用。
> 如需支持，您需要订阅[专业版](https://gitlab.cn/pricing)。

[PgBouncer](https://www.pgbouncer.org/) 用于在故障转移场景中无缝迁移服务器之间的数据库连接。此外，它还可以用于非容错配置中，以池化连接，从而加快响应时间并减少资源使用。

极狐GitLab 专业版包含内置的 PgBouncer 版本，可通过 `/etc/gitlab/gitlab.rb` 进行管理。

<a id="pgbouncer-as-part-of-a-fault-tolerant-gitlab-installation"></a>

## 作为容错极狐GitLab 安装的一部分的 PgBouncer

此内容已移至[新位置](replication_and_failover.md#configure-pgbouncer-nodes)。

<a id="pgbouncer-as-part-of-a-non-fault-tolerant-gitlab-installation"></a>

## 作为非容错极狐GitLab 安装的一部分的 PgBouncer

1. 使用命令 `gitlab-ctl pg-password-md5 pgbouncer` 生成 `PGBOUNCER_USER_PASSWORD_HASH`
1. 使用命令 `gitlab-ctl pg-password-md5 gitlab` 生成 `SQL_USER_PASSWORD_HASH`。稍后输入明文 SQL_USER_PASSWORD。
1. 在您的数据库节点上，确保在 `/etc/gitlab/gitlab.rb`中设置以下内容

   ```ruby
   postgresql['pgbouncer_user_password'] = 'PGBOUNCER_USER_PASSWORD_HASH'
   postgresql['sql_user_password'] = 'SQL_USER_PASSWORD_HASH'
   postgresql['listen_address'] = 'XX.XX.XX.Y' # Where XX.XX.XX.Y is the ip address on the node postgresql should listen on
   postgresql['md5_auth_cidr_addresses'] = %w(AA.AA.AA.B/32) # Where AA.AA.AA.B is the IP address of the pgbouncer node
   ```

1. 运行 `gitlab-ctl reconfigure`

   > [!note]
   > 如果数据库已在运行，则需要在重新配置后通过运行 `gitlab-ctl restart postgresql` 重启数据库。

1. 在运行 PgBouncer 的节点上，确保在 `/etc/gitlab/gitlab.rb`中设置以下内容

   ```ruby
   pgbouncer['enable'] = true
   pgbouncer['databases'] = {
     gitlabhq_production: {
       host: 'DATABASE_HOST',
       user: 'pgbouncer',
       password: 'PGBOUNCER_USER_PASSWORD_HASH'
     }
   }
   ```

   您可以为每个数据库传递额外的配置参数，例如：

   ```ruby
   pgbouncer['databases'] = {
     gitlabhq_production: {
        ...
        pool_mode: 'transaction'
     }
   }
   ```

   请谨慎使用这些参数。有关参数的完整列表，请参阅
   [PgBouncer 文档](https://www.pgbouncer.org/config.html#section-databases)。

1. 运行 `gitlab-ctl reconfigure`
1. 在运行 Puma 的节点上，确保在 `/etc/gitlab/gitlab.rb`中设置以下内容

   ```ruby
   gitlab_rails['db_host'] = 'PGBOUNCER_HOST'
   gitlab_rails['db_port'] = '6432'
   gitlab_rails['db_password'] = 'SQL_USER_PASSWORD'
   ```

1. 运行 `gitlab-ctl reconfigure`
1. 此时，您的实例应通过 PgBouncer 连接到数据库。如果您遇到问题，请参阅[故障排除](#troubleshooting)部分

<a id="backups"></a>

## 备份

不要通过 PgBouncer 连接备份或恢复极狐GitLab：这会导致极狐GitLab 中断。

[详细了解此问题以及如何重新配置备份](../backup_restore/backup_gitlab.md#back-up-and-restore-for-installations-using-pgbouncer)。

<a id="enable-monitoring"></a>

## 启用监控

如果启用监控，则必须在所有 PgBouncer 服务器上启用。

1. 创建/编辑 `/etc/gitlab/gitlab.rb` 并添加以下配置：

   ```ruby
   # Enable service discovery for Prometheus
   consul['enable'] = true
   consul['monitoring_service_discovery'] =  true

   # Replace placeholders
   # Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z
   # with the addresses of the Consul server nodes
   consul['configuration'] = {
      retry_join: %w(Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z),
   }

   # Set the network addresses that the exporters will listen on
   node_exporter['listen_address'] = '0.0.0.0:9100'
   pgbouncer_exporter['listen_address'] = '0.0.0.0:9188'
   ```

1. 运行 `sudo gitlab-ctl reconfigure` 以编译配置。

<a id="administrative-console"></a>

## 管理控制台

在 Linux 软件包安装中，提供了一个命令来自动连接到 PgBouncer 管理控制台。有关如何与控制台交互的详细说明，请参阅
[PgBouncer 文档](https://www.pgbouncer.org/usage.html#admin-console)。

要启动会话，请运行以下命令并提供 `pgbouncer` 用户的密码：

```shell
sudo gitlab-ctl pgb-console
```

要获取有关实例的一些基本信息：

```shell
pgbouncer=# show databases; show clients; show servers;
        name         |   host    | port |      database       | force_user | pool_size | reserve_pool | pool_mode | max_connections | current_connections
---------------------+-----------+------+---------------------+------------+-----------+--------------+-----------+-----------------+---------------------
 gitlabhq_production | 127.0.0.1 | 5432 | gitlabhq_production |            |       100 |            5 |           |               0 |                   1
 pgbouncer           |           | 6432 | pgbouncer           | pgbouncer  |         2 |            0 | statement |               0 |                   0
(2 rows)

 type |   user    |      database       | state  |   addr    | port  | local_addr | local_port |    connect_time     |    request_time     |    ptr    | link
| remote_pid | tls
------+-----------+---------------------+--------+-----------+-------+------------+------------+---------------------+---------------------+-----------+------
+------------+-----
 C    | gitlab    | gitlabhq_production | active | 127.0.0.1 | 44590 | 127.0.0.1  |       6432 | 2018-04-24 22:13:10 | 2018-04-24 22:17:10 | 0x12444c0 |
|          0 |
 C    | gitlab    | gitlabhq_production | active | 127.0.0.1 | 44592 | 127.0.0.1  |       6432 | 2018-04-24 22:13:10 | 2018-04-24 22:17:10 | 0x12447c0 |
|          0 |
 C    | gitlab    | gitlabhq_production | active | 127.0.0.1 | 44594 | 127.0.0.1  |       6432 | 2018-04-24 22:13:10 | 2018-04-24 22:17:10 | 0x1244940 |
|          0 |
 C    | gitlab    | gitlabhq_production | active | 127.0.0.1 | 44706 | 127.0.0.1  |       6432 | 2018-04-24 22:14:22 | 2018-04-24 22:16:31 | 0x1244ac0 |
|          0 |
 C    | gitlab    | gitlabhq_production | active | 127.0.0.1 | 44708 | 127.0.0.1  |       6432 | 2018-04-24 22:14:22 | 2018-04-24 22:15:15 | 0x1244c40 |
|          0 |
 C    | gitlab    | gitlabhq_production | active | 127.0.0.1 | 44794 | 127.0.0.1  |       6432 | 2018-04-24 22:15:15 | 2018-04-24 22:15:15 | 0x1244dc0 |
|          0 |
 C    | gitlab    | gitlabhq_production | active | 127.0.0.1 | 44798 | 127.0.0.1  |       6432 | 2018-04-24 22:15:15 | 2018-04-24 22:16:31 | 0x1244f40 |
|          0 |
 C    | pgbouncer | pgbouncer           | active | 127.0.0.1 | 44660 | 127.0.0.1  |       6432 | 2018-04-24 22:13:51 | 2018-04-24 22:17:12 | 0x1244640 |
|          0 |
(8 rows)

 type |  user  |      database       | state |   addr    | port | local_addr | local_port |    connect_time     |    request_time     |    ptr    | link | rem
ote_pid | tls
------+--------+---------------------+-------+-----------+------+------------+------------+---------------------+---------------------+-----------+------+----
--------+-----
 S    | gitlab | gitlabhq_production | idle  | 127.0.0.1 | 5432 | 127.0.0.1  |      35646 | 2018-04-24 22:15:15 | 2018-04-24 22:17:10 | 0x124dca0 |      |
  19980 |
(1 row)
```

<a id="procedure-for-bypassing-pgbouncer"></a>

## 绕过 PgBouncer 的步骤

<a id="linux-package-installations"></a>

### Linux 软件包安装

某些数据库更改必须直接进行，而不能通过 PgBouncer 进行。

主要受影响的任务是[数据库恢复](../backup_restore/backup_gitlab.md#back-up-and-restore-for-installations-using-pgbouncer)和[带数据库迁移的极狐GitLab 升级](../../update/zero_downtime.md)。

1. 要查找主节点，请在数据库节点上运行以下命令：

   ```shell
   sudo gitlab-ctl patroni members
   ```

1. 在您执行任务的应用节点上编辑 `/etc/gitlab/gitlab.rb`，并使用数据库主节点的主机名和端口更新 `gitlab_rails['db_host']` 和 `gitlab_rails['db_port']`。

1. 运行重新配置：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

执行完任务或步骤后，切换回使用 PgBouncer：

1. 将 `/etc/gitlab/gitlab.rb` 改回指向 PgBouncer。
1. 运行重新配置：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="helm-chart-installations"></a>

### Helm chart 安装

高可用部署也需要出于与基于 Linux 软件包的部署相同的原因绕过 PgBouncer。
对于 Helm chart 安装：

- 数据库备份和恢复任务由 toolbox 容器执行。
- 迁移任务由 migrations 容器执行。

您应覆盖每个子 chart 上的 PostgreSQL 端口，以便这些任务可以执行并直接连接到 PostgreSQL：

- [Toolbox](https://jihulab.com/gitlab-cn/charts/gitlab/-/blob/master/charts/gitlab/charts/toolbox/values.yaml#L40)
- [Migrations](https://jihulab.com/gitlab-cn/charts/gitlab/-/blob/master/charts/gitlab/charts/migrations/values.yaml#L46)

<a id="fine-tuning"></a>

## 微调

PgBouncer 的默认设置适用于大多数安装。在特定情况下，您可能需要更改性能特定和资源特定的变量，以提高可能的吞吐量，或限制可能导致数据库内存耗尽的资源使用。

您可以在[官方 PgBouncer 文档](https://www.pgbouncer.org/config.html)中找到参数及各自的文档。下面列出了 Linux 软件包安装中最相关的参数及其默认值：

- `pgbouncer['max_client_conn']`（默认值：`2048`，取决于服务器文件描述符限制）
  这是 PgBouncer 中的“前端”池：从 Rails 到 PgBouncer 的连接。
- `pgbouncer['default_pool_size']`（默认值：`100`）
  这是 PgBouncer 中的“后端”池：从 PgBouncer 到数据库的连接。

有关为您的拓扑调整 `max_client_conn` 和 `default_pool_size` 大小的详细指导，请参阅[使用 PgBouncer](tune.md#with-pgbouncer)。

`pgbouncer['max_client_conn']` 是 PgBouncer 可以接受的连接硬限制。您不太可能需要更改此值。如果您达到了该限制，您可能需要考虑使用内部负载均衡器添加额外的 PgBouncer。

在为指向 Geo 跟踪数据库的 PgBouncer 设置限制时，您通常可以忽略公式中的 `puma`，因为它只是偶尔访问该数据库。

<a id="pooling-mode"></a>

### 池化模式

极狐GitLab 要求 PgBouncer 在**事务池化模式**（`pool_mode = transaction`）下运行。
在此模式下，后端连接仅在单个事务期间保持，然后返回池中。这允许许多前端连接共享一小部分后端连接，因此可以按[使用 PgBouncer](tune.md#with-pgbouncer)中的说明减少 `max_connections`。

在会话模式下，每个前端连接在其整个生命周期内都保持一个后端连接。后端池不会小于前端需求，因此不会发生 `max_connections` 减少。

<a id="troubleshooting"></a>

## 故障排除

如果您在通过 PgBouncer 连接时遇到任何问题，首先要检查的始终是日志：

```shell
sudo gitlab-ctl tail pgbouncer
```

此外，您可以在[管理控制台](#administrative-console)中检查 `show databases`的输出。在输出中，您应该会在 `gitlabhq_production` 数据库的 `host` 字段中看到值。此外，`current_connections` 应大于 1。

<a id="message-log--invalid-cidr-mask-in-address"></a>

### 消息：`LOG:  invalid CIDR mask in address`

请参阅 [Geo 文档中的建议修复](../geo/replication/troubleshooting/postgresql_replication.md#message-log--invalid-cidr-mask-in-address)。

<a id="message-log--invalid-ip-mask-md5-name-or-service-not-known"></a>

### 消息：`LOG:  invalid IP mask "md5": Name or service not known`

请参阅 [Geo 文档中的建议修复](../geo/replication/troubleshooting/postgresql_replication.md#message-log--invalid-ip-mask-md5-name-or-service-not-known)。
