---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GLQL API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 以编程方式执行 [极狐GitLab 查询语言（GLQL）](../user/glql/_index.md)查询。GLQL 提供了一种简化的查询语言，用于跨项目和群组搜索和筛选[极狐GitLab 资源](../user/glql/_index.md#supported-areas)，例如议题、合并请求和史诗。

先决条件：

- 群组或项目必须允许访问其数据。
- 对于私有群组和项目，您必须使用具有相应权限的
  [个人访问令牌](../user/profile/personal_access_tokens.md)。

<a id="execute-a-glql-query"></a>

## 执行 GLQL 查询

执行 GLQL 查询以搜索和筛选极狐GitLab 资源。

```plaintext
POST /glql
```

> [!note]
> 此端点根据查询的 SHA 对查询进行速率限制。超时的相同查询会被
> 跟踪，如果执行过于频繁，可能会被暂时阻止。

支持的属性：

| 属性   | 类型   | 必需 | 描述                                                                                                                           |
|-------------|--------|----------|---------------------------------------------------------------------------------------------------------------------------------------|
| `glql_yaml` | string | 是      | 带有可选 YAML 配置的 GLQL 查询。最大大小：10,000 字节（10 KB）。有关详细信息，请参阅[查询格式](#query-formats)。 |
| `after`     | string | 否       | 用于分页的游标。使用上一次查询的 `data.pageInfo.endCursor` 值来获取下一页结果。               |

<a id="query-formats"></a>

### 查询格式

`glql_yaml` 参数接受带有 `query` 键的 YAML 格式：

```yaml
fields: id,title,author
group: my-group
limit: 10
sort: created desc
query: state = opened
```

<a id="configuration-options"></a>

### 配置选项

可以在 YAML 中包含以下配置选项：

| 选项    | 类型    | 必需 | 描述 |
|-----------|---------|----------|-------------|
| `fields`  | string  | 否       | 要返回的字段的逗号分隔列表。默认值：`title`。请参阅[可用字段](#available-fields)。 |
| `group`   | string  | 否       | 将查询范围限定到特定群组。不能与 `project` 一起使用。如果查询中也指定了 `group`，则以查询中的值为准。 |
| `limit`   | integer | 否       | 要返回的最大结果数。必须介于 1 和 100 之间。默认值：`100`。 |
| `project` | string  | 否       | 将查询范围限定到特定项目。格式：`group/project`。如果查询中也指定了 `project`，则以查询中的值为准。 |
| `sort`    | string  | 否       | 结果的排序顺序。格式：`field direction`（例如，`created asc` 或 `created desc`）。 |

<a id="available-fields"></a>

### 可用字段

将 `fields` 配置选项设置为[可用 GLQL 字段](../user/glql/fields.md)的逗号分隔列表。

<a id="glql-query-syntax"></a>

### GLQL 查询语法

查询语法由 [GLQL](../user/glql/_index.md#query-syntax) 定义。

<a id="response-attributes"></a>

### 响应属性

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                       | 类型    | 描述 |
|---------------------------------|---------|-------------|
| `data`                          | object  | 包含查询结果。 |
| `data.count`                    | integer | 匹配结果的总数。 |
| `data.nodes`                    | array   | 包含所请求字段的匹配资源数组。 |
| `data.pageInfo`                 | object  | 分页信息。 |
| `data.pageInfo.endCursor`       | string  | 用于获取下一页结果的游标。 |
| `data.pageInfo.hasNextPage`     | boolean | 指示是否有更多结果可用。 |
| `data.pageInfo.hasPreviousPage` | boolean | 指示是否有上一页结果可用。 |
| `data.pageInfo.startCursor`     | string  | 用于获取上一页结果的游标。 |
| `error`                         | string  | 查询失败时的错误消息。 |
| `fields`                        | array   | 字段定义数组。 |
| `fields[].field`                | string  | 基础字段名称。对于带别名的参数化字段，这是底层字段名称（例如 `durationQuantile`），而 `key` 是别名（例如 `p50`）。对于标准字段，与 `key` 相同。 |
| `fields[].key`                  | string  | 唯一字段标识符。 |
| `fields[].label`                | string  | 人类可读的字段名称。 |
| `fields[].name`                 | string  | 用于统一相似字段的通用字段名称。例如，`created` 和 `createdAt` 键的名称均为 `createdAt`。对于带别名的参数化字段，这是生成的响应键（例如 `durationQuantile_quantile_0_d5`），而不是通用名称。 |
| `fields[].parameters`           | object  | 参数化字段的已解析参数元数据。当字段没有参数时不存在。值为字符串，对于列表参数则为字符串数组。例如，`{"granularity": "weekly"}`、`{"quantile": "0.5"}` 或 `{"thresholds": ["4", "25", "100"]}`。 |
| `fields[].type`                 | string  | 字段分类：对于分析模式字段，为 `dimension` 或 `metric`。对于标准字段则不存在。 |
| `success`                       | boolean | 指示查询是否成功。 |

<a id="example-basic-query"></a>

### 示例：基本查询

搜索群组中已开启的议题：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "glql_yaml": "query: group = \"my-group\" AND state = opened"
  }' \
  --url "https://gitlab.example.com/api/v4/glql"
```

示例响应：

```json
{
  "data": {
    "count": 1,
    "nodes": [
      {
        "id": "gid://gitlab/Issue/123",
        "iid": "123",
        "reference": "#123",
        "state": "OPEN",
        "title": "Add an example of GoLang HTTP server",
        "webUrl": "https://gitlab.example.com/my-group/my-project/-/issues/123",
        "widgets": null
      }
    ],
    "pageInfo": {
      "endCursor": "eyJpZCI6IjEyMyJ9",
      "hasNextPage": false,
      "hasPreviousPage": false,
      "startCursor": "eyJpZCI6IjEyMyJ9"
    }
  },
  "error": null,
  "fields": [
    {
      "field": "title",
      "key": "title",
      "label": "Title",
      "name": "title"
    }
  ],
  "success": true
}
```

<a id="example-query-with-front-matter-configuration"></a>

### 示例：带 front matter 配置的查询

使用自定义字段和排序进行搜索：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "glql_yaml": "fields: id,title,author,state\ngroup: my-group\nlimit: 5\nsort: created desc\nquery: state = opened"
  }' \
  --url "https://gitlab.example.com/api/v4/glql"
```

示例响应：

```json
{
  "data": {
    "count": 2,
    "nodes": [
      {
        "author": {
          "avatarUrl": "https://www.gravatar.com/avatar/4a17cff4a15e98966063bd203d88aceac682c623e74943a08cdbe0cce87c6d7c?s=80&d=identicon",
          "id": "gid://gitlab/User/123",
          "name": "John Doe",
          "username": "johndoe",
          "webUrl": "https://gitlab.example.com/johndoe"
        },
        "id": "gid://gitlab/Issue/123",
        "iid": "123",
        "reference": "#123",
        "state": "OPEN",
        "title": "Add an example of GoLang HTTP server",
        "webUrl": "https://gitlab.example.com/my-group/my-project/-/issues/123",
        "widgets": null
      },
      {
        "author": {
          "avatarUrl": "https://www.gravatar.com/avatar/4a17cff4a15e98966063bd203d88aceac682c623e74943a08cdbe0cce87c6d7c?s=80&d=identicon",
          "id": "gid://gitlab/User/122",
          "name": "Jane Doe",
          "username": "janedoe",
          "webUrl": "https://gitlab.example.com/janedoe"
        },
        "id": "gid://gitlab/Issue/122",
        "iid": "122",
        "reference": "#122",
        "state": "OPEN",
        "title": "HTTP server examples for all programming languages",
        "webUrl": "https://gitlab.example.com/groups/my-group/-/issues/122",
        "widgets": null
      }
    ],
    "pageInfo": {
      "endCursor": "eyJpZCI6IjEyMyJ9",
      "hasNextPage": false,
      "hasPreviousPage": false,
      "startCursor": "eyJpZCI6IjEyMyJ9"
    }
  },
  "error": null,
  "fields": [
    {
      "field": "id",
      "key": "id",
      "label": "ID",
      "name": "id"
    },
    {
      "field": "title",
      "key": "title",
      "label": "Title",
      "name": "title"
    },
    {
      "field": "author",
      "key": "author",
      "label": "Author",
      "name": "author"
    },
    {
      "field": "state",
      "key": "state",
      "label": "State",
      "name": "state"
    }
  ],
  "success": true
}
```

<a id="example-query-with-project-scope"></a>

### 示例：带项目范围的查询

在特定项目中搜索：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "glql_yaml": "query: project = \"my-group/my-project\" AND state = opened"
  }' \
  --url "https://gitlab.example.com/api/v4/glql"
```

<a id="example-query-with-currentuser-function"></a>

### 示例：使用 `currentUser()` 函数的查询

搜索分配给当前用户的议题：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "glql_yaml": "fields: id,title,assignees\nquery: group = \"my-group\" AND assignee = currentUser()"
  }' \
  --url "https://gitlab.example.com/api/v4/glql"
```

示例响应：

```json
{
  "data": {
    "count": 1,
    "nodes": [
      {
        "assignees": {
          "nodes": [
            {
              "avatarUrl": "https://www.gravatar.com/avatar/4a17cff4a15e98966063bd203d88aceac682c623e74943a08cdbe0cce87c6d7c?s=80&d=identicon",
              "id": "gid://gitlab/User/123",
              "name": "John Doe",
              "username": "johndoe",
              "webUrl": "https://gitlab.example.com/johndoe"
            }
          ]
        },
        "id": "gid://gitlab/Issue/123",
        "iid": "123",
        "reference": "#123",
        "state": "OPEN",
        "title": "Add an example of GoLang HTTP server",
        "webUrl": "https://gitlab.example.com/my-group/my-project/-/issues/123",
        "widgets": null
      }
    ],
    "pageInfo": {
      "endCursor": "eyJpZCI6IjEyMyJ9",
      "hasNextPage": false,
      "hasPreviousPage": false,
      "startCursor": "eyJpZCI6IjEyMyJ9"
    }
  },
  "error": null,
  "fields": [
    {
      "field": "id",
      "key": "id",
      "label": "ID",
      "name": "id"
    },
    {
      "field": "title",
      "key": "title",
      "label": "Title",
      "name": "title"
    },
    {
      "field": "assignees",
      "key": "assignees",
      "label": "Assignees",
      "name": "assignees"
    }
  ],
  "success": true
}
```

<a id="example-query-with-limit-and-pagination"></a>

### 示例：带限制和分页的查询

检索有限数量的结果并对其进行分页：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "glql_yaml": "limit: 2\nquery: group = \"my-group\" AND state = opened"
  }' \
  --url "https://gitlab.example.com/api/v4/glql"
```

示例响应：

```json
{
  "data": {
    "count": 68,
    "nodes": [
      {
        "id": "gid://gitlab/Issue/321",
        "iid": "321",
        "reference": "#321",
        "state": "OPEN",
        "title": "Corrupti consectetur impedit non blanditiis hic vitae minus.",
        "webUrl": "https://gitlab.example.com/my-group/my-project/-/issues/321",
        "widgets": null
      },
      {
        "id": "gid://gitlab/WorkItem/322",
        "iid": "322",
        "reference": "#322",
        "state": "OPEN",
        "title": "Ipsa cupiditate corrupti vel maxime quasi at assumenda repellat quod.",
        "webUrl": "https://gitlab.example.com/my-group/my-project/-/issues/322",
        "widgets": null
      }
    ],
    "pageInfo": {
      "endCursor": "eyJpZCI6IjIifQ==",
      "hasNextPage": true,
      "hasPreviousPage": false,
      "startCursor": "eyJpZCI6IjEyMyJ9"
    }
  },
  "error": null,
  "fields": [
    {
      "field": "title",
      "key": "title",
      "label": "Title",
      "name": "title"
    }
  ],
  "success": true
}
```

要获取下一页，请使用上一次响应中的 `endCursor` 值：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "glql_yaml": "limit: 2\nquery: group = \"my-group\" AND state = opened",
    "after": "eyJpZCI6IjIifQ=="
  }' \
  --url "https://gitlab.example.com/api/v4/glql"
```

<a id="example-analytics-mode-query"></a>

### 示例：分析模式查询

按维度分组汇总流水线指标。在分析模式下，`fields` 数组包含每个字段的 `type` 属性，以及参数化字段的 `parameters` 属性：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "glql_yaml": "mode: analytics\ndimensions: ref\nmetrics: durationQuantile(0.5) as \"p50\"\nquery: type = Pipeline AND project = \"my-group/my-project\" AND finished >= -30d"
  }' \
  --url "https://gitlab.example.com/api/v4/glql"
```

示例响应：

```json
{
  "data": {
    "count": 2,
    "nodes": [
      {
        "durationQuantile_quantile_0_d5": 245.5,
        "p50": 245.5,
        "ref": "main"
      },
      {
        "durationQuantile_quantile_0_d5": 312.0,
        "p50": 312.0,
        "ref": "feature-branch"
      }
    ],
    "pageInfo": {
      "endCursor": "eyJpZCI6IjIifQ==",
      "hasNextPage": false,
      "hasPreviousPage": false,
      "startCursor": "eyJpZCI6IjEifQ=="
    }
  },
  "error": null,
  "fields": [
    {
      "field": "ref",
      "key": "ref",
      "label": "Ref",
      "name": "ref",
      "type": "dimension"
    },
    {
      "field": "durationQuantile",
      "key": "p50",
      "label": "p50",
      "name": "durationQuantile_quantile_0_d5",
      "parameters": {
        "quantile": "0.5"
      },
      "type": "metric"
    }
  ],
  "success": true
}
```

<a id="retrieve-the-glql-schema"></a>

## 检索 GLQL 模式

检索 GLQL 模式：可用的数据源及其筛选、显示和排序字段，运算符、值类型和引用类型词汇表，可用的函数，以及查询可以呈现的显示类型。

该文档描述查询语言。针对您不可用的数据源的查询会在 `POST /glql` 处失败。

该文档仅在极狐GitLab 升级时更改。它通过 `ETag` 提供，因此发送 `If-None-Match` 以重新验证并接收 `304 Not Modified` 而不是完整文档。

```plaintext
GET /glql/schema
```

此端点不接受任何参数，并为每个用户返回相同的文档。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性         | 类型         | 描述 |
|-------------------|--------------|-------------|
| `display_types`   | object array | 查询可以如何呈现，以及每种呈现需要什么。省略 `display:` 会呈现列表。见下文。 |
| `functions`       | object array | 可用的函数，每个都有 `name`、`kind`（`value` 用于查询中，`field` 用于 `fields`中）、`description`、`args` 和 `returns`。 |
| `operators`       | object array | 比较运算符，每个都有 `symbol`、`name` 和 `label`。 |
| `reference_types` | object array | 引用前缀，每个都有 `name`、`symbol` 和 `example`。例如，标记的 `~`。 |
| `sources`         | object array | 数据源。见下文。 |
| `value_kinds`     | object array | 筛选器或字段函数参数接受的值类型，每个都有 `name` 和 `description`。 |
| `version`         | string       | 此文档随附的 GLQL gem 版本。 |

`display_types[]` 的响应属性：

| 属性     | 类型         | 描述 |
|---------------|--------------|-------------|
| `description` | string       | 显示类型呈现的内容。 |
| `name`        | string       | 在 GLQL 块的 `display:` 选项中使用的值。 |
| `selections`  | object array | 该类型接受的维度和指标组合。查询必须匹配其中之一。仅对聚合类型存在，因此这些类型需要 `mode: analytics`。见下文。 |

`display_types[].selections[]` 的响应属性：

| 属性    | 类型    | 描述 |
|--------------|---------|-------------|
| `dimensions` | integer | 此组合采用的维度确切数量。 |
| `metrics`    | object  | 此组合采用的指标数量，以 `min` 和可选的 `max` 表示。没有 `max` 表示没有限制。 |

`sources[]` 的响应属性：

| 属性 | 类型         | 描述 |
|-----------|--------------|-------------|
| `label`   | string       | 人类可读的名称。 |
| `modes`   | object array | 数据源支持的查询模式。见下文。 |
| `name`    | string       | 规范数据源名称。例如，`WorkItems`。 |

`sources[].modes[]` 的响应属性：

| 属性                | 类型         | 描述 |
|--------------------------|--------------|-------------|
| `allowed_scopes`         | string array | 数据源可以在其中查询的范围。例如，`project`。 |
| `dimensions`             | string array | 仅分析模式。用于分组的字段。 |
| `display_fields`         | object array | 仅标准模式。可用于 `fields`的字段，每个都有 `name` 和可选的 `aliases`。分析模式省略此项，改用 `dimensions` 和 `metrics`。 |
| `filter_fields`          | object array | 可用于 `query`的字段，每个都有 `name`、可选的 `aliases` 和 `value_types`。 |
| `metrics`                | string array | 仅分析模式。要计算的聚合。 |
| `mode`                   | string       | `Standard` 或 `Analytics`。请注意，此处它们是大写的，而 GLQL 块中的 `mode` 选项是小写的。例如，`mode: analytics`。 |
| `multi_scope`            | boolean      | 指示 `query`中的 `group` 和 `project` 是否接受完整路径列表。请参阅[多个群组和项目](../user/glql/data_sources/_index.md#multiple-groups-and-projects)。 |
| `parameterized_fields`   | object array | 接受参数的字段，每个都有 `name` 和 `parameters`。仅在支持的地方存在。见下文。 |
| `sort_fields`            | string array | 可用于 `sort`的字段。 |
| `sort_restrictions`      | object array | 仅接受一个方向的排序字段，每个都有 `name` 及其接受的 `directions`。不在此列表中的字段同时接受 `asc` 和 `desc`。仅在存在限制的地方存在。 |
| `wildcard_filter_fields` | object array | 接受参数的筛选器，每个都有 `name`、`syntax` 字符串和 `value_types`。例如，`customField("Name")`。仅在支持的地方存在。 |

`sources[].modes[].filter_fields[].value_types[]` 的响应属性：

| 属性    | 类型         | 描述 |
|--------------|--------------|-------------|
| `items`      | object array | 仅 `List`。列表中接受的值类型。 |
| `kind`       | string       | `value_kinds` 名称之一。 |
| `operators`  | string array | 此类型接受的运算符。 |
| `references` | string       | 仅 `Reference`。`reference_types` 名称之一。 |
| `values`     | string array | 仅 `Enum` 和 `StringEnum`。接受的取值。在 `type` 筛选器上，列出的取值用于选择此数据源。只有 `WorkItems` 接受多个，因为对于工作项，`type` 还会将结果缩小到某个工作项类型。 |

`sources[].modes[].parameterized_fields[].parameters[]` 的响应属性：

| 属性             | 类型                      | 描述 |
|-----------------------|---------------------------|-------------|
| `default`             | string, number, or array | 省略参数时使用的值。当参数为 `required` 或 `optional` 时不存在。 |
| `items`               | object array              | 仅适用于 `List`。列表中接受的取值类型，每种类型都有一个 `kind`，对于 `Number` 还有 `min` 和 `max`，对于 `Enum` 还有 `values`。`String` 项不携带其他属性。 |
| `kind`                | string                    | `Enum`、`Number`、`List`、`Granularity` 或 `Timestamp` 之一。 |
| `max`                 | number                    | 仅适用于 `Number`。接受的最大值。 |
| `max_days`            | number                    | 仅适用于 `Granularity`。最大的固定天数取值，写作 `<max_days>d`。 |
| `max_length`          | number                    | 仅适用于 `List`。接受的最多项数。 |
| `min`                 | number                    | 仅适用于 `Number`。接受的最小值。 |
| `min_days`            | number                    | 仅适用于 `Granularity`。最小的固定天数取值。 |
| `min_length`          | number                    | 仅适用于 `List`。接受的最少项数。 |
| `name`                | string                    | 参数名称。例如 `granularity`。 |
| `optional`            | boolean                   | 当参数可以省略且省略后不会发送时为 `true`。此类参数没有 `default`。 |
| `required`            | boolean                   | 当查询必须提供该参数时为 `true`。 |
| `requires`            | object                    | 当该参数仅在同级参数的特定取值下有效时存在。包含 `parameter`（同级参数的名称）和 `value`（接受取值的描述）。 |
| `strictly_ascending`  | boolean                   | 仅适用于 `List`。当每一项都必须大于前一项时为 `true`。 |
| `values`              | string array              | `Enum` 和 `Granularity`。接受的取值。对于 `Granularity`，指除固定天数形式外还接受的日历取值。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/glql/schema"
```

示例响应（截断）：

```json
{
  "sources": [
    {
      "name": "WorkItems",
      "label": "work items",
      "modes": [
        {
          "mode": "Standard",
          "allowed_scopes": ["project", "group"],
          "filter_fields": [
            {
              "name": "label",
              "aliases": ["labels"],
              "value_types": [
                { "kind": "String", "operators": ["=", "!="] },
                {
                  "kind": "List",
                  "operators": ["in", "=", "!="],
                  "items": [{ "kind": "String" }, { "kind": "Reference", "references": "LabelRef" }]
                }
              ]
            }
          ],
          "wildcard_filter_fields": [
            {
              "name": "customField",
              "syntax": "customField(\"Name\")",
              "value_types": [{ "kind": "String", "operators": ["="] }]
            }
          ],
          "display_fields": [
            { "name": "title" },
            { "name": "assignee", "aliases": ["assignees"] }
          ],
          "sort_fields": ["created", "updated", "due"]
        }
      ]
    }
  ],
  "operators": [{ "symbol": "=", "name": "Equal", "label": "equals" }],
  "value_kinds": [{ "name": "String", "description": "A quoted string, for example \"my title\"." }],
  "reference_types": [{ "name": "LabelRef", "symbol": "~", "example": "~frontend" }],
  "display_types": [
    { "name": "list", "description": "A bulleted list of items." },
    {
      "name": "barChart",
      "description": "Horizontal bars, one per dimension value.",
      "selections": [
        { "dimensions": 1, "metrics": { "min": 1 } },
        { "dimensions": 2, "metrics": { "min": 1, "max": 1 } }
      ]
    }
  ],
  "functions": [
    { "name": "today", "kind": "value", "description": "Today's date at 00:00 UTC.", "args": [], "returns": "Date" }
  ],
  "version": "0.41.0"
}
```

分析模式会列出其维度和指标接受的参数，因此查询可以显式设置它们，而不是依赖默认值：

```json
"parameterized_fields": [
  {
    "name": "finished",
    "parameters": [
      { "name": "granularity", "kind": "Granularity", "values": ["daily", "weekly", "monthly"], "min_days": 1, "max_days": 399, "default": "weekly" },
      { "name": "origin", "kind": "Timestamp", "optional": true, "requires": { "parameter": "granularity", "value": "a fixed-day granularity such as `30d`, not a calendar bucket (`daily`, `weekly`, `monthly`)" } }
    ]
  },
  {
    "name": "durationQuantile",
    "parameters": [{ "name": "quantile", "kind": "Number", "min": 0.01, "max": 0.99, "default": 0.95 }]
  },
  {
    "name": "userTier",
    "parameters": [
      { "name": "thresholds", "kind": "List", "items": [{ "kind": "Number", "min": 1, "max": 2147483647 }], "min_length": 1, "max_length": 9, "strictly_ascending": true, "required": true }
    ]
  }
]
```

<a id="rate-limiting"></a>

## 速率限制

GLQL API 根据查询的 SHA-256 哈希实施速率限制。超时的查询会被跟踪。如果某个超时的特定查询执行过于频繁，它会被暂时阻止。

当受到速率限制时，API 返回 `429 Too Many Requests` 状态码并附带错误消息：

```json
{
  "error": "Query temporarily blocked due to repeated timeouts. Please try again later or narrow your search scope."
}
```

<a id="error-handling"></a>

## 错误处理

API 返回以下 HTTP 状态码：

| 状态码                 | 描述 |
|-----------------------------|-------------|
| `200 Success`               | 查询成功执行。 |
| `400 Bad Request`           | 查询语法无效、缺少必需参数或输入超出大小限制。 |
| `401 Unauthorized`          | 需要身份验证或凭据无效。 |
| `403 Forbidden`             | 权限不足或缺少必需的 OAuth 范围。 |
| `429 Too Many Requests`     | 超出查询速率限制。 |
| `500 Internal Server Error` | 查询执行期间发生服务器错误。 |

<a id="error-response-examples"></a>

### 错误响应示例

- 缺少必需参数：

  ```json
  {
    "error": "glql_yaml is missing, glql_yaml is empty"
  }
  ```

- GLQL 语法无效：

  ```json
  {
    "error": "400 Bad request - Error: Unexpected `invalid syntax @@@ ###`, expected operator (one of IN, =, !=, >, or <)"
  }
  ```

- 输入大小超出：

  ```json
  {
    "error": "400 Bad request - Input exceeds maximum size"
  }
  ```

- 项目不存在：

  ```json
  {
    "error": "400 Bad request - Error: Project does not exist or you do not have access to it"
  }
  ```

- 群组不存在：

  ```json
  {
    "error": "400 Bad request - Error: Group does not exist or you do not have access to it"
  }
  ```

- 超出速率限制：

  ```json
  {
    "error": "Query temporarily blocked due to repeated timeouts. Please try again later or narrow your search scope."
  }
  ```

- 字段无效

  ```json
  {
    "error": "Field 'title' doesn't exist on type 'WorkItem' (Did you mean `title`?)"
  }
  ```

> [!note]
> 适用时，GraphQL 错误请求错误会以 `400` 错误码传递到 API 的
> `error` 字段。

<a id="limits-and-constraints"></a>

## 限制和约束

GLQL API 具有以下限制：

- 最大输入大小：`glql_yaml` 参数为 10,000 字节（10 KB）。
- 最大查询限制：每个请求 100 个结果。
- 默认限制：未指定时为 100 个结果。
- 分页：仅支持使用 `after` 属性及上一次响应中的
  `endCursor` 值进行向前分页。
- 速率限制：查询根据查询 SHA-256 哈希进行速率限制。
