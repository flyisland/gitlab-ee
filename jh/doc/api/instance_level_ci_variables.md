---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 实例级 CI/CD 变量 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与您实例的 [CI/CD 变量](../ci/variables/_index.md#for-an-instance) 进行交互。

<a id="list-all-instance-variables"></a>

列出所有实例变量

{{< history >}}

- `description` 参数在 极狐GitLab 16.8 中引入。

{{< /history >}}

列出所有实例级变量。使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

```plaintext
GET /admin/ci/variables
```

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/ci/variables"
```

```json
[
    {
        "key": "TEST_VARIABLE_1",
        "description": null,
        "variable_type": "env_var",
        "value": "TEST_1",
        "protected": false,
        "masked": false,
        "raw": false
    },
    {
        "key": "TEST_VARIABLE_2",
        "description": null,
        "variable_type": "env_var",
        "value": "TEST_2",
        "protected": false,
        "masked": false,
        "raw": false
    }
]
```

<a id="retrieve-instance-variable-details"></a>

检索实例变量详情

{{< history >}}

- `description` 参数在 极狐GitLab 16.8 中引入。

{{< /history >}}

检索特定实例级变量的详细信息。

```plaintext
GET /admin/ci/variables/:key
```

| 属性 | 类型   | 必填 | 描述 |
|-----------|---------|----------|-------------|
| `key`     | string  | 是      | 变量的 `key` |

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/ci/variables/TEST_VARIABLE_1"
```

```json
{
    "key": "TEST_VARIABLE_1",
    "description": null,
    "variable_type": "env_var",
    "value": "TEST_1",
    "protected": false,
    "masked": false,
    "raw": false
}
```

<a id="create-instance-variable"></a>

创建实例变量

{{< history >}}

- `description` 参数在 极狐GitLab 16.8 中引入。

{{< /history >}}

创建一个新的实例级变量。

可以更改[实例级变量的最大数量](../administration/instance_limits.md#cicd-variable-limits)。

```plaintext
POST /admin/ci/variables
```

| 属性       | 类型    | 必填 | 描述 |
|-----------------|---------|----------|-------------|
| `key`           | string  | 是      | 变量的 `key`。最多 255 个字符，只允许 `A-Z`、`a-z`、`0-9` 和 `_`。 |
| `value`         | string  | 是      | 变量的值。最多 10,000 个字符。 |
| `description`   | string  | 否       | 变量的描述。最多 255 个字符。 |
| `masked`        | boolean | 否       | 变量是否已掩蔽。 |
| `protected`     | boolean | 否       | 变量是否受保护。 |
| `raw`           | boolean | 否       | 变量是否可扩展。 |
| `variable_type` | string  | 否       | 变量类型。可用类型包括：`env_var`（默认）和 `file`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/ci/variables" \
  --form "key=NEW_VARIABLE" \
  --form "value=new value"
```

```json
{
    "key": "NEW_VARIABLE",
    "description": null,
    "value": "new value",
    "variable_type": "env_var",
    "protected": false,
    "masked": false,
    "raw": false
}
```

<a id="update-instance-variable"></a>

更新实例变量

{{< history >}}

- `description` 参数在 极狐GitLab 16.8 中引入。

{{< /history >}}

更新一个实例级变量。

```plaintext
PUT /admin/ci/variables/:key
```

| 属性       | 类型    | 必填 | 描述 |
|-----------------|---------|----------|-------------|
| `description`   | string  | 否       | 变量的描述。最多 255 个字符。 |
| `key`           | string  | 是      | 变量的 `key`。最多 255 个字符，只允许 `A-Z`、`a-z`、`0-9` 和 `_`。 |
| `masked`        | boolean | 否       | 变量是否已掩蔽。 |
| `protected`     | boolean | 否       | 变量是否受保护。 |
| `raw`           | boolean | 否       | 变量是否可扩展。 |
| `value`         | string  | 是      | 变量的值。最多 10,000 个字符。 |
| `variable_type` | string  | 否       | 变量类型。可用类型包括：`env_var`（默认）和 `file`。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/ci/variables/NEW_VARIABLE" \
  --form "value=updated value"
```

```json
{
    "key": "NEW_VARIABLE",
    "description": null,
    "value": "updated value",
    "variable_type": "env_var",
    "protected": true,
    "masked": true,
    "raw": true
}
```

<a id="delete-instance-variable"></a>

删除实例变量

删除一个实例级变量。

```plaintext
DELETE /admin/ci/variables/:key
```

| 属性 | 类型   | 必填 | 描述 |
|-----------|--------|----------|-------------|
| `key`     | string | 是      | 变量的 `key` |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/ci/variables/VARIABLE_1"
```