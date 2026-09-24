---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 发布 CI/CD 示例
---

极狐GitLab 发布功能非常灵活，可以配置为匹配您的工作流程。本页面展示了 CI/CD 发布作业示例。每个示例展示了在 CI/CD 流水线中创建发布的不同方法。

<a id="create-a-release-when-a-git-tag-is-created"></a>

## 在创建 Git 标签时创建发布

在此 CI/CD 示例中，发布由以下事件之一触发：

- 推送 Git 标签到代码仓库。
- 在 UI 中创建 Git 标签。

如果您更喜欢手动创建 Git 标签并随后创建发布，可以使用此方法。

> [!note]
> 在 UI 中创建 Git 标签时，请不要提供发布说明。提供发布说明会创建发布，导致流水线失败。

以下示例 `.gitlab-ci.yml` 文件摘录中的关键点：

- `rules` 节定义了作业何时被添加到流水线中。
- Git 标签用于发布的名称和描述。

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG                 # 当创建标签时运行此作业
  script:
    - echo "running release_job"
  release:                               # 请参阅 https://gitlab.cn/docs/ci/yaml/#release 了解可用属性
    tag_name: '$CI_COMMIT_TAG'
    description: '$CI_COMMIT_TAG'
```

<a id="create-a-release-when-a-commit-is-merged-to-the-default-branch"></a>

## 在提交合并到默认分支时创建发布

在此 CI/CD 示例中，当您将提交合并到默认分支时触发发布。如果您的发布工作流程不手动创建标签，可以使用此方法。

以下示例 `.gitlab-ci.yml` 文件摘录中的关键点：

- Git 标签、描述及引用在流水线中自动创建。
- 如果您手动创建标签，`release_job` 作业不会运行。

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                  # 手动创建标签时不运行此作业
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # 当提交推送或合并到默认分支时运行此作业
  script:
    - echo "running release_job for $TAG"
  release:                                         # 请参阅 https://gitlab.cn/docs/ci/yaml/#release 了解可用属性
    tag_name: 'v0.$CI_PIPELINE_IID'                # 版本号随每次流水线递增。
    description: 'v0.$CI_PIPELINE_IID'
    ref: '$CI_COMMIT_SHA'                          # 该标签基于流水线 SHA 创建。
```

> [!note]
> 在 `before_script` 或 `script` 中设置的环境变量无法在同一个作业中展开使用。详细了解
> [可能实现变量展开](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/6400)。

<a id="create-release-metadata-in-a-custom-script"></a>

## 在自定义脚本中创建发布元数据

在此 CI/CD 示例中，发布准备被拆分为独立的作业，以获得更大的灵活性：

- `prepare_job` 作业生成发布元数据。任何镜像都可以用来运行此作业，包括自定义镜像。生成的元数据存储在变量文件 `variables.env` 中。
  该元数据会[传递给下游作业](../../../ci/variables/dotenv_variables.md#pass-variables-to-later-jobs)。
- `release_job` 使用来自变量文件的内容来创建发布，这些元数据通过变量文件传递给它。此作业必须使用
  `registry.gitlab.com/gitlab-org/cli:latest` 镜像，因为它包含了 `glab` 命令行工具。

```yaml
prepare_job:
  stage: prepare                                              # 此阶段必须在发布阶段之前运行
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                             # 手动创建标签时不运行此作业
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH             # 当提交推送或合并到默认分支时运行此作业
  script:
    - echo "EXTRA_DESCRIPTION=some message" >> variables.env  # 生成 EXTRA_DESCRIPTION 和 TAG 环境变量
    - echo "TAG=v$(cat VERSION)" >> variables.env             # 并追加到 variables.env 文件
  artifacts:
    reports:
      dotenv: variables.env                                   # 使用 artifacts:reports:dotenv 将变量暴露给其他作业

release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  needs:
    - job: prepare_job
      artifacts: true
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                  # 手动创建标签时不运行此作业
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # 当提交推送或合并到默认分支时运行此作业
  script:
    - echo "running release_job for $TAG"
  release:
    name: 'Release $TAG'
    description: '通过命令行工具创建 $EXTRA_DESCRIPTION'  # $EXTRA_DESCRIPTION 和 $TAG
    tag_name: '$TAG'                                         # 变量必须在流水线中其他地方定义。
    ref: '$CI_COMMIT_SHA'                                    # 例如，在 prepare_job 中定义
    milestones:                                              # 
      - 'm1'
      - 'm2'
      - 'm3'
    released_at: '2020-07-15T08:00:00Z'  # 可选，如果不定义则会自动生成，也可以使用变量。
    assets:
      links:
        - name: 'asset1'
          url: 'https://example.com/assets/1'
        - name: 'asset2'
          url: 'https://example.com/assets/2'
          filepath: '/pretty/url/1' # 可选
          link_type: 'other' # 可选
```

<a id="skip-multiple-pipelines-when-creating-a-release"></a>

## 在创建发布时跳过多个流水线

使用 CI/CD 作业创建发布时，如果关联的标签尚不存在，可能会触发多个流水线。为了理解这种情况如何发生，请考虑以下工作流程：

- 先创建标签，再创建发布：
  1. 从 UI 创建或推送标签。
  1. 标签流水线被触发，运行 `release` 作业。
  1. 发布被创建。
- 先创建发布，再创建标签：
  1. 当提交推送或合并到默认分支时触发流水线，流水线运行 `release` 作业。
  1. 发布被创建。
  1. 标签被创建。
  1. 标签流水线被触发，该流水线同样运行 `release` 作业。

在第二种工作流程中，`release` 作业会在多个流水线中运行。为了防止这种情况，您可以使用 [`workflow:rules` 关键字](../../../ci/yaml/_index.md#workflowrules)来决定 `release` 作业是否应该在标签流水线中运行：

```yaml
release_job:
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                  # 不在标签流水线中运行此作业
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # 当提交推送或合并到默认分支时运行此作业
  script:
    - echo "Create release"
  release:
    name: 'My awesome release'
    tag_name: '$CI_COMMIT_TAG'
```