---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 设置 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="prerequisites"></a>

## 先决条件

- 两个（或更多）独立运行的极狐GitLab 站点：
  - 一个极狐GitLab 站点作为 Geo **主要** 站点。参考[极狐GitLab 参考架构文档](../../reference_architectures/_index.md)进行搭建。每个 Geo 站点可以使用不同规模的参考架构。如果你已经有一个正在使用的极狐GitLab 实例，可以将其作为 **主要** 站点。
  - 第二个极狐GitLab 站点作为 Geo **次要** 站点。参考[极狐GitLab 参考架构文档](../../reference_architectures/_index.md)进行搭建。建议登录并进行测试。但请注意，从 **主要** 站点复制数据的过程中，**次要站点上的所有数据都会丢失**。

    > [!note]
    > Geo 支持多个次要站点。你可以遵循相同步骤并做出相应调整。

- 需要两个站点的管理员访问权限。许多配置任务需要站点的根访问权限，以及访问极狐GitLab UI 中的 **管理员** 区域。
- 确保 **主要** 站点拥有[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/)订阅以解锁 Geo。所有站点只需一个许可证。
- 确认所有站点满足[运行 Geo 的要求](../_index.md#requirements-for-running-geo)。例如，各站点必须使用相同的极狐GitLab 版本，且站点之间必须能够通过特定端口互相通信。
- 确认 **主要** 站点和 **次要** 站点的存储配置相匹配。如果主要 Geo 站点使用对象存储，次要 Geo 站点也必须使用对象存储。更多信息，请参阅[使用对象存储的 Geo](../replication/object_storage.md)。
- 确保 **主要** 站点和 **次要** 站点的时钟同步。时钟同步是 Geo 正常运行的必要条件。例如，如果 **主要** 站点和 **次要** 站点之间的时钟偏差超过 1 分钟，复制就会失败。

<a id="using-linux-package-installations"></a>

## 使用 Linux 软件包安装

如果你使用 Linux 软件包安装极狐GitLab（强烈推荐），设置 Geo 的过程取决于你是需要设置单节点 Geo 站点还是多节点 Geo 站点。

<a id="single-node-geo-sites"></a>

### 单节点 Geo 站点

如果两个 Geo 站点都基于 [1K 用户参考架构](../../reference_architectures/1k_users.md)，请遵循[为两个单节点站点设置 Geo](two_single_node_sites.md)。

如果使用外部 PostgreSQL 服务，例如 Amazon RDS，请遵循[为两个单节点站点设置 Geo（使用外部 PostgreSQL 服务）](two_single_node_external_services.md)。

根据你的极狐GitLab 部署情况，可能还需要为 LDAP、对象存储和容器镜像仓库进行[额外配置](#additional-configuration)。

<a id="multi-node-geo-sites"></a>

### 多节点 Geo 站点

如果你有一个或多个站点使用 [40 RPS / 2,000 用户参考架构](../../reference_architectures/2k_users.md) 或更大规模，请参阅[为多节点配置 Geo](../replication/multiple_servers.md)。

根据你的极狐GitLab 部署情况，可能还需要为 LDAP、对象存储和容器镜像仓库进行[额外配置](#additional-configuration)。

<a id="general-steps-for-reference"></a>

### 通用步骤参考

1. 根据你选择的 PostgreSQL 实例设置数据库复制（`primary (read-write) <-> secondary (read-only)` 拓扑）：
   - [使用 Linux 软件包 PostgreSQL 实例](database.md)。
   - [使用外部 PostgreSQL 实例](external_database.md)
1. [配置极狐GitLab](../replication/configuration.md) 以设置 **主要** 站点和 **次要** 站点。
1. 遵循[使用 Geo 站点](../replication/usage.md)指南。

根据你的极狐GitLab 部署情况，可能还需要为 LDAP、对象存储和容器镜像仓库进行[额外配置](#additional-configuration)。

<a id="additional-configuration"></a>

### 额外配置

根据你使用极狐GitLab 的方式，可能需要以下配置：

- 如果 **主要** 站点使用对象存储，为 **次要** 站点[配置对象存储复制](../replication/object_storage.md)。
- 如果你使用 LDAP，为 **次要** 站点[配置次要 LDAP 服务器](../../auth/ldap/_index.md)。更多信息，请参阅[带有 Geo 的 LDAP](../replication/single_sign_on.md#ldap)。
- 如果你使用容器镜像仓库，在 **主要** 站点和 **次要** 站点上[配置容器镜像仓库用于复制](../replication/container_registry.md)。
- 为加快故障排查，[配置关联 ID 传播](../replication/troubleshooting/common.md#tracing-requests-across-geo-sites)。

你应当[配置统一 URL](/secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites)，为所有 Geo 站点使用一个单一的统一 URL。

<a id="using-gitlab-charts"></a>

## 使用极狐GitLab Charts

[使用极狐GitLab Geo 配置极狐GitLab chart](https://gitlab.cn/docs/charts/advanced/geo/)。

<a id="geo-and-self-compiled-installations"></a>

## Geo 与自行编译的安装

使用[自行编译的极狐GitLab 安装](../../../install/self_compiled/_index.md)时，不支持 Geo。

<a id="post-installation-documentation"></a>

## 安装后文档

在 **次要** 站点上安装极狐GitLab 并完成初始配置后，请参阅[以下安装后信息文档](../_index.md#post-installation-documentation)。