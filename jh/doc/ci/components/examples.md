---
stage: Verify
group: Pipeline Authoring
info: This page is maintained by Developer Relations, author @dnsmichi, see <https://handbook.gitlab.com/handbook/marketing/developer-relations/developer-advocacy/content/#maintained-documentation>
title: CI/CD 组件示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="test-a-component"></a>

## 测试组件

根据组件的功能，[测试组件](_index.md#test-the-component)可能需要在代码仓库中添加其他文件。例如，一个用于对特定编程语言编写的软件进行代码检查、构建和测试的组件，需要实际的源代码示例。您可以在同一个代码仓库中放置源代码示例、配置文件及类似内容。

例如，代码质量 CI/CD 组件包含若干[用于测试的代码示例](https://gitlab.com/components/code-quality/-/tree/main/src)。

<a id="example-test-a-rust-language-cicd-component"></a>

### 示例：测试 Rust 语言 CI/CD 组件

根据组件的功能，[测试组件](_index.md#test-the-component)可能需要在代码仓库中添加其他文件。

以下针对 Rust 编程语言的“hello world”示例为简单起见使用了 `cargo` 工具链：

1. 进入 CI/CD 组件的根目录。
1. 使用 `cargo init` 命令初始化一个新的 Rust 项目。

   ```shell
   cargo init
   ```

   该命令会创建所有必需的项目文件，包括一个 `src/main.rs`“hello world”示例。
   此步骤足以在组件作业中使用 `cargo build` 构建 Rust 源代码。

   ```plaintext
   tree
   .
   ├── Cargo.toml
   ├── LICENSE.md
   ├── README.md
   ├── src
   │   └── main.rs
   └── templates
       └── build.yml
   ```

1. 确保该组件有一个用于构建 Rust 源代码的作业，例如，
   在 `templates/build.yml`中：

   ```yaml
   spec:
     inputs:
       stage:
         default: build
         description: 'Defines the build stage'
       rust_version:
         default: latest
         description: 'Specify the Rust version, use values from https://hub.docker.com/_/rust/tags Defaults to latest'
   ---

   "build-$[[ inputs.rust_version ]]":
     stage: $[[ inputs.stage ]]
     image: rust:$[[ inputs.rust_version ]]
     script:
       - cargo build --verbose
   ```

   在此示例中：

   - `stage` 和 `rust_version` 输入可以从其默认值进行修改。
     CI/CD 作业以 `build-` 前缀开头，并根据 `rust_version` 输入动态创建名称。
     命令 `cargo build --verbose` 会编译 Rust 源代码。

1. 在项目的 `.gitlab-ci.yml` 配置文件中测试组件的 `build` 模板：

   ```yaml
   include:
     # include the component located in the current project from the current SHA
     - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
       inputs:
         stage: build

   stages: [build, test, release]
   ```

1. 如需运行测试及更多内容，请向 Rust 代码中添加其他函数和测试，
   并在 `templates/test.yml`中添加一个运行 `cargo test`的组件模板和作业。

   ```yaml
   spec:
     inputs:
       stage:
         default: test
         description: 'Defines the test stage'
       rust_version:
         default: latest
         description: 'Specify the Rust version, use values from https://hub.docker.com/_/rust/tags Defaults to latest'
   ---

   "test-$[[ inputs.rust_version ]]":
     stage: $[[ inputs.stage ]]
     image: rust:$[[ inputs.rust_version ]]
     script:
       - cargo test --verbose
   ```

1. 通过包含 `test` 组件模板，在流水线中测试该附加作业：

   ```yaml
   include:
     # include the component located in the current project from the current SHA
     - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
       inputs:
         stage: build
     - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/test@$CI_COMMIT_SHA
       inputs:
         stage: test

   stages: [build, test, release]
   ```

<a id="cicd-component-patterns"></a>

## CI/CD 组件模式

本节提供在 CI/CD 组件中实现常见模式的实用示例。

<a id="use-boolean-inputs-to-conditionally-configure-jobs"></a>

### 使用布尔输入有条件地配置作业

您可以通过组合 `boolean` 类型输入和 [`extends`](../yaml/_index.md#extends) 功能，使用两个条件来组合作业。

例如，要使用 `boolean` 输入配置复杂的缓存行为：

```yaml
spec:
  inputs:
    enable_special_caching:
      description: 'If set to `true` configures a complex caching behavior'
      type: boolean
---

.my-component:enable_special_caching:false:
  extends: null

.my-component:enable_special_caching:true:
  cache:
    policy: pull-push
    key: $CI_COMMIT_SHA
    paths: [...]

my-job:
  extends: '.my-component:enable_special_caching:$[[ inputs.enable_special_caching ]]'
  script: ... # run some fancy tooling
```

此模式的工作原理是将 `enable_special_caching` 输入传递给作业的 `extends` 关键字。根据 `enable_special_caching` 是 `true` 还是 `false`，从预定义的隐藏作业（`.my-component:enable_special_caching:true` 或 `.my-component:enable_special_caching:false`）中选择相应的配置。

<a id="use-options-to-conditionally-configure-jobs"></a>

### 使用 `options` 有条件地配置作业

您可以使用多个选项来组合作业，以实现类似于 `if` 和 `elseif` 条件的行为。将 [`extends`](../yaml/_index.md#extends) 与 `string` 类型以及多个 `options` 结合使用，可支持任意数量的条件。

例如，要使用 3 个不同选项配置复杂的缓存行为：

```yaml
spec:
  inputs:
    cache_mode:
      description: Defines the caching mode to use for this component
      type: string
      options:
        - default
        - aggressive
        - relaxed
---

.my-component:cache_mode:default:
  extends: null

.my-component:cache_mode:aggressive:
  cache:
    policy: push
    key: $CI_COMMIT_SHA
    paths: ['*/**']

.my-component:cache_mode:relaxed:
  cache:
    policy: pull-push
    key: $CI_COMMIT_BRANCH
    paths: ['bin/*']

my-job:
  extends: '.my-component:cache_mode:$[[ inputs.cache_mode ]]'
  script: ... # run some fancy tooling
```

在此示例中，`cache_mode` 输入提供 `default`、`aggressive` 和 `relaxed` 选项，每个选项对应一个不同的隐藏作业。通过使用 `extends: '.my-component:cache_mode:$[[ inputs.cache_mode ]]'` 扩展组件作业，该作业会根据所选选项动态继承正确的缓存配置。

<a id="use-component-context-to-reference-versioned-resources"></a>

### 使用组件上下文引用带版本的资源

使用组件上下文 [CI/CD 表达式](../yaml/expressions.md)引用组件元数据，例如版本和提交 SHA。一个用例是使用您的组件构建并发布带版本的资源（如 Docker 镜像），并确保组件使用匹配的版本。

例如，您可以：

- 在组件的发布流水线中构建一个 Docker 镜像，其标签与组件版本匹配。
- 让组件引用同一镜像版本。

在组件项目的发布流水线（`.gitlab-ci.yml`）中：

```yaml
build-image:
  stage: build
  image: docker:latest
  script:
    - docker build -t $CI_REGISTRY_IMAGE/my-tool:$CI_COMMIT_TAG .
    - docker push $CI_REGISTRY_IMAGE/my-tool:$CI_COMMIT_TAG

create-release:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  script: echo "Creating release $CI_COMMIT_TAG"
  rules:
    - if: $CI_COMMIT_TAG
  release:
    tag_name: $CI_COMMIT_TAG
    description: "Release $CI_COMMIT_TAG"
```

在组件模板（`templates/my-component/template.yml`）中：

```yaml
spec:
  component: [version, reference]
  inputs:
    stage:
      default: test
---

run-tool:
  stage: $[[ inputs.stage ]]
  image: $CI_REGISTRY_IMAGE/my-tool:$[[ component.version ]]
  script:
    - echo "Running tool version $[[ component.version ]]"
    - echo "Component was included using reference: $[[ component.reference ]]"
    - my-tool --version
```

在此示例中：

- 如果您使用 `@1.0.0` 包含该组件，作业将使用镜像 `my-tool:1.0.0`。
- 如果您使用 `@1.0` 包含它，它会解析为最新的 `1.0.x` 版本，例如 `1.0.3`，
  因此使用 `my-tool:1.0.3`。
- 如果您使用 `@~latest` 包含它，它会使用最新发布的版本。
- `component.reference` 字段显示您指定的确切引用，例如 `1.0`、`~latest` 或 SHA。
  您可以将该引用用于日志记录或调试。

<a id="cicd-component-migration-examples"></a>

## CI/CD 组件迁移示例

本节展示将 CI/CD 模板和流水线配置迁移为可复用 CI/CD 组件的实用示例。

<a id="cicd-component-migration-example-go"></a>

### CI/CD 组件迁移示例：Go

软件开发生命周期的完整流水线可以由多个作业和阶段组成。针对编程语言的 CI/CD 模板可能会在单个模板文件中提供多个作业。作为实践，应迁移以下 Go CI/CD 模板。

```yaml
default:
  image: golang:latest

stages:
  - test
  - build
  - deploy

format:
  stage: test
  script:
    - go fmt $(go list ./... | grep -v /vendor/)
    - go vet $(go list ./... | grep -v /vendor/)
    - go test -race $(go list ./... | grep -v /vendor/)

compile:
  stage: build
  script:
    - mkdir -p mybinaries
    - go build -o mybinaries ./...
  artifacts:
    paths:
      - mybinaries
```

> [!note]
> 如需采用更渐进的方式，可以一次迁移一个作业。
> 从 `build` 作业开始，然后对 `format` 和 `test` 作业重复这些步骤。

CI/CD 模板迁移涉及以下步骤：

1. 分析 CI/CD 作业和依赖关系，并定义迁移操作：
   - `image` 配置是全局的，[需要移入作业定义中](_index.md#avoid-using-global-keywords)。
   - `format` 作业在一个作业中运行多个 `go` 命令。应将 `go test` 命令
     移入单独的作业，以提高流水线效率。
   - `compile` 作业运行 `go build`，应重命名为 `build`。
1. 定义优化策略，以提高流水线效率。
   - `stage` 作业属性应可配置，以支持不同的 CI/CD 流水线使用方。
   - `image` 键使用了硬编码的镜像标签 `latest`。添加 [`golang_version` 作为输入](../inputs/_index.md)，
     并将 `latest` 作为默认值，以实现更灵活、更可复用的流水线。该输入必须与
     Docker Hub 镜像标签值匹配。
   - `compile` 作业将二进制文件构建到硬编码的目标目录 `mybinaries`，
     可以通过动态[输入](../inputs/_index.md)和默认值 `mybinaries` 来增强。
1. 为新组件创建模板[目录结构](_index.md#directory-structure)，
   基于每个作业一个模板。

   - 模板的名称应遵循 `go` 命令，例如 `format.yml`、`build.yml` 和 `test.yml`。
   - 创建一个新项目，初始化 Git 代码仓库，添加/提交所有更改，设置远程源，然后推送。
     请修改 URL 以匹配您的 CI/CD 组件项目路径。
   - 按照[编写组件](_index.md#write-a-component)指南创建其他文件：
     `README.md`、`LICENSE.md`、`.gitlab-ci.yml`、`.gitignore`。以下 shell 命令
     会初始化 Go 组件结构：

   ```shell
   git init

   mkdir templates
   touch templates/{format,build,test}.yml

   touch README.md LICENSE.md .gitlab-ci.yml .gitignore

   git add -A
   git commit -avm "Initial component structure"

   git remote add origin https://gitlab.example.com/components/golang.git

   git push
   ```

1. 将 CI/CD 作业创建为模板。从 `build` 作业开始。
   - 在 `spec` 部分定义以下输入：`stage`、`golang_version` 和 `binary_directory`。
   - 添加动态作业名称定义，访问 `inputs.golang_version`。
   - 对动态 Go 镜像版本使用类似的模式，访问 `inputs.golang_version`。
   - 将阶段赋值为 `inputs.stage`的值。
   - 从 `inputs.binary_directory` 创建二进制目录，并将其作为参数添加到 `go build`。
   - 将产物路径定义为 `inputs.binary_directory`。

     ```yaml
     spec:
       inputs:
         stage:
           default: 'build'
           description: 'Defines the build stage'
         golang_version:
           default: 'latest'
           description: 'Go image version tag'
         binary_directory:
           default: 'mybinaries'
           description: 'Output directory for created binary artifacts'
     ---

     "build-$[[ inputs.golang_version ]]":
       image: golang:$[[ inputs.golang_version ]]
       stage: $[[ inputs.stage ]]
       script:
         - mkdir -p $[[ inputs.binary_directory ]]
         - go build -o $[[ inputs.binary_directory ]] ./...
       artifacts:
         paths:
           - $[[ inputs.binary_directory ]]
     ```

   - `format` 作业模板遵循相同的模式，但只需要 `stage` 和 `golang_version` 输入。

     ```yaml
     spec:
       inputs:
         stage:
           default: 'format'
           description: 'Defines the format stage'
         golang_version:
           default: 'latest'
           description: 'Golang image version tag'
     ---

     "format-$[[ inputs.golang_version ]]":
       image: golang:$[[ inputs.golang_version ]]
       stage: $[[ inputs.stage ]]
       script:
         - go fmt $(go list ./... | grep -v /vendor/)
         - go vet $(go list ./... | grep -v /vendor/)
     ```

   - `test` 作业模板遵循相同的模式，但只需要 `stage` 和 `golang_version` 输入。

     ```yaml
     spec:
       inputs:
         stage:
           default: 'test'
           description: 'Defines the format stage'
         golang_version:
           default: 'latest'
           description: 'Golang image version tag'
     ---

     "test-$[[ inputs.golang_version ]]":
       image: golang:$[[ inputs.golang_version ]]
       stage: $[[ inputs.stage ]]
       script:
         - go test -race $(go list ./... | grep -v /vendor/)
     ```

1. 要测试该组件，请修改 `.gitlab-ci.yml` 配置文件，
   并添加[测试](_index.md#test-the-component)。

   - 为 `build` 作业的 `golang_version` 输入指定不同的值。
   - 请修改 URL 以匹配您的 CI/CD 组件路径。

     ```yaml
     stages: [format, build, test]

     include:
       - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/format@$CI_COMMIT_SHA
       - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
       - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
         inputs:
           golang_version: "1.21"
       - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/test@$CI_COMMIT_SHA
         inputs:
           golang_version: latest
     ```

1. 添加 Go 源代码以测试该 CI/CD 组件。`go` 命令要求 Go 项目
   在根目录中包含 `go.mod` 和 `main.go`。

   - 初始化 Go 模块。请修改 URL 以匹配您的 CI/CD 组件路径。

     ```shell
     go mod init example.gitlab.com/components/golang
     ```

   - 创建一个包含 main 函数的 `main.go` 文件，例如打印 `Hello, CI/CD component`。
     您可以使用代码注释，通过极狐GitLab Duo 代码建议生成 Go 代码。

     ```go
     // Specify the package, import required packages
     // Create a main function
     // Inside the main function, print "Hello, CI/CD Component"

     package main

     import "fmt"

     func main() {
       fmt.Println("Hello, CI/CD Component")
     }
     ```

   - 目录树应如下所示：

     ```plaintext
     tree
     .
     ├── LICENSE.md
     ├── README.md
     ├── go.mod
     ├── main.go
     └── templates
         ├── build.yml
         ├── format.yml
         └── test.yml
     ```

按照[将 CI/CD 模板转换为组件](_index.md#convert-a-cicd-template-to-a-component)一节中的其余步骤完成迁移：

1. 提交并推送更改，然后验证 CI/CD 流水线结果。
1. 按照[编写组件](_index.md#write-a-component)指南更新 `README.md` 和 `LICENSE.md` 文件。
1. [发布组件](_index.md#publish-a-new-release)，并在 CI/CD catalog 中验证它。
1. 将 CI/CD 组件添加到您的预发布/生产环境中。

[GitLab 维护的 Go 组件](https://gitlab.com/components/go)提供了一个示例，展示了从 Go CI/CD 模板成功迁移的过程，并通过输入和组件最佳实践进行了增强。您可以查看 Git 历史以了解更多信息。
