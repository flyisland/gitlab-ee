---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码建议
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

代码建议是一个数据源，提供关于
[极狐GitLab Duo 代码建议](../../project/repository/code_suggestions/_index.md)
在您的项目或群组中使用情况的聚合指标。

<a id="allowed-modes"></a>

## 允许的模式

- [`analytics`](../_index.md#analytics-mode)

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                                                                 |
| --------- | --------------------------------------------------------------------------- |
| `project` | 查询特定项目中的代码建议。                               |
| `group`   | 查询群组内所有项目（包括子群组）的代码建议。 |

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                                      | 名称（和别名） | 运算符                 |
| ------------------------------------------ | ---------------- | ------------------------- |
| [IDE 名称](#cs-ide-name)                   | `ideName`        | `=`, `in`                 |
| [语言](#cs-language)                    | `language`       | `=`, `in`                 |
| [时间戳](#cs-timestamp)                 | `timestamp`      | `=`, `>`, `<`, `>=`, `<=` |
| [用户](#cs-user)                           | `user`           | `=`, `in`                 |

### IDE 名称 {#cs-ide-name}

**描述**：按生成建议所使用的 IDE 进行筛选。

**允许的值类型**：

- `String`
- `List`（多个值使用 `in` 运算符）

### 语言 {#cs-language}

**描述**：按建议的编程语言进行筛选。

**允许的值类型**：

- `String`
- `List`（多个值使用 `in` 运算符）

### 时间戳 {#cs-timestamp}

**描述**：按建议生成的时间进行筛选。
使用范围运算符来定义时间窗口。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

### 用户 {#cs-user}

**描述**：按收到建议的用户进行筛选。

**允许的值类型**：

- `Number`（用户 ID）
- `List`（多个用户 ID 使用 `in` 运算符）

> [!note]
> 用户名筛选的支持正在[议题 599750](https://gitlab.com/gitlab-org/gitlab/-/work_items/599750) 中跟踪。

<a id="dimensions"></a>

## 维度

支持以下维度：

| 维度 | 名称（和别名） | 描述                                          |
|-----------|------------------|------------------------------------------------------|
| IDE 名称  | `ideName`        | 按使用的 IDE 分组（例如，VSCode、JetBrains）。  |
| 语言  | `language`       | 按编程语言分组。                       |
| 时间戳 | `timestamp`      | 按日期分组。仅接受 `monthly` [`granularity` 参数](../_index.md#field-parameters)（默认值：`monthly`）。 |
| 用户      | `user`           | 按用户分组（显示头像、姓名和用户名）。 |

<a id="metrics"></a>

## 指标

支持以下指标：

| 指标              | 名称（和别名）    | 描述                             |
|---------------------|---------------------|-----------------------------------------|
| 接受率     | `acceptanceRate`    | 已接受建议与已显示建议的比率。 |
| 已接受数量      | `acceptedCount`     | 已接受建议的数量。         |
| 已拒绝数量      | `rejectedCount`     | 已拒绝建议的数量。         |
| 已显示数量         | `shownCount`        | 向用户显示的建议数量。   |
| 建议大小总和 | `suggestionSizeSum` | 建议的总量。            |
| 总数量         | `totalCount`        | 建议的总数。            |
| 用户数量         | `usersCount`        | 唯一用户的数量。                 |

<a id="sort-fields"></a>

## 排序字段

按所选维度或指标中包含的任何字段排序。有关更多信息，请参阅[分析模式排序](../_index.md#sorting)。

<a id="examples"></a>

## 示例

- 最近 30 天按语言统计的接受率：

  ````yaml
  ```glql
  display: table
  mode: analytics
  query: type = CodeSuggestion and timestamp >= -30d
  dimensions: language as "Language"
  metrics: totalCount as "Total", acceptanceRate as "Acceptance Rate"
  sort: acceptanceRate desc
  ```
  ````

- 按 IDE 统计的使用情况：

  ````yaml
  ```glql
  display: table
  mode: analytics
  query: type = CodeSuggestion and timestamp >= -30d
  dimensions: ideName as "IDE"
  metrics: totalCount as "Total Suggestions", usersCount as "Active Users"
  sort: totalCount desc
  ```
  ````

- 不分组时的总体指标：

  ````yaml
  ```glql
  display: table
  mode: analytics
  query: type = CodeSuggestion and timestamp >= -30d
  metrics: totalCount as "Total", acceptedCount as "Accepted", rejectedCount as "Rejected", shownCount as "Shown", acceptanceRate as "Acceptance Rate"
  ```
  ````

- 特定项目中每个用户的建议，筛选为 Ruby：

  ````yaml
  ```glql
  display: table
  mode: analytics
  query: type = CodeSuggestion and timestamp >= -30d and language = "ruby"
  dimensions: user as "User"
  metrics: totalCount as "Total", acceptanceRate as "Acceptance Rate"
  sort: totalCount desc
  limit: 10
  ```
  ````

- 日期范围内按语言统计的建议随时间变化情况：

  ````yaml
  ```glql
  display: table
  mode: analytics
  query: type = CodeSuggestion and timestamp >= "2026-01-01" and timestamp <= "2026-03-31"
  dimensions: timestamp as "Date", language as "Language"
  metrics: totalCount as "Total", acceptanceRate as "Acceptance Rate"
  sort: timestamp desc
  ```
  ````

- 筛选到特定 IDE 和语言：

  ````yaml
  ```glql
  display: table
  mode: analytics
  query: type = CodeSuggestion and timestamp >= -7d and ideName in ("Visual Studio Code", "RubyMine") and language in ("ruby", "python")
  dimensions: ideName as "IDE", language as "Language"
  metrics: totalCount as "Total", acceptanceRate as "Rate"
  sort: totalCount desc
  ```
  ````
