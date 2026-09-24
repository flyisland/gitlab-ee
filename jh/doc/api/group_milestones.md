---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组里程碑 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [群组里程碑](../user/project/milestones/_index.md)。

对于项目里程碑，使用 [项目里程碑 API](milestones.md)。

<a id="list-group-milestones"></a>

## 列出群组里程碑

返回群组里程碑列表。

```plaintext
GET /groups/:id/milestones
GET /groups/:id/milestones?iids[]=42
GET /groups/:id/milestones?iids[]=42&iids[]=43
GET /groups/:id/milestones?state=active
GET /groups/:id/milestones?state=closed
GET /groups/:id/milestones?title=1.0
GET /groups/:id/milestones?search=version
GET /groups/:id/milestones?search_title=17.3+17.4
GET /groups/:id/milestones?search_title=17.3%2017.4
GET /groups/:id/milestones?updated_before=2013-10-02T09%3A24%3A18Z
GET /groups/:id/milestones?updated_after=2013-10-02T09%3A24%3A18Z
GET /groups/:id/milestones?containing_date=2013-10-02T09%3A24%3A18Z
GET /groups/:id/milestones?start_date=2013-10-02T09%3A24%3A18Z&end_date=2013-11-02T09%3A24%3A18Z
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `iids[]` | integer 数组 | 否 | 只返回具有给定 `iid` 的里程碑。如果 `include_ancestors` 为 `true`，则忽略。 |
| `state` | string | 否 | 只返回 `active` 或 `closed` 状态的里程碑。 |
| `title` | string | 否 | 只返回具有给定 `title` 的里程碑（区分大小写）。 |
| `search` | string | 否 | 只返回标题或描述与提供的字符串匹配的里程碑（不区分大小写）。 |
| `search_title` | string | 否 | 只返回标题与提供的字符串匹配的里程碑（不区分大小写）。可以提供多个术语，用转义的空格分隔，使用 `+` 或 `%20`，术语之间进行 AND 运算。示例：`17.4+17.5` 将匹配子字符串 `17.4` 和 `17.5`（顺序不限）。在极狐GitLab 11.8 中引入。 |
| `include_parent_milestones` | boolean | 否 | 在极狐GitLab 16.7 中已弃用。请改用 `include_ancestors`。 |
| `include_ancestors` | boolean | 否 | 包含所有父群组的里程碑。 |
| `include_descendants` | boolean | 否 | 包含群组及其后代的里程碑。在极狐GitLab 16.7 中引入。 |
| `updated_before` | datetime | 否 | 只返回在给定日期时间之前更新的里程碑。预期格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。在极狐GitLab 15.10 中引入。 |
| `updated_after` | datetime | 否 | 只返回在给定日期时间之后更新的里程碑。预期格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。在极狐GitLab 15.10 中引入。 |
| `containing_date` | datetime | 否 | 只返回满足 `start_date <= containing_date <= due_date` 的里程碑。预期格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。在极狐GitLab 13.5 中引入。 |
| `start_date` | datetime | 否 | 只返回 `due_date >=` 提供的 `start_date` 的里程碑。预期格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。注意：仅在同时提供 `end_date` 时有效。在极狐GitLab 12.8 中引入。 |
| `end_date` | datetime | 否 | 只返回 `start_date <=` 提供的 `end_date` 的里程碑。预期格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。注意：仅在同时提供 `start_date` 时有效。在极狐GitLab 12.8 中引入。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/milestones"
```

示例响应：

```json
[
  {
    "id": 12,
    "iid": 3,
    "group_id": 16,
    "title": "10.0",
    "description": "Version",
    "due_date": "2013-11-29",
    "start_date": "2013-11-10",
    "state": "active",
    "updated_at": "2013-10-02T09:24:18Z",
    "created_at": "2013-10-02T09:24:18Z",
    "expired": false,
    "web_url": "https://gitlab.com/groups/gitlab-org/-/milestones/42"
  }
]
```

<a id="get-single-milestone"></a>

## 获取单个里程碑

获取单个群组里程碑。

```plaintext
GET /groups/:id/milestones/:milestone_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | integer | 是 | 群组里程碑的 ID |

<a id="create-new-milestone"></a>

## 创建新里程碑

创建一个新的群组里程碑。

```plaintext
POST /groups/:id/milestones
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `title` | string | 是 | 里程碑的标题 |
| `description` | string | 否 | 里程碑的描述 |
| `due_date` | date | 否 | 里程碑的到期日期，ISO 8601 格式 (`YYYY-MM-DD`) |
| `start_date` | date | 否 | 里程碑的开始日期，ISO 8601 格式 (`YYYY-MM-DD`) |

<a id="edit-milestone"></a>

## 编辑里程碑

更新现有的群组里程碑。

```plaintext
PUT /groups/:id/milestones/:milestone_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | integer | 是 | 群组里程碑的 ID |
| `title` | string | 否 | 里程碑的标题 |
| `description` | string | 否 | 里程碑的描述 |
| `due_date` | date | 否 | 里程碑的到期日期，ISO 8601 格式 (`YYYY-MM-DD`) |
| `start_date` | date | 否 | 里程碑的开始日期，ISO 8601 格式 (`YYYY-MM-DD`) |
| `state_event` | string | 否 | 里程碑的状态事件 _(`close` 或 `activate`)_ |

<a id="delete-group-milestone"></a>

## 删除群组里程碑

仅限具有群组开发者角色的用户。

```plaintext
DELETE /groups/:id/milestones/:milestone_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | integer | 是 | 群组里程碑的 ID |

<a id="get-all-issues-assigned-to-a-single-milestone"></a>

## 获取分配给单个里程碑的所有议题

获取分配给单个群组里程碑的所有议题。

```plaintext
GET /groups/:id/milestones/:milestone_id/issues
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | integer | 是 | 群组里程碑的 ID |

目前，此 API 端点不返回任何子群组的议题。如果您想要获取所有里程碑的议题，可以改用 [列出议题 API](issues.md#list-all-issues) 并针对特定里程碑进行过滤（例如，`GET /issues?milestone=1.0.0&state=opened`）。

<a id="get-all-merge-requests-assigned-to-a-single-milestone"></a>

## 获取分配给单个里程碑的所有合并请求

获取分配给单个群组里程碑的所有合并请求。

```plaintext
GET /groups/:id/milestones/:milestone_id/merge_requests
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | integer | 是 | 群组里程碑的 ID |

<a id="get-all-burndown-chart-events-for-a-single-milestone"></a>

## 获取单个里程碑的所有燃尽图事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

获取单个里程碑的所有燃尽图事件。

```plaintext
GET /groups/:id/milestones/:milestone_id/burndown_events
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | integer | 是 | 群组里程碑的 ID |

