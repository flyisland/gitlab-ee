---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合规流水线（已弃用）
description: Compliance pipelines (deprecated in 17.3, planned to be removed in 19.0) enables centralized CI/CD control for labeled projects. Replaced by pipeline execution policies.
---

<!--- start_remove The following content will be removed on remove_date: '2026-08-15' -->

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 17.3 中[已弃用](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/159841)，
> 并计划在 20.0 中移除。请改用[流水线执行策略类型](../application_security/policies/pipeline_execution_policies.md)。
> 这是一个重大变更。有关更多信息，请参见[迁移指南](#pipeline-execution-policies-migration)。

群组所有者可以在与其他项目分开的项目中配置合规流水线。默认情况下，合规流水线配置（例如 `.compliance-gitlab-ci.yml`）会代替标记项目的流水线配置（例如 `.gitlab-ci.yml`）运行。

但是，合规流水线配置可以引用标记项目的 `.gitlab-ci.yml` 文件，以便：

- 合规流水线也可以运行标记项目流水线的作业。这允许对流水线配置进行集中控制。
- 合规流水线中定义的作业和变量不能被标记项目的 `.gitlab-ci.yml` 文件中的变量更改。

> [!note]
> 由于一个[已知问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/414004)，项目流水线必须首先包含在合规流水线配置的顶部，以防止项目覆盖下游设置。

有关更多信息，请参见：

- [示例配置](#example-configuration)，了解如何配置运行来自标记项目流水线配置的作业的合规流水线。
- [创建合规流水线](../../tutorials/compliance_pipeline/_index.md)教程。

<a id="pipeline-execution-policies-migration"></a>

## 流水线执行策略迁移

流水线执行策略旨在整合和简化扫描及流水线强制执行。合规流水线在极狐GitLab 17.3 中已弃用，并将在极狐GitLab 19.0 中移除。

流水线执行策略通过流水线执行策略中链接的单独 YAML 文件（例如 `pipeline-execution.yml`）中提供的配置来扩展项目的 `.gitlab-ci.yml` 文件。

默认情况下，在创建新的合规框架时，系统会引导您使用流水线执行策略类型，而不是合规流水线。

必须迁移现有的合规流水线。客户应尽快从合规流水线迁移到新的[流水线执行策略类型](../application_security/policies/pipeline_execution_policies.md)。

<a id="migrate-an-existing-compliance-framework"></a>

### 迁移现有合规框架

要将现有合规框架迁移为使用流水线执行策略类型：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. [编辑](compliance_frameworks/_index.md#create-edit-or-delete-a-compliance-framework)现有合规框架。
1. 在出现的横幅中，选择 **将流水线迁移到策略** 以在安全策略中创建新策略。
1. 再次编辑合规框架以移除合规流水线。

有关更多信息，请参见[安全策略项目](../application_security/policies/enforcement/security_policy_projects.md)。

如果您在迁移过程中收到 `Pipeline execution policy error: Job names must be unique` 错误，请参见[相关故障排除信息](#error-job-names-must-be-unique)。

<a id="effect-on-labeled-projects"></a>

## 对标记项目的影响

用户无法知道已配置合规流水线，并且可能会困惑为什么自己的流水线根本没有运行，或者包含他们自己未定义的作业。

在标记项目上编写流水线时，没有任何迹象表明已配置合规流水线。项目级别的唯一标记是合规框架标签本身，但该标签并不说明框架是否配置了合规流水线。

因此，请与项目用户沟通合规流水线配置，以减少不确定性和困惑。

<a id="multiple-compliance-frameworks"></a>

### 多个合规框架

您可以[将多个配置了合规流水线的合规框架应用于单个项目](compliance_frameworks/_index.md#apply-a-compliance-framework-to-a-project)。
在这种情况下，只有第一个应用于项目的合规框架的合规流水线会包含在项目流水线中。

要确保正确的合规流水线包含在项目中：

1. 从项目中移除所有合规框架。
1. 将具有正确合规流水线的合规框架应用于项目。
1. 将其他合规框架应用于项目。

<a id="configure-a-compliance-pipeline"></a>

## 配置合规流水线

{{< history >}}

- 在极狐GitLab 15.11 中引入，合规框架移至合规中心。

{{< /history >}}

要配置合规流水线：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 选择 **框架** 部分。
1. 选择 **新框架** 部分，添加合规框架信息，包括合规框架配置的路径。使用 `path/file.y[a]ml@group-name/project-name` 格式。例如：

   - `.compliance-ci.yml@gitlab-org/gitlab`。
   - `.compliance-ci.yaml@gitlab-org/gitlab`。

此配置由应用了合规框架标签的项目继承。在应用了合规框架标签的项目中，合规流水线配置将代替标记项目自身的流水线配置运行。

在标记项目中运行流水线的用户必须至少对合规项目具有报告者角色。

当用于强制执行扫描执行时，此功能与[扫描执行策略](../application_security/policies/scan_execution_policies.md)有一些重叠。
这两个功能的用户体验[尚未统一](https://gitlab.com/groups/gitlab-org/-/epics/7312)。

<a id="important-considerations"></a>

## 重要注意事项

> [!warning]
> 在迁移同一项目中的现有合规流水线之前，请勿启用[流水线执行策略](../application_security/policies/pipeline_execution_policies.md)。当两者都配置时，合规流水线会替换标准项目流水线，但流水线执行策略会基于原始项目流水线应用。这会产生不可预测的行为，具体取决于流水线执行策略策略和 CI/CD 配置，并可能导致作业重复、流水线失败或缺少关键的安全和合规检查。合规流水线已[弃用](../../update/deprecations.md#compliance-pipelines)。您应尽快迁移现有合规流水线，并对所有新实施使用流水线执行策略。

<a id="example-configuration"></a>

### 示例配置

以下示例 `.compliance-gitlab-ci.yml` 包含 `include` 关键字，以确保标记项目的流水线配置也被执行。

```yaml
include:  # 执行单个项目的配置（如果项目包含 .gitlab-ci.yml）
  - project: '$CI_PROJECT_PATH'
    file: '$CI_CONFIG_PATH'
    ref: '$CI_COMMIT_SHA' # 必须定义，否则 MR 流水线始终使用默认分支
    rules:
      - if: $CI_PROJECT_PATH != "my-group/project-1" # 必须在托管此配置的项目以外的项目上运行。

# 允许合规团队控制阶段/作业的顺序和交错。
# 未定义作业的阶段将保持隐藏。
stages:
  - pre-compliance
  - build
  - test
  - pre-deploy-compliance
  - deploy
  - post-compliance

variables:  # 可以通过在项目的本地 .gitlab-ci.yml 中设置作业特定变量来覆盖
  FOO: sast

sast:  # 这些属性都不能被项目的本地 .gitlab-ci.yml 覆盖
  variables:
    FOO: sast
  image: ruby:2.6
  stage: pre-compliance
  rules:
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS && $CI_PIPELINE_SOURCE == "push"
      when: never
    - when: always  # 或 when: on_success
  allow_failure: false
  before_script:
    - "# 无前置脚本。"
  script:
    - echo "正在运行 $FOO"
  after_script:
    - "# 无后置脚本。"

健全性检查:
  image: ruby:2.6
  stage: pre-deploy-compliance
  rules:
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS && $CI_PIPELINE_SOURCE == "push"
      when: never
    - when: always  # 或 when: on_success
  allow_failure: false
  before_script:
    - "# 无前置脚本。"
  script:
    - echo "正在运行 $FOO"
  after_script:
    - "# 无后置脚本。"

审计追踪:
  image: ruby:2.7
  stage: post-compliance
  rules:
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS && $CI_PIPELINE_SOURCE == "push"
      when: never
    - when: always  # 或 when: on_success
  allow_failure: false
  before_script:
    - "# 无前置脚本。"
  script:
    - echo "正在运行 $FOO"
  after_script:
    - "# 无后置脚本。"
```

`include` 定义中的 `rules` 配置避免了循环包含，以防合规流水线必须能够在宿主项目本身中运行。
如果您的合规流水线仅在标记项目中运行，则可以省略它。

<a id="compliance-pipelines-and-custom-pipeline-configuration-hosted-externally"></a>

#### 合规流水线与外部托管的自定义流水线配置

前面的示例假设所有项目都在同一项目中托管其流水线配置。
如果任何项目使用[外部托管的配置](../../ci/pipelines/settings.md#specify-a-custom-cicd-configuration-file)，
则示例配置不起作用。有关更多详细信息，请参见[议题 393960](https://jihulab.com/gitlab-cn/gitlab/-/issues/393960)。

对于使用外部托管配置的项目，您可以尝试以下解决方法：

- 必须调整示例合规流水线配置中的 `include` 部分。
  例如，使用 [`include:rules`](../../ci/yaml/includes.md#use-rules-with-include)：

  ```yaml
  include:
    # 如果定义了自定义路径变量，则包含项目的外部配置文件。
    - project: '$PROTECTED_PIPELINE_CI_PROJECT_PATH'
      file: '$PROTECTED_PIPELINE_CI_CONFIG_PATH'
      ref: '$PROTECTED_PIPELINE_CI_REF'
      rules:
        - if: $PROTECTED_PIPELINE_CI_PROJECT_PATH && $PROTECTED_PIPELINE_CI_CONFIG_PATH && $PROTECTED_PIPELINE_CI_REF
    # 如果未定义任何自定义路径变量，则照常包含项目的内部配置文件。
    - project: '$CI_PROJECT_PATH'
      file: '$CI_CONFIG_PATH'
      ref: '$CI_COMMIT_SHA'
      rules:
        - if: $PROTECTED_PIPELINE_CI_PROJECT_PATH == null || $PROTECTED_PIPELINE_CI_CONFIG_PATH == null || $