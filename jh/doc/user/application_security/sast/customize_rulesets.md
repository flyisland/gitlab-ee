<translated>
---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Customize SAST analyzer rules in GitLab by disabling, overriding, or replacing default rules.
title: 自定义规则集
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- [Enabled] 在极狐GitLab 16.2 中支持指定模糊 passthrough 引用。

{{< /history >}}

基于 Semgrep 的 SAST 分析器和极狐GitLab Advanced SAST 分析器各自都有一个 [默认规则集](rules.md)。您可以根据组织的安全需求自定义其规则。例如，您可能希望提高特定规则的严重性级别。

在为基于 Semgrep 的 SAST 分析器编写自定义规则之前，您可以在 [Semgrep Playground](https://semgrep.dev/playground/new) 中以交互方式制作原型并进行测试。
使用 Playground 时，请忽略 **测试代码** 面板中标有星形图标 ({{< icon name="star" >}}) 且提示信息为 **使用 Semgrep Pro 引擎发现的发现** 的发现。
这些发现与极狐GitLab 使用的开源 Semgrep 引擎不兼容。
有关 Semgrep 规则格式的更多信息，请参阅 [学习 Semgrep 语法](https://semgrep.dev/learn)。

<a id="ruleset-glossary"></a>

## 规则集术语

规则
: 一种独立的安全检查或检测模式，用于扫描特定的漏洞。

规则集
: 指定分析器要执行的各个规则的 YAML 格式文件。

规则集配置文件
: 指定要执行哪个规则集以及该规则集是存储在本地还是远程的 TOML 格式文件。文件名为 `sast-ruleset.toml`。

Passthrough
: passthrough 是一种配置源，可从文件、Git 仓库、URL 或内联配置中拉取规则集自定义项。您可以将多个 passthrough 组合成一个链，其中每个 passthrough 都可以覆盖或追加前一个配置。

<a id="rule-customization-options"></a>

## 规则自定义选项

您可以通过禁用规则、覆盖其元数据、替换或添加规则来自定义默认规则集。

下表显示了每种分析器类型可用的自定义选项。

| 自定义方式 | 极狐GitLab Advanced SAST | 极狐GitLab Semgrep | [其他分析器](analyzers.md#official-analyzers) |
|------------------------------|----------------------------|--------------------|------------------------------------------------|
| 禁用默认规则 | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 覆盖默认规则的元数据 | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 替换或添加默认规则 | 支持修改默认的非污点、结构性规则的行为以及文件和原始 passthrough 的应用。其他 passthrough 类型会被忽略。 | 支持完整的 passthrough。 | {{< no >}} |

> [!note]
> 极狐GitLab 的支持范围仅限于 Semgrep 分析器集成和默认规则集。如果您替换或添加默认规则，则必须自行管理可能因此产生的兼容性问题。
> 有关更多详细信息，请参阅 [Semgrep 分析器兼容性文档](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/COMPATIBILITY.md)。

<a id="disable-default-rules"></a>

### 禁用默认规则

您可以禁用任何 SAST 分析器的默认规则。例如，您可能希望根据组织策略排除特定规则。

请参阅以下示例：

- [禁用特定默认极狐GitLab Advanced SAST 规则](#disable-specific-default-gitlab-advanced-sast-rules)
- [禁用其他 SAST 分析器的特定默认规则](#disable-specific-default-rules-of-other-sast-analyzers)

<a id="override-metadata-of-default-rules"></a>

### 覆盖默认规则的元数据

您可以覆盖任何 SAST 分析器默认规则的某些属性。例如，您可能希望根据组织策略覆盖漏洞的严重性，或选择在漏洞报告中显示不同的消息。

请参阅 [覆盖默认规则元数据](#override-default-rule-metadata) 示例。

<a id="replace-or-add-to-the-default-rules"></a>

### 替换或添加默认规则

您可以替换或添加基于 Semgrep 的 SAST 分析器和极狐GitLab Advanced SAST 分析器的默认规则。默认情况下，定义自定义规则集会替换默认规则集。要向默认规则集添加规则，您必须在 [规则集配置文件](#configuration-methods) 中将 `keepdefaultrules` 设置为 `true`。

请参阅以下示例：

- [替换所有默认极狐GitLab Advanced SAST 规则](#replace-all-default-gitlab-advanced-sast-rules)
- [替换或添加 `semgrep` 的默认规则](#replace-or-add-to-the-default-rules-of-semgrep)

<a id="effects-of-ruleset-customization"></a>

### 规则集自定义的效果

下表描述了自定义 SAST 规则集时会发生的情况：

| 操作 | 扫描行为 | 流水线安全选项卡 | 漏洞报告 |
|----------------------------|-----------------------------------------------------------------------------------------------------------------|----------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| 禁用规则 | 分析器仍会扫描漏洞，但扫描完成后会移除该规则的结果。极狐GitLab Advanced SAST 会在初始扫描中排除已禁用的规则。 | 下次流水线运行后，之前在禁用前由该规则检测到的发现不再出现。 | 之前在禁用前由该规则检测到的漏洞会被标记为 [**不再检测**](../vulnerability_report/_index.md#activity-filter)。 |
| 覆盖元数据 | 扫描行为无变化。 | 下次流水线运行后，覆盖前由该规则检测到的发现的元数据会更新。 | 覆盖前由该规则检测到的漏洞的元数据会更新。 |
| 替换默认规则集 | 支持自定义规则集的分析器不再使用默认规则集。 | 替换前由默认规则集中的规则检测到的发现，在下次流水线运行后不再出现。 | 默认规则集中的规则检测到的漏洞会被标记为 [**不再检测**](../vulnerability_report/_index.md#activity-filter)。 |

<a id="configuration-methods"></a>

## 配置方法

您可以通过以下方式提供规则集自定义内容：

本地规则集文件
: 在提交到仓库的 `sast-ruleset.toml` 文件中定义自定义内容。这种方法可以将您的规则集配置与源代码一起置于版本控制之下。

远程规则集文件
: 指定托管您的规则集文件的远程位置（Git 仓库、URL 或其他源）。这种方法使您可以集中管理规则集并在多个项目之间复用。

> [!note]
> 本地 `.gitlab/sast-ruleset.toml` 文件优先于远程规则集文件。

您可以使用 passthrough（可组合成规则集的配置源）来提供自定义内容。

所有规则集自定义都必须符合 [SAST 规则集架构](#schema)。

<a id="use-a-local-ruleset-file"></a>

### 使用本地规则集文件

当您希望将自定义内容与源代码一起存储时，请使用本地规则集文件。本地自定义仅适用于单个项目。

先决条件：

- 项目的维护者或所有者角色。

要创建本地规则集文件：

1. 如果项目的根目录下还没有 `.gitlab` 目录，请创建一个。
1. 在 `.gitlab` 目录中创建名为 `sast-ruleset.toml` 的文件。
1. 将您的自定义规则集添加到 `sast-ruleset.toml` 文件中。
1. 将本地规则集文件提交到仓库。

请参阅本地规则集文件的 [示例](#examples)。

<a id="use-a-remote-ruleset-file"></a>

### 使用远程规则集文件

{{< history >}}

- [Introduced] 在极狐GitLab 16.1 中引入。

{{< /history >}}

当您希望将相同的自定义应用于多个项目时，请使用远程规则集文件。远程规则集文件存储在使用它的项目的仓库之外。

要使用远程规则集文件，请执行以下步骤：

- 创建远程规则集。
- 在每个项目中引用远程规则集。

> [!note]
> 本地 `.gitlab/sast-ruleset.toml` 文件优先于远程规则集文件。

<a id="create-a-remote-ruleset-file"></a>

#### 创建远程规则集文件

创建远程规则集文件作为多个项目的中心规则集。

先决条件：

- 项目的维护者或所有者角色。

要创建远程规则集：

- 在项目的仓库中创建规则集。

  有关规则集文件示例，请参阅 [示例](#examples)。

<a id="reference-the-remote-ruleset-file"></a>

#### 引用远程规则集文件

引用远程规则集文件以将其规则应用于项目。

先决条件：

- 项目的维护者或所有者角色。
- [项目中的远程规则集](#create-a-remote-ruleset-file)。
- 对存储远程规则集的项目的读取权限。例如，使用作业令牌或群组访问令牌。

要在每个项目中引用远程规则集文件，请执行以下操作：

- 设置 CI/CD 变量 `SAST_RULESET_GIT_REFERENCE` 以指定远程规则集文件的位置。

  远程规则集文件引用的格式类似于 [Git URLs](https://git-scm.com/docs/git-clone#_git_urls)，用于指定项目 URI、可选的身份验证和可选的 Git SHA。该变量使用以下格式：

  ```plaintext
  [<AUTH_USER>[:<AUTH_PASSWORD>]@]<PROJECT_PATH>[@<GIT_SHA>]
  ```

下面的示例启用了 SAST 并使用远程规则集文件。在此示例中，文件被提交到 `example-ruleset-project` 的默认分支，路径为 `.gitlab/sast-ruleset.toml`。

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SAST_RULESET_GIT_REFERENCE: "jihulab.com/example-group/example-ruleset-project"
```

有关高级示例，请参阅 [指定私有远程配置示例](#specify-a-private-remote-configuration)。

<a id="troubleshooting-remote-configuration-files"></a>

#### 排查远程配置文件问题

如果远程配置文件似乎未正确应用自定义，可能的原因有：

1. 您的仓库中存在本地 `.gitlab/sast-ruleset.toml` 文件。
   - 默认情况下，即使设置了远程配置作为变量，也会使用本地文件（如果存在）。
   - 您可以将 [SECURE_ENABLE_LOCAL_CONFIGURATION CI/CD 变量](../../../ci/variables/_index.md) 设置为 `false`，以忽略本地配置文件。
1. 身份验证存在问题。
   - 要检查这是否是问题的原因，请尝试从不要求身份验证的仓库位置引用配置文件。

<a id="schema"></a>

## 架构

规则集配置文件使用 TOML 语法。以下章节描述了每个配置元素的结构和有效设置。

<a id="top-level-section"></a>

### 顶级部分

顶级部分包含一个或多个配置部分，定义为 [TOML 表格](https://toml.io/en/v1.0.0#table)。

| 设置 | 描述 |
|---------------|--------------------------------------------------------------|
| `[$analyzer]` | 为分析器声明一个配置部分。名称遵循 [SAST 分析器](analyzers.md#official-analyzers) 列表中定义的名称。 |

配置示例：

```toml
[semgrep]
...
```

避免创建既修改现有规则又构建自定义规则集的配置部分，因为后者会完全替换默认规则。

<a id="analyzer-configuration-section"></a>

### `[$analyzer]` 配置部分

`[$analyzer]` 部分允许您自定义分析器的行为。有效的属性根据您进行的配置类型而有所不同。

| 设置 | 适用于 | 描述 |
|------------------------------------|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `[[$analyzer.ruleset]]` | 默认规则 | 定义对现有规则的修改。 |
| `interpolate` | 所有 | 如果设置为 `true`，您可以在配置中使用 `$VAR` 来评估环境变量。请谨慎使用此功能，以避免泄露密钥或令牌。（默认值：`false`） |
| `description` | Passthroughs | 自定义规则集的描述。 |
| `targetdir` | Passthroughs | 应保留最终配置的目录。如果为空，则会创建一个具有随机名称的目录。该目录可以包含最多 100 MB 的文件。如果 SAST 作业以非 root 用户权限运行，请确保该用户对此目录具有读写权限。 |
| `validate` | Passthroughs | 如果设置为 `true`，则验证每个 passthrough 的内容。验证适用于 `yaml`、`xml`、`json` 和 `toml` 内容。正确的验证器根据 `[[$analyzer.passthrough]]` 部分中 `target` 参数使用的扩展名来识别。（默认值：`false`） |
| `timeout` | Passthroughs | 评估 passthrough 链所花费的最长时间，超时前。超时时间不能超过 300 秒。（默认值：60） |
| `keepdefaultrules` | Passthroughs | 如果设置为 `true`，分析器的默认规则将与定义的 passthrough 一起激活。（默认值：`false`） |

<a id="interpolate"></a>

#### `interpolate`

> [!warning]
> 为降低泄露密钥的风险，请谨慎使用此功能。

以下示例显示了一个使用 `$GITURL` 环境变量访问私有仓库的配置。该变量包含用户名和令牌（例如 `https://user:token@url`），因此它们不会显式存储在配置文件中。

```toml
[semgrep]
  description = "My private Semgrep ruleset"
  interpolate = true

  [[semgrep.passthrough]]
    type  = "git"
    value = "$GITURL"
    ref = "main"
```

<a id="analyzer-ruleset-section"></a>

### `[[$analyzer.ruleset]]` 部分

`[[$analyzer.ruleset]]` 部分针对并修改单个默认规则。您可以为每个分析器定义一个或多个此类部分。

| 设置 | 描述 |
|----------------------------------|-----------------------------------------------------|
| `disable` | 是否应禁用该规则。（默认值：`false`） |
| `[$analyzer.ruleset.identifier]` | 选择要修改的默认规则。 |
| `[$analyzer.ruleset.override]` | 定义该规则的覆盖项。 |

配置示例：

```toml
[semgrep]
  [[semgrep.ruleset]]
    disable = true
    ...
```

<a id="analyzer-ruleset-identifier-section"></a>

### `[$analyzer.ruleset.identifier]` 部分

`[$analyzer.ruleset.identifier]` 部分定义了您要修改的默认规则的标识符。

| 设置 | 描述 |
|---------|---------------------------------------------|
| `type` | 默认规则使用的标识符类型。 |
| `value` | 默认规则使用的标识符值。 |

您可以通过查看分析器产生的 [`gl-sast-report.json`](_index.md#download-a-sast-report) 来查找 `type` 和 `value` 的正确值。
您可以从分析器的 CI 作业中将此文件作为作业产物下载。

例如，下面的代码片段显示了一个具有三个标识符的 `semgrep` 规则发现。JSON 对象中的 `type` 和 `value` 键对应于您应在此部分中提供的值。

```json
...
  "vulnerabilities": [
    {
      "id": "7331a4b7093875f6eb9f6eb1755b30cc792e9fb3a08c9ce673fb0d2207d7c9c9",
      "category": "sast",
      "message": "Key Exchange without Entity Authentication",
      "description": "Audit the use of ssh.InsecureIgnoreHostKey\n",
      ...
      "identifiers": [
        {
          "type": "semgrep_id",
          "name": "gosec.G106-1",
          "value": "gosec.G106-1"
        },
        {
          "type": "cwe",
          "name": "CWE-322",
          "value": "322",
          "url": "https://cwe.mitre.org/data/definitions/322.html"
        },
        {
          "type": "gosec_rule_id",
          "name": "Gosec Rule ID G106",
          "value": "G106"
        }
      ]
    }
    ...
  ]
...
```

配置示例：

```toml
[semgrep]
  [[semgrep.ruleset]]
    [semgrep.ruleset.identifier]
      type = "semgrep_id"
      value = "gosec.G106-1
    ...
```

<a id="analyzer-ruleset-override-section"></a>

### `[$analyzer.ruleset.override]` 部分

`[$analyzer.ruleset.override]` 部分允许您覆盖默认规则的属性。

| 设置 | 描述 |
|---------------|---------------------------------------------------------------------------------------------------------|
| `description` | 有关问题的详细描述。 |
| `message` | （已弃用）问题的描述。 |
| `name` | 规则的名称。 |
| `severity` | 规则的严重性。有效选项为：`Critical`、`High`、`Medium`、`Low`、`Unknown`、`Info` |

> [!note]
> 尽管 `message` 由分析器填充，但它已经 [被弃用](https://gitlab.com/gitlab-org/security-products/analyzers/report/-/blob/1d86d5f2e61dc38c775fb0490ee27a45eee4b8b3/vulnerability.go#L22)，取而代之的是 `name` 和 `description`。

配置示例：

```toml
[semgrep]
  [[semgrep.ruleset]]
    [semgrep.ruleset.override]
      severity = "Critical"
      name = "Command injection"
    ...
```

<a id="analyzer-passthrough-section"></a>

### `[[$analyzer.passthrough]]` 部分

> [!note]
> Passthrough 配置仅适用于 [基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)。

`[[$analyzer.passthrough]]` 部分允许您为分析器构建自定义配置。您最多可以为每个分析器定义 20 个此类部分。passthrough 组成一个 *passthrough 链*，该链评估成一个完整的配置，用于替换分析器的默认规则。

passthrough 按顺序评估。链中后面列出的 passthrough 具有更高的优先级，并且可以覆盖或追加先前 passthrough 生成的数据（取决于 `mode`）。这在您需要使用或修改现有配置的情况下非常有用。

单个 passthrough 生成的配置大小限制为 10 MB。

| 设置 | 适用于 | 描述 |
|-------------|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `type` | 所有 | 可选 `file`、`raw`、`git` 或 `url`。 |
| `target` | 所有 | 包含由 passthrough 评估写入的数据的目标文件。如果为空，则使用随机文件名。 |
| `mode` | 所有 | 如果 `overwrite`，则覆盖 `target` 文件。如果 `append`，则将新内容追加到 `target` 文件。`git` 类型仅支持 `overwrite`。（默认值：`overwrite`） |
| `ref` | `type = "git"` | 包含要拉取的分支名称、标签或 SHA |
| `subdir` | `type = "git"` | 用于选择 Git 仓库的子目录作为配置源。 |
| `value` | 所有 | 对于 `file`、`url` 和 `git` 类型，定义文件或 Git 仓库的位置。对于 `raw` 类型，包含内联配置。 |
| `validator` | 所有 | 用于在评估 passthrough 后显式调用目标文件上的验证器（`xml`、`yaml`、`json`、`toml`）。 |

<a id="passthrough-types"></a>

#### Passthrough 类型

| 类型 | 描述 |
|--------|------------------------------------------------------|
| `file` | 使用 Git 仓库中存在的文件。 |
| `raw` | 以内联方式提供配置。 |
| `git` | 从远程 Git 仓库拉取配置。 |
| `url` | 使用 HTTP 获取配置。 |

> [!warning]
> 当使用带有 YAML 代码片段的 `raw` passthrough 时，建议将 `sast-ruleset.toml` 文件中的所有缩进格式化为空格。YAML 规范要求使用空格而不是制表符，除非缩进相应表示，否则分析器将无法解析您的自定义规则集。

<a id="examples"></a>

## 示例

以下示例展示了如何针对常见场景自定义规则集。使用架构部分来理解每个示例中使用的配置选项。

<a id="replace-all-default-gitlab-advanced-sast-rules"></a>

### 替换所有默认极狐GitLab Advanced SAST 规则

</translated>
使用以下自定义规则集配置，极狐GitLab Advanced SAST 分析器的默认规则集将被替换为存储在待扫描仓库中名为 `my-gitlab-advanced-sast-rules.yml` 文件中的自定义规则集。

```yaml
# my-gitlab-advanced-sast-rules.yml
---
rules:
- id: my-custom-rule
  pattern: print("Hello World")
  message: |
    未经授权使用 Hello World。
  severity: ERROR
  languages:
  - python
```

```toml
[gitlab-advanced-sast]
  description = "我的 Semgrep 自定义规则集"

  [[gitlab-advanced-sast.passthrough]]
    type  = "file"
    value = "my-gitlab-advanced-sast-rules.yml"
```

### 禁用特定的默认 极狐GitLab Advanced SAST 规则

在此示例中，根据以下条件禁用特定的默认规则：

- CWE 标识符，用于标识一整类漏洞。
- 极狐GitLab Advanced SAST 规则 ID，用于标识 极狐GitLab Advanced SAST 中使用的特定检测策略。
- 关联的 Semgrep 规则 ID，该 ID 包含在 极狐GitLab Advanced SAST 发现中以确保兼容性。
  此附加元数据允许在两个分析器在同一位置生成相似发现时自动转换发现。

这些标识符显示在每个漏洞的[漏洞详情](../vulnerabilities/_index.md)中。您也可以在[可下载的 SAST 报告产物](_index.md#download-a-sast-report)中查看每个标识符及其关联的 `type`。

```toml
[gitlab-advanced-sast]
  [[gitlab-advanced-sast.ruleset]]
    disable = true
    [gitlab-advanced-sast.ruleset.identifier]
      type = "cwe"
      value = "89"

  [[gitlab-advanced-sast.ruleset]]
    disable = true
    [gitlab-advanced-sast.ruleset.identifier]
      type = "gitlab-advanced-sast_id"
      value = "java-spring-csrf-unrestricted-requestmapping-atomic"

  [[gitlab-advanced-sast.ruleset]]
    disable = true
    [gitlab-advanced-sast.ruleset.identifier]
      type = "semgrep_id"
      value = "java_cookie_rule-CookieHTTPOnly"
```

### 禁用其他 SAST 分析器的特定默认规则

使用以下自定义规则集配置，以下默认规则将从报告中省略：

- `semgrep` 规则，其 `semgrep_id` 为 `gosec.G106-1` 或 `cwe` 为 `322`。
- `sobelow` 规则，其 `sobelow_rule_id` 为 `sql_injection`。
- `flawfinder` 规则，其 `flawfinder_func_name` 为 `memcpy`。

```toml
[semgrep]
  [[semgrep.ruleset]]
    disable = true
    [semgrep.ruleset.identifier]
      type = "semgrep_id"
      value = "gosec.G106-1"

  [[semgrep.ruleset]]
    disable = true
    [semgrep.ruleset.identifier]
      type = "cwe"
      value = "322"

[sobelow]
  [[sobelow.ruleset]]
    disable = true
    [sobelow.ruleset.identifier]
      type = "sobelow_rule_id"
      value = "sql_injection"

[flawfinder]
  [[flawfinder.ruleset]]
    disable = true
    [flawfinder.ruleset.identifier]
      type = "flawfinder_func_name"
      value = "memcpy"
```

### 覆盖默认规则元数据

使用以下自定义规则集配置，通过 `semgrep` 发现的、类型为 `CWE` 且值为 `322` 的漏洞，其严重性将被覆盖为 `Critical`。

```toml
[semgrep]
  [[semgrep.ruleset]]
    [semgrep.ruleset.identifier]
      type = "cwe"
      value = "322"
    [semgrep.ruleset.override]
      severity = "Critical"
```

### 替换或添加到 `semgrep` 的默认规则

使用以下自定义规则集配置，`semgrep` 分析器的默认规则集将被替换为存储在待扫描仓库中名为 `my-semgrep-rules.yml` 文件中的自定义规则集。

```yaml
# my-semgrep-rules.yml
---
rules:
- id: my-custom-rule
  pattern: print("Hello World")
  message: |
    未经授权使用 Hello World。
  severity: ERROR
  languages:
  - python
```

```toml
[semgrep]
  description = "我的 Semgrep 自定义规则集"

  [[semgrep.passthrough]]
    type  = "file"
    value = "my-semgrep-rules.yml"
```

### 为 `semgrep` 使用 passthrough 链构建自定义配置

使用以下自定义规则集配置，`semgrep` 分析器的默认规则集将被替换为通过评估四个 passthrough 链生成的自定义规则集。每个 passthrough 生成一个文件并写入容器内的 `/sgrules` 目录。设置 `timeout` 为 60 秒，以防任何 Git 远程无响应。

此示例展示了不同的 passthrough 类型：

- 两个 `git` passthrough，第一个从 `myrules` Git 仓库拉取 `develop` 分支，第二个从 `sast-rules` 仓库拉取修订版 `97f7686`，并仅考虑 `go` 子目录中的文件。
  - `sast-rules` 条目具有更高的优先级，因为它出现在配置的后面。
  - 如果两个检出之间存在文件名冲突，`sast-rules` 仓库的文件将覆盖 `myrules` 仓库的文件。
- 一个 `raw` passthrough，将其 `value` 写入 `/sgrules/insecure.yml`。
- 一个 `url` passthrough，获取托管在某个 URL 的配置并将其写入 `/sgrules/gosec.yml`。

之后，使用位于 `/sgrules` 下的最终配置调用 Semgrep。

```toml
[semgrep]
  description = "我的 Semgrep 自定义规则集"
  targetdir = "/sgrules"
  timeout = 60

  [[semgrep.passthrough]]
    type  = "git"
    value = "https://gitlab.com/user/myrules.git"
    ref = "develop"

  [[semgrep.passthrough]]
    type  = "git"
    value = "https://gitlab.com/gitlab-org/secure/gsoc-sast-vulnerability-rules/playground/sast-rules.git"
    ref = "97f7686db058e2141c0806a477c1e04835c4f395"
    subdir = "go"

  [[semgrep.passthrough]]
    type  = "raw"
    target = "insecure.yml"
    value = """
rules:
- id: "insecure"
  patterns:
    - pattern: "func insecure() {...}"
  message: |
    检测到不安全的函数 insecure
  metadata:
    cwe: "CWE-200: 向未授权角色暴露敏感信息"
  severity: "ERROR"
  languages:
    - "go"
"""

  [[semgrep.passthrough]]
    type  = "url"
    value = "https://semgrep.dev/c/p/gosec"
    target = "gosec.yml"
```

### 配置链中 passthrough 的模式

您可以选择如何处理链中 passthrough 之间发生的文件名冲突。默认行为是覆盖同名现有文件，但您也可以选择 `mode = append` 将后续文件的内容追加到较早文件之后。

`append` 模式仅适用于 `file`、`url` 和 `raw` passthrough 类型。

使用以下自定义规则集配置，两个 `raw` passthrough 用于迭代构建 `/sgrules/my-rules.yml` 文件，然后将其作为规则集提供给 Semgrep。每个 passthrough 向规则集追加一条规则。第一个 passthrough 负责根据 [Semgrep 规则语法](https://semgrep.dev/docs/writing-rules/rule-syntax) 初始化顶级 `rules` 对象。

```toml
[semgrep]
  description = "我的 Semgrep 自定义规则集"
  targetdir = "/sgrules"
  validate = true

  [[semgrep.passthrough]]
    type  = "raw"
    target = "my-rules.yml"
    value = """
rules:
- id: "insecure"
  patterns:
    - pattern: "func insecure() {...}"
  message: |
    检测到不安全的函数 'insecure'
  metadata:
    cwe: "..."
  severity: "ERROR"
  languages:
    - "go"
"""

  [[semgrep.passthrough]]
    type  = "raw"
    mode  = "append"
    target = "my-rules.yml"
    value = """
- id: "secret"
  patterns:
    - pattern-either:
        - pattern: '$MASK = "..."'
    - metavariable-regex:
        metavariable: "$MASK"
        regex: "(password|pass|passwd|pwd|secret|token)"
  message: |
    使用硬编码密码
  metadata:
    cwe: "..."
  severity: "ERROR"
  languages:
    - "go"
"""
```

```yaml
# /sgrules/my-rules.yml
rules:
- id: "insecure"
  patterns:
    - pattern: "func insecure() {...}"
  message: |
    检测到不安全的函数 'insecure'
  metadata:
    cwe: "..."
  severity: "ERROR"
  languages:
    - "go"
- id: "secret"
  patterns:
    - pattern-either:
        - pattern: '$MASK = "..."'
    - metavariable-regex:
        metavariable: "$MASK"
        regex: "(password|pass|passwd|pwd|secret|token)"
  message: |
    使用硬编码密码
  metadata:
    cwe: "..."
  severity: "ERROR"
  languages:
    - "go"
```

### 指定私有远程配置

以下示例启用 SAST 并使用共享规则集自定义文件：

- 该文件从需要身份验证的私有项目下载。此示例使用安全存储在 CI/CD 变量中的[群组访问令牌](../../group/settings/group_access_tokens.md)。
- 该文件在特定的 Git 提交 SHA 处检出，而不是默认分支。

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SAST_RULESET_GIT_REFERENCE: "oauth2:$GROUP_ACCESS_TOKEN@gitlab.com/example-group/example-ruleset-project@c8ea7e3ff126987fb4819cc35f2310755511c2ab"
```

### 演示项目

浏览演示了其中一些配置选项的[演示项目](https://jihulab.com/gitlab-cn/security-products/demos/SAST-analyzer-configurations)。

其中许多项目演示了如何使用远程规则集覆盖或禁用规则，并按它们所对应的分析器分组。

您也可以观看设置远程规则集的视频演示：