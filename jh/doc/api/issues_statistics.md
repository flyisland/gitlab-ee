---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for issues statistics in 极狐GitLab.
title: 议题统计 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 获取[议题](../user/project/issues/_index.md)的统计信息。
每次调用此 API 都需要身份验证。

如果用户不是项目的成员且项目为私有，则对该项目的 `GET` 请求会返回 `404` 状态码。

<a id="retrieve-issues-statistics-for-a-user"></a>

## 获取用户的议题统计信息

检索当前用户可访问的议题统计信息。默认情况下，仅返回当前用户创建的议题。要获取所有议题，请将 `scope` 属性设置为 `all`。

```plaintext
GET /issues_statistics
GET /issues_statistics?labels=foo
GET /issues_statistics?labels=foo,bar
GET /issues_statistics?labels=foo,bar&state=opened
GET /issues_statistics?milestone=1.0.0
GET /issues_statistics?milestone=1.0.0&state=opened
GET /issues_statistics?iids[]=42&iids[]=43
GET /issues_statistics?author_id=5
GET /issues_statistics?assignee_id=5
GET /issues_statistics?my_reaction_emoji=star
GET /issues_statistics?search=foo&in=title
GET /issues_statistics?confidential=true
```

| 属性           | 类型             | 必需   | 描述                                                                                                                                         |
| ------------------- | ---------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `labels`            | string           | 否         | 以逗号分隔的标签名称列表，议题必须包含所有标签才会被返回。`None` 列出所有没有标签的议题。`Any` 列出至少有一个标签的议题。 |
| `milestone`         | string           | 否         | 里程碑标题。`None` 列出所有没有里程碑的议题。`Any` 列出所有已分配里程碑的议题。                             |
| `scope`             | string           | 否         | 返回给定范围的议题：`created_by_me`、`assigned_to_me` 或 `all`。默认为 `created_by_me` |
| `author_id`         | integer          | 否         | 返回由给定用户 `id` 创建的议题。与 `author_username` 互斥。可与 `scope=all` 或 `scope=assigned_to_me` 结合使用。 |
| `author_username`   | string           | 否         | 返回由给定 `username` 创建的议题。类似于 `author_id`，并与 `author_id` 互斥。 |
| `assignee_id`       | integer          | 否         | 返回分配给给定用户 `id` 的议题。与 `assignee_username` 互斥。`None` 返回未分配的议题。`Any` 返回已分配指派人的议题。 |
| `assignee_username` | string array     | 否         | 返回分配给给定 `username` 的议题。类似于 `assignee_id`，并与 `assignee_id` 互斥。在极狐GitLab 基础版中，`assignee_username` 数组应仅包含一个值，否则会返回无效参数错误。 |
| `epic_id`           | integer      | 否         | 返回与给定史诗 ID 关联的议题。`None` 返回未关联史诗的议题。`Any` 返回已关联史诗的议题。仅专业版和旗舰版。 |
| `my_reaction_emoji` | string           | 否         | 返回由认证用户通过给定 `emoji` 做出反应的议题。`None` 返回未获得反应的议题。`Any` 返回至少获得一个反应的议题。 |
| `iids[]`            | integer array    | 否         | 仅返回具有给定 `iid` 的议题                                                                                                       |
| `search`            | string           | 否         | 根据议题的 `title` 和 `description` 进行搜索                                                                                               |
| `in`                | string           | 否         | 修改 `search` 属性的范围。`title`、`description`，或以逗号连接的字符串。默认为 `title,description`             |
| `created_after`     | datetime         | 否         | 返回在给定时间或之后创建的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `created_before`    | datetime         | 否         | 返回在给定时间或之前创建的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `updated_after`     | datetime         | 否         | 返回在给定时间或之后更新的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `updated_before`    | datetime         | 否         | 返回在给定时间或之前更新的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `confidential`      | boolean          | 否         | 筛选机密或公开议题。                                                                                                               |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/issues_statistics"
```

响应示例：

```json
{
  "statistics": {
    "counts": {
      "all": 20,
      "closed": 5,
      "opened": 15
    }
  }
}
```

<a id="retrieve-issues-statistics-for-a-group"></a>

## 获取群组的议题统计信息

检索指定群组中的议题统计信息。

```plaintext
GET /groups/:id/issues_statistics
GET /groups/:id/issues_statistics?labels=foo
GET /groups/:id/issues_statistics?labels=foo,bar
GET /groups/:id/issues_statistics?labels=foo,bar&state=opened
GET /groups/:id/issues_statistics?milestone=1.0.0
GET /groups/:id/issues_statistics?milestone=1.0.0&state=opened
GET /groups/:id/issues_statistics?iids[]=42&iids[]=43
GET /groups/:id/issues_statistics?search=issue+title+or+description
GET /groups/:id/issues_statistics?author_id=5
GET /groups/:id/issues_statistics?assignee_id=5
GET /groups/:id/issues_statistics?my_reaction_emoji=star
GET /groups/:id/issues_statistics?confidential=true
```

| 属性           | 类型             | 必需   | 描述                                                                                                                   |
| ------------------- | ---------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `id`                | integer or string   | 是        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                 |
| `labels`            | string           | 否         | 以逗号分隔的标签名称列表，议题必须包含所有标签才会被返回。`None` 列出所有没有标签的议题。`Any` 列出至少有一个标签的议题。 |
| `iids[]`            | integer array    | 否         | 仅返回具有给定 `iid` 的议题                                                                                 |
| `milestone`         | string           | 否         | 里程碑标题。`None` 列出所有没有里程碑的议题。`Any` 列出所有已分配里程碑的议题。       |
| `scope`             | string           | 否         | 返回给定范围的议题：`created_by_me`、`assigned_to_me` 或 `all`。 |
| `author_id`         | integer          | 否         | 返回由给定用户 `id` 创建的议题。与 `author_username` 互斥。可与 `scope=all` 或 `scope=assigned_to_me` 结合使用。 |
| `author_username`   | string           | 否         | 返回由给定 `username` 创建的议题。类似于 `author_id`，并与 `author_id` 互斥。 |
| `assignee_id`       | integer          | 否         | 返回分配给给定用户 `id` 的议题。与 `assignee_username` 互斥。`None` 返回未分配的议题。`Any` 返回已分配指派人的议题。 |
| `assignee_username` | string array     | 否         | 返回分配给给定 `username` 的议题。类似于 `assignee_id`，并与 `assignee_id` 互斥。在极狐GitLab 基础版中，`assignee_username` 数组应仅包含一个值，否则会返回无效参数错误。 |
| `my_reaction_emoji` | string           | 否         | 返回由认证用户通过给定 `emoji` 做出反应的议题。`None` 返回未获得反应的议题。`Any` 返回至少获得一个反应的议题。 |
| `search`            | string           | 否         | 根据群组议题的 `title` 和 `description` 进行搜索                                                                   |
| `created_after`     | datetime         | 否         | 返回在给定时间或之后创建的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `created_before`    | datetime         | 否         | 返回在给定时间或之前创建的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `updated_after`     | datetime         | 否         | 返回在给定时间或之后更新的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `updated_before`    | datetime         | 否         | 返回在给定时间或之前更新的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `confidential`      | boolean          | 否         | 筛选机密或公开议题。                                                                                         |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4/issues_statistics"
```

响应示例：

```json
{
  "statistics": {
    "counts": {
      "all": 20,
      "closed": 5,
      "opened": 15
    }
  }
}
```

<a id="retrieve-issues-statistics-for-a-project"></a>

## 获取项目的议题统计信息

检索指定项目中的议题统计信息。

```plaintext
GET /projects/:id/issues_statistics
GET /projects/:id/issues_statistics?labels=foo
GET /projects/:id/issues_statistics?labels=foo,bar
GET /projects/:id/issues_statistics?labels=foo,bar&state=opened
GET /projects/:id/issues_statistics?milestone=1.0.0
GET /projects/:id/issues_statistics?milestone=1.0.0&state=opened
GET /projects/:id/issues_statistics?iids[]=42&iids[]=43
GET /projects/:id/issues_statistics?search=issue+title+or+description
GET /projects/:id/issues_statistics?author_id=5
GET /projects/:id/issues_statistics?assignee_id=5
GET /projects/:id/issues_statistics?my_reaction_emoji=star
GET /projects/:id/issues_statistics?confidential=true
```

| 属性           | 类型             | 必需   | 描述                                                                                                                   |
| ------------------- | ---------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)               |
| `iids[]`            | integer array    | 否         | 仅返回具有给定 `iid` 的议题                                                                              |
| `labels`            | string           | 否         | 以逗号分隔的标签名称列表，议题必须包含所有标签才会被返回。`None` 列出所有没有标签的议题。`Any` 列出至少有一个标签的议题。 |
| `milestone`         | string           | 否         | 里程碑标题。`None` 列出所有没有里程碑的议题。`Any` 列出所有已分配里程碑的议题。       |
| `scope`             | string           | 否         | 返回给定范围的议题：`created_by_me`、`assigned_to_me` 或 `all`。 |
| `author_id`         | integer          | 否         | 返回由给定用户 `id` 创建的议题。与 `author_username` 互斥。可与 `scope=all` 或 `scope=assigned_to_me` 结合使用。 |
| `author_username`   | string           | 否         | 返回由给定 `username` 创建的议题。类似于 `author_id`，并与 `author_id` 互斥。 |
| `assignee_id`       | integer          | 否         | 返回分配给给定用户 `id` 的议题。与 `assignee_username` 互斥。`None` 返回未分配的议题。`Any` 返回已分配指派人的议题。 |
| `assignee_username` | string array     | 否         | 返回分配给给定 `username` 的议题。类似于 `assignee_id`，并与 `assignee_id` 互斥。在极狐GitLab 基础版中，`assignee_username` 数组应仅包含一个值，否则会返回无效参数错误。 |
| `my_reaction_emoji` | string           | 否         | 返回由认证用户通过给定 `emoji` 做出反应的议题。`None` 返回未获得反应的议题。`Any` 返回至少获得一个反应的议题。 |
| `search`            | string           | 否         | 根据项目议题的 `title` 和 `description` 进行搜索                                                                 |
| `created_after`     | datetime         | 否         | 返回在给定时间或之后创建的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `created_before`    | datetime         | 否         | 返回在给定时间或之前创建的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `updated_after`     | datetime         | 否         | 返回在给定时间或之后更新的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `updated_before`    | datetime         | 否         | 返回在给定时间或之前更新的议题。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`) |
| `confidential`      | boolean          | 否         | 筛选机密或公开议题。                                                                                         |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues_statistics"
```

响应示例：

```json
{
  "statistics": {
    "counts": {
      "all": 20,
      "closed": 5,
      "opened": 15
    }
  }
}
```