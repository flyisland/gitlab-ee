---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置流水线、作业、计划和产物的 CI/CD 限制，以控制实例上的资源使用。
title: CI/CD 限制
---

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以通过[管理区域](../admin_area.md)管理许多与 CI/CD 相关的实例限制。
其他限制只能通过 GitLab Rails 控制台修改实例配置来更改。

JihuLab.com 上的值可能与极狐GitLab 私有化部署的默认值不同。
请查看 [JihuLab.com 的 CI/CD 限制和设置](../../user/jihulab_com/_index.md#gitlab-cicd)。

<a id="instance-cicd-variable-limit"></a>

## 实例 CI/CD 变量限制

可以在实例设置中定义的 [CI/CD 变量](../../ci/variables/_index.md) 数量是有限制的。每次创建新变量时都会检查此限制。
如果新变量会导致变量总数超过限制，则不会创建该新变量。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **可定义的实例级 CI/CD 变量最大数量** 设置一个值。
   默认值为 `25`。
1. 选择 **保存更改**。

<a id="limit-dotenv-file-size"></a>

## 限制 dotenv 文件大小

您可以设置 dotenv 产物的最大大小限制。每次将 dotenv 文件导出为产物时都会检查此限制。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **dotenv 产物的最大大小（字节）** 设置一个值。
1. 选择 **保存更改**。

将限制设置为 `0` 以禁用它。默认为 5 KB。

<a id="limit-dotenv-variables"></a>

## 限制 dotenv 变量

您可以设置 dotenv 产物内变量数量的最大限制。每次将 dotenv 文件导出为产物时都会检查此限制。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **dotenv 产物中的变量最大数量** 设置一个值。
1. 选择 **保存更改**。

将限制设置为 `0` 以禁用它。默认为 `20`。

您也可以使用 [计划限制 API](../../api/plan_limits.md) 设置此限制。

<a id="limit-cyclonedx-artifact-size"></a>

## 限制 CycloneDX 产物大小

您可以设置 [CycloneDX SBOM](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 产物的最大大小限制。每次将 CycloneDX 报告作为产物上传时都会检查此限制。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **CycloneDX 产物的最大大小（MB）** 设置一个值。
1. 选择 **保存更改**。

将限制设置为 `0` 以改用 [最大产物大小](#maximum-artifacts-size)。默认为 `1` MB。

<a id="maximum-number-of-jobs-in-a-pipeline"></a>

## 流水线中的最大作业数

您可以限制单个流水线中的最大作业数。在创建流水线以及创建新的提交状态时，会检查流水线中的作业数。
作业过多的流水线会因 `size_limit_exceeded` 错误而失败。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **单个流水线中的最大作业数** 设置一个值。
1. 选择 **保存更改**。

将限制设置为 `0` 以禁用它。默认禁用。

<a id="number-of-jobs-in-active-pipelines"></a>

## 活动流水线中的作业数

每个项目的活动流水线中的作业总数可以受到限制。每次创建新的流水线时都会检查此限制。活动流水线是指处于以下任一状态的流水线：

- `created`
- `pending`
- `running`

如果新的流水线会导致作业总数超过限制，则该流水线会因 `job_activity_limit_exceeded` 错误而失败。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **当前活动流水线中的作业总数** 设置一个值。
1. 选择 **保存更改**。

将限制设置为 `0` 以禁用它。默认禁用。

<a id="number-of-cicd-subscriptions-to-a-project"></a>

## 项目的 CI/CD 订阅数量

每个项目的订阅总数可以受到限制。每次创建新订阅时都会检查此限制。

如果新订阅会导致订阅总数超过限制，则该订阅被视为无效。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **进出项目的流水线订阅最大数量** 设置一个值。
1. 选择 **保存更改**。

默认情况下，订阅限制为 `2` 个。将限制设置为 `0` 以禁用它。

<a id="number-of-pipeline-schedules"></a>

## 流水线计划的数量

每个项目的流水线计划总数可以受到限制。每次创建新的流水线计划时都会检查此限制。如果新的流水线计划会导致流水线计划总数超过限制，则不会创建该流水线计划。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **流水线计划的最大数量** 设置一个值。
1. 选择 **保存更改**。

默认情况下，流水线计划限制为 `10` 个。

您也可以使用 [计划限制 API](../../api/plan_limits.md)。

<a id="maximum-number-of-needs-dependencies"></a>

## needs 依赖的最大数量

您可以设置单个作业可以拥有的 needs 依赖的最大数量。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **作业可以拥有的 needs 依赖的最大数量** 设置一个值。
1. 选择 **保存更改**。

此限制无法禁用。默认为 `50`。

设置为 `0` 以阻止所有 needs 依赖。配置为使用 `needs` 的作业的流水线随后会返回错误 `job can only need 0 others`。

<a id="number-of-registered-runners-for-groups-and-projects"></a>

## 群组和项目的已注册 Runner 数量

群组和项目的已注册 Runner 总数是有限制的。每次注册新的 Runner 时，极狐GitLab 都会根据过去 7 天内创建或活动的 Runner 来检查这些限制。
如果 Runner 的注册超出了由其注册令牌确定的范围限制，则注册失败。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为以下任一选项设置一个值：
   - **过去七天内群组中创建或活动的 Runner 最大数量**
   - **过去七天内项目中创建或活动的 Runner 最大数量**
1. 选择 **保存更改**。

将限制设置为 `0` 以禁用它。

<a id="limit-pipeline-hierarchy-size"></a>

## 限制流水线层级大小

默认情况下，一个 [流水线层级](../../ci/pipelines/downstream_pipelines.md) 最多可以包含 1000 个下游流水线。
当超过此限制时，创建流水线会因错误 `downstream pipeline tree is too large` 而失败。

> [!warning]
> 不建议增加此限制。默认限制可保护您的极狐GitLab 实例免受过度资源消耗、潜在的流水线递归和数据库过载的影响。
>
> 与其增加限制，不如通过将大型流水线层级拆分为较小的流水线来重组您的 CI/CD 配置。
> 考虑在单个流水线中的作业或依赖阶段之间使用 `needs`。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **流水线层级树中的下游流水线最大数量** 设置一个值。
1. 选择 **保存更改**。

您也可以使用 [计划限制 API](../../api/plan_limits.md)。

<a id="merge-train-parallel-pipeline-limit"></a>

## 合并列车并行流水线限制

默认情况下，每个 [合并列车](../../ci/pipelines/merge_trains.md) 最多可以并行运行 20 个流水线。当达到此限制时，
额外的合并请求将排队，直到有可用的流水线槽位。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **CI/CD 限制** 下，为 **每个合并列车的最大并行流水线** 设置一个值。
   最小值为 `1`。值为 `1` 时，合并请求将按顺序处理，无并行。
1. 选择 **保存更改**。

您也可以使用 [计划限制 API](../../api/plan_limits.md)。

您可以为[特定项目](../../ci/pipelines/merge_trains.md#merge-train-parallel-pipeline-limit)设置不同的值。

<a id="maximum-time-jobs-can-run"></a>

## 作业可以运行的最长时间

作业可以运行的默认最长时间为 60 分钟。运行时间超过 60 分钟的作业将超时。

您可以更改作业在超时前可以运行的最长时间：

- 对于特定项目，在[项目的 CI/CD 设置](../../ci/pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)中设置。此限制必须在 10 分钟到 1 个月之间。
- [对于 Runner](../../ci/runners/configure_runners.md#set-the-maximum-job-timeout)。此限制必须为 10 分钟或更长。

无论配置的超时限制如何，极狐GitLab 都会终止任何处于非活动状态 60 分钟的作业。非活动作业是指未产生新日志或跟踪更新的作业。

<a id="number-of-pipelines-per-git-push"></a>

## 每次 Git 推送的流水线数量

> [!warning]
> 不建议增加此限制。如果同时推送大量更改，可能会导致极狐GitLab 实例负载过高，可能造成大量流水线涌入。

当使用单个 Git 推送推送多个更改（如多个标签或分支）时，默认情况下只能触发四个标签或分支流水线。此限制可防止在使用 `git push --all` 或 `git push --mirror` 时意外创建大量流水线。

[合并请求流水线](../../ci/pipelines/merge_request_pipelines.md) 也受限制。
如果 Git 推送同时更新多个合并请求，则在达到限制之前，每个更新的合并请求都可能触发一个合并请求流水线。

极狐GitLab 私有化部署和 JihuLab.com 的默认值为 `4`。

要在您的极狐GitLab 私有化部署实例上更改此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 更改 **每次 Git 推送的流水线限制** 的值。
1. 选择 **保存更改**。

<a id="pipeline-creation-rate-limits"></a>

## 流水线创建速率限制

您可以设置限制，使用户和进程每分钟不能请求超过一定数量的流水线。
这些限制有助于节省资源并提高稳定性。
每个限制在一分钟后重置。

极狐GitLab 在本节中强制执行以下速率限制：

- **每个项目、提交和用户**：限制同一项目、提交 SHA 和用户组合创建的流水线。默认设置为 `0`（无限制）。
- **每个用户**：限制用户在所有项目中创建的流水线总数。默认设置为 `0`（无限制）。
- **每个用户的 CI lint 请求**：限制用户在所有项目中发出的 [CI lint](../../ci/yaml/lint.md) 请求。CI lint 请求类似于流水线创建请求。

在新安装中，`ci_lint_limit_per_user` 设置为 `0`（无限制）。
在升级到极狐GitLab 19.2 的实例上，如果 `pipeline_limit_per_user` 已设置为大于 `0` 的值，
则 `ci_lint_limit_per_user` 将初始化为相同的值。

例如，如果您将每个用户的限制设置为 `100`，并且某个用户在一分钟内跨不同项目向 [触发 API](../../ci/triggers/_index.md) 发送了流水线创建请求 `101` 次，
则第 101 个请求将被阻止。一分钟后，对该端点的访问将再次被允许。

这些限制不按 IP 地址应用。

超过限制的请求会记录在 `application_json.log` 文件中。

> [!flag]
> 仅当启用了 `ci_enforce_ci_lint_rate_limit` 功能标志时，才会强制执行 `ci_lint_limit_per_user` 限制。
> 在该标志启用之前，超过限制的请求会被记录但不会被阻止。

<a id="set-pipeline-request-limits"></a>

### 设置流水线请求限制

先决条件：

- 管理员访问权限。

要限制流水线请求的数量：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **流水线创建速率限制**。
   - 在 **每个项目、用户和提交的每分钟最大请求数** 下，输入大于 `0` 的值以限制同一项目、提交和用户组合的流水线。设置为 `0` 表示每分钟请求数不限。
   - 在 **每个用户的每分钟最大请求数** 下，输入大于 `0` 的值以限制每个用户创建的流水线总数。设置为 `0` 表示每分钟请求数不限。
   - 在 **每个用户的 CI Lint 请求最大数量** 下，输入大于 `0` 的值以限制每个用户发出的 CI lint 请求。设置为 `0` 表示每分钟请求数不限。
1. 选择 **保存更改**。

速率限制是独立评估的：

- 用户为项目中的同一提交 SHA 创建多个流水线时，受每个项目、用户和提交限制的约束。
- 用户跨不同项目或提交创建流水线时，受每个用户限制的约束。
- 用户跨项目发送 CI lint 请求时，受每个用户的 CI lint 请求限制的约束。
- 如果超过限制，请求将被阻止。

<a id="limit-downstream-pipeline-trigger-rate"></a>

## 限制下游流水线触发速率

限制每分钟可以从单个源触发多少个 [下游流水线](../../ci/pipelines/downstream_pipelines.md)。

最大下游流水线触发速率限制了在给定项目、用户和提交组合下每分钟可以触发的下游流水线数量。
默认值为 `0`，表示没有限制。

要配置此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 为 **最大下游流水线触发速率** 设置一个值。
1. 选择 **保存更改**。

<a id="maximum-artifacts-size"></a>

## 最大产物大小

设置作业产物的大小限制以控制存储使用。
作业中的每个产物文件默认最大大小为 100 MB。

使用 `artifacts:reports` 定义的作业产物可以具有[不同的限制](#maximum-file-size-per-type-of-artifact)。
当应用不同的限制时，使用较小的值。

> [!note]
> 此设置适用于最终归档文件的大小，而不是作业中的单个文件。

您可以为以下级别配置产物大小限制：

- 实例：适用于所有项目和群组的基础设置。
- 群组：覆盖该群组中所有项目的实例设置。
- 项目：覆盖特定项目的实例和群组设置。

有关 JihuLab.com 的限制，请参阅 [产物最大大小](../../user/jihulab_com/_index.md#gitlab-cicd)。

要更改实例的最大产物大小：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **最大产物大小 (MB)** 文本框中输入一个值。
1. 选择 **保存更改**。

<a id="maximum-number-of-includes"></a>

## 最大 include 数量

限制流水线可以使用 [`include` 关键字](../../ci/yaml/includes.md) 包含多少个外部 YAML 文件。
此限制可防止当流水线包含过多文件时出现性能问题。

默认情况下，一个流水线最多可以包含 150 个文件。
当流水线超过此限制时，它会因错误而失败。

要为每个流水线设置最大包含文件数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **最大 include 数量** 文本框中输入一个值。
1. 选择 **保存更改**。

<a id="maximum-size-of-the-ci-artifacts-archive"></a>

## CI 产物归档的最大大小

此设置限制 [动态子流水线](../../ci/pipelines/downstream_pipelines.md#dynamic-child-pipelines) 的 YAML 大小。

CI 产物归档的默认最大大小为 5 兆字节。

要在管理区域中更改此限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **动态子流水线的最大产物大小（字节）** 文本框中输入一个值。
1. 选择 **保存更改**。

要使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 更改此限制，
请使用新值更新 `max_artifacts_content_include_size`。例如，将其设置为 20 MB：

```ruby
ApplicationSetting.update(max_artifacts_content_include_size: 20.megabytes)
```

<a id="maximum-number-of-caches-per-job"></a>

## 每个作业的最大缓存数

限制单个 CI/CD 作业可以定义多少个 [`cache`](../../ci/yaml/_index.md#cache) 条目。
当缓存使用 `cache:key:files` 时，此限制会限定作业在创建流水线期间可以触发的 Gitaly 调用次数。

默认情况下，一个作业最多可以定义 4 个缓存。
当作业超过此限制时，配置解析将失败并报错。

该值必须至少为 1。将限制提高到默认值以上可能会影响流水线创建性能。

要更改每个作业的最大缓存数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成和部署**。
1. 在 **每个作业的最大缓存数** 文本框中输入一个值。
1. 选择 **保存更改**。

<a id="cicd-limits-instance-configuration"></a>

## CI/CD 限制实例配置

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

某些 CI/CD 限制只能通过编辑实例配置来更改。

先决条件：

- 您必须具有实例的 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 访问权限。

<a id="maximum-number-of-deployment-jobs-in-a-pipeline"></a>

### 流水线中的最大部署作业数

您可以限制流水线中的最大部署作业数。部署是指任何指定了 [`environment`](../../ci/environments/_index.md) 的作业。在创建流水线时会检查流水线中的部署数量。部署过多的流水线会因 `deployments_limit_exceeded` 错误而失败。

要更改限制，请使用以下 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 命令更改 `default` 计划的限制：

```ruby
# If limits don't exist for the default plan, you can create one with:
# Plan.default.create_limits!

Plan.default.actual_limits.update!(ci_pipeline_deployments: 500)
```

默认限制为 `500`。将限制设置为 `0` 以禁用它。

<a id="limit-the-number-of-pipeline-triggers"></a>

### 限制流水线触发器的数量

您可以设置每个项目的流水线触发器最大数量限制。每次创建新触发器时都会检查此限制。

如果新触发器会导致流水线触发器总数超过限制，则该触发器被视为无效。

将限制设置为 `0` 以禁用它。默认为 `25000`。

要将此限制设置为 `100`，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
Plan.default.actual_limits.update!(pipeline_triggers: 100)
```

<a id="limit-the-number-of-pipelines-created-by-a-pipeline-schedule-each-day"></a>

### 限制每个流水线计划每天创建的流水线数量

您可以限制每个单独的流水线计划每天可以触发的流水线数量。

尝试以高于限制的频率运行流水线的计划将被减慢到最大频率。
该频率的计算方法是将 1440（一天中的分钟数）除以限制值。例如，对于最大频率：

- 每分钟一次，限制必须为 `1440`。
- 每 10 分钟一次，限制必须为 `144`。
- 每 60 分钟一次，限制必须为 `24`。

最小值为 `24`，即每 60 分钟一个流水线。
没有最大值。

要在极狐GitLab 私有化部署实例上将此限制设置为 `1440`，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_daily_pipeline_schedule_triggers: 1440)
```

<a id="maximum-scheduled-pipeline-frequency"></a>

### 最大计划流水线频率

[计划流水线](../../ci/pipelines/schedules.md) 可以配置任何 [cron 值](../../topics/cron/_index.md)，
但它们并不总是按计划准确运行。一个名为“流水线计划工作进程”的内部进程会排队所有计划的流水线，但不会持续运行。该工作进程按自己的计划运行，准备开始的计划流水线只会在工作进程下次运行时排队。计划流水线的运行频率不能高于工作进程。

流水线计划工作进程的默认频率为 `3-59/10 * * * *`（每十分钟一次，
从 `0:03`、`0:13`、`0:23` 等开始）。JihuLab.com 的默认频率
列在 [JihuLab.com 设置](../../user/jihulab_com/_index.md#gitlab-cicd) 中。

要更改流水线计划工作进程的频率：

1. 编辑实例的 `gitlab.rb` 文件中的 `gitlab_rails['pipeline_schedule_worker_cron']` 值。
1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

例如，要将流水线的最大频率设置为每天两次，请将 `pipeline_schedule_worker_cron`
设置为 cron 值 `0 */12 * * *`（每天 `00:00` 和 `12:00`）。

当许多流水线计划同时运行时，可能会出现额外的延迟。
流水线计划工作进程会[分批](https://gitlab.com/gitlab-org/gitlab/-/blob/3426be1b93852c5358240c5df40970c0ddfbdb2a/app/workers/pipeline_schedule_worker.rb#L13-14)处理流水线，
每批之间有小延迟以分散系统负载。这可能导致流水线计划在其计划时间之后几分钟到一小时以上才开始，具体取决于系统负载。

<a id="limit-the-number-of-schedule-rules-defined-for-security-policy-project"></a>

### 限制为安全策略项目定义的调度规则数量

您可以限制每个安全策略项目的调度规则总数。每次更新带有调度规则的策略时都会检查此限制。如果新的调度规则会导致调度规则总数超过限制，则不会处理新的调度规则。

默认情况下，极狐GitLab 不限制可处理的调度规则数量。

要设置此限制，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
Plan.default.actual_limits.update!(security_policy_scan_execution_schedules: 100)
```

<a id="group-and-project-cicd-variable-limits"></a>

### 群组和项目 CI/CD 变量限制

整个实例中可以在群组和项目中定义的 [CI/CD 变量](../../ci/variables/_index.md) 数量是有限制的。每次创建新变量时都会检查这些限制。
如果新变量会导致变量总数超过相应限制，则不会创建该新变量。

要在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中更新这些限制之一的 `default` 计划，请运行以下命令：

- 每个群组的 [群组级 CI/CD 变量](../../ci/variables/_index.md#for-a-group) 限制（默认值：`30000`）：

  ```ruby
  Plan.default.actual_limits.update!(group_ci_variables: 40000)
  ```

- 每个项目的 [项目级 CI/CD 变量](../../ci/variables/_index.md#for-a-project) 限制（默认值：`8000`）：

  ```ruby
  Plan.default.actual_limits.update!(project_ci_variables: 10000)
  ```

<a id="maximum-file-size-per-type-of-artifact"></a>

### 每种产物类型的最大文件大小

使用 [`artifacts:reports`](../../ci/yaml/_index.md#artifactsreports) 定义并由 Runner 上传的作业产物，如果文件大小超过最大文件大小限制，则会被拒绝。该限制通过比较项目的[最大产物大小设置](#maximum-artifacts-size)与给定产物类型的实例限制，并选择较小的值来确定。

限制以兆字节为单位设置，因此可以定义的最小可能值为 `1 MB`。

每种类型的产物都可以设置大小限制。默认值 `0` 表示该特定产物类型没有限制，并使用项目的最大产物大小设置：

| 产物限制名称                               | 默认值 |
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

例如，要在极狐GitLab 私有化部署上将 `ci_max_artifact_size_junit` 限制设置为 10 MB，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_max_artifact_size_junit: 10)
```

您也可以在 **管理**区域设置 `ci_max_artifact_size_cyclonedx`。有关更多信息，请参阅
[限制 CycloneDX 产物大小](#limit-cyclonedx-artifact-size)。

<a id="maximum-file-size-for-job-logs"></a>

### 作业日志的最大文件大小

极狐GitLab 中的作业日志文件大小限制默认为 100 兆字节。任何超过该限制的作业都会被标记为失败，并被 Runner 丢弃。

您可以在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中更改限制。
使用以兆字节为单位的新值更新 `ci_jobs_trace_size_limit`：

```ruby
Plan.default.actual_limits.update!(ci_jobs_trace_size_limit: 125)
```

极狐GitLab Runner 也有一个 [`output_limit` 设置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)
用于配置 Runner 中的最大日志大小。超过 Runner 限制的作业会继续运行，但当日志达到限制时会被截断。

<a id="maximum-number-of-active-dast-profile-schedules-per-project"></a>

### 每个项目最大活动 DAST 配置文件计划数

限制每个项目的活动 DAST 配置文件计划数。DAST 配置文件计划可以处于活动或非活动状态。

您可以在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中更改限制。
使用新值更新 `dast_profile_schedules`：

```ruby
Plan.default.actual_limits.update!(dast_profile_schedules: 50)
```

<a id="maximum-size-and-depth-of-cicd-configuration-yaml-files"></a>

### CI/CD 配置 YAML 文件的最大大小和深度

单个 CI/CD 配置 YAML 文件的默认最大大小为 2 兆字节，默认深度为 100。

您可以在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中更改这些限制：

- 要更新最大 YAML 大小，请使用以兆字节为单位的新值更新 `max_yaml_size_bytes`：

  ```ruby
  ApplicationSetting.update(max_yaml_size_bytes: 4.megabytes)
  ```

  `max_yaml_size_bytes` 值不直接与 YAML 文件的大小相关，
  而是与为相关对象分配的内存相关。

- 要更新最大 YAML 深度，请使用以行数表示的新值更新 `max_yaml_depth`：

  ```ruby
  ApplicationSetting.update(max_yaml_depth: 125)
  ```

<a id="maximum-size-of-the-entire-cicd-configuration"></a>

### 整个 CI/CD 配置的最大大小

可以为完整的流水线配置（包括所有包含的 YAML 配置文件）分配的最大内存量（以字节为单位）。

默认值通过将 [`max_yaml_size_bytes`](#maximum-size-and-depth-of-cicd-configuration-yaml-files)（默认 2 MB）与 [`ci_max_includes`](../../api/settings.md#available-settings)（默认 150）相乘计算得出：

- 在极狐GitLab 17.2 及更早版本中：1 MB × 150 = `157286400` 字节（150 MB）。
- 在极狐GitLab 17.3 及更高版本中：2 MB × 150 = `314572800` 字节（314.6 MB）。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 更改此限制。
要更新可为 CI/CD 配置分配的最大内存，请使用新值更新 `ci_max_total_yaml_size_bytes`。例如，将其设置为 20 MB：

```ruby
ApplicationSetting.update(ci_max_total_yaml_size_bytes: 20.megabytes)
```

此限制同样约束创建流水线时为单个 CI/CD 作业存储的编译配置。单个作业的配置始终是整个流水线配置的子集，因此不能超过此限制。

<a id="limit-cicd-job-annotations"></a>

### 限制 CI/CD 作业注解

您可以设置每个 CI/CD 作业的 [注解](../../ci/yaml/artifacts_reports.md#artifactsreportsannotations) 最大数量限制。

将限制设置为 `0` 以禁用它。默认为 `20`。

要在您的实例上将此限制设置为 `100`，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_job_annotations_num: 100)
```

<a id="limit-cicd-job-annotations-file-size"></a>

### 限制 CI/CD 作业注解文件大小

您可以设置 CI/CD 作业 [注解](../../ci/yaml/artifacts_reports.md#artifactsreportsannotations) 的最大大小限制。

将限制设置为 `0` 以禁用它。默认为 80 KB。

要将此限制设置为 100 KB，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
Plan.default.actual_limits.update!(ci_job_annotations_size: 100.kilobytes)
```

<a id="maximum-database-partition-size-for-cicd-tables"></a>

### CI/CD 表的最大数据库分区大小

在自动创建新分区之前，分区表的一个分区可以使用的最大磁盘空间量（以字节为单位）。默认为 100 GB。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 更改此限制。
要更改限制，请使用新值更新 `ci_partitions_size_limit`。例如，将其设置为 20 GB：

```ruby
ApplicationSetting.update(ci_partitions_size_limit: 20.gigabytes)
```

<a id="maximum-time-window-for-cicd-partitions"></a>

### CI/CD 分区的最大时间窗口

在创建新的 CI 分区并且系统切换到下一组分区之前的时间窗口（以秒为单位）。必须在 1 个月到 6 个月之间。默认为 1 个月（2592000 秒）。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 更改此限制。
要更改限制，请使用新值更新 `ci_partitions_in_seconds_limit`。例如，将其设置为 3 个月：

```ruby
ApplicationSetting.update(ci_partitions_in_seconds_limit: ChronicDuration.parse('3 months'))
```

<a id="maximum-retention-period-for-automatic-pipeline-cleanup"></a>

### 自动流水线清理的最大保留期

配置 [自动流水线清理](../../ci/pipelines/settings.md#automatic-pipeline-cleanup) 的上限。默认为 1 年。

您可以使用 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 更改此限制。
要更改限制，请使用新值更新 `ci_delete_pipelines_in_seconds_limit_human_readable`。
例如，将其设置为 3 年：

```ruby
ApplicationSetting.update(ci_delete_pipelines_in_seconds_limit_human_readable: '3 years')
```
