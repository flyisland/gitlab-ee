---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目级 CI/CD 变量 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.9 中引入了 `filter`。

{{< /history >}}

使用此 API 与项目的 [CI/CD 变量](../ci/variables/_index.md#for-a-project) 进行交互。

<a id="list-project-variables"></a>

## 列出项目变量

列出项目的所有变量。使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

```plaintext
GET /projects/:id/variables
```

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/variables"
```

示例响应：

```json
[
    {
        "variable_type": "env_var",
        "key": "TEST_VARIABLE_1",
        "value": "TEST_1",
        "protected": false,
        "masked": true,
        "hidden": false,
        "raw": false,
        "environment_scope": "*",
        "description": null
    },
    {
        "variable_type": "env_var",
        "key": "TEST_VARIABLE_2",
        "value": "TEST_2",
        "protected": false,
        "masked": false,
        "hidden": false,
        "raw": false,
        "environment_scope": "*",
        "description": null
    }
]
```

<a id="retrieve-a-single-variable"></a>

## 获取单个变量

获取单个变量的详细信息。如果存在多个具有相同键的变量，请使用 `filter` 来选择正确的 `environment_scope`。

```plaintext
GET /projects/:id/variables/:key
```

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key` | 字符串 | 是 | 变量的键 |
| `filter` | 哈希 | 否 | 当多个变量具有相同键时过滤结果。可能的值：`[environment_scope]` |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/variables/TEST_VARIABLE_1"
```

示例响应：

```json
{
    "key": "TEST_VARIABLE_1",
    "variable_type": "env_var",
    "value": "TEST_1",
    "protected": false,
    "masked": true,
    "hidden": false,
    "raw": false,
    "environment_scope": "*",
    "description": null
}
```

带 `filter` 的示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/variables/SCOPED_VARIABLE_1" \
  --form "filter[environment_scope]=production"
```

<a id="create-a-variable"></a>

## 创建变量

{{< history >}}

- 在极狐GitLab 17.4 中引入了 `masked_and_hidden` 和 `hidden` 属性。

{{< /history >}}

创建一个新变量。如果已存在具有相同 `key` 的变量，则新变量必须具有不同的 `environment_scope`。否则，极狐GitLab 会返回类似以下的消息：`VARIABLE_NAME 已被占用`。

```plaintext
POST /projects/:id/variables
```

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key` | 字符串 | 是 | 变量的 `key`；不得超过 255 个字符；仅允许 `A-Z`、`a-z`、`0-9` 和 `_` |
| `value` | 字符串 | 是 | 变量的 `value` |
| `description` | 字符串 | 否 | 变量的描述。默认值：`null`。在极狐GitLab 16.2 中引入。 |
| `environment_scope` | 字符串 | 否 | 变量的 `environment_scope`。默认值：`*` |
| `masked` | 布尔值 | 否 | 变量是否被掩码。默认值：`false` |
| `masked_and_hidden` | 布尔值 | 否 | 变量是否被掩码并隐藏。默认值：`false` |
| `protected` | 布尔值 | 否 | 变量是否受保护。默认值：`false` |
| `raw` | 布尔值 | 否 | 变量是否被视为原始字符串。默认值：`true`。当为 `false` 时，值中的变量会被 [展开](../ci/variables/_index.md#allow-cicd-variable-expansion)。 |
| `variable_type` | 字符串 | 否 | 变量的类型。可用类型有：`env_var`（默认）和 `file` |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/variables" \
  --form "key=NEW_VARIABLE" \
  --form "value=new value"
```

示例响应：

```json
{
    "variable_type": "env_var",
    "key": "NEW_VARIABLE",
    "value": "new value",
    "protected": false,
    "masked": false,
    "hidden": false,
    "raw": false,
    "environment_scope": "*",
    "description": null
}
```

<a id="update-a-variable"></a>

## 更新变量

更新项目变量。如果存在多个具有相同键的变量，请使用 `filter` 来选择正确的 `environment_scope`。

```plaintext
PUT /projects/:id/variables/:key
```

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key` | 字符串 | 是 | 变量的键 |
| `value` | 字符串 | 是 | 变量的值 |
| `description` | 字符串 | 否 | 变量的描述。在极狐GitLab 16.2 中引入。默认值：`null`。 |
| `environment_scope` | 字符串 | 否 | 变量的环境范围 |
| `filter` | 哈希 | 否 | 当多个变量具有相同键时过滤结果。可能的值：`[environment_scope]` |
| `masked` | 布尔值 | 否 | 如果为 `true`，表示变量被掩码 |
| `protected` | 布尔值 | 否 | 如果为 `true`，表示变量受保护 |
| `raw` | 布尔值 | 否 | 如果为 `true`，表示变量被视为原始字符串。当为 `false` 时，变量值会被 [展开](../ci/variables/_index.md#allow-cicd-variable-expansion)。默认值：`true` |
| `variable_type` | 字符串 | 否 | 变量的类型。可用类型有：`env_var`（默认）和 `file` |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/variables/NEW_VARIABLE" \
  --form "value=updated value"
```

示例响应：

```json
{
    "variable_type": "env_var",
    "key": "NEW_VARIABLE",
    "value": "updated value",
    "protected": true,
    "masked": false,
    "hidden": false,
    "raw": false,
    "environment_scope": "*",
    "description": "null"
}
```

带 `filter` 的示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/variables/SCOPED_VARIABLE_1" \
  --form "value=updated value" \
  --form "environment_scope=production" \
  --form "filter[environment_scope]=production"
```

<a id="delete-a-variable"></a>

## 删除变量

删除项目变量。如果存在多个具有相同键的变量，请使用 `filter` 来选择正确的 `environment_scope`。

```plaintext
DELETE /projects/:id/variables/:key
```

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key` | 字符串 | 是 | 变量的键 |
| `filter` | 哈希 | 否 | 当多个变量具有相同键时过滤结果。可能的值：`[environment_scope]` |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>"
  --url "https://gitlab.example.com/api/v4/projects/1/variables/VARIABLE_1"
```

带 `filter` 的示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>"
  --url "https://gitlab.example.com/api/v4/projects/1/variables/SCOPED_VARIABLE_1" \
  --form "filter[environment_scope]=production"
```