---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for merge requests in GitLab.
title: 合并请求 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<!-- Do not remove these outdated lines until the changes are actually implemented in the API -->

{{< history >}}

- `reference` 在 极狐GitLab 12.7 中[弃用]。
- `merged_by` 在 极狐GitLab 14.7 中[弃用]。
- `merge_status` 在 极狐GitLab 15.6 中[弃用]，取而代之的是 `detailed_merge_status`。
- `with_merge_status_recheck` 在 极狐GitLab 15.11 中[变更]，通过功能标志 `restrict_merge_status_recheck` 使其在权限不足用户的请求中被忽略。默认禁用。
- `approvals_before_merge` 在 极狐GitLab 16.0 中[弃用]。
- `prepared_at` 在 极狐GitLab 16.1 中[引入]。
- `merge_user_id` 在 极狐GitLab 17.0 中[引入]。
- `merge_user_username` 在 极狐GitLab 17.0 中[引入]。
- `merged_at` 作为 `order_by` 的可选值在 极狐GitLab 17.2 中[引入]。
- `merge_after` 在 极狐GitLab 17.5 中[引入]。
- `security_policy_violations` 在 极狐GitLab 18.4 中[一般可用]。功能标志 `policy_mergability_check` 已移除。

{{< /history >}}

使用此 API 来管理[合并请求](../user/project/merge_requests/_index.md)。你可以：

- 自动执行代码审查流程中的任何部分。
- 将代码变更连接到外部工具。
- 以你喜欢的格式将合并请求信息发送到非极狐GitLab 系统。
- 基于外部系统的数据更新、批准、合并或阻止合并请求。

所有访问非公开信息的 API 调用都需要身份验证。

<a id="removals-in-api-v5"></a>

## API v5 中的删除项

`approvals_before_merge` 属性已弃用，并[计划在 API v5 中移除](rest/deprecations.md)，请改用[合并请求批准 API](merge_request_approvals.md)。

<a id="list-merge-requests"></a>

## 列出合并请求

列出已认证用户可访问的所有合并请求。默认情况下，仅返回当前用户创建的合并请求。
使用 `scope=all` 可获取所有合并请求。

使用 `state` 参数可仅获取处于特定状态（`opened`、`closed`、`locked` 或 `merged`）或所有状态（`all`）的合并请求。
按 `locked` 搜索通常不会返回结果，因为该状态持续时间短且是过渡性的。使用分页参数 `page` 和 `per_page` 来限制合并请求列表。

```plaintext
GET /merge_requests
GET /merge_requests?state=opened
GET /merge_requests?state=all
GET /merge_requests?milestone=release
GET /merge_requests?labels=bug,reproduced
GET /merge_requests?author_id=5
GET /merge_requests?author_username=gitlab-bot
GET /merge_requests?my_reaction_emoji=star
GET /merge_requests?scope=assigned_to_me
GET /merge_requests?scope=reviews_for_me
GET /merge_requests?search=foo&in=title
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|---|---|---|---|
| `approved_by_ids[]` | 整数数组 | 否 | 返回至少被所有给定 `id` 用户（最多 5 位）批准的合并请求。`None` 返回未经批准的合并请求。`Any` 返回有批准的合并请求。 |
| `approved_by_usernames[]` | 字符串数组 | 否 | 返回至少被所有给定 `username` 用户（最多 5 位）批准的合并请求。`None` 返回未经批准的合并请求。`Any` 返回有批准的合并请求。 |
| `approver_ids[]` | 整数数组 | 否 | 返回审批规则中所有给定 `id` 用户均作为合格审批人的合并请求。`None` 返回没有合格审批人的合并请求。`Any` 返回至少有一个合格审批人的合并请求。仅专业版和旗舰版可用。 |
| `assignee_id` | 整数或字符串 | 否 | 返回指派给给定用户 `id` 的合并请求。`None` 返回未指派的合并请求。`Any` 返回有指派的合并请求。与 `assignee_username` 互斥。 |
| `assignee_username[]` | 字符串数组 | 否 | 返回指派给给定用户名的合并请求。与 `assignee_id` 互斥。 |
| `author_id` | 整数 | 否 | 返回由给定用户 `id` 创建的合并请求。与 `author_username` 互斥。可与 `scope=all` 或 `scope=assigned_to_me` 结合使用。 |
| `author_username` | 字符串 | 否 | 返回由给定 `username` 创建的合并请求。与 `author_id` 互斥。 |
| `created_after` | 日期时间 | 否 | 返回在给定日期时间或之后创建的合并请求。应采用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before` | 日期时间 | 否 | 返回在给定日期时间或之前创建的合并请求。应采用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `deployed_after` | 日期时间 | 否 | 返回在给定日期时间之后部署的合并请求。应采用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `deployed_before` | 日期时间 | 否 | 返回在给定日期时间之前部署的合并请求。应采用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `environment` | 字符串 | 否 | 返回部署到给定环境的合并请求。 |
| `in` | 字符串 | 否 | 更改 `search` 属性的作用域。可选值：`title`、`description` 或以逗号分隔的组合字符串。默认为 `title,description`。 |
| `labels` | 字符串 | 否 | 返回与逗号分隔的标签列表匹配的合并请求。`None` 列出所有无标签的合并请求。`Any` 列出所有至少有一个标签的合并请求。预定义名称不区分大小写。 |
| `merge_user_id` | 整数 | 否 | 返回由给定用户 `id` 合并的合并请求。与 `merge_user_username` 互斥。[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/140002) 极狐GitLab 17.0。 |
| `merge_user_username` | 字符串 | 否 | 返回由给定 `username` 合并的合并请求。与 `merge_user_id` 互斥。[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/140002) 极狐GitLab 17.0。 |
| `milestone` | 字符串 | 否 | 返回特定里程碑的合并请求。`None` 返回无里程碑的合并请求。`Any` 返回有指定里程碑的合并请求。 |
| `my_reaction_emoji` | 字符串 | 否 | 返回已认证用户通过给定 `emoji` 回应过的合并请求。`None` 返回无回应的议题。`Any` 返回至少有一个回应的议题。 |
| `non_archived` | 布尔值 | 否 | 如果为 `true`，则仅返回未归档项目的合并请求。默认为 `false`。 |
| `not` | 哈希 | 否 | 返回不匹配所提供参数的合并请求。接受：`labels`、`milestone`、`author_id`、`author_username`、`assignee_id`、`assignee_username`、`reviewer_id`、`reviewer_username`、`my_reaction_emoji`。 |
| `order_by` | 字符串 | 否 | 按 `created_at`、`updated_at`、`merged_at`（[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/147052) 极狐GitLab 17.2）、`label_priority`、`priority`、`milestone_due`、`popularity` 或 `title` 字段排序返回合并请求。默认为 `created_at`。 |
| `reviewer_id` | 整数或字符串 | 否 | 返回指定用户 `id` 为[审核人](../user/project/merge_requests/reviews/_index.md)的合并请求。`None` 返回无审核人的合并请求。`Any` 返回有任一审核人的合并请求。与 `reviewer_username` 互斥。 |
| `reviewer_username` | 字符串 | 否 | 返回指定 `username` 为[审核人](../user/project/merge_requests/reviews/_index.md)的合并请求。`None` 返回无审核人的合并请求。`Any` 返回有任一审核人的合并请求。与 `reviewer_id` 互斥。 |
| `scope` | 字符串 | 否 | 返回给定作用域的合并请求：`created_by_me`、`assigned_to_me`、`reviews_for_me` 或 `all`。`reviews_for_me` 返回当前用户被指定为审核人的合并请求。默认为 `created_by_me`。 |
| `search` | 字符串 | 否 | 在合并请求的 `title` 和 `description` 中搜索。可与 `in` 属性结合使用。 |
| `sort` | 字符串 | 否 | 以 `asc` 或 `desc` 顺序返回合并请求。默认为 `desc`。 |
| `source_branch` | 字符串 | 否 | 返回具有给定源分支的合并请求。 |
| `state` | 字符串 | 否 | 返回所有合并请求（`all`）或仅处于 `opened`、`closed`、`locked` 或 `merged` 状态的合并请求。默认为 `all`。 |
| `target_branch` | 字符串 | 否 | 返回具有给定目标分支的合并请求。 |
| `updated_after` | 日期时间 | 否 | 返回在给定日期时间或之后更新的合并请求。应采用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `updated_before` | 日期时间 | 否 | 返回在给定日期时间或之前更新的合并请求。应采用 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `view` | 字符串 | 否 | 如果为 `simple`，则返回合并请求的 `iid`、URL、标题、描述和基本状态。 |
| `wip` | 字符串 | 否 | 根据 `wip` 状态筛选合并请求。`yes` 仅返回草稿合并请求，`no` 返回非草稿合并请求。 |
| `with_labels_details` | 布尔值 | 否 | 如果为 `true`，则在标签字段中为每个标签返回更多详细信息：`:name`、`:color`、`:description`、`:description_html`、`:text_color`。默认为 `false`。 |
| `with_merge_status_recheck` | 布尔值 | 否 | 如果为 `true`，则此投影请求（但不保证）异步重新计算 `merge_status` 字段。启用 `restrict_merge_status_recheck` [功能标志](../administration/feature_flags/_index.md)可在不具备开发者、维护者或所有者角色的用户请求时忽略此属性。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)。如果 `view` 设置为 `simple`，则返回字段的子集。否则，响应属性包括：

| 属性 | 类型 | 描述 |
|---|---|---|
| `allow_collaboration` | 布尔值 | 如果为 `true`，则此派生允许来自可合并到目标分支的成员的协作。仅用于来自派生的合并请求。 |
| `allow_maintainer_to_push` | 布尔值 | 已弃用。请改用 `allow_collaboration`。 |
| `approvals_before_merge` | 整数 | 在 极狐GitLab 16.0 中[弃用]。要配置审批规则，请改为使用[合并请求批准 API](merge_request_approvals.md)。仅专业版和旗舰版可用。 |
| `assignee[]` | 对象 | 已弃用。请改用 `assignees`。 |
| `assignees[]` | 数组 | 指派给合并请求的用户。 |
| `assignees.avatar_url` | 字符串 | 指派人头像的完整 URL。 |
| `assignees.id` | 整数 | 指派人的唯一 ID。 |
| `assignees.locked` | 布尔值 | 如果为 `true`，则指派人账户因多次身份验证失败而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `assignees.name` | 字符串 | 指派人的显示名称。可能根据当前用户的权限被编辑。 |
| `assignees.public_email` | 字符串 | 指派人的公共电子邮件地址。 |
| `assignees.state` | 字符串 | 指派人账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `assignees.username` | 字符串 | 合并请求指派人的用户名。 |
| `assignees.web_url` | 字符串 | 指派人个人信息页的完整 URL。 |
| `author[]` | 对象 | 包含创建合并请求的用户信息的对象。 |
| `author.avatar_url` | 字符串 | 作者头像的完整 URL。 |
| `author.id` | 整数 | 创建合并请求的用户的唯一 ID。 |
| `author.locked` | 布尔值 | 如果为 `true`，则作者账户因多次身份验证失败而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `author.name` | 字符串 | 作者的显示名称。可能根据当前用户的权限被编辑。 |
| `author.public_email` | 字符串 | 作者的公共电子邮件地址。 |
| `author.state` | 字符串 | 作者账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `author.username` | 字符串 | 合并请求作者的用户名。 |
| `author.web_url` | 字符串 | 作者个人信息页的完整 URL。 |
| `blocking_discussions_resolved` | 布尔值 | 如果为 `true`，则在合并之前必须解决合并请求中的所有讨论线程。 |
| `closed_at` | 日期时间 | 合并请求关闭的时间戳。 |
| `closed_by[]` | 对象 | 包含关闭合并请求的用户信息的对象。如果为 `null`，则合并请求处于开启状态。 |
| `closed_by.avatar_url` | 字符串 | 关闭者头像的完整 URL。 |
| `closed_by.id` | 整数 | 关闭合并请求的用户的唯一 ID。 |
| `closed_by.locked` | 布尔值 | 如果为 `true`，则关闭者账户因多次身份验证失败而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `closed_by.name` | 字符串 | 关闭者的显示名称。可能根据当前用户的权限被编辑。 |
| `closed_by.public_email` | 字符串 | 关闭者的公共电子邮件地址。 |
| `closed_by.state` | 字符串 | 关闭者账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `closed_by.username` | 字符串 | 关闭合并请求的用户名。 |
| `closed_by.web_url` | 字符串 | 关闭者个人信息页的完整 URL。 |
| `created_at` | 日期时间 | 合并请求创建的时间戳。 |
| `description` | 字符串 | 合并请求的描述。包含为缓存而渲染为 HTML 的 Markdown。 |
| `description_html` | 字符串 | 如果设置了 `render_html`，则为描述渲染后的 HTML 版本。 |
| `detailed_merge_status` | 字符串 | 详细的合并状态信息。有关可能的值列表，请参阅[合并状态](#merge-status)。 |
| `discussion_locked` | 布尔值 | 如果为 `true`，则讨论被锁定。只有项目成员可以添加、编辑或解决锁定讨论中的评论。 |
| `downvotes` | 整数 | 合并请求的反对票数。 |
| `draft` | 布尔值 | 如果为 `true`，则合并请求标记为 `draft` 状态。 |
| `force_remove_source_branch` | 布尔值 | 如果为 `true`，则项目设置强制在合并后删除源分支。 |
| `has_conflicts` | 布尔值 | 如果为 `true`，则合并请求有冲突且无法合并。依赖于 `merge_status` 属性。除非 `merge_status` 为 `cannot_be_merged`，否则返回 `false`。 |
| `id` | 整数 | 合并请求的唯一 ID。 |
| `iid` | 整数 | 合并请求在项目中的内部 ID。 |
| `imported` | 布尔值 | 如果为 `true`，则合并请求是导入的。 |
| `imported_from` | 字符串 | 导入来源，例如 `Bitbucket`。 |
| `labels[]` | 数组 | 分配给合并请求的标签数组。如果 `with_labels_details` 为 `true`，则为每个标签返回一个对象数组。 |
| `labels.archived` | 布尔值 | 如果 `with_labels_details` 为 `true`，标签已归档。 |
| `labels.color` | 字符串 | 如果 `with_labels_details` 为 `true`，标签的背景颜色。 |
| `labels.description` | 字符串 | 如果 `with_labels_details` 为 `true`，标签的描述文本。如果为 `null`，则该标签无描述。 |
| `labels.description_html` | 字符串 | 如果 `with_labels_details` 为 `true`，标签描述的 HTML 渲染版本。如果为 `null`，则该标签无描述。 |
| `labels.id` | 整数 | 如果 `with_labels_details` 为 `true`，标签的唯一 ID。 |
| `labels.name` | 字符串 | 如果 `with_labels_details` 为 `true`，标签的名称。 |
| `labels.text_color` | 字符串 | 如果 `with_labels_details` 为 `true`，标签的文本颜色。 |
| `merge_after` | 日期时间 | 如果设置，则为合并请求可以合并的时间戳之后。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/510992) 极狐GitLab 17.8。 |
| `merge_commit_sha` | 字符串 | 如果设置，则为合并请求提交的 SHA。合并前返回 `null`。 |
| `merge_status` | 字符串 | 合并请求的状态。请改用 `detailed_merge_status`，该字段涵盖了所有可能的状态。影响 `has_conflicts` 属性。有关响应数据的重要说明，请参阅[单个合并请求响应说明](#single-merge-request-response-notes)。在 极狐GitLab 15.6 中[弃用]。<!-- Do not remove line until field is actually removed --> |
| `merge_user` | 对象 | 包含合并该合并请求、将其设置为自动合并，或为 `null` 的用户信息的对象。 |
| `merge_when_pipeline_succeeds` | 布尔值 | 如果为 `true`，则合并请求被设置为自动合并。 |
| `merged_at` | 日期时间 | 合并请求合并的时间戳。 |
| `merged_by[]` | 对象 | 已弃用。请改用 `merge_user`。 |
| `milestone[]` | 对象 | 包含分配给合并请求的里程碑信息的对象。 |
| `milestone.created_at` | 日期时间 | 里程碑创建的时间戳。 |
| `milestone.description` | 字符串 | 里程碑的描述文本。如果为 `null`，则该里程碑无描述。 |
| `milestone.due_date` | 日期 | 里程碑的截止日期。如果为 `null`，则该里程碑无截止日期。 |
| `milestone.expired` | 布尔值 | 如果为 `true`，则里程碑已过期。 |
| `milestone.group_id` | 整数 | 里程碑所属群组的 ID。仅在里程碑为群组里程碑时包含。 |
| `milestone.id` | 整数 | 里程碑的唯一 ID。 |
| `milestone.iid` | 整数 | 里程碑在项目或群组中的内部 ID。 |
| `milestone.project_id` | 整数 | 里程碑所属项目的 ID。仅在里程碑为项目里程碑时包含。 |
| `milestone.start_date` | 日期 | 里程碑的开始日期。如果为 `null`，则该里程碑无开始日期。 |
| `milestone.state` | 字符串 | 里程碑的当前状态，如 `active` 或 `closed`。 |
| `milestone.title` | 字符串 | 里程碑的名称。 |
| `milestone.updated_at` | 日期时间 | 里程碑最后更新的时间戳。 |
| `milestone.web_url` | 字符串 | 查看里程碑的完整 Web URL。 |
| `prepared_at` | 日期时间 | 合并请求准备就绪的时间戳。此字段在所有的[准备步骤](#preparation-steps)完成后仅填充一次，添加更多更改时不会更新。 |
| `project_id` | 整数 | 包含合并请求的项目的 ID。 |
| `reference` | 字符串 | 已弃用。请改用 `references`。 |
| `references[]` | 对象 | 包含合并请求所有内部引用的对象。 |
| `references.full` | 字符串 | 对合并请求的完整引用，包括完整的项目路径，如 `gitlab-org/gitlab!123`。跨群组或项目请求时，等同于 `references.relative`。 |
| `references.relative` | 字符串 | 相对于特定项目或群组的引用：当前项目的合并请求为 `!123`，同一群组下其他项目则为 `other-project!123`。 |
| `references.short` | 字符串 | 合并请求的最短引用，如 `!123`。从合并请求自身的项目获取时，等同于 `references.relative`。 |
| `reviewers[]` | 数组 | 合并请求的审核人。 |
| `reviewers.avatar_url` | 字符串 | 审核人头像的完整 URL。 |
| `reviewers.id` | 整数 | 审核人的唯一 ID。 |
| `reviewers.locked` | 布尔值 | 如果为 `true`，则审核人账户因多次身份验证失败而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `reviewers.name` | 字符串 | 审核人的显示名称。可能根据当前用户的权限被编辑。 |
| `reviewers.public_email` | 字符串 | 审核人的公共电子邮件地址。 |
| `reviewers.state` | 字符串 | 审核人账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `reviewers.username` | 字符串 | 合并请求审核人的用户名。 |
| `reviewers.web_url` | 字符串 | 审核人个人信息页的完整 URL。 |
| `sha` | 字符串 | 源分支中头部提交的 SHA。 |
| `should_remove_source_branch` | 布尔值 | 如果为 `true`，则在合并后删除源分支。 |
| `source_branch` | 字符串 | 源分支的名称。 |
| `source_project_id` | 整数 | 源项目的 ID。 |
| `squash` | 布尔值 | 如果为 `true`，则在合并时压缩提交。 |
| `squash_commit_sha` | 字符串 | 如果设置，则为压缩提交的 SHA。合并前为空。 |
| `squash_on_merge` | 布尔值 | 如果为 `true`，则在合并时压缩提交。 |
|
```markdown
<a id="state"></a>

`state`                                  | string   | 合并请求的当前状态。可能的值：`opened`、`closed`、`merged` 或 `locked`。 |
| `target_branch`                          | string   | 目标分支的名称。 |
| `target_project_id`                      | integer  | 目标项目的 ID。 |
| `task_completion_status[]`               | object   | 包含任务列表完成状态信息的对象。 |
| `task_completion_status.completed_count` | integer  | 合并请求描述中已完成任务列表项的数量。如果合并请求没有描述或没有任务列表项，则返回 `0`。 |
| `task_completion_status.count`           | integer  | 合并请求描述中找到的任务列表项总数。如果合并请求没有描述或没有任务列表项，则返回 `0`。 |
| `time_stats[]`                           | object   | 包含此合并请求的时间跟踪信息的对象。 |
| `time_stats.human_time_estimate`         | string   | `time_stats.time_estimate` 的人类可读格式，例如 `3h 30m`。 |
| `time_stats.human_total_time_spent`      | string   | `time_stats.total_time_spent` 的人类可读格式，例如 `3h 30m`。 |
| `time_stats.time_estimate`               | integer  | 完成合并请求的预估时间，以秒为单位。 |
| `time_stats.total_time_spent`            | integer  | 在合并请求上花费的总时间，以秒为单位。 |
| `title`                                  | string   | 合并请求标题。 |
| `title_html`                             | string   | 如果 `render_html` 为 `true`，则为标题的渲染后 HTML 版本。 |
| `updated_at`                             | dateTime | 合并请求最后一次更新的时间戳。 |
| `upvotes`                                | integer  | 合并请求的赞同票数。 |
| `user_notes_count`                       | integer  | 用户评论数量。 |
| `web_url`                                | string   | 查看合并请求的 Web URL。 |
| `work_in_progress`                       | boolean  | 已弃用。请改用 `draft`。 |

其他可能的响应：

- `401 Unauthorized` 如果访问令牌无效。
- `408 Request Timeout` 如果数据库查询超时。
- `422 Unprocessable Entity` 如果验证失败。
- `429 Too Many Requests` 如果使用了 `search` 参数且请求被限流。

示例响应：

```json
[
  {
    "id": 1,
    "iid": 1,
    "project_id": 3,
    "title": "test1",
    "description": "fixed login page css paddings",
    "state": "merged",
    "imported": false,
    "imported_from": "none",
    "merged_by": { // Deprecated and will be removed in API v5, use `merge_user` instead
      "id": 87854,
      "name": "Douwe Maan",
      "username": "DouweM",
      "state": "active",
      "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
      "web_url": "https://gitlab.com/DouweM"
    },
    "merge_user": {
      "id": 87854,
      "name": "Douwe Maan",
      "username": "DouweM",
      "state": "active",
      "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
      "web_url": "https://gitlab.com/DouweM"
    },
    "merged_at": "2018-09-07T11:16:17.520Z",
    "merge_after": "2018-09-07T11:16:00.000Z",
    "prepared_at": "2018-09-04T11:16:17.520Z",
    "closed_by": null,
    "closed_at": null,
    "created_at": "2017-04-29T08:46:00Z",
    "updated_at": "2017-04-29T08:46:00Z",
    "target_branch": "main",
    "source_branch": "test1",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "admin",
      "state": "active",
      "avatar_url": null,
      "web_url" : "https://gitlab.example.com/admin"
    },
    "assignee": {
      "id": 1,
      "name": "Administrator",
      "username": "admin",
      "state": "active",
      "avatar_url": null,
      "web_url" : "https://gitlab.example.com/admin"
    },
    "assignees": [{
      "name": "Miss Monserrate Beier",
      "username": "axel.block",
      "id": 12,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/axel.block"
    }],
    "reviewers": [{
      "id": 2,
      "name": "Sam Bauch",
      "username": "kenyatta_oconnell",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/956c92487c6f6f7616b536927e22c9a0?s=80&d=identicon",
      "web_url": "http://gitlab.example.com//kenyatta_oconnell"
    }],
    "source_project_id": 2,
    "target_project_id": 3,
    "labels": [
      "Community contribution",
      "Manage"
    ],
    "draft": false,
    "work_in_progress": false,
    "milestone": {
      "id": 5,
      "iid": 1,
      "project_id": 3,
      "title": "v2.0",
      "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
      "state": "closed",
      "created_at": "2015-02-02T19:49:26.013Z",
      "updated_at": "2015-02-02T19:49:26.013Z",
      "due_date": "2018-09-22",
      "start_date": "2018-08-08",
      "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
    },
    "merge_when_pipeline_succeeds": true,
    "merge_status": "can_be_merged",
    "detailed_merge_status": "not_open",
    "sha": "8888888888888888888888888888888888888888",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 1,
    "discussion_locked": null,
    "should_remove_source_branch": true,
    "force_remove_source_branch": false,
    "allow_collaboration": false,
    "allow_maintainer_to_push": false,
    "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
    "references": {
      "short": "!1",
      "relative": "my-group/my-project!1",
      "full": "my-group/my-project!1"
    },
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "squash": false,
    "task_completion_status":{
      "count":0,
      "completed_count":0
    }
  }
]
```

<a id="merge-requests-list-response-notes"></a>

### 合并请求列表响应说明

- 列出合并请求时可能不会主动更新 `merge_status`（这也影响 `has_conflicts`），因为这可能是一个昂贵的操作。
  如果你需要此端点中的这些字段值，请在查询时将 `with_merge_status_recheck` 参数设置为 `true`。
- 关于合并请求对象字段的说明，请参阅[单个合并请求响应说明](#single-merge-request-response-notes)。

<a id="list-project-merge-requests"></a>

## 列出项目合并请求

列出项目的所有合并请求。

```plaintext
GET /projects/:id/merge_requests
GET /projects/:id/merge_requests?state=opened
GET /projects/:id/merge_requests?state=all
GET /projects/:id/merge_requests?iids[]=42&iids[]=43
GET /projects/:id/merge_requests?milestone=release
GET /projects/:id/merge_requests?labels=bug,reproduced
GET /projects/:id/merge_requests?my_reaction_emoji=star
```

支持的属性：

| 属性                            | 类型           | 是否必需 | 描述 |
| ------------------------------- | -------------- | -------- | ----------- |
| `id`                            | integer 或 string | 是    | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `iids[]`                        | integer 数组    | 否    | 返回与所提供的 IID 匹配的合并请求。 |
| `approved_by_ids[]`             | integer 数组    | 否    | 返回由所有具有给定 `id` 的用户批准的合并请求，最多 5 个用户。`None` 返回没有批准的合并请求。`Any` 返回有批准的合并请求。 |
| `approved_by_usernames[]`       | string 数组     | 否    | 返回由所有具有给定 `username` 的用户批准的合并请求，最多 5 个用户。`None` 返回没有批准的合并请求。`Any` 返回有批准的合并请求。 |
| `approver_ids[]`                | integer 数组    | 否    | 返回根据批准规则，所有具有指定 `id` 的用户作为合格批准者的合并请求。`None` 返回没有合格批准者的合并请求。`Any` 返回至少有一个合格批准者的合并请求。仅限专业版和旗舰版。 |
| `assignee_id`                   | integer 或 string | 否 | 返回分配给给定用户 `id` 的合并请求。`None` 返回未分配的合并请求。`Any` 返回有指派人的合并请求。与 `assignee_username` 互斥。 |
| `assignee_username[]`           | string 数组     | 否    | 返回分配给给定用户名的合并请求。与 `assignee_id` 互斥。 |
| `author_id`                     | integer        | 否    | 返回由给定用户 `id` 创建的合并请求。与 `author_username` 互斥。 |
| `author_username`               | string         | 否    | 返回由给定 `username` 创建的合并请求。与 `author_id` 互斥。 |
| `created_after`                 | datetime       | 否    | 返回在给定日期和时间或之后创建的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `created_before`                | datetime       | 否    | 返回在给定日期和时间或之前创建的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `deployed_after`                | datetime       | 否    | 返回在给定日期和时间之后部署的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `deployed_before`               | datetime       | 否    | 返回在给定日期和时间之前部署的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `environment`                   | string         | 否    | 返回部署到给定环境的合并请求。 |
| `in`                            | string         | 否    | 更改 `search` 属性的范围。可以是 `title`、`description`，或用逗号连接它们的字符串。默认是 `title,description`。 |
| `labels`                        | string         | 否    | 返回匹配逗号分隔标签列表的合并请求。`None` 列出所有没有标签的合并请求。`Any` 列出所有至少有一个标签的合并请求。预定义名称不区分大小写。 |
| `merge_user_id`                 | integer        | 否    | 返回由给定用户 `id` 的用户合并的合并请求。与 `merge_user_username` 互斥。[在极狐GitLab 17.0 中引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/140002)。 |
| `merge_user_username`           | string         | 否    | 返回由给定 `username` 的用户合并的合并请求。与 `merge_user_id` 互斥。[在极狐GitLab 17.0 中引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/140002)。 |
| `milestone`                     | string         | 否    | 返回特定里程碑的合并请求。`None` 返回没有里程碑的合并请求。`Any` 返回有已分配里程碑的合并请求。 |
| `my_reaction_emoji`             | string         | 否    | 返回由认证用户对给定 `emoji` 做出反应的合并请求。`None` 返回未收到反应的议题。`Any` 返回至少收到一个反应的议题。 |
| `not`                           | hash           | 否    | 返回不符合所提供参数的合并请求。接受：`labels`、`milestone`、`author_id`、`author_username`、`assignee_id`、`assignee_username`、`reviewer_id`、`reviewer_username`、`my_reaction_emoji`。 |
| `order_by`                      | string         | 否    | 按照 `created_at`、`updated_at`、`merged_at`（[在极狐GitLab 17.2 中引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/147052)）、`label_priority`、`priority`、`milestone_due`、`popularity` 或 `title` 字段排序返回合并请求。默认是 `created_at`。 |
| `reviewer_id`                   | integer 或 string | 否 | 返回将用户作为[审核者](../user/project/merge_requests/reviews/_index.md)（给定用户 `id`）的合并请求。`None` 返回没有审核者的合并请求。`Any` 返回有任何审核者的合并请求。与 `reviewer_username` 互斥。  |
| `reviewer_username`             | string         | 否    | 返回将用户作为[审核者](../user/project/merge_requests/reviews/_index.md)（给定 `username`）的合并请求。`None` 返回没有审核者的合并请求。`Any` 返回有任何审核者的合并请求。与 `reviewer_id` 互斥。 |
| `scope`                         | string         | 否    | 返回给定范围的合并请求：`created_by_me`、`assigned_to_me`、`reviews_for_me` 或 `all`。`reviews_for_me` 返回当前用户被指派为审核者的合并请求。默认为 `all`。 |
| `search`                        | string         | 否    | 搜索匹配其 `title` 和 `description` 的合并请求。与 `in` 属性结合使用。 |
| `sort`                          | string         | 否    | 按照 `asc` 或 `desc` 顺序排序返回合并请求。默认是 `desc`。 |
| `source_branch`                 | string         | 否    | 返回具有给定源分支的合并请求。 |
| `state`                         | string         | 否    | 返回所有合并请求 (`all`) 或仅返回 `opened`、`closed`、`locked` 或 `merged` 的。默认为 `all`。 |
| `target_branch`                 | string         | 否    | 返回具有给定目标分支的合并请求。 |
| `updated_after`                 | datetime       | 否    | 返回在给定日期和时间或之后更新的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `updated_before`                | datetime       | 否    | 返回在给定日期和时间或之前更新的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `view`                          | string         | 否    | 如果为 `simple`，则返回合并请求的 `iid`、URL、标题、描述和基本状态。 |
| `wip`                           | string         | 否    | 根据合并请求的 `wip` 状态过滤。使用 `yes` 仅返回草稿合并请求，使用 `no` 返回非草稿合并请求。 |
| `with_labels_details`           | boolean        | 否    | 如果为 `true`，响应会为每个标签的标签字段返回更多详情：`:name`、`:color`、`:description`、`:description_html`、`:text_color`。默认是 `false`。 |
| `with_merge_status_recheck`     | boolean        | 否    | 如果为 `true`，此投影请求（但不保证）异步重新计算 `merge_status` 字段。启用 `restrict_merge_status_recheck` [功能标志](../administration/feature_flags/_index.md) 可在没有开发者、维护者或所有者角色的用户请求时忽略此属性。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                               | 类型     | 描述 |
| ---------------------------------- | -------- | ----------- |
| `[].id`                            | integer  | 合并请求的 ID。 |
| `[].iid`                           | integer  | 合并请求的内部 ID。 |
| `[].approvals_before_merge`        | integer  | 此合并请求合并前所需的批准数量。要配置批准规则，请参阅[合并请求批准 API](merge_request_approvals.md)。[在极狐GitLab 16.0 中弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/353097)。仅限专业版和旗舰版。 |
| `[].assignee`                      | object   | 合并请求的第一个指派人。 |
| `[].assignees`                     | array    | 合并请求的指派人。 |
| `[].author`                        | object   | 创建此合并请求的用户。 |
| `[].blocking_discussions_resolved` | boolean  | 指示是否所有讨论都已解决（仅当合并请求合并前要求全部解决时）。 |
| `[].closed_at`                     | datetime | 合并请求关闭的时间戳。 |
| `[].closed_by`                     | object   | 关闭此合并请求的用户。 |
| `[].created_at`                    | datetime | 合并请求创建的时间戳。 |
| `[].description`                   | string   | 合并请求的描述。 |
| `[].detailed_merge_status`         | string   | 合并请求的详细合并状态。有关可能值的列表，请参阅[合并状态](#merge-status)。 |
| `[].discussion_locked`             | boolean  | 指示合并请求上的评论是否仅对成员锁定。 |
| `[].downvotes`                     | integer  | 合并请求的反对票数。 |
| `[].draft`                         | boolean  | 指示合并请求是否为草稿。 |
| `[].force_remove_source_branch`    | boolean  | 指示项目设置是否导致合并后删除源分支。 |
| `[].has_conflicts`                 | boolean  | 指示合并请求是否有冲突且无法合并。取决于 `merge_status` 属性。除非 `merge_status` 为 `cannot_be_merged`，否则返回 `false`。 |
| `[].labels`                        | array    | 合并请求的标签。 |
| `[].merge_commit_sha`              | string   | 合并请求提交的 SHA。合并前返回 `null`。 |
| `[].merge_status`                  | string   | 合并请求的状态。可以是 `unchecked`、`checking`、`can_be_merged`、`cannot_be_merged` 或 `cannot_be_merged_recheck`。影响 `has_conflicts` 属性。有关响应数据的重要说明，请参阅[单个合并请求响应说明](#single-merge-request-response-notes)。[在极狐GitLab 15.6 中弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/3169#note_1162532204)。改用 `detailed_merge_status`。<!-- 在实际删除该字段前，请勿移除此行 --> |
| `[].merge_user`                    | object   | 合并此合并请求的用户、将其设置为自动合并的用户，或 `null`。 |
| `[].merge_when_pipeline_succeeds`  | boolean  | 指示合并请求是否设置为自动合并。 |
| `[].merged_at`                     | datetime | 合并请求合并的时间戳。 |
| `[].merged_by`                     | object   | 合并此合并请求或将其设置为自动合并的用户。[在极狐GitLab 14.7 中弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/350534)，并计划在 [API 版本 5](https://gitlab.com/groups/gitlab-org/-/epics/8115) 中移除。改用 `merge_user`。<!-- 在实际删除该字段前，请勿移除此行 --> |
| `[].milestone`                     | object   | 合并请求的里程碑。 |
| `[].prepared_at`                   | datetime | 合并请求准备就绪的时间戳。此字段仅在所有[准备步骤](#preparation-steps)完成后填充一次，如果添加更多更改，则不会更新。 |
| `[].project_id`                    | integer  | 合并请求所在项目的 ID。始终等于 `target_project_id`。 |
| `[].reference`                     | string   | 合并请求的内部引用。默认以短格式返回。[在极狐GitLab 12.7 中弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/20354)，并计划在 [API 版本 5](https://gitlab.com/groups/gitlab-org/-/epics/8115) 中移除。改用 `references`。<!-- 在实际删除该字段前，请勿移除此行 --> |
| `[].references`                    | object   | 合并请求的内部引用。包括 `short`、`relative` 和 `full` 引用。`references.relative` 相对于合并请求的群组或项目。当从合并请求的项目获取时，`relative` 和 `short` 格式相同。当跨群组或项目请求时，`relative` 和 `full` 格式相同。|
| `[].reviewers`                     | array    | 合并请求的审核者。 |
| `[].sha`                           | string   | 合并请求的 diff head SHA。 |
| `[].should_remove_source_branch`   | boolean  | 指示合并后是否应删除合并请求的源分支。 |
| `[].source_branch`                 | string   | 合并请求的源分支。 |
| `[].source_project_id`             | integer  | 合并请求源项目的 ID。等于 `target_project_id`，除非合并请求源自 fork。 |
| `[].squash`                        | boolean  | 如果为 `true`，在合并时将所有提交压缩为单个提交。[项目设置](../user/project/merge_requests/squash_and_merge.md#configure-squash-options-for-a-project)可能会覆盖此值。改用 `squash_on_merge` 以考虑项目压缩选项。 |
| `[].squash_commit_sha`             | string   | 压缩提交的 SHA。合并前为空。 |
| `[].squash_on_merge`               | boolean  | 指示合并时是否压缩合并请求。 |
| `[].state`                         | string   | 合并请求的状态。可以是 `opened`、`closed`、`merged`、`locked`。 |
| `[].target_branch`                 | string   | 合并请求的目标分支。 |
| `[].target_project_id`             | integer  | 合并请求目标项目的 ID。 |
| `[].task_completion_status`        | object   | 任务的完成状态。包括 `count` 和 `completed_count`。 |
| `[].time_stats`                    | object   | 合并请求的时间跟踪统计信息。包括 `time_estimate`、`total_time_spent`、`human_time_estimate` 和 `human_total_time_spent`。 |
| `[].title`                         | string   | 合并请求的标题。 |
| `[].updated_at`                    | datetime | 合并请求更新的时间戳。 |
| `[].upvotes`                       | integer  | 合并请求的赞同票数。 |
| `[].user_notes_count`              | integer  | 合并请求的用户评论数量。 |
| `[].web_url`                       | string   | 合并请求的 Web URL。 |
| `[].work_in_progress`              | boolean  | 已弃用：改用 `draft`。指示合并请求是否为草稿。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests"
```

示例响应：
```
```json
[
  {
    "id": 1,
    "iid": 1,
    "project_id": 3,
    "title": "test1",
    "description": "修复了登录页面 CSS 的内边距",
    "state": "merged",
    "imported": false,
    "imported_from": "none",
    "merged_by": { // 已弃用，将在 API v5 中移除，请使用 `merge_user` 替代
      "id": 87854,
      "name": "Douwe Maan",
      "username": "DouweM",
      "state": "active",
      "locked": false,
      "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
      "web_url": "https://gitlab.com/DouweM"
    },
    "merge_user": {
      "id": 87854,
      "name": "Douwe Maan",
      "username": "DouweM",
      "state": "active",
      "locked": false,
      "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
      "web_url": "https://gitlab.com/DouweM"
    },
    "merged_at": "2018-09-07T11:16:17.520Z",
    "merge_after": "2018-09-07T11:16:00.000Z",
    "prepared_at": "2018-09-04T11:16:17.520Z",
    "closed_by": null,
    "closed_at": null,
    "created_at": "2017-04-29T08:46:00Z",
    "updated_at": "2017-04-29T08:46:00Z",
    "target_branch": "main",
    "source_branch": "test1",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "admin",
      "state": "active",
      "locked": false,
      "avatar_url": null,
      "web_url" : "https://gitlab.example.com/admin"
    },
    "assignee": {
      "id": 1,
      "name": "Administrator",
      "username": "admin",
      "state": "active",
      "locked": false,
      "avatar_url": null,
      "web_url" : "https://gitlab.example.com/admin"
    },
    "assignees": [{
      "name": "Miss Monserrate Beier",
      "username": "axel.block",
      "id": 12,
      "state": "active",
      "locked": false,
      "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/axel.block"
    }],
    "reviewers": [{
      "id": 2,
      "name": "Sam Bauch",
      "username": "kenyatta_oconnell",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/956c92487c6f6f7616b536927e22c9a0?s=80&d=identicon",
      "web_url": "http://gitlab.example.com//kenyatta_oconnell"
    }],
    "source_project_id": 2,
    "target_project_id": 3,
    "labels": [
      "Community contribution",
      "Manage"
    ],
    "draft": false,
    "work_in_progress": false,
    "milestone": {
      "id": 5,
      "iid": 1,
      "project_id": 3,
      "title": "v2.0",
      "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
      "state": "closed",
      "created_at": "2015-02-02T19:49:26.013Z",
      "updated_at": "2015-02-02T19:49:26.013Z",
      "due_date": "2018-09-22",
      "start_date": "2018-08-08",
      "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
    },
    "merge_when_pipeline_succeeds": true,
    "merge_status": "can_be_merged",
    "detailed_merge_status": "not_open",
    "sha": "8888888888888888888888888888888888888888",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 1,
    "discussion_locked": null,
    "should_remove_source_branch": true,
    "force_remove_source_branch": false,
    "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
    "reference": "!1",
    "references": {
      "short": "!1",
      "relative": "!1",
      "full": "my-group/my-project!1"
    },
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "squash": false,
    "squash_on_merge": false,
    "task_completion_status":{
      "count":0,
      "completed_count":0
    },
    "has_conflicts": false,
    "blocking_discussions_resolved": true,
    "approvals_before_merge": 2
  }
]
```

关于响应数据的重要说明，请参阅[合并请求列表响应说明](#merge-requests-list-response-notes)。

<a id="list-group-merge-requests"></a>

## 列出群组合并请求

列出一个群组及其子群组的所有合并请求。

```plaintext
GET /groups/:id/merge_requests
GET /groups/:id/merge_requests?state=opened
GET /groups/:id/merge_requests?state=all
GET /groups/:id/merge_requests?milestone=release
GET /groups/:id/merge_requests?labels=bug,reproduced
GET /groups/:id/merge_requests?my_reaction_emoji=star
```

支持的属性：

| 属性                   | 类型              | 是否必需 | 描述 |
|-----------------------------|-------------------|----------|-------------|
| `id`                        | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approved`                  | string            | 否       | 如果为 `yes`，则仅返回已批准的合并请求。`no` 仅返回未批准的合并请求。 |
| `approved_by_ids[]`         | integer array     | 否       | 返回由所有给定 `id` 的用户批准的合并请求，最多 5 个用户。`None` 返回没有批准的合并请求。`Any` 返回有批准的合并请求。 |
| `approved_by_usernames[]`   | string array      | 否       | 返回由所有给定 `username` 的用户批准的合并请求，最多 5 个用户。`None` 返回没有批准的合并请求。`Any` 返回有批准的合并请求。 |
| `approver_ids[]`            | integer array     | 否       | 返回根据审批规则，所有指定 `id` 的用户都是合格审批者的合并请求。`None` 返回没有合格审批者的合并请求。`Any` 返回至少有一个合格审批者的合并请求。仅限专业版和旗舰版。 |
| `assignee_id`               | integer 或 string | 否       | 返回分配给给定用户 `id` 的合并请求。`None` 返回未分配的合并请求。`Any` 返回有指派的合并请求。与 `assignee_username` 互斥。 |
| `assignee_username[]`       | string array      | 否       | 返回分配给给定用户名的合并请求。与 `assignee_id` 互斥。 |
| `author_id`                 | integer           | 否       | 返回由给定用户 `id` 创建的合并请求。与 `author_username` 互斥。 |
| `author_username`           | string            | 否       | 返回由给定 `username` 创建的合并请求。与 `author_id` 互斥。 |
| `created_after`             | datetime          | 否       | 返回在给定日期和时间或之后创建的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `created_before`            | datetime          | 否       | 返回在给定日期和时间或之前创建的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `deployed_after`            | datetime          | 否       | 返回在给定日期和时间之后部署的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `deployed_before`           | datetime          | 否       | 返回在给定日期和时间之前部署的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `environment`               | string            | 否       | 返回部署到给定环境的合并请求。 |
| `in`                        | string            | 否       | 更改 `search` 属性的范围。`title`、`description` 或一个用逗号连接它们的字符串。默认是 `title,description`。 |
| `labels`                  | string             | 否       | 返回匹配逗号分隔标签列表的合并请求。`None` 列出所有没有标签的合并请求。`Any` 列出所有至少有一个标签的合并请求。预定义的标签名称不区分大小写。 |
| `merge_user_id`             | integer           | 否       | 返回由给定用户 `id` 合并的合并请求。与 `merge_user_username` 互斥。在极狐GitLab 17.0 中引入。 |
| `merge_user_username`       | string            | 否       | 返回由给定 `username` 的用户合并的合并请求。与 `merge_user_id` 互斥。在极狐GitLab 17.0 中引入。 |
| `milestone`                 | string            | 否       | 返回特定里程碑的合并请求。`None` 返回没有里程碑的合并请求。`Any` 返回已分配里程碑的合并请求。 |
| `my_reaction_emoji`         | string            | 否       | 返回已认证用户用给定 `emoji` 回应过的合并请求。`None` 返回未收到回应的议题。`Any` 返回至少收到一个回应的议题。 |
| `non_archived`              | boolean           | 否       | 如果为 `true`，则仅返回非归档项目中的合并请求。默认是 `true`。 |
| `not`                       | hash              | 否       | 返回不匹配所提供参数的合并请求。接受：`labels`、`milestone`、`author_id`、`author_username`、`assignee_id`、`assignee_username`、`reviewer_id`、`reviewer_username`、`my_reaction_emoji`。 |
| `order_by`                  | string            | 否       | 返回按 `created_at`、`updated_at`、`merged_at`（在极狐GitLab 17.2 中引入）、`label_priority`、`priority`、`milestone_due`、`popularity` 或 `title` 字段排序的合并请求。默认是 `created_at`。 |
| `reviewer_id`               | integer 或 string | 否       | 返回将给定用户 `id` 作为[审核者](../user/project/merge_requests/reviews/_index.md)的合并请求。`None` 返回没有审核者的合并请求。`Any` 返回有任何审核者的合并请求。与 `reviewer_username` 互斥。 |
| `reviewer_username`         | string            | 否       | 返回将给定 `username` 的用户作为[审核者](../user/project/merge_requests/reviews/_index.md)的合并请求。`None` 返回没有审核者的合并请求。`Any` 返回有任何审核者的合并请求。与 `reviewer_id` 互斥。 |
| `scope`                     | string            | 否       | 返回给定范围的合并请求：`created_by_me`、`assigned_to_me`、`reviews_for_me` 或 `all`。`reviews_for_me` 返回当前用户被指定为审核者的合并请求。默认为 `all`。 |
| `search`                    | string            | 否       | 根据合并请求的 `title` 和 `description` 进行搜索。与 `in` 属性结合使用。 |
| `sort`                      | string            | 否       | 返回按 `asc` 或 `desc` 顺序排序的合并请求。默认是 `desc`。 |
| `source_branch`             | string            | 否       | 返回具有给定源分支的合并请求。 |
| `source_project_id`         | integer           | 否       | 返回具有给定源项目 ID 的合并请求。 |
| `state`                     | string            | 否       | 返回所有合并请求 (`all`) 或仅返回那些 `opened`、`closed`、`locked` 或 `merged` 的合并请求。默认为 `all`。 |
| `target_branch`             | string            | 否       | 返回具有给定目标分支的合并请求。 |
| `updated_after`             | datetime          | 否       | 返回在给定日期和时间或之后更新的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `updated_before`            | datetime          | 否       | 返回在给定日期和时间或之前更新的合并请求。预期为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。 |
| `view`                      | string            | 否       | 如果为 `simple`，则返回合并请求的 `iid`、URL、标题、描述和基本状态。 |
| `wip`                       | string            | 否       | 根据合并请求的 `wip` 状态进行过滤。使用 `yes` 仅返回草稿合并请求，`no` 返回非草稿合并请求。 |
| `with_labels_details`       | boolean           | 否       | 如果为 `true`，响应会为标签字段中的每个标签返回更多详细信息：`:name`、`:color`、`:description`、`:description_html`、`:text_color`。默认为 `false`。 |
| `with_merge_status_recheck` | boolean           | 否       | 如果为 `true`，此投影请求（但不保证）对 `merge_status` 字段进行异步重新计算。当没有开发者、维护者或所有者角色的用户请求此属性时，启用 `restrict_merge_status_recheck` [功能标志](../administration/feature_flags/_index.md) 可以忽略此属性。 |

在响应中，`group_id` 表示包含合并请求所在项目的群组 ID。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)。如果 `view` 设置为 `simple`，则返回字段的子集。否则，响应属性包括：

```
| 属性                                | 类型     | 描述 |
|------------------------------------------|----------|-------------|
| `allow_collaboration`                    | boolean  | 如果为 `true`，则此 fork 允许有权限合并到目标分支的成员进行协作。仅用于来自 fork 的合并请求。 |
| `allow_maintainer_to_push`               | boolean  | 已弃用。请改用 `allow_collaboration`。 |
| `approvals_before_merge`                 | integer  | 在极狐GitLab 16.0 中[已弃用]。要配置审批规则，请参见[合并请求审批 API](merge_request_approvals.md)。仅极狐GitLab 专业版和旗舰版可用。 |
| `assignee[]`                             | object   | 已弃用。请改用 `assignees`。 |
| `assignees[]`                            | array    | 分配给合并请求的用户。 |
| `assignees.avatar_url`                   | string   | 指派人头像的完整 URL。 |
| `assignees.id`                           | integer  | 指派人的唯一 ID。 |
| `assignees.locked`                       | boolean  | 如果为 `true`，则指派人的账户由于认证失败尝试而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `assignees.name`                         | string   | 指派人的显示名称。可能根据当前用户的权限被遮盖。 |
| `assignees.public_email`                 | string   | 指派人的公开邮箱地址。 |
| `assignees.state`                        | string   | 指派人用户账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `assignees.username`                     | string   | 合并请求指派人的用户名。 |
| `assignees.web_url`                      | string   | 指派人个人资料页的完整 URL。 |
| `author[]`                               | object   | 包含创建合并请求用户信息的对象。 |
| `author.avatar_url`                      | string   | 作者头像的完整 URL。 |
| `author.id`                              | integer  | 创建合并请求的用户的唯一 ID。 |
| `author.locked`                          | boolean  | 如果为 `true`，则作者的账户由于认证失败尝试而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `author.name`                            | string   | 作者的显示名称。可能根据当前用户的权限被遮盖。 |
| `author.public_email`                    | string   | 作者的公开邮箱地址。 |
| `author.state`                           | string   | 用户账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `author.username`                        | string   | 合并请求作者的用户名。 |
| `author.web_url`                         | string   | 作者个人资料页的完整 URL。 |
| `blocking_discussions_resolved`          | boolean  | 如果为 `true`，则合并前所有讨论串都必须解决。 |
| `closed_at`                              | dateTime | 合并请求关闭时的时间戳。 |
| `closed_by[]`                            | object   | 包含关闭合并请求用户信息的对象。如果为 `null`，则合并请求是打开的。 |
| `closed_by.avatar_url`                   | string   | 关闭者头像的完整 URL。 |
| `closed_by.id`                           | integer  | 关闭合并请求的用户的唯一 ID。 |
| `closed_by.locked`                       | boolean  | 如果为 `true`，则关闭者的账户由于认证失败尝试而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `closed_by.name`                         | string   | 关闭者的显示名称。可能根据当前用户的权限被遮盖。 |
| `closed_by.public_email`                 | string   | 关闭者的公开邮箱地址。 |
| `closed_by.state`                        | string   | 关闭者账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `closed_by.username`                     | string   | 关闭合并请求的用户名。 |
| `closed_by.web_url`                      | string   | 关闭者个人资料页的完整 URL。 |
| `created_at`                             | dateTime | 合并请求创建时的时间戳。 |
| `description`                            | string   | 合并请求的描述。包含用于缓存的 Markdown 渲染 HTML。 |
| `detailed_merge_status`                  | string   | 详细的合并状态信息。可能的值列表请参见[合并状态](#merge-status)。 |
| `discussion_locked`                      | boolean  | 如果为 `true`，则讨论被锁定。只有项目成员可以在锁定的讨论中添加、编辑或解决评论。 |
| `downvotes`                              | integer  | 合并请求的反对数。 |
| `draft`                                  | boolean  | 如果为 `true`，则合并请求标记为 `草稿` 状态。 |
| `force_remove_source_branch`             | boolean  | 如果为 `true`，则项目设置强制在合并后删除源分支。 |
| `has_conflicts`                          | boolean  | 如果为 `true`，则合并请求存在冲突，无法合并。取决于 `merge_status` 属性。除非 `merge_status` 为 `cannot_be_merged`，否则返回 `false`。 |
| `id`                                     | integer  | 合并请求的唯一 ID。 |
| `iid`                                    | integer  | 合并请求在项目中的内部 ID。 |
| `imported`                               | boolean  | 如果为 `true`，则合并请求是导入的。 |
| `imported_from`                          | string   | 导入来源，例如 `Bitbucket`。 |
| `labels[]`                               | array    | 分配给合并请求的标签数组。如果 `with_labels_details` 为 `true`，则为每个标签返回一个数组。 |
| `labels.archived`                        | boolean  | 如果 `with_labels_details` 为 `true`，则标签已归档。 |
| `labels.color`                           | string   | 如果 `with_labels_details` 为 `true`，则标签的背景颜色。 |
| `labels.description`                     | string   | 如果 `with_labels_details` 为 `true`，则标签的描述文本。如果为 `null`，则标签没有描述。 |
| `labels.description_html`                | string   | 如果 `with_labels_details` 为 `true`，则标签的 HTML 渲染描述。如果为 `null`，则标签没有描述。 |
| `labels.id`                              | integer  | 如果 `with_labels_details` 为 `true`，则标签的唯一 ID。 |
| `labels.name`                            | string   | 如果 `with_labels_details` 为 `true`，则标签的名称。 |
| `labels.text_color`                      | string   | 如果 `with_labels_details` 为 `true`，则标签的文本颜色。 |
| `merge_after`                            | dateTime | 如果设置，则为此时间戳之后合并请求可以合并。在极狐GitLab 17.8 中[引入]。 |
| `merge_commit_sha`                       | string   | 如果设置，则为此合并请求提交的 SHA。在合并之前返回 `null`。 |
| `merge_status`                           | string   | 合并请求的状态。请改用 `detailed_merge_status`，它考虑了所有可能的状态。影响 `has_conflicts` 属性。有关响应数据的重要说明，请参见[单个合并请求响应说明](#single-merge-request-response-notes)。在极狐GitLab 15.6 中[已弃用]。<!-- 在该字段实际移除前不要删除此行 --> |
| `merge_user`                             | object   | 包含合并或设置自动合并用户信息的对象，或为 `null`。 |
| `merge_when_pipeline_succeeds`           | boolean  | 如果为 `true`，则合并请求设置为自动合并。 |
| `merged_at`                              | dateTime | 合并请求合并时的时间戳。 |
| `merged_by[]`                            | object   | 已弃用。请改用 `merge_user`。 |
| `milestone[]`                            | object   | 包含分配给合并请求的里程碑信息的对象。 |
| `milestone.created_at`                   | dateTime | 里程碑创建时的时间戳。 |
| `milestone.description`                  | string   | 里程碑的描述文本。如果为 `null`，则里程碑没有描述。 |
| `milestone.due_date`                     | date     | 里程碑的截止日期。如果为 `null`，则里程碑没有截止日期。 |
| `milestone.expired`                      | boolean  | 如果为 `true`，则里程碑已过期。 |
| `milestone.group_id`                     | integer  | 里程碑所属群组的 ID。仅当里程碑是群组里程碑时才包含。 |
| `milestone.id`                           | integer  | 里程碑的唯一 ID。 |
| `milestone.iid`                          | integer  | 里程碑在项目或群组中的内部 ID。 |
| `milestone.project_id`                   | integer  | 里程碑所属项目的 ID。仅当里程碑是项目里程碑时才包含。 |
| `milestone.start_date`                   | date     | 里程碑的开始日期。如果为 `null`，则里程碑没有开始日期。 |
| `milestone.state`                        | string   | 里程碑的当前状态，例如 `active` 或 `closed`。 |
| `milestone.title`                        | string   | 里程碑的名称。 |
| `milestone.updated_at`                   | dateTime | 里程碑最后更新的时间戳。 |
| `milestone.web_url`                      | string   | 查看里程碑的完整 Web URL。 |
| `prepared_at`                            | dateTime | 合并请求准备就绪的时间戳。此字段仅在所有[准备步骤](#preparation-steps)完成后填充一次，后续添加更多更改时不会更新。 |
| `project_id`                             | integer  | 包含合并请求的项目的 ID。 |
| `reference`                              | string   | 已弃用。请改用 `references`。 |
| `references[]`                           | object   | 包含合并请求所有内部引用的对象。 |
| `references.full`                        | string   | 合并请求的完整引用，包括完整项目路径，例如 `gitlab-org/gitlab!123`。在跨群组或项目请求时，与 `references.relative` 相同。 |
| `references.relative`                    | string   | 相对于特定项目或群组的引用：对于当前项目中的合并请求为 `!123`，对于同一群组中的其他项目为 `other-project!123`。 |
| `references.short`                       | string   | 合并请求的最短引用，例如 `!123`。从合并请求所在项目获取时，与 `references.relative` 相同。 |
| `reviewers[]`                            | array    | 合并请求的评审人。 |
| `reviewers.avatar_url`                   | string   | 评审人头像的完整 URL。 |
| `reviewers.id`                           | integer  | 评审人的唯一 ID。 |
| `reviewers.locked`                       | boolean  | 如果为 `true`，则评审人的账户由于认证失败尝试而被锁定，在锁定过期或管理员解锁前无法登录。 |
| `reviewers.name`                         | string   | 评审人的显示名称。可能根据当前用户的权限被遮盖。 |
| `reviewers.public_email`                 | string   | 评审人的公开邮箱地址。 |
| `reviewers.state`                        | string   | 评审人用户账户的当前状态。可能的值：`active`、`blocked` 或 `deactivated`。 |
| `reviewers.username`                     | string   | 合并请求评审人的用户名。 |
| `reviewers.web_url`                      | string   | 评审人个人资料页的完整 URL。 |
| `sha`                                    | string   | 源分支中头部提交的 SHA。 |
| `should_remove_source_branch`            | boolean  | 如果为 `true`，则合并后删除源分支。 |
| `source_branch`                          | string   | 源分支的名称。 |
| `source_project_id`                      | integer  | 源项目的 ID。 |
| `squash`                                 | boolean  | 如果为 `true`，则合并时压缩提交。 |
| `squash_commit_sha`                      | string   | 如果设置，则为压缩提交的 SHA。合并之前为空。 |
| `squash_on_merge`                        | boolean  | 如果为 `true`，则合并时压缩提交。 |
| `state`                                  | string   | 合并请求的当前状态。可能的值：`opened`、`closed`、`merged` 或 `locked`。 |
| `target_branch`                          | string   | 目标分支的名称。 |
| `target_project_id`                      | integer  | 目标项目的 ID。 |
| `task_completion_status[]`               | object   | 包含任务列表完成状态信息的对象。 |
| `task_completion_status.completed_count` | integer  | 合并请求描述中已完成的任务列表项数。如果合并请求没有描述或没有任务列表项，则返回 `0`。 |
| `task_completion_status.count`           | integer  | 合并请求描述中找到的任务列表项总数。如果合并请求没有描述或没有任务列表项，则返回 `0`。 |
| `time_stats[]`                           | object   | 包含此合并请求时间跟踪信息的对象。 |
| `time_stats.human_time_estimate`         | string   | `time_stats.time_estimate` 的人类可读格式，例如 `3h 30m`。 |
| `time_stats.human_total_time_spent`      | string   | `time_stats.total_time_spent` 的人类可读格式，例如 `3h 30m`。 |
| `time_stats.time_estimate`               | integer  | 完成合并请求的估计时间，以秒为单位。 |
| `time_stats.total_time_spent`            | integer  | 在合并请求上花费的总时间，以秒为单位。 |
| `title`                                  | string   | 合并请求标题。 |
| `updated_at`                             | dateTime | 合并请求最后更新的时间戳。 |
| `upvotes`                                | integer  | 合并请求的赞同数。 |
| `user_notes_count`                       | integer  | 用户评论数。 |
| `web_url`                                | string   | 查看合并请求的 Web URL。 |
| `work_in_progress`                       | boolean  | 已弃用。请改用 `draft`。 |

其他可能的响应：

- `401 Unauthorized` 如果访问令牌无效。
- `404 Not Found` 如果项目或合并请求未找到。
- `422 Unprocessable Entity` 如果验证失败。
- `429 Too Many Requests` 如果使用 `search` 参数，且请求被限流。

示例响应：

```json
[
  {
    "id": 1,
    "iid": 1,
    "project_id": 3,
    "title": "test1",
    "description": "fixed login page css paddings",
    "state": "merged",
    "imported": false,
    "imported_from": "none",
    "merged_by": { // 已弃用，将在 API v5 中移除，请使用 `merge_user` 代替
      "id": 87854,
      "name": "Douwe Maan",
      "username": "DouweM",
      "state": "active",
      "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
      "web_url": "https://jihulab.com/DouweM"
    },
    "merge_user": {
      "id": 87854,
      "name": "Douwe Maan",
      "username": "DouweM",
      "state": "active",
      "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
      "web_url": "https://jihulab.com/DouweM"
    },
    "merged_at": "2018-09-07T11:16:17.520Z",
    "merge_after": "2018-09-07T11:16:00.000Z",
    "prepared_at": "2018-09-04T11:16:17.520Z",
    "closed_by": null,
    "closed_at": null,
    "created_at": "2017-04-29T08:46:00Z",
    "updated_at": "2017-04-29T08:46:00Z",
    "target_branch": "main",
    "source_branch": "test1",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "admin",
      "state": "active",
      "avatar_url": null,
      "web_url" : "https://gitlab.example.com/admin"
    },
    "assignee": {
      "id": 1,
      "name": "Administrator",
      "username": "admin",
      "state": "active",
      "avatar_url": null,
      "web_url" : "https://gitlab.example.com/admin"
    },
    "assignees": [{
      "name": "Miss Monserrate Beier",
      "username": "axel.block",
      "id": 12,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/axel.block"
    }],
    "reviewers": [{
      "id": 2,
      "name": "Sam Bauch",
      "username": "kenyatta_oconnell",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/956c92487c6f6f7616b536927e22c9a0?s=80&d=identicon",
      "web_url": "http://gitlab.example.com//kenyatta_oconnell"
    }],
    "source_project_id": 2,
    "target_project_id": 3,
    "labels": [
      "Community contribution",
      "Manage"
    ],
    "draft": false,
    "work_in_progress": false,
    "milestone": {
      "id": 5,
      "iid": 1,
      "project_id": 3,
      "title": "v2.0",
      "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
      "state": "closed",
      "created_at": "2015-02-02T19:49:26.013Z",
      "updated_at": "2015-02-02T19:49:26.013Z",
      "due_date": "2018-10-22",
      "start_date": "2018-09-08",
      "web_url": "gitlab.example.com/my-group/my-project/milestones/1"
    },
    "merge_when_pipeline_succeeds": true,
    "merge_status": "can_be_merged",
    "detailed_merge_status": "not_open",
    "sha": "8888888888888888888888888888888888888888",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 1,
    "discussion_locked": null,
    "should_remove_source_branch": true,
    "force_remove_source_branch": false,
    "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
    "references": {
      "short": "!1",
      "relative": "my-project!1",
      "full": "my-group/my-project!1"
    },
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "squash": false,
    "task_completion_status":{
      "count":0,
      "completed_count":0
    },
    "has_conflicts": false,
    "blocking_discussions_resolved": true
  }
]
```

有关响应数据的重要说明，请参见[合并请求列表响应说明](#merge-requests-list-response-notes)。

## 获取合并请求

获取合并请求的信息。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid
```

支持的属性：

| 属性                        | 类型              | 是否必需 | 描述 |
|----------------------------------|-------------------|----------|-------------|
| `id`                             | integer 或 string | 是      | 项目的 ID 或 [URL 编码的路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid`              | integer           | 是      | 合并请求的内部 ID。 |
| `include_diverged_commits_count` | boolean           | 否       | 如果为 `true`，响应中包含目标分支之后的提交数。 |
| `include_rebase_in_progress`     | boolean           | 否       | 如果为 `true`，响应中包含是否正在进行变基操作。 |
| `render_html`                    | boolean           | 否       | 如果为 `true`，响应中包含标题和描述的渲染 HTML。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)。其他可能的响应：

- `401 Unauthorized` 如果访问令牌无效。
- `403 Forbidden` 如果访问被拒绝。
- `404 Not Found` 如果项目或合并请求未找到。
- `408 Request Timeout` 如果数据库查询超时。
- `409 Conflict` 如果存在资源锁冲突。
- `422 Unprocessable Entity` 如果验证失败。
- `429 Too Many Requests` 如果使用 `search` 参数，且请求被限流。

### 响应
| 属性 | 类型 | 描述 |
|-------------------------------------------------------------|----------|-------------|
| `allow_collaboration` | 布尔值 | 如果为 `true`，此派生（fork）允许可合并到目标分支的成员进行协作。仅用于来自派生的合并请求。 |
| `allow_maintainer_to_push` | 布尔值 | 已弃用。请改用 `allow_collaboration`。 |
| `approvals_before_merge` | 整数 | 在极狐GitLab 16.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/353097)。要配置审批规则，请参见[合并请求审批 API](merge_request_approvals.md)。仅限极狐GitLab 专业版和旗舰版。 |
| `assignee[]` | 对象 | 已弃用。请改用 `assignees`。 |
| `assignees[]` | 数组 | 分配给合并请求的用户。 |
| `assignees.avatar_url` | 字符串 | 指派人头像的完整 URL。 |
| `assignees.id` | 整数 | 指派人的唯一 ID。 |
| `assignees.locked` | 布尔值 | 如果为 `true`，该指派人的账户因多次认证失败而被锁定，在锁定到期或管理员解锁之前无法登录。 |
| `assignees.name` | 字符串 | 指派人的显示名称。可能会根据当前用户权限被隐去。 |
| `assignees.public_email` | 字符串 | 指派人的公开电子邮件地址。 |
| `assignees.state` | 字符串 | 指派人用户账户的当前状态。可能的值：`active`（活跃）、`blocked`（冻结）或 `deactivated`（停用）。 |
| `assignees.username` | 字符串 | 合并请求指派人的用户名。 |
| `assignees.web_url` | 字符串 | 指派人个人资料页面的完整 URL。 |
| `author[]` | 对象 | 包含创建合并请求的用户信息的对象。 |
| `author.avatar_url` | 字符串 | 作者头像的完整 URL。 |
| `author.id` | 整数 | 创建合并请求用户的唯一 ID。 |
| `author.locked` | 布尔值 | 如果为 `true`，该作者的账户因多次认证失败而被锁定，在锁定到期或管理员解锁之前无法登录。 |
| `author.name` | 字符串 | 作者的显示名称。可能会根据当前用户权限被隐去。 |
| `author.public_email` | 字符串 | 作者的公开电子邮件地址。 |
| `author.state` | 字符串 | 用户账户的当前状态。可能的值：`active`（活跃）、`blocked`（冻结）或 `deactivated`（停用）。 |
| `author.username` | 字符串 | 合并请求作者的用户名。 |
| `author.web_url` | 字符串 | 作者个人资料页面的完整 URL。 |
| `blocking_discussions_resolved` | 布尔值 | 如果为 `true`，合并前必须解决合并请求中的所有讨论串。 |
| `changes_count` | 字符串 | 如果已设置，表示合并请求中的变更数量。创建合并请求时为空，异步填充。类型为字符串，不是整数。当合并请求变更过多无法显示和存储时，该值上限为 1000，并返回字符串 `"1000+"`。请参阅[新合并请求的空 API 字段](#empty-api-fields-for-new-merge-requests)。 |
| `closed_at` | 日期时间 | 合并请求关闭的时间戳。 |
| `closed_by[]` | 对象 | 包含关闭合并请求的用户信息的对象。若为 `null`，则合并请求处于打开状态。 |
| `closed_by.avatar_url` | 字符串 | 关闭者头像的完整 URL。 |
| `closed_by.id` | 整数 | 关闭合并请求用户的唯一 ID。 |
| `closed_by.locked` | 布尔值 | 如果为 `true`，该关闭者的账户因多次认证失败而被锁定，在锁定到期或管理员解锁之前无法登录。 |
| `closed_by.name` | 字符串 | 关闭者的显示名称。可能会根据当前用户权限被隐去。 |
| `closed_by.public_email` | 字符串 | 关闭者的公开电子邮件地址。 |
| `closed_by.state` | 字符串 | 关闭者账户的当前状态。可能的值：`active`（活跃）、`blocked`（冻结）或 `deactivated`（停用）。 |
| `closed_by.username` | 字符串 | 关闭合并请求用户的用户名。 |
| `closed_by.web_url` | 字符串 | 关闭者个人资料页面的完整 URL。 |
| `created_at` | 日期时间 | 合并请求创建的时间戳。 |
| `description` | 字符串 | 合并请求的描述。包含已渲染为 HTML 以供缓存的 Markdown 内容。 |
| `detailed_merge_status` | 字符串 | 详细的合并状态信息。可能的值列表请参见[合并状态](#merge-status)。 |
| `diff_refs[]` | 对象 | 包含此合并请求的 base、head 和 start 提交 SHA 引用的对象。对应合并请求的最新差异版本。创建合并请求时为空，异步填充。请参阅[新合并请求的空 API 字段](#empty-api-fields-for-new-merge-requests)。 |
| `diff_refs.base_sha` | 字符串 | 源分支和目标分支分叉点的合并基础提交的 SHA。 |
| `diff_refs.start_sha` | 字符串 | 目标分支提交的 SHA，差异的起点。通常与 `base_sha` 相同。 |
| `diff_refs.head_sha` | 字符串 | 源分支中头提交的 SHA，即合并请求中的最新提交。 |
| `discussion_locked` | 布尔值 | 如果为 `true`，讨论被锁定。只有项目成员可以在锁定的讨论中添加、编辑或解决评论。 |
| `diverged_commits_count` | 整数 | 如果已设置，包含源分支落后于目标分支的提交数量。 |
| `downvotes` | 整数 | 合并请求的反对票数。 |
| `draft` | 布尔值 | 如果为 `true`，合并请求被标记为 `draft`（草稿）状态。 |
| `first_contribution` | 布尔值 | 如果为 `true`，表示作者在本项目中的首次贡献。 |
| `first_deployed_to_production_at` | 日期时间 | 首次部署完成的时间戳。 |
| `force_remove_source_branch` | 布尔值 | 如果为 `true`，项目设置强制在合并后删除源分支。 |
| `has_conflicts` | 布尔值 | 如果为 `true`，合并请求存在冲突且无法合并。取决于 `merge_status` 属性。除非 `merge_status` 为 `cannot_be_merged`，否则返回 `false`。 |
| `head_pipeline[]` | 对象 | 在合并请求源分支的 HEAD 提交上运行的流水线。推荐使用此处而非 `pipeline`，因为它包含更完整的信息。仅当当前用户可以查看此项目的流水线时才暴露。 |
| `head_pipeline.before_sha` | 字符串 | 此流水线运行前提交的 SHA。 |
| `head_pipeline.committed_at` | 日期时间 | 提交完成的时间戳。 |
| `head_pipeline.coverage` | 数字 | 测试覆盖率百分比，例如 `98.29`。 |
| `head_pipeline.created_at` | 日期时间 | 流水线创建的时间戳。 |
| `head_pipeline.detailed_status[]` | 对象 | 包含此流水线详细状态字段的对象。 |
| `head_pipeline.detailed_status.action[]` | 对象 | 如果已设置，包含此流水线可用操作的对象。 |
| `head_pipeline.detailed_status.action.button_title` | 字符串 | 操作的按钮标题。 |
| `head_pipeline.detailed_status.action.confirmation_message` | 字符串 | 操作的确认消息。 |
| `head_pipeline.detailed_status.action.icon` | 字符串 | 操作的图标。 |
| `head_pipeline.detailed_status.action.method` | 字符串 | 操作的 HTTP 方法，例如 `POST`。 |
| `head_pipeline.detailed_status.action.path` | 字符串 | 操作的路径，例如 `"/namespace1/project1/-/jobs/2/cancel"`。 |
| `head_pipeline.detailed_status.action.title` | 字符串 | 操作的标题。 |
| `head_pipeline.detailed_status.details_path` | 字符串 | 详细视图的路径，例如 `"/test-group/test-project/-/pipelines/287"`。 |
| `head_pipeline.detailed_status.favicon` | 字符串 | 状态图标的路径。 |
| `head_pipeline.detailed_status.group` | 字符串 | 状态分组，例如 `success`。 |
| `head_pipeline.detailed_status.has_details` | 布尔值 | 如果已设置，表示存在详细视图。 |
| `head_pipeline.detailed_status.icon` | 字符串 | 状态图标名称，例如 `"status_success"`。 |
| `head_pipeline.detailed_status.illustration.content` | 字符串 | 插图的文本内容，例如 `"This job depends on upstream jobs that need to succeed in order for this job to be triggered"`。 |
| `head_pipeline.detailed_status.illustration.image` | 字符串 | 插图图像的路径。 |
| `head_pipeline.detailed_status.illustration.size` | 字符串 | 插图的尺寸。 |
| `head_pipeline.detailed_status.illustration.title` | 字符串 | 插图的标题，例如 `"This job has not been triggered yet"`。 |
| `head_pipeline.detailed_status.label` | 字符串 | 流水线的状态标签，例如 `"passed"`。 |
| `head_pipeline.detailed_status.text` | 字符串 | 流水线的状态文本，例如 `"passed"`。 |
| `head_pipeline.detailed_status.tooltip` | 字符串 | 流水线的提示文本，例如 `"passed"`。 |
| `head_pipeline.duration` | 整数 | 流水线运行耗时，单位秒。 |
| `head_pipeline.finished_at` | 日期时间 | 流水线完成的时间戳。 |
| `head_pipeline.id` | 整数 | 流水线的唯一数字标识符。对应 `ci_pipelines` 表的外键。 |
| `head_pipeline.iid` | 整数 | 流水线的内部数字 ID。 |
| `head_pipeline.project_id` | 整数 | 包含该流水线的项目数字 ID。 |
| `head_pipeline.queued_duration` | 整数 | 排队时间，单位秒。 |
| `head_pipeline.ref` | 字符串 | 流水线运行的 Git 引用名称（分支或标签）。 |
| `head_pipeline.sha` | 字符串 | 触发该流水线的提交 SHA。 |
| `head_pipeline.source` | 字符串 | 流水线触发方式，例如 `push`、`merge_request_event` 或 `api`。 |
| `head_pipeline.started_at` | 日期时间 | 流水线开始运行的时间戳。 |
| `head_pipeline.status` | 字符串 | 流水线的当前状态。可能的值：`success`、`failed`、`running`、`pending`。 |
| `head_pipeline.tag` | 布尔值 | 如果为 `true`，此流水线运行在 Git 标签上。 |
| `head_pipeline.updated_at` | 日期时间 | 流水线最后更新的时间戳。 |
| `head_pipeline.user[]` | 对象 | 包含触发该流水线的用户信息的对象。 |
| `head_pipeline.user.avatar_url` | 字符串 | 用户头像的完整 URL。 |
| `head_pipeline.user.id` | 整数 | 触发该流水线用户的唯一 ID。 |
| `head_pipeline.user.locked` | 布尔值 | 如果为 `true`，触发该流水线的用户账户因多次认证失败而被锁定，在锁定到期或管理员解锁之前无法登录。 |
| `head_pipeline.user.name` | 字符串 | 触发该流水线用户的显示名称。可能会根据当前用户权限被隐去。 |
| `head_pipeline.user.public_email` | 字符串 | 触发该流水线用户的公开电子邮件地址。 |
| `head_pipeline.user.state` | 字符串 | 触发该流水线用户账户的当前状态。可能的值：`active`（活跃）、`blocked`（冻结）或 `deactivated`（停用）。 |
| `head_pipeline.user.username` | 字符串 | 触发该流水线用户的用户名。 |
| `head_pipeline.user.web_url` | 字符串 | 触发该流水线用户个人资料页面的完整 URL。 |
| `head_pipeline.web_url` | 字符串 | 流水线页面的完整 URL。 |
| `head_pipeline.yaml_errors` | 字符串 | 任何 YAML 配置错误。例如 `widgets:build: needs 'widgets:test'`。 |
| `id` | 整数 | 合并请求的 ID。 |
| `iid` | 整数 | 合并请求的内部 ID。 |
| `imported` | 布尔值 | 如果为 `true`，该合并请求为导入产生。 |
| `imported_from` | 字符串 | 导入来源，例如 `Bitbucket`。 |
| `labels[]` | 数组 | 分配给合并请求的标签数组。如果 `with_labels_details` 为 `true`，则每个标签返回一个对象数组。 |
| `labels.archived` | 布尔值 | 当 `with_labels_details` 为 `true` 时，表示标签已归档。 |
| `labels.color` | 字符串 | 当 `with_labels_details` 为 `true` 时，表示标签的背景颜色。 |
| `labels.description` | 字符串 | 当 `with_labels_details` 为 `true` 时，表示标签的描述文本。若为 `null`，则标签没有描述。 |
| `labels.description_html` | 字符串 | 当 `with_labels_details` 为 `true` 时，表示标签的 HTML 渲染描述。若为 `null`，则标签没有描述。 |
| `labels.id` | 整数 | 当 `with_labels_details` 为 `true` 时，表示标签的唯一 ID。 |
| `labels.name` | 字符串 | 当 `with_labels_details` 为 `true` 时，表示标签的名称。 |
| `labels.text_color` | 字符串 | 当 `with_labels_details` 为 `true` 时，表示标签的文字颜色。 |
| `latest_build_finished_at` | 日期时间 | 合并请求最新构建完成的时间戳。 |
| `latest_build_started_at` | 日期时间 | 合并请求最新构建开始的时间戳。 |
| `merge_after` | 日期时间 | 如果已设置，表示在此时间戳之后合并请求才可合并。在极狐GitLab 17.8 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/510992)。 |
| `merge_commit_sha` | 字符串 | 如果已设置，表示合并请求提交的 SHA。合并前返回 `null`。 |
| `merge_error` | 字符串 | 如果已设置，表示合并失败时显示的错误消息。要检查可合并性，请改用 `detailed_merge_status`。 |
| `merge_status` | 字符串 | 合并请求的状态。推荐使用 `detailed_merge_status`，它考虑了所有可能的状态。此属性影响 `has_conflicts` 属性。有关响应数据的重要说明，请参见[单个合并请求响应说明](#single-merge-request-response-notes)。在极狐GitLab 15.6 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/3169#note_1162532204)。<!-- 此行请保留，直至字段实际移除 --> |
| `merge_user[]` | 对象 | 合并此合并请求的用户、将其设置为自动合并的用户，或为 `null`。 |
| `merge_when_pipeline_succeeds` | 布尔值 | 如果为 `true`，该合并请求被设置为在流水线成功后自动合并。 |
| `merged_at` | 日期时间 | 合并请求合并的时间戳。 |
| `merged_by[]` | 对象 | 合并此合并请求或将其设置为自动合并的用户。在极狐GitLab 14.7 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/350534)，计划在 [API 版本 5](https://jihulab.com/gitlab-cn/gitlab-org/-/epics/8115) 中移除。请改用 `merge_user`。<!-- 此行请保留，直至字段实际移除 --> |
| `milestone[]` | 对象 | 包含分配给合并请求的里程碑信息的对象。 |
| `milestone.created_at` | 日期时间 | 里程碑创建的时间戳。 |
| `milestone.description` | 字符串 | 里程碑的描述文本。若为 `null`，则没有描述。 |
| `milestone.due_date` | 日期 | 里程碑的截止日期。若为 `null`，则没有截止日期。 |
| `milestone.expired` | 布尔值 | 如果为 `true`，里程碑已过期。 |
| `milestone.group_id` | 整数 | 里程碑所属群组的 ID。仅当里程碑是群组里程碑时才包含。 |
| `milestone.id` | 整数 | 里程碑的唯一 ID。 |
| `milestone.iid` | 整数 | 项目或群组中里程碑的内部 ID。 |
| `milestone.project_id` | 整数 | 里程碑所属项目的 ID。仅当里程碑是项目里程碑时才包含。 |
| `milestone.start_date` | 日期 | 里程碑的开始日期。若为 `null`，则没有开始日期。 |
| `milestone.state` | 字符串 | 里程碑的当前状态，例如 `active` 或 `closed`。 |
| `milestone.title` | 字符串 | 里程碑的名称。 |
| `milestone.updated_at` | 日期时间 | 里程碑最后更新的时间戳。 |
| `milestone.web_url` | 字符串 | 查看里程碑的完整网页 URL。 |
| `pipeline[]` | 对象 | 在合并请求分支 HEAD 上运行的流水线。推荐使用 `head_pipeline`，因为它包含更多信息。 |
| `prepared_at` | 日期时间 | 合并请求准备完成的时间戳。此字段仅在所有[准备步骤](#preparation-steps)完成后一次性填充，之后即使有更多变更也不会更新。 |
| `project_id` | 整数 | 包含该合并请求的项目 ID。 |
| `rebase_in_progress` | 布尔值 | 如果为 `true`，Sidekiq 正在此分支上执行变基（rebase）操作。 |
| `reference` | 字符串 | 已弃用。请改用 `references`。在极狐GitLab 12.7 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/20354)，计划在 [API 版本 5](https://jihulab.com/gitlab-cn/gitlab-org/-/epics/8115) 中移除。<!-- 此行请保留，直至字段实际移除 --> |
| `references[]` | 对象 | 包含合并请求所有内部引用的对象。 |
| `references.full` | 字符串 | 合并请求的完整引用，包括项目完整路径，例如 `gitlab-org/gitlab!123`。当跨群组或项目请求时，与 `references.relative` 相同。 |
| `references.relative` | 字符串 | 相对于特定项目或群组的引用：当前项目中的合并请求为 `!123`，同群组中其他项目则为 `other-project!123`。 |
| `references.short` | 字符串 | 合并请求的最短引用，例如 `!123`。当从合并请求自身的项目获取时，与 `references.relative` 相同。 |
| `reviewers[]` | 数组 | 合并请求的审核人。 |
| `reviewers.avatar_url` | 字符串 | 审核人头像的完整 URL。 |
| `reviewers.id` | 整数 | 审核人的唯一 ID。 |
| `reviewers.locked` | 布尔值 | 如果为 `true`，该审核人的账户因多次认证失败而被锁定，在锁定到期或管理员解锁之前无法登录。 |
| `reviewers.name` | 字符串 | 审核人的显示名称。可能会根据当前用户权限被隐去。 |
| `reviewers.public_email` | 字符串 | 审核人的公开电子邮件地址。 |
| `reviewers.state` | 字符串 | 审核人用户账户的当前状态。可能的值：`active`（活跃）、`blocked`（冻结）或 `deactivated`（停用）。 |
| `reviewers.username` | 字符串 | 合并请求审核人的用户名。 |
| `reviewers.web_url` | 字符串 | 审核人个人资料页面的完整 URL。 |
| `sha` | 字符串 | 源分支中头提交的 SHA。 |
| `should_remove_source_branch` | 布尔值 | 如果为 `true`，合并后删除源分支。 |
| `source_branch` | 字符串 | 源分支的名称。 |
| `source_project_id` | 整数 | 源项目的 ID。 |
| `squash` | 布尔值 | 如果为 `true`，合并时压缩提交。 |
| `squash_commit_sha` | 字符串 | 如果已设置，表示压缩提交的 SHA。合并前为空。 |
| `squash_on_merge` | 布尔值 | 如果为 `true`，合并时将压缩提交。 |
| `state` | 字符串 | 合并请求的当前状态。 |
| `subscribed` | boolean | 如果为 `true`，当前认证用户订阅此合并请求。 |
| `target_branch` | string | 目标分支的名称。 |
| `target_project_id` | integer | 目标项目的 ID。 |
| `task_completion_status[]` | object | 包含任务列表完成状态信息的对象。 |
| `task_completion_status.completed_count` | integer | 合并请求描述中已完成的任务列表项数量。如果合并请求没有描述或没有任务列表项，则返回 `0`。 |
| `task_completion_status.count` | integer | 合并请求描述中任务列表项总数。如果合并请求没有描述或没有任务列表项，则返回 `0`。 |
| `time_stats[]` | object | 包含此合并请求的时间跟踪信息的对象。 |
| `time_stats.human_time_estimate` | string | `time_stats.time_estimate` 的人类可读格式，如 `3h 30m`。 |
| `time_stats.human_total_time_spent` | string | `time_stats.total_time_spent` 的人类可读格式，如 `3h 30m`。 |
| `time_stats.time_estimate` | integer | 完成合并请求的预计时间，以秒为单位。 |
| `time_stats.total_time_spent` | integer | 处理合并请求已花费的总时间，以秒为单位。 |
| `title` | string | 合并请求标题。 |
| `updated_at` | datetime | 合并请求上次更新的时间戳。 |
| `upvotes` | integer | 合并请求的赞成票数。 |
| `user[]` | object | 请求合并请求的用户的权限。 |
| `user.can_merge` | boolean | 如果为 `true`，当前认证用户可以合并此合并请求。 |
| `user_notes_count` | integer | 用户评论数。 |
| `web_url` | string | 查看合并请求的 Web URL。 |
| `work_in_progress` | boolean | 已弃用。请改用 `draft`。 |

示例响应：

```json
{
  "id": 155016530,
  "iid": 133,
  "project_id": 15513260,
  "title": "Manual job rules",
  "description": "",
  "state": "opened",
  "imported": false,
  "imported_from": "none",
  "created_at": "2022-05-13T07:26:38.402Z",
  "updated_at": "2022-05-14T03:38:31.354Z",
  "merged_by": null, // 已弃用，并将在 API v5 中移除。请改用 `merge_user`。
  "merge_user": null,
  "merged_at": null,
  "merge_after": "2018-09-07T11:16:00.000Z",
  "prepared_at": "2018-09-04T11:16:17.520Z",
  "closed_by": null,
  "closed_at": null,
  "target_branch": "main",
  "source_branch": "manual-job-rules",
  "user_notes_count": 0,
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "id": 4155490,
    "username": "marcel.amirault",
    "name": "Marcel Amirault",
    "state": "active",
    "avatar_url": "https://jihulab.com/uploads/-/system/user/avatar/4155490/avatar.png",
    "web_url": "https://jihulab.com/marcel.amirault"
  },
  "assignees": [],
  "assignee": null,
  "reviewers": [],
  "source_project_id": 15513260,
  "target_project_id": 15513260,
  "labels": [],
  "draft": false,
  "work_in_progress": false,
  "milestone": null,
  "merge_when_pipeline_succeeds": false,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "mergeable",
  "sha": "e82eb4a098e32c796079ca3915e07487fc4db24c",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "discussion_locked": null,
  "should_remove_source_branch": null,
  "force_remove_source_branch": true,
  "reference": "!133", // 已弃用。请改用 `references`。
  "references": {
    "short": "!133",
    "relative": "!133",
    "full": "marcel.amirault/test-project!133"
  },
  "web_url": "https://jihulab.com/marcel.amirault/test-project/-/merge_requests/133",
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
  "has_conflicts": false,
  "blocking_discussions_resolved": true,
  "approvals_before_merge": null, // 已弃用，请使用 [合并请求批准 API](merge_request_approvals.md)
  "subscribed": true,
  "changes_count": "1",
  "latest_build_started_at": "2022-05-13T09:46:50.032Z",
  "latest_build_finished_at": null,
  "first_deployed_to_production_at": null,
  "pipeline": { // 请改用 `head_pipeline`。
    "id": 538317940,
    "iid": 1877,
    "project_id": 15513260,
    "sha": "1604b0c46c395822e4e9478777f8e54ac99fe5b9",
    "ref": "refs/merge-requests/133/merge",
    "status": "failed",
    "source": "merge_request_event",
    "created_at": "2022-05-13T09:46:39.560Z",
    "updated_at": "2022-05-13T09:47:20.706Z",
    "web_url": "https://jihulab.com/marcel.amirault/test-project/-/pipelines/538317940"
  },
  "head_pipeline": {
    "id": 538317940,
    "iid": 1877,
    "project_id": 15513260,
    "sha": "1604b0c46c395822e4e9478777f8e54ac99fe5b9",
    "ref": "refs/merge-requests/133/merge",
    "status": "failed",
    "source": "merge_request_event",
    "created_at": "2022-05-13T09:46:39.560Z",
    "updated_at": "2022-05-13T09:47:20.706Z",
    "web_url": "https://jihulab.com/marcel.amirault/test-project/-/pipelines/538317940",
    "before_sha": "1604b0c46c395822e4e9478777f8e54ac99fe5b9",
    "tag": false,
    "yaml_errors": null,
    "user": {
      "id": 4155490,
      "username": "marcel.amirault",
      "name": "Marcel Amirault",
      "state": "active",
      "avatar_url": "https://jihulab.com/uploads/-/system/user/avatar/4155490/avatar.png",
      "web_url": "https://jihulab.com/marcel.amirault"
    },
    "started_at": "2022-05-13T09:46:50.032Z",
    "finished_at": "2022-05-13T09:47:20.697Z",
    "committed_at": null,
    "duration": 30,
    "queued_duration": 10,
    "coverage": null,
    "detailed_status": {
      "icon": "status_failed",
      "text": "failed",
      "label": "failed",
      "group": "failed",
      "tooltip": "failed",
      "has_details": true,
      "details_path": "/marcel.amirault/test-project/-/pipelines/538317940",
      "illustration": null,
      "favicon": "/assets/ci_favicons/favicon_status_failed-41304d7f7e3828808b0c26771f0309e55296819a9beea3ea9fbf6689d9857c12.png"
    },
    "archived": false
  },
  "diff_refs": {
    "base_sha": "1162f719d711319a2efb2a35566f3bfdadee8bab",
    "head_sha": "e82eb4a098e32c796079ca3915e07487fc4db24c",
    "start_sha": "1162f719d711319a2efb2a35566f3bfdadee8bab"
  },
  "merge_error": null,
  "first_contribution": false,
  "user": {
    "can_merge": true
  },
  "approvals_before_merge": { // 仅适用于极狐GitLab 专业版和旗舰版
    "id": 1,
    "title": "test1",
    "approvals_before_merge": null
  },
}
```

### 单个合并请求响应说明

当请求此端点时，每个合并请求的合并性（`merge_status`）会异步检查。轮询此 API 端点可获取更新后的状态。这会影响 `has_conflicts` 属性，因为它取决于 `merge_status`。除非 `merge_status` 为 `cannot_be_merged`，否则返回 `false`。

### 合并状态

使用 `detailed_merge_status` 替代 `merge_status` 来覆盖所有可能的状态。

- `detailed_merge_status` 字段可包含以下与合并请求相关的值之一：
  - `approvals_syncing`：合并请求的审批信息正在同步。
  - `checking`：Git 正在测试是否可以进行有效合并。
  - `ci_must_pass`：合并前 CI/CD 流水线必须成功。
  - `ci_still_running`：CI/CD 流水线仍在运行。
  - `commits_status`：源分支应存在且包含提交。
  - `conflict`：源分支与目标分支之间存在冲突。
  - `discussions_not_resolved`：合并前必须解决所有讨论。
  - `draft_status`：无法合并，因为合并请求是草稿。
  - `jira_association_missing`：标题或描述必须引用 Jira 议题。要配置此要求，请参阅[要求合并请求关联 Jira 议题才能合并](../integration/jira/issues.md#require-associated-jira-issue-for-merge-requests-to-be-merged)。
  - `mergeable`：分支可以干净地合并到目标分支中。
  - `merge_request_blocked`：被另一个合并请求阻塞。
  - `merge_time`：在指定时间之后才能合并。
  - `need_rebase`：合并请求必须变基。
  - `not_approved`：合并前需要审批。
  - `not_open`：合并前合并请求必须处于打开状态。
  - `preparing`：正在创建合并请求差异。
  - `requested_changes`：合并请求的审核者已请求更改。
  - `security_policy_pipeline_check`：当强制执行安全策略时，最新提交的所有流水线必须成功才能合并。
  - `security_policy_violations`：所有安全策略必须被满足。
  - `status_checks_must_pass`：合并前所有状态检查必须通过。
  - `unchecked`：Git 尚未测试是否可以进行有效合并。
  - `locked_paths`：合并到默认分支之前，必须解锁被其他用户锁定的路径。
  - `locked_lfs_files`：合并前必须解锁被其他用户锁定的 LFS 文件。
  - `title_regex`：检查标题是否与预期的正则表达式匹配（如果在项目设置中配置）。

### 准备步骤

仅在以下步骤完成后，`prepared_at` 字段才会填充一次：

- 创建差异。
- 创建流水线。
- 检查合并性。
- 链接所有 Git LFS 对象。
- 发送通知。

如果向合并请求添加更多更改，`prepared_at` 字段不会更新。

## 获取合并请求参与者

获取合并请求的参与者。

```plaintext
获取 /projects/:id/merge_requests/:merge_request_iid/participants
```

支持的属性：

| 属性                | 类型               | 是否必填 | 描述 |
|---------------------|--------------------|----------|-------------|
| `id`                | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数            | 是       | 合并请求的内部 ID。 |

示例响应：

```json
[
  {
    "id": 1,
    "name": "John Doe1",
    "username": "user1",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/c922747a93b40d1ea88262bf1aebee62?s=80&d=identicon",
    "web_url": "http://localhost/user1"
  },
  {
    "id": 2,
    "name": "John Doe2",
    "username": "user2",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/10fc7f102be8de7657fb4d80898bbfe3?s=80&d=identicon",
    "web_url": "http://localhost/user2"
  }
]
```

## 获取合并请求审核者

获取合并请求的审核者。

```plaintext
获取 /projects/:id/merge_requests/:merge_request_iid/reviewers
```

支持的属性：

| 属性                | 类型               | 是否必填 | 描述 |
|---------------------|--------------------|----------|-------------|
| `id`                | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数            | 是       | 合并请求的内部 ID。 |

示例响应：

```json
[
  {
    "user": {
      "id": 1,
      "name": "John Doe1",
      "username": "user1",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/c922747a93b40d1ea88262bf1aebee62?s=80&d=identicon",
      "web_url": "http://localhost/user1"
    },
    "state": "unreviewed",
    "created_at": "2022-07-27T17:03:27.684Z"
  },
  {
    "user": {
      "id": 2,
      "name": "John Doe2",
      "username": "user2",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/10fc7f102be8de7657fb4d80898bbfe3?s=80&d=identicon",
      "web_url": "http://localhost/user2"
    },
    "state": "reviewed",
    "created_at": "2022-07-27T17:03:27.684Z"
  }
]
```

## 获取合并请求提交

获取合并请求的提交。

```plaintext
获取 /projects/:id/merge_requests/:merge_request_iid/commits
```

支持的属性：

| 属性                | 类型               | 是否必填 | 描述 |
|---------------------|--------------------|----------|-------------|
| `id`                | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数            | 是       | 合并请求的内部 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                          | 类型          | 描述 |
|-------------------------------|---------------|-------------|
| `commits`                     | 对象数组 | 合并请求中的提交。 |
| `commits[].id`                | 字符串        | 提交的 ID。 |
| `commits[].short_id`          | 字符串        | 提交的短 ID。 |
| `commits[].created_at`        | 日期时间      | 与 `committed_date` 字段相同。 |
| `commits[].parent_ids`        | 数组         | 父提交的 ID。 |
| `commits[].title`             | 字符串        | 提交标题。 |
| `commits[].message`           | 字符串        | 提交消息。 |
| `commits[].author_name`       | 字符串        | 提交作者的姓名。 |
| `commits[].author_email`      | 字符串        | 提交作者的电子邮件地址。 |
| `commits[].authored_date`     | 日期时间      | 提交创作的日期和时间。 |
| `commits[].committer_name`    | 字符串        | 提交者的姓名。 |
| `commits[].committer_email`   | 字符串        | 提交者的电子邮件地址。 |
| `commits[].committed_date`    | 日期时间      | 提交日期和时间。 |
| `commits[].trailers`          | 对象         | 为提交解析的 Git trailers。重复的键只包含最后一个值。 |
| `commits[].extended_trailers` | 对象         | 为提交解析的 Git trailers。 |
| `commits[].web_url`           | 字符串        | 合并请求的 Web URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/commits"
```

示例响应：

```json
[
  {
    "id": "ed899a2f4b50b4370feeea94676502b42383c746",
    "short_id": "ed899a2f4b5",
    "title": "Replace sanitize with escape once",
    "author_name": "Example User",
    "author_email": "user@example.com",
    "authored_date": "2012-09-20T11:50:22+03:00",
    "committer_name": "Example User",
    "committer_email": "user@example.com",
    "committed_date": "2012-09-20T11:50:22+03:00",
    "created_at": "2012-09-20T11:50:22+03:00",
    "message": "Replace sanitize with escape once",
    "trailers": {},
    "extended_trailers": {},
    "web_url": "https://gitlab.example.com/project/-/commit/ed899a2f4b50b4370feeea94676502b42383c746"
  },
  {
    "id": "6104942438c14ec7bd21c6cd5bd995272b3faff6",
    "short_id": "6104942438c",
    "title": "Sanitize for network graph",
    "author_name": "Example User",
    "author_email": "user@example.com",
    "authored_date": "2012-09-20T09:06:12+03:00",
    "committer_name": "Example User",
    "committer_email": "user@example.com",
    "committed_date": "2012-09-20T09:06:12+03:00",
    "created_at": "2012-09-20T09:06:12+03:00",
    "message": "Sanitize for network graph",
    "trailers": {},
    "extended_trailers": {},
    "web_url": "https://gitlab.example.com/project/-/commit/6104942438c14ec7bd21c6cd5bd995272b3faff6"
  }
]
```

## 获取合并请求依赖项

获取合并请求在合并前必须解决的依赖项。

> [!note]
> 如果用户无权访问阻塞合并请求，则不会返回 `blocking_merge_request` 属性。

```plaintext
获取 /projects/:id/merge_requests/:merge_request_iid/blocks
```

支持的属性：

| 属性                | 类型            | 是否必填 | 描述 |
|---------------------|-----------------|----------|-------------|
| `id`                | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/blocks"
```

示例响应：

```json
[
  {
    "id": 1,
    "blocking_merge_request": {
      "id": 145,
      "iid": 12,
      "project_id": 7,
      "title": "Interesting MR",
      "description": "Does interesting things.",
      "state": "opened",
      "created_at": "2024-07-05T21:29:11.172Z",
      "updated_at": "2024-07-05T21:29:11.172Z",
      "merged_by": null,
      "merge_user": null,
      "merged_at": null,
      "merge_after": "2018-09-07T11:16:00.000Z",
      "closed_by": null,
      "closed_at": null,
      "target_branch": "master",
      "source_branch": "v2.x",
      "user_notes_count": 0,
      "upvotes": 0,
      "downvotes": 0,
      "author": {
        "id": 2,
        "username": "aiguy123",
        "name": "AI GUY",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "https://localhost/aiguy123"
      },
      "assignees": [
        {
          "id": 2,
          "username": "aiguy123",
          "name": "AI GUY",
          "state": "active",
          "locked": false,
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "https://localhost/aiguy123"
        }
      ],
      "assignee": {
        "id": 2,
        "username": "aiguy123",
        "name": "AI GUY",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "https://localhost/aiguy123"
      },
      "reviewers": [
        {
          "id": 2,
          "username": "aiguy123",
          "name": "AI GUY",
          "state": "active",
          "locked": false,
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "https://localhost/aiguy123"
        },
        {
          "id": 1,
          "username": "root",
          "name": "Administrator",
          "state": "active",
          "locked": false,
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "https://localhost/root"
        }
      ],
      "source_project_id": 7,
      "target_project_id": 7,
      "labels": [],
      "draft": false,
      "imported": false,
      "imported_from": "none",
      "work_in_progress": false,
      "milestone": null,
      "merge_when_pipeline_succeeds": false,
      "merge_status": "unchecked",
      "detailed_merge_status": "unchecked",
      "sha": "ce7e4f2d0ce13cb07479bb39dc10ee3b861c08a6",
      "merge_commit_sha": null,
      "squash_commit_sha": null,
      "discussion_locked": null,
      "should_remove_source_branch": null,
      "force_remove_source_branch": true,
      "prepared_at": null,
      "reference": "!12",
      "references": {
        "short": "!12",
        "relative": "!12",
        "full": "my-group/my-project!12"
      },
      "web_url": "https://localhost/my-group/my-project/-/merge_requests/12",
      "time_stats": {
        "time_estimate": 0,
        "total_time_spent": 0,
        "human_time_estimate": null,
        "human_total_time_spent": null
      },
      "squash": false,
      "squash_on_merge": false,
      "task_completion_status": {
        "count": 0,
        "completed_count": 0
      },
      "has_conflicts": false,
      "blocking_discussions_resolved": true,
      "approvals_before_merge": null
    },
    "blocked_merge_request": {
      "id": 146,
      "iid": 13,
      "project_id": 7,
      "title": "Really cool MR",
      "description": "Adds some stuff",
      "state": "opened",
      "created_at": "2024-07-05T21:31:34.811Z",
      "updated_at": "2024-07-27T02:57:08.054Z",
      "merged_by": null,
      "merge_user": null,
      "merged_at": null,
      "merge_after": "2018-09-07T11:16:00.000Z",
      "closed_by": null,
      "closed_at": null,
      "target_branch": "master",
      "source_branch": "remove-from",
      "user_notes_count": 0,
      "upvotes": 1,
      "downvotes": 0,
      "author": {
        "id": 2,
        "username": "aiguy123",
        "name": "AI GUY",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "https://localhost/aiguy123"
      },
      "assignees": [
        {
          "id": 2,
          "username": "aiguy123",
          "name": "AI GUY",
          "state": "active",
          "locked": false,
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "https://localhose/aiguy123"
        }
      ],
      "assignee": {
        "id": 2,
        "username": "aiguy123",
        "name": "AI GUY",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "https://localhost/aiguy123"
      },
      "reviewers": [
        {
          "id": 1,
          "username": "root",
          "name": "Administrator",
          "state": "active",
          "locked": false,
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "https://localhost/root"
        }
      ],
      "source_project_id": 7,
      "target_project_id": 7,
      "labels": [],
      "draft": false,
      "imported": false,
      "imported_from": "none",
      "work_in_progress": false,
      "milestone": {
        "id": 59,
        "iid": 6,
        "project_id": 7,
        "title": "Sprint 1718897375",
        "description": "Accusantium omnis iusto a animi.",
        "state": "active",
        "created_at": "2024-06-20T15:29:35.739Z",
        "updated_at": "2024-06-20T15:29:35.739Z",
        "due_date": null,
        "start_date": null,
        "expired": false,
        "web_url": "https://localhost/my-group/my-project/-/milestones/6"
      },
      "merge_when_pipeline_succeeds": false,
      "merge_status": "cannot_be_merged",
      "detailed_merge_status": "not_approved",
      "sha": "daa75b9b17918f51f43866ff533987fda71375ea",
      "merge_commit_sha": null,
      "squash_commit_sha": null,
      "discussion_locked": null,
      "should_remove_source_branch": null,
      "force_remove_source_branch": true,
      "prepared_at": "2024-07-11T18:50:46.215Z",
      "reference": "!13",
      "references": {
        "short": "!13",
        "relative": "!13",
        "full": "my-group/my-project!12"
      },
      "web_url": "https://localhost/my-group/my-project/-/merge_requests/13",
      "time_stats": {
        "time_estimate": 0,
        "total_time_spent": 0,
        "human_time_estimate": null,
        "human_total_time_spent": null
      },
      "squash": false,
      "squash_on_merge": false,
      "task_completion_status": {
        "count": 0,
        "completed_count": 0
      },
      "has_conflicts": true,
      "blocking_discussions_resolved": true,
      "approvals_before_merge": null
    },
    "project_id": 7
  }
]
```

## 删除合并请求依赖项

删除一个合并请求依赖项。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/blocks/:block_id
```

支持的属性：

| 属性                | 类型               | 是否必填 | 描述 |
|---------------------|--------------------|----------|-------------|
| `id`                | 整数或字符串 | 是       | 认证用户拥有的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数            | 是       | 合并请求的内部 ID。 |
| `block_id`          | 整数            | 是       | 阻塞关系的 ID。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/blocks/1"
```

返回：
- 如果依赖关系成功删除，则返回 `204 No Content`。
- 如果用户没有更新合并请求的权限，则返回 `403 Forbidden`。
- 如果用户没有读取阻止合并请求的权限，则返回 `403 Forbidden`。

<a id="create-a-merge-request-dependency"></a>

## 创建合并请求依赖

创建合并请求依赖。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/blocks
```

支持的属性：

| 属性                         | 类型              | 是否必需    | 描述 |
|------------------------------|-------------------|-------------|-------------|
| `id`                         | integer 或 string | 是          | 经过身份验证的用户所拥有的项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid`          | integer           | 是          | 要阻止的合并请求的内部 ID。 |
| `blocking_merge_request_id`  | integer           | 有条件      | 阻止合并请求的全局 ID。如果未提供 `blocking_merge_request_iid`，则为必需。 |
| `blocking_merge_request_iid` | integer           | 有条件      | 阻止合并请求的 IID。如果未提供 `blocking_merge_request_id`，则为必需。 |
| `blocking_project_id`        | integer 或 string | 否          | 包含阻止合并请求的项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。当 `blocking_merge_request_iid` 引用不同项目中的合并请求时为必需。默认为当前项目。 |

使用 IID 的示例请求（同一项目）：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/blocks?blocking_merge_request_iid=2"
```

使用 IID 的示例请求（跨项目）：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/blocks?blocking_merge_request_iid=5&blocking_project_id=2"
```

使用全局 ID 的示例请求（旧方法）：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/blocks?blocking_merge_request_id=12345"
```

返回：

- 如果依赖关系成功创建，则返回 `201 Created`。
- 如果阻止合并请求保存失败，则返回 `400 Bad request`。
- 如果用户没有读取阻止合并请求的权限，则返回 `403 Forbidden`。
- 如果未找到阻止合并请求，则返回 `404 Not found`。
- 如果阻止关系已存在，则返回 `409 Conflict`。

示例响应：

```json
{
  "id": 1,
  "blocking_merge_request": {
    "id": 145,
    "iid": 12,
    "project_id": 7,
    "title": "Interesting MR",
    "description": "Does interesting things.",
    "state": "opened",
    "created_at": "2024-07-05T21:29:11.172Z",
    "updated_at": "2024-07-05T21:29:11.172Z",
    "merged_by": null,
    "merge_user": null,
    "merged_at": null,
    "merge_after": "2018-09-07T11:16:00.000Z",
    "closed_by": null,
    "closed_at": null,
    "target_branch": "master",
    "source_branch": "v2.x",
    "user_notes_count": 0,
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "id": 2,
      "username": "aiguy123",
      "name": "AI GUY",
      "state": "active",
      "locked": false,
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "https://localhost/aiguy123"
    },
    "assignees": [
      {
        "id": 2,
        "username": "aiguy123",
        "name": "AI GUY",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "https://localhost/aiguy123"
      }
    ],
    "assignee": {
      "id": 2,
      "username": "aiguy123",
      "name": "AI GUY",
      "state": "active",
      "locked": false,
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "https://localhost/aiguy123"
    },
    "reviewers": [
      {
        "id": 2,
        "username": "aiguy123",
        "name": "AI GUY",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "https://localhost/aiguy123"
      },
      {
        "id": 1,
        "username": "root",
        "name": "Administrator",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "https://localhost/root"
      }
    ],
    "source_project_id": 7,
    "target_project_id": 7,
    "labels": [],
    "draft": false,
    "imported": false,
    "imported_from": "none",
    "work_in_progress": false,
    "milestone": null,
    "merge_when_pipeline_succeeds": false,
    "merge_status": "unchecked",
    "detailed_merge_status": "unchecked",
    "sha": "ce7e4f2d0ce13cb07479bb39dc10ee3b861c08a6",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "discussion_locked": null,
    "should_remove_source_branch": null,
    "force_remove_source_branch": true,
    "prepared_at": null,
    "reference": "!12",
    "references": {
      "short": "!12",
      "relative": "!12",
      "full": "my-group/my-project!12"
    },
    "web_url": "https://localhost/my-group/my-project/-/merge_requests/12",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "squash": false,
    "squash_on_merge": false,
    "task_completion_status": {
      "count": 0,
      "completed_count": 0
    },
    "has_conflicts": false,
    "blocking_discussions_resolved": true,
    "approvals_before_merge": null
  },
  "project_id": 7
}
```

<a id="retrieve-blocked-merge-requests"></a>

## 获取被阻止的合并请求

获取被某个合并请求阻止的合并请求。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/blockees
```

支持的属性：

| 属性      | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer 或 string | 是       | 项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/blockees"
```

示例响应：

```json
[
  {
    "id": 18,
    "blocking_merge_request": {
      "id": 71,
      "iid": 10,
      "project_id": 7,
      "title": "At quaerat occaecati voluptate ex explicabo nisi.",
      "description": "Aliquid distinctio officia corrupti ad nemo natus ipsum culpa.",
      "state": "merged",
      "created_at": "2024-07-05T19:44:14.023Z",
      "updated_at": "2024-07-05T19:44:14.023Z",
      "merged_by": {
        "id": 40,
        "username": "i-user-0-1720208283",
        "name": "I User0",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/8325417f0f7919e3724957543b4414fdeca612cade1e4c0be45685fdaa2be0e2?s=80&d=identicon",
        "web_url": "http://127.0.0.1:3000/i-user-0-1720208283"
      },
      "merge_user": {
        "id": 40,
        "username": "i-user-0-1720208283",
        "name": "I User0",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/8325417f0f7919e3724957543b4414fdeca612cade1e4c0be45685fdaa2be0e2?s=80&d=identicon",
        "web_url": "http://127.0.0.1:3000/i-user-0-1720208283"
      },
      "merged_at": "2024-06-26T19:44:14.123Z",
      "closed_by": null,
      "closed_at": null,
      "target_branch": "master",
      "source_branch": "Brickwood-Brunefunc-417",
      "user_notes_count": 0,
      "upvotes": 0,
      "downvotes": 0,
      "author": {
        "id": 40,
        "username": "i-user-0-1720208283",
        "name": "I User0",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/8325417f0f7919e3724957543b4414fdeca612cade1e4c0be45685fdaa2be0e2?s=80&d=identicon",
        "web_url": "http://127.0.0.1:3000/i-user-0-1720208283"
      },
      "assignees": [],
      "assignee": null,
      "reviewers": [],
      "source_project_id": 7,
      "target_project_id": 7,
      "labels": [],
      "draft": false,
      "imported": false,
      "imported_from": "none",
      "work_in_progress": false,
      "milestone": null,
      "merge_when_pipeline_succeeds": false,
      "merge_status": "can_be_merged",
      "detailed_merge_status": "not_open",
      "merge_after": null,
      "sha": null,
      "merge_commit_sha": null,
      "squash_commit_sha": null,
      "discussion_locked": null,
      "should_remove_source_branch": null,
      "force_remove_source_branch": null,
      "prepared_at": null,
      "reference": "!10",
      "references": {
        "short": "!10",
        "relative": "!10",
        "full": "flightjs/Flight!10"
      },
      "web_url": "http://127.0.0.1:3000/flightjs/Flight/-/merge_requests/10",
      "time_stats": {
        "time_estimate": 0,
        "total_time_spent": 0,
        "human_time_estimate": null,
        "human_total_time_spent": null
      },
      "squash": false,
      "squash_on_merge": false,
      "task_completion_status": {
        "count": 0,
        "completed_count": 0
      },
      "has_conflicts": false,
      "blocking_discussions_resolved": true,
      "approvals_before_merge": null
    },
    "blocked_merge_request": {
      "id": 176,
      "iid": 14,
      "project_id": 7,
      "title": "second_mr",
      "description": "Signed-off-by: Lucas Zampieri <lzampier@redhat.com>",
      "state": "opened",
      "created_at": "2024-07-08T19:12:29.089Z",
      "updated_at": "2024-08-27T19:27:17.045Z",
      "merged_by": null,
      "merge_user": null,
      "merged_at": null,
      "closed_by": null,
      "closed_at": null,
      "target_branch": "master",
      "source_branch": "second_mr",
      "user_notes_count": 0,
      "upvotes": 0,
      "downvotes": 0,
      "author": {
        "id": 1,
        "username": "root",
        "name": "Administrator",
        "state": "active",
        "locked": false,
        "avatar_url": "https://www.gravatar.com/avatar/fc3634394c590e212d964e8e0a34c4d9b8c17c992f4d6d145d75f9c21c1c3b6e?s=80&d=identicon",
        "web_url": "http://127.0.0.1:3000/root"
      },
      "assignees": [],
      "assignee": null,
      "reviewers": [],
      "source_project_id": 7,
      "target_project_id": 7,
      "labels": [],
      "draft": false,
      "imported": false,
      "imported_from": "none",
      "work_in_progress": false,
      "milestone": null,
      "merge_when_pipeline_succeeds": false,
      "merge_status": "cannot_be_merged",
      "detailed_merge_status": "commits_status",
      "merge_after": null,
      "sha": "3a576801e528db79a75fbfea463673054ff224fb",
      "merge_commit_sha": null,
      "squash_commit_sha": null,
      "discussion_locked": null,
      "should_remove_source_branch": null,
      "force_remove_source_branch": true,
      "prepared_at": null,
      "reference": "!14",
      "references": {
        "short": "!14",
        "relative": "!14",
        "full": "flightjs/Flight!14"
      },
      "web_url": "http://127.0.0.1:3000/flightjs/Flight/-/merge_requests/14",
      "time_stats": {
        "time_estimate": 0,
        "total_time_spent": 0,
        "human_time_estimate": null,
        "human_total_time_spent": null
      },
      "squash": false,
      "squash_on_merge": false,
      "task_completion_status": {
        "count": 0,
        "completed_count": 0
      },
      "has_conflicts": true,
      "blocking_discussions_resolved": true,
      "approvals_before_merge": null
    },
    "project_id": 7
  }
]
```

<a id="retrieve-merge-request-changes"></a>

## 获取合并请求变更

> [!warning]
> 此端点已在 极狐GitLab 15.7 中废弃，并计划在 API v5 中移除。请改用 [列出合并请求差异](#list-merge-request-diffs) 端点。
> <!-- 在实际移除该端点之前请勿删除此行 -->

获取合并请求的信息，包括其文件和变更。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/changes
```

支持的属性：

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |
| `access_raw_diffs`  | boolean           | 否       | 通过 Gitaly 检索变更差异。 |
| `unidiff`           | boolean           | 否       | 以 [统一差异](https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html) 格式呈现变更差异。默认为 false。在 极狐GitLab 16.5 中引入。 |

与变更集相关联的差异具有与其他通过 API 返回或在 UI 中查看的差异相同的大小限制。当这些限制影响结果时，`overflow` 字段将包含值 `true`。通过添加 `access_raw_diffs` 参数，可以不应用这些限制来检索差异数据，该参数直接从 Gitaly 访问差异，而不是从数据库。这种方法通常较慢且更耗费资源，但不受数据库支持的差异大小限制的影响。但 Gitaly 固有的限制仍然适用。

示例响应：

```json
{
  "id": 21,
  "iid": 1,
  "project_id": 4,
  "title": "Blanditiis beatae suscipit hic assumenda et molestias nisi asperiores repellat et.",
  "state": "reopened",
  "created_at": "2015-02-02T19:49:39.159Z",
  "updated_at": "2015-02-02T20:08:49.959Z",
  "target_branch": "secret_token",
  "source_branch": "version-1-9",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "name": "Chad Hamill",
    "username": "jarrett",
    "id": 5,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/b95567800f828948baf5f4160ebb2473?s=40&d=identicon",
    "web_url" : "https://gitlab.example.com/jarrett"
  },
  "assignee": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40&d=identicon",
    "web_url" : "https://gitlab.example.com/root"
  },
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "reviewers": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "source_project_id": 4,
  "target_project_id": 4,
  "labels": [ ],
  "description": "Qui voluptatibus placeat ipsa alias quasi. Deleniti rem ut sint. Optio velit qui distinctio.",
  "draft": false,
  "work_in_progress": false,
  "milestone": {
    "id": 5,
    "iid": 1,
    "project_id": 4,
    "title": "v2.0",
    "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
    "state": "closed",
    "created_at": "2015-02-02T19:49:26.013Z",
    "updated_at": "2015-02-02T19:49:26.013Z",
    "due_date": null
  },
  "merge_when_pipeline_succeeds": true,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "mergeable",
  "subscribed" : true,
  "sha": "8888888888888888888888888888888888888888",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "user_notes_count": 1,
  "changes_count": "1",
  "should_remove_source_branch": true,
  "force_remove_source_branch": false,
  "squash": false,
  "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
  "references": {
    "short": "!1",
    "relative": "!1",
    "full": "my-group/my-project!1"
  },
  "discussion_locked": false,
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "task_completion_status":{
    "count":0,
    "completed_count":0
  },
  "changes": [
    {
    "old_path": "VERSION",
    "new_path": "VERSION",
    "a_mode": "100644",
    "b_mode": "100644",
    "diff": "@@ -1 +1 @@\ -1.9.7\ +1.9.8",
    "new_file": false,
    "renamed_file": false,
    "deleted_file": false
    }
  ],
  "overflow": false
}
```

<a id="list-merge-request-diffs"></a>

## 列出合并请求差异

{{< history >}}

- `generated_file` 在 极狐GitLab 16.9 中引入，并带有名为 `collapse_generated_diff_files` 的 [功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 在 极狐GitLab 16.10 中在 JihuLab.com 和 私有化部署 上启用。
- `generated_file` 在 极狐GitLab 16.11 中 GA。功能标志 `collapse_generated_diff_files` 已移除。
- `collapsed` 和 `too_large` 响应属性在 极狐GitLab 18.4 中引入。

{{< /history >}}

列出合并请求中更改文件的差异。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/diffs
```

支持的属性：

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |
| `page`              | integer           | 否       | 要返回的结果页。默认为 1。 |
| `per_page`          | integer           | 否       | 每页结果数。默认为 20。 |
| `unidiff`           | boolean           | 否       | 以 [统一差异](https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html) 格式呈现差异。默认为 false。在 极狐GitLab 16.5 中引入。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性             | 类型    | 描述 |
|------------------|---------|-------------|
| `a_mode`         | string  | 文件的旧文件模式。 |
| `b_mode`         | string  | 文件的新文件模式。 |
| `collapsed`      | boolean | 文件差异被排除，但可以根据请求获取。 |
| `deleted_file`   | boolean | 文件已被删除。 |
| `diff`           | string  | 对文件所做更改的差异表示。 |
| `generated_file` | boolean | 文件被 [标记为生成文件](../user/project/merge_requests/changes.md#collapse-generated-files)。 |
| `new_file`       | boolean | 文件已添加。 |
| `new_path`       | string  | 文件的新路径。 |
| `old_path`       | string  | 文件的旧路径。 |
| `renamed_file`   | boolean | 文件已重命名。 |
| `too_large`      | boolean | 文件差异被排除且无法检索。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/diffs?page=1&per_page=2"
```

示例响应：

```json
[
  {
    "old_path": "README",
    "new_path": "README",
    "a_mode": "100644",
    "b_mode": "100644",
    "diff": "@@ -1 +1 @@\ -Title\ +README",
    "collapsed": false,
    "too_large": false,
    "new_file": false,
    "renamed_file": false,
    "deleted_file": false,
    "generated_file": false
  },
  {
    "old_path": "VERSION",
    "new_path": "VERSION",
    "a_mode": "100644",
    "b_mode": "100644",
    "diff": "@@\ -1.9.7\ +1.9.8",
    "collapsed": false,
    "too_large": false,
    "new_file": false,
    "renamed_file": false,
    "deleted_file": false,
    "generated_file": false
  }
]
```

> [!note]
> 此端点受 [合并请求差异限制](../administration/instance_limits.md#diff-limits) 约束。
> 超出差异限制的合并请求将返回有限的结果。

<a id="show-merge-request-raw-diffs"></a>

## 显示合并请求原始差异

显示合并请求中更改的文件的原始差异。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/raw_diffs
```

支持的属性：

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及一个可编程使用的原始差异响应：

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/raw_diffs"
```

示例响应：

```diff
        diff --git a/lib/api/helpers.rb b/lib/api/helpers.rb
index 31525ad523553c8d7eff163db3e539058efd6d3a..f30e36d6fdf4cd4fa25f62e08ecdbf4a7b169681 100644
--- a/lib/api/helpers.rb
+++ b/lib/api/helpers.rb
@@ -944,6 +944,10 @@ def send_git_blob(repository, blob)
       body ''
     end

+    def send_git_diff(repository, diff_refs)
+      header(*Gitlab::Workhorse.send_git_diff(repository, diff_refs))
+    end
+
     def send_git_archive(repository, **kwargs)
       header(*Gitlab::Workhorse.send_git_archive(repository, **kwargs))

diff --git a/lib/api/merge_requests.rb b/lib/api/merge_requests.rb
index e02d9eea1852f19fe5311acda6aa17465eeb422e..f32b38585398a18fea75c11d7b8ebb730eeb3fab 100644
--- a/lib/api/merge_requests.rb
+++ b/lib/api/merge_requests.rb
@@ -6,6 +6,8 @@ class MergeRequests < ::API::Base
     include PaginationParams
     include Helpers::Unidiff

+    helpers ::API::Helpers::HeadersHelpers
+
     CONTEXT_COMMITS_POST_LIMIT = 20

     before { authenticate_non_get! }
```

> [!note]
> 此端点受 [合并请求差异限制](../administration/instance_limits.md#diff-limits) 约束。
> 超出差异限制的合并请求将返回有限的结果。

<a id="list-merge-request-pipelines"></a>

## 列出合并请求流水线

列出合并请求的所有流水线。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/pipelines
```

支持的属性：

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |

要限制合并请求流水线列表，请使用分页参数 `page` 和 `per_page`。

示例响应：

```json
[
  {
    "id": 77,
    "sha": "959e04d7c7a30600c894bd3c0cd0e1ce7f42c11d",
    "ref": "main",
    "status": "success"
  }
]
```

<a id="create-merge-request-pipeline"></a>

## 创建合并请求流水线

为合并请求创建一个新的 [流水线](../ci/pipelines/merge_request_pipelines.md)。通过此端点创建的流水线不会运行常规的分支/标签流水线。要创建作业，请将 `.gitlab-ci.yml` 配置为 `only: [merge_requests]`。

新流水线可以是：
- 分离的合并请求流水线。
- 如果 [项目设置已启用](../ci/pipelines/merged_results_pipelines.md#enable-merged-results-pipelines)，则为 [合并结果流水线](../ci/pipelines/merged_results_pipelines.md)。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/pipelines
```

支持的属性：

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目 ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |

示例响应：
```json
{
  "id": 2,
  "sha": "b83d6e391c22777fca1ed3012fce84f633d7fed0",
  "ref": "refs/merge-requests/1/head",
  "status": "pending",
  "web_url": "http://localhost/user1/project1/pipelines/2",
  "before_sha": "0000000000000000000000000000000000000000",
  "tag": false,
  "yaml_errors": null,
  "user": {
    "id": 1,
    "name": "John Doe1",
    "username": "user1",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c922747a93b40d1ea88262bf1aebee62?s=80&d=identicon",
    "web_url": "http://example.com"
  },
  "created_at": "2019-09-04T19:20:18.267Z",
  "updated_at": "2019-09-04T19:20:18.459Z",
  "started_at": null,
  "finished_at": null,
  "committed_at": null,
  "duration": null,
  "coverage": null,
  "detailed_status": {
    "icon": "status_pending",
    "text": "pending",
    "label": "pending",
    "group": "pending",
    "tooltip": "pending",
    "has_details": false,
    "details_path": "/user1/project1/pipelines/2",
    "illustration": null,
    "favicon": "/assets/ci_favicons/favicon_status_pending-5bdf338420e5221ca24353b6bff1c9367189588750632e9a871b7af09ff6a2ae.png"
  },
  "archived": false
}
```

## 创建合并请求

创建新的合并请求。

```plaintext
POST /projects/:id/merge_requests
```

| 属性 | 类型 | 是否必需 | 描述 |
|----------------------------|-------------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `source_branch` | string | 是 | 源分支。 |
| `target_branch` | string | 是 | 目标分支。 |
| `title` | string | 是 | MR 标题。 |
| `allow_collaboration` | boolean | 否 | 允许能够合并到目标分支的成员进行提交。 |
| `approvals_before_merge` | integer | 否 | 此合并请求可合并前所需的审批数量（见下文）。要配置审批规则，请参阅[合并请求审批 API](merge_request_approvals.md)。已在 极狐GitLab 16.0 [弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/353097)。仅限专业版和旗舰版。 |
| `allow_maintainer_to_push` | boolean | 否 | `allow_collaboration` 的别名。 |
| `assignee_id` | integer | 否 | 指派人用户 ID。 |
| `assignee_ids` | integer array | 否 | 指派给此合并请求的用户 ID。设置为 `0` 或提供空值以取消分配所有指派人。 |
| `description` | string | 否 | 合并请求的描述。限制为 1,048,576 个字符。 |
| `labels` | string | 否 | 合并请求的标签，以逗号分隔的列表形式表示。如果标签尚不存在，则会创建一个新的项目标签并将其分配给该合并请求。 |
| `merge_after` | string | 否 | 该合并请求在此日期后才能被合并。[在 极狐GitLab 17.8 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/510992)。 |
| `milestone_id` | integer | 否 | 里程碑的全局 ID。 |
| `remove_source_branch` | boolean | 否 | 标记合并请求在合并时是否应删除源分支。 |
| `reviewer_ids` | integer array | 否 | 作为评审人添加到合并请求的用户 ID。如果设置为 `0` 或留空，则不添加评审人。 |
| `squash` | boolean | 否 | 如果为 `true`，则在合并时将所有提交压扁为一个提交。未提供时，默认为[项目的压扁选项设置](../user/project/merge_requests/squash_and_merge.md#configure-squash-options-for-a-project)。项目设置在合并时可能会覆盖此值。 |
| `target_project_id` | integer | 否 | 目标项目的数字 ID。 |

响应示例：

```json
{
  "id": 1,
  "iid": 1,
  "project_id": 3,
  "title": "test1",
  "description": "fixed login page css paddings",
  "state": "merged",
  "imported": false,
  "imported_from": "none",
  "created_at": "2017-04-29T08:46:00Z",
  "updated_at": "2017-04-29T08:46:00Z",
  "target_branch": "main",
  "source_branch": "test1",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignee": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "source_project_id": 2,
  "target_project_id": 3,
  "labels": [
    "Community contribution",
    "Manage"
  ],
  "draft": false,
  "work_in_progress": false,
  "milestone": {
    "id": 5,
    "iid": 1,
    "project_id": 3,
    "title": "v2.0",
    "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
    "state": "closed",
    "created_at": "2015-02-02T19:49:26.013Z",
    "updated_at": "2015-02-02T19:49:26.013Z",
    "due_date": "2018-09-22",
    "start_date": "2018-08-08",
    "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
  },
  "merge_when_pipeline_succeeds": true,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "not_open",
  "merge_error": null,
  "sha": "8888888888888888888888888888888888888888",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "user_notes_count": 1,
  "discussion_locked": null,
  "should_remove_source_branch": true,
  "force_remove_source_branch": false,
  "allow_collaboration": false,
  "allow_maintainer_to_push": false,
  "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
  "references": {
    "short": "!1",
    "relative": "!1",
    "full": "my-group/my-project!1"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "squash": false,
  "subscribed": false,
  "changes_count": "1",
  "merged_by": { // 已弃用，并将在 API v5 中移除，请改用 `merge_user`
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merge_user": {
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merged_at": "2018-09-07T11:16:17.520Z",
  "merge_after": "2018-09-07T11:16:00.000Z",
  "prepared_at": "2018-09-04T11:16:17.520Z",
  "closed_by": null,
  "closed_at": null,
  "latest_build_started_at": "2018-09-07T07:27:38.472Z",
  "latest_build_finished_at": "2018-09-07T08:07:06.012Z",
  "first_deployed_to_production_at": null,
  "pipeline": {
    "id": 29626725,
    "sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "ref": "patch-28",
    "status": "success",
    "web_url": "https://gitlab.example.com/my-group/my-project/pipelines/29626725"
  },
  "diff_refs": {
    "base_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00",
    "head_sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "start_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00"
  },
  "diverged_commits_count": 2,
  "task_completion_status":{
    "count":0,
    "completed_count":0
  }
}
```

有关响应数据的重要说明，请参阅[单个合并请求响应说明](#single-merge-request-response-notes)。

## 更新合并请求

更新现有合并请求。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid
```

| 属性 | 类型 | 是否必需 | 描述 |
|----------------------------|-------------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的 ID。 |
| `add_labels` | string | 否 | 以逗号分隔的标签名称，用于添加至合并请求。如果标签尚不存在，则会创建一个新的项目标签并将其分配给该合并请求。 |
| `allow_collaboration` | boolean | 否 | 允许能够合并到目标分支的成员进行提交。 |
| `allow_maintainer_to_push` | boolean | 否 | `allow_collaboration` 的别名。 |
| `assignee_id` | integer | 否 | 指派给此合并请求的用户 ID。设置为 `0` 或提供空值以取消分配所有指派人。 |
| `assignee_ids` | integer array | 否 | 指派给此合并请求的用户 ID。设置为 `0` 或提供空值以取消分配所有指派人。 |
| `description` | string | 否 | 合并请求的描述。限制为 1,048,576 个字符。 |
| `discussion_locked` | boolean | 否 | 一个标记，指示合并请求的讨论是否被锁定。只有项目成员才能为锁定的讨论添加、编辑或解决评论。 |
| `labels` | string | 否 | 合并请求的以逗号分隔的标签名称。设置为空字符串以取消分配所有标签。如果标签尚不存在，则会创建一个新的项目标签并将其分配给该合并请求。 |
| `merge_after` | string | 否 | 该合并请求在此日期后才能被合并。[在 极狐GitLab 17.8 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/510992)。 |
| `milestone_id` | integer | 否 | 指派给合并请求的里程碑的全局 ID。设置为 `0` 或提供空值以取消分配里程碑。 |
| `remove_labels` | string | 否 | 以逗号分隔的标签名称，用于从合并请求中移除。 |
| `remove_source_branch` | boolean | 否 | 标记合并请求在合并时是否应删除源分支。 |
| `reviewer_ids` | integer array | 否 | 设置为合并请求评审人的用户 ID。将值设置为 `0` 或提供空值以取消设置所有评审人。 |
| `squash` | boolean | 否 | 如果为 `true`，则在合并时将所有提交压扁为一个提交。未提供时，默认为[项目的压扁选项设置](../user/project/merge_requests/squash_and_merge.md#configure-squash-options-for-a-project)。如果项目被配置为 **要求** 或 **不允许** 压扁，则该设置在合并时优先。 |
| `state_event` | string | 否 | 新状态 (close/reopen)。 |
| `target_branch` | string | 否 | 目标分支。 |
| `title` | string | 否 | MR 标题。 |

必须包含至少一个非必要属性。

响应示例：

```json
{
  "id": 1,
  "iid": 1,
  "project_id": 3,
  "title": "test1",
  "description": "fixed login page css paddings",
  "state": "merged",
  "created_at": "2017-04-29T08:46:00Z",
  "updated_at": "2017-04-29T08:46:00Z",
  "target_branch": "main",
  "source_branch": "test1",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignee": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "reviewers": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "source_project_id": 2,
  "target_project_id": 3,
  "labels": [
    "Community contribution",
    "Manage"
  ],
  "draft": false,
  "work_in_progress": false,
  "milestone": {
    "id": 5,
    "iid": 1,
    "project_id": 3,
    "title": "v2.0",
    "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
    "state": "closed",
    "created_at": "2015-02-02T19:49:26.013Z",
    "updated_at": "2015-02-02T19:49:26.013Z",
    "due_date": "2018-09-22",
    "start_date": "2018-08-08",
    "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
  },
  "merge_when_pipeline_succeeds": true,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "not_open",
  "merge_error": null,
  "sha": "8888888888888888888888888888888888888888",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "user_notes_count": 1,
  "discussion_locked": null,
  "should_remove_source_branch": true,
  "force_remove_source_branch": false,
  "allow_collaboration": false,
  "allow_maintainer_to_push": false,
  "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
  "references": {
    "short": "!1",
    "relative": "!1",
    "full": "my-group/my-project!1"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "squash": false,
  "subscribed": false,
  "changes_count": "1",
  "merged_by": { // 已弃用，并将在 API v5 中移除，请改用 `merge_user`
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merge_user": {
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merged_at": "2018-09-07T11:16:17.520Z",
  "merge_after": "2018-09-07T11:16:00.000Z",
  "prepared_at": "2018-09-04T11:16:17.520Z",
  "closed_by": null,
  "closed_at": null,
  "latest_build_started_at": "2018-09-07T07:27:38.472Z",
  "latest_build_finished_at": "2018-09-07T08:07:06.012Z",
  "first_deployed_to_production_at": null,
  "pipeline": {
    "id": 29626725,
    "sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "ref": "patch-28",
    "status": "success",
    "web_url": "https://gitlab.example.com/my-group/my-project/pipelines/29626725"
  },
  "diff_refs": {
    "base_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00",
    "head_sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "start_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00"
  },
  "diverged_commits_count": 2,
  "task_completion_status":{
    "count":0,
    "completed_count":0
  }
}
```

有关响应数据的重要说明，请参阅[单个合并请求响应说明](#single-merge-request-response-notes)。

## 删除合并请求

删除一个合并请求。只有管理员和项目所有者可以删除合并请求。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid
```

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/merge_requests/85"
```

## 合并一个合并请求

使用此 API 接受并合并通过合并请求提交的变更。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/merge
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------------------------|-------------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |
| `auto_merge` | boolean | 否 | 如果为 `true`，则当流水线成功时合并该合并请求。 |
| `merge_commit_message` | string | 否 | 自定义合并提交消息。 |
| `merge_when_pipeline_succeeds` | boolean | 否 | 已在 极狐GitLab 17.11 [弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/521291)。改用 `auto_merge`。 |
| `sha` | string | 否 | 如果提供，此 SHA 必须与源分支的 HEAD 匹配。用于确保只合并已审查的提交。 |
| `should_remove_source_branch` | boolean | 否 | 如果为 `true`，则删除源分支。 |
| `squash_commit_message` | string | 否 | 自定义压扁提交消息。 |
| `squash` | boolean | 否 | 如果为 `true`，则在合并时将所有提交压扁为一个提交。 |

此 API 在失败时返回特定的 HTTP 状态码：

| HTTP 状态码 | 消息 | 原因 |
|-------------|--------------------------------------------|--------|
| `401` | `401 Unauthorized` | 此用户无权接受此合并请求。 |
| `405` | `405 Method Not Allowed` | 该合并请求无法合并。 |
| `409` | `SHA does not match HEAD of source branch` | 提供的 `sha` 参数与源的 HEAD 不匹配。 |
| `422` | `Branch cannot be merged` | 合并请求合并失败。 |

有关响应数据的重要说明，请参阅[单个合并请求响应说明](#single-merge-request-response-notes)。

响应示例：

```json
{
  "id": 1,
  "iid": 1,
  "project_id": 3,
  "title": "test1",
  "description": "fixed login page css paddings",
  "state": "merged",
  "created_at": "2017-04-29T08:46:00Z",
  "updated_at": "2017-04-29T08:46:00Z",
  "target_branch": "main",
  "source_branch": "test1",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignee": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "reviewers": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "source_project_id": 2,
  "target_project_id": 3,
  "labels": [
    "Community contribution",
    "Manage"
  ],
  "draft": false,
  "work_in_progress": false,
  "milestone": {
    "id": 5,
    "iid": 1,
    "project_id": 3,
    "title": "v2.0",
    "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
    "state": "closed",
    "created_at": "2015-02-02T19:49:26.013Z",
    "updated_at": "2015-02-02T19:49:26.013Z",
    "due_date": "2018-09-22",
    "start_date": "2018-08-08",
    "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
  },
  "merge_when_pipeline_succeeds": true,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "not_open",
  "merge_error": null,
  "sha": "8888888888888888888888888888888888888888",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "user_notes_count": 1,
  "discussion_locked": null,
  "should_remove_source_branch": true,
  "force_remove_source_branch": false,
  "allow_collaboration": false,
  "allow_maintainer_to_push": false,
  "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
  "references": {
    "short": "!1",
    "relative": "!1",
    "full": "my-group/my-project!1"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "squash": false,
  "subscribed": false,
  "changes_count": "1",
  "merged_by": { // 已弃用，并将在 API v5 中移除，请改用 `merge_user`
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merge_user": {
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merged_at": "2018-09-07T11:16:17.520Z",
  "merge_after": "2018-09-07T11:16:00.000Z",
  "prepared_at": "2018-09-04T11:16:17.520Z",
  "closed_by": null,
  "closed_at": null,
  "latest_build_started_at": "2018-09-07T07:27:38.472Z",
  "latest_build_finished_at": "2018-09-07T08:07:06.012Z",
  "first_deployed_to_production_at": null,
  "pipeline": {
    "id": 29626725,
    "sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "ref": "patch-28",
    "status": "success",
    "web_url": "https://gitlab.example.com/my-group/my-project/pipelines/29626725"
  },
  "diff_refs": {
    "base_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00",
    "head_sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "start_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00"
  },
  "diverged_commits_count": 2,
  "task_completion_status":{
    "count":0,
    "completed_count":0
  }
}
```

## 合并到默认合并引用路径

将合并请求的源分支和目标分支之间的更改合并到目标项目仓库的 `refs/merge-requests/:iid/merge` 引用中，如果可能的话。此引用具有目标分支在执行常规合并操作后将具有的状态。

此操作不是常规合并操作，因为它不会以任何方式改变合并请求目标分支的状态。

这个引用 (`refs/merge-requests/:iid/merge`) 在提交请求到此 API 时不一定被覆盖，尽管它确保引用具有尽可能最新的状态。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/merge_ref
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

此 API 返回特定的 HTTP 状态码：

| HTTP 状态码 | 消息 | 原因 |
|-------------|----------------------------------|--------|
| `200` | _(无)_ | 成功。返回 `refs/merge-requests/:iid/merge` 的 HEAD 提交。 |
| `400` | `Merge request is not mergeable` | 合并请求存在冲突。 |
| `400` | `Merge ref cannot be updated` | |
| `400` | `Unsupported operation` | 极狐GitLab 数据库处于只读模式。 |

响应示例：

```json
{
  "commit_id": "854a3a7a17acbcc0bbbea170986df1eb60435f34"
}
```

## 当流水线成功时取消合并

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/cancel_merge_when_pipeline_succeeds
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

此 API 返回特定的 HTTP 状态码：
| HTTP 状态码 | 消息 | 原因 |
|-------------|----------|--------|
| `201`       | _(无)_ | 成功，或合并请求已经合并。 |
| `406`       | `无法取消自动合并` | 合并请求已关闭。 |

有关响应数据的重要说明，请参见[单个合并请求响应说明](#single-merge-request-response-notes)。

示例响应：

```json
{
  "id": 1,
  "iid": 1,
  "project_id": 3,
  "title": "test1",
  "description": "修复登录页面 CSS 内边距",
  "state": "merged",
  "created_at": "2017-04-29T08:46:00Z",
  "updated_at": "2017-04-29T08:46:00Z",
  "target_branch": "main",
  "source_branch": "test1",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignee": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "reviewers": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "source_project_id": 2,
  "target_project_id": 3,
  "labels": [
    "Community contribution",
    "Manage"
  ],
  "draft": false,
  "work_in_progress": false,
  "milestone": {
    "id": 5,
    "iid": 1,
    "project_id": 3,
    "title": "v2.0",
    "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
    "state": "closed",
    "created_at": "2015-02-02T19:49:26.013Z",
    "updated_at": "2015-02-02T19:49:26.013Z",
    "due_date": "2018-09-22",
    "start_date": "2018-08-08",
    "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
  },
  "merge_when_pipeline_succeeds": false,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "not_open",
  "merge_error": null,
  "sha": "8888888888888888888888888888888888888888",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "user_notes_count": 1,
  "discussion_locked": null,
  "should_remove_source_branch": true,
  "force_remove_source_branch": false,
  "allow_collaboration": false,
  "allow_maintainer_to_push": false,
  "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
  "references": {
    "short": "!1",
    "relative": "!1",
    "full": "my-group/my-project!1"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "squash": false,
  "subscribed": false,
  "changes_count": "1",
  "merged_by": { // 已弃用，将在 API v5 中移除，请使用 `merge_user` 代替
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merge_user": {
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merged_at": "2018-09-07T11:16:17.520Z",
  "merge_after": "2018-09-07T11:16:00.000Z",
  "prepared_at": "2018-09-04T11:16:17.520Z",
  "closed_by": null,
  "closed_at": null,
  "latest_build_started_at": "2018-09-07T07:27:38.472Z",
  "latest_build_finished_at": "2018-09-07T08:07:06.012Z",
  "first_deployed_to_production_at": null,
  "pipeline": {
    "id": 29626725,
    "sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "ref": "patch-28",
    "status": "success",
    "web_url": "https://gitlab.example.com/my-group/my-project/pipelines/29626725"
  },
  "diff_refs": {
    "base_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00",
    "head_sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "start_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00"
  },
  "diverged_commits_count": 2,
  "task_completion_status":{
    "count":0,
    "completed_count":0
  }
}
```

## 变基合并请求

自动将合并请求的 `source_branch` 变基到其 `target_branch`。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/rebase
```

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|----------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |
| `skip_ci` | boolean | 否 | 设置为 `true` 以跳过创建 CI 流水线。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/76/merge_requests/1/rebase"
```

此 API 返回特定的 HTTP 状态码：

| HTTP 状态码 | 消息 | 原因 |
|-------------|--------------------------------------------|--------|
| `202` | _(无信息)_ | 成功加入队列。 |
| `403` | `无法推送到源分支` | 你没有权限推送到合并请求的源分支。 |
| `403` | `源分支不存在` | 你没有权限推送到合并请求的源分支。 |
| `403` | `源分支被保护，禁止强制推送` | 你没有权限推送到合并请求的源分支。 |
| `409` | `无法将变基操作加入队列` | 一个长时间运行的事务可能阻塞了你的请求。 |

如果请求成功加入队列，响应包含：

```json
{
  "rebase_in_progress": true
}
```

你可以使用 `include_rebase_in_progress` 参数轮询[获取单个合并请求](#retrieve-a-merge-request)端点，以检查异步请求的状态。

如果变基操作正在进行中，响应包含以下内容：

```json
{
  "rebase_in_progress": true,
  "merge_error": null
}
```

变基操作成功完成后，响应包含以下内容：

```json
{
  "rebase_in_progress": false,
  "merge_error": null
}
```

如果变基操作失败，响应包含以下内容：

```json
{
  "rebase_in_progress": false,
  "merge_error": "变基失败。请在本地进行变基"
}
```

## 合并请求上的评论

[评论](notes.md)资源创建评论。

## 列出合并后关闭的议题

获取合并请求合并时将关闭的议题列表。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/closes_issues
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

成功后，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性（使用极狐GitLab 议题跟踪器时）：

| 属性 | 类型 | 描述 |
|-----------------------------|----------|-------------|
| `[].assignee` | object | 议题的第一个指派人。 |
| `[].assignees` | array | 议题的指派人。 |
| `[].author` | object | 创建此议题的用户。 |
| `[].blocking_issues_count` | integer | 此议题阻塞的议题数量。 |
| `[].closed_at` | datetime | 议题关闭时的时间戳。 |
| `[].closed_by` | object | 关闭此议题的用户。 |
| `[].confidential` | boolean | 标识议题是否为机密。 |
| `[].created_at` | datetime | 议题创建时的时间戳。 |
| `[].description` | string | 议题的描述。 |
| `[].discussion_locked` | boolean | 标识议题的评论是否仅限成员。 |
| `[].downvotes` | integer | 议题收到的踩数。 |
| `[].due_date` | date | 议题的截止日期。 |
| `[].id` | integer | 议题的 ID。 |
| `[].iid` | integer | 议题的内部 ID。 |
| `[].issue_type` | string | 议题的类型。可以是 `issue`、`incident`、`test_case`、`requirement`、`task`。 |
| `[].labels` | array | 议题的标签。 |
| `[].merge_requests_count` | integer | 合并时将关闭此议题的合并请求数量。 |
| `[].milestone` | object | 议题的里程碑。 |
| `[].project_id` | integer | 议题项目的 ID。 |
| `[].state` | string | 议题的状态。可以是 `opened` 或 `closed`。 |
| `[].task_completion_status` | object | 包含 `count` 和 `completed_count`。 |
| `[].time_stats` | object | 议题的时间统计。包含 `time_estimate`、`total_time_spent`、`human_time_estimate` 和 `human_total_time_spent`。 |
| `[].title` | string | 议题的标题。 |
| `[].type` | string | 议题的类型。与 `issue_type` 相同，但为大写。 |
| `[].updated_at` | datetime | 议题更新时的时间戳。 |
| `[].upvotes` | integer | 议题收到的赞数。 |
| `[].user_notes_count` | integer | 议题的用户评论数。 |
| `[].web_url` | string | 议题的 Web URL。 |
| `[].weight` | integer | 议题的权重。 |

成功后，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性（使用外部议题跟踪器时，如 Jira）：

| 属性 | 类型 | 描述 |
|------------|---------|-------------|
| `[].id` | integer | 议题的 ID。 |
| `[].title` | string | 议题的标题。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/76/merge_requests/1/closes_issues"
```

使用极狐GitLab 议题跟踪器时的示例响应：

```json
[
  {
    "id": 76,
    "iid": 6,
    "project_id": 1,
    "title": "Consequatur vero maxime deserunt laboriosam est voluptas dolorem.",
    "description": "Ratione dolores corrupti mollitia soluta quia.",
    "state": "opened",
    "created_at": "2024-09-06T10:58:49.002Z",
    "updated_at": "2024-09-06T11:01:40.710Z",
    "closed_at": null,
    "closed_by": null,
    "labels": [
      "label"
    ],
    "milestone": {
      "project_id": 1,
      "description": "Ducimus nam enim ex consequatur cumque ratione.",
      "state": "closed",
      "due_date": null,
      "iid": 2,
      "created_at": "2016-01-04T15:31:39.996Z",
      "title": "v4.0",
      "id": 17,
      "updated_at": "2016-01-04T15:31:39.996Z"
    },
    "assignees": [
      {
        "id": 1,
        "username": "root",
        "name": "Administrator",
        "state": "active",
        "locked": false,
        "avatar_url": null,
        "web_url": "https://gitlab.example.com/root"
      }
    ],
    "author": {
      "id": 18,
      "username": "eileen.lowe",
      "name": "Alexandra Bashirian",
      "state": "active",
      "locked": false,
      "avatar_url": null,
      "web_url": "https://gitlab.example.com/eileen.lowe"
    },
    "type": "ISSUE",
    "assignee": {
      "id": 1,
      "username": "root",
      "name": "Administrator",
      "state": "active",
      "locked": false,
      "avatar_url": null,
      "web_url": "https://gitlab.example.com/root"
    },
    "user_notes_count": 1,
    "merge_requests_count": 1,
    "upvotes": 0,
    "downvotes": 0,
    "due_date": null,
    "confidential": false,
    "discussion_locked": null,
    "issue_type": "issue",
    "web_url": "https://gitlab.example.com/my-group/my-project/-/issues/6",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    },
    "task_completion_status": {
      "count": 0,
      "completed_count": 0
    },
    "weight": null,
    "blocking_issues_count": 0
 }
]
```

使用外部议题跟踪器（如 Jira）时的示例响应：

```json
[
   {
       "id" : "PROJECT-123",
       "title" : "此议题的标题"
   }
]
```

## 列出与合并请求相关的议题

从合并请求的标题、描述、提交信息、评论和讨论中列出与其相关的议题。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/related_issues
```

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/76/merge_requests/1/related_issues"
```

使用极狐GitLab 议题跟踪器时的示例响应：

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
      "assignee" : {
         "state" : "active",
         "id" : 1,
         "name" : "Administrator",
         "web_url" : "https://gitlab.example.com/root",
         "avatar_url" : null,
         "username" : "root"
      },
      "updated_at" : "2016-01-04T15:31:51.081Z",
      "id" : 76,
      "title" : "Consequatur vero maxime deserunt laboriosam est voluptas dolorem.",
      "created_at" : "2016-01-04T15:31:51.081Z",
      "iid" : 6,
      "labels" : [],
      "user_notes_count": 1,
      "changes_count": "1"
   }
]
```

使用外部议题跟踪器（如 Jira）时的示例响应：

```json
[
   {
       "id" : "PROJECT-123",
       "title" : "此议题的标题"
   }
]
```

## 订阅合并请求

订阅已认证用户到合并请求以接收通知。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/subscribe
```

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

如果用户已经订阅了该合并请求，端点返回状态码 `HTTP 304 Not Modified`。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/17/subscribe"
```

示例响应：

```json
{
  "id": 1,
  "iid": 1,
  "project_id": 3,
  "title": "test1",
  "description": "修复登录页面 CSS 内边距",
  "state": "merged",
  "created_at": "2017-04-29T08:46:00Z",
  "updated_at": "2017-04-29T08:46:00Z",
  "target_branch": "main",
  "source_branch": "test1",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignee": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "reviewers": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "source_project_id": 2,
  "target_project_id": 3,
  "labels": [
    "Community contribution",
    "Manage"
  ],
  "draft": false,
  "work_in_progress": false,
  "milestone": {
    "id": 5,
    "iid": 1,
    "project_id": 3,
    "title": "v2.0",
    "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
    "state": "closed",
    "created_at": "2015-02-02T19:49:26.013Z",
    "updated_at": "2015-02-02T19:49:26.013Z",
    "due_date": "2018-09-22",
    "start_date": "2018-08-08",
    "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
  },
  "merge_when_pipeline_succeeds": true,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "not_open",
  "sha": "8888888888888888888888888888888888888888",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "user_notes_count": 1,
  "discussion_locked": null,
  "should_remove_source_branch": true,
  "force_remove_source_branch": false,
  "allow_collaboration": false,
  "allow_maintainer_to_push": false,
  "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
  "references": {
    "short": "!1",
    "relative": "!1",
    "full": "my-group/my-project!1"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "squash": false,
  "subscribed": false,
  "changes_count": "1",
  "merged_by": { // 已弃用，将在 API v5 中移除，请使用 `merge_user` 代替
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merge_user": {
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merged_at": "2018-09-07T11:16:17.520Z",
  "merge_after": "2018-09-07T11:16:00.000Z",
  "prepared_at": "2018-09-04T11:16:17.520Z",
  "closed_by": null,
  "closed_at": null,
  "latest_build_started_at": "2018-09-07T07:27:38.472Z",
  "latest_build_finished_at": "2018-09-07T08:07:06.012Z",
  "first_deployed_to_production_at": null,
  "pipeline": {
    "id": 29626725,
    "sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "ref": "patch-28",
    "status": "success",
    "web_url": "https://gitlab.example.com/my-group/my-project/pipelines/29626725"
  },
  "diff_refs": {
    "base_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00",
    "head_sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "start_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00"
  },
  "diverged_commits_count": 2,
  "task_completion_status":{
    "count":0,
    "completed_count":0
  }
}
```

有关响应数据的重要说明，请参见[单个合并请求响应说明](#single-merge-request-response-notes)。

## 取消订阅合并请求

取消已认证用户对合并请求的订阅，不再接收该合并请求的通知。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/unsubscribe
```

| 属性 | 类型 | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/17/unsubscribe"
```

如果用户未订阅该合并请求，端点返回状态码 `HTTP 304 Not Modified`。

示例响应：
```json
{
  "id": 1,
  "iid": 1,
  "project_id": 3,
  "title": "test1",
  "description": "fixed login page css paddings",
  "state": "merged",
  "created_at": "2017-04-29T08:46:00Z",
  "updated_at": "2017-04-29T08:46:00Z",
  "target_branch": "main",
  "source_branch": "test1",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignee": {
    "id": 1,
    "name": "Administrator",
    "username": "admin",
    "state": "active",
    "avatar_url": null,
    "web_url" : "https://gitlab.example.com/admin"
  },
  "assignees": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "reviewers": [{
    "name": "Miss Monserrate Beier",
    "username": "axel.block",
    "id": 12,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/axel.block"
  }],
  "source_project_id": 2,
  "target_project_id": 3,
  "labels": [
    "Community contribution",
    "Manage"
  ],
  "draft": false,
  "work_in_progress": false,
  "milestone": {
    "id": 5,
    "iid": 1,
    "project_id": 3,
    "title": "v2.0",
    "description": "Assumenda aut placeat expedita exercitationem labore sunt enim earum.",
    "state": "closed",
    "created_at": "2015-02-02T19:49:26.013Z",
    "updated_at": "2015-02-02T19:49:26.013Z",
    "due_date": "2018-09-22",
    "start_date": "2018-08-08",
    "web_url": "https://gitlab.example.com/my-group/my-project/milestones/1"
  },
  "merge_when_pipeline_succeeds": true,
  "merge_status": "can_be_merged",
  "detailed_merge_status": "not_open",
  "sha": "8888888888888888888888888888888888888888",
  "merge_commit_sha": null,
  "squash_commit_sha": null,
  "user_notes_count": 1,
  "discussion_locked": null,
  "should_remove_source_branch": true,
  "force_remove_source_branch": false,
  "allow_collaboration": false,
  "allow_maintainer_to_push": false,
  "web_url": "http://gitlab.example.com/my-group/my-project/merge_requests/1",
  "references": {
    "short": "!1",
    "relative": "!1",
    "full": "my-group/my-project!1"
  },
  "time_stats": {
    "time_estimate": 0,
    "total_time_spent": 0,
    "human_time_estimate": null,
    "human_total_time_spent": null
  },
  "squash": false,
  "subscribed": false,
  "changes_count": "1",
  "merged_by": { // Deprecated and will be removed in API v5, use `merge_user` instead
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merge_user": {
    "id": 87854,
    "name": "Douwe Maan",
    "username": "DouweM",
    "state": "active",
    "avatar_url": "https://gitlab.example.com/uploads/-/system/user/avatar/87854/avatar.png",
    "web_url": "https://gitlab.com/DouweM"
  },
  "merged_at": "2018-09-07T11:16:17.520Z",
  "merge_after": "2018-09-07T11:16:00.000Z",
  "prepared_at": "2018-09-04T11:16:17.520Z",
  "closed_by": null,
  "closed_at": null,
  "latest_build_started_at": "2018-09-07T07:27:38.472Z",
  "latest_build_finished_at": "2018-09-07T08:07:06.012Z",
  "first_deployed_to_production_at": null,
  "pipeline": {
    "id": 29626725,
    "sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "ref": "patch-28",
    "status": "success",
    "web_url": "https://gitlab.example.com/my-group/my-project/pipelines/29626725"
  },
  "diff_refs": {
    "base_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00",
    "head_sha": "2be7ddb704c7b6b83732fdd5b9f09d5a397b5f8f",
    "start_sha": "c380d3acebd181f13629a25d2e2acca46ffe1e00"
  },
  "diverged_commits_count": 2,
  "task_completion_status":{
    "count":0,
    "completed_count":0
  }
}
```

关于响应数据的重要说明，请参见[单个合并请求响应说明](#single-merge-request-response-notes)。

## 创建待办事项

为当前用户在合并请求上手动创建一个待办事项。
如果该用户在此合并请求上已存在待办事项，此端点会返回状态码 `HTTP 304 Not Modified`。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/todo
```

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/27/todo"
```

响应示例：

```json
{
  "id": 113,
  "project": {
    "id": 3,
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
  "target_type": "MergeRequest",
  "target": {
    "id": 27,
    "iid": 7,
    "project_id": 3,
    "title": "Et voluptas laudantium minus nihil recusandae ut accusamus earum aut non.",
    "description": "Veniam sunt nihil modi earum cumque illum delectus. Nihil ad quis distinctio quia. Autem eligendi at quibusdam repellendus.",
    "state": "merged",
    "created_at": "2016-06-17T07:48:04.330Z",
    "updated_at": "2016-07-01T11:14:15.537Z",
    "target_branch": "allow_regex_for_project_skip_ref",
    "source_branch": "backup",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "name": "Jarret O'Keefe",
      "username": "francisca",
      "id": 14,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a7fa515d53450023c83d62986d0658a8?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/francisca",
      "discussion_locked": false
    },
    "assignee": {
      "name": "Dr. Gabrielle Strosin",
      "username": "barrett.krajcik",
      "id": 4,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/733005fcd7e6df12d2d8580171ccb966?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/barrett.krajcik"
    },
    "assignees": [{
      "name": "Miss Monserrate Beier",
      "username": "axel.block",
      "id": 12,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/axel.block"
    }],
    "reviewers": [{
      "name": "Miss Monserrate Beier",
      "username": "axel.block",
      "id": 12,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/46f6f7dc858ada7be1853f7fb96e81da?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/axel.block"
    }],
    "source_project_id": 3,
    "target_project_id": 3,
    "labels": [],
    "draft": false,
    "work_in_progress": false,
    "milestone": {
      "id": 27,
      "iid": 2,
      "project_id": 3,
      "title": "v1.0",
      "description": "Quis ea accusantium animi hic fuga assumenda.",
      "state": "active",
      "created_at": "2016-06-17T07:47:33.840Z",
      "updated_at": "2016-06-17T07:47:33.840Z",
      "due_date": null
    },
    "merge_when_pipeline_succeeds": false,
    "merge_status": "unchecked",
    "detailed_merge_status": "not_open",
    "subscribed": true,
    "sha": "8888888888888888888888888888888888888888",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 7,
    "changes_count": "1",
    "should_remove_source_branch": true,
    "force_remove_source_branch": false,
    "squash": false,
    "web_url": "http://example.com/my-group/my-project/merge_requests/1",
    "references": {
      "short": "!1",
      "relative": "!1",
      "full": "my-group/my-project!1"
    }
  },
  "target_url": "https://gitlab.example.com/gitlab-org/gitlab-ci/merge_requests/7",
  "body": "Et voluptas laudantium minus nihil recusandae ut accusamus earum aut non.",
  "state": "pending",
  "created_at": "2016-07-01T11:14:15.530Z"
}
```

## 获取合并请求的差异版本

获取合并请求的差异版本。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/versions
```

| 属性                | 类型    | 是否必需 | 描述                           |
|---------------------|---------|----------|---------------------------------------|
| `id`                | String  | 是       | 项目 ID。                |
| `merge_request_iid` | integer | 是       | 合并请求的内部 ID。 |

有关响应中 SHA 值的说明，
请参见[API 响应中的 SHA 值](#shas-in-the-api-response)。

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/versions"
```

响应示例：

```json
[{
  "id": 110,
  "head_commit_sha": "33e2ee8579fda5bc36accc9c6fbd0b4fefda9e30",
  "base_commit_sha": "eeb57dffe83deb686a60a71c16c32f71046868fd",
  "start_commit_sha": "eeb57dffe83deb686a60a71c16c32f71046868fd",
  "created_at": "2016-07-26T14:44:48.926Z",
  "merge_request_id": 105,
  "state": "collected",
  "real_size": "1",
  "patch_id_sha": "d504412d5b6e6739647e752aff8e468dde093f2f"
}, {
  "id": 108,
  "head_commit_sha": "3eed087b29835c48015768f839d76e5ea8f07a24",
  "base_commit_sha": "eeb57dffe83deb686a60a71c16c32f71046868fd",
  "start_commit_sha": "eeb57dffe83deb686a60a71c16c32f71046868fd",
  "created_at": "2016-07-25T14:21:33.028Z",
  "merge_request_id": 105,
  "state": "collected",
  "real_size": "1",
  "patch_id_sha": "72c30d1f0115fc1d2bb0b29b24dc2982cbcdfd32"
}]
```

### API 响应中的 SHA 值

| SHA 字段           | 用途                                                                             |
|--------------------|-------------------------------------------------------------------------------------|
| `base_commit_sha`  | 源分支与目标分支之间的合并基础提交 SHA 值。        |
| `head_commit_sha`  | 源分支的最新提交。                                               |
| `start_commit_sha` | 创建此差异版本时，目标分支的最新提交 SHA 值。 |

## 获取特定合并请求差异版本

{{< history >}}

- `collapsed` 和 `too_large` 响应属性在极狐GitLab 18.4 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/199633)。

{{< /history >}}

获取合并请求的特定差异版本。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/versions/:version_id
```

支持的属性：

| 属性                | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `id`                | String  | 是       | 项目 ID。 |
| `merge_request_iid` | integer | 是       | 合并请求的内部 ID。 |
| `version_id`        | integer | 是       | 合并请求差异版本的 ID。 |
| `unidiff`           | boolean | 否       | 以 [unified diff](https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html) 格式呈现差异。默认为 false。[引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/130610) 极狐GitLab 16.5。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下
响应属性：

| 属性                          | 类型         | 描述 |
|-------------------------------|--------------|-------------|
| `id`                          | integer      | 合并请求差异版本的 ID。 |
| `base_commit_sha`             | string       | 源分支与目标分支之间的合并基础提交 SHA 值。 |
| `commits`                     | object array | 合并请求差异中的提交。 |
| `commits[].id`                | string       | 提交的 ID。 |
| `commits[].short_id`          | string       | 提交的短 ID。 |
| `commits[].created_at`        | datetime     | 与 `committed_date` 字段相同。 |
| `commits[].parent_ids`        | array        | 父提交的 ID。 |
| `commits[].title`             | string       | 提交标题。 |
| `commits[].message`           | string       | 提交信息。 |
| `commits[].author_name`       | string       | 提交作者的姓名。 |
| `commits[].author_email`      | string       | 提交作者的电子邮件地址。 |
| `commits[].authored_date`     | datetime     | 提交的创作日期和时间。 |
| `commits[].committer_name`    | string       | 提交者的姓名。 |
| `commits[].committer_email`   | string       | 提交者的电子邮件地址。 |
| `commits[].committed_date`    | datetime     | 提交的日期和时间。 |
| `commits[].trailers`          | object       | 为提交解析的 Git trailers。重复的键仅包含最后一个值。 |
| `commits[].extended_trailers` | object       | 为提交解析的 Git trailers。 |
| `commits[].web_url`           | string       | 合并请求的 Web URL。 |
| `created_at`                  | datetime     | 合并请求的创建日期和时间。 |
| `diffs`                       | object array | 合并请求差异版本中的差异。 |
| `diffs[].a_mode`              | string       | 文件的旧文件模式。 |
| `diffs[].b_mode`              | string       | 文件的新文件模式。 |
| `diffs[].collapsed`           | boolean      | 文件差异已被排除，但可以按需获取。 |
| `diffs[].deleted_file`        | boolean      | 文件已被删除。 |
| `diffs[].diff`                | string       | 差异内容。 |
| `diffs[].generated_file`      | boolean      | 文件被[标记为已生成](../user/project/merge_requests/changes.md#collapse-generated-files)。 |
| `diffs[].new_file`            | boolean      | 文件已被添加。 |
| `diffs[].new_path`            | string       | 文件的新路径。 |
| `diffs[].old_path`            | string       | 文件的旧路径。 |
| `diffs[].renamed_file`        | boolean      | 文件已被重命名。 |
| `diffs[].too_large`           | boolean      | 文件差异已被排除且无法检索。 |
| `head_commit_sha`             | string       | 源分支的最新提交。 |
| `merge_request_id`            | integer      | 合并请求的 ID。 |
| `patch_id_sha`                | string       | 合并请求差异的 [Patch ID](https://git-scm.com/docs/git-patch-id)。 |
| `real_size`                   | string       | 合并请求差异中的变更数量。 |
| `start_commit_sha`            | string       | 创建此差异版本时，目标分支的最新提交 SHA 值。 |
| `state`                       | string       | 合并请求差异的状态。可以是 `collected`、`overflow`、`without_files`。已废弃的值: `timeout`、`overflow_commits_safe_size`、`overflow_diff_files_limit`、`overflow_diff_lines_limit`。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/merge_requests/1/versions/1"
```

响应示例：

```json
{
  "id": 110,
  "head_commit_sha": "33e2ee8579fda5bc36accc9c6fbd0b4fefda9e30",
  "base_commit_sha": "eeb57dffe83deb686a60a71c16c32f71046868fd",
  "start_commit_sha": "eeb57dffe83deb686a60a71c16c32f71046868fd",
  "created_at": "2016-07-26T14:44:48.926Z",
  "merge_request_id": 105,
  "state": "collected",
  "real_size": "1",
  "patch_id_sha": "d504412d5b6e6739647e752aff8e468dde093f2f",
  "commits": [{
    "id": "33e2ee8579fda5bc36accc9c6fbd0b4fefda9e30",
    "short_id": "33e2ee85",
    "parent_ids": [],
    "title": "Change year to 2018",
    "author_name": "Administrator",
    "author_email": "admin@example.com",
    "authored_date": "2016-07-26T17:44:29.000+03:00",
    "committer_name": "Administrator",
    "committer_email": "admin@example.com",
    "committed_date": "2016-07-26T17:44:29.000+03:00",
    "created_at": "2016-07-26T17:44:29.000+03:00",
    "message": "Change year to 2018",
    "trailers": {},
    "extended_trailers": {},
    "web_url": "https://gitlab.example.com/project/-/commit/33e2ee8579fda5bc36accc9c6fbd0b4fefda9e30"
  }, {
    "id": "aa24655de48b36335556ac8a3cd8bb521f977cbd",
    "short_id": "aa24655d",
    "parent_ids": [],
    "title": "Update LICENSE",
    "author_name": "Administrator",
    "author_email": "admin@example.com",
    "authored_date": "2016-07-25T17:21:53.000+03:00",
    "committer_name": "Administrator",
    "committer_email": "admin@example.com",
    "committed_date": "2016-07-25T17:21:53.000+03:00",
    "created_at": "2016-07-25T17:21:53.000+03:00",
    "message": "Update LICENSE",
    "trailers": {},
    "extended_trailers": {},
    "web_url": "https://gitlab.example.com/project/-/commit/aa24655de48b36335556ac8a3cd8bb521f977cbd"
  }, {
    "id": "3eed087b29835c48015768f839d76e5ea8f07a24",
    "short_id": "3eed087b",
    "parent_ids": [],
    "title": "Add license",
    "author_name": "Administrator",
    "author_email": "admin@example.com",
    "authored_date": "2016-07-25T17:21:20.000+03:00",
    "committer_name": "Administrator",
    "committer_email": "admin@example.com",
    "committed_date": "2016-07-25T17:21:20.000+03:00",
    "created_at": "2016-07-25T17:21:20.000+03:00",
    "message": "Add license",
    "trailers": {},
    "extended_trailers": {},
    "web_url": "https://gitlab.example.com/project/-/commit/3eed087b29835c48015768f839d76e5ea8f07a24"
  }],
  "diffs": [{
    "old_path": "LICENSE",
    "new_path": "LICENSE",
    "a_mode": "0",
    "b_mode": "100644",
    "diff": "@@ -0,0 +1,21 @@\n+The MIT License (MIT)\n+\n+Copyright (c) 2018 Administrator\n+\n+Permission is hereby granted, free of charge, to any person obtaining a copy\n+of this software and associated documentation files (the \"Software\"), to deal\n+in the Software without restriction, including without limitation the rights\n+to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n+copies of the Software, and to permit persons to whom the Software is\n+furnished to do so, subject to the following conditions:\n+\n+The above copyright notice and this permission notice shall be included in all\n+copies or substantial portions of the Software.\n+\n+THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n+IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n+FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n+AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n+LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n+OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n+SOFTWARE.\n",
    "collapsed": false,
    "too_large": false,
    "new_file": true,
    "renamed_file": false,
    "deleted_file": false,
    "generated_file": false
  }]
}
```

## 为合并请求设置时间预估

为合并请求设置预估工作时间。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/time_estimate
```

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |
| `duration`          | string            | 是       | 持续时间的人类可读格式，例如 `3h30m`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/93/time_estimate?duration=3h30m"
```

响应示例：

```json
{
  "human_time_estimate": "3h 30m",
  "human_total_time_spent": null,
  "time_estimate": 12600,
  "total_time_spent": 0
}
```

## 重置合并请求的时间预估

将合并请求的预估时间重置为 0 秒。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/reset_time_estimate
```

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 项目合并请求的内部 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/93/reset_time_estimate"
```

响应示例：

```json
{
  "human_time_estimate": null,
  "human_total_time_spent": null,
  "time_estimate": 0,
  "total_time_spent": 0
}
```

## 为合并请求添加花费时间

为合并请求添加已花费的时间。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/add_spent_time
```

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |
| `duration`          | string            | 是       | 持续时间的人类可读格式，例如 `3h30m` |
| `summary`           | string            | 否       | 关于时间花费方式的摘要。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/93/add_spent_time?duration=1h"
```

响应示例：

```json
{
  "human_time_estimate": null,
  "human_total_time_spent": "1h",
  "time_estimate": 0,
  "total_time_spent": 3600
}
```

## 重置合并请求的花费时间

将合并请求的总花费时间重置为 0 秒。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/reset_spent_time
```

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 项目合并请求的内部 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/93/reset_spent_time"
```

响应示例：

```json
{
  "human_time_estimate": null,
  "human_total_time_spent": null,
  "time_estimate": 0,
  "total_time_spent": 0
}
```

## 获取时间跟踪统计信息

获取合并请求的时间跟踪统计信息。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/time_stats
```

| 属性                | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的内部 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/93/time_stats"
```

响应示例：

```json
{
  "human_time_estimate": "2h",
  "human_total_time_spent": "1h",
  "time_estimate": 7200,
  "total_time_spent": 3600
}
```

## 批准

有关批准，请参见[合并请求批准](merge_request_approvals.md)。

## 列出合并请求状态事件

要跟踪设置的状态、设置人以及设置时间，请参见
[资源状态事件 API](resource_state_events.md#merge-requests)。

## 故障排除

### 新建合并请求时 API 字段为空

创建合并请求时，`diff_refs` 和 `changes_count` 字段最初为空。这些字段在创建合并请求后异步填充。更多信息请参见 [issue 386562](https://gitlab.com/gitlab-org/gitlab/-/issues/386562) 以及极狐GitLab 论坛中的[相关讨论](https://forum.gitlab.com/t/diff-refs-empty-after-mr-is-created/78975)。