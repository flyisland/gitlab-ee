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

{{< history >}}

- 在极狐GitLab 18.6 中作为 [测试版](../../../policy/development_stages_support.md#beta) 引入。
- 在极狐GitLab 18.8 中 GA。

{{< /history >}}

<a id="turn-on-gitlab-advanced-sast-c-cpp-analysis"></a>

## 启用极狐GitLab 高级 SAST C/C++ 分析

前置条件：

- [启用极狐GitLab 高级 SAST](gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。
- [编译数据库](#compilation-database)

要在项目中启用极狐GitLab 高级 SAST C/C++ 分析：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的项目。
1. 进入 **构建** > **流水线** 编辑器。
1. 将 C/C++ 分析添加到您的 SAST 作业配置中。此处的说明假设编译数据库命名为 `compile_commands.json`。

   - 如果您使用 CI/CD 模板，在 `include:` 语句之后将以下 CI/CD 变量添加到您的配置中：

     ```yaml
     include:
       - template: Jobs/SAST.gitlab-ci.yml

     variables:
       GITLAB_ADVANCED_SAST_CPP_ENABLED: "true"
       SAST_COMPILATION_DATABASE: "compile_commands.json"
     ```

   - 如果您使用 CI/CD 组件，将以下输入参数和 CI/CD 变量添加到您的配置中：

     ```yaml
     include:
     - component: gitlab.com/components/sast/sast@main
         inputs:
           run_advanced_sast_cpp: "true"

     variables:
       SAST_COMPILATION_DATABASE: "compile_commands.json"
     ```

1. 选择 **验证** 选项卡，然后选择 **验证流水线**。

   消息 **仿真成功完成** 确认文件有效。
1. 选择 **编辑** 选项卡。
1. 填写以下字段：
   - 提交信息。
   - 分支。例如，`add-sast`。
1. 勾选 **发起一个包含这些变更的合并请求** 复选框，然后选择 **提交变更**。

   合并请求页面将打开。
1. 根据您的标准工作流程填写字段，然后选择 **创建合并请求**。
1. 根据您的标准工作流程审查和编辑合并请求，然后选择 **合并**。

<a id="compilation-database"></a>

## 编译数据库

极狐GitLab 高级 SAST CPP 分析器需要一个编译数据库（CDB）才能正确解析和分析源文件。

CDB 是一个 JSON 文件（`compile_commands.json`），为每个翻译单元包含一个条目。
每个条目通常指定以下内容：

- 用于构建文件的编译器命令
- 编译器标志和包含路径
- 执行编译的工作目录

CDB 使分析器能够重现确切的构建环境，从而确保准确的解析和语义分析。

要使用极狐GitLab 高级 SAST CPP，您必须创建一个 CDB 并将其提供给分析器。

<a id="create-a-cdb"></a>

### 创建 CDB

生成 CDB 的方式取决于您的构建系统。以下是一些常见示例。

<a id="example-cmake"></a>

#### 示例：CMake

[CMake](https://cmake.org/) 可以通过在 `cmake` 调用中添加 `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` 参数直接生成 CDB：

```shell
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

此选项配置项目并在 `build` 文件夹中生成 `compile_commands.json` 文件，该文件记录了每个源文件的编译器命令。

极狐GitLab 高级 SAST CPP 分析器依赖此文件来准确重现构建环境。

在以下构建作业示例中，将生成的 `compile_commands.json` 文件导出为 [作业产物](../../../ci/jobs/job_artifacts.md)：

```yaml
<您的构建作业名称>:
  image: ubuntu:24.04
  before_script:
    - apt update -qq && apt install -y -qq cmake build-essential
  script:
    - mkdir -p build
    - cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    - make -j$(nproc)
  artifacts:
    paths:
      - build/compile_commands.json # 将 CDB 文件传递给 gitlab-advanced-sast-cpp 作业
```

<a id="examples-for-various-build-systems"></a>

#### 各种构建系统的示例

您还可以找到使用不同构建系统创建 CDB 并运行极狐GitLab 高级 SAST CPP 的完整示例：

- [CMake 示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/1)
- [Meson 示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/2)
- [compiledb 示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/5)
- [compiledb-go 示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/7)
- [Make + Bear 示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/4)
- [Ninja + Bear 示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/3)
- [Bazel 示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/highway/-/merge_requests/8)

<a id="provide-the-cdb-to-the-analyzer"></a>

### 向分析器提供 CDB

使用 `SAST_COMPILATION_DATABASE` 变量告知极狐GitLab 高级 SAST CPP 分析器 CDB 的位置：

```yaml
variables:
  SAST_COMPILATION_DATABASE: 您的编译数据库.json
```

如果未指定 `SAST_COMPILATION_DATABASE`，极狐GitLab 高级 SAST CPP 分析器将默认使用位于项目根目录下名为 `compile_commands.json` 的文件。

生成 `compile_commands.json` 的构建作业必须将其导出为 [作业产物](../../../ci/jobs/job_artifacts.md)，以便 `gitlab-advanced-sast-cpp` 作业使用：

```yaml
variables:
  SAST_COMPILATION_DATABASE: build/compile_commands.json

<您的构建作业名称>:
  image: ubuntu:24.04
  before_script:
    - apt update -qq && apt install -y -qq cmake build-essential
  script:
    - mkdir -p build
    - cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    - make -j$(nproc)
  artifacts:
    paths:
      - build/compile_commands.json # 将 CDB 文件传递给 gitlab-advanced-sast-cpp 作业
```

或者，查看 [缓存 CDB](#caching-a-cdb)。

<a id="optimize-analysis-runtime"></a>

### 优化分析运行时间

要优化 C/C++ 代码的分析运行时间，您可以通过将 CDB 拆分为多个片段来并行运行分析。

[`极狐GitLab 高级 SAST CPP` 仓库](https://jihulab.com/gitlab-cn/security-products/demos/sast/gitlab-advanced-sast-cpp-templates/-/blob/main/templates/scripts.yml) 提供了辅助脚本来拆分 CDB 并运行并行分析。

要并行运行 C/C++ 代码分析：

1. 包含这些脚本：

   ```yaml
   include:
     - project: "gitlab-cn/security-products/demos/sast/gitlab-advanced-sast-cpp-templates"
       file: "templates/scripts.yml"
   ```

1. 在您的构建作业中引用辅助脚本并拆分 CDB：

   ```yaml
   <您的构建作业名称>:
     script:
       - <生成 CDB 的脚本>
       - !reference [.gitlab-advanced-sast-cpp-scripts]
       - split_cdb "${BUILD_DIR}" 1 4 # 拆分为 4 个片段
     artifacts:
       paths:
         - ${BUILD_DIR} # 将拆分后的 CDB 文件传递给并行化的 gitlab-advanced-sast-cpp 作业
   ```

   > [!note]
   > `split_cdb` 硬编码为读取 `${BUILD_DIR}/compile_commands.json`。
   > 您的构建必须在调用 `split_cdb` 之前在这个确切位置生成 CDB。

1. 运行并行的分析器作业：

   ```yaml
   gitlab-advanced-sast-cpp:
     parallel: 4
     variables:
       SAST_COMPILATION_DATABASE: "${BUILD_DIR}/compile_commands${CI_NODE_INDEX}.json"
     needs:
       - job: <您的构建作业名称>
         artifacts: true
   ```

   - `parallel: 4` 将执行分片为 4 个作业。
   - `${CI_NODE_INDEX}` (1, 2, 3, 4) 选择正确的 CDB 片段。
   - `needs` 确保分析器作业接收您的构建作业生成的产物。

通过此设置，您的构建作业生成一个 `compile_commands.json`。`split_cdb` 脚本创建多个分区，分析器作业并行运行，每个作业处理一个分区。

<a id="ruleset-configuration"></a>

## 规则集配置

极狐GitLab 高级 SAST CPP 支持 [自定义规则集](customize_rulesets.md)，其中“规则”是指一个极狐GitLab 高级 SAST CPP 检查器。

可以使用由 [`CodeChecker` 配置文件](https://github.com/Ericsson/codechecker/blob/master/docs/config_file.md) 组成的 [直通](customize_rulesets.md#build-a-custom-configuration-using-a-passthrough-chain-for-semgrep) 来创建自定义规则集。

直通配置按如下方式处理：

- `targetDir` 和 `target` 被忽略。处理直通后，任何生成的标志都会直接传递给 `CodeChecker`。
- `overwrite` 模式替换整个配置，`append` 模式追加标志。
- 特定的 `CodeChecker` 标志无法自定义，包括分析器标志 `-o`、`--output` 和解析标志 `-o, --output, -e, --export`。
- `server` 和 `store` 配置项被忽略。

以下示例展示了来自不同来源的直通如何组合：

文件 `.gitlab/sastconfig.toml`：

```toml
[gitlab-advanced-sast-cpp]
    description = "我的规则集"

    [[gitlab-advanced-sast-cpp.passthrough]]
        # 用我自己的配置替换极狐GitLab 默认配置
        mode  = "overwrite"
        type  = "url"
        value = "https://example.com/gitlab-advanced-sast-cpp.yaml"

    [[gitlab-advanced-sast-cpp.passthrough]]
        # 从当前仓库中的文件追加标志
        mode  = "append"
        type  = "file"
        value = "gitlab-advanced-sast-cpp.yml"
```

远程配置位于 `https://example.com/gitlab-advanced-sast-cpp.yaml`：

```yaml
analyzer:
  - --disable-all
  - --enable=core.DivideZero
```

本地配置位于 `gitlab-advanced-sast-cpp.yml`：

```yaml
analyzer:
  - --enable=core.CallAndMessage
```

最终组合配置如下：

```yaml
analyzer:
  - --disable-all
  - --enable=core.DivideZero
  - --enable=core.CallAndMessage
```

<a id="troubleshooting"></a>

## 故障排除

<a id="rebasing-paths-with-cdb-rebase"></a>

### 使用 `cdb-rebase` 重新设置路径

如果 CDB 中的路径与 CI/CD 作业中的容器路径不匹配，请使用 [cdb-rebase](https://jihulab.com/gitlab-cn/security-products/analyzers/clangsa/-/tree/main/cmd/cdb-rebase) 进行调整。

安装：

```shell
go install gitlab.com/gitlab-org/secure/tools/cdb-rebase@latest
```

二进制文件安装在 `$GOPATH/bin` 或 `$HOME/go/bin` 中。确保此目录在您的 `PATH` 中。

使用示例：

```shell
cdb-rebase compile_commands.json /host/path /container/path > rebased_compile_commands.json
```

<a id="fixing-the-cdb"></a>

### 修复 CDB

如果构建环境与扫描环境不同，生成的 CDB 可能需要调整。
您可以使用 [jq](https://jqlang.org) 进行修改，
或使用来自 [预定义辅助脚本](https://jihulab.com/gitlab-cn/security-products/demos/sast/gitlab-advanced-sast-cpp-templates/-/blob/main/templates/scripts.yml) 的 shell 函数 `cdb_append`。

`cdb_append` 向现有 CDB 追加编译器选项。
它接受：

- 第一个参数：包含 `compile_commands.json` 的文件夹
- 后续参数：要追加的额外编译器选项

CI/CD 中的示例：

```yaml
include:
  - project: "gitlab-cn/security-products/demos/sast/gitlab-advanced-sast-cpp-templates"
    file: "templates/scripts.yml"

<您的构建作业名称>:
  script:
    - !reference [.gitlab-advanced-sast-cpp-scripts]
    - <生成 CDB 的脚本>
    - cdb_append "${BUILD_DIR}" "-I'$PWD/include-cache'" "-Wno-error=register"
```

<a id="caching-a-cdb"></a>

### 缓存 CDB

为了加速编译和分析过程，CDB 可以被 [缓存](../../../ci/caching/_index.md)。

```yaml
.cdb_cache:
  cache: &cdb_cache
    key:
      files:
        - Makefile
        - src/
    paths:
      - compile_commands.json

<您的构建作业名称>:
  script:
    - <生成 CDB 的脚本>
  cache:
    <<: *cdb_cache
    policy: pull-push

gitlab-advanced-sast-cpp:
  cache:
    <<: *cdb_cache
    policy: pull
```

有关完整示例，请参阅演示项目 [`cached-cdb`](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/cached-db)。

<a id="handling-absolute-paths-in-a-cdb"></a>

### 处理 CDB 中的绝对路径

在 [演示项目](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/cached-db/-/blob/1a36792b744d7a6ad396a8ac8114ca8947e45b62/.gitlab-ci.yml#L27) 中，`bear` 从 Docker 作业的 [构建目录](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#default-build-directory) 运行。
CDB 路径是绝对路径，基于 [/builds/$CI_PROJECT_PATH](../../../ci/variables/predefined_variables.md)。
分析器作业 `gitlab-advanced-sast-cpp` 在同一位置运行，因此路径是正确的。

如果 CDB 是在分析期间不可用的路径生成的，则必须对其进行重新设置路径。
包含在分析器镜像中的 `cdb-rebase` 工具会重写 `directory`、`file` 和 `output` 路径。

示例：

```yaml
gitlab-advanced-sast-cpp:
  before-script:
    # 将原始 CDB 重新设置为相对于当前目录。
    #
    # ORIGINAL_CDB_PATH     - 来自先前作业的 CDB 产物路径（例如，artifacts/compile_commands.json）
    # ORIGINAL_CDB_BASEPATH - 生成 ORIGINAL_CDB_PATH 时项目根的绝对路径。
    #                         （例如，/mnt/custom_build_area/my-project 或 /home/user/my-project）
    - /cdb-rebase   --input "$ORIGINAL_CDB_PATH" \
                    --output compile_commands.json \
                    --src "$ORIGINAL_CDB_BASEPATH" \
                    --dst .
```

有关完整演示，请参阅 [cdb-rebase-demo](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/cdb-rebase-demo)

除了简单的路径重新设置，`cdb-rebase` 还可以管理构建和扫描环境之间的包含文件：

- 缓存外部头文件：使用 `--include-cache`，源树外部的头文件将被复制到可移植的缓存中。
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

`cdb-rebase` 工具也可用于安装了 Go 的环境中，因此可以在生成 CDB 时对其进行重新设置，例如：

```shell
go install gitlab.com/gitlab-org/security-products/analyzers/clangsa/cmd/cdb-rebase@latest
bear -o compile_commands_abs.json -- make
cdb-rebase -i compile_commands_abs.json -o compile_commands.json -s "$PWD" -d .
```

> [!note]
> 上面的 `go install` 命令将 `cdb-rebase` 安装到 `GOBIN` 路径，可以使用 `go env GOBIN` 找到该路径。

<a id="partial-scan-coverage-due-to-missing-header-files"></a>

### 由于缺少头文件导致的部分扫描覆盖

当扫描作业中缺少必需的系统或第三方头文件时，可能会出现部分扫描覆盖。
在构建作业中安装的头文件必须显式转发到扫描作业，并通过编译数据库中记录的包含路径使其可解析。

一种常见的方法是缓存所需的头文件并更新编译数据库以引用它们：

```shell
# 创建并填充一个 include 缓存
mkdir -p include-cache
dpkg -L <构建依赖软件包> | sed -n 's:^/usr/include/::p' > headers.txt
rsync -a --files-from=headers.txt /usr/include/ include-cache/

# 将缓存头文件添加到编译标志
cdb_append . "-I'$PWD/include-cache'"
```

有关完整演示，请参阅
[示例](https://jihulab.com/gitlab-cn/security-products/demos/experiments/advanced-sast-cpp/OpenSceneGraph/-/merge_requests/4)。