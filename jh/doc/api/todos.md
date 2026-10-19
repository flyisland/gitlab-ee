---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 待办事项列表 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [待办事项](../user/todos.md) 交互。

<a id="list-all-to-do-items"></a>

## 列表所有待办事项

列表所有待办事项。当未应用过滤时，会返回当前用户的所有未完成待办事项。不同的过滤器允许用户细化请求。

```plaintext
GET /todos
```

参数：

| 属性 | 类型 | 是否必填 | 描述 |
| --------- | ---- | -------- | ----------- |
| `action` | string | 否 | 要过滤的动作。可以是 `已分配`、`被提及`、`构建失败`、`已标记`、`需审批`、`不可合并`、`直接处理`、`合并队列已移除` 或 `成员访问请求`。 |
| `author_id` | integer | 否 | 作者的 ID |
| `project_id` | integer | 否 | 项目的 ID |
| `group_id` | integer | 否 | 群组的 ID |
| `state` | string | 否 | 待办事项的状态。可以是 `待处理` 或 `已完成` |
| `type` | string | 否 | 待办事项的类型。可以是 `议题`、`合并请求`、`提交`、`史诗`、`设计管理::设计`、`告警管理::告警`、`项目`、`命名空间`、`漏洞` 或 `Wiki页面::元数据` |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/todos"
```

示例响应：

```json
[
  {
    "id": 102,
    "project": {
      "id": 2,
      "name": "极狐GitLab 基础版",
      "name_with_namespace": "极狐GitLab 组织 / 极狐GitLab 基础版",
      "path": "gitlab-foss",
      "path_with_namespace": "gitlab-org/gitlab-foss"
    },
    "author": {
      "name": "Administrator",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/root"
    },
    "action_name": "已标记",
    "target_type": "合并请求",
    "target": {
      "id": 34,
      "iid": 7,
      "project_id": 2,
      "title": "这是一个示例合并请求标题。",
      "description": "这是一个示例描述。",
      "state": "opened",
      "created_at": "2016-06-17T07:49:24.419Z",
      "updated_at": "2016-06-17T07:52:43.484Z",
      "target_branch": "tutorials_git_tricks",
      "source_branch": "DNSBL_docs",
      "upvotes": 0,
      "downvotes": 0,
      "author": {
        "name": "Maxie Medhurst",
        "username": "craig_rutherford",
        "id": 12,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/a0d477b3ea21970ce6ffcbb817b0b435?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/craig_rutherford"
      },
      "assignee": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/root"
      },
      "source_project_id": 2,
      "target_project_id": 2,
      "labels": [],
      "draft": false,
      "work_in_progress": false,
      "milestone": {
        "id": 32,
        "iid": 2,
        "project_id": 2,
        "title": "v1.0",
        "description": "这是一个示例里程碑描述。",
        "state": "active",
        "created_at": "2016-06-17T07:47:34.163Z",
        "updated_at": "2016-06-17T07:47:34.163Z",
        "due_date": null
      },
      "merge_when_pipeline_succeeds": false,
      "merge_status": "cannot_be_merged",
      "user_notes_count": 7
    },
    "target_url": "https://gitlab.example.com/gitlab-org/gitlab-foss/-/merge_requests/7",
    "body": "这是一个示例正文。",
    "state": "待处理",
    "created_at": "2016-06-17T07:52:35.225Z",
    "updated_at": "2016-06-17T07:52:35.225Z"
  },
  {
    "id": 98,
    "project": {
      "id": 2,
      "name": "极狐GitLab 基础版",
      "name_with_namespace": "极狐GitLab 组织 / 极狐GitLab 基础版",
      "path": "gitlab-foss",
      "path_with_namespace": "gitlab-org/gitlab-foss"
    },
    "author": {
      "name": "Maxie Medhurst",
      "username": "craig_rutherford",
      "id": 12,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a0d477b3ea21970ce6ffcbb817b0b435?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/craig_rutherford"
    },
    "action_name": "已分配",
    "target_type": "合并请求",
    "target": {
      "id": 34,
      "iid": 7,
      "project_id": 2,
      "title": "这是一个示例合并请求标题。",
      "description": "这是一个示例描述。",
      "state": "opened",
      "created_at": "2016-06-17T07:49:24.419Z",
      "updated_at": "2016-06-17T07:52:43.484Z",
      "target_branch": "tutorials_git_tricks",
      "source_branch": "DNSBL_docs",
      "upvotes": 0,
      "downvotes": 0,
      "author": {
        "name": "Maxie Medhurst",
        "username": "craig_rutherford",
        "id": 12,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/a0d477b3ea21970ce6ffcbb817b0b435?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/craig_rutherford"
      },
      "assignee": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/root"
      },
      "source_project_id": 2,
      "target_project_id": 2,
      "labels": [],
      "draft": false,
      "work_in_progress": false,
      "milestone": {
        "id": 32,
        "iid": 2,
        "project_id": 2,
        "title": "v1.0",
        "description": "这是一个示例里程碑描述。",
        "state": "active",
        "created_at": "2016-06-17T07:47:34.163Z",
        "updated_at": "2016-06-17T07:47:34.163Z",
        "due_date": null
      },
      "merge_when_pipeline_succeeds": false,
      "merge_status": "cannot_be_merged",
      "user_notes_count": 7
    },
    "target_url": "https://gitlab.example.com/gitlab-org/gitlab-foss/-/merge_requests/7",
    "body": "这是一个示例正文。",
    "state": "待处理",
    "created_at": "2016-06-17T07:49:24.624Z",
    "updated_at": "2016-06-17T07:49:24.624Z"
  }
]
```

<a id="mark-a-to-do-item-as-done"></a>

## 将待办事项标记为完成

将当前用户的单个未完成待办事项（由其 ID 确定）标记为完成。响应中返回已标记为完成的待办事项。

```plaintext
POST /todos/:id/mark_as_done
```

参数：

| 属性 | 类型 | 是否必填 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 待办事项的 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/todos/130/mark_as_done"
```

示例响应：

```json
{
    "id": 102,
    "project": {
      "id": 2,
      "name": "极狐GitLab 基础版",
      "name_with_namespace": "极狐GitLab 组织 / 极狐GitLab 基础版",
      "path": "gitlab-foss",
      "path_with_namespace": "gitlab-org/gitlab-foss"
    },
    "author": {
      "name": "Administrator",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/root"
    },
    "action_name": "已标记",
    "target_type": "合并请求",
    "target": {
      "id": 34,
      "iid": 7,
      "project_id": 2,
      "title": "这是一个示例合并请求标题。",
      "description": "这是一个示例描述。",
      "state": "opened",
      "created_at": "2016-06-17T07:49:24.419Z",
      "updated_at": "2016-06-17T07:52:43.484Z",
      "target_branch": "tutorials_git_tricks",
      "source_branch": "DNSBL_docs",
      "upvotes": 0,
      "downvotes": 0,
      "author": {
        "name": "Maxie Medhurst",
        "username": "craig_rutherford",
        "id": 12,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/a0d477b3ea21970ce6ffcbb817b0b435?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/craig_rutherford"
      },
      "assignee": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/root"
      },
      "source_project_id": 2,
      "target_project_id": 2,
      "labels": [],
      "draft": false,
      "work_in_progress": false,
      "milestone": {
        "id": 32,
        "iid": 2,
        "project_id": 2,
        "title": "v1.0",
        "description": "这是一个示例里程碑描述。",
        "state": "active",
        "created_at": "2016-06-17T07:47:34.163Z",
        "updated_at": "2016-06-17T07:47:34.163Z",
        "due_date": null
      },
      "merge_when_pipeline_succeeds": false,
      "merge_status": "cannot_be_merged",
      "subscribed": true,
      "user_notes_count": 7
    },
    "target_url": "https://gitlab.example.com/gitlab-org/gitlab-foss/-/merge_requests/7",
    "body": "这是一个示例正文。",
    "state": "已完成",
    "created_at": "2016-06-17T07:52:35.225Z",
    "updated_at": "2016-06-17T07:52:35.225Z"
}
```

<a id="mark-all-to-do-items-as-done"></a>

## 将所有待办事项标记为完成

将当前用户的所有未完成待办事项标记为完成。返回 HTTP 状态码 `204` 并附带空响应。

```plaintext
POST /todos/mark_as_done
```

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/todos/mark_as_done"
```