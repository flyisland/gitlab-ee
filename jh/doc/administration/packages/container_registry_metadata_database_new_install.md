---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用于新安装的容器镜像仓库元数据数据库
description: Enable the container registry metadata database for new installations.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为您的实例启用容器镜像仓库元数据数据库。

## 启用元数据数据库

为新的容器镜像仓库启用元数据数据库。

{{< tabs >}}

{{< tab title="极狐GitLab 18.3 及更高版本" >}}

先决条件：

- 您必须有一个未推送任何镜像的新容器镜像仓库。

要启用数据库：

1. 编辑 `/etc/gitlab/gitlab.rb`，将 `enabled` 设为 `true` 来启用数据库：

   ```ruby
   registry['database'] = {
     'enabled' => true,
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="极狐GitLab 17.5 至 18.2" >}}

先决条件：

- 您必须有一个未推送任何镜像的新容器镜像仓库。
- 创建一个[外部数据库](../postgresql/external.md#container-registry-metadata-database)。

要启用数据库：

1. 编辑 `/etc/gitlab/gitlab.rb`，添加数据库连接详细信息，但先保持元数据数据库为禁用状态：

   ```ruby
   registry['database'] = {
     'enabled' => false,
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # 默认值，如果您的数据库实例端口不同，请设置为实际端口。
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # 更多信息请参阅 PostgreSQL 文档 https://www.postgresql.org/docs/16/libpq-ssl.html。
     'sslcert' => '</path/to/cert.pem>',
     'sslkey' => '</path/to/private.key>',
     'sslrootcert' => '</path/to/ca.pem>'
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. [应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 编辑 `/etc/gitlab/gitlab.rb`，将 `enabled` 设为 `true` 来启用数据库：

   ```ruby
   registry['database'] = {
     'enabled' => true,
     'host' => '<registry_database_host_placeholder_change_me>',
     'port' => 5432, # 默认值，如果您的数据库实例端口不同，请设置为实际端口。
     'user' => '<registry_database_username_placeholder_change_me>',
     'password' => '<registry_database_placeholder_change_me>',
     'dbname' => '<registry_database_name_placeholder_change_me>',
     'sslmode' => 'require', # 更多信息请参阅 PostgreSQL 文档 https://www.postgresql.org/docs/16/libpq-ssl.html。
     'sslcert' => '</path/to/cert.pem>',
     'sslkey' => '</path/to/private.key>',
     'sslrootcert' => '</path/to/ca.pem>'
   }
   ```

{{< /tab >}}

{{< /tabs >}}

您现在可以将元数据数据库用于所有操作了！