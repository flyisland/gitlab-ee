---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查常见 Geo 错误
description: 诊断和解决常见 Geo 问题，涵盖健康检查、数据库复制问题、站点连接性以及错误解决流程。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="basic-troubleshooting"></a>

## 基本故障排查

在进行更高级的故障排查之前：

- 检查 [Geo 站点的健康状况](#check-the-health-of-the-geo-sites)。
- 检查 [PostgreSQL 复制是否正常工作](#check-if-postgresql-replication-is-working)。

<a id="tracing-requests-across-geo-sites"></a>

### 跨 Geo 站点追踪请求

在对 Geo 进行故障排查时，您可能需要追踪从次要站点到主站点的请求，或反之。
极狐GitLab 使用关联 ID 来关联跨服务的相关日志条目。

默认情况下，每个站点在接收到请求时会生成自己的关联 ID。要使用相同的关联ID追踪跨两个站点的单个请求，您必须配置每个接收站点的 Workhorse 以接受来自其他 Geo 站点的传入关联 ID。

在所有 Geo 站点上：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_workhorse['propagate_correlation_id'] = true
   gitlab_workhorse['trusted_cidrs_for_propagation'] = %w(<次要站点-ip>/32)
   ```

1. 保存文件并重新配置 极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 更新您的 Helm 值：

   ```yaml
   gitlab:
     webservice:
       workhorse:
         extraArgs: "-propagateCorrelationID"
         trustedCIDRsForPropagation: ["<次要站点-ip>/32"]
   ```

1. 应用更改。

{{< /tab >}}

{{< /tabs >}}

启用此设置后，从次要站点发送到主站点的请求会在其日志中共享相同的关联 ID，从而使您能够追踪跨两个站点的请求。

<a id="check-the-health-of-the-geo-sites"></a>

### 检查 Geo 站点的健康状况

在**主站点**上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **Geo** > **站点**。

我们对每个**次要站点**执行以下健康检查，以帮助识别是否出现问题：

- 站点是否正在运行？
- 次要站点的数据库是否配置了流复制？
- 次要站点的跟踪数据库是否已配置？
- 次要站点的跟踪数据库是否已连接？
- 次要站点的跟踪数据库是否是最新的？
- 次要站点的状态是否少于 1 小时？

如果站点状态超过 1 小时未更新，则该站点显示为“不健康”。在这种情况下，尝试在受影响的次要站点的 [Rails 控制台](../../../operations/rails_console.md) 中运行以下命令：

```ruby
Geo::MetricsUpdateWorker.new.perform
```

如果它引发错误，则该错误可能也阻止了作业完成。如果耗时超过 1 小时，则状态可能会出现波动或持续显示为“不健康”，即使状态偶尔得到更新。这可能是因为使用量增长、数据随时间增加或性能缺陷（诸如缺少数据库索引）所致。

您可以使用 `top` 或 `htop` 等工具监控系统 CPU 负载。如果 PostgreSQL 占用了大量 CPU，这可能表明存在问题，或者系统资源不足。还应监控系统内存。

如果您增加了内存，还应该检查 `/etc/gitlab/gitlab.rb` 配置中与 PostgreSQL 内存相关的设置。

如果它成功更新了状态，则可能是 Sidekiq 出了问题。它是否在运行？日志中是否显示错误？该作业应该每分钟入队一次，如果 [作业去重幂等性](../../../sidekiq/sidekiq_troubleshooting.md#clearing-a-sidekiq-job-deduplication-idempotency-key) 键未被正确清除，可能不会运行。它在 Redis 中获取独占租约，以确保同一时间只有一个这类作业可以运行。主站点直接在 PostgreSQL 数据库中更新自身状态。次要站点向主站点发送 HTTP POST 请求，捎带其状态数据。

如果某些健康检查失败，站点也会显示为“不健康”。您可以通过在受影响的次要站点上的 [Rails 控制台](../../../operations/rails_console.md) 中运行以下命令来揭示失败详情：

```ruby
Gitlab::Geo::HealthCheck.new.perform_checks
```

如果它返回 `""`（空字符串）或 `"Healthy"`，则检查成功。如果返回其他内容，则该消息应解释失败原因，或显示异常消息。

有关如何解决用户界面报告的常见错误消息的信息，请参阅 [修复常见错误](#fixing-common-errors)。

如果用户界面无法工作，或者您无法登录，可以手动运行 Geo 健康检查以获取此信息以及更多详细信息。

<a id="health-check-rake-task"></a>

#### 健康检查 Rake 任务

{{< history >}}

- 使用自定义 NTP 服务器在 极狐GitLab 15.7 中引入。

{{< /history >}}

此 Rake 任务可以在**主站点**或**次要站点**的 **Rails** 节点上运行：

```shell
sudo gitlab-rake gitlab:geo:check
```

示例输出：

```plaintext
检查 Geo ...

极狐GitLab Geo 可用 ... 是
极狐GitLab Geo 已启用 ... 是
本机器的 Geo 节点名称与数据库记录匹配 ... 是，找到一个名为 "Shanghai" 的次要节点
极狐GitLab Geo 跟踪数据库已正确配置 ... 是
数据库复制已启用？... 是
数据库复制正常工作？... 是
极狐GitLab Geo HTTP(S) 连通性 ...
* 可以连接到主节点 ... 是
HTTP/HTTPS 仓库克隆已启用 ... 是
机器时钟已同步 ... 是
Git 用户具有默认 SSH 配置？... 是
OpenSSH 配置为使用 AuthorizedKeysCommand ... 是
极狐GitLab 配置为禁止写入 authorized_keys 文件 ... 是
极狐GitLab 配置为将新项目存储为哈希存储？... 是
所有项目均为哈希存储？... 是
容器镜像仓库复制已启用 ... 是
容器镜像仓库 Geo 事件 ... 最近事件在 2024-01-15 10:30:00 UTC

检查 Geo ... 完成
```

您还可以使用环境变量指定自定义 NTP 服务器。例如：

```shell
sudo gitlab-rake gitlab:geo:check NTP_HOST="ntp.ubuntu.com" NTP_TIMEOUT="30"
```

支持以下环境变量。

| 变量          | 描述                         | 默认值                                      |
| ------------- | ---------------------------- | ------------------------------------------- |
| `NTP_HOST`    | NTP 主机。                  | `pool.ntp.org`                              |
| `NTP_PORT`    | NTP 主机监听的端口。        | `123`                                       |
| `NTP_TIMEOUT` | NTP 超时秒数。              | 在 `net-ntp` Ruby 库中定义的值（[60 秒](https://github.com/zencoder/net-ntp/blob/3d0990214f439a5127782e0f50faeaf2c8ca7023/lib/net/ntp/ntp.rb#L6)）。 |

如果 Rake 任务跳过了 `OpenSSH configured to use AuthorizedKeysCommand` 检查，将显示以下输出：

```plaintext
OpenSSH 配置为使用 AuthorizedKeysCommand ... 跳过
  原因：
  无法访问 OpenSSH 配置文件
  尝试修复：
  如果您使用 SELinux，这是预期情况。您可能希望手动检查配置
  更多信息，请参见：
  doc/administration/operations/fast_ssh_key_lookup.md
```

此问题可能发生在以下情况：

- 您使用了 [SELinux](../../../operations/fast_ssh_key_lookup.md#selinux-support)。
- 您未使用 SELinux，但 `git` 用户因受限的文件权限无法访问 OpenSSH 配置文件。

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

当前同步信息可以通过在 Geo **次要站点**上运行 Rails 的任何节点（Puma、Sidekiq 或 Geo Log Cursor）上手动执行此 Rake 任务找到。

极狐GitLab **不会**验证存储在对象存储中的对象。如果您使用的是对象存储，您将看到所有“已验证”检查均显示 0 次成功。这是预期情况，无需担忧。

```shell
sudo gitlab-rake geo:status
```

输出包括：

- 如果发生任何失败，则显示“失败”项的数量
- “成功”项的百分比，相对于“总计”

示例：

```plaintext
                        Geo 站点信息
--------------------------------------------
                                      名称: example-us-east-2
                                      URL: https://gitlab.example.com
                                  Geo 角色: 次要站点
                             健康状态: 健康
                此节点的 极狐GitLab 版本: 17.7.0-ee

                     复制信息
--------------------------------------------
                             同步设置: 完全
                  数据库复制延迟: 0 秒
           从主站点看到的最后一个事件 ID: 12345 (约 2 分钟前)
                   最后处理的事件 ID: 12345 (约 2 分钟前)
                    最后状态报告时间: 1 分钟前

                          复制状态
--------------------------------------------
                    Lfs 对象 已复制: 成功 111 / 总计 111 (100%)
            合并请求差异 已复制: 成功 28 / 总计 28 (100%)
                  软件包文件 已复制: 成功 90 / 总计 90 (100%)
         Terraform 状态版本 已复制: 成功 65 / 总计 65 (100%)
           代码片段仓库 已复制: 成功 63 / 总计 63 (100%)
        群组 Wiki 仓库 已复制: 成功 14 / 总计 14 (100%)
             流水线产物 已复制: 成功 112 / 总计 112 (100%)
               Pages 部署 已复制: 成功 55 / 总计 55 (100%)
                        上传 已复制: 成功 2 / 总计 2 (100%)
                  作业产物 已复制: 成功 32 / 总计 32 (100%)
                CI 安全文件 已复制: 成功 44 / 总计 44 (100%)
         依赖代理 Blobs 已复制: 成功 15 / 总计 15 (100%)
      依赖代理清单 已复制: 成功 2 / 总计 2 (100%)
      项目 Wiki 仓库 已复制: 成功 2 / 总计 2 (100%)
 设计管理仓库 已复制: 成功 1 / 总计 1 (100%)
           项目仓库 已复制: 成功 2 / 总计 2 (100%)

                         验证状态
--------------------------------------------
                      Lfs 对象 已验证: 成功 111 / 总计 111 (100%)
             合并请求差异 已验证: 成功 28 / 总计 28 (100%)
                   软件包文件 已验证: 成功 90 / 总计 90 (100%)
         Terraform 状态版本 已验证: 成功 65 / 总计 65 (100%)
            代码片段仓库 已验证: 成功 63 / 总计 63 (100%)
         群组 Wiki 仓库 已验证: 成功 14 / 总计 14 (100%)
              流水线产物 已验证: 成功 112 / 总计 112 (100%)
                Pages 部署 已验证: 成功 55 / 总计 55 (100%)
                         上传 已验证: 成功 2 / 总计 2 (100%)
                   作业产物 已验证: 成功 32 / 总计 32 (100%)
                CI 安全文件 已验证: 成功 44 / 总计 44 (100%)
          依赖代理 Blobs 已验证: 成功 15 / 总计 15 (100%)
       依赖代理清单 已验证: 成功 2 / 总计 2 (100%)
       项目 Wiki 仓库 已验证: 成功 2 / 总计 2 (100%)
   设计管理仓库 已验证: 成功 1 / 总计 1 (100%)
             项目仓库 已验证: 成功 2 / 总计 2 (100%)

```

所有对象都已复制和验证，这些对象在 [Geo 术语表](../../glossary.md) 中定义。了解更多关于我们在[受支持的 Geo 数据类型](../datatypes.md#data-types)中用于复制和验证每种数据类型的方法。

要查找有关失败项的更多详细信息，请查看 [`gitlab-rails/geo.log` 文件](../../../logs/log_parsing.md#find-most-common-geo-sync-errors)。

如果您发现复制或验证失败，可以尝试 [解决它们](synchronization_verification.md)。

<a id="fixing-errors-found-when-running-the-geo-check-rake-task"></a>

##### 修复运行 Geo 检查 Rake 任务时发现的错误

运行此 Rake 任务时，如果节点未正确配置，您可能会看到以下错误消息：

```shell
sudo gitlab-rake gitlab:geo:check
```

- Rails 在连接数据库时未提供密码。

  ```plaintext
  检查 Geo ...

  极狐GitLab Geo 可用 ... 异常：fe_sendauth: 没有提供密码
  极狐GitLab Geo 已启用 ... 异常：fe_sendauth: 没有提供密码
  ...
  检查 Geo ... 完成
  ```

  确保将 `gitlab_rails['db_password']` 设置为创建 `postgresql['sql_user_password']` 哈希时使用的明文密码。

- Rails 无法连接到数据库。

  ```plaintext
  检查 Geo ...

  极狐GitLab Geo 可用 ... 异常：严重： 没有针对主机 "1.1.1.1"，用户 "gitlab"，数据库 "gitlabhq_production"，SSL 打开的 pg_hba.conf 条目
  严重： 没有针对主机 "1.1.1.1"，用户 "gitlab"，数据库 "gitlabhq_production"，SSL 关闭的 pg_hba.conf 条目
  极狐GitLab Geo 已启用 ... 异常：严重： 没有针对主机 "1.1.1.1"，用户 "gitlab"，数据库 "gitlabhq_production"，SSL 打开的 pg_hba.conf 条目
  严重： 没有针对主机 "1.1.1.1"，用户 "gitlab"，数据库 "gitlabhq_production"，SSL 关闭的 pg_hba.conf 条目
  ...
  检查 Geo ... 完成
  ```

  确保将 Rails 节点的 IP 地址包含在 `postgresql['md5_auth_cidr_addresses']` 中。另外，确保包含 IP 地址的子网掩码：`postgresql['md5_auth_cidr_addresses'] = ['1.1.1.1/32']`。

- Rails 提供了错误的密码。

  ```plaintext
  检查 Geo ...
  极狐GitLab Geo 可用 ... 异常：严重： 用户 "gitlab" 的密码验证失败
  严重： 用户 "gitlab" 的密码验证失败
  极狐GitLab Geo 已启用 ... 异常：严重： 用户 "gitlab" 的密码验证失败
  严重： 用户 "gitlab" 的密码验证失败
  ...
  检查 Geo ... 完成
  ```

  通过运行 `gitlab-ctl pg-password-md5 gitlab` 并输入密码，验证为 `gitlab_rails['db_password']` 设置的密码与创建 `postgresql['sql_user_password']` 哈希时使用的密码一致。

- 检查返回 `不是次要节点`。

  ```plaintext
  检查 Geo ...

  极狐GitLab Geo 可用 ... 是
  极狐GitLab Geo 已启用 ... 是
  极狐GitLab Geo 跟踪数据库已正确配置 ... 不是次要节点
  数据库复制已启用？... 不是次要节点
  ...
  检查 Geo ... 完成
  ```

  确保您已在**主站点**的 Web 界面中的 **管理员** 区域下的 **Geo** > **站点** 中添加了次要站点。还要确保您在**主站点**的 **管理员** 区域中添加次要站点时输入了 `gitlab_rails['geo_node_name']`。

- 检查返回 `异常：PG::UndefinedTable：错误： 关系 "geo_nodes" 不存在`。

  ```plaintext
  检查 Geo ...

  极狐GitLab Geo 可用 ... 否
    尝试修复：
    添加一个包含 极狐GitLab Geo 功能的新许可证
    更多信息，请参见：
    https://about.gitlab.com/features/gitlab-geo/
  极狐GitLab Geo 已启用 ... 异常：PG::UndefinedTable：错误： 关系 "geo_nodes" 不存在
  第 8 行：               WHERE a.attrelid = '"geo_nodes"'::regclass
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
  检查 Geo ... 完成
  ```

  当进行 PostgreSQL 大版本升级（9 > 10）时，出现此情况是预期的。按照[启动复制过程](../../setup/database.md#step-3-initiate-the-replication-process)进行操作。

- Rails 似乎没有连接 Geo 跟踪数据库所需的配置。

  ```plaintext
  检查 Geo ...

  极狐GitLab Geo 可用 ... 是
  极狐GitLab Geo 已启用 ... 是
  极狐GitLab Geo 跟踪数据库已正确配置 ... 否
  尝试修复：
  Rails 似乎没有连接 Geo 跟踪数据库所需的配置。如果跟踪数据库运行在本节点以外的节点上，则可能需要添加配置。
  ...
  检查 Geo ... 完成
  ```

  - 如果您在单个节点上运行次要站点的所有服务，请遵循 [Geo 数据库复制 - 配置次要服务器](../../setup/database.md#step-2-configure-the-secondary-server)。
  - 如果您在单独的节点上运行次要站点的跟踪数据库，请遵循 [多服务器 Geo - 在 Geo 次要站点上配置 Geo 跟踪数据库](../multiple_servers.md#step-2-configure-the-geo-tracking-database-on-the-geo-secondary-site)。
  - 如果您在 Patroni 集群中运行次要站点的跟踪数据库，请遵循 [Geo 数据库复制 - 为跟踪 PostgreSQL 数据库配置 Patroni 集群](../../setup/database.md#configuring-patroni-cluster-for-the-tracking-postgresql-database)。
  - 如果您在外部数据库中运行次要站点的跟踪数据库，请遵循 [使用外部 PostgreSQL 实例的 Geo](../../setup/external_database.md#configure-the-tracking-database)。
  - 如果 Geo 检查任务在未运行 极狐GitLab Rails 应用（Puma、Sidekiq 或 Geo Log Cursor）的节点上运行，则可以忽略此错误。该节点不需要配置 Rails。

<a id="message-container-registry-geo-events-none-found"></a>

##### 消息：容器镜像仓库 Geo 事件 ... 未找到

如果显示 `容器镜像仓库 Geo 事件 ... 未找到` 并且您希望存在容器镜像仓库复制事件，请验证**主站点**上的镜像仓库通知配置是否符合[容器镜像仓库复制配置指南](../container_registry.md#configure-primary-site)。

<a id="message-machine-clock-is-synchronized-exception"></a>

##### 消息：机器时钟已同步 ... 异常

Rake 任务尝试验证服务器时钟是否与 NTP 同步。时钟同步对于 Geo 正常工作至关重要。例如，出于安全考虑，当主站点和次要站点的服务器时间相差一分钟或更长时间时，Geo 站点之间的请求会失败。如果此检查任务由于时间不匹配以外的原因而未能完成，并不一定意味着 Geo 无法工作。

执行检查的 Ruby gem 硬编码使用 `pool.ntp.org` 作为其参考时间源。

- 异常消息 `机器时钟已同步 ... 异常：Timeout::Error`

  当您的服务器无法访问主机 `pool.ntp.org` 时，会出现此问题。

- 异常消息 `机器时钟已同步 ... 异常：没有到主机的路由 - recvfrom(2)`

  当主机名 `pool.ntp.org` 解析到不提供时间服务的服务器时，会出现此问题。

在这种情况下，在 极狐GitLab 15.7 及更高版本中，[使用环境变量指定自定义 NTP 服务器](#health-check-rake-task)。

在 极狐GitLab 15.6 及更早版本中，请使用以下解决方法之一：

- 在 `/etc/hosts` 中添加 `pool.ntp.org` 的条目，将请求定向到有效的本地时间服务器。这可以修复长时间的延迟和超时错误。
- 将检查定向到任何有效的 IP 地址。这可以解决超时问题，但检查会像之前备注的那样因为 `没有到主机的路由` 错误而失败。

[云原生极狐GitLab 部署](https://gitlab.cn/docs/charts/advanced/geo/#set-the-geo-primary-site) 会生成错误，因为 Kubernetes 中的容器无法访问主机时钟：

```plaintext
机器时钟已同步 ... 异常：getaddrinfo: 不支持 ai_socktype 的服务名
```

<a id="message-cannot-execute-insert-in-a-read-only-transaction"></a>

##### 消息：`无法在只读事务中执行 INSERT`

当在次要站点上遇到此错误时，它可能影响 极狐GitLab Rails 的所有用法，如 `gitlab-rails` 或 `gitlab-rake` 命令，以及 Puma、Sidekiq 和 Geo Log Cursor 服务。

```plaintext
ActiveRecord::StatementInvalid: PG::ReadOnlySqlTransaction: 错误： 无法在只读事务中执行 INSERT
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
2023-01-17_17:44:54.64268 错误：  无法在只读事务中执行 INSERT
2023-01-17_17:44:54.64271 语句：  /*application:web,db_config_name:main*/ INSERT INTO "shards" ("name") VALUES ('storage1') RETURNING "id"
```

此情况可能发生在：

- 在初始配置过程中，当次要站点尚未意识到它是次要站点时。要解决此错误，请遵循 [步骤 3. 添加次要站点](../configuration.md#step-3-add-the-secondary-site)。
- 在升级 Geo 次要站点期间。可能是因为 `gitlab_rails['auto_migrate']` 设置为 `true`，导致 极狐GitLab 尝试在副本数据库上执行数据库迁移，而这是不必要的。要解决此错误：

  1. 以 root 用户 SSH 登录到次要站点的 极狐GitLab Rails 节点。
  1. 编辑 `/etc/gitlab/gitlab.rb`，注释掉此设置或将其设置为 false：

     ```ruby
     gitlab_rails['auto_migrate'] = false
     ```

  1. 重新配置 极狐GitLab：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

<a id="check-if-postgresql-replication-is-working"></a>

### 检查 PostgreSQL 复制是否正常工作

要检查 PostgreSQL 复制是否正常工作，请检查以下方面：

- [站点是否指向正确的数据库节点](#are-sites-pointing-to-the-correct-database-node)。
- [Geo 能否正确检测当前站点](#can-geo-detect-the-current-site-correctly)。

如果您仍然遇到问题，请参阅 [高级复制故障排查](synchronization_verification.md)。

<a id="are-sites-pointing-to-the-correct-database-node"></a>

#### 站点是否指向正确的数据库节点？

您应确保您的**主** Geo [站点](../../glossary.md) 指向具有写入权限的数据库节点。

所有**次要**站点应仅指向只读数据库节点。

<a id="can-geo-detect-the-current-site-correctly"></a>

#### Geo 能否正确检测当前站点？

Geo 通过以下逻辑在 `/etc/gitlab/gitlab.rb` 中找到当前 Puma 或 Sidekiq 节点的 Geo [站点](../../glossary.md) 名称：

1. 获取 “Geo 节点名称”（有一个议题提议将这些设置重命名为 “Geo 站点名称”）：
   - Linux 安装包：获取 `gitlab_rails['geo_node_name']` 设置。
   - 极狐GitLab Helm Chart：获取 `global.geo.nodeName` 设置（请参阅 [带有 Geo 的 Chart](https://gitlab.cn/docs/charts/advanced/geo/)）。
1. 如果未定义，则获取 `external_url` 设置。

此名称用于在 **Geo 站点** 仪表盘中查找具有相同 **名称** 的 Geo 站点。

要检查当前机器是否具有与数据库中的站点匹配的站点名称，请运行检查任务：

```shell
sudo gitlab-rake gitlab:geo:check
```

它显示了当前机器的站点名称，以及匹配的数据库记录是**主**站点还是**辅**站点。

```plaintext
此机器的 Geo 节点名称与数据库记录匹配 ... 是，找到了名为 "Shanghai" 的辅节点
```

```plaintext
此机器的 Geo 节点名称与数据库记录匹配 ... 否
  请尝试修复此问题：
  您可以添加或更新 Geo 节点数据库记录，将名称设置为 "https://example.com/"。
  或者，您可以将此机器的 Geo 节点名称设置为与现有数据库记录的名称匹配："London"、"Shanghai"
  欲了解更多信息，请参阅：
  doc/administration/geo/replication/troubleshooting/_index.md#can-geo-detect-the-current-node-correctly
```

有关名称字段描述中推荐的站点名称的更多信息，请参见
[Geo **管理** 区域通用设置](../../../geo_sites.md#common-settings)。

### 检查操作系统区域数据兼容性

如有可能，所有站点上的所有 Geo 节点都应使用相同的方法和操作系统进行部署，具体请参考 [运行 Geo 的要求](../../_index.md#requirements-for-running-geo)。

如果在 Geo 站点之间部署了不同的操作系统或不同的操作系统版本，则**必须**在设置 Geo 之前执行区域数据兼容性检查。当使用混合的极狐GitLab 部署方法时，您还必须检查 `glibc`。Linux 安装包、极狐GitLab Docker 容器、Helm Chart 部署或外部数据库服务之间的区域可能不同。请参阅 [升级 PostgreSQL 操作系统的文档](../../../postgresql/upgrading_os.md)，包括如何检查 `glibc` 版本兼容性。

Geo 使用 PostgreSQL 和流复制在 Geo 站点之间复制数据。PostgreSQL 使用操作系统 C 库提供的区域数据对文本进行排序。如果 C 库中的区域数据在 Geo 站点之间不兼容，则会导致错误的查询结果，从而在 [辅站点上引发错误行为](https://gitlab.com/gitlab-org/gitlab/-/issues/360723)。

例如，Ubuntu 18.04（及更早版本）和 RHEL/CentOS 7（及更早版本）与它们的后续版本不兼容。
请参阅 [PostgreSQL wiki 了解更多详细信息](https://wiki.postgresql.org/wiki/Locale_data_changes)。

## 修复常见错误

本节记录了 Web 界面上 **管理** 区域报告的常见错误消息，以及如何修复它们。

### 无法重用现有的跟踪数据库

Geo 无法重用现有的跟踪数据库。

最安全的方法是使用全新的辅站点，或者按照
[重置 Geo 辅站点复制](synchronization_verification.md#resetting-geo-secondary-site-replication) 的方式重置整个辅站点。

在不重置的情况下重用辅站点是有风险的，因为辅站点可能错过了一些 Geo 事件。例如，错过的删除事件会导致辅站点永久性地保留了本应被删除的数据。同样，丢失一个物理移动数据位置的事件会导致数据在一个位置永久成为孤儿，并在另一个位置丢失，直到重新验证。这就是极狐GitLab 切换到哈希存储的原因，这使得移动数据变得不再必要。丢失事件还可能引发其他未知问题。

如果这些风险不适用，例如在测试环境中，或者您知道主 PostgreSQL 数据库仍然包含自添加 Geo 站点以来的所有 Geo 事件，那么您可以绕过此健康检查：

1. 获取最后处理的事件时间。在**辅**站点中的 Rails 控制台中，运行：

   ```ruby
   Geo::EventLogState.last.created_at.utc
   ```

1. 复制输出内容，例如 `2024-02-21 23:50:50.676918 UTC`。
1. 更新辅站点的创建时间，使其看起来更早。在**主**站点中的 Rails 控制台中，运行：

   ```ruby
   GeoNode.secondary_nodes.last.update_column(:created_at, DateTime.parse('2024-02-21 23:50:50.676918 UTC') - 1.second)
   ```

   此命令假设受影响的辅站点是最后创建的那个。

1. 在 **管理** > **Geo** > **站点** 中更新辅站点的状态。在**辅**站点中的 Rails 控制台中，运行：

   ```ruby
   Geo::MetricsUpdateWorker.new.perform
   ```

1. 辅站点应显示为健康状态。如果不是，请在辅站点上运行 `gitlab-rake gitlab:geo:check`，或者如果您在重新添加辅站点后尚未重启 Rails，请尝试重启 Rails。
1. 要重新同步缺失或过时的数据，请转到 **管理** > **Geo** > **站点**。
1. 在辅站点下选择 **复制详情**。
1. 为每种数据类型选择 **全部重新验证**。

### Geo 站点有一个可写数据库

此错误消息指**辅**站点上的数据库副本存在问题，
而 Geo 需要对该副本有访问权限。可写的辅站点数据库
表明该数据库未配置为与主站点进行复制。这通常意味着存在以下问题之一：

- 使用了不被支持的复制方法（例如，逻辑复制）。
- 未正确遵循[设置 Geo 数据库复制](../../setup/database.md)的说明。
- 您的数据库连接详细信息不正确，即您在 `/etc/gitlab/gitlab.rb` 文件中指定了错误的用户。

Geo **辅**站点需要两个独立的 PostgreSQL 实例：

- 一个**主**站点的只读副本。
- 一个常规的、可写的实例，用于保存复制元数据。即 Geo 跟踪数据库。

此错误消息表明辅站点中的副本数据库配置错误，并且复制已停止。

要恢复数据库并继续复制，您可以执行以下操作之一：

- [重置 Geo 辅站点复制](synchronization_verification.md#resetting-geo-secondary-site-replication)。
- [使用 Linux 安装包设置一个新的 Geo 辅站点](../../setup/_index.md#using-linux-package-installations)。

如果您从头开始设置一个新的辅站点，您还必须[从 Geo 集群中移除旧站点](../remove_geo_site.md)。

### Geo 站点似乎没有从主站点复制数据库

导致数据库无法正确复制的最常见问题是：

- **辅**站点无法访问**主**站点。请检查凭据和[防火墙规则](../../_index.md#firewall-rules)。
- SSL 证书问题。确保您已从**主**站点复制了 `/etc/gitlab/gitlab-secrets.json`。
- 数据库存储磁盘已满。
- 数据库复制槽配置错误。
- 数据库未使用复制槽或其他替代方案，并且由于 WAL 文件被清除而无法赶上进度。

请确保您遵循了 [Geo 数据库复制](../../setup/database.md) 中支持的配置说明。

### Geo 数据库版本 (...) 与最新迁移版本 (...) 不匹配

如果您使用的是 Linux 安装包，升级过程中可能发生了某些故障。您可以：

- 运行 `sudo gitlab-ctl reconfigure`。
- 通过以 root 用户身份在**辅**站点上运行 `sudo gitlab-rake db:migrate:geo` 来手动触发数据库迁移。

### 极狐GitLab 显示已同步的仓库超过 100%

这可能是由项目注册表中的孤儿记录引起的。系统会使用注册表工作进程定期清理它们，请稍等片刻让其自行修复。

### 主站点上校验和失败

由 Geo 主站点验证信息屏幕识别的校验和失败可能由丢失的文件或不匹配的校验和引起。您可以在 `gitlab-rails/geo.log` 文件中找到类似 `"因为仓库不存在，无法对其进行校验和计算"` 或 `"文件不能校验 - 文件不存在于以下路径: <path>"` 的错误消息。错误消息包含文件路径，以帮助识别丢失的文件。

有关失败项目的更多信息，请运行 [完整性检查 Rake 任务](../../../raketasks/check.md#uploaded-files-integrity)：

```ruby
sudo gitlab-rake gitlab:artifacts:check
sudo gitlab-rake gitlab:ci_secure_files:check
sudo gitlab-rake gitlab:lfs:check
sudo gitlab-rake gitlab:uploads:check
```

有关各个错误的详细信息，请使用 `VERBOSE=1` 变量。

### 辅站点在 UI 中显示为 **不健康**

如果您在 `/etc/gitlab/gitlab.rb` 中更新了主站点的 `external_url` 值，或将协议从 `http` 更改为 `https`，您可能会看到辅站点显示为 **不健康**。您还可能在 `geo.log` 中找到以下错误：

```plaintext
"class": "Geo::NodeStatusRequestService",
...
"message": "Failed to Net::HTTP::Post to primary url: http://primary-site.gitlab.tld/api/v4/geo/status",
  "error": "Failed to open TCP connection to <PRIMARY_IP_ADDRESS>:80 (Connection refused - connect(2) for \"<PRIMARY_ID_ADDRESS>\" port 80)"
```

在这种情况下，请确保在所有站点上更新已更改的 URL：

1. 在右上角，选择 **管理**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 更改 URL 并保存更改。

### 备份期间出现消息：`ERROR: canceling statement due to conflict with recovery`

在 Geo **辅**站点上运行备份[不受支持](https://gitlab.com/gitlab-org/gitlab/-/issues/211668)。

在**辅**站点上运行备份时，您可能会遇到以下错误消息：

```plaintext
Dumping PostgreSQL database gitlabhq_production ...
pg_dump: error: Dumping the contents of table "notes" failed: PQgetResult() failed.
pg_dump: error: Error message from server: ERROR:  canceling statement due to conflict with recovery
DETAIL:  User query might have needed to see row versions that must be removed.
pg_dump: error: The command was: COPY public.notes (id, note, [...], last_edited_at) TO stdout;
```

为防止在极狐GitLab 升级期间在 Geo **辅**站点自动进行数据库备份，
请创建以下空文件：

```shell
sudo touch /etc/gitlab/skip-auto-backup
```

### 在对象验证期间主站点 CPU 使用率高

从极狐GitLab 16.11 到 17.2，一个缺失的 PostgreSQL 索引会导致 CPU 使用率高以及产物验证进度缓慢。此外，Geo 辅站点可能会报告为不健康。[议题 471727](https://gitlab.com/gitlab-org/gitlab/-/issues/471727) 详细描述了此行为。

要确定您是否可能遇到此问题，请按照步骤
[确认您是否受到影响](https://gitlab.com/gitlab-org/gitlab/-/issues/471727#to-confirm-if-you-are-affected)。

如果您受到影响，请按照 [变通方法](https://gitlab.com/gitlab-org/gitlab/-/issues/471727#workaround) 中的步骤手动创建索引。创建索引会导致 PostgreSQL 在完成之前消耗略多的资源。随后，在验证继续期间，CPU 使用率可能保持高位，但查询应显著加快，辅站点状态应会正确更新。

### 验证失败，错误为：`Verification timed out after (...)`

从极狐GitLab 16.11 开始，Geo 可能会为同一个 `artifact_id` 创建重复的 `JobArtifactRegistry` 条目，这可能会导致主站点和辅站点之间同步失败。此问题也可能影响 `UploadRegistry` 和 `PackageFileRegistry` 条目。

要确定您是否可能遇到此问题并删除重复条目：

1. 在辅站点中打开一个 [Rails 控制台](../../../operations/rails_console.md)。
1. 获取具有重复项的模型记录 ID 的数量：

   ```ruby
   artifact_ids = Geo::JobArtifactRegistry.group(:artifact_id).having('COUNT(*) > 1').pluck(:artifact_id); artifact_ids.size
   upload_ids = Geo::UploadRegistry.group(:file_id).having('COUNT(*) > 1').pluck(:file_id); upload_ids.size
   package_file_ids = Geo::PackageFileRegistry.group(:package_file_id).having('COUNT(*) > 1').pluck(:package_file_id); package_file_ids.size
   ```

1. 输出 ID：

   ```ruby
   puts 'BEGIN Artifact IDs', artifact_ids, 'END Artifact IDs'
   puts 'BEGIN Upload IDs', upload_ids, 'END Upload IDs'
   puts 'BEGIN Package File IDs', package_file_ids, 'END Package File IDs'
   ```

   如果输出为空，则您未受影响。否则，请将终端输出保存在文本文件中，以防之后连接断开。

1. 删除所有重复项：

   ```ruby
   Geo::JobArtifactRegistry.where(artifact_id: artifact_ids).delete_all
   Geo::UploadRegistry.where(file_id: upload_ids).delete_all
   Geo::PackageFileRegistry.where(package_file_id: package_file_ids).delete_all
   ```

1. 等待后台作业再次创建注册表行并重新同步。

请关注 [议题 479852](https://gitlab.com/gitlab-org/gitlab/-/issues/479852) 以获取有关此修复的反馈。

### 在辅站点上运行 Geo Rake 检查任务时出现错误 `end of file reached`

在辅站点上运行 [健康检查 Rake 任务](common.md#health-check-rake-task) 时，您可能会遇到以下错误：

```plaintext
Can connect to the primary node ... no
Reason:
end of file reached
```

如果设置中指定了错误的主站点 URL，就可能发生此情况。要对其进行故障排除，
请在 [Rails 控制台](../../../operations/rails_console.md) 中运行以下命令：

```ruby
primary = Gitlab::Geo.primary_node
primary.internal_uri
Gitlab::HTTP.get(primary.internal_uri, allow_local_requests: true, limit: 10)
```

确保前面输出中 `internal_uri` 的值是正确的。
如果主站点的 URL 不正确，请在 `/etc/gitlab/gitlab.rb` 和 **管理** > **Geo** > **站点** 中仔细检查。

### 来自 Geo 指标收集的数据库 IO 过多

如果您因为频繁收集 Geo 指标而导致数据库负载过高，可以降低 `geo_metrics_update_worker` 作业的执行频率。此调整有助于减轻大型极狐GitLab 实例中因指标收集而严重影响数据库性能的数据库压力。

增加间隔意味着您的 Geo 指标更新频率会降低。这会导致指标在更长时间内过时，从而可能影响您实时监控 Geo 复制的能力。如果指标过时超过 10 分钟，该站点会在管理区域中被任意标记为“不健康”。

以下示例将作业设置为每 30 分钟运行一次。请根据您的需求调整 cron 计划。

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

1. 在 `/etc/gitlab/gitlab.rb` 中添加或修改以下设置：

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
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}