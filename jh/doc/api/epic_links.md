---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 史诗链接 API (已弃用)
description: Review the GitLab API documentation for Epic Links. Discover how to programmatically manage, create, and remove parent and child epic relationships efficiently.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 史诗 REST API 在 极狐GitLab 17.0 中已弃用，并计划在 API v5 中移除。
> 从 极狐GitLab 17.4 到 18.0，如果启用了 [史诗的新外观](../user/group/epics/_index.md#epics-as-work-items)，并且在 极狐GitLab 18.1 及更高版本中，请改用工作项 API。更多信息，参见 [将史诗 API 迁移到工作项](graphql/epic_work_items_api_migration_guide.md)。
> 此变更为重大变更。

管理父子[史诗关系](../user/work_items/child_items.md#work-with-multi-level-hierarchies)。

每个对 `epic_links` 的 API 调用都必须经过认证。

如果用户不是私有群组的成员，对该群组发起 `GET` 请求会返回 `404` 状态码。

多级史诗仅在 [极狐GitLab 旗舰版](https://gitlab.cn/pricing/) 中可用。如果多级史诗功能不可用，则会返回 `403` 状态码。

<a id="list-all-child-epics-of-an-epic"></a>

## 列出史诗的所有子史诗

列出史诗的所有子史诗。

```plaintext
GET /groups/:id/epics/:epic_iid/epics
```

| 属性         | 类型              | 是否必需 | 描述                                                                                                |
| ------------ | ----------------- | -------- | --------------------------------------------------------------------------------------------------- |
| `id`         | integer 或 string | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                         |
| `epic_iid`   | integer           | 是       | 史诗的内部 ID。                                                                                     |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/epics"
```

示例响应：

```json
[
  {
    "id": 29,
    "iid": 6,
    "group_id": 1,
    "parent_id": 5,
    "title": "Accusamus iste et ullam ratione voluptatem omnis debitis dolor est.",
    "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
    "author": {
      "id": 10,
      "name": "Lu Mayer",
      "username": "kam",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
      "web_url": "http://localhost:3001/kam"
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
    "labels": []
  }
]
```

<a id="assign-a-child-epic"></a>

## 分配子史诗

在两个史诗之间创建关联，将一个指定为父史诗，另一个指定为子史诗。一个父史诗可以有多个子史诗。如果新的子史诗原本属于另一个史诗，它将从之前的父史诗中取消分配。

```plaintext
POST /groups/:id/epics/:epic_iid/epics/:child_epic_id
```

| 属性             | 类型              | 是否必需 | 描述                                                                                                              |
| ---------------- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| `id`             | integer 或 string | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                                         |
| `epic_iid`       | integer           | 是       | 史诗的内部 ID。                                                                                                   |
| `child_epic_id`  | integer           | 是       | 子史诗的全局 ID。不能使用内部 ID，因为它们可能与其他群组的史诗冲突。                                               |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/epics/6"

```

示例响应：

```json
{
  "id": 6,
  "iid": 38,
  "group_id": 1,
  "parent_id": 5,
  "title": "Accusamus iste et ullam ratione voluptatem omnis debitis dolor est.",
  "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
  "author": {
    "id": 10,
    "name": "Lu Mayer",
    "username": "kam",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
    "web_url": "http://localhost:3001/kam"
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
  "labels": []
}
```

<a id="create-and-assign-a-child-epic"></a>

## 创建并分配子史诗

创建一个新史诗并将其与提供的父史诗关联。响应为一个 `LinkedEpic` 对象。

```plaintext
POST /groups/:id/epics/:epic_iid/epics
```

| 属性            | 类型              | 是否必需 | 描述                                                                                                                                |
| --------------- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `id`            | integer 或 string | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                                                           |
| `epic_iid`      | integer           | 是       | （未来的父）史诗的内部 ID。                                                                                                         |
| `title`         | string            | 是       | 新创建史诗的标题。                                                                                                                  |
| `confidential`  | boolean           | 否       | 史诗是否应为机密。如果 `confidential_epics` 功能标志被禁用，此参数将被忽略。默认继承父史诗的机密状态。                                |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/5/epics?title=Newpic"
```

示例响应：

```json
{
  "id": 24,
  "iid": 2,
  "title": "child epic",
  "group_id": 49,
  "parent_id": 23,
  "has_children": false,
  "has_issues": false,
  "reference":  "&2",
  "url": "http://localhost/groups/group16/-/epics/2",
  "relation_url": "http://localhost/groups/group16/-/epics/1/links/24"
}
```

<a id="re-order-a-child-epic"></a>

## 重排子史诗

```plaintext
PUT /groups/:id/epics/:epic_iid/epics/:child_epic_id
```

| 属性              | 类型              | 是否必需 | 描述                                                                                                                |
| ----------------- | ----------------- | -------- | ------------------------------------------------------------------------------------------------------------------- |
| `id`              | integer 或 string | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                                           |
| `epic_iid`        | integer           | 是       | 史诗的内部 ID。                                                                                                     |
| `child_epic_id`   | integer           | 是       | 子史诗的全局 ID。不能使用内部 ID，因为它们可能与其他群组的史诗冲突。                                               |
| `move_before_id`  | integer           | 否       | 应放置在该子史诗之前的同级史诗的全局 ID。                                                                           |
| `move_after_id`   | integer           | 否       | 应放置在该子史诗之后的同级史诗的全局 ID。                                                                           |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/4/epics/5"
```

示例响应：

```json
[
  {
    "id": 29,
    "iid": 6,
    "group_id": 1,
    "parent_id": 5,
    "title": "Accusamus iste et ullam ratione voluptatem omnis debitis dolor est.",
    "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
    "author": {
      "id": 10,
      "name": "Lu Mayer",
      "username": "kam",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
      "web_url": "http://localhost:3001/kam"
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
    "labels": []
  }
]
```

<a id="unassign-a-child-epic"></a>

## 取消分配子史诗

从父史诗中取消分配一个子史诗。

```plaintext
DELETE /groups/:id/epics/:epic_iid/epics/:child_epic_id
```

| 属性             | 类型              | 是否必需 | 描述                                                                                                              |
| ---------------- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| `id`             | integer 或 string | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                                         |
| `epic_iid`       | integer           | 是       | 史诗的内部 ID。                                                                                                   |
| `child_epic_id`  | integer           | 是       | 子史诗的全局 ID。不能使用内部 ID，因为它们可能与其他群组的史诗冲突。                                               |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/4/epics/5"
```

示例响应：

```json
{
  "id": 5,
  "iid": 38,
  "group_id": 1,
  "parent_id": null,
  "title": "Accusamus iste et ullam ratione voluptatem omnis debitis dolor est.",
  "description": "Molestias dolorem eos vitae expedita impedit necessitatibus quo voluptatum.",
  "author": {
    "id": 10,
    "name": "Lu Mayer",
    "username": "kam",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/018729e129a6f31c80a6327a30196823?s=80&d=identicon",
    "web_url": "http://localhost:3001/kam"
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
  "labels": []
}
```