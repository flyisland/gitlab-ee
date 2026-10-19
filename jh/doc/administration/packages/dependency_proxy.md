---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 依赖代理管理
description: 管理员指南：管理极狐GitLab 依赖代理，以缓存频繁访问的上游产物，包括容器镜像和软件包。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将极狐GitLab 用作依赖代理，以缓存频繁访问的上游产物，包括容器镜像和软件包。

本文档是管理文档。要了解如何使用依赖代理，请参阅：

- [容器镜像依赖代理](../../user/packages/dependency_proxy/_index.md)用户指南
- [虚拟仓库](../../user/packages/virtual_registry/_index.md)用户指南

极狐GitLab 依赖代理：

- 默认开启。
- 可由管理员关闭。

<a id="turn-off-the-dependency-proxy"></a>

## 关闭依赖代理

依赖代理默认启用。如果您是管理员，可以关闭依赖代理。要关闭依赖代理，请按照与您的极狐GitLab 安装方式对应的说明操作。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['dependency_proxy_enabled'] = false
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

安装完成后，更新全局 `appConfig` 以关闭依赖代理：

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

更多信息，请参阅[使用全局值配置 Charts](https://gitlab.cn/docs/charts/charts/globals/#configure-appconfig-settings)。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 安装完成后，在 `config/gitlab.yml`中配置 `dependency_proxy` 部分。将 `enabled` 设置为 `false` 以关闭依赖代理：

   ```yaml
   dependency_proxy:
     enabled: false
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="multi-node-gitlab-installations"></a>

### 多节点极狐GitLab 安装

对每个 Web 和 Sidekiq 节点，按照 Linux 软件包安装的步骤操作。

<a id="turn-on-the-dependency-proxy"></a>

## 开启依赖代理

依赖代理默认开启，但可由管理员关闭。要手动关闭它，请按照[关闭依赖代理](#turn-off-the-dependency-proxy)中的说明操作。

<a id="changing-the-storage-path"></a>

## 更改存储路径

默认情况下，依赖代理文件存储在本地，但您可以更改默认的本地位置，甚至使用对象存储。

<a id="changing-the-local-storage-path"></a>

### 更改本地存储路径

Linux 软件包安装的依赖代理文件存储在 `/var/opt/gitlab/gitlab-rails/shared/dependency_proxy/` 下，源码安装的依赖代理文件存储在 `shared/dependency_proxy/` 下（相对于 Git 主目录）。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['dependency_proxy_storage_path'] = "/mnt/dependency_proxy"
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml`中的 `dependency_proxy` 部分：

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

您可以使用[整合对象存储设置](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)，而不必依赖本地存储。本节介绍的是较早的配置格式。[迁移步骤仍然适用](#migrate-local-dependency-proxy-blobs-and-manifests-to-object-storage)。

[详细了解如何在极狐GitLab 中使用对象存储](../object_storage.md)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行（必要时取消注释）：

   ```ruby
   gitlab_rails['dependency_proxy_enabled'] = true
   gitlab_rails['dependency_proxy_storage_path'] = "/var/opt/gitlab/gitlab-rails/shared/dependency_proxy"
   gitlab_rails['dependency_proxy_object_store_enabled'] = true
   gitlab_rails['dependency_proxy_object_store_remote_directory'] = "dependency_proxy" # The bucket name.
   gitlab_rails['dependency_proxy_object_store_proxy_download'] = false        # Passthrough all downloads via GitLab instead of using Redirects to Object Storage.
   gitlab_rails['dependency_proxy_object_store_connection'] = {
     ##
     ## If the provider is AWS S3, uncomment the following
     ##
     #'provider' => 'AWS',
     #'region' => 'eu-west-1',
     #'aws_access_key_id' => 'AWS_ACCESS_KEY_ID',
     #'aws_secret_access_key' => 'AWS_SECRET_ACCESS_KEY',
     ##
     ## If the provider is other than AWS (an S3-compatible one), uncomment the following
     ##
     #'host' => 's3.amazonaws.com',
     #'aws_signature_version' => 4             # For creation of signed URLs. Set to 2 if provider does not support v4.
     #'endpoint' => 'https://s3.amazonaws.com' # Useful for S3-compliant services such as DigitalOcean Spaces.
     #'path_style' => false                    # If true, use 'host/bucket_name/object' instead of 'bucket_name.host/object'.
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml`中的 `dependency_proxy` 部分（必要时取消注释）：

   ```yaml
   dependency_proxy:
     enabled: true
     ##
     ## The location where build dependency_proxy are stored (default: shared/dependency_proxy).
     ##
     # storage_path: shared/dependency_proxy
     object_store:
       enabled: false
       remote_directory: dependency_proxy  # The bucket name.
       #  proxy_download: false     # Passthrough all downloads via GitLab instead of using Redirects to Object Storage.
       connection:
       ##
       ## If the provider is AWS S3, use the following
       ##
         provider: AWS
         region: us-east-1
         aws_access_key_id: AWS_ACCESS_KEY_ID
         aws_secret_access_key: AWS_SECRET_ACCESS_KEY
         ##
         ## If the provider is other than AWS (an S3-compatible one), comment out the previous 4 lines and use the following instead:
         ##
         #  host: 's3.amazonaws.com'             # default: s3.amazonaws.com.
         #  aws_signature_version: 4             # For creation of signed URLs. Set to 2 if provider does not support v4.
         #  endpoint: 'https://s3.amazonaws.com' # Useful for S3-compliant services such as DigitalOcean Spaces.
         #  path_style: false                    # If true, use 'host/bucket_name/object' instead of 'bucket_name.host/object'.
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="migrate-local-dependency-proxy-blobs-and-manifests-to-object-storage"></a>

#### 将本地依赖代理 blob 和清单迁移到对象存储

在[配置对象存储](#using-object-storage)后，使用以下任务将现有的依赖代理 blob 和清单从本地存储迁移到远程存储。处理在后台工作进程中完成，无需停机。

- 对于 Linux 软件包安装：

  ```shell
  sudo gitlab-rake "gitlab:dependency_proxy:migrate"
  ```

- 对于自编译安装：

  ```shell
  RAILS_ENV=production sudo -u git -H bundle exec rake gitlab:dependency_proxy:migrate
  ```

您可以选择使用 [PostgreSQL 控制台](https://gitlab.cn/docs/omnibus/settings/database/#connecting-to-the-postgresql-database)跟踪进度，并验证所有依赖代理 blob 和清单是否已成功迁移：

- Linux 软件包安装使用 `sudo gitlab-rails dbconsole --database main`。
- 自编译实例使用 `sudo -u git -H psql -d gitlabhq_production`。

针对以下查询，验证 `objectstg`（其中 `file_store = '2'`）是否包含所有依赖代理 blob 和清单的数量：

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

验证 `dependency_proxy` 文件夹中的磁盘上没有文件：

```shell
sudo find /var/opt/gitlab/gitlab-rails/shared/dependency_proxy -type f | grep -v tmp | wc -l
```

<a id="changing-the-jwt-expiration"></a>

## 更改 JWT 过期时间

依赖代理遵循 [Docker v2 令牌身份验证流程](https://distribution.github.io/distribution/spec/auth/token/)，向客户端签发一个 JWT 用于拉取请求。令牌过期时间可通过应用设置 `container_registry_token_expire_delay` 进行配置。可以在 Rails 控制台中更改：

```ruby
# update the JWT expiration to 30 minutes
ApplicationSetting.update(container_registry_token_expire_delay: 30)
```

默认过期时间以及 JihuLab.com 上的过期时间为 15 分钟。

<a id="using-the-dependency-proxy-behind-a-proxy"></a>

## 在代理后面使用依赖代理

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_workhorse['env'] = {
     "http_proxy" => "http://USERNAME:PASSWORD@example.com:8080",
     "https_proxy" => "http://USERNAME:PASSWORD@example.com:8080"
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
