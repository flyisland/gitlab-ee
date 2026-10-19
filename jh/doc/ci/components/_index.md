---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 组件
description: 可复用、带版本的 CI/CD 组件，用于流水线。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

CI/CD 组件是可复用的单一流水线配置单元。您可以使用组件来构建更大流水线的一小部分，甚至组合出完整的流水线配置。

组件可以通过[输入参数](../inputs/_index.md)进行配置，以实现更动态的行为。

CI/CD 组件与[使用 `include` 关键字添加的其他配置](../yaml/includes.md)类似，但具有以下优势：

- 组件可以列在 [CI/CD Catalog](#cicd-catalog)中。
- 组件可以发布并使用特定版本。
- 可以在同一项目中定义多个组件，并一起进行版本管理。

除了创建自己的组件，您还可以在 [CI/CD Catalog](#cicd-catalog)中搜索具有您所需功能的已发布组件。

有关常见问题和更多支持，请参阅 [FAQ: GitLab CI/CD Catalog](https://about.gitlab.com/blog/faq-gitlab-ci-cd-catalog/)
博客文章。

<a id="component-project"></a>

## 组件项目

组件项目是一个极狐GitLab 项目，其代码仓库中托管一个或多个组件。项目中的所有组件一起进行版本管理，每个项目最多可包含 100 个组件。

如果某个组件需要与其他组件采用不同的版本管理方式，则应将该组件移至专用的组件项目。

<a id="create-a-component-project"></a>

### 创建组件项目

要创建组件项目，您必须：

1. [创建新项目](../../user/project/_index.md#create-a-blank-project)，并包含一个 `README.md` 文件：
   - 确保描述清晰地介绍该组件。
   - 可选。项目创建后，您可以[添加项目头像](../../user/project/working_with_projects.md#add-a-project-avatar)。

   发布到 [CI/CD catalog](#cicd-catalog)的组件在显示组件项目摘要时会同时使用描述和头像。

1. 按照[所需的目录结构](#directory-structure)为每个组件添加一个 YAML 配置文件。
   例如：

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

您可以立即[使用该组件](#use-a-component)，但您可能需要考虑
将该组件发布到 [CI/CD catalog](#cicd-catalog)。

<a id="directory-structure"></a>

### 目录结构

代码仓库必须包含：

- 一个 `README.md` Markdown 文件，记录代码仓库中所有组件的详细信息。
- 一个顶层 `templates/` 目录，包含所有组件配置。
  在此目录中，您可以：
  - 为每个组件使用以 `.yml` 结尾的单个文件，例如 `templates/secret-detection.yml`。
  - 为每个组件创建包含 `template.yml`的子目录，
    例如 `templates/secret-detection/template.yml`。使用该组件的其他项目只会使用
    `template.yml` 文件。这些目录中的其他文件不会随组件一起发布，
    但可用于测试或构建容器镜像等用途。

组件文件名和子目录名可以包含字母、数字、下划线（`_`）、连字符（`-`）和句点（`.`）。例如，`templates/secret-detection.enterprise.yml` 和 `templates/secret-detection.enterprise/template.yml` 都是有效的组件文件名。

> [!note]
> 可选。每个组件还可以有自己的 `README.md` 文件，提供更详细的信息，并可以从顶层 `README.md` 文件链接过去。这有助于更好地概述您的组件项目及其使用方法。

您还应该：

- 配置项目的 `.gitlab-ci.yml` 以[测试组件](#test-the-component)
  并[发布新版本](#publish-a-new-release)。
- 添加一个 `LICENSE.md` 文件，其中包含您选择的、涵盖组件使用方式的许可证。
  例如 [MIT](https://opensource.org/license/mit) 或 [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0#apply)
  开源许可证。

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
  - `my-other-component` 组件的配置包含目录中的多个文件。
    使用该组件的其他项目只能使用 `template.yml` 文件。

<a id="use-a-component"></a>

## 使用组件

先决条件：

如果您是包含当前群组或项目的父群组的成员：

- 您必须具有项目父群组的可见性级别所设置的最低角色。例如，如果父项目设置为 **Private**，您必须具有报告者、开发者、维护者或所有者角色。

要将组件添加到项目的 CI/CD 配置中，请使用 [`include: component`](../yaml/_index.md#includecomponent) 关键字。组件引用的格式为 `<fully-qualified-domain-name>/<project-path>/<component-name>@<specific-version>`，例如：

```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security-components/secret-detection@1.0.0
    inputs:
      stage: build
```

在此示例中：

- `$CI_SERVER_FQDN` 是一个[预定义变量](../variables/predefined_variables.md)，
  表示与极狐GitLab 主机匹配的完全限定域名（FQDN）。
  您只能引用与您的项目位于同一极狐GitLab 实例中的组件。
- `my-org/security-components` 是包含该组件的项目的完整路径。
- `secret-detection` 是组件名称，定义为单个文件 `templates/secret-detection.yml`
  或包含 `template.yml`的目录 `templates/secret-detection/`。
- `1.0.0` 是该组件的[版本](#component-versions)。

流水线配置和组件配置不会独立处理。当流水线启动时，任何包含的组件配置都会[合并](../yaml/includes.md#merge-method-for-include)到流水线的配置中。如果您的流水线和组件都包含同名的配置，它们可能会以意想不到的方式相互影响。

例如，两个同名的作业会合并为一个作业。同样，如果组件使用 `extends` 引用的配置与您流水线中的某个作业同名，可能会扩展错误的配置。请确保您的流水线和组件不共享任何同名配置，除非您打算[覆盖](../yaml/includes.md#override-included-configuration-values)组件的配置。

要在极狐GitLab 私有化部署实例上使用 JihuLab.com 组件，您必须[镜像该组件项目](#use-a-gitlabcom-component-on-gitlab-self-managed)。

> [!warning]
> 如果组件需要使用令牌、密码或其他敏感数据才能运行，
> 请务必审计组件的源代码，以确认这些数据仅用于
> 执行您预期并授权的操作。您还应使用具有完成该操作所需
> 最低权限、访问权限或范围的令牌和密钥。

<a id="component-versions"></a>

### 组件版本

按优先级从高到低排列，组件版本可以是：

- 提交 SHA，例如 `e3262fdd0914fa823210cdb79a8c421e2cef79d8`。
- 标签，例如：`1.0.0`。如果存在同名的标签和提交 SHA，
  提交 SHA 优先于标签。发布到 CI/CD Catalog 的组件
  必须使用[语义化版本](#semantic-versioning)打标签。
- 分支名称，例如 `main`。如果存在同名的分支和标签，
  标签优先于分支。
- `~latest` 或部分语义化版本，用于选择 CI/CD Catalog 中
  已发布的、符合指定模式的最新版本。仅当您希望始终使用绝对
  最新版本（可能包含破坏性变更）时，才使用 `~latest`。`~latest`
  不包含预发布版本，例如 `1.0.1-rc`，这些版本不被视为
  可用于生产环境。

您可以使用组件支持的任何版本，但建议使用发布到 CI/CD catalog 的版本。通过提交 SHA 或分支名称引用的版本可能未发布在 CI/CD catalog 中，但可用于测试。

<a id="partial-semantic-versions"></a>

#### 部分语义化版本

当您引用 CI/CD catalog 组件时，请使用部分语义化版本号或 `~latest` 来选择符合您指定规格的最新已发布版本。这些格式仅适用于已发布的 CI/CD catalog 组件，不适用于普通项目组件。

这种方法对组件的使用者和作者都有显著好处：

- 对用户而言，使用部分版本是自动接收
  次要或补丁更新的绝佳方式，同时不会面临主要版本带来的破坏性变更风险。这可确保
  您的流水线保持最新的缺陷修复和安全补丁，
  同时保持稳定性。
- 对组件作者而言，部分版本支持允许发布主要版本
  而不会立即破坏现有流水线。指定了
  部分版本的用户会继续使用最新的兼容次要或补丁版本，
  从而有时间按自己的节奏更新流水线。

使用：

- `1.2` 选择最新的 `1.2.*` 版本
- `1` 选择最新的 `1.*.*` 版本
- `~latest` 选择最新的已发布版本

例如，某个组件有以下版本：`1.0.0`、`1.1.0`、`1.1.1`、`1.2.0`、`2.0.0`、`2.0.1`、`2.1.0`

引用该组件时：

- `1` 选择 `1.2.0`
- `1.1` 选择 `1.1.1`
- `~latest` 选择 `2.1.0`

使用部分版本选择时，永远不会获取预发布版本。要获取预发布版本，请指定完整版本，例如 `1.0.1-rc`。

<a id="use-component-context-in-components"></a>

### 在组件中使用组件上下文

组件可以通过组件上下文 [CI/CD 表达式](../yaml/expressions.md)访问自身的元数据。在组件模板中使用此表达式可以动态引用版本、提交 SHA 和其他元数据。

要在组件中使用组件上下文，您必须：

1. 在 [`spec:component`](../yaml/_index.md#speccomponent) 标头中声明该组件需要哪些组件上下文字段。
   `spec:component` 支持 `name`、`sha`、`version` 和 `reference` 字段。
1. 在组件模板中（`spec` 部分之外）使用 CI/CD 表达式 `$[[ component.field-name ]]`
   引用这些上下文字段。

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

组件模板中的 `spec` 部分定义组件的配置和输入。您可以在 `spec` 部分中使用以下关键字：

- [`description`](../yaml/_index.md#specdescription)：提供组件的简短描述，显示在 CI/CD Catalog 中。
- [`inputs`](../yaml/_index.md#specinputs)：定义输入参数，供用户自定义组件配置。
- [`component`](../yaml/_index.md#speccomponent)：声明哪些组件上下文字段可用于插值（如 `name`、`sha`、`version` 和 `reference`）。

> [!note]
> 您不能在组件中使用 [`spec:include`](../yaml/_index.md#specinclude)。
> 组件应自包含，不应依赖外部文件。请直接在组件中定义输入，
> 而不是从单独的文件中引入。

<a id="write-a-component"></a>

## 编写组件

本节介绍一些创建高质量组件项目的最佳实践。

<a id="manage-dependencies"></a>

### 管理依赖项

虽然组件可以依次使用其他组件，但请务必谨慎选择依赖项。要管理依赖项，您应该：

- 将依赖项保持在最低限度。少量重复通常比引入依赖项更好。
- 尽可能依赖本地依赖项。例如，使用 [`include:local`](../yaml/_index.md#includelocal) 是确保
  多个文件使用相同 Git SHA 的好方法。
- 当依赖其他项目的组件时，请将其版本固定到目录中的某个发布版本，而不是使用
  诸如 `~latest` 或 Git 引用之类的移动目标版本。使用发布版本或 Git SHA 可保证您始终
  获取相同的修订版本，并且组件的使用者获得一致的行为。
- 通过将依赖项固定到较新的发布版本来定期更新依赖项。然后发布带有更新
  依赖项的组件新版本。
- 评估依赖项的权限，并使用所需权限最少的依赖项。
  例如，如果您需要构建镜像，请考虑使用 [Buildah](https://buildah.io/) 而不是 Docker，这样您就
  不需要具有特权 Docker 守护进程的 Runner。

<a id="write-a-clear-readmemd"></a>

### 编写清晰的 `README.md`

每个组件项目都应有清晰、全面的文档。要编写好的 `README.md` 文件：

- 以组件所提供能力的摘要开头。
- 如果项目包含多个组件，请使用[目录](../../user/markdown.md#table-of-contents)
  帮助用户快速跳转到特定组件的详细信息。
- 添加一个 `## Components` 部分，并为每个组件添加诸如 `### Component A`的子部分。
- 在每个组件部分中：
  - 描述该组件的作用。
  - 至少添加一个 YAML 示例，展示如何使用它。
  - 使用 [`spec:inputs:description`](../yaml/_index.md#specinputsdescription) 来
    记录组件使用的任何变量或密钥。
  - 不要在 `README`中重复输入文档。输入会自动显示在组件页面上。
    请改为链接到已发布的组件。
- 如果欢迎贡献，请添加一个 `## Contribute` 部分。

如果组件需要更多说明，请在组件目录中的 Markdown 文件中添加额外文档，并从主 `README.md` 文件链接过去。例如：

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

强烈建议将 CI/CD 组件测试作为开发工作流的一部分，这有助于确保行为一致。

在根目录中创建 `.gitlab-ci.yml`，在 CI/CD 流水线中测试变更（与任何其他项目一样）。请务必测试组件的行为和潜在副作用。如有需要，您可以使用[极狐GitLab API](../../api/rest/_index.md)。

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

提交并推送变更后，流水线会测试该组件，如果前面的作业通过，则创建一个发布版本。

> [!note]
> 如果项目是私有的，则必须进行身份验证。

<a id="test-a-component-against-sample-files"></a>

#### 使用示例文件测试组件

在某些情况下，组件需要与之交互的源文件。例如，构建 Go 源代码的组件可能需要一些 Go 示例来进行测试。或者，构建 Docker 镜像的组件可能需要一些示例 Dockerfile 来进行测试。

您可以直接在组件项目中包含此类示例文件，供组件测试期间使用。

您可以在[测试组件的示例](examples.md#test-a-component)中了解更多信息。

<a id="avoid-hard-coding-instance-or-project-specific-values"></a>

### 避免硬编码实例或项目特定的值

在组件中[使用另一个组件](#use-a-component)时，请使用 `$CI_SERVER_FQDN` 而不是您实例的完全限定域名（如 `gitlab.com`）。

在组件中访问极狐GitLab API 时，请使用 `$CI_API_V4_URL` 而不是您实例的完整 URL 和路径（如 `https://gitlab.com/api/v4`）。

这些[预定义变量](../variables/predefined_variables.md)可确保您的组件在其他实例上使用时也能正常工作。例如，您可能[在极狐GitLab 私有化部署实例上使用 JihuLab.com 组件](#use-a-gitlabcom-component-on-gitlab-self-managed)。

<a id="do-not-assume-api-resources-are-always-public"></a>

### 不要假设 API 资源始终是公开的

确保组件及其测试流水线也能[在极狐GitLab 私有化部署上](#use-a-gitlabcom-component-on-gitlab-self-managed)正常工作。JihuLab.com 上公开项目的某些 API 资源可以通过未经身份验证的请求访问。但是，在极狐GitLab 私有化部署实例上，组件项目可能被镜像为私有或内部项目。

重要的是，可以通过输入或变量选择性地提供访问令牌，以便在极狐GitLab 私有化部署实例上对请求进行身份验证。

<a id="avoid-using-global-keywords"></a>

### 避免使用全局关键字

避免在组件中使用[全局关键字](../yaml/_index.md#global-keywords)。在组件中使用这些关键字会影响流水线中的所有作业，包括直接定义在主 `.gitlab-ci.yml` 或其他包含的组件中的作业。

作为全局关键字的替代方案：

- 将配置直接添加到每个作业，即使这会在组件配置中
  造成一些重复。
- 在组件中使用 [`extends`](../yaml/_index.md#extends) 关键字，但使用
  唯一的名称，以降低组件合并到配置中时发生命名冲突的风险。

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

您可以改为：

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

避免在 CI/CD 组件中使用硬编码值。硬编码值可能会迫使组件用户需要查看组件的内部细节，并调整他们的流水线以配合该组件。

一个常见的有问题的硬编码值关键字是 `stage`。如果组件作业的阶段是硬编码的，则所有使用该组件的流水线都必须定义完全相同的阶段，或者[覆盖](../yaml/includes.md#override-included-configuration-values)该配置。

首选方法是使用 [`input` 关键字](../inputs/_index.md)来实现动态组件配置。组件用户可以指定他们所需的确切值。

例如，要创建一个带有可由用户定义的 `stage` 配置的组件：

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

与 `stage` 关键字的值类似，您应避免在 CI/CD 组件中硬编码作业名称。当组件的用户可以自定义作业名称时，他们可以防止与其流水线中现有名称的冲突。用户还可以通过使用不同的名称，多次包含具有不同输入选项的同一组件。

使用 `inputs` 允许组件的用户定义特定的作业名称，或作业名称的前缀。例如：

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

在组件中使用 CI/CD 变量时，请评估是否应改用 `inputs` 关键字。当 `inputs` 是更好的解决方案时，避免要求用户定义自定义变量来配置组件。

输入在组件的 `spec` 部分中显式定义，并且比变量具有更好的验证。例如，如果未向组件传递必需的输入，极狐GitLab 会返回流水线错误。相比之下，如果未定义变量，其值为空，且不会报错。

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

- 使用[预定义变量](../variables/predefined_variables.md)自动配置
  组件以匹配用户的项目。
- 要求用户将敏感值存储为[项目设置中已屏蔽或受保护的 CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-ui)。

<a id="cicd-catalog"></a>

## CI/CD Catalog

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[CI/CD Catalog](https://gitlab.com/explore/catalog) 是一个包含已发布 CI/CD 组件的项目列表，您可以使用它们来扩展您的 CI/CD 工作流。

任何人都可以[创建组件项目](#create-a-component-project)并将其添加到 CI/CD Catalog，或为现有项目做出贡献以改进可用的组件。

有关点击式演示，请参阅 [CI/CD Catalog 测试版产品导览](https://gitlab.navattic.com/cicd-catalog)。
<!-- Demo published on 2024-01-24 -->

<a id="view-the-cicd-catalog"></a>

### 查看 CI/CD Catalog

要访问 CI/CD Catalog 并查看可供您使用的已发布组件：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 选择**探索**。
1. 选择 **CI/CD Catalog**。

或者，如果您已经在项目的[流水线编辑器](../pipeline_editor/_index.md)中，
可以选择 **CI/CD Catalog**。

CI/CD catalog 中组件的可见性遵循组件源项目的[可见性设置](../../user/public_access.md)。源项目设置为以下内容的组件：

- 私有：仅对在源组件项目中分配了访客、计划者、报告者、开发者、维护者或所有者角色的用户可见。要使用组件，您必须具有报告者、开发者、维护者或所有者角色。
- 内部：仅对登录到极狐GitLab 实例的用户可见。
- 公开：对任何有权访问极狐GitLab 实例的人可见。

列表中的每个 CI/CD Catalog 项目都会显示一个使用次数。此计数表示在过去 30 天内，在流水线中使用过该目录项目中任何组件的唯一项目总数。

<a id="view-cicd-catalog-project-analytics"></a>

### 查看 CI/CD Catalog 项目分析

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您维护 CI/CD catalog 资源，可以查看使用分析，以了解您的组件在各项目中的采用情况。

先决条件：

- 您必须对一个或多个目录资源项目具有维护者或所有者角色。

要查看目录资源分析：

1. 在顶部栏中，选择**搜索或跳转到** > **探索**。
1. 选择 **CI/CD Catalog**。
1. 选择**分析**标签页。

分析视图会显示您具有维护者或所有者角色的目录资源。此视图显示：

- **项目**：目录资源名称及其最新发布的版本。
- **使用统计**：在过去 30 天内，在流水线中使用过此目录资源中某个组件的唯一项目数量。
- **组件**：目录资源最新版本中可用的组件列表。

例如：

![目录资源分析页面，显示 3 个组件及其使用次数。](img/catalog_analytics_v18_10.png)

您可以使用这些信息来：

- 确定哪些目录资源被最广泛地采用。
- 跟踪您的组件随时间的使用趋势。
- 了解哪些项目正在使用您的目录资源。
- 就组件维护和弃用做出明智的决策。

<a id="view-component-usage-details"></a>

### 查看组件使用详情

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您维护 CI/CD catalog 组件项目，可以查看详细的组件使用信息，以了解哪些项目使用了这些组件以及使用了哪些版本。这有助于您规划升级、传达弃用信息，并识别使用过时版本的项目。

详情页面还会在每个组件名称旁显示一个使用次数。此计数特定于版本，显示在过去 30 天内使用过该组件版本的唯一项目数量。

先决条件：

- 您必须对目录资源项目具有维护者或所有者角色。

要查看组件使用详情：

1. 在顶部栏中，选择**搜索或跳转到** > **探索**。
1. 选择 **CI/CD Catalog**。
1. 从目录中选择一个组件项目。
1. 在详情页面上，选择**使用情况**标签页。

此标签页列出了在过去 30 天内，在流水线中包含过此项目任何组件的项目。该列表仅包含您有权查看的项目。

详情包括：

- **项目路径**：项目的完整路径，并带有指向该项目的链接。
- **状态**：如果项目使用了组件的最新版本，则标记为**最新**。否则为**已过时**。
- **使用的组件**：项目使用的组件名称和版本。

您无法看到的项目会显示为**私有项目**，且不带链接。

您可以使用这些信息来：

- 识别使用过时组件版本并需要升级的项目。
- 在有新版本可用或弃用组件时通知项目维护者。
- 了解特定组件版本在您组织中的采用情况。

<a id="publish-a-component-project"></a>

### 发布组件项目

要将组件项目发布到 CI/CD catalog 中，您必须：

1. 将项目设置为目录项目。
1. 发布新版本。

<a id="set-a-component-project-as-a-catalog-project"></a>

#### 将组件项目设置为目录项目

要使组件项目的已发布版本在 CI/CD catalog 中可见，您必须将该项目设置为目录项目。

先决条件：

- 您必须对项目具有所有者角色。

要将项目设置为目录项目：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 打开 **CI/CD Catalog 项目**开关。

只有在您发布新版本后，该项目才能在目录中被找到。

要使用自动化启用此设置，您可以使用 [`mutationcatalogresourcescreate`](../../api/graphql/reference/_index.md#mutationcatalogresourcescreate)
GraphQL 端点。[议题 463043](https://gitlab.com/gitlab-org/gitlab/-/issues/463043)
提议也在 REST API 中公开此功能。

<a id="publish-a-new-release"></a>

#### 发布新版本

CI/CD 组件无需列在 CI/CD catalog 中即可[使用](#use-a-component)。
但是，在目录中发布组件的版本可以让其他用户发现它。

先决条件：

- 您必须对项目具有维护者或所有者角色。
- 项目必须：
  - 设置为[目录项目](#set-a-component-project-as-a-catalog-project)。
  - 定义了[项目描述](../../user/project/working_with_projects.md#edit-a-project)。
  - 在正在发布的标签的提交 SHA 的根目录中有一个 `README.md` 文件。
  - 在正在发布的标签的提交 SHA 的 [`templates/` 目录中至少有一个 CI/CD 组件](#directory-structure)。
- 您必须在 CI/CD 作业中使用 [`release` 关键字](../yaml/_index.md#release)来创建发布版本，
  而不是使用 [Releases API](../../api/releases/_index.md#create-a-release)。

要将组件的新版本发布到目录：

1. 在项目的 `.gitlab-ci.yml` 文件中添加一个作业，使用 `release`
   关键字在创建标签时创建新版本。
   您应配置标签流水线，以便在运行发布作业之前[测试组件](#test-the-component)。例如：

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

1. 为发布版本创建[新标签](../../user/project/repository/tags/_index.md#create-a-tag)，
   这应触发包含负责创建发布版本的作业的标签流水线。
   标签必须使用[语义化版本](#semantic-versioning)。

发布作业成功完成后，发布版本即创建，新版本
会发布到 CI/CD catalog。

<a id="semantic-versioning"></a>

#### 语义化版本

在将组件的新版本打标签并[发布](#publish-a-new-release)到目录时，您必须使用[语义化版本](https://semver.org)。语义化版本是传达变更属于主要、次要、补丁或其他类型变更的标准。

例如，`1.0.0`、`2.3.4` 和 `1.0.0-alpha` 都是有效的语义化版本。

<a id="unpublish-a-component-project"></a>

### 取消发布组件项目

要将组件项目从目录中移除，请在项目设置中关闭 [**CI/CD Catalog 资源**](#set-a-component-project-as-a-catalog-project)开关。

> [!warning]
> 此操作会销毁有关该组件项目及其在目录中发布的版本的元数据。
> 项目及其代码仓库仍然存在，但在目录中不可见。

要再次将组件项目发布到目录中，您需要[发布新版本](#publish-a-new-release)。

<a id="verified-component-creators"></a>

### 已验证的组件创建者

某些 CI/CD 组件会显示一个已验证图标。该图标表示该组件由经 GitLab 或实例管理员验证的用户创建并维护：

- GitLab 维护（{{< icon name="tanuki-verified" >}}）：由 GitLab 创建和维护的 JihuLab.com 组件。
- GitLab 合作伙伴（{{< icon name="partner-verified" >}}）：由经 GitLab 验证的合作伙伴独立创建
  和维护的 JihuLab.com 组件。

  GitLab 合作伙伴可以联系 GitLab Partner Alliance 的成员，将其在 JihuLab.com 上的
  命名空间标记为经 GitLab 验证。然后，该命名空间中的
  任何 CI/CD 组件都会被标记为 GitLab 合作伙伴组件。Partner Alliance 成员
  代表已验证的合作伙伴创建[内部请求议题（仅限 GitLab 团队成员）](https://gitlab.com/gitlab-com/support/internal-requests/-/issues/new?description_template=CI%20Catalog%20Badge%20Request)。

  > [!warning]
  > GitLab 合作伙伴创建的组件按**原样**提供，不附带任何形式的保证。
  > 最终用户使用 GitLab 合作伙伴创建的组件需自行承担风险，
  > 对于最终用户使用该组件，GitLab 不承担任何赔偿义务，也不承担任何类型的责任。
  > 最终用户对此类内容的使用及任何相关责任应由内容发布者与最终用户之间承担。

- 已验证创建者（{{< icon name="check-sm" >}}）：由管理员验证的
  用户创建和维护的组件。

<a id="set-a-component-as-maintained-by-a-verified-creator"></a>

#### 将组件设置为由已验证创建者维护

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 管理员可以将 CI/CD 组件设置为由已验证创建者创建和维护：

1. 使用您的管理员账号在实例中打开 GraphiQL，例如：`https://gitlab.example.com/-/graphql-explorer`。
1. 运行此查询，将 `root-level-group` 替换为要验证的组件的根命名空间：

   ```graphql
   mutation {
     verifiedNamespaceCreate(input: { namespacePath: "root-level-group",
       verificationLevel: VERIFIED_CREATOR_SELF_MANAGED
       }) {
       errors
     }
   }
   ```

查询完成后，根命名空间中项目里的所有组件都会被验证。**已验证创建者**徽章会显示在 CI/CD catalog 中的组件名称旁边。

要从组件中移除该徽章，请使用 `verificationLevel`的 `UNVERIFIED` 重新运行该查询。

<a id="convert-a-cicd-template-to-a-component"></a>

## 将 CI/CD 模板转换为组件

任何您通过 `include:` 语法在项目中使用的现有 CI/CD 模板都可以转换为 CI/CD 组件：

1. 决定您希望该组件作为现有[组件项目](#component-project)的一部分与其他组件分组，
   还是[创建新的组件项目](#create-a-component-project)。
1. 按照[目录结构](#directory-structure)在组件项目中创建 YAML 文件。
1. 将原始模板 YAML 文件的内容复制到新的组件 YAML 文件中。
1. 重构新组件的配置，以：
   - 遵循[编写组件](#write-a-component)的指导。
   - 改进配置，例如通过启用[合并请求流水线](../pipelines/merge_request_pipelines.md)
     或使其[更高效](../pipelines/pipeline_efficiency.md)。
1. 利用组件代码仓库中的 `.gitlab-ci.yml` 来[测试对组件的变更](#test-the-component)。
1. 打标签并[发布组件](#publish-a-new-release)。

您可以按照[将 Go CI/CD 模板迁移到 CI/CD 组件](examples.md#cicd-component-migration-example-go)的实用示例了解更多信息。

<a id="use-a-gitlabcom-component-on-gitlab-self-managed"></a>

## 在极狐GitLab 私有化部署上使用 JihuLab.com 组件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

全新安装的极狐GitLab 实例的 CI/CD catalog 初始没有任何已发布的 CI/CD 组件。要填充实例的目录，您可以：

- [发布您自己的组件](#publish-a-component-project)。
- 在您的极狐GitLab 私有化部署实例中镜像来自 JihuLab.com 的组件。

要在您的极狐GitLab 私有化部署实例中镜像 JihuLab.com 组件：

1. 确保允许对 `gitlab.com` 进行[网络出站请求](../../security/webhooks.md)。
1. [创建群组](../../user/group/_index.md#create-a-group)来托管组件项目（推荐的群组：`components`）。
1. 在新群组中[创建组件项目的镜像](../../user/project/repository/mirror/pull.md)。
1. 为组件项目镜像编写[项目描述](../../user/project/working_with_projects.md#edit-a-project)，
   因为镜像代码仓库不会复制描述。
1. [将私有化部署的组件项目设置为目录资源](#set-a-component-project-as-a-catalog-project)。
1. 通过为标签（通常是最新标签）[运行流水线](../pipelines/_index.md#run-a-pipeline-manually)，
   在私有化部署的组件项目中发布[新版本](../../user/project/releases/_index.md)。

<a id="cicd-component-security-best-practices"></a>

## CI/CD 组件安全最佳实践

<a id="for-component-users"></a>

### 对于组件用户

由于任何人都可以将组件发布到目录，因此在项目中使用组件之前，您应仔细审查它们。使用极狐GitLab CI/CD 组件的风险由您自行承担，极狐GitLab 无法保证第三方组件的安全性。

使用第三方 CI/CD 组件时，请考虑以下安全最佳实践：

- **审计并审查组件源代码**：仔细检查代码，确保其不包含恶意内容。
- **尽量减少对凭据和令牌的访问**：
  - 审计组件的源代码，以确认任何凭据或令牌仅用于
    执行您预期并授权的操作。
  - 使用范围最小的访问令牌。
  - 避免使用长期有效的访问令牌或凭据。
  - 审计 CI/CD 组件使用的凭据和令牌。
- **使用固定版本**：将 CI/CD 组件固定到特定的提交 SHA（首选）
  或发布版本标签，以确保流水线中使用的组件的完整性。
  仅在您信任组件维护者时才使用发布标签。避免使用 `latest`。
- **安全地存储密钥**：不要在 CI/CD 配置文件中存储密钥。
  如果您可以使用外部密钥管理解决方案，请避免在项目设置中存储密钥和凭据。
- **使用临时、隔离的 Runner 环境**：尽可能在临时、
  隔离的环境中运行组件作业。请注意自管理 Runner 的[安全风险](https://gitlab.cn/docs/runner/security/)。
- **安全地处理缓存和产物**：除非绝对必要，否则不要将流水线中其他作业的
  缓存或产物传递给 CI/CD 组件作业。
- **限制 CI_JOB_TOKEN 访问**：为使用 CI/CD 组件的项目限制 [CI/CD 作业令牌（`CI_JOB_TOKEN`）的项目访问和权限](../jobs/ci_job_token.md#control-job-token-access-to-your-project)。
- **审查 CI/CD 组件变更**：在更改为使用组件的更新提交 SHA 或发布标签之前，
  仔细审查对 CI/CD 组件配置的所有变更。
- **审计自定义容器镜像**：仔细审查 CI/CD 组件使用的任何自定义容器镜像，
  以确保它们不包含恶意内容。

<a id="for-component-maintainers"></a>

### 对于组件维护者

要维护安全可信的 CI/CD 组件，并确保您交付给用户的流水线配置的完整性，请遵循以下最佳实践：

- **使用双重身份验证（2FA）**：确保所有 CI/CD 组件项目的维护者
  和所有者都[启用了 2FA](../../user/profile/account/two_factor_authentication.md#enable-two-factor-authentication)，
  或[对群组中的所有用户强制实施 2FA](../../security/two_factor_authentication.md#enforce-2fa-for-all-users-in-a-group)。
- **使用受保护分支**：
  - 为组件项目发布使用[受保护分支](../../user/project/repository/branches/protected.md)。
  - 保护默认分支，并[使用通配符规则](../../user/project/repository/branches/protected.md#use-wildcard-rules)保护所有发布分支。
  - 要求所有人对受保护分支的变更提交合并请求。将受保护分支的
    **允许推送和合并**选项设置为 `No one`。
  - 阻止对受保护分支的强制推送。
- **签署所有提交**：[签署](../../user/project/repository/signed_commits/_index.md)对组件项目的所有提交。
- **不鼓励使用 `latest`**：避免在 `README.md`中包含使用 `@latest`的示例。
- **限制对其他作业缓存和产物的依赖**：仅在绝对必要时，才在 CI/CD 组件中使用
  其他作业的缓存和产物
- **更新 CI/CD 组件依赖项**：定期检查并应用依赖项的更新。
- **仔细审查变更**：
  - 在合并到默认分支或发布分支之前，仔细审查对 CI/CD 组件流水线配置的
    所有变更。
  - 对 CI/CD 组件目录项目的所有面向用户的变更使用[合并请求审批](../../user/project/merge_requests/approvals/_index.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="content-not-found-message"></a>

### `content not found` 消息

如果您使用 `~latest` 或部分语义版本限定符来引用由[目录项目](#set-a-component-project-as-a-catalog-project)托管的组件，可能会看到此错误：

```plaintext
This GitLab CI configuration is invalid: Component 'gitlab.com/my-namespace/my-project/my-component@~latest' - content not found
```

`~latest` 限定符指的是目录资源的最新语义化版本。要解决此问题，请[创建新版本](#publish-a-new-release)。

<a id="error-build-component-error-spec-must-be-a-valid-json-schema"></a>

### 错误：`Build component error: Spec must be a valid json schema`

如果组件的格式无效，您在创建发布版本时可能会收到类似 `Build component error: Spec must be a valid json schema`的错误。

此错误可能由空的 `spec:inputs` 部分引起。如果您的配置不使用任何输入，可以将 `spec` 部分留空。例如：

```yaml
spec:
---

my-component:
  script: echo
```
