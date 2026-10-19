---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 作业输入
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用作业输入可为单个 CI/CD 作业定义带类型、经过验证的参数，这些参数可在手动运行或重试作业时被覆盖。与 [CI/CD 变量](../variables/_index.md)不同，作业输入提供：

- 类型安全：输入可以是 `string`、`number`、`boolean` 或 `array`，并会自动验证。
- 明确的契约：作业只接受您定义的输入。意外的输入会被拒绝。
- 覆盖能力：可在[运行](#run-a-manual-job-with-input-values)作业时设置输入值，并在[重试](#retry-a-job-with-different-input-values)作业时更改输入值。

对于控制作业行为、且重新运行作业时可能需要调整的参数，请使用作业输入。例如：部署目标、测试配置或功能标志。

作业输入的作用域限定在定义它们的作业内，无法在包含的文件或其他作业中访问。如果需要在作业或文件之间共享配置，请改用 [CI/CD 配置输入](../inputs/_index.md)。

<a id="job-input-comparison"></a>

## 作业输入对比

<a id="compared-to-cicd-pipeline-configuration-inputs"></a>

### 与 CI/CD 流水线配置输入对比

作业输入与 [CI/CD 流水线配置输入](../inputs/_index.md)的用途不同：

| 功能        | 作业输入                                                              | CI/CD 配置输入 |
|----------------|-------------------------------------------------------------------------|---------------------|
| 用途        | 配置单个作业的行为                                       | 配置可复用的模板和组件 |
| 语法         | 作业定义中的 `inputs:`                                             | 配置头部的 `spec:inputs:` |
| 插值  | `${{ job.inputs.INPUT_NAME }}`                                          | `$[[ inputs.INPUT_NAME ]]` |
| 求值     | 值在作业创建时设置，可在运行/重试时覆盖 | 值在流水线创建时设置，在整个流水线期间固定 |
| 默认值 | 必需                                                                | 可选 |
| 作用域          | 仅限单个作业                                                         | 整个配置文件，或传递给包含的文件 |

<a id="compared-to-environment-variables"></a>

### 与环境变量对比

作业输入在作业创建时被插值到作业配置中。它们不是环境变量，无法使用 `$INPUT_NAME` 语法访问。您可以在脚本和其他支持的关键字中，使用 `${{ job.inputs.INPUT_NAME }}` 语法直接使用作业输入。

<a id="define-and-use-job-inputs"></a>

## 定义和使用作业输入

在作业中使用 `inputs` 关键字来定义输入参数。每个输入都必须有默认值。使用 `${{ job.inputs.INPUT_NAME }}` [Moa 表达式](../functions/moa.md)语法引用输入值。

例如：

```yaml
deploy_job:
  inputs:
    target_env:
      default: staging
      options: [staging, production]
    replicas:
      type: number
      default: 3
    debug_mode:
      type: boolean
      default: false
  script:
    - 'echo "Deploying to ${{ job.inputs.target_env }}"'
    - 'echo "Replicas - ${{ job.inputs.replicas }}"'
    - 'if [ "${{ job.inputs.debug_mode }}" == "true" ]; then set -x; fi'
    - ./deploy.sh
```

<a id="input-configuration"></a>

### 输入配置

使用以下关键字配置输入：

- `default`：作业运行时使用的默认值。所有作业输入都必须有默认值。
- `type`：可选。输入类型。可以是 `string`（默认）、`number`、`boolean` 或 `array`。
- `description`：可选。对输入用途的易读描述。
- `options`：可选。允许值的列表。输入必须匹配其中一个值。
- `regex`：可选。输入必须匹配的正则表达式模式。

例如：

```yaml
test_job:
  inputs:
    test_framework:
      default: rspec
      description: Testing framework to use
      options: [rspec, minitest, cucumber]
    parallel_count:
      type: number
      default: 5
      description: Number of parallel test jobs
    run_integration_tests:
      type: boolean
      default: false
      description: Whether to run integration tests
    test_tags:
      type: array
      default: [smoke, regression]
      description: Test tags to run
  script:
    - bundle exec ${{ job.inputs.test_framework }}
    - 'echo "Running ${{ job.inputs.parallel_count }} parallel jobs"'
```

作业输入会在作业创建时以及输入值被覆盖时进行验证。如果验证失败，作业将无法启动，并显示明确的错误消息。

<a id="input-types"></a>

### 输入类型

作业输入支持以下类型：

- `string`（默认）：文本值，例如 `"staging"` 或 `"v1.2.3"`。
- `number`：数值，例如 `5`、`3.14` 或 `-10`。
- `boolean`：布尔值，为 `true` 或 `false`。
- `array`：值的列表，例如 `[1, 2, 3]` 或 `["a", "b"]`。

通过 API 或 UI 传递输入值时，数组必须为 JSON 格式，例如：
`["value1", "value2"]`。

<a id="where-you-can-use-job-inputs"></a>

### 可以使用作业输入的位置

您可以使用插值，或使用带运算符和函数的更复杂表达式。完整语法请参见 [Moa 表达式语言](../functions/moa.md)。

作业输入可用于以下作业关键字及其子键：

- `script`、`before_script` 和 `after_script`
- `artifacts`
- `cache`
- `image`
- `services`

作业输入使用 `${{ job.inputs.INPUT_NAME }}` 语法，该语法在作业运行时求值，而不是在流水线配置创建时求值。您无法在必须在流水线创建时求值的配置部分中使用作业输入，例如：

- 作业名称
- `stage` 关键字
- `rules` 关键字
- `include` 关键字
- 上面未列出的其他作业级关键字

要动态配置流水线的这些部分，请改用带 `$[[ inputs.* ]]` 语法的 [CI/CD 流水线配置输入](../inputs/_index.md)。

<a id="provide-input-values"></a>

## 提供输入值

您可以在以下情况下提供作业输入值：

- 运行手动作业时。
- 作业完成后重试作业时。

<a id="run-a-manual-job-with-input-values"></a>

### 使用输入值运行手动作业

当您运行定义了输入的手动作业时，可以指定输入值。

要使用特定输入运行手动作业：

1. 转到流水线、作业或[环境](../environments/deployments.md#configure-manual-deployments)视图。
1. 选择手动作业的名称，而不是 **运行**（{{< icon name="play" >}}）。
1. 在表单中，指定输入值。
1. 选择 **运行作业**。

<a id="retry-a-job-with-different-input-values"></a>

### 使用不同输入值重试作业

当您重试定义了输入的作业时，可以更新输入值。

要使用不同输入重试作业：

1. 转到作业详情页面。
1. 选择 **使用修改后的值重试作业**（{{< icon name="chevron-down" >}}）。
1. 在表单中，输入会预填上次运行的值。
   根据需要修改输入值。
1. 选择 **再次运行作业**。

要使用相同输入值重试，请改为选择 **重试**（{{< icon name="retry" >}}）。

<a id="job-input-examples"></a>

## 作业输入示例

<a id="basic-deployment-job-with-inputs"></a>

### 带输入的基本部署作业

```yaml
deploy:
  when: manual
  inputs:
    target_env:
      default: staging
      description: Target deployment environment
      options: [staging, production]
    version:
      default: latest
      description: Application version to deploy
  script:
    - 'echo "Deploying version ${{ job.inputs.version }} to ${{ job.inputs.target_env }}"'
    - ./deploy.sh --env ${{ job.inputs.target_env }} --version ${{ job.inputs.version }}
```

<a id="test-job-with-validation"></a>

### 带验证的测试作业

```yaml
integration_tests:
  inputs:
    test_suite:
      default: smoke
      description: Which test suite to run
      options: [smoke, regression, full]
    parallel_jobs:
      type: number
      default: 5
      description: Number of parallel test runners
    enable_debug:
      type: boolean
      default: false
      description: Enable debug logging
    tags:
      type: array
      default: ["critical"]
      description: Test tags to run
  script:
    - 'if [ "${{ job.inputs.enable_debug }}" == "true" ]; then export DEBUG=1; fi'
    - ./run_tests.sh
        --suite ${{ job.inputs.test_suite }}
        --parallel ${{ job.inputs.parallel_jobs }}
        --tags '${{ job.inputs.tags }}'
```

<a id="database-migration-with-safety-checks"></a>

### 带安全检查的数据库迁移

```yaml
migrate_database:
  when: manual
  inputs:
    target_db:
      default: development
      description: Database environment
      options: [development, staging, production]
    migration_name:
      default: ""
      description: Specific migration to run (leave empty for all)
      regex: ^[a-zA-Z0-9_]*$
    dry_run:
      type: boolean
      default: true
      description: Run in dry-run mode without applying changes
  script:
    - 'echo "Running migrations on ${{ job.inputs.target_db }}"'
    - |
      if [ "${{ job.inputs.dry_run }}" == "true" ]; then
        echo "DRY RUN MODE - no changes will be applied"
        MIGRATION_FLAGS="--dry-run"
      fi
    - |
      if [ -n "${{ job.inputs.migration_name }}" ]; then
        ./migrate.sh $MIGRATION_FLAGS --migration ${{ job.inputs.migration_name }}
      else
        ./migrate.sh $MIGRATION_FLAGS --all
      fi
```

<a id="use-job-inputs-with-the-api"></a>

## 通过 API 使用作业输入

使用 API 运行或重试作业时，您可以指定作业输入值。

<a id="run-a-manual-job-with-inputs"></a>

### 使用输入运行手动作业

使用 [`POST /projects/:id/jobs/:job_id/play` 端点](../../api/jobs.md#run-a-job)，并带上 `job_inputs` 参数：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "job_inputs": {
      "environment": "staging",
      "version": "v2.1.0"
    }
  }' \
  "https://gitlab.example.com/api/v4/projects/1/jobs/456/play"
```

<a id="retry-a-job-with-inputs"></a>

### 使用输入重试作业

使用 [`POST /projects/:id/jobs/:job_id/retry` 端点](../../api/jobs.md#retry-a-job)，并带上 `job_inputs` 参数：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "job_inputs": {
      "environment": "production",
      "replicas": 10
    }
  }' \
  "https://gitlab.example.com/api/v4/projects/1/jobs/123/retry"
```

<a id="use-graphql"></a>

### 使用 GraphQL

您可以使用 [`jobPlay` 变更操作](../../api/graphql/reference/_index.md#mutationjobplay)
或 [`jobRetry` 变更操作](../../api/graphql/reference/_index.md#mutationjobretry)，
并带上 `inputs` 参数：

```graphql
mutation {
  jobPlay(input: {
    id: "gid://gitlab/Ci::Build/123",
    inputs: [
      { name: "environment", value: "production" },
      { name: "replicas", value: 10 }
    ]
  }) {
    job {
      id
      status
    }
    errors
  }
}
```

<a id="troubleshooting"></a>

## 故障排除

<a id="job-fails-with-input-must-have-a-default-value"></a>

### 作业失败并提示 `input must have a default value`

作业输入必须始终有默认值，以确保作业能在无法手动指定输入的流水线中运行。

要修复此错误，请为每个输入添加 `default`：

```yaml
my_job:
  inputs:
    target_env:
      default: staging  # Default specified
  script:
    - echo ${{ job.inputs.target_env }}
```

<a id="input-validation-fails-with-unexpected-value"></a>

### 输入验证失败并提示 `unexpected value`

当输入验证失败时，请检查：

- 如果使用 `options`，请确保该值与某个允许的选项完全匹配（区分大小写）。
- 如果使用 `regex`，请测试您的正则表达式是否匹配该输入值。
- 如果使用 `type: number`，请确保该值为数值，而不是字符串。
- 如果使用 `type: array`，请确保通过 API 传递时该值为 JSON 数组格式。
