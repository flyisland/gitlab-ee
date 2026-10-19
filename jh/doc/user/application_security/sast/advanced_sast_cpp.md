---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 高级 SAST C/C++ 配置
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="turn-on-gitlab-advanced-sast-cc-analysis"></a>

## 开启极狐GitLab 高级 SAST C/C++ 分析

先决条件：

- [开启极狐GitLab 高级 SAST](gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。
- [编译数据库](#compilation-database)

要在您的项目中开启极狐GitLab 高级 SAST C/C++ 分析：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到**构建** > **流水线**编辑器。
1. 将 C/C++ 分析添加到您的 SAST 作业配置中。此处的说明假定
   编译数据库名为 `compile_commands.json`。

   - 如果您使用的是 CI/CD 模板，请在 `include:` 语句之后
     将以下 CI/CD 变量添加到您的配置中：

     ```yaml
     include:
       - template: Jobs/SAST.gitlab-ci.yml

     variables:
       GITLAB_ADVANCED_SAST_CPP_ENABLED: "true"
       SAST_COMPILATION_DATABASE: "compile_commands.json"
     ```

   - 如果您使用的是 CI/CD 组件，请将以下输入参数
     和 CI/CD 变量添加到您的配置中：

     ```yaml
     include:
     - component: gitlab.com/components/sast/sast@main
         inputs:
           run_advanced_sast_cpp: "true"

     variables:
       SAST_COMPILATION_DATABASE: "compile_commands.json"
     ```

1. 选择**验证**标签页，然后选择**验证流水线**。

   **模拟已成功完成**消息确认该文件有效。
1. 选择**编辑**标签页。
1. 填写以下字段：
   - 提交信息。
   - 分支。例如，`add-sast`。
1. 选中**使用这些更改启动新的合并请求**复选框，然后选择
   **提交更改**。

   合并请求页面随即打开。
1. 按照您的标准工作流填写字段，然后选择**创建合并请求**。
1. 按照您的标准工作流审阅并编辑合并请求，然后选择**合并**。

<a id="compilation-database"></a>

## 编译数据库

极狐GitLab 高级 SAST CPP 分析器需要编译数据库（CDB）才能正确解析和分析源文件。

CDB 是一个 JSON 文件（`compile_commands.json`），其中为每个翻译单元包含一个条目。每个条目通常指定以下内容：

- 用于构建该文件的编译器命令
- 编译器标志和包含路径
- 执行编译的工作目录

CDB 使分析器能够重现确切的构建环境，从而确保准确的解析和语义分析。

要使用极狐GitLab 高级 SAST CPP，您必须创建 CDB 并将其提供给分析器。

<a id="create-a-cdb"></a>

### 创建 CDB

生成 CDB 的方式取决于您的构建系统。以下是一些常见示例。

<a id="example-cmake"></a>

#### 示例：CMake

[CMake](https://cmake.org/) 可以通过在 `cmake` 调用中添加 `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` 参数来直接生成 CDB：

```shell
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

此选项会配置项目，并在 `build` 文件夹中生成一个 `compile_commands.json` 文件，其中记录了每个源文件的编译器命令。

极狐GitLab 高级 SAST CPP 分析器依赖此文件来准确重现构建环境。

在以下构建作业示例中，将生成的 `compile_commands.json` 文件导出为[作业产物](../../../ci/jobs/job_artifacts.md)：

```yaml
<YOUR-BUILD-JOB-NAME>:
  image: ubuntu:24.04
  before_script:
    - apt update -qq && apt install -y -qq cmake build-essential
  script:
    - mkdir -p build
    - cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    - make -j$(nproc)
  artifacts:
    paths:
      - build/compile_commands.json # Pass the CDB file to the gitlab-advanced-sast-cpp job
```

<a id="examples-for-various-build-systems"></a>

#### 各种构建系统的示例

您还可以找到使用不同构建系统创建 CDB 并运行极狐GitLab 高级 SAST CPP 的完整示例：

- [CMake 示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/1)
- [Meson 示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/2)
- [compiledb 示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/5)
- [compiledb-go 示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/7)
- [Make + Bear 示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/4)
- [Ninja + Bear 示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/3)
- [Bazel 示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/8)

<a id="provide-the-cdb-to-the-analyzer"></a>

### 将 CDB 提供给分析器

使用 `SAST_COMPILATION_DATABASE` 变量告知极狐GitLab 高级 SAST CPP 分析器在何处查找 CDB：

```yaml
variables:
  SAST_COMPILATION_DATABASE: YOUR_COMPILATION_DATABASE.json
```

如果未指定 `SAST_COMPILATION_DATABASE`，极狐GitLab 高级 SAST CPP 分析器默认使用项目根目录中名为 `compile_commands.json`的文件。

生成 `compile_commands.json` 文件的构建作业必须将其导出为[作业产物](../../../ci/jobs/job_artifacts.md)，以供 `gitlab-advanced-sast-cpp` 作业使用：

```yaml
variables:
  SAST_COMPILATION_DATABASE: build/compile_commands.json

<YOUR-BUILD-JOB-NAME>:
  image: ubuntu:24.04
  before_script:
    - apt update -qq && apt install -y -qq cmake build-essential
  script:
    - mkdir -p build
    - cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    - make -j$(nproc)
  artifacts:
    paths:
      - build/compile_commands.json # Pass the CDB file to the gitlab-advanced-sast-cpp job
```

或者，请查看[缓存 CDB](#caching-a-cdb)。

<a id="optimize-analysis-runtime"></a>

### 优化分析运行时间

要优化 C/C++ 代码的分析运行时间，您可以通过将 CDB 拆分为多个片段来并行运行分析。

[`GitLab Advanced SAST CPP` 代码仓库](https://gitlab.com/gitlab-org/security-products/demos/sast/gitlab-advanced-sast-cpp-templates/-/blob/main/templates/scripts.yml)提供了用于拆分 CDB 并运行并行分析的辅助脚本。

要并行运行 C/C++ 代码分析：

1. 包含这些脚本：

   ```yaml
   include:
     - project: "gitlab-org/security-products/demos/sast/gitlab-advanced-sast-cpp-templates"
       file: "templates/scripts.yml"
   ```

1. 引用辅助脚本并在您的构建作业中拆分 CDB：

   ```yaml
   <YOUR-BUILD-JOB-NAME>:
     script:
       - <your-script to generate the CDB>
       - !reference [.gitlab-advanced-sast-cpp-scripts]
       - split_cdb "${BUILD_DIR}" 1 4 # Split into 4 fragments
     artifacts:
       paths:
         - ${BUILD_DIR} # Pass the split CDB files to the parallelized gitlab-advanced-sast-cpp jobs
   ```

   > [!note]
   > `split_cdb` 被硬编码为读取 `${BUILD_DIR}/compile_commands.json`。
   > 您的构建必须在此确切位置生成 CDB，然后才能调用 `split_cdb`。

1. 运行并行分析器作业：

   ```yaml
   gitlab-advanced-sast-cpp:
     parallel: 4
     variables:
       SAST_COMPILATION_DATABASE: "${BUILD_DIR}/compile_commands${CI_NODE_INDEX}.json"
     needs:
       - job: <YOUR-BUILD-JOB-NAME>
         artifacts: true
   ```

   - `parallel: 4` 将执行分片到 4 个作业中。
   - `${CI_NODE_INDEX}`（1、2、3、4）选择正确的 CDB 片段。
   - `needs` 确保分析器作业接收您的构建作业生成的产物。

通过此设置，您的构建作业会生成单个 `compile_commands.json`。`split_cdb` 脚本会创建多个分区，分析器作业并行运行，每个作业处理一个分区。

<a id="ruleset-configuration"></a>

## 规则集配置

极狐GitLab 高级 SAST CPP 支持[自定义规则集](customize_rulesets.md)，其中“规则”是一个
极狐GitLab 高级 SAST CPP 检查器。

可以使用由 [`CodeChecker` 配置文件](https://github.com/Ericsson/codechecker/blob/master/docs/config_file.md)组成的[直通](customize_rulesets.md#build-a-custom-configuration-using-a-passthrough-chain-for-semgrep)来创建自定义规则集。

直通配置的处理方式如下：

- `targetDir` 和 `target` 会被忽略。处理直通后，任何生成的标志都会
  直接传递给 `CodeChecker`。
- `overwrite` 模式会替换整个配置，`append` 模式会追加标志。
- 无法自定义特定的 `CodeChecker` 标志，包括分析器标志 `-o`、`--output`
  以及解析标志 `-o, --output, -e, --export`。
- `server` 和 `store` 配置项会被忽略。

以下示例展示了来自不同来源的直通如何组合：

文件 `.gitlab/sast-ruleset.toml`：

```toml
[gitlab-advanced-sast-cpp]
    description = "My ruleset"

    [[gitlab-advanced-sast-cpp.passthrough]]
        # replace the GitLab default configuration with my own
        mode  = "overwrite"
        type  = "url"
        value = "https://example.com/gitlab-advanced-sast-cpp.yaml"

    [[gitlab-advanced-sast-cpp.passthrough]]
        # append flags from a file in the current repository
        mode  = "append"
        type  = "file"
        value = "gitlab-advanced-sast-cpp.yml"
```

位于 `https://example.com/gitlab-advanced-sast-cpp.yaml`的远程配置：

```yaml
analyzer:
  - --disable-all
  - --enable=core.DivideZero
```

位于 `gitlab-advanced-sast-cpp.yml`的本地配置：

```yaml
analyzer:
  - --enable=core.CallAndMessage
```

合并后的配置如下：

```yaml
analyzer:
  - --disable-all
  - --enable=core.DivideZero
  - --enable=core.CallAndMessage
```

<a id="offline-environment"></a>

## 离线环境

要在离线环境中运行极狐GitLab 高级 SAST C/C++，请在运行扫描之前将 `clangsa` 分析器镜像镜像到您的本地镜像仓库。标准的 `gitlab-advanced-sast` 镜像不包含用于其他语言的 `clangsa` 镜像。您必须单独镜像此镜像。

要镜像 `clangsa` 镜像，请使用 [`Secure-Binaries.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/Secure-Binaries.gitlab-ci.yml)。此模板包含一个 `gitlab-advanced-sast-cpp` 作业，用于将 `clangsa` 镜像拉取并推送到您的镜像仓库。

有关设置离线环境的更多信息，请参阅[离线环境](../offline_deployments/_index.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="rebasing-paths-with-cdb-rebase"></a>

### 使用 `cdb-rebase` 重定路径基准

如果 CDB 中的路径与 CI/CD 作业中的容器路径不匹配，请使用 [cdb-rebase](https://gitlab.com/gitlab-org/security-products/analyzers/clangsa/-/tree/main/cmd/cdb-rebase) 调整它们。

安装：

```shell
go install gitlab.com/gitlab-org/secure/tools/cdb-rebase@latest
```

该二进制文件安装在 `$GOPATH/bin` 或 `$HOME/go/bin`中。请确保此目录位于您的 `PATH`中。

用法示例：

```shell
cdb-rebase compile_commands.json /host/path /container/path > rebased_compile_commands.json
```

<a id="fixing-the-cdb"></a>

### 修复 CDB

如果构建环境与扫描环境不同，生成的 CDB 可能需要调整。您可以使用 [jq](https://jqlang.org) 修改它，或使用 `cdb_append`，这是[预定义辅助脚本](https://gitlab.com/gitlab-org/security-products/demos/sast/gitlab-advanced-sast-cpp-templates/-/blob/main/templates/scripts.yml)中的一个 shell 函数。

`cdb_append` 会将编译器选项追加到现有 CDB。它接受：

- 第一个参数：包含 `compile_commands.json`的文件夹
- 后续参数：要追加的其他编译器选项

CI/CD 中的示例：

```yaml
include:
  - project: "gitlab-org/security-products/demos/sast/gitlab-advanced-sast-cpp-templates"
    file: "templates/scripts.yml"

<YOUR-BUILD-JOB-NAME>:
  script:
    - !reference [.gitlab-advanced-sast-cpp-scripts]
    - <your-script to generate the CDB>
    - cdb_append "${BUILD_DIR}" "-I'$PWD/include-cache'" "-Wno-error=register"
```

<a id="caching-a-cdb"></a>

### 缓存 CDB

为了加速编译和分析过程，可以[缓存](../../../ci/caching/_index.md) CDB。

```yaml
.cdb_cache:
  cache: &cdb_cache
    key:
      files:
        - Makefile
        - src/
    paths:
      - compile_commands.json

<YOUR-BUILD-JOB-NAME>:
  script:
    - <your-script to generate the CDB>
  cache:
    <<: *cdb_cache
    policy: pull-push

gitlab-advanced-sast-cpp:
  cache:
    <<: *cdb_cache
    policy: pull
```

有关完整示例，请参阅演示项目 [`cached-cdb`](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/cached-db)。

<a id="handling-absolute-paths-in-a-cdb"></a>

### 处理 CDB 中的绝对路径

在[演示项目](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/cached-db/-/blob/1a36792b744d7a6ad396a8ac8114ca8947e45b62/.gitlab-ci.yml#L27)中，`bear` 是从 Docker 作业的[构建目录](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#default-build-directory)运行的。
CDB 路径是绝对路径，基于 [/builds/$CI_PROJECT_PATH](../../../ci/variables/predefined_variables.md)。
分析器作业 `gitlab-advanced-sast-cpp` 在同一位置运行，因此路径是正确的。

如果 CDB 是在分析期间不可用的路径中生成的，则必须重定其基准。分析器镜像中包含的 `cdb-rebase` 工具会重写 `directory`、`file` 和 `output` 路径。

示例：

```yaml
gitlab-advanced-sast-cpp:
  before-script:
    # Rebase the original CDB to be relative to the current directory.
    #
    # ORIGINAL_CDB_PATH     - Path to the CDB artifact from a previous job (e.g., artifacts/compile_commands.json)
    # ORIGINAL_CDB_BASEPATH - The absolute path to the project root when the ORIGINAL_CDB_PATH was generated.
    #                         (e.g., /mnt/custom_build_area/my-project or /home/user/my-project)
    - /cdb-rebase   --input "$ORIGINAL_CDB_PATH" \
                    --output compile_commands.json \
                    --src "$ORIGINAL_CDB_BASEPATH" \
                    --dst .
```

有关完整演示，请参阅 [cdb-rebase-demo](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/cdb-rebase-demo)

除了简单的路径重定基准之外，`cdb-rebase` 还可以管理构建环境和扫描环境之间的包含文件：

- 缓存外部头文件：使用 `--include-cache`，源代码树之外的头文件会被复制到可移植缓存中。
- 添加包含路径：使用 `--include`，指定要缓存的额外包含目录。
- 排除文件：使用 `--exclude`，跳过您不想携带的头文件。

示例：

```shell
/cdb-rebase --src /my-project \
            --dst /scan-env \
            --input build/compile_commands.json \
            --output rebased_cdb.json \
            --include-cache include-cache \
            --include third_party/include \
            --exclude dummy.h
```

`cdb-rebase` 工具也可用于已安装 Go 的环境，因此可以在生成 CDB 时重定其基准，例如

```shell
go install gitlab.com/gitlab-org/security-products/analyzers/clangsa/cmd/cdb-rebase@latest
bear -o compile_commands_abs.json -- make
cdb-rebase -i compile_commands_abs.json -o compile_commands.json -s "$PWD" -d .
```

> [!note]
> 上面的 `go install` 命令会将 `cdb-rebase` 安装到 `GOBIN` 路径，可通过 `go env GOBIN` 找到该路径。

<a id="partial-scan-coverage-due-to-missing-header-files"></a>

### 因缺少头文件而导致扫描覆盖不完整

当扫描作业中缺少所需的系统或第三方头文件时，可能会出现扫描覆盖不完整的情况。在构建作业期间安装的头文件必须显式转发到扫描作业，并通过编译数据库中记录的包含路径使其可解析。

一种常见方法是缓存所需的头文件并更新编译数据库以引用它们：

```shell
# Create and populate an include cache
mkdir -p include-cache
dpkg -L <build-dependency-packages> | sed -n 's:^/usr/include/::p' > headers.txt
rsync -a --files-from=headers.txt /usr/include/ include-cache/

# Add cached headers to compile flags
cdb_append . "-I'$PWD/include-cache'"
```

有关完整演示，请参阅[示例](https://gitlab.com/gitlab-org/security-products/demos/experiments/advanced-sast-cpp/OpenSceneGraph/-/merge_requests/4)。
