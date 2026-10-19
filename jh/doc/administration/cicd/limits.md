---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为实例上的流水线、作业、计划和产物配置 CI/CD 限制，以控制资源使用。
title: CI/CD 限制
---

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以通过[管理区域](../admin_area.md)管理许多与 CI/CD 相关的实例限制。其他限制只能通过 GitLab Rails 控制台修改实例配置来更改。

JihuLab.com 的值可能与极狐GitLab 私有化部署的默认值不同。
请查看 [JihuLab.com 的 CI/CD 限制和设置](../../user/jihulab_com/_index.md#gitlab-cicd)。

<a id="instance-cicd-variable-limit"></a>

## 实例 CI/CD 变量限制

可在实例设置中定义的 [CI/CD 变量](../../ci/variables/_index.md)数量是有限的。每次创建新变量时都会检查此限制。如果新变量会导致变量总数超过限制，则不会创建该新变量。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**可定义的实例级 CI/CD 变量最大数量**设置一个值。
   默认值为 `25`。
1. 选择**保存更改**。

<a id="limit-dotenv-file-size"></a>

## 限制 dotenv 文件大小

您可以设置 dotenv 产物的最大大小限制。每次将 dotenv 文件导出为产物时都会检查此限制。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为 **dotenv 产物的最大大小（字节）**设置一个值。
1. 选择**保存更改**。

将该限制设置为 `0` 可禁用它。默认为 5 KB。

<a id="limit-dotenv-variables"></a>

## 限制 dotenv 变量

您可以设置 dotenv 产物中变量的最大数量限制。每次将 dotenv 文件导出为产物时都会检查此限制。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为 **dotenv 产物中的变量最大数量**设置一个值。
1. 选择**保存更改**。

将该限制设置为 `0` 可禁用它。默认为 `20`。

您也可以使用[计划限制 API](../../api/plan_limits.md) 设置此限制。

<a id="limit-cyclonedx-artifact-size"></a>

## 限制 CycloneDX 产物大小

您可以设置 [CycloneDX SBOM](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 产物的最大大小限制。每次将 CycloneDX 报告作为产物上传时都会检查此限制。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为 **CycloneDX 产物的最大大小（MB）**设置一个值。
1. 选择**保存更改**。

将该限制设置为 `0` 可改为使用[最大产物大小](#maximum-artifacts-size)。默认为 `1` MB。

<a id="maximum-number-of-jobs-in-a-pipeline"></a>

## 单个流水线中的最大作业数量

您可以限制流水线中的最大作业数量。流水线中的作业数量在创建流水线时以及创建新提交状态时进行检查。作业过多的流水线会失败，并显示 `size_limit_exceeded` 错误。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**单个流水线中的最大作业数量**设置一个值。
1. 选择**保存更改**。

将该限制设置为 `0` 可禁用它。默认禁用。

<a id="number-of-jobs-in-active-pipelines"></a>

## 活动流水线中的作业数量

每个项目的活动流水线中的作业总数可以受到限制。每次创建新流水线时都会检查此限制。活动流水线是指处于以下任一状态的流水线：

- `created`
- `pending`
- `running`

如果新流水线会导致作业总数超过限制，则该流水线会失败，并显示 `job_activity_limit_exceeded` 错误。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**当前活动流水线中的作业总数**设置一个值。
1. 选择**保存更改**。

将该限制设置为 `0` 可禁用它。默认禁用。

<a id="number-of-cicd-subscriptions-to-a-project"></a>

## 项目的 CI/CD 订阅数量

每个项目的订阅总数可以受到限制。每次创建新订阅时都会检查此限制。

如果新订阅会导致订阅总数超过限制，则该订阅被视为无效。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**项目接收和发出的流水线订阅最大数量**设置一个值。
1. 选择**保存更改**。

默认情况下，订阅数量限制为 `2`。将该限制设置为 `0` 可禁用它。

<a id="number-of-pipeline-schedules"></a>

## 流水线计划数量

每个项目的流水线计划总数可以受到限制。每次创建新流水线计划时都会检查此限制。如果新流水线计划会导致流水线计划总数超过限制，则不会创建该流水线计划。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**流水线计划最大数量**设置一个值。
1. 选择**保存更改**。

默认情况下，流水线计划数量限制为 `10`。

您也可以使用[计划限制 API](../../api/plan_limits.md)。

<a id="maximum-number-of-needs-dependencies"></a>

## needs 依赖的最大数量

您可以设置单个作业可以拥有的 needs 依赖的最大数量。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**作业可以拥有的 needs 依赖最大数量**设置一个值。
1. 选择**保存更改**。

此限制无法禁用。默认为 `50`。

设置为 `0` 可阻止所有 needs 依赖。配置为使用 `needs`的作业的流水线随后会返回错误 `job can only need 0 others`。

<a id="number-of-registered-runners-for-groups-and-projects"></a>

## 群组和项目的已注册 runner 数量

群组和项目的已注册 runner 总数是有限的。每次注册新 runner 时，极狐GitLab 都会根据过去 7 天内创建或活跃的 runner 检查这些限制。如果 runner 超过由 runner 注册令牌确定的范围的限制，则其注册会失败。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为以下任一项设置一个值：
   - **过去七天内群组中创建或活跃的 runner 最大数量**
   - **过去七天内项目中创建或活跃的 runner 最大数量**
1. 选择**保存更改**。

将该限制设置为 `0` 可禁用它。

<a id="limit-pipeline-hierarchy-size"></a>

## 限制流水线层级大小

默认情况下，[流水线层级](../../ci/pipelines/downstream_pipelines.md)最多可以包含 1000 个下游流水线。超过此限制时，流水线创建会失败，并显示错误 `downstream pipeline tree is too large`。

> [!warning]
> 不建议提高此限制。默认限制可保护您的极狐GitLab 实例免受过度的资源消耗、
> 潜在的流水线递归和数据库过载的影响。
>
> 与其提高限制，不如通过将大型流水线层级拆分为较小的流水线来重构您的 CI/CD 配置。
> 可以考虑在单个流水线中的作业或依赖阶段之间使用 `needs`。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**流水线层级树中的下游流水线最大数量**设置一个值。
1. 选择**保存更改**。

您也可以使用[计划限制 API](../../api/plan_limits.md)。

<a id="merge-train-parallel-pipeline-limit"></a>

## 合并列车并行流水线限制

默认情况下，每个[合并列车](../../ci/pipelines/merge_trains.md)最多可以并行运行 20 个流水线。达到此限制时，其他合并请求会排队，直到有可用的流水线槽位。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在 **CI/CD 限制**下，为**每个合并列车的最大并行流水线数**设置一个值。
   最小值为 `1`。值为 `1` 时会按顺序处理合并请求，没有并行。
1. 选择**保存更改**。

您也可以使用[计划限制 API](../../api/plan_limits.md)。

您可以为[特定项目](../../ci/pipelines/merge_trains.md#merge-train-parallel-pipeline-limit)设置不同的值。

<a id="maximum-time-jobs-can-run"></a>

## 作业可以运行的最长时间

作业可以运行的默认最长时间为 60 分钟。运行时间超过 60 分钟的作业会超时。

您可以更改作业在超时前可以运行的最长时间：

- 对于项目，在[项目的 CI/CD 设置](../../ci/pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)中
  为给定项目设置。此限制必须介于 10 分钟和 1 个月之间。
- [对于 runner](../../ci/runners/configure_runners.md#set-the-maximum-job-timeout)。
  此限制必须为 10 分钟或更长。

无论配置的超时限制如何，极狐GitLab 都会终止任何已 60 分钟无活动的作业。无活动的作业是指未产生新日志或跟踪更新的作业。

<a id="number-of-pipelines-per-git-push"></a>

## 每次 Git 推送的流水线数量

> [!warning]
> 不建议提高此限制。如果同时推送许多更改，可能会给您的极狐GitLab 实例带来过大的负载，可能造成大量流水线。

使用单次 Git 推送推送多个更改（例如多个标签或分支）时，默认情况下只能触发四个标签或分支流水线。此限制可防止在使用 `git push --all` 或 `git push --mirror` 时意外创建大量流水线。

[合并请求流水线](../../ci/pipelines/merge_request_pipelines.md)是受限的。如果 Git 推送同时更新多个合并请求，则在达到限制之前，每个更新的合并请求都可以触发一个合并请求流水线。

对于极狐GitLab 私有化部署和 JihuLab.com，默认值为 `4`。

要在您的极狐GitLab 私有化部署实例上更改此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 更改**每次 Git 推送的流水线限制**的值。
1. 选择**保存更改**。

<a id="pipeline-creation-rate-limits"></a>

## 流水线创建速率限制

您可以设置限制，使用户和进程每分钟不能请求超过一定数量的流水线。这些限制有助于节省资源并提高稳定性。每个限制在一分钟后重置。

极狐GitLab 在本节中强制执行以下速率限制：

- **按项目、提交和用户**：限制同一项目、
  提交 SHA 和用户组合下创建的流水线。默认设置为 `0`（无限制）。
- **按用户**：限制用户在所有项目中创建的流水线总数。默认设置为 `0`（无限制）。
- **按用户的 CI lint 请求**：限制用户跨所有项目发起的 [CI lint](../../ci/yaml/lint.md) 请求。
  CI lint 请求类似于流水线创建请求。

默认情况下，`ci_lint_limit_per_user` 设置为 `0`（无限制）。升级到极狐GitLab 19.5 会在每个实例上将此值重置为 `0`，即使管理员之前设置过限制也是如此。如果您想限制 CI lint 请求，请在升级后重新设置该值。

例如，如果您设置每用户限制为 `100`，而某用户在一分钟内跨不同项目向[触发器 API](../../ci/triggers/_index.md) 发送了 `101` 个流水线创建请求，则第 101 个请求会被阻止。一分钟后，将再次允许访问该端点。

这些限制不按 IP 地址应用。

超过限制的请求会记录在 `application_json.log` 文件中。

> [!flag]
> 只有在启用 `ci_enforce_ci_lint_rate_limit` 功能标志时，才会强制执行 `ci_lint_limit_per_user` 限制。
> 在该标志启用之前，超过限制的请求会被记录，但不会被阻止。

<a id="set-pipeline-request-limits"></a>

### 设置流水线请求限制

先决条件：

- 管理员访问权限。

要限制流水线请求数量：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**流水线创建速率限制**。
   - 在**每个项目、用户和提交每分钟的最大请求数**下，输入大于 `0`的值，以限制同一项目、
     提交和用户组合的流水线。设置为 `0` 表示每分钟请求数不受限制。
   - 在**每个用户每分钟的最大请求数**下，输入大于 `0`的值，以限制每个用户创建的流水线总数。
     设置为 `0` 表示每分钟请求数不受限制。
   - 在**用户的最大 CI Lint 请求数**下，输入大于 `0`的值，以限制每个用户
     发起的 CI lint 请求。设置为 `0` 表示每分钟请求数不受限制。
1. 选择**保存更改**。

这些速率限制是独立评估的：

- 用户为项目中的同一提交 SHA 创建多个流水线时，受按项目、用户和提交的限制约束。
- 用户跨不同项目或提交创建流水线时，受按用户的限制约束。
- 用户跨项目发送 CI lint 请求时，受按用户的 CI lint 请求限制约束。
- 如果超过某个限制，该请求会被阻止。

<a id="limit-downstream-pipeline-trigger-rate"></a>

## 限制下游流水线触发速率

限制每分钟可以从单个来源触发多少个[下游流水线](../../ci/pipelines/downstream_pipelines.md)。

最大下游流水线触发速率限制了在给定项目、用户和提交组合下每分钟可以触发的下游流水线数量。默认值为 `0`，表示没有限制。

要配置此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 为**最大下游流水线触发速率**设置一个值。
1. 选择**保存更改**。

<a id="pipeline-cancellation-rate-limits"></a>

## 流水线取消速率限制

取消流水线会停止其[流水线层级](../../ci/pipelines/downstream_pipelines.md)中每个可取消的作业，因此取消的成本会随流水线规模而增加。重复取消，无论是在一个大型流水线上还是分散在项目中的许多流水线上，都可能累积成对实例的过度负载。您可以限制流水线的取消频率，以防止这种情况。

此速率限制适用于通过
[取消流水线 REST API](../../api/pipelines.md#cancel-all-jobs-for-a-pipeline)、
[`pipelineCancel`](../../api/graphql/reference/_index.md#mutationpipelinecancel) GraphQL 变更或极狐GitLab UI 进行的流水线取消。
该限制不适用于自动取消（例如 `auto_cancel_on_job_failure`）。

极狐GitLab 强制执行以下限制：

- 按用户和流水线：固定为每分钟 `5` 个请求。此限制不可配置，且始终适用。
- 按用户和项目：可配置，默认为每分钟 `120` 个请求。
  将该限制设置为 `0` 可禁用此按项目限制。按用户和流水线的限制仍然适用。

如果超过任一限制，取消请求会被阻止。

要配置按用户和项目的限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 为**每个项目的最大流水线取消次数**设置一个值。
1. 选择**保存更改**。

<a id="pipeline-retry-rate-limits"></a>

## 流水线重试速率限制

> [!flag]
> 此功能的可用性由功能标志控制。

重试流水线会克隆每个可重试的作业，因此重试的成本会随流水线规模而增加。重复重试，无论是在一个大型流水线上还是分散在项目中的许多流水线上，都可能累积成对实例的过度负载。您可以限制流水线的重试频率，以防止这种情况。

此速率限制适用于通过
[重试流水线 REST API](../../api/pipelines.md#retry-jobs-in-a-pipeline)、
[`pipelineRetry`](../../api/graphql/reference/_index.md#mutationpipelineretry) GraphQL 变更或极狐GitLab UI 进行的流水线重试。
该限制不适用于自动作业重试，例如由 [`retry`](../../ci/yaml/_index.md#retry) 关键字触发的重试，它使用不同的代码路径。

极狐GitLab 强制执行以下限制：

- 按用户和流水线：固定为每分钟 `5` 个请求。此限制不可配置，且始终适用。
- 按用户和项目：可配置，默认为每分钟 `200` 个请求。
  将该限制设置为 `0` 可禁用此按项目限制。按用户和流水线的限制仍然适用。

如果超过任一限制，重试请求会被阻止。

要配置按用户和项目的限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 为**每个项目的最大流水线重试次数**设置一个值。
1. 选择**保存更改**。

<a id="job-retry-and-manual-job-run-rate-limits"></a>

## 作业重试和手动作业运行速率限制

> [!flag]
> 此功能的可用性由功能标志控制。

重试作业或运行手动作业会创建新作业并重新评估流水线，因此重复请求会累积成对实例的显著负载。您可以限制作业的重试或运行频率，以防止这种情况。

这些速率限制适用于通过[重试作业](../../api/jobs.md#retry-a-job)和[运行作业](../../api/jobs.md#run-a-job) REST API 端点、[`jobRetry`](../../api/graphql/reference/_index.md#mutationjobretry) 和 [`jobPlay`](../../api/graphql/reference/_index.md#mutationjobplay) GraphQL 变更或极狐GitLab UI 进行的作业重试和手动作业运行。这些限制不适用于自动重试（例如 CI/CD 配置中的 `retry:`）或自动回滚。

极狐GitLab 强制执行以下限制：

- 作业重试，按用户和作业：固定为每分钟 `3` 个请求。不可配置。
- 作业重试，按用户和项目：可配置，默认为每分钟 `320` 个请求。设置为 `0` 可禁用。
- 手动作业运行，按用户和作业：固定为每分钟 `3` 个请求。不可配置。
- 手动作业运行，按用户和项目：可配置，默认为每分钟 `200` 个请求。设置为 `0` 可禁用。

如果超过某个限制，该请求会被阻止。

要配置按用户和项目的限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 为**每个项目的最大作业重试次数**和**每个项目的最大手动作业运行次数**设置值。
1. 选择**保存更改**。

<a id="pipeline-deletion-rate-limits"></a>

## 流水线删除速率限制

> [!flag]
> 此功能的可用性由功能标志控制。

删除流水线会在移除记录之前取消流水线树中的每个作业，因此所涉及的工作量会随流水线规模而增加。您可以限制用户删除流水线的频率，以保护您的实例免受过度的负载。每个限制在一分钟后重置。

此速率限制适用于用户通过
[删除流水线 REST API](../../api/pipelines.md#delete-a-pipeline)、
[`pipelineDestroy`](../../api/graphql/reference/_index.md#mutationpipelinedestroy) GraphQL 变更
或极狐GitLab UI 删除流水线时。它不适用于由[自动清理](../settings/continuous_integration.md)、项目删除或议题删除移除的流水线，因为这些使用不同的代码路径。

极狐GitLab 强制执行以下限制：

- 按用户和流水线：固定为每分钟 `5` 个请求。此限制不可配置，且始终适用。
- 按用户和项目：可配置，默认为每分钟 `400` 个请求。
  将该限制设置为 `0` 可移除此按项目限制。按用户和流水线的限制仍然适用。

如果超过任一限制，删除请求会被阻止。

要配置按用户和项目的限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 为**每个项目的最大流水线删除次数**设置一个值。
1. 选择**保存更改**。

<a id="maximum-artifacts-size"></a>

## 最大产物大小

设置作业产物的大小限制，以控制存储使用量。作业中的每个产物文件默认最大大小为 100 MB。

使用 `artifacts:reports` 定义的作业产物可以有[不同的限制](#maximum-file-size-per-type-of-artifact)。当适用不同的限制时，使用较小的值。

> [!note]
> 此设置适用于最终归档文件的大小，而不是作业中的单个文件。

您可以为以下对象配置产物大小限制：

- 实例：适用于所有项目和群组的基础设置。
- 群组：覆盖该群组中所有项目的实例设置。
- 项目：覆盖特定项目的实例和群组设置。

有关 JihuLab.com 的限制，请参阅[产物最大大小](../../user/jihulab_com/_index.md#gitlab-cicd)。

要更改实例的最大产物大小：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在**最大产物大小（MB）**文本框中输入一个值。
1. 选择**保存更改**。

<a id="maximum-number-of-includes"></a>

## 最大 include 数量

限制流水线可以使用 [`include` 关键字](../../ci/yaml/includes.md)包含多少个外部 YAML 文件。此限制可防止流水线包含过多文件时出现性能问题。

默认情况下，流水线最多可以包含 150 个文件。当流水线超过此限制时，会失败并显示错误。

要设置每个流水线包含文件的最大数量：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在**最大 include 数量**文本框中输入一个值。
1. 选择**保存更改**。

<a id="maximum-size-of-the-ci-artifacts-archive"></a>

## CI 产物归档的最大大小

此设置限制[动态子流水线](../../ci/pipelines/downstream_pipelines.md#dynamic-child-pipelines)的 YAML 大小。

CI 产物归档的默认最大大小为 5 兆字节。

要在管理区域中更改此限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在**动态子流水线的最大产物大小（字节）**文本框中输入一个值。
1. 选择**保存更改**。

要使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)更改此限制，请用新值更新 `max_artifacts_content_include_size`。例如，将其设置为 20 MB：

```ruby
ApplicationSetting.update(max_artifacts_content_include_size: 20.megabytes)
```

<a id="maximum-number-of-caches-per-job"></a>

## 每个作业的最大缓存数量

限制单个 CI/CD 作业可以定义多少个 [`cache`](../../ci/yaml/_index.md#cache) 条目。当缓存使用 `cache:key:files` 时，此限制会限制作业在流水线创建期间可以触发的 Gitaly 调用数量。

默认情况下，一个作业最多可以定义 4 个缓存。当作业超过此限制时，配置会解析失败并显示错误。

该值必须至少为 1。将限制提高到默认值以上可能会影响流水线创建性能。

要更改每个作业的最大缓存数量：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**持续集成和部署**。
1. 在**每个作业的最大缓存数量**文本框中输入一个值。
1. 选择**保存更改**。

<a id="cicd-limits-instance-configuration"></a>

## CI/CD 限制实例配置

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

某些 CI/CD 限制只能通过编辑实例配置来更改。

先决条件：

- 您必须有权访问该实例的 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。

<a id="maximum-number-of-deployment-jobs-in-a-pipeline"></a>

### 单个流水线中的最大部署作业数量

您可以限制流水线中的最大部署作业数量。部署是指任何指定了 [`environment`](../../ci/environments/_index.md)的作业。流水线中的部署数量在创建流水线时进行检查。部署过多的流水线会失败，并显示 `deployments_limit_exceeded` 错误。

要更改此限制，请使用以下 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)命令更改 `default` 计划的限制：

```ruby
Plan.default.actual_limits.update!(ci_pipeline_deployments: 500)
```

默认限制为 `500`。将该限制设置为 `0` 可禁用它。

<a id="limit-the-number-of-pipeline-triggers"></a>

### 限制流水线触发器数量

您可以设置每个项目的流水线触发器最大数量限制。每次创建新触发器时都会检查此限制。

如果新触发器会导致流水线触发器总数超过限制，则该触发器被视为无效。

将该限制设置为 `0` 可禁用它。默认为 `25000`。

要将此限制设置为 `100`，请在
[GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
Plan.default.actual_limits.update!(pipeline_triggers: 100)
```

<a id="limit-the-number-of-pipelines-created-by-a-pipeline-schedule-each-day"></a>

### 限制流水线计划每天创建的流水线数量

您可以限制每个单独的流水线计划每天可以触发的流水线数量。

尝试以高于限制的频率运行流水线的计划会被减慢到最大频率。该频率通过将 1440（一天中的分钟数）除以限制值来计算。例如，对于以下最大频率：

- 每分钟一次，限制必须为 `1440`。
- 每 10 分钟一次，限制必须为 `144`。
- 每 60 分钟一次，限制必须为 `24`。

最小值为 `24`，即每 60 分钟一个流水线。没有最大值。

要在极狐GitLab 私有化部署实例上将此限制设置为 `1440`，请在
[GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_daily_pipeline_schedule_triggers: 1440)
```

<a id="maximum-scheduled-pipeline-frequency"></a>

### 最大计划流水线频率

[计划流水线](../../ci/pipelines/schedules.md)可以使用任何 [cron 值](../../topics/cron/_index.md)进行配置，但它们并不总是在计划的时间准确运行。一个称为“流水线计划 worker”的内部进程会对所有计划流水线进行排队，但它不会持续运行。该 worker 按自己的计划运行，准备启动的计划流水线只会在该 worker 下次运行时才被排队。计划流水线的运行频率不能高于该 worker。

流水线计划 worker 的默认频率为 `3-59/10 * * * *`（每十分钟一次，从 `0:03`、`0:13`、`0:23` 等开始）。JihuLab.com 的默认频率
列在 [JihuLab.com 设置](../../user/jihulab_com/_index.md#gitlab-cicd)中。

要更改流水线计划 worker 的频率：

1. 在实例的 `gitlab.rb` 文件中编辑 `gitlab_rails['pipeline_schedule_worker_cron']` 值。
1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

例如，要将流水线的最大频率设置为每天两次，请将 `pipeline_schedule_worker_cron` 设置为 cron 值 `0 */12 * * *`（每天 `00:00` 和 `12:00`）。

当许多流水线计划同时运行时，可能会出现额外的延迟。流水线计划 worker 会[分批](https://gitlab.com/gitlab-org/gitlab/-/blob/3426be1b93852c5358240c5df40970c0ddfbdb2a/app/workers/pipeline_schedule_worker.rb#L13-14)处理流水线，每批之间有短暂延迟，以分散系统负载。这可能导致流水线计划在其计划时间之后几分钟到超过一小时才启动，具体取决于系统负载。

<a id="limit-the-number-of-schedule-rules-defined-for-security-policy-project"></a>

### 限制为安全策略项目定义的计划规则数量

您可以限制每个安全策略项目的计划规则总数。每次更新带有计划规则的策略时都会检查此限制。如果新计划规则会导致计划规则总数超过限制，则不会处理该新计划规则。

默认情况下，极狐GitLab 不限制可处理的计划规则数量。

要设置此限制，请在
[GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
Plan.default.actual_limits.update!(security_policy_scan_execution_schedules: 100)
```

<a id="group-and-project-cicd-variable-limits"></a>

### 群组和项目 CI/CD 变量限制

可以在群组和项目中定义的 [CI/CD 变量](../../ci/variables/_index.md)数量对整个实例是有限的。每次创建新变量时都会检查这些限制。如果新变量会导致变量总数超过相应限制，则不会创建该新变量。

要更新其中某个限制的 `default` 计划，请在
[GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

- [群组级 CI/CD 变量](../../ci/variables/_index.md#for-a-group)每个群组的限制（默认：`30000`）：

  ```ruby
  Plan.default.actual_limits.update!(group_ci_variables: 40000)
  ```

- [项目级 CI/CD 变量](../../ci/variables/_index.md#for-a-project)每个项目的限制（默认：`8000`）：

  ```ruby
  Plan.default.actual_limits.update!(project_ci_variables: 10000)
  ```

<a id="maximum-file-size-per-type-of-artifact"></a>

### 每种产物类型的最大文件大小

由 runner 上传的、使用 [`artifacts:reports`](../../ci/yaml/_index.md#artifactsreports) 定义的作业产物，如果文件大小超过最大文件大小限制，则会被拒绝。该限制通过比较项目的[最大产物大小设置](#maximum-artifacts-size)与给定产物类型的实例限制来确定，并选择较小的值。

限制以兆字节为单位设置，因此可以定义的最小值为 `1 MB`。

每种产物类型都有一个可以设置的大小限制。默认值 `0` 表示该特定产物类型没有限制，将使用项目的最大产物大小设置：

| 产物限制名称                         | 默认值 |
|---------------------------------------------|---------------|
| `ci_max_artifact_size_accessibility`        | 0             |
| `ci_max_artifact_size_annotations`          | 0             |
| `ci_max_artifact_size_api_fuzzing`          | 0             |
| `ci_max_artifact_size_archive`              | 0             |
| `ci_max_artifact_size_browser_performance`  | 0             |
| `ci_max_artifact_size_cluster_applications` | 0             |
| `ci_max_artifact_size_cobertura`            | 0             |
| `ci_max_artifact_size_codequality`          | 0             |
| `ci_max_artifact_size_container_scanning`   | 0             |
| `ci_max_artifact_size_coverage_fuzzing`     | 0             |
| `ci_max_artifact_size_dast`                 | 0             |
| `ci_max_artifact_size_dependency_scanning`  | 0             |
| `ci_max_artifact_size_dotenv`               | 0             |
| `ci_max_artifact_size_jacoco`               | 0             |
| `ci_max_artifact_size_junit`                | 0             |
| `ci_max_artifact_size_license_management`   | 0             |
| `ci_max_artifact_size_license_scanning`     | 0             |
| `ci_max_artifact_size_load_performance`     | 0             |
| `ci_max_artifact_size_lsif`                 | 200 MB        |
| `ci_max_artifact_size_metadata`             | 0             |
| `ci_max_artifact_size_metrics_referee`      | 0             |
| `ci_max_artifact_size_metrics`              | 0             |
| `ci_max_artifact_size_network_referee`      | 0             |
| `ci_max_artifact_size_performance`          | 0             |
| `ci_max_artifact_size_requirements`         | 0             |
| `ci_max_artifact_size_requirements_v2`      | 0             |
| `ci_max_artifact_size_sarif`                | 10 MB         |
| `ci_max_artifact_size_sast`                 | 0             |
| `ci_max_artifact_size_secret_detection`     | 0             |
| `ci_max_artifact_size_terraform`            | 5 MB          |
| `ci_max_artifact_size_trace`                | 0             |
| `ci_max_artifact_size_cyclonedx`            | 1 MB          |

例如，要在极狐GitLab 私有化部署上将 `ci_max_artifact_size_junit` 限制设置为 10 MB，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_max_artifact_size_junit: 10)
```

您也可以在**管理**区域中设置 `ci_max_artifact_size_cyclonedx`。有关更多信息，请参阅
[限制 CycloneDX 产物大小](#limit-cyclonedx-artifact-size)。

<a id="maximum-file-size-for-job-logs"></a>

### 作业日志的最大文件大小

极狐GitLab 中的作业日志文件大小限制默认为 100 兆字节。任何超过限制的作业都会被标记为失败，并由 runner 丢弃。

您可以在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中更改此限制。用新值（以兆字节为单位）更新 `ci_jobs_trace_size_limit`：

```ruby
Plan.default.actual_limits.update!(ci_jobs_trace_size_limit: 125)
```

极狐GitLab Runner 还有一个 [`output_limit` 设置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)，
用于配置 runner 中的最大日志大小。超过 runner 限制的作业会继续运行，但日志在达到限制时会被截断。

<a id="maximum-number-of-active-dast-profile-schedules-per-project"></a>

### 每个项目的最大活动 DAST 配置文件计划数量

限制每个项目的活动 DAST 配置文件计划数量。DAST 配置文件计划可以是活动的或非活动的。

您可以在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中更改此限制。用新值更新 `dast_profile_schedules`：

```ruby
Plan.default.actual_limits.update!(dast_profile_schedules: 50)
```

<a id="maximum-size-and-depth-of-cicd-configuration-yaml-files"></a>

### CI/CD 配置 YAML 文件的最大大小和深度

单个 CI/CD 配置 YAML 文件的默认最大大小为 2 兆字节，默认深度为 100。

您可以在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中更改这些限制：

- 要更新最大 YAML 大小，请用新值（以兆字节为单位）更新 `max_yaml_size_bytes`：

  ```ruby
  ApplicationSetting.update(max_yaml_size_bytes: 4.megabytes)
  ```

  `max_yaml_size_bytes` 值并不直接与 YAML 文件的大小相关，
  而是与为相关对象分配的内存相关。

- 要更新最大 YAML 深度，请用新值（以行数为单位）更新 `max_yaml_depth`：

  ```ruby
  ApplicationSetting.update(max_yaml_depth: 125)
  ```

<a id="maximum-size-of-the-entire-cicd-configuration"></a>

### 整个 CI/CD 配置的最大大小

可以为完整流水线配置（包括所有包含的 YAML 配置文件）分配的最大内存量（以字节为单位）。

默认值通过将 [`max_yaml_size_bytes`](#maximum-size-and-depth-of-cicd-configuration-yaml-files)（默认 2 MB）乘以 [`ci_max_includes`](../../api/settings.md#available-settings)（默认 150）计算得出：

- 在极狐GitLab 17.2 及更早版本中：1 MB × 150 = `157286400` 字节（150 MB）。
- 在极狐GitLab 17.3 及更高版本中：2 MB × 150 = `314572800` 字节（314.6 MB）。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)更改此限制。要更新可以为 CI/CD 配置分配的最大内存，请用新值更新 `ci_max_total_yaml_size_bytes`。例如，将其设置为 20 MB：

```ruby
ApplicationSetting.update(ci_max_total_yaml_size_bytes: 20.megabytes)
```

当创建流水线时，此限制也约束为单个 CI/CD 作业存储的已编译配置。单个作业的配置始终是整个流水线配置的子集，因此它不能超过此限制。

<a id="limit-cicd-job-annotations"></a>

### 限制 CI/CD 作业注解

您可以设置每个 CI/CD 作业的[注解](../../ci/yaml/artifacts_reports.md#artifactsreportsannotations)最大数量限制。

将该限制设置为 `0` 可禁用它。默认为 `20`。

要在您的实例上将此限制设置为 `100`，请在
[GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_job_annotations_num: 100)
```

<a id="limit-cicd-job-annotations-file-size"></a>

### 限制 CI/CD 作业注解文件大小

您可以设置 CI/CD 作业[注解](../../ci/yaml/artifacts_reports.md#artifactsreportsannotations)的最大大小限制。

将该限制设置为 `0` 可禁用它。默认为 80 KB。

要将此限制设置为 100 KB，请在
[GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_job_annotations_size: 100.kilobytes)
```

<a id="maximum-database-partition-size-for-cicd-tables"></a>

### CI/CD 表的最大数据库分区大小

在自动创建新分区之前，分区表的一个分区可以使用的最大磁盘空间量（以字节为单位）。默认为 100 GB。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)更改此限制。要更改此限制，请用新值更新 `ci_partitions_size_limit`。例如，将其设置为 20 GB：

```ruby
ApplicationSetting.update(ci_partitions_size_limit: 20.gigabytes)
```

<a id="maximum-time-window-for-cicd-partitions"></a>

### CI/CD 分区的最大时间窗口

在创建新 CI 分区并且系统切换到下一组分区之前的时间窗口（以秒为单位）。必须介于 1 个月和 6 个月之间。默认为 1 个月（2592000 秒）。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)更改此限制。要更改此限制，请用新值更新 `ci_partitions_in_seconds_limit`。例如，将其设置为 3 个月：

```ruby
ApplicationSetting.update(ci_partitions_in_seconds_limit: ChronicDuration.parse('3 months'))
```

<a id="maximum-retention-period-for-automatic-pipeline-cleanup"></a>

### 自动流水线清理的最大保留期

配置[自动流水线清理](../../ci/pipelines/settings.md#automatic-pipeline-cleanup)的上限。默认为 1 年。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)更改此限制。要更改此限制，请用新值更新 `ci_delete_pipelines_in_seconds_limit_human_readable`。例如，将其设置为 3 年：

```ruby
ApplicationSetting.update(ci_delete_pipelines_in_seconds_limit_human_readable: '3 years')
```
