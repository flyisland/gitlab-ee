---
stage: GitLab Dedicated
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
  - 一个极狐GitLab 站点用作 Geo 主站点。使用[极狐GitLab 参考架构文档](../../reference_architectures/_index.md)进行设置。您可以为每个 Geo 站点使用不同的参考架构规格。如果您已有一个正在使用中的极狐GitLab 实例，可以将其用作主站点。
  - 第二个极狐GitLab 站点用作 Geo 从站点。使用[极狐GitLab 参考架构文档](../../reference_architectures/_index.md)进行设置。建议先登录并测试。但请注意，在从主站点复制的过程中，从站点上的所有数据都会丢失。

    > [!note]
    > Geo 支持多个从站点。您可以按照相同的步骤操作，并相应地进行任何更改。

- 两个站点的管理员访问权限。许多配置任务需要对站点的 root 访问权限，以及对极狐GitLab UI 中**管理员**区域的访问权限。
- 确保主站点拥有[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)订阅以启用 Geo。所有站点只需一个许可证。
- 确认所有站点均满足[运行 Geo 的要求](../_index.md#requirements-for-running-geo)。例如，站点必须使用相同的极狐GitLab 版本，并且站点必须能够通过特定端口相互通信。
- 确认主站点和从站点的存储配置一致。如果 Geo 主站点使用对象存储，Geo 从站点也必须使用对象存储。更多信息，请参见 [Geo 与对象存储](../replication/object_storage.md)。
- 确保主站点和从站点之间的时钟已同步。Geo 正常运行需要时钟同步。例如，如果主站点和从站点之间的时钟偏差超过 1 分钟，复制就会失败。

<a id="using-linux-package-installations"></a>

## 使用 Linux 软件包安装

如果您使用 Linux 软件包安装极狐GitLab（强烈推荐），设置 Geo 的过程取决于您需要设置单节点 Geo 站点还是多节点 Geo 站点。

<a id="single-node-geo-sites"></a>

### 单节点 Geo 站点

如果两个 Geo 站点都基于 [1K 参考架构](../../reference_architectures/1k_users.md)，请遵循[为两个单节点站点设置 Geo](two_single_node_sites.md)。

如果使用外部 PostgreSQL 服务，例如 Amazon RDS，请遵循[为两个单节点站点设置 Geo（使用外部 PostgreSQL 服务）](two_single_node_external_services.md)。

根据您的极狐GitLab 部署情况，可能需要对 LDAP、对象存储和容器镜像仓库进行[额外配置](#additional-configuration)。

<a id="multi-node-geo-sites"></a>

### 多节点 Geo 站点

如果您的某个或多个站点使用 [40 RPS / 2,000 用户参考架构](../../reference_architectures/2k_users.md)或更大规格，请参见[为多个节点配置 Geo](../replication/multiple_servers.md)。

根据您的极狐GitLab 部署情况，可能需要对 LDAP、对象存储和容器镜像仓库进行[额外配置](#additional-configuration)。

<a id="general-steps-for-reference"></a>

### 供参考的通用步骤

1. 根据您选择的 PostgreSQL 实例（`primary (read-write) <-> secondary (read-only)` 拓扑）设置数据库复制：
   - [使用 Linux 软件包 PostgreSQL 实例](database.md)。
   - [使用外部 PostgreSQL 实例](external_database.md)
1. [配置极狐GitLab](../replication/configuration.md) 以设置主站点和从站点。
1. 遵循[使用 Geo 站点](../replication/usage.md)指南。

根据您的极狐GitLab 部署情况，可能需要对 LDAP、对象存储和容器镜像仓库进行[额外配置](#additional-configuration)。

<a id="additional-configuration"></a>

### 额外配置

根据您使用极狐GitLab 的方式，可能需要进行以下配置：

- 如果主站点使用对象存储，请为从站点[配置对象存储复制](../replication/object_storage.md)。
- 如果您使用 LDAP，请为从站点[配置次要 LDAP 服务器](../../auth/ldap/_index.md)。
  更多信息，请参见 [Geo 与 LDAP](../replication/single_sign_on.md#ldap)。
- 如果您使用容器镜像仓库，请在主站点和从站点上[配置容器镜像仓库复制](../replication/container_registry.md)。
- 为加快故障排除速度，请[配置关联 ID 传播](../replication/troubleshooting/common.md#tracing-requests-across-geo-sites)。

您应[配置统一 URL](../secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites)，以便为所有 Geo 站点使用单个统一 URL。

<a id="using-gitlab-charts"></a>

## 使用 GitLab Charts

[使用极狐GitLab Geo 配置 GitLab chart](https://gitlab.cn/docs/charts/advanced/geo/)。

<a id="geo-and-self-compiled-installations"></a>

## Geo 与自行编译安装

使用[自行编译的极狐GitLab 安装](../../../install/self_compiled/_index.md)时不支持 Geo。

<a id="post-installation-documentation"></a>

## 安装后文档

在从站点上安装极狐GitLab并执行初始配置后，请参见[以下安装后信息文档](../_index.md#post-installation-documentation)。
