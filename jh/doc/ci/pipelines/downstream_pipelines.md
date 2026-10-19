---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 触发和管理父子流水线及多项目流水线。
title: 下游流水线
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

下游流水线是由另一条流水线触发的任何极狐GitLab CI/CD 流水线。下游流水线独立于触发它们的上游流水线运行，并与其并发执行。

- [父子流水线](#parent-child-pipelines)是在与第一条流水线相同的项目中触发的下游流水线。
- [多项目流水线](#multi-project-pipelines)是在与第一条流水线不同的项目中触发的下游流水线。

有时您可以将父子流水线和多项目流水线用于类似目的，但它们之间存在[关键差异](pipeline_architectures.md)。

默认情况下，一条流水线层级最多可包含 1000 条下游流水线。有关此限制及如何更改的更多信息，请参阅[限制流水线层级大小](../../administration/cicd/limits.md#limit-pipeline-hierarchy-size)。

<a id="parent-child-pipelines"></a>

## 父子流水线

父流水线是在同一项目中触发下游流水线的流水线。该下游流水线称为子流水线。

子流水线：

- 在与父流水线相同的项目、ref 和提交 SHA 下运行。
- 不会直接影响流水线所针对 ref 的整体状态。例如，
  如果主分支的流水线失败，通常会说“主分支已损坏”。
  仅当子流水线使用 [`trigger:strategy`](../yaml/_index.md#triggerstrategy) 触发时，子流水线的状态才会影响 ref 的状态。
- 如果流水线配置了 [`interruptible`](../yaml/_index.md#interruptible)，当为同一 ref 创建新流水线时，会自动取消。
- 不会显示在项目的流水线列表中。您只能在父流水线的详情页上查看子流水线。

<a id="nested-child-pipelines"></a>

### 嵌套子流水线

父流水线和子流水线最多只能有两层子流水线。

父流水线可以触发多个子流水线，这些子流水线可以触发它们自己的子流水线。您不能再触发下一层子流水线。

<a id="multi-project-pipelines"></a>

## 多项目流水线

一个项目中的流水线可以触发另一个项目中的下游流水线，这称为多项目流水线。触发上游流水线的用户必须有权在下游项目中启动流水线，否则[下游流水线将无法启动](downstream_pipelines_troubleshooting.md#trigger-job-fails-and-does-not-create-multi-project-pipeline)。

多项目流水线：

- 由另一个项目的流水线触发，但上游（触发方）流水线对下游（被触发方）流水线的控制有限。不过，它可以选择下游流水线的 ref，并向其传递 CI/CD 变量。
- 会影响其运行所在项目 ref 的整体状态，但不会影响触发方流水线的 ref 状态，除非它是使用 [`trigger:strategy`](../yaml/_index.md#triggerstrategy) 触发的。
- 当上游流水线中为同一 ref 运行新流水线时，使用 [`interruptible`](../yaml/_index.md#interruptible) 不会自动取消下游项目中的流水线。如果在下游项目上为同一 ref 触发新流水线，则它们可以被自动取消。
- 在下游项目的流水线列表中可见。
- 相互独立，因此没有嵌套限制。

如果您使用公开项目来触发私有项目中的下游流水线，请确保不存在保密性问题。上游项目的流水线页面始终显示：

- 下游项目的名称。
- 流水线的状态。

<a id="trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file"></a>

## 从 `.gitlab-ci.yml` 文件中的作业触发下游流水线

在您的 `.gitlab-ci.yml` 文件中使用 [`trigger`](../yaml/_index.md#trigger) 关键字来创建一个触发下游流水线的作业。此作业称为触发作业。

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

触发作业启动后，在极狐GitLab 尝试创建下游流水线期间，作业的初始状态为 `pending`。如果下游流水线创建成功，触发作业显示为 `passed`，否则显示为 `failed`。或者，您可以[将触发作业设置为显示下游流水线的状态](#mirror-the-status-of-a-downstream-pipeline-in-the-trigger-job)。

触发作业不使用 Runner，因此长时间处于 `pending` 状态的触发作业通常意味着极狐GitLab 无法创建下游流水线。有关故障排除步骤，请参阅[下游流水线故障排除](downstream_pipelines_troubleshooting.md)。

<a id="use-rules-to-control-downstream-pipeline-jobs"></a>

### 使用 `rules` 控制下游流水线作业

使用 CI/CD 变量或 [`rules`](../yaml/_index.md#rulesif) 关键字来[控制下游流水线中的作业行为](../jobs/job_control.md)。

当您使用 [`trigger`](../yaml/_index.md#trigger) 关键字触发下游流水线时，所有作业的 [`$CI_PIPELINE_SOURCE` 预定义变量](../variables/predefined_variables.md)的值为：

- 多项目流水线为 `pipeline`。
- 父子流水线为 `parent_pipeline`。

例如，要在同时运行合并请求流水线的项目中控制多项目流水线中的作业：

```yaml
job1:
  rules:
    - if: $CI_PIPELINE_SOURCE == "pipeline"
  script: echo "This job runs in multi-project pipelines only"

job2:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script: echo "This job runs in merge request pipelines only"

job3:
  rules:
    - if: $CI_PIPELINE_SOURCE == "pipeline"
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script: echo "This job runs in both multi-project and merge request pipelines"
```

<a id="use-a-child-pipeline-configuration-file-in-a-different-project"></a>

### 在不同项目中使用子流水线配置文件

您可以在触发作业中使用 [`include:project`](../yaml/_index.md#includeproject)，以使用不同项目中的配置文件触发子流水线：

```yaml
microservice_a:
  trigger:
    include:
      - project: 'my-group/my-pipeline-library'
        ref: 'main'
        file: '/path/to/child-pipeline.yml'
```

<a id="combine-multiple-child-pipeline-configuration-files"></a>

### 合并多个子流水线配置文件

定义子流水线时，最多可以包含三个配置文件。子流水线的配置由所有配置文件合并而成：

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

您可以从作业中生成的 YAML 文件触发子流水线，而不是使用项目中保存的静态文件。这种技术对于生成针对已更改内容的流水线，或构建目标和架构矩阵非常有用。

包含生成的 YAML 文件的产物必须在[实例限制](../../administration/cicd/limits.md#maximum-size-of-the-ci-artifacts-archive)范围内。

有关生成动态子流水线的示例项目，请参阅[使用 Jsonnet 的动态子流水线](https://gitlab.com/gitlab-org/project-templates/jsonnet)。此项目展示了如何使用数据模板语言在运行时生成您的 `.gitlab-ci.yml`。您可以对 [Dhall](https://dhall-lang.org/) 或 [ytt](https://get-ytt.io/) 等其他模板语言使用类似流程。

<a id="trigger-a-dynamic-child-pipeline"></a>

#### 触发动态子流水线

要从动态生成的配置文件触发子流水线：

1. 在作业中生成配置文件，并将其保存为[产物](../yaml/_index.md#artifactspaths)：

   ```yaml
   generate-config:
     stage: build
     script: generate-ci-config > generated-config.yml
     artifacts:
       paths:
         - generated-config.yml
   ```

1. 将触发作业配置为在生成配置文件的作业之后运行。将 `include: artifact` 设置为生成的产物，并将 `include: job` 设置为创建该产物的作业：

   ```yaml
   child-pipeline:
     stage: test
     trigger:
       include:
         - artifact: generated-config.yml
           job: generate-config
   ```

在此示例中，极狐GitLab 检索 `generated-config.yml`，并使用该文件中的 CI/CD 配置触发子流水线。

产物路径由极狐GitLab 解析，而不是由 Runner 解析，因此路径必须与运行极狐GitLab 的操作系统语法匹配。如果极狐GitLab 在 Linux 上运行，但使用 Windows Runner 进行测试，则触发作业的路径分隔符为 `/`。使用 Windows Runner 的作业的其他 CI/CD 配置（如脚本）使用 ` \ `。

您不能在动态子流水线配置的 `include` 部分中使用 CI/CD 变量。

<a id="run-child-pipelines-with-merge-request-pipelines"></a>

### 使用合并请求流水线运行子流水线

当不使用 [`rules`](../yaml/_index.md#rules) 或 [`workflow:rules`](../yaml/_index.md#workflowrules) 时，流水线（包括子流水线）默认作为分支流水线运行。要将子流水线配置为在从[合并请求（父）流水线](merge_request_pipelines.md)触发时运行，请使用 `rules` 或 `workflow:rules`。例如，使用 `rules`：

1. 将父流水线的触发作业设置为在合并请求上运行：

   ```yaml
   trigger-child-pipeline-job:
     trigger:
       include: path/to/child-pipeline-configuration.yml
     rules:
       - if: $CI_PIPELINE_SOURCE == "merge_request_event"
   ```

1. 使用 `rules` 将子流水线作业配置为在由父流水线触发时运行：

   ```yaml
   job1:
     script: echo "This child pipeline job runs any time the parent pipeline triggers it."
     rules:
       - if: $CI_PIPELINE_SOURCE == "parent_pipeline"

   job2:
     script: echo "This child pipeline job runs only when the parent pipeline is a merge request pipeline"
     rules:
       - if: $CI_MERGE_REQUEST_ID
   ```

在子流水线中，`$CI_PIPELINE_SOURCE`的值始终为 `parent_pipeline`，因此：

- 您可以使用 `if: $CI_PIPELINE_SOURCE == "parent_pipeline"` 来确保子流水线作业始终运行。
- 您不能使用 `if: $CI_PIPELINE_SOURCE == "merge_request_event"` 来配置子流水线作业为合并请求流水线运行。相反，应使用 `if: $CI_MERGE_REQUEST_ID` 将子流水线作业设置为仅在父流水线是合并请求流水线时运行。父流水线的 [`CI_MERGE_REQUEST_*` 预定义变量](../variables/predefined_variables.md#predefined-variables-for-merge-request-pipelines)会传递给子流水线作业。

<a id="specify-a-branch-for-multi-project-pipelines"></a>

### 为多项目流水线指定分支

触发多项目流水线时，您可以指定要使用的分支。极狐GitLab 使用分支头部的提交来创建下游流水线。例如：

```yaml
staging:
  stage: deploy
  trigger:
    project: my/deployment
    branch: stable-11-2
```

使用：

- `project` 关键字指定下游项目的完整路径。您可以使用[变量扩展](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- `branch` 关键字指定由 `project` 指定的项目中的分支或[标签](../../user/project/repository/tags/_index.md)名称。您可以使用变量扩展。

<a id="trigger-a-multi-project-pipeline-by-using-the-api"></a>

## 使用 API 触发多项目流水线

您可以在 CI/CD 作业内部使用 [CI/CD 作业令牌（`CI_JOB_TOKEN`）](../jobs/ci_job_token.md)和[流水线触发令牌 API 端点](../../api/pipeline_triggers.md#trigger-a-pipeline-with-a-token)来触发多项目流水线。极狐GitLab 将使用作业令牌触发的流水线设置为包含发起 API 调用的作业的流水线的下游流水线。

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

在[流水线详情页](_index.md#pipeline-details)中，下游流水线显示为图谱右侧的卡片列表。在此视图中，您可以：

- 选择触发作业以查看被触发的下游流水线的作业。
- 在流水线卡片上选择**展开作业** {{< icon name="chevron-lg-right" >}}，以展开视图显示下游流水线的作业。您一次只能查看一条下游流水线。
- 将鼠标悬停在流水线卡片上，以高亮显示触发下游流水线的作业。

<a id="retry-failed-and-canceled-jobs-in-a-downstream-pipeline"></a>

### 重试下游流水线中失败和已取消的作业

要重试失败和已取消的作业，请选择**重试**（{{< icon name="retry" >}}）：

- 从下游流水线的详情页。
- 在流水线图谱视图中的流水线卡片上。

<a id="recreate-a-downstream-pipeline"></a>

### 重新创建下游流水线

您可以通过重试其对应的触发作业来重新创建下游流水线。新创建的下游流水线会替换流水线图谱中的当前下游流水线。

要重新创建下游流水线：

- 在流水线图谱视图中，选择触发作业卡片上的**再次运行**（{{< icon name="retry" >}}）。

<a id="cancel-a-downstream-pipeline"></a>

### 取消下游流水线

要取消仍在运行的下游流水线，请选择**取消**（{{< icon name="cancel" >}}）：

- 从下游流水线的详情页。
- 在流水线图谱视图中的流水线卡片上。

<a id="auto-cancel-the-parent-pipeline-from-a-downstream-pipeline"></a>

### 从下游流水线自动取消父流水线

您可以将子流水线配置为在其某个作业失败时立即[自动取消](../yaml/_index.md#workflowauto_cancelon_job_failure)。

仅当满足以下条件时，父流水线才会在子流水线中的作业失败时自动取消：

- 父流水线也设置为在作业失败时自动取消。
- 触发作业配置了 [`strategy: mirror`](../yaml/_index.md#triggerstrategy)。

例如：

- `.gitlab-ci.yml`的内容：

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

- `child-pipeline.yml`的内容

  ```yaml
  # Contents of child-pipeline.yml
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
1. 子流水线已被取消，因此父流水线被自动取消

<a id="mirror-the-status-of-a-downstream-pipeline-in-the-trigger-job"></a>

### 在触发作业中镜像下游流水线的状态

您可以使用 [`trigger: strategy`](../yaml/_index.md#triggerstrategy) 在触发作业中镜像下游流水线的状态：

使用 `strategy: mirror` 时，触发作业始终具有与下游流水线相同的状态。

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

不建议使用 `strategy: depend`，因为触发作业的状态并不总是与下游流水线的状态匹配。请参阅 [`trigger:strategy` 参考中的其他详细信息](../yaml/_index.md#triggerstrategy)。

<a id="view-multi-project-pipelines-in-pipeline-graphs"></a>

### 在流水线图谱中查看多项目流水线

触发多项目流水线后，下游流水线显示在[流水线图谱](_index.md#view-pipelines)的右侧。

在[流水线迷你图谱](_index.md#pipeline-mini-graphs)中，下游流水线显示在迷你图谱的右侧。

<a id="view-child-pipeline-reports-in-merge-requests"></a>

## 在合并请求中查看子流水线报告

您可以在合并请求小部件中查看和下载子流水线的报告。这提供了跨流水线层级的测试结果和质量检查的统一视图，无需手动浏览多条流水线来识别失败和漏洞。

支持来自子流水线的以下报告类型：

- 单元测试报告（JUnit）
- 代码质量报告
- Terraform 报告
- 指标报告
- 安全报告（SAST、密钥检测、依赖扫描、容器扫描、DAST、API 模糊测试）

安全报告适用于来自同一项目的子流水线、动态生成的子流水线以及由流水线执行策略创建的流水线。不支持来自[扫描执行策略](../../user/application_security/policies/scan_execution_policies.md)的报告。

来自子流水线的测试结果和[安全发现](../../user/application_security/detect/security_scanning_results.md)也会显示在父流水线的**测试**和**安全**选项卡中。

子流水线的安全发现可以触发[合并请求审批策略](../../user/application_security/policies/merge_request_approval_policies.md)。如果子流水线检测到漏洞，您可能需要额外的审批才能合并。

为确保子流水线的报告显示在合并请求小部件中，请为生成产物报告的子流水线使用 [`strategy: depend`](../yaml/_index.md#triggerstrategy) 或 [`strategy: mirror`](../yaml/_index.md#triggerstrategy)。例如：

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

如果不使用这些策略，父流水线会在子流水线完成之前结束，其报告也不会显示在合并请求中。

<a id="fetch-artifacts-from-an-upstream-pipeline"></a>

## 从上游流水线获取产物

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< tabs >}}

{{< tab title="父子流水线" >}}

使用 [`needs:pipeline:job`](../yaml/_index.md#needspipelinejob) 从上游流水线获取产物：

1. 在上游流水线中，使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字将产物保存在作业中，然后使用触发作业触发下游流水线：

   ```yaml
   build_artifacts:
     stage: build
     script:
       - echo "This is a test artifact!" >> artifact.txt
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

先决条件：

- 下游项目已添加到上游项目的[作业令牌范围允许名单](../jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)中。
- 触发下游流水线的用户至少具有上游项目中的 [Reporter 角色](../../user/permissions.md#project-cicd)。将项目添加到允许名单并不会授予此访问权限。

使用 [`needs:project`](../yaml/_index.md#needsproject) 从上游流水线获取产物：

1. 在上游流水线中，使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字将产物保存在作业中，然后使用触发作业触发下游流水线：

   ```yaml
   build_artifacts:
     stage: build
     script:
       - echo "This is a test artifact!" >> artifact.txt
     artifacts:
       paths:
         - artifact.txt

   deploy:
     stage: deploy
     trigger: my/downstream_project   # Path to the project to trigger a pipeline in
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
> 请确保上游作业在下游作业开始之前完成，否则您将无法获取产物。
> 使用 [`needs`](../yaml/_index.md#needs) 让下游作业等待上游作业。
>
> 有关更多信息，请参阅[议题 356016](https://gitlab.com/gitlab-org/gitlab/-/issues/356016)。

<a id="fetch-artifacts-from-an-upstream-merge-request-pipeline"></a>

### 从上游合并请求流水线获取产物

当您使用 `needs:project` 来[将产物传递给下游流水线](#fetch-artifacts-from-an-upstream-pipeline)时，`ref`的值通常是分支名称，如 `main` 或 `development`。

对于[合并请求流水线](merge_request_pipelines.md)，`ref` 值的格式为 `refs/merge-requests/<id>/head`，其中 `id` 是合并请求 ID。您可以使用 [`CI_MERGE_REQUEST_REF_PATH`](../variables/predefined_variables.md#predefined-variables-for-merge-request-pipelines) CI/CD 变量检索此 ref。请勿在合并请求流水线中使用分支名称作为 `ref`，因为下游流水线会尝试从最新的分支流水线获取产物。

先决条件：

- 下游项目已添加到上游项目的[作业令牌范围允许名单](../jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)中。
- 触发下游流水线的用户至少具有上游项目中的 Reporter 角色。将项目添加到允许名单并不会授予此访问权限。

要从上游 `merge request` 流水线而不是 `branch` 流水线获取产物，请使用[变量继承](#pass-yaml-defined-cicd-variables)将 `CI_MERGE_REQUEST_REF_PATH` 传递给下游流水线：

1. 在上游流水线的作业中，使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字保存产物。
1. 在触发下游流水线的作业中，传递 `$CI_MERGE_REQUEST_REF_PATH` 变量：

   ```yaml
   build_artifacts:
     rules:
       - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
     stage: build
     script:
       - echo "This is a test artifact!" >> artifact.txt
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

1. 在下游流水线的作业中，使用 `needs:project` 和传递的变量作为 `ref` 来获取上游流水线的产物：

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

您可以使用 [`inputs`](../inputs/_index.md) 关键字向下游流水线传递输入值。与变量相比，输入具有类型检查、通过选项进行验证、描述和默认值等优势。

首先，使用 `spec:inputs` 在目标配置文件中定义输入参数：

```yaml
# Target pipeline configuration
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

## 向下游流水线传递 CI/CD 变量

您可以根据变量的创建或定义位置，使用几种不同的方法将 [CI/CD 变量](../variables/_index.md)传递给下游流水线。

<a id="pass-yaml-defined-cicd-variables"></a>

### 传递 YAML 定义的 CI/CD 变量

> [!note]
> 对于流水线配置，建议使用输入而不是变量，因为它们提供了更高的安全性和灵活性。

您可以使用 `variables` 关键字将 CI/CD 变量传递给下游流水线。这些变量在[变量优先级](../variables/_index.md#cicd-variable-precedence)中属于流水线变量。

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

您可以使用 [`inherit:variables`](../yaml/_index.md#inheritvariables) 阻止默认 CI/CD 变量传递到下游流水线。您可以列出要继承的特定变量，或阻止所有默认变量。

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

`DEFAULT_VAR` 变量在被触发的流水线中不可用，但 `JOB_VAR` 可用。

<a id="pass-a-predefined-variable"></a>

### 传递预定义变量

要使用[预定义 CI/CD 变量](../variables/predefined_variables.md)传递有关上游流水线的信息，请使用插值。将预定义变量保存为触发作业中的新作业变量，该变量会传递给下游流水线。例如：

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

`UPSTREAM_BRANCH` 变量包含上游流水线的 `$CI_COMMIT_REF_NAME` 预定义 CI/CD 变量的值，该变量在下游流水线中可用。

请勿使用此方法将[掩码变量](../variables/_index.md#mask-a-cicd-variable)传递给多项目流水线。CI/CD 掩码配置不会传递给下游流水线，该变量可能会在下游项目的作业日志中取消掩码。

您不能使用此方法将[仅作业变量](../variables/predefined_variables.md#variable-availability)转发到下游流水线，因为它们在触发作业中不可用。

上游流水线优先于下游流水线。如果上游和下游项目中定义了两个同名变量，则上游项目中定义的变量优先。

<a id="pass-dotenv-variables-created-in-a-job"></a>

### 传递作业中创建的 dotenv 变量

您可以通过 dotenv 变量继承将变量传递给下游流水线。

有关更多信息，请参阅[将变量传递给下游流水线](../variables/dotenv_variables.md#pass-variables-to-downstream-pipelines)。

<a id="control-what-type-of-variables-to-forward-to-downstream-pipelines"></a>

### 控制转发到下游流水线的变量类型

使用 [`trigger:forward` 关键字](../yaml/_index.md#triggerforward)指定要转发到下游流水线的变量类型。转发的变量被视为触发变量，具有[最高优先级](../variables/_index.md#cicd-variable-precedence)。

<a id="downstream-pipelines-for-deployments"></a>

## 用于部署的下游流水线

您可以将 [`environment`](../yaml/_index.md#environment) 关键字与 [`trigger`](../yaml/_index.md#trigger) 一起使用。如果您的部署项目和应用项目是分开管理的，您可能希望在触发作业中使用 `environment`。

```yaml
deploy:
  trigger:
    project: project-group/my-downstream-project
  environment: production
```

下游流水线可以预配基础设施、部署到指定环境，并将部署状态返回给上游项目。

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
