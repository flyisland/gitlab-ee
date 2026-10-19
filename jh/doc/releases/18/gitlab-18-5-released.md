---
stage: Release Notes
group: Monthly Release
date: 2025-10-16
title: "极狐GitLab 18.5 发布说明"
description: "极狐GitLab 18.5 发布，推出 极狐GitLab Duo Planner，这是一款专业 Agent 和产品经理团队成员（测试版）"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 10 月 16 日，极狐GitLab 18.5 版本正式发布，带来了以下新功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-planner-a-specialized-agent-and-product-manager-team-member-beta"></a>

### 极狐GitLab Duo Planner，一款专业 Agent 和产品经理团队成员（测试版）

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/planner.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/576618)

{{< /details >}}

与极狐GitLab Duo Planner 协作，这是一款专为在极狐GitLab 内直接支持产品经理而构建的极狐GitLab Duo Agent。
无需再手动追踪更新、排定工作优先级或汇总规划数据，极狐GitLab Duo Planner 可帮助您分析待办事项列表、应用 RICE 或 MoSCoW 等框架，并呈现真正需要您关注的内容。它就像一位积极主动的队友，了解您的规划工作流，并与您一起做出更好、更快的决策。此功能目前处于测试版。请在[议题 576622](https://gitlab.com/gitlab-org/gitlab/-/issues/576622)中提供反馈。

<a id="gitlab-security-analyst-agent-for-duo-agent-catalog-beta"></a>

### 适用于 Duo Agent Catalog 的 极狐GitLab 安全分析师 Agent（测试版）

<!-- categories: Vulnerability Management, Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/agents/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19659)

{{< /details >}}

极狐GitLab Duo Agent Platform 中的 Agent 可用于在极狐GitLab 内执行任务并回答复杂问题。
用户可以创建自定义 Agent 来完成特定任务，例如创建合并请求或评审代码，
也可以使用 AI 目录发现极狐GitLab Agent。

在极狐GitLab 18.5 中，我们发布 极狐GitLab 安全分析师 Agent 作为测试版功能，可在 AI 目录中使用。要在特定项目中使用 极狐GitLab 安全分析师 Agent，请在极狐GitLab Duo Agentic Chat 中选择并启用该 Agent。该 Agent 可以执行以下任务：

- 列出给定项目中的所有漏洞。
- 获取详细的漏洞信息，包括 CVE 数据和 EPSS 评分。
- 确认和忽略漏洞。
- 更新漏洞严重性级别。
- 将漏洞状态恢复为 `detected`。
- 创建漏洞议题，或将漏洞链接到现有议题。

借助 极狐GitLab 安全分析师 Agent，用户可以通过 AI 驱动的自动化和智能分析执行繁琐的安全工作流，让工程师专注于真正的威胁，而由 极狐GitLab 安全分析师 Agent 处理重复性的评估和文档工作。请注意，使用极狐GitLab Duo Chat 的 极狐GitLab 安全分析师 Agent 仅适用于购买了极狐GitLab Duo 附加组件的旗舰版客户。

此功能处于测试版，欢迎您在[议题 576916](https://gitlab.com/gitlab-org/gitlab/-/issues/576916)中提供反馈。

<a id="maven-virtual-registry-now-available-in-beta"></a>

### Maven 虚拟仓库现已推出测试版

<!-- categories: Virtual Registry -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/virtual_registry/maven/_index.md#manage-virtual-registries) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14137)

{{< /details >}}

极狐GitLab 18.5 为 Maven 虚拟仓库管理引入了全面的基于 Web 的界面。此前，平台工程师只能通过 API 调用配置和管理虚拟仓库，这使得日常维护任务繁琐且需要专业知识。

这种基于 Web 的方式显著降低了平台工程团队的运维开销。常见任务，如清除过期缓存条目、为优化性能重新排序上游以及测试连接性，现在都可以通过点击操作完成。开发团队可以更好地了解其依赖配置，从而就构建性能和安全策略展开更明智的讨论。

Maven 虚拟仓库对极狐GitLab 专业版和旗舰版客户仍处于测试版。当前测试版的限制包括每个顶级群组最多 20 个虚拟仓库，每个虚拟仓库最多 20 个上游。

我们邀请企业客户参与 Maven 虚拟仓库测试版计划，以帮助塑造最终版本。请在[议题 543045](https://gitlab.com/gitlab-org/gitlab/-/issues/543045)中分享反馈和建议。

<a id="pick-up-where-you-left-off-on-the-new-personal-homepage"></a>

### 在新的个人主页上继续您上次的操作

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../tutorials/personal_homepage/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16657)

{{< /details >}}

您现在可以访问新的个人主页，它将您所有重要的极狐GitLab 活动整合到一个地方，让您更轻松地继续上次的操作。该主页汇集了您的待办事项、分配给您的议题、合并请求、评审请求以及最近查看的内容，帮助您在极狐GitLab 庞大的功能界面中导航，并专注于对您最重要的内容。

<a id="gpt-5-now-available-as-a-model-option-for-gitlab-duo-agentic-chat"></a>

### GPT-5 现可作为极狐GitLab Duo Agentic Chat 的模型选项

<!-- categories: Model Personalization -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/agentic_chat.md#select-a-model) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19124)

{{< /details >}}

在为极狐GitLab Duo Agent Platform 选择模型时，OpenAI GPT-5 现可作为极狐GitLab AI 供应商模型使用。当 JihuLab.com 上顶级群组的所有者以及私有化部署实例的管理员完成配置后，最终用户可以选择将 GPT-5 与极狐GitLab Duo 功能配合使用。顶级群组所有者和管理员可以继续通过命名空间或实例设置来设定组织范围的模型偏好，或允许最终用户从所有可用的极狐GitLab AI 供应商模型中进行选择。

要开始使用 GPT-5，请在极狐GitLab Duo Chat 的模型下拉列表中选择您偏好的模型。

<a id="instance-wide-compliance-and-security-policy-management"></a>

### 实例范围的合规与安全策略管理

<!-- categories: Compliance Management, Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../security/compliance_security_policy_management.md)

{{< /details >}}

企业用户希望跨多个顶级群组管理其[合规框架](../../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)和[安全策略](../../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md)。当实例中的所有群组出现以下情况时，通常会有此需求：

- 共享相同的合规框架。例如，当某个群组中的所有项目都必须遵循 ISO 27001 标准时。
- 强制执行类似的安全策略。例如，当所有群组共享相同的流水线执行策略时。

在极狐GitLab 18.5 中，我们引入了合规与安全策略群组，用于在极狐GitLab 私有化部署实例上集中管理安全策略和合规框架。通过此版本，您现在可以从单个顶级群组创建、配置和分配合规框架及安全策略，并在实例中的所有其他顶级群组中强制执行它们。

借助合规与安全策略群组，您拥有单一可信来源，可以在其中管理和编辑您的合规框架和安全策略。群组内的安全和合规用户随后可以将合规框架和安全策略应用于实例中的所有项目。

合规与安全策略群组使您更轻松地管理和执行整个实例的合规与安全需求。不过，群组仍保留创建自己的合规框架和安全策略的能力，以应对这些群组中可能出现的特定情况或工作流。

此功能面向极狐GitLab 私有化部署客户。JihuLab.com 客户可以使用安全策略项目在单个顶级群组或命名空间内集中管理框架和策略。

详细了解合规与安全策略群组，请参阅[合规框架](../../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)和[安全策略](../../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md)。

<a id="dast-authentication-scripts"></a>

### DAST 身份验证脚本

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/configuration/authentication_scripts.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17018)

{{< /details >}}

您现在可以向 CI/CD 配置中添加脚本，以自动化 DAST 身份验证工作流。身份验证脚本支持自动化复杂的身份验证流程，包括对基于时间的一次性密码（OTP MFA）的支持。

此增强功能可帮助您的团队在进行全面、自动化的安全扫描的同时，维持关键安全控制。通过支持真实世界的身份验证场景，脚本可减少阻力并确保对生产软件进行准确的安全评估。

<a id="agentic-core"></a>

## AI 功能

<a id="additional-triggers-for-cli-agents"></a>

### CLI Agent 的更多触发器

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/triggers/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/567787)

{{< /details >}}

您现在可以使用更多事件触发 CLI Agent，从而在项目中为 Agent 何时何地采取行动提供更大的灵活性和控制力。除了现有的 **提及** 触发器外，您还可以使用：

- **指派**：当合并请求或议题被指派时触发 Agent。
- **指派审核人**：当审核人被添加到合并请求时触发 Agent。

<a id="gitlab-duo-agent-platform-for-gitlab-duo-self-hosted-now-in-beta"></a>

### 适用于极狐GitLab Duo 自部署版本的极狐GitLab Duo Agent Platform 现已推出测试版

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/558083)

{{< /details >}}

极狐GitLab Duo Agent Platform 现已在极狐GitLab Duo 自部署版本中推出测试版。此功能面向所有私有化部署的极狐GitLab Duo Enterprise 客户。使用 AWS Bedrock 或 Azure OpenAI 的私有化部署实例管理员可以配置 Anthropic Claude 或 OpenAI GPT 模型，以配合极狐GitLab Duo Agent Platform 使用。自部署版本管理员还可以配置

[兼容模型](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models)

以配合极狐GitLab Duo Agent Platform 使用。

<a id="codestral-now-supported-for-gitlab-duo-chat-classic"></a>

### 极狐GitLab Duo Chat（经典版）现已支持 Codestral

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/550266)

{{< /details >}}

您现在可以在

极狐GitLab Duo 自部署版本

上使用 Mistral Codestral 进行经典版 Duo Chat。此模型支持极狐GitLab 私有化部署实例上的极狐GitLab Duo 自部署版本客户。

<a id="gpt-oss-models-compatible-with-gitlab-duo-agent-platform-for-gitlab-duo-self-hosted"></a>

### 与适用于极狐GitLab Duo 自部署版本的极狐GitLab Duo Agent Platform 兼容的 GPT OSS 模型

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19348)

{{< /details >}}

您现在可以在极狐GitLab Duo Agent Platform 上配合极狐GitLab Duo 自部署版本使用 GPT OSS 模型。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="enhanced-admin-area-groups-list"></a>

### 增强的**管理**区域群组列表

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/admin_area.md#administering-groups) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17783)

{{< /details >}}

我们升级了**管理**区域群组列表，为极狐GitLab 管理员提供更一致的体验：

- 延迟删除保护：群组删除现在遵循极狐GitLab 中通用的安全删除流程，防止意外数据丢失。
- 更快的交互：无需重新加载页面即可筛选、排序和分页群组，获得更灵敏的体验。
- 一致的界面：群组列表现在与极狐GitLab 中其他群组列表的外观和行为保持一致。

此更新使管理员体验与极狐GitLab 设计标准保持一致，并添加了重要的安全功能来保护您的数据。未来对群组管理的增强将自动出现在整个平台的所有群组列表中。

<a id="updated-navigation-experience-for-groups"></a>

### 更新的群组导航体验

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/_index.md#view-a-group) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13790)

{{< /details >}}

我们对群组概览列表进行了更改，以在整个极狐GitLab 中提供更一致、更高效的体验。这些改进使您更轻松地导航群组和项目，同时一目了然地提供更有价值的信息：

- 更丰富的项目信息：项目现在显示星标、forks、议题、合并请求和相关日期，让您一目了然地获得完整的活动概览。
- 简化的操作：使用操作菜单直接从概览中编辑或删除群组和项目。已归档和待删除的条目显示在**非活跃**标签页中。
- 一致的体验：群组概览现在与极狐GitLab 中其他群组和项目列表的外观和行为保持一致，带来更直观的体验。

这些增强功能将更多信息和操作置于您的指尖，从而节省时间。此更新还为批量编辑和高级筛选选项等未来功能奠定了基础。

<a id="improved-inactive-item-management-for-groups-and-projects"></a>

### 改进的群组和项目非活跃条目管理

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md#view-inactive-projects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/526211)

{{< /details >}}

**非活跃**标签页现在在整个极狐GitLab 中一致地在同一个统一位置显示所有非活跃条目。这包括已归档项目、待删除项目和待删除群组。此标签页可在群组概览页面以及**您的工作**、**探索**和**管理**区域中的群组和项目列表中使用。所有具有相应权限的用户都可以查看非活跃条目，但只有群组所有者以及项目所有者和维护者可以对其采取进一步操作。
作为此更新的一部分，Projects 和 Groups REST API 以及 GraphQL API 中现在都提供了新的 `active` 参数。

管理非活跃内容是维护极狐GitLab 实例的关键部分。此更新使查找和恢复已归档或待删除的内容变得更加容易，让您可以更好地控制极狐GitLab 资源，同时降低意外丢失有价值工作的风险。活跃内容与非活跃内容的清晰分离，还可在极狐GitLab 各个区域中导航群组和项目时提供更专注的搜索体验。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="new-vulnerability-management-features-in-gitlab-duo-agentic-chat"></a>

### 极狐GitLab Duo Agentic Chat 中的新漏洞管理功能

<!-- categories: Vulnerability Management, Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/agentic_chat.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19639)

{{< /details >}}

极狐GitLab Duo Agentic Chat 是极狐GitLab Duo Chat 的增强版本。它会搜索、
检索并组合来自您极狐GitLab 项目中多个来源的信息，以提供更全面、更相关的答案。其部分用例包括搜索项目、读取和列出文件，以及根据提供给极狐GitLab Duo Chat 的提示自主创建和更改文件。

在极狐GitLab 18.5 中，Agentic Chat 的用例扩展到包括管理
来自安全扫描器的漏洞。通过向 Agentic Chat 添加漏洞管理工具，这通过 AI 驱动的自动化和智能分析转变了繁琐的安全工作流，使安全专业人员能够通过自然语言命令高效地分类、管理和修复漏洞。这消除了在漏洞仪表板中手动点击数小时的工作，并简化了以前需要自定义脚本或繁琐手动工作的复杂批量操作。

借助添加到极狐GitLab Duo Chat 的新漏洞管理工具，拥有极狐GitLab Duo 的旗舰版用户可以执行以下操作：

- 列出给定项目中的所有漏洞。
- 获取详细的漏洞信息，包括 CVE 数据和 EPSS 评分。
- 确认和忽略漏洞。
- 更新漏洞严重性级别。
- 将漏洞状态恢复为 `detected`。
- 创建漏洞议题，或将漏洞链接到现有议题。

这些工具将安全工作流从被动的手动分类转变为智能修复，让工程师专注于真正的威胁，而由 AI 处理重复性的评估和文档工作。使用极狐GitLab Duo Chat 的漏洞管理仅适用于购买了极狐GitLab Duo 附加组件的旗舰版客户。

<a id="cc-support-for-advanced-sast"></a>

### 高级 SAST 的 C/C++ 支持

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/advanced_sast_cpp.md)

{{< /details >}}

我们为极狐GitLab 高级 SAST 添加了对 C/C++ 的测试版支持。

要使用这一新的跨文件、跨函数扫描支持，请[启用 C/C++ 支持](../../user/application_security/sast/advanced_sast_cpp.md)。

我们欢迎对此功能提供反馈。如果您有任何问题、意见，或希望与我们的团队交流，请参阅此[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/575671)。

<a id="secret-validity-checks-is-in-beta"></a>

### 密钥有效性检查处于测试版

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerabilities/validity_check.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16927)

{{< /details >}}

流水线密钥检测会提醒您项目中暴露的凭据，如密码或 API 密钥。然而，在极狐GitLab 18.5 之前，您必须手动检查每个检测结果是否代表一个有效的令牌。这可能使有效分类检测结果变得困难且耗时。

现在有效性检查处于测试版，启用它即可显示检测到的极狐GitLab 密钥的状态。有效密钥可用于冒充合法活动，因此您应尽快轮换它们。

<a id="increased-rule-coverage-for-secret-push-protection-and-pipeline-secret-detection"></a>

### 扩展密钥推送保护和流水线密钥检测的规则覆盖范围

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/detected_secrets.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/573973)

{{< /details >}}

极狐GitLab 流水线密钥检测中新增了规则。一些现有规则也已更新，以提高质量并减少误报。这些更改在密钥分析器的 [7.15.0 版本](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v7.15.0)中发布。

<a id="customizable-detection-logic-for-advanced-sast"></a>

### 高级 SAST 的可自定义检测逻辑

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/customize_rulesets.md)

{{< /details >}}

您现在可以使用极狐GitLab 高级 SAST 创建针对您组织特定安全需求和编码模式量身定制的自定义安全检测规则。此功能使您的安全团队能够定义超出预定义规则集的自定义漏洞模式，从而检测特定于应用程序的安全问题。

有关更多信息，请参阅[自定义规则集](../../user/application_security/sast/customize_rulesets.md)。

<a id="advanced-sast-diff-based-scanning-in-merge-requests"></a>

### 合并请求中基于差异的高级 SAST 扫描

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/gitlab_advanced_sast.md#diff-based-scanning)

{{< /details >}}

您现在可以使用极狐GitLab 高级 SAST 执行基于差异的扫描，仅分析合并请求中的代码更改，与全代码仓库扫描相比，可显著缩短扫描时间。通过仅扫描 Git 差异而非整个代码库，您的团队可以更无缝地将安全测试集成到开发工作流中，而不会牺牲速度或给合并请求流程增加阻力。

我们正在努力默认启用此性能改进；这已在[议题 546359](https://gitlab.com/gitlab-org/gitlab/-/issues/546359)中跟踪。

<a id="control-requests-for-external-control-statuses"></a>

### 外部控制状态的控制请求

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_frameworks/_index.md#ping-enabled-setting) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521757)

{{< /details >}}

在极狐GitLab 中创建合规框架时，外部控制可以附加到要求上。

默认情况下，极狐GitLab 在合规扫描期间每 12 小时自动从外部系统请求外部控制的状态，将控制状态设置为“pending”。外部系统随后通过使用外部控制 API 将状态更新为“pass”或“fail”来响应。

在极狐GitLab 18.5 中，您现在可以在配置外部控制时关闭 **Ping 已启用**设置，从而禁用此自动 12 小时 ping。当 12 小时 ping 被禁用时：

- 极狐GitLab 将不会自动从外部系统请求状态更新。
- 外部控制在合规框架 UI 中显示**已禁用**徽章。
- 您可以使用外部控制 API 完全控制外部控制状态的更新时间。

这可以防止系统将外部控制状态重置为“pending”，并让您完全控制状态更新时间。

<a id="dependency-scanning-in-limited-availability"></a>

### 限量提供的依赖扫描

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15961)

{{< /details >}}

在极狐GitLab 18.5 中，我们发布了一个新的依赖扫描模板，可与依赖扫描分析器配合使用。该分析器现在会生成包含所有组件漏洞的依赖扫描报告。扫描执行策略（SEP）和流水线执行策略（PEP）支持新模板。

要使用新模板，请导入 `Jobs/Dependency-Scanning.v2.gitlab-ci.yml`。

此功能在 JihuLab.com 和私有化部署实例上可用，不过它被标记为限量提供，因为对私有化部署的官方支持尚未推出。JihuLab.com 用户可以立即使用它。

我们欢迎对此功能提供反馈。如果您有问题、意见，或希望与我们的团队交流，请参阅此[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523458)。

<a id="variable-expansion-in-environment-deployment_tier"></a>

### 环境 `deployment_tier`中的变量展开

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#environmentdeployment_tier) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/365402)

{{< /details >}}

您现在可以在 `environment:deployment_tier` 字段中使用 CI/CD 变量，从而更轻松地根据流水线条件动态配置部署层级。

<a id="configure-status-lifecycles-for-issues-and-tasks"></a>

### 为议题和任务配置状态生命周期

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/work_items/status.md#lifecycles) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/555528)

{{< /details >}}

此前，议题和任务必须共享同一组已配置的状态。在此版本中，我们添加了对配置状态生命周期的支持，使您能够为项目中的议题和任务定义不同的工作流。借助内置于工作流中的状态映射，您可以在更改工作项类型时无缝地将议题或任务转换到一组新状态，而无需批量编辑。

请通过[为 GitLab 的反馈议题做贡献](https://gitlab.com/gitlab-com/www-gitlab-com/-/issues/35235)分享您的反馈和用例及建议，帮助我们改进此功能。

<a id="format-markdown-tables-in-the-plain-text-editor"></a>

### 在纯文本编辑器中格式化 Markdown 表格

<!-- categories: Markdown -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md#tables)

{{< /details >}}

未对齐的 Markdown 表格难以阅读和编辑，即使它们能正确渲染。

纯文本编辑器工具栏中新增的**重新格式化表格**功能只需单击一下即可重新对齐表格列，同时保留对齐设置和缩进。要使用它：

- 在 Wiki 页面、议题或合并请求中选择任意 Markdown 表格。
- 从**更多选项**菜单中，选择**重新格式化表格**。

这使文档维护更快，在处理复杂表格时协作更轻松。

<a id="view-child-task-completion-in-issues"></a>

### 在议题中查看子任务完成情况

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/tasks.md#view-tasks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/520886)

{{< /details >}}

您现在可以直接从子项小组件跟踪议题的进度，让您一目了然地获得状态概览。此增强功能在工作已在进行中时提供对潜在瓶颈的实时可见性，帮助您快速识别有风险的项，并在冲刺截止日期受到威胁之前及时调整。

<a id="expose-original-severity-from-the-vulnerabilities-api"></a>

### 从漏洞 API 公开原始严重性

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/graphql/reference/_index.md#pipelinesecurityreportfinding) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/557940)

{{< /details >}}

漏洞 GraphQL API 现在会公开漏洞的原始严重性。这使您可以确定在应用严重性覆盖之前漏洞的严重性是什么。

<a id="time-windows-for-merge-request-approval-policies"></a>

### 合并请求审批策略的时间窗口

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#security_report_time_window) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/525509)

{{< /details >}}

为了在安全漏洞比较中提供更大的灵活性，我们在合并请求审批策略中引入了时间窗口。如果最近基线的安全报告尚不可用，此新策略配置允许您使用先前完成的安全报告，只要这些报告不早于您指定为时间窗口的时长。

开发团队现在可以避免在基线安全扫描卡住或耗时过长时出现不必要的延迟，例如在非常繁忙的项目中。通过配置时间窗口，未引入新漏洞的合并请求可以继续推进，而无需等待最新的流水线完成，从而提高工作流效率。

要使用此功能，请创建或编辑合并请求审批策略，并在审批策略配置中指定 `security_report_time_window` 参数（以分钟为单位）

系统将使用在指定时间窗口内创建的安全报告，将您合并请求的安全结果与最新流水线进行比较，从而在未引入新漏洞时实现更快的审批。

<a id="refreshed-security-finding-statuses-in-the-pipeline-security-tab"></a>

### 刷新了流水线**安全**标签页中的安全发现状态

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/detect/security_scanning_results.md#change-status) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/554078)

{{< /details >}}

此前，在流水线的**安全**标签页中，如果您忽略了一个漏洞，该漏洞不会立即从列表中移除。

流水线页面安全标签页中的状态更新现在会在更改后立即更新。

<a id="exceptions-to-bypass-merge-request-approval-policies"></a>

### 绕过合并请求审批策略的例外

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18114)

{{< /details >}}

组织现在可以指定特定用户、群组、角色或自定义角色，以便在发生关键情况时绕过合并请求审批策略。此能力为应急响应提供了灵活性，同时保持全面的审计事件记录和治理控制。

**带问责的紧急绕过**：指定用户可以在关键事件、安全热修复或紧急生产问题期间绕过审批要求。当紧急情况发生时，授权人员可以立即合并或推送更改，同时系统会捕获详细理由和审计信息以供合规审查。

关键能力包括：

- **有记录的绕过流程**：当授权用户调用策略绕过时，他们必须使用直观的模态界面提供详细理由，确保每个例外都带有上下文并被妥善记录。
- **全面的审计集成**：每次绕过都会生成详细的审计事件，包括用户身份、策略上下文、理由和时间戳，以便完整了解例外使用模式。
- **灵活的配置**：使用 YAML 或 UI 配置为策略定义例外权限，支持单个用户、极狐GitLab 群组、标准角色和自定义角色。
- **基于 Git 的推送例外**：拥有预先批准的策略例外的用户在调用推送绕过选项 `security_policy.bypass_reason` 时可以直接推送。

此功能消除了在紧急情况下完全禁用安全策略的需要，为紧急更改提供了受控路径，同时保留组织治理和审计要求。

<a id="show-only-active-vulnerabilities-in-the-dependency-list"></a>

### 在依赖列表中仅显示活跃漏洞

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md#vulnerabilities) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/353487)

{{< /details >}}

此前，依赖列表包含一些已忽略的漏洞。

为了向您提供依赖列表中漏洞更有用的呈现，项目依赖列表现在仅包含处于 `detected` 和 `confirmed` 状态的活跃漏洞。

<a id="static-reachability-in-limited-availability-and-experimental-java-support"></a>

### 限量提供的静态可达性以及实验性 Java 支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/static_reachability.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15780)

{{< /details >}}

在极狐GitLab 18.5 中，我们发布了静态可达性的限量提供支持。此版本侧重于改进 JS/TS 覆盖支持、修复缺陷，并为 Java 提供实验性支持。静态可达性通过扫描项目源代码来识别正在使用的开源依赖，从而丰富软件组成分析（SCA）结果。静态可达性产生的数据可作为用户分类和修复决策的一部分。静态可达性数据还可与 CVSS 和 EPSS 评分以及 KEV 指标一起使用，以提供对已识别漏洞更聚焦的视图。

我们欢迎对此功能提供反馈。如果您有问题、意见，或希望与我们的团队交流，请参阅此[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/535498)。

<a id="gitlab-runner-185"></a>

### 极狐GitLab Runner 18.5

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/) | [相关议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38976)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.5！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

缺陷修复：

- [将 runner operator 从 1.39 更新到 1.41 后，在原生 Kubernetes 上 Runner 更新失败](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/259)
- [某些容器标签具有重复的前缀](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38674)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-5-stable/CHANGELOG.md)中。
