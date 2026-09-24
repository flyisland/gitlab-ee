---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目议题看板 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[议题看板](../user/project/issue_board.md)。
每次调用此 API 都需要进行身份验证。

如果用户不是私有项目的成员，
对该项目执行 `GET` 请求会返回 `404` 状态码。

<a id="list-all-project-issue-boards"></a>

## 列出项目中的所有议题看板

列出指定项目中的所有议题看板。

```plaintext
GET /projects/:id/boards
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards"
```

示例响应：

```json
[
  {
    "id" : 1,
    "name": "board1",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "project": {
      "id": 5,
      "name": "Diaspora Project Site",
      "name_with_namespace": "Diaspora / Diaspora Project Site",
      "path": "diaspora-project-site",
      "path_with_namespace": "diaspora/diaspora-project-site",
      "http_url_to_repo": "http://example.com/diaspora/diaspora-project-site.git",
      "web_url": "http://example.com/diaspora/diaspora-project-site"
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
        "position" : 1,
        "max_issue_count": 0,
        "max_issue_weight": 0,
        "limit_metric": null
      },
      {
        "id" : 2,
        "label" : {
          "name" : "Ready",
          "color" : "#FF0000",
          "description" : null
        },
        "position" : 2,
        "max_issue_count": 0,
        "max_issue_weight": 0,
        "limit_metric":  null
      },
      {
        "id" : 3,
        "label" : {
          "name" : "Production",
          "color" : "#FF5F00",
          "description" : null
        },
        "position" : 3,
        "max_issue_count": 0,
        "max_issue_weight": 0,
        "limit_metric":  null
      }
    ]
  }
]
```

当项目中没有已激活或存在的看板时，另一个示例响应：

```json
[]
```

<a id="retrieve-an-issue-board"></a>

## 检索一个议题看板

检索项目中指定的议题看板。

```plaintext
GET /projects/:id/boards/:board_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | integer | 是 | 看板的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1"
```

示例响应：

```json
  {
    "id": 1,
    "name": "project issue board",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "project": {
      "id": 5,
      "name": "Diaspora Project Site",
      "name_with_namespace": "Diaspora / Diaspora Project Site",
      "path": "diaspora-project-site",
      "path_with_namespace": "diaspora/diaspora-project-site",
      "http_url_to_repo": "http://example.com/diaspora/diaspora-project-site.git",
      "web_url": "http://example.com/diaspora/diaspora-project-site"
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
        "position" : 1,
        "max_issue_count": 0,
        "max_issue_weight": 0,
        "limit_metric":  null
      },
      {
        "id" : 2,
        "label" : {
          "name" : "Ready",
          "color" : "#FF0000",
          "description" : null
        },
        "position" : 2,
        "max_issue_count": 0,
        "max_issue_weight": 0,
        "limit_metric":  null
      },
      {
        "id" : 3,
        "label" : {
          "name" : "Production",
          "color" : "#FF5F00",
          "description" : null
        },
        "position" : 3,
        "max_issue_count": 0,
        "max_issue_weight": 0,
        "limit_metric":  null
      }
    ]
  }
```

<a id="create-an-issue-board"></a>

## 创建议题看板

在指定项目中创建议题看板。

```plaintext
POST /projects/:id/boards
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | string | 是 | 新看板的名称。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards" \
  --data "name=newboard"
```

示例响应：

```json
  {
    "id": 1,
    "name": "newboard",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "project": {
      "id": 5,
      "name": "Diaspora Project Site",
      "name_with_namespace": "Diaspora / Diaspora Project Site",
      "path": "diaspora-project-site",
      "path_with_namespace": "diaspora/diaspora-project-site",
      "http_url_to_repo": "http://example.com/diaspora/diaspora-project-site.git",
      "web_url": "http://example.com/diaspora/diaspora-project-site"
    },
    "lists" : [],
    "group": null,
    "milestone": null,
    "assignee" : null,
    "labels" : [],
    "weight" : null
  }
```

<a id="update-an-issue-board"></a>

## 更新议题看板

更新项目中指定的议题看板。

```plaintext
PUT /projects/:id/boards/:board_id
```

| 属性                        | 类型           | 是否必需 | 描述 |
| ---------------------------- | -------------- | -------- | ----------- |
| `id`                         | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id`                   | integer        | 是      | 看板的 ID。 |
| `name`                       | string         | 否       | 看板的新名称。 |
| `hide_backlog_list`          | boolean        | 否       | 隐藏 Open 列表。 |
| `hide_closed_list`           | boolean        | 否       | 隐藏 Closed 列表。 |
| `assignee_id`                | integer        | 否       | 看板应限定范围的指派人。仅专业版和旗舰版。 |
| `milestone_id`               | integer        | 否       | 看板应限定范围的里程碑。仅专业版和旗舰版。 |
| `labels`                     | string         | 否       | 以逗号分隔的标签名称列表，看板应限定范围至这些标签。仅专业版和旗舰版。 |
| `weight`                     | integer        | 否       | 权重范围，从 0 到 9，看板应限定范围至该权重。仅专业版和旗舰版。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1" \
  --data "name=new_name&milestone_id=43&assignee_id=1&labels=Doing&weight=4"
```

示例响应：

```json
  {
    "id": 1,
    "name": "new_name",
    "hide_backlog_list": false,
    "hide_closed_list": false,
    "project": {
      "id": 5,
      "name": "Diaspora Project Site",
      "name_with_namespace": "Diaspora / Diaspora Project Site",
      "path": "diaspora-project-site",
      "path_with_namespace": "diaspora/diaspora-project-site",
      "created_at": "2018-07-03T05:48:49.982Z",
      "default_branch": null,
      "tag_list": [], //已废弃，请改用 `topics`
      "topics": [],
      "ssh_url_to_repo": "ssh://user@example.com/diaspora/diaspora-project-site.git",
      "http_url_to_repo": "http://example.com/diaspora/diaspora-project-site.git",
      "web_url": "http://example.com/diaspora/diaspora-project-site",
      "readme_url": null,
      "avatar_url": null,
      "star_count": 0,
      "forks_count": 0,
      "last_activity_at": "2018-07-03T05:48:49.982Z"
    },
    "lists": [],
    "group": null,
    "milestone": {
      "id": 43,
      "iid": 1,
      "project_id": 15,
      "title": "Milestone 1",
      "description": "Milestone 1 desc",
      "state": "active",
      "created_at": "2018-07-03T06:36:42.618Z",
      "updated_at": "2018-07-03T06:36:42.618Z",
      "due_date": null,
      "start_date": null,
      "web_url": "http://example.com/root/board1/milestones/1"
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
      "id": 10,
      "name": "Doing",
      "color": "#5CB85C",
      "description": null
    }],
    "weight": 4
  }
```

<a id="delete-an-issue-board"></a>

## 删除议题看板

删除项目中指定的议题看板。

```plaintext
DELETE /projects/:id/boards/:board_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | integer | 是 | 看板的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1"
```

<a id="list-all-board-lists-in-an-issue-board"></a>

## 列出议题看板中的所有列表

列出指定议题看板中的所有列表。
不包括 `open` 和 `closed` 列表。

```plaintext
GET /projects/:id/boards/:board_id/lists
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | integer | 是 | 看板的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1/lists"
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
    "max_issue_count": 0,
    "max_issue_weight": 0,
    "limit_metric":  null
  },
  {
    "id" : 2,
    "label" : {
      "name" : "Ready",
      "color" : "#FF0000",
      "description" : null
    },
    "position" : 2,
    "max_issue_count": 0,
    "max_issue_weight": 0,
    "limit_metric":  null
  },
  {
    "id" : 3,
    "label" : {
      "name" : "Production",
      "color" : "#FF5F00",
      "description" : null
    },
    "position" : 3,
    "max_issue_count": 0,
    "max_issue_weight": 0,
    "limit_metric":  null
  }
]
```

<a id="retrieve-a-board-list"></a>

## 检索一个看板列表

从议题看板中检索指定的列表。

```plaintext
GET /projects/:id/boards/:board_id/lists/:list_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | integer | 是 | 看板的 ID。 |
| `list_id`| integer | 是 | 看板列表的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1/lists/1"
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
  "max_issue_count": 0,
  "max_issue_weight": 0,
  "limit_metric":  null
}
```

<a id="create-a-board-list"></a>

## 创建看板列表

创建一个新的议题看板列表。

```plaintext
POST /projects/:id/boards/:board_id/lists
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | integer | 是 | 看板的 ID。 |
| `label_id` | integer | 否 | 标签的 ID。 |
| `assignee_id` | integer | 否 | 用户的 ID。仅专业版和旗舰版。 |
| `milestone_id` | integer | 否 | 里程碑的 ID。仅专业版和旗舰版。 |
| `iteration_id` | integer | 否 | 迭代的 ID。仅专业版和旗舰版。 |

> [!note]
> 标签、指派人及里程碑参数互斥，即每个请求中仅能接受其中一项。
> 请查阅[议题看板文档](../user/project/issue_board.md)以获取每种列表类型所需许可证的更多信息。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1/lists" \
  --data "label_id=5"
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
  "max_issue_count": 0,
  "max_issue_weight": 0,
  "limit_metric":  null
}
```

<a id="update-a-board-list"></a>

## 更新看板列表

更新议题看板中指定列表的位置。

```plaintext
PUT /projects/:id/boards/:board_id/lists/:list_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | integer | 是 | 看板的 ID。 |
| `list_id` | integer | 是 | 看板列表的 ID。 |
| `position` | integer | 是 | 列表的位置。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1/lists/1" \
  --data "position=2"
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
  "max_issue_count": 0,
  "max_issue_weight": 0,
  "limit_metric":  null
}
```

<a id="delete-a-board-list-from-a-board"></a>

## 从看板中删除列表

从议题看板中删除指定的列表。

前提条件：

- 满足以下任一条件：
  - 拥有项目的 计划者、报告者、Security Manager、开发者、维护者 或 所有者 角色。
  - 管理员权限。

```plaintext
DELETE /projects/:id/boards/:board_id/lists/:list_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `board_id` | integer | 是 | 看板的 ID。 |
| `list_id` | integer | 是 | 看板列表的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/boards/1/lists/1"
```