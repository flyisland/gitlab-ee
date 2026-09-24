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

你可以使用[不同类型的规则集自定义](configure.md#customize-analyzer-rulesets)来定制流水线密钥检测的行为。

## Schema

<a id="schema"></a>

流水线密钥检测规则集的自定义必须遵循严格的 schema。以下各节描述了每个可用选项以及适用于该部分的 schema。

### 顶级部分

<a id="the-top-level-section"></a>

顶级部分包含一个或多个配置节，定义为 [TOML 表](https://toml.io/en/v1.0.0#table)。

| 设置       | 描述                   |
|-------------|-----------------------|
| `[secrets]` | 声明分析器的配置节。 |

配置示例：

```toml
[secrets]
...
```

### `[secrets]` 配置节

<a id="the-secrets-configuration-section"></a>

`[secrets]` 节允许你自定义分析器的行为。有效的属性取决于你正在进行的配置类型。

| 设置                   | 适用对象             | 描述                                                                                                                                                                                                                                                               |
|-----------------------|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `[[secrets.ruleset]]` | 预定义规则           | 定义对现有规则的修改。                                                                                                                                                                                                                                                   |
| `interpolate`         | 全部                | 如果设置为 `true`，你可以在配置中使用 `$VAR` 来评估环境变量。请谨慎使用此功能，以免泄露密钥或令牌。(默认值：`false`)                                                                                                                                                                  |
| `description`         | 直通                | 自定义规则集的描述。                                                                                                                                                                                                                                                      |
| `targetdir`           | 直通                | 最终配置应持久化的目录。如果为空，则会创建一个具有随机名称的目录。该目录最多可包含 100 MB 的文件。                                                                                                                                                                                 |
| `validate`            | 直通                | 如果设置为 `true`，则会验证每个直通的内容。验证适用于 `yaml`、`xml`、`json` 和 `toml` 内容。根据 `[[secrets.passthrough]]` 节的 `target` 参数中使用的扩展名来识别合适的验证器。(默认值：`false`)                                                                                        |
| `timeout`             | 直通                | 评估直通链所花费的最长时间，超时后便会终止。超时时间不能超过 300 秒。(默认值：60)                                                                                                                                                                                               |

#### `interpolate`

<a id="interpolate"></a>

> [!warning]
> 为降低泄露密钥的风险，请谨慎使用此功能。

下面的示例展示了一个配置，该配置使用 `$GITURL` 环境变量访问私有仓库。该变量包含用户名和令牌（例如 `https://user:token@url`），因此它们不会显式存储在配置文件中。

```toml
[secrets]
  description = "我的私有远程规则集"
  interpolate = true

  [[secrets.passthrough]]
    type  = "git"
    value = "$GITURL"
    ref = "main"
```

### `[[secrets.ruleset]]` 节

<a id="the-secretsruleset-section"></a>

`[[secrets.ruleset]]` 节定位并修改单个预定义规则。你可以为分析器定义一个或多个这样的节。

| 设置                            | 描述                                      |
|--------------------------------|------------------------------------------|
| `disable`                      | 是否应禁用该规则。(默认值：`false`)          |
| `[secrets.ruleset.identifier]` | 选择要修改的预定义规则。                      |
| `[secrets.ruleset.override]`   | 定义对该规则的覆盖。                         |

配置示例：

```toml
[secrets]
  [[secrets.ruleset]]
    disable = true
    ...
```

### `[secrets.ruleset.identifier]` 节

<a id="the-secretsrulesetidentifier-section"></a>

`[secrets.ruleset.identifier]` 节定义了你希望修改的预定义规则的标识符。

| 设置    | 描述                             |
|--------|---------------------------------|
| `type`  | 预定义规则使用的标识符类型。      |
| `value` | 预定义规则使用的标识符的值。      |

要确定 `type` 和 `value` 的正确值，请查看分析器生成的 [`gl-secret-detection-report.json`](_index.md#secret-detection-results)。你可以从分析器的 CI/CD 作业中将此文件作为作业产物下载。

例如，下面的代码片段显示了一个来自 `gitlab_personal_access_token` 规则且带有一个标识符的发现。JSON 对象中的 `type` 和 `value` 键与你应在此节中提供的值相对应。

```json
...
  "vulnerabilities": [
    {
      "id": "fccb407005c0fb58ad6cfcae01bea86093953ed1ae9f9623ecc3e4117675c91a",
      "category": "secret_detection",
      "name": "极狐GitLab 个人访问令牌",
      "description": "GitLab personal access token has been found in commit 5c124166",
      ...
      "identifiers": [
        {
          "type": "gitleaks_rule_id",
          "name": "Gitleaks 规则 ID gitlab_personal_access_token",
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

### `[secrets.ruleset.override]` 节

<a id="the-secretsrulesetoverride-section"></a>

`[secrets.ruleset.override]` 节允许你覆盖预定义规则的属性。

| 设置          | 描述                                                                                               |
|---------------|---------------------------------------------------------------------------------------------------|
| `description` | 对这个议题的详细描述。                                                                              |
| `message`     | (已弃用) 对这个议题的描述。                                                                          |
| `name`        | 规则的名称。                                                                                       |
| `severity`    | 规则的严重性。有效选项为：`Critical`、`High`、`Medium`、`Low`、`Unknown`、`Info`                     |

> [!note]
> 尽管分析器仍会填充 `message`，但它已[被弃用](https://gitlab.com/gitlab-org/security-products/analyzers/report/-/blob/1d86d5f2e61dc38c775fb0490ee27a45eee4b8b3/vulnerability.go#L22)，并被 `name` 和 `description` 取代。

配置示例：

```toml
[secrets]
  [[secrets.ruleset]]
    [secrets.ruleset.override]
      severity = "Medium"
      name = "systemd machine-id"
    ...
```

### 自定义规则格式

<a id="custom-rule-format"></a>

{{< history >}}

- 于极狐GitLab 17.9 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/511321)。

{{< /history >}}

在创建自定义规则时，你可以同时使用 [Gitleaks 的标准规则格式](https://github.com/gitleaks/gitleaks?tab=readme-ov-file#configuration)和极狐GitLab 特定的额外字段。每个规则可用的设置如下：

| 设置          | 是否必填 | 描述                                     |
|--------------|------|------------------------------------------|
| `title`        | 否   | 一个极狐GitLab 特定字段，用于为规则设置自定义标题。 |
| `description`  | 是   | 对规则检测内容的详细描述。                  |
| `remediation`  | 否   | 一个极狐GitLab 特定字段，用于在规则触发时提供修复指导。 |
| `regex`        | 是   | 用于检测密钥的正则表达式模式。              |
| `keywords`     | 否   | 用于在应用正则表达式之前预过滤内容的关键字列表。 |
| `id`           | 是   | 规则的唯一标识符。                         |

一个包含所有可用字段的自定义规则示例：

```toml
[[rules]]
  title = "API 密钥检测规则"
  description = "检测代码库中潜在的 API 密钥"
  remediation = "轮换已暴露的 API 密钥，并将其存储在安全的凭据管理器中"
  id = "custom_api_key"
  keywords = ["apikey", "api_key"]
  regex = '''api[_-]key[_-][a-zA-Z0-9]{16,}'''
```

当你创建的自定义规则与扩展规则集中的某一规则共享相同的 ID 时，你的自定义规则将优先。你自定义规则的所有属性都将替换扩展规则中的相应值。

使用自定义规则扩展现有默认规则的示例：

```toml
title = "极狐GitLab 默认 Gitleaks 配置的扩展"

[extend]
  path = "/gitleaks.toml"

[[rules]]
  title = "自定义 API 密钥规则"
  description = "检测自定义 API 密钥格式"
  remediation = "轮换已暴露的 API 密钥"
  id = "custom_api_123"
  keywords = ["testing"]
  regex = '''testing-key-[1-9]{3}'''
```

### `[[secrets.passthrough]]` 节

<a id="the-secretspassthrough-section"></a>

`[[secrets.passthrough]]` 节允许你为分析器合成一个自定义配置。

每个分析器最多可以定义 20 个这样的节。然后，直通会被组合成一个直通链，该链会评估出一个完整的配置，这个配置可用于替换或扩展分析器的预定义规则。

直通按顺序评估。链中后面列出的直通具有更高的优先级，并且可以根据 `mode` 覆盖或附加到先前直通产生的数据。当你需要使用或修改现有配置时，请使用直通。

单个直通生成的配置大小限制为 10 MB。

| 设置         | 适用于         | 描述                                                                                                                                                    |
|-------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`      | 全部            | `file`、`raw`、`git` 或 `url` 之一。                                                                                                                   |
| `target`    | 全部            | 包含由直通评估写入的数据的目标文件。如果为空，则使用随机文件名。                                                                                              |
| `mode`      | 全部            | 如果为 `overwrite`，则覆盖 `target` 文件。如果为 `append`，则将新内容附加到 `target` 文件中。`git` 类型仅支持 `overwrite`。(默认值：`overwrite`)                      |
| `ref`       | `type = "git"`  | 包含要拉取的分支、标签或 SHA 的名称。                                                                                                                       |
| `subdir`    | `type = "git"`  | 用于选择 Git 仓库的子目录作为配置源。                                                                                                                         |
| `auth`      | `type = "git"`  | 用于在使用[存储在私有 Git 仓库中的配置](configure.md#with-a-private-remote-ruleset)时提供凭据。                                                        |
| `value`     | 全部            | 对于 `file`、`url` 和 `git` 类型，定义文件或 Git 仓库的位置。对于 `raw` 类型，包含内联配置。                                                                  |
| `validator` | 全部            | 用于在评估直通后，在目标文件上显式调用验证器（`xml`、`yaml`、`json`、`toml`）。                                                                                    |

#### 直通类型

<a id="passthrough-types"></a>

| 类型   | 描述                                   |
|--------|---------------------------------------|
| `file` | 使用存储在同一个 Git 仓库中的文件。    |
| `raw`  | 以内联方式提供规则集配置。              |
| `git`  | 从远程 Git 仓库拉取配置。             |
| `url`  | 使用 HTTP 获取配置。                    |