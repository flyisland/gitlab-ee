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

如果您要从 Jenkins 迁移到极狐GitLab CI/CD，可以创建 CI/CD
流水线，以复现并增强您的 Jenkins 工作流。

<a id="key-similarities-and-differences"></a>

## 主要异同

极狐GitLab CI/CD 和 Jenkins 都是 CI/CD 工具，二者有一些相似之处。极狐GitLab
和 Jenkins 都：

- 使用阶段来组织作业集合。
- 支持基于容器的构建。

此外，两者之间也有一些重要差异：

- 极狐GitLab CI/CD 流水线全部通过 YAML 格式的配置文件进行配置。
  Jenkins 使用 Groovy 格式的配置文件（声明式流水线）
  或 Jenkins DSL（脚本式流水线）。
- 极狐GitLab 提供 [JihuLab.com](../../subscriptions/manage_seats.md#gitlabcom-billing-and-usage)，这是一个多租户 SaaS 服务。
  您也可以运行自己的[极狐GitLab 私有化部署](../../subscriptions/manage_subscription.md)
  实例。Jenkins 部署必须自托管。
- 极狐GitLab 开箱即用地提供源代码管理（SCM）。Jenkins 需要单独的
  SCM 解决方案来存储代码。
- 极狐GitLab 提供内置的容器镜像仓库。Jenkins 需要单独的解决方案
  来存储容器镜像。
- 极狐GitLab 提供用于扫描代码的内置模板。Jenkins 需要第三方插件
  来扫描代码。

<a id="comparison-of-features-and-concepts"></a>

## 功能与概念对比

Jenkins 的许多功能和概念在极狐GitLab 中都有对应项，可提供相同的功能。

<a id="configuration-file"></a>

### 配置文件

Jenkins 可以使用 [Groovy 格式的 `Jenkinsfile`](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) 进行配置。极狐GitLab CI/CD 默认使用 `.gitlab-ci.yml` 文件。

`Jenkinsfile` 示例：

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

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

Jenkins 配置由包含各个部分和指令的 `pipeline` 块组成。极狐GitLab CI/CD 具有类似的功能，通过 YAML 关键字进行配置。

<a id="sections"></a>

#### 部分

| Jenkins  | 极狐GitLab         | 说明 |
|----------|----------------|-------------|
| `agent`  | `image`        | Jenkins 流水线在代理上执行，`agent` 部分定义流水线如何执行，以及要使用的 Docker 容器。极狐GitLab 作业在 Runner 上执行，`image` 关键字定义要使用的容器。您可以在 Kubernetes 或任意主机上配置自己的 Runner。 |
| `post`   | `after_script` 或 `stage` | Jenkins `post` 部分定义应在阶段或流水线结束时执行的操作。在极狐GitLab 中，使用 `after_script` 定义在作业结束时运行的命令，使用 `before_script` 定义在作业中其他命令之前运行的操作。使用 `stage` 选择作业应在哪个确切阶段运行。极狐GitLab 支持 `.pre` 和 `.post` 阶段，它们始终在所有其他已定义阶段之前或之后运行。 |
| `stages` | `stages`       | Jenkins 阶段是作业的分组。极狐GitLab CI/CD 也使用阶段，但更加灵活。您可以有多个阶段，每个阶段包含多个相互独立的作业。在顶层使用 `stages` 定义阶段及其执行顺序，在作业级别使用 `stage` 定义该作业所属的阶段。 |
| `steps`  | `script`       | Jenkins `steps` 定义要执行的内容。极狐GitLab CI/CD 使用类似的 `script` 部分。`script` 部分是一个 YAML 数组，其中每个条目对应一个要按顺序运行的命令。 |

<a id="directives"></a>

#### 指令

| Jenkins       | 极狐GitLab         | 说明 |
|---------------|----------------|-------------|
| `environment` | `variables`    | Jenkins 使用 `environment` 定义环境变量。极狐GitLab CI/CD 使用 `variables` 关键字定义可在作业执行期间使用的 CI/CD 变量，也可用于更动态的流水线配置。这些变量也可以在极狐GitLab UI 的 CI/CD 设置中设置。 |
| `options`     | 不适用 | Jenkins 使用 `options` 进行额外配置，包括超时和重试值。极狐GitLab 不需要单独的选项部分，所有配置都作为 CI/CD 关键字添加到作业或流水线级别，例如 `timeout` 或 `retry`。 |
| `parameters`  | 不适用 | 在 Jenkins 中，触发流水线时可能需要参数。在极狐GitLab 中，参数通过 CI/CD 变量处理，这些变量可以在许多位置定义，包括流水线配置、项目设置、运行时通过 UI 或 API 手动定义。 |
| `triggers`    | `rules`        | 在 Jenkins 中，`triggers` 定义流水线何时应再次运行，例如通过 cron 表示法。极狐GitLab CI/CD 可以出于许多原因自动运行流水线，包括 Git 变更和合并请求更新。使用 `rules` 关键字控制为哪些事件运行作业。定时流水线在项目设置中定义。 |
| `tools`       | 不适用 | 在 Jenkins 中，`tools` 定义要在环境中安装的额外工具。极狐GitLab 没有类似的关键字，因为建议使用预构建的容器镜像，其中包含作业所需的确切工具。这些镜像可以被缓存，并且可以构建为已包含流水线所需的工具。如果作业需要额外工具，可以在 `before_script` 部分中安装。 |
| `input`       | 不适用 | 在 Jenkins 中，`input` 添加用户输入提示。与 `parameters` 类似，输入在极狐GitLab 中通过 CI/CD 变量处理。 |
| `when`        | `rules`        | 在 Jenkins 中，`when` 定义阶段何时应执行。极狐GitLab 也有 `when` 关键字，它根据较早作业的状态（例如作业是通过还是失败）定义作业是否应开始运行。要控制何时将作业添加到特定流水线，请使用 `rules`。 |

<a id="common-configurations"></a>

### 常见配置

本节介绍常用的 CI/CD 配置，展示如何将它们
从 Jenkins 转换为极狐GitLab CI/CD。

[Jenkins 流水线](https://www.jenkins.io/doc/book/pipeline/)生成自动化 CI/CD 作业，
这些作业在特定事件发生时触发，例如推送新提交。Jenkins 流水线在 `Jenkinsfile`中定义。极狐GitLab 中的等效项是 [`.gitlab-ci.yml` 配置文件](../yaml/_index.md)。

Jenkins 不提供存储源代码的位置，因此 `Jenkinsfile` 必须存储在单独的源代码管理代码仓库中。

<a id="jobs"></a>

#### 作业

作业是一组按设定顺序运行的命令，用于实现特定结果。

例如，在 `Jenkinsfile`中构建容器然后将其部署到生产环境：

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

此示例：

- 使用 `golang:alpine` 容器镜像。
- 运行一个用于构建代码的作业。
  - 将构建的可执行文件存储为产物。
- 添加第二个作业以部署到 `staging`，该作业：
  - 仅在提交目标为 `staging` 分支时存在。
  - 在构建阶段成功后开始。
  - 使用较早作业中构建的可执行文件产物。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

##### 并行

在 Jenkins 中，不依赖于先前作业的作业在添加到 `parallel` 部分时可以并行运行。

例如，在 `Jenkinsfile`中：

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

此示例使用不同的容器镜像并行运行 Python 和 Java 作业。Java 作业仅在 `staging` 分支发生变更时运行。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

在这种情况下，无需额外配置即可让作业并行运行。作业默认并行运行，每个作业在不同的 Runner 上运行，前提是有足够的 Runner 供所有作业使用。Java 作业设置为仅在 `staging` 分支发生变更时运行。

<a id="matrix"></a>

##### 矩阵

在极狐GitLab 中，您可以使用矩阵在单个流水线中并行多次运行一个作业，但每次作业实例使用不同的变量值。Jenkins 按顺序运行矩阵。

例如，在 `Jenkinsfile`中：

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

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

在极狐GitLab 中，您可以使用 [image](../yaml/_index.md#image) 关键字[在单独的隔离 Docker 容器中运行 CI/CD 作业](../docker/using_docker_images.md)。

例如，在 `Jenkinsfile`中：

```groovy
stage('Version') {
    agent { docker 'python:latest' }
    steps {
        echo 'Hello Python'
        sh 'python --version'
    }
}
```

此示例展示在 `python:latest` 容器中运行的命令。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

```yaml
version-job:
  image: python:latest
  script:
    - echo "Hello Python"
    - python --version
```

<a id="variables"></a>

#### 变量

在极狐GitLab 中，使用 `variables` 关键字定义 [CI/CD 变量](../variables/_index.md)。使用变量可以复用配置数据、实现更动态的配置，或存储重要值。变量可以全局定义，也可以按作业定义。

例如，在 `Jenkinsfile`中：

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

此示例展示如何使用变量将值传递给作业中的命令。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

变量也可以[在极狐GitLab UI 的 CI/CD 设置中设置](../variables/_index.md#define-a-cicd-variable-in-the-ui)。在某些情况下，您可以使用[受保护](../variables/_index.md#protect-a-cicd-variable)和[掩码](../variables/_index.md#mask-a-cicd-variable)变量来存储密钥值。这些变量可以在流水线作业中访问，与配置文件中定义的变量相同。

例如，在 `Jenkinsfile`中：

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

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

```yaml
login-job:
  script:
    - my-login-script.sh $AWS_ACCESS_KEY
```

此外，极狐GitLab CI/CD 使[预定义变量](../variables/predefined_variables.md)可用于每个流水线和作业，其中包含与流水线和代码仓库相关的值。

<a id="expressions-and-conditionals"></a>

#### 表达式和条件

当新的流水线启动时，极狐GitLab 会检查该流水线中应运行哪些作业。您可以根据变量状态或流水线类型等因素配置作业的运行方式。

例如，在 `Jenkinsfile`中：

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

在此示例中，作业仅在您提交到的分支名为 `staging` 时运行。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

与 Jenkins 代理类似，极狐GitLab Runner 是运行作业的主机。如果您使用 JihuLab.com，
可以使用[实例 Runner 队列](../runners/_index.md)运行作业，而无需预配
自己的 Runner。

要将 Jenkins 代理转换为与极狐GitLab CI/CD 配合使用，请卸载该代理，然后[安装并注册 Runner](../runners/_index.md)。Runner 不需要太多开销，因此您很可能可以使用与之前使用的 Jenkins 代理类似的预配方式。

关于 Runner 的一些关键细节：

- Runner 可以[配置](../runners/runners_scope.md)为在实例、
  群组之间共享，或专用于单个项目。
- 您可以使用 [`tags` 关键字](../runners/configure_runners.md#control-jobs-that-a-runner-can-run)
  进行更精细的控制，并将 Runner 与特定作业关联。例如，您可以为需要
  专用、更强大或特定硬件的作业使用标签。
- 极狐GitLab 提供 [Runner 自动扩缩](https://gitlab.cn/docs/runner/configuration/autoscale/)。
  使用自动扩缩可以仅在需要时预配 Runner，并在不需要时缩减。

例如，在 `Jenkinsfile`中：

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

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

在极狐GitLab 中，任何作业都可以使用 [`artifacts`](../yaml/_index.md#artifacts) 关键字定义一组在作业完成时存储的产物。[产物](../jobs/job_artifacts.md)是可在后续作业中使用的文件，例如用于测试或部署。

例如，在 `Jenkinsfile`中：

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

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件如下：

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

当作业下载一个或多个文件并保存它们以便将来更快访问时，就会创建[缓存](../caching/_index.md)。使用相同缓存的后续作业不必再次下载这些文件，因此执行速度更快。缓存存储在 Runner 上，如果[启用了分布式缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)，则会上传到 S3。Jenkins 核心不提供缓存。

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

Jenkins 中通过插件启用的一些功能，在极狐GitLab 中通过提供类似功能的关键字和特性原生支持。例如：

| Jenkins 插件                                                                    | 极狐GitLab 功能 |
|-----------------------------------------------------------------------------------|----------------|
| [Build Timeout](https://plugins.jenkins.io/build-timeout/)                        | [`timeout` 关键字](../yaml/_index.md#timeout) |
| [Cobertura](https://plugins.jenkins.io/cobertura/)                                | [覆盖率报告产物](../yaml/artifacts_reports.md#artifactsreportscoverage_report)和[代码覆盖率](../testing/code_coverage/_index.md) |
| [Code coverage API](https://plugins.jenkins.io/code-coverage-api/)                | [代码覆盖率](../testing/code_coverage/_index.md)和[覆盖率可视化](../testing/code_coverage/_index.md#coverage-visualization) |
| [Embeddable Build Status](https://plugins.jenkins.io/embeddable-build-status/)    | [流水线状态徽章](../../user/project/badges.md#pipeline-status-badges) |
| [JUnit](https://plugins.jenkins.io/junit/)                                        | [JUnit 测试报告产物](../yaml/artifacts_reports.md#artifactsreportsjunit)和[单元测试报告](../testing/unit_test_reports.md) |
| [Mailer](https://plugins.jenkins.io/mailer/)                                      | [通知邮件](../../user/profile/notifications.md) |
| [Parameterized Trigger Plugin](https://plugins.jenkins.io/parameterized-trigger/) | [`trigger` 关键字](../yaml/_index.md#trigger)和[下游流水线](../pipelines/downstream_pipelines.md) |
| [Role-based Authorization Strategy](https://plugins.jenkins.io/role-strategy/)    | 极狐GitLab [权限和角色](../../user/permissions.md) |
| [Timestamper](https://plugins.jenkins.io/timestamper/)                            | [作业](../jobs/_index.md)日志默认带有时间戳 |

<a id="security-scanning-features"></a>

### 安全扫描功能

您可能在 Jenkins 中使用过用于代码质量、安全性或静态应用程序扫描等功能的插件。极狐GitLab 开箱即用地提供[安全扫描器](../../user/application_security/_index.md)，用于检测 SDLC 各个部分中的漏洞。您可以在极狐GitLab 中使用模板添加这些插件，例如要为流水线添加 SAST 扫描，请将以下内容添加到 `.gitlab-ci.yml`：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml
```

您可以使用 CI/CD 变量自定义安全扫描器的行为，例如使用 [SAST 扫描器](../../user/application_security/sast/_index.md#available-cicd-variables)。

<a id="secrets-management"></a>

### 密钥管理

特权信息通常称为“密钥”，是您在 CI/CD 工作流中需要的敏感信息或凭据。您可能使用密钥来解锁工具、应用程序、容器和云原生环境中的受保护资源或敏感信息。

Jenkins 中的密钥管理通常通过 `Secret` 类型字段或凭据插件处理。存储在 Jenkins 设置中的凭据可以通过凭据绑定插件作为环境变量暴露给作业。

对于极狐GitLab 中的密钥管理，您可以使用[支持的集成](../secrets/_index.md)来连接外部服务。这些服务将密钥安全地存储在您的极狐GitLab 项目之外，不过您必须拥有该服务的订阅。

极狐GitLab 还支持 [OIDC 认证](../secrets/id_token_authentication.md)，
用于其他支持 OIDC 的第三方服务。

此外，您可以通过将凭据存储在 CI/CD 变量中使其可供作业使用，不过以纯文本形式存储的密钥容易意外泄露，[与 Jenkins 中相同](https://www.jenkins.io/doc/developer/security/secrets/#storing-secrets)。您应始终将敏感信息存储在[掩码](../variables/_index.md#mask-a-cicd-variable)和[受保护](../variables/_index.md#protect-a-cicd-variable)变量中，这可以缓解部分风险。

另外，切勿将密钥作为变量存储在 `.gitlab-ci.yml` 文件中，该文件对所有有权访问该项目的用户都是公开的。将敏感信息存储在变量中只应在[项目、群组或实例设置](../variables/_index.md#define-a-cicd-variable-in-the-ui)中进行。

请查看[安全指南](../variables/_index.md#cicd-variable-security)，以提高 CI/CD 变量的安全性。

<a id="planning-and-performing-a-migration"></a>

## 规划和执行迁移

以下步骤可帮助您规划和执行此迁移。

<a id="create-a-migration-plan"></a>

### 创建迁移计划

在开始迁移之前，您应创建[迁移计划](plan_a_migration.md)，为迁移做好准备。对于从 Jenkins 迁移，请在准备过程中问自己以下问题：

- 目前 Jenkins 中的作业使用了哪些插件？
  - 您知道这些插件具体做什么吗？
  - 是否有插件封装了常见的构建工具？例如 Maven、Gradle 或 NPM？
- Jenkins 代理上安装了哪些内容？
- 是否有正在使用的共享库？
- 您如何从 Jenkins 进行认证？您使用的是 SSH 密钥、API 令牌还是其他密钥？
- 是否有其他项目需要从您的流水线访问？
- Jenkins 中是否有用于访问外部服务的凭据？例如 Ansible Tower、
  Artifactory 或其他云提供商或部署目标？

<a id="prerequisites"></a>

### 先决条件

在进行任何迁移工作之前，您应首先：

1. 熟悉极狐GitLab。
   - 阅读[极狐GitLab CI/CD 关键功能](../_index.md)。
   - 按照教程创建[您的第一个极狐GitLab 流水线](../quick_start/_index.md)和[更复杂的流水线](../quick_start/tutorial.md)，用于构建、测试和部署静态站点。
   - 查看 [CI/CD YAML 语法参考](../yaml/_index.md)。
1. 设置并配置极狐GitLab。
1. 测试您的极狐GitLab 实例。
   - 确保 [Runner](../runners/_index.md) 可用，可以使用 JihuLab.com 共享 Runner 或安装新的 Runner。

<a id="migration-steps"></a>

### 迁移步骤

1. 将项目从您的 SCM 解决方案迁移到极狐GitLab。
   - （推荐）您可以使用可用的[导入器](../../user/import/_index.md)
     自动从外部 SCM 提供商批量导入。
   - 您可以[通过 URL 导入代码仓库](../../user/import/third_party_systems/repo_by_url.md)。
1. 在每个项目中创建 `.gitlab-ci.yml` 文件。
1. 将 Jenkins 配置迁移到极狐GitLab CI/CD 作业，并配置它们以直接在合并请求中显示结果。
1. 使用[云部署模板](../cloud_deployment/_index.md)、
   [环境](../environments/_index.md)和[极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md) 迁移部署作业。
1. 检查是否有任何 CI/CD 配置可以在不同项目之间复用，然后创建
   并共享 CI/CD 模板。
1. 查看[流水线效率文档](../pipelines/pipeline_efficiency.md)，
   了解如何让您的极狐GitLab CI/CD 流水线更快、更高效。

<a id="additional-resources"></a>

### 其他资源

- 您可以使用 [JenkinsFile Wrapper](https://gitlab.com/gitlab-org/jfr-container-builder/)
  在极狐GitLab CI/CD 作业中运行完整的 Jenkins 实例，包括插件。使用此工具可以通过延迟迁移不太紧急的流水线，帮助您更轻松地过渡到极狐GitLab CI/CD。

  > [!note]
  > JenkinsFile Wrapper 不随极狐GitLab 打包，不在支持范围内。
  > 有关更多信息，请参阅[支持声明](https://gitlab.cn/support)。
