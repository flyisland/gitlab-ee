---
stage: Release Notes
group: Monthly Release
date: 2025-12-18
title: "极狐GitLab 18.7 发布说明"
description: "极狐GitLab 18.7 发布，密钥有效性检查改进并正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 12 月 18 日，极狐GitLab 18.7 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="secret-validity-checks-improved-and-generally-available"></a>

### 密钥有效性检查改进并正式发布

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerabilities/validity_check.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16890)

{{< /details >}}

当您的某个代码仓库中泄露了有效密钥时，您必须迅速做出反应。为帮助您确定紧急威胁的优先级，有效性检查会自动验证泄露的凭据是否仍可使用。

在极狐GitLab 18.7 中，我们改进了：

- 厂商集成：集成了 Google Cloud、AWS 和 Postman，并保留了对极狐GitLab 令牌的现有支持。
- 报告筛选：按有效性状态（有效、无效、可能有效）筛选漏洞报告，以快速分类和确定密钥发现的优先级。
- 群组级 API：通过一次 API 调用为群组中的所有项目开启有效性检查，简化在整个组织中的推广。

在此版本中，有效性检查已正式发布。

<a id="separate-model-selection-for-agentic-chat-and-agents"></a>

### 为 Agentic Chat 和 Agent 分别选择模型

<!-- categories: Model Personalization -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/model_selection.md#select-a-model-for-a-feature) | [相关议题](https://gitlab.com/groups/gitlab-org/-/work_items/19998)

{{< /details >}}

现在可以为顶级群组或实例的 Agentic Chat 和所有其他 Agent 分别选择模型。
这为极狐GitLab Duo Agent Platform 提供了更多模型选择。

<a id="improved-gitlab-duo-and-sdlc-trends-dashboard"></a>

### 改进的极狐GitLab Duo 和 SDLC 趋势仪表板

<!-- categories: DevOps Reports -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/analytics/duo_and_sdlc_trends.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19629)

{{< /details >}}

极狐GitLab Duo 和 SDLC 趋势仪表板提供了改进的分析能力，用于衡量极狐GitLab Duo 对软件交付的影响。该仪表板现在提供跨极狐GitLab Duo 功能采用情况、流水线性能以及部署频率和平均合并时间等常见开发指标的 6 个月趋势分析。

您现在可以跟踪极狐GitLab Duo 代码建议的代码生成量以及 IDE 或语言趋势，并观察您的团队采用新的极狐GitLab Duo Agent Platform 任务流的情况。增强的用户级指标使团队能够更深入地了解提供持续价值的关键 Duo 功能。

新的[实例级 AI 使用情况端点](../../api/graphql/reference/_index.md#aiinstanceusagedata)现已可供实例管理员使用，可从 Postgres（保留 3 个月）或
ClickHouse 中提取所有 Duo 数据。

该仪表板由 [ClickHouse 集成](../../integration/clickhouse.md)提供支持，可在数百万个数据点上实现亚秒级查询性能。对于私有化部署实例，请参阅 [ClickHouse 集成](../../integration/clickhouse.md)的改进建议和配置指南。

<a id="additional-planner-agent-features-available-in-beta"></a>

### 测试版中提供更多计划者 Agent 功能

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/planner.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/576618)

{{< /details >}}

计划者 Agent 现在在测试版中包含创建和编辑功能！计划者 Agent 是一个内置 Agent，旨在在极狐GitLab 中直接为产品经理提供支持。使用计划者 Agent 创建、编辑和分析极狐GitLab 工作项。

计划者 Agent 无需您手动跟进更新、确定工作优先级或汇总规划数据，而是帮助您分析待办事项、应用 RICE 或 MoSCoW 等框架，并找出真正需要您关注的内容。它就像一位主动的队友，了解您的规划工作流，并与您一起做出更好、更高效的决策。

请在[议题 576622](https://gitlab.com/gitlab-org/gitlab/-/issues/576622)中提供您的反馈。

<a id="dynamic-input-options-in-cicd-pipelines"></a>

### CI/CD 流水线中的动态输入选项

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/inputs/_index.md#define-conditional-input-options-with-specinputsrules) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18546)

{{< /details >}}

您可以设置 CI/CD 流水线，以便通过直观的 Web 界面创建新流水线时使用动态输入选择。

现在，借助动态输入选项，您可以配置流水线，使输入选择选项根据之前的选择动态更新。例如，当您在一个下拉列表中选择某个输入时，它会自动在第二个下拉列表中填充相关输入选项的列表。

借助 CI/CD 输入，您可以：

- 使用预配置的输入触发流水线，减少错误并简化部署。
- 让您的用户可以从下拉菜单中选择不同于默认值的输入。
- 现在拥有级联下拉列表，其中的选项会根据之前的选择动态更新。

这种动态能力使您能够创建更智能、更具上下文感知的输入配置，引导您完成流水线创建过程，减少错误并确保只选择有效的输入组合。

<a id="sast-false-positive-detection-with-ai-beta"></a>

### 使用 AI 进行 SAST 误报检测（测试版）

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/application_security/vulnerabilities/false_positive_detection.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18977)

{{< /details >}}

安全团队通常花费大量时间调查最终被证明是误报的 SAST 发现，从而分散了对真正安全风险的注意力。

在极狐GitLab 18.7 中，我们引入了由 AI 驱动的 SAST 误报检测，以帮助团队专注于真正重要的漏洞。当安全扫描运行时，极狐GitLab Duo 会自动分析每个严重级别和高危级别 SAST 漏洞，以确定其为误报的可能性。

AI 评估直接显示在漏洞报告中，为安全工程师提供即时上下文，以便更快、更自信地做出分类决策。

主要能力包括：

- 自动分析：误报检测在每次安全扫描后自动运行，无需手动触发。
- 手动触发选项：用户可以在漏洞详情页面上手动触发单个漏洞的误报检测，以进行按需分析。
- 专注于高影响发现：范围限定为严重级别和高危级别漏洞，以最大限度地提高信噪比改善。
- 上下文 AI 推理：每项评估都包含基于代码上下文和漏洞特征，说明该发现可能是或可能不是真正漏洞的原因。
- 无缝工作流集成：结果直接显示在漏洞报告中，与现有的严重性、状态和修复信息并列。

此功能作为免费测试版提供给旗舰版客户，必须在您的群组或项目设置中启用。欢迎您在[议题 583697](https://gitlab.com/gitlab-org/gitlab/-/issues/583697)中提供反馈。

<a id="new-security-dashboards-enabled-by-default"></a>

### 默认启用新的安全仪表板

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/security_dashboard/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/20213)

{{< /details >}}

新的安全仪表板已更新并实现现代化。这些仪表板此前已在 JihuLab.com 上提供，现在已在极狐GitLab 私有化部署上默认启用。

新功能包括：

- 漏洞随时间变化图表，支持：
  - 按项目或报告类型筛选。
  - 按报告类型和严重性分组。
  - 直接链接到漏洞报告中的漏洞。
- 风险评分模块，根据极狐GitLab 算法计算群组或项目的估计风险。

请注意，使用新仪表板需要 Elasticsearch。

<a id="instance-setting-to-control-publishing-of-components-to-the-cicd-catalog"></a>

### 用于控制向 CI/CD Catalog 发布组件的实例设置

<!-- categories: Pipeline Composition, Component Catalog -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/continuous_integration.md#restrict-cicd-catalog-publishing) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/582044)

{{< /details >}}

极狐GitLab 私有化部署的管理员现在可以限制哪些项目允许向 CI/CD Catalog 发布组件。此新设置使组织能够通过控制可以发布哪些组件，维护一个精心策划、值得信赖的 CI/CD Catalog。

管理员现在可以指定一个允许发布组件的项目允许名单。当允许名单中填充了项目后，只有这些项目可以发布组件。这可以防止未经授权或未经批准的组件扰乱已发布组件的列表，并确保所有组件符合组织标准和安全要求。

这解决了企业客户的一个关键治理挑战，这些客户希望保持对其 CI/CD 组件生态系统的控制，同时让其团队发现和复用已批准的组件。

<a id="agentic-core"></a>

## AI 功能

<a id="advanced-search-available-for-both-merge-request-descriptions-and-comments"></a>

### 高级搜索现在可用于合并请求描述和评论

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/advanced_search.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/572590)

{{< /details >}}

高级搜索现在会同时返回合并请求描述和评论中的匹配结果。此前，用户必须分别搜索合并请求描述和评论。

此改进为极狐GitLab 合并请求提供了更精简、更全面的搜索工作流。

<a id="support-for-agentsmd-with-gitlab-duo-chat-agentic-in-ides"></a>

### 在 IDE 中支持将 `AGENTS.md` 与极狐GitLab Duo Chat（Agentic）配合使用

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/customize/agents_md.md)

{{< /details >}}

极狐GitLab Duo Chat 现在支持 `AGENTS.md` 规范，这是一种为 AI 编码助手提供上下文和指令的新兴标准。

与仅可供极狐GitLab Duo 使用的自定义规则不同，`AGENTS.md` 文件也可供其他 AI 编码工具使用。这使您的构建命令、测试指令、代码风格指南和项目特定上下文可供任何支持该规范的 AI 工具使用。

您 IDE 中的极狐GitLab Duo Chat 会自动应用代码仓库中 `AGENTS.md` 文件中可用的指令，这些指令在用户或工作区级别设置。对于 monorepo，您可以将 `AGENTS.md` 文件放在子目录中，以便为不同组件提供量身定制的指令。

<a id="ai-agent-and-flow-versioning"></a>

### AI Agent 和任务流版本控制

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/ai_catalog.md#agent-and-flow-versions) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/20022)

{{< /details >}}

当您在项目中启用来自 AI 目录的 Agent 或任务流时，极狐GitLab 现在会将其固定到特定版本。

这意味着即使目录条目不断演进，您的 AI 驱动工作流也能保持稳定和可预测，因此您可以在升级之前测试和验证新版本。

<a id="ai-gateway-timeout-setting"></a>

### AI 网关超时设置

<!-- categories: Model Personalization -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-timeout-for-the-ai-gateway) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/579183)

{{< /details >}}

对于极狐GitLab Duo 自部署版本，您现在可以为对自部署模型的请求配置超时值。

该值的范围可以是 60 到 600 秒。

<a id="report-agents-and-flows-to-administrators"></a>

### 向管理员报告 Agent 和任务流

<!-- categories: AI Catalog -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/report_abuse.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/578591)

{{< /details >}}

当您遇到有问题的内容时，现在可以向实例管理员报告 Agent 和任务流。提交一份包含您反馈的滥用报告，管理员可以选择隐藏或删除有害条目。

使用此功能可在整个组织中保持您的 Agent 和任务流安全。

<a id="configure-foundational-agent-availability"></a>

### 配置内置 Agent 可用性

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/583815)

{{< /details >}}

您现在可以控制顶级群组或实例中可用的内置 Agent。

默认开启或关闭所有内置 Agent，或切换单个 Agent，以符合您组织的安全和治理策略。

<a id="scale-and-deployments"></a>

## 规模和部署

<a id="enhanced-active-trial-experience-for-self-managed"></a>

### 增强的私有化部署试用体验

<!-- categories: Acquisition -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../subscriptions/free_trials.md#view-remaining-trial-period-days)

{{< /details >}}

处于旗舰版试用的极狐GitLab 私有化部署用户现在可以从左侧边栏访问其当前试用状态、剩余天数、可访问功能以及到期通知。

这些增强功能有助于消除对试用期限的困惑，并使在购买前评估付费功能变得更加容易。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 和安全

<a id="advanced-vulnerability-management-available-in-self-managed-and-dedicated-environments"></a>

### 私有化部署环境中提供高级漏洞管理

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#advanced-vulnerability-management) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/532703)

{{< /details >}}

高级漏洞管理可供所有旗舰版客户使用，包括以下功能：

- 在项目或群组的漏洞报告中按 OWASP 2021 类别对数据分组。
- 在项目或群组的漏洞报告中基于漏洞标识符进行筛选。
- 在项目或群组的漏洞报告中基于可达性值进行筛选。
- 按策略违规绕过原因进行筛选。

<a id="data-analyst-foundational-agent-powered-by-glql-beta"></a>

### 由 GLQL 提供支持的数据分析内置 Agent（测试版）

<!-- categories: Custom Dashboards Foundation -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/data_analyst.md)

{{< /details >}}

数据分析 Agent 是一个专门的 AI 助手，可帮助您查询、可视化和呈现整个极狐GitLab 平台中的数据。它使用极狐GitLab 查询语言（GLQL）来检索和分析数据，然后提供关于您项目的清晰、可操作的洞察。

您可以在文档中找到示例提示和用例。

此 Agent 目前处于测试版状态，因此请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/574028)中分享您的想法，以帮助我们改进并了解您希望它接下来朝哪个方向发展。

<a id="filter-and-comment-on-compliance-violations"></a>

### 筛选和评论合规违规

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_violations_report.md)

{{< /details >}}

合规违规报告提供了您组织项目中所有合规违规的集中视图。该报告显示有关控制违规、相关审计事件的全面详细信息，并使团队能够有效跟踪违规状态。

在极狐GitLab 18.7 中，我们引入了强大的筛选功能，以帮助您快速找到最重要的违规。您现在可以按以下条件筛选：

- 状态
- 项目
- 控制

团队现在还可以通过评论直接协作解决违规。在违规记录本身中，团队可以：

- 标记团队成员进行调查
- 讨论修复方法
- 记录发现——所有这些都在违规记录本身中完成。

这些功能共同将合规违规报告发展为一个动态协作平台，使组织能够高效地发现、分析并解决其群组和项目中的合规违规。

<a id="compliance-framework-controls-show-accurate-scan-status"></a>

### 合规框架控制显示准确的扫描状态

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_frameworks/_index.md#gitlab-compliance-controls)

{{< /details >}}

极狐GitLab 合规控制可用于合规框架。控制是针对分配给合规框架的项目的配置或行为的检查。

此前，与扫描器相关的控制（例如，检查是否启用了 SAST）要求您的项目在默认分支中具有通过的流水线，然后合规中心才会显示您的控制的成功或失败状态。

在极狐GitLab 18.7 中，我们更改了此行为，仅根据扫描完成情况来显示您的控制是成功还是失败，而不考虑整体流水线状态。这有助于减少困惑，因为您的控制的合规状态反映的是安全扫描是否运行并完成，而不是整个流水线是否通过。

<a id="accessibility-improvements-for-heading-anchor-links"></a>

### 标题锚点链接的无障碍改进

<!-- categories: Markdown -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/463385)

{{< /details >}}

标题锚点链接现在会以与其对应标题相同的文本进行播报，从而改善屏幕阅读器用户的体验。这些链接还会显示在标题文本之后，提供更简洁的视觉呈现。

这些更改使所有用户都更容易理解和导航到文档、议题和其他内容的特定部分。

<a id="warn-mode-in-merge-request-approval-policies"></a>

### 合并请求审批策略中的警告模式

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#warn-mode) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19595)

{{< /details >}}

安全团队现在可以使用警告模式，在应用强制执行之前测试和验证安全策略的影响，或推出软性门禁以加速您的安全计划。警告模式有助于在安全策略推广期间减少开发者摩擦，同时继续确保检测到的漏洞得到处理。

当您创建或编辑[合并请求审批策略](../../user/application_security/policies/merge_request_approval_policies.md)时，您现在可以在 `warn` 或 `enforce` 执行选项之间进行选择。

处于警告模式的策略会生成信息性机器人评论，而不会阻止合并请求。可选审批人可以被指定为策略问题的联系人。这种方法使安全团队能够评估策略影响，并通过透明、渐进的策略采用来建立开发者的信任。

合并请求中的清晰指示器会告知用户策略何时处于 `warn` 或 `enforce` 模式，审计事件会跟踪策略违规和忽略操作以用于合规报告。开发者可以通过提供忽略策略违规的理由来绕过扫描发现和许可证策略违规，从而在开发者和安全团队之间创建协作反馈循环，以实现更有效的策略启用。

当在项目的默认分支上检测到策略违规时，策略会在项目和群组的漏洞报告中识别违反策略的漏洞。项目的依赖项列表还会显示指示许可证合规策略违规的徽章。

此外，您可以使用 API 查询项目中默认分支上策略违规的筛选列表。

<a id="service-accounts-available-during-trials-on-gitlabcom"></a>

### JihuLab.com 上试用期间可用的服务账号

<!-- categories: System Access -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/profile/service_accounts.md)

{{< /details >}}

服务账号现在在试用期间可用，允许您在购买前测试自动化和集成工作流。

<a id="gitlab-runner-187"></a>

### 极狐GitLab Runner 18.7

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.7！

极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [可配置的 taskscaler 预留节流](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39161)
- [默认启用 `FF_TIMESTAMPS`](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38378)

<a id="bug-fixes"></a>

#### 缺陷修复

- [如果指定了相对 `builds_dir`，Shell 执行器在现有 Git 代码仓库上失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39150)
- [GitLab Runner 18.6.0 在后续流水线运行中认证失败（SSH 执行器）](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39140)
- [GitLab Runner 18.6.0 在后续流水线运行中认证失败（shell 执行器）](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39123)
- [Docker 29 API 兼容性问题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39129)
- [引用文件变量的变量在 GitLab Runner 18.6.0 中与 shell 执行器配合使用时不再工作](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39124)
- [GitLab Runner 现在支持 Windows 11 2025 (25H2)](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39050)
- [ECR 凭据助手无法与 Docker 自动扩缩执行器配合使用](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38365)
- [作业超时现在在 GitLab Runner 中得到正确强制执行](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27040)

所有更改的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-7-stable/CHANGELOG.md)中。

<a id="view-child-pipeline-reports-in-merge-requests"></a>

### 在合并请求中查看子流水线报告

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/downstream_pipelines.md#view-child-pipeline-reports-in-merge-requests) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18311)

{{< /details >}}

使用父子 CI/CD 流水线的团队此前必须浏览多个流水线页面来检查测试结果、代码质量报告和基础设施变更，从而中断了他们的合并请求评审工作流。

您现在可以在统一视图中查看和下载所有报告，包括单元测试、代码质量检查、Terraform 计划和自定义指标，而无需离开合并请求。

这消除了上下文切换并加快了合并请求速度，使团队能够在不影响质量的情况下更快地交付功能。
