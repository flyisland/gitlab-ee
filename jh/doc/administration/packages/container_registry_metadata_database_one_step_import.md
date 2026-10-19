---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 一步导入
description: 一步启用容器镜像仓库元数据数据库。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您定期运行[离线垃圾回收](container_registry.md#container-registry-garbage-collection)，请使用一步导入方法。与三步导入方法相比，此方法的操作更简单。

<a id="one-step-import"></a>

## 一步导入

> [!warning]
> 导入期间，镜像仓库必须保持 `read-only` 模式。
> 否则，导入期间写入的数据将无法访问，或导致数据不一致。
> 如果您改为停止镜像仓库，则应用数据库迁移的步骤可以重新启动它，之后镜像仓库会在导入期间接受推送。

{{< tabs >}}

{{< tab title="极狐GitLab 18.7 及更高版本" >}}

1. 确保在 `registry['database']` 配置节（位于 `/etc/gitlab/gitlab.rb` 文件中）禁用数据库：

   ```ruby
   registry['database'] = {
     'enabled' => false, # Must be false!
   }
   ```

1. 确保镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并将 `maintenance` 部分添加到 `registry['storage']` 配置中。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端镜像仓库，
   配置可以如下：

   ```ruby
   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => true # Must be set to true.
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

1. 如果命令成功完成，则镜像仓库已完全导入。您可以启用数据库、在配置中关闭只读模式，并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # Must be enabled now!
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

1. 确保在 `registry['database']` 配置节（位于 `/etc/gitlab/gitlab.rb` 文件中）禁用数据库：

   ```ruby
   registry['database'] = {
     'enabled' => false, # Must be false!
   }
   ```

1. 确保镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并将 `maintenance` 部分添加到 `registry['storage']` 配置中。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端镜像仓库，
   配置可以如下：

   ```ruby
   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => true # Must be set to true.
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

1. 如果命令成功完成，则镜像仓库已完全导入。您可以启用数据库、在配置中关闭只读模式，并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # Must be enabled now!
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

- 创建[外部数据库](../postgresql/external.md#container-registry-metadata-database)。

1. 将 `database` 部分添加到 `/etc/gitlab/gitlab.rb` 文件中，但开始时先禁用元数据数据库：

   ```ruby
   registry['database'] = {
     'enabled' => false, # Must be false!
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # Default, but set to the port of your database instance if it differs.
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # See the PostgreSQL documentation for additional information https://www.postgresql.org/docs/16/libpq-ssl.html.
     'sslcert' => '</path/to/cert.pem>',
     'sslkey' => '</path/to/private.key>',
     'sslrootcert' => '</path/to/ca.pem>'
   }
   ```

1. 确保镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并将 `maintenance` 部分添加到 `registry['storage']` 配置中。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端镜像仓库，
   配置可以如下：

   ```ruby
   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => {
       'readonly' => {
         'enabled' => true # Must be set to true.
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. 如果尚未执行，请[应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行以下命令：

   ```shell
   sudo gitlab-ctl registry-database import
   ```

1. 如果命令成功完成，则镜像仓库现已完全导入。您现在可以启用数据库、在配置中关闭只读模式，并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # Must be enabled now!
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # Default, but set to the port of your database instance if it differs.
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # See the PostgreSQL documentation for additional information https://www.postgresql.org/docs/16/libpq-ssl.html.
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

现在，您可以将元数据数据库用于所有操作！

<a id="after-import"></a>

## 导入后

大型镜像仓库在导入后可能有数十万甚至数百万个 blob 排队等待垃圾回收审查。这是预期情况，按默认工作进程间隔处理需要一些时间。

有关预期情况以及如何加快处理的指导，请参阅：

- [导入后](container_registry_metadata_database.md#post-import)，了解完成导入后预期行为的概述。
- [检查在线垃圾回收的运行状况](container_registry_metadata_database.md#check-the-health-of-online-garbage-collection)，
  以监控垃圾回收审查队列。
- [调整垃圾回收器工作进程间隔](container_registry_metadata_database.md#adjust-the-garbage-collector-worker-interval)，
  以临时加快处理大量积压。
