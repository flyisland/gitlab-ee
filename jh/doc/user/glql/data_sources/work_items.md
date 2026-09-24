---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 工作项
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

工作项包括以下类型：
`Issue`、`Incident`、`TestCase`、`Requirement`、`Task`、`Ticket`、`Objective`、`KeyResult` 和 `Epic`。

> [!note]
> 查询史诗仅适用于专业版和旗舰版层级。

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                                      |
| --------- | ------------------------------------------------ |
| `project` | 查询特定项目中的工作项。          |
| `group`   | 查询群组中所有项目（包括子群组）的工作项。 |

有关更多信息，请参阅[范围](_index.md#scopes)。

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                                                          | 名称（和别名）                             | 运算符                  | 类型              |
| -------------------------------------------------------------- | -------------------------------------------- | -------------------------- | ------------------ |
| [指派人](#workitem-assignees)                               | `assignee`, `assignees`                      | `=`, `in`, `!=`            | 全部                |
| [作者](#workitem-author)                                     | `author`                                     | `=`, `in`, `!=`            | 全部                |
| [节奏](#workitem-cadence)                                   | `cadence`                                    | `=`, `in`                  | 除史诗外的全部    |
| [关闭时间](#workitem-closed-at)                               | `closed`, `closedAt`                         | `=`, `>`, `<`, `>=`, `<=`  | 全部                |
| [机密](#workitem-confidential)                         | `confidential`                               | `=`, `!=`                  | 全部                |
| [创建时间](#workitem-created-at)                             | `created`, `createdAt`, `opened`, `openedAt` | `=`, `>`, `<`, `>=`, `<=`  | 全部                |
| [自定义字段](#workitem-custom-field)                         | `customField("Field name")`                  | `=`                        | 全部                |
| [截止日期](#workitem-due-date)                                 | `due`, `dueDate`                             | `=`, `>`, `<`, `>=`, `<=`  | 全部                |
| [史诗](#workitem-epic)                                         | `epic`                                       | `=`, `!=`                  | 除史诗外的全部    |
| [健康状态](#workitem-health-status)                       | `health`, `healthStatus`                     | `=`, `!=`                  | 全部                |
| [ID](#workitem-identifier)                                     | `id`                                         | `=`, `in`                  | 全部                |
| [包含子群组](#workitem-include-subgroups)               | `includeSubgroups`                           | `=`, `!=`                  | 全部                |
| [迭代](#workitem-iteration)                               | `iteration`                                  | `=`, `in`, `!=`            | 除史诗外的全部    |
| [标记](#workitem-labels)                                     | `label`, `labels`                            | `=`, `in`, `!=`            | 全部                |
| [里程碑](#workitem-milestone)                               | `milestone`                                  | `=`, `in`, `!=`            | 全部                |
| [我的表情回应](#workitem-my-reaction-emoji)               | `myReaction`, `myReactionEmoji`              | `=`, `!=`                  | 全部                |
| [父项](#workitem-parent)                                     | `parent`                                     | `=`, `!=`                  | 除史诗外的全部    |
| [状态](#workitem-state)                                       | `state`                                      | `=`                        | 全部                |
| [状态](#workitem-status)                                     | `status`                                     | `=`                        | 除史诗外的全部    |
| [已订阅](#workitem-subscribed)                             | `subscribed`                                 | `=`, `!=`                  | 全部                |
| [更新时间](#workitem-updated-at)                             | `updated`, `updatedAt`                       | `=`, `>`, `<`, `>=`, `<=`  | 全部                |
| [权重](#workitem-weight)                                     | `weight`                                     | `=`, `!=`                  | 除史诗外的全部    |

### 指派人 {#workitem-assignees}

**描述**：按一个或多个被指派到工作项的用户查询工作项。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）
- `List`（包含 `String` 或 `User` 值）
- `Nullable`（`null`、`none` 或 `any` 之一）

### 作者 {#workitem-author}

**描述**：按作者查询工作项。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）
- `List`（包含 `String` 或 `User` 值）

### 节奏 {#workitem-cadence}

**描述**：按工作项迭代所属的[节奏](../../group/iterations/_index.md#iteration-cadences)查询除史诗外的工作项。

**允许的值类型**：

- `Number`（仅正整数）
- `List`（包含 `Number` 值）
- `Nullable`（`none` 或 `any` 之一）

**注意**：

- 由于一个工作项只能有一个迭代，因此 `=` 运算符不能与 `List` 类型一起用于 `cadence` 字段。

### 关闭时间 {#workitem-closed-at}

**描述**：按工作项的关闭日期查询工作项。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 机密 {#workitem-confidential}

**描述**：按工作项对项目成员的可见性查询工作项。

**允许的值类型**：

- `Boolean`（`true` 或 `false` 之一）

**注意**：

- 使用 GLQL 查询的机密工作项仅对有权查看它们的人员可见。

### 创建时间 {#workitem-created-at}

**描述**：按工作项的创建日期查询工作项。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 自定义字段 {#workitem-custom-field}

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

**描述**：按[自定义字段](../../work_items/custom_fields.md)查询工作项。

**允许的值类型**：

- `String`（用于单选自定义字段）
- `List`（包含 `String`，用于多选自定义字段）

**注意**：

- 自定义字段名称和值不区分大小写。

### 截止日期 {#workitem-due-date}

**描述**：按工作项的截止日期查询工作项。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 史诗 {#workitem-epic}

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

**描述**：按父史诗的 ID 或引用查询工作项。

**允许的值类型**：

- `Number`（史诗 ID）
- `String`（包含类似 `&123` 的史诗引用）
- `Epic`（例如，`&123`、`gitlab-org&123`）

### 健康状态 {#workitem-health-status}

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

**描述**：按健康状态查询工作项。

**允许的值类型**：

- `StringEnum`（`"needs attention"`、`"at risk"` 或 `"on track"` 之一）
- `Nullable`（`null`、`none` 或 `any` 之一）

### ID {#workitem-identifier}

**描述**：按 ID 查询工作项。

**允许的值类型**：

- `Number`（仅正整数）
- `List`（包含 `Number` 值）

### 包含子群组 {#workitem-include-subgroups}

**描述**：查询群组整个层级中的工作项。

**允许的值类型**：

- `Boolean`（`true` 或 `false` 之一）

**注意**：

- 此字段只能与 `group` 范围一起使用。
- 此字段的值默认为 `false`。

### 迭代 {#workitem-iteration}

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

**描述**：按关联的[迭代](../../group/iterations/_index.md)查询除史诗外的工作项。

**允许的值类型**：

- `Number`（仅正整数）
- `Iteration`（例如，`*iteration:123456`）
- `List`（包含 `Number` 或 `Iteration` 值）
- `Enum`（仅支持 `current`）
- `Nullable`（`none` 或 `any` 之一）

**注意**：

- 由于一个工作项只能有一个迭代，因此 `=` 运算符不能与 `List` 类型一起用于 `iteration` 字段。

### 标记 {#workitem-labels}

**描述**：按关联的标记查询工作项。

**允许的值类型**：

- `String`
- `Label`（例如，`~bug`、`~"team::planning"`）
- `List`（包含 `String` 或 `Label` 值）
- `Nullable`（`none` 或 `any` 之一）

**注意**：

- 作用域标记或包含空格的标记必须用引号括起来。

### 里程碑 {#workitem-milestone}

**描述**：按关联的里程碑查询工作项。

**允许的值类型**：

- `String`
- `Milestone`（例如，`%Backlog`、`%"Awaiting Further Demand"`）
- `List`（包含 `String` 或 `Milestone` 值）
- `Nullable`（`none` 或 `any` 之一）

**注意**：

- 包含空格的里程碑必须用引号（`"`）括起来。
- 由于一个工作项只能有一个里程碑，因此 `=` 运算符不能与 `List` 类型一起用于 `milestone` 字段。
- `Epic` 类型不支持通配符里程碑筛选，例如 `none` 或 `any`。

### 我的表情回应 {#workitem-my-reaction-emoji}

**描述**：按当前用户对工作项的[表情回应](../../emoji_reactions.md)查询工作项。

**允许的值类型**：`String`

### 父项 {#workitem-parent}

**描述**：按父工作项或父史诗查询除史诗外的工作项。

**允许的值类型**：

- `Number`（父项 ID）
- `String`（包含类似 `#123` 的引用）
- `WorkItem`（例如，`#123`、`gitlab-org/gitlab#123`）
- `Epic`（例如，`&123`、`gitlab-org&123`）

### 状态 {#workitem-state}

**描述**：按状态查询工作项。

**允许的值类型**：

- `Enum`，为 `opened`、`closed` 或 `all` 之一

**注意**：

- `state` 字段不支持 `!=` 运算符。

### 状态 {#workitem-status}

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

**描述**：按状态查询工作项。

**允许的值类型**：`String`

### 已订阅 {#workitem-subscribed}

**描述**：按当前用户是否已[设置通知](../../profile/notifications.md)查询工作项。

**允许的值类型**：`Boolean`

### 更新时间 {#workitem-updated-at}

**描述**：按工作项的最后更新时间查询工作项。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，时间范围按用户时区的 00:00 至 23:59 计算。

### 权重 {#workitem-weight}

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

**描述**：按权重查询除史诗外的工作项。

**允许的值类型**：

- `Number`（仅正整数或 0）
- `Nullable`（`null`、`none` 或 `any` 之一）

**注意**：

- 不能使用比较运算符 `<` 和 `>`。

<a id="display-fields"></a>

## 显示字段

| 字段            | 名称或别名                         | 类型           | 描述 |
| ---------------- | ------------------------------------- | --------------- | ----------- |
| 指派人        | `assignee`, `assignees`               | 全部             | 显示指派给对象的用户 |
| 作者           | `author`                              | 全部             | 显示对象的作者 |
| 关闭时间        | `closed`, `closedAt`                  | 全部             | 显示对象关闭以来的时间 |
| 颜色            | `color`                               | 仅史诗       | 显示与史诗关联的颜色样本 |
| 机密     | `confidential`                        | 全部             | 显示 `Yes` 或 `No`，指示对象是否机密 |
| 创建时间       | `created`, `createdAt`                | 全部             | 显示对象创建以来的时间 |
| 描述      | `description`                         | 全部             | 显示对象的描述 |
| 截止日期         | `due`, `dueDate`                      | 全部             | 显示距离对象到期的剩余时间 |
| 史诗             | `epic`                                | 除史诗外的全部 | 显示指向史诗的链接。适用于专业版和旗舰版层级 |
| 健康状态    | `health`, `healthStatus`              | 全部             | 显示指示健康状态的徽章。适用于旗舰版 |
| ID               | `id`                                  | 全部             | 显示对象的 ID |
| 迭代        | `iteration`                           | 除史诗外的全部 | 显示迭代。适用于专业版和旗舰版层级 |
| 标记           | `label`, `labels`                     | 全部             | 显示标记。可接受参数以筛选特定标记，例如 `labels("workflow::*", "backend")` |
| 最后评论     | `lastComment`                         | 全部             | 显示对对象做出的最后评论 |
| 里程碑        | `milestone`                           | 全部             | 显示与对象关联的里程碑 |
| 父项           | `parent`                              | 全部             | 显示指向父工作项或史诗的链接 |
| 进度         | `progress`                            | 仅目标和关键结果 | 显示工作项的进度百分比（0-100） |
| 项目          | `project`                             | 除史诗外的全部 | 显示工作项所属的项目 |
| 开始日期       | `start`, `startDate`                  | 仅史诗       | 显示史诗的开始日期 |
| 状态            | `state`                               | 全部             | 显示指示状态的徽章。值为 `Open` 或 `Closed` |
| 状态           | `status`                              | 除史诗外的全部 | 显示指示状态的徽章。例如，“待办”或“已完成”。适用于专业版和旗舰版层级 |
| 任务完成状态 | `taskCompletionStatus`          | 全部             | 以分数（已完成/总计）显示任务完成情况 |
| 时间估算    | `timeEstimate`                        | 全部             | 显示工作项的预计时间 |
| 标题            | `title`                               | 全部             | 显示对象的标题 |
| 总耗时 | `totalTimeSpent`                      | 全部             | 显示在工作项上花费的总时间 |
| 类型             | `type`                                | 全部             | 显示工作项类型，例如 `Issue`、`Task` 或 `Objective` |
| 更新时间       | `updated`, `updatedAt`                | 全部             | 显示对象最后更新以来的时间 |
| 权重           | `weight`                              | 除史诗外的全部 | 显示权重。适用于专业版和旗舰版层级 |

<a id="sort-fields"></a>

## 排序字段

| 字段         | 名称（和别名）         | 类型           | 描述                                     |
|---------------|--------------------------|-----------------|------------------------------------------------ |
| 关闭时间     | `closed`, `closedAt`     | 全部             | 按关闭日期排序                             |
| 创建时间       | `created`, `createdAt`   | 全部             | 按创建日期排序                            |
| 截止日期      | `due`, `dueDate`         | 全部             | 按截止日期排序                                |
| 健康状态 | `health`, `healthStatus` | 全部             | 按健康状态排序                           |
| 里程碑     | `milestone`              | 除史诗外的全部 | 按里程碑截止日期排序                      |
| 热度    | `popularity`             | 全部             | 按点赞表情回应数量排序 |
| 开始日期    | `start`, `startDate`     | 仅史诗       | 按开始日期排序                              |
| 标题         | `title`                  | 全部             | 按标题排序                                   |
| 更新时间    | `updated`, `updatedAt`   | 全部             | 按最后更新日期排序                       |
| 权重        | `weight`                 | 除史诗外的全部 | 按权重排序                                  |

<a id="examples"></a>

## 示例

- 列出 `gitlab-org/gitlab` 项目中按标题排序的所有议题：

  ````yaml
  ```glql
  display: table
  fields: state, title, updated
  sort: title asc
  query: project = "gitlab-org/gitlab" and type = Issue
  ```
  ````

- 列出 `gitlab-org` 群组中按开始日期排序（最早的在前）的所有史诗：

  ````yaml
  ```glql
  display: table
  fields: title, state, startDate
  sort: startDate asc
  query: group = "gitlab-org" and type = Epic
  ```
  ````

- 列出 `gitlab-org` 群组中已分配权重并按权重排序（最高的在前）的所有议题：

  ````yaml
  ```glql
  display: table
  fields: title, weight, health
  sort: weight desc
  query: type = Issue and group = "gitlab-org" and weight = any
  ```
  ````

- 列出 `gitlab-org` 群组中截止日期距今天不超过一周并按截止日期排序（最早的在前）的所有议题：

  ````yaml
  ```glql
  display: table
  fields: title, dueDate, assignee
  sort: dueDate asc
  query: type = Issue and group = "gitlab-org" and due >= today() and due <= 1w
  ```
  ````
