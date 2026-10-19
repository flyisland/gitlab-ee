---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 文件导出项目迁移故障排查
description: "文件导出项目迁移故障排查。涵盖常见错误、性能问题和解决方案。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您在使用[文件导出迁移项目](import_export.md)时遇到问题，请参阅以下可能的解决方案。

<a id="troubleshooting-commands"></a>

## 故障排查命令

使用 [Rails 控制台](../../../administration/operations/rails_console.md) 通过 JID 查找导入状态和更多日志的信息：

```ruby
Project.find_by_full_path('group/project').import_state.slice(:jid, :status, :last_error)
> {"jid"=>"414dec93f941a593ea1a6894", "status"=>"finished", "last_error"=>nil}
```

```shell
# Logs
grep JID /var/log/gitlab/sidekiq/current
grep "Import/Export error" /var/log/gitlab/sidekiq/current
grep "Import/Export backtrace" /var/log/gitlab/sidekiq/current
tail /var/log/gitlab/gitlab-rails/importer.log
```

<a id="project-fails-to-import-due-to-mismatch"></a>

## 项目因不匹配而无法导入

如果导出的项目与项目导入之间的[实例 Runner 启用状态](../../../ci/runners/runners_scope.md#enable-instance-runners-for-a-project)不匹配，则项目无法导入。
请查看[议题 276930](https://gitlab.com/gitlab-org/gitlab/-/issues/276930)，并执行以下任一操作：

- 确保源项目和目标项目都启用了实例 Runner。
- 在导入项目时，禁用父群组的实例 Runner。

<a id="users-missing-from-imported-project"></a>

## 导入的项目中缺少用户

如果用户未随导入的项目一起导入，请参阅[保留用户贡献](import_export.md#preserving-user-contributions)的要求。

缺少用户的一个常见原因是用户未配置[公开邮箱设置](../../profile/_index.md#set-your-public-email)。
要解决此问题，请让用户使用极狐GitLab UI 配置此设置。

如果用户数量过多，手动配置不可行，
您可以使用 [Rails 控制台](../../../administration/operations/rails_console.md#starting-a-rails-console-session)将所有用户配置文件设置为使用公开邮箱地址：

```ruby
User.where("public_email IS NULL OR public_email = '' ").find_each do |u|
  next if u.bot?

  puts "Setting #{u.username}'s currently empty public email to #{u.email}…"
  u.public_email = u.email
  u.save!
end
```

<a id="import-workarounds-for-large-repositories"></a>

## 大型代码仓库的导入变通方法

[最大导入大小限制](import_export.md#import-a-project-and-its-data)可能会阻止导入成功。如果无法更改导入限制，您可以尝试此处列出的变通方法之一。

<a id="workaround-option-1"></a>

### 变通方法 1

以下本地工作流程可用于临时减小代码仓库大小，以便再次尝试导入：

1. 从导出文件创建临时工作目录：

   ```shell
   EXPORT=<filename-without-extension>

   mkdir "$EXPORT"
   tar -xf "$EXPORT".tar.gz --directory="$EXPORT"/
   cd "$EXPORT"/
   git clone project.bundle

   # Prevent interference with recreating an importable file later
   mv project.bundle ../"$EXPORT"-original.bundle
   mv ../"$EXPORT".tar.gz ../"$EXPORT"-original.tar.gz

   git switch --create smaller-tmp-main
   ```

1. 为减小代码仓库大小，请在此 `smaller-tmp-main` 分支上操作：
   [识别并删除大文件](../repository/repository_size.md#methods-to-reduce-repository-size)
   或[交互式变基并修复](../../../topics/git/git_rebase.md#interactive-rebase)以减少提交数量。

   ```shell
   # Reduce the .git/objects/pack/ file size
   cd project
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive

   # Prepare recreating an importable file
   git bundle create ../project.bundle <default-branch-name>
   cd ..
   mv project/ ../"$EXPORT"-project
   cd ..

   # Recreate an importable file
   tar -czf "$EXPORT"-smaller.tar.gz --directory="$EXPORT"/ .
   ```

1. 将此新的、更小的文件导入极狐GitLab。
1. 在原始代码仓库的完整克隆中，
   使用 `git remote set-url origin <new-url> && git push --force --all`
   完成导入。
1. 更新已导入代码仓库的
   [分支保护规则](../repository/branches/protected.md)及其[默认分支](../repository/branches/default.md)，并删除临时的 `smaller-tmp-main` 分支以及本地临时数据。

<a id="workaround-option-2"></a>

### 变通方法 2

> [!note]
> 此变通方法不考虑 LFS 对象。

此变通方法不是尝试一次推送所有更改，而是：

- 将项目导入与 Git 代码仓库导入分开
- 增量地将代码仓库推送到极狐GitLab

1. 对要迁移的代码仓库进行本地克隆。在后续步骤中，您将在项目导出之外推送此克隆。
1. 下载导出文件并移除 `project.bundle`（其中包含 Git 代码仓库）：

   ```shell
   tar -czvf new_export.tar.gz --exclude='project.bundle' @old_export.tar.gz
   ```

1. 导入没有 Git 代码仓库的导出文件。它会要求您确认要在没有代码仓库的情况下导入。
1. 将此 bash 脚本保存为文件，并在添加适当的 origin 后运行它。

   ```shell
   #!/bin/sh

   # ASSUMPTIONS:
   # - The GitLab location is "origin"
   # - The default branch is "main"
   # - This will attempt to push in chunks of 500 MB (dividing the total size by 500 MB).
   #   Decrease this size to push in smaller chunks if you still receive timeouts.

   git gc
   SIZE=$(git count-objects -v 2> /dev/null | grep size-pack | awk '{print $2}')

   # Be conservative and try to push 2 GB at a time
   # (given this assumes each commit is the same size - which is wrong)
   BATCHES=$(($SIZE / 500000))
   TOTAL_COMMITS=$(git rev-list --count HEAD)
   if (( BATCHES > TOTAL_COMMITS )); then
       BATCHES=$TOTAL_COMMITS
   fi

   INCREMENTS=$(( ($TOTAL_COMMITS / $BATCHES) - 1 ))

   for (( BATCH=BATCHES; BATCH>=1; BATCH-- ))
   do
     COMMIT_NUM=$(( $BATCH - $INCREMENTS ))
     COMMIT_SHA=$(git log -n $COMMIT_NUM --format=format:%H | tail -1)
     git push -u origin ${COMMIT_SHA}:refs/heads/main
   done
   git push -u origin main
   git push -u origin --all
   git push -u origin --tags
   ```

<a id="error-http-524-a-timeout-occurred-when-importing-a-project"></a>

## 错误：导入项目时出现 `HTTP 524 A timeout occurred`

在 JihuLab.com 上，导入项目可能会失败并出现 `HTTP 524 A timeout occurred` 错误。
当归档文件大小达到数 GB 时，可能会出现此错误。

每次上传都必须在时间限制内完成。大型归档文件可能超出该限制，这会在上传完成前关闭连接。

为避免此错误，请将归档文件托管在 HTTPS 位置（例如 AWS S3 存储桶），并让极狐GitLab 在导入期间下载它。使用以下端点之一：

- [`POST /api/v4/projects/remote-import`](../../../api/project_import_export.md#import-a-project-from-a-remote-archive)
  适用于任何 HTTPS URL，包括 S3 预签名 URL。
- [`POST /api/v4/projects/remote-import-s3`](../../../api/project_import_export.md#import-a-project-from-an-aws-s3-bucket)
  在使用凭据时适用于 AWS S3。

由于极狐GitLab 在后台下载归档文件，因此归档文件的大小不会导致超时。

<a id="sidekiq-process-fails-to-export-a-project"></a>

## Sidekiq 进程无法导出项目

有时 Sidekiq 进程可能无法导出项目，例如在执行期间被终止时。

GitLab.com 用户应[联系支持](https://support.gitlab.com/hc/en-us/articles/11626483177756-GitLab-Support#contact-support)以解决此问题。

极狐GitLab 私有化部署管理员可以使用 Rails 控制台绕过 Sidekiq 进程并手动触发项目导出：

```ruby
project = Project.find(1)
current_user = User.find_by(username: 'my-user-name')
RequestStore.begin!
ActiveRecord::Base.logger = Logger.new(STDOUT)
params = {}

::Projects::ImportExport::ExportService.new(project, current_user, params).execute(nil)
```

这会使导出文件在 UI 中可用，但不会向用户发送电子邮件。
要手动触发项目导出并发送电子邮件：

```ruby
project = Project.find(1)
current_user = User.find_by(username: 'my-user-name')
RequestStore.begin!
ActiveRecord::Base.logger = Logger.new(STDOUT)
params = {}

ProjectExportWorker.new.perform(current_user.id, project.id)
```

<a id="manually-execute-export-steps"></a>

## 手动执行导出步骤

您通常通过[Web 界面](import_export.md#export-a-project-and-its-data)或[项目导入导出 API](../../../api/project_import_export.md)导出项目。使用这些方法导出有时可能会失败，而不会提供足够的故障排查信息。在这些情况下，请[打开 Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)并遍历[所有已定义的导出器](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/services/projects/import_export/export_service.rb)。请逐行执行每条命令，而不是一次粘贴整个代码块，以便您能看到每条命令返回的任何错误。

```ruby
# User needs to have permission to export
u = User.find_by_username('someuser')
p = Project.find_by_full_path('some/project')
e = Projects::ImportExport::ExportService.new(p,u)

e.send(:version_saver).send(:save)
e.send(:repo_saver).send(:save)
e.send(:avatar_saver).send(:save)
e.send(:project_tree_saver).send(:save)
e.send(:uploads_saver).send(:save)
e.send(:wiki_repo_saver).send(:save)
e.send(:lfs_saver).send(:save)
e.send(:snippets_repo_saver).send(:save)
e.send(:design_repo_saver).send(:save)
## continue using `e.send(:exporter_name).send(:save)` going through the list of exporters

# The following line should show you the export_path similar to /var/opt/gitlab/gitlab-rails/shared/tmp/gitlab_exports/@hashed/49/94/4994....
s = Gitlab::ImportExport::Saver.new(exportable: p, shared: p.import_export_shared, user: u)

# Prior to GitLab 17.0, the `user` parameter was not supported. If you encounter an
# error with the above or are unsure whether or not to supply the `user`
# argument, use the following check:
Gitlab::ImportExport::Saver.instance_method(:initialize).parameters.include?([:keyreq, :user])
# If the preceding check returns false, omit the user argument:
s = Gitlab::ImportExport::Saver.new(exportable: p, shared: p.import_export_shared)

# To try and upload use:
s.send(:compress_and_save)
s.send(:save_upload)
```

项目成功上传后，导出的项目位于 `.tar.gz` 文件中，路径为 `/var/opt/gitlab/gitlab-rails/uploads/-/system/import_export_upload/export_file/`。

<a id="error-pgquerycanceled-error-canceling-statement-due-to-statement-timeout"></a>

## 错误：`PG::QueryCanceled: ERROR: canceling statement due to statement timeout`

某些迁移可能会因以下错误而超时：`PG::QueryCanceled: ERROR: canceling statement due to statement timeout`。
避免此问题的一种方法是减小迁移批处理大小。这可以降低迁移超时的可能性，但会使迁移速度变慢。

要减小批处理大小，您必须启用一个功能标志。有关更多信息，请参阅[议题 456948](https://gitlab.com/gitlab-org/gitlab/-/issues/456948)。

<a id="error-json-exceeds-50-mb-limit"></a>

## 错误：`JSON exceeds 50 MB limit`

当您使用文件导出导入项目时，可能会收到以下错误：

```plaintext
JSON exceeds 50 MB limit
```

当导出中的单个记录（例如具有大型描述或差异的合并请求或议题）大于导入对每条记录应用的 50 MB 限制时，会出现此错误。

要解决此错误，请减小源项目中受影响记录的大小，然后重新导出并导入项目。

<a id="error-command-exited-with-error-code-15-and-unable-to-save-filtered-into-filtered"></a>

## 错误：`command exited with error code 15 and Unable to save [FILTERED] into [FILTERED]`

当您使用文件导出迁移项目时，可能会在日志中收到以下错误：

```plaintext
command exited with error code 15 and Unable to save [FILTERED] into [FILTERED]
```

当 Sidekiq 收到 `SIGTERM` 信号时（通常在执行 `tar` 命令期间），会在导出或导入期间出现此错误。

在 JihuLab.com 等 Kubernetes 环境中，操作系统会因内存或磁盘不足、代码部署或实例升级而触发 `SIGTERM` 信号。
要确定根本原因，管理员应调查 Kubernetes 终止实例的原因。

在非 Kubernetes 环境中，如果在执行 `tar` 命令时实例被终止，则可能会出现此错误。
但是，此错误不会因磁盘不足而发生，因此内存不足是最可能的原因。

如果您遇到此错误：

- 当您导出文件时，极狐GitLab 会重试导出，直到达到最大重试次数，然后将导出标记为失败。
  对于 JihuLab.com，请尝试在周末实例负载较低时进行导出。
- 当您导入文件时，您必须自行重试导入。极狐GitLab 不会自动重试导入。

<a id="troubleshooting-performance-issues"></a>

## 性能问题故障排查

请阅读以下 Import/Export 的当前性能问题。

<a id="oom-errors"></a>

### OOM 错误

内存不足（OOM）错误通常由 [Sidekiq 内存杀手](../../../administration/sidekiq/sidekiq_memory_killer.md)导致：

```shell
SIDEKIQ_MEMORY_KILLER_MAX_RSS = 2000000
SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS = 3000000
SIDEKIQ_MEMORY_KILLER_GRACE_TIME = 900
```

导入状态为 `started`，并且以下 Sidekiq 日志表明存在内存问题：

```shell
WARN: Work still in progress <struct with JID>
```

<a id="timeouts"></a>

### 超时

超时错误是由于 `Gitlab::Import::StuckProjectImportJobsWorker` 将进程标记为失败而发生的：

```ruby
module Gitlab
  module Import
    class StuckProjectImportJobsWorker
      include Gitlab::Import::StuckImportJob
      # ...
    end
  end
end

module Gitlab
  module Import
    module StuckImportJob
      # ...
      IMPORT_JOBS_EXPIRATION = 15.hours.to_i
      # ...
      def perform
        stuck_imports_without_jid_count = mark_imports_without_jid_as_failed!
        stuck_imports_with_jid_count = mark_imports_with_jid_as_failed!

        track_metrics(stuck_imports_with_jid_count, stuck_imports_without_jid_count)
      end
      # ...
    end
  end
end
```

```shell
Marked stuck import jobs as failed. JIDs: xyz
```

```plaintext
  +-----------+    +-----------------------------------+
  |Export Job |--->| Calls ActiveRecord `as_json` and  |
  +-----------+    | `to_json` on all project models   |
                   +-----------------------------------+

  +-----------+    +-----------------------------------+
  |Import Job |--->| Loads all JSON in memory, then    |
  +-----------+    | inserts into the DB in batches    |
                   +-----------------------------------+
```

<a id="problems-and-solutions"></a>

### 问题与解决方案

[慢速 JSON](https://gitlab.com/gitlab-org/gitlab/-/issues/25251) 从数据库加载/转储模型：

- [拆分 worker](https://gitlab.com/gitlab-org/gitlab/-/issues/25252)
- 批量导出
- 优化 SQL
- 摆脱 `ActiveRecord` 回调（困难）

高内存使用（另请参阅一些[分析](https://gitlab.com/gitlab-org/gitlab/-/issues/18857)）：

- 使用更少内存的 DB 提交最佳点
- [Netflix Fast JSON API](https://github.com/Netflix/fast_jsonapi) 可能会有所帮助
- 批量读写磁盘和任何 SQL
