---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 17 升级说明
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页面包含极狐GitLab 17 次要版本和补丁版本的升级信息。请确保您查看以下说明：

- 您的安装类型。
- 当前版本与目标版本之间的所有版本。

有关 Helm Chart 安装的更多信息，请参阅
[Helm Chart 8.0 升级说明](https://gitlab.cn/docs/charts/releases/8_0/)。

<a id="issues-to-be-aware-of-when-upgrading"></a>

升级时需要注意的问题

当从某些极狐GitLab 版本升级时，您应该注意一些可能影响升级的问题。

<a id="from-gitlab-16.11"></a>

### 从极狐GitLab 16.11 升级

当您从极狐GitLab 16.11 升级时：

- 后台迁移 `AlterWebhookDeletedAuditEvent: audit_events` 可能需要几个小时才能完成。您可以在合并请求 161320 中了解更多信息。
- 在升级到极狐GitLab 17.0 或更高版本之前，您必须从 `gitlab.rb` 中删除对[现已弃用的捆绑 Grafana](../deprecations.md#bundled-grafana-deprecated-and-disabled) 键的引用。升级后，`gitlab.rb` 中对键的任何引用都将导致 `gitlab-ctl reconfigure` 失败。
- 在升级到极狐GitLab 17.0 之前，您应该[迁移到新的 Runner 注册工作流](../../ci/runners/new_creation_workflow.md)。

  在极狐GitLab 16.0 中，我们引入了一种新的 Runner 创建流程，该流程使用 Runner 认证令牌来注册 Runner。
  使用注册令牌的旧版工作流现在在极狐GitLab 17.0 中默认禁用，并计划在极狐GitLab 20.0 中移除。
  如果仍在使用注册令牌，升级到极狐GitLab 17.0 将导致 Runner 注册失败。
- Gitaly 存储不能再共享相同的路径，如下例所示：

  ```ruby
  gitaly['configuration'] = {
    storage: [
      {
         name: 'default',
         path: '/var/opt/gitlab/git-data/repositories',
      },
      {
         name: 'duplicate-path',
         path: '/var/opt/gitlab/git-data/repositories',
      },
    ],
  }
  ```

  在此示例中，必须删除 `duplicate-path` 存储或将其重新定位到新路径。如果您有多个 Gitaly 节点，则必须确保该节点的 `gitlab.rb` 文件中仅列出该节点对应的存储。

  如果从节点的 `gitlab.rb` 文件中删除了存储，则与之关联的任何项目都必须在极狐GitLab 数据库中更新其存储。您可以使用 Rails 控制台更新其存储。例如：

  ```shell
  $ sudo gitlab-rails console
  Project.where(repository_storage: 'duplicate-path').update_all(repository_storage: 'default')
  ```

- 从极狐GitLab 16.x 直接升级到极狐GitLab 17.1.0 或 17.1.1 时出现迁移失败。
  此错误已在极狐GitLab 17.1.2 中修复。
  从极狐GitLab 16.x 直接升级到 17.1.2 不会导致这些问题。

  由于极狐GitLab 17.1.0 和 17.1.1 中的一个错误，后台作业完成未正确执行，因此直接升级到极狐GitLab 17.1.0 和 17.1.1 时可能会出现故障。
  升级过程中迁移的错误如下所示：

  ```shell
  main: == [advisory_lock_connection] object_id: 55460, pg_backend_pid: 8714
  main: == 20240531173207 ValidateNotNullCheckConstraintOnEpicsIssueId: migrating =====
  main: -- execute("SET statement_timeout TO 0")
  main:    -> 0.0004s
  main: -- execute("ALTER TABLE epics VALIDATE CONSTRAINT check_450724d1bb;")
  main: -- execute("RESET statement_timeout")
  main: == [advisory_lock_connection] object_id: 55460, pg_backend_pid: 8714
  STDERR:
  ```

  要升级，请执行以下任一操作：

  - 升级到极狐GitLab 17.0，并等待所有后台迁移完成。
  - 升级到极狐GitLab 17.1，然后通过运行以下命令手动执行后台作业和迁移：

    ```shell
    sudo gitlab-rake gitlab:background_migrations:finalize[BackfillEpicBasicFieldsToWorkItemRecord,epics,id,'[null]']
    ```

  现在您应该能够在极狐GitLab 17.1 中完成迁移并完成升级。

- 极狐GitLab 17.0.x 和极狐GitLab 17.1.x 附带的 Git 版本中存在一个已知问题，在负载下会导致 CPU 使用率显著增加。此回归的主要原因已在极狐GitLab 17.2 附带的 Git 版本中解决，因此对于出现高峰负载的系统，您应该升级到极狐GitLab 17.2。

<a id="linux-package-installations"></a>

#### Linux 软件包安装

特定信息适用于 Linux 软件包安装：

- PostgreSQL 13 的二进制文件已被移除。

  在升级之前，您必须确保您的安装使用的是
  [PostgreSQL 14](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。
- 不再为 Ubuntu 18.04 构建软件包

  在尝试升级极狐GitLab 之前，请确保您的操作系统已升级到 Ubuntu 20.04 或更高版本。

<a id="non-expiring-access-tokens"></a>

#### 永不过期的访问令牌

没有到期日的访问令牌无限期有效，如果访问令牌泄露，则会带来安全风险。

当您升级到极狐GitLab 16.0 及更高版本时，任何没有到期日的[个人](../../user/profile/personal_access_tokens.md)、
[项目](../../user/project/settings/project_access_tokens.md) 或
[群组](../../user/group/settings/group_access_tokens.md) 访问令牌
将自动设置到期日为升级之日起一年后。

在应用此自动到期日之前，您应执行以下操作以最大程度地减少中断：

1. [识别任何没有到期日的访问令牌](../../security/tokens/token_troubleshooting.md#find-tokens-with-no-expiration-date)。
1. [为这些令牌设置到期日](../../security/tokens/token_troubleshooting.md#extend-token-lifetime)。

有关更多信息，请参阅：

- [弃用和移除文档](../deprecations.md#non-expiring-access-tokens)。
- 弃用议题 369122。

<a id="from-gitlab-17.0-and-earlier"></a>

### 从极狐GitLab 17.0 及更早版本升级

对于 Linux 软件包安装，在升级到极狐GitLab 17.1 或更高版本之前，您必须从 `/etc/gitlab/gitlab.rb` 中删除对[现已弃用的捆绑 Grafana](../deprecations.md#bundled-grafana-deprecated-and-disabled) 键 (`grafana[]`) 的引用。
升级后，`/etc/gitlab/gitlab.rb` 中对该键的任何引用都可能破坏功能，[例如合并请求小部件](https://support.gitlab.com/hc/en-us/articles/19677647414812-Error-after-upgrade-Unable-to-load-the-merge-request-widget)。

有关更多信息，请参阅以下议题：

- 移除 Grafana 属性和弃用消息 8200。
- 弃用 Grafana 并将其作为重大更改禁用 7772。

<a id="from-gitlab-17.1-and-earlier"></a>

### 从极狐GitLab 17.1 及更早版本升级

当您从极狐GitLab 17.1 及更早版本升级时：

- 如果您正在使用极狐GitLab Duo 并升级到极狐GitLab 17.2.3 或更早版本，则必须执行以下两项操作：
  - 重新同步您的许可证。
  - 升级后重启服务器。
- 如果您正在使用极狐GitLab Duo 并升级到极狐GitLab 17.2.4 或更高版本，则必须执行以下任一操作：
  - 重新同步您的许可证。
  - 等待下一次计划的许可证同步，该同步每 24 小时进行一次。

在您升级到极狐GitLab 17.2.4 或更高版本后，后续升级不再需要这些步骤。

有关更多信息，请参阅议题 480328。

<a id="from-gitlab-17.3"></a>

### 从极狐GitLab 17.3 升级

从极狐GitLab 17.3 升级时出现迁移失败。

从 17.3 升级到 17.4 时，有很小的几率会遇到错误。在迁移过程中，您可能会看到类似以下的错误消息：

```shell
main: == [advisory_lock_connection] object_id: 127900, pg_backend_pid: 76263
main: == 20240812040748 AddUniqueConstraintToRemoteDevelopmentAgentConfigs: migrating
main: -- transaction_open?(nil)
main:    -> 0.0000s
main: -- view_exists?(:postgres_partitions)
main:    -> 0.0181s
main: -- index_exists?(:remote_development_agent_configs, :cluster_agent_id, {:name=>"index_remote_development_agent_configs_on_unique_agent_id", :unique=>true, :algorithm=>:concurrently})
main:    -> 0.0026s
main: -- execute("SET statement_timeout TO 0")
main:    -> 0.0004s
main: -- add_index(:remote_development_agent_configs, :cluster_agent_id, {:name=>"index_remote_development_agent_configs_on_unique_agent_id", :unique=>true, :algorithm=>:concurrently})
main: -- execute("RESET statement_timeout")
main:    -> 0.0002s
main: == [advisory_lock_connection] object_id: 127900, pg_backend_pid: 76263
rake aborted!
StandardError: An error has occurred, all later migrations canceled:

PG::UniqueViolation: ERROR:  could not create unique index "index_remote_development_agent_configs_on_unique_agent_id"
DETAIL:  Key (cluster_agent_id)=(1000141) is duplicated.
```

发生此错误的原因是迁移在 `remote_development_agent_configs` 表中的 `cluster_agent_id` 列上添加了唯一约束，但仍然存在重复条目。之前的迁移应该删除这些重复项，但在极少数情况下，两个迁移之间可能会插入新的重复项。

要安全地解决此问题，请按照以下步骤操作：

1. 打开正在运行迁移的 Rails 控制台。
1. 在 Rails 控制台中运行以下脚本。
1. 重新运行迁移，它们应该会成功完成。

```ruby
# Get the IDs to keep for each cluster_agent_id; if there are duplicates, only the row with the latest updated_at will be kept.
latest_ids = ::RemoteDevelopment::RemoteDevelopmentAgentConfig.select("DISTINCT ON (cluster_agent_id) id")
  .order("cluster_agent_id, updated_at DESC")
  .map(&:id
- 极狐GitLab Runner 分布式缓存的 S3 对象存储访问现在由 AWS SDK v2 for Go 而非 MinIO 客户端处理。你可以通过将 `FF_USE_LEGACY_S3_CACHE_ADAPTER` [极狐GitLab Runner 功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/) 设置为 `true` 来重新启用 MinIO 客户端。
- Gitaly 用于向 极狐GitLab 认证的令牌现已成为自有设置。这意味着 Gitaly 不再需要 GitLab Rails 和 Shell recipes 来运行并填充 shell 目录内的默认密钥文件，而是可以拥有自己的密钥文件。某些定制环境可能需要 [更新其认证配置](../../administration/gitaly/configure_gitaly.md#configure-authentication) 以避免密钥不匹配。

## 升级到 17.4.0

- 从 极狐GitLab 17.4 开始，全新安装的 极狐GitLab 在 ID 列方面具有不同的数据库模式。
  - 所有之前的 32 位整数 ID 列（例如 `id`、`%_id`、`%_ids` 这样的列）现在均创建为 `bigint`（64 位）。
  - 现有安装将在后续版本中通过数据库迁移从 32 位整数迁移到 64 位整数。
  - 如果你正在构建一个新的 极狐GitLab 环境以测试升级，请安装 极狐GitLab 17.3 或更早版本，以获得与现有环境相同的整数类型。然后你可以升级到更高版本，以运行与现有环境相同的数据库迁移。如果你是通过从备份恢复到新环境，则无需这样做，因为数据库恢复会移除现有的数据库模式定义，并使用备份中存储的定义。
- Gitaly 需要 Git 2.46.0 及更高版本。对于自编译安装，你应该使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。
- Workhorse 中的 S3 对象存储上传现在默认使用 AWS SDK v2 for Go 处理。如果你遇到 S3 对象存储上传问题，可以通过禁用 `workhorse_use_aws_sdk_v2` [功能标志](../../administration/feature_flags/_index.md#enable-or-disable-the-feature) 降级到 v1。
- 根据 [RFC 7540](https://datatracker.ietf.org/doc/html/rfc7540#section-3.3)，Gitaly 和 Praefect 拒绝不支持 ALPN 的 TLS 连接。如果你在启用了 TLS 的 Praefect 前使用了负载均衡器，且未使用 ALPN，则可能会遇到 `FAIL: 14:connections to all backends failing` 错误。你可以通过在 Praefect 环境中设置 `GRPC_ENFORCE_ALPN_ENABLED=false` 来禁用此强制措施。对于 Linux 软件包，编辑 `/etc/gitlab/gitlab.rb`：

  ```ruby
  praefect['env'] = { 'GRPC_ENFORCE_ALPN_ENABLED' => 'false' }
  ```

  然后运行 `gitlab-ctl reconfigure`。

  ALPN 强制措施已在 [极狐GitLab 17.5.5 及其他版本](../../administration/gitaly/praefect/configure.md#alpn-enforcement) 中再次禁用。升级到这些版本之一后，无需再设置 `GRPC_ENFORCE_ALPN_ENABLED`。

## 升级到 17.3.0

- Gitaly 需要 Git 2.45.0 及更高版本。对于自编译安装，你应该使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。

### Geo 安装 17.3.0

- 即使 Geo 复制正常工作，辅助站点的 Geo 复制详情页面也可能显示为空。该问题已在 极狐GitLab 17.4 中修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.11                   | 16.11.5 - 16.11.10      | 无       |
  | 17.0                    | 所有                    | 17.0.7   |
  | 17.1                    | 所有                    | 17.1.7   |
  | 17.2                    | 所有                    | 17.2.5   |
  | 17.3                    | 所有                    | 17.3.1   |

## 升级到 17.2.1

- 升级到 极狐GitLab 17.2.1 可能因数据库中存在未知序列而失败。此问题已在 极狐GitLab 17.2.2 中修复。
- [极狐GitLab 17.2.1 的升级可能失败并报错](https://jihulab.com/gitlab-cn/gitlab/-/issues/473337)：

  ```plaintext
  PG::DependentObjectsStillExist: 错误：无法删除指定对象，因为其他对象依赖它们
  ```

  此数据库序列所有权问题已在 极狐GitLab 17.2.1 中修复。但是，如果你在 17.2.0 中的迁移未完成，而 Linux 软件包因 JSON 文件格式错误而阻止升级到 17.2.1 或更高版本，则你可能仍会遇到此问题。例如，你可能看到以下错误：

  ```plaintext
  在 /opt/gitlab/embedded/nodes/gitlab.example.com.json 找到格式错误的配置 JSON 文件。
  这通常是因为上次运行 `gitlab-ctl reconfigure` 未成功完成。
  该文件用于检查是否启用了任何不支持的配置，
  因此升级前需要成功运行 reconfigure。
  请运行 `sudo gitlab-ctl reconfigure` 修复并重试。
  ```

  当前的解决方法是：

  1. 删除 `/opt/gitlab/embedded/nodes` 中的 JSON 文件：

     ```shell
     rm /opt/gitlab/embedded/nodes/*.json
     ```

  1. 升级到 极狐GitLab 17.2.1 或更高版本。

### Geo 安装 17.2.1

- 在 极狐GitLab 16.11 到 极狐GitLab 17.2 中，缺少 PostgreSQL 索引可能导致 CPU 使用率高、作业产物验证进度缓慢以及 Geo 指标状态更新缓慢或超时。该索引已在 极狐GitLab 17.3 中添加。要手动添加索引，请参见 [Geo 故障排除 - 作业产物验证期间主节点 CPU 使用率高](../../administration/geo/replication/troubleshooting/common.md#high-cpu-usage-on-primary-during-object-verification)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.11                   | 所有                    | 无       |
  | 17.0                    | 所有                    | 17.0.7   |
  | 17.1                    | 所有                    | 17.1.7   |
  | 17.2                    | 所有                    | 17.2.5   |

- 即使 Geo 复制正常工作，辅助站点的 Geo 复制详情页面也可能显示为空。该问题已在 极狐GitLab 17.4 中修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  |16.11                   | 16.11.5 - 16.11.10      | 无       |
  |17.0                    | 所有                    | 17.0.7   |
  |17.1                    | 所有                    | 17.1.7   |
  |17.2                    | 所有                    | 17.2.5   |
  |17.3                    | 所有                    | 17.3.1   |

## 升级到 17.1.0

- 带有不受信任 `extern_uid` 的 Bitbucket 身份会被删除。更多信息，请参阅合并请求 452426。
- 默认的 [变更日志](../../user/project/changelogs.md) 模板生成的链接为完整 URL 而非 极狐GitLab 特定的引用。更多信息，请参阅合并请求 155806。
- Gitaly 需要 Git 2.44.0 及更高版本。对于自编译安装，你应该使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。
- 升级到 极狐GitLab 17.1.0 或 17.1.1，或者存在从 极狐GitLab 17.0 未完成的数据库后台迁移，可能导致运行迁移时失败。这是由某个错误所致。该问题已在 极狐GitLab 17.1.2 中修复。

### 长时间运行的流水线消息数据变更

极狐GitLab 17.1 是对于 `ci_pipeline_messages` 表中有大量记录的较大型 极狐GitLab 实例的强制停留点。

对于较大的 极狐GitLab 实例，数据变更可能需要数小时才能完成，处理速率为每小时 150 万到 200 万条记录。如果你的实例受到影响：

1. 升级到 17.1。
1. [确保所有批处理迁移已成功完成](../background_migrations.md#check-for-pending-database-background-migrations)。
1. 升级到 17.2 或 17.3。

要检查你是否受影响：

1. 启动 [数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)
1. 运行：

   ```sql
   SELECT relname as table,n_live_tup as rows FROM pg_stat_user_tables
   WHERE relname='ci_pipeline_messages' and n_live_tup>1500000;
   ```

1. 如果查询返回了 `ci_pipeline_messages` 的计数输出，则你的实例达到了此强制停留点的阈值。报告为 `0 rows` 的实例可以跳过 17.1 的升级停留。

极狐GitLab 17.1 引入了一个 [批处理后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，确保 `ci_pipeline_messages` 表中的每条记录都拥有 [正确的分区键](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/153391)。对 CI 表进行分区有望为拥有大量 CI 数据的实例带来性能提升。

升级到 极狐GitLab 17.2 会运行一个 `Finalize` 迁移，确保 17.1 的后台迁移已完成，必要时在升级期间同步执行 17.1 的变更。

极狐GitLab 17.2 还 [添加了外键数据库约束](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/158065)，要求分区键已被填充。这些约束 [会在升级到 极狐GitLab 17.3 的过程中被验证](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/159571)。

如果在升级路径中省略了 17.1（或者 17.1 的迁移未完成）：

- 受影响的实例在升级完成期间会出现更长的停机时间。
- 向前修复是安全的。
- 为使环境尽快可用，可以使用 Rake 任务来运行迁移：

  ```shell
  sudo gitlab-rake gitlab:background_migrations:finalize[BackfillPartitionIdCiPipelineMessage,ci_pipeline_messages,id,'[]']
  ```

在所有数据库迁移完成之前，极狐GitLab 很可能无法使用，并产生 `500` 错误，这是由部分升级的数据库模式与正在运行的 Sidekiq 和 Puma 进程之间的不兼容所致。

Linux 软件包（Omnibus）或 Docker 升级可能在一小时后超时失败：

```plaintext
致命错误: Mixlib::ShellOut::CommandTimeout: rails_migration[gitlab-rails]
[..]
Mixlib::ShellOut::CommandTimeout: 命令在 3600 秒后超时:
```

要解决此问题：

1. 运行前面的 Rake 任务以完成批处理迁移。
1. [完成剩余的超时操作](../package/package_troubleshooting.md#error-command-timed-out-after-3600s)。在此过程结束时，Sidekiq 和 Puma 会重新启动以修复 `500` 错误。

### Geo 安装 17.1.0

- 在 极狐GitLab 16.11 到 极狐GitLab 17.2 中，缺少 PostgreSQL 索引可能导致 CPU 使用率高、作业产物验证进度缓慢以及 Geo 指标状态更新缓慢或超时。该索引已在 极狐GitLab 17.3 中添加。要手动添加索引，请参见 [Geo 故障排除 - 作业产物验证期间主节点 CPU 使用率高](../../administration/geo/replication/troubleshooting/common.md#high-cpu-usage-on-primary-during-object-verification)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.11                   | 所有                    | 无       |
  | 17.0                    | 所有                    | 17.0.7   |
  | 17.1                    | 所有                    | 17.1.7   |
  | 17.2                    | 所有                    | 17.2.5   |

- 即使 Geo 复制正常工作，辅助站点的 Geo 复制详情页面也可能显示为空。该问题已在 极狐GitLab 17.4 中修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  |16.11                   | 16.11.5 - 16.11.10      | 无       |
  |17.0                    | 所有                    | 17.0.7   |
  |17.1                    | 所有                    | 17.1.7   |
  |17.2                    | 所有                    | 17.2.5   |
  |17.3                    | 所有                    | 17.3.1   |

## 升级到 17.0.0

### Geo 安装 17.0.0

- 在 极狐GitLab 16.11 到 极狐GitLab 17.2 中，缺少 PostgreSQL 索引可能导致 CPU 使用率高、作业产物验证进度缓慢以及 Geo 指标状态更新缓慢或超时。该索引已在 极狐GitLab 17.3 中添加。要手动添加索引，请参见 [Geo 故障排除 - 作业产物验证期间主节点 CPU 使用率高](../../administration/geo/replication/troubleshooting/common.md#high-cpu-usage-on-primary-during-object-verification)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.11                   | 所有                    | 无       |
  | 17.0                    | 所有                    | 17.0.7   |
  | 17.1                    | 所有                    | 17.1.7   |
  | 17.2                    | 所有                    | 17.2.5   |

- 即使 Geo 复制正常工作，辅助站点的 Geo 复制详情页面也可能显示为空。该问题已在 极狐GitLab 17.4 中修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  |16.11                   | 16.11.5 - 16.11.10      | 无       |
  |17.0                    | 所有                    | 17.0.7   |
  |17.1                    | 所有                    | 17.1.7   |
  |17.2                    | 所有                    | 17.2.5   |
  |17.3                    | 所有                    | 17.3.1   |

## 统一新的加密密钥

[极狐GitLab 17.8 引入了三个新密钥](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/175154) 以支持新的加密框架，[该框架于 极狐GitLab 17.9 引入](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/179559)：

- `active_record_encryption_primary_key`
- `active_record_encryption_deterministic_key`
- `active_record_encryption_key_derivation_salt`

如果你使用多节点配置，必须确保这些密钥在所有节点上都相同。否则，应用启动时会自动生成缺失的密钥。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 如果可能，[启用维护模式](../../administration/maintenance_mode/_index.md#enable-maintenance-mode)。
1. （仅适用于 极狐GitLab >= 17.9）删除所有 `CloudConnector::Keys` 记录：

   ```shell
   gitlab-rails runner 'CloudConnector::Keys.delete_all'
   ```

1. 在所有 Sidekiq 和 GitLab 应用节点上，收集加密密钥及其使用情况的信息。

   在 极狐GitLab >= 18.0.0、>= 17.11.2、>= 17.10.6 或 >= 17.9.8 上，运行：

   ```shell
   gitlab-rake gitlab:doctor:encryption_keys
   ```

   对于其他版本，你可以直接继续选择参考节点（以下列表中的“情况 1”），我们假设你还没有加密数据。

   根据命令输出，确定要遵循的流程：

   - 情况 1：如果所有 `Encryption keys usage for <model>` 报告都显示 `NONE`：
     - 选择任意一个 Sidekiq 或 GitLab 应用节点作为参考节点。
     - 将此节点的 `/etc/gitlab/gitlab-secrets.json` 复制到所有其他节点。
   - 情况 2：如果所有报告的密钥都使用相同的密钥 ID：
     - 选择密钥存在的节点作为参考节点。
     - 将此节点的 `/etc/gitlab/gitlab-secrets.json` 复制到所有其他节点。

       例如，如果节点 1 提供以下输出：

       ```shell
       Gathering existing encryption keys:
       - active_record_encryption_primary_key: ID => `bb32`; truncated secret => `bEt...eBU`
       - active_record_encryption_deterministic_key: ID => `445f`; truncated secret => `MJo...yg5`

       [... 为简洁起见省略 ...]

       Encryption keys usage for VirtualRegistries::Packages::Maven::Upstream: NONE
       Encryption keys usage for Ai::ActiveContext::Connection: NONE
       Encryption keys usage for CloudConnector::Keys: NONE
       Encryption keys usage for DependencyProxy::GroupSetting:
       - `bb32` => 8
       Encryption keys usage for Ci::PipelineScheduleInput:
       - `bb32` => 1
       ```

       而节点 2 提供以下输出（`(UNKNOWN KEY!)` 只要使用了单个密钥 ID 就没问题。例如这里是 `bb32`）：

       ```shell
       Gathering existing encryption keys:
       - active_record_encryption_primary_key: ID => `83kf`; truncated secret => `pKq...ikC`
       - active_record_encryption_deterministic_key: ID => `b722`; truncated secret => `Lma...iJ7`

       [... 为简洁起见省略 ...]

       Encryption keys usage for VirtualRegistries::Packages::Maven::Upstream: NONE
       Encryption keys usage for Ai::ActiveContext::Connection: NONE
       Encryption keys usage for CloudConnector::Keys: NONE
       Encryption keys usage for DependencyProxy::GroupSetting:
       - `bb32` (UNKNOWN KEY!) => 8
       Encryption keys usage for Ci::PipelineScheduleInput:
       - `bb32` (UNKNOWN KEY!) => 1
       ```

       在此示例中，选择节点 1 作为参考节点，因为它包含两个节点都使用的 `bb32` 密钥。
   - 情况 3：如果不同节点对相同数据使用了不同的密钥 ID（例如，节点 1 显示 `-bb32 => 1` 而节点 2 显示 `-83kf => 1`）：
     - 这需要使用单一加密密钥重新加密所有数据。
     - 或者，如果你愿意丢失一些数据，可以删除记录使所有剩余记录使用相同的密钥 ID。
     - 请联系 [极狐GitLab 支持](https://gitlab.cn/support/) 寻求帮助。

1. 在确定哪个节点为参考节点后，决定必须将参考节点的哪些密钥复制到其他节点。
1. 在除参考节点之外的所有 Sidekiq 和 Rails 节点上：

   1. 备份你的 [配置文件](https://docs.gitlab.com/omnibus/settings/backups/#backup-and-restore-configuration-on-a-linux-package-installation)：

      ```shell
      sudo gitlab-ctl backup-etc
      ```

   1. 从参考节点复制 `/etc/gitlab/gitlab-secrets.json`，并替换当前节点上的同名文件。
   1. 重新配置 极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. 根据你的版本，使用以下命令之一再次检查加密密钥及其使用情况：

      在 极狐GitLab >= 18.0.0、>= 17.11.2、>= 17.10.6 或 >= 17.9.8 上，运行：

      ```shell
      gitlab-rake gitlab:doctor:encryption_keys
      ```

      对于其他版本，你可以跳过此检查，因为我们假设你还没有加密数据。

      所有报告的密钥使用情况都应使用相同的密钥 ID。例如，在节点 1 上：

      ```shell
      Gathering existing encryption keys:
      - active_record_encryption_primary_key: ID => `bb32`; truncated secret => `bEt...eBU`
      - active_record_encryption_deterministic_key: ID => `445f`; truncated secret => `MJo...yg5`

      [... 为简洁起见省略 ...]

      Encryption keys usage for VirtualRegistries::Packages::Maven::Upstream: NONE
      Encryption keys usage for Ai::ActiveContext::Connection: NONE
      Encryption keys usage for CloudConnector::Keys:
      - `bb32` => 1
      Encryption keys usage for DependencyProxy::GroupSetting:
      - `bb32` => 8
      Encryption keys usage for Ci::PipelineScheduleInput:
      - `bb32` => 1
      ```

      例如，在节点 2 上（这次你不应看到任何 `(UNKNOWN KEY!)`）：

      ```shell
      Gathering existing encryption keys:
      - active_record_encryption_primary_key: ID => `bb32`; truncated secret => `bEt...eBU`
      - active_record_encryption_deterministic_key: ID => `445f`; truncated secret => `MJo...yg5`

      [... 为简洁起见省略 ...]

      Encryption keys usage for VirtualRegistries::Packages::Maven::Upstream: NONE
      Encryption keys usage for Ai::ActiveContext::Connection: NONE
      Encryption keys usage for CloudConnector::Keys:
      - `bb32` => 1
      Encryption keys usage for DependencyProxy::GroupSetting:
      - `bb32` => 8
      Encryption keys usage for Ci::PipelineScheduleInput:
      - `bb32` => 1
      ```

1. 创建新的 Cloud Connector 密钥：

   对于 极狐GitLab >= 17.10：

   ```shell
   gitlab-rake cloud_connector:keys:create
   ```

   对于 极狐GitLab 17.9：

   ```shell
   gitlab-rails runner 'CloudConnector::Keys.create!(secret_key: OpenSSL::PKey::RSA.new(2048).to_pem)'
   ```

1. [禁用维护模式](../../administration/maintenance_mode/_index.md#disable-maintenance-mode)。

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

如果你禁用了 [共享密钥 chart](https://gitlab.cn/docs/charts/charts/shared-secrets/)，则需要 [手动创建这些密钥](https://gitlab.cn/docs/charts/releases/8_0/)。

{{< /tab >}}

{{< /tabs >}}