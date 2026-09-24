---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 依赖项代理管理
description: Administrator's guide to managing a GitLab dependency proxy for frequently-accessed upstream artifacts, including container images and packages.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在 [极狐GitLab 专业版](https://gitlab.cn/pricing/) 11.11 中引入。
- 在 13.6 中从极狐GitLab 专业版移至极狐GitLab 基础版。

{{< /history >}}

你可以将极狐GitLab 用作依赖项代理，用于缓存频繁访问的上游制品，包括容器镜像和软件包。

这是面向管理员的文档。要了解如何使用依赖项代理，请参见：

- [容器镜像的依赖项代理](../../user/packages/dependency_proxy/_index.md) 用户指南
- [虚拟注册表](../../user/packages/virtual_registry/_index.md) 用户指南

极狐GitLab 依赖项代理：

- 默认开启。
- 可以由管理员关闭。

<a id="turn-off-the-dependency-proxy"></a>

## 关闭依赖项代理

依赖项代理默认启用。如果你是管理员，可以关闭依赖项代理。要关闭依赖项代理，请按照对应你的极狐GitLab 安装的说明进行操作。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['dependency_proxy_enabled'] = false
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

安装完成后，更新全局 `appConfig` 以关闭依赖项代理：

```yaml
global:
  appConfig:
    dependencyProxy:
      enabled: false
      bucket: gitlab-dependency-proxy
      connection:
        secret:
        key:
```

更多信息，请参见[使用 Globals 配置 Charts](https://gitlab.cn/docs/charts/charts/globals/#configure-appconfig-settings)。

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

1. 安装完成后，在 `config/gitlab.yml` 中配置 `dependency_proxy` 部分。将 `enabled` 设置为 `false` 以关闭依赖项代理：

   ```yaml
   dependency_proxy:
     enabled: false
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

### 多节点极狐GitLab 安装

为每个 Web 和 Sidekiq 节点遵循 Linux 软件包安装的步骤。

<a id="turn-on-the-dependency-proxy"></a>

## 开启依赖项代理

依赖项代理默认开启，但可以被管理员关闭。如需手动关闭，请按照[关闭依赖项代理](#关闭依赖项代理)中的说明操作。

<a id="changing-the-storage-path"></a>

## 更改存储路径

默认情况下，依赖项代理文件存储在本地，但你可以更改默认的本地位置，甚至使用对象存储。

<a id="changing-the-local-storage-path"></a>

### 更改本地存储路径

Linux 软件包安装的依赖项代理文件存储在 `/var/opt/gitlab/gitlab-rails/shared/dependency_proxy/` 下，源代码安装的则存储在 `shared/dependency_proxy/`（相对于 Git 主目录）。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['dependency_proxy_storage_path'] = "/mnt/dependency_proxy"
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

1. 编辑 `config/gitlab.yml` 中的 `dependency_proxy` 部分：

   ```yaml
   dependency_proxy:
     enabled: true
     storage_path: shared/dependency_proxy
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="using-object-storage"></a>

### 使用对象存储

不再依赖本地存储，你可以使用[统一对象存储设置](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。本节描述的是早期配置格式。[迁移步骤仍然适用](#将本地依赖项代理-blob-和清单迁移到对象存储)。

[进一步了解如何在极狐GitLab 中使用对象存储](../object_storage.md)。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行（必要时取消注释）：

   ```ruby
   gitlab_rails['dependency_proxy_enabled'] = true
   gitlab_rails['dependency_proxy_storage_path'] = "/var/opt/gitlab/gitlab-rails/shared/dependency_proxy"
   gitlab_rails['dependency_proxy_object_store_enabled'] = true
   gitlab_rails['dependency_proxy_object_store_remote_directory'] = "dependency_proxy" # 存储桶名称。
   gitlab_rails['dependency_proxy_object_store_proxy_download'] = false        # 通过极狐GitLab 进行所有下载，而不是使用对象存储的重定向。
   gitlab_rails['dependency_proxy_object_store_connection'] = {
     ##
     ## 如果提供商是 AWS S3，请取消以下行的注释
     ##
     #'provider' => 'AWS',
     #'region' => 'eu-west-1',
     #'aws_access_key_id' => 'AWS_ACCESS_KEY_ID',
     #'aws_secret_access_key' => 'AWS_SECRET_ACCESS_KEY',
     ##
     ## 如果提供商不是 AWS（而是 S3 兼容的），请取消以下行的注释
     ##
     #'host' => 's3.amazonaws.com',
     #'aws_signature_version' => 4             # 用于创建签名 URL。如果提供商不支持 v4，则设置为 2。
     #'endpoint' => 'https://s3.amazonaws.com' # 适用于 S3 兼容服务，例如 DigitalOcean Spaces。
     #'path_style' => false                    # 如果为 true，则使用 'host/bucket_name/object' 而不是 'bucket_name.host/object'。
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

1. 编辑 `config/gitlab.yml` 中的 `dependency_proxy` 部分（必要时取消注释）：

   ```yaml
   dependency_proxy:
     enabled: true
     ##
     ## 构建依赖项代理的存储位置（默认：shared/dependency_proxy）。
     ##
     # storage_path: shared/dependency_proxy
     object_store:
       enabled: false
       remote_directory: dependency_proxy  # 存储桶名称。
       #  proxy_download: false     # 通过极狐GitLab 进行所有下载，而不是使用对象存储的重定向。
       connection:
       ##
       ## 如果提供商是 AWS S3，请使用以下配置
       ##
         provider: AWS
         region: us-east-1
         aws_access_key_id: AWS_ACCESS_KEY_ID
         aws_secret_access_key: AWS_SECRET_ACCESS_KEY
         ##
         ## 如果提供商不是 AWS（而是 S3 兼容的），请注释掉前面的 4 行，并使用以下配置：
         ##
         #  host: 's3.amazonaws.com'             # 默认：s3.amazonaws.com。
         #  aws_signature_version: 4             # 用于创建签名 URL。如果提供商不支持 v4，则设置为 2。
         #  endpoint: 'https://s3.amazonaws.com' # 适用于 S3 兼容服务，例如 DigitalOcean Spaces。
         #  path_style: false                    # 如果为 true，则使用 'host/bucket_name/object' 而不是 'bucket_name.host/object'。
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="migrate-local-dependency-proxy-blobs-and-manifests-to-object-storage"></a>

#### 将本地依赖项代理 blob 和清单迁移到对象存储

在[配置对象存储](#使用对象存储)后，使用以下任务将现有的依赖项代理 blob 和清单从本地存储迁移到远程存储。迁移在后台工作进行，无需停机。

- 对于 Linux 软件包安装：

  ```shell
  sudo gitlab-rake "gitlab:dependency_proxy:migrate"
  ```

- 对于自编译安装：

  ```shell
  RAILS_ENV=production sudo -u git -H bundle exec rake gitlab:dependency_proxy:migrate
  ```

你可以可选地跟踪进度并验证所有依赖项代理 blob 和清单是否成功迁移，使用 [PostgreSQL 控制台](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database)：

- `sudo gitlab-rails dbconsole` 适用于 14.1 及更早版本的 Linux 软件包安装。
- `sudo gitlab-rails dbconsole --database main` 适用于 14.2 及更高版本的 Linux 软件包安装。
- `sudo -u git -H psql -d gitlabhq_production` 适用于自编译实例。

验证 `objectstg`（其中 `file_store = '2'`）拥有所有依赖项代理 blob 和清单的计数，执行以下查询：

```shell
gitlabhq_production=# SELECT count(*) AS total, sum(case when file_store = '1' then 1 else 0 end) AS filesystem, sum(case when file_store = '2' then 1 else 0 end) AS objectstg FROM dependency_proxy_blobs;

total | filesystem | objectstg
------+------------+-----------
 22   |          0 |        22

gitlabhq_production=# SELECT count(*) AS total, sum(case when file_store = '1' then 1 else 0 end) AS filesystem, sum(case when file_store = '2' then 1 else 0 end) AS objectstg FROM dependency_proxy_manifests;

total | filesystem | objectstg
------+------------+-----------
 10   |          0 |        10
```

验证 `dependency_proxy` 文件夹中磁盘上无文件：

```shell
sudo find /var/opt/gitlab/gitlab-rails/shared/dependency_proxy -type f | grep -v tmp | wc -l
```

<a id="changing-the-jwt-expiration"></a>

## 更改 JWT 过期时间

依赖项代理遵循 [Docker v2 令牌认证流程](https://distribution.github.io/distribution/spec/auth/token/)，向客户端颁发用于拉取请求的 JWT。令牌过期时间可通过应用程序设置 `container_registry_token_expire_delay` 进行配置。可以从 rails 控制台更改它：

```ruby
# 将 JWT 过期时间更新为 30 分钟
ApplicationSetting.update(container_registry_token_expire_delay: 30)
```

默认过期时间以及在 JihuLab.com 上的过期时间为 15 分钟。

<a id="using-the-dependency-proxy-behind-a-proxy"></a>

## 在代理后使用依赖项代理

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_workhorse['env'] = {
     "http_proxy" => "http://USERNAME:PASSWORD@example.com:8080",
     "https_proxy" => "http://USERNAME:PASSWORD@example.com:8080"
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。