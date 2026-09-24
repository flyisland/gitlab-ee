---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Runner 控制器 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

{{< history >}}

- 在极狐GitLab 18.9 中引入，带有名为 `FF_USE_JOB_ROUTER` 的功能标志。此功能为实验性功能，并受测试协议约束。
- `connected` 字段在极狐GitLab 18.10 中引入。

{{< /history >}}

Runner 控制器 API 允许你管理用于 CI/CD 作业准入控制的 runner 控制器。
Runner 控制器连接到作业路由器，并根据自定义策略评估作业，决定是准入还是拒绝它们。此 API 提供了创建、读取、更新和删除 runner 控制器的端点。

先决条件：

- 你必须拥有对极狐GitLab 实例的管理员访问权限。

<a id="list-all-runner-controllers"></a>

## 列出所有 runner 控制器

列出所有 runner 控制器。

```plaintext
GET /runner_controllers
```

响应：

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 并附带以下响应属性：

| 属性                | 类型         | 描述                                                              |
|--------------------|--------------|------------------------------------------------------------------|
| `id`               | 整数          | runner 控制器的唯一标识符。                                           |
| `description`      | 字符串        | runner 控制器的描述。                                               |
| `state`            | 字符串        | runner 控制器的状态。有效值为 `disabled`（默认）、`enabled` 或 `dry_run`。 |
| `created_at`       | datetime     | runner 控制器创建时的日期和时间。                                     |
| `updated_at`       | datetime     | runner 控制器上次更新的日期和时间。                                    |

示例请求：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers"
```

示例响应：

```json
[
    {
        "id": 1,
        "description": "Runner controller",
        "state": "enabled",
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-01-02T00:00:00Z"
    },
    {
        "id": 2,
        "description": "Another runner controller",
        "state": "disabled",
        "created_at": "2026-01-03T00:00:00Z",
        "updated_at": "2026-01-04T00:00:00Z"
    }
]
```

<a id="retrieve-a-single-runner-controller"></a>

## 获取单个 runner 控制器

通过其 ID 获取特定 runner 控制器的详细信息。

```plaintext
GET /runner_controllers/:id
```

响应：

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 并附带以下响应属性：

| 属性                | 类型         | 描述                                                                                                |
|--------------------|--------------|----------------------------------------------------------------------------------------------------|
| `id`               | 整数          | runner 控制器的唯一标识符。                                                                             |
| `description`      | 字符串        | runner 控制器的描述。                                                                                 |
| `state`            | 字符串        | runner 控制器的状态。有效值为 `disabled`（默认）、`enabled` 或 `dry_run`。                                   |
| `connected`        | boolean      | runner 控制器当前是否已连接。如果一个 runner 控制器在过去一小时内至少使用了它的一个活跃令牌，则认为它是已连接的。 |
| `created_at`       | datetime     | runner 控制器创建时的日期和时间。                                                                       |
| `updated_at`       | datetime     | runner 控制器上次更新的日期和时间。                                                                      |

示例请求：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/1"
```

示例响应：

```json
{
    "id": 1,
    "description": "Runner controller",
    "state": "enabled",
    "connected": true,
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-02T00:00:00Z"
}
```

<a id="register-a-runner-controller"></a>

## 注册 runner 控制器

注册一个新的 runner 控制器。

```plaintext
POST /runner_controllers
```

支持的属性：

| 属性           | 类型   | 是否必需 | 描述                                                              |
|---------------|--------|----------|------------------------------------------------------------------|
| `description` | 字符串  | 否       | runner 控制器的描述。                                               |
| `state`       | 字符串  | 否       | runner 控制器的状态。有效值为 `disabled`（默认）、`enabled` 或 `dry_run`。 |

响应：

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 并附带以下响应属性：

| 属性          | 类型     | 描述                                              |
|--------------|----------|--------------------------------------------------|
| `id`         | 整数      | runner 控制器的唯一标识符。                           |
| `description`| 字符串    | runner 控制器的描述。                               |
| `state`      | 字符串    | runner 控制器的状态。有效值为 `disabled`（默认）、`enabled` 或 `dry_run`。 |
| `created_at` | datetime | runner 控制器创建时的日期和时间。                     |
| `updated_at` | datetime | runner 控制器上次更新的日期和时间。                    |

示例请求：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"description": "New runner controller", "state": "dry_run"}' \
     --url "https://gitlab.example.com/api/v4/runner_controllers"
```

示例响应：

```json
{
    "id": 3,
    "description": "New runner controller",
    "state": "dry_run",
    "created_at": "2026-01-05T00:00:00Z",
    "updated_at": "2026-01-05T00:00:00Z"
}
```

<a id="update-a-runner-controller"></a>

## 更新 runner 控制器

通过其 ID 更新现有 runner 控制器的详细信息。

```plaintext
PUT /runner_controllers/:id
```

支持的属性：

| 属性           | 类型   | 是否必需 | 描述                                                              |
|---------------|--------|----------|------------------------------------------------------------------|
| `description` | 字符串  | 否       | runner 控制器的描述。                                               |
| `state`       | 字符串  | 否       | runner 控制器的状态。有效值为 `disabled`（默认）、`enabled` 或 `dry_run`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 并附带以下响应属性：

| 属性          | 类型     | 描述                                                              |
|--------------|----------|------------------------------------------------------------------|
| `id`         | 整数      | runner 控制器的唯一标识符。                                           |
| `description`| 字符串    | runner 控制器的描述。                                               |
| `state`      | 字符串    | runner 控制器的状态。有效值为 `disabled`（默认）、`enabled` 或 `dry_run`。 |
| `created_at` | datetime | runner 控制器创建时的日期和时间。                                     |
| `updated_at` | datetime | runner 控制器上次更新的日期和时间。                                    |

示例请求：

```shell
curl --request PUT \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"description": "Updated runner controller", "state": "enabled"}' \
     --url "https://gitlab.example.com/api/v4/runner_controllers/3"
```

示例响应：

```json
{
    "id": 3,
    "description": "Updated runner controller",
    "state": "enabled",
    "created_at": "2026-01-05T00:00:00Z",
    "updated_at": "2026-01-06T00:00:00Z"
}
```

<a id="delete-a-runner-controller"></a>

## 删除 runner 控制器

通过其 ID 删除特定的 runner 控制器。

```plaintext
DELETE /runner_controllers/:id
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/3"
```

<a id="runner-controller-scopes"></a>

## Runner 控制器作用域

Runner 控制器作用域定义了一个 runner 控制器为准入控制评估哪些作业。
Runner 控制器必须至少有一个作用域才能接收准入请求。没有任何作用域，即使其状态是 `enabled` 或 `dry_run`，控制器也会保持非活跃状态。

Runner 控制器作用域支持两种互斥的作用域类型：

- **实例作用域**: Runner 控制器评估极狐GitLab 实例中所有 runner 的作业。
- **Runner 作用域**: Runner 控制器仅评估特定实例 runner 的作业。

一个 runner 控制器可以有一个实例作用域或一个或多个 runner 作用域，但不能两者兼有。

> [!note]
> 目前只有实例和 runner 作用域可用。其他作用域类型（群组、项目）在议题中提出。

<a id="list-all-scopes-for-a-runner-controller"></a>

### 列出一个 runner 控制器的所有作用域

列出一个特定 runner 控制器配置的所有作用域：

```plaintext
GET /runner_controllers/:id/scopes
```

支持的属性：

| 属性 | 类型   | 是否必需 | 描述                      |
|------|--------|----------|--------------------------|
| `id` | 整数    | 是       | runner 控制器的 ID。       |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                    | 类型         | 描述                                             |
|----------------------------------------|--------------|--------------------------------------------------|
| `instance_level_scopings`              | object array | runner 控制器的实例作用域列表。                        |
| `instance_level_scopings[].created_at` | datetime     | 作用域创建的日期和时间。                             |
| `instance_level_scopings[].updated_at` | datetime     | 作用域上次更新的日期和时间。                         |
| `runner_level_scopings`                | object array | runner 控制器的 runner 作用域列表。                   |
| `runner_level_scopings[].runner_id`    | 整数          | runner 的 ID。                                  |
| `runner_level_scopings[].created_at`   | datetime     | 作用域创建的日期和时间。                             |
| `runner_level_scopings[].updated_at`   | datetime     | 作用域上次更新的日期和时间。                         |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/1/scopes"
```

示例响应：

```json
{
    "instance_level_scopings": [
        {
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z"
        }
    ],
    "runner_level_scopings": []
}
```

<a id="add-instance-scope"></a>

### 添加实例作用域

向 runner 控制器添加一个实例作用域。添加后，runner 控制器会评估极狐GitLab 实例中所有 runner 的作业。

一个 runner 控制器只能有一个实例作用域。如果实例作用域已存在，此端点将返回一个错误。

```plaintext
POST /runner_controllers/:id/scopes/instance
```

支持的属性：

| 属性 | 类型   | 是否必需 | 描述                      |
|------|--------|----------|--------------------------|
| `id` | 整数    | 是       | runner 控制器的 ID。       |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性           | 类型     | 描述                          |
|---------------|----------|------------------------------|
| `created_at`  | datetime | 作用域创建时的日期和时间。         |
| `updated_at`  | datetime | 作用域上次更新的日期和时间。      |

示例请求：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/1/scopes/instance"
```

示例响应：

```json
{
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-01T00:00:00Z"
}
```

<a id="remove-instance-scope"></a>

### 移除实例作用域

从 runner 控制器移除一个实例作用域。

```plaintext
DELETE /runner_controllers/:id/scopes/instance
```

支持的属性：

| 属性     | 类型   | 是否必需 | 描述                      |
|---------|--------|----------|--------------------------|
| `id`    | 整数    | 是       | runner 控制器的 ID。       |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/1/scopes/instance"
```

<a id="add-runner-scope"></a>

### 添加 Runner 作用域

{{< history >}}

- 在极狐GitLab 18.10 中引入。

{{< /history >}}

向 runner 控制器添加一个 runner 作用域。添加后，runner 控制器仅评估指定 runner 的作业。

具有实例作用域的 runner 控制器不能有 runner 作用域。请在添加 runner 作用域之前移除实例作用域。

```plaintext
POST /runner_controllers/:id/scopes/runners/:runner_id
```

支持的属性：

| 属性        | 类型   | 是否必需 | 描述                              |
|------------|--------|----------|----------------------------------|
| `id`       | 整数    | 是       | runner 控制器的 ID。               |
| `runner_id`| 整数    | 是       | runner 的 ID。必须是一个实例 runner。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性        | 类型     | 描述                          |
|------------|----------|------------------------------|
| `runner_id`| 整数      | runner 的 ID。               |
| `created_at`| datetime | 作用域创建的日期和时间。         |
| `updated_at`| datetime | 作用域上次更新的日期和时间。      |

示例请求：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/1/scopes/runners/5"
```

示例响应：

```json
{
    "runner_id": 5,
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-01T00:00:00Z"
}
```

<a id="remove-runner-scope"></a>

### 移除 Runner 作用域

{{< history >}}

- 在极狐GitLab 18.10 中引入。

{{< /history >}}

从 runner 控制器移除一个 runner 作用域。

```plaintext
DELETE /runner_controllers/:id/scopes/runners/:runner_id
```

支持的属性：

| 属性        | 类型   | 是否必需 | 描述                      |
|------------|--------|----------|--------------------------|
| `id`       | 整数    | 是       | runner 控制器的 ID。       |
| `runner_id`| 整数    | 是       | runner 的 ID。            |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/1/scopes/runners/5"
```