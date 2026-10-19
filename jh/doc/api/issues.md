---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中议题的 REST API 文档。
title: 议题 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[议题](../user/project/issues/_index.md)。您可以：

- 创建、更新和删除议题。
- 管理议题元数据，例如指派人、标记、里程碑和时间跟踪。
- 交叉引用议题和合并请求。
- 跟踪议题在项目和史诗之间的移动和提升。
- 通过授权检查控制访问和可见性。

如果用户不是私有项目的成员，对该项目发出的 `GET` 请求将返回 `404` 状态码。

此 API 中的响应已[分页](rest/_index.md#pagination)，默认返回 20 条结果。

> [!note]
> `references.relative` 属性是相对于所请求议题所在的群组或项目。
> 当从其项目获取议题时，`relative` 格式与 `short` 格式相同。
> 当跨群组或项目请求时，它应与 `full` 格式相同。

<a id="list-all-issues"></a>

## 列出所有议题

列出认证用户有权访问的所有议题。默认情况下，仅返回当前用户创建的议题。要列出所有议题，请使用参数 `scope=all`。

```plaintext
GET /issues
GET /issues?assignee_id=5
GET /issues?author_id=5
GET /issues?confidential=true
GET /issues?iids[]=42&iids[]=43
GET /issues?labels=foo
GET /issues?labels=foo,bar
GET /issues?labels=foo,bar&state=opened
GET /issues?milestone=1.0.0
GET /issues?milestone=1.0.0&state=opened
GET /issues?my_reaction_emoji=star
GET /issues?search=foo&in=title
GET /issues?state=closed
GET /issues?state=opened
```

支持的属性：

| 属性                       | 类型          | 必填 | 描述                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|---------------------------------|---------------| ---------- |------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `assignee_id`                   | integer       | 否         | 返回分配给给定用户 `id` 的议题。与 `assignee_username` 互斥。`None` 返回未分配的议题。`Any` 返回有指派人的议题。                                                                                                                                                                                                                                                                                                                                                                                                   |
| `assignee_username`             | string array  | 否         | 返回分配给给定 `username` 的议题。与 `assignee_id` 类似，且与 `assignee_id` 互斥。在极狐GitLab 基础版中，`assignee_username` 数组应只包含一个值。否则，将返回无效参数错误。仅返回分配给所有传入用户的议题。 |
| `author_id`                     | integer       | 否         | 返回由给定用户 `id` 创建的议题。与 `author_username` 互斥。与 `scope=all` 或 `scope=assigned_to_me` 结合使用。                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `author_username`               | string        | 否         | 返回由给定 `username` 创建的议题。与 `author_id` 类似，且与 `author_id` 互斥。                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `confidential`                  | boolean       | 否         | 过滤机密或公开议题。                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `created_after`                 | datetime      | 否         | 返回在给定时间或之后创建的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `created_before`                | datetime      | 否         | 返回在给定时间或之前创建的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `due_date`                      | string        | 否         | 返回没有截止日期、已逾期，或截止日期在本周、本月，或介于两周前和下周之间的议题。接受：`0`（无截止日期）、`any`、`today`、`tomorrow`、`overdue`、`week`、`month`、`next_month_and_previous_two_weeks`。                                                                                                                                                                                                                                                                                                        |
| `epic_id`        | integer       | 否         | 返回与给定史诗 ID 关联的议题。`None` 返回未与史诗关联的议题。`Any` 返回与史诗关联的议题。仅限专业版和旗舰版。                                                                                                                                                                                                                                                                                                                                                                         |
| `health_status`  | string        | 否         | 返回具有指定 `health_status` 的议题。`None` 返回未分配健康状态的议题，`Any` 返回已分配健康状态的议题。仅限旗舰版。                                                                                                                                                                                                                |
| `iids[]`                        | integer array | 否         | 仅返回具有给定 `iid` 的议题。                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `in`                            | string        | 否         | 修改 `search` 属性的范围。`title`、`description`，或用逗号连接它们的字符串。默认值为 `title,description`。                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `issue_type`                    | string        | 否         | 过滤到给定类型的议题。可以是 `issue`、`incident`、`test_case` 或 `task` 之一。                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `iteration_id`                  | integer       | 否         | 返回分配给给定迭代 ID 的议题。`None` 返回不属于任何迭代的议题。`Any` 返回属于某个迭代的议题。与 `iteration_title` 互斥。仅限专业版和旗舰版。                                                                                                                                                                                                                                                                                                                                    |
| `iteration_title`               | string        | 否       | 返回分配给具有给定标题的迭代的议题。与 `iteration_id` 类似，且与 `iteration_id` 互斥。仅限专业版和旗舰版。                                                                                                                                                                                                                                                                                                                                                                                                         |
| `labels`                        | string        | 否         | 逗号分隔的标记名称列表，议题必须包含所有标记才会被返回。`None` 列出所有无标记的议题。`Any` 列出所有至少有一个标记的议题。`No+Label`（已弃用）列出所有无标记的议题。预定义名称不区分大小写。                                                                                                                                                                                                                                                                                               |
| `milestone_id`                  | string        | 否         | 返回分配给具有给定时间盒值（`None`、`Any`、`Upcoming` 和 `Started`）的里程碑的议题。`None` 列出所有无里程碑的议题。`Any` 列出所有已分配里程碑的议题。`Upcoming` 列出所有分配给未来到期里程碑的议题。`Started` 列出所有分配给已开启、已开始里程碑的议题。`Upcoming` 和 `Started` 的逻辑与 [GraphQL API](../user/project/milestones/_index.md#special-milestone-filters) 中使用的逻辑不同。`milestone` 和 `milestone_id` 互斥。 |
| `milestone`                     | string        | 否         | 里程碑标题。`None` 列出所有无里程碑的议题。`Any` 列出所有已分配里程碑的议题。使用 `None` 或 `Any` 将[在未来弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/336044)。请改用 `milestone_id` 属性。`milestone` 和 `milestone_id` 互斥。                                                                                                                                                                                                                                   |
| `my_reaction_emoji`             | string        | 否         | 返回认证用户对给定 `emoji` 做出反应的议题。`None` 返回未给予反应的议题。`Any` 返回至少给予一个反应的议题。                                                                                                                                                                                                                                                                                                                                                                                                    |
| `non_archived`                  | boolean       | 否         | 仅返回非归档项目中的议题。如果为 `false`，则响应返回归档和非归档项目中的议题。默认值为 `true`。                                                                                                                                                                                                                                                                                                                                                                                                                |
| `not`                           | Hash          | 否         | 返回与提供的参数不匹配的议题。接受：`assignee_id`、`assignee_username`、`author_id`、`author_username`、`iids`、`iteration_id`、`iteration_title`、`labels`、`milestone`、`milestone_id` 和 `weight`。                                                                                                                                                                                                                                                                                                                                   |
| `order_by`                      | string        | 否         | 返回按 `created_at`、`due_date`、`label_priority`、`milestone_due`、`popularity`、`priority`、`relative_position`、`title`、`updated_at` 或 `weight` 字段排序的议题。默认值为 `created_at`。                                                                                                                                                                                                                                                                                                                                                               |
| `scope`                         | string        | 否         | 返回给定范围的议题：`created_by_me`、`assigned_to_me` 或 `all`。默认为 `created_by_me`。                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `search`                        | string        | 否         | 根据议题的 `title` 和 `description` 搜索议题。                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `sort`                          | string        | 否         | 返回按 `asc` 或 `desc` 顺序排序的议题。默认值为 `desc`。                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `state`                         | string        | 否         | 返回 `all` 议题或仅返回 `opened` 或 `closed` 的议题。                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `updated_after`                 | datetime      | 否         | 返回在给定时间或之后更新的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `updated_before`                | datetime      | 否         | 返回在给定时间或之前更新的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `weight`                        | integer       | 否         | 返回具有指定 `weight` 的议题。`None` 返回未分配权重的议题。`Any` 返回已分配权重的议题。仅限专业版和旗舰版。                                                                                                                                                                                                                                                                                                                                                                                                      |
| `with_labels_details`           | boolean       | 否         | 如果为 `true`，则响应会为 labels 字段中的每个标记返回更多详细信息：`:name`、`:color`、`:description`、`:description_html`、`:text_color`。默认值为 `false`。                                                                                                                                                                                                                                                                                                                                                                                                |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/issues"
```

示例响应：

```json
[
   {
      "state" : "opened",
      "description" : "Ratione dolores corrupti mollitia soluta quia.",
      "author" : {
         "state" : "active",
         "id" : 18,
         "web_url" : "https://gitlab.example.com/eileen.lowe",
         "name" : "Alexandra Bashirian",
         "avatar_url" : null,
         "username" : "eileen.lowe"
      },
      "milestone" : {
         "project_id" : 1,
         "description" : "Ducimus nam enim ex consequatur cumque ratione.",
         "state" : "closed",
         "due_date" : null,
         "iid" : 2,
         "created_at" : "2016-01-04T15:31:39.996Z",
         "title" : "v4.0",
         "id" : 17,
         "updated_at" : "2016-01-04T15:31:39.996Z"
      },
      "project_id" : 1,
      "assignees" : [{
         "state" : "active",
         "id" : 1,
         "name" : "Administrator",
         "web_url" : "https://gitlab.example.com/root",
         "avatar_url" : null,
         "username" : "root"
      }],
      "assignee" : {
         "state" : "active",
         "id" : 1,
         "name" : "Administrator",
         "web_url" : "https://gitlab.example.com/root",
         "avatar_url" : null,
         "username" : "root"
      },
      "type" : "ISSUE",
      "updated_at" : "2016-01-04T15:31:51.081Z",
      "closed_at" : null,
      "closed_by" : null,
      "id" : 76,
      "title" : "Consequatur vero maxime deserunt laboriosam est voluptas dolorem.",
      "created_at" : "2016-01-04T15:31:51.081Z",
      "moved_to_id" : null,
      "iid" : 6,
      "labels" : ["foo", "bar"],
      "upvotes": 4,
      "downvotes": 0,
      "merge_requests_count": 0,
      "user_notes_count": 1,
      "start_date": null,
      "due_date": "2016-07-22",
      "imported":false,
      "imported_from": "none",
      "web_url": "http://gitlab.example.com/my-group/my-project/issues/6",
      "references": {
        "short": "#6",
        "relative": "my-group/my-project#6",
        "full": "my-group/my-project#6"
      },
      "time_stats": {
         "time_estimate": 0,
         "total_time_spent": 0,
         "human_time_estimate": null,
         "human_total_time_spent": null
      },
      "has_tasks": true,
      "task_status": "10 of 15 tasks completed",
      "confidential": false,
      "discussion_locked": false,
      "issue_type": "issue",
      "severity": "UNKNOWN",
      "_links":{
         "self":"http://gitlab.example.com/api/v4/projects/1/issues/76",
         "notes":"http://gitlab.example.com/api/v4/projects/1/issues/76/notes",
         "award_emoji":"http://gitlab.example.com/api/v4/projects/1/issues/76/award_emoji",
         "project":"http://gitlab.example.com/api/v4/projects/1",
         "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
      },
      "task_completion_status":{
         "count":0,
         "completed_count":0
      }
   }
]
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
[
   {
      "state" : "opened",
      "description" : "Ratione dolores corrupti mollitia soluta quia.",
      "weight": null,
      ...
   }
]
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `iteration` 属性：

```json
{
   "iteration": {
      "id":90,
      "iid":4,
      "sequence":2,
      "group_id":162,
      "title":null,
      "description":null,
      "state":2,
      "created_at":"2022-03-14T05:21:11.929Z",
      "updated_at":"2022-03-14T05:21:11.929Z",
      "start_date":"2022-03-08",
      "due_date":"2022-03-14",
      "web_url":"https://gitlab.com/groups/my-group/-/iterations/90"
   }
   ...
}
```

由极狐GitLab 旗舰版用户创建的议题包含 `health_status` 属性：

```json
[
   {
      "state" : "opened",
      "description" : "Ratione dolores corrupti mollitia soluta quia.",
      "health_status": "on_track",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以
> 符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，并[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="list-all-group-issues"></a>

## 列出群组的所有议题

列出指定群组的所有议题。

如果群组是私有的，您必须提供凭据进行授权。
推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /groups/:id/issues
GET /groups/:id/issues?assignee_id=5
GET /groups/:id/issues?author_id=5
GET /groups/:id/issues?confidential=true
GET /groups/:id/issues?iids[]=42&iids[]=43
GET /groups/:id/issues?labels=foo
GET /groups/:id/issues?labels=foo,bar
GET /groups/:id/issues?labels=foo,bar&state=opened
GET /groups/:id/issues?milestone=1.0.0
GET /groups/:id/issues?milestone=1.0.0&state=opened
GET /groups/:id/issues?my_reaction_emoji=star
GET /groups/:id/issues?search=issue+title+or+description
GET /groups/:id/issues?state=closed
GET /groups/:id/issues?state=opened
```

支持的属性：

| 属性           | 类型             | 必填   | 描述                                                                                                                   |
| ------------------- | ---------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `id`                | integer or string   | 是        | 群组的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                 |
| `assignee_id`       | integer          | 否         | 返回分配给给定用户 `id` 的议题。与 `assignee_username` 互斥。`None` 返回未分配的议题。`Any` 返回有指派人的议题。 |
| `assignee_username` | string array     | 否         | 返回分配给给定 `username` 的议题。与 `assignee_id` 类似，且与 `assignee_id` 互斥。在极狐GitLab 基础版中，`assignee_username` 数组应只包含一个值。否则，将返回无效参数错误。仅返回分配给所有传入用户的议题。 |
| `author_id`         | integer          | 否         | 返回由给定用户 `id` 创建的议题。与 `author_username` 互斥。与 `scope=all` 或 `scope=assigned_to_me` 结合使用。 |
| `author_username`   | string           | 否         | 返回由给定 `username` 创建的议题。与 `author_id` 类似，且与 `author_id` 互斥。 |
| `confidential`     | boolean          | 否         | 过滤机密或公开议题。                                                                                         |
| `created_after`     | datetime         | 否         | 返回在给定时间或之后创建的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before`    | datetime         | 否         | 返回在给定时间或之前创建的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `due_date`          | string           | 否         | 返回没有截止日期、已逾期，或截止日期在本周、本月，或介于两周前和下周之间的议题。接受：`0`（无截止日期）、`any`、`today`、`tomorrow`、`overdue`、`week`、`month`、`next_month_and_previous_two_weeks`。 |
| `epic_id`           | integer      | 否         | 返回与给定史诗 ID 关联的议题。`None` 返回未与史诗关联的议题。`Any` 返回与史诗关联的议题。仅限专业版和旗舰版。 |
| `iids[]`            | integer array    | 否         | 仅返回具有给定 `iid` 的议题。                                                                                 |
| `issue_type`        | string           | 否         | 过滤到给定类型的议题。可以是 `issue`、`incident`、`test_case` 或 `task` 之一。 |
| `iteration_id`      | integer | 否         | 返回分配给给定迭代 ID 的议题。`None` 返回不属于任何迭代的议题。`Any` 返回属于某个迭代的议题。与 `iteration_title` 互斥。仅限专业版和旗舰版。 |
| `iteration_title`   | string | 否       | 返回分配给具有给定标题的迭代的议题。与 `iteration_id` 类似，且与 `iteration_id` 互斥。仅限专业版和旗舰版。|
| `labels`            | string           | 否         | 逗号分隔的标记名称列表，议题必须包含所有标记才会被返回。`None` 列出所有无标记的议题。`Any` 列出所有至少有一个标记的议题。`No+Label`（已弃用）列出所有无标记的议题。预定义名称不区分大小写。 |
| `milestone`         | string           | 否         | 里程碑标题。`None` 列出所有无里程碑的议题。`Any` 列出所有已分配里程碑的议题。       |
| `my_reaction_emoji` | string           | 否         | 返回认证用户对给定 `emoji` 做出反应的议题。`None` 返回未给予反应的议题。`Any` 返回至少给予一个反应的议题。 |
| `non_archived`      | boolean          | 否         | 返回非归档项目中的议题。默认为 true。 |
| `not`               | Hash             | 否         | 返回与提供的参数不匹配的议题。接受：`labels`、`milestone`、`author_id`、`author_username`、`assignee_id`、`assignee_username`、`my_reaction_emoji`、`search`、`in`。 |
| `order_by`          | string           | 否         | 返回按 `created_at`、`updated_at`、`priority`、`due_date`、`relative_position`、`label_priority`、`milestone_due`、`popularity`、`weight` 字段排序的议题。默认值为 `created_at`                                                               |
| `scope`             | string           | 否         | 返回给定范围的议题：`created_by_me`、`assigned_to_me` 或 `all`。默认为 `all`。 |
| `search`            | string           | 否         | 根据群组议题的 `title` 和 `description` 搜索议题。                                                                   |
| `sort`              | string           | 否         | 返回按 `asc` 或 `desc` 顺序排序的议题。默认值为 `desc`。                                                              |
| `state`             | string           | 否         | 返回所有议题或仅返回 `opened` 或 `closed` 的议题。                                                                 |
| `updated_after`     | datetime         | 否         | 返回在给定时间或之后更新的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `updated_before`    | datetime         | 否         | 返回在给定时间或之前更新的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `weight` | integer       | 否         | 返回具有指定 `weight` 的议题。`None` 返回未分配权重的议题。`Any` 返回已分配权重的议题。仅限专业版和旗舰版。 |
| `with_labels_details` | boolean        | 否         | 如果为 `true`，则响应会为 labels 字段中的每个标记返回更多详细信息：`:name`、`:color`、`:description`、`:description_html`、`:text_color`。默认值为 `false`。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4/issues"
```

示例响应：

```json
[
   {
      "project_id" : 4,
      "milestone" : {
         "due_date" : null,
         "project_id" : 4,
         "state" : "closed",
         "description" : "Rerum est voluptatem provident consequuntur molestias similique ipsum dolor.",
         "iid" : 3,
         "id" : 11,
         "title" : "v3.0",
         "created_at" : "2016-01-04T15:31:39.788Z",
         "updated_at" : "2016-01-04T15:31:39.788Z"
      },
      "author" : {
         "state" : "active",
         "web_url" : "https://gitlab.example.com/root",
         "avatar_url" : null,
         "username" : "root",
         "id" : 1,
         "name" : "Administrator"
      },
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "state" : "closed",
      "iid" : 1,
      "assignees" : [{
         "avatar_url" : null,
         "web_url" : "https://gitlab.example.com/lennie",
         "state" : "active",
         "username" : "lennie",
         "id" : 9,
         "name" : "Dr. Luella Kovacek"
      }],
      "assignee" : {
         "avatar_url" : null,
         "web_url" : "https://gitlab.example.com/lennie",
         "state" : "active",
         "username" : "lennie",
         "id" : 9,
         "name" : "Dr. Luella Kovacek"
      },
      "type" : "ISSUE",
      "labels" : ["foo", "bar"],
      "upvotes": 4,
      "downvotes": 0,
      "merge_requests_count": 0,
      "id" : 41,
      "title" : "Ut commodi ullam eos dolores perferendis nihil sunt.",
      "updated_at" : "2016-01-04T15:31:46.176Z",
      "created_at" : "2016-01-04T15:31:46.176Z",
      "closed_at" : null,
      "closed_by" : null,
      "user_notes_count": 1,
      "due_date": null,
      "imported": false,
      "imported_from": "none",
      "web_url": "http://gitlab.example.com/my-group/my-project/issues/1",
      "references": {
        "short": "#1",
        "relative": "my-project#1",
        "full": "my-group/my-project#1"
      },
      "time_stats": {
         "time_estimate": 0,
         "total_time_spent": 0,
         "human_time_estimate": null,
         "human_total_time_spent": null
      },
      "has_tasks": true,
      "task_status": "10 of 15 tasks completed",
      "confidential": false,
      "discussion_locked": false,
      "issue_type": "issue",
      "severity": "UNKNOWN",
      "_links":{
         "self":"http://gitlab.example.com/api/v4/projects/4/issues/41",
         "notes":"http://gitlab.example.com/api/v4/projects/4/issues/41/notes",
         "award_emoji":"http://gitlab.example.com/api/v4/projects/4/issues/41/award_emoji",
         "project":"http://gitlab.example.com/api/v4/projects/4",
         "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
      },
      "task_completion_status":{
         "count":0,
         "completed_count":0
      }
   }
]
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "weight": null,
      ...
   }
]
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

由极狐GitLab 旗舰版用户创建的议题包含 `health_status` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "at_risk",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，并[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="list-all-project-issues"></a>

## 列出项目的所有议题

列出指定项目的所有议题。

如果项目是私有的，您需要提供凭据进行授权。
推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /projects/:id/issues
GET /projects/:id/issues?assignee_id=5
GET /projects/:id/issues?author_id=5
GET /projects/:id/issues?confidential=true
GET /projects/:id/issues?iids[]=42&iids[]=43
GET /projects/:id/issues?labels=foo
GET /projects/:id/issues?labels=foo,bar
GET /projects/:id/issues?labels=foo,bar&state=opened
GET /projects/:id/issues?milestone=1.0.0
GET /projects/:id/issues?milestone=1.0.0&state=opened
GET /projects/:id/issues?my_reaction_emoji=star
GET /projects/:id/issues?search=issue+title+or+description
GET /projects/:id/issues?state=closed
GET /projects/:id/issues?state=opened
```

支持的属性：

| 属性             | 类型           | 必填 | 描述 |
| --------------------- | -------------- | -------- | ----------- |
| `id`                  | integer or string | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `assignee_id`         | integer        | 否       | 返回分配给给定用户 `id` 的议题。与 `assignee_username` 互斥。`None` 返回未分配的议题。`Any` 返回有指派人的议题。 |
| `assignee_username`   | string array   | 否       | 返回分配给给定 `username` 的议题。与 `assignee_id` 类似，且与 `assignee_id` 互斥。在极狐GitLab 基础版中，`assignee_username` 数组应只包含一个值。否则，将返回无效参数错误。仅返回分配给所有传入用户的议题。 |
| `author_id`           | integer        | 否       | 返回由给定用户 `id` 创建的议题。与 `author_username` 互斥。与 `scope=all` 或 `scope=assigned_to_me` 结合使用。 |
| `author_username`     | string         | 否       | 返回由给定 `username` 创建的议题。与 `author_id` 类似，且与 `author_id` 互斥。 |
| `confidential`        | boolean        | 否       | 过滤机密或公开议题。 |
| `created_after`       | datetime       | 否       | 返回在给定时间或之后创建的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before`      | datetime       | 否       | 返回在给定时间或之前创建的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `due_date`            | string         | 否       | 返回没有截止日期、已逾期，或截止日期在本周、本月，或介于两周前和下周之间的议题。接受：`0`（无截止日期）、`any`、`today`、`tomorrow`、`overdue`、`week`、`month`、`next_month_and_previous_two_weeks`。 |
| `epic_id`             | integer        | 否       | 返回与给定史诗 ID 关联的议题。`None` 返回未与史诗关联的议题。`Any` 返回与史诗关联的议题。仅限专业版和旗舰版。 |
| `iids[]`              | integer array  | 否       | 仅返回具有给定 `iid` 的议题。 |
| `issue_type`          | string         | 否       | 过滤到给定类型的议题。可以是 `issue`、`incident`、`test_case` 或 `task` 之一。 |
| `iteration_id`        | integer        | 否       | 返回分配给给定迭代 ID 的议题。`None` 返回不属于任何迭代的议题。`Any` 返回属于某个迭代的议题。与 `iteration_title` 互斥。仅限专业版和旗舰版。 |
| `iteration_title`     | string         | 否       | 返回分配给具有给定标题的迭代的议题。与 `iteration_id` 类似，且与 `iteration_id` 互斥。仅限专业版和旗舰版。 |
| `labels`              | string         | 否       | 逗号分隔的标记名称列表，议题必须包含所有标记才会被返回。`None` 列出所有无标记的议题。`Any` 列出所有至少有一个标记的议题。`No+Label`（已弃用）列出所有无标记的议题。预定义名称不区分大小写。 |
| `milestone`           | string         | 否       | 里程碑标题。`None` 列出所有无里程碑的议题。`Any` 列出所有已分配里程碑的议题。 |
| `my_reaction_emoji`   | string         | 否       | 返回认证用户对给定 `emoji` 做出反应的议题。`None` 返回未给予反应的议题。`Any` 返回至少给予一个反应的议题。 |
| `not`                 | Hash           | 否       | 返回与提供的参数不匹配的议题。接受：`labels`、`milestone`、`author_id`、`author_username`、`assignee_id`、`assignee_username`、`my_reaction_emoji`、`search`、`in`。 |
| `order_by`            | string         | 否       | 返回按 `created_at`、`updated_at`、`priority`、`due_date`、`relative_position`、`label_priority`、`milestone_due`、`popularity`、`weight` 字段排序的议题。默认值为 `created_at`。 |
| `scope`               | string         | 否       | 返回给定范围的议题：`created_by_me`、`assigned_to_me` 或 `all`。默认为 `all`。 |
| `search`              | string         | 否       | 根据项目议题的 `title` 和 `description` 搜索议题。 |
| `sort`                | string         | 否       | 返回按 `asc` 或 `desc` 顺序排序的议题。默认值为 `desc`。 |
| `state`               | string         | 否       | 返回所有议题或仅返回 `opened` 或 `closed` 的议题。 |
| `updated_after`       | datetime       | 否       | 返回在给定时间或之后更新的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `updated_before`      | datetime       | 否       | 返回在给定时间或之前更新的议题。期望使用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `weight`              | integer        | 否       | 返回具有指定 `weight` 的议题。`None` 返回未分配权重的议题。`Any` 返回已分配权重的议题。仅限专业版和旗舰版。 |
| `with_labels_details` | boolean        | 否       | 如果为 `true`，则响应会为 labels 字段中的每个标记返回更多详细信息：`:name`、`:color`、`:description`、`:description_html`、`:text_color`。默认值为 `false`。 |
| `cursor`              | string         | 否       | 用于键集分页的参数。 |

此端点支持基于偏移量和基于[键集](rest/_index.md#keyset-based-pagination)的分页。当请求连续的结果页时，应使用基于键集的分页。

阅读更多关于[分页](rest/_index.md#pagination)的信息。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues"
```

示例响应：

```json
[
   {
      "project_id" : 4,
      "milestone" : {
         "due_date" : null,
         "project_id" : 4,
         "state" : "closed",
         "description" : "Rerum est voluptatem provident consequuntur molestias similique ipsum dolor.",
         "iid" : 3,
         "id" : 11,
         "title" : "v3.0",
         "created_at" : "2016-01-04T15:31:39.788Z",
         "updated_at" : "2016-01-04T15:31:39.788Z"
      },
      "author" : {
         "state" : "active",
         "web_url" : "https://gitlab.example.com/root",
         "avatar_url" : null,
         "username" : "root",
         "id" : 1,
         "name" : "Administrator"
      },
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "state" : "closed",
      "iid" : 1,
      "assignees" : [{
         "avatar_url" : null,
         "web_url" : "https://gitlab.example.com/lennie",
         "state" : "active",
         "username" : "lennie",
         "id" : 9,
         "name" : "Dr. Luella Kovacek"
      }],
      "assignee" : {
         "avatar_url" : null,
         "web_url" : "https://gitlab.example.com/lennie",
         "state" : "active",
         "username" : "lennie",
         "id" : 9,
         "name" : "Dr. Luella Kovacek"
      },
      "type" : "ISSUE",
      "labels" : ["foo", "bar"],
      "upvotes": 4,
      "downvotes": 0,
      "merge_requests_count": 0,
      "id" : 41,
      "title" : "Ut commodi ullam eos dolores perferendis nihil sunt.",
      "updated_at" : "2016-01-04T15:31:46.176Z",
      "created_at" : "2016-01-04T15:31:46.176Z",
      "closed_at" : "2016-01-05T15:31:46.176Z",
      "closed_by" : {
         "state" : "active",
         "web_url" : "https://gitlab.example.com/root",
         "avatar_url" : null,
         "username" : "root",
         "id" : 1,
         "name" : "Administrator"
      },
      "user_notes_count": 1,
      "due_date": "2016-07-22",
      "imported": false,
      "imported_from": "none",
      "web_url": "http://gitlab.example.com/my-group/my-project/issues/1",
      "references": {
        "short": "#1",
        "relative": "#1",
        "full": "my-group/my-project#1"
      },
      "time_stats": {
         "time_estimate": 0,
         "total_time_spent": 0,
         "human_time_estimate": null,
         "human_total_time_spent": null
      },
      "has_tasks": true,
      "task_status": "10 of 15 tasks completed",
      "confidential": false,
      "discussion_locked": false,
      "issue_type": "issue",
      "severity": "UNKNOWN",
      "_links":{
         "self":"http://gitlab.example.com/api/v4/projects/4/issues/41",
         "notes":"http://gitlab.example.com/api/v4/projects/4/issues/41/notes",
         "award_emoji":"http://gitlab.example.com/api/v4/projects/4/issues/41/award_emoji",
         "project":"http://gitlab.example.com/api/v4/projects/4",
         "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
      },
      "task_completion_status":{
         "count":0,
         "completed_count":0
      }
   }
]
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "weight": null,
      ...
   }
]
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

由极狐GitLab 旗舰版用户创建的议题包含 `health_status` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "at_risk",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，并[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="retrieve-an-issue"></a>

## 检索一个议题

仅限管理员。

检索指定的议题。

推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /issues/:id
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | integer | 是      | 议题的 ID。                 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/issues/41"
```

示例响应：

```json
{
  "id": 1,
  "milestone": {
    "due_date": null,
    "project_id": 4,
    "state": "closed",
    "description": "Rerum est voluptatem provident consequuntur molestias similique ipsum dolor.",
    "iid": 3,
    "id": 11,
    "title": "v3.0",
    "created_at": "2016-01-04T15:31:39.788Z",
    "updated_at": "2016-01-04T15:31:39.788Z",
    "closed_at": "2016-01-05T15:31:46.176Z"
  },
  "author": {
    "state": "active",
    "web_url": "https://gitlab.example.com/root",
    "avatar_url": null,
    "username": "root",
    "id": 1,
    "name": "Administrator"
  },
  "description": "Omnis vero earum sunt corporis dolor et placeat.",
  "state": "closed",
  "iid": 1,
  "assignees": [
    {
      "avatar_url": null,
      "web_url": "https://gitlab.example.com/lennie",
      "state": "active",
      "username": "lennie",
      "id": 9,
      "name": "Dr. Luella Kovacek"
    }
  ],
  "assignee": {
    "avatar_url": null,
    "web_url": "https://gitlab.example.com/lennie",
    "state": "active",
    "username": "lennie",
    "id": 9,
    "name": "Dr. Luella Kovacek"
  },
  "type": "ISSUE",
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "merge_requests_count": 0,
  "title": "Ut commodi ullam eos dolores perferendis nihil sunt.",
  "updated_at": "2016-01-04T15:31:46.176Z",
  "created_at": "2016-01-04T15:31:46.176Z",
  "closed_at": null,
  "closed_by": null,
  "subscribed": false,
  "user_notes_count": 1,
  "due_date": null,
  "imported": false,
  "imported_from": "none",
  "web_url": "http://example.com/my-group/my-project/issues/1",
  "references": {
    "short": "#1",
    "relative": "#1",
    "full": "my-group/my-project#1"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "confidential": false,
  "discussion_locked": false,
  "issue_type": "issue",
  "severity": "UNKNOWN",
  "task_completion_status": {
    "count": 0,
    "completed_count": 0
  },
  "weight": null,
  "has_tasks": false,
  "_links": {
    "self": "http://gitlab.example:3000/api/v4/projects/1/issues/1",
    "notes": "http://gitlab.example:3000/api/v4/projects/1/issues/1/notes",
    "award_emoji": "http://gitlab.example:3000/api/v4/projects/1/issues/1/award_emoji",
    "project": "http://gitlab.example:3000/api/v4/projects/1",
    "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
  },
  "moved_to_id": null,
  "service_desk_reply_to": "service.desk@gitlab.com"
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "weight": null,
   ...
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic": {
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

[极狐GitLab 旗舰版](https://gitlab.cn/pricing) 的用户还可以看到 `health_status`
属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "on_track",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以
> 符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，并[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="retrieve-a-project-issue"></a>

## 检索一个项目议题

检索项目的指定议题。

如果项目是私有的或议题是机密的，您需要提供凭据进行授权。
推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /projects/:id/issues/:issue_iid
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | integer or string | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | integer | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues/41"
```

示例响应：

```json
{
   "project_id" : 4,
   "milestone" : {
      "due_date" : null,
      "project_id" : 4,
      "state" : "closed",
      "description" : "Rerum est voluptatem provident consequuntur molestias similique ipsum dolor.",
      "iid" : 3,
      "id" : 11,
      "title" : "v3.0",
      "created_at" : "2016-01-04T15:31:39.788Z",
      "updated_at" : "2016-01-04T15:31:39.788Z",
      "closed_at" : "2016-01-05T15:31:46.176Z"
   },
   "author" : {
      "state" : "active",
      "web_url" : "https://gitlab.example.com/root",
      "avatar_url" : null,
      "username" : "root",
      "id" : 1,
      "name" : "Administrator"
   },
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "state" : "closed",
   "iid" : 1,
   "assignees" : [{
      "avatar_url" : null,
      "web_url" : "https://gitlab.example.com/lennie",
      "state" : "active",
      "username" : "lennie",
      "id" : 9,
      "name" : "Dr. Luella Kovacek"
   }],
   "assignee" : {
      "avatar_url" : null,
      "web_url" : "https://gitlab.example.com/lennie",
      "state" : "active",
      "username" : "lennie",
      "id" : 9,
      "name" : "Dr. Luella Kovacek"
   },
   "type" : "ISSUE",
   "labels" : [],
   "upvotes": 4,
   "downvotes": 0,
   "merge_requests_count": 0,
   "id" : 41,
   "title" : "Ut commodi ullam eos dolores perferendis nihil sunt.",
   "updated_at" : "2016-01-04T15:31:46.176Z",
   "created_at" : "2016-01-04T15:31:46.176Z",
   "closed_at" : null,
   "closed_by" : null,
   "subscribed": false,
   "user_notes_count": 1,
   "due_date": null,
   "imported": false,
   "imported_from": "none",
   "web_url": "http://gitlab.example.com/my-group/my-project/issues/1",
   "references": {
     "short": "#1",
     "relative": "#1",
     "full": "my-group/my-project#1"
   },
   "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
   },
   "confidential": false,
   "discussion_locked": false,
   "issue_type": "issue",
   "severity": "UNKNOWN",
   "_links": {
      "self": "http://gitlab.example.com/api/v4/projects/1/issues/2",
      "notes": "http://gitlab.example.com/api/v4/projects/1/issues/2/notes",
      "award_emoji": "http://gitlab.example.com/api/v4/projects/1/issues/2/award_emoji",
      "project": "http://gitlab.example.com/api/v4/projects/1",
      "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
   },
   "task_completion_status":{
      "count":0,
      "completed_count":0
   }
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "weight": null,
   ...
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

[极狐GitLab 旗舰版](https://gitlab.cn/pricing) 的用户还可以看到 `health_status`
属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "on_track",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，并[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="create-an-issue"></a>

## 创建一个议题

为指定项目创建一个议题。

```plaintext
POST /projects/:id/issues
```

支持的属性：

| 属性                                 | 类型           | 必填 | 描述  |
|-------------------------------------------|----------------|----------|--------------|
| `id`                                      | integer or string | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `assignee_id`                             | integer        | 否       | 要将议题分配给的用户的 ID。仅出现在极狐GitLab 基础版中。 |
| `assignee_ids`                            | integer array  | 否       | 要将议题分配给的用户的 ID。仅限专业版和旗舰版。|
| `confidential`                            | boolean        | 否       | 将议题设置为机密。默认值为 `false`。  |
| `created_at`                              | string         | 否       | 议题的创建时间。日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限。 |
| `description`                             | string         | 否       | 议题的描述。限制为 1,048,576 个字符。 |
| `discussion_to_resolve`                   | string         | 否       | 要解决的讨论的 ID。这将使用默认描述填充议题，并将讨论标记为已解决。与 `merge_request_to_resolve_discussions_of` 结合使用。 |
| `due_date`                                | string         | 否       | 截止日期。日期时间字符串，格式为 `YYYY-MM-DD`，例如 `2016-03-11`。 |
| `epic_id`                                 | integer | 否 | 要将议题添加到的史诗的 ID。有效值大于或等于 0。仅限专业版和旗舰版。 |
| `epic_iid`                                | integer | 否 | 要将议题添加到的史诗的 IID。有效值大于或等于 0。（已弃用，[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)）。仅限专业版和旗舰版。 |
| `iid`                                     | integer or string | 否       | 项目议题的内部 ID（需要管理员或项目所有者权限）。 |
| `issue_type`                              | string         | 否       | 议题的类型。可以是 `issue`、`incident`、`test_case` 或 `task` 之一。默认值为 `issue`。 |
| `labels`                                  | string         | 否       | 要分配给新议题的逗号分隔的标记名称。如果标记不存在，则会创建一个新的项目标记并将其分配给该议题。  |
| `merge_request_to_resolve_discussions_of` | integer        | 否       | 要解决所有讨论的合并请求的 IID。这将使用默认描述填充议题，并将所有讨论标记为已解决。当传递描述或标题时，这些值优先于默认值。|
| `milestone_id`                            | integer        | 否       | 要将议题分配到的里程碑的全局 ID。要查找与里程碑关联的 `milestone_id`，请查看已分配该里程碑的议题，并[使用 API](#retrieve-a-project-issue) 检索该议题的详细信息。与 `milestone` 互斥。 |
| `milestone`                               | string         | 否       | 要将议题分配到的项目或祖先群组里程碑的标题。精确匹配（区分大小写）。与 `milestone_id` 互斥。 |
| `severity`                                | string         | 否       | 议题的严重性。仅适用于事件。可以是 `unknown`、`low`、`medium`、`high` 或 `critical` 之一。 |
| `start_date`                              | string         | 否       | 开始日期。日期时间字符串，格式为 `YYYY-MM-DD`，例如 `2016-03-11`。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/238041)于极狐GitLab 19.1。 |
| `title`                                   | string         | 是      | 议题的标题。 |
| `weight`                                  | integer        | 否       | 议题的权重。有效值大于或等于 0。仅限专业版和旗舰版。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues?title=Issues%20with%20auth&labels=bug"
```

示例响应：

```json
{
   "project_id" : 4,
   "id" : 84,
   "created_at" : "2016-01-07T12:44:33.959Z",
   "iid" : 14,
   "title" : "Issues with auth",
   "state" : "opened",
   "assignees" : [],
   "assignee" : null,
   "type" : "ISSUE",
   "labels" : [
      "bug"
   ],
   "upvotes": 4,
   "downvotes": 0,
   "merge_requests_count": 0,
   "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
   },
   "description" : null,
   "updated_at" : "2016-01-07T12:44:33.959Z",
   "closed_at" : null,
   "closed_by" : null,
   "milestone" : null,
   "subscribed" : true,
   "user_notes_count": 0,
   "due_date": null,
   "web_url": "http://gitlab.example.com/my-group/my-project/issues/14",
   "references": {
     "short": "#14",
     "relative": "#14",
     "full": "my-group/my-project#14"
   },
   "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
   },
   "confidential": false,
   "discussion_locked": false,
   "issue_type": "issue",
   "severity": "UNKNOWN",
   "_links": {
      "self": "http://gitlab.example.com/api/v4/projects/1/issues/2",
      "notes": "http://gitlab.example.com/api/v4/projects/1/issues/2/notes",
      "award_emoji": "http://gitlab.example.com/api/v4/projects/1/issues/2/award_emoji",
      "project": "http://gitlab.example.com/api/v4/projects/1",
      "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
   },
   "task_completion_status":{
      "count":0,
      "completed_count":0
   }
}
```

如果目标项目已[关闭](../user/project/settings/_index.md#toggle-project-features) **议题** 功能，
您将收到 `403` 响应，并附带消息：

```json
{
   "message": "403 Forbidden"
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
{
   "project_id" : 4,
   "description" : null,
   "weight": null,
   ...
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

由极狐GitLab 旗舰版用户创建的议题包含 `health_status` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "on_track",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，并[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="rate-limits"></a>

### 速率限制

为帮助避免滥用，用户每分钟的 `Create` 请求数可能会受到限制。
更多信息，请参阅[内容创建速率限制](../rate_limits/content_creation.md)。

<a id="update-an-issue"></a>

## 更新议题

更新项目中指定的议题。此请求也用于使用 `state_event` 参数关闭或重新打开议题。

请求成功至少需要以下参数之一：

- `:assignee_id`
- `:assignee_ids`
- `:confidential`
- `:created_at`
- `:description`
- `:discussion_locked`
- `:due_date`
- `:issue_type`
- `:labels`
- `:milestone_id`
- `:severity`
- `:start_date`
- `:state_event`
- `:title`

```plaintext
PUT /projects/:id/issues/:issue_iid
```

支持的属性：

| 属性      | 类型    | 必填 | 描述                                                                                                |
|----------------|---------|----------|------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是 | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid`    | 整数 | 是      | 项目议题的内部 ID。                                                                       |
| `add_labels`   | 字符串  | 否       | 要添加到议题的逗号分隔的标记名称。如果标记不存在，则会创建新的项目标记并将其分配给该议题。 |
| `assignee_ids` | 整数数组 | 否 | 要指派议题的用户的 ID。设置为 `0` 或提供空值以取消指派所有指派人。 |
| `confidential` | 布尔值 | 否       | 将议题更新为机密。                                                                        |
| `description`  | 字符串  | 否       | 议题的描述。限制为 1,048,576 个字符。        |
| `discussion_locked` | 布尔值 | 否  | 指示议题的讨论是否被锁定的标志。如果讨论被锁定，则只有项目成员可以添加或编辑评论。 |
| `due_date`     | 字符串  | 否       | 截止日期。格式为 `YYYY-MM-DD` 的日期时间字符串，例如 `2016-03-11`。                                           |
| `epic_id`      | 整数 | 否 | 要将议题添加到的史诗的 ID。有效值大于或等于 0。仅限专业版和旗舰版。 |
| `epic_iid`     | 整数 | 否 | 要将议题添加到的史诗的 IID。有效值大于或等于 0。（已弃用，[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)）。仅限专业版和旗舰版。 |
| `issue_type`   | 字符串  | 否       | 更新议题的类型。可以是 `issue`、`incident` 或 `test_case` 之一。 |
| `labels`       | 字符串  | 否       | 议题的逗号分隔的标记名称。设置为空字符串以取消分配所有标记。如果标记不存在，则会创建新的项目标记并将其分配给该议题。 |
| `milestone_id` | 整数 | 否       | 要指派议题的里程碑的全局 ID。设置为 `0` 或提供空值以取消指派里程碑。与 `milestone` 互斥。|
| `milestone`    | 字符串  | 否       | 要指派议题的项目或祖先群组里程碑的标题。精确匹配（区分大小写）。与 `milestone_id` 互斥。 |
| `remove_labels`| 字符串  | 否       | 要从议题中移除的逗号分隔的标记名称。                                                       |
| `severity`     | 字符串  | 否       | 议题的严重性。仅适用于事件。可以是 `unknown`、`low`、`medium`、`high` 或 `critical` 之一。 |
| `start_date`   | 字符串  | 否       | 开始日期。格式为 `YYYY-MM-DD` 的日期时间字符串，例如 `2016-03-11`。[在极狐GitLab 19.1 中引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/238041)。 |
| `state_event`  | 字符串  | 否       | 议题的状态事件。要关闭议题，请使用 `close`；要重新打开议题，请使用 `reopen`。                      |
| `title`        | 字符串  | 否       | 议题的标题。                                                                                      |
| `updated_at`   | 字符串  | 否       | 议题的更新时间。ISO 8601 格式的日期时间字符串，例如 `2016-03-11T03:45:40Z`（需要管理员或项目所有者权限）。不接受空字符串或 null 值。|
| `weight`       | 整数 | 否       | 议题的权重。有效值大于或等于 0。仅限专业版和旗舰版。           |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues/85?state_event=close"
```

示例响应：

```json
{
   "created_at" : "2016-01-07T12:46:01.410Z",
   "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "username" : "eileen.lowe",
      "id" : 18,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe"
   },
   "state" : "closed",
   "title" : "Issues with auth",
   "project_id" : 4,
   "description" : null,
   "updated_at" : "2016-01-07T12:55:16.213Z",
   "closed_at" : "2016-01-08T12:55:16.213Z",
   "closed_by" : {
      "state" : "active",
      "web_url" : "https://gitlab.example.com/root",
      "avatar_url" : null,
      "username" : "root",
      "id" : 1,
      "name" : "Administrator"
    },
   "iid" : 15,
   "labels" : [
      "bug"
   ],
   "upvotes": 4,
   "downvotes": 0,
   "merge_requests_count": 0,
   "id" : 85,
   "assignees" : [],
   "assignee" : null,
   "milestone" : null,
   "subscribed" : true,
   "user_notes_count": 0,
   "due_date": "2016-07-22",
   "web_url": "http://gitlab.example.com/my-group/my-project/issues/15",
   "references": {
     "short": "#15",
     "relative": "#15",
     "full": "my-group/my-project#15"
   },
   "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
   },
   "confidential": false,
   "discussion_locked": false,
   "issue_type": "issue",
   "severity": "UNKNOWN",
   "_links": {
      "self": "http://gitlab.example.com/api/v4/projects/1/issues/2",
      "notes": "http://gitlab.example.com/api/v4/projects/1/issues/2/notes",
      "award_emoji": "http://gitlab.example.com/api/v4/projects/1/issues/2/award_emoji",
      "project": "http://gitlab.example.com/api/v4/projects/1",
      "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"

   },
   "task_completion_status":{
      "count":0,
      "completed_count":0
   }
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
{
   "project_id" : 4,
   "description" : null,
   "weight": null,
   ...
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

由极狐GitLab 旗舰版用户创建的议题包含 `health_status` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "on_track",
      ...
   }
]
```

> [!warning]
> 弃用说明：
>
> - `epic_iid` 属性已弃用，[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
>   请改用 `epic` 属性的 `iid`。
> - `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。

<a id="delete-an-issue"></a>

## 删除议题

拥有计划者或所有者角色的用户可以删除任何议题。其他项目成员可以删除他们创建的议题。

从项目中删除指定的议题。

```plaintext
DELETE /projects/:id/issues/:issue_iid
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues/85"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

<a id="reorder-an-issue"></a>

## 对议题重新排序

对项目中指定的议题重新排序。当您[手动对议题列表排序](../user/project/issues/sorting_issue_lists.md#manual-sorting)时，可以查看结果。

```plaintext
PUT /projects/:id/issues/:issue_iid/reorder
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |
| `move_after_id` | 整数 | 否 | 应放置在此议题之后的项目议题的全局 ID。 |
| `move_before_id` | 整数 | 否 | 应放置在此议题之前的项目议题的全局 ID。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues/85/reorder?move_after_id=51&move_before_id=92"
```

<a id="move-an-issue"></a>

## 移动议题

将指定的议题移动到另一个项目。如果目标项目是源项目或用户权限不足，则返回状态码为 `400` 的错误消息。

如果目标项目中已存在同名的标记或里程碑，则会将其分配给被移动的议题。

```plaintext
POST /projects/:id/issues/:issue_iid/move
```

支持的属性：

| 属性       | 类型    | 必填 | 描述                          |
|-----------------|---------|----------|--------------------------------------|
| `id`            | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid`     | 整数 | 是      | 项目议题的内部 ID。 |
| `to_project_id` | 整数 | 是      | 新项目的 ID。            |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --form to_project_id=5 \
  --url "https://gitlab.example.com/api/v4/projects/4/issues/85/move"
```

示例响应：

```json
{
  "id": 92,
  "iid": 11,
  "project_id": 5,
  "title": "Sit voluptas tempora quisquam aut doloribus et.",
  "description": "Repellat voluptas quibusdam voluptatem exercitationem.",
  "state": "opened",
  "created_at": "2016-04-05T21:41:45.652Z",
  "updated_at": "2016-04-07T12:20:17.596Z",
  "closed_at": null,
  "closed_by": null,
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "merge_requests_count": 0,
  "milestone": null,
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "assignee": {
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  },
  "type" : "ISSUE",
  "author": {
    "name": "Kris Steuber",
    "username": "solon.cremin",
    "id": 10,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/7a190fecbaa68212a4b68aeb6e3acd10?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/solon.cremin"
  },
  "due_date": null,
  "imported": false,
  "imported_from": "none",
  "web_url": "http://gitlab.example.com/my-group/my-project/issues/11",
  "references": {
    "short": "#11",
    "relative": "#11",
    "full": "my-group/my-project#11"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "confidential": false,
  "discussion_locked": false,
  "issue_type": "issue",
  "severity": "UNKNOWN",
  "_links": {
    "self": "http://gitlab.example.com/api/v4/projects/1/issues/2",
    "notes": "http://gitlab.example.com/api/v4/projects/1/issues/2/notes",
    "award_emoji": "http://gitlab.example.com/api/v4/projects/1/issues/2/award_emoji",
    "project": "http://gitlab.example.com/api/v4/projects/1",
    "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
  },
  "task_completion_status":{
     "count":0,
     "completed_count":0
  }
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
{
  "project_id": 5,
  "description": "Repellat voluptas quibusdam voluptatem exercitationem.",
  "weight": null,
  ...
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

由极狐GitLab 旗舰版用户创建的议题包含 `health_status` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "on_track",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="clone-an-issue"></a>

## 克隆议题

将指定的议题克隆到给定的项目。只要目标项目包含等效的条件（例如标记或里程碑），就会尽可能多地复制数据。

如果您的权限不足，则返回状态码为 `400` 的错误消息。

```plaintext
POST /projects/:id/issues/:issue_iid/clone
```

支持的属性：

| 属性       | 类型           | 必填               | 描述                       |
| --------------- | -------------- | ---------------------- | --------------------------------- |
| `id`            | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid`     | 整数        | 是 | 项目议题的内部 ID。 |
| `to_project_id` | 整数        | 是 | 新项目的 ID。            |
| `with_notes`    | 布尔值        | 否 | 克隆议题时包含[评论](notes.md)。默认为 `false`。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/1/clone?with_notes=true&to_project_id=6"
```

示例响应：

```json
{
  "id":290,
  "iid":1,
  "project_id":143,
  "title":"foo",
  "description":"closed",
  "state":"opened",
  "created_at":"2021-09-14T22:24:11.696Z",
  "updated_at":"2021-09-14T22:24:11.696Z",
  "closed_at":null,
  "closed_by":null,
  "labels":[

  ],
  "milestone":null,
  "assignees":[
    {
      "id":179,
      "name":"John Doe2",
      "username":"john",
      "state":"active",
      "avatar_url":"https://www.gravatar.com/avatar/10fc7f102be8de7657fb4d80898bbfe3?s=80\u0026d=identicon",
      "web_url":"https://gitlab.example.com/john"
    }
  ],
  "author":{
    "id":179,
    "name":"John Doe2",
    "username":"john",
    "state":"active",
    "avatar_url":"https://www.gravatar.com/avatar/10fc7f102be8de7657fb4d80898bbfe3?s=80\u0026d=identicon",
    "web_url":"https://gitlab.example.com/john"
  },
  "type":"ISSUE",
  "assignee":{
    "id":179,
    "name":"John Doe2",
    "username":"john",
    "state":"active",
    "avatar_url":"https://www.gravatar.com/avatar/10fc7f102be8de7657fb4d80898bbfe3?s=80\u0026d=identicon",
    "web_url":"https://gitlab.example.com/john"
  },
  "user_notes_count":1,
  "merge_requests_count":0,
  "upvotes":0,
  "downvotes":0,
  "due_date":null,
  "imported":false,
  "imported_from": "none",
  "confidential":false,
  "discussion_locked":null,
  "issue_type":"issue",
  "severity": "UNKNOWN",
  "web_url":"https://gitlab.example.com/namespace1/project2/-/issues/1",
  "time_stats":{
    "time_estimate":0,
    "total_time_spent":0,
    "human_time_estimate":null,
    "human_total_time_spent":null
  },
  "task_completion_status":{
    "count":0,
    "completed_count":0
  },
  "blocking_issues_count":0,
  "has_tasks":false,
  "_links":{
    "self":"https://gitlab.example.com/api/v4/projects/143/issues/1",
    "notes":"https://gitlab.example.com/api/v4/projects/143/issues/1/notes",
    "award_emoji":"https://gitlab.example.com/api/v4/projects/143/issues/1/award_emoji",
    "project":"https://gitlab.example.com/api/v4/projects/143",
    "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
  },
  "references":{
    "short":"#1",
    "relative":"#1",
    "full":"namespace1/project2#1"
  },
  "subscribed":true,
  "moved_to_id":null,
  "service_desk_reply_to":null
}
```

<a id="notifications"></a>

## 通知

以下请求与议题的[电子邮件通知](../user/profile/notifications.md)相关。

<a id="subscribe-to-an-issue"></a>

### 订阅议题

将经过身份验证的用户订阅到指定的议题以接收通知。如果用户已订阅该议题，则返回状态码 `304`。

```plaintext
POST /projects/:id/issues/:issue_iid/subscribe
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/subscribe"
```

示例响应：

```json
{
  "id": 92,
  "iid": 11,
  "project_id": 5,
  "title": "Sit voluptas tempora quisquam aut doloribus et.",
  "description": "Repellat voluptas quibusdam voluptatem exercitationem.",
  "state": "opened",
  "created_at": "2016-04-05T21:41:45.652Z",
  "updated_at": "2016-04-07T12:20:17.596Z",
  "closed_at": null,
  "closed_by": null,
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "merge_requests_count": 0,
  "milestone": null,
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "assignee": {
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  },
  "type" : "ISSUE",
  "author": {
    "name": "Kris Steuber",
    "username": "solon.cremin",
    "id": 10,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/7a190fecbaa68212a4b68aeb6e3acd10?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/solon.cremin"
  },
  "due_date": null,
  "web_url": "http://gitlab.example.com/my-group/my-project/issues/11",
  "references": {
    "short": "#11",
    "relative": "#11",
    "full": "my-group/my-project#11"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "confidential": false,
  "discussion_locked": false,
  "issue_type": "issue",
  "severity": "UNKNOWN",
  "_links": {
    "self": "http://gitlab.example.com/api/v4/projects/1/issues/2",
    "notes": "http://gitlab.example.com/api/v4/projects/1/issues/2/notes",
    "award_emoji": "http://gitlab.example.com/api/v4/projects/1/issues/2/award_emoji",
    "project": "http://gitlab.example.com/api/v4/projects/1",
    "closed_as_duplicate_of": "http://gitlab.example.com/api/v4/projects/1/issues/75"
  },
  "task_completion_status":{
     "count":0,
     "completed_count":0
  }
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `weight` 属性：

```json
{
  "project_id": 5,
  "description": "Repellat voluptas quibusdam voluptatem exercitationem.",
  "weight": null,
  ...
}
```

由极狐GitLab 专业版或旗舰版用户创建的议题包含 `epic` 属性：

```json
{
   "project_id" : 4,
   "description" : "Omnis vero earum sunt corporis dolor et placeat.",
   "epic_iid" : 5, //deprecated, use `iid` of the `epic` attribute
   "epic": {
     "id" : 42,
     "iid" : 5,
     "title": "My epic epic",
     "url" : "/groups/h5bp/-/epics/5",
     "group_id": 8
   },
   ...
}
```

由极狐GitLab 旗舰版用户创建的议题包含 `health_status` 属性：

```json
[
   {
      "project_id" : 4,
      "description" : "Omnis vero earum sunt corporis dolor et placeat.",
      "health_status": "on_track",
      ...
   }
]
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。
>
> `epic_iid` 属性已弃用，[计划在 API 版本 5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/35157)。
> 请改用 `epic` 属性的 `iid`。

<a id="unsubscribe-from-an-issue"></a>

### 取消订阅议题

取消经过身份验证的用户对指定议题的订阅以停止接收通知。如果用户未订阅该议题，则返回状态码 `304`。

```plaintext
POST /projects/:id/issues/:issue_iid/unsubscribe
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/unsubscribe"
```

示例响应：

```json
{
  "id": 93,
  "iid": 12,
  "project_id": 5,
  "title": "Incidunt et rerum ea expedita iure quibusdam.",
  "description": "Et cumque architecto sed aut ipsam.",
  "state": "opened",
  "created_at": "2016-04-05T21:41:45.217Z",
  "updated_at": "2016-04-07T13:02:37.905Z",
  "labels": [],
  "upvotes": 4,
  "downvotes": 0,
  "merge_requests_count": 0,
  "milestone": null,
  "assignee": {
    "name": "Edwardo Grady",
    "username": "keyon",
    "id": 21,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/3e6f06a86cf27fa8b56f3f74f7615987?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/keyon"
  },
  "type" : "ISSUE",
  "closed_at": null,
  "closed_by": null,
  "author": {
    "name": "Vivian Hermann",
    "username": "orville",
    "id": 11,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/5224fd70153710e92fb8bcf79ac29d67?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/orville"
  },
  "subscribed": false,
  "due_date": null,
  "web_url": "http://gitlab.example.com/my-group/my-project/issues/12",
  "references": {
    "short": "#12",
    "relative": "#12",
    "full": "my-group/my-project#12"
  },
  "confidential": false,
  "discussion_locked": false,
  "issue_type": "issue",
  "severity": "UNKNOWN",
  "task_completion_status":{
     "count":0,
     "completed_count":0
  }
}
```

<a id="create-a-to-do-item-for-an-issue"></a>

## 为议题创建待办事项

为当前用户在指定议题上创建待办事项。如果该用户在该议题上已存在待办事项，则返回状态码 `304`。

```plaintext
POST /projects/:id/issues/:issue_iid/todo
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/todo"
```

示例响应：

```json
{
  "id": 112,
  "project": {
    "id": 5,
    "name": "GitLab CI/CD",
    "name_with_namespace": "GitLab Org / GitLab CI/CD",
    "path": "gitlab-ci",
    "path_with_namespace": "gitlab-org/gitlab-ci"
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
  "target_type": "Issue",
  "target": {
    "id": 93,
    "iid": 10,
    "project_id": 5,
    "title": "Vel voluptas atque dicta mollitia adipisci qui at.",
    "description": "Tempora laboriosam sint magni sed voluptas similique.",
    "state": "closed",
    "created_at": "2016-06-17T07:47:39.486Z",
    "updated_at": "2016-07-01T11:09:13.998Z",
    "labels": [],
    "milestone": {
      "id": 26,
      "iid": 1,
      "project_id": 5,
      "title": "v0.0",
      "description": "Accusantium nostrum rerum quae quia quis nesciunt suscipit id.",
      "state": "closed",
      "created_at": "2016-06-17T07:47:33.832Z",
      "updated_at": "2016-06-17T07:47:33.832Z",
      "due_date": null
    },
    "assignees": [{
      "name": "Jarret O'Keefe",
      "username": "francisca",
      "id": 14,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a7fa515d53450023c83d62986d0658a8?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/francisca"
    }],
    "assignee": {
      "name": "Jarret O'Keefe",
      "username": "francisca",
      "id": 14,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a7fa515d53450023c83d62986d0658a8?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/francisca"
    },
    "type" : "ISSUE",
    "author": {
      "name": "Maxie Medhurst",
      "username": "craig_rutherford",
      "id": 12,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a0d477b3ea21970ce6ffcbb817b0b435?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/craig_rutherford"
    },
    "subscribed": true,
    "user_notes_count": 7,
    "upvotes": 0,
    "downvotes": 0,
    "merge_requests_count": 0,
    "due_date": null,
    "web_url": "http://gitlab.example.com/my-group/my-project/issues/10",
    "references": {
      "short": "#10",
      "relative": "#10",
      "full": "my-group/my-project#10"
    },
    "confidential": false,
    "discussion_locked": false,
    "issue_type": "issue",
    "severity": "UNKNOWN",
    "task_completion_status":{
       "count":0,
       "completed_count":0
    }
  },
  "target_url": "https://gitlab.example.com/gitlab-org/gitlab-ci/issues/10",
  "body": "Vel voluptas atque dicta mollitia adipisci qui at.",
  "state": "pending",
  "created_at": "2016-07-01T11:09:13.992Z"
}
```

> [!warning]
> `assignee` 列已弃用。极狐GitLab 将其作为单元素数组 `assignees` 返回，以符合极狐GitLab 企业版 API。

<a id="promote-an-issue-to-an-epic"></a>

## 将议题升级为史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过添加包含 [`/promote_to`](../user/project/quick_actions.md#promote_to) 快速操作的评论，将指定的议题升级为史诗。

有关更多信息，请参阅
[将议题升级为史诗](../user/project/issues/managing_issues.md#promote-an-issue-to-an-epic)。

```plaintext
POST /projects/:id/issues/:issue_iid/notes
```

支持的属性：

| 属性   | 类型           | 必填 | 描述 |
| :---------- | :------------- | :------- | :---------- |
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数        | 是      | 项目议题的内部 ID。 |
| `body`      | 字符串         | 是      | 评论的内容。必须在新行开头包含 `/promote`。如果评论仅包含 `/promote`，则升级议题，但不添加评论。否则，其他行将构成一条评论。|

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/notes?body=Lets%20promote%20this%20to%20an%20epic%0A%0A%2Fpromote"
```

示例响应：

```json
{
   "id":699,
   "type":null,
   "body":"Lets promote this to an epic",
   "attachment":null,
   "author": {
      "id":1,
      "name":"Alexandra Bashirian",
      "username":"eileen.lowe",
      "state":"active",
      "avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url":"https://gitlab.example.com/eileen.lowe"
   },
   "created_at":"2020-12-03T12:27:17.844Z",
   "updated_at":"2020-12-03T12:27:17.844Z",
   "system":false,
   "noteable_id":461,
   "noteable_type":"Issue",
   "resolvable":false,
   "confidential":false,
   "noteable_iid":33,
   "commands_changes": {
      "promote_to_epic":true
   }
}
```

<a id="time-tracking"></a>

## 时间跟踪

以下请求与议题上的[时间跟踪](../user/project/time_tracking.md)相关。

<a id="set-a-time-estimate-for-an-issue"></a>

### 为议题设置时间估算

为指定的议题设置预估工作时间。

```plaintext
POST /projects/:id/issues/:issue_iid/time_estimate
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                              |
|-------------|---------|----------|------------------------------------------|
| `duration`  | 字符串  | 是      | 人类可读格式的持续时间。例如：`3h30m`。 |
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。      |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。     |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/time_estimate?duration=3h30m"
```

示例响应：

```json
{
  "human_time_estimate": "3h 30m",
  "human_total_time_spent": null,
  "time_estimate": 12600,
  "total_time_spent": 0
}
```

<a id="reset-the-time-estimate-for-an-issue"></a>

### 重置议题的时间估算

将指定议题的预估时间重置为 0 秒。

```plaintext
POST /projects/:id/issues/:issue_iid/reset_time_estimate
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/reset_time_estimate"
```

示例响应：

```json
{
  "human_time_estimate": null,
  "human_total_time_spent": null,
  "time_estimate": 0,
  "total_time_spent": 0
}
```

<a id="add-spent-time-for-an-issue"></a>

### 为议题添加已用时间

为指定的议题添加已用时间。

```plaintext
POST /projects/:id/issues/:issue_iid/add_spent_time
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                              |
|-------------|---------|----------|------------------------------------------|
| `duration`  | 字符串  | 是      | 人类可读格式的持续时间。例如：`3h30m` |
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。    |
| `summary`   | 字符串  | 否       | 时间使用方式的摘要。  |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/add_spent_time?duration=1h"
```

示例响应：

```json
{
  "human_time_estimate": null,
  "human_total_time_spent": "1h",
  "time_estimate": 0,
  "total_time_spent": 3600
}
```

<a id="reset-spent-time-for-an-issue"></a>

### 重置议题的已用时间

将指定议题的总已用时间重置为 0 秒。

```plaintext
POST /projects/:id/issues/:issue_iid/reset_spent_time
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/reset_spent_time"
```

示例响应：

```json
{
  "human_time_estimate": null,
  "human_total_time_spent": null,
  "time_estimate": 0,
  "total_time_spent": 0
}
```

<a id="retrieve-time-tracking-stats-for-an-issue"></a>

### 检索议题的时间跟踪统计信息

以人类可读格式（例如，`1h30m`）和秒数检索指定议题的时间跟踪统计信息。

如果项目是私有的或议题是机密的，您必须提供凭据进行授权。
推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /projects/:id/issues/:issue_iid/time_stats
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/time_stats"
```

示例响应：

```json
{
  "human_time_estimate": "2h",
  "human_total_time_spent": "1h",
  "time_estimate": 7200,
  "total_time_spent": 3600
}
```

<a id="merge-requests"></a>

## 合并请求

以下请求与议题和合并请求之间的关系相关。

<a id="list-all-merge-requests-related-to-an-issue"></a>

### 列出与议题相关的所有合并请求

列出与指定议题相关的所有合并请求。

如果项目是私有的或议题是机密的，您需要提供凭据进行授权。
推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /projects/:id/issues/:issue_iid/related_merge_requests
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/11/related_merge_requests"
```

示例响应：

```json
[
  {
    "id": 29,
    "iid": 11,
    "project_id": 1,
    "title": "Provident eius eos blanditiis consequatur neque odit.",
    "description": "Ut consequatur ipsa aspernatur quisquam voluptatum fugit. Qui harum corporis quo fuga ut incidunt veritatis. Autem necessitatibus et harum occaecati nihil ea.\r\n\r\ntwitter/flight#8",
    "state": "opened",
    "created_at": "2018-09-18T14:36:15.510Z",
    "updated_at": "2018-09-19T07:45:13.089Z",
    "closed_by": null,
    "closed_at": null,
    "target_branch": "v2.x",
    "source_branch": "so_long_jquery",
    "user_notes_count": 9,
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "id": 14,
      "name": "Verna Hills",
      "username": "lawanda_reinger",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/de68a91aeab1cff563795fb98a0c2cc0?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/lawanda_reinger"
    },
    "assignee": {
      "id": 19,
      "name": "Jody Baumbach",
      "username": "felipa.kuvalis",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/6541fc75fc4e87e203529bd275fafd07?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/felipa.kuvalis"
    },
    "source_project_id": 1,
    "target_project_id": 1,
    "labels": [],
    "draft": false,
    "work_in_progress": false,
    "milestone": {
      "id": 27,
      "iid": 2,
      "project_id": 1,
      "title": "v1.0",
      "description": "Et tenetur voluptatem minima doloribus vero dignissimos vitae.",
      "state": "active",
      "created_at": "2018-09-18T14:35:44.353Z",
      "updated_at": "2018-09-18T14:35:44.353Z",
      "due_date": null,
      "start_date": null,
      "web_url": "https://gitlab.example.com/twitter/flight/milestones/2"
    },
    "merge_when_pipeline_succeeds": false,
    "merge_status": "cannot_be_merged",
    "sha": "3b7b528e9353295c1c125dad281ac5b5deae5f12",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "discussion_locked": null,
    "should_remove_source_branch": null,
    "force_remove_source_branch": false,
    "reference": "!11",
    "web_url": "https://gitlab.example.com/twitter/flight/merge_requests/4",
    "references": {
      "short": "!4",
      "relative": "!4",
      "full": "twitter/flight!4"
    },
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "squash": false,
    "task_completion_status": {
      "count": 0,
      "completed_count": 0
    },
    "changes_count": "10",
    "latest_build_started_at": "2018-12-05T01:16:41.723Z",
    "latest_build_finished_at": "2018-12-05T02:35:54.046Z",
    "first_deployed_to_production_at": null,
    "pipeline": {
      "id": 38980952,
      "sha": "81c6a84c7aebd45a1ac2c654aa87f11e32338e0a",
      "ref": "test-branch",
      "status": "success",
      "web_url": "https://gitlab.com/gitlab-org/gitlab/pipelines/38980952"
    },
    "head_pipeline": {
      "id": 38980952,
      "sha": "81c6a84c7aebd45a1ac2c654aa87f11e32338e0a",
      "ref": "test-branch",
      "status": "success",
      "web_url": "https://gitlab.example.com/twitter/flight/pipelines/38980952",
      "before_sha": "3c738a37eb23cf4c0ed0d45d6ddde8aad4a8da51",
      "tag": false,
      "yaml_errors": null,
      "user": {
        "id": 19,
        "name": "Jody Baumbach",
        "username": "felipa.kuvalis",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/6541fc75fc4e87e203529bd275fafd07?s=80&d=identicon",
        "web_url": "https://gitlab.example.com/felipa.kuvalis"
      },
      "created_at": "2018-12-05T01:16:13.342Z",
      "updated_at": "2018-12-05T02:35:54.086Z",
      "started_at": "2018-12-05T01:16:41.723Z",
      "finished_at": "2018-12-05T02:35:54.046Z",
      "committed_at": null,
      "duration": 4436,
      "coverage": "46.68",
      "detailed_status": {
        "icon": "status_warning",
        "text": "passed",
        "label": "passed with warnings",
        "group": "success-with-warnings",
        "tooltip": "passed",
        "has_details": true,
        "details_path": "/twitter/flight/pipelines/38",
        "illustration": null,
        "favicon": "https://gitlab.example.com/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png"
      },
      "archived": false
    },
    "diff_refs": {
      "base_sha": "d052d768f0126e8cddf80afd8b1eb07f406a3fcb",
      "head_sha": "81c6a84c7aebd45a1ac2c654aa87f11e32338e0a",
      "start_sha": "d052d768f0126e8cddf80afd8b1eb07f406a3fcb"
    },
    "merge_error": null,
    "user": {
      "can_merge": true
    }
  }
]
```

<a id="list-all-merge-requests-that-close-an-issue-on-merge"></a>

### 列出合并后关闭议题的所有合并请求

列出合并后关闭指定议题的所有合并请求。

如果项目是私有的或议题是机密的，您需要提供凭据进行授权。
推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /projects/:id/issues/:issue_iid/closed_by
```

支持的属性：

| 属性   | 类型           | 必填 | 描述                        |
| ----------- | ---------------| -------- | ---------------------------------- |
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数        | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/11/closed_by"
```

示例响应：

```json
[
  {
    "id": 6471,
    "iid": 6432,
    "project_id": 1,
    "title": "add a test for cgi lexer options",
    "description": "closes #11",
    "state": "opened",
    "created_at": "2017-04-06T18:33:34.168Z",
    "updated_at": "2017-04-09T20:10:24.983Z",
    "target_branch": "main",
    "source_branch": "feature.custom-highlighting",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "name": "Administrator",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/root"
    },
    "assignee": null,
    "source_project_id": 1,
    "target_project_id": 1,
    "closed_at": null,
    "closed_by": null,
    "labels": [],
    "draft": false,
    "work_in_progress": false,
    "milestone": null,
    "merge_when_pipeline_succeeds": false,
    "merge_status": "unchecked",
    "sha": "5a62481d563af92b8e32d735f2fa63b94e806835",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 1,
    "should_remove_source_branch": null,
    "force_remove_source_branch": false,
    "web_url": "https://gitlab.example.com/gitlab-org/gitlab-test/merge_requests/6432",
    "reference": "!6432",
    "references": {
      "short": "!6432",
      "relative": "!6432",
      "full": "gitlab-org/gitlab-test!6432"
    },
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

<a id="list-all-participants-in-an-issue"></a>

## 列出议题的所有参与者

列出指定议题的所有参与者。

如果项目是私有的或议题是机密的，您需要提供凭据进行授权。
推荐的方法是使用[个人访问令牌](../user/profile/personal_access_tokens.md)。

```plaintext
GET /projects/:id/issues/:issue_iid/participants
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  -url "https://gitlab.example.com/api/v4/projects/5/issues/93/participants"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "John Doe1",
    "username": "user1",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/c922747a93b40d1ea88262bf1aebee62?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/user1"
  },
  {
    "id": 5,
    "name": "John Doe5",
    "username": "user5",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/4aea8cf834ed91844a2da4ff7ae6b491?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/user5"
  }
]
```

<a id="comments-on-issues"></a>

## 议题评论

使用[评论 API](notes.md) 与评论交互。

<a id="retrieve-user-agent-details-for-an-issue"></a>

## 检索议题的用户代理详情

仅适用于管理员。

检索创建指定议题的用户的用户代理字符串和 IP 地址。用于垃圾邮件跟踪。

```plaintext
GET /projects/:id/issues/:issue_iid/user_agent_detail
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/user_agent_detail"
```

示例响应：

```json
{
  "user_agent": "AppleWebKit/537.36",
  "ip_address": "127.0.0.1",
  "akismet_submitted": false
}
```

<a id="list-issue-state-events"></a>

## 列出议题状态事件

要跟踪设置了哪个状态、由谁设置以及何时设置，请使用
[资源状态事件 API](resource_state_events.md#issues)。

<a id="incidents"></a>

## 事件

以下请求仅适用于[事件](../operations/incident_management/incidents.md)。

<a id="upload-a-metric-image-for-an-incident"></a>

### 为事件上传指标图片

仅适用于[事件](../operations/incident_management/incidents.md)。

上传指标图表截图以显示在指定事件的 **指标** 选项卡中。上传图片时，您可以将图片与文本或原始图表的链接关联。如果添加了 URL，您可以通过选择上传图片上方的超链接访问原始图表。

```plaintext
POST /projects/:id/issues/:issue_iid/metric_images
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |
| `file` | 文件 | 是      | 要上传的图片文件。 |
| `url` | 字符串 | 否      | 用于查看更多指标信息的 URL。 |
| `url_text` | 字符串 | 否      | 图片或 URL 的描述。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --form 'file=@/path/to/file.png' \
  --form 'url=http://example.com' \
  --form 'url_text=Example website' \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/metric_images"
```

示例响应：

```json
{
    "id": 23,
    "created_at": "2020-11-13T00:06:18.084Z",
    "filename": "file.png",
    "file_path": "/uploads/-/system/issuable_metric_image/file/23/file.png",
    "url": "http://example.com",
    "url_text": "Example website"
}
```

<a id="list-all-metric-images-for-an-incident"></a>

### 列出事件的所有指标图片

仅适用于[事件](../operations/incident_management/incidents.md)。

列出指定事件 **指标** 选项卡中显示的所有指标图表截图。

```plaintext
GET /projects/:id/issues/:issue_iid/metric_images
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  -url "https://gitlab.example.com/api/v4/projects/5/issues/93/metric_images"
```

示例响应：

```json
[
    {
        "id": 17,
        "created_at": "2020-11-12T20:07:58.156Z",
        "filename": "sample_2054",
        "file_path": "/uploads/-/system/issuable_metric_image/file/17/sample_2054.png",
        "url": "example.com/metric"
    },
    {
        "id": 18,
        "created_at": "2020-11-12T20:14:26.441Z",
        "filename": "sample_2054",
        "file_path": "/uploads/-/system/issuable_metric_image/file/18/sample_2054.png",
        "url": "example.com/metric"
    }
]
```

<a id="update-a-metric-image-for-an-incident"></a>

### 更新事件指标图片

仅适用于[事件](../operations/incident_management/incidents.md)。

更新事件 **指标** 选项卡中显示的指定指标图片的属性。

```plaintext
PUT /projects/:id/issues/:issue_iid/metric_images/:image_id
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |
| `image_id` | 整数 | 是      | 图片的 ID。 |
| `url` | 字符串 | 否      | 用于查看更多指标信息的 URL。 |
| `url_text` | 字符串 | 否      | 图片或 URL 的描述。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --request PUT \
  --form 'url=http://example.com' \
  --form 'url_text=Example website' \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/metric_images/1"
```

示例响应：

```json
{
    "id": 23,
    "created_at": "2020-11-13T00:06:18.084Z",
    "filename": "file.png",
    "file_path": "/uploads/-/system/issuable_metric_image/file/23/file.png",
    "url": "http://example.com",
    "url_text": "Example website"
}
```

<a id="delete-a-metric-image-from-an-incident"></a>

### 从事件中删除指标图片

仅适用于[事件](../operations/incident_management/incidents.md)。

从事件的 **指标** 选项卡中删除指定的指标图片。

```plaintext
DELETE /projects/:id/issues/:issue_iid/metric_images/:image_id
```

支持的属性：

| 属性   | 类型    | 必填 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | 整数或字符串 | 是      | 项目的全局 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `issue_iid` | 整数 | 是      | 项目议题的内部 ID。 |
| `image_id` | 整数 | 是      | 图片的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --request DELETE \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/93/metric_images/1"
```

可能返回以下状态码：

- `204 No Content`，如果图片删除成功。
- `400 Bad Request`，如果图片无法删除。
