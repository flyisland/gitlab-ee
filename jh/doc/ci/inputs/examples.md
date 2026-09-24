---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 输入示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[CI/CD 输入](_index.md) 提高了 CI/CD 配置的灵活性。使用这些示例作为配置流水线以使用输入的指南。

<a id="include-the-same-file-multiple-times"></a>

## 多次包含同一文件

你可以多次包含同一文件，并使用不同的输入。但是，如果多个同名作业被添加到同一个流水线中，每个额外的作业都会覆盖之前的同名作业。你必须确保配置能防止重复的作业名称。

例如，使用不同的输入多次包含同一配置：

```yaml
include:
  - local: path/to/my-super-linter.yml
    inputs:
      linter: docs
      lint-path: "doc/"
  - local: path/to/my-super-linter.yml
    inputs:
      linter: yaml
      lint-path: "data/yaml/"
```

`path/to/my-super-linter.yml` 中的配置确保作业每次被包含时都具有唯一的名称：

```yaml
spec:
  inputs:
    linter:
    lint-path:
---
"run-$[[ inputs.linter ]]-lint":
  script: ./lint --$[[ inputs.linter ]] --path=$[[ inputs.lint-path ]]
```

<a id="reuse-configuration-in-inputs"></a>

## 在 `输入` 中重用配置

要在 `输入` 中重用配置，你可以使用 [YAML 锚点](../yaml/yaml_optimization.md#anchors)。

例如，要在多个组件的输入中重用相同的 `规则` 配置，这些组件支持 `规则` 数组：

```yaml
.my-job-rules: &my-job-rules
  - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

include:
  - component: $CI_SERVER_FQDN/project/path/component1@main
    inputs:
      job-rules: *my-job-rules
  - component: $CI_SERVER_FQDN/project/path/component2@main
    inputs:
      job-rules: *my-job-rules
```

你不能在输入中使用 [`!reference` 标签](../yaml/yaml_optimization.md#reference-tags)，但 issue 424481 提议添加此功能。

<a id="use-inputs-with-needs"></a>

## 将 `输入` 与 `依赖` 结合使用

你可以将数组类型的输入与 [`依赖`](../yaml/_index.md#needs) 结合使用，以实现复杂的作业依赖。

例如，在名为 `component.yml` 的文件中：

```yaml
spec:
  inputs:
    first_needs:
      type: array
    second_needs:
      type: array
---

test_job:
  script: echo "这个作业有依赖"
  needs:
    - $[[ inputs.first_needs ]]
    - $[[ inputs.second_needs ]]
```

在此示例中，输入是 `first_needs` 和 `second_needs`，两者都是 [数组类型输入](_index.md#array-type)。然后，在 `.gitlab-ci.yml` 文件中，你可以添加此配置并设置输入值：

```yaml
include:
  - local: 'component.yml'
    inputs:
      first_needs:
        - build1
      second_needs:
        - build2
```

当流水线启动时，`test_job` 的 `依赖` 数组中的项会被合并为：

```yaml
test_job:
  script: echo "这个作业有依赖"
  needs:
  - build1
  - build2
```

<a id="allow-needs-to-be-expanded-when-included"></a>

### 允许在包含时扩展 `依赖`

你可以在包含的作业中使用 [`依赖`](../yaml/_index.md#needs)，同时也可以通过 `spec:inputs` 向 `依赖` 数组添加额外的作业。

例如：

```yaml
spec:
  inputs:
    test_job_needs:
      type: array
      default: []
---

build-job:
  script:
    - echo "我的构建作业"

test-job:
  script:
    - echo "我的测试作业"
  needs:
    - build-job
    - $[[ inputs.test_job_needs ]]
```

在此示例中：
- `test-job` 作业始终需要 `build-job`。
- 默认情况下，测试作业不需要任何其他作业，因为 `test_job_needs:` 数组输入默认为空。

要在配置中设置 `test-job` 需要另一个作业，请在包含文件时将其添加到 `test_needs` 输入中。例如：

```yaml
include:
  - component: $CI_SERVER_FQDN/project/path/component@1.0.0
    inputs:
      test_job_needs: [my-other-job]

my-other-job:
  script:
    - echo "我希望组件中的 build-job 也需要此作业"
```

<a id="add-needs-to-an-included-job-that-doesnt-have-needs"></a>

### 向没有 `依赖` 的包含作业添加 `依赖`

你可以向尚未定义 `依赖` 的包含作业添加 [`依赖`](../yaml/_index.md#needs)。例如，在 CI/CD 组件的配置中：

```yaml
spec:
  inputs:
    test_job:
      default: test-job
---

build-job:
  script:
    - echo "我的构建作业"

"$[[ inputs.test_job ]]":
  script:
    - echo "我的测试作业"
```

在此示例中，`spec:inputs` 部分允许自定义作业名称。

然后，在包含组件之后，你可以使用额外的 `依赖` 配置来扩展作业。例如：

```yaml
include:
  - component: $CI_SERVER_FQDN/project/path/component@1.0.0
    inputs:
      test_job: my-test-job

my-test-job:
  needs: [my-other-job]

my-other-job:
  script:
    - echo "我希望 `my-test-job` 需要此作业"
```

<a id="use-inputs-with-include-for-more-dynamic-pipelines"></a>

## 将 `输入` 与 `include` 结合使用以实现更动态的流水线

你可以将 `输入` 与 `include` 结合使用，以选择要包含哪些额外的流水线配置文件。

例如：

```yaml
spec:
  inputs:
    pipeline-type:
      type: string
      default: development
      options: ['development', 'canary', 'production']
      description: "流水线类型，决定包含哪组作业。"
---

include:
  - local: .gitlab/ci/$[[ inputs.pipeline-type ]].gitlab-ci.yml
```

在此示例中，默认包含 `.gitlab/ci/development.gitlab-ci.yml` 文件。但如果使用了不同的 `pipeline-type` 输入选项，则会包含不同的配置文件。

<a id="use-cicd-inputs-in-variable-expressions"></a>

### 在变量表达式中使用 CI/CD 输入

你可以使用 [CI/CD 输入](_index.md) 来自定义变量表达式。例如：

```yaml
example-job:
  script: echo "测试"
  rules:
    - if: '"$[[ inputs.some_example ]]" == "test-branch"'
```

表达式分两步评估：

1. 输入插值：在创建流水线之前，输入会被替换为输入值。在此示例中，`$[[ inputs.some_example ]]` 输入会被替换为 [设置值](_index.md#set-input-values)。例如，如果值为：
   - `test-branch`，表达式变为 `if: '"test-branch" == "test-branch"'`。
   - `$CI_COMMIT_BRANCH`，表达式变为 `if: '"$CI_COMMIT_BRANCH" == "test-branch"'`。

1. 表达式评估：输入插值后，极狐GitLab 尝试创建流水线。在流水线创建过程中，会评估表达式以确定将哪些作业添加到流水线中。