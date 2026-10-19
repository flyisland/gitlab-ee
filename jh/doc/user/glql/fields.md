---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GLQL 字段
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 极狐GitLab 查询语言（GLQL） 时，字段可用于：

- 筛选 [GLQL 查询](_index.md#query-syntax)返回的结果。
- 控制[嵌入式视图](_index.md#presentation-syntax)中显示的详细信息。
- 对嵌入式视图中显示的结果进行排序。

您可以在三个嵌入式视图参数中使用字段：

- **`query`** - 设置条件以确定要检索哪些条目。
  `query` 参数可以包含一个或多个
  格式为 `<field> <operator> <value>` 的表达式。多个表达式使用 `and` 连接，
  例如 `group = "gitlab-org" and author = currentUser()`。
- **`fields`** - 指定视图中显示哪些列和详细信息。
  以逗号分隔的字段或[字段函数](functions.md#functions-in-embedded-views)列表，
  例如 `fields: title, state, health, epic, milestone, weight, updated`。
- **`sort`** - 按特定条件对条目排序。
  字段名后跟排序顺序（`asc` 或 `desc`），
  例如 `sort: updated desc`。

<a id="data-sources"></a>

## 数据源

有关支持的数据源及其字段的列表，请参阅 [GLQL 数据源](data_sources/_index.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="query-timeout-errors"></a>

### 查询超时错误

您可能会遇到以下错误消息：

```plaintext
Embedded view timed out. Add more filters to reduce the number of results.
```

```plaintext
Query temporarily blocked due to repeated timeouts. Please try again later or try narrowing your search scope.
```

当查询执行时间过长时，会出现这些错误。结果集过大和搜索范围过广都可能导致超时。

要解决此问题，请添加筛选条件以限制搜索范围：

- 使用 `created`、`updated` 或 `closed` 等日期字段添加时间范围筛选条件，将结果限制在特定时间段内。
  例如：

  ````yaml
  ```glql
  display: table
  fields: title, labels, created
  query: type = Issue and group = "gitlab-org" and label = "group::planner intelligence" and created > "2025-01-01" and created < "2025-03-01"
  ```
  ````

- 按最近更新进行筛选，以关注活跃条目：

  ````yaml
  ```glql
  display: table
  fields: title, labels, updated
  query: type = Issue and group = "gitlab-org" and label = "group::planner intelligence" and updated > -3m
  ```
  ````

- 尽可能使用特定于项目的查询，而不是群组范围的搜索：

  ````yaml
  ```glql
  display: table
  fields: title, state, assignee
  query: type = Issue and project = "gitlab-org/gitlab" and state = opened and updated > -1m
  ```
  ````
