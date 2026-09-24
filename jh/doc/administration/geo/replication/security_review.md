---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo 安全审查 (问答)
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下对 Geo 功能集的安全审查聚焦于该功能的安全方面，因为它们适用于运行自己的极狐GitLab 实例的客户。审查问题部分基于 [OWASP 应用程序安全验证标准项目](https://owasp.org/www-project-application-security-verification-standard/)，来自 [owasp.org](https://owasp.org/)。

<a id="business-model"></a>

## 业务模型

<a id="what-geographic-areas-does-the-application-service"></a>

### 应用程序服务于哪些地理区域？

- 这因客户而异。Geo 允许客户部署到多个区域，他们可以自行选择部署位置。
- 区域和节点的选择完全手动完成。

<a id="data-essentials"></a>

## 数据要点

<a id="what-data-does-the-application-receive-produce-and-process"></a>

### 应用程序接收、生成和处理哪些数据？

- Geo 在站点之间流式传输极狐GitLab 实例所持有的几乎所有数据。这包括完整的数据库复制、大多数文件（例如用户上传的附件）以及仓库和 Wiki 数据。在典型配置中，这些操作将通过公共互联网进行，并采用 TLS 加密。
- PostgreSQL 复制是 TLS 加密的。
- 另请参阅：[仅应支持 TLSv1.2](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/2948)

<a id="how-can-the-data-be-classified-into-categories-according-to-its-sensitivity"></a>

### 如何根据数据敏感性对数据进行分类？

- 极狐GitLab 的敏感性模型以公开、内部和私有项目为中心。Geo 会不加区分地复制所有项目。对于文件和仓库（但不包括数据库内容）存在“选择性同步”功能，该功能允许根据需要仅将敏感性较低的项目复制到 **次要** 站点。

<a id="what-data-backup-and-retention-requirements-have-been-defined-for-the-application"></a>

### 为应用程序定义了哪些数据备份和保留要求？

- Geo 旨在提供应用程序数据的特定子集的复制。它是解决方案的一部分，而非问题的一部分。

<a id="end-users"></a>

## 最终用户

<a id="who-are-the-applications-end-users"></a>

### 谁是应用程序的最终用户？

- 创建 **次要** 站点的区域，在互联网延迟方面与主 极狐GitLab 安装（**主要** 站点）相距较远。它们旨在供通常使用 **主要** 站点的任何用户使用，这些用户会发现 **次要** 站点（在互联网延迟方面）距离他们更近。

<a id="how-do-the-end-users-interact-with-the-application"></a>

### 最终用户如何与应用程序交互？

- **次要** 站点提供 **主要** 站点所提供的所有接口（尤其是 HTTP/HTTPS Web 应用程序，以及 HTTP/HTTPS 或 SSH Git 仓库访问），但仅限于只读活动。预期的主要用例是从 **次要** 站点克隆 Git 仓库，而不是从 **主要** 站点，但最终用户可以使用 极狐GitLab Web 界面查看项目、议题、合并请求和代码片段等信息。

<a id="what-security-expectations-do-the-end-users-have"></a>

### 最终用户有哪些安全期望？

- 复制过程必须是安全的。例如，通常不会接受以明文形式通过公共互联网传输全部数据库内容或所有文件和仓库。
- **次要** 站点必须对其内容拥有与 **主要** 站点相同的访问控制——未经身份验证的用户不得通过查询 **次要** 站点来获取 **主要** 站点的特权信息。
- 攻击者不得能够向 **主要** 站点冒充 **次要** 站点，从而获取特权信息。

<a id="administrators"></a>

## 管理员

<a id="who-has-administrative-capabilities-in-the-application"></a>

### 谁在应用程序中拥有管理职能？

- 无 Geo 特定内容。数据库中设置了 `admin: true` 的任何用户都被视为具有超级用户权限的管理员。
- 另请参阅：[更细粒度的访问控制](https://gitlab.com/gitlab-org/gitlab/-/issues/18242)（非 Geo 特定）。
- Geo 的大部分集成（例如数据库复制）必须由系统管理员在应用程序中进行配置。

<a id="what-administrative-capabilities-does-the-application-offer"></a>

### 应用程序提供了哪些管理功能？

- 具有管理访问权限的用户可以添加、修改或移除 **次要** 站点。
- 可以通过 Sidekiq 管理控制来控制（启动/停止）复制过程。

<a id="network"></a>

## 网络

<a id="what-details-regarding-routing-switching-firewalling-and-load-balancing-have-been-defined"></a>

### 已定义了有关路由、交换、防火墙和负载均衡的哪些详细信息？

- Geo 要求 **主要** 站点和 **次要** 站点能够通过 TCP/IP 网络相互通信。特别地，**次要** 站点必须能够访问 **主要** 站点上的 HTTP/HTTPS 和 PostgreSQL 服务。

<a id="what-core-network-devices-support-the-application"></a>

### 哪些核心网络设备支持该应用程序？

- 因客户而异。

<a id="what-network-performance-requirements-exist"></a>

### 存在哪些网络性能要求？

- **主要** 站点和 **次要** 站点之间的最大复制速度受站点间可用带宽的限制。没有硬性要求——完成复制的时间（以及跟上 **主要** 站点更改的能力）取决于数据集大小、对延迟的容忍度以及可用网络容量。

<a id="what-private-and-public-network-links-support-the-application"></a>

### 哪些私有和公共网络链接支持该应用程序？

- 客户选择自己的网络。由于站点旨在地理上相隔，在典型部署中，复制流量预计会经过公共互联网，但这不是必需的。

<a id="systems"></a>

## 系统

<a id="what-operating-systems-support-the-application"></a>

### 支持哪些操作系统运行该应用程序？

- Geo 对操作系统没有额外限制（有关更多详细信息，请参阅 [极狐GitLab 安装](https://gitlab.cn/install/) 页面），但我们建议使用 [Geo 文档](../_index.md#requirements-for-running-geo) 中列出的操作系统。

<a id="what-details-regarding-required-os-components-and-lock-down-needs-have-been-defined"></a>

### 已定义了有关所需操作系统组件和锁定需求的哪些详细信息？

- 受支持的 Linux 软件包安装方法会自行打包大多数组件。
- 对系统安装的 OpenSSH 守护进程（Geo 要求用户设置自定义身份验证方法）以及 Linux 软件包提供或系统提供的 PostgreSQL 守护进程（必须配置为监听 TCP，必须添加额外用户和复制槽等）存在重大依赖。
- 处理安全更新的过程（例如，如果 OpenSSH 或其他服务中存在重大漏洞，并且客户想要在操作系统上修补这些服务）与非 Geo 情况相同：OpenSSH 的安全更新将通过通常的分发渠道提供给用户。Geo 不会在此过程中引入延迟。

<a id="infrastructure-monitoring"></a>

## 基础设施监控

<a id="what-network-and-system-performance-monitoring-requirements-have-been-defined"></a>

### 已定义了哪些网络和系统性能监控要求？

- 无特定于 Geo 的要求。

<a id="what-mechanisms-exist-to-detect-malicious-code-or-compromised-application-components"></a>

### 存在哪些机制来检测恶意代码或受损的应用程序组件？

- 无特定于 Geo 的机制。

<a id="what-network-and-system-security-monitoring-requirements-have-been-defined"></a>

### 已定义了哪些网络和系统安全监控要求？

- 无特定于 Geo 的要求。

<a id="virtualization-and-externalization"></a>

## 虚拟化和外部化

<a id="what-aspects-of-the-application-lend-themselves-to-virtualization"></a>

### 应用程序的哪些方面适合虚拟化？

- 全部。

<a id="what-virtualization-requirements-have-been-defined-for-the-application"></a>

### 为应用程序定义了哪些虚拟化要求？

- 没有 Geo 特定的要求，但 极狐GitLab 中的所有内容都需要在这样的环境中具有完整的功能。

<a id="what-aspects-of-the-product-may-or-may-not-be-hosted-via-the-cloud-computing-model"></a>

### 产品的哪些方面可以通过云计算模型托管，哪些不能？

- 极狐GitLab 是“云原生”的，这同样适用于 Geo 以及产品的其余部分。在云中部署是一种常见且受支持的场景。

<a id="if-applicable-what-approaches-to-cloud-computing-are-taken"></a>

### 如果适用，采用了哪些云计算方式？

- 是否使用这些由我们的客户根据其运维需求决定：
  - 托管式托管对比“纯”云
  - “整机”方式，例如 AWS-ED2，对比“托管数据库”方式，例如 AWS-RDS 和 Azure

<a id="environment"></a>

## 环境

<a id="what-frameworks-and-programming-languages-have-been-used-to-create-the-application"></a>

### 使用了哪些框架和编程语言来创建应用程序？

- Ruby on Rails，Ruby。

<a id="what-process-code-or-infrastructure-dependencies-have-been-defined-for-the-application"></a>

### 为应用程序定义了哪些流程、代码或基础设施依赖？

- 无特定于 Geo 的内容。

<a id="what-databases-and-application-servers-support-the-application"></a>

### 哪些数据库和应用程序服务器支持该应用程序？

- PostgreSQL >= 12，Redis，Sidekiq，Puma。

<a id="how-to-protect-database-connection-strings-encryption-keys-and-other-sensitive-components"></a>

### 如何保护数据库连接字符串、加密密钥和其他敏感组件？

- 有一些特定于 Geo 的值。其中一些是需要在设置时从 **主要** 站点安全传输到 **次要** 站点的共享密钥。我们的文档建议通过 SSH 将它们从 **主要** 站点传输到系统管理员，然后以相同的方式传输回 **次要** 站点。特别是，这包括 PostgreSQL 复制凭据和一个用于解密数据库中某些列的密钥(`db_key_base`)。`db_key_base` 密钥未加密地存储在文件系统上的 `/etc/gitlab/gitlab-secrets.json` 中，与其他许多密钥一起。它们没有静态保护。

<a id="data-processing"></a>

## 数据处理

<a id="what-data-entry-paths-does-the-application-support"></a>

### 应用程序支持哪些数据输入路径？

- 数据通过 极狐GitLab 自身公开的 Web 应用程序输入。一些数据也通过在 极狐GitLab 服务器上使用系统管理命令（例如 `gitlab-ctl set-primary-node`）输入。
- **次要** 站点也通过来自 **主要** 站点的 PostgreSQL 流复制接收输入。

<a id="what-data-output-paths-does-the-application-support"></a>

### 应用程序支持哪些数据输出路径？

- **主要** 站点通过 PostgreSQL 流复制向 **次要** 站点输出。否则，主要通过 极狐GitLab 自身公开的 Web 应用程序，以及通过最终用户发起的 SSH `git clone` 操作输出。

<a id="how-does-data-flow-across-the-applications-internal-components"></a>

### 数据如何在应用程序的内部组件之间流动？

- **次要** 站点和 **主要** 站点通过 HTTP/HTTPS（使用 JSON Web 令牌保护）以及 PostgreSQL 流复制进行交互。
- 在 **主要** 站点或 **次要** 站点内，SSOT 是文件系统和数据库（包括 **次要** 站点上的 Geo 跟踪数据库）。编排各种内部组件以对这些存储进行更改。

<a id="what-data-input-validation-requirements-have-been-defined"></a>

### 已定义了哪些数据输入验证要求？

- **次要** 站点必须进行 **主要** 站点数据的忠实复制。

<a id="what-data-does-the-application-store-and-how"></a>

### 应用程序存储哪些数据以及如何存储？

- Git 仓库和文件、与之相关的跟踪信息以及 极狐GitLab 数据库内容。

<a id="what-data-should-be-encrypted-what-key-management-requirements-are-defined"></a>

### 哪些数据应该加密？定义了哪些密钥管理要求？

- **主要** 站点或 **次要** 站点均不加密静态 Git 仓库或文件系统数据。使用 `db_otp_key` 对一部分数据库列进行静态加密。
- 一个在 极狐GitLab 部署中所有主机之间共享的静态密钥。
- 在传输过程中，数据应该加密，尽管应用程序确实允许通信在不加密的情况下进行。两个主要的传输部分是 **次要** 站点的 PostgreSQL 复制过程以及 Git 仓库/文件的复制过程。两者都应使用 TLS 进行保护，其密钥由 Linux 软件包根据最终用户访问 极狐GitLab 的现有配置进行管理。

<a id="what-capabilities-exist-to-detect-the-leakage-of-sensitive-data"></a>

### 存在哪些检测敏感数据泄露的功能？

- 存在全面的系统日志，记录每次连接到 极狐GitLab 和 PostgreSQL 的情况。

<a id="what-encryption-requirements-have-been-defined-for-data-in-transit"></a>

### 为传输中的数据定义了哪些加密要求？

- （这包括通过广域网、局域网、SecureFTP 或诸如 `http:` 和 `https:` 等公共可访问协议的传输。）
- 数据必须能够选择在传输过程中加密，并且能够抵御被动和主动攻击（例如，不应可能发生 MITM 攻击）。

<a id="access"></a>

## 访问

<a id="what-user-privilege-levels-does-the-application-support"></a>

### 应用程序支持哪些用户权限级别？

- Geo 增加了一种权限类型：**次要** 站点可以访问特殊的 Geo API 以通过 HTTP/HTTPS 下载文件，并使用 HTTP/HTTPS 克隆仓库。

<a id="what-user-identification-and-authentication-requirements-have-been-defined"></a>

### 已定义了哪些用户标识和身份验证要求？

- **次要** 站点通过基于共享数据库（HTTP 访问）的 OAuth 或 JWT 身份验证，或者 PostgreSQL 复制用户（用于数据库复制）向 Geo **主要** 站点标识身份。数据库复制还需要定义基于 IP 的访问控制。

<a id="what-user-authorization-requirements-have-been-defined"></a>

### 已定义了哪些用户授权要求？

- **次要** 站点必须只能读取数据。它们不能在 **主要** 站点上变更数据。

<a id="what-session-management-requirements-have-been-defined"></a>

### 已定义了哪些会话管理要求？

- Geo JWT 被定义为仅持续两分钟就需要重新生成。
- Geo JWT 为以下特定范围之一生成：
  - Geo API 访问。
  - Git 访问。
  - LFS 和 File ID。
  - 上传和 File ID。
  - 作业产物和 File ID。

<a id="what-access-requirements-have-been-defined-for-uri-and-service-calls"></a>

### 为 URI 和服务调用定义了哪些访问要求？

- **次要** 站点会多次调用 **主要** 站点的 API。例如，这就是文件复制进行的方式。此端点只能通过 JWT 令牌访问。
- **主要** 站点也会调用 **次要** 站点以获取状态信息。

<a id="application-monitoring"></a>

## 应用程序监控

<a id="how-are-audit-and-debug-logs-accessed-stored-and-secured"></a>

### 如何访问、存储和保护审计和调试日志？

- 结构化 JSON 日志写入文件系统，也可以导入 Kibana 安装中以进行进一步分析。