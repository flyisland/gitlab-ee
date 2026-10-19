---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: 监控应用性能并排查性能问题。
ignore_in_report: true
title: 显示可观测性中 CI/CD 流水线的遥测数据
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

启用后，极狐GitLab 可观测性会自动对您的 CI/CD 流水线进行插桩，无需任何代码更改即可洞察流水线性能、作业时长和执行流程。

- 洞察哪些作业拖慢了您的流水线。
- 流水线性能随时间的变化情况。
- 部署过程中的瓶颈。

<a id="enable-pipeline-instrumentation"></a>

## 启用流水线插桩

要启用自动流水线插桩，请将 `GITLAB_OBSERVABILITY_EXPORT` CI/CD 变量添加到您的项目或群组：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**。
1. 配置该变量：
   - **键**：`GITLAB_OBSERVABILITY_EXPORT`
   - **值**：`traces`、`metrics`、`logs`中的一个或多个（多个值以逗号分隔）
   - **类型**：变量
   - **环境范围**：所有（或特定环境）
1. 选择**添加变量**。

<a id="authenticate-exported-data"></a>

## 对导出的数据进行身份验证

默认情况下，极狐GitLab 可观测性 OpenTelemetry 协议（OTLP）端点
接受未经身份验证的遥测数据。您可以要求调用方发送持有者令牌，这样只有持有有效令牌的客户端才能将流水线遥测数据发送到您的实例。

身份验证涉及两个方面：

- 在极狐GitLab 可观测性中，您生成并管理令牌，并按实例开启或关闭
  强制执行。
- 在极狐GitLab 中，您将该令牌存储在 CI/CD 变量中，以便流水线
  导出器随遥测数据一起发送该令牌。

设置 `GITLAB_OBSERVABILITY_TOKEN` CI/CD 变量后，极狐GitLab 会将其值作为 `Authorization: Bearer <token>` 请求头随导出的遥测数据一起发送。未设置该变量时，极狐GitLab 导出数据时不带 `Authorization` 请求头。

> [!note]
> 强制执行只能通过极狐GitLab 可观测性 API 进行。以下
> 示例使用 `curl` 并通过 `SIGNOZ-API-KEY`
> 请求头进行身份验证。要获取 API 密钥，请参阅[访问可观测性 API](api_access.md)。
> 只有具有编辑者角色或管理员访问权限的用户才能管理令牌或
> 更改强制执行设置。请将示例中的 `<api_key>` 和 `<instance_url>`
> 替换为您自己的值。

<a id="generate-a-token-in-gitlab-observability"></a>

### 在极狐GitLab 可观测性中生成令牌

摄取令牌是 `otel-ingest` 服务账号上的 API 密钥。可通过 API 生成一个：

```shell
curl --request POST \
  --header "SIGNOZ-API-KEY: <api_key>" \
  --header "Content-Type: application/json" \
  --data '{"name": "ci-cd-export"}' \
  --url "<instance_url>/api/v1/ingest_auth/tokens"
```

响应中的 `token` 字段包含令牌值。该值仅在创建令牌时返回，因此请立即复制。

您也可以在 UI 中通过 **观测** > **API 密钥** 创建令牌。

建议使用无过期时间的令牌，这也是默认设置。极狐GitLab 可观测性不会在令牌过期前通知您，而过期的令牌将不再被接受，从而悄无声息地中断遥测数据摄取。要更换令牌，请使用轮换而不是设置过期时间。请参阅[轮换令牌](#rotate-a-token)。

暂时保持强制执行处于关闭状态。在启用强制执行之前，先将令牌推广到您的流水线，这样端点就不会开始拒绝未经身份验证的遥测数据。

<a id="set-the-token-in-gitlab"></a>

### 在极狐GitLab 中设置令牌

将令牌添加到运行已插桩流水线的项目或群组：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**。
1. 配置该变量：
   - **键**：`GITLAB_OBSERVABILITY_TOKEN`
   - **值**：您在极狐GitLab 可观测性中生成的令牌。
   - **类型**：变量
   - **标志**：选择**屏蔽变量**，以免令牌在作业日志中暴露。
1. 选择**添加变量**。

<a id="enable-enforcement"></a>

### 启用强制执行

在极狐GitLab 中设置令牌，并且向该实例发送遥测数据的其他所有客户端都已采用该令牌后，通过 API 开启强制执行：

```shell
curl --request PUT \
  --header "SIGNOZ-API-KEY: <api_key>" \
  --header "Content-Type: application/json" \
  --data '{"enabled": true}' \
  --url "<instance_url>/api/v1/ingest_auth/state"
```

要再次关闭强制执行，请向同一端点发送 `{"enabled": false}`。要检查当前状态，请向其发送 `GET` 请求。

该更改无需重启收集器即可生效。强制执行开启后，OTLP 端点会拒绝任何不包含有效令牌的遥测数据。

> [!warning]
> 只有在向该实例发送遥测数据的所有客户端都持有有效令牌后，
> 才能启用强制执行，包括此流水线导出。在客户端采用令牌之前
> 启用强制执行，会导致该客户端的遥测数据被拒绝。

<a id="rotate-a-token"></a>

### 轮换令牌

轮换令牌可以在不中断遥测数据的情况下更换令牌，因为该实例可同时接受多个有效令牌：

1. 按照[在极狐GitLab 可观测性中生成令牌](#generate-a-token-in-gitlab-observability)中所述，
   生成一个新令牌。
1. 将 `GITLAB_OBSERVABILITY_TOKEN` 变量（以及任何其他客户端）更新为
   新的令牌值。只要新旧令牌同时存在，两者都保持有效，因此遥测数据导出不会中断。
1. 撤销旧令牌。列出令牌以找到其 ID，然后将其删除：

   ```shell
   curl --request GET \
     --header "SIGNOZ-API-KEY: <api_key>" \
     --url "<instance_url>/api/v1/ingest_auth/tokens"

   curl --request DELETE \
     --header "SIGNOZ-API-KEY: <api_key>" \
     --url "<instance_url>/api/v1/ingest_auth/tokens/<token_id>"
   ```

> [!note]
> 强制执行开启期间，您无法撤销最后一个仍然有效的令牌。
> 撤销它会导致所有遥测数据被拒绝。请先生成一个替代令牌，或
> 禁用强制执行。

<a id="instrumentation-types"></a>

## 插桩类型

`GITLAB_OBSERVABILITY_EXPORT` 变量接受以下值：

- `traces`：导出分布式追踪数据，显示流水线执行流程、作业依赖关系和耗时
- `metrics`：导出关于流水线时长、作业成功率和资源使用情况的指标
- `logs`：导出流水线执行产生的结构化日志

您可以通过用逗号分隔来启用多种类型：

```plaintext
traces,metrics,logs
```

<a id="exported-data"></a>

## 导出的数据

极狐GitLab 将每种信号类型导出为 OpenTelemetry 协议（OTLP）数据。
每个属性都会同时以旧版 GitLab 命名空间（`pipeline.*`、`job.*`、`gitlab.*`）以及（如果存在）等效的
[OpenTelemetry CI/CD 语义约定](https://opentelemetry.io/docs/specs/semconv/registry/attributes/cicd/)
命名空间（`cicd.*`、`vcs.*`）发出。

<a id="traces"></a>

### 追踪

每个流水线都导出为单个资源 span，其中包含一个流水线 span，以及流水线中每个作业或桥接的一个作业 span。

该资源带有以下属性：

| 属性 | 描述 |
| --- | --- |
| `service.name` | 配置的服务名称，如果未配置则为项目名称。 |
| `service.version` | 静态值 `1.0.0`。 |
| `deployment.environment` | 配置的环境，如果未配置则为 `production`。 |
| `vcs.provider.name` | 静态值 `gitlab`。 |
| `vcs.repository.name` | 项目的名称。 |
| `gitlab.vcs.repository.id` | 项目的 ID。 |
| `vcs.repository.url.full` | 项目的 Web URL。 |
| `vcs.owner.name` | 拥有该项目的命名空间。 |

流水线 span 带有以下属性：

| 属性 | 描述 |
| --- | --- |
| `pipeline.id` | 流水线的 ID。 |
| `pipeline.iid` | 流水线的项目范围内内部 ID（如果可用）。 |
| `pipeline.name` | 流水线的名称。 |
| `pipeline.ref` | 流水线运行所在的分支或标签。 |
| `pipeline.sha` | 流水线运行所针对的提交 SHA。 |
| `pipeline.status` | 流水线状态，例如 `success` 或 `failed`。 |
| `pipeline.detailed_status` | UI 中显示的详细状态文本。 |
| `pipeline.duration` | 流水线时长，以秒为单位。 |
| `pipeline.queued_duration` | 流水线排队所花费的时间，以秒为单位。 |
| `pipeline.protected_ref` | 流水线是否在受保护分支或标签上运行。 |
| `pipeline.url` | 流水线的 URL。 |
| `pipeline.tag` | 流水线是否在标签上运行（如果此信息可用）。 |
| `pipeline.before_sha` | 流水线运行前的提交 SHA（如果可用）。 |
| `pipeline.stages` | 流水线阶段名称的数组（如果可用）。 |
| `pipeline.user.id` | 触发流水线的用户的 ID（如果可用）。 |
| `pipeline.user.username` | 触发流水线的用户的用户名（如果可用）。 |
| `pipeline.commit.id` | 与流水线关联的提交的 SHA（如果可用）。 |
| `pipeline.commit.message` | 与流水线关联的提交的消息（如果可用）。 |
| `pipeline.merge_request.id` | 关联合并请求的 ID（如果流水线是为其运行的）。 |
| `pipeline.merge_request.iid` | 关联合并请求的内部 ID（如果流水线是为其运行的）。 |
| `pipeline.source_pipeline.pipeline_id` | 父流水线的 ID，适用于子流水线或多项目流水线。 |
| `cicd.pipeline.name` | 流水线的名称。 |
| `cicd.pipeline.result` | 流水线结果。请参阅[属性值映射](#attribute-value-mapping)。 |
| `cicd.pipeline.run.id` | 流水线的 ID，以字符串表示。 |
| `cicd.pipeline.run.state` | 流水线运行状态。请参阅[属性值映射](#attribute-value-mapping)。 |
| `cicd.pipeline.run.url.full` | 流水线的 URL。 |
| `vcs.ref.head.name` | 流水线运行所在的分支或标签。 |
| `vcs.ref.head.revision` | 流水线运行所针对的提交 SHA。 |
| `vcs.ref.head.type` | `tag` 或 `branch`。 |
| `vcs.ref.base.revision` | 流水线运行前的提交 SHA（如果可用）。 |
| `vcs.change.id` | 关联合并请求的内部 ID，以字符串表示（如果流水线是为其运行的）。 |
| `vcs.change.title` | 关联合并请求的标题（如果流水线是为其运行的）。 |
| `vcs.change.state` | 关联合并请求的状态。请参阅[属性值映射](#attribute-value-mapping)。 |
| `vcs.ref.base.name` | 关联合并请求的目标分支（如果流水线是为其运行的）。 |
| `gitlab.vcs.ref.head.revision.message` | 与流水线关联的提交的消息（如果可用）。 |
| `gitlab.cicd.pipeline.run.duration` | 流水线时长，以秒为单位。 |
| `gitlab.cicd.pipeline.run.queued_duration` | 流水线排队所花费的时间，以秒为单位。 |
| `gitlab.cicd.pipeline.source_pipeline.id` | 父流水线的 ID，适用于子流水线或多项目流水线。 |
| `gitlab.cicd.pipeline.stages` | 流水线阶段名称的数组（如果可用）。 |
| `gitlab.cicd.pipeline.trigger.type` | 触发流水线的事件，例如 `push` 或 `schedule`。 |
| `gitlab.cicd.pipeline.user.id` | 触发流水线的用户的 ID（如果可用）。 |
| `gitlab.cicd.pipeline.user.username` | 触发流水线的用户的用户名（如果可用）。 |
| `gitlab.vcs.ref.head.protected` | 流水线是否在受保护分支或标签上运行。 |

作业 span 为每个作业或桥接带有以下属性：

| 属性 | 描述 |
| --- | --- |
| `job.id` | 作业的 ID。 |
| `job.name` | 作业的名称。 |
| `job.stage` | 作业所属的阶段。 |
| `job.status` | 作业状态，例如 `success` 或 `failed`。 |
| `job.duration` | 作业时长，以秒为单位。 |
| `job.queued_duration` | 作业排队所花费的时间，以秒为单位。 |
| `job.manual` | 作业是否需要手动操作才能运行。 |
| `job.allow_failure` | 是否允许作业失败而不影响流水线结果。 |
| `job.failure_reason` | 作业失败的原因（如果失败）。 |
| `job.type` | 对于触发下游流水线的作业，该值为 `bridge`。 |
| `job.created_at` | 作业创建的时间，以 Unix 纳秒为单位。 |
| `job.when` | 决定作业是否运行的 `rules` 或 `when` 关键字值（如果可用）。 |
| `job.user.id` | 与作业关联的用户的 ID（如果可用）。 |
| `job.user.username` | 与作业关联的用户的用户名（如果可用）。 |
| `job.artifacts.filename` | 作业产物归档的文件名（如果作业生成了产物）。 |
| `job.artifacts.size` | 作业产物归档的大小，以字节为单位（如果作业生成了产物）。 |
| `job.runner.id` | 运行该作业的 Runner 的 ID（如果该作业有 Runner）。 |
| `job.runner.description` | 运行该作业的 Runner 的描述（如果该作业有 Runner）。 |
| `job.runner.tags` | 运行该作业的 Runner 的标签（如果该作业有 Runner）。 |
| `job.runner.type` | Runner 类型，例如 `instance_type` 或 `project_type`（如果可用）。 |
| `job.runner.active` | Runner 是否处于活动状态（如果可用）。 |
| `job.runner.is_shared` | Runner 是否跨项目共享（如果可用）。 |
| `job.environment.name` | 作业部署到的环境的名称（如果该作业有环境）。 |
| `job.environment.action` | 部署操作，例如 `start` 或 `stop`（如果该作业有环境）。 |
| `job.environment.deployment_tier` | 环境的部署层级（如果可用）。 |
| `cicd.pipeline.task.name` | 作业的名称。 |
| `cicd.pipeline.task.run.id` | 作业的 ID，以字符串表示。 |
| `cicd.pipeline.task.run.result` | 作业结果。请参阅[属性值映射](#attribute-value-mapping)。 |
| `cicd.pipeline.task.run.state` | 作业运行状态。请参阅[属性值映射](#attribute-value-mapping)。 |
| `cicd.pipeline.task.run.url.full` | 作业的 URL。 |
| `cicd.pipeline.task.type` | 作业所属的阶段。 |
| `gitlab.cicd.pipeline.task.allow_failure` | 是否允许作业失败而不影响流水线结果。 |
| `gitlab.cicd.pipeline.task.kind` | 对于触发下游流水线的作业，该值为 `bridge`。 |
| `gitlab.cicd.pipeline.task.run.created_at` | 作业创建的时间，以 Unix 纳秒为单位。 |
| `gitlab.cicd.pipeline.task.run.duration` | 作业时长，以秒为单位。 |
| `gitlab.cicd.pipeline.task.run.failure_reason` | 作业失败的原因（如果失败）。 |
| `gitlab.cicd.pipeline.task.run.queued_duration` | 作业排队所花费的时间，以秒为单位。 |
| `gitlab.cicd.pipeline.task.run.when` | 决定作业是否运行的 `rules` 或 `when` 关键字值（如果可用）。 |
| `gitlab.cicd.pipeline.task.trigger.type` | 触发流水线的事件，例如 `push` 或 `schedule`。 |
| `gitlab.cicd.pipeline.task.artifacts.filename` | 作业产物归档的文件名（如果作业生成了产物）。 |
| `gitlab.cicd.pipeline.task.artifacts.size` | 作业产物归档的大小，以字节为单位（如果作业生成了产物）。 |
| `gitlab.cicd.pipeline.task.environment.action` | 部署操作，例如 `start` 或 `stop`（如果该作业有环境）。 |
| `gitlab.cicd.pipeline.task.environment.deployment_tier` | 环境的部署层级（如果可用）。 |
| `gitlab.cicd.pipeline.task.environment.name` | 作业部署到的环境的名称（如果该作业有环境）。 |
| `gitlab.cicd.pipeline.task.user.id` | 与作业关联的用户的 ID（如果可用）。 |
| `gitlab.cicd.pipeline.task.user.username` | 与作业关联的用户的用户名（如果可用）。 |
| `cicd.worker.id` | 运行该作业的 Runner 的 ID，以字符串表示（如果该作业有 Runner）。 |
| `cicd.worker.name` | 运行该作业的 Runner 的描述（如果该作业有 Runner）。 |
| `cicd.worker.state` | Runner 状态。请参阅[属性值映射](#attribute-value-mapping)。 |
| `gitlab.cicd.runner.is_shared` | Runner 是否跨项目共享（如果可用）。 |
| `gitlab.cicd.worker.tags` | 运行该作业的 Runner 的标签（如果该作业有 Runner）。 |
| `gitlab.cicd.worker.type` | Runner 类型，例如 `instance_type` 或 `project_type`（如果可用）。 |

对于由桥接作业触发的子流水线，极狐GitLab 会将子流水线的追踪数据链接到触发作业的 span。父流水线和子流水线随后会显示为一条连通的追踪数据。

<a id="metrics"></a>

### 指标

极狐GitLab 为每个流水线导出以下指标：

| 指标 | 类型 | 描述 |
| --- | --- | --- |
| `pipeline.duration_seconds` | Gauge | 流水线时长，以秒为单位。仅在流水线有持续时间时发出。 |
| `cicd.pipeline.run.duration` | Histogram | 流水线运行时长，以秒为单位。仅在流水线有持续时间时发出。 |
| `pipeline.status_total` | Counter | 流水线状态变更的次数。 |
| `cicd.pipeline.run.count` | Counter | 流水线运行的次数。 |
| `pipeline.jobs_total` | Gauge | 流水线中的作业数量。 |
| `cicd.pipeline.task.total` | Gauge | 流水线中的作业数量。 |
| `job.duration_seconds` | Histogram | 作业时长，以秒为单位，按阶段分组。仅在流水线有作业时发出。 |
| `cicd.pipeline.task.duration` | Histogram | 作业时长，以秒为单位，按阶段分组。仅在流水线有作业时发出。 |
| `pipeline.queue_duration_seconds` | Gauge | 流水线排队所花费的时间，以秒为单位。仅在流水线曾排队时发出。 |
| `gitlab.cicd.pipeline.run.queued_duration` | Gauge | 流水线排队所花费的时间，以秒为单位。仅在流水线曾排队时发出。 |
| `cicd.pipeline.run.errors` | Counter | 流水线错误的数量。仅在流水线结果为 `failure` 时发出。 |

指标数据点带有诸如 `pipeline.status`、`pipeline.ref`、`cicd.pipeline.name`、`cicd.pipeline.result`、`gitlab.cicd.pipeline.trigger.type` 和 `vcs.ref.head.type` 等属性。`job.duration_seconds` 和 `cicd.pipeline.task.duration` 直方图为每个数据点带有一个 `job.stage` 属性。指标数据的资源还带有一个 `gitlab.cicd.pipeline.trace_id` 属性，以便将指标与流水线的追踪数据关联起来。`cicd.pipeline.run.errors` 数据点带有一个 `error.type` 属性。

<a id="logs"></a>

### 日志

极狐GitLab 为流水线导出一条日志记录，并为每个作业导出一条日志记录。每条日志记录具有以下字段：

| 字段 | 描述 |
| --- | --- |
| `severityNumber` 和 `severityText` | 根据流水线或作业状态映射。请参阅[属性值映射](#attribute-value-mapping)。 |
| `body` | 人类可读的摘要，例如 `Pipeline success: my-pipeline` 或 `Job failed: test-job (test)`。 |
| `log.level` | 与 `severityText` 相同的值。 |
| `log.source` | `pipeline` 或 `job`。 |
| 其余属性 | 与追踪 span 相同的属性族：流水线或作业身份、`cicd.*` 和 `vcs.*` 语义约定属性，以及可用时的 Runner、环境和产物属性。 |

<a id="attribute-value-mapping"></a>

### 属性值映射

极狐GitLab 将其内部状态值映射到 OpenTelemetry
CI/CD 语义约定定义的枚举值。

流水线和作业结果（`cicd.pipeline.result`、`cicd.pipeline.task.run.result`）：

| 极狐GitLab 状态 | OpenTelemetry 结果 |
| --- | --- |
| `success` | `success` |
| `failed` | `failure` |
| `canceled` | `cancellation` |
| `skipped` | `skip` |

流水线和作业运行状态（`cicd.pipeline.run.state`、`cicd.pipeline.task.run.state`）：

| 极狐GitLab 状态 | OpenTelemetry 运行状态 |
| --- | --- |
| `pending` | `pending` |
| `waiting_for_resource` | `pending` |
| `preparing` | `pending` |
| `running` | `executing` |

Runner 状态（`cicd.worker.state`）：

| Runner `active` 属性 | OpenTelemetry 工作进程状态 |
| --- | --- |
| `true` | `available` |
| `false` | `offline` |

<a id="how-it-works"></a>

## 工作原理

设置该变量后，极狐GitLab 会自动：

1. 在每个流水线完成后捕获流水线执行数据
1. 根据您的配置将数据转换为 OpenTelemetry 格式
1. 将遥测数据导出到您的极狐GitLab 可观测性实例
1. 使数据在您的可观测性仪表板中可用

无需更改您的 `.gitlab-ci.yml` 文件。插桩会在后台自动进行。

<a id="view-pipeline-telemetry"></a>

## 查看流水线遥测数据

在启用插桩的情况下运行流水线后：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组或项目。
1. 在左侧边栏中，选择 **观测** > **服务**。
1. 选择您的 `gitlab-ci` 服务，查看流水线执行产生的追踪数据、指标和日志。

来自 [GitLab 可观测性模板](https://gitlab.com/gitlab-org/embody-team/experimental-observability/o11y-templates/)的 CI/CD 仪表板模板为流水线性能分析提供了预构建的可视化。
