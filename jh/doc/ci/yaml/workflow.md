---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于流水线控制、规则管理和防止重复流水线的极狐GitLab CI/CD `workflow` 关键字用法。
title: '`workflow` 关键字'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在 `.gitlab-ci.yml` 文件中使用 [`workflow`](_index.md#workflow) 关键字来控制何时创建流水线。

`workflow` 关键字在作业之前进行求值。例如，如果某个作业配置为针对标签运行，但工作流阻止了标签流水线，则该作业永远不会运行。

<a id="common-if-clauses-for-workflowrules"></a>

## `workflow:rules`的常用 `if` 子句

以下是一些 `workflow: rules`的 `if` 子句示例：

| 示例规则                                        | 详情 |
|------------------------------------------------------|---------|
| `if: '$CI_PIPELINE_SOURCE == "merge_request_event"'` | 控制何时运行合并请求流水线。 |
| `if: '$CI_PIPELINE_SOURCE == "push"'`                | 控制何时运行分支流水线和标签流水线。 |
| `if: $CI_COMMIT_TAG`                                 | 控制何时运行标签流水线。 |
| `if: $CI_COMMIT_BRANCH`                              | 控制何时运行分支流水线。 |

有关更多示例，请参阅 [`rules`的常用 `if` 子句](../jobs/job_rules.md#common-if-clauses-with-predefined-variables)。

<a id="workflow-rules-examples"></a>

## `workflow: rules` 示例

在以下示例中：

- 所有 `push` 事件（分支变更和新标签）都会运行流水线。
- 提交消息以 `-draft` 结尾的推送事件不会运行流水线，因为
  它们被设置为 `when: never`。
- 计划或合并请求的流水线也不会运行，因为没有规则对它们求值为 true。

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_MESSAGE =~ /-draft$/
      when: never
    - if: $CI_PIPELINE_SOURCE == "push"
```

此示例具有严格的规则，在任何其他情况下都不会运行流水线。

或者，所有规则都可以是 `when: never`，最后再添加一条 `when: always` 规则。匹配 `when: never` 规则的流水线不会运行。所有其他类型的流水线都会运行。例如：

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
      when: never
    - if: $CI_PIPELINE_SOURCE == "push"
      when: never
    - when: always
```

此示例会阻止计划流水线或 `push`（分支和标签）流水线。最后的 `when: always` 规则会运行所有其他类型的流水线，包括合并请求流水线。

<a id="switch-between-branch-pipelines-and-merge-request-pipelines"></a>

### 在分支流水线和合并请求流水线之间切换

要在创建合并请求后让流水线从分支流水线切换为[合并请求流水线](../pipelines/merge_request_pipelines.md)，请在 `.gitlab-ci.yml` 文件中添加 `workflow: rules` 部分。

如果同时使用这两种流水线类型，可能会同时运行[重复的流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。要防止重复的流水线，请使用 [`CI_OPEN_MERGE_REQUESTS` 变量](../variables/predefined_variables.md)。

以下示例适用于仅运行分支和合并请求流水线、而不在任何其他情况下运行流水线的项目。它会运行：

- 当分支没有打开的合并请求时，运行分支流水线。
- 当分支有打开的合并请求时，运行合并请求流水线。

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never
    - if: $CI_COMMIT_BRANCH
```

如果极狐GitLab 尝试触发：

- 一个合并请求流水线，则启动该流水线。例如，向带有相关打开
  合并请求的分支推送可以触发一个合并请求流水线。
- 一个分支流水线，但该分支有打开的合并请求，则不运行该分支流水线。
  例如，分支变更、API 调用或计划流水线都可以触发分支流水线。
- 一个分支流水线，但该分支没有打开的合并请求，则运行该分支流水线。

您还可以向现有的 `workflow` 部分添加规则，以便在创建合并请求时从分支流水线切换为合并请求流水线。

将此规则添加到 `workflow` 部分的顶部，随后是已有的其他规则：

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS && $CI_PIPELINE_SOURCE == "push"
      when: never
    - # Previously defined workflow rules here
```

在分支上运行的[触发的流水线](../triggers/_index.md)会设置 `$CI_COMMIT_BRANCH`，并可能被类似的规则阻止。触发的流水线的流水线来源为 `trigger` 或 `pipeline`，因此 `&& $CI_PIPELINE_SOURCE == "push"` 可确保该规则不会阻止触发的流水线。

<a id="git-flow-with-merge-request-pipelines"></a>

### 使用合并请求流水线的 Git Flow

您可以将 `workflow: rules` 与合并请求流水线一起使用。借助这些规则，您可以在功能分支上使用[合并请求流水线功能](../pipelines/merge_request_pipelines.md)，同时保留长期分支以支持软件的多个版本。

例如，要仅为合并请求、标签和受保护分支运行流水线：

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_TAG
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_REF_PROTECTED == "true"
```

此示例假设您的默认分支或其他长期分支是[受保护的](../../user/project/repository/branches/protected.md)。

<a id="skip-pipelines-for-draft-merge-requests"></a>

### 跳过草稿合并请求的流水线

您可以使用 `workflow: rules` 来跳过草稿合并请求的流水线。这种方法可以节省计算资源，直到开发完成。

使用 `CI_MERGE_REQUEST_DRAFT` 变量检查合并请求是否处于草稿状态。此变量会自动检测极狐GitLab 支持的所有草稿格式。

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" && $CI_MERGE_REQUEST_DRAFT == "true"
      when: never
    - when: always

stages:
  - build

build-job:
  stage: build
  script:
    - echo "Testing"
```

> [!note]
> `CI_MERGE_REQUEST_DRAFT` 变量在极狐GitLab 17.10 中引入。
> 对于更早的版本，请改用 `CI_MERGE_REQUEST_TITLE` 配合正则表达式。

<a id="troubleshooting"></a>

## 故障排除

<a id="merge-request-stuck-with-checking-pipeline-status-message"></a>

### 合并请求卡在 `Checking pipeline status.` 消息

如果合并请求显示 `Checking pipeline status.`，但该消息一直不消失（“加载指示器”一直旋转），则可能是由 `workflow:rules` 导致的。如果项目启用了[**流水线必须成功**](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)，但 `workflow:rules` 阻止了合并请求的流水线运行，就可能出现此问题。

例如，使用此工作流时，合并请求无法合并，因为没有流水线可以运行：

```yaml
workflow:
  rules:
    - changes:
        - .gitlab/**/**.md
      when: never
```
