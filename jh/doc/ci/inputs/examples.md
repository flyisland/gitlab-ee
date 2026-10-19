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

[CI/CD 输入](_index.md)可提高 CI/CD 配置的灵活性。您可以将这些示例作为指导，配置使用输入的流水线。

<a id="include-the-same-file-multiple-times"></a>

## 多次包含同一文件

您可以多次包含同一文件，并使用不同的输入。但是，如果多个同名作业被添加到同一个流水线中，每个新增的同名作业都会覆盖之前的作业。您必须确保配置能够防止作业名称重复。

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

`path/to/my-super-linter.yml`中的配置可确保该作业每次被包含时都具有唯一的名称：

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

## 在 `inputs`中复用配置

要使用 `inputs` 复用配置，您可以使用 [YAML 锚点](../yaml/yaml_optimization.md#anchors)。

例如，要在多个支持在输入中使用 `rules` 数组的组件中复用相同的 `rules` 配置：

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

您无法在输入中使用 [`!reference` 标签](../yaml/yaml_optimization.md#reference-tags)，但[议题 424481](https://gitlab.com/gitlab-org/gitlab/-/issues/424481) 提议添加此功能。

<a id="use-inputs-with-needs"></a>

## 将 `inputs` 与 `needs` 配合使用

您可以将数组类型的输入与 [`needs`](../yaml/_index.md#needs) 配合使用，以实现复杂的作业依赖关系。

例如，在名为 `component.yml`的文件中：

```yaml
spec:
  inputs:
    first_needs:
      type: array
    second_needs:
      type: array
---

test_job:
  script: echo "this job has needs"
  needs:
    - $[[ inputs.first_needs ]]
    - $[[ inputs.second_needs ]]
```

在此示例中，输入为 `first_needs` 和 `second_needs`，两者都是[数组类型输入](_index.md#array-type)。然后，在`.gitlab-ci.yml` 文件中，您可以添加此配置并设置输入值：

```yaml
include:
  - local: 'component.yml'
    inputs:
      first_needs:
        - build1
      second_needs:
        - build2
```

当流水线启动时，`test_job`的 `needs` 数组中的项会合并为：

```yaml
test_job:
  script: echo "this job has needs"
  needs:
  - build1
  - build2
```

<a id="allow-needs-to-be-expanded-when-included"></a>

### 允许在包含时扩展 `needs`

您可以在被包含的作业中使用 [`needs`](../yaml/_index.md#needs)，同时通过 `spec:inputs` 向 `needs` 数组添加其他作业。

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
    - echo "My build job"

test-job:
  script:
    - echo "My test job"
  needs:
    - build-job
    - $[[ inputs.test_job_needs ]]
```

在此示例中：

- `test-job` 作业始终需要 `build-job`。
- 默认情况下，该测试作业不需要任何其他作业，因为 `test_job_needs:`数组输入默认为空。

要将 `test-job` 设置为在您的配置中需要另一个作业，请在包含该文件时将其添加到 `test_needs` 输入中。例如：

```yaml
include:
  - component: $CI_SERVER_FQDN/project/path/component@1.0.0
    inputs:
      test_job_needs: [my-other-job]

my-other-job:
  script:
    - echo "I want build-job` in the component to need this job too"
```

<a id="add-needs-to-an-included-job-that-doesnt-have-needs"></a>

### 向没有 `needs`的被包含作业添加 `needs`

您可以向尚未定义 `needs`的被包含作业添加 [`needs`](../yaml/_index.md#needs)。例如，在 CI/CD 组件的配置中：

```yaml
spec:
  inputs:
    test_job:
      default: test-job
---

build-job:
  script:
    - echo "My build job"

"$[[ inputs.test_job ]]":
  script:
    - echo "My test job"
```

在此示例中，`spec:inputs` 部分允许自定义作业名称。

然后，在包含该组件后，您可以使用额外的 `needs` 配置来扩展该作业。例如：

```yaml
include:
  - component: $CI_SERVER_FQDN/project/path/component@1.0.0
    inputs:
      test_job: my-test-job

my-test-job:
  needs: [my-other-job]

my-other-job:
  script:
    - echo "I want `my-test-job` to need this job"
```

<a id="use-inputs-with-include-for-more-dynamic-pipelines"></a>

## 将 `inputs` 与 `include` 配合使用，实现更动态的流水线

您可以将 `inputs` 与 `include` 配合使用，以选择要包含哪些额外的流水线配置文件。

例如：

```yaml
spec:
  inputs:
    pipeline-type:
      type: string
      default: development
      options: ['development', 'canary', 'production']
      description: "The pipeline type, which determines which set of jobs to include."
---

include:
  - local: .gitlab/ci/$[[ inputs.pipeline-type ]].gitlab-ci.yml
```

在此示例中，默认包含`.gitlab/ci/development.gitlab-ci.yml` 文件。但如果使用不同的 `pipeline-type` 输入选项，则会包含不同的配置文件。

<a id="use-cicd-inputs-in-variable-expressions"></a>

### 在变量表达式中使用 CI/CD 输入

您可以使用 [CI/CD 输入](_index.md)来自定义变量表达式。例如：

```yaml
example-job:
  script: echo "Testing"
  rules:
    - if: '"$[[ inputs.some_example ]]" == "test-branch"'
```

该表达式分两步求值：

1. 输入插值：在创建流水线之前，输入会被替换为输入值。
   在此示例中，`$[[ inputs.some_example ]]`输入会被替换为[设置的值](_index.md#set-input-values)。
   例如，如果该值为：

   - `test-branch`，则表达式变为 `if: '"test-branch" == "test-branch"'`。
   - `$CI_COMMIT_BRANCH`，则表达式变为 `if: '"$CI_COMMIT_BRANCH" == "test-branch"'`。

1. 表达式求值：输入插值完成后，极狐GitLab 会尝试创建流水线。
   在创建流水线期间，会对表达式求值，以确定要将哪些作业添加到流水线中。
