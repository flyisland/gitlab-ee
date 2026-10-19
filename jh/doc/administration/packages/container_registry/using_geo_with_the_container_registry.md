---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab 容器镜像仓库元数据数据库与 Geo 配合使用
description: 将极狐GitLab 容器镜像仓库元数据数据库与 Geo 配合使用
---

将极狐GitLab 容器镜像仓库与 Geo 配合使用，以复制容器镜像。每个站点的容器镜像仓库元数据数据库都是独立的，不使用 Postgres 复制。

每个从站点都应为其元数据数据库配备自己独立的 PostgreSQL 实例。

<a id="create-a-gitlab-instance-with-the-container-registry-and-geo"></a>

## 创建带有容器镜像仓库和 Geo 的极狐GitLab 实例

先决条件：

- 一个新的极狐GitLab 实例。
- 已为该实例配置容器镜像仓库，且其中没有数据。

要设置 Geo 支持：

1. 为主站点和从站点设置 Geo。更多信息，请参见[为两个单节点站点设置 Geo](../../geo/setup/two_single_node_sites.md)。
1. 在主站点和从站点上，为每个站点使用单独的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="add-container-registries-to-existing-geo-sites"></a>

## 将容器镜像仓库添加到现有 Geo 站点

先决条件：

- 两个新的极狐GitLab 实例，分别设置为主站点和从站点。
- 已为主站点配置容器镜像仓库，且其中没有数据。

要将容器镜像仓库添加到现有 Geo 从站点：

1. 在从站点上，[启用容器镜像仓库](../container_registry.md)。
1. 在主站点和从站点上，为每个站点使用单独的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="add-geo-support-and-container-registry-to-an-existing-instance-of-gitlab"></a>

## 为现有极狐GitLab 实例添加 Geo 支持和容器镜像仓库

先决条件：

- 一个现有的极狐GitLab 实例，未配置容器镜像仓库。
- 没有现有的 Geo 站点。

要为现有实例添加 Geo 支持，并为两个 Geo 站点添加容器镜像仓库：

1. 为现有实例（主站点）设置 Geo，并添加一个从站点。更多信息，请参见[为两个单节点站点设置 Geo](../../geo/setup/two_single_node_sites.md)。
1. 在主站点和从站点上：
   1. [启用容器镜像仓库](../container_registry.md#enable-the-container-registry)。
   1. 为每个站点使用单独的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="add-geo-support-to-an-instance-with-a-configured-container-registry"></a>

## 为已配置容器镜像仓库的实例添加 Geo 支持

以下各节介绍如何为已配置容器镜像仓库的现有极狐GitLab 实例添加 Geo 支持。

您可以设置以下任一项：

- 外部数据库连接。
- 默认的容器镜像仓库元数据数据库。

<a id="use-an-external-container-registry-metadata-database"></a>

### 使用外部容器镜像仓库元数据数据库

先决条件：

- 一个现有的极狐GitLab 实例，已配置容器镜像仓库。
- 没有现有的 Geo 站点。

要为现有实例添加 Geo 支持，并为从站点添加容器镜像仓库：

1. 为现有实例（主站点）设置 Geo，并添加一个从站点。更多信息，请参见[为两个单节点站点设置 Geo](../../geo/setup/two_single_node_sites.md)。
1. 在从站点上：
   1. [启用容器镜像仓库](../container_registry.md#enable-the-container-registry)。
   1. 使用单独的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="use-the-default-container-registry-metadata-database"></a>

### 使用默认的容器镜像仓库元数据数据库

先决条件：

- 一个现有的极狐GitLab 实例，已配置容器镜像仓库。
- 一个使用默认 PostgreSQL 实例的容器镜像仓库元数据数据库。
- 没有现有的 Geo 站点。

在此场景中，必须将元数据数据库迁移到外部 PostgreSQL 实例。

1. 按照此处的步骤[将元数据数据库迁移到外部 PostgreSQL 实例](../../postgresql/moving.md)。
1. 继续执行[为现有极狐GitLab 实例添加 Geo 支持和容器镜像仓库](#add-geo-support-and-container-registry-to-an-existing-instance-of-gitlab)的步骤。

<a id="migrate-the-container-registry-from-legacy-metadata"></a>

## 从旧版元数据迁移容器镜像仓库

在此场景中，您必须在现有 Geo 站点上将容器镜像仓库从旧版元数据迁移到外部 PostgreSQL 元数据数据库。

先决条件：

- 极狐GitLab 17.3 或更高版本（支持数据库元数据）
- 已在主站点和从站点上配置 Geo
- 两个站点上的容器镜像仓库均使用旧版元数据
- 两个镜像仓库都必须已有数据（已推送镜像）

<a id="migration-steps"></a>

### 迁移步骤

停机时间取决于导入方法。有关导入方法的建议，请参见[选择合适的导入方法](../container_registry_metadata_database.md#choose-the-right-import-method)。

> [!note]
> 正在迁移的镜像仓库在导入期间为只读。

迁移期间，其余 Geo 复制会继续进行。

要迁移元数据数据库：

1. 在从站点上，[将现有旧版元数据迁移到新的元数据数据库](../container_registry_metadata_database.md#enable-the-database-for-existing-registries)。
1. 在主站点上，[将现有旧版元数据迁移到新的元数据数据库](../container_registry_metadata_database.md#enable-the-database-for-existing-registries)。
1. 验证 Geo 复制继续正常工作。

<a id="add-or-rebuild-a-secondary-site-when-the-primary-is-already-migrated"></a>

## 在主站点已迁移的情况下添加或重建从站点

先决条件：

- 一个现有的 Geo 主站点，其容器镜像仓库使用元数据数据库并保存有数据。在您[从旧版元数据迁移容器镜像仓库](#migrate-the-container-registry-from-legacy-metadata)后，主站点会达到此状态。
- 要添加的从站点，已[设置为 Geo 站点](../../geo/setup/two_single_node_sites.md)，
  或要重建的现有从站点。

以下步骤会同时替换从站点的镜像仓库存储和数据库。它们不是镜像仓库存储和数据库均完好无损的从站点的恢复路径。

> [!warning]
> 在从站点的镜像仓库针对保存有数据的存储启动之前，先预配并迁移从站点的镜像仓库数据库。先启动的镜像仓库没有可写入的 schema。
> 在[偏好模式](../container_registry_metadata_database.md#prefer-mode)下，
> 找不到锁文件的镜像仓库不会回退到
> 旧版元数据。它需要一个可访问的数据库，并会采用一个空数据库
> 并提供空目录。

要添加或重建从站点：

1. 在主站点上，确认镜像仓库使用元数据数据库并保存有数据。
   有关如何确认后端的信息，请参见[验证哪个元数据后端处于活动状态](../container_registry_metadata_database.md#verify-which-metadata-backend-is-active)。如果主站点仍使用旧版元数据，请改用[从旧版元数据迁移容器镜像仓库](#migrate-the-container-registry-from-legacy-metadata)。
1. 在从站点上，准备镜像仓库状态。
   完成以下其中一项：
   - 如果您要重建现有从站点，
     请移除您要替换的镜像仓库状态：
     1. 停止镜像仓库。
     1. 删除镜像仓库对象存储的内容。
     1. 在该站点的镜像仓库数据库实例上，使用为该站点镜像仓库配置的数据库名称和所有者，删除并重新创建镜像仓库数据库。
        例如，在 `psql`中：

        ```sql
        DROP DATABASE registry;
        CREATE DATABASE registry OWNER registry;
        ```

     同时移除存储内容和数据库。
     数据库已重新创建且存储已填充的站点，既不符合此过程，
     也不符合全新安装的过程。
   - 如果您要添加新的从站点，
     请确认从站点的镜像仓库对象存储为空。
     如果存储中保存有数据，或之前的尝试遗留了镜像仓库数据库，
     请将该站点视为重建，并改为完成前一条路径。
1. 在从站点上，在数据库仍处于禁用状态时配置
   [镜像仓库数据库连接](../container_registry_metadata_database.md#using-an-external-database)，
   然后[重新配置极狐GitLab](../../restart_gitlab.md)。
   下一步中的迁移会从镜像仓库配置文件中读取该连接，
   因此该连接必须在迁移运行之前就已存在。
1. 在从站点上，
   [应用数据库迁移](../container_registry_metadata_database.md#apply-database-migrations)。
1. 在从站点上，启用数据库并[重新配置极狐GitLab](../../restart_gitlab.md)。
1. 为从站点配置
   [容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)，
   如果尚未配置的话。
1. 验证从站点保存有这些镜像。与主站点进行比较：
   - 来自 `/v2/_catalog`的目录。
   - 某个容器仓库的标签列表，以及某个标签的 `Docker-Content-Digest` 响应头。
     摘要必须匹配。
   - 每个站点各自镜像仓库数据库中的容器仓库、清单和标签行数。

不要比较两个站点之间的对象数量。从旧版元数据迁移而来的主站点会保留其原有的元数据文件，而基于元数据数据库构建的从站点只存储内容 blob，因此主站点始终保存有更多对象。

随每次推送而增大的差异另有原因。有关仍使用旧版元数据的从站点上的一个已知原因，请参见[议题 590744](https://gitlab.com/gitlab-org/gitlab/-/issues/590744)。
