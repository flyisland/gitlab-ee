---
stage: 发布说明
group: 月度发布
date: 2025-03-20
title: "极狐GitLab 17.10 发布说明"
description: "极狐GitLab 17.10 发布，包含测试版的 Duo 代码审查功能"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 3 月 20 日，极狐GitLab 17.10 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="duo-code-review-available-in-beta"></a>

### Duo 代码审查现已在测试版中可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)

{{< /details >}}

代码审查是软件开发中的一项关键活动。它确保对项目的贡献能够保持并提升代码质量和安全性，同时也是工程师指导和反馈的途径。它也是软件开发过程中最耗时的活动之一。

Duo 代码审查是代码审查流程的下一个演进阶段。

Duo 代码审查可以加速你的开发流程。当它对合并请求进行初步审查时，可以帮助识别潜在的缺陷并建议进一步的改进——其中一些你可以直接从浏览器中应用。在引入其他人员之前，使用它来迭代和改进你的更改。

**试用方法：**

- 要立即启动代码审查，请将 `@GitLabDuo` 添加为合并请求的审查者。
- 要针对你的更改细化反馈，请在评论中提及 `@GitLabDuo`。

你可以在史诗 [13008](https://gitlab.com/groups/gitlab-org/-/epics/13008) 及相关子史诗中跟踪 Duo 代码审查的未来进展。反馈可以在议题 [517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386) 中提供。

<a id="root-cause-analysis-available-on-gitlab-duo-self-hosted"></a>

### 根因分析现已在极狐GitLab Duo 自托管上可用

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md#feature-versions-and-status)

{{< /details >}}

你现在可以在极狐GitLab Duo 自托管上使用[极狐GitLab Duo 根因分析](https://about.gitlab.com/blog/developing-gitlab-duo-blending-ai-and-root-cause-analysis-to-fix-ci-cd/)。此功能在使用极狐GitLab Duo 自托管的极狐GitLab 私有化部署实例上处于测试阶段，支持国内 SOTA 大模型。

借助极狐GitLab Duo 自托管上的根因分析，你可以更快地排查 CI/CD 流水线中失败的作业，同时不损害数据主权。根因分析会分析失败的作业日志，快速确定作业失败的根本原因，并为你建议修复方案。

注意：此功能目前功能有限，完整功能计划在 17.11 中推出。
更多信息请参见
[故障排查文档](../../administration/gitlab_duo_self_hosted/troubleshooting.md#feature-not-accessible-or-feature-button-not-visible)
和议题 [527128](https://gitlab.com/gitlab-org/gitlab/-/issues/527128)。

请在议题 [523912](https://gitlab.com/gitlab-org/gitlab/-/issues/523912) 中留下对极狐GitLab Duo 自托管根因分析的反馈。

<a id="gitlab-query-language-views-beta"></a>

### 极狐GitLab 查询语言视图测试版

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/glql/_index.md#embedded-views)

{{< /details >}}

以往，在极狐GitLab 中跟踪和了解进行中的工作需要在多个位置之间导航，降低了团队效率并消耗了宝贵时间。

此版本引入了极狐GitLab 查询语言 (GLQL) 视图测试版，让你可以直接在现有工作流中创建动态的实时工作跟踪。

GLQL 视图将实时数据查询嵌入到 Wiki 页面、史诗描述、议题评论和合并请求的 Markdown 代码块中。

GLQL 视图此前作为实验功能提供，现在进入测试阶段，支持使用逻辑表达式和运算符对关键字段（包括指派人、作者、标签和里程碑）进行复杂的筛选。你可以将视图的呈现方式自定义为表格或列表，控制显示哪些字段，并设置结果限制，为团队创建聚焦的、可操作的洞察。

团队现在可以在保持上下文的同时访问所需信息，建立共同理解，并改善协作——所有这些都无需离开当前工作流。

[我们欢迎你的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/509791)，我们将持续增强此功能。

<a id="enhanced-markdown-experience"></a>

### 增强的 Markdown 体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/markdown.md)

{{< /details >}}

极狐GitLab Flavored Markdown 得到了多项强大的改进：

- **改进的数学公式和图片处理**：
  - 在你的群组或私有化部署实例中禁用[数学公式渲染](../../user/markdown.md#math-equations)限制，以处理更复杂的数学表达式。
  - 使用像素值或百分比精确控制[图片尺寸](../../user/markdown.md#change-image-or-video-dimensions)，更好地管理内容布局。
- **增强的编辑器体验**：
  - 按 Enter/Return 键时自动继续列表。
  - 使用键盘快捷键将文本向左或向右移动。
  - 使用描述列表语法创建清晰的术语-定义对。
  - 灵活调整视频宽度。
- **更好的内容组织**：
  - 通过自动展开的[摘要快速视图](../../user/markdown.md#show-item-summary)（在 URL 中添加 `+s`）更轻松地导航内容。
  - 自动渲染引用的[议题标题](../../user/markdown.md#show-item-title)（在 URL 中添加 `+`）。
  - 使用 [`include` 语法](../../user/markdown.md#includes)模块化地组织内容。
  - 使用[警告框](../../user/markdown.md#alerts)创建视觉上独特的提示和警告。

这些改进使极狐GitLab Flavored Markdown 对于创建和维护文档的团队更加强大，同时在内容的呈现和组织方式上提供了更大的灵活性。

<a id="new-visualization-of-devops-performance-with-dora-metrics-across-projects"></a>

### 通过跨项目的 DORA 指标实现 DevOps 性能的全新可视化

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md#projects-by-dora-metric)

{{< /details >}}

我们很高兴推出**按 DORA 指标划分的项目**面板，这是[价值流仪表盘](https://www.youtube.com/watch?v=EA9Sbks27g4)的新增功能。此表格列出了顶级群组中的所有项目，并细分了[四项 DORA 指标](https://about.gitlab.com/solutions/value-stream-management/dora/#overview)。管理者可以使用此表格来识别高、中、低绩效项目。此信息还有助于做出数据驱动的决策，有效分配资源，并专注于提升软件交付速度、稳定性和可靠性的举措。

[DORA 指标](../../user/analytics/dora_metrics.md)在极狐GitLab 中开箱即用，现在结合[**DORA 表现者评分**面板](https://about.gitlab.com/blog/inside-dora-performers-score-in-gitlab-value-streams-dashboard/)，高管们可以自上而下地全面了解其组织的 DevOps 健康状况。

<a id="new-issues-look-now-in-beta"></a>

### 新议题外观现已进入测试阶段

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issues/_index.md)

{{< /details >}}

议题现在与史诗和任务共享一个通用框架，具有实时更新和工作流改进：

- **抽屉视图：** 从列表或看板中打开项目到一个抽屉中，无需离开当前上下文即可快速查看。顶部的按钮可让你展开到全页视图。
- **更改类型：** 使用“更改类型”操作在史诗、议题和任务之间转换类型（替代“提升为史诗”）。
- **开始日期：** 议题现在支持开始日期，使其功能与史诗和任务保持一致。
- **层级关系：** 完整的层次结构显示在标题上方和侧边栏的父级字段中。要管理关系，请使用新的[快速操作](../../user/project/quick_actions.md)命令 `/set_parent`、`/remove_parent`、`/add_child` 和 `/remove_child`。
- **控件：** 所有操作现在都可以从顶部菜单（垂直省略号）访问，该菜单在滚动时保持在粘性标题中可见。
- **开发：** 与议题或任务相关的所有开发项（合并请求、分支和功能标志）现在都整合在一个方便的统一列表中。
- **布局：** UI 改进在议题、史诗、任务和合并请求之间创造了更无缝的体验，帮助你更高效地导航工作流。
- **链接项：** 通过改进的链接选项在任务、议题和史诗之间创建关系。拖放以更改链接类型，并切换标签和已关闭项的可见性。

<a id="description-templates-for-epics-issues-tasks-objectives-and-key-results"></a>

### 史诗、议题、任务、目标和关键结果的描述模板

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/description_templates.md)

{{< /details >}}

现在，你可以通过工作项（史诗、任务、目标和关键结果）的描述模板来简化工作流并保持项目间的一致性。

这一强大的新增功能允许你创建标准化的模板，节省时间并确保每次创建新工作项时都包含所有关键信息。

<a id="change-the-severity-of-a-vulnerability"></a>

### 更改漏洞的严重性

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#change-or-override-vulnerability-severity)

{{< /details >}}

在对漏洞进行分类时，你需要根据组织的独特安全环境和风险承受能力灵活调整严重性级别。到目前为止，你只能依赖安全扫描器分配的默认严重性级别，这可能无法准确反映你特定环境的风险级别。

现在，你可以手动更改特定漏洞实例的严重性，以更好地符合组织的安全需求。这使你能够：

- 将任何漏洞的严重性级别调整为**严重**、**高**、**中**、**低**、**信息**或**未知**。
- 从漏洞报告一次性更改多个漏洞的严重性。
- 通过视觉指示器轻松识别哪些漏洞具有自定义严重性级别。

所有严重性更改都会在漏洞历史和审计事件中跟踪，并且只能由项目中至少具有维护者角色的团队成员或具有 `admin_vulnerability` 权限的自定义角色覆盖。此功能为安全团队在漏洞优先级排序方面提供了更大的灵活性和控制力。

<a id="agentic-core"></a>

## Agentic Core

<a id="gitlab-duo-chat-is-now-resizable"></a>

### 极狐GitLab Duo Chat 现在可调整大小

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/_index.md#use-gitlab-duo-chat-in-the-gitlab-ui)

{{< /details >}}

在极狐GitLab UI 中，你现在可以调整 Duo Chat 抽屉的大小。这使得查看代码输出或在使用极狐GitLab 后台工作时保持 Chat 打开变得更加容易。

<a id="manage-multiple-conversations-in-gitlab-duo-chat"></a>

### 在极狐GitLab Duo Chat 中管理多个会话

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/_index.md#have-multiple-conversations)

{{< /details >}}

在极狐GitLab Duo Chat 中跨不同主题保持上下文现在变得更加容易，这得益于多个会话功能。你可以创建新会话、浏览会话历史记录并在会话之间切换。

以前，开始一个新会话意味着丢失现有聊天的上下文。现在，你可以管理不同主题的多个会话。每个会话都保持自己的上下文，例如，你可以在一个会话中就代码解释提出后续问题，同时在另一个会话中准备工作计划。

当你需要重新查看之前的讨论时，选择新的聊天历史图标即可查看所有最近的会话。会话会自动按最近活动排序，方便你从上次中断的地方继续。

为保护你的隐私，30 天无活动的会话将被自动删除，你也可以随时手动删除任何会话。

此功能目前仅在 JihuLab.com 的 Web UI 上可用。它不适用于极狐GitLab 私有化部署实例，也不适用于 IDE 集成。

请在议题 [526013](https://gitlab.com/gitlab-org/gitlab/-/issues/526013) 中与我们分享你的体验。

<a id="select-models-for-ai-powered-features-on-gitlab-duo-self-hosted"></a>

### 为极狐GitLab Duo 自托管上的 AI 功能选择模型

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#select-a-self-hosted-model-for-a-feature)

{{< /details >}}

在极狐GitLab Duo 自托管上，你现在可以为私有化部署实例上的每个极狐GitLab Duo Chat 子功能选择单独的受支持模型。Chat 子功能的模型选择和配置现已进入测试阶段。

要留下反馈，请访问议题 [524175](https://gitlab.com/gitlab-org/gitlab/-/issues/524175)。

<a id="ai-impact-dashboard-available-on-gitlab-duo-self-hosted-code-suggestions"></a>

### AI 影响仪表盘现可用于极狐GitLab Duo 自托管代码建议

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/analytics/duo_and_sdlc_trends.md)

{{< /details >}}

你现在可以在私有化部署实例上使用 AI 影响仪表盘与极狐GitLab Duo 自托管代码建议，帮助你了解极狐GitLab Duo 对生产力的影响。AI 影响仪表盘在极狐GitLab Duo 自托管上处于测试阶段，你可以将此功能与你的私有化部署实例以及 Visual Studio Code、Microsoft Visual Studio、JetBrains 和 Neovim IDE 一起使用。

使用 AI 影响仪表盘将 AI 使用趋势与前置时间、周期时间、DORA 和漏洞等指标进行比较。这使你能够衡量使用极狐GitLab Duo 自托管在端到端工作流中节省了多少时间，同时专注于业务成果而非开发者活动。

请在议题 [456105](https://gitlab.com/gitlab-org/gitlab/-/issues/456105) 中留下对 AI 影响仪表盘的反馈。

<a id="meta-llama-3-models-available-for-gitlab-duo-self-hosted-code-suggestions-and-chat"></a>

### Meta Llama 3 模型可用于极狐GitLab Duo 自托管代码建议和 Chat

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models)

{{< /details >}}

你现在可以将选定的 Meta Llama 3 模型与极狐GitLab Duo 自托管一起使用。这些模型在极狐GitLab Duo 自托管上处于测试阶段，用于支持极狐GitLab Duo Chat 和代码建议。

请在议题 [523912](https://gitlab.com/gitlab-org/gitlab/-/issues/523917) 中留下关于将这些模型与极狐GitLab Duo 自托管一起使用的反馈。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="timestamps-of-when-placeholder-users-were-created"></a>

### 占位用户创建时间的时间戳

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/import/mapping/post_migration_mapping.md#placeholder-user-attributes)

{{< /details >}}

以前，当你导入群组或项目时，无法看到[占位用户](../../user/import/mapping/post_migration_mapping.md#placeholder-users)的创建时间。
在此版本中，我们添加了时间戳，以便你可以跟踪迁移进度并在出现问题时进行故障排查。

<a id="bulk-edit-to-do-items"></a>

### 批量编辑待办事项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/todos.md#bulk-edit-to-do-items)

{{< /details >}}

你现在可以通过我们改进的批量编辑功能高效管理你的待办事项列表。选择多个待办事项，一次性将它们标记为已完成或延后，让你更好地控制任务，并以更少的精力保持条理。

<a id="snooze-to-do-items"></a>

### 延后待办事项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/todos.md#snooze-to-do-items)

{{< /details >}}

你现在可以在待办事项列表中延后通知，允许你暂时隐藏项目并专注于当前最重要的事项。无论你需要集中精力一小时还是想明天再处理某项任务，你都可以精细控制通知何时重新出现，帮助你更有效地管理工作流。

<a id="request-reassignment-by-using-a-csv-file"></a>

### 使用 CSV 文件请求重新分配

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/import/mapping/reassignment.md#request-reassignment-by-using-a-csv-file)

{{< /details >}}

在此版本中，用户贡献映射现在支持通过 CSV 文件进行批量重新分配。
如果你拥有大量用户和许多占位用户，具有所有者角色的群组成员可以：

1. 下载预填充的 CSV 模板。
1. 添加来自目标实例的极狐GitLab 用户名或公共电子邮件。
1. 上传完成的文件以一次性重新分配所有贡献。

此方法消除了通过 UI 进行繁琐的手动重新分配。
为了进一步简化大规模迁移，现在也提供了基于 CSV 的重新分配的 API 支持。

<a id="new-navigation-experience-for-projects-in-your-work"></a>

### “你的工作”中项目的新导航体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/working_with_projects.md)

{{< /details >}}

我们很高兴地宣布对**你的工作**中的项目概览进行了重大改进，旨在简化你发现和访问项目的方式。此更新引入了更直观的基于选项卡的导航系统，更好地反映了用户与项目交互的方式。

- 新的**已贡献**选项卡（原为**你的**）现在显示你贡献过的所有项目，包括你的个人项目，让你更容易跟踪开发活动。
- 通过**个人**选项卡更快地找到你的个人项目，该选项卡现在突出显示在主导航中。
- 通过**成员**选项卡（原为**全部**）访问团队项目，显示你拥有成员资格的所有项目。
- **未激活**选项卡（原为**待删除**）现在提供归档项目和待删除项目的全面视图。

此外，如果你拥有适当的权限，现在可以直接从**你的工作**项目概览中编辑或删除项目。
这些变化反映了我们致力于创造更高效、更用户友好的极狐GitLab 体验。新布局帮助你专注于对工作最重要的项目，减少在不同项目类别之间导航所花费的时间。

我们重视你对此更新的反馈！加入史诗 [16662](https://gitlab.com/groups/gitlab-org/-/epics/16662) 的讨论，分享你对新导航系统的体验。

<a id="improved-project-creation-permission-settings"></a>

### 改进的项目创建权限设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/settings/visibility_and_access_controls.md#define-which-roles-can-create-projects)

{{< /details >}}

我们改进了项目创建权限设置，使其更清晰、更直观，并与我们的安全原则保持一致。改进的设置包括：

- 将“默认项目创建保护”下拉菜单重命名为“项目创建所需的最低角色”，以清晰反映该设置的用途。
- 将“开发者 + 维护者”下拉选项重命名为“开发者”，以保持平台一致性。
- 将下拉选项从最严格到最宽松的访问级别重新排序。

这些更改使你更容易理解和配置哪些角色可以在群组中创建项目，帮助管理员更自信地执行适当的访问控制。

感谢 [@yasuk](https://gitlab.com/yasuk) 的社区贡献！

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="dependency-scanning-support-for-pub-dart-package-manager"></a>

### 对 pub (Dart) 包管理器的依赖项扫描支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers)

{{< /details >}}

依赖项扫描已添加对 pub（Dart 的官方包管理器）的支持。此支持已添加到我们的依赖项扫描[最新模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.latest.gitlab-ci.yml)和 [CI/CD 组件](https://gitlab.com/explore/catalog/components/dependency-scanning)中。

此新增功能来自我们的一位用户 Alexandre Laroche 的社区贡献。极狐GitLab 组合分析团队感谢这一改进我们产品的贡献，非常感谢 Alexandre。如果你有兴趣了解更多关于为极狐GitLab 做贡献的信息，请查看我们的[社区贡献计划](https://about.gitlab.com/community/contribute/)。

<a id="select-a-compliance-framework-as-default-from-the-dropdown-list-on-the-frameworks-page"></a>

### 从框架页面的下拉列表中选择默认合规框架

{{< details >}}
- Tier: 旗舰版，专业版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_frameworks_report.md#set-and-remove-a-compliance-framework-as-default) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/181500)

{{< /details >}}

用户可以在极狐GitLab 合规中心设置默认合规框架，该框架将应用于在该群组中创建的所有新项目和导入项目。默认合规框架带有 **默认** 标签，方便用户识别。

为了更便捷地将合规框架设为默认，我们正在引入一项新功能：用户可以在顶级群组合规中心的框架列表页面，通过框架下拉列表将框架设为默认。此功能在子群组或项目的合规中心中不可用。

<a id="ignore-specific-revisions-in-git-blame"></a>

### 在 Git Blame 中忽略特定修订

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/files/git_blame.md#ignore-specific-revisions)

{{< /details >}}

在浏览代码仓的历史记录时，有些提交可能与项目中的有意义变更无关。这种情况可能发生在：

- 重构时，您在不改变功能的前提下更换了库。
- 实施需要标准化整个代码库的代码格式化工具或代码检查工具时。

当您使用 `blame` 查看项目历史时，这类提交会使理解变更变得困难。Git 支持通过项目中的 `.git-blame-ignore-revs` 文件来标识这些提交。极狐GitLab 现允许您在“Blame 偏好设置”下拉列表中切换 blame 视图，以显示或隐藏这些特定修订，从而更轻松地理解项目历史。

<a id="path-exclusions-for-codeowners"></a>

### CODEOWNERS 的路径排除

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/codeowners/reference.md#exclusion-patterns)

{{< /details >}}

当团队配置 `CODEOWNERS` 文件时，通常会为路径和文件类型包含广泛的匹配模式。如果您的文档、自动化构建文件或其他模式不需要指定代码所有者，这些宽泛配置可能会带来问题。

您现在可以在 `CODEOWNERS` 文件中配置路径排除规则，以忽略特定路径。当您希望排除特定文件或路径，使其无需代码所有者审批时，这非常有用。

<a id="configurable-squash-settings-in-branch-rules"></a>

### 分支规则中可配置的压缩设置

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/branches/branch_rules.md#edit-squash-commits-option)

{{< /details >}}

不同的 Git 工作流在分支间合并时，需要不同的策略来处理提交。在之前的极狐GitLab 版本中，您只能为合并时是否压缩提交以及强制执行的力度设置单一策略。这种设置可能容易出错，或要求开发者针对不同分支目标做出特定选择以遵循项目约定。

您现在可以通过分支规则为每个受保护分支配置压缩设置。例如，您可以：

- 当合并功能分支到开发分支时要求压缩，以保持历史记录整洁。
- 当合并开发分支到主分支时禁用压缩，以保留完整的提交历史。

这种灵活性确保了整个项目中一致的提交历史，同时兼顾了工作流中每个分支的独特需求，无需开发者手动干预。

<a id="wider-distribution-for-token-expiration-notifications"></a>

### 更广泛的令牌到期通知分发

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/manage.md#expiry-emails-for-group-and-project-access-tokens)

{{< /details >}}

此前，访问令牌到期通知邮件仅发送给令牌所在群组和项目的直接成员。现在，如果启用了相关设置，这些通知也会发送给继承的群组和项目成员。这种更广泛的分发有助于在令牌到期前更轻松地进行管理。

<a id="handling-of-needs-statements-in-pipeline-execution-policies-for-compliance"></a>

### 为合规处理流水线执行策略中的 `needs` 语句

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/pipeline_execution_policies.md#pipeline_execution_policy-schema)

{{< /details >}}

为加强对流水线执行的控制，现在要求在 `.pipeline-policy-pre` 保留阶段中强制执行的任务必须完成后，后续阶段的任务才能开始，无论该任务是否定义了 `needs` 语句。此前，定义在 `.pipeline-policy-pre` 阶段的任务以及后续流水线中带有 `needs` 语句的任务都会在流水线执行时立即启动。通过此增强，后续阶段的任务必须等待 `.pipeline-policy-pre` 完成后才能启动，这有助于您在安全策略中强制实施有序执行并确保合规。

我们的客户依赖保留阶段在开发者任务运行之前强制执行合规和安全检查。一个常见用例是强制执行一个安全检查，如果检查未通过则使整个流水线失败。允许任务乱序运行可能会绕过此强制措施并削弱策略意图。此改进为您提供了一种更一致的合规执行方法。

要在不覆盖 `needs` 行为的情况下在流水线开头注入任务，可以将任务配置为使用我们在 17.9 中引入的新自定义阶段功能中的自定义阶段。

<a id="authenticate-to-private-pages-with-an-access-token"></a>

### 使用访问令牌认证私有 Pages

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/pages_access_control.md#authenticate-with-an-access-token)

{{< /details >}}

您现在可以通过编程方式使用访问令牌认证私有极狐GitLab Pages 站点，从而更轻松地自动化与 Pages 内容的交互。此前，访问受限制的 Pages 站点需要通过极狐GitLab UI 进行交互式认证。

这一强大的增强功能在保持安全性的同时提高了生产力，为开发者在与私有 Pages 内容交互和分发时提供了更大的灵活性。

<a id="new-insights-into-gitlab-duo-code-suggestions-and-gitlab-duo-chat-trends"></a>

### 极狐GitLab Duo 代码建议和极狐GitLab Duo Chat 趋势的新洞察

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 附加功能：极狐GitLab Duo 企业版
- Links: [文档](../../user/analytics/duo_and_sdlc_trends.md)

{{< /details >}}

AI 影响力仪表盘上的 AI 对比指标面板现在为 极狐GitLab Duo 代码建议接受率和 极狐GitLab Duo Chat 用量（环比百分比）提供月度环比跟踪。这些新的趋势洞察与现有的 代码建议 和 Duo Chat 卡片相辅相成，后者提供了这些指标的 30 天快照。
通过这些额外指标，管理者可以更好地衡量 AI 对其软件开发流程的影响，并通过将代码建议接受率和 Duo Chat 用量与其他随时间变化的 SDLC 指标进行比较来识别模式。

<a id="docker-hub-authentication-for-the-dependency-proxy"></a>

### 依赖代理的 Docker Hub 认证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/dependency_proxy/_index.md#authenticate-with-docker-hub)

{{< /details >}}

极狐GitLab 容器镜像依赖代理现支持通过 Docker Hub 认证，帮助您避免因速率限制导致的流水线失败，并让您可以访问私有镜像。

自 2025 年 4 月 1 日起，Docker Hub 将对未认证用户执行更严格的拉取限制（每个 IPv4 地址或 IPv6 /64 子网每 6 小时 100 次）。没有认证，一旦达到这些限制，您的流水线可能会失败。

通过此版本，您可以使用 Docker Hub 凭据、[个人访问令牌](https://docs.docker.com/security/for-developers/access-tokens/) 或 [组织访问令牌](https://docs.docker.com/security/for-admins/access-tokens/) 通过 GraphQL API 配置 Docker Hub 认证。UI 配置支持将在 极狐GitLab 17.11 中提供。

<a id="package-registry-adds-audit-events"></a>

### 软件包仓库新增审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/audit_event_types.md)

{{< /details >}}

软件包仓库操作现记录为审计事件，以便团队可以跟踪软件包的发布或删除情况，满足合规要求。

在此版本之前，没有内置的方法来跟踪谁发布了软件包或做出了更改。团队必须创建自己的跟踪系统或手动记录软件包更改，以维护这些活动的日志。现在，每个审计事件都会显示谁做出了更改、何时发生的更改、他们是如何认证的，以及软件包中确切发生了什么更改。

项目的审计事件存储在群组命名空间或项目本身中（供个人项目所有者查看）。群组可以关闭审计事件来管理存储需求。

<a id="sort-access-tokens-in-credentials-inventory"></a>

### 在凭证清单中排序访问令牌

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/credentials_inventory.md)

{{< /details >}}

您现在可以在凭证清单中按所有者、创建日期和最后使用日期对个人、项目和群组访问令牌进行排序。这有助于您更快速地定位和识别访问令牌。
感谢 [Chaitanya Sonwane](https://jihulab.com/chaitanyason9) 的贡献！

<a id="identify-and-revoke-tokens-with-token-information-api"></a>

### 使用令牌信息 API 识别和吊销令牌

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../api/admin/token.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/15777)

{{< /details >}}

极狐GitLab 管理员现在可以使用统一的 API 来识别和吊销令牌。此前，管理员必须使用与特定令牌类型相关的端点。该 API 允许无论类型如何都进行吊销。有关支持的令牌类型列表，请参阅 [令牌信息 API](../../api/admin/token.md)。

感谢 [Nicholas Wittstruck](https://jihulab.com/nwittstruck) 和西门子团队的贡献！

<a id="configurable-token-duration-with-gitlab-oidc-provider"></a>

### 使用 极狐GitLab OIDC 提供程序配置令牌持续时间

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/auth/oidc.md#configure-a-custom-duration-for-id-tokens)

{{< /details >}}

当使用 极狐GitLab 作为 OpenID Connect (OIDC) 提供程序时，您现在可以通过 `id_token_expiration` 属性配置 ID 令牌的持续时间。此前，ID 令牌的固定过期时间为 120 秒。

感谢 [Henry Sachs](https://jihulab.com/DerAstronaut) 的贡献！

<a id="map-omniauth-profile-attributes-to-user"></a>

### 将 OmniAuth 配置文件属性映射到用户

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../integration/omniauth.md#keep-omniauth-user-profiles-up-to-date)

{{< /details >}}

您现在可以将 OmniAuth 身份提供程序 (IdP) 中的组织和职位配置文件属性映射到用户的 极狐GitLab 个人资料。这使得 IdP 成为这些属性的单一事实来源，用户无法再更改它们。

<a id="extended-webhook-triggers-for-expiring-tokens"></a>

### 扩展的即将到期令牌的 Webhook 触发器

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/manage.md#add-additional-webhook-triggers-for-group-access-token-expiration)

{{< /details >}}

您现在可以在项目或群组访问令牌到期前 60 天和 30 天触发 Webhook 事件。此前，这些 Webhook 事件仅在到期前 7 天触发。这是一个可选设置，与现有的到期令牌电子邮件通知计划相匹配。

<a id="gitlab-runner-1710"></a>

### GitLab Runner 17.10

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了 GitLab Runner 17.10！GitLab Runner 是高度可扩展的构建代理，它运行您的 CI/CD 任务并将结果发送回 极狐GitLab 实例。GitLab Runner 与 极狐GitLab CI/CD 协同工作，后者是 极狐GitLab 内置的开源持续集成服务。

#### 新功能

- [在使用实例前进行 Autoscaler 执行器健康检查](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/38271)
- [扩展 Docker 执行器卷](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/38249)
- [为服务添加 Docker 执行器设备添加配置](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/6208)

#### 缺陷修复

- [Windows `gitlab-runner-helper` 镜像因 `/opt/step-runner` 路径的无效卷规范而失败](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/38632)
- [GitLab Runner 17.7.0 及更高版本中 RPM 软件包的镜像仓库镜像功能无法正常工作](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/38409)
- [在 极狐GitLab CI/CD 中运行 `git submodule update --remote` 返回错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/359825)

所有变更的列表请见 GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/17-10-stable/CHANGELOG.md)。