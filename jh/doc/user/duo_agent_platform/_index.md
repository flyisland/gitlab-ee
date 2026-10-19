---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 探索 AI 驱动的 Agent 和任务流，自动执行软件开发生命周期中的各项任务。
title: 极狐GitLab Duo Agent Platform
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- LLM: DeepSeek-V4-Pro-0813
- 适用于[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

极狐GitLab Duo Agent Platform 是一种 AI 原生解决方案，在软件开发生命周期中
嵌入了多个智能助手（“Agent”）。

- 无需遵循线性工作流，而是与 AI Agent 异步协作。
- 将日常任务（从代码重构、安全扫描到调研）委派给专门的 AI Agent。

要开始使用，请参阅
[极狐GitLab Duo Agent Platform 入门](../get_started/get_started_agent_platform.md)。

<a id="prerequisites"></a>

## 先决条件

要使用 Agent Platform：

- 已[开启极狐GitLab Duo](turn_on_off.md#turn-gitlab-duo-on-or-off)。
- 如果您没有极狐GitLab Duo Pro 或 Enterprise，
  请为顶级群组或实例[开启极狐GitLab Duo Core](turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- 在极狐GitLab 18.9 及更早版本中，您无法将 Agent Platform 与极狐GitLab Duo Enterprise 附加组件一起使用。
  要将 Agent Platform 与极狐GitLab Duo Enterprise 一起使用，请升级到极狐GitLab 18.10 或更高版本。
- 根据您的极狐GitLab 版本：
  - 在极狐GitLab 18.8 及更高版本中，已[开启 Agent Platform](turn_on_off.md#turn-gitlab-duo-agent-platform-on-or-off)。
  - 在极狐GitLab 18.7 及更早版本中，已[开启测试版和实验性功能](turn_on_off.md#turn-on-beta-and-experimental-features)。
- 对于极狐GitLab 私有化部署，请[配置您的实例](../../administration/gitlab_duo/configure/_index.md)。
- 对于极狐GitLab Duo 自部署版本，请[安装带有 Agent Platform 服务的 AI 网关](../../install/install_ai_gateway.md)。

要在本地环境中使用 Agent Platform：

- 安装编辑器扩展并使用极狐GitLab 进行身份验证。
- 在[群组命名空间](../namespace/_index.md)中拥有一个项目。
- 拥有开发者、维护者或所有者角色。

<a id="generally-available-features"></a>

## 正式发布的功能

这些功能已正式发布，使用时将消耗[极狐GitLab Credits](../../subscriptions/gitlab_credits.md)。

基础版中可用的功能需要购买[极狐GitLab Credits](../../subscriptions/gitlab_credits.md#for-the-free-tier)。

| 功能 | 基础版 | 专业版 | 旗舰版 |
|---------|---------|---------|---------|
| [Agentic Chat](../gitlab_duo_chat/agentic_chat.md) <br /> 回答复杂问题，并自主创建和编辑文件。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [代码建议](code_suggestions/_index.md) <br /> 在编写代码时获取 AI 驱动的建议。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [自定义 Agent](agents/custom.md) <br /> 针对您独特的开发需求构建团队专属 Agent。 | {{< yes >}} |  {{< yes >}}  | {{< yes >}} |
| [外部 Agent](agents/external.md) <br /> 安全地连接第三方集成和工具，以扩展 Agent Platform 的能力。 | {{< no >}} |  {{< yes >}}  | {{< yes >}} |
| [计划者 Agent](agents/foundational_agents/planner.md) <br /> 规划、排定优先级并跟踪工作。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [数据分析师 Agent](agents/foundational_agents/data_analyst.md) <br /> 分析数据，并从您的开发指标和项目数据中生成洞察。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [开发者任务流](flows/foundational_flows/developer.md) <br /> 将议题转换为合并请求。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [代码评审任务流](flows/foundational_flows/code_review/_index.md) <br /> 自动执行代码评审任务，并在整个团队中强制执行编码标准。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [Convert to GitLab CI/CD Flow](flows/foundational_flows/convert_to_gitlab_ci.md) <br /> 将旧版 CI/CD 流水线转换为极狐GitLab CI/CD 格式。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [Fix CI/CD Pipeline Flow](flows/foundational_flows/fix_pipeline.md) <br /> 诊断并自动修复失败的 CI/CD 流水线。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [软件开发任务流](flows/foundational_flows/software_development.md) <br /> 在执行之前创建完整的多步骤计划。 | {{< yes >}} | {{< yes >}}  | {{< yes >}} |
| [MCP 客户端](../gitlab_duo/model_context_protocol/mcp_clients.md) <br /> 从任何兼容 MCP 的 AI 客户端或 IDE 扩展访问极狐GitLab 资源和工具。 <sup>1</sup> | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [自定义任务流](flows/custom.md) <br /> 组合多个 Agent 来解决您的业务问题。 | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [合并请求中的交互](../project/merge_requests/duo_in_merge_requests.md#interact-with-gitlab-duo) <br /> 在合并请求评论讨论串中提问并讨论反馈。 | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [解决合并冲突](../project/merge_requests/conflicts.md#resolve-conflicts-with-gitlab-duo) <br /> 自主分析合并冲突、编辑冲突文件并推送解决提交。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [任务流创建器 Agent](agents/foundational_agents/flow_creator.md) <br /> 为 AI 目录创建自定义任务流。 | {{< no >}} | {{< yes >}}  | {{< yes >}} |
| [解决评审讨论](../project/merge_requests/duo_in_merge_requests.md#resolve-a-discussion-with-gitlab-duo) <br /> 自主分析评审讨论、推送所请求的更改并解决该讨论串。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [SAST 误报检测任务流](../application_security/vulnerabilities/false_positive_detection.md) <br /> 自动识别并过滤 SAST 安全扫描中的误报。 | {{< no >}} | {{< no >}}  | {{< yes >}} |
| [SAST 漏洞解决任务流](flows/foundational_flows/agentic_sast_vulnerability_resolution.md) <br /> 自动为 SAST 漏洞生成修复和补救步骤。 | {{< no >}} | {{< no >}}  | {{< yes >}} |
| [密钥误报检测任务流](flows/foundational_flows/secret_false_positive_detection.md) <br /> 自动识别并过滤密钥检测结果中的误报。 | {{< no >}} | {{< no >}}  | {{< yes >}} |
| [权限助手](agents/foundational_agents/permissions_assistant.md) <br /> 在创建细粒度个人访问令牌时选择正确的权限。 | {{< no >}} | {{< no >}}  | {{< yes >}} |
| [安全分析师 Agent](agents/foundational_agents/security_analyst_agent.md) <br /> 自动执行重复性安全任务：排查议题、分析漏洞并生成修复。 | {{< no >}} | {{< no >}}  | {{< yes >}} |

**脚注**：

1. MCP 客户端不会直接消耗 Credits。但是，任何 Agent Platform 的使用（例如通过 MCP 客户端发起的模型请求）都可能消耗 Credits。

<a id="beta-features-that-consume-credits"></a>

## 消耗 Credits 的测试版功能

这些功能处于测试版阶段，其使用会消耗极狐GitLab Credits。

| 功能 | 基础版 | 专业版 | 旗舰版 |
|---------|---|---|---|
| [安全审查任务流](flows/foundational_flows/security_review.md) <br /> 检测合并请求中的业务逻辑漏洞。 | {{< no >}} | {{< no >}} | {{< yes >}} |

<a id="beta-and-experimental-features-that-dont-consume-credits"></a>

## 不消耗 Credits 的测试版和实验性功能

这些功能处于测试版或实验性阶段，不会消耗极狐GitLab Credits。

对于[基础版用户](../../subscriptions/gitlab_credits.md#for-the-free-tier)，这些测试版和实验性功能不会消耗 Credits，
但您需要在月度承诺池中拥有 Credits 才能访问它们。

> [!warning]
> 当某项功能正式发布后，在所有极狐GitLab 版本和所有交付方式上使用该功能都将开始消耗极狐GitLab Credits。
> 不消耗 Credits 的测试版功能可能随时转为正式发布并按用量计费。

| 功能 | 基础版 | 专业版 | 旗舰版 |
|---------|---|---|---|
| [Agent 工具治理](../ai-governance/tool-governance.md) <br /> 配置工具级审批策略，在执行时通过人工审批来管控敏感的 Agent 操作。 | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [AI 审计事件报告](../ai-governance/ai-audit-events.md) <br /> 出于合规和治理目的，浏览并筛选极狐GitLab Duo Agent 活动的统一记录。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [AI 治理仪表板](../ai-governance/governance-dashboard.md) <br /> 监控群组内的 AI Agent 会话、审计日志和开发者暴露情况。 | {{< no >}} | {{< no >}} | {{< yes >}} |
| [CI 专家 Agent](agents/foundational_agents/ci_expert_agent.md) <br /> 创建、调试并优化极狐GitLab CI/CD 流水线。 | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [外部 MCP 服务器](../gitlab_duo/model_context_protocol/ai_catalog_mcp_servers.md) <br /> 使用 MCP 服务器将自定义 Agent 连接到外部数据源和第三方服务。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [Agentic 破坏性变更解决任务流](flows/foundational_flows/agentic-breaking-change-resolution.md) <br /> 分析依赖升级合并请求中的流水线失败，并创建代码修复以解决依赖更新引入的破坏性变更。 | {{< no >}} | {{< no >}} | {{< yes >}} |
| [支持助手](agents/foundational_agents/support_assistant.md) <br /> 诊断并解决极狐GitLab 产品问题。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [Recommend Reviewers Flow](../project/merge_requests/reviews/automatic_reviewer_assignment.md#assign-reviewers-with-the-recommend-reviewers-flow) <br /> 推荐并指派最适合审核合并请求的审核人。 | {{< no >}} | {{< yes >}} | {{< yes >}} |
