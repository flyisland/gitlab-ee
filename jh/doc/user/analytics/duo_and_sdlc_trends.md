---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo 与 SDLC 趋势
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 极狐GitLab 私有化部署的测试版

{{< /details >}}

此功能在极狐GitLab 私有化部署中为测试版。更多信息，请参见[史诗 51](https://gitlab.com/groups/gitlab-org/architecture/gitlab-data-analytics/-/epics/51)。

极狐GitLab Duo 与 SDLC 趋势用于衡量极狐GitLab Duo 对软件开发生命周期（SDLC）表现的影响。
此仪表板可让您了解在项目或群组中采用 AI 的背景下的关键 SDLC 指标。您可以使用该仪表板衡量哪些指标因您的 AI 投入而得到改善。

使用极狐GitLab Duo 与 SDLC 趋势可以：

- 结合您的极狐GitLab Duo 使用历程跟踪 SDLC 趋势：考察项目或群组中极狐GitLab Duo 使用趋势如何影响其他关键生产力指标，例如平均合并时间和 CI/CD 统计信息。极狐GitLab Duo 使用指标显示最近六个月（包括当月）的数据。
- 监控极狐GitLab Duo 功能采用情况：跟踪项目或群组中最近 30 天的席位和功能使用情况。

下表列出了极狐GitLab Duo 与 SDLC 指标的可用性：

| 功能 | 需要 [ClickHouse](../../integration/clickhouse.md) |
|---------|:-------------------:|
| 极狐GitLab Duo 与 SDLC 趋势仪表板 | {{< yes >}} |
| `AiMetrics` API | {{< yes >}} |
| `AiUserMetrics` API | {{< yes >}} |
| `AiUsageData` API | {{< no >}}（仅 PostgreSQL） |

要了解如何优化您的许可证使用率，请参见[极狐GitLab Duo 附加组件](../../subscriptions/subscription-add-ons.md)。

要详细了解极狐GitLab Duo 与 SDLC 趋势，请参见博客文章
[开发 GitLab Duo：AI 影响分析仪表板衡量 AI 投资回报率](https://about.gitlab.com/blog/developing-gitlab-duo-ai-impact-analytics-dashboard-measures-the-roi-of-ai/)。

<a id="key-metrics"></a>

## 关键指标

- **极狐GitLab Duo 用户**：最近 30 天内使用过至少一项极狐GitLab Duo 或极狐GitLab Duo Agent Platform 功能的用户数。
- **极狐GitLab Duo 高级用户**：最近 30 天内使用过至少三项极狐GitLab Duo 功能的用户数。
- **极狐GitLab Duo Agent/任务流用户**：最近 30 天内使用过至少一个极狐GitLab Duo Agent 或任务流的用户数。
- **极狐GitLab Duo Agent 聊天会话**：最近 30 天内在极狐GitLab Duo Agent Platform 中发起的聊天会话数。
- **使用极狐GitLab Duo 功能的流水线**：最近 30 天内在执行期间使用过一项或多项极狐GitLab Duo 功能的 CI/CD 流水线所占百分比。

<a id="metric-trends"></a>

## 指标趋势

**指标趋势**表显示最近六个月的指标，包括每月数值、过去六个月的百分比变化以及趋势迷你图。

这些指标会显示一个趋势指示器，展示与上一时间段相比的百分比变化。如果上一时间段没有可用数据，百分比变化会显示为 **n/a**。

绿色数值表示正向变化，红色数值表示负向变化。数值旁边的图标表示上升趋势 {{< icon name="trend-up" >}} 或下降趋势 {{< icon name="trend-down" >}}。

对于某些指标（如[部署频率](dora_metrics.md#deployment-frequency)），上升趋势是正向的（绿色）；但对于其他指标（如[平均合并时间](merge_request_analytics.md)），上升趋势则是负向的（红色）。

<a id="gitlab-duo-usage-metrics"></a>

### 极狐GitLab Duo 使用指标

- **功能使用情况**：使用过至少一项极狐GitLab Duo 或极狐GitLab Duo Agent Platform 功能的用户数。
- **Agent Platform 聊天**：通过极狐GitLab Duo Agent Platform 发起的聊天会话数。
- **Agent Platform 任务流**：通过极狐GitLab Duo Agent Platform 执行的 Agent 任务流（不含聊天）数。
- **Non-Agentic Chat 使用情况**：使用过 Non-Agentic Chat 的用户数。
- **根因分析使用情况**：使用过根因分析的用户数。
- **代码评审请求**：对合并请求发起的代码评审请求数。
  这包括由合并请求作者和非作者发起的请求。
- **代码评审评论**：在合并请求差异中发布的代码评审评论数。
- **代码建议使用情况**：使用过代码建议的用户数。
  在 JihuLab.com 上，数据每五分钟更新一次。
  只有当用户在当前月份向项目推送过代码时，极狐GitLab 才会统计代码建议使用情况。
- **代码建议接受率**：极狐GitLab Duo 提供的代码建议中被代码贡献者接受的百分比。

<a id="development-metrics"></a>

### 开发指标

- [**前置时间**](../group/value_stream_analytics/_index.md#lifecycle-metrics)
- [**合并的中位时间**](merge_request_analytics.md)
- [**部署频率**](dora_metrics.md#deployment-frequency)
- [**合并请求吞吐量**](merge_request_analytics.md#view-the-number-of-merge-requests-in-a-date-range)
- [**随时间推移的严重漏洞**](../application_security/vulnerability_report/_index.md)
- [**贡献者数量**](../profile/contributions_calendar.md#user-contribution-events)

<a id="pipeline-metrics"></a>

### 流水线指标

流水线指标表显示所选项目中运行的流水线的指标。

- **流水线运行总数**：项目中流水线的运行次数。
- **中位时长**：一次流水线运行的中位时长（以分钟为单位）。
- **成功率**：成功完成的流水线运行所占百分比。
- **失败率**：以失败状态完成的流水线运行所占百分比。

<a id="pipelines-using-gitlab-duo-agent-platform"></a>

## 使用极狐GitLab Duo Agent Platform 的流水线

**使用极狐GitLab Duo Agent Platform 的流水线**图表显示最近 180 天内运行的流水线数量，按月汇总。该图表显示：

- **使用 Agent Platform**：由极狐GitLab Duo Agent Platform 触发的流水线数量。
- **所有流水线**：命名空间中运行的流水线总数。

<a id="gitlab-duo-code-suggestions-acceptance-by-language"></a>

## 按语言统计的极狐GitLab Duo 代码建议接受情况

**按语言统计的极狐GitLab Duo 代码建议接受情况**图表显示最近 30 天内按编程语言统计的已接受代码建议数量。

将鼠标悬停在柱状条上可查看每种语言的：

- **已接受建议**：用户接受的建议数。
- **已显示建议**：向用户显示的建议数。
- **接受率**：已接受建议所占百分比。
  计算方式为已接受的代码建议数除以显示的代码建议总数。

<a id="gitlab-duo-code-suggestions-acceptance-by-ide"></a>

## 按 IDE 统计的极狐GitLab Duo 代码建议接受情况

**按 IDE 统计的极狐GitLab Duo 代码建议接受情况**图表显示最近 30 天内按 IDE 统计的已接受代码建议数量。

将鼠标悬停在柱状条上可查看每种 IDE 的：

- **已接受建议**：用户接受的建议数。
- **已显示建议**：向用户显示的建议数。
- **接受率**：已接受建议所占百分比。
  计算方式为已接受的代码建议数除以显示的代码建议总数。

<a id="code-generation-volume-trends"></a>

## 代码生成量趋势

**代码生成量趋势**图表显示最近 180 天内通过代码建议生成的代码量，按月汇总。该图表显示：

- **已接受的代码行数**：来自代码建议且被接受的代码行数。
- **已显示的代码行数**：代码建议中显示的代码行数。

<a id="gitlab-duo-code-review-requests-by-role"></a>

## 按角色统计的极狐GitLab Duo 代码评审请求

**按角色统计的极狐GitLab Duo 代码评审请求**图表显示最近 180 天内的代码评审请求数，按月汇总。该图表显示：

- **作者发起的评审请求**：由合并请求作者发起的代码评审请求数。这包括通过项目设置自动请求的代码评审，以及作者在合并请求中手动请求的代码评审。
- **非作者发起的评审请求**：由合并请求作者以外的用户发起的代码评审请求数。例如，请极狐GitLab Duo 评审合并请求变更的审核人。

作者采用率越高，说明团队越倾向于采用自动化评审工作流。

<a id="gitlab-duo-code-review-comments-sentiment"></a>

## 极狐GitLab Duo 代码评审评论情感

**极狐GitLab Duo 代码评审评论情感**图表显示最近 180 天内代码评审评论的情感，通过正面（👍）和负面（👎）反应率来衡量。该图表显示：

- **批准率**：收到正面（👍）反应的代码评审评论所占百分比。
- **不批准率**：收到负面（👎）反应的代码评审评论所占百分比。

在解读分析数据时，请记住：

- 负面偏差是预期之内的。用户倾向于指出问题，但很少认可好的建议，即使他们采纳了这些建议。
- 低反应率很常见。请关注代码是否得到改进、评审是否更快完成。
- 不批准（👎）率上升表明存在问题。不批准率稳定或下降则表明极狐GitLab Duo 代码评审得到了良好采用。

<a id="returning-gitlab-duo-users-by-feature"></a>

## 按功能统计的极狐GitLab Duo 回访用户

**按功能统计的极狐GitLab Duo 回访用户**图表显示最近 180 天内每项极狐GitLab Duo 功能的留存率：代码建议、极狐GitLab Duo Chat、根因分析和极狐GitLab Duo 代码评审。

将鼠标悬停在某个点上可查看所选功能和时段的：

- **留存率**：上一时段中的用户在选择时段内再次使用该功能的百分比。
  计算方式为所选时段内的回访用户数除以上一时段内的用户数。

该图表从所选日期范围中的第二个时段开始显示。第一个时段不显示留存率，因为没有更早的时段可供比较。

<a id="gitlab-duo-metrics-by-user"></a>

## 按用户统计的极狐GitLab Duo 指标

用户指标表显示最近 30 天内各个用户对不同极狐GitLab Duo 功能的使用情况。

- **按用户统计的极狐GitLab Duo 代码建议使用情况**：已接受的代码建议数，以及代码建议接受率。
- **按用户统计的极狐GitLab Duo 代码评审使用情况**：以合并请求作者身份向极狐GitLab Duo 请求的代码评审数，以及对代码评审评论的反应数（:thumbsup: 和 :thumbsdown:）。
- **按用户统计的极狐GitLab Duo 根因分析使用情况**：向极狐GitLab Duo 发起的故障排除请求数。
- **按用户统计的极狐GitLab Duo 使用情况**：用户产生的极狐GitLab Duo 事件数。
- **按用户统计的任务流使用情况**：用户触发特定任务流的次数。

<a id="view-gitlab-duo-and-sdlc-trends"></a>

## 查看极狐GitLab Duo 与 SDLC 趋势

先决条件：

- 您在群组中必须至少具有报告者角色。
- 该群组必须是顶级群组。
- 必须启用极狐GitLab Duo 代码建议。
- 对于极狐GitLab 私有化部署，必须配置[用于贡献分析的 ClickHouse](../group/contribution_analytics/_index.md#contribution-analytics-with-clickhouse)。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在左侧边栏中，选择**分析** > **分析仪表板**。
1. 选择**极狐GitLab Duo 与 SDLC 趋势**。

要获取极狐GitLab Duo 与 SDLC 指标，您还可以使用 `AiMetrics`、`AiUserMetrics` 和 `AiUsageData` [GraphQL API](../../api/graphql/duo_and_sdlc_trends.md)。

<a id="metric-data-availability"></a>

## 指标数据可用性

下表显示极狐GitLab Duo 指标开始计算使用数据的极狐GitLab 版本：

| 极狐GitLab Duo 指标 | 数据计算起始版本 |
|--------|------------------------------|
| 代码建议使用情况 | 极狐GitLab 16.11 |
| 根因分析使用情况 | 极狐GitLab 18.0 |
| 代码评审请求和评论 | 极狐GitLab 18.3 |
| Agent Platform 聊天和任务流 | 极狐GitLab 18.7 |
