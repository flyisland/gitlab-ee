---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 表达式
---

CI/CD 表达式让您可以在专用上下文中引用变量和输入，从而在 CI/CD 流水线中实现动态配置。极狐GitLab 会在创建流水线之前，对流水线配置中的表达式进行求值。

<a id="configuration-expressions"></a>

## 配置表达式

配置表达式使用 `$[[ ]]` 语法，并在流水线创建时（编译时）求值。它们支持基于不同上下文实现动态配置。

所有配置表达式都具有以下特征：

- **编译时求值**：值在创建流水线配置时解析，
  而不是在作业执行期间解析。大量表达式可能会增加流水线创建时间，
  但不会影响作业执行时间。
- **静态解析**：无法执行动态逻辑或访问运行时作业状态。

配置表达式支持不同的上下文来访问值：

| 上下文                                 | 语法                        | 可用性       | 用途 |
|-----------------------------------------|-------------------------------|--------------------|---------|
| [输入上下文](#inputs-context)       | `$[[ inputs.INPUT_NAME ]]`    | 极狐GitLab 17.0        | 在可复用配置中引用 CI/CD 输入。 |
| [矩阵上下文](#matrix-context)       | `$[[ matrix.IDENTIFIER ]]`    | 极狐GitLab 18.6（测试版） | 在作业依赖中引用 `parallel:matrix` 标识符。 |
| [组件上下文](#component-context) | `$[[ component.FIELD_NAME ]]` | 极狐GitLab 18.6（测试版） | 在组件模板中引用组件元数据。 |

<a id="inputs-context"></a>

### 输入上下文

使用 `inputs.` 上下文，通过 `$[[ inputs.INPUT_NAME ]]` 语法在可复用配置中引用 [CI/CD 输入](../inputs/_index.md)。

例如：

```yaml
spec:
  inputs:
    environment:
      default: production
    job-stage:
      default: test
---
scan-website:
  stage: $[[ inputs.job-stage ]]
  script: ./scan-website $[[ inputs.environment ]]
```

`input.` 表达式具有以下特征：

- 类型验证：支持 `string`、`number`、`boolean` 和 `array` 类型，并会进行验证。
  输入验证可防止使用无效值创建流水线。
- 函数支持：`expand_vars` 和 `truncate` 等预定义函数可以操作值。
- 作用域：在定义该输入的文件中可用，或通过 `include:inputs` 显式传递。

<a id="matrix-context"></a>

### 矩阵上下文

使用 [`matrix.` 上下文](matrix_expressions.md)，通过 `$[[ matrix.IDENTIFIER ]]` 语法引用 [`parallel:matrix`](_index.md#parallelmatrix)的值。在作业依赖中使用它，可实现 `parallel:matrix` 作业之间动态的 1:1 映射。

例如：

```yaml
.os-arch-matrix:
  parallel:
    matrix:
      - OS: [ubuntu, alpine]
        ARCH: [amd64, arm64]

build:
  script: echo "Testing $OS on $ARCH"
  parallel: !reference [.os-arch-matrix, parallel]

test:
  script: echo "Testing $OS on $ARCH"
  parallel: !reference [.os-arch-matrix, parallel]
  needs:
    - job: build
      parallel:
        matrix:
          - OS: ['$[[ matrix.OS ]]']
            ARCH: ['$[[ matrix.ARCH ]]']
```

`matrix.` 表达式具有以下特征：

- 作用域限于作业级 `parallel:matrix`：只能引用当前作业中的值。
- 自动映射：在跨阶段的矩阵作业之间创建 1:1 依赖关系。

<a id="component-context"></a>

### 组件上下文

使用 `component.` 上下文，通过 `$[[ component.FIELD_NAME ]]` 语法在组件模板中引用 [CI/CD 组件](../components/_index.md)元数据。

组件上下文提供有关组件自身的元数据，例如其名称、版本和提交 SHA。这使组件模板可以动态引用自身的元数据。

要使用组件上下文，请在 [`spec:component`](_index.md#speccomponent) 头部声明需要哪些字段，然后在组件模板中引用它们。

例如：

```yaml
spec:
  component: [name, version]
  inputs:
    stage:
      default: build
---

build-job:
  stage: $[[ inputs.stage ]]
  image: registry.example.com/$[[ component.name ]]:$[[ component.version ]]
  script:
    - echo "Building with component version $[[ component.version ]]"
```
