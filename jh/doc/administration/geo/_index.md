---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo
description: 在地理上分布极狐GitLab。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Geo 是面向广泛分布的开发团队的解决方案，也可作为灾难恢复策略的一部分提供温备站点。Geo 并非开箱即用的高可用解决方案。

> [!warning]
> Geo 在每个版本之间都会发生重大变化。支持升级并已[记录在文档中](#upgrading-geo)，但您应确保使用的是与您的安装相匹配的文档版本。

为确保您使用的是正确的文档版本，请前往 [GitLab.com 上的 Geo 页面](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/administration/geo/_index.md)，然后从**切换分支/标签**下拉列表中选择相应的版本。例如，[`v19.2.0-ee`](https://gitlab.com/gitlab-org/gitlab/-/blob/v19.2.0-ee/doc/administration/geo/_index.md)。

对于远离单个极狐GitLab 实例的团队和 Runner 来说，获取大型代码仓库可能需要很长时间。

Geo 提供本地缓存，可以将其放置在地理上靠近远程团队的位置，以处理读取请求。这可以减少克隆和获取大型代码仓库所需的时间，加快开发速度并提高远程团队的工作效率。

Geo 从站点会透明地将写入请求代理到主站点。所有 Geo 站点都可以配置为响应单个极狐GitLab URL，无论用户访问哪个站点，都能提供一致、无缝且全面的体验。

Geo 使用一组已定义的术语，这些术语在 [Geo 术语表](glossary.md)中进行了描述。请务必熟悉这些术语。

<a id="use-cases"></a>

## 使用场景

实施 Geo 可以解决多种使用场景。本节提供了一些预期的使用场景，并重点介绍了它们的优势。

<a id="regional-disaster-recovery"></a>

### 区域灾难恢复

Geo 作为[灾难恢复](disaster_recovery/_index.md)解决方案，可为您提供一个位于与主站点不同区域的温备从站点。数据会持续同步到从站点，确保其始终保持最新。在发生灾难时，例如数据中心或网络中断或硬件故障，您可以故障转移到完全可用的从站点。您可以使用[计划内故障转移](disaster_recovery/planned_failover.md)来测试您的灾难恢复流程和基础设施。

优势：

- 在发生区域灾难时保持业务连续性。
- 较低的恢复时间目标（RTO）和恢复点目标（RPO）。
- 使用 GitLab Environment Toolkit (GET) 实现自动化（但非自动）故障转移。
- 运维工作量极小 - 无人值守的持续复制和验证可确保您的从站点保持最新，并且复制的数据在传输和静态存储期间不会损坏。

<a id="remote-team-acceleration"></a>

### 远程团队加速

在与您的远程团队地理上更接近的位置建立 Geo 从站点，以提供加速读取操作的本地缓存。您可以拥有多个 Geo 从站点，每个站点都经过定制，仅同步您的远程团队所需的项目。[透明代理](secondary_proxy/_index.md)和[统一 URL](replication/location_aware_git_url.md)的地理路由可确保一致且无缝的开发体验。

优势：

- 改善地理分布团队使用极狐GitLab 的体验。Geo 在从站点上提供完整的极狐GitLab 体验：维护一个极狐GitLab 主站点，同时为每个分布式团队启用具有读写访问权限和完整 UI 体验的从站点。
- 将分布式开发者克隆和获取大型代码仓库及项目的时间从几分钟缩短到几秒钟。
- 让所有开发者无论身处何地都能并行贡献想法和开展工作。
- 在主站点和从站点之间平衡读取负载。
- 克服远距离办公室之间的慢速连接，通过提高分布式团队的速度来节省时间。
- 减少自动化任务、自定义集成和内部工作流的加载时间。

<a id="cicd-traffic-offload"></a>

### CI/CD 流量卸载

您可以将 CI/CD Runner 配置为[从 Geo 从站点克隆](secondary_proxy/runners.md)。您可以定制从站点以匹配 Runner 工作负载的需求，而无需镜像主站点。支持的读取请求由从站点上的缓存数据提供服务，当从站点上的数据过期或不可用时，请求会透明地转发到主站点。

优势：

- 在主站点上，通过将流量转移到从站点，减少 CI/CD 流量对用户体验的影响。
- 减少跨区域流量，并将 CI/CD 计算时间安排在您的组织最经济的位置。创建数据的单个跨区域副本，并使其可用于针对从站点的重复读取请求。

<a id="additional-use-cases"></a>

### 其他使用场景

<a id="infrastructure-migrations"></a>

#### 基础设施迁移

您可以使用 Geo 迁移到新的基础设施。如果您将极狐GitLab 实例迁移到新服务器或数据中心，可以使用 Geo 在后台将极狐GitLab 数据迁移到新实例，同时旧实例继续为您的用户提供服务。对活动极狐GitLab 数据的任何更改都会复制到新实例，因此切换期间不会丢失数据。

您不能使用 Geo 将 PostgreSQL 数据库从一个操作系统迁移到另一个操作系统。请参阅[升级 PostgreSQL 的操作系统](../postgresql/upgrading_os.md)。

优势：

- 与备份和恢复迁移方法相比，可显著减少迁移期间的停机时间。在后台将数据复制到新实例，而无需在切换停机窗口之前停止活动的极狐GitLab 实例。

<a id="what-geo-is-not-designed-to-address"></a>

## Geo 不适用于解决的场景

Geo 并非旨在解决所有使用场景。本节提供了一些 Geo 不是合适解决方案的使用场景示例。

<a id="enforce-data-export-compliance"></a>

### 强制执行数据导出合规性

虽然 Geo 的[选择性同步](replication/selective_synchronization.md)功能允许您限制同步到从站点的项目，但它的设计目的是减少跨区域流量和存储需求，而不是强制执行导出合规性。您必须根据解决方案和文档，持续独立地确定您在隐私、网络安全和适用贸易管制法律方面的法律义务。解决方案和文档均可能发生变化。

<a id="provide-access-control"></a>

### 提供访问控制

Geo 的[只读从站点](secondary_proxy/_index.md#disable-secondary-site-git-proxying)功能不是一等功能，将来可能不再支持。您不应依赖此功能来实现访问控制目的。极狐GitLab 提供了更适合此目的的[身份验证和授权](../auth/_index.md)控制。

<a id="an-alternative-to-zero-downtime-upgrades"></a>

### 零停机升级的替代方案

Geo 不是[零停机升级](../../update/zero_downtime.md)的解决方案。您必须先升级 Geo 主站点，然后再升级从站点。

<a id="protect-against-malicious-or-unintentional-corruption"></a>

### 防范恶意或无意的损坏

Geo 会将主站点上的损坏复制到所有从站点。为防范恶意或无意的损坏，您应将 Geo 与[备份](../backup_restore/_index.md)结合使用。

<a id="active-active-high-availability-configuration"></a>

### 双活、高可用配置

Geo 被设计为主动-被动的高可用解决方案。它采用最终一致的同步模型，这意味着从站点与主站点并非紧密同步。从站点会以较小的延迟跟随主站点，这可能导致灾难发生后出现少量数据丢失。在发生灾难时故障转移到从站点需要人工干预。但是，只要您使用 GET 部署所有站点，将从站点提升为主站点的大部分流程都由 [GitLab Environment Toolkit (GET)](https://gitlab.com/gitlab-org/gitlab-environment-toolkit) 实现自动化。

<a id="gitaly-cluster-praefect"></a>

## Gitaly 集群（Praefect）

不应将 Geo 与 [Gitaly 集群（Praefect）](../gitaly/praefect/_index.md)混淆。有关 Geo 与 Gitaly 集群（Praefect）之间区别的更多信息，请参阅[与 Geo 的比较](../gitaly/praefect/_index.md#comparison-to-geo)。

<a id="how-geo-works"></a>

## Geo 的工作原理

这是 Geo 在您的极狐GitLab 环境中如何工作的简要概述。有关更多详细信息，请参阅 Geo 开发文档。

除了读取任何数据外，您的 Geo 实例还可用于克隆和获取项目。这使得在远距离处理大型代码仓库时速度更快。

![Geo 概览](img/geo_overview_v11_5.png)

启用 Geo 后：

- 原始实例称为主站点。
- 复制站点称为从站点。

请记住：

- 从站点与主站点通信以：
  - 获取用于登录的用户数据（API）。
  - 复制代码仓库、LFS 对象和附件（HTTPS + JWT）。
- 主站点与从站点通信以查看复制详情。主站点对从站点执行 GraphQL 查询以获取同步和验证数据（API）。
- 您可以直接推送到从站点（HTTP 和 SSH 均可，包括 Git LFS），它会将请求代理到主站点。
- 使用 Geo 时存在一些[已知问题](#known-issues)。

<a id="architecture"></a>

### 架构

下图说明了 Geo 的底层架构。

![Geo 架构图，显示主站点和从站点之间通过 PostgreSQL 流式复制进行数据库复制，以及通过 Git HTTP 和私有 API 进行文件复制。](img/geo_architecture_v13_8.png)

在此图中：

- 有主站点和一个从站点的详细信息。
- 对数据库的写入只能在主站点上执行。从站点通过使用 [PostgreSQL 流式复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION)接收数据库更新。
- 如果存在，应将 [LDAP 服务器](#ldap)配置为针对[灾难恢复](disaster_recovery/_index.md)场景进行复制。
- 从站点使用受 JWT 保护的特殊授权对主站点执行不同类型的同步：
  - 代码仓库通过 Git over HTTPS 进行克隆/更新。
  - 附件、LFS 对象和其他文件通过使用私有 API 端点的 HTTPS 下载。

从执行 Git 操作的用户的角度来看：

- 主站点的行为如同一个完整的读写极狐GitLab 实例。
- 从站点的行为如同完整的读写极狐GitLab 实例。从站点会透明地将所有操作代理到主站点，但[有一些值得注意的例外](secondary_proxy/_index.md#features-accelerated-by-secondary-geo-sites)。特别是，当从站点是最新的时候，Git 获取由从站点提供服务。

从浏览极狐GitLab UI 或使用 API 的用户的角度来看：

- 主站点的行为如同一个完整的读写极狐GitLab 实例。
- 从站点的行为如同完整的读写极狐GitLab 实例。从站点会透明地将所有操作代理到主站点，但[有一些值得注意的例外](secondary_proxy/_index.md#features-accelerated-by-secondary-geo-sites)。特别是，Web UI 资产由从站点提供服务。

为简化图表，省略了一些必要的组件。

- Git over SSH 需要 [`gitlab-shell`](https://gitlab.com/gitlab-org/gitlab-shell)。
- Git over HTTPS 需要 [`workhorse`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/workhorse)。

从站点需要两个不同的 PostgreSQL 数据库：

- 一个只读数据库实例，从主极狐GitLab 数据库流式传输数据。
- 一个[读写数据库实例（跟踪数据库）](#geo-tracking-database)，由从站点内部使用，以记录已复制的数据。

从站点还运行一个额外的守护进程：[Geo 日志游标](#geo-log-cursor)。

<a id="requirements-for-running-geo"></a>

## 运行 Geo 的要求

运行 Geo 需要以下条件：

- 支持 OpenSSH 6.9 或更高版本的操作系统（[在数据库中快速查找已授权的 SSH 密钥](../operations/fast_ssh_key_lookup.md)所需）
  已知以下操作系统随附当前版本的 OpenSSH：
  - [CentOS](https://www.centos.org) 7.4 或更高版本
  - [Ubuntu](https://ubuntu.com) 16.04 或更高版本
- 在可能的情况下，您还应在所有 Geo 站点上使用相同的操作系统版本。如果在 Geo 站点之间使用不同的操作系统版本，您必须跨 Geo 站点[检查操作系统区域设置数据兼容性](replication/troubleshooting/common.md#check-os-locale-data-compatibility)，以避免数据库索引的静默损坏。
- 您的极狐GitLab 版本所支持的 [PostgreSQL 版本](https://handbook.gitlab.com/handbook/engineering/data-engineering/database-excellence/database-frameworks/postgresql-upgrade-cadence/)，并支持[流式复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION)。
  - 不支持 [PostgreSQL 逻辑复制](https://www.postgresql.org/docs/16/logical-replication.html)。
- 所有站点必须运行[相同的 PostgreSQL 版本](setup/database.md#postgresql-replication)。
- Git 2.9 或更高版本
- 使用 LFS 时，用户端需要 Git-lfs 2.4.2 或更高版本
- 所有站点必须运行完全相同的极狐GitLab 版本。[主版本、次版本和补丁版本](../../policy/maintenance.md#versioning)都必须匹配。
  要检查站点的极狐GitLab 版本，请运行 `sudo gitlab-rake gitlab:env:info`。有关更多信息，请参阅
  [收集极狐GitLab 和系统信息](../raketasks/maintenance.md#gather-gitlab-and-system-information)。
- 所有站点必须定义相同的[代码仓库存储](../repository_storage_paths.md)。
- 在将容器镜像仓库与 Geo 一起使用时，您必须在每个站点为容器镜像仓库元数据数据库配置单独的外部 PostgreSQL 实例。有关详细信息，请参阅[从站点的容器镜像仓库](replication/container_registry.md)。

此外，请检查极狐GitLab 的[最低要求](../../install/requirements.md)，并使用最新版本的极狐GitLab 以获得更好的体验。

由于 Geo 在基础极狐GitLab 安装之上添加了跟踪数据库和复制元数据，对于没有代码仓库数据的最小 Geo 部署，请为每个站点规划至少 40 GB 的磁盘空间。有关更多详细信息，请参阅[存储要求](../../install/requirements.md#storage)。

<a id="firewall-rules"></a>

### 防火墙规则

下表列出了 Geo 在主站点和从站点之间必须开放的基本端口。为简化故障转移，您应在两个方向上开放端口。

| 源站点 | 源端口 | 目标站点 | 目标端口 | 协议    |
|-------------|-------------|------------------|------------------|-------------|
| 主站点     | 任意         | 从站点        | 80               | TCP (HTTP)  |
| 主站点     | 任意         | 从站点        | 443              | TCP (HTTPS) |
| 从站点   | 任意         | 主站点          | 80               | TCP (HTTP)  |
| 从站点   | 任意         | 主站点          | 443              | TCP (HTTPS) |
| 从站点   | 任意         | 主站点          | 5432             | TCP         |
| 从站点   | 任意         | 主站点          | 5000             | TCP (HTTPS) |

请参阅[软件包默认值](../package_information/defaults.md)中极狐GitLab 使用的完整端口列表

> [!warning]
> 对于 Geo 站点之间的 PostgreSQL 复制，您必须使用专用网络连接，例如内部 VPC 对等互连。
> 切勿将 PostgreSQL 端口暴露到互联网。将 PostgreSQL 端口暴露到互联网可能导致未经授权的访问，并获得对极狐GitLab 数据库的完整写入权限，从而可能危及您的整个极狐GitLab 实例及所有相关数据。

此外：

- [Web 终端](../../ci/environments/_index.md#web-terminals-deprecated)支持要求您的负载均衡器正确处理 WebSocket 连接。
  使用 HTTP 或 HTTPS 代理时，您的负载均衡器必须配置为传递 `Connection` 和 `Upgrade` 逐跳请求头。有关更多详细信息，请参阅 [Web 终端](../integration/terminal.md)集成指南。
- 对端口 443 使用 HTTPS 协议时，您必须向负载均衡器添加 SSL 证书。
  如果您希望在极狐GitLab 应用服务器上终止 SSL，请改用 TCP 协议。
- 如果您仅对外部/内部 URL 使用 `HTTPS`，则无需在防火墙中开放端口 80。

<a id="internal-url"></a>

#### 内部 URL

从任何 Geo 从站点到 Geo 主站点的 HTTP 请求都使用 Geo 主站点的内部 URL。如果未在**管理**区域的 Geo 主站点设置中明确指定，则使用主站点的公共 URL。

先决条件：

- 管理员访问权限。

要更新 Geo 主站点的内部 URL：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在主站点上选择**编辑**。
1. 更改**内部 URL**，然后选择**保存更改**。

<a id="geo-tracking-database"></a>

### Geo 跟踪数据库

跟踪数据库实例用作元数据，以控制本地实例上需要更新的内容。例如：

- 下载新资产。
- 获取新的 LFS 对象。
- 从最近更新过的代码仓库获取更改。

由于复制的数据库实例是只读的，因此每个从站点都需要这个额外的数据库实例。

<a id="geo-log-cursor"></a>

### Geo 日志游标

此守护进程：

- 读取由主站点复制到从数据库实例的事件日志。
- 使用必须执行的更改更新 Geo 跟踪数据库实例。

当跟踪数据库实例中标记了要更新的内容时，在从站点上运行的异步作业会执行所需的操作并更新状态。

这种新架构使极狐GitLab 能够应对站点之间的连接问题。从站点与主站点断开连接的时间长短无关紧要，因为它能够按正确的顺序重放所有事件并再次与主站点同步。

<a id="known-issues"></a>

## 已知问题

> [!warning]
> 这些已知问题仅反映最新版本的极狐GitLab。如果您使用的是较旧版本，可能存在其他问题。

- 直接推送到从站点会将请求重定向（对于 HTTP）或代理（对于 SSH）到主站点，而不是[直接处理它](https://gitlab.com/gitlab-org/gitlab/-/issues/1381)。您不能使用 URI 中嵌入凭据的 Git over HTTP，例如 `https://user:personal-access-token@secondary.tld`。有关更多信息，请参阅如何[使用 Geo 站点](replication/usage.md)。
- 主站点必须在线才能进行 OAuth 登录。现有会话和 Git 不受影响。从站点使用独立于主站点的 OAuth 提供商的支持[正在规划中](https://gitlab.com/gitlab-org/gitlab/-/issues/208465)。
- 安装需要多个手动步骤，根据具体情况，这些步骤总共可能需要大约一个小时。考虑使用
  [GitLab Environment Toolkit](https://gitlab.com/gitlab-org/gitlab-environment-toolkit) Terraform 和 Ansible 脚本，基于我们的[参考架构](../reference_architectures/_index.md)来部署和运维生产
  极狐GitLab 实例，包括常见日常任务的自动化。
  [史诗 1465](https://gitlab.com/groups/gitlab-org/-/work_items/1465) 提议进一步改进 Geo 安装。
- 议题/合并请求的实时更新（例如，通过长轮询）在[禁用 HTTP 代理](secondary_proxy/_index.md#disable-secondary-site-http-proxying)的从站点上无法工作。
- [选择性同步](replication/selective_synchronization.md)仅限制复制哪些代码仓库和文件。整个 PostgreSQL 数据仍会被复制。选择性同步并非为满足合规/出口管制使用场景而构建。
- [Pages 访问控制](../../user/project/pages/pages_access_control.md)在从站点上无法工作。有关更多信息，请参阅[议题 9336](https://gitlab.com/gitlab-org/gitlab/-/issues/9336)了解详情。
- 对于具有多个从站点的部署，[灾难恢复](disaster_recovery/_index.md)会导致停机，因为需要在所有未提升的从站点上重新初始化 PostgreSQL 流式复制，以跟随新的主站点。
- 对于 Git over SSH，为使项目克隆 URL 无论您浏览哪个站点都能正确显示，从站点必须使用与主站点相同的端口。
  有关更多信息，请参阅[议题 339262](https://gitlab.com/gitlab-org/gitlab/-/issues/339262)。
- 备份[无法在 Geo 从站点上运行](replication/troubleshooting/postgresql_replication.md#message-error-canceling-statement-due-to-conflict-with-recovery)。
- 在大多数情况下，Geo 从站点不会加速（服务）流水线第一阶段的克隆请求。后续阶段也不保证由从站点提供服务，例如如果 Git 更改很大、带宽很小，或者流水线阶段很短。一般来说，它确实会为后续阶段提供克隆请求服务。[议题 446176](https://gitlab.com/gitlab-org/gitlab/-/issues/446176) 讨论了此问题的原因，并提议进行增强，以提高 Runner 克隆请求由从站点提供服务的可能性。
- 当单个 Git 代码仓库以足够高的速率接收推送时，从站点的本地副本可能会永远处于过期状态。这会导致该代码仓库的所有 Git 获取都被转发到主站点。有关更多信息，请参阅[议题 455870](https://gitlab.com/gitlab-org/gitlab/-/issues/455870)。
- [代理](secondary_proxy/_index.md)仅在 Puma 服务或 Web 服务中的极狐GitLab 应用程序中实现，因此其他服务无法从这种行为中受益。您应使用[单独的 URL](secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site) 以确保请求始终发送到主站点。这些服务包括：
  - 极狐GitLab 容器镜像仓库 - [可以配置为使用单独的域](../packages/container_registry.md#configure-container-registry-under-its-own-domain)，例如 `registry.example.com`。从站点容器镜像仓库仅用于灾难恢复。不应将用户路由到它们，尤其是推送，因为数据不会传播到主站点。
  - GitLab Pages - 应始终使用单独的域，作为[运行 GitLab Pages 的先决条件](../pages/_index.md#prerequisites)的一部分。
- 使用[统一 URL](secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites) 时，Let's Encrypt 无法生成证书，除非它可以通过同一域访问两个 IP。要将 TLS 证书与 Let's Encrypt 一起使用，您可以手动将域指向其中一个 Geo 站点，生成证书，然后将其复制到所有其他站点。
- 当[从站点使用与主站点不同的 URL](secondary_proxy/_index.md#set-up-a-separate-url-for-a-secondary-geo-site) 时，仅当 SAML 身份提供商 (IdP) 允许为应用程序配置多个回调 URL 时，才支持[使用 SAML 登录从站点](replication/single_sign_on.md#saml-with-separate-url-with-proxying-enabled)。
- 如果从站点在请求发起时不是最新的，并且 `geo_proxy_fetch_ssh_to_primary` 功能标志被禁用，则通过 SSH 针对从站点使用 `--depth` 选项的 Git 克隆和获取请求会无限期挂起。有关更多信息，请参阅[议题 391980](https://gitlab.com/gitlab-org/gitlab/-/issues/391980)。该功能标志在极狐GitLab 19.4 及更高版本中默认启用。使用捆绑 NGINX Ingress 的 Cloud Native GitLab 部署必须[在升级到 19.4 之前采取措施](replication/troubleshooting/ssh_proxying.md#ssh-pull-and-push-hang-indefinitely-on-cloud-native-deployments-using-nginx-ingress)。
- 不要将[相对 URL](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-a-relative-url-for-gitlab)
  与极狐GitLab Geo 一起使用，因为它们会破坏站点之间的代理。有关更多信息，请参阅
  [议题 456427](https://gitlab.com/gitlab-org/gitlab/-/issues/456427)。

<a id="replicated-data-types"></a>

### 复制的数据类型

有所有极狐GitLab [数据类型](replication/datatypes.md)和[复制的数据类型](replication/datatypes.md#replicated-data-types)的完整列表。

<a id="post-installation-documentation"></a>

## 安装后文档

在从站点上安装极狐GitLab并执行初始配置后，请参阅以下文档以获取安装后信息。

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

<a id="resyncing-and-reverifying-data"></a>

### 重新同步和重新验证数据

有关手动重试单个组件或批量复制或验证的更多信息，请参阅[重新同步和重新验证 Geo 数据](replication/resync_reverify.md)。

<a id="background-jobs"></a>

### 后台作业

有关 Geo 后台工作进程、其队列安全性和恢复机制的更多信息，请参阅 [Geo 后台作业](replication/background_jobs.md)。

<a id="backfill"></a>

### 回填

设置从站点后，它会开始从主站点复制缺失的数据，这一过程称为**回填**。您可以在浏览器中从主站点的 **Geo 节点** 仪表板监控每个 Geo 站点上的同步过程。

回填期间发生的失败计划在回填结束时重试。

<a id="runners"></a>

### Runner

- 除了我们部署 [Runner 集群](https://gitlab.cn/docs/runner/fleet_scaling/)的标准最佳实践外，Runner 还可以配置为连接到 Geo 从站点以分散作业负载。请参阅如何[针对从站点注册 Runner](secondary_proxy/runners.md)。
- 另请参阅如何处理[故障转移期间的 Runner 连接](disaster_recovery/planned_failover.md#runner-connectivity-during-failover)。

<a id="upgrading-geo"></a>

### 升级 Geo

有关如何将您的 Geo 站点更新到最新极狐GitLab 版本的信息，请参阅[升级 Geo 站点](replication/upgrading_the_geo_sites.md)。

<a id="security-review"></a>

### 安全审查

有关 Geo 安全性的更多信息，请参阅 [Geo 安全审查](replication/security_review.md)。

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

## 故障排除

- 有关 Geo 故障排除步骤，请参阅 [Geo 故障排除](replication/troubleshooting/_index.md)。
- 有关灾难恢复故障排除步骤，请参阅[故障排除 Geo 故障转移](disaster_recovery/failover_troubleshooting.md)。
