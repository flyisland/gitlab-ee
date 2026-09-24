---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Trigger and manage parent-child and multi-project pipelines.
title: 下游流水线
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

下游流水线是由另一个流水线触发的任何极狐GitLab CI/CD 流水线。下游流水线与触发它们的上游流水线独立、并发地运行。

- 父子流水线是在与第一条流水线同一项目内触发的下游流水线。
- 多项目流水线是在与第一条流水线不同的项目中触发的下游流水线。

你有时可以将父子流水线和多项目流水线用于类似目的，但它们之间存在[关键差异](pipeline_architectures.md)。

默认情况下，流水线层次结构最多可包含 1000 个下游流水线。有关此限制及如何更改的更多信息，请参见[限制流水线层次结构大小](../../administration/instance_limits.md#limit-pipeline-hierarchy-size)。

<a id="parent-child-pipelines"></a>

## 父子流水线

父流水线是在同一项目中触发下游流水线的流水线。被触发的下游流水线称为子流水线。

子流水线：

- 与父流水线在相同的项目、引用和提交 SHA 下运行。
- 不会直接影响流水线所针对引用的整体状态。例如，如果针对主分支的流水线失败，通常会说“主分支已损坏”。子流水线的状态仅在子流水线通过 [`trigger:strategy`](../yaml/_index.md#triggerstrategy) 触发时才会影响引用的状态。
- 如果流水线配置为 [`interruptible`](../yaml/_index.md#interruptible)，并且为同一引用创建了新的流水线，则会自动取消。
- 不会显示在项目的流水线列表中。你只能在父流水线的详情页面查看子流水线。

<a id="nested-child-pipelines"></a>

### 嵌套子流水线

父流水线和子流水线最多可有两级深度的子流水线。

一个父流水线可以触发多个子流水线，这些子流水线又可以触发它们自己的子流水线。你不能再触发下一级子流水线。

<a id="multi-project-pipelines"></a>

## 多项目流水线

一个项目中的流水线可以触发另一个项目中的下游流水线，这称为多项目流水线。触发上游流水线的用户必须能够在下游项目中启动流水线，否则[下游流水线将无法启动](downstream_pipelines_troubleshooting.md#trigger-job-fails-and-does-not-create-multi-project-pipeline)。

多项目流水线：

- 从另一个项目的流水线触发，但上游（触发）流水线对下游（被触发的）流水线没有太多控制权。不过，它可以选择下游流水线的引用，并传递 CI/CD 变量给下游。
- 影响其运行所在项目引用的整体状态，但不会影响触发流水线引用的状态，除非通过 [`trigger:strategy`](../yaml/_index.md#triggerstrategy) 触发。
- 当在具有 [`interruptible`](../yaml/_index.md#interruptible) 的上游流水线中为同一引用运行新流水线时，下游项目不会自动取消。但如果在下游项目上为同一引用触发新流水线，则可能会自动取消。
- 在下游项目的流水线列表中可见。
- 是独立的，因此没有嵌套限制。

如果你使用公共项目触发私有项目中的下游流水线，请确保不存在机密性问题。上游项目的流水线页面始终显示：

- 下游项目的名称。
- 流水线的状态。

<a id="trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file"></a>

## 从 `.gitlab-ci.yml` 文件中的作业触发下游流水线

在你的 `.gitlab-ci.yml` 文件中使用 [`trigger`](../yaml/_index.md#trigger) 关键字创建一个触发下游流水线的作业。该作业称为触发作业。

例如：

{{< tabs >}}

{{< tab title="父子流水线" >}}

```yaml
trigger_job:
  trigger:
    include:
      - local: path/to/child-pipeline.yml
```

{{< /tab >}}

{{< tab title="多项目流水线" >}}

```yaml
trigger_job:
  trigger:
    project: project-group/my-downstream-project
```

{{< /tab >}}

{{< /tabs >}}

触发作业启动后，作业的初始状态为 `pending`，同时极狐GitLab 尝试创建下游流水线。如果下游流水线创建成功，触发作业显示 `passed`，否则显示 `failed`。或者，你可以[设置触发作业以反映下游流水线的状态](#mirror-the-status-of-a-downstream-pipeline-in-the-trigger-job)。

<a id="use-rules-to-control-downstream-pipeline-jobs"></a>

### 使用 `rules` 控制下游流水线作业

使用 CI/CD 变量或 [`rules`](../yaml/_index.md#rulesif) 关键字来[控制下游流水线中的作业行为](../jobs/job_control.md)。

当你使用 [`trigger`](../yaml/_index.md#trigger) 关键字触发下游流水线时，所有作业的 [`$CI_PIPELINE_SOURCE` 预定义变量](../variables/predefined_variables.md) 的值为：

- 对于多项目流水线为 `pipeline`。
- 对于父子流水线为 `parent_pipeline`。

例如，要控制同时运行合并请求流水线的项目中的多项目流水线的作业：

```yaml
job1:
  rules:
    - if: $CI_PIPELINE_SOURCE == "pipeline"
  script: echo "此作业仅在多项目流水线中运行"

job2:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script: echo "此作业仅在合并请求流水线中运行"

job3:
  rules:
    - if: $CI_PIPELINE_SOURCE == "pipeline"
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script: echo "此作业在多项目流水线和合并请求流水线中均运行"
```

<a id="use-a-child-pipeline-configuration-file-in-a-different-project"></a>

### 在不同项目中使用子流水线配置文件

你可以在触发作业中使用 [`include:project`](../yaml/_index.md#includeproject) 来触发带有不同项目中配置文件的子流水线：

```yaml
microservice_a:
  trigger:
    include:
      - project: 'my-group/my-pipeline-library'
        ref: 'main'
        file: '/path/to/child-pipeline.yml'
```

<a id="combine-multiple-child-pipeline-configuration-files"></a>

### 组合多个子流水线配置文件

在定义子流水线时，你最多可以包含三个配置文件。子流水线的配置由所有配置文件合并而成：

```yaml
microservice_a:
  trigger:
    include:
      - local: path/to/microservice_a.yml
      - template: Jobs/SAST.gitlab-ci.yml
      - project: 'my-group/my-pipeline-library'
        ref: 'main'
        file: '/path/to/child-pipeline.yml'
```

<a id="dynamic-child-pipelines"></a>

### 动态子流水线

你可以从作业中生成的 YAML 文件触发子流水线，而不是使用项目中保存的静态文件。这种技术对于生成针对变更内容的流水线或构建目标与架构矩阵非常强大。

包含生成的 YAML 文件的产物必须在[实例限制](../../administration/instance_limits.md#maximum-size-of-the-ci-artifacts-archive)之内。

有关生成动态子流水线的示例项目，请参见 [使用 Jsonnet 的动态子流水线](https://jihulab.com/gitlab-cn/project-templates/jsonnet)。此项目展示了如何使用数据模板语言在运行时生成你的 `.gitlab-ci.yml`。你可以对其他模板语言（如 [Dhall](https://dhall-lang.org/) 或 [ytt](https://get-ytt.io/) 使用类似的过程。

<a id="trigger-a-dynamic-child-pipeline"></a>

#### 触发动态子流水线

要从动态生成的配置文件触发子流水线：

1. 在一个作业中生成配置文件并将其保存为[产物](../yaml/_index.md#artifactspaths)：

   ```yaml
   generate-config:
     stage: build
     script: generate-ci-config > generated-config.yml
     artifacts:
       paths:
         - generated-config.yml
   ```

1. 配置触发作业在生成配置文件的作业之后运行。将 `include: artifact` 设置为生成的产物，并将 `include: job` 设置为创建产物的作业：

   ```yaml
   child-pipeline:
     stage: test
     trigger:
       include:
         - artifact: generated-config.yml
           job: generate-config
   ```

在此示例中，极狐GitLab 检索 `generated-config.yml` 并使用该文件中的 CI/CD 配置触发子流水线。

产物路径由极狐GitLab 解析，而不是 Runner，因此路径必须与运行极狐GitLab 的操作系统语法匹配。如果极狐GitLab 运行在 Linux 上，但使用 Windows Runner 进行测试，则触发作业的路径分隔符为 `/`。使用 Windows Runner 的其他 CI/CD 配置（如脚本）使用 `\`。

你不能在动态子流水线配置的 `include` 部分中使用 CI/CD 变量。

<a id="run-child-pipelines-with-merge-request-pipelines"></a>

### 将子流水线与合并请求流水线一起运行

在不使用 [`rules`](../yaml/_index.md#rules) 或 [`workflow:rules`](../yaml/_index.md#workflowrules) 的情况下，流水线（包括子流水线）默认按分支流水线运行。要配置子流水线在从[合并请求（父）流水线](merge_request_pipelines.md)触发时运行，请使用 `rules` 或 `workflow:rules`。例如，使用 `rules`：

1. 将父流水线的触发作业设置为在合并请求时运行：

   ```yaml
   trigger-child-pipeline-job:
     trigger:
       include: path/to/child-pipeline-configuration.yml
     rules:
       - if: $CI_PIPELINE_SOURCE == "merge_request_event"
   ```

1. 使用 `rules` 配置子流水线的作业，使其在父流水线触发时运行：

   ```yaml
   job1:
     script: echo "此子流水线作业会在父流水线触发时随时运行。"
     rules:
       - if: $CI_PIPELINE_SOURCE == "parent_pipeline"

   job2:
     script: echo "此子流水线作业仅在父流水线为合并请求流水线时运行"
     rules:
       - if: $CI_MERGE_REQUEST_ID
   ```

在子流水线中，`$CI_PIPELINE_SOURCE` 的值始终为 `parent_pipeline`，因此：

- 你可以使用 `if: $CI_PIPELINE_SOURCE == "parent_pipeline"` 来确保子流水线作业始终运行。
- 你不能使用 `if: $CI_PIPELINE_SOURCE == "merge_request_event"` 来配置子流水线作业为合并请求流水线运行。相反，使用 `if: $CI_MERGE_REQUEST_ID` 来设置子流水线作业仅在父流水线为合并请求流水线时运行。父流水线的 [`CI_MERGE_REQUEST_*` 预定义变量](../variables/predefined_variables.md#predefined-variables-for-merge-request-pipelines) 会传递给子流水线作业。

<a id="specify-a-branch-for-multi-project-pipelines"></a>

### 为多项目流水线指定分支

你可以指定触发多项目流水线时使用的分支。极狐GitLab 使用分支头部的提交来创建下游流水线。例如：

```yaml
staging:
  stage: deploy
  trigger:
    project: my/deployment
    branch: stable-11-2
```

使用：

- `project` 关键字指定下游项目的完整路径。在[极狐GitLab 15.3 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/367660)中，你可以使用[变量扩展](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- `branch` 关键字指定 `project` 所指定项目中的分支或[标签](../../user/project/repository/tags/_index.md)名称。你可以使用变量扩展。

<a id="trigger-a-multi-project-pipeline-by-using-the-api"></a>

## 通过 API 触发多项目流水线

你可以将 [CI/CD 作业令牌（`CI_JOB_TOKEN`）](../jobs/ci_job_token.md)与[流水线触发器令牌 API 端点](../../api/pipeline_triggers.md#trigger-a-pipeline-with-a-token)结合使用，从 CI/CD 作业内部触发多项目流水线。极狐GitLab 将使用作业令牌触发的流水线设置为包含发起 API 调用的作业的流水线的下游流水线。

例如：

```yaml
trigger_pipeline:
  stage: deploy
  script:
    - |
      curl --request POST \
        --form "token=$CI_JOB_TOKEN" \
        --form ref=main \
        --url "https://gitlab.example.com/api/v4/projects/9/trigger/pipeline"
  rules:
    - if: $CI_COMMIT_TAG
  environment: production
```

<a id="view-a-downstream-pipeline"></a>

## 查看下游流水线

在[流水线详情页面](_index.md#pipeline-details)中，下游流水线在图右侧显示为一系列卡片。在此视图中，你可以：

- 选择一个触发作业以查看触发的下游流水线的作业。
- 在流水线卡片上选择 **展开作业** {{< icon name="chevron-lg-right" >}} 以展开视图，显示下游流水线的作业。你一次只能查看一个下游流水线。
- 将鼠标悬停在流水线卡片上，以突出显示触发该下游流水线的作业。

<a id="retry-failed-and-canceled-jobs-in-a-downstream-pipeline"></a>

### 重试下游流水线中失败和已取消的作业

{{< history >}}

- Retry from graph view [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/354974) in GitLab 15.0 [with a flag](../../administration/feature_flags/_index.md) named `downstream_retry_action`. Disabled by default.
- Retry from graph view [generally available and feature flag removed](https://gitlab.com/gitlab-org/gitlab/-/issues/357406) in GitLab 15.1.

{{< /history >}}

要重试失败和已取消的作业，选择 **重试** ({{< icon name="retry" >}})：

- 从下游流水线的详情页面。
- 在流水线图中的流水线卡片上。

<a id="recreate-a-downstream-pipeline"></a>

### 重新创建下游流水线

{{< history >}}

- Retry trigger job from graph view [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/367547) in GitLab 15.10 [with a flag](../../administration/feature_flags/_index.md) named `ci_recreate_downstream_pipeline`. Disabled by default.
- [Generally available](https://gitlab.com/groups/gitlab-org/-/epics/6947) in GitLab 15.11. Feature flag `ci_recreate_downstream_pipeline` removed.

{{< /history >}}

你可以通过重试相应的触发作业来重新创建下游流水线。新创建的下游流水线将替换流水线图中的当前下游流水线。

要重新创建下游流水线：

- 在流水线图中的触发作业卡片上选择 **再次运行** ({{< icon name="retry" >}})。

<a id="cancel-a-downstream-pipeline"></a>

### 取消下游流水线

{{< history >}}

- Retry from graph view [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/354974) in GitLab 15.0 [with a flag](../../administration/feature_flags/_index.md) named `downstream_retry_action`. Disabled by default.
- Retry from graph view [generally available and feature flag removed](https://gitlab.com/gitlab-org/gitlab/-/issues/357406) in GitLab 15.1.

{{< /history >}}

要取消仍在运行的下游流水线，选择 **取消** ({{< icon name="cancel" >}})：

- 从下游流水线的详情页面。
- 在流水线图中的流水线卡片上。

<a id="auto-cancel-the-parent-pipeline-from-a-downstream-pipeline"></a>

### 从下游流水线自动取消父流水线

你可以配置子流水线在某个作业失败时[自动取消](../yaml/_index.md#workflowauto_cancelon_job_failure)。

仅当满足以下条件时，父流水线才会在子流水线中的作业失败时自动取消：

- 父流水线也已设置为在作业失败时自动取消。
- 触发作业配置了 [`strategy: mirror`](../yaml/_index.md#triggerstrategy)。

例如：

- `.gitlab-ci.yml` 的内容：

  ```yaml
  workflow:
    auto_cancel:
      on_job_failure: all

  trigger_job:
    trigger:
      include: child-pipeline.yml
      strategy: mirror

  job3:
    script:
      - sleep 120
  ```

- `child-pipeline.yml` 的内容

  ```yaml
  # child-pipeline.yml 的内容
  workflow:
    auto_cancel:
      on_job_failure: all

  job1:
    script: sleep 60

  job2:
    script:
      - sleep 30
      - exit 1
  ```

在此示例中：

1. 父流水线同时触发子流水线和 `job3`
1. 子流水线中的 `job2` 失败，子流水线被取消，同时停止 `job1`
1. 子流水线已取消，因此父流水线自动取消

<a id="mirror-the-status-of-a-downstream-pipeline-in-the-trigger-job"></a>

### 在触发作业中反映下游流水线的状态

你可以通过使用 [`trigger: strategy`](../yaml/_index.md#triggerstrategy) 在触发作业中反映下游流水线的状态：

使用 `strategy: mirror` 时，触发作业的状态始终与下游流水线的状态相同。

{{< tabs >}}

{{< tab title="父子流水线" >}}

```yaml
trigger_job:
  trigger:
    include:
      - local: path/to/child-pipeline.yml
    strategy: mirror
```

{{< /tab >}}

{{< tab title="多项目流水线" >}}

```yaml
trigger_job:
  trigger:
    project: my/project
    strategy: mirror
```

{{< /tab >}}

{{< /tabs >}}

不推荐使用 `strategy: depend`，因为触发作业的状态并不总是与下游流水线的状态匹配。请参见 [`trigger:strategy` 参考](../yaml/_index.md#triggerstrategy)中的其他详细信息。

<a id="view-multi-project-pipelines-in-pipeline-graphs"></a>

### 在流水线图中查看多项目流水线

{{< history >}}

- [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/422282) from GitLab Premium to GitLab Free in 16.8.

{{< /history >}}

在触发多项目流水线后，下游流水线显示在[流水线图](_index.md#view-pipelines)的右侧。

在[流水线迷你图](_index.md#pipeline-mini-graphs)中，下游流水线显示在迷你图的右侧。

<a id="view-child-pipeline-reports-in-merge-requests"></a>

## 在合并请求中查看子流水线报告

{{< history >}}

- [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/18311) in GitLab 18.6.
- Security reports from child pipelines [introduced](https://gitlab.com/groups/gitlab-org/-/work_items/18377) in GitLab 18.9.

{{< /history >}}

你可以在合并请求小部件中查看和下载子流水线的报告。这提供了整个流水线层次结构中测试结果和质量检查的统一视图，无需手动浏览多个流水线来识别失败和漏洞。

支持以下来自子流水线的报告类型：

- 单元测试报告 (JUnit)
- 代码质量报告
- Terraform 报告
- 指标报告
- 安全报告 (SAST、密钥检测、依赖项扫描、容器扫描、DAST、API 模糊测试)

安全报告支持来自同一项目的子流水线、动态生成的子流水线以及由流水线执行策略创建的流水线。不支持来自[扫描执行策略](../../user/application_security/policies/scan_execution_policies.md)的报告。

测试结果和[安全发现](../../user/application_security/detect/security_scanning_results.md)也会出现在父流水线的 **测试** 和 **安全** 选项卡中。

子流水线的安全发现可以触发[合并请求批准策略](../../user/application_security/policies/merge_request_approval_policies.md)。如果子流水线检测到漏洞，你可能需要额外的批准才能合并。

要确保子流水线的报告出现在合并请求小部件中，为生成产物报告的子流水线使用 [`strategy: depend`](../yaml/_index.md#triggerstrategy) 或 [`strategy: mirror`](../yaml/_index.md#triggerstrategy)。例如：

```yaml
test-backend:
  trigger:
    include: backend-tests.yml
    strategy: depend

test-frontend:
  trigger:
    include: frontend-tests.yml
    strategy: depend
```

如果不使用这些策略，父流水线会在子流水线完成之前完成，它们的报告将不会出现在合并请求中。

<a id="fetch-artifacts-from-an-upstream-pipeline"></a>

## 从上游流水线获取产物

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< tabs >}}

{{< tab title="父子流水线" >}}

使用 [`needs:pipeline:job`](../yaml/_index.md#needspipelinejob) 从上游流水线获取产物：

1. 在上游流水线中，使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字将产物保存在一个作业中，然后用触发作业触发下游流水线：

   ```yaml
   build_artifacts:
     stage: build
     script:
       - echo "这是一个测试产物！" >> artifact.txt
     artifacts:
       paths:
         - artifact.txt

   deploy:
     stage: deploy
     trigger:
       include:
         - local: path/to/child-pipeline.yml
     variables:
       PARENT_PIPELINE_ID: $CI_PIPELINE_ID
   ```

1. 在下游流水线的作业中使用 `needs:pipeline:job` 来获取成功作业的产物。

   ```yaml
   test:
     stage: test
     script:
       - cat artifact.txt
     needs:
       - pipeline: $PARENT_PIPELINE_ID
         job: build_artifacts
   ```

   将 `job` 设置为上游流水线中创建产物的作业。

{{< /tab >}}

{{< tab title="多项目流水线" >}}

使用 [`needs:project`](../yaml/_index.md#needsproject) 从上游流水线获取产物：

1. 在极狐GitLab 15.9 及更高版本中，[将下游项目添加到上游项目的作业令牌范围允许列表](../jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)。
1. 在上游流水线中，使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字将产物保存在一个作业中，然后用触发作业触发下游流水线：

   ```yaml
   build_artifacts:
     stage: build
     script:
       - echo "这是一个测试产物！" >> artifact.txt
     artifacts:
       paths:
         - artifact.txt

   deploy:
     stage: deploy
     trigger: my/downstream_project   # 要触发流水线的项目路径
   ```

1. 在下游流水线的作业中使用 `needs:project` 来获取成功作业的产物。

   ```yaml
   test:
     stage: test
     script:
       - cat artifact.txt
     needs:
       - project: my/upstream_project
         job: build_artifacts
         ref: main
         artifacts: true
   ```

   设置：

   - `job` 为上游流水线中创建产物的作业。
   - `ref` 为分支。
   - `artifacts` 为 `true`。

{{< /tab >}}

{{< /tabs >}}

> [!warning]
> 确保上游作业在下游作业开始之前完成，否则你无法获取产物。
> 使用 [`needs`](../yaml/_index.md#needs) 让下游作业等待上游作业。
>
> 更多信息，请参见[议题 356016](https://gitlab.com/gitlab-org/gitlab/-/issues/356016)。

<a id="fetch-artifacts-from-an-upstream-merge-request-pipeline"></a>

### 从上游合并请求流水线获取产物

当你使用 `needs:project` [将产物传递到下游流水线](#fetch-artifacts-from-an-upstream-pipeline) 时，`ref` 值通常是一个分支名称，如 `main` 或 `development`。

对于[合并请求流水线](merge_request_pipelines.md)，`ref` 值的格式为 `refs/merge-requests/<id>/head`，其中 `id` 是合并请求 ID。你可以使用 [`CI_MERGE_REQUEST_REF_PATH`](../variables/predefined_variables.md#predefined-variables-for-merge-request-pipelines) CI/CD 变量检索此引用。不要在合并请求流水线中使用分支名称作为 `ref`，因为下游流水线会尝试从最新的分支流水线获取产物。

要从上游 `merge request` 流水线而不是 `branch` 流水线获取产物，通过[变量继承](#pass-yaml-defined-cicd-variables)将 `CI_MERGE_REQUEST_REF_PATH` 传递给下游流水线：

1. 在极狐GitLab 15.9 及更高版本中，[将下游项目添加到上游项目的作业令牌范围允许列表](../jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)。
1. 在上游流水线的作业中，使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字保存产物。
1. 在触发下游流水线的作业中，传递 `$CI_MERGE_REQUEST_REF_PATH` 变量：

   ```yaml
   build_artifacts:
     rules:
       - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
     stage: build
     script:
       - echo "这是一个测试产物！" >> artifact.txt
     artifacts:
       paths:
         - artifact.txt

   upstream_job:
     rules:
       - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
     variables:
       UPSTREAM_REF: $CI_MERGE_REQUEST_REF_PATH
     trigger:
       project: my/downstream_project
       branch: my-branch
   ```

1. 在下游流水线的作业中，使用 `needs:project` 并将传递的变量作为 `ref` 来获取上游流水线的产物：
    ```yaml
   test:
     stage: test
     script:
       - cat artifact.txt
     needs:
       - project: my/upstream_project
         job: build_artifacts
         ref: $UPSTREAM_REF
         artifacts: true
   ```

您可以使用此方法从上游合并请求流水线获取产物，但不能从[合并结果流水线](merged_results_pipelines.md)获取。

<a id="pass-inputs-to-a-downstream-pipeline"></a>

## 向下游流水线传递输入

您可以使用 [`inputs`](../inputs/_index.md) 关键字向下游流水线传递输入值。输入相较于变量具有诸多优势，包括类型检查、通过选项进行验证、描述以及默认值。

首先，在目标配置文件中使用 `spec:inputs` 定义输入参数：

```yaml
# 目标流水线配置
spec:
  inputs:
    environment:
      description: "Deployment environment"
      options: [staging, production]
    version:
      type: string
      description: "Application version"
```

然后在触发流水线时提供值：

{{< tabs >}}

{{< tab title="父子流水线" >}}

```yaml
staging:
  trigger:
    include:
      - local: path/to/child-pipeline.yml
        inputs:
          environment: staging
          version: "1.0.0"
```

{{< /tab >}}

{{< tab title="多项目流水线" >}}

```yaml
staging:
  trigger:
    project: my-group/my-deployment-project
    inputs:
      environment: staging
      version: "1.0.0"
```

{{< /tab >}}

{{< /tabs >}}

<a id="pass-cicd-variables-to-a-downstream-pipeline"></a>

## 将 CI/CD 变量传递到下游流水线

您可以通过几种不同的方法将 [CI/CD 变量](../variables/_index.md) 传递到下游流水线，具体取决于变量的创建或定义位置。

<a id="pass-yaml-defined-cicd-variables"></a>

### 传递 YAML 定义的 CI/CD 变量

> [!note]
> 建议使用输入而非变量进行流水线配置，因为输入提供了更高的安全性和灵活性。

您可以使用 `variables` 关键字将 CI/CD 变量传递到下游流水线。这些变量是用于[变量优先级](../variables/_index.md#cicd-variable-precedence)的流水线变量。

例如：

{{< tabs >}}

{{< tab title="父子流水线" >}}

```yaml
variables:
  VERSION: "1.0.0"

staging:
  variables:
    ENVIRONMENT: staging
  stage: deploy
  trigger:
    include:
      - local: path/to/child-pipeline.yml
```

{{< /tab >}}

{{< tab title="多项目流水线" >}}

```yaml
variables:
  VERSION: "1.0.0"

staging:
  variables:
    ENVIRONMENT: staging
  stage: deploy
  trigger: my-group/my-deployment-project
```

{{< /tab >}}

{{< /tabs >}}

`ENVIRONMENT` 变量在下游流水线中定义的每个作业中都可用。

`VERSION` 默认变量在下游流水线中也可用，因为流水线中的所有作业（包括触发作业）都会继承[默认 `variables`](../yaml/_index.md#default-variables)。

<a id="prevent-default-variables-from-being-passed"></a>

#### 阻止传递默认变量

您可以使用 [`inherit:variables`](../yaml/_index.md#inheritvariables) 阻止默认 CI/CD 变量传递到下游流水线。您可以列出要继承的特定变量，或者阻止所有默认变量。

例如：

{{< tabs >}}

{{< tab title="父子流水线" >}}

```yaml
variables:
  DEFAULT_VAR: value

trigger-job:
  inherit:
    variables: false
  variables:
    JOB_VAR: value
  trigger:
    include:
      - local: path/to/child-pipeline.yml
```

{{< /tab >}}

{{< tab title="多项目流水线" >}}

```yaml
variables:
  DEFAULT_VAR: value

trigger-job:
  inherit:
    variables: false
  variables:
    JOB_VAR: value
  trigger: my-group/my-project
```

{{< /tab >}}

{{< /tabs >}}

`DEFAULT_VAR` 变量在触发的流水线中不可用，但 `JOB_VAR` 可用。

<a id="pass-a-predefined-variable"></a>

### 传递预定义变量

要使用[预定义 CI/CD 变量](../variables/predefined_variables.md)传递有关上游流水线的信息，请使用插值。将预定义变量保存为触发作业中的新作业变量，该变量会传递到下游流水线。例如：

{{< tabs >}}

{{< tab title="父子流水线" >}}

```yaml
trigger-job:
  variables:
    PARENT_BRANCH: $CI_COMMIT_REF_NAME
  trigger:
    include:
      - local: path/to/child-pipeline.yml
```

{{< /tab >}}

{{< tab title="多项目流水线" >}}

```yaml
trigger-job:
  variables:
    UPSTREAM_BRANCH: $CI_COMMIT_REF_NAME
  trigger: my-group/my-project
```

{{< /tab >}}

{{< /tabs >}}

`UPSTREAM_BRANCH` 变量包含上游流水线的 `$CI_COMMIT_REF_NAME` 预定义 CI/CD 变量的值，在下游流水线中可用。

请勿使用此方法将[掩码变量](../variables/_index.md#mask-a-cicd-variable)传递到多项目流水线。CI/CD 掩码配置不会传递到下游流水线，并且该变量可能会在下游项目的作业日志中被取消掩码。

您不能使用此方法将[仅作业变量](../variables/predefined_variables.md#variable-availability)转发到下游流水线，因为它们在触发作业中不可用。

上游流水线优先于下游流水线。如果在上游和下游项目中都定义了两个同名的变量，则在上游项目中定义的变量优先。

<a id="pass-dotenv-variables-created-in-a-job"></a>

### 传递在作业中创建的 dotenv 变量

您可以通过 dotenv 变量继承将变量传递到下游流水线。更多信息，请参阅[将变量传递到下游流水线](../variables/dotenv_variables.md#pass-variables-to-downstream-pipelines)。

<a id="control-what-type-of-variables-to-forward-to-downstream-pipelines"></a>

### 控制要转发到下游流水线的变量类型

使用 [`trigger:forward` 关键字](../yaml/_index.md#triggerforward) 指定要转发到下游流水线的变量类型。转发的变量被视为触发变量，具有[最高优先级](../variables/_index.md#cicd-variable-precedence)。

<a id="downstream-pipelines-for-deployments"></a>

## 用于部署的下游流水线

{{< history >}}

- 在极狐GitLab 16.4 中引入。

{{< /history >}}

您可以将 [`environment`](../yaml/_index.md#environment) 关键字与 [`trigger`](../yaml/_index.md#trigger) 一起使用。如果您的部署和应用项目是分开管理的，您可能希望从触发作业中使用 `environment`。

```yaml
deploy:
  trigger:
    project: project-group/my-downstream-project
  environment: production
```

下游流水线可以配置基础设施、部署到指定环境，并将部署状态返回给上游项目。

您可以从上游项目[查看环境和部署](../environments/_index.md#view-environments-and-deployments)。

<a id="advanced-example"></a>

### 高级示例

此示例配置具有以下行为：

- 上游项目根据分支名称动态组合环境名称。
- 上游项目使用 `UPSTREAM_*` 变量将部署上下文传递给下游项目。

上游项目中的 `.gitlab-ci.yml`：

```yaml
stages:
  - deploy
  - cleanup

.downstream-deployment-pipeline:
  variables:
    UPSTREAM_PROJECT_ID: $CI_PROJECT_ID
    UPSTREAM_ENVIRONMENT_NAME: $CI_ENVIRONMENT_NAME
    UPSTREAM_ENVIRONMENT_ACTION: $CI_ENVIRONMENT_ACTION
  trigger:
    project: project-group/deployment-project
    branch: main
    strategy: mirror

deploy-review:
  stage: deploy
  extends: .downstream-deployment-pipeline
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    on_stop: stop-review

stop-review:
  stage: cleanup
  extends: .downstream-deployment-pipeline
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
  when: manual
```

下游项目中的 `.gitlab-ci.yml`：

```yaml
deploy:
  script: echo "Deploy to ${UPSTREAM_ENVIRONMENT_NAME} for ${UPSTREAM_PROJECT_ID}"
  rules:
    - if: $CI_PIPELINE_SOURCE == "pipeline" && $UPSTREAM_ENVIRONMENT_ACTION == "start"

stop:
  script: echo "Stop ${UPSTREAM_ENVIRONMENT_NAME} for ${UPSTREAM_PROJECT_ID}"
  rules:
    - if: $CI_PIPELINE_SOURCE == "pipeline" && $UPSTREAM_ENVIRONMENT_ACTION == "stop"
```