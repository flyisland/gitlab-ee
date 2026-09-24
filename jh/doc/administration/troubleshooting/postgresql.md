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

此页面包含极狐GitLab 支持团队在故障排除时使用的有关 PostgreSQL 的信息。极狐GitLab 将这些信息公开，以便任何人都可以利用支持团队收集的知识。

> [!warning]
> 此处记录的某些步骤可能会损坏您的极狐GitLab 实例。请自行承担风险。

如果您使用的是[付费版本](https://gitlab.cn/pricing/) 并且不确定如何使用这些命令，请[联系支持](https://gitlab.cn/support/) 以获取有关您遇到的任何问题的帮助。

<a id="other-gitlab-postgresql-documentation"></a>

## 其他极狐GitLab PostgreSQL 文档

本节提供了指向极狐GitLab 文档中其他相关信息的链接。

<a id="procedures"></a>

### 步骤

- [针对 Linux 软件包安装的数据库步骤](https://gitlab.cn/docs/omnibus/settings/database/) 包括：
  - SSL：启用、禁用和验证。
  - 启用预写日志（WAL）归档。
  - 使用外部（非 Omnibus）PostgreSQL 安装并进行备份。
  - 通过 TCP/IP 以及（或代替）套接字进行监听。
  - 将数据存储在其他位置。
  - 以破坏性方式重新 seeding 极狐GitLab 数据库。
  - 有关更新打包的 PostgreSQL 的指导，包括如何阻止其自动发生。
- [有关外部 PostgreSQL 的信息](../postgresql/external.md)。
- [在外部 PostgreSQL 上运行 Geo](../geo/setup/external_database.md)。
- [在针对高可用性配置 PostgreSQL 的情况下进行升级](https://gitlab.cn/docs/omnibus/settings/database/#upgrading-a-gitlab-ha-cluster)。
- [在 CI runner 中使用 PostgreSQL](../../ci/services/postgres.md)。
- 管理来自 Linux 软件包开发文档的 Linux 软件包安装中的 PostgreSQL 版本。
- [PostgreSQL 扩展](../postgresql/replication_and_failover.md)
  - 包括[故障排除](../postgresql/replication_and_failover_troubleshooting.md) `gitlab-ctl patroni check-leader` 和 PgBouncer 错误。
- 有关数据库的开发人员文档，其中部分内容绝对不能用于生产环境。包括：
  - 理解 EXPLAIN 计划。

<a id="support-topics"></a>

### 支持主题

<a id="database-deadlocks"></a>

#### 数据库死锁

参考：

- 如果实例因大量推送而涌入，可能会发生死锁。这提供了关于极狐GitLab 代码在异常情况下如何产生此类意外影响的背景信息。

```plaintext
ERROR: deadlock detected
```

在议题 #30528 中确定了三个适用的超时时间；我们推荐的设置如下：

```ini
deadlock_timeout = 5s
statement_timeout = 15s
idle_in_transaction_session_timeout = 60s
```

引用自议题 #30528：

<!-- vale gitlab_base.FutureTense = NO -->

> "如果遇到死锁，我们通过在短时间后中止事务来解决问题，那么我们现有的重试机制将使导致死锁的工作再次尝试，并且我们不太可能连续多次出现死锁。"

<!-- vale gitlab_base.FutureTense = YES -->

> [!note]
> 在支持中，我们重新配置超时的总体方法（同样适用于 HTTP 堆栈）是，可以将其作为临时解决方法。如果它使客户能够使用极狐GitLab，那么就争取了时间来更全面地理解问题、实施热修复或进行其他解决根本原因的更改。通常，在根本原因解决后，应将超时恢复为合理的默认值。

在这种情况下，我们得到的开发指导是降低 `deadlock_timeout` 或 `statement_timeout`，但将第三个设置保持在 60 秒。设置 `idle_in_transaction` 可以保护数据库免受可能挂起数天的会话的影响。有关在 JihuLab.com 上引入此超时的议题中有更多讨论。

PostgreSQL 默认值：

- `statement_timeout = 0` (从不)
- `idle_in_transaction_session_timeout = 0` (从不)

议题 #30528 中的评论表明，对于所有 Linux 软件包安装，这两个值都应至少设置为几分钟（这样它们就不会无限期挂起）。但是，`statement_timeout` 的 15 秒非常短，只有在底层基础设施性能非常高时才有效。

使用以下命令查看当前设置：

```shell
sudo gitlab-rails runner "c = ApplicationRecord.connection ; puts c.execute('SHOW statement_timeout').to_a ;
puts c.execute('SHOW deadlock_timeout').to_a ;
puts c.execute('SHOW idle_in_transaction_session_timeout').to_a ;"
```

可能需要稍等片刻才能得到响应。

```ruby
{"statement_timeout"=>"1min"}
{"deadlock_timeout"=>"0"}
{"idle_in_transaction_session_timeout"=>"1min"}
```

可以在 `/etc/gitlab/gitlab.rb` 中使用以下内容更新这些设置：

```ruby
postgresql['deadlock_timeout'] = '5s'
postgresql['statement_timeout'] = '15s'
postgresql['idle_in_transaction_session_timeout'] = '60s'
```

保存后，[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

> [!note]
> 这些是 Linux 软件包设置。如果使用外部数据库（例如客户的 PostgreSQL 安装或 Amazon RDS），则不会设置这些值，必须从外部进行设置。

<a id="temporarily-changing-the-statement-timeout"></a>

#### 临时更改语句超时

> [!warning]
> 如果启用了 [PgBouncer](../postgresql/pgbouncer.md)，以下建议不适用，因为更改后的超时可能会影响比预期更多的事务。

在某些情况下，可能需要在无需[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)（这种情况下会重启 Puma 和 Sidekiq）的条件下设置不同的语句超时。

例如，备份可能因语句超时太短而失败，并在[备份命令](../backup_restore/_index.md#back-up-gitlab)的输出中出现以下错误：

```plaintext
pg_dump: error: Error message from server: server closed the connection unexpectedly
```

您也可能在 [PostgreSQL 日志](../logs/_index.md#postgresql-logs)中看到错误：

```plaintext
canceling statement due to statement timeout
```

<a id="for-linux-package-installations"></a>

##### 对于 Linux 软件包安装

要临时更改语句超时：

1. 在编辑器中打开 `/var/opt/gitlab/gitlab-rails/etc/database.yml`
1. 将 `statement_timeout` 的值设置为 `0`，这将设置无限的语句超时。
1. [在新的 Rails 控制台会话中确认](../operations/rails_console.md#using-the-rails-runner) 已使用此值：

   ```shell
   sudo gitlab-rails runner "ActiveRecord::Base.connection_db_config[:variables]"
   ```

1. 执行需要不同超时的操作（例如备份或 Rails 命令）。
1. 恢复 `/var/opt/gitlab/gitlab-rails/etc/database.yml` 中的编辑。

<a id="for-cloud-native-deployments"></a>

##### 对于云原生部署

对于使用托管 PostgreSQL 服务（例如 AWS RDS、Azure Database for PostgreSQL 或 Google Cloud SQL）的云原生部署，您无法直接修改数据库配置文件。相反，应通过云服务的参数组或配置界面来配置 `statement_timeout` 参数：

- **AWS RDS**：修改与您的数据库实例关联的参数组，并将 `statement_timeout` 设置为 `0`（无限）。
- **Azure Database for PostgreSQL**：在 Azure 门户中更新服务器参数，并将 `statement_timeout` 设置为 `0`。
- **Google Cloud SQL**：修改数据库标志，并将 `statement_timeout` 设置为 `0`。

在对参数组或配置进行更改后，您可能需要重启数据库实例以使更改生效。请查阅云提供商的文档以获取具体说明。

<a id="observe-reindex-progress-report"></a>

### 观察（RE）INDEX 进度报告

在某些情况下，您可能希望观察 `CREATE INDEX` 或 `REINDEX` 操作的进度。例如，您可以这样做来确认 `CREATE INDEX` 或 `REINDEX` 操作是否处于活动状态，或者检查操作处于哪个阶段。

先决条件：

- 您必须使用 PostgreSQL 12 或更高版本。

要观察 `CREATE INDEX` 或 `REINDEX` 操作：

- 使用内置的 [`pg_stat_progress_create_index` 视图](https://www.postgresql.org/docs/16/progress-reporting.html#CREATE-INDEX-PROGRESS-REPORTING)。

例如，在数据库控制台会话中运行以下命令：

```sql
SELECT * FROM  pg_stat_progress_create_index \watch 0.2
```

要了解有关生成易于阅读的输出并将数据写入日志文件的更多信息，请参阅[此代码片段](https://jihulab.com/-/snippets/3750940)。

<a id="troubleshooting"></a>

## 故障排除

<a id="database-connection-is-refused"></a>

### 数据库连接被拒绝

如果您遇到以下错误，请检查 `max_connections` 是否足够高以确保稳定连接。

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

### 数据库拒绝命令以防止回绕数据丢失

此错误可能意味着 `autovacuum` 无法完成其运行：

```plaintext
ERROR:  database is not accepting commands to avoid wraparound data loss in database "gitlabhq_production"
```

或者

```plaintext
 ERROR:  failed to re-find parent key in index "XXX" for deletion target page XXX
```

要解决此错误，请手动运行 `VACUUM`：

1. 使用命令 `gitlab-ctl stop` 停止 GitLab。
1. 使用命令将数据库置于单用户模式：

   ```shell
   /opt/gitlab/embedded/bin/postgres --single -D /var/opt/gitlab/postgresql/data gitlabhq_production
   ```

1. 在 `backend>` 提示符下，运行 `VACUUM;`。此命令可能需要几分钟才能完成。
1. 等待命令完成，然后按 <kbd>Control</kbd> + <kbd>D</kbd> 退出。
1. 使用命令 `gitlab-ctl start` 启动 GitLab。

<a id="gitlab-database-requirements"></a>

### GitLab 数据库要求

请参阅[数据库要求](../../install/requirements.md#postgresql) 并查看并安装[必需的扩展列表](../../install/postgresql_extensions.md)。

<a id="serialization-errors-in-the-productionsidekiq-log"></a>

### `production/sidekiq` 日志中的序列化错误

如果您在 `production/sidekiq` 日志中收到类似此示例的错误，请阅读有关[将 `default_transaction_isolation` 设置为读已提交](https://gitlab.cn/docs/omnibus/settings/database/#set-default_transaction_isolation-into-read-committed) 的内容以解决问题：

```plaintext
ActiveRecord::StatementInvalid PG::TRSerializationFailure: ERROR:  could not serialize access due to concurrent update
```

<a id="postgresql-replication-slot-errors"></a>

### PostgreSQL 复制槽错误

如果您收到类似此示例的错误，请阅读如何解决 PostgreSQL 高可用[复制槽错误](https://gitlab.cn/docs/omnibus/settings/database/#troubleshooting-upgrades-in-an-ha-cluster)：

```plaintext
pg_basebackup: could not create temporary replication slot "pg_basebackup_12345": ERROR:  all replication slots are in use
HINT:  Free one or increase max_replication_slots.
```

<a id="geo-replication-errors"></a>

### Geo 复制错误

如果您收到类似此示例的错误，请阅读如何解决 [Geo 复制错误](../geo/replication/troubleshooting/postgresql_replication.md)：

```plaintext
ERROR: replication slots can only be used if max_replication_slots > 0

FATAL: could not start WAL streaming: ERROR: replication slot "geo_secondary_my_domain_com" does not exist

Command exceeded allowed execution time

PANIC: could not write to file 'pg_xlog/xlogtemp.123': No space left on device
```

<a id="review-geo-configuration-and-common-errors"></a>

### 检查 Geo 配置和常见错误

在排查 Geo 问题时，您应该：

- 检查 [Geo 常见错误](../geo/replication/troubleshooting/common.md#fixing-common-errors)。
- [检查您的 Geo 配置](../geo/replication/troubleshooting/_index.md)，包括：
  - 重新配置主机和端口。
  - 检查并修复用户和密码映射。

<a id="mismatch-in-pg_dump-and-psql-versions"></a>

### `pg_dump` 和 `psql` 版本不匹配

如果您收到类似此示例的错误，请阅读如何[备份和还原非打包 PostgreSQL 数据库](https://gitlab.cn/docs/omnibus/settings/database/#backup-and-restore-a-non-packaged-postgresql-database)：

```plaintext
Dumping PostgreSQL database gitlabhq_production ... pg_dump: error: server version: 13.3; pg_dump version: 14.2
pg_dump: error: aborting because of server version mismatch
```

<a id="extension-btree_gist-is-not-allow-listed"></a>

### 未允许扩展 `btree_gist`

在 Azure Database for PostgreSQL - 灵活服务器上部署 PostgreSQL 可能会导致此错误：

```plaintext
extension "btree_gist" is not allow-listed for "azure_pg_admin" users in Azure Database for PostgreSQL
```

要解决此错误，请在安装前[允许该扩展](https://learn.microsoft.com/zh-cn/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions)。