---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 持续容器扫描
description: 极狐GitLab 如何检测 CI/CD 流水线之外的镜像依赖中的新漏洞。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

容器扫描的持续漏洞扫描（CVS）通过将项目镜像依赖的组件名称和版本与最新的[安全公告](#security-advisories)中的信息进行比对，来查找这些依赖中的安全漏洞，而无需运行新的流水线。CVS 依赖存储在默认分支上的 CycloneDX SBOM 报告来了解项目使用了哪些组件。要生成此 SBOM，容器扫描作业必须至少在默认分支上运行一次。此后，CVS 会自动针对这些组件检测新发布的公告，无需再运行流水线。当镜像内容发生变化时，必须在默认分支上运行新的流水线以刷新 SBOM，使 CVS 能够评估更新后的组件集合。在大多数项目中，这会作为常规工作流的一部分发生，因为更改依赖通常涉及代码变更，而代码变更本身就会触发流水线。

当持续漏洞扫描对包含[受支持的软件包类型](#supported-package-types)组件的所有项目触发扫描时，[可能会出现新漏洞](#checking-new-vulnerabilities)。

由容器扫描的持续漏洞扫描创建的漏洞使用 `GitLab SBoM Vulnerability Scanner` 作为扫描器名称，使用 `Container Scanning` 作为漏洞类型。

与基于 CI/CD 的安全扫描不同，持续漏洞扫描通过后台作业（Sidekiq）执行，而不是通过 CI/CD 流水线，并且不会生成安全报告产物。

<a id="prerequisites"></a>

## 先决条件

- [CycloneDX SBOM 报告](#how-to-generate-a-cyclonedx-sbom-report)。
- [安全公告](#security-advisories)已同步到极狐GitLab 实例。

<a id="supported-package-types"></a>

## 受支持的软件包类型

持续漏洞扫描支持具有以下 [PURL 类型](https://github.com/package-url/purl-spec/blob/346589846130317464b677bc4eab30bf5040183a/PURL-TYPES.rst)的组件：

- `apk`
- `deb`
- `rpm`

已知限制：

- 不支持包含前导零的 APK 版本。支持这些版本的工作在[议题 471509](https://gitlab.com/gitlab-org/gitlab/-/issues/471509)中跟踪。
- 不支持包含 `^` 的 RPM 版本。支持这些版本的工作在[议题 459969](https://gitlab.com/gitlab-org/gitlab/-/issues/459969)中跟踪。
- 不支持 Red Hat 发行版中的 RPM 软件包。支持此用例的工作在[史诗 12980](https://gitlab.com/groups/gitlab-org/-/epics/12980)中跟踪。

<a id="how-to-generate-a-cyclonedx-sbom-report"></a>

## 如何生成 CycloneDX SBOM 报告

使用 [CycloneDX SBOM 报告](../../../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx)向极狐GitLab 注册您的项目组件。

CycloneDX 报告必须符合：

- [CycloneDX 规范](https://github.com/CycloneDX/specification)版本 `1.4`、`1.5` 或 `1.6`。
- [容器扫描的 GitLab CycloneDX 属性分类法](../../../../development/sec/cyclonedx_property_taxonomy.md#gitlabcontainer_scanning-namespace-taxonomy)。

极狐GitLab 提供可生成与极狐GitLab 兼容报告的安全分析器：

- [容器扫描](../_index.md#getting-started)
- [容器镜像仓库的容器扫描](../_index.md#container-scanning-for-registry)

<a id="turn-on-or-off-continuous-vulnerability-scanning"></a>

## 开启或关闭持续漏洞扫描

持续漏洞扫描默认对所有已摄入的 CycloneDX SBOM 文件运行。您可以为每个项目关闭它。关闭期间，当摄入新的安全公告时，不会为您的镜像依赖创建漏洞记录。

先决条件：

- 您必须拥有项目的维护者、所有者或安全管理员角色。

要开启或关闭持续漏洞扫描：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**容器扫描的持续漏洞扫描**下，开启或关闭该开关。

<a id="checking-new-vulnerabilities"></a>

## 检查新漏洞

持续漏洞扫描检测到的新漏洞会显示在[漏洞报告](../../vulnerability_report/_index.md)中。但是，它们不会列在检测到受影响 SBOM 组件的流水线中。

漏洞在[安全公告](#security-advisories)被添加或更新后创建。在代码库保持不变的情况下，相应的漏洞可能需要几个小时才会添加到您的项目中。只有过去 14 天内发布的公告才会被纳入持续漏洞扫描的考虑范围。

<a id="when-vulnerabilities-are-no-longer-detected"></a>

## 当漏洞不再被检测到时

持续漏洞扫描会在发布新公告时自动创建漏洞，但它无法判断漏洞何时不再存在于项目中。为此，极狐GitLab 仍然需要在默认分支的流水线中执行[容器扫描](../_index.md)，并生成包含最新信息的相应安全报告产物。当这些报告被处理后，如果它们不再包含某些漏洞，这些漏洞会被标记为已解决，即使它们是由持续漏洞扫描创建的。

> [!warning]
> 通过容器镜像仓库的容器扫描检测到的漏洞无法使用此方法解决，即使在镜像中修复后仍会保持可见。这是因为容器镜像仓库的容器扫描仅生成 SBOM，而不生成将漏洞标记为已解决所需的安全报告。

<a id="security-advisories"></a>

## 安全公告

持续漏洞扫描使用软件包元数据数据库，这是由 GitLab 管理的一项服务，用于汇总许可证和安全公告数据，并定期发布更新，供 JihuLab.com 和极狐GitLab 私有化部署实例使用。

在 JihuLab.com 上，同步由 GitLab 管理，并对所有项目可用。

在极狐GitLab 私有化部署上，您可以在极狐GitLab 实例的**管理**区域中[选择要同步的软件包仓库元数据](../../../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)。

<a id="data-sources"></a>

### 数据源

当前安全公告的数据源包括：

- [Trivy DB](https://github.com/aquasecurity/trivy-db)，由 Aqua security 的 [`vuln-list repository`](https://github.com/aquasecurity/vuln-list) 构建

<a id="contributing-to-the-vulnerability-database"></a>

### 为漏洞数据库做贡献

要查找漏洞，您可以搜索 Aqua security 的 [`vuln-list repository`](https://github.com/aquasecurity/vuln-list)，其中包含原始数据。您也可以[为 Trivy-DB 做贡献](https://github.com/aquasecurity/vuln-list-update/blob/main/CONTRIBUTING.md)。
