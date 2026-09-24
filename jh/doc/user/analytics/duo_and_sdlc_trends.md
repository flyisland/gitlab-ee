---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo 与 SDLC 趋势
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 私有化部署 Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.11 引入，通过一个名为 `ai_impact_analytics_dashboard` 的功能标志，默认禁用。
- 在极狐GitLab 17.2 GA。功能标志 `ai_impact_analytics_dashboard` 已移除。
- 在极狐GitLab 17.6 中，变为需要极狐GitLab Duo 附加组件。
- 在 18.2 中，从极狐GitLab 旗舰版移至专业版。
- 流水线指标表格在极狐GitLab 18.4 中添加。
- 在极狐GitLab 18.4 中，从 `AI impact analytics` 更名为 `极狐GitLab Duo 与 SDLC 趋势`。
- 在极狐GitLab 18.7 中，变为不需要附加组件。

{{< /history >}}

此功能在私有化部署中为 Beta 状态。  
更多信息，请参阅 [史诗 51](https://jihulab.com/groups/gitlab-cn/architecture/gitlab-data-analytics/-/epics/51)。

极狐GitLab Duo 与 SDLC 趋势衡量极狐GitLab Duo 对软件开发生命周期（SDLC）绩效的影响。  
此仪表盘提供了在项目或群组采用 AI 的背景下关键 SDLC 指标的可视化。  
您可以使用仪表盘来衡量您的 AI 投资改善了哪些指标。

指标显示趋势指标，展示与前一个时间段相比的百分比变化。  
如果前一时期没有可用数据，则百分比变化显示 **n/a**。

绿色值表示正向变化，红色值表示负向变化。  
值旁边的图标表示向上趋势 {{< icon name="trend-up" >}} 或向下趋势 {{< icon name="trend-down" >}}。

对于某些指标（如[部署频率](dora_metrics.md#deployment-frequency)），向上趋势是正向（绿色），但对其他指标（如[平均合并时间](merge_request_analytics.md)）则是负向（红色）。

使用极狐GitLab Duo 与 SDLC 趋势可以实现：

- 追踪与您的极狐GitLab Duo 旅程相关的 SDLC 趋势：检视项目或群组中极狐GitLab Duo 使用趋势如何影响其他关键生产力指标，例如平均合并时间和 CI/CD 统计。极狐GitLab Duo 使用指标显示最近六个月（包括当前月）的数据。
- 监控极狐GitLab Duo 功能采纳情况：跟踪过去 30 天内项目或群组中席位和功能的使用情况。

了解如何优化许可证利用率，请参见 [极狐GitLab Duo 附加组件](../../subscriptions/subscription-add-ons.md)。

要了解有关极狐GitLab Duo 与 SDLC 趋势的更多信息，请参阅博客文章 [开发极狐GitLab Duo：AI 影响分析仪表盘衡量 AI 投资回报率](https://gitlab.cn/blog/developing-gitlab-duo-ai-impact-analytics-dashboard-measures-the-roi-of-ai/)。

<a id="key-metrics"></a>

## 关键指标

{{< history >}}

- 在极狐GitLab 18.10 中，极狐GitLab Duo Chat 使用指标被极狐GitLab Duo Agent 会话替代。
- 在极狐GitLab 18.10 中，已分配的极狐GitLab Duo 席位参与度指标被极狐GitLab Duo 用户数替代。
- 在极狐GitLab 18.10 中，极狐GitLab Duo 代码建议使用指标从百分比变为绝对用户数。
- 在极狐GitLab 18.11 中，代码建议接受率指标被极狐GitLab Duo agent/flow 用户替代。
- 趋势指标在极狐GitLab 19.0 中引入。

{{< /history >}}

- **极狐GitLab Duo 用户**：过去 30 天内至少使用过一个极狐GitLab Duo 或极狐GitLab Duo Agent Platform 功能的用户数。
- **代码建议用户**：过去 30 天内使用代码建议的用户数。计算代码建议指标时，极狐GitLab 仅从代码编辑器扩展收集数据。
- **极狐GitLab Duo agent/flow 用户**：过去 30 天内至少使用过一次极狐GitLab Duo agent 或 flow 的用户数。
- **极狐GitLab Duo Agent 聊天会话**：过去 30 天内通过极狐GitLab Duo Agent Platform 发起的聊天会话数。

<a id="metric-trends"></a>

## 指标趋势

**指标趋势** 表格显示最近六个月的指标，包含月度数值、过去六个月的百分比变化以及趋势迷你图。

<a id="gitlab-duo-usage-metrics"></a>

### 极狐GitLab Duo 使用指标

{{< history >}}

- 通过一个名为 `duo_rca_usage_rate` 的功能标志，在极狐GitLab 18.1 中引入，默认禁用。
- 在极狐GitLab 18.3 中在 JihuLab.com、私有化部署上启用。
- 在极狐GitLab 18.4 GA。功能标志 `duo_rca_usage_rate` 已移除。
- 在极狐GitLab 18.6 中引入极狐GitLab Duo 功能使用。
- 在极狐GitLab 18.7 中引入极狐GitLab Duo 代码审查请求和评论。
- 在极狐GitLab 18.7 中引入极狐GitLab Duo Agent Platform 聊天和流。
- 在极狐GitLab 18.10 中，极狐GitLab Duo 代码建议、非 Agentic 聊天和根因分析指标从百分比变为绝对用户数。

{{< /history >}}

- **功能使用**：至少使用过一个极狐GitLab Duo 或极狐GitLab Duo Agent Platform 功能的用户数。
- **Agent Platform 聊天**：通过极狐GitLab Duo Agent Platform 发起的聊天会话数。
- **Agent Platform 流**：通过极狐GitLab Duo Agent Platform 执行的 agent 流数（不包括聊天）。
- **非 Agentic 聊天使用**：使用过非 Agentic 聊天的用户数。
- **根因分析使用**：使用过根因分析的用户数。
- **代码审查请求**：针对合并请求发起的代码审查请求数。包括由合并请求作者和非作者发起的请求。
- **代码审查评论**：在合并请求差异上发布的代码审查评论数。
- **代码建议使用**：使用过代码建议的用户数。在 JihuLab.com 上，数据每五分钟更新一次。仅当用户在当前月向项目推送了代码时，极狐GitLab 才计算代码建议使用量。
- **代码建议接受率**：极狐GitLab Duo 提供的代码建议中被代码贡献者接受的百分比。

<a id="development-metrics"></a>

### 开发指标

- [**前置时间**](../group/value_stream_analytics/_index.md#lifecycle-metrics)
- [**中位合并时间**](merge_request_analytics.md)
- [**部署频率**](dora_metrics.md#deployment-frequency)
- [**合并请求吞吐量**](merge_request_analytics.md#view-the-number-of-merge-requests-in-a-date-range)
- [**随时间变化的严重漏洞**](../application_security/vulnerability_report/_index.md)
- [**贡献者数量**](../profile/contributions_calendar.md#user-contribution-events)

<a id="pipeline-metrics"></a>

### 流水线指标

流水线指标表格显示所选项目中运行的流水线的指标。

- **总流水线运行次数**：项目中流水线运行次数。
- **中位持续时间**：流水线运行的中位持续时间（分钟）。
- **成功率**：成功完成的流水线运行百分比。
- **失败率**：以失败完成的流水线运行百分比。

<a id="gitlab-duo-code-suggestions-acceptance-by-language"></a>

## 极狐GitLab Duo 代码建议按语言接受情况

{{< history >}}

- 在极狐GitLab 18.5 中引入。

{{< /history >}}

**极狐GitLab Duo 代码建议按语言接受情况** 图表显示过去 30 天按编程语言分类的已接受代码建议数量。

将鼠标悬停在柱形上可查看每种语言的以下信息：

- **已接受建议数**：用户接受的建议数量。
- **已显示建议数**：向用户显示的代码建议数量。
- **接受率**：建议被接受的百分比。计算方式为已接受的代码建议数除以已显示的代码建议总数。

<a id="gitlab-duo-code-suggestions-acceptance-by-ide"></a>

## 极狐GitLab Duo 代码建议按 IDE 接受情况

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

**极狐GitLab Duo 代码建议按 IDE 接受情况** 图表显示过去 30 天按 IDE 分类的已接受代码建议数量。

将鼠标悬停在柱形上可查看每种 IDE 的以下信息：

- **已接受建议数**：用户接受的建议数量。
- **已显示建议数**：向用户显示的代码建议数量。
- **接受率**：建议被接受的百分比。计算方式为已接受的代码建议数除以已显示的代码建议总数。

<a id="code-generation-volume-trends"></a>

## 代码生成量趋势

{{< history >}}

- 在极狐GitLab 18.5 中引入。

{{< /history >}}

**代码生成量趋势** 图表显示过去 180 天通过代码建议生成的代码量，按月汇总。图表显示：

- **已接受的代码行数**：代码建议中被接受的代码行数。
- **已显示的代码行数**：代码建议中显示的代码行数。

<a id="gitlab-duo-code-review-requests-by-role"></a>

## 极狐GitLab Duo 代码审查请求按角色分类

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

**极狐GitLab Duo 代码审查请求按角色分类** 图表显示过去 180 天按月汇总的代码审查请求数。图表显示：

- **作者发起的审查请求**：由合并请求作者发起的代码审查请求数。包括通过项目设置自动请求的和作者在合并请求中手动请求的审查。
- **非作者发起的审查请求**：由非合并请求作者发起的代码审查请求数。例如，请求极狐GitLab Duo 审查合并请求更改的审查者。

较高的作者采纳率表明团队正在接受自动化审查工作流。

<a id="gitlab-duo-code-review-comments-sentiment"></a>

## 极狐GitLab Duo 代码审查评论情感

{{< history >}}

- 在极狐GitLab 18.8 中引入。

{{< /history >}}

**极狐GitLab Duo 代码审查评论情感** 图表显示过去 180 天代码审查评论的情感，以正面（👍）和负面（👎）反馈率衡量。图表显示：

- **认可率**：收到正面（👍）反馈的代码审查评论百分比。
- **不认可率**：收到负面（👎）反馈的代码审查评论百分比。

在解读分析数据时，请注意：

- 负面偏见是正常的。用户倾向于指出问题，但即使在采纳时也鲜少认可好的建议。
- 低反馈率很常见。重点关注代码是否改进以及审查是否更快完成。
- 上升的不认可（👎）率表明存在问题。稳定或下降的不认可率表明极狐GitLab Duo 代码审查正健康采用。

<a id="gitlab-duo-metrics-by-user"></a>

## 极狐GitLab Duo 按用户指标

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

用户指标表格显示过去 30 天内不同极狐GitLab Duo 功能的个人使用情况。

- **极狐GitLab Duo 代码建议按用户使用情况**：已接受的代码建议数量以及代码建议接受率。
- **极狐GitLab Duo 代码审查按用户使用情况**：作为合并请求作者从极狐GitLab Duo 请求的代码审查次数，以及对代码审查评论的反馈次数（👍 和 👎）。
- **极狐GitLab Duo 根因分析按用户使用情况**：从极狐GitLab Duo 发起的故障排除请求数。
- **极狐GitLab Duo 按用户使用情况**：该用户进行的极狐GitLab Duo 事件次数。
- **按用户使用的流**：用户触发特定流的次数。

<a id="view-gitlab-duo-and-sdlc-trends"></a>

## 查看极狐GitLab Duo 与 SDLC 趋势

先决条件：

- 必须至少具有群组的报告者角色。
- 群组必须是顶级群组。
- 必须启用极狐GitLab Duo 代码建议。
- 对于私有化部署，必须配置 [使用 ClickHouse 的贡献分析](../group/contribution_analytics/_index.md#contribution-analytics-with-clickhouse)。

1. 在顶部栏，选择 **搜索或跳转到** 并查找您的项目或群组。
1. 在左侧边栏，选择 **分析** > **分析仪表盘**。
1. 选择 **极狐GitLab Duo 与 SDLC 趋势**。

您也可以使用 `AiMetrics`、`AiUserMetrics` 和 `AiUsageData` [GraphQL API](../../api/graphql/duo_and_sdlc_trends.md) 获取极狐GitLab Duo 与 SDLC 指标。

<a id="metric-data-availability"></a>

## 指标数据可用性

以下表格显示了极狐GitLab Duo 指标开始计算使用数据的极狐GitLab 版本：

| 极狐GitLab Duo 指标 | 数据计算开始时间 |
|--------|------------------------------|
| 代码建议使用 | 极狐GitLab 16.11 |
| 根因分析使用 | 极狐GitLab 18.0 |
| 代码审查请求和评论 | 极狐GitLab 18.3 |
| Agent Platform 聊天和流 | 极狐GitLab 18.7 |