---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GLQL 显示类型
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

显示类型控制[嵌入式视图](_index.md#embedded-views)如何渲染 GLQL 查询的结果。在视图源中使用 `display` 参数设置显示类型。

如果您未设置 `display` 参数，结果将以列表形式渲染。

某些显示类型适用于任何查询。其他显示类型仅适用于[分析模式](_index.md#analytics-mode)，该模式将数据聚合为维度和指标。

以下显示类型适用于任何模式：

| 显示类型                  | `display` 值 | 描述 |
| ----------------------------- | --------------- | ----------- |
| 表格               | `table`         | 一个表格，每个结果占一行，每个字段占一列。 |
| 列表                 | `list`          | 结果的无序列表。 |
| 有序列表 | `orderedList`   | 结果的编号列表。 |

以下显示类型仅适用于分析模式：

| 显示类型                  | `display` 值 | 描述 |
| ----------------------------- | --------------- | ----------- |
| 单一统计 | `stat`          | 单个聚合指标，以大数值显示。 |
| 柱状图 | `columnChart`   | 一个图表，用于比较由您的维度定义的类别之间的指标。 |
| 条形图 | `barChart` | 一个水平图表，用于比较由您的维度定义的类别之间的指标。 |
| 折线图     | `lineChart`     | 一个图表，将一个或多个指标作为线条绘制在维度上，以显示趋势。 |
| 面积图     | `areaChart`     | 一个图表，将一个或多个指标作为填充区域绘制在维度上，以显示趋势和体量。 |

<a id="table"></a>

## 表格

表格为每个结果渲染一行，为每个[字段](fields.md)渲染一列。

要按列对表格进行排序，请选择列标题。此视图会重新排序视图中加载的行，而不是整个结果集。

<a id="example"></a>

### 示例

要将 `gitlab-org/gitlab` 项目中分配给当前用户的前五个未结议题以表格形式显示，并包含 `title`、`state`、`health`、`epic`、`milestone`、`weight` 和 `updated` 列：

````yaml
```glql
display: table
title: My open issues
fields: title, state, health, epic, milestone, weight, updated
limit: 5
query: type = Issue AND project = "gitlab-org/gitlab" AND assignee = currentUser() AND state = opened
```
````

<a id="list"></a>

## 列表

列表将结果渲染为无序列表。列表是默认的显示类型。

<a id="example-1"></a>

### 示例

要将 `gitlab-org/gitlab` 项目中分配给当前用户的前五个未结议题以列表形式显示，按截止日期排序（最早的在前），并显示 `title`、`health` 和 `due` 字段：

````yaml
```glql
display: list
fields: title, health, due
limit: 5
sort: due asc
query: type = Issue AND project = "gitlab-org/gitlab" AND assignee = currentUser() AND state = opened
```
````

<a id="ordered-list"></a>

## 有序列表

有序列表将结果渲染为编号列表。
当结果的顺序有意义时（例如排名），请使用有序列表。

<a id="example-2"></a>

### 示例

要将 `gitlab-org/gitlab` 项目中分配给当前用户的前五个未结议题以有序列表形式显示，按截止日期排序（最早的在前），并显示 `title`、`health` 和 `due` 字段：

````yaml
```glql
display: orderedList
fields: title, health, due
limit: 5
sort: due asc
query: type = Issue AND project = "gitlab-org/gitlab" AND assignee = currentUser() AND state = opened
```
````

<a id="single-stat"></a>

## 单一统计

单一统计将[分析模式](_index.md#analytics-mode)中的一个聚合指标可视化为一个大数值。使用单一统计来突出显示关键数字，例如总数或比率。

单一统计需要：

- 分析模式，通过 `mode: analytics` 设置。
- 仅一个指标，通过 `metrics` 参数设置。
- 无 `dimensions`。

数值会根据指标自动格式化。例如，计数使用千位分隔符，比率显示为百分比。

<a id="example-3"></a>

### 示例

要将过去 30 天的代码建议总数显示为单一统计：

````yaml
```glql
display: stat
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
metrics: totalCount
```
````

<a id="column-chart"></a>

## 柱状图

柱状图将[分析模式](_index.md#analytics-mode)中的聚合数据可视化。使用柱状图来比较由您的维度定义的类别之间的指标。

柱状图需要：

- 分析模式，通过 `mode: analytics` 设置。
- 一个或两个 `dimensions` 用于对结果进行分组。
- 至少一个要绘制的指标（使用 `metrics` 参数）。

维度和指标的数量决定了图表的渲染方式：

- 一个维度搭配一个或多个指标，会为每个指标绘制一个柱。要堆叠这些柱，请在 `displayConfig` 下设置 `stacked: true`。对于单个指标，`stacked` 没有可见效果。
- 两个维度搭配一个指标，会绘制按第二个维度分组的堆叠柱状图。使用两个维度时，只能使用一个指标，极狐GitLab 会忽略 `displayConfig.stacked`。

<a id="example-4"></a>

### 示例

要将过去 30 天按语言统计的代码建议使用情况显示为柱状图：

````yaml
```glql
display: columnChart
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
dimensions: language
metrics: totalCount
```
````

要将指标堆叠到单个柱中，而不是并排绘制：

````yaml
```glql
display: columnChart
displayConfig:
  stacked: true
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
dimensions: language
metrics: acceptedCount, rejectedCount
```
````

<a id="bar-chart"></a>

## 条形图

条形图将[分析模式](_index.md#analytics-mode)中的聚合数据可视化为水平条形。使用条形图来比较由您的维度定义的类别之间的指标，尤其是在类别标签较长时。

条形图需要：

- 分析模式，通过 `mode: analytics` 设置。
- 一个或两个 `dimensions` 用于对结果进行分组。
- 至少一个要绘制的指标（使用 `metrics` 参数）。

维度和指标的数量决定了图表的渲染方式：

- 一个维度搭配一个或多个指标，会为每个指标绘制一个条形。要堆叠这些条形，请在 `displayConfig` 下设置 `stacked: true`。对于单个指标，`stacked` 没有可见效果。
- 两个维度搭配一个指标，会绘制按第二个维度分组的堆叠条形图。使用两个维度时，只能使用一个指标，极狐GitLab 会忽略 `displayConfig.stacked`。

<a id="example-5"></a>

### 示例

要将过去 30 天按语言统计的代码建议使用情况显示为条形图：

````yaml
```glql
display: barChart
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
dimensions: language
metrics: totalCount
```
````

要将指标堆叠到单个条形中，而不是并排绘制：

````yaml
```glql
display: barChart
displayConfig:
  stacked: true
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
dimensions: language
metrics: acceptedCount, rejectedCount
```
````

<a id="line-chart"></a>

## 折线图

折线图将[分析模式](_index.md#analytics-mode)中的聚合数据可视化为一条或多条线。使用折线图来显示指标如何跨维度变化，例如随时间变化。

折线图需要：

- 分析模式，通过 `mode: analytics` 设置。
- 恰好一个 `dimension` 用于 x 轴。
- 至少一个要绘制的 `metric`。每个指标渲染为一条独立的线。

<a id="example-6"></a>

### 示例

要将过去 30 天按语言统计的代码建议使用情况显示为折线图，其中一条线表示总建议数，一条线表示已接受建议数：

````yaml
```glql
display: lineChart
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
dimensions: language
metrics: totalCount, acceptedCount
```
````

<a id="area-chart"></a>

## 面积图

面积图将[分析模式](_index.md#analytics-mode)中的聚合数据可视化为一个或多个填充区域。使用面积图来显示指标如何跨维度变化（例如随时间变化），并强调趋势背后的体量。

面积图需要：

- 分析模式，通过 `mode: analytics` 设置。
- 一个或两个 `dimensions` 用于对结果进行分组。
- 至少一个要绘制的指标（使用 `metrics` 参数）。

维度和指标的数量决定了图表的渲染方式：

- 一个维度搭配一个或多个指标，会为每个指标绘制一个面积。面积以半透明填充重叠。要改为累积堆叠面积，请在 `displayConfig` 下设置 `stacked: true`。对于单个指标，`stacked` 没有可见效果。
- 两个维度搭配一个指标，会绘制按第二个维度分组的堆叠面积图。使用两个维度时，只能使用一个指标，极狐GitLab 会忽略 `displayConfig.stacked`。

<a id="example-7"></a>

### 示例

要将过去 30 天已显示和已接受的代码建议显示为重叠面积：

````yaml
```glql
display: areaChart
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
dimensions: timestamp
metrics: shownCount, acceptedCount
```
````

要改为累积堆叠指标：

````yaml
```glql
display: areaChart
displayConfig:
  stacked: true
mode: analytics
query: type = CodeSuggestion and timestamp >= -30d
dimensions: timestamp
metrics: shownCount, acceptedCount
```
````

<a id="pagination-support"></a>

## 分页支持

适用于任何模式的显示类型会显示第一页结果，并提供 **加载更多** 操作来获取其他页面。有关更多信息，请参阅[分页](_index.md#pagination)。

分析模式可视化不支持分页。它们会一次性渲染所有聚合结果。
