---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure Git LFS for GitLab Self-Managed.
title: 极狐GitLab Git 大文件存储（LFS）管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 Git 大文件存储（LFS）来在 Git 仓库中存储大文件，同时不增加仓库大小或影响性能。你可以启用或禁用 LFS，为 LFS 对象配置本地或远程存储，并在存储类型之间迁移对象。

有关用户文档，请参见 [Git 大文件存储（LFS）](../../topics/git/lfs/_index.md)。

前提条件：

- 用户必须安装 [Git LFS 客户端](https://git-lfs.com/) 1.1.0 及更高版本，或 1.0.2。

<a id="enable-or-disable-lfs"></a>

## 启用或禁用 LFS

LFS 默认启用。要禁用它：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # 改为 true 以启用 lfs - 如果未定义，则默认启用
   gitlab_rails['lfs_enabled'] = false
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

1. 导出 Helm 值：

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

1. 保存文件并应用新的值：

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
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="change-local-storage-path"></a>

## 更改本地存储路径

Git LFS 对象可能很大。默认情况下，它们存储在安装了极狐GitLab 的服务器上。

> [!note]
> 对于 Docker 安装，你可以更改数据挂载的路径。
> 对于 Helm Chart，请使用
> [对象存储](https://gitlab.cn/docs/charts/advanced/external-object-storage/)。

要更改默认的本地存储路径位置：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # 默认为 /var/opt/gitlab/gitlab-rails/shared/lfs-objects。
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
   # 默认为 /home/git/gitlab/shared/lfs-objects。
   production: &base
     lfs:
       storage_path: /mnt/storage/lfs-objects
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

<a id="storing-lfs-objects-in-remote-object-storage"></a>

## 在远程对象存储中存储 LFS 对象

你可以将 LFS 对象存储在远程对象存储中。这可以减少对本地磁盘的读写，并显著释放磁盘空间。

你应该使用
[统一对象存储设置](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

<a id="migrating-to-object-storage"></a>

### 迁移到对象存储

你可以将 LFS 对象从本地存储迁移到对象存储。处理过程在后台完成，无需停机。

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
   sudo docker exec -t <容器名称> gitlab-rake gitlab:lfs:migrate
   ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   ```shell
   sudo -u git -H bundle exec rake gitlab:lfs:migrate RAILS_ENV=production
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 可选。使用 PostgreSQL 控制台跟踪进度并验证所有 LFS 对象是否已成功迁移。
   1. 打开 PostgreSQL 控制台：

      {{< tabs >}}

      {{< tab title="Linux 软件包（Omnibus）" >}}

      ```shell
      sudo gitlab-psql
      ```

      {{< /tab >}}

      {{< tab title="Docker" >}}

      ```shell
      sudo docker exec -it <容器名称> /bin/bash
      gitlab-psql
      ```

      {{< /tab >}}

      {{< tab title="自行编译（源代码）" >}}

      ```shell
      sudo -u git -H psql -d gitlabhq_production
      ```

      {{< /tab >}}

      {{< /tabs >}}

   1. 使用以下 SQL 查询验证所有 LFS 文件均已迁移到对象存储。`objectstg` 的数量应与 `total` 相同：

      ```shell
      gitlabhq_production=# SELECT count(*) AS total, sum(case when file_store = '1' then 1 else 0 end) AS filesystem, sum(case when file_store = '2' then 1 else 0 end) AS objectstg FROM lfs_objects;

      total | filesystem | objectstg
      ------+------------+-----------
       2409 |          0 |      2409
      ```

1. 验证磁盘上的 `lfs-objects` 目录中没有文件：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   sudo find /var/opt/gitlab/gitlab-rails/shared/lfs-objects -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   假设你将 `/var/opt/gitlab` 挂载到 `/srv/gitlab`：

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
> 对于 Helm Chart，你应该使用
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
   sudo docker exec -t <容器名称> gitlab-rake gitlab:lfs:migrate_to_local
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
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="pure-ssh-transfer-protocol"></a>

## 纯 SSH 传输协议

{{< history >}}

- 在极狐GitLab 17.2 引入。
- 在极狐GitLab 17.3 针对 Helm Chart（Kubernetes）引入。

{{< /history >}}

> [!warning]
> 此功能受 [一个已知问题](https://github.com/git-lfs/git-lfs/issues/5880) 影响
> （已在 [Git LFS 3.6.0](https://github.com/git-lfs/git-lfs/blob/main/CHANGELOG.md#360-20-november-2024) 中解决）。
> 如果你使用纯 SSH 协议克隆包含多个 Git LFS 对象的仓库，
> 客户端可能会因 `nil` 指针引用而崩溃。

[`git-lfs` 3.0.0](https://github.com/git-lfs/git-lfs/blob/main/CHANGELOG.md#300-24-sep-2021)
发布了对使用 SSH 作为传输协议而非 HTTP 的支持。
SSH 由 `git-lfs` 命令行工具透明处理。

当启用纯 SSH 协议支持且 `git` 配置为使用 SSH 时，
所有 LFS 操作都通过 SSH 进行。例如，当 Git 远程地址为
`git@gitlab.com:gitlab-org/gitlab.git` 时。你无法将 `git` 和 `git-lfs`
配置为使用不同的协议。从 3.0 版本开始，`git-lfs` 首先尝试使用纯
SSH 协议，如果不支持或不可用，则回退到 HTTP。

前提条件：

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

{{< tab title="Helm Chart（Kubernetes）" >}}

1. 导出 Helm 值：

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

1. 保存文件并应用新的值：

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
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab-shell.target

   # 对于使用 SysV init 的系统
   sudo service gitlab-shell restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="storage-statistics"></a>

## 存储统计

你可以在以下位置查看群组和项目为 LFS 对象使用的总存储空间：

- **管理员** 区域
- [群组](../../api/groups.md) 和 [项目](../../api/projects.md) API

> [!note]
> 存储统计会计算每个链接到该对象的项目中的每个 LFS 对象。

<a id="troubleshooting"></a>

## 故障排除

<a id="missing-lfs-objects"></a>

### 缺少 LFS 对象

在以下任一情况下，可能会发生关于缺少 LFS 对象的错误：

- 从磁盘迁移 LFS 对象到对象存储时，错误消息如下：

  ```plaintext
  ERROR -- : 未能传输 LFS 对象
  006622269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7
  错误：没有这样的文件或目录 @ rb_sysopen -
  /var/opt/gitlab/gitlab-rails/shared/lfs-objects/00/66/22269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7
  ```

   （为便于阅读，已添加换行。）

- 运行
  [LFS 对象完整性检查](../raketasks/check.md#uploaded-files-integrity)
  并带有 `VERBOSE=1` 参数时。

数据库可能存在不在磁盘上的 LFS 对象的记录。该数据库条目可能
[阻止推送该对象的新副本](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/49241)。
要删除这些引用：

1. [启动 Rails 控制台](../operations/rails_console.md)。
1. 在 Rails 控制台中查询报告为缺少的对象，以返回文件路径：

   ```ruby
   lfs_object = LfsObject.find_by(oid: '006622269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7')
   lfs_object.file.path
   ```

1. 检查磁盘或对象存储上是否存在：

   ```shell
   ls -al /var/opt/gitlab/gitlab-rails/shared/lfs-objects/00/66/22269c61b41bf14a22bbe0e43be3acf86a4a446afb4250c3794ea47541a7
   ```

1. 如果文件不存在，使用 Rails 控制台删除数据库记录：

   ```ruby
   # 首先删除父记录，然后销毁记录本身
   lfs_object.lfs_objects_projects.destroy_all
   lfs_object.destroy
   ```

<a id="remove-multiple-missing-lfs-objects"></a>

#### 删除多个缺失的 LFS 对象

要一次性删除对多个缺失的 LFS 对象的引用：

1. 打开 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下脚本：

   ```ruby
   lfs_files_deleted = 0
   LfsObject.find_each do |lfs_file|
     next if lfs_file.file.file.exists?
     lfs_files_deleted += 1
     p "LFS 文件 ID #{lfs_file.id}，路径 #{lfs_file.file.path} 缺失。"
     # lfs_file.lfs_objects_projects.destroy_all     # 取消注释以删除父记录
     # lfs_file.destroy                              # 取消注释以销毁 LFS 对象引用
   end
   p "已识别/已销毁的无效引用数量：#{lfs_files_deleted}"
   ```

此脚本识别数据库中所有缺失的 LFS 对象。在删除任何记录之前：

- 首先打印有关缺失文件的信息以供验证。
- 被注释的行可防止意外删除。如果取消注释，脚本将删除
  已识别的记录。
- 脚本会自动打印最终删除的记录计数以供比较。

<a id="lfs-commands-fail-on-tls-v1-3-server"></a>

### LFS 命令在 TLS v1.3 服务器上失败

如果你配置极狐GitLab [禁用 TLS v1.2](https://gitlab.cn/docs/omnibus/settings/nginx/) 并仅启用 TLS v1.3 连接，则 LFS 操作需要
[Git LFS 客户端](https://git-lfs.com/) 版本 2.11.0 或更高。如果你使用
早于 2.11.0 版本的 Git LFS 客户端，极狐GitLab 会显示错误：

```plaintext
batch response: Post https://username:***@gitlab.example.com/tool/releases.git/info/lfs/objects/batch: remote error: tls: protocol version not supported
error: 无法从 'https://username:[MASKED]@gitlab.example.com/tool/releases.git/info/lfs' 获取某些对象
```

在通过配置了 TLS v1.3 的极狐GitLab 服务器使用极狐GitLab CI 时，你必须
[升级到 GitLab Runner](https://gitlab.cn/docs/runner/install/) 13.2.0
或更高版本，以接收更新的 Git LFS 客户端版本，该版本随附
[GitLab Runner 辅助镜像](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#helper-image)。

要检查已安装的 Git LFS 客户端版本，请运行以下命令：

```shell
git lfs version
```

<a id="connection-refused-errors"></a>

### `Connection refused` 错误

如果你推送或镜像 LFS 对象时收到类似如下的错误：

- `dial tcp <IP>:443: connect: connection refused`
- `Connection refused - connect(2) for \"<目标或代理IP>\" port 443`

则防火墙或代理规则可能正在终止连接。

如果使用标准 Unix 工具或手动 Git 推送进行检查时连接成功，
则该规则可能与请求的大小有关。

<a id="error-viewing-a-pdf-file"></a>

### 查看 PDF 文件时出错

当 LFS 配置了对象存储且 `proxy_download` 设置为
`false` 时，你在 Web 浏览器中预览 PDF 文件时可能会看到错误：

```plaintext
加载文件时出错。请稍后重试。
```

这是因为跨域资源共享（CORS）限制：
浏览器尝试从对象存储加载 PDF，但对象
存储提供商拒绝了请求，因为极狐GitLab 域与
对象存储域不同。

要解决此问题，请配置对象存储提供商的 CORS
设置以允许极狐GitLab 域。有关更多详细信息，请参阅以下文档：

1. [AWS S3](https://repost.aws/knowledge-center/s3-configure-cors)
1. [Google Cloud Storage](https://cloud.google.com/storage/docs/using-cors)
1. [Azure Storage](https://learn.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services).

<a id="fork-operation-stuck-on-forking-in-progress-message"></a>

### Fork 操作卡在“正在 Fork”消息

如果你正 Fork 一个包含多个 LFS 文件的项目，操作可能会卡在“正在 Fork”消息。
如果遇到此情况，请按照以下步骤诊断并解决问题：

1. 检查你的 [`exceptions_json.log`](../logs/_index.md#exceptions_jsonlog) 文件是否存在以下错误消息：

   ```plaintext
   "error_message": "无法 Fork 项目 12345 的仓库
   @hashed/11/22/encoded-path -> @hashed/33/44/encoded-new-path:
   源项目有太多 LFS 对象"
   ```

   此错误表示你已达到默认的 100,000 个 LFS 文件限制，
   如 [issue 476693](https://gitlab.com/gitlab-org/gitlab/-/issues/476693) 中所述。

1. 增加 `GITLAB_LFS_MAX_OID_TO_FETCH` 变量的值：

   1. 打开配置文件 `/etc/gitlab/gitlab.rb`。
   1. 添加或更新变量：

      ```ruby
      gitlab_rails['env'] = {
         "GITLAB_LFS_MAX_OID_TO_FETCH" => "新值"
      }
      ```

      将 `新值` 替换为基于你需求的数字。

1. 应用更改。运行：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

   有关更多信息，请参见 [重新配置 Linux 软件包安装](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

1. 重复 Fork 操作。

> [!note]
> 对于极狐GitLab Helm Chart，使用 [`extraEnv`](https://gitlab.cn/docs/charts/charts/globals/#extraenv) 来配置环境变量 `GITLAB_LFS_MAX_OID_TO_FETCH`。