---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除常见 Geo 错误
description: 诊断并解决常见的 Geo 问题，涵盖健康检查、数据库复制问题、站点连接以及错误解决流程。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="basic-troubleshooting"></a>

## 基本故障排除

在尝试更高级的故障排除之前：

- 检查 [Geo 站点的健康状况](#check-the-health-of-the-geo-sites)。
- 检查 [PostgreSQL 复制是否正常工作](#check-if-postgresql-replication-is-working)。

<a id="tracing-requests-across-geo-sites"></a>

### 跨 Geo 站点追踪请求

在对 Geo 进行故障排除时，您可能需要追踪从从站点到主站点（或反向）的请求。极狐GitLab 使用关联 ID 来关联跨服务的相关日志条目。

默认情况下，每个站点在收到请求时都会生成自己的关联 ID。要使用同一个关联 ID 跨两个站点追踪单个请求，您必须配置每个接收站点的 Workhorse，使其接受来自其他 Geo 站点的传入关联 ID。

在所有 Geo 站点上：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_workhorse['propagate_correlation_id'] = true
   gitlab_workhorse['trusted_cidrs_for_propagation'] = %w(<secondary-site-ip>/32)
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 更新您的 Helm values：

   ```yaml
   gitlab:
     webservice:
       workhorse:
         extraArgs: "-propagateCorrelationID"
         trustedCIDRsForPropagation: ["<secondary-site-ip>/32"]
   ```

1. 应用更改。

{{< /tab >}}

{{< /tabs >}}

启用此设置后，从从站点发送到主站点的请求会在其日志中共享同一个关联 ID，从而允许您跨两个站点追踪请求。

<a id="check-the-health-of-the-geo-sites"></a>

### 检查 Geo 站点的健康状况

在主站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。

我们对每个从站点执行以下健康检查，以帮助识别是否出现问题：

- 站点是否正在运行？
- 从站点的数据库是否配置为流式复制？
- 从站点的跟踪数据库是否已配置？
- 从站点的跟踪数据库是否已连接？
- 从站点的跟踪数据库是否是最新的？
- 从站点的状态是否在 1 小时以内？

如果站点的状态超过 1 小时未更新，则该站点会显示为“不健康”。在这种情况下，请尝试在受影响的从站点上的 [Rails 控制台](../../../operations/rails_console.md)中运行以下命令：

```ruby
Geo::MetricsUpdateWorker.new.perform
```

如果它引发错误，那么该错误可能也阻止了作业完成。如果耗时超过 1 小时，那么状态可能会反复变化或持续显示为“不健康”，即使状态偶尔会更新。这可能是由于使用量增长、数据随时间增长，或诸如缺少数据库索引之类的性能缺陷所致。

您可以使用 `top` 或 `htop` 之类的工具监控系统 CPU 负载。如果 PostgreSQL 使用了大量 CPU，这可能表明存在问题，或者系统预配不足。还应监控系统内存。

如果增加内存，您还应检查 `/etc/gitlab/gitlab.rb` 配置中与 PostgreSQL 内存相关的设置。

如果它成功更新了状态，那么 Sidekiq 可能有问题。它是否正在运行？日志中是否显示错误？此作业应每分钟入队一次，如果[作业去重幂等键](../../../sidekiq/sidekiq_troubleshooting.md#clearing-a-sidekiq-job-deduplication-idempotency-key)未正确清除，它可能不会运行。它在 Redis 中获取独占租约，以确保这些作业中一次只能运行一个。主站点直接在 PostgreSQL 数据库中更新其状态。从站点向主站点发送 HTTP Post 请求，其中包含其状态数据。

如果某些健康检查失败，站点也会显示为“不健康”。您可以通过在受影响的从站点上的 [Rails 控制台](../../../operations/rails_console.md)中运行以下命令来揭示失败原因：

```ruby
Gitlab::Geo::HealthCheck.new.perform_checks
```

如果它返回 `""`（空字符串）或 `"Healthy"`，则检查成功。如果它返回其他任何内容，则该消息应说明失败原因，或显示异常消息。

有关如何解决用户界面报告的常见错误消息的信息，请参阅[修复常见错误](#fixing-common-errors)。

如果用户界面无法正常工作，或者您无法登录，您可以手动运行 Geo 健康检查以获取此信息以及更多详细信息。

<a id="health-check-rake-task"></a>

#### 健康检查 Rake 任务

此 Rake 任务可以在主站点或 Geo 从站点的 Rails 节点上运行：

```shell
sudo gitlab-rake gitlab:geo:check
```

示例输出：

```plaintext
Checking Geo ...

GitLab Geo is available ... yes
GitLab Geo is enabled ... yes
This machine's Geo node name matches a database record ... yes, found a secondary node named "Shanghai"
GitLab Geo tracking database is correctly configured ... yes
Database replication enabled? ... yes
Database replication working? ... yes
GitLab Geo HTTP(S) connectivity ...
* Can connect to the primary node ... yes
HTTP/HTTPS repository cloning is enabled ... yes
Machine clock is synchronized ... yes
Git user has default SSH configuration? ... yes
OpenSSH configured to use AuthorizedKeysCommand ... yes
GitLab configured to disable writing to authorized_keys file ... yes
GitLab configured to store new projects in hashed storage? ... yes
All projects are in hashed storage? ... yes
Container Registry replication enabled ... yes
Container Registry Geo events ... last event at 2024-01-15 10:30:00 UTC

Checking Geo ... Finished
```

您还可以使用环境变量指定自定义 NTP 服务器。例如：

```shell
sudo gitlab-rake gitlab:geo:check NTP_HOST="ntp.ubuntu.com" NTP_TIMEOUT="30"
```

支持以下环境变量。

| 变量      | 描述 | 默认值 |
| ------------- | ----------- | ------------- |
| `NTP_HOST`    | NTP 主机。 | `pool.ntp.org` |
| `NTP_PORT`    | 主机监听的 NTP 端口。 | `123` |
| `NTP_TIMEOUT` | NTP 超时时间（秒）。 | `net-ntp` Ruby 库中定义的值（[60 秒](https://github.com/zencoder/net-ntp/blob/3d0990214f439a5127782e0f50faeaf2c8ca7023/lib/net/ntp/ntp.rb#L6)）。 |

如果 Rake 任务跳过 `OpenSSH configured to use AuthorizedKeysCommand` 检查，则会显示以下输出：

```plaintext
OpenSSH configured to use AuthorizedKeysCommand ... skipped
  Reason:
  Cannot access OpenSSH configuration file
  Try fixing it:
  This is expected if you are using SELinux. You may want to check configuration manually
  For more information see:
  doc/administration/operations/fast_ssh_key_lookup.md
```

此问题可能在以下情况下发生：

- 您使用 [SELinux](../../../operations/fast_ssh_key_lookup.md#selinux-support)。
- 您不使用 SELinux，并且由于文件权限受限，`git` 用户无法访问 OpenSSH 配置文件。

在后一种情况下，以下输出显示只有 `root` 用户可以读取此文件：

```plaintext
sudo stat -c '%G:%U %A %a %n' /etc/ssh/sshd_config

root:root -rw------- 600 /etc/ssh/sshd_config
```

要允许 `git` 用户读取 OpenSSH 配置文件，而不更改文件所有者或权限，请使用 `acl`：

```plaintext
sudo setfacl -m u:git:r /etc/ssh/sshd_config
```

<a id="sync-status-rake-task"></a>

#### 同步状态 Rake 任务

可以在 Geo 从站点上任何运行 Rails（Puma、Sidekiq 或 Geo Log Cursor）的
节点上手动运行此 Rake 任务来查找当前同步信息。

极狐GitLab 不会验证存储在对象存储中的对象。如果您使用对象存储，您会看到所有“verified”检查都显示 0 个成功。这是预期行为，无需担心。

```shell
sudo gitlab-rake gitlab:geo:status
```

输出包括：

- 如果发生任何失败，则显示“failed”条目的计数
- 相对于“total”的“succeeded”条目百分比

示例：

```plaintext
                        Geo Site Information
--------------------------------------------
                                      Name: example-us-east-2
                                       URL: https://gitlab.example.com
                                  Geo Role: Secondary
                             Health Status: Healthy
                This Node's GitLab Version: 17.7.0-ee

                     Replication Information
--------------------------------------------
                             Sync Settings: Full
                  Database replication lag: 0 seconds
           Last event ID seen from primary: 12345 (about 2 minutes ago)
                   Last event ID processed: 12345 (about 2 minutes ago)
                    Last status report was: 1 minute ago

                          Replication Status
--------------------------------------------
                    Lfs Objects replicated: succeeded 111 / total 111 (100%)
            Merge Request Diffs replicated: succeeded 28 / total 28 (100%)
                  Package Files replicated: succeeded 90 / total 90 (100%)
       Terraform State Versions replicated: succeeded 65 / total 65 (100%)
           Snippet Repositories replicated: succeeded 63 / total 63 (100%)
        Group Wiki Repositories replicated: succeeded 14 / total 14 (100%)
             Pipeline Artifacts replicated: succeeded 112 / total 112 (100%)
              Pages Deployments replicated: succeeded 55 / total 55 (100%)
                        Uploads replicated: succeeded 2 / total 2 (100%)
                  Job Artifacts replicated: succeeded 32 / total 32 (100%)
                Ci Secure Files replicated: succeeded 44 / total 44 (100%)
         Dependency Proxy Blobs replicated: succeeded 15 / total 15 (100%)
     Dependency Proxy Manifests replicated: succeeded 2 / total 2 (100%)
      Project Wiki Repositories replicated: succeeded 2 / total 2 (100%)
 Design Management Repositories replicated: succeeded 1 / total 1 (100%)
           Project Repositories replicated: succeeded 2 / total 2 (100%)

                         Verification Status
--------------------------------------------
                      Lfs Objects verified: succeeded 111 / total 111 (100%)
              Merge Request Diffs verified: succeeded 28 / total 28 (100%)
                    Package Files verified: succeeded 90 / total 90 (100%)
         Terraform State Versions verified: succeeded 65 / total 65 (100%)
             Snippet Repositories verified: succeeded 63 / total 63 (100%)
          Group Wiki Repositories verified: succeeded 14 / total 14 (100%)
               Pipeline Artifacts verified: succeeded 112 / total 112 (100%)
                Pages Deployments verified: succeeded 55 / total 55 (100%)
                          Uploads verified: succeeded 2 / total 2 (100%)
                    Job Artifacts verified: succeeded 32 / total 32 (100%)
                  Ci Secure Files verified: succeeded 44 / total 44 (100%)
           Dependency Proxy Blobs verified: succeeded 15 / total 15 (100%)
       Dependency Proxy Manifests verified: succeeded 2 / total 2 (100%)
        Project Wiki Repositories verified: succeeded 2 / total 2 (100%)
   Design Management Repositories verified: succeeded 1 / total 1 (100%)
             Project Repositories verified: succeeded 2 / total 2 (100%)

```

所有对象都会被复制和验证，这些定义见 [Geo 术语表](../../glossary.md)。在[支持的 Geo 数据类型](../datatypes.md#data-types)中详细了解我们用于复制和验证每种数据类型的方法。

要查找有关失败条目的更多详细信息，请查看 [`gitlab-rails/geo.log` 文件](../../../logs/log_parsing.md#find-most-common-geo-sync-errors)

如果您发现复制或验证失败，可以尝试[解决它们](synchronization_verification.md)。

<a id="fixing-errors-found-when-running-the-geo-check-rake-task"></a>

##### 修复运行 Geo 检查 Rake 任务时发现的错误

运行此 Rake 任务时，如果节点未正确配置，您可能会看到错误消息：

```shell
sudo gitlab-rake gitlab:geo:check
```

- Rails 在连接数据库时未提供密码。

  ```plaintext
  Checking Geo ...

  GitLab Geo is available ... Exception: fe_sendauth: no password supplied
  GitLab Geo is enabled ... Exception: fe_sendauth: no password supplied
  ...
  Checking Geo ... Finished
  ```

  确保您已将 `gitlab_rails['db_password']` 设置为创建 `postgresql['sql_user_password']` 哈希时使用的明文
  密码。

- Rails 无法连接到数据库。

  ```plaintext
  Checking Geo ...

  GitLab Geo is available ... Exception: FATAL:  no pg_hba.conf entry for host "1.1.1.1",  user "gitlab", database "gitlabhq_production", SSL on
  FATAL:  no pg_hba.conf entry for host "1.1.1.1", user "gitlab", database "gitlabhq_production", SSL off
  GitLab Geo is enabled ... Exception: FATAL:  no pg_hba.conf entry for host "1.1.1.1", user "gitlab", database "gitlabhq_production", SSL on
  FATAL:  no pg_hba.conf entry for host "1.1.1.1", user "gitlab", database "gitlabhq_production", SSL off
  ...
  Checking Geo ... Finished
  ```

  确保您已将 rails 节点的 IP 地址包含在 `postgresql['md5_auth_cidr_addresses']` 中。
  另外，确保您在 IP 地址上包含了子网掩码：`postgresql['md5_auth_cidr_addresses'] = ['1.1.1.1/32']`。

- Rails 提供了错误的密码。

  ```plaintext
  Checking Geo ...
  GitLab Geo is available ... Exception: FATAL:  password authentication failed for user "gitlab"
  FATAL:  password authentication failed for user "gitlab"
  GitLab Geo is enabled ... Exception: FATAL:  password authentication failed for user "gitlab"
  FATAL:  password authentication failed for user "gitlab"
  ...
  Checking Geo ... Finished
  ```

  通过运行 `gitlab-ctl pg-password-md5 gitlab` 并输入密码，验证为 `gitlab_rails['db_password']` 设置了正确的密码，
  该密码用于在 `postgresql['sql_user_password']` 中创建哈希。

- 检查返回 `not a secondary node`。

  ```plaintext
  Checking Geo ...

  GitLab Geo is available ... yes
  GitLab Geo is enabled ... yes
  GitLab Geo tracking database is correctly configured ... not a secondary node
  Database replication enabled? ... not a secondary node
  ...
  Checking Geo ... Finished
  ```

  确保您已在主站点的 Web 界面中，在**管理**区域的 **Geo** > **站点**下添加了从站点。
  还要确保您在主站点的**管理**区域中添加从站点时输入了 `gitlab_rails['geo_node_name']`。

- 检查返回 `Exception: PG::UndefinedTable: ERROR:  relation "geo_nodes" does not exist`。

  ```plaintext
  Checking Geo ...

  GitLab Geo is available ... no
    Try fixing it:
    Add a new license that includes the GitLab Geo feature
    For more information see:
    https://about.gitlab.com/features/gitlab-geo/
  GitLab Geo is enabled ... Exception: PG::UndefinedTable: ERROR:  relation "geo_nodes" does not exist
  LINE 8:                WHERE a.attrelid = '"geo_nodes"'::regclass
                                             ^
  :               SELECT a.attname, format_type(a.atttypid, a.atttypmod),
                       pg_get_expr(d.adbin, d.adrelid), a.attnotnull, a.atttypid, a.atttypmod,
                       c.collname, col_description(a.attrelid, a.attnum) AS comment
                  FROM pg_attribute a
                  LEFT JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
                  LEFT JOIN pg_type t ON a.atttypid = t.oid
                  LEFT JOIN pg_collation c ON a.attcollation = c.oid AND a.attcollation <> t.typcollation
                 WHERE a.attrelid = '"geo_nodes"'::regclass
                   AND a.attnum > 0 AND NOT a.attisdropped
                 ORDER BY a.attnum
  ...
  Checking Geo ... Finished
  ```

  在执行 PostgreSQL 主版本升级（9 > 10）时，这是预期行为。请遵循
  [启动复制过程](../../setup/database.md#step-3-initiate-the-replication-process)。

- Rails 似乎没有连接到 Geo 跟踪数据库所需的配置。

  ```plaintext
  Checking Geo ...

  GitLab Geo is available ... yes
  GitLab Geo is enabled ... yes
  GitLab Geo tracking database is correctly configured ... no
  Try fixing it:
  Rails does not appear to have the configuration necessary to connect to the Geo tracking database. If the tracking database is running on a node other than this one, then you may need to add configuration.
  ...
  Checking Geo ... Finished
  ```

  - 如果您在单个节点上为所有服务运行从站点，请遵循 [Geo 数据库复制 - 配置从服务器](../../setup/database.md#step-2-configure-the-secondary-server)。
  - 如果您在单独的节点上运行从站点的跟踪数据库，请遵循[多服务器 Geo - 在 Geo 从站点上配置 Geo 跟踪数据库](../multiple_servers.md#step-2-configure-the-geo-tracking-database-on-the-geo-secondary-site)
  - 如果您在 Patroni 集群中运行从站点的跟踪数据库，请遵循 [Geo 数据库复制 - 为跟踪 PostgreSQL 数据库配置 Patroni 集群](../../setup/database.md#configuring-patroni-cluster-for-the-tracking-postgresql-database)
  - 如果您在外部数据库中运行从站点的跟踪数据库，请遵循[使用外部 PostgreSQL 实例的 Geo](../../setup/external_database.md#configure-the-tracking-database)
  - 如果 Geo 检查任务是在未运行 GitLab Rails 应用（Puma、Sidekiq 或 Geo Log Cursor）的服务的节点上运行的，则可以忽略此错误。该节点不需要配置 Rails。

<a id="message-container-registry-geo-events--none-found"></a>

##### 消息：Container Registry Geo events ... none found

如果显示 `Container Registry Geo events ... none found`，而您期望存在 Container Registry
复制事件，请验证主站点上的 registry 通知配置是否符合 [Container Registry 复制配置指南](../container_registry.md#configure-primary-site)。

<a id="message-machine-clock-is-synchronized--exception"></a>

##### 消息：Machine clock is synchronized ... Exception

Rake 任务会尝试验证服务器时钟是否与 NTP 同步。Geo 正常运行需要时钟同步。例如，出于安全考虑，当主站点和从站点上的服务器时间相差约一分钟或更多时，Geo 站点之间的请求会失败。如果此检查任务由于时间不匹配以外的原因而无法完成，这并不一定意味着 Geo 无法正常工作。

执行检查的 Ruby gem 硬编码了 `pool.ntp.org` 作为其参考时间源。

- 异常消息 `Machine clock is synchronized ... Exception: Timeout::Error`

  当您的服务器无法访问主机 `pool.ntp.org` 时，会发生此问题。

- 异常消息 `Machine clock is synchronized ... Exception: No route to host - recvfrom(2)`

  当主机名 `pool.ntp.org` 解析到不提供时间服务的服务器时，会发生此问题。

在这种情况下，[使用环境变量指定自定义 NTP 服务器](#health-check-rake-task)。

[Cloud native GitLab 部署](https://gitlab.cn/docs/charts/advanced/geo/#set-the-geo-primary-site)
会生成错误，因为 Kubernetes 中的容器无法访问主机时钟：

```plaintext
Machine clock is synchronized ... Exception: getaddrinfo: Servname not supported for ai_socktype
```

<a id="message-cannot-execute-insert-in-a-read-only-transaction"></a>

##### 消息：`cannot execute INSERT in a read-only transaction`

当在从站点上遇到此错误时，它可能会影响 GitLab Rails 的所有用法，例如 `gitlab-rails` 或 `gitlab-rake` 命令，以及 Puma、Sidekiq 和 Geo Log Cursor 服务。

```plaintext
ActiveRecord::StatementInvalid: PG::ReadOnlySqlTransaction: ERROR:  cannot execute INSERT in a read-only transaction
/opt/gitlab/embedded/service/gitlab-rails/app/models/application_record.rb:86:in `block in safe_find_or_create_by'
/opt/gitlab/embedded/service/gitlab-rails/app/models/concerns/cross_database_modification.rb:92:in `block in transaction'
/opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/database.rb:332:in `block in transaction'
/opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/database.rb:331:in `transaction'
/opt/gitlab/embedded/service/gitlab-rails/app/models/concerns/cross_database_modification.rb:83:in `transaction'
/opt/gitlab/embedded/service/gitlab-rails/app/models/application_record.rb:86:in `safe_find_or_create_by'
/opt/gitlab/embedded/service/gitlab-rails/app/models/shard.rb:21:in `by_name'
/opt/gitlab/embedded/service/gitlab-rails/app/models/shard.rb:17:in `block in populate!'
/opt/gitlab/embedded/service/gitlab-rails/app/models/shard.rb:17:in `map'
/opt/gitlab/embedded/service/gitlab-rails/app/models/shard.rb:17:in `populate!'
/opt/gitlab/embedded/service/gitlab-rails/config/initializers/fill_shards.rb:9:in `<top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/config/environment.rb:7:in `<top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
```

PostgreSQL 只读副本数据库会产生以下错误：

```plaintext
2023-01-17_17:44:54.64268 ERROR:  cannot execute INSERT in a read-only transaction
2023-01-17_17:44:54.64271 STATEMENT:  /*application:web,db_config_name:main*/ INSERT INTO "shards" ("name") VALUES ('storage1') RETURNING "id"
```

此情况可能在以下情况下发生：

- 在初始配置期间，从站点尚不知道自己是从站点。要解决此错误，请遵循[第 3 步。添加从站点](../configuration.md#step-3-add-the-secondary-site)。
- 在升级 Geo 从站点期间。可能是 `gitlab_rails['auto_migrate']` 被设置为 `true`，导致极狐GitLab 尝试在副本数据库上执行数据库迁移，而这是不需要的。要解决此错误：

  1. 以 root 身份 SSH 到从站点的 GitLab Rails 节点。
  1. 编辑 `/etc/gitlab/gitlab.rb`，并注释掉此设置或将其设置为 false：

     ```ruby
     gitlab_rails['auto_migrate'] = false
     ```

  1. 重新配置极狐GitLab：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

<a id="check-if-postgresql-replication-is-working"></a>

### 检查 PostgreSQL 复制是否正常工作

要检查 PostgreSQL 复制是否正常工作，请检查：

- [站点是否指向正确的数据库节点](#are-sites-pointing-to-the-correct-database-node)。
- [Geo 能否正确检测当前站点](#can-geo-detect-the-current-site-correctly)。

如果您仍然遇到问题，请参阅[高级复制故障排除](synchronization_verification.md)。

<a id="are-sites-pointing-to-the-correct-database-node"></a>

#### 站点是否指向正确的数据库节点？

您应确保您的主 Geo [站点](../../glossary.md)指向具有写入权限的数据库节点。

任何从站点都应只指向只读数据库节点。

<a id="can-geo-detect-the-current-site-correctly"></a>

#### Geo 能否正确检测当前站点？

Geo 在
`/etc/gitlab/gitlab.rb`中通过以下逻辑查找当前 Puma 或 Sidekiq 节点的 Geo [站点](../../glossary.md)名称：

1. 获取“Geo node name”（有一个
   [议题要求将这些设置重命名为“Geo site name”](https://gitlab.com/gitlab-org/gitlab/-/issues/335944)）：
   - Linux 软件包：获取 `gitlab_rails['geo_node_name']` 设置。
   - GitLab Helm charts：获取 `global.geo.nodeName` 设置（请参阅[使用极狐GitLab Geo 的 Charts](https://gitlab.cn/docs/charts/advanced/geo/)）。
1. 如果未定义，则获取 `external_url` 设置。

此名称用于在 **Geo 站点**
仪表板中查找具有相同**名称**的 Geo 站点。

要检查当前机器是否具有与数据库中某个站点匹配的站点名称，请运行检查任务：

```shell
sudo gitlab-rake gitlab:geo:check
```

它会显示当前机器的站点名称，以及匹配的数据库记录是主站点还是从站点。

```plaintext
This machine's Geo node name matches a database record ... yes, found a secondary node named "Shanghai"
```

```plaintext
This machine's Geo node name matches a database record ... no
  Try fixing it:
  You could add or update a Geo node database record, setting the name to "https://example.com/".
  Or you could set this machine's Geo node name to match the name of an existing database record: "London", "Shanghai"
  For more information see:
  doc/administration/geo/replication/troubleshooting/_index.md#can-geo-detect-the-current-node-correctly
```

有关 Name 字段描述中推荐的站点名称的更多信息，请参阅 [Geo **管理**区域常用设置](../../../geo_sites.md#common-settings)。

<a id="check-os-locale-data-compatibility"></a>

### 检查操作系统区域设置数据兼容性

如果可能，所有站点中的所有 Geo 节点都应使用相同的方法和操作系统进行部署，如[运行 Geo 的要求](../../_index.md#requirements-for-running-geo)中所定义。

如果在 Geo 站点之间部署了不同的操作系统或不同的操作系统版本，您必须在设置 Geo 之前执行区域设置数据兼容性检查。在使用混合的极狐GitLab 部署方法时，您还必须检查 `glibc`。Linux 软件包安装、极狐GitLab Docker 容器、Helm chart 部署或外部数据库服务之间的区域设置可能不同。请参阅[有关升级 PostgreSQL 操作系统的文档](../../../postgresql/upgrading_os.md)，包括如何检查 `glibc` 版本兼容性。

Geo 使用 PostgreSQL 和流式复制在 Geo 站点之间复制数据。PostgreSQL 使用操作系统 C 库提供的区域设置数据来对文本进行排序。如果 C 库中的区域设置数据在 Geo 站点之间不兼容，则会导致错误的查询结果，从而导致[从站点上的行为不正确](https://gitlab.com/gitlab-org/gitlab/-/issues/360723)。

例如，Ubuntu 18.04（及更早版本）和 RHEL/CentOS 7（及更早版本）与其后续版本不兼容。
有关更多详细信息，请参阅 [PostgreSQL wiki](https://wiki.postgresql.org/wiki/Locale_data_changes)。

<a id="fixing-common-errors"></a>

## 修复常见错误

本节记录了 Web 界面中**管理**区域报告的常见错误消息，以及如何修复它们。

<a id="an-existing-tracking-database-cannot-be-reused"></a>

### 无法重用现有的跟踪数据库

Geo 无法重用现有的跟踪数据库。

最安全的做法是使用全新的从站点，或者按照[重置 Geo 从站点复制](synchronization_verification.md#resetting-geo-secondary-site-replication)重置整个从站点。

在不重置的情况下重用从站点是有风险的，因为从站点可能已错过一些 Geo 事件。例如，错过的删除事件会导致从站点永久保留本应删除的数据。同样，丢失一个实际移动数据位置的事件会导致数据永久孤立在一个位置，而在另一个位置缺失，直到重新验证。这就是极狐GitLab 改用哈希存储的原因，它使移动数据变得不必要。由于丢失事件，可能还存在其他未知问题。

如果这类风险不适用，例如在测试环境中，或者如果您知道主 Postgres 数据库仍包含自添加 Geo 站点以来的所有 Geo 事件，那么您可以绕过此健康检查：

1. 获取最后处理事件的时间。在从站点的 Rails 控制台中，运行：

   ```ruby
   Geo::EventLogState.last.created_at.utc
   ```

1. 复制输出，例如 `2024-02-21 23:50:50.676918 UTC`。
1. 更新从站点的创建时间，使其看起来更早。在主站点的 Rails 控制台中，运行：

   ```ruby
   GeoNode.secondary_nodes.last.update_column(:created_at, DateTime.parse('2024-02-21 23:50:50.676918 UTC') - 1.second)
   ```

   此命令假设受影响的从站点是最后创建的那个。

1. 在**管理员** > **Geo** > **站点**中更新从站点的状态。在从站点的 Rails 控制台中，运行：

   ```ruby
   Geo::MetricsUpdateWorker.new.perform
   ```

1. 从站点应显示为健康。如果未显示，请在从站点上运行 `gitlab-rake gitlab:geo:check`，或者如果您自重新添加从站点以来尚未重启 Rails，请尝试重启它。
1. 要重新同步缺失或过期的数据，请转到**管理员** > **Geo** > **站点**。
1. 在从站点下选择**复制详情**。
1. 为每种数据类型选择**全部重新验证**。

<a id="geo-site-has-a-database-that-is-writable"></a>

### Geo 站点有一个可写的数据库

此错误消息指的是从站点上的数据库副本出现问题，Geo 期望能够访问该副本。可写的从站点数据库表明该数据库未配置为与主站点进行复制。这通常意味着以下情况之一：

- 使用了不支持的复制方法（例如，逻辑复制）。
- 未正确遵循设置 [Geo 数据库复制](../../setup/database.md)的说明。
- 您的数据库连接详细信息不正确，即您在 `/etc/gitlab/gitlab.rb` 文件中指定了错误的
  用户。

Geo 从站点需要两个独立的 PostgreSQL 实例：

- 主站点的只读副本。
- 一个常规的、可写的实例，用于保存复制元数据。即 Geo 跟踪数据库。

此错误消息表明从站点中的副本数据库配置错误，并且复制已停止。

要恢复数据库并恢复复制，您可以执行以下操作之一：

- [重置 Geo 从站点复制](synchronization_verification.md#resetting-geo-secondary-site-replication)。
- [使用 Linux 软件包设置新的 Geo 从站点](../../setup/_index.md#using-linux-package-installations)。

如果您从头设置新的从站点，您还必须[从 Geo 集群中移除旧站点](../remove_geo_site.md)。

<a id="geo-site-does-not-appear-to-be-replicating-the-database-from-the-primary-site"></a>

### Geo 站点似乎没有从主站点复制数据库

阻止数据库正确复制的最常见问题是：

- 从站点无法访问主站点。检查凭据和
  [防火墙规则](../../_index.md#firewall-rules)。
- SSL 证书问题。确保您从主站点复制了 `/etc/gitlab/gitlab-secrets.json`。
- 数据库存储磁盘已满。
- 数据库复制槽配置错误。
- 数据库未使用复制槽或其他替代方案，并且由于 WAL 文件已被清除而无法赶上。

确保您遵循 [Geo 数据库复制](../../setup/database.md)说明以使用受支持的配置。

<a id="geo-database-version--does-not-match-latest-migration-"></a>

### Geo 数据库版本 (...) 与最新迁移 (...) 不匹配

如果您使用的是 Linux 软件包安装，升级期间可能出现了问题。您可以：

- 运行 `sudo gitlab-ctl reconfigure`。
- 通过在从站点上以 root 身份运行 `sudo gitlab-rake db:migrate:geo` 手动触发数据库迁移。

<a id="error-pgundefinedtable-when-running-gitlab-rake-gitlabgeostatus"></a>

### 运行 `gitlab-rake gitlab:geo:status` 时出现错误 `PG::UndefinedTable`

在运行 `sudo gitlab-rake gitlab:geo:status` 时，您可能会遇到 `PG::UndefinedTable` 错误。当 Geo 跟踪数据库迁移从未运行，或中途停止时，会发生此问题，因此缺少一个注册表。

解决方法是检查哪些迁移处于待处理状态并运行它们：

```shell
sudo gitlab-rake db:migrate:status:geo
sudo gitlab-rake db:migrate:geo
```

然后重新运行 `sudo gitlab-rake gitlab:geo:status` 以确认跟踪数据库是最新的。

<a id="gitlab-indicates-that-more-than-100-of-repositories-were-synced"></a>

### 极狐GitLab 指示已同步超过 100% 的代码仓库

这可能是由项目注册表中的孤立记录引起的。它们会定期使用注册表工作进程进行清理，因此请给它一些时间自行修复。

<a id="failed-checksums-on-primary-site"></a>

### 主站点上的校验和失败

Geo 主站点验证信息屏幕识别出的校验和失败可能是由文件缺失或校验和不匹配引起的。您可以在 `gitlab-rails/geo.log` 文件中找到类似 `"Repository cannot be checksummed because it does not exist"` 或 `"File is not checksummable - file does not exist at: <path>"` 的错误消息。错误消息包含文件路径，以帮助识别缺失的文件。

有关失败条目的其他信息，请运行[完整性检查 Rake 任务](../../../raketasks/check.md#uploaded-files-integrity)：

```ruby
sudo gitlab-rake gitlab:artifacts:check
sudo gitlab-rake gitlab:ci_secure_files:check
sudo gitlab-rake gitlab:lfs:check
sudo gitlab-rake gitlab:uploads:check
```

有关各个错误的详细信息，请使用 `VERBOSE=1` 变量。

<a id="secondary-site-shows-unhealthy-in-ui"></a>

### 从站点在 UI 中显示**不健康**

如果您在 `/etc/gitlab/gitlab.rb`中更新了主站点的 `external_url` 值，或者将协议从 `http` 更改为 `https`，您可能会看到从站点显示为**不健康**。您还可能在 `geo.log`中找到以下错误：

```plaintext
"class": "Geo::NodeStatusRequestService",
...
"message": "Failed to Net::HTTP::Post to primary url: http://primary-site.gitlab.tld/api/v4/geo/status",
  "error": "Failed to open TCP connection to <PRIMARY_IP_ADDRESS>:80 (Connection refused - connect(2) for \"<PRIMARY_ID_ADDRESS>\" port 80)"
```

在这种情况下，请确保在所有站点上更新已更改的 URL：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 更改 URL 并保存更改。

<a id="message-error-canceling-statement-due-to-conflict-with-recovery-during-backup"></a>

### 消息：备份期间出现 `ERROR: canceling statement due to conflict with recovery`

在 Geo 从站点上运行备份[不受支持](https://gitlab.com/gitlab-org/gitlab/-/issues/211668)。

在从站点上运行备份时，您可能会遇到以下错误消息：

```plaintext
Dumping PostgreSQL database gitlabhq_production ...
pg_dump: error: Dumping the contents of table "notes" failed: PQgetResult() failed.
pg_dump: error: Error message from server: ERROR:  canceling statement due to conflict with recovery
DETAIL:  User query might have needed to see row versions that must be removed.
pg_dump: error: The command was: COPY public.notes (id, note, [...], last_edited_at) TO stdout;
```

要防止在 Geo 从站点上的极狐GitLab 升级期间自动进行数据库备份，请创建以下空文件：

```shell
sudo touch /etc/gitlab/skip-auto-backup
```

<a id="high-cpu-usage-on-primary-during-object-verification"></a>

### 对象验证期间主站点上的 CPU 使用率过高

从极狐GitLab 16.11 到极狐GitLab 17.2，缺少 PostgreSQL 索引会导致 CPU
使用率过高和产物验证进度缓慢。此外，Geo 从站点可能会报告为不健康。[议题 471727](https://gitlab.com/gitlab-org/gitlab/-/issues/471727) 详细描述了此行为。

要确定您是否可能遇到此问题，请遵循[确认您是否受影响](https://gitlab.com/gitlab-org/gitlab/-/issues/471727#to-confirm-if-you-are-affected)的步骤。

如果您受影响，请遵循[变通方法](https://gitlab.com/gitlab-org/gitlab/-/issues/471727#workaround)中的步骤手动创建索引。创建索引会导致 PostgreSQL 在完成之前消耗略多的资源。之后，在验证继续期间 CPU 使用率可能仍然很高，但查询应会显著加快，并且从站点状态应正确更新。

<a id="verification-failed-with-verification-timed-out-after-"></a>

### 验证失败，错误为：`Verification timed out after (...)`

Geo 可能会为同一个 `artifact_id` 创建重复的 `JobArtifactRegistry` 条目，这可能导致主站点和从站点之间的同步失败。此问题也可能影响 `UploadRegistry` 和 `PackageFileRegistry` 条目。

要确定您是否可能遇到此问题并移除重复条目：

1. 在从站点中打开 [Rails 控制台](../../../operations/rails_console.md)。
1. 获取有重复项的模型记录 ID 数量：

   ```ruby
   artifact_ids = Geo::JobArtifactRegistry.group(:artifact_id).having('COUNT(*) > 1').pluck(:artifact_id); artifact_ids.size
   upload_ids = Geo::UploadRegistry.group(:file_id).having('COUNT(*) > 1').pluck(:file_id); upload_ids.size
   package_file_ids = Geo::PackageFileRegistry.group(:package_file_id).having('COUNT(*) > 1').pluck(:package_file_id); package_file_ids.size
   ```

1. 输出这些 ID：

   ```ruby
   puts 'BEGIN Artifact IDs', artifact_ids, 'END Artifact IDs'
   puts 'BEGIN Upload IDs', upload_ids, 'END Upload IDs'
   puts 'BEGIN Package File IDs', package_file_ids, 'END Package File IDs'
   ```

   如果输出为空，则您不受影响。否则，请将
   终端输出保存到文本文件中，以防稍后失去连接。

1. 删除所有重复项：

   ```ruby
   Geo::JobArtifactRegistry.where(artifact_id: artifact_ids).delete_all
   Geo::UploadRegistry.where(file_id: upload_ids).delete_all
   Geo::PackageFileRegistry.where(package_file_id: package_file_ids).delete_all
   ```

1. 等待后台作业再次创建注册表行并重新同步。

请关注[议题 479852](https://gitlab.com/gitlab-org/gitlab/-/issues/479852) 以获取有关修复的反馈。

<a id="error-end-of-file-reached-when-running-geo-rake-check-task-on-secondary"></a>

### 在从站点上运行 Geo Rake 检查任务时出现错误 `end of file reached`

在从站点上运行[健康检查 Rake 任务](#health-check-rake-task)时，您可能会遇到以下错误：

```plaintext
Can connect to the primary node ... no
Reason:
end of file reached
```

如果在设置中指定了错误的主站点 URL，则可能会发生这种情况。要进行故障排除，请在 [Rails 控制台](../../../operations/rails_console.md)中运行以下命令：

```ruby
primary = Gitlab::Geo.primary_node
primary.internal_uri
Gitlab::HTTP.get(primary.internal_uri, allow_local_requests: true, limit: 10)
```

确保前面输出中的 `internal_uri` 值正确。如果主站点的 URL 不正确，请在 `/etc/gitlab/gitlab.rb`中以及**管理员** > **Geo** > **站点**中仔细检查它。

<a id="excessive-database-io-from-geo-metrics-collection"></a>

### Geo 指标收集导致数据库 IO 过多

Geo 指标收集会扫描大型表，例如 `ci_job_artifact_states` 和 `job_artifact_registry`，因此其成本会随着复制数据量的增长而增长。请按顺序考虑以下补救措施：

1. [减少复制数据量](../tuning.md#reduce-the-amount-of-replicated-data)，
   这解决了根本原因，同时也减少了同步和验证负载。
1. [使用预计算的验证摘要](#use-pre-calculated-verification-summaries)，
   它用增量更新替代全表扫描。
1. 降低指标收集的频率，这以监控新鲜度为代价换取更低的数据库负载。

如果您因频繁的 Geo 指标收集而遇到高数据库负载，您可以降低 `geo_metrics_update_worker` 作业的频率。在指标收集显著影响数据库性能的大型极狐GitLab 实例中，此调整有助于缓解数据库压力。

增加间隔意味着您的 Geo 指标更新频率降低。这会导致指标在更长时间内处于过期状态，这可能会影响您实时监控 Geo 复制的能力。如果指标过期超过 10 分钟，站点会在管理区域中被任意标记为“不健康”。

以下示例将作业设置为每 30 分钟运行一次。根据您的需要调整 cron 计划。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 在 `/etc/gitlab/gitlab.rb`中添加或修改以下设置：

   ```ruby
   gitlab_rails['geo_metrics_update_worker_cron'] = "*/30 * * * *"
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     ee_cron_jobs:
       geo_metrics_update_worker:
         cron: "*/30 * * * *"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="use-pre-calculated-verification-summaries"></a>

#### 使用预计算的验证摘要

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

您无需降低指标收集频率，而是可以为 CI 作业产物启用预计算的验证摘要。这用增量更新替代全表扫描，因此只重新统计已更改的数据。

启用后，后台工作进程会在专用表中维护摘要计数。当验证状态发生变化时，数据库触发器会将受影响的桶标记为脏，工作进程只重新计算这些桶。在大型实例上，这可将指标收集带来的数据库负载降低几个数量级。

要启用：

```shell
sudo gitlab-rails runner 'Feature.enable(:geo_job_artifact_verification_summaries)'
```

要禁用：

```shell
sudo gitlab-rails runner 'Feature.disable(:geo_job_artifact_verification_summaries)'
```
