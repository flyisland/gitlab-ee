---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 调试 CI/CD 流水线
description: 配置验证、警告、错误和故障排除。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了多种工具，帮助您更轻松地调试 CI/CD 配置。

如果您无法解决流水线问题，可以通过以下渠道获取帮助：

- [极狐GitLab 社区论坛](https://forum.gitlab.cn/)
- 极狐GitLab [支持](https://gitlab.cn/support)

如果您在使用特定 CI/CD 功能时遇到问题，请参阅该功能相关的故障排除章节：

- [缓存](caching/_index.md#troubleshooting)
- [CI/CD 作业令牌](jobs/ci_job_token.md#troubleshooting)
- [容器镜像仓库](../user/packages/container_registry/troubleshoot_container_registry.md)
- [Docker](docker/docker_build_troubleshooting.md)
- [下游流水线](pipelines/downstream_pipelines_troubleshooting.md)
- [环境](environments/_index.md#troubleshooting)
- [极狐GitLab Runner](https://gitlab.cn/docs/runner/faq/)
- [ID 令牌](secrets/id_token_authentication.md#troubleshooting)
- [作业](jobs/job_troubleshooting.md)
- [作业产物](jobs/job_artifacts_troubleshooting.md)
- [合并请求流水线](pipelines/mr_pipeline_troubleshooting.md)、
  [合并结果流水线](pipelines/merged_results_pipelines.md#troubleshooting)
  和[合并列车](pipelines/merge_trains.md#troubleshooting)
- [流水线编辑器](pipeline_editor/_index.md#troubleshooting)
- [变量](variables/variables_troubleshooting.md)
- [YAML `includes` 关键字](yaml/includes.md#troubleshooting)
- [YAML `script` 关键字](yaml/script_troubleshooting.md)

<a id="debugging-techniques"></a>

## 调试技巧

<a id="verify-syntax"></a>

### 验证语法

问题的早期来源可能是语法错误。如果发现任何语法或格式问题，流水线会显示 `yaml invalid` 徽章，并且不会开始运行。

<a id="edit-gitlab-ciyml-with-the-pipeline-editor"></a>

#### 使用流水线编辑器编辑 `.gitlab-ci.yml`

[流水线编辑器](pipeline_editor/_index.md)是推荐的编辑体验（而非单文件编辑器或 Web IDE）。它包括：

- 代码补全建议，确保您只使用被接受的关键字。
- 自动语法高亮和验证。
- [CI/CD 配置可视化](pipeline_editor/_index.md#visualize-cicd-configuration)，
  以图形方式展示您的 `.gitlab-ci.yml` 文件。

<a id="edit-gitlab-ciyml-locally"></a>

#### 在本地编辑 `.gitlab-ci.yml`

如果您更倾向于在本地编辑流水线配置，可以在编辑器中使用
极狐GitLab CI/CD schema 来验证基本语法问题。任何
[支持 Schemastore 的编辑器](https://www.schemastore.org/)默认都会使用
极狐GitLab CI/CD schema。

如果您需要直接链接到该 schema，请使用以下 URL：

```plaintext
https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/assets/javascripts/editor/schema/ci.json
```

要查看 CI/CD schema 涵盖的自定义标签的完整列表，请查看该 schema 的最新版本。

<a id="verify-syntax-with-ci-lint-tool"></a>

#### 使用 CI Lint 工具验证语法

您可以使用 [CI Lint 工具](yaml/lint.md)来验证 CI/CD 配置片段的语法是否正确。粘贴完整的 `.gitlab-ci.yml` 文件或单个作业配置，即可验证基本语法。

当项目中存在 `.gitlab-ci.yml` 文件时，您还可以使用 CI Lint 工具来[模拟创建完整的流水线](yaml/lint.md#simulate-a-pipeline)。它会对配置语法进行更深入的验证。

<a id="use-pipeline-names"></a>

### 使用流水线名称

使用 [`workflow:name`](yaml/_index.md#workflowname) 为您的所有流水线类型命名，这样可以更轻松地在流水线列表中识别流水线。例如：

```yaml
variables:
  PIPELINE_NAME: "Default pipeline name"

workflow:
  name: '$PIPELINE_NAME'
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      variables:
        PIPELINE_NAME: "Merge request pipeline"
    - if: '$CI_PIPELINE_SOURCE == "schedule" && $PIPELINE_SCHEDULE_TYPE == "hourly_deploy"'
      variables:
        PIPELINE_NAME: "Hourly deployment pipeline"
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
      variables:
        PIPELINE_NAME: "Other scheduled pipeline"
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
      variables:
        PIPELINE_NAME: "Default branch pipeline"
    - if: '$CI_COMMIT_BRANCH =~ /^\d{1,2}\.\d{1,2}-stable$/'
      variables:
        PIPELINE_NAME: "Stable branch pipeline"
```

<a id="cicd-variables"></a>

### CI/CD 变量

<a id="verify-variables"></a>

#### 验证变量

CI/CD 故障排除的一个关键部分是验证流水线中存在哪些变量，以及它们的值是什么。许多流水线配置都依赖于变量，验证变量是找到问题来源的最快方法之一。

[导出每个有问题的作业中可用的完整变量列表](variables/variables_troubleshooting.md#list-all-variables)。检查您期望的变量是否存在，并检查它们的值是否符合预期。

<a id="use-variables-to-add-flags-to-cli-commands"></a>

#### 使用变量为 CLI 命令添加标志

您可以定义在标准流水线运行中不使用、但可以按需用于调试的 CI/CD 变量。如果您添加了一个变量，可以在手动运行[流水线](pipelines/_index.md#run-a-pipeline-manually)或[单个作业](jobs/job_control.md#run-a-manual-job)时设置其值，以修改命令的行为。例如：

```yaml
my-flaky-job:
  variables:
    DEBUG_VARS: ""
  script:
    - my-test-command $DEBUG_VARS /test-dirs
```

在此示例中，`DEBUG_VARS` 在标准流水线中默认为空。如果您需要调试作业的行为，请手动运行流水线并将 `DEBUG_VARS` 设置为 `--verbose` 以获取额外输出。

<a id="dependencies"></a>

### 依赖项

依赖项相关问题是流水线中另一类常见的意外问题来源。

<a id="verify-dependency-versions"></a>

#### 验证依赖项版本

要验证作业中使用的依赖项版本是否正确，您可以在运行主脚本命令之前输出它们。例如：

```yaml
job:
  before_script:
    - node --version
    - yarn --version
  script:
    - my-javascript-tests.sh
```

<a id="pin-versions"></a>

#### 固定版本

虽然您可能希望始终使用依赖项或镜像的最新版本，但更新可能会意外引入破坏性变更。请考虑固定关键依赖项和镜像的版本，以避免意外变更。例如：

```yaml
variables:
  ALPINE_VERSION: '3.18.6'

job1:
  image: alpine:$ALPINE_VERSION  # This will never change unexpectedly
  script:
    - my-test-script.sh

job2:
  image: alpine:latest  # This might suddenly change
  script:
    - my-test-script.sh
```

您仍应定期检查依赖项和镜像的更新，因为可能存在重要的安全更新。然后，您可以手动更新版本，作为验证更新后的镜像或依赖项仍能与您的流水线正常配合使用的流程的一部分。

<a id="verify-job-output"></a>

### 验证作业输出

<a id="make-output-verbose"></a>

#### 使输出更详细

您可以使用 `--silent` 来减少作业日志中的输出量。但是，这可能会使识别作业中出错的位置变得困难。请尽可能考虑使用 `--verbose`，它会显示有关命令正在执行的操作的更多详细信息。

```yaml
job1:
  script:
    - my-test-tool --silent         # If this fails, it might be impossible to identify the issue.
    - my-other-test-tool --verbose  # This command will likely be easier to debug.
```

<a id="save-output-and-reports-as-artifacts"></a>

#### 将输出和报告保存为产物

某些工具可能会生成仅在作业运行期间需要的文件，但这些文件的内容可用于调试。您可以使用 [`artifacts`](yaml/_index.md#artifacts) 将它们保存起来以供后续分析：

```yaml
job1:
  script:
    - my-tool --json-output my-output.json
  artifacts:
    paths:
      - my-output.json
```

使用 [`artifacts:reports`](yaml/artifacts_reports.md) 配置的报告默认不可下载，但也可能包含有助于调试的信息。使用相同的技巧使这些报告可供检查：

```yaml
job1:
  script:
    - rspec --format RspecJunitFormatter --out rspec.xml
  artifacts:
    reports:
      junit: rspec.xml
    paths:
      - rspec.xmp
```

> [!warning]
> 请勿在产物中保存令牌、密码或其他敏感信息，
> 因为任何有权访问流水线的用户都可以查看这些信息。

<a id="run-the-jobs-commands-locally"></a>

### 在本地运行作业的命令

您可以使用 [Rancher Desktop](https://rancherdesktop.io/) 或类似替代工具
在本地机器上运行作业的容器镜像。然后，在容器中运行作业的 `script` 命令并验证其行为。

<a id="troubleshoot-a-failed-job-with-root-cause-analysis"></a>

### 使用根因分析排查失败的作业

您可以在极狐GitLab Duo Chat 中使用极狐GitLab Duo 根因分析来[排查失败的 CI/CD 作业](../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)。

<a id="job-configuration-issues"></a>

## 作业配置问题

许多常见的流水线问题都可以通过分析 `rules` 或 `only/except` 配置的行为来修复。此配置用于[控制作业何时被添加到流水线](jobs/job_control.md)。您不应在同一个流水线中同时使用这两种配置，因为它们的行为不同。在这种混合行为下，很难预测流水线会如何运行。`rules` 是控制作业的首选方式，因为 `only` 和 `except` 已不再积极开发。

如果您的 `rules` 或 `only/except` 配置使用了[预定义变量](variables/predefined_variables.md)，例如 `CI_PIPELINE_SOURCE`、`CI_MERGE_REQUEST_ID`，您应该首先[验证它们](#verify-variables)作为故障排除的第一步。

<a id="jobs-or-pipelines-dont-run-when-expected"></a>

### 作业或流水线未按预期运行

`rules` 或 `only/except` 关键字决定了作业是否会被添加到流水线中。如果流水线运行了，但某个作业没有被添加到流水线中，通常是由于 `rules` 或 `only/except` 配置问题。

如果流水线似乎根本没有运行，也没有错误消息，也可能是由于 `rules` 或 `only/except` 配置，或 `workflow: rules` 关键字。

如果您正在从 `only/except` 转换为 `rules` 关键字，您应该仔细检查 [`rules` 配置详情](yaml/_index.md#rules)。`only/except` 和 `rules`的行为不同，在两者之间迁移时可能会导致意外行为。

[`rules`的常见 `if` 子句](jobs/job_rules.md#common-if-clauses-with-predefined-variables)对于编写符合您预期行为的规则示例非常有帮助。

如果流水线只包含 `.pre` 或 `.post` 阶段中的作业，则它不会运行。必须至少有一个其他阶段中的作业。

<a id="unexpected-behavior-when-gitlab-ciyml-file-contains-a-byte-order-mark-bom"></a>

### `.gitlab-ci.yml` 文件包含字节顺序标记（BOM）时的意外行为

`.gitlab-ci.yml` 文件或其他包含的配置文件中存在 [UTF-8 字节顺序标记（BOM）](https://en.wikipedia.org/wiki/Byte_order_mark)可能会导致错误的流水线行为。字节顺序标记会影响文件的解析。因此，某些配置可能会被忽略，作业可能会缺失，变量也可能具有错误的值。某些文本编辑器如果配置为这样做，可能会插入 BOM 字符。

如果您的流水线出现令人困惑的行为，您可以使用能够显示这些字符的工具来检查是否存在 BOM 字符。流水线编辑器无法显示这些字符，因此您必须使用外部工具。有关更多详细信息，请参阅[议题 354026](https://gitlab.com/gitlab-org/gitlab/-/issues/354026)。

<a id="a-job-with-the-changes-keyword-runs-unexpectedly"></a>

### 带有 `changes` 关键字的作业意外运行

作业被意外添加到流水线的一个常见原因是 `changes` 关键字在某些情况下始终评估为 true。例如，`changes` 在某些流水线类型中始终为 true，包括定时流水线和标签的流水线。

`changes` 关键字与 [`only/except`](yaml/deprecated_keywords.md#onlychanges--exceptchanges) 或 [`rules`](yaml/_index.md#ruleschanges) 结合使用。建议仅将 `changes` 与 `rules` 或 `only/except` 配置中的 `if` 部分一起使用，以确保作业仅被添加到分支流水线或合并请求流水线。

<a id="two-pipelines-run-at-the-same-time"></a>

### 两个流水线同时运行

当向具有关联的开放合并请求的分支推送提交时，可能会运行两个流水线。通常一个流水线是合并请求流水线，另一个是分支流水线。

这种情况通常是由 `rules` 配置引起的，有几种方法可以[防止重复的流水线](jobs/job_rules.md#avoid-duplicate-pipelines)。

<a id="no-pipeline-or-the-wrong-type-of-pipeline-runs"></a>

### 没有流水线运行或运行了错误类型的流水线

在流水线可以运行之前，极狐GitLab 会评估配置中的所有作业，并尝试将它们添加到所有可用的流水线类型中。如果在评估结束时没有作业被添加到流水线中，则流水线不会运行。

如果流水线没有运行，很可能是所有作业的 `rules` 或 `only/except` 配置阻止了它们被添加到流水线中。

如果运行了错误类型的流水线，则应检查 `rules` 或 `only/except` 配置，以确保作业被添加到正确的流水线类型中。例如，如果合并请求流水线没有运行，则作业可能被添加到了分支流水线中。

也有可能是您的 [`workflow: rules`](yaml/_index.md#workflow) 配置阻止了流水线，或允许了错误类型的流水线。

如果您正在使用拉取镜像，可以查看[拉取镜像流水线的故障排除条目](../user/project/repository/mirror/troubleshooting.md#pull-mirroring-is-not-triggering-pipelines)。

<a id="pipeline-with-many-jobs-fails-to-start"></a>

### 包含大量作业的流水线无法启动

如果流水线的作业数量超过实例定义的 [CI/CD 限制](../administration/cicd/limits.md#maximum-number-of-jobs-in-a-pipeline)，则该流水线无法启动。

要减少单个流水线中的作业数量，您可以将 `.gitlab-ci.yml` 配置拆分为更多独立的[父子流水线](pipelines/pipeline_architectures.md#parent-child-pipelines)。

<a id="pipeline-warnings"></a>

## 流水线警告

在以下情况下会显示流水线配置警告：

- [使用 CI Lint 工具验证配置](yaml/lint.md)。
- [手动运行流水线](pipelines/_index.md#run-a-pipeline-manually)。

<a id="job-may-allow-multiple-pipelines-to-run-for-a-single-action-warning"></a>

### `Job may allow multiple pipelines to run for a single action` 警告

当您使用带有 `when` 子句但没有 `if` 子句的 [`rules`](yaml/_index.md#rules) 时，可能会运行多个流水线。通常，当您向具有关联的开放合并请求的分支推送提交时，会发生这种情况。

要[防止重复的流水线](jobs/job_rules.md#avoid-duplicate-pipelines)，请使用 [`workflow: rules`](yaml/_index.md#workflow) 或重写您的规则来控制哪些流水线可以运行。

<a id="pipeline-errors"></a>

## 流水线错误

<a id="error-identity-verification-is-required-in-order-to-run-ci-jobs"></a>

### 错误：`Identity verification is required in order to run CI jobs`

{{< details >}}

- Tier: 基础版
- Offering: JihuLab.com

{{< /details >}}

在 JihuLab.com 上使用极狐GitLab 托管的 Runner 且使用基础版套餐时，
如果您看到错误消息 `Identity verification is required in order to run CI jobs`，则必须完成身份验证。

此要求有助于防止免费计算资源的滥用。根据您的风险评分，您可能需要验证您的电子邮件、电话号码或添加付款方式。有关更多信息，请参阅[身份验证](../security/identity_verification.md)。

要完成验证：

1. 在警报横幅中，选择**验证我的账号**。
1. 出现提示时，按照身份验证步骤操作。
   您可能需要验证您的电话号码或添加付款方式。
1. 创建新提交或手动触发新的流水线。

或者，您可以：

- 升级到付费套餐。
- 为您的命名空间购买额外的计算分钟数。
- 使用项目或群组 Runner，而不是极狐GitLab 托管的 Runner。
- 请您的群组所有者设置私有化部署 Runner。

<a id="a-cicd-pipeline-must-run-and-be-successful-before-merge-message"></a>

### `A CI/CD pipeline must run and be successful before merge` 消息

如果项目中启用了[**流水线必须成功**](../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)设置，并且流水线尚未成功运行，则会显示此消息。如果流水线尚未创建，或者您正在等待外部 CI 服务，此消息同样适用。

如果您的项目不使用流水线，则应禁用**流水线必须成功**，以便可以接受合并请求。

<a id="checking-ability-to-merge-automatically-message"></a>

### `Checking ability to merge automatically` 消息

如果您的合并请求卡在 `Checking ability to merge automatically` 消息上，且几分钟后仍未消失，您可以尝试以下变通方法之一：

- 刷新合并请求页面。
- 关闭并重新打开合并请求。
- 使用 [`/rebase` 快速操作](../user/project/quick_actions.md#rebase)对合并请求进行变基。
- 如果您已经确认合并请求可以合并，可以使用
  `/merge` 快速操作来合并它。

<a id="checking-pipeline-status-message"></a>

### `Checking pipeline status` 消息

当合并请求的最新提交尚未关联流水线时，会显示此消息并带有旋转状态图标（{{< icon name="spinner" >}}）。这可能是因为：

- 极狐GitLab 尚未完成流水线的创建。
- 您正在使用外部 CI 服务，极狐GitLab 尚未收到该服务的反馈。
- 您的项目未使用 CI/CD 流水线。
- 您的项目使用了 CI/CD 流水线，但您的配置阻止了流水线在合并请求的源分支上运行。
- 最新的流水线已被删除（这是一个[已知问题](https://gitlab.com/gitlab-org/gitlab/-/issues/214323)）。
- 合并请求的源分支位于私有 fork 上。

创建流水线后，消息会更新为流水线状态。

在某些情况下，如果启用了[**流水线必须成功**](../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)设置，此消息可能会卡住并无限旋转图标。有关更多详细信息，请参阅[议题 334281](https://gitlab.com/gitlab-org/gitlab/-/issues/334281)。

<a id="project--not-found-or-access-denied-message"></a>

### `Project <group/project> not found or access denied` 消息

如果使用 [`include`](yaml/_index.md#include) 添加了配置，并且出现以下任一情况，则会显示此消息：

- 配置引用了无法找到的项目。
- 运行流水线的用户无法访问任何被包含的项目。

要解决此问题，请检查：

- 项目路径的格式为 `my-group/my-project`，并且不包含
  代码仓库中的任何文件夹。
- 运行流水线的用户是包含被包含文件的[项目成员](../user/project/members/_index.md#add-users-to-a-project)。
  用户还必须拥有在相同项目中运行 CI/CD 作业的[权限](../user/permissions.md#project-cicd)。

<a id="the-parsed-yaml-is-too-big-message"></a>

### `The parsed YAML is too big` 消息

当 YAML 配置过大或嵌套过深时，会显示此消息。包含大量 include 且总行数达数千行的 YAML 文件更有可能达到此内存限制。例如，一个 200 kb 的 YAML 文件很可能会达到默认内存限制。

要减小配置大小，您可以：

- 在流水线编辑器的[完整配置](pipeline_editor/_index.md#view-full-configuration)选项卡中检查展开后的 CI/CD 配置的长度。
  查找可以删除或简化的重复配置。
- 将冗长或重复的 `script` 部分移到项目中的独立脚本中。
- 使用[父子和子流水线](pipelines/downstream_pipelines.md#parent-child-pipelines)将部分
  工作移到独立子流水线中的作业中。

在极狐GitLab 私有化部署上，您可以[增大大小限制](../administration/cicd/limits.md#maximum-size-and-depth-of-cicd-configuration-yaml-files)。

<a id="500-error-when-editing-the-gitlab-ciyml-file"></a>

### 编辑 `.gitlab-ci.yml` 文件时出现 `500` 错误

使用 [Web 编辑器](../user/project/repository/web_editor.md)编辑 `.gitlab-ci.yml` 文件时，包含的配置文件形成循环引用可能会导致 `500` 错误。

请确保被包含的配置文件不会形成相互引用的循环。

<a id="failed-to-pull-image-messages"></a>

### `Failed to pull image` 消息

当 Runner 尝试在 CI/CD 作业中拉取容器镜像时，可能会返回 `Failed to pull image` 消息。

当使用 [`image`](yaml/_index.md#image) 定义的容器镜像来自另一个项目的容器镜像仓库时，Runner 会使用 [CI/CD 作业令牌](jobs/ci_job_token.md)进行身份验证。

如果作业令牌设置阻止了对另一个项目容器镜像仓库的访问，Runner 会返回错误消息。

例如：

- ```plaintext
  WARNING: Failed to pull image with policy "always": Error response from daemon: pull access denied for registry.example.com/path/to/project, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
  ```

- ```plaintext
  WARNING: Failed to pull image with policy "": image pull failed: rpc error: code = Unknown desc = failed to pull and unpack image "registry.example.com/path/to/project/image:v1.2.3": failed to resolve reference "registry.example.com/path/to/project/image:v1.2.3": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
  ```

如果以下两种情况同时成立，则可能出现这些错误：

- 托管镜像的私有项目中启用了[**限制对此项目的访问**](jobs/ci_job_token.md#limit-job-token-scope-for-public-or-internal-projects)
  选项。
- 尝试拉取镜像的作业运行在未列入该私有项目允许名单的项目中。

要解决此问题，请将任何具有从容器镜像仓库拉取镜像的 CI/CD 作业的项目添加到目标项目的[作业令牌允许名单](jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)中。

当尝试使用[项目访问令牌](../user/project/settings/project_access_tokens.md)访问另一个项目中的镜像时，也可能出现这些错误。项目访问令牌的作用域仅限于一个项目，因此无法访问其他项目中的镜像。您必须使用具有更广泛作用域的[其他令牌类型](../security/tokens/_index.md)。

<a id="random-or-intermittent-failed-to-pull-image-errors"></a>

#### 随机或间歇性的 `Failed to pull image` 错误

您可能会在 CI/CD 作业中遇到间歇性的 `Failed to pull image` 错误。

当用户访问镜像的权限不同，并且与 Runner 缓存这些镜像的方式相结合时，可能会出现此问题。机器人用户通常会受到影响，因为他们的权限通常与其他项目成员不同。

例如，您的流水线镜像可能托管在另一个项目的容器镜像仓库中。如果所有用户都可以访问这两个项目，则这不是问题。但是，如果某个用户（例如机器人用户）无法访问托管镜像的项目，他们可能会收到 `Failed to pull image` 错误。

当 Runner 为有权访问镜像的用户成功拉取并缓存镜像后，错误就会变得间歇性。此时该 Runner 已经拥有该镜像，无需访问另一个项目来拉取镜像。所有用户，包括无权访问另一个项目的用户，都可以使用此镜像运行 CI/CD 作业。但是，如果 Runner 从未拉取并缓存过该镜像，则无权访问镜像项目的用户会收到 `Failed to pull image` 错误。

要解决此问题，请确保所有运行流水线的用户（包括机器人用户）都可以访问托管所拉取镜像的项目。

<a id="something-went-wrong-on-our-end-message-or-500-error-when-running-a-pipeline"></a>

### 运行流水线时出现 `Something went wrong on our end` 消息或 `500` 错误

您可能会收到以下流水线错误：

- 推送或创建合并请求时出现 `Something went wrong on our end` 消息。
- 使用 API 触发流水线时出现 `500` 错误。

如果项目导入后内部 ID 记录不同步，则可能出现这些错误。

要解决此问题，请参阅[议题 352382 中的变通方法](https://gitlab.com/gitlab-org/gitlab/-/issues/352382#workaround)。

<a id="config-should-be-an-array-of-hashes-error-message"></a>

### `config should be an array of hashes` 错误消息

在数组中使用多个 [`!reference` 标签](yaml/yaml_optimization.md#reference-tags)时，您可能会看到类似以下的错误：

```plaintext
This GitLab CI configuration is invalid: jobs:my_job_name:parallel:matrix config should be an array of hashes.
```

虽然 `script`、`rules` 和 `stages` 关键字支持使用多个引用标签，但其他期望数组的关键字则不支持。您可以[使用嵌套来绕过此限制](https://gitlab.com/gitlab-org/gitlab/-/issues/439828#note_1918858137)，或改用 [YAML 锚点](yaml/yaml_optimization.md#anchors)。

<a id="error-jobsjob-name-config-should-contain-either-a-trigger-or-a-needspipeline"></a>

### 错误：`jobs:<job-name> config should contain either a trigger or a needs:pipeline.`

当您的 `.gitlab-ci.yml`中的作业使用了 `needs` 关键字，但没有使用 `script:` 或 `trigger:` 关键字时，可能会出现此错误。

每个作业都必须使用 `script` 或 `trigger` 关键字之一，因此请为任何未使用这两个关键字的作业添加适当的关键字。

<a id="error-config-contains-unknown-keys-key-name"></a>

### 错误：`config contains unknown keys: <key-name>`

您可能会收到类似 `<keyword> config contains unknown keys: <key-name>` 的错误。

此错误消息可能由以下几个问题引起：

- 关键字拼写错误，例如使用 `imag`（无效）而不是 `image`（有效）。
- 关键字或作业的空格或缩进不正确。

例如：

```yaml
test-job:
  artifacts:
    path:        # This is a typo, it should be `paths`
      - test
    image: test  # This indentation is incorrect, it should be at the same level as `script`.
  script:
    - echo
```
