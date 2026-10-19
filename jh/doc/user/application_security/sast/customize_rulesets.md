---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中通过禁用、覆盖或替换默认规则来自定义 SAST 分析器规则。
title: 自定义规则集
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

基于 Semgrep 的 SAST 分析器和极狐GitLab Advanced SAST 分析器各自都有一个
[默认规则集](rules.md)。您可以自定义这些规则，以满足组织的安全要求。例如，您可能希望提高某个特定规则的严重级别。

在为基于 Semgrep 的 SAST 分析器编写自定义规则之前，您可以在 [Semgrep Playground](https://semgrep.dev/playground/new)中以交互方式对规则进行原型设计和测试。
使用 Playground 时，请忽略 **测试代码** 面板中带有星形图标 ({{< icon name="star" >}}) 且工具提示为 **由 Semgrep Pro Engine 检出的发现项**的发现项。
这些发现项与极狐GitLab 使用的开源 Semgrep 引擎不兼容。
有关 Semgrep 规则格式的更多信息，请参阅 [Learn Semgrep Syntax](https://semgrep.dev/learn)。

<a id="ruleset-glossary"></a>

## 规则集术语表

规则
: 一项单独的安全检查或检测模式，用于扫描特定的漏洞。

规则集
: YAML 格式的文件，用于指定分析器要执行的各项规则。

规则集配置文件
: TOML 格式的文件，用于指定要执行的规则集以及该规则集存储在本地还是远程。文件名为 `sast-ruleset.toml`。

透传
: 透传是一种配置来源，可从文件、Git 代码仓库、URL 或内联配置中获取规则集自定义内容。您可以将多个透传组合成一个链，其中每个透传都可以覆盖或追加到前一个配置。

<a id="rule-customization-options"></a>

## 规则自定义选项

您可以通过禁用规则、覆盖规则元数据，或替换、添加规则来自定义默认规则集。

下表显示了每种分析器类型可用的自定义选项。

| 自定义                          | 极狐GitLab Advanced SAST                                                                                                                                             | 极狐GitLab Semgrep             | [其他分析器](analyzers.md#official-analyzers)和 [IaC 扫描](../iac_scanning/_index.md) |
|----------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------|----------------------------------------------------|
| 禁用默认规则               | {{< yes >}}                                                                                                                                                      | {{< yes >}}                | {{< yes >}}                                        |
| 覆盖默认规则的元数据  | {{< yes >}}                                                                                                                                                      | {{< yes >}}                | {{< yes >}}                                        |
| 替换或添加默认规则 | 支持修改默认的非污点、结构化规则的行为，以及应用文件和原始透传。其他透传类型会被忽略。 | 支持完整的透传。 | {{< no >}}                                         |

> [!note]
> 极狐GitLab 的支持范围仅限于 Semgrep 分析器集成和默认规则集。如果您替换或添加默认规则，则必须自行管理由此可能产生的兼容性问题。
> 更多详情，请参阅 [Semgrep 分析器兼容性文档](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/COMPATIBILITY.md)。

<a id="disable-default-rules"></a>

### 禁用默认规则

您可以禁用任何 SAST 分析器的默认规则。例如，您可能希望根据组织策略排除某个特定规则。

请参阅以下示例：

- [禁用特定的默认极狐GitLab Advanced SAST 规则](#disable-specific-default-gitlab-advanced-sast-rules)
- [禁用其他 SAST 分析器的特定默认规则](#disable-specific-default-rules-of-other-sast-analyzers)

<a id="override-metadata-of-default-rules"></a>

### 覆盖默认规则的元数据

您可以覆盖任何 SAST 分析器默认规则的某些属性。例如，您可能希望根据组织策略覆盖漏洞的严重级别，或选择在漏洞报告中显示不同的消息。

有关示例，请参阅[覆盖默认规则元数据](#override-default-rule-metadata)。

<a id="replace-or-add-to-the-default-rules"></a>

### 替换或添加默认规则

您可以替换或添加基于 Semgrep 的 SAST 分析器和极狐GitLab Advanced SAST 分析器的默认规则。默认情况下，定义自定义规则集会替换默认规则集。要添加到默认规则集，您必须在[规则集配置文件](#configuration-methods)中将 `keepdefaultrules` 设置为 `true`。

请参阅以下示例：

- [替换所有默认极狐GitLab Advanced SAST 规则](#replace-all-default-gitlab-advanced-sast-rules)
- [替换或添加 `semgrep`的默认规则](#replace-or-add-to-the-default-rules-of-semgrep)

<a id="effects-of-ruleset-customization"></a>

### 规则集自定义的影响

下表描述了自定义 SAST 规则集时会发生的情况：

| 操作                     | 扫描行为                                                                                                                                                               | 流水线安全标签页                                                                                                      | 漏洞报告                                                                                                                                   |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| 禁用规则             | 分析器仍会扫描该漏洞，但该规则的结果会在扫描完成后被移除。极狐GitLab Advanced SAST 会在初始扫描中排除已禁用的规则。 | 在规则被禁用之前由该规则检测到的发现项，在下次流水线运行后不再出现。                        | 在规则被禁用之前由该规则检测到的漏洞会被标记为[**不再检测到**](../vulnerability_report/_index.md#activity-filter)。 |
| 覆盖元数据          | 扫描行为不变。                                                                                                                                                 | 在规则被覆盖之前由该规则检测到的发现项的元数据，会在下次流水线运行后更新。               | 在规则被覆盖之前由该规则检测到的漏洞的元数据会被更新。                                                                 |
| 替换默认规则集 | 支持自定义规则集的分析器不再使用默认规则集。                                                                                               | 在默认规则集被替换之前由其规则检测到的发现项，在下次流水线运行后不再出现。 | 由默认规则集中的规则检测到的漏洞会被标记为[**不再检测到**](../vulnerability_report/_index.md#activity-filter)。 |

<a id="configuration-methods"></a>

## 配置方法

您可以通过以下方式提供规则集自定义内容：

本地规则集文件
: 在提交到您的代码仓库的 `sast-ruleset.toml` 文件中定义自定义内容。这种方式可将规则集配置与源代码一起纳入版本控制。

远程规则集文件
: 指定托管规则集文件的远程位置（Git 代码仓库、URL 或其他来源）。这种方式可让您集中管理规则集，并在多个项目中重复使用。

> [!note]
> 本地 `.gitlab/sast-ruleset.toml` 文件优先于远程规则集文件。

您可以通过透传来提供自定义内容，透传是一种配置来源，可以组合成一个规则集。

所有规则集自定义都必须符合 [SAST 规则集架构](#schema)。

<a id="use-a-local-ruleset-file"></a>

### 使用本地规则集文件

当您希望将自定义内容与源代码一起存储时，请使用本地规则集文件。本地自定义仅适用于单个项目。

先决条件：

- 项目的维护者或所有者角色。

要创建本地规则集文件：

1. 在项目根目录下创建一个 `.gitlab` 目录（如果尚不存在）。
1. 在 `.gitlab` 目录中创建一个名为 `sast-ruleset.toml`的文件。
1. 将您的自定义规则集添加到 `sast-ruleset.toml` 文件中。
1. 将本地规则集文件提交到代码仓库。

请参阅本地规则集文件的[示例](#examples)。

<a id="use-a-remote-ruleset-file"></a>

### 使用远程规则集文件

当您希望将相同的自定义内容应用于多个项目时，请使用远程规则集文件。远程规则集文件存储在项目代码仓库之外。

要使用远程规则集文件，请执行以下操作：

- 创建远程规则集。
- 从每个项目引用该远程规则集。

本地 `.gitlab/sast-ruleset.toml` 文件优先于远程规则集文件。

> [!warning]
> 设置 `SAST_RULESET_GIT_REFERENCE` 会将项目的信任边界扩展到所引用的代码仓库。该代码仓库的维护者可以随时更改规则集配置，包括启用 [`interpolate`](#interpolate) 以在 SAST 作业中求值环境变量。请仅引用您控制的或由您信任的团队管理的代码仓库中的规则集。不要将 `SAST_RULESET_GIT_REFERENCE` 指向公共或不受控制的代码仓库。为防止静默更改，请将引用固定到特定的 Git SHA，这样除非在您的项目中显式更新，否则规则集无法更改。

<a id="create-a-remote-ruleset-file"></a>

#### 创建远程规则集文件

创建一个远程规则集文件，作为多个项目的中心规则集。

先决条件：

- 项目的维护者或所有者角色。

要创建远程规则集：

- 在项目的代码仓库中创建规则集。

  有关规则集文件示例，请参阅[示例](#examples)。

<a id="reference-the-remote-ruleset-file"></a>

#### 引用远程规则集文件

引用远程规则集文件，以将其规则应用于项目。

先决条件：

- 项目的维护者或所有者角色。
- [项目中的远程规则集](#create-a-remote-ruleset-file)。
- 对存储远程规则集的项目的读取权限。例如，使用作业令牌或群组访问令牌。

要在每个项目中引用远程规则集文件，请执行以下操作：

- 设置 CI/CD 变量 `SAST_RULESET_GIT_REFERENCE`，以指定远程规则集文件的位置。

  远程规则集文件引用使用类似于
  [Git URL](https://git-scm.com/docs/git-clone#_git_urls)的格式来指定项目 URI、可选的身份验证和可选的 Git SHA。该变量使用以下格式：

  ```plaintext
  [<AUTH_USER>[:<AUTH_PASSWORD>]@]<PROJECT_PATH>[@<GIT_SHA>]
  ```

以下示例启用 SAST 并使用远程规则集文件。在此示例中，该文件提交在 `example-ruleset-project`的默认分支上，路径为
`.gitlab/sast-ruleset.toml`。

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SAST_RULESET_GIT_REFERENCE: "gitlab.com/example-group/example-ruleset-project"
```

有关高级示例，请参阅[指定私有远程配置示例](#specify-a-private-remote-configuration)。

<a id="troubleshooting-remote-configuration-files"></a>

#### 故障排除远程配置文件

如果远程配置文件似乎未正确应用自定义内容，可能的原因有：

1. 您的代码仓库中有一个本地 `.gitlab/sast-ruleset.toml` 文件。
   - 默认情况下，如果本地文件存在，则会使用它，即使已将远程配置设置为变量。
   - 您可以将 [SECURE_ENABLE_LOCAL_CONFIGURATION CI/CD 变量](../../../ci/variables/_index.md)设置为 `false`，以忽略本地配置文件。
1. 身份验证存在问题。
   - 要检查这是否是问题的原因，请尝试从不要求身份验证的代码仓库位置引用配置文件。

<a id="schema"></a>

## 架构

规则集配置文件使用 TOML 语法。以下各节介绍每个配置元素的结构和有效设置。

<a id="top-level-section"></a>

### 顶层节

顶层节包含一个或多个配置节，定义为 [TOML 表](https://toml.io/en/v1.0.0#table)。

| 设置       | 描述                                                                                                                                            |
|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| `[$analyzer]` | 声明分析器的配置节。名称遵循 [SAST 分析器](analyzers.md#official-analyzers)列表中定义的名称。 |

配置示例：

```toml
[semgrep]
...
```

避免创建修改现有规则的配置节并构建自定义规则集，因为后者会完全替换默认规则。

<a id="analyzer-configuration-section"></a>

### `[$analyzer]` 配置节

`[$analyzer]` 节可让您自定义分析器的行为。有效属性因您所做的配置类型而异。

| 设置                 | 适用于    | 描述                                                                                                                                                                                                                                                                                                   |
|-------------------------|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `[[$analyzer.ruleset]]` | 默认规则 | 定义对现有规则的修改。                                                                                                                                                                                                                                                                    |
| `interpolate`           | 全部           | 如果设置为 `true`，您可以在配置中使用 `$VAR` 来求值环境变量。请谨慎使用此功能，以免泄露密钥或令牌。（默认值：`false`）                                                                                                                           |
| `description`           | 透传  | 自定义规则集的描述。                                                                                                                                                                                                                                                                            |
| `targetdir`             | 透传  | 最终配置应持久化到的目录。如果为空，则会创建一个具有随机名称的目录。该目录最多可包含 100 MB 的文件。如果 SAST 作业以非 root 用户权限运行，请确保该用户对此目录具有读写权限。 |
| `validate`              | 透传  | 如果设置为 `true`，则会验证每个透传的内容。该验证适用于 `yaml`、`xml`、`json` 和 `toml` 内容。将根据 `[[$analyzer.passthrough]]` 节的 `target` 参数中使用的扩展名来识别相应的验证器。（默认值：`false`）                    |
| `timeout`               | 透传  | 在超时之前，求值透传链所花费的最长时间。超时时间不能超过 300 秒。（默认值：60）                                                                                                                                                                          |
| `keepdefaultrules`      | 透传  | 如果设置为 `true`，分析器的默认规则将与所定义的透传一起激活。（默认值：`false`）                                                                                                                                                                                 |

<a id="interpolate"></a>

#### `interpolate`

> [!warning]
> 为降低泄露密钥的风险，请谨慎使用此功能。
> 当 `interpolate = true` 时，配置中的任何 `$VAR` 引用都会根据
> CI/CD 作业的环境进行展开，包括暴露给该作业的 CI/CD 变量和受保护变量。
> 展开后的值可能会出现在扫描输出、产物或规则集写入的任何其他渠道中。如果配置文件是从由
> [`SAST_RULESET_GIT_REFERENCE`](#reference-the-remote-ruleset-file) 设置的远程位置加载的，则远程作者控制着
> 是否启用 `interpolate`。请仅引用您信任的代码仓库中的规则集。

下面的示例展示了一个使用 `$GITURL` 环境变量访问私有代码仓库的配置。该变量包含用户名和令牌（例如 `https://user:token@url`），因此它们不会显式存储在配置文件中。

```toml
[semgrep]
  description = "My private Semgrep ruleset"
  interpolate = true

  [[semgrep.passthrough]]
    type  = "git"
    value = "$GITURL"
    ref = "main"
```

<a id="analyzerruleset-section"></a>

### `[[$analyzer.ruleset]]` 节

`[[$analyzer.ruleset]]` 节用于定位并修改单个默认规则。您可以为每个分析器定义一个或多个此类节。

| 设置                          | 描述                                             |
|----------------------------------|---------------------------------------------------------|
| `disable`                        | 是否应禁用该规则。（默认值：`false`） |
| `[$analyzer.ruleset.identifier]` | 选择要修改的默认规则。                |
| `[$analyzer.ruleset.override]`   | 定义该规则的覆盖项。                     |

配置示例：

```toml
[semgrep]
  [[semgrep.ruleset]]
    disable = true
    ...
```

<a id="analyzerrulesetidentifier-section"></a>

### `[$analyzer.ruleset.identifier]` 节

`[$analyzer.ruleset.identifier]` 节定义您希望修改的默认规则的标识符。

| 设置 | 描述                                           |
|---------|-------------------------------------------------------|
| `type`  | 默认规则使用的标识符类型。      |
| `value` | 默认规则使用的标识符值。 |

您可以通过查看分析器生成的 [`gl-sast-report.json`](_index.md#download-a-sast-report) 来查找 `type` 和 `value`的正确值。您可以从分析器的 CI 作业中下载此文件作为作业产物。

例如，下面的代码片段显示了来自 `semgrep` 规则的一个发现项，其中包含三个标识符。JSON 对象中的 `type` 和 `value` 键对应于您应在此节中提供的值。

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

<a id="analyzerrulesetoverride-section"></a>

### `[$analyzer.ruleset.override]` 节

`[$analyzer.ruleset.override]` 节允许您覆盖默认规则的属性。

| 设置       | 描述                                                                                         |
|---------------|-----------------------------------------------------------------------------------------------------|
| `description` | 问题的详细描述。                                                                |
| `message`     | （已弃用）问题的描述。                                                            |
| `name`        | 规则的名称。                                                                               |
| `severity`    | 规则的严重级别。有效选项为：`Critical`、`High`、`Medium`、`Low`、`Unknown`、`Info` |

> [!note]
> 虽然 `message` 由分析器填充，但它已被[弃用](https://gitlab.com/gitlab-org/security-products/analyzers/report/-/blob/1d86d5f2e61dc38c775fb0490ee27a45eee4b8b3/vulnerability.go#L22)，
> 取而代之的是 `name` 和 `description`。

配置示例：

```toml
[semgrep]
  [[semgrep.ruleset]]
    [semgrep.ruleset.override]
      severity = "Critical"
      name = "Command injection"
    ...
```

<a id="analyzerpassthrough-section"></a>

### `[[$analyzer.passthrough]]` 节

> [!note]
> 透传配置仅适用于[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)。

`[[$analyzer.passthrough]]` 节允许您为分析器构建自定义配置。您可以为每个分析器定义最多 20 个此类节。透传会组合成一个*透传链*，其求值结果是一个完整配置，用于替换分析器的默认规则。

透传按顺序求值。链中靠后的透传具有更高的优先级，可以覆盖或追加到先前透传产生的数据（取决于 `mode`）。这在您需要使用或修改现有配置时非常有用。

单个透传生成的配置大小限制为 10 MB。

| 设置     | 适用于     | 描述                                                                                                                                                                   |
|-------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`      | 全部            | `file`、`raw`、`git` 或 `url` 之一。                                                                                                                                        |
| `target`    | 全部            | 用于包含透传求值所写入数据的目标文件。如果为空，则使用随机文件名。                                                               |
| `mode`      | 全部            | 如果为 `overwrite`，则覆盖 `target` 文件。如果为 `append`，则将新内容追加到 `target` 文件。`git` 类型仅支持 `overwrite`。（默认值：`overwrite`） |
| `ref`       | `type = "git"` | 包含要拉取的分支、标签或 SHA 的名称                                                                                                                      |
| `subdir`    | `type = "git"` | 用于选择 Git 代码仓库的子目录作为配置来源。                                                                                              |
| `value`     | 全部            | 对于 `file`、`url` 和 `git` 类型，定义文件或 Git 代码仓库的位置。对于 `raw` 类型，包含内联配置。                            |
| `validator` | 全部            | 用于在透传求值后对目标文件显式调用验证器（`xml`、`yaml`、`json`、`toml`）。                                                |

<a id="passthrough-types"></a>

#### 透传类型

| 类型   | 描述                                          |
|--------|------------------------------------------------------|
| `file` | 使用 Git 代码仓库中存在的文件。    |
| `raw`  | 以内联方式提供配置。                    |
| `git`  | 从远程 Git 代码仓库拉取配置。 |
| `url`  | 使用 HTTP 获取配置。                  |

> [!warning]
> 将 `raw` 透传与 YAML 代码片段一起使用时，建议将 `sast-ruleset.toml` 文件中的所有缩进格式化为空格。YAML 规范要求使用空格而非制表符，除非缩进按相应方式表示，否则分析器将无法解析您的自定义规则集。

<a id="examples"></a>

## 示例

以下示例展示了如何为常见场景自定义规则集。请使用架构一节来了解每个示例中使用的配置选项。

<a id="replace-all-default-gitlab-advanced-sast-rules"></a>

### 替换所有默认极狐GitLab Advanced SAST 规则

使用以下自定义规则集配置，极狐GitLab Advanced SAST 分析器的默认规则集将被替换为正在扫描的代码仓库中名为 `my-gitlab-advanced-sast-rules.yml`的文件中所包含的自定义规则集。

```yaml
# my-gitlab-advanced-sast-rules.yml
---
rules:
- id: my-custom-rule
  pattern: print("Hello World")
  message: |
    Unauthorized use of Hello World.
  severity: ERROR
  languages:
  - python
```

```toml
[gitlab-advanced-sast]
  description = "My custom ruleset for Semgrep"

  [[gitlab-advanced-sast.passthrough]]
    type  = "file"
    value = "my-gitlab-advanced-sast-rules.yml"
```

<a id="disable-specific-default-gitlab-advanced-sast-rules"></a>

### 禁用特定的默认极狐GitLab Advanced SAST 规则

在此示例中，根据以下条件禁用特定的默认规则：

- CWE 标识符，用于标识一整类漏洞。
- 极狐GitLab Advanced SAST 规则 ID，用于标识极狐GitLab Advanced SAST 中使用的特定检测策略。
- 关联的 Semgrep 规则 ID，出于兼容性考虑包含在极狐GitLab Advanced SAST 发现项中。
  此附加元数据允许在两个分析器于同一位置创建类似发现项时自动转换发现项。

这些标识符显示在每个漏洞的[漏洞详情](../vulnerabilities/_index.md)中。您还可以在[可下载的 SAST 报告产物](_index.md#download-a-sast-report)中查看每个标识符及其关联的 `type`。

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

<a id="disable-specific-default-rules-of-other-sast-analyzers"></a>

### 禁用其他 SAST 分析器的特定默认规则

使用以下自定义规则集配置，以下默认规则将从报告中省略：

- `semgrep` 规则，其 `semgrep_id` 为 `gosec.G106-1` 或其 `cwe` 为 `322`。
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

<a id="override-default-rule-metadata"></a>

### 覆盖默认规则元数据

使用以下自定义规则集配置，通过 `semgrep` 发现的类型为 `CWE`、值为 `322`的漏洞，其严重级别将被覆盖为 `Critical`。

```toml
[semgrep]
  [[semgrep.ruleset]]
    [semgrep.ruleset.identifier]
      type = "cwe"
      value = "322"
    [semgrep.ruleset.override]
      severity = "Critical"
```

<a id="replace-or-add-to-the-default-rules-of-semgrep"></a>

### 替换或添加 `semgrep`的默认规则

使用以下自定义规则集配置，`semgrep` 分析器的默认规则集将被替换为正在扫描的代码仓库中名为 `my-semgrep-rules.yml`的文件中所包含的自定义规则集。

```yaml
# my-semgrep-rules.yml
---
rules:
- id: my-custom-rule
  pattern: print("Hello World")
  message: |
    Unauthorized use of Hello World.
  severity: ERROR
  languages:
  - python
```

```toml
[semgrep]
  description = "My custom ruleset for Semgrep"

  [[semgrep.passthrough]]
    type  = "file"
    value = "my-semgrep-rules.yml"
```

<a id="build-a-custom-configuration-using-a-passthrough-chain-for-semgrep"></a>

### 使用透传链为 `semgrep` 构建自定义配置

使用以下自定义规则集配置，`semgrep` 分析器的默认规则集将被替换为通过求值四个透传组成的链而生成的自定义规则集。每个透传都会生成一个文件，写入容器内的 `/sgrules` 目录。设置了 `timeout` 为 60 秒，以防任何 Git 远程仓库无响应。

此示例演示了不同的透传类型：

- 两个 `git` 透传，第一个从 `myrules` Git 代码仓库拉取 `develop` 分支，第二个从 `sast-rules` 代码仓库拉取修订版本 `97f7686`，并且仅考虑 `go` 子目录中的文件。
  - `sast-rules` 条目的优先级更高，因为它在配置中出现得更靠后。
  - 如果两个检出之间存在文件名冲突，则 `sast-rules` 代码仓库中的文件会覆盖 `myrules` 代码仓库中的文件。
- 一个 `raw` 透传，将其 `value` 写入 `/sgrules/insecure.yml`。
- 一个 `url` 透传，获取托管在某个 URL 上的配置并将其写入 `/sgrules/gosec.yml`。

之后，使用位于 `/sgrules` 下的最终配置调用 Semgrep。

```toml
[semgrep]
  description = "My custom ruleset for Semgrep"
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
    Insecure function insecure detected
  metadata:
    cwe: "CWE-200: Exposure of Sensitive Information to an Unauthorized Actor"
  severity: "ERROR"
  languages:
    - "go"
"""

  [[semgrep.passthrough]]
    type  = "url"
    value = "https://semgrep.dev/c/p/gosec"
    target = "gosec.yml"
```

<a id="configure-the-mode-for-passthroughs-in-a-chain"></a>

### 配置链中透传的模式

您可以选择如何处理链中透传之间发生的文件名冲突。默认行为是用同名文件覆盖现有文件，但您也可以选择 `mode = append`，将靠后文件的内容追加到靠前文件上。

您只能对 `file`、`url` 和 `raw` 透传类型使用 `append` 模式。

使用以下自定义规则集配置，两个 `raw` 透传用于迭代组装 `/sgrules/my-rules.yml` 文件，然后将其作为规则集提供给 Semgrep。每个透传都会向规则集追加一条规则。第一个透传负责根据 [Semgrep 规则语法](https://docs.semgrep.dev/writing-rules/rule-syntax)初始化顶层 `rules` 对象。

```toml
[semgrep]
  description = "My custom ruleset for Semgrep"
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
    Insecure function 'insecure' detected
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
    Use of hard-coded password
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
    Insecure function 'insecure' detected
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
    Use of hard-coded password
  metadata:
    cwe: "..."
  severity: "ERROR"
  languages:
    - "go"
```

<a id="specify-a-private-remote-configuration"></a>

### 指定私有远程配置

以下示例启用 SAST 并使用共享的规则集自定义文件：

- 该文件从需要身份验证的私有项目下载。此示例使用安全存储在 CI/CD 变量中的
  [群组访问令牌](../../group/settings/group_access_tokens.md)。
- 该文件在特定的 Git 提交 SHA 处检出，而不是默认分支。

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SAST_RULESET_GIT_REFERENCE: "oauth2:$GROUP_ACCESS_TOKEN@gitlab.com/example-group/example-ruleset-project@c8ea7e3ff126987fb4819cc35f2310755511c2ab"
```

<a id="demonstration-projects"></a>

### 演示项目

浏览[演示项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations)，这些项目演示了其中一些配置选项。

其中许多项目演示了如何使用远程规则集来覆盖或禁用规则，并按它们所属的分析器分组。
