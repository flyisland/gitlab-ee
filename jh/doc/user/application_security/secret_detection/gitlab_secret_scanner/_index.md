---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 源代码密钥扫描
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

极狐GitLab 源代码密钥扫描是[流水线密钥检测](../pipeline/_index.md)的替代分析器。它与默认分析器在同一个 `secret_detection` CI/CD 作业中运行，但提供了额外的密钥检测功能，包括检测通用密钥。

<a id="how-gitlab-secret-scanning-for-source-code-differs"></a>

## 极狐GitLab 源代码密钥扫描的差异

该分析器使用由极狐GitLab 开发的专有扫描引擎。它不依赖模式匹配，而是使用启发式方法来检测[标准极狐GitLab 密钥检测规则](../detected_secrets.md)之外的非结构化密钥和密码。它结合多种启发式技术来减少误报。

在测试版期间，该分析器提供：

- 通用密钥检测：识别非结构化密钥和密码，包括超出标准极狐GitLab 密钥检测规则覆盖范围的上下文密钥。
- 误报减少：结合多种启发式技术来评估密钥及其周围上下文，以减少扫描结果中的噪音。
- 编码密钥检测：检测以编码形式而非明文存储的密钥。支持 base64 编码的字符串。

<a id="turn-on-the-analyzer"></a>

## 启用分析器

先决条件：

- 您有一个基于 Linux 的 Runner，使用 [`docker`](https://gitlab.cn/docs/runner/executors/docker/) 或 [`kubernetes`](https://gitlab.cn/docs/runner/install/kubernetes/) 执行器。如果您使用 JihuLab.com 的托管 Runner，则默认已启用此功能。
  - 不支持 Windows Runner。
  - 不支持 amd64 以外的 CPU 架构。
- 您有一个包含 `test` 阶段的 `.gitlab-ci.yml` 文件。

要启用分析器，请使用最新的密钥检测模板，并将 `SECRET_DETECTION_ENABLE_GSS` CI/CD 变量设置为 `true`：

```yaml
include:
  - template: Jobs/Secret-Detection.latest.gitlab-ci.yml

secret_detection:
  variables:
    SECRET_DETECTION_ENABLE_GSS: "true"
```

> [!note]
> 该分析器仅报告高置信度发现结果。中低置信度的发现结果会被有意过滤掉，以尽量减少漏洞报告中的噪音。如果预期的密钥未出现在结果中，则它很可能被标记为中或低置信度。
> 此行为将持续到分析器支持配置扫描的置信度级别，并且漏洞报告 UI 支持按置信度级别过滤发现结果为止。要同时查看被抑制的发现结果，请参阅[查看因置信度阈值而被抑制的发现结果](#view-findings-suppressed-by-confidence-threshold)。

<a id="run-the-analyzer-for-the-first-time"></a>

### 首次运行分析器

首次运行极狐GitLab 源代码密钥扫描时，您应该运行一次历史扫描。该分析器会扫描所有提交，并使用最新的发现结果更新漏洞报告，包括接管来自 [流水线密钥检测](../pipeline/_index.md) 的现有发现结果。

要运行历史扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择 **新建流水线**。
1. 添加一个 CI/CD 变量：
   1. 从下拉列表中，选择 **变量**。
   1. 在 **输入变量键** 框中，输入 `SECRET_DETECTION_HISTORIC_SCAN`。
   1. 在 **输入变量值** 框中，输入 `true`。
1. 选择 **新建流水线**。

如果您改为在 `.gitlab-ci.yml` 文件中将 `SECRET_DETECTION_HISTORIC_SCAN` 设置为 `true`，请在扫描完成后删除该变量。否则，每次流水线都会扫描完整的代码仓库历史。

<a id="default-configuration"></a>

## 默认配置

当您启用分析器时，它将使用以下配置运行：

| 设置 | 默认值 | 如何更改 |
|---------|---------|---------------|
| 通用密钥检测 | 开 | 将 `SECRET_DETECTION_GSS_ENABLE_GENERIC_SECRETS` 设置为 `false`。请参阅 [通用密钥](#generic-secrets)。 |
| 误报减少 | 开 | 不可配置。 |
| 规则 | 默认的极狐GitLab 密钥检测规则集 | 请参阅 [自定义规则](#customize-rules)。 |

<a id="generic-secrets"></a>

## 通用密钥

当分析器启用时，通用密钥检测默认开启。

要关闭通用密钥检测，请将 `SECRET_DETECTION_GSS_ENABLE_GENERIC_SECRETS` CI/CD 变量设置为 `false`：

```yaml
include:
  - template: Jobs/Secret-Detection.latest.gitlab-ci.yml

secret_detection:
  variables:
    SECRET_DETECTION_ENABLE_GSS: "true"
    SECRET_DETECTION_GSS_ENABLE_GENERIC_SECRETS: "false"
```

<a id="customize-rules"></a>

## 自定义规则

您可以使用代码仓库中的 `.gitlab/secret-detection-ruleset.toml` 文件对极狐GitLab 源代码密钥扫描应用扫描自定义。要创建此文件，请参阅[创建规则集配置文件](../pipeline/configure.md#create-a-ruleset-configuration-file)。

您可以：

- 从默认规则集中[禁用规则](../pipeline/configure.md#disable-a-rule)。
- 使用您自己的规则[扩展默认规则集](../pipeline/configure.md#extend-the-default-ruleset)。新规则必须遵循[自定义规则格式](../pipeline/custom_rulesets_schema.md#custom-rule-format)。
- 使用允许列表按正则表达式或文件路径忽略密钥。

例如，要扩展默认规则集并按正则表达式或文件路径忽略密钥，请使用指向扩展配置文件的 `file` 透传。将透传添加到 `.gitlab/secret-detection-ruleset.toml` 文件中：

```toml
# .gitlab/secret-detection-ruleset.toml
[secrets]
  [[secrets.passthrough]]
    type   = "file"
    target = "gss.toml"
    value  = "extended-gss-config.toml"
```

在扩展配置文件中，使用 `[extend]` 在默认规则集的基础上构建，并使用一个或多个 `[[allowlists]]` 表来忽略发现结果。每个允许列表可以使用 `regexes` 匹配密钥值，并使用 `paths` 匹配文件路径：

```toml
# extended-gss-config.toml
[extend]
# Extends the default packaged ruleset. Do not change the path.
path = "/gitleaks.toml"

[[allowlists]]
  description = "Ignore known test values and fixture paths"
  regexes = [
    '''glpat-[0-9a-zA-Z_\-]{20}''',
  ]
  paths = [
    '''spec/fixtures/.*''',
  ]
```

允许列表中的 `regexes` 和 `paths` 使用逻辑 OR 进行组合。如果发现结果的密钥匹配任何 `regexes`，或其文件路径匹配任何 `paths`，则该发现结果将被忽略。

<a id="migrate-from-the-default-analyzer"></a>

## 从默认分析器迁移

极狐GitLab 源代码密钥扫描在 `secret_detection` 作业中取代了默认分析器。当 `SECRET_DETECTION_ENABLE_GSS` CI/CD 变量设置为 `true` 时，仅运行极狐GitLab 源代码密钥扫描。

要从默认分析器迁移：

1. 在功能分支上[启用极狐GitLab 源代码密钥扫描](#turn-on-the-analyzer)。
1. 运行一次流水线，并将发现结果与使用默认分析器的扫描结果进行比较。
1. 检查您的规则集自定义。有关可用选项，请参阅[自定义规则](#customize-rules)。
1. 当您对结果满意时，在默认分支上启用分析器。

<a id="existing-findings-after-migration"></a>

### 迁移后的现有发现结果

当您在默认分支上启用极狐GitLab 源代码密钥扫描时，两个分析器都能检测到的密钥将由该分析器接管。它会将这些发现结果与之前由默认分析器报告的漏洞进行匹配。它们现有的漏洞记录会延续下来，而不会作为新发现结果再次报告。

默认分析器之前报告过但极狐GitLab 源代码密钥扫描未检测到的发现结果将保持不变。

<a id="fips-enabled-images"></a>

## 启用 FIPS 的镜像

虽然极狐GitLab 源代码密钥扫描处于测试版阶段，但尚未为其发布启用 FIPS 的镜像。如果您将 `SECRET_DETECTION_IMAGE_SUFFIX` CI/CD 变量设置为 `-fips`，则 `secret_detection` 作业将因无法拉取镜像而失败。

要使用启用 FIPS 的镜像进行扫描，请使用默认分析器进行 [流水线密钥检测](../pipeline/_index.md#fips-enabled-images)。

<a id="troubleshooting"></a>

## 故障排除

有关流水线密钥检测的常见问题，请参阅[故障排除](../pipeline/_index.md#troubleshooting)文档。

<a id="view-findings-suppressed-by-confidence-threshold"></a>

### 查看因置信度阈值而被抑制的发现结果

分析器会抑制低于可配置置信度阈值的发现结果。该阈值固定为高，因此分析器会抑制中低置信度的发现结果。

要查看被抑制的发现结果，请在 `secret_detection` 作业中将 `SECRET_DETECTION_GSS_DEBUG_REPORT` CI/CD 变量设置为 `true`。此变量会生成一个名为 `gl-secret-detection-report.debug.json` 的第二个作业产物，您可以从作业产物中下载它。
调试报告仅包含因置信度而被抑制的发现结果。它不包含因排除（允许列表）而被抑制的发现结果。
漏洞报告保持不变，仍仅显示高置信度发现结果。
如果未设置该变量或将其设置为 `false`，则不会生成调试报告。扫描器会记录一条警告，该警告不影响作业状态。
