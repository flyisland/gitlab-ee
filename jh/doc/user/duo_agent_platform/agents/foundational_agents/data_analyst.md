---
stage: AI-powered
group: Workflow Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 数据分析 Agent
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.6 中[引入]，带有一个功能标志 `foundational_analytics_agent`，默认禁用。
- 在 极狐GitLab 18.7 中改为 [beta](../../../../policy/development_stages_support.md#beta)。
- 在 极狐GitLab 18.7 中，[启用于 JihuLab.com 和私有化部署]。
- 在 极狐GitLab 18.11 中，[GA]。

{{< /history >}}

数据分析 Agent 是一个专门的 AI 助手，可帮助你查询、可视化和呈现 极狐GitLab 平台中的数据。它使用 [GLQL](../../../glql/_index.md) 来检索和分析数据，然后提供有关你的项目和群组的清晰、可操作的洞察。关于你的层级支持哪些数据源和字段的信息，请参阅 [GLQL 数据源](../../../glql/data_sources/_index.md)。

当你需要以下方面的帮助时，可以使用数据分析 Agent：

- 容量分析：统计一段时间内的合并请求、议题或其他工作项数量。
- 团队表现：了解团队成员的工作内容及其产出。
- 趋势分析：识别开发工作流中的模式。
- 状态监控：检查项目或群组中工作项的状态。
- 工作项发现：按作者、标签、里程碑或其他条件查找议题、合并请求或史诗。
- GLQL 查询生成：创建可以在支持 极狐GitLab Flavored Markdown 的任何位置嵌入的查询，包括议题、合并请求、史诗、评论、Wiki、代码片段和发布。

<a id="known-issues"></a>

## 已知问题

- Agent 可以对查询到的数据进行轻度聚合，但对于超过 100 条的数据集，结果可能不完整。
- GLQL 支持查询[特定区域](../../../glql/data_sources/_index.md)，但不支持所有 极狐GitLab 数据源。
- Agent 无法直接输出到工作项或仪表板。但是，你可以复制生成的 GLQL 查询，并将其嵌入到支持 极狐GitLab Flavored Markdown 的任何页面中。

<a id="use-the-data-analyst-agent"></a>

## 使用数据分析 Agent

您可以在极狐GitLab UI 中使用数据分析 Agent。

<a id="in-the-gitlab-ui"></a>

### 在极狐GitLab UI 中

先决条件：

- [打开](_index.md#turn-foundational-agents-on-or-off)内置 Agent。

要在 极狐GitLab UI 中使用数据分析 Agent：

1. 在 极狐GitLab Duo 侧边栏中，选择 **添加新会话** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中，选择 **数据分析**。

   一个 Chat 会话将打开在屏幕右侧的 极狐GitLab Duo 侧边栏中。
1. 输入你的分析问题或请求。为获得最佳结果：

   - 询问数据时指定范围（项目或群组）。
   - 在进行基于时间的分析时包含时间范围。
   - 明确指出你感兴趣的工作项类型。

<a id="example-prompts"></a>

## 示例提示

- 容量和计数：
  - “本月合并了多少个合并请求？”
  - “统计上周创建的议题。”
  - “当前有多少个缺陷处于开放状态？”
- 团队表现：
  - “@用户 本月做了什么？”
  - “显示团队 X 在过去两周内合并的合并请求。”
  - “显示一个包含指派给我的议题标题和标签的表格。”
  - “按作者列出开放的合并请求。”
- 状态和监控：
  - “显示带有 `~priority::1` 和 `~bug` 标签的开放议题。”
  - “显示逾期的议题。”
  - “有哪些合并请求正在等待审核？”
  - “列出当前里程碑中的议题。”
- 趋势分析：
  - “显示过去一个月的合并请求活动。”
  - “本季度缺陷创建的趋势是什么？”
  - “比较本月和上个月的议题关闭率。”
- GLQL 查询生成：
  - “为我创建一条针对指派给我的开放议题的 GLQL 查询。”
  - “创建一个表格，显示本周合并的所有合并请求。”
  - “为团队 X 的开放工作生成一个 GLQL 嵌入式视图。”
  - “按多个标签过滤的 GLQL 语法是什么？”
- 工作项发现：
  - “列出目标分支为 main 的合并请求。”
  - “查找在过去 24 小时内更新的议题。”
  - “显示指派给团队 X 的开放缺陷。”