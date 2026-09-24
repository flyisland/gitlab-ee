---
stage: 发布说明
group: 月度发布
date: 2025-10-16
title: "极狐GitLab 18.5 发布说明"
description: "GitLab 18.5 released with GitLab Duo Planner, a specialized agent and Product Manager team member (beta)"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 10 月 16 日，极狐GitLab 18.5 版本正式发布，带来了以下新功能。

此外，我们要感谢所有贡献者，包括本月的重大贡献者。

## 本月重大贡献者：Jose Gabriel Companioni Benitez

在他的博客文章[《极狐GitLab 如何助力你的职业生涯》](https://compacompila.com/posts/gitlab-open-source-community/)中，
Jose 分享道：“对我而言，从职业发展的角度来看，极狐GitLab 的主要优势在于它是开源的。”他补充说，“对于极狐GitLab 而言，
能够让任何人都能做出贡献非常重要，因此，他们非常认真地对待贡献者的入门引导过程。”

Jose 从 9 月的首次贡献者，到 10 月成为重大贡献者的旅程，充分展现了极狐GitLab 协作社区的力量。
通过积极参与社区线上答疑、Discord 讨论和结对编程，
Jose 找到了一个支持性环境，帮助他迅速成长为一名三级贡献者，贡献涵盖[文档](https://jihulab.com/gitlab-cn/cli/-/merge_requests/2392)、
[代码](https://jihulab.com/gitlab-cn/terraform-provider-gitlab/-/merge_requests/2690)和社区支持等多个方面。

极狐GitLab 社区提供了一个友好的空间，贡献者在这里互相支持、共同成长。
无论你是刚刚开启开源之旅，还是希望深化技能，我们的社区都将助你成功。

要了解更多关于贡献的信息，请查看[极狐GitLab 贡献者平台](https://contributors.gitlab.com/)。

谢谢你，Jose，感谢你的杰出工作！🚀

## 主要功能

### 极狐GitLab Duo Planner，一个专业的代理和产品经理团队成员（测试版）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [文档](../../user/duo_agent_platform/agents/foundational_agents/planner.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/576618)

{{< /details >}}

与极狐GitLab Duo Planner 协作，这是一个直接在极狐GitLab 中为产品经理提供支持而构建的极狐GitLab Duo Agent。
无需手动跟踪更新、确定工作优先级或汇总规划数据，极狐GitLab Duo Planner 可帮助你分析待办事项列表，
应用 RICE 或 MoSCoW 等框架，并提示真正需要你关注的事项。
它就像一个积极主动的队友，了解你的规划工作流程，并与你一起做出更好、更快的决策。
此功能目前为测试版。请在[议题 576622](https://jihulab.com/gitlab-cn/gitlab/-/issues/576622) 中提供反馈。

### 用于 Duo Agent Catalog 的极狐GitLab 安全分析师代理（测试版）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [文档](../../user/duo_agent_platform/agents/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19659)

{{< /details >}}

极狐GitLab Duo Agent Platform 中的代理可用于在极狐GitLab 内执行任务并回答复杂问题。
用户既可以创建自定义代理来完成特定任务（例如创建合并请求或审查代码），
也可以使用 AI Catalog 发现极狐GitLab 代理。

在极狐GitLab 18.5 中，我们发布了极狐GitLab 安全分析师代理的测试版功能，可在 AI Catalog 中使用。要在特定项目中使用极狐GitLab 安全分析师代理，请在极狐GitLab Duo Agentic Chat 中选择并启用该代理。该代理可以执行以下任务：

- 列出给定项目中的所有漏洞。
- 获取详细的漏洞信息，包括 CVE 数据和 EPSS 评分。
- 确认和关闭漏洞。
- 更新漏洞严重程度级别。
- 将漏洞状态恢复为 `detected`。
- 创建漏洞议题，或将漏洞关联至现有议题。

借助极狐GitLab 安全分析师代理，用户可以通过 AI 驱动的自动化和智能分析来执行繁琐的安全工作流，
使工程师能够专注于真正的威胁，而极狐GitLab 安全分析师代理则处理重复性的评估和文档工作。请注意，使用极狐GitLab Duo Chat 的极狐GitLab 安全分析师代理仅供拥有极狐GitLab Duo 插件的旗舰版客户使用。

此功能为测试版，欢迎你在[议题 576916](https://jihulab.com/gitlab-cn/gitlab/-/issues/576916) 中提供反馈。

### Maven 虚拟仓库现进入测试阶段

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/packages/virtual_registry/maven/_index.md#manage-virtual-registries) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14137)

{{< /details >}}

极狐GitLab 18.5 为 Maven 虚拟仓库管理引入了全面的基于 Web 的界面。此前，平台工程师只能通过 API 调用来配置和管理虚拟仓库，
这使得日常维护任务繁琐且需要专业知识。

这种基于 Web 的方式显著降低了平台工程团队的操作开销。诸如清除过时缓存条目、重新排序上游以优化性能以及测试连通性等常见任务，
现在都变成了点击操作。开发团队可以更清晰地了解其依赖项配置，从而就构建性能和安全策略展开更明智的讨论。

Maven 虚拟仓库对于极狐GitLab 专业版和旗舰版客户来说仍为测试版。当前的测试版限制包括每个顶级群组最多 20 个虚拟仓库，以及每个虚拟仓库最多 20 个上游。

我们邀请企业客户参与 Maven 虚拟仓库测试计划，共同完善最终版本。请考虑在[议题 543045](https://jihulab.com/gitlab-cn/gitlab/-/issues/543045) 中分享反馈和建议。

### 在新的个人主页上从上次中断的地方继续

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../tutorials/personal_homepage/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16657)

{{< /details >}}

你现在可以访问一个新的个人主页，该主页将你所有重要的极狐GitLab 活动整合到一处，让你更容易从上次中断的地方继续工作。
该主页汇集了你的待办事项、已分配的议题、合并请求、审查请求以及最近查看的内容，
帮助你驾驭极狐GitLab 的庞大功能界面，并专注于对你最重要的事情。

### 国内 SOTA 大模型现可作为极狐GitLab Duo Agentic Chat 的模型选项

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/agentic_chat.md#select-a-model) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19124)

{{< /details >}}

国内 SOTA 大模型现可作为极狐GitLab AI Vendor 模型，在为极狐GitLab Duo Agent Platform 选择模型时使用。当 JihuLab.com 上顶级群组的所有者以及私有化部署实例的管理员完成配置后，最终用户可以选择使用国内 SOTA 大模型来使用极狐GitLab Duo 功能。顶级群组所有者和管理员可以继续通过命名空间或实例设置来设定全组织范围的模型偏好，或允许最终用户从所有可用的极狐GitLab AI Vendor 模型中进行选择。

要开始使用国内 SOTA 大模型，请从极狐GitLab Duo Chat 的模型下拉列表中选择你偏好的模型。

### 实例级合规与安全策略管理

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署
- Links: [文档](../../security/compliance_security_policy_management.md)

{{< /details >}}

企业用户希望跨多个顶级群组管理其[合规框架](../../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)和[安全策略](../../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md)。
当实例中的所有群组满足以下情况时，通常会出现这种需求：

- 共享相同的合规框架。例如，当群组中的所有项目都必须遵循 ISO 27001 标准时。
- 实施类似的安全策略。例如，当所有群组共享相同的流水线执行策略时。

在极狐GitLab 18.5 中，我们引入了合规与安全策略群组，以便在私有化部署实例上集中管理安全策略和合规框架。通过此版本，你现在可以从单个顶级群组创建、配置和分配合规框架和安全策略，并将其强制执行到实例中所有其他顶级群组。

有了合规与安全策略群组，你就有了一个单一的真实来源，可以在此管理和编辑你的合规框架和安全策略。群组内的安全与合规用户可以随后将合规框架和安全策略应用到实例中的所有项目。

合规与安全策略群组使跨实例管理和执行合规与安全需求变得更加容易。但是，群组仍然保留创建自己的合规框架和安全策略的能力，以应对这些群组中可能出现的特定情况或工作流。

此功能适用于私有化部署客户。JihuLab.com 客户可以使用安全策略项目，在单个顶级群组或命名空间内集中管理框架和策略。

详细了解适用于[合规框架](../../user/compliance/compliance_frameworks/centralized_compliance_frameworks.md)和[安全策略](../../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md)的合规与安全策略群组。

### DAST 认证脚本

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/dast/browser/configuration/authentication_scripts.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17018)

{{< /details >}}

你现在可以在 CI/CD 配置中添加脚本，以实现 DAST 认证工作流的自动化。认证脚本支持自动化复杂的认证流程，包括对基于时间的一次性密码（OTP MFA）的支持。

这一增强功能帮助你的团队在保持关键安全控制的同时，进行彻底、自动化的安全扫描。通过支持真实的认证场景，脚本减少了摩擦，并确保了对生产软件进行准确的安全评估。

## Agentic Core

### 为 CLI 代理增加额外触发器

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Enterprise
- Links: [文档](../../user/duo_agent_platform/triggers/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/567787)

{{< /details >}}

你现在可以使用额外的事件来触发 CLI 代理，从而让你更灵活地控制代理在项目中采取行动的位置和时机。除了现有的 **提及** 触发器，你还可以使用：

- **分配**：在合并请求或议题被分配时触发代理。
- **分配审查人**：在审查人被添加到合并请求时触发代理。

### 自部署模型的 极狐GitLab Duo Agent Platform 现进入测试阶段

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/558083)

{{< /details >}}

自部署模型的 极狐GitLab Duo Agent Platform 现进入测试阶段。此功能对所有私有化部署的极狐GitLab Duo Enterprise 客户可用。私有化部署实例管理员可以配置

[兼容模型](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models)

以用于极狐GitLab Duo Agent Platform。

### 国内 SOTA 大模型现支持用于极狐GitLab Duo Chat（经典版）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/550266)

{{< /details >}}

你现在可以在极狐GitLab Duo 自托管上使用国内 SOTA 大模型进行经典版 Duo Chat。该模型支持极狐GitLab 私有化部署实例上的极狐GitLab Duo 自托管客户。

### 国内 SOTA 大模型与自部署模型的 极狐GitLab Duo Agent Platform 兼容

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19348)

{{< /details >}}

你现在可以在自部署模型的 极狐GitLab Duo Agent Platform 上使用国内 SOTA 大模型。

## 规模化部署

### 增强的 **管理员** 区域群组列表

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Links: [文档](../../administration/admin_area.md#administering-groups) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17783)

{{< /details >}}

我们升级了 **管理员** 区域的群组列表，为极狐GitLab 管理员提供更一致的体验：

- 延迟删除保护：群组删除现在遵循极狐GitLab 中的安全删除流程，防止意外数据丢失。
- 更快的交互：无需重新加载页面即可筛选、排序和分页群组，响应更迅速。
- 一致的界面：群组列表现在与极狐GitLab 中其他群组列表的外观和行为相匹配。

此更新使管理员体验与极狐GitLab 的设计标准保持一致，并增加了重要的安全功能以保护你的数据。未来对群组管理的增强将自动出现在平台的所有群组列表中。

### 更新的群组导航体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/group/_index.md#view-a-group) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13790)

{{< /details >}}

我们对群组概览列表进行了更改，以在极狐GitLab 中提供更一致、更高效的体验。
这些改进让你更容易导航你的群组和项目，同时一目了然地提供更有价值的信息：

- 更丰富的项目信息：项目现在显示星标、派生、议题、合并请求和相关日期，让你一览完整的活动总览。
- 简化的操作：使用操作菜单直接从概览中编辑或删除群组和项目。已归档和待删除的项目显示在 **未激活** 页签中。
- 一致的体验：群组概览现在与极狐GitLab 中其他群组和项目列表的外观和行为相匹配，带来更直观的体验。

这些增强功能将更多信息和操作置于你的指尖，节省了时间。此更新也为未来的批量编辑和高级筛选选项等功能奠定了基础。

### 改进的群组和项目未激活项管理

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/project/working_with_projects.md#view-inactive-projects) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/526211)

{{< /details >}}

**未激活** 页签现在在极狐GitLab 各处统一显示所有未激活项。这包括已归档项目、待删除项目和待删除群组。
此页签在群组概览页面以及 **您的工作**、**探索** 和 **管理员** 区域的群组和项目列表中均可使用。
所有具有适当权限的用户都可以查看未激活项，而只有群组所有者以及项目所有者和维护者可以对其采取进一步操作。
作为此更新的一部分，一个新的 `active` 参数现已在项目 REST API、群组 REST API 和 GraphQL API 中可用。

管理未激活内容是维护极狐GitLab 实例的关键部分。
此更新让你更容易找到并恢复已归档或待删除的内容，使你能够更好地控制极狐GitLab 资源，同时降低意外丢失有价值工作的风险。
活动内容与未激活内容的明确区分，也让你在极狐GitLab 的所有区域导航群组和项目时，获得更集中的搜索体验。

## 统一 DevOps 与安全

### 极狐GitLab Duo Agentic Chat 中的新漏洞管理功能

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/agentic_chat.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19639)

{{< /details >}}

极狐GitLab Duo Agentic Chat 是极狐GitLab Duo Chat 的增强版本。它搜索、
检索并组合来自极狐GitLab 项目中多个来源的信息，以提供更全面、更相关的答案。其部分用例包括
能够搜索项目、读取和列出文件，以及根据提供给极狐GitLab Duo Chat 的提示自主创建和更改
文件。

在极狐GitLab 18.5 中，Agentic Chat 的用例扩展到包括管理
来自安全扫描器的漏洞。通过向 Agentic Chat 添加漏洞管理工具，
这些工具通过 AI 驱动的自动化和智能分析，改变了繁琐的安全工作流，使安全专业人员能够通过自然语言命令高效地执行分类、管理和修复漏洞。
这消除了数小时手动点击漏洞仪表板的工作，并简化了以前需要自定义脚本或繁琐手动工作的复杂批量操作。

通过向极狐GitLab Duo Chat 添加新的漏洞管理工具，拥有极狐GitLab Duo 的旗舰版用户可以执行以下操作：

- 列出给定项目中的所有漏洞。
- 获取详细的漏洞信息，包括 CVE 数据和 EPSS 评分。
- 确认和关闭漏洞。
- 更新漏洞严重程度级别。
- 将漏洞状态恢复为 `detected`。
- 创建漏洞议题，或将漏洞关联至现有议题。

这些工具将安全工作流从被动的手动分类转变为智能修复，使工程师能够专注于真正的威胁，而 AI 则处理重复性的评估和文档工作。使用极狐GitLab Duo Chat 的漏洞管理仅供拥有极狐GitLab Duo 插件的旗舰版客户使用。

### C/C++ 高级 SAST 支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/sast/advanced_sast_cpp.md)

{{< /details >}}

我们已为极狐GitLab Advanced SAST 添加了对 C/C++ 的测试版支持。

要使用这种新的跨文件、跨函数扫描支持，请[启用 C/C++ 支持](../../user/application_security/sast/advanced_sast_cpp.md)。

我们欢迎对此功能提供反馈。如果你有任何问题、意见或希望与我们的团队交流，请参阅此[反馈议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/575671)。

### 密钥有效性检查现已进入测试版

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/vulnerabilities/validity_check.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16927)

{{< /details >}}

流水线密钥检测会提醒你项目中暴露的凭据，如密码或 API 密钥。然而，在极狐GitLab 18.5 之前，你必须手动检查每个检测到的凭据是否代表一个有效的令牌。这使得有效分类检测结果变得困难且耗时。

现在，有效性检查已进入测试版，启用它可以显示检测到的极狐GitLab 密钥的状态。有效的密钥可用于冒充合法活动，因此你应该尽快轮换它们。

### 增强了密钥推送保护和流水线密钥检测的规则覆盖

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/secret_detection/detected_secrets.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/573973)

{{< /details >}}

新的规则已添加到极狐GitLab 流水线密钥检测中。一些现有规则也已更新，以提高质量并减少误报。这些更改已在密钥分析器的[版本 7.15.0](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v7.15.0) 中发布。

### 高级 SAST 的自定义检测逻辑

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/sast/customize_rulesets.md)

{{< /details >}}

你现在可以使用极狐GitLab Advanced SAST，根据组织的特定安全需求和编码模式创建自定义安全检测规则。此功能使你的安全团队能够在预定义规则集之外定义自定义漏洞模式，从而检测特定于应用程序的安全问题。

欲了解更多信息，请参见[自定义规则集](../../user/application_security/sast/customize_rulesets.md)。

### 高级 SAST 在合并请求中基于差异的扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/sast/gitlab_advanced_sast.md#diff-based-scanning)

{{< /details >}}

你现在可以使用极狐GitLab Advanced SAST 执行基于差异的扫描，该扫描仅分析合并请求中的代码变更，与全仓库扫描相比，显著缩短了扫描时间。通过仅扫描 Git 差异而不是整个代码库，你的团队可以将安全测试更无缝地集成到开发工作流中，而不会牺牲速度或为合并请求流程增加摩擦。

我们正在努力默认启用此性能改进；相关工作在[议题 546359](https://jihulab.com/gitlab-cn/gitlab/-/issues/546359) 中进行跟踪。

### 控制外部控制状态请求

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/compliance/compliance_frameworks/_index.md#ping-enabled-setting) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/521757)

{{< /details >}}

在极狐GitLab 中创建合规框架时，外部控制可以附加到需求上。

默认情况下，极狐GitLab 在进行合规扫描时，每 12 小时自动向外部系统请求外部控制的状态，
并将控制状态设置为“待处理”。然后，外部系统通过使用外部控制 API 将状态更新为“通过”或“失败”来响应。

在极狐GitLab 18.5 中，你现在可以在配置外部控制时关闭 **启用 Ping** 设置，从而禁用这种自动的 12 小时 ping 操作。当 12 小时 ping 被禁用时：

- 极狐GitLab 不会自动向外部系统请求状态更新。
- 外部控制在合规框架 UI 中显示 **已禁用** 徽章。
- 你可以完全控制何时使用外部控制 API 更新外部控制状态。

这可以防止系统将外部控制状态重置为“待处理”，并使你完全掌控状态更新的时机。

### 依赖项扫描限时可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) | Related epic

{{< /details >}}

在极狐GitLab 18.5 中，我们发布了新的依赖项扫描模板，可与依赖项扫描分析器配合使用。
分析器现在生成包含所有组件漏洞的依赖项扫描报告。
扫描执行策略 (SEP) 和流水线执行策略 (PEP) 支持新模板。

要使用新模板，请导入 `Jobs/Dependency-Scanning.v2.gitlab-ci.yml`。

此功能在 JihuLab.com 和私有化部署实例上可用，但由于尚未正式支持私有化部署，因此标记为有限可用。
JihuLab.com 用户可立即使用。

欢迎对此功能提供反馈。如有问题或意见，欢迎与我们交流。

### 环境变量 `deployment_tier` 中的变量展开

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../ci/yaml/_index.md#environmentdeployment_tier) | Related issue

{{< /details >}}

现在您可以在 `environment:deployment_tier` 字段中使用 CI/CD 变量，从而更容易地根据流水线条件动态配置部署层级。

### 为议题和任务配置状态生命周期

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/work_items/status.md#lifecycles) | Related issue

{{< /details >}}

以前，议题和任务必须共享同一组已配置的状态。在此版本中，我们添加了对配置状态生命周期的支持，使您能够为项目中的议题和任务定义不同的工作流。通过工作流内置的状态映射，您可以在更改工作项类型时将议题或任务无缝转换到一组新状态，而无需批量编辑。

分享您的反馈并帮助我们改进该功能，欢迎提供您的使用案例和建议。

### 在纯文本编辑器中格式化 Markdown 表格

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/markdown.md#tables)

{{< /details >}}

未对齐的 Markdown 表格难以阅读和编辑，即使它们能正确渲染。

纯文本编辑器工具栏中的新 **重新格式化表格** 功能只需点击一下即可重新对齐表格列，并保留对齐设置和缩进。使用方法：

- 在 Wiki 页面、议题或合并请求中选择任意 Markdown 表格。
- 从 **更多选项** 菜单中，选择 **重新格式化表格**。

这使得在处理复杂表格时，文档维护更快，协作更轻松。

### 在议题中查看子任务完成情况

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/tasks.md#view-tasks) | Related issue

{{< /details >}}

现在您可以直接从子项小部件跟踪议题的进度，一目了然地查看状态概览。此增强功能可在工作正在进行时实时显示潜在瓶颈，帮助您快速识别有风险的项目，并在冲刺截止日期之前及时进行调整。

### 通过漏洞 API 公开原始严重性

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../api/graphql/reference/_index.md#pipelinesecurityreportfinding) | Related issue

{{< /details >}}

漏洞 GraphQL API 现在公开漏洞的原始严重性。
这允许您在应用严重性覆盖之前确定漏洞的严重性。

### 合并请求批准策略的时间窗口

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/policies/merge_request_approval_policies.md#security_report_time_window) | Related issue

{{< /details >}}

为了在安全漏洞比较中提供更大的灵活性，我们在合并请求批准策略中引入了时间窗口。如果最新基线的安全报告尚未可用，此新策略配置允许您使用之前完成的安全报告，只要报告的使用时间不超过您指定的时间窗口。

开发团队现在可以避免因基线安全扫描卡住或耗时过长（例如在非常繁忙的项目中）而导致的不必要延迟。通过配置时间窗口，未引入新漏洞的合并请求可以继续，而无需等待最新流水线完成，从而提高工作流效率。

要使用此功能，请创建或编辑合并请求批准策略，并在批准策略配置中指定 `security_report_time_window` 参数（以分钟为单位）。

系统将使用在指定时间窗口内创建的安全报告，将您的合并请求安全结果与最新流水线进行比较，以便在未引入新漏洞时更快地批准。

### 在流水线 **安全** 选项卡中刷新安全发现状态

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/detect/security_scanning_results.md#change-status) | Related issue

{{< /details >}}

以前，在流水线的 **安全** 选项卡中，如果您忽略了一个漏洞，该漏洞不会立即从列表中移除。

现在，流水线页面安全选项卡中的状态更新在更改后会立即更新。

### 绕过合并请求批准策略的例外情况

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/policies/merge_request_approval_policies.md) | Related epic

{{< /details >}}

组织现在可以指定特定用户、群组、角色或自定义角色，以便在紧急情况下绕过合并请求批准策略。此功能为紧急响应提供了灵活性，同时维护全面的审计跟踪和治理控制。

**带有问责机制的紧急绕过**: 指定的用户可以在关键事件、安全热修复或紧急生产问题期间绕过批准要求。当紧急情况发生时，授权人员可以立即合并或推送更改，同时系统会捕获详细的理由和审计信息以供合规审查。

主要功能包括：

- **记录的绕过过程**: 当授权用户调用策略绕过时，他们必须使用直观的模态界面提供详细理由，确保每个例外都带有上下文妥善记录。
- **全面的审计集成**: 每次绕过都会生成详细的审计事件，包括用户身份、策略上下文、理由和时间戳，以便完全洞察异常使用模式。
- **灵活的配置**: 使用 YAML 或 UI 配置为策略定义例外权限，支持个人用户、极狐GitLab 群组、标准角色和自定义角色。
- **基于 Git 的推送例外**: 具有预批准策略例外的用户可以在调用推送绕过选项 `security_policy.bypass_reason` 时直接推送。

此功能消除了在紧急情况下完全禁用安全策略的需要，为紧急更改提供了受控路径，同时保留了组织治理和审计要求。

### 在依赖项列表中仅显示活跃漏洞

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/dependency_list/_index.md#vulnerabilities) | Related issue

{{< /details >}}

以前，依赖项列表中包含一些已忽略的漏洞。

为了在依赖项列表中提供更有用的漏洞表示，项目依赖项列表现在仅包含处于 `detected` 和 `confirmed` 状态的活跃漏洞。

### 静态可达性处于有限可用状态及实验性的 Java 支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/dependency_scanning/static_reachability.md) | Related epic

{{< /details >}}

在极狐GitLab 18.5 中，我们发布了静态可达性的有限可用性支持。
此版本专注于改进 JS/TS 覆盖率支持、修复错误，并提供实验性的 Java 支持。
静态可达性通过扫描项目源代码来识别正在使用的开源依赖项，从而丰富软件成分分析 (SCA) 结果。
静态可达性产生的数据可作为用户分类和修复决策的一部分。静态可达性数据还可以与 CVSS 和 EPSS 评分以及 KEV 指标一起使用，以提供对已识别漏洞的更集中视图。

欢迎对此功能提供反馈。如有问题或意见，欢迎与我们交流。

### GitLab Runner 18.5

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](https://gitlab.cn/docs/runner) | Related issue

{{< /details >}}

我们今天还发布了 GitLab Runner 18.5！GitLab Runner 是高度可扩展的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 附带的开源持续集成服务。

错误修复：

- Runner 在将 runner operator 从 1.39 更新到 1.41 后在 vanilla Kubernetes 上更新失败
- 某些容器标签具有重复前缀

所有变更列表请参阅 GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/18-5-stable/CHANGELOG.md)。