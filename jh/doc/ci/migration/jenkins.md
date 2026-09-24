---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Jenkins 迁移
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果你正在从 Jenkins 迁移到极狐GitLab CI/CD，你可以创建 CI/CD 流水线，复制并增强你的 Jenkins 工作流。

<a id="key-similarities-and-differences"></a>

## 主要相似点和差异点

极狐GitLab CI/CD 和 Jenkins 都是 CI/CD 工具，有一些相似之处。极狐GitLab 和 Jenkins 都：

- 使用阶段来分组作业。
- 支持基于容器的构建。

此外，两者之间还有一些重要差异：

- 极狐GitLab CI/CD 流水线全部配置在一个 YAML 格式的配置文件中。Jenkins 使用 Groovy 格式的配置文件（声明式流水线）或 Jenkins DSL（脚本式流水线）。
- 极狐GitLab 提供 JihuLab.com（多租户 SaaS 服务），你也可以运行自己的 [私有化部署](../../subscriptions/manage_subscription.md) 实例。Jenkins 部署必须自托管。
- 极狐GitLab 提供内置的源代码管理（SCM）。Jenkins 需要单独的 SCM 解决方案来存储代码。
- 极狐GitLab 提供内置的容器镜像仓库。Jenkins 需要单独的解决方案来存储容器镜像。
- 极狐GitLab 提供内置的代码扫描模板。Jenkins 需要第三方插件来扫描代码。

<a id="comparison-of-features-and-concepts"></a>

## 功能与概念对比

许多 Jenkins 的功能和概念在极狐GitLab 中都有对应，并提供相同功能。

<a id="configuration-file"></a>

### 配置文件

Jenkins 可以使用 Groovy 格式的 [`Jenkinsfile`](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) 进行配置。极狐GitLab CI/CD 默认使用 `.gitlab-ci.yml` 文件。

一个 `Jenkinsfile` 示例：

```groovy
pipeline {
    agent any

    stages {
        stage('hello') {
            steps {
                echo "Hello World"
            }
        }
    }
}
```

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
stages:
  - hello

hello-job:
  stage: hello
  script:
    - echo "Hello World"
```

<a id="jenkins-pipeline-syntax"></a>

### Jenkins 流水线语法

Jenkins 配置由包含 sections 和 directives 的 `pipeline` 块组成。极狐GitLab CI/CD 有类似功能，通过 YAML 关键词进行配置。

<a id="sections"></a>

#### Sections

| Jenkins  | 极狐GitLab         | 说明 |
|----------|----------------|-------------|
| `代理`  | `镜像`        | Jenkins 流水线在代理上执行，`代理` 部分定义了流水线如何执行以及要使用的 Docker 容器。极狐GitLab 作业在 Runner 上执行，`镜像` 关键词定义了要使用的容器。你可以在 Kubernetes 或任何主机上配置自己的 Runner。 |
| `后置`   | `after_script` 或 `阶段` | Jenkins 的 `后置` 部分定义了在阶段或流水线末尾应执行的操作。在极狐GitLab 中，使用 `after_script` 来定义在作业末尾要运行的命令，使用 `before_script` 来定义在作业中其他命令之前执行的操作。使用 `阶段` 来选择作业应运行的确切阶段。极狐GitLab 支持 `.pre` 和 `.post` 阶段，这些阶段始终在所有其他定义的阶段之前或之后运行。 |
| `stages` | `stages`       | Jenkins 的阶段是作业组。极狐GitLab CI/CD 也使用阶段，但更加灵活。你可以有多个阶段，每个阶段可以包含多个独立的作业。在顶层使用 `stages` 定义阶段及其执行顺序，并在作业级别使用 `stage` 为该作业定义所在阶段。 |
| `steps`  | `script`       | Jenkins 的 `steps` 定义要执行的内容。极狐GitLab CI/CD 使用类似的 `script` 部分。`script` 部分是一个 YAML 数组，每个条目对应要按顺序运行的命令。 |

<a id="directives"></a>

#### Directives

| Jenkins       | 极狐GitLab         | 说明 |
|---------------|----------------|-------------|
| `environment` | `variables`    | Jenkins 使用 `environment` 来管理环境变量。极狐GitLab CI/CD 使用 `variables` 关键词来定义 CI/CD 变量，这些变量既可以在作业执行期间使用，也可以用于更动态的流水线配置。这些变量也可以在极狐GitLab UI 的 CI/CD 设置中进行设置。 |
| `options`     | 不适用 | Jenkins 使用 `options` 进行额外配置，包括超时和重试值。极狐GitLab 不需要单独的 options 部分，所有配置都作为 CI/CD 关键词添加到作业或流水线级别，例如 `timeout` 或 `retry`。 |
| `parameters`  | 不适用 | 在 Jenkins 中，可以在触发流水线时要求提供参数。极狐GitLab 通过 CI/CD 变量处理参数，这些变量可以在许多地方定义，包括流水线配置、项目设置、在运行时通过 UI 或 API 手动设置。 |
| `triggers`    | `rules`        | 在 Jenkins 中，`triggers` 定义了流水线应何时再次运行，例如通过 cron 表达式。极狐GitLab CI/CD 可以因为多种原因自动运行流水线，包括 Git 更改和合并请求更新。使用 `rules` 关键词来控制应针对哪些事件运行作业。定时流水线在项目设置中定义。 |
| `tools`       | 不适用 | 在 Jenkins 中，`tools` 定义了要在环境中安装的额外工具。极狐GitLab 没有类似的关键词，推荐使用预先构建好作业所需确切工具的容器镜像。这些镜像可以被缓存，并且可以预先包含流水线所需的工具。如果作业需要额外的工具，可以在 `before_script` 部分中安装。 |
| `input`       | 不适用 | 在 Jenkins 中，`input` 用于添加用户输入提示。与 `parameters` 类似，在极狐GitLab 中通过 CI/CD 变量处理输入。 |
| `when`        | `rules`        | 在 Jenkins 中，`when` 定义了阶段应在何时执行。极狐GitLab 也有一个 `when` 关键词，它根据前面作业的状态（例如作业是通过还是失败）来决定作业是否应该开始运行。要控制何时将作业添加到特定的流水线中，请使用 `rules`。 |

<a id="common-configurations"></a>

### 常见配置

本节介绍常用的 CI/CD 配置，并展示如何将它们从 Jenkins 转换到极狐GitLab CI/CD。

[Jenkins 流水线](https://www.jenkins.io/doc/book/pipeline/) 会在特定事件（例如推送新提交）发生时生成自动化的 CI/CD 作业。Jenkins 流水线在 `Jenkinsfile` 中定义。极狐GitLab 的对应文件是 [`.gitlab-ci.yml` 配置文件](../yaml/_index.md)。

Jenkins 不提供存储源代码的位置，因此 `Jenkinsfile` 必须存储在单独的源代码管理仓库中。

<a id="jobs"></a>

#### 作业

作业是按特定顺序运行以实现特定结果的一组命令。

例如，在 `Jenkinsfile` 中构建一个容器，然后将其部署到生产环境：

```groovy
pipeline {
    agent any
    stages {
        stage('build') {
            agent { docker 'golang:alpine' }
            steps {
                apk update
                go build -o bin/hello
            }
            post {
              always {
                archiveArtifacts artifacts: 'bin/hello'
                onlyIfSuccessful: true
              }
            }
        }
        stage('deploy') {
            agent { docker 'golang:alpine' }
            when {
              branch 'staging'
            }
            steps {
                echo "Deploying to staging"
                scp bin/hello remoteuser@remotehost:/remote/directory
            }
        }
    }
}
```

这个示例：

- 使用 `golang:alpine` 容器镜像。
- 运行一个用于构建代码的作业。
  - 将构建出的可执行文件存储为产物。
- 添加第二个作业来部署到 `staging`，该作业：
  - 仅在提交目标为 `staging` 分支时存在。
  - 在构建阶段成功后启动。
  - 使用前一个作业中的构建产物。

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
default:
  image: golang:alpine

stages:
  - build
  - deploy

build-job:
  stage: build
  script:
    - apk update
    - go build -o bin/hello
  artifacts:
    paths:
      - bin/hello
    expire_in: 1 week

deploy-job:
  stage: deploy
  script:
    - echo "Deploying to Staging"
    - scp bin/hello remoteuser@remotehost:/remote/directory
  rules:
    - if: $CI_COMMIT_BRANCH == 'staging'
  artifacts:
    paths:
      - bin/hello
```

<a id="parallel"></a>

##### 并行执行

在 Jenkins 中，不依赖于前面作业的作业可以通过添加到 `parallel` 部分来并行运行。

例如，在 `Jenkinsfile` 中：

```groovy
pipeline {
    agent any
    stages {
        stage('Parallel') {
            parallel {
                stage('Python') {
                    agent { docker 'python:latest' }
                    steps {
                        sh "python --version"
                    }
                }
                stage('Java') {
                    agent { docker 'openjdk:latest' }
                    when {
                        branch 'staging'
                    }
                    steps {
                        sh "java -version"
                    }
                }
            }
        }
    }
}
```

该示例使用不同的容器镜像并行运行 Python 和 Java 作业。Java 作业仅在更改 `staging` 分支时运行。

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
python-version:
  image: python:latest
  script:
    - python --version

java-version:
  image: openjdk:latest
  rules:
    - if: $CI_COMMIT_BRANCH == 'staging'
  script:
    - java -version
```

在这种情况下，无需额外配置即可使作业并行运行。默认情况下，作业可以并行运行，每个作业在不同的 Runner 上执行，前提是有足够的 Runner 可用于所有作业。Java 作业被设置为仅在更改 `staging` 分支时运行。

<a id="matrix"></a>

##### 矩阵

在极狐GitLab 中，你可以使用矩阵在单个流水线中多次并行运行一个作业，但每个作业实例具有不同的变量值。Jenkins 是顺序执行矩阵的。

例如，在 `Jenkinsfile` 中：

```groovy
matrix {
    axes {
        axis {
            name 'PLATFORM'
            values 'linux', 'mac', 'windows'
        }
        axis {
            name 'ARCH'
            values 'x64', 'x86'
        }
    }
    stages {
        stage('build') {
            echo "Building $PLATFORM for $ARCH"
        }
        stage('test') {
            echo "Building $PLATFORM for $ARCH"
        }
        stage('deploy') {
            echo "Building $PLATFORM for $ARCH"
        }
    }
}
```

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
stages:
  - build
  - test
  - deploy

.parallel-hidden-job:
  parallel:
    matrix:
      - PLATFORM: [linux, mac, windows]
        ARCH: [x64, x86]

build-job:
  extends: .parallel-hidden-job
  stage: build
  script:
    - echo "Building $PLATFORM for $ARCH"

test-job:
  extends: .parallel-hidden-job
  stage: test
  script:
    - echo "Testing $PLATFORM for $ARCH"

deploy-job:
  extends: .parallel-hidden-job
  stage: deploy
  script:
    - echo "Testing $PLATFORM for $ARCH"
```

<a id="container-images"></a>

#### 容器镜像

在极狐GitLab 中，你可以使用 [image](../yaml/_index.md#image) 关键词在[独立的、隔离的 Docker 容器中运行 CI/CD 作业](../docker/using_docker_images.md)。

例如，在 `Jenkinsfile` 中：

```groovy
stage('Version') {
    agent { docker 'python:latest' }
    steps {
        echo 'Hello Python'
        sh 'python --version'
    }
}
```

该示例展示了在 `python:latest` 容器中运行的命令。

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
version-job:
  image: python:latest
  script:
    - echo "Hello Python"
    - python --version
```

<a id="variables"></a>

#### 变量

在极狐GitLab 中，使用 `variables` 关键词来定义 [CI/CD 变量](../variables/_index.md)。使用变量可以重用配置数据、实现更动态的配置或存储重要值。变量可以全局定义，也可以按作业定义。

例如，在 `Jenkinsfile` 中：

```groovy
pipeline {
    agent any
    environment {
        NAME = 'Fern'
    }
    stages {
        stage('English') {
            environment {
                GREETING = 'Hello'
            }
            steps {
                sh 'echo "$GREETING $NAME"'
            }
        }
        stage('Spanish') {
            environment {
                GREETING = 'Hola'
            }
            steps {
                sh 'echo "$GREETING $NAME"'
            }
        }
    }
}
```

该示例展示了如何使用变量将值传递给作业中的命令。

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

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

变量也可以在[极狐GitLab UI 的 CI/CD 设置中进行设置](../variables/_index.md#define-a-cicd-variable-in-the-ui)。在某些情况下，你可以使用[受保护](../variables/_index.md#protect-a-cicd-variable)和[被屏蔽](../variables/_index.md#mask-a-cicd-variable)的变量来处理密钥值。这些变量可以在流水线作业中像在配置文件中定义的变量一样被访问。

例如，在 `Jenkinsfile` 中：

```groovy
pipeline {
    agent any
    stages {
        stage('Example Username/Password') {
            environment {
                AWS_ACCESS_KEY = credentials('aws-access-key')
            }
            steps {
                sh 'my-login-script.sh $AWS_ACCESS_KEY'
            }
        }
    }
}
```

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
login-job:
  script:
    - my-login-script.sh $AWS_ACCESS_KEY
```

此外，极狐GitLab CI/CD 为每个流水线和作业提供了[预定义变量](../variables/predefined_variables.md)，这些变量包含与流水线和仓库相关的值。

<a id="expressions-and-conditionals"></a>

#### 表达式和条件判断

当新流水线启动时，极狐GitLab 会检查哪些作业应该在该流水线中运行。你可以根据变量状态或流水线类型等因素来配置作业的运行条件。

例如，在 `Jenkinsfile` 中：

```groovy
stage('deploy_staging') {
    agent { docker 'alpine:latest' }
    when {
        branch 'staging'
    }
    steps {
        echo "Deploying to staging"
    }
}
```

在该示例中，作业仅在提交到的分支名为 `staging` 时运行。

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
deploy_staging:
  stage: deploy
  script:
    - echo "Deploy to staging server"
  rules:
    - if: '$CI_COMMIT_BRANCH == staging'
```

<a id="runners"></a>

#### Runner

与 Jenkins 代理类似，极狐GitLab Runner 是运行作业的主机。如果你使用的是 JihuLab.com，你可以使用[实例 Runner 队列](../runners/_index.md)来运行作业，而无需自行配置 Runner。

要将 Jenkins 代理转换用于极狐GitLab CI/CD，请卸载该代理，然后[安装并注册 Runner](../runners/_index.md)。Runner 不需要太多开销，因此你或许可以使用与 Jenkins 代理类似的配置。

关于 Runner 的一些关键细节：

- Runner 可以[配置](../runners/runners_scope.md)为跨实例、群组共享，或者专用于单个项目。
- 你可以使用 [`tags` 关键词](../runners/configure_runners.md#control-jobs-that-a-runner-can-run)进行更精细的控制，并将 Runner 与特定作业关联。例如，你可以为需要专用、更强大或特定硬件的作业使用一个标签。
- 极狐GitLab 支持[Runner 自动伸缩](https://docs.gitlab.com/runner/configuration/autoscale/)。使用自动伸缩仅在需要时配置 Runner，并在不需要时缩减。

例如，在 `Jenkinsfile` 中：

```groovy
pipeline {
    agent none
    stages {
        stage('Linux') {
            agent {
                label 'linux'
            }
            steps {
                echo "Hello, $USER"
            }
        }
        stage('Windows') {
            agent {
                label 'windows'
            }
            steps {
                echo "Hello, %USERNAME%"
            }
        }
    }
}
```

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
linux_job:
  stage: build
  tags:
    - linux
  script:
    - echo "Hello, $USER"

windows_job:
  stage: build
  tags:
    - windows
  script:
    - echo "Hello, %USERNAME%"
```

<a id="artifacts"></a>

#### 产物

在极狐GitLab 中，任何作业都可以使用 [`artifacts`](../yaml/_index.md#artifacts) 关键词来定义作业完成时要存储的一组产物。[产物](../jobs/job_artifacts.md)是可以在后续作业中使用的文件，例如用于测试或部署。

例如，在 `Jenkinsfile` 中：

```groovy
stages {
    stage('Generate Cat') {
        steps {
            sh 'touch cat.txt'
            sh 'echo "meow" > cat.txt'
        }
        post {
            always {
                archiveArtifacts artifacts: 'cat.txt'
                onlyIfSuccessful: true
            }
        }
    }
    stage('Use Cat') {
        steps {
            sh 'cat cat.txt'
        }
    }
  }
```

对应的极狐GitLab CI/CD `.gitlab-ci.yml` 文件为：

```yaml
stages:
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
  artifacts:
    paths:
      - cat.txt
```

<a id="caching"></a>

#### 缓存

当作业下载一个或多个文件并将其保存以供将来更快访问时，就会创建[缓存](../caching/_index.md)。后续使用相同缓存的作业无需再次下载这些文件，因此执行速度更快。缓存存储在 Runner 上，如果启用了[分布式缓存](https://docs.gitlab.com/runner/configuration/autoscale/#distributed-runners-caching)，还会上传到 S3。Jenkins 核心不提供缓存功能。

例如，在 `.gitlab-ci.yml` 文件中：

```yaml
cache-job:
  script:
    - echo "This job uses a cache."
  cache:
    key: binaries-cache-$CI_COMMIT_REF_SLUG
    paths:
      - binaries/
```

<a id="jenkins-plugins"></a>

### Jenkins 插件

Jenkins 中通过插件启用的一些功能在极狐GitLab 中通过提供类似功能的关键词和特性原生支持。例如：

| Jenkins 插件                                                                    | 极狐GitLab 功能 |
|-----------------------------------------------------------------------------------|----------------|
| [Build Timeout](https://plugins.jenkins.io/build-timeout/)                        | [`timeout` 关键词](../yaml/_index.md#timeout) |
| [Cobertura](https://plugins.jenkins.io/cobertura/)                                | [覆盖率报告产物](../yaml/artifacts_reports.md#artifactsreportscoverage_report) 和 [代码覆盖率](../testing/code_coverage/_index.md) |
| [Code coverage API](https://plugins.jenkins.io/code-coverage-api/)                | [代码覆盖率](../testing/code_coverage/_index.md) 和 [覆盖率可视化](../testing/code_coverage/_index.md#coverage-visualization) |
| [Embeddable Build Status](https://plugins.jenkins.io/embeddable-build-status/)    | [流水线状态徽章](../../user/project/badges.md#pipeline-status-badges) |
| [JUnit](https://plugins.jenkins.io/junit/)                                        | [JUnit 测试报告产物](../yaml/artifacts_reports.md#artifactsreportsjunit) 和 [单元测试报告](../testing/unit_test_reports.md) |
| [Mailer](https://plugins.jenkins.io/mailer/)                                      | [通知邮件](../../user/profile/notifications.md) |
| [Parameterized Trigger Plugin](https://plugins.jenkins.io/parameterized-trigger/) | [`trigger` 关键词](../yaml/_index.md#trigger) 和 [下游流水线](../pipelines/downstream_pipelines.md) |
| [Role-based Authorization Strategy](https://plugins.jenkins.io/role-strategy/)    | 极狐GitLab [权限和角色](../../user/permissions.md) |
| [Timestamper](https://plugins.jenkins.io/timestamper/)                            | [作业](../jobs/_index.md) 日志默认带有时间戳 |

<a id="security-scanning-features"></a>

### 安全扫描功能

你可能在 Jenkins 中使用过插件来实现代码质量、安全或静态应用扫描等功能。极狐GitLab 提供开箱即用的[安全扫描器](../../user/application_security/_index.md)，可在 SDLC 的各个部分检测漏洞。你可以使用模板将这些插件添加到极狐GitLab 中。例如，要将 SAST 扫描添加到你的流水线中，请将以下内容添加到你的 `.gitlab-ci.yml`：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml
```

你可以通过 CI/CD 变量自定义安全扫描器的行为，例如使用 [SAST 扫描器](../../user/application_security/sast/_index.md#available-cicd-variables)。

<a id="secrets-management"></a>

### 密钥管理

特权信息，通常称为“密钥”，是你在 CI/CD 工作流中需要的敏感信息或凭证。你可能使用密钥来解锁工具、应用程序、容器和云原生环境中的受保护资源或敏感信息。

Jenkins 中的密钥管理通常通过 `Secret` 类型字段或 Credentials 插件处理。存储在 Jenkins 设置中的凭证可以通过 Credentials Binding 插件作为环境变量暴露给作业。

对于极狐GitLab 的密钥管理，你可以使用一个[支持的外部服务集成](../secrets/_index.md)。这些服务将密钥安全地存储在极狐GitLab 项目之外，但你必须有该服务的订阅。

极狐GitLab 也支持 [OIDC 认证](../secrets/id_token_authentication.md)，适用于支持 OIDC 的其他第三方服务。

此外，你可以通过将凭证存储在 CI/CD 变量中来使其对作业可用，但以明文形式存储的密钥容易意外泄露，[与在 Jenkins 中一样](https://www.jenkins.io/doc/developer/security/secrets/#storing-secrets)。你应始终将敏感信息存储在[被屏蔽](../variables/_index.md#mask-a-cicd-variable)和[受保护](../variables/_index.md#protect-a-cicd-variable)的变量中，这可以减轻一些风险。

同时，切勿将密钥作为变量存储在 `.gitlab-ci.yml` 文件中，因为该文件对所有可以访问项目的用户公开。存储敏感信息在变量中应仅在[项目、群组或实例设置](../variables/_index.md#define-a-cicd-variable-in-the-ui)中进行。

请查看[安全指南](../variables/_index.md#cicd-variable-security)，以提高 CI/CD 变量的安全性。

<a id="planning-and-performing-a-migration"></a>

## 规划并执行迁移

以下推荐步骤清单是根据观察到能够快速完成此迁移的组织而创建的。

<a id="create-a-migration-plan"></a>

### 创建迁移计划

在开始迁移之前，你应该创建一个[迁移计划](plan_a_migration.md)，为迁移做好准备。对于从 Jenkins 迁移，请思考以下问题：

- Jenkins 中的作业目前使用了哪些插件？
  - 你是否确切了解这些插件的功能？
  - 是否有任何插件封装了一个常用的构建工具？例如 Maven、Gradle 或 NPM？
- Jenkins 代理上安装了哪些软件？
- 是否有正在使用的共享库？
- 你是如何从 Jenkins 进行身份验证的？你是在使用 SSH 密钥、API 令牌还是其他密钥？
- 是否需要从你的流水线访问其他项目？
- Jenkins 中是否有用于访问外部服务的凭证？例如 Ansible Tower、Artifactory 或其他云提供商或部署目标？

<a id="prerequisites"></a>

### 前提准备

在进行任何迁移工作之前，你应该首先：

1. 熟悉极狐GitLab。
   - 阅读[极狐GitLab CI/CD 的关键功能](../_index.md)。
   - 按照教程创建[你的第一个极狐GitLab 流水线](../quick_start/_index.md)以及[更复杂的流水线](../quick_start/tutorial.md)，这些流水线可以构建、测试和部署一个静态站点。
   - 回顾 [CI/CD YAML 语法参考](../yaml/_index.md)。
1. 设置并配置极狐GitLab。
1. 测试你的极狐GitLab 实例。
   - 确保[Runner](../runners/_index.md)可用，可以通过使用共享的极狐GitLab.com Runner 或安装新的 Runner 来实现。

<a id="migration-steps"></a>

### 迁移步骤
1.  将项目从您的 SCM 解决方案迁移到极狐GitLab。
    -   （推荐）您可以使用可用的[导入器](../../user/import/_index.md)，自动从外部 SCM 提供商进行批量导入。
    -   您可以[通过 URL 导入代码仓库](../../user/import/third_party_systems/repo_by_url.md)。
1.  在每个项目中创建一个 `.gitlab-ci.yml` 文件。
1.  将 Jenkins 配置迁移到极狐GitLab CI/CD 作业中，并对其进行配置以直接在合并请求中显示结果。
1.  使用[云部署模板](../cloud_deployment/_index.md)、[环境](../environments/_index.md)和[极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md)迁移部署作业。
1.  检查是否有任何 CI/CD 配置可在不同项目中重用，然后创建并共享 CI/CD 模板。
1.  查看[流水线效率文档](../pipelines/pipeline_efficiency.md)，了解如何使您的极狐GitLab CI/CD 流水线更快、更高效。

### 额外资源

-   您可以使用 [JenkinsFile Wrapper](https://jihulab.com/gitlab-cn/jfr-container-builder/) 在极狐GitLab CI/CD 作业中运行完整的 Jenkins 实例，包括插件。通过此工具，您可以推迟迁移不太紧急的流水线，从而帮助简化向极狐GitLab CI/CD 的过渡。

    > [!NOTE]
    > JenkinsFile Wrapper 未与极狐GitLab 打包在一起，不在支持范围内。
    > 更多信息，请参阅[支持声明](https://gitlab.cn/support/statement-of-support/)。

如果您的问题在这里没有得到解答，[极狐GitLab 社区论坛](https://forum.gitlab.com/)可能会是一个很好的资源。