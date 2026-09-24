---
stage: Release Notes
group: Monthly Release
date: 2025-11-20
title: "极狐GitLab 18.6 发布说明"
description: "极狐GitLab 18.6 released with The new 极狐GitLab UI: Designed for productivity"
---

2025 年 11 月 20 日，极狐GitLab 18.6 发布了以下功能。

<a id="the-new-gitlab-ui-designed-for-productivity"></a>

### 全新的极狐GitLab UI：为生产力而设计

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/interface_redesign.md)

{{< /details >}}

推出更智能、更直观的极狐GitLab UI，将开发者生产力放在首位。

全新的并排设计使用上下文面板让你保持在工作流中，减少不必要的点击，帮助团队更快速地工作。自定义你的工作区，最大化屏幕空间，享受更简洁、更动态的体验，适应你的工作流程。

极狐GitLab 致力于持续改进，因此请分享你的想法，帮助塑造极狐GitLab 的未来。

<a id="exact-code-search-in-limited-availability"></a>

### 精准代码搜索（有限可用）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/search/exact_code_search.md)

{{< /details >}}

随着此次发布，精准代码搜索现在处于有限可用状态。你可以使用精确匹配和正则表达式模式在整个实例、群组或项目中搜索代码。精准代码搜索基于开源搜索引擎 Zoekt 构建。

对于 JihuLab.com，精准代码搜索默认启用。对于极狐GitLab 私有化部署，管理员必须[安装 Zoekt](../../integration/zoekt/_index.md#install-zoekt) 并[启用精准代码搜索](../../integration/zoekt/_index.md#enable-exact-code-search)。

<a id="cicd-components-can-reference-their-own-metadata"></a>

### CI/CD 组件可以引用自身元数据

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../ci/yaml/expressions.md#component-context)

{{< /details >}}

以前，CI/CD 组件无法在其配置中引用自身的元数据，比如版本号或提交 SHA。这种信息缺失可能导致你使用包含硬编码值或复杂变通方法的配置。以这种方式编写配置可能导致组件在构建 Docker 镜像等资源时出现版本不匹配，因为没有方法自动使用组件兼容版本标记这些资源。

在本次发布中，我们引入了通过 `spec:component` 关键字访问组件上下文的功能。现在，你可以在发布组件版本时构建和发布版本化资源（如 Docker 镜像），确保一切保持同步，消除手动版本管理，并防止版本不匹配。

<a id="support-dynamic-job-dependencies-in-needsparallelmatrix"></a>

### 在 `needs:[parallel:matrix](../../ci/yaml.md#parallelmatrix)` 中支持动态作业依赖

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../ci/yaml/matrix_expressions.md#matrix-expressions-in-needsparallelmatrix)

{{< /details >}}

[`parallel:matrix`](../../ci/yaml/_index.md#parallelmatrix) 使得能够轻松并行运行具有不同需求的多个作业，例如同时为多个平台测试代码。但是，如果你希望后续作业使用 `needs:parallel:matrix` 来依赖特定的并行作业，配置会变得复杂且不够灵活。

现在，通过新引入的 `$[[matrix.VARIABLE]]` 表达式（作为 Beta 功能），用户可以创建动态的一对一依赖关系，这使得复杂的 `parallel:matrix` 配置更容易管理。这可以帮助你创建更快的流水线，实现高效的产物处理、更好的可扩展性和更清晰的配置。此功能对于多平台构建、跨多个环境的 Terraform 部署以及任何需要跨多个维度并行处理的工作流尤其有价值。

<a id="gitlab-security-analyst-agent-available-as-a-foundational-agent"></a>

### 极狐GitLab 安全分析师代理作为内置 Agent 可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [Documentation](../../user/duo_agent_platform/agents/foundational_agents/security_analyst_agent.md)

{{< /details >}}

极狐GitLab 安全分析师代理现已成为极狐GitLab Duo Agentic Chat 中的内置 Agent。这意味着用户无需从 AI 目录手动添加该代理，并且此代理默认可用于极狐GitLab 私有化部署。这个专门的助手提供 AI 原生的漏洞管理和安全分析，帮助你调查发现、分类漏洞以及满足合规要求，无需任何设置。

此功能处于 beta 阶段。

<a id="security-dashboard-upgrade-beta-on-gitlabcom"></a>

### 安全仪表板升级（在 JihuLab.com 上为 beta）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/security_dashboard/_index.md)

{{< /details >}}

新的安全仪表板已更新并现代化。beta 版本的初始功能包括：

- 漏洞随时间变化图表，支持：
  - 基于项目或报告类型过滤。
  - 按报告类型和严重程度分组。
  - 直接链接到漏洞报告中的漏洞。
- 一个风险评分模块，基于极狐GitLab 算法计算群组或项目的预估风险。

在 18.6 中发布的新安全仪表板目前仅在 JihuLab.com 上可用。

## Agentic 核心

<a id="gitlab-mcp-server-available-in-beta"></a>

### 极狐GitLab MCP 服务器在 [beta](../../policy/development_stages_support.md#beta) 中可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [Documentation](../../user/gitlab_duo/model_context_protocol/mcp_server.md)

{{< /details >}}

极狐GitLab MCP 服务器在 [beta](../../policy/development_stages_support.md#beta) 中可用。借助极狐GitLab MCP 服务器，你可以使用 AI 助手以及其他 MCP 兼容的工具来与你的极狐GitLab 项目、议题、合并请求和流水线互动，而无需为每个工具构建自定义集成。

要开始使用，请在极狐GitLab Duo 设置中[开启 beta 和实验性功能](../../user/gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)。

极狐GitLab MCP 服务器提供了涵盖议题、合并请求和流水线的关键工具，我们将根据用户反馈继续完善它。

<a id="advanced-search-available-for-both-issue-descriptions-and-comments"></a>

### 议题描述和评论均支持高级搜索

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/search/advanced_search.md)

{{< /details >}}

高级搜索现在从议题描述和评论中返回匹配结果。以前，用户必须分别搜索议题描述和评论。这一改进为极狐GitLab 议题提供了更流畅、更全面的搜索工作流。

<a id="gemini-25-flash-model-compatible-with-gitlab-duo-agent-platform-for-gitlab-duo-self-hosted"></a>

### 国内 SOTA 大模型兼容极狐GitLab Duo Agent Platform，用于 [GitLab Duo Self-Hosted](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models)

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Add-ons: Duo Enterprise
- Links: [Documentation](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models)

{{< /details >}}

你现在可以在极狐GitLab Duo Agent Platform 上，与 GitLab Duo Self-Hosted 一起使用国内 SOTA 大模型。

## 扩展与部署

<a id="rate-limit-for-listing-project-and-group-members"></a>

### 对列出项目和群组成员添加速率限制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../administration/settings/rate_limit_on_projects_api.md#configure-rate-limits-on-listing-project-members)

{{< /details >}}

我们对 `/api/v4/projects/:id/members/all` 和 `/api/v4/groups/:id/members/all` 端点引入了速率限制，以提高 API 稳定性并确保所有用户的公平资源使用。`GET /api/v4/projects/:id/members/all` 和 `GET /api/v4/groups/:id/members/all` 端点现在每个用户每分钟的请求限制为 200 次。

这一变更有助于保护极狐GitLab 实例免受可能影响所有用户性能的过度 API 使用。每分钟 200 次请求的限制为正常使用模式提供了充足的容量，同时防止潜在的滥用或意外资源耗尽。如果你的集成或脚本使用此端点，请确保它们适当地处理速率限制响应（HTTP 429），并根据需要实现带退避的重试逻辑。在正常使用模式下，大多数用户不应受到影响。

## 统一 DevOps 与安全

<a id="increased-rule-coverage-for-secret-push-protection-and-pipeline-secret-detection"></a>

### 增强了密钥推送保护和流水线密钥检测的规则覆盖

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/secret_detection/detected_secrets.md)

{{< /details >}}

我们为极狐GitLab 的流水线密钥检测添加了对 40 条新规则的支持。一些现有规则也进行了更新，以提高质量并减少误报。这些变更已在密钥分析器的[版本 7.20.1](https://jihulab.com/gitlab-cn/security-products/analyzers/secrets/-/releases/v7.20.1) 中发布。

<a id="code-owners-now-supports-inherited-group-memberships"></a>

### 代码所有者现在支持继承的群组成员资格

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/project/codeowners/advanced.md#group-inheritance-and-eligibility)

{{< /details >}}

代码所有权对于维护代码质量和确保合适的人审查代码库敏感部分的更改至关重要。然而，在具有复杂群组结构的组织中管理代码所有者一直具有挑战性。以前，要在你的 `CODEOWNERS` 文件中引用一个群组，该群组必须被直接邀请到每个特定项目，即使它已经是父群组的成员。

代码所有者现在支持具有继承成员资格的群组作为合格的审批者：

- 当启用代码所有者审批时，通过父群组成员资格获得继承访问权限的群组会被识别为有效的代码所有者。
- 无需将群组直接邀请到每个项目。
- 现有的 `CODEOWNERS` 文件无需更改即可继续使用。
- 对谁可以批准关键代码路径变更保持相同级别的控制。

这一变更减少了管理开销，同时保持了代码所有者提供的安全性和审批要求。

<a id="toggle-draft-merge-request-visibility-on-your-homepage"></a>

### 在主页上切换草稿合并请求的可见性

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/project/merge_requests/homepage.md#set-your-display-preferences)

{{< /details >}}

在你的主页上，草稿合并请求可能会使你的合并请求视图变得杂乱，并分散你对已就绪工作的注意力。以前，你无法将其过滤掉。

现在，你可以通过显示偏好设置，在主页的**你的合并请求**部分隐藏草稿合并请求。当你隐藏草稿合并请求时：

- 它们会被排除在活跃计数之外。
- 页脚会显示已过滤的草稿合并请求数量。
- 你的偏好会被自动保存。

这一变更帮助你专注于需要立即关注的合并请求。

<a id="new-gitlab-cli-features-and-improvements"></a>

### 新的极狐GitLab CLI 功能和改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](https://gitlab.cn/docs/cli/)

{{< /details >}}

极狐GitLab CLI（glab）提供了新的功能和改进，以增强你从命令行进行的极狐GitLab 工作流：

- **增强的认证**：登录时自动从 git 远程推断极狐GitLab URL，更容易对正确的极狐GitLab 实例进行认证。
- **灵活的流水线监控**：使用 `ci-view` 命令通过 ID 查看任何流水线。
- **GPG 密钥管理**：使用新命令直接从 CLI 管理 GPG 密钥。
- **项目成员管理**：从命令行添加、移除和更新项目成员。
- **改进的 Git 集成**：增强的 git-credential 插件，支持所有 token 类型。
- **现代化的用户界面**：更新了提示库，提供更好的确认对话框，并在 UI 组件间保持一致的极狐GitLab 主题。

有关更改和更新的完整列表，请参阅 [CLI 发布说明](https://jihulab.com/gitlab-cn/cli/-/releases)。要开始使用极狐GitLab CLI 或更新到最新版本，请参阅[安装指南](https://jihulab.com/gitlab-cn/cli/#installation)。

<a id="webhook-notifications-for-merge-request-review-re-requests"></a>

### 针对合并请求复审请求的 Webhook 通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/project/integrations/webhook_events.md#re-request-review-events)

{{< /details >}}

Webhook 集成对于自动化工作流以及保持外部系统与极狐GitLab 合并请求活动同步至关重要。但是，当为合并请求重新请求评审时，Webhook 消费者无法识别具体是哪个评审人被重新请求，这使得触发适当的通知或自动化变得困难。

合并请求的 Webhook 负载现在在评审人数据中包含一个 `re_requested` 属性，可清晰指示哪个评审人被重新请求：

- 对于被重新请求的特定评审人，设置为 `true`。
- 对于所有其他评审人，设置为 `false`。

这一改进使得能够围绕合并请求评审流程进行更精确的自动化。Webhook 消费者可以在复审被请求时发送针对性通知、更新外部跟踪系统并触发适当的工作流。

<a id="webhook-triggers-for-system-initiated-approval-resets"></a>

### 针对系统发起的审批重置的 Webhook 触发器

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/project/integrations/webhook_events.md#system-initiated-merge-request-events)

{{< /details >}}

通过 Webhook 将极狐GitLab 与外部系统集成，对于自动化工作流以及让团队了解合并请求状态变更至关重要。然而，当极狐GitLab 自动重置审批时（例如当新的提交被推送到启用了“推送时重置审批”的合并请求时），外部系统无法将这些系统发起的事件与手动用户操作区分开来。

极狐GitLab 现在包含增强的 Webhook 负载，可清晰标识系统发起的审批重置。当审批被自动重置时，Webhook 现在包含：

- 一个 `system` 字段，设置为 `true`。
- 一个 `system_action` 字段，提供关于重置原因的具体上下文，例如 `approvals_reset_on_push` 或 `code_owner_approvals_reset_on_push`。

这意味着你的 Webhook 集成现在可以区分手动审批变更和自动系统重置，从而启用能够对每个审批变更的特定上下文做出适当响应的更复杂的自动化工作流。

<a id="gitlab-duo-planner-agent-now-available-by-default"></a>

### 极狐GitLab Duo 计划者代理现在默认可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [Documentation](../../user/duo_agent_platform/agents/foundational_agents/planner.md)

{{< /details >}}

极狐GitLab Duo 计划者代理现在默认出现在极狐GitLab Duo Chat 的代理下拉列表中，无需再从 AI 目录手动添加。凭借对你的工作项、史诗、议题和任务的完整上下文了解，计划者代理现在可以在群组和项目级别为你提供帮助。

开始使用[**[示例提示](../../user/duo_agent_platform/agents/foundational_agents/planner.md#example-prompts)**](../../user/duo_agent_platform/agents/foundational_agents/planner.md#example-prompts)，了解计划者代理如何帮助你分解复杂工作、创建实施计划以及组织团队的目标。

此功能处于 beta 阶段。

<a id="helm-chart-registry-no-more-1000-chart-limit"></a>

### Helm 图表仓库：不再有 1,000 个图表限制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/packages/helm_repository/_index.md)

{{< /details >}}

极狐GitLab 的 Helm 图表仓库以前会即时生成元数据响应，当仓库包含大量图表时，这会产生性能瓶颈。为了维护系统稳定性，我们强制执行了仅包含最近 1,000 个图表的硬性限制。当平台团队尝试访问较旧的图表版本时，此限制会导致令人沮丧的 404 错误。

平台工程师被迫实施复杂的变通方法，例如跨多个仓库拆分图表、手动管理图表保留策略或维护单独的图表存储解决方案。这些变通方法增加了运营开销，并使部署工作流碎片化，使得维护集中式图表治理更加困难。

在极狐GitLab 18.6 中，我们通过预计算元数据响应并将其存储在对象存储中，消除了 1,000 个图表的限制。这一架构变更同时提供了无限的图表访问权限和改进的性能，因为元数据在后台任务中生成一次，而不是在每次请求时生成。

<a id="warn-mode-in-merge-request-approval-policies-beta"></a>

### 合并请求审批策略中的警告模式（Beta）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [Documentation](../../user/application_security/policies/merge_request_approval_policies.md#warn-mode)

{{< /details >}}

安全团队现在可以使用警告模式在应用强制执行之前测试和验证安全策略的影响，从而减少安全策略推行期间给开发者带来的摩擦。

当你创建或编辑一个[合并请求审批策略](../../user/application_security/policies/merge_request_approval_policies.md)时，现在可以在 `warn` 或 `enforce` 强制执行选项之间进行选择。

处于警告模式的策略会生成信息性机器人评论，而不会阻止合并请求。可以指定可选审批者作为策略问题的联系人。这种方法使安全团队能够评估策略影响，并通过透明、渐进式的策略采用来建立开发者信任。

合并请求中的明确指示器会告知用户策略何时处于 `warn` 或 `enforce` 模式，并且审计事件会跟踪策略违规和驳回情况以进行合规报告。开发者可以驳回漏洞，同时提供驳回理由，从而形成协作式的安全策略管理方法。

<a id="security-attributes-beta"></a>

### 安全属性（Beta）

{{< details >}}
- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/attributes/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19597)

{{< /details >}}

安全团队现在可以通过安全属性将业务上下文应用到项目中。

安全属性按类别组织，包括业务影响（带有结构化的预定义选项）、应用、业务单元、互联网暴露情况以及位置。或者，你也可以创建自己的属性类别，并在这些类别中定义标签。

通过在整个项目中应用这些属性，你可以更快速地搜索、筛选和识别安全清单中那些需要根据风险态势和组织上下文采取行动的项目。你现在可以：

- 识别出关键任务且需要更好扫描覆盖的项目
- 按应用或业务单元审查扫描覆盖情况
- 基于应用到项目的属性进行搜索和筛选
- 快速定位构成可公开访问/暴露的应用的项目

<a id="exceptions-to-bypass-merge-request-approval-policies"></a>

### 绕过合并请求批准策略的例外

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18114)

{{< /details >}}

组织现在可以指定能够绕过合并请求批准策略的特定用户、群组、角色或自定义角色，以应对紧急情况。此功能为应急响应提供了灵活性，同时保持了完善的审计跟踪和治理控制。

**具有问责制的紧急绕过**：指定用户在关键事件、安全热修复或紧急生产问题期间可以绕过批准要求。当紧急情况发生时，经授权的人员可以立即合并或推送变更，同时系统会捕获详细的理由和审计信息以供合规审查。

**关键能力包括：**

- **文档化的绕过流程**：当授权用户调用策略绕过时，他们必须使用直观的模态界面提供详细理由，确保每个例外都得到适当的上下文记录。
- **全面的审计集成**：每次绕过都会生成详细的审计事件，包括用户身份、策略上下文、理由和时间戳，以便全面了解例外使用模式。
- **灵活的配置**：使用 YAML 或 UI 配置为策略定义例外权限，支持个人用户、极狐GitLab 群组、标准角色和自定义角色。
- **基于 Git 的推送例外**：具有预先批准策略例外的用户可以在调用推送绕过选项 `security_policy.bypass_reason` 时直接推送。

此功能消除了在紧急情况下完全禁用安全策略的需要，为紧急变更提供了一条受控的路径，同时保留了组织治理和审计要求。

<a id="designate-an-account-succession-beneficiary"></a>

### 指定账户继承受益人

{{< details >}}

- Tier: 基础版，白银版，黄金版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/account/account_succession.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/330669)

{{< /details >}}

现在，你可以指定一位账户受益人，在你失去行为能力或无法联系时，该受益人有权管理你的极狐GitLab 账户。要访问你的账户，受益人必须提供适当的法律文件。此功能有助于确保你工作和项目的连续性，同时防止未经授权的访问。

<a id="group-owners-can-update-primary-emails-for-enterprise-users"></a>

### 群组所有者可以为企业用户更新主邮箱

{{< details >}}

- Tier: 白银版，黄金版
- Offering: JihuLab.com
- Links: [文档](../../user/enterprise_user/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425837)

{{< /details >}}

群组所有者现在可以更新其群组内企业用户的主邮箱地址。更新可通过 Users API 完成。此前，每个企业用户都必须手动更新自己的邮箱地址。此变更使得大规模管理企业用户变得更加容易。

<a id="gitlab-runner-186"></a>

### 极狐GitLab Runner 18.6

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.6！极狐GitLab Runner 是高度可扩展的构建代理，负责运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 内置的开源持续集成服务。

#### 新增功能

- [实现最小化作业确认 API](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39013)

#### 缺陷修复

- [极狐GitLab Runner 不展开 Docker 镜像平台选项中的变量](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38488)
- [辅助 sidecar 容器未能将缓存上传到另一个账户的 S3 存储桶](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37879)
- [自动取消的作业继续执行并失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37878)
- [生成的 PowerShell 脚本中缺少 UTF8 BOM，允许使用带有字符 Ä 的合并请求标题进行远程代码执行](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36060)
- [使用 Kubernetes 执行器时出现间歇性 Kubernetes API 服务器请求失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30109)
- [使用 Kubernetes 执行器时，带有较大提交信息的作业失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/26624)

所有变更的列表位于极狐GitLab Runner 的[更新日志](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-6-stable/CHANGELOG.md)中。