---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 CircleCI 迁移
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您使用 CircleCI，可以将您的 CI/CD 流水线迁移到 [极狐GitLab CI/CD](../_index.md)。
两个平台都使用 YAML 配置文件定义流水线，并按阶段运行作业。
因此，CircleCI 的大多数概念在极狐GitLab CI/CD 中都有直接对应的概念。

<a id="configyml-vs-gitlab-ciyml"></a>

## `config.yml` 与 `.gitlab-ci.yml` 对比

CircleCI 的 `config.yml` 配置文件定义了脚本、作业和工作流（在极狐GitLab 中称为“阶段”）。在极狐GitLab 中，采用类似的方法，在代码仓库的根目录中使用 `.gitlab-ci.yml` 文件。

<a id="jobs"></a>

### 作业

在 CircleCI 中，作业是执行特定任务的一系列步骤的集合。在极狐GitLab 中，[作业](../jobs/_index.md) 也是配置文件中的基本元素。极狐GitLab CI/CD 中不需要 `checkout` 关键字，因为代码仓库会自动获取。

CircleCI 作业定义示例：

```yaml
jobs:
  job1:
    steps:
      - checkout
      - run: "execute-script-for-job1"
```

极狐GitLab CI/CD 中相同作业定义的示例：

```yaml
job1:
  script: "execute-script-for-job1"
```

<a id="docker-image-definition"></a>

### Docker 镜像定义

CircleCI 在作业级别定义镜像，极狐GitLab CI/CD 也支持此操作。此外，极狐GitLab CI/CD 支持全局设置此配置，供所有未定义 `image` 的作业使用。

CircleCI 镜像定义示例：

```yaml
jobs:
  job1:
    docker:
      - image: ruby:2.6
```

极狐GitLab CI/CD 中相同镜像定义的示例：

```yaml
job1:
  image: ruby:2.6
```

<a id="workflows"></a>

### 工作流

CircleCI 使用 `workflows` 来确定作业的运行顺序，以及运行是并发的、顺序的、定时的还是手动的。极狐GitLab CI/CD 中的等效功能称为 [阶段](../yaml/_index.md#stages)。同一阶段的作业并行运行，并且只有在前一阶段完成后才会运行。默认情况下，当某个作业失败时，下一阶段的执行会被跳过，但也可以允许在[作业失败后](../yaml/_index.md#allow_failure)继续执行。

有关您可以使用的不同类型的流水线的指导，请参阅 [流水线架构概述](../pipelines/pipeline_architectures.md)。流水线可以根据您的需求进行定制，例如用于大型复杂项目或具有独立定义组件的单一代码仓库。

<a id="parallel-and-sequential-job-execution"></a>

#### 并行和顺序作业执行

以下示例展示了作业如何并行或顺序运行：

1. `job1` 和 `job2` 并行运行（在极狐GitLab CI/CD 的 `build` 阶段）。
1. `job3` 仅在 `job1` 和 `job2` 成功完成后运行（在 `test` 阶段）。
1. `job4` 仅在 `job3` 成功完成后运行（在 `deploy` 阶段）。

使用 `workflows` 的 CircleCI 示例：

```yaml
version: 2
jobs:
  job1:
    steps:
      - checkout
      - run: make build dependencies
  job2:
    steps:
      - run: make build artifacts
  job3:
    steps:
      - run: make test
  job4:
    steps:
      - run: make deploy

workflows:
  version: 2
  jobs:
    - job1
    - job2
    - job3:
        requires:
          - job1
          - job2
    - job4:
        requires:
          - job3
```

在极狐GitLab CI/CD 中使用 `stages` 实现相同工作流的示例：

```yaml
stages:
  - build
  - test
  - deploy

job1:
  stage: build
  script: make build dependencies

job2:
  stage: build
  script: make build artifacts

job3:
  stage: test
  script: make test

job4:
  stage: deploy
  script: make deploy
  environment: production
```

<a id="scheduled-run"></a>

#### 定时运行

您可以在极狐GitLab UI 中[按 cron 计划调度流水线](../pipelines/schedules.md)。您也可以使用 [rules](../yaml/_index.md#rules) 来在定时流水线中包含或排除作业。

CircleCI 定时工作流示例：

```yaml
commit-workflow:
  jobs:
    - build
scheduled-workflow:
  triggers:
    - schedule:
        cron: "0 1 * * *"
        filters:
          branches:
            only: try-schedule-workflow
  jobs:
    - build
```

在极狐GitLab CI/CD 中使用 [`rules`](../yaml/_index.md#rules) 实现相同定时流水线的示例：

```yaml
job1:
  script:
    - make build
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule" && $CI_COMMIT_REF_NAME == "try-schedule-workflow"
```

保存流水线配置后，您可以在 [极狐GitLab UI](../pipelines/schedules.md#create-a-pipeline-schedule) 中配置 cron 计划，也可以在 UI 中启用或禁用计划。

<a id="manual-run"></a>

#### 手动运行

CircleCI 手动工作流示例：

```yaml
release-branch-workflow:
  jobs:
    - build
    - testing:
        requires:
          - build
    - deploy:
        type: approval
        requires:
          - testing
```

在极狐GitLab CI/CD 中使用 [`when: manual`](../jobs/job_control.md#create-a-job-that-must-be-run-manually) 实现相同工作流的示例：

```yaml
deploy_prod:
  stage: deploy
  script:
    - echo "Deploy to production server"
  when: manual
  environment: production
```

<a id="filter-job-by-branch"></a>

### 按分支筛选作业

[Rules](../yaml/_index.md#rules) 是一种用于确定作业是否为特定分支运行的机制。

CircleCI 按分支筛选作业的示例：

```yaml
jobs:
  deploy:
    branches:
      only:
        - main
        - /rc-.*/
```

在极狐GitLab CI/CD 中使用 `rules` 实现相同工作流的示例：

```yaml
deploy:
  stage: deploy
  script:
    - echo "Deploy job"
  rules:
    - if: $CI_COMMIT_BRANCH == "main" || $CI_COMMIT_BRANCH =~ /^rc-/
  environment: production
```

<a id="caching"></a>

### 缓存

极狐GitLab 提供了一种缓存机制，通过重用先前下载的依赖项来加快作业的构建时间。了解 [缓存和产物之间的区别](../caching/_index.md#how-cache-is-different-from-artifacts) 对于充分利用这些功能非常重要。

CircleCI 使用缓存的作业示例：

```yaml
jobs:
  job1:
    steps:
      - restore_cache:
          key: source-v1-< .Revision >
      - checkout
      - run: npm install
      - save_cache:
          key: source-v1-< .Revision >
          paths:
            - "node_modules"
```

在极狐GitLab CI/CD 中使用 `cache` 实现相同流水线的示例：

```yaml
test_async:
  image: node:latest
  cache:  # Cache modules in between jobs
    key: $CI_COMMIT_REF_SLUG
    paths:
      - .npm/
  before_script:
    - npm ci --cache .npm --prefer-offline
  script:
    - node ./specs/start.js ./specs/async.spec.js
```

<a id="contexts-and-variables"></a>

## 上下文和变量

CircleCI 提供 [上下文](https://circleci.com/docs/contexts/)，用于在项目流水线之间安全地传递环境变量。在极狐GitLab 中，可以创建一个 [群组](../../user/group/_index.md) 来将相关项目组合在一起。[CI/CD 变量](../variables/_index.md#for-a-group) 可以存储在群组级别，独立于各个项目，并在多个项目的流水线中安全传递。

<a id="orbs"></a>

## Orbs

CircleCI Orbs 是可复用的 CI/CD 配置包。在极狐GitLab 中，[CI/CD 组件](../components/_index.md) 提供了类似的可复用流水线配置，您可以在项目之间使用。

<a id="build-environments"></a>

## 构建环境

CircleCI 提供 `executors` 作为运行特定作业的底层技术。在极狐GitLab 中，这是通过 [runners](https://gitlab.cn/docs/runner/) 完成的。

支持以下环境：

私有化部署的 runner：

- Linux
- Windows
- macOS

JihuLab.com 实例 runner：

- Linux
- [Windows](../runners/hosted_runners/windows.md)（[测试版](../../policy/development_stages_support.md#beta)）。
- [macOS](../runners/hosted_runners/macos.md)（[测试版](../../policy/development_stages_support.md#beta)）。

<a id="machine-and-specific-build-environments"></a>

### 机器和特定构建环境

[Tags](../yaml/_index.md#tags) 可用于在不同平台上运行作业，方法是告知极狐GitLab 哪些 runner 应运行这些作业。

CircleCI 在特定环境上运行作业的示例：

```yaml
jobs:
  ubuntuJob:
    machine:
      image: ubuntu-1604:201903-01
    steps:
      - checkout
      - run: echo "Hello, $USER!"
  osxJob:
    macos:
      xcode: 11.3.0
    steps:
      - checkout
      - run: echo "Hello, $USER!"
```

在极狐GitLab CI/CD 中使用 `tags` 实现相同作业的示例：

```yaml
windows job:
  stage: build
  tags:
    - windows
  script:
    - echo Hello, %USERNAME%!

osx job:
  stage: build
  tags:
    - osx
  script:
    - echo "Hello, $USER!"
```
