---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo 术语表
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 我们正在更新 Geo 文档、用户界面和命令以反映这些变化。并非所有页面都尚未符合这些定义。

这些是描述 Geo 各个方面的已定义术语。使用一组清晰定义的术语有助于我们高效沟通并避免混淆。本页面上的语言旨在普遍适用并尽可能简单。

## 主要术语

我们提供了[示例图表和说明](#示例)来演示术语的正确用法。

| 术语                      | 定义                                                                                                                             | 适用范围            | 不建议使用的同义词                                |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------|---------------------|----------------------------------------------------|
| 节点 (Node)               | 一台独立的服务器，用于运行极狐GitLab，可以承担特定角色或作为一个整体（例如 Rails 应用节点）。在云环境中，这可以是特定的机器类型。     | 极狐GitLab          | 实例 (instance)，服务器 (server)                     |
| 站点 (Site)               | 运行单个极狐GitLab 应用程序的一个或一组节点。一个站点可以是单节点或多节点的。                                                          | 极狐GitLab          | 部署 (deployment)，安装实例 (installation instance)       |
| 单节点站点 (Single-node site)       | 只使用一个节点的特定极狐GitLab 配置。                                                                                                    | 极狐GitLab          | 单服务器 (single-server)，单实例 (single-instance)            |
| 多节点站点 (Multi-node site)        | 使用一个以上节点的特定极狐GitLab 配置。                                                                                                  | 极狐GitLab          | 多服务器 (multi-server)，多实例 (multi-instance)，高可用性 (high availability) |
| 主站点 (Primary site)           | 数据被至少一个从站点复制的极狐GitLab 站点。只能有一个主站点。                                                                            | Geo 特定            | Geo 部署 (Geo deployment)，主节点 (Primary node)           |
| 从站点 (Secondary site)         | 配置为复制主站点数据的极狐GitLab 站点。可以有一个或多个从站点。                                                                            | Geo 特定            | Geo 部署 (Geo deployment)，从节点 (Secondary node)          |
| Geo 部署 (Geo deployment)         | 由两个或多个极狐GitLab 站点组成的集合，其中恰好有一个主站点的数据被一个或多个从站点复制。                                                         | Geo 特定            |                                                     |
| 参考架构 (Reference architecture) | 基于每秒请求数或用户数量的特定[极狐GitLab 配置](../reference_architectures/_index.md)，可能包括多个节点和多个站点。                            | 极狐GitLab          |                                                     |
| 提升 (Promoting)              | 将站点的角色从从站点更改为主站点的过程。                                                                                                | Geo 特定            |                                                     |
| 降级 (Demoting)               | 将站点的角色从主站点更改为从站点的过程。                                                                                                | Geo 特定            |                                                     |
| 故障转移 (Failover)               | 将用户从主站点转移到从站点的整个过程。这包括提升从站点，但也包含其他部分。例如，安排维护。                                                       | Geo 特定            |                                                     |
| 复制 (Replication)            | 也称为“同步”。将从站点上的资源更新以匹配主站点上资源的单向过程。                                                                            | Geo 特定            |                                                     |
| 复制槽 (Replication slot)       | PostgreSQL 复制功能，它确保与数据库的持久连接点，并跟踪备用服务器仍然需要哪些 WAL 段。将复制槽命名为与站点的 `geo_node_name` 匹配会有所帮助，但这不是必需的。 | PostgreSQL         |                                                     |
| 验证 (Verification)           | 比较主站点上存在的数据与复制到从站点的数据的过程。用于确保复制数据的完整性。                                                                      | Geo 特定            |                                                     |
| 统一 URL (Unified URL)            | 用于所有 Geo 站点的单一外部 URL。允许请求被路由到主 Geo 站点或任何从 Geo 站点。                                                                 | Geo 特定            |                                                     |
| Geo 代理 (Geo proxying)           | 一种机制，从 Geo 站点将操作透明地转发到主站点，但某些可以由从站点本地处理的操作除外。                                                                  | Geo 特定            |                                                     |
| 二进制大对象 (Blob)                   | Geo 相关的数据类型，可以被复制以涵盖各种极狐GitLab 组件。                                                                                    | Geo 特定            | 文件 (file)                                                |

## 复制器术语

Geo 使用复制器在主站点和从站点之间复制各个极狐GitLab 组件的数据。它们定义了这些组件各自的[数据类型](replication/datatypes.md#data-types)需要如何处理和验证。例如，极狐GitLab 容器镜像仓库的数据必须与 CI 作业产物进行不同的处理。有些组件可能有多个复制器，它们可能也有不同的命名。因此，下表描述了复制器的名称以及它们属于哪个极狐GitLab 组件。

相同的复制器名称也会显示在管理中心的 Geo 部分，或者在使用 Geo 相关的控制台命令时。

| Geo 复制器名称                       | GitLab 组件名称                        |
|------------------------------------|----------------------------------------|
| CI 安全文件 (CI Secure Files)                | CI 安全文件 (CI Secure Files)                        |
| 容器仓库 (Container Repositories)         | 容器镜像仓库 (Container registry)                     |
| 依赖代理二进制大对象 (Dependency Proxy Blobs)         | 依赖代理镜像 (Dependency Proxy Images)                |
| 依赖代理清单 (Dependency Proxy Manifests)     | 依赖代理镜像 (Dependency Proxy Images)                |
| 设计管理仓库 (Design Management Repositories) | 项目设计仓库 (Project designs repository)             |
| 群组 Wiki 仓库 (Group Wiki Repositories)        | 群组 Wiki 仓库 (Group wiki repository)                  |
| CI 作业产物 (CI Job Artifacts)               | CI 作业产物 (CI job artifacts)                       |
| LFS 对象 (LFS Objects)                    | LFS 对象 (LFS objects)                            |
| 合并请求差异 (Merge Request Diffs)            | 外部合并请求差异 (External merge request diffs)           |
| 软件包文件 (Package Files)                  | 软件包仓库 (Package registry)                       |
| Pages 部署 (Pages Deployments)              | Pages (Pages)                                  |
| 流水线产物 (Pipeline Artifacts)             | 流水线产物 (Pipeline artifacts)                     |
| 项目仓库 (Project Repositories)           | 项目仓库 (Project repository)                     |
| 项目 Wiki 仓库 (Project Wiki Repositories)      | 项目 Wiki 仓库 (Project wiki repository)                |
| 代码片段仓库 (Snippet Repositories)           | 个人代码片段和项目代码片段 (Personal Snippets and Project Snippets) |
| Terraform 状态版本 (Terraform State Versions)       | 版本化 Terraform 状态 (Versioned Terraform State)              |
| 上传文件 (Uploads)                        | 用户上传文件 (User uploads)                           |

<a id="examples"></a>

## 示例

<a id="single-node-site"></a>

### 单节点站点

一个具有一个运行极狐GitLab 节点的站点：

- 极狐GitLab 节点

<a id="multi-node-site"></a>

### 多节点站点

一个具有多个运行不同极狐GitLab 组件的节点的站点：

- 应用节点
- 数据库节点
- Gitaly 节点

<a id="geo-deployment---single-node-sites"></a>

### Geo 部署 - 单节点站点

此 Geo 部署有一个单节点主站点和一个单节点从站点：

主站点 (单节点)：

- 极狐GitLab 节点

从站点 1 (单节点)：

- 极狐GitLab 节点

<a id="geo-deployment---multi-node-sites"></a>

### Geo 部署 - 多节点站点

此 Geo 部署有一个多节点主站点和一个多节点从站点：

主站点 (多节点)：

- 应用节点
- 数据库节点

从站点 1 (多节点)：

- 应用节点
- 数据库节点

<a id="geo-deployment---mixed-sites"></a>

### Geo 部署 - 混合站点

此 Geo 部署有一个多节点主站点、一个多节点从站点和一个单节点从站点：

主站点 (多节点)：

- 应用节点
- 数据库节点
- Gitaly 节点

从站点 1 (多节点)：

- 应用节点
- 数据库节点

从站点 2 (单节点)：

- 单个极狐GitLab 节点