---
stage: 安全风险管理
group: 安全策略
info: 要确定与此页面关联的阶段/组的技术文档撰写者，请参见 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中外部状态检查的 REST API 文档。
title: 外部状态检查 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[外部状态检查](../user/project/merge_requests/status_checks.md)。

<a id="retrieve-project-external-status-check-services"></a>

## 获取项目外部状态检查服务

使用以下端点获取项目的外部状态检查服务信息：

```plaintext
GET /projects/:id/external_status_checks
```

**参数**：

| 属性           | 类型    | 是否必需 | 描述         |
|---------------------|---------|----------|---------------------|
| `id`                | integer | 是      | 项目的 ID     |

```json
[
  {
    "id": 1,
    "name": "Compliance Tool",
    "project_id": 6,
    "external_url": "https://gitlab.com/example/compliance-tool",
    "hmac": true,
    "protected_branches": [
      {
        "id": 14,
        "project_id": 6,
        "name": "main",
        "created_at": "2020-10-12T14:04:50.787Z",
        "updated_at": "2020-10-12T14:04:50.787Z",
        "code_owner_approval_required": false
      }
    ]
  }
]
```

<a id="create-external-status-check-service"></a>

## 创建外部状态检查服务

使用以下端点为项目创建新的外部状态检查服务：

```plaintext
POST /projects/:id/external_status_checks
```

> [!warning]
> 外部状态检查会将所有适用的合并请求信息发送到定义的外部服务。这包括机密合并请求。

| 属性              | 类型             | 是否必需 | 描述                                    |
|------------------------|------------------|----------|------------------------------------------------|
| `id`                   | integer          | 是      | 项目的 ID                                |
| `name`                 | string           | 是      | 外部状态检查服务的显示名称  |
| `external_url`         | string           | 是      | 外部状态检查服务的 URL           |
| `shared_secret`        | string           | 否       | 用于外部状态检查的 HMAC 密钥          |
| `protected_branch_ids` | `array<Integer>` | 否       | 要限制规则的受保护分支的 ID |

<a id="update-external-status-check-service"></a>

## 更新外部状态检查服务

使用以下端点更新项目的现有外部状态检查：

```plaintext
PUT /projects/:id/external_status_checks/:check_id
```

| 属性              | 类型             | 是否必需 | 描述                                    |
|------------------------|------------------|----------|------------------------------------------------|
| `id`                   | integer          | 是      | 项目的 ID                                |
| `check_id`             | integer          | 是      | 外部状态检查服务的 ID         |
| `name`                 | string           | 否       | 外部状态检查服务的显示名称  |
| `external_url`         | string           | 否       | 外部状态检查服务的 URL           |
| `shared_secret`        | string           | 否       | 用于外部状态检查的 HMAC 密钥          |
| `protected_branch_ids` | `array<Integer>` | 否       | 要限制规则的受保护分支的 ID |

<a id="delete-external-status-check-service"></a>

## 删除外部状态检查服务

使用以下端点删除项目的外部状态检查服务：

```plaintext
DELETE /projects/:id/external_status_checks/:check_id
```

| 属性              | 类型           | 是否必需 | 描述                            |
|------------------------|----------------|----------|----------------------------------------|
| `check_id`             | integer        | 是      | 外部状态检查服务的 ID |
| `id`                   | integer        | 是      | 项目的 ID                        |

<a id="list-all-status-checks-for-a-merge-request"></a>

## 列出合并请求的所有状态检查

列出适用于单个合并请求的外部状态检查服务及其状态。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/status_checks
```

**参数**：

| 属性                | 类型    | 是否必需 | 描述                |
| ------------------------ | ------- | -------- | -------------------------- |
| `id`                     | integer | 是      | 项目的 ID            |
| `merge_request_iid`      | integer | 是      | 合并请求的 IID     |

```json
[
    {
        "id": 2,
        "name": "Service 1",
        "external_url": "https://gitlab.com/test-endpoint",
        "status": "passed"
    },
    {
        "id": 1,
        "name": "Service 2",
        "external_url": "https://gitlab.com/test-endpoint-2",
        "status": "pending"
    }
]
```

<a id="set-status-of-an-external-status-check"></a>

## 设置外部状态检查的状态

{{< history >}}

- 在极狐GitLab 15.0 中，默认启用了对 `failed` 和 `passed` 的支持。
- 在极狐GitLab 16.5 中，默认启用了对 `pending` 的支持。

{{< /history >}}

设置单个合并请求的外部状态检查状态，通知极狐GitLab 合并请求已通过外部服务的检查。要设置外部检查的状态，所使用的个人访问令牌必须属于在合并请求的目标项目中具有开发者、维护者或所有者角色的用户。

可以以任何有权批准合并请求本身的用户身份执行此 API 调用。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/status_check_responses
```

**参数**：

| 属性                  | 类型    | 是否必需 | 描述                                                                                       |
| -------------------------- | ------- | -------- |---------------------------------------------------------------------------------------------------|
| `id`                       | integer | 是      | 项目的 ID                                                                                   |
| `merge_request_iid`        | integer | 是      | 合并请求的 IID                                                                            |
| `sha`                      | string  | 是      | 源分支 `HEAD` 处的 SHA                                                                |
| `external_status_check_id` | integer | 是      | 外部状态检查的 ID                                                                    |
| `status`                   | string  | 否       | 设置为 `pending` 以将检查标记为待处理，`passed` 以通过检查，或 `failed` 以使其失败 |

> [!note]
> `sha` 必须是合并请求源分支 `HEAD` 处的 SHA。

<a id="retry-failed-status-check-for-a-merge-request"></a>

## 重试合并请求的失败状态检查

{{< history >}}

- 在极狐GitLab 15.7 中引入。

{{< /history >}}

重试单个合并请求的指定失败外部状态检查。即使合并请求未发生变化，此端点也会将合并请求的当前状态重新发送到定义的外部服务。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/status_checks/:external_status_check_id/retry
```

**参数**：

| 属性                  | 类型    | 是否必需 | 描述                           |
| -------------------------- | ------- | -------- | ------------------------------------- |
| `id`                       | integer | 是      | 项目的 ID                       |
| `merge_request_iid`        | integer | 是      | 合并请求的 IID                |
| `external_status_check_id` | integer | 是      | 失败的外部状态检查的 ID |

<a id="response"></a>

## 响应

如果成功，状态码为 202。

```json
{
    "message": "202 Accepted"
}
```

如果状态检查已通过，状态码为 422。

```json
{
    "message": "External status check must be failed"
}
```

<a id="example-payload-sent-to-external-service"></a>

## 发送到外部服务的示例负载

```json
{
  "object_kind": "merge_request",
  "event_type": "merge_request",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "email": "[REDACTED]"
  },
  "project": {
    "id": 6,
    "name": "Flight",
    "description": "Ipsa minima est consequuntur quisquam.",
    "web_url": "http://example.com/flightjs/Flight",
    "avatar_url": null,
    "git_ssh_url": "ssh://example.com/flightjs/Flight.git",
    "git_http_url": "http://example.com/flightjs/Flight.git",
    "namespace": "Flightjs",
    "visibility_level": 20,
    "path_with_namespace": "flightjs/Flight",
    "default_branch": "main",
    "ci_config_path": null,
    "homepage": "http://example.com/flightjs/Flight",
    "url": "ssh://example.com/flightjs/Flight.git",
    "ssh_url": "ssh://example.com/flightjs/Flight.git",
    "http_url": "http://example.com/flightjs/Flight.git"
  },
  "object_attributes": {
    "assignee_id": null,
    "author_id": 1,
    "created_at": "2022-12-07 07:53:43 UTC",
    "description": "",
    "head_pipeline_id": 558,
    "id": 144,
    "iid": 4,
    "last_edited_at": null,
    "last_edited_by_id": null,
    "merge_commit_sha": null,
    "merge_error": null,
    "merge_params": {
      "force_remove_source_branch": "1"
    },
    "merge_status": "can_be_merged",
    "merge_user_id": null,
    "merge_when_pipeline_succeeds": false,
    "milestone_id": null,
    "source_branch": "root-main-patch-30152",
    "source_project_id": 6,
    "state_id": 1,
    "target_branch": "main",
    "target_project_id": 6,
    "time_estimate": 0,
    "title": "Update README.md",
    "updated_at": "2022-12-07 07:53:43 UTC",
    "updated_by_id": null,
    "url": "http://example.com/flightjs/Flight/-/merge_requests/4",
    "source": {
      "id": 6,
      "name": "Flight",
      "description": "Ipsa minima est consequuntur quisquam.",
      "web_url": "http://example.com/flightjs/Flight",
      "avatar_url": null,
      "git_ssh_url": "ssh://example.com/flightjs/Flight.git",
      "git_http_url": "http://example.com/flightjs/Flight.git",
      "namespace": "Flightjs",
      "visibility_level": 20,
      "path_with_namespace": "flightjs/Flight",
      "default_branch": "main",
      "ci_config_path": null,
      "homepage": "http://example.com/flightjs/Flight",
      "url": "ssh://example.com/flightjs/Flight.git",
      "ssh_url": "ssh://example.com/flightjs/Flight.git",
      "http_url": "http://example.com/flightjs/Flight.git"
    },
    "target": {
      "id": 6,
      "name": "Flight",
      "description": "Ipsa minima est consequuntur quisquam.",
      "web_url": "http://example.com/flightjs/Flight",
      "avatar_url": null,
      "git_ssh_url": "ssh://example.com/flightjs/Flight.git",
      "git_http_url": "http://example.com/flightjs/Flight.git",
      "namespace": "Flightjs",
      "visibility_level": 20,
      "path_with_namespace": "flightjs/Flight",
      "default_branch": "main",
      "ci_config_path": null,
      "homepage": "http://example.com/flightjs/Flight",
      "url": "ssh://example.com/flightjs/Flight.git",
      "ssh_url": "ssh://example.com/flightjs/Flight.git",
      "http_url": "http://example.com/flightjs/Flight.git"
    },
    "last_commit": {
      "id": "141be9714669a4c1ccaa013c6a7f3e462ff2a40f",
      "message": "Update README.md",
      "title": "Update README.md",
      "timestamp": "2022-12-07T07:52:11+00:00",
      "url": "http://example.com/flightjs/Flight/-/commit/141be9714669a4c1ccaa013c6a7f3e462ff2a40f",
      "author": {
        "name": "Administrator",
        "email": "admin@example.com"
      }
    },
    "work_in_progress": false,
    "total_time_spent": 0,
    "time_change": 0,
    "human_total_time_spent": null,
    "human_time_change": null,
    "human_time_estimate": null,
    "assignee_ids": [
    ],
    "reviewer_ids": [
    ],
    "labels": [
    ],
    "state": "opened",
    "blocking_discussions_resolved": true,
    "first_contribution": false,
    "detailed_merge_status": "mergeable"
  },
  "labels": [
  ],
  "changes": {
  },
  "repository": {
    "name": "Flight",
    "url": "ssh://example.com/flightjs/Flight.git",
    "description": "Ipsa minima est consequuntur quisquam.",
    "homepage": "http://example.com/flightjs/Flight"
  },
  "external_approval_rule": {
    "id": 1,
    "name": "QA",
    "external_url": "https://example.com/"
  }
}
```