---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab CI/CD `workflow` 关键字用于流水线控制、规则管理以及防止重复流水线。
title: '`workflow` 关键字'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在您的 `.gitlab-ci.yml` 文件中使用 `workflow` 关键字来控制流水线的创建时机。

`workflow` 关键字在作业之前被评估。例如，如果某个作业被配置为针对标签运行，但 workflow 阻止了标签流水线，则该作业永远不会运行。

<a id="common-if-clauses-for-workflowrules"></a>

## 常见的 `workflow:rules` 的 `if` 子句

一些用于 `workflow: rules` 的示例 `if` 子句：

| 示例规则                                        | 详情 |
|------------------------------------------------------|---------|
| `if: '$CI_PIPELINE_SOURCE == "merge_request_event"'` | 控制何时运行合并请求流水线。 |
| `if: '$CI_PIPELINE_SOURCE == "push"'`                | 控制何时运行分支流水线和标签流水线。 |
| `if: $CI_COMMIT_TAG`                                 | 控制何时运行标签流水线。 |
| `if: $CI_COMMIT_BRANCH`                              | 控制何时运行分支流水线。 |

有关更多示例，请参阅[常见的 `rules` 的 `if` 子句](../jobs/job_rules.md#common-if-clauses-with-predefined-variables)。

<a id="workflow-rules-examples"></a>

## `workflow: rules` 示例

在以下示例中：

- 所有 `push` 事件（对分支的更改和新标签）都会运行流水线。
- 提交信息以 `-draft` 结尾的 push 事件不会运行流水线，因为它们被设置为 `when: never`。
- 对于调度或合并请求的流水线也不会运行，因为没有任何规则评估为 true。

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_MESSAGE =~ /-draft$/
      when: never
    - if: $CI_PIPELINE_SOURCE == "push"
```

此示例具有严格的规则，流水线在其他任何情况下都**不会**运行。

或者，所有规则都可以是 `when: never`，最后再加上一个 `when: always` 规则。匹配 `when: never` 规则的流水线不会运行。其他所有类型的流水线都会运行。例如：

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
      when: never
    - if: $CI_PIPELINE_SOURCE == "push"
      when: never
    - when: always
```

此示例阻止了调度或 `push`（分支和标签）流水线。最后的 `when: always` 规则会运行其他所有类型的流水线，**包括**合并请求流水线。

<a id="switch-between-branch-pipelines-and-merge-request-pipelines"></a>

### 在分支流水线和合并请求流水线之间切换

为了在创建合并请求后使流水线从分支流水线切换到[合并请求流水线](../pipelines/merge_request_pipelines.md)，请在您的 `.gitlab-ci.yml` 文件中添加一个 `workflow: rules` 部分。

如果同时使用这两种流水线类型，可能会同时运行[重复的流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。要防止重复的流水线，请使用 [`CI_OPEN_MERGE_REQUESTS` 变量](../variables/predefined_variables.md)。

以下示例针对一个仅运行分支和合并请求流水线的项目，不会为其他情况运行流水线。它运行：

- 当分支未打开合并请求时运行分支流水线。
- 当分支已打开合并请求时运行合并请求流水线。

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never
    - if: $CI_COMMIT_BRANCH
```

如果极狐GitLab 尝试触发：

- 合并请求流水线，则启动流水线。例如，可以通过推送至具有关联打开合并请求的分支来触发合并请求流水线。
- 分支流水线，但该分支存在打开的合并请求，则不运行分支流水线。例如，可以通过分支变更、API 调用、调度流水线等方式触发分支流水线。
- 分支流水线，且该分支没有打开的合并请求，则运行分支流水线。

您还可以在现有的 `workflow` 部分添加一条规则，在合并请求创建时从分支流水线切换到合并请求流水线。

将这条规则添加到 `workflow` 部分的顶部，后面跟着之前已存在的其他规则：

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS && $CI_PIPELINE_SOURCE == "push"
      when: never
    - # 之前已定义的工作流规则在此处
```

在分支上运行的[触发流水线](../triggers/_index.md)会设置 `$CI_COMMIT_BRANCH`，可能会被类似的规则阻止。触发流水线的流水线来源是 `trigger` 或 `pipeline`，因此 `&& $CI_PIPELINE_SOURCE == "push"` 可确保该规则不会阻止触发流水线。

<a id="git-flow-with-merge-request-pipelines"></a>

### 使用合并请求流水线的 Git Flow

您可以结合使用 `workflow: rules` 与合并请求流水线。借助这些规则，您可以在特性分支中使用[合并请求流水线功能](../pipelines/merge_request_pipelines.md)，同时保留长期分支来支持多个软件版本。

例如，仅为合并请求、标签和受保护分支运行流水线：

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_TAG
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_REF_PROTECTED == "true"
```

此示例假设您的默认分支或其他长期分支已[受保护](../../user/project/repository/branches/protected.md)。

<a id="skip-pipelines-for-draft-merge-requests"></a>

### 跳过草稿合并请求的流水线

您可以使用 `workflow: rules` 来跳过草稿合并请求的流水线。此方法在开发完成前可节省计算资源。

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
> `CI_MERGE_REQUEST_DRAFT` 变量在极狐GitLab 17.10 中引入。对于更早的版本，请改用 `CI_MERGE_REQUEST_TITLE` 配合正则表达式。

<a id="troubleshooting"></a>

## 故障排查

<a id="merge-request-stuck-with-checking-pipeline-status-message"></a>

### 合并请求卡在 `Checking pipeline status.` 消息

如果合并请求显示 `Checking pipeline status.`，但消息始终不消失（“加载图标”一直在旋转），则可能是由于 `workflow:rules` 导致。如果项目启用了**流水线必须成功**功能，但 `workflow:rules` 阻止了为该合并请求运行流水线，则会出现此问题。

例如，使用此工作流时，合并请求无法合并，因为没有流水线可以运行：

```yaml
workflow:
  rules:
    - changes:
        - .gitlab/**/**.md
      when: never
```