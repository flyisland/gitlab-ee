---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.11 中引入。
- 字段 `commit`、`commitPath`、`refPath`、`stages` 和 `user` 在极狐GitLab 18.11 中添加。

{{< /history >}}

> [!note]
> 流水线不支持排序。

## 查询字段

以下字段为必需字段：[项目](#pipeline-project)

| 字段                                          | 名称（及别名）                             | 操作符                  |
| ---------------------------------------------- | -------------------------------------------- | -------------------------- |
| [作者](#pipeline-author)                     | `author`                                     | `=`                        |
| [项目](#pipeline-project)                   | `project`                                    | `=`                        |
| [引用](#pipeline-ref)                           | `ref`                                        | `=`                        |
| [范围](#pipeline-scope)                       | `scope`                                      | `=`                        |
| [SHA](#pipeline-sha)                           | `sha`                                        | `=`                        |
| [来源](#pipeline-source)                     | `source`                                     | `=`                        |
| [状态](#pipeline-status)                     | `status`                                     | `=`                        |
| [更新时间](#pipeline-updated-at)             | `updated`，`updatedAt`                       | `=`，`>`，`<`，`>=`，`<=`  |

### 作者 {#pipeline-author}

**描述**：按触发流水线的用户过滤流水线。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）

### 项目 {#pipeline-project}

**描述**：指定要查询流水线的项目。此字段为**必需**字段。

**允许的值类型**：`String`

### 引用 {#pipeline-ref}

**描述**：按流水线运行的 Git 引用（分支或标签名称）过滤流水线。

**允许的值类型**：`String`

### 范围 {#pipeline-scope}

**描述**：按流水线的范围过滤流水线。

**允许的值类型**：

- `Enum`，可选值包括 `branches`、`tags`、`finished`、`pending` 或 `running`

### SHA {#pipeline-sha}

**描述**：按提交 SHA 过滤流水线。

**允许的值类型**：`String`

### 来源 {#pipeline-source}

**描述**：按触发流水线的来源过滤流水线。

**允许的值类型**：`String`

### 状态 {#pipeline-status}

**描述**：按流水线的 CI/CD 状态过滤流水线。

**允许的值类型**：

- `Enum`，可选值包括 `canceled`、`canceling`、`created`、`failed`、`manual`、`pending`、
  `preparing`、`running`、`scheduled`、`skipped`、`success`、`waiting_for_callback`、
  或 `waiting_for_resource`

### 更新时间 {#pipeline-updated-at}

**描述**：按流水线的最后更新时间过滤流水线。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<符号><数字><单位>`，其中符号为 `+`、`-` 或省略，
  数字为整数，而 `单位` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 操作符，时间范围被视为用户所在时区的 00:00 至 23:59。
- `>=` 和 `<=` 操作符包含所查询的日期，而 `>` 和 `<` 则不包含。

## 显示字段

| 字段              | 名称（及别名）                   | 描述 |
| ------------------ | ---------------------------------- | ----------- |
| 活跃状态             | `active`                           | 显示流水线是否活跃 |
| 可取消             | `cancelable`                       | 显示流水线是否可以取消 |
| 子流水线              | `child`                            | 显示这是否为子流水线 |
| 提交             | `commit`                           | 显示提交详情（ID、短 ID、标题、作者姓名、Web URL） |
| 提交路径        | `commitPath`                       | 显示触发流水线的提交的路径 |
| 提交于       | `committed`，`committedAt`         | 显示提交时间戳 |
| 已完成           | `complete`                         | 显示流水线是否已完成 |
| 计算分钟数    | `computeMinutes`                   | 显示已使用的计算分钟数 |
| 配置来源      | `configSource`                     | 显示流水线配置来源 |
| 覆盖率           | `coverage`                         | 显示代码覆盖率百分比 |
| 创建于         | `created`，`createdAt`             | 显示流水线的创建时间 |
| 持续时间           | `duration`                         | 显示流水线持续时间 |
| 失败作业数  | `failedJobsCount`                  | 显示失败作业的数量 |
| 失败原因     | `failureReason`                    | 显示流水线失败的原因 |
| 完成于        | `finished`，`finishedAt`           | 显示流水线的完成时间 |
| ID                 | `id`                               | 显示流水线 ID |
| IID                | `iid`                              | 显示流水线内部 ID |
| 最新             | `latest`                           | 显示这是否为引用的最新流水线 |
| 名称               | `name`                             | 显示流水线名称 |
| 路径               | `path`                             | 显示流水线路径 |
| 引用                | `ref`                              | 显示 Git 引用（分支或标签） |
| 引用路径           | `refPath`                          | 显示触发流水线的引用的路径 |
| 可重试          | `retryable`                        | 显示流水线是否可以重试 |
| SHA                | `sha`                              | 显示提交 SHA |
| 来源             | `source`                           | 显示触发流水线的来源 |
| 阶段             | `stages`                           | 显示流水线阶段（名称和状态） |
| 开始于         | `started`，`startedAt`             | 显示流水线的开始时间 |
| 状态             | `status`                           | 显示流水线状态 |
| 卡住              | `stuck`                            | 显示流水线是否卡住 |
| 作业总数         | `totalJobs`                        | 显示作业总数 |
| 更新于         | `updated`，`updatedAt`             | 显示流水线的最后更新时间 |
| 用户               | `user`                             | 显示触发流水线的用户 |
| 警告           | `warnings`                         | 显示流水线警告 |
| YAML 错误        | `yamlErrors`                       | 显示流水线是否有 YAML 错误 |
| YAML 错误信息| `yamlErrorMessages`                | 显示 YAML 错误信息 |

## 已知问题

- 大日期范围的查询可能导致超时。

## 示例

- 列出 `gitlab-org/gitlab` 项目中今天失败的所有流水线：

  ````yaml
  ```glql
  display: table
  fields: id，ref，status，startedAt
  query: type = Pipeline and project = "gitlab-org/gitlab" and status = failed and updated = today()
  ```
  ````

- 列出 `gitlab-org/gitlab` 项目中所有 Duo agent 流水线：

  ````yaml
  ```glql
  display: table
  fields: id，ref，status，source，startedAt
  query: type = Pipeline and project = "gitlab-org/gitlab" and source = "duo_workflow"
  ```
  ````