---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用极狐GitLab 容器镜像仓库元数据数据库与 Geo
description: 使用极狐GitLab 容器镜像仓库元数据数据库与 Geo
---

使用极狐GitLab 容器镜像仓库与 Geo 复制容器镜像。每个站点的容器镜像仓库元数据数据库是独立的，不使用 PostgreSQL 复制。

每个副站点应拥有自己的独立 PostgreSQL 实例用于元数据数据库。

<a id="create-a-gitlab-instance-with-the-container-registry-and-geo"></a>

## 创建带有容器镜像仓库和 Geo 的极狐GitLab 实例

先决条件：

- 全新的极狐GitLab 实例。
- 为该实例配置了无数据的容器镜像仓库。

设置 Geo 支持：

1. 为主站点和副站点设置 Geo。更多信息，参见[为两个单节点站点设置 Geo](../../geo/setup/two_single_node_sites.md)。
1. 在主站点和副站点上，使用各自独立的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="add-container-registries-to-existing-geo-sites"></a>

## 向现有 Geo 站点添加容器镜像仓库

先决条件：

- 两个全新的极狐GitLab 实例，分别设置为主站点和副站点。
- 为主站点配置了无数据的容器镜像仓库。

向现有 Geo 副站点添加容器镜像仓库：

1. 在副站点上，[启用容器镜像仓库](../container_registry.md)。
1. 在主站点和副站点上，使用各自独立的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="add-geo-support-and-container-registry-to-an-existing-instance-of-gitlab"></a>

## 向现有极狐GitLab 实例添加 Geo 支持和容器镜像仓库

先决条件：

- 未配置容器镜像仓库的现有极狐GitLab 实例。
- 无现有 Geo 站点。

向现有实例添加 Geo 支持，并向两个 Geo 站点添加容器镜像仓库：

1. 为现有实例（主站点）设置 Geo，并添加一个副站点。更多信息，参见[为两个单节点站点设置 Geo](../../geo/setup/two_single_node_sites.md)。
1. 在主站点和副站点上：
   1. [启用容器镜像仓库](../container_registry.md#enable-the-container-registry)。
   1. 使用各自独立的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="add-geo-support-to-an-instance-with-a-configured-container-registry"></a>

## 向已配置容器镜像仓库的实例添加 Geo 支持

以下章节介绍如何向已配置容器镜像仓库的现有极狐GitLab 实例添加 Geo 支持。

你可以设置以下任一方式：

- 外部数据库连接。
- 默认容器镜像仓库元数据数据库。

<a id="use-an-external-container-registry-metadata-database"></a>

### 使用外部容器镜像仓库元数据数据库

先决条件：

- 已配置容器镜像仓库的现有极狐GitLab 实例。
- 无现有 Geo 站点。

向现有实例添加 Geo 支持，并向副站点添加容器镜像仓库：

1. 为现有实例（主站点）设置 Geo，并添加一个副站点。更多信息，参见[为两个单节点站点设置 Geo](../../geo/setup/two_single_node_sites.md)。
1. 在副站点上：
   1. [启用容器镜像仓库](../container_registry.md#enable-the-container-registry)。
   1. 使用独立的[外部数据库](../container_registry_metadata_database.md#using-an-external-database)设置[元数据数据库](../container_registry_metadata_database_new_install.md)。
1. 配置[容器镜像仓库复制](../../geo/replication/container_registry.md#configure-container-registry-replication)。

<a id="use-the-default-container-registry-metadata-database"></a>

### 使用默认容器镜像仓库元数据数据库

先决条件：

- 已配置容器镜像仓库的现有极狐GitLab 实例。
- 使用默认 PostgreSQL 实例的容器镜像仓库元数据数据库。
- 无现有 Geo 站点。

在此场景中，必须将元数据数据库迁移到外部 PostgreSQL 实例。

1. 按照[将元数据数据库迁移到外部 PostgreSQL 实例](../../postgresql/moving.md)的步骤操作。
1. 继续执行[向现有极狐GitLab 实例添加 Geo 支持和容器镜像仓库](#add-geo-support-and-container-registry-to-an-existing-instance-of-gitlab)的步骤。

<a id="migrate-the-container-registry-from-legacy-metadata"></a>

## 从旧版元数据迁移容器镜像仓库

在此场景中，你必须将容器镜像仓库从旧版元数据迁移到现有 Geo 站点的外部 PostgreSQL 元数据数据库。

先决条件：

- 极狐GitLab 17.3 或更高版本（支持数据库元数据）
- 主站点和副站点上已配置 Geo
- 两个站点上的容器镜像仓库均使用旧版元数据
- 两个仓库必须具有已有数据（镜像已推送）

### 迁移步骤

停机时间取决于导入方法。关于导入方法的建议，请参见[选择合适的导入方法](../container_registry_metadata_database.md#choose-the-right-import-method)。

> [!note]
> 在导入期间，正在迁移的仓库处于只读状态。

迁移期间，其余 Geo 复制将继续进行。

迁移元数据数据库：

1. 在副站点上，[将现有旧版元数据迁移到新的元数据数据库](../container_registry_metadata_database.md#enable-the-database-for-existing-registries)。
1. 在主站点上，[将现有旧版元数据迁移到新的元数据数据库](../container_registry_metadata_database.md#enable-the-database-for-existing-registries)。
1. 验证 Geo 复制继续正常工作。