---
stage: Facilitated functionality
group: Facilitated functionality
info: For more information, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
title: 事件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 查看事件活动。事件可以包含多种操作，例如加入项目、对议题发表评论、将变更推送到合并请求，或关闭史诗。

有关活动保留限制的信息，请参阅：

- [用户活动时间期限](../user/profile/contributions_calendar.md#event-time-period-limit)
- [项目活动时间期限](../user/project/working_with_projects.md#view-project-activity)

此 API 在史诗、合并请求和批量推送事件方面存在一些限制：

- API 不会返回某些史诗功能，例如子项、链接项、开始日期、截止日期和健康状态。
- 某些合并请求评论可能改用 `DiscussionNote` 类型。
  此目标类型
  [不受 API 支持](discussions.md#understand-note-types-in-the-api)。
- 当推送超过
  [推送事件活动数限制](../administration/settings/push_event_activities_limit.md)
  时创建的批量推送事件，返回的详细信息有限：`commit_count: 0`、`ref_count` 显示
  推送的引用数量，而各个提交属性
  （`commit_from`、`commit_to`、`ref`、`commit_title`）的值为 `null`。

<a id="list-all-events"></a>

## 列出所有事件

列出已认证用户的所有事件。不返回与史诗或合并请求关联的事件。返回的批量推送事件仅包含有限的提交详细信息。

先决条件：

- 您的访问令牌必须具有 `read_user` 或 `api` 范围。

```plaintext
GET /events
```

参数：

| 参数     | 类型            | 是否必需 | 描述 |
| ------------- | --------------- | -------- | ----------- |
| `action`      | string          | 否       | 如果定义，则返回具有指定[操作类型](../user/profile/contributions_calendar.md#user-contribution-events)的事件。 |
| `target_type` | string          | 否       | 如果定义，则返回指定的事件。可能的值：`design`、`issue`、`merge_request`、`milestone`、`note`、`project`、`snippet`、`user` 和 `wiki`。 |
| `before`      | date (ISO 8601) | 否       | 如果定义，则返回在指定日期之前创建的事件。 |
| `after`       | date (ISO 8601) | 否       | 如果定义，则返回在指定日期之后创建的事件。 |
| `scope`       | string          | 否       | 包含用户所有项目中的全部事件。 |
| `sort`        | string          | 否       | 按创建日期对结果排序的方向。可能的值：`asc`、`desc`。默认值：`desc`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/events?target_type=issue&action=created&after=2017-01-31&before=2017-03-01&scope=all"
```

示例响应：

```json
[
  {
    "id": 1,
    "title": null,
    "project_id": 1,
    "action_name": "opened",
    "target_id": 160,
    "target_iid": 53,
    "target_type": "Issue",
    "author_id": 25,
    "target_title": "Qui natus eos odio tempore et quaerat consequuntur ducimus cupiditate quis.",
    "created_at": "2017-02-09T10:43:19.667Z",
    "author": {
      "name": "User 3",
      "username": "user3",
      "id": 25,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/97d6d9441ff85fdc730e02a6068d267b?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/user3"
    },
    "author_username": "user3",
    "imported": false,
    "imported_from": "none"
  },
  {
    "id": 2,
    "title": null,
    "project_id": 1,
    "action_name": "opened",
    "target_id": 159,
    "target_iid": 14,
    "target_type": "Issue",
    "author_id": 21,
    "target_title": "Nostrum enim non et sed optio illo deleniti non.",
    "created_at": "2017-02-09T10:43:19.426Z",
    "author": {
      "name": "Test User",
      "username": "ted",
      "id": 21,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/80fb888c9a48b9a3f87477214acaa63f?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/ted"
    },
    "author_username": "ted",
    "imported": false,
    "imported_from": "none"
  }
]
```

关于 Wiki 页面的事件会带有 `wiki_page` 对象。其他任何目标的事件则不会。要仅返回这些事件，请按 `target_type=wiki` 筛选。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/events?target_type=wiki&action=created"
```

示例响应：

```json
[
  {
    "id": 3,
    "title": null,
    "project_id": 1,
    "action_name": "created",
    "target_id": 123,
    "target_iid": null,
    "target_type": "WikiPage::Meta",
    "author_id": 25,
    "target_title": "Deploy",
    "created_at": "2017-02-09T10:44:02.113Z",
    "author": {
      "name": "User 3",
      "username": "user3",
      "id": 25,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/97d6d9441ff85fdc730e02a6068d267b?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/user3"
    },
    "wiki_page": {
      "format": "markdown",
      "slug": "deploy",
      "title": "Deploy",
      "wiki_page_meta_id": 123
    },
    "author_username": "user3",
    "imported": false,
    "imported_from": "none"
  }
]
```

<a id="retrieve-contribution-events-for-a-user"></a>

## 检索用户的贡献事件

检索指定用户的贡献事件。不返回与史诗或合并请求关联的事件。返回的批量推送事件仅包含有限的提交详细信息。

先决条件：

- 您的访问令牌必须具有 `read_user` 或 `api` 范围。

```plaintext
GET /users/:id/events
```

参数：

| 参数     | 类型            | 是否必需 | 描述 |
| ------------- | --------------- | -------- | ----------- |
| `id`          | integer         | 是      | 用户的 ID 或用户名。 |
| `action`      | string          | 否       | 如果定义，则返回具有指定[操作类型](../user/profile/contributions_calendar.md#user-contribution-events)的事件。 |
| `target_type` | string          | 否       | 如果定义，则返回指定的事件。可能的值：`design`、`issue`、`merge_request`、`milestone`、`note`、`project`、`snippet`、`user` 和 `wiki`。 |
| `before`      | date (ISO 8601) | 否       | 如果定义，则返回在指定日期之前创建的事件。 |
| `after`       | date (ISO 8601) | 否       | 如果定义，则返回在指定日期之后创建的事件。 |
| `sort`        | string          | 否       | 按创建日期对结果排序的方向。可能的值：`asc`、`desc`。默认值：`desc`。 |
| `page`        | integer         | 否       | 返回指定的结果页。默认值：`1`。 |
| `per_page`    | integer         | 否       | 每页的结果数。默认值：`20`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/:id/events"
```

示例响应：

```json
[
  {
    "id": 3,
    "title": null,
    "project_id": 15,
    "action_name": "closed",
    "target_id": 830,
    "target_iid": 82,
    "target_type": "Issue",
    "author_id": 1,
    "target_title": "Public project search field",
    "author": {
      "name": "Dmitriy Zaporozhets",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://localhost:3000/uploads/user/avatar/1/fox_avatar.png",
      "web_url": "http://localhost:3000/root"
    },
    "author_username": "root",
    "imported": false,
    "imported_from": "none"
  },
  {
    "id": 4,
    "title": null,
    "project_id": 15,
    "action_name": "pushed",
    "target_id": null,
    "target_iid": null,
    "target_type": null,
    "author_id": 1,
    "author": {
      "name": "Dmitriy Zaporozhets",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://localhost:3000/uploads/user/avatar/1/fox_avatar.png",
      "web_url": "http://localhost:3000/root"
    },
    "author_username": "john",
    "imported": false,
    "imported_from": "none",
    "push_data": {
      "commit_count": 1,
      "action": "pushed",
      "ref_type": "branch",
      "commit_from": "50d4420237a9de7be1304607147aec22e4a14af7",
      "commit_to": "c5feabde2d8cd023215af4d2ceeb7a64839fc428",
      "ref": "main",
      "commit_title": "Add simple search to projects in public area"
    },
    "target_title": null
  },
  {
    "id": 5,
    "title": null,
    "project_id": 15,
    "action_name": "closed",
    "target_id": 840,
    "target_iid": 11,
    "target_type": "Issue",
    "author_id": 1,
    "target_title": "Finish & merge Code search PR",
    "author": {
      "name": "Dmitriy Zaporozhets",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://localhost:3000/uploads/user/avatar/1/fox_avatar.png",
      "web_url": "http://localhost:3000/root"
    },
    "author_username": "root",
    "imported": false,
    "imported_from": "none"
  },
  {
    "id": 7,
    "title": null,
    "project_id": 15,
    "action_name": "commented on",
    "target_id": 1312,
    "target_iid": 61,
    "target_type": "Note",
    "author_id": 1,
    "target_title": null,
    "created_at": "2015-12-04T10:33:58.089Z",
    "note": {
      "id": 1312,
      "body": "What an awesome day!",
      "attachment": null,
      "author": {
        "name": "Dmitriy Zaporozhets",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://localhost:3000/uploads/user/avatar/1/fox_avatar.png",
        "web_url": "http://localhost:3000/root"
      },
      "created_at": "2015-12-04T10:33:56.698Z",
      "system": false,
      "noteable_id": 377,
      "noteable_type": "Issue"
    },
    "author": {
      "name": "Dmitriy Zaporozhets",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://localhost:3000/uploads/user/avatar/1/fox_avatar.png",
      "web_url": "http://localhost:3000/root"
    },
    "author_username": "root",
    "imported": false,
    "imported_from": "none"
  }
]
```

<a id="list-all-visible-events-for-a-project"></a>

## 列出项目的所有可见事件

列出指定项目的所有可见事件。返回当推送超过[推送事件活动数限制](../administration/settings/push_event_activities_limit.md)时创建的批量推送事件，其提交详细信息有限：`commit_count: 0`、`ref_count` 显示推送的引用数量，而各个提交属性的值为 `null`。

```plaintext
GET /projects/:project_id/events
```

参数：

| 参数     | 类型            | 是否必需 | 描述 |
| ------------- | --------------- | -------- | ----------- |
| `project_id`  | integer or string  | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `action`      | string          | 否       | 如果定义，则返回具有指定[操作类型](../user/profile/contributions_calendar.md#user-contribution-events)的事件。 |
| `target_type` | string          | 否       | 如果定义，则返回指定的事件。可能的值：`design`、`issue`、`merge_request`、`milestone`、`note`、`project`、`snippet`、`user` 和 `wiki`。 |
| `before`      | date (ISO 8601) | 否       | 如果定义，则返回在指定日期之前创建的事件。 |
| `after`       | date (ISO 8601) | 否       | 如果定义，则返回在指定日期之后创建的事件。 |
| `sort`        | string          | 否       | 按创建日期对结果排序的方向。可能的值：`asc`、`desc`。默认值：`desc`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:project_id/events?target_type=issue&action=created&after=2017-01-31&before=2017-03-01"
```

示例响应：

```json
[
  {
    "id": 8,
    "title": null,
    "project_id": 1,
    "action_name": "opened",
    "target_id": 160,
    "target_iid": 160,
    "target_type": "Issue",
    "author_id": 25,
    "target_title": "Qui natus eos odio tempore et quaerat consequuntur ducimus cupiditate quis.",
    "created_at": "2017-02-09T10:43:19.667Z",
    "author": {
      "name": "User 3",
      "username": "user3",
      "id": 25,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/97d6d9441ff85fdc730e02a6068d267b?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/user3"
    },
    "author_username": "user3",
    "imported": false,
    "imported_from": "none"
  },
  {
    "id": 9,
    "title": null,
    "project_id": 1,
    "action_name": "opened",
    "target_id": 159,
    "target_iid": 159,
    "target_type": "Issue",
    "author_id": 21,
    "target_title": "Nostrum enim non et sed optio illo deleniti non.",
    "created_at": "2017-02-09T10:43:19.426Z",
    "author": {
      "name": "Test User",
      "username": "ted",
      "id": 21,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/80fb888c9a48b9a3f87477214acaa63f?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/ted"
    },
    "author_username": "ted",
    "imported": false,
    "imported_from": "none"
  },
  {
    "id": 10,
    "title": null,
    "project_id": 1,
    "action_name": "commented on",
    "target_id": 1312,
    "target_iid": 1312,
    "target_type": "Note",
    "author_id": 1,
    "data": null,
    "target_title": null,
    "created_at": "2015-12-04T10:33:58.089Z",
    "note": {
      "id": 1312,
      "body": "What an awesome day!",
      "attachment": null,
      "author": {
        "name": "Dmitriy Zaporozhets",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "https://gitlab.example.com/uploads/user/avatar/1/fox_avatar.png",
        "web_url": "https://gitlab.example.com/root"
      },
      "created_at": "2015-12-04T10:33:56.698Z",
      "system": false,
      "noteable_id": 377,
      "noteable_type": "Issue",
      "noteable_iid": 377
    },
    "author": {
      "name": "Dmitriy Zaporozhets",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "https://gitlab.example.com/uploads/user/avatar/1/fox_avatar.png",
      "web_url": "https://gitlab.example.com/root"
    },
    "author_username": "root",
    "imported": false,
    "imported_from": "none"
  }
]
```
