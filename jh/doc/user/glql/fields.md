---
title: GLQL 字段
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.4 中引入，带有名为 `glql_integration` 的功能标志。默认禁用。
- 在极狐GitLab 17.4 中为部分群组和项目在 JihuLab.com 上启用。
- 在极狐GitLab 17.10 中从实验阶段变更为 [beta](../../policy/development_stages_support.md#beta) 阶段。
- 在极狐GitLab 17.10 中，已在 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 18.3 中 GA。功能标志 `glql_integration` 已移除。

{{< /history >}}

<a id="glql-fields"></a>

## GLQL 字段

使用极狐GitLab 查询语言（GLQL），字段用于：

- 过滤从 [GLQL 查询](_index.md#query-syntax)返回的结果。
- 控制[嵌入式视图](_index.md#presentation-syntax)中显示的详细信息。
- 对嵌入式视图中显示的结果进行排序。

你可以在三个嵌入式视图参数中使用字段：

- **`query`** - 设置条件以确定要检索的项。
  `query` 参数可以包含一个或多个格式为 `<field> <operator> <value>` 的表达式。多个表达式用 `and` 连接，
  例如 `group = "gitlab-org" and author = currentUser()`。
- **`fields`** - 指定视图中显示的列和详细信息。
  一个逗号分隔的字段或[字段函数](functions.md#functions-in-embedded-views)列表，
  例如 `fields: title, state, health, epic, milestone, weight, updated`。
- **`sort`** - 按特定条件对项进行排序。
  一个字段名后跟排序顺序（`asc` 或 `desc`），
  例如 `sort: updated desc`。

<a id="data-sources"></a>

## 数据源

有关支持的数据源及其字段的列表，请参见 [GLQL 数据源](data_sources/_index.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="query-timeout-errors"></a>

### 查询超时错误

你可能会遇到以下错误消息：

```plaintext
嵌入式视图超时。请添加更多过滤器以减少结果数。
```

```plaintext
由于重复超时，查询暂时被阻止。请稍后重试，或尝试缩小搜索范围。
```

当查询执行时间过长时，会出现这些错误。大量结果集和宽泛的搜索可能导致超时。

要解决此问题，请添加过滤器以限制搜索范围：

- 添加时间范围过滤器，使用日期字段（如 `created`、`updated` 或 `closed`）将结果限制到特定时间段。例如：

  ````yaml
  ```glql
  display: table
  fields: title, labels, created
  query: type = Issue and group = "gitlab-org" and label = "group::knowledge" and created > "2025-01-01" and created < "2025-03-01"
  ```
  ````

- 按最近的更新进行过滤，以关注活跃项：

  ````yaml
  ```glql
  display: table
  fields: title, labels, updated
  query: type = Issue and group = "gitlab-org" and label = "group::knowledge" and updated > -3m
  ```
  ````

- 尽可能使用项目特定的查询，而不是群组范围的搜索：

  ````yaml
  ```glql
  display: table
  fields: title, state, assignee
  query: type = Issue and project = "gitlab-org/gitlab" and state = opened and updated > -1m
  ```
  ````

<a id="error-invalid-username-reference"></a>

### 错误：`无效的用户名引用`

在 GLQL 查询中使用 `@` 符号引用以数字开头的用户名时，可能会遇到错误，提示 `无效的用户名引用`。例如：

```plaintext
尝试显示此嵌入式视图时发生错误：
* 错误：无效的用户名引用 @123username
```

出现此问题的原因是 GLQL 嵌入式视图渲染器不支持以数字开头的用户名使用 `@` 提及，即使这些用户名在极狐GitLab 中是有效的。

解决方法是移除 `@` 符号，并用引号将用户名括起来。例如，使用 `assignee = "123username"` 而不是 `assignee = @123username`。

