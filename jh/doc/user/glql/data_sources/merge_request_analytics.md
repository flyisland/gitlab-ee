---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合并请求分析
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

分析模式返回合并请求的聚合指标，数据通常在 10 分钟内可用。

要查询单个合并请求记录，请使用[合并请求](merge_requests.md)。

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                                                               |
| --------- | -------------------------------------------------------------------------- |
| `project` | 查询特定项目中的合并请求。                               |
| `group`   | 查询群组内所有项目（包括子群组）中的合并请求。 |

有关更多信息，请参阅[范围](_index.md#scopes)。

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                              | 名称           | 运算符                 |
| ---------------------------------- | -------------- | ------------------------- |
| [创建时间](#created-at)          | `created`      | `=`, `>`, `<`, `>=`, `<=` |
| [合并时间](#merged-at)            | `merged`       | `=`, `>`, `<`, `>=`, `<=` |
| [状态](#state)                    | `state`        | `=`, `in`                 |
| [目标分支](#target-branch)    | `targetBranch` | `=`, `in`                 |

### 创建时间 {#created-at}

**描述**：按创建日期筛选合并请求。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 合并时间 {#merged-at}

**描述**：按合并日期筛选合并请求。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 状态 {#state}

**描述**：按状态筛选合并请求。

**允许的值类型**：

- `Enum`，为 `opened`、`closed`、`merged` 或 `locked` 之一
- `List`（多个值使用 `in` 运算符）

**注意**：

- 不支持 `all` 值。要包含所有状态的合并请求，请省略该筛选条件。

### 目标分支 {#target-branch}

**描述**：按目标分支筛选合并请求。

**允许的值类型**：

- `String`
- `List`（多个值使用 `in` 运算符）

<a id="dimensions"></a>

## 维度

| 维度     | 名称           | 描述                              |
| ------------- | -------------- | ---------------------------------------- |
| 创建时间    | `created`      | 按创建日期分组。接受 [`granularity` 参数](../_index.md#field-parameters)，值为 `daily`、`weekly` 或 `monthly`（默认：`weekly`）。例如，`created(monthly)`。 |
| 合并时间     | `merged`       | 按合并日期分组。接受 [`granularity` 参数](../_index.md#field-parameters)，值为 `daily`、`weekly` 或 `monthly`（默认：`weekly`）。例如，`merged(monthly)`。 |
| 状态         | `state`        | 按合并请求状态分组。            |
| 目标分支 | `targetBranch` | 按目标分支分组。                  |

<a id="metrics"></a>

## 指标

| 指标                 | 名称                   | 描述                              |
| ---------------------- | ---------------------- | ---------------------------------------- |
| 吞吐量计数       | `throughputCount`      | 已合并的合并请求数量。         |
| 合并时间分位数 | `timeToMergeQuantile`  | 从创建到合并的时间，以持续时间形式呈现。例如，`1d 2h`。接受 [`quantile` 参数](../_index.md#field-parameters)，值介于 `0.01` 和 `0.99` 之间（默认：`0.5`，即中位数）。例如，`timeToMergeQuantile(0.95)`。 |
| 总计数            | `totalCount`           | 合并请求的总数。          |

<a id="sort-fields"></a>

## 排序字段

按所选维度或指标中包含的任何字段排序。有关更多信息，请参阅[分析模式排序](../_index.md#sorting)。

<a id="examples"></a>

## 示例

- 最近 30 天的每周合并请求吞吐量趋势：

  ````yaml
  ```glql
  title: "Weekly merge request throughput (last 30 days)"
  display: table
  mode: analytics
  query: type = MergeRequest and project = "gitlab-org/gitlab" and merged > -30d
  dimensions: merged(weekly) as "Week"
  metrics: totalCount as "Total", throughputCount as "Merged", timeToMergeQuantile(0.5) as "Median time to merge"
  sort: merged desc
  ```
  ````

- 按周统计的合并时间中位数和 p95：

  ````yaml
  ```glql
  title: "Median and p95 time to merge by week"
  display: table
  mode: analytics
  query: type = MergeRequest and project = "gitlab-org/gitlab" and merged > -90d
  dimensions: merged(weekly) as "Week"
  metrics: timeToMergeQuantile(0.5) as "Median time to merge", timeToMergeQuantile(0.95) as "p95 time to merge"
  sort: merged desc
  ```
  ````

- 按状态分组的合并请求：

  ````yaml
  ```glql
  title: "Merge requests by state (last 30 days)"
  display: table
  mode: analytics
  query: type = MergeRequest and project = "gitlab-org/gitlab" and created > -30d
  dimensions: state as "State"
  metrics: totalCount as "Total"
  sort: totalCount desc
  ```
  ````

- 群组内各目标分支的吞吐量：

  ````yaml
  ```glql
  title: "Merge request throughput by target branch"
  display: table
  mode: analytics
  query: type = MergeRequest and group = "gitlab-org" and merged > -30d
  dimensions: targetBranch as "Target branch"
  metrics: totalCount as "Total", throughputCount as "Merged"
  sort: throughputCount desc
  ```
  ````

- 群组的总体合并请求数量（不分组）：

  ````yaml
  ```glql
  title: "Merge requests created in the last 7 days"
  display: table
  mode: analytics
  query: type = MergeRequest and group = "gitlab-org" and created > -7d
  metrics: totalCount as "Total"
  ```
  ````
