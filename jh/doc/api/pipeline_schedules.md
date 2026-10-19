---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线计划 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[流水线计划](../ci/pipelines/schedules.md)进行交互。

<a id="list-all-pipeline-schedules"></a>

## 列出所有流水线计划

列出项目的所有流水线计划。

```plaintext
GET /projects/:id/pipeline_schedules
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `scope`   | string            | 否       | 流水线计划的范围，必须为以下之一：`active`、`inactive`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules"
```

```json
[
    {
        "id": 13,
        "description": "测试计划流水线",
        "ref": "refs/heads/main",
        "cron": "* * * * *",
        "cron_timezone": "Asia/Tokyo",
        "next_run_at": "2017-05-19T13:41:00.000Z",
        "active": true,
        "created_at": "2017-05-19T13:31:08.849Z",
        "updated_at": "2017-05-19T13:40:17.727Z",
        "owner": {
            "name": "Administrator",
            "username": "root",
            "id": 1,
            "state": "active",
            "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
            "web_url": "https://gitlab.example.com/root"
        },
        "inputs": [
            {
                "name": "deploy_strategy",
                "value": "blue-green"
            },
            {
                "name": "feature_flags",
                "value": ["flag1", "flag2"]
            }
        ]
    }
]
```

> [!note]
> `inputs` 字段仅在响应中返回给具有维护者或所有者角色的用户，或返回给计划所有者。

<a id='retrieve-a-pipeline-schedule'></a>

## 获取流水线计划

获取项目的流水线计划。

```plaintext
GET /projects/:id/pipeline_schedules/:pipeline_schedule_id
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13"
```

```json
{
    "id": 13,
    "description": "测试计划流水线",
    "ref": "refs/heads/main",
    "cron": "* * * * *",
    "cron_timezone": "Asia/Tokyo",
    "next_run_at": "2017-05-19T13:41:00.000Z",
    "active": true,
    "created_at": "2017-05-19T13:31:08.849Z",
    "updated_at": "2017-05-19T13:40:17.727Z",
    "last_pipeline": {
        "id": 332,
        "sha": "0e788619d0b5ec17388dffb973ecd505946156db",
        "ref": "refs/heads/main",
        "status": "pending"
    },
    "owner": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/root"
    },
    "variables": [
        {
            "key": "TEST_VARIABLE_1",
            "variable_type": "env_var",
            "value": "TEST_1",
            "raw": false
        }
    ],
    "inputs": [
        {
            "name": "deploy_strategy",
            "value": "blue-green"
        },
        {
            "name": "feature_flags",
            "value": ["flag1", "flag2"]
        }
    ]
}
```

> [!note]
> `inputs` 和 `variables` 字段仅在响应中返回给具有维护者或所有者角色的用户，或返回给计划所有者。

<a id='list-all-pipelines-triggered-by-a-pipeline-schedule'></a>

## 列出由流水线计划触发的所有流水线

列出项目中由流水线计划触发的所有流水线。

```plaintext
GET /projects/:id/pipeline_schedules/:pipeline_schedule_id/pipelines
```

支持的属性：

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |
| `scope`                | string            | 否       | 流水线的范围。为以下之一：`running`、`pending`、`finished`、`branches`、`tags`。 |
| `sort`                 | string            | 否       | 以 `asc` 或 `desc` 顺序对流水线进行排序。默认为 `asc`。 |
| `status`               | string            | 否       | 流水线的状态。为以下之一：`created`、`waiting_for_resource`、`preparing`、`pending`、`running`、`success`、`failed`、`canceled`、`skipped`、`manual`、`scheduled`。 |
| `updated_after`        | datetime          | 否       | 返回在指定日期之后更新的流水线。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `updated_before`       | datetime          | 否       | 返回在指定日期之前更新的流水线。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `created_after`        | datetime          | 否       | 返回在指定日期之后创建的流水线。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `created_before`       | datetime          | 否       | 返回在指定日期之前创建的流水线。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13/pipelines"
```

响应示例：

```json
[
  {
    "id": 47,
    "iid": 12,
    "project_id": 29,
    "status": "pending",
    "source": "scheduled",
    "ref": "new-pipeline",
    "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
    "web_url": "https://example.com/foo/bar/pipelines/47",
    "created_at": "2016-08-11T11:28:34.085Z",
    "updated_at": "2016-08-11T11:32:35.169Z"
  },
  {
    "id": 48,
    "iid": 13,
    "project_id": 29,
    "status": "pending",
    "source": "scheduled",
    "ref": "new-pipeline",
    "sha": "eb94b618fb5865b26e80fdd8ae531b7a63ad851a",
    "web_url": "https://example.com/foo/bar/pipelines/48",
    "created_at": "2016-08-12T10:06:04.561Z",
    "updated_at": "2016-08-12T10:09:56.223Z"
  }
]
```

<a id='create-a-new-pipeline-schedule'></a>

## 创建新的流水线计划

{{< history >}}

- `inputs` 属性在极狐GitLab 17.11 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/525504)，[带有功能标志](../administration/feature_flags/_index.md)，名称为 `ci_inputs_for_pipelines`。默认启用。
- `inputs` 属性在极狐GitLab 18.1 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/536548)。功能标志 `ci_inputs_for_pipelines` 已移除。

{{< /history >}}

创建项目新的流水线计划。

```plaintext
POST /projects/:id/pipeline_schedules
```

| 属性       | 类型              | 是否必需 | 描述 |
| --------------- | ----------------- | -------- | ----------- |
| `cron`          | string            | 是      | Cron 计划，例如：`0 1 * * *`。 |
| `description`   | string            | 是      | 流水线计划的描述。 |
| `id`            | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `ref`           | string            | 是      | 触发流水线的分支或标签名称。接受短引用 (`main`) 或完整引用 (`refs/heads/main` 或 `refs/tags/main`)。除非该值可能同时匹配分支或标签，否则短引用会自动扩展为完整引用。 |
| `active`        | boolean           | 否       | 激活流水线计划。如果设置为 false，则流水线计划初始处于停用状态（默认：`true`）。 |
| `cron_timezone` | string            | 否       | `ActiveSupport::TimeZone` 支持的时区，例如：`Pacific Time (US & Canada)`（默认：`UTC`）。 |
| `inputs`        | hash              | 否       | 要传递给流水线计划的[输入](../ci/inputs/_index.md#for-a-pipeline)数组。每个输入包含 `name` 和 `value`。值可以是字符串、数组、数字或布尔值。 |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules" \
  --form "description=构建软件包" \
  --form "ref=main" \
  --form "cron=0 1 * * 5" \
  --form "cron_timezone=UTC" \
  --form "active=true"
```

响应示例：

```json
{
    "id": 14,
    "description": "构建软件包",
    "ref": "refs/heads/main",
    "cron": "0 1 * * 5",
    "cron_timezone": "UTC",
    "next_run_at": "2017-05-26T01:00:00.000Z",
    "active": true,
    "created_at": "2017-05-19T13:43:08.169Z",
    "updated_at": "2017-05-19T13:43:08.169Z",
    "last_pipeline": null,
    "owner": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/root"
    }
}
```

带有 `inputs` 的请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules" \
  --form "description=构建软件包" \
  --form "ref=main" \
  --form "cron=0 1 * * 5" \
  --form "cron_timezone=UTC" \
  --form "active=true" \
  --form "inputs[][name]=deploy_strategy" \
  --form "inputs[][value]=blue-green"
```

<a id='update-a-pipeline-schedule'></a>

## 更新流水线计划

更新项目的流水线计划。更新完成后，它将自动重新计划。

```plaintext
PUT /projects/:id/pipeline_schedules/:pipeline_schedule_id
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |
| `active`               | boolean           | 否       | 激活流水线计划。如果设置为 false，则流水线计划将被停用。 |
| `cron_timezone`        | string            | 否       | `ActiveSupport::TimeZone` 支持的时区（例如 `Pacific Time (US & Canada)`），或 `TZInfo::Timezone`（例如 `America/Los_Angeles`）。 |
| `cron`                 | string            | 否       | Cron 计划，例如：`0 1 * * *`。 |
| `description`          | string            | 否       | 流水线计划的描述。 |
| `ref`                  | string            | 否       | 触发流水线的分支或标签名称。接受短引用 (`main`) 或完整引用 (`refs/heads/main` 或 `refs/tags/main`)。除非该值可能同时匹配分支或标签，否则短引用会自动扩展为完整引用。 |
| `inputs`               | hash              | 否       | 要传递给流水线计划的[输入](../ci/inputs/_index.md)数组。每个输入包含 `name` 和 `value`。要删除现有输入，请包含 `name` 字段并将 `destroy` 设置为 `true`。值可以是字符串、数组、数字或布尔值。 |

请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13" \
  --form "cron=0 2 * * *"
```

响应示例：

```json
{
    "id": 13,
    "description": "测试计划流水线",
    "ref": "refs/heads/main",
    "cron": "0 2 * * *",
    "cron_timezone": "Asia/Tokyo",
    "next_run_at": "2017-05-19T17:00:00.000Z",
    "active": true,
    "created_at": "2017-05-19T13:31:08.849Z",
    "updated_at": "2017-05-19T13:44:16.135Z",
    "last_pipeline": {
        "id": 332,
        "sha": "0e788619d0b5ec17388dffb973ecd505946156db",
        "ref": "refs/heads/main",
        "status": "pending"
    },
    "owner": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/root"
    }
}
```

带有 `inputs` 的请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13" \
  --form "cron=0 2 * * *" \
  --form "inputs[][name]=deploy_strategy" \
  --form "inputs[][value]=rolling" \
  --form "inputs[][name]=existing_input" \
  --form "inputs[][destroy]=true"
```

<a id='update-ownership-of-a-pipeline-schedule'></a>

## 更新流水线计划的所有权

更新项目流水线计划的所有者。

```plaintext
POST /projects/:id/pipeline_schedules/:pipeline_schedule_id/take_ownership
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13/take_ownership"
```

```json
{
    "id": 13,
    "description": "测试计划流水线",
    "ref": "refs/heads/main",
    "cron": "0 2 * * *",
    "cron_timezone": "Asia/Tokyo",
    "next_run_at": "2017-05-19T17:00:00.000Z",
    "active": true,
    "created_at": "2017-05-19T13:31:08.849Z",
    "updated_at": "2017-05-19T13:46:37.468Z",
    "last_pipeline": {
        "id": 332,
        "sha": "0e788619d0b5ec17388dffb973ecd505946156db",
        "ref": "refs/heads/main",
        "status": "pending"
    },
    "owner": {
        "name": "shinya",
        "username": "maeda",
        "id": 50,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/8ca0a796a679c292e3a11da50f99e801?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/maeda"
    }
}
```

<a id='delete-a-pipeline-schedule'></a>

## 删除流水线计划

删除项目的流水线计划。

```plaintext
DELETE /projects/:id/pipeline_schedules/:pipeline_schedule_id
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13"
```

```json
{
    "id": 13,
    "description": "测试计划流水线",
    "ref": "refs/heads/main",
    "cron": "0 2 * * *",
    "cron_timezone": "Asia/Tokyo",
    "next_run_at": "2017-05-19T17:00:00.000Z",
    "active": true,
    "created_at": "2017-05-19T13:31:08.849Z",
    "updated_at": "2017-05-19T13:46:37.468Z",
    "last_pipeline": {
        "id": 332,
        "sha": "0e788619d0b5ec17388dffb973ecd505946156db",
        "ref": "refs/heads/main",
        "status": "pending"
    },
    "owner": {
        "name": "shinya",
        "username": "maeda",
        "id": 50,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/8ca0a796a679c292e3a11da50f99e801?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/maeda"
    }
}
```

<a id='run-a-pipeline-schedule-immediately'></a>

## 立即运行流水线计划

立即运行一个流水线计划。该流水线的下一次计划运行不受影响。

```plaintext
POST /projects/:id/pipeline_schedules/:pipeline_schedule_id/play
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/pipeline_schedules/1/play"
```

响应示例：

```json
{
  "message": "201 Created"
}
```

<a id='create-a-variable-for-a-pipeline-schedule'></a>

## 为流水线计划创建变量

为流水线计划创建一个新变量。

```plaintext
POST /projects/:id/pipeline_schedules/:pipeline_schedule_id/variables
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `key`                  | string            | 是      | 变量的键；必须不超过 255 个字符；仅允许 `A-Z`、`a-z`、`0-9` 和 `_`。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |
| `value`                | string            | 是      | 变量的值。 |
| `variable_type`        | string            | 否       | 变量的类型。可用类型为：`env_var`（默认）和 `file`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13/variables" \
  --form "key=NEW_VARIABLE" \
  --form "value=new value"
```

```json
{
    "key": "NEW_VARIABLE",
    "variable_type": "env_var",
    "value": "new value"
}
```

<a id='retrieve-a-variable-for-a-pipeline-schedule'></a>

## 获取流水线计划的变量

{{< history >}}

- 在极狐GitLab 18.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/386005)。

{{< /history >}}

获取流水线计划的变量。

```plaintext
GET /projects/:id/pipeline_schedules/:pipeline_schedule_id/variables/:key
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `key`                  | string            | 是      | 变量的键。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性       | 类型   | 描述 |
| --------------- | ------ | ----------- |
| `key`           | string | 变量的键。 |
| `value`         | string | 变量的值。 |
| `variable_type` | string | 变量的类型。为 `env_var` 或 `file`。 |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13/variables/NEW_VARIABLE"
```

响应示例：

```json
{
    "key": "NEW_VARIABLE",
    "variable_type": "env_var",
    "value": "new value"
}
```

<a id='update-a-variable-for-a-pipeline-schedule'></a>

## 更新流水线计划的变量

更新流水线计划的变量。

```plaintext
PUT /projects/:id/pipeline_schedules/:pipeline_schedule_id/variables/:key
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `key`                  | string            | 是      | 变量的键。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |
| `value`                | string            | 是      | 变量的值。 |
| `variable_type`        | string            | 否       | 变量的类型。可用类型为：`env_var`（默认）和 `file`。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13/variables/NEW_VARIABLE" \
  --form "value=updated value"
```

```json
{
    "key": "NEW_VARIABLE",
    "value": "updated value",
    "variable_type": "env_var"
}
```

<a id='delete-a-variable-for-a-pipeline-schedule'></a>

## 删除流水线计划的变量

删除流水线计划的变量。

```plaintext
DELETE /projects/:id/pipeline_schedules/:pipeline_schedule_id/variables/:key
```

| 属性              | 类型              | 是否必需 | 描述 |
| ---------------------- | ----------------- | -------- | ----------- |
| `id`                   | integer 或 string | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `key`                  | string            | 是      | 变量的键。 |
| `pipeline_schedule_id` | integer           | 是      | 流水线计划的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/29/pipeline_schedules/13/variables/NEW_VARIABLE"
```

```json
{
    "key": "NEW_VARIABLE",
    "value": "updated value"
}
```

<a id='ambiguous-refs'></a>

### 不明确的引用

在以下情况下，API 无法自动将短 `ref` 扩展为完整 `ref`：

- 存在与你的短 `ref` 同名的分支和标签。
- 不存在具有该名称的分支或标签。

要解决此问题，请提供完整的 `ref` 以确保识别正确的资源。