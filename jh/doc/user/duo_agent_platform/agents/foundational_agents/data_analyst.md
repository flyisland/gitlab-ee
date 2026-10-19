---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 数据分析 Agent
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

数据分析 Agent 是一款专用的 AI 助手，可帮助您在整个极狐GitLab 平台上查询、可视化并呈现数据。它使用[极狐GitLab 查询语言（GLQL）](../../../glql/_index.md)和 [Orbit](https://docs.gitlab.cn/docs/orbit/) 来检索和分析数据，然后就您的项目和群组提供清晰、可操作的洞察。有关您的版本可使用哪些数据源和字段的信息，请参阅 [GLQL 数据源](../../../glql/data_sources/_index.md)和 [Orbit 索引的内容](https://docs.gitlab.com/orbit/remote/indexing/)。

当您需要以下方面的帮助时，可使用数据分析 Agent：

- 数量分析：统计一段时间内的合并请求、议题或其他工作项数量。
- 团队绩效：了解团队成员做过哪些工作及其产出。
- 趋势分析：识别开发工作流中的模式。
- 状态监控：检查项目或群组中工作项的状态。
- 工作项查找：按作者、标记、里程碑或其他条件查找议题、合并请求或史诗。
- GLQL 查询生成：创建可嵌入任何支持极狐GitLab 风格 Markdown 的位置的查询，
  包括议题、合并请求、史诗、评论、Wiki、代码片段和发布。

您可以在[议题 574028](https://gitlab.com/gitlab-org/gitlab/-/issues/574028)中留下反馈。

<a id="known-issues"></a>

## 已知问题

- 该 Agent 可以对查询到的数据执行轻量聚合，但对于超过 100 条的数据集，
  结果可能不完整。
- GLQL 支持查询[特定领域](../../../glql/data_sources/_index.md)，
  但不支持所有极狐GitLab 数据源。
- 该 Agent 无法直接输出到工作项或仪表板。不过，您可以复制生成的 GLQL
  查询，并将其嵌入任何支持极狐GitLab 风格 Markdown 的页面。

<a id="use-the-data-analyst-agent"></a>

## 使用数据分析 Agent

您可以在极狐GitLab UI、VS Code 和 JetBrains IDE 中使用数据分析 Agent。

<a id="in-the-gitlab-ui"></a>

### 在极狐GitLab UI 中

先决条件：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。

要在极狐GitLab UI 中使用数据分析 Agent：

1. 在极狐GitLab Duo 边栏中，选择**添加新聊天** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中，选择 **Data Analyst**。

   聊天对话会在屏幕右侧的极狐GitLab Duo 边栏中打开。
1. 输入您的分析问题或请求。为获得最佳结果：

   - 在询问数据时指定范围（项目或群组）。
   - 为基于时间的分析包含时间范围。
   - 明确说明您感兴趣的工作项类型。

<a id="in-vs-code"></a>

### 在 VS Code 中

先决条件：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- 安装并配置 [GitLab for VS Code](../../../../editor_extensions/visual_studio_code/setup.md)
  6.57.3 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

要在 VS Code 中使用数据分析 Agent：

1. 在 VS Code 中，在左侧边栏中，选择**极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}})。
1. 选择 **Chat** 标签页。
1. 从**新会话** ({{< icon name="duo-chat-new" >}}) 下拉列表中，选择 **Data Analyst**。
1. 输入您的分析问题或请求。为获得最佳结果：

   - 在询问数据时指定范围（项目或群组）。
   - 为基于时间的分析包含时间范围。
   - 明确说明您感兴趣的工作项类型。

<a id="in-jetbrains-ides"></a>

### 在 JetBrains IDE 中

先决条件：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- 安装并配置[适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../../../editor_extensions/jetbrains_ide/setup.md)
  3.24.4 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

首先，启用极狐GitLab Duo Agent Platform：

1. 在您的 JetBrains IDE 中，转到 **Settings** > **Tools** > **极狐GitLab Duo**。
1. 在**极狐GitLab Duo Agent Platform** 下，选中**启用极狐GitLab Duo Agent Platform**复选框。
1. 如果系统提示，请重启您的 IDE。

然后，要使用数据分析 Agent：

1. 在您的 JetBrains IDE 中，在右侧工具窗口栏上，选择**极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}})。
1. 选择 **Chat** 标签页。
1. 从**新会话** ({{< icon name="duo-chat-new" >}}) 下拉列表中，选择 **Data Analyst**。
1. 输入您的分析问题或请求。为获得最佳结果：

   - 在询问数据时指定范围（项目或群组）。
   - 为基于时间的分析包含时间范围。
   - 明确说明您感兴趣的工作项类型。

<a id="example-prompts"></a>

## 示例提示

- 数量与计数：
  - “本月合并了多少个合并请求？”
  - “统计上周创建的议题数量。”
  - “当前有多少个未解决的缺陷？”
- 团队绩效：
  - “@username 本月做了哪些工作？”
  - “显示过去两周内由团队 X 合并的合并请求。”
  - “显示分配给我的议题表格，包含标题和标记。”
  - “按作者列出未解决的合并请求。”
- 状态与监控：
  - “显示带有`~priority::1` 和`~bug` 标记的未解决议题。”
  - “显示已逾期的议题。”
  - “哪些合并请求正在等待评审？”
  - “列出当前里程碑中的议题。”
- 趋势分析：
  - “显示上个月的合并请求活动。”
  - “本季度缺陷创建的趋势如何？”
  - “比较本月与上个月的议题关闭率。”
- GLQL 查询生成：
  - “为分配给我的未解决议题编写一个 GLQL 查询。”
  - “创建一个表格，显示本周合并的所有合并请求。”
  - “为团队 X 的未完成工作生成一个 GLQL 嵌入式视图。”
  - “按多个标记筛选的 GLQL 语法是什么？”
- 工作项查找：
  - “列出以主分支为目标的合并请求。”
  - “查找过去 24 小时内更新的议题。”
  - “显示分配给团队 X 的未解决缺陷。”
