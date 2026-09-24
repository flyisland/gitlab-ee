---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Terraform 状态管理
description: 管理 Terraform 状态存储。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 可作为 [Terraform](../user/infrastructure/_index.md) 状态文件的后端。这些文件在存储前会被加密。该功能默认启用。

这些文件的存储位置默认为：

- 对于 Linux 软件包安装，存储在 `/var/opt/gitlab/gitlab-rails/shared/terraform_state`。
- 对于自行编译安装，存储在 `/home/git/gitlab/shared/terraform_state`。

可以使用下文描述的选项配置这些位置。

对于 [极狐GitLab Helm Chart](https://gitlab.cn/docs/charts/) 安装，请使用 [外部对象存储](https://gitlab.cn/docs/charts/advanced/external-object-storage/#lfs-artifacts-uploads-packages-external-diffs-terraform-state-dependency-proxy-secure-files) 配置。

<a id="disabling-terraform-state"></a>

## 禁用 Terraform 状态

你可以在整个实例中禁用 Terraform 状态。你可能希望禁用 Terraform 以减少磁盘空间占用，或者因为你的实例不使用 Terraform。

当 Terraform 状态管理被禁用时：

- 在左侧边栏中，你无法选择 **运维** > **Terraform 状态**。
- 任何访问 Terraform 状态的 CI/CD 作业都会失败，并显示以下错误：

  ```shell
  Error refreshing state: HTTP remote state endpoint invalid auth
  ```

要根据你的安装方式禁用 Terraform 管理，请按照以下步骤操作。

前提条件：

- 你必须是管理员。

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['terraform_state_enabled'] = false
   ```

1. 保存文件并 [重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

对于自行编译安装：

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   terraform_state:
     enabled: false
   ```

1. 保存文件并 [重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。

<a id="using-local-storage"></a>

## 使用本地存储

默认配置使用本地存储。要更改 Terraform 状态文件在本地存储的位置，请按照以下步骤操作。

对于 Linux 软件包安装：

1. 例如，要将存储路径更改为 `/mnt/storage/terraform_state`，请编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['terraform_state_storage_path'] = "/mnt/storage/terraform_state"
   ```

1. 保存文件并 [重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

对于自行编译安装：

1. 例如，要将存储路径更改为 `/mnt/storage/terraform_state`，请编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   terraform_state:
     enabled: true
     storage_path: /mnt/storage/terraform_state
   ```

1. 保存文件并 [重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。

<a id="using-object-storage"></a>

## 使用对象存储

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

我们不建议将 Terraform 状态文件存储在磁盘上，而是推荐使用 [受支持的对象存储选项之一](object_storage.md#object-storage-provider-support)。此配置依赖于已配置的有效凭据。

[深入了解如何在极狐GitLab 中使用对象存储](object_storage.md)。

<a id="object-storage-settings"></a>

### 对象存储设置

以下设置：

- 在 Linux 软件包安装中，以 `terraform_state_object_store_` 为前缀。
- 在自行编译安装中，嵌套在 `terraform_state:` 下，然后是 `object_store:` 下。

| 设置 | 描述 | 默认值 |
|---------|-------------|---------|
| `enabled` | 启用/禁用对象存储 | `false` |
| `remote_directory` | 存储 Terraform 状态文件的桶名称 | |
| `connection` | 下文描述的各种连接选项 | |

<a id="migrate-to-object-storage"></a>

### 迁移至对象存储

> [!warning]
> 目前无法将 Terraform 状态文件从对象存储迁移回本地存储，请谨慎操作。

要将 Terraform 状态文件迁移到对象存储：

- 对于 Linux 软件包安装：

  ```shell
  gitlab-rake gitlab:terraform_states:migrate
  ```

- 对于自行编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:terraform_states:migrate RAILS_ENV=production
  ```

你可以选择使用 [PostgreSQL 控制台](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database) 跟踪进度并验证所有 Terraform 状态文件是否已成功迁移：

- 对于 Linux 软件包安装：`sudo gitlab-rails dbconsole --database main`。
- 对于自行编译安装：`sudo -u git -H psql -d gitlabhq_production`。

验证下面的 `objectstg`（其中 `file_store=2`）是否包含了所有状态的数量：

```shell
gitlabhq_production=# SELECT count(*) AS total, sum(case when file_store = '1' then 1 else 0 end) AS filesystem, sum(case when file_store = '2' then 1 else 0 end) AS objectstg FROM terraform_state_versions;

total | filesystem | objectstg
------+------------+-----------
   15 |          0 |      15
```

验证磁盘上 `terraform_state` 文件夹中没有文件：

```shell
sudo find /var/opt/gitlab/gitlab-rails/shared/terraform_state -type f | grep -v tmp | wc -l
```

<a id="s3-compatible-connection-settings"></a>

### S3 兼容连接设置

你应该使用 [统一的对象存储设置](object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。本节描述早期的配置格式。

查看 [不同提供商可用的连接设置](object_storage.md#configure-the-connection-settings)。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行；替换为你想要的值：

   ```ruby
   gitlab_rails['terraform_state_object_store_enabled'] = true
   gitlab_rails['terraform_state_object_store_remote_directory'] = "terraform"
   gitlab_rails['terraform_state_object_store_connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'aws_access_key_id' => 'AWS_ACCESS_KEY_ID',
     'aws_secret_access_key' => 'AWS_SECRET_ACCESS_KEY'
   }
   ```

   > [!note]
   > 如果你正在使用 AWS IAM 配置文件，请务必省略 AWS 访问密钥和秘密访问密钥/值对。

   ```ruby
   gitlab_rails['terraform_state_object_store_connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'use_iam_profile' => true
   }
   ```

1. 保存文件并 [重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. [将所有现有的本地状态迁移到对象存储](#migrate-to-object-storage)

{{< /tab >}}

{{< tab title="自行编译（源码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   terraform_state:
     enabled: true
     object_store:
       enabled: true
       remote_directory: "terraform" # 桶名称
       connection:
         provider: AWS # 目前仅支持 AWS
         aws_access_key_id: AWS_ACCESS_KEY_ID
         aws_secret_access_key: AWS_SECRET_ACCESS_KEY
         region: eu-central-1
   ```

1. 保存文件并 [重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。
1. [将所有现有的本地状态迁移到对象存储](#migrate-to-object-storage)

{{< /tab >}}

{{< /tabs >}}

<a id="find-a-terraform-state-file-path"></a>

### 查找 Terraform 状态文件路径

Terraform 状态文件存储在相关项目的哈希目录路径中。

路径格式为 `/var/opt/gitlab/gitlab-rails/shared/terraform_state/<path>/<to>/<projectHashDirectory>/<UUID>/0.tfstate`，其中 [UUID](https://gitlab.com/gitlab-org/gitlab/-/blob/dcc47a95c7e1664cb15bef9a70f2a4eefa9bd99a/app/models/terraform/state.rb#L33) 是随机定义的。

要查找状态文件路径：

1. 将 `get-terraform-path` 添加到你的 shell 中：

   ```shell
   get-terraform-path() {
       PROJECT_HASH=$(echo -n $1 | openssl dgst -sha256 | sed 's/^.* //')
       echo "${PROJECT_HASH:0:2}/${PROJECT_HASH:2:2}/${PROJECT_HASH}"
   }
   ```

1. 运行 `get-terraform-path <project_id>`。

   ```shell
   $ get-terraform-path 650
   20/99/2099a9b5f777e242d1f9e19d27e232cc71e2fa7964fc988a319fce5671ca7f73
   ```

此时会显示相对路径。

<a id="restoring-terraform-state-files-from-backups"></a>

## 从备份恢复 Terraform 状态文件

要从备份恢复 Terraform 状态文件，你必须能够访问加密的状态文件以及极狐GitLab 数据库。

<a id="database-tables"></a>

### 数据库表

以下数据库表有助于将 S3 路径追溯到特定项目：

- `terraform_states`：包含基本状态信息，包括每个状态的通用唯一 ID (UUID)。

<a id="file-structure-and-path-composition"></a>

### 文件结构和路径构成

状态文件存储在特定的目录结构中，其中：

- 路径的前三段是从项目 ID 的 SHA-256 哈希值派生出来的。
- 每个状态都有一个 UUID 存储于 `terraform_states` 数据库表中，并构成路径的一部分。

例如，对于一个项目，如果：

- 项目 ID 为 `12345`
- 状态 UUID 为 `example-uuid`

假设 `12345` 的 SHA-256 哈希值为 `5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5`，那么文件夹结构将是：

```plaintext
terraform/                                                                 <- 已配置的 Terraform 存储目录
├─ 59/                                                                     <- 项目 ID 哈希值的第一和第二字符
|  ├─ 94/                                                                  <- 项目 ID 哈希值的第三和第四字符
|  |  ├─ 5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5/ <- 完整的项目 ID 哈希值
|  |  |  ├─ example-uuid/                                                  <- 状态 UUID
|  |  |  |  ├─ 1.tf                                                        <- 单独的状态版本
|  |  |  |  ├─ 2.tf
|  |  |  |  ├─ 3.tf
```

<a id="decryption-process"></a>

### 解密过程

状态文件使用 Lockbox 加密，解密时需要以下信息：

- `db_key_base` 应用程序密钥
- 项目 ID

加密密钥由 `db_key_base` 和项目 ID 共同派生。如果你无法访问 `db_key_base`，则无法解密。

要了解如何手动解密文件，请参阅 [Lockbox](https://github.com/ankane/lockbox) 的文档。

要查看加密密钥的生成过程，请参阅 [状态上传器代码](https://gitlab.com/gitlab-org/gitlab/-/blob/e0137111fbbd28316f38da30075aba641e702b98/app/uploaders/terraform/state_uploader.rb#L43)。