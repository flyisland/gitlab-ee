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

根据您的[订阅级别](_index.md#availability)和配置方法，您可以更改流水线密钥检测的工作方式。

[自定义分析器行为](#customize-analyzer-behavior) 可：

- 更改分析器检测的密钥类型。
- 使用不同的分析器版本。
- 通过特定方法扫描您的项目。

[自定义分析器规则集](#customize-analyzer-rulesets) 可：

- 检测自定义密钥类型。
- 覆盖默认扫描器规则。

<a id="customize-analyzer-behavior"></a>

## 自定义分析器行为

要更改分析器的行为，请在 `.gitlab-ci.yml` 中使用 [`variables`](../../../../ci/yaml/_index.md#variables) 参数定义变量。

> [!warning]
> 在将这些更改合并到默认分支之前，应在合并请求中测试极狐GitLab 安全扫描工具的所有配置。否则可能导致意外结果，包括大量误报。

<a id="add-new-patterns"></a>

### 添加新模式

要在您的代码仓中搜索其他类型的密钥，您可以[自定义分析器规则集](#customize-analyzer-rulesets)。

<a id="propose-new-detection-rules"></a>

### 提议新的检测规则

您可以通过以下两种方式为所有流水线密钥检测用户提议新的检测规则：

- 请求新规则：使用[密钥检测模式更改议题模板](https://jihulab.com/gitlab-cn/gitlab/-/issues/new?description_template=Secret_Detection_Pattern_Change)创建一个议题。极狐GitLab 团队将审核该请求，并与您联系以决定如何以及何时实施新规则。
- 贡献新规则：如果您想自己贡献规则，请遵循密钥检测规则仓库中的[贡献指南](https://jihulab.com/gitlab-cn/security-products/secret-detection/secret-detection-rules/-/blob/main/README.md#adding-new-rules)。

如果您运营云或 SaaS 产品，并有兴趣与极狐GitLab 合作以更好地保护您的用户，请参阅极狐GitLab [针对泄露凭据通知的合作伙伴计划](../automatic_response.md#partner-program-for-leaked-credential-notifications)。

<a id="pin-to-specific-analyzer-version"></a>

### 固定到特定分析器版本

极狐GitLab 管理的 CI/CD 模板会指定一个主要版本，并自动拉取该主要版本内最新的分析器版本。

在某些情况下，您可能需要使用特定版本。例如，您可能希望避免后续版本中的回归。

要覆盖自动更新行为，请在包含 [`Secret-Detection.gitlab-ci.yml` 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)后，在 CI/CD 配置文件中设置 `SECRETS_ANALYZER_VERSION` CI/CD 变量。

您可以将标签设置为：

- 主要版本，如 `4`。您的流水线会使用此主要版本内发布的任何次要或补丁更新。
- 次要版本，如 `4.5`。您的流水线会使用此次要版本内发布的任何补丁更新。
- 补丁版本，如 `4.5.0`。您的流水线不会接收任何更新。

以下示例使用了特定次要版本的分析器：

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

请参阅[使用安全扫描工具与合并请求流水线](../../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。

<a id="override-the-analyzer-jobs"></a>

### 覆盖分析器作业

要覆盖作业定义（例如，更改 `variables` 或 `dependencies` 等属性），请声明一个与要覆盖的 `secret_detection` 作业同名的作业。将此新作业放在模板包含之后，并在其下指定任何额外的键。

在以下 `.gitlab-ci.yml` 文件的摘录示例中：

- 已[包含](../../../../ci/yaml/_index.md#include) `Jobs/Secret-Detection` CI/CD 模板。
- 在 `secret_detection` 作业中，CI/CD 变量 `SECRET_DETECTION_HISTORIC_SCAN` 被设置为 `true`。由于模板在流水线配置之前评估，因此最后提及的变量优先，从而执行历史扫描。

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

| CI/CD 变量                       | 默认值 | 描述 |
|-----------------------------------|---------------|-------------|
| `SECRET_DETECTION_EXCLUDED_PATHS` | ""            | 根据路径从输出中排除漏洞。路径是以逗号分隔的模式列表。模式可以是 glob（有关支持的模式，请参阅 [`doublestar.Match`](https://pkg.go.dev/github.com/bmatcuk/doublestar/v4@v4.0.2#Match)），也可以是文件或文件夹路径（例如 `doc,spec`）。父目录也会匹配模式。之前已添加到漏洞报告中的已检测密钥不会被移除。在极狐GitLab 13.3 引入。 |
| `SECRET_DETECTION_HISTORIC_SCAN`  | false         | 启用 Gitleaks 历史扫描的功能标志。 |
| `SECRET_DETECTION_IMAGE_SUFFIX`   | "" | 添加到镜像名称的后缀。如果设置为 `-fips`，则使用 `FIPS-enabled` 镜像进行扫描。有关更多详细信息，请参阅[使用启用 FIPS 的镜像](_index.md#fips-enabled-images)。在极狐GitLab 14.10 引入。 |
| `SECRET_DETECTION_LOG_OPTIONS`  | ""        | 指定要扫描的提交范围的功能标志。Gitleaks 使用 [`git log`](https://git-scm.com/docs/git-log) 来确定提交范围。定义后，流水线密钥检测会尝试获取分支中的所有提交。如果分析器无法访问每个提交，它将继续使用已检出的仓库。在极狐GitLab 15.1 引入。 |

在以前的极狐GitLab 版本中，以下变量也可用：

| CI/CD 变量                       | 默认值 | 描述 |
|-----------------------------------|---------------|-------------|
| `SECRET_DETECTION_COMMIT_FROM`    | -             | Gitleaks 扫描开始的提交。在极狐GitLab 13.5 移除。被 `SECRET_DETECTION_COMMITS` 替代。 |
| `SECRET_DETECTION_COMMIT_TO`      | -             | Gitleaks 扫描结束的提交。在极狐GitLab 13.5 移除。被 `SECRET_DETECTION_COMMITS` 替代。 |
| `SECRET_DETECTION_COMMITS`        | -             | Gitleaks 应扫描的提交列表。在极狐GitLab 13.5 引入。在极狐GitLab 15.0 移除。 |

<a id="customize-analyzer-rulesets"></a>

## 自定义分析器规则集

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 13.5 引入。
- 在极狐GitLab 14.6 扩展，增加了 `file` 和 `raw` 的额外直通类型。
- 在极狐GitLab 14.8 启用了覆盖规则的支持。
- 在极狐GitLab 17.2 启用了直通链支持，并添加了 `git` 和 `url` 的额外直通类型。

{{< /history >}}

您可以通过创建自定义规则集配置文件（可以位于被扫描的仓库中或远程仓库中）来自定义流水线密钥检测所检测的密钥类型。

自定义使您能够

- 修改默认规则集中规则的行为。
- 用自定义规则集替换默认规则集。
- 扩展默认规则集的行为。
- 忽略密钥和路径。

<a id="create-a-ruleset-configuration-file"></a>

### 创建规则集配置文件

要创建规则集配置文件：

1. 如果项目根目录下尚不存在 `.gitlab` 目录，请创建一个。
1. 在 `.gitlab` 目录中创建一个名为 `secret-detection-ruleset.toml` 的文件。

<a id="modify-rules-from-the-default-ruleset"></a>

### 修改默认规则集中的规则

您可以修改[默认规则集](../detected_secrets.md)中预定义的规则。

修改规则可以帮助您根据现有工作流程或工具调整流水线密钥检测。例如，您可能希望覆盖已检测密钥的严重程度，或完全禁用某个规则的检测。

您还可以使用远程存储的规则集配置文件（即远程 Git 仓库或网站）来修改预定义规则。新规则必须使用[自定义规则格式](custom_rulesets_schema.md#custom-rule-format)。

<a id="disable-a-rule"></a>

#### 禁用规则

{{< history >}}

- 在极狐GitLab 16.0 及更高版本中，启用了使用远程规则集禁用规则的功能。

{{< /history >}}

您可以禁用它不希望处于活动状态的规则。要禁用分析器默认规则集中的规则：

1. 如果尚不存在，请[创建规则集配置文件](#create-a-ruleset-configuration-file)。
1. 在 [`ruleset` 部分](custom_rulesets_schema.md#the-secretsruleset-section)的上下文中，将 `disabled` 标志设置为 `true`。
1. 在一个或多个 `ruleset.identifier` 子部分中，列出要禁用的规则。每个 [`ruleset.identifier` 部分](custom_rulesets_schema.md#the-secretsrulesetidentifier-section)都有：
   - 一个 `type` 字段，用于预定义规则标识符。
   - 一个 `value` 字段，用于规则名称。

在以下 `secret-detection-ruleset.toml` 文件示例中，禁用的规则通过标识符的 `type` 和 `value` 进行匹配：

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

- 在极狐GitLab 16.0 及更高版本中，启用了使用远程规则集覆盖规则的功能。

{{< /history >}}

如果有特定规则需要自定义，您可以覆盖它们。例如，您可能想要提高特定类型密钥的严重程度，因为泄露它会对您的工作流程产生更大的影响。

要覆盖分析器默认规则集中的规则：

1. 如果尚不存在，请[创建规则集配置文件](#create-a-ruleset-configuration-file)。
1. 在一个或多个 `ruleset.identifier` 子部分中，列出要覆盖的规则。每个 [`ruleset.identifier` 部分](custom_rulesets_schema.md#the-secretsrulesetidentifier-section)都有：
   - 一个 `type` 字段，用于预定义规则标识符。
   - 一个 `value` 字段，用于规则名称。
1. 在 [`ruleset` 部分](custom_rulesets_schema.md#the-secretsruleset-section)的 [`ruleset.override` 上下文](custom_rulesets_schema.md#the-secretsrulesetoverride-section)中，提供要覆盖的键。可以覆盖任意键组合。有效键包括：
   - `description`
   - `message`
   - `name`
   - `severity`（有效选项为：`Critical`、`High`、`Medium`、`Low`、`Unknown`、`Info`）

在以下 `secret-detection-ruleset.toml` 文件中，通过标识符的 `type` 和 `value` 匹配规则，然后进行覆盖：

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

远程规则集是存储在当前仓库外部的配置文件。它可以用于跨多个项目修改规则。

要使用远程规则集修改预定义规则，您可以使用 `SECRET_DETECTION_RULESET_GIT_REFERENCE` [CI/CD 变量](../../../../ci/variables/_index.md)：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

variables:
  SECRET_DETECTION_RULESET_GIT_REFERENCE: "gitlab.com/example-group/remote-ruleset-project"
```

流水线密钥检测假定配置定义在由 CI/CD 变量引用的仓库中的 `.gitlab/secret-detection-ruleset.toml` 文件中（即远程规则集存储的位置）。如果该文件不存在，请务必[创建一个](#create-a-ruleset-configuration-file)，并按照之前概述的[覆盖](#override-a-rule)或[禁用](#disable-a-rule)预定义规则的步骤操作。

> [!note]
> 默认情况下，项目中的本地 `.gitlab/secret-detection-ruleset.toml` 文件优先于 `SECRET_DETECTION_RULESET_GIT_REFERENCE`，因为 `SECURE_ENABLE_LOCAL_CONFIGURATION` 设置为 `true`。
> 如果将 `SECURE_ENABLE_LOCAL_CONFIGURATION` 设置为 `false`，则会忽略本地文件，并使用默认配置或 `SECRET_DETECTION_RULESET_GIT_REFERENCE`（如果已设置）。

`SECRET_DETECTION_RULESET_GIT_REFERENCE` 变量使用类似 [Git URL](https://git-scm.com/docs/git-clone#_git_urls) 的格式来指定 URI、可选的认证信息和可选的 Git SHA。该变量使用以下格式：

```plaintext
<AUTH_USER>:<AUTH_PASSWORD>@<PROJECT_PATH>@<GIT_SHA>
```

如果配置文件存储在需要身份验证的私有项目中，您可以使用安全存储在 CI/CD 变量中的[群组访问 Token](../../../group/settings/group_access_tokens.md) 来加载远程规则集：

```yaml
include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml

variables:
  SECRET_DETECTION_RULESET_GIT_REFERENCE: "group_2504721_bot_7c9311ffb83f2850e794d478ccee36f5:$GROUP_ACCESS_TOKEN@gitlab.com/example-group/remote-ruleset-project"
```

群组访问 Token 必须具有 `read_repository` 作用域以及报告者、开发者、维护者或所有者角色。有关详细信息，请参阅[仓库权限](../../../permissions.md#project-repositories)。

有关如何查找与群组访问 Token 关联的用户名，请参阅[群组的 Bot 用户](../../../group/settings/group_access_tokens.md#bot-users-for-groups)。

<a id="replace-the-default-ruleset"></a>

### 替换默认规则集

您可以使用[自定义配置](custom_rulesets_schema.md)来替换默认规则集配置。这些配置可以通过[直通](custom_rulesets_schema.md#passthrough-types)组合到单个配置中。

使用直通，您可以：

- 将最多 [20 个直通](custom_rulesets_schema.md#the-secretspassthrough-section)链接到单个配置中，以替换或扩展预定义规则。
- 在直通中包含[环境变量](custom_rulesets_schema.md#interpolate)。
- 为评估直通设置[超时](custom_rulesets_schema.md#the-secrets-configuration-section)。
- [验证](custom_rulesets_schema.md#the-secrets-configuration-section)每个定义的直通中使用的 TOML 语法。

<a id="with-an-inline-ruleset"></a>

#### 使用内联规则集

您可以使用 [`raw` 直通](custom_rulesets_schema.md#passthrough-types)，以内联方式提供的配置替换默认规则集。

在存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `[[rules]]` 下定义的规则：

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

上面的示例用一条检查所定义正则表达式（`Custom Raw Ruleset T` 后跟 3 个 `e`、`s` 或 `t` 中的任意一个字符）的规则替换了默认规则集。

有关要使用的直通语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-local-ruleset"></a>

#### 使用本地规则集

您可以使用 [`file` 直通](custom_rulesets_schema.md#passthrough-types)，用提交到当前仓库的另一个文件替换默认规则集。

在存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value` 以指向本地规则集配置文件的路径：

```toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "config/gitleaks.toml"
```

这将用 `config/gitleaks.toml` 文件中定义的配置替换默认规则集。

有关要使用的直通语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-remote-ruleset-1"></a>

#### 使用远程规则集

您可以使用 `git` 和 `url` 直通，用在远程 Git 仓库中定义的配置或存储在某处在线文件中的配置来替换默认规则集。

远程规则集可以跨多个项目使用。例如，您可能希望对某个命名空间中的多个项目应用相同的规则集，在这种情况下，您可以使用任一直通类型加载该远程规则集，并让多个项目使用它。它还能实现规则集的集中管理，仅允许授权人员编辑。

要使用 `git` 直通，请在存储在仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并调整 `value` 以指向 Git 仓库的地址：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

在此配置中，分析器从 `user_group/central_repository_with_shared_ruleset` 仓库的 `main` 分支中 `config` 目录内的 `gitleaks.toml` 文件加载规则集。然后，您可以在 `user_group/basic_repository` 之外的其他项目中包含相同的配置。

或者，您可以使用 `url` 直通用远程规则集配置替换默认规则集。

要使用 `url` 直通，请在存储在仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并调整 `value` 以指向远程文件的地址：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "url"
    target = "gitleaks.toml"
    value  = "https://example.com/gitleaks.toml"
```

在此配置中，分析器从提供的地址处存储的 `gitleaks.toml` 文件加载规则集配置。

有关要使用的直通语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-private-remote-ruleset"></a>

#### 使用私有远程规则集

如果规则集配置存储在私有仓库中，您必须使用直通的 [`auth` 设置](custom_rulesets_schema.md#the-secretspassthrough-section)提供用于访问仓库的凭据。

> [!note]
> `auth` 设置仅适用于 `git` 直通。

要使用存储在私有仓库中的远程规则集，请在存储在仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，调整 `value` 以指向 Git 仓库的地址，并根据需要更新 `auth` 以使用适当的凭据：

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
> 使用此功能时，请注意不要泄露凭据。查看[此节](custom_rulesets_schema.md#interpolate)以获取有关如何使用环境变量来最大限度降低风险的示例。

有关要使用的直通语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="extend-the-default-ruleset"></a>

### 扩展默认规则集

您还可以根据需要，向[默认规则集](../detected_secrets.md)配置添加额外的规则。当您希望既受益于默认规则集中由极狐GitLab 维护的高置信度预定义规则，又想要为自己项目和命名空间中可能使用的密钥类型添加规则时，这会很有帮助。新规则必须遵循[自定义规则格式](custom_rulesets_schema.md#custom-rule-format)。

<a id="with-a-local-ruleset-1"></a>

#### 使用本地规则集

您可以使用 `file` 直通来扩展默认规则集，以添加额外的规则。

在存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并根据需要调整 `value` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

存储在 `extended-gitleaks-config.toml` 中的扩展配置会包含在分析器在 CI/CD 流水线中使用的配置里。

以下示例添加了带有正则表达式的新 `[[rules]]` 部分用于匹配：

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

使用此规则集配置，分析器会检测任何与这些定义的正则表达式模式匹配的字符串。

有关要使用的直通语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-remote-ruleset-2"></a>

#### 使用远程规则集

与使用远程规则集替换默认规则集类似，您也可以使用存储在远程 Git 仓库中的配置或存储在包含 `.gitlab/secret-detection-ruleset.toml` 配置文件的仓库外部的文件来扩展默认规则集。

如前所述，可以使用 `git` 或 `url` 直通来实现。

要使用 `git` 直通实现，请在存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并相应调整 `value`、`ref` 和 `subdir` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "git"
    ref    = "main"
    subdir = "config"
    value  = "https://gitlab.com/user_group/central_repository_with_shared_ruleset"
```

流水线密钥检测假定远程规则集配置文件名为 `gitleaks.toml`，并存储在引用仓库 `main` 分支上的 `config` 目录中。

要扩展默认规则集，`gitleaks.toml` 文件应使用 `[extend]` 指令，类似于前面的示例：

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

要使用 `url` 直通，请在存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中添加以下内容，并相应调整 `value` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml in https://gitlab.com/user_group/basic_repository
[secrets]
  [[secrets.passthrough]]
    type   = "url"
    target = "gitleaks.toml"
    value  = "https://example.com/gitleaks.toml"
```

有关要使用的直通语法的更多信息，请参阅[模式](custom_rulesets_schema.md#schema)。

<a id="with-a-scan-execution-policy"></a>

#### 使用扫描执行策略

要使用扫描执行策略扩展和强制执行规则集：

- 按照[使用扫描执行策略设置流水线密钥检测配置](https://support.gitlab.com/hc/en-us/articles/18863735262364-How-to-set-up-a-centrally-managed-pipeline-secret-detection-configuration-applied-via-Scan-Execution-Policy)中的步骤操作。

<a id="ignore-patterns-and-paths"></a>

### 忽略模式和路径
可能存在需要忽略特定模式或路径，以免被流水线密钥检测发现的情况。例如，你可能有一个包含用于测试套件的虚假密钥的文件。

在这种情况下，你可以使用 [Gitleaks 原生的 `[allowlist]`](https://github.com/gitleaks/gitleaks#configuration) 指令来忽略特定的模式或路径。

> [!note]
> 无论你使用的是本地还是远程规则集配置文件，此功能均有效。但以下示例使用的是通过 `file` 透传的本地规则集。

要忽略某个模式，请将以下内容添加到存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中，并根据需要调整 `value` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

存储在 `extended-gitleaks-config.toml` 中的扩展配置会被包含在分析器使用的配置中。

以下示例添加了一个 `[allowlist]` 指令，该指令定义了一个正则表达式，用于匹配要忽略（"允许"）的密钥：

```toml
# extended-gitleaks-config.toml
[extend]
# 扩展默认打包规则集，注意：不要更改路径。
path = "/gitleaks.toml"

[allowlist]
  description = "要在检测中忽略的模式白名单"
  regexTarget = "match"
  regexes = [
    '''glpat-[0-9a-zA-Z_\\-]{20}'''
  ]
```

这将忽略任何匹配 `glpat-` 且后缀为 20 个字符（包括数字和字母）的字符串。

同样，你可以排除特定路径不被扫描。以下示例在 `[allowlist]` 指令下定义了一个要忽略的路径数组。路径可以是正则表达式，也可以是特定的文件路径：

```toml
# extended-gitleaks-config.toml
[extend]
# 扩展默认打包规则集，注意：不要更改路径。
path = "/gitleaks.toml"

[allowlist]
  description = "要在检测中忽略的模式白名单"
  paths = [
    '''/gitleaks.toml''',
    '''(.*?)(jpg|gif|doc|pdf|bin|svg|socket)'''
  ]
```

这将忽略在 `/gitleaks.toml` 文件或任何以指定扩展名结尾的文件中检测到的任何密钥。

从 [Gitleaks v8.20.0](https://github.com/gitleaks/gitleaks/releases/tag/v8.20.0) 开始，你还可以将 `regexTarget` 与 `[allowlist]` 一起使用。这意味着你可以通过覆盖现有规则来配置[个人访问令牌前缀](../../../../administration/settings/account_and_limit_settings.md#personal-access-token-prefix)或[自定义实例前缀](../../../../administration/settings/account_and_limit_settings.md#instance-token-prefix)。例如，对于 `personal access tokens`，你可以配置：

```toml
# extended-gitleaks-config.toml
[extend]
# 扩展默认打包规则集，注意：不要更改路径。
path = "/gitleaks.toml"

[[rules]]
# 你想要覆盖的规则 ID：
id = "gitlab_personal_access_token"
# 默认规则中的所有其他属性都会被继承
    [[rules.allowlists]]
    regexTarget = "line"
    regexes = [ '''CUSTOMglpat-''' ]

[[rules]]
id = "gitlab_personal_access_token_with_custom_prefix"
regex = '<匹配以你的 CUSTOM 前缀开头的个人访问令牌的正则表达式>'

```

请记住，你需要考虑到[默认规则集]中配置的所有规则。

有关要使用的透传语法的更多信息，请参见[模式](custom_rulesets_schema.md#schema)。

### 内联忽略密钥

在某些情况下，你可能想要内联忽略一个密钥。例如，你可能在示例或测试套件中有一个虚假密钥。在这些情况下，你应该忽略该密钥，而不是将其报告为漏洞。

要忽略某个密钥，请在包含该密钥的行上添加 `gitleaks:allow` 作为注释。

例如：

```ruby
"A personal token for GitLab will look like glpat-JUST20LETTERSANDNUMB"  # gitleaks:allow
```

### 检测复杂字符串

[默认规则集](_index.md#detected-secrets)提供了用于检测结构化字符串的模式，具有较低的误报率。但是，你可能想要检测更复杂的字符串，例如密码。[Gitleaks 不支持正向预查或反向预查](https://github.com/google/re2/issues/411)，因此无法编写高置信度的通用规则来检测非结构化字符串。

虽然无法检测到每一个复杂字符串，但你可以扩展规则集以满足特定用例。

例如，此规则修改了 Gitleaks 默认规则集中的 [`generic-api-key` 规则](https://github.com/gitleaks/gitleaks/blob/4e43d1109303568509596ef5ef576fbdc0509891/config/gitleaks.toml#L507-L514)：

```regex
(?i)(?:pwd|passwd|password)(?:[0-9a-z\-_\t .]{0,20})(?:[\s|']|[\s|"]){0,3}(?:=|>|=:|:{1,3}=|\|\|:|<=|=>|:|\?=)(?:'|\"|\s|=|\x60){0,5}([0-9a-z\-_.=\S_]{3,50})(?:['|\"|\n|\r|\s|\x60|;]|$)
```

此正则表达式匹配：

1. 一个不区分大小写、以 `pwd`、`passwd` 或 `password` 开头的标识符。你可以根据其他变体（如 `secret` 或 `key`）对此进行调整。
1. 跟随标识符的后缀。后缀是数字、字母和符号的组合，长度在 0 到 23 个字符之间。
1. 常用的赋值运算符，如 `=`、`:=`、`:` 或 `=>`。
1. 一个密钥前缀，通常用作边界以帮助检测密钥。
1. 一个由数字、字母和符号组成的字符串，长度在 3 到 50 个字符之间。这就是密钥本身。如果你期望更长的字符串，可以调整长度。
1. 一个密钥后缀，通常用作边界。这匹配常见的结尾，如反引号、换行符和新行。

以下是与此正则表达式匹配的示例字符串：

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

要使用此正则表达式，请使用本页中记录的其中一种方法扩展你的规则集。

例如，假设你希望[使用本地规则集](#with-a-local-ruleset-1)扩展默认规则集，并包含此规则。

将以下内容添加到存储在同一仓库中的 `.gitlab/secret-detection-ruleset.toml` 配置文件中。调整 `value` 以指向扩展配置文件的路径：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gitleaks.toml"
    value  = "extended-gitleaks-config.toml"
```

在 `extended-gitleaks-config.toml` 文件中，添加一个新的 `[[rules]]` 部分，其中包含你想要使用的正则表达式：

```toml
# extended-gitleaks-config.toml
[extend]
# 扩展默认打包规则集，注意：不要更改路径。
path = "/gitleaks.toml"

[[rules]]
  description = "通用密码规则"
  id = "generic-password"
  regex = '''(?i)(?:pwd|passwd|password)(?:[0-9a-z\-_\t .]{0,20})(?:[\s|']|[\s|"]){0,3}(?:=|>|=:|:{1,3}=|\|\|:|<=|=>|:|\?=)(?:'|\"|\s|=|\x60){0,5}([0-9a-z\-_.=\S_]{3,50})(?:['|\"|\n|\r|\s|\x60|;]|$)'''
  entropy = 3.5
  keywords = ["pwd", "passwd", "password"]
```

> [!note]
> 提供此示例配置仅为方便起见，可能无法适用于所有用例。如果你配置规则集来检测复杂字符串，可能会产生大量误报，或者无法捕获某些模式。

### 演示

有一些[演示项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection)说明了其中一些配置选项。

下表列出了演示项目及其关联的工作流：

| 操作/工作流 | 适用于/通过 | 使用内联或本地规则集 | 使用远程规则集 |
|-------------------------|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| 禁用规则 | 预定义规则 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/disable-rule-project/-/blob/main/.gitlab/secret-detection-ruleset.toml?ref_type=heads) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/disable-rule-project) | [远程规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/disable-rule-ruleset) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/disable-rule-project) |
| 覆盖规则 | 预定义规则 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/override-rule-project/-/blob/main/.gitlab/secret-detection-ruleset.toml?ref_type=heads) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/local-ruleset/override-rule-project) | [远程规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/override-rule-ruleset) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/modify-default-ruleset/remote-ruleset/override-rule-project) |
| 替换默认规则集 | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/file-passthrough/-/blob/main/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/file-passthrough) | 不适用 |
| 替换默认规则集 | 原始透传 | [内联规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/raw-passthrough/-/blob/main/.gitlab/secret-detection-ruleset.toml?ref_type=heads) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/raw-passthrough) | 不适用 |
| 替换默认规则集 | Git 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-replace/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/git-passthrough) |
| 替换默认规则集 | URL 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-replace/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/replace-default-ruleset/url-passthrough) |
| 扩展默认规则集 | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/file-passthrough) | 不适用 |
| 扩展默认规则集 | Git 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-extend/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/git-passthrough) |
| 扩展默认规则集 | URL 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-extend/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/extend-default-ruleset/url-passthrough) |
| 忽略路径 | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/file-passthrough) | 不适用 |
| 忽略路径 | Git 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-paths/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/git-passthrough) |
| 忽略路径 | URL 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-paths/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-paths/url-passthrough) |
| 忽略模式 | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/file-passthrough) | 不适用 |
| 忽略模式 | Git 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-patterns/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/git-passthrough) |
| 忽略模式 | URL 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-patterns/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-patterns/url-passthrough) |
| 忽略值 | 文件透传 | [本地规则集](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/file-passthrough/-/blob/main/config/extended-gitleaks-config.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/file-passthrough) | 不适用 |
| 忽略值 | Git 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-values/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/git-passthrough) |
| 忽略值 | URL 透传 | 不适用 | [远程规则集](https://gitlab.com/gitlab-org/security-products/tests/secrets-passthrough-git-and-url-test/-/blob/config-demos-ignore-values/config/gitleaks.toml) / [项目](https://gitlab.com/gitlab-org/security-products/demos/analyzer-configurations/secret-detection/ignore-values/url-passthrough) |

## 离线配置

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

离线环境对外部资源的互联网访问是有限、受限或间歇性的。对于此类环境中的实例，流水线密钥检测需要进行一些配置更改。本节中的说明必须与[离线环境](../../offline_deployments/_index.md)中详述的说明一起完成。

### 配置极狐GitLab Runner

默认情况下，Runner 会尝试从极狐GitLab 容器镜像仓库拉取 Docker 镜像，即使本地有副本可用。你应该使用此默认设置，以确保 Docker 镜像保持最新。但是，如果没有网络连接，你必须更改默认的极狐GitLab Runner `pull_policy` 变量。

将极狐GitLab Runner CI/CD 变量 `pull_policy` 配置为 [`if-not-present`](https://docs.gitlab.com/runner/executors/docker/#using-the-if-not-present-pull-policy)。

### 使用本地流水线密钥检测分析器镜像

如果你希望从本地 Docker 仓库而非极狐GitLab 容器镜像仓库获取镜像，请使用本地流水线密钥检测分析器镜像。

先决条件：

- 将 Docker 镜像导入本地离线 Docker 仓库取决于你的网络安全策略。请咨询你的 IT 人员，以找到可接受并批准的导入或临时访问外部资源的过程。

1. 将默认的流水线密钥检测分析器镜像从 `registry.gitlab.com` 导入到你的[本地 Docker 容器镜像仓库](../../../packages/container_registry/_index.md)：

   ```plaintext
   registry.gitlab.com/security-products/secrets:7
   ```

   流水线密钥检测分析器的镜像会[定期更新](../../detect/vulnerability_scanner_maintenance.md)，因此你应该定期更新本地副本。

1. 将 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 设置为本地 Docker 容器镜像仓库。

   ```yaml
   include:
     - template: Jobs/Secret-Detection.gitlab-ci.yml

   variables:
     SECURE_ANALYZERS_PREFIX: "localhost:5000/analyzers"
   ```

现在，流水线密钥检测作业应该使用分析器 Docker 镜像的本地副本，无需互联网访问。

## 使用自定义 SSL CA 证书颁发机构

要信任自定义证书颁发机构，请将 `ADDITIONAL_CA_CERT_BUNDLE` 变量设置为你信任的 CA 证书包。可以在 `.gitlab-ci.yml` 文件中、在文件变量中或作为 CI/CD 变量进行此操作。

- 在 `.gitlab-ci.yml` 文件中，`ADDITIONAL_CA_CERT_BUNDLE` 值必须包含 [X.509 PEM 公钥证书的文本表示形式](https://www.rfc-editor.org/rfc/rfc7468#section-5.1)。

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

- 如果使用文件变量，请将 `ADDITIONAL_CA_CERT_BUNDLE` 的值设置为证书的路径。

- 如果使用变量，请将 `ADDITIONAL_CA_CERT_BUNDLE` 的值设置为证书的文本表示形式。