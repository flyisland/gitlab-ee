---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API to retrieve CI/CD job details, retry and cancel jobs, run manual jobs, and access job logs.
title: 作业 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [CI/CD 作业](../ci/jobs/_index.md) 进行交互。

<a id="list-all-jobs-for-a-project"></a>

## 列出项目的所有作业

列出指定项目的所有作业。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[分页显示](rest/_index.md#pagination)。

> [!note]
> 此端点支持基于偏移量和[基于游标（keyset）](rest/_index.md#keyset-based-pagination) 的分页，但在请求连续多页结果时，强烈建议使用基于游标的分页。

```plaintext
GET /projects/:id/jobs
```

| 属性 | 类型 | 是否必填 | 描述 |
| ---------- | ------------------------------ | -------- | ----------- |
| `id`       | integer or string                 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `scope`    | string, or array of strings | 否       | 要显示的作业范围。可以是单个或多个 [作业状态值](#job-status-values)。如果未提供 `scope`，则返回所有作业。 |
| `order_by` | string                         | 否       | 按 `id` 对返回的作业进行排序。 |
| `sort`     | string                         | 否       | 按 `asc` 或 `desc` 顺序排序返回的作业。默认为 `desc`。 |

```shell
curl --globoff \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs?scope[]=pending&scope[]=running"
```

响应示例：

```json
[
  {
    "commit": {
      "author_email": "admin@example.com",
      "author_name": "Administrator",
      "created_at": "2015-12-24T16:51:14.000+01:00",
      "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "message": "Test the CI integration.",
      "short_id": "0ff3ae19",
      "title": "Test the CI integration."
    },
    "coverage": null,
    "archived": false,
    "source": "push",
    "allow_failure": false,
    "created_at": "2015-12-24T15:51:21.802Z",
    "started_at": "2015-12-24T17:54:27.722Z",
    "finished_at": "2015-12-24T17:54:27.895Z",
    "erased_at": null,
    "duration": 0.173,
    "queued_duration": 0.010,
    "artifacts_file": {
      "filename": "artifacts.zip",
      "size": 1000
    },
    "artifacts": [
      {"file_type": "archive", "size": 1000, "filename": "artifacts.zip", "file_format": "zip"},
      {"file_type": "metadata", "size": 186, "filename": "metadata.gz", "file_format": "gzip"},
      {"file_type": "trace", "size": 1500, "filename": "job.log", "file_format": "raw"},
      {"file_type": "junit", "size": 750, "filename": "junit.xml.gz", "file_format": "gzip"}
    ],
    "artifacts_expire_at": "2016-01-23T17:54:27.895Z",
    "tag_list": [
      "docker runner", "ubuntu18"
    ],
    "id": 7,
    "name": "teaspoon",
    "pipeline": {
      "id": 6,
      "project_id": 1,
      "ref": "main",
      "sha": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "status": "pending"
    },
    "ref": "main",
    "runner": {
      "id": 32,
      "description": "",
      "ip_address": null,
      "active": true,
      "paused": false,
      "is_shared": true,
      "runner_type": "instance_type",
      "name": null,
      "online": false,
      "status": "offline"
    },
    "runner_manager": {
      "id": 1,
      "system_id": "s_89e5e9956577",
      "version": "16.11.1",
      "revision": "535ced5f",
      "platform": "linux",
      "architecture": "amd64",
      "created_at": "2024-05-01T10:12:02.507Z",
      "contacted_at": "2024-05-07T06:30:09.355Z",
      "ip_address": "127.0.0.1",
      "status": "offline"
    },
    "stage": "test",
    "status": "failed",
    "failure_reason": "script_failure",
    "tag": false,
    "web_url": "https://example.com/foo/bar/-/jobs/7",
    "project": {
      "ci_job_token_scope_enabled": false
    },
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.dev/root",
      "created_at": "2015-12-21T13:14:24.077Z",
      "bio": null,
      "location": null,
      "public_email": "",
      "linkedin": "",
      "twitter": "",
      "website_url": "",
      "organization": ""
    }
  },
  {
    "commit": {
      "author_email": "admin@example.com",
      "author_name": "Administrator",
      "created_at": "2015-12-24T16:51:14.000+01:00",
      "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "message": "Test the CI integration.",
      "short_id": "0ff3ae19",
      "title": "Test the CI integration."
    },
    "coverage": null,
    "archived": false,
    "source": "push",
    "allow_failure": false,
    "created_at": "2015-12-24T15:51:21.727Z",
    "started_at": "2015-12-24T17:54:24.729Z",
    "finished_at": "2015-12-24T17:54:24.921Z",
    "erased_at": null,
    "duration": 0.192,
    "queued_duration": 0.023,
    "artifacts_expire_at": "2016-01-23T17:54:24.921Z",
    "tag_list": [
      "docker runner", "win10-2004"
    ],
    "id": 6,
    "name": "rspec:other",
    "pipeline": {
      "id": 6,
      "project_id": 1,
      "ref": "main",
      "sha": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "status": "pending"
    },
    "ref": "main",
    "artifacts": [],
    "runner": null,
    "runner_manager": null,
    "stage": "test",
    "status": "failed",
    "failure_reason": "stuck_or_timeout_failure",
    "tag": false,
    "web_url": "https://example.com/foo/bar/-/jobs/6",
    "project": {
      "ci_job_token_scope_enabled": false
    },
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.dev/root",
      "created_at": "2015-12-21T13:14:24.077Z",
      "bio": null,
      "location": null,
      "public_email": "",
      "linkedin": "",
      "twitter": "",
      "website_url": "",
      "organization": ""
    }
  }
]
```

<a id="job-status-values"></a>

### 作业状态值

作业响应中的 `status` 字段以及用于筛选作业的 `scope` 参数使用以下值：

- `canceled`：作业已被手动取消或自动中止。
- `canceling`：作业正在被取消，但 `after_script` 仍在运行。
- `created`：作业已创建，但尚未开始处理。
- `failed`：作业执行失败。
- `manual`：作业需要手动操作才能启动。
- `pending`：作业在队列中等待 Runner。
- `preparing`：Runner 正在准备执行环境。
- `running`：作业正在 Runner 上执行。
- `scheduled`：作业已计划，但尚未开始执行。
- `skipped`：作业因条件或依赖关系被跳过。
- `success`：作业成功完成。
- `waiting_for_callback`：作业正在等待外部服务的回调。
- `waiting_for_resource`：作业正在等待资源可用。

<a id="list-all-jobs-by-pipeline"></a>

## 列出流水线的所有作业

列出指定流水线的所有作业。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[分页显示](rest/_index.md#pagination)。

此端点：

- [返回任意流水线的数据](pipelines.md#retrieve-a-single-pipeline)，包括[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。
- 默认情况下，响应中不会返回重试的作业。
- 按 ID 降序排列作业（最新的在前）。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/jobs
```

| 属性 | 类型 | 是否必填 | 描述 |
| ----------------- | ------------------------------ | -------- | ----------- |
| `id`              | integer or string                 | 是      | ID 或者[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_id`     | integer                        | 是      | 流水线的 ID。也可以使用[预定义 CI 变量](../ci/variables/predefined_variables.md) `CI_PIPELINE_ID` 在 CI 作业中获取。 |
| `include_retried` | boolean                        | 否       | 在响应中包含重试的作业。默认为 `false`。 |
| `scope`           | string **或** array of strings | 否       | 要显示的作业范围。可以是单个或多个 [作业状态值](#job-status-values)。如果未提供 `scope`，则返回所有作业。 |

```shell
curl --globoff \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/6/jobs?scope[]=pending&scope[]=running"
```

响应示例：

```json
[
  {
    "commit": {
      "author_email": "admin@example.com",
      "author_name": "Administrator",
      "created_at": "2015-12-24T16:51:14.000+01:00",
      "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "message": "Test the CI integration.",
      "short_id": "0ff3ae19",
      "title": "Test the CI integration."
    },
    "coverage": null,
    "archived": false,
    "source": "push",
    "allow_failure": false,
    "created_at": "2015-12-24T15:51:21.727Z",
    "started_at": "2015-12-24T17:54:24.729Z",
    "finished_at": "2015-12-24T17:54:24.921Z",
    "erased_at": null,
    "duration": 0.192,
    "queued_duration": 0.023,
    "artifacts_expire_at": "2016-01-23T17:54:24.921Z",
    "tag_list": [
      "docker runner", "ubuntu18"
    ],
    "id": 6,
    "name": "rspec:other",
    "pipeline": {
      "id": 6,
      "project_id": 1,
      "ref": "main",
      "sha": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "status": "pending"
    },
    "ref": "main",
    "artifacts": [],
    "runner": {
      "id": 32,
      "description": "",
      "ip_address": null,
      "active": true,
      "paused": false,
      "is_shared": true,
      "runner_type": "instance_type",
      "name": null,
      "online": false,
      "status": "offline"
    },
    "runner_manager": {
      "id": 1,
      "system_id": "s_89e5e9956577",
      "version": "16.11.1",
      "revision": "535ced5f",
      "platform": "linux",
      "architecture": "amd64",
      "created_at": "2024-05-01T10:12:02.507Z",
      "contacted_at": "2024-05-07T06:30:09.355Z",
      "ip_address": "127.0.0.1",
    },
    "stage": "test",
    "status": "failed",
    "failure_reason": "stuck_or_timeout_failure",
    "tag": false,
    "web_url": "https://example.com/foo/bar/-/jobs/6",
    "project": {
      "ci_job_token_scope_enabled": false
    },
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.dev/root",
      "created_at": "2015-12-21T13:14:24.077Z",
      "bio": null,
      "location": null,
      "public_email": "",
      "linkedin": "",
      "twitter": "",
      "website_url": "",
      "organization": ""
    }
  },
  {
    "commit": {
      "author_email": "admin@example.com",
      "author_name": "Administrator",
      "created_at": "2015-12-24T16:51:14.000+01:00",
      "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "message": "Test the CI integration.",
      "short_id": "0ff3ae19",
      "title": "Test the CI integration."
    },
    "coverage": null,
    "archived": false,
    "source": "push",
    "allow_failure": false,
    "created_at": "2015-12-24T15:51:21.802Z",
    "started_at": "2015-12-24T17:54:27.722Z",
    "finished_at": "2015-12-24T17:54:27.895Z",
    "erased_at": null,
    "duration": 0.173,
    "queued_duration": 0.023,
    "artifacts_file": {
      "filename": "artifacts.zip",
      "size": 1000
    },
    "artifacts": [
      {"file_type": "archive", "size": 1000, "filename": "artifacts.zip", "file_format": "zip"},
      {"file_type": "metadata", "size": 186, "filename": "metadata.gz", "file_format": "gzip"},
      {"file_type": "trace", "size": 1500, "filename": "job.log", "file_format": "raw"},
      {"file_type": "junit", "size": 750, "filename": "junit.xml.gz", "file_format": "gzip"}
    ],
    "artifacts_expire_at": "2016-01-23T17:54:27.895Z",
    "tag_list": [
      "docker runner", "ubuntu18"
    ],
    "id": 7,
    "name": "teaspoon",
    "pipeline": {
      "id": 6,
      "project_id": 1,
      "ref": "main",
      "sha": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "status": "pending"
    },
    "ref": "main",
    "runner": null,
    "runner_manager": null,
    "stage": "test",
    "status": "failed",
    "failure_reason": "script_failure",
    "tag": false,
    "web_url": "https://example.com/foo/bar/-/jobs/7",
    "project": {
      "ci_job_token_scope_enabled": false
    },
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.dev/root",
      "created_at": "2015-12-21T13:14:24.077Z",
      "bio": null,
      "location": null,
      "public_email": "",
      "linkedin": "",
      "twitter": "",
      "website_url": "",
      "organization": ""
    }
  }
]
```

<a id="list-all-trigger-jobs-by-pipeline"></a>

## 列出流水线的所有触发器作业

列出指定流水线的所有触发器作业。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/bridges
```

| 属性 | 类型 | 是否必填 | 描述 |
| ------------- | ------------------------------ | -------- | ----------- |
| `id`          | integer or string                 | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_id` | integer                        | 是      | 流水线的 ID。 |
| `scope`       | string **或** array of strings | 否       | 要显示的作业范围。可以是单个或多个 [作业状态值](#job-status-values)。如果未提供 `scope`，则返回所有作业。 |

```shell
curl --globoff \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/6/bridges?scope[]=pending&scope[]=running"
```

响应示例：

```json
[
  {
    "commit": {
      "author_email": "admin@example.com",
      "author_name": "Administrator",
      "created_at": "2015-12-24T16:51:14.000+01:00",
      "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "message": "Test the CI integration.",
      "short_id": "0ff3ae19",
      "title": "Test the CI integration."
    },
    "coverage": null,
    "archived": false,
    "source": "push",
    "allow_failure": false,
    "created_at": "2015-12-24T15:51:21.802Z",
    "started_at": "2015-12-24T17:54:27.722Z",
    "finished_at": "2015-12-24T17:58:27.895Z",
    "erased_at": null,
    "duration": 240,
    "queued_duration": 0.123,
    "id": 7,
    "name": "teaspoon",
    "pipeline": {
      "id": 6,
      "project_id": 1,
      "ref": "main",
      "sha": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
      "status": "pending",
      "created_at": "2015-12-24T15:50:16.123Z",
      "updated_at": "2015-12-24T18:00:44.432Z",
      "web_url": "https://example.com/foo/bar/pipelines/6"
    },
    "ref": "main",
    "stage": "test",
    "status": "pending",
    "tag": false,
    "web_url": "https://example.com/foo/bar/-/jobs/7",
    "project": {
      "ci_job_token_scope_enabled": false
    },
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.dev/root",
      "created_at": "2015-12-21T13:14:24.077Z",
      "bio": null,
      "location": null,
      "public_email": "",
      "linkedin": "",
      "twitter": "",
      "website_url": "",
      "organization": ""
    },
    "downstream_pipeline": {
      "id": 5,
      "sha": "f62a4b2fb89754372a346f24659212eb8da13601",
      "ref": "main",
      "status": "pending",
      "created_at": "2015-12-24T17:54:27.722Z",
      "updated_at": "2015-12-24T17:58:27.896Z",
      "web_url": "https://example.com/diaspora/diaspora-client/pipelines/5"
    }
  }
]
```

<a id="retrieve-a-job-by-job-token"></a>

## 通过作业令牌获取作业

获取由指定作业令牌生成的作业。

```plaintext
GET /job
```

示例（须作为 [CI/CD 作业](../ci/jobs/_index.md) 的 [`script`](../ci/yaml/_index.md#script) 部分的一部分运行）：

```shell
# 选项 1
curl --header "Authorization: Bearer $CI_JOB_TOKEN" \
  --url "${CI_API_V4_URL}/job"

# 选项 2
curl --header "JOB-TOKEN: $CI_JOB_TOKEN" \
  --url "${CI_API_V4_URL}/job"

# 选项 3
curl --url "${CI_API_V4_URL}/job?job_token=$CI_JOB_TOKEN"
```

响应示例：

```json
{
  "commit": {
    "author_email": "admin@example.com",
    "author_name": "Administrator",
    "created_at": "2015-12-24T16:51:14.000+01:00",
    "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "message": "Test the CI integration.",
    "short_id": "0ff3ae19",
    "title": "Test the CI integration."
  },
  "coverage": null,
  "archived": false,
  "source": "push",
  "allow_failure": false,
  "created_at": "2015-12-24T15:51:21.880Z",
  "started_at": "2015-12-24T17:54:30.733Z",
  "finished_at": "2015-12-24T17:54:31.198Z",
  "erased_at": null,
  "duration": 0.465,
  "queued_duration": 0.123,
  "artifacts_expire_at": "2016-01-23T17:54:31.198Z",
  "id": 8,
  "name": "rubocop",
  "pipeline": {
    "id": 6,
    "project_id": 1,
    "ref": "main",
    "sha": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "status": "pending"
  },
  "ref": "main",
  "artifacts": [],
  "runner": null,
  "runner_manager": null,
  "stage": "test",
  "status": "failed",
  "failure_reason": "script_failure",
  "tag": false,
  "web_url": "https://example.com/foo/bar/-/jobs/8",
  "project": {
    "ci_job_token_scope_enabled": false
  },
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://gitlab.dev/root",
    "created_at": "2015-12-21T13:14:24.077Z",
    "bio": null,
    "location": null,
    "public_email": "",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": ""
  }
}
```

<a id="retrieve-gitlab-agent-for-kubernetes-by-ci-job-token"></a>

## 通过 `CI_JOB_TOKEN` 获取 Kubernetes 的极狐GitLab 代理

获取生成 `CI_JOB_TOKEN` 的作业，以及允许的[代理列表](../user/clusters/agent/_index.md)。

```plaintext
GET /job/allowed_agents
```

支持的属性：

| 属性 | 类型 | 是否必填 | 描述 |
|----------------|--------|----------|-------------|
| `CI_JOB_TOKEN` | string | 是      | 与极狐GitLab 提供的 `CI_JOB_TOKEN` 变量关联的令牌值。 |

示例请求：

```shell
# 选项 1
curl --header "JOB-TOKEN: <CI_JOB_TOKEN>" \
  --url "https://gitlab.example.com/api/v4/job/allowed_agents"

# 选项 2
curl --url "https://gitlab.example.com/api/v4/job/allowed_agents?job_token=<CI_JOB_TOKEN>"
```

响应示例：

```json
{
  "allowed_agents": [
    {
      "id": 1,
      "config_project": {
        "id": 1,
        "description": null,
        "name": "project1",
        "name_with_namespace": "John Doe2 / project1",
        "path": "project1",
        "path_with_namespace": "namespace1/project1",
        "created_at": "2022-11-16T14:51:50.579Z"
      }
    }
  ],
  "job": {
    "id": 1
  },
  "pipeline": {
    "id": 2
  },
  "project": {
    "id": 1,
    "groups": [
      {
        "id": 1
      },
      {
        "id": 2
      },
      {
        "id": 3
      }
    ]
  },
  "user": {
    "id": 2,
    "name": "John Doe3",
    "username": "user2",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/10fc7f102b",
    "web_url": "http://localhost/user2"
  }
}
```

<a id="retrieve-a-job-by-job-id"></a>

## 通过作业 ID 获取作业

获取指定作业 ID 的作业。

```plaintext
GET /projects/:id/jobs/:job_id
```

| 属性 | 类型 | 是否必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer        | 是      | 作业的 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/8"
```

响应示例：

```json
{
  "commit": {
    "author_email": "admin@example.com",
    "author_name": "Administrator",
    "created_at": "2015-12-24T16:51:14.000+01:00",
    "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "message": "Test the CI integration.",
    "short_id": "0ff3ae19",
    "title": "Test the CI integration."
  },
  "coverage": null,
  "archived": false,
  "source": "push",
  "allow_failure": false,
  "created_at": "2015-12-24T15:51:21.880Z",
  "started_at": "2015-12-24T17:54:30.733Z",
  "finished_at": "2015-12-24T17:54:31.198Z",
  "erased_at": null,
  "duration": 0.465,
  "queued_duration": 0.010,
  "artifacts_expire_at": "2016-01-23T17:54:31.198Z",
  "tag_list": [
      "docker runner", "macos-10.15"
    ],
  "id": 8,
  "name": "rubocop",
  "pipeline": {
    "id": 6,
    "project_id": 1,
    "ref": "main",
    "sha": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "status": "pending"
  },
  "ref": "main",
  "artifacts": [],
  "runner": null,
  "runner_manager": null,
  "stage": "test",
  "status": "failed",
  "tag": false,
  "web_url": "https://example.com/foo/bar/-/jobs/8",
  "project": {
    "ci_job_token_scope_enabled": false
  },
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://gitlab.dev/root",
    "created_at": "2015-12-21T13:14:24.077Z",
    "bio": null,
    "location": null,
    "public_email": "",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": ""
  }
}
```

<a id="retrieve-a-log-file-for-a-job"></a>

## 获取作业的日志文件

获取指定作业 ID 的作业日志（跟踪信息）。

```plaintext
GET /projects/:id/jobs/:job_id/trace
```

| 属性 | 类型 | 是否必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer        | 是      | 作业的 ID。 |

```shell
curl --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/8/trace"
```

可能的响应状态码：

| 状态码 | 描述 |
|--------|-------------|
| 200    | 提供日志文件 |
| 404    | 未找到作业或无日志文件 |

<a id="cancel-a-job"></a>

## 取消作业

取消项目的单个作业。

```plaintext
POST /projects/:id/jobs/:job_id/cancel
```

| 属性 | 类型 | 是否必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer        | 是      | 作业的 ID。 |
| `force`   | boolean        | 否       | 设置为 `true` 时，[强制取消](../ci/jobs/_index.md#force-cancel-a-job) 处于 `canceling` 状态的作业。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/cancel"
```

响应示例：

```json
{
  "commit": {
    "author_email": "admin@example.com",
    "author_name": "Administrator",
    "created_at": "2015-12-24T16:51:14.000+01:00",
    "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "message": "Test the CI integration.",
    "short_id": "0ff3ae19",
    "title": "Test the CI integration."
  },
  "coverage": null,
  "archived": false,
  "source": "push",
  "allow_failure": false,
  "created_at": "2016-01-11T10:13:33.506Z",
  "started_at": "2016-01-11T10:14:09.526Z",
  "finished_at": null,
  "erased_at": null,
  "duration": 8,
  "queued_duration": 0.010,
  "id": 1,
  "name": "rubocop",
  "ref": "main",
  "artifacts": [],
  "runner": null,
  "runner_manager": null,
  "stage": "test",
  "status": "canceled",
  "tag": false,
  "web_url": "https://example.com/foo/bar/-/jobs/1",
  "project": {
    "ci_job_token_scope_enabled": false
  },
  "user": null
}
```

<a id="retry-a-job"></a>

## 重试作业

{{< history >}}

- `job_inputs` 属性于极狐GitLab 18.10 引入。

{{< /history >}}

重试项目的单个作业。

```plaintext
POST /projects/:id/jobs/:job_id/retry
```
| 属性    | 类型              | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | integer or string | 是      | 项目 ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`     | integer           | 是      | 作业 ID。 |
| `job_inputs` | hash              | 否       | 重试作业时要使用的 [作业输入](../ci/jobs/job_inputs.md) 值的哈希。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/retry"
```

响应示例：

```json
{
  "commit": {
    "author_email": "admin@example.com",
    "author_name": "Administrator",
    "created_at": "2015-12-24T16:51:14.000+01:00",
    "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "message": "Test the CI integration.",
    "short_id": "0ff3ae19",
    "title": "Test the CI integration."
  },
  "coverage": null,
  "archived": false,
  "source": "push",
  "allow_failure": false,
  "created_at": "2016-01-11T10:13:33.506Z",
  "started_at": null,
  "finished_at": null,
  "erased_at": null,
  "duration": null,
  "queued_duration": 0.010,
  "id": 1,
  "name": "rubocop",
  "ref": "main",
  "artifacts": [],
  "runner": null,
  "runner_manager": null,
  "stage": "test",
  "status": "pending",
  "tag": false,
  "web_url": "https://example.com/foo/bar/-/jobs/1",
  "project": {
    "ci_job_token_scope_enabled": false
  },
  "user": null
}
```

> [!note]
> 在极狐GitLab 17.0 之前，此端点不支持触发器作业。

## 清除作业

清除项目的单个作业（删除作业产物和作业日志）

```plaintext
POST /projects/:id/jobs/:job_id/erase
```

参数

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目 ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer        | 是      | 作业 ID。 |

请求示例

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/erase"
```

响应示例：

```json
{
  "commit": {
    "author_email": "admin@example.com",
    "author_name": "Administrator",
    "created_at": "2015-12-24T16:51:14.000+01:00",
    "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "message": "Test the CI integration.",
    "short_id": "0ff3ae19",
    "title": "Test the CI integration."
  },
  "coverage": null,
  "archived": false,
  "source": "push",
  "allow_failure": false,
  "download_url": null,
  "id": 1,
  "name": "rubocop",
  "ref": "main",
  "artifacts": [],
  "runner": null,
  "runner_manager": null,
  "stage": "test",
  "created_at": "2016-01-11T10:13:33.506Z",
  "started_at": "2016-01-11T10:13:33.506Z",
  "finished_at": "2016-01-11T10:15:10.506Z",
  "erased_at": "2016-01-11T11:30:19.914Z",
  "duration": 97.0,
  "queued_duration": 0.010,
  "status": "failed",
  "tag": false,
  "web_url": "https://example.com/foo/bar/-/jobs/1",
  "project": {
    "ci_job_token_scope_enabled": false
  },
  "user": null
}
```

> [!note]
> 无法使用 API 删除归档作业，但可以
> [删除在特定日期之前完成的作业的作业产物和日志](../administration/cicd/job_artifacts_troubleshooting.md#delete-old-builds-and-artifacts)

## 启动作业

{{< history >}}

- `job_inputs` 属性在极狐GitLab 18.10 中引入。

{{< /history >}}

对于状态为手动的作业，触发一个动作来启动作业。

```plaintext
POST /projects/:id/jobs/:job_id/play
```

| 属性                  | 类型              | 是否必需 | 描述 |
|----------------------------|-------------------|----------|-------------|
| `id`                       | integer or string | 是      | 项目 ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`                   | integer           | 是      | 作业 ID。 |
| `job_inputs`               | hash              | 否       | 启动作业时要使用的 [作业输入](../ci/jobs/job_inputs.md) 值的哈希。 |
| `job_variables_attributes` | array of hashes   | 否       | 包含可供作业使用的自定义变量的数组。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data @variables.json \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/play"
```

`@variables.json` 的结构如下：

```json
{
  "job_variables_attributes": [
    {
      "key": "TEST_VAR_1",
      "value": "test1"
    },
    {
      "key": "TEST_VAR_2",
      "value": "test2"
    }
  ]
}
```

响应示例：

```json
{
  "commit": {
    "author_email": "admin@example.com",
    "author_name": "Administrator",
    "created_at": "2015-12-24T16:51:14.000+01:00",
    "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "message": "Test the CI integration.",
    "short_id": "0ff3ae19",
    "title": "Test the CI integration."
  },
  "coverage": null,
  "archived": false,
  "source": "push",
  "allow_failure": false,
  "created_at": "2016-01-11T10:13:33.506Z",
  "started_at": null,
  "finished_at": null,
  "erased_at": null,
  "duration": null,
  "queued_duration": 0.010,
  "id": 1,
  "name": "rubocop",
  "ref": "main",
  "artifacts": [],
  "runner": null,
  "runner_manager": null,
  "stage": "test",
  "status": "pending",
  "tag": false,
  "web_url": "https://example.com/foo/bar/-/jobs/1",
  "project": {
    "ci_job_token_scope_enabled": false
  },
  "user": null
}
```