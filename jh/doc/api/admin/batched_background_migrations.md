---
stage: Data Access
group: Database Frameworks
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于列出、检索、暂停和恢复批处理后台迁移的 REST API。
title: 批处理后台迁移 API
ignore_in_report: true
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 来监控和管理[批处理后台迁移](../../update/background_migrations.md)。

先决条件：

- 您必须具有该实例的管理员访问权限。

<a id="list-the-last-20-batched-background-migrations"></a>

## 列出最近 20 个批处理后台迁移

列出所有批处理后台迁移。

```plaintext
GET /api/v4/admin/batched_background_migrations
```

支持的属性：

| 属性        | 类型   | 必填 | 描述 |
|------------------|--------|----------|-------------|
| `database`       | string | 否       | 数据库名称。默认为 `main`。 |
| `job_class_name` | string | 否       | 按作业类名称筛选迁移。 |

如果成功，返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                  | 类型     | 描述 |
|----------------------------|----------|-------------|
| `column_name`              | string   | 迁移迭代的列的名称。 |
| `created_at`               | datetime | 迁移创建时的时间戳。 |
| `estimated_time_remaining` | string   | 迁移完成前的预计时间。有时为 null |
| `id`                       | integer  | 批处理后台迁移的 ID。 |
| `job_class_name`           | string   | 迁移作业类的名称。 |
| `progress`                 | float    | 迁移的完成百分比。 |
| `status`                   | string   | 迁移的状态。可以是 `paused`、`active`、`finished`、`failed`、`finalizing` 或 `finalized`。 |
| `table_name`               | string   | 迁移迭代的表的名称。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/batched_background_migrations"
```

示例响应：

```json
[
  {
    "id": 1234,
    "job_class_name": "CopyColumnUsingBackgroundMigrationJob",
    "table_name": "events",
    "column_name": "id",
    "status": "active",
    "progress": 50.0,
    "created_at": "2022-11-28T16:26:39+02:00",
    "estimated_time_remaining": "1 day"
  }
]
```

<a id="retrieve-a-batched-background-migration"></a>

## 检索批处理后台迁移

检索批处理后台迁移。

```plaintext
GET /api/v4/admin/batched_background_migrations/:id
```

支持的属性：

| 属性  | 类型    | 必填 | 描述 |
|------------|---------|----------|-------------|
| `id`       | integer | 是      | 批处理后台迁移的 ID。 |
| `database` | string  | 否       | 数据库名称。默认为 `main`。 |

如果成功，返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                  | 类型     | 描述 |
|----------------------------|----------|-------------|
| `column_name`              | string   | 迁移迭代的列的名称。 |
| `created_at`               | datetime | 迁移创建时的时间戳。 |
| `estimated_time_remaining` | string   | 迁移完成前的预计时间。 |
| `id`                       | integer  | 批处理后台迁移的 ID。 |
| `job_class_name`           | string   | 迁移作业类的名称。 |
| `progress`                 | float    | 迁移的完成百分比。 |
| `status`                   | string   | 迁移的状态。可以是 `paused`、`active`、`finished`、`failed`、`finalizing` 或 `finalized`。 |
| `table_name`               | string   | 迁移迭代的表的名称。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/batched_background_migrations/1234"
```

示例响应：

```json
{
  "id": 1234,
  "job_class_name": "CopyColumnUsingBackgroundMigrationJob",
  "table_name": "events",
  "column_name": "id",
  "status": "active",
  "progress": 50.0,
  "created_at": "2022-11-28T16:26:39+02:00",
  "estimated_time_remaining": "1 day"
}
```

<a id="pause-a-batched-background-migration"></a>

## 暂停批处理后台迁移

暂停批处理后台迁移。您只能暂停状态为 `active` 的迁移。

```plaintext
PUT /api/v4/admin/batched_background_migrations/:id/pause
```

支持的属性：

| 属性  | 类型    | 必填 | 描述 |
|------------|---------|----------|-------------|
| `id`       | integer | 是      | 批处理后台迁移的 ID。 |
| `database` | string  | 否       | 数据库名称。默认为 `main`。 |

如果成功，返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                  | 类型     | 描述 |
|----------------------------|----------|-------------|
| `column_name`              | string   | 迁移迭代的列的名称。 |
| `created_at`               | datetime | 迁移创建时的时间戳。 |
| `estimated_time_remaining` | string   | 迁移完成前的预计时间。 |
| `id`                       | integer  | 批处理后台迁移的 ID。 |
| `job_class_name`           | string   | 迁移作业类的名称。 |
| `progress`                 | float    | 迁移的完成百分比。 |
| `status`                   | string   | 迁移的状态。可以是 `paused`、`active`、`finished`、`failed`、`finalizing` 或 `finalized`。 |
| `table_name`               | string   | 迁移迭代的表的名称。 |

如果迁移的状态不是 `active`，则返回 [`422 Unprocessable Entity`](../rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/batched_background_migrations/1234/pause"
```

示例响应：

```json
{
  "id": 1234,
  "job_class_name": "CopyColumnUsingBackgroundMigrationJob",
  "table_name": "events",
  "column_name": "id",
  "status": "paused",
  "progress": 50.0,
  "created_at": "2022-11-28T16:26:39+02:00",
  "estimated_time_remaining": "1 day"
}
```

<a id="resume-a-batched-background-migration"></a>

## 恢复批处理后台迁移

恢复批处理后台迁移。您只能恢复状态为 `paused` 的迁移。

```plaintext
PUT /api/v4/admin/batched_background_migrations/:id/resume
```

支持的属性：

| 属性  | 类型    | 必填 | 描述 |
|------------|---------|----------|-------------|
| `id`       | integer | 是      | 批处理后台迁移的 ID。 |
| `database` | string  | 否       | 数据库名称。默认为 `main`。 |

如果成功，返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                  | 类型     | 描述 |
|----------------------------|----------|-------------|
| `column_name`              | string   | 迁移迭代的列的名称。 |
| `created_at`               | datetime | 迁移创建时的时间戳。 |
| `estimated_time_remaining` | string   | 迁移完成前的预计时间。 |
| `id`                       | integer  | 批处理后台迁移的 ID。 |
| `job_class_name`           | string   | 迁移作业类的名称。 |
| `progress`                 | float    | 迁移的完成百分比。 |
| `status`                   | string   | 迁移的状态。可以是 `paused`、`active`、`finished`、`failed`、`finalizing` 或 `finalized`。 |
| `table_name`               | string   | 迁移迭代的表的名称。 |

如果迁移的状态不是 `paused`，则返回 [`422 Unprocessable Entity`](../rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/batched_background_migrations/1234/resume"
```

示例响应：

```json
{
  "id": 1234,
  "job_class_name": "CopyColumnUsingBackgroundMigrationJob",
  "table_name": "events",
  "column_name": "id",
  "status": "active",
  "progress": 50.0,
  "created_at": "2022-11-28T16:26:39+02:00",
  "estimated_time_remaining": "1 day"
}
```
