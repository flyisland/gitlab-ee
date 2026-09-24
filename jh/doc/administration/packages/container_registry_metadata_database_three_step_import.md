---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 三步导入
description: Enable the container registry metadata database with minimal downtime.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

导入现有的容器镜像仓库元数据。
以下步骤推荐用于较大的镜像仓库（200 GiB 或更大），或希望在导入过程中最小化停机时间的情况。

<a id="pre-import-repositories-step-one"></a>

## 预导入仓库（第一步）

根据用户报告，第一步导入的完成速度在[每小时 2 到 4 TB](https://jihulab.com/gitlab-cn/gitlab/-/issues/423459)。
以较慢的速度计算，数据量超过 100 TB 的镜像仓库可能需要超过 48 小时。

在第一步执行期间，你可以正常使用镜像仓库。

{{< tabs >}}

{{< tab title="极狐GitLab 18.7 及更高版本" >}}

1. 确保在你的 `/etc/gitlab/gitlab.rb` 文件的 `database` 部分中数据库处于禁用状态：

   ```ruby
   registry['database'] = {
     'enabled' => false, # 必须为 false!
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

1. 确保在你的 `/etc/gitlab/gitlab.rb` 文件的 `database` 部分中数据库处于禁用状态：

   ```ruby
   registry['database'] = {
     'enabled' => false, # 必须为 false!
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

前提条件：

- 创建一个[外部数据库](../postgresql/external.md#container-registry-metadata-database)。

1. 将 `database` 部分添加到你的 `/etc/gitlab/gitlab.rb` 文件中，但先以元数据数据库禁用的状态开始：

   ```ruby
   registry['database'] = {
     'enabled' => false, # 必须为 false!
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # 默认值，如果不同则设置为你的数据库实例端口。
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # 请参阅 PostgreSQL 文档了解更多信息 https://www.postgresql.org/docs/16/libpq-ssl.html。
     'sslcert' => '</path/to/cert.pem>',
     'sslkey' => '</path/to/private.key>',
     'sslrootcert' => '</path/to/ca.pem>'
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. 如果你尚未执行，请[应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 运行第一步以开始导入：

   ```shell
   sudo gitlab-ctl registry-database import --step-one
   ```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 你应尽快安排下一步，以减少所需的停机时间。理想情况下，在第一步完成后不超过一周。第一步和第二步之间写入镜像仓库的任何新数据都会导致第二步花费更多时间。

<a id="import-all-repository-data-step-two"></a>

## 导入所有仓库数据（第二步）

此步骤要求镜像仓库关闭或设置为 `只读` 模式；
但可以预期此步骤比第一步快约 90%。
在执行第二步期间，请留出足够的停机时间。

{{< tabs >}}

{{< tab title="极狐GitLab 18.7 及更高版本" >}}

1. 确保镜像仓库设置为 `只读` 模式。

   编辑你的 `/etc/gitlab/gitlab.rb` 并将 `maintenance` 部分添加到 `registry['storage']` 配置中。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端镜像仓库，配置可以为：

   ```ruby
   ## 对象存储 - 容器镜像仓库
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
1. 运行第二步导入：

   ```shell
   sudo gitlab-ctl registry-database import --step-two --log-to-stdout
   ```

1. 如果命令成功完成，所有镜像现在已完全导入。现在你可以启用数据库，在配置中关闭只读模式，
   并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # 必须设置为 true！
   }

   ## 对象存储 - 容器镜像仓库
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => { # 此部分可以删除。
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="极狐GitLab 18.3 至 18.6" >}}

1. 确保镜像仓库设置为 `只读` 模式。

   编辑你的 `/etc/gitlab/gitlab.rb` 并将 `maintenance` 部分添加到 `registry['storage']` 配置中。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端镜像仓库，配置可以为：

   ```ruby
   ## 对象存储 - 容器镜像仓库
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
1. 运行第二步导入：

   ```shell
   sudo -u registry gitlab-ctl registry-database import --step-two --log-to-stdout
   ```

1. 如果命令成功完成，所有镜像现在已完全导入。现在你可以启用数据库，在配置中关闭只读模式，
   并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # 必须设置为 true！
   }

   ## 对象存储 - 容器镜像仓库
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => { # 此部分可以删除。
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="极狐GitLab 17.5 至 18.2" >}}

1. 确保镜像仓库设置为 `只读` 模式。

   编辑你的 `/etc/gitlab/gitlab.rb` 并将 `maintenance` 部分添加到 `registry['storage']` 配置中。
   例如，对于使用 `gs://my-company-container-registry` 存储桶的 `gcs` 后端镜像仓库，配置可以为：

   ```ruby
   ## 对象存储 - 容器镜像仓库
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
1. 运行第二步导入：

   ```shell
   sudo gitlab-ctl registry-database import --step-two
   ```

1. 如果命令成功完成，所有镜像现在已完全导入。现在你可以启用数据库，在配置中关闭只读模式，
   并启动镜像仓库服务：

   ```ruby
   registry['database'] = {
     'enabled' => true, # 必须设置为 true！
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # 默认值，如果不同则设置为你的数据库实例端口。
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # 请参阅 PostgreSQL 文档了解更多信息 https://www.postgresql.org/docs/16/libpq-ssl.html。
     'sslcert' => '</path/to/cert.pem>',
     'sslkey' => '</path/to/private.key>',
     'sslrootcert' => '</path/to/ca.pem>'
   }

   ## 对象存储 - 容器镜像仓库
   registry['storage'] = {
     'gcs' => {
       'bucket' => '<my-company-container-registry>',
       'chunksize' => 5242880
     },
     'maintenance' => { # 此部分可以删除。
       'readonly' => {
         'enabled' => false
       }
     }
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< /tabs >}}

你现在可以使用元数据数据库进行所有操作！

<a id="import-remaining-data-step-three"></a>

## 导入剩余数据（第三步）

尽管镜像仓库现已完全使用数据库存储元数据，
但它尚未访问任何可能未使用的层 blob，这导致这些 blob
无法被在线垃圾回收器删除。

在第三步执行期间，你可以正常使用镜像仓库。

要完成此过程，请运行迁移的最后一步：

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

该命令成功退出后，镜像仓库元数据现已完全导入数据库。

<a id="after-import"></a>

## 导入之后

大型镜像仓库在导入后可能会有数十万甚至数百万个 blob 排队等待垃圾回收审查。
这是预期行为，在默认工作线程间隔下需要时间来处理。

有关预期行为及如何加速处理的指导，请参见：

- [导入后](container_registry_metadata_database.md#post-import) 了解完成导入后的预期行为概览。
- [检查在线垃圾回收的健康状况](container_registry_metadata_database.md#check-the-health-of-online-garbage-collection)
  以监控垃圾回收审查队列。
- [调整垃圾回收器工作线程间隔](container_registry_metadata_database.md#adjust-the-garbage-collector-worker-interval)
  以临时加速处理大型积压。