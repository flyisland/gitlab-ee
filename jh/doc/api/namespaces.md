---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 命名空间 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 中，计费相关字段的可见性通过功能标志 `restrict_namespace_api_billing_fields` 进行了更改。默认禁用。
- 在极狐GitLab 18.9 中，计费相关字段的可见性 GA，功能标志 `restrict_namespace_api_billing_fields` 已移除。

{{< /history >}}

使用此 API 与命名空间进行交互，命名空间是一种用于组织用户和群组的特殊资源类别。有关更多信息，请参见[命名空间](../user/namespace/_index.md)。

此 API 使用[分页](rest/_index.md#pagination)来过滤结果。

<a id="list-all-namespaces"></a>

## 列出所有命名空间

{{< history >}}

- `top_level_only` 在极狐GitLab 16.8 中引入。

{{< /history >}}

列出当前用户可用的所有命名空间。如果用户是管理员，此端点将返回实例中的所有命名空间。

```plaintext
GET /namespaces
```

| 属性                | 类型    | 是否必填 | 描述                                                                    |
| ------------------- | ------- | -------- | ----------------------------------------------------------------------- |
| `search`            | string  | 否       | 只返回名称或路径中包含指定值的命名空间。                                |
| `owned_only`        | boolean | 否       | 如果为 `true`，则只返回当前用户拥有的命名空间。                         |
| `top_level_only`    | boolean | 否       | 在极狐GitLab 16.8 及更高版本中，如果为 `true`，则只返回顶级命名空间。   |
| `full_path_search`  | boolean | 否       | 如果为 `true`，`search` 参数将与命名空间的完整路径进行匹配。            |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/namespaces"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "user1",
    "path": "user1",
    "kind": "user",
    "full_path": "user1",
    "parent_id": null,
    "avatar_url": "https://secure.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/user1",
    "billable_members_count": 1,
    "plan": "ultimate",
    "end_date": null,
    "trial_ends_on": null,
    "trial": false,
    "root_repository_size": 100,
    "projects_count": 3
  },
  {
    "id": 2,
    "name": "group1",
    "path": "group1",
    "kind": "group",
    "full_path": "group1",
    "parent_id": null,
    "avatar_url": null,
    "web_url": "https://gitlab.example.com/groups/group1",
    "members_count_with_descendants": 2,
    "billable_members_count": 2,
    "plan": "ultimate",
    "end_date": null,
    "trial_ends_on": null,
    "trial": false,
    "root_repository_size": 100,
    "projects_count": 3
  },
  {
    "id": 3,
    "name": "bar",
    "path": "bar",
    "kind": "group",
    "full_path": "foo/bar",
    "parent_id": 9,
    "avatar_url": null,
    "web_url": "https://gitlab.example.com/groups/foo/bar",
    "members_count_with_descendants": 5,
    "billable_members_count": 5,
    "end_date": null,
    "trial_ends_on": null,
    "trial": false,
    "root_repository_size": 100,
    "projects_count": 3
  }
]
```

群组所有者或 JihuLab.com 上可能返回额外的属性：

```json
[
  {
    ...
    "max_seats_used": 3,
    "max_seats_used_changed_at": "2025-05-15T12:00:02.000Z",
    "seats_in_use": 2,
    "projects_count": 1,
    "root_repository_size": 0,
    "members_count_with_descendants": 26,
    "plan": "free",
    ...
  }
]
```

<a id="retrieve-namespace-details"></a>

## 获取命名空间详情

获取指定命名空间的详情。

```plaintext
GET /namespaces/:id
```

| 属性 | 类型             | 是否必填 | 描述                                                                |
| ---- | ---------------- | -------- | ------------------------------------------------------------------- |
| `id` | 整数或字符串     | 是       | 命名空间的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/namespaces/2"
```

示例响应：

```json
{
  "id": 2,
  "name": "group1",
  "path": "group1",
  "kind": "group",
  "full_path": "group1",
  "parent_id": null,
  "avatar_url": null,
  "web_url": "https://gitlab.example.com/groups/group1",
  "members_count_with_descendants": 2,
  "billable_members_count": 2,
  "max_seats_used": 0,
  "seats_in_use": 0,
  "plan": "default",
  "end_date": null,
  "trial_ends_on": null,
  "trial": false,
  "root_repository_size": 100,
  "projects_count": 3
}
```

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/namespaces/group1"
```

示例响应：

```json
{
  "id": 2,
  "name": "group1",
  "path": "group1",
  "kind": "group",
  "full_path": "group1",
  "parent_id": null,
  "avatar_url": null,
  "web_url": "https://gitlab.example.com/groups/group1",
  "members_count_with_descendants": 2,
  "billable_members_count": 2,
  "max_seats_used": 0,
  "seats_in_use": 0,
  "plan": "default",
  "end_date": null,
  "trial_ends_on": null,
  "trial": false,
  "root_repository_size": 100
}
```

<a id="verify-namespace-availability"></a>

## 验证命名空间可用性

验证指定的命名空间是否存在。如果命名空间存在，则端点会建议一个备用名称。

```plaintext
GET /namespaces/:namespace/exists
```

| 属性        | 类型    | 是否必填 | 描述                                                       |
| ----------- | ------- | -------- | ---------------------------------------------------------- |
| `namespace` | string  | 是       | 命名空间的路径。                                           |
| `parent_id` | integer | 否       | 父命名空间的 ID。如果不指定，则只返回顶级命名空间。         |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/namespaces/my-group/exists?parent_id=1"
```

示例响应：

```json
{
    "exists": true,
    "suggests": [
        "my-group1"
    ]
}
```