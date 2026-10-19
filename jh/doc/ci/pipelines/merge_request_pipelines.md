---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何在极狐GitLab CI/CD 中使用合并请求流水线，以便高效测试变更、运行针对性作业，并在合并前提升代码质量。
title: 合并请求流水线
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以配置流水线，使其在您每次更改合并请求中的源分支时运行。此类流水线称为合并请求流水线。

这些流水线会在以下情况下运行：

- 从包含一个或多个提交的源分支创建新的合并请求。
- 向合并请求的源分支推送新提交。
- 转到合并请求中的**流水线**标签页，然后选择**运行流水线**。

合并请求流水线：

- 仅针对源分支的内容运行，忽略目标分支的内容。
- 在流水线列表中显示 `merge request` 标记。

要运行测试源分支和目标分支合并结果的流水线，请使用[合并结果流水线](merged_results_pipelines.md)。

<a id="prerequisites"></a>

## 先决条件

要使用合并请求流水线：

- 您项目的 `.gitlab-ci.yml` 文件必须包含与 `CI_PIPELINE_SOURCE == "merge_request_event"` 匹配的作业规则或工作流规则。
- 您必须拥有源项目的开发者、维护者或所有者角色，才能运行合并请求流水线。
- 您的代码仓库必须是极狐GitLab 代码仓库，而不是[外部代码仓库](../ci_cd_for_external_repos/_index.md)。

<a id="configure-merge-request-pipelines"></a>

## 配置合并请求流水线

要配置合并请求流水线，您必须在 `.gitlab-ci.yml` 文件中配置作业，使其在 `CI_PIPELINE_SOURCE` 等于 `merge_request_event` 时运行。

> [!note]
> 在 `include:` 中定义的规则（例如使用 `include:component`）不满足
> 此要求。您必须直接在 `.gitlab-ci.yml`中定义匹配的 `rules:` 或 `workflow: rules`。

您可以使用 `rules` 配置单个作业，或使用 `workflow: rules` 控制整个流水线。

<a id="configure-individual-jobs"></a>

### 配置单个作业

使用 [`rules`](../yaml/_index.md#rules) 关键字配置单个作业在合并请求流水线中运行。例如：

```yaml
job1:
  script:
    - echo "This job runs in merge request pipelines"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

您还可以根据文件变更来控制作业的运行时机：

```yaml
test:
  script:
    - echo "This job always runs in merge request pipelines"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

lint:
  script:
    - echo "This job runs only when JavaScript files change"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - "*.js"
```

<a id="configure-the-entire-pipeline"></a>

### 配置整个流水线

使用 [`workflow: rules`](../yaml/_index.md#workflowrules) 关键字配置流水线中的所有作业在合并请求流水线中运行。例如：

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

job1:
  script:
    - echo "This job runs in merge request pipelines"
```

有关更多 `workflow` 示例，请参阅：

- [在分支流水线和合并请求流水线之间切换](../yaml/workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)
- [使用合并请求流水线的 Git Flow](../yaml/workflow.md#git-flow-with-merge-request-pipelines)

要[在合并请求流水线中使用安全扫描工具](../../user/application_security/detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)，请使用 CI/CD 变量 `AST_ENABLE_MR_PIPELINES` 或 `latest` 模板版本。

<a id="run-a-merge-request-pipeline-with-custom-inputs"></a>

## 使用自定义输入运行合并请求流水线

如果您的 `.gitlab-ci.yml` 定义了[流水线输入](../inputs/_index.md)，您可以在手动运行新的合并请求流水线时自定义输入值。您还可以在同一表单中设置 [CI/CD 变量](../variables/_index.md)。

先决条件：

- 您的 `.gitlab-ci.yml` 文件必须[已配置为合并请求流水线](#configure-merge-request-pipelines)。
- 您的 `.gitlab-ci.yml` 文件还必须定义 `spec: inputs` 部分。
- 您必须至少拥有源项目的开发者角色。

要使用自定义输入运行合并请求流水线：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的项目。
1. 选择**代码** > **合并请求**并打开您的合并请求。
1. 选择**流水线**标签页。
1. 选择**运行流水线**下拉列表（{{< icon name="chevron-down" >}}），
   然后选择**使用修改后的值运行流水线**。
1. 新的流水线表单打开，并预填了合并请求的源分支。
   根据需要修改输入值并设置任何 CI/CD 变量。
1. 选择**运行流水线**。

<a id="use-with-forked-projects"></a>

## 与复刻项目一起使用

在复刻中工作的外部贡献者无法在父项目中创建流水线。

从复刻提交到父项目的合并请求会触发一个流水线，该流水线：

- 在复刻（源）项目中创建并运行，而不是在父（目标）项目中。
- 使用复刻项目的 CI/CD 配置、资源和项目 CI/CD 变量。

复刻的流水线在父项目中显示 **fork** 徽章。

<a id="run-pipelines-in-the-parent-project"></a>

### 在父项目中运行流水线

父项目中的项目成员可以为从复刻项目提交的合并请求触发合并请求流水线。此流水线：

- 在父（目标）项目中创建并运行，而不是在复刻（源）项目中。
- 使用复刻项目分支中存在的 CI/CD 配置。
- 使用父项目的 CI/CD 设置、资源和项目 CI/CD 变量。
- 使用触发流水线的父项目成员的权限。

在复刻项目合并请求中运行流水线，以确保合并后的流水线在父项目中通过。此外，如果您不信任复刻项目的 runner，在父项目中运行流水线会使用父项目受信任的 runner。

> [!warning]
> 复刻合并请求可能包含恶意代码，当流水线运行时，这些代码会试图窃取父项目中的密钥，
> 甚至在合并之前就可能发生。作为审核人，请在触发流水线之前仔细检查
> 合并请求中的变更。除非您通过 API 或
> [`/rebase` 快捷操作](../../user/project/quick_actions.md#rebase)触发流水线，
> 否则极狐GitLab 会显示一条警告，您必须接受该警告后流水线才会运行。否则不会显示任何警告。

先决条件：

- 父项目的 `.gitlab-ci.yml` 文件必须配置为
  [在合并请求流水线中运行作业](#prerequisites)。
- 您必须是父项目的成员，并具有[运行 CI/CD 流水线的权限](../../user/permissions.md#project-cicd)。
  如果分支受保护，您可能需要额外的权限。
- 复刻项目必须对运行流水线的用户[可见](../../user/public_access.md)。
  否则，合并请求中不会显示**流水线**标签页。

要使用 UI 为来自复刻项目的合并请求在父项目中运行流水线：

1. 在合并请求中，转到**流水线**标签页。
1. 选择**运行流水线**。您必须阅读并接受警告，否则流水线不会运行。

<a id="prevent-pipelines-from-fork-projects"></a>

### 阻止来自复刻项目的流水线

要阻止用户在父项目中为复刻项目运行新的流水线，请使用[项目 API](../../api/projects.md#update-a-project) 禁用 `ci_allow_fork_pipelines_to_run_in_parent_project` 设置。

> [!warning]
> 在禁用该设置之前创建的流水线不受影响，会继续运行。
> 如果您在较旧的流水线中重新运行作业，该作业将使用与
> 流水线最初创建时相同的上下文。

<a id="available-predefined-variables"></a>

## 可用的预定义变量

使用合并请求流水线时，您可以使用：

- 与分支流水线中可用的[预定义变量](../variables/predefined_variables.md)完全相同的所有变量。
- 仅合并请求流水线中的作业可用的[其他预定义变量](../variables/predefined_variables.md#predefined-variables-for-merge-request-pipelines)。

<a id="control-access-to-protected-variables-and-runners"></a>

## 控制对受保护变量和 runner 的访问

您可以控制合并请求流水线对[受保护 CI/CD 变量](../variables/_index.md#protect-a-cicd-variable)和[受保护 runner](../runners/configure_runners.md#prevent-runners-from-revealing-sensitive-information)的访问。

合并请求流水线只有在以下情况下才能访问这些受保护资源：

- 源分支和目标分支都[受保护](../../user/project/repository/branches/protected.md)。
- 触发流水线的用户对目标分支具有推送/合并访问权限。
- 源分支和目标分支都属于同一项目。

来自复刻代码仓库的合并请求流水线无法访问这些受保护资源。

先决条件：

- 在项目中拥有维护者或所有者角色。

要控制对受保护变量和 runner 的访问：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 在**在合并请求流水线中访问受保护资源**下，选中或清除
   **允许合并请求流水线访问受保护变量和 runner** 复选框。
