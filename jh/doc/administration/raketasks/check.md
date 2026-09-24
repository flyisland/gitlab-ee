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

极狐GitLab 提供 Rake 任务来检查各种组件的完整性。
另请参见[检查极狐GitLab 配置 Rake 任务](maintenance.md#check-gitlab-configuration)。

<a id="repository-integrity"></a>

## 仓库完整性

尽管 Git 具有很强的弹性并尝试防止数据完整性问题，但有时仍会出错。以下 Rake 任务旨在帮助极狐GitLab 管理员诊断有问题的仓库，以便进行修复。

这些 Rake 任务使用三种不同的方法来确定 Git 仓库的完整性。

1. Git 仓库文件系统检查（[`git fsck`](https://git-scm.com/docs/git-fsck)）。
   此步骤验证仓库中对象的连接性和有效性。
1. 检查仓库目录中是否存在 `config.lock`。
1. 检查 `refs/heads` 中是否存在任何分支/引用锁文件。

仅存在 `config.lock` 或引用锁文件并不一定表示存在问题。当 Git 和极狐GitLab 对仓库执行操作时，会例行创建和删除锁文件。它们用于防止数据完整性问题。但是，如果 Git 操作被中断，这些锁可能无法被正确清理。

以下症状可能表明仓库完整性存在问题。如果用户遇到这些症状，你可以使用下面描述的 Rake 任务来确定哪些仓库导致了问题。

- 在尝试推送代码时收到错误 - `remote: error: cannot lock ref`
- 查看极狐GitLab 仪表板或访问特定项目时出现 500 错误。

<a id="check-all-project-code-repositories"></a>

### 检查所有项目代码仓库

此任务遍历项目代码仓库，并运行前面描述的完整性检查。如果项目使用池仓库，该仓库也会被检查。其他类型的 Git 仓库[不会被检查](https://gitlab.com/gitlab-org/gitaly/-/issues/3643)。

要检查项目代码仓库：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:git:fsck
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:git:fsck RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="check-specific-project-code-repositories"></a>

### 检查特定项目代码仓库

{{< history >}}

- 引入于极狐GitLab 18.3。

{{< /history >}}

通过将 `PROJECT_IDS` 环境变量设置为以逗号分隔的项目 ID 列表，可以将检查限制为具有特定项目 ID 的项目的仓库。

例如，要检查项目 ID 为 `1` 和 `3` 的项目的仓库：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

```shell
sudo PROJECT_IDS="1,3" gitlab-rake gitlab:git:fsck
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
sudo -u git -H PROJECT_IDS="1,3" bundle exec rake gitlab:git:fsck RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="checksum-of-repository-refs"></a>

## 仓库引用的校验和

可以通过对每个仓库的所有引用进行校验和来将一个 Git 仓库与另一个仓库进行比较。如果两个仓库具有相同的引用，并且两个仓库都通过了完整性检查，那么我们可以确信两个仓库是相同的。

例如，这可用于将仓库的备份与源仓库进行比较。

<a id="check-all-gitlab-repositories"></a>

### 检查所有极狐GitLab 仓库

此任务遍历极狐GitLab 服务器上的所有仓库，并以 `<项目 ID>,<校验和>` 的格式输出校验和。

- 如果仓库不存在，则项目 ID 的校验和为空白。
- 如果仓库存在但为空，则输出的校验和为 `0000000000000000000000000000000000000000`。
- 不存在的项目会被跳过。

要检查所有极狐GitLab 仓库：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:git:checksum_projects
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:git:checksum_projects RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

例如，如果：

- ID 为 2 的项目不存在，它被跳过。
- ID 为 4 的项目没有仓库，其校验和为空白。
- ID 为 5 的项目有一个空的仓库，其校验和为 `0000000000000000000000000000000000000000`。

那么输出将类似于：

```plaintext
1,cfa3f06ba235c13df0bb28e079bcea62c5848af2
3,3f3fb58a8106230e3a6c6b48adc2712fb3b6ef87
4,
5,0000000000000000000000000000000000000000
6,6c6b48adc2712fb3b6ef87cfa3f06ba235c13df0
```

<a id="check-specific-gitlab-repositories"></a>

### 检查特定极狐GitLab 仓库

或者，可以通过设置环境变量 `CHECKSUM_PROJECT_IDS` 来对特定的项目 ID 进行校验和，该变量为一个逗号分隔的整数列表，例如：

```shell
sudo CHECKSUM_PROJECT_IDS="1,3" gitlab-rake gitlab:git:checksum_projects
```

<a id="uploaded-files-integrity"></a>

## 上传文件完整性

用户可以将各种类型的文件上传到极狐GitLab 实例。
这些完整性检查可以检测丢失的文件。此外，对于本地存储的文件，上传时会在数据库中生成并存储校验和，这些检查会根据当前文件验证这些校验和。

以下类型的文件支持完整性检查：

- CI 产物
- LFS 对象
- 项目级安全文件（于极狐GitLab 16.1.0 引入）
- 用户上传

要检查上传文件的完整性：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:artifacts:check
sudo gitlab-rake gitlab:ci_secure_files:check
sudo gitlab-rake gitlab:lfs:check
sudo gitlab-rake gitlab:uploads:check
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:artifacts:check RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:ci_secure_files:check RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:lfs:check RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:uploads:check RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

这些任务还接受一些环境变量，你可以使用它们来覆盖某些值：

| 变量  | 类型    | 描述 |
|-----------|---------|-------------|
| `BATCH`   | 整数 | 指定批次大小。默认为 200。 |
| `ID_FROM` | 整数 | 指定起始 ID，包括该值。 |
| `ID_TO`   | 整数 | 指定结束 ID，包括该值。 |
| `VERBOSE` | 布尔值 | 导致单独列出失败项，而不是总结。 |

```shell
sudo gitlab-rake gitlab:artifacts:check BATCH=100 ID_FROM=50 ID_TO=250
sudo gitlab-rake gitlab:ci_secure_files:check BATCH=100 ID_FROM=50 ID_TO=250
sudo gitlab-rake gitlab:lfs:check BATCH=100 ID_FROM=50 ID_TO=250
sudo gitlab-rake gitlab:uploads:check BATCH=100 ID_FROM=50 ID_TO=250
```

示例输出：

```shell
$ sudo gitlab-rake gitlab:uploads:check
正在检查上传的完整性
- 1..1350: 失败数: 0
- 1351..2743: 失败数: 0
- 2745..4349: 失败数: 2
- 4357..5762: 失败数: 1
- 5764..7140: 失败数: 2
- 7142..8651: 失败数: 0
- 8653..10134: 失败数: 0
- 10135..11773: 失败数: 0
- 11777..13315: 失败数: 0
完成！
```

详细输出示例：

```shell
$ sudo gitlab-rake gitlab:uploads:check VERBOSE=1
正在检查上传的完整性
- 1..1350: 失败数: 0
- 1351..2743: 失败数: 0
- 2745..4349: 失败数: 2
  - 上传: 3573: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /opt/gitlab/embedded/service/gitlab-rails/public/uploads/user-foo/project-bar/7a77cc52947bfe188adeff42f890bb77/image.png>
  - 上传: 3580: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /opt/gitlab/embedded/service/gitlab-rails/public/uploads/user-foo/project-bar/2840ba1ba3b2ecfa3478a7b161375f8a/pug.png>
- 4357..5762: 失败数: 1
  - 上传: 4636: #<Google::Apis::ServerError: Server error>
- 5764..7140: 失败数: 2
  - 上传: 5812: #<NoMethodError: undefined method `hashed_storage?' for nil:NilClass>
  - 上传: 5837: #<NoMethodError: undefined method `hashed_storage?' for nil:NilClass>
- 7142..8651: 失败数: 0
- 8653..10134: 失败数: 0
- 10135..11773: 失败数: 0
- 11777..13315: 失败数: 0
完成！
```

<a id="ldap-check"></a>

## LDAP 检查

LDAP 检查 Rake 任务测试绑定 DN 和密码凭据（如果已配置），并列出 LDAP 用户样本。此任务也作为 `gitlab:check` 任务的一部分执行，但可以独立运行。有关详细信息，请参阅 [LDAP Rake 任务 - LDAP 检查](ldap.md#check)。

<a id="verify-database-values-can-be-decrypted-using-the-current-secrets"></a>

## 验证数据库值是否可以使用当前密钥解密

此任务遍历数据库中所有可能的加密值，验证是否可以使用当前密钥文件（`gitlab-secrets.json`）解密它们。

自动修复尚未实现。如果你有无法解密的值，可以按照步骤重置它们，参见关于[密钥文件丢失时的操作](../backup_restore/troubleshooting_backup_gitlab.md#when-the-secrets-file-is-lost)的文档。

这可能需要很长的时间，具体取决于数据库的大小，因为它会检查所有表中的所有行。

要验证数据库值是否可以使用当前密钥解密：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:doctor:secrets
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
bundle exec rake gitlab:doctor:secrets RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

**示例输出**

```plaintext
I, [2020-06-11T17:17:54.951815 #27148]  INFO -- : 正在检查数据库中的加密值
I, [2020-06-11T17:18:12.677708 #27148]  INFO -- : - 应用设置失败: 0
I, [2020-06-11T17:18:12.823692 #27148]  INFO -- : - 用户失败: 0
[...] 可能包含加密数据的其他模型
I, [2020-06-11T17:18:14.938335 #27148]  INFO -- : - 群组失败: 1
I, [2020-06-11T17:18:15.559162 #27148]  INFO -- : - 运维::FeatureFlagsClient 失败: 0
I, [2020-06-11T17:18:15.575533 #27148]  INFO -- : - ScimOauthAccessToken 失败: 0
I, [2020-06-11T17:18:15.575678 #27148]  INFO -- : 总计: 1 行受到影响
I, [2020-06-11T17:18:15.575711 #27148]  INFO -- : 完成！
```

<a id="verbose-mode"></a>

### 详细模式

要获得有关哪些行和列无法解密的更详细信息，你可以传递 `VERBOSE` 环境变量。

要使用详细信息验证数据库值是否可以使用当前密钥解密：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:doctor:secrets VERBOSE=1
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
bundle exec rake gitlab:doctor:secrets RAILS_ENV=production VERBOSE=1
```

{{< /tab >}}

{{< /tabs >}}

**详细输出示例**

<!-- vale gitlab_base.SentenceSpacing = NO -->

```plaintext
I, [2020-06-11T17:17:54.951815 #27148]  INFO -- : 正在检查数据库中的加密值
I, [2020-06-11T17:18:12.677708 #27148]  INFO -- : - 应用设置失败: 0
I, [2020-06-11T17:18:12.823692 #27148]  INFO -- : - 用户失败: 0
[...] 可能包含加密数据的其他模型
D, [2020-06-11T17:19:53.224344 #27351] DEBUG -- : > Group[10].runners_token 出了问题: 验证失败: Route 不能为空
I, [2020-06-11T17:19:53.225178 #27351]  INFO -- : - 群组失败: 1
D, [2020-06-11T17:19:53.225267 #27351] DEBUG -- :   - Group[10]: runners_token
I, [2020-06-11T17:18:15.559162 #27148]  INFO -- : - 运维::FeatureFlagsClient 失败: 0
I, [2020-06-11T17:18:15.575533 #27148]  INFO -- : - ScimOauthAccessToken 失败: 0
I, [2020-06-11T17:18:15.575678 #27148]  INFO -- : 总计: 1 行受到影响
I, [2020-06-11T17:18:15.575711 #27148]  INFO -- : 完成！
```

<!-- vale gitlab_base.SentenceSpacing = YES -->

<a id="reset-encrypted-tokens-when-they-can-t-be-recovered"></a>

## 在加密令牌无法恢复时重置它们

{{< history >}}

- 引入于极狐GitLab 16.6。

{{< /history >}}

> [!警告]
> 此操作很危险，可能导致数据丢失。请格外谨慎。
> 在执行此操作之前，你必须了解极狐GitLab 的内部结构。

在某些情况下，加密令牌可能无法再恢复并导致问题。
最常见的是，在非常大的实例上，群组和项目的 runner 注册令牌可能会损坏。

要重置损坏的令牌：

1. 确定哪些数据库模型具有损坏的加密令牌。例如，可能是 `Group` 和 `Project`。
1. 确定损坏的令牌。例如 `runners_token`。
1. 要重置损坏的令牌，请使用 `VERBOSE=true MODEL_NAMES=Model1,Model2 TOKEN_NAMES=broken_token1,broken_token2` 运行 `gitlab:doctor:reset_encrypted_tokens`。例如：

   {{< tabs >}}

   {{< tab title="Linux 安装包 (Omnibus)" >}}

   ```shell
   VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token gitlab-rake gitlab:doctor:reset_encrypted_tokens
   ```

   {{< /tab >}}

   {{< tab title="自编译（源代码）" >}}

   ```shell
   bundle exec rake gitlab:doctor:reset_encrypted_tokens RAILS_ENV=production VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token
   ```

   {{< /tab >}}

   {{< /tabs >}}

   你将看到此任务尝试执行的每个操作：

   ```plain
   I, [2023-09-26T16:20:23.230942 #88920]  INFO -- : 如果无法读取，正在重置 Project、Group 上的 runners_token
   I, [2023-09-26T16:20:23.230975 #88920]  INFO -- : 在演练模式下执行，不会实际更新任何记录
   D, [2023-09-26T16:20:30.151585 #88920] DEBUG -- : > 修复 Project[1].runners_token
   I, [2023-09-26T16:20:30.151617 #88920]  INFO -- : 已检查 1/9 个项目
   D, [2023-09-26T16:20:30.151873 #88920] DEBUG -- : > 修复 Project[3].runners_token
   D, [2023-09-26T16:20:30.152975 #88920] DEBUG -- : > 修复 Project[10].runners_token
   I, [2023-09-26T16:20:30.152992 #88920]  INFO -- : 已检查 11/29 个项目
   I, [2023-09-26T16:20:30.153230 #88920]  INFO -- : 已检查 21/29 个项目
   I, [2023-09-26T16:20:30.153882 #88920]  INFO -- : 已检查 29 个项目
   D, [2023-09-26T16:20:30.195929 #88920] DEBUG -- : > 修复 Group[22].runners_token
   I, [2023-09-26T16:20:30.196125 #88920]  INFO -- : 已检查 1/19 个群组
   D, [2023-09-26T16:20:30.196192 #88920] DEBUG -- : > 修复 Group[25].runners_token
   D, [2023-09-26T16:20:30.197557 #88920] DEBUG -- : > 修复 Group[82].runners_token
   I, [2023-09-26T16:20:30.197581 #88920]  INFO -- : 已检查 11/19 个群组
   I, [2023-09-26T16:20:30.198455 #88920]  INFO -- : 已检查 19 个群组
   I, [2023-09-26T16:20:30.198462 #88920]  INFO -- : 完成！
   ```

1. 如果你确信此操作会重置正确的令牌，请禁用演练模式并再次运行操作：

   {{< tabs >}}

   {{< tab title="Linux 安装包 (Omnibus)" >}}

   ```shell
   DRY_RUN=false VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token gitlab-rake gitlab:doctor:reset_encrypted_tokens
   ```

   {{< /tab >}}

   {{< tab title="自编译（源代码）" >}}

   ```shell
   bundle exec rake gitlab:doctor:reset_encrypted_tokens RAILS_ENV=production DRY_RUN=false VERBOSE=true MODEL_NAMES=Project,Group TOKEN_NAMES=runners_token
   ```

   {{< /tab >}}

   {{< /tabs >}}

`gitlab:doctor:reset_encrypted_tokens` 任务具有以下限制：

- 非令牌属性，例如 `ApplicationSetting:ci_jwt_signing_key`，不会被重置。
- 单个模型记录中存在多个无法解密的属性会导致任务失败，并显示 `TypeError: no implicit conversion of nil into String ... block in aes256_gcm_decrypt` 错误。

<a id="troubleshooting"></a>

## 故障排除

以下是使用上文文档中的 Rake 任务可能发现的问题的解决方案。

<a id="dangling-objects"></a>

### 悬空对象

`gitlab-rake gitlab:git:fsck` 任务可以找到悬空对象，例如：

```plaintext
dangling blob a12...
dangling commit b34...
dangling tag c56...
dangling tree d78...
```

要删除它们，请尝试[运行 housekeeping](../housekeeping.md)。

如果问题仍然存在，请尝试通过 [Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 触发垃圾回收：

```ruby
p = Project.find_by_path("project-name")
Repositories::HousekeepingService.new(p, :gc).execute
```

如果悬空对象比默认的 2 周宽限期更年轻，并且你不想等待它们自动过期，请运行：

```ruby
Repositories::HousekeepingService.new(p, :prune).execute
```

<a id="delete-references-to-missing-remote-uploads"></a>

### 删除缺失远程上传的引用

`gitlab-rake gitlab:uploads:check VERBOSE=1` 检测到远程对象不存在，因为它们已在外部删除，但其引用仍然存在于极狐GitLab 数据库中。

带有错误消息的示例输出：

```shell
$ sudo gitlab-rake gitlab:uploads:check VERBOSE=1
正在检查上传的完整性
- 100..434: 失败数: 2
- 上传: 100: 远程对象不存在
- 上传: 101: 远程对象不存在
完成！
```

要删除这些对已外部删除的远程上传的引用，请打开 [极狐GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 并运行：

```ruby
uploads_deleted=0
Upload.find_each do |upload|
  next if upload.retrieve_uploader.file.exists?
  uploads_deleted=uploads_deleted + 1
  p upload                            ### 允许在销毁前进行验证
  # p upload.destroy!                 ### 取消注释以实际销毁
end
p "#{uploads_deleted} 个远程对象已被销毁。"
```

<a id="delete-references-to-missing-artifacts"></a>

### 删除缺失产物的引用

`gitlab-rake gitlab:artifacts:check VERBOSE=1` 检测产物（或 `job.log` 文件）是否：

- 已在极狐GitLab 之外删除。
- 引用仍然存在于极狐GitLab 数据库中。

当检测到这种情况时，Rake 任务会显示一条错误消息。例如：

```shell
正在检查作业产物的完整性
- 1..15: 失败数: 2
  - 作业产物: 9: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /var/opt/gitlab/gitlab-rails/shared/artifacts/4b/22/4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a/2022_06_30/8/9/job.log>
  - 作业产物: 15: 远程对象不存在
完成！

```

要删除这些对缺失本地和/或远程产物（`job.log` 文件）的引用：

1. 打开 [极狐GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下 Ruby 代码：

   ```ruby
   artifacts_deleted = 0
   ::Ci::JobArtifact.find_each do |artifact|                      ### 遍历产物
   #  next if artifact.file.filename != "job.log"                 ### 如果只需要处理 `job.log` 文件的引用，请取消注释
     next if artifact.file.file.exists?                           ### 如果文件引用有效则跳过
     artifacts_deleted += 1
     puts "#{artifact.id}  #{artifact.file.path} 缺失。"     ### 允许在销毁前进行验证
   #  artifact.destroy!                                           ### 取消注释以实际销毁
   end
   puts "识别/销毁的无效引用计数: #{artifacts_deleted}"
   ```

<a id="delete-references-to-missing-lfs-objects"></a>

### 删除缺失 LFS 对象的引用

如果 `gitlab-rake gitlab:lfs:check VERBOSE=1` 检测到数据库中存在的 LFS 对象但磁盘上不存在，[请遵循 LFS 文档中的步骤](../lfs/_index.md#missing-lfs-objects) 来删除数据库条目。

<a id="update-dangling-object-storage-references"></a>

### 更新悬空的对象存储引用

如果你已[从对象存储迁移到本地存储](../cicd/job_artifacts.md#migrating-from-object-storage-to-local-storage) 并且文件丢失，则会保留悬空数据库引用。

这在迁移日志中表现为类似以下的错误：

```shell
W, [2022-11-28T13:14:09.283833 #10025]  WARN -- : 无法传输 Ci::JobArtifact ID 11，错误: undefined method `body' for nil:NilClass
W, [2022-11-28T13:14:09.296911 #10025]  WARN -- : 无法传输 Ci::JobArtifact ID 12，错误: undefined method `body' for nil:NilClass
```

在禁用对象存储后尝试[删除缺失产物的引用](check.md#delete-references-to-missing-artifacts)，会导致以下错误：

```plaintext
RuntimeError (未为 JobArtifactUploader 启用对象存储)
```

要将这些引用更新为指向本地存储：

1. 打开 [极狐GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下 Ruby 代码：

   ```ruby
   artifacts_updated = 0
   ::Ci::JobArtifact.find_each do |artifact|                    ### 遍历产物
     next if artifact.file_store != 2                           ### 如果 file_store 已指向本地存储则跳过
     artifacts_updated += 1
     # artifact.update(file_store: 1)                           ### 取消注释以实际更新
   end
   puts "更新的 file_store 计数: #{artifacts_updated}"
   ```

现在，[删除缺失产物的引用](check.md#delete-references-to-missing-artifacts) 脚本可以正常工作并清理数据库。

<a id="delete-references-to-missing-secure-files"></a>

### 删除缺失安全文件的引用

`VERBOSE=1 gitlab-rake gitlab:ci_secure_files:check` 检测安全文件是否：

- 已在极狐GitLab 之外删除。
- 引用仍然存在于极狐GitLab 数据库中。

当检测到这种情况时，Rake 任务会显示一条错误消息。例如：

```shell
正在检查 CI 安全文件的完整性
- 1..15: 失败数: 2
  - Job SecureFile: 9: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /var/opt/gitlab/gitlab-rails/shared/ci_secure_files/4b/22/4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a/2022_06_30/8/9/distribution.cer>
  - Job SecureFile: 15: 远程对象不存在
完成！

```

要删除这些对缺失本地或远程安全文件的引用：

1. 打开 [极狐GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下 Ruby 代码：

   ```ruby
   secure_files_deleted = 0
   ::Ci::SecureFile.find_each do |secure_file|                    ### 遍历安全文件
     next if secure_file.file.file.exists?                        ### 如果文件引用有效则跳过
     secure_files_deleted += 1
     puts "#{secure_file.id}  #{secure_file.file.path} 缺失。"     ### 允许在销毁前进行验证
   #  secure_file.destroy!                                           ### 取消注释以实际销毁
   end
   puts "识别/销毁的无效引用计数: #{secure_files_deleted}"
   ```