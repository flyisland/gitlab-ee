---
stage: Release Notes
group: Monthly Release
date: 2025-02-20
title: "极狐GitLab 17.9 发布说明"
description: "极狐GitLab 17.9 发布，极狐GitLab Duo 自部署版本已正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

在 2025 年 2 月 20 日，极狐GitLab 17.9 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-self-hosted-is-generally-available"></a>

### 极狐GitLab Duo 自部署版本已正式发布

<!-- categories: Model Selection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/517102)

{{< /details >}}

现在，您可以在自己的基础设施中托管选定的大语言模型（LLM），并将这些模型配置为极狐GitLab Duo 代码建议和 Chat 的来源。在具有相应许可的极狐GitLab 私有化部署环境中，此功能现已正式发布。

借助极狐GitLab Duo 自部署版本，您可以使用托管在本地或私有云中的模型作为极狐GitLab Duo Chat 或代码建议的来源。目前，我们支持 vLLM 或 AWS Bedrock 上的开源 Mistral 模型、AWS Bedrock 上的 Claude 3.5 Sonnet，以及 Azure OpenAI 上的 OpenAI 模型。通过启用自部署模型，您可以在保持完全数据主权和隐私的同时，充分利用生成式 AI 的能力。

请在[议题 512753](https://gitlab.com/gitlab-org/gitlab/-/issues/512753)中留下反馈。

<a id="run-multiple-pages-sites-with-parallel-deployments"></a>

### 通过并行部署运行多个 Pages 站点

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/_index.md#parallel-deployments) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14434)

{{< /details >}}

现在，您可以通过并行部署同时创建 GitLab Pages 站点的多个版本。每个部署都会根据您配置的前缀获得一个唯一 URL。例如，使用唯一域名时，您的站点可通过 `project-123456.gitlab.io/prefix` 访问；不使用唯一域名时，则可通过 `namespace.gitlab.io/project/prefix` 访问。

当您需要执行以下操作时，此功能尤其有用：

- 预览设计变更或内容更新。
- 在开发环境中测试站点变更。
- 评审来自合并请求的变更。
- 维护多个站点版本（例如，包含本地化内容的版本）。

为帮助管理存储空间，并行部署默认在 24 小时后过期，不过您可以自定义该时长，或将部署设置为永不过期。如需自动清理，从合并请求创建的并行部署会在合并请求被合并或关闭时删除。

<a id="add-project-files-to-duo-chat-in-vs-code-and-jetbrains-ides"></a>

### 在 VS Code 和 JetBrains IDE 中将项目文件添加到 Duo Chat

<!-- categories: VS Code, JetBrains, Web Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/examples.md#ask-about-specific-files-in-the-ide) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15183)

{{< /details >}}

在 VS Code 和 JetBrains 中，将您的项目文件直接添加到 Duo Chat，即可获得更强大、更具上下文感知能力的 AI 辅助。

通过添加项目文件，Duo Chat 能够深入理解您的特定代码库，从而提供高度贴合上下文且准确的回答。这种上下文感知能力可为您带来更相关的代码解释、更精准的调试帮助，以及与现有代码库无缝集成的建议。我们欢迎您对这一令人兴奋的新功能提出反馈。请在[反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/492443)议题中分享您的想法。

<a id="workspaces-container-support-with-sysbox"></a>

### 使用 Sysbox 支持工作区容器

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/configuration.md#build-and-run-containers-in-a-workspace)

{{< /details >}}

极狐GitLab 工作区现在支持直接在您的开发环境中构建和运行容器。当您的工作区运行在[配置了 Sysbox](../../user/workspace/configuration.md#with-sysbox)的 Kubernetes 集群上时，您无需额外配置即可构建和运行容器。

此功能在极狐GitLab 17.4 中作为 [ sudo 访问功能](gitlab-17-4-released.md#secure-sudo-access-for-workspaces)的一部分引入，使您能够在极狐GitLab 工作区环境中维持完整的容器工作流。

<a id="create-workspaces-without-a-custom-devfile"></a>

### 无需自定义 devfile 即可创建工作区

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md#gitlab-default-devfile)

{{< /details >}}

以前，设置工作区需要创建 `devfile.yaml` 配置文件。极狐GitLab 现在为您提供了一个包含常用开发工具的默认文件。此增强功能：

- 消除了配置障碍。
- 使您可以从任何项目快速创建工作区。
- 包含预先配置好、开箱即用的常用开发工具。
- 让您专注于开发，而非配置。

无需额外的设置或配置步骤，即可立即开始开发并创建工作区。

<a id="gitlab-managed-kubernetes-resources"></a>

### 极狐GitLab 托管的 Kubernetes 资源

<!-- categories: Environment Management, Deployment Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/managed_kubernetes_resources.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16130)

{{< /details >}}

使用[极狐GitLab 托管的 Kubernetes 资源](../../user/clusters/agent/managed_kubernetes_resources.md)，您可以在将应用部署到 Kubernetes 时实现更精细的控制和更高程度的自动化。以前，您必须为每个环境手动配置 Kubernetes 资源。现在，您可以使用极狐GitLab 托管的 Kubernetes 资源来自动预配和管理这些资源。

使用极狐GitLab 托管的 Kubernetes 资源，您可以：

- 为新环境自动创建命名空间和服务账号
- 通过角色绑定管理访问权限
- 配置其他所需的 Kubernetes 资源

当您的开发者部署应用时，极狐GitLab 会根据提供的资源模板自动创建必要的 Kubernetes 资源，从而简化部署流程并保持各环境之间的一致性。

<a id="simplified-access-to-deployments-within-project-environments"></a>

### 简化对项目环境中部署的访问

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/505770)

{{< /details >}}

您是否曾为难以概览项目中的部署而苦恼？现在，您可以在环境列表中查看最近的部署详情，而无需展开每个环境。对于每个环境，列表会显示您最近一次成功的部署，如果不同，还会显示您最近一次的部署尝试。

<a id="wiki-page-comments"></a>

### Wiki 页面评论

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/discussions/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14062)

{{< /details >}}

现在，您可以直接在 Wiki 页面上添加评论，将您的文档转变为交互式协作空间。

Wiki 页面上的评论和讨论串可帮助团队：

- 直接在上下文中讨论内容。
- 提出改进和更正建议。
- 保持文档准确且最新。
- 分享知识和专业技能。

借助 Wiki 评论，团队可以通过直接的反馈和讨论，维护与项目共同演进的动态文档。

<a id="enhancing-workflow-visibility-new-insights-into-merge-request-review-time"></a>

### 增强工作流可见性：关于合并请求评审时间的新洞察

<!-- categories: Value Stream Management, Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/value_stream_analytics/_index.md#value-stream-stage-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/503754)

{{< /details >}}

为改进开发工作流跟踪，[价值流分析](https://about.gitlab.com/solutions/value-stream-management/)（VSA）新增了一个事件——*合并请求最后批准时间*。[合并请求审批](../../user/project/merge_requests/approvals/_index.md)事件标志着评审阶段的结束，以及最终流水线运行或合并阶段的开始。例如，要计算总的合并请求评审时间，您可以创建一个 VSA 阶段，以*合并请求审核人首次指派*为开始事件，以*合并请求最后批准时间*为结束事件。

通过此增强功能，团队可以更深入地了解优化评审时间的机会，这有助于缩短整体开发周期，从而加快软件交付。

<a id="epss-kev-and-cvss-data-for-vulnerability-risk-prioritization"></a>

### 用于漏洞风险优先级排序的 EPSS、KEV 和 CVSS 数据

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerabilities/risk_assessment_data.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11544)

{{< /details >}}

我们新增了对以下漏洞风险数据的支持：

- 漏洞利用预测评分系统（EPSS）
- 已知被利用漏洞（KEV）
- 通用漏洞和暴露（CVE）

现在，您可以使用这些数据高效地对依赖项和容器镜像漏洞进行风险优先级排序。您可以在漏洞报告和漏洞详情页面中找到这些数据。

<a id="configure-dast-scans-through-the-ui-with-full-control"></a>

### 通过 UI 全面控制 DAST 扫描配置

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/on-demand_scan.md)

{{< /details >}}

为了有效测试复杂的应用程序，安全团队在配置 DAST 扫描时需要灵活性。以前，通过 UI 配置的 DAST 扫描配置选项有限，导致无法成功扫描具有特定安全要求的应用程序。这意味着即使进行快速安全评估，您也必须使用基于流水线的扫描。

现在，您可以通过 UI 配置 DAST 扫描，并获得与基于流水线的扫描相同的精细控制。这包括：

- 完整的身份验证配置，包括自定义请求头和 cookie
- 精确的爬取设置，如最大页面数、最大深度和排除的 URL
- 高级扫描超时和重试次数
- 自定义扫描器行为，如最大爬取链接数和 DOM 深度
- 针对特定漏洞类型的定向扫描模式

将这些配置保存为可复用的配置文件，以便在您的应用程序之间保持一致的安全测试。每次配置变更都会通过审计事件进行跟踪，因此您可以了解扫描设置何时被添加、编辑或移除。

这种增强的控制能力可帮助您运行更有效的安全扫描，同时通过详细的审计事件记录保持合规。您无需花费时间管理流水线配置，而是可以为每个应用程序快速启动合适的扫描，从而更快地发现和修复漏洞。

<a id="automatic-cicd-pipeline-cleanup"></a>

### 自动清理 CI/CD 流水线

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/settings.md#automatic-pipeline-cleanup) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/338480)

{{< /details >}}

过去，如果您想删除较旧的 CI/CD 流水线，只能通过 API 进行。

在极狐GitLab 17.9 中，我们引入了一个项目设置，允许您设置 CI/CD 流水线的过期时间。任何超过所定义保留期的流水线及相关产物都会被删除。这有助于减少那些运行大量生成大型产物的流水线的项目的磁盘占用，甚至还能提升整体性能。

<a id="agentic-core"></a>

## AI 功能

<a id="composite-identity-for-more-secure-ai-connections"></a>

### 用于更安全 AI 连接的复合身份

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../development/ai_features/composite_identity.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/506641)

{{< /details >}}

以前，对极狐GitLab 的请求只能以单个用户身份进行身份验证。借助复合身份，我们现在可以同时以服务账号和用户身份对请求进行身份验证。AI Agent 用例通常要求权限基于在系统中发起任务的用户，同时还要显示一个与发起用户不同的独立身份。复合身份是我们新的身份主体，代表 AI Agent 的身份。此身份与向该 Agent 请求操作的人类用户身份相关联。每当 AI Agent 操作尝试访问资源时，都会使用复合身份令牌。此令牌属于某个服务账号，同时也与指示该 Agent 的人类用户相关联。对该令牌运行的授权检查会在授予资源访问权限之前同时考虑这两个主体。两个身份都必须有权访问该资源，否则访问将被拒绝。这项新功能增强了我们保护极狐GitLab 中存储资源的能力。有关如何使用服务账号复合身份的更多信息，请参阅[文档](../../development/ai_features/composite_identity.md)。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="restrict-users-from-making-their-profile-private"></a>

### 限制用户将个人资料设为私有

<!-- categories: User Management, User Profile -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/account_and_limit_settings.md#prevent-users-from-making-their-profiles-private) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421310)

{{< /details >}}

用户可以选择将其用户资料设为公开或私有。管理员现在可以控制用户是否能够在其极狐GitLab 实例中将个人资料设为私有。在管理区域中，“允许用户将个人资料设为私有”控制此设置。此设置默认启用，允许用户选择私有个人资料。

<a id="manage-project-integrations-from-a-group-with-the-rest-api"></a>

### 使用 REST API 从群组管理项目集成

<!-- categories: Source Code Management, Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/group_integrations.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/328496)

{{< /details >}}

以前，您只能在极狐GitLab UI 中从群组管理项目集成。在此版本中，也可以通过 REST API 管理这些集成。

感谢 [Van](https://gitlab.com/van.m.anderson)的[初始社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/148283)，该贡献随后由 GitLab 接手并完成。

<a id="group-sharing-visibility-enhancement"></a>

### 群组共享可见性增强

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/members/sharing_projects_groups.md#view-shared-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/378629)

{{< /details >}}

我们很高兴地宣布，极狐GitLab 中群组共享的可见性已扩展。以前，虽然您可以在群组概览页面上看到共享的项目，但无法看到您的群组被邀请加入了哪些群组。现在，您可以在群组概览页面上查看**共享的项目**和**共享的群组**两个选项卡，从而全面了解您的群组在整个组织中的连接和共享情况。这让审计和管理整个组织中的群组访问权限变得更加容易。

欢迎在[史诗 16777](https://gitlab.com/groups/gitlab-org/-/epics/16777)中对此变更提出反馈。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="enable-dependency-scanning-using-sbom-for-cargo-conda-cocoapods-and-swift-projects"></a>

### 使用 SBOM 为 Cargo、Conda、Cocoapods 和 Swift 项目启用依赖扫描

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/519597)

{{< /details >}}

在极狐GitLab 17.9 中，成分分析团队开始使用新的依赖扫描分析器向基于 SBOM 的依赖扫描过渡。此分析器将取代 Gemnasium，后者将在 18.0 中达到支持终止，并可在极狐GitLab 19.0 之前继续使用。

基于 SBOM 的依赖扫描方法将通过扩展语言支持、在极狐GitLab 平台内实现更紧密的集成和体验，以及向行业标准报告类型（基于 SBOM 的扫描和报告）转变，更好地支持客户。自极狐GitLab 17.9 起，新的依赖扫描分析器将在 `latest` 依赖扫描 CI/CD 模板（`Dependency-Scanning.latest.gitlab-ci.yml`）中针对以下项目和文件类型默认启用：

- 使用 conda 并带有 `conda-lock.yml` 文件的 C/C++/Fortran/Go/Python/R 项目。
- 使用 Cocoapods 并带有 `podfile.lock` 文件的 Objective-C 项目。
- 使用 Cargo 并带有 `cargo.lock` 文件的 Rust 项目。
- 使用 Swift 并带有 `package.resolved` 文件的 Swift 项目。

通过此变更，我们引入了一个新的 CI/CD 变量：`DS_ENFORCE_NEW_ANALYZER`，其默认值为 `false`。

此方法可确保 `latest` 模板的所有现有客户继续默认使用 Gemnasium 分析器，并为上述文件类型自动启用新的依赖扫描分析器。

希望迁移到新依赖扫描分析器的现有客户，可以将 `DS_ENFORCE_NEW_ANALYZER` 设置为 `true`（在项目、群组或实例级别）。您可以在[弃用公告](../../update/deprecations.md#dependency-scanning-upgrades-to-the-gitlab-sbom-vulnerability-scanner)和相关的[迁移指南](../../user/application_security/dependency_scanning/migration_guide_to_sbom_based_scans.md)中了解有关此变更的更多信息。

希望完全阻止使用新依赖扫描分析器的客户，必须将 CI/CD 变量 `DS_EXCLUDED_ANALYZERS` 设置为 `dependency-scanning`。

<a id="license-scanning-support-for-swift-packages"></a>

### 对 Swift 软件包的许可证扫描支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/506730)

{{< /details >}}

在极狐GitLab 17.9 中，我们新增了对 Swift 软件包进行许可证扫描的支持。这将使在项目中使用 Swift 的用户能够更好地了解其 Swift 软件包的许可情况。

成分分析用户可以通过依赖列表、SBOM 报告和 GraphQL API 获取这些数据。

<a id="multi-core-advanced-sast-offers-faster-scans"></a>

### 多核高级 SAST 提供更快的扫描

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/_index.md#security-scanner-configuration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/514156)

{{< /details >}}

极狐GitLab 高级 SAST 现在提供多核扫描作为可选功能，以提升性能。这可以显著缩短扫描时长，尤其是对于较大的代码库。

要启用它，请将 `SAST_SCANNER_ALLOWED_CLI_OPTS` CI/CD 变量设置为`--multi-core N`，其中 `N` 是要使用的核心数。您只应在 `gitlab-advanced-sast` 作业上设置此变量，而不要在任何其他作业上设置。请查看[文档](../../user/application_security/sast/_index.md#security-scanner-configuration)，了解有关如何选择正确值的重要指导。

我们正在努力默认启用此性能改进；相关进展记录在[议题 517409](https://gitlab.com/gitlab-org/gitlab/-/issues/517409)中。

<a id="apply-a-compliance-framework-by-using-a-projects-compliance-center"></a>

### 使用项目的合规中心应用合规框架

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_projects_report.md) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/issues/507986)

{{< /details >}}

在极狐GitLab 17.2 中，我们发布了群组所有者通过群组的合规中心为群组中所有项目应用和移除合规框架的功能。

我们对此进行了扩展，现在群组所有者还可以在项目级别应用和移除合规框架。这将使群组所有者更容易在项目级别应用和监控合规框架。

在项目级别应用和移除合规框架的功能仅适用于群组所有者，而不适用于项目所有者。

<a id="workspace-extensions-now-support-proposed-apis"></a>

### 工作区扩展现在支持提议的 API

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md#extension-marketplace)

{{< /details >}}

工作区扩展现在支持启用提议的 API，从而提升生产环境中的兼容性和可靠性。此更新允许依赖提议 API 的扩展无错误运行，包括 Python Debugger 等关键开发工具。此变更在保持稳定性的同时扩展了 API 访问能力。

<a id="implement-oci-based-gitops-with-the-fluxcd-cicd-component"></a>

### 使用 FluxCD CI/CD 组件实现基于 OCI 的 GitOps

<!-- categories: Container Registry, Deployment Management, Component Catalog -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.com/components/fluxcd/) | [相关议题](https://gitlab.com/gitlab-org/ci-cd/deploy-stage/environments-group/experiments/fluxcd-ci-cd-component/-/issues/1)

{{< /details >}}

您是否曾想过如何使用极狐GitLab 实现 GitOps 最佳实践？新的 [FluxCD 组件](https://gitlab.com/components/fluxcd/)让这一切变得简单。使用 FluxCD 组件将 Kubernetes 清单打包为 OCI 镜像，并将这些镜像存储在兼容 OCI 的容器镜像仓库中。您还可以选择对镜像进行签名，并触发一次即时的 FluxCD 协调。

<a id="get-started-with-the-gitlab-integration-with-kubernetes"></a>

### 开始使用极狐GitLab 与 Kubernetes 的集成

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/getting_started.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/505216)

{{< /details >}}

在此版本中，我们新增了 Kubernetes 入门指南，向您展示如何使用极狐GitLab 直接以及通过 FluxCD 将应用部署到 Kubernetes。这些易于遵循的教程无需深入的 Kubernetes 知识即可完成，因此无论是新手还是经验丰富的用户，都能学会如何集成极狐GitLab 和 Kubernetes。

作为 Kubernetes 入门指南的补充，我们还提供了一系列关于将极狐GitLab 集成到 Kubernetes 环境中的建议。

<a id="discover-and-migrate-certificate-based-kubernetes-clusters"></a>

### 发现并迁移基于证书的 Kubernetes 集群

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/cluster_discovery.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/512420)

{{< /details >}}

基于证书的 Kubernetes 集成将于 2025 年 5 月 6 日 9:00 UTC 至 2025 年 5 月 8 日 22:00 UTC 期间在 JihuLab.com 上对所有用户关闭，并将在极狐GitLab 19.0（预计 2026 年 5 月）中从极狐GitLab 私有化部署实例中移除。

为帮助用户迁移，我们新增了一个集群 API 端点，群组所有者可以查询该端点，以[发现](../../api/cluster_discovery.md)注册到群组、子群组或项目的任何基于证书的集群。我们还更新了[迁移文档](../../user/infrastructure/clusters/migrate_to_gitlab_agent.md)，为不同类型的用例提供说明。

我们鼓励所有 JihuLab.com 用户检查自己是否受到影响，并尽快规划迁移。

<a id="enforce-custom-stages-in-pipeline-execution-policies"></a>

### 在流水线执行策略中强制使用自定义阶段

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/pipeline_execution_policies.md#inject_policy-type) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/475152)

{{< /details >}}

我们很高兴地推出流水线执行策略的一项新功能，允许您在 `Inject` 模式下将**自定义阶段**强制注入到您的 CI/CD 流水线中。此功能在保持安全和合规要求的同时，为您的流水线结构提供了更大的灵活性和控制力，为您带来：

- **增强的流水线自定义能力**：在流水线的特定位置定义并注入自定义阶段，从而更精细地控制作业执行顺序。
- **改进的安全性和合规性**：确保安全扫描和合规检查在流水线中最合适的时机运行，例如在构建之后、部署之前。
- **灵活的策略管理**：在允许开发团队在既定护栏内自定义其流水线的同时，保持集中式策略控制。
- **无缝集成**：自定义阶段可与现有项目阶段和其他策略类型协同工作，以非破坏性的方式增强您的 CI/CD 工作流。

**它是如何工作的？**

用于流水线执行策略的全新改进的 `inject_policy` 策略允许您在策略配置中定义自定义阶段。然后，这些阶段会使用有向无环图（DAG）算法与项目现有阶段智能合并，确保正确的顺序并防止冲突。

例如，您现在可以轻松地在构建阶段和部署阶段之间注入一个自定义安全扫描阶段。

`inject_policy` 阶段将取代即将弃用的 `inject_ci`，让您可以选择启用 `inject_policy` 模式以获得这些优势。在策略编辑器中使用 `Inject` 配置策略时，`inject_policy` 模式将成为默认模式。

<a id="rotate-access-tokens-with-self_rotate-scope"></a>

### 使用 `self_rotate` 作用域轮换访问令牌

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../security/tokens/access_token_scopes.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/430748)

{{< /details >}}

现在，您可以使用 `self_rotate` 作用域来轮换访问令牌。此作用域适用于个人、项目或群组访问令牌。以前，这需要两个请求：一个用于获取新令牌，另一个用于执行令牌轮换。

感谢 [Stéphane Talbot](https://gitlab.com/stalb) 和 [Anthony Juckel](https://gitlab.com/ajuckel)的贡献！

<a id="view-inactive-project-and-group-access-tokens"></a>

### 查看非活动的项目和群组访问令牌

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/settings/project_access_tokens.md#view-your-access-tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)

{{< /details >}}

现在，您可以在 UI 中查看非活动的群组和项目访问令牌。以前，极狐GitLab 会在项目和群组访问令牌过期或被撤销后立即将其删除。由于缺少非活动令牌的记录，审计和安全审查变得更加困难。极狐GitLab 现在会保留非活动的群组和项目访问令牌记录 30 天，这有助于团队出于合规和监控目的跟踪令牌的使用和过期情况。

<a id="view-access-token-ip-addresses"></a>

### 查看访问令牌 IP 地址

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/personal_access_tokens.md#view-token-usage-information) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428577)

{{< /details >}}

以前，在查看您的个人访问令牌时，您唯一能看到的用量信息是该令牌在多少分钟前被使用过。现在，您还可以看到令牌最近使用过的至多七个 IP 地址。这些组合信息可以帮助您跟踪令牌的使用位置。

感谢 [Jayce Martin](https://jrm2k.us)、[Avinash Koganti](http://www.linkedin.com/in/avinash-koganti-38b511162)、[Austin Dixon](https://austindixon.net/) 和 [Rohit Kala](https://www.linkedin.com/in/rohit-kala-1b891a179)的贡献！

<a id="control-access-to-gitlab-pages-for-groups"></a>

### 控制群组对 GitLab Pages 的访问

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/pages_access_control.md#remove-public-access-for-group-pages)

{{< /details >}}

现在，您可以在群组级别限制 GitLab Pages 的访问。群组所有者可以启用一个设置，使群组及其子群组中的所有 Pages 站点仅对项目成员可见。这种集中式控制简化了安全管理，无需修改各个项目的设置。

<a id="change-work-item-type-to-another"></a>

### 将工作项类型更改为其他类型

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/tasks.md#convert-a-task-into-another-item-type) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385131)

{{< /details >}}

现在，您可以轻松更改工作项的类型，从而更灵活、更高效地管理您的项目。

<a id="speed-up-adding-new-child-items-by-keeping-the-form-open"></a>

### 通过保持表单打开来加快添加新子项的速度

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/work_items/child_items.md#work-with-multi-level-hierarchies) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/497767)

{{< /details >}}

我们简化了创建多个子项的流程，在每次提交后保持表单打开，让您无需额外点击即可更轻松地添加多个条目。此更新可为您节省时间，并确保在管理任务时工作流更加顺畅。

<a id="work-items-graphql-api---additional-query-filters"></a>

### 工作项 GraphQL API - 额外的查询筛选条件

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/graphql/reference/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513308)

{{< /details >}}

工作项 GraphQL API 现在包含额外的查询筛选条件，让您可以按以下条件进行筛选：

- 创建日期、更新日期、关闭日期和截止日期
- 健康状态
- 权重

这些新的筛选条件让您通过 API 查询和组织工作项时拥有更多控制力。

<a id="block-deletion-of-active-security-policy-projects"></a>

### 阻止删除活动的安全策略项目

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/_index.md) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/issues/482967)

{{< /details >}}

为确保安全策略的安全管理，并防止对已启用和强制执行的策略造成干扰，我们新增了保护措施，以防止删除正在使用中的安全策略项目。

如果安全策略项目链接到任何群组或项目，则必须先移除这些链接，然后才能删除该安全策略项目。

<a id="dependency-list-filter-by-component-in-projects"></a>

### 在项目中按组件筛选依赖列表

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md#filter-dependency-list) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16490)

{{< /details >}}

在项目的依赖列表中，您现在可以使用组件筛选条件按软件包名称进行筛选。

以前，您无法在项目级别的依赖列表中搜索软件包。现在，设置组件筛选条件将查找包含指定字符串的软件包。

<a id="filter-by-identifier-in-the-project-vulnerability-report"></a>

### 在项目漏洞报告中按标识符筛选

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#filtering-vulnerabilities) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13340)

{{< /details >}}

在项目的漏洞报告中，您现在可以按漏洞标识符筛选结果，从而找到项目中的特定漏洞（如 CVE 或 CWE）。您可以将标识符与严重性、状态或工具等其他筛选条件结合使用。漏洞标识符筛选仅适用于漏洞数量不超过 20,000 个的报告。

<a id="support-custom-roles-in-merge-request-approval-policies"></a>

### 在合并请求审批策略中支持自定义角色

<!-- categories: Permissions, Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#require_approval-action-type) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13550)

{{< /details >}}

我们通过新增将自定义角色指派为审批人的功能，使合并请求审批策略更加灵活。

现在，您可以根据组织独特的团队结构和职责定制审批要求，确保合适的角色根据策略参与评审流程。例如，安全评审需要 AppSec Engineering 角色批准，许可证审批需要 Compliance 角色批准。

<a id="search-and-filter-the-credentials-inventory"></a>

### 搜索和筛选凭据清单

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/credentials_inventory.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/345734)

{{< /details >}}

现在，您可以在凭据清单中使用搜索和筛选功能。这样可以更轻松地识别符合特定用户定义参数的令牌和密钥，包括在特定时间窗口内过期的令牌。以前，凭据清单中的条目以静态列表形式呈现。

<a id="oauth-application-authorization-audit-event"></a>

### OAuth 应用程序授权审计事件

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md#authorization) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/514152)

{{< /details >}}

以前，当用户授权某个 OAuth 应用程序时，不会生成审计事件。然而，此事件对于安全团队监控用户在特定极狐GitLab 实例上授权的 OAuth 应用程序非常重要。

在此版本中，极狐GitLab 现在提供**用户授权了 OAuth 应用程序**审计事件，以跟踪用户何时成功授权 OAuth 应用程序。这个新的审计事件进一步提升了您审计极狐GitLab 实例的能力。

<a id="use-api-to-disable-2fa-for-individual-enterprise-users"></a>

### 使用 API 为单个企业用户禁用 2FA

<!-- categories: System Access -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../api/group_enterprise_users.md#disable-two-factor-authentication-for-an-enterprise-user) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383319)

{{< /details >}}

现在，您可以使用 API 清除单个企业用户的所有双因素认证（2FA）注册信息。以前，这只能在 UI 中完成。使用 API 可以实现自动化和批量操作，在需要大规模重置 2FA 时节省时间。

<a id="email-notifications-for-service-accounts"></a>

### 服务账号的电子邮件通知

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/service_accounts.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428750)

{{< /details >}}

现在，您可以设置一个自定义电子邮件地址，用于接收服务账号的电子邮件通知。如果在创建服务账号时指定了自定义电子邮件地址，极狐GitLab 会向该地址发送通知。每个服务账号必须使用唯一的电子邮件地址。这可以帮助您更有效地监控流程和事件。

感谢来自 [SNCF Connect & Tech 团队](https://www.sncf-connect-tech.fr/)的 [Gilles Dehaudt](https://gitlab.com/tonton1728)、[Étienne Girondel](https://gitlab.com/lenaing)、[Kevin Caborderie](https://gitlab.com/Densett)、[Geoffrey McQuat](https://gitlab.com/gmcquat)、[Raphaël Bihore](https://gitlab.com/rbihore)的贡献！

<a id="support-for-additional-group-memberships-with-multiple-oidc-providers"></a>

### 使用多个 OIDC 提供商支持额外的群组成员资格

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/auth/oidc.md#configure-multiple-openid-connect-providers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/408248)

{{< /details >}}

现在，您可以在使用多个 OIDC 提供商时配置额外的群组成员资格。以前，如果您配置了多个 OIDC 提供商，则只能使用单个群组成员资格。

<a id="custom-expiration-date-for-rotated-service-account-tokens"></a>

### 为轮换的服务账号令牌自定义过期日期

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/service_accounts.md#rotate-a-personal-access-token-for-a-group-service-account) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/505671)

{{< /details >}}

在轮换服务账号的访问令牌时，您现在可以使用 `expires_at` 属性设置自定义过期日期。以前，令牌在轮换后七天后自动过期。这允许对令牌生命周期进行更精细的管理，增强您维护安全访问控制的能力。

<a id="support-merge-request-variables-in-pipeline-execution-policies"></a>

### 在流水线执行策略中支持合并请求变量

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/pipeline_execution_policies.md) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/issues/512916)

{{< /details >}}

流水线执行策略现在支持额外的合并请求变量，允许您创建更复杂的策略，将合并请求相关的信息纳入考量。这为 CI/CD 强制执行提供了更有针对性和更高效的控制。现在支持以下变量：

- `CI_MERGE_REQUEST_SOURCE_BRANCH_SHA`
- `CI_MERGE_REQUEST_TARGET_BRANCH_SHA`
- `CI_MERGE_REQUEST_DIFF_BASE_SHA`

通过此增强功能，您可以：

- 实施高级安全扫描，比较源分支和目标分支之间的变更，确保彻底的代码评审和漏洞检测。
- 创建动态流水线配置，根据每个合并请求的具体情况自适应调整，从而简化您的开发流程。

<a id="new-permissions-for-custom-roles"></a>

### 自定义角色的新权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14746)

{{< /details >}}

您可以使用[读取合规仪表板](https://gitlab.com/gitlab-org/gitlab/-/issues/465324)权限创建自定义角色。自定义角色允许您仅授予用户完成任务所需的特定权限。这有助于您定义适合群组需求的角色，并可以减少需要维护者或所有者角色的用户数量。

<a id="gitlab-runner-179"></a>

### 极狐GitLab Runner 17.9

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.9！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [为 runner 自动扩缩器实例添加健康检查](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38271)
- [为 runner 准备阶段时长添加直方图指标](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37471)
- [为 Kubernetes 执行器添加对自定义服务容器名称的支持](https://gitlab.com/gitlab-org/gitlab/-/issues/421131)

<a id="bug-fixes"></a>

#### 缺陷修复

- [极狐GitLab Runner 无法从 S3 Express One Zone 检索缓存](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38484)
- [极狐GitLab Runner 在 Kubernetes 上对 AWS Spot 实例报告 `script_failure` 而非 `runner_system_failure`](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37911)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-9-stable/CHANGELOG.md)。
