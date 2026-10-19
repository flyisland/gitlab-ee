---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线分析
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

分析模式返回所有状态下流水线的聚合指标，包括进行中的流水线，数据通常可在十分钟内获取。

要查询单个流水线记录，请使用[流水线](pipelines.md)。

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                                                          |
| --------- | -------------------------------------------------------------------- |
| `project` | 查询特定项目中的流水线。                               |
| `group`   | 查询群组（包括子群组）中所有项目的流水线。 |

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                                  | 名称       | 运算符                 |
| -------------------------------------- | ---------- | ------------------------- |
| [完成时间](#finished-at)         | `finished` | `=`, `>`, `<`, `>=`, `<=` |
| [引用](#ref)                         | `ref`      | `=`, `in`                 |
| [来源](#source)                   | `source`   | `=`, `in`                 |
| [开始时间](#started-at)           | `started`  | `=`, `>`, `<`, `>=`, `<=` |
| [状态](#status)                   | `status`   | `=`, `in`                 |

### 完成时间 {#finished-at}

**描述**：按完成日期筛选流水线。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 引用 {#ref}

**描述**：按流水线运行所在的 Git 引用（分支或标签名称）筛选流水线。

**允许的值类型**：

- `String`
- `List`（多个值使用 `in` 运算符）

### 来源 {#source}

**描述**：按触发事件筛选流水线。

**允许的值类型**：

- `String`
- `List`（多个值使用 `in` 运算符）

### 开始时间 {#started-at}

**描述**：按开始日期筛选流水线。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 状态 {#status}

**描述**：按 CI/CD 状态筛选流水线。

**允许的值类型**：

- `Enum`，为 `canceled`、`canceling`、`created`、`failed`、`manual`、`pending`、`preparing`、`running`、`scheduled`、`skipped`、`success`、`waiting_for_callback` 或 `waiting_for_resource` 之一
- `List`（多个值使用 `in` 运算符）

<a id="dimensions"></a>

## 维度

| 维度   | 名称       | 描述                              |
| ----------- | ---------- | ---------------------------------------- |
| 完成时间 | `finished` | 按完成日期分组。接受 [`granularity` 参数](../_index.md#field-parameters)，值为 `daily`、`weekly` 或 `monthly`（默认值：`weekly`）。例如，`finished(daily)`。 |
| 项目     | `project`  | 按项目分组。                        |
| 引用         | `ref`      | 按 Git 引用（分支或标签）分组。        |
| 来源      | `source`   | 按触发流水线的事件分组。    |
| 开始时间  | `started`  | 按开始日期分组。接受 [`granularity` 参数](../_index.md#field-parameters)，值为 `daily`、`weekly` 或 `monthly`（默认值：`weekly`）。例如，`started(daily)`。 |
| 状态      | `status`   | 按流水线状态分组。                |

<a id="metrics"></a>

## 指标

当流水线完成处理并达到最终状态（成功、失败、已取消或已跳过）时，即视为已完成。

| 指标            | 名称               | 描述                                            |
| ----------------- | ------------------ | ------------------------------------------------------ |
| 取消率     | `canceledRate`     | 已取消的流水线与已完成的流水线之比。    |
| 时长分位数 | `durationQuantile` | 流水线时长分位数，单位为秒。接受 [`quantile` 参数](../_index.md#field-parameters)，值介于 `0.01` 和 `0.99` 之间（默认值：`0.95`）。例如，`durationQuantile(0.5)`。 |
| 失败率      | `failureRate`      | 失败的流水线与已完成的流水线之比。      |
| 跳过率      | `skippedRate`      | 已跳过的流水线与已完成的流水线之比。     |
| 成功率      | `successRate`      | 成功的流水线与已完成的流水线之比。  |
| 总计数       | `totalCount`       | 流水线的总数，包括进行中的。 |

<a id="sort-fields"></a>

## 排序字段

按所选维度或指标中包含的任何字段排序。有关更多信息，请参阅[分析模式排序](../_index.md#sorting)。

<a id="examples"></a>

## 示例

- 最近 30 天内按引用统计的流水线成功率和失败率：

  ````yaml
  ```glql
  title: "Pipeline success and failure rates by branch (last 30 days)"
  display: table
  mode: analytics
  query: type = Pipeline and project = "gitlab-org/gitlab" and finished >= -30d
  dimensions: ref as "Ref"
  metrics: totalCount as "Total", successRate as "Success rate", failureRate as "Failure rate"
  sort: totalCount desc
  ```
  ````

- 特定引用的流水线每周时长趋势：

  ````yaml
  ```glql
  title: "Weekly pipeline duration trend for master"
  display: table
  mode: analytics
  query: type = Pipeline and project = "gitlab-org/gitlab" and ref = "master" and finished >= -90d
  dimensions: finished as "Week"
  metrics: totalCount as "Total", durationQuantile as "p95 duration (s)"
  sort: finished desc
  ```
  ````

- 每周流水线时长的中位数和 p95：

  ````yaml
  ```glql
  title: "Median and p95 pipeline duration by week"
  display: table
  mode: analytics
  query: type = Pipeline and project = "gitlab-org/gitlab" and finished >= -90d
  dimensions: finished(weekly) as "Week", status as "Status"
  metrics: durationQuantile(0.5) as "Median", durationQuantile(0.95) as "p95", totalCount as "Total"
  sort: Median desc
  ```
  ````

- 群组的整体流水线指标，不进行分组：

  ````yaml
  ```glql
  title: "Overall pipeline metrics for gitlab-org"
  display: table
  mode: analytics
  query: type = Pipeline and group = "gitlab-org" and finished >= -7d
  metrics: totalCount as "Total", successRate as "Success rate", failureRate as "Failure rate", canceledRate as "Canceled rate"
  ```
  ````

- 按来源和状态分组，并筛选到特定日期范围的流水线：

  ````yaml
  ```glql
  title: "Pipelines by source and status (Q1 2026)"
  display: table
  mode: analytics
  query: type = Pipeline and project = "gitlab-org/gitlab" and finished >= "2026-01-01" and finished <= "2026-03-31"
  dimensions: source as "Source", status as "Status"
  metrics: totalCount as "Total"
  sort: totalCount desc
  ```
  ````

- 跨群组筛选特定引用和状态：

  ````yaml
  ```glql
  title: "Default branch pipeline outcomes across gitlab-org"
  display: table
  mode: analytics
  query: type = Pipeline and group = "gitlab-org" and finished >= -14d and ref in ("master", "main") and status in ("success", "failed")
  dimensions: project as "Project", status as "Status"
  metrics: totalCount as "Total", successRate as "Success rate"
  sort: totalCount desc
  limit: 20
  ```
  ````
