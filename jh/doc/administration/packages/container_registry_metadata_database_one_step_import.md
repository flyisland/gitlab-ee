---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 一步导入
description: Enable the container registry metadata database in one step.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果你经常运行[离线垃圾回收](container_registry.md#container-registry-garbage-collection)，建议使用一步导入方法。与三步导入方法相比，此方法操作更简单。

<a id="one-step-import"></a>

## 一步导入

> [!warning]
> 导入期间，容器镜像仓库必须关闭或保持 `read-only` 模式。
> 否则，导入期间写入的数据将无法访问或导致不一致。

{{< tabs >}}

{{< tab title="极狐GitLab 18.7 及更高版本" >}}

1. 确保数据库在 `/etc/gitlab/gitlab.rb` 文件的 `registry['database']` 部分中被禁用：

   ```ruby
   registry['database'] = {
     'enabled' => false, # 必须为 false！
   }
   ```

1. 确保容器镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并在 `registry['storage']` 配置中添加 `maintenance` 部分。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端容器镜像仓库，配置可能如下：

   ```ruby
   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => true # 必须设置为 true。
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. [应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行以下命令：

   ```shell
   sudo gitlab-ctl registry-database import --log-to-stdout
   ```

1. 如果命令成功完成，则容器镜像仓库已完全导入。你可以在配置中启用数据库，关闭只读模式，并启动容器镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # 必须现在就启用！
   }

   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="极狐GitLab 18.3 至 18.6" >}}

1. 确保数据库在 `/etc/gitlab/gitlab.rb` 文件的 `registry['database']` 部分中被禁用：

   ```ruby
   registry['database'] = {
     'enabled' => false, # 必须为 false！
   }
   ```

1. 确保容器镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并在 `registry['storage']` 配置中添加 `maintenance` 部分。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端容器镜像仓库，配置可能如下：

   ```ruby
   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => true # 必须设置为 true。
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. [应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行以下命令：

   ```shell
   sudo -u registry gitlab-ctl registry-database import --log-to-stdout
   ```

1. 如果命令成功完成，则容器镜像仓库已完全导入。你可以在配置中启用数据库，关闭只读模式，并启动容器镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # 必须现在就启用！
   }

   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="极狐GitLab 17.5 至 18.2" >}}

先决条件：

- 创建一个[外部数据库](../postgresql/external.md#container-registry-metadata-database)。

1. 在 `/etc/gitlab/gitlab.rb` 文件中添加 `database` 部分，但先禁用元数据数据库：

   ```ruby
   registry['database'] = {
     'enabled' => false, # 必须为 false！
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # 默认值，如果你的数据库实例端口不同，请设置为相应端口。
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # 更多信息请参阅 PostgreSQL 文档 https://www.postgresql.org/docs/16/libpq-ssl.html。
     'sslcert' => '</path/to/cert.pem>',
     'sslkey' => '</path/to/private.key>',
     'sslrootcert' => '</path/to/ca.pem>'
   }
   ```

1. 确保容器镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并在 `registry['storage']` 配置中添加 `maintenance` 部分。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端容器镜像仓库，配置可能如下：

   ```ruby
   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => true # 必须设置为 true。
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. 如果你尚未执行，请[应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行以下命令：

   ```shell
   sudo gitlab-ctl registry-database import
   ```

1. 如果命令成功完成，则容器镜像仓库已完全导入。你可以在配置中启用数据库，关闭只读模式，并启动容器镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # 必须现在就启用！
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # 默认值，如果你的数据库实例端口不同，请设置为相应端口。
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # 更多信息请参阅 PostgreSQL 文档 https://www.postgresql.org/docs/16/libpq-ssl.html。
     'sslcert' => '</path/to/cert.pem>',
     'sslkey' => '</path/to/private.key>',
     'sslrootcert' => '</path/to/ca.pem>'
   }

   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< /tabs >}}

你现在可以将元数据数据库用于所有操作！

<a id="after-import"></a>

## 导入后

大型容器镜像仓库在导入后可能有数十万甚至数百万个 blob 排队等待垃圾回收审查。这是预期情况，在默认的工作间隔下处理需要时间。

有关预期行为以及如何加速处理的指导，请参阅：

- 完成导入后的预期行为概述，请参阅[导入后](container_registry_metadata_database.md#post-import)。
- 要监控垃圾回收审查队列，请[检查在线垃圾回收健康状况](container_registry_metadata_database.md#check-the-health-of-online-garbage-collection)。
- 要临时加速处理大型积压，请[调整垃圾回收器工作间隔](container_registry_metadata_database.md#adjust-the-garbage-collector-worker-interval)。