---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Moa 表达式语言
---

Moa 是一种表达式语言，用于在作业执行期间动态构造值。表达式使用 `${{ }}` 分隔符，并用于极狐GitLab Functions 和作业输入。

Moa 支持字符串操作、算术运算、比较、逻辑运算、属性访问和函数调用。

<a id="differences-from-ci-cd-expressions"></a>

与 CI/CD 表达式的区别

极狐GitLab 有三种表达式语法，在流水线生命周期的不同阶段服务于不同目的。

- [规则](../yaml/_index.md#rules) 在 `rules:` 关键字中使用自己的表达式语法来控制作业的包含。它们在流水线创建期间评估，并支持对 CI/CD 变量进行比较和模式匹配，但不能执行算术运算或访问运行时状态。
- CI/CD 表达式使用 `$[[ ]]` 语法，并在流水线创建期间、任何作业运行之前进行评估。这些表达式为 [CI/CD 输入](../inputs/_index.md)、[矩阵值](../yaml/matrix_expressions.md) 和 [组件输入](../components/_index.md) 执行值替换。它们不能执行算术运算、比较或逻辑运算，也无法访问运行时状态。更多信息，请参见 [CI/CD 表达式](../yaml/expressions.md)。
- Moa 使用 `${{ }}` 语法，并在作业执行期间由 runner 评估。Moa 是一种完整的表达式语言，具有运算符、数据结构和函数调用。

这三种语法可以在同一个流水线中共存。包含极狐GitLab Functions 的 CI/CD 组件可能会使用全部三种：

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

<a id="context-reference"></a>

上下文引用

表达式中可用的值取决于表达式使用的位置。

| 上下文 | 可用位置 | 类型 | 评估时机 | 描述 |
|-------|---------|------|---------|------|
| `job.inputs` | 作业配置：`script`、`before_script`、`after_script`、`artifacts`、`cache`、`image`、`services` | 对象 | 当 Runner 接收到作业时 | 为作业定义的输入值。使用 `job.inputs.<name>` 访问单个变量。 |
| `env` | 极狐GitLab Functions | 对象 | 函数运行前 | 函数可用的环境变量。使用 `env.<name>` 访问单个变量。 |
| `inputs` | 极狐GitLab Functions | 对象 | 函数运行前 | 传递给函数的输入值。使用 `inputs.<name>` 访问单个输入。 |
| `vars` | 极狐GitLab Functions | 对象 | 函数运行前 | 从 CI 作业传递的作业变量。使用 `vars.<name>` 访问单个变量。 |
| `steps` | 极狐GitLab Functions | 对象 | 函数运行前 | 当前函数中先前执行的步骤的结果。使用 `steps.<step_name>.outputs.<output_name>` 访问步骤的输出。 |
| `export_file` | 极狐GitLab Functions | 字符串 | 函数运行前 | 函数可以写入环境变量以导出到后续步骤的文件路径。 |
| `output_file` | 极狐GitLab Functions | 字符串 | 函数运行前 | 函数写入其输出值的文件路径。 |
| `func_dir` | 极狐GitLab Functions | 字符串 | 函数运行前 | 包含函数定义文件的目录路径。用于引用与函数捆绑的文件。 |
| `work_dir` | 极狐GitLab Functions | 字符串 | 函数运行前 | 当前执行的工作目录路径。 |

<a id="template-syntax"></a>

模板语法

<a id="interpolation"></a>

插值

将表达式包裹在 `${{ }}` 中以对其进行求值：

```yaml
script:
  - echo "Hello, ${{ job.inputs.name }}"
```

当文本包围表达式时，结果始终转换为字符串。单个值中可以出现多个表达式：

```yaml
script:
  - echo "${{ job.inputs.greeting }}, ${{ job.inputs.name }}!"
```

<a id="native-type-passthrough"></a>

原生类型透传

当 `${{ expression }}` 是整个值且没有周围文本时，表达式返回其原生类型。使用原生类型表达式在步骤之间传递非字符串值（如数字、布尔值、数组和对象），而无需将它们转换为字符串。

```yaml
inputs:
  count: ${{ steps.previous.outputs.total }}
```

在此示例中，如果 `total` 是一个数字，则 `count` 接收到一个数字，而不是字符串表示。

<a id="escape-moa-expressions"></a>

转义 Moa 表达式

要在文本中包含字面量的 `${{` 而不触发插值，请使用反斜杠进行转义：

```yaml
script:
  - echo "Use \${{ to start an expression"
```

此命令输出文本 `Use ${{ to start an expression` 而不进行求值。

<a id="literals"></a>

字面量

<a id="null"></a>

Null

关键字 `null` 表示值的缺失。

```yaml
${{ null }}
```

<a id="booleans"></a>

布尔值

关键字 `true` 和 `false` 表示布尔值。

```yaml
${{ true }}
${{ false }}
```

<a id="numbers"></a>

数字

数字是 IEEE 754 双精度浮点值，具有 53 位有效数字精度。支持整数、小数和科学记数法。

```yaml
${{ 42 }}
${{ 3.14 }}
${{ 1.5e3 }}
${{ 2E-4 }}
```

<a id="strings"></a>

字符串

用双引号或单引号括起字符串。两种引号类型处理转义序列和模板表达式的方式不同。

双引号字符串支持模板表达式和完整的转义序列集：

| 序列 | 含义 |
|------|------|
| `\\` | 反斜杠 |
| `\"` | 双引号 |
| `\n` | 换行 |
| `\r` | 回车 |
| `\t` | 制表符 |
| `\a` | 响铃 |
| `\b` | 退格 |
| `\f` | 换页 |
| `\v` | 垂直制表符 |
| `\/` | 正斜杠 |
| `\uXXXX` | Unicode 码点 |
| `\${{` | 字面量 `${{`（防止插值） |

双引号字符串内的模板表达式 (`${{ }}`) 会被求值并插入到字符串中。

单引号字符串是原始字符串字面量，解释最少。单引号字符串内的模板表达式不会被求值。仅支持两种转义序列：

| 序列 | 含义 |
|------|------|
| `\\` | 反斜杠 |
| `\'` | 单引号 |

```yaml
${{ "Hello\nWorld" }}
${{ 'It\'s a string' }}
${{ 'Literal ${{ not evaluated }}' }}
```

<a id="identifiers"></a>

标识符

标识符引用表达式上下文中的值。标识符以字母或下划线开头，可以包含字母、数字和下划线。标识符区分大小写：`foo`、`Foo` 和 `FOO` 是三个不同的标识符。

```yaml
${{ env }}
${{ my_variable }}
```

标识符根据可用上下文进行解析。有关每个上下文中可用的值，请参见[上下文引用](#context-reference)。

当标识符引用上下文对象时，将返回整个对象。例如，`${{ vars }}` 将所有作业变量作为一个对象返回。

<a id="operators"></a>

运算符

<a id="arithmetic-operators"></a>

算术运算符

算术运算符作用于数字。`+` 运算符也可以连接字符串。运算符不执行隐式类型转换，因此 `"hello" + 42` 会导致错误。

| 运算符 | 描述 | 示例 | 结果 |
|-------|------|------|------|
| `+` | 加法 | `${{ 2 + 3 }}` | `5` |
| `+` | 连接 | `${{ "a" + "b" }}` | `"ab"` |
| `-` | 减法 | `${{ 10 - 4 }}` | `6` |
| `*` | 乘法 | `${{ 3 * 4 }}` | `12` |
| `/` | 除法 | `${{ 10 / 3 }}` | `3.333...` |
| `%` | 取模（截断除法） | `${{ 10 % 3 }}` | `1` |

除以零会导致错误。

<a id="comparison-operators"></a>

比较运算符

比较运算符返回布尔值。

| 运算符 | 描述 | 示例 | 结果 |
|-------|------|------|------|
| `==` | 等于 | `${{ 1 == 1 }}` | `true` |
| `!=` | 不等于 | `${{ 1 != 2 }}` | `true` |
| `<` | 小于 | `${{ 1 < 2 }}` | `true` |
| `<=` | 小于或等于 | `${{ 2 <= 2 }}` | `true` |
| `>` | 大于 | `${{ 3 > 2 }}` | `true` |
| `>=` | 大于或等于 | `${{ 3 >= 3 }}` | `true` |

不同类型的值按类型进行比较，因此 `1 == "1"` 求值为 `false`。相同类型的值遵循以下比较规则：

- 数字：数值比较。
- 字符串：字典序比较（UTF-8 字节顺序）。
- 布尔值：`false` 小于 `true`。
- 数组：逐元素比较。
- 对象：按长度比较，然后按键比较，最后按值比较。键的顺序无关紧要。
- Null：`null` 等于 `null`。

<a id="logical-operators"></a>

逻辑运算符

逻辑运算符使用短路求值，并返回其操作数之一，不一定是布尔值。此行为类似于 JavaScript 的 `&&` 和 `||` 运算符。

| 运算符 | 描述 | 行为 |
|-------|------|------|
| `\|\|` | 逻辑或 | 如果左操作数为真，则返回左操作数；否则求值并返回右操作数。 |
| `&&` | 逻辑与 | 如果左操作数为假，则返回左操作数；否则求值并返回右操作数。 |
| `!` | 逻辑非 | 如果操作数为假，则返回 `true`；如果为真，则返回 `false`。 |

`||` 运算符用于提供默认值：

```yaml
${{ inputs.name || "default" }}
```

如果 `inputs.name` 是非空字符串，则按原样返回。如果为空或 null，则返回 `"default"`。

<a id="unary-operators"></a>

一元运算符

| 运算符 | 描述 | 示例 | 结果 |
|-------|------|------|------|
| `+` | 一元加 | `${{ +5 }}` | `5` |
| `-` | 一元负 | `${{ -5 }}` | `-5` |
| `!` | 逻辑非 | `${{ !true }}` | `false` |

<a id="operator-precedence"></a>

运算符优先级

运算符按从最高优先级到最低优先级列出。同一行的运算符具有相同的优先级。所有二元运算符都是左结合的。

| 优先级 | 运算符 |
|-------|--------|
| 7（最高） | `.`、`[]`、`()` |
| 6 | `+`、`-`、`!` |
| 5 | `*`、`/`、`%` |
| 4 | `+`、`-` |
| 3 | `==`、`!=`、`<`、`<=`、`>`、`>=` |
| 2 | `&&` |
| 1（最低） | `\|\|` |

使用括号覆盖优先级：

```yaml
${{ (1 + 2) * 3 }}
```

<a id="data-structures"></a>

数据结构

<a id="arrays"></a>

数组

使用方括号表示法创建数组。元素可以是任何类型，并且可以混合类型。可以使用尾随逗号。

```yaml
${{ [1, 2, 3] }}
${{ ["a", 1, true, null] }}
${{ [] }}
```

<a id="objects"></a>

对象

使用花括号表示法创建对象。键必须求值为字符串。值可以是任何类型。允许尾随逗号。

```yaml
${{ {name: "runner", version: 1} }}
${{ {"string-key": true} }}
${{ {} }}
```

用作对象键的裸标识符被视为字符串字面量，而不是变量引用。要将变量用作键，请将其括在括号中：

```yaml
${{ {name: "Alice"} }}           # "name" is the string "name", not a variable reference
${{ {(obj.prop): "value"} }}     # key is the value of obj.prop, which must be a string
```

<a id="property-access"></a>

属性访问

<a id="dot-notation"></a>

点表示法

使用点表示法访问对象属性：

```yaml
${{ env.HOME }}
${{ steps.build.outputs.artifact_path }}
```

<a id="bracket-notation"></a>

方括号表示法

通过索引访问数组元素，或通过字符串键访问对象属性：

```yaml
${{ my_array[0] }}
${{ my_object["property-name"] }}
```

当属性名包含连字符等特殊字符时，必须使用方括号表示法。

<a id="chaining"></a>

链式调用

链式属性访问和函数调用：

```yaml
${{ steps.build.outputs.items[0] }}
```

<a id="function-calls"></a>

函数调用

通过名称和括号调用函数：

```yaml
${{ str(42) }}
${{ num("3.14") }}
```

<a id="truthiness"></a>

真值性

逻辑运算符和 `!` 运算符使用以下真值性规则：

| 类型 | 真值条件 | 假值条件 |
|------|---------|---------|
| 布尔值 | `true` | `false` |
| 字符串 | 长度大于 `0` | 空字符串 `""` |
| 数字 | 非 `0` | `0` |
| 数组 | 长度大于 `0` | 空数组 `[]` |
| 对象 | 长度大于 `0` | 空对象 `{}` |
| Null | 从不 | 总是 |

<a id="built-in-functions"></a>

内置函数

<a id="strvalue"></a>

str(value)

将任何值转换为其字符串表示形式。

```yaml
${{ str(42) }}       # "42"
${{ str(true) }}     # "true"
${{ str(null) }}     # "<null>"
```

<a id="numvalue"></a>

num(value)

将字符串转换为数字。字符串必须是有效的数字表示。

```yaml
${{ num("42") }}     # 42
${{ num("3.14") }}   # 3.14
```

<a id="boolvalue"></a>

bool(value)

根据其[真值性](#truthiness)将任何值转换为布尔值。

```yaml
${{ bool("hello") }}  # true
${{ bool("") }}       # false
${{ bool(0) }}        # false
${{ bool(1) }}        # true
```

<a id="reserved-words"></a>

保留字

以下单词是保留字，不能用作标识符。它们被保留用于未来可能的语言特性。

`array`、`as`、`break`、`case`、`const`、`continue`、`default`、`else`、`fallthrough`、`float`、`for`、`func`、`function`、`goto`、`if`、`import`、`in`、`int`、`let`、`loop`、`map`、`namespace`、`number`、`object`、`package`、`range`、`return`、`string`、`struct`、`switch`、`type`、`var`、`void`、`while`

关键字 `null`、`true` 和 `false` 也作为字面量值被保留。

<a id="examples"></a>

示例

<a id="deploy-with-strategy-selection"></a>

带策略选择的部署

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

来自布尔作业输入的条件标志

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

从作业变量构建镜像引用

```yaml
build_job:
  run:
    - name: build
      func: ./docker-build
      inputs:
        image: ${{ vars.CI_REGISTRY + "/" + vars.CI_PROJECT_PATH + ":" + vars.CI_PIPELINE_IID }}
```

<a id="continue-gate"></a>

继续门控

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

版本管理

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

环境特定配置

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

配置 A/B 测试

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