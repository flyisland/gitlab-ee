---
stage: Release Notes
group: Monthly Release
date: 2026-03-19
title: "极狐GitLab 18.10 发布说明"
description: "极狐GitLab 18.10 发布，带来使用极狐GitLab Duo Agent Platform 的 SAST 误报检测"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2026 年 3 月 19 日，极狐GitLab 18.10 正式发布，带来以下新功能。

<a id="primary-features"></a>

## 主要功能

<a id="sast-false-positive-detection-with-gitlab-duo-agent-platform"></a>

### 使用极狐GitLab Duo Agent Platform 进行 SAST 误报检测

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/application_security/vulnerabilities/false_positive_detection.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/19789)

{{< /details >}}

SAST 误报检测最初在极狐GitLab 18.7 中作为测试版推出，现已在极狐GitLab 18.10 中正式发布。

当安全扫描运行时，极狐GitLab Duo Agent Platform 会分析每个严重级别和高危级别的 SAST 漏洞，并判断其为误报的可能性。评估结果会直接显示在漏洞报告中，为团队提供所需的上下文，使其能够自信而非不确定地进行分类处理。

主要功能包括：

- 自动分析：每次安全扫描后自动运行误报检测，无需人工干预。
- 手动选项：用户可以在漏洞详情页面对单个漏洞手动运行误报检测，以进行按需分析。
- 聚焦高影响发现项：将分析范围限制在严重级别和高危级别的 SAST 漏洞，从而在最重要的地方排除干扰。
- 上下文 AI 推理：每项评估都会解释某个发现项为何可能是或不是误报，并综合考虑代码上下文、数据流以及静态分析特有的漏洞特征。
- 无缝工作流集成：结果直接显示在漏洞报告中，与现有的严重性、状态和修复信息并列——无需更改现有工作流。

此功能适用于已使用极狐GitLab Duo Agent Platform 的旗舰版客户。该功能必须在您的群组或项目设置中启用。欢迎在[议题 583697](https://gitlab.com/gitlab-org/gitlab/-/issues/583697)中提供反馈。

<a id="purchase-gitlab-credits-on-the-free-tier-on-gitlabcom"></a>

### 在 JihuLab.com 的基础版中购买极狐GitLab Credits

<!-- categories: Subscription Management -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 附加组件: 极狐GitLab Credits
- 链接: [文档](../../subscriptions/gitlab_credits.md#for-the-free-tier) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20165)

{{< /details >}}

JihuLab.com 上基础版的群组所有者现在可以通过极狐GitLab Credits 解锁 AI 能力。购买月度额度、承诺年度期限，即可访问[极狐GitLab Duo Agent Platform Agent 和任务流](../../subscriptions/gitlab_credits.md#for-the-free-tier)。额度每月自动刷新，因此您的团队始终拥有更快、更智能地构建所需的一切。

主要亮点：

- **基于用量的定价**：购买月度额度承诺，无需基础套餐订阅。
- **自助购买**：通过极狐GitLab 购买流程购买额度。
- **无缝升级路径**：如果您之后升级到专业版或旗舰版，您的额度承诺将随之转移。
- **用量跟踪**：通过极狐GitLab Credits 仪表板监控您的额度使用情况。

此[购买选项](../../subscriptions/gitlab_credits.md#buy-gitlab-credits)目前仅适用于免费的 JihuLab.com 顶级群组。

<a id="sign-in-securely-with-passkeys"></a>

### 使用通行密钥安全登录

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../auth/passkeys.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/10897)

{{< /details >}}

极狐GitLab 现在支持使用通行密钥进行无密码登录，并将其作为一种可抵御网络钓鱼的双因素认证 (2FA) 方式。通行密钥使用公钥加密和生物识别认证（指纹、面部识别）或您的设备 PIN 来安全访问您的账号。

通行密钥具有以下优势：

- **无密码的便捷性**：使用设备的生物识别或 PIN 登录，无需记住密码。
- **多设备支持**：可在桌面浏览器、移动设备（iOS 16 或更高版本、Android 9 或更高版本）以及兼容 FIDO2/WebAuthn 的硬件安全密钥上使用通行密钥。
- **抵御网络钓鱼的安全性**：您的私钥永远不会离开您的设备。极狐GitLab 仅存储公钥，即使极狐GitLab 服务器被攻破也能保护您的账号。
- **自动 2FA 集成**：对于已启用 2FA 的账号，通行密钥可作为默认的 2FA 方式使用。

要开始使用，请在您的账号设置中添加通行密钥。欢迎在议题 [366758](https://gitlab.com/gitlab-org/gitlab/-/work_items/366758)中提出问题和反馈。

<a id="introducing-the-work-items-list-and-saved-views"></a>

### 推出工作项列表和已保存视图

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/work_items/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/17530)

{{< /details >}}

极狐GitLab 的规划体验通过工作项列表和已保存视图获得了重大升级，将两项长期以来的需求整合在一起：

- 工作项列表将史诗、议题和其他工作项合并到一个统一的列表中，无需在不同工作项类型的独立页面之间切换。这让您更容易理解各规划对象之间的关系。
- 已保存视图允许您创建并保存自定义的列表配置，包括筛选条件、排序顺序和显示选项。这使日常检查更加高效，并支持团队以标准化的方式查看工作。

这是极狐GitLab 工作项之旅的下一步，这一统一架构旨在为极狐GitLab 规划工具带来一致性并解锁新能力。

请在[议题 590689](https://gitlab.com/gitlab-org/gitlab/-/work_items/590689)中分享您的想法和反馈。

<a id="custom-agents-can-use-mcp-to-access-external-data"></a>

### 自定义 Agent 可以使用 MCP 访问外部数据

<!-- categories: AI Catalog -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/gitlab_duo/model_context_protocol/ai_catalog_mcp_servers.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590708)

{{< /details >}}

您现在可以将 AI 目录中的自定义 Agent 通过模型上下文协议（MCP）连接到外部数据源和工具，而无需离开极狐GitLab。

此功能为实验。请在[议题 593219](https://gitlab.com/gitlab-org/gitlab/-/work_items/593219)中分享您的反馈。

<a id="enforce-merge-request-title-naming-conventions-with-regex"></a>

### 使用正则表达式强制实施合并请求标题命名规范

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/title_validation.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20108)

{{< /details >}}

保持一致的合并请求标题对于依赖结构化命名规范的团队来说非常重要。无论是遵循 Conventional Commits 格式，还是链接到内部跟踪系统。团队以前需要外部工具或自定义 CI/CD 流水线作业来强制实施这些规范，但这种方法存在一个关键缺口。如果有人在流水线运行后更改了合并请求标题，则不会重新验证，合并请求仍可能以不符合规范的标题被合并。

您现在可以在项目设置中为合并请求配置必需的标题正则表达式。配置后，极狐GitLab 会将合并请求标题与该模式进行比对，作为可合并性检查——在标题更新为符合规范之前阻止合并，无论标题最后一次更改是在何时。

要进行设置，请转到项目的**设置 > 合并请求**，并在**合并请求标题必须匹配正则表达式**字段中输入正则表达式模式。

您现有的合并请求工作流将继续照常运行。此检查仅适用于您明确配置了标题正则表达式的项目。

<a id="secret-false-positive-detection-with-ai-beta"></a>

### 使用 AI 进行密钥误报检测（测试版）

<!-- categories: Vulnerability Management, Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/application_security/vulnerabilities/secret_false_positive_detection.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20152)

{{< /details >}}

安全团队花费大量时间调查最终被证明是误报的密钥检测发现项。例如，被错误标记为实际密钥的测试凭据、示例值和占位符令牌。误报会造成告警疲劳、削弱对扫描结果的信任，并分散对真正安全风险的注意力。

极狐GitLab 18.10 引入了 AI 驱动的密钥误报检测（测试版），以聚焦于真正重要的密钥。当安全扫描运行时，极狐GitLab Duo 会自动分析每个**严重**和**高危**级别的密钥检测漏洞，以判断其是否为误报。

AI 评估结果会直接显示在漏洞报告中，为安全工程师提供即时上下文，以便更快、更自信地做出分类决策。

主要功能包括：

- 自动分析：每次安全扫描后自动运行误报检测，无需手动触发。
- 手动触发选项：您可以在漏洞详情页面对单个漏洞手动触发误报检测，以进行按需分析。
- 聚焦高影响发现项：范围限定为**严重**和**高危**级别的漏洞，以最大化信噪比改善。
- 上下文 AI 推理：每项评估都会解释该发现项为何可能是或不是真阳性，依据代码上下文和漏洞特征。
- 置信度评分：每项检测都包含置信度评分，帮助团队根据模型的确定性来优先安排审查。
- 无缝工作流集成：结果直接显示在漏洞报告中，与现有的严重性、状态和修复信息并列。

此功能作为免费测试版提供给旗舰版客户，并且必须在您的群组或项目设置中启用。请在[议题 592861](https://gitlab.com/gitlab-org/gitlab/-/work_items/592861)中分享反馈。

<a id="use-runtime-inputs-with-cicd-jobs"></a>

### 在 CI/CD 作业中使用运行时输入

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/job_inputs.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17833)

{{< /details >}}

使用 CI/CD 变量进行动态作业配置可能颇具挑战。变量遵循复杂的覆盖层级，难以管理，并且无法用于多种用例。

现在您可以使用 `inputs` 在作业级别定义显式的、带类型的输入。使用作业输入来定义和控制作业在运行时接受的值。使用作业输入，您可以获得：

- 类型安全（字符串、数字、布尔值、数组）。
- 默认值，可以是静态的，也可以引用现有变量。
- 可定义严格的可选值列表。
- 支持使用正则表达式验证输入值。

作业输入可以使用默认值而无需任何用户交互，但您可以在重试作业或运行手动作业时修改这些值。

<a id="agentic-core"></a>

## AI 功能

<a id="gitlab-blob-search-for-group-and-instance-code-search"></a>

### 用于群组和实例代码搜索的极狐GitLab Blob Search

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/agents/tools.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/593221)

{{< /details >}}

[`[gitlab_blob_search](../../user/duo_agent_platform/agents/tools.md)`](../../user/duo_agent_platform/agents/tools.md) 工具现在使极狐GitLab AI Agent 能够搜索您的代码：

- 跨群组中的所有项目。
- 跨实例上所有可访问的项目。

此前，blob 搜索仅限于单个项目，或需要指定明确的项目 ID。此变更使 AI 驱动的工作流更容易发现和复用分散在多个相关项目中的代码。

<a id="gitlab-mcp-server-tool-for-pipeline-management"></a>

### 用于流水线管理的极狐GitLab MCP 服务器工具

<!-- categories: MCP Server -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/model_context_protocol/mcp_server_tools.md#manage_pipeline) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/583826)

{{< /details >}}

您现在可以使用新的 `manage_pipeline` 工具在极狐GitLab 项目中管理您的 CI/CD 流水线。此极狐GitLab MCP 服务器工具让 AI Agent 能够在一次调用中创建、取消、重试、删除和更新流水线元数据。借助此工具，您不再需要拼凑多个步骤来自动化您的流水线工作流。

如果您想了解其他极狐GitLab MCP 服务器工具，请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/566375)中告诉我们。

<a id="project-maintainers-can-enable-custom-agents-and-flows"></a>

### 项目维护者可以启用自定义 Agent 和任务流

<!-- categories: AI Catalog -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/flows/custom.md#enable-a-flow) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590573)

{{< /details >}}

此前，从 AI 目录启用 AI Agent 和任务流需要顶级群组权限。

现在，在探索级别或项目级别浏览 AI 目录时，项目维护者可以直接在其项目中启用 Agent 和任务流。

<a id="configure-network-access-control-for-remote-flows-in-projects"></a>

### 为项目中的远程任务流配置网络访问控制

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/environment_sandbox.md#configure-a-network-policy) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/593560)

{{< /details >}}

您现在可以为项目中使用极狐GitLab Runner 的任务流配置[网络访问控制](../../user/duo_agent_platform/environment_sandbox.md)。

这提供了安全的外部集成，同时保持对网络目标的控制。这也使项目维护者能够灵活地允许必要的 API 连接、MCP 服务器和第三方服务，同时强制实施安全边界。

在 `agent-config.yml`的 `network_policy` 部分配置[网络访问控制](../../user/duo_agent_platform/environment_sandbox.md)。`agent-config.yml` 受分支保护规则和合并请求审批工作流保护。

<a id="self-hosted-vertex-ai-for-gitlab-duo-agent-platform"></a>

### 用于极狐GitLab Duo Agent Platform 的自部署 Vertex AI

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_llm_serving_platforms.md#configure-authentication-with-gemini-enterprise-agent-platform) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/591604)

{{< /details >}}

Vertex AI 现在是极狐GitLab Duo Agent Platform 自部署版本中受支持的 LLM 平台。

客户现在可以配置托管在 Vertex AI 上的 Anthropic models，以用于极狐GitLab Duo Agent Platform 功能。

<a id="users-can-enable-agents-and-flows-directly-from-projects"></a>

### 用户可以直接从项目启用 Agent 和任务流

<!-- categories: AI Catalog -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/agents/custom.md#enable-an-agent) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/588012)

{{< /details >}}

维护者和所有者现在可以直接从其项目或探索页面启用 Agent 和任务流，而无需离开当前上下文。

顶级群组所有者还可以选择其群组，以及他们想要激活 Agent 和任务流的特定项目，从而简化其工作流设置。

<a id="support-for-agent-skills-in-ides-and-cicd-pipelines"></a>

### 在 IDE 和 CI/CD 流水线中支持 Agent Skills

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/customize/agent_skills.md) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/1984)

{{< /details >}}

极狐GitLab Duo Agent Platform 现在支持 [Agent Skills 规范](https://agentskills.io/specification)，
这是一项为 AI Agent 赋予新能力和专业知识的新兴标准。

您可以在项目的工作区级别定义 Agent Skills，为 Agent 提供针对特定任务的专门知识和工作流，例如使用特定框架编写测试。Agent 在遇到匹配的任务时会自动发现并加载相关的 skills。

您还可以按名称、文件路径或自定义 slash 命令手动触发 skills。
Agent Skills 可用于 IDE 中的任务流和 Agentic Chat，以及
在 CI/CD 流水线中运行的任务流。它们也可与任何其他支持该规范的 AI 工具配合使用。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="download-credit-usage-data-as-csv"></a>

### 以 CSV 格式下载额度使用数据

<!-- categories: Consumables Cost Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../subscriptions/gitlab_credits_dashboard.md#export-usage-data) | [相关议题](https://gitlab.com/gitlab-org/customers-gitlab-com/-/work_items/14504)

{{< /details >}}

账单管理员现在可以直接从客户门户的极狐GitLab Credits 仪表板下载额度使用数据为 CSV 文件。

该导出提供当前账单月按操作划分的每日额度消耗明细，包括已使用的承诺额度、豁免额度、试用额度、按需额度和包含额度。

财务和运营团队可以使用这些数据在 Excel、Google Sheets 或 BI 工具中执行成本分摊、成本回摊报告和使用情况分析，而无需手动收集数据或提交支持请求。

<a id="link-credit-usage-to-gitlab-duo-agent-platform-sessions"></a>

### 将额度使用情况关联到极狐GitLab Duo Agent Platform 会话

<!-- categories: Consumables Cost Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../subscriptions/gitlab_credits_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/579139)

{{< /details >}}

极狐GitLab Credits 仪表板现在将额度消耗直接关联到产生该消耗的极狐GitLab Duo Agent Platform 会话。

在按用户下钻视图中，Agent Platform 使用行（如 **Agentic Chat** 或 **Foundational Agents**）的**操作**列现在是一个可点击的超链接，可导航到相应的会话详情。

此链接提供了从账单到 AI 会话行为的直接审计事件记录，因此管理员可以调查额度使用情况、支持升级和合规审查，而无需在多个系统之间手动关联时间戳。

<a id="new-navigation-experience-for-projects-in-explore"></a>

### 探索中项目的新导航体验

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md#explore-all-projects-on-an-instance) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/13786)

{{< /details >}}

我们简化了**探索**中的项目页面，以减少杂乱并移除随时间累积的冗余选项。简化后的界面现在聚焦于两个核心视图：

- **活跃**选项卡：发现具有近期活动和持续开发的项目。
- **非活跃**选项卡：访问已归档和计划删除的项目。

我们移除了几个冗余的选项卡：

- **最多星标**项目可以通过按星标数对**活跃**或**非活跃**选项卡进行排序来找到。
- **全部**项目可以通过查看**活跃**和非活跃选项卡来获取。
- **趋势**选项卡将在极狐GitLab 19.0 中完全移除，因为其功能有限且使用率低。

更简洁的设计与其他项目列表保持一致，以实现视觉一致性。您仍然可以通过更合理的组织和灵活的排序选项访问所有相同的内容。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="dependency-scanning-with-sbom-support-for-java-gradle-build-files"></a>

### 对 Java Gradle 构建文件的 SBOM 依赖扫描支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#manifest-fallback) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/588788)

{{< /details >}}

使用 SBOM 的极狐GitLab 依赖扫描现在支持扫描 Java `build.gradle` 和 `build.gradle.kts` 构建文件。

此前，对使用 Gradle 的 Java 项目进行依赖扫描需要存在锁文件。现在，当锁文件不可用时，分析器会自动回退到扫描 `build.gradle` 和 `build.gradle.kts` 文件，仅提取并报告直接依赖以进行漏洞分析。此改进使使用 Gradle 的 Java 项目更容易启用依赖扫描，而无需锁文件。

要启用清单回退，请将 `DS_ENABLE_MANIFEST_FALLBACK` CI/CD 变量设置为`"true"`。

<a id="dependency-scanning-sbom-based-scanning-extended-to-self-managed"></a>

### 基于 SBOM 的依赖扫描扩展至私有化部署

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/546429)

{{< /details >}}

在极狐GitLab 18.10 中，我们将新的基于 SBOM 的依赖扫描功能的限量提供状态扩展至私有化部署实例。

此功能最初在极狐GitLab 18.5 中发布，仅对 JihuLab.com 限量提供，受功能标志 `dependency_scanning_sbom_scan_api` 控制并默认禁用。

经过额外的改进和修复，我们现在有信心可靠地使用新的 SBOM 扫描内部 API 并默认启用此功能标志。此内部 API 允许依赖扫描分析器生成包含所有组件漏洞的依赖扫描报告。与之前的行为（测试版）在 CI/CD 流水线完成后处理 SBOM 报告不同，[此改进的流程](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#how-it-scans-an-application)在 CI/CD 作业期间立即生成扫描结果，使用户能够即时访问漏洞数据以用于自定义工作流。

遇到问题的私有化部署客户可以禁用 `dependency_scanning_sbom_scan_api` 功能标志。分析器随后将回退到之前的行为。

要使用此功能，请导入 v2 依赖扫描模板 `Jobs/Dependency-Scanning.v2.gitlab-ci.yml`。

欢迎对此功能提供反馈。如果您有问题、意见，或希望与我们的团队交流，请在此[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523458)中联系我们。

<a id="license-scanning-support-for-dartflutter-projects-using-pub-package-manager"></a>

### 对使用 Pub 包管理器的 Dart/Flutter 项目的许可证扫描支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#data-sources) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/18351)

{{< /details >}}

极狐GitLab 现在支持对使用 `pub` 包管理器的 Dart 和 Flutter 项目进行许可证扫描。此前，使用 Dart 或 Flutter 构建的团队无法直接在极狐GitLab 中识别其开源依赖的许可证，这给有许可证政策要求的组织造成了合规盲区。

许可证数据直接来源于 [pub.dev](https://pub.dev)，即官方 Dart 包仓库，结果与其他受支持的生态系统并列显示。Dart/Flutter 依赖扫描和漏洞检测此前已受支持。

<a id="conan-20-package-registry-support-beta"></a>

### Conan 2.0 软件包仓库支持（测试版）

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/conan_2_repository/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/585819)

{{< /details >}}

使用 Conan 作为包管理器的 C 和 C++ 开发团队长期以来一直要求在极狐GitLab 中提供仓库支持。此前，Conan 软件包仓库处于实验阶段，仅支持 Conan 1.x 客户端，限制了已迁移到现代 Conan 2.0 工具链的团队的采用。

Conan 软件包仓库现在支持 Conan 2.0，并已从实验阶段提升为测试版。此版本包括完整的 v2 API 兼容性、配方修订支持、改进的搜索功能，以及对上传策略（包括`--force` 标志）的正确处理。团队可以使用标准 Conan 客户端工作流直接从极狐GitLab 发布和安装 Conan 2.0 软件包，减少了对 JFrog Artifactory 等外部产物管理解决方案的需求。

通过此更新，管理 C 和 C++ 依赖的平台工程团队可以将其包管理整合到极狐GitLab 中，与源代码、CI/CD 流水线和安全扫描放在一起。Conan 仓库支持项目级和实例级端点，并可使用个人访问令牌、部署令牌和 CI/CD 作业令牌进行认证。

在我们朝着正式发布努力的过程中，欢迎提供反馈。请在[史诗](https://gitlab.com/groups/gitlab-org/-/work_items/6816)中分享您的体验。

<a id="manage-container-virtual-registries-with-a-dedicated-ui-beta"></a>

### 使用专用 UI 管理容器虚拟仓库（测试版）

<!-- categories: Virtual Registry -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/virtual_registry/container/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/19283)

{{< /details >}}

当容器虚拟仓库在上一个里程碑以测试版推出时，平台工程师可以将多个上游容器镜像仓库——Docker Hub、Harbor、Quay 等——聚合到单个拉取端点后面。然而，所有配置都需要直接调用 API，这意味着团队必须维护脚本或手动 curl 命令来创建和管理其仓库、配置上游，并处理随时间推移的变更。这增加了运维开销，并使不熟悉直接使用 API 的用户无法使用该功能。

容器虚拟仓库现在可以直接从极狐GitLab UI 创建和管理。在群组级容器镜像仓库页面中，您可以创建新的虚拟仓库、使用认证凭据配置上游源、编辑现有配置，以及删除不再需要的仓库——所有这些都无需离开极狐GitLab 或编写任何 API 调用。该 UI 与现有的容器镜像仓库体验无缝集成，使虚拟仓库成为您群组产物管理工作流中的一等公民。

此功能处于测试版。要分享反馈，请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/589630)中发表评论。

<a id="gitlab-helm-chart-registry-generally-available"></a>

### GitLab Helm Chart 仓库正式发布

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/helm_repository/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/573715)

{{< /details >}}

使用 Helm 管理 Kubernetes 应用部署的团队现在可以依赖 GitLab Helm Chart 仓库来处理生产工作负载。该仓库此前处于测试版，在关键架构和可靠性问题得到解决后现已正式发布。

通往正式发布的道路包括：解决了一个阻止 `index.yaml` 端点返回超过 1,000 个 chart 的硬性限制，修复了一个导致新发布的 chart 版本从索引中缺失的后台索引错误，完成了完整的 AppSec 安全审查，并为 Helm 元数据缓存添加了 Geo 复制支持，确保运行极狐GitLab Geo 的私有化部署客户享有高可用性。

平台和 DevOps 团队可以使用标准 Helm 客户端工作流直接从极狐GitLab 发布和安装 Helm chart，支持项目级端点，并使用个人访问令牌、部署令牌和 CI/CD 作业令牌进行认证。现在您可以将 chart 与依赖它们的源代码、流水线和安全扫描放在一起。

<a id="task-item-support-in-markdown-tables"></a>

### Markdown 表格中的任务项支持

<!-- categories: Markdown -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md#task-lists-in-tables) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/21506)

{{< /details >}}

您现在可以直接在 Markdown 表格单元格中使用任务项复选框语法。

此前，要实现这一点需要结合原始 HTML 和 Markdown，既繁琐又难以维护。

此改进使您更容易在议题、史诗和其他内容的结构化表格布局中直接跟踪任务完成情况。

<a id="pipeline-secret-detection-in-security-configuration-profiles"></a>

### 安全配置配置文件中的流水线密钥检测

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/configuration/security_configuration_profiles.md)

{{< /details >}}

在极狐GitLab 18.9 中，我们引入了安全配置配置文件，并提供了 **密钥检测 - 默认** 配置文件，从推送保护开始。您可以使用该配置文件在数百个项目中应用标准化的密钥扫描，而无需触碰任何 CI/CD 配置文件。

**密钥检测 - 默认** 配置文件现在也涵盖基于流水线的扫描，为您的整个开发工作流中的密钥检测提供统一的控制界面。

该配置文件激活三种扫描触发器：

- **推送保护**：扫描所有 Git 推送事件，并阻止检测到密钥的推送，防止密钥进入您的代码库。
- **合并请求流水线**：每当新提交被推送到具有打开的合并请求的分支时，自动运行扫描。结果仅包含由该合并请求引入的新漏洞。
- **分支流水线（仅默认分支）**：当更改被合并或推送到默认分支时自动运行，提供默认分支密钥检测态势的完整视图。

应用该配置文件无需 YAML 配置。该配置文件可以应用于群组，以将覆盖范围传播到群组中的所有项目，也可以应用于单个项目以实现更细粒度的控制。

<a id="macos-tahoe-26-and-xcode-26-job-image"></a>

### macOS Tahoe 26 和 Xcode 26 作业镜像

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/macos.md) | [相关史诗](https://gitlab.com/groups/gitlab-com/gl-infra/-/work_items/1694)

{{< /details >}}

您现在可以使用 macOS Tahoe 26 和 Xcode 26 为最新一代 Apple 设备创建、测试和部署应用程序。

借助 [macOS 上的托管 Runner](../../ci/runners/hosted_runners/macos.md)，
您的开发团队可以在与极狐GitLab CI/CD 集成的安全、按需构建环境中更快地构建和部署 macOS 应用程序。

立即在您的`.gitlab-ci.yml` 文件中使用 `macos-26-xcode-26` 镜像来试用。

<a id="gitlab-runner-1810"></a>

### 极狐GitLab Runner 18.10

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.10！
极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。
极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [允许 k8s runner 为构建 pod 定义 Pod 级资源](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39085)
- [为所有 Runner 项目添加自动更新 Go 版本和软件包的自动化](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39192)

<a id="bug-fixes"></a>

#### 缺陷修复

- [使用 RoleARN 的 S3 缓存对不存在的缓存返回 403 而非 404](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39105)
- [使用辅助镜像 `gitlab-runner-helper:x86_64-v16.11.1-nanoserver21H2` 导致 `init-permissions` 错误](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/37872)
- [MacOS：LaunchAgent - 服务在 M1 架构上无法初始化](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/28136)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-10-stable/[CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-10-stable/CHANGELOG.md).md)。
