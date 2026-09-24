---
stage: Release Notes
group: Monthly Release
date: 2026-03-19
title: "极狐GitLab 18.10 发布说明"
description: "极狐GitLab 18.10 发布，包含使用极狐GitLab Duo Agent Platform 的 SAST 误报检测功能"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2026 年 3 月 19 日，极狐GitLab 18.10 正式发布，带来以下新功能。

## 主要功能

<a id="primary-features"></a>

### 使用极狐GitLab Duo Agent Platform 进行 SAST 误报检测

<a id="sast-false-positive-detection-with-gitlab-duo-agent-platform"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [文档](../../user/application_security/vulnerabilities/false_positive_detection.md)

{{< /details >}}

SAST 误报检测最初在极狐GitLab 18.7 中作为测试版功能推出，现已于极狐GitLab 18.10 正式发布。

当安全扫描运行时，极狐GitLab Duo Agent Platform 会分析每个严重和高危 SAST 漏洞，并判断其是否为误报的可能性。
该评估结果会直接显示在漏洞报告中，为团队提供自信地进行分类所需的上下文，而不是充满不确定性。

主要功能包括：

- 自动分析：误报检测在每次安全扫描后自动运行，无需手动干预。
- 手动选项：用户可以在漏洞详情页面对单个漏洞手动运行误报检测，以进行按需分析。
- 聚焦高危发现：将分析范围限制在严重和高危 SAST 漏洞，直击要害，消除噪音。
- 上下文 AI 推理：每项评估都会解释某发现是否为误报的原因，综合考虑代码上下文、数据流和特定于静态分析的漏洞特征。
- 无缝工作流集成：结果直接显示在漏洞报告中，与现有的严重性、状态和修复信息并列——无需更改现有工作流。

此功能面向拥有极狐GitLab Duo Agent Platform 的旗舰版客户。必须在群组或项目设置中启用该功能。
我们欢迎您在 [议题 583697](https://gitlab.com/gitlab-org/gitlab/-/issues/583697) 中提供反馈。

### 在 JihuLab.com 的基础版上购买极狐GitLab Credits

<a id="purchase-gitlab-credits-on-the-free-tier-on-gitlabcom"></a>

{{< details >}}

- Tier: 基础版
- Offering: JihuLab.com
- Add-ons: 极狐GitLab Credits
- Links: [文档](../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)

{{< /details >}}

JihuLab.com 基础版群组的所有者现在可以借助极狐GitLab Credits 解锁 AI 功能。您可以购买月度信用额度，承诺年度期限，并获得对[极狐GitLab Duo Agent Platform 代理和流](../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)的访问权限。信用额度每月自动刷新，因此您的团队始终有足够的资源，可以更快速、更智能地进行构建。

主要亮点：

- **基于用量的定价**：购买月度信用承诺，无需基础计划订阅。
- **自助购买**：通过极狐GitLab 购买流程购买信用额度。
- **无缝升级路径**：如果您稍后升级到专业版或旗舰版，您的信用承诺会相应转移。
- **用量跟踪**：通过极狐GitLab Credits 仪表盘监控您的信用使用情况。

此[购买选项](../../subscriptions/gitlab_credits.md#buy-gitlab-credits)目前仅适用于 JihuLab.com 的基础版顶级群组。

### 使用通行密钥安全登录

<a id="sign-in-securely-with-passkeys"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../auth/passkeys.md)

{{< /details >}}

极狐GitLab 现已支持使用通行密钥进行无密码登录，并作为防钓鱼的双因素认证（2FA）方法。通行密钥使用公钥加密和生物特征认证（指纹、面部识别）或您的设备 PIN 码来安全地访问您的账户。

通行密钥提供以下优势：

- **无密码便利性**：使用设备的生物特征或 PIN 码登录，无需记忆密码。
- **多设备支持**：在桌面浏览器、移动设备（iOS 16 或更高版本，Android 9 或更高版本）以及兼容 FIDO2/WebAuthn 的硬件安全密钥上使用通行密钥。
- **防钓鱼安全**：您的私钥永远不会离开您的设备。极狐GitLab 仅存储公钥，即使极狐GitLab 服务器被攻破，也能保护您的账户安全。
- **自动集成双因素认证**：对于已启用双因素认证的账户，通行密钥将成为您的默认双因素认证方法。

要开始使用，请在您的账户设置中添加一个通行密钥。我们欢迎您在议题 [366758](https://gitlab.com/gitlab-org/gitlab/-/work_items/366758) 中提出问题和反馈。

### 推出工作项列表和已保存视图

<a id="introducing-the-work-items-list-and-saved-views"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/work_items/_index.md)

{{< /details >}}

极狐GitLab 的规划体验通过工作项列表和已保存视图得到了显著升级，将两个期待已久的功能整合在一起：

- 工作项列表将史诗、议题和其他工作项整合到一个统一的列表中，无需在不同工作项类型的独立页面之间切换。这使得理解不同规划对象之间的关系变得更加容易。
- 已保存视图允许您创建并保存自定义的列表配置，包括筛选器、排序顺序和显示选项。这使得例行检查更高效，并支持团队以标准化的方式查看工作。

这是极狐GitLab 工作项发展历程的下一步，它是一个统一架构，旨在多种极狐GitLab 规划工具中提供一致性并解锁新功能。

请在议题 [590689](https://gitlab.com/gitlab-org/gitlab/-/work_items/590689) 中分享您的想法和反馈。

### 自定义代理可使用 MCP 访问外部数据

<a id="custom-agents-can-use-mcp-to-access-external-data"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/gitlab_duo/model_context_protocol/ai_catalog_mcp_servers.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590708)

{{< /details >}}

现在，您可以将 AI Catalog 中的自定义代理通过模型上下文协议（MCP）连接到外部数据源和工具，无需离开极狐GitLab。

此功能是实验性质的。请在议题 [593219](https://gitlab.com/gitlab-org/gitlab/-/work_items/593219) 中分享您的反馈。

### 使用正则表达式强制合并请求标题命名约定

<a id="enforce-merge-request-title-naming-conventions-with-regex"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/project/merge_requests/title_validation.md)

{{< /details >}}

对于依赖结构化命名约定的团队来说，保持一致的合并请求标题至关重要。无论是遵循 Conventional Commits 格式，还是链接到内部跟踪系统，团队以前都需要外部工具或自定义 CI/CD 流水线作业来强制执行这些约定，但这种方法存在一个关键缺陷。如果有人在流水线运行后更改了合并请求标题，就没有重新验证，合并请求仍然可以在标题不合规的情况下被合并。

现在，您可以在项目设置中为合并请求配置必需的标题正则表达式。配置完成后，极狐GitLab 会将合并请求标题与模式进行比对，以此作为可合并性检查——阻止合并，直到标题更新为合规，无论标题最后更改的时间是什么时候。

要进行设置，请转到您项目的 **设置 > 合并请求**，并在 **合并请求标题必须匹配正则表达式** 字段中输入一个正则表达式模式。

您现有的合并请求工作流将继续像以前一样工作。此检查仅适用于您明确配置了标题正则表达式的项目。

### 密钥误报检测与 AI（测试版）

<a id="secret-false-positive-detection-with-ai-beta"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [文档](../../user/application_security/vulnerabilities/secret_false_positive_detection.md)

{{< /details >}}

安全团队花费大量时间调查最终被证明是误报的密钥检测发现，例如，测试凭证、示例值和占位令牌被错误地标记为实际密钥。
误报会导致告警疲劳，削弱对扫描结果的信任，并分散对真正安全风险的注意力。

极狐GitLab 18.10 引入了 AI 驱动的密钥误报检测（测试版），以便专注于真正重要的密钥。
当安全扫描运行时，极狐GitLab Duo 会自动分析每个 **严重** 和 **高危** 密钥检测漏洞，判断其是否为误报。

AI 评估结果直接显示在漏洞报告中，为安全工程师提供即时上下文，以便更快、更自信地做出分类决策。

主要功能包括：

- 自动分析：误报检测在每次安全扫描后自动运行，无需手动触发。
- 手动触发选项：您可以在漏洞详情页面对单个漏洞手动触发误报检测，以进行按需分析。
- 聚焦高危发现：限定于 **严重** 和 **高危** 漏洞，最大化提升信噪比。
- 上下文 AI 推理：每项评估都包含对发现是否为真阳性原因的解释，基于代码上下文和漏洞特征。
- 置信度评分：每次检测都包含一个置信度评分，以帮助团队根据模型的确定性对审查进行优先级排序。
- 无缝工作流集成：结果直接显示在漏洞报告中，与现有的严重性、状态和修复信息并列。

此功能作为旗舰版客户的免费测试版提供，必须在您的群组或项目设置中启用。
请在议题 [592861](https://gitlab.com/gitlab-org/gitlab/-/work_items/592861) 中分享反馈。

### 在 CI/CD 作业中使用运行时输入

<a id="use-runtime-inputs-with-cicd-jobs"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../ci/jobs/job_inputs.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17833)

{{< /details >}}

将 CI/CD 变量用于动态作业配置可能具有挑战性。变量遵循复杂的覆盖层次结构，难以管理，且不能用于各种用例。

现在，您可以使用 `inputs` 在作业级别定义明确的、类型化的输入。使用作业输入来定义和控制作业在运行时接受的值。通过作业输入，您将获得：

- 类型安全（字符串、数字、布尔值、数组）。
- 可以是静态值或引用现有变量的默认值。
- 定义可用值的严格列表的选项。
- 用于验证输入值的正则表达式支持。

作业输入可以在无需任何用户交互的情况下使用默认值，但您可以在重试作业或运行手动作业时修改这些值。

## Agentic Core

<a id="agentic-core"></a>

### 极狐GitLab 用于群组和实例代码搜索的 Blob 搜索

<a id="gitlab-blob-search-for-group-and-instance-code-search"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/duo_agent_platform/agents/tools.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/593221)

{{< /details >}}

[`gitlab_blob_search`](../../user/duo_agent_platform/agents/tools.md) 工具现已使极狐GitLab AI Agent 能够搜索您的代码：

- 跨群组中的所有项目。
- 跨实例上所有可访问的项目。

以前，Blob 搜索仅限于单个项目，或者需要指定明确的项目 ID。此变更使 AI 驱动的工作流更容易发现和重用分散在多个相关项目中的代码。

### 用于流水线管理的极狐GitLab MCP 服务器工具

<a id="gitlab-mcp-server-tool-for-pipeline-management"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/gitlab_duo/model_context_protocol/mcp_server_tools.md#manage_pipeline) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/583826)

{{< /details >}}

您现在可以使用新的 `manage_pipeline` 工具管理极狐GitLab 项目中的 CI/CD 流水线。
这个极狐GitLab MCP 服务器工具允许 AI Agent 在单个调用中创建、取消、重试、删除和更新流水线元数据。
借助此工具，您不再需要拼凑多个步骤来自动化您的流水线工作流。

如果您想了解其他极狐GitLab MCP 服务器工具，请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/566375)中告知我们。

### 项目维护者可启用自定义代理和流

<a id="project-maintainers-can-enable-custom-agents-and-flows"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/duo_agent_platform/flows/custom.md#enable-a-flow) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590573)

{{< /details >}}

以前，从 AI Catalog 启用 AI Agent 和流需要顶级群组权限。

现在，在探索级别或项目级别浏览 AI Catalog 时，项目维护者可以直接在其项目中启用代理和流。

### 为项目中的远程流配置网络访问控制

<a id="configure-network-access-control-for-remote-flows-in-projects"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/duo_agent_platform/environment_sandbox.md#configure-a-network-policy) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/593560)

{{< /details >}}

您现在可以为在项目中使用极狐GitLab Runner 的流配置[网络访问控制](../../user/duo_agent_platform/environment_sandbox.md)。

这提供了安全的外部集成，同时保持对网络目标的控制。这也使项目维护者能够灵活地允许必要的 API 连接、MCP 服务器和第三方服务，同时强制执行安全边界。

在 `agent-config.yml` 的 `network_policy` 部分配置[网络访问控制](../../user/duo_agent_platform/environment_sandbox.md)。`agent-config.yml` 受分支保护规则和合并请求审批工作流保护。

### 自托管 Vertex AI 用于极狐GitLab Duo Agent Platform

<a id="self-hosted-vertex-ai-for-gitlab-duo-agent-platform"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_llm_serving_platforms.md#configure-authentication-with-google-vertex-ai) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/591604)

{{< /details >}}

Vertex AI 现已成为极狐GitLab Duo Agent Platform 自部署版中受支持的 LLM 平台。

客户现在可以配置托管在 Vertex AI 上的 Anthropic 模型，用于极狐GitLab Duo Agent Platform 功能。

### 用户可以直接从项目启用代理和流

<a id="users-can-enable-agents-and-flows-directly-from-projects"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/duo_agent_platform/agents/custom.md#enable-an-agent) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/588012)

{{< /details >}}

维护者和所有者现在可以直接从其项目或探索页面启用代理和流，无需离开当前上下文。

顶级群组所有者还可以选择其群组以及他们想要激活代理和流的特定项目，以简化其工作流设置。

### 在 IDE 和 CI/CD 流水线中支持 Agent Skills

<a id="support-for-agent-skills-in-ides-and-cicd-pipelines"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/duo_agent_platform/customize/agent_skills.md) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/1984)

{{< /details >}}

极狐GitLab Duo Agent Platform 现已支持 [Agent Skills 规范](https://agentskills.io/specification)，这是一个为 AI Agent 提供新功能和专业知识的、新兴的标准。

您可以为项目在工作区级别定义 Agent Skills，为代理提供针对特定任务（例如使用特定框架编写测试）的专业知识和工作流。代理在遇到匹配任务时会自动发现并加载相关技能。

您还可以通过名称、文件路径或自定义斜杠命令手动触发技能。Agent Skills 可在您的 IDE 中用于流和 Agentic Chat，以及在 CI/CD 流水线中运行的流。它们也适用于任何支持该规范的其他 AI 工具。

## 规模化与部署

<a id="scale-and-deployments"></a>

### 以 CSV 格式下载信用使用数据

<a id="download-credit-usage-data-as-csv"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../subscriptions/gitlab_credits.md#export-usage-data) | [相关议题](https://gitlab.com/gitlab-org/customers-gitlab-com/-/work_items/14504)

{{< /details >}}

计费管理员现在可以直接从 Customers Portal 的极狐GitLab Credits 仪表盘将信用使用数据下载为 CSV 文件。

导出文件提供了当前计费月按天划分的、每个操作的信用消耗明细，包括已使用的承诺额度、豁免额度、试用额度、按需额度和包含的信用额度。

财务和运营团队可以使用这些数据，在 Excel、Google Sheets 或 BI 工具中执行成本分摊、计费返还报告和用量分析，无需手动收集数据或提出支持请求。

### 将信用使用情况关联到极狐GitLab Duo Agent Platform 会话

<a id="link-credit-usage-to-gitlab-duo-agent-platform-sessions"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../subscriptions/gitlab_credits.md#gitlab-credits-dashboard) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/579139)

{{< /details >}}

极狐GitLab Credits 仪表盘现在将信用消耗直接关联到生成该消耗的极狐GitLab Duo Agent Platform 会话。

在按用户细分的视图中，Agent Platform 用量行（例如 **Agentic Chat** 或 **Foundational Agents**）的 **Action** 列现在是一个可点击的超链接，可导航到相应的会话详情。

此链接提供了从计费到 AI 会话行为的直接审计跟踪，因此管理员可以调查信用使用情况、支持升级和合规性审查，而无需在多个系统之间手动关联时间戳。

### 在极狐GitLab Credits 仪表盘中对用户排序

<a id="sort-users-in-the-gitlab-credits-dashboard"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../subscriptions/gitlab_credits.md#view-the-gitlab-credits-dashboard) | [相关议题](https://gitlab.com/gitlab-org/customers-gitlab-com/-/work_items/15608)

{{< /details >}}

企业管理员现在可以按使用的总信用额度或用户名对极狐GitLab Credits 仪表盘中的 **Usage by User** 表进行排序。

默认排序顺序是按消耗的总信用额度（最高优先），因此最高消耗者无需滚动即可立即看到。

通过此视图，管理数千名极狐GitLab Duo 用户的管理员可以快速识别高用量个人，用于成本分摊、计费返还报告和许可证利用率审计。

### 针对 Explore 中项目的全新导航体验

<a id="new-navigation-experience-for-projects-in-explore"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/project/working_with_projects.md#explore-all-projects-on-an-instance) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/13786)

{{< /details >}}

我们精简了 **Explore** 中的项目页面，以减少杂乱并移除随着时间的推移积累的冗余选项。
简化后的界面现在专注于两个核心视图：

- **Active** 选项卡：发现近期有活动且正在开发的项目的项目。
- **Inactive** 选项卡：访问已存档的项目和计划删除的项目。

我们移除了几个冗余的选项卡：

- **Most starred** 项目，可以通过在 **Active** 或 **Inactive** 选项卡中按星标数量排序来找到。
- **All** 项目，可以通过查看 **Active** 和 **Inactive** 选项卡来找到。
- 由于功能有限和使用率低，**Trending** 选项卡将在极狐GitLab 19.0 中完全移除。

更简洁的设计与其他项目列表在视觉上保持一致。您仍然可以通过更合乎逻辑的组织方式和灵活的排序选项访问所有相同的内容。

## 统一 DevOps 和安全

<a id="unified-devops-and-security"></a>

### 依赖扫描支持 Java Gradle 构建文件的 SBOM 支持

<a id="dependency-scanning-with-sbom-support-for-java-gradle-build-files"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#manifest-fallback) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/588788)

{{< /details >}}
<a id="dependency-scanning-sbom-based-scanning-extended-to-self-managed"></a>

### 基于 SBOM 的依赖扫描扩展至私有化部署

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md)

{{< /details >}}

在极狐GitLab 18.10 中，我们将新的基于 SBOM 的依赖扫描功能的有限可用状态扩展到私有化部署实例。

此功能最初在极狐GitLab 18.5 中发布，仅对 JihuLab.com 提供有限可用，位于功能标志 `dependency_scanning_sbom_scan_api` 之后，默认禁用。

通过额外的改进和修复，我们现在有信心可靠地使用新的 SBOM 扫描内部 API，并默认启用此功能标志。

此内部 API 允许依赖扫描分析器生成包含所有组件漏洞的依赖扫描报告。

与之前在 CI/CD 流水线完成后处理 SBOM 报告的行为（测试版）不同，[此改进的流程](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#how-it-scans-an-application) 在 CI/CD 作业期间立即生成扫描结果，使用户能够即时访问漏洞数据以用于自定义工作流。

遇到问题的私有化部署客户可以禁用 `dependency_scanning_sbom_scan_api` 功能标志。然后分析器将回退到以前的行为。

要使用此功能，请导入 v2 依赖扫描模板 `Jobs/Dependency-Scanning.v2.gitlab-ci.yml`。

我们欢迎对此功能的反馈。如果您有问题、意见或希望与我们的团队交流，请与我们联系。

<a id="license-scanning-support-for-dartflutter-projects-using-pub-package-manager"></a>

### 对使用 Pub 包管理器的 Dart/Flutter 项目的许可证扫描支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#data-sources) | [相关史诗](https://jihulab.com/groups/gitlab-org/-/work_items/18351)

{{< /details >}}

极狐GitLab 现在支持对使用 `pub` 包管理器的 Dart 和 Flutter 项目进行许可证扫描。

以前，使用 Dart 或 Flutter 构建的团队无法直接在极狐GitLab 中识别其开源依赖项的许可证，从而为有许可证策略要求的组织造成了合规盲点。

许可证数据直接来源于官方 Dart 包仓库 [pub.dev](https://pub.dev)，结果与其他支持的生态系统一起呈现。

Dart/Flutter 依赖扫描和漏洞检测已经受支持。

<a id="conan-20-package-registry-support-beta"></a>

### Conan 2.0 软件包仓库支持（测试版）

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/packages/conan_2_repository/_index.md)

{{< /details >}}

使用 Conan 作为包管理器的 C 和 C++ 开发团队长期以来一直要求在极狐GitLab 中提供仓库支持。

以前，Conan 软件包仓库是实验性的，仅支持 Conan 1.x 客户端，限制了已迁移到现代 Conan 2.0 工具链的团队的采用。

Conan 软件包仓库现在支持 Conan 2.0，并已从实验性升级为测试版。

此版本包括完整的 v2 API 兼容性、配方修订支持、改进的搜索功能，以及正确处理包括 `--force` 标志在内的上传策略。

团队可以使用标准 Conan 客户端工作流直接从极狐GitLab 发布和安装 Conan 2.0 软件包，减少了对 JFrog Artifactory 等外部制品管理解决方案的需求。

通过此更新，管理 C 和 C++ 依赖关系的平台工程团队可以将软件包管理与源代码、CI/CD 流水线和安全扫描一起整合到极狐GitLab 中。

Conan 仓库支持项目级和实例级端点，并可与个人访问令牌、部署令牌和 CI/CD 作业令牌一起用于身份验证。

在我们努力实现 GA 的过程中，我们欢迎反馈。请在[史诗](https://jihulab.com/groups/gitlab-org/-/work_items/6816)中分享您的经验。

<a id="manage-container-virtual-registries-with-a-dedicated-ui-beta"></a>

### 使用专用 UI 管理容器虚拟仓库（测试版）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/packages/virtual_registry/container/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-org/-/work_items/19283)

{{< /details >}}

当容器虚拟仓库在上一个里程碑以测试版推出时，平台工程师可以将多个上游容器镜像仓库（Docker Hub、Harbor、Quay 等）聚合到一个拉取端点后面。

但是，所有配置都需要直接调用 API，这意味着团队必须维护脚本或手动 curl 命令来创建和管理他们的仓库、配置上游以及处理随时间的变化。

这增加了运维开销，并使不习惯直接使用 API 的用户无法使用该功能。

现在可以直接从极狐GitLab UI 创建和管理容器虚拟仓库。

从群组级别的容器镜像仓库页面，您可以创建新的虚拟仓库、使用身份验证凭据配置上游源、编辑现有配置以及删除不再需要的仓库——所有这些都无需离开极狐GitLab 或编写任何 API 调用。

该 UI 与现有的容器镜像仓库体验无缝集成，使虚拟仓库成为群组制品管理工作流的一等公民。

此功能处于测试版。要分享反馈，请留下评论。

<a id="gitlab-helm-chart-registry-generally-available"></a>

### 极狐GitLab Helm Chart 仓库 GA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/packages/helm_repository/_index.md)

{{< /details >}}

使用 Helm 管理 Kubernetes 应用部署的团队现在可以依赖极狐GitLab Helm Chart 仓库来满足生产工作负载。

以前处于测试版，现在在解决了关键架构和可靠性问题后，该仓库已 GA。

通往 GA 的道路包括解决阻止 `index.yaml` 端点返回超过 1,000 个图表的硬限制，修复导致新发布的图表版本从索引中缺失的后台索引错误，完成全面的 AppSec 安全审查，并为 Helm 元数据缓存添加 Geo 复制支持，确保运行极狐GitLab Geo 的私有化部署客户的高可用性。

平台和 DevOps 团队可以使用标准 Helm 客户端工作流直接从极狐GitLab 发布和安装 Helm 图表，支持项目级端点以及使用个人访问令牌、部署令牌和 CI/CD 作业令牌进行身份验证。

现在，您可以将图表与依赖它们的源代码、流水线和安全扫描放在一起。

<a id="task-item-support-in-markdown-tables"></a>

### Markdown 表格中的任务项支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/markdown.md#task-lists-in-tables)

{{< /details >}}

您现在可以直接在 Markdown 表格单元格中使用任务项复选框语法。

以前，实现此功能需要结合原始 HTML 和 Markdown，这既繁琐又难以维护。

这一改进使得在议题、史诗和其他内容的结构化表格布局中直接跟踪任务完成情况变得更加容易。

<a id="pipeline-secret-detection-in-security-configuration-profiles"></a>

### 安全配置配置文件中的流水线密钥检测

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/configuration/security_configuration_profiles.md)

{{< /details >}}

在极狐GitLab 18.9 中，我们引入了安全配置配置文件，首先是 **密钥检测 - 默认** 配置文件，从推送保护开始。

您可以使用该配置文件在数百个项目中应用标准化的密钥扫描，而无需修改任何 CI/CD 配置文件。

**密钥检测 - 默认** 配置文件现在还涵盖了基于流水线的扫描，为整个开发工作流中的密钥检测提供了统一的控制面。

该配置文件激活三个扫描触发器：

- **推送保护**：扫描所有 Git 推送事件，并阻止检测到密钥的推送，防止密钥进入您的代码库。
- **合并请求流水线**：每次将新提交推送到具有开放合并请求的分支时，自动运行扫描。结果仅包括合并请求引入的新漏洞。
- **分支流水线（仅默认）**：当更改合并或推送到默认分支时自动运行，提供默认分支密钥检测状态的完整视图。

应用该配置文件无需 YAML 配置。可以将配置文件应用于群组，以将覆盖范围传播到群组中的所有项目，也可以应用于单个项目以实现更精细的控制。

<a id="macos-tahoe-26-and-xcode-26-job-image"></a>

### macOS Tahoe 26 和 Xcode 26 作业镜像

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/macos.md) | [相关史诗](https://jihulab.com/groups/gitlab-com/gl-infra/-/work_items/1694)

{{< /details >}}

您现在可以使用 macOS Tahoe 26 和 Xcode 26 为最新一代 Apple 设备创建、测试和部署应用程序。

借助 [macOS 上的托管 Runner](../../ci/runners/hosted_runners/macos.md)，您的开发团队可以在与极狐GitLab CI/CD 集成的安全、按需构建环境中更快地构建和部署 macOS 应用程序。

立即在您的 `.gitlab-ci.yml` 文件中使用 `macos-26-xcode-26` 镜像进行尝试。

<a id="gitlab-runner-1810"></a>

### 极狐GitLab Runner 18.10

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.10！

极狐GitLab Runner 是高度可扩展的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。

极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 中包含的开源持续集成服务。

#### 新功能

- [允许 k8s runner 为构建 pod 定义 Pod 级别资源](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39085)
- [添加自动化以更新所有 Runner 项目的 Go 版本和软件包](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39192)

#### 错误修复

- [使用 RoleARN 的 S3 缓存对于不存在的缓存返回 403 而不是 404](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39105)
- [使用辅助镜像 `gitlab-runner-helper:x86_64-v16.11.1-nanoserver21H2` 导致 `init-permissions` 错误](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/37872)
- [MacOS：LaunchAgent - 服务无法在 M1 架构上初始化](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/28136)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/18-10-stable/CHANGELOG.md) 中。