---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 自定义规则集格式
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

您可以使用[不同种类的规则集自定义](configure.md#customize-analyzer-rulesets)来定制流水线密钥检测的行为。

<a id="schema"></a>

## 架构

流水线密钥检测规则集的自定义必须遵循严格的架构。以下部分描述了每个可用选项及其适用的架构。

<a id="the-top-level-section"></a>

### 顶级部分

顶级部分包含一个或多个_配置部分_，定义为 TOML表。

| 设置         | 描述                                                      |
|--------------|----------------------------------------------------------|
| `[secrets]`  | 为分析器声明一个配置部分。                               |

配置示例：

```toml
[secrets]
...
```

<a id="the-secrets-configuration-section"></a>

### `[secrets]` 配置部分

`[secrets]` 部分允许您自定义分析器的行为。有效的属性根据您正在进行的配置类型而有所不同。

| 设置                   | 适用范围           | 描述                                                                                                                                                                                                                                           |
|------------------------|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `[[secrets.ruleset]]`  | 预定义规则         | 定义对现有规则的修改。                                                                                                                                                                                                                         |
| `interpolate`          | 所有               | 如果设置为 `true`，您可以在配置中使用 `$VAR` 来评估环境变量。使用此功能时要谨慎，以免泄漏密钥或令牌。（默认值：`false`）                                                                                                                     |
| `description`          | 透传               | 自定义规则集的描述。                                                                                                                                                                                                                           |
| `targetdir`            | 透传               | 应持久化最终配置的目录。如果为空，则会创建一个随机名称的目录。目录最多可以包含 100 MB 的文件。                                                                                                                                                  |
| `validate`             | 透传               | 如果设置为 `true`，则会验证每个透传的内容。验证适用于 `yaml`、`xml`、`json` 和 `toml` 内容。根据 `[[secrets.passthrough]]` 部分中的 `target` 参数使用的扩展名来识别正确的验证器。（默认值：`false`）                                            |
| `timeout`              | 透传               | 在超时之前评估透传链的最长时间。超时不能超过 300 秒。（默认值：60）                                                                                                                                                                            |

<a id="interpolate"></a>

#### `interpolate`

{{< alert type="warning" >}}

为了减少泄漏密钥的风险，请谨慎使用此功能。

{{< /alert >}}

下面的示例显示了一个使用 `$GITURL` 环境变量访问私有仓库的配置。变量包含用户名和令牌（例如 `https://user:token@url`），因此它们不会明确存储在配置文件中。

```toml
[secrets]
  description = "我的私有远程规则集"
  interpolate = true

  [[secrets.passthrough]]
    type  = "git"
    value = "$GITURL"
    ref = "main"
```

<a id="the-secrets-ruleset-section"></a>

### `[[secrets.ruleset]]` 部分

`[[secrets.ruleset]]` 部分针对并修改单个预定义规则。您可以为分析器定义一个或多个这些部分。

| 设置                            | 描述                               |
|---------------------------------|----------------------------------|
| `disable`                       | 是否应该禁用该规则。（默认值：`false`） |
| `[secrets.ruleset.identifier]`  | 选择要修改的预定义规则。          |
| `[secrets.ruleset.override]`    | 定义规则的覆盖。                  |

配置示例：

```toml
[secrets]
  [[secrets.ruleset]]
    disable = true
    ...
```

<a id="the-secrets-ruleset-identifier-section"></a>

### `[secrets.ruleset.identifier]` 部分

`[secrets.ruleset.identifier]` 部分定义您希望修改的预定义规则的标识符。

| 设置   | 描述                                             |
|--------|--------------------------------------------------|
| `type` | 预定义规则使用的标识符类型。                     |
| `value`| 预定义规则使用的标识符值。                       |

要确定 `type` 和 `value` 的正确值，请查看由分析器生成的[`gl-secret-detection-report.json`](_index.md#output)。您可以从分析器的 CI 作业下载此文件作为作业产物。

例如，下面的代码段显示了一个来自 `gitlab_personal_access_token` 规则的发现，其中包含一个标识符。JSON 对象中的 `type` 和 `value` 键对应于您应该在此部分中提供的值。

```json
...
  "vulnerabilities": [
    {
      "id": "fccb407005c0fb58ad6cfcae01bea86093953ed1ae9f9623ecc3e4117675c91a",
      "category": "secret_detection",
      "name": "极狐GitLab 个人访问令牌",
      "description": "在提交 5c124166 中发现了极狐GitLab 个人访问令牌",
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

<a id="the-secrets-ruleset-override-section"></a>

### `[secrets.ruleset.override]` 部分

`[secrets.ruleset.override]` 部分允许您覆盖预定义规则的属性。

| 设置           | 描述                                                                                                 |
|---------------|------------------------------------------------------------------------------------------------------|
| `description` | 议题的详细描述。                                                                                      |
| `message`     | （已弃用）议题的描述。                                                                               |
| `name`        | 规则的名称。                                                                                         |
| `severity`    | 规则的严重性。有效选项为：`Critical`、`High`、`Medium`、`Low`、`Unknown`、`Info`                     |

{{< alert type="note" >}}

虽然 `message` 仍由分析器填充，但它已被弃用，并被 `name` 和 `description` 替代。

{{< /alert >}}

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

{{< history >}}

- 引入于极狐GitLab 17.9。

{{< /history >}}

在创建自定义规则时，您可以使用 Gitleaks 的标准规则格式以及其他极狐GitLab 特定字段。以下设置可用于每个规则：

| 设置         | 必需的 | 描述                                                                                         |
|-------------|--------|----------------------------------------------------------------------------------------------|
| `title`     | 否     | 极狐GitLab 特定字段，用于为规则设置自定义标题。                                               |
| `description` | 是   | 详细描述规则检测的内容。                                                                      |
| `remediation` | 否   | 极狐GitLab 特定字段，提供规则触发时的修复指导。                                               |
| `regex`     | 是     | 用于检测密钥的正则表达式模式。                                                               |
| `keywords`  | 否     | 在应用正则表达式之前预过滤内容的关键字列表。                                                 |
| `id`        | 是     | 规则的唯一标识符。                                                                           |

带有所有可用字段的自定义规则示例：

```toml
[[rules]]
  title = "API 密钥检测规则"
  description = "检测代码库中的潜在 API 密钥"
  remediation = "旋转暴露的 API 密钥并将其存储在安全的凭证管理器中"
  id = "custom_api_key"
  keywords = ["apikey", "api_key"]
  regex = '''api[_-]key[_-][a-zA-Z0-9]{16,}'''
```

当您创建与扩展规则集中规则共享相同 ID 的自定义规则时，您的自定义规则将优先。您自定义规则的所有属性将替换扩展规则中的对应值。

使用自定义规则扩展默认规则的示例：

```toml
title = "扩展极狐GitLab 默认 Gitleaks 配置"

[extend]
  path = "/gitleaks.toml"

[[rules]]
  title = "自定义 API 密钥规则"
  description = "检测自定义 API 密钥格式"
  remediation = "旋转暴露的 API 密钥"
  id = "custom_api_123"
  keywords = ["testing"]
  regex = '''testing-key-[1-9]{3}'''
```

<a id="the-secrets-passthrough-section"></a>

### `[[secrets.passthrough]]` 部分

`[[secrets.passthrough]]` 部分允许您为分析器合成自定义配置。

您可以为每个分析器定义最多 20 个这样的部分。透传然后被组合成一个_透传链_，评估为一个完整的配置，可以用于替换或扩展分析器的预定义规则。

透传按顺序进行评估。链中后面列出的透传具有更高的优先级，可以根据 `mode` 覆盖或追加前面透传生成的数据。当您需要使用或修改现有配置时，请使用透传。

单个透传生成的配置大小限制为 10 MB。

| 设置         | 适用范围       | 描述                                                                                                                                                                     |
|--------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`       | 所有           | 其中之一 `file`、`raw`、`git` 或 `url`。                                                                                                                                  |
| `target`     | 所有           | 包含透传评估写入数据的目标文件。如果为空，则使用随机文件名。                                                                                                             |
| `mode`       | 所有           | 如果为 `overwrite`，则会覆盖 `target` 文件。如果为 `append`，则将新内容追加到 `target` 文件中。`git` 类型仅支持 `overwrite`。（默认值：`overwrite`）                      |
| `ref`        | `type = "git"` | 包含要拉取的分支、标签或 SHA 的名称。                                                                                                                                     |
| `subdir`     | `type = "git"` | 用于选择 Git 仓库的子目录作为配置源。                                                                                                                                    |
| `auth`       | `type = "git"` | 用于提供凭证，以便使用[存储在私有 Git 仓库中的配置](configure.md#with-a-private-remote-ruleset)。                                                              |
| `value`      | 所有           | 对于 `file`、`url` 和 `git` 类型，定义文件或 Git 仓库的位置。对于 `raw` 类型，包含内联配置。                                                                          |
| `validator`  | 所有           | 用于在透传评估后显式调用目标文件上的验证器（`xml`、`yaml`、`json`、`toml`）。                                                                                           |

<a id="passthrough-types"></a>

#### 透传类型

| 类型   | 描述                                               |
|--------|----------------------------------------------------|
| `file` | 使用存储在同一 Git 仓库中的文件。                  |
| `raw`  | 提供内联的规则集配置。                             |
| `git`  | 从远程 Git 仓库拉取配置。                          |
| `url`  | 使用 HTTP 获取配置。                               |
