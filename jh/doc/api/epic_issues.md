---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the Epic Issues API to list, link, and unlink issues with epics.
title: 史诗议题 API（已弃用）
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!警告]
> 史诗 REST API 已在极狐GitLab 17.0 中被[弃用](https://jihulab.com/gitlab-cn/gitlab/-/issues/460668)，
> 计划在 API v5 中移除。
> 从极狐GitLab 17.4 到 18.0，如果启用了[史诗的新外观](../user/group/epics/_index.md#epics-as-work-items)，并且在极狐GitLab 18.1 及之后版本，请使用
> Work Items API 代替。更多信息，请参阅[将史诗 API 迁移到工作项](graphql/epic_work_items_api_migration_guide.md)。
> 此变更是一个破坏性变更。

所有史诗议题 API 端点的调用都必须通过身份验证。

如果用户不是某群组成员且该群组是私有的，则对该群组执行的 `GET` 请求将返回 `404` 状态码。

史诗仅适用于极狐GitLab [专业版和旗舰版](https://about.gitlab.com/pricing/)。
如果史诗功能不可用，则返回 `403` 状态码。

<a id="list-all-issues-for-an-epic"></a>

## 列出史诗的所有议题

列出分配给某个史诗的所有议题。

响应采用[分页](rest/_index.md#pagination)形式，默认每页返回 20 条结果。

```plaintext
GET /groups/:id/epics/:epic_iid/issues
```

| 属性                | 类型              | 是否必需   | 描述                                                                                     |
| ------------------- | ---------------- | ---------- | --------------------------------------------------------------------------------------- |
| `id`                | integer 或 string | yes        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                               |
| `epic_iid`          | integer 或 string | yes        | 史诗的内部 ID。                                                                         |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/issues"
```

示例响应：

```json
[
  {
    "id": 76,
    "iid": 6,
    "project_id": 8,
    "title" : "Consequatur vero maxime deserunt laboriosam est voluptas dolorem.",
    "description" : "Ratione dolores corrupti mollitia soluta quia.",
    "state": "opened",
    "created_at": "2017-11-15T13:39:24.670Z",
    "updated_at": "2018-01-04T10:49:19.506Z",
    "closed_at": null,
    "labels": [],
    "milestone": {
      "id": 38,
      "iid": 3,
      "project_id": 8,
      "title": "v2.0",
      "description": "In tempore culpa inventore quo accusantium.",
      "state": "closed",
      "created_at": "2017-11-15T13:39:13.825Z",
      "updated_at": "2017-11-15T13:39:13.825Z",
      "due_date": null,
      "start_date": null
    },
    "assignees": [{
      "id": 7,
      "name": "Pamella Huel",
      "username": "arnita",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
      "web_url": "http://localhost:3001/arnita"
    }],
    "assignee": {
      "id": 7,
      "name": "Pamella Huel",
      "username": "arnita",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
      "web_url": "http://localhost:3001/arnita"
    },
    "author": {
      "id": 13,
      "name": "Michell Johns",
      "username": "chris_hahn",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/30e3b2122ccd6b8e45e8e14a3ffb58fc?s=80&d=identicon",
      "web_url": "http://localhost:3001/chris_hahn"
    },
    "user_notes_count": 8,
    "upvotes": 0,
    "downvotes": 0,
    "due_date": null,
    "confidential": false,
    "weight": null,
    "discussion_locked": null,
    "web_url": "http://localhost:3001/h5bp/html5-boilerplate/issues/6",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "_links":{
      "self": "http://localhost:3001/api/v4/projects/8/issues/6",
      "notes": "http://localhost:3001/api/v4/projects/8/issues/6/notes",
      "award_emoji": "http://localhost:3001/api/v4/projects/8/issues/6/award_emoji",
      "project": "http://localhost:3001/api/v4/projects/8"
    },
    "epic_issue_id": 2
  }
]
```

> [!注意]
> `assignee` 字段已被弃用，现在使用单元素数组 `assignees` 代替。

<a id="assign-an-issue-to-an-epic"></a>

## 将议题分配给史诗

将某个议题分配给指定的史诗。如果该议题已属于另一个史诗，则会先从原史诗中移除。

```plaintext
POST /groups/:id/epics/:epic_iid/issues/:issue_id
```

| 属性                | 类型              | 是否必需   | 描述                                                                                     |
| ------------------- | ---------------- | ---------- | --------------------------------------------------------------------------------------- |
| `id`                | integer 或 string | yes        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                               |
| `epic_iid`          | integer 或 string | yes        | 史诗的内部 ID。                                                                         |
| `issue_id`          | integer 或 string | yes        | 议题的 ID。                                                                             |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/issues/55"
```

示例响应：

```json
{
  "id": 11,
  "epic": {
    "id": 30,
    "iid": 5,
    "title": "Ea cupiditate dolores ut vero consequatur quasi veniam voluptatem et non.",
    "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
    "author": {
      "id": 7,
      "name": "Pamella Huel",
      "username": "arnita",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
      "web_url": "http://localhost:3001/arnita"
    },
    "start_date": null,
    "end_date": null
  },
  "issue": {
    "id": 55,
    "iid": 13,
    "project_id": 8,
    "title": "Beatae laborum voluptatem voluptate eligendi ex accusamus.",
    "description": "Quam veritatis debitis omnis aliquam sit.",
    "state": "opened",
    "created_at": "2017-11-05T13:59:12.782Z",
    "updated_at": "2018-01-05T10:33:03.900Z",
    "closed_at": null,
    "labels": [],
    "milestone": {
      "id": 48,
      "iid": 6,
      "project_id": 8,
      "title": "Sprint - Sed sed maxime temporibus ipsa ullam qui sit.",
      "description": "Quos veritatis qui expedita sunt deleniti accusamus.",
      "state": "active",
      "created_at": "2017-11-05T13:59:12.445Z",
      "updated_at": "2017-11-05T13:59:12.445Z",
      "due_date": "2017-11-13",
      "start_date": "2017-11-05"
    },
    "assignees": [{
      "id": 10,
      "name": "Lu Mayer",
      "username": "kam",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
      "web_url": "http://localhost:3001/kam"
    }],
    "assignee": {
      "id": 10,
      "name": "Lu Mayer",
      "username": "kam",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
      "web_url": "http://localhost:3001/kam"
    },
    "author": {
      "id": 25,
      "name": "User 3",
      "username": "user3",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/97d6d9441ff85fdc730e02a6068d267b?s=80&d=identicon",
      "web_url": "http://localhost:3001/user3"
    },
    "user_notes_count": 0,
    "upvotes": 0,
    "downvotes": 0,
    "due_date": null,
    "confidential": false,
    "weight": null,
    "discussion_locked": null,
    "web_url": "http://localhost:3001/h5bp/html5-boilerplate/issues/13",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
}
```

> [!注意]
> `assignee` 字段已被弃用，现在使用单元素数组 `assignees` 代替。

<a id="remove-an-issue-from-an-epic"></a>

## 从史诗中移除议题

从指定的史诗中移除某个议题。

```plaintext
DELETE /groups/:id/epics/:epic_iid/issues/:epic_issue_id
```

| 属性                | 类型              | 是否必需   | 描述                                                                                          |
| ------------------- | ---------------- | ---------- | -----------------------------------------------------------------------------------------------------|
| `id`                | integer 或 string | yes        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                               |
| `epic_iid`          | integer 或 string | yes        | 史诗的内部 ID。                                                                         |
| `epic_issue_id`     | integer 或 string | yes        | 史诗-议题关联的 ID。                                                                     |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/issues/11"
```

示例响应：

```json
{
  "id": 11,
  "epic": {
    "id": 30,
    "iid": 5,
    "title": "Ea cupiditate dolores ut vero consequatur quasi veniam voluptatem et non.",
    "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
    "author": {
      "id": 7,
      "name": "Pamella Huel",
      "username": "arnita",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
      "web_url": "http://localhost:3001/arnita"
    },
    "start_date": null,
    "end_date": null
  },
  "issue": {
    "id": 223,
    "iid": 13,
    "project_id": 8,
    "title": "Beatae laborum voluptatem voluptate eligendi ex accusamus.",
    "description": "Quam veritatis debitis omnis aliquam sit.",
    "state": "opened",
    "created_at": "2017-11-05T13:59:12.782Z",
    "updated_at": "2018-01-05T10:33:03.900Z",
    "closed_at": null,
    "labels": [],
    "milestone": {
      "id": 48,
      "iid": 6,
      "project_id": 8,
      "title": "Sprint - Sed sed maxime temporibus ipsa ullam qui sit.",
      "description": "Quos veritatis qui expedita sunt deleniti accusamus.",
      "state": "active",
      "created_at": "2017-11-05T13:59:12.445Z",
      "updated_at": "2017-11-05T13:59:12.445Z",
      "due_date": "2017-11-13",
      "start_date": "2017-11-05"
    },
    "assignees": [{
      "id": 10,
      "name": "Lu Mayer",
      "username": "kam",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
      "web_url": "http://localhost:3001/kam"
    }],
    "assignee": {
      "id": 10,
      "name": "Lu Mayer",
      "username": "kam",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
      "web_url": "http://localhost:3001/kam"
    },
    "author": {
      "id": 25,
      "name": "User 3",
      "username": "user3",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/97d6d9441ff85fdc730e02a6068d267b?s=80&d=identicon",
      "web_url": "http://localhost:3001/user3"
    },
    "user_notes_count": 0,
    "upvotes": 0,
    "downvotes": 0,
    "due_date": null,
    "confidential": false,
    "weight": null,
    "discussion_locked": null,
    "web_url": "http://localhost:3001/h5bp/html5-boilerplate/issues/13",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
}
```

> [!注意]
> `assignee` 字段已被弃用，现在使用单元素数组 `assignees` 代替。

<a id="update-an-epic-issue-association"></a>

## 更新史诗-议题关联

更新史诗与议题的关联。

```plaintext
PUT /groups/:id/epics/:epic_iid/issues/:epic_issue_id
```

| 属性                | 类型              | 是否必需   | 描述                                                                                          |
| ------------------- | ---------------- | ---------- | -----------------------------------------------------------------------------------------------------|
| `id`                | integer 或 string | yes        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                               |
| `epic_iid`          | integer 或 string | yes        | 史诗的内部 ID。                                                                         |
| `epic_issue_id`     | integer 或 string | yes        | 史诗-议题关联的 ID。                                                                     |
| `move_before_id`    | integer 或 string | no         | 应放置在问题中当前链接之前的史诗-议题关联的 ID。                                              |
| `move_after_id`     | integer 或 string | no         | 应放置在问题中当前链接之后的史诗-议题关联的 ID。                                              |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/issues/11?move_before_id=20"
```

示例响应：

```json
[
  {
    "id": 30,
    "iid": 6,
    "project_id": 8,
    "title" : "Consequatur vero maxime deserunt laboriosam est voluptas dolorem.",
    "description" : "Ratione dolores corrupti mollitia soluta quia.",
    "state": "opened",
    "created_at": "2017-11-15T13:39:24.670Z",
    "updated_at": "2018-01-04T10:49:19.506Z",
    "closed_at": null,
    "labels": [],
    "milestone": {
      "id": 38,
      "iid": 3,
      "project_id": 8,
      "title": "v2.0",
      "description": "In tempore culpa inventore quo accusantium.",
      "state": "closed",
      "created_at": "2017-11-15T13:39:13.825Z",
      "updated_at": "2017-11-15T13:39:13.825Z",
      "due_date": null,
      "start_date": null
    },
    "assignees": [{
      "id": 7,
      "name": "Pamella Huel",
      "username": "arnita",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
      "web_url": "http://localhost:3001/arnita"
    }],
    "assignee": {
      "id": 7,
      "name": "Pamella Huel",
      "username": "arnita",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
      "web_url": "http://localhost:3001/arnita"
    },
    "author": {
      "id": 13,
      "name": "Michell Johns",
      "username": "chris_hahn",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/30e3b2122ccd6b8e45e8e14a3ffb58fc?s=80&d=identicon",
      "web_url": "http://localhost:3001/chris_hahn"
    },
    "user_notes_count": 8,
    "upvotes": 0,
    "downvotes": 0,
    "due_date": null,
    "confidential": false,
    "weight": null,
    "discussion_locked": null,
    "web_url": "http://localhost:3001/h5bp/html5-boilerplate/issues/6",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "_links":{
      "self": "http://localhost:3001/api/v4/projects/8/issues/6",
      "notes": "http://localhost:3001/api/v4/projects/8/issues/6/notes",
      "award_emoji": "http://localhost:3001/api/v4/projects/8/issues/6/award_emoji",
      "project": "http://localhost:3001/api/v4/projects/8"
    },
    "subscribed": true,
    "epic_issue_id": 11,
    "relative_position": 55
  }
]
```