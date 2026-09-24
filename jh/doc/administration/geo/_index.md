---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo
description: 地理分布式部署极狐GitLab。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Geo 是面向广泛分布开发团队的解决方案，也是灾难恢复策略中温备站点的一部分。Geo 并非开箱即用的高可用性（HA）解决方案。

> [!warning]
> Geo 在每次版本发布之间会有重大变化。支持升级，并有[相应文档](#upgrading-geo)，但您应确保使用的是与您的安装版本相匹配的文档。

为确保您使用的是正确版本的文档，请访问 [JihuLab.com 上的 Geo 页面](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/administration/geo/_index.md)，并从 **Switch branch/tag** 下拉列表中选择合适的版本。例如，[`v19.2.0-ee`](https://gitlab.com/gitlab-org/gitlab/-/blob/v19.2.0-ee/doc/administration/geo/_index.md)。

对于远离单个极狐GitLab 实例的团队和 Runner，获取大型代码仓库可能需要很长时间。

Geo 提供可放置在地理上靠近远程团队的本地缓存，用于处理读取请求。这可以减少克隆和获取大型代码仓库所需的时间，从而加快开发速度并提高远程团队的生产力。

Geo 从站点会将写请求透明地代理到主站点。所有 Geo 站点都可以配置为响应单个极狐GitLab URL，无论用户访问哪个站点，都能提供一致、无缝且全面的体验。

Geo 使用一组在 [Geo 术语表](glossary.md) 中定义的术语。请务必熟悉这些术语。

<a id="use-cases"></a>

## 使用场景

实施 Geo 可满足多种使用场景。本节介绍部分预期使用场景及其优势。

<a id="regional-disaster-recovery"></a>

### 区域灾难恢复

Geo 作为[灾难恢复](disaster_recovery/_index.md)解决方案，可在与主站点不同的区域为您提供温备从站点。数据会持续同步到从站点，确保其始终是最新的。发生灾难（例如数据中心或网络中断、硬件故障）时，您可以故障转移到一个完全可用的从站点。您可以通过[计划内故障转移](disaster_recovery/planned_failover.md)来测试灾难恢复流程和基础设施。

优势：

- 在发生区域灾难时保障业务连续性。
- 低恢复时间目标（RTO）和低恢复点目标（RPO）。
- 使用极狐GitLab 环境工具包（GET）实现自动化（但非自动）故障转移。
- 极少的运维工作量 - 无需人工干预的持续复制和验证可确保您的从站点保持最新，并确保复制的数据在传输和静态存储期间不会损坏。

<a id="remote-team-acceleration"></a>

### 加速远程团队

在离远程团队更近的位置建立 Geo 从站点，以提供加速读取操作的本地缓存。您可以拥有多个 Geo 从站点，每个站点仅同步远程团队所需的项目。[透明代理](secondary_proxy/_index.md)和基于[统一 URL](replication/location_aware_git_url.md)的地理路由可确保一致且无缝的开发者体验。

优势：

- 改善地理分布团队的极狐GitLab 体验。Geo 在从站点上提供完整的极狐GitLab 体验：维护一个主极狐GitLab 站点，同时为每个分布式团队启用具有读写访问权限和完整 UI 体验的从站点。
- 将分布式开发者克隆和获取大型代码仓库和项目的时间从几分钟缩短到几秒。
- 让所有开发者无论身处何地，都能并行贡献想法和工作。
- 在主站点和从站点之间平衡读取负载。
- 克服异地办公室之间的慢速连接，通过提高分布式团队的速度来节省时间。
- 减少自动化任务、自定义集成和内部工作流的加载时间。

<a id="cicd-traffic-offload"></a>

### CI/CD 流量卸载

您可以配置 CI/CD Runner 从 [Geo 从站点克隆](secondary_proxy/runners.md)。您可以根据 Runner 工作负载的需求定制从站点，而无需镜像主站点。支持的读取请求由从站点上的缓存数据提供服务，当从站点上的数据过期或不可用时，请求会透明地转发到主站点。

优势：

- 在主站点上，通过将流量转移到从站点，减少 CI/CD 流量对用户体验的影响。
- 减少跨区域流量，并将 CI/CD 计算时间安排在组织最具成本效益的位置。创建数据的单一跨区域副本，并使其可用于对从站点的重复读取请求。

<a id="additional-use-cases"></a>

### 其他使用场景

<a id="infrastructure-migrations"></a>

#### 基础设施迁移

您可以使用 Geo 迁移到新的基础设施。如果您将极狐GitLab 实例迁移到新的服务器或数据中心，可以使用 Geo 在后台将极狐GitLab 数据迁移到新实例，同时旧实例继续为用户提供服务。对活跃极狐GitLab 数据的任何更改都会复制到新实例，因此在切换期间不会丢失数据。

您不能使用 Geo 将 PostgreSQL 数据库从一种操作系统迁移到另一种操作系统。请参阅 [PostgreSQL 操作系统升级](../postgresql/upgrading_os.md)。

优势：

- 与备份和恢复迁移方法相比，显著减少迁移期间的停机时间。在切换停机窗口之前，无需停止活跃的极狐GitLab 实例，即可在后台将数据复制到新实例。

<a id="migration-to-gitlab-dedicated"></a>

#### 迁移到 GitLab Dedicated

您还可以使用 Geo 将极狐GitLab 私有化部署迁移到 [GitLab Dedicated](../../subscriptions/gitlab_dedicated/_index.md)。

优势：

- 更顺畅的入门体验，停机时间显著减少。在后台进行数据迁移时，您的团队可以继续使用极狐GitLab 私有化部署。

<a id="what-geo-is-not-designed-to-address"></a>

## Geo 不适用于的场景

Geo 并非为所有使用场景而设计。本节提供 Geo 不适用的一些示例。

<a id="enforce-data-export-compliance"></a>

### 强制数据导出合规

虽然 Geo 的[选择性同步](replication/selective_synchronization.md)功能允许您限制同步到从站点的项目，但其设计目的是减少跨区域流量和存储需求，而非强制导出合规。您必须根据解决方案和文档，持续独立地确定您在隐私、网络安全和适用的贸易管制法律方面的法律义务。解决方案和文档均可能发生变化。

<a id="provide-access-control"></a>

### 提供访问控制

Geo 的[只读从站点](secondary_proxy/_index.md#disable-secondary-site-git-proxying)功能并非一级功能，未来可能不受支持。您不应依赖此功能进行访问控制。极狐GitLab 提供了更适用于此目的的[身份验证和授权](../auth/_index.md)控制。

<a id="an-alternative-to-zero-downtime-upgrades"></a>

### 零停机升级的替代方案

Geo 不是[零停机升级](../../update/zero_downtime.md)的解决方案。您必须先升级主 Geo 站点，然后再升级从站点。

<a id="protect-against-malicious-or-unintentional-corruption"></a>

### 防止恶意或意外损坏

Geo 会将主站点上的损坏复制到所有从站点。为防止恶意或意外损坏，您应使用[备份](../backup_restore/_index.md)来补充 Geo。

<a id="active-active-high-availability-configuration"></a>

### 主动-主动高可用性配置

Geo 被设计为主动-被动高可用性解决方案。它采用最终一致的同步模型，这意味着从站点与主站点并非紧密同步。从站点跟随主站点会有少量延迟，这可能导致灾难发生后出现少量数据丢失。发生灾难时，故障转移到从站点需要人工干预。但是，如果您使用 [极狐GitLab 环境工具包 (GET)](https://gitlab.com/gitlab-org/gitlab-environment-toolkit) 部署所有站点，则将从站点提升为主站点的大部分流程由 GET 自动完成。

<a id="gitaly-cluster-praefect"></a>

## Gitaly 集群 (Praefect)

不应将 Geo 与 [Gitaly 集群 (Praefect)](../gitaly/praefect/_index.md) 混淆。有关 Geo 与 Gitaly 集群 (Praefect) 之间差异的更多信息，请参阅 [与 Geo 的比较](../gitaly/praefect/_index.md#comparison-to-geo)。

<a id="how-geo-works"></a>

## Geo 的工作原理

以下简要介绍 Geo 在您的极狐GitLab 环境中的工作原理。有关更多详细信息，请参阅 Geo 开发文档。

您的 Geo 实例可用于克隆和获取项目，以及读取任何数据。这使得在远距离处理大型代码仓库时速度更快。

![Geo 概览](img/geo_overview_v11_5.png)

启用 Geo 后：

- 原始实例称为主站点。
- 复制站点称为从站点。

请记住：

- 从站点与主站点通信以：
  - 获取用户登录数据（API）。
  - 复制代码仓库、LFS 对象和附件（HTTPS + JWT）。
- 主站点与从站点通信以查看复制详细信息。主站点对从站点执行 GraphQL 查询以获取同步和验证数据（API）。
- 您可以直接推送到从站点（支持 HTTP 和 SSH，包括 Git LFS），它将把请求代理到主站点。
- 使用 Geo 时存在一些[已知问题](#known-issues)。

<a id="architecture"></a>

### 架构

下图说明了 Geo 的底层架构。

![Geo 架构图，显示通过 PostgreSQL 流复制进行数据库复制，以及通过 Git HTTP 和私有 API 在主站点和从站点之间进行文件复制。](img/geo_architecture_v13_8.png)

在此图中：

- 有一个主站点和一个从站点的详细信息。
- 对数据库的写入只能在主站点上执行。从站点通过使用 [PostgreSQL 流复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION) 接收数据库更新。
- 如果存在，[LDAP 服务器](#ldap) 应配置为针对[灾难恢复](disaster_recovery/_index.md)场景进行复制。
- 从站点使用受 JWT 保护的特殊授权，对主站点执行不同类型的同步：
  - 通过 HTTPS 上的 Git 克隆/更新代码仓库。
  - 通过使用私有 API 端点的 HTTPS 下载附件、LFS 对象和其他文件。

从执行 Git 操作的用户角度来看：

- 主站点表现为一个完整的读写极狐GitLab 实例。
- 从站点表现为完整的读写极狐GitLab 实例。从站点将所有操作透明地代理到主站点，但有一些[显著例外](secondary_proxy/_index.md#features-accelerated-by-secondary-geo-sites)。特别是，当从站点是最新时，Git 获取请求由从站点提供服务。

从浏览极狐GitLab UI 或使用 API 的用户角度来看：

- 主站点表现为一个完整的读写极狐GitLab 实例。
- 从站点表现为完整的读写极狐GitLab 实例。从站点将所有操作透明地代理到主站点，但有一些[显著例外](secondary_proxy/_index.md#features-accelerated-by-secondary-geo-sites)。特别是，Web UI 资源由从站点提供服务。

为简化图示，省略了一些必要的组件。

- 通过 SSH 的 Git 需要 [`gitlab-shell`](https://gitlab.com/gitlab-org/gitlab-shell)。
- 通过 HTTPS 的 Git 需要 [`workhorse`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/workhorse)。

从站点需要两个不同的 PostgreSQL 数据库：

- 一个只读数据库实例，用于从主极狐GitLab 数据库流式传输数据。
- 一个[读写数据库实例（跟踪数据库）](#geo-tracking-database)，由从站点内部使用，用于记录已复制的数据。

从站点还运行一个额外的守护进程：[Geo 日志游标](#geo-log-cursor)。

<a id="requirements-for-running-geo"></a>

## 运行 Geo 的要求

运行 Geo 需要满足以下要求：

- 支持 OpenSSH 6.9 或更高版本的操作系统（用于[在数据库中快速查找授权的 SSH 密钥](../operations/fast_ssh_key_lookup.md)）
  已知以下操作系统随附当前版本的 OpenSSH：
  - [CentOS](https://www.centos.org) 7.4 或更高版本
  - [Ubuntu](https://ubuntu.com) 16.04 或更高版本
- 在可能的情况下，您还应在所有 Geo 站点上使用相同的操作系统版本。如果在 Geo 站点之间使用不同的操作系统版本，您必须检查 Geo 站点之间的 [OS 区域设置数据兼容性](replication/troubleshooting/common.md#check-os-locale-data-compatibility)，以避免数据库索引被静默损坏。
- 您的极狐GitLab 版本支持的 [PostgreSQL 版本](https://handbook.gitlab.com/handbook/engineering/data-engineering/database-excellence/database-frameworks/postgresql-upgrade-cadence/)，并支持[流复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION)。
  - 不支持 [PostgreSQL 逻辑复制](https://www.postgresql.org/docs/16/logical-replication.html)。
- 所有站点必须运行[相同的 PostgreSQL 版本](setup/database.md#postgresql-replication)。
- Git 2.9 或更高版本
- 使用 LFS 时，用户端需要 Git-lfs 2.4.2 或更高版本
- 所有站点必须运行完全相同的极狐GitLab 版本。[主、次和补丁版本](../../policy/maintenance.md#versioning)必须全部匹配。
- 所有站点必须定义相同的[代码仓库存储](../repository_storage_paths.md)。
- 将容器镜像仓库与 Geo 一起使用时，您必须在每个站点为容器镜像仓库元数据数据库配置独立的外部 PostgreSQL 实例。有关详细信息，请参阅[从站点的容器镜像仓库](replication/container_registry.md)。

此外，请查看极狐GitLab [最低要求](../../install/requirements.md)，并使用最新版本的极狐GitLab 以获得更好的体验。

由于 Geo 在基础极狐GitLab 安装之上增加了跟踪数据库和复制元数据，因此对于不包含代码仓库数据的最小 Geo 部署，请为每个站点规划至少 40 GB 的磁盘空间。有关更多详细信息，请参阅[存储要求](../../install/requirements.md#storage)。

<a id="firewall-rules"></a>

### 防火墙规则

下表列出了 Geo 主站点和从站点之间必须打开的基本端口。为简化故障转移，您应在两个方向都打开端口。

| 源站点   | 源端口 | 目标站点   | 目标端口 | 协议        |
|-------------|-------------|------------------|------------------|-------------|
| 主站点     | 任意         | 从站点        | 80               | TCP (HTTP)  |
| 主站点     | 任意         | 从站点        | 443              | TCP (HTTPS) |
| 从站点   | 任意         | 主站点          | 80               | TCP (HTTP)  |
| 从站点   | 任意         | 主站点          | 443              | TCP (HTTPS) |
| 从站点   | 任意         | 主站点          | 5432             | TCP         |
| 从站点   | 任意         | 主站点          | 5000             | TCP (HTTPS) |

在[软件包默认值](../package_information/defaults.md)中查看极狐GitLab 使用的完整端口列表。

> [!warning]
> 对于 Geo 站点之间的 PostgreSQL 复制，您必须使用私有网络连接，例如内部 VPC 对等连接。
> 切勿将 PostgreSQL 端口暴露到互联网。将 PostgreSQL 端口暴露到互联网可能导致未经授权的访问，并获得对您的极狐GitLab 数据库的完全写入权限，从而可能危及您的整个极狐GitLab 实例及所有相关数据。

此外：

- [Web 终端](../../ci/environments/_index.md#web-terminals-deprecated)支持要求您的负载均衡器正确处理 WebSocket 连接。
  使用 HTTP 或 HTTPS 代理时，您的负载均衡器必须配置为传递 `Connection` 和 `Upgrade` 逐跳头。有关更多详细信息，请参阅 [Web 终端](../integration/terminal.md)集成指南。
- 对端口 443 使用 HTTPS 协议时，您必须向负载均衡器添加 SSL 证书。
  如果您希望在极狐GitLab 应用服务器上终止 SSL，请改用 TCP 协议。
- 如果您仅对外部/内部 URL 使用 `HTTPS`，则无需在防火墙中打开端口 80。

<a id="internal-url"></a>

#### 内部 URL

从任何 Geo 从站点到主 Geo 站点的 HTTP 请求都使用主 Geo 站点的内部 URL。如果未在 **管理员** 区域的主 Geo 站点设置中显式定义，则使用主站点的公共 URL。

先决条件：

- 管理员访问权限。

要更新主 Geo 站点的内部 URL：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在主站点上选择 **编辑**。
1. 更改 **内部 URL**，然后选择 **保存更改**。

<a id="geo-tracking-database"></a>

### Geo 跟踪数据库

跟踪数据库实例用作元数据，以控制本地实例上需要更新的内容。例如：

- 下载新资源。
- 获取新的 LFS 对象。
- 获取最近更新的代码仓库的更改。

由于复制的数据库实例是只读的，因此我们需要为每个从站点提供此额外的数据库实例。

<a id="geo-log-cursor"></a>

### Geo 日志游标

此守护进程：

- 读取由主站点复制到从数据库实例的事件日志。
- 使用必须执行的更改更新 Geo 跟踪数据库实例。

当跟踪数据库实例中标记了要更新的内容时，在从站点上运行的异步作业将执行所需操作并更新状态。

这种新架构使极狐GitLab 能够抵御站点之间的连接问题。无论从站点与主站点断开连接多长时间，它都能以正确的顺序重放所有事件，并再次与主站点同步。

<a id="known-issues"></a>

## 已知问题

> [!warning]
> 这些已知问题仅反映最新版本的极狐GitLab。如果您使用的是旧版本，则可能存在其他问题。

- 通过 Geo 从站点进行的 Git over SSH 无法可靠工作。有关更多信息，请参阅 [议题 #413109](https://gitlab.com/gitlab-org/gitlab/-/issues/413109)、[议题 #417186](https://gitlab.com/gitlab-org/gitlab/-/issues/417186)、[议题 #454707](https://gitlab.com/gitlab-org/gitlab/-/issues/454707) 和 [议题 585913](https://gitlab.com/gitlab-org/gitlab/-/issues/585913)。
- 直接推送到从站点会将请求重定向（对于 HTTP）或代理（对于 SSH）到主站点，而不是[直接处理](https://gitlab.com/gitlab-org/gitlab/-/issues/1381)。您不能使用 URI 中嵌入凭据的 Git over HTTP，例如 `https://user:personal-access-token@secondary.tld`。有关更多信息，请参阅如何[使用 Geo 站点](replication/usage.md)。
- 主站点必须在线才能进行 OAuth 登录。现有会话和 Git 不受影响。从站点使用独立于主站点的 OAuth 提供程序的支持正在[规划中](https://gitlab.com/gitlab-org/gitlab/-/issues/208465)。
- 安装需要多个手动步骤，根据情况总共可能需要大约一个小时。考虑使用 [极狐GitLab 环境工具包](https://gitlab.com/gitlab-org/gitlab-environment-toolkit) Terraform 和 Ansible 脚本，基于[参考架构](../reference_architectures/_index.md)部署和运维生产极狐GitLab 实例，包括自动化常见日常任务。[Epic 1465](https://gitlab.com/groups/gitlab-org/-/work_items/1465) 提议进一步改进 Geo 安装。
- 在[禁用 HTTP 代理](secondary_proxy/_index.md#disable-secondary-site-http-proxying)的从站点上，议题/合并请求的实时更新（例如，通过长轮询）无法工作。
- [选择性同步](replication/selective_synchronization.md)仅限制复制的代码仓库和文件。整个 PostgreSQL 数据仍会被复制。选择性同步并非为满足合规/出口管制用例而构建。
- [Pages 访问控制](../../user/project/pages/pages_access_control.md)在从站点上不起作用。有关详细信息，请参阅 [议题 9336](https://gitlab.com/gitlab-org/gitlab/-/issues/9336)。
- 对于具有多个从站点的部署，[灾难恢复](disaster_recovery/_index.md)会因需要在所有未提升的从站点上重新初始化 PostgreSQL 流复制以跟随新的主站点而导致停机。
- 对于 Git over SSH，为使项目克隆 URL 无论您浏览哪个站点都能正确显示，从站点必须使用与主站点相同的端口。有关更多信息，请参阅 [议题 339262](https://gitlab.com/gitlab-org/gitlab/-/issues/339262)。
- 备份[无法在 Geo 从站点上运行](replication/troubleshooting/postgresql_replication.md#message-error-canceling-statement-due-to-conflict-with-recovery)。
- 在大多数情况下，Geo 从站点不会加速（提供）流水线第一阶段的克隆请求。后续阶段也不保证由从站点提供服务，例如，如果 Git 更改很大、带宽很小或流水线阶段很短。通常，它确实会为后续阶段的克隆请求提供服务。[议题 446176](https://gitlab.com/gitlab-org/gitlab/-/issues/446176) 讨论了原因，并提出了增强功能以增加 Runner 克隆请求由从站点提供服务的可能性。
- 当单个 Git 代码仓库以足够高的速率接收推送时，从站点的本地副本可能永远处于过期状态。这会导致该代码仓库的所有 Git 获取都被转发到主站点。有关更多信息，请参阅 [议题 455870](https://gitlab.com/gitlab-org/gitlab/-/issues/455870)。
- [代理](secondary_proxy/_index.md)仅在极狐GitLab 应用程序的 Puma 服务或 Web 服务中实现，因此其他服务不会受益于此行为。您应使用[单独的 URL](secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site) 以确保请求始终发送到主站点。这些服务包括：
  - 极狐GitLab 容器镜像仓库 - [可以配置为使用单独的域名](../packages/container_registry.md#configure-container-registry-under-its-own-domain)，例如 `registry.example.com`。从站点容器镜像仓库仅用于灾难恢复。不应将用户路由到这些仓库，尤其是推送操作，因为数据不会传播到主站点。
  - GitLab Pages - 应始终使用单独的域名，作为[运行 GitLab Pages 的先决条件](../pages/_index.md#prerequisites)的一部分。
- 使用[统一 URL](secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites)时，除非 Let's Encrypt 可以通过同一域名访问两个 IP，否则无法生成证书。要将 TLS 证书与 Let's Encrypt 一起使用，您可以手动将域名指向其中一个 Geo 站点，生成证书，然后将其复制到所有其他站点。
- 当[从站点使用与主站点不同的 URL](secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site)时，仅当 SAML 身份提供程序 (IdP) 允许应用程序配置多个回调 URL 时，才支持[使用 SAML 登录从站点](replication/single_sign_on.md#saml-with-separate-url-with-proxying-enabled)。
- 如果从站点在发起请求时不是最新的，则通过 SSH 对从站点使用 `--depth` 选项的 Git 克隆和获取请求将无法工作并无限期挂起。这是由于在代理期间将 Git SSH 转换为 Git HTTPS 的相关问题。有关更多信息，请参阅 [议题 391980](https://gitlab.com/gitlab-org/gitlab/-/issues/391980)。现在，对于 Linux 软件包安装的极狐GitLab Geo 从站点，可以使用一种不涉及上述转换步骤的新工作流，可通过功能标志启用。有关更多详细信息，请参阅 [议题 454707 中的评论](https://gitlab.com/gitlab-org/gitlab/-/issues/454707#note_2102067451)。针对 Cloud Native GitLab Geo 从站点的修复在 [议题 5641](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5641) 中跟踪。
- 不要将[相对 URL](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-a-relative-url-for-gitlab) 与极狐GitLab Geo 一起使用，因为它们会破坏站点之间的代理。有关更多信息，请参阅 [议题 456427](https://gitlab.com/gitlab-org/gitlab/-/issues/456427)。

<a id="replicated-data-types"></a>

### 复制的数据类型

这里有所有极狐GitLab [数据类型](replication/datatypes.md)和[复制的数据类型](replication/datatypes.md#replicated-data-types)的完整列表。

<a id="post-installation-documentation"></a>

## 安装后文档

在从站点上安装极狐GitLab 并执行初始配置后，请参阅以下文档获取安装后信息。

<a id="setting-up-geo"></a>

### 设置 Geo

有关配置 Geo 的信息，请参阅[设置 Geo](setup/_index.md)。

<a id="configuring-geo-with-object-storage"></a>

### 使用对象存储配置 Geo

有关使用对象存储配置 Geo 的信息，请参阅[使用对象存储的 Geo](replication/object_storage.md)。

<a id="replicating-the-container-registry"></a>

### 复制容器镜像仓库

有关如何复制容器镜像仓库的更多信息，请参阅[从站点的容器镜像仓库](replication/container_registry.md)。

<a id="set-up-a-unified-url-for-geo-sites"></a>

### 为 Geo 站点设置统一 URL

有关如何使用 AWS Route53 或 Google Cloud DNS 设置单个位置感知 URL 的示例，请参阅[为 Geo 站点设置统一 URL](secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites)。

<a id="single-sign-on-sso"></a>

### 单点登录 (SSO)

有关配置单点登录 (SSO) 的更多信息，请参阅[使用单点登录 (SSO) 的 Geo](replication/single_sign_on.md)。

<a id="ldap"></a>

#### LDAP

有关配置 LDAP 的更多信息，请参阅[使用单点登录 (SSO) 的 Geo > LDAP](replication/single_sign_on.md#ldap)。

<a id="tuning-geo"></a>

### 调优 Geo

有关调优 Geo 的更多信息，请参阅[调优 Geo](replication/tuning.md)。

<a id="pausing-and-resuming-replication"></a>

### 暂停和恢复复制

有关更多信息，请参阅[暂停和恢复复制](replication/pause_resume_replication.md)。

<a id="background-jobs"></a>

### 后台作业

有关 Geo 后台工作进程、其队列安全性和恢复机制的更多信息，请参阅[Geo 后台作业](replication/background_jobs.md)。

<a id="backfill"></a>

### 回填

设置从站点后，它会开始从主站点复制缺失的数据，此过程称为**回填**。您可以在浏览器中从主站点的 **Geo Nodes** 仪表板监控每个 Geo 站点上的同步过程。

回填期间发生的失败会被安排在回填结束时重试。

<a id="runners"></a>

### Runner

- 除了部署 [Runner 集群](https://gitlab.cn/docs/runner/fleet_scaling/)的标准最佳实践外，Runner 还可以配置为连接到 Geo 从站点以分散作业负载。请参阅如何[针对从站点注册 Runner](secondary_proxy/runners.md)。
- 另请参阅如何处理[故障转移期间的 Runner 连接](disaster_recovery/planned_failover.md#runner-connectivity-during-failover)。

<a id="upgrading-geo"></a>

### 升级 Geo

有关如何将 Geo 站点升级到最新极狐GitLab 版本的信息，请参阅[升级 Geo 站点](replication/upgrading_the_geo_sites.md)。

<a id="security-review"></a>

### 安全审查

有关 Geo 安全的更多信息，请参阅 [Geo 安全审查](replication/security_review.md)。

<a id="remove-geo-site"></a>

## 移除 Geo 站点

有关移除 Geo 站点的更多信息，请参阅[移除 Geo 从站点](replication/remove_geo_site.md)。

<a id="disable-geo"></a>

## 禁用 Geo

要了解如何禁用 Geo，请参阅[禁用 Geo](replication/disable_geo.md)。

<a id="log-files"></a>

## 日志文件

Geo 将结构化日志消息存储在 `geo.log` 文件中。

有关如何访问和使用 Geo 日志的更多信息，请参阅[日志系统文档中的 Geo 部分](../logs/_index.md#geolog)。

<a id="disaster-recovery"></a>

## 灾难恢复

有关在灾难恢复情况下使用 Geo 以减轻数据丢失和恢复服务的信息，请参阅[灾难恢复](disaster_recovery/_index.md)。

<a id="frequently-asked-questions"></a>

## 常见问题解答

有关常见问题的解答，请参阅 [Geo 常见问题解答](replication/faq.md)。

<a id="troubleshooting"></a>

## 故障排查

- 有关 Geo 故障排查步骤，请参阅 [Geo 故障排查](replication/troubleshooting/_index.md)。
- 有关灾难恢复故障排查步骤，请参阅[Geo 故障转移故障排查](disaster_recovery/failover_troubleshooting.md)。
