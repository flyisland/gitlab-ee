---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 持续容器扫描
description: How 极狐GitLab detects new vulnerabilities for image dependencies outside of CI/CD pipelines.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 持续容器扫描在极狐GitLab 16.8 [引入] [通过功能标志](../../../../administration/feature_flags/_index.md) 命名为 `container_scanning_continuous_vulnerability_scans`。默认禁用。
- 持续容器扫描在极狐GitLab 16.10 [启用于私有化部署]。
- 在极狐GitLab 17.0 [GA]。功能标志 `container_scanning_continuous_vulnerability_scans` 已移除。

{{< /history >}}

持续漏洞扫描（CVS）针对容器扫描，通过将项目的镜像依赖组件的名称和版本与最新的[安全公告](#security-advisories)中的信息进行比较，来查找安全漏洞，无需运行新的流水线。
CVS 依赖于默认分支上存储的 CycloneDX SBOM 报告，以了解项目使用了哪些组件。要生成此 SBOM，必须在默认分支上至少运行一次容器扫描作业。此后，CVS 将自动根据这些组件检测新发布的安全公告，无需再运行流水线。
当镜像内容发生变化时，必须在默认分支上运行新的流水线来刷新 SBOM，以便 CVS 能够评估更新后的组件集。在大多数项目中，这作为常规工作流程的一部分发生，因为依赖项的变更通常涉及代码更改，从而触发流水线。

当持续漏洞扫描触发对所有包含[支持软件包类型](#supported-package-types)组件的项目进行扫描时，[可能会出现新漏洞](#checking-new-vulnerabilities)。

容器扫描的持续漏洞扫描所创建的漏洞使用 `极狐GitLab SBoM 漏洞扫描器` 作为扫描器名称，并使用 `容器扫描` 作为漏洞类型。

与基于 CI/CD 的安全扫描不同，持续漏洞扫描通过后台作业（Sidekiq）执行，而非通过 CI/CD 流水线，并且不会生成安全报告产物。

<a id="prerequisites"></a>

## 先决条件

- [一个 CycloneDX SBOM 报告](#how-to-generate-a-cyclonedx-sbom-report)。
- 同步到极狐GitLab实例的[安全公告](#security-advisories)。

<a id="supported-package-types"></a>

## 支持的软件包类型

持续漏洞扫描支持以下 [PURL 类型](https://github.com/package-url/purl-spec/blob/346589846130317464b677bc4eab30bf5040183a/PURL-TYPES.rst)的组件：

- `apk`
- `deb`
- `rpm`

已知限制：

- 不支持包含前导零的 APK 版本。支持这些版本的工作在[议题 471509](https://jihulab.com/gitlab-cn/gitlab/-/issues/471509) 中进行跟踪。
- 不支持包含 `^` 的 RPM 版本。支持这些版本的工作在[议题 459969](https://jihulab.com/gitlab-cn/gitlab/-/issues/459969) 中进行跟踪。
- Red Hat 发行版中的 RPM 软件包不受支持。支持此用例的工作在[史诗 12980](https://jihulab.com/groups/gitlab-cn/-/epics/12980) 中进行跟踪。

<a id="how-to-generate-a-cyclonedx-sbom-report"></a>

## 如何生成 CycloneDX SBOM 报告

使用 [CycloneDX SBOM 报告](../../../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 向极狐GitLab注册您的项目组件。

CycloneDX 报告必须符合：

- [CycloneDX 规范](https://github.com/CycloneDX/specification) 版本 `1.4`、`1.5` 或 `1.6`。
- [适用于容器扫描的极狐GitLab CycloneDX 属性分类](../../../../development/sec/cyclonedx_property_taxonomy.md#gitlabcontainer_scanning-namespace-taxonomy)。

极狐GitLab 提供能生成与极狐GitLab兼容报告的安全扫描器：

- [容器扫描](../_index.md#getting-started)
- [仓库容器扫描](../_index.md#container-scanning-for-registry)

<a id="checking-new-vulnerabilities"></a>

## 检查新漏洞

持续漏洞扫描检测到的新漏洞会显示在[漏洞报告](../../vulnerability_report/_index.md)中。但是，它们不会列出在检测到受影响 SBOM 组件的流水线中。

在添加或更新[安全公告](#security-advisories)后，会创建漏洞。将相应漏洞添加到项目可能需要几个小时，前提是代码库保持不变。仅考虑过去 14 天内发布的安全公告用于持续漏洞扫描。

<a id="when-vulnerabilities-are-no-longer-detected"></a>

## 当不再检测到漏洞时

持续漏洞扫描会在新安全公告发布时自动创建漏洞，但无法判断漏洞何时不再存在于项目中。为此，极狐GitLab 仍然需要为默认分支在流水线中执行[容器扫描](../_index.md)，并生成包含最新信息的相应安全报告产物。当处理这些报告时，如果不再包含某些漏洞，即使这些漏洞是由持续漏洞扫描创建的，它们也会被标记为已不存在。

> [!warning]
> 通过仓库容器扫描检测到的漏洞无法使用此方法解决，即使在镜像中修复后，它们仍然可见。这是因为仓库容器扫描仅生成 SBOM，而不生成将漏洞标记为已解决所需的安全报告。

<a id="security-advisories"></a>

## 安全公告

持续漏洞扫描使用软件包元数据数据库，这是一项由极狐GitLab 管理的服务，用于聚合许可证和安全公告数据，并定期发布更新，供 JihuLab.com 和私有化部署实例使用。

在 JihuLab.com 上，同步由极狐GitLab 管理，所有项目均可使用。

在私有化部署实例上，你可以在极狐GitLab 实例的**管理员**区域[选择要同步的软件包仓库元数据](../../../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)。

<a id="data-sources"></a>

### 数据源

当前安全公告的数据源包括：

- [Trivy DB](https://github.com/aquasecurity/trivy-db)，基于 Aqua Security 的 [`vuln-list 仓库`](https://github.com/aquasecurity/vuln-list) 构建

<a id="contributing-to-the-vulnerability-database"></a>

### 贡献漏洞数据库

要查找漏洞，你可以搜索包含原始数据的 Aqua Security 的 [`vuln-list 仓库`](https://github.com/aquasecurity/vuln-list)。你还可以向 Trivy-DB [贡献](https://github.com/aquasecurity/vuln-list-update/blob/main/CONTRIBUTING.md)。