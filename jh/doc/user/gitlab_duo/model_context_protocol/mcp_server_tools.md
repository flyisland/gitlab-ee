---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use these tools to interact with GitLab through the GitLab MCP server.
title: 极狐GitLab MCP 服务器工具
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- 状态：测试版

{{< /details >}}

极狐GitLab MCP 服务器提供了一组与您现有极狐GitLab 工作流集成的工具。
您可以使用这些工具直接与极狐GitLab 交互并执行常见的极狐GitLab 操作。

<a id="get_mcp_server_version"></a>

## 获取 MCP 服务器版本

返回极狐GitLab MCP 服务器的当前版本。

示例：

```plaintext
我连接的是哪个版本的极狐GitLab MCP 服务器？
```

<a id="create_issue"></a>

## 创建议题

在极狐GitLab 项目中创建新议题。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `title` | 字符串 | 是 | 议题的标题。 |
| `description` | 字符串 | 否 | 议题的描述。 |
| `assignee_ids` | 整数数组 | 否 | 指派人用户 ID 的数组。 |
| `milestone_id` | 整数 | 否 | 里程碑的 ID。 |
| `labels` | 字符串数组 | 否 | 标签名称的数组。 |
| `confidential` | 布尔值 | 否 | 将议题设置为机密。默认为 `false`。 |
| `epic_id` | 整数 | 否 | 关联史诗的 ID。 |

示例：

```plaintext
在项目 123 中创建一个标题为 "修复登录错误" 的议题，描述为 "用户无法使用包含特殊字符的密码登录"
```

<a id="get_issue"></a>

## 获取议题

检索特定极狐GitLab 议题的详细信息。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `issue_iid` | 整数 | 是 | 议题的内部 ID。 |

示例：

```plaintext
获取项目 123 中议题 42 的详细信息
```

<a id="create_merge_request"></a>

## 创建合并请求

{{< history >}}

- 在极狐GitLab 18.5 中引入。
- `assignee_ids`、`reviewer_ids`、`description`、`labels` 和 `milestone_id` 在极狐GitLab 18.8 中添加。

{{< /history >}}

在极狐GitLab 项目中创建合并请求。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `title` | 字符串 | 是 | 合并请求的标题。 |
| `source_branch` | 字符串 | 是 | 源分支的名称。 |
| `target_branch` | 字符串 | 是 | 目标分支的名称。 |
| `target_project_id` | 整数 | 否 | 目标项目的 ID。 |
| `assignee_ids` | 整数数组 | 否 | 合并请求指派人的 ID 数组。设置为 `0` 或空值以取消分配所有指派人。 |
| `reviewer_ids` | 整数数组 | 否 | 合并请求审核人的 ID 数组。设置为 `0` 或空值以取消分配所有审核人。 |
| `description` | 字符串 | 否 | 合并请求的描述。 |
| `labels` | 字符串数组 | 否 | 标签名称的数组。设置为空字符串以取消分配所有标签。 |
| `milestone_id` | 整数 | 否 | 里程碑的 ID。 |

示例：

```plaintext
在项目 gitlab-org/gitlab 中创建一个标题为 "Bug fix broken specs" 的合并请求，从分支 "fix/specs-broken" 合并到 "master"，并启用压缩合并
```

<a id="get_merge_request"></a>

## 获取合并请求

检索特定极狐GitLab 合并请求的详细信息。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `merge_request_iid` | 整数 | 是 | 合并请求的内部 ID。 |

示例：

```plaintext
获取项目 gitlab-org/gitlab 中合并请求 15 的详细信息
```

<a id="get_merge_request_commits"></a>

## 获取合并请求的提交

检索特定极狐GitLab 合并请求中的提交列表。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `merge_request_iid` | 整数 | 是 | 合并请求的内部 ID。 |
| `per_page` | 整数 | 否 | 每页的提交数量。 |
| `page` | 整数 | 否 | 当前页码。 |

示例：

```plaintext
显示项目 123 中合并请求 42 的所有提交
```

<a id="get_merge_request_diffs"></a>

## 获取合并请求的差异

检索特定极狐GitLab 合并请求的差异。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `merge_request_iid` | 整数 | 是 | 合并请求的内部 ID。 |
| `per_page` | 整数 | 否 | 每页的差异数量。 |
| `page` | 整数 | 否 | 当前页码。 |

示例：

```plaintext
gitlab 项目中合并请求 25 更改了哪些文件？
```

<a id="get_merge_request_pipelines"></a>

## 获取合并请求的流水线

检索特定极狐GitLab 合并请求的流水线。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `merge_request_iid` | 整数 | 是 | 合并请求的内部 ID。 |

示例：

```plaintext
显示项目 gitlab-org/gitlab 中合并请求 42 的所有流水线
```

<a id="get_pipeline_jobs"></a>

## 获取流水线作业

检索特定极狐GitLab CI/CD 流水线的作业。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `pipeline_id` | 整数 | 是 | 流水线的 ID。 |
| `per_page` | 整数 | 否 | 每页的作业数量。 |
| `page` | 整数 | 否 | 当前页码。 |

示例：

```plaintext
显示项目 gitlab-org/gitlab 中流水线 12345 的所有作业
```

<a id="manage_pipeline"></a>

## 管理流水线

{{< history >}}

- 在极狐GitLab 18.10 中引入。

{{< /history >}}

管理极狐GitLab 项目中的 CI/CD 流水线。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 字符串 | 是 | 项目的 ID 或 URL 编码路径。 |
| `list` | 布尔值 | 否 | 如果为 `true`，列出项目中的所有流水线。 |
| `ref` | 字符串 | 否 | 分支或标签名称。如果设置，在分支或标签上创建新流水线。用于筛选列表时可选项。 |
| `pipeline_id` | 整数 | 否 | 流水线的 ID。如果仅设置此参数，删除流水线及其所有相关数据。 |
| `retry` | 布尔值 | 否 | 如果为 `true` 且设置了 `pipeline_id`，重试失败或已取消的流水线作业。 |
| `cancel` | 布尔值 | 否 | 如果为 `true` 且设置了 `pipeline_id`，取消运行中流水线的所有作业。 |
| `name` | 字符串 | 否 | 流水线的名称。如果设置此参数和 `pipeline_id`，更新流水线元数据。 |
| `variables` | 数组 | 否 | 数组格式的流水线变量（`[{key, value, variable_type}]`）。 |
| `inputs` | 哈希 | 否 | 作为键值对的流水线输入参数。 |
| `page` | 整数 | 否 | 当前页码。默认为 `1`。 |
| `per_page` | 整数 | 否 | 每页的项目数量。默认为 `20`。 |

示例：

- 列出流水线：

  ```plaintext
  列出项目 gitlab-org/gitlab 中的所有流水线
  ```

- 创建流水线：

  ```plaintext
  在项目 gitlab-org/gitlab 的主分支上创建流水线
  ```

- 更新流水线：

  ```plaintext
  将项目 gitlab-org/gitlab 中的流水线 12345 重命名为 "我的部署流水线"
  ```

- 重试流水线：

  ```plaintext
  重试项目 gitlab-org/gitlab 中流水线 12345 的失败作业
  ```

- 取消流水线：

  ```plaintext
  取消项目 gitlab-org/gitlab 中的流水线 12345
  ```

- 删除流水线：

  ```plaintext
  删除项目 gitlab-org/gitlab 中的流水线 12345
  ```

<a id="create_workitem_note"></a>

## 创建工作项备注

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

在极狐GitLab 工作项上创建新备注（评论）。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `body` | 字符串 | 是 | 备注的内容。 |
| `url` | 字符串 | 否 | 工作项的 URL。如果缺少 `group_id` 或 `project_id` 和 `work_item_iid`，则必需。 |
| `group_id` | 字符串 | 否 | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则必需。 |
| `project_id` | 字符串 | 否 | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则必需。 |
| `work_item_iid` | 整数 | 否 | 工作项的内部 ID。如果缺少 `url`，则必需。 |
| `internal` | 布尔值 | 否 | 将备注标记为内部备注（仅对具有项目报告者、开发者、维护者或所有者角色的用户可见）。默认为 `false`。 |
| `discussion_id` | 字符串 | 否 | 要回复的讨论的全局 ID（格式为 `gid://gitlab/Discussion/<id>`）。 |

示例：

```plaintext
在项目 gitlab-org/gitlab 的工作项 42 中添加评论 "这看起来不错"
```

<a id="get_workitem_notes"></a>

## 获取工作项备注

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

检索特定极狐GitLab 工作项的所有备注（评论）。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `url` | 字符串 | 否 | 工作项的 URL。如果缺少 `group_id` 或 `project_id` 和 `work_item_iid`，则必需。 |
| `group_id` | 字符串 | 否 | 群组的 ID 或路径。如果缺少 `url` 和 `project_id`，则必需。 |
| `project_id` | 字符串 | 否 | 项目的 ID 或路径。如果缺少 `url` 和 `group_id`，则必需。 |
| `work_item_iid` | 整数 | 否 | 工作项的内部 ID。如果缺少 `url`，则必需。 |
| `after` | 字符串 | 否 | 用于正向分页的游标。 |
| `before` | 字符串 | 否 | 用于反向分页的游标。 |
| `first` | 整数 | 否 | 正向分页时返回的备注数量。 |
| `last` | 整数 | 否 | 反向分页时返回的备注数量。 |

示例：

```plaintext
显示项目 gitlab-org/gitlab 中工作项 42 的所有评论
```

<a id="search"></a>

## 搜索

{{< history >}}

- 在极狐GitLab 18.4 中引入。
- 在极狐GitLab 18.6 中添加了搜索群组和项目以及排序结果的功能。
- 在极狐GitLab 18.8 中从 `gitlab_search` 重命名为 `search`。

{{< /history >}}

使用搜索 API 在整个极狐GitLab 实例中搜索词语。
此工具可用于全局、群组和项目搜索。
可用范围取决于[搜索类型](../../search/_index.md)。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `scope` | 字符串 | 是 | 搜索范围（例如，`issues`、`merge_requests` 或 `projects`）。 |
| `search` | 字符串 | 是 | 搜索词。 |
| `group_id` | 字符串 | 否 | 要搜索的群组的 ID 或 URL 编码路径。 |
| `project_id` | 字符串 | 否 | 要搜索的项目的 ID 或 URL 编码路径。 |
| `state` | 字符串 | 否 | 搜索结果的状态（针对 `issues` 和 `merge_requests`）。 |
| `confidential` | 布尔值 | 否 | 按机密性筛选结果（针对 `issues`）。默认为 `false`。 |
| `fields` | 字符串数组 | 否 | 要搜索的字段数组（针对 `issues` 和 `merge_requests`）。 |
| `order_by` | 字符串 | 否 | 排序结果的属性。基本搜索默认为 `created_at`，高级搜索默认为相关性。 |
| `sort` | 字符串 | 否 | 结果的排序方向。默认为 `desc`。 |
| `per_page` | 整数 | 否 | 每页的结果数量。默认为 `20`。 |
| `page` | 整数 | 否 | 当前页码。默认为 `1`。 |

示例：

```plaintext
在整个极狐GitLab 中搜索议题 "flaky test"
```

<a id="search_labels"></a>

## 搜索标签

{{< history >}}

- 在极狐GitLab 18.9 中引入。

{{< /history >}}

在极狐GitLab 项目或群组中搜索标签。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `full_path` | 字符串 | 是 | 项目或群组的完整路径（例如，`group/project`）。 |
| `is_project` | 布尔值 | 是 | 是否在项目（`true`）或群组（`false`）中搜索。 |
| `search` | 字符串 | 否 | 用于按标题筛选标签的搜索词。 |

当您搜索群组标签时，结果包括来自祖先群组和后代群组的标签。

示例：

```plaintext
显示项目 gitlab-org/gitlab 中的所有标签
```

<a id="semantic_code_search"></a>

## 语义代码搜索

{{< history >}}

- 在极狐GitLab 18.5 中作为实验引入，带有名为 `code_snippet_search_graphqlapi` 的功能标志。默认禁用。
- 在极狐GitLab 18.6 中添加了按项目路径搜索。
- 在极狐GitLab 18.7 中从实验更改为测试版。功能标志 `code_snippet_search_graphqlapi` 已移除。
- 在极狐GitLab 18.7 中添加到极狐GitLab UI，带有名为 `mcp_client` 的功能标志。默认禁用。

{{< /history >}}

在极狐GitLab 项目中搜索相关代码片段。
有关更多信息，包括设置和启用，请参阅[语义代码搜索](../semantic_code_search.md)。

| 参数 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `semantic_query` | 字符串 | 是 | 代码的搜索查询。 |
| `project_id` | 字符串 | 是 | 项目的 ID 或路径。 |
| `directory_path` | 字符串 | 否 | 目录路径（例如，`app/services/`）。 |
| `knn` | 整数 | 否 | 用于查找相似代码片段的最近邻数量。默认为 `64`。 |
| `limit` | 整数 | 否 | 返回结果的最大数量。默认为 `20`。 |

为获得最佳结果，请描述您感兴趣的功能或行为，而不是使用通用关键字或特定的函数或变量名。

示例：

```plaintext
此项目中的授权是如何管理的？
```