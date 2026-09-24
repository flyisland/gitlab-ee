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

{{< history >}}

- 在极狐GitLab 18.6 中引入。

{{< /history >}}

矩阵表达式根据 [`parallel:matrix`](_index.md#parallel-matrix) 标识符实现动态作业依赖，从而在 `parallel:matrix` 作业之间创建 1:1 映射。

与 [inputs 表达式](expressions.md#inputs-context) 相比，矩阵表达式有一些限制：

- 仅编译时：标识符在流水线创建时解析，而不是在作业执行时。
- 仅字符串替换：无复杂逻辑或转换。
- 仅矩阵标识符：无法引用 CI/CD 变量或输入。

<a id="syntax"></a>

## 语法

矩阵表达式使用 `$[[ matrix.IDENTIFIER ]]` 语法在作业依赖中引用 `parallel:matrix` 标识符。例如：

```yaml
needs:
  - job: build
    parallel:
      matrix:
        - OS: ['$[[ matrix.OS ]]']
          ARCH: ['$[[ matrix.ARCH ]]']
```

<a id="matrix-expressions-in-needs-parallel-matrix"></a>

### 在 `needs:parallel:matrix` 中使用矩阵表达式

你可以使用矩阵表达式在作业依赖中动态引用矩阵标识符，实现矩阵作业之间的一对一映射，而无需手动指定所有组合。

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

此示例在所有 `linux:build` 和 `linux:test` 作业之间创建一对一依赖映射：

- `linux:test: [aws, monitoring]` 依赖于 `linux:build: [aws, monitoring]`
- `linux:test: [aws, app1]` 依赖于 `linux:build: [aws, app1]`
- 所有 6 个 `parallel:matrix` 值组合均如此。

使用 `matrix.` 表达式，你无需手动指定每个矩阵组合。

矩阵表达式仅引用当前作业矩阵配置中的标识符。

<a id="use-yaml-anchors-to-reuse-parallel-matrix-configuration"></a>

### 使用 YAML 锚点复用 `parallel:matrix` 配置

你可以使用 [YAML 锚点](yaml_optimization.md#anchors) 在具有复杂 `parallel:matrix` 配置和依赖关系的多个作业间复用 `parallel:matrix` 配置。

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

此配置创建 24 个作业：每个阶段 8 个作业（2 `OS` × 2 `ARCH` × 2 `VARIANT` 组合），各阶段之间为一对一依赖关系。

<a id="use-a-subset-of-values"></a>

### 使用值的子集

你可以将矩阵表达式与特定值结合使用，以创建选择性的依赖子集：

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

- `prepare_env` 使用 `parallel:matrix` 创建 9 个作业：3 `PLATFORM` × 3 `VERSIONS`。
- `build_project` 使用 `parallel:matrix` 创建 3 个作业：仅 3 个 `PLATFORM` 值。
- 每个 `build_project` 作业仅依赖于所有平台 (`PLATFORM`) 上 Node.js `18` (`VERSION`) 的准备。

或者，你可以 [手动配置所有依赖关系](../jobs/job_control.md#specify-a-parallelized-job-using-needs-with-multiple-parallelized-jobs)。