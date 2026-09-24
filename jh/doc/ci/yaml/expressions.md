---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 表达式
---

CI/CD 表达式通过引用变量和输入在特定上下文中为 CI/CD 流水线实现动态配置。极狐GitLab 在流水线创建前评估流水线配置中的表达式。

<a id="configuration-expressions"></a>

## 配置表达式

配置表达式使用 `$[[ ]]` 语法，并在流水线创建时（编译时）求值。它们能够根据不同的上下文实现动态配置。

所有配置表达式都具有以下特征：

- **编译时评估**：值在流水线配置创建时解析，而非在作业执行期间。大量表达式可能会增加流水线创建时间，但不影响作业执行时间。
- **静态解析**：无法执行动态逻辑或访问运行时作业状态。

配置表达式支持不同的上下文来访问值：

| 上下文 | 语法 | 可用版本 | 用途 |
|-----------------------------------------|-------------------------------|--------------------|---------|
| [输入上下文](#inputs-context) | `$[[ inputs.INPUT_NAME ]]` | 极狐GitLab 17.0 | 在可重用配置中引用 CI/CD 输入。 |
| [矩阵上下文](#matrix-context) | `$[[ matrix.IDENTIFIER ]]` | 极狐GitLab 18.6（测试版） | 在作业依赖中引用 `parallel:matrix` 标识符。 |
| [组件上下文](#component-context) | `$[[ component.FIELD_NAME ]]` | 极狐GitLab 18.6（测试版） | 在组件模板中引用组件元数据。 |

<a id="inputs-context"></a>

### 输入上下文

{{< history >}}

- 引入于极狐GitLab 15.11，作为 beta 功能。
- 于极狐GitLab 17.0 中转为 GA。

{{< /history >}}

使用 `inputs.` 上下文，通过 `$[[ inputs.INPUT_NAME ]]` 语法在可重用配置中引用 [CI/CD 输入](../inputs/_index.md)。

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

- 类型验证：支持 `string`、`number`、`boolean` 和 `array` 类型，并进行验证。输入验证可防止使用无效值创建流水线。
- 函数支持：预定义函数如 `expand_vars` 和 `truncate` 可用于操作值。
- 作用域：在定义的文件中可用，或通过 `include:inputs` 显式传递。

<a id="matrix-context"></a>

### 矩阵上下文

{{< history >}}

- 引入于极狐GitLab 18.6，处于 [测试版](../../policy/development_stages_support.md#beta) 阶段。

{{< /history >}}

使用 [`matrix.` 上下文](matrix_expressions.md)，通过 `$[[ matrix.IDENTIFIER ]]` 语法引用 [`parallel:matrix`](_index.md#parallelmatrix) 值。在作业依赖中使用它，可以实现在 `parallel:matrix` 作业之间建立动态的 1:1 映射。

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

- 作用于作业级 `parallel:matrix`：只能引用当前作业的值。
- 自动映射：跨阶段创建矩阵作业之间的 1:1 依赖关系。

<a id="component-context"></a>

### 组件上下文

{{< history >}}

- 于极狐GitLab 18.6 中引入，作为 [测试版](../../policy/development_stages_support.md#beta)，带有名为 `ci_component_context_interpolation` 的 [功能标志](../../administration/feature_flags/_index.md)。默认启用。
- 于极狐GitLab 18.7 中转为 GA。功能标志 `ci_component_context_interpolation` 已移除。

{{< /history >}}

使用 `component.` 上下文，通过 `$[[ component.FIELD_NAME ]]` 语法在组件模板中引用 [CI/CD 组件](../components/_index.md) 元数据。

组件上下文提供组件自身的元数据，例如其名称、版本和提交 SHA。这使得组件模板可以动态引用自身的元数据。

要使用组件上下文，在 [`spec:component`](_index.md#speccomponent) 头部中声明所需字段，然后在组件模板中引用它们。

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

<a id="related-topics"></a>

## 相关主题

- [Moa 表达式语言](../functions/moa.md)
- [CI/CD 输入](../inputs/_index.md)
- [CI/CD 组件](../components/_index.md)
- [矩阵表达式](matrix_expressions.md)
- [YAML 优化](yaml_optimization.md)