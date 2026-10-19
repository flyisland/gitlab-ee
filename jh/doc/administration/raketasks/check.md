---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 完整性检查 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供 Rake 任务来检查各种组件的完整性。另请参阅[检查极狐GitLab 配置 Rake 任务](maintenance.md#check-gitlab-configuration)。

<a id="repository-integrity"></a>

## 代码仓库完整性

尽管 Git 具有很强的韧性并会尽力防止数据完整性问题，但有时仍会出问题。以下 Rake 任务旨在帮助极狐GitLab 管理员诊断有问题的代码仓库，以便进行修复。

这些 Rake 任务使用三种不同的方法来确定 Git 代码仓库的完整性。

1. Git 代码仓库文件系统检查（[`git fsck`](https://git-scm.com/docs/git-fsck)）。
   此步骤验证代码仓库中对象的连通性和有效性。
1. 检查代码仓库目录中是否存在 `config.lock`。
1. 检查 `refs/heads`中是否存在任何分支/引用锁定文件。

仅存在 `config.lock` 或引用锁并不一定表示有问题。当 Git 和极狐GitLab 对代码仓库执行操作时，锁定文件会被例行创建和删除。它们用于防止数据完整性问题。但是，如果 Git 操作被中断，这些锁可能无法被正确清理。

以下症状可能表明代码仓库完整性存在问题。如果用户遇到这些症状，您可以使用下面描述的 Rake 任务来确定究竟是哪些代码仓库导致了问题。

- 尝试推送代码时收到错误 - `remote: error: cannot lock ref`
- 查看极狐GitLab 仪表板或访问特定项目时出现 500 错误。

<a id="check-all-project-code-repositories"></a>

### 检查所有项目代码仓库

此任务会遍历项目代码仓库并运行前面描述的完整性检查。如果项目使用了池代码仓库，也会对其进行检查。其他类型的 Git 代码仓库[不会被检查](https://gitlab.com/gitlab-org/gitaly/-/issues/3643)。

要检查项目代码仓库：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:git:fsck
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:git:fsck RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="check-specific-project-code-repositories"></a>

### 检查特定项目代码仓库

通过将 `PROJECT_IDS` 环境变量设置为以逗号分隔的项目 ID 列表，可以将检查限制为具有特定项目 ID 的项目的代码仓库。

例如，要检查项目 ID 为 `1` 和 `3`的项目的代码仓库：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo PROJECT_IDS="1,3" gitlab-rake gitlab:git:fsck
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo -u git -H PROJECT_IDS="1,3" bundle exec rake gitlab:git:fsck RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="checksum-of-repository-refs"></a>

## 代码仓库引用的校验和

通过对每个代码仓库的所有引用计算校验和，可以将一个 Git 代码仓库与另一个进行比较。如果两个代码仓库具有相同的引用，并且两个代码仓库都通过了完整性检查，那么我们就可以确信这两个代码仓库是相同的。

例如，这可用于将代码仓库的备份与源代码仓库进行比较。

<a id="check-all-gitlab-repositories"></a>

### 检查所有极狐GitLab 代码仓库

此任务会遍历极狐GitLab 服务器上的所有代码仓库，并以 `<PROJECT ID>,<CHECKSUM>` 格式输出校验和。

- 如果代码仓库不存在，则项目 ID 的校验和为空。
- 如果代码仓库存在但为空，则输出的校验和为 `0000000000000000000000000000000000000000`。
- 不存在的项目会被跳过。

要检查所有极狐GitLab 代码仓库：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:git:checksum_projects
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:git:checksum_projects RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

例如，如果：

- ID 为 #2 的项目不存在，则会被跳过。
- ID 为 #4 的项目没有代码仓库，其校验和为空。
- ID 为 #5 的项目有一个空代码仓库，其校验和为 `0000000000000000000000000000000000000000`。

那么输出将类似于：

```plaintext
1,cfa3f06ba235c13df0bb28e079bcea62c5848af2
3,3f3fb58a8106230e3a6c6b48adc2712fb3b6ef87
4,
5,0000000000000000000000000000000000000000
6,6c6b48adc2712fb3b6ef87cfa3f06ba235c13df0
```

<a id="check-specific-gitlab-repositories"></a>

### 检查特定极狐GitLab 代码仓库

您也可以选择通过设置环境变量 `CHECKSUM_PROJECT_IDS` 为以逗号分隔的整数列表，来对特定项目 ID 计算校验和，例如：

```shell
sudo CHECKSUM_PROJECT_IDS="1,3" gitlab-rake gitlab:git:checksum_projects
```

<a id="uploaded-files-integrity"></a>

## 上传文件完整性

用户可以将各种类型的文件上传到极狐GitLab 安装实例。这些完整性检查可以检测缺失的文件。此外，对于本地存储的文件，上传时会生成校验和并存储在数据库中，这些检查会将它们与当前文件进行验证。

支持对以下类型的文件进行完整性检查：

- CI 产物
- LFS 对象
- 项目级安全文件
- 用户上传

要检查上传文件的完整性：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:artifacts:check
sudo gitlab-rake gitlab:ci_secure_files:check
sudo gitlab-rake gitlab:lfs:check
sudo gitlab-rake gitlab:uploads:check
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:artifacts:check RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:ci_secure_files:check RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:lfs:check RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:uploads:check RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

这些任务还接受一些环境变量，您可以使用它们来覆盖某些值：

| 变量  | 类型    | 描述 |
|-----------|---------|-------------|
| `BATCH`   | integer | 指定批次的大小。默认为 200。 |
| `ID_FROM` | integer | 指定起始 ID，包含该值。 |
| `ID_TO`   | integer | 指定结束 ID 值，包含该值。 |
| `VERBOSE` | boolean | 使失败项被单独列出，而不是被汇总。 |

```shell
sudo gitlab-rake gitlab:artifacts:check BATCH=100 ID_FROM=50 ID_TO=250
sudo gitlab-rake gitlab:ci_secure_files:check BATCH=100 ID_FROM=50 ID_TO=250
sudo gitlab-rake gitlab:lfs:check BATCH=100 ID_FROM=50 ID_TO=250
sudo gitlab-rake gitlab:uploads:check BATCH=100 ID_FROM=50 ID_TO=250
```

示例输出：

```shell
$ sudo gitlab-rake gitlab:uploads:check
Checking integrity of Uploads
- 1..1350: Failures: 0
- 1351..2743: Failures: 0
- 2745..4349: Failures: 2
- 4357..5762: Failures: 1
- 5764..7140: Failures: 2
- 7142..8651: Failures: 0
- 8653..10134: Failures: 0
- 10135..11773: Failures: 0
- 11777..13315: Failures: 0
Done!
```

详细输出示例：

```shell
$ sudo gitlab-rake gitlab:uploads:check VERBOSE=1
Checking integrity of Uploads
- 1..1350: Failures: 0
- 1351..2743: Failures: 0
- 2745..4349: Failures: 2
  - Upload: 3573: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /opt/gitlab/embedded/service/gitlab-rails/public/uploads/user-foo/project-bar/7a77cc52947bfe188adeff42f890bb77/image.png>
  - Upload: 3580: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /opt/gitlab/embedded/service/gitlab-rails/public/uploads/user-foo/project-bar/2840ba1ba3b2ecfa3478a7b161375f8a/pug.png>
- 4357..5762: Failures: 1
  - Upload: 4636: #<Google::Apis::ServerError: Server error>
- 5764..7140: Failures: 2
  - Upload: 5812: #<NoMethodError: undefined method `hashed_storage?' for nil:NilClass>
  - Upload: 5837: #<NoMethodError: undefined method `hashed_storage?' for nil:NilClass>
- 7142..8651: Failures: 0
- 8653..10134: Failures: 0
- 10135..11773: Failures: 0
- 11777..13315: Failures: 0
Done!
```

<a id="ldap-check"></a>

## LDAP 检查

LDAP 检查 Rake 任务会测试绑定 DN 和密码凭据（如果已配置），并列出 LDAP 用户示例。此任务也会作为 `gitlab:check` 任务的一部分执行，但可以独立运行。
详情请参阅 [LDAP Rake 任务 - LDAP 检查](ldap.md#check)。

<a id="verify-database-values-can-be-decrypted-using-the-current-secrets"></a>

## 验证数据库值能否使用当前密钥解密

此任务会遍历数据库中所有可能的加密值，验证它们能否使用当前密钥文件（`gitlab-secrets.json`）解密。

自动解决尚未实现。如果您有无法解密的值，可以按照步骤重置它们，请参阅我们关于[密钥文件丢失时](../backup_restore/troubleshooting_backup_gitlab.md#when-the-secrets-file-is-lost)该怎么做的文档。

这可能会花费很长时间，具体取决于您的数据库大小，因为它会检查所有表中的所有行。

要验证数据库值能否使用当前密钥解密：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:doctor:secrets
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:doctor:secrets RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

**示例输出**

```plaintext
I, [2020-06-11T17:17:54.951815 #27148]  INFO -- : Checking encrypted values in the database
I, [2020-06-11T17:18:12.677708 #27148]  INFO -- : - ApplicationSetting failures: 0
I, [2020-06-11T17:18:12.823692 #27148]  INFO -- : - User failures: 0
[...] other models possibly containing encrypted data
I, [2020-06-11T17:18:14.938335 #27148]  INFO -- : - Group failures: 1
I, [2020-06-11T17:18:15.559162 #27148]  INFO -- : - Operations::FeatureFlagsClient failures: 0
I, [2020-06-11T17:18:15.575533 #27148]  INFO -- : - ScimOauthAccessToken failures: 0
I, [2020-06-11T17:18:15.575678 #27148]  INFO -- : Total: 1 row(s) affected
I, [2020-06-11T17:18:15.575711 #27148]  INFO -- : Done!
```

<a id="verbose-mode"></a>

### 详细模式

要获取有关哪些行和列无法解密的更详细信息，您可以传入 `VERBOSE` 环境变量。

要使用当前密钥验证数据库值能否解密并获取详细信息：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:doctor:secrets VERBOSE=1
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:doctor:secrets RAILS_ENV=production VERBOSE=1
```

{{< /tab >}}

{{< /tabs >}}

**详细输出示例**

<!-- vale gitlab_base.SentenceSpacing = NO -->

```plaintext
I, [2020-06-11T17:17:54.951815 #27148]  INFO -- : Checking encrypted values in the database
I, [2020-06-11T17:18:12.677708 #27148]  INFO -- : - ApplicationSetting failures: 0
I, [2020-06-11T17:18:12.823692 #27148]  INFO -- : - User failures: 0
[...] other models possibly containing encrypted data
D, [2020-06-11T17:19:53.224344 #27351] DEBUG -- : > Something went wrong for Group[10].runners_token: Validation failed: Route can't be blank
I, [2020-06-11T17:19:53.225178 #27351]  INFO -- : - Group failures: 1
D, [2020-06-11T17:19:53.225267 #27351] DEBUG -- :   - Group[10]: runners_token
I, [2020-06-11T17:18:15.559162 #27148]  INFO -- : - Operations::FeatureFlagsClient failures: 0
I, [2020-06-11T17:18:15.575533 #27148]  INFO -- : - ScimOauthAccessToken failures: 0
I, [2020-06-11T17:18:15.575678 #27148]  INFO -- : Total: 1 row(s) affected
I, [2020-06-11T17:18:15.575711 #27148]  INFO -- : Done!
```

<!-- vale gitlab_base.SentenceSpacing = YES -->

<a id="reset-encrypted-tokens-when-they-cant-be-recovered"></a>

## 当加密令牌无法恢复时重置它们

> [!warning]
> 此操作很危险，可能导致数据丢失。请极其谨慎地操作。
> 在执行此操作之前，您必须了解极狐GitLab 内部机制。

在某些情况下，加密令牌可能无法再恢复并导致问题。最常见的情况是，在非常大的实例上，群组和项目的 runner 注册令牌可能会损坏。

要重置损坏的令牌：

1. 确定具有损坏加密令牌的数据库模型。例如，它可能是 `Group` 和 `Project`。
1. 确定损坏的令牌。例如 `runners_token`。
1. 要重置损坏的令牌，请使用 `VERBOSE=true MODEL_NAMES=Model1,Model2 TOKEN_NAMES=broken_token1,broken_token2` 运行 `gitlab:doctor:reset_encrypted_tokens`。例如：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token gitlab-rake gitlab:doctor:reset_encrypted_tokens
   ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   ```shell
   bundle exec rake gitlab:doctor:reset_encrypted_tokens RAILS_ENV=production VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token
   ```

   {{< /tab >}}

   {{< /tabs >}}

   您将看到此任务会尝试执行的每一个操作：

   ```plain
   I, [2023-09-26T16:20:23.230942 #88920]  INFO -- : Resetting runners_token on Project, Group if they can not be read
   I, [2023-09-26T16:20:23.230975 #88920]  INFO -- : Executing in DRY RUN mode, no records will actually be updated
   D, [2023-09-26T16:20:30.151585 #88920] DEBUG -- : > Fix Project[1].runners_token
   I, [2023-09-26T16:20:30.151617 #88920]  INFO -- : Checked 1/9 Projects
   D, [2023-09-26T16:20:30.151873 #88920] DEBUG -- : > Fix Project[3].runners_token
   D, [2023-09-26T16:20:30.152975 #88920] DEBUG -- : > Fix Project[10].runners_token
   I, [2023-09-26T16:20:30.152992 #88920]  INFO -- : Checked 11/29 Projects
   I, [2023-09-26T16:20:30.153230 #88920]  INFO -- : Checked 21/29 Projects
   I, [2023-09-26T16:20:30.153882 #88920]  INFO -- : Checked 29 Projects
   D, [2023-09-26T16:20:30.195929 #88920] DEBUG -- : > Fix Group[22].runners_token
   I, [2023-09-26T16:20:30.196125 #88920]  INFO -- : Checked 1/19 Groups
   D, [2023-09-26T16:20:30.196192 #88920] DEBUG -- : > Fix Group[25].runners_token
   D, [2023-09-26T16:20:30.197557 #88920] DEBUG -- : > Fix Group[82].runners_token
   I, [2023-09-26T16:20:30.197581 #88920]  INFO -- : Checked 11/19 Groups
   I, [2023-09-26T16:20:30.198455 #88920]  INFO -- : Checked 19 Groups
   I, [2023-09-26T16:20:30.198462 #88920]  INFO -- : Done!
   ```

1. 如果您确信此操作会重置正确的令牌，请禁用试运行模式并再次运行该操作：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   DRY_RUN=false VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token gitlab-rake gitlab:doctor:reset_encrypted_tokens
   ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   ```shell
   bundle exec rake gitlab:doctor:reset_encrypted_tokens RAILS_ENV=production DRY_RUN=false VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token
   ```

   {{< /tab >}}

   {{< /tabs >}}

`gitlab:doctor:reset_encrypted_tokens` 任务具有以下限制：

- 非令牌属性，例如 `ApplicationSetting:ci_jwt_signing_key` 不会被重置。
- 单个模型记录中存在多个无法解密的属性会导致该任务
  失败，并出现 `TypeError: no implicit conversion of nil into String ... block in aes256_gcm_decrypt` 错误。

<a id="troubleshooting"></a>

## 故障排除

以下是您使用前面记录的 Rake 任务时可能发现的问题的解决方案。

<a id="dangling-objects"></a>

### 悬空对象

`gitlab-rake gitlab:git:fsck` 任务可以找到悬空对象，例如：

```plaintext
dangling blob a12...
dangling commit b34...
dangling tag c56...
dangling tree d78...
```

要删除它们，请尝试[运行例行维护](../housekeeping.md)。

如果问题仍然存在，请尝试通过 [Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)触发垃圾回收：

```ruby
p = Project.find_by_path("project-name")
Repositories::HousekeepingService.new(p, :gc).execute
```

如果悬空对象的存续时间短于默认的 2 周宽限期，而您不想等到它们自动过期，请运行：

```ruby
Repositories::HousekeepingService.new(p, :prune).execute
```

<a id="delete-references-to-missing-remote-uploads"></a>

### 删除对缺失的远程上传的引用

`gitlab-rake gitlab:uploads:check VERBOSE=1` 会检测已在外部删除的远程对象。这些对象的引用仍存在于极狐GitLab 数据库中。

带有错误消息的示例输出：

```shell
$ sudo gitlab-rake gitlab:uploads:check VERBOSE=1
Checking integrity of Uploads
- 100..434: Failures: 2
- Upload: 100: Remote object does not exist
- Upload: 101: Remote object does not exist
Done!
```

要删除这些对已在外部删除的远程上传的引用，请打开 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)并运行：

```ruby
uploads_deleted=0
Upload.find_each do |upload|
  next if upload.retrieve_uploader.file.exists?
  uploads_deleted=uploads_deleted + 1
  p upload                            ### allow verification before destroy
  # p upload.destroy!                 ### uncomment to actually destroy
end
p "#{uploads_deleted} remote objects were destroyed."
```

<a id="delete-references-to-missing-artifacts"></a>

### 删除对缺失产物的引用

`gitlab-rake gitlab:artifacts:check VERBOSE=1` 会检测产物（或 `job.log` 文件）是否存在以下情况：

- 在极狐GitLab 之外被删除。
- 其引用仍存在于极狐GitLab 数据库中。

检测到这种情况时，Rake 任务会显示错误消息。例如：

```shell
Checking integrity of Job artifacts
- 1..15: Failures: 2
  - Job artifact: 9: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /var/opt/gitlab/gitlab-rails/shared/artifacts/4b/22/4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a/2022_06_30/8/9/job.log>
  - Job artifact: 15: Remote object does not exist
Done!

```

要删除这些对缺失的本地和/或远程产物（`job.log` 文件）的引用：

1. 打开 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下 Ruby 代码：

   ```ruby
   artifacts_deleted = 0
   ::Ci::JobArtifact.find_each do |artifact|                      ### Iterate artifacts
   #  next if artifact.file.filename != "job.log"                 ### Uncomment if only `job.log` files' references are to be processed
     next if artifact.file.file.exists?                           ### Skip if the file reference is valid
     artifacts_deleted += 1
     puts "#{artifact.id}  #{artifact.file.path} is missing."     ### Allow verification before destroy
   #  artifact.destroy!                                           ### Uncomment to actually destroy
   end
   puts "Count of identified/destroyed invalid references: #{artifacts_deleted}"
   ```

<a id="delete-references-to-missing-lfs-objects"></a>

### 删除对缺失的 LFS 对象的引用

如果 `gitlab-rake gitlab:lfs:check VERBOSE=1` 检测到存在于数据库中但不在磁盘上的 LFS 对象，请[按照 LFS 文档中的步骤](../lfs/_index.md#missing-lfs-objects)删除数据库条目。

<a id="update-dangling-object-storage-references"></a>

### 更新悬空的对象存储引用

如果您[从对象存储迁移到本地存储](../cicd/job_artifacts.md#migrating-from-object-storage-to-local-storage)且文件缺失，那么悬空的数据库引用会保留下来。

这会在迁移日志中显示为如下错误：

```shell
W, [2022-11-28T13:14:09.283833 #10025]  WARN -- : Failed to transfer Ci::JobArtifact ID 11 with error: undefined method `body' for nil:NilClass
W, [2022-11-28T13:14:09.296911 #10025]  WARN -- : Failed to transfer Ci::JobArtifact ID 12 with error: undefined method `body' for nil:NilClass
```

在您禁用对象存储后，尝试[删除对缺失产物的引用](#delete-references-to-missing-artifacts)会导致以下错误：

```plaintext
RuntimeError (Object Storage is not enabled for JobArtifactUploader)
```

要将这些引用更新为指向本地存储：

1. 打开 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下 Ruby 代码：

   ```ruby
   artifacts_updated = 0
   ::Ci::JobArtifact.find_each do |artifact|                    ### Iterate artifacts
     next if artifact.file_store != 2                           ### Skip if file_store already points to local storage
     artifacts_updated += 1
     # artifact.update(file_store: 1)                           ### Uncomment to actually update
   end
   puts "Updated file_store count: #{artifacts_updated}"
   ```

用于[删除对缺失产物的引用](#delete-references-to-missing-artifacts)的脚本现在可以正常工作并清理数据库。

<a id="delete-references-to-missing-secure-files"></a>

### 删除对缺失的安全文件的引用

`VERBOSE=1 gitlab-rake gitlab:ci_secure_files:check` 会检测安全文件是否存在以下情况：

- 在极狐GitLab 之外被删除。
- 其引用仍存在于极狐GitLab 数据库中。

检测到这种情况时，Rake 任务会显示错误消息。例如：

```shell
Checking integrity of CI Secure Files
- 1..15: Failures: 2
  - Job SecureFile: 9: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /var/opt/gitlab/gitlab-rails/shared/ci_secure_files/4b/22/4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a/2022_06_30/8/9/distribution.cer>
  - Job SecureFile: 15: Remote object does not exist
Done!

```

要删除这些对缺失的本地或远程安全文件的引用：

1. 打开 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下 Ruby 代码：

   ```ruby
   secure_files_deleted = 0
   ::Ci::SecureFile.find_each do |secure_file|                    ### Iterate secure files
     next if secure_file.file.file.exists?                        ### Skip if the file reference is valid
     secure_files_deleted += 1
     puts "#{secure_file.id}  #{secure_file.file.path} is missing."     ### Allow verification before destroy
   #  secure_file.destroy!                                           ### Uncomment to actually destroy
   end
   puts "Count of identified/destroyed invalid references: #{secure_files_deleted}"
   ```
