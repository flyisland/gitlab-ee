---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SAST 分析器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

静态应用程序安全测试（SAST）使用分析器来检测源代码中的漏洞。每个分析器都是对[扫描器](../terminology/_index.md#scanner)（一种第三方代码分析工具）的封装。

这些分析器以 Docker 镜像的形式发布，SAST 使用这些镜像为每次分析启动专用容器。为确保分析器的性能稳定，建议至少使用 4 GB 内存。

SAST 默认镜像由极狐GitLab 维护，但您也可以集成自己的自定义镜像。

对于每个扫描器，分析器会：

- 公开其检测逻辑。
- 处理其执行过程。
- 将其输出转换为[标准格式](../terminology/_index.md#secure-report-format)。

<a id="official-analyzers"></a>

## 官方分析器

SAST 支持以下官方分析器：

- [`gitlab-advanced-sast`](gitlab_advanced_sast.md)，提供跨文件和跨函数的污点分析，并提高检测准确性。仅限旗舰版。
- [`gitlab-advanced-sast-ext`](advanced_sast_swift_objc.md)，为 Swift 和 Objective-C 提供跨文件和跨函数的污点分析。仅限旗舰版。测试版。
- [`kubesec`](https://gitlab.com/gitlab-org/security-products/analyzers/kubesec)，基于 Kubesec。默认关闭；请参见[启用 KubeSec 分析器](_index.md#enabling-kubesec-analyzer)。
- [`pmd-apex`](https://gitlab.com/gitlab-org/security-products/analyzers/pmd-apex)，基于 PMD，并包含针对 Apex 语言的规则。
- [`semgrep`](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)，基于 Semgrep OSS 引擎，[使用极狐GitLab 管理的规则](rules.md#semgrep-based-analyzer)。
- [`sobelow`](https://gitlab.com/gitlab-org/security-products/analyzers/sobelow)，基于 Sobelow。
<!-- vale gitlab_base.OxfordComma = NO -->
- [`spotbugs`](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs)，基于 SpotBugs，并使用 Find Sec Bugs 插件（Ant、Gradle 及 wrapper、Grails、Maven 及 wrapper、SBT）。
<!-- vale gitlab_base.OxfordComma = YES -->

<a id="supported-versions"></a>

### 支持的版本

官方分析器以容器镜像的形式发布，与极狐GitLab 平台相互独立。每个分析器版本仅与有限的一组极狐GitLab 版本兼容。

当某个分析器版本在未来的极狐GitLab 版本中不再受支持时，此变更会提前公布。例如，请参见[极狐GitLab 17.0 的公告](../../../update/deprecations.md#secure-analyzers-major-version-update)。

每个官方分析器支持的主版本号反映在其 [SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml)的作业定义中。要查看之前的极狐GitLab 版本中支持的分析器版本，请选择 SAST 模板文件的历史版本，例如极狐GitLab 16.11.0 对应的 [v16.11.0-ee](https://gitlab.com/gitlab-org/gitlab/-/blob/v16.11.0-ee/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml?ref_type=tags)。

<a id="analyzers-that-have-reached-end-of-support"></a>

## 已停止支持的分析器

以下极狐GitLab 分析器已达到[停止支持](../../../update/terminology.md#end-of-support)状态，不再接收更新。它们已被基于 Semgrep 的分析器取代，[使用极狐GitLab 管理的规则](rules.md#semgrep-based-analyzer)。

升级到极狐GitLab 17.3.1 或更高版本后，一次性数据迁移会[自动解决](_index.md#automatic-vulnerability-resolution)已停止支持的分析器产生的发现项。这包括下面列出的所有分析器，但 SpotBugs 除外，因为 SpotBugs 仍会扫描 Groovy 代码。该迁移只会解决您尚未确认或忽略的漏洞，并且不会影响已[自动转换为基于 Semgrep 的扫描](#transition-to-semgrep-based-scanning)的漏洞。有关详情，请参见[议题 444926](https://gitlab.com/gitlab-org/gitlab/-/issues/444926)。

| 分析器                                                                                                   | 扫描的语言                                                                      | 停止支持的极狐GitLab 版本                                                                 |
|------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Bandit](https://gitlab.com/gitlab-org/security-products/analyzers/bandit)                                 | Python                                                                                 | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [Brakeman](https://gitlab.com/gitlab-org/security-products/analyzers/brakeman)                             | Ruby，包括 Ruby on Rails                                                          | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)         |
| [ESLint](https://gitlab.com/gitlab-org/security-products/analyzers/eslint) 及 React 和 Security 插件 | JavaScript 和 TypeScript，包括 React                                             | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [Flawfinder](https://gitlab.com/gitlab-org/security-products/analyzers/flawfinder)                         | C、C++                                                                                 | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)         |
| [gosec](https://gitlab.com/gitlab-org/security-products/analyzers/gosec)                                   | Go                                                                                     | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [MobSF](https://gitlab.com/gitlab-org/security-products/analyzers/mobsf)                                   | Java 和 Kotlin，仅适用于 Android 应用程序；Objective-C，仅适用于 iOS 应用程序 | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)         |
| [NodeJsScan](https://gitlab.com/gitlab-org/security-products/analyzers/nodejs-scan)                        | JavaScript（仅 Node.js）                                                              | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)         |
| [phpcs-security-audit](https://gitlab.com/gitlab-org/security-products/analyzers/phpcs-security-audit)     | PHP                                                                                    | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)         |
| [Security Code Scan](https://gitlab.com/gitlab-org/security-products/analyzers/security-code-scan)         | .NET（包括 C#、Visual Basic）                                                      | [16.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-160)         |
| [SpotBugs](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs)                             | 仅 Java[^remains-supported-analyzer]                                                                  | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [SpotBugs](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs)                             | 仅 Kotlin 和 Scala[^remains-supported-analyzer]                                                      | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)         |

[^remains-supported-analyzer]: SpotBugs 对于 Groovy 仍是[受支持的分析器](_index.md#supported-languages-and-frameworks)。它仅在检测到 Groovy 代码时激活。

<a id="sast-analyzer-features"></a>

## SAST 分析器功能

分析器要被认定为正式发布，至少应支持以下功能：

- [可自定义配置](_index.md#available-cicd-variables)
- [可自定义规则集](customize_rulesets.md)
- [扫描项目](_index.md#supported-languages-and-frameworks)
- 多项目支持
- [离线支持](_index.md#running-sast-in-an-offline-environment)
- [以 JSON 报告格式输出结果](_index.md#download-a-sast-report)
- [SELinux 支持](_index.md#running-sast-in-selinux)

<a id="post-analyzers"></a>

## 后处理分析器

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

后处理分析器会丰富分析器的报告输出。后处理分析器不会直接修改报告内容，而是通过附加属性来增强结果，包括：

- CWE。
- 位置跟踪字段。

<a id="transition-to-semgrep-based-scanning"></a>

## 过渡到基于 Semgrep 的扫描

除了[极狐GitLab Advanced SAST 分析器](gitlab_advanced_sast.md)之外，极狐GitLab 还提供基于 Semgrep 的[分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)，它覆盖[多种语言](_index.md#supported-languages-and-frameworks)。极狐GitLab 维护该分析器并为其编写[检测规则](rules.md)。这些规则取代了之前版本中使用的特定语言分析器。

<a id="vulnerability-translation"></a>

### 漏洞转换

在可能的情况下，漏洞管理系统会自动将漏洞从旧分析器迁移为基于 Semgrep 的新发现项。有关向极狐GitLab Advanced SAST 分析器的转换，请参阅[极狐GitLab Advanced SAST 文档](gitlab_advanced_sast.md)。

发生这种情况时，系统会将来自各分析器的漏洞合并为一条记录。

但是，如果出现以下情况，漏洞可能无法匹配：

- 新的基于 Semgrep 的规则检测到漏洞的位置或方式与旧分析器不同。
- 您之前[禁用了 SAST 分析器](#disable-specific-default-analyzers)。

这会妨碍为每个漏洞记录必要的标识符，从而干扰自动转换。

如果某个漏洞无法匹配：

- 原始漏洞在漏洞报告中会被标记为“不再检测到”。
- 然后会根据基于 Semgrep 的发现项创建一个新漏洞。

<a id="customize-analyzers"></a>

## 自定义分析器

在您的 `.gitlab-ci.yml` 文件中使用 [CI/CD 变量](_index.md#available-cicd-variables)来自定义分析器的行为。

<a id="use-a-custom-docker-mirror"></a>

### 使用自定义 Docker 镜像仓库

您可以使用自定义 Docker 镜像仓库（而不是极狐GitLab 镜像仓库）来托管分析器的镜像。

先决条件：

- 项目的维护者或所有者角色。
- 自定义 Docker 镜像仓库必须为所有官方分析器提供镜像。

> [!note]
> 此变量会影响所有安全分析器，而不仅仅是 SAST 的分析器。

要让极狐GitLab 从自定义 Docker 镜像仓库下载分析器的镜像，请使用 `SECURE_ANALYZERS_PREFIX` CI/CD 变量定义前缀。

例如，以下内容指示 SAST 拉取 `my-docker-registry/gitlab-images/semgrep`，而不是 `registry.gitlab.com/security-products/semgrep`：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SECURE_ANALYZERS_PREFIX: my-docker-registry/gitlab-images
```

<a id="disable-all-default-analyzers"></a>

### 禁用所有默认分析器

您可以禁用所有默认 SAST 分析器，仅保留已启用的[自定义分析器](#custom-analyzers)。

先决条件：

- 项目的维护者或所有者角色。

要禁用所有默认分析器，请在 `.gitlab-ci.yml` 文件中将 CI/CD 变量 `SAST_DISABLED` 设置为 `"true"`。

示例：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SAST_DISABLED: "true"
```

<a id="disable-specific-default-analyzers"></a>

### 禁用特定的默认分析器

分析器会根据检测到的源代码语言自动运行。不过，您可以禁用选定的分析器。

先决条件：

- 项目的维护者或所有者角色。

要禁用选定的分析器，请将 CI/CD 变量 `SAST_EXCLUDED_ANALYZERS` 设置为以逗号分隔的字符串，列出您希望阻止运行的分析器。

例如，要禁用 `spotbugs` 分析器：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SAST_EXCLUDED_ANALYZERS: "spotbugs"
```

<a id="custom-analyzers"></a>

### 自定义分析器

您可以通过在 CI/CD 配置中定义作业来提供自己的分析器。为了与默认分析器保持一致，您应该为自定义 SAST 作业添加后缀 `-sast`。

<a id="example-custom-analyzer"></a>

#### 自定义分析器示例

此示例展示了如何添加一个基于 Docker 镜像 `my-docker-registry/analyzers/csharp`的扫描作业。它会运行脚本 `/analyzer run` 并输出 SAST 报告 `gl-sast-report.json`。

在您的 `.gitlab-ci.yml` 文件中定义以下内容：

```yaml
csharp-sast:
  image:
    name: "my-docker-registry/analyzers/csharp"
  script:
    - /analyzer run
  artifacts:
    reports:
      sast: gl-sast-report.json
```
