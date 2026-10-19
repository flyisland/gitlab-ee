---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 自定义流水线密钥检测
---

<!-- markdownlint-disable MD025 -->

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 极狐GitLab私有化部署

{{< /details >}}

根据您的[订阅层级](_index.md#availability)和配置方法，您可以更改流水线密钥检测的工作方式。

[自定义分析器行为](#customize-analyzer-behavior)以：

- 更改分析器检测的密钥类型。
- 使用不同的分析器版本。
- 使用特定方法扫描您的项目。

[自定义分析器规则集](#customize-analyzer-rulesets)以：

- 检测自定义密钥类型。
- 覆盖默认扫描器规则。

<a id="customize-analyzer-behavior"></a>

## 自定义分析器行为

要更改分析器的行为，请在 `.gitlab-ci.yml` 文件中使用 [`variables`](../../../../../ci/yaml/_index.md#variables) 参数定义变量。

{{< alert type="warning" >}}

所有极狐GitLab安全扫描工具的配置应在合并请求中进行测试，然后再将这些更改合并到默认分支中。如果不这样做，可能会导致意外结果，包括大量误报。

{{< /alert >}}

<a id="add-new-patterns"></a>

### 添加新模式

要在您的仓库中搜索其他类型的密钥，可以[自定义分析器规则集](#customize-analyzer-rulesets)。

要为所有流水线密钥检测用户提出新的检测规则，请[查看我们的规则单一来源](https://gitlab.com/gitlab-org/security-products/secret-detection/secret-detection-rules/-/blob/main/README.md)并按照指导创建合并请求。

如果您运营云或 SaaS 产品，并且有兴趣与极狐GitLab合作以更好地保护您的用户，请了解有关我们[泄露凭证通知合作伙伴计划](../../automatic_response.md#partner-program-for-leaked-credential-notifications)的更多信息。

<a id="pin-to-specific-analyzer-version"></a>

### 固定到特定分析器版本

极狐GitLab管理的 CI/CD 模板指定了一个主要版本，并在该主要版本中自动拉取最新的分析器版本。

在某些情况下，您可能需要使用特定版本。例如，您可能需要避免后续版本中的回归。

要覆盖自动更新行为，请在包含 [`Secret-Detection.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)后，在您的 CI/CD 配置文件中设置 `SECRETS_ANALYZER_VERSION` CI/CD 变量。

您可以将标记设置为：

- 主要版本，例如 `4`。您的流水线使用在此主要版本中发布的任何次要或补丁更新。
- 次要版本，例如 `4.5`。您的流水线使用在此次要版本中发布的任何补丁更新。
- 补丁版本，例如 `4.5.0`。您的流水线不会收到任何更新。

此示例使用分析器的特定次要版本：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

secret_detection:
  variables:
    SECRETS_ANALYZER_VERSION: "4.5"
```

<a id="enable-historic-scan"></a>

### 启用历史扫描

要启用历史扫描，请在 `.gitlab-ci.yml` 文件中将变量 `SECRET_DETECTION_HISTORIC_SCAN` 设置为 `true`。

<a id="run-jobs-in-merge-request-pipelines"></a>

### 在合并请求流水线中运行作业

请参阅[在合并请求流水线中使用安全扫描工具](../../../detect/roll_out_security_scanning.md#use-security-scanning-tools-with-merge-request-pipelines)。

<a id="override-the-analyzer-jobs"></a>

### 覆盖分析器作业

要覆盖作业定义（例如更改 `variables` 或 `dependencies` 等属性），声明一个与 `secret_detection` 作业同名的新作业来覆盖。在模板包含之后放置这个新作业并在其下指定任何附加键。

在以下 `.gitlab-ci.yml` 文件的示例摘录中：

- `Jobs/Secret-Detection` CI 模板被[包含](../../../../../ci/yaml/_index.md#include)。
- 在 `secret_detection` 作业中，CI/CD 变量 `SECRET_DETECTION_HISTORIC_SCAN` 被设置为 `true`。因为模板在流水线配置之前被评估，所以变量的最后一次提及优先，因此进行历史扫描。

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

secret_detection:
  variables:
    SECRET_DETECTION_HISTORIC_SCAN: "true"
```

<a id="available-ci-cd-variables"></a>

### 可用的 CI/CD 变量

通过定义可用的 CI/CD 变量来更改流水线密钥检测的行为：

| CI/CD 变量                     | 默认值       | 描述 |
|----------------------------------|---------------|-------------|
| `SECRET_DETECTION_EXCLUDED_PATHS` | ""            | 根据路径从输出中排除漏洞。这些路径是一个逗号分隔的模式列表。模式可以是 globs（如 `doublestar.Match`，支持的模式），或文件或文件夹路径（例如，`doc,spec`）。父目录也匹配模式。以前添加到漏洞报告的检测到的密钥不会被移除。（在极狐GitLab 13.3 中引入）|
| `SECRET_DETECTION_HISTORIC_SCAN`  | false         | 启用历史 Gitleaks 扫描的 FLAG。 |
| `SECRET_DETECTION_IMAGE_SUFFIX`   | "" | 添加到图像名称的后缀。如果设置为 `-fips`，则使用 `FIPS-enabled` 图像进行扫描。有关更多详细信息，请参阅使用 FIPS-enabled 图像。（在极狐GitLab 14.10 中引入）|
| `SECRET_DETECTION_LOG_OPTIONS`  | ""        | 指定要扫描的提交范围的 FLAG。Gitleaks 使用 `git log` 来确定提交范围。定义后，流水线密钥检测会尝试获取分支中的所有提交。如果分析器无法访问每个提交，它将继续使用已检出的仓库。（在极狐GitLab 15.1 中引入）|

在以前的极狐GitLab版本中，以下变量也可用：

| CI/CD 变量                     | 默认值       | 描述 |
|----------------------------------|---------------|-------------|
| `SECRET_DETECTION_COMMIT_FROM`    | -             | Gitleaks 扫描开始的提交。（在极狐GitLab 13.5 中移除，替换为 `SECRET_DETECTION_COMMITS`）|
| `SECRET_DETECTION_COMMIT_TO`      | -             | Gitleaks 扫描结束的提交。（在极狐GitLab 13.5 中移除，替换为 `SECRET_DETECTION_COMMITS`）|
| `SECRET_DETECTION_COMMITS`        | -             | Gitleaks 应扫描的提交列表。（在极狐GitLab 13.5 中引入，在极狐GitLab 15.0 中移除）|

<a id="customize-analyzer-rulesets"></a>

## 自定义分析器规则集

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 13.5 中引入。
- 在极狐GitLab 14.6 中扩展以包含额外的 `file` 和 `raw` 类型。
- 在极狐GitLab 14.8 中启用对覆盖规则的支持。
- 在极狐GitLab 17.2 中启用对 passthrough 链的支持，并包含额外的 `git` 和 `url` 类型。

{{< /history >}}

您可以通过[创建规则集配置文件](#create-a-ruleset-configuration-file)，在被扫描的仓库或远程仓库中自定义使用流水线密钥检测检测的密钥类型。自定义使您能够修改、替换或扩展默认规则集。

有多种自定义可用：

- 修改**默认规则集中预定义的规则**的行为。这包括：
  - [覆盖默认规则集中的规则](#override-a-rule)。
  - [禁用默认规则集中的规则](#disable-a-rule)。
  - [使用远程规则集禁用或覆盖规则](#with-a-remote-ruleset)。
- 使用 passthrough 替换默认规则集为自定义规则集。这包括：
  - [使用内联规则集配置](#with-an-inline-ruleset)。
  - [使用本地规则集配置](#with-a-local-ruleset)。
  - [使用远程规则集配置](#with-a-remote-ruleset-1)。
  - [使用私有远程规则集配置](#with-a-private-remote-ruleset)。
- 使用 passthrough 扩展默认规则集的行为。这包括：
  - [使用本地规则集配置](#with-a-local-ruleset-1)。
  - [使用远程规则集配置](#with-a-remote-ruleset-2)。
- 使用 Gitleaks 原生功能忽略密钥和路径。这包括：
  - 使用 `Gitleaks 的 [allowlist] 指令`来[忽略模式和路径](#ignore-patterns-and-paths)。
  - 使用 `gitleaks:allow` 注释来[忽略内联密钥](#ignore-secrets-inline)。

<a id="create-a-ruleset-configuration-file"></a>

### 创建规则集配置文件

要创建规则集配置文件：

1. 在项目的根目录创建一个 `.gitlab` 目录，如果尚不存在。
1. 在 `.gitlab` 目录中创建一个名为 `secret-detection-ruleset.toml` 的文件。

<a id="modify-rules-from-the-default-ruleset"></a>

### 修改默认规则集中的规则

您可以修改在[默认规则集中](../../detected_secrets.md)预定义的规则。

修改规则可以帮助您将流水线密钥检测适应现有的工作流程或工具。例如，您可能希望覆盖检测到的密钥的严重性或禁用某个规则的检测。

您还可以使用存储在远程（即远程 Git 仓库或网站）上的规则集配置文件来修改预定义的规则。新规则必须使用[自定义规则格式](custom_rulesets_schema.md#custom-rule-format)。

<a id="disable-a-rule"></a>

#### 禁用规则

{{< history >}}

- 在极狐GitLab 16.0 及更高版本中启用使用远程规则集禁用规则的功能。

{{< /history >}}

您可以禁用不想激活的规则。要禁用分析器默认规则集中的规则：

1. 如果尚不存在，请[创建规则集配置文件](#create-a-ruleset-configuration-file)。
1. 在 [`ruleset` 部分](custom_rulesets_schema.md#the-secretsruleset-section)的上下文中将 `disabled` 标志设置为 `true`。
1. 在一个或多个 `ruleset.identifier` 子部分中列出要禁用的规则。每个[`ruleset.identifier` 部分](custom_rulesets_schema.md#the-secretsrulesetidentifier-section)都有：
   - 一个用于预定义规则标识符的 `type` 字段。
   - 一个用于规则名称的 `value` 字段。

在以下示例 `secret-detection-ruleset.toml` 文件中，禁用的规则通过标识符的 `type` 和 `value` 匹配：

```toml
[secrets]
  [[secrets.ruleset]]
    disable = true
    [secrets.ruleset.identifier]
      type  = "gitleaks_rule_id"
      value = "RSA private key"
```

<a id="override-a-rule"></a>

#### 覆盖规则

{{< history >}}

- 在极狐GitLab 16.0 及更高版本中启用使用远程规则集覆盖规则的功能。

{{< /history >}}

如果有特定规则需要自定义，您可以覆盖它们。例如，您可能会增加某种类型密钥的严重性，因为泄露它会对您的工作流程产生更高影响。

要覆盖分析器默认规则集中的规则：

1. 如果尚不存在，请[创建规则集配置文件](#create-a-ruleset-configuration-file)。
1. 在一个或多个 `ruleset.identifier` 子部分中列出要覆盖的规则。每个[`ruleset.identifier` 部分](custom_rulesets_schema.md#the-secretsrulesetidentifier-section)都有：
   - 一个用于预定义规则标识符的 `type` 字段。
   - 一个用于规则名称的 `value` 字段。
1. 在 [`ruleset.override` 上下文](custom_rulesets_schema.md#the-secretsrulesetoverride-section)中的 [`ruleset` 部分](custom_rulesets_schema.md#the-secretsruleset-section)中提供要覆盖的键。任何组合的键都可以被覆盖。有效的键包括：
   - `description`
   - `message`
   - `name`
   - `severity` （有效选项包括：`Critical`，`High`，`Medium`，`Low`，`Unknown`，`Info`）

在以下 `secret-detection-ruleset.toml` 文件中，规则通过标识符的 `type` 和 `value` 匹配，然后被覆盖：

```toml
[secrets]
  [[secrets.ruleset]]
    [secrets.ruleset.identifier]
      type  = "gitleaks_rule_id"
      value = "RSA private key"
    [secrets.ruleset.override]
      description = "OVERRIDDEN description"
      message     = "OVERRIDDEN message"
      name        = "OVERRIDDEN name"
      severity    = "Info"
```

<a id="with-a-remote-ruleset"></a>

#### 使用远程规则集

**远程规则集是一个配置文件，存储在当前仓库之外**。它可用于跨多个项目修改规则。

要使用远程规则集修改预定义规则，您可以使用 `SECRET_DETECTION_RULESET_GIT_REFERENCE` [CI/CD 变量](../../../../../ci/variables/_index.md)：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

variables:
  SECRET_DETECTION_RULESET_GIT_REFERENCE: "gitlab.com/example-group/remote-ruleset-project"
```

流水线密钥检测假定配置在由 CI 变量引用的仓库中的 `.gitlab/secret-detection-ruleset.toml` 文件中定义，其中存储远程规则集。如果该文件不存在，请确保[创建一个](#create-a-ruleset-configuration-file)并按照上面概述的步骤[覆盖](#override-a-rule)或[禁用](#disable-a-rule)预定义规则。

{{< alert type="note" >}}

项目中的本地 `.gitlab/secret-detection-ruleset.toml` 文件默认情况下优先于 `SECRET_DETECTION_RULESET_GIT_REFERENCE`，因为 `SECURE_ENABLE_LOCAL_CONFIGURATION` 被设置为 `true`。如果将 `SECURE_ENABLE_LOCAL_CONFIGURATION` 设置为 `false`，则忽略本地文件并使用默认配置或 `SECRET_DETECTION_RULESET_GIT_REFERENCE`（如果设置）。

{{< /alert >}}

`SECRET_DETECTION_RULESET_GIT_REFERENCE` 变量使用类似于 [Git URLs](https://git-scm.com/docs/git-clone#_git_urls) 的格式来指定 URI、可选认证和可选 Git SHA。该变量使用以下格式：

```plaintext
<AUTH_USER>:<AUTH_PASSWORD>@<PROJECT_PATH>@<GIT_SHA>
```

如果配置文件存储在需要认证的私有项目中，您可以使用安全存储在 CI 变量中的[群组访问令牌](../../../../group/settings/group_access_tokens.md)来加载远程规则集：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

variables:
  SECRET_DETECTION_RULESET_GIT_REFERENCE: "group_2504721_bot_7c9311ffb83f2850e794d478ccee36f5:$GROUP_ACCESS_TOKEN@gitlab.com/example-group/remote-ruleset-project"
```

群组访问令牌必须具有 `read_repository` 范围和至少 Reporter 角色。有关详细信息，请参阅[仓库权限](../../../../permissions.md#repository)。

请参阅[群组的机器人用户](../../../../group/settings/group_access_tokens.md#bot-users-for-groups)以了解如何找到与群组访问令牌关联的用户名。

<a id="replace-the-default-ruleset"></a>

### 替换默认规则集

您可以使用许多[自定义](custom_rulesets_schema.md)替换默认规则集配置。这些可以通过 [passthroughs](custom_rulesets_schema.md#passthrough-types) 组合成单个配置。

使用 passthroughs，您可以：

- 将最多[20 个 passthroughs](custom_rulesets_schema.md#the-secretspassthrough-section) 链接成一个单独的配置以替换或扩展预定义规则。
- 在 passthroughs 中包含[环境变量](custom_rulesets_schema.md#interpolate)。
- 设置评估 passthroughs 的[超时](custom_rulesets_schema.md#the-secrets-configuration-section)。
- [验证](custom_rulesets_schema.md#the-secrets-configuration-section)每个定义的 passthrough 使用的 TOML 语法。

<a id="with-an-inline-ruleset"></a>

#### 使用内联规则集

您可以使用 [`raw` passthrough](custom_rulesets_schema.md#passthrough-types) 替换默认规则集为内联提供的配置。

为此，请在同一仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整定义在 `[[rules]]` 下的规则：

```toml
[secrets]
  [[secrets.passthrough]]
    type   = "raw"
    target = "gitleaks.toml"
    value  = """
title = "replace default ruleset with a raw passthrough"

[[rules]]
description = "Test for Raw Custom Rulesets"
regex = '''Custom Raw Ruleset T[est]{3}'''
"""
```

上面的示例用一个规则替换默认规则集，该规则检查定义的正则表达式 - `Custom Raw Ruleset T`，后缀为三个字母中的任意一个：`e`、`s` 或 `t`。

有关要使用的 passthrough 语法的更多信息，请参阅[Schema](custom_rulesets_schema.md#schema)。

<a id="with-a-local-ruleset"></a>

#### 使用本地规则集

您可以使用 [`file` passthrough](custom_rulesets_schema.md#passthrough-types) 替换默认规则集为另一个提交到当前仓库的文件。

为此，请在同一仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`，以指向具有本地规则集配置的文件路径：

```toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "config/gitleaks.toml"
```

这将使用 `config/gitleaks.toml` 文件中定义的配置替换默认规则集。

有关要使用的 passthrough 语法的更多信息，请参阅[Schema](custom_rulesets_schema.md#schema)。

<a id="with-a-remote-ruleset-1"></a>

#### 使用远程规则集

您可以使用在远程 Git 仓库或在线存储的文件中定义的配置替换默认规则集，分别使用 `git` 和 `url` passthroughs。

远程规则集可以跨多个项目使用。例如，您可能希望将相同的规则集应用于您的命名空间中的多个项目，在这种情况下，您可以使用任一类型的 passthrough 加载远程规则集，并让多个项目使用它。这也使规则集的集中管理成为可能，只有授权人员才能编辑。

要使用 `git` passthrough，请在仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并调整 `value` 以指向 Git 仓库的地址：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

在此配置中，分析器从存储在 `user_group/central_repository_with_shared_ruleset` 仓库的 `main` 分支的 `config` 目录中的 `gitleaks.toml` 文件中加载规则集。然后，您可以继续在 `user_group/basic_repository` 之外的项目中包含相同的配置。

或者，您可以使用 `url` passthrough 来替换默认规则集为远程规则集配置。

要使用 `url` passthrough，请在仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并调整 `value` 以指向远程文件的地址：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "url"
    target = "gitleaks.toml"
    value  = "https://example.com/gitleaks.toml"
```

在此配置中，分析器从提供的地址存储的 `gitleaks.toml` 文件加载规则集配置。

有关要使用的 passthrough 语法的更多信息，请参阅[Schema](custom_rulesets_schema.md#schema)。

<a id="with-a-private-remote-ruleset"></a>

#### 使用私有远程规则集

如果规则集配置存储在私有仓库中，则必须使用 passthrough 的 [`auth` 设置](custom_rulesets_schema.md#the-secretspassthrough-section)提供访问仓库的凭证。

{{< alert type="note" >}}

`auth` 设置仅适用于 `git` passthrough。

{{< /alert >}}

要使用存储在私有仓库中的远程规则集，请在仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，调整 `value` 以指向 Git 仓库的地址，并更新 `auth` 以使用适当的凭证：

```toml
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    auth   = "USERNAME:PASSWORD" # replace USERNAME and PASSWORD as appropriate
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

{{< alert type="warning" >}}

使用此功能时，请注意泄露凭证。请检查[此部分](custom_rulesets_schema.md#interpolate)以获取有关如何使用环境变量来最大限度地降低风险的示例。

{{< /alert >}}

有关要使用的 passthrough 语法的更多信息，请参阅[Schema](custom_rulesets_schema.md#schema)。

<a id="extend-the-default-ruleset"></a>

### 扩展默认规则集

您还可以根据需要使用其他规则扩展[默认规则集](../../detected_secrets.md)配置。当您仍希望从极狐GitLab在默认规则集中维护的高置信度预定义规则中受益，但也希望添加用于您自己项目和命名空间中可能使用的密钥类型的规则时，这将非常有用。新规则必须遵循[自定义规则格式](custom_rulesets_schema.md#custom-rule-format)。

<a id="with-a-local-ruleset-1"></a>

#### 使用本地规则集

您可以使用 `file` passthrough 扩展默认规则集以添加其他规则。

在同一仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

存储在 `extended-gitleaks-config.toml` 中的扩展配置将包含在分析器在 CI/CD 流水线中使用的配置中。

在下面的示例中，我们添加了几个新的 `[[rules]]` 部分，这些部分定义了一些要检测的正则表达式：

```toml
# extended-gitleaks-config.toml
[extend]
# Extends default packaged ruleset, NOTE: do not change the path.
path = "/gitleaks.toml"

[[rules]]
  id = "example_api_key"
  description = "Example Service API Key"
  regex = '''example_api_key'''

[[rules]]
  id = "example_api_secret"
  description = "Example Service API Secret"
  regex = '''example_api_secret'''
```

使用此规则集配置，分析器会检测与这些两个定义的正则表达式匹配的任何字符串。

有关要使用的 passthrough 语法的更多信息，请参阅[Schema](custom_rulesets_schema.md#schema)。

<a id="with-a-remote-ruleset-2"></a>

#### 使用远程规则集

与您可以使用远程规则集替换默认规则集的方式类似，您还可以使用存储在远程 Git 仓库中的配置或存储在仓库之外的文件扩展默认规则集，该仓库中您拥有 `.gitlab/secret-detection-ruleset.toml` 配置文件。

这可以通过使用之前讨论过的 `git` 或 `url` passthroughs 来实现。

要使用 `git` passthrough 来实现这一点，请在同一仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`、`ref` 和 `subdir`，以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

流水线密钥检测假定远程规则集配置文件名为 `gitleaks.toml`，并存储在引用仓库的 `main` 分支上的 `config` 目录中。

要扩展默认规则集，`gitleaks.toml` 文件应使用 `[extend]` 指令，类似于上面的示例：

```toml
# https://gitlab.com/user_group/central_repository_with_shared_ruleset/-/raw/main/config/gitleaks.toml
[extend]
# Extends default packaged ruleset, NOTE: do not change the path.
path = "/gitleaks.toml"

[[rules]]
  id = "example_api_key"
  description = "Example Service API Key"
  regex = '''example_api_key'''

[[rules]]
  id = "example_api_secret"
  description = "Example Service API Secret"
  regex = '''example_api_secret'''
```

要使用 `url` passthrough，请在同一仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`，以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "url"
    target = "gitleaks.toml"
    value  = "https://example.com/gitleaks.toml"
```

有关要使用的 passthrough 语法的更多信息，请参阅[Schema](custom_rulesets_schema.md#schema)。

<a id="ignore-patterns-and-paths"></a>

### 忽略模式和路径

在某些情况下，您可能需要忽略流水线密钥检测检测的某个模式或路径。例如，您可能有一个文件包含用于测试套件的假密钥。

在这种情况下，您可以利用 Gitleaks 原生的 `allowlist` 指令来忽略特定模式或路径。

{{< alert type="note" >}}

无论您使用的是本地还是远程规则集配置文件，此功能均可用。以下示例使用的是使用 `file` passthrough 的本地规则集。

{{< /alert >}}

要忽略某个模式，请在同一仓库中存储的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`，以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

存储在 `extended-gitleaks-config.toml` 中的扩展配置将包含在分析器使用的配置中。

在下面的示例中，我们添加了一个 `[allowlist]` 指令，该指令定义了一个匹配要忽略（“允许”）的密钥的正则表达式：

```toml
# extended-gitleaks-config.toml
[extend]
# Extends default packaged ruleset, NOTE: do not change the path.
path = "/gitleaks.toml"

[allowlist]
  description = "allowlist of patterns to ignore in detection"
  regexTarget = "match"
  regexes = [
    '''glpat-[0-9a-zA-Z_\\-]{20}'''
  ]
```

这将忽略任何字符串匹配 `glpat-`，后缀为 20 个数字和字母字符。

同样，您可以排除特定路径的扫描。在下面的示例中，我们在 `[allowlist]` 指令下定义了一个要忽略的路径数组。路径可以是正则表达式，也可以是特定文件路径：

```toml
# extended-gitleaks-config.toml
[extend]
# Extends default packaged ruleset, NOTE: do not change the path.
path = "/gitleaks.toml"

[allowlist]
  description = "allowlist of patterns to ignore in detection"
  paths = [
    '''/gitleaks.toml''',
    '''(.*?)(jpg|gif|doc|pdf|bin|svg|socket)'''
  ]
```

这将忽略在 `/gitleaks.toml` 文件或任何以指定扩展名结尾的文件中检测到的任何密钥。

有关要使用的 passthrough 语法的更多信息，请参阅[Schema](custom_rulesets_schema.md#schema)。

<a id="ignore-secrets-inline"></a>

### 内联忽略密钥

在某些情况下，您可能希望内联忽略某个密钥。例如，您可能在示例或测试套件中有一个假密钥。在这些情况下，您将希望忽略密钥，而不是将其报告为漏洞。

要忽略某个密钥，请在包含密钥的行添加 `gitleaks:allow` 作为注释。

例如：

```ruby
"A personal token for GitLab will look like glpat-JUST20LETTERSANDNUMB"  # gitleaks:allow
```

<a id="detecting-complex-strings"></a>

### 检测复杂字符串

[默认规则集](_index.md#detected-secrets)提供了检测低误报率结构化字符串的模式。但是，您可能希望检测更复杂的字符串，例如密码。由于Gitleaks 不支持前瞻或后顾，编写一个高置信度的通用规则来检测非结构化字符串是不可能的。

尽管您无法检测到所有复杂字符串，但您可以扩展您的规则集以满足特定用例。

例如，此规则修改了 Gitleaks 默认规则集中的 `generic-api-key` 规则：

```regex
(?i)(?:pwd|passwd|password)(?:[0-9a-z\-_\t .]{0,20})(?:[\s|']|[\s|"]){0,3}(?:=|>|=:|:{1,3}=|\|\|:|<=|=>|:|\?=)(?:'|\"|\s|=|\x60){0,5}([0-9a-z\-_.=\S_]{3,50})(?:['|\"|\n|\r|\s|\x60|;]|$)
```

此正则表达式匹配：

1. 一个不区分大小写的标识符，以 `pwd`、`passwd` 或 `password` 开头。您可以使用其他变体进行调整，例如 `secret` 或 `key`。
1. 跟随标识符的后缀。后缀是数字、字母和符号的组合，长度在零到 23 个字符之间。
1. 常用的赋值运算符，例如 `=`、`:=`、`:` 或 `=>`。
1. 一个密钥前缀，通常用作边界以帮助检测密钥。
1. 一个由数字、字母和符号组成的字符串，长度在 3 到 50 个字符之间。这就是密钥本身。如果您期望更长的字符串，可以调整长度。
1. 一个密钥后缀，通常用作边界。这匹配常见的结束方式，例如勾号、换行符和新行。

以下是该正则表达式匹配的示例字符串：

```plaintext
pwd = password1234
passwd = 'p@ssW0rd1234'
password = thisismyverylongpassword
password => mypassword
password := mypassword
password: password1234
"password" = "p%ssward1234"
'password': 'p@ssW0rd1234'
```

要使用此正则表达式，请使用本文档中记录的方法扩展您的规则集。

例如，假设您希望扩展默认规则集[使用本地规则集](#with-a-local-ruleset-1)并包含此规则。

在存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容。调整 `value` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

在 `extended-gitleaks-config.toml` 文件中，添加一个新的 `[[rules]]` 部分，并使用您要使用的正则表达式：

```toml
# extended-gitleaks-config.toml
[extend]
# Extends default packaged ruleset, NOTE: do not change the path.
path = "/gitleaks.toml"

[[rules]]
  description = "Generic Password Rule"
  id = "generic-password"
  regex = '''(?i)(?:pwd|passwd|password)(?:[0-9a-z\-_\t .]{0,20})(?:[\s|']|[\s|"]){0,3}(?:=|>|=:|:{1,3}=|\|\|:|<=|=>|:|\?=)(?:'|\"|\s|=|\x60){0,5}([0-9a-z\-_.=\S_]{3,50})(?:['|\"|\n|\r|\s|\x60|;]|$)'''
  entropy = 3.5
  keywords = ["pwd", "passwd", "password"]
```

{{< alert type="note" >}}

此示例配置仅为方便提供，可能无法满足所有用例。如果您将规则集配置为检测复杂字符串，您可能会产生大量误报，或未能捕获某些模式。

{{< /alert >}}

<a id="demonstrations"></a>

### 演示

有一些[演示项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection)，展示了一些这些配置选项。

以下是演示项目及其相关工作流的表格：

| 动作/工作流         | 适用于/通过   | 使用内联或本地规则集 | 使用远程规则集 |
|-------------------|------------------|--------------|---------------------|
| 禁用规则          | 预定义规则 | 本地规则集 / 项目   | 远程规则集 / 项目 |
| 覆盖规则         | 预定义规则 | 本地规则集 / 项目 | 远程规则集 / 项目 |
| 替换默认规则集 | 文件 Passthrough | 本地规则集 / 项目 | 不适用      |
| 替换默认规则集 | 原始 Passthrough  | 内联规则集 / 项目| 不适用      |
| 替换默认规则集 | Git Passthrough  | 不适用| 远程规则集 / 项目 |
| 替换默认规则集 | URL Passthrough  | 不适用| 远程规则集 / 项目 |
| 扩展默认规则集  | 文件 Passthrough | 本地规则集 / 项目 | 不适用      |
| 扩展默认规则集  | Git Passthrough  | 不适用| 远程规则集 / 项目 |
| 扩展默认规则集  | URL Passthrough  | 不适用| 远程规则集 / 项目 |
| 忽略路径            | 文件 Passthrough | 本地规则集 / 项目 | 不适用      |
| 忽略路径            | Git Passthrough  | 不适用| 远程规则集 / 项目 |
| 忽略路径            | URL Passthrough  | 不适用| 远程规则集 / 项目 |
| 忽略模式           | File Passthrough | 本地规则集/项目 | 不适用      |
| 忽略模式           | Git Passthrough  | 不适用| 远程规则集 / 项目 |
| 忽略模式           | URL Passthrough  | 不适用| 远程规则集 / 项目 |
| 忽略值             | File Passthrough | 本地规则集/项目| 不适用      |
| 忽略值             | Git Passthrough  | 不适| 远程规则集 / 项目 |
| 忽略值             | URL Passthrough  | 不适用| 远程规则集 / 项目 |


<a id="offline-configuration"></a>

## 离线配置

{{< details >}}

- 层级：专业版，旗舰版
- 提供：私有化部署

{{< /details >}}

离线环境对通过互联网访问外部资源有限制或不定期可用。对于处于这种环境中的实例，流水线秘密检测需要进行一些配置更改。本节中的说明必须与[离线环境](../../../offline_deployments/_index.md)中详细说明的指令一起完成。

<a id="configure-gitlab-runner"></a>

### 配置极狐GitLab Runner

默认情况下，即使本地有副本，runner 也会尝试从极狐GitLab 容器镜像仓库拉取 Docker 镜像。您应该使用此默认设置，以确保 Docker 镜像保持最新。然而，如果没有网络连接，则必须更改默认的极狐GitLab Runner `pull_policy` 变量。

将极狐GitLab Runner CI/CD 变量 `pull_policy` 配置为[`if-not-present`](https://gitlab.cn/docs/runner/executors/docker.html#using-the-if-not-present-pull-policy)。

<a id="use-local-pipeline-secret-detection-analyzer-image"></a>

### 使用本地流水线秘密检测分析器镜像

如果您希望从本地 Docker 注册表而不是极狐GitLab 容器镜像仓库获取镜像，请使用本地流水线秘密检测分析器镜像。

前提条件：

- 将 Docker 镜像导入本地离线 Docker 注册表取决于您的网络安全策略。请咨询您的 IT 人员，以找到接受和批准的流程来导入或临时访问外部资源。

1. 将默认的流水线秘密检测分析器镜像从 `registry.gitlab.com` 导入到您的[本地 Docker 容器镜像仓库](../../../../packages/container_registry/_index.md)：

   ```plaintext
   registry.gitlab.com/security-products/secrets:6
   ```

   流水线秘密检测分析器的镜像是[定期更新的](../../../detect/vulnerability_scanner_maintenance.md)，因此您应该定期更新本地副本。

1. 将 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 设置为本地 Docker 容器镜像仓库。

   ```yaml
   include:
     - template: Jobs/Secret-Detection.gitlab-ci.yml

   variables:
     SECURE_ANALYZERS_PREFIX: "localhost:5000/analyzers"
   ```

流水线秘密检测作业现在应该使用分析器 Docker 镜像的本地副本，而不需要互联网访问。

<a id="using-a-custom-ssl-ca-certificate-authority"></a>

## 使用自定义 SSL CA 证书颁发机构

要信任自定义证书颁发机构，请将 `ADDITIONAL_CA_CERT_BUNDLE` 变量设置为您信任的 CA 证书包。可以在 `.gitlab-ci.yml` 文件中、文件变量中或作为 CI/CD 变量进行设置。

- 在 `.gitlab-ci.yml` 文件中，`ADDITIONAL_CA_CERT_BUNDLE` 值必须包含X.509 PEM 公钥证书的文本表示。

  例如：

  ```yaml
  variables:
    ADDITIONAL_CA_CERT_BUNDLE: |
        -----BEGIN CERTIFICATE-----
        MIIGqTCCBJGgAwIBAgIQI7AVxxVwg2kch4d56XNdDjANBgkqhkiG9w0BAQsFADCB
        ...
        jWgmPqF3vUbZE0EyScetPJquRFRKIesyJuBFMAs=
        -----END CERTIFICATE-----
  ```

- 如果使用文件变量，将 `ADDITIONAL_CA_CERT_BUNDLE` 的值设置为证书的路径。

- 如果使用变量，将 `ADDITIONAL_CA_CERT_BUNDLE` 的值设置为证书的文本表示。
