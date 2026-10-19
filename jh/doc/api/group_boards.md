---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组议题看板 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [群组议题看板](../user/project/issue_board.md#group-issue-boards)。每次调用此 API 都需要身份验证。

如果用户不是群组成员且群组为私有，`GET` 请求会返回 `404` 状态码。

<a id="list-all-group-issue-boards-in-a-group"></a>

## 列出一个群组中的所有群组议题看板

列出指定群组中的所有群组议题看板。

```plaintext
GET /groups/:id/boards
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "group issue board",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "milestone":   {
      "id": 12,
      "title": "10.0"
    },
    "lists" : [
      {
        "id" : 1,
        "label" : {
          "name" : "Testing",
          "color" : "#F0AD4E",
          "description" : null
        },
        "position" : 1
      },
      {
        "id" : 2,
        "label" : {
          "name" : "Ready",
          "color" : "#FF0000",
          "description" : null
        },
        "position" : 2
      },
      {
        "id" : 3,
        "label" : {
          "name" : "Production",
          "color" : "#FF5F00",
          "description" : null
        },
        "position" : 3
      }
    ]
  }
]
```

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 的用户将看到不同的参数，因为它们可以拥有多个群组议题看板。

示例响应：

```json
[
  {
    "id": 1,
    "name": "group issue board",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "milestone":   {
      "id": 12,
      "title": "10.0"
    },
    "lists" : [
      {
        "id" : 1,
        "label" : {
          "name" : "Testing",
          "color" : "#F0AD4E",
          "description" : null
        },
        "position" : 1
      },
      {
        "id" : 2,
        "label" : {
          "name" : "Ready",
          "color" : "#FF0000",
          "description" : null
        },
        "position" : 2
      },
      {
        "id" : 3,
        "label" : {
          "name" : "Production",
          "color" : "#FF5F00",
          "description" : null
        },
        "position" : 3
      }
    ]
  }
]
```

<a id="retrieve-a-group-issue-board"></a>

## 获取一个群组议题看板

获取指定的群组议题看板。

```plaintext
GET /groups/:id/boards/:board_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | 整数 | 是 | 看板的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/1"
```

示例响应：

```json
  {
    "id": 1,
    "name": "group issue board",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "milestone":   {
      "id": 12,
      "title": "10.0"
    },
    "lists" : [
      {
        "id" : 1,
        "label" : {
          "name" : "Testing",
          "color" : "#F0AD4E",
          "description" : null
        },
        "position" : 1
      },
      {
        "id" : 2,
        "label" : {
          "name" : "Ready",
          "color" : "#FF0000",
          "description" : null
        },
        "position" : 2
      },
      {
        "id" : 3,
        "label" : {
          "name" : "Production",
          "color" : "#FF5F00",
          "description" : null
        },
        "position" : 3
      }
    ]
  }
```

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 的用户将看到不同的参数，因为它们可以拥有多个群组议题看板。

示例响应：

```json
  {
    "id": 1,
    "name": "group issue board",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "milestone":   {
      "id": 12,
      "title": "10.0"
    },
    "lists" : [
      {
        "id" : 1,
        "label" : {
          "name" : "Testing",
          "color" : "#F0AD4E",
          "description" : null
        },
        "position" : 1
      },
      {
        "id" : 2,
        "label" : {
          "name" : "Ready",
          "color" : "#FF0000",
          "description" : null
        },
        "position" : 2
      },
      {
        "id" : 3,
        "label" : {
          "name" : "Production",
          "color" : "#FF5F00",
          "description" : null
        },
        "position" : 3
      }
    ]
  }
```

<a id="create-a-group-issue-board"></a>

## 创建一个群组议题看板

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为指定群组创建一个群组议题看板。

```plaintext
POST /groups/:id/boards
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 新看板的名称。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards?name=newboard"
```

示例响应：

```json
  {
    "id": 1,
    "name": "newboard",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "project": null,
    "lists" : [],
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "milestone": null,
    "assignee" : null,
    "labels" : [],
    "weight" : null
  }
```

<a id="update-a-group-issue-board"></a>

## 更新一个群组议题看板

更新指定的群组议题看板。

```plaintext
PUT /groups/:id/boards/:board_id
```

| 属性                    | 类型           | 是否必需 | 描述 |
| ---------------------------- | -------------- | -------- | ----------- |
| `id`                         | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id`                   | 整数        | 是      | 看板的 ID。 |
| `name`                       | 字符串         | 否       | 看板的新名称。 |
| `hide_backlog_list`          | 布尔值        | 否       | 隐藏待办列表。 |
| `hide_closed_list`           | 布尔值        | 否       | 隐藏已关闭列表。 |
| `assignee_id`                | 整数        | 否       | 看板应限定到的指派人。仅专业版和旗舰版。 |
| `milestone_id`               | 整数        | 否       | 看板应限定到的里程碑。仅专业版和旗舰版。 |
| `labels`                     | 字符串         | 否       | 看板应限定到的标签名称列表，以逗号分隔。仅专业版和旗舰版。 |
| `weight`                     | 整数        | 否       | 看板应限定到的权重范围，从 0 到 9。仅专业版和旗舰版。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/1?name=new_name&milestone_id=44&assignee_id=1&labels=GroupLabel&weight=4"
```

示例响应：

```json
  {
    "id": 1,
    "name": "new_name",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "project": null,
    "lists": [],
    "group": {
      "id": 5,
      "name": "Documentcloud",
      "web_url": "http://example.com/groups/documentcloud"
    },
    "milestone": {
      "id": 44,
      "iid": 1,
      "group_id": 5,
      "title": "Group Milestone",
      "description": "Group Milestone Desc",
      "state": "active",
      "created_at": "2018-07-03T07:15:19.271Z",
      "updated_at": "2018-07-03T07:15:19.271Z",
      "due_date": null,
      "start_date": null,
      "web_url": "http://example.com/groups/documentcloud/-/milestones/1"
    },
    "assignee": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://example.com/root"
    },
    "labels": [{
      "id": 11,
      "name": "GroupLabel",
      "color": "#428BCA",
      "description": ""
    }],
    "weight": 4
  }
```

<a id="delete-a-group-issue-board"></a>

## 删除一个群组议题看板

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

删除指定的群组议题看板。

```plaintext
DELETE /groups/:id/boards/:board_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | 整数 | 是 | 看板的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/1"
```

<a id="list-group-issue-board-lists"></a>

## 列出群组议题看板列表

列出指定看板的所有群组议题看板列表。不包括 `open` 和 `closed` 列表。

```plaintext
GET /groups/:id/boards/:board_id/lists
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | 整数 | 是 | 看板的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/1/lists"
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
    "position" : 1
  },
  {
    "id" : 2,
    "label" : {
      "name" : "Ready",
      "color" : "#FF0000",
      "description" : null
    },
    "position" : 2
  },
  {
    "id" : 3,
    "label" : {
      "name" : "Production",
      "color" : "#FF5F00",
      "description" : null
    },
    "position" : 3
  }
]
```

<a id="retrieve-a-group-issue-board-list"></a>

## 获取一个群组议题看板列表

获取指定的群组议题看板列表。

```plaintext
GET /groups/:id/boards/:board_id/lists/:list_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | 整数 | 是 | 看板的 ID。 |
| `list_id` | 整数 | 是 | 看板列表的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/1/lists/1"
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
  "position" : 1
}
```

<a id="create-a-group-issue-board-list"></a>

## 创建一个群组议题看板列表

为指定看板创建一个群组议题看板列表。

```plaintext
POST /groups/:id/boards/:board_id/lists
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | 整数 | 是 | 看板的 ID。 |
| `label_id` | 整数 | 否 | 标签的 ID。 |
| `assignee_id` | 整数 | 否 | 用户的 ID。仅专业版和旗舰版。 |
| `milestone_id` | 整数 | 否 | 里程碑的 ID。仅专业版和旗舰版。 |
| `iteration_id` | 整数 | 否 | 迭代的 ID。仅专业版和旗舰版。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/12/lists?milestone_id=7"
```

示例响应：

```json
{
  "id": 9,
  "label": null,
  "position": 0,
  "milestone": {
    "id": 7,
    "iid": 3,
    "group_id": 12,
    "title": "Milestone with due date",
    "description": "",
    "state": "active",
    "created_at": "2017-09-03T07:16:28.596Z",
    "updated_at": "2017-09-03T07:16:49.521Z",
    "due_date": null,
    "start_date": null,
    "web_url": "https://gitlab.example.com/groups/issue-reproduce/-/milestones/3"
  }
}
```

<a id="update-a-group-issue-board-list"></a>

## 更新群组议题看板列表

更新指定的群组议题看板列表。此调用用于更改列表位置。

```plaintext
PUT /groups/:id/boards/:board_id/lists/:list_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`            | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | 整数 | 是 | 看板的 ID。 |
| `list_id` | 整数 | 是 | 看板列表的 ID。 |
| `position` | 整数 | 是 | 列表的位置。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/1/lists/1?position=2"
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
  "position" : 1
}
```

<a id="delete-a-group-issue-board-list"></a>

## 删除群组议题看板列表

删除指定的群组议题看板列表。仅限管理员和群组所有者。

```plaintext
DELETE /groups/:id/boards/:board_id/lists/:list_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | 整数 | 是 | 看板的 ID。 |
| `list_id` | 整数 | 是 | 看板列表的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/boards/1/lists/1"
```

