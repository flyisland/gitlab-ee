---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 错误追踪 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与项目的错误追踪功能进行交互。更多信息，请参见[错误追踪](../operations/error_tracking.md)。

先决条件：

- 你必须具有维护者或所有者角色。

<a id="retrieve-error-tracking-settings"></a>

## 获取错误追踪设置

获取指定项目的错误追踪设置。

```plaintext
GET /projects/:id/error_tracking/settings
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------- | -------- | --------------------- |
| `id`      | integer | yes      | 项目的 ID 或 [URL-encoded path of the project](rest/_index.md#namespaced-paths) |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/error_tracking/settings"
```

示例响应：

```json
{
  "active": true,
  "project_name": "sample sentry project",
  "sentry_external_url": "https://sentry.io/myawesomeproject/project",
  "api_url": "https://sentry.io/api/0/projects/myawesomeproject/project",
  "integrated": false
}
```

<a id="create-error-tracking-settings"></a>

## 创建错误追踪设置

{{< history >}}

- 于 极狐GitLab 15.10 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/393035/)。

{{< /history >}}

为指定项目创建错误追踪设置。

> [!note]
> 此 API 仅在与[集成错误追踪](../operations/integrated_error_tracking.md)一起使用时可用。

```plaintext
PUT /projects/:id/error_tracking/settings
```

支持的属性：

| 属性    | 类型    | 是否必需 | 描述                                                                                                                                                     |
| ------------ | ------- |----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`         | integer | yes      | 项目的 ID 或 [URL-encoded path of the project](rest/_index.md#namespaced-paths)。                                            |
| `active`     | boolean | yes      | 传递 `true` 以启用错误追踪设置配置，或传递 `false` 以禁用它。                                                                        |
| `integrated` | boolean | yes      | 传递 `true` 以启用集成错误追踪后端。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/error_tracking/settings?active=true&integrated=true"
```

示例响应：

```json
{
  "active": true,
  "project_name": null,
  "sentry_external_url": null,
  "api_url": null,
  "integrated": true
}
```

<a id="update-error-tracking-project-settings"></a>

## 更新错误追踪项目设置

更新指定项目的错误追踪设置。

```plaintext
PATCH /projects/:id/error_tracking/settings
```

| 属性 | 类型 | 是否必需 | 描述 |
| ------------ | ------- | -------- | --------------------- |
| `id` | integer | yes | 项目的 ID 或 [URL-encoded path of the project](rest/_index.md#namespaced-paths)。 |
| `active` | boolean | yes | 传递 `true` 以启用已配置的错误追踪设置，或传递 `false` 以禁用它。 |
| `integrated` | boolean | no | 传递 `true` 以启用集成错误追踪后端。 |

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/error_tracking/settings?active=true"
```

示例响应：

```json
{
  "active": true,
  "project_name": "sample sentry project",
  "sentry_external_url": "https://sentry.io/myawesomeproject/project",
  "api_url": "https://sentry.io/api/0/projects/myawesomeproject/project",
  "integrated": false
}
```

<a id="list-all-project-client-keys"></a>

## 列出所有项目客户端密钥

列出指定项目的所有[集成错误追踪](../operations/integrated_error_tracking.md)客户端密钥。

```plaintext
GET /projects/:id/error_tracking/client_keys
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | yes | 项目的 ID 或 [URL-encoded path of the project](rest/_index.md#namespaced-paths)。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/error_tracking/client_keys"
```

示例响应：

```json
[
  {
    "id": 1,
    "active": true,
    "public_key": "glet_aa77551d849c083f76d0bc545ed053a3",
    "sentry_dsn": "https://glet_aa77551d849c083f76d0bc545ed053a3@example.com/errortracking/api/v1/projects/5"
  },
  {
    "id": 3,
    "active": true,
    "public_key": "glet_0ff98b1d849c083f76d0bc545ed053a3",
    "sentry_dsn": "https://glet_aa77551d849c083f76d0bc545ed053a3@example.com/errortracking/api/v1/projects/5"
  }
]
```

<a id="create-a-client-key"></a>

## 创建客户端密钥

为指定项目创建一个[集成错误追踪](../operations/integrated_error_tracking.md)客户端密钥。公钥 (public key) 属性将自动生成。

```plaintext
POST /projects/:id/error_tracking/client_keys
```

| 属性  | 类型 | 是否必需 | 描述 |
| ---------  | ---- | -------- | ----------- |
| `id`       | integer or string | yes | 项目的 ID 或 [URL-encoded path of the project](rest/_index.md#namespaced-paths)。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/5/error_tracking/client_keys"
```

示例响应：

```json
{
  "id": 3,
  "active": true,
  "public_key": "glet_0ff98b1d849c083f76d0bc545ed053a3",
  "sentry_dsn": "https://glet_aa77551d849c083f76d0bc545ed053a3@example.com/errortracking/api/v1/projects/5"
}
```

<a id="delete-a-client-key"></a>

## 删除客户端密钥

从指定项目中删除一个[集成错误追踪](../operations/integrated_error_tracking.md)客户端密钥。

```plaintext
DELETE /projects/:id/error_tracking/client_keys/:key_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | yes | 项目的 ID 或 [URL-encoded path of the project](rest/_index.md#namespaced-paths)。 |
| `key_id`  | integer | yes | 客户端密钥的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/error_tracking/client_keys/13"
```