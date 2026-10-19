---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 关联史诗 API（已弃用）
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 14.9 中引入，带有一个功能标志，名称为 `related_epics_widget`。默认启用。
- 功能标志 `related_epics_widget` 在极狐GitLab 15.0 中被移除。

{{< /history >}}

> [!warning]
> Epics REST API 在极狐GitLab 17.0 中已被弃用，
> 并计划在 API v5 中移除。
> 从极狐GitLab 17.4 到 18.0，如果启用了史诗的新外观，并且在极狐GitLab 18.1 及更高版本中，请改用
> Work Items API。更多信息，请参阅迁移史诗 API 到工作项。
> 这是一项重大变更。

如果您的极狐GitLab 计划中未提供关联史诗功能，将返回 `403` 状态码。

<a id="list-all-related-epic-links-for-a-group"></a>

## 列出一个群组的所有关联史诗链接

列出指定群组及其子群组的所有关联史诗链接。用户需要同时拥有对 `source_epic` 和 `target_epic` 的访问权限才能查看关联史诗链接。

```plaintext
GET /groups/:id/related_epic_links
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述                                                               |
| ---------------- | ----------------- | -------- | ------------------------------------------------------------------ |
| `id`             | 整数或字符串      | 是       | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths)。     |
| `created_after`  | 字符串            | 否       | 返回在给定时间或之后创建的关联史诗链接。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`） |
| `created_before` | 字符串            | 否       | 返回在给定时间或之前创建的关联史诗链接。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`） |
| `updated_after`  | 字符串            | 否       | 返回在给定时间或之后更新的关联史诗链接。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`） |
| `updated_before` | 字符串            | 否       | 返回在给定时间或之前更新的关联史诗链接。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`） |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/related_epic_links"
```

示例响应：

```json
[
  {
    "id": 1,
    "created_at": "2022-01-31T15:10:44.988Z",
    "updated_at": "2022-01-31T15:10:44.988Z",
    "link_type": "relates_to",
    "source_epic": {
      "id": 21,
      "iid": 1,
      "color": "#1068bf",
      "text_color": "#FFFFFF",
      "group_id": 26,
      "parent_id": null,
      "parent_iid": null,
      "title": "Aspernatur recusandae distinctio omnis et qui est iste.",
      "description": "some description",
      "confidential": false,
      "author": {
        "id": 15,
        "username": "trina",
        "name": "Theresia Robel",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/085e28df717e16484cbf6ceca75e9a93?s=80&d=identicon",
        "web_url": "http://gitlab.example.com/trina"
      },
      "start_date": null,
      "end_date": null,
      "due_date": null,
      "state": "opened",
      "web_url": "http://gitlab.example.com/groups/flightjs/-/epics/1",
      "references": {
        "short": "&1",
        "relative": "&1",
        "full": "flightjs&1"
      },
      "created_at": "2022-01-31T15:10:44.988Z",
      "updated_at": "2022-03-16T09:32:35.712Z",
      "closed_at": null,
      "labels": [],
      "upvotes": 0,
      "downvotes": 0,
      "_links": {
        "self": "http://gitlab.example.com/api/v4/groups/26/epics/1",
        "epic_issues": "http://gitlab.example.com/api/v4/groups/26/epics/1/issues",
        "group": "http://gitlab.example.com/api/v4/groups/26",
        "parent": null
      }
    },
    "target_epic": {
      "id": 25,
      "iid": 5,
      "color": "#1068bf",
      "text_color": "#FFFFFF",
      "group_id": 26,
      "parent_id": null,
      "parent_iid": null,
      "title": "Aut assumenda id nihil distinctio fugiat vel numquam est.",
      "description": "some description",
      "confidential": false,
      "author": {
        "id": 3,
        "username": "valerie",
        "name": "Erika Wolf",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/9ef7666abb101418a4716a8ed4dded80?s=80&d=identicon",
        "web_url": "http://gitlab.example.com/valerie"
      },
      "start_date": null,
      "end_date": null,
      "due_date": null,
      "state": "opened",
      "web_url": "http://gitlab.example.com/groups/flightjs/-/epics/5",
      "references": {
        "short": "&5",
        "relative": "&5",
        "full": "flightjs&5"
      },
      "created_at": "2022-01-31T15:10:45.080Z",
      "updated_at": "2022-03-16T09:32:35.842Z",
      "closed_at": null,
      "labels": [],
      "upvotes": 0,
      "downvotes": 0,
      "_links": {
        "self": "http://gitlab.example.com/api/v4/groups/26/epics/5",
        "epic_issues": "http://gitlab.example.com/api/v4/groups/26/epics/5/issues",
        "group": "http://gitlab.example.com/api/v4/groups/26",
        "parent": null
      }
    },
  }
]
```

<a id="list-all-linked-epics-for-an-epic"></a>

## 列出一个史诗的所有关联史诗

列出指定史诗的所有关联史诗。

```plaintext
GET /groups/:id/epics/:epic_iid/related_epics
```

支持的属性：

| 属性       | 类型           | 是否必需 | 描述                                                               |
| ---------- | -------------- | -------- | ------------------------------------------------------------------ |
| `epic_iid` | 整数           | 是       | 群组史诗的内部 ID                                                  |
| `id`       | 整数或字符串   | 是       | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths)。     |

示例请求：

```shell
curl --request GET \
 --header "PRIVATE-TOKEN: <your_access_token>" \
 --url "https://gitlab.example.com/api/v4/groups/:id/epics/:epic_iid/related_epics"
```

示例响应：

```json
[
   {
      "id":2,
      "iid":2,
      "color":"#1068bf",
      "text_color":"#FFFFFF",
      "group_id":2,
      "parent_id":null,
      "parent_iid":null,
      "title":"My title 2",
      "description":null,
      "confidential":false,
      "author":{
         "id":3,
         "username":"user3",
         "name":"Sidney Jones4",
         "state":"active",
         "avatar_url":"https://www.gravatar.com/avatar/82797019f038ab535a84c6591e7bc936?s=80u0026d=identicon",
         "web_url":"http://localhost/user3"
      },
      "start_date":null,
      "end_date":null,
      "due_date":null,
      "state":"opened",
      "web_url":"http://localhost/groups/group1/-/epics/2",
      "references":{
         "short":"u00262",
         "relative":"u00262",
         "full":"group1u00262"
      },
      "created_at":"2022-03-10T18:35:24.479Z",
      "updated_at":"2022-03-10T18:35:24.479Z",
      "closed_at":null,
      "labels":[

      ],
      "upvotes":0,
      "downvotes":0,
      "_links":{
         "self":"http://localhost/api/v4/groups/2/epics/2",
         "epic_issues":"http://localhost/api/v4/groups/2/epics/2/issues",
         "group":"http://localhost/api/v4/groups/2",
         "parent":null
      },
      "related_epic_link_id":1,
      "link_type":"relates_to",
      "link_created_at":"2022-03-10T18:35:24.496+00:00",
      "link_updated_at":"2022-03-10T18:35:24.496+00:00"
   }
]
```

<a id="create-a-related-epic-link"></a>

## 创建关联史诗链接

{{< history >}}

- 在极狐GitLab 15.8 中，群组所需的最低角色从报告者更改为访客。

{{< /history >}}

在两个史诗之间创建双向关联。用户必须在两个群组中都拥有访客、计划者、报告者、开发者、维护者或所有者角色。

```plaintext
POST /groups/:id/epics/:epic_iid/related_epics
```

支持的属性：

| 属性               | 类型              | 是否必需 | 描述                                                           |
| ------------------ | ----------------- | -------- | -------------------------------------------------------------- |
| `epic_iid`         | 整数              | 是       | 群组史诗的内部 ID                                              |
| `id`               | 整数或字符串      | 是       | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `target_epic_iid`  | 整数或字符串      | 是       | 目标群组史诗的内部 ID                                          |
| `target_group_id`  | 整数或字符串      | 是       | 目标群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `link_type`        | 字符串            | 否       | 关联类型（`relates_to`、`blocks`、`is_blocked_by`），默认为 `relates_to`。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/26/epics/1/related_epics?target_group_id=26&target_epic_iid=5"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2022-01-31T15:10:44.988Z",
  "updated_at": "2022-01-31T15:10:44.988Z",
  "link_type": "relates_to",
  "source_epic": {
    "id": 21,
    "iid": 1,
    "color": "#1068bf",
    "text_color": "#FFFFFF",
    "group_id": 26,
    "parent_id": null,
    "parent_iid": null,
    "title": "Aspernatur recusandae distinctio omnis et qui est iste.",
    "description": "some description",
    "confidential": false,
    "author": {
      "id": 15,
      "username": "trina",
      "name": "Theresia Robel",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/085e28df717e16484cbf6ceca75e9a93?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/trina"
    },
    "start_date": null,
    "end_date": null,
    "due_date": null,
    "state": "opened",
    "web_url": "http://gitlab.example.com/groups/flightjs/-/epics/1",
    "references": {
      "short": "&1",
      "relative": "&1",
      "full": "flightjs&1"
    },
    "created_at": "2022-01-31T15:10:44.988Z",
    "updated_at": "2022-03-16T09:32:35.712Z",
    "closed_at": null,
    "labels": [],
    "upvotes": 0,
    "downvotes": 0,
    "_links": {
      "self": "http://gitlab.example.com/api/v4/groups/26/epics/1",
      "epic_issues": "http://gitlab.example.com/api/v4/groups/26/epics/1/issues",
      "group": "http://gitlab.example.com/api/v4/groups/26",
      "parent": null
    }
  },
  "target_epic": {
    "id": 25,
    "iid": 5,
    "color": "#1068bf",
    "text_color": "#FFFFFF",
    "group_id": 26,
    "parent_id": null,
    "parent_iid": null,
    "title": "Aut assumenda id nihil distinctio fugiat vel numquam est.",
    "description": "some description",
    "confidential": false,
    "author": {
      "id": 3,
      "username": "valerie",
      "name": "Erika Wolf",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/9ef7666abb101418a4716a8ed4dded80?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/valerie"
    },
    "start_date": null,
    "end_date": null,
    "due_date": null,
    "state": "opened",
    "web_url": "http://gitlab.example.com/groups/flightjs/-/epics/5",
    "references": {
      "short": "&5",
      "relative": "&5",
      "full": "flightjs&5"
    },
    "created_at": "2022-01-31T15:10:45.080Z",
    "updated_at": "2022-03-16T09:32:35.842Z",
    "closed_at": null,
    "labels": [],
    "upvotes": 0,
    "downvotes": 0,
    "_links": {
      "self": "http://gitlab.example.com/api/v4/groups/26/epics/5",
      "epic_issues": "http://gitlab.example.com/api/v4/groups/26/epics/5/issues",
      "group": "http://gitlab.example.com/api/v4/groups/26",
      "parent": null
    }
  },
}
```

<a id="delete-a-related-epic-link"></a>

## 删除关联史诗链接

{{< history >}}

- 在极狐GitLab 15.8 中，群组所需的最低角色从报告者更改为访客。

{{< /history >}}

删除两个指定史诗之间的双向关联。用户必须在两个群组中都拥有访客、计划者、报告者、开发者、维护者或所有者角色。

```plaintext
DELETE /groups/:id/epics/:epic_iid/related_epics/:related_epic_link_id
```

支持的属性：

| 属性                    | 类型              | 是否必需 | 描述                                                           |
| ----------------------- | ----------------- | -------- | -------------------------------------------------------------- |
| `epic_iid`              | 整数              | 是       | 群组史诗的内部 ID                                              |
| `id`                    | 整数或字符串      | 是       | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `related_epic_link_id`  | 整数或字符串      | 是       | 关联史诗链接的内部 ID                                          |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/26/epics/1/related_epics/1"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2022-01-31T15:10:44.988Z",
  "updated_at": "2022-01-31T15:10:44.988Z",
  "link_type": "relates_to",
  "source_epic": {
    "id": 21,
    "iid": 1,
    "color": "#1068bf",
    "text_color": "#FFFFFF",
    "group_id": 26,
    "parent_id": null,
    "parent_iid": null,
    "title": "Aspernatur recusandae distinctio omnis et qui est iste.",
    "description": "some description",
    "confidential": false,
    "author": {
      "id": 15,
      "username": "trina",
      "name": "Theresia Robel",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/085e28df717e16484cbf6ceca75e9a93?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/trina"
    },
    "start_date": null,
    "end_date": null,
    "due_date": null,
    "state": "opened",
    "web_url": "http://gitlab.example.com/groups/flightjs/-/epics/1",
    "references": {
      "short": "&1",
      "relative": "&1",
      "full": "flightjs&1"
    },
    "created_at": "2022-01-31T15:10:44.988Z",
    "updated_at": "2022-03-16T09:32:35.712Z",
    "closed_at": null,
    "labels": [],
    "upvotes": 0,
    "downvotes": 0,
    "_links": {
      "self": "http://gitlab.example.com/api/v4/groups/26/epics/1",
      "epic_issues": "http://gitlab.example.com/api/v4/groups/26/epics/1/issues",
      "group": "http://gitlab.example.com/api/v4/groups/26",
      "parent": null
    }
  },
  "target_epic": {
    "id": 25,
    "iid": 5,
    "color": "#1068bf",
    "text_color": "#FFFFFF",
    "group_id": 26,
    "parent_id": null,
    "parent_iid": null,
    "title": "Aut assumenda id nihil distinctio fugiat vel numquam est.",
    "description": "some description",
    "confidential": false,
    "author": {
      "id": 3,
      "username": "valerie",
      "name": "Erika Wolf",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/9ef7666abb101418a4716a8ed4dded80?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/valerie"
    },
    "start_date": null,
    "end_date": null,
    "due_date": null,
    "state": "opened",
    "web_url": "http://gitlab.example.com/groups/flightjs/-/epics/5",
    "references": {
      "short": "&5",
      "relative": "&5",
      "full": "flightjs&5"
    },
    "created_at": "2022-01-31T15:10:45.080Z",
    "updated_at": "2022-03-16T09:32:35.842Z",
    "closed_at": null,
    "labels": [],
    "upvotes": 0,
    "downvotes": 0,
    "_links": {
      "self": "http://gitlab.example.com/api/v4/groups/26/epics/5",
      "epic_issues": "http://gitlab.example.com/api/v4/groups/26/epics/5/issues",
      "group": "http://gitlab.example.com/api/v4/groups/26",
      "parent": null
    }
  },
}
```