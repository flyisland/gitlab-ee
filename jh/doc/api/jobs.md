---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于检索 CI/CD 作业详情、重试和取消作业、运行手动作业以及访问作业日志的 REST API。
title: 作业 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [CI/CD 作业](../ci/jobs/_index.md)交互。

<a id="list-all-jobs-for-a-project"></a>

## 列出项目的所有作业

列出指定项目的所有作业。

默认情况下，此请求每次返回 20 条结果，因为 API 结果[已分页](rest/_index.md#pagination)

> [!note]
> 此端点同时支持基于偏移量和[基于键集](rest/_index.md#keyset-based-pagination)的分页，但在请求连续结果页时，
> 强烈建议使用基于键集的分页。
> 作业按 ID 降序返回。

```plaintext
GET /projects/:id/jobs
```

| 属性  | 类型                           | 是否必需 | 描述 |
| ---------- | ------------------------------ | -------- | ----------- |
| `id`       | integer or string                 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `scope`    | string, or array of strings | 否       | 要显示的作业范围。可以是[作业状态值](#job-status-values)之一，也可以是作业状态值的数组。如果未提供 `scope`，则返回所有作业。 |

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

- `canceled`：作业被手动取消或自动中止。
- `canceling`：作业正在取消，但 `after_script` 仍在运行。
- `created`：作业已创建但尚未处理。
- `failed`：作业执行失败。
- `manual`：作业需要手动操作才能启动。
- `pending`：作业在队列中等待 Runner。
- `preparing`：Runner 正在准备执行环境。
- `running`：作业正在 Runner 上执行。
- `scheduled`：作业已排定，但尚未开始执行。
- `skipped`：作业因条件或依赖关系而被跳过。
- `success`：作业已成功完成。
- `waiting_for_callback`：作业正在等待外部服务的回调。
- `waiting_for_resource`：作业正在等待资源可用。

<a id="list-all-jobs-by-pipeline"></a>

## 按流水线列出所有作业

列出指定流水线的所有作业。

默认情况下，此请求每次返回 20 条结果，因为 API 结果[已分页](rest/_index.md#pagination)

此端点：

- [返回任何流水线的数据](pipelines.md#retrieve-a-single-pipeline)，包括[子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。
- 默认情况下，响应中不返回重试的作业。
- 按 ID 降序排列作业（最新的在前）。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/jobs
```

| 属性         | 类型                           | 是否必需 | 描述 |
| ----------------- | ------------------------------ | -------- | ----------- |
| `id`              | integer or string                 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_id`     | integer                        | 是      | 流水线的 ID。也可以在 CI 作业中使用[预定义 CI 变量](../ci/variables/predefined_variables.md) `CI_PIPELINE_ID` 获取。 |
| `include_retried` | boolean                        | 否       | 在响应中包含重试的作业。默认为 `false`。 |
| `scope`           | string or array of strings | 否       | 要显示的作业范围。可以是[作业状态值](#job-status-values)之一，也可以是作业状态值的数组。如果未提供 `scope`，则返回所有作业。 |

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

## 按流水线列出所有触发作业

列出指定流水线的所有触发作业。

```plaintext
GET /projects/:id/pipelines/:pipeline_id/trigger_jobs
```

| 属性     | 类型                           | 是否必需 | 描述 |
| ------------- | ------------------------------ | -------- | ----------- |
| `id`          | integer or string                 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `pipeline_id` | integer                        | 是      | 流水线的 ID。 |
| `scope`       | string or array of strings | 否       | 要显示的作业范围。可以是[作业状态值](#job-status-values)之一，也可以是作业状态值的数组。如果未提供 `scope`，则返回所有作业。 |

```shell
curl --globoff \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/pipelines/6/trigger_jobs?scope[]=pending&scope[]=running"
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

## 按作业令牌检索作业

检索由指定作业令牌生成的作业。

```plaintext
GET /job
```

示例（必须作为 [CI/CD 作业](../ci/jobs/_index.md)的 [`script`](../ci/yaml/_index.md#script) 部分运行）：

```shell
# Option 1
curl --header "Authorization: Bearer $CI_JOB_TOKEN" \
  --url "${CI_API_V4_URL}/job"

# Option 2
curl --header "JOB-TOKEN: $CI_JOB_TOKEN" \
  --url "${CI_API_V4_URL}/job"

# Option 3
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

<a id="retrieve-gitlab-agent-for-kubernetes-by-ci_job_token"></a>

## 按 `CI_JOB_TOKEN` 检索极狐GitLab Kubernetes Agent

检索生成 `CI_JOB_TOKEN`的作业，以及允许的[代理](../user/clusters/agent/_index.md)列表。

```plaintext
GET /job/allowed_agents
```

支持的属性：

| 属性      | 类型   | 是否必需 | 描述 |
|----------------|--------|----------|-------------|
| `CI_JOB_TOKEN` | string | 是      | 与极狐GitLab 提供的 `CI_JOB_TOKEN` 变量关联的令牌值。 |

请求示例：

```shell
# Option 1
curl --header "JOB-TOKEN: <CI_JOB_TOKEN>" \
  --url "https://gitlab.example.com/api/v4/job/allowed_agents"

# Option 2
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

## 按作业 ID 检索作业

检索具有指定作业 ID 的作业。

```plaintext
GET /projects/:id/jobs/:job_id
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
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

## 检索作业的日志文件

检索指定作业 ID 的作业日志（跟踪）。

```plaintext
GET /projects/:id/jobs/:job_id/trace
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
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
| 404    | 未找到作业或没有日志文件 |

<a id="cancel-a-job"></a>

## 取消作业

取消项目的单个作业。

```plaintext
POST /projects/:id/jobs/:job_id/cancel
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer        | 是      | 作业的 ID。 |
| `force`   | boolean        | 否       | 设置为 `true` 时，[强制取消](../ci/jobs/_index.md#force-cancel-a-job)处于 `canceling` 状态的作业。 |

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

重试项目的单个作业

```plaintext
POST /projects/:id/jobs/:job_id/retry
```

如果您超过[作业重试速率限制](../administration/cicd/limits.md#job-retry-and-manual-job-run-rate-limits)，此端点会返回 `429 Too Many Requests` 状态码，并带有 `Retry-After` 响应头。

| 属性    | 类型              | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`     | integer           | 是      | 作业的 ID。 |
| `job_inputs` | hash              | 否       | 重试作业时要使用的[作业输入](../ci/jobs/job_inputs.md)值的哈希。 |

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
> 在极狐GitLab 17.0 之前，此端点不支持触发作业。

<a id="erase-a-job"></a>

## 擦除作业

擦除项目的单个作业（移除作业产物和作业日志）

```plaintext
POST /projects/:id/jobs/:job_id/erase
```

参数

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer        | 是      | 作业的 ID。 |

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
> 您无法使用 API 删除已归档的作业，但可以
> [删除在特定日期之前完成的作业的作业产物和日志](../administration/cicd/job_artifacts_troubleshooting.md#delete-old-builds-and-artifacts)

<a id="run-a-job"></a>

## 运行作业

对于处于手动状态的作业，触发操作以启动作业。

```plaintext
POST /projects/:id/jobs/:job_id/play
```

如果您超过[手动作业运行速率限制](../administration/cicd/limits.md#job-retry-and-manual-job-run-rate-limits)，此端点会返回 `429 Too Many Requests` 状态码，并带有 `Retry-After` 响应头。

| 属性                  | 类型              | 是否必需 | 描述 |
|----------------------------|-------------------|----------|-------------|
| `id`                       | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`                   | integer           | 是      | 作业的 ID。 |
| `job_inputs`               | hash              | 否       | 运行作业时要使用的[作业输入](../ci/jobs/job_inputs.md)值的哈希。 |
| `job_variables_attributes` | array of hashes   | 否       | 包含作业可用的自定义变量的数组。 |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data @variables.json \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/play"
```

`@variables.json`的结构如下：

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
