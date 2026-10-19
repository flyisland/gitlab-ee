---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 计划者 Agent
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

计划者 Agent 是一种专用 AI Agent，可协助您在极狐GitLab 中完成产品管理和规划工作流。它可以帮助您更高效地创建、排定优先级和跟踪工作。

计划者 Agent 了解极狐GitLab 的规划概念，包括工作项层级（史诗、议题和任务）、里程碑、标记和权重。它可以分析工作项、建议优先级排序策略，并帮助您组织和传达您的计划。

当您为顶级群组和用户偏好设置开启 [Orbit](https://docs.gitlab.cn/docs/orbit/) 后，计划者 Agent 还可以使用知识图谱来回答有关跨项目的关系、依赖项和历史背景的问题。

当您需要以下方面的帮助时，请使用计划者 Agent：

- 优先级排序：应用 RICE、MoSCoW 或 WSJF 等框架对工作项进行排序。
- 工作分解：将计划分解为史诗、功能和用户故事。
- 创建内容：起草备忘录、需求和其他规划产物，或在被要求时直接创建史诗、议题和任务。
- 依赖项分析：识别受阻的工作并了解各项之间的关系。
- 编辑内容：在被要求时，或在它请求确认以执行操作后，更新工作项、标记、里程碑、关联项关系和其他属性。
- 待办事项管理：为工作项添加待办事项并将其标记为已完成。
- 规划会议：组织冲刺、里程碑或季度规划。
- 状态报告：生成进度、风险和阻碍因素的摘要。
- 待办事项列表管理：识别陈旧的议题、重复项或需要完善的项。
- 已保存视图：使用视图的筛选条件和排序顺序分析已保存视图中的工作项。
- 估算：为工作项建议相对规模或工作量估算。
- 基于图谱的上下文：查找类似的过往工作、跨项目依赖项以及具有相关经验的贡献者。需要 [Orbit](https://docs.gitlab.cn/docs/orbit/)。

您可以在[议题 583008](https://gitlab.com/gitlab-org/gitlab/-/work_items/583008)中留下反馈。

<a id="use-the-planner-agent"></a>

## 使用计划者 Agent

您可以在极狐GitLab UI、VS Code 和 JetBrains IDE 中使用计划者 Agent。

<a id="tips-for-best-results"></a>

### 获得最佳结果的提示

要让请求获得最佳结果：

- 提供有关请求的上下文，例如 URL、筛选条件或范围。
- 在相关时指定工作项类型（史诗、议题或任务）。
- 如果您有偏好的优先级排序框架，请指定它。
- 在请求摘要或更新时，指定您的目标受众，例如工程团队、领导层或利益相关者。
- 当您希望 Agent 执行操作而不是提出建议时，使用明确的动作动词，如“创建”、“更新”或“关闭”。
- 如果 Agent 的假设与您的工作流不符，请要求其澄清。

<a id="in-the-gitlab-ui"></a>

### 在极狐GitLab UI 中

先决条件：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- 可选。要使用基于图谱的上下文，请为您的顶级群组和用户偏好设置[开启 Orbit](https://docs.gitlab.cn/docs/orbit/remote/getting-started/)。

要在极狐GitLab UI 中使用计划者 Agent：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在极狐GitLab Duo 边栏中，选择**添加新聊天** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中，选择 **Planner**。

   聊天对话会在屏幕右侧的极狐GitLab Duo 边栏中打开。
1. 输入您与规划相关的问题或请求。

<a id="in-vs-code"></a>

### 在 VS Code 中

先决条件：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- 安装并配置 [GitLab for VS Code](../../../../editor_extensions/visual_studio_code/setup.md)
  6.57.3 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- 可选。要使用基于图谱的上下文，请为您的顶级群组和用户偏好设置[开启 Orbit](https://docs.gitlab.cn/docs/orbit/remote/getting-started/)。

要在 VS Code 中使用计划者 Agent：

1. 在 VS Code 中，在左侧边栏中，选择**极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}})。
1. 选择 **Chat** 标签页。
1. 从**新会话** ({{< icon name="duo-chat-new" >}}) 下拉列表中，选择 **Planner**。
1. 输入您与规划相关的问题或请求。

<a id="in-jetbrains-ides"></a>

### 在 JetBrains IDE 中

先决条件：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- 安装并配置[适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../../../editor_extensions/jetbrains_ide/setup.md)
  3.11.1 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- 可选。要使用基于图谱的上下文，请为您的顶级群组和用户偏好设置[开启 Orbit](https://docs.gitlab.cn/docs/orbit/remote/getting-started/)。

首先，启用极狐GitLab Duo Agent Platform：

1. 在您的 JetBrains IDE 中，转到 **Settings** > **Tools** > **极狐GitLab Duo**。
1. 在**极狐GitLab Duo Agent Platform** 下，选中**启用极狐GitLab Duo Agent Platform**复选框。
1. 如果系统提示，请重启您的 IDE。

然后，要使用计划者 Agent：

1. 在您的 JetBrains IDE 中，在右侧工具窗口栏上，选择**极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}})。
1. 选择 **Chat** 标签页。
1. 从**新会话** ({{< icon name="duo-chat-new" >}}) 下拉列表中，选择 **Planner**。
1. 输入您与规划相关的问题或请求。

<a id="example-prompts"></a>

## 示例提示

- 优先级排序：
  - “使用 RICE 框架帮我为待办事项列表中带有标记 `<label name>` 的工作项排定优先级。”
  - “使用 MoSCoW 根据客户影响 `<URL>`，按条件 `<criteria>` 对此工作项中的功能进行分类。”
  - “按第一季度的战略价值对这些工作项进行排序：`<URLs>`”
  - “使用工作量与影响矩阵比较这些功能：`<URLs>`”
  - “为按时完成，我应从当前范围中移除此工作项中的哪些子项？`<URL>`”
- 工作分解：
  - “将此计划分解为我们需要交付的关键功能：`<URL>`”
  - “实现此工作项需要哪些任务？`<URL>`”
  - “此功能的最小可行产品（MVP）版本会是什么样？`<URL>`”
  - “我们应如何安排此工作项中功能的顺序？`<URL>`”
  - “为此项目建议一种分阶段的方法：`<URL>`”
- 状态报告：
  - “为此工作项（包括所有子项）提供状态更新和进度报告：`<URL>`”
  - “生成此工作项进度的高层摘要：`<URL>`”
  - “为领导层总结阻碍因素和缓解计划：`<URL>`”
  - “就此计划的健康状况撰写一份利益相关者更新：`<URL>`”
- 内容创建：
  - “为此计划起草一份备忘录，包括目标、成功标准和关键利益相关者：`<URL>`”
  - “为此起草一份技术需求工作项，包括 API 需求、数据模型和集成点：`<URL>`”
  - “撰写一份依赖关系图说明，解释这些工作项之间的关系和顺序：`<URLs>`”
  - “为此史诗生成风险评估，识别潜在的阻碍因素和缓解策略：`<URL>`”
  - “估算此工作项的实施工作量，包括开发时间、测试和潜在阻碍因素：`<URL>`”
- 依赖项分析：
  - “为缩小范围，我们应在此工作项中推迟哪些工作？`<URL>`”
  - “帮我权衡技术债务与新功能的优先级。”
- 规划会议：
  - “将这些工作项归入合理的发布主题：`<URLs>`”
  - “哪些工作项已错过截止日期？”
- 待办事项列表管理：
  - “查找 6 个月内未更新的陈旧工作项。”
  - “识别此项目中的重复或相似工作项。”
  - “显示分配给我的工作项。”
- 已保存视图：
  - “总结此已保存视图中的工作项：`<URL>`”
  - “此已保存视图中有哪些工作项未分配？`<URL>`”
- 内容编辑：
  - “将此工作项关闭为已完成，并创建一个新的回顾工作项，记录哪些做得好以及哪些需要改进：`<URL>`”
  - “将此工作项标记为被这些项阻碍：`<URLs>`”
  - “将这些工作项链接为相关：`<URLs>`”
- 待办事项管理：
  - “为此工作项添加待办事项：`<URL>`”
  - “将此工作项中我的所有待办事项标记为已完成：`<URL>`”
- 基于图谱的上下文（需要 [Orbit](https://docs.gitlab.cn/docs/orbit/)）：
  - “查找与此史诗相似且已交付的史诗：`<URL>`”
  - “过去针对此工作项，类似的计划是如何分解的：`<URL>`”
  - “是否已有人跟踪与此想法相关的工作？”
  - “哪些贡献者曾从事与此史诗相关的领域？`<URL>`”
  - “此工作项可能依赖跨项目的哪些其他工作项？`<URL>`”

<a id="known-issues"></a>

## 已知问题

- Agent 可以批量分析工作项，但对于涉及大量项的请求，响应质量可能会下降。
- Agent 无法可靠地访问讨论历史很长的工作项上的评论。评论历史超过约 100 条时可能不完整。
- 当您要求 Agent 将工作项状态更新为不存在的值时，Agent 可能会错误地报告更新成功，而实际上未应用任何更改。
