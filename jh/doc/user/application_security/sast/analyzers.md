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

{{< history >}}

- 在 13.3 中，从 GitLab 旗舰版 移至 GitLab 基础版。

{{< /history >}}

静态应用程序安全测试 (SAST) 使用分析器检测源代码中的漏洞。每个分析器都是封装了一个[扫描器](../terminology/_index.md#scanner) 的包装器，该扫描器是一个第三方代码分析工具。

这些分析器以 Docker 镜像形式发布，SAST 使用这些镜像为每个分析启动专用容器。我们建议至少 4 GB 内存以保证分析器的一致性能。

SAST 默认镜像由极狐GitLab 维护，但你也可以集成自己的自定义镜像。

对于每个扫描器，分析器：

- 暴露其检测逻辑。
- 处理其执行。
- 将其输出转换为[标准格式](../terminology/_index.md#secure-report-format)。

<a id="official-analyzers"></a>

## 官方分析器

SAST 支持以下官方分析器：

- [`gitlab-advanced-sast`](gitlab_advanced_sast.md)，提供跨文件和跨函数的污点分析及改进的检测准确性。仅限旗舰版可用。
- [`kubesec`](https://jihulab.com/gitlab-cn/security-products/analyzers/kubesec)，基于 Kubesec。默认关闭；请参阅[启用 KubeSec 分析器](_index.md#enabling-kubesec-analyzer)。
- [`pmd-apex`](https://jihulab.com/gitlab-cn/security-products/analyzers/pmd-apex)，基于 PMD，带有 Apex 语言的规则。
- [`semgrep`](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep)，基于 Semgrep OSS 引擎，[带有极狐GitLab 管理的规则](rules.md#semgrep-based-analyzer)。
- [`sobelow`](https://jihulab.com/gitlab-cn/security-products/analyzers/sobelow)，基于 Sobelow。
- [`spotbugs`](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs)，基于 SpotBugs，带有 Find Sec Bugs 插件（Ant、Gradle 及其包装器、Grails、Maven 及其包装器、SBT）。

<a id="supported-versions"></a>

### 支持的版本

官方分析器以容器镜像的形式发布，与极狐GitLab 平台分开。每个分析器版本与一组有限的极狐GitLab 版本兼容。

当某个分析器版本在未来极狐GitLab 版本中将不再受支持时，此更改会提前宣布。例如，请参阅[极狐GitLab 17.0 的公告](../../../update/deprecations.md#secure-analyzers-major-version-update)。

每个官方分析器受支持的 major 版本反映在其 [SAST CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml) 的 job 定义中。要查看在以前极狐GitLab 版本中支持的分析器版本，请选择 SAST 模板文件的历史版本，例如 [v16.11.0-ee](https://jihulab.com/gitlab-cn/gitlab/-/blob/v16.11.0-ee/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml?ref_type=tags) 用于极狐GitLab 16.11.0。

<a id="analyzers-that-have-reached-end-of-support"></a>

## 已达到支持终止期的分析器

以下极狐GitLab 分析器已达到[支持终止期](../../../update/terminology.md#end-of-support)状态，不再接收更新。它们已被替换为基于 Semgrep 的分析器，[带有极狐GitLab 管理的规则](rules.md#semgrep-based-analyzer)。

升级到极狐GitLab 17.3.1 或更高版本后，一次性数据迁移会自动[解决](_index.md#automatic-vulnerability-resolution) 来自达到支持终止期的分析器的发现项。这包括下面列出的所有分析器，除了 SpotBugs，因为 SpotBugs 仍然扫描 Groovy 代码。该迁移仅解决你尚未确认或忽略的漏洞，并且不影响已[自动转换为基于 Semgrep 扫描](#transition-to-semgrep-based-scanning) 的漏洞。有关详细信息，请参见[议题 444926](https://jihulab.com/gitlab-cn/gitlab/-/issues/444926)。

| 分析器 | 扫描的语言 | 支持终止的极狐GitLab 版本 |
|--------|------------|-----------------------------|
| [Bandit](https://jihulab.com/gitlab-cn/security-products/analyzers/bandit) | Python | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [Brakeman](https://jihulab.com/gitlab-cn/security-products/analyzers/brakeman) | Ruby，包括 Ruby on Rails | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170) |
| [ESLint](https://jihulab.com/gitlab-cn/security-products/analyzers/eslint) with React and Security plugins | JavaScript 和 TypeScript，包括 React | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [Flawfinder](https://jihulab.com/gitlab-cn/security-products/analyzers/flawfinder) | C，C++ | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170) |
| [gosec](https://jihulab.com/gitlab-cn/security-products/analyzers/gosec) | Go | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [MobSF](https://jihulab.com/gitlab-cn/security-products/analyzers/mobsf) | Java 和 Kotlin，仅适用于 Android 应用程序；Objective-C，仅适用于 iOS 应用程序 | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170) |
| [NodeJsScan](https://jihulab.com/gitlab-cn/security-products/analyzers/nodejs-scan) | JavaScript（仅 Node.js） | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170) |
| [phpcs-security-audit](https://jihulab.com/gitlab-cn/security-products/analyzers/phpcs-security-audit) | PHP | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170) |
| [Security Code Scan](https://jihulab.com/gitlab-cn/security-products/analyzers/security-code-scan) | .NET（包括 C#、Visual Basic） | [16.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-160) |
| [SpotBugs](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs) | 仅 Java<sup>1</sup> | [15.4](../../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) |
| [SpotBugs](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs) | 仅 Kotlin 和 Scala<sup>1</sup> | [17.0](../../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170) |

脚注：

1. SpotBugs 仍然是一个用于 Groovy 的[受支持的分析器](_index.md#supported-languages-and-frameworks)。它仅在检测到 Groovy 代码时激活。

<a id="sast-analyzer-features"></a>

## SAST 分析器功能

一个分析器要被视为普遍可用（GA），它至少应支持以下功能：

- [可自定义的配置](_index.md#available-cicd-variables)
- [可自定义的规则集](customize_rulesets.md)
- [扫描项目](_index.md#supported-languages-and-frameworks)
- 多项目支持
- [离线支持](_index.md#running-sast-in-an-offline-environment)
- [以 JSON 报告格式输出结果](_index.md#download-a-sast-report)
- [SELinux 支持](_index.md#running-sast-in-selinux)

<a id="post-analyzers"></a>

## 后置分析器

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

后置分析器丰富分析器输出的报告。后置分析器不直接修改报告内容，而是通过附加属性增强结果，包括：

- CWE。
- 位置跟踪字段。

<a id="transition-to-semgrep-based-scanning"></a>

## 过渡到基于 Semgrep 的扫描

除了 [极狐GitLab 高级 SAST 分析器](gitlab_advanced_sast.md) 之外，极狐GitLab 还提供了一个 [基于 Semgrep 的分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep)，该分析器覆盖[多种语言](_index.md#supported-languages-and-frameworks)。极狐GitLab 维护该分析器并为其编写[检测规则](rules.md)。这些规则取代了之前版本中使用的特定语言分析器。

<a id="vulnerability-translation"></a>

### 漏洞转换

漏洞管理系统在可能的情况下自动将漏洞从旧分析器转移到新的基于 Semgrep 的发现项。要转换到极狐GitLab 高级 SAST 分析器，请参阅[极狐GitLab 高级 SAST 文档](gitlab_advanced_sast.md)。

发生这种情况时，系统会将来自每个分析器的漏洞合并到一条记录中。

但是，如果出现以下情况，漏洞可能无法匹配：

- 新的基于 Semgrep 的规则以与旧分析器不同的位置或不同的方式检测到该漏洞。
- 你之前[禁用了 SAST 分析器](#disable-specific-default-analyzers)。

这可能会干扰自动转换，因为会阻止记录每个漏洞的必要标识符。

如果漏洞不匹配：

- 原始漏洞在漏洞报告中被标记为“不再检测到”。
- 然后基于基于 Semgrep 的发现项创建一个新漏洞。

<a id="customize-analyzers"></a>

## 自定义分析器

使用你的 `.gitlab-ci.yml` 文件中的 [CI/CD 变量](_index.md#available-cicd-variables) 自定义分析器的行为。

<a id="use-a-custom-docker-mirror"></a>

### 使用自定义 Docker 镜像仓库

你可以使用自定义 Docker 注册表，而不是极狐GitLab 注册表，来托管分析器的镜像。

先决条件：

- 项目具有维护者或所有者角色。
- 自定义 Docker 注册表必须提供所有官方分析器的镜像。

> [!注意]
> 此变量会影响所有安全分析器，而不仅仅是 SAST 的分析器。

要让极狐GitLab 从自定义 Docker 注册表下载分析器的镜像，请使用 `SECURE_ANALYZERS_PREFIX` CI/CD 变量定义前缀。

例如，以下指令指示 SAST 拉取 `my-docker-registry/gitlab-images/semgrep` 而不是 `registry.gitlab.com/security-products/semgrep`：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SECURE_ANALYZERS_PREFIX: my-docker-registry/gitlab-images
```

<a id="disable-all-default-analyzers"></a>

### 禁用所有默认分析器

你可以禁用所有默认 SAST 分析器，仅保留[自定义分析器](#custom-analyzers) 启用。

先决条件：

- 项目具有维护者或所有者角色。

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

分析器会根据检测到的源代码语言自动运行。但是，你可以禁用选定的分析器。

先决条件：

- 项目具有维护者或所有者角色。

要禁用选定的分析器，请将 CI/CD 变量 `SAST_EXCLUDED_ANALYZERS` 设置为逗号分隔的字符串，列出你想要阻止运行的分析器。

例如，要禁用 `spotbugs` 分析器：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SAST_EXCLUDED_ANALYZERS: "spotbugs"
```

<a id="custom-analyzers"></a>

### 自定义分析器

你可以通过在 CI/CD 配置中定义 job 来提供自己的分析器。为与默认分析器保持一致，你应该为自定义 SAST job 添加后缀 `-sast`。

<a id="example-custom-analyzer"></a>

#### 自定义分析器示例

此示例展示如何添加一个基于 Docker 镜像 `my-docker-registry/analyzers/csharp` 的扫描 job。它运行脚本 `/analyzer run` 并输出 SAST 报告 `gl-sast-report.json`。

在你的 `.gitlab-ci.yml` 文件中定义以下内容：

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

