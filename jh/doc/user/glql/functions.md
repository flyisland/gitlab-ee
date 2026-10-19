---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GLQL 函数
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [极狐GitLab 查询语言（GLQL）](_index.md)中的函数来创建动态查询。

<a id="functions-inside-query"></a>

## 查询中的函数

要使查询与上下文相关，请在[查询](_index.md#query-syntax)中使用函数，例如按当前用户或日期进行筛选。

<a id="current-user"></a>

### 当前用户

**函数名称**：`currentUser`

**参数**：无

**语法**：`currentUser()`

**描述**：求值为当前已认证用户。

**其他详细信息**：

- 在查询中使用此函数会导致未认证用户的查询失败。

**示例**：

- 列出当前已认证用户是指派人的所有议题：

  ```plaintext
  assignee = currentUser()
  ```

- 列出当前已认证用户是指派人但不是作者的所有合并请求：

  ```plaintext
  type = MergeRequest and assignee = currentUser() and author != currentUser()
  ```

<a id="today"></a>

### 今天

**函数名称**：`today`

**参数**：无

**语法**：`today()`

**描述**：求值为用户时区中今天 00:00 的日期。

**其他详细信息**：

- 与 `=` 运算符一起使用时，时间范围被视为用户时区中的 00:00 到 23:59。

**示例**：

- 列出今天创建的所有议题：

  ```plaintext
  created = today()
  ```

- 列出今天合并的所有合并请求：

  ```plaintext
  type = MergeRequest and merged = today()
  ```

<a id="functions-in-embedded-views"></a>

## 嵌入视图中的函数

要从[嵌入视图](_index.md#embedded-views)的现有字段派生新列，请在 `fields` 参数中包含函数。

<a id="extract-labels-into-a-new-column"></a>

### 将标记提取到新列

**函数名称**：`labels`

**参数**：一个或多个 `String` 值

**语法**：`labels("field1", "field2")`

**描述**：

`labels` 函数接受一个或多个标记名称字符串值作为参数，并创建一个仅包含议题上这些标记的筛选列。该函数还可用作提取器，因此如果某个标记已被提取，那么当您选择同时显示常规的 `labels` 列时，该标记将不再显示在该列中。

**其他详细信息**：

- 默认情况下，此函数会查找与标记名称完全匹配的项。在字符串中使用通配符（`*`）可匹配任意字符。
- 传递给 `labels` 函数的标记名称最少为 1 个，最多为 100 个。
- 传递给此函数的标记名称不区分大小写。例如，`Deliverable` 和 `deliverable` 是等效的。

**示例**：

- 在列中包含所有 `workflow` 作用域标记：

  ```plaintext
  labels("workflow::*")
  ```

- 包含标记 `Deliverable`、`Stretch` 和 `Spike`：

  ```plaintext
  labels("Deliverable", "Stretch", "Spike")
  ```

- 包含所有类似 `backend`、`frontend` 以及其他以 `end` 结尾的标记：

  ```plaintext
  labels("*end")
  ```

要在嵌入视图中包含 `labels` 函数：

````markdown
```glql
display: list
fields: title, health, due, labels("workflow::*"), labels
limit: 5
query: project = "gitlab-org/gitlab" AND assignee = currentUser() AND state = opened
```
````
