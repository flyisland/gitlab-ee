---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GLQL 函数
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.4 中作为一个[功能标志](../../administration/feature_flags/_index.md)引入，名称为 `glql_integration`。默认禁用。
- 在极狐GitLab 17.4 中，已在 JihuLab.com 上针对部分群组和项目启用。
- 在极狐GitLab 17.10 中，从实验更改为 [beta](../../policy/development_stages_support.md#beta)。
- 在极狐GitLab 17.10 中，已在 JihuLab.com 和私有化部署中启用。
- 在极狐GitLab 18.3 中 GA。功能标志 `glql_integration` 已移除。

{{< /history >}}

使用 [GitLab Query Language (GLQL)](_index.md) 的函数创建动态查询。

<a id="functions-inside-query"></a>

## 查询中的函数

要使查询与上下文相关，请在[查询](_index.md#query-syntax)中使用函数，例如，
按当前用户或日期筛选。

### 当前用户

**函数名称**：`currentUser`

**参数**：无

**语法**：`currentUser()`

**描述**：求值为当前已认证用户。

**附加信息**：

- 在查询中使用此函数会导致未认证用户的查询失败。

**示例**：

- 列出所有当前已认证用户为指派人的议题：

  ```plaintext
  assignee = currentUser()
  ```

- 列出所有当前已认证用户为指派人但非作者的合并请求：

  ```plaintext
  type = MergeRequest and assignee = currentUser() and author != currentUser()
  ```

### 今天

**函数名称**：`today`

**参数**：无

**语法**：`today()`

**描述**：求值为用户时区中今天的日期 00:00。

**附加信息**：

- 当与 `=` 运算符一起使用时，时间范围被视为用户时区中的 00:00 到 23:59。

**示例**：

- 列出所有今天创建的议题：

  ```plaintext
  created = today()
  ```

- 列出所有今天合并的合并请求：

  ```plaintext
  type = MergeRequest and merged = today()
  ```

<a id="functions-in-embedded-views"></a>

## 嵌入式视图中的函数

要从[嵌入式视图](_index.md#embedded-views)的现有字段派生新列，可在 `fields` 参数中包含
函数。

### 将标签提取到新列

**函数名称**：`labels`

**参数**：一个或多个 `String` 值

**语法**：`labels("field1", "field2")`

**描述**：

`labels` 函数接受一个或多个标签名称字符串值作为参数，
并创建一个仅包含议题上这些标签的筛选列。
该函数也作为提取器工作，因此如果标签已被提取，它将不再显示
在常规的 `labels` 列中，如果你选择也显示该列的话。

**附加信息**：

- 默认情况下，此函数查找与标签名称完全匹配的项。
  字符串中可以使用通配符 (`*`) 匹配任意字符。
- 最少可向 `labels` 函数传递 1 个标签名称，最多 100 个。
- 传递给此函数的标签名称不区分大小写。例如，`Deliverable` 和 `deliverable` 等效。

**示例**：

- 在列中包含所有 `workflow` 作用域标签：

  ```plaintext
  labels("workflow::*")
  ```

- 包含标签 `Deliverable`、`Stretch` 和 `Spike`：

  ```plaintext
  labels("Deliverable", "Stretch", "Spike")
  ```

- 包含所有类似 `backend`、`frontend` 及其他以 `end` 结尾的标签：

  ```plaintext
  labels("*end")
  ```

要在嵌入式视图中包含 `labels` 函数：

````markdown
```glql
display: list
fields: title, health, due, labels("workflow::*"), labels
limit: 5
query: project = "gitlab-org/gitlab" AND assignee = currentUser() AND state = opened
```
````

