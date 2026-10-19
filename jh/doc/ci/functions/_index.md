---
stage: Verify
group: CI Functions Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Functions
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

GitLab Functions 提供可复用的 CI/CD 作业逻辑单元，用于替代极狐GitLab CI/CD 作业中的 `script`。

> [!note]
> GitLab Functions 是一项正在积极开发的实验功能，可能会发生破坏性变更。
> 有关详情，请查看[变更日志](https://gitlab.com/gitlab-org/step-runner/-/blob/main/CHANGELOG.md)。

<a id="why-functions"></a>

## 为什么使用函数

当流水线规模增长时，`script` 块会变得难以维护。逻辑在多个作业中重复，脚本在运行时从外部来源获取，而微小的改动需要在多处更新。GitLab Functions 正是为解决这些问题而设计的。

函数的优势包括：

- 函数是自包含且带版本的。函数是一个 OCI 镜像，其中打包了逻辑、支持的脚本或二进制文件，
  以及描述其输入和输出的规范。当步骤运行时，极狐GitLab 会自动获取该函数。您无需在作业开始时
  获取脚本，也无需手动管理外部依赖。当您引用特定版本标签的函数时，每次都会得到完全相同的版本。

- 函数可在作业和项目之间复用。将函数发布到 OCI 镜像仓库后，任何作业都可以通过单个 `func` 引用使用它，
  无需在每个代码仓库中复制和维护脚本文件。

- 函数使数据流变得明确。在 `script` 块中，值通过 shell 变量在命令之间传递，
  您可以按任意顺序设置、覆盖或读取这些变量。而在 `run` 列表中，每个步骤都声明其输入和输出，
  并且一个步骤只能访问已经运行过的步骤的输出。

- 函数可以独立测试。由于函数定义了其输入和输出，您可以单独运行和测试它，而无需运行整个流水线。

- 函数执行在不同平台上都可靠。专用代理在构建主机上管理函数执行，而不是解释通过网络传输的脚本。
  这为函数提供了恰当的进程控制、跨平台一致性，以及可恢复作业的基础。仅靠 shell 脚本很难或
  无法实现这些能力。

要复用现有的 shell 脚本，请在逐步迁移的过程中使用 `script` 步骤在 `run` 列表中直接运行它们。您可以先使用函数，而不必一次性转换所有内容。

<a id="understand-functions"></a>

## 了解函数

在传统的 CI/CD 作业中，`script` 关键字包含一组 shell 命令。作业拥有每一个步骤，逻辑直接存在于 YAML 中，精确描述了如何达成结果。当流水线规模增长时，这种方式会变得难以复用、测试或跨项目共享。

使用 GitLab Functions 时，您使用 `run` 关键字来声明一组步骤。每个步骤引用一个包含实现的函数，作业描述应该发生什么，而不是如何发生。逻辑存在于函数中，而不是 YAML 中。

以下是一个 JavaScript 项目的传统 `.gitlab-ci.yml` 示例：

```yaml
build_and_release:
  script:
    - npm run lint
    - npm test
    - npm run bundle
    - BUNDLE_PATH=$(find dist -name '*.js' | head -1)
    - npm run minify -- --input $BUNDLE_PATH
    - npm run deploy -- --artifact $MINIFIED_PATH --env production
```

使用 GitLab Functions 编写的同一个流水线：

```yaml
build_and_release:
  run:
    - name: validate
      func: registry.gitlab.com/js/validate:1.0.0
    - name: release
      func: registry.gitlab.com/js/release:1.0.0
      inputs:
        environment: production
```

每个作业通过步骤声明应该发生什么。函数本身包含实现。

<a id="gitlab-functions-glossary"></a>

## GitLab Functions 术语表

本术语表提供与 GitLab Functions 相关术语的定义。

函数
: 一个可复用、自包含的 CI/CD 逻辑包。函数包含特定平台的编译代码、
定义其输入和输出的规范，以及描述函数功能的定义。
函数可以运行命令，也可以组合其他函数。

步骤
: 在 `run` 列表中对函数的一次调用。步骤包括名称、函数引用、
提供的任何输入，以及为该次调用设置的任何环境变量。

输入
: 当您将函数作为步骤调用时传入的具名值。输入在函数
规范中声明，包含类型和可选的默认值。

输出
: 函数运行后返回的具名值。输出在函数规范中声明，
并在执行期间写入输出文件。

环境变量
: 函数在运行时可以使用的变量。环境变量可以来自操作系统
进程环境、Runner、函数定义、步骤调用，或之前运行并导出它们的函数。

<a id="rename-from-cicd-steps"></a>

## 从 CI/CD Steps 重命名

GitLab Functions 以前称为 CI/CD Steps。该功能及其语法已重命名。

| 旧                                        | 新                            |
|:------------------------------------------|:------------------------------|
| CI/CD Steps                               | GitLab Functions              |
| `step:`（已弃用）                      | `func:`                       |
| `step.yml`（已弃用）                   | `func.yml`                    |
| `${{ step_dir }}`（已弃用）            | `${{ func_dir }}`             |
| `${{ job.<variable_name> }}`（已弃用） | `${{ vars.<variable_name> }}` |

<a id="components-and-functions"></a>

## 组件与函数

组件和函数在流水线的不同层级上运作，解决不同的问题。

[CI/CD 组件](../components/_index.md)可在流水线层级复用。极狐GitLab 会在任何作业运行之前包含组件，并向流水线贡献作业、阶段和配置。组件描述流水线中存在哪些作业。

GitLab Functions 可在作业层级复用。它们在作业内部运行，并替代 `script`。

组件和函数在不同层级上运作，可以很好地互补。组件可以定义一个作业，并在内部使用函数来实现它。当您包含该组件时，您就获得了一个完全配置好的作业，而无需了解其工作原理。作为组件作者，您可以使用函数来处理作业功能的复杂性。

<a id="expression-syntax"></a>

### 表达式语法

组件和函数使用不同的表达式语法，因为它们在不同的时间求值：

- `$[[ ]]` 表达式在流水线创建期间、任何作业运行之前求值。此语法用于
  [CI/CD 输入](../inputs/_index.md)和组件输入。
- `${{ }}` 表达式在作业执行期间、每个步骤运行之前求值。此语法用于
  函数输入、环境变量以及依赖运行时状态的值。

两种语法都可以出现在 CI/CD 组件 YAML 配置文件中：

```yaml
spec:
  inputs:
    go_version:
      default: "1.22"
---

my-format-job:
  run:
    - name: install_go
      func: ./languages/go/install
      inputs:
        version: $[[ inputs.go_version ]]                      # resolved at pipeline creation
    - name: format
      func: ./languages/go/go-fmt
      inputs:
        go_binary: ${{ steps.install_go.outputs.go_binary }}   # resolved during job execution
```

<a id="function-execution-model"></a>

## 函数执行模型

函数是自包含的包，可以接受输入、返回输出并导出环境变量。函数在您的 CI 作业环境中运行，无论该实例是主机还是容器。您可以将函数托管在本地文件系统、OCI 镜像仓库或 Git 代码仓库中。

`run` 列表中的每个步骤按顺序运行。步骤之间通过输入、输出和导出的环境变量进行通信，而不是通过共享的 shell 状态。

一个步骤的输出可通过 `${{ steps.<step-name>.outputs.<output-name> }}` 表达式供后续步骤使用。一个步骤导出的环境变量可供所有后续步骤使用。输出和环境变量都只在该步骤完成后才可用。

当 Runner 获取带有 `run` 列表的作业时，它会调用步骤运行器来管理执行。对于列表中的每个步骤，步骤运行器会：

1. 解析函数引用，并从文件系统、OCI 镜像仓库
   或 Git 代码仓库获取函数包。
1. 对步骤输入和环境变量中的任何表达式求值。
1. 执行函数，并传入解析后的输入和环境。
1. 读取函数写入输出文件的任何输出，并将其提供给后续步骤。
1. 读取函数导出的任何环境变量，并将其添加到全局环境。
1. 继续下一个步骤，如果该步骤失败则停止。

<a id="function-requirements"></a>

## 函数要求

要使用函数，您可能需要在所使用的 Runner 执行器上安装步骤运行器。有关更多信息，请参阅[手动安装步骤运行器](https://gitlab.cn/docs/runner/install/step-runner/)。

<a id="use-functions"></a>

## 使用函数

使用 `run` 关键字配置极狐GitLab CI/CD 作业以使用函数。运行函数时，您不能在作业中使用 `before_script`、`after_script` 或 `script`。

<a id="run-a-function-with-a-step"></a>

### 使用步骤运行函数

`run` 关键字接受要运行的步骤列表。步骤按列表中定义的顺序一次运行一个。每个步骤都有一个 `name`，以及 `func` 或 `script`，还可以有 `inputs` 和 `env`。

名称只能由字母数字字符和下划线组成，且不能以数字开头。

<a id="invoke-a-function"></a>

#### 调用函数

步骤可以通过 `func` 关键字提供[函数引用](#function-reference)来调用函数。使用 `inputs` 关键字向函数传递输入，并使用 `env` 关键字覆盖环境值。在 `func` 值以及 `inputs` 和 `env`的键和值中使用[表达式](#expressions)。

函数在 `CI_PROJECT_DIR` 目录中运行，除非被调用的函数覆盖了工作目录。

例如，运行下面的 echo 函数会将消息 `Hi Sally!` 打印到作业日志中。

```yaml
my-job:
  variables:
    FRIEND: "Sally"
  run:
    - name: say_hi
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "Hi ${{ vars.FRIEND }}!"
```

<a id="run-a-script"></a>

#### 运行脚本

步骤可以通过 `script` 关键字调用脚本。使用 `env` 传递给脚本的环境变量会在 shell 中设置。脚本步骤使用 `bash` shell，如果找不到 bash，则回退到 `sh`。[表达式](#expressions)可用于 `script` 值以及 `env`的键和值。脚本步骤在 `CI_PROJECT_DIR` 目录中运行。

当您需要在函数之外使用自定义内容时，请使用脚本步骤。在内部，函数会将脚本转换为函数调用，并将脚本作为输入传入。

例如，以下脚本步骤会将消息 `Hi Sally!` 打印到作业日志中：

```yaml
my-job:
  variables:
    FRIEND: "Sally"
  run:
    - name: say_hi
      script: echo 'Hi ${{ vars.FRIEND }}!'
```

<a id="function-reference"></a>

### 函数引用

函数从文件系统或 OCI 镜像仓库加载。从 Git 代码仓库加载受支持但已弃用。

<a id="load-from-an-oci-repository"></a>

#### 从 OCI 镜像仓库加载

要从 OCI 镜像仓库加载函数，请提供镜像仓库地址（registry）、仓库路径（repository）和版本（标签）。此方法是分发和使用函数的推荐方式。

函数 OCI 镜像支持多个平台。步骤运行器会下载与运行平台匹配的镜像。如果找不到匹配项，该步骤会失败。

```yaml
# prints 'Hi from GitLab Functions'
my-job:
  run:
    - name: echo
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "Hi from GitLab Functions"
```

如果函数不在根目录，您还可以在镜像中指定子目录和文件名：

```yaml
# prints 'snoitcnuF baLtiG morf iH'
my-job:
  run:
    - name: echo
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1 reverse/func.yml
      inputs:
        message: "Hi from GitLab Functions"
```

要向私有 OCI 镜像仓库进行身份验证，请设置 `DOCKER_AUTH_CONFIG` 环境变量，其值采用 Docker 配置文件格式。有关作为函数进行身份验证的可用示例，请参阅
[Docker Auth](https://gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/docker-auth) 函数。

<a id="load-from-the-file-system"></a>

#### 从文件系统加载

要使用相对路径从文件系统加载函数，请以 `.` 开头。路径相对于调用函数的目录。当您直接从作业调用该函数时，路径相对于 `CI_PROJECT_DIR`。

以 `/` 开头，可使用绝对路径从文件系统加载函数。

该路径在步骤运行时成为函数目录。函数定义 YAML 必须存在于此目录中。可选地，如果函数定义 YAML 文件名非标准，请提供该文件名。

无论操作系统如何，路径分隔符都必须使用正斜杠 `/`。

例如：

- 从相对目录加载：

  ```yaml
  - name: my_step
    func: ./path/to/my-function
  ```

- 从绝对目录加载：

  ```yaml
  - name: my_step
    func: /opt/gitlab-functions/my-function
  ```

- 使用自定义函数定义文件加载：

  ```yaml
  - name: my_step
    func: ./funcs/release/dry-run.yml
  ```

<a id="load-from-a-git-repository-deprecated"></a>

#### 从 Git 代码仓库加载（已弃用）

> [!warning]
> 极狐GitLab 计划在未来版本中移除从 Git 代码仓库加载函数的支持。
> 请改为从 OCI 镜像仓库加载函数。

要从 Git 代码仓库加载函数，请提供该代码仓库的 URL 和修订版本（提交、分支或标签）。要向该代码仓库进行身份验证，请在 URL 中添加用户名和密码。

当您在 `func`中以文本形式提供 Git 函数引用时，函数必须存在于 `steps` 子目录中。当您使用长格式 Git 函数引用 `git` 时，函数必须存在于 `dir` 目录中。

Git 代码仓库包含源代码，而不是编译后的代码。请尽可能从 OCI 镜像仓库加载函数。

例如：

- 使用标签指定函数：

  ```yaml
  - name: my_step
    func: gitlab.com/funcs/my-git-repo@v1.0.0
  ```

- 使用分支指定函数：

  ```yaml
  - name: my_step
    func: gitlab.com/funcs/my-git-repo@main
  ```

- 使用目录、文件名和 Git 提交指定函数：

  ```yaml
  - name: my_step
    func: gitlab.com/funcs/my-git-repo/-/reverse/my-func.yml@3c63f399ace12061db4b8b9a29f522f41a3d7f25
  ```

- 在获取时向 Git 进行身份验证：

  ```yaml
  - name: my_step
    func: gitlab-ci-token:${{ vars.CI_JOB_TOKEN }}@gitlab.com/funcs/my-git-repo@v2.0.0
  ```

要指定 `steps` 文件夹之外的目录或文件，请使用扩展的 `func` 语法：

```yaml
my-job:
  run:
    - name: my_step
      func:
        git:
          url: gitlab.com/funcs/my-git-repo
          rev: main
          dir: my-functions/sub-directory  # optional, defaults to the repository root
          file: my-func.yml                # optional, defaults to `func.yml`
```

<a id="expressions"></a>

### 表达式

当您需要一个直到作业运行时才知道的值时，请使用表达式，例如前一个步骤的输出、作业变量或计算得出的值。

表达式使用 `${{ }}` 语法，并在每个函数运行之前求值。有关完整的表达式语言参考，包括运算符、数据结构和内置函数，请参阅 [Moa 表达式语言](moa.md)。

表达式可用于：

- 输入值（`inputs`）
- 环境变量值（`env`）
- 函数引用（`func`）
- 脚本内容（`script`）

<a id="available-context"></a>

#### 可用上下文

使用 GitLab Functions 时，请使用以下上下文变量。有关完整的上下文参考，请参阅 [Moa 表达式语言](moa.md#context-reference)。

| 变量                                  | 类型   | 描述                                                                                                                                                                                                   |
|:------------------------------------------|:-------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `env.<name>`                              | String | 函数运行时的环境。包括由操作系统、Runner 设置的环境变量，以及之前运行的步骤导出的任何环境变量。`env` 不包含 CI/CD 作业变量。 |
| `vars.<name>`                             | String | 从 Runner 传入的 CI/CD 作业变量。与 `env` 不同，此变量不受步骤导出的影响。                                                                                                      |
| `inputs.<name>`                           | Any    | 传递给当前函数的输入值。                                                                                                                                                              |
| `steps.<step_name>.outputs.<output_name>` | Any    | 当前 `run` 列表中之前已完成步骤的输出值。                                                                                                                                     |
| `func_dir`                                | String | 包含函数定义文件的目录路径。用于引用与函数捆绑在一起的文件。                                                                                            |
| `work_dir`                                | String | 当前执行的工作目录路径。                                                                                                                                                      |

<a id="examples"></a>

#### 示例

- 引用前一个步骤的输出：

  ```yaml
  my-job:
    run:
      - name: generate_rand
        func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/random:1
      - name: echo
        func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
        inputs:
          message: "The random value is: ${{ steps.generate_rand.outputs.random_value }}"
  ```

- 使用带后备默认值的作业变量：

  ```yaml
  run:
    - name: deploy
      func: ./deploy
      inputs:
        environment: ${{ vars.CI_COMMIT_REF_NAME == "main" && "production" || "staging" }}
  ```

<a id="environment-variables"></a>

### 环境变量

环境变量在步骤之间以两种方式传递：您使用 `env` 设置它们，或通过函数导出它们。这一区别很重要，因为它们的作用域不同。

CI/CD 作业变量不能作为环境变量使用。请改用 `${{ vars.<name> }}` 访问作业变量。

<a id="set-environment-variables-for-a-step"></a>

#### 为步骤设置环境变量

在步骤上使用 `env` 关键字，为该步骤及其内部调用的任何函数设置环境变量。使用 `env` 设置的变量，除了环境中已有的所有变量之外，还可供该步骤使用。如果某个变量已存在，则由 `env` 设置的值优先。以这种方式设置的变量不可供同一 `run` 列表中的后续步骤使用。

```yaml
run:
  - name: build
    func: ./build
    env:
      BUILD_TARGET: release   # available to build and its child steps only
  - name: test
    func: ./test              # BUILD_TARGET is not available here
```

在 `env`的键和值中使用[表达式](#expressions)。

<a id="exported-environment-variables"></a>

#### 导出的环境变量

当函数写入 `${{ export_file }}` 时，它写入的变量会导出到 `run` 列表中的所有后续步骤。函数使用此方法与后续步骤共享状态。

导出的变量可通过表达式中的 `env` 使用：

```yaml
run:
  - name: setup
    func: ./setup             # exports INSTALL_PATH during execution
  - name: build
    func: ./build
    inputs:
      path: ${{ env.INSTALL_PATH }}   # available because setup exported it
```

<a id="precedence"></a>

#### 优先级

当同一个变量在多个位置设置时，适用以下顺序，从高到低：

1. 在函数定义（`func.yml`）中设置的 `env`
1. 在 `run` 列表中的步骤上设置的 `env`
1. 由之前运行的步骤导出
1. 由 Runner 设置
1. 由操作系统进程环境设置

<a id="create-your-own-function"></a>

## 创建您自己的函数

要创建函数，请参阅[创建 GitLab Function](create.md)。

有关示例函数，请参阅 [GitLab Functions 示例](examples.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="fetch-functions-from-an-https-url"></a>

### 从 HTTPS URL 获取函数

诸如 `tls: failed to verify certificate: x509: certificate signed by unknown authority` 之类的错误消息表明操作系统无法识别或信任托管该函数的服务器。

一个常见原因是 Docker 镜像未安装受信任的根证书。请通过在容器中安装证书，或将其烘焙到作业 `image`中来解决此问题。

您可以使用 `script` 步骤在获取任何函数之前安装依赖项：

```yaml
ubuntu_job:
  image: ubuntu:24.04
  run:
    - name: install_certs
      script: apt update && apt install --assume-yes --no-install-recommends ca-certificates
    - name: echo_step
      func: registry.gitlab.com/user/my_functions/hello_world:1.0.0
```
