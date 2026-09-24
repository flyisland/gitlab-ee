---
stage: Release Notes
group: Monthly Release
date: 2025-12-18
title: "极狐GitLab 18.7 发行说明"
description: "GitLab 18.7 released with Secret validity checks improved and generally available"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 12 月 18 日，极狐GitLab 18.7 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="secret-validity-checks-improved-and-generally-available"></a>

### 密钥有效性检查改进并正式发布（GA）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/vulnerabilities/validity_check.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/16890)

{{< /details >}}

当有效密钥在您的某个代码仓库中泄露时，您必须迅速作出反应。为了帮助您优先处理紧急威胁，有效性检查会自动验证泄露的凭据是否仍然可用。

在极狐GitLab 18.7 中，我们改进了：

- **供应商集成**：与 Google Cloud、AWS 和 Postman 集成，同时保留对极狐GitLab 令牌的现有支持。
- **报告筛选**：按有效性状态（活跃、不活跃、可能活跃）筛选漏洞报告，以便快速分类和确定密钥查找结果的优先级。
- **群组级 API**：通过单个 API 调用在群组中的所有项目上启用有效性检查，并简化整个组织的推广。

在此版本中，有效性检查已正式发布（GA）。

<a id="separate-model-selection-for-agentic-chat-and-agents"></a>

### Agentic Chat 和代理的独立模型选择

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Pro，Duo Enterprise
- Links: [Documentation](../../user/gitlab_duo/model_selection.md#select-a-model-for-a-feature) | [Related issue](https://jihulab.com/groups/gitlab-cn/-/work_items/19998)

{{< /details >}}

现在可以为 Agentic Chat 以及顶级群组或实例的所有其他代理分别选择模型。这为极狐GitLab Duo Agent Platform 提供了更多的模型选择。

<a id="improved-gitlab-duo-and-sdlc-trends-dashboard"></a>

### 改进的极狐GitLab Duo 和 SDLC 趋势仪表板

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core，Duo Pro，Duo Enterprise
- Links: [Documentation](../../user/analytics/duo_and_sdlc_trends.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/19629)

{{< /details >}}

极狐GitLab Duo 和 SDLC 趋势仪表板提供了改进的分析功能，用于衡量极狐GitLab Duo 对软件交付的影响。该仪表板现在提供跨越极狐GitLab Duo 功能采用、流水线性能和常见开发指标（例如部署频率和平均合并时间）的 6 个月趋势分析。

您现在可以跟踪极狐GitLab Duo 代码建议的代码生成量以及 IDE 或语言趋势，并观察您的团队如何采用新的极狐GitLab Duo Agent Platform 流程。增强的用户级指标使团队能够更深入地了解持续提供价值的关键 Duo 功能。

一个新的 [实例级 AI 使用端点](../../api/graphql/reference/_index.md#aiinstanceusagedata) 现已可供实例管理员使用，以从 Postgres（3 个月保留期）或 ClickHouse 提取所有 Duo 数据。

由 [ClickHouse 集成](../../integration/clickhouse.md) 提供支持，该仪表板在数百万个数据点上提供亚秒级查询性能。对于私有化部署实例，请参阅 [ClickHouse 集成](../../integration/clickhouse.md) 的改进建议和配置指南。

<a id="additional-planner-agent-features-available-in-beta"></a>

### 规划代理的其他功能（测试版）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core，Duo Pro，Duo Enterprise
- Links: [Documentation](../../user/duo_agent_platform/agents/foundational_agents/planner.md) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/issues/576618)

{{< /details >}}

规划代理现在在测试版中包含创建和编辑功能！规划代理是一个内置 Agent，旨在直接在极狐GitLab 中为产品经理提供支持。使用规划代理来创建、编辑和分析极狐GitLab 工作项。

规划代理可帮助您分析积压工作、应用诸如 RICE 或 MoSCoW 之类的框架，并真正找出需要您关注的内容，而无需手动追踪更新、确定工作优先级或总结规划数据。这就像拥有一个了解您规划工作流程的积极主动的队友，并与您一起做出更好、更高效的决策。

<a id="dynamic-input-options-in-cicd-pipelines"></a>

### CI/CD 流水线中的动态输入选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../ci/inputs/_index.md#define-conditional-input-options-with-specinputsrules) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/18546)

{{< /details >}}

您可以设置 CI/CD 流水线，以便在通过直观的 Web 界面创建新流水线时利用动态输入选择。

现在，借助动态输入选项，您可以配置流水线，以便输入选择选项根据先前选择动态更新。例如，当您在一个下拉列表中选择一个输入时，它会自动填充第二个下拉列表中的相关输入选项列表。

借助 CI/CD 输入，您可以：

- 使用预配置的输入触发流水线，从而减少错误并简化部署。
- 允许用户从下拉菜单中选择不同于默认值的输入。
- 现在拥有级联下拉列表，其中选项会根据先前的选择动态更新。

这种动态功能使您能够创建更智能、上下文感知的输入配置，引导您完成流水线创建过程，减少错误并确保仅选择有效的输入组合。

<a id="sast-false-positive-detection-with-ai-beta"></a>

### 基于 AI 的 SAST 误报检测（测试版）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core，Duo Pro，Duo Enterprise
- Links: [Documentation](../../user/application_security/vulnerabilities/false_positive_detection.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/18977)

{{< /details >}}

安全团队经常花费大量时间调查最终被证明是误报的 SAST 发现结果，从而将注意力从真正的安全风险上转移了。

在极狐GitLab 18.7 中，我们引入了基于 AI 的 SAST 误报检测功能，帮助团队专注于重要的漏洞。运行安全扫描时，极狐GitLab Duo 会自动分析每个严重和重要严重性级别的 SAST 漏洞，以确定其为误报的可能性。

AI 评估会直接显示在漏洞报告中，为安全工程师提供即时上下文，以便更快、更自信地做出分类决策。

主要功能包括：

- **自动分析**：误报检测在每次安全扫描后自动运行，无需手动触发。
- **手动触发选项**：用户可以在漏洞详情页面上手动触发针对单个漏洞的误报检测，以实现按需分析。
- **专注于高影响发现结果**：范围限定在严重和重要严重性级别的漏洞，以最大限度地提高信噪比改善效果。
- **具有上下文的 AI 推理**：每项评估都包括关于为何该发现结果可能为真阳性或可能不是真阳性的解释，这基于代码上下文和漏洞特征。
- **无缝工作流集成**：结果直接显示在漏洞报告中，与现有的严重性、状态和修复信息放在一起。

此功能作为旗舰版客户的免费测试版提供，必须在您的群组或项目设置中启用。

<a id="new-security-dashboards-enabled-by-default"></a>

### 默认启用新的安全仪表板

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/security_dashboard/_index.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/20213)

{{< /details >}}

新的安全仪表板已更新并实现了现代化。这些仪表板之前已在 JihuLab.com 上可用，现在在私有化部署上默认启用。

新功能包括：

- 一个显示漏洞随时间变化的图表，它支持：
  - 基于项目或报告类型进行筛选。
  - 按报告类型和严重性进行分组。
  - 指向漏洞报告中漏洞的直接链接。
- 一个风险评分模块，它基于极狐GitLab 算法计算群组或项目的预估风险。

请注意，使用新的仪表板需要 Elasticsearch。

<a id="instance-setting-to-control-publishing-of-components-to-the-cicd-catalog"></a>

### 控制向 CI/CD 目录发布组件的实例设置

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Links: [Documentation](../../administration/settings/continuous_integration.md#restrict-cicd-catalog-publishing) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/issues/582044)

{{< /details >}}

私有化部署管理员现在可以限制哪些项目允许将组件发布到 CI/CD 目录。这一新设置使组织能够通过控制可发布的组件来维护一个经过整理的、值得信赖的 CI/CD 目录。

管理员现在可以指定一个授权发布组件的项目允许列表。当允许列表中填充了项目时，只有那些项目才能发布组件。这可以防止未经授权或未经批准的组件扰乱已发布组件的列表，并确保所有组件都符合组织标准和安全要求。

这解决了企业客户面临的一个关键治理挑战，他们希望控制其 CI/CD 组件生态系统，同时使其团队能够发现和重用经过批准的组件。

<a id="agentic-core"></a>

## Agentic Core

<a id="advanced-search-available-for-both-merge-request-descriptions-and-comments"></a>

### 合并请求描述和评论均支持高级搜索

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/search/advanced_search.md) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/issues/572590)

{{< /details >}}

高级搜索现在可以从合并请求描述和评论中返回匹配结果。以前，用户必须分别搜索合并请求描述和评论。

这一改进为极狐GitLab 合并请求提供了更精简、更全面的搜索工作流。

<a id="ai-agent-and-flow-versioning"></a>

### AI Agent 和流版本管理

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/duo_agent_platform/ai_catalog.md#agent-and-flow-versions) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/20022)

{{< /details >}}

当您在项目中从 AI 目录启用一个代理或流程时，极狐GitLab 现在将其固定到特定版本。

这意味着即使目录项在演进，您的 AI 驱动工作流也能保持稳定和可预测，因此您可以在升级之前测试和验证新版本。

<a id="ai-gateway-timeout-setting"></a>

### AI 网关超时设置

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Add-ons: Duo Enterprise
- Links: [Documentation](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-timeout-for-the-ai-gateway) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/work_items/579183)

{{< /details >}}

对于极狐GitLab Duo 私有化部署，您现在可以为发送到自部署模型的请求配置超时值。

此值的范围可以从 60 到 600 秒。

<a id="report-agents-and-flows-to-administrators"></a>

### 向管理员举报代理和流

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/report_abuse.md) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/issues/578591)

{{< /details >}}

现在，当您遇到有问题的内容时，可以向实例管理员举报代理和流。提交包含您反馈的滥用举报，管理员可以选择隐藏或删除有害项目。

使用此功能，可以在整个组织中保持代理和流的安全。

<a id="configure-foundational-agent-availability"></a>

### 配置内置 Agent 的可用性

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/duo_agent_platform/agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/issues/583815)

{{< /details >}}

您现在可以控制哪些内置 Agent 在您的顶级群组或实例中可用。

默认情况下，可以开启或关闭所有内置 Agent，或者切换各个代理以符合贵组织的安全和治理策略。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="enhanced-active-trial-experience-for-self-managed"></a>

### 增强的私有化部署试用体验

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署
- Links: [Documentation](../../subscriptions/free_trials.md#view-remaining-trial-period-days)

{{< /details >}}

极狐GitLab 私有化部署旗舰版试用用户现在可以从左侧边栏访问他们的活动试用状态、剩余天数、可访问的功能和到期通知。

这些增强功能有助于消除关于试用时长的混淆，并使其更易于在购买前评估付费功能。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="advanced-vulnerability-management-available-in-self-managed-and-dedicated-environments"></a>

### 私有化部署环境中的高级漏洞管理

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/vulnerability_report/_index.md#advanced-vulnerability-management) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/issues/532703)

{{< /details >}}

高级漏洞管理对所有旗舰版客户可用，并包含以下功能：

- 在项目或群组的漏洞报告中按 OWASP 2021 类别对数据进行分组。
- 在项目或群组的漏洞报告中根据漏洞标识符进行筛选。
- 在项目或群组的漏洞报告中根据可达性值进行筛选。
- 按策略违规绕过原因进行筛选。

<a id="data-analyst-foundational-agent-powered-by-glql-beta"></a>

### 由 GLQL 驱动的基础数据分析师代理（测试版）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core，Duo Pro，Duo Enterprise
- Links: [Documentation](../../user/duo_agent_platform/agents/foundational_agents/data_analyst.md)

{{< /details >}}

数据分析师代理是一个专门的 AI 助手，可帮助您查询、可视化并呈现整个极狐GitLab 平台的数据。它使用极狐GitLab 查询语言（GLQL）来检索和分析数据，然后提供关于您项目的清晰、可操作的洞察。

您可以在文档中找到示例提示和用例。

该代理目前处于测试阶段。

<a id="filter-and-comment-on-compliance-violations"></a>

### 筛选和评论合规违规

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/compliance/compliance_center/compliance_violations_report.md)

{{< /details >}}

合规违规报告提供了组织内所有项目中合规违规的集中视图。该报告显示了控制违规、相关审计事件的全面详细信息，并使团队能够有效地跟踪违规状态。

在极狐GitLab 18.7 中，我们引入了强大的筛选功能，以帮助您快速找到最重要的违规。您现在可以按以下条件筛选：

- 状态
- 项目
- 控制

团队现在还可以通过评论直接在解决违规方面进行协作。在违规记录本身内部，团队可以：

- 标记团队成员进行调查
- 讨论补救方法
- 记录调查结果——所有这些都在违规记录内部完成。

这些功能共同将合规违规报告演变为一个动态协作平台，使组织能够高效地发现、分析和解决其群组和项目中的合规违规。

<a id="compliance-framework-controls-show-accurate-scan-status"></a>

### 合规框架控制显示准确的扫描状态

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/compliance/compliance_frameworks/_index.md#gitlab-compliance-controls)

{{< /details >}}

极狐GitLab 合规控制可用于合规框架中。控制是针对分配给合规框架的项目的配置或行为进行的检查。

以前，与扫描器相关的控制（例如，检查是否启用了 SAST）要求您的项目在默认分支中有一个通过的流水线，然后合规中心才会显示您控制的成功或失败状态。

在极狐GitLab 18.7 中，我们更改了这一行为，仅根据扫描完成情况来显示控制是否成功或失败，而不管整体流水线状态如何。这有助于消除混淆，因为您控制的合规状态反映了安全扫描是否已运行并完成，而不是整个流水线是否通过。

<a id="accessibility-improvements-for-heading-anchor-links"></a>

### 标题锚点链接的无障碍改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/markdown.md) | [Related issue](https://jihulab.com/gitlab-org/gitlab/-/work_items/463385)

{{< /details >}}

标题锚点链接现在会使用与其对应标题相同的文本进行播报，从而改善屏幕阅读器用户的体验。这些链接还显示在标题文本之后，提供了更清晰的外观。

这些更改使所有用户更容易理解和导航到文档、议题和其他内容的特定部分。

<a id="warn-mode-in-merge-request-approval-policies"></a>

### 合并请求批准策略中的警告模式

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/policies/merge_request_approval_policies.md#warn-mode) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/19595)

{{< /details >}}

安全团队现在可以使用警告模式来测试和验证安全策略的影响，然后再进行强制执行，或者推出软门以加速您的安全计划。警告模式有助于在安全策略推广期间减少开发人员摩擦，同时继续确保检测到的漏洞得到解决。

当您创建或编辑 [合并请求批准策略](../../user/application_security/policies/merge_request_approval_policies.md) 时，现在可以在 `warn` 或 `enforce` 强制选项之间进行选择。

处于警告模式的策略会生成信息性机器人评论，而不会阻止合并请求。可选的审批人可以被指定为策略问题的联系人。这种方法使安全团队能够评估策略影响，并通过透明、渐进的策略采用建立开发人员信任。

合并请求中的明确指示器会告知用户策略处于 `warn` 模式还是 `enforce` 模式，并且审计事件会跟踪策略违规和驳回以进行合规报告。开发人员可以通过提供策略驳回的理由来绕过扫描发现和许可证策略违规，从而在开发人员和安全团队之间创建一个协作反馈回路，以实现更有效的策略启用。

在项目默认分支上检测到策略违规时，策略会在项目和群组的漏洞报告中识别违反策略的漏洞。项目的依赖项列表还会显示指示许可证合规策略违规的徽章。

此外，您可以使用 API 查询项目中默认分支上经过筛选的策略违规列表。

<a id="service-accounts-available-during-trials-on-gitlabcom"></a>

### JihuLab.com 上试用期间服务账户可用

{{< details >}}

- Tier: Silver，Gold
- Offering: JihuLab.com
- Links: [Documentation](../../user/profile/service_accounts.md)

{{< /details >}}

服务账户现在在试用期间可用，允许您在购买前测试自动化和集成工作流。

<a id="gitlab-runner-187"></a>

### 极狐GitLab Runner 18.7

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.7！

极狐GitLab Runner 是高扩展性的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

<a id="bug-fixes"></a>

#### 错误修复
- [当指定了相对 `builds_dir` 时，Shell 执行器在现有 Git 仓库中失败](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/39150)
- [极狐GitLab Runner 18.6.0 在后续流水线运行中出现认证失败（SSH 执行器）](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/39140)
- [极狐GitLab Runner 18.6.0 在后续流水线运行中出现认证失败（Shell 执行器）](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/39123)
- [Docker 29 API 兼容性问题](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/39129)
- [在极狐GitLab Runner 18.6.0 中使用 Shell 执行器时，引用文件变量的变量不再工作](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/39124)
- [极狐GitLab Runner 现已支持 Windows 11 2025 (25H2)](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/39050)
- [ECR 凭证助手在 Docker Autoscaler 执行器中无法工作](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/38365)
- [极狐GitLab Runner 中的作业超时现在已正确实施](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/27040)

所有变更的完整列表见极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/18-7-stable/CHANGELOG.md)。

<a id="view-child-pipeline-reports-in-merge-requests"></a>

### 在合并请求中查看子流水线报告

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用父子 CI/CD 流水线的团队之前需要浏览多个流水线页面来查看测试结果、代码质量报告和基础设施变更，这打乱了他们的合并请求审查工作流。

你现在可以在统一视图中查看和下载所有报告，包括单元测试、代码质量检查、Terraform 计划和自定义指标，而无需离开合并请求。

这消除了上下文切换并加快了合并请求的速度，使团队能够更快地交付功能而不影响质量。