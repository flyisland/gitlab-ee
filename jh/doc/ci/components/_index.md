---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 组件
description: 可复用的、带版本控制的 CI/CD 组件，用于流水线。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

CI/CD 组件是一个可复用的单一流水线配置单元。使用组件可以创建更大流水线的一小部分，甚至可以组合出完整的流水线配置。

组件可以通过[输入参数](../inputs/_index.md)进行配置，从而实现更动态的行为。

CI/CD 组件与[使用 `include` 关键字添加的其他配置](../yaml/includes.md)类似，但具有以下优势：

- 组件可以列入 [CI/CD Catalog](#cicd-catalog)。
- 组件可以发布并使用特定版本。
- 可以在同一个项目中定义多个组件并一起进行版本控制。

除了创建自己的组件外，您也可以在 [CI/CD Catalog](#cicd-catalog) 中搜索已发布且具备所需功能的组件。

<!-- Video published on 2024-01-22. DRI: Developer Relations, <https://gitlab.com/groups/gitlab-com/marketing/developer-relations/-/epics/399> -->

有关常见问题和其他支持，请参阅 [FAQ：GitLab CI/CD Catalog](https://about.gitlab.com/blog/faq-gitlab-ci-cd-catalog/) 博客文章。

<a id="component-project"></a>

## 组件项目

组件项目是一个极狐GitLab 项目，其代码仓库承载一个或多个组件。项目中的所有组件一起进行版本控制，每个项目最多包含 100 个组件。

如果某个组件需要与其他组件不同的版本控制，则应将该组件移至专用的组件项目。

<a id="create-a-component-project"></a>

### 创建组件项目

要创建组件项目，您必须：

1. [创建新项目](../../user/project/_index.md#create-a-blank-project)，并包含 `README.md` 文件：
   - 确保描述清晰地介绍该组件。
   - 可选。项目创建后，您可以[添加项目头像](../../user/project/working_with_projects.md#add-a-project-avatar)。

   发布到 [CI/CD catalog](#cicd-catalog) 的组件在显示组件项目摘要时，会同时使用描述和头像。

1. 按照[必需的目录结构](#directory-structure)为每个组件添加一个 YAML 配置文件。例如：

   ```yaml
   spec:
     inputs:
       stage:
         default: test
   ---
   component-job:
     script: echo job 1
     stage: $[[ inputs.stage ]]
   ```

您可以立即[使用该组件](#use-a-component)，但也可以考虑将组件发布到 [CI/CD catalog](#cicd-catalog)。

<a id="directory-structure"></a>

### 目录结构

代码仓库必须包含：

- 一个 `README.md` Markdown 文件，用于记录代码仓库中所有组件的详细信息。
- 一个顶层 `templates/` 目录，其中包含所有组件配置。在此目录中，您可以：
  - 为每个组件使用以 `.yml` 结尾的单个文件，例如 `templates/secret-detection.yml`。
  - 为每个组件创建包含 `template.yml` 的子目录，例如 `templates/secret-detection/template.yml`。使用该组件的其他项目只会使用 `template.yml` 文件。这些目录中的其他文件不会随组件一起发布，但可用于测试或构建容器镜像等用途。

组件文件名和子目录名可以包含字母、数字、下划线（`_`）、连字符（`-`）和句点（`.`）。例如，`templates/secret-detection.enterprise.yml` 和 `templates/secret-detection.enterprise/template.yml` 都是有效的组件文件名。

> [!note]
> 可选地，每个组件也可以有自己的 `README.md` 文件，提供更详细的信息，并可从顶层 `README.md` 文件链接到该文件。这有助于更好地概览您的组件项目及其使用方法。

您还应该：

- 配置项目的 `.gitlab-ci.yml` 以[测试组件](#test-the-component)并[发布新版本](#publish-a-new-release)。
- 添加一个 `LICENSE.md` 文件，选择适合您组件使用方式的许可证。例如 [MIT](https://opensource.org/license/mit) 或 [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0#apply) 开源许可证。

例如：

- 如果项目只包含一个组件，目录结构应类似于：

  ```plaintext
  ├── templates/
  │   └── my-component.yml
  ├── LICENSE.md
  ├── README.md
  └── .gitlab-ci.yml
  ```

- 如果项目包含多个组件，则目录结构应类似于：

  ```plaintext
  ├── templates/
  │   ├── my-component.yml
  │   └── my-other-component/
  │       ├── template.yml
  │       ├── Dockerfile
  │       └── test.sh
  ├── LICENSE.md
  ├── README.md
  └── .gitlab-ci.yml
  ```

  在此示例中：

  - `my-component` 组件的配置定义在单个文件中。
  - `my-other-component` 组件的配置包含目录中的多个文件。使用该组件的其他项目只能使用 `template.yml` 文件。

<a id="use-a-component"></a>

## 使用组件

先决条件：

如果您是包含当前群组或项目的父群组成员：

- 您必须具有由项目父群组的可见性级别所设定的最低角色。例如，如果父项目设置为 **Private**，您必须具有报告者、开发者、维护者或所有者角色。

要将组件添加到项目的 CI/CD 配置中，请使用 [`include: component`](../yaml/_index.md#includecomponent) 关键字。组件引用的格式为 `<fully-qualified-domain-name>/<project-path>/<component-name>@<specific-version>`，例如：

```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security-components/secret-detection@1.0.0
    inputs:
      stage: build
```

在此示例中：

- `$CI_SERVER_FQDN` 是用于匹配极狐GitLab 主机的完全限定域名（FQDN）的[预定义变量](../variables/predefined_variables.md)。您只能引用与您的项目位于同一极狐GitLab 实例中的组件。
- `my-org/security-components` 是包含该组件的项目的完整路径。
- `secret-detection` 是组件名称，定义为单个文件 `templates/secret-detection.yml` 或包含 `template.yml` 的目录 `templates/secret-detection/`。
- `1.0.0` 是组件的[版本](#component-versions)。

流水线配置和组件配置不是独立处理的。当流水线启动时，任何包含的组件配置都会[合并](../yaml/includes.md#merge-method-for-include)到流水线的配置中。如果您的流水线和组件都包含同名配置，它们可能会以意外的方式相互作用。

例如，两个同名作业会合并为一个作业。类似地，如果组件使用 `extends` 引用的配置与您流水线中的某个作业同名，则可能会扩展错误的配置。请确保您的流水线和组件不共享任何同名配置，除非您有意[覆盖](../yaml/includes.md#override-included-configuration-values)组件的配置。

要在极狐GitLab 私有化部署实例上使用 JihuLab.com 组件，您必须[镜像组件项目](#use-a-gitlabcom-component-on-gitlab-self-managed)。

> [!warning]
> 如果组件需要使用令牌、密码或其他敏感数据才能运行，请务必审计组件的源代码，以确认这些数据仅用于执行您预期并授权的操作。您还应该使用完成操作所需的最小权限、访问范围或作用域的令牌和密钥。

<a id="component-versions"></a>

### 组件版本

按优先级从高到低排列，组件版本可以是：

- 提交 SHA，例如 `e3262fdd0914fa823210cdb79a8c421e2cef79d8`。
- 标签，例如：`1.0.0`。如果存在同名的标签和提交 SHA，则提交 SHA 优先于标签。发布到 CI/CD Catalog 的组件必须使用[语义化版本](#semantic-versioning)进行标记。
- 分支名称，例如 `main`。如果存在同名的分支和标签，则标签优先于分支。
- `~latest` 或部分语义化版本，用于选择 CI/CD Catalog 中已发布的符合指定模式的最新版本。只有在您希望始终使用绝对最新版本（可能包含破坏性变更）时才使用 `~latest`。`~latest` 不包含预发布版本，例如 `1.0.1-rc`，这些版本不被视为可用于生产环境。

您可以使用组件支持的任何版本，但建议使用已发布到 CI/CD catalog 的版本。使用提交 SHA 或分支名称引用的版本可能未在 CI/CD catalog 中发布，但可用于测试。

<a id="partial-semantic-versions"></a>

#### 部分语义化版本

在引用 CI/CD catalog 组件时，您可以使用部分语义化版本号和关键字 `~latest` 来选择符合您规格的最新已发布版本。

这些格式仅适用于已发布的 CI/CD catalog 组件，不适用于普通项目组件。这确保了当您使用 `1.2` 或 `~latest` 等格式时，只会拉取已经过验证并发布到 catalog 的组件，而不是来自任意代码仓库的潜在未测试代码。

这种方法为组件的使用者和作者都带来了显著好处：

- 对于用户来说，使用部分版本是自动接收次要或补丁更新的绝佳方式，而无需承担主要版本带来的破坏性变更风险。这可以确保您的流水线在保持稳定性的同时，及时获得最新的错误修复和安全补丁。
- 对于组件作者来说，部分版本支持允许发布主要版本，而不会立即破坏现有流水线的风险。指定了部分版本的用户会继续使用最新的兼容次要或补丁版本，从而有时间按照自己的节奏更新其流水线。

使用：

- `1.2` 选择最新的 `1.2.*` 版本
- `1` 选择最新的 `1.*.*` 版本
- `~latest` 选择最新发布的版本

例如，某组件有以下版本：`1.0.0`、`1.1.0`、`1.1.1`、`1.2.0`、`2.0.0`、`2.0.1`、`2.1.0`

引用该组件时：

- `1` 选择 `1.2.0`
- `1.1` 选择 `1.1.1`
- `~latest` 选择 `2.1.0`

使用部分版本选择时，永远不会获取预发布版本。要获取预发布版本，请指定完整版本，例如 `1.0.1-rc`。

<a id="use-component-context-in-components"></a>

### 在组件中使用组件上下文

组件可以通过组件上下文 [CI/CD 表达式](../yaml/expressions.md)访问自身的元数据。在组件模板中使用此表达式可以动态引用版本、提交 SHA 和其他元数据。

要在组件中使用组件上下文，您必须：

1. 在 [`spec:component`](../yaml/_index.md#speccomponent) 头部中声明组件需要哪些组件上下文字段。`spec:component` 支持 `name`、`sha`、`version` 和 `reference` 字段。
1. 在组件模板中（`spec` 部分之外）使用 CI/CD 表达式 `$[[ component.field-name ]]` 引用上下文字段。

例如，一个引用使用相同版本构建的 Docker 镜像的组件：

```yaml
spec:
  component: [name, version, reference]
  inputs:
    stage:
      default: build
---

build-image:
  stage: $[[ inputs.stage ]]
  image: registry.example.com/$[[ component.name ]]:$[[ component.version ]]
  script:
    - echo "Building with component version $[[ component.version ]]"
    - echo "Component reference: $[[ component.reference ]]"
```

您还可以使用组件上下文来[引用带版本的资源](examples.md#use-component-context-to-reference-versioned-resources)。

<a id="component-spec-section"></a>

### 组件 `spec` 部分

组件模板中的 `spec` 部分定义了组件的配置和输入。您可以在 `spec` 部分中使用以下关键字：

- [`description`](../yaml/_index.md#specdescription)：提供组件的简短描述，该描述会显示在 CI/CD Catalog 中。
- [`inputs`](../yaml/_index.md#specinputs)：定义输入参数，供用户自定义组件配置。
- [`component`](../yaml/_index.md#speccomponent)：声明哪些组件上下文字段可用于插值（例如 `name`、`sha`、`version` 和 `reference`）。

> [!note]
> 您不能在组件中使用 [`spec:include`](../yaml/_index.md#specinclude)。组件应该是自包含的，不应依赖外部文件。应直接在组件中定义输入，而不是从单独的文件中包含它们。

<a id="write-a-component"></a>

## 编写组件

本节介绍创建高质量组件项目的一些最佳实践。

<a id="manage-dependencies"></a>

### 管理依赖项

虽然组件可以反过来使用其他组件，但请务必谨慎选择依赖项。要管理依赖项，您应该：

- 将依赖项保持在最低限度。少量重复通常比拥有依赖项更好。
- 尽可能依赖本地资源。例如，使用 [`include:local`](../yaml/_index.md#includelocal) 是确保多个文件使用相同 Git SHA 的好方法。
- 当依赖其他项目的组件时，将其版本固定到 catalog 中的某个版本，而不是使用 `~latest` 或 Git 引用等移动目标版本。使用版本或 Git SHA 可以保证您始终获取相同的修订版本，并确保您组件的使用者获得一致的行为。
- 定期更新依赖项，将其固定到更新的版本。然后使用更新后的依赖项发布组件的新版本。
- 评估依赖项的权限，并使用所需权限最少的依赖项。例如，如果您需要构建镜像，请考虑使用 [Buildah](https://buildah.io/) 而不是 Docker，这样就不需要具有特权 Docker 守护进程的 Runner。

<a id="write-a-clear-readmemd"></a>

### 编写清晰的 `README.md`

每个组件项目都应该有清晰全面的文档。要编写好的 `README.md` 文件：

- 首先概述组件提供的功能。
- 如果项目包含多个组件，请使用[目录](../../user/markdown.md#table-of-contents)帮助用户快速跳转到特定组件的详细信息。
- 添加一个 `## Components` 部分，并为每个组件添加诸如 `### Component A` 的子部分。
- 在每个组件部分中：
  - 描述组件的作用。
  - 至少添加一个展示如何使用它的 YAML 示例。
  - 使用 [`spec:inputs:description`](../yaml/_index.md#specinputsdescription) 记录组件使用的任何变量或密钥。
  - 不要在 `README` 中重复输入文档。输入会自动显示在组件页面上。相反，应链接到已发布的组件。
- 如果欢迎贡献，请添加 `## Contribute` 部分。

如果组件需要更多说明，请在组件目录中添加一个 Markdown 文件作为附加文档，并从主 `README.md` 文件链接到该文件。例如：

```plaintext
README.md    # with links to the specific docs.md
templates/
├── component-1/
│   ├── template.yml
│   └── docs.md
└── component-2/
    ├── template.yml
    └── docs.md
```

有关示例，请参阅 [AWS 组件 README](https://gitlab.com/components/aws/-/blob/main/README.md)。

<a id="test-the-component"></a>

### 测试组件

强烈建议在开发工作流中测试 CI/CD 组件，这有助于确保行为一致。

通过在根目录中创建 `.gitlab-ci.yml`，像测试任何其他项目一样在 CI/CD 流水线中测试变更。请务必测试组件的行为和潜在副作用。如有需要，可以使用 [极狐GitLab API](../../api/rest/_index.md)。

例如：

```yaml
include:
  # include the component located in the current project from the current SHA
  - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/my-component@$CI_COMMIT_SHA
    inputs:
      stage: build

stages: [build, test, release]

# Check if `component job of my-component` is added.
# This example job could also test that the included component works as expected.
# You can inspect data generated by the component, use GitLab API endpoints, or third-party tools.
ensure-job-added:
  stage: test
  image: badouralix/curl-jq
  # Replace "component job of my-component" with the job name in your component.
  script:
    - |
      route="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/pipelines/${CI_PIPELINE_ID}/jobs"
      count=`curl --silent --header "JOB-TOKEN: ${CI_JOB_TOKEN}" "$route" | jq 'map(select(.name | contains("component job of my-component"))) | length'`
      if [ "$count" != "1" ]; then
        exit 1; else
        echo "Component Job present"
      fi

# If the pipeline is for a new tag with a semantic version, and all previous jobs succeed,
# create the release.
create-release:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  script: echo "Creating release $CI_COMMIT_TAG"
  rules:
    - if: $CI_COMMIT_TAG
  release:
    tag_name: $CI_COMMIT_TAG
    description: "Release $CI_COMMIT_TAG of components repository $CI_PROJECT_PATH"
```

提交并推送变更后，流水线会测试组件，如果之前的作业通过，则会创建版本。

> [!note]
> 如果项目是私有的，则需要进行身份验证。

<a id="test-a-component-against-sample-files"></a>

#### 针对示例文件测试组件

在某些情况下，组件需要与源文件交互。例如，构建 Go 源代码的组件可能需要一些 Go 示例来进行测试。或者，构建 Docker 镜像的组件可能需要一些示例 Dockerfile 来进行测试。

您可以将此类示例文件直接包含在组件项目中，以便在组件测试期间使用。

您可以在[测试组件的示例](examples.md#test-a-component)中了解更多信息。

<a id="avoid-hard-coding-instance-or-project-specific-values"></a>

### 避免硬编码实例或项目特定的值

在您的组件中[使用另一个组件](#use-a-component)时，请使用 `$CI_SERVER_FQDN` 而不是您实例的完全限定域名（例如 `gitlab.com`）。

在组件中访问极狐GitLab API 时，请使用 `$CI_API_V4_URL` 而不是您实例的完整 URL 和路径（例如 `https://gitlab.com/api/v4`）。

这些[预定义变量](../variables/predefined_variables.md)可确保您的组件在其他实例上也能正常工作，例如在极狐GitLab 私有化部署实例上[使用 JihuLab.com 组件](#use-a-gitlabcom-component-on-gitlab-self-managed)时。

<a id="do-not-assume-api-resources-are-always-public"></a>

### 不要假设 API 资源始终是公开的

确保组件及其测试流水线也能[在极狐GitLab 私有化部署上](#use-a-gitlabcom-component-on-gitlab-self-managed)正常工作。虽然 JihuLab.com 上公开项目的某些 API 资源可以通过未经身份验证的请求访问，但在极狐GitLab 私有化部署实例上，组件项目可能会被镜像为私有或内部项目。

重要的是，可以通过输入或变量选择性地提供访问令牌，以便在极狐GitLab 私有化部署实例上对请求进行身份验证。

<a id="avoid-using-global-keywords"></a>

### 避免使用全局关键字

避免在组件中使用[全局关键字](../yaml/_index.md#global-keywords)。在组件中使用这些关键字会影响流水线中的所有作业，包括直接在主 `.gitlab-ci.yml` 中定义的作业或其他包含的组件中的作业。

作为全局关键字的替代方案：

- 将配置直接添加到每个作业，即使这会在组件配置中产生一些重复。
- 在组件中使用 [`extends`](../yaml/_index.md#extends) 关键字，但使用唯一名称，以降低组件合并到配置中时发生命名冲突的风险。

例如，避免使用 `default` 全局关键字：

```yaml
# Not recommended
default:
  image: ruby:3.0

rspec-1:
  script: bundle exec rspec dir1/

rspec-2:
  script: bundle exec rspec dir2/
```

相反，您可以：

- 将配置显式添加到每个作业：

  ```yaml
  rspec-1:
    image: ruby:3.0
    script: bundle exec rspec dir1/

  rspec-2:
    image: ruby:3.0
    script: bundle exec rspec dir2/
  ```

- 使用 `extends` 复用配置：

  ```yaml
  .rspec-image:
    image: ruby:3.0

  rspec-1:
    extends:
      - .rspec-image
    script: bundle exec rspec dir1/

  rspec-2:
    extends:
      - .rspec-image
    script: bundle exec rspec dir2/
  ```

<a id="replace-hardcoded-values-with-inputs"></a>

### 用输入替换硬编码值

避免在 CI/CD 组件中使用硬编码值。硬编码值可能会迫使组件使用者需要查看组件的内部细节，并调整其流水线才能与组件配合使用。

一个常见的存在硬编码值问题的关键字是 `stage`。如果组件作业的阶段被硬编码，所有使用该组件的流水线都必须定义完全相同的阶段，或者[覆盖](../yaml/includes.md#override-included-configuration-values)该配置。

首选方法是使用 [`input` 关键字](../inputs/_index.md)进行动态组件配置。组件使用者可以指定他们需要的精确值。

例如，要创建一个具有可由用户定义的 `stage` 配置的组件：

- 在组件配置中：

  ```yaml
  spec:
    inputs:
      stage:
        default: test
  ---
  unit-test:
    stage: $[[ inputs.stage ]]
    script: echo unit tests

  integration-test:
    stage: $[[ inputs.stage ]]
    script: echo integration tests
  ```

- 在使用该组件的项目中：

  ```yaml
  stages: [verify, release]

  include:
    - component: $CI_SERVER_FQDN/myorg/ruby/test@1.0.0
      inputs:
        stage: verify
  ```

<a id="define-job-names-with-inputs"></a>

#### 使用输入定义作业名称

与 `stage` 关键字的值类似，您应该避免在 CI/CD 组件中硬编码作业名称。当组件的使用者可以自定义作业名称时，他们可以防止与其流水线中现有名称发生冲突。使用者还可以通过使用不同的名称，以不同的输入选项多次包含同一个组件。

使用 `inputs` 允许组件的使用者定义特定的作业名称或作业名称前缀。例如：

```yaml
spec:
  inputs:
    job-prefix:
      description: "Define a prefix for the job name"
    job-name:
      description: "Alternatively, define the job's name"
    job-stage:
      default: test
---

"$[[ inputs.job-prefix ]]-scan-website":
  stage: $[[ inputs.job-stage ]]
  script:
    - scan-website-1

"$[[ inputs.job-name ]]":
  stage: $[[ inputs.job-stage ]]
  script:
    - scan-website-2
```

<a id="replace-custom-cicd-variables-with-inputs"></a>

### 用输入替换自定义 CI/CD 变量

在组件中使用 CI/CD 变量时，请评估是否应该改用 `inputs` 关键字。当 `inputs` 是更好的解决方案时，避免要求用户定义自定义变量来配置组件。

输入在组件的 `spec` 部分中显式定义，并且比变量具有更好的验证。例如，如果未向组件传递必需的输入，极狐GitLab 会返回流水线错误。相比之下，如果未定义变量，其值为空，并且不会报错。

例如，使用 `inputs` 而不是变量来配置扫描器的输出格式：

- 在组件配置中：

  ```yaml
  spec:
    inputs:
      scanner-output:
        default: json
  ---
  my-scanner:
    script: my-scan --output $[[ inputs.scanner-output ]]
  ```

- 在使用该组件的项目中：

  ```yaml
  include:
    - component: $CI_SERVER_FQDN/path/to/project/my-scanner@1.0.0
      inputs:
        scanner-output: yaml
  ```

在其他情况下，CI/CD 变量可能仍然是首选。例如：

- 使用[预定义变量](../variables/predefined_variables.md)自动配置组件以匹配用户的项目。
- 要求用户将敏感值存储为[项目设置中的掩码或受保护 CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-ui)。

<a id="cicd-catalog"></a>

## CI/CD Catalog

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[CI/CD Catalog](https://gitlab.com/explore/catalog) 是一个包含已发布 CI/CD 组件的项目列表，您可以使用这些组件来扩展您的 CI/CD 工作流。

任何人都可以[创建组件项目](#create-a-component-project)并将其添加到 CI/CD Catalog，或者为现有项目做出贡献以改进可用组件。

如需点击式演示，请参阅 [CI/CD Catalog 测试版产品导览](https://gitlab.navattic.com/cicd-catalog)。
<!-- Demo published on 2024-01-24 -->

<a id="view-the-cicd-catalog"></a>

### 查看 CI/CD Catalog

要访问 CI/CD Catalog 并查看可供您使用的已发布组件：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **探索**。
1. 选择 **CI/CD Catalog**。

或者，如果您已经在项目的[流水线编辑器](../pipeline_editor/_index.md)中，可以选择 **CI/CD Catalog**。

CI/CD catalog 中组件的可见性遵循组件源项目的[可见性设置](../../user/public_access.md)。源项目设置为：

- 私有的组件仅对在源组件项目中具有访客、计划者、报告者、开发者、维护者或所有者角色的用户可见。要使用组件，您必须具有报告者、开发者、维护者或所有者角色。
- 内部的组件仅对登录到极狐GitLab 实例的用户可见。
- 公开的组件对任何可以访问极狐GitLab 实例的人可见。

列表中的每个 CI/CD Catalog 项目都会显示使用次数。此计数表示在过去 30 天内在流水线中使用过该 Catalog 项目中任何组件的唯一项目总数。

<a id="view-cicd-catalog-project-analytics"></a>

### 查看 CI/CD Catalog 项目分析

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您维护 CI/CD catalog 资源，可以查看使用分析，以了解您的组件在各项目中的采用情况。

先决条件：

- 您必须对一个或多个 catalog 资源项目具有维护者或所有者角色。

要查看 catalog 资源分析：

1. 在顶部栏中，选择 **搜索或跳转到** > **探索**。
1. 选择 **CI/CD Catalog**。
1. 选择 **分析** 选项卡。

分析视图会显示您具有维护者或所有者角色的 catalog 资源。此视图显示：

- **项目**：catalog 资源名称及其最新发布版本。
- **使用统计**：在过去 30 天内在流水线中使用过此 catalog 资源中某个组件的唯一项目数量。
- **组件**：catalog 资源最新版本中可用组件的列表。

例如：

![catalog 资源分析页面，显示 3 个组件及其使用数量。](img/catalog_analytics_v18_10.png)

您可以使用这些信息来：

- 确定哪些 catalog 资源被最广泛地采用。
- 跟踪组件随时间的使用趋势。
- 了解哪些项目正在使用您的 catalog 资源。
- 就组件维护和弃用做出明智的决策。

<a id="view-component-usage-details"></a>

### 查看组件使用详情

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您维护 CI/CD catalog 组件项目，可以查看详细的组件使用信息，以了解哪些项目使用了这些组件以及它们使用的版本。这有助于您规划升级、传达弃用信息，并识别使用过时版本的项目。

详情页面还会在每个组件名称旁边显示使用次数。此计数是特定于版本的，显示在过去 30 天内使用该组件版本的唯一项目数量。

先决条件：

- 您必须对 catalog 资源项目具有维护者或所有者角色。

要查看组件使用详情：

1. 在顶部栏中，选择 **搜索或跳转到** > **探索**。
1. 选择 **CI/CD Catalog**。
1. 从 catalog 中选择一个组件项目。
1. 在详情页面上，选择 **使用** 选项卡。

此选项卡列出了在过去 30 天内在流水线中包含过此项目任何组件的项目。该列表仅包含您有权查看的项目。

详细信息包括：

- **项目路径**：项目的完整路径，带有指向项目的链接。
- **状态**：如果项目使用了组件的最新版本，则标记为 **最新**。否则为 **已过时**。
- **使用的组件**：项目使用的组件名称和版本。

对您不可见的项目显示为 **私有项目**，不带链接。

您可以使用这些信息来：

- 识别使用过时组件版本并需要升级的项目。
- 在新版本可用或弃用组件时通知项目维护者。
- 了解特定组件版本在您组织中的采用情况。

<a id="publish-a-component-project"></a>

### 发布组件项目

要在 CI/CD catalog 中发布组件项目，您必须：

1. 将项目设置为 catalog 项目。
1. 发布新版本。

<a id="set-a-component-project-as-a-catalog-project"></a>

#### 将组件项目设置为 catalog 项目

要使组件项目的已发布版本在 CI/CD catalog 中可见，您必须将项目设置为 catalog 项目。

先决条件：

- 您必须对项目具有所有者角色。

要将项目设置为 catalog 项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 打开 **CI/CD Catalog 项目** 开关。

只有在您发布新版本后，项目才会在 catalog 中可被找到。

要使用自动化启用此设置，您可以使用 [`mutationcatalogresourcescreate`](../../api/graphql/reference/_index.md#mutationcatalogresourcescreate) GraphQL 端点。[议题 463043](https://gitlab.com/gitlab-org/gitlab/-/issues/463043) 提议也在 REST API 中公开此功能。

<a id="publish-a-new-release"></a>

#### 发布新版本

CI/CD 组件可以[被使用](#use-a-component)而无需列入 CI/CD catalog。但是，在 catalog 中发布组件的版本可以使其被其他用户发现。

先决条件：

- 您必须对项目具有维护者或所有者角色。
- 项目必须：
  - 被设置为 [catalog 项目](#set-a-component-project-as-a-catalog-project)。
  - 已定义[项目描述](../../user/project/working_with_projects.md#edit-a-project)。
  - 在要发布的标签的提交 SHA 的根目录中有一个 `README.md` 文件。
  - 在要发布的标签的提交 SHA 的 `templates/` 目录中至少有一个 [CI/CD 组件](#directory-structure)。
- 您必须在 CI/CD 作业中使用 [`release` 关键字](../yaml/_index.md#release)来创建版本，而不是使用 [Releases API](../../api/releases/_index.md#create-a-release)。

要将组件的新版本发布到 catalog：

1. 在项目的 `.gitlab-ci.yml` 文件中添加一个作业，该作业在创建标签时使用 `release` 关键字创建新版本。您应该配置标签流水线在运行发布作业之前[测试组件](#test-the-component)。例如：

   ```yaml
   create-release:
     stage: release
     image: registry.gitlab.com/gitlab-org/cli:latest
     script: echo "Creating release $CI_COMMIT_TAG"
     rules:
       - if: $CI_COMMIT_TAG
     release:
       tag_name: $CI_COMMIT_TAG
       description: "Release $CI_COMMIT_TAG of components in $CI_PROJECT_PATH"
   ```

1. 为版本创建[新标签](../../user/project/repository/tags/_index.md#create-a-tag)，这应该会触发一个标签流水线，其中包含负责创建版本的作业。标签必须使用[语义化版本](#semantic-versioning)。

发布作业成功完成后，版本即被创建，新版本也会发布到 CI/CD catalog。

<a id="semantic-versioning"></a>

#### 语义化版本

在向 Catalog 标记和[发布组件的新版本](#publish-a-new-release)时，您必须使用[语义化版本](https://semver.org)。语义化版本是传达变更是主要、次要、补丁还是其他类型变更的标准。

例如，`1.0.0`、`2.3.4` 和 `1.0.0-alpha` 都是有效的语义化版本。

<a id="unpublish-a-component-project"></a>

### 取消发布组件项目

要从 catalog 中移除组件项目，请在项目设置中关闭 [**CI/CD Catalog 资源**](#set-a-component-project-as-a-catalog-project)开关。

> [!warning]
> 此操作会销毁 catalog 中关于该组件项目及其已发布版本的元数据。项目及其代码仓库仍然存在，但在 catalog 中不可见。

要再次在 catalog 中发布该组件项目，您需要[发布新版本](#publish-a-new-release)。

<a id="verified-component-creators"></a>

### 已验证的组件创建者

一些 CI/CD 组件带有图标徽章，表明该组件由经 GitLab 或实例管理员验证的用户创建和维护：

- GitLab 维护（{{< icon name="tanuki-verified" >}}）：由 GitLab 创建和维护的 JihuLab.com 组件。
- GitLab 合作伙伴（{{< icon name="partner-verified" >}}）：由经 GitLab 验证的合作伙伴独立创建和维护的 JihuLab.com 组件。

  GitLab 合作伙伴可以联系 GitLab 合作伙伴联盟的成员，将其在 JihuLab.com 上的命名空间标记为经 GitLab 验证。之后，位于该命名空间中的任何 CI/CD 组件都会标记为 GitLab 合作伙伴组件。合作伙伴联盟成员会代表已验证的合作伙伴创建[内部请求议题（仅限 GitLab 团队成员）](https://gitlab.com/gitlab-com/support/internal-requests/-/issues/new?description_template=CI%20Catalog%20Badge%20Request)。

  > [!warning]
  > GitLab 合作伙伴创建的组件按“原样”提供，不提供任何形式的保证。最终用户使用 GitLab 合作伙伴创建的组件需自行承担风险，GitLab 对最终用户使用该组件不承担任何赔偿义务，也不承担任何类型的责任。最终用户对此类内容的使用及与之相关的任何责任应由内容发布者与最终用户之间自行解决。

- 已验证创建者（{{< icon name="check-sm" >}}）：由经管理员验证的用户创建和维护的组件。

<a id="set-a-component-as-maintained-by-a-verified-creator"></a>

#### 将组件设置为由已验证创建者维护

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 管理员可以将 CI/CD 组件设置为由已验证创建者创建和维护：

1. 使用管理员账号在实例中打开 GraphiQL，例如：`https://gitlab.example.com/-/graphql-explorer`。
1. 运行以下查询，将 `root-level-group` 替换为要验证的组件的根命名空间：

   ```graphql
   mutation {
     verifiedNamespaceCreate(input: { namespacePath: "root-level-group",
       verificationLevel: VERIFIED_CREATOR_SELF_MANAGED
       }) {
       errors
     }
   }
   ```

查询完成后，根命名空间中项目里的所有组件都会被验证。**已验证创建者** 徽章会显示在 CI/CD catalog 中组件名称旁边。

要从组件上移除徽章，请使用 `UNVERIFIED` 作为 `verificationLevel` 重复该查询。

<a id="convert-a-cicd-template-to-a-component"></a>

## 将 CI/CD 模板转换为组件

您通过 `include:` 语法在项目中使用的任何现有 CI/CD 模板都可以转换为 CI/CD 组件：

1. 决定您希望该组件作为现有[组件项目](#component-project)的一部分与其他组件归为一组，还是[创建新的组件项目](#create-a-component-project)。
1. 根据[目录结构](#directory-structure)在组件项目中创建 YAML 文件。
1. 将原始模板 YAML 文件的内容复制到新的组件 YAML 文件中。
1. 重构新组件的配置以：
   - 遵循[编写组件](#write-a-component)的指南。
   - 改进配置，例如启用[合并请求流水线](../pipelines/merge_request_pipelines.md)或使其[更高效](../pipelines/pipeline_efficiency.md)。
1. 利用组件代码仓库中的 `.gitlab-ci.yml` 来[测试对组件的更改](#test-the-component)。
1. 标记并[发布组件](#publish-a-new-release)。

您可以通过[将 Go CI/CD 模板迁移到 CI/CD 组件](examples.md#cicd-component-migration-example-go)的实践示例了解更多信息。

<a id="use-a-gitlabcom-component-on-gitlab-self-managed"></a>

## 在极狐GitLab 私有化部署上使用 JihuLab.com 组件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

全新安装的极狐GitLab 实例的 CI/CD catalog 初始不包含任何已发布的 CI/CD 组件。要填充您实例的 catalog，您可以：

- [发布您自己的组件](#publish-a-component-project)。
- 在您的极狐GitLab 私有化部署实例中镜像 JihuLab.com 的组件。

要在您的极狐GitLab 私有化部署实例中镜像 JihuLab.com 组件：

1. 确保允许对 `gitlab.com` 的[网络出站请求](../../security/webhooks.md)。
1. [创建群组](../../user/group/_index.md#create-a-group)来承载组件项目（推荐群组：`components`）。
1. 在新群组中[创建组件项目的镜像](../../user/project/repository/mirror/pull.md)。
1. 为组件项目镜像编写[项目描述](../../user/project/working_with_projects.md#edit-a-project)，因为镜像代码仓库不会复制描述。
1. [将自部署组件项目设置为 catalog 资源](#set-a-component-project-as-a-catalog-project)。
1. 通过为标签（通常是最新标签）[运行流水线](../pipelines/_index.md#run-a-pipeline-manually)，在自部署组件项目中发布[新版本](../../user/project/releases/_index.md)。

<a id="cicd-component-security-best-practices"></a>

## CI/CD 组件安全最佳实践

<a id="for-component-users"></a>

### 面向组件使用者

由于任何人都可以向 catalog 发布组件，您应该在项目中使用组件之前仔细审查它们。使用极狐GitLab CI/CD 组件需自行承担风险，极狐GitLab 无法保证第三方组件的安全性。

使用第三方 CI/CD 组件时，请考虑以下安全最佳实践：

- **审计和审查组件源代码**：仔细检查代码，确保其不含恶意内容。
- **最小化对凭据和令牌的访问**：
  - 审计组件的源代码，以确认任何凭据或令牌仅用于执行您预期并授权的操作。
  - 使用作用域最小的访问令牌。
  - 避免使用长期有效的访问令牌或凭据。
  - 审计 CI/CD 组件使用的凭据和令牌。
- **使用固定版本**：将 CI/CD 组件固定到特定的提交 SHA（首选）或版本标签，以确保流水线中使用的组件的完整性。只有在您信任组件维护者时才使用版本标签。避免使用 `latest`。
- **安全存储密钥**：不要将密钥存储在 CI/CD 配置文件中。如果可以使用外部密钥管理解决方案，请避免在项目设置中存储密钥和凭据。
- **使用临时的、隔离的 Runner 环境**：尽可能在临时的、隔离的环境中运行组件作业。注意自管理 Runner 的[安全风险](https://gitlab.cn/docs/runner/security/)。
- **安全处理缓存和产物**：除非绝对必要，否则不要将流水线中其他作业的缓存或产物传递给 CI/CD 组件作业。
- **限制 CI_JOB_TOKEN 访问**：为使用 CI/CD 组件的项目限制 [CI/CD 作业令牌（`CI_JOB_TOKEN`）的项目访问和权限](../jobs/ci_job_token.md#control-job-token-access-to-your-project)。
- **审查 CI/CD 组件变更**：在改用组件的更新提交 SHA 或版本标签之前，仔细审查 CI/CD 组件配置的所有变更。
- **审计自定义容器镜像**：仔细审查 CI/CD 组件使用的任何自定义容器镜像，确保其不含恶意内容。

<a id="for-component-maintainers"></a>

### 面向组件维护者

要维护安全可信的 CI/CD 组件，并确保您交付给用户的流水线配置的完整性，请遵循以下最佳实践：

- **使用双重身份验证（2FA）**：确保所有 CI/CD 组件项目维护者和所有者都已[启用 2FA](../../user/profile/account/two_factor_authentication.md#enable-two-factor-authentication)，或[为群组中的所有用户强制执行 2FA](../../security/two_factor_authentication.md#enforce-2fa-for-all-users-in-a-group)。
- **使用受保护分支**：
  - 为组件项目版本使用[受保护分支](../../user/project/repository/branches/protected.md)。
  - 保护默认分支，并[使用通配符规则](../../user/project/repository/branches/protected.md#use-wildcard-rules)保护所有发布分支。
  - 要求所有人通过合并请求提交对受保护分支的更改。将受保护分支的 **允许推送和合并** 选项设置为 `No one`。
  - 阻止对受保护分支的强制推送。
- **对所有提交签名**：[对组件项目的所有提交进行签名](../../user/project/repository/signed_commits/_index.md)。
- **不鼓励使用 `latest`**：避免在您的 `README.md` 中包含使用 `@latest` 的示例。
- **限制对来自其他作业的缓存和产物的依赖**：仅在绝对必要时才在 CI/CD 组件中使用来自其他作业的缓存和产物。
- **更新 CI/CD 组件依赖项**：定期检查并应用依赖项更新。
- **仔细审查变更**：
  - 在合并到默认或发布分支之前，仔细审查 CI/CD 组件流水线配置的所有变更。
  - 对 CI/CD 组件 catalog 项目的所有面向用户的变更使用[合并请求审批](../../user/project/merge_requests/approvals/_index.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="content-not-found-message"></a>

### `content not found` 消息

当使用 `~latest` 或部分语义化版本限定符引用由 [catalog 项目](#set-a-component-project-as-a-catalog-project)承载的组件时，您可能会收到类似以下内容的错误消息：

```plaintext
This GitLab CI configuration is invalid: Component 'gitlab.com/my-namespace/my-project/my-component@~latest' - content not found
```

`~latest` 限定符指的是 catalog 资源的最新语义化版本。要解决此问题，请[创建新版本](#publish-a-new-release)。

<a id="error-build-component-error-spec-must-be-a-valid-json-schema"></a>

### 错误：`Build component error: Spec must be a valid json schema`

如果组件格式无效，您在创建版本时可能会收到类似 `Build component error: Spec must be a valid json schema` 的错误。

此错误可能是由空的 `spec:inputs` 部分引起的。如果您的配置不使用任何输入，您可以将 `spec` 部分留空。例如：

```yaml
spec:
---

my-component:
  script: echo
```
