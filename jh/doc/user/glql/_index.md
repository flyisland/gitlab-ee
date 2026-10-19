---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 查询语言 (GLQL)
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 于极狐GitLab 17.4 引入，[带有功能标志](../../administration/feature_flags/_index.md) 名为 `glql_integration`。默认禁用。
- 于极狐GitLab 17.4 在 JihuLab.com 上为部分群组和项目启用。
- 于极狐GitLab 17.10 从实验性功能变为 Beta。
- 于极狐GitLab 17.10 在 JihuLab.com 和私有化部署上启用。
- 于极狐GitLab 18.3 GA。功能标志 `glql_integration` 已移除。

{{< /history >}}

极狐GitLab 查询语言 (GLQL) 是适用于整个极狐GitLab 的统一查询语言。
使用它，你可以利用熟悉的语法，从平台的任何地方筛选和嵌入内容。

在 Markdown 代码块中嵌入查询。
嵌入式视图是 GLQL 源代码块的渲染输出。

在 嵌入式视图（由 GLQL 驱动）反馈议题 中分享你的反馈。

<a id="query-syntax"></a>

## 查询语法

查询语法主要由逻辑表达式组成。这些表达式遵循 `<field> <operator> <value> and ...` 的语法。

<a id="data-sources"></a>

### 数据源

GLQL 可以查询不同的数据源，例如工作项、合并请求、流水线、作业和项目。

有关支持的数据源的完整列表，请参见 [GLQL 数据源](data_sources/_index.md)。

<a id="fields"></a>

### 字段

使用字段来筛选、显示和排序结果。

你可以使用的字段取决于你正在查询的数据源。
有关每个数据源支持的字段、运算符和值的完整列表，请参见 [GLQL 字段](fields.md)。

<a id="operators"></a>

### 运算符

**比较运算符**：

| GLQL 运算符 | 描述 | 搜索中的等效项 |
|---------------|-----------------------------------------|------------------------|
| `=` | 等于 / 包含列表中的所有项 | `is`（等于） |
| `!=` | 不等于 / 不包含在列表中 | `is not`（不等于） |
| `in` | 包含在列表中 | `or` / `is one of` |
| `>` | 大于 | {{< no >}} |
| `<` | 小于 | {{< no >}} |
| `>=` | 大于或等于 | {{< no >}} |
| `<=` | 小于或等于 | {{< no >}} |

**逻辑运算符**：仅支持 `and`。
对于某些字段，可以通过使用 `in` 比较运算符间接支持 `or`。

<a id="values"></a>

### 值

值可以包括：

- 字符串
- 数字
- 相对日期（例如 `-1d`、`2w`、`-6m` 或 `1y`）
- 绝对日期（格式为 `YYYY-MM-DD`，例如 `2025-01-01`）
- 函数（例如用于用户字段的 `currentUser()` 或用于日期的 `today()`）
- 枚举值（例如里程碑的 `upcoming` 或 `started`）
- 布尔值（`true` 或 `false`）
- 可空值（例如 `null`、`none` 或 `any`）
- 极狐GitLab 引用（例如标签的 `~label`、里程碑的 `%Backlog` 或用户的 `@username`）
- 包含任何上述值的列表（用括号 `()` 括起来，并用逗号 `,` 分隔）

<a id="embedded-views"></a>

## 嵌入式视图

嵌入式视图是 Markdown 中 GLQL 源代码块的输出。源包含描述如何显示 GLQL 查询结果的 YAML 属性，以及查询本身。

<a id="supported-areas"></a>

### 支持的区域

{{< history >}}

- 于极狐GitLab 18.3 引入了仓库 Markdown 文件中的嵌入式视图。

{{< /history >}}

嵌入式视图可以显示在以下区域：

- 群组和项目 Wiki
- 以下内容的描述和评论：
  - 史诗
  - 议题
  - 合并请求
  - 工作项（任务、OKR 或史诗）
- 仓库 Markdown 文件

<a id="syntax"></a>

### 语法

嵌入式视图源的语法是 YAML 的超集，包括：

- `query` 参数：用逻辑运算符（如 `and`）连接在一起的表达式。
- 与表示层相关的参数，如 `display`、`limit`、`fields`、`title` 和 `description`，以 YAML 表示。

视图在 Markdown 中定义为一个代码块，类似于 Mermaid 等其他代码块。

例如：

- 显示 `gitlab-org/gitlab` 中分配给已认证用户的前 5 个未关闭议题的表格。
- 显示列 `title`、`state`、`health`、`description`、`epic`、`milestone`、`weight` 和 `updated`。

````yaml
```glql
display: table
title: GLQL table 🎉
description: This view lists my open issues
fields: title, state, health, epic, milestone, weight, updated
limit: 5
query: type = Issue AND group = "gitlab-org" AND assignee = currentUser() AND state = opened
```
````

此源应渲染出如下所示的表格：

![列出分配给当前用户的议题的表格](img/glql_table_v18_5.png)

<a id="presentation-syntax"></a>

#### 表示语法

{{< history >}}

- 于极狐GitLab 17.7 变更：使用 YAML 前置信息配置表示层已弃用。
- 于极狐GitLab 17.10 引入了 `title` 和 `description` 参数。
- 于极狐GitLab 18.2 引入了排序和分页。
- 于极狐GitLab 18.3 引入了 `collapsed` 参数。

{{< /history >}}

除了 `query` 参数之外，你还可以使用一些可选参数来配置视图的表示细节。

支持的参数：

| 参数 | 默认值 | 描述 |
| ------------- | --------------------------------------------- | ----------- |
| `collapsed` | `false` | 是否折叠或展开视图。 |
| `description` | 无 | 在标题下方显示的可选描述。 |
| `display` | `table` | 数据的显示方式。支持的选项：`table`、`list` 或 `orderedList`。 |
| `fields` | `title` | 要包含在视图中的 [字段](fields.md) 的逗号分隔列表。 |
| `limit` | `100` | 在第一页上显示的项目数。最大值为 `100`。 |
| `sort` | `updated desc` | 用于[排序数据的字段](fields.md)，后跟排序顺序（`asc` 或 `desc`）。 |
| `title` | 嵌入式表格视图 或 嵌入式列表视图 | 显示在嵌入式视图顶部的标题。 |

例如，要在 `gitlab-org/gitlab` 项目中以列表形式显示分配给当前用户的前五个议题，按截止日期排序（最早的在前），并显示 `title`、`health` 和 `due` 字段：

````yaml
```glql
display: list
fields: title, health, due
limit: 5
sort: due asc
query: type = Issue AND group = "gitlab-org" AND assignee = currentUser() AND state = opened
```
````

此源应渲染出如下所示的列表：

![显示分配给当前用户的议题列表的嵌入式视图](img/glql_list_v18_5.png)

<a id="pagination"></a>

#### 分页

{{< history >}}

- 于极狐GitLab 18.2 引入。

{{< /history >}}

默认情况下，嵌入式视图显示第一页结果。
`limit` 参数控制显示的项目数。

要加载下一页，请在最后一行选择 **加载更多**。

<a id="field-functions"></a>

#### 字段函数

要创建动态生成的列，请在视图的 `fields` 参数中使用函数。
有关完整列表，请参见 [嵌入式视图中的函数](functions.md#functions-in-embedded-views)。

<a id="custom-field-aliases"></a>

#### 自定义字段别名

{{< history >}}

- 于极狐GitLab 18.0 引入。

{{< /history >}}

要将表格视图的列重命名为自定义值，请使用 `AS` 语法关键字为字段设置别名。

````yaml
```glql
display: list
fields: title, labels("workflow::*") AS "Workflow", labels("priority::*") AS "Priority"
limit: 5
query: type = Issue AND project = "gitlab-org/gitlab" AND assignee = currentUser() AND state = opened
```
````

此源显示一个包含 `Title`、`Workflow` 和 `Priority` 列的视图。

<a id="view-actions"></a>

### 视图操作

{{< history >}}

- 于极狐GitLab 17.11 引入。
- 于极狐GitLab 18.0 引入了 **重新加载** 操作。

{{< /history >}}

当视图出现在页面上时，使用 **视图操作** ({{< icon name="ellipsis_v" >}}) 下拉列表对其进行操作。

支持的操作：

| 操作 | 描述 |
| ------------- | -------------------------------------------------------------- |
| 查看源 | 查看视图的源。 |
| 复制源 | 将视图的源复制到剪贴板。 |
| 复制内容 | 将表格或列表内容复制到剪贴板。 |
| 重新加载 | 重新加载此视图。 |

<a id="advanced-search-integration"></a>

## 高级搜索集成

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 于极狐GitLab 18.6 引入为 [Beta](../../policy/development_stages_support.md#beta)，带有[功能标志](../../administration/feature_flags/_index.md) 名为 `glql_work_items` 和 `glql_es_integration`。默认启用。
- 功能标志 `glql_work_items` 在极狐GitLab 18.10 中已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 有关更多信息，请参见历史记录。

GLQL 在可用时使用高级搜索来加速查询。高级搜索为跨大型数据集的复杂查询提供更快的响应时间。

高级搜索：

- 对于 JihuLab.com 的付费订阅，默认启用。
- 当管理员[启用高级搜索](../../integration/advanced_search/elasticsearch.md#enable-advanced-search)时，可用于私有化部署。

如果高级搜索不可用，GLQL 则使用 PostgreSQL。