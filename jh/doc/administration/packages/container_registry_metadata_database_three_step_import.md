---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 三步导入
description: 以最短停机时间启用容器镜像仓库元数据数据库。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

导入您现有的容器镜像仓库元数据。对于较大的镜像仓库（200 GiB 或更多），或者您希望在完成导入的同时尽可能减少停机时间，建议使用以下步骤。

<a id="pre-import-repositories-step-one"></a>

## 预导入代码仓库（第一步）

用户报告称，第一步导入的[速率可达每小时 2 至 4 TB](https://gitlab.com/gitlab-org/gitlab/-/issues/423459)。按较慢的速度计算，数据量超过 100TB 的镜像仓库可能需要 48 小时以上。

在完成第一步期间，您可以照常继续使用镜像仓库。

{{< tabs >}}

{{< tab title="极狐GitLab 18.7 及更高版本" >}}

1. 确保在 `/etc/gitlab/gitlab.rb` 文件的 `database` 部分中禁用数据库：

   ```ruby
   registry['database'] = {
     'enabled' => false, # Must be false!
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. [应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行第一步以开始导入：

   ```shell
   sudo gitlab-ctl registry-database import --step-one --log-to-stdout
   ```

{{< /tab >}}

{{< tab title="极狐GitLab 18.3 至 18.6" >}}

1. 确保在 `/etc/gitlab/gitlab.rb` 文件的 `database` 部分中禁用数据库：

   ```ruby
   registry['database'] = {
     'enabled' => false, # Must be false!
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. [应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行第一步以开始导入：

   ```shell
   sudo -u registry gitlab-ctl registry-database import --step-one --log-to-stdout
   ```

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

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. 如果尚未执行，请[应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行第一步以开始导入：

   ```shell
   sudo gitlab-ctl registry-database import --step-one
   ```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 您应尽快安排以下步骤，以减少所需的停机时间。理想情况下，应在第一步完成后一周内进行。在第一步和第二步之间写入镜像仓库的任何新数据都会导致第二步耗时更长。

<a id="import-all-repository-data-step-two"></a>

## 导入所有代码仓库数据（第二步）

此步骤要求将镜像仓库设置为 `read-only` 模式；不过，此步骤的完成速度预计比第一步快约 90%。在执行第二步时，请预留足够的停机时间。

{{< tabs >}}

{{< tab title="极狐GitLab 18.7 及更高版本" >}}

1. 确保镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并将 `maintenance` 部分添加到 `registry['storage']`
   配置中。例如，对于使用 `gs://my-company-container-registry`
   存储桶的 `gcs` 后端镜像仓库，配置可以是：

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
1. 运行导入的第二步：

   ```shell
   sudo gitlab-ctl registry-database import --step-two --log-to-stdout
   ```

1. 如果命令成功完成，则所有镜像现已完全导入。您现在可以启用数据库、关闭配置中的只读模式，并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # Must be set to true!
   }

   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => { # This section can be removed.
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="极狐GitLab 18.3 至 18.6" >}}

1. 确保镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并将 `maintenance` 部分添加到 `registry['storage']`
   配置中。例如，对于使用 `gs://my-company-container-registry`
   存储桶的 `gcs` 后端镜像仓库，配置可以是：

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
1. 运行导入的第二步：

   ```shell
   sudo -u registry gitlab-ctl registry-database import --step-two --log-to-stdout
   ```

1. 如果命令成功完成，则所有镜像现已完全导入。您现在可以启用数据库、关闭配置中的只读模式，并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # Must be set to true!
   }

   ## Object Storage - Container Registry
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => { # This section can be removed.
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="极狐GitLab 17.5 至 18.2" >}}

1. 确保镜像仓库设置为 `read-only` 模式。

   编辑 `/etc/gitlab/gitlab.rb`，并将 `maintenance` 部分添加到 `registry['storage']`
   配置中。例如，对于使用 `gs://my-company-container-registry`
   存储桶的 `gcs` 后端镜像仓库，配置可以是：

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
1. 运行导入的第二步：

   ```shell
   sudo gitlab-ctl registry-database import --step-two
   ```

1. 如果命令成功完成，则所有镜像现已完全导入。您现在可以启用数据库、关闭配置中的只读模式，并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # Must be set to true!
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
     'maintenance' => { # This section can be removed.
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< /tabs >}}

现在，您可以将元数据数据库用于所有操作了！

<a id="import-remaining-data-step-three"></a>

## 导入剩余数据（第三步）

尽管镜像仓库现在已完全使用数据库来存储其元数据，但它尚无法访问任何可能未使用的层 blob，这导致这些 blob 无法被在线垃圾回收器移除。

在完成第三步期间，您可以照常继续使用镜像仓库。

要完成整个过程，请运行迁移的最后一步：

{{< tabs >}}

{{< tab title="极狐GitLab 18.7 及更高版本" >}}

```shell
sudo gitlab-ctl registry-database import --step-three --log-to-stdout
```

{{< /tab >}}

{{< tab title="极狐GitLab 18.3 至 18.6" >}}

```shell
sudo -u registry gitlab-ctl registry-database import --step-three --log-to-stdout
```

{{< /tab >}}

{{< tab title="极狐GitLab 17.5 至 18.2" >}}

```shell
sudo gitlab-ctl registry-database import --step-three
```

{{< /tab >}}

{{< /tabs >}}

该命令成功退出后，镜像仓库元数据现已完全导入到数据库中。

<a id="after-import"></a>

## 导入后

大型镜像仓库在导入后可能有数十万甚至数百万个 blob 排队等待垃圾回收审查。这是预期情况，按默认工作进程间隔处理需要一些时间。

有关预期情况以及如何加快处理的指导，请参阅：

- [导入后](container_registry_metadata_database.md#post-import)，了解完成导入后预期行为的概述。
- [检查在线垃圾回收的健康状况](container_registry_metadata_database.md#check-the-health-of-online-garbage-collection)
  以监控垃圾回收审查队列。
- [调整垃圾回收器工作进程间隔](container_registry_metadata_database.md#adjust-the-garbage-collector-worker-interval)
  以临时加快处理大量积压数据。
