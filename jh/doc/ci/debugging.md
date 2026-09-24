---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 调试 CI/CD 流水线
description: Configuration validation, warnings, errors, and troubleshooting.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了多种工具，帮助你更轻松地调试 CI/CD 配置。

如果你无法解决流水线问题，可以从以下渠道获取帮助：

- [极狐GitLab 社区论坛](https://forum.gitlab.com/)
- 极狐GitLab [支持](https://gitlab.cn/support/)

如果你在使用特定 CI/CD 功能时遇到问题，请参阅相关功能的故障排除部分：

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
- [合并请求流水线](pipelines/mr_pipeline_troubleshooting.md)
  [合并结果流水线](pipelines/merged_results_pipelines.md#troubleshooting) 和 [合并队列](pipelines/merge_trains.md#troubleshooting)
- [流水线编辑器](pipeline_editor/_index.md#troubleshooting)
- [变量](variables/variables_troubleshooting.md)
- [YAML `includes` 关键字](yaml/includes.md#troubleshooting)
- [YAML `script` 关键字](yaml/script_troubleshooting.md)

<a id="debugging-techniques"></a>

## 调试技巧

<a id="verify-syntax"></a>

### 验证语法

问题的一个早期来源可能是语法不正确。如果发现任何语法或格式问题，流水线会显示 `yaml invalid` 徽章并且不会启动运行。

<a id="edit-gitlab-ciyml-with-the-pipeline-editor"></a>

#### 使用流水线编辑器编辑 `.gitlab-ci.yml`

[流水线编辑器](pipeline_editor/_index.md) 是推荐的编辑体验（而不是单文件编辑器或 Web IDE）。它包括：

- 代码补全建议，确保你只使用被接受的关键字。
- 自动语法高亮和验证。
- [CI/CD 配置可视化](pipeline_editor/_index.md#visualize-ci-configuration)，即你的 `.gitlab-ci.yml` 文件的图形化表示。

<a id="edit-gitlab-ciyml-locally"></a>

#### 在本地编辑 `.gitlab-ci.yml`

如果你更喜欢在本地编辑流水线配置，可以使用编辑器中的极狐GitLab CI/CD schema 来验证基本的语法问题。任何[支持 Schemastore 的编辑器](https://www.schemastore.org/) 默认使用极狐GitLab CI/CD schema。

如果你需要直接链接到 schema，请使用此 URL：

```plaintext
https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/assets/javascripts/editor/schema/ci.json
```

要查看 CI/CD schema 覆盖的自定义标签的完整列表，请检查 schema 的最新版本。

<a id="verify-syntax-with-ci-lint-tool"></a>

#### 使用 CI Lint 工具验证语法

你可以使用 [CI Lint 工具](yaml/lint.md) 来验证 CI/CD 配置片段的语法是否正确。粘贴完整的 `.gitlab-ci.yml` 文件或单独的作业配置，以验证基本语法。

当项目中存在 `.gitlab-ci.yml` 文件时，你还可以使用 CI Lint 工具[模拟创建完整流水线](yaml/lint.md#simulate-a-pipeline)。它对配置语法进行更深入的验证。

<a id="use-pipeline-names"></a>

### 使用流水线名称

使用 [`workflow:name`](yaml/_index.md#workflowname) 为所有流水线类型命名，这样可以更轻松地在流水线列表中识别流水线。例如：

```yaml
variables:
  PIPELINE_NAME: "默认流水线名称"

workflow:
  name: '$PIPELINE_NAME'
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      variables:
        PIPELINE_NAME: "合并请求流水线"
    - if: '$CI_PIPELINE_SOURCE == "schedule" && $PIPELINE_SCHEDULE_TYPE == "hourly_deploy"'
      variables:
        PIPELINE_NAME: "每小时部署流水线"
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
      variables:
        PIPELINE_NAME: "其他调度流水线"
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
      variables:
        PIPELINE_NAME: "默认分支流水线"
    - if: '$CI_COMMIT_BRANCH =~ /^\d{1,2}\.\d{1,2}-stable$/'
      variables:
        PIPELINE_NAME: "稳定分支流水线"
```

<a id="cicd-variables"></a>

### CI/CD 变量

<a id="verify-variables"></a>

#### 验证变量

故障排除 CI/CD 的关键部分是验证流水线中存在哪些变量，以及它们的值是什么。许多流水线配置依赖于变量，验证它们是找到问题根源的最快方法之一。

[导出每个有问题作业中可用的完整变量列表](variables/variables_troubleshooting.md#list-all-variables)。检查你期望的变量是否存在，并检查它们的值是否符合你的预期。

<a id="use-variables-to-add-flags-to-cli-commands"></a>

#### 使用变量为 CLI 命令添加标志

你可以定义在标准流水线运行中不使用的 CI/CD 变量，但可以在需要时用于调试。如果你像以下示例那样添加变量，可以在手动运行[流水线](pipelines/_index.md#run-a-pipeline-manually)或[单个作业](jobs/job_control.md#run-a-manual-job)时添加它，以修改命令的行为。例如：

```yaml
my-flaky-job:
  variables:
    DEBUG_VARS: ""
  script:
    - my-test-command $DEBUG_VARS /test-dirs
```

在此示例中，在标准流水线中 `DEBUG_VARS` 默认为空。如果你需要调试作业的行为，请手动运行流水线并将 `DEBUG_VARS` 设置为 `--verbose` 以获取额外输出。

<a id="dependencies"></a>

### 依赖

<a id="verify-dependency-versions"></a>

#### 验证依赖版本

为了验证作业中使用的依赖项版本是否正确，你可以在运行主脚本命令之前输出它们。例如：

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

虽然你可能希望始终使用依赖项或镜像的最新版本，但更新可能会意外地包含破坏性更改。考虑固定关键依赖项和镜像以避免意外更改。例如：

```yaml
variables:
  ALPINE_VERSION: '3.18.6'

job1:
  image: alpine:$ALPINE_VERSION  # 这将永远不会意外更改
  script:
    - my-test-script.sh

job2:
  image: alpine:latest  # 这可能会突然更改
  script:
    - my-test-script.sh
```

你仍然应该定期检查依赖项和镜像更新，因为可能会有重要的安全更新。然后，你可以手动更新版本，作为验证更新后的镜像或依赖项是否仍然适用于你的流水线的过程的一部分。

<a id="verify-job-output"></a>

### 验证作业输出

<a id="make-output-verbose"></a>

#### 使输出详细

如果你使用 `--silent` 来减少作业日志中的输出量，可能会难以确定作业中出了什么问题。此外，在可能的情况下考虑使用 `--verbose` 来获取更多详细信息。

```yaml
job1:
  script:
    - my-test-tool --silent         # 如果此操作失败，可能无法确定问题。
    - my-other-test-tool --verbose  # 此命令可能更容易调试。
```

<a id="save-output-and-reports-as-artifacts"></a>

#### 将输出和报告保存为产物

有些工具可能会生成仅在作业运行期间需要的文件，但这些文件的内容可以用于调试。你可以使用 [`artifacts`](yaml/_index.md#artifacts) 将它们保存以供后续分析：

```yaml
job1:
  script:
    - my-tool --json-output my-output.json
  artifacts:
    paths:
      - my-output.json
```

使用 [`artifacts:reports`](yaml/artifacts_reports.md) 配置的报告默认不可下载，但可能也包含有助于调试的信息。使用相同的技术使这些报告可供检查：

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
> 不要将令牌、密码或其他敏感信息保存在产物中，因为它们可能被任何可以访问流水线的用户查看。

<a id="run-the-jobs-commands-locally"></a>

### 在本地运行作业的命令

你可以使用像 [Rancher Desktop](https://rancherdesktop.io/) 或类似替代品的工具，在你的本地机器上运行作业的容器镜像。然后，在容器中运行作业的 `script` 命令并验证行为。

<a id="troubleshoot-a-failed-job-with-root-cause-analysis"></a>

### 使用根因分析排查失败作业

你可以在极狐GitLab Duo Chat 中使用极狐GitLab Duo 根因分析，来[排查失败的 CI/CD 作业](../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)。

<a id="job-configuration-issues"></a>

## 作业配置问题

许多常见的流水线问题可以通过分析用于[控制何时将作业添加到流水线](jobs/job_control.md)的 `rules` 或 `only/except` 配置的行为来解决。你不应该在同一个流水线中同时使用这两种配置，因为它们的行为不同。这种混合行为很难预测流水线的运行方式。`rules` 是控制作业的首选，因为 `only` 和 `except` 不再被积极开发。

如果你的 `rules` 或 `only/except` 配置使用了像 `CI_PIPELINE_SOURCE`、`CI_MERGE_REQUEST_ID` 这样的[预定义变量](variables/predefined_variables.md)，你应该首先[验证它们](#verify-variables)作为故障排除的第一步。

<a id="jobs-or-pipelines-dont-run-when-expected"></a>

### 作业或流水线未按预期运行时

`rules` 或 `only/except` 关键字决定了作业是否被添加到流水线。如果流水线运行了，但作业未被添加到流水线，通常是由于 `rules` 或 `only/except` 配置问题。

如果流水线似乎根本没有运行，也没有错误消息，也可能是因为 `rules` 或 `only/except` 配置，或者 `workflow: rules` 关键字。

如果你正在从 `only/except` 转换为 `rules` 关键字，你应该仔细检查 [`rules` 配置详情](yaml/_index.md#rules)。`only/except` 和 `rules` 的行为不同，在两者之间迁移时可能会导致意外行为。

[常见的 `rules` 的 `if` 子句](jobs/job_rules.md#common-if-clauses-with-predefined-variables) 可以提供非常有帮助的示例，展示如何编写按预期方式运行的规则。

如果流水线仅包含 `.pre` 或 `.post` 阶段的作业，则不会运行。必须至少有一个在其他阶段的其他作业。

<a id="unexpected-behavior-when-gitlab-ciyml-file-contains-a-byte-order-mark-bom"></a>

### `.gitlab-ci.yml` 文件包含字节顺序标记 (BOM) 时的意外行为

`.gitlab-ci.yml` 文件或其他包含的配置文件中存在 [UTF-8 字节顺序标记 (BOM)](https://en.wikipedia.org/wiki/Byte_order_mark) 可能导致不正确的流水线行为。字节顺序标记影响文件的解析，导致某些配置被忽略——作业可能缺失，变量可能有错误的值。某些文本编辑器如果配置为这样做，可能会插入 BOM 字符。

如果你的流水线行为混乱，你可以使用能够显示它们的工具检查是否存在 BOM 字符。流水线编辑器无法显示这些字符，因此你必须使用外部工具。有关更多详细信息，请参阅 [议题 354026](https://jihulab.com/gitlab-cn/gitlab/-/issues/354026)。

<a id="a-job-with-the-changes-keyword-runs-unexpectedly"></a>

### 带有 `changes` 关键字的作业意外运行

作业意外添加到流水线的一个常见原因是，`changes` 关键字在某些情况下总是评估为 true。例如，在某些流水线类型中，包括调度流水线和标签流水线，`changes` 总是为 true。

`changes` 关键字与 [`only/except`](yaml/deprecated_keywords.md#onlychanges--exceptchanges) 或 [`rules`](yaml/_index.md#ruleschanges) 结合使用。建议只将 `changes` 与 `rules` 中的 `if` 部分或 `only/except` 配置一起使用，以确保作业仅添加到分支流水线或合并请求流水线。

<a id="two-pipelines-run-at-the-same-time"></a>

### 两个流水线同时运行

当将提交推送到关联有开放合并请求的分支时，可能会运行两个流水线。通常一个流水线是合并请求流水线，另一个是分支流水线。

这种情况通常是由 `rules` 配置引起的，有多种方法可以[防止重复流水线](jobs/job_rules.md#avoid-duplicate-pipelines)。

<a id="no-pipeline-or-the-wrong-type-of-pipeline-runs"></a>

### 没有流水线或运行了错误类型的流水线

在流水线运行之前，极狐GitLab 评估配置中的所有作业，并尝试将它们添加到所有可用的流水线类型。如果在评估结束时没有作业添加到流水线，则流水线不会运行。

如果流水线没有运行，很可能所有作业都有 `rules` 或 `only/except`，阻止它们被添加到流水线。

如果运行了错误的流水线类型，则应检查 `rules` 或 `only/except` 配置，以确保作业被添加到正确的流水线类型。例如，如果合并请求流水线没有运行，作业可能被添加到了分支流水线。

也可能是你的 [`workflow: rules`](yaml/_index.md#workflow) 配置阻止了流水线，或者允许了错误的流水线类型。

如果你使用的是拉取镜像，可以查看[拉取镜像流水线的故障排除条目](../user/project/repository/mirror/troubleshooting.md#pull-mirroring-is-not-triggering-pipelines)。

<a id="pipeline-with-many-jobs-fails-to-start"></a>

### 包含大量作业的流水线无法启动

包含的作业数量超过实例定义的 [CI/CD 限制](../administration/settings/continuous_integration.md#set-cicd-limits)的流水线无法启动。

要减少单个流水线中的作业数量，你可以将 `.gitlab-ci.yml` 配置拆分为更多独立的[父子流水线](pipelines/pipeline_architectures.md#parent-child-pipelines)。

<a id="pipeline-warnings"></a>

## 流水线警告

流水线配置警告在以下情况下显示：

- [使用 CI Lint 工具验证配置](yaml/lint.md)。
- [手动运行流水线](pipelines/_index.md#run-a-pipeline-manually)。

<a id="job-may-allow-multiple-pipelines-to-run-for-a-single-action-warning"></a>

### `作业可能允许多个流水线针对单个操作运行` 警告

当你使用带有 `when` 子句但没有 `if` 子句的 [`rules`](yaml/_index.md#rules) 时，可能会运行多个流水线。通常，当你将提交推送到关联有开放合并请求的分支时会发生这种情况。

要[防止重复流水线](jobs/job_rules.md#avoid-duplicate-pipelines)，请使用 [`workflow: rules`](yaml/_index.md#workflow) 或重写你的规则以控制可以运行哪些流水线。

<a id="pipeline-errors"></a>

## 流水线错误

<a id="error-identity-verification-is-required-in-order-to-run-ci-jobs"></a>

### 错误：`需要身份验证才能运行 CI 作业`

{{< details >}}

- Tier: 基础版
- Offering: JihuLab.com

{{< /details >}}

当在 JihuLab.com 上使用极狐GitLab 托管的 Runner 并采用基础版计划时，如果你看到错误消息“需要身份验证才能运行 CI 作业”，则必须完成身份验证。

此要求有助于防止滥用免费计算资源。根据你的风险评分，你可能需要验证你的邮箱、电话号码或添加付款方式。有关更多信息，请参阅[身份验证](../security/identity_verification.md)。

完成验证：

1. 在警报横幅中，选择 **验证我的账户**。
1. 出现提示时，按照身份验证步骤操作。你可能需要验证你的电话号码或添加付款方式。
1. 创建一个新提交或手动触发一个新流水线。

或者，你可以：

- 升级到付费计划。
- 为你的命名空间购买额外的计算分钟。
- 使用项目或群组 Runner 而非极狐GitLab 托管的 Runner。
- 请你的群组所有者设置私有化部署 Runner。

<a id="a-cicd-pipeline-must-run-and-be-successful-before-merge-message"></a>

### `CI/CD 流水线必须在合并前运行并成功` 消息

如果在项目中启用了 [**流水线必须成功**](../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge) 设置，并且流水线尚未成功运行，则会显示此消息。这也适用于流水线尚未创建的情况，或者你正在等待外部 CI 服务。

如果你的项目不使用流水线，则应禁用 **流水线必须成功**，以便可以接受合并请求。

<a id="checking-ability-to-merge-automatically-message"></a>

### `检查自动合并能力` 消息

如果你的合并请求卡在“检查自动合并能力”消息上，几分钟后仍未消失，你可以尝试以下解决方法之一：

- 刷新合并请求页面。
- 关闭并重新打开合并请求。
- 使用 [`/rebase` 快速操作](../user/project/quick_actions.md#rebase) 变基合并请求。
- 如果你已经确认合并请求已准备好合并，你可以使用 `/merge` 快速操作合并它。

此议题在极狐GitLab 15.5 中已[解决](https://jihulab.com/gitlab-cn/gitlab/-/issues/229352)。

<a id="checking-pipeline-status-message"></a>

### `检查流水线状态` 消息

当合并请求尚未与最新提交关联管道时，此消息会显示一个旋转状态图标 ({{< icon name="spinner" >}})。这可能是因为：

- 极狐GitLab 尚未完成创建流水线。
- 你正在使用外部 CI 服务，极狐GitLab 尚未收到该服务的反馈。
- 你的项目中未使用 CI/CD 流水线。
- 你的项目中使用了 CI/CD 流水线，但你的配置阻止了流水线在合并请求的源分支上运行。
- 最新的流水线已被删除（这是一个[已知议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/214323)）。
- 合并请求的源分支位于私有派生上。

流水线创建后，消息会更新为流水线状态。

在某些情况下，如果启用了 [**流水线必须成功**](../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge) 设置，该消息可能会一直显示旋转图标。有关更多详细信息，请参阅 [议题 334281](https://jihulab.com/gitlab-cn/gitlab/-/issues/334281)。

<a id="project-groupproject-not-found-or-access-denied-message"></a>

### `项目 <group/project> 未找到或访问被拒绝` 消息

如果使用 [`include`](yaml/_index.md#include) 添加配置，并且以下任一情况成立，则会显示此消息：

- 配置引用了找不到的项目。
- 运行流水线的用户无法访问任何包含的项目。

要解决此问题，请检查：

- 项目路径的格式为 `my-group/my-project`，并且不包含仓库中的任何文件夹。
- 运行流水线的用户是包含所包含文件的[项目成员](../user/project/members/_index.md#add-users-to-a-project)。用户还必须具有在同一项目中运行 CI/CD 作业的[权限](../user/permissions.md#project-cicd)。

<a id="the-parsed-yaml-is-too-big-message"></a>

### `解析的 YAML 太大` 消息

当 YAML 配置太大或嵌套太深时，会显示此消息。包含大量 include 且总行数达数千行的 YAML 文件更有可能达到此内存限制。例如，一个 200 kb 的 YAML 文件很可能会达到默认内存限制。

要减少配置大小，你可以：

- 在流水线编辑器的[完整配置](pipeline_editor/_index.md#view-full-configuration)标签页中检查展开的 CI/CD 配置的长度。查找可以删除或简化的重复配置。
- 将较长或重复的 `script` 部分移至项目中的独立脚本。
- 使用[父流水线和子流水线](pipelines/downstream_pipelines.md#parent-child-pipelines)将一些工作移至独立子流水线中的作业。

在私有化部署的极狐GitLab 上，你可以[增加大小限制](../administration/instance_limits.md#maximum-size-and-depth-of-cicd-configuration-yaml-files)。

<a id="500-error-when-editing-the-gitlab-ciyml-file"></a>

### 编辑 `.gitlab-ci.yml` 文件时出现 `500` 错误

使用 [Web 编辑器](../user/project/repository/web_editor.md)编辑 `.gitlab-ci.yml` 文件时，包含的配置文件循环可能会导致 `500` 错误。

确保包含的配置文件不会创建相互引用的循环。

<a id="failed-to-pull-image-messages"></a>

### `拉取镜像失败` 消息

{{< history >}}

- **允许使用 CI_JOB_TOKEN 访问此项目** 设置已在极狐GitLab 16.3 中重命名为 **限制对此项目的访问**。

{{< /history >}}

当尝试在 CI/CD 作业中拉取容器镜像时，Runner 可能会返回“拉取镜像失败”的消息。

当从另一个项目的容器镜像仓库获取使用 [`image`](yaml/_index.md#image) 定义的容器镜像时，Runner 使用 [CI/CD 作业令牌](jobs/ci_job_token.md) 进行认证。

如果作业令牌设置阻止了访问另一个项目的容器镜像仓库，Runner 会返回错误消息。

例如：

- ```plaintext
  警告：使用策略 "always" 拉取镜像失败：来自守护进程的错误响应：registry.example.com/path/to/project 拉取访问被拒绝，仓库不存在或可能需要 'docker login'：被拒绝：请求的资源访问被拒绝
  ```

- ```plaintext
  警告：使用策略 "" 拉取镜像失败：镜像拉取失败：rpc 错误：代码 = Unknown desc = 无法拉取和解包镜像 "registry.example.com/path/to/project/image:v1.2.3"：无法解析引用 "registry.example.com/path/to/project/image:v1.2.3"：拉取访问被拒绝，仓库不存在或可能需要授权：服务器消息： insufficient_scope：授权失败
  ```

如果以下两个条件都成立，则可能会出现这些错误：

- 托管镜像的私有项目中启用了 [**限制对此项目的访问**](jobs/ci_job_token.md#limit-job-token-scope-for-public-or-internal-projects) 选项。
- 尝试获取镜像的作业正在一个未列入私有项目允许列表的项目中运行。

要解决此问题，请将任何具有从容器镜像仓库获取镜像的 CI/CD 作业的项目添加到目标项目的[作业令牌允许列表](jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)中。

当尝试使用[项目访问令牌](../user/project/settings/project_access_tokens.md)访问另一个项目中的镜像时，也可能发生这些错误。项目访问令牌的范围限制在一个项目内，因此无法访问其他项目中的镜像。你必须使用[具有更广范围的不同令牌类型](../security/tokens/_index.md)。

<a id="random-or-intermittent-failed-to-pull-image-errors"></a>

#### 随机或间歇性的 `拉取镜像失败` 错误

你可能在 CI/CD 作业中遇到间歇性的 `拉取镜像失败` 错误。

当用户具有不同的镜像访问权限，并结合 Runner 缓存这些镜像的方式时，可能会发生此问题。机器人用户通常会受到影响，因为他们通常具有与其他项目成员不同的权限。

例如，你的流水线镜像可能托管在不同项目的容器镜像仓库中。如果所有用户都可以访问这两个项目，这就不是问题。但是，如果用户（如机器人用户）无法访问托管镜像的项目，他们就可能会遇到 `拉取镜像失败` 错误。

当 Runner 为具有访问镜像权限的用户成功获取并缓存了镜像时，该错误就变得间歇性。此 Runner 现在具有可用的镜像，无需访问其他项目来获取镜像。所有用户，包括无权访问其他项目的用户，都可以使用此镜像运行 CI/CD 作业。但是，如果 Runner 从未获取和缓存过镜像，则无权访问镜像项目的用户会收到 `拉取镜像失败` 错误。

要解决此问题，请确保运行流水线的所有用户，包括机器人用户，都可以访问托管所拉取镜像的项目。

<a id="something-went-wrong-on-our-end-message-or-500-error-when-running-a-pipeline"></a>

### 运行流水线时出现 `我们这边出了问题` 消息或 `500` 错误

你可能会收到以下流水线错误：

- 推送或创建合并请求时出现 `我们这边出了问题` 消息。
- 使用 API 触发流水线时出现 `500` 错误。

如果导入项目后内部 ID 的记录变得不同步，则可能会发生这些错误。

要解决此问题，请参阅 [议题 352382 中的解决方法](https://jihulab.com/gitlab-cn/gitlab/-/issues/352382#workaround)。

<a id="config-should-be-an-array-of-hashes-error-message"></a>

### `配置应该是一个哈希数组` 错误消息

当在数组中使用多个 [`!reference` 标签](yaml/yaml_optimization.md#reference-tags) 时，你可能会看到类似以下的错误：

```plaintext
此极狐GitLab CI 配置无效：jobs:my_job_name:parallel:matrix 配置应该是一个哈希数组。
```
虽然 `script`、`rules` 和 `stages` 关键字支持使用多个引用标签，但其他期望数组的关键字不支持。
你可以使用嵌套来解决此限制，或者改用 [YAML 锚点](yaml/yaml_optimization.md#anchors)。

<a id="jobs-job-name-config-should-contain-either-a-trigger-or-a-needs-pipeline"></a>

### 错误：`jobs:<job-name> 配置应包含一个 trigger 或一个 needs:pipeline。`

当你的 `.gitlab-ci.yml` 中的作业使用了 `needs` 关键字，但没有使用 `script:` 或 `trigger:` 关键字时，可能会发生此错误。

每个作业必须使用 `script` 或 `trigger` 关键字之一，因此请为没有使用这两个关键字中任何一个的作业添加相应的关键字。

<a id="config-contains-unknown-keys-key-name"></a>

### 错误：`配置包含未知键：<key-name>`

你可能遇到类似于 `<keyword> 配置包含未知键：<key-name>` 的错误。

此错误消息可能由以下几个问题引起：

- 关键字中的拼写错误，例如 `imag`（无效）而不是 `image`（有效）。
- 关键字或作业的间距或缩进不正确。

例如：

```yaml
test-job:
  artifacts:
    path:        # 这是一个拼写错误，应为 `paths`
      - test
    image: test  # 此缩进不正确，应与 `script` 对齐。
  script:
    - echo
```