---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.11 中引入。
- 字段 `browseArtifactsPath`、`canPlayJob`、`commitPath`、`createdByTag`、`exitCode`、`pipeline`、`playPath`、`queuedDuration`、`refPath`、`retryPath` 和 `scheduledAt` 在 极狐GitLab 18.11 中添加。

{{< /history >}}

> [!note]
> 任务不支持排序。

<a id="query-fields"></a>

## 查询字段

以下字段为必填项：[项目](#job-project)

| 字段                                          | 名称                | 运算符  |
| ---------------------------------------------- | ------------------- | ---------- |
| [类型](#job-kind)                              | `kind`              | `=`        |
| [流水线](#job-pipeline)                      | `pipeline`          | `=`        |
| [项目](#job-project)                        | `project`           | `=`        |
| [状态](#job-status)                          | `status`            | `=`        |
| [包含产物](#job-with-artifacts)          | `withArtifacts`     | `=`, `!=`  |

<a id="kind"></a>

### 类型 {#job-kind}

**描述**：按类型过滤任务。

**允许的值类型**：

- `枚举`，`bridge` 或 `build` 之一

**备注**：

- `bridge` 任务是启动下游流水线的触发任务。
- `build` 任务是常规的 CI/CD 任务。

<a id="pipeline"></a>

### 流水线 {#job-pipeline}

**描述**：按任务所属的流水线过滤，使用流水线 IID。

**允许的值类型**：`数字`（流水线 IID）

<a id="project"></a>

### 项目 {#job-project}

**描述**：指定要从中查询任务的项目。此字段为**必填项**。

**允许的值类型**：`字符串`

<a id="status"></a>

### 状态 {#job-status}

**描述**：按 CI/CD 状态过滤任务。

**允许的值类型**：

- `枚举`，`canceled`、`canceling`、`created`、`failed`、`manual`、`pending`、`preparing`、`running`、`scheduled`、`skipped`、`success`、`waiting_for_callback` 或 `waiting_for_resource` 之一

<a id="with-artifacts"></a>

### 包含产物 {#job-with-artifacts}

**描述**：按任务是否包含产物过滤。

**允许的值类型**：`布尔值`（`true` 或 `false`）

<a id="display-fields"></a>

## 显示字段

| 字段                  | 名称（及别名）                   | 描述 |
| ---------------------- | ---------------------------------- | ----------- |
| Active                 | `active`                           | 显示任务是否活跃 |
| Allow failure          | `allowFailure`                     | 显示任务是否允许失败 |
| Browse artifacts path  | `browseArtifactsPath`              | 显示浏览任务产物存档的 URL |
| Can play job           | `canPlayJob`                       | 显示当前用户是否可以运行该任务 |
| Cancelable             | `cancelable`                       | 显示任务是否可以取消 |
| Commit path            | `commitPath`                       | 显示触发该任务的提交路径 |
| Coverage               | `coverage`                         | 显示代码覆盖率百分比 |
| Created at             | `created`, `createdAt`             | 显示任务的创建时间 |
| Created by tag         | `createdByTag`                     | 显示任务是否由标签创建 |
| Duration               | `duration`                         | 显示任务持续时间 |
| Erased at              | `erased`, `erasedAt`               | 显示任务产物被清除的时间 |
| Exit code              | `exitCode`                         | 显示任务的退出码 |
| Failure message        | `failureMessage`                   | 显示失败消息 |
| Finished at            | `finished`, `finishedAt`           | 显示任务完成时间 |
| ID                     | `id`                               | 显示任务 ID |
| Kind                   | `kind`                             | 显示任务类型（`bridge` 或 `build`） |
| Manual job             | `manualJob`                        | 显示是否为手动任务 |
| Name                   | `name`                             | 显示任务名称 |
| Pipeline               | `pipeline`                         | 显示任务所属的流水线（ID、IID、路径、状态） |
| Play path              | `playPath`                         | 显示运行任务的路径 |
| Playable               | `playable`                         | 显示任务是否可以运行 |
| Queued at              | `queued`, `queuedAt`               | 显示任务进入队列的时间 |
| Queued duration        | `queuedDuration`                   | 显示任务在启动前排队等待的时长 |
| Ref name               | `refName`                          | 显示 Git 引用名称 |
| Ref path               | `refPath`                          | 显示触发该任务的引用路径 |
| Retried                | `retried`                          | 显示任务是否被重试 |
| Retry path             | `retryPath`                        | 显示重试任务的路径 |
| Retryable              | `retryable`                        | 显示任务是否可以重试 |
| Scheduled              | `scheduled`                        | 显示任务是否为计划任务 |
| Scheduled at           | `scheduledAt`                      | 显示任务计划运行的时间 |
| Scheduling type        | `schedulingType`                   | 显示计划类型 |
| Short SHA              | `shortSha`                         | 显示短提交 SHA |
| Source                 | `source`                           | 显示任务来源 |
| Stage                  | `stage`                            | 显示任务所属的流水线阶段 |
| Started at             | `started`, `startedAt`             | 显示任务开始时间 |
| Status                 | `status`                           | 显示任务状态 |
| Stuck                  | `stuck`                            | 显示任务是否卡住 |
| Tags                   | `tags`                             | 显示 Runner 标签 |
| Triggered              | `triggered`                        | 显示任务是否被触发 |
| Web path               | `webPath`                          | 显示任务的 Web 路径 |

<a id="examples"></a>

## 示例

- 列出 `gitlab-org/gitlab` 项目中所有失败的任务：

  ````yaml
  ```glql
  display: table
  fields: name, status, stage, startedAt
  query: type = Job and project = "gitlab-org/gitlab" and status = failed
  ```
  ````

- 列出 `gitlab-org/gitlab` 项目中所有包含产物的任务：

  ````yaml
  ```glql
  display: table
  fields: name, status, stage
  query: type = Job and project = "gitlab-org/gitlab" and withArtifacts = true
  ```
  ````