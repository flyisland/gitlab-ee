---
stage: Verify
group: CI Functions Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建 GitLab Function
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

GitLab Function 是一个包含 `func.yml` 文件的目录，该文件定义了函数的接口和实现。函数可以在本地运行，也可以发布到 OCI 镜像仓库，以便在作业和项目之间复用。

有关在 CI/CD 作业中使用函数的信息，请参阅 [GitLab Functions](_index.md)。有关示例函数，请参阅 [GitLab Functions 示例](examples.md)。

<a id="function-structure"></a>

## 函数结构

函数是一个目录，其中至少包含一个 `func.yml` 文件，以及实现所需的任何支持文件：

```plaintext
my-function/
├── func.yml
└── my-script.sh
```

`func.yml` 文件包含两个由 `---` 分隔的 YAML 文档：一个定义函数输入和输出的规范，以及一个描述函数功能的定义。

```yaml
# Document 1: spec
spec:
  inputs:
    message:
      type: string
  outputs:
    result:
      type: string
---
# Document 2: definition
exec:
  command: ["${{ func_dir }}/my-script.sh", "${{ inputs.message }}"]
```

<a id="spec-declare-inputs-and-outputs"></a>

## 规范：声明输入和输出

规范描述函数的接口。

<a id="inputs"></a>

### 输入

每个输入都需要一个 `type`。带有 `default` 值的输入是可选的。没有默认值的输入必须由调用方提供。

输入名称必须使用字母数字字符和下划线，且不能以数字开头。

输入必须是以下类型之一：

| 类型      | 示例                 | 描述             |
|:----------|:------------------------|:------------------------|
| `array`   | `["a","b"]`             | 无类型项的列表 |
| `boolean` | `true`                  | 真或假           |
| `number`  | `56.77`                 | 64 位浮点数            |
| `string`  | `"brown cow"`           | 文本                    |
| `struct`  | `{"k1":"v1","k2":"v2"}` | 结构化内容      |

例如：

```yaml
spec:
  inputs:
    # Required string input
    message:
      type: string

    # Optional input with a default
    count:
      type: number
      default: 1

    # Struct input for passing structured data
    config:
      type: struct
      default: {}
```

<a id="outputs"></a>

### 输出

输出定义函数返回给后续步骤的值。每个输出都需要一个 `type`。带有 `default` 值的输出是可选的。当函数未写入输出值时，将使用默认值。

输出使用与输入相同的类型和命名规则。

例如：

```yaml
spec:
  outputs:
    # Required string output
    artifact_path:
      type: string

    # Optional output with a default
    compressed:
      type: boolean
      default: false
```

在运行时，函数将输出值写入 `${{ output_file }}` 指定的路径。每一行必须是一个包含 `name` 和 `value` 字段的 JSON 对象：

```shell
echo '{"name":"artifact_path","value":"/dist/app.tar.gz"}' >> "${{ output_file }}"
echo '{"name":"compressed","value":true}' >> "${{ output_file }}"
```

<a id="delegate-outputs"></a>

### 委托输出

如果函数有多个步骤，而您希望函数的输出来自某个特定步骤，请在规范中使用 `outputs: delegate`，并在定义中使用 `delegate: <step_name>`：

```yaml
spec:
  outputs: delegate
---
run:
  - name: build
    func: ./build
  - name: package
    func: ./package
delegate: package  # use the package step outputs as this function outputs
```

<a id="definition-implement-the-function"></a>

## 定义：实现函数

`func.yml`中的第二个文档描述实现。您可以通过两种方式实现函数。

<a id="exec"></a>

### `exec`

使用 `exec` 运行单个命令或脚本。该命令会直接传递给操作系统而不经过 shell，因此它必须是字符串数组。

```yaml
spec:
  inputs:
    message:
      type: string
---
exec:
  command: ["./greet", "${{ inputs.message }}"]
```

工作目录默认为 `CI_PROJECT_DIR`。要覆盖它，请使用 `work_dir`。`work_dir` 关键字仅对 `exec` 定义有效，对 `run:` 定义无效。

当命令需要引用与 `func.yml` 位于同一目录中的文件时，请将 `work_dir` 设置为 `${{ func_dir }}`：

```yaml
exec:
  command: ["./build.sh"]
  work_dir: "${{ func_dir }}"
```

如果命令以非零退出码退出，则函数失败。

<a id="run"></a>

### `run`

使用 `run` 表示按顺序调用其他函数的函数。

如果序列中的任何步骤失败，则函数失败。失败后，序列中的后续步骤不会运行。

```yaml
spec:
  inputs:
    environment:
      type: string
  outputs:
    url:
      type: string
---
run:
  - name: build
    func: ./build
  - name: push
    func: registry.example.com/my-org/push:1.0.0
    inputs:
      artifact: ${{ steps.build.outputs.artifact_path }}
  - name: deploy
    func: ./deploy
    inputs:
      env: ${{ inputs.environment }}
      image: ${{ steps.push.outputs.image_ref }}
outputs:
  url: ${{ steps.deploy.outputs.url }}
```

<a id="set-environment-variables"></a>

### 设置环境变量

在定义中使用 `env` 为 `exec` 命令或 `run:` 序列中的所有步骤设置环境变量。值可以使用表达式：

```yaml
spec:
---
run:
  - name: test
    func: ./run-tests
env:
  GOFLAGS: "-race"
  TARGET_ENV: "${{ inputs.environment }}"
```

<a id="export-environment-variables"></a>

## 导出环境变量

要使环境变量在作业剩余时间内对函数之后运行的所有步骤可用，请将其写入 `${{ export_file }}`。每一行必须是一个包含 `name` 和 `value` 字段的 JSON 对象：

```shell
echo '{"name":"INSTALL_PATH","value":"/opt/myapp"}' >> "${{ export_file }}"
```

只有 `string`、`number` 和 `boolean` 值可以作为环境变量导出。

有关导出的变量如何与 `env:` 及更广泛的环境交互的更多信息，请参阅[环境变量](_index.md#environment-variables)。

<a id="expressions"></a>

## 表达式

表达式使用 `${{ }}` 语法，并在函数运行前立即求值。它们可以出现在 `inputs` 值、`env` 值、`exec` 命令参数和 `work_dir`中。

除了[表达式](_index.md#expressions)中描述的上下文变量外，函数定义中还可以使用以下上下文变量：

| 变量                                  | 描述                                                                                 |
|:------------------------------------------|:--------------------------------------------------------------------------------------------|
| `inputs.<name>`                           | 传递给此函数的指定输入的值。                                       |
| `func_dir`                                | 包含此 `func.yml`的目录的绝对路径。用于引用捆绑文件。  |
| `output_file`                             | 用于写入输出的文件路径。                                                       |
| `export_file`                             | 用于导出环境变量的文件路径。                                       |
| `steps.<step_name>.outputs.<output_name>` | 来自指定步骤的输出（仅在 `run:` 定义中可用）。                            |

<a id="complete-example"></a>

## 完整示例

以下函数接受一个文件路径，使用 `gzip` 对其进行压缩，并返回压缩文件的路径。

<a id="create-the-function"></a>

### 创建函数

目录结构：

```plaintext
compress/
├── func.yml
└── compress.sh
```

`func.yml`：

```yaml
spec:
  inputs:
    input_path:
      type: string
  outputs:
    output_path:
      type: string
---
exec:
  command: ["${{ func_dir }}/compress.sh", "${{ inputs.input_path }}", "${{ output_file }}"]
```

`compress.sh`（必须可执行）：

```shell
#!/usr/bin/env sh
set -e

INPUT_PATH="$1"
OUTPUT_FILE="$2"

gzip --keep "$INPUT_PATH"

echo "{\"name\":\"output_path\",\"value\":\"${INPUT_PATH}.gz\"}" >> "$OUTPUT_FILE"
```

<a id="use-the-function-from-a-job"></a>

### 在作业中使用函数

此函数需要作业环境中具有 `gzip`。此示例假设作业运行的实例上已提供 `gzip`。如果没有，您可以先使用 `script:` 步骤安装它，或在调用 `compress` 之前调用一个处理安装的函数。

```yaml
my-job:
  run:
    - name: compress_artifact
      func: ./compress
      inputs:
        input_path: "dist/app.tar"
    - name: list_compressed
      script: ls -lh ${{ steps.compress_artifact.outputs.output_path }}
```

有关更多示例函数，请参阅 [GitLab Functions 示例](examples.md)。

<a id="build-and-release-functions"></a>

## 构建和发布函数

函数以 OCI 镜像的形式分发。步骤运行器提供两个内置函数，用于构建和发布函数镜像。

<a id="build"></a>

### 构建

`builtin://function/oci/build` 函数根据项目目录中的文件构建多架构函数 OCI 镜像，并将其归档为 `CI_PROJECT_DIR`中的 `function-image.tar`。

`common.files` 复制所有平台共享的文件。`platforms.<os/arch>.files` 复制特定于该平台的文件。在这两种情况下，映射键是镜像中的目标路径，值是相对于 `CI_PROJECT_DIR`的源路径。

在以下示例中，`function-image.tar` 是一个支持两个平台的函数 OCI 镜像：`linux/amd64` 和 `linux/arm64`。每个平台镜像有三个文件：`func.yml`、`my-script.sh` 和 `bin/my-binary`。为平台二进制文件使用相同的文件名可使 `func.yml` 与平台无关。

```yaml
build_function:
  artifacts:
    paths:
      - function-image.tar
  run:
    - name: build
      func: builtin://function/oci/build
      inputs:
        version: "1.2.3"
        common:
          files:
            func.yml: func.yml
            my-script.sh: my-script.sh
        platforms:
          linux/amd64:
            files:
              bin/my-binary: bin/linux-amd64/my-binary
          linux/arm64:
            files:
              bin/my-binary: bin/linux-arm64/my-binary
```

<a id="release"></a>

### 发布

`builtin://function/oci/publish` 函数将来自 `function/oci/build`的归档发布到 OCI 镜像仓库。

发布函数对函数镜像标签使用语义化版本：`1.0.0`、`1.1.0`、`2.0.0`。该函数从 `function-image.tar` 文件中提取版本。发布会在必要时更新 `major`、`major.minor`、`major.minor.patch` 和 `latest` 标签。

候选版本使用预发布后缀，例如 `1.2.0-rc1`。发布候选版本只会创建确切的 `major.minor.patch-prerelease` 标签。它不会更新 `major`、`major.minor` 或 `latest` 标签。

```yaml
publish_function:
  needs: [build_function]
  run:
    - name: publish
      func: builtin://function/oci/publish
      inputs:
        archive: function-image.tar  # version is baked into the tar file
        to_repository: registry.example.com/my-org/my-function
```

<a id="authenticate-to-a-registry"></a>

### 向镜像仓库进行身份验证

要发布到私有镜像仓库，请在运行 `function/oci/publish` 之前进行身份验证。使用 [Docker Auth](https://gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/docker-auth) 函数在发布前生成并导出 `DOCKER_AUTH_CONFIG` 作为一个步骤：

```yaml
publish_function:
  needs: [build_function]
  run:
    - name: auth
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/docker-auth:1
      inputs:
        registry: ${{ vars.CI_REGISTRY }}
        username: ${{ vars.CI_REGISTRY_USER }}
        password: ${{ vars.CI_REGISTRY_PASSWORD }}
    - name: publish
      func: builtin://function/oci/publish
      inputs:
        archive: function-image.tar
        to_repository: ${{ vars.CI_REGISTRY_IMAGE }}
```

`docker-auth` 会将 `DOCKER_AUTH_CONFIG` 导出到所有后续步骤，因此 `function/oci/publish` 会自动获取它。

发布后，调用方使用镜像仓库 URL 和标签引用该函数：

```yaml
run:
  - name: run_my_function
    func: registry.example.com/my-org/my-function:1.2.3
```
