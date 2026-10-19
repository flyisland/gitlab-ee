---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference
---

# CI/CD 故障排查 **(BASIC ALL)**

极狐GitLab 提供了多种工具来帮助您更轻松地对流水线进行故障排查。

本指南还列出了常见问题和可能的解决方案。

## 验证语法

问题的早期根源可能是不正确的语法。如果发现任何语法或格式问题，流水线会显示一个 `yaml invalid` 标志并且不会开始运行。

### 使用流水线编辑器编辑 `.gitlab-ci.yml`

[流水线编辑器](pipeline_editor/index.md) 是推荐的编辑体验（而不是单个文件编辑器或 Web IDE）。包括：

- 代码完成建议，确保您只使用可接受的关键字。
- 自动语法高亮和验证。
- [CI/CD 配置可视化](pipeline_editor/index.md#可视化-ci-配置)，是您的`.gitlab-ci.yml` 文件的图形表示。

如果您更喜欢使用其他编辑器，可以使用像 [the Schemastore `gitlab-ci` schema](https://json.schemastore.org/gitlab-ci) 这样的模式和您选择的编辑器。

### 在本地编辑 `.gitlab-ci.yml`

如果您更喜欢在本地编辑流水线配置，可以在编辑器中使用极狐GitLab CI/CD schema 来验证基本语法问题。任何[支持 Schemastore 的编辑器](https://www.schemastore.org/json/#editors) 默认使用极狐GitLab CI/CD 模式。

如果您需要直接链接到 schema，它位于：

```plaintext
https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/assets/javascripts/editor/schema/ci.json.
```

要查看 CI/CD schema 涵盖的自定义标签的完整列表，请查看上面链接的 schema 的最新版本。

### 使用 CI Lint 工具验证语法

<!--[CI Lint 工具](lint.md)-->CI Lint 工具是一种确保 CI/CD 配置文件语法正确的简单方法。粘贴完整的 `.gitlab-ci.yml` 文件或单个作业配置，以验证基本语法。

当项目中存在 `.gitlab-ci.yml` 文件时，您还可以使用 CI Lint 工具模拟完整流水线的创建<!--[模拟完整流水线的创建](lint.md#pipeline-simulation)-->。
它对配置语法进行更深入的验证。

## 验证变量

CI/CD 故障排查的一个关键部分是验证流水线中存在哪些变量，以及它们的值是什么。许多流水线配置依赖于变量，验证它们是找到问题根源的最快方法之一。

<!--[导出完整的变量列表](variables/index.md#list-all-environment-variables)-->导出完整的变量列表在每个有问题的作业中可用。检查您期望的变量是否存在，并检查它们的值是否符合您的期望。

## GitLab CI/CD 文档

[完整的`.gitlab-ci.yml` 参考](yaml/index.md) 包含可用于配置流水线的每个关键字的完整列表。

<!--
还可以查看大量的pipeline配置[examples](examples/index.md)和[templates](examples/index.md#cicd-templates)。
-->

### 流水线类型的文档

某些流水线类型有自己的详细使用指南，如果您正在使用该类型，您应该阅读这些指南：

- [多项目流水线](pipelines/downstream_pipelines.md#multi-project-pipelines)：让您的流水线触发不同项目中的流水线。
- [父/子流水线](pipelines/downstream_pipelines.md#parent-child-pipelines)：让您的主流水线触发在同一项目中单独运行的流水线。您还可以在运行时[动态生成子流水线的配置](pipelines/downstream_pipelines.md#dynamic-child-pipelines)。
- [合并请求流水线](pipelines/merge_request_pipelines.md)：在合并请求的上下文中运行流水线。
   - [合并结果流水线](pipelines/merged_results_pipelines.md)：合并请求的流水线在合并的源和目标分支上运行。
   - [合并队列](pipelines/merge_trains.md)：用于合并结果的多个流水线，在合并更改之前自动排队和运行。

<!--
### CI/CD 功能故障排查指南

Troubleshooting guides are available for some CI/CD features and related topics:

- [Container Registry](../user/packages/container_registry/index.md#troubleshooting-the-gitlab-container-registry)
- [GitLab Runner](https://docs.gitlab.com/runner/faq/)
- [Merge Trains](pipelines/merge_trains.md#troubleshooting)
- [Docker Build](docker/using_docker_build.md#troubleshooting)
- [Environments](environments/deployment_safety.md#ensure-only-one-deployment-job-runs-at-a-time)
-->

## 常见 CI/CD 问题

许多常见的流水线问题可以通过分析 `rules` 或 `only/except` 配置来解决。您不应在同一流水线中使用这两种配置，因为它们的行为不同，很难预测流水线如何以方式运行。

如果您的 `rules` 或 `only/except` 配置使用了预定义的变量，如 `CI_PIPELINE_SOURCE`、`CI_MERGE_REQUEST_ID`，您应该将[验证它们](#验证变量)作为故障排查的第一步。

### 作业或流水线未按预期运行

`rules` 或 `only/except` 关键字决定了是否将作业添加到流水线中。如果流水线运行，但没有将作业添加到流水线中，通常是由于 `rules` 或 `only/except` 配置问题。

如果流水线似乎根本没有运行，没有错误消息，也可能是由于 `rules` 或 `only/except` 配置，或者 `workflow: rules` 关键字。

如果您正在从 `only/except` 转换为 `rules` 关键字，应该仔细检查 [`rules` 配置细节](yaml/index.md#rules)。`only/except` 和 `rules` 的行为不同，在两者之间迁移时可能会导致意外行为。

<!--[`rules` 的常见 `if` 子句](jobs/job_control.md#common-if-clauses-for-rules)-->`rules` 的常见 `if` 子句对于如何编写符合您期望的规则的示例非常有帮助。

#### 两条流水线同时运行

将提交推送到具有与其关联的开放合并请求的分支时，可以运行两个流水线。通常一个流水线是合并请求流水线，另一个是分支流水线。

这种情况通常是由`rules`配置引起的，有几种方法可以[防止重复流水线](jobs/job_control.md#防止重复流水线)。

#### 作业不在流水线中

GitLab 根据为作业定义的 [`only/except`](yaml/index.md#only--except) 或 [`rules`](yaml/index.md#rules) 确定是否将作业添加到流水线中。如果流水线没有运行，它可能没有按照您的预期进行评估。

#### 没有流水线或运行的流水线类型错误

在流水线可以运行之前，系统会评估配置中的所有作业，并尝试将它们添加到所有可用的流水线类型中。如果在评估结束时没有向流水线添加任何作业，则流水线不会运行。

如果流水线没有运行，很可能所有作业都有 `rules` 或 `only/except` 阻止它们被添加到流水线中。

如果运行了错误的流水线类型，则应检查 `rules` 或 `only/except` 配置，以确保将作业添加到正确的流水线类型中。例如，如果合并请求流水线未运行，则作业可能已添加到分支流水线中。

也可能是您的 [`workflow: rules`](yaml/index.md#workflow) 配置阻止了流水线，或允许错误的流水线类型。

### 作业意外运行

作业意外添加到流水线中的一个常见原因是，在某些情况下 `changes` 关键字总是评估为 true。例如，`changes` 在某些流水线类型中始终为真，包括计划流水线和标签流水线。

`changes` 关键字与 [`only/except`](yaml/index.md#onlychanges--exceptchanges) 或 [`rules`](yaml/index.md#ruleschanges)) 结合使用。建议将 `changes` 与 `rules` 或 `only/except` 配置一起使用，以确保作业仅添加到分支流水线或合并请求流水线。

### "fatal: reference is not a tree" 错误

<!--
> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/17043) in GitLab 12.4.
-->

以前，当您将分支强制推送到其远端仓库时，您会遇到意外的流水线故障。为了说明这个问题，假设您有当前的工作流程：

1. 用户创建一个名为 `example` 的功能分支并将其推送到远端仓库。
1. 一个新的流水线开始在 `example` 分支上运行。
1. 用户将 `example` 分支重新建立在最新的默认分支上，并将其强制推送到其远端仓库。
1. 一个新的流水线再次开始在 `example` 分支上运行，但是，之前的流水线 (2) 因为 `fatal: reference is not a tree:` 错误而失败。

发生这种情况是因为之前的流水线无法从提交历史已经被强制推送覆盖的 `example` 分支中，找到 checkout-SHA（与流水线记录相关联）。
同样，[合并结果流水线](pipelines/merged_results_pipelines.md)可能由于相同的原因而间歇性失败。

我们通过专门持久化流水线 refs 来改进。生命周期：

1. 在名为 `example` 的功能分支上创建流水线。
1. 在 `refs/pipelines/<pipeline-id>` 处创建了一个持久的流水线 ref，它保留了相关流水线记录的 checkout-SHA。这个持久 ref 在流水线执行期间保持完整，即使 `example` 分支的提交历史已经被 force-push 覆盖。
1. runner 获取持久流水线 ref 并从 checkout-SHA 获取源代码。
1. 当流水线完成时，它的持久 ref 在后台进程中被清除。

### 合并请求流水线消息

合并请求流水线区域显示有关合并请求中流水线状态的信息。它显示在[能够合并状态区域](#合并请求状态消息)的上方。

#### "Checking ability to merge automatically" 消息

如果您的合并请求有此消息并且几分钟后它没有消失，您可以尝试以下解决方法之一：

- 刷新合并请求页面。
- 关闭并重新打开合并请求。
- 使用 `/rebase` [快速操作](../user/project/quick_actions.md) 重新设置合并请求。
- 如果您已经确认合并请求已准备好合并，您可以使用 `/merge` 快速操作将其合并。

#### "Checking pipeline status" 消息

当合并请求还没有与最新提交关联的流水线时，会显示此消息。这可能是因为：

- 系统尚未完成创建流水线。
- 您正在使用外部 CI 服务并且系统尚未收到该服务的回复。
- 您没有在项目中使用 CI/CD 流水线。
- 您在项目中使用 CI/CD 流水线，但您的配置阻止了流水线在您的合并请求的源分支上运行。
- 删除了最新的流水线。
- 合并请求的源分支在私有分支上。

创建流水线后，消息会随着流水线状态更新。

### 合并请求状态消息

合并请求状态部件显示 **合并** 按钮以及合并请求是否准备好合并。如果无法合并合并请求，则会显示原因。

如果流水线仍在运行，**合并** 按钮将替换为 **流水线成功时合并** 按钮。

如果启用了 [**合并队列**](pipelines/merge_trains.md)，则按钮为 **添加到合并队列** 或 **流水线成功时添加到合并队列**。 **(PREMIUM)**

#### "A CI/CD pipeline must run and be successful before merge" 消息

如果在项目中启用了流水线必须成功设置，并且流水线尚未成功运行，则会显示此消息。
如果流水线尚未创建，或者您正在等待外部 CI 服务，同样适用。如果您的项目不使用流水线，那么您应该禁用 **流水线必须成功**，以便您可以接受合并请求。

#### "Merge blocked: pipeline must succeed. Push a new commit that fixes the failure" 消息

如果[合并请求流水线](pipelines/merge_request_pipelines.md)、[合并结果流水线](pipelines/merged_results_pipelines.md)或[合并队列流水线](pipelines/merge_trains.md) 失败或被取消，则会显示此消息。

如果合并请求流水线或合并结果流水线被取消或失败，您可以：

- 通过在合并请求的流水线选项卡中单击 **运行流水线** 重新运行整个流水线。
- [仅重试失败的作业](pipelines/index.md#查看流水线)。没有必要重新运行整个流水线。
- 推送新的提交以修复失败。

如果合并队列流水线失败，您可以：

- 检查失败并确定是否可以使用[`/merge` 快速操作](../user/project/quick_actions.md)，立即再次将合并请求添加到队列中。
- 通过在合并请求的流水线选项卡中单击 **运行流水线** 重新运行整个流水线，然后再次将合并请求添加到队列中。
- 推送提交以修复失败，然后再次向队列添加合并请求。

如果在合并请求合并之前取消合并队列流水线，并且没有失败，您可以：

- 再次将其添加到队列。

### 未找到项目 `group/project` 或访问被拒绝

如果使用 [`include`](yaml/index.md#include) 和以下之一添加配置，则会显示此消息：

- 配置引用了一个找不到的项目。
- 运行搜了下的用户无法访问任何包含的项目。

要解决此问题，请检查：

- 项目路径的格式为 `my-group/my-project`，不包括仓库中的任何文件夹。
- 运行流水线的用户是包含 include 文件的项目的成员。用户还必须具有在相同项目中运行 CI/CD 作业的权限。

### "The parsed YAML is too big" 消息

当 YAML 配置太大或嵌套太深时会显示此消息。
包含大量 includes 和数千行的 YAML 文件更有可能达到此内存限制。例如，一个 200kb 的 YAML 文件很可能会达到默认内存限制。

要减少配置大小，您可以：

- 在流水线编辑器的 merged YAML<!--[merged YAML](pipeline_editor/index.md#view-expanded-configuration)--> 选项卡中检查扩展 CI/CD 配置的长度。寻找可以删除或简化的重复配置。
- 将长的或重复的 `script` 部分移动到项目中的独立脚本中。
- 使用[父子流水线](pipelines/downstream_pipelines.md)将一些作业转移到独立子流水线中的作业。

对于私有化部署实例，您可以增加大小限制。<!--[increase the size limits](../administration/instance_limits.md#maximum-size-and-depth-of-cicd-configuration-yaml-files).-->

### 编辑 `.gitlab-ci.yml` 文件时发生 500 错误

使用 [web 编辑器](../user/project/repository/web_editor.md) 编辑 `.gitlab-ci.yml` 文件时，[包含的配置文件循环](pipeline_editor/index.md#configuration-validation-currently-not-available-message)可能会导致 `500` 错误。

### CI/CD 作业在再次运行时不使用更新的配置

流水线的配置仅在创建流水线时获取。
当您重新运行作业时，每次都使用相同的配置。如果更新配置文件，包括使用 [`include`](yaml/index.md#include) 添加的单独文件，则必须启动新流水线来使用新配置。

## 流水线警告

当您执行以下操作时，会显示流水线配置警告：

- [使用 CI Lint 工具验证配置](yaml/index.md)。
- [手动运行流水线](pipelines/index.md#手动运行流水线)。

### "Job may allow multiple pipelines to run for a single action" 警告

当您将 [`rules`](yaml/index.md#rules) 与没有 `if` 子句的 `when` 子句一起使用时，可能会运行多个流水线。通常，当您将提交推送到具有与其关联的开放合并请求的分支时，会发生这种情况。

要防止重复流水线<!--[防止重复流水线](jobs/job_control.md#防止重复流水线)-->，请使用 [`workflow: rules`](yaml/index.md#workflow) 或重写您的规则以控制哪些流水线可以运行。

### 使用 `resource_group` 的作业卡住时的控制台解决方法 **(BASIC SELF)**

```ruby
# find resource group by name
resource_group = Project.find_by_full_path('...').resource_groups.find_by(key: 'the-group-name')
busy_resources = resource_group.resources.where('build_id IS NOT NULL')

# identify which builds are occupying the resource
# (I think it should be 1 as of today)
busy_resources.pluck(:build_id)

# it's good to check why this build is holding the resource.
# Is it stuck? Has it been forcefully dropped by the system?
# free up busy resources
busy_resources.update_all(build_id: nil)
```

### 作业日志更新缓慢

当您访问正在运行的作业的作业日志页面时，日志更新前可能会有长达 60 秒的延迟。默认刷新时间为 60 秒，但在 UI 中查看日志后，下方的日志每 3 秒发生一次更新。

## 灾难恢复

您可以禁用应用程序的一些重要但计算量大的部分，以减轻持续停机期间数据库的压力。

### 禁用共享 runner 的公平调度

清除大量积压作业时，您可以临时启用 `ci_queueing_disaster_recovery_disable_fair_scheduling` [功能标志](../administration/feature_flags.md)。此标志禁用共享 runner 上的公平调度，从而减少 `jobs/request` 端点上的系统资源使用。

启用后，作业将按照它们放入系统的顺序进行处理，而不是在多个项目之间进行平衡。

### 禁用 CI/CD 分钟数配额执行

要禁用对共享 runner 执行 CI/CD 分钟数配额，您可以临时启用 `ci_queueing_disaster_recovery_disable_quota` [功能标志](../administration/feature_flags.md)。
此标志减少了 `jobs/request` 端点上的系统资源使用。

启用后，在之前最后一小时创建的作业可以在超出配额的项目中运行。
早期的作业已经被周期性的后台 worker（`StuckCiJobsWorker`）取消。

<!--
## How to get help

If you are unable to resolve pipeline issues, you can get help from:

- The [GitLab community forum](https://forum.gitlab.com/)
- GitLab [Support](https://about.gitlab.com/support/)
-->
