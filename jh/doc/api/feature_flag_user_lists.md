---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 功能标志用户列表 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com， 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 专业版 12.10 中引入。
- 于 13.5 迁移至极狐GitLab 基础版。

{{< /history >}}

使用此 API 与极狐GitLab [用户列表](../operations/feature_flags.md#user-list) 的功能标志进行交互。

先决条件：

- 你必须具有开发者、维护者或所有者角色。

> [!note]
> 要与面向所有用户的功能标志交互，请参见 [功能标志 API](feature_flags.md)。

<a id="list-all-feature-flag-user-lists-for-a-project"></a>

## 列出项目的所有功能标志用户列表

列出指定项目的所有功能标志用户列表。

```plaintext
GET /projects/:id/feature_flags_user_lists
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数控制结果分页。

| 属性     | 类型             | 是否必需 | 描述                                                                               |
| -------- | ---------------- | -------- | ---------------------------------------------------------------------------------- |
| `id`     | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                     |
| `search` | string           | 否       | 返回与搜索条件匹配的用户列表。                                                     |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags_user_lists"
```

示例响应：

```json
[
   {
      "name": "user_list",
      "user_xids": "user1,user2",
      "id": 1,
      "iid": 1,
      "project_id": 1,
      "created_at": "2020-02-04T08:13:51.423Z",
      "updated_at": "2020-02-04T08:13:51.423Z"
   },
   {
      "name": "test_users",
      "user_xids": "user3,user4,user5",
      "id": 2,
      "iid": 2,
      "project_id": 1,
      "created_at": "2020-02-04T08:13:10.507Z",
      "updated_at": "2020-02-04T08:13:10.507Z"
   }
]
```

<a id="create-a-feature-flag-user-list"></a>

## 创建功能标志用户列表

在指定项目中创建功能标志用户列表。

```plaintext
POST /projects/:id/feature_flags_user_lists
```

| 属性                 | 类型             | 是否必需 | 描述                                                                           |
| -------------------- | ---------------- | -------- | ------------------------------------------------------------------------------ |
| `id`                 | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                |
| `name`               | string           | 是       | 列表的名称。                                                                   |
| `user_xids`          | string           | 是       | 以逗号分隔的外部用户 ID 列表。                                                  |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags_user_lists" \
  --data @- << EOF
{
    "name": "my_user_list",
    "user_xids": "user1,user2,user3"
}
EOF
```

示例响应：

```json
{
   "name": "my_user_list",
   "user_xids": "user1,user2,user3",
   "id": 1,
   "iid": 1,
   "project_id": 1,
   "created_at": "2020-02-04T08:32:27.288Z",
   "updated_at": "2020-02-04T08:32:27.288Z"
}
```

<a id="retrieve-a-feature-flag-user-list"></a>

## 检索功能标志用户列表

检索指定的功能标志用户列表。

```plaintext
GET /projects/:id/feature_flags_user_lists/:iid
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数控制结果分页。

| 属性                 | 类型             | 是否必需 | 描述                                                                           |
| -------------------- | ---------------- | -------- | ------------------------------------------------------------------------------ |
| `id`                 | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                |
| `iid`                | integer 或 string | 是       | 项目功能标志用户列表的内部 ID。                                                 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags_user_lists/1"
```

示例响应：

```json
{
   "name": "my_user_list",
   "user_xids": "123,456",
   "id": 1,
   "iid": 1,
   "project_id": 1,
   "created_at": "2020-02-04T08:13:10.507Z",
   "updated_at": "2020-02-04T08:13:10.507Z"
}
```

<a id="update-a-feature-flag-user-list"></a>

## 更新功能标志用户列表

更新指定的功能标志用户列表。

```plaintext
PUT /projects/:id/feature_flags_user_lists/:iid
```

| 属性                 | 类型             | 是否必需 | 描述                                                                           |
| -------------------- | ---------------- | -------- | ------------------------------------------------------------------------------ |
| `id`                 | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                |
| `iid`                | integer 或 string | 是       | 项目功能标志用户列表的内部 ID。                                                 |
| `name`               | string           | 否       | 列表的名称。                                                                   |
| `user_xids`          | string           | 否       | 以逗号分隔的外部用户 ID 列表。                                                  |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags_user_lists/1" \
  --data @- << EOF
{
    "user_xids": "user2,user3,user4"
}
EOF
```

示例响应：

```json
{
   "name": "my_user_list",
   "user_xids": "user2,user3,user4",
   "id": 1,
   "iid": 1,
   "project_id": 1,
   "created_at": "2020-02-04T08:32:27.288Z",
   "updated_at": "2020-02-05T09:33:17.179Z"
}
```

<a id="delete-feature-flag-user-list"></a>

## 删除功能标志用户列表

删除指定的功能标志用户列表。

```plaintext
DELETE /projects/:id/feature_flags_user_lists/:iid
```

| 属性                 | 类型             | 是否必需 | 描述                                                                           |
| -------------------- | ---------------- | -------- | ------------------------------------------------------------------------------ |
| `id`                 | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                |
| `iid`                | integer 或 string | 是       | 项目功能标志用户列表的内部 ID。                                                 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags_user_lists/1"
```