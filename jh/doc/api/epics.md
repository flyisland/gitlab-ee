---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 史诗 API（已弃用）
description: 查看极狐GitLab 官方史诗 API 文档。了解如何以编程方式有效列出、创建、更新和删除群组中的史诗。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 史诗 REST API 已在极狐GitLab 17.0 中[弃用](https://jihulab.com/gitlab-cn/gitlab/-/issues/460668)，并计划在 API v5 中移除。
> 从极狐GitLab 17.4 到 18.0，如果启用了[史诗新外观](../user/group/epics/_index.md#epics-as-work-items)，以及在极狐GitLab 18.1 及之后版本，请改用工作项 API。更多信息，请参见[将史诗 API 迁移至工作项](graphql/epic_work_items_api_migration_guide.md)。
> 此更改是一个破坏性变更。

对史诗的每个 API 调用都必须经过认证。

如果用户不是私有群组的成员，对该群组的 `GET` 请求将返回 `404` 状态码。

如果史诗功能不可用，将返回 `403` 状态码。

<a id="legacy-epic-ids-and-workitem-ids"></a>

## 旧版史诗 ID 与工作项 ID

旧版史诗 ID 与工作项 ID 不相同。只有 `iid` 是匹配的。但是，要获取史诗对应的工作项 ID，响应中会包含一个 `work_item_id`。

此 ID 可用于工作项 GraphQL API，例如，`work_item_id` 在工作项 GraphQL API 中对应的全局 ID 为 `gid://gitlab/WorkItem/123`。

<a id="epic-issues-api"></a>

## 史诗议题 API

[史诗议题 API](epic_issues.md) 允许你与史诗关联的议题进行交互。

<a id="milestone-dates-integration"></a>

## 里程碑日期集成

由于开始日期和截止日期可以动态来自关联议题里程碑，当用户具有编辑权限时，会显示额外的字段。这包括两个布尔值字段 `start_date_is_fixed` 和 `due_date_is_fixed`，以及四个日期字段 `start_date_fixed`、`start_date_from_inherited_source`、`due_date_fixed` 和 `due_date_from_inherited_source`。

- `end_date` 已弃用，推荐使用 `due_date`。
- `start_date_from_milestones` 已弃用，推荐使用 `start_date_from_inherited_source`
- `due_date_from_milestones` 已弃用，推荐使用 `due_date_from_inherited_source`

<a id="list-all-group-epics"></a>

## 列出所有群组史诗

列出指定群组及其子群组的所有史诗。

响应是[分页](rest/_index.md#pagination)的，默认返回 20 条结果。

> [!note]
> `references.relative` 是相对于请求史诗的群组而言的。当从史诗的原始群组获取时，`relative` 格式与 `short` 格式相同。
> 当跨群组请求史诗时，`relative` 格式预期与 `full` 格式相同。

```plaintext
GET /groups/:id/epics
GET /groups/:id/epics?author_id=5
GET /groups/:id/epics?labels=bug,reproduced
GET /groups/:id/epics?state=opened
```

| 属性           | 类型             | 必需   | 描述                                                                                                                 |
| ------------------- | ---------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------- |
| `id`                | integer 或 string   | 是        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)               |
| `author_id`         | integer          | 否         | 返回由给定用户 `id` 创建的史诗                                                                                 |
| `author_username`   | string           | 否         | 返回由给定 `username` 用户创建的史诗。 |
| `labels`            | string           | 否         | 返回匹配逗号分隔标签名称列表的史诗。可以使用史诗所在群组或父群组的标签名称 |
| `with_labels_details` | boolean        | 否         | 如果为 `true`，响应会返回每个标签的更多详细信息：`:name`、`:color`、`:description`、`:description_html`、`:text_color`。默认为 `false`。 |
| `order_by`          | string           | 否         | 返回按 `created_at`、`updated_at` 或 `title` 字段排序的史诗。默认为 `created_at`                              |
| `sort`              | string           | 否         | 返回按 `asc` 或 `desc` 排序的史诗。默认为 `desc`                                                             |
| `search`            | string           | 否         | 根据史诗的 `title` 和 `description` 进行搜索                                                                        |
| `state`             | string           | 否         | 根据史诗的 `state` 进行搜索，可能的过滤值：`opened`、`closed` 和 `all`，默认值：`all`                          |
| `created_after`     | datetime         | 否         | 返回在给定时间或之后创建的史诗。预期格式为 ISO 8601（`2019-03-15T08:00:00Z`） |
| `created_before`    | datetime         | 否         | 返回在给定时间或之前创建的史诗。预期格式为 ISO 8601（`2019-03-15T08:00:00Z`） |
| `updated_after`     | datetime         | 否         | 返回在给定时间或之后更新的史诗。预期格式为 ISO 8601（`2019-03-15T08:00:00Z`） |
| `updated_before`    | datetime         | 否         | 返回在给定时间或之前更新的史诗。预期格式为 ISO 8601（`2019-03-15T08:00:00Z`） |
| `include_ancestor_groups` | boolean    | 否         | 包括来自请求群组父级群组的史诗。默认为 `false`                                                      |
| `include_descendant_groups` | boolean  | 否         | 包括来自请求群组子级群组的史诗。默认为 `true`                                                     |
| `my_reaction_emoji` | string           | 否         | 返回已认证用户使用指定 emoji 做出反应的史诗。`None` 返回未给出反应的史诗。`Any` 返回至少给出一个反应的史诗。 |
| `not` | Hash | 否 | 返回不匹配所提供参数的史诗。可接受：`author_id`、`author_username` 和 `labels`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics"
```

示例响应：

```json
[
  {
  "id": 29,
  "work_item_id": 1032,
  "iid": 4,
  "group_id": 7,
  "parent_id": 23,
  "parent_iid": 3,
  "title": "Accusamus iste et ullam ratione voluptatem omnis debitis dolor est.",
  "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
  "state": "opened",
  "confidential": "false",
  "web_url": "http://gitlab.example.com/groups/test/-/epics/4",
  "reference": "&4",
  "references": {
    "short": "&4",
    "relative": "&4",
    "full": "test&4"
  },
  "author": {
    "id": 10,
    "name": "Lu Mayer",
    "username": "kam",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/kam"
  },
  "start_date": null,
  "start_date_is_fixed": false,
  "start_date_fixed": null,
  "start_date_from_milestones": null,       //已弃用，推荐使用 start_date_from_inherited_source
  "start_date_from_inherited_source": null,
  "end_date": "2018-07-31",                 //已弃用，推荐使用 due_date
  "due_date": "2018-07-31",
  "due_date_is_fixed": false,
  "due_date_fixed": null,
  "due_date_from_milestones": "2018-07-31", //已弃用，推荐使用 start_date_from_inherited_source
  "due_date_from_inherited_source": "2018-07-31",
  "created_at": "2018-07-17T13:36:22.770Z",
  "updated_at": "2018-07-18T12:22:05.239Z",
  "closed_at": "2018-08-18T12:22:05.239Z",
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "color": "#1068bf",
  "_links":{
      "self": "http://gitlab.example.com/api/v4/groups/7/epics/4",
      "epic_issues": "http://gitlab.example.com/api/v4/groups/7/epics/4/issues",
      "group":"http://gitlab.example.com/api/v4/groups/7",
      "parent":"http://gitlab.example.com/api/v4/groups/7/epics/3"
  }
  },
  {
  "id": 50,
  "work_item_id": 1035,
  "iid": 35,
  "group_id": 17,
  "parent_id": 19,
  "parent_iid": 1,
  "title": "Accusamus iste et ullam ratione voluptatem omnis debitis dolor est.",
  "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
  "state": "opened",
  "web_url": "http://gitlab.example.com/groups/test/sample/-/epics/35",
  "reference": "&4",
  "references": {
    "short": "&4",
    "relative": "sample&4",
    "full": "test/sample&4"
  },
  "author": {
    "id": 10,
    "name": "Lu Mayer",
    "username": "kam",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/kam"
  },
  "start_date": null,
  "start_date_is_fixed": false,
  "start_date_fixed": null,
  "start_date_from_milestones": null,       //已弃用，推荐使用 start_date_from_inherited_source
  "start_date_from_inherited_source": null,
  "end_date": "2018-07-31",                 //已弃用，推荐使用 due_date
  "due_date": "2018-07-31",
  "due_date_is_fixed": false,
  "due_date_fixed": null,
  "due_date_from_milestones": "2018-07-31", //已弃用，推荐使用 start_date_from_inherited_source
  "due_date_from_inherited_source": "2018-07-31",
  "created_at": "2018-07-17T13:36:22.770Z",
  "updated_at": "2018-07-18T12:22:05.239Z",
  "closed_at": "2018-08-18T12:22:05.239Z",
  "imported": false,
  "imported_from": "none",
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "color": "#1068bf",
  "_links":{
      "self": "http://gitlab.example.com/api/v4/groups/17/epics/35",
      "epic_issues": "http://gitlab.example.com/api/v4/groups/17/epics/35/issues",
      "group":"http://gitlab.example.com/api/v4/groups/17",
      "parent":"http://gitlab.example.com/api/v4/groups/17/epics/1"
  }
  }
]
```

<a id="retrieve-an-epic"></a>

## 获取史诗

获取指定群组的一个史诗。

```plaintext
GET /groups/:id/epics/:epic_iid
```

| 属性           | 类型             | 必需   | 描述                                                                            |
| ------------------- | ---------------- | ---------- | ---------------------------------------------------------------------------------------|
| `id`                | integer 或 string   | 是        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                |
| `epic_iid`          | integer 或 string   | 是        | 史诗的内部 ID。  |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5"
```

示例响应：

```json
{
  "id": 30,
  "work_item_id": 1099,
  "iid": 5,
  "group_id": 7,
  "parent_id": null,
  "parent_iid": null,
  "title": "Ea cupiditate dolores ut vero consequatur quasi veniam voluptatem et non.",
  "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
  "state": "opened",
  "imported": false,
  "imported_from": "none",
  "web_url": "http://gitlab.example.com/groups/test/-/epics/5",
  "reference": "&5",
  "references": {
    "short": "&5",
    "relative": "&5",
    "full": "test&5"
  },
  "author":{
    "id": 7,
    "name": "Pamella Huel",
    "username": "arnita",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/arnita"
  },
  "start_date": null,
  "start_date_is_fixed": false,
  "start_date_fixed": null,
  "start_date_from_milestones": null,       //已弃用，推荐使用 start_date_from_inherited_source
  "start_date_from_inherited_source": null,
  "end_date": "2018-07-31",                 //已弃用，推荐使用 due_date
  "due_date": "2018-07-31",
  "due_date_is_fixed": false,
  "due_date_fixed": null,
  "due_date_from_milestones": "2018-07-31", //已弃用，推荐使用 start_date_from_inherited_source
  "due_date_from_inherited_source": "2018-07-31",
  "created_at": "2018-07-17T13:36:22.770Z",
  "updated_at": "2018-07-18T12:22:05.239Z",
  "closed_at": "2018-08-18T12:22:05.239Z",
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "color": "#1068bf",
  "subscribed": true,
  "_links":{
      "self": "http://gitlab.example.com/api/v4/groups/7/epics/5",
      "epic_issues": "http://gitlab.example.com/api/v4/groups/7/epics/5/issues",
      "group":"http://gitlab.example.com/api/v4/groups/7",
      "parent": null
  }
}
```

<a id="create-an-epic"></a>

## 创建史诗

为指定群组创建一个史诗。

> [!note]
> 自极狐GitLab [11.3](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/6448) 开始，不应再直接为 `start_date` 和 `end_date` 赋值，因为它们现在表示组合值。你可以通过 `*_is_fixed` 和 `*_fixed` 字段进行配置。

```plaintext
POST /groups/:id/epics
```

| 属性           | 类型             | 必需   | 描述                                                                            |
| ------------------- | ---------------- | ---------- | ---------------------------------------------------------------------------------------|
| `id`                | integer 或 string   | 是        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                |
| `title`             | string           | 是        | 史诗的标题 |
| `labels`            | string           | 否         | 逗号分隔的标签列表 |
| `description`       | string           | 否         | 史诗的描述。限制为 1,048,576 个字符。  |
| `color`             | string           | 否         | 史诗的颜色。由名为 `epic_highlight_color` 的功能标志控制（默认禁用） |
| `confidential`      | boolean          | 否         | 史诗是否应保密 |
| `created_at`        | string           | 否         | 史诗的创建时间。日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限 |
| `start_date_is_fixed` | boolean        | 否         | 开始日期是否应来自 `start_date_fixed` 或来自里程碑 |
| `start_date_fixed`  | string           | 否         | 史诗的固定开始日期 |
| `due_date_is_fixed` | boolean          | 否         | 截止日期是否应来自 `due_date_fixed` 或来自里程碑 |
| `due_date_fixed`    | string           | 否         | 史诗的固定截止日期 |
| `parent_id`         | integer 或 string   | 否         | 父史诗的 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics?title=Epic&description=Epic%20description&parent_id=29"
```

示例响应：

```json
{
  "id": 33,
  "work_item_id": 1020,
  "iid": 6,
  "group_id": 7,
  "parent_id": 29,
  "parent_iid": 4,
  "title": "Epic",
  "description": "Epic description",
  "state": "opened",
  "imported": false,
  "imported_from": "none",
  "confidential": "false",
  "web_url": "http://gitlab.example.com/groups/test/-/epics/6",
  "reference": "&6",
  "references": {
    "short": "&6",
    "relative": "&6",
    "full": "test&6"
  },
  "author": {
    "name" : "Alexandra Bashirian",
    "avatar_url" : null,
    "state" : "active",
    "web_url" : "https://gitlab.example.com/eileen.lowe",
    "id" : 18,
    "username" : "eileen.lowe"
  },
  "start_date": null,
  "start_date_is_fixed": false,
  "start_date_fixed": null,
  "start_date_from_milestones": null,       //已弃用，推荐使用 start_date_from_inherited_source
  "start_date_from_inherited_source": null,
  "end_date": "2018-07-31",                 //已弃用，推荐使用 due_date
  "due_date": "2018-07-31",
  "due_date_is_fixed": false,
  "due_date_fixed": null,
  "due_date_from_milestones": "2018-07-31", //已弃用，推荐使用 start_date_from_inherited_source
  "due_date_from_inherited_source": "2018-07-31",
  "created_at": "2018-07-17T13:36:22.770Z",
  "updated_at": "2018-07-18T12:22:05.239Z",
  "closed_at": "2018-08-18T12:22:05.239Z",
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "color": "#1068bf",
  "_links":{
    "self": "http://gitlab.example.com/api/v4/groups/7/epics/6",
    "epic_issues": "http://gitlab.example.com/api/v4/groups/7/epics/6/issues",
    "group":"http://gitlab.example.com/api/v4/groups/7",
    "parent": "http://gitlab.example.com/api/v4/groups/7/epics/4"
  }
}
```

<a id="update-an-epic"></a>

## 更新史诗

更新指定群组的一个史诗。

```plaintext
PUT /groups/:id/epics/:epic_iid
```

| 属性           | 类型             | 必需   | 描述                                                                            |
| ------------------- | ---------------- | ---------- | ---------------------------------------------------------------------------------------|
| `id`                | integer 或 string   | 是        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                |
| `epic_iid`          | integer 或 string   | 是        | 史诗的内部 ID  |
| `add_labels`        | string           | 否         | 逗号分隔的标签名称，用于添加到议题。 |
| `confidential`      | boolean          | 否         | 史诗是否应保密 |
| `description`       | string           | 否         | 史诗的描述。限制为 1,048,576 个字符。  |
| `due_date_fixed`    | string           | 否         | 史诗的固定截止日期 |
| `due_date_is_fixed` | boolean          | 否         | 截止日期是否应来自 `due_date_fixed` 或来自里程碑 |
| `labels`            | string           | 否         | 议题的逗号分隔标签名称。设置为空字符串以取消分配所有标签。 |
| `parent_id`         | integer 或 string   | 否         | 父史诗的 ID。 |
| `remove_labels`     | string           | 否         | 逗号分隔的标签名称，用于从议题中移除。 |
| `start_date_fixed`  | string           | 否         | 史诗的固定开始日期 |
| `start_date_is_fixed` | boolean        | 否         | 开始日期是否应来自 `start_date_fixed` 或来自里程碑 |
| `state_event`       | string           | 否         | 史诗的状态事件。设置 `close` 以关闭史诗，设置 `reopen` 以重新打开 |
| `title`             | string           | 否         | 史诗的标题 |
| `updated_at`        | string           | 否         | 史诗的更新时间。日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限 |
| `color`             | string           | 否         | 史诗的颜色。由名为 `epic_highlight_color` 的功能标志控制（默认禁用） |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5?title=New%20Title&parent_id=29"
```

示例响应：

```json
{
  "id": 33,
  "work_item_id": 1019,
  "iid": 6,
  "group_id": 7,
  "parent_id": 29,
  "parent_iid": 4,
  "title": "New Title",
  "description": "Epic description",
  "state": "opened",
  "imported": false,
  "imported_from": "none",
  "confidential": "false",
  "web_url": "http://gitlab.example.com/groups/test/-/epics/6",
  "reference": "&6",
  "references": {
    "short": "&6",
    "relative": "&6",
    "full": "test&6"
  },
  "author": {
    "name" : "Alexandra Bashirian",
    "avatar_url" : null,
    "state" : "active",
    "web_url" : "https://gitlab.example.com/eileen.lowe",
    "id" : 18,
    "username" : "eileen.lowe"
  },
  "start_date": null,
  "start_date_is_fixed": false,
  "start_date_fixed": null,
  "start_date_from_milestones": null,       //已弃用，推荐使用 start_date_from_inherited_source
  "start_date_from_inherited_source": null,
  "end_date": "2018-07-31",                 //已弃用，推荐使用 due_date
  "due_date": "2018-07-31",
  "due_date_is_fixed": false,
  "due_date_fixed": null,
  "due_date_from_milestones": "2018-07-31", //已弃用，推荐使用 start_date_from_inherited_source
  "due_date_from_inherited_source": "2018-07-31",
  "created_at": "2018-07-17T13:36:22.770Z",
  "updated_at": "2018-07-18T12:22:05.239Z",
  "closed_at": "2018-08-18T12:22:05.239Z",
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "color": "#1068bf"
}
```

<a id="delete-an-epic"></a>

## 删除史诗

{{< history >}}

- 在极狐GitLab 16.11 中[更改]。在极狐GitLab 16.10 及更早版本中，如果删除史诗，其所有子史诗及后代也会被删除。如果需要，可以在删除前从父史诗中移除子史诗。

{{< /history >}}

从指定群组中删除一个史诗。

```plaintext
DELETE /groups/:id/epics/:epic_iid
```

| 属性           | 类型             | 必需   | 描述                                                                            |
| ------------------- | ---------------- | ---------- | ---------------------------------------------------------------------------------------|
| `id`                | integer 或 string   | 是        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                |
| `epic_iid`          | integer 或 string   | 是        | 史诗的内部 ID。  |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5"
```

<a id="create-a-to-do-item-for-an-epic"></a>

## 为史诗创建待办事项

为当前用户在指定史诗上创建一个待办事项。如果该用户在该史诗上已存在待办事项，则返回状态码 304。

```plaintext
POST /groups/:id/epics/:epic_iid/todo
```

| 属性   | 类型    | 必需 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | integer 或 string | 是   | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)  |
| `epic_iid` | integer | 是          | 群组史诗的内部 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/todo"
```

示例响应：

```json
{
  "id": 112,
  "group": {
    "id": 1,
    "name": "Gitlab",
    "path": "gitlab",
    "kind": "group",
    "full_path": "base/gitlab",
    "parent_id": null
  },
  "author": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/root"
  },
  "action_name": "marked",
  "target_type": "epic",
  "target": {
    "id": 30,
    "iid": 5,
    "group_id": 1,
    "title": "Ea cupiditate dolores ut vero consequatur quasi veniam voluptatem et non.",
    "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
    "author":{
      "id": 7,
      "name": "Pamella Huel",
      "username": "arnita",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a2f5c6fcef64c9c69cb8779cb292be1b?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/arnita"
    },
    "web_url": "http://gitlab.example.com/groups/test/-/epics/5",
    "reference": "&5",
    "references": {
      "short": "&5",
      "relative": "&5",
      "full": "test&5"
    },
    "start_date": null,
    "end_date": null,
    "created_at": "2018-01-21T06:21:13.165Z",
    "updated_at": "2018-01-22T12:41:41.166Z",
    "closed_at": "2018-08-18T12:22:05.239Z"
  },
  "target_url": "https://gitlab.example.com/groups/epics/5",
  "body": "Vel voluptas atque dicta mollitia adipisci qui at.",
  "state": "pending",
  "created_at": "2016-07-01T11:09:13.992Z"
}
```

