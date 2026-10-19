---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 发布 CI/CD 示例
---

极狐GitLab 的发布功能非常灵活，可以配置为匹配您的工作流程。本页面提供示例 CI/CD 发布作业。每个示例都演示了在 CI/CD 流水线中创建发布的一种方法。

<a id="create-a-release-when-a-git-tag-is-created"></a>

## 创建 Git 标签时创建发布

在此 CI/CD 示例中，发布由以下事件之一触发：

- 将 Git 标签推送到代码仓库。
- 在 UI 中创建 Git 标签。

如果您希望手动创建 Git 标签并由此创建发布，可以使用此方法。

> [!note]
> 在 UI 中创建 Git 标签时，请勿提供发布说明。提供发布说明
> 会创建发布，从而导致流水线失败。

以下示例 `.gitlab-ci.yml` 文件摘录中的要点：

- `rules` 节定义了何时将作业添加到流水线。
- Git 标签用于发布的名称和描述。

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG                 # Run this job when a tag is created
  script:
    - echo "running release_job"
  release:                               # See https://docs.gitlab.com/ci/yaml/#release for available properties
    tag_name: '$CI_COMMIT_TAG'
    description: '$CI_COMMIT_TAG'
```

<a id="create-a-release-when-a-commit-is-merged-to-the-default-branch"></a>

## 提交合并到默认分支时创建发布

在此 CI/CD 示例中，当您将提交合并到默认分支时触发发布。如果您的发布工作流程不会手动创建标签，可以使用此方法。

以下示例 `.gitlab-ci.yml` 文件摘录中的要点：

- Git 标签、描述和引用会在流水线中自动创建。
- 如果您手动创建标签，则 `release_job` 作业不会运行。

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                  # Do not run this job when a tag is created manually
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # Run this job when commits are pushed or merged to the default branch
  script:
    - echo "running release_job for $TAG"
  release:                                         # See https://docs.gitlab.com/ci/yaml/#release for available properties
    tag_name: 'v0.$CI_PIPELINE_IID'                # The version is incremented per pipeline.
    description: 'v0.$CI_PIPELINE_IID'
    ref: '$CI_COMMIT_SHA'                          # The tag is created from the pipeline SHA.
```

> [!note]
> 在 `before_script` 或 `script`中设置的环境变量无法在同一作业中
> 展开。详细了解
> [如何使变量可供展开](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/6400)。

<a id="create-release-metadata-in-a-custom-script"></a>

## 在自定义脚本中创建发布元数据

在此 CI/CD 示例中，发布准备工作被拆分为多个独立的作业，以获得更大的灵活性：

- `prepare_job` 作业生成发布元数据。可以使用任何镜像来运行该作业，
  包括自定义镜像。生成的元数据存储在变量文件 `variables.env`中。
  该元数据会[传递给下游作业](../../../ci/variables/dotenv_variables.md#pass-variables-to-later-jobs)。
- `release_job` 使用变量文件中的内容来创建发布，所用元数据
  通过变量文件传递给它。该作业必须使用
  `registry.gitlab.com/gitlab-org/cli:latest` 镜像，因为它包含 `glab` CLI。

```yaml
prepare_job:
  stage: prepare                                              # This stage must run before the release stage
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                             # Do not run this job when a tag is created manually
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH             # Run this job when commits are pushed or merged to the default branch
  script:
    - echo "EXTRA_DESCRIPTION=some message" >> variables.env  # Generate the EXTRA_DESCRIPTION and TAG environment variables
    - echo "TAG=v$(cat VERSION)" >> variables.env             # and append to the variables.env file
  artifacts:
    reports:
      dotenv: variables.env                                   # Use artifacts:reports:dotenv to expose the variables to other jobs

release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  needs:
    - job: prepare_job
      artifacts: true
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                  # Do not run this job when a tag is created manually
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # Run this job when commits are pushed or merged to the default branch
  script:
    - echo "running release_job for $TAG"
  release:
    name: 'Release $TAG'
    description: 'Created using the CLI $EXTRA_DESCRIPTION'  # $EXTRA_DESCRIPTION and the $TAG
    tag_name: '$TAG'                                                 # variables must be defined elsewhere
    ref: '$CI_COMMIT_SHA'                                            # in the pipeline. For example, in the
    milestones:                                                      # prepare_job
      - 'm1'
      - 'm2'
      - 'm3'
    released_at: '2020-07-15T08:00:00Z'  # Optional, is auto generated if not defined, or can use a variable.
    assets:
      links:
        - name: 'asset1'
          url: 'https://example.com/assets/1'
        - name: 'asset2'
          url: 'https://example.com/assets/2'
          filepath: '/pretty/url/1' # optional
          link_type: 'other' # optional
```

<a id="skip-multiple-pipelines-when-creating-a-release"></a>

## 创建发布时跳过多个流水线

如果关联的标签尚不存在，使用 CI/CD 作业创建发布可能会触发多个流水线。要了解这种情况可能如何发生，请考虑以下工作流程：

- 先创建标签，再创建发布：
  1. 从 UI 创建标签或推送标签。
  1. 触发标签流水线，并运行 `release` 作业。
  1. 创建发布。
- 先创建发布，再创建标签：
  1. 当提交被推送或合并到默认分支时，触发流水线。该流水线运行 `release` 作业。
  1. 创建发布。
  1. 创建标签。
  1. 触发标签流水线。该流水线也会运行 `release` 作业。

在第二种工作流程中，`release` 作业会在多个流水线中运行。要防止这种情况，您可以使用 [`workflow:rules` 关键字](../../../ci/yaml/_index.md#workflowrules)来确定发布作业是否应在标签流水线中运行：

```yaml
release_job:
  rules:
    - if: $CI_COMMIT_TAG
      when: never                                  # Do not run this job in a tag pipeline
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # Run this job when commits are pushed or merged to the default branch
  script:
    - echo "Create release"
  release:
    name: 'My awesome release'
    tag_name: '$CI_COMMIT_TAG'
```
