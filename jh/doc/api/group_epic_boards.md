---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组史诗板 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 15.9。

{{< /history >}}

使用此 API 来管理[群组史诗板](../user/group/epics/epic_boards.md)。每个对此 API 的请求都必须经过身份验证。

如果用户不是群组成员且群组是私有的，则 `GET` 请求会返回 `404` 状态码。

<a id="list-all-epic-boards-in-a-group"></a>

## 列出群组中的所有史诗板

列出指定群组的所有史诗板。

```plaintext
GET /groups/:id/epic_boards
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | yes | 经过身份验证的用户可访问的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epic_boards"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "group epic board",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "labels": [
      {
        "id": 1,
        "title": "Board Label",
        "color": "#c21e56",
        "description": "label applied to the epic board",
        "group_id": 5,
        "project_id": null,
        "template": false,
        "text_color": "#FFFFFF",
        "created_at": "2023-01-27T10:40:59.738Z",
        "updated_at": "2023-01-27T10:40:59.738Z"
      }
    ],
    "lists": [
      {
        "id": 1,
        "label": {
          "id": 69,
          "name": "Testing",
          "color": "#F0AD4E",
          "description": null
        },
        "position": 1,
        "list_type": "label"
      },
      {
        "id": 2,
        "label": {
          "id": 70,
          "name": "Ready",
          "color": "#FF0000",
          "description": null
        },
        "position": 2,
        "list_type": "label"
      },
      {
        "id": 3,
        "label": {
          "id": 71,
          "name": "Production",
          "color": "#FF5F00",
          "description": null
        },
        "position": 3,
        "list_type": "label"
      }
    ]
  }
]
```

<a id="retrieve-a-group-epic-board"></a>

## 获取群组史诗板

获取指定的群组史诗板。

```plaintext
GET /groups/:id/epic_boards/:board_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | yes | 经过身份验证的用户可访问的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `board_id` | integer | yes | 史诗板的 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epic_boards/1"
```

示例响应：

```json
  {
    "id": 1,
    "name": "group epic board",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "labels": [
      {
        "id": 1,
        "title": "Board Label",
        "color": "#c21e56",
        "description": "label applied to the epic board",
        "group_id": 5,
        "project_id": null,
        "template": false,
        "text_color": "#FFFFFF",
        "created_at": "2023-01-27T10:40:59.738Z",
        "updated_at": "2023-01-27T10:40:59.738Z"
      }
    ],
    "lists" : [
      {
        "id" : 1,
        "label" : {
          "id": 69,
          "name" : "Testing",
          "color" : "#F0AD4E",
          "description" : null
        },
        "position" : 1,
        "list_type": "label"
      },
      {
        "id" : 2,
        "label" : {
          "id": 70,
          "name" : "Ready",
          "color" : "#FF0000",
          "description" : null
        },
        "position" : 2,
        "list_type": "label"
      },
      {
        "id" : 3,
        "label" : {
          "id": 71,
          "name" : "Production",
          "color" : "#FF5F00",
          "description" : null
        },
        "position" : 3,
        "list_type": "label"
      }
    ]
  }
```

<a id="list-group-epic-board-lists"></a>

## 列出群组史诗板列表

{{< history >}}

- 引入于极狐GitLab 15.9。

{{< /history >}}

列出指定板的所有群组史诗板列表。不包括 `open` 和 `closed` 列表。

```plaintext
GET /groups/:id/epic_boards/:board_id/lists
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | yes | 经过身份验证的用户可访问的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `board_id` | integer | yes | 史诗板的 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epic_boards/1/lists"
```

示例响应：

```json
[
  {
    "id" : 1,
    "label" : {
      "name" : "Testing",
      "color" : "#F0AD4E",
      "description" : null
    },
    "position" : 1,
    "list_type" : "label",
    "collapsed" : false
  },
  {
    "id" : 2,
    "label" : {
      "name" : "Ready",
      "color" : "#FF0000",
      "description" : null
    },
    "position" : 2,
    "list_type" : "label",
    "collapsed" : false
  },
  {
    "id" : 3,
    "label" : {
      "name" : "Production",
      "color" : "#FF5F00",
      "description" : null
    },
    "position" : 3,
    "list_type" : "label",
    "collapsed" : false
  }
]
```

<a id="retrieve-a-group-epic-board-list"></a>

## 获取群组史诗板列表

{{< history >}}

- 引入于极狐GitLab 15.9。

{{< /history >}}

获取指定的群组史诗板列表。

```plaintext
GET /groups/:id/epic_boards/:board_id/lists/:list_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | yes | 经过身份验证的用户可访问的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `board_id` | integer | yes | 史诗板的 ID |
| `list_id` | integer | yes | 史诗板列表的 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epic_boards/1/lists/1"
```

示例响应：

```json
{
  "id" : 1,
  "label" : {
    "name" : "Testing",
    "color" : "#F0AD4E",
    "description" : null
  },
  "position" : 1,
  "list_type" : "label",
  "collapsed" : false
}
```