---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Control when jobs run by using rules, conditions, and variable expressions.
title: 使用 `rules` 指定作业运行时机
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [`rules`](../yaml/_index.md#rules) 关键字在流水线中包含或排除作业。

规则将按顺序评估，直到找到第一个匹配项。当找到匹配项时，根据配置，作业会被包含进流水线或从流水线中排除。

你不能在规则中使用作业脚本中创建的 dotenv 变量，因为规则是在任何作业运行之前进行评估的。

<a id="rules-examples"></a>

## `rules` 示例

以下示例使用 `if` 定义作业仅在两种特定情况下运行：

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: manual
      allow_failure: true
    - if: $CI_PIPELINE_SOURCE == "schedule"
```

- 如果流水线是针对合并请求的，则第一条规则匹配，作业将以如下属性被添加到合并请求流水线中：
  - `when: manual`（手动作业）
  - `allow_failure: true`（即使手动作业未运行，流水线也会继续运行）
- 如果流水线不是针对合并请求的，则第一条规则不匹配，接着评估第二条规则。
- 如果流水线是定时流水线，则第二条规则匹配，作业被添加到定时流水线中。由于未定义任何属性，因此将使用以下默认值添加：
  - `when: on_success`（默认）
  - `allow_failure: false`（默认）
- 在所有其他情况下，没有规则匹配，因此作业不会被添加到任何其他流水线中。

或者，你可以定义一组规则，在少数情况下排除作业，但在所有其他情况下运行它们：

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: never
    - if: $CI_PIPELINE_SOURCE == "schedule"
      when: never
    - when: on_success
```

- 如果流水线是针对合并请求的，则作业不会被添加到流水线中。
- 如果流水线是定时流水线，则作业不会被添加到流水线中。
- 在所有其他情况下，作业将被添加到流水线中，且 `when: on_success`。

> [!warning]
> 如果你使用 `when` 子句作为最终规则（不包括 `when: never`），则可能会同时启动两个流水线。推送流水线和合并请求流水线都可能由同一事件触发（向打开的合并请求的源分支推送）。有关更多详细信息，请参阅[如何避免重复流水线](#avoid-duplicate-pipelines)。

<a id="run-jobs-for-scheduled-pipelines"></a>

### 为定时流水线运行作业

你可以配置作业仅在流水线被定时触发时执行。例如：

```yaml
job:on-schedule:
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  script:
    - make world

job:
  rules:
    - if: $CI_PIPELINE_SOURCE == "push"
  script:
    - make build
```

在此示例中，`make world` 在定时流水线中运行，而 `make build` 在分支和标签流水线中运行。

<a id="skip-jobs-if-the-branch-is-empty"></a>

### 在分支为空时跳过作业

使用 [`rules:changes:compare_to`](../yaml/_index.md#ruleschangescompare_to) 在分支为空时跳过作业，从而节省 CI/CD 资源。该配置将分支与默认分支进行比较，如果分支：

- 没有更改文件，则作业不运行。
- 有更改文件，则作业运行。

例如，在一个默认分支为 `main` 的项目中：

```yaml
job:
  script:
    - echo "This job only runs for branches that are not empty"
  rules:
    - if: $CI_COMMIT_BRANCH
      changes:
        compare_to: 'refs/heads/main'
        paths:
          - '**/*'
```

此作业的规则将当前分支中的所有文件和路径递归（`**/*`）地与 `main` 分支进行比较。只有当分支中的文件发生更改时，规则才会匹配并且作业运行。

<a id="run-a-job-when-a-file-is-not-present"></a>

## 当文件不存在时运行作业

你可以使用 `rules: exists` 配置作业仅在特定文件不存在时运行。

例如，当 `example.yml` 文件不存在时，在合并请求流水线中运行作业：

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - exists:
      - "example_dir/example.yml"
      when: never
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

在此示例中，如果分支中存在 `example_dir/example.yml` 文件，则作业不运行。如果该文件不存在，则作业可以在合并请求流水线中运行。

<a id="common-if-clauses-with-predefined-variables"></a>

## 常见带有预定义变量的 `if` 子句

`rules:if` 子句通常与[预定义的 CI/CD 变量](../variables/predefined_variables.md)一起使用，尤其是 `CI_PIPELINE_SOURCE`。

以下示例将作业作为手动作业在定时流水线或推送流水线（针对分支或标签）中运行，且 `when: on_success`（默认）。它不会将作业添加到任何其他类型的流水线中。

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
      when: manual
      allow_failure: true
    - if: $CI_PIPELINE_SOURCE == "push"
```

以下示例将作业作为 `when: on_success` 作业在合并请求流水线和定时流水线中运行。它不会在任何其他类型的流水线中运行。

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_PIPELINE_SOURCE == "schedule"
```

其他常用的 `if` 子句：

- `if: $CI_COMMIT_TAG`：如果为标签推送了更改。
- `if: $CI_COMMIT_BRANCH`：如果向任何分支推送了更改。
- `if: $CI_COMMIT_BRANCH == "main"`：如果向 `main` 推送了更改。
- `if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH`：如果向默认分支推送了更改。
- `if: $CI_COMMIT_BRANCH =~ /regex-expression/`：如果提交分支匹配正则表达式。
- `if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH && $CI_COMMIT_TITLE =~ /Merge branch.*/`：如果提交分支是默认分支且提交消息标题匹配正则表达式。
- `if: $CUSTOM_VARIABLE == "value1"`：如果自定义变量 `CUSTOM_VARIABLE` 恰好等于 `value1`。

<a id="run-jobs-only-in-specific-pipeline-types"></a>

### 仅在特定流水线类型中运行作业

你可以将预定义的 CI/CD 变量与 `rules` 结合使用，来选择作业应针对哪些流水线类型运行。

下表列出了一些可以使用的变量，以及这些变量可以控制的流水线类型：

- 分支流水线，由向分支的 Git `push` 事件触发，如新提交或标签。
- 标签流水线，仅当新 Git 标签被推送到分支时运行。
- 合并请求流水线，由合并请求的更改触发，如新提交或在合并请求的流水线选项卡中选择 **Run pipeline**。
- 定时流水线。

| 变量                                      | 分支 | 标签 | 合并请求 | 定时 |
|--------------------------------------------|--------|-----|---------------|-----------|
| `CI_COMMIT_BRANCH`                         | 是    |     |               | 是       |
| `CI_COMMIT_TAG`                            |        | 是 |               | 是，如果定时流水线配置为在标签上运行。 |
| `CI_PIPELINE_SOURCE = push`                | 是    | 是 |               |           |
| `CI_PIPELINE_SOURCE = schedule`            |        |     |               | 是       |
| `CI_PIPELINE_SOURCE = merge_request_event` |        |     | 是           |           |
| `CI_MERGE_REQUEST_IID`                     |        |     | 是           |           |

例如，配置作业为合并请求流水线和定时流水线运行，但不为分支或标签流水线运行：

```yaml
job1:
  script:
    - echo
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_PIPELINE_SOURCE == "schedule"
    - if: $CI_PIPELINE_SOURCE == "push"
      when: never
```

<a id="ci_pipeline_source-predefined-variable"></a>

### `CI_PIPELINE_SOURCE` 预定义变量

使用 `CI_PIPELINE_SOURCE` 变量控制何时为以下流水线类型添加作业：

| 值                             | 描述 |
|---------------------------------|-------------|
| `api`                           | 由 [pipelines API](../../api/pipelines.md#create-a-new-pipeline) 触发的流水线。 |
| `chat`                          | 使用 [极狐GitLab ChatOps](../chatops/_index.md) 命令创建的流水线。 |
| `external`                      | 当使用极狐GitLab 之外的 CI 服务时。 |
| `external_pull_request_event`   | 当 [GitHub 上的外部拉取请求](../ci_cd_for_external_repos/_index.md#pipelines-for-external-pull-requests)被创建或更新时。 |
| `merge_request_event`           | 当合并请求被创建或更新时创建的流水线。需要启用[合并请求流水线](../pipelines/merge_request_pipelines.md)、[合并结果流水线](../pipelines/merged_results_pipelines.md)和[合并队列](../pipelines/merge_trains.md)。 |
| `ondemand_dast_scan`            | 用于 [DAST 按需扫描](../../user/application_security/dast/on-demand_scan.md)流水线。 |
| `ondemand_dast_validation`      | 用于 [DAST 按需验证](../../user/application_security/dast/profiles.md#site-profile-validation)流水线。 |
| `parent_pipeline`               | 由[父流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)触发的子流水线。在子流水线配置中使用此流水线源，以便它可以被父流水线触发。 |
| `pipeline`                      | 用于[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)。 |
| `push`                          | 由 Git 推送事件触发的流水线，包括分支和标签。 |
| `schedule`                      | 用于[定时流水线](../pipelines/schedules.md)。 |
| `security_orchestration_policy` | 用于[定时扫描执行策略](../../user/application_security/policies/scan_execution_policies.md)流水线。 |
| `trigger`                       | 使用[触发令牌](../triggers/_index.md#configure-cicd-jobs-to-run-in-triggered-pipelines)创建的流水线。 |
| `web`                           | 通过在极狐GitLab UI 中，从项目的 **Build** > **Pipelines** 部分选择 **New pipeline** 创建的流水线。 |
| `webide`                        | 使用 [Web IDE](../../user/project/web_ide/_index.md) 创建的流水线。 |

这些值与使用 [pipelines API 端点](../../api/pipelines.md#list-project-pipelines) 时 `source` 参数返回的值相同。

<a id="complex-rules"></a>

## 复杂规则

你可以在同一条规则中使用所有 `rules` 关键字，比如 `if`、`changes` 和 `exists`。只有当所有包含的关键字都评估为真时，规则才评估为真。

例如：

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $VAR == "string value"
      changes:  # 如果以下任何路径匹配到修改的文件，则包含作业并设置为 when:manual。
        - Dockerfile
        - docker/scripts/**/*
      when: manual
      allow_failure: true
```

如果 `Dockerfile` 文件或 `/docker/scripts` 中的任何文件发生了变化，并且 `$VAR == "string value"`，那么作业将以手动方式运行，并允许失败。

你可以使用括号搭配 `&&` 和 `||` 来构建更复杂的变量表达式。

```yaml
job1:
  script:
    - echo This rule uses parentheses.
  rules:
    - if: ($CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH || $CI_COMMIT_BRANCH == "develop") && $MY_VARIABLE
```

<a id="avoid-duplicate-pipelines"></a>

## 避免重复流水线

如果作业使用了 `rules`，那么一次操作（比如向分支推送提交）可能会触发多个流水线。你不需要显式地为多种类型的流水线配置规则，就可能意外触发它们。

例如：

```yaml
job:
  script: echo "This job creates double pipelines!"
  rules:
    - if: $CUSTOM_VARIABLE == "false"
      when: never
    - when: always
```

当 `$CUSTOM_VARIABLE` 为 false 时，此作业不运行，但在所有其他流水线中都会运行，包括**同时**在推送（分支）和合并请求流水线中。使用此配置，每次向打开的合并请求的源分支推送都会导致重复的流水线。

为了避免重复流水线，你可以：

- 使用 [`workflow`](../yaml/_index.md#workflow) 指定可以运行哪些类型的流水线。
- 重写规则，使作业仅在非常特定的情况下运行，并避免最终的 `when` 规则：

  ```yaml
  job:
    script: echo "This job does NOT create double pipelines!"
    rules:
      - if: $CUSTOM_VARIABLE == "true" && $CI_PIPELINE_SOURCE == "merge_request_event"
  ```

你还可以通过更改作业规则来避免推送（分支）流水线或合并请求流水线，从而避免重复流水线。但是，如果你在没有 `workflow: rules` 的情况下使用 `- when: always` 规则，极狐GitLab 会显示[流水线警告](../debugging.md#pipeline-warnings)。

例如，以下配置不会导致重复流水线，但不建议在没有 `workflow: rules` 的情况下使用：

```yaml
job:
  script: echo "This job does NOT create double pipelines!"
  rules:
    - if: $CI_PIPELINE_SOURCE == "push"
      when: never
    - when: always
```

你不应在同一作业中同时包含推送和合并请求流水线，除非使用[能防止重复流水线的 `workflow:rules`](../yaml/workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)：

```yaml
job:
  script: echo "This job creates double pipelines!"
  rules:
    - if: $CI_PIPELINE_SOURCE == "push"
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

另外，不要在同一流水线中将 `only/except` 作业与 `rules` 作业混合使用。这或许不会导致 YAML 错误，但 `only/except` 和 `rules` 不同的默认行为可能会导致难以排查的问题：

```yaml
job-with-no-rules:
  script: echo "This job runs in branch pipelines."

job-with-rules:
  script: echo "This job runs in merge request pipelines."
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

对于每次推送到具有已打开合并请求的分支的更改，都会运行重复的流水线。一个分支流水线运行单个作业（`job-with-no-rules`），而一个合并请求流水线运行另一个作业（`job-with-rules`）。没有规则的作业默认为 [`except: merge_requests`](../yaml/deprecated_keywords.md#only--except)，因此 `job-with-no-rules` 在除合并请求外的所有情况下都会运行。

<a id="reuse-rules-in-different-jobs"></a>

## 在不同作业中复用规则

使用 [`!reference` 标签](../yaml/yaml_optimization.md#reference-tags)在不同作业中复用规则。你可以将 `!reference` 规则与作业中定义的规则结合使用。例如：

```yaml
.default_rules:
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
      when: never
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

job1:
  rules:
    - !reference [.default_rules, rules]
  script:
    - echo "This job runs for the default branch, but not schedules."

job2:
  rules:
    - !reference [.default_rules, rules]
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script:
    - echo "This job runs for the default branch, but not schedules."
    - echo "It also runs for merge requests."
```

<a id="cicd-variable-expressions"></a>

## CI/CD 变量表达式

将变量表达式与 [`rules:if`](../yaml/_index.md#rulesif) 一起使用，来控制何时应将作业添加到流水线中。

你可以使用相等运算符 `==` 和 `!=` 将变量与字符串进行比较。单引号和双引号都有效。变量必须位于比较的左侧。例如：

- `if: $VARIABLE == "some value"`
- `if: $VARIABLE != "some value"`

你可以比较两个变量的值。例如：

- `if: $VARIABLE_1 == $VARIABLE_2`
- `if: $VARIABLE_1 != $VARIABLE_2`

你可以将变量与 `null` 关键字进行比较，以检查它是否已定义。例如：

- `if: $VARIABLE == null`
- `if: $VARIABLE != null`

你可以检查一个变量是否已定义但为空。例如：

- `if: $VARIABLE == ""`
- `if: $VARIABLE != ""`

你可以通过在表达式中仅使用变量名来检查变量是否已定义且不为空。例如：

- `if: $VARIABLE`

你还可以[在变量表达式中使用 CI/CD 输入](../inputs/examples.md#use-cicd-inputs-in-variable-expressions)。

<a id="compare-a-variable-to-a-regular-expression"></a>

### 将变量与正则表达式进行比较

你可以使用 `=~` 和 `!~` 运算符对变量值进行正则表达式匹配。

如果满足以下条件，表达式评估为 `true`：

- 使用 `=~` 时找到匹配项。
- 使用 `!~` 时未找到匹配项。

例如：

- `if: $VARIABLE =~ /^content.*/`
- `if: $VARIABLE !~ /^content.*/`

此外：

- 不支持单字符正则表达式（如 `/./`），会产生 `invalid expression syntax` 错误。
- 模式匹配默认区分大小写。使用 `i` 标志修饰符使模式不区分大小写。例如：`/pattern/i`。
- 只有标签或分支名称可以通过正则表达式匹配。如果提供了仓库路径，则始终按字面匹配。
- 整个模式必须用 `/` 括起来。例如，你不能使用 `issue-/.*/` 来匹配所有以 `issue-` 开头的标签名或分支名，但可以使用 `/issue-.*/`。
- `@` 符号表示引用仓库路径的开始。要在正则表达式中匹配包含 `@` 字符的引用名称，你必须使用十六进制字符码匹配 `\x40`。
- 使用锚点 `^` 和 `$` 来避免正则表达式仅匹配标签名或分支名的子字符串。例如，`/^issue-.*$/` 等效于 `/^issue-/`，而单独的 `/issue/` 也会匹配名为 `severe-issues` 的分支。
- 使用正则表达式的变量模式匹配使用 [RE2 正则表达式语法](https://github.com/google/re2/wiki/Syntax)。

<a id="store-a-regular-expression-in-a-variable"></a>

### 将正则表达式存储在变量中

`=~` 和 `!~` 表达式右侧的变量会被评估为正则表达式。该正则表达式必须用正斜杠（`/`）括起来。例如：

```yaml
variables:
  pattern: '/^ab.*/'

regex-job1:
  variables:
    teststring: 'abcde'
  script: echo "This job will run, because 'abcde' matches the /^ab.*/ pattern."
  rules:
    - if: '$teststring =~ $pattern'

regex-job2:
  variables:
    teststring: 'fghij'
  script: echo "This job will not run, because 'fghi' does not match the /^ab.*/ pattern."
  rules:
    - if: '$teststring =~ $pattern'
```

正则表达式中的变量不会被展开。例如：

```yaml
variables:
  string1: 'regex-job1'
  string2: 'regex-job2'
  pattern: '/$string2/'

regex-job1:
  script: echo "This job will NOT run, because the 'string1' variable inside the regex pattern is not expanded."
  rules:
    - if: '$CI_JOB_NAME =~ /$string1/'

regex-job2:
  script: echo "This job will NOT run, because the 'string2' variable inside the 'pattern' variable is not expanded."
  rules:
    - if: '$CI_JOB_NAME =~ $pattern'
```

<a id="join-variable-expressions-together"></a>

### 连接变量表达式

你可以使用 `&&`（与）或 `||`（或）连接多个表达式，例如：

- `$VARIABLE1 =~ /^content.*/ && $VARIABLE2 == "something"`
- `$VARIABLE1 =~ /^content.*/ && $VARIABLE2 =~ /thing$/ && $VARIABLE3`
- `$VARIABLE1 =~ /^content.*/ || $VARIABLE2 =~ /thing$/ && $VARIABLE3`

你可以使用括号将表达式分组。括号优先于 `&&` 和 `||`，因此括号中的表达式首先求值，其结果用于表达式的其余部分。对于运算符优先级，`&&` 在 `||` 之前求值。

嵌套括号以创建复杂条件，最内层括号中的表达式首先求值。例如：

- `($VARIABLE1 =~ /^content.*/ || $VARIABLE2) && ($VARIABLE3 =~ /thing$/ || $VARIABLE4)`
- `($VARIABLE1 =~ /^content.*/ || $VARIABLE2 =~ /thing$/) && $VARIABLE3`
- `$CI_COMMIT_BRANCH == "my-branch" || (($VARIABLE1 == "thing" || $VARIABLE2 == "thing") && $VARIABLE3)`

<a id="negate-expressions"></a>

### 取反表达式

{{< history >}}

- 在极狐GitLab 18.11 引入。

{{< /history >}}

你可以使用 `!` 运算符来取反一个表达式或表达式的一部分。例如：

- `if: "!$VAR1"`：当变量为空或未定义时为真。
- `if: !($VAR1 == "my variable")`：当变量值不匹配 `my variable` 时为真。
- `if: $VAR1 && !$VAR2`：当 `VAR1` 存在且不为空，且 `VAR2` 不存在或为空时为真。
- `if: !($VAR1 || $VAR2)`：仅当两个变量都不存在或为空时为真。
- `if: !($VAR1 && $VAR2)`：当任一变量不存在或为空时为真。

> [!warning]
> `!` 运算符检查变量是否为空或未定义，而不是其值是否为 `false` 或 `0`。例如：
>
> - `!"false"` 评估为 `false`，因为字符串 `"false"` 不为空（非空字符串为真值）。
> - `!"0"` 也评估为 `false`，因为字符串不为空。
> - `!""` 评估为 `true`，因为字符串为空（空字符串为假值）。
>
> 要检查特定的值，请使用比较运算符，例如 `!($VAR == "false")` 或 `!($VAR == "0")`。

<a id="migrate-from-only-or-except-to-rules"></a>

## 从 `only` 或 `except` 迁移到 `rules`

使用 `rules` 和 CI/CD 变量表达式来重现已弃用的 [`only` 和 `except` 关键字](../yaml/deprecated_keywords.md#only--except)的相同行为。

例如，从以下已弃用的配置开始：

```yaml
job1:
  script: echo
  only:
    - main
    - /^stable-branch.*$/
    - schedules

job2:
  script: echo
  except:
    - main
    - /^issue-.*$/
    - merge_requests
```

在此示例中：

- `job1` 使用 `only` 在以下情况下运行流水线：
  - 分支是默认分支（`main`）。
  - 分支名称匹配模式 `/^stable-branch.*$/`。
  - 流水线按计划运行。
- `job2` 使用 `except` 在以下情况下跳过流水线：
  - 分支是默认分支（`main`）。
  - 分支名称匹配模式 `/^issue-.*$/`。
  - 流水线是合并请求流水线。

要使用 `rules` 创建类似的流水线配置，请使用 CI/CD 变量表达式。例如，从 `only` 和 `except` 直接迁移到 `rules`：

```yaml
job1:
  script: echo
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_BRANCH =~ /^stable-branch.*$/
    - if: $CI_PIPELINE_SOURCE == "schedule"

job2:
  script: echo
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: never
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: never
    - if: $CI_COMMIT_BRANCH =~ /^issue-.*$/
      when: never
    - when: on_success
```

使用 `rules` 后，两个作业的行为与使用 `only` 和 `except` 时相同。但是，你可以简化 `job2` 以避免使用 `when: never` 规则。

定义 `job2` 应该在何时运行，而不是何时不运行。例如，如果 `job2` 应该为除默认分支外的所有分支运行，以及为标签运行：

```yaml
job2:
  script: echo
  rules:
    - if: $CI_COMMIT_BRANCH != $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_TAG
```

在此示例中，`job2` 在分支不是默认分支时运行，以及在创建新 Git 标签时运行。否则，作业不运行。

<a id="troubleshooting"></a>

## 故障排除

<a id="unexpected-behavior-from-regular-expression-matching-with-"></a>

### 使用 `=~` 进行正则表达式匹配时的意外行为

当使用 `=~` 字符时，确保比较的右侧始终包含一个有效的正则表达式。

如果比较的右侧不是用 `/` 字符括起来的有效正则表达式，则表达式会以意外方式求值。在这种情况下，比较会检查左侧是否是右侧的子字符串。例如，`"23" =~ "1234"` 评估为 true，这与 `"23" =~ /1234/` 评估为 false 的结果相反。

你不应将流水线配置为依赖此行为。