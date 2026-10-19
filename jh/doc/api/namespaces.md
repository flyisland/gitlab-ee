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

使用此 API 与命名空间交互。命名空间是一种特殊的资源类别，用于组织用户和群组。更多信息，请参见[命名空间](../user/namespace/_index.md)。

此 API 使用[分页](rest/_index.md#pagination)来筛选结果。

<a id="list-all-namespaces"></a>

## 列出所有命名空间

列出当前用户可用的所有命名空间。如果该用户是管理员，此端点会返回实例中的所有命名空间。

```plaintext
GET /namespaces
```

| 属性          | 类型    | 是否必需 | 描述                                                                             |
|--------------------|---------|----------|-----------------------------------------------------------------------------------------|
| `search`           | string  | 否       | 仅返回名称或路径中包含指定值的命名空间。         |
| `owned_only`       | boolean | 否       | 如果为 `true`，则仅返回当前用户拥有的命名空间。                                 |
| `top_level_only`   | boolean | 否       | 如果为 `true`，则仅返回顶级命名空间。                                           |
| `full_path_search` | boolean | 否       | 如果为 `true`，则 `search` 参数将与命名空间的完整路径进行匹配。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
| --------- | ---- | ----------- |
| `id` | integer | 命名空间的 ID。 |
| `name` | string | 命名空间的名称。 |
| `path` | string | 命名空间的路径段。 |
| `kind` | string | 命名空间类型：`user` 或 `group`。 |
| `full_path` | string | 命名空间的完整路径，包括子群组的父路径。 |
| `parent_id` | integer | 父命名空间的 ID。对于顶级命名空间为 `null`。 |
| `avatar_url` | string | 命名空间头像的 URL。如果未设置则为 `null`。 |
| `web_url` | string | 命名空间在极狐GitLab 上的 URL。 |
| `billable_members_count` | integer | 命名空间中计费成员的数量。 |
| `plan` | string | 命名空间的订阅计划（例如 `free`、`ultimate`）。 |
| `end_date` | date | 当前订阅的结束日期。如果不适用则为 `null`。 |
| `trial_ends_on` | date | 试用结束的日期。如果不在试用期则为 `null`。 |
| `trial` | boolean | 命名空间是否处于试用计划。 |
| `root_repository_size` | integer | 命名空间中所有代码仓库的总大小，以字节为单位。 |
| `projects_count` | integer | 命名空间中项目的数量。 |
| `members_count_with_descendants` | integer | 成员总数，包括子群组中的成员。仅对群组命名空间返回。 |
| `max_seats_used` | integer | 当前订阅期内使用的最大席位数量。仅对群组所有者或在 JihuLab.com 上返回。 |
| `max_seats_used_changed_at` | datetime | `max_seats_used` 上次更改的时间戳。仅对群组所有者或在 JihuLab.com 上返回。 |
| `seats_in_use` | integer | 当前正在使用的席位数量。仅对群组所有者或在 JihuLab.com 上返回。 |
| `ci_minutes_usage` | object | 计算分钟用量明细。在 JihuLab.com 上，反映应用于所有命名空间的[计算配额系统](../ci/pipelines/compute_minutes.md)。在极狐GitLab 私有化部署上，仅当[在命名空间上配置了计算配额](../administration/cicd/compute_minutes.md#set-the-compute-quota-for-a-group)时才返回。仅当用户具有所有者角色或是管理员时，对顶级群组返回。 |
| `ci_minutes_usage.total_minutes_used` | integer | 当前计费周期内使用的计算分钟总数。 |
| `ci_minutes_usage.monthly_minutes_used` | integer | 从每月配额中使用的计算分钟。 |
| `ci_minutes_usage.purchased_minutes_used` | integer | 从额外购买的配额中使用的计算分钟。 |
| `shared_runners_minutes_limit` | integer | 分配给命名空间的每月计算配额。仅在 JihuLab.com 上，对实例管理员返回。 |
| `extra_shared_runners_minutes_limit` | integer | 在每月配额之上额外添加的计算分钟。反映购买的分钟包。仅在 JihuLab.com 上，对实例管理员返回。 |

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

对于群组所有者或在 JihuLab.com 上，可能会返回以下附加属性。与计算分钟和已购买存储量相关的四个属性（`shared_runners_minutes_limit`、
`extra_shared_runners_minutes_limit`、`additional_purchased_storage_size`、
`additional_purchased_storage_ends_on`）仅在 JihuLab.com 上对管理员返回：

```json
[
  {
    ...
    "max_seats_used": 3,
    "max_seats_used_changed_at":"2025-05-15T12:00:02.000Z",
    "seats_in_use": 2,
    "projects_count": 1,
    "root_repository_size":0,
    "members_count_with_descendants":26,
    "plan": "free",
    "shared_runners_minutes_limit": 133,
    "extra_shared_runners_minutes_limit": 50,
    "additional_purchased_storage_size": 1000,
    "additional_purchased_storage_ends_on": "2022-06-18",
    ...
  }
]
```

<a id="retrieve-namespace-details"></a>

## 检索命名空间详情

检索指定命名空间的详情。

```plaintext
GET /namespaces/:id
```

| 属性 | 类型           | 是否必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 命名空间的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
| --------- | ---- | ----------- |
| `id` | integer | 命名空间的 ID。 |
| `name` | string | 命名空间的名称。 |
| `path` | string | 命名空间的路径段。 |
| `kind` | string | 命名空间类型：`user` 或 `group`。 |
| `full_path` | string | 命名空间的完整路径，包括子群组的父路径。 |
| `parent_id` | integer | 父命名空间的 ID。对于顶级命名空间为 `null`。 |
| `avatar_url` | string | 命名空间头像的 URL。如果未设置则为 `null`。 |
| `web_url` | string | 命名空间在极狐GitLab 上的 URL。 |
| `billable_members_count` | integer | 命名空间中计费成员的数量。 |
| `plan` | string | 命名空间的订阅计划（例如 `free`、`ultimate`）。 |
| `end_date` | date | 当前订阅的结束日期。如果不适用则为 `null`。 |
| `trial_ends_on` | date | 试用结束的日期。如果不在试用期则为 `null`。 |
| `trial` | boolean | 命名空间是否处于试用计划。 |
| `root_repository_size` | integer | 命名空间中所有代码仓库的总大小，以字节为单位。 |
| `projects_count` | integer | 命名空间中项目的数量。 |
| `members_count_with_descendants` | integer | 成员总数，包括子群组中的成员。仅对群组命名空间返回。 |
| `max_seats_used` | integer | 当前订阅期内使用的最大席位数量。仅对群组所有者或在 JihuLab.com 上返回。 |
| `max_seats_used_changed_at` | datetime | `max_seats_used` 上次更改的时间戳。仅对群组所有者或在 JihuLab.com 上返回。 |
| `seats_in_use` | integer | 当前正在使用的席位数量。仅对群组所有者或在 JihuLab.com 上返回。 |
| `ci_minutes_usage` | object | 计算分钟用量明细。在 JihuLab.com 上，反映应用于所有命名空间的[计算配额系统](../ci/pipelines/compute_minutes.md)。在极狐GitLab 私有化部署上，仅当[在命名空间上配置了计算配额](../administration/cicd/compute_minutes.md#set-the-compute-quota-for-a-group)时才返回。仅当用户具有所有者角色或是管理员时，对顶级群组返回。 |
| `ci_minutes_usage.total_minutes_used` | integer | 当前计费周期内使用的计算分钟总数。 |
| `ci_minutes_usage.monthly_minutes_used` | integer | 从每月配额中使用的计算分钟。 |
| `ci_minutes_usage.purchased_minutes_used` | integer | 从额外购买的配额中使用的计算分钟。 |
| `shared_runners_minutes_limit` | integer | 分配给命名空间的每月计算配额。仅在 JihuLab.com 上，对实例管理员返回。 |
| `extra_shared_runners_minutes_limit` | integer | 在每月配额之上额外添加的计算分钟。反映购买的分钟包。仅在 JihuLab.com 上，对实例管理员返回。 |

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
  "projects_count": 3,
  "ci_minutes_usage": {
    "total_minutes_used": 450,
    "monthly_minutes_used": 400,
    "purchased_minutes_used": 50
  }
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
  "root_repository_size": 100,
  "ci_minutes_usage": {
    "total_minutes_used": 450,
    "monthly_minutes_used": 400,
    "purchased_minutes_used": 50
  }
}
```

<a id="verify-namespace-availability"></a>

## 验证命名空间可用性

验证指定的命名空间是否存在。如果该命名空间存在，此端点会建议一个替代名称。

```plaintext
GET /namespaces/:namespace/exists
```

| 属性   | 类型    | 是否必需 | 描述 |
| ----------- | ------- | -------- | ----------- |
| `namespace` | string  | 是      | 命名空间的路径。 |
| `parent_id` | integer | 否       | 父命名空间的 ID。如果未指定，则仅返回顶级命名空间。 |

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
