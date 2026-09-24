---
stage: Release Notes
group: Monthly Release
date: 2025-07-17
title: "极狐GitLab 18.2 发布说明"
description: "极狐GitLab 18.2 发布，包含 IDE 中的 Duo Agent Platform（测试版）"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 7 月 17 日，极狐GitLab 18.2 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="custom-workflow-statuses-for-issues-and-tasks"></a>

### 自定义议题和任务的工作流状态

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/work_items/status.md) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/issues/xxxx) <!-- 注意原 issue 链接，这里替换为 jihulab 的，但原链接是 groups/gitlab-org/-/epics/14794，需要替换为 groups/gitlab-cn/-/epics/14794 ？规则将 gitlab-org 替换为 gitlab-cn，所以更新如下 -->

{{< /details >}}

借助可配置的状态，超越基本的打开/关闭系统，让你能够跟踪工作项在你的团队实际工作流阶段中的进展。

现在，你可以定义能够准确反映流程的自定义状态，而不再依赖标签。通过可配置的状态，你可以：

- **定义与你的团队实际流程相匹配的自定义工作流**。
- **用更易查找、更新和报告的适当状态来替代工作流标签**。
- **明确完成结果**，除了关闭议题外，还可以使用"完成"或"已取消"。
- **准确地对工作项状态进行筛选和报告**，以获得更好的项目洞察。
- **在议题看板中使用状态**，当议题在列之间移动时自动更新状态。
- **对多个工作项进行批量状态更新**，以实现高效的工作流管理。
- **跟踪依赖关系**，并查看关联工作项的状态可见性。

自定义工作流状态还支持**评论中的快速操作**，并自动与极狐GitLab 的打开/关闭系统同步。

请在 [反馈议题](https://gitlab.com/gitlab-com/www-gitlab-com/-/issues/35235) 中分享你的想法和建议，帮助我们改进此功能。

<a id="new-merge-request-homepage"></a>

### 新的合并请求主页

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/merge_requests/homepage.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13448)

{{< /details >}}

当你同时作为作者和审查者处理大量合并请求时，跨多个项目管理代码审查可能会令人不知所措。

新的合并请求主页通过智能地优先处理你需要立即关注的事项，彻底改变了你管理审查工作负载的方式，它提供了两种强大的查看模式：

- **工作流视图**根据审查状态对合并请求进行组织，按其在代码审查工作流中的阶段对工作进行分组。
- **角色视图**根据你是作者还是审查者对合并请求进行分组，清晰地分离了职责。

**活跃**选项卡显示需要关注的合并请求，**已合并**显示最近完成的工作，而**搜索**提供全面的筛选功能。

新的主页还通过合并你作为作者和被指派的合并请求，扩大了你的可见性，确保你不会错过已委派给你的工作。

<a id="group-and-project-controls-for-premium-and-ultimate-with-gitlab-duo"></a>

### 使用 极狐GitLab Duo 对专业版和旗舰版进行群组和项目控制

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/gitlab_duo/turn_on_off.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/551895)

{{< /details >}}

极狐GitLab 专业版和旗舰版用户现在可以更改代码建议和 极狐GitLab Duo Chat 在 IDE 中对群组和项目的可用性。以前，你只能更改实例或顶级群组的可用性。

<a id="new-group-overview-compliance-dashboard"></a>

### 新的群组概览合规仪表板

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_overview_dashboard.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13909)

{{< /details >}}

合规中心是合规团队集中管理其合规状态报告、违规报告以及群组合规框架的核心位置。

新的群组概览合规仪表板为合规经理提供了关于群组中所有项目合规信息的聚合视图。此首次迭代显示以下信息：

- 受特定合规框架覆盖的项目百分比。
- 群组中所有项目未通过的需求百分比。
- 群组中所有项目未通过的控件百分比。
- 需要"关注"的特定框架。

通过这个新的群组概览，合规经理现在拥有了一个统一的视图，可以清晰地从宏观层面了解其合规状况。

<a id="download-a-pdf-export-of-security-reports"></a>

### 以 PDF 格式导出版安全报告

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/security_dashboard/_index.md#export-as-pdf) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/16989)

{{< /details >}}

为了向其他利益相关者传达你的漏洞管理工作的状态和进展，你现在可以将每个项目或群组的安全仪表板导版为 PDF 文档。

<a id="centralized-security-policy-management-beta"></a>

### 集中式安全策略管理（测试版）

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/policies/enforcement/compliance_and_security_policy_groups.md#set-up-centralized-security-policy-management) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/17392)

{{< /details >}}

在合规至关重要的大型组织中，团队常常因分散在多个项目和群组中的策略而苦苦挣扎。如果没有集中化的可视性，确保持续一致的执行就会成为一项耗时的挑战，同时还会增加合规风险。

集中式安全策略管理引入了一种统一的方法，通过单个指定的合规与安全策略 (CSP) 群组，在整个极狐GitLab 组织中创建、管理和执行安全策略。这使安全团队能够：

- **一次定义，处处应用**：通过 CSP 一次性创建实例级安全策略，并自动在所有群组和项目中执行这些策略。
- **配置业务单元策略**：顶级群组可以配置自己独立的一套策略，同时从 CSP 群组继承组织策略。
- **确保遵守最小权限原则**：建立为实例强制执行的中央策略管理层。

此测试版为集中式策略管理建立了基础框架，支持所有现有的安全策略类型，可为群组、项目或实例进行配置。

<a id="agentic-core"></a>

## Agentic 核心

<a id="mistral-small-now-available-for-gitlab-duo-self-hosted"></a>

### 国内 SOTA 模型现在可用于极狐GitLab Duo Self-Hosted

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/18202)

{{< /details >}}

你现在可以在极狐GitLab Duo Self-Hosted 上使用国内 SOTA 模型。该模型可用于私有化部署实例，并且是第一个完全兼容的开源模型，可在极狐GitLab Duo Self-Hosted 上为 极狐GitLab Duo Chat 和代码建议提供支持。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="container-scanning-support-for-multi-architecture-container-images"></a>

### 对多架构容器镜像的容器扫描支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/container_scanning/_index.md#available-cicd-variables) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/543144)

{{< /details >}}

容器扫描现在随 Linux Arm64 容器镜像变体一起提供。当在 Linux Arm64 Runner 上运行时，分析器将不再需要仿真，从而加快分析速度。此外，你现在可以通过将 `TRIVY_PLATFORM` 环境变量设置为要扫描的平台来扫描多架构镜像。

<a id="improved-archive-file-support-for-container-scanning"></a>

### 改进的容器扫描归档文件支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/container_scanning/_index.md#scanning-archive-formats) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/501077)

{{< /details >}}

极狐GitLab 18.2 为容器扫描带来了改进的归档文件扫描支持。如果在多个镜像中发现某个特定软件包的漏洞，你现在会看到该漏洞归属于每个已扫描的镜像。

<a id="static-reachability-support-for-javascript"></a>

### JavaScript 的静态可达性支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/static_reachability.md#supported-languages-and-package-managers) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/502334)

{{< /details >}}

组件分析现在支持对 JavaScript 库进行静态可达性分析。你可以将静态可达性生成的数据用作分类和修复决策的一部分。静态可达性数据还可以与 EPSS、KEV 和 CVSS 评分结合使用，以提供更聚焦的漏洞视图。

<a id="improved-support-for-verifying-successful-dast-login"></a>

### 改进对验证 DAST 登录成功的支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/browser/configuration/variables.md#authentication) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/435942)

{{< /details >}}

以前，`DAST_AUTH_SUCCESS_IF_AT_URL` 变量需要精确的 URL 匹配来验证身份验证是否成功。这对于具有静态登录后页面的应用程序效果很好，但对于每次登录后 URL 包含动态元素的应用程序来说则带来了困难。

现在，你可以在 `DAST_AUTH_SUCCESS_IF_AT_URL` 变量中使用通配符模式来匹配动态 URL 模式。此增强功能提供了所需的灵活性，即使在每次会话之间确切 URL 发生变化时也能验证身份验证成功。

<a id="dast-support-for-time-based-one-time-password-mfa"></a>

### DAST 对基于时间的一次性密码 MFA 的支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/browser/configuration/authentication.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13633)

{{< /details >}}

动态分析现在支持基于时间的一次性密码 (TOTP) 多因素身份验证。

你可以对启用了 TOTP MFA 的项目运行 DAST 扫描，以确保全面的安全测试。此增强功能通过在与部署了 MFA 的生产环境相匹配的配置中测试应用程序，提供了更准确的扫描结果。

<a id="deactivate-streaming-to-an-audit-streaming-destination"></a>

### 停用审计流目标

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_streaming.md#activate-or-deactivate-streaming-destinations) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/537096)

{{< /details >}}

以前，没有方法可以暂时停用到某个审计流目标的流。你可能会出于多种原因想要这样做，包括对流连接进行故障排查，或者在不删除配置并重新开始的情况下对配置进行更改。

在极狐GitLab 18.2 中，我们添加了将审计流切换为活动或非活动状态的功能。当审计流处于非活动状态时，审计事件将不再流式传输到所选目标。重新激活后，审计事件会再次流式传输到所选目标。

<a id="filter-functionality-for-all-audit-streaming-destinations"></a>

### 所有审计流目标的筛选功能

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/audit_event_streaming.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/524939)

{{< /details >}}

以前，某些审计流目标不具备所有可用的筛选功能。

我们现在通过 UI 对所有目标支持筛选功能，包括能够根据以下条件进行筛选：

- 审计事件类型。
- 群组或项目。

这一变更也意味着 AWS 和 GCP 等审计事件目标现在可以通过审计事件进行筛选。

<a id="configure-epic-display-preferences"></a>

### 配置史诗显示首选项

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/393559)

{{< /details >}}

你现在可以完全控制在查看工作项列表时显示哪些元数据，从而更容易专注于对你最重要的信息。

以前，所有元数据字段总是可见的，这可能会使浏览工作项变得不堪重负。现在，你可以通过打开或关闭特定字段（如指派人、标签、日期和里程碑）来自定义你的视图。

<a id="open-epics-in-a-drawer-or-the-full-page-on-the-epics-page"></a>

### 在史诗页面上以抽屉或完整页面打开史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#open-epics-in-a-drawer) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/536620)

{{< /details >}}

你现在可以通过一个新的切换开关，选择史诗如何从列表页面打开，该切换开关可在抽屉视图和完整页面导航之间切换。

使用抽屉可以快速查看史诗详细信息，同时保持史诗列表的上下文；当需要更多屏幕空间进行详细编辑和全面导航时，则可以打开完整页面。

<a id="assign-milestones-to-epics-for-enhanced-long-term-planning"></a>

### 为史诗分配[里程碑](../../user/project/milestones/_index.md)以增强长期规划

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/milestones/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/329)

{{< /details >}}

你现在可以将[里程碑](../../user/project/milestones/_index.md)直接分配给史诗，从而创建一个从战略举措到执行的自然规划级联。此增强功能可帮助你将长期规划节奏（如季度规划或 SAFe 项目群增量）与史诗对齐。同时，你可以保持迭代专注于开发冲刺。

通过建立这种明确的层级结构，你可以减少管理开销，并更好地了解你的战略举措如何根据组织时间框架取得进展。

<a id="assign-epics-to-team-members"></a>

### 将史诗分配给团队成员

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#assignees) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/4231)

{{< /details >}}

你现在可以将史诗分配给个人，从而明确谁负责监督战略举措。史诗指派人有助于你在作品集层面明确所有权，从而实现更快的决策制定，并更清晰地界定长期目标的责任。团队可以快速了解就史诗进展、依赖关系或范围变化应联系谁。

<a id="sorting-and-pagination-for-glql-views"></a>

### GLQL 视图的排序和分页

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/glql/_index.md#presentation-syntax) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/502701)

{{< /details >}}

此版本为 GLQL 视图引入了增强的排序和分页功能，使处理大型数据集更加容易。

你现在可以按关键字段（包括截止日期、健康状态和流行度）进行排序，以快速找到最相关的项目。新的"加载更多"分页系统提供了对数据加载的更好控制，用按需加载的可管理数据块取代了令人应接不暇的全量结果。

这些改进可帮助团队高效地浏览复杂的项目数据，并在任何给定时刻专注于最重要的事项。

<a id="work-item-references-and-editor-improvements-for-gitlab-flavored-markdown"></a>

### GitLab Flavored Markdown 的工作项引用和编辑器改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/markdown.md#gitlab-specific-references) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/7654)

{{< /details >}}

你现在可以在 GitLab Flavored Markdown 中使用统一的 `[work_item:123]` 语法来引用议题、史诗和工作项。此新语法可与现有的引用格式（如议题的 `#123` 和史诗的 `&123`）一起使用，并支持使用 `[work_item:namespace/project/123]` 进行跨项目引用。

纯文本编辑器还包含一个新的[首选项，可以在按 Enter 键时保持光标缩进](../../user/profile/preferences.md#maintain-cursor-indentation)，这使得编写结构化内容（如嵌套列表和代码块）更加容易。

<a id="vulnerability-id-added-to-vulnerability-report-csv-export"></a>

### 漏洞 ID 添加到漏洞报告 CSV 导出

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

... <!-- 后续内容将根据第二部分继续翻译 -->
- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#exporting)

{{< /details >}}

之前，漏洞报告的 CSV 导出不包含漏洞 ID。
现在，您可以在 CSV 导出中找到每个漏洞的 ID。

<a id="reachability-filter-in-the-vulnerability-report"></a>

### 漏洞报告中的可达性过滤器

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#filtering-vulnerabilities)

{{< /details >}}

用户现在可以在漏洞报告中过滤数据，仅包含可达漏洞。
可达漏洞是指同时满足以下条件的漏洞：

- 在通用漏洞与披露 (CVE) 列表中。
- 属于显式导入的库的一部分。

<a id="vulnerability-graphql-api-returns-additional-information"></a>

### 漏洞 GraphQL API 返回额外信息

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/graphql/reference/_index.md#vulnerability)

{{< /details >}}

您现在可以使用 GraphQL API 来确定漏洞引入的流水线以及最后检测到的时间。漏洞 GraphQL API 现在包括：

- `initialDetectedPipeline`：用于检索有关漏洞引入时的额外提交信息，例如作者的用户名。
- `latestDetectedPipeline`：用于检索有关漏洞移除时的额外提交信息，例如提交 SHA。

<a id="source-branch-pattern-exceptions-for-approval-policies"></a>

### 审批策略的源分支模式例外

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md#source-branch-exceptions)

{{< /details >}}

之前，使用 GitFlow 的团队在将 `release/*` 分支合并到 `main` 时经常面临审批死锁，
因为大多数贡献者已经参与了发布开发，因此无法担任审批人。

合并请求审批策略中的分支模式例外通过自动绕过特定源-目标分支组合的审批要求来解决此问题。
为功能到主分支的合并配置严格的审批，同时允许简化的发布到主分支工作流。

**关键能力：**

- **基于模式的配置：** 定义绕过审批要求的源分支模式，例如 `release/*` 或 `hotfix/*`
- **无缝集成：** 分支例外直接集成到现有的合并请求审批策略中，并可通过 UI 或 `policy.yml` 文件进行配置。

这消除了对复杂变通方法的需求，同时为标准开发工作流保留了合并请求审批策略的安全优势。

<a id="display-dependency-paths"></a>

### 显示依赖路径

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_list/_index.md#dependency-paths)

{{< /details >}}

之前，很难确定某个依赖是直接依赖还是由依赖的后代导入的传递依赖。

您现在可以使用新的依赖路径功能确定库是主要导入还是传递导入。您可以在项目和群组依赖列表以及漏洞详情中找到依赖路径。此功能使开发人员能够根据库的导入方式确定最有效的修复路径。

<a id="credentials-inventory-now-includes-service-account-tokens"></a>

### 凭证清单现在包含服务账户令牌

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/credentials_inventory.md)

{{< /details >}}

极狐GitLab 现在在凭证清单中支持服务账户令牌，让您更好地了解和控制整个软件供应链中使用的各种认证方法。凭证清单提供了组织内使用的凭证的完整视图。

<a id="security-inventory-for-comprehensive-asset-visibility-now-in-beta"></a>

### 用于全面资产可见性的安全清单（测试版）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/security_inventory/_index.md)

{{< /details >}}

AppSec 团队需要全面了解其组织在所有资产中的安全态势。之前，极狐GitLab 的安全工作流主要集中在项目级别的扫描器配置和项目级别的漏洞上，这使得理解覆盖差距和做出高效、基于风险的优先级决策变得困难。

安全清单提供了极狐GitLab 实例中安全态势的集中视图，使 AppSec 团队能够：

- 全面了解项目和群组的安全覆盖情况
- 识别缺乏安全扫描或存在配置差距的资产
- 做出明智的、基于风险的决策，确定安全工作的重点
- 跟踪安全态势随时间的改进

此功能有助于弥合单个项目安全与组织范围安全策略之间的差距，为您提供有效安全管理计划所需的资产清单基础。

<a id="custom-admin-role-in-beta"></a>

### 自定义管理员角色（测试版）

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/custom_roles/_index.md)

{{< /details >}}

自定义管理员角色为私有化部署实例的管理员区域带来了细粒度权限。管理员现在可以创建仅访问用户所需特定功能的专门角色，而不是授予完全访问权限。此功能帮助组织实施管理功能的最小权限原则，降低因过度授权带来的安全风险，并提高运营效率。

我们正在积极寻求社区对此功能的反馈。如果您有问题、想分享实施经验，或希望直接与我们的团队就潜在改进进行交流，请访问我们的反馈 issue。

<a id="trigger-jobs-can-mirror-the-downstream-pipeline-status"></a>

### 触发器作业可以镜像下游流水线状态

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/yaml/_index.md#triggerstrategy)

{{< /details >}}

之前，使用 `strategy:depend` 的触发器作业在处理复杂流水线状态（如手动作业、阻塞流水线或在执行过程中状态变化的重新尝试流水线）时存在限制。
这可能使下游流水线看起来正在运行，而实际上它正阻塞在手动作业上。

新的 `strategy:mirror` 关键字通过镜像下游流水线的精确实时状态，提供了更细致的状态报告。状态包括中间状态，如
`running`、`manual`、`blocked` 和 `canceled`。这使团队能够完全了解其下游流水线的当前状态，而不会破坏现有工作流。

<a id="gitlab-runner-182"></a>

### 极狐GitLab Runner 18.2

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.2！极狐GitLab Runner 是高度可扩展的构建代理，运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 中包含的开源持续集成服务。

#### Bug 修复

- [升级到极狐GitLab Runner 18.1.0 后，Runner 在 FIPS 模式下失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38890)
- [使用 `FF_USE_DUMB_INIT_WITH_KUBERNETES_EXECUTOR` 无法启动作业 Pod](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/241)
- [`ubi-fips` 镜像不是极狐GitLab Runner FIPS 的默认辅助镜像类型](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38273)
- [禁用极狐GitLab 维护模式后，Runner 长时间保持离线状态](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29181)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-2-stable/CHANGELOG.md) 中。