---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于创建、管理和监控 CI/CD 流水线的 REST API。
title: 流水线 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [CI/CD 流水线](../ci/pipelines/_index.md) 进行交互。

<a id="list-project-pipelines"></a>

## 列出项目流水线

{{< history >}}

- 响应中的 `name` 在 极狐GitLab 15.11 中引入，并带有一个名为 `pipeline_name_in_api` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 请求中的 `name` 在 15.11 中引入，并带有一个名为 `pipeline_name_search` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 响应中的 `name` 在 极狐GitLab 16.3 中 GA。功能标志 `pipeline_name_in_api` 已移除。
- 请求中的 `name` 在 极狐GitLab 16.9 中 GA。功能标志 `pipeline_name_search` 已移除。
- 支持通过将 `source` 设置为 `parent_pipeline` 来返回子流水线，在 极狐GitLab 17.0 中引入。

{{< /history >}}

列出项目中的流水线。

默认情况下，结果中不包含[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。要返回子流水线，请将 `source` 设置为 `parent_pipeline`。

```plaintext
GET /projects/:id/pipelines
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性 | 类型 | 必填 | 描述 |
|------------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 否 | 返回具有指定名称的流水线。 |
| `order_by` | 字符串 | 否 | 排序流水线的字段：`id`、`status`、`ref`、`updated_at` 或 `user_id`（默认：`id`）。 |
| `ref` | 字符串 | 否 | 返回指定分支或标签的流水线。 |
| `scope` | 字符串 | 否 | 返回指定范围的流水线：`running`、`pending`、`finished`、`branches` 或 `tags`。 |
| `sha` | 字符串 | 否 | 返回指定 commit SHA 的流水线。 |
| `sort` | 字符串 | 否 | 排序顺序：`asc` 或 `desc`（默认：`desc`）。 |
| `source` | 字符串 | 否 | 返回具有指定[来源](../ci/jobs/job_rules.md#ci_pipeline_source-predefined-variable)的流水线。 |
| `status` | 字符串 | 否 | 返回具有指定状态的流水线：`created`、`waiting_for_resource`、`preparing`、`pending`、`running`、`success`、`failed`、`canceled`、`skipped`、`manual` 或 `scheduled`。 |
| `updated_after` | 日期时间 | 否 | 返回在指定日期之后更新的流水线。日期应为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `updated_before` | 日期时间 | 否 | 返回在指定日期之前更新的流水线。日期应为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_after` | 日期时间 | 否 | 返回在指定日期之后创建的流水线。日期应为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before` | 日期时间 | 否 | 返回在指定日期之前创建的流水线。日期应为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `username` | 字符串 | 否 | 返回由指定用户名触发的流水线。 |
| `yaml_errors` | 布尔值 | 否 | 返回配置无效的流水线。 |

当 `scope` 设置为 `branches` 或 `tags` 时，API 仅返回每个分支或标签引用的最新流水线。

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

## 获取单个流水线

{{< history >}}

- 响应中的 `name` 在 极狐GitLab 15.11 中引入，并带有一个名为 `pipeline_name_in_api` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 响应中的 `name` 在 极狐GitLab 16.3 中 GA。功能标志 `pipeline_name_in_api` 已移除。

{{< /history >}}

获取项目中的单个流水线。

您也可以获取单个[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。

```plaintext
GET /projects/:id/pipelines/:pipeline_id
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

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

## 获取最新流水线

{{< history >}}

- 响应中的 `name` 在 极狐GitLab 15.11 中引入，并带有一个名为 `pipeline_name_in_api` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 响应中的 `name` 在 极狐GitLab 16.3 中 GA。功能标志 `pipeline_name_in_api` 已移除。

{{< /history >}}

获取项目中指定引用上最近提交的最新流水线。如果该提交不存在流水线，则返回 `403` 状态码。

```plaintext
GET /projects/:id/pipelines/latest
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性 | 类型 | 必填 | 描述 |
|-----------|--------|----------|-------------|
| `ref` | 字符串 | 否 | 要检查最新流水线的分支或标签。未指定时默认为默认分支。 |

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

## 获取流水线变量

获取流水线的[流水线变量](../ci/variables/_index.md#use-pipeline-variables)。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/variables
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

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

## 获取流水线的测试报告

> [!note]
> 此 API 路由是[单元测试报告](../ci/testing/unit_test_reports.md)功能的一部分。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/test_report
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/test_report"
```

响应示例：

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

## 获取流水线的测试报告摘要

> [!note]
> 此 API 路由是[单元测试报告](../ci/testing/unit_test_reports.md)功能的一部分。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/test_report_summary
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/test_report_summary"
```

响应示例：

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

{{< history >}}

- 响应中的 `iid` 在 极狐GitLab 14.6 中引入。
- `inputs` 属性在 极狐GitLab 17.10 中引入，并带有一个名为 `ci_inputs_for_pipelines` 的[功能标志](../administration/feature_flags/_index.md)。默认启用。
- `inputs` 属性在 极狐GitLab 18.1 中 GA。功能标志 `ci_inputs_for_pipelines` 已移除。

{{< /history >}}

```plaintext
POST /projects/:id/pipeline
```

| 属性 | 类型 | 必填 | 描述 |
|-------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `ref` | 字符串 | 是 | 要运行流水线的分支或标签。对于合并请求流水线，请使用[合并请求端点](merge_requests.md#create-merge-request-pipeline)。 |
| `variables` | 数组 | 否 | 包含流水线中可用变量的[哈希数组](rest/_index.md#array-of-hashes)，结构为 `[{ 'key': 'UPLOAD_TO_S3', 'variable_type': 'file', 'value': 'true' }, {'key': 'TEST', 'value': 'test variable'}]`。如果未指定 `variable_type`，则默认为 `env_var`。 |
| `inputs` | 哈希 | 否 | 包含输入的[哈希](rest/_index.md#hash)，以键值对形式提供，用于创建流水线时使用。 |

基本示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipeline?ref=main"
```

使用[输入](../ci/inputs/_index.md)的请求示例：

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

{{< history >}}

- 响应中的 `iid` 在 极狐GitLab 14.6 中引入。

{{< /history >}}

重试流水线中失败或已取消的作业。如果流水线中没有失败或已取消的作业，调用此端点不会产生任何效果。

```plaintext
POST /projects/:id/pipelines/:pipeline_id/retry
```

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

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
> 无论流水线状态如何，此端点都会返回成功响应 `200`。

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

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

删除流水线会使所有流水线缓存失效，并删除所有直接关联的对象，例如构建、日志、产物和触发器。**此操作不可撤销**。

删除流水线不会自动删除其[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。

```plaintext
DELETE /projects/:id/pipelines/:pipeline_id
```

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

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

| 属性 | 类型 | 必填 | 描述 |
|---------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name` | 字符串 | 是 | 流水线的新名称 |
| `pipeline_id` | 整数 | 是 | 流水线的 ID |

请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/46/metadata" \
  --data '{"name": "Some new pipeline name"}'
```

响应示例：

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