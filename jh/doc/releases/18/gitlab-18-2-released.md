---
stage: Release Notes
group: Monthly Release
date: 2025-07-17
title: "极狐GitLab 18.2 发布说明"
description: "极狐GitLab 18.2 发布，在 IDE 中提供 Duo Agent Platform（测试版）"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 7 月 17 日，极狐GitLab 18.2 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="duo-agent-platform-in-the-ide-beta"></a>

### 在 IDE 中提供 Duo Agent Platform（测试版）

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/duo_agent_platform/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/556038)

{{< /details >}}

Duo Agent Platform 将 Agentic Chat 和 Agent 任务流直接引入 VS Code 和 JetBrains IDE，支持以自然对话方式与您的代码库和极狐GitLab 项目交互。

Agentic Chat 专为快速、对话式任务而设计，例如创建和编辑文件、使用模式匹配和 grep 在代码库中搜索，以及即时获取有关代码的答案。Agent 任务流负责更大规模的实现和全面规划，将高层构想从概念推进到架构，同时访问极狐GitLab 资源，包括议题、合并请求、提交、CI/CD 流水线和安全漏洞。两者都提供智能搜索能力，可搜索文档、代码模式和项目发现，帮助您完成从快速编辑到复杂项目分析的各种任务。

该平台还支持模型上下文协议（MCP），用于连接外部数据源和工具，使 AI 功能能够利用极狐GitLab 之外的上下文。

在 GitLab 的博客文章中了解更多：[极狐GitLab Duo Agent Platform 公开测试版：新一代 AI 编排及更多功能](https://about.gitlab.com/blog/gitlab-duo-agent-platform-public-beta/)。

要开始使用，请参阅 [Duo Agent Platform 文档](../../user/duo_agent_platform/_index.md)、
[VS Code 设置指南](../../user/gitlab_duo_chat/agentic_chat.md#use-gitlab-duo-chat-in-vs-code)
和 [JetBrains 设置指南](../../user/gitlab_duo_chat/agentic_chat.md#use-gitlab-duo-chat-in-jetbrains-ides)。

<a id="custom-workflow-statuses-for-issues-and-tasks"></a>

### 议题和任务的自定义工作流状态

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/work_items/status.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14794)

{{< /details >}}

通过可配置状态，您可以超越基本的打开/关闭系统，按照团队实际的工作流阶段跟踪工作项。

现在，您无需依赖标记，即可定义准确反映您流程的自定义状态。借助可配置状态，您可以：

- **定义自定义工作流**，使其与团队的实际流程相匹配。
- **替换工作流标记**，改用更易于查找、更新和报告的正式状态。
- **明确完成结果**，使用“已完成”或“已取消”来超越关闭议题这一单一方式。
- **准确筛选和报告**工作项状态，获得更好的项目洞察。
- **在议题看板中使用状态**，当议题在列之间移动时自动更新。
- **批量更新状态**，跨多个工作项高效管理工作流。
- **跟踪依赖关系**，查看已关联工作项的状态。

自定义工作流状态还支持**评论中的快速操作**，并与极狐GitLab 的打开/关闭系统自动同步。

欢迎在 GitLab 的[反馈议题](https://gitlab.com/gitlab-com/www-gitlab-com/-/issues/35235)中分享您的想法和建议，帮助我们改进此功能。

<a id="new-merge-request-homepage"></a>

### 全新的合并请求主页

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/homepage.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13448)

{{< /details >}}

当您同时作为作者和审核人处理数十个合并请求时，跨多个项目管理代码评审可能会让人不堪重负。

全新的合并请求主页通过智能地优先显示当前需要您关注的内容，改变了您浏览评审工作量的方式，并提供两种强大的查看模式：

- **工作流视图**按评审状态组织合并请求，将工作按其代码评审工作流中的阶段分组。
- **角色视图**按您是作者还是审核人对合并请求进行分组，让职责划分一目了然。

**活跃**标签页显示需要关注的合并请求，**已合并**显示最近完成的工作，**搜索**提供全面的筛选能力。

新主页还通过合并您创作的合并请求和分配给您的合并请求来扩展可见性，确保您不会错过任何委派给您的任务。

<a id="improve-security-with-immutable-container-tags-beta"></a>

### 使用不可变容器标签提升安全性（测试版）

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 旗舰版
- 链接: [文档](../../user/packages/container_registry/immutable_container_tags.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15139)

{{< /details >}}

容器镜像仓库是现代 DevSecOps 团队的关键基础设施。然而，即使使用了受保护的容器标签，组织仍然面临一个挑战：标签创建后，拥有足够权限的用户可以更改它。这给依赖特定标签版本容器镜像来保障生产稳定性的团队带来了风险。任何修改——即使是授权用户所做的——都可能引入意外变更或破坏部署完整性。

借助不可变容器标签，您可以保护容器镜像免受意外更改。当创建的标签匹配不可变规则后，任何人都无法修改该容器镜像。现在您可以：

- 使用 RE2 正则表达式模式，为每个项目创建最多 5 条保护规则（受保护规则和不可变规则合计）。
- 保护关键标签（如 latest、语义化版本（例如 v1.0.0）或候选发布版本）免受任何修改。
- 确保不可变标签自动排除在清理策略之外。

不可变容器标签需要下一代容器镜像仓库，该仓库在 JihuLab.com 上默认启用。对于极狐GitLab 私有化部署实例，您必须启用[元数据数据库](../../administration/packages/container_registry_metadata_database.md)才能使用不可变容器标签。

<a id="group-and-project-controls-for-premium-and-ultimate-with-gitlab-duo"></a>

### 使用极狐GitLab Duo 的专业版和旗舰版群组与项目控制

<!-- categories: Code Suggestions, Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/gitlab_duo/turn_on_off.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/551895)

{{< /details >}}

极狐GitLab 专业版和旗舰版用户现在可以更改群组和项目中 IDE 内代码建议和极狐GitLab Duo Chat 的可用性。此前，您只能更改实例或顶级群组的可用性。

<a id="new-group-overview-compliance-dashboard"></a>

### 全新的群组概览合规仪表板

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_overview_dashboard.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13909)

{{< /details >}}

合规中心是合规团队管理其合规状态报告、违规报告和群组合规框架的集中位置。

全新的群组概览合规仪表板为合规经理提供群组内所有项目合规信息的聚合视图。此首个迭代版本显示以下信息：

- 受特定合规框架覆盖的项目百分比。
- 群组内所有项目未通过要求的百分比。
- 群组内所有项目未通过控制的百分比。
- 需要“关注”的特定框架。

借助这一全新的群组概览，合规经理现在拥有单一统一视图，可以清晰了解其合规状况的高层全貌。

<a id="map-workspace-kubernetes-agents-for-the-instance"></a>

### 为实例映射工作区 Kubernetes Agent

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 链接: [文档](../../user/workspace/gitlab_agent_configuration.md#allow-a-cluster-agent-for-workspaces-on-the-instance) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16485)

{{< /details >}}

极狐GitLab 管理员现在可以为实例映射已启用的工作区 Kubernetes Agent。随后，用户可以从该实例中的任何群组或项目创建工作区。

这显著提升了工作区的可扩展性，使组织可以一次性预配工作区 Kubernetes Agent，并让整个实例中所有当前和未来的项目都能访问这些 Agent。

<a id="download-a-pdf-export-of-security-reports"></a>

### 下载安全报告的 PDF 导出文件

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/security_dashboard/_index.md#export-as-pdf) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16989)

{{< /details >}}

为了向其他利益相关方传达您漏洞管理工作的情况和进展，您现在可以将每个项目或群组的安全仪表板导出为 PDF 文档。

<a id="centralized-security-policy-management-beta"></a>

### 集中式安全策略管理（测试版）

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md#set-up-centralized-security-policy-management) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17392)

{{< /details >}}

在合规至关重要的大型组织中，团队常常苦于策略分散在多个项目和群组中。缺乏集中可见性时，确保一致执行会成为一项耗时的挑战，同时增加合规风险。

集中式安全策略管理引入了一种统一方法，通过单个指定的合规与安全策略（CSP）群组，在整个极狐GitLab 组织中创建、管理和执行安全策略。这使安全团队能够：

- **一次定义策略，处处应用**：通过 CSP 一次性创建实例级安全策略，并自动在所有群组和项目中执行这些策略。
- **配置业务单元策略**：顶级群组可以配置自己独立的策略集，同时继承来自 CSP 群组的组织策略。
- **确保遵循最小权限原则**：建立为实例强制执行的集中策略管理层。

此测试版为集中式策略管理奠定了基础框架，支持所有现有安全策略类型，可针对群组、项目或实例进行配置。

<a id="agentic-core"></a>

## AI 功能

<a id="mistral-small-now-available-for-gitlab-duo-self-hosted"></a>

### Mistral Small 现已可用于极狐GitLab Duo 自部署版本

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18202)

{{< /details >}}

您现在可以在极狐GitLab Duo 自部署版本上使用 Mistral Small。该模型可在极狐GitLab 私有化部署实例上使用，并且是极狐GitLab Duo 自部署版本上首个完全兼容的开源模型，适用于极狐GitLab Duo Chat 和代码建议。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="administrators-can-reassign-contributions-without-user-confirmation"></a>

### 管理员无需用户确认即可重新分配贡献

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523259)

{{< /details >}}

管理员现在无需用户确认，即可将占位用户的贡献重新分配给活跃用户。此功能解决了大型组织的一个关键难题：当用户未查看电子邮件以批准重新分配时，该流程会停滞。

在启用了用户模拟的极狐GitLab 实例上，管理员可以在维护数据完整性的同时简化用户管理工作流。重新分配完成后，用户仍会收到通知电子邮件，确保整个过程的透明度。

<a id="reassign-from-placeholder-users-to-inactive-users"></a>

### 从占位用户重新分配给非活跃用户

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../administration/settings/import_and_export_settings.md#skip-confirmation-when-administrators-reassign-placeholder-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523260)

{{< /details >}}

此前，管理员只能将占位用户的贡献和成员资格重新分配给活跃用户。

在极狐GitLab 私有化部署上，管理员现在还可以将占位用户的贡献和成员资格重新分配给非活跃用户。此功能允许您保留极狐GitLab 实例上被阻止、被封禁或已停用用户的贡献历史和成员资格信息。

管理员必须先启用此设置；启用后，该设置在重新分配期间跳过用户确认，同时保持安全的访问控制，从而简化用户管理。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="container-scanning-support-for-multi-architecture-container-images"></a>

### 容器扫描支持多架构容器镜像

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/container_scanning/_index.md#available-cicd-variables) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/543144)

{{< /details >}}

容器扫描现在随附 Linux Arm64 容器镜像变体。在 Linux Arm64 runner 上运行时，
分析器将不再需要模拟，从而加快分析速度。此外，您现在可以通过将 `TRIVY_PLATFORM` 环境变量设置为您要扫描的平台来扫描多架构镜像。

<a id="improved-archive-file-support-for-container-scanning"></a>

### 改进容器扫描的归档文件支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/container_scanning/_index.md#scanning-archive-formats) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501077)

{{< /details >}}

极狐GitLab 18.2 为容器扫描带来了改进的归档文件扫描支持。如果在多个镜像中发现某个特定软件包的漏洞，您现在会看到归属于每个已扫描镜像的漏洞。

<a id="static-reachability-support-for-javascript"></a>

### JavaScript 的静态可达性支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/static_reachability.md#supported-languages-and-package-managers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/502334)

{{< /details >}}

成分分析现在支持 JavaScript 库的静态可达性。您可以将静态可达性产生的数据用于分类和修复决策。静态可达性数据还可以与 EPSS、KEV 和 CVSS 评分结合使用，提供更聚焦的漏洞视图。

<a id="improved-support-for-verifying-successful-dast-login"></a>

### 改进对验证 DAST 登录成功的支持

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/configuration/variables.md#authentication) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435942)

{{< /details >}}

此前，`DAST_AUTH_SUCCESS_IF_AT_URL` 变量需要精确的 URL 匹配才能验证身份验证成功。这对于具有静态落地页的应用程序效果良好，但对于登录后 URL 每次登录都包含动态元素的应用程序则存在困难。

现在，您可以在 `DAST_AUTH_SUCCESS_IF_AT_URL` 变量中使用通配符模式来匹配动态 URL 模式。此增强功能提供了所需的灵活性，即使会话之间确切 URL 发生变化，也能验证身份验证成功。

<a id="dast-support-for-time-based-one-time-password-mfa"></a>

### DAST 支持基于时间的一次性密码 MFA

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/configuration/authentication.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13633)

{{< /details >}}

动态分析现在支持基于时间的一次性密码（TOTP）多因素身份验证。

您可以在启用了 TOTP MFA 的项目上运行 DAST 扫描，以确保全面的安全测试。此增强功能通过在与部署了 MFA 的生产环境相匹配的配置中测试应用程序，提供更准确的扫描结果。

<a id="deactivate-streaming-to-an-audit-streaming-destination"></a>

### 停用向审计事件流目标的流式传输

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_streaming.md#activate-or-deactivate-streaming-destinations) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/537096)

{{< /details >}}

此前，无法临时停用向审计事件流目标的流式传输。您可能出于多种原因需要这样做，包括排查流连接问题，或在不删除配置并重新开始的情况下更改配置。

在极狐GitLab 18.2 中，我们新增了将审计事件流切换为活跃或非活跃的功能。当审计事件流处于非活跃状态时，审计事件不再流式传输到所选目标。重新激活后，审计事件会再次流式传输到所选目标。

<a id="filter-functionality-for-all-audit-streaming-destinations"></a>

### 所有审计事件流目标的筛选功能

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_streaming.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/524939)

{{< /details >}}

此前，某些审计事件流目标不具备所有可用的筛选能力。

我们现在通过 UI 支持所有目标的筛选功能，包括按以下条件筛选：

- 按审计事件类型。
- 按群组或项目。

此变更还意味着 AWS 和 GCP 等审计事件目标现在可以筛选审计事件。

<a id="configure-epic-display-preferences"></a>

### 配置史诗显示偏好设置

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393559)

{{< /details >}}

您现在可以完全控制查看工作项列表时显示哪些元数据，从而更轻松地专注于对您最重要的信息。

此前，所有元数据字段始终可见，这可能会让浏览工作项变得不堪重负。现在，您可以通过打开或关闭特定字段（如指派人、标记、日期和里程碑）来自定义视图。

<a id="open-epics-in-a-drawer-or-the-full-page-on-the-epics-page"></a>

### 在史诗页面上以抽屉或整页方式打开史诗

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md#open-epics-in-a-drawer) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/536620)

{{< /details >}}

您现在可以通过一个新的切换开关选择史诗从列表页面打开的方式，在抽屉视图和整页导航之间切换。

使用抽屉可以快速查看史诗详情，同时保持史诗列表的上下文，或者在需要更多屏幕空间进行详细编辑和全面导航时打开整页。

<a id="assign-milestones-to-epics-for-enhanced-long-term-planning"></a>

### 为史诗分配[里程碑](../../user/project/milestones/_index.md)，增强长期规划

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/milestones/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/329)

{{< /details >}}

您现在可以直接为史诗分配[里程碑](../../user/project/milestones/_index.md)，形成从战略举措到执行的自然规划级联。此增强功能帮助您将长期规划节奏（如季度规划或 SAFe 项目群增量）与史诗对齐。同时，您可以让迭代专注于开发冲刺。

有了这一清晰的层级结构，您可以减少管理开销，并更好地了解您的战略举措如何按照组织时间框架推进。

<a id="assign-epics-to-team-members"></a>

### 为团队成员分配史诗

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md#assignees) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/4231)

{{< /details >}}

您现在可以为个人分配史诗，明确谁负责监督战略举措。史诗指派人帮助您在项目组合层面识别归属，从而加快决策速度，并让长期目标的问责更加清晰。团队可以快速了解就史诗进展、依赖关系或范围变更应联系谁。

<a id="sorting-and-pagination-for-glql-views"></a>

### GLQL 视图的排序和分页

<!-- categories: Wiki, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/glql/_index.md#presentation-syntax) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/502701)

{{< /details >}}

此版本为 GLQL 视图引入了增强的排序和分页功能，使处理大型数据集更加容易。

您现在可以按关键字段（包括截止日期、健康状态和热度）排序，以快速找到最相关的条目。新的“加载更多”分页系统提供了更好的数据加载控制，用按需加载的可管理数据块取代了令人不堪重负的整页结果。

这些改进帮助团队高效浏览复杂的项目数据，并随时专注于最重要的内容。

<a id="work-item-references-and-editor-improvements-for-gitlab-flavored-markdown"></a>

### 极狐GitLab 风格 Markdown 的工作项引用和编辑器改进

<!-- categories: Markdown -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md#gitlab-specific-references) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/7654)

{{< /details >}}

您现在可以在极狐GitLab 风格 Markdown 中使用统一的 `[work_item:123]` 语法引用议题、史诗和工作项。此新语法与现有引用格式（如用于议题的 `#123` 和用于史诗的 `&123`）并存，并支持使用 `[work_item:namespace/project/123]` 进行跨项目引用。

纯文本编辑器还包含一个新的[按 Enter 时保持光标缩进的偏好设置](../../user/profile/preferences.md#maintain-cursor-indentation)，使编写嵌套列表和代码块等结构化内容更加容易。

<a id="vulnerability-id-added-to-vulnerability-report-csv-export"></a>

### 漏洞报告 CSV 导出中新增漏洞 ID

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#exporting) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18033)

{{< /details >}}

此前，漏洞报告的 CSV 导出不包含漏洞 ID。您现在可以在 CSV 导出中找到列出的每个漏洞的 ID。

<a id="reachability-filter-in-the-vulnerability-report"></a>

### 漏洞报告中的可达性筛选

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#filtering-vulnerabilities) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/543346)

{{< /details >}}

用户现在可以筛选漏洞报告中的数据，仅包含可达漏洞。可达漏洞是指同时满足以下两个条件的漏洞：

- 在通用漏洞与暴露（CVE）列表中。
- 属于显式导入的库的一部分。

<a id="vulnerability-graphql-api-returns-additional-information"></a>

### 漏洞 GraphQL API 返回更多信息

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/graphql/reference/_index.md#vulnerability) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/468913)

{{< /details >}}

您现在可以使用 GraphQL API 确定漏洞引入时和最后检测到时的流水线。漏洞 GraphQL API 现在包含：

- `initialDetectedPipeline`：用于检索有关漏洞引入时间的其他提交信息，例如作者的用户名。
- `latestDetectedPipeline`：用于检索有关漏洞移除时间的其他提交信息，例如提交 SHA。

<a id="source-branch-pattern-exceptions-for-approval-policies"></a>

### 审批策略的源分支模式例外

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#source-branch-exceptions) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18113)

{{< /details >}}

此前，使用 GitFlow 的团队在将 `release/*` 分支合并到 `main` 时经常面临审批死锁，因为大多数贡献者已经参与了发布开发，因而无法担任审批人。

合并请求审批策略中的分支模式例外通过自动绕过特定源-目标分支组合的审批要求来解决此问题。为功能分支到 main 的合并配置严格审批，同时允许简化的发布分支到 main 的工作流。

**主要能力：**

- **基于模式的配置：**定义源分支模式，如 `release/*` 或 `hotfix/*`，以绕过审批要求
- **无缝集成：**分支例外直接集成到现有合并请求审批策略中，可通过 UI 或 `policy.yml` 文件进行配置。

这消除了对复杂变通方法的需求，同时保留了合并请求审批策略对标准开发工作流的安全优势。

<a id="display-dependency-paths"></a>

### 显示依赖路径

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md#dependency-paths) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16815)

{{< /details >}}

此前，很难确定某个依赖项是直接依赖项，还是由该依赖项的后代导入的传递依赖项。

您现在可以使用新的依赖路径功能确定某个库是直接导入还是传递导入。您可以在项目和群组依赖列表以及漏洞详情中找到依赖路径。此能力使开发者能够根据库的导入方式确定最高效的修复路径。

<a id="credentials-inventory-now-includes-service-account-tokens"></a>

### 凭据清单现在包含服务账号令牌

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/credentials_inventory.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421954)

{{< /details >}}

极狐GitLab 现在支持在凭据清单中显示服务账号令牌，让您更好地了解和控制软件供应链中使用的各种身份验证方法。凭据清单提供组织中所使用凭据的完整视图。

<a id="security-inventory-for-comprehensive-asset-visibility-now-in-beta"></a>

### 用于全面资产可见性的安全清单现已推出测试版

<!-- categories: Security Asset Inventories -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/security_inventory/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16484)

{{< /details >}}

AppSec 团队需要全面了解其组织所有资产的安全状况。此前，极狐GitLab 的安全工作流主要关注项目级扫描器配置和项目级漏洞，导致难以了解覆盖缺口并做出高效、基于风险的优先级决策。

安全清单提供极狐GitLab 实例中安全状况的集中视图，使 AppSec 团队能够：

- 全面了解项目和群组的安全覆盖情况
- 识别缺少安全扫描或存在配置缺口的资产
- 就安全工作的重点方向做出明智的、基于风险的决策
- 跟踪安全状况随时间的改进

此功能有助于弥合单个项目安全与组织级安全策略之间的差距，为您提供有效管理安全计划所需的资产清单基础。

<a id="custom-admin-role-in-beta"></a>

### 自定义管理员角色（测试版）

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15069)

{{< /details >}}

自定义管理员角色为极狐GitLab 私有化部署实例的管理区域带来了细粒度权限。管理员现在可以创建仅访问用户所需特定功能的专用角色，而无需授予完全访问权限。此功能帮助组织对管理功能实施最小权限原则，降低权限过高带来的安全风险，并提高运营效率。

我们正在积极寻求社区对此功能的反馈。如果您有疑问、想分享您的实施经验，或希望直接与我们的团队讨论潜在的改进，请访问 GitLab 的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/509376)。

<a id="trigger-jobs-can-mirror-the-downstream-pipeline-status"></a>

### 触发作业可以镜像下游流水线状态

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../ci/yaml/_index.md#triggerstrategy) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431882)

{{< /details >}}

此前，使用 `strategy:depend`的触发作业在处理复杂流水线状态时存在局限，例如手动作业、被阻止的流水线，或执行期间状态不断变化的已重试流水线。这可能会让下游流水线看起来正在积极运行，而实际上它被手动作业阻止了。

新的 `strategy:mirror` 关键字通过镜像下游流水线的确切实时状态，提供更细致的状态报告。状态包括中间状态，如 `running`、`manual`、`blocked` 和 `canceled`。这使团队能够全面了解其下游流水线的当前状态，而不会破坏现有工作流。

<a id="gitlab-runner-182"></a>

### 极狐GitLab Runner 18.2

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.2！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 缺陷修复

- [升级到极狐GitLab Runner 18.1.0 后，Runner 在 FIPS 模式下失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38890)
- [无法使用 `FF_USE_DUMB_INIT_WITH_KUBERNETES_EXECUTOR` 启动作业 pod](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/241)
- [`ubi-fips` 镜像不是极狐GitLab Runner FIPS 的默认辅助镜像类型](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38273)
- [禁用极狐GitLab 维护模式后，Runner 长时间保持离线](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29181)

所有变更列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-2-stable/CHANGELOG.md)。
