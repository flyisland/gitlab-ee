---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 备份故障排查
---

当你备份极狐GitLab 时，可能会遇到以下问题。

<a id="when-the-secrets-file-is-lost"></a>

## 密钥文件丢失

如果你没有[备份密钥文件](backup_gitlab.md#storing-configuration-files)，你必须完成几个步骤，才能使极狐GitLab 重新正常工作。

密钥文件负责存储包含必需敏感信息的列的加密密钥。如果密钥丢失，极狐GitLab 无法解密这些列，从而阻止访问以下内容：

- [CI/CD 变量](../../ci/variables/_index.md)
- [Kubernetes / GCP 集成](../../user/infrastructure/clusters/_index.md)
- [自定义 Pages 域名](../../user/project/pages/custom_domains_ssl_tls_certification/_index.md)
- [项目错误跟踪](../../operations/error_tracking.md)
- [Runner 认证](../../ci/runners/_index.md)
- [项目镜像](../../user/project/repository/mirror/_index.md)
- [集成](../../user/project/integrations/_index.md)
- [Webhooks](../../user/project/integrations/webhooks.md)
- [部署令牌](../../user/project/deploy_tokens/_index.md)

对于像 CI/CD 变量和 Runner 认证这样的情况，你可能会遇到意外行为，例如：

- 卡住的作业。
- 500 错误。

在这种情况下，你必须为 CI/CD 变量和 Runner 认证重置所有令牌，以下各节将对此进行详细说明。重置令牌后，你应该可以访问项目，并且作业将重新开始运行。

> [!warning]
> 本节中的步骤可能会导致前面列出的项目数据丢失。
> 如果你是专业版或旗舰版客户，考虑提交一个[支持请求](https://support.jihulab.com/hc/en-us/requests/new)。

<a id="verify-that-all-values-can-be-decrypted"></a>

### 验证所有值均可解密

你可以使用 [Rake 任务](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)来确定数据库中是否存在无法解密的值。

<a id="take-a-backup"></a>

### 进行备份

你必须直接修改极狐GitLab 数据，以解决密钥文件丢失问题。

> [!warning]
> 在进行任何更改之前，请务必创建完整的数据库备份。

<a id="disable-user-two-factor-authentication-2fa"></a>

### 禁用用户双重身份验证（2FA）

启用了 2FA 的用户无法登录极狐GitLab。在这种情况下，你必须[为所有人禁用 2FA](../../security/two_factor_authentication.md#for-all-users)，之后用户必须重新激活 2FA。

<a id="reset-cicd-variables"></a>

### 重置 CI/CD 变量

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译的安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 检查 `ci_group_variables` 和 `ci_variables` 表：

   ```sql
   SELECT * FROM public."ci_group_variables";
   SELECT * FROM public."ci_variables";
   ```

   这些是你需要删除的变量。

1. 删除所有变量：

   ```sql
   DELETE FROM ci_group_variables;
   DELETE FROM ci_variables;
   ```

1. 如果你知道要从哪个特定群组或项目中删除变量，可以在 `DELETE` 中包含 `WHERE` 语句来指定：

   ```sql
   DELETE FROM ci_group_variables WHERE group_id = <GROUPID>;
   DELETE FROM ci_variables WHERE project_id = <PROJECTID>;
   ```

你可能需要重新配置或重启极狐GitLab，以使更改生效。

<a id="reset-runner-registration-tokens"></a>

### 重置 Runner 注册令牌

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译的安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 清除项目、群组和整个实例的所有令牌：

   > [!warning]
   > 最后的 `UPDATE` 操作将阻止 runner 接收新作业。你必须注册新的 runner。

   ```sql
   -- 清除项目令牌
   UPDATE projects SET runners_token = null, runners_token_encrypted = null;
   -- 清除群组令牌
   UPDATE namespaces SET runners_token = null, runners_token_encrypted = null;
   -- 清除实例令牌
   UPDATE application_settings SET runners_registration_token_encrypted = null;
   -- 清除用于 JWT 认证的密钥
   -- 这可能会破坏 $CI_JWT_TOKEN 作业变量：
   -- https://gitlab.com/gitlab-org/gitlab/-/issues/325965
   UPDATE application_settings SET encrypted_ci_jwt_signing_key = null;
   -- 清除 runner 令牌
   UPDATE ci_runners SET token = null, token_encrypted = null;
   ```

<a id="reset-pending-pipeline-jobs"></a>

### 重置待处理的流水线作业

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译的安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 清除所有待处理作业的令牌：

   ```sql
   -- 清除构建令牌
   UPDATE ci_builds SET token_encrypted = null;
   ```

对于其他功能，可以采用类似的策略。通过删除无法解密的数据，极狐GitLab 可以恢复运行，丢失的数据可以手动替换。

<a id="fix-integrations-and-webhooks"></a>

### 修复集成和 Webhooks

如果你丢失了密钥，[集成设置](../../user/project/integrations/_index.md)和 [Webhooks 设置](../../user/project/integrations/webhooks.md)页面可能会显示 `500` 错误消息。当你尝试访问之前配置了集成或 Webhook 的项目仓库时，丢失的密钥也可能产生 `500` 错误。

修复方法是清空受影响的表（包含加密列的表）。这将删除所有已配置的集成、Webhook 以及相关元数据。在删除任何数据之前，你应该确认密钥是根本原因。

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译的安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 清空以下表：

   ```sql
   -- 清空 web_hooks 表
   TRUNCATE integrations, chat_names, issue_tracker_data, jira_tracker_data, slack_integrations, web_hooks, zentao_tracker_data, web_hook_logs CASCADE;
   ```

<a id="container-registry-is-not-restored"></a>

## 容器镜像仓库未恢复

如果你从使用[容器镜像仓库](../../user/packages/container_registry/_index.md)的环境恢复备份到一个未启用容器镜像仓库的新安装环境，则容器镜像仓库不会被恢复。

要同时恢复容器镜像仓库，你需要在恢复备份之前在新环境中[启用它](../packages/container_registry.md#enable-the-container-registry)。

<a id="container-registry-push-failures-after-restoring-from-a-backup"></a>

## 从备份恢复后容器镜像仓库推送失败

如果你使用[容器镜像仓库](../../user/packages/container_registry/_index.md)，在 Linux 软件包（Omnibus）实例上恢复备份并恢复仓库数据后，推送到镜像仓库可能会失败。

这些故障在仓库日志中显示权限问题，类似于：

```plaintext
level=error
msg="response completed with error"
err.code=unknown
err.detail="filesystem: mkdir /var/opt/gitlab/gitlab-rails/shared/registry/docker/registry/v2/repositories/...: permission denied"
err.message="unknown error"
```

此问题是由于还原过程以非特权用户 `git` 运行，导致在还原过程中无法为仓库文件分配正确的所有权所致（[议题 #62759](https://jihulab.com/gitlab-cn/gitlab-foss/-/issues/62759 "Incorrect permissions on registry filesystem after restore")）。

要使你的仓库重新工作：

```shell
sudo chown -R registry:registry /var/opt/gitlab/gitlab-rails/shared/registry/docker
```

如果你更改了仓库的默认文件系统位置，请对你的自定义位置运行 `chown`，而不是 `/var/opt/gitlab/gitlab-rails/shared/registry/docker`。

<a id="backup-fails-to-complete-with-gzip-error"></a>

## 备份因 Gzip 错误而无法完成

运行备份时，你可能会收到 Gzip 错误消息：

```shell
sudo /opt/gitlab/bin/gitlab-backup create
...
Dumping ...
...
gzip: stdout: Input/output error

Backup failed
```

如果发生这种情况，请检查以下内容：

- 确认 Gzip 操作有足够的磁盘空间。使用[默认策略](backup_gitlab.md#backup-strategy-option)的备份在创建过程中通常需要相当于实例大小一半的可用磁盘空间。
- 如果使用 NFS，检查挂载选项 `timeout` 是否已设置。默认值为 `600`，将此值更改为较小的值会导致此错误。

<a id="backup-fails-with-file-name-too-long-error"></a>

## 备份因“文件名过长”错误而失败

备份期间，你可能会收到“文件名过长”错误（[议题 #354984](https://jihulab.com/gitlab-cn/gitlab/-/issues/354984)）。例如：

```plaintext
Problem: <class 'OSError: [Errno 36] File name too long:
```

此问题导致备份脚本无法完成。要解决此问题，你必须截断导致问题的文件名。允许的最大长度（包括文件扩展名）为 246 个字符。

> [!warning]
> 本节中的步骤可能会导致数据丢失。所有步骤必须严格按照给定的顺序执行。
> 如果你是专业版或旗舰版客户，考虑提交一个[支持请求](https://support.jihulab.com/hc/en-us/requests/new)。

通过截断文件名来解决此错误，包括：

- 清理不在数据库中跟踪的远程上传文件。
- 截断数据库中引用的文件名。
- 重新运行备份任务。

<a id="clean-up-remote-uploaded-files"></a>

### 清理远程上传的文件

一个[已知议题](https://jihulab.com/gitlab-cn/gitlab-foss/-/issues/45425)导致在父资源被删除后，对象存储上传仍然存在。此问题[已解决](https://jihulab.com/gitlab-cn/gitlab-foss/-/merge_requests/18698)。

要修复这些文件，你必须清理存储在存储中但未在 `uploads` 数据库表中跟踪的所有远程上传文件。

1. 列出所有可以移动到“失物招领”目录的对象存储上传文件（如果它们在极狐GitLab 数据库中不存在）：

   ```shell
   bundle exec rake gitlab:cleanup:remote_upload_files RAILS_ENV=production
   ```

1. 如果你确定要删除这些文件并移除所有未引用的上传文件，请运行：

   > [!warning]
   > 以下操作不可逆。

   ```shell
   bundle exec rake gitlab:cleanup:remote_upload_files RAILS_ENV=production DRY_RUN=false
   ```

<a id="truncate-the-filenames-referenced-by-the-database"></a>

### 截断数据库引用的文件名

你必须截断数据库中引用的导致问题的文件。数据库引用的文件名存储在：

- `uploads` 表中。
- 找到的引用中。任何从其他数据库表和列中找到的引用。
- 文件系统中。

截断 `uploads` 表中的文件名：

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译的安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 在 `uploads` 表中搜索长度超过 246 个字符的文件名：

   以下查询以 0 到 10000 的批次选择 `uploads` 中文件名长度超过 246 个字符的记录。这可以提高拥有数千条记录的大实例的性能。

   ```sql
   CREATE TEMP TABLE uploads_with_long_filenames AS
   SELECT ROW_NUMBER() OVER(ORDER BY id) row_id, id, path
   FROM uploads AS u
   WHERE LENGTH((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1]) > 246;

   CREATE INDEX ON uploads_with_long_filenames(row_id);

   SELECT
      u.id,
      u.path,
      -- 当前文件名
      (regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1] AS current_filename,
      -- 新文件名
      CONCAT(
         LEFT(SPLIT_PART((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1], '.', 1), 242),
         COALESCE(SUBSTRING((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1] FROM '\.(?:.(?!\.))+$'))
      ) AS new_filename,
      -- 新路径
      CONCAT(
         COALESCE((regexp_match(u.path, '(.*\/).*'))[1], ''),
         CONCAT(
            LEFT(SPLIT_PART((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1], '.', 1), 242),
            COALESCE(SUBSTRING((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1] FROM '\.(?:.(?!\.))+$'))
         )
      ) AS new_path
   FROM uploads_with_long_filenames AS u
   WHERE u.row_id > 0 AND u.row_id <= 10000;
   ```

   输出示例：

   ```postgresql
   -[ RECORD 1 ]----+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   id               | 34
   path             | public/@hashed/loremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelitsedvulputatemisitloremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelitsedvulputatemisit.txt
   current_filename | loremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelitsedvulputatemisitloremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelitsedvulputatemisit.txt
   new_filename     | loremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelitsedvulputatemisitloremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelits.txt
   new_path         | public/@hashed/loremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelitsedvulputatemisitloremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliquaauctorelits.txt
   ```

   其中：

   - `current_filename`：长度超过 246 个字符的文件名。
   - `new_filename`：已截断为最多 246 个字符的文件名。
   - `new_path`：考虑 `new_filename`（已截断）的新路径。

   在验证批次结果后，你必须使用以下数字序列（10000 到 20000）更改批次大小（`row_id`）。重复此过程，直到达到 `uploads` 表的最后一条记录。

1. 将 `uploads` 表中找到的文件名从长文件名重命名为新的截断文件名。以下查询会在事务包装器中回滚更新，以便你可以安全地检查结果：

   ```sql
   CREATE TEMP TABLE uploads_with_long_filenames AS
   SELECT ROW_NUMBER() OVER(ORDER BY id) row_id, path, id
   FROM uploads AS u
   WHERE LENGTH((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1]) > 246;

   CREATE INDEX ON uploads_with_long_filenames(row_id);

   BEGIN;
   WITH updated_uploads AS (
      UPDATE uploads
      SET
         path =
         CONCAT(
            COALESCE((regexp_match(updatable_uploads.path, '(.*\/).*'))[1], ''),
            CONCAT(
               LEFT(SPLIT_PART((regexp_match(updatable_uploads.path, '[^\\/:*?"<>|\r\n]+$'))[1], '.', 1), 242),
               COALESCE(SUBSTRING((regexp_match(updatable_uploads.path, '[^\\/:*?"<>|\r\n]+$'))[1] FROM '\.(?:.(?!\.))+$'))
            )
         )
      FROM
         uploads_with_long_filenames AS updatable_uploads
      WHERE
         uploads.id = updatable_uploads.id
      AND updatable_uploads.row_id > 0 AND updatable_uploads.row_id  <= 10000
      RETURNING uploads.*
   )
   SELECT id, path FROM updated_uploads;
   ROLLBACK;
   ```

   在验证批次更新结果后，你必须使用以下数字序列（10000 到 20000）更改批次大小（`row_id`）。重复此过程，直到达到 `uploads` 表的最后一条记录。

1. 验证上一步查询的新文件名是否符合预期。如果你确定要将上一步中找到的记录截断为 246 个字符，请运行以下命令：

   > [!warning]
   > 以下操作不可逆。

   ```sql
   CREATE TEMP TABLE uploads_with_long_filenames AS
   SELECT ROW_NUMBER() OVER(ORDER BY id) row_id, path, id
   FROM uploads AS u
   WHERE LENGTH((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1]) > 246;

   CREATE INDEX ON uploads_with_long_filenames(row_id);

   UPDATE uploads
   SET
   path =
      CONCAT(
         COALESCE((regexp_match(updatable_uploads.path, '(.*\/).*'))[1], ''),
         CONCAT(
            LEFT(SPLIT_PART((regexp_match(updatable_uploads.path, '[^\\/:*?"<>|\r\n]+$'))[1], '.', 1), 242),
            COALESCE(SUBSTRING((regexp_match(updatable_uploads.path, '[^\\/:*?"<>|\r\n]+$'))[1] FROM '\.(?:.(?!\.))+$'))
         )
      )
   FROM
   uploads_with_long_filenames AS updatable_uploads
   WHERE
   uploads.id = updatable_uploads.id
   AND updatable_uploads.row_id > 0 AND updatable_uploads.row_id  <= 10000;
   ```

   完成批次更新后，你必须使用以下数字序列（10000 到 20000）更改批次大小（`updatable_uploads.row_id`）。重复此过程，直到达到 `uploads` 表的最后一条记录。

截断找到的引用中的文件名：

1. 检查这些记录是否在别处被引用。一种方法是转储数据库并搜索父目录名和文件名：

   1. 要转储你的数据库，你可以使用以下命令作为示例：

      ```shell
      pg_dump -h /var/opt/gitlab/postgresql/ -d gitlabhq_production > gitlab-dump.tmp
      ```

   1. 然后你可以使用 `grep` 命令搜索引用。将父目录和文件名结合起来搜索可能是个好主意。例如：

      ```shell
      grep public/alongfilenamehere.txt gitlab-dump.tmp
      ```

1. 使用从查询 `uploads` 表中获得的新文件名替换那些长文件名。

截断文件系统中的文件名。你必须手动将文件系统中的文件重命名为从查询 `uploads` 表中获得的新文件名。

<a id="re-run-the-backup-task"></a>

### 重新运行备份任务

按照上述所有步骤操作后，重新运行备份任务。

<a id="restoring-database-backup-fails-when-pg_stat_statements-was-previously-enabled"></a>

## 当 `pg_stat_statements` 之前已启用时恢复数据库备份失败

极狐GitLab 的 PostgreSQL 数据库备份包括所有启用之前已在数据库中启用的扩展所需的 SQL 语句。

`pg_stat_statements` 扩展只能由具有 `superuser` 角色的 PostgreSQL 用户启用或禁用。
由于恢复过程使用权限受限的数据库用户，因此无法执行以下 SQL 语句：

```sql
DROP EXTENSION IF EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;
```

当尝试在没有 `pg_stats_statements` 扩展的 PostgreSQL 实例中恢复备份时，会显示以下错误消息：

```plaintext
ERROR: permission denied to create extension "pg_stat_statements"
HINT: Must be superuser to create this extension.
ERROR: extension "pg_stat_statements" does not exist
```

当尝试在已启用 `pg_stats_statements` 扩展的实例中恢复时，清理步骤会失败，并显示类似以下的错误消息：

```plaintext
rake aborted!
ActiveRecord::StatementInvalid: PG::InsufficientPrivilege: ERROR: must be owner of view pg_stat_statements
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:42:in `block (4 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:41:in `each'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:41:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/backup.rake:71:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
Caused by:
PG::InsufficientPrivilege: ERROR: must be owner of view pg_stat_statements
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:42:in `block (4 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:41:in `each'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:41:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/backup.rake:71:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
Tasks: TOP => gitlab:db:drop_tables
(See full trace by running task with --trace)
```

<a id="prevent-the-dump-file-to-include-pg_stat_statements"></a>

### 防止转储文件包含 `pg_stat_statements`

要防止将扩展包含在备份包的 PostgreSQL 转储文件中，请在除 `public` 模式之外的任何模式中启用该扩展：

```sql
CREATE SCHEMA adm;
CREATE EXTENSION pg_stat_statements SCHEMA adm;
```

如果扩展先前已在 `public` 模式中启用，请将其移至新模式：

```sql
CREATE SCHEMA adm;
ALTER EXTENSION pg_stat_statements SET SCHEMA adm;
```

更改模式后，要查询 `pg_stat_statements` 数据，请使用新模式作为前缀：

```sql
SELECT * FROM adm.pg_stat_statements limit 0;
```

为了使其与期望它在 `public` 模式中启用的第三方监控解决方案兼容，你需要将其包含在 `search_path` 中：

```sql
set search_path to public,adm;
```

<a id="fix-an-existing-dump-file-to-remove-references-to-pg_stat_statements"></a>

### 修复现有转储文件以移除对 `pg_stat_statements` 的引用

要修复现有的备份文件，请进行以下更改：

1. 从备份中解压出以下文件：`db/database.sql.gz`。
1. 解压缩该文件，或使用能够处理压缩文件的编辑器。
1. 删除以下行或类似行：

   ```sql
   CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;
   ```

   ```sql
   COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';
   ```

1. 保存更改并重新压缩文件。
1. 使用修改后的 `db/database.sql.gz` 更新备份文件。