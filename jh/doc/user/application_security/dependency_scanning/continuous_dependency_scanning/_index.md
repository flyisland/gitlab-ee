---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 持续依赖扫描
description: How GitLab detects new vulnerabilities for application dependencies outside of CI/CD pipelines.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 依赖扫描的持续漏洞扫描在默认启用[功能标志](../../../../administration/feature_flags/_index.md) `dependency_scanning_on_advisory_ingestion` 和 `package_metadata_advisory_scans` 的情况下引入。
- 在极狐GitLab 16.10 中 GA。功能标志 `dependency_scanning_on_advisory_ingestion` 和 `package_metadata_advisory_scans` 已移除。

{{< /history >}}

依赖扫描的持续漏洞扫描（CVS）通过将项目依赖的组件名称和版本与最新的[安全公告](#security-advisories)中的信息进行比较，来查找安全漏洞，而无需运行新的流水线。
必须在默认分支上至少运行一次流水线，以通过 CycloneDX SBOM 注册项目的组件。之后，CVS 会在发布公告时运行，无需进一步执行流水线，直到依赖项发生变化。

当持续漏洞扫描触发对所有包含[支持的软件包类型](#supported-package-types)组件的项目进行扫描时，[可能会出现新漏洞](#checking-new-vulnerabilities)。

由依赖扫描的持续漏洞扫描创建的漏洞使用 `GitLab SBoM Vulnerability Scanner` 作为扫描器名称，使用 `Dependency Scanning` 作为漏洞类型。

与基于 CI/CD 的安全扫描不同，持续漏洞扫描通过后台作业（Sidekiq）执行，而不是 CI/CD 流水线，并且不会生成安全报告产物。

<a id="prerequisites"></a>

## 先决条件

- [一个 CycloneDX SBOM 报告](#how-to-generate-a-cyclonedx-sbom-report)。
- [安全公告](#security-advisories) 已同步到极狐GitLab 实例。

<a id="supported-package-types"></a>

## 支持的软件包类型

持续漏洞扫描支持以下用于依赖扫描的 [PURL 类型](https://github.com/package-url/purl-spec/blob/346589846130317464b677bc4eab30bf5040183a/PURL-TYPES.rst) 的组件：

- `cargo`
- `conan`
- `go`
- `maven`
- `npm`
- `nuget`
- `packagist`
- `pub`
- `pypi`
- `rubygem`
- `swift`

不支持 Go 伪版本。引用 Go 伪版本的项目依赖永远不会被视为受影响，因为这可能导致漏报。

<a id="how-to-generate-a-cyclonedx-sbom-report"></a>

## 如何生成 CycloneDX SBOM 报告

使用 [CycloneDX SBOM 报告](../../../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 向极狐GitLab 注册项目组件。

CycloneDX 报告必须符合：

- [CycloneDX 规范](https://github.com/CycloneDX/specification) 版本 `1.4`、`1.5` 或 `1.6`。
- [极狐GitLab 依赖扫描的 CycloneDX 属性分类](../../../../development/sec/cyclonedx_property_taxonomy.md#gitlabdependency_scanning-namespace-taxonomy)。

极狐GitLab 提供能够生成与极狐GitLab 兼容报告的安全分析器：

- [依赖扫描分析器](../dependency_scanning_sbom/_index.md#turn-on-dependency-scanning)
- [Gemnasium 分析器（已弃用）](../legacy_dependency_scanning/_index.md)

<a id="checking-new-vulnerabilities"></a>

## 检查新漏洞

持续漏洞扫描检测到的新漏洞在[漏洞报告](../../vulnerability_report/_index.md)中可见。但是，它们不会列在检测到受影响 SBOM 组件的流水线中。

在添加或更新[安全公告](#security-advisories)后，会创建漏洞，如果代码库保持不变，相应的漏洞可能需要几个小时才能添加到您的项目中。仅考虑最近 14 天内发布的公告进行持续漏洞扫描。

<a id="when-vulnerabilities-are-no-longer-detected"></a>

## 当不再检测到漏洞时

当发布新公告时，持续漏洞扫描会自动创建漏洞，但无法判断漏洞何时不再存在于项目中。为此，极狐GitLab 仍然需要在默认分支的流水线中执行[依赖扫描](../_index.md)，并生成包含最新信息的相应安全报告产物。当处理这些报告时，如果它们不再包含某些漏洞，即使这些漏洞是由持续漏洞扫描创建的，也会被标记为不再存在。

<a id="security-advisories"></a>

## 安全公告

持续漏洞扫描使用软件包元数据数据库，这是由极狐GitLab 管理的一项服务，它聚合许可证和安全公告数据，并定期发布更新，供 JihuLab.com 和私有化部署实例使用。

在 JihuLab.com 上，同步由极狐GitLab 管理，对所有项目可用。

在私有化部署实例上，您可以在极狐GitLab 实例的**管理员**区域[选择要同步的软件包仓库元数据](../../../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)。

<a id="data-sources"></a>

### 数据来源

当前安全公告的数据来源包括：

- [极狐GitLab 公告数据库](https://advisories.gitlab.com/)（托管在 [`gemnasium-db`](https://jihulab.com/gitlab-cn/security-products/gemnasium-db) 仓库中，这是一个旧名称）

<a id="contributing-to-the-vulnerability-database"></a>

### 为漏洞数据库做贡献

要查找漏洞，您可以搜索[`极狐GitLab 公告数据库`](https://advisories.gitlab.com/)。
您也可以[提交新漏洞](https://jihulab.com/gitlab-cn/security-products/gemnasium-db/blob/master/CONTRIBUTING.md)。