---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全文件管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.7 中，此功能已 GA，并移除了 `ci_secure_files` 功能标志。

{{< /history >}}

你可以安全地存储最多 100 个文件，作为安全文件用于 CI/CD 流水线中。这些文件安全地存储在项目仓库之外，且不受版本控制。在这些文件中存储敏感信息是安全的。安全文件支持纯文本和二进制文件类型，且文件大小必须为 5 MB 或更小。

这些文件的存储位置可通过下述选项进行配置，但默认位置为：

- 对于使用 Linux 软件包的安装，位置为 `/var/opt/gitlab/gitlab-rails/shared/ci_secure_files`。
- 对于自编译安装，位置为 `/home/git/gitlab/shared/ci_secure_files`。

对于极狐GitLab Helm Chart 安装，请使用[外部对象存储](https://gitlab.cn/docs/charts/advanced/external-object-storage/#lfs-artifacts-uploads-packages-external-diffs-terraform-state-dependency-proxy-secure-files)配置。

<a id="disabling-secure-files"></a>

## 禁用安全文件

你可以在整个极狐GitLab 实例中禁用安全文件。你可能希望禁用安全文件以减少磁盘空间，或移除此功能的访问权限。要禁用安全文件，请根据你的安装类型按照以下步骤操作。先决条件：

- 你必须具有管理员权限。

**对于 Linux 软件包安装**

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['ci_secure_files_enabled'] = false
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

**对于自编译安装**

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   ci_secure_files:
     enabled: false
   ```

1. 保存文件并[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 使更改生效。

<a id="using-local-storage"></a>

## 使用本地存储

默认配置使用本地存储。要更改安全文件在本地存储的位置，请按照以下步骤操作。

**对于 Linux 软件包安装**

1. 例如，要将存储路径更改为 `/mnt/storage/ci_secure_files`，请编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['ci_secure_files_storage_path'] = "/mnt/storage/ci_secure_files"
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

**对于自编译安装**

1. 例如，要将存储路径更改为 `/mnt/storage/ci_secure_files`，请编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   ci_secure_files:
     enabled: true
     storage_path: /mnt/storage/ci_secure_files
   ```

1. 保存文件并[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 使更改生效。

<a id="using-object-storage"></a>

## 使用对象存储

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

建议不要将安全文件存储在磁盘上，而应使用[支持的对象存储方案之一](../object_storage.md#object-storage-provider-support)。此配置依赖于已配置的有效凭据。

<a id="consolidated-object-storage"></a>

### 统一对象存储

{{< history >}}

- 在极狐GitLab 17.0 中引入对统一对象存储的支持。

{{< /history >}}

建议使用对象存储的[统一形式](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

<a id="storage-specific-object-storage"></a>

### 存储特定的对象存储

以下设置在自编译安装中嵌套在 `ci_secure_files:` 下的 `object_store:` 中；在 Linux 软件包安装中以 `ci_secure_files_object_store_` 为前缀。

| 设置 | 描述 | 默认值 |
|---------|-------------|---------|
| `enabled` | 启用/禁用对象存储 | `false` |
| `remote_directory` | 存储安全文件的存储桶名称 | |
| `connection` | 下述各项连接选项 | |

<a id="s3-compatible-connection-settings"></a>

### S3 兼容的连接设置

请参阅[不同提供商的可用连接设置](../object_storage.md#configure-the-connection-settings)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，但使用所需的值：

   ```ruby
   gitlab_rails['ci_secure_files_object_store_enabled'] = true
   gitlab_rails['ci_secure_files_object_store_remote_directory'] = "ci_secure_files"
   gitlab_rails['ci_secure_files_object_store_connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'aws_access_key_id' => 'AWS_ACCESS_KEY_ID',
     'aws_secret_access_key' => 'AWS_SECRET_ACCESS_KEY'
   }
   ```

   > [!note]
   > 如果你使用 AWS IAM 配置文件，请务必省略 AWS 访问密钥和秘密访问密钥/值对：

   ```ruby
   gitlab_rails['ci_secure_files_object_store_connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'use_iam_profile' => true
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. [迁移任何现有的本地状态到对象存储](#migrate-to-object-storage)。

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   ci_secure_files:
     enabled: true
     object_store:
       enabled: true
       remote_directory: "ci_secure_files"  # 存储桶名称
       connection:
         provider: AWS  # 目前仅支持 AWS
         aws_access_key_id: AWS_ACCESS_KEY_ID
         aws_secret_access_key: AWS_SECRET_ACCESS_KEY
         region: eu-central-1
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

1. [迁移任何现有的本地状态到对象存储](#migrate-to-object-storage)。

{{< /tab >}}

{{< /tabs >}}

<a id="migrate-to-object-storage"></a>

### 迁移到对象存储

{{< history >}}

- 在极狐GitLab 16.1 中引入。

{{< /history >}}

> [!warning]
> 无法将安全文件从对象存储迁移回本地存储，因此请谨慎操作。

要将安全文件迁移至对象存储，请按照以下说明操作。

- 对于 Linux 软件包安装：

  ```shell
  sudo gitlab-rake gitlab:ci_secure_files:migrate
  ```

- 对于自编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:ci_secure_files:migrate RAILS_ENV=production
  ```