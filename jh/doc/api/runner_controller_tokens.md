---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Runner 控制器 tokens API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

{{< history >}}

- 在 极狐GitLab 18.9 引入，带有一个功能标志 `FF_USE_JOB_ROUTER`。此功能为[实验](../policy/development_stages_support.md)功能，须遵守[极狐GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)。
- `last_used_at` 字段在 极狐GitLab 18.10 引入。

{{< /history >}}

Runner 控制器 tokens API 允许您管理 Runner 控制器的身份验证 token。
Runner 控制器使用这些 token 与 极狐GitLab 实例进行身份验证并管理 Runner。
该 API 提供了创建、列出、轮换和撤销 token 的端点。

先决条件：

- 您必须拥有 极狐GitLab 实例的管理员访问权限。

<a id="list-all-runner-controller-tokens"></a>

## 列出所有 Runner 控制器 tokens

列出所有 Runner 控制器 tokens。

```plaintext
GET /runner_controllers/:id/tokens
```

参数：

| 属性          | 类型         | 是否必需 | 描述 |
|--------------------|--------------|----------|-------------|
| `id`               | 整数      | 是      | Runner 控制器的 ID。 |

响应：

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性               | 类型    | 描述 |
|-------------------------|---------|-------------|
| `id`                    | 整数 | Runner 控制器 token 的唯一标识符。 |
| `runner_controller_id`  | 整数 | 关联的 Runner 控制器的 ID。 |
| `description`           | 字符串  | token 的描述。 |
| `last_used_at`          | datetime| token 上次使用的时间。 |
| `created_at`            | datetime| token 的创建时间。 |
| `updated_at`            | datetime| token 的最后更新时间。 |

请求示例：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/:id/tokens"
```

响应示例：

```json
[
    {
        "id": 1,
        "runner_controller_id": 1,
        "description": "Token for runner controller",
        "last_used_at": "2026-01-05T00:00:00Z",
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-01-02T00:00:00Z"
    },
    {
        "id": 2,
        "runner_controller_id": 1,
        "description": "Another token for runner controller",
        "last_used_at": "2026-01-05T00:00:00Z",
        "created_at": "2026-01-03T00:00:00Z",
        "updated_at": "2026-01-04T00:00:00Z"
    }
]
```

<a id="retrieve-a-single-runner-controller-token"></a>

## 检索单个 Runner 控制器 token

通过 ID 检索特定 Runner 控制器 token 的详细信息。

```plaintext
GET /runner_controllers/:id/tokens/:token_id
```

参数：

| 属性          | 类型         | 是否必需 | 描述 |
|--------------------|--------------|----------|-------------|
| `id`               | 整数      | 是      | Runner 控制器的 ID。 |
| `token_id`         | 整数      | 是      | Runner 控制器 token 的 ID。 |

响应：

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下字段：

| 属性               | 类型    | 描述 |
|-------------------------|---------|-------------|
| `id`                    | 整数 | Runner 控制器 token 的唯一标识符。 |
| `runner_controller_id`  | 整数 | 关联的 Runner 控制器的 ID。 |
| `description`           | 字符串  | token 的描述。 |
| `last_used_at`          | datetime| token 上次使用的时间。 |
| `created_at`            | datetime| token 的创建时间。 |
| `updated_at`            | datetime| token 的最后更新时间。 |

请求示例：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/:id/tokens/:token_id"
```

响应示例：

```json
{
    "id": 1,
    "runner_controller_id": 1,
    "description": "Token for runner controller",
    "last_used_at": "2026-01-05T00:00:00Z",
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-02T00:00:00Z"
}
```

<a id="create-a-runner-controller-token"></a>

## 创建 Runner 控制器 token

创建新的 Runner 控制器 token。

```plaintext
POST /runner_controllers/:id/tokens
```

参数：

| 属性          | 类型         | 是否必需 | 描述 |
|--------------------|--------------|----------|-------------|
| `id`               | 整数      | 是      | Runner 控制器的 ID。 |

支持的属性：

| 属性          | 类型         | 是否必需 | 描述 |
|--------------------|--------------|----------|-------------|
| `description`      | 字符串       | 是      | token 的描述。 |

响应：

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下属性：

| 属性               | 类型    | 描述 |
|-------------------------|---------|-------------|
| `id`                    | 整数 | Runner 控制器 token 的唯一标识符。 |
| `runner_controller_id`  | 整数 | 关联的 Runner 控制器的 ID。 |
| `description`           | 字符串  | token 的描述。 |
| `last_used_at`          | datetime| token 上次使用的时间。 |
| `created_at`            | datetime| token 的创建时间。 |
| `updated_at`            | datetime| token 的最后更新时间。 |
| `token`                 | 字符串  | 用于身份验证的实际 token 值。 |

请求示例：

```shell
curl --request POST \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --header "Content-Type: application/json" \
    --data '{"description": "Token for runner controller"}' \
    --url "https://gitlab.example.com/api/v4/runner_controllers/:id/tokens"
```

响应示例：

```json
{
    "id": 1,
    "runner_controller_id": 1,
    "description": "Token for runner controller",
    "last_used_at": null,
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-01T00:00:00Z",
    "token": "glrct-<token>"
}
```

<a id="revoke-a-runner-controller-token"></a>

## 撤销 Runner 控制器 token

撤销现有的 Runner 控制器 token。

```plaintext
DELETE /runner_controllers/:id/tokens/:token_id
```

参数：

| 属性          | 类型         | 是否必需 | 描述 |
|--------------------|--------------|----------|-------------|
| `id`               | 整数      | 是      | Runner 控制器的 ID。 |
| `token_id`         | 整数      | 是      | Runner 控制器 token 的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

```shell
curl --request DELETE \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/runner_controllers/:id/tokens/:token_id"
```

<a id="rotate-a-runner-controller-token"></a>

## 轮换 Runner 控制器 token

轮换现有的 Runner 控制器 token。

```plaintext
POST /runner_controllers/:id/tokens/:token_id/rotate
```

参数：

| 属性          | 类型         | 是否必需 | 描述 |
|--------------------|--------------|----------|-------------|
| `id`               | 整数      | 是      | Runner 控制器的 ID。 |
| `token_id`         | 整数      | 是      | Runner 控制器 token 的 ID。 |

响应：

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下属性：

| 属性               | 类型    | 描述 |
|-------------------------|---------|-------------|
| `id`                    | 整数 | Runner 控制器 token 的唯一标识符。 |
| `runner_controller_id`  | 整数 | 关联的 Runner 控制器的 ID。 |
| `description`           | 字符串  | token 的描述。 |
| `last_used_at`          | datetime| token 上次使用的时间。 |
| `created_at`            | datetime| token 的创建时间。 |
| `updated_at`            | datetime| token 的最后更新时间。 |
| `token`                 | 字符串  | 用于身份验证的实际 token 值。 |

请求示例：

```shell
curl --request POST \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/runner_controllers/:id/tokens/:token_id/rotate"
```

响应示例：

```json
{
    "id": 1,
    "runner_controller_id": 1,
    "description": "Token for runner controller",
    "last_used_at": "2026-01-05T00:00:00Z",
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-01T00:00:00Z",
    "token": "glrct-<token>"
}
```