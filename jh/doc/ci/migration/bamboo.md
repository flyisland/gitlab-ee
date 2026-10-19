---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Bamboo 迁移
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将 Bamboo Specs 转换为 `.gitlab-ci.yml` 文件，从而从 Atlassian Bamboo 迁移到极狐GitLab CI/CD。

您可以从 Bamboo UI 导出这些 Specs，也可以使用已在 Specs 代码仓库中定义为代码的 Specs。

<a id="key-migration-considerations"></a>

## 迁移关键注意事项

| 配置方面 | Bamboo | 极狐GitLab CI/CD | 迁移任务 |
| --------------------- | ---------------------------------- | ------------------------------------ | --------------- |
| 配置文件 | Bamboo Specs（Java 或 YAML） | `.gitlab-ci.yml` 文件 | 将 Specs 转换为极狐GitLab YAML 语法 |
| 变量语法 | `${bamboo.variableName}` | `$VARIABLE_NAME` | 更新脚本中的所有变量引用 |
| 执行环境 | 构建代理（本地或远程） | 带执行器的 Runner | 安装并配置 Runner |
| 产物共享 | 带订阅的具名产物 | 阶段之间自动继承 | 简化产物配置 |
| 部署 | 单独的部署项目 | 带环境的部署作业 | 在单个流水线中合并构建和部署 |

<a id="configuration-examples"></a>

## 配置示例

<a id="bamboo-specs-export"></a>

### Bamboo Specs 导出

以下示例展示了从 UI 导出的 Bamboo Specs YAML 及其对应的极狐GitLab CI/CD 配置。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 通过嵌套层级组织构建：项目包含多个计划，计划定义阶段和作业，作业执行各项任务。
项目充当共享资源（如变量、凭据和代码仓库连接）的容器，多个计划都可以访问这些资源。

从 UI 导出的 Bamboo Specs 包含这一完整层级，以及权限、通知和项目设置等管理元数据。

查看导出内容时，请重点关注以下对迁移至关重要的元素：

- 作业和任务：实际的构建命令和脚本
- 阶段定义：执行顺序和依赖关系
- 变量和产物：作业之间共享的数据和文件
- 触发器和条件：决定构建何时运行的规则

```yaml
version: 2
plan:
  project-key: AB
  key: TP
  name: test plan
stages:
  - Default Stage:
      manual: false
      final: false
      jobs:
        - Default Job
Default Job:
  key: JOB1
  tasks:
  - checkout:
      force-clean-build: false
      description: Checkout Default Repository
  - script:
      interpreter: SHELL
      scripts:
        - |-
          ruby -v  # Print out ruby version for debugging
          bundle config set --local deployment true  # Install dependencies into ./vendor/ruby
          bundle install -j $(nproc)
          rubocop
          rspec spec
      description: run bundler
  artifact-subscriptions: []
repositories:
  - Demo Project:
      scope: global
triggers:
  - polling:
      period: '180'
branches:
  create: manually
  delete: never
  link-to-jira: true
notifications: []
labels: []
dependencies:
  require-all-stages-passing: false
  enabled-for-branches: true
  block-strategy: none
  plans: []
other:
  concurrent-build-plugin: system-default

---

version: 2
plan:
  key: AB-TP
plan-permissions:
  - users:
    - root
    permissions:
    - view
    - edit
    - build
    - clone
    - admin
    - view-configuration
  - roles:
    - logged-in
    - anonymous
    permissions:
    - view
...
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

极狐GitLab CI/CD 消除了这种嵌套复杂性。每个代码仓库只需包含一个 `.gitlab-ci.yml` 文件，即可定义所有阶段和作业。

```yaml
default:
  image: ruby:latest

stages:
  - default-stage

job1:
  stage: default-stage
  script:
    - ruby -v  # Print out ruby version for debugging
    - bundle config set --local deployment true  # Install dependencies into ./vendor/ruby
    - bundle install -j $(nproc)
    - rubocop
    - rspec spec
```

{{< /tab >}}

{{< /tabs >}}

<a id="jobs-and-tasks"></a>

### 作业和任务

在极狐GitLab 和 Bamboo 中，同一阶段中的作业并行运行，除非必须先满足某个依赖关系。

Bamboo 中可运行的作业数量取决于 Bamboo 构建代理的可用性和 Bamboo 许可证规模。

使用极狐GitLab CI/CD 时，并行作业的数量取决于与极狐GitLab 实例集成的 Runner 数量及其配置的并发数。

{{< tabs >}}

{{< tab title="Bamboo" >}}

在 Bamboo 中，作业由任务组成。任务可以是一组作为脚本运行的命令，也可以是预定义任务，例如源代码检出或产物下载。Bamboo 还在 Atlassian 任务市场中提供其他任务。

```yaml
version: 2
#...

Default Job:
  key: JOB1
  tasks:
  - checkout:
      force-clean-build: false
      description: Checkout Default Repository
  - script:
      interpreter: SHELL
      scripts:
        - |-
          ruby -v
          bundle config set --local deployment true
          bundle install -j $(nproc)
      description: run bundler
other:
  concurrent-build-plugin: system-default
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

极狐GitLab 中与任务对应的是 `script`，它指定 Runner 要执行的命令。您可以使用 CI/CD 模板和 CI/CD 组件来组合您的流水线，无需自己编写所有内容。

```yaml
job1:
  script: "bundle exec rspec"

job2:
  script:
    - ruby -v
    - bundle config set --local deployment true
    - bundle install -j $(nproc)
```

{{< /tab >}}

{{< /tabs >}}

<a id="container-images"></a>

### 容器镜像

以下示例展示了 Bamboo 的 `docker` 关键字如何转换为极狐GitLab 的 `image` 关键字。

{{< tabs >}}

{{< tab title="Bamboo" >}}

构建和部署默认在 Bamboo 构建代理的原生操作系统上运行，但可以使用 `docker` 关键字配置为在容器中运行。

```yaml
version: 2
plan:
  project-key: SAMPLE
  name: Build Ruby App
  key: BUILD-APP

docker: alpine:latest

stages:
  - Build App:
      jobs:
        - Build Application

Build Application:
  tasks:
    - script:
        - # Run builds
  docker:
    image: alpine:edge
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在极狐GitLab CI/CD 中，您只需要 `image` 关键字。

```yaml
default:
  image: alpine:latest

stages:
  - build

build-application:
  stage: build
  script:
    - # Run builds
  image:
    name: alpine:edge
```

{{< /tab >}}

{{< /tabs >}}

<a id="variables"></a>

### 变量

以下示例展示了定义和访问变量时的语法差异。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 具有不同的变量类型，访问方式也各不相同。
系统变量使用 `${system.variableName}`，其他变量使用 `${bamboo.variableName}`。

在脚本任务中，点号会转换为下划线。例如，`${bamboo.variableName}` 会变为 `$bamboo_variableName`。

```yaml
variables:
  username: admin
  releaseType: milestone

Default job:
  tasks:
    - script: echo '$bamboo_username is the DRI for $bamboo_releaseType'
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在极狐GitLab CI/CD 中，变量像常规 Shell 脚本变量一样使用 `$VARIABLE_NAME` 访问。
与 Bamboo 中的系统变量和全局变量类似，极狐GitLab 具有可供每个作业使用的预定义 CI/CD 变量。

```yaml
variables:
  DEFAULT_VAR: "A default variable"

job1:
  variables:
    JOB_VAR: "A job variable"
  script:
    - echo "Variables are '$DEFAULT_VAR' and '$JOB_VAR'"
```

{{< /tab >}}

{{< /tabs >}}

<a id="conditions-and-triggers"></a>

### 条件和触发器

以下示例展示了 Bamboo 条件和触发器如何转换为极狐GitLab 规则。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 有多种触发构建的选项，可以基于代码变更、计划、其他计划的结果或按需触发。可以配置计划定期轮询项目以获取新变更。

```yaml
tasks:
  - script:
      scripts:
        - echo "Hello"
      conditions:
        - variable:
            equals:
              planRepository.branch: development

triggers:
  - polling:
      period: '180'
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

极狐GitLab CI/CD 流水线基于代码变更、计划或 API 调用触发。
流水线不使用轮询。

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_COMMIT_REF_NAME == "development"

workflow:
  rules:
    - changes:
        - .gitlab/**/**.md
      when: never
```

{{< /tab >}}

{{< /tabs >}}

<a id="artifacts"></a>

### 产物

在极狐GitLab 和 Bamboo 中，您都可以使用 `artifacts` 关键字定义作业产物。

{{< tabs >}}

{{< tab title="Bamboo" >}}

在 Bamboo 中，产物通过名称、位置和模式定义。您可以与其他作业和计划共享产物，也可以定义订阅该产物的作业。

`artifact-subscriptions` 用于访问同一计划中另一个作业的产物，
`artifact-download` 用于访问不同计划中作业的产物。

```yaml
version: 2
# ...
Build:
  # ...
  artifacts:
    - name: Test Reports
      location: target/reports
      pattern: '*.xml'
      required: false
      shared: false
    - name: Special Reports
      location: target/reports
      pattern: 'special/*.xml'
      shared: true

Test app:
  artifact-subscriptions:
    - artifact: Test Reports
      destination: deploy

# ...
Build:
  # ...
  tasks:
    - artifact-download:
        source-plan: PROJECTKEY-PLANKEY
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在极狐GitLab 中，默认会下载较早阶段中已完成作业的所有产物。

```yaml
stages:
  - build

pdf:
  stage: build
  script: #generate XML reports
  artifacts:
    name: "test-report-files"
    untracked: true
    paths:
      - target/reports
```

在此示例中：

- 产物的名称是显式指定的，但您可以使用 CI/CD 变量使其动态化。
- `untracked` 关键字设置产物还包含 Git 未跟踪文件，
  以及通过 `paths` 显式指定的文件。

{{< /tab >}}

{{< /tabs >}}

<a id="caching"></a>

### 缓存

在 Bamboo 中，可以使用 Git 缓存来加速构建。Git 缓存在 Bamboo 管理设置中配置，存储在 Bamboo 服务器或远程构建代理上。

极狐GitLab 同时支持 Git 缓存和作业缓存。使用 `cache` 关键字为每个作业定义缓存：

```yaml
test-job:
  stage: build
  cache:
    - key:
        files:
          - Gemfile.lock
      paths:
        - vendor/ruby
    - key:
        files:
          - yarn.lock
      paths:
        - .yarn-cache/
  script:
    - bundle config set --local path 'vendor/ruby'
    - bundle install
    - yarn install --cache-folder .yarn-cache
    - echo Run tests...
```

<a id="deployments"></a>

### 部署

以下示例展示了如何将 Bamboo 部署项目转换为极狐GitLab 部署作业。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 具有部署项目，它们链接到构建计划，以跟踪、获取产物并将其部署到部署环境。创建项目时，您需要将其链接到构建计划，指定部署环境和执行部署的任务。

```yaml
deployment:
  name: Deploy ruby app
  source-plan: build-app

release-naming: release-1.0

environments:
  - Production

Production:
  tasks:
    - # scripts to deploy app to production
    - ./.ci/deploy_prod.sh
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在极狐GitLab CI/CD 中，您可以创建部署作业，将应用部署到环境或创建发布。

```yaml
deploy-to-production:
  stage: deploy
  script:
    - # Run Deployment script
    - ./.ci/deploy_prod.sh
  environment:
    name: production
```

要改为创建发布，请使用 `release` 关键字和 `glab` CLI 工具为 Git 标签创建发布：

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG                  # Run this job when a tag is created manually
  script:
    - echo "Building release version"
  release:
    tag_name: $CI_COMMIT_TAG
    name: 'Release $CI_COMMIT_TAG'
    description: 'Release created using the CLI.'
```

{{< /tab >}}

{{< /tabs >}}

<a id="security-scanning"></a>

## 安全扫描

Bamboo 依赖 Atlassian Marketplace 中提供的第三方任务来运行安全扫描。

极狐GitLab 提供安全扫描器，用于检测 SDLC 各个环节中的漏洞。您可以使用模板在极狐GitLab 中添加这些扫描器，例如为您的流水线添加 SAST 扫描：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml
```

您可以使用 CI/CD 变量自定义安全扫描器的行为。

<a id="secrets-management"></a>

## 密钥管理

Bamboo 中的密钥管理通过共享凭据或 Atlassian Marketplace 中的第三方应用来处理。

要在极狐GitLab 中进行密钥管理，您可以使用受支持的外部服务集成。这些服务将密钥安全地存储在您的极狐GitLab 项目之外，但您必须拥有该服务的订阅。

极狐GitLab 还支持对其他支持 OIDC 的第三方服务进行 OIDC 认证。

此外，您可以将凭据存储在 CI/CD 变量中，使其可供作业使用。但是，以纯文本形式存储的密钥容易意外泄露。您应始终将敏感信息存储在掩码变量和受保护变量中，这可以降低部分风险。

> [!note]
> 切勿将密钥作为变量存储在您的 `.gitlab-ci.yml` 文件中，该文件对所有有权访问该项目的用户公开。敏感信息只应存储在项目、群组或实例设置中的变量里。

<a id="create-a-migration-plan"></a>

## 创建迁移计划

在开始迁移之前，请创建[迁移计划](plan_a_migration.md)并回答以下问题：

- 目前作业使用了哪些 Bamboo 任务，它们的作用是什么？
- 是否有任务封装了 Maven、Gradle 或 NPM 等常见构建工具？
- Bamboo 构建代理上安装了哪些软件？
- 您如何从 Bamboo 进行认证（SSH 密钥、API 令牌或其他密钥）？
- Bamboo 中是否有用于访问外部服务的凭据？
- 是否使用了共享库或模板？

<a id="migrate-from-bamboo-to-gitlab-cicd"></a>

## 从 Bamboo 迁移到极狐GitLab CI/CD

先决条件：

- 您必须已设置并配置好极狐GitLab 实例。
- 您必须有可用的 [Runner](../runners/_index.md)。

从 Bamboo 迁移的步骤：

1. 审计您的 Bamboo 配置：
   - 从 Bamboo UI 将您的 Bamboo 项目/计划导出为 YAML Spec。
   - 列出作业中使用的所有 Bamboo 任务（例如 Maven、Docker、SCP）。
   - 记录每个 Bamboo 构建代理上安装的软件版本。
   - 识别所有共享凭据及其用途。

1. 将您的源代码仓库迁移到极狐GitLab：
   - 使用可用的[导入器](../../user/import/_index.md)自动从外部 SCM 提供商批量导入。
   - 对于单个代码仓库，[通过 URL 导入代码仓库](../../user/import/third_party_systems/repo_by_url.md)。

1. 使用等效软件设置极狐GitLab Runner：
   - 安装与 Bamboo 构建代理上相同的软件版本。
   - 对于复杂的构建代理设置，使用所需工具创建自定义 Docker 镜像。
   - 测试 Runner 能否成功执行您的构建命令。

1. 将 Bamboo Specs 转换为 `.gitlab-ci.yml` 文件：
   - 用极狐GitLab 阶段和作业替换 Bamboo 计划结构。
   - 将 `${bamboo.variableName}` 语法转换为 `$VARIABLE_NAME`。
   - 将 `${bamboo.planKey}` 等 Bamboo 专用变量替换为极狐GitLab 中的等效变量，
     例如 `$CI_PIPELINE_ID`。
   - 移除 Bamboo 检出任务。极狐GitLab 会在每个作业开始时自动检出您的源代码。

1. 迁移产物处理：
   - 移除 Bamboo 的 `artifact-subscriptions` 和 `artifact-download` 配置。
   - 使用阶段之间的自动产物继承。
   - 更新产物路径，使其与您的极狐GitLab 作业结构匹配。

1. 转换 Bamboo 部署项目：
   - 将部署任务从单独的 Bamboo 部署项目移入您的主 `.gitlab-ci.yml` 文件。
   - 将 Bamboo 环境替换为极狐GitLab [环境](../environments/_index.md)。
   - 对常见部署模式使用[云部署模板](../cloud_deployment/_index.md)。
   - 如果要部署到 Kubernetes，请配置[极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md)。

1. 迁移密钥和凭据：
   - 使用[外部密钥集成](../secrets/_index.md)，或将凭据存储为掩码变量和受保护的 CI/CD 变量。

1. 测试并优化迁移后的流水线：
   - 运行测试流水线以验证功能。
   - 添加合并请求集成以显示流水线结果。
   - 优化流水线性能并创建可复用模板。
