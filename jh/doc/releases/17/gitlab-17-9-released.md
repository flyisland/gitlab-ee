---
stage: Release Notes
group: Monthly Release
date: 2025-02-20
title: "极狐GitLab 17.9 发布说明"
description: "GitLab 17.9 released with GitLab Duo Self-Hosted is generally available"
---

<!-- markdownlint-disable -->
<!-- vale off -->

在 2025 年 2 月 20 日，极狐GitLab 17.9 发布，包含以下功能。

## 主要功能

### 极狐GitLab Duo 自部署现已正式可用

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/517102)

{{< /details >}}

您现在可以在自己的基础设施中托管选定的模型，并将这些模型配置为极狐GitLab Duo 代码建议和极狐GitLab Duo Chat 的来源。此功能在符合条件的私有化部署极狐GitLab 环境中已正式可用。

通过极狐GitLab Duo 自部署，您可以使用托管在本地或私有云中的模型作为极狐GitLab Duo Chat 或代码建议的来源。我们目前支持在 vLLM 或 AWS Bedrock 上运行的开源 Mistral 模型，以及国内 SOTA 模型。通过启用自部署模型，您可以在享受生成式 AI 强大能力的同时，保持完整的数据主权和隐私。

### 并行部署运行多个 Pages 站点

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/_index.md#parallel-deployments) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/14434)

{{< /details >}}

您现在可以同时创建多个版本的极狐GitLab Pages 站点，通过并行部署的方式。每次部署都会根据您配置的前缀获得唯一的 URL。例如，如果使用唯一域名，您的站点可以通过 `namespace.gitlab.io/project/prefix` 访问（或者如果有唯一域名则为 `project-123456.gitlab.io/prefix`）。

此功能在以下情况下特别有用：

- 预览设计更改或内容更新。
- 在生产环境中测试站点更改。
- 审查合并请求中的更改。
- 维护多个站点版本（例如，包含本地化内容）。

默认情况下，并行部署在 24 小时后过期，以帮助管理存储空间，但您可以自定义此持续时间或设置部署永不过期。对于自动清理，从合并请求创建的并行部署在合并请求合并或关闭时被删除。

### 通过 Sysbox 支持工作区容器

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/configuration.md#build-and-run-containers-in-a-workspace)

{{< /details >}}

极狐GitLab 工作区现在支持在您的开发环境中直接构建和运行容器。当您的工作区在配置了 [Sysbox 的 Kubernetes 集群](../../user/workspace/configuration.md#with-sysbox) 上运行时，无需额外配置即可构建和运行容器。

此功能于极狐GitLab 17.4 中作为 [sudo 访问功能](https://gitlab.cn/releases/2024/09/19/gitlab-17-4-released/#secure-sudo-access-for-workspaces) 的一部分推出，使您能够在极狐GitLab 工作区环境中保留完整的容器工作流。

### 无需自定义 devfile 创建工作区

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/_index.md#gitlab-default-devfile)

{{< /details >}}

以前，设置工作区需要创建 `devfile.yaml` 配置文件。现在，极狐GitLab 为您提供了一个包含常用开发工具的默认文件。此增强功能：

- 消除了配置障碍。
- 使您能够从任何项目快速创建工作区。
- 包含预先配置并可立即使用的常用开发工具。
- 让您专注于开发而不是配置。

立即开始开发并创建工作区，无需额外的设置或配置步骤。

### 极狐GitLab 管理的 Kubernetes 资源

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/managed_kubernetes_resources.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/16130)

{{< /details >}}

使用 [极狐GitLab 管理的 Kubernetes 资源](../../user/clusters/agent/managed_kubernetes_resources.md)，您可以以更高的控制力和自动化方式将应用部署到 Kubernetes。以前，您必须为每个环境手动配置 Kubernetes 资源。现在，您可以使用极狐GitLab 管理的 Kubernetes 资源来自动化地和提供商这些资源。

通过极狐GitLab 管理的 Kubernetes 资源，您可以：

- 自动为新环境创建命名空间和服务账号
- 通过角色绑定管理访问权限
- 配置其他所需的 Kubernetes 资源

当您的开发者部署应用时，极狐GitLab 会根据提供的资源模板自动创建必要的 Kubernetes 资源，从而简化部署流程并保持环境之间的一致性。

### 在项目环境中简化部署访问

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/505770)

{{< /details >}}

您是否曾经难以概览项目中的部署情况？现在，您可以在环境列表中查看最近的部署详情，而无需展开每个环境。对于每个环境，列表会显示您最新的成功部署，如果存在差异，还会显示最新的部署尝试。

### Wiki 页面评论

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/discussions/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/14062)

{{< /details >}}

您现在可以直接在 Wiki 页面上添加评论，将您的文档转变为交互式协作空间。

Wiki 页面的评论和讨论线程帮助团队：

- 在上下文中直接讨论内容。
- 提出改进和修正建议。
- 保持文档的准确性和时效性。
- 分享知识和专业技能。

通过 Wiki 评论，团队可以通过直接反馈和讨论维护与项目共同演进的实时文档。

### 增强工作流可见性：深入了解合并请求审查时间

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/value_stream_analytics/_index.md#value-stream-stage-events) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/503754)

{{< /details >}}

为了改善开发工作流跟踪，[价值流分析](https://gitlab.cn/solutions/value-stream-management/) (VSA) 新增了一个事件——*合并请求最后批准时间*。[合并请求审批](../../user/project/merge_requests/approvals/_index.md) 事件标志着审查阶段的结束，也标志着最终流水线运行或合并阶段的开始。例如，要计算合并请求的总体审查时间，您可以创建一个 VSA 阶段，以 *合并请求审核人首次分配* 作为开始事件，以 *合并请求最后批准时间* 作为结束事件。

通过这一增强功能，团队可以深入了解优化审查时间的机会，从而帮助缩短整体开发周期，加快软件交付。

### 用于漏洞风险优先级排序的 EPSS、KEV 和 CVSS 数据

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerabilities/risk_assessment_data.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11544)

{{< /details >}}

我们增加了对以下漏洞风险数据的支持：

- 漏洞利用预测评分系统 (EPSS)
- 已知被利用漏洞 (KEV)
- 通用漏洞与暴露 (CVE)

您现在可以利用这些数据，高效地对依赖项和容器镜像漏洞进行风险优先级排序。这些数据可以在漏洞报告和漏洞详情页面中找到。

### 通过 UI 配置 DAST 扫描，实现全面控制

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/on-demand_scan.md)

{{< /details >}}

为了有效测试复杂的应用，安全团队在配置 DAST 扫描时需要灵活性。以前，通过 UI 配置的 DAST 扫描配置选项有限，导致无法成功扫描具有特定安全要求的应用。这意味着即使进行快速安全评估，您也必须使用基于流水线的扫描。

现在，您可以通过 UI 配置 DAST 扫描，拥有与基于流水线的扫描相同的精细控制。这包括：

- 完整的身份验证配置，包括自定义标头和 Cookie
- 精确的爬网设置，如最大页数、最大深度和排除的 URL
- 高级扫描超时和重试尝试
- 自定义扫描器行为，如最大抓取链接数和 DOM 深度
- 针对特定漏洞类型的定向扫描模式

将这些配置保存为可复用的配置文件，以确保跨应用的安全测试保持一致。每次配置更改都会通过审计事件进行跟踪，因此您知道扫描设置何时被添加、编辑或删除。

这种增强的控制能力帮助您运行更高效的安全扫描，同时利用详细的审计跟踪保持合规性。您无需花时间管理流水线配置，而是可以快速为每个应用启动正确的扫描，从而更快地发现和修复漏洞。

### 自动 CI/CD 流水线清理

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/pipelines/settings.md#automatic-pipeline-cleanup) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/338480)

{{< /details >}}

过去，如果您想删除旧的 CI/CD 流水线，只能通过 API 实现。

在极狐GitLab 17.9 中，我们引入了一个项目设置，允许您设置 CI/CD 流水线过期时间。任何超过指定保留期的流水线及其相关产物都会被删除。这有助于减少运行大量流水线、生成大型产物的项目的磁盘使用量，甚至可能提升整体性能。

## Agentic Core

### 用于更安全 AI 连接的复合身份

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../development/ai_features/composite_identity.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/506641)

{{< /details >}}

以前，向极狐GitLab 发出的请求只能认证为单个用户。通过复合身份，我们现在可以同时将请求认证为服务账号和用户。
AI agent 用例通常需要权限基于在系统中发起任务的用户，同时显示与发起用户不同的独立身份。复合身份是我们新的身份主体，代表 AI agent 的身份。该身份与请求 agent 执行操作的人类用户身份关联。
每当 AI agent 操作尝试访问资源时，都会使用复合身份令牌。该令牌属于一个服务账号，同时也关联着指示 agent 的人类用户。在授权检查运行在令牌上时，会同时考虑两个主体，然后才授予资源访问权限。两个身份都需要有资源访问权限，否则访问将被拒绝。
这一新功能增强了我们保护存储在极狐GitLab 中资源的能力。
有关服务账号复合身份如何使用的更多信息，请参阅[文档](../../development/ai_features/composite_identity.md)。

## 扩展与部署

### 限制用户将个人资料设为私有

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/settings/account_and_limit_settings.md#prevent-users-from-making-their-profiles-private) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/421310)

{{< /details >}}

用户可以选择将自己的用户资料设为公开或私有。
管理员现在可以控制用户是否有权在整个极狐GitLab 实例中将资料设为私有。在管理区域中，“允许用户将资料设为私有”控制此设置。该设置默认启用，即允许用户选择私有资料。

### 通过 REST API 从群组管理项目集成

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/group_integrations.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/328496)

{{< /details >}}

以前，您只能在极狐GitLab UI 中从群组管理项目集成。随着本次发布，现在也可以通过 REST API 来管理这些集成。

感谢 [Van](https://jihulab.com/van.m.anderson) 的[最初社区贡献](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/148283)，该贡献随后由极狐GitLab 接手并完成。

### 群组共享可见性增强

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/members/sharing_projects_groups.md#view-shared-groups) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/378629)

{{< /details >}}

我们很高兴地宣布，极狐GitLab 中的群组共享可见性得到了扩展。以前，您可以在群组概览页面看到共享的项目，但无法看到您的群组被邀请加入了哪些群组。现在，您可以在群组概览页面同时看到 **共享项目** 和 **共享群组** 选项卡，让您全面了解群组在整个组织中的连接和共享情况。这使得在组织内审计和管理群组访问权限更加容易。

我们欢迎您就这一变在 [史诗 16777](https://jihulab.com/groups/gitlab-cn/-/epics/16777) 中提供反馈。

## 统一 DevOps 与安全

### 为 Cargo、Conda、Cocoapods 和 Swift 项目启用基于 SBOM 的依赖项扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/519597)

{{< /details >}}

在极狐GitLab 17.9 中，组合分析团队开始过渡到使用新的依赖项扫描分析器，采用基于 SBOM 的依赖项扫描。该分析器将取代 Gemnasium，后者将在 18.0 中达到支持终止，但在极狐GitLab 19.0 之前仍可使用。

采用基于 SBOM 的依赖项扫描方法将通过扩展语言支持、更紧密的平台集成和体验以及向行业标准报告类型（基于 SBOM 的扫描和报告）转变，更好地为客户服务。从极狐GitLab 17.9 开始，新的依赖项扫描分析器将在 `latest` Dependency Scanning CI/CD 模板 (`Dependency-Scanning.latest.gitlab-ci.yml`) 中默认启用，适用于以下项目和文件类型：

- 使用 conda 的 C/C++/Fortran/Go/Python/R 项目，具有 `conda-lock.yml` 文件。
- 使用 Cocoapods 的 Objective-C 项目，具有 `podfile.lock` 文件。
- 使用 Cargo 的 Rust 项目，具有 `cargo.lock` 文件。
- 使用 Swift 的 Swift 项目，具有 `package.resolved` 文件。

随着这一变更，我们引入了一个新的 CI/CD 变量：`DS_ENFORCE_NEW_ANALYZER`，默认设置为 `false`。

这种方法确保所有使用 `latest` 模板的现有客户继续默认使用 Gemnasium 分析器，并为上述文件类型自动启用新的依赖项扫描分析器。

希望迁移到新依赖项扫描分析器的现有客户可以将 `DS_ENFORCE_NEW_ANALYZER` 设置为 `true`（在项目、群组或实例级别）。您可以在[弃用公告](../../update/deprecations.md#dependency-scanning-upgrades-to-the-gitlab-sbom-vulnerability-scanner)和相关的[迁移指南](../../user/application_security/dependency_scanning/migration_guide_to_sbom_based_scans.md)中了解更多关于此变更的信息。

想要完全阻止使用新依赖项扫描分析器的客户必须将 CI/CD 变量 `DS_EXCLUDED_ANALYZERS` 设置为 `dependency-scanning`。

### 对 Swift 软件包的许可证扫描支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/506730)

{{< /details >}}

在极狐GitLab 17.9 中，我们增加了对 Swift 软件包的许可证扫描支持。这将使在项目中使用 Swift 的用户能够更好地了解其 Swift 软件包的许可证情况。

这些数据可通过依赖项列表、SBOM 报告和 GraphQL API 供组合分析用户使用。

### 多核 Advanced SAST 提供更快的扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/_index.md#security-scanner-configuration) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/514156)

{{< /details >}}

极狐GitLab Advanced SAST 现在提供多核扫描作为可选功能，以提升性能。
这可以显著缩短扫描时间，尤其是对于较大的代码库。

要启用它，请将 `SAST_SCANNER_ALLOWED_CLI_OPTS` CI/CD 变量设置为 `--multi-core N`，其中 `N` 是所需的核数。
您应仅针对 `gitlab-advanced-sast` 作业设置此变量，而不要针对其他作业。
查看[文档](../../user/application_security/sast/_index.md#security-scanner-configuration)了解如何正确选择该值的重要指导。

我们正在努力使此性能改进默认启用；请关注[议题 517409](https://jihulab.com/gitlab-cn/gitlab/-/issues/517409)。

### 使用项目合规中心应用合规框架

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_projects_report.md) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/issues/507986)

{{< /details >}}

在极狐GitLab 17.2 中，我们推出了让群组所有者能够通过群组合规中心为群组中所有项目应用和移除合规框架的功能。

我们对此进行了扩展，现在群组所有者也可以在项目级别应用和移除合规框架。
这将使群组所有者更轻松地在项目级别应用和监控合规框架。

在项目级别应用和移除合规框架的能力仅适用于群组所有者，而不适用于项目所有者。

### 工作区扩展现在支持提议的 API

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/_index.md#extension-marketplace)

{{< /details >}}

工作区扩展现在支持启用提议的 API，从而提高了生产环境中的兼容性和可靠性。此更新允许依赖提议的 API 的扩展无错误运行，包括关键的开发工具，如 Python 调试器。这一变更在保持稳定性的同时扩展了 API 访问。

### 使用 FluxCD CI/CD 组件实现基于 OCI 的 GitOps

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://jihulab.com/components/fluxcd/) | [相关议题](https://jihulab.com/gitlab-cn/ci-cd/deploy-stage/environments-group/experiments/fluxcd-ci-cd-component/-/issues/1)

{{< /details >}}

您是否曾想过如何使用极狐GitLab 实现 GitOps 最佳实践？新的 [FluxCD 组件](https://jihulab.com/components/fluxcd/) 使之变得简单。使用 FluxCD 组件将 Kubernetes manifest 打包成 OCI 镜像，并将镜像存储在兼容 OCI 的容器镜像仓库中。您可以选择对镜像进行签名，并触发立即的 FluxCD 调和。

### 开始使用极狐GitLab 与 Kubernetes 的集成

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/getting_started.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/505216)

{{< /details >}}

在此版本中，我们新增了 Kubernetes 入门指南，向您展示如何使用极狐GitLab 将应用程序直接部署到 Kubernetes 以及通过 FluxCD 部署。这些简单易懂的教程无需深入的 Kubernetes 知识即可完成，因此新手和经验丰富的用户都可以学习如何集成极狐GitLab 和 Kubernetes。

为了补充 Kubernetes 入门指南，我们还提供了一系列关于将极狐GitLab 集成到 Kubernetes 环境的建议。

<a id="discover-and-migrate-certificate-based-kubernetes-clusters"></a>

### 发现和迁移基于证书的 Kubernetes 集群

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../api/cluster_discovery.md) | Related issue

{{< /details >}}

基于证书的 Kubernetes 集成将于 2025 年 5 月 6 日 9:00 UTC 至 2025 年 5 月 8 日 22:00 UTC 期间在 JihuLab.com 上对所有用户关闭，并将在极狐GitLab 19.0（预计 2026 年 5 月）中从私有化部署实例中移除。

为了帮助用户迁移，我们新增了一个集群 API 端点，群组所有者可以查询该端点以[发现注册到群组、子群组或项目的任何基于证书的集群](../../api/cluster_discovery.md)。我们还更新了[迁移文档](../../user/infrastructure/clusters/migrate_to_gitlab_agent.md)，为不同类型的用例提供说明。

我们鼓励所有 JihuLab.com 用户检查是否受到影响，并尽快计划迁移。

<a id="enforce-custom-stages-in-pipeline-execution-policies"></a>

### 在流水线执行策略中强制执行自定义阶段

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/pipeline_execution_policies.md#inject_policy-type) | Related issue

{{< /details >}}

我们很高兴地推出流水线执行策略的一项新功能，允许您在 `Inject` 模式下将**自定义阶段**强制执行到 CI/CD 流水线中。此功能在保持安全性和合规性要求的同时，为流水线结构提供了更大的灵活性和控制力，为您提供：

- **增强的流水线定制**：在流水线的特定位置定义和注入自定义阶段，从而更精细地控制作业执行顺序。
- **改进的安全性和合规性**：确保安全扫描和合规性检查在流水线中最合适的时间运行，例如在构建之后但在部署之前。
- **灵活的策略管理**：保持集中式策略控制，同时允许开发团队在定义的护栏内自定义其流水线。
- **无缝集成**：自定义阶段与现有项目阶段和其他策略类型协同工作，以非破坏性的方式增强您的 CI/CD 工作流程。

**它是如何工作的？**

流水线执行策略的全新改进的 `inject_policy` 策略允许您在策略配置中定义自定义阶段。然后，这些阶段会使用有向无环图 (DAG) 算法与项目的现有阶段智能合并，确保正确的顺序并防止冲突。

例如，您现在可以轻松地在构建和部署阶段之间注入自定义安全扫描阶段。

`inject_policy` 阶段取代了即将弃用的 `inject_ci`，允许您选择加入 `inject_policy` 模式以获得好处。在策略编辑器中配置 `Inject` 策略时，`inject_policy` 模式将成为默认模式。

<a id="rotate-access-tokens-with-self_rotate-scope"></a>

### 使用 `self_rotate` 范围轮换访问令牌

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/profile/personal_access_tokens.md#personal-access-token-scopes) | Related issue

{{< /details >}}

您现在可以使用 `self_rotate` 范围来轮换访问令牌。此范围适用于个人、项目或群组访问令牌。以前，这需要两个请求：一个获取新令牌，然后另一个执行令牌轮换。

感谢 [Stéphane Talbot](https://jihulab.com/stalb) 和 [Anthony Juckel](https://jihulab.com/ajuckel) 的贡献！

<a id="view-inactive-project-and-group-access-tokens"></a>

### 查看非活跃的项目和群组访问令牌

{{< details >}}

- Tier: 基础版，专业版，旗舰版，Silver，Gold
- Links: [Documentation](../../user/project/settings/project_access_tokens.md#view-your-access-tokens) | Related issue

{{< /details >}}

您现在可以在 UI 中查看非活跃的群组和项目访问令牌。以前，极狐GitLab 在项目或群组访问令牌过期或被撤销后会立即删除它们。缺乏非活跃令牌的记录使得审计和安全审查更加困难。极狐GitLab 现在将非活跃的群组和项目访问令牌记录保留 30 天，这有助于团队跟踪令牌使用情况和过期时间，以实现合规和监控目的。

<a id="view-access-token-ip-addresses"></a>

### 查看访问令牌 IP 地址

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/profile/personal_access_tokens.md#view-token-usage-information) | Related issue

{{< /details >}}

以前，查看个人访问令牌时，唯一的使用信息是令牌多少分钟前被使用过。现在，您还可以看到令牌最后使用的多达七个 IP 地址。这些信息结合在一起可以帮助您跟踪令牌的使用位置。

感谢 [Jayce Martin](https://jrm2k.us)、[Avinash Koganti](http://www.linkedin.com/in/avinash-koganti-38b511162)、[Austin Dixon](https://austindixon.net/) 和 [Rohit Kala](https://www.linkedin.com/in/rohit-kala-1b891a179) 的贡献！

<a id="control-access-to-gitlab-pages-for-groups"></a>

### 控制群组对极狐GitLab Pages 的访问

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/pages/pages_access_control.md#remove-public-access-for-group-pages)

{{< /details >}}

您现在可以在群组级别限制极狐GitLab Pages 的访问。群组所有者可以启用一个设置，使群组及其子群组中的所有 Pages 站点仅对项目成员可见。这种集中控制简化了安全管理，无需修改单个项目设置。

<a id="change-work-item-type-to-another"></a>

### 将工作项类型更改为另一种

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/tasks.md#convert-a-task-into-another-item-type) | Related issue

{{< /details >}}

您现在可以轻松更改工作项的类型，从而更灵活地管理项目。

<a id="speed-up-adding-new-child-items-by-keeping-the-form-open"></a>

### 通过保持表单打开来加快添加新子项

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/work_items/child_items.md#work-with-multi-level-hierarchies) | Related issue

{{< /details >}}

我们简化了创建多个子项的过程，在每次提交后保持表单打开，从而无需额外点击即可更轻松地添加多个条目。此更新可节省您的时间，并确保在管理任务时工作流程更顺畅。

<a id="work-items-graphql-api---additional-query-filters"></a>

### 工作项 GraphQL API - 额外的查询过滤器

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../api/graphql/reference/_index.md) | Related issue

{{< /details >}}

工作项 GraphQL API 现在包含额外的查询过滤器，允许您按以下条件过滤：创建日期、更新日期、关闭日期和截止日期；健康状态；权重。这些新过滤器使您通过 API 查询和组织工作项时拥有更多控制权。

<a id="block-deletion-of-active-security-policy-projects"></a>

### 阻止删除活跃的安全策略项目

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/_index.md) | Related epic

{{< /details >}}

为了确保安全策略的安全管理并防止对已启用和强制执行的策略造成中断，我们添加了保护措施，以防止删除正在使用的安全策略项目。如果安全策略项目链接到任何群组或项目，则必须先移除这些链接，然后才能删除安全策略项目。

<a id="dependency-list-filter-by-component-in-projects"></a>

### 按组件筛选项目中的依赖项列表

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/dependency_list/_index.md#filter-dependency-list) | Related epic

{{< /details >}}

在项目的依赖项列表中，您现在可以使用组件过滤器按包名称进行筛选。以前，您无法在项目级别的依赖项列表中搜索包。现在，设置组件过滤器将查找包含指定字符串的包。

<a id="filter-by-identifier-in-the-project-vulnerability-report"></a>

### 在项目漏洞报告中按标识符筛选

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/vulnerability_report/_index.md#filtering-vulnerabilities) | Related epic

{{< /details >}}

在项目的漏洞报告中，您现在可以按漏洞标识符筛选结果，以便查找项目中存在的特定漏洞（如 CVE 或 CWE）。您可以将标识符与其他过滤器（如严重性、状态或工具过滤器）结合使用。漏洞标识符过滤器仅限于包含 20,000 个或更少漏洞的报告。

<a id="support-custom-roles-in-merge-request-approval-policies"></a>

### 在合并请求批准策略中支持自定义角色

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/merge_request_approval_policies.md#require_approval-action-type) | Related epic

{{< /details >}}

我们通过添加将自定义角色指定为审批者的功能，使合并请求批准策略更加灵活。您现在可以定制审批要求，以匹配组织独特的团队结构和职责，确保根据策略让正确的角色参与审查过程。例如，要求 AppSec 工程角色进行安全审查，合规角色进行许可证审批。

<a id="search-and-filter-the-credentials-inventory"></a>

### 搜索和筛选凭据清单

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../administration/credentials_inventory.md) | Related issue

{{< /details >}}

您现在可以在凭据清单中使用搜索和筛选功能。这使得识别符合某些用户定义参数的令牌和密钥变得更加容易，包括在特定时间窗口内过期的令牌。以前，凭据清单中的条目以静态列表形式呈现。

<a id="oauth-application-authorization-audit-event"></a>

### OAuth 应用程序授权审计事件

{{< details >}}

- Tier: 旗舰版，专业版
- Offering: JihuLab.com
- Links: [Documentation](../../user/compliance/audit_event_types.md#authorization) | Related issue

{{< /details >}}

以前，当用户授权 OAuth 应用程序时，不会生成审计事件。但是，此事件对于安全团队监控用户在特定极狐GitLab 实例上授权的 OAuth 应用程序非常重要。在此版本中，极狐GitLab 现在提供 **用户授权了 OAuth 应用程序** 审计事件，用于跟踪用户何时成功授权 OAuth 应用程序。这个新的审计事件进一步提高了您审计极狐GitLab 实例的能力。

<a id="use-api-to-disable-2fa-for-individual-enterprise-users"></a>

### 使用 API 为单个企业用户禁用双重身份验证

{{< details >}}

- Tier: Silver，Gold
- Offering: JihuLab.com
- Links: [Documentation](../../api/group_enterprise_users.md#disable-two-factor-authentication-for-an-enterprise-user) | Related issue

{{< /details >}}

您现在可以使用 API 清除单个企业用户的所有双重身份验证 (2FA) 注册。以前，这只能在 UI 中实现。使用 API 可以进行自动化和批量操作，在需要大规模重置 2FA 时节省时间。

<a id="email-notifications-for-service-accounts"></a>

### 服务帐户的电子邮件通知

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/profile/service_accounts.md) | Related issue

{{< /details >}}

您现在可以设置自定义电子邮件地址来接收服务帐户的电子邮件通知。在创建服务帐户时指定自定义电子邮件地址后，极狐GitLab 会向该地址发送通知。每个服务帐户必须使用唯一的电子邮件地址。这可以帮助您更有效地监控流程和事件。

感谢来自 [SNCF Connect & Tech 团队](https://www.sncf-connect-tech.fr/) 的 [Gilles Dehaudt](https://jihulab.com/tonton1728)、[Étienne Girondel](https://jihulab.com/lenaing)、[Kevin Caborderie](https://jihulab.com/Densett)、[Geoffrey McQuat](https://jihulab.com/gmcquat)、[Raphaël Bihore](https://jihulab.com/rbihore) 的贡献！

<a id="support-for-additional-group-memberships-with-multiple-oidc-providers"></a>

### 支持使用多个 OIDC 提供商的额外群组成员资格

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [Documentation](../../administration/auth/oidc.md#configure-multiple-openid-connect-providers) | Related issue

{{< /details >}}

您现在可以在使用多个 OIDC 提供商时配置额外的群组成员资格。以前，如果配置了多个 OIDC 提供商，则仅限于单个群组成员资格。

<a id="custom-expiration-date-for-rotated-service-account-tokens"></a>

### 轮换服务帐户令牌的自定义过期日期

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../api/service_accounts.md#rotate-a-personal-access-token-for-a-group-service-account) | Related issue

{{< /details >}}

在为服务帐户轮换访问令牌时，您现在可以使用 `expires_at` 属性设置自定义过期日期。以前，令牌在轮换后七天后自动过期。这允许更精细地管理令牌生命周期，增强您维护安全访问控制的能力。

<a id="support-merge-request-variables-in-pipeline-execution-policies"></a>

### 在流水线执行策略中支持合并请求变量

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/pipeline_execution_policies.md) | Related epic

{{< /details >}}

流水线执行策略现在支持额外的合并请求变量，允许您创建更复杂的策略，这些策略会考虑与合并请求相关的信息。这为 CI/CD 强制执行提供了更有针对性和更高效的控制。现在支持以下变量：`CI_MERGE_REQUEST_SOURCE_BRANCH_SHA`、`CI_MERGE_REQUEST_TARGET_BRANCH_SHA`、`CI_MERGE_REQUEST_DIFF_BASE_SHA`。通过此增强功能，您可以：实施高级安全扫描，比较源分支和目标分支之间的更改，确保彻底的代码审查和漏洞检测。创建动态流水线配置，根据每个合并请求的具体情况进行调整，从而简化开发流程。

<a id="new-permissions-for-custom-roles"></a>

### 自定义角色的新权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/custom_roles/_index.md) | Related epic

{{< /details >}}

您可以创建具有 Read compliance dashboard 权限的自定义角色。自定义角色允许您仅授予用户完成任务所需的特定权限。这有助于您定义适合群组需求的角色，并可以减少需要所有者或维护者角色的用户数量。

<a id="gitlab-runner-179"></a>

### 极狐GitLab Runner 17.9

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.9！极狐GitLab Runner 是一个高度可扩展的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD（极狐GitLab 中包含的开源持续集成服务）协同工作。

#### 新增功能

- Add health check for runner autoscaler instances
- Add histogram metrics for runner prepare stage duration
- Add support for custom service container names to the Kubernetes executor

#### 错误修复

- GitLab Runner is unable to retrieve cache from S3 Express One Zone
- GitLab Runner on Kubernetes reports ‘script_failure’ instead of ‘runner_system_failure’ for AWS Spot instances

所有更改的列表位于极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/17-9-stable/CHANGELOG.md) 中。