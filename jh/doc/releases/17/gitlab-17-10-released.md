---
stage: Release Notes
group: Monthly Release
date: 2025-03-20
title: "极狐GitLab 17.10 发布说明"
description: "极狐GitLab 17.10 发布，Duo Code Review 进入测试版"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 3 月 20 日，极狐GitLab 17.10 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="duo-code-review-available-in-beta"></a>

### Duo Code Review 进入测试版

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)

{{< /details >}}

代码评审是软件开发中的一项核心活动。它确保对项目的贡献能够维持并提升代码质量和安全性，同时也是工程师获得指导和反馈的途径。它也是软件开发过程中最耗时的活动之一。

Duo Code Review 是代码评审流程的下一步演进。

Duo Code Review 可以加速您的开发流程。当它对您的合并请求执行初步评审时，可以帮助识别潜在缺陷并提出进一步改进建议——其中一些建议您可以直接在浏览器中应用。在引入其他人员之前，使用它来迭代和改进您的变更。

**立即体验：**

- 要立即开始代码评审，请将`@GitLabDuo` 作为审核人添加到您的合并请求中。
- 要细化对您变更的反馈，请在评论中提及`@GitLabDuo`。

您可以在史诗 [13008](https://gitlab.com/groups/gitlab-org/-/epics/13008) 及相关子史诗中跟踪 Duo Code Review 的未来进展。反馈可在议题 [517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386)中提供。

<a id="root-cause-analysis-available-on-gitlab-duo-self-hosted"></a>

### 根因分析现已在极狐GitLab Duo 自部署版本上可用

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md#feature-versions-and-status) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13759)

{{< /details >}}

您现在可以在极狐GitLab Duo 自部署版本上使用[极狐GitLab Duo 根因分析](https://about.gitlab.com/blog/developing-gitlab-duo-blending-ai-and-root-cause-analysis-to-fix-ci-cd/)。此功能在使用极狐GitLab Duo 自部署版本的极狐GitLab 私有化部署实例上处于测试阶段，支持 Mistral、Anthropic 和 OpenAI GPT 模型系列。

借助极狐GitLab Duo 自部署版本上的根因分析，您可以更快地排查 CI/CD流水线中的失败作业，而无需牺牲数据主权。根因分析会分析失败的作业日志，快速确定作业失败的根本原因，并为您建议修复方案。

注意：此功能目前功能有限，完整功能计划在 17.11 中推出。更多信息请参阅
[故障排除文档](../../administration/gitlab_duo_self_hosted/troubleshooting.md#feature-not-accessible-or-feature-button-not-visible)
以及议题 [527128](https://gitlab.com/gitlab-org/gitlab/-/issues/527128)。

请在[议题 523912](https://gitlab.com/gitlab-org/gitlab/-/issues/523912)中留下您对极狐GitLab Duo 自部署版本根因分析的反馈。

<a id="gitlab-query-language-views-beta"></a>

### GitLab 查询语言视图测试版

<!-- categories: Wiki, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/glql/_index.md#embedded-views) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14938)

{{< /details >}}

此前，在极狐GitLab 中跟踪和理解进行中的工作需要在多个位置之间导航，降低了团队效率并耗费了宝贵时间。

此版本引入了 GitLab 查询语言（GLQL）视图测试版，让您可以直接在现有工作流中创建动态、实时的进度跟踪。

GLQL 视图将实时数据查询嵌入 Wiki 页面、史诗描述、议题评论和合并请求的 Markdown 代码块中。

GLQL 视图此前作为实验功能提供，现已进入测试阶段，支持跨关键字段（包括指派人、作者、标记和里程碑）使用逻辑表达式和运算符进行复杂筛选。您可以将视图自定义为表格或列表形式，控制显示哪些字段，并设置结果数量限制，从而为团队创建聚焦且可操作的洞察。

团队现在可以在保持上下文的同时访问所需信息，建立共同理解并改善协作——所有这些都无需离开当前工作流。

在继续增强此功能的过程中，[我们欢迎您对 GLQL 视图提出反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/509791)。

<a id="enhanced-markdown-experience"></a>

### 增强的 Markdown 体验

<!-- categories: Markdown -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/7654)

{{< /details >}}

极狐GitLab 风格 Markdown 已获得多项强大改进：

- **改进的数学公式和图片处理**：
  - 在您的群组或私有化部署实例中禁用[数学公式渲染](../../user/markdown.md#math-equations)限制，以处理更复杂的数学表达式。
  - 使用像素值或百分比精确控制[图片尺寸](../../user/markdown.md#change-image-or-video-dimensions)，以更好地管理内容布局。
- **增强的编辑器体验**：
  - 按 Enter/Return 时自动继续列表。
  - 使用键盘快捷键将文本向左或向右移动。
  - 使用描述列表语法创建清晰的术语-定义对。
  - 灵活调整视频宽度。
- **更好的内容组织**：
  - 通过自动展开的[摘要快速视图](../../user/markdown.md#show-item-summary)（在 URL 中添加`+s`）更轻松地浏览内容。
  - 自动渲染引用的[议题标题](../../user/markdown.md#show-item-title)（在 URL 中添加`+`）。
  - 使用 [`include` 语法](../../user/markdown.md#includes)模块化地组织内容。
  - 使用[警告框](../../user/markdown.md#alerts)创建视觉上醒目的提示和警告。

这些改进使极狐GitLab 风格 Markdown 对于创建和维护文档的团队来说更加强大，同时在内容呈现和组织方式上提供了更大的灵活性。

<a id="new-visualization-of-devops-performance-with-dora-metrics-across-projects"></a>

### 通过跨项目 DORA 指标实现 DevOps 性能的全新可视化

<!-- categories: Value Stream Management, DORA Metrics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md#projects-by-dora-metric) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/408516)

{{< /details >}}

“按 DORA 指标划分的项目”面板以表格列出了顶级群组中的所有项目，并按[四项 DORA 指标](https://about.gitlab.com/solutions/value-stream-management/dora/#overview)进行了细分。管理者可以使用此表格识别高、中、低绩效项目。这些信息还有助于做出数据驱动的决策、有效分配资源，并专注于提升软件交付速度、稳定性和可靠性的举措。

[DORA 指标](../../user/analytics/dora_metrics.md)在极狐GitLab 中开箱即用，现在结合 [**DORA Performers 评分**面板](https://about.gitlab.com/blog/inside-dora-performers-score-in-gitlab-value-streams-dashboard/)，高管们可以自上而下全面了解其组织的 DevOps 健康状况。

<a id="new-issues-look-now-in-beta"></a>

### 新议题外观现已进入测试版

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issues/_index.md)

{{< /details >}}

议题现在与史诗和任务共享一个通用框架，具有实时更新和工作流改进：

- **抽屉视图：**在抽屉中打开列表或看板中的条目，无需离开当前上下文即可快速查看。顶部的按钮可让您展开到全页视图。
- **更改类型：**使用“更改类型”操作在史诗、议题和任务之间转换类型（取代“升级为史诗”）。
- **开始日期：**议题现在支持开始日期，使其功能与史诗和任务保持一致。
- **层级关系：**完整层级显示在标题上方和侧边栏的父项字段中。要管理关系，请使用新的[快速操作](../../user/project/quick_actions.md)命令`/set_parent`、`/remove_parent`、`/add_child` 和 `/remove_child`。
- **控件：**所有操作现在都可以从顶部菜单（垂直省略号）访问，该菜单在滚动时仍会显示在粘性标题中。
- **开发：**与议题或任务相关的所有开发条目（合并请求、分支和功能标志）现在都整合在一个方便的列表中。
- **布局：**UI 改进在议题、史诗、任务和合并请求之间创造了更无缝的体验，帮助您更高效地导航工作流。
- **关联条目：**通过改进的关联选项在任务、议题和史诗之间创建关系。拖放即可更改关联类型，并切换标记和已关闭条目的可见性。

<a id="description-templates-for-epics-issues-tasks-objectives-and-key-results"></a>

### 史诗、议题、任务、目标和关键结果的描述模板

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/description_templates.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16088)

{{< /details >}}

您现在可以通过工作项（史诗、任务、目标和关键结果）的描述模板来简化工作流并保持项目间的一致性。

这一强大的新增功能允许您创建标准化模板，节省时间并确保每次创建新工作项时都包含所有关键信息。

<a id="change-the-severity-of-a-vulnerability"></a>

### 更改漏洞严重程度

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#change-or-override-vulnerability-severity) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/16157)

{{< /details >}}

在排查漏洞时，您需要根据组织独特的安全环境和风险承受能力灵活调整严重程度级别。此前，您只能依赖安全扫描器分配的默认严重程度级别，这些级别可能无法准确反映您特定环境的风险水平。

现在，您可以手动更改特定漏洞实例的严重程度，以更好地符合您组织的安全需求。这使您可以：

- 将任何漏洞的严重程度级别调整为**严重**、**高**、**中**、**低**、**信息**或**未知**。
- 从漏洞报告一次性更改多个漏洞的严重程度。
- 通过视觉指示器轻松识别哪些漏洞具有自定义严重程度级别。

所有严重程度更改都会记录在漏洞历史和审计事件中，并且只能由项目中至少具有维护者角色的团队成员或具有 `admin_vulnerability` 权限的自定义角色覆盖。此功能为安全团队在漏洞优先级排序方面提供了更大的灵活性和控制力。

<a id="agentic-core"></a>

## AI 功能

<a id="gitlab-duo-chat-is-now-resizable"></a>

### 极狐GitLab Duo Chat 现在可调整大小

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/_index.md#use-gitlab-duo-chat-in-the-gitlab-ui) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/499849)

{{< /details >}}

在极狐GitLab UI 中，您现在可以调整 Duo Chat 抽屉的大小。这样可以更轻松地查看代码输出，或在后台使用极狐GitLab 时保持 Chat 打开。

<a id="manage-multiple-conversations-in-gitlab-duo-chat"></a>

### 在极狐GitLab Duo Chat 中管理多个对话

<!-- categories: Duo Chat -->

{{< details >}}

- 交付方式: JihuLab.com
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/_index.md#have-multiple-conversations) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16108)

{{< /details >}}

借助多个对话，在极狐GitLab Duo Chat 中跨不同主题保持上下文现在更加容易。您可以创建新对话、浏览对话历史并在对话之间切换。

此前，开始新对话意味着丢失现有聊天的上下文。现在，您可以管理不同主题的多个对话。每个对话都保持自己的上下文，例如，您可以在一个对话中追问代码解释，同时在另一个对话中准备工作计划。

当您需要回顾之前的讨论时，选择新的聊天历史图标即可查看所有最近的对话。对话会自动按最近活动排序，让您可以轻松地从上次中断的地方继续。

为保护您的隐私，30 天无活动的对话会自动删除，您也可以随时手动删除任何对话。

此功能目前仅在 JihuLab.com 的 Web UI 中可用。它不适用于极狐GitLab 私有化部署实例，也不适用于 IDE 集成。

请在[议题 526013](https://gitlab.com/gitlab-org/gitlab/-/issues/526013)中与我们分享您的体验。

<a id="select-models-for-ai-powered-features-on-gitlab-duo-self-hosted"></a>

### 在极狐GitLab Duo 自部署版本上为 AI 驱动功能选择模型

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#select-a-self-hosted-model-for-a-feature) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/524174)

{{< /details >}}

在极狐GitLab Duo 自部署版本上，您现在可以在私有化部署实例上为每个极狐GitLab Duo Chat 子功能选择单独支持的模型。Chat 子功能的模型选择和配置现已进入测试阶段。

要留下反馈，请访问[议题 524175](https://gitlab.com/gitlab-org/gitlab/-/issues/524175)。

<a id="ai-impact-dashboard-available-on-gitlab-duo-self-hosted-code-suggestions"></a>

### AI 影响仪表板现已在极狐GitLab Duo 自部署版本代码建议上可用

<!-- categories: Self-Hosted Models, Value Stream Management, DORA Metrics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/analytics/duo_and_sdlc_trends.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523807)

{{< /details >}}

您现在可以在私有化部署实例上使用 AI 影响仪表板与极狐GitLab Duo 自部署版本代码建议，帮助您了解极狐GitLab Duo 对生产力的影响。AI 影响仪表板在极狐GitLab Duo 自部署版本上处于测试阶段，您可以在私有化部署实例以及 Visual Studio Code、Microsoft Visual Studio、JetBrains 和 Neovim IDE 中使用此功能。

使用 AI 影响仪表板将 AI 使用趋势与前置时间、周期时间、DORA 和漏洞等指标进行比较。这使您可以衡量使用极狐GitLab Duo 自部署版本在端到端工作流中节省了多少时间，同时专注于业务成果而非开发者活动。

请在[议题 456105](https://gitlab.com/gitlab-org/gitlab/-/issues/456105)中留下您对 AI 影响仪表板的反馈。

<a id="meta-llama-3-models-available-for-gitlab-duo-self-hosted-code-suggestions-and-chat"></a>

### Meta Llama 3 模型可用于极狐GitLab Duo 自部署版本代码建议和 Chat

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523917)

{{< /details >}}

您现在可以在极狐GitLab Duo 自部署版本上使用部分 Meta Llama 3 模型。这些模型在极狐GitLab Duo 自部署版本上处于测试阶段，用于支持极狐GitLab Duo Chat 和代码建议。

请在[议题 523912](https://gitlab.com/gitlab-org/gitlab/-/issues/523917)中留下您对在极狐GitLab Duo 自部署版本上使用这些模型的反馈。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="timestamps-of-when-placeholder-users-were-created"></a>

### 占位用户创建时间戳

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/import/mapping/post_migration_mapping.md#placeholder-user-attributes) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/507297)

{{< /details >}}

此前，当您导入群组或项目时，无法看到[占位用户](../../user/import/mapping/post_migration_mapping.md#placeholder-users)的创建时间。
在此版本中，我们添加了时间戳，以便您可以跟踪迁移进度并在出现问题时进行排查。

<a id="bulk-edit-to-do-items"></a>

### 批量编辑待办事项

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/todos.md#bulk-edit-to-do-items) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/16564)

{{< /details >}}

您现在可以通过改进的批量编辑功能高效管理待办事项列表。选择多个待办事项并一次性将其标记为完成或稍后提醒，让您更好地控制任务，并以更少的精力保持井井有条。

<a id="snooze-to-do-items"></a>

### 稍后提醒待办事项

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/todos.md#snooze-to-do-items) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/17712)

{{< /details >}}

您现在可以在待办事项列表中稍后提醒通知，从而暂时隐藏条目并专注于当前最重要的事项。无论您是需要一小时集中精力，还是想明天再处理某项任务，您都可以精细控制通知重新出现的时间，帮助您更有效地管理工作流。

<a id="request-reassignment-by-using-a-csv-file"></a>

### 使用 CSV 文件请求重新分配

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/import/mapping/reassignment.md#request-reassignment-by-using-a-csv-file) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16765)

{{< /details >}}

在此版本中，用户贡献映射现在支持使用 CSV 文件进行批量重新分配。如果您拥有大量占位用户的庞大用户群，具有所有者角色的群组成员可以：

1. 下载预填的 CSV 模板。
1. 添加目标实例中的极狐GitLab 用户名或公开邮箱。
1. 上传填写完成的文件，一次性重新分配所有贡献。

此方法消除了通过 UI 进行繁琐的手动重新分配。为进一步简化大规模迁移，现在也提供了基于 CSV 重新分配的 API 支持。

<a id="new-navigation-experience-for-projects-in-your-work"></a>

### “您的工作”中项目的新导航体验

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/465889)

{{< /details >}}

我们很高兴地宣布对**您的工作**中的项目概览进行了重大改进，旨在简化您发现和访问项目的方式。此更新引入了更直观的基于标签页的导航系统，更好地反映了用户与项目交互的方式。

- 新的**已贡献**标签页（原**您的**）现在显示您贡献过的所有项目，包括您的个人项目，让您更轻松地跟踪开发活动。
- 通过**个人**标签页更快地找到您的个人项目，该标签页现在突出显示在主导航中。
- 通过**成员**标签页（原**全部**）访问团队项目，显示您拥有成员资格的所有项目。
- **非活跃**标签页（原**待删除**）现在提供已归档项目和待删除项目的全面视图。

此外，如果您拥有相应权限，现在可以直接从**您的工作**项目概览中编辑或删除项目。这些变化体现了我们致力于打造更高效、更用户友好的极狐GitLab 体验的承诺。新布局帮助您专注于对工作最重要的项目，减少在不同项目类别之间导航所花费的时间。

我们非常重视您对此次更新的反馈！加入[史诗 16662](https://gitlab.com/groups/gitlab-org/-/epics/16662)中的讨论，分享您对新导航系统的体验。

<a id="improved-project-creation-permission-settings"></a>

### 改进的项目创建权限设置

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/visibility_and_access_controls.md#define-which-roles-can-create-projects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/507410)

{{< /details >}}

我们改进了项目创建权限设置，使其更加清晰、直观，并符合我们的安全原则。改进后的设置包括：

- 将“默认项目创建保护”下拉菜单重命名为“创建项目所需的最低角色”，以清晰反映该设置的用途。
- 将“开发者 + 维护者”下拉选项重命名为“开发者”，以保持平台一致性。
- 将下拉选项从最严格到最宽松的访问级别重新排序。

这些更改使您更容易理解和配置哪些角色可以在您的群组中创建项目，帮助管理员更有信心地实施适当的访问控制。

感谢 [@yasuk](https://gitlab.com/yasuk)的社区贡献！

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="dependency-scanning-support-for-pub-dart-package-manager"></a>

### 依赖扫描支持 pub（Dart）包管理器

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/342468)

{{< /details >}}

依赖扫描已添加对 pub（Dart 官方包管理器）的支持。此支持已添加到我们的依赖扫描[最新模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.latest.gitlab-ci.yml)和 [CI/CD 组件](https://gitlab.com/explore/catalog/components/dependency-scanning)中。

此新增功能来自我们的一位用户 Alexandre Laroche 的社区贡献。GitLab 组成分析团队感谢他为改进我们的产品所做的贡献，非常感谢 Alexandre。如果您有兴趣了解更多关于为 GitLab 做贡献的信息，请查看我们的[社区贡献计划](https://about.gitlab.com/community/contribute/)。

<a id="select-a-compliance-framework-as-default-from-the-dropdown-list-on-the-frameworks-page"></a>

### 在框架页面的下拉列表中选择默认合规框架

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版, 专业版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_frameworks_report.md#set-and-remove-a-compliance-framework-as-default) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181500)

{{< /details >}}

用户可以在极狐GitLab 合规中心设置默认合规框架，该框架将应用于在该群组中创建的所有新项目和导入项目。默认合规框架带有**默认**标记，以帮助用户识别它。

为了更轻松地将合规框架设置为默认，我们引入了让用户通过顶级群组合规中心框架列表页面上的框架下拉列表将框架设置为默认的功能。此功能不适用于子群组或项目的合规中心。

<a id="ignore-specific-revisions-in-git-blame"></a>

### 在 Git 追溯中忽略特定修订

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/files/git_blame.md#ignore-specific-revisions)

{{< /details >}}

在浏览代码仓库历史时，可能存在与项目中有意义的变更无关的提交。这可能发生在以下情况：

- 在不改变功能的情况下从一个库切换到另一个库的重构。
- 实施需要标准化整个代码库的代码格式化工具或代码检查工具。

当您使用 `blame` 查看项目历史时，这类提交会让您难以理解所发生的变更。Git 支持通过项目中的`.git-blame-ignore-revs` 文件来识别这些提交。极狐GitLab 现在允许您在“追溯偏好”下拉列表中切换追溯视图，以显示或隐藏这些特定修订，让您更轻松地理解项目历史。

<a id="path-exclusions-for-codeowners"></a>

### CODEOWNERS 的路径排除

<!-- categories: Source Code Management, Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/codeowners/reference.md#exclusion-patterns)

{{< /details >}}

当团队配置 `CODEOWNERS` 文件时，通常会为路径和文件类型包含宽泛的匹配模式。如果您的文档、自动化构建文件或其他模式不需要指定代码所有者，这些宽泛的配置可能会带来问题。

您现在可以配置 `CODEOWNERS` 文件的路径排除，以忽略某些路径。当您想要排除特定文件或路径，使其不需要代码所有者审批时，这非常有用。

<a id="configurable-squash-settings-in-branch-rules"></a>

### 分支规则中可配置的压缩设置

<!-- categories: Source Code Management, Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/branches/branch_rules.md#edit-squash-commits-option)

{{< /details >}}

不同的 Git 工作流在分支之间合并时需要不同的提交处理策略。在之前的极狐GitLab 版本中，您只能为合并时是否应压缩提交以及应强制执行的程度设置单一策略。这种设置可能容易出错，或者需要开发者针对不同的分支目标做出特定选择以遵循项目约定。

您现在可以通过分支规则为每个受保护分支配置压缩设置。例如，您可以：

- 在从 `feature` 分支合并到 `develop` 分支时要求压缩，以保持历史整洁。
- 在从 `develop` 分支合并到 `main` 分支时禁用压缩，以保持提交历史完整。

这种灵活性确保了整个项目提交历史的一致性，同时尊重工作流中每个分支的独特需求，且无需开发者手动干预。

<a id="wider-distribution-for-token-expiration-notifications"></a>

### 令牌过期通知的更广泛分发

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/manage.md#expiry-emails-for-group-and-project-access-tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/463016)

{{< /details >}}

此前，访问令牌过期通知邮件仅发送给令牌即将过期的群组和项目的直接成员。现在，如果启用了该设置，这些通知也会发送给继承的群组和项目成员。这种更广泛的分发使您更容易在令牌过期前进行管理。

<a id="handling-of-needs-statements-in-pipeline-execution-policies-for-compliance"></a>

### 合规流水线执行策略中 `needs` 语句的处理

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/pipeline_execution_policies.md#pipeline_execution_policy-schema) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/469256)

{{< /details >}}

为加强对流水线执行的控制，在`.pipeline-policy-pre` 保留阶段中强制执行的作业现在必须在后续阶段的作业开始之前完成，无论该作业是否定义了任何 `needs` 语句。此前，定义在`.pipeline-policy-pre` 阶段中的作业以及后续流水线中带有 `needs` 语句的作业都会在流水线执行时立即启动。通过此增强，后续阶段中的作业必须等待`.pipeline-policy-pre` 完成，然后才能启动任何其他没有依赖关系的作业，帮助您强制执行有序执行并确保安全策略中的合规性。

我们的客户依赖保留阶段在开发者作业运行之前强制执行合规和安全检查。一个常见的用例是强制执行一项安全或合规检查，如果检查未通过，则使整个流水线失败。允许作业无序运行可能会绕过此强制执行并削弱策略意图。此改进为您提供了一种更一致的合规执行方法。

要在不覆盖 `needs` 行为的情况下在流水线开头注入作业，请使用我们在 17.9 中引入的新自定义阶段功能，将作业配置为使用自定义阶段。

<a id="authenticate-to-private-pages-with-an-access-token"></a>

### 使用访问令牌对私有 Pages 进行身份验证

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/pages_access_control.md#authenticate-with-an-access-token)

{{< /details >}}

您现在可以使用访问令牌以编程方式对私有 GitLab Pages 站点进行身份验证，从而更轻松地自动与 Pages 内容交互。此前，访问受限的 Pages 站点需要通过极狐GitLab UI 进行交互式身份验证。

这一强大的增强功能在保持安全性的同时提高了生产力，为开发者在交互和分发私有 Pages 内容方面提供了更大的灵活性。

<a id="new-insights-into-gitlab-duo-code-suggestions-and-gitlab-duo-chat-trends"></a>

### 极狐GitLab Duo 代码建议和极狐GitLab Duo Chat 趋势的新洞察

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/analytics/duo_and_sdlc_trends.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/477246)

{{< /details >}}

AI 影响仪表板上的 AI 对比指标面板现在提供极狐GitLab Duo 代码建议接受率和极狐GitLab Duo Chat 使用量的环比（MoM）跟踪（MoM%）。这些新的趋势洞察补充了现有的 Duo 代码建议和 Duo Chat 磁贴，后者提供这些指标的 30 天快照。借助这些额外指标，管理者可以更好地衡量 AI 对其软件开发流程的影响，并通过将代码建议接受率和 Duo Chat 使用量与其他 SDLC 指标随时间进行比较来识别模式。

<a id="docker-hub-authentication-for-the-dependency-proxy"></a>

### 依赖代理的 Docker Hub 身份验证

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/dependency_proxy/_index.md#authenticate-with-docker-hub) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/331741)

{{< /details >}}

用于容器镜像的极狐GitLab 依赖代理现在支持 Docker Hub 身份验证，帮助您避免因速率限制导致的流水线失败，并让您能够访问私有镜像。

从 2025 年 4 月 1 日起，Docker Hub 将对未认证用户实施更严格的拉取限制（每个 IPv4 地址或 IPv6 /64 子网每 6 小时 100 次）。如果没有身份验证，一旦达到这些限制，您的流水线可能会失败。

在此版本中，您可以使用 Docker Hub 凭据、[个人访问令牌](https://docs.docker.com/security/access-tokens/)或[组织访问令牌](https://docs.docker.com/enterprise/security/access-tokens/)通过 GraphQL API 配置 Docker Hub 身份验证。UI 配置支持将在极狐GitLab 17.11 中提供。

<a id="package-registry-adds-audit-events"></a>

### 软件包仓库新增审计事件

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/329588)

{{< /details >}}

软件包仓库操作现在会记录为审计事件，以便团队在软件包发布或删除时进行跟踪，以满足合规要求。

在此版本之前，没有内置方法来跟踪谁发布或更改了软件包。团队必须创建自己的跟踪系统或手动记录软件包更改，以维护这些活动的日志。现在，每个审计事件都会显示谁做了更改、何时发生、他们如何通过身份验证，以及软件包中具体发生了什么变化。

项目的审计事件存储在群组命名空间中，或者对于单个项目所有者，存储在项目本身中。群组可以关闭审计事件以管理存储需求。

<a id="sort-access-tokens-in-credentials-inventory"></a>

### 在凭据清单中对访问令牌进行排序

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/credentials_inventory.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/513181)

{{< /details >}}

您现在可以在凭据清单中按所有者、创建日期和最后使用日期对个人、项目和群组访问令牌进行排序。这有助于您更快地定位和识别访问令牌。
感谢 [Chaitanya Sonwane](https://gitlab.com/chaitanyason9)的贡献！

<a id="identify-and-revoke-tokens-with-token-information-api"></a>

### 使用令牌信息 API 识别和撤销令牌

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../api/admin/token.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15777)

{{< /details >}}

极狐GitLab 管理员现在可以使用统一的 API 来识别和撤销令牌。此前，管理员必须使用与特定令牌类型相关的端点。此 API 允许无论类型如何都可以撤销。有关支持的令牌类型列表，请参阅[令牌信息 API](../../api/admin/token.md)。

感谢 [Nicholas Wittstruck](https://gitlab.com/nwittstruck) 和西门子团队的贡献！

<a id="configurable-token-duration-with-gitlab-oidc-provider"></a>

### 使用极狐GitLab OIDC 提供商配置令牌时长

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/auth/oidc.md#configure-a-custom-duration-for-id-tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/377654)

{{< /details >}}

当使用极狐GitLab 作为 OpenID Connect（OIDC）提供商时，您现在可以使用 `id_token_expiration` 属性配置 ID 令牌的时长。此前，ID 令牌的固定过期时间为 120 秒。

感谢 [Henry Sachs](https://gitlab.com/DerAstronaut)的贡献！

<a id="map-omniauth-profile-attributes-to-user"></a>

### 将 OmniAuth 个人资料属性映射到用户

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../integration/omniauth.md#keep-omniauth-user-profiles-up-to-date) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/505575)

{{< /details >}}

您现在可以将 OmniAuth身份提供商（IdP）中的组织和职位个人资料属性映射到用户的极狐GitLab 个人资料。这使得 IdP 成为这些属性的唯一事实来源，用户无法再更改它们。

<a id="extended-webhook-triggers-for-expiring-tokens"></a>

### 过期令牌的扩展 Webhook 触发器

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/manage.md#add-additional-webhook-triggers-for-group-access-token-expiration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/499732)

{{< /details >}}

您现在可以在项目或群组访问令牌过期前 60 天和 30 天触发 Webhook 事件。此前，这些 Webhook 事件仅在过期前 7 天触发。这是一项可选设置，与现有的过期令牌电子邮件通知计划相匹配。

<a id="gitlab-runner-1710"></a>

### 极狐GitLab Runner 17.10

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.10！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [在使用实例前执行 Autoscaler 执行器健康检查](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38271)
- [扩展 Docker 执行器卷](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38249)
- [为服务添加 Docker 执行器设备添加配置](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/6208)

<a id="bug-fixes"></a>

#### 缺陷修复

- [Windows `gitlab-runner-helper` 镜像因 `/opt/step-runner` 路径的无效卷规范而失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38632)
- [RPM 软件包的代码仓库镜像在GitLab Runner 17.7.0 及更高版本中无法正常工作](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38409)
- [在GitLab CI/CD 中运行 `git submodule update --remote` 返回错误](https://gitlab.com/gitlab-org/gitlab/-/issues/359825)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-10-stable/CHANGELOG.md)。
