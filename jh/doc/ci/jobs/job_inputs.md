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

{{< history >}}

- 在极狐GitLab 18.10 中引入。
- 需要极狐GitLab Runner 18.9 或更高版本。

{{< /history >}}

使用作业输入为单个 CI/CD 作业定义类型化、已验证的参数，这些参数可以在手动运行或重试作业时被覆盖。与 [CI/CD 变量](../variables/_index.md) 不同，作业输入提供：

- 类型安全：输入可以是 `string`、`number`、`boolean` 或 `array`，并带有自动验证。
- 明确的约定：作业只接受你定义的输入。意外的输入会被拒绝。
- 覆盖能力：在[运行](#run-a-manual-job-with-input-values)作业时可以设置输入值，并在[重试](#retry-a-job-with-different-input-values)作业时可以更改输入值。

对于控制作业行为且可能需要在重新运行作业时进行调整的参数，请使用作业输入。例如：部署目标、测试配置或功能标志。

作业输入的作用域限定在定义它们的作业内，不能在包含的文件或其他作业中访问。如果你需要跨作业或文件共享配置，请改用 [CI/CD 配置输入](../inputs/_index.md)。

## 作业输入对比

### 与 CI/CD 流水线配置输入对比

作业输入和 [CI/CD 流水线配置输入](../inputs/_index.md) 服务于不同的目的：

| 功能        | 作业输入                                                              | CI/CD 配置输入 |
|----------------|-------------------------------------------------------------------------|---------------------|
| 目的        | 配置单个作业行为                                       | 配置可重用模板和组件 |
| 语法         | 作业定义中的 `inputs:`                                             | 配置头中的 `spec:inputs:` |
| 插值  | `${{ job.inputs.INPUT_NAME }}`                                          | `$[[ inputs.INPUT_NAME ]]` |
| 求值     | 创建作业时设置值，可在运行/重试时覆盖 | 在流水线创建时设置值，对整个流水线固定 |
| 默认值 | 必需                                                                | 可选 |
| 作用域          | 仅限单个作业                                                         | 整个配置文件或传递给包含的文件 |

### 与环境变量对比

作业输入在创建作业时被插值到作业配置中。它们不是环境变量，不能使用 `$INPUT_NAME` 语法访问。你可以使用 `${{ job.inputs.INPUT_NAME }}` 语法直接在脚本和其他支持的关键字中使用作业输入。

## 定义和使用作业输入

使用作业中的 `inputs` 关键字来定义输入参数。每个输入都必须有一个默认值。使用 `${{ job.inputs.INPUT_NAME }}` [Moa 表达式](../functions/moa.md) 语法引用输入值。

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
    - 'echo "正在部署到 ${{ job.inputs.target_env }}"'
    - 'echo "副本数 - ${{ job.inputs.replicas }}"'
    - 'if [ "${{ job.inputs.debug_mode }}" == "true" ]; then set -x; fi'
    - ./deploy.sh
```

### 输入配置

使用以下关键字配置输入：

- `default`：作业运行时的默认值。所有作业输入都必须有默认值。
- `type`：可选。输入类型。可以是 `string`（默认值）、`number`、`boolean` 或 `array`。
- `description`：可选。关于输入用途的人类可读的描述。
- `options`：可选。允许值的列表。输入必须匹配这些值之一。
- `regex`：可选。输入必须匹配的正则表达式模式。

例如：

```yaml
test_job:
  inputs:
    test_framework:
      default: rspec
      description: 要使用的测试框架
      options: [rspec, minitest, cucumber]
    parallel_count:
      type: number
      default: 5
      description: 并行测试作业的数量
    run_integration_tests:
      type: boolean
      default: false
      description: 是否运行集成测试
    test_tags:
      type: array
      default: [smoke, regression]
      description: 要运行的测试标签
  script:
    - bundle exec ${{ job.inputs.test_framework }}
    - 'echo "正在运行 ${{ job.inputs.parallel_count }} 个并行作业"'
```

创建作业时以及覆盖输入值时，都会对作业输入进行验证。如果验证失败，作业将无法启动并显示明确的错误信息。

### 输入类型

作业输入支持以下类型：

- `string`（默认值）：文本值，例如 `"staging"` 或 `"v1.2.3"`。
- `number`：数值，例如 `5`、`3.14` 或 `-10`。
- `boolean`：布尔值，可以是 `true` 或 `false`。
- `array`：值列表，例如 `[1, 2, 3]` 或 `["a", "b"]`。

通过 API 或 UI 传递输入值时，数组必须采用 JSON 格式，例如：`["value1", "value2"]`。

### 可以在哪里使用作业输入

你可以使用简单的插值或带有运算符和函数的更复杂的表达式。有关完整语法，请参见 [Moa 表达式语言](../functions/moa.md)。

作业输入可以在以下作业关键字及其子键中使用：

- `script`、`before_script` 和 `after_script`
- `artifacts`
- `cache`
- `image`
- `services`

### 局限性

作业输入使用 `${{ job.inputs.INPUT_NAME }}` 语法，该语法在作业运行时求值，而不是在创建流水线配置时求值。你不能在必须在流水线创建时求值的配置部分中使用作业输入，例如：

- 作业名称
- `stage` 关键字
- `rules` 关键字
- `include` 关键字
- 上面未列出的其他作业级关键字

要动态配置流水线的这些部分，请改用带有 `$[[ inputs.* ]]` 语法的 [CI/CD 流水线配置输入](../inputs/_index.md)。

## 提供输入值

你可以在以下情况下提供作业输入值：

- 运行手动作业时。
- 作业完成后重试时。

<a id="run-a-manual-job-with-input-values"></a>

### 使用输入值运行手动作业

当你运行一个定义了输入的手动作业时，你可以指定输入值。

要使用特定输入运行手动作业：

1. 进入流水线、作业或[环境](../environments/deployments.md#configure-manual-deployments)视图。
1. 选择手动作业的名称，而不是 **运行**（{{< icon name="play" >}}）。
1. 在表单中，指定输入值。
1. 选择 **运行作业**。

<a id="retry-a-job-with-different-input-values"></a>

### 使用不同的输入值重试作业

当你重试一个定义了输入的作业时，你可以更新输入值。

要使用不同的输入重试作业：

1. 进入作业详情页面。
1. 选择 **使用修改后的值重试作业**（{{< icon name="chevron-down" >}}）。
1. 在表单中，输入会预填上次运行的值。根据需要修改输入值。
1. 选择 **再次运行作业**。

要使用相同的输入值重试，请选择 **重试**（{{< icon name="retry" >}}）。

## 作业输入示例

### 带有输入的基本部署作业

```yaml
deploy:
  when: manual
  inputs:
    target_env:
      default: staging
      description: 目标部署环境
      options: [staging, production]
    version:
      default: latest
      description: 要部署的应用程序版本
  script:
    - 'echo "正在部署版本 ${{ job.inputs.version }} 到 ${{ job.inputs.target_env }}"'
    - ./deploy.sh --env ${{ job.inputs.target_env }} --version ${{ job.inputs.version }}
```

### 带有验证的测试作业

```yaml
integration_tests:
  inputs:
    test_suite:
      default: smoke
      description: 要运行的测试套件
      options: [smoke, regression, full]
    parallel_jobs:
      type: number
      default: 5
      description: 并行测试 Runner 的数量
    enable_debug:
      type: boolean
      default: false
      description: 启用调试日志记录
    tags:
      type: array
      default: ["critical"]
      description: 要运行的测试标签
  script:
    - 'if [ "${{ job.inputs.enable_debug }}" == "true" ]; then export DEBUG=1; fi'
    - ./run_tests.sh
        --suite ${{ job.inputs.test_suite }}
        --parallel ${{ job.inputs.parallel_jobs }}
        --tags '${{ job.inputs.tags }}'
```

### 带有安全检查的数据库迁移

```yaml
migrate_database:
  when: manual
  inputs:
    target_db:
      default: development
      description: 数据库环境
      options: [development, staging, production]
    migration_name:
      default: ""
      description: 要运行的特定迁移（留空表示全部）
      regex: ^[a-zA-Z0-9_]*$
    dry_run:
      type: boolean
      default: true
      description: 以试运行模式运行，不应用更改
  script:
    - 'echo "正在 ${{ job.inputs.target_db }} 上运行迁移"'
    - |
      if [ "${{ job.inputs.dry_run }}" == "true" ]; then
        echo "试运行模式 - 不会应用任何更改"
        MIGRATION_FLAGS="--dry-run"
      fi
    - |
      if [ -n "${{ job.inputs.migration_name }}" ]; then
        ./migrate.sh $MIGRATION_FLAGS --migration ${{ job.inputs.migration_name }}
      else
        ./migrate.sh $MIGRATION_FLAGS --all
      fi
```

## 通过 API 使用作业输入

在使用 API 运行或重试作业时，你可以指定作业输入值。

### 使用输入运行手动作业

使用 [`POST /projects/:id/jobs/:job_id/play` 端点](../../api/jobs.md#run-a-job) 和 `job_inputs` 参数：

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

### 使用输入重试作业

使用 [`POST /projects/:id/jobs/:job_id/retry` 端点](../../api/jobs.md#retry-a-job) 和 `job_inputs` 参数：

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

### 使用 GraphQL

你可以使用带有 `inputs` 参数的 [`jobPlay` 变更](../../api/graphql/reference/_index.md#mutationjobplay) 或 [`jobRetry` 变更](../../api/graphql/reference/_index.md#mutationjobretry)：

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

## 故障排查

### 作业失败，提示 `input must have a default value`

作业输入必须始终具有默认值，以确保作业可以在无法手动指定输入的流水线中运行。

要修复此错误，请为每个输入添加一个 `default`：

```yaml
my_job:
  inputs:
    target_env:
      default: staging  # 指定了默认值
  script:
    - echo ${{ job.inputs.target_env }}
```

### 输入验证失败，提示 `unexpected value`

当输入验证失败时，请检查：

- 如果使用了 `options`，确保该值与任一允许的选项完全匹配（区分大小写）。
- 如果使用了 `regex`，测试你的正则表达式是否匹配输入值。
- 如果使用了 `type: number`，确保该值是数字，而不是字符串。
- 如果使用了 `type: array`，确保在通过 API 传递时，该值被格式化为 JSON 数组。