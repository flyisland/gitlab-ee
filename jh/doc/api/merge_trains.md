---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for merge trains in GitLab.
title: 合并队列 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[合并队列](../ci/pipelines/merge_trains.md)进行交互。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

所有合并队列端点都支持使用 `page` 和 `per_page` 参数的[基于偏移量的分页](rest/_index.md#offset-based-pagination)。

<a id="list-all-merge-trains-for-a-project"></a>

## 列出项目的所有合并队列

列出指定项目的所有合并队列。

```plaintext
GET /projects/:id/merge_trains
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `scope` | 字符串 | 否 | 根据给定的范围过滤返回的合并队列。可用范围是 `active`（待合并）和 `complete`（已合并）。 |
| `sort` | 字符串 | 否 | 返回按 `asc` 或 `desc` 顺序排序的合并队列。默认值：`desc`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at` | datetime | 合并队列的创建时间戳。 |
| `duration` | 整数 | 在合并队列上花费的时间（秒），如果未完成则为 `null`。 |
| `id` | 整数 | 合并队列的 ID。 |
| `merged_at` | datetime | 合并请求合并的时间戳，如果未合并则为 `null`。 |
| `merge_request` | 对象 | 合并请求详情。 |
| `merge_request.created_at` | datetime | 合并请求的创建时间戳。 |
| `merge_request.description` | 字符串 | 合并请求的描述。 |
| `merge_request.id` | 整数 | 合并请求的 ID。 |
| `merge_request.iid` | 整数 | 合并请求的内部 ID。 |
| `merge_request.project_id` | 整数 | 包含合并请求的项目的 ID。 |
| `merge_request.state` | 字符串 | 合并请求的状态。 |
| `merge_request.title` | 字符串 | 合并请求的标题。 |
| `merge_request.updated_at` | datetime | 合并请求最后一次更新的时间戳。 |
| `merge_request.web_url` | 字符串 | 合并请求的 Web URL。 |
| `pipeline` | 对象 | 流水线详情，如果没有关联的流水线则为 `null`。 |
| `pipeline.created_at` | datetime | 流水线的创建时间戳。 |
| `pipeline.id` | 整数 | 流水线的 ID。 |
| `pipeline.iid` | 整数 | 流水线的内部 ID。 |
| `pipeline.project_id` | 整数 | 包含流水线的项目的 ID。 |
| `pipeline.ref` | 字符串 | 流水线的 Git 引用。 |
| `pipeline.sha` | 字符串 | 触发流水线的提交的 SHA。 |
| `pipeline.source` | 字符串 | 流水线触发器的来源。 |
| `pipeline.status` | 字符串 | 流水线的状态。 |
| `pipeline.updated_at` | datetime | 流水线最后一次更新的时间戳。 |
| `pipeline.web_url` | 字符串 | 流水线的 Web URL。 |
| `status` | 字符串 | 合并队列的状态。可能的值：`idle`、`stale`、`fresh`、`merging`、`merged`、`skip_merged`。 |
| `target_branch` | 字符串 | 目标分支的名称。 |
| `updated_at` | datetime | 合并队列最后一次更新的时间戳。 |
| `user` | 对象 | 将合并请求添加到合并队列的用户。 |
| `user.avatar_url` | 字符串 | 用户的头像 URL。 |
| `user.id` | 整数 | 用户的 ID。 |
| `user.name` | 字符串 | 用户的名称。 |
| `user.state` | 字符串 | 用户账户的状态。 |
| `user.username` | 字符串 | 用户的用户名。 |
| `user.web_url` | 字符串 | 用户资料的 Web URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_trains"
```

示例响应：

```json
[
  {
    "id": 110,
    "merge_request": {
      "id": 126,
      "iid": 59,
      "project_id": 20,
      "title": "Test MR 1580978354",
      "description": "",
      "state": "merged",
      "created_at": "2020-02-06T08:39:14.883Z",
      "updated_at": "2020-02-06T08:40:57.038Z",
      "web_url": "http://local.gitlab.test:8181/root/merge-train-race-condition/-/merge_requests/59"
    },
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://local.gitlab.test:8181/root"
    },
    "pipeline": {
      "id": 246,
      "sha": "bcc17a8ffd51be1afe45605e714085df28b80b13",
      "ref": "refs/merge-requests/59/train",
      "status": "success",
      "created_at": "2020-02-06T08:40:42.410Z",
      "updated_at": "2020-02-06T08:40:46.912Z",
      "web_url": "http://local.gitlab.test:8181/root/merge-train-race-condition/pipelines/246"
    },
    "created_at": "2020-02-06T08:39:47.217Z",
    "updated_at": "2020-02-06T08:40:57.720Z",
    "target_branch": "feature-1580973432",
    "status": "merged",
    "merged_at": "2020-02-06T08:40:57.719Z",
    "duration": 70
  }
]
```

<a id="list-all-merge-requests-in-a-merge-train"></a>

## 列出合并队列中的所有合并请求

列出目标分支的合并队列中的所有合并请求。

```plaintext
GET /projects/:id/merge_trains/:target_branch
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------------- | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `target_branch` | 字符串 | 是 | 合并队列的目标分支。 |
| `scope` | 字符串 | 否 | 根据给定的范围过滤返回的合并队列。可用范围是 `active`（待合并）和 `complete`（已合并）。 |
| `sort` | 字符串 | 否 | 返回按 `asc` 或 `desc` 顺序排序的合并队列。默认值：`desc`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at` | datetime | 合并队列的创建时间戳。 |
| `duration` | 整数 | 在合并队列上花费的时间（秒），如果未完成则为 `null`。 |
| `id` | 整数 | 合并队列的 ID。 |
| `merged_at` | datetime | 合并请求合并的时间戳，如果未合并则为 `null`。 |
| `merge_request` | 对象 | 合并请求详情。 |
| `merge_request.created_at` | datetime | 合并请求的创建时间戳。 |
| `merge_request.description` | 字符串 | 合并请求的描述。 |
| `merge_request.id` | 整数 | 合并请求的 ID。 |
| `merge_request.iid` | 整数 | 合并请求的内部 ID。 |
| `merge_request.project_id` | 整数 | 包含合并请求的项目的 ID。 |
| `merge_request.state` | 字符串 | 合并请求的状态。 |
| `merge_request.title` | 字符串 | 合并请求的标题。 |
| `merge_request.updated_at` | datetime | 合并请求最后一次更新的时间戳。 |
| `merge_request.web_url` | 字符串 | 合并请求的 Web URL。 |
| `pipeline` | 对象 | 流水线详情，如果没有关联的流水线则为 `null`。 |
| `pipeline.created_at` | datetime | 流水线的创建时间戳。 |
| `pipeline.id` | 整数 | 流水线的 ID。 |
| `pipeline.iid` | 整数 | 流水线的内部 ID。 |
| `pipeline.project_id` | 整数 | 包含流水线的项目的 ID。 |
| `pipeline.ref` | 字符串 | 流水线的 Git 引用。 |
| `pipeline.sha` | 字符串 | 触发流水线的提交的 SHA。 |
| `pipeline.source` | 字符串 | 流水线触发器的来源。 |
| `pipeline.status` | 字符串 | 流水线的状态。 |
| `pipeline.updated_at` | datetime | 流水线最后一次更新的时间戳。 |
| `pipeline.web_url` | 字符串 | 流水线的 Web URL。 |
| `status` | 字符串 | 合并队列的状态。可能的值：`idle`、`stale`、`fresh`、`merging`、`merged`、`skip_merged`。 |
| `target_branch` | 字符串 | 目标分支的名称。 |
| `updated_at` | datetime | 合并队列最后一次更新的时间戳。 |
| `user` | 对象 | 将合并请求添加到合并队列的用户。 |
| `user.avatar_url` | 字符串 | 用户的头像 URL。 |
| `user.id` | 整数 | 用户的 ID。 |
| `user.name` | 字符串 | 用户的名称。 |
| `user.state` | 字符串 | 用户账户的状态。 |
| `user.username` | 字符串 | 用户的用户名。 |
| `user.web_url` | 字符串 | 用户资料的 Web URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/597/merge_trains/main"
```

示例响应：

```json
[
  {
    "id": 267,
    "merge_request": {
      "id": 273,
      "iid": 1,
      "project_id": 597,
      "title": "My title 9",
      "description": null,
      "state": "opened",
      "created_at": "2022-10-31T19:06:05.725Z",
      "updated_at": "2022-10-31T19:06:05.725Z",
      "web_url": "http://localhost/namespace18/project21/-/merge_requests/1"
    },
    "user": {
      "id": 933,
      "username": "user12",
      "name": "Sidney Jones31",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/6c8365de387cb3db10ecc7b1880203c4?s=80&d=identicon",
      "web_url": "http://localhost/user12"
    },
    "pipeline": {
      "id": 273,
      "iid": 1,
      "project_id": 598,
      "sha": "b83d6e391c22777fca1ed3012fce84f633d7fed0",
      "ref": "main",
      "status": "pending",
      "source": "push",
      "created_at": "2022-10-31T19:06:06.231Z",
      "updated_at": "2022-10-31T19:06:06.231Z",
      "web_url": "http://localhost/namespace19/project22/-/pipelines/273"
    },
    "created_at": "2022-10-31T19:06:06.237Z",
    "updated_at": "2022-10-31T19:06:06.237Z",
    "target_branch": "main",
    "status": "idle",
    "merged_at": null,
    "duration": null
  }
]
```

<a id="retrieve-merge-train-status"></a>

## 获取合并队列状态

获取指定合并请求的合并队列状态。

```plaintext
GET /projects/:id/merge_trains/merge_requests/:merge_request_iid
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| ------------------- | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数 | 是 | 合并请求的内部 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at` | datetime | 合并队列的创建时间戳。 |
| `duration` | 整数 | 在合并队列上花费的时间（秒），如果未完成则为 `null`。 |
| `id` | 整数 | 合并队列的 ID。 |
| `merged_at` | datetime | 合并请求合并的时间戳，如果未合并则为 `null`。 |
| `merge_request` | 对象 | 合并请求详情。 |
| `merge_request.created_at` | datetime | 合并请求的创建时间戳。 |
| `merge_request.description` | 字符串 | 合并请求的描述。 |
| `merge_request.id` | 整数 | 合并请求的 ID。 |
| `merge_request.iid` | 整数 | 合并请求的内部 ID。 |
| `merge_request.project_id` | 整数 | 包含合并请求的项目的 ID。 |
| `merge_request.state` | 字符串 | 合并请求的状态。 |
| `merge_request.title` | 字符串 | 合并请求的标题。 |
| `merge_request.updated_at` | datetime | 合并请求最后一次更新的时间戳。 |
| `merge_request.web_url` | 字符串 | 合并请求的 Web URL。 |
| `pipeline` | 对象 | 流水线详情，如果没有关联的流水线则为 `null`。 |
| `pipeline.created_at` | datetime | 流水线的创建时间戳。 |
| `pipeline.id` | 整数 | 流水线的 ID。 |
| `pipeline.iid` | 整数 | 流水线的内部 ID。 |
| `pipeline.project_id` | 整数 | 包含流水线的项目的 ID。 |
| `pipeline.ref` | 字符串 | 流水线的 Git 引用。 |
| `pipeline.sha` | 字符串 | 触发流水线的提交的 SHA。 |
| `pipeline.source` | 字符串 | 流水线触发器的来源。 |
| `pipeline.status` | 字符串 | 流水线的状态。 |
| `pipeline.updated_at` | datetime | 流水线最后一次更新的时间戳。 |
| `pipeline.web_url` | 字符串 | 流水线的 Web URL。 |
| `status` | 字符串 | 合并队列的状态。可能的值：`idle`、`stale`、`fresh`、`merging`、`merged`、`skip_merged`。 |
| `target_branch` | 字符串 | 目标分支的名称。 |
| `updated_at` | datetime | 合并队列最后一次更新的时间戳。 |
| `user` | 对象 | 将合并请求添加到合并队列的用户。 |
| `user.avatar_url` | 字符串 | 用户的头像 URL。 |
| `user.id` | 整数 | 用户的 ID。 |
| `user.name` | 字符串 | 用户的名称。 |
| `user.state` | 字符串 | 用户账户的状态。 |
| `user.username` | 字符串 | 用户的用户名。 |
| `user.web_url` | 字符串 | 用户资料的 Web URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/597/merge_trains/merge_requests/1"
```

示例响应：

```json
{
  "id": 267,
  "merge_request": {
    "id": 273,
    "iid": 1,
    "project_id": 597,
    "title": "My title 9",
    "description": null,
    "state": "opened",
    "created_at": "2022-10-31T19:06:05.725Z",
    "updated_at": "2022-10-31T19:06:05.725Z",
    "web_url": "http://localhost/namespace18/project21/-/merge_requests/1"
  },
  "user": {
    "id": 933,
    "username": "user12",
    "name": "Sidney Jones31",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/6c8365de387cb3db10ecc7b1880203c4?s=80&d=identicon",
    "web_url": "http://localhost/user12"
  },
  "pipeline": {
    "id": 273,
    "iid": 1,
    "project_id": 598,
    "sha": "b83d6e391c22777fca1ed3012fce84f633d7fed0",
    "ref": "main",
    "status": "pending",
    "source": "push",
    "created_at": "2022-10-31T19:06:06.231Z",
    "updated_at": "2022-10-31T19:06:06.231Z",
    "web_url": "http://localhost/namespace19/project22/-/pipelines/273"
  },
  "created_at": "2022-10-31T19:06:06.237Z",
  "updated_at": "2022-10-31T19:06:06.237Z",
  "target_branch": "main",
  "status": "idle",
  "merged_at": null,
  "duration": null
}
```

<a id="add-a-merge-request-to-a-merge-train"></a>

## 将合并请求添加到合并队列

将指定合并请求添加到合并队列。

```plaintext
POST /projects/:id/merge_trains/merge_requests/:merge_request_iid
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| ------------------------ | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数 | 是 | 合并请求的内部 ID。 |
| `auto_merge` | 布尔值 | 否 | 如果为 true，则当检查通过时，合并请求会被添加到合并队列。当为 false 或未指定时，合并请求直接添加到合并队列。 |
| `sha` | 字符串 | 否 | 如果存在，SHA 必须与源分支的 `HEAD` 匹配，否则合并失败。 |
| `squash` | 布尔值 | 否 | 如果为 true，则在合并时将提交压缩成一个单独的提交。 |
| `when_pipeline_succeeds` | 布尔值 | 否 | 已在极狐GitLab 17.11 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/521290)。请改用 `auto_merge`。 |

如果成功，返回：

- 如果合并请求立即添加到合并队列，则返回 [`201 Created`](rest/troubleshooting.md#status-codes)。
- 如果合并请求计划添加到合并队列，则返回 [`202 Accepted`](rest/troubleshooting.md#status-codes)。

返回以下响应属性：

| 属性 | 类型 | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at` | datetime | 合并队列的创建时间戳。 |
| `duration` | 整数 | 在合并队列上花费的时间（秒），如果未完成则为 `null`。 |
| `id` | 整数 | 合并队列的 ID。 |
| `merged_at` | datetime | 合并请求合并的时间戳，如果未合并则为 `null`。 |
| `merge_request` | 对象 | 合并请求详情。 |
| `merge_request.created_at` | datetime | 合并请求的创建时间戳。 |
| `merge_request.description` | 字符串 | 合并请求的描述。 |
| `merge_request.id` | 整数 | 合并请求的 ID。 |
| `merge_request.iid` | 整数 | 合并请求的内部 ID。 |
| `merge_request.project_id` | 整数 | 包含合并请求的项目的 ID。 |
| `merge_request.state` | 字符串 | 合并请求的状态。 |
| `merge_request.title` | 字符串 | 合并请求的标题。 |
| `merge_request.updated_at` | datetime | 合并请求最后一次更新的时间戳。 |
| `merge_request.web_url` | 字符串 | 合并请求的 Web URL。 |
| `pipeline` | 对象 | 流水线详情，如果没有关联的流水线则为 `null`。 |
| `pipeline.created_at` | datetime | 流水线的创建时间戳。 |
| `pipeline.id` | 整数 | 流水线的 ID。 |
| `pipeline.iid` | 整数 | 流水线的内部 ID。 |
| `pipeline.project_id` | 整数 | 包含流水线的项目的 ID。 |
| `pipeline.ref` | 字符串 | 流水线的 Git 引用。 |
| `pipeline.sha` | 字符串 | 触发流水线的提交的 SHA。 |
| `pipeline.source` | 字符串 | 流水线触发器的来源。 |
| `pipeline.status` | 字符串 | 流水线的状态。 |
| `pipeline.updated_at` | datetime | 流水线最后一次更新的时间戳。 |
| `pipeline.web_url` | 字符串 | 流水线的 Web URL。 |
| `status` | 字符串 | 合并队列的状态。可能的值：`idle`、`stale`、`fresh`、`merging`、`merged`、`skip_merged`。 |
| `target_branch` | 字符串 | 目标分支的名称。 |
| `updated_at` | datetime | 合并队列最后一次更新的时间戳。 |
| `user` | 对象 | 将合并请求添加到合并队列的用户。 |
| `user.avatar_url` | 字符串 | 用户的头像 URL。 |
| `user.id` | 整数 | 用户的 ID。 |
| `user.name` | 字符串 | 用户的名称。 |
| `user.state` | 字符串 | 用户账户的状态。 |
| `user.username` | 字符串 | 用户的用户名。 |
| `user.web_url` | 字符串 | 用户资料的 Web URL。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/597/merge_trains/merge_requests/1"
```

示例响应：

```json
[
  {
    "id": 267,
    "merge_request": {
      "id": 273,
      "iid": 1,
      "project_id": 597,
      "title": "My title 9",
      "description": null,
      "state": "opened",
      "created_at": "2022-10-31T19:06:05.725Z",
      "updated_at": "2022-10-31T19:06:05.725Z",
      "web_url": "http://localhost/namespace18/project21/-/merge_requests/1"
    },
    "user": {
      "id": 933,
      "username": "user12",
      "name": "Sidney Jones31",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/6c8365de387cb3db10ecc7b1880203c4?s=80&d=identicon",
      "web_url": "http://localhost/user12"
    },
    "pipeline": {
      "id": 273,
      "iid": 1,
      "project_id": 598,
      "sha": "b83d6e391c22777fca1ed3012fce84f633d7fed0",
      "ref": "main",
      "status": "pending",
      "source": "push",
      "created_at": "2022-10-31T19:06:06.231Z",
      "updated_at": "2022-10-31T19:06:06.231Z",
      "web_url": "http://localhost/namespace19/project22/-/pipelines/273"
    },
    "created_at": "2022-10-31T19:06:06.237Z",
    "updated_at": "2022-10-31T19:06:06.237Z",
    "target_branch": "main",
    "status": "idle",
    "merged_at": null,
    "duration": null
  }
]
```