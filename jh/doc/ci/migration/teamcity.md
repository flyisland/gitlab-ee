---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 TeamCity 迁移
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您正在从 TeamCity 迁移到极狐GitLab CI/CD，可以创建 CI/CD 流水线来复制并增强您的 TeamCity 工作流。

<a id="key-similarities-and-differences"></a>

## 主要相似点和不同点

极狐GitLab CI/CD 和 TeamCity 都是具有某些相似之处的 CI/CD 工具。极狐GitLab 和 TeamCity 均：

- 足够灵活，可运行大多数语言的作业。
- 可部署在本地或云上。

此外，两者之间还存在一些重要区别：

- 极狐GitLab CI/CD 流水线在 YAML 格式的配置文件中配置，您可以手动编辑或使用[流水线编辑器](../pipeline_editor/_index.md)进行编辑。
  TeamCity 流水线可以通过 UI 或使用 Kotlin DSL 进行配置。
- 极狐GitLab 是一个 DevSecOps 平台，内置 SCM、容器镜像仓库、安全扫描等。
  TeamCity 则需要单独的解决方案来实现这些功能，通常通过集成提供。

<a id="configuration-file"></a>

### 配置文件

TeamCity 可以通过 [UI](https://www.jetbrains.com/help/teamcity/creating-and-editing-build-configurations.html) 或以 [Kotlin DSL 格式的 `Teamcity Configuration` 文件](https://www.jetbrains.com/help/teamcity/kotlin-dsl.html)进行配置。
TeamCity 构建配置是一组指令，用于定义如何构建、测试和部署软件项目。配置包含在 TeamCity 中自动化 CI/CD 流程所需的参数和设置。

在极狐GitLab 中，与 TeamCity 构建配置对应的是 `.gitlab-ci.yml` 文件。
该文件定义了项目的 CI/CD 流水线，指定构建、测试和部署项目所需的阶段、作业和命令。

<a id="comparison-of-features-and-concepts"></a>

## 功能与概念对比

许多 TeamCity 功能和概念在极狐GitLab 中都有提供相同功能的对应项。

<a id="jobs"></a>

### 作业

TeamCity 使用构建配置，这些配置包含多个构建步骤，您可以在其中定义命令或脚本来执行任务，例如编译代码、运行测试和打包产物。

以下是一个 Kotlin DSL 格式的 TeamCity 项目配置示例，它构建 Dockerfile 并运行单元测试：

```kotlin
package _Self.buildTypes

import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildFeatures.perfmon
import jetbrains.buildServer.configs.kotlin.buildSteps.dockerCommand
import jetbrains.buildServer.configs.kotlin.buildSteps.nodeJS
import jetbrains.buildServer.configs.kotlin.triggers.vcs

object BuildTest : BuildType({
    name = "Build & Test"

    vcs {
        root(HttpsGitlabComRutshahCicdDemoGitRefsHeadsMain)
    }

    steps {
        dockerCommand {
            id = "DockerCommand"
            commandType = build {
                source = file {
                    path = "Dockerfile"
                }
            }
        }
        nodeJS {
            id = "nodejs_runner"
            workingDir = "app"
            shellScript = """
                npm install jest-teamcity --no-save
                npm run test -- --reporters=jest-teamcity
            """.trimIndent()
        }
    }

    triggers {
        vcs {
        }
    }

    features {
        perfmon {
        }
    }
})
```

在极狐GitLab CI/CD 中，您可以定义包含要执行任务的作业作为流水线的一部分。
每个作业可以包含一个或多个构建步骤。

上一示例对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH != "main" || $CI_PIPELINE_SOURCE != "merge_request_event"
      when: never
    - when: always

stages:
  - build
  - test

build-job:
  image: docker:20.10.16
  stage: build
  services:
    - docker:20.10.16-dind
  script:
    - docker build -t cicd-demo:0.1 .

run_unit_tests:
  image: node:17-alpine3.14
  stage: test
  before_script:
    - cd app
    - npm install
  script:
    - npm test
  artifacts:
    when: always
    reports:
      junit: app/junit.xml
```

<a id="pipeline-triggers"></a>

### 流水线触发器

[TeamCity 触发器](https://www.jetbrains.com/help/teamcity/configuring-build-triggers.html)定义了触发构建的条件，包括 VCS 变更、定时触发器或由其他构建触发的构建。

在极狐GitLab CI/CD 中，流水线可以针对各种事件自动触发，例如分支或合并请求更改以及新标签。流水线还可以手动触发，使用 [API](../triggers/_index.md) 或通过[定时流水线](../pipelines/schedules.md)。更多信息请参见 [CI/CD 流水线](../pipelines/_index.md)。

<a id="variables"></a>

### 变量

在 TeamCity 中，您在构建配置设置中[定义构建参数和环境变量](https://www.jetbrains.com/help/teamcity/using-build-parameters.html)。

在极狐GitLab 中，使用 `variables` 关键字定义 [CI/CD 变量](../variables/_index.md)。
使用变量可以重用配置数据、实现更动态的配置或存储重要值。
变量可以全局定义，也可以按作业定义。

例如，一个使用变量的极狐GitLab CI/CD `.gitlab-ci.yml` 文件：

```yaml
default:
  image: alpine:latest

stages:
  - greet

variables:
  NAME: "Fern"

english:
  stage: greet
  variables:
    GREETING: "Hello"
  script:
    - echo "$GREETING $NAME"

spanish:
  stage: greet
  variables:
    GREETING: "Hola"
  script:
    - echo "$GREETING $NAME"
```

<a id="artifacts"></a>

### 产物

TeamCity 中的构建配置允许您定义构建过程中生成的[产物](https://www.jetbrains.com/help/teamcity/build-artifact.html)。

在极狐GitLab 中，任何作业都可以使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字定义一组在作业完成时存储的产物。[产物](../jobs/job_artifacts.md)是可以在后续作业中用于测试或部署的文件。

例如，一个使用产物的极狐GitLab CI/CD `.gitlab-ci.yml` 文件：

```yaml
stage:
  - generate
  - use

generate_cat:
  stage: generate
  script:
    - touch cat.txt
    - echo "meow" > cat.txt
  artifacts:
    paths:
      - cat.txt
    expire_in: 1 week

use_cat:
  stage: use
  script:
    - cat cat.txt
```

<a id="runners"></a>

### Runners

极狐GitLab 中与 [TeamCity 代理](https://www.jetbrains.com/help/teamcity/build-agent.html)等价的是 Runner。

在极狐GitLab CI/CD 中，Runner 是执行作业的服务。如果您使用 JihuLab.com，可以使用[实例 Runner 队列](../runners/_index.md)来运行作业，而无需配置您自己的私有化部署 Runner。

关于 Runner 的一些关键细节：

- Runner 可以[配置](../runners/runners_scope.md)为在实例范围内共享、群组范围内共享或专用于单个项目。
- 您可以使用 [`tags` 关键字](../runners/configure_runners.md#control-jobs-that-a-runner-can-run)进行更精细的控制，并将 Runner 与特定作业关联。例如，您可以为需要专用、更强大或特定硬件的作业使用标签。
- 极狐GitLab 拥有 [Runner 自动缩放](https://gitlab.cn/docs/runner/runner_autoscale/)功能。
  使用自动缩放仅在需要时配置 Runner，并在不需要时缩减规模。

<a id="teamcity-build-features-and-plugins"></a>

### TeamCity 构建功能和插件

TeamCity 中通过构建功能和插件启用的一些功能，在极狐GitLab CI/CD 中通过 CI/CD 关键字和功能原生支持。

| TeamCity 插件                                                                                                                      | 极狐GitLab 功能 |
|------------------------------------------------------------------------------------------------------------------------------------|----------------|
| [代码覆盖率](https://www.jetbrains.com/help/teamcity/configuring-test-reports-and-code-coverage.html#Code+Coverage+in+TeamCity)    | [代码覆盖率](../testing/code_coverage/_index.md)和[测试覆盖率可视化](../testing/code_coverage/_index.md#coverage-visualization) |
| [单元测试报告](https://www.jetbrains.com/help/teamcity/configuring-test-reports-and-code-coverage.html)                            | [JUnit 测试报告产物](../yaml/artifacts_reports.md#artifactsreportsjunit)和[单元测试报告](../testing/unit_test_reports.md) |
| [通知](https://www.jetbrains.com/help/teamcity/configuring-notifications.html)                                                      | [通知邮件](../../user/profile/notifications.md)和 [Slack](../../user/project/integrations/gitlab_slack_application.md) |

<a id="planning-and-performing-a-migration"></a>

## 规划和执行迁移

以下建议步骤列表源自对能够快速完成极狐GitLab CI/CD 迁移的组织的观察。

<a id="create-a-migration-plan"></a>

### 制定迁移计划

在开始迁移之前，您应该制定一个[迁移计划](plan_a_migration.md)，为迁移做好准备。

对于从 TeamCity 的迁移，请问自己以下问题以做好准备：

- 如今 TeamCity 中的作业使用了哪些插件？
  - 您确切知道这些插件的功能吗？
- TeamCity 代理上安装了哪些软件？
- 是否使用了任何共享库？
- 您是如何通过 TeamCity 进行身份验证的？是使用 SSH 密钥、API 令牌还是其他密钥？
- 是否有其他项目需要从流水线访问？
- TeamCity 中是否有用于访问外部服务的凭据？例如 Ansible Tower、Artifactory 或其他云供应商或部署目标？

<a id="prerequisites"></a>

### 前提条件

在进行任何迁移工作之前，您应首先：

1. 熟悉极狐GitLab。
   - 阅读[极狐GitLab CI/CD 关键功能](../_index.md)。
   - 按照教程创建[您的第一个极狐GitLab 流水线](../quick_start/_index.md)和[更复杂的流水线](../quick_start/tutorial.md)，执行构建、测试和部署静态站点。
   - 查看 [CI/CD YAML 语法参考](../yaml/_index.md)。
1. 设置并配置极狐GitLab。
1. 测试您的极狐GitLab 实例。
   - 确保 [Runner](../runners/_index.md) 可用，方法是使用共享的 JihuLab.com Runner 或安装新的 Runner。

<a id="migration-steps"></a>

### 迁移步骤

1. 将项目从您的 SCM 解决方案迁移到极狐GitLab。
   - （推荐）您可以使用可用的[导入器](../../user/import/_index.md)自动从外部 SCM 提供商批量导入。
   - 您也可以[通过 URL 导入代码仓库](../../user/import/third_party_systems/repo_by_url.md)。
1. 在每个项目中创建一个 `.gitlab-ci.yml` 文件。
1. 将 TeamCity 配置迁移到极狐GitLab CI/CD 作业，并配置它们直接在合并请求中显示结果。
1. 使用[云部署模板](../cloud_deployment/_index.md)、[环境](../environments/_index.md)和[极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md) 迁移部署作业。
1. 检查是否有任何 CI/CD 配置可以跨不同项目重用，然后创建并共享 [CI/CD 组件](../components/_index.md)。
1. 请参阅[流水线效率](../pipelines/pipeline_efficiency.md)，了解如何使您的极狐GitLab CI/CD 流水线更快、更高效。

如果您有任何这里没有解答的问题，[极狐GitLab 社区论坛](https://forum.jihulab.com/)可能是一个很好的资源。