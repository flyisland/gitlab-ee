---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 作业
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 作业不支持排序。

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                           |
| --------- | ------------------------------------- |
| `project` | 查询特定项目中的作业。     |

更多信息，请参见[范围](_index.md#scopes)。

<a id="query-fields"></a>

## 查询字段

使用这些字段在 `query` 参数中筛选结果。

| 字段                                          | 名称                | 运算符  |
| ---------------------------------------------- | ------------------- | ---------- |
| [类型](#job-kind)                              | `kind`              | `=`        |
| [流水线](#job-pipeline)                      | `pipeline`          | `=`        |
| [状态](#job-status)                          | `status`            | `=`        |
| [带产物](#job-with-artifacts)          | `withArtifacts`     | `=`, `!=`  |

### 类型 {#job-kind}

**描述**：按作业类型筛选作业。

**允许的值类型**：

- `Enum`，取值为 `bridge` 或 `build` 之一

**注意**：

- `bridge` 作业是启动下游流水线的触发作业。
- `build` 作业是常规 CI/CD 作业。

### 流水线 {#job-pipeline}

**描述**：按作业所属的流水线筛选作业，使用流水线 IID。

**允许的值类型**：`Number`（流水线 IID）

### 状态 {#job-status}

**描述**：按作业的 CI/CD 状态筛选作业。

**允许的值类型**：

- `Enum`，取值为 `canceled`、`canceling`、`created`、`failed`、`manual`、`pending`、
  `preparing`、`running`、`scheduled`、`skipped`、`success`、`waiting_for_callback`
  或 `waiting_for_resource` 之一

### 带产物 {#job-with-artifacts}

**描述**：按作业是否带产物筛选作业。

**允许的值类型**：`Boolean`（`true` 或 `false`）

<a id="display-fields"></a>

## 显示字段

| 字段                  | 名称（及别名）                   | 描述 |
| ---------------------- | ---------------------------------- | ----------- |
| 活动状态                 | `active`                           | 显示作业是否处于活动状态 |
| 允许失败          | `allowFailure`                     | 显示是否允许作业失败 |
| 浏览产物路径  | `browseArtifactsPath`              | 显示用于浏览作业产物归档的 URL |
| 可运行作业           | `canPlayJob`                       | 显示当前用户是否可以运行该作业 |
| 可取消             | `cancelable`                       | 显示作业是否可以取消 |
| 提交路径            | `commitPath`                       | 显示触发该作业的提交路径 |
| 覆盖率               | `coverage`                         | 显示代码覆盖率百分比 |
| 创建时间             | `created`, `createdAt`             | 显示作业的创建时间 |
| 由标签创建         | `createdByTag`                     | 显示作业是否由标签创建 |
| 时长               | `duration`                         | 显示作业时长 |
| 清除时间              | `erased`, `erasedAt`               | 显示作业产物被清除的时间 |
| 退出码              | `exitCode`                         | 显示作业的退出码 |
| 失败消息        | `failureMessage`                   | 显示失败消息 |
| 完成时间            | `finished`, `finishedAt`           | 显示作业的完成时间 |
| ID                     | `id`                               | 显示作业 ID |
| 类型                   | `kind`                             | 显示作业类型（`bridge` 或 `build`） |
| 手动作业             | `manualJob`                        | 显示这是否是手动作业 |
| 名称                   | `name`                             | 显示作业名称 |
| 流水线               | `pipeline`                         | 显示作业所属的流水线 |
| 运行路径              | `playPath`                         | 显示运行该作业的路径 |
| 可运行               | `playable`                         | 显示作业是否可以运行 |
| 排队时间              | `queued`, `queuedAt`               | 显示作业的排队时间 |
| 排队时长        | `queuedDuration`                   | 显示作业在开始前排队了多长时间 |
| 引用名称               | `refName`                          | 显示 Git 引用名称 |
| 引用路径               | `refPath`                          | 显示触发该作业的引用路径 |
| 已重试                | `retried`                          | 显示作业是否已重试 |
| 重试路径             | `retryPath`                        | 显示重试该作业的路径 |
| 可重试              | `retryable`                        | 显示作业是否可以重试 |
| 已计划              | `scheduled`                        | 显示作业是否已计划 |
| 计划时间           | `scheduledAt`                      | 显示作业计划运行的时间 |
| 计划类型        | `schedulingType`                   | 显示计划类型 |
| 短 SHA              | `shortSha`                         | 显示短提交 SHA |
| 来源                 | `source`                           | 显示作业来源 |
| 阶段                  | `stage`                            | 显示作业所属的流水线阶段 |
| 开始时间             | `started`, `startedAt`             | 显示作业的开始时间 |
| 状态                 | `status`                           | 显示作业状态 |
| 卡住                  | `stuck`                            | 显示作业是否卡住 |
| 标签                   | `tags`                             | 显示 runner 标签 |
| 已触发              | `triggered`                        | 显示作业是否被触发 |
| Web 路径               | `webPath`                          | 显示作业的 Web 路径 |

<a id="examples"></a>

## 示例

- 列出 `gitlab-org/gitlab` 项目中的所有失败作业：

  ````yaml
  ```glql
  display: table
  fields: name, status, stage, startedAt
  query: type = Job and project = "gitlab-org/gitlab" and status = failed
  ```
  ````

- 列出 `gitlab-org/gitlab` 项目中所有带产物的作业：

  ````yaml
  ```glql
  display: table
  fields: name, status, stage
  query: type = Job and project = "gitlab-org/gitlab" and withArtifacts = true
  ```
  ````
