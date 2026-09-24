---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 资源组 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[资源组](../ci/resource_groups/_index.md)交互。

<a id="list-all-resource-groups"></a>

## 列出所有资源组

列出指定项目的所有资源组。

```plaintext
GET /projects/:id/resource_groups
```

| 属性       | 类型              | 是否必填 | 描述                                                                                     |
|-----------|-------------------|----------|------------------------------------------------------------------------------------------|
| `id`      | integer or string | yes      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/resource_groups"
```

响应示例

```json
[
  {
    "id": 3,
    "key": "production",
    "process_mode": "unordered",
    "created_at": "2021-09-01T08:04:59.650Z",
    "updated_at": "2021-09-01T08:04:59.650Z"
  }
]
```

<a id="retrieve-a-resource-group"></a>

## 获取一个资源组

获取项目的指定资源组。

```plaintext
GET /projects/:id/resource_groups/:key
```

| 属性   | 类型              | 是否必填 | 描述                                                                                                  |
|-------|-------------------|----------|-------------------------------------------------------------------------------------------------------|
| `id`  | integer or string | yes      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                          |
| `key` | string            | yes      | 资源组的 URL 编码键。例如，使用 `resource%5Fa` 而不是 `resource_a`。                                    |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/resource_groups/production"
```

响应示例

```json
{
  "id": 3,
  "key": "production",
  "process_mode": "unordered",
  "created_at": "2021-09-01T08:04:59.650Z",
  "updated_at": "2021-09-01T08:04:59.650Z"
}
```

<a id="retrieve-current-job-for-a-resource-group"></a>

## 获取资源组的当前作业

{{< history >}}

- 在极狐GitLab 18.6 中引入。

{{< /history >}}

获取项目中指定资源组的当前作业。

```plaintext
GET /projects/:id/resource_groups/:key/current_job
```

| 属性   | 类型              | 是否必填 | 描述                                                                                                  |
|-------|-------------------|----------|-------------------------------------------------------------------------------------------------------|
| `id`  | integer or string | yes      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                          |
| `key` | string            | yes      | 资源组的 URL 编码键。例如，使用 `resource%5Fa` 而不是 `resource_a`。                                    |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/50/resource_groups/production/current_job"
```

响应示例

```json
{
  "id": 1154,
  "status": "waiting_for_resource",
  "stage": "deploy",
  "name": "deploy_to_production",
  "ref": "main",
  "tag": false,
  "coverage": null,
  "allow_failure": false,
  "created_at": "2022-09-28T09:57:04.590Z",
  "started_at": null,
  "finished_at": null,
  "duration": null,
  "queued_duration": null,
  "user": {
    "id": 1,
    "username": "john_smith",
    "name": "John Smith",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/2d691a4d0427ca8db6efc3924a6408ba?s=80\u0026d=identicon",
    "web_url": "http://gitlab.example.com/john_smith",
    "created_at": "2022-05-27T19:19:17.526Z",
    "bio": "",
    "location": null,
    "public_email": null,
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": null,
    "job_title": "",
    "pronouns": null,
    "bot": false,
    "work_information": null,
    "followers": 0,
    "following": 0,
    "local_time": null
  },
  "commit": {
    "id": "3177f39064891bbbf5124b27850c339da331f02f",
    "short_id": "3177f390",
    "created_at": "2022-09-27T17:55:31.000+02:00",
    "parent_ids": [
      "18059e45a16eaaeaddf6fc0daf061481549a89df"
    ],
    "title": "List upcoming jobs",
    "message": "List upcoming jobs",
    "author_name": "Example User",
    "author_email": "user@example.com",
    "authored_date": "2022-09-27T17:55:31.000+02:00",
    "committer_name": "Example User",
    "committer_email": "user@example.com",
    "committed_date": "2022-09-27T17:55:31.000+02:00",
    "trailers": {},
    "web_url": "https://gitlab.example.com/test/gitlab/-/commit/3177f39064891bbbf5124b27850c339da331f02f"
  },
  "pipeline": {
    "id": 274,
    "iid": 9,
    "project_id": 50,
    "sha": "3177f39064891bbbf5124b27850c339da331f02f",
    "ref": "main",
    "status": "waiting_for_resource",
    "source": "web",
    "created_at": "2022-09-28T09:57:04.538Z",
    "updated_at": "2022-09-28T09:57:13.537Z",
    "web_url": "https://gitlab.example.com/test/gitlab/-/pipelines/274"
  },
  "web_url": "https://gitlab.example.com/test/gitlab/-/jobs/1154",
  "project": {
    "ci_job_token_scope_enabled": false
  }
}
```

<a id="list-upcoming-jobs-for-a-specific-resource-group"></a>

## 列出特定资源组的即将到来作业

```plaintext
GET /projects/:id/resource_groups/:key/upcoming_jobs
```

| 属性   | 类型              | 是否必填 | 描述                                                                                                  |
|-------|-------------------|----------|-------------------------------------------------------------------------------------------------------|
| `id`  | integer or string | yes      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                          |
| `key` | string            | yes      | 资源组的 URL 编码键。例如，使用 `resource%5Fa` 而不是 `resource_a`。                                    |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/50/resource_groups/production/upcoming_jobs"
```

响应示例

```json
[
  {
    "id": 1154,
    "status": "waiting_for_resource",
    "stage": "deploy",
    "name": "deploy_to_production",
    "ref": "main",
    "tag": false,
    "coverage": null,
    "allow_failure": false,
    "created_at": "2022-09-28T09:57:04.590Z",
    "started_at": null,
    "finished_at": null,
    "duration": null,
    "queued_duration": null,
    "user": {
      "id": 1,
      "username": "john_smith",
      "name": "John Smith",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/2d691a4d0427ca8db6efc3924a6408ba?s=80\u0026d=identicon",
      "web_url": "http://gitlab.example.com/john_smith",
      "created_at": "2022-05-27T19:19:17.526Z",
      "bio": "",
      "location": null,
      "public_email": null,
      "linkedin": "",
      "twitter": "",
      "website_url": "",
      "organization": null,
      "job_title": "",
      "pronouns": null,
      "bot": false,
      "work_information": null,
      "followers": 0,
      "following": 0,
      "local_time": null
    },
    "commit": {
      "id": "3177f39064891bbbf5124b27850c339da331f02f",
      "short_id": "3177f390",
      "created_at": "2022-09-27T17:55:31.000+02:00",
      "parent_ids": [
        "18059e45a16eaaeaddf6fc0daf061481549a89df"
      ],
      "title": "List upcoming jobs",
      "message": "List upcoming jobs",
      "author_name": "Example User",
      "author_email": "user@example.com",
      "authored_date": "2022-09-27T17:55:31.000+02:00",
      "committer_name": "Example User",
      "committer_email": "user@example.com",
      "committed_date": "2022-09-27T17:55:31.000+02:00",
      "trailers": {},
      "web_url": "https://gitlab.example.com/test/gitlab/-/commit/3177f39064891bbbf5124b27850c339da331f02f"
    },
    "pipeline": {
      "id": 274,
      "iid": 9,
      "project_id": 50,
      "sha": "3177f39064891bbbf5124b27850c339da331f02f",
      "ref": "main",
      "status": "waiting_for_resource",
      "source": "web",
      "created_at": "2022-09-28T09:57:04.538Z",
      "updated_at": "2022-09-28T09:57:13.537Z",
      "web_url": "https://gitlab.example.com/test/gitlab/-/pipelines/274"
    },
    "web_url": "https://gitlab.example.com/test/gitlab/-/jobs/1154",
    "project": {
      "ci_job_token_scope_enabled": false
    }
  }
]
```

<a id="update-a-resource-group"></a>

## 更新一个资源组

更新现有资源组的属性。

如果资源组更新成功，则返回 `200`。如果发生错误，则返回状态码 `400`。

```plaintext
PUT /projects/:id/resource_groups/:key
```

| 属性            | 类型              | 是否必填 | 描述                                                                                                                       |
|----------------|-------------------|----------|----------------------------------------------------------------------------------------------------------------------------|
| `id`           | integer or string | yes      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                                               |
| `key`          | string            | yes      | 资源组的 URL 编码键。例如，使用 `resource%5Fa` 而不是 `resource_a`。                                                         |
| `process_mode` | string            | no       | 资源组的处理模式。可选值为 `unordered`、`oldest_first`、`newest_first` 或 `newest_ready_first`。更多信息请阅读[处理模式](../ci/resource_groups/_index.md#process-modes)。 |

```shell
curl --request PUT \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "process_mode=oldest_first" \
     --url "https://gitlab.example.com/api/v4/projects/1/resource_groups/production"
```

响应示例：

```json
{
  "id": 3,
  "key": "production",
  "process_mode": "oldest_first",
  "created_at": "2021-09-01T08:04:59.650Z",
  "updated_at": "2021-09-01T08:13:38.679Z"
}
```