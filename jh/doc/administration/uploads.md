---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 上传管理
description: 管理上传存储。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

上传是指所有可能以单个文件形式发送到极狐GitLab 的用户数据。例如，头像和评论附件都是上传。上传是极狐GitLab 功能不可或缺的一部分，因此无法禁用。

> [!note]
> 添加到评论或描述中的附件只有在父项目或群组被删除时才会被删除。即使上传附件所在的评论或资源（如议题、合并请求、史诗）被删除，附件仍会保留在文件存储中。

<a id="using-local-storage"></a>

## 使用本地存储

这是默认配置。要更改上传文件在本地存储的位置，请根据您的安装方式使用本节中的步骤：

> [!note]
> 由于历史原因，整个实例的上传文件（例如 [网站图标](appearance.md#customize-the-favicon)）存储在基础目录中，
> 默认情况下该目录为 `uploads/-/system`。强烈建议不要在现有极狐GitLab 安装上更改
> 基础目录。

对于 Linux 软件包安装：

*上传文件默认存储在 `/var/opt/gitlab/gitlab-rails/uploads`。*

1. 要更改存储路径，例如更改为 `/mnt/storage/uploads`，请编辑
   `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['uploads_directory'] = "/mnt/storage/uploads"
   ```

   此设置仅在您未更改 `gitlab_rails['uploads_storage_path']` 目录时适用。

1. 保存文件并[重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

对于自行编译安装：

_上传文件默认存储在
`/home/git/gitlab/public/uploads`。_

1. 要更改存储路径，例如更改为 `/mnt/storage/uploads`，请编辑
   `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   uploads:
     storage_path: /mnt/storage
     base_dir: uploads
   ```

1. 保存文件并[重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。

<a id="using-object-storage"></a>

## 使用对象存储

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您不想使用安装极狐GitLab 所在的本地磁盘来存储上传文件，可以改用 AWS S3 之类的对象存储提供商。此配置依赖于已配置好的有效 AWS 凭证。

[详细了解如何将对象存储与极狐GitLab 一起使用](object_storage.md)。

<a id="object-storage-settings"></a>

### 对象存储设置

本节介绍特定于存储的配置格式。您应改用[整合的对象存储设置](object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

对于自行编译安装，以下设置嵌套在 `uploads:` 下，然后是 `object_store:`。在 Linux 软件包安装中，它们带有前缀 `uploads_object_store_`。

| 设置 | 描述 | 默认值 |
|---------|-------------|---------|
| `enabled` | 启用/禁用对象存储 | `false` |
| `remote_directory` | 存储上传文件的存储桶名称| |
| `proxy_download` | 设置为 `true` 可启用对所有所提供文件的代理。设置为 `false` 时，客户端直接从远程存储下载，从而减少极狐GitLab 服务器上的出站流量 | `false` |
| `connection` | 下文描述的各种连接选项 | |

<a id="connection-settings"></a>

#### 连接设置

请参阅[不同提供商的可用连接设置](object_storage.md#configure-the-connection-settings)。

对于 Linux 软件包安装：

_上传文件默认存储在
`/var/opt/gitlab/gitlab-rails/uploads`。_

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，将其替换为您想要的值：

   ```ruby
   gitlab_rails['uploads_object_store_enabled'] = true
   gitlab_rails['uploads_object_store_remote_directory'] = "uploads"
   gitlab_rails['uploads_object_store_connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'aws_access_key_id' => 'AWS_ACCESS_KEY_ID',
     'aws_secret_access_key' => 'AWS_SECRET_ACCESS_KEY'
   }
   ```

   如果您使用 AWS IAM 配置文件，请务必省略 AWS 访问密钥和秘密访问密钥/值对。

   ```ruby
   gitlab_rails['uploads_object_store_connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'use_iam_profile' => true
   }
   ```

1. 保存文件并[重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 使用 [`gitlab:uploads:migrate:all` Rake 任务](raketasks/uploads/migrate.md)将任何现有的本地上传文件迁移到对象存储。

对于自行编译安装：

_上传文件默认存储在
`/home/git/gitlab/public/uploads`。_

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下
   行，确保使用[与您的提供商相符的配置行](object_storage.md#configure-the-connection-settings)：

   ```yaml
   uploads:
     object_store:
       enabled: true
       remote_directory: "uploads" # The bucket name
       connection: # The lines in this block depend on your provider
         provider: AWS
         aws_access_key_id: AWS_ACCESS_KEY_ID
         aws_secret_access_key: AWS_SECRET_ACCESS_KEY
         region: eu-central-1
   ```

1. 保存文件并[重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。
1. 使用 [`gitlab:uploads:migrate:all` Rake 任务](raketasks/uploads/migrate.md)将任何现有的本地上传文件迁移到对象存储。
