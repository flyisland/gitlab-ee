---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use typed, validated input parameters to customize reusable CI/CD templates and components.
title: CI/CD 输入
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.11 中作为测试功能引入。
- 在极狐GitLab 17.0 中正式发布。

{{< /history >}}

使用 CI/CD 输入来提高 CI/CD 配置的灵活性。输入和 [CI/CD 变量](../variables/_index.md) 可以以类似的方式使用，但具有不同的优势：

- 输入为可重用模板提供了类型化参数，并在流水线创建时进行内置验证。要在流水线运行时定义特定值，请使用输入而不是 CI/CD 变量。
- CI/CD 变量提供了可以在多个层级定义的灵活值，但可以在流水线执行过程中被修改。对于需要在作业运行时环境中可访问的值，请使用变量。你还可以将 [预定义变量](../variables/predefined_variables.md) 与 `rules` 结合使用，以实现动态流水线配置。

<a id="ci-cd-inputs-and-variables-comparison"></a>

## CI/CD 输入与变量对比

输入：

- **目的**：在 CI 配置（模板、组件或 `.gitlab-ci.yml`）中定义，并在触发流水线时赋值，允许使用者自定义可重用的 CI 配置。
- **修改**：一旦在流水线初始化时传入，输入值就会被插值到 CI/CD 配置中，并在整个流水线运行期间保持不变。
- **作用域**：仅在定义它们的文件中可用，无论是在 `.gitlab-ci.yml` 中还是在被 `include` 的文件中。你可以使用 `include:inputs` 将它们显式传递给其他文件，或者使用 `trigger:inputs` 传递给流水线。
- **验证**：提供强大的验证功能，包括类型检查、正则表达式模式、预定义选项列表以及为用户提供有用的描述。

CI/CD 变量：

- **目的**：可以在作业执行期间设置为环境变量，并在流水线的各个部分中用于在作业之间传递数据。
- **修改**：可以在流水线执行过程中通过 dotenv 产物、条件规则或直接在作业脚本中动态生成或修改。
- **作用域**：可以全局定义（影响所有作业），在作业级别定义（仅影响特定作业），或者通过极狐GitLab UI 为整个项目或群组定义。
- **验证**：简单的键值对，内置验证很少，不过你可以通过极狐GitLab UI 为项目变量添加一些控制。

<a id="define-input-parameters-with-specinputs"></a>

## 使用 `spec:inputs` 定义输入参数

在 CI/CD 配置的 [头部](../yaml/_index.md#header-keywords) 中使用 `spec:inputs` 来定义可以传递给配置文件的输入参数。

在头部部分之外，使用 `$[[ inputs.input-id ]]` 插值格式来声明在哪里使用这些输入。

例如：

```yaml
spec:
  inputs:
    job-stage:
      default: test
    environment:
      default: production
---
scan-website:
  stage: $[[ inputs.job-stage ]]
  script: ./scan-website $[[ inputs.environment ]]
```

在这个例子中，输入是 `job-stage` 和 `environment`。

使用 `spec:inputs` 时：

- 如果未指定 `default`，则输入是必填的。
- 输入在流水线创建期间获取配置时被评估和填充。
- 包含输入的字符串必须小于 1 MB。
- 输入内部的字符串必须小于 1 KB。
- 输入可以使用 CI/CD 变量，但具有与 [`include` 关键字相同的变量限制](../yaml/includes.md#use-variables-with-include)。
- 如果定义 `spec:inputs` 的文件也包含作业定义，请在头部之后添加一个 YAML 文档分隔符 (`---`)。

然后，在以下情况下为输入设置值：

- [运行新流水线](#for-a-pipeline) 使用此配置文件。当使用除 `include` 以外的任何方法配置新流水线时，你应该始终设置默认值。否则，如果新流水线自动触发，流水线可能无法启动，包括：
  - 合并请求流水线
  - 分支流水线
  - 标签流水线
- [将配置包含在流水线中](#for-configuration-added-with-include)。任何必填的输入都必须添加到 `include:inputs` 部分，并在每次包含该配置时使用。

<a id="input-configuration"></a>

### 输入配置

要配置输入，请使用：

- [`spec:inputs:default`](../yaml/_index.md#specinputsdefault) 为未指定的输入定义默认值。当你指定默认值时，输入不再是必填的。
- [`spec:inputs:description`](../yaml/_index.md#specinputsdescription) 为特定输入提供描述。该描述不会影响输入，但可以帮助人们理解输入的详细信息或预期值。
- [`spec:inputs:options`](../yaml/_index.md#specinputsoptions) 为输入指定允许值的列表。
- [`spec:inputs:regex`](../yaml/_index.md#specinputsregex) 指定输入必须匹配的正则表达式。
- [`spec:inputs:type`](../yaml/_index.md#specinputstype) 强制指定输入类型，可以是 `string`（未指定时的默认值）、`array`、`number` 或 `boolean`。
- [`spec:inputs:rules`](../yaml/_index.md#specinputsrules) 根据其他输入的值定义条件 `options` 和 `default` 值。

每个 CI/CD 配置文件可以定义多个输入，每个输入可以有多个配置参数。

例如，在名为 `scan-website-job.yml` 的文件中：

```yaml
spec:
  inputs:
    job-prefix:     # 必填的字符串输入
      description: "为作业名称定义一个前缀"
    job-stage:      # 可选的字符串输入，未提供时使用默认值
      default: test
    environment:    # 必填输入，必须匹配其中一个选项
      options: ['test', 'staging', 'production']
    concurrency:
      type: number  # 可选的数字输入，未提供时使用默认值
      default: 1
    version:        # 必填的字符串输入，必须匹配正则表达式
      type: string
      regex: ^v\d\.\d+(\.\d+)$
    export_results: # 可选的布尔输入，未提供时使用默认值
      type: boolean
      default: true
---

"$[[ inputs.job-prefix ]]-scan-website":
  stage: $[[ inputs.job-stage ]]
  script:
    - echo "扫描网站 -e $[[ inputs.environment ]] -c $[[ inputs.concurrency ]] -v $[[ inputs.version ]]"
    - if $[[ inputs.export_results ]]; then echo "导出结果"; fi
```

在这个例子中：

- `job-prefix` 是一个必填的字符串输入，必须定义。
- `job-stage` 是可选的。如果未定义，则值为 `test`。
- `environment` 是一个必填的字符串输入，必须匹配其中一个定义的选项。
- `concurrency` 是一个可选的数字输入。未指定时，默认为 `1`。
- `version` 是一个必填的字符串输入，必须匹配指定的正则表达式。
- `export_results` 是一个可选的布尔输入。未指定时，默认为 `true`。

<a id="input-types"></a>

### 输入类型

你可以使用可选的 `spec:inputs:type` 关键字指定输入必须使用特定类型。

输入类型有：

- [`array`](#array-type)
- `boolean`
- `number`
- `string`（未指定时的默认值）

当输入替换 CI/CD 配置中的整个 YAML 值时，它会以其指定的类型插值到配置中。例如：

```yaml
spec:
  inputs:
    array_input:
      type: array
    boolean_input:
      type: boolean
    number_input:
      type: number
    string_input:
      type: string
---

test_job:
  allow_failure: $[[ inputs.boolean_input ]]
  needs: $[[ inputs.array_input ]]
  parallel: $[[ inputs.number_input ]]
  script: $[[ inputs.string_input ]]
```

当输入作为较大字符串的一部分插入到 YAML 值中时，输入始终以字符串形式插值。例如：

```yaml
spec:
  inputs:
    port:
      type: number
---

test_job:
  script: curl "https://gitlab.com:$[[ inputs.port ]]"
```

<a id="array-type"></a>

#### 数组类型

{{< history >}}

- 在极狐GitLab 16.11 中引入。

{{< /history >}}

数组类型中项目的内容可以是任何有效的 YAML 映射、序列或标量。不能使用更复杂的 YAML 特性，如 [`!reference`](../yaml/yaml_optimization.md#reference-tags)。在字符串中使用数组输入的值时（例如在 `script:` 部分中使用 `echo "My rules: $[[ inputs.rules-config ]]"`），你可能会看到意外的结果。数组输入被转换为其字符串表示形式，对于复杂的 YAML 结构（如映射），这可能与你的预期不符。

```yaml
spec:
  inputs:
    rules-config:
      type: array
      default:
        - if: $CI_PIPELINE_SOURCE == "merge_request_event"
          when: manual
        - if: $CI_PIPELINE_SOURCE == "schedule"
---

test_job:
  rules: $[[ inputs.rules-config ]]
  script: ls
```

当手动传递输入时，数组输入必须格式化为 JSON，例如 `["array-input-1", "array-input-2"]`，用于：

- [手动运行流水线](../pipelines/_index.md#run-a-pipeline-manually)。
- [流水线触发器 API](../../api/pipeline_triggers.md#trigger-a-pipeline-with-a-token)。
- [流水线 API](../../api/pipelines.md#create-a-new-pipeline)。
- Git [推送选项](../../topics/git/commit.md#push-options-for-gitlab-cicd)
- [流水线计划](../pipelines/schedules.md#create-a-pipeline-schedule)

<a id="array-inputs-with-options"></a>

##### 带选项的数组输入

{{< history >}}

- 在极狐GitLab 19.0 中引入。

{{< /history >}}

你可以定义一个选项列表来限制数组输入的允许值。当你手动运行流水线时，UI 会显示一个多选下拉菜单，而不是文本字段。例如：

```yaml
spec:
  inputs:
    runner_tags:
      type: array
      default: ["docker"]
      options:
        - docker
        - linux
        - gpu
        - macos
---

test:
  script:
    - run_tests.sh
  tags: $[[ inputs.runner_tags ]]
```

如果数组输入中的任何值与列出的选项不匹配，流水线将无法启动。

<a id="access-individual-array-elements"></a>

##### 访问单个数组元素

{{< history >}}

- 在极狐GitLab 18.10 中引入，带有名为 `ci_inputs_array_index_operator` 的功能标志。默认禁用。
- 在极狐GitLab 18.11 中正式发布。功能标志 `ci_inputs_array_index_operator` 已移除。

{{< /history >}}

使用带索引号的方括号表示法来访问数组输入的单个元素。数组项按照它们在 YAML 数组中定义的顺序进行索引，使用正数，`[0]` 索引项是数组中的第一项。

例如：

```yaml
spec:
  inputs:
    supported_versions:
      type: array
      default:
        - '2.0'
        - '1.0'
        - '0.1'
---

job:
  script:
    # 输出：'最新版本是 2.0'
    - echo '最新版本是 $[[ inputs.supported_versions[0] ]]'
```

你可以将数组索引与点表示法链接起来以访问嵌套值：

```yaml
spec:
  inputs:
    servers:
      type: array
      default:
        - host: server1.example.com
          port: 8080
---

job:
  script:
    - curl "https://$[[ inputs.servers[0].host ]]:$[[ inputs.servers[0].port ]]"
```

对于多维数组，连续使用多个索引。例如，对于二维数组，你可以使用 `[0][1]`：

```yaml
spec:
  inputs:
    matrix:
      type: array
      default:
        - ['a', 'b']
        - ['c', 'd']
---

job:
  script:
    # 输出：'b'
    - echo $[[ inputs.matrix[0][1] ]]
```

每个段最多可以链接 5 个索引，例如 `arr[0][1][2][3][4]`。

<a id="multi-line-input-string-values"></a>

#### 多行输入字符串值

输入支持不同的值类型。你可以使用以下格式传递多行字符串值：

```yaml
spec:
  inputs:
    closed_message:
      description: 议题关闭时发布的消息。
      default: '你好 {{author}} :wave:,

        根据非活跃议题的策略，此议题现在将被关闭。

        如果此议题需要进一步关注，请重新打开此议题。'
---
```

<a id="define-conditional-input-options-with-specinputsrules"></a>

### 使用 `spec:inputs:rules` 定义条件输入选项

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

使用 [`spec:inputs:rules`](../yaml/_index.md#specinputsrules) 根据其他输入的值，为输入定义不同的 `options` 和 `default` 值。当一个输入应该根据其他输入提供的上下文而具有不同的允许值时，你可以使用此配置。

`rules` 列表中的每个规则可以包含：

- `if`：一个表达式，检查一个或多个输入的值，以确定此规则何时适用。使用与 [`$[[ inputs.input-id ]]` 插值](#define-input-parameters-with-specinputs) 相同的语法。
- `options`：当此规则匹配时，输入的允许值列表。
- `default`：当此规则匹配时使用的默认值。

规则按顺序评估。第一个具有匹配 `if` 条件的规则将被使用。没有 `if` 条件的最后一个规则作为其他规则都不匹配时的回退。

例如，要定义根据云提供商和环境而变化的实例类型：

```yaml
spec:
  inputs:
    cloud_provider:
      options: ['aws', 'gcp', 'azure']
      default: 'aws'
      description: '云提供商'

    environment:
      options: ['development', 'staging', 'production']
      default: 'development'
      description: '目标环境'

    instance_type:
      description: '虚拟机实例类型'
      rules:
        - if: $[[ inputs.cloud_provider ]] == 'aws' && $[[ inputs.environment ]] == 'development'
          options: ['t3.micro', 't3.small']
          default: 't3.micro'
        - if: $[[ inputs.cloud_provider ]] == 'aws' && $[[ inputs.environment ]] == 'production'
          options: ['t3.xlarge', 't3.2xlarge', 'm5.xlarge']
          default: 't3.xlarge'
        - if: $[[ inputs.cloud_provider ]] == 'gcp'
          options: ['e2-micro', 'e2-small', 'e2-standard-4']
          default: 'e2-micro'
        - if: $[[ inputs.cloud_provider ]] == 'azure'
          options: ['Standard_B1s', 'Standard_B2s', 'Standard_D2s_v3']
          default: 'Standard_B1s'
        - options: ['small', 'medium', 'large']  # 任何其他情况的回退
          default: 'small'
---

deploy:
  script: |
    echo "部署到 $[[ inputs.cloud_provider ]]"
    echo "环境：$[[ inputs.environment ]]"
    echo "实例：$[[ inputs.instance_type ]]"
```

在这个例子中：

- 当 `cloud_provider` 为 `aws` 且 `environment` 为 `development` 时，用户可以从 `t3.micro` 或 `t3.small` 实例类型中选择，默认值为 `t3.micro`。
- 当 `cloud_provider` 为 `aws` 且 `environment` 为 `production` 时，可用的实例类型不同（`t3.xlarge`、`t3.2xlarge`、`m5.xlarge`）。
- 当 `cloud_provider` 为 `gcp` 时，无论环境如何，都可以使用 GCP 特定的实例类型。
- 如果所有条件都不匹配，回退规则提供通用的尺寸选项。

你还可以使用 `||`（或）运算符来匹配多个条件。例如：

```yaml
spec:
  inputs:
    deployment_type:
      options: ['canary', 'blue-green', 'rolling', 'recreate']
      default: 'rolling'

    requires_approval:
      description: '部署是否需要手动批准'
      rules:
        - if: $[[ inputs.deployment_type ]] == 'canary' || $[[ inputs.deployment_type ]] == 'blue-green'
          options: ['true']
          default: 'true'
        - options: ['true', 'false']
          default: 'false'
---

deploy:
  script: echo "使用 $[[ inputs.deployment_type ]] 策略部署"
```

在这个例子中，当 `deployment_type` 为 `canary` 或 `blue-green` 时，`requires_approval` 输入被设置为 `true`。在所有其他情况下，默认值为 `false`，并且 `true` 或 `false` 都是允许的选项。

<a id="allow-user-entered-values-with-default-null"></a>

### 使用 `default: null` 允许用户输入值

{{< history >}}

- 在极狐GitLab 18.9 中引入。

{{< /history >}}

使用带有 `default: null` 且不带 `options` 的 `spec:inputs:rules`，允许用户为输入输入自己的值。这对于工作流特定的值（如环境名称或测试配置）非常有用。

例如：

```yaml
spec:
  inputs:
    deployment_type:
      options: ['standard', 'custom']
      default: 'standard'

    custom_config:
      description: '自定义配置值'
      rules:
        - if: $[[ inputs.deployment_type ]] == 'custom'
          default: null
---

deploy:
  script: echo "配置：$[[ inputs.custom_config ]]"
```

在这个例子中，当 `deployment_type` 为 `custom` 时，`custom_config` 输入会显示在运行流水线页面上，用户必须为该输入输入一个值。

<a id="use-boolean-inputs-with-specinputsrules"></a>

### 在 `spec:inputs:rules` 中使用布尔输入

你可以在规则条件中使用布尔输入。布尔值可以使用布尔字面量（`true`/`false`）进行比较：

```yaml
spec:
  inputs:
    publish:
      type: boolean
      default: true

    publish_stage:
      rules:
        - if: $[[ inputs.publish ]] == true
          default: 'publish'
        - if: $[[ inputs.publish ]] == false
          default: 'test'
---

job:
  stage: $[[ inputs.publish_stage ]]
  script: echo "发布状态为 $[[ inputs.publish ]]"
```

在这个例子中，当 `publish` 为 `true` 时，`publish_stage` 默认为 `publish`。当 `publish` 为 `false` 时，它默认为 `test`。

<a id="set-input-values"></a>

## 设置输入值

你可以在流水线配置中或触发流水线时设置输入值。

流水线启动后，你无法获取任何已使用的输入值。如果某个值可以安全公开，你可以在作业日志中输出该值以供将来参考，或者将其保存在产物中。

<a id="for-configuration-added-with-include"></a>

### 对于通过 `include` 添加的配置

{{< history >}}

- `include:with` 在极狐GitLab 16.0 中[重命名为 `include:inputs`](https://gitlab.com/gitlab-org/gitlab/-/issues/406780)。

{{< /history >}}

当包含的配置被添加到流水线时，使用 [`include:inputs`](../yaml/_index.md#includeinputs) 为输入设置值，包括：

- [CI/CD 组件](../components/_index.md)
- 通过 `include` 添加的任何其他配置。

例如，要从[输入配置示例](#input-configuration)中包含 `scan-website-job.yml` 并设置其输入值：

```yaml
include:
  - local: 'scan-website-job.yml'
    inputs:
      job-prefix: 'some-service-'
      environment: 'staging'
      concurrency: 2
      version: 'v1.3.2'
      export_results: false
```

在这个例子中，包含的配置的输入为：

| 输入            | 值             | 详细信息 |
|------------------|-----------------|---------|
| `job-prefix`     | `some-service-` | 必须显式定义。 |
| `job-stage`      | `test`          | 未在 `include:inputs` 中定义，因此值来自包含配置中的 `spec:inputs:default`。 |
| `environment`    | `staging`       | 必须显式定义，并且必须匹配包含配置中 `spec:inputs:options` 中的值之一。 |
| `concurrency`    | `2`             | 必须是数字值，以匹配包含配置中设置为 `number` 的 `spec:inputs:type`。覆盖默认值。 |
| `version`        | `v1.3.2`        | 必须显式定义，并且必须匹配包含配置中 `spec:inputs:regex` 中的正则表达式。 |
| `export_results` | `false`         | 必须是 `true` 或 `false`，以匹配包含配置中设置为 `boolean` 的 `spec:inputs:type`。覆盖默认值。 |

<a id="with-multiple-include-entries"></a>

#### 对于多个 `include` 条目

必须为每个 include 条目单独指定输入。例如：

```yaml
include:
  - component: $CI_SERVER_FQDN/the-namespace/the-project/the-component@1.0
    inputs:
      stage: my-stage
  - local: path/to/file.yml
    inputs:
      stage: my-stage
```

<a id="for-a-pipeline"></a>

### 对于流水线

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

输入提供了优于变量的优势，包括类型检查、验证和清晰的契约。意外的输入会被拒绝。流水线的输入必须在主 `.gitlab-ci.yml` 文件的 [`spec:inputs` 头部](#define-input-parameters-with-specinputs) 中定义。你不能使用包含文件中定义的输入进行流水线级别的配置。

> [!note]
> 在[极狐GitLab 17.7](../../update/deprecations.md#increased-default-security-for-use-of-pipeline-variables) 及更高版本中，建议使用流水线输入，而不是传递[流水线变量](../variables/_index.md#use-pipeline-variables)。为了增强安全性，在使用输入时，你应该[禁用流水线变量](../variables/_index.md#restrict-pipeline-variables)。

在为流水线定义输入时，你应该始终设置默认值。如果任何输入缺少默认值，流水线在自动触发时会失败。例如，合并请求流水线可以针对合并请求源分支的更改触发。你无法为合并请求流水线手动设置输入，因此如果任何输入缺少默认值，流水线将失败。这也可能发生在分支流水线、标签流水线和其他自动触发的流水线上。

你可以通过以下方式设置输入值：

- [下游流水线](../pipelines/downstream_pipelines.md#pass-inputs-to-a-downstream-pipeline)
- [手动运行流水线](../pipelines/_index.md#run-a-pipeline-manually)。
- [流水线触发器 API](../../api/pipeline_triggers.md#trigger-a-pipeline-with-a-token)
- [流水线 API](../../api/pipelines.md#create-a-new-pipeline)
- Git [推送选项](../../topics/git/commit.md#push-options-for-gitlab-cicd)
- [流水线计划](../pipelines/schedules.md#create-a-pipeline-schedule)
- [`trigger` 关键字](../pipelines/downstream_pipelines.md#pass-inputs-to-a-downstream-pipeline)

一个流水线最多可以接受 20 个输入。

你可以将输入传递给[下游流水线](../pipelines/downstream_pipelines.md)，前提是下游流水线的配置文件使用了 [`spec:inputs`](#define-input-parameters-with-specinputs)。

例如，使用 [`trigger:inputs`](../yaml/_index.md#triggerinputs)：

{{< tabs >}}

{{< tab title="父子流水线" >}}

```yaml
trigger-job:
  trigger:
    strategy: mirror
    include:
      - local: path/to/child-pipeline.yml
        inputs:
          job-name: "defined"
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
```

{{< /tab >}}

{{< tab title="多项目流水线" >}}

```yaml
trigger-job:
  trigger:
    strategy: mirror
    project: project-group/my-downstream-project
    inputs:
      job-name: "defined"
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
```

{{< /tab >}}

{{< /tabs >}}

<a id="define-pipeline-inputs-in-external-files"></a>

#### 在外部文件中定义流水线输入

{{< history >}}

- 在极狐GitLab 18.6 中引入，带有名为 `ci_file_inputs` 的功能标志。默认禁用。
- 在极狐GitLab 18.9 中正式发布。功能标志 `ci_file_inputs` 已移除。

{{< /history >}}

你可以通过在外部文件中定义流水线输入定义，并使用 [`spec:include`](../yaml/_index.md#specinclude) 将它们包含到项目的流水线配置中，从而在多个 CI/CD 配置中重用这些定义。

创建一个包含输入定义的文件，例如在名为 `shared-inputs.yml` 的文件中：

```yaml
inputs:
  environment:
    description: "部署环境"
    options: ['staging', 'production']
  region:
    default: 'us-east-1'
```

然后，你可以在 `.gitlab-ci.yml` 中使用 `local` 包含这些外部输入：

```yaml
spec:
  include:
    - local: /shared-inputs.yml
---

deploy:
  script: echo "部署到 $[[ inputs.environment ]] 在 $[[ inputs.region ]] 区域"
```

如果文件存储在项目之外，你可以使用：

- `project` 用于另一个极狐GitLab 项目中的文件。使用完整的项目路径，并使用 `file` 定义文件名。你还可以选择定义 `ref` 来获取文件。
- `remote` 用于另一台服务器上的文件。使用文件的完整 URL。

你还可以同时包含多个输入文件，例如：
```yaml
spec:
  include:
    - local: /shared-inputs.yml
    - project: 'my-group/shared-configs'
      ref: main
      file: '/ci/common-inputs.yml'
    - remote: 'https://example.com/ci/shared-inputs.yml'
---
```

> [!note]
> 你不能将 `spec:include` 用于 [CI/CD 组件](../components/_index.md#component-spec-section) 输入。

<a id="override-inputs-from-an-external-file"></a>

#### 从外部文件覆盖输入

{{< history >}}

- 在极狐GitLab 18.9 引入。

{{< /history >}}

输入键在所有包含的文件和内联规范中必须唯一。如果你在多个包含的文件中，或在包含的文件和 `.gitlab-ci.yml` 配置的 `inputs:` 部分中定义了相同键的输入，则会返回以下错误：

```plaintext
发现重复的输入键：environment。输入键在所有包含的文件和内联规范中必须唯一。
```

要修复此错误，请确保每个输入键只定义一次，要么在包含的文件中，要么在内联 `inputs:` 部分中，但不能同时在两者中。

<a id="specify-functions-to-manipulate-input-values"></a>

## 指定用于操作输入值的函数

{{< history >}}

- 在极狐GitLab 16.3 引入。

{{< /history >}}

你可以在插值块中指定预定义函数来操作输入值。支持的格式如下：

```yaml
$[[ input.input-id | <function1> | <function2> | ... <functionN> ]]
```

关于函数：

- 只允许使用[预定义的插值函数](#predefined-interpolation-functions)。
- 单个插值块中最多可以指定 3 个函数。
- 函数按照指定的顺序执行。

```yaml
spec:
  inputs:
    test:
      default: 'test $MY_VAR'
---

test-job:
  script: echo $[[ inputs.test | expand_vars | truncate(5,8) ]]
```

在此示例中，假设输入使用默认值，且 `$MY_VAR` 是一个值为 `my value` 的未掩码项目变量：

1. 首先，函数 [`expand_vars`](#expand_vars) 将值扩展为 `test my value`。
1. 然后，[`truncate`](#truncate) 应用于 `test my value`，字符偏移量为 `5`，长度为 `8`。
1. `script` 的输出将是 `echo my value`。

<a id="predefined-interpolation-functions"></a>

### 预定义的插值函数

<a id="expand_vars"></a>

#### `expand_vars`

{{< history >}}

- 在极狐GitLab 16.5 引入。

{{< /history >}}

使用 `expand_vars` 扩展输入值中的 [CI/CD 变量](../variables/_index.md)。

只有可以[与 `include` 关键字一起使用](../yaml/includes.md#use-variables-with-include)且**未**[掩码](../variables/_index.md#mask-a-cicd-variable)的变量才能被扩展。不支持[嵌套变量扩展](../variables/where_variables_can_be_used.md#nested-variable-expansion)。

示例：

```yaml
spec:
  inputs:
    test:
      default: 'test $MY_VAR'
---

test-job:
  script: echo $[[ inputs.test | expand_vars ]]
```

在此示例中，如果 `$MY_VAR` 未掩码（在作业日志中暴露）且值为 `my value`，则输入将扩展为 `test my value`。

<a id="truncate"></a>

#### `truncate`

{{< history >}}

- 在极狐GitLab 16.3 引入。

{{< /history >}}

使用 `truncate` 缩短插值。例如：

- `truncate(<offset>,<length>)`

| 名称 | 类型 | 描述 |
| ---- | ---- | ----------- |
| `offset` | 整数 | 要偏移的字符数。 |
| `length` | 整数 | 偏移后要返回的字符数。 |

示例：

```yaml
$[[ inputs.test | truncate(3,5) ]]
```

假设 `inputs.test` 的值为 `0123456789`，则输出将为 `34567`。

<a id="posix_escape"></a>

#### `posix_escape`

{{< history >}}

- 在极狐GitLab 18.6 引入。

{{< /history >}}

使用 `posix_escape` 转义输入值中的任何 POSIX _Bourne shell_ 控制或元字符。`posix_escape` 通过在输入中相关字符前插入 ` \ ` 来转义字符。

示例：

```yaml
spec:
  inputs:
    test:
      default: |
        A string with single ' and double " quotes and   blanks
---

test-job:
  script: printf '%s\n' $[[ inputs.test | posix_escape ]]
```

在此示例中，`posix_escape` 转义了可能是 shell 控制或元字符的字符：

```console
$ printf '%s\n' A\ string\ with\ single\ \'\ and\ double\ \"\ quotes\ and\ \ \ blanks
A string with single ' and double " quotes and   blanks
```

转义后的输入保留了提供的特殊字符和间距。

> [!warning]
> 不要依赖 `posix_escape` 来保证不受信任输入值的安全。

`posix_escape` 尽力保留输入值，但某些字符组合仍可能导致意外结果。即使使用 `posix_escape`，仍可能出现以下情况：

- 字符串中包含的 Shell 代码可能会被执行。
- 单引号或双引号可能用于转义任何周围的引号。
- 变量引用可能用于访问受保护的变量。
- 输入或输出重定向可能用于读取或写入本地文件。
- Shell 使用未转义的空格将字符串拆分为多个参数。

出于安全目的，你应该确保输入是可信的。你可以使用：

- [`spec:input:type`](../yaml/_index.md#specinputstype) `number` 或 `boolean`，它们不能包含有问题的字符。
- [`spec:input:regex`](../yaml/_index.md#specinputsregex) 关键字来防止有问题的输入。
- [`spec:input:options`](../yaml/_index.md#specinputsoptions) 关键字来定义预定义的输入选项列表。

如果你将 `posix_escape` 与 `expand_vars` 结合使用，必须首先设置 `expand_vars`。否则 `posix_escape` 会转义变量中的 `$`，阻止扩展。例如：

```yaml
test-job:
  script: echo $[[ inputs.test | expand_vars | posix_escape ]]
```

<a id="troubleshooting"></a>

## 故障排除

<a id="yaml-syntax-errors-when-using-inputs-in-rules"></a>

### 在 `rules` 中使用 `inputs` 时的 YAML 语法错误

当你使用输入修改 `rules:if` 表达式时，可能会遇到[各种语法错误](../jobs/job_troubleshooting.md#this-gitlab-ci-configuration-is-invalid-for-variable-expressions)之一。

这些错误通常与 [CI/CD 变量表达式](../jobs/job_rules.md#cicd-variable-expressions) 中字符串的处理方式有关。`rules:if` 中的表达式期望将 CI/CD 变量与带引号的字符串（`'` 或 `"`）或另一个变量进行比较。当在流水线运行时将输入值插入到 `rules` 配置中时，结果值可能不是带引号的字符串或变量，从而导致错误。

例如，在要包含的配置中：

```yaml
spec:
  inputs:
    branch:
      default: $CI_DEFAULT_BRANCH
    branch2:
      default: $CI_DEFAULT_BRANCH
---

job-name:
  rules:
    - if: $CI_COMMIT_REF_NAME == $[[ inputs.branch ]]
    - if: $CI_COMMIT_REF_NAME == $[[ inputs.branch2 ]]
```

然后，在主配置文件中：

```yaml
include:
  inputs:
    branch: $CI_DEFAULT_BRANCH  # 有效
    branch2: main               # 无效
```

在此示例中：

- 使用 `branch: $CI_DEFAULT_BRANCH` 是有效的。`if:` 子句求值为 `if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH`，这是一个有效的变量表达式。变量不需要引号。
- 使用 `branch2: main` 是无效的。`if:` 子句求值为 `if: $CI_COMMIT_REF_NAME == main`，这是无效的，因为 `main` 是一个字符串但没有引号。

要解决此问题，请确保在将输入值插入配置后，表达式保持正确的格式。这可能需要额外的引号字符。例如，为使用字符串值的规则添加引号：

```yaml
rules:
  if: $CI_COMMIT_REF_NAME == "$[[ inputs.branch2 ]]"
```

对于像 [`expand_vars`](#expand_vars) 这样的插值函数，你可能还需要引用整个 `if:` 表达式。例如：

```yaml
spec:
  inputs:
    environment:
      default: "$ENVIRONMENT"
---

$[[ inputs.environment | expand_vars ]] job:
  script: echo
  rules:
    - if: '"$[[ inputs.environment | expand_vars ]]" == "production"'
```

在此示例中，引用输入和整个 `if:` 表达式可确保在计算输入后语法有效。当引号嵌套时，内层引号使用 `"`，外层引号使用 `'`，或反之。

作业名称不需要引号。