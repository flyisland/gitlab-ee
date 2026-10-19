---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Moa 表达式语言
---

Moa 是一种表达式语言，用于在作业执行期间动态构造值。表达式用 `${{ }}` 分隔符括起，用于 GitLab Functions 和作业输入。

Moa 支持字符串操作、算术、比较、逻辑运算、属性访问和函数调用。

<a id="differences-from-cicd-expressions"></a>

## 与 CI/CD 表达式的区别

极狐GitLab 有三种表达式语法，在流水线生命周期的不同阶段发挥不同作用。

- [规则](../yaml/_index.md#rules)在 `rules:` 关键字中使用自己的表达式语法，
  以控制作业是否包含。它们在流水线创建期间求值，支持
  针对 CI/CD 变量的比较和模式匹配，但无法执行算术
  或访问运行时状态。
- CI/CD 表达式使用 `$[[ ]]` 语法，在流水线创建期间、
  任何作业运行之前求值。这些表达式为
  [CI/CD 输入](../inputs/_index.md)、[矩阵值](../yaml/matrix_expressions.md)和
  [组件输入](../components/_index.md)执行值替换。它们无法执行
  算术、比较或逻辑运算，也无法访问运行时状态。
  更多信息，请参见 [CI/CD 表达式](../yaml/expressions.md)。
- Moa 使用 `${{ }}` 语法，由 Runner 在作业执行期间
  求值。Moa 是一种完整的表达式语言，具有运算符、数据结构和
  函数调用。

这三种语法可以共存于同一个流水线中。一个包含
GitLab Functions 的 CI/CD 组件可能同时使用这三种语法：

```yaml
spec:
  inputs:
    echo_version:
      type: string
---

hi-job:
  # rules expression - evaluated when the pipeline is created
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  run:
    - name: say_hi
      # $[[ ]] - resolved when the pipeline is created
      step: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo@$[[ inputs.echo_version ]]
      inputs:
        # ${{ }} - resolved when the job runs
        message: "Hello, ${{ vars.CI_PROJECT_NAME }}"
```

Moa 之所以作为一种独立语言存在，是因为 GitLab Functions 需要在流水线创建时无法获得的能力：

- 运行时求值：步骤输出在函数运行之前并不存在。像
  `${{ steps.build.outputs.image_ref }}` 这样的表达式只能在执行期间求值。
- 类型化值：Moa 保留原生类型（数字、布尔值、数组和对象），
  并在函数之间传递它们，而不会转换为字符串。
- 运算符和逻辑：GitLab Functions 需要算术（`major_version + 1`）、比较
  （`vulnerabilities == 0`）和短路逻辑（`inputs.tag || "latest"`），
  以便从变量和输出构造步骤输入。
- 敏感值跟踪：Moa 会在运算过程中传播敏感值。
  如果您将敏感值拼接到字符串中，或通过函数调用传递它，
  结果也会被视为敏感值。这可以防止在日志和输出中
  意外泄露密钥。

<a id="context-reference"></a>

## 上下文引用

表达式中可用的值取决于表达式的使用位置。

| 上下文       | 可用于                                                                                             | 类型   | 求值时机                        | 描述                                                                                                                             |
|---------------|----------------------------------------------------------------------------------------------------------|--------|----------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| `job.inputs`  | 作业配置：`script`、`before_script`、`after_script`、`artifacts`、`cache`、`image`、`services`  | 对象 | Runner 收到作业时 | 为作业定义的输入值。使用 `job.inputs.<name>` 访问各个变量。                                                 |
| `env`         | GitLab Functions                                                                                         | 对象 | 函数运行之前         | 函数可用的环境变量。使用 `env.<name>` 访问各个变量。                                         |
| `inputs`      | GitLab Functions                                                                                         | 对象 | 函数运行之前         | 传递给函数的输入值。使用 `inputs.<name>` 访问各个输入。                                                     |
| `vars`        | GitLab Functions                                                                                         | 对象 | 函数运行之前         | 从 CI 作业传递的作业变量。使用 `vars.<name>` 访问各个变量。                                                   |
| `steps`       | GitLab Functions                                                                                         | 对象 | 函数运行之前         | 当前函数中先前已执行步骤的结果。使用 `steps.<step_name>.outputs.<output_name>` 访问某个步骤的输出。 |
| `export_file` | GitLab Functions                                                                                         | 字符串 | 函数运行之前         | 供函数写入环境变量、以导出到后续步骤的文件路径。                                      |
| `output_file` | GitLab Functions                                                                                         | 字符串 | 函数运行之前         | 函数将输出值写入该文件的路径。                                                                           |
| `func_dir`    | GitLab Functions                                                                                         | 字符串 | 函数运行之前         | 包含函数定义文件的目录路径。用于引用与函数捆绑的文件。                      |
| `work_dir`    | GitLab Functions                                                                                         | 字符串 | 函数运行之前         | 当前执行的工作目录路径。                                                                                |

<a id="template-syntax"></a>

## 模板语法

<a id="interpolation"></a>

### 插值

将表达式包裹在 `${{ }}` 中以对其求值：

```yaml
script:
  - echo "Hello, ${{ job.inputs.name }}"
```

当表达式周围有文本时，结果始终会转换为字符串。单个值中可以出现多个表达式：

```yaml
script:
  - echo "${{ job.inputs.greeting }}, ${{ job.inputs.name }}!"
```

<a id="native-type-passthrough"></a>

### 原生类型直通

当 `${{ expression }}` 是整个值且周围没有文本时，表达式返回其原生类型。使用原生类型表达式可以在步骤之间传递数字、布尔值、数组和对象等非字符串值，而无需将它们转换为字符串。

```yaml
inputs:
  count: ${{ steps.previous.outputs.total }}
```

在此示例中，如果 `total` 是数字，则 `count` 接收的是数字，而不是字符串表示。

<a id="escape-moa-expressions"></a>

### 转义 Moa 表达式

要在文本中包含字面量 `${{` 而不触发插值，请使用反斜杠对其进行转义：

```yaml
script:
  - echo "Use \${{ to start an expression"
```

此命令会输出文本 `Use ${{ to start an expression`，而不进行求值。

<a id="literals"></a>

## 字面量

<a id="null"></a>

### Null

关键字 `null` 表示值的缺失。

```yaml
${{ null }}
```

<a id="booleans"></a>

### 布尔值

关键字 `true` 和 `false` 表示布尔值。

```yaml
${{ true }}
${{ false }}
```

<a id="numbers"></a>

### 数字

数字是 IEEE 754 双精度浮点值，具有 53 位精度。大于 2^53（约 9 千万亿）的整数无法精确表示。支持整数、小数和科学记数法。

```yaml
${{ 42 }}
${{ 3.14 }}
${{ 1.5e3 }}
${{ 2E-4 }}
```

<a id="strings"></a>

### 字符串

将字符串括在双引号或单引号中。这两种引号类型对转义序列和模板表达式的处理方式不同。

双引号字符串支持模板表达式和完整的转义序列：

| 序列  | 含义                                 |
|-----------|-----------------------------------------|
| `\\`      | 反斜杠                               |
| `\"`      | 双引号                            |
| `\n`      | 换行符                                 |
| `\r`      | 回车符                         |
| `\t`      | 制表符                                     |
| `\a`      | 警报（响铃）                            |
| `\b`      | 退格符                               |
| `\f`      | 换页符                               |
| `\v`      | 垂直制表符                            |
| `\/`      | 正斜杠                           |
| `\uXXXX`  | Unicode 码点                      |
| `\${{`    | 字面量 `${{`（阻止插值）  |

双引号字符串中的模板表达式（`${{ }}`）会被求值并插值到字符串中。

单引号字符串是原始字符串字面量，解释极少。单引号字符串中的模板表达式不会被求值。仅支持两种转义序列：

| 序列 | 含义      |
|----------|--------------|
| `\\`     | 反斜杠    |
| `\'`     | 单引号 |

```yaml
${{ "Hello\nWorld" }}
${{ 'It\'s a string' }}
${{ 'Literal ${{ not evaluated }}' }}
```

<a id="identifiers"></a>

## 标识符

标识符引用表达式上下文中的值。标识符以字母或下划线开头，可以包含字母、数字和下划线。标识符区分大小写：`foo`、`Foo` 和 `FOO` 是三个不同的标识符。

```yaml
${{ env }}
${{ my_variable }}
```

标识符会根据可用的上下文进行解析。有关每个上下文中可用的值，请参见[上下文引用](#context-reference)。

当标识符引用某个上下文对象时，会返回整个对象。例如，`${{ vars }}` 会以对象形式返回所有作业变量。

<a id="operators"></a>

## 运算符

<a id="arithmetic-operators"></a>

### 算术运算符

算术运算符作用于数字。`+` 运算符还可用于拼接字符串。运算符不会执行隐式类型转换，因此 `"hello" + 42` 会导致错误。

| 运算符 | 描述                 | 示例             | 结果     |
|----------|-----------------------------|---------------------|------------|
| `+`      | 加法                    | `${{ 2 + 3 }}`      | `5`        |
| `+`      | 拼接               | `${{ "a" + "b" }}`  | `"ab"`     |
| `-`      | 减法                 | `${{ 10 - 4 }}`     | `6`        |
| `*`      | 乘法              | `${{ 3 * 4 }}`      | `12`       |
| `/`      | 除法                    | `${{ 10 / 3 }}`     | `3.333...` |
| `%`      | 取模（截断除法） | `${{ 10 % 3 }}`     | `1`        |

除以零会导致错误。

<a id="comparison-operators"></a>

### 比较运算符

比较运算符返回布尔值。

| 运算符 | 描述           | 示例            | 结果  |
|----------|-----------------------|--------------------|---------|
| `==`     | 等于                 | `${{ 1 == 1 }}`    | `true`  |
| `!=`     | 不等于             | `${{ 1 != 2 }}`    | `true`  |
| `<`      | 小于             | `${{ 1 < 2 }}`     | `true`  |
| `<=`     | 小于或等于    | `${{ 2 <= 2 }}`    | `true`  |
| `>`      | 大于          | `${{ 3 > 2 }}`     | `true`  |
| `>=`     | 大于或等于 | `${{ 3 >= 3 }}`    | `true`  |

不同类型的值按类型进行比较，因此 `1 == "1"` 的求值结果为 `false`。相同类型的值遵循以下比较规则：

- 数字：数值比较。
- 字符串：字典序比较（UTF-8 字节顺序）。
- 布尔值：`false` 小于 `true`。
- 数组：逐元素比较。
- 对象：先按长度比较，再按键比较，最后按值比较。键的顺序无关紧要。
- Null：`null` 等于 `null`。

<a id="logical-operators"></a>

### 逻辑运算符

逻辑运算符使用短路求值，并返回其操作数之一，而不一定是布尔值。此行为类似于 JavaScript 的 `&&` 和 `||` 运算符。

| 运算符   | 描述 | 行为                                                                                      |
|------------|-------------|-----------------------------------------------------------------------------------------------|
| `\|\|`     | 逻辑或  | 如果左操作数为真值，则返回左操作数，否则求值并返回右操作数。  |
| `&&`       | 逻辑与 | 如果左操作数为假值，则返回左操作数，否则求值并返回右操作数。   |
| `!`        | 逻辑非 | 如果操作数为假值则返回 `true`，如果为真值则返回 `false`。                                    |

`||` 运算符用于提供默认值：

```yaml
${{ inputs.name || "default" }}
```

如果 `inputs.name` 是非空字符串，则按原样返回。如果它为空或为 null，则返回 `"default"`。

<a id="unary-operators"></a>

### 一元运算符

| 运算符 | 描述    | 示例          | 结果  |
|----------|----------------|------------------|---------|
| `+`      | 一元加     | `${{ +5 }}`      | `5`     |
| `-`      | 一元取负 | `${{ -5 }}`      | `-5`    |
| `!`      | 逻辑非    | `${{ !true }}`   | `false` |

<a id="operator-precedence"></a>

### 运算符优先级

运算符按从最高优先级到最低优先级列出。同一行中的运算符具有相同优先级。所有二元运算符都是左结合的。

| 优先级  | 运算符                        |
|-------------|----------------------------------|
| 7（最高） | `.`、`[]`、`()`                  |
| 6           | `+`、`-`、`!`                    |
| 5           | `*`、`/`、`%`                    |
| 4           | `+`、`-`                         |
| 3           | `==`、`!=`、`<`、`<=`、`>`、`>=` |
| 2           | `&&`                             |
| 1（最低）  | `\|\|`                           |

使用括号可覆盖优先级：

```yaml
${{ (1 + 2) * 3 }}
```

<a id="data-structures"></a>

## 数据结构

<a id="arrays"></a>

### 数组

使用方括号表示法创建数组。元素可以是任意类型，并且可以混合类型。可以使用尾随逗号。

```yaml
${{ [1, 2, 3] }}
${{ ["a", 1, true, null] }}
${{ [] }}
```

<a id="objects"></a>

### 对象

使用花括号表示法创建对象。键必须求值为字符串。值可以是任意类型。允许使用尾随逗号。

```yaml
${{ {name: "runner", version: 1} }}
${{ {"string-key": true} }}
${{ {} }}
```

用作对象键的裸标识符会被视为字符串字面量，而不是变量引用。要将变量用作键，请将其括在括号中：

```yaml
${{ {name: "Alice"} }}           # "name" is the string "name", not a variable reference
${{ {(obj.prop): "value"} }}     # key is the value of obj.prop, which must be a string
```

<a id="property-access"></a>

## 属性访问

<a id="dot-notation"></a>

### 点表示法

使用点表示法访问对象属性：

```yaml
${{ env.HOME }}
${{ steps.build.outputs.artifact_path }}
```

<a id="bracket-notation"></a>

### 方括号表示法

按索引访问数组元素，或按字符串键访问对象属性：

```yaml
${{ my_array[0] }}
${{ my_object["property-name"] }}
```

当属性名包含连字符等特殊字符时，必须使用方括号表示法。

<a id="chaining"></a>

### 链式调用

链式使用属性访问和函数调用：

```yaml
${{ steps.build.outputs.items[0] }}
```

<a id="function-calls"></a>

## 函数调用

使用括号按名称调用函数：

```yaml
${{ str(42) }}
${{ num("3.14") }}
```

<a id="truthiness"></a>

## 真值性

逻辑运算符和 `!` 运算符使用以下真值性规则：

| 类型    | 为真值时             | 为假值时        |
|---------|-------------------------|-------------------|
| 布尔值 | `true`                  | `false`           |
| 字符串  | 长度大于 `0` | 空字符串 `""` |
| 数字  | 不为 `0`                 | `0`               |
| 数组   | 长度大于 `0` | 空数组 `[]`  |
| 对象  | 长度大于 `0` | 空对象 `{}` |
| Null    | 从不                   | 始终            |

<a id="built-in-functions"></a>

## 内置函数

<a id="strvalue"></a>

### `str(value)`

将任意值转换为其字符串表示。

```yaml
${{ str(42) }}       # "42"
${{ str(true) }}     # "true"
${{ str(null) }}     # "<null>"
```

<a id="numvalue"></a>

### `num(value)`

将字符串转换为数字。该字符串必须是有效的数字表示。

```yaml
${{ num("42") }}     # 42
${{ num("3.14") }}   # 3.14
```

<a id="boolvalue"></a>

### `bool(value)`

根据值的[真值性](#truthiness)将任意值转换为布尔值。

```yaml
${{ bool("hello") }}  # true
${{ bool("") }}       # false
${{ bool(0) }}        # false
${{ bool(1) }}        # true
```

<a id="reserved-words"></a>

## 保留字

以下单词为保留字，不能用作标识符。它们是为未来可能的语言特性而保留的。

`array`、`as`、`break`、`case`、`const`、`continue`、`default`、`else`、
`fallthrough`、`float`、`for`、`func`、`function`、`goto`、`if`、`import`、
`in`、`int`、`let`、`loop`、`map`、`namespace`、`number`、`object`、`package`、
`range`、`return`、`string`、`struct`、`switch`、`type`、`var`、`void`、`while`

关键字 `null`、`true` 和 `false` 也作为字面量值保留。

<a id="examples"></a>

## 示例

<a id="deploy-with-strategy-selection"></a>

### 带策略选择的部署

```yaml
deploy job:
  when: manual
  inputs:
    environment:
      default: staging
      options: [staging, production]
      description: Target deployment environment
    strategy:
      default: rolling
      options: [rolling, blue-green, canary]
      description: Deployment strategy
    replicas:
      type: number
      default: 3
      description: Number of replicas to deploy
  image: ${{ job.inputs.environment == "production" && "deploy-tools:stable" || "deploy-tools:latest" }}
  script:
    - 'echo "Deploying to ${{ job.inputs.environment }} using ${{ job.inputs.strategy }}"'
    - deploy
        --env ${{ job.inputs.environment }}
        --strategy ${{ job.inputs.strategy }}
        --replicas ${{ str(job.inputs.replicas) }}
```

<a id="conditional-flags-from-boolean-job-inputs"></a>

### 来自布尔作业输入的条件标志

```yaml
test_job:
  inputs:
    coverage:
      type: boolean
      default: false
    verbose:
      type: boolean
      default: false
  script:
    - pytest ${{ job.inputs.verbose && "-v" || "" }} ${{ job.inputs.coverage && "--cov=src" || "" }}
```

<a id="building-an-image-reference-from-job-variables"></a>

### 从作业变量构建镜像引用

```yaml
build_job:
  run:
    - name: build
      func: ./docker-build
      inputs:
        image: ${{ vars.CI_REGISTRY + "/" + vars.CI_PROJECT_PATH + ":" + vars.CI_PIPELINE_IID }}
```

<a id="continue-gate"></a>

### 继续门控

```yaml
security_scan_job:
  run:
    - name: scan
      func: ./security-scan
    - name: gate
      func: ./quality-gate
      inputs:
        should_proceed: ${{ steps.scan.outputs.critical == 0 && steps.scan.outputs.high < 5 }}
```

<a id="version-management"></a>

### 版本管理

```yaml
increment_version_job:
  run:
    - name: current
      func: ./find-version
    - name: bump
      func: ./bump-version
      inputs:
        new_version: ${{ str(steps.current.outputs.major + 1) + ".0.0" }}
```

<a id="environment-specific-configuration"></a>

### 特定环境的配置

```yaml
deploy_job:
  run:
    - name: deploy
      func: ./deploy
      inputs:
        registry: ${{ (vars.CI_COMMIT_REF_NAME == "main" && "prod.registry.com") || "staging.registry.com" }}
        replicas: ${{ (vars.CI_COMMIT_REF_NAME == "main" && 5) || 2 }}
```

<a id="configure-ab-testing"></a>

### 配置 A/B 测试

```yaml
configure_job:
  run:
    - name: configure_ab
      func: ./traffic-split
      inputs:
        variants: |
          ${{ [
            {name: "control", use_new_feature: false, weight: 90},
            {name: "experiment", use_new_feature: true, weight: 10}
          ] }}
```
