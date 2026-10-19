---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: AI 使用事件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

AI 使用事件是一种数据源，提供关于您的项目或群组中极狐GitLab Duo 功能使用情况的聚合指标。

<a id="allowed-modes"></a>

## 允许的模式

- [`analytics`](../_index.md#analytics-mode)

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                                                                 |
| --------- | --------------------------------------------------------------------------- |
| `project` | 查询特定项目中的 AI 使用事件。                                |
| `group`   | 查询群组中所有项目（包括子群组）的 AI 使用事件。  |

有关更多信息，请参阅[范围](_index.md#scopes)。

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                                | 名称            | 运算符                 |
| ------------------------------------ | --------------- | ------------------------- |
| [事件](#event)                      | `event`         | `=`, `in`                 |
| [功能](#feature)                  | `feature`       | `=`, `in`                 |
| [功能数量](#features-count)    | `featuresCount` | `>`, `<`, `>=`, `<=`      |
| [时间戳](#timestamp)              | `timestamp`     | `=`, `>`, `<`, `>=`, `<=` |
| [用户](#user)                        | `user`          | `=`, `in`                 |

### 事件 {#event}

**描述**：按事件标识符筛选。

**允许的值类型**：

- `String`
- `List`（多个值使用 `in` 运算符）

### 功能 {#feature}

**描述**：按生成事件的极狐GitLab Duo 功能筛选。例如，`code_suggestions` 或 `chat`。

**允许的值类型**：

- `String`
- `List`（多个值使用 `in` 运算符）

### 功能数量 {#features-count}

**描述**：按使用的唯一功能数量筛选。此筛选仅在同时选择 `featuresCount` 指标时有效。

**允许的值类型**：`Number`

### 时间戳 {#timestamp}

**描述**：按事件发生时间筛选。使用范围运算符定义时间窗口。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户所在时区的 00:00 至 23:59 计算。

### 用户 {#user}

**描述**：按触发事件的用户筛选。

**允许的值类型**：

- `Number`（用户 ID）
- `List`（多个用户 ID 使用 `in` 运算符）

> [!note]
> 用户名筛选的支持正在[议题 599750](https://gitlab.com/gitlab-org/gitlab/-/work_items/599750) 中跟踪。

<a id="dimensions"></a>

## 维度

| 维度 | 名称        | 描述                                          |
| --------- | ----------- | ---------------------------------------------------- |
| 事件     | `event`     | 按事件标识符分组。                           |
| 功能   | `feature`   | 按极狐GitLab Duo 功能分组。                         |
| 时间戳 | `timestamp` | 按日期分组。接受 [`granularity` 参数](../_index.md#field-parameters)，值为 `daily`、`weekly` 或 `monthly`（默认：`weekly`）。例如，`timestamp(daily)`。 |
| 用户      | `user`      | 按用户分组（显示头像、姓名和用户名）。 |

<a id="metrics"></a>

## 指标

| 指标                      | 名称                      | 描述                                             |
| --------------------------- | ------------------------- | ------------------------------------------------------- |
| 功能数量              | `featuresCount`           | 使用的唯一功能数量。                         |
| 上一周期用户数 | `previousPeriodUsersCount` | 上一周期内的唯一用户数。         |
| 回访用户数       | `returningUsersCount`     | 在当前周期和上一周期均活跃的用户数。 |
| 总数                 | `totalCount`              | 事件总数。                                 |
| 用户数                 | `usersCount`              | 唯一用户数。                                 |

**注意**：

- `returningUsersCount` 和 `previousPeriodUsersCount` 指标仅在同时选择 `timestamp` 维度时有效。

<a id="sort-fields"></a>

## 排序字段

按所选维度或指标中包含的任何字段排序。有关更多信息，请参阅[分析模式排序](../_index.md#sorting)。

<a id="examples"></a>

## 示例

- 最近 30 天的功能采用情况：

  ````yaml
  ```glql
  title: "GitLab Duo feature adoption (last 30 days)"
  display: table
  mode: analytics
  query: type = AiUsageEvent and group = "gitlab-org" and timestamp > -30d
  dimensions: feature as "Feature"
  metrics: totalCount as "Total events", usersCount as "Users"
  sort: usersCount desc
  ```
  ````

- 包含回访用户的每周使用趋势：

  ````yaml
  ```glql
  title: "Weekly GitLab Duo usage trend"
  display: table
  mode: analytics
  query: type = AiUsageEvent and group = "gitlab-org" and timestamp > -30d
  dimensions: timestamp(weekly) as "Week"
  metrics: usersCount as "Users", returningUsersCount as "Returning users", previousPeriodUsersCount as "Previous period users"
  sort: timestamp desc
  ```
  ````

- 特定项目中每个用户的事件：

  ````yaml
  ```glql
  title: "GitLab Duo events by user"
  display: table
  mode: analytics
  query: type = AiUsageEvent and project = "gitlab-org/gitlab" and timestamp > -30d
  dimensions: user as "User"
  metrics: totalCount as "Total events"
  sort: totalCount desc
  limit: 10
  ```
  ````

- 不分组时的总体唯一用户数：

  ````yaml
  ```glql
  title: "Unique GitLab Duo users (last 30 days)"
  display: table
  mode: analytics
  query: type = AiUsageEvent and group = "gitlab-org" and timestamp > -30d
  metrics: usersCount as "Users"
  ```
  ````
