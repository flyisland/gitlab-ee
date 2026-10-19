---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合并请求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="allowed-modes"></a>

## 允许的模式

- 标准模式（默认）：查询合并请求记录。
- 分析模式：查询聚合的合并请求指标。有关更多信息，请参阅[合并请求分析](merge_request_analytics.md)。

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                                           |
| --------- | ----------------------------------------------------- |
| `project` | 查询特定项目中的合并请求。           |
| `group`   | 查询群组中所有项目（包括子群组）的合并请求。 |

有关更多信息，请参阅[范围](_index.md#scopes)。

<a id="query-fields"></a>

## 查询字段

使用 `query` 参数中的这些字段来筛选结果。

| 字段                                                    | 名称（和别名）                             | 运算符                  |
| -------------------------------------------------------- | -------------------------------------------- | -------------------------- |
| [批准用户](#mr-approved-by-user)                 | `approver`, `approvedBy`, `approvers`        | `=`, `!=`                  |
| [指派人](#mr-assignees)                               | `assignee`, `assignees`                      | `=`, `!=`                  |
| [作者](#mr-author)                                     | `author`                                     | `=`, `!=`                  |
| [关闭时间](#mr-closed-at)                               | `closed`, `closedAt`                         | `=`, `>`, `<`, `>=`, `<=`  |
| [创建时间](#mr-created-at)                             | `created`, `createdAt`, `opened`, `openedAt` | `=`, `>`, `<`, `>=`, `<=`  |
| [草稿](#mr-draft)                                       | `draft`                                      | `=`, `!=`                  |
| [环境](#mr-environment)                           | `environment`                                | `=`                        |
| [ID](#mr-identifier)                                     | `id`                                         | `=`, `in`                  |
| [包含子群组](#mr-include-subgroups)               | `includeSubgroups`                            | `=`, `!=`                  |
| [标记](#mr-labels)                                     | `label`, `labels`                            | `=`, `!=`                  |
| [合并时间](#mr-merged-at)                               | `merged`, `mergedAt`                         | `=`, `>`, `<`, `>=`, `<=`  |
| [合并用户](#mr-merged-by-user)                     | `merger`, `mergedBy`                         | `=`                        |
| [里程碑](#mr-milestone)                               | `milestone`                                  | `=`, `!=`                  |
| [我的表情回应](#mr-my-reaction-emoji)               | `myReaction`, `myReactionEmoji`              | `=`, `!=`                  |
| [审核人](#mr-reviewers)                               | `reviewer`, `reviewers`, `reviewedBy`        | `=`, `!=`                  |
| [源分支](#mr-source-branch)                       | `sourceBranch`                               | `=`, `in`, `!=`            |
| [状态](#mr-state)                                       | `state`                                      | `=`                        |
| [已订阅](#mr-subscribed)                             | `subscribed`                                 | `=`, `!=`                  |
| [目标分支](#mr-target-branch)                       | `targetBranch`                               | `=`, `in`, `!=`            |
| [部署时间](#mr-deployed-at)                           | `deployed`, `deployedAt`                     | `=`, `>`, `<`, `>=`, `<=`  |
| [更新时间](#mr-updated-at)                             | `updated`, `updatedAt`                       | `=`, `>`, `<`, `>=`, `<=`  |

### 批准用户 {#mr-approved-by-user}

**描述**：按一个或多个批准了该合并请求的用户查询合并请求。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）
- `List`（包含 `String` 或 `User` 值）
- `Nullable`（`null`、`none` 或 `any` 之一）

### 指派人 {#mr-assignees}

**描述**：按一个或多个被指派到合并请求的用户查询合并请求。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）
- `Nullable`（`null`、`none` 或 `any` 之一）

**说明**：

- 合并请求不支持 `List` 值和 `in` 运算符。

### 作者 {#mr-author}

**描述**：按作者查询合并请求。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）

**说明**：

- 合并请求不支持 `in` 运算符。

### 关闭时间 {#mr-closed-at}

**描述**：按合并请求的关闭日期查询合并请求。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**说明**：

- 对于 `=` 运算符，时间范围按用户所在时区的 00:00 至 23:59 计算。

### 创建时间 {#mr-created-at}

**描述**：按合并请求的创建日期查询合并请求。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**说明**：

- 对于 `=` 运算符，时间范围按用户所在时区的 00:00 至 23:59 计算。

### 草稿 {#mr-draft}

**描述**：按合并请求的草稿状态查询合并请求。

**允许的值类型**：

- `Boolean`（`true` 或 `false` 之一）

### 部署时间 {#mr-deployed-at}

**描述**：按合并请求的部署日期查询合并请求。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**说明**：

- 对于 `=` 运算符，时间范围按用户所在时区的 00:00 至 23:59 计算。

### 环境 {#mr-environment}

**描述**：按合并请求部署到的环境查询合并请求。

**允许的值类型**：`String`

### ID {#mr-identifier}

**描述**：按 ID 查询合并请求。

**允许的值类型**：

- `Number`（仅限正整数）
- `List`（包含 `Number` 值）

### 包含子群组 {#mr-include-subgroups}

**描述**：查询群组整个层级中的合并请求。

**允许的值类型**：

- `Boolean`（`true` 或 `false` 之一）

**说明**：

- 此字段只能与 `group` 范围一起使用。
- 此字段的值默认为 `false`。

### 标记 {#mr-labels}

**描述**：按关联的标记查询合并请求。

**允许的值类型**：

- `String`
- `Label`（例如，`~bug`、`~"team::planning"`）
- `Nullable`（`none` 或 `any` 之一）

**说明**：

- 合并请求不支持 `in` 运算符。
- 作用域标记或包含空格的标记必须用引号括起来。

### 合并时间 {#mr-merged-at}

**描述**：按合并请求的合并日期查询合并请求。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**说明**：

- 对于 `=` 运算符，时间范围按用户所在时区的 00:00 至 23:59 计算。

### 合并用户 {#mr-merged-by-user}

**描述**：按合并该合并请求的用户查询合并请求。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）

### 里程碑 {#mr-milestone}

**描述**：按关联的里程碑查询合并请求。

**允许的值类型**：

- `String`
- `Milestone`（例如，`%Backlog`、`%"Awaiting Further Demand"`）
- `Nullable`（`none` 或 `any` 之一）

**说明**：

- 合并请求不支持 `in` 运算符。
- 包含空格的里程碑必须用引号（`"`）括起来。

### 我的表情回应 {#mr-my-reaction-emoji}

**描述**：按当前用户对合并请求的[表情回应](../../emoji_reactions.md)查询合并请求。

**允许的值类型**：`String`

### 审核人 {#mr-reviewers}

**描述**：查询由一个或多个用户审核过的合并请求。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）
- `Nullable`（`null`、`none` 或 `any` 之一）

### 源分支 {#mr-source-branch}

**描述**：按源分支查询合并请求。

**允许的值类型**：`String`、`List`

**说明**：

- `List` 值仅支持 `in` 和 `!=` 运算符。

### 状态 {#mr-state}

**描述**：按状态查询合并请求。

**允许的值类型**：

- `Enum`，为 `opened`、`closed`、`merged` 或 `all` 之一

**说明**：

- `state` 字段不支持 `!=` 运算符。

### 已订阅 {#mr-subscribed}

**描述**：按当前用户是否已[设置通知](../../profile/notifications.md)来查询合并请求。

**允许的值类型**：`Boolean`

### 目标分支 {#mr-target-branch}

**描述**：按目标分支查询合并请求。

**允许的值类型**：`String`、`List`

**说明**：

- `List` 值仅支持 `in` 和 `!=` 运算符。

### 更新时间 {#mr-updated-at}

**描述**：按合并请求的最后更新时间查询合并请求。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**说明**：

- 对于 `=` 运算符，时间范围按用户所在时区的 00:00 至 23:59 计算。

<a id="display-fields"></a>

## 显示字段

| 字段            | 名称或别名                         | 描述 |
| ---------------- | ------------------------------------- | ----------- |
| 已批准         | `approved`                            | 显示 `Yes` 或 `No`，指示该合并请求是否已获批准 |
| 批准用户 | `approver`, `approvers`, `approvedBy` | 显示批准该合并请求的用户 |
| 指派人        | `assignee`, `assignees`               | 显示被指派到该合并请求的用户 |
| 作者           | `author`                              | 显示该合并请求的作者 |
| 关闭时间        | `closed`, `closedAt`                  | 显示该合并请求关闭以来的时间 |
| 创建时间       | `created`, `createdAt`                | 显示该合并请求创建以来的时间 |
| 描述      | `description`                         | 显示该合并请求的描述 |
| 草稿            | `draft`                               | 显示 `Yes` 或 `No`，指示该合并请求是否处于草稿状态 |
| ID               | `id`                                  | 显示该合并请求的 ID |
| 标记           | `label`, `labels`                     | 显示与该合并请求关联的标记 |
| 最后评论     | `lastComment`                         | 显示对该合并请求的最后一条评论 |
| 合并时间        | `merged`, `mergedAt`                  | 显示该合并请求合并以来的时间 |
| 合并用户   | `merger`, `mergedBy`                  | 显示合并该合并请求的用户 |
| 里程碑        | `milestone`                           | 显示与该合并请求关联的里程碑 |
| 项目          | `project`                             | 显示该合并请求所属的项目 |
| 审核人        | `reviewer`, `reviewers`               | 显示被指派审核该合并请求的用户 |
| 源分支    | `sourceBranch`                        | 显示该合并请求的源分支 |
| 源项目   | `sourceProject`                       | 显示该合并请求的源项目 |
| 状态            | `state`                               | 显示指示状态的徽章。值为 `Open`、`Closed` 或 `Merged` |
| 已订阅       | `subscribed`                          | 显示 `Yes` 或 `No`，指示当前用户是否已订阅 |
| 目标分支    | `targetBranch`                        | 显示该合并请求的目标分支 |
| 目标项目   | `targetProject`                       | 显示该合并请求的目标项目 |
| 时间估算    | `timeEstimate`                        | 显示该合并请求的估算时间 |
| 标题            | `title`                               | 显示该合并请求的标题 |
| 总耗时 | `totalTimeSpent`                      | 显示在该合并请求上花费的总时间 |
| 更新时间       | `updated`, `updatedAt`                | 显示该合并请求上次更新以来的时间 |

<a id="sort-fields"></a>

## 排序字段

| 字段         | 名称（和别名）       | 描述                                     |
|---------------|------------------------|-------------------------------------------------|
| 关闭时间     | `closed`, `closedAt`   | 按关闭日期排序                             |
| 创建时间       | `created`, `createdAt` | 按创建日期排序                            |
| 合并时间     | `merged`, `mergedAt`   | 按合并日期排序                              |
| 里程碑     | `milestone`            | 按里程碑到期日排序                      |
| 热度    | `popularity`           | 按点赞表情回应数量排序 |
| 标题         | `title`                | 按标题排序                                   |
| 更新时间    | `updated`, `updatedAt` | 按最后更新日期排序                       |

<a id="examples"></a>

## 示例

- 列出 `gitlab-org` 群组中由我创建的所有合并请求，并按合并日期排序（最新的在前）：

  ````yaml
  ```glql
  display: table
  fields: title, reviewer, merged
  sort: merged desc
  query: group = "gitlab-org" and type = MergeRequest and state = merged and author = currentUser()
  limit: 10
  ```
  ````
