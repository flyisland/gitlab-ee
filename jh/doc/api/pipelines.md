---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API 用于创建、管理和监控 CI/CD 流水线。
title: 流水线 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [CI/CD 流水线](../ci/pipelines/_index.md)交互。

<a id="list-pipelines"></a>

## 列出流水线

列出由已认证用户触发的所有项目中的流水线。

仅返回最近创建的流水线。要列出特定项目的完整流水线历史记录，请使用[列出项目流水线](#list-project-pipelines)。

用户已无法访问的项目中的流水线不会包含在结果中。默认情况下，结果中不包含[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。要返回子流水线，请将 `source` 设置为 `parent_pipeline`。

仅当[合并请求流水线](../ci/pipelines/merge_request_pipelines.md)的合并请求对用户可见时，响应中才会包含 `merge_request` 字段。

```plaintext
GET /pipelines
```

结果采用[分页](rest/_index.md#keyset-based-pagination)方式，每页最多返回 100 条记录（默认 20 条）。不支持基于偏移量的分页。要获取下一页结果，请使用 `Link` 响应头中的 URL。

支持的属性：

| 属性        | 类型     | 是否必需 | 描述 |
|------------------|----------|----------|-------------|
| `created_after`  | datetime | 否       | 返回在指定日期之后创建的流水线。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before` | datetime | 否       | 返回在指定日期之前创建的流水线。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `cursor`         | string   | 否       | 用于键集分页的游标，来自上一次响应的 `Link` 响应头。 |
| `order_by`       | string   | 否       | 按 `created_at` 对流水线排序。仅支持 `created_at`。默认值：`created_at`。 |
| `sort`           | string   | 否       | 按 `desc` 顺序对流水线排序。仅支持 `desc`。默认值：`desc`。 |
| `source`         | string   | 否       | 返回具有指定[来源](../ci/jobs/job_rules.md#ci_pipeline_source-predefined-variable)的流水线。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/pipelines?created_after=2016-08-11T00:00:00Z"
```

响应示例

```json
[
  {
    "id": 47,
    "iid": 12,
    "project_id": 1,
    "status": "running",
    "source": "merge_request_event",
    "ref": "refs/merge-requests/14/merge",
    "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
    "name": "Build pipeline",
    "web_url": "https://example.com/foo/bar/pipelines/47",
    "created_at": "2016-08-11T11:28:34.085Z",
    "updated_at": "2016-08-11T11:32:35.169Z",
    "started_at": "2016-08-11T11:28:54.085Z",
    "finished_at": null,
    "duration": null,
    "queued_duration": 20,
    "detailed_status": {
      "icon": "status_running",
      "text": "Running",
      "label": "running",
      "group": "running",
      "tooltip": "running",
      "has_details": true,
      "details_path": "/foo/bar/-/pipelines/47",
      "illustration": null,
      "favicon": "/assets/ci_favicons/favicon_status_running.png"
    },
    "merge_request": {
      "iid": 14,
      "title": "Add rate limiting to the public API",
      "web_url": "https://example.com/foo/bar/-/merge_requests/14"
    },
    "project": {
      "id": 1,
      "description": "",
      "name": "Bar",
      "name_with_namespace": "Foo / Bar",
      "path": "bar",
      "path_with_namespace": "foo/bar",
      "created_at": "2016-08-10T09:00:00.000Z"
    }
  },
  {
    "id": 51,
    "iid": 5,
    "project_id": 3,
    "status": "success",
    "source": "web",
    "ref": "main",
    "sha": "eb94b618fb5865b26e80fdd8ae531b7a63ad851a",
    "name": "Deploy pipeline",
    "web_url": "https://example.com/foo/baz/pipelines/51",
    "created_at": "2016-08-11T09:07:01.514Z",
    "updated_at": "2016-08-11T09:12:44.782Z",
    "started_at": "2016-08-11T09:07:31.514Z",
    "finished_at": "2016-08-11T09:12:44.782Z",
    "duration": 313,
    "queued_duration": 30,
    "detailed_status": {
      "icon": "status_success",
      "text": "Passed",
      "label": "passed",
      "group": "success",
      "tooltip": "passed",
      "has_details": true,
      "details_path": "/foo/baz/-/pipelines/51",
      "illustration": null,
      "favicon": "/assets/ci_favicons/favicon_status_success.png"
    },
    "project": {
      "id": 3,
      "description": "",
      "name": "Baz",
      "name_with_namespace": "Foo / Baz",
      "path": "baz",
      "path_with_namespace": "foo/baz",
      "created_at": "2016-08-10T09:00:00.000Z"
    }
  }
]
```

<a id="list-project-pipelines"></a>

## 列出项目流水线

列出项目中的流水线。

默认情况下，结果中不包含[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。要返回子流水线，请将 `source` 设置为 `parent_pipeline`。

```plaintext
GET /projects/:id/pipelines
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`           | string            | 否       | 返回具有指定名称的流水线。 |
| `order_by`       | string            | 否       | 用于对流水线排序的字段：`id`、`status`、`ref`、`updated_at` 或 `user_id`（默认值：`id`）。 |
| `ref`            | string            | 否       | 返回指定分支或标签的流水线。 |
| `scope`          | string            | 否       | 返回指定范围内的流水线：`running`、`pending`、`finished`、`branches` 或 `tags`。 |
| `sha`            | string            | 否       | 返回指定提交 SHA 的流水线。 |
| `sort`           | string            | 否       | 排序顺序：`asc` 或 `desc`（默认值：`desc`）。 |
| `source`         | string            | 否       | 返回具有指定[来源](../ci/jobs/job_rules.md#ci_pipeline_source-predefined-variable)的流水线。 |
| `status`         | string            | 否       | 返回具有指定状态的流水线：`created`、`waiting_for_resource`、`preparing`、`waiting_for_callback`、`pending`、`running`、`success`、`failed`、`canceling`、`canceled`、`skipped`、`manual` 或 `scheduled`。 |
| `updated_after`  | datetime          | 否       | 返回在指定日期之后更新的流水线。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `updated_before` | datetime          | 否       | 返回在指定日期之前更新的流水线。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_after`  | datetime          | 否       | 返回在指定日期之后创建的流水线。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before` | datetime          | 否       | 返回在指定日期之前创建的流水线。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `username`       | string            | 否       | 返回由指定用户名触发的流水线。 |
| `yaml_errors`    | boolean           | 否       | 返回配置无效的流水线。 |

当 `scope` 设置为 `branches` 或 `tags` 时，API 仅返回每个分支或标签 ref 的最新流水线。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines"
```

响应示例

```json
[
  {
    "id": 47,
    "iid": 12,
    "project_id": 1,
    "status": "pending",
    "source": "push",
    "ref": "new-pipeline",
    "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
    "name": "Build pipeline",
    "web_url": "https://example.com/foo/bar/pipelines/47",
    "created_at": "2016-08-11T11:28:34.085Z",
    "updated_at": "2016-08-11T11:32:35.169Z"
  },
  {
    "id": 48,
    "iid": 13,
    "project_id": 1,
    "status": "pending",
    "source": "web",
    "ref": "new-pipeline",
    "sha": "eb94b618fb5865b26e80fdd8ae531b7a63ad851a",
    "name": "Build pipeline",
    "web_url": "https://example.com/foo/bar/pipelines/48",
    "created_at": "2016-08-12T10:06:04.561Z",
    "updated_at": "2016-08-12T10:09:56.223Z"
  }
]
```

<a id="retrieve-a-single-pipeline"></a>

## 检索单个流水线

从项目中检索单个流水线。

您也可以获取单个[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。

```plaintext
GET /projects/:id/pipelines/:pipeline_id
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46"
```

响应示例

```json
{
  "id": 287,
  "iid": 144,
  "project_id": 21,
  "name": "Build pipeline",
  "sha": "50f0acb76a40e34a4ff304f7347dcc6587da8a14",
  "ref": "main",
  "status": "success",
  "source": "push",
  "created_at": "2022-09-21T01:05:07.200Z",
  "updated_at": "2022-09-21T01:05:50.185Z",
  "web_url": "http://127.0.0.1:3000/test-group/test-project/-/pipelines/287",
  "before_sha": "8a24fb3c5877a6d0b611ca41fc86edc174593e2b",
  "tag": false,
  "yaml_errors": null,
  "user": {
    "id": 1,
    "username": "root",
    "name": "Administrator",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://127.0.0.1:3000/root"
  },
  "started_at": "2022-09-21T01:05:14.197Z",
  "finished_at": "2022-09-21T01:05:50.175Z",
  "committed_at": null,
  "duration": 34,
  "queued_duration": 6,
  "coverage": null,
  "detailed_status": {
    "icon": "status_success",
    "text": "passed",
    "label": "passed",
    "group": "success",
    "tooltip": "passed",
    "has_details": false,
    "details_path": "/test-group/test-project/-/pipelines/287",
    "illustration": null,
    "favicon": "/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png"
  },
  "archived": false
}
```

<a id="retrieve-the-latest-pipeline"></a>

## 检索最新流水线

检索项目中特定 ref 上最近一次提交的最新流水线。如果该提交不存在流水线，则返回 `403` 状态码。

```plaintext
GET /projects/:id/pipelines/latest
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

| 属性 | 类型   | 是否必需 | 描述 |
|-----------|--------|----------|-------------|
| `ref`     | string | 否       | 要检查最新流水线的分支或标签。未指定时默认为默认分支。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/latest"
```

响应示例

```json
{
    "id": 287,
    "iid": 144,
    "project_id": 21,
    "name": "Build pipeline",
    "sha": "50f0acb76a40e34a4ff304f7347dcc6587da8a14",
    "ref": "main",
    "status": "success",
    "source": "push",
    "created_at": "2022-09-21T01:05:07.200Z",
    "updated_at": "2022-09-21T01:05:50.185Z",
    "web_url": "http://127.0.0.1:3000/test-group/test-project/-/pipelines/287",
    "before_sha": "8a24fb3c5877a6d0b611ca41fc86edc174593e2b",
    "tag": false,
    "yaml_errors": null,
    "user": {
        "id": 1,
        "username": "root",
        "name": "Administrator",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "http://127.0.0.1:3000/root"
    },
    "started_at": "2022-09-21T01:05:14.197Z",
    "finished_at": "2022-09-21T01:05:50.175Z",
    "committed_at": null,
    "duration": 34,
    "queued_duration": 6,
    "coverage": null,
    "detailed_status": {
        "icon": "status_success",
        "text": "passed",
        "label": "passed",
        "group": "success",
        "tooltip": "passed",
        "has_details": false,
        "details_path": "/test-group/test-project/-/pipelines/287",
        "illustration": null,
        "favicon": "/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png"
    },
    "archived": false
}
```

<a id="retrieve-pipeline-variables"></a>

## 检索流水线变量

检索流水线的[流水线变量](../ci/variables/_index.md#use-pipeline-variables)。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/variables
```

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/variables"
```

响应示例

```json
[
  {
    "key": "RUN_NIGHTLY_BUILD",
    "variable_type": "env_var",
    "value": "true"
  },
  {
    "key": "foo",
    "value": "bar"
  }
]
```

<a id="retrieve-a-test-report-for-a-pipeline"></a>

## 检索流水线的测试报告

> [!note]
> 此 API 路由是[单元测试报告](../ci/testing/unit_test_reports.md)功能的一部分。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/test_report
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/test_report"
```

示例响应：

```json
{
  "total_time": 5,
  "total_count": 1,
  "success_count": 1,
  "failed_count": 0,
  "skipped_count": 0,
  "error_count": 0,
  "test_suites": [
    {
      "name": "Secure",
      "total_time": 5,
      "total_count": 1,
      "success_count": 1,
      "failed_count": 0,
      "skipped_count": 0,
      "error_count": 0,
      "test_cases": [
        {
          "status": "success",
          "name": "Security Reports can create an auto-remediation MR",
          "classname": "vulnerability_management_spec",
          "execution_time": 5,
          "system_output": null,
          "stack_trace": null
        }
      ]
    }
  ]
}
```

<a id="retrieve-a-test-report-summary-for-a-pipeline"></a>

## 检索流水线的测试报告摘要

> [!note]
> 此 API 路由是[单元测试报告](../ci/testing/unit_test_reports.md)功能的一部分。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/test_report_summary
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/test_report_summary"
```

示例响应：

```json
{
    "total": {
        "time": 1904,
        "count": 3363,
        "success": 3351,
        "failed": 0,
        "skipped": 12,
        "error": 0,
        "suite_error": null
    },
    "test_suites": [
        {
            "name": "test",
            "total_time": 1904,
            "total_count": 3363,
            "success_count": 3351,
            "failed_count": 0,
            "skipped_count": 12,
            "error_count": 0,
            "build_ids": [
                66004
            ],
            "suite_error": null
        }
    ]
}
```

<a id="create-a-new-pipeline"></a>

## 创建新流水线

```plaintext
POST /projects/:id/pipeline
```

| 属性   | 类型           | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `ref`       | string         | 是      | 要在其上运行流水线的分支或标签。对于合并请求流水线，请使用[合并请求端点](merge_requests.md#create-merge-request-pipeline)。 |
| `variables` | array          | 否       | 包含流水线中可用变量的[哈希数组](rest/_index.md#array-of-hashes)，结构为 `[{ 'key': 'UPLOAD_TO_S3', 'variable_type': 'file', 'value': 'true' }, {'key': 'TEST', 'value': 'test variable'}]`。如果省略 `variable_type`，则默认为 `env_var`。 |
| `inputs`    | hash           | 否       | 包含输入的[哈希](rest/_index.md#hash)，以键值对形式表示，在创建流水线时使用。 |

基本示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipeline?ref=main"
```

使用[输入](../ci/inputs/_index.md)的示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipeline?ref=main" \
  --data '{"inputs": {"environment": "environment", "scan_security": false, "level": 3}}'
```

响应示例

```json
{
  "id": 61,
  "iid": 21,
  "project_id": 1,
  "sha": "384c444e840a515b23f21915ee5766b87068a70d",
  "ref": "main",
  "status": "pending",
  "before_sha": "0000000000000000000000000000000000000000",
  "tag": false,
  "yaml_errors": null,
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://localhost:3000/root"
  },
  "created_at": "2016-11-04T09:36:13.747Z",
  "updated_at": "2016-11-04T09:36:13.977Z",
  "started_at": null,
  "finished_at": null,
  "committed_at": null,
  "duration": null,
  "queued_duration": 0.010,
  "coverage": null,
  "web_url": "https://example.com/foo/bar/pipelines/61",
  "archived": false
}
```

<a id="retry-jobs-in-a-pipeline"></a>

## 重试流水线中的作业

> [!flag]
> `409 Conflict` 响应的可用性由功能标志控制。

重试流水线中失败或已取消的作业。如果流水线中没有失败或已取消的作业，则调用此端点不会产生任何效果。

如果超出[流水线重试速率限制](../administration/cicd/limits.md#pipeline-retry-rate-limits)，此端点将返回 `429 Too Many Requests` 状态码。

同一流水线同一时间只能执行一次重试。如果同一流水线的重试已在进行中，此端点将返回 `409 Conflict` 状态码。请等待重试完成，然后再次发送请求。

```plaintext
POST /projects/:id/pipelines/:pipeline_id/retry
```

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/retry"
```

响应：

```json
{
  "id": 46,
  "iid": 11,
  "project_id": 1,
  "status": "pending",
  "ref": "main",
  "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "before_sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "tag": false,
  "yaml_errors": null,
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://localhost:3000/root"
  },
  "created_at": "2016-08-11T11:28:34.085Z",
  "updated_at": "2016-08-11T11:32:35.169Z",
  "started_at": null,
  "finished_at": "2016-08-11T11:32:35.145Z",
  "committed_at": null,
  "duration": null,
  "queued_duration": 0.010,
  "coverage": null,
  "web_url": "https://example.com/foo/bar/pipelines/46",
  "archived": false
}
```

<a id="cancel-all-jobs-for-a-pipeline"></a>

## 取消流水线的所有作业

```plaintext
POST /projects/:id/pipelines/:pipeline_id/cancel
```

> [!note]
> 无论流水线处于何种状态，此端点都会返回成功响应 `200`。
> 更多信息，请参见[议题 414963](https://gitlab.com/gitlab-org/gitlab/-/issues/414963)。

如果超出[流水线取消速率限制](../administration/cicd/limits.md#pipeline-cancellation-rate-limits)，此端点将返回 `429 Too Many Requests` 状态码，并带有 `Retry-After` 响应头。

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/cancel"
```

响应：

```json
{
  "id": 46,
  "iid": 11,
  "project_id": 1,
  "status": "canceled",
  "ref": "main",
  "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "before_sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "tag": false,
  "yaml_errors": null,
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://localhost:3000/root"
  },
  "created_at": "2016-08-11T11:28:34.085Z",
  "updated_at": "2016-08-11T11:32:35.169Z",
  "started_at": null,
  "finished_at": "2016-08-11T11:32:35.145Z",
  "committed_at": null,
  "duration": null,
  "queued_duration": 0.010,
  "coverage": null,
  "web_url": "https://example.com/foo/bar/pipelines/46",
  "archived": false
}
```

<a id="delete-a-pipeline"></a>

## 删除流水线

删除流水线会使所有流水线缓存过期，并删除所有直接相关的对象，例如构建、日志、产物和触发器。此操作无法撤销。

此端点受[速率限制](../administration/cicd/limits.md#pipeline-deletion-rate-limits)，超出限制时会返回 `429 Too Many Requests` 以及 `Retry-After` 响应头。

删除流水线不会自动删除其[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。详情请参见[相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/39503)。

先决条件：

- 项目的所有者角色。

```plaintext
DELETE /projects/:id/pipelines/:pipeline_id
```

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46"
```

<a id="update-pipeline-metadata"></a>

## 更新流水线元数据

更新流水线元数据。元数据包含流水线的名称。

```plaintext
PUT /projects/:id/pipelines/:pipeline_id/metadata
```

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name`        | string         | 是      | 流水线的新名称 |
| `pipeline_id` | integer        | 是      | 流水线的 ID |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/metadata" \
  --data '{"name": "Some new pipeline name"}'
```

示例响应：

```json
{
  "id": 46,
  "iid": 11,
  "project_id": 1,
  "status": "running",
  "ref": "main",
  "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "before_sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "tag": false,
  "yaml_errors": null,
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://localhost:3000/root"
  },
  "created_at": "2016-08-11T11:28:34.085Z",
  "updated_at": "2016-08-11T11:32:35.169Z",
  "started_at": null,
  "finished_at": "2016-08-11T11:32:35.145Z",
  "committed_at": null,
  "duration": null,
  "queued_duration": 0.010,
  "coverage": null,
  "web_url": "https://example.com/foo/bar/pipelines/46",
  "name": "Some new pipeline name",
  "archived": false
}
```
