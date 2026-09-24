---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组级别变量 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 16.9 中引入了 `filter`。

{{< /history >}}

使用此 API 与群组的 [CI/CD 变量](../ci/variables/_index.md#for-a-group) 交互。

先决条件：

- 您必须具有该群组的所有者角色。

<a id="list-all-group-variables"></a>

## 列出所有群组变量

列出指定群组的所有变量。使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数控制结果的分页。

```plaintext
GET /groups/:id/variables
```

| 属性 | 类型 | 必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/variables"
```

```json
[
    {
        "key": "TEST_VARIABLE_1",
        "variable_type": "env_var",
        "value": "TEST_1",
        "protected": false,
        "masked": false,
        "hidden": false,
        "raw": false,
        "environment_scope": "*",
        "description": null
    },
    {
        "key": "TEST_VARIABLE_2",
        "variable_type": "env_var",
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

<a id="retrieve-details-of-a-group-variable"></a>

## 获取群组变量的详细信息

{{< history >}}

- `filter` 参数在 极狐GitLab 16.9 中引入。

{{< /history >}}

获取指定群组变量的详细信息。如果有多个变量具有相同的键，使用 `filter` 选择正确的 `environment_scope`。

```plaintext
GET /groups/:id/variables/:key
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key` | 字符串 | 是 | 变量的键。 |
| `filter` | 哈希 | 否 | 当多个变量具有相同键时过滤结果。可能的值：`[environment_scope]`。仅专业版和旗舰版。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/variables/TEST_VARIABLE_1"
```

```json
{
    "key": "TEST_VARIABLE_1",
    "variable_type": "env_var",
    "value": "TEST_1",
    "protected": false,
    "masked": false,
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
  --url "https://gitlab.example.com/api/v4/groups/1/variables/SCOPED_VARIABLE_1" \
  --form "filter[environment_scope]=production"
```

<a id="create-a-group-variable"></a>

## 创建群组变量

{{< history >}}

- `masked_and_hidden` 和 `hidden` 属性在 极狐GitLab 17.4 中引入。

{{< /history >}}

创建群组变量。

```plaintext
POST /groups/:id/variables
```

| 属性 | 类型 | 必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key` | 字符串 | 是 | 变量的 `key`。最多 255 个字符。仅允许 `A-Z`、`a-z`、`0-9` 和 `_`。 |
| `value` | 字符串 | 是 | 变量的 `value`。 |
| `description` | 字符串 | 否 | 变量的 `description`。最多 255 个字符。默认：`null`。 |
| `environment_scope` | 字符串 | 否 | 变量的 [环境范围](../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。仅专业版和旗舰版。 |
| `masked` | 布尔值 | 否 | 变量是否被掩码。 |
| `masked_and_hidden` | 布尔值 | 否 | 变量是否被掩码且隐藏。默认：`false` |
| `protected` | 布尔值 | 否 | 变量是否受保护。 |
| `raw` | 布尔值 | 否 | 变量是否被视为原始字符串。默认：`true`。当 `false` 时，变量中的值会被 [展开](../ci/variables/_index.md#allow-cicd-variable-expansion)。 |
| `variable_type` | 字符串 | 否 | 变量的类型。可用类型：`env_var`（默认）和 `file`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/variables" \
  --form "key=NEW_VARIABLE" \
  --form "value=new value"
```

```json
{
    "key": "NEW_VARIABLE",
    "value": "new value",
    "variable_type": "env_var",
    "protected": false,
    "masked": false,
    "hidden": false,
    "raw": false,
    "environment_scope": "*",
    "description": null
}
```

<a id="update-a-group-variable"></a>

## 更新群组变量

{{< history >}}

- `filter` 参数在 极狐GitLab 16.9 中引入。

{{< /history >}}

更新指定的群组变量。如果有多个变量具有相同的键，使用 `filter` 选择正确的 `environment_scope`。

> [!warning]
> 当过滤一个不存在的 `environment_scope` 时，端点会回退到更新具有相同名称但不同环境范围的变量。使用 [获取群组变量的详细信息](#retrieve-details-of-a-group-variable) 端点验证给定变量的范围是否存在。

```plaintext
PUT /groups/:id/variables/:key
```

| 属性 | 类型 | 必需 | 描述 |
| ------------------- | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key` | 字符串 | 是 | 变量的键。 |
| `value` | 字符串 | 是 | 变量的值。 |
| `description` | 字符串 | 否 | 变量的描述。在 极狐GitLab 16.2 中引入。默认：`null`。 |
| `environment_scope` | 字符串 | 否 | 变量的 [环境范围](../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。仅专业版和旗舰版。 |
| `filter` | 哈希 | 否 | 当多个变量具有相同键时过滤结果。可能的值：`[environment_scope]`。仅专业版和旗舰版。 |
| `masked` | 布尔值 | 否 | 如果为 `true`，表示变量被掩码。 |
| `protected` | 布尔值 | 否 | 如果为 `true`，表示变量受保护。 |
| `raw` | 布尔值 | 否 | 如果为 `true`，表示变量被视为原始字符串。当 `false` 时，变量值会被 [展开](../ci/variables/_index.md#allow-cicd-variable-expansion)。默认：`true`。 |
| `variable_type` | 字符串 | 否 | 变量的类型。可用类型：`env_var`（默认）和 `file`。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/variables/NEW_VARIABLE" \
  --form "value=updated value"
```

```json
{
    "key": "NEW_VARIABLE",
    "value": "updated value",
    "variable_type": "env_var",
    "protected": true,
    "masked": true,
    "hidden": false,
    "raw": true,
    "environment_scope": "*",
    "description": null
}
```

带 `filter` 的示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/variables/SCOPED_VARIABLE_1" \
  --form "value=updated value" \
  --form "environment_scope=production" \
  --form "filter[environment_scope]=production"
```

<a id="delete-a-group-variable"></a>

## 删除群组变量

{{< history >}}

- `filter` 参数在 极狐GitLab 16.9 中引入。

{{< /history >}}

删除指定的群组变量。如果有多个变量具有相同的键，使用 `filter` 选择正确的 `environment_scope`。

```plaintext
DELETE /groups/:id/variables/:key
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key` | 字符串 | 是 | 变量的键。 |
| `filter` | 哈希 | 否 | 当多个变量具有相同键时过滤结果。可能的值：`[environment_scope]`。仅专业版和旗舰版。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/variables/VARIABLE_1"
```

带 `filter` 的示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/variables/SCOPED_VARIABLE_1" \
  --form "filter[environment_scope]=production"
```