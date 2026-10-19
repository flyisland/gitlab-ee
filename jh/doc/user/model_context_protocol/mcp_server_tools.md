---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用这些工具通过极狐GitLab MCP 服务器与极狐GitLab 交互。
title: 极狐GitLab MCP 服务器工具
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!warning]
> 要提供有关此功能的反馈，请在 [议题 561564](https://gitlab.com/gitlab-org/gitlab/-/issues/561564) 上留下评论。

极狐GitLab MCP 服务器提供了一组工具，可与您现有的极狐GitLab 工作流集成。
您可以使用这些工具直接与极狐GitLab 交互，并执行常见的极狐GitLab 操作。

<a id="get_mcp_server_version"></a>

## `get_mcp_server_version`

返回极狐GitLab MCP 服务器的当前版本。

示例：

```plaintext
What version of the GitLab MCP server am I connected to?
```

<a id="add_commit"></a>

## `add_commit`

在单次调用中向分支添加一个包含一个或多个文件操作的提交。

| 参数        | 类型             | 是否必需 | 描述 |
|------------------|------------------|----------|-------------|
| `commit_message` | string           | 是      | 提交信息。 |
| `actions`        | array of objects | 是      | 作为单个批次提交的文件操作。 |
| `branch`         | string           | 是      | 要提交到的分支名称。 |
| `project_id`     | string           | 否       | 项目的 ID 或路径。如果未提供 `url`，则为必需。 |
| `url`            | string           | 否       | 项目的极狐GitLab URL。如果未提供 `project_id`，则为必需。 |
| `start_branch`   | string           | 否       | 用于创建新分支的起始分支名称。当 `branch` 不存在时为必需。 |

`actions` 中的每个对象接受以下字段：

| 字段              | 类型    | 是否必需 | 描述 |
|--------------------|---------|----------|-------------|
| `action`           | string  | 是      | 要执行的操作：`create`、`update`、`delete`、`move` 或 `chmod`。 |
| `file_path`        | string  | 是      | 文件的完整路径。 |
| `content`          | string  | 否       | 文件内容。用于 `create`、`update` 和 `move`。与 `old_str` 和 `new_str` 互斥。 |
| `old_str`          | string  | 否       | 在 `update` 操作中要替换的现有文本。需要 `new_str`。 |
| `new_str`          | string  | 否       | 在 `update` 操作中用于替换 `old_str` 的文本。 |
| `previous_path`    | string  | 否       | 原始文件路径。对于 `move` 为必需。 |
| `encoding`         | string  | 否       | `content` 的编码：`text` 或 `base64`。默认为 `text`。 |
| `last_commit_id`   | string  | 否       | 文件的最后已知提交 ID，用于乐观并发控制。 |
| `execute_filemode` | boolean | 否       | 文件是否可执行。对于 `chmod` 为必需。 |

部分编辑仅替换 `old_str` 的一次出现。如果它出现多次，请提供更多上下文。
部分编辑会在服务器上读取完整文件，并受 20 MB GraphQL blob 请求限制的约束。

示例：

```plaintext
In project gitlab-org/gitlab, create README.md on branch "docs-update"
with the content "# New title" and commit message "Add README"
```

<a id="create_issue"></a>

## `create_issue`

在极狐GitLab 项目中创建新议题。

| 参数      | 类型              | 是否必需 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | string            | 是      | 项目的 ID 或 URL 编码路径。 |
| `title`        | string            | 是      | 议题标题。 |
| `description`  | string            | 否       | 议题描述。 |
| `assignee_ids` | array of integers | 否       | 被指派用户的 ID 数组。 |
| `milestone_id` | integer           | 否       | 里程碑的 ID。 |
| `labels`       | array of strings  | 否       | 标记名称数组。 |
| `confidential` | boolean           | 否       | 将议题设置为机密。默认为 `false`。 |
| `epic_id`      | integer           | 否       | 关联史诗的 ID。 |

示例：

```plaintext
Create a new issue titled "Fix login bug" in project 123 with description
"Users cannot log in with special characters in password"
```

<a id="get_issue"></a>

## `get_issue`

检索特定极狐GitLab 议题的详细信息。

| 参数   | 类型    | 是否必需 | 描述 |
|-------------|---------|----------|-------------|
| `id`        | string  | 是      | 项目的 ID 或 URL 编码路径。 |
| `issue_iid` | integer | 是      | 议题的内部 ID。 |

示例：

```plaintext
Get details for issue 42 in project 123
```

<a id="save_merge_request"></a>

## `save_merge_request`

在极狐GitLab 项目中创建或更新合并请求。
`merge_request_iid` 的存在与否决定操作类型：省略它以创建合并请求，或提供它以更新现有合并请求。

| 参数              | 类型              | 是否必需 | 描述 |
|------------------------|-------------------|----------|-------------|
| `project_id`           | string            | 是      | 项目的 ID 或完整路径。 |
| `merge_request_iid`    | integer           | 否       | 合并请求的内部 ID。提供以更新现有合并请求；省略以创建新的。 |
| `title`                | string            | 否       | 合并请求的标题。创建时为必需。 |
| `source_branch`        | string            | 否       | 源分支名称。创建时为必需。 |
| `target_branch`        | string            | 否       | 目标分支名称。创建时为必需。 |
| `target_project_id`    | integer           | 否       | 目标项目的 ID。创建时适用。 |
| `description`          | string            | 否       | 合并请求的描述。 |
| `labels`               | array of strings  | 否       | 标记名称。替换所有现有标记。传递空数组以移除所有标记。 |
| `add_labels`           | array of strings  | 否       | 要添加的标记名称。更新时适用。 |
| `remove_labels`        | array of strings  | 否       | 要移除的标记名称。更新时适用。 |
| `assignees`            | array of strings  | 否       | 要指派的用户名。与 `assignee_ids` 二选一。传递空数组以移除所有指派人。 |
| `assignee_ids`         | array of integers | 否       | 要指派的用户 ID。与 `assignees` 二选一。传递空数组以移除所有指派人。 |
| `reviewers`            | array of strings  | 否       | 要请求评审的用户名。与 `reviewer_ids` 二选一。传递空数组以移除所有审核人。 |
| `reviewer_ids`         | array of integers | 否       | 要请求评审的用户 ID。与 `reviewers` 二选一。传递空数组以移除所有审核人。 |
| `milestone_id`         | integer           | 否       | 里程碑的 ID。 |
| `milestone`            | string            | 否       | 要指派的项目或祖先群组里程碑的标题。与 `milestone_id` 互斥。 |
| `remove_source_branch` | boolean           | 否       | 当合并请求合并时移除源分支。 |
| `squash`               | boolean           | 否       | 合并时将提交压缩为单个提交。 |
| `state_event`          | string            | 否       | 要执行的状态转换。为 `close` 或 `reopen` 之一。更新时适用。 |
| `discussion_locked`    | boolean           | 否       | 锁定合并请求的讨论。更新时适用。 |
| `allow_collaboration`  | boolean           | 否       | 允许可合并到目标分支的成员提交。更新时适用。 |

示例：

```plaintext
Create a merge request in project gitlab-org/gitlab titled "Bug fix broken specs"
from branch "fix/specs-broken" into "master" and enable squash
```

```plaintext
Update merge request 42 in project gitlab-org/gitlab to add the "bug" label and close it
```

<a id="get_merge_request"></a>

## `get_merge_request`

检索合并请求，并可选择检索其差异、提交、评论、流水线或讨论。
除非您使用 `include` 参数请求关联数据，否则仅返回基础合并请求。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `url`               | string  | 否       | 合并请求的极狐GitLab URL。提供此项，或提供 `project_id` 和 `merge_request_iid`。 |
| `project_id`        | string  | 否       | 项目的 ID 或 URL 编码路径。如果缺少 `url`，则为必需。 |
| `merge_request_iid` | integer | 否       | 合并请求的内部 ID。如果缺少 `url`，则为必需。 |
| `include`           | array   | 否       | 与合并请求一起返回的关联方面。为 `diffs`、`commits`、`notes`、`pipelines` 或 `discussions` 之一。每次调用仅限一个方面。 |
| `notes_after`       | string  | 否       | 评论向前分页的光标。仅当 `include` 为 `["notes"]` 时适用。 |
| `notes_first`       | integer | 否       | 光标后要返回的评论数量，最多 100。仅当 `include` 为 `["notes"]` 时适用。 |

`diffs` 方面仅返回变更统计信息：总体总数以及每个文件的添加和删除行数。
要获取补丁文本，请使用 `get_merge_request_diffs`。

示例：

```plaintext
Get merge request 15 in project gitlab-org/gitlab with its commits
```

<a id="list_duo_sessions"></a>

## `list_duo_sessions`

列出您的极狐GitLab Duo Agent Platform 会话，不包括 Duo Chat 会话。
每个会话都包含其单独状态、目标预览、任务流定义和创建时间戳。
项目会话还包含会话 URL。
目标预览可能会被截断。

| 参数      | 类型    | 是否必需 | 描述 |
|----------------|---------|----------|-------------|
| `url`          | string  | 否       | 用于筛选会话的项目的极狐GitLab URL。不要与 `project_id` 一起使用。 |
| `project_id`   | string  | 否       | 用于筛选会话的项目的数字 ID 或完整路径。不要与 `url` 一起使用。 |
| `status_group` | string  | 否       | 会话状态组。为 `active`、`paused`、`awaiting_input`、`completed`、`failed` 或 `canceled` 之一。 |
| `after`        | string  | 否       | 向前分页的光标。 |
| `first`        | integer | 否       | 向前分页要返回的会话数量。默认为 20，最大为 100。 |

`status_group` 筛选器可以返回具有多个单独状态的会话。
每次调用返回单页结果。
如果存在更多页面，响应会包含 `pageInfo.endCursor`，您可以将其作为 `after` 传递。

示例：

```plaintext
List my active Duo Agent Platform sessions in gitlab-org/gitlab
```

<a id="list_merge_requests"></a>

## `list_merge_requests`

列出或搜索极狐GitLab 项目中的合并请求，返回紧凑的合并请求元数据。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `url`               | string  | 否       | 项目的 URL。请仅提供 `url` 或 `project_id` 之一。 |
| `project_id`        | string  | 否       | 项目的 ID 或完整路径。请仅提供 `url` 或 `project_id` 之一。 |
| `author_username`   | string  | 否       | 按合并请求作者的用户名筛选。 |
| `assignee_username` | string  | 否       | 按指派人的用户名筛选。 |
| `reviewer_username` | string  | 否       | 按审核人的用户名筛选。 |
| `state`             | string  | 否       | 按状态筛选。为 `opened`、`closed`、`merged`、`locked` 或 `all` 之一。省略以包含任何状态。 |
| `scope`             | string  | 否       | 相对于已认证用户的筛选。为 `created_by_me`、`assigned_to_me` 或 `review_requested` 之一。显式用户名在该字段上优先。 |
| `milestone`         | string  | 否       | 按里程碑标题筛选。 |
| `labels`            | string  | 否       | 逗号分隔的标记名称列表。仅返回具有所有这些标记的合并请求。 |
| `search`            | string  | 否       | 针对合并请求标题和描述匹配的搜索查询。 |
| `after`             | string  | 否       | 向前分页的光标。 |
| `first`             | integer | 否       | 向前分页要返回的合并请求数量。默认为 20，最大为 100。 |

要检索单个合并请求的完整详细信息，请使用 `get_merge_request`。其差异、提交和评论可分别从 `get_merge_request_diffs`、`get_merge_request_commits` 和 `get_merge_request_notes` 获取。要跨资源类型进行全文搜索，请使用 `search`。

示例：

```plaintext
List my open merge requests in gitlab-org/gitlab
```

<a id="get_merge_request_commits"></a>

## `get_merge_request_commits`

检索特定极狐GitLab 合并请求中的提交列表。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `id`                | string  | 是      | 项目的 ID 或 URL 编码路径。 |
| `merge_request_iid` | integer | 是      | 合并请求的内部 ID。 |
| `per_page`          | integer | 否       | 每页的提交数量。 |
| `page`              | integer | 否       | 当前页码。 |

示例：

```plaintext
Show me all commits in merge request 42 from project 123
```

<a id="get_merge_request_diffs"></a>

## `get_merge_request_diffs`

检索特定极狐GitLab 合并请求的差异。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `id`                | string  | 是      | 项目的 ID 或 URL 编码路径。 |
| `merge_request_iid` | integer | 是      | 合并请求的内部 ID。 |
| `per_page`          | integer | 否       | 每页的差异数量。 |
| `page`              | integer | 否       | 当前页码。 |

示例：

```plaintext
What files were changed in merge request 25 in the gitlab project?
```

<a id="get_merge_request_pipelines"></a>

## `get_merge_request_pipelines`

检索特定极狐GitLab 合并请求的流水线。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `id`                | string  | 是      | 项目的 ID 或 URL 编码路径。 |
| `merge_request_iid` | integer | 是      | 合并请求的内部 ID。 |

示例：

```plaintext
Show me all pipelines for merge request 42 in project gitlab-org/gitlab
```

<a id="save_note"></a>

## `save_note`

以已认证用户身份向极狐GitLab 合并请求或工作项添加评论，或回复现有讨论线程。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `url`               | string  | 否       | 合并请求或工作项的 URL。URL 决定目标类型。 |
| `project_id`        | string  | 否       | 项目的 ID 或路径。与 `merge_request_iid` 一起使用时为必需，对于项目级工作项与 `work_item_iid` 一起使用时也为必需。 |
| `group_id`          | string  | 否       | 群组的 ID 或路径。对于群组级工作项与 `work_item_iid` 一起使用时为必需。 |
| `merge_request_iid` | integer | 否       | 合并请求的内部 ID。与 `project_id` 一起提供。与 `work_item_iid` 互斥。 |
| `work_item_iid`     | integer | 否       | 工作项的内部 ID。与 `project_id` 或 `group_id` 一起提供。与 `merge_request_iid` 互斥。 |
| `body`              | string  | 是      | 评论内容。行不能以 `/` 开头，以避免触发快速操作（例如 `/merge`）。 |
| `internal`          | boolean | 否       | 将评论标记为内部评论（仅对至少具有报告者角色的成员可见）。默认为 `false`。 |
| `discussion_id`     | string  | 否       | 要回复的讨论的全局 ID（格式为 `gid://gitlab/Discussion/<id>`）。如果缺失，则创建新的顶级评论。 |

示例：

- 评论合并请求：

  ```plaintext
  Reply "Thanks, fixed in the latest push" to merge request 42 in project gitlab-org/gitlab
  ```

- 评论工作项：

  ```plaintext
  Add a comment "This looks good to me" to work item 42 in project gitlab-org/gitlab
  ```

<a id="get_merge_request_notes"></a>

## `get_merge_request_notes`

检索特定极狐GitLab 合并请求的备注（评论和系统备注）。

| 参数           | 类型    | 是否必需 | 描述                                                                                    |
|---------------------|---------|----------|--------------------------------------------------------------------------------------------------|
| `url`               | string  | 否       | 极狐GitLab 合并请求的 URL。如果缺少 `project_id` 和 `merge_request_iid`，则为必需。   |
| `project_id`        | string  | 否       | 项目的 ID 或 URL 编码路径。如果缺少 `url`，则为必需。                           |
| `merge_request_iid` | integer | 否       | 合并请求的内部 ID。如果缺少 `url`，则为必需。                                |
| `after`             | string  | 否       | 向前分页的光标。                                                                 |
| `before`            | string  | 否       | 向后分页的光标。                                                                |
| `first`             | integer | 否       | 向前分页要返回的评论数量。                                              |
| `last`              | integer | 否       | 向后分页要返回的评论数量。                                             |

每个返回的评论都包含其讨论 ID，因此相关评论可以分组到线程中。

示例：

```plaintext
Show me all comments on merge request 5 in project gitlab-org/gitlab
```

<a id="save_merge_request_review"></a>

## `save_merge_request_review`

以已认证用户身份写入合并请求评审产物。每次调用仅执行一个操作，通过 `method` 参数选择：

| 方法               | 操作 |
|----------------------|--------|
| `create_note`        | 添加顶级评论。 |
| `reply_discussion`   | 在现有讨论中回复。 |
| `create_diff_note`   | 评论特定差异行。 |
| `resolve_discussion` | 解决或取消解决讨论。 |
| `submit_review`      | 在一次调用中发布多个差异评论和可选摘要。 |
| `post_duo_review`    | 请求极狐GitLab Duo 评审合并请求。需要极狐GitLab Duo 代码评审。 |
| `approve`            | 批准合并请求。已批准的调用会以状态 `already_approved` 成功。 |
| `unapprove`          | 移除您的批准。没有先前批准的调用会以状态 `not_approved` 成功。 |

来自 `post_duo_review`、`approve` 和 `unapprove` 的响应包含合并请求当前的 `diff_head_sha`，因此您可以判断现有批准或评审是否仍覆盖最新提交。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `url`               | string  | 否       | 极狐GitLab 合并请求的 URL。如果缺少 `project_id` 和 `merge_request_iid`，则为必需。 |
| `project_id`        | string  | 否       | 项目的 ID 或路径。如果缺少 `url`，则为必需。 |
| `merge_request_iid` | integer | 否       | 合并请求的内部 ID。如果缺少 `url`，则为必需。 |
| `method`            | string  | 是      | 要执行的操作。属于不同方法的参数将被拒绝。 |
| `body`              | string  | 否       | 评论文本。对于 `create_note`、`reply_discussion` 和 `create_diff_note` 为必需。行不能以 `/` 开头，以避免触发快速操作（例如 `/merge`）。 |
| `discussion_id`     | string  | 否       | 要操作的讨论。对于 `reply_discussion` 和 `resolve_discussion` 为必需。接受全局 ID 或裸讨论 ID。 |
| `internal`          | boolean | 否       | 对于 `create_note`，将评论标记为内部评论。 |
| `resolved`          | boolean | 否       | 对于 `resolve_discussion`：`true` 表示解决，`false` 表示取消解决。对于该方法为必需。 |
| `old_path`          | string  | 否       | 对于 `create_diff_note`，变更前的文件路径。提供 `old_path` 或 `new_path`，或两者都提供。 |
| `new_path`          | string  | 否       | 对于 `create_diff_note`，变更后的文件路径。 |
| `old_line`          | integer | 否       | 对于 `create_diff_note`，旧版本中的行号。提供 `old_line` 或 `new_line`，或两者都提供。 |
| `new_line`          | integer | 否       | 对于 `create_diff_note`，新版本中的行号。 |
| `comments`          | array   | 否       | 对于 `submit_review`，1-20 条差异评论。每个条目包含 `file` 和 `body`（必需），以及 `old_line`、`new_line` 和 `suggestion`（可选）。对于该方法为必需。`file` 是变更后的路径；对于重命名文件，请改用 `create_diff_note`。 |
| `verdict`           | string  | 否       | 对于 `submit_review`，添加到摘要评论前面的总体结论。 |
| `summary`           | string  | 否       | 对于 `submit_review`，在差异评论之后发布的摘要评论。 |
| `summary_internal`  | boolean | 否       | 对于 `submit_review`，将摘要评论标记为内部评论。 |
| `sha`               | string  | 否       | 对于 `approve`，头部 SHA 保护。当提供且不再匹配合并请求头部时，批准将被拒绝。传递由 `get_merge_request` 返回的完整 40 字符 `diff_head_sha`。 |

示例：

```plaintext
Review merge request 42 in project gitlab-org/gitlab and leave your findings as diff comments with a summary
```

<a id="list_project_members"></a>

## `list_project_members`

列出极狐GitLab 项目的成员及其角色和访问级别。

| 参数           | 类型    | 是否必需 | 描述 |
|---------------------|---------|----------|-------------|
| `project_id`        | string  | 是      | 项目的完整路径或数字 ID（例如 `gitlab-org/gitlab` 或 `278964`）。 |
| `include_inherited` | boolean | 否       | 同时返回从父群组或项目的子群组继承角色的成员。默认为 `false`。 |
| `query`             | string  | 否       | 仅返回名称或用户名包含此文本的成员。 |
| `first`             | integer | 否       | 向前分页要返回的成员数量（默认 20，最大 100）。 |
| `after`             | string  | 否       | 向前分页的光标。 |

对于每个成员，响应返回用户 ID、用户名、名称、数字 `access_level`、匹配的 `access_level_name`（例如 `Maintainer`）以及成员资格 `expires_at` 日期。
通过电子邮件受邀但尚未接受邀请的成员不会返回。

每次调用返回单页结果。
如果存在更多页面，响应 `metadata` 包含一个 `end_cursor`，您可以将其作为 `after` 传递以获取下一页。

示例：

```plaintext
Who are the maintainers of gitlab-org/gitlab?
```

<a id="accept_merge_request"></a>

## `accept_merge_request`

合并合并请求，或安排其自动合并。如果不提供 `strategy`，合并会立即开始并异步完成。如果提供 `strategy`，则会启用自动合并，合并请求会在其检查通过后合并。要改为批准合并请求，请使用 `save_merge_request_review` 工具。

对已合并的合并请求的调用会以状态 `already_merged` 成功，对已安排的合并请求使用 `strategy` 的调用会以状态 `already_scheduled` 成功。

| 参数                     | 类型    | 是否必需 | 描述 |
|-------------------------------|---------|----------|-------------|
| `url`                         | string  | 否       | 合并请求的极狐GitLab URL。提供此项，或提供 `project_id` 和 `merge_request_iid`。 |
| `project_id`                  | string  | 否       | 项目的 ID 或路径。如果缺少 `url`，则为必需。 |
| `merge_request_iid`           | integer | 否       | 合并请求的内部 ID。如果缺少 `url`，则为必需。 |
| `sha`                         | string  | 是      | 头部 SHA 保护。当它不再匹配合并请求头部时，合并将被拒绝。传递由 `get_merge_request` 返回的 `diff_head_sha`。 |
| `strategy`                    | string  | 否       | 自动合并策略，例如 `merge_when_checks_pass`。提供时，启用自动合并而不是立即合并。 |
| `squash`                      | boolean | 否       | 合并时将提交压缩为单个提交。 |
| `commit_message`              | string  | 否       | 自定义合并提交信息。 |
| `squash_commit_message`       | string  | 否       | 自定义压缩提交信息。当 `squash` 为 `true` 时适用。 |
| `should_remove_source_branch` | boolean | 否       | 合并后移除源分支。 |

示例：

```plaintext
Merge merge request 42 in project gitlab-org/gitlab once its checks pass, and remove the source branch
```

<a id="add_branch"></a>

## `add_branch`

从源引用向极狐GitLab 项目添加分支。

| 参数    | 类型   | 是否必需 | 描述 |
|--------------|--------|----------|-------------|
| `url`        | string | 否       | 项目的极狐GitLab URL。提供此项，或提供 `project_id`。 |
| `project_id` | string | 否       | 项目的 ID 或路径。如果未提供 `url`，则为必需。 |
| `branch`     | string | 是      | 新分支的名称。 |
| `ref`        | string | 是      | 用于创建新分支的分支名称或提交 SHA。 |

示例：

```plaintext
Create a branch named feature/x from main in project gitlab-org/gitlab
```

<a id="get_repository_file"></a>

## `get_repository_file`

在特定引用处从代码仓库检索单个文件的内容。

内容来自代码仓库，而不是来自您的本地文件系统。
文件按 `ref` 处的提交状态返回，因此本地检出中的未提交更改不会包含在内。

| 参数    | 类型    | 是否必需 | 描述 |
|--------------|---------|----------|-------------|
| `url`        | string  | 否       | 文件的 URL，例如 `https://gitlab.example.com/my-group/my-project/-/blob/main/app/models/user.rb`。提供此项，或提供 `project_id`、`file_path` 和 `ref`。 |
| `project_id` | string  | 否       | 项目的 ID 或完整路径。如果未提供 `url`，则为必需。 |
| `file_path`  | string  | 否       | 相对于代码仓库根目录的文件路径。如果未提供 `url`，则为必需。 |
| `ref`        | string  | 否       | 分支名称、标签名称或提交 SHA。使用 `HEAD` 表示默认分支。如果未提供 `url`，则为必需。 |
| `offset`     | integer | 否       | 从零开始的行号，用于开始读取。默认为 `0`。 |
| `limit`      | integer | 否       | 要返回的最大行数。默认值和最大值均为 `2000`。 |

响应包含一个 `metadata` 对象，其中包含 `total_lines`、`returned_lines`、`truncated` 和 `size_bytes`。
当响应仅覆盖文件的一部分时，`system_instruction` 会说明下一次调用中要使用的 `offset`。

此工具仅返回文本。
二进制文件和存储在 Git LFS 中的文件会返回错误。
项目从极狐GitLab Duo 上下文中排除的文件也会返回错误。

示例：

```plaintext
Show me app/models/user.rb from the main branch of my-group/my-project
```

<a id="get_commit"></a>

## `get_commit`

检索单个提交的元数据，并可选择检索其差异或评论。

| 参数     | 类型    | 是否必需 | 描述 |
|---------------|---------|----------|-------------|
| `url`         | string  | 否       | 极狐GitLab 提交的 URL。如果未提供 `project_id` 和 `commit_sha`，则为必需。 |
| `project_id`  | string  | 否       | 项目的 ID 或 URL 编码路径。如果未提供 `url`，则为必需。 |
| `commit_sha`  | string  | 否       | 要查找的提交。接受完整或短 SHA、分支名称或标签名称。如果未提供 `url`，则为必需。 |
| `include`     | array   | 否       | 要内联获取的关联方面，每次调用一个（`diff` 或 `notes`）。基础元数据始终返回。 |
| `diff_detail` | string  | 否       | 提交差异中的详细程度。仅当 `include` 包含 `diff` 时适用。可以是 `stats` 或 `full_patch`。默认为 `stats`。 |
| `notes_after` | string  | 否       | 获取下一页评论的令牌。仅当 `include` 包含 `notes` 时适用。 |
| `notes_first` | integer | 否       | 每页要返回的评论数量（最大 100）。仅当 `include` 包含 `notes` 时适用。 |

当 `diff_detail` 设置为 `stats` 时，差异方面返回每个文件和摘要的行数。
当设置为 `full_patch` 时，返回补丁文本。

示例：

```plaintext
Show me commit abc123 in gitlab-org/gitlab with its diff stats
```

<a id="get_pipeline"></a>

## `get_pipeline`

检索流水线，并可选择检索其作业、下游流水线或桥接（触发）作业。

| 参数     | 类型    | 是否必需 | 描述 |
|---------------|---------|----------|-------------|
| `id`          | string  | 是      | 项目的 ID 或完整路径。 |
| `pipeline_id` | integer | 是      | 流水线的 ID。 |
| `include`     | array   | 否       | 与流水线一起包含的方面，每次调用一个：`jobs`、`downstream_pipelines` 或 `bridge_jobs`。 |
| `job_status`  | string  | 否       | 按状态筛选 `jobs` 方面（例如 `failed`）。仅当 `include` 为 `jobs` 时适用。 |
| `first`       | integer | 否       | 为所选 `include` 方面返回的条目数量。默认为 `20`，最大为 `100`。 |
| `after`       | string  | 否       | 所选 `include` 方面向前分页的光标。使用先前响应中的 `page_info.end_cursor`。 |

当触发作业尚未触发下游流水线时，以及当您无权访问该流水线时，桥接作业的 `downstream_pipeline` 都会被省略（`null`）。

每个下游流水线都包含一个 `project_full_path`，因为下游流水线可能属于不同的项目。请将该值用作后续调用的 `id`。

示例：

- 获取流水线：

  ```plaintext
  Get the status of pipeline 12345 in project gitlab-org/gitlab
  ```

- 获取流水线的失败作业：

  ```plaintext
  Show me the failed jobs in pipeline 12345 for project gitlab-org/gitlab
  ```

- 获取流水线的下游流水线：

  ```plaintext
  Show me the downstream pipelines triggered by pipeline 12345 in project gitlab-org/gitlab
  ```

<a id="get_pipeline_jobs"></a>

## `get_pipeline_jobs`

检索特定极狐GitLab CI/CD 流水线的作业。要在单次调用中同时获取作业和流水线的其余数据，请改用带有 `include: jobs` 的 `get_pipeline` 工具。

| 参数     | 类型    | 是否必需 | 描述 |
|---------------|---------|----------|-------------|
| `id`          | string  | 是      | 项目的 ID 或 URL 编码路径。 |
| `pipeline_id` | integer | 是      | 流水线的 ID。 |
| `per_page`    | integer | 否       | 每页的作业数量。 |
| `page`        | integer | 否       | 当前页码。 |

示例：

```plaintext
Show me all jobs in pipeline 12345 for project gitlab-org/gitlab
```

<a id="get_job"></a>

## `get_job`

获取 CI/CD 作业的元数据，并可选择获取其跟踪/日志。

| 参数     | 类型    | 是否必需 | 描述 |
|---------------|---------|----------|-------------|
| `id`          | string  | 是      | 项目的 ID 或完整路径。 |
| `job_id`      | integer | 是      | 作业的 ID。 |
| `include`     | array   | 否       | 与作业一起包含的方面，每次调用一个：`log`。 |
| `byte_offset` | integer | 否       | 开始读取作业日志的字节偏移量。仅当 `include` 为 `log` 时适用。默认为 `0`。 |
| `byte_limit`  | integer | 否       | 要返回的作业日志的最大字节数。仅当 `include` 为 `log` 时适用。默认值和最大值均为 `512000`。 |

当日志长度超过 `byte_limit` 时，响应会报告总大小，并告知您下一个窗口要使用的 `byte_offset`。

示例：

- 获取作业的元数据：

  ```plaintext
  Get the status of job 88 in project gitlab-org/gitlab
  ```

- 获取作业的日志：

  ```plaintext
  Show me the log output for job 88 in project gitlab-org/gitlab
  ```

<a id="list_pipelines"></a>

## `list_pipelines`

列出极狐GitLab 项目中的流水线，并带有可选筛选器。

| 参数        | 类型    | 是否必需 | 描述 |
|------------------|---------|----------|-------------|
| `id`             | string  | 是      | 项目的 ID 或 URL 编码路径。 |
| `ref`            | string  | 否       | 分支或标签名称。按引用筛选流水线。 |
| `status`         | string  | 否       | 按状态筛选流水线（例如 `running`、`success`、`failed`）。 |
| `source`         | string  | 否       | 按来源筛选流水线（例如 `push`、`web`、`schedule`）。 |
| `created_after`  | string  | 否       | 返回在指定日期时间（ISO 8601 格式）之后创建的流水线。 |
| `created_before` | string  | 否       | 返回在指定日期时间（ISO 8601 格式）之前创建的流水线。 |
| `order_by`       | string  | 否       | 按 `id`、`status`、`ref`、`updated_at` 或 `user_id` 对流水线排序。默认为 `id`。 |
| `sort`           | string  | 否       | 排序方向，`asc` 或 `desc`。默认为 `desc`。 |
| `page`           | integer | 否       | 当前页码。默认为 `1`。 |
| `per_page`       | integer | 否       | 每页的条目数量。默认为 `20`。 |

默认情况下，子流水线会从结果中排除。要仅返回子流水线，请将 `source` 设置为 `parent_pipeline`。

默认顺序（`id`、`desc`）首先返回 ID 最高的流水线。ID 顺序通常与创建顺序一致，但不能保证两者一致。请使用 `created_after` 或 `created_before` 按明确的时间边界筛选。调用方可以逐页浏览结果，并在其目标范围之外的第一条流水线处停止。

示例：

```plaintext
List all failed pipelines on the main branch for project gitlab-org/gitlab
```

<a id="save_pipeline"></a>

## `save_pipeline`

在极狐GitLab 项目中运行、重试、取消或重命名 CI/CD 流水线。要删除流水线，请改用 `manage_pipeline` 工具。要列出流水线，请改用 `list_pipelines` 工具。

| 参数     | 类型    | 是否必需    | 描述 |
|---------------|---------|-------------|-------------|
| `url`         | string  | 否          | 项目的极狐GitLab URL。仅用于创建流水线。提供此项，或提供 `project_id`。 |
| `project_id`  | string  | 否          | 项目的 ID 或完整路径。仅用于创建流水线。提供此项，或提供 `url`。 |
| `pipeline_id` | integer | 否          | 要定位的现有流水线的 ID。设置后，需要 `action`。省略以创建新的流水线。 |
| `action`      | string  | 否          | 要对 `pipeline_id` 执行的生命周期操作：`retry`、`cancel` 或 `update`。设置 `pipeline_id` 时为必需。 |
| `ref`         | string  | 否          | 分支或标签名称。创建流水线时为必需（当 `pipeline_id` 不存在时）。 |
| `name`        | string  | 否          | 新的流水线名称。对于 `action: "update"` 为必需。 |
| `variables`   | array   | 否          | 数组格式的流水线变量（`[{key, value, variable_type}]`）。 |
| `inputs`      | hash    | 否          | 作为键值对的流水线输入参数。 |

示例：

- 创建流水线：

  ```plaintext
  Create a pipeline on the main branch for project gitlab-org/gitlab
  ```

- 重试流水线：

  ```plaintext
  Retry failed jobs in pipeline 12345 for project gitlab-org/gitlab
  ```

- 取消流水线：

  ```plaintext
  Cancel pipeline 12345 in project gitlab-org/gitlab
  ```

- 重命名流水线：

  ```plaintext
  Rename pipeline 12345 to "Nightly security scan" in project gitlab-org/gitlab
  ```

<a id="manage_pipeline"></a>

## `manage_pipeline`

更新流水线元数据或删除极狐GitLab 项目中的流水线。要创建、重试或取消流水线，请改用 `save_pipeline` 工具。要列出流水线，请改用 `list_pipelines` 工具。

| 参数     | 类型    | 是否必需    | 描述 |
|---------------|---------|-------------|-------------|
| `id`          | string  | 是         | 项目的 ID 或 URL 编码路径。 |
| `pipeline_id` | integer | 是         | 流水线的 ID。如果仅设置此参数，则删除流水线及所有相关数据。 |
| `name`        | string  | 否          | 流水线的名称。如果设置此参数和 `pipeline_id`，则更新流水线元数据。 |

示例：

- 更新流水线：

  ```plaintext
  Rename pipeline 12345 to "My deploy pipeline" in project gitlab-org/gitlab
  ```

- 删除流水线：

  ```plaintext
  Delete pipeline 12345 in project gitlab-org/gitlab
  ```

<a id="get_work_item"></a>

## `get_work_item`

检索单个工作项（议题、史诗、任务、事件、目标或关键结果）及其类型、日期、指派人、标记、里程碑和父项。可选择包含其评论或与之相关的合并请求。工作项类型不支持的小组件会被省略。

| 参数                       | 类型    | 是否必需 | 描述 |
|---------------------------------|---------|----------|-------------|
| `url`                           | string  | 否       | 工作项的极狐GitLab URL（`/-/work_items/`、`/-/issues/` 或 `/-/epics/` URL）。提供此项，或提供 `work_item_iid` 以及 `group_id` 或 `project_id`。 |
| `group_id`                      | string  | 否       | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则为必需。 |
| `project_id`                    | string  | 否       | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则为必需。 |
| `work_item_iid`                 | integer | 否       | 工作项的内部 ID。如果缺少 `url`，则为必需。 |
| `include`                       | array   | 否       | 要返回的关联数据。为 `notes` 或 `related_merge_requests` 之一，每次调用一个方面。 |
| `related_merge_requests_first`  | integer | 否       | 要返回的相关合并请求数量。默认 20，最大 100。 |
| `related_merge_requests_after`  | string  | 否       | 相关合并请求向前分页的光标。 |
| `mr_page_size`                  | integer | 否       | 已弃用：请改用 `related_merge_requests_first`。 |
| `mr_pagination_cursor`          | string  | 否       | 已弃用：请改用 `related_merge_requests_after`。 |

`notes` 方面返回前 100 条评论。要获取完整的评论分页，请使用 `get_workitem_notes`。对于史诗等群组级工作项，`related_merge_requests` 方面为空。

示例：

```plaintext
Get issue 42 in project gitlab-org/gitlab with its related merge requests
```

<a id="get_workitem_notes"></a>

## `get_workitem_notes`

检索特定极狐GitLab 工作项的所有评论。

| 参数       | 类型    | 是否必需 | 描述 |
|-----------------|---------|----------|-------------|
| `url`           | string  | 否       | 工作项的 URL。如果缺少 `group_id` 或 `project_id` 和 `work_item_iid`，则为必需。 |
| `group_id`      | string  | 否       | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则为必需。 |
| `project_id`    | string  | 否       | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则为必需。 |
| `work_item_iid` | integer | 否       | 工作项的内部 ID。如果缺少 `url`，则为必需。 |
| `after`         | string  | 否       | 向前分页的光标。 |
| `before`        | string  | 否       | 向后分页的光标。 |
| `first`         | integer | 否       | 向前分页要返回的评论数量。 |
| `last`          | integer | 否       | 向后分页要返回的评论数量。 |

示例：

```plaintext
Show me all comments on work item 42 in project gitlab-org/gitlab
```

<a id="link_work_items"></a>

## `link_work_items`

使用关系类型将一个工作项链接到一个或多个其他工作项。

| 参数        | 类型             | 是否必需 | 描述 |
|------------------|------------------|----------|-------------|
| `work_items_ids` | array of strings | 是      | 要链接到的工作项的全局 ID（格式为 `gid://gitlab/WorkItem/<id>`）。最多 10 项。 |
| `url`            | string           | 否       | 源工作项的 URL。如果缺少 `group_id` 或 `project_id` 和 `work_item_iid`，则为必需。 |
| `group_id`       | string           | 否       | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则为必需。 |
| `project_id`     | string           | 否       | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则为必需。 |
| `work_item_iid`  | integer          | 否       | 源工作项的内部 ID。如果缺少 `url`，则为必需。 |
| `link_type`      | string           | 否       | 关系类型。为 `relates_to`、`blocks` 或 `blocked_by` 之一。默认为 `relates_to`。`blocks` 和 `blocked_by` 类型需要极狐GitLab 专业版或旗舰版。 |

示例：

```plaintext
Mark work item 42 in project gitlab-org/gitlab as blocked by work item 40
```

<a id="get_saved_view_work_items"></a>

## `get_saved_view_work_items`

从命名空间检索已保存视图及其工作项列表。该工具会将已保存视图中的筛选器和排序顺序应用于返回的工作项。

| 参数       | 类型    | 是否必需 | 描述 |
|-----------------|---------|----------|-------------|
| `saved_view_id` | string  | 是      | 已保存视图的全局 ID（格式为 `gid://gitlab/WorkItems::SavedViews::SavedView/<id>`）。 |
| `url`           | string  | 否       | 命名空间（项目或群组）的 URL。如果缺少 `group_id` 或 `project_id`，则为必需。 |
| `group_id`      | string  | 否       | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则为必需。 |
| `project_id`    | string  | 否       | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则为必需。 |
| `after`         | string  | 否       | 向前分页的光标。 |
| `first`         | integer | 否       | 要返回的工作项数量。最大 100。 |

示例：

```plaintext
Show me the work items in this saved view: <URL>
```

<a id="save_work_item"></a>

## `save_work_item`

创建或更新极狐GitLab 工作项，例如议题、任务或史诗。省略 `work_item_iid` 以创建新工作项。提供 `work_item_iid` 或工作项 URL 以更新现有工作项。仅发送您打算设置的字段，其余字段省略。工具名称 `create_work_item` 和 `update_work_item` 是此工具的别名。

| 参数          | 类型              | 是否必需 | 描述 |
|--------------------|-------------------|----------|-------------|
| `url`              | string            | 否       | 项目、群组或工作项的极狐GitLab URL。请仅提供 `url`、`project_id` 或 `group_id` 之一。 |
| `group_id`         | string            | 否       | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则为必需。 |
| `project_id`       | string            | 否       | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则为必需。 |
| `work_item_iid`    | integer           | 否       | 要更新的工作项的正整数内部 ID。省略以创建新工作项。 |
| `title`            | string            | 否       | 工作项的标题。创建工作项时为必需。 |
| `type_name`        | string            | 否       | 工作项类型名称，例如 `Issue`、`Task` 或 `Epic`。创建工作项时为必需。有效类型取决于命名空间和许可证。 |
| `description`      | string            | 否       | 极狐GitLab 风格 Markdown 格式的描述。最多 1,048,576 个字符。 |
| `assignee_ids`     | array of integers | 否       | 要指派给工作项的用户 ID。最多 100 项。 |
| `label_ids`        | array of strings  | 否       | 标记 ID 或全局 ID。仅创建时使用；更新时请使用 `add_label_ids` 或 `remove_label_ids`。最多 100 项。 |
| `labels`           | array of strings  | 否       | 要设置的标记名称，在项目或群组及其祖先群组中解析。仅创建时使用；更新时请使用 `add_labels` 或 `remove_labels`。最多 100 项。 |
| `add_label_ids`    | array of strings  | 否       | 仅更新时使用。要添加的标记 ID 或全局 ID。最多 100 项。 |
| `add_labels`       | array of strings  | 否       | 仅更新时使用。要添加的标记名称。最多 100 项。 |
| `remove_label_ids` | array of strings  | 否       | 仅更新时使用。要移除的标记 ID 或全局 ID。最多 100 项。 |
| `remove_labels`    | array of strings  | 否       | 仅更新时使用。要移除的标记名称。最多 100 项。 |
| `milestone_id`     | string            | 否       | 要指派的里程碑的 ID 或全局 ID，会针对项目或群组及其祖先群组进行验证。当同时提供 `milestone` 时，此项优先。 |
| `milestone`        | string            | 否       | 要指派的里程碑标题，在项目或群组及其祖先群组的里程碑中解析。 |
| `confidential`     | boolean           | 否       | 设置工作项的机密性。 |
| `start_date`       | string            | 否       | 开始日期，格式为 `YYYY-MM-DD`。 |
| `due_date`         | string            | 否       | 截止日期，格式为 `YYYY-MM-DD`。 |
| `state`            | string            | 否       | 仅更新时使用。`closed` 关闭工作项，`opened` 重新打开它。 |
| `parent_id`        | string            | 否       | 父工作项的全局 ID 或数字 ID。 |
| `todo_action`      | string            | 否       | 仅更新时使用。`add` 为当前用户添加待办事项，`mark_as_done` 将待办事项标记为完成。 |
| `todo_id`          | string            | 否       | 仅更新时使用。待办事项的全局 ID 或数字 ID。省略以更新工作项上的所有待办事项。 |
| `health_status`    | string            | 否       | 健康状态。为 `onTrack`、`needsAttention` 或 `atRisk` 之一。仅限旗舰版。 |
| `weight`           | integer           | 否       | 工作项的权重。必须为 0 或更大。仅限专业版和旗舰版。 |
| `clear_weight`     | boolean           | 否       | 仅更新时使用。移除权重。优先于 `weight`。仅限专业版和旗舰版。 |
| `status_id`        | string            | 否       | 要设置的状态的全局 ID。仅限专业版和旗舰版。 |
| `is_fixed`         | boolean           | 否       | 开始日期和截止日期是否固定。当为 `false` 时，日期从子项汇总，`start_date` 和 `due_date` 会被忽略。仅限专业版和旗舰版。 |
| `agent_plan`       | string            | 否       | Agent 计划的 Markdown 内容。仅限旗舰版。需要 workplan 功能。 |
| `readiness_score`  | integer           | 否       | Agent 计划的就绪度分数，从 0 到 100。仅限旗舰版。需要 workplan 功能。 |

示例：

```plaintext
Create a task "Update the onboarding guide" in project gitlab-org/gitlab and assign it to me
```

<a id="list_work_items"></a>

## `list_work_items`

列出或搜索群组或项目中的工作项（议题、事件、测试用例、需求、任务、工单、目标、关键结果、史诗）。群组范围包括后代项目和子群组的工作项。每个结果仅包含 ID、IID、标题、状态、Web URL、完整引用、创建和更新时间戳以及工作项类型，并带有光标分页。
使用 `get_work_item` 深入读取单个工作项。

| 参数               | 类型    | 是否必需 | 描述 |
|-------------------------|---------|----------|-------------|
| `url`                   | string  | 否       | 项目或群组的极狐GitLab URL。请仅提供 `url`、`group_id` 或 `project_id` 之一。 |
| `group_id`              | string  | 否       | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则为必需。 |
| `project_id`            | string  | 否       | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则为必需。 |
| `state`                 | string  | 否       | 按状态筛选：`opened`、`closed` 或 `all`（默认）。 |
| `search`                | string  | 否       | 在标题和描述中进行自由文本搜索。 |
| `author_username`       | string  | 否       | 作者的用户名。 |
| `assignee_usernames`    | array   | 否       | 指派人的用户名。工作项必须匹配所有用户名。最多 100 个值。 |
| `label_name`            | array   | 否       | 标记名称。工作项必须具有所有标记。最多 100 个值。 |
| `milestone_title`       | array   | 否       | 里程碑标题。不能与 `milestone_wildcard_id` 结合使用。最多 100 个值。 |
| `milestone_wildcard_id` | string  | 否       | `NONE`、`ANY`、`STARTED` 或 `UPCOMING`。不能与 `milestone_title` 结合使用。 |
| `types`                 | array   | 否       | 要包含的工作项类型，例如 `["ISSUE", "TASK"]`。 |
| `created_after`         | string  | 否       | 在此时间之后创建（ISO 8601；仅日期表示当天开始，遵循偏移量）。 |
| `created_before`        | string  | 否       | 在此时间之前创建（ISO 8601；仅日期表示当天开始，遵循偏移量）。 |
| `updated_after`         | string  | 否       | 在此时间之后更新（ISO 8601；仅日期表示当天开始，遵循偏移量）。 |
| `updated_before`        | string  | 否       | 在此时间之前更新（ISO 8601；仅日期表示当天开始，遵循偏移量）。 |
| `due_after`             | string  | 否       | 在此时间之后截止（ISO 8601；仅日期表示当天开始，遵循偏移量）。 |
| `due_before`            | string  | 否       | 在此时间之前截止（ISO 8601；仅日期表示当天开始，遵循偏移量）。 |
| `sort`                  | string  | 否       | 排序顺序，例如 `UPDATED_DESC`。默认 `CREATED_DESC`。 |
| `first`                 | integer | 否       | 要返回的工作项数量。默认 20，最大 100。 |
| `after`                 | string  | 否       | 向前分页的光标。 |
| `health_status_filter`  | string  | 否       | 仅限旗舰版。`onTrack`、`needsAttention` 或 `atRisk`。 |
| `status`                | object  | 否       | 仅限旗舰版。按自定义状态名称筛选，例如 `{"name": "In progress"}`。 |

示例：

```plaintext
List my open tasks in the gitlab-org group updated this month.
```

<a id="search"></a>

## `search`

使用搜索 API 在整个极狐GitLab 实例中搜索检索词。
此工具可用于全局、群组和项目搜索。
可用范围取决于[搜索类型](../search/_index.md)。

| 参数      | 类型             | 是否必需 | 描述 |
|----------------|------------------|----------|-------------|
| `scope`        | string           | 是      | 搜索范围（例如 `work_items`、`merge_requests` 或 `projects`）。 |
| `search`       | string           | 是      | 搜索词。 |
| `group_id`     | string           | 否       | 要搜索的群组的 ID 或 URL 编码路径。 |
| `project_id`   | string           | 否       | 要搜索的项目的 ID 或 URL 编码路径。 |
| `state`        | string           | 否       | 搜索结果的状态（用于 `work_items` 和 `merge_requests`）。 |
| `confidential` | boolean          | 否       | 按机密性筛选结果（用于 `work_items`）。默认为 `false`。 |
| `fields`       | array of strings | 否       | 要搜索的字段数组（用于 `work_items` 和 `merge_requests`）。 |
| `order_by`     | string           | 否       | 结果排序所依据的属性。基础搜索默认为 `created_at`，高级搜索默认为相关性。 |
| `sort`         | string           | 否       | 结果的排序方向。默认为 `desc`。 |
| `per_page`     | integer          | 否       | 每页的结果数量。默认为 `20`。 |
| `page`         | integer          | 否       | 当前页码。默认为 `1`。 |

示例：

```plaintext
Search issues for "flaky test" across GitLab
```

<a id="search_labels"></a>

## `search_labels`

在极狐GitLab 项目或群组中搜索标记。

| 参数    | 类型    | 是否必需 | 描述 |
|--------------|---------|----------|-------------|
| `full_path`  | string  | 是      | 项目或群组的完整路径（例如 `group/project`）。 |
| `is_project` | boolean | 是      | 是在项目中搜索（`true`）还是在群组中搜索（`false`）。 |
| `search`     | string  | 否       | 按标题筛选标记的搜索词。 |

当您搜索群组标记时，结果会包含来自祖先群组和后代群组的标记。

示例：

```plaintext
Show me all labels in project gitlab-org/gitlab
```

<a id="list_wiki_pages"></a>

## `list_wiki_pages`

列出极狐GitLab 项目或群组中的 Wiki 页面。

| 参数    | 类型    | 是否必需 | 描述 |
|--------------|---------|----------|-------------|
| `project_id` | string  | 否       | 项目的完整路径或数字 ID（例如 `gitlab-org/gitlab` 或 `278964`）。 |
| `group_id`   | string  | 否       | 群组的完整路径或数字 ID（例如 `gitlab-org` 或 `9970`）。 |
| `first`      | integer | 否       | 向前分页要返回的 Wiki 页面数量（最大 100）。 |
| `after`      | string  | 否       | 向前分页的光标。 |

仅提供 `project_id` 或 `group_id` 之一。
每次调用返回单页结果。
如果存在更多页面，响应会包含一个 `end_cursor`，您可以将其作为 `after` 传递以获取下一页。

示例：

```plaintext
List the wiki pages in gitlab-org/gitlab
```

<a id="semantic_code_search"></a>

## `semantic_code_search`

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

在极狐GitLab 项目中搜索相关代码片段。
有关更多信息，包括设置和启用方法，请参阅[语义代码搜索](../gitlab_duo/semantic_code_search.md)。

| 参数        | 类型    | 是否必需 | 描述 |
|------------------|---------|----------|-------------|
| `semantic_query` | string  | 是      | 代码的搜索查询。 |
| `project_id`     | string  | 是      | 项目的 ID 或路径。 |
| `directory_path` | string  | 否       | 目录的路径（例如 `app/services/`）。 |
| `knn`            | integer | 否       | 用于查找相似代码片段的最近邻数量。默认为 `64`。 |
| `limit`          | integer | 否       | 要返回的最大结果数量。默认为 `20`。 |

为获得最佳结果，请描述您感兴趣的功能或行为，而不是使用通用关键字或特定的函数或变量名称。

示例：

```plaintext
How are authorizations managed in this project?
```

<a id="attach_scan_profile"></a>

## `attach_scan_profile`

将给定的安全扫描配置文件附加到指定项目，或附加到指定群组下的所有项目。

| 参数                  | 类型             | 是否必需 | 描述 |
|----------------------------|------------------|----------|-------------|
| `security_scan_profile_id` | string           | 是      | 安全扫描配置文件的全局 ID（例如 `gid://gitlab/Security::ScanProfile/1`）。 |
| `project_ids`              | array of strings | 否       | 项目的全局 ID 数组（例如 `[gid://gitlab/Project/1]`）。除非提供 `group_ids`，否则为必需。 |
| `group_ids`                | array of strings | 否       | 群组的全局 ID 数组（例如 `[gid://gitlab/Group/1]`）。除非提供 `project_ids`，否则为必需。 |

示例：

```plaintext
Attach `gid://gitlab/Security::ScanProfile/1` to all projects under `gid://gitlab/Group/1`.
```
