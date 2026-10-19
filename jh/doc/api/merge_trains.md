---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中用于合并列车的 REST API 文档。
title: 合并列车 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[合并列车](../ci/pipelines/merge_trains.md)交互。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

所有合并列车端点都支持使用 `page` 和 `per_page` 参数的[基于偏移量的分页](rest/_index.md#offset-based-pagination)。

一个合并列车可以包含多个合并请求。API 响应中的每个对象代表合并列车中的一个合并请求，而不是整个合并列车。

如果您调用 `GET /projects/:id/merge_trains` 时未指定目标分支，响应可能包含项目中多个合并列车的条目。

REST API 响应不包含每个合并请求的明确队列位置，并且以扁平列表而非按合并列车分组的方式返回合并请求：

- 如需确切的队列位置，请按 `id` 升序排序，或使用 GraphQL API 的
  [`MergeTrainCar.index`](graphql/reference/_index.md#mergetraincar-index) 字段。
- 如需按合并列车对合并请求分组，请使用 `target_branch` 属性，或查询 GraphQL API 的
  [`Project.mergeTrains`](graphql/reference/_index.md#projectmergetrains) 和
  [`MergeTrain.cars`](graphql/reference/_index.md#mergetraincars) 字段。

<a id="list-all-merge-trains-for-a-project"></a>

## 列出项目的所有合并列车

列出指定项目的所有合并列车。

```plaintext
GET /projects/:id/merge_trains
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `scope`   | string            | 否       | 返回按给定范围筛选的合并列车。可用范围为 `active`（待合并）和 `complete`（已合并）。 |
| `sort`    | string            | 否       | 返回按 `id` 以 `asc` 或 `desc` 顺序排序的合并请求。默认值：`desc`。`id` 越小，表示该合并请求加入合并列车的时间越早。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                   | 类型     | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at`                | datetime | 合并列车创建时的时间戳。 |
| `duration`                  | integer  | 在合并列车上花费的时间（秒），如果未完成则为 `null`。 |
| `id`                        | integer  | 合并列车的 ID。 |
| `merged_at`                 | datetime | 合并请求合并时的时间戳，如果未合并则为 `null`。 |
| `merge_request`             | object   | 合并请求详情。 |
| `merge_request.created_at`  | datetime | 合并请求创建时的时间戳。 |
| `merge_request.description` | string   | 合并请求的描述。 |
| `merge_request.id`          | integer  | 合并请求的 ID。 |
| `merge_request.iid`         | integer  | 合并请求的内部 ID。 |
| `merge_request.project_id`  | integer  | 包含该合并请求的项目的 ID。 |
| `merge_request.state`       | string   | 合并请求的状态。 |
| `merge_request.title`       | string   | 合并请求的标题。 |
| `merge_request.updated_at`  | datetime | 合并请求上次更新时的时间戳。 |
| `merge_request.web_url`     | string   | 合并请求的 Web URL。 |
| `pipeline`                  | object   | 流水线详情，如果未关联流水线则为 `null`。 |
| `pipeline.created_at`       | datetime | 流水线创建时的时间戳。 |
| `pipeline.id`               | integer  | 流水线的 ID。 |
| `pipeline.iid`              | integer  | 流水线的内部 ID。 |
| `pipeline.project_id`       | integer  | 包含该流水线的项目的 ID。 |
| `pipeline.ref`              | string   | 流水线的 Git 引用。 |
| `pipeline.sha`              | string   | 触发流水线的提交的 SHA。 |
| `pipeline.source`           | string   | 流水线触发来源。 |
| `pipeline.status`           | string   | 流水线的状态。 |
| `pipeline.updated_at`       | datetime | 流水线上次更新时的时间戳。 |
| `pipeline.web_url`          | string   | 流水线的 Web URL。 |
| `status`                    | string   | 合并请求在合并列车上的状态。活动合并列车的可能值：`idle`、`fresh` 或 `stale`。已完成合并列车的可能值：`merging`、`merged` 或 `skip_merged`。 |
| `target_branch`             | string   | 目标分支的名称。 |
| `updated_at`                | datetime | 合并列车上次更新时的时间戳。 |
| `user`                      | object   | 将该合并请求添加到合并列车的用户。 |
| `user.avatar_url`           | string   | 用户的头像 URL。 |
| `user.id`                   | integer  | 用户的 ID。 |
| `user.name`                 | string   | 用户的名称。 |
| `user.state`                | string   | 用户账号的状态。 |
| `user.username`             | string   | 用户的用户名。 |
| `user.web_url`              | string   | 用户个人资料的 Web URL。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

## 列出合并列车中的所有合并请求

列出目标分支的合并列车中的所有合并请求。

响应中的每个对象代表 `target_branch` 合并列车中的一个合并请求。响应使用与[列出所有合并列车](#list-all-merge-trains-for-a-project)端点相同的对象类型。

```plaintext
GET /projects/:id/merge_trains/:target_branch
```

支持的属性：

| 属性       | 类型              | 是否必需 | 描述 |
| --------------- | ----------------- | -------- | ----------- |
| `id`            | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `target_branch` | string            | 是      | 合并列车的目标分支。 |
| `scope`         | string            | 否       | 返回按给定范围筛选的合并列车。可用范围为 `active`（待合并）和 `complete`（已合并）。 |
| `sort`          | string            | 否       | 返回按 `id` 以 `asc` 或 `desc` 顺序排序的合并请求。默认值：`desc`。`id` 越小，表示该合并请求加入合并列车的时间越早。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                   | 类型     | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at`                | datetime | 合并列车创建时的时间戳。 |
| `duration`                  | integer  | 在合并列车上花费的时间（秒），如果未完成则为 `null`。 |
| `id`                        | integer  | 合并列车的 ID。 |
| `merged_at`                 | datetime | 合并请求合并时的时间戳，如果未合并则为 `null`。 |
| `merge_request`             | object   | 合并请求详情。 |
| `merge_request.created_at`  | datetime | 合并请求创建时的时间戳。 |
| `merge_request.description` | string   | 合并请求的描述。 |
| `merge_request.id`          | integer  | 合并请求的 ID。 |
| `merge_request.iid`         | integer  | 合并请求的内部 ID。 |
| `merge_request.project_id`  | integer  | 包含该合并请求的项目的 ID。 |
| `merge_request.state`       | string   | 合并请求的状态。 |
| `merge_request.title`       | string   | 合并请求的标题。 |
| `merge_request.updated_at`  | datetime | 合并请求上次更新时的时间戳。 |
| `merge_request.web_url`     | string   | 合并请求的 Web URL。 |
| `pipeline`                  | object   | 流水线详情，如果未关联流水线则为 `null`。 |
| `pipeline.created_at`       | datetime | 流水线创建时的时间戳。 |
| `pipeline.id`               | integer  | 流水线的 ID。 |
| `pipeline.iid`              | integer  | 流水线的内部 ID。 |
| `pipeline.project_id`       | integer  | 包含该流水线的项目的 ID。 |
| `pipeline.ref`              | string   | 流水线的 Git 引用。 |
| `pipeline.sha`              | string   | 触发流水线的提交的 SHA。 |
| `pipeline.source`           | string   | 流水线触发来源。 |
| `pipeline.status`           | string   | 流水线的状态。 |
| `pipeline.updated_at`       | datetime | 流水线上次更新时的时间戳。 |
| `pipeline.web_url`          | string   | 流水线的 Web URL。 |
| `status`                    | string   | 合并请求在合并列车上的状态。活动合并列车的可能值：`idle`、`fresh` 或 `stale`。已完成合并列车的可能值：`merging`、`merged` 或 `skip_merged`。 |
| `target_branch`             | string   | 目标分支的名称。 |
| `updated_at`                | datetime | 合并列车上次更新时的时间戳。 |
| `user`                      | object   | 将该合并请求添加到合并列车的用户。 |
| `user.avatar_url`           | string   | 用户的头像 URL。 |
| `user.id`                   | integer  | 用户的 ID。 |
| `user.name`                 | string   | 用户的名称。 |
| `user.state`                | string   | 用户账号的状态。 |
| `user.username`             | string   | 用户的用户名。 |
| `user.web_url`              | string   | 用户个人资料的 Web URL。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

## 检索合并列车状态

检索指定合并请求的合并列车状态。

```plaintext
GET /projects/:id/merge_trains/merge_requests/:merge_request_iid
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
| ------------------- | ----------------- | -------- | ----------- |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的内部 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                   | 类型     | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at`                | datetime | 合并列车创建时的时间戳。 |
| `duration`                  | integer  | 在合并列车上花费的时间（秒），如果未完成则为 `null`。 |
| `id`                        | integer  | 合并列车的 ID。 |
| `merged_at`                 | datetime | 合并请求合并时的时间戳，如果未合并则为 `null`。 |
| `merge_request`             | object   | 合并请求详情。 |
| `merge_request.created_at`  | datetime | 合并请求创建时的时间戳。 |
| `merge_request.description` | string   | 合并请求的描述。 |
| `merge_request.id`          | integer  | 合并请求的 ID。 |
| `merge_request.iid`         | integer  | 合并请求的内部 ID。 |
| `merge_request.project_id`  | integer  | 包含该合并请求的项目的 ID。 |
| `merge_request.state`       | string   | 合并请求的状态。 |
| `merge_request.title`       | string   | 合并请求的标题。 |
| `merge_request.updated_at`  | datetime | 合并请求上次更新时的时间戳。 |
| `merge_request.web_url`     | string   | 合并请求的 Web URL。 |
| `pipeline`                  | object   | 流水线详情，如果未关联流水线则为 `null`。 |
| `pipeline.created_at`       | datetime | 流水线创建时的时间戳。 |
| `pipeline.id`               | integer  | 流水线的 ID。 |
| `pipeline.iid`              | integer  | 流水线的内部 ID。 |
| `pipeline.project_id`       | integer  | 包含该流水线的项目的 ID。 |
| `pipeline.ref`              | string   | 流水线的 Git 引用。 |
| `pipeline.sha`              | string   | 触发流水线的提交的 SHA。 |
| `pipeline.source`           | string   | 流水线触发来源。 |
| `pipeline.status`           | string   | 流水线的状态。 |
| `pipeline.updated_at`       | datetime | 流水线上次更新时的时间戳。 |
| `pipeline.web_url`          | string   | 流水线的 Web URL。 |
| `status`                    | string   | 合并请求在合并列车上的状态。活动合并列车的可能值：`idle`、`fresh` 或 `stale`。已完成合并列车的可能值：`merging`、`merged` 或 `skip_merged`。 |
| `target_branch`             | string   | 目标分支的名称。 |
| `updated_at`                | datetime | 合并列车上次更新时的时间戳。 |
| `user`                      | object   | 将该合并请求添加到合并列车的用户。 |
| `user.avatar_url`           | string   | 用户的头像 URL。 |
| `user.id`                   | integer  | 用户的 ID。 |
| `user.name`                 | string   | 用户的名称。 |
| `user.state`                | string   | 用户账号的状态。 |
| `user.username`             | string   | 用户的用户名。 |
| `user.web_url`              | string   | 用户个人资料的 Web URL。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

## 将合并请求添加到合并列车

将指定的合并请求添加到合并列车。

```plaintext
POST /projects/:id/merge_trains/merge_requests/:merge_request_iid
```

支持的属性：

| 属性                | 类型              | 是否必需 | 描述 |
| ------------------------ | ----------------- | -------- | ----------- |
| `id`                     | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid`      | integer           | 是      | 合并请求的内部 ID。 |
| `auto_merge`             | boolean           | 否       | 如果为 true，则在检查通过后将该合并请求添加到合并列车。如果为 false 或未指定，则将该合并请求直接添加到合并列车。 |
| `sha`                    | string            | 否       | 如果存在，SHA 必须与源分支的 `HEAD` 匹配，否则合并失败。 |
| `squash`                 | boolean           | 否       | 如果为 true，则在合并时将提交压缩为单个提交。 |
| `when_pipeline_succeeds` | boolean           | 否       | 在极狐GitLab 17.11 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/521290)。请改用 `auto_merge`。 |

如果成功，返回：

- [`201 Created`](rest/troubleshooting.md#status-codes)，如果该合并请求立即添加到合并列车。
- [`202 Accepted`](rest/troubleshooting.md#status-codes)，如果该合并请求计划添加到合并列车。

返回以下响应属性：

| 属性                   | 类型     | 描述 |
| --------------------------- | -------- | ----------- |
| `created_at`                | datetime | 合并列车创建时的时间戳。 |
| `duration`                  | integer  | 在合并列车上花费的时间（秒），如果未完成则为 `null`。 |
| `id`                        | integer  | 合并列车的 ID。 |
| `merged_at`                 | datetime | 合并请求合并时的时间戳，如果未合并则为 `null`。 |
| `merge_request`             | object   | 合并请求详情。 |
| `merge_request.created_at`  | datetime | 合并请求创建时的时间戳。 |
| `merge_request.description` | string   | 合并请求的描述。 |
| `merge_request.id`          | integer  | 合并请求的 ID。 |
| `merge_request.iid`         | integer  | 合并请求的内部 ID。 |
| `merge_request.project_id`  | integer  | 包含该合并请求的项目的 ID。 |
| `merge_request.state`       | string   | 合并请求的状态。 |
| `merge_request.title`       | string   | 合并请求的标题。 |
| `merge_request.updated_at`  | datetime | 合并请求上次更新时的时间戳。 |
| `merge_request.web_url`     | string   | 合并请求的 Web URL。 |
| `pipeline`                  | object   | 流水线详情，如果未关联流水线则为 `null`。 |
| `pipeline.created_at`       | datetime | 流水线创建时的时间戳。 |
| `pipeline.id`               | integer  | 流水线的 ID。 |
| `pipeline.iid`              | integer  | 流水线的内部 ID。 |
| `pipeline.project_id`       | integer  | 包含该流水线的项目的 ID。 |
| `pipeline.ref`              | string   | 流水线的 Git 引用。 |
| `pipeline.sha`              | string   | 触发流水线的提交的 SHA。 |
| `pipeline.source`           | string   | 流水线触发来源。 |
| `pipeline.status`           | string   | 流水线的状态。 |
| `pipeline.updated_at`       | datetime | 流水线上次更新时的时间戳。 |
| `pipeline.web_url`          | string   | 流水线的 Web URL。 |
| `status`                    | string   | 合并请求在合并列车上的状态。活动合并列车的可能值：`idle`、`fresh` 或 `stale`。已完成合并列车的可能值：`merging`、`merged` 或 `skip_merged`。 |
| `target_branch`             | string   | 目标分支的名称。 |
| `updated_at`                | datetime | 合并列车上次更新时的时间戳。 |
| `user`                      | object   | 将该合并请求添加到合并列车的用户。 |
| `user.avatar_url`           | string   | 用户的头像 URL。 |
| `user.id`                   | integer  | 用户的 ID。 |
| `user.name`                 | string   | 用户的名称。 |
| `user.state`                | string   | 用户账号的状态。 |
| `user.username`             | string   | 用户的用户名。 |
| `user.web_url`              | string   | 用户个人资料的 Web URL。 |

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

<a id="remove-a-merge-request-from-a-merge-train"></a>

## 从合并列车中移除合并请求

要从合并列车中移除合并请求，请使用合并请求 API 中的[取消自动合并](merge_requests.md#cancel-auto-merge)端点。
