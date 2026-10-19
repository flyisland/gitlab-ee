---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo 安全审查（问答）
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下针对 Geo 功能集的安全审查重点关注该功能在安全方面的表现，适用于运行自有极狐GitLab 实例的客户。审查问题部分基于 [OWASP 应用安全验证标准项目](https://owasp.org/www-project-application-security-verification-standard/)（来自 [owasp.org](https://owasp.org/)）。

<a id="business-model"></a>

## 业务模式

<a id="what-geographic-areas-does-the-application-service"></a>

### 该应用服务覆盖哪些地理区域？

- 因客户而异。Geo 允许客户部署到多个区域，具体位置由客户自行选择。
- 区域和节点的选择完全手动进行。

<a id="data-essentials"></a>

## 数据要点

<a id="what-data-does-the-application-receive-produce-and-process"></a>

### 该应用接收、产生和处理哪些数据？

- Geo 会在各站点之间流式传输极狐GitLab 实例持有的几乎所有数据。这包括完整的数据库复制、大多数文件（例如用户上传的附件）以及代码仓库和 Wiki 数据。在典型配置中，这些传输会经过公共互联网，并使用 TLS 加密。
- PostgreSQL 复制使用 TLS 加密。
- 另请参阅：[应仅支持 TLSv1.2](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/2948)

<a id="how-can-the-data-be-classified-into-categories-according-to-its-sensitivity"></a>

### 如何根据敏感程度将数据分类？

- 极狐GitLab 的敏感度模型围绕公开、内部和私有项目展开。Geo 会不加区分地复制所有项目。文件和代码仓库（但不包括数据库内容）支持“选择性同步”，因此如有需要，可以只将敏感度较低的项目复制到从站点。

<a id="what-data-backup-and-retention-requirements-have-been-defined-for-the-application"></a>

### 为该应用定义了哪些数据备份和保留要求？

- Geo 旨在复制应用数据的某个子集。它是解决方案的一部分，而不是问题的一部分。

<a id="end-users"></a>

## 最终用户

<a id="who-are-the-applications-end-users"></a>

### 该应用的最终用户是谁？

- 从站点创建在距离主站点的极狐GitLab 安装较远（就互联网延迟而言）的区域。它们面向任何通常使用主站点、但发现从站点距离自己更近（就互联网延迟而言）的用户。

<a id="how-do-the-end-users-interact-with-the-application"></a>

### 最终用户如何与该应用交互？

- 从站点提供主站点提供的所有接口（尤其是 HTTP/HTTPS Web 应用，以及 HTTP/HTTPS 或 SSH 的 Git 代码仓库访问），但被限制为只读操作。主要用例设想为在从站点而非主站点克隆 Git 代码仓库，但最终用户也可以使用极狐GitLab Web 界面查看项目、议题、合并请求和代码片段等信息。

<a id="what-security-expectations-do-the-end-users-have"></a>

### 最终用户有哪些安全预期？

- 复制过程必须是安全的。例如，以明文形式通过公共互联网传输整个数据库内容或所有文件和代码仓库通常是不可接受的。
- 从站点对其内容必须具有与主站点相同的访问控制——未认证用户不得通过查询从站点获取主站点上的特权信息。
- 攻击者不得能够向主站点冒充从站点，从而获取特权信息。

<a id="administrators"></a>

## 管理员

<a id="who-has-administrative-capabilities-in-the-application"></a>

### 谁在该应用中拥有管理能力？

- 没有 Geo 特有的内容。数据库中设置了 `admin: true`的任何用户都被视为拥有超级用户权限的管理员。
- 另请参阅：[更细粒度的访问控制](https://gitlab.com/gitlab-org/gitlab/-/issues/18242)（并非 Geo 特有）。
- Geo 的许多集成（例如数据库复制）必须随应用一起配置，通常由系统管理员完成。

<a id="what-administrative-capabilities-does-the-application-offer"></a>

### 该应用提供哪些管理能力？

- 拥有管理访问权限的用户可以添加、修改或移除从站点。
- 可以通过 Sidekiq 管理控制项控制（启动/停止）复制过程。

<a id="network"></a>

## 网络

<a id="what-details-regarding-routing-switching-firewalling-and-load-balancing-have-been-defined"></a>

### 定义了哪些关于路由、交换、防火墙和负载均衡的细节？

- Geo 要求主站点和从站点能够通过 TCP/IP 网络相互通信。特别是，从站点必须能够访问主站点上的 HTTP/HTTPS 和 PostgreSQL 服务。

<a id="what-core-network-devices-support-the-application"></a>

### 哪些核心网络设备支持该应用？

- 因客户而异。

<a id="what-network-performance-requirements-exist"></a>

### 存在哪些网络性能要求？

- 主站点与从站点之间的最大复制速度受站点之间可用带宽的限制。不存在硬性要求——完成复制所需的时间（以及跟上主站点变更的能力）取决于数据集大小、对延迟的容忍度以及可用网络容量。

<a id="what-private-and-public-network-links-support-the-application"></a>

### 哪些私有和公共网络链路支持该应用？

- 客户自行选择网络。由于站点在地理上被设计为相互分离，在典型部署中，复制流量预计会经过公共互联网，但这并非硬性要求。

<a id="systems"></a>

## 系统

<a id="what-operating-systems-support-the-application"></a>

### 哪些操作系统支持该应用？

- Geo 对操作系统不施加额外限制（更多详情请参见[极狐GitLab 安装](https://gitlab.cn/install)页面），但我们建议使用 [Geo 文档](../_index.md#requirements-for-running-geo)中列出的操作系统。

<a id="what-details-regarding-required-os-components-and-lock-down-needs-have-been-defined"></a>

### 定义了哪些关于所需操作系统组件和锁定要求的细节？

- 受支持的 Linux 软件包安装方式会自行打包大多数组件。
- 对系统安装的 OpenSSH 守护进程（Geo 要求用户设置自定义认证方式）以及 Linux 软件包提供或系统提供的 PostgreSQL 守护进程存在重要依赖（必须将其配置为监听 TCP，必须添加额外用户和复制槽等）。
- 处理安全更新（例如，如果 OpenSSH 或其他服务存在重大漏洞，而客户希望在操作系统上修补这些服务）的流程与非 Geo 场景相同：OpenSSH 的安全更新会通过常规发行渠道提供给用户。Geo 不会在这方面引入延迟。

<a id="infrastructure-monitoring"></a>

## 基础设施监控

<a id="what-network-and-system-performance-monitoring-requirements-have-been-defined"></a>

### 定义了哪些网络和系统性能监控要求？

- 没有 Geo 特有的要求。

<a id="what-mechanisms-exist-to-detect-malicious-code-or-compromised-application-components"></a>

### 存在哪些机制来检测恶意代码或被入侵的应用组件？

- 没有 Geo 特有的机制。

<a id="what-network-and-system-security-monitoring-requirements-have-been-defined"></a>

### 定义了哪些网络和系统安全监控要求？

- 没有 Geo 特有的要求。

<a id="virtualization-and-externalization"></a>

## 虚拟化与外部化

<a id="what-aspects-of-the-application-lend-themselves-to-virtualization"></a>

### 该应用的哪些方面适合虚拟化？

- 全部。

<a id="what-virtualization-requirements-have-been-defined-for-the-application"></a>

## 为该应用定义了哪些虚拟化要求？

- 没有 Geo 特有的要求，但极狐GitLab 中的一切都需要在此类环境中具备完整功能。

<a id="what-aspects-of-the-product-may-or-may-not-be-hosted-via-the-cloud-computing-model"></a>

### 该产品的哪些方面可以或不可以采用云计算模式托管？

- 极狐GitLab 是“云原生”的，这一点同样适用于 Geo 以及产品的其余部分。在云中部署是常见且受支持的场景。

<a id="if-applicable-what-approaches-to-cloud-computing-are-taken"></a>

## 如适用，采用了哪些云计算方式？

- 是否使用这些方式由我们的客户根据其运营需求决定：

  - 托管主机与“纯”云
  - “完整机器”方式（如 AWS-ED2）与“托管数据库”方式（如 AWS-RDS 和 Azure）

<a id="environment"></a>

## 环境

<a id="what-frameworks-and-programming-languages-have-been-used-to-create-the-application"></a>

### 使用了哪些框架和编程语言来创建该应用？

- Ruby on Rails、Ruby。

<a id="what-process-code-or-infrastructure-dependencies-have-been-defined-for-the-application"></a>

### 为该应用定义了哪些流程、代码或基础设施依赖？

- 没有 Geo 特有的依赖。

<a id="what-databases-and-application-servers-support-the-application"></a>

### 哪些数据库和应用服务器支持该应用？

- PostgreSQL >= 12、Redis、Sidekiq、Puma。

<a id="how-to-protect-database-connection-strings-encryption-keys-and-other-sensitive-components"></a>

### 如何保护数据库连接字符串、加密密钥和其他敏感组件？

- 有一些 Geo 特有的值。其中一些是共享密钥，必须在设置时从主站点安全地传输到从站点。我们的文档建议通过 SSH 将它们从主站点传输给系统管理员，再以同样方式传输到从站点。具体而言，这包括 PostgreSQL 复制凭据以及用于解密数据库中某些列的密钥（`db_key_base`）。`db_key_base` 密钥以未加密形式存储在文件系统上的 `/etc/gitlab/gitlab-secrets.json`中，与其他许多密钥放在一起。它们没有静态保护。

<a id="data-processing"></a>

## 数据处理

<a id="what-data-entry-paths-does-the-application-support"></a>

### 该应用支持哪些数据输入路径？

- 数据通过极狐GitLab 自身暴露的 Web 应用输入。部分数据也通过在极狐GitLab 服务器上执行系统管理命令输入（例如 `gitlab-ctl set-primary-node`）。
- 从站点还通过来自主站点的 PostgreSQL 流式复制接收输入。

<a id="what-data-output-paths-does-the-application-support"></a>

### 该应用支持哪些数据输出路径？

- 主站点通过 PostgreSQL 流式复制输出到从站点。除此之外，主要通过极狐GitLab 自身暴露的 Web 应用，以及最终用户发起的 SSH `git clone` 操作输出。

<a id="how-does-data-flow-across-the-applications-internal-components"></a>

### 数据如何在该应用的内部组件之间流动？

- 从站点和主站点通过 HTTP/HTTPS（使用 JSON Web 令牌保护）以及 PostgreSQL 流式复制进行交互。
- 在主站点或从站点内部，单一事实来源（SSOT）是文件系统和数据库（在从站点上还包括 Geo 跟踪数据库）。各种内部组件经过编排，对这些存储进行更改。

<a id="what-data-input-validation-requirements-have-been-defined"></a>

### 定义了哪些数据输入验证要求？

- 从站点必须忠实复制主站点的数据。

<a id="what-data-does-the-application-store-and-how"></a>

### 该应用存储哪些数据，以及如何存储？

- Git 代码仓库和文件、与它们相关的跟踪信息，以及极狐GitLab 数据库内容。

<a id="what-data-should-be-encrypted-what-key-management-requirements-are-defined"></a>

### 哪些数据应加密？定义了哪些密钥管理要求？

- 主站点和从站点都不对静态的 Git 代码仓库或文件系统数据加密。部分数据库列使用 `db_otp_key` 进行静态加密。
- 一个在极狐GitLab 部署中所有主机之间共享的静态密钥。
- 在传输过程中，数据应加密，尽管该应用允许以未加密方式继续通信。两个主要传输是用于 PostgreSQL 的从站点复制过程，以及用于 Git 代码仓库/文件的复制过程。两者都应使用 TLS 保护，其密钥由 Linux 软件包按照最终用户访问极狐GitLab 的现有配置进行管理。

<a id="what-capabilities-exist-to-detect-the-leakage-of-sensitive-data"></a>

### 存在哪些检测敏感数据泄露的能力？

- 存在全面的系统日志，跟踪与极狐GitLab 和 PostgreSQL 的每一次连接。

<a id="what-encryption-requirements-have-been-defined-for-data-in-transit"></a>

### 为传输中的数据定义了哪些加密要求？

- （这包括通过 WAN、LAN、SecureFTP 或可公开访问的协议（如 `http:` 和 `https:`）进行的传输。）
- 数据必须能够选择在传输中加密，并且必须能够抵御被动和主动攻击（例如，不应可能发生 MITM 攻击）。

<a id="access"></a>

## 访问

<a id="what-user-privilege-levels-does-the-application-support"></a>

### 该应用支持哪些用户权限级别？

- Geo 增加了一种权限类型：从站点可以访问特殊的 Geo API，以通过 HTTP/HTTPS 下载文件，并使用 HTTP/HTTPS 克隆代码仓库。

<a id="what-user-identification-and-authentication-requirements-have-been-defined"></a>

### 定义了哪些用户身份识别和认证要求？

- 从站点通过基于共享数据库的 OAuth 或 JWT 认证（HTTP 访问）或 PostgreSQL 复制用户（用于数据库复制）向 Geo 主站点进行身份识别。数据库复制还要求定义基于 IP 的访问控制。

<a id="what-user-authorization-requirements-have-been-defined"></a>

### 定义了哪些用户授权要求？

- 从站点必须只能读取数据。它们不能更改主站点上的数据。

<a id="what-session-management-requirements-have-been-defined"></a>

### 定义了哪些会话管理要求？

- Geo JWT 被定义为仅持续两分钟，之后需要重新生成。
- Geo JWT 针对以下特定范围之一生成：
  - Geo API 访问。
  - Git 访问。
  - LFS 和文件 ID。
  - 上传和文件 ID。
  - 作业产物和文件 ID。

<a id="what-access-requirements-have-been-defined-for-uri-and-service-calls"></a>

### 为 URI 和服务调用定义了哪些访问要求？

- 从站点会对主站点的 API 发起许多调用。例如，文件复制就是这样进行的。此端点只能使用 JWT 令牌访问。
- 主站点也会调用从站点以获取状态信息。

<a id="application-monitoring"></a>

## 应用监控

<a id="how-are-audit-and-debug-logs-accessed-stored-and-secured"></a>

### 如何访问、存储和保护审计日志和调试日志？

- 结构化 JSON 日志写入文件系统，也可以摄取到 Kibana 安装中进行进一步分析。
