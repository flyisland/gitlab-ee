---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义流水线密钥检测
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

根据您的[订阅层级](_index.md#availability)和配置方法，您可以更改流水线密钥检测的工作方式。

[自定义分析器行为](#customize-analyzer-behavior)以：

- 更改分析器检测的密钥类型。
- 使用其他分析器版本。
- 使用特定方法扫描您的项目。

[自定义分析器规则集](#customize-analyzer-rulesets)以：

- 检测自定义密钥类型。
- 覆盖默认扫描器规则。

<a id="customize-analyzer-behavior"></a>

## 自定义分析器行为

要更改分析器的行为，请在`.gitlab-ci.yml`中使用 [`variables`](../../../../ci/yaml/_index.md#variables) 参数定义变量。

> [!warning]
> 极狐GitLab 安全扫描工具的所有配置都应先在合并请求中测试，然后再将这些更改合并到默认分支。否则可能会产生意外结果，包括大量误报。

<a id="add-new-patterns"></a>

### 添加新模式

要在您的代码仓库中搜索其他类型的密钥，您可以[自定义分析器规则集](#customize-analyzer-rulesets)。

<a id="propose-new-detection-rules"></a>

### 提议新的检测规则

您可以通过两种方式为所有流水线密钥检测用户提议新的检测规则：

- 请求新规则：使用[密钥检测模式变更议题模板](https://gitlab.com/gitlab-org/gitlab/-/work_items/new?description_template=Secret_Detection_Pattern_Change)创建议题。GitLab 团队将审核该请求，并与您联系以决定如何以及何时实施新规则。
- 贡献新规则：如果您想自行贡献规则，请遵循密钥检测规则代码仓库中的[贡献指南](https://gitlab.com/gitlab-org/security-products/secret-detection/secret-detection-rules/-/blob/main/README.md#adding-new-rules)。

如果您运营云或 SaaS 产品，并且有兴趣与 GitLab 合作以更好地保护您的用户，请参阅 GitLab [泄露凭据通知合作伙伴计划](../automatic_response.md#partner-program-for-leaked-credential-notifications)。

<a id="pin-to-specific-analyzer-version"></a>

### 固定到特定分析器版本

GitLab 管理的 CI/CD 模板指定了一个主版本，并自动拉取该主版本内的最新分析器版本。

在某些情况下，您可能需要使用特定版本。例如，您可能需要避免后续版本中的回归问题。

要覆盖自动更新行为，请在包含 [`Secret-Detection.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)之后，在您的 CI/CD 配置文件中设置 `SECRETS_ANALYZER_VERSION` CI/CD 变量。

您可以将标签设置为：

- 主版本，例如 `4`。您的流水线将使用该主版本内发布的任何次版本或补丁更新。
- 次版本，例如 `4.5`。您的流水线将使用该次版本内发布的任何补丁更新。
- 补丁版本，例如 `4.5.0`。您的流水线不会收到任何更新。

此示例使用分析器的特定次版本：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

secret_detection:
  variables:
    SECRETS_ANALYZER_VERSION: "4.5"
```

<a id="enable-historic-scan"></a>

### 启用历史扫描

要启用历史扫描，请在`.gitlab-ci.yml` 文件中将变量 `SECRET_DETECTION_HISTORIC_SCAN` 设置为 `true`。

<a id="run-jobs-in-merge-request-pipelines"></a>

### 在合并请求流水线中运行作业

请参阅[在合并请求流水线中使用安全扫描工具](../../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。

<a id="override-the-analyzer-jobs"></a>

### 覆盖分析器作业

要覆盖作业定义（例如，更改 `variables` 或 `dependencies` 等属性），请声明一个与 `secret_detection` 作业同名的作业以进行覆盖。将此新作业放在模板包含之后，并在其下指定任何其他键。

在以下`.gitlab-ci.yml` 文件摘录中：

- `Jobs/Secret-Detection` CI/CD 模板已[包含](../../../../ci/yaml/_index.md#include)。
- 在 `secret_detection` 作业中，CI/CD 变量 `SECRET_DETECTION_HISTORIC_SCAN` 设置为
  `true`。由于模板在流水线配置之前求值，最后提及的
  变量优先，因此会执行历史扫描。

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

secret_detection:
  variables:
    SECRET_DETECTION_HISTORIC_SCAN: "true"
```

<a id="available-cicd-variables"></a>

### 可用的 CI/CD 变量

通过定义可用的 CI/CD 变量来更改流水线密钥检测的行为：

| CI/CD 变量                    | 默认值 | 描述 |
|-----------------------------------|---------------|-------------|
| `SECRET_DETECTION_EXCLUDED_PATHS` | ""            | 根据路径从输出中排除漏洞。路径是以逗号分隔的模式列表。模式可以是 glob（有关支持的模式，请参阅 [`doublestar.Match`](https://pkg.go.dev/github.com/bmatcuk/doublestar/v4@v4.0.2#Match)），也可以是文件或文件夹路径（例如 `doc,spec`）。父目录也会匹配模式。之前已添加到漏洞报告中的检测到的密钥不会被移除。 |
| `SECRET_DETECTION_HISTORIC_SCAN`  | false         | 用于启用历史 Gitleaks 扫描的功能标志。 |
| `SECRET_DETECTION_IMAGE_SUFFIX`   | "" | 添加到镜像名称的后缀。如果设置为`-fips`，则使用 `FIPS-enabled` 镜像进行扫描。有关更多详细信息，请参阅[使用启用 FIPS 的镜像](_index.md#fips-enabled-images)。 |
| `SECRET_DETECTION_LOG_OPTIONS`  | ""        | 用于指定要扫描的提交范围的功能标志。Gitleaks 使用 [`git log`](https://git-scm.com/docs/git-log) 来确定提交范围。定义后，流水线密钥检测会尝试获取分支中的所有提交。如果分析器无法访问每个提交，则会继续使用已检出的代码仓库。 |

<a id="customize-analyzer-rulesets"></a>

## 自定义分析器规则集

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

您可以通过创建自定义规则集配置文件来自定义流水线密钥检测所检测的密钥类型，该文件可以位于被扫描的代码仓库中，也可以位于远程代码仓库中。

自定义使您能够：

- 修改默认规则集中规则的行为。
- 用自定义规则集替换默认规则集。
- 扩展默认规则集的行为。
- 忽略密钥和路径。

<a id="create-a-ruleset-configuration-file"></a>

### 创建规则集配置文件

要创建规则集配置文件：

1. 在项目根目录下创建一个`.gitlab` 目录（如果尚不存在）。
1. 在`.gitlab` 目录中创建一个名为 `secret-detection-ruleset.toml`的文件。

<a id="modify-rules-from-the-default-ruleset"></a>

### 修改默认规则集中的规则

您可以修改[默认规则集](../detected_secrets.md)中预定义的规则。

修改规则可以帮助您将流水线密钥检测适配到现有工作流或工具。例如，您可能想要覆盖检测到的密钥的严重性，或者完全禁用某个规则的检测。

您还可以使用远程存储的规则集配置文件（即远程 Git 代码仓库或网站）来修改预定义规则。新规则必须使用[自定义规则格式](custom_rulesets_schema.md#custom-rule-format)。

<a id="disable-a-rule"></a>

#### 禁用规则

您可以禁用不希望启用的规则。要从分析器默认规则集中禁用规则：

1. [创建规则集配置文件](#create-a-ruleset-configuration-file)（如果尚不存在）。
1. 在 [`ruleset` 部分](custom_rulesets_schema.md#the-secretsruleset-section)的上下文中，将 `disabled` 标志设置为 `true`。
1. 在一个或多个 `ruleset.identifier` 子部分中，列出要禁用的规则。每个
   [`ruleset.identifier` 部分](custom_rulesets_schema.md#the-secretsrulesetidentifier-section)都有：
   - 一个 `type` 字段，用于预定义规则标识符。
   - 一个 `value` 字段，用于规则名称。

在以下 `secret-detection-ruleset.toml` 文件中，禁用的规则通过标识符的 `type` 和 `value` 进行匹配：

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

如果有需要自定义的特定规则，您可以覆盖它们。例如，您可能提高某种特定类型密钥的严重性，因为泄露它会对您的工作流产生更大的影响。

要覆盖分析器默认规则集中的规则：

1. [创建规则集配置文件](#create-a-ruleset-configuration-file)（如果尚不存在）。
1. 在一个或多个 `ruleset.identifier` 子部分中，列出要覆盖的规则。每个
   [`ruleset.identifier` 部分](custom_rulesets_schema.md#the-secretsrulesetidentifier-section)都有：
   - 一个 `type` 字段，用于预定义规则标识符。
   - 一个 `value` 字段，用于规则名称。
1. 在 [`ruleset` 部分](custom_rulesets_schema.md#the-secretsruleset-section)的 [`ruleset.override` 上下文](custom_rulesets_schema.md#the-secretsrulesetoverride-section)中，提供要覆盖的键。可以覆盖任意键组合。有效的键有：
   - `description`
   - `message`
   - `name`
   - `severity`（有效选项有：`Critical`、`High`、`Medium`、`Low`、`Unknown`、`Info`）

在以下 `secret-detection-ruleset.toml` 文件中，规则通过标识符的 `type` 和 `value` 进行匹配，然后被覆盖：

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

远程规则集是存储在当前代码仓库外部的配置文件。它可用于跨多个项目修改规则。

要使用远程规则集修改预定义规则，您可以使用 `SECRET_DETECTION_RULESET_GIT_REFERENCE` [CI/CD 变量](../../../../ci/variables/_index.md)：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

variables:
  SECRET_DETECTION_RULESET_GIT_REFERENCE: "gitlab.com/example-group/remote-ruleset-project"
```

流水线密钥检测假定配置定义在存储远程规则集的 CI/CD 变量所引用代码仓库中的`.gitlab/secret-detection-ruleset.toml` 文件中。如果该文件不存在，请确保[创建一个](#create-a-ruleset-configuration-file)，并按照前面概述的步骤[覆盖](#override-a-rule)或[禁用](#disable-a-rule)预定义规则。

> [!note]
> 项目中的本地`.gitlab/secret-detection-ruleset.toml` 文件默认优先于 `SECRET_DETECTION_RULESET_GIT_REFERENCE`，因为 `SECURE_ENABLE_LOCAL_CONFIGURATION` 设置为 `true`。
> 如果您将 `SECURE_ENABLE_LOCAL_CONFIGURATION` 设置为 `false`，则本地文件会被忽略，并使用默认配置或 `SECRET_DETECTION_RULESET_GIT_REFERENCE`（如果已设置）。

`SECRET_DETECTION_RULESET_GIT_REFERENCE` 变量使用类似于 [Git URL](https://git-scm.com/docs/git-clone#_git_urls)的格式来指定 URI、可选身份验证和可选 Git SHA。该变量使用以下格式：

```plaintext
<AUTH_USER>:<AUTH_PASSWORD>@<PROJECT_PATH>@<GIT_SHA>
```

如果配置文件存储在需要身份验证的私有项目中，您可以使用安全存储在 CI/CD 变量中的[群组访问令牌](../../../group/settings/group_access_tokens.md)来加载远程规则集：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

variables:
  SECRET_DETECTION_RULESET_GIT_REFERENCE: "group_2504721_bot_7c9311ffb83f2850e794d478ccee36f5:$GROUP_ACCESS_TOKEN@gitlab.com/example-group/remote-ruleset-project"
```

群组访问令牌必须具有 `read_repository` 范围以及报告者、开发者、维护者或所有者角色。有关详细信息，请参阅[代码仓库权限](../../../permissions.md#project-repositories)。

请参阅[群组的机器人用户](../../../group/settings/group_access_tokens.md#bot-users-for-groups)，了解如何查找与群组访问令牌关联的用户名。

<a id="replace-the-default-ruleset"></a>

### 替换默认规则集

您可以使用[自定义](custom_rulesets_schema.md)来替换默认规则集配置。这些自定义可以通过[透传](custom_rulesets_schema.md#passthrough-types)组合成单个配置。

使用透传，您可以：

- 将最多 [20 个透传](custom_rulesets_schema.md#the-secretspassthrough-section)链接到单个配置中，以替换或扩展预定义规则。
- 在[透传中包含环境变量](custom_rulesets_schema.md#interpolate)。
- 为透传求值设置[超时](custom_rulesets_schema.md#the-secrets-configuration-section)。
- [验证](custom_rulesets_schema.md#the-secrets-configuration-section)每个已定义透传中使用的 TOML 语法。

<a id="with-an-inline-ruleset"></a>

#### 使用内联规则集

您可以使用 [`raw` 透传](custom_rulesets_schema.md#passthrough-types)以内联提供的配置替换默认规则集。

在存储于同一代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整`[[rules]]`下定义的规则：

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

前面的示例将默认规则集替换为一条规则，该规则检查所定义的正则表达式——`Custom Raw Ruleset T`，其后缀为 3 个字符，来自 `e`、`s` 或 `t` 字母中的任意一个。

有关要使用的透传语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-local-ruleset"></a>

#### 使用本地规则集

您可以使用 [`file` 透传](custom_rulesets_schema.md#passthrough-types)以提交到当前代码仓库的另一个文件替换默认规则集。

在存储于同一代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`，使其指向包含本地规则集配置的文件的路径：

```toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "config/gitleaks.toml"
```

这会将默认规则集替换为 `config/gitleaks.toml` 文件中定义的配置。

有关要使用的透传语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-remote-ruleset-1"></a>

#### 使用远程规则集

您可以使用 `git` 和 `url` 透传，以远程 Git 代码仓库中定义的配置或存储在网络某处的文件替换默认规则集。

远程规则集可以跨多个项目使用。例如，您可能希望将同一规则集应用于某个命名空间中的多个项目，在这种情况下，您可以使用任一类型的透传来加载该远程规则集，并让多个项目使用它。它还支持对规则集进行集中管理，只有获得授权的人员才能编辑。

要使用 `git` 透传，请在存储于代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并调整 `value` 以指向 Git 代码仓库的地址：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

在此配置中，分析器从存储于 `user_group/central_repository_with_shared_ruleset`的代码仓库的 `main` 分支中 `config` 目录内的 `gitleaks.toml` 文件加载规则集。然后，您可以继续在 `user_group/basic_repository` 以外的项目中包含相同的配置。

或者，您可以使用 `url` 透传，以远程规则集配置替换默认规则集。

要使用 `url` 透传，请在存储于代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并调整 `value` 以指向远程文件的地址：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "url"
    target = "gitleaks.toml"
    value  = "https://example.com/gitleaks.toml"
```

在此配置中，分析器从存储在所提供地址的 `gitleaks.toml` 文件加载规则集配置。

有关要使用的透传语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-private-remote-ruleset"></a>

#### 使用私有远程规则集

如果规则集配置存储在私有代码仓库中，您必须通过透传的 [`auth` 设置](custom_rulesets_schema.md#the-secretspassthrough-section)提供访问该代码仓库的凭据。

> [!note]
> `auth` 设置仅适用于 `git` 透传。

要使用存储在私有代码仓库中的远程规则集，请在存储于代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，调整 `value` 以指向 Git 代码仓库的地址，并更新 `auth` 以使用适当的凭据：

```toml
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    auth   = "USERNAME:PASSWORD" # replace USERNAME and PASSWORD as appropriate
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

> [!warning]
> 使用此功能时请注意凭据泄露。请查看[此部分](custom_rulesets_schema.md#interpolate)了解如何使用环境变量来最小化风险的示例。

有关要使用的透传语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="turn-on-beta-rules"></a>

### 开启测试版规则

测试版规则是实验性检测规则，不属于默认规则集。在规则被提升到默认规则集之前，可使用测试版规则检测其他密钥类型。

> [!warning]
> 测试版规则是实验性的。它们可能比默认规则产生更多误报。
> 它们可能会在不另行通知的情况下更改或移除。请仔细审查测试版规则的发现结果。

分析器镜像在`/beta.toml` 处包含一个测试版规则集。此规则集包含所有默认规则以及成熟度为 `beta`的规则。除非您选择启用，否则分析器不会加载测试版规则集。

要开启测试版规则，请使用 [`file` 透传](custom_rulesets_schema.md#passthrough-types)，以捆绑的测试版规则集替换默认规则集。在存储于同一代码仓库的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容：

```toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "/beta.toml"
```

测试版规则集已包含默认规则，因此您无需单独扩展默认规则集。

<a id="extend-the-default-ruleset"></a>

### 扩展默认规则集

您还可以根据需要向[默认规则集](../detected_secrets.md)配置中添加其他规则来扩展它。当您仍希望受益于 GitLab 在默认规则集中维护的高置信度预定义规则，但又想为可能在您自己的项目和命名空间中使用的密钥类型添加规则时，这会很有帮助。新规则必须遵循[自定义规则格式](custom_rulesets_schema.md#custom-rule-format)。

<a id="with-a-local-ruleset-1"></a>

#### 使用本地规则集

您可以使用 `file` 透传来扩展默认规则集以添加其他规则。

在存储于同一代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`，使其指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

存储在 `extended-gitleaks-config.toml`中的扩展配置会包含在分析器于 CI/CD 流水线中使用的配置中。

下面的示例添加了新的`[[rules]]`部分，其中包含要匹配的正则表达式：

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

使用此规则集配置，分析器会检测与所定义正则表达式模式匹配的任何字符串。

有关要使用的透传语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-remote-ruleset-2"></a>

#### 使用远程规则集

与您可以使用远程规则集替换默认规则集类似，您也可以使用存储在远程 Git 代码仓库中的配置，或存储在包含`.gitlab/secret-detection-ruleset.toml` 配置文件的代码仓库外部的文件来扩展默认规则集。

这可以通过使用前面讨论的 `git` 或 `url` 透传中的任一种来实现。

要使用 `git` 透传实现这一点，请在存储于同一代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`、`ref` 和 `subdir`，使其指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

流水线密钥检测假定远程规则集配置文件名为 `gitleaks.toml`，并存储在所引用代码仓库的 `main` 分支上的 `config` 目录中。

要扩展默认规则集，`gitleaks.toml` 文件应使用与前面示例类似的`[extend]`指令：

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

要使用 `url` 透传，请在存储于同一代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`，使其指向扩展配置文件的路径

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "url"
    target = "gitleaks.toml"
    value  = "https://example.com/gitleaks.toml"
```

有关要使用的透传语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-scan-execution-policy"></a>

#### 使用扫描执行策略

要使用扫描执行策略扩展并强制执行规则集：

- 遵循[使用扫描执行策略设置流水线密钥检测配置](https://gitlab.cn/support)中的步骤。

<a id="ignore-patterns-and-paths"></a>

### 忽略模式和路径

在某些情况下，您可能需要忽略某个模式或路径，使其不被流水线密钥检测检测到。例如，您可能有一个包含假密钥的文件，用于测试套件。

在这种情况下，您可以使用 [Gitleaks 原生的`[allowlist]`](https://github.com/gitleaks/gitleaks#configuration) 指令来忽略特定模式或路径。

> [!note]
> 无论您使用的是本地还是远程规则集配置文件，此功能都有效。
> 不过，下面的示例使用通过 `file` 透传的本地规则集。

要忽略某个模式，请在存储于同一代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value`，使其指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

存储在 `extended-gitleaks-config.toml`中的扩展配置会包含在分析器使用的配置中。

下面的示例添加了一个`[allowlist]`指令，该指令定义了一个正则表达式，用于匹配要忽略（“允许”）的密钥：

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

这会忽略任何匹配 `glpat-`且后缀为 20 个数字和字母字符的字符串。

同样，您可以从扫描中排除特定路径。下面的示例在`[allowlist]`指令下定义了一个要忽略的路径数组。路径可以是正则表达式，也可以是特定文件路径：

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

这会忽略在`/gitleaks.toml` 文件或任何以指定扩展名之一结尾的文件中检测到的任何密钥。

从 [Gitleaks v8.20.0](https://github.com/gitleaks/gitleaks/releases/tag/v8.20.0) 开始，您还可以将 `regexTarget` 与`[allowlist]`一起使用。这意味着您可以通过覆盖现有规则来配置[个人访问令牌前缀](../../../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)或[自定义实例前缀](../../../../administration/settings/account_and_limit_settings.md#instance-token-prefix)。例如，对于 `personal access tokens`，您可以配置：

```toml
# extended-gitleaks-config.toml
[extend]
# Extends default packaged ruleset, NOTE: do not change the path.
path = "/gitleaks.toml"

[[rules]]
# Rule id you want to override:
id = "gitlab_personal_access_token"
# all the other attributes from the default rule are inherited
    [[rules.allowlists]]
    regexTarget = "line"
    regexes = [ '''CUSTOMglpat-''' ]

[[rules]]
id = "gitlab_personal_access_token_with_custom_prefix"
regex = '<Regex that match a personal access token starting with your CUSTOM prefix>'

```

请记住，您需要考虑[默认规则集](https://gitlab.com/gitlab-org/security-products/secret-detection/secret-detection-rules/-/blob/main/rules/mit/gitlab/gitlab.toml)中配置的所有规则。

有关要使用的透传语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="ignore-secrets-inline"></a>

### 内联忽略密钥

在某些情况下，您可能希望内联忽略某个密钥。例如，您可能在示例或测试套件中有一个假密钥。在这些情况下，您应该忽略该密钥，而不是将其报告为漏洞。

要忽略某个密钥，请将 `gitleaks:allow` 作为注释添加到包含该密钥的行。

例如：

```ruby
"A personal token for GitLab will look like glpat-JUST20LETTERSANDNUMB"  # gitleaks:allow
```

<a id="detecting-complex-strings"></a>

### 检测复杂字符串

[默认规则集](_index.md#detected-secrets)提供了用于检测结构化字符串且误报率低的模式。但是，您可能希望检测更复杂的字符串，例如密码。[Gitleaks 不支持前瞻或后顾](https://github.com/google/re2/issues/411)，因此无法编写高置信度的通用规则来检测非结构化字符串。

尽管您无法检测每个复杂字符串，但您可以扩展规则集以满足特定用例。

例如，此规则修改了 Gitleaks 默认规则集中的 [`generic-api-key` 规则](https://github.com/gitleaks/gitleaks/blob/4e43d1109303568509596ef5ef576fbdc0509891/config/gitleaks.toml#L507-L514)：

```regex
(?i)(?:pwd|passwd|password)(?:[0-9a-z\-_\t .]{0,20})(?:[\s|']|[\s|"]){0,3}(?:=|>|=:|:{1,3}=|\|\|:|<=|=>|:|\?=)(?:'|\"|\s|=|\x60){0,5}([0-9a-z\-_.=\S_]{3,50})(?:['|\"|\n|\r|\s|\x60|;]|$)
```

此正则表达式匹配：

1. 一个不区分大小写的标识符，以 `pwd`、`passwd` 或 `password` 开头。您可以使用其他变体（如 `secret` 或 `key`）进行调整。
1. 跟在标识符后面的后缀。后缀是数字、字母和符号的组合，长度在零到 23 个字符之间。
1. 常用的赋值运算符，例如`=`、`:=`、`:`或`=>`。
1. 密钥前缀，通常用作边界以帮助检测密钥。
1. 一串数字、字母和符号，长度在三到 50 个字符之间。这就是密钥本身。如果您预期更长的字符串，可以调整长度。
1. 密钥后缀，通常用作边界。它匹配常见的结尾，如反引号、换行符和换行。

以下是由此正则表达式匹配的示例字符串：

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

要使用此正则表达式，请使用本页记录的其中一种方法扩展您的规则集。

例如，假设您希望[使用本地规则集](#with-a-local-ruleset-1)扩展默认规则集，其中包含此规则。

在存储于同一代码仓库的`.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容。调整 `value` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

在 `extended-gitleaks-config.toml` 文件中，添加一个新的`[[rules]]`部分，其中包含您要使用的正则表达式：

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

> [!note]
> 此示例配置仅为方便起见而提供，可能并非适用于
> 所有用例。如果您将规则集配置为检测复杂字符串，可能会
> 产生大量误报，或者无法捕获某些模式。

<a id="demonstrations"></a>

### 演示

有一些[演示项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection)展示了其中一些配置选项。

下表列出了演示项目及其关联的工作流：

| 操作/工作流         | 适用于/通过   | 使用内联或本地规则集                                                                                                                                                                                                                                                                                                                                                                                       | 使用远程规则集 |
|-------------------------|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| 禁用规则          | 预定义规则 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/disable-rule-project/-/blob/main/.gitlab/secret-detection-ruleset.toml?ref_type=heads) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/disable-rule-project)   | [远程规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/disable-rule-ruleset) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/disable-rule-project) |
| 覆盖规则         | 预定义规则 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/override-rule-project/-/blob/main/.gitlab/secret-detection-ruleset.toml?ref_type=heads) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/override-rule-project) | [远程规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/override-rule-ruleset) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/override-rule-project) |
| 替换默认规则集 | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/file-passthrough/-/blob/main/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/file-passthrough)                                                                     | 不适用      |
| 替换默认规则集 | 原始透传  | [内联规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/raw-passthrough/-/blob/main/.gitlab/secret-detection-ruleset.toml?ref_type=heads) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/raw-passthrough)                                      | 不适用      |
| 替换默认规则集 | Git 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-replace/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/git-passthrough) |
| 替换默认规则集 | URL 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-replace/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/url-passthrough) |
| 扩展默认规则集  | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/file-passthrough)                                                       | 不适用      |
| 扩展默认规则集  | Git 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-extend/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/git-passthrough) |
| 扩展默认规则集  | URL 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-extend/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/url-passthrough) |
| 忽略路径            | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/file-passthrough)                                                                           | 不适用      |
| 忽略路径            | Git 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-paths/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/git-passthrough) |
| 忽略路径            | URL 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-paths/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/url-passthrough) |
| 忽略模式         | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/file-passthrough)                                                                     | 不适用      |
| 忽略模式         | Git 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-patterns/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/git-passthrough) |
| 忽略模式         | URL 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-patterns/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/url-passthrough) |
| 忽略值           | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/file-passthrough)                                                                         | 不适用      |
| 忽略值           | Git 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-values/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/git-passthrough) |
| 忽略值           | URL 透传  | 不适用                                                                                                                                                                                                                                                                                                                                                                                                     | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-values/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/url-passthrough) |

<a id="offline-configuration"></a>

## 离线配置

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

离线环境通过互联网对外部资源的访问有限、受限或间歇性。对于此类环境中的实例，流水线密钥检测需要进行一些配置更改。本节中的说明必须与[离线环境](../../offline_deployments/_index.md)中详述的说明一起完成。

<a id="configure-gitlab-runner"></a>

### 配置极狐GitLab Runner

默认情况下，即使本地有可用副本，runner 也会尝试从 GitLab 容器镜像仓库拉取 Docker 镜像。您应使用此默认设置，以确保 Docker 镜像保持最新。但是，如果没有可用的网络连接，您必须更改默认的极狐GitLab Runner `pull_policy` 变量。

将极狐GitLab Runner CI/CD 变量 `pull_policy` 配置为
[`if-not-present`](https://gitlab.cn/docs/runner/executors/docker/#using-the-if-not-present-pull-policy)。

<a id="use-local-pipeline-secret-detection-analyzer-image"></a>

### 使用本地流水线密钥检测分析器镜像

如果您想从本地 Docker 镜像仓库而不是 GitLab 容器镜像仓库获取镜像，请使用本地流水线密钥检测分析器镜像。

先决条件：

- 将 Docker 镜像导入本地离线 Docker 镜像仓库取决于您的
  网络安全策略。请咨询您的 IT 人员，以找到可接受且经批准的流程
  来导入或临时访问外部资源。

1. 将默认流水线密钥检测分析器镜像从 `registry.gitlab.com` 导入到您的
   [本地 Docker 容器镜像仓库](../../../packages/container_registry/_index.md)：

   ```plaintext
   registry.gitlab.com/security-products/secrets:7
   ```

   流水线密钥检测分析器的镜像会[定期更新](../../detect/vulnerability_scanner_maintenance.md)，
   因此您应定期更新本地副本。

1. 将 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 设置为本地 Docker 容器镜像仓库。

   ```yaml
   include:
     - template: Jobs/Secret-Detection.gitlab-ci.yml

   variables:
     SECURE_ANALYZERS_PREFIX: "localhost:5000/analyzers"
   ```

流水线密钥检测作业现在应使用分析器 Docker 镜像的本地副本，而无需访问互联网。

<a id="using-a-custom-ssl-ca-certificate-authority"></a>

## 使用自定义 SSL CA 证书颁发机构

要信任自定义证书颁发机构，请将 `ADDITIONAL_CA_CERT_BUNDLE` 变量设置为您信任的 CA 证书捆绑包。可以在`.gitlab-ci.yml` 文件中、文件变量中或作为 CI/CD 变量执行此操作。

- 在`.gitlab-ci.yml` 文件中，`ADDITIONAL_CA_CERT_BUNDLE` 值必须包含
  [X.509 PEM 公钥证书的文本表示](https://www.rfc-editor.org/rfc/rfc7468#section-5.1)。

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

- 如果使用文件变量，请将 `ADDITIONAL_CA_CERT_BUNDLE`的值设置为证书的
  路径。

- 如果使用变量，请将 `ADDITIONAL_CA_CERT_BUNDLE`的值设置为证书的文本
  表示。
