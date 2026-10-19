---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 迁移至基于 SBOM 的依赖项扫描
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 基于 Gemnasium 分析器的依赖项扫描功能在极狐GitLab 17.9 中已弃用，并计划在极狐GitLab 20.0 中移除。但移除时间表尚未最终确定，你可以根据需要继续使用 Gemnasium。

{{< /history >}}

依赖项扫描功能正在升级到极狐GitLab SBOM 漏洞扫描器。
作为此变更的一部分，[基于 SBOM 的依赖项扫描](dependency_scanning_sbom/_index.md) 功能以及[新的依赖项扫描分析器](https://jihulab.com/gitlab-cn/security-products/analyzers/dependency-scanning)
取代了基于 Gemnasium 分析器的传统依赖项扫描功能。然而，由于该过渡引入了重大变化，无法自动实施，本文档旨在提供一份迁移指南。

如果你使用极狐GitLab 依赖项扫描且满足以下任一条件，请遵循本迁移指南：

- 依赖项扫描 CI/CD 作业是通过 include 依赖项扫描 CI/CD 模板配置的。

  ```yaml
    include:
      - template: Jobs/Dependency-Scanning.gitlab-ci.yml
      - template: Jobs/Dependency-Scanning.latest.gitlab-ci.yml
  ```

- 依赖项扫描 CI/CD 作业是通过使用[扫描执行策略](../policies/scan_execution_policies.md)配置的。
- 依赖项扫描 CI/CD 作业是通过使用[流水线执行策略](../policies/pipeline_execution_policies.md)配置的。

<a id="understand-the-changes"></a>

## 了解变更

在将项目迁移至基于 SBOM 的依赖项扫描之前，你应该
了解正在引入的根本性变更。这次过渡是一次
技术演进，是一种在极狐GitLab 中实现依赖项扫描的全新方法，
并在用户体验方面带来了诸多改进，包括但不限于以下方面：

- 增加了语言支持。
  已弃用的 Gemnasium 分析器仅限于少数几个 Python
  和 Java 版本。新分析器为组织提供了必要的
  灵活性，使其可以在旧项目中使用旧版工具链，
  并且可以选择尝试较新版本，而无需等待分析器镜像的重大更新。此外，新分析器受益于更广泛的
  [文件覆盖范围](https://jihulab.com/gitlab-cn/security-products/analyzers/dependency-scanning#supported-files)。
- 性能提升。
  根据应用程序的不同，Gemnasium
  分析器所触发的构建可能持续近一个小时，并且是一种重复工作。
  新分析器不再直接调用构建系统。相反，它复用之前
  定义的构建作业，以提升整体扫描性能。
- 更小的攻击面。
  为支持其构建能力，Gemnasium 分析器预装了
  各种依赖项。新分析器移除了其中大量
  依赖项，从而减少了攻击面。
- 更简单的配置。
  已弃用的 Gemnasium 分析器通常需要配置
  代理、证书颁发机构 (CA) 证书包以及各种其他实用程序
  才能正常工作。新方案移除了其中许多要求，从而提供了一个
  更易于配置的稳健工具。

<a id="a-new-approach-to-security-scanning"></a>

### 安全扫描的新方法

使用传统的依赖项扫描功能时，所有扫描工作都在你的 CI/CD 流水线中进行。运行扫描时，Gemnasium 分析器同时处理两项关键任务：识别项目的依赖项，并立即使用本地的极狐GitLab 通告数据库及其特定的安全扫描引擎对这些依赖项进行安全分析。然后，它将结果输出到各种报告（CycloneDX SBOM 和依赖项扫描安全报告）中。

另一方面，基于 SBOM 的依赖项扫描功能依赖于一种解耦的依赖项分析方法，该方法将依赖项检测与其他分析（如静态可达性或漏洞扫描）分离开来。虽然这些任务仍在同一个 CI/CD 作业中执行，但它们作为解耦、可复用的组件运行。例如，漏洞扫描分析复用了统一的引擎——极狐GitLab SBOM 漏洞扫描器，该扫描器也支持极狐GitLab 持续漏洞扫描功能。这也为未来的集成点开辟了机会，从而实现更灵活的漏洞扫描工作流。

阅读更多关于基于 SBOM 的依赖项扫描如何[扫描应用程序](dependency_scanning_sbom/_index.md#how-it-scans-an-application)的内容。

<a id="cicd-configuration"></a>

### CI/CD 配置

为避免对 CI/CD 流水线造成中断，新方法不适用于稳定的依赖项扫描 CI/CD 模板 (`Dependency-Scanning.gitlab-ci.yml`)，并且从极狐GitLab 18.5 开始，你必须使用 `v2` 模板 (`Dependency-Scanning.v2.gitlab-ci.yml`) 来启用它。
随着该功能的成熟，可能会考虑其他迁移路径。

如果你正在使用[扫描执行策略](../policies/scan_execution_policies.md)，这些变更同样适用，因为它们基于 CI/CD 模板构建。

如果你正在使用[主要的依赖项扫描 CI/CD 组件](https://gitlab.com/components/dependency-scanning/-/tree/main/templates/main)，你将不会看到任何变化，因为它已经使用了新的分析器。
但是，如果你正在使用针对 Android、Rust、Swift 或 CocoaPods 的专用组件，则需要迁移到现在支持所有受支持语言和软件包管理器的主组件。

<a id="build-support-for-java-and-python"></a>

### Java 和 Python 的构建支持

一项重大变更影响了依赖项的发现方式，特别是对于 Java 和 Python 项目。新分析器采用了一种不同的方法：它不再尝试构建你的应用程序来确定依赖项，而是需要通过锁文件或依赖项图文件显式提供依赖项信息。
这意味着你需要确保这些文件可用，方法可以是将其提交到代码仓中，或者是在 CI/CD 流水线中动态生成它们。虽然这需要进行一些初始设置，但它能在不同环境中提供更可靠、更一致的结果。
如果必要，以下部分将指导你完成使项目适应这种新方法所需的具体步骤。

<a id="accessing-scan-results"></a>

### 访问扫描结果

当使用 `Dependency-Scanning.v2.gitlab-ci.yml` 时，用户可以将依赖项扫描结果作为作业产物 (`gl-dependency-scanning-report.json`) 来查看。

<a id="beta-behavior"></a>

#### Beta 行为

依赖项扫描报告产物已包含在正式发布版本中。
Beta 行为记录如下，仅供参考，但不再
正式支持，并可能从产品中移除。

<details>
  <summary>展开此部分，了解访问漏洞扫描结果方式的变更详情。</summary>

  当迁移到基于 SBOM 的依赖项扫描时，你会注意到安全扫描结果处理方式的根本变化。新方法将安全分析从 CI/CD 流水线移至极狐GitLab 平台内部，这改变了你访问和处理结果的方式。
  在传统依赖项扫描功能中，使用 Gemnasium 分析器的 CI/CD 作业会生成包含扫描结果的[依赖项扫描报告产物](../../../ci/yaml/artifacts_reports.md#artifactsreportsdependency_scanning)，并将其上传到平台。你可以通过作业产物提供的所有可能方式访问这些结果。这意味着你可以在结果到达极狐GitLab 平台之前，在 CI/CD 流水线中对其进行处理或修改。
  基于 SBOM 的依赖项扫描方法则不同。安全分析现在使用内置的极狐GitLab SBOM 漏洞扫描器在极狐GitLab 平台内部进行，因此你将无法再在作业产物中找到扫描结果。相反，极狐GitLab 会分析 CI/CD 流水线生成的 [CycloneDX SBOM 报告产物](../../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx)，并直接在极狐GitLab 平台中创建安全发现。
  为了帮助你平稳过渡，极狐GitLab 保持了一定的向后兼容性。在使用 Gemnasium 分析器时，你仍然会获得一个包含扫描结果的标准产物（使用 `artifacts:paths`）。这意味着如果你有需要这些结果的后续 CI/CD 作业，它们仍然可以访问。但是，请注意，随着极狐GitLab SBOM 漏洞扫描器不断演进和改进，这些基于产物的结果将无法反映最新的增强功能。
  当你准备完全迁移到新的依赖项扫描分析器时，你需要调整以编程方式访问扫描结果的方式。你将使用极狐GitLab GraphQL API，特别是 [`Pipeline.securityReportFindings` 资源](../../../api/graphql/reference/_index.md#pipelinesecurityreportfindings)，而不是读取作业产物。
</details>

<a id="compliance-framework-considerations"></a>

### 合规框架注意事项

迁移到基于 SBOM 的依赖项扫描时，请注意对合规框架的潜在影响：

- 在使用基于 SBOM 的扫描时，极狐GitLab 私有化部署实例（从 18.4 开始）上的“依赖项扫描正在运行”合规控制可能会失败，因为它期望的是传统的 `gl-dependency-scanning-report.json` 产物。
- 此问题不影响 JihuLab.com 实例。
- 如果你的组织使用带有依赖项扫描控制的合规框架，请先在非生产环境中测试迁移。

有关更多信息，请参见[合规框架兼容性](dependency_scanning_sbom/troubleshooting_ds_sbom_analyzer.md#compliance-framework-compatibility)。

<a id="identify-affected-projects"></a>

## 识别受影响的项目

了解哪些项目需要注意此次迁移是重要的第一步。影响最大的是你的 Java 和 Python 项目，因为它们处理依赖项的方式正在发生根本性变化。
为了帮助你识别受影响的项目，极狐GitLab 提供了[依赖项扫描构建支持检测助手](https://gitlab.com/security-products/tooling/build-support-detection-helper)工具。该工具会检查你的极狐GitLab 群组或极狐GitLab 私有化部署实例，并识别当前使用依赖项扫描功能且带有 `gemnasium-maven-dependency_scanning` 或 `gemnasium-python-dependency_scanning` CI/CD 作业的项目。
当你运行此工具时，它会生成一份全面的报告，列出在迁移过程中需要你关注的项目。尽早掌握这些信息有助于你有效规划迁移策略，尤其是在管理组织内多个项目时。

<a id="migrate-to-dependency-scanning-using-sbom"></a>

## 迁移至基于 SBOM 的依赖项扫描

先决条件：

- 要编辑 `.gitlab-ci.yml` 文件或使用 CI/CD 组件：需要项目的开发者、维护者或所有者角色。
- 要编辑扫描执行或流水线执行策略：需要群组的所有者角色，或具有 `manage_security_policy_link` 权限的自定义角色。

要迁移至基于 SBOM 的依赖项扫描方法，请对每个项目执行以下步骤：

1. 移除基于 Gemnasium 分析器的现有依赖项扫描自定义设置。
   - 如果你在项目的 `.gitlab-ci.yml` 或流水线执行策略的 CI/CD 配置中手动覆盖了 `gemnasium-dependency_scanning`、`gemnasium-maven-dependency_scanning` 或 `gemnasium-python-dependency_scanning` CI/CD 作业以对其进行自定义，请将其移除。
   - 如果你配置了任何[受影响的 CI/CD 变量](#changes-to-cicd-variables)，请相应地调整你的配置。
1. 通过以下选项之一启用基于 SBOM 的依赖项扫描功能：
   - **推荐**：使用 `v2` 依赖项扫描 CI/CD 模板 `Dependency-Scanning.v2.gitlab-ci.yml` 来运行新的依赖项扫描分析器：
     1. 确保你的 `.gitlab-ci.yml` CI/CD 配置中包含 `v2` 依赖项扫描 CI/CD 模板。
     1. 如有需要，请按照下面的特定语言说明调整你的项目和 CI/CD 配置。
   - 使用[扫描执行策略](dependency_scanning_sbom/_index.md#enforce-scanning-on-multiple-projects)来运行新的依赖项扫描分析器：
     1. 编辑已配置的依赖项扫描扫描执行策略，并确保它使用 `v2` 模板。
     1. 如有需要，请按照下面的特定语言说明调整你的项目和 CI/CD 配置。
   - 使用[流水线执行策略](dependency_scanning_sbom/_index.md#enforce-scanning-on-multiple-projects)来运行新的依赖项扫描分析器：
     1. 编辑已配置的流水线执行策略，并确保它使用 `v2` 模板。
     1. 如有需要，请按照下面的特定语言说明调整你的项目和 CI/CD 配置。
   - 使用[依赖项扫描 CI/CD 组件](https://gitlab.com/explore/catalog/components/dependency-scanning)来运行新的依赖项扫描分析器：
     1. 在你的 `.gitlab-ci.yml` CI/CD 配置中，将依赖项扫描 CI/CD 模板的 `include` 语句替换为依赖项扫描 CI/CD 组件。
     1. 如有需要，请按照下面的特定语言说明调整你的项目和 CI/CD 配置。

对于多语言项目，请完成所有相关的特定语言迁移步骤。

> [!note]
> 如果你决定从 CI/CD 模板迁移到 CI/CD 组件，请查看极狐GitLab 私有化部署的[当前限制](../../../ci/components/_index.md#use-a-gitlabcom-component-on-gitlab-self-managed)。

<a id="language-specific-instructions"></a>

## 特定语言说明

在迁移到新的依赖项扫描分析器时，你需要根据项目的编程语言和软件包管理器进行特定的调整。无论你如何配置它运行（通过 CI/CD 模板、扫描执行策略或依赖项扫描 CI/CD 组件），这些说明都适用。
在以下部分中，你将找到每种受支持语言和软件包管理器的详细说明。每项说明都解释了：

- 依赖项检测方式的变化
- 你需要提供哪些特定文件
- 如果这些文件尚未成为你工作流的一部分，如何生成它们

<a id="bundler"></a>

### Bundler

**先前行为**：基于 Gemnasium 分析器的依赖项扫描支持 Bundler 项目，它使用 `gemnasium-dependency_scanning` CI/CD 作业，并通过解析 `Gemfile.lock` 文件（也支持备用文件名 `gems.locked`）来提取项目依赖项。支持的 Bundler 版本和 `Gemfile.lock` 文件的组合详细信息，请参见[依赖项扫描（基于 Gemnasium）文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。

**新行为**：新的依赖项扫描分析器同样通过解析 `Gemfile.lock` 文件（也支持备用文件名 `gems.locked`）来提取项目依赖项，并使用 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

<a id="migrate-a-bundler-project"></a>

#### 迁移 Bundler 项目

迁移 Bundler 项目以使用新的依赖项扫描分析器。

先决条件：

- 完成所有项目所需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 Bundler 项目以使用依赖项扫描分析器无需任何额外步骤。

<a id="cocoapods"></a>

### CocoaPods

**先前行为**：基于 Gemnasium 分析器的依赖项扫描在使用 CI/CD 模板或扫描执行策略时不支持 CocoaPods 项目。对 CocoaPods 的支持仅通过实验性的 CocoaPods CI/CD 组件提供。

**新行为**：新的依赖项扫描分析器通过解析 `Podfile.lock` 文件来提取项目依赖项，并使用 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

<a id="migrate-a-cocoapods-project"></a>

#### 迁移 CocoaPods 项目

迁移 CocoaPods 项目以使用新的依赖项扫描分析器。

先决条件：

- 完成所有项目所需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 CocoaPods 项目以使用依赖项扫描分析器无需任何额外步骤。

<a id="composer"></a>

### Composer

**先前行为**：基于 Gemnasium 分析器的依赖项扫描支持 Composer 项目，它使用 `gemnasium-dependency_scanning` CI/CD 作业，并通过解析 `composer.lock` 文件来提取项目依赖项。支持的 Composer 版本和 `composer.lock` 文件的组合详细信息，请参见[依赖项扫描（基于 Gemnasium）文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。

**新行为**：新的依赖项扫描分析器同样通过解析 `composer.lock` 文件来提取项目依赖项，并使用 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

<a id="migrate-a-composer-project"></a>

#### 迁移 Composer 项目

迁移 Composer 项目以使用新的依赖项扫描分析器。

先决条件：

- 完成所有项目所需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 Composer 项目以使用依赖项扫描分析器无需任何额外步骤。

<a id="conan"></a>

### Conan

**先前行为**：基于 Gemnasium 分析器的依赖项扫描支持 Conan 项目，它使用 `gemnasium-dependency_scanning` CI/CD 作业，并通过解析 `conan.lock` 文件来提取项目依赖项。支持的 Conan 版本和 `conan.lock` 文件的组合详细信息，请参见[依赖项扫描（基于 Gemnasium）文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。

**新行为**：新的依赖项扫描分析器同样通过解析 `conan.lock` 文件来提取项目依赖项，并使用 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

<a id="migrate-a-conan-project"></a>

#### 迁移 Conan 项目

迁移 Conan 项目以使用新的依赖项扫描分析器。

先决条件：

- 完成所有项目所需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 Conan 项目以使用依赖项扫描分析器无需任何额外步骤。

<a id="go"></a>

### Go

**先前行为**：基于 Gemnasium 分析器的依赖项扫描支持 Go 项目，它使用 `gemnasium-dependency_scanning` CI/CD 作业，并通过使用 `go.mod` 和 `go.sum` 文件来提取项目依赖项。该分析器会尝试执行 `go list` 命令以提高检测到的依赖项的准确性，这需要一个可运行的 Go 环境。如果失败，它会回退到解析 `go.sum` 文件。支持的 Go 版本、`go.mod` 和 `go.sum` 文件的组合详细信息，请参见[依赖项扫描（基于 Gemnasium）文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。

**新行为**：新的依赖项扫描分析器不会尝试在项目中执行 `go list` 命令来提取依赖项，也不再回退到解析 `go.sum` 文件。相反，项目必须至少提供一个 `go.mod` 文件，并且理想情况下提供一个使用 Go 工具链中的 [`go mod graph` 命令](https://go.dev/ref/mod#go-mod-graph)生成的 `go.graph` 文件。需要 `go.graph` 文件来提高检测到的组件的准确性，并生成依赖项图以支持诸如[依赖项路径](../dependency_list/_index.md#dependency-paths)之类的功能。这些文件由 `dependency-scanning` CI/CD 作业处理，以生成 CycloneDX SBOM 报告产物。这种方法不要求极狐GitLab 支持特定的 Go 版本。

<a id="migrate-a-go-project"></a>

#### 迁移 Go 项目

迁移 Go 项目以使用新的依赖项扫描分析器。

先决条件：

- 完成所有项目所需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

要迁移 Go 项目：

- 确保你的项目提供了 `go.mod` 和 `go.graph` 文件。在运行依赖项扫描作业之前，在前置的 CI/CD 作业（例如：`build`）中配置 Go 工具链中的 [`go mod graph` 命令](https://go.dev/ref/mod#go-mod-graph)，以动态生成 `dependencies.lock` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

有关更多详细信息和示例，请参见 [Go 的启用说明](dependency_scanning_sbom/_index.md#go)。

<a id="gradle"></a>

### Gradle

**先前行为**：基于 Gemnasium 分析器的依赖项扫描支持 Gradle 项目，它使用 `gemnasium-maven-dependency_scanning` CI/CD 作业，通过从 `build.gradle` 和 `build.gradle.kts` 文件构建应用程序来提取项目依赖项。Java、Kotlin 和 Gradle 的受支持版本组合非常复杂，详细信息请参见[依赖项扫描（基于 Gemnasium）文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)。

**新行为**：新的依赖项扫描分析器不会构建项目来提取依赖项。相反，项目必须提供一个使用 [Gradle Dependency Lock Plugin](https://github.com/nebula-plugins/gradle-dependency-lock-plugin) 生成的 `dependencies.lock` 文件。该文件由 `dependency-scanning` CI/CD 作业处理，以生成 CycloneDX SBOM 报告产物。这种方法不要求极狐GitLab 支持特定的 Java、Kotlin 和 Gradle 版本。

<a id="migrate-a-gradle-project"></a>

#### 迁移 Gradle 项目

迁移 Gradle 项目以使用新的依赖项扫描分析器。

先决条件：

- 完成所有项目所需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

要迁移 Gradle 项目：

- 确保你的项目提供了 `dependencies.lock` 文件。在你的项目中配置 [Gradle Dependency Lock Plugin](https://github.com/nebula-plugins/gradle-dependency-lock-plugin)，然后：
  - 将该插件永久集成到你的开发工作流中。这意味着将 `dependencies.lock` 文件提交到代码仓中，并在更改项目依赖项时更新它。
  - 在运行依赖项扫描作业之前，在前置的 CI/CD 作业（例如：`build`）中使用该命令，以动态生成 `dependencies.lock` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

有关更多详细信息和示例，请参见 [Gradle 的启用说明](dependency_scanning_sbom/_index.md#gradle)。

<a id="maven"></a>

### Maven

**先前行为**：基于 Gemnasium 分析器的依赖项扫描支持 Maven 项目，它使用 `gemnasium-maven-dependency_scanning` CI/CD 作业，通过从 `pom.xml` 文件构建应用程序来提取项目依赖项。Java、Kotlin 和 Maven 的受支持版本组合非常复杂，详细信息请参见[依赖项扫描（基于 Gemnasium）文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)。

**新行为**：新的依赖项扫描分析器不会构建项目来提取依赖项。相反，项目必须提供一个使用 [maven dependency plugin](https://maven.apache.org/plugins/maven-dependency-plugin/index.html) 生成的 `maven.graph.json` 文件。该文件由 `dependency-scanning` CI/CD 作业处理，以生成 CycloneDX SBOM 报告产物。这种方法不要求极狐GitLab 支持特定的 Java、Kotlin 和 Maven 版本。

<a id="migrate-a-maven-project"></a>

#### 迁移 Maven 项目

迁移 Maven 项目以使用新的依赖项扫描分析器。

先决条件：

- 完成所有项目所需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。
### Maven

<a id="maven"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-maven-dependency_scanning` CI/CD 作业支持 Maven 项目，通过从源代码仓库中的 `pom.xml` 文件构建应用来提取依赖项，或根据已发布的软件包版本（可从本地 Maven 仓库安装）提取依赖项。支持 Java 和 Maven 的版本组合较为复杂，详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)。

**新行为**：新的依赖扫描分析器不会通过构建项目来提取依赖项。相反，项目必须提供一个 `maven.graph.json` 文件，该文件由 [maven 依赖插件](https://maven.apache.org/plugins/maven-dependency-plugin/index.html)（Maven 3.1.0 及以上版本内置）生成。此文件会由 `dependency-scanning` CI/CD 作业处理，生成 CycloneDX SBOM 报告产物。这种方式不再要求极狐GitLab 支持特定版本的 Java 和 Maven。

#### 迁移 Maven 项目

<a id="migrate-a-maven-project"></a>

要迁移 Maven 项目：

- 确保你的项目提供了 `maven.graph.json` 文件。在运行依赖扫描作业之前的 CI/CD 作业（例如：`build`）中配置 [maven 依赖插件](https://maven.apache.org/plugins/maven-dependency-plugin/index.html)，动态生成 `maven.graph.json` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

更多详情和示例请参阅 [Maven 的启用说明](dependency_scanning_sbom/_index.md#maven)。

### npm

<a id="npm"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-dependency_scanning` CI/CD 作业支持 npm 项目，通过解析 `package-lock.json` 或 `npm-shrinkwrap.json.lock` 文件来提取项目依赖项。支持的 npm 版本和锁文件的组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。该分析器可能会使用 `Retire.JS` 扫描器扫描 npm 项目中引入的 JavaScript 文件。

**新行为**：新的依赖扫描分析器同样通过解析 `package-lock.json` 或 `npm-shrinkwrap.json.lock` 文件来提取项目依赖项，并通过 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。该分析器不会扫描引入的 JavaScript 文件。替代功能已[在史诗 7186 中提出](https://jihulab.com/gitlab-cn/-/epics/7186)。

#### 迁移 npm 项目

<a id="migrate-an-npm-project"></a>

将 npm 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 npm 项目无需额外步骤。

### NuGet

<a id="nuget"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-dependency_scanning` CI/CD 作业支持 NuGet 项目，通过解析 `packages.lock.json` 文件来提取项目依赖项。支持的 NuGet 版本和锁文件的组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。

**新行为**：新的依赖扫描分析器同样通过解析 `packages.lock.json` 文件来提取项目依赖项，并通过 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

#### 迁移 NuGet 项目

<a id="migrate-a-nuget-project"></a>

将 NuGet 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 NuGet 项目无需额外步骤。

### pip

<a id="pip"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-python-dependency_scanning` CI/CD 作业支持 pip 项目，通过从 `requirements.txt` 文件构建应用来提取项目依赖项（也支持 `requirements.pip` 和 `requires.txt` 等其他文件名）。`PIP_REQUIREMENTS_FILE` 环境变量也可用于指定自定义文件名。Python 和 pip 的支持版本组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)。

**新行为**：新的依赖扫描分析器不会通过构建项目来提取依赖项。相反，项目必须提供一个由 [pip-compile 命令行工具](https://pip-tools.readthedocs.io/en/latest/cli/pip-compile/) 生成的 `requirements.txt` 锁文件。此文件会由 `dependency-scanning` CI/CD 作业处理，生成 CycloneDX SBOM 报告产物。这种方式不再要求极狐GitLab 支持特定版本的 Python 和 pip。也可以使用 `pipcompile_lockfile_file_name_pattern` spec 输入或 `DS_PIPCOMPILE_LOCKFILE_FILE_NAME_PATTERN` 变量来为 pip-compile 锁文件指定自定义文件名。

或者，项目可以提供由 [pipdeptree 命令行工具](https://pypi.org/project/pipdeptree/) 生成的 `pipdeptree.json` 文件。

#### 迁移 pip 项目

<a id="migrate-a-pip-project"></a>

将 pip 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 pip 项目，请执行以下任一操作：

- 确保你的项目提供了 `requirements.txt` 锁文件。在你的项目中配置 [pip-compile 命令行工具](https://pip-tools.readthedocs.io/en/latest/cli/pip-compile/)，然后选择以下方式之一：
  - 将命令行工具永久集成到你的开发工作流中。这意味着将 `requirements.txt` 文件提交到代码仓库，并在修改项目依赖项时对其进行更新。
  - 在运行依赖扫描作业之前的 CI/CD 作业（例如：`build`）中使用该命令行工具，动态生成 `requirements.txt` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

或者

- 确保你的项目提供了 `pipdeptree.json` 锁文件。在运行依赖扫描作业之前的 CI/CD 作业（例如：`build`）中配置 [pipdeptree 命令行工具](https://pypi.org/project/pipdeptree/)，动态生成 `pipdeptree.json` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

更多详情和示例请参阅 [pip 的启用说明](dependency_scanning_sbom/_index.md#pip)。

### Pipenv

<a id="pipenv"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-python-dependency_scanning` CI/CD 作业支持 Pipenv 项目，通过从 `Pipfile` 文件构建应用来提取项目依赖项，或从 `Pipfile.lock` 文件（如果存在）提取。Python 和 Pipenv 的支持版本组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)。

**新行为**：新的依赖扫描分析器不会通过构建 Pipenv 项目来提取依赖项。相反，项目必须至少提供一个 `Pipfile.lock` 文件，理想情况下还应提供由 [`pipenv graph` 命令](https://pipenv.pypa.io/en/latest/cli.html#graph) 生成的 `pipenv.graph.json` 文件。`pipenv.graph.json` 文件是生成依赖图并启用[依赖路径](../dependency_list/_index.md#dependency-paths)等功能所必需的。这些文件会由 `dependency-scanning` CI/CD 作业处理，生成 CycloneDX SBOM 报告产物。这种方式不再要求极狐GitLab 支持特定版本的 Python 和 Pipenv。

#### 迁移 Pipenv 项目

<a id="migrate-a-pipenv-project"></a>

将 Pipenv 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 Pipenv 项目，请执行以下任一操作：

- 确保你的项目提供了 `Pipfile.lock` 文件。在你的项目中配置 [`pipenv lock` 命令](https://pipenv.pypa.io/en/latest/cli.html#graph)，然后选择以下方式之一：
  - 将该命令永久集成到你的开发工作流中。这意味着将 `Pipfile.lock` 文件提交到代码仓库，并在修改项目依赖项时对其进行更新。
  - 在运行依赖扫描作业之前的 CI/CD 作业（例如：`build`）中使用该命令，动态生成 `Pipfile.lock` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

或者

- 确保你的项目提供了 `pipenv.graph.json` 文件。在运行依赖扫描作业之前的 CI/CD 作业（例如：`build`）中配置 [`pipenv graph` 命令](https://pipenv.pypa.io/en/latest/cli.html#graph)，动态生成 `pipenv.graph.json` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

更多详情和示例请参阅 [Pipenv 的启用说明](dependency_scanning_sbom/_index.md#pipenv)。

### Poetry

<a id="poetry"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-python-dependency_scanning` CI/CD 作业支持 Poetry 项目，通过解析 `poetry.lock` 文件来提取项目依赖项。Poetry 和锁文件的版本组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。

**新行为**：新的依赖扫描分析器同样通过解析 `poetry.lock` 文件来提取项目依赖项，并通过 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

#### 迁移 Poetry 项目

<a id="migrate-a-poetry-project"></a>

将 Poetry 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 Poetry 项目无需额外步骤。

### pnpm

<a id="pnpm"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-dependency_scanning` CI/CD 作业支持 pnpm 项目，通过解析 `pnpm-lock.yaml` 文件来提取项目依赖项。pnpm 和锁文件的版本组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。该分析器可能会使用 `Retire.JS` 扫描器扫描 pnpm 项目中引入的 JavaScript 文件。

**新行为**：新的依赖扫描分析器同样通过解析 `pnpm-lock.yaml` 文件来提取项目依赖项，并通过 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。该分析器不会扫描引入的 JavaScript 文件。替代功能已[在史诗 7186 中提出](https://jihulab.com/gitlab-cn/-/epics/7186)。

#### 迁移 pnpm 项目

<a id="migrate-a-pnpm-project"></a>

将 pnpm 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 pnpm 项目无需额外步骤。

### sbt

<a id="sbt"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-maven-dependency_scanning` CI/CD 作业支持 sbt 项目，通过从 `build.sbt` 文件构建应用来提取项目依赖项。Java、Scala 和 sbt 的版本组合较为复杂，详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)。

**新行为**：新的依赖扫描分析器不会通过构建项目来提取依赖项。相反，项目必须提供一个由 [sbt-dependency-graph 插件](https://github.com/sbt/sbt-dependency-graph)（[已包含在 sbt 1.4.0 及以上版本中](https://www.scala-sbt.org/1.x/docs/sbt-1.4-Release-Notes.html#sbt-dependency-graph+is+in-sourced)）生成的 `dependencies-compile.dot` 文件。此文件会由 `dependency-scanning` CI/CD 作业处理，生成 CycloneDX SBOM 报告产物。这种方式不再要求极狐GitLab 支持特定版本的 Java、Scala 和 sbt。

#### 迁移 sbt 项目

<a id="migrate-an-sbt-project"></a>

将 sbt 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 sbt 项目：

- 确保你的项目提供了 `dependencies-compile.dot` 文件。在运行依赖扫描作业之前的 CI/CD 作业（例如：`build`）中配置 [sbt-dependency-graph 插件](https://github.com/sbt/sbt-dependency-graph)，动态生成 `dependencies-compile.dot` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)。

更多详情和示例请参阅 [sbt 的启用说明](dependency_scanning_sbom/_index.md#sbt)。

### setuptools

<a id="setuptools"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-python-dependency_scanning` CI/CD 作业支持 setuptools 项目，通过从 `setup.py` 文件构建应用来提取项目依赖项。Python 和 setuptools 的支持版本组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)。

**新行为**：新的依赖扫描分析器不支持通过构建 setuptools 项目来提取依赖项。请配置 [pip-compile 命令行工具](https://pip-tools.readthedocs.io/en/latest/cli/pip-compile/) 来生成兼容的 `requirements.txt` 锁文件。或者，你可以提供自己的 CycloneDX SBOM 文档。

#### 迁移 setuptools 项目

<a id="migrate-a-setuptools-project"></a>

将 setuptools 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 setuptools 项目：

- 确保你的项目提供了 `requirements.txt` 锁文件。在你的项目中配置 [pip-compile 命令行工具](https://pip-tools.readthedocs.io/en/latest/cli/pip-compile/)，然后选择以下方式之一：
  - 将命令行工具永久集成到你的开发工作流中。这意味着将 `requirements.txt` 文件提交到代码仓库，并在修改项目依赖项时对其进行更新。
  - 在 `build` CI/CD 作业中使用该命令行工具，动态生成 `requirements.txt` 文件并将其导出为[产物](../../../ci/jobs/job_artifacts.md)，以便在运行依赖扫描作业前使用。

更多详情和示例请参阅 [pip 的启用说明](dependency_scanning_sbom/_index.md#pip)。

### Swift

<a id="swift"></a>

**旧行为**：基于 Gemnasium 的依赖扫描在使用 CI/CD 模板或扫描执行策略时，不支持 Swift 项目。对 Swift 的支持仅在实验性的 Swift CI/CD 组件中可用。

**新行为**：新的依赖扫描分析器通过解析 `Package.resolved` 文件来提取项目依赖项，并通过 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

#### 迁移 Swift 项目

<a id="migrate-a-swift-project"></a>

将 Swift 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 Swift 项目无需额外步骤。

### uv

<a id="uv"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-dependency_scanning` CI/CD 作业支持 uv 项目，通过解析 `uv.lock` 文件来提取项目依赖项。uv 和锁文件的版本组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。

**新行为**：新的依赖扫描分析器同样通过解析 `uv.lock` 文件来提取项目依赖项，并通过 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。

#### 迁移 uv 项目

<a id="migrate-a-uv-project"></a>

将 uv 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 uv 项目无需额外步骤。

### Yarn

<a id="yarn"></a>

**旧行为**：基于 Gemnasium 的依赖扫描使用 `gemnasium-dependency_scanning` CI/CD 作业支持 Yarn 项目，通过解析 `yarn.lock` 文件来提取项目依赖项。Yarn 和锁文件的版本组合详见[基于 Gemnasium 的依赖扫描文档](legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles)。该分析器可为 Yarn 依赖项提供修复数据，以通过[合并请求解决漏洞](../vulnerabilities/_index.md#resolve-a-vulnerability)。该分析器可能会使用 `Retire.JS` 扫描器扫描 Yarn 项目中引入的 JavaScript 文件。

**新行为**：新的依赖扫描分析器同样通过解析 `yarn.lock` 文件来提取项目依赖项，并通过 `dependency-scanning` CI/CD 作业生成 CycloneDX SBOM 报告产物。该分析器不提供 Yarn 依赖项的修复数据。替代功能已[在史诗 759 中提出](https://jihulab.com/gitlab-cn/-/epics/759)。该分析器不会扫描引入的 JavaScript 文件。替代功能已[在史诗 7186 中提出](https://jihulab.com/gitlab-cn/-/epics/7186)。

#### 迁移 Yarn 项目

<a id="migrate-a-yarn-project"></a>

将 Yarn 项目迁移至新的依赖扫描分析器。

先决条件：

- 完成所有项目必需的[通用迁移步骤](#migrate-to-dependency-scanning-using-sbom)。
- 具有项目的开发者、维护者或所有者角色。

迁移 Yarn 项目无需额外步骤。如果你使用了通过合并请求解决漏洞功能，请查看[弃用公告](../../../update/deprecations.md#resolve-a-vulnerability-for-dependency-scanning-on-yarn-projects)了解可采取的行动。如果你使用了 JavaScript 引入文件扫描功能，请查看[弃用公告](../../../update/deprecations.md#dependency-scanning-for-javascript-vendored-libraries)了解可采取的行动。

## CI/CD 变量的变更

<a id="changes-to-cicd-variables"></a>

大多数现有 CI/CD 变量在新的依赖扫描分析器中不再适用，因此它们的值将被忽略。除非这些变量也被用于配置其他安全分析器，否则你应该将它们从 CI/CD 配置中移除。

从你的 CI/CD 配置中移除以下 CI/CD 变量：

- `DS_GRADLE_RESOLUTION_POLICY`
- `DS_IMAGE_SUFFIX`
- `DS_JAVA_VERSION`
- `DS_PIP_DEPENDENCY_PATH`
- `DS_PIP_VERSION`
- `DS_REMEDIATE_TIMEOUT`
- `DS_REMEDIATE`
- `GEMNASIUM_DB_LOCAL_PATH`
- `GEMNASIUM_DB_REF_NAME`
- `GEMNASIUM_DB_REMOTE_URL`
- `GEMNASIUM_DB_UPDATE_DISABLED`
- `GEMNASIUM_IGNORED_SCOPES`
- `GEMNASIUM_LIBRARY_SCAN_ENABLED`
- `GOARCH`
- `GOFLAGS`
- `GOOS`
- `GOPRIVATE`
- `GRADLE_CLI_OPTS`
- `GRADLE_PLUGIN_INIT_PATH`
- `MAVEN_CLI_OPTS`
- `PIP_EXTRA_INDEX_URL`
- `PIP_INDEX_URL`
- `PIP_REQUIREMENTS_FILE`
- `PIPENV_PYPI_MIRROR`
- `SBT_CLI_OPTS`

保留以下仍适用于新依赖扫描分析器的 CI/CD 变量：

- `DS_EXCLUDED_PATHS`
- `DS_INCLUDE_DEV_DEPENDENCIES`
- `DS_MAX_DEPTH`
- `SECURE_ANALYZERS_PREFIX`

> [!note]
> 在新的依赖扫描分析器中，`PIP_REQUIREMENTS_FILE` 被替换为 `DS_PIP_MANIFEST_FILE_NAME_PATTERN` 或 `pip_manifest_file_name_pattern` spec 输入。

为了与用户配置（尤其是扫描执行策略）更平滑地过渡，`v2` 模板向后兼容以下配置变量（这些变量优先于其对应的 `spec:inputs`）。这些变量包括：

- `DS_PIPCOMPILE_REQUIREMENTS_FILE_NAME_PATTERN`
- `DS_MAX_DEPTH`
- `DS_EXCLUDED_PATHS`
- `DS_INCLUDE_DEV_DEPENDENCIES`
- `DS_STATIC_REACHABILITY_ENABLED`
- `SECURE_LOG_LEVEL`

此外，还新增了 3 个变量。这些变量在 `latest` 模板中不存在，用于控制漏洞扫描 API 功能。

- `DS_API_TIMEOUT`
- `DS_API_SCAN_DOWNLOAD_DELAY`
- `DS_ENABLE_VULNERABILITY_SCAN`