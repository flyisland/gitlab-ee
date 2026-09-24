---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 维护 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供用于常规维护的 Rake 任务。

<a id="gather-gitlab-and-system-information"></a>

## 收集极狐GitLab 和系统信息

此命令收集有关您的极狐GitLab 安装及其运行系统的信息。这些信息在寻求帮助或报告问题时可能很有用。在多节点环境中，请在运行 GitLab Rails 的节点上运行此命令，以避免 PostgreSQL socket 错误。

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake gitlab:env:info
  ```

- 自编译安装：

  ```shell
  bundle exec rake gitlab:env:info RAILS_ENV=production
  ```

输出示例：

```plaintext
System information
System:         Ubuntu 20.04
Proxy:          no
Current User:   git
Using RVM:      no
Ruby Version:   2.7.6p219
Gem Version:    3.1.6
Bundler Version:2.3.15
Rake Version:   13.0.6
Redis Version:  6.2.7
Sidekiq Version:6.4.2
Go Version:     unknown

GitLab information
Version:        15.5.5-ee
Revision:       5f5109f142d
Directory:      /opt/gitlab/embedded/service/gitlab-rails
DB Adapter:     PostgreSQL
DB Version:     13.8
URL:            https://app.gitaly.gcp.gitlabsandbox.net
HTTP Clone URL: https://app.gitaly.gcp.gitlabsandbox.net/some-group/some-project.git
SSH Clone URL:  git@app.gitaly.gcp.gitlabsandbox.net:some-group/some-project.git
Elasticsearch:  no
Geo:            no
Using LDAP:     no
Using Omniauth: yes
Omniauth Providers:

GitLab Shell
Version:        14.12.0
Repository storage paths:
- default:      /var/opt/gitlab/git-data/repositories
- gitaly:       /var/opt/gitlab/git-data/repositories
GitLab Shell path:              /opt/gitlab/embedded/service/gitlab-shell


Gitaly
- default Address:      unix:/var/opt/gitlab/gitaly/gitaly.socket
- default Version:      15.5.5
- default Git Version:  2.37.1.gl1
- gitaly Address:       tcp://10.128.20.6:2305
- gitaly Version:       15.5.5
- gitaly Git Version:   2.37.1.gl1
```

<a id="show-gitlab-license-information"></a>

## 显示极狐GitLab 许可证信息

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此命令显示有关您的 [极狐GitLab 许可证](../license.md) 的信息以及已使用的席位数量。它仅适用于极狐GitLab 企业版安装：许可证无法安装到极狐GitLab 基础版中。

这些信息在向支持团队提交工单或通过编程方式检查许可证参数时可能很有用。

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake gitlab:license:info
  ```

- 自编译安装：

  ```shell
  bundle exec rake gitlab:license:info RAILS_ENV=production
  ```

输出示例：

```plaintext
Today's Date: 2020-02-29
Current User Count: 30
Max Historical Count: 30
Max Users in License: 40
License valid from: 2019-11-29 to 2020-11-28
Email associated with license: user@example.com
```

<a id="check-gitlab-configuration"></a>

## 检查极狐GitLab 配置

`gitlab:check` Rake 任务会运行以下 Rake 任务：

- `gitlab:gitlab_shell:check`
- `gitlab:gitaly:check`
- `gitlab:sidekiq:check`
- `gitlab:incoming_email:check`
- `gitlab:ldap:check`
- `gitlab:app:check`
- `gitlab:geo:check`（仅当您运行 [Geo](../geo/replication/troubleshooting/common.md#health-check-rake-task) 时）

它会检查每个组件是否按照安装指南进行设置，并针对发现的问题提出修复建议。此命令必须在您的应用服务器上运行，并且在 [Gitaly](../gitaly/configure_gitaly.md#run-gitaly-on-its-own-server) 等组件服务器上无法正常工作。

您也可以查看我们的故障排除指南：

- [极狐GitLab](../troubleshooting/_index.md)。
- [Linux 软件包安装](https://gitlab.cn/docs/omnibus/#troubleshooting)。

此外，您还应该 [验证数据库值可以使用当前密钥解密](check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)。

要运行 `gitlab:check`，请运行：

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake gitlab:check
  ```

- 自编译安装：

  ```shell
  bundle exec rake gitlab:check RAILS_ENV=production
  ```

- Kubernetes 安装：

  ```shell
  kubectl exec -it <toolbox-pod-name> -- sudo gitlab-rake gitlab:check
  ```

  > [!note]
  > 由于基于 Helm 的极狐GitLab 安装具有特定架构，输出中可能包含对 `gitlab-shell`、Sidekiq 和 `systemd` 相关文件连接验证的误报。
  > 这些报告的失败是预期行为，并不表示实际存在问题。在审阅诊断结果时请忽略它们。

如果您希望从输出中省略项目名称，请为 `gitlab:check` 使用 `SANITIZE=true`。

输出示例：

```plaintext
Checking Environment ...

Git configured for git user? ... yes
Has python2? ... yes
python2 is supported version? ... yes

Checking Environment ... Finished

Checking GitLab Shell ...

GitLab Shell version? ... OK (1.2.0)
Repo base directory exists? ... yes
Repo base directory is a symlink? ... no
Repo base owned by git:git? ... yes
Repo base access is drwxrws---? ... yes
post-receive hook up-to-date? ... yes
post-receive hooks in repos are links: ... yes

Checking GitLab Shell ... Finished

Checking Sidekiq ...

Running? ... yes

Checking Sidekiq ... Finished

Checking GitLab App...

Database config exists? ... yes
Database is SQLite ... no
All migrations up? ... yes
GitLab config exists? ... yes
GitLab config up to date? ... no
Cable config exists? ... yes
Resque config exists? ... yes
Log directory writable? ... yes
Tmp directory writable? ... yes
Init script exists? ... yes
Init script up-to-date? ... yes
Redis version >= 2.0.0? ... yes

Checking GitLab ... Finished
```

<a id="rebuild-authorized_keys-file"></a>

## 重建 `authorized_keys` 文件

在某些情况下，有必要重建 `authorized_keys` 文件，例如，如果升级后通过 [SSH](../../user/ssh.md) 推送时收到 `Permission denied (publickey)` 错误，
并在 [`gitlab-shell.log` 文件](../logs/_index.md#gitlab-shelllog) 中发现 `404 Key Not Found` 错误。
要重建 `authorized_keys`，请运行：

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake gitlab:shell:setup
  ```

- 自编译安装：

  ```shell
  cd /home/git/gitlab
  sudo -u git -H bundle exec rake gitlab:shell:setup RAILS_ENV=production
  ```

输出示例：

```plaintext
This will rebuild an authorized_keys file.
You will lose any data stored in authorized_keys file.
Do you want to continue (yes/no)? yes
```

<a id="clear-redis-cache"></a>

## 清除 Redis 缓存

如果由于某种原因仪表板显示错误信息，您可能需要清除 Redis 的缓存。为此，请运行：

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake cache:clear
  ```

- 自编译安装：

  ```shell
  cd /home/git/gitlab
  sudo -u git -H bundle exec rake cache:clear RAILS_ENV=production
  ```

<a id="precompile-the-assets"></a>

## 预编译资源

有时在版本升级过程中，您可能会遇到一些错误的 CSS 或缺少某些图标。在这种情况下，请尝试重新预编译资源。

此 Rake 任务仅适用于自编译安装。有关在运行 Linux 软件包时排查此问题的更多信息，请 [阅读更多](../../update/package/package_troubleshooting.md#missing-asset-files)。
针对 Linux 软件包的指南可能适用于极狐GitLab 的 Kubernetes 和 Docker 部署，但通常基于容器的安装不会遇到缺少资源的问题。

- 自编译安装：

  ```shell
  cd /home/git/gitlab
  sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production
  ```

对于 Linux 软件包安装，未优化的资源（JavaScript、CSS）在上游 GitLab 发布时被冻结。Linux 软件包安装包含这些资源的优化版本。除非您在安装软件包后修改了生产机器上的 JavaScript / CSS 代码，否则没有理由在生产机器上重新执行 `rake gitlab:assets:compile`。如果您怀疑资源已损坏，应重新安装 Linux 软件包。

<a id="check-tcp-connectivity-to-a-remote-site"></a>

## 检查到远程站点的 TCP 连接

有时您需要知道您的极狐GitLab 安装是否可以连接到另一台机器上的 TCP 服务（例如 PostgreSQL 或 Web 服务器），以排查代理问题。我们提供了一个 Rake 任务来帮助您解决此问题。

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake gitlab:tcp_check[example.com,80]
  ```

- 自编译安装：

  ```shell
  cd /home/git/gitlab
  sudo -u git -H bundle exec rake gitlab:tcp_check[example.com,80] RAILS_ENV=production
  ```

<a id="clear-exclusive-lease-danger"></a>

## 清除独占锁（危险）

极狐GitLab 使用共享锁机制：`ExclusiveLease` 来防止对共享资源的同时操作。一个例子是在代码仓库上运行定期垃圾回收。

在非常特殊的情况下，被独占锁锁定的操作可能会失败而无法释放锁。如果您无法等待其过期，可以运行此任务手动清除它。

要清除所有独占锁：

> [!warning]
> 不要在极狐GitLab 或 Sidekiq 运行时运行此命令

```shell
sudo gitlab-rake gitlab:exclusive_lease:clear
```

要指定锁 `type` 或锁 `type + id`，请指定一个范围：

```shell
# to clear all leases for repository garbage collection:
sudo gitlab-rake gitlab:exclusive_lease:clear[project_housekeeping:*]

# to clear a lease for repository garbage collection in a specific project: (id=4)
sudo gitlab-rake gitlab:exclusive_lease:clear[project_housekeeping:4]
```

<a id="display-status-of-database-migrations"></a>

## 显示数据库迁移状态

请参阅 [后台迁移文档](../../update/background_migrations.md)，了解在升级极狐GitLab 时如何检查迁移是否完成。

要检查特定迁移的状态，可以使用以下 Rake 任务：

```shell
sudo gitlab-rake db:migrate:status
```

要检查 [Geo 从站点上的跟踪数据库](../geo/setup/external_database.md#configure-the-tracking-database)，可以使用以下 Rake 任务：

```shell
sudo gitlab-rake db:migrate:status:geo
```

这会输出一个表格，其中每个迁移的 `Status` 为 `up` 或 `down`。示例：

```shell
database: gitlabhq_production

 Status   Migration ID    Type     Milestone    Name
--------------------------------------------------
   up     20240701074848  regular  17.2         AddGroupIdToPackagesDebianGroupComponents
   up     20240701153843  regular  17.2         AddWorkItemsDatesSourcesSyncToIssuesTrigger
   up     20240702072515  regular  17.2         AddGroupIdToPackagesDebianGroupArchitectures
   up     20240702133021  regular  17.2         AddWorkspaceTerminationTimeoutsToRemoteDevelopmentAgentConfigs
   up     20240604064938  post     17.2         FinalizeBackfillPartitionIdCiPipelineMessage
   up     20240604111157  post     17.2         AddApprovalPolicyRulesFkOnApprovalGroupRules
```

从极狐GitLab 17.1 开始，迁移按照符合极狐GitLab 发布节奏的顺序执行。

<a id="run-incomplete-database-migrations"></a>

## 运行未完成的数据库迁移

数据库迁移可能会卡在不完整状态，在 `sudo gitlab-rake db:migrate:status` 命令的输出中显示为 `down` 状态。

1. 要完成这些迁移，请使用以下 Rake 任务：

   ```shell
   sudo gitlab-rake db:migrate
   ```

1. 命令完成后，运行 `sudo gitlab-rake db:migrate:status` 检查所有迁移是否已完成（状态为 `up`）。
1. 热重载 `puma` 和 `sidekiq` 服务：

   ```shell
   sudo gitlab-ctl hup puma
   sudo gitlab-ctl restart sidekiq
   ```

从极狐GitLab 17.1 开始，迁移按照符合极狐GitLab 发布节奏的顺序执行。

<a id="rebuild-database-indexes"></a>

## 重建数据库索引

> [!warning]
> 在生产环境中运行时请谨慎使用，并在非高峰时段运行。

可以定期重建数据库索引以回收空间并长期保持健康的索引膨胀水平。重新索引也可以作为 [常规 cron 作业](https://gitlab.cn/docs/omnibus/settings/database/#automatic-database-reindexing) 运行。“健康”的膨胀水平高度依赖于特定索引，但通常应低于 30%。

数据库重新索引执行以下任务：

1. 重新索引手动排队的 PostgreSQL 索引：可以将索引手动添加到重新索引队列中。重新索引 PostgreSQL 索引通常会减少 [索引膨胀](https://wiki.postgresql.org/wiki/Index_Maintenance#Index_Bloat)。
1. 使用 [索引膨胀](https://wiki.postgresql.org/wiki/Index_Maintenance#Index_Bloat) 启发式方法自动重新索引 PostgreSQL 索引：PostgreSQL 使用启发式方法识别膨胀最严重的索引。该过程在每次运行时最多选择 2 个索引进行重新索引。

先决条件：

- 此功能需要 PostgreSQL 12 或更高版本。
- 不支持以下索引类型：表达式索引和用于约束排除的索引。

<a id="run-reindexing"></a>

### 运行重新索引

以下任务仅重建每个数据库中膨胀率最高的两个索引。要重建两个以上的索引，请再次运行该任务，直到所有需要的索引都已重建。

1. 运行重新索引任务：

   ```shell
   sudo gitlab-rake gitlab:db:reindex
   ```

1. 检查 [`application_json.log`](../logs/_index.md#application_jsonlog) 以验证执行情况或进行故障排除。

对于使用 [Toolbox chart](https://gitlab.cn/docs/charts/charts/gitlab/toolbox/#configure-periodic-database-reindexing) 运行此任务的极狐GitLab Cloud Native 安装，日志位于 Pod 的标准输出中。

<a id="customize-reindexing-settings"></a>

### 自定义重新索引设置

对于较小的实例或调整重新索引行为，您可以使用 Rails 控制台修改这些设置：

```shell
sudo gitlab-rails console
```

然后自定义配置：

```ruby
# Lower minimum index size to 100 MB (default is 1 GB)
Gitlab::Database::Reindexing.minimum_index_size!(100.megabytes)

# Change minimum bloat threshold to 30% (default is 20%, there is no benefit from setting it lower)
Gitlab::Database::Reindexing.minimum_relative_bloat_size!(0.3)
```

<a id="automated-reindexing"></a>

### 自动重新索引

对于数据库规模较大的实例，可以通过安排在低活动期间运行来自动化数据库重新索引。

<a id="schedule-with-crontab"></a>

#### 使用 crontab 调度

对于软件包安装的极狐GitLab，使用 crontab：

1. 编辑 crontab：

   ```shell
   sudo crontab -e
   ```

1. 根据您偏好的计划添加条目：

   1. 选项 1：在安静时段每天运行

   ```shell
   # Run database reindexing every day at 21:12
   # The log will be rotated by the packaged logrotate daemon
   12 21 * * * /opt/gitlab/bin/gitlab-rake gitlab:db:reindex >> /var/log/gitlab/gitlab-rails/cron_reindex.log 2>&1
   ```

   1. 选项 2：仅在周末运行

   ```shell
   # Run database reindexing at 01:00 AM on weekends
   0 1 * * 0,6 /opt/gitlab/bin/gitlab-rake gitlab:db:reindex >> /var/log/gitlab/gitlab-rails/cron_reindex.log 2>&1
   ```

   1. 选项 3：在低流量时段频繁运行

   ```shell
   # Run database reindexing every 3 hours during night hours (22:00-07:00)
   0 22,1,4,7 * * * /opt/gitlab/bin/gitlab-rake gitlab:db:reindex >> /var/log/gitlab/gitlab-rails/cron_reindex.log 2>&1
   ```

对于 Kubernetes 部署，您可以使用 CronJob 资源创建类似的计划来运行重新索引任务。

<a id="notes"></a>

### 备注

- 重建数据库索引是一项磁盘密集型任务，因此您应在非高峰时段执行该任务。在高峰时段运行该任务可能导致膨胀加剧，并可能导致某些查询变慢。
- 该任务需要足够的磁盘空间来恢复索引。创建的索引会附加 `_ccnew` 后缀。如果重新索引任务失败，重新运行该任务会清理临时索引。
- 数据库索引重建完成所需的时间取决于目标数据库的大小。可能需要几个小时到几天不等。
- 该任务使用 Redis 锁，因此可以安全地频繁调度运行。如果另一个重新索引任务已在运行，则此任务为无操作。

<a id="dump-the-database-schema"></a>

## 转储数据库模式

在极少数情况下，即使所有数据库迁移都已完成，数据库模式也可能与应用程序代码期望的不同。如果发生这种情况，可能会导致极狐GitLab 出现奇怪的错误。

要转储数据库模式：

```shell
SCHEMA=/tmp/structure.sql gitlab-rake db:schema:dump
```

该 Rake 任务会创建一个包含数据库模式转储的 `/tmp/structure.sql` 文件。

要确定是否存在任何差异：

1. 转到 [`gitlab`](https://jihulab.com/gitlab-cn/gitlab) 项目中的 [`db/structure.sql`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/db/structure.sql) 文件。
   选择与您的极狐GitLab 版本匹配的分支。例如，上游 GitLab 19.2 的文件：<https://gitlab.com/gitlab-org/gitlab/-/blob/19-2-stable-ee/db/structure.sql>。
1. 将 `/tmp/structure.sql` 与您版本的 `db/structure.sql` 文件进行比较。

<a id="check-the-database-for-schema-inconsistencies"></a>

## 检查数据库是否存在模式不一致

此 Rake 任务检查数据库模式是否存在任何不一致，并在终端中打印出来。此任务是诊断工具，应在极狐GitLab 支持的指导下使用。您不应将此任务用于常规检查，因为数据库不一致可能是预期行为。

```shell
gitlab-rake gitlab:db:schema_checker:run
```

<a id="collect-information-and-statistics-about-the-database"></a>

## 收集有关数据库的信息和统计信息

`gitlab:db:sos` 命令收集有关您的极狐GitLab 数据库的配置、性能和诊断数据，以帮助您排查问题。运行此命令的位置取决于您的配置。请确保在极狐GitLab 安装目录 `(/gitlab)` 下运行此命令。

- **扩展部署的极狐GitLab**：在您的 Puma 或 Sidekiq 服务器上。
- **Cloud Native 安装**：在 toolbox Pod 上。
- **所有其他配置**：在您的极狐GitLab 服务器上。

根据需要修改命令：

- **默认路径** - 要使用默认文件路径 (`/var/opt/gitlab/gitlab-rails/tmp/sos.zip`) 运行命令，请运行 `gitlab-rake gitlab:db:sos`。
- **自定义路径** - 要更改文件路径，请运行 `gitlab-rake gitlab:db:sos["/absolute/custom/path/to/file.zip"]`。
- **Zsh 用户** - 如果您尚未修改 Zsh 配置，则必须为整个命令添加引号，如下所示：`gitlab-rake "gitlab:db:sos[/absolute/custom/path/to/file.zip]"`

该 Rake 任务运行五分钟。它会在您指定的路径中创建一个压缩文件夹。该压缩文件夹包含大量文件。

<a id="enable-optional-query-statistics-data"></a>

### 启用可选的查询统计信息数据

`gitlab:db:sos` Rake 任务还可以使用 [`pg_stat_statements` 扩展](https://www.postgresql.org/docs/16/pgstatstatements.html) 收集数据以排查慢查询问题。

启用此扩展是可选的，并且需要重启 PostgreSQL 和极狐GitLab。排查由慢数据库查询引起的极狐GitLab 性能问题时，可能需要此数据。

先决条件：

- 您必须是具有超级用户权限的 PostgreSQL 用户才能启用或禁用扩展。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 修改 `/etc/gitlab/gitlab.rb` 以添加以下行：

   ```ruby
   postgresql['shared_preload_libraries'] = 'pg_stat_statements'
   ```

1. 运行 reconfigure：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. PostgreSQL 需要重启以加载此扩展，这也需要重启极狐GitLab：

   ```shell
   sudo gitlab-ctl restart postgresql
   sudo gitlab-ctl restart sidekiq
   sudo gitlab-ctl restart puma
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 修改 `/etc/gitlab/gitlab.rb` 以添加以下行：

   ```ruby
   postgresql['shared_preload_libraries'] = 'pg_stat_statements'
   ```

1. 运行 reconfigure：

   ```shell
   docker exec -it <container-id> gitlab-ctl reconfigure
   ```

1. PostgreSQL 需要重启以加载此扩展，这也需要重启极狐GitLab：

   ```shell
   docker exec -it <container-id> gitlab-ctl restart postgresql
   docker exec -it <container-id> gitlab-ctl restart sidekiq
   docker exec -it <container-id> gitlab-ctl restart puma
   ```

{{< /tab >}}

{{< tab title="External PostgreSQL service" >}}

1. 在您的 `postgresql.conf` 文件中添加或取消注释以下参数

   ```shell
   shared_preload_libraries = 'pg_stat_statements'
   pg_stat_statements.track = all
   ```

1. 重启 PostgreSQL 以使更改生效。
1. 重启极狐GitLab：应重启 Web（Puma）和 Sidekiq 服务。

{{< /tab >}}

{{< /tabs >}}

1. 在 [数据库控制台](../troubleshooting/postgresql.md) 上运行：

   ```SQL
   CREATE EXTENSION pg_stat_statements;
   ```

1. 检查扩展是否正常工作：

   ```SQL
   SELECT extname FROM pg_extension WHERE extname = 'pg_stat_statements';
   SELECT * FROM pg_stat_statements LIMIT 10;
   ```

<a id="check-the-database-for-duplicate-cicd-tags"></a>

## 检查数据库是否存在重复的 CI/CD 标签

此 Rake 任务检查 `ci` 数据库中 `tags` 表中的重复标签。此问题可能影响长时间内经历多次主要升级的实例。运行以下命令搜索重复标签，然后将引用重复标签的任何标签分配重写为使用原始标签。

```shell
sudo gitlab-rake gitlab:db:deduplicate_tags
```

要以试运行模式运行此命令，请设置环境变量 `DRY_RUN=true`。

<a id="detect-postgresql-collation-version-mismatches"></a>

## 检测 PostgreSQL 排序规则版本不匹配

PostgreSQL 排序规则检查器：

- 检测数据库与操作系统之间可能导致索引损坏的排序规则版本不匹配。PostgreSQL 使用操作系统的 `glibc` 库进行字符串排序（排序和比较规则）。
- 对预定义的索引集执行损坏抽查（重复检测）。这些索引已知因排序规则不匹配而容易出现损坏问题。

在更改底层 `glibc` 库的操作系统升级后，运行此任务。

先决条件：

- PostgreSQL 13 或更高版本。

要检查所有数据库中的 PostgreSQL 排序规则不匹配和相关索引损坏：

```shell
sudo gitlab-rake gitlab:db:collation_checker
```

要检查特定数据库：

```shell
# Check main database
sudo gitlab-rake gitlab:db:collation_checker:main

# Check CI database
sudo gitlab-rake gitlab:db:collation_checker:ci
```

<a id="adjust-table-size-limits"></a>

### 调整表大小限制

默认情况下，会跳过大于 1 GB 的表，以避免可能影响数据库性能的长时间运行查询。您可以通过设置 `MAX_TABLE_SIZE` 环境变量来调整表大小阈值。

> [!warning]
> 增加表大小限制可能导致长时间运行的查询，从而影响数据库性能。

```shell
# Set custom table size limit (in bytes)
# to increase the max table size threshold to 10 GB
MAX_TABLE_SIZE=10737418240 sudo gitlab-rake gitlab:db:collation_checker:main
```

<a id="bypass-pgbouncer-for-long-running-queries"></a>

### 为长时间运行的查询绕过 PgBouncer

请参阅故障排除部分中的 [解决语句超时错误](#resolve-statement-timeout-errors)。

<a id="example-output"></a>

### 输出示例

当未发现问题时：

```plaintext
Checking for PostgreSQL collation mismatches on main database...
No collation mismatches detected on main.
Found 8 indexes to corruption spot check.
No corrupted indexes detected.
```

如果检测到不匹配，该任务会提供修复受影响索引的补救步骤。

存在不匹配时的输出示例：

```plaintext
Checking for PostgreSQL collation mismatches on main database...
⚠️ COLLATION MISMATCHES DETECTED on main database!
2 collation(s) have version mismatches:
  - en_US.utf8: stored=428.1, actual=513.1
  - es_ES.utf8: stored=428.1, actual=513.1

Found 8 indexes to corruption spot check.
Affected indexes that need to be rebuilt:
  - index_projects_on_name (btree) on table projects
    • Issues detected: duplicates
    • Affected columns: name
    • Type: UNIQUE
    • Needs deduplication: Yes

REMEDIATION STEPS:
1. Put GitLab into maintenance mode
2. Run the following SQL commands:

# Step 1: Check for duplicate entries in unique indexes
SELECT name, COUNT(*), ARRAY_AGG(id) FROM projects GROUP BY name HAVING COUNT(*) > 1 LIMIT 1;

# If duplicates exist, you may need to use gitlab:db:deduplicate_tags or similar tasks
# to fix duplicate entries before rebuilding unique indexes.

# Step 2: Rebuild affected indexes
# Option A: Rebuild individual indexes with minimal downtime:
REINDEX INDEX CONCURRENTLY index_projects_on_name;

# Option B: Alternatively, rebuild all indexes at once (requires downtime):
REINDEX DATABASE main;

# Step 3: Refresh collation versions
ALTER DATABASE main REFRESH COLLATION VERSION;

3. Take GitLab out of maintenance mode
```

有关 PostgreSQL 排序规则问题及其如何影响数据库索引的更多信息，请参阅 [PostgreSQL 升级操作系统文档](../postgresql/upgrading_os.md)。

<a id="repair-corrupted-database-indexes"></a>

## 修复损坏的数据库索引

索引修复工具可修复可能导致数据完整性问题的损坏或缺失的数据库索引。该工具针对受排序规则不匹配或其他损坏问题影响的特定问题索引。该工具：

- 在唯一索引损坏时对数据进行去重。
- 更新引用以维护数据完整性。
- 使用正确的配置重建或创建索引。

在修复索引之前，以试运行模式运行该工具以分析潜在更改：

```shell
sudo DRY_RUN=true gitlab-rake gitlab:db:repair_index
```

以下示例输出显示了更改：

```shell
INFO -- : DRY RUN: Analysis only, no changes will be made.
INFO -- : Running Index repair on database main...
INFO -- : Processing index 'index_merge_request_diff_commit_users_on_name_and_email'...
INFO -- : Index is unique. Checking for duplicate data...
INFO -- : No duplicates found in 'merge_request_diff_commit_users' for columns: name,email.
INFO -- : Index exists. Reindexing...
INFO -- : Index reindexed successfully.
```

要修复所有数据库中所有已知的问题索引：

```shell
sudo gitlab-rake gitlab:db:repair_index
```

该命令处理每个数据库并修复索引。例如：

```shell
INFO -- : Running Index repair on database main...
INFO -- : Processing index 'index_merge_request_diff_commit_users_on_name_and_email'...
INFO -- : Index is unique. Checking for duplicate data...
INFO -- : No duplicates found in 'merge_request_diff_commit_users' for columns: name,email.
INFO -- : Index does not exist. Creating new index...
INFO -- : Index created successfully.
INFO -- : Index repair completed for database main.
```

要修复特定数据库中的索引：

```shell
# Repair indexes in main database
sudo gitlab-rake gitlab:db:repair_index:main

# Repair indexes in CI database
sudo gitlab-rake gitlab:db:repair_index:ci
```

<a id="bypass-pgbouncer-for-long-running-queries-1"></a>

### 为长时间运行的查询绕过 PgBouncer

请参阅故障排除部分中的 [解决语句超时错误](#resolve-statement-timeout-errors)。

<a id="troubleshooting"></a>

## 故障排除

<a id="advisory-lock-connection-information"></a>

### 咨询锁连接信息

运行 `db:migrate` Rake 任务后，您可能会看到类似以下的输出：

```shell
main: == [advisory_lock_connection] object_id: 173580, pg_backend_pid: 5532
main: == [advisory_lock_connection] object_id: 173580, pg_backend_pid: 5532
```

返回的消息仅供参考，可以忽略。

<a id="postgresql-socket-errors-when-executing-the-gitlabenvinfo-rake-task"></a>

### 执行 `gitlab:env:info` Rake 任务时出现 PostgreSQL socket 错误

在 Gitaly 或其他非 Rails 节点上运行 `sudo gitlab-rake gitlab:env:info` 后，您可能会看到以下错误：

```plaintext
PG::ConnectionBad: could not connect to server: No such file or directory
Is the server running locally and accepting
connections on Unix domain socket "/var/opt/gitlab/postgresql/.s.PGSQL.5432"?
```

这是因为在多节点环境中，`gitlab:env:info` Rake 任务只应在运行 **GitLab Rails** 的节点上执行。

<a id="resolve-statement-timeout-errors"></a>

### 解决语句超时错误

如果您的极狐GitLab 实例使用 PgBouncer，并且在数据库维护任务（如排序规则检查器或索引修复）期间遇到语句超时，请通过使用直接 PostgreSQL 连接来绕过 PgBouncer。

```shell
# Example with direct connection
GITLAB_BACKUP_PGUSER=postgres GITLAB_BACKUP_PGHOST=localhost sudo gitlab-rake gitlab:db:collation_checker

GITLAB_BACKUP_PGUSER=postgres GITLAB_BACKUP_PGHOST=localhost sudo gitlab-rake gitlab:db:repair_index
```

支持的环境变量：

- `GITLAB_BACKUP_PGHOST`
- `GITLAB_BACKUP_PGUSER`
- `GITLAB_BACKUP_PGPORT`
- `GITLAB_BACKUP_PGPASSWORD`

有关绕过 PgBouncer 的更多信息和支持的环境变量的完整列表，请参阅
[绕过 PgBouncer 的步骤](../postgresql/pgbouncer.md#procedure-for-bypassing-pgbouncer)。
