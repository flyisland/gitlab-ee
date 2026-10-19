---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义规则集 schema
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用[不同种类的规则集自定义](configure.md#customize-analyzer-rulesets)来自定义流水线密钥检测的行为。

<a id="schema"></a>

## Schema

对流水线密钥检测规则集的自定义必须遵循严格的 schema。以下各节介绍每个可用选项以及适用于该节的 schema。

<a id="the-top-level-section"></a>

### 顶层节

顶层节包含一个或多个配置节，定义为 [TOML 表](https://toml.io/en/v1.0.0#table)。

| 设置     | 描述                                        |
|-------------|----------------------------------------------------|
| `[secrets]` | 为分析器声明一个配置节。 |

配置示例：

```toml
[secrets]
...
```

<a id="the-secrets-configuration-section"></a>

### `[secrets]` 配置节

`[secrets]` 节允许您自定义分析器的行为。有效属性因您所做的配置类型而异。

| 设置               | 适用于       | 描述                                                                                                                                                                                                                                                                              |
|-----------------------|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `[[secrets.ruleset]]` | 预定义规则 | 定义对现有规则的修改。                                                                                                                                                                                                                                               |
| `interpolate`         | 全部              | 如果设置为 `true`，您可以在配置中使用 `$VAR` 来求值环境变量。请谨慎使用此功能，以免泄露密钥或令牌。（默认值：`false`）                                                                                                      |
| `description`         | 透传     | 自定义规则集的描述。                                                                                                                                                                                                                                                       |
| `targetdir`           | 透传     | 最终配置应持久化到的目录。如果为空，则创建一个具有随机名称的目录。该目录最多可包含 100 MB 的文件。                                                                                                                   |
| `validate`            | 透传     | 如果设置为 `true`，则验证每个透传的内容。该验证适用于 `yaml`、`xml`、`json` 和 `toml` 内容。将根据 `[[secrets.passthrough]]` 节的 `target` 参数中使用的扩展名来识别相应的验证器。（默认值：`false`） |
| `timeout`             | 透传     | 在超时之前，求值透传链所花费的最长时间。超时时间不能超过 300 秒。（默认值：60）                                                                                                                                                     |

<a id="interpolate"></a>

#### `interpolate`

> [!warning]
> 为降低泄露密钥的风险，请谨慎使用此功能。

下面的示例展示了一个配置，它使用 `$GITURL` 环境变量来访问私有代码仓库。该变量包含用户名和令牌（例如 `https://user:token@url`），因此它们不会显式存储在配置文件中。

```toml
[secrets]
  description = "My private remote ruleset"
  interpolate = true

  [[secrets.passthrough]]
    type  = "git"
    value = "$GITURL"
    ref = "main"
```

<a id="the-secretsruleset-section"></a>

### `[[secrets.ruleset]]` 节

`[[secrets.ruleset]]` 节用于定位并修改单个预定义规则。您可以为分析器定义一个到多个此类节。

| 设置                        | 描述                                             |
|--------------------------------|---------------------------------------------------------|
| `disable`                      | 是否应禁用该规则。（默认值：`false`） |
| `[secrets.ruleset.identifier]` | 选择要修改的预定义规则。             |
| `[secrets.ruleset.override]`   | 定义该规则的覆盖项。                     |

配置示例：

```toml
[secrets]
  [[secrets.ruleset]]
    disable = true
    ...
```

<a id="the-secretsrulesetidentifier-section"></a>

### `[secrets.ruleset.identifier]` 节

`[secrets.ruleset.identifier]` 节定义您希望修改的预定义规则的标识符。

| 设置 | 描述 |
| --------| ----------- |
| `type`  | 预定义规则使用的标识符类型。 |
| `value` | 预定义规则使用的标识符值。 |

要确定 `type` 和 `value`的正确值，请查看分析器生成的
[`gl-secret-detection-report.json`](_index.md#secret-detection-results)。
您可以从分析器的 CI/CD 作业中下载此文件作为作业产物。

例如，下面的代码片段展示了来自 `gitlab_personal_access_token` 规则的一个发现项，它带有一个标识符。JSON 对象中的 `type` 和 `value` 键对应于您应在本节中提供的值。

```json
...
  "vulnerabilities": [
    {
      "id": "fccb407005c0fb58ad6cfcae01bea86093953ed1ae9f9623ecc3e4117675c91a",
      "category": "secret_detection",
      "name": "GitLab personal access token",
      "description": "GitLab personal access token has been found in commit 5c124166",
      ...
      "identifiers": [
        {
          "type": "gitleaks_rule_id",
          "name": "Gitleaks rule ID gitlab_personal_access_token",
          "value": "gitlab_personal_access_token"
        }
      ]
    }
    ...
  ]
...
```

配置示例：

```toml
[secrets]
  [[secrets.ruleset]]
    [secrets.ruleset.identifier]
      type = "gitleaks_rule_id"
      value = "gitlab_personal_access_token"
    ...
```

<a id="the-secretsrulesetoverride-section"></a>

### `[secrets.ruleset.override]` 节

`[secrets.ruleset.override]` 节允许您覆盖预定义规则的属性。

| 设置       | 描述                                                                                         |
|---------------|-----------------------------------------------------------------------------------------------------|
| `description` | 该问题的详细描述。                                                                |
| `message`     | （已弃用）该问题的描述。                                                            |
| `name`        | 规则的名称。                                                                               |
| `severity`    | 规则的严重性。有效选项为：`Critical`、`High`、`Medium`、`Low`、`Unknown`、`Info` |

> [!note]
> 尽管 `message` 仍由分析器填充，但它已被[弃用](https://gitlab.com/gitlab-org/security-products/analyzers/report/-/blob/1d86d5f2e61dc38c775fb0490ee27a45eee4b8b3/vulnerability.go#L22)
> 并由 `name` 和 `description` 取代。

配置示例：

```toml
[secrets]
  [[secrets.ruleset]]
    [secrets.ruleset.override]
      severity = "Medium"
      name = "systemd machine-id"
    ...
```

<a id="custom-rule-format"></a>

### 自定义规则格式

创建自定义规则时，您可以同时使用 [Gitleaks 的标准规则格式](https://github.com/gitleaks/gitleaks?tab=readme-ov-file#configuration)和额外的极狐GitLab 专用字段。每条规则可使用以下设置：

| 设置 | 必需 | 描述 |
|---------|-------------|-------------|
| `title` | 否 | 极狐GitLab 专用字段，用于为规则设置自定义标题。 |
| `description` | 是 | 该规则检测内容的详细描述。 |
| `remediation` | 否 | 极狐GitLab 专用字段，用于在触发规则时提供修复指导。 |
| `regex` | 是 | 用于检测密钥的正则表达式模式。 |
| `keywords` | 否 | 在应用正则表达式之前用于预过滤内容的关键字列表。 |
| `id` | 是 |  该规则的唯一标识符。 |

包含所有可用字段的自定义规则示例：

```toml
[[rules]]
  title = "API Key Detection Rule"
  description = "Detects potential API keys in the codebase"
  remediation = "Rotate the exposed API key and store it in a secure credential manager"
  id = "custom_api_key"
  keywords = ["apikey", "api_key"]
  regex = '''api[_-]key[_-][a-zA-Z0-9]{16,}'''
```

当您创建的自定义规则与扩展规则集中的某条规则具有相同 ID 时，您的自定义规则优先。您的自定义规则的所有属性都会替换扩展规则中的对应值。

使用自定义规则扩展默认规则的示例：

```toml
title = "Extension of GitLab's default Gitleaks config"

[extend]
  path = "/gitleaks.toml"

[[rules]]
  title = "Custom API Key Rule"
  description = "Detects custom API key format"
  remediation = "Rotate the exposed API key"
  id = "custom_api_123"
  keywords = ["testing"]
  regex = '''testing-key-[1-9]{3}'''
```

<a id="the-secretspassthrough-section"></a>

### `[[secrets.passthrough]]` 节

`[[secrets.passthrough]]` 节允许您为分析器合成自定义配置。

每个分析器最多可定义 20 个此类节。然后，透传会被组合成一个透传链，该链求值后生成完整配置，可用于替换或扩展分析器的预定义规则。

透传按顺序求值。链中靠后的透传具有更高的优先级，可以覆盖或追加到先前透传产生的数据（取决于 `mode`）。当您需要使用或修改现有配置时，请使用透传。

单个透传生成的配置大小限制为 10 MB。

| 设置     | 适用于     | 描述                                                                                                                                                                   |
|-------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`      | 全部            | `file`、`raw`、`git` 或 `url` 之一。                                                                                                                                        |
| `target`    | 全部            | 用于包含透传求值所写入数据的目标文件。如果为空，则使用随机文件名。                                                               |
| `mode`      | 全部            | 如果为 `overwrite`，则覆盖 `target` 文件。如果为 `append`，则将新内容追加到 `target` 文件。`git` 类型仅支持 `overwrite`。（默认值：`overwrite`） |
| `ref`       | `type = "git"` | 包含要拉取的分支、标签或 SHA 的名称。                                                                                                                     |
| `subdir`    | `type = "git"` | 用于选择 Git 代码仓库的子目录作为配置来源。                                                                                              |
| `auth`      | `type = "git"` | 用于提供使用[存储在私有 Git 代码仓库中的配置](configure.md#with-a-private-remote-ruleset)时要使用的凭据。                       |
| `value`     | 全部            | 对于 `file`、`url` 和 `git` 类型，定义文件或 Git 代码仓库的位置。对于 `raw` 类型，包含内联配置。                            |
| `validator` | 全部            | 用于在透传求值后，对目标文件显式调用验证器（`xml`、`yaml`、`json`、`toml`）。                                                |

<a id="passthrough-types"></a>

#### 透传类型

| 类型   | 描述                                           |
|--------|-------------------------------------------------------|
| `file` | 使用存储在同一 Git 代码仓库中的文件。 |
| `raw`  | 以内联方式提供规则集配置。             |
| `git`  | 从远程 Git 代码仓库拉取配置。  |
| `url`  | 使用 HTTP 获取配置。                   |
