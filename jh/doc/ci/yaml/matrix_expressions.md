---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab CI/CD 中的矩阵表达式
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

矩阵表达式可基于 [`parallel:matrix`](_index.md#parallelmatrix) 标识符实现动态作业依赖，从而在 `parallel:matrix` 作业之间建立 1:1 映射。

与[输入表达式](expressions.md#inputs-context)相比，矩阵表达式存在一些限制：

- 仅在编译时生效：标识符在创建流水线时解析，而不是在作业执行期间解析。
- 仅支持字符串替换：不支持复杂逻辑或转换。
- 仅支持矩阵标识符：不能引用 CI/CD 变量或输入。

<a id="syntax"></a>

## 语法

矩阵表达式使用 `$[[ matrix.IDENTIFIER ]]` 语法，在作业依赖中引用 `parallel:matrix` 标识符。例如：

```yaml
needs:
  - job: build
    parallel:
      matrix:
        - OS: ['$[[ matrix.OS ]]']
          ARCH: ['$[[ matrix.ARCH ]]']
```

<a id="matrix-expressions-in-needsparallelmatrix"></a>

### `needs:parallel:matrix`中的矩阵表达式

您可以使用矩阵表达式在作业依赖中动态引用矩阵标识符，从而在矩阵作业之间建立 1:1 映射，而无需手动指定所有组合。

例如：

```yaml
linux:build:
  stage: build
  script: echo "Building linux..."
  parallel:
    matrix:
      - PROVIDER: [aws, gcp]
        STACK: [monitoring, app1, app2]

linux:test:
  stage: test
  script: echo "Testing linux..."
  parallel:
    matrix:
      - PROVIDER: [aws, gcp]
        STACK: [monitoring, app1, app2]
  needs:
    - job: linux:build
      parallel:
        matrix:
          - PROVIDER: ['$[[ matrix.PROVIDER ]]']
            STACK: ['$[[ matrix.STACK ]]']
```

此示例在所有 `linux:build` 和 `linux:test` 作业之间建立 1:1 依赖映射：

- `linux:test: [aws, monitoring]` 依赖于 `linux:build: [aws, monitoring]`
- `linux:test: [aws, app1]` 依赖于 `linux:build: [aws, app1]`
- 所有 6 种 `parallel:matrix` 值组合均遵循相同规则。

使用 `matrix.` 表达式，您无需手动指定每个矩阵组合。

矩阵表达式仅引用当前作业矩阵配置中的标识符。

<a id="use-yaml-anchors-to-reuse-parallelmatrix-configuration"></a>

### 使用 YAML 锚点复用 `parallel:matrix` 配置

您可以使用 [YAML 锚点](yaml_optimization.md#anchors)，在具有复杂 `parallel:matrix` 配置和依赖关系的多个作业之间复用 `parallel:matrix` 配置。

例如：

```yaml
stages:
  - compile
  - test
  - deploy

.build_matrix: &build_matrix
  parallel:
    matrix:
      - OS: ["ubuntu", "alpine"]
        ARCH: ["amd64", "arm64"]
        VARIANT: ["slim", "full"]

compile_binary:
  stage: compile
  script:
    - echo "Compiling for $OS-$ARCH-$VARIANT"
  <<: *build_matrix

integration_test:
  stage: test
  script:
    - echo "Testing $OS-$ARCH-$VARIANT"
  <<: *build_matrix
  needs:
    - job: compile_binary
      parallel:
        matrix:
          - OS: ['$[[ matrix.OS ]]']
            ARCH: ['$[[ matrix.ARCH ]]']
            VARIANT: ['$[[ matrix.VARIANT ]]']

deploy_artifact:
  stage: deploy
  script:
    - echo "Deploying $OS-$ARCH-$VARIANT"
  <<: *build_matrix
  needs:
    - job: integration_test
      parallel:
        matrix:
          - OS: ['$[[ matrix.OS ]]']
            ARCH: ['$[[ matrix.ARCH ]]']
            VARIANT: ['$[[ matrix.VARIANT ]]']
```

此配置会创建 24 个作业：每个阶段 8 个作业（2 个 `OS` × 2 个 `ARCH` × 2 个 `VARIANT` 组合），各阶段之间具有 1:1 依赖关系。

<a id="use-a-subset-of-values"></a>

### 使用部分值

您可以将矩阵表达式与特定值结合使用，创建选择性的依赖子集：

```yaml
stages:
  - prepare
  - build
  - test

.full_matrix: &full_matrix
  parallel:
    matrix:
      - PLATFORM: ["linux", "windows", "macos"]
        VERSION: ["16", "18", "20"]

.platform_only: &platform_only
  parallel:
    matrix:
      - PLATFORM: ["linux", "windows", "macos"]

prepare_env:
  stage: prepare
  script:
    - echo "Preparing $PLATFORM with Node.js $VERSION"
  <<: *full_matrix

build_project:
  stage: build
  script:
    - echo "Building on $PLATFORM"
  needs:
    - job: prepare_env
      parallel:
        matrix:
          - PLATFORM: ['$[[ matrix.PLATFORM ]]']
            VERSION: ["18"]  # Only depend on Node.js 18 preparations
  <<: *platform_only
```

在此示例中：

- `prepare_env` 使用 `parallel:matrix` 创建 9 个作业：3 个 `PLATFORM` × 3 个 `VERSIONS`。
- `build_project` 使用 `parallel:matrix` 创建 3 个作业：仅包含 3 个 `PLATFORM` 值。
- 每个 `build_project` 作业仅依赖于所有平台（`PLATFORM`）的 Node.js `18`（`VERSION`）。

或者，您可以[手动配置所有依赖关系](../jobs/job_control.md#specify-a-parallelized-job-using-needs-with-multiple-parallelized-jobs)。
