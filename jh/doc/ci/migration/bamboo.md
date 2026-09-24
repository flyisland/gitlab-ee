```yaml

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

你可以通过转换从 Bamboo UI 导出或存储在 Spec 仓库中的 Bamboo Specs YAML 配置，从 Atlassian Bamboo 迁移到 极狐GitLab CI/CD。

<a id="key-migration-considerations"></a>

## 关键迁移注意事项

| 配置方面 | Bamboo | 极狐GitLab CI/CD | 迁移任务 |
| --------------------- | ---------------------------------- | ------------------------------------ | --------------- |
| 配置文件 | Bamboo Specs (Java or YAML) | `.gitlab-ci.yml` 文件 | 将 Specs 转换为 极狐GitLab YAML 语法 |
| 变量语法 | `${bamboo.variableName}` | `$VARIABLE_NAME` | 更新脚本中的所有变量引用 |
| 执行环境 | Agents (本地或远程) | 带有执行器的 Runner | 安装和配置 Runner |
| 产物共享 | 可订阅的具名产物 | 阶段之间自动继承 | 简化产物配置 |
| 部署 | 单独的部署项目 | 带有环境的部署 Job | 在单个流水线中合并构建和部署 |

<a id="configuration-examples"></a>

## 配置示例

<a id="bamboo-specs-export"></a>

### Bamboo Specs 导出

以下示例展示了一个从 UI 导出的 Bamboo Specs YAML 及其对应的 极狐GitLab CI/CD 配置。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 通过嵌套层级来组织构建：项目包含多个计划，计划定义阶段和 Job，Job 执行单个任务。项目充当共享资源（如变量、凭据和仓库连接）的容器，多个计划可以访问这些资源。

从 UI 导出的 Bamboo Specs 包含这个完整的层次结构，以及权限、通知和项目设置等管理元数据。

在检查你的导出文件时，请关注以下对迁移至关重要的元素：

- Job 和任务: 实际的构建命令和脚本
- 阶段定义: 串行执行顺序和依赖关系
- 变量和产物: Job 之间共享的数据和文件
- 触发器和条件: 决定构建何时运行的规则

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
          ruby -v  # 打印 Ruby 版本以进行调试
          bundle config set --local deployment true  # 将依赖安装到 ./vendor/ruby
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

极狐GitLab CI/CD 消除了这种嵌套复杂性。取而代之的是，每个仓库都包含一个单一的 `.gitlab-ci.yml` 文件，该文件定义了所有的阶段和 Job。

```yaml
default:
  image: ruby:latest

stages:
  - default-stage

job1:
  stage: default-stage
  script:
    - ruby -v  # 打印 Ruby 版本以进行调试
    - bundle config set --local deployment true  # 将依赖安装到 ./vendor/ruby
    - bundle install -j $(nproc)
    - rubocop
    - rspec spec
```

{{< /tab >}}

{{< /tabs >}}

<a id="jobs-and-tasks"></a>

### Job 和任务

在 极狐GitLab 和 Bamboo 中，同一阶段内的 Job 可以并行运行，除非某个 Job 运行前需要满足特定的依赖关系。

Bamboo 中可以运行的 Job 数量取决于可用 Bamboo 代理的数量和 Bamboo 许可证的大小。

对于 极狐GitLab CI/CD，可并行运行的 Job 数量取决于与 极狐GitLab 实例集成的 Runner 数量以及 Runner 中设置的并发数。

{{< tabs >}}

{{< tab title="Bamboo" >}}

在 Bamboo 中，Job 由任务组成，任务可以是一组作为脚本运行的命令，也可以是预定义任务，如源代码检出、产物下载以及 Atlassian 任务市场中可用的其他任务。

```yaml
version: 2
#...

Default Job:
  key: JOB1
  tasks:
  - checkout:
      force-clean-build: false
      description: 检出默认仓库
  - script:
      interpreter: SHELL
      scripts:
        - |-
          ruby -v
          bundle config set --local deployment true
          bundle install -j $(nproc)
      description: 运行 bundler
other:
  concurrent-build-plugin: system-default
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在 极狐GitLab 中，与 Bamboo 任务相对应的是 `script`，它指定了 Runner 要执行的命令。你可以使用 CI/CD 模板和 CI/CD 组件来编排你的流水线，而无需自己编写所有内容。

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

以下示例展示了如何将 Bamboo `docker` 关键字转换为 极狐GitLab 的 `image` 关键字。

{{< tabs >}}

{{< tab title="Bamboo" >}}

默认情况下，构建和部署在 Bamboo 代理的原生操作系统上运行，但可以使用 `docker` 关键字配置为在容器中运行。

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
        - # 运行构建
  docker:
    image: alpine:edge
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在 极狐GitLab CI/CD 中，你只需要 `image` 关键字。

```yaml
default:
  image: alpine:latest

stages:
  - build

build-application:
  stage: build
  script:
    - # 运行构建
  image:
    name: alpine:edge
```

{{< /tab >}}

{{< /tabs >}}

<a id="variables"></a>

### 变量

以下示例展示了定义和访问变量的语法差异。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 有不同的变量类型，它们拥有不同的访问模式。系统变量使用 `${system.variableName}`，其他变量使用 `${bamboo.variableName}`。

在脚本任务中，点号会被转换为下划线。例如，`${bamboo.variableName}` 会变成 `$bamboo_variableName`。

```yaml
variables:
  username: admin
  releaseType: milestone

Default job:
  tasks:
    - script: echo '$bamboo_username 是 $bamboo_releaseType 的 DRI'
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在 极狐GitLab CI/CD 中，变量像常规的 Shell 脚本变量一样通过 `$VARIABLE_NAME` 访问。与 Bamboo 中的系统变量和全局变量类似，极狐GitLab 提供了预定义的 CI/CD 变量，可用于每个 Job。

```yaml
variables:
  DEFAULT_VAR: "一个默认的变量"

job1:
  variables:
    JOB_VAR: "一个 Job 变量"
  script:
    - echo "变量是 '$DEFAULT_VAR' 和 '$JOB_VAR'"
```

{{< /tab >}}

{{< /tabs >}}

<a id="conditions-and-triggers"></a>

### 条件和触发器

这些示例展示了如何将 Bamboo 的条件和触发器转换为 极狐GitLab 的规则。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 有多种触发构建的选项，可以基于代码更改、计划、其他计划的结果，或者按需触发。可以将计划配置为定期轮询项目以获取新的更改。

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

极狐GitLab CI/CD 流水线基于代码更改、计划或 API 调用来触发。流水线不使用轮询。

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

在 极狐GitLab 和 Bamboo 中，你都可以使用 `artifacts` 关键字来定义 Job 产物。

{{< tabs >}}

{{< tab title="Bamboo" >}}

在 Bamboo 中，产物由名称、位置和模式定义。你可以与其他 Job 和计划共享这些产物，或者定义订阅该产物的 Job。

`artifact-subscriptions` 用于访问同一计划中另一个 Job 的产物，而 `artifact-download` 用于访问不同计划中 Job 的产物。

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

在 极狐GitLab 中，默认会自动下载已完成的前一阶段 Job 中的所有产物。

```yaml
stages:
  - build

pdf:
  stage: build
  script: #生成 XML 报告
  artifacts:
    name: "test-report-files"
    untracked: true
    paths:
      - target/reports
```

在这个例子中：

- 产物的名称是明确指定的，但你可以通过使用 CI/CD 变量使其动态化。
- `untracked` 关键字将产物设置为也包含 Git 未跟踪的文件，以及通过 `paths` 明确指定的文件。

{{< /tab >}}

{{< /tabs >}}

<a id="caching"></a>

### 缓存

在 Bamboo 中，Git 缓存可用于加速构建。Git 缓存在 Bamboo 管理设置中进行配置，并存储在 Bamboo 服务器或远程代理上。

极狐GitLab 同时支持 Git 缓存和 Job 缓存。每个 Job 使用 `cache` 关键字定义缓存：

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

以下示例展示了如何将 Bamboo 部署项目转换为 极狐GitLab 的部署 Job。

{{< tabs >}}

{{< tab title="Bamboo" >}}

Bamboo 有部署项目，这些项目链接到构建计划，以跟踪、获取并将产物部署到部署环境。创建项目时，你需要将其链接到一个构建计划，指定部署环境和执行部署的任务。

```yaml
deployment:
  name: Deploy ruby app
  source-plan: build-app

release-naming: release-1.0

environments:
  - Production

Production:
  tasks:
    - # 将应用程序部署到生产环境的脚本
    - ./.ci/deploy_prod.sh
```

{{< /tab >}}

{{< tab title="极狐GitLab CI/CD" >}}

在 极狐GitLab CI/CD 中，你可以创建一个部署到环境或创建发布的部署 Job。

```yaml
deploy-to-production:
  stage: deploy
  script:
    - # 运行部署脚本
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
    - if: $CI_COMMIT_TAG                  # 当手动创建标签时运行此 Job
  script:
    - echo "正在构建发布版本"
  release:
    tag_name: $CI_COMMIT_TAG
    name: '发布 $CI_COMMIT_TAG'
    description: '使用 CLI 创建的发布。'
```

{{< /tab >}}

{{< /tabs >}}

<a id="security-scanning"></a>

## 安全扫描

Bamboo 依赖 Atlassian Marketplace 中提供的第三方任务来运行安全扫描。

极狐GitLab 提供安全扫描器，用于检测 SDLC 各个部分的漏洞。你可以在 极狐GitLab 中使用模板添加这些扫描器，例如，将 SAST 扫描添加到你的流水线中：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml
```

你可以通过使用 CI/CD 变量来自定义安全扫描器的行为。

<a id="secrets-management"></a>

## 密钥管理

Bamboo 中的密钥管理通过共享凭据或 Atlassian Marketplace 中的第三方应用程序来处理。

对于 极狐GitLab 中的密钥管理，你可以使用支持的外部服务集成。这些服务将你的密钥安全地存储在 极狐GitLab 项目之外，但你需要为这些服务拥有订阅。

极狐GitLab 也支持对其他支持 OIDC 的第三方服务进行 OIDC 认证。

此外，你可以通过将凭据存储在 CI/CD 变量中，使 Job 可以使用它们，但以明文形式存储的密钥容易意外泄露。你应始终将敏感信息存储在已掩码和受保护的变量中，这可以减轻部分风险。

> [!note]
> 永远不要将密钥作为变量存储在 `.gitlab-ci.yml` 文件中，该文件对所有有权访问项目的用户都是公开的。敏感信息的变量存储只应在项目、群组或实例设置中进行。

<a id="create-a-migration-plan"></a>

## 创建迁移计划

在开始迁移之前，请创建一个[迁移计划](plan_a_migration.md)并回答以下问题：

- 当前 Job 使用哪些 Bamboo 任务，它们做什么？
- 是否有任务封装了常见的构建工具，如 Maven、Gradle 或 NPM？
- Bamboo 代理上安装了哪些软件？
- 你如何从 Bamboo 进行身份验证 (SSH 密钥、API 令牌或其他密钥)？
- Bamboo 中是否有访问外部服务的凭据？
- 是否使用了共享库或模板？

<a id="migrate-from-bamboo-to-gitlab-cicd"></a>

## 从 Bamboo 迁移到 极狐GitLab CI/CD

先决条件：

- 你必须已设置并配置好一个 极狐GitLab 实例。
- 你必须拥有[可用的 Runner](../runners/_index.md)。

要从 Bamboo 迁移：

1. 审查你的 Bamboo 配置：
   - 从 Bamboo UI 将你的 Bamboo 项目/计划导出为 YAML Specs。
   - 列出你的 Job 中使用的所有 Bamboo 任务 (例如，Maven, Docker, SCP)。
   - 记录每个 Bamboo 代理上安装的软件版本。
   - 识别所有共享凭据及其用途。

1. 将你的源代码仓库迁移到 极狐GitLab：
   - 使用可用的[导入器](../../user/import/_index.md)自动完成从外部 SCM 提供商的大规模导入。
   - 对于单个仓库，[通过 URL 导入仓库](../../user/import/third_party_systems/repo_by_url.md)。

1. 设置具有同等功能软件的 极狐GitLab Runner：
   - 安装与你 Bamboo 代理上相同版本的软件。
   - 对于复杂的代理设置，创建包含所需工具的自定义 Docker 镜像。
   - 测试 Runner 能否成功执行你的构建命令。

1. 将 Bamboo Specs 转换为 `.gitlab-ci.yml` 文件：
   - 将 Bamboo 计划结构替换为 极狐GitLab 的阶段和 Job。
   - 将 `${bamboo.variableName}` 语法转换为 `$VARIABLE_NAME`。
   - 将 Bamboo 特有的变量，如 `${bamboo.planKey}`，替换为对应的 极狐GitLab 变量，如 `$CI_PIPELINE_ID`。
   - 移除 Bamboo 检出任务。极狐GitLab 会在每个 Job 开始时自动检出你的源代码。

1. 迁移产物处理：
   - 移除 Bamboo 的 `artifact-subscriptions` 和 `artifact-download` 配置。
   - 使用阶段间的自动产物继承。
   - 更新产物路径以匹配你的 极狐GitLab Job 结构。

1. 转换 Bamboo 部署项目：
   - 将部署任务从单独的 Bamboo 部署项目移动到你的主 `.gitlab-ci.yml` 文件中。
   - 将 Bamboo 环境替换为 极狐GitLab [环境](../environments/_index.md)。
   - 使用[云部署模板](../cloud_deployment/_index.md)来应用常用的部署模式。
   - 如果部署到 Kubernetes，请配置 [极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md)。

1. 迁移密钥和凭据：
   - 使用[外部密钥集成](../secrets/_index.md)或将凭据存储为已掩码和受保护的 CI/CD 变量。

1. 测试并优化你迁移后的流水线：
   - 运行测试流水线以验证功能。
   - 添加合并请求集成以显示流水线结果。
   - 优化流水线性能并创建可复用的模板。
```