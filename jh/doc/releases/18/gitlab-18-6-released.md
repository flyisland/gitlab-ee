---
stage: Release Notes
group: Monthly Release
date: 2025-11-20
title: "极狐GitLab 18.6 发布说明"
description: "极狐GitLab 18.6 发布，推出全新的极狐GitLab UI：为生产力而设计"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 11 月 20 日，极狐GitLab 18.6 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="the-new-gitlab-ui-designed-for-productivity"></a>

### 全新的极狐GitLab UI：为生产力而设计

<!-- categories: Design Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../tutorials/gitlab_navigation.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17279)

{{< /details >}}

推出更智能、更直观的极狐GitLab UI，将开发者生产力放在首位。

全新的并排设计使用上下文面板，让您始终处于工作流之中，减少不必要的点击，帮助团队更快地工作。您可以自定义工作区、最大化屏幕空间，并享受更简洁、更动态、能适应您工作流的体验。

极狐GitLab 致力于持续改进，因此请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/577554)中分享您的想法，帮助塑造极狐GitLab 的未来。

<a id="exact-code-search-in-limited-availability"></a>

### 精确代码搜索限量提供

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/exact_code_search.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17918)

{{< /details >}}

在此版本中，精确代码搜索现已限量提供。您可以使用精确匹配和正则表达式模式，在整个实例、群组或项目中搜索代码。精确代码搜索基于开源搜索引擎 Zoekt 构建。

对于 JihuLab.com，精确代码搜索默认启用。对于极狐GitLab 私有化部署，管理员必须[安装 Zoekt](../../integration/zoekt/_index.md#install-zoekt) 并[启用精确代码搜索](../../integration/zoekt/_index.md#enable-exact-code-search)。

此功能正在积极开发中。欢迎您在[议题 420920](https://gitlab.com/gitlab-org/gitlab/-/issues/420920)中提供反馈！

<a id="cicd-components-can-reference-their-own-metadata"></a>

### CI/CD 组件可以引用自身的元数据

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/expressions.md#component-context) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438275)

{{< /details >}}

此前，CI/CD 组件无法在其配置中引用自身的元数据，例如版本号或提交 SHA。缺少这些信息可能导致您使用硬编码值或复杂的变通方法来编写配置。以这种方式编写配置，在组件构建 Docker 镜像等资源时可能导致版本不匹配，因为无法自动使用组件的兼容版本为这些资源打标签。

在此版本中，我们引入了使用 `spec:component` 关键字访问组件上下文的能力。现在，您可以在发布组件版本时构建并发布带版本的资源（如 Docker 镜像），确保一切保持同步，消除手动版本管理，并防止版本不匹配。

<a id="support-dynamic-job-dependencies-in-needsparallelmatrix"></a>

### 在 `needs:[parallel:matrix](../../ci/yaml.md#parallelmatrix)`中支持动态作业依赖

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/matrix_expressions.md#matrix-expressions-in-needsparallelmatrix) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/423553)

{{< /details >}}

[`parallel:matrix`](../../ci/yaml/_index.md#parallelmatrix) 让您可以轻松地以不同需求并行运行多个作业，例如同时测试多个平台的代码。但如果您希望后续作业使用 `needs:parallel:matrix` 来依赖特定的并行作业，配置会变得复杂且不灵活。

现在，借助作为测试版功能引入的新 `$[[matrix.VARIABLE]]` 表达式，用户可以创建动态的一对一依赖关系，使复杂的 `parallel:matrix` 配置更易于管理。这可以帮助您创建更快的流水线，实现高效的产物处理、更好的可扩展性和更简洁的配置。此功能对于多平台构建、跨多个环境的 Terraform 部署，以及任何需要跨多个维度并行处理的工作流都特别有价值。

<a id="gitlab-security-analyst-agent-available-as-a-foundational-agent"></a>

### 极狐GitLab 安全分析师 Agent 作为内置 Agent 提供

<!-- categories: Vulnerability Management, Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/security_analyst_agent.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19659)

{{< /details >}}

极狐GitLab 安全分析师 Agent 现在是极狐GitLab Duo Agentic Chat 中的内置 Agent。这意味着用户无需从 AI 目录中手动添加 极狐GitLab 安全分析师 Agent，并且该 Agent 默认也可用于极狐GitLab 私有化部署。
这个专用助手提供 AI 原生的漏洞管理和安全分析，帮助您调查发现项、排查漏洞，并在无需任何设置的情况下满足合规要求。

此功能处于测试版，欢迎您在[议题 576916](https://gitlab.com/gitlab-org/gitlab/-/issues/576916)中提供反馈。

<a id="model-selection-for-gitlab-duo-agentic-chat-in-vs-code-and-jetbrains-ides"></a>

### VS Code 和 JetBrains IDE 中极狐GitLab Duo Agentic Chat 的模型选择

<!-- categories: Editor Extensions, Model Personalization -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/model_selection.md#select-a-model-for-a-feature) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19345)

{{< /details >}}

现在，您可以直接在极狐GitLab Duo Chat 中轻松选择您偏好的 AI 模型，该功能现已在 VS Code 和 JetBrains IDE 中提供。使用极狐GitLab Duo Chat 面板中的下拉列表，可在 Claude、GPT 和其他受支持的模型中进行选择。模型可用性由您所在组织的管理员管理，确保您可以访问适合您工作流的模型。

<a id="security-dashboard-upgrade-beta-on-gitlabcom"></a>

### 安全仪表板升级（JihuLab.com 上的测试版）

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/application_security/security_dashboard/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18509)

{{< /details >}}

新的安全仪表板已更新并实现现代化。测试版中的初始功能包括：

- 漏洞随时间变化图表，支持：
  - 按项目或报告类型筛选。
  - 按报告类型和严重性分组。
  - 直接链接到漏洞报告中的漏洞。
- 风险评分模块，基于极狐GitLab 算法计算群组或项目的预估风险。

18.6 中发布的新安全仪表板目前仅在 JihuLab.com 上提供。

<a id="agentic-core"></a>

## AI 功能

<a id="gitlab-mcp-server-available-in-beta"></a>

### 极狐GitLab MCP 服务器以[测试版](../../policy/development_stages_support.md#beta)提供

<!-- categories: MCP Server -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/model_context_protocol/mcp_server.md)

{{< /details >}}

极狐GitLab MCP 服务器以[测试版](../../policy/development_stages_support.md#beta)提供。借助极狐GitLab MCP 服务器，您可以使用 Claude Code、Cursor 等 AI 助手以及其他兼容 MCP 的工具，与您的极狐GitLab 项目、议题、合并请求和流水线交互，而无需为每个工具构建自定义集成。

要开始使用，请在您的极狐GitLab Duo 设置中[开启测试版和实验性功能](../../user/gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)。

极狐GitLab MCP 服务器提供涵盖议题、合并请求和流水线的关键工具，我们会根据用户反馈持续完善它。此功能可能存在功能不完整或缺陷。请试用并在[议题 561564](https://gitlab.com/gitlab-org/gitlab/-/issues/561564)中分享反馈。

<a id="advanced-search-available-for-both-issue-descriptions-and-comments"></a>

### 高级搜索现可同时搜索议题描述和评论

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/advanced_search.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513146)

{{< /details >}}

高级搜索现在会同时返回议题描述和评论中的匹配结果。此前，用户必须分别搜索议题描述和评论。此改进为极狐GitLab 议题提供了更精简、更全面的搜索工作流。

<a id="gemini-25-flash-model-compatible-with-gitlab-duo-agent-platform-for-gitlab-duo-self-hosted"></a>

### Gemini 2.5 Flash 模型兼容极狐GitLab Duo Agent Platform，适用于[极狐GitLab Duo 自部署版本](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models)

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/572353)

{{< /details >}}

现在，您可以在极狐GitLab Duo Agent Platform 上配合极狐GitLab Duo 自部署版本使用 Gemini 2.5 Flash 模型。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="rate-limit-for-listing-project-and-group-members"></a>

### 列出项目和群组成员的速率限制

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../rate_limits/api/projects.md#configure-rate-limits-on-listing-project-members) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/580116)

{{< /details >}}

我们为 `/api/v4/projects/:id/members/all` 和 `/api/v4/groups/:id/members/all` 端点引入了速率限制，以提高 API 稳定性并确保所有用户公平使用资源。`GET /api/v4/projects/:id/members/all` 和 `GET /api/v4/groups/:id/members/all` 端点现在对每个用户设有每分钟 200 次请求的速率限制。

此变更有助于保护极狐GitLab 实例免受可能影响所有用户性能的过度 API 使用。每分钟 200 次的限制为正常使用模式提供了充足容量，同时防止潜在的滥用或意外的资源耗尽。如果您的集成或脚本使用此端点，请确保它们妥善处理速率限制响应（HTTP 429），并根据需要实现带退避的重试逻辑。在正常使用模式下，大多数用户不会受此变更影响。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="increased-rule-coverage-for-secret-push-protection-and-pipeline-secret-detection"></a>

### 扩展了密钥推送保护和流水线密钥检测的规则覆盖范围

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/detected_secrets.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/576279)

{{< /details >}}

我们为极狐GitLab 的流水线密钥检测新增了 40 条规则的支持。部分现有规则也已更新，以提高质量并减少误报。这些变更已在密钥分析器的 [7.20.1 版本](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v7.20.1)中发布。

<a id="code-owners-now-supports-inherited-group-memberships"></a>

### 代码所有者现在支持继承的群组成员身份

<!-- categories: Code Review Workflow, Source Code Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/codeowners/advanced.md#group-inheritance-and-eligibility)

{{< /details >}}

代码所有权对于维护代码质量、确保由合适的人员评审代码库敏感部分的变更至关重要。然而，在群组结构复杂的组织中管理代码所有者一直颇具挑战。此前，要在 `CODEOWNERS` 文件中引用某个群组，该群组必须被直接邀请到每个特定项目，即使它已经是父群组的成员。

代码所有者现在支持具有继承成员身份的群组作为合格的审批人：

- 当启用代码所有者审批时，通过父群组成员身份获得继承访问权限的群组会被识别为有效的代码所有者。
- 无需将群组直接邀请到每个项目。
- 现有的 `CODEOWNERS` 文件无需更改即可继续工作。
- 对谁可以批准关键代码路径变更的控制级别保持不变。

此变更减少了管理开销，同时保持了代码所有者提供的安全性和审批要求。

<a id="toggle-draft-merge-request-visibility-on-your-homepage"></a>

### 在主页上切换草稿合并请求的可见性

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/homepage.md#set-your-display-preferences) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/551475)

{{< /details >}}

在您的主页上，草稿合并请求可能会使您的合并请求视图变得杂乱，并分散您对已准备好处理的工作的注意力。此前，您无法将它们筛选出去。

现在，您可以使用显示偏好设置，从主页的**您的合并请求**部分隐藏草稿合并请求。当您隐藏草稿合并请求时：

- 它们会从活动计数中排除。
- 页脚会显示已筛选的草稿合并请求数量。
- 您的偏好设置会自动保存。

此变更帮助您专注于需要立即关注的合并请求。

<a id="new-gitlab-cli-features-and-improvements"></a>

### 新的 GitLab CLI 功能和改进

<!-- categories: GitLab CLI -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/cli/) | [相关议题](https://gitlab.com/gitlab-org/cli/-/releases)

{{< /details >}}

GitLab CLI (glab) 提供了新功能和改进，以增强您从命令行使用极狐GitLab 的工作流：

- **增强的身份验证**：登录时从 git 远程自动检测极狐GitLab URL，使您更容易针对正确的极狐GitLab 实例进行身份验证。
- **灵活的流水线监控**：使用 `ci-view` 命令按 ID 查看任意流水线。
- **GPG 密钥管理**：使用新命令直接从 CLI 管理 GPG 密钥。
- **项目成员管理**：从命令行添加、移除和更新项目成员。
- **改进的 Git 集成**：增强的 git-credential 插件，支持所有令牌类型。
- **现代化的用户界面**：更新了提示库，提供更好的确认对话框，并在各 UI 组件中保持一致的极狐GitLab 主题。

有关变更和更新的完整列表，请参阅 [CLI 发布](https://gitlab.com/gitlab-org/cli/-/releases)。要开始使用 GitLab CLI 或更新到最新版本，请参阅[安装指南](https://jihulab.com/gitlab-cn/cli#installation)。

<a id="webhook-notifications-for-merge-request-review-re-requests"></a>

### 合并请求重新请求评审的 Webhook 通知

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhook_events.md#re-request-review-events)

{{< /details >}}

Webhook 集成对于自动化工作流以及让外部系统与极狐GitLab 合并请求活动保持同步至关重要。然而，当审核人被重新请求评审合并请求时，webhook 消费方无法识别具体是哪个审核人被重新请求评审，从而难以触发适当的通知或自动化。

合并请求的 Webhook 负载现在在审核人数据中包含一个 `re_requested` 属性，明确指示哪个审核人被重新请求评审：

- 对于被重新请求评审的特定审核人，设置为 `true`。
- 对于所有其他审核人，设置为 `false`。

此改进使围绕合并请求评审流程的自动化更加精确。Webhook 消费方可以发送有针对性的通知、更新外部跟踪系统，并在重新请求评审时触发适当的工作流。

<a id="web-ide-support-for-offline-gitlab-self-managed-environments"></a>

### Web IDE 支持离线极狐GitLab 私有化部署环境

<!-- categories: Web IDE, Editor Extensions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/web_ide.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/15146)

{{< /details >}}

处于离线或严格受控网络环境中的极狐GitLab 私有化部署管理员现在可以配置自定义 Web IDE 扩展主机域名，从而在无需外部互联网访问的情况下启用完整的 Web IDE 功能。

此前，Web IDE 需要连接到 `.cdn.web-ide.gitlab-static.net` 才能加载 VS Code 扩展和功能。这一要求阻碍了注重安全的组织、政府和公共部门客户，以及具有严格网络策略的企业采用 Web IDE。

通过此更新，管理员可以配置其极狐GitLab 实例直接提供 Web IDE 资源，从而消除对外部域名的依赖。您现在可以：

- 在完全离线的环境中使用完整的 Web IDE 功能集。
- 使用自定义扩展注册表服务启用扩展市场。
- 在隔离网络中的 Web IDE 内启用 Markdown 预览、代码编辑和极狐GitLab Duo Chat。

<a id="webhook-triggers-for-system-initiated-approval-resets"></a>

### 系统发起的审批重置的 Webhook 触发器

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhook_events.md#system-initiated-merge-request-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/553070)

{{< /details >}}

通过 webhook 将极狐GitLab 与外部系统集成，对于自动化工作流以及让团队了解合并请求状态变更至关重要。然而，当极狐GitLab 自动重置审批时（例如在启用了“推送时重置审批”的合并请求中推送新提交时），外部系统无法区分这些系统发起的事件与手动用户操作。

极狐GitLab 现在包含增强的 webhook 负载，可明确识别系统发起的审批重置。当审批被自动重置时，webhook 现在包含：

- 一个设置为 `true`的 `system` 字段。
- 一个 `system_action` 字段，提供有关重置发生原因的具体上下文，例如 `approvals_reset_on_push` 或 `code_owner_approvals_reset_on_push`。

这意味着您的 webhook 集成现在可以区分手动审批变更和自动系统重置，从而实现更复杂的自动化工作流，针对每次审批变更的具体上下文做出适当响应。

<a id="gitlab-duo-planner-agent-now-available-by-default"></a>

### 极狐GitLab Duo Planner Agent 现在默认提供

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/agents/foundational_agents/planner.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/580924)

{{< /details >}}

极狐GitLab Duo Planner Agent 现在默认在极狐GitLab Duo Chat 的 Agent 下拉列表中提供，无需从 AI 目录中手动添加。凭借对您的工作项、史诗、议题和任务的完整上下文，Planner Agent 现在可以在群组和项目两个层级为您提供帮助。

从[**[示例提示](../../user/duo_agent_platform/agents/foundational_agents/planner.md#example-prompts)**](../../user/duo_agent_platform/agents/foundational_agents/planner.md#example-prompts)开始，了解 Planner Agent 如何帮助您分解复杂工作、创建实施计划并组织团队目标。

此功能处于测试版，欢迎您在[议题 576622](https://gitlab.com/gitlab-org/gitlab/-/issues/576622)中提供反馈。

<a id="helm-chart-registry-no-more-1000-chart-limit"></a>

### Helm chart 仓库：不再有 1,000 个 chart 的限制

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/helm_repository/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/545919)

{{< /details >}}

极狐GitLab 的 Helm chart 仓库此前会即时生成元数据响应，当仓库包含大量 chart 时会造成性能瓶颈。为保持系统稳定性，我们强制实施了最近 1,000 个 chart 的硬性限制。当平台团队尝试访问较旧的 chart 版本时，此限制会导致令人沮丧的 404 错误。

平台工程师被迫实施复杂的变通方法，例如将 chart 拆分到多个仓库、手动管理 chart 保留策略，或维护单独的 chart 存储解决方案。这些变通方法增加了运维开销，并使部署工作流变得碎片化，从而更难维护集中式的 chart 治理。

在极狐GitLab 18.6 中，我们通过预先计算元数据响应并将其存储在对象存储中，消除了 1,000 个 chart 的限制。这一架构变更既实现了无限制的 chart 访问，又提升了性能，因为元数据在后台作业中生成一次，而不是在每次请求时生成。

<a id="warn-mode-in-merge-request-approval-policies-beta"></a>

### 合并请求审批策略中的警告模式（测试版）

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#warn-mode) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19595)

{{< /details >}}

安全团队现在可以使用警告模式，在实施强制执行之前测试和验证安全策略的影响，从而在安全策略推广期间减少开发人员的阻力。

当您创建或编辑[合并请求审批策略](../../user/application_security/policies/merge_request_approval_policies.md)时，现在可以在 `warn` 或 `enforce` 执行选项之间进行选择。

处于警告模式的策略会生成信息性机器人评论，而不会阻止合并请求。可选审批人可被指定为策略问题的联系人。这种方法使安全团队能够评估策略影响，并通过透明、渐进的策略采用来建立开发人员的信任。

合并请求中的清晰指示器会告知用户策略处于 `warn` 还是 `enforce` 模式，审计事件会跟踪策略违规和忽略情况，以供合规报告使用。开发人员可以在提供忽略理由的同时忽略漏洞，从而形成协作式的安全策略管理方法。

<a id="security-attributes-beta"></a>

### 安全属性（测试版）

<!-- categories: Security Asset Inventories -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/attributes/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19597)

{{< /details >}}

安全团队现在可以通过利用安全属性，为项目应用业务上下文。

安全属性按类别组织，包括业务影响（带有结构化的预定义选项）、应用程序、业务部门、互联网暴露和位置。或者，您可以创建自己的属性类别，并在这些类别中定义标记。

通过将这些属性应用于您的项目，您可以更快地搜索、筛选和识别安全清单中哪些项目需要根据风险态势和组织上下文采取行动。您现在可以：

- 识别任务关键型且需要更好扫描覆盖范围的项目
- 按应用程序或业务部门查看扫描覆盖范围
- 根据应用于您项目的属性进行搜索和筛选
- 快速定位对可公开访问/暴露的应用程序有贡献的项目

<a id="exceptions-to-bypass-merge-request-approval-policies"></a>

### 绕过合并请求审批策略的例外情况

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18114)

{{< /details >}}

组织现在可以指定特定用户、群组、角色或自定义角色，在发生关键情况时绕过合并请求审批策略。此能力为应急响应提供了灵活性，同时保持全面的审计事件记录和治理控制。

**带问责的紧急绕过**：指定用户可以在关键事件、安全热修复或紧急生产问题期间绕过审批要求。当紧急情况发生时，授权人员可以立即合并或推送变更，同时系统会捕获详细的理由和审计信息以供合规审查。

**关键能力包括：**

- **有记录的绕过流程**：当授权用户调用策略绕过时，他们必须通过直观的模态界面提供详细理由，确保每个例外都带有上下文并被妥善记录。
- **全面的审计集成**：每次绕过都会生成详细的审计事件，包括用户身份、策略上下文、理由和时间戳，从而完整了解例外使用模式。
- **灵活的配置**：使用 YAML 或 UI 配置为策略定义例外权限，支持单个用户、极狐GitLab 群组、标准角色和自定义角色。
- **基于 Git 的推送例外**：拥有预先批准的策略例外的用户在调用推送绕过选项 `security_policy.bypass_reason` 时可以直接推送。

此功能消除了在紧急情况下完全禁用安全策略的需要，为紧急变更提供了受控路径，同时保留了组织治理和审计要求。

<a id="designate-an-account-succession-beneficiary"></a>

### 指定账户继承受益人

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/profile/account/account_succession.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/330669)

{{< /details >}}

现在，您可以指定账户受益人权限，以便在您丧失行为能力或无法使用的情况下管理您的极狐GitLab 账户。要访问您的账户，受益人必须提供适当的法律文件。此功能有助于确保您的工作和项目的连续性，同时防止未经授权的访问。

<a id="group-owners-can-update-primary-emails-for-enterprise-users"></a>

### 群组所有者可以为企业管理用户更新主电子邮件

<!-- categories: System Access -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/enterprise_user/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425837)

{{< /details >}}

群组所有者现在可以更新其群组中企业管理用户的主电子邮件地址。可以通过用户 API 进行更新。此前，每个企业管理用户都必须手动更新自己的电子邮件地址。此变更使大规模管理企业管理用户变得更加容易。

<a id="gitlab-runner-186"></a>

### 极狐GitLab Runner 18.6

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.6！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [实现最小作业确认 API](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/39013)

<a id="bug-fixes"></a>

#### 缺陷修复

- [极狐GitLab Runner 不会展开 Docker 镜像平台选项中的变量](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38488)
- [辅助 sidecar 容器无法将缓存上传到另一个账户的 S3 存储桶](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37879)
- [自动取消的作业继续执行并失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37878)
- [生成的 PowerShell 脚本中缺少 UTF8 BOM，导致可使用带有字符 Ä 的合并请求标题执行远程代码](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36060)
- [使用 Kubernetes 执行器时，Kubernetes API 服务器请求间歇性失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30109)
- [使用 Kubernetes 执行器时，提交信息较大的作业会失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/26624)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-6-stable/CHANGELOG.md)。
