---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为极狐GitLab 私有化部署配置 Git LFS。
title: 极狐GitLab Git 大文件存储（LFS）管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 Git Large File Storage (LFS) 在 Git 代码仓库中存储大文件，而不会
增加其大小或影响性能。您可以启用或禁用 LFS，为 LFS 对象配置本地或远程存储，并在不同存储类型之间迁移对象。

用户文档请参见 [Git Large File Storage (LFS)](../../topics/git/lfs/_index.md)。

先决条件：

- 用户必须安装 [Git LFS 客户端](https://git-lfs.com/) 1.1.0 及更高版本，或 1.0.2。

<a id="enable-or-disable-lfs"></a>

## 启用或禁用 LFS

LFS 默认启用。要禁用它：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # Change to true to enable lfs - enabled by default if not defined
   gitlab_rails['lfs_enabled'] = false
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       lfs:
         enabled: false
   ```

1. 保存文件并应用新 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['lfs_enabled'] = false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     lfs:
       enabled: false
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

<a id="change-local-storage-path"></a>

## 更改本地存储路径

Git LFS 对象可能很大。默认情况下，它们存储在安装极狐GitLab 的服务器上。

> [!note]
> 对于 Docker 安装，您可以更改数据挂载的路径。
> 对于 Helm chart，请使用
> [对象存储](https://gitlab.cn/docs/charts/advanced/external-object-storage/)。

要更改默认本地存储路径位置：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # /var/opt/gitlab/gitlab-rails/shared/lfs-objects by default.
   gitlab_rails['lfs_storage_path'] = "/mnt/storage/lfs-objects"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   # /home/git/gitlab/shared/lfs-objects by default.
   production: &base
     lfs:
       storage_path: /mnt/storage/lfs-objects
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

<a id="storing-lfs-objects-in-remote-object-storage"></a>

## 将 LFS 对象存储在远程对象存储中

您可以将 LFS 对象存储在远程对象存储中。这样可以减少对本地磁盘的读写，并显著释放磁盘空间。

您应该使用[统一对象存储设置](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

<a id="migrating-to-object-storage"></a>

### 迁移到对象存储

您可以将 LFS 对象从本地存储迁移到对象存储。该处理在后台完成，无需停机。

1. [配置对象存储](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。
1. 迁移 LFS 对象：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   sudo gitlab-rake gitlab:lfs:migrate
   ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   ```shell
   sudo docker exec -t <container name> gitlab-rake gitlab:lfs:migrate
   ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   ```shell
   sudo -u git -H bundle exec rake gitlab:lfs:migrate RAILS_ENV=production
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 可选。使用 PostgreSQL 控制台跟踪进度并验证所有作业 LFS 对象是否已成功迁移。
   1. 打开 PostgreSQL 控制台：

      {{< tabs >}}

      {{< tab title="Linux 软件包（Omnibus）" >}}

      ```shell
      sudo gitlab-psql
      ```

      {{< /tab >}}

      {{< tab title="Docker" >}}

      ```shell
      sudo docker exec -it <container_name> /bin/bash
      gitlab-psql
      ```

      {{< /tab >}}

      {{< tab title="自行编译（源代码）" >}}

      ```shell
      sudo -u git -H psql -d gitlabhq_production
      ```

      {{< /tab >}}

      {{< /tabs >}}

   1. 使用以下 SQL 查询验证所有 LFS 文件是否已迁移到对象存储。`objectstg`的数量应与 `total` 相同：

      ```shell
      gitlabhq_production=# SELECT count(*) AS total, sum(case when file_store = '1' then 1 else 0 end) AS filesystem, sum(case when file_store = '2' then 1 else 0 end) AS objectstg FROM lfs_objects;

      total | filesystem | objectstg
      ------+------------+-----------
       2409 |          0 |      2409
      ```

1. 验证磁盘上的 `lfs-objects` 目录中是否没有文件：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   sudo find /var/opt/gitlab/gitlab-rails/shared/lfs-objects -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   假设您已将 `/var/opt/gitlab` 挂载到 `/srv/gitlab`：

   ```shell
   sudo find /srv/gitlab/gitlab-rails/shared/lfs-objects -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   ```shell
   sudo find /home/git/gitlab/shared/lfs-objects -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="migrating-back-to-local-storage"></a>

### 迁移回本地存储

> [!note]
> 对于 Helm chart，您应该使用
> [对象存储](https://gitlab.cn/docs/charts/advanced/external-object-storage/)。

要迁移回本地存储：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 迁移 LFS 对象：

   ```shell
   sudo gitlab-rake gitlab:lfs:migrate_to_local
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并为 LFS 对象
   [禁用对象存储](../object_storage.md#disable-object-storage-for-specific-features)：

   ```ruby
   gitlab_rails['object_store']['objects']['lfs']['enabled'] = false
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 迁移 LFS 对象：

   ```shell
   sudo docker exec -t <container name> gitlab-rake gitlab:lfs:migrate_to_local
   ```

1. 编辑 `docker-compose.yml` 并为 LFS 对象禁用对象存储：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['object_store']['objects']['lfs']['enabled'] = false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 迁移 LFS 对象：

   ```shell
   sudo -u git -H bundle exec rake gitlab:lfs:migrate_to_local RAILS_ENV=production
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并为 LFS 对象禁用对象存储：

   ```yaml
   production: &base
     object_store:
       objects:
         lfs:
           enabled: false
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

<a id="pure-ssh-transfer-protocol"></a>

## 纯 SSH 传输协议

> [!warning]
> 此功能受[一个已知问题](https://github.com/git-lfs/git-lfs/issues/5880)影响
> （已在 [Git LFS 3.6.0](https://github.com/git-lfs/git-lfs/blob/main/CHANGELOG.md#360-20-november-2024)中解决）。
> 如果您使用纯 SSH 协议克隆包含多个 Git LFS 对象的代码仓库，
> 客户端可能会因 `nil` 指针引用而崩溃。

[`git-lfs` 3.0.0](https://github.com/git-lfs/git-lfs/blob/main/CHANGELOG.md#300-24-sep-2021)
发布了对使用 SSH 作为传输协议（而非 HTTP）的支持。SSH 由 `git-lfs` 命令行工具透明处理。

当启用纯 SSH 协议支持且 `git` 配置为使用 SSH 时，所有 LFS 操作都通过 SSH 进行。例如，当 Git 远程地址为 `git@gitlab.com:gitlab-org/gitlab.git` 时。您不能将 `git` 和 `git-lfs` 配置为使用不同的协议。从 3.0 版本开始，`git-lfs` 会先尝试使用纯 SSH 协议，如果未启用或不可用，则会回退到使用 HTTP。

先决条件：

- `git-lfs` 版本必须为 [v3.5.1](https://github.com/git-lfs/git-lfs/releases/tag/v3.5.1) 或更高。

要将 Git LFS 切换为使用纯 SSH 协议：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_shell['lfs_pure_ssh_protocol'] = true
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   gitlab:
     gitlab-shell:
       config:
         lfs:
           pureSSHProtocol: true
   ```

1. 保存文件并应用新 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_shell['lfs_pure_ssh_protocol'] = true
   ```

1. 保存文件并重启极狐GitLab 及其服务：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab-shell/config.yml`：

   ```yaml
   lfs:
      pure_ssh_protocol: true
   ```

1. 保存文件并重启 GitLab Shell：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab-shell.target

   # For systems running SysV init
   sudo service gitlab-shell restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="storage-statistics"></a>

## 存储统计信息

您可以在以下位置查看群组和项目的 LFS 对象总存储用量：

- **管理**区域
- [群组](../../api/groups.md)和[项目](../../api/projects.md) API

> [!note]
> 存储统计信息会为每个链接到它的项目分别统计每个 LFS 对象。

<a id="troubleshooting"></a>

## 故障排除

<a id="missing-lfs-objects"></a>

### 缺少 LFS 对象

在以下任一情况下，都可能出现关于缺少 LFS 对象的错误：

- 将 LFS 对象从磁盘迁移到对象存储时，出现类似以下错误消息：

  ```plaintext
  ERROR -- : Failed to transfer LFS object
  006622269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7
  with error: No such file or directory @ rb_sysopen -
  /var/opt/gitlab/gitlab-rails/shared/lfs-objects/00/66/22269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7
  ```

  （为便于阅读，已添加换行。）

- 使用 `VERBOSE=1` 参数运行
  [LFS 对象完整性检查](../raketasks/check.md#uploaded-files-integrity)时。

数据库中可能存在磁盘上不存在的 LFS 对象记录。该数据库条目可能[阻止推送该对象的新副本](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/49241)。要删除这些引用：

1. [启动 Rails 控制台](../operations/rails_console.md)。
1. 在 Rails 控制台中查询报告为缺失的对象，以返回文件路径：

   ```ruby
   lfs_object = LfsObject.find_by(oid: '006622269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7')
   lfs_object.file.path
   ```

1. 检查磁盘或对象存储中是否存在该文件：

   ```shell
   ls -al /var/opt/gitlab/gitlab-rails/shared/lfs-objects/00/66/22269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7
   ```

1. 如果文件不存在，请使用 Rails 控制台删除数据库记录：

   ```ruby
   # First delete the parent records and then destroy the record itself
   lfs_object.lfs_objects_projects.destroy_all
   lfs_object.destroy
   ```

<a id="remove-multiple-missing-lfs-objects"></a>

#### 删除多个缺失的 LFS 对象

要一次性删除对多个缺失 LFS 对象的引用：

1. 打开 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下脚本：

   ```ruby
   lfs_files_deleted = 0
   LfsObject.find_each do |lfs_file|
     next if lfs_file.file.file.exists?
     lfs_files_deleted += 1
     p "LFS file with ID #{lfs_file.id} and path #{lfs_file.file.path} is missing."
     # lfs_file.lfs_objects_projects.destroy_all     # Uncomment to delete parent records
     # lfs_file.destroy                              # Uncomment to destroy the LFS object reference
   end
   p "Count of identified/destroyed invalid references: #{lfs_files_deleted}"
   ```

此脚本会识别数据库中所有缺失的 LFS 对象。在删除任何记录之前：

- 它会先打印有关缺失文件的信息以供验证。
- 注释掉的行可防止意外删除。如果您取消注释这些行，脚本将删除
  已识别的记录。
- 脚本会自动打印最终删除的记录数以供比较。

<a id="lfs-commands-fail-on-tls-v13-server"></a>

### LFS 命令在 TLS v1.3 服务器上失败

如果您将极狐GitLab 配置为[禁用 TLS v1.2](https://gitlab.cn/docs/omnibus/settings/nginx/) 并仅启用 TLS v1.3 连接，则 LFS 操作需要 [Git LFS 客户端](https://git-lfs.com/) 2.11.0 或更高版本。如果您使用早于 2.11.0 版本的 Git LFS 客户端，极狐GitLab 会显示错误：

```plaintext
batch response: Post https://username:***@gitlab.example.com/tool/releases.git/info/lfs/objects/batch: remote error: tls: protocol version not supported
error: failed to fetch some objects from 'https://username:[MASKED]@gitlab.example.com/tool/releases.git/info/lfs'
```

在配置了 TLS v1.3 的极狐GitLab 服务器上使用极狐GitLab CI 时，您必须
[升级到极狐GitLab Runner](https://gitlab.cn/docs/runner/install/) 13.2.0
或更高版本，才能通过随附的[极狐GitLab Runner 辅助程序镜像](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#helper-image)
获得更新后的 Git LFS 客户端版本。

要检查已安装的 Git LFS 客户端版本，请运行以下命令：

```shell
git lfs version
```

<a id="connection-refused-errors"></a>

### `Connection refused` 错误

如果您推送或镜像 LFS 对象时收到类似以下错误：

- `dial tcp <IP>:443: connect: connection refused`
- `Connection refused - connect(2) for \"<target-or-proxy-IP>\" port 443`

可能是防火墙或代理规则终止了连接。

如果使用标准 Unix 工具进行连接检查或手动 Git 推送成功，则该规则可能与请求的大小有关。

<a id="error-viewing-a-pdf-file"></a>

### 查看 PDF 文件时出错

当 LFS 已配置对象存储且 `proxy_download` 设置为 `false` 时，您从 Web 浏览器预览 PDF 文件时可能会看到错误：

```plaintext
An error occurred while loading the file. Please try again later.
```

这是由于跨源资源共享（CORS）限制导致的：浏览器尝试从对象存储加载 PDF，但对象存储提供商拒绝了该请求，因为极狐GitLab 域与对象存储域不同。

要解决此问题，请配置对象存储提供商的 CORS 设置以允许极狐GitLab 域。有关更多详细信息，请参阅以下文档：

1. [AWS S3](https://repost.aws/knowledge-center/s3-configure-cors)
1. [Google Cloud Storage](https://docs.cloud.google.com/storage/docs/using-cors)
1. [Azure Storage](https://learn.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)。

<a id="fork-operation-stuck-on-forking-in-progress-message"></a>

### fork 操作卡在 `Forking in progress` 消息

如果您正在 forking 一个包含多个 LFS 文件的项目，该操作可能会卡在 `Forking in progress` 消息上。如果遇到此情况，请按照以下步骤诊断并解决问题：

1. 检查您的 [`exceptions_json.log`](../logs/_index.md#exceptions_jsonlog) 文件中是否有以下错误消息：

   ```plaintext
   "error_message": "Unable to fork project 12345 for repository
   @hashed/11/22/encoded-path -> @hashed/33/44/encoded-new-path:
   Source project has too many LFS objects"
   ```

   此错误表示您已达到 100,000 个 LFS 文件的默认限制，
   如 [议题 476693](https://gitlab.com/gitlab-org/gitlab/-/issues/476693)中所述。

1. 增加 `GITLAB_LFS_MAX_OID_TO_FETCH` 变量的值：

   1. 打开配置文件 `/etc/gitlab/gitlab.rb`。
   1. 添加或更新该变量：

      ```ruby
      gitlab_rails['env'] = {
         "GITLAB_LFS_MAX_OID_TO_FETCH" => "NEW_VALUE"
      }
      ```

      根据您的需求将 `NEW_VALUE` 替换为一个数字。

1. 应用更改。运行：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

   有关更多信息，请参见[重新配置 Linux 软件包安装](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

1. 重复 fork 操作。

> [!note]
> 对于 GitLab Helm chart，请使用 [`extraEnv`](https://gitlab.cn/docs/charts/charts/globals/#extraenv) 来配置环境变量 `GITLAB_LFS_MAX_OID_TO_FETCH`。
