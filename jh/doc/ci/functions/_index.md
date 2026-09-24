---
stage: Verify
group: CI Functions Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Functions
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Functions 提供了可复用的 CI/CD 作业逻辑单元，用于替换 极狐GitLab CI/CD 作业中的 `script`。

> [!note]
> 极狐GitLab Functions 是一项正在积极开发的实验性功能，可能会发生破坏性变更。
> 有关详细信息，请查看[变更日志](https://jihulab.com/gitlab-cn/step-runner/-/blob/main/CHANGELOG.md)。

<a id="why-functions"></a>

## 为什么使用函数

当流水线规模增长时，`script` 代码块会变得难以维护。逻辑在作业之间重复，脚本在运行时从外部源获取，微小的变更需要在许多地方进行更新。极狐GitLab Functions 正是为解决这些问题而设计的。

函数的优势包括：

- 函数是自包含且带有版本的。一个函数是一个 OCI 镜像，其中封装了逻辑、支持脚本或二进制文件，以及描述其输入和输出的规范。当步骤运行时，极狐GitLab 会自动获取该函数。你无需在作业开始时获取脚本，也无需手动管理外部依赖。当你引用特定版本标签的函数时，每次都会获得完全相同的版本。

- 函数可跨作业和项目复用。将函数发布到 OCI 镜像仓库后，任何作业都可以通过一个 `func` 引用来使用它，而无需在每个仓库中复制和维护脚本文件。

- 函数使数据流变得明确。在 `script` 代码块中，数值通过 shell 变量在命令之间传递，你可以按任意顺序设置、覆盖或读取它们。而在 `run` 列表中，每个步骤都声明其输入和输出，并且一个步骤只能访问已经运行完毕的步骤的输出。

- 函数可独立测试。由于函数定义了其输入和输出，你可以在不运行整个流水线的情况下单独运行和测试它。

- 函数的执行跨平台可靠。一个专用的代理程序在构建主机上管理函数的执行，而不是解释通过网络传输的脚本。这使得函数具有适当的进程控制、跨平台一致性，并为可恢复的作业奠定了基础。这些能力是仅使用 shell 脚本难以实现或根本无法实现的。

要复用现有的 shell 脚本，可以使用 `script` 步骤在 `run` 列表中直接运行它们，同时逐步进行迁移。你无需一次性转换所有内容即可使用函数。

<a id="understand-functions"></a>

## 理解函数

在传统的 CI/CD 作业中，`script` 关键字包含一个 shell 命令列表。作业拥有每一步，逻辑直接存在于 YAML 中，这个 YAML 精确地描述了如何实现一个结果。当流水线规模增长时，这种方法变得难以跨项目复用、测试或共享。

使用 极狐GitLab Functions，你可以使用 `run` 关键字来声明一个步骤列表。每个步骤引用一个包含实现的函数，作业描述的是应该发生什么，而不是如何发生。逻辑存在于函数中，而不是 YAML 中。

以下是一个传统的用于 JavaScript 项目的 `.gitlab-ci.yml` 示例：

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

使用 极狐GitLab Functions 编写的同一条流水线：

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

每个作业通过步骤声明应该发生什么。函数本身包含了实现。

<a id="gitlab-functions-glossary"></a>

## 极狐GitLab Functions 术语表

本术语表提供了与 极狐GitLab Functions 相关的术语定义。

函数
: 一个可复用的、自包含的 CI/CD 逻辑包。函数包含特定平台的编译代码、定义其输入和输出的规范，以及描述函数功能的定义。函数可以运行一个命令或组合其他函数。

步骤
: 在 `run` 列表中对函数的一次调用。一个步骤包括一个名称、函数引用、提供的任何输入，以及为该次调用设置的任何环境变量。

输入
: 当你将函数作为步骤调用时，传入函数的命名值。输入在函数规范中声明，并带有类型和可选的默认值。

输出
: 函数运行后返回的命名值。输出在函数规范中声明，并在执行期间写入输出文件。

环境变量
: 函数在运行时可用的变量。环境变量可以来自操作系统进程环境、Runner、函数定义、步骤调用，或者之前运行的已导出这些变量的函数。

<a id="rename-from-cicd-steps"></a>

## 从 CI/CD Steps 重命名

极狐GitLab Functions 之前称为 CI/CD Steps。该功能及其语法已重命名。

| 旧名称                                   | 新名称                         |
|:------------------------------------------|:------------------------------|
| CI/CD Steps                               | 极狐GitLab Functions          |
| `step:` （已弃用）                        | `func:`                       |
| `step.yml` （已弃用）                     | `func.yml`                    |
| `${{ step_dir }}` （已弃用）              | `${{ func_dir }}`             |
| `${{ job.<variable_name> }}` （已弃用）   | `${{ vars.<variable_name> }}` |

<a id="components-and-functions"></a>

## 组件与函数

组件和函数在流水线的不同层面运行，并解决不同的问题。

[CI/CD 组件](../components/_index.md) 在流水线层面可复用。极狐GitLab 会在任何作业运行之前引入一个组件，并为流水线贡献作业、阶段和配置。组件描述流水线中存在哪些作业。

极狐GitLab Functions 在作业层面可复用。它们在作业内部运行，并替换 `script`。

组件和函数在不同层面运行，并很好地互补。一个组件可以定义一个作业，并在内部使用函数来实现它。当你引入该组件时，你获得了一个完全配置好的作业，而无需了解其工作原理。作为组件作者，你使用函数来处理作业的具体复杂度。

<a id="expression-syntax"></a>

### 表达式语法

组件和函数使用不同的表达式语法，因为它们是在不同时间求值的：

- `$[[ ]]` 表达式在流水线创建期间，即任何作业运行之前求值。请对 [CI/CD 输入](../inputs/_index.md) 和组件输入使用此语法。
- `${{ }}` 表达式在作业执行期间，即每个步骤即将运行之前求值。请对函数输入、环境变量以及依赖于运行时状态的值使用此语法。

这两种语法都可以出现在 CI/CD 组件 YAML 配置文件中：

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
        version: $[[ inputs.go_version ]]                      # 在流水线创建时解析
    - name: format
      func: ./languages/go/go-fmt
      inputs:
        go_binary: ${{ steps.install_go.outputs.go_binary }}   # 在作业执行期间解析
```

<a id="function-execution-model"></a>

## 函数执行模型

函数是自包含的包，可以接受输入、返回输出并导出环境变量。函数在你的 CI 作业环境中运行，无论该实例是宿主机还是容器。你可以将函数托管在本地文件系统、OCI 镜像仓库或 Git 仓库中。

`run` 列表中的每个步骤按顺序运行。步骤之间通过输入、输出和导出的环境变量进行通信，而不是通过共享的 shell 状态。

一个步骤的输出可供后续步骤通过 `${{ steps.<step-name>.outputs.<output-name> }}` 表达式访问。由一个步骤导出的环境变量可供所有后续步骤使用。输出和环境变量都只有在步骤完成后才变得可用。

当 Runner 拾取一个包含 `run` 列表的作业时，它会调用步骤 Runner 来管理执行。对于列表中的每个步骤，步骤 Runner 会：

1. 解析函数引用，并从文件系统、OCI 仓库或 Git 仓库获取函数包。
1. 对步骤的输入和环境变量中的任何表达式求值。
1. 执行函数，并传入经解析的输入和环境。
1. 读取函数写入输出文件的任何输出，并使它们可供后续步骤使用。
1. 读取函数导出的任何环境变量，并将它们添加到全局环境中。
1. 移至下一个步骤，如果该步骤失败则停止。

<a id="function-requirements"></a>

## 函数要求

要使用函数，你可能需要在所使用的 Runner 执行器上安装步骤 Runner。有关更多信息，请参见[手动安装步骤 Runner](https://gitlab.cn/docs/runner/install/step-runner)。

<a id="use-functions"></a>

## 使用函数

使用 `run` 关键字配置 极狐GitLab CI/CD 作业以使用函数。运行函数时，你不能在作业中使用 `before_script`、`after_script` 或 `script`。

<a id="run-a-function-with-a-step"></a>

### 通过步骤运行函数

`run` 关键字接受一个要运行的步骤列表。步骤按照它们在列表中定义的顺序逐一运行。每个步骤都有一个 `name`，以及 `func` 或 `script` 其中之一，还可以选择性地包含 `inputs` 和 `env`。

名称只能由字母数字字符和下划线组成，并且不能以数字开头。

<a id="invoke-a-function"></a>

#### 调用函数

一个步骤可以通过 `func` 关键字提供[函数引用](#function-reference)来调用一个函数。使用 `inputs` 关键字向函数传递输入，并使用 `env` 关键字覆盖环境变量值。可以在 `func` 的值以及 `inputs` 和 `env` 的键和值中使用[表达式](#expressions)。

除非被调用的函数覆盖了工作目录，否则函数会在 `CI_PROJECT_DIR` 目录中运行。

例如，运行下面的 echo 函数将在作业日志中打印消息 `Hi Sally!`。

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

一个步骤可以通过 `script` 关键字来调用脚本。使用 `env` 传递给脚本的环境变量会在 shell 中被设置。脚本步骤使用 `bash` shell，如果找不到 bash 则回退到 `sh`。[表达式](#expressions) 可用于 `script` 的值以及 `env` 的键和值。脚本步骤在 `CI_PROJECT_DIR` 目录中运行。

当你需要一些自定义且简单的功能来配合函数使用时，可以使用脚本步骤。在内部，函数会将脚本转换为函数调用，并将脚本作为输入传递。

例如，下面的脚本步骤将在作业日志中打印消息 `Hi Sally!`：

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

函数可以从文件系统或 OCI 仓库加载。虽然也支持从 Git 仓库加载，但已被弃用。

<a id="load-from-an-oci-repository"></a>

#### 从 OCI 仓库加载

{{< history >}}

- 引入于 极狐GitLab Runner 18.9。

{{< /history >}}

要从 OCI 仓库加载函数，请提供注册中心、仓库和版本（标签）。此方法是分发和使用函数的推荐方式。

函数 OCI 镜像支持多个平台。步骤 Runner 会下载与运行平台相匹配的镜像。如果找不到匹配项，步骤将失败。

```yaml
# 打印 'Hi from GitLab Functions'
my-job:
  run:
    - name: echo
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "Hi from GitLab Functions"
```

如果函数不在根目录，你也可以在镜像中指定子目录和文件名：

```yaml
# 打印 'snoitcnuF baLtiG morf iH'
my-job:
  run:
    - name: echo
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1 reverse/func.yml
      inputs:
        message: "Hi from GitLab Functions"
```

要向私有的 OCI 仓库进行身份验证，请将 `DOCKER_AUTH_CONFIG` 环境变量设置为 Docker 配置文件格式。有关作为函数进行身份验证的可用示例，请参见 [Docker Auth](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/gitlab-functions-examples/docker-auth) 函数。

<a id="load-from-the-file-system"></a>

#### 从文件系统加载

要使用相对路径从文件系统加载函数，请以 `.` 开头函数引用。路径相对于调用函数所在的目录。当你直接从作业调用函数时，该路径相对于 `CI_PROJECT_DIR`。

以 `/` 开头函数引用，即可使用绝对路径从文件系统加载函数。

当步骤运行时，该路径会成为函数目录。函数定义 YAML 必须存在于此目录中。如果文件名不是标准名称，可以选择提供函数定义 YAML 文件名。

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

#### 从 Git 仓库加载（已弃用）

> [!warning]
> 极狐GitLab 计划在未来的版本中移除对从 Git 仓库加载函数的支持。请改为从 OCI 仓库加载函数。

要从 Git 仓库加载函数，请提供仓库的 URL 和版本（提交、分支或标签）。要对仓库进行身份验证，请在 URL 中添加用户名和密码。

当你以文本形式在 `func` 中提供 Git 函数引用时，函数必须存在于 `steps` 子目录中。当你使用长格式的 Git 函数引用 `git` 时，函数必须存在于 `dir` 目录中。

Git 仓库包含的是源代码，而非编译后的代码。请尽可能从 OCI 仓库加载函数。

例如：

- 使用标签指定函数：

  ```yaml
  - name: my_step
    func: jihulab.com/funcs/my-git-repo@v1.0.0
  ```

- 使用分支指定函数：

  ```yaml
  - name: my_step
    func: jihulab.com/funcs/my-git-repo@main
  ```

- 使用目录、文件名和 Git 提交指定函数：

  ```yaml
  - name: my_step
    func: jihulab.com/funcs/my-git-repo/-/reverse/my-func.yml@3c63f399ace12061db4b8b9a29f522f41a3d7f25
  ```

- 在获取时向 Git 进行身份验证：

  ```yaml
  - name: my_step
    func: gitlab-ci-token:${{ vars.CI_JOB_TOKEN }}@jihulab.com/funcs/my-git-repo@v2.0.0
  ```

要指定 `steps` 文件夹之外的目录或文件，请使用扩展的 `func` 语法：

```yaml
my-job:
  run:
    - name: my_step
      func:
        git:
          url: jihulab.com/funcs/my-git-repo
          rev: main
          dir: my-functions/sub-directory  # 可选，默认为仓库根目录
          file: my-func.yml                # 可选，默认为 `func.yml`
```

<a id="expressions"></a>

### 表达式

当你需要一个在作业运行前无法确定的值时，例如前序步骤的输出、作业变量或计算值，请使用表达式。

表达式使用 `${{ }}` 语法，并在每个函数运行前求值。有关完整的表达式语言参考，包括运算符、数据结构和内置函数，请参见 [Moa 表达式语言](moa.md)。

表达式可用于：

- 输入值 (`inputs`)
- 环境变量值 (`env`)
- 函数引用 (`func`)
- 脚本内容 (`script`)

<a id="available-context"></a>

#### 可用上下文

使用 极狐GitLab Functions 时，请使用以下上下文变量。有关完整的上下文参考，请参见 [Moa 表达式语言](moa.md#context-reference)。

| 变量                                      | 类型   | 描述                                                                                                                               |
|:------------------------------------------|:-------|:----------------------------------------------------------------------------------------------------------------------------------|
| `env.<name>`                              | String | 函数运行时的环境。包括由 OS、Runner 设置的环境变量，以及任何由之前运行的步骤导出的环境变量。`env` 不包含 CI/CD 作业变量。 |
| `vars.<name>`                             | String | 从 Runner 传递的 CI/CD 作业变量。与 `env` 不同，此变量不受步骤导出的影响。                                                    |
| `inputs.<name>`                           | Any    | 传递给当前函数的输入值。                                                                                                        |
| `steps.<step_name>.outputs.<output_name>` | Any    | 当前 `run` 列表中前序已完成步骤的输出值。                                                                                       |
| `func_dir`                                | String | 包含函数定义文件的目录路径。用于引用与函数捆绑在一起的文件。                                                                    |
| `work_dir`                                | String | 当前执行的工作目录路径。                                                                                                        |

<a id="examples"></a>

#### 示例

- 引用前序步骤的输出：

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

- 使用带有回退默认值的作业变量：

  ```yaml
  run:
    - name: deploy
      func: ./deploy
      inputs:
        environment: ${{ vars.CI_COMMIT_REF_NAME == "main" && "production" || "staging" }}
  ```

<a id="environment-variables"></a>

### 环境变量

环境变量通过两种方式在步骤之间传递：使用 `env` 进行设置，或者通过函数导出。两者的区别在于它们的作用域不同。

CI/CD 作业变量不能作为环境变量使用。请改用 `${{ vars.<name> }}` 访问作业变量。

<a id="set-environment-variables-for-a-step"></a>

#### 为步骤设置环境变量

使用步骤上的 `env` 关键字为该步骤及其内部调用的任何函数设置环境变量。使用 `env` 设置的变量对该步骤可用，此外，环境中已有的所有变量也对它可用。如果某个变量已存在，则 `env` 设置的值优先。以这种方式设置的变量对于同一 `run` 列表中的后续步骤不可用。

```yaml
run:
  - name: build
    func: ./build
    env:
      BUILD_TARGET: release   # 仅对 build 及其子步骤可用
  - name: test
    func: ./test              # BUILD_TARGET 在这里不可用
```

在 `env` 的键和值中使用[表达式](#expressions)。

<a id="exported-environment-variables"></a>

#### 导出的环境变量

当函数写入 `${{ export_file }}` 时，它写入的变量会被导出到 `run` 列表中所有后续步骤。函数使用此方法与后续步骤共享状态。

在表达式中，导出的变量通过 `env` 可用：

```yaml
run:
  - name: setup
    func: ./setup             # 执行期间导出 INSTALL_PATH
  - name: build
    func: ./build
    inputs:
      path: ${{ env.INSTALL_PATH }}   # 因为 setup 导出了它，所以可用
```

<a id="precedence"></a>

#### 优先级

当同一变量在多个地方设置时，适用以下顺序，从最高到最低：

1. 在函数定义 (`func.yml`) 中设置的 `env`
1. 在 `run` 列表中的步骤上设置的 `env`
1. 由之前运行的步骤导出
1. 由 Runner 设置
1. 由操作系统进程环境设置

<a id="create-your-own-function"></a>

## 创建你自己的函数

要创建函数，请参见[创建 极狐GitLab Function](create.md)。

有关示例函数，请参见[极狐GitLab Functions 示例](examples.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="fetch-functions-from-an-https-url"></a>

### 从 HTTPS URL 获取函数

类似 `tls: failed to verify certificate: x509: certificate signed by unknown authority` 的错误消息表明，操作系统无法识别或信任托管该函数的服务器。

一个常见的原因是 Docker 镜像没有安装受信任的根证书。解决方法是在容器中安装证书，或者将其内置到作业 `image` 中。

你可以使用一个 `script` 步骤在获取任何函数之前安装依赖项：

```yaml
ubuntu_job:
  image: ubuntu:24.04
  run:
    - name: install_certs
      script: apt update && apt install --assume-yes --no-install-recommends ca-certificates
    - name: echo_step
      func: registry.gitlab.com/user/my_functions/hello_world:1.0.0
```