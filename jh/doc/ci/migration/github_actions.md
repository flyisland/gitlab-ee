---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 GitHub Actions 迁移
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您要从 GitHub Actions 迁移到极狐GitLab CI/CD，您可以创建能够复制并增强您的 GitHub Action 工作流的 CI/CD
流水线。

您可以手动完成此操作，也可以使用您选择的 Agent 配合
[GitHub Actions 到 GitLab CI/CD Agent skill](https://about.gitlab.com/github-actions-to-gitlab-ci/)

<a id="key-similarities-and-differences"></a>

## 主要相似点和差异

GitHub Actions 和极狐GitLab CI/CD 都用于生成流水线，以自动化构建、测试和部署您的代码。两者具有以下相似之处：

- CI/CD 功能可以直接访问存储在项目代码仓库中的代码。
- 流水线配置使用 YAML 编写，并存储在项目代码仓库中。
- 流水线可配置，并且可以在不同阶段运行。
- 作业可以各自使用不同的容器镜像。

此外，两者之间还存在一些重要差异：

- GitHub 有一个用于下载第三方 Action 的市场，这可能需要额外的支持或许可证。
- 极狐GitLab 私有化部署同时支持水平和垂直扩展，而 GitHub Enterprise Server 仅支持垂直扩展。
- 极狐GitLab 在内部维护并支持所有功能，部分第三方集成可通过模板访问。
- 极狐GitLab 提供内置的容器镜像仓库。
- 极狐GitLab 原生支持 Kubernetes 部署。
- 极狐GitLab 提供细粒度的安全策略。

<a id="comparison-of-features-and-concepts"></a>

## 功能与概念对比

GitHub 的许多功能和概念在极狐GitLab 中都有提供相同功能的对应项。

<a id="configuration-file"></a>

### 配置文件

GitHub Actions 可以使用 [workflow YAML 文件](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#understanding-the-workflow-file) 进行配置。
极狐GitLab CI/CD 默认使用 `.gitlab-ci.yml` YAML 文件。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
on: [push]
jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello World"
```

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

```yaml
stages:
  - hello

hello:
  stage: hello
  script:
    - echo "Hello World"
```

<a id="github-actions-workflow-syntax"></a>

### GitHub Actions 工作流语法

GitHub Actions 配置在 `workflow` YAML 文件中使用特定关键字定义。
极狐GitLab CI/CD 具有类似的功能，通常也使用 YAML 关键字进行配置。

| GitHub    | 极狐GitLab         | 说明 |
|-----------|----------------|-------------|
| `env`     | `variables`    | `env` 定义在工作流、作业或步骤中设置的变量。极狐GitLab 使用 `variables` 在全局或作业级别定义 [CI/CD 变量](../variables/_index.md)。也可以在 UI 中添加变量。 |
| `jobs`    | `stages`       | `jobs` 将工作流中运行的所有作业分组在一起。极狐GitLab 使用 `stages` 将作业分组在一起。 |
| `on`      | 不适用 | `on` 定义工作流的触发时机。极狐GitLab 与 Git 紧密集成，因此不需要为触发器配置 SCM 轮询选项，但如有需要，可以为每个作业进行配置。 |
| `run`     | 不适用 | 在作业中执行的命令。极狐GitLab 在 `script` 关键字下使用 YAML 数组，每个要执行的命令对应一个条目。 |
| `runs-on` | `tags`         | `runs-on` 定义作业必须在其上运行的 GitHub runner。极狐GitLab 使用 `tags` 来选择 runner。 |
| `steps`   | `script`       | `steps` 将作业中运行的所有步骤分组在一起。极狐GitLab 使用 `script` 将作业中运行的所有命令分组在一起。 |
| `uses`    | `include`      | `uses` 定义要添加到 `step` 中的 GitHub Action。极狐GitLab 使用 `include` 将其他文件中的配置添加到作业中。 |

<a id="common-configurations"></a>

### 常见配置

本节介绍常用的 CI/CD 配置，展示如何将它们从 GitHub Actions 转换为极狐GitLab CI/CD。

[GitHub Action 工作流](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#workflows)
会在某些事件发生时（例如推送新提交）生成自动化的 CI/CD 作业。GitHub Action 工作流是一个 YAML 文件，定义在代码仓库根目录下的 `.github/workflows` 目录中。极狐GitLab 的对应物是 `.gitlab-ci.yml` 配置文件，它也位于代码仓库的根目录中。

<a id="jobs"></a>

#### 作业

作业是按特定顺序运行的一组命令，以实现特定结果，例如构建容器或部署到生产环境。

例如，这个 GitHub Actions `workflow` 会构建一个容器，然后将其部署到生产环境。作业按顺序运行，因为 `deploy` 作业依赖于 `build` 作业：

```yaml
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    container: golang:alpine
    steps:
      - run: apk update
      - run: go build -o bin/hello
      - uses: actions/upload-artifact@v3
        with:
          name: hello
          path: bin/hello
          retention-days: 7
  deploy:
    if: contains( github.ref, 'staging')
    runs-on: ubuntu-latest
    container: golang:alpine
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: hello
      - run: echo "Deploying to Staging"
      - run: scp bin/hello remoteuser@remotehost:/remote/directory
```

此示例：

- 使用 `golang:alpine` 容器镜像。
- 运行一个用于构建代码的作业。
  - 将构建可执行文件存储为产物。
- 运行第二个作业以部署到 `staging`，该作业还：
  - 要求构建作业成功后才能运行。
  - 要求提交目标分支为 `staging`。
  - 使用构建可执行文件产物。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

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
```

<a id="parallel"></a>

##### 并行

在 GitHub 和极狐GitLab 中，作业默认并行运行。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
on: [push]
jobs:
  python-version:
    runs-on: ubuntu-latest
    container: python:latest
    steps:
      - run: python --version
  java-version:
    if: contains( github.ref, 'staging')
    runs-on: ubuntu-latest
    container: openjdk:latest
    steps:
      - run: java -version
```

此示例使用不同的容器镜像并行运行一个 Python 作业和一个 Java 作业。Java 作业仅在 `staging` 分支发生更改时运行。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

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

在这种情况下，无需额外配置即可使作业并行运行。作业默认并行运行，每个作业在不同的 runner 上运行（假设有足够的 runner 来处理所有作业）。Java 作业设置为仅在 `staging` 分支发生更改时运行。

<a id="matrix"></a>

##### 矩阵

在极狐GitLab 和 GitHub 中，您都可以使用矩阵在单个流水线中并行多次运行一个作业，但每次作业实例使用不同的变量值。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building $PLATFORM for $ARCH"
    strategy:
      matrix:
        platform: [linux, mac, windows]
        arch: [x64, x86]
  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Testing $PLATFORM for $ARCH"
    strategy:
      matrix:
        platform: [linux, mac, windows]
        arch: [x64, x86]
  deploy:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying $PLATFORM for $ARCH"
    strategy:
      matrix:
        platform: [linux, mac, windows]
        arch: [x64, x86]
```

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

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
    - echo "Deploying $PLATFORM for $ARCH"
```

<a id="trigger"></a>

#### 触发器

GitHub Actions 要求您为工作流添加触发器。极狐GitLab 与 Git 紧密集成，因此不需要为触发器配置 SCM 轮询选项，但如有需要，可以为每个作业进行配置。

示例 GitHub Actions 配置：

```yaml
on:
  push:
    branches:
      - main
```

等效的极狐GitLab CI/CD 配置将是：

```yaml
rules:
  - if: '$CI_COMMIT_BRANCH == main'
```

流水线也可以[使用 Cron 语法进行调度](../pipelines/schedules.md)。

<a id="container-images"></a>

#### 容器镜像

使用极狐GitLab，您可以通过使用 [`image`](../yaml/_index.md#image) 关键字，[在独立的、隔离的 Docker 容器中运行您的 CI/CD 作业](../docker/using_docker_images.md)。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
jobs:
  update:
    runs-on: ubuntu-latest
    container: alpine:latest
    steps:
      - run: apk update
```

在此示例中，`apk update` 命令在 `alpine:latest` 容器中运行。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

```yaml
update-job:
  image: alpine:latest
  script:
    - apk update
```

极狐GitLab 为每个项目提供一个[容器镜像仓库](../../user/packages/container_registry/_index.md)，用于托管容器镜像。可以直接从极狐GitLab CI/CD 流水线构建和存储容器镜像。

例如：

```yaml
stages:
  - build

build-image:
  stage: build
  variables:
    IMAGE: $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:$CI_COMMIT_SHA
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $IMAGE .
    - docker push $IMAGE
```

<a id="variables"></a>

#### 变量

您可以使用 `variables` 关键字在运行时定义不同的 [CI/CD 变量](../variables/_index.md)。当您需要在流水线中重用配置数据时，请使用变量。您可以在全局或每个作业级别定义变量。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
env:
  NAME: "fern"

jobs:
  english:
    runs-on: ubuntu-latest
    env:
      Greeting: "hello"
    steps:
      - run: echo "$GREETING $NAME"
  spanish:
    runs-on: ubuntu-latest
    env:
      Greeting: "hola"
    steps:
      - run: echo "$GREETING $NAME"
```

在此示例中，变量为作业提供了不同的输出。

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

```yaml
default:
  image: ubuntu-latest

variables:
  NAME: "fern"

english:
  variables:
    GREETING: "hello"
  script:
    - echo "$GREETING $NAME"

spanish:
  variables:
    GREETING: "hola"
  script:
    - echo "$GREETING $NAME"
```

变量也可以通过极狐GitLab UI 在 CI/CD 设置下进行设置，您可以在其中[保护](../variables/_index.md#protect-a-cicd-variable)或[掩码](../variables/_index.md#mask-a-cicd-variable)变量。掩码变量在作业日志中隐藏，而受保护变量只能在受保护分支或标签的流水线中访问。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
jobs:
  login:
    runs-on: ubuntu-latest
    env:
      AWS_ACCESS_KEY: ${{ secrets.AWS_ACCESS_KEY }}
    steps:
      - run: my-login-script.sh "$AWS_ACCESS_KEY"
```

如果在极狐GitLab 项目设置中定义了 `AWS_ACCESS_KEY` 变量，则等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

```yaml
login:
  script:
    - my-login-script.sh $AWS_ACCESS_KEY
```

此外，[GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/contexts) 和 [极狐GitLab CI/CD](../variables/predefined_variables.md) 都提供包含与流水线和代码仓库相关数据的内置变量。

<a id="conditionals"></a>

#### 条件

当新的流水线启动时，极狐GitLab 会检查流水线配置，以确定该流水线中应运行哪些作业。您可以使用 [`rules` 关键字](../yaml/_index.md#rules) 根据变量状态或流水线类型等条件来配置作业的运行。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
jobs:
  deploy_staging:
    if: contains( github.ref, 'staging')
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploy to staging server"
```

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

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

Runner 是执行作业的服务。如果您使用的是 JihuLab.com，您可以使用[实例 Runner 集群](../runners/_index.md)来运行作业，而无需预配您自己的自管理 runner。

关于 Runner 的一些关键细节：

- Runner 可以[配置](../runners/runners_scope.md)为在实例、群组中共享，或专用于单个项目。
- 您可以使用 [`tags` 关键字](../runners/configure_runners.md#control-jobs-that-a-runner-can-run) 进行更精细的控制，并将 runner 与特定作业关联。例如，您可以为需要专用、更强大或特定硬件的作业使用标签。
- 极狐GitLab 支持 [Runner 自动扩缩](https://gitlab.cn/docs/runner/configuration/autoscale/)。仅在需要时使用自动扩缩来预配 runner，并在不需要时进行缩减。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
linux_job:
  runs-on: ubuntu-latest
  steps:
    - run: echo "Hello, $USER"

windows_job:
  runs-on: windows-latest
  steps:
    - run: echo "Hello, %USERNAME%"
```

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

```yaml
linux_job:
  stage: build
  tags:
    - linux-runners
  script:
    - echo "Hello, $USER"

windows_job:
  stage: build
  tags:
    - windows-runners
  script:
    - echo "Hello, %USERNAME%"
```

<a id="artifacts"></a>

#### 产物

在极狐GitLab 中，任何作业都可以使用 [artifacts](../yaml/_index.md#artifacts) 关键字来定义一组在作业完成时要存储的产物。[产物](../jobs/job_artifacts.md) 是可以在后续作业中使用的文件。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
on: [push]
jobs:
  generate_cat:
    steps:
      - run: touch cat.txt
      - run: echo "meow" > cat.txt
      - uses: actions/upload-artifact@v3
        with:
          name: cat
          path: cat.txt
          retention-days: 7
  use_cat:
    needs: [generate_cat]
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: cat
      - run: cat cat.txt
```

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

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

<a id="caching"></a>

#### 缓存

当作业下载一个或多个文件并将其保存以供将来更快访问时，会创建[缓存](../caching/_index.md)。使用相同缓存的后续作业不必再次下载这些文件，因此执行速度更快。缓存存储在 runner 上，如果[启用了分布式缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)，则会上传到 S3。

例如，在 GitHub Actions 的 `workflow` 文件中：

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - run: echo "This job uses a cache."
    - uses: actions/cache@v3
      with:
        path: binaries/
        key: binaries-cache-$CI_COMMIT_REF_SLUG
```

等效的极狐GitLab CI/CD `.gitlab-ci.yml` 文件将是：

```yaml
cache-job:
  script:
    - echo "This job uses a cache."
  cache:
    key: binaries-cache-$CI_COMMIT_REF_SLUG
    paths:
      - binaries/
```

<a id="templates"></a>

#### 模板

在 GitHub 中，Action 是一组需要频繁重复的复杂任务，将其保存以便重用，而无需重新定义 CI/CD 流水线。在极狐GitLab 中，与 Action 等效的是 [`include` 关键字](../yaml/includes.md)，它允许您[从其他文件添加 CI/CD 流水线](../yaml/includes.md)，包括极狐GitLab 内置的模板文件。

示例 GitHub Actions 配置：

```yaml
- uses: hashicorp/setup-terraform@v2.0.3
```

等效的极狐GitLab CI/CD 配置将是：

```yaml
include:
  - template: Terraform.gitlab-ci.yml
```

在这些示例中，`setup-terraform` GitHub Action 和 `Terraform.gitlab-ci.yml` 极狐GitLab 模板并不完全匹配。这两个示例仅用于展示如何重用复杂配置。

<a id="security-scanning-features"></a>

### 安全扫描功能

极狐GitLab 默认提供各种[安全扫描器](../../user/application_security/_index.md)，用于检测 SDLC 所有部分中的漏洞。您可以通过使用模板将这些功能添加到您的极狐GitLab CI/CD 流水线中。

例如，要向您的流水线添加 SAST 扫描，请将以下内容添加到您的 `.gitlab-ci.yml` 中：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml
```

您可以通过使用 CI/CD 变量来自定义安全扫描器的行为，例如使用 [SAST 扫描器](../../user/application_security/sast/_index.md#available-cicd-variables)。

<a id="secrets-management"></a>

### 密钥管理

特权信息，通常称为“secrets”，是您在 CI/CD 工作流中需要的敏感信息或凭据。您可能使用密钥来解锁受保护资源或工具、应用程序、容器和云原生环境中的敏感信息。

对于极狐GitLab 中的密钥管理，您可以使用[受支持的集成](../secrets/_index.md)之一来连接外部服务。这些服务将密钥安全地存储在您的极狐GitLab 项目之外，但您必须订阅该服务。

极狐GitLab 还支持对其他支持 OIDC 的第三方服务进行 [OIDC 认证](../secrets/id_token_authentication.md)。

此外，您可以通过将凭据存储在 CI/CD 变量中来使作业可以使用这些凭据，但以纯文本存储的密钥容易意外暴露。您应始终将敏感信息存储在[掩码](../variables/_index.md#mask-a-cicd-variable)和[受保护](../variables/_index.md#protect-a-cicd-variable)的变量中，这可以降低部分风险。

另外，切勿将密钥作为变量存储在您的 `.gitlab-ci.yml` 文件中，该文件对所有有权访问项目的用户都是公开的。将敏感信息存储在变量中应仅在[项目、群组或实例设置](../variables/_index.md#define-a-cicd-variable-in-the-ui)中进行。

请查阅[安全指南](../variables/_index.md#cicd-variable-security)以提高您的 CI/CD 变量的安全性。

<a id="planning-and-performing-a-migration"></a>

## 规划和执行迁移

以下步骤可帮助您规划和执行此迁移。

<a id="create-a-migration-plan"></a>

### 创建迁移计划

在开始迁移之前，您应该创建一个[迁移计划](plan_a_migration.md)来为迁移做好准备。

<a id="prerequisites"></a>

### 先决条件

在进行任何迁移工作之前，您应该首先：

1. 熟悉极狐GitLab。
   - 阅读[极狐GitLab CI/CD 关键功能](../_index.md)。
   - 按照教程创建[您的第一个极狐GitLab 流水线](../quick_start/_index.md) 以及[更复杂的流水线](../quick_start/tutorial.md)，用于构建、测试和部署静态站点。
   - 查阅 [CI/CD YAML 语法参考](../yaml/_index.md)。
1. 设置并配置极狐GitLab。
1. 测试您的极狐GitLab 实例。
   - 确保 [Runner](../runners/_index.md) 可用，可以使用共享的 JihuLab.com Runner 或安装新的 Runner。

<a id="migration-steps"></a>

### 迁移步骤

1. 将项目从 GitHub 迁移到极狐GitLab：
   - （推荐）您可以使用 [GitHub 导入器](../../user/project/import/github.md) 来自动化从外部 SCM 提供商进行批量导入。
   - 您可以[通过 URL 导入代码仓库](../../user/import/third_party_systems/repo_by_url.md)。
1. 在每个项目中创建 `.gitlab-ci.yml` 文件。
1. 将 GitHub Actions 作业迁移到极狐GitLab CI/CD 作业，并配置它们以直接在合并请求中显示结果。这可以使用[提供的 Agent Skill](https://gitlab.com/gitlab-org/ci-cd/github-actions-to-gitlab-ci) 来自动化。
1. 通过使用[云部署模板](../cloud_deployment/_index.md)、[环境](../environments/_index.md)和 [极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md) 来迁移部署作业。
1. 检查是否有任何 CI/CD 配置可以在不同项目之间重用，然后创建并共享 [CI/CD 组件](../components/_index.md)。
1. 查阅 [流水线效率文档](../pipelines/pipeline_efficiency.md) 以了解如何使您的极狐GitLab CI/CD 流水线更快、更高效。
