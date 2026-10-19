---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: PostgreSQL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页包含极狐GitLab 支持团队在故障排除时使用的 PostgreSQL 相关信息。极狐GitLab 公开这些信息，以便任何人都能利用支持团队收集的知识。

> [!warning]
> 此处记录的某些操作可能会损坏您的极狐GitLab 实例。请自行承担风险。

如果您使用的是[付费版本](https://gitlab.cn/pricing)，且不确定如何使用这些命令，请[联系支持团队](https://gitlab.cn/support)，以获取针对您所遇问题的帮助。

<a id="start-a-database-console"></a>

## 启动数据库控制台

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

推荐用于：

- 单节点实例。
- 横向扩展或混合环境，在 Patroni 节点上，通常是领导者节点。
- 横向扩展或混合环境，在运行 PostgreSQL 服务的服务器上。

```shell
sudo gitlab-psql
```

在单节点实例，或 Web 或 Sidekiq 节点上，您也可以使用 Rails 数据库控制台，但它的初始化时间更长：

```shell
sudo gitlab-rails dbconsole --database main
```

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
docker exec -it <container-id> gitlab-psql
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

使用[您的 PostgreSQL 安装](../../install/self_compiled/_index.md#7-database)自带的 `psql` 命令。

```shell
sudo -u git -H psql -d gitlabhq_production
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

- 如果您运行的是混合环境，且 PostgreSQL 运行在 Linux 软件包安装（Omnibus）上，推荐的做法是在这些服务器上本地使用数据库控制台。请参阅 Linux 软件包的详细信息。
- 使用外部第三方 PostgreSQL 服务自带的控制台。
- 在 toolbox pod 中运行 `gitlab-rails dbconsole`。
  - 详情请参阅我们的 [Kubernetes 速查表](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/#gitlab-specific-kubernetes-information)。

> [!note]
> 对于使用托管 PostgreSQL 服务（如 AWS RDS）的云原生部署，您无法直接修改数据库配置文件。请改为通过云服务的参数组或配置界面来配置 PostgreSQL 参数。

{{< /tab >}}

{{< /tabs >}}

要退出控制台，请输入：`quit`。

<a id="other-gitlab-postgresql-documentation"></a>

## 其他极狐GitLab PostgreSQL 文档

本节提供指向极狐GitLab 文档中其他位置信息的链接。

<a id="procedures"></a>

### 操作步骤

- [Linux 软件包安装的数据库操作步骤](https://gitlab.cn/docs/omnibus/settings/database/)，包括：
  - SSL：启用、禁用和验证。
  - 启用预写式日志（WAL）归档。
  - 使用外部（非 Omnibus）PostgreSQL 安装并对其进行备份。
  - 除套接字外，或代替套接字，监听 TCP/IP。
  - 将数据存储在其他位置。
  - 以破坏性方式重新初始化极狐GitLab 数据库。
  - 有关更新随包提供的 PostgreSQL 的指导，包括如何阻止其自动更新。
- [关于外部 PostgreSQL 的信息](../postgresql/external.md)。
- [使用外部 PostgreSQL 运行 Geo](../geo/setup/external_database.md)。
- [运行配置为高可用的 PostgreSQL 时的升级](https://gitlab.cn/docs/omnibus/settings/database/#upgrading-a-gitlab-ha-cluster)。
- 从 [CI runner 内部](../../ci/services/postgres.md)使用 PostgreSQL。
- 从 Linux 软件包开发文档中管理 Linux 软件包安装上的 PostgreSQL 版本。
- [PostgreSQL 扩展](../postgresql/replication_and_failover.md)
  - 包括[故障排除](../postgresql/replication_and_failover_troubleshooting.md)
    `gitlab-ctl patroni check-leader` 和 PgBouncer 错误。
- 开发者数据库文档，
  其中部分内容绝对不适用于生产环境。包括：
  - 理解 EXPLAIN 计划。

<a id="support-topics"></a>

## 支持主题

<a id="database-deadlocks"></a>

### 数据库死锁

参考资料：

- [如果实例被大量推送淹没，可能会发生死锁](https://gitlab.com/gitlab-org/gitlab/-/issues/33650)。
  提供此内容是为了说明极狐GitLab 代码在异常情况下如何产生这类
  意料之外的影响。

```plaintext
ERROR: deadlock detected
```

议题 [#30528](https://gitlab.com/gitlab-org/gitlab/-/issues/30528)中确定了三个适用的超时；我们推荐的设置如下：

```ini
deadlock_timeout = 5s
statement_timeout = 15s
idle_in_transaction_session_timeout = 60s
```

引用议题 [#30528](https://gitlab.com/gitlab-org/gitlab/-/issues/30528)中的内容：

<!-- vale gitlab_base.FutureTense = NO -->

> “如果发生死锁，而我们通过在短时间后中止事务来解决它，那么我们已有的重试机制会让死锁的那部分工作再次尝试，而且我们不太可能连续多次发生死锁。”

<!-- vale gitlab_base.FutureTense = YES -->

> [!note]
> 在支持团队中，我们重新配置超时的一般做法（同样适用于
> HTTP 栈）是：可以将其作为变通方法临时进行。如果
> 它能让客户正常使用极狐GitLab，那么就能争取时间来更全面地理解
> 问题、实施热修复，或做出其他
> 解决根本原因的更改。通常，在根本原因解决后，应将超时恢复为
> 合理的默认值。

在这种情况下，开发团队给我们的指导是降低 `deadlock_timeout` 或 `statement_timeout`，但将第三个设置保留为 60 秒。设置 `idle_in_transaction` 可以保护数据库，避免会话可能挂起数天。更多讨论见[关于在 GitLab.com 上引入此超时的议题](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/1053)。

PostgreSQL 默认值：

- `statement_timeout = 0`（永不超时）
- `idle_in_transaction_session_timeout = 0`（永不超时）

议题 [#30528](https://gitlab.com/gitlab-org/gitlab/-/issues/30528)中的评论指出，对于所有 Linux 软件包安装，这两项都应至少设置为若干分钟（以免无限期挂起）。不过，`statement_timeout`的 15 秒非常短，只有在底层基础设施性能非常高时才有效。

使用以下命令查看当前设置：

```shell
sudo gitlab-rails runner "c = ApplicationRecord.connection ; puts c.execute('SHOW statement_timeout').to_a ;
puts c.execute('SHOW deadlock_timeout').to_a ;
puts c.execute('SHOW idle_in_transaction_session_timeout').to_a ;"
```

响应可能需要一点时间。

```ruby
{"statement_timeout"=>"1min"}
{"deadlock_timeout"=>"0"}
{"idle_in_transaction_session_timeout"=>"1min"}
```

可以在 `/etc/gitlab/gitlab.rb`中使用以下内容更新这些设置：

```ruby
postgresql['deadlock_timeout'] = '5s'
postgresql['statement_timeout'] = '15s'
postgresql['idle_in_transaction_session_timeout'] = '60s'
```

保存后，[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

> [!note]
> 这些是 Linux 软件包设置。如果使用外部数据库，例如客户的 PostgreSQL 安装
> 或 Amazon RDS，则不会设置这些值，必须在外部进行设置。

<a id="temporarily-changing-the-statement-timeout"></a>

### 临时更改语句超时

> [!warning]
> 如果启用了
> [PgBouncer](../postgresql/pgbouncer.md)，则以下建议不适用，
> 因为更改后的超时可能会影响比预期更多的事务。

在某些情况下，您可能希望设置不同的语句超时，而无需[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)，因为在这种情况下重新配置会重启 Puma 和 Sidekiq。

例如，由于语句超时太短，备份可能会失败，并在[备份命令](../backup_restore/_index.md#back-up-gitlab)的输出中显示以下错误：

```plaintext
pg_dump: error: Error message from server: server closed the connection unexpectedly
```

您也可能在 [PostgreSQL 日志](../logs/_index.md#postgresql-logs)中看到错误：

```plaintext
canceling statement due to statement timeout
```

<a id="for-linux-package-installations"></a>

#### 对于 Linux 软件包安装

要临时更改语句超时：

1. 在编辑器中打开 `/var/opt/gitlab/gitlab-rails/etc/database.yml`
1. 将 `statement_timeout`的值设置为 `0`，即设置无限制的语句超时。
1. [在新的 Rails 控制台会话中确认](../operations/rails_console.md#using-the-rails-runner)
   使用了该值：

   ```shell
   sudo gitlab-rails runner "ActiveRecord::Base.connection_db_config[:variables]"
   ```

1. 执行需要不同超时的操作
   （例如备份或 Rails 命令）。
1. 还原对 `/var/opt/gitlab/gitlab-rails/etc/database.yml`的编辑。

<a id="for-cloud-native-deployments"></a>

#### 对于云原生部署

对于使用托管 PostgreSQL 服务（如 AWS RDS、Azure Database for PostgreSQL 或 Google Cloud SQL）的云原生部署，您无法直接修改数据库配置文件。请改为通过云服务的参数组或配置界面配置 `statement_timeout` 参数：

- **AWS RDS**：修改与您的数据库实例关联的参数组，并将 `statement_timeout` 设置为 `0`（无限制）。
- **Azure Database for PostgreSQL**：在 Azure 门户中更新服务器参数，并将 `statement_timeout` 设置为 `0`。
- **Google Cloud SQL**：修改数据库标志，并将 `statement_timeout` 设置为 `0`。

更改参数组或配置后，您可能需要重启数据库实例才能使更改生效。具体说明请查阅您的云提供商文档。

<a id="observe-reindex-progress-report"></a>

### 观察 (RE)INDEX 进度报告

在某些情况下，您可能希望观察 `CREATE INDEX` 或 `REINDEX` 操作的进度。例如，您可以借此确认 `CREATE INDEX` 或 `REINDEX` 操作是否处于活动状态，或检查该操作处于哪个阶段。

先决条件：

- 您必须使用 PostgreSQL 12 或更高版本。

要观察 `CREATE INDEX` 或 `REINDEX` 操作：

- 使用内置的 [`pg_stat_progress_create_index` 视图](https://www.postgresql.org/docs/16/progress-reporting.html#CREATE-INDEX-PROGRESS-REPORTING)。

例如，在数据库控制台会话中，运行以下命令：

```sql
SELECT * FROM  pg_stat_progress_create_index \watch 0.2
```

要详细了解如何生成人类友好的输出以及将数据写入日志文件，请参阅[此代码片段](https://gitlab.com/-/snippets/3750940)。

<a id="troubleshooting"></a>

## 故障排除

<a id="database-connection-is-refused"></a>

### 数据库连接被拒绝

如果您遇到以下错误，请检查 `max_connections` 是否足够高，以确保连接稳定。

```shell
connection to server at "xxx.xxx.xxx.xxx", port 5432 failed: Connection refused
      Is the server running on that host and accepting TCP/IP connections?
```

```shell
psql: error: connection to server on socket "/var/opt/gitlab/postgresql/.s.PGSQL.5432" failed:
FATAL:  sorry, too many clients already
```

要调整 `max_connections`，请参阅[配置多个数据库连接](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections)。

<a id="database-is-not-accepting-commands-to-avoid-wraparound-data-loss"></a>

### 数据库不接受命令，以避免回卷数据丢失

此错误很可能意味着 `autovacuum` 未能完成其运行：

```plaintext
ERROR:  database is not accepting commands to avoid wraparound data loss in database "gitlabhq_production"
```

或

```plaintext
 ERROR:  failed to re-find parent key in index "XXX" for deletion target page XXX
```

要解决该错误，请手动运行 `VACUUM`：

1. 使用命令 `gitlab-ctl stop` 停止极狐GitLab。
1. 使用以下命令将数据库置于单用户模式：

   ```shell
   /opt/gitlab/embedded/bin/postgres --single -D /var/opt/gitlab/postgresql/data gitlabhq_production
   ```

1. 在 `backend>` 提示符下，运行 `VACUUM;`。此命令可能需要几分钟才能完成。
1. 等待命令完成，然后按 <kbd>Control</kbd> + <kbd>D</kbd> 退出。
1. 使用命令 `gitlab-ctl start` 启动极狐GitLab。

<a id="gitlab-database-requirements"></a>

### 极狐GitLab 数据库要求

请参阅[数据库要求](../../install/requirements.md#postgresql)，并查看和安装[所需扩展列表](../../install/requirements.md#extensions)。

<a id="serialization-errors-in-the-productionsidekiq-log"></a>

### `production/sidekiq` 日志中的序列化错误

如果您在 `production/sidekiq` 日志中收到类似以下示例的错误，请阅读
[将 `default_transaction_isolation` 设置为 read committed](https://gitlab.cn/docs/omnibus/settings/database/#set-default_transaction_isolation-into-read-committed) 以解决该问题：

```plaintext
ActiveRecord::StatementInvalid PG::TRSerializationFailure: ERROR:  could not serialize access due to concurrent update
```

<a id="postgresql-replication-slot-errors"></a>

### PostgreSQL 复制槽错误

如果您收到类似以下示例的错误，请阅读如何解决 PostgreSQL 高可用[复制槽错误](https://gitlab.cn/docs/omnibus/settings/database/#troubleshooting-upgrades-in-an-ha-cluster)：

```plaintext
pg_basebackup: could not create temporary replication slot "pg_basebackup_12345": ERROR:  all replication slots are in use
HINT:  Free one or increase max_replication_slots.
```

<a id="geo-replication-errors"></a>

### Geo 复制错误

如果您收到类似以下示例的错误，请阅读如何解决 [Geo 复制错误](../geo/replication/troubleshooting/postgresql_replication.md)：

```plaintext
ERROR: replication slots can only be used if max_replication_slots > 0

FATAL: could not start WAL streaming: ERROR: replication slot "geo_secondary_my_domain_com" does not exist

Command exceeded allowed execution time

PANIC: could not write to file 'pg_xlog/xlogtemp.123': No space left on device
```

<a id="review-geo-configuration-and-common-errors"></a>

### 检查 Geo 配置和常见错误

在对 Geo 问题进行故障排除时，您应该：

- 查看[常见 Geo 错误](../geo/replication/troubleshooting/common.md#fixing-common-errors)。
- [检查您的 Geo 配置](../geo/replication/troubleshooting/_index.md)，包括：
  - 重新配置主机和端口。
  - 检查和修复用户与密码映射。

<a id="mismatch-in-pg_dump-and-psql-versions"></a>

### `pg_dump` 和 `psql` 版本不匹配

如果您收到类似以下示例的错误，请阅读如何[备份和恢复非随包提供的 PostgreSQL 数据库](https://gitlab.cn/docs/omnibus/settings/database/#backup-and-restore-a-non-packaged-postgresql-database)：

```plaintext
Dumping PostgreSQL database gitlabhq_production ... pg_dump: error: server version: 13.3; pg_dump version: 14.2
pg_dump: error: aborting because of server version mismatch
```

<a id="extension-btree_gist-is-not-allow-listed"></a>

### 扩展 `btree_gist` 不在允许名单中

在 Azure Database for PostgreSQL - Flexible Server 上部署 PostgreSQL 可能会导致此错误：

```plaintext
extension "btree_gist" is not allow-listed for "azure_pg_admin" users in Azure Database for PostgreSQL
```

要解决此错误，请在安装前[将该扩展加入允许名单](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions)。
