---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 备份故障排除
---

备份极狐GitLab 时，您可能会遇到以下问题。

<a id="when-the-secrets-file-is-lost"></a>

## 当密钥文件丢失时

如果您没有[备份密钥文件](backup_gitlab.md#storing-configuration-files)，则必须完成几个步骤，才能让极狐GitLab 重新正常工作。

密钥文件负责存储包含必需敏感信息的列的加密密钥。如果密钥丢失，极狐GitLab 将无法解密这些列，从而阻止访问以下条目：

- [CI/CD 变量](../../ci/variables/_index.md)
- [Kubernetes / GCP 集成](../../user/infrastructure/clusters/_index.md)
- [自定义 Pages 域名](../../user/project/pages/custom_domains_ssl_tls_certification/_index.md)
- [项目错误追踪](../../operations/error_tracking.md)
- [Runner 认证](../../ci/runners/_index.md)
- [项目镜像](../../user/project/repository/mirror/_index.md)
- [集成](../../user/project/integrations/_index.md)
- [Webhooks](../../user/project/integrations/webhooks.md)
- [部署令牌](../../user/project/deploy_tokens/_index.md)

对于 CI/CD 变量和 Runner 认证等情况，您可能会遇到意外行为，例如：

- 作业卡住。
- 500 错误。

在这种情况下，您必须重置 CI/CD 变量和 Runner 认证的所有令牌，后续章节将更详细地介绍这一点。重置令牌后，您应该能够访问您的项目，作业也会重新开始运行。

> [!warning]
> 本节中的步骤可能会导致前面列出的条目发生数据丢失。
> 如果您是专业版或旗舰版客户，请考虑提交[支持请求](https://gitlab.cn/support)。

<a id="verify-that-all-values-can-be-decrypted"></a>

### 验证所有值均可解密

您可以使用 [Rake 任务](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)来确定数据库中是否包含无法解密的值。

<a id="take-a-backup"></a>

### 进行备份

您必须直接修改极狐GitLab 数据，以应对密钥文件丢失的情况。

> [!warning]
> 在尝试任何更改之前，请务必创建完整的数据库备份。

<a id="disable-user-two-factor-authentication-2fa"></a>

### 禁用用户双重身份验证（2FA）

启用了 2FA 的用户无法登录极狐GitLab。在这种情况下，您必须[为所有人禁用 2FA](../../security/two_factor_authentication.md#for-all-users)，之后用户必须重新激活 2FA。

<a id="reset-cicd-variables"></a>

### 重置 CI/CD 变量

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 检查 `ci_group_variables` 和 `ci_variables` 表：

   ```sql
   SELECT * FROM public."ci_group_variables";
   SELECT * FROM public."ci_variables";
   ```

   这些就是您需要删除的变量。

1. 删除所有变量：

   ```sql
   DELETE FROM ci_group_variables;
   DELETE FROM ci_variables;
   ```

1. 如果您知道要从中删除变量的特定群组或项目，可以在 `DELETE`中包含 `WHERE` 语句来指定：

   ```sql
   DELETE FROM ci_group_variables WHERE group_id = <GROUPID>;
   DELETE FROM ci_variables WHERE project_id = <PROJECTID>;
   ```

您可能需要重新配置或重启极狐GitLab，更改才会生效。

<a id="reset-runner-registration-tokens"></a>

### 重置 Runner 注册令牌

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 清除项目、群组和整个实例的所有令牌：

   > [!warning]
   > 最后的 `UPDATE` 操作会阻止 Runner 获取新作业。您必须注册新的 Runner。

   ```sql
   -- Clear project tokens
   UPDATE projects SET runners_token = null, runners_token_encrypted = null;
   -- Clear group tokens
   UPDATE namespaces SET runners_token = null, runners_token_encrypted = null;
   -- Clear instance tokens
   UPDATE application_settings SET runners_registration_token_encrypted = null;
   -- Clear key used for JWT authentication
   -- This may break the $CI_JWT_TOKEN job variable:
   -- https://gitlab.com/gitlab-org/gitlab/-/issues/325965
   UPDATE application_settings SET encrypted_ci_jwt_signing_key = null;
   -- Clear runner tokens
   UPDATE ci_runners SET token = null, token_encrypted = null;
   ```

<a id="reset-pending-pipeline-jobs"></a>

### 重置待处理的流水线作业

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 清除待处理作业的所有令牌：

   ```sql
   -- Clear build tokens
   UPDATE ci_builds SET token_encrypted = null;
   ```

对于其余功能，可以采用类似的策略。通过删除无法解密的数据，极狐GitLab 可以恢复运行，丢失的数据可以手动替换。

<a id="fix-integrations-and-webhooks"></a>

### 修复集成和 Webhooks

如果您丢失了密钥，[集成设置](../../user/project/integrations/_index.md)和 [Webhooks 设置](../../user/project/integrations/webhooks.md)页面可能会显示 `500` 错误消息。当您尝试在之前配置过集成或 Webhook 的项目中访问代码仓库时，丢失的密钥也可能会产生 `500` 错误。

修复方法是清空受影响的表（包含加密列的表）。这会删除您所有已配置的集成、Webhook 及相关元数据。在删除任何数据之前，您应该确认密钥是根本原因。

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 清空以下表：

   ```sql
   -- truncate web_hooks table
   TRUNCATE integrations, chat_names, issue_tracker_data, jira_tracker_data, slack_integrations, web_hooks, zentao_tracker_data, web_hook_logs CASCADE;
   ```

<a id="container-registry-is-not-restored"></a>

## 容器镜像仓库未恢复

如果您从使用[容器镜像仓库](../../user/packages/container_registry/_index.md)的环境恢复备份到未启用容器镜像仓库的新安装环境，则容器镜像仓库不会被恢复。

要同时恢复容器镜像仓库，您需要在恢复备份之前在新环境中[启用它](../packages/container_registry.md#enable-the-container-registry)。

<a id="container-registry-push-failures-after-restoring-from-a-backup"></a>

## 从备份恢复后容器镜像仓库推送失败

如果您使用[容器镜像仓库](../../user/packages/container_registry/_index.md)，在 Linux 软件包（Omnibus）实例上恢复备份并恢复镜像仓库数据后，推送到镜像仓库可能会失败。

这些失败会在镜像仓库日志中提及权限问题，类似于：

```plaintext
level=error
msg="response completed with error"
err.code=unknown
err.detail="filesystem: mkdir /var/opt/gitlab/gitlab-rails/shared/registry/docker/registry/v2/repositories/...: permission denied"
err.message="unknown error"
```

此问题是由于恢复过程以非特权用户 `git` 运行，该用户在恢复过程中无法为镜像仓库文件分配正确的所有权（[议题 #62759](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/62759 "Incorrect permissions on registry filesystem after restore")）。

要让您的镜像仓库重新正常工作：

```shell
sudo chown -R registry:registry /var/opt/gitlab/gitlab-rails/shared/registry/docker
```

如果您更改了镜像仓库的默认文件系统位置，请对您的自定义位置运行 `chown`，而不是对 `/var/opt/gitlab/gitlab-rails/shared/registry/docker` 运行。

<a id="backup-fails-to-complete-with-gzip-error"></a>

## 备份因 Gzip 错误而无法完成

运行备份时，您可能会收到 Gzip 错误消息：

```shell
sudo /opt/gitlab/bin/gitlab-backup create
...
Dumping ...
...
gzip: stdout: Input/output error

Backup failed
```

如果发生这种情况，请检查以下内容：

- 确认有足够的磁盘空间用于 Gzip 操作。使用[默认策略](backup_gitlab.md#backup-strategy-option)的备份在创建备份期间需要相当于实例大小一半的可用磁盘空间，这并不罕见。
- 如果正在使用 NFS，请检查是否设置了挂载选项 `timeout`。默认值为 `600`，将其更改为较小的值会导致此错误。

<a id="backup-fails-with-file-name-too-long-error"></a>

## 备份失败并出现 `File name too long` 错误

备份期间，您可能会遇到 `File name too long` 错误（[议题 #354984](https://gitlab.com/gitlab-org/gitlab/-/issues/354984)）。例如：

```plaintext
Problem: <class 'OSError: [Errno 36] File name too long:
```

此问题会阻止备份脚本完成。要解决此问题，您必须截断导致问题的文件名。最多允许 246 个字符，包括文件扩展名。

> [!warning]
> 本节中的步骤可能会导致数据丢失。必须严格按照给定的顺序执行所有步骤。
> 如果您是专业版或旗舰版客户，请考虑提交[支持请求](https://gitlab.cn/support)。

截断文件名以解决错误涉及：

- 清理数据库中未跟踪的远程上传文件。
- 截断数据库中的文件名。
- 重新运行备份任务。

<a id="clean-up-remote-uploaded-files"></a>

### 清理远程上传文件

一个[已知问题](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/45425)导致父资源被删除后，对象存储上传仍然保留。此问题已[解决](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/18698)。

要修复这些文件，您必须清理所有存储在存储中但未在 `uploads` 数据库表中跟踪的远程上传文件。

1. 列出所有可以移动到失物招领目录的对象存储上传文件（如果它们不存在于极狐GitLab 数据库中）：

   ```shell
   bundle exec rake gitlab:cleanup:remote_upload_files RAILS_ENV=production
   ```

1. 如果您确定要删除这些文件并移除所有未被引用的上传文件，请运行：

   > [!warning]
   > 以下操作不可逆。

   ```shell
   bundle exec rake gitlab:cleanup:remote_upload_files RAILS_ENV=production DRY_RUN=false
   ```

<a id="truncate-the-filenames-referenced-by-the-database"></a>

### 截断数据库引用的文件名

您必须截断数据库中引用的导致问题的文件。数据库引用的文件名存储在：

- `uploads` 表中。
- 找到的引用中。从其他数据库表和列中找到的任何引用。
- 文件系统上。

截断 `uploads` 表中的文件名：

1. 进入数据库控制台：

   对于 Linux 软件包（Omnibus）：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   对于自行编译安装：

   ```shell
   sudo -u git -H bundle exec rails dbconsole -e production --database main
   ```

1. 在 `uploads` 表中搜索长度超过 246 个字符的文件名：

   以下查询以 0 到 10000 的批次选择文件名长度超过 246 个字符的 `uploads` 记录。这可以提高具有数千条记录的表的大型极狐GitLab 实例的性能。

   ```sql
   CREATE TEMP TABLE uploads_with_long_filenames AS
   SELECT ROW_NUMBER() OVER(ORDER BY id) row_id, id, path
   FROM uploads AS u
   WHERE LENGTH((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1]) > 246;

   CREATE INDEX ON uploads_with_long_filenames(row_id);

   SELECT
      u.id,
      u.path,
      -- Current filename
      (regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1] AS current_filename,
      -- New filename
      CONCAT(
         LEFT(SPLIT_PART((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1], '.', 1), 242),
         COALESCE(SUBSTRING((regexp_match(u.path, '[^\\/:*?"<>|\r\n]+$'))[1] FROM '\.(?:.(?!\.))+$'))
      ) AS new_filename,
      -- New path
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
   - `new_path`：考虑 `new_filename`（截断后）的新路径。

   验证批次结果后，您必须使用以下数字序列（10000 到 20000）更改批次大小（`row_id`）。重复此过程，直到到达 `uploads` 表中的最后一条记录。

1. 将 `uploads` 表中找到的文件从长文件名重命名为新的截断文件名。以下查询会回滚更新，以便您可以在事务包装器中安全地检查结果：

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

   验证批量更新结果后，您必须使用以下数字序列（10000 到 20000）更改批次大小（`row_id`）。重复此过程，直到到达 `uploads` 表中的最后一条记录。

1. 验证上一条查询得到的新文件名是否符合预期。如果您确定要将上一步中找到的记录截断为 246 个字符，请运行以下命令：

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

   完成批量更新后，您必须使用以下数字序列（10000 到 20000）更改批次大小（`updatable_uploads.row_id`）。重复此过程，直到到达 `uploads` 表中的最后一条记录。

截断找到的引用中的文件名：

1. 检查这些记录是否在某处被引用。一种方法是转储数据库并搜索父目录名和文件名：

   1. 要转储数据库，您可以使用以下命令作为示例：

      ```shell
      pg_dump -h /var/opt/gitlab/postgresql/ -d gitlabhq_production > gitlab-dump.tmp
      ```

   1. 然后您可以使用 `grep` 命令搜索引用。将父目录和文件名组合起来可能是个好主意。例如：

      ```shell
      grep public/alongfilenamehere.txt gitlab-dump.tmp
      ```

1. 使用从查询 `uploads` 表获得的新文件名替换那些长文件名。

截断文件系统上的文件名。您必须手动将文件系统中的文件重命名为从查询 `uploads` 表获得的新文件名。

<a id="re-run-the-backup-task"></a>

### 重新运行备份任务

按照上述所有步骤操作后，重新运行备份任务。

<a id="error-pack-objects-died-during-server-side-backup-of-a-large-repository"></a>

## 大型代码仓库的服务器端备份期间出现错误：`pack-objects died`

当您运行服务器端备份（使用 `REPOSITORIES_SERVER_SIDE=true`）时，如果一个或多个大型代码仓库持续失败，您可能会看到此错误：

```plaintext
backup repository: manager: write bundle: local repository: create bundle:
create bundle: exit status 1: stderr: "error: pack-objects died"
```

即使在以下情况下，您也可能会看到此错误：

- 同一项目的较小代码仓库和 Wiki 代码仓库备份成功。
- 在 Gitaly 节点上手动运行 `git fsck --full` 和 `git bundle create` 时均无错误通过。

出现此问题是因为 Gitaly 使用分段上传将代码仓库包直接流式传输到对象存储。

默认情况下，分段大小为 5 MB，而 AWS S3（及兼容提供商）每次分段上传最多允许 10,000 个分段。

此默认值给出的有效最大包大小约为 50 GB。当代码仓库的包超过此限制时，对象存储提供商会中止上传。中止会破坏传回 `git pack-objects`的管道，从而报告具有误导性的 `pack-objects died` 错误，而不是上传失败。

要解决此问题，请在 Gitaly 备份配置中增大 `buffer_size`。由于有效最大包大小为 `buffer_size × 10,000`，请将 `buffer_size` 设置为能够容纳您最大代码仓库的值。

1. 要识别 Gitaly 节点上最大的 packfile：

   ```shell
   sudo find /var/opt/gitlab/git-data -name "*.pack" -size +10G -ls
   ```

1. 设置 `buffer_size`。

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   1. 在每个 Gitaly 节点上编辑 `/etc/gitlab/gitlab.rb`，并将 `buffer_size` 添加到您现有的备份配置中：

      ```ruby
      gitaly['configuration'] = {
        backup: {
          go_cloud_url: 's3://<bucket>?region=<region>',
          # Increase part size to raise the S3 multipart upload limit.
          # buffer_size (bytes) x 10,000 = effective maximum bundle size.
          # Example: 10485760 (10 MB) supports bundles up to ~100 GB.
          buffer_size: 10485760,
        },
      }
      ```

   1. 在每个节点上重新配置并重启 Gitaly：

      ```shell
      sudo gitlab-ctl reconfigure
      sudo gitlab-ctl restart gitaly
      ```

   {{< /tab >}}

   {{< tab title="Helm chart（Kubernetes）" >}}

   1. 导出 Helm values：

      ```shell
      helm get values gitlab > gitlab_values.yaml
      ```

   1. 编辑 `gitlab_values.yaml` 并设置所需的值：

      ```yaml
      gitlab:
        gitaly:
          configuration:
            backup:
              buffer_size: 10485760
      ```

   1. 保存文件并应用新值：

      ```shell
      helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
      ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="restoring-database-backup-fails-when-pg_stat_statements-was-previously-enabled"></a>

## 之前启用过 `pg_stat_statements` 时恢复数据库备份失败

极狐GitLab 的 PostgreSQL 数据库备份包含启用数据库中之前已启用的扩展所需的所有 SQL 语句。

`pg_stat_statements` 扩展只能由具有 `superuser` 角色的 PostgreSQL 用户启用或禁用。由于恢复过程使用权限有限的数据库用户，因此无法执行以下 SQL 语句：

```sql
DROP EXTENSION IF EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;
```

当尝试在没有 `pg_stat_statements` 扩展的 PostgreSQL 实例中恢复备份时，会显示以下错误消息：

```plaintext
ERROR: permission denied to create extension "pg_stat_statements"
HINT: Must be superuser to create this extension.
ERROR: extension "pg_stat_statements" does not exist
```

当尝试在已启用 `pg_stat_statements` 扩展的实例中恢复时，清理步骤会失败，并显示类似于以下的错误消息：

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

<a id="prevent-the-dump-file-from-including-pg_stat_statements"></a>

### 防止转储文件包含 `pg_stat_statements`

要防止该扩展包含在作为备份包一部分的 PostgreSQL 转储文件中，请在除 `public` schema 之外的任何 schema 中启用该扩展：

```sql
CREATE SCHEMA adm;
CREATE EXTENSION pg_stat_statements SCHEMA adm;
```

如果该扩展之前已在 `public` schema 中启用，请将其移动到新的 schema：

```sql
CREATE SCHEMA adm;
ALTER EXTENSION pg_stat_statements SET SCHEMA adm;
```

要在更改 schema 后查询 `pg_stat_statements` 数据，请在视图名称前加上新 schema：

```sql
SELECT * FROM adm.pg_stat_statements limit 0;
```

为了与期望它在 `public` schema 中启用的第三方监控解决方案兼容，您需要将其包含在 `search_path`中：

```sql
set search_path to public,adm;
```

<a id="fix-an-existing-dump-file-to-remove-references-to-pg_stat_statements"></a>

### 修复现有转储文件以移除对 `pg_stat_statements`的引用

要修复现有备份文件，请执行以下更改：

1. 从备份中提取以下文件：`db/database.sql.gz`。
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
