---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CycloneDX 文件的许可证扫描
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为了检测正在使用的许可证，许可证合规性依赖于运行
[依赖扫描作业](../../application_security/dependency_scanning/_index.md)，
并分析这些作业生成的 [CycloneDX](https://cyclonedx.org/) 软件物料清单 (SBOM)。
这种扫描方法能够解析和识别超过 600 种不同类型的许可证，如 [SPDX 列表](https://spdx.org/licenses/) 中所定义。
只要第三方扫描器能为[受支持的语言](#supported-languages-and-package-managers)生成 CycloneDX 报告产物，并遵循极狐GitLab CycloneDX 属性分类法，就可以使用它们来生成依赖项列表。
提供其他许可证的能力在[史诗 10861](https://gitlab.com/groups/gitlab-org/-/epics/10861) 中跟踪。

> [!note]
> 许可证扫描功能依赖于外部数据库中收集的公开可用的软件包元数据，并自动与极狐GitLab 实例同步。
> 扫描仅在极狐GitLab 实例内执行。
> 不会将上下文信息（例如，项目依赖项列表）发送到外部服务。

<a id="configuration"></a>

## 配置

要启用 CycloneDX 文件的许可证扫描：

- 使用依赖扫描模板
  - 开启[依赖扫描](../../application_security/dependency_scanning/dependency_scanning_sbom/_index.md#turn-on-dependency-scanning)
    并确保满足其先决条件。
  - 在极狐GitLab 私有化部署上，您可以在极狐GitLab 实例的 **管理** 区域中[选择要同步的软件包仓库元数据](../../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)。要使此数据同步正常工作，您必须允许从极狐GitLab 实例到域 `storage.googleapis.com` 的出站网络流量。如果您的网络连接受限或没有网络连接，请参阅文档部分[在离线环境中运行](#running-in-an-offline-environment) 以获取进一步指导。
- 或者，对于适用的软件包仓库，使用 [CI/CD 组件](../../../ci/components/_index.md)。

<a id="supported-languages-and-package-managers"></a>

## 支持的语言和软件包管理器

以下语言和软件包管理器支持许可证扫描：

<!-- markdownlint-disable MD044 -->
<table class="supported-languages">
  <thead>
    <tr>
      <th>语言</th>
      <th>软件包管理器</th>
      <th>依赖扫描模板</th>
      <th>CI/CD 组件</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>.NET</td>
      <td rowspan="2"><a href="https://www.nuget.org/">NuGet</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>C#</td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>C</td>
      <td rowspan="2"><a href="https://conan.io/">Conan</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>C++</td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>Dart</td>
      <td><a href="https://pub.dev/">pub</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>Go<sup>1</sup></td>
      <td><a href="https://go.dev/">Go</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td rowspan="3">Java</td>
      <td><a href="https://gradle.org/">Gradle</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://maven.apache.org/">Maven</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://developer.android.com/">Android</a></td>
      <td>是</td>
      <td><a href="https://gitlab.com/components/android-dependency-scanning">是</a></td>
    </tr>
    <tr>
      <td rowspan="3">JavaScript 和 TypeScript</td>
      <td><a href="https://www.npmjs.com/">npm</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://pnpm.io/">pnpm</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://classic.yarnpkg.com/en/">yarn</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>PHP</td>
      <td><a href="https://getcomposer.org/">Composer</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td rowspan="4">Python</td>
      <td><a href="https://setuptools.readthedocs.io/en/latest/">setuptools</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://pip.pypa.io/en/stable/">pip</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://pipenv.pypa.io/en/latest/">Pipenv</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://python-poetry.org/">Poetry</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>Ruby</td>
      <td><a href="https://bundler.io/">Bundler</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>Rust</td>
      <td><a href="https://doc.rust-lang.org/cargo/">cargo</a></td>
      <td>否</td>
      <td><a href="https://gitlab.com/components/dependency-scanning#generating-cargo-sboms">是</a></td>
    </tr>
    <tr>
      <td>Scala</td>
      <td><a href="https://www.scala-sbt.org/">sbt</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
    <tr>
      <td>Swift</td>
      <td><a href="https://developer.apple.com/swift/">sbt</a></td>
      <td>是</td>
      <td>否</td>
    </tr>
  </tbody>
</table>
<!-- markdownlint-enable MD044 -->

**脚注**：

1. 诸如 `stdlib` 之类的 Go 标准库不受支持，并将显示为 `unknown` 许可证。对此的支持在[议题 480305](https://gitlab.com/gitlab-org/gitlab/-/issues/480305) 中跟踪。

受支持的文件和版本与
[依赖扫描](../../application_security/dependency_scanning/dependency_scanning_sbom/_index.md#supported-languages-and-files) 所支持的一致。

<a id="data-sources"></a>

## 数据源

受支持软件包的许可证信息来自以下来源。极狐GitLab 会对原始数据进行额外处理，包括将各种变体映射到规范的许可证名称。

| 软件包管理器 | 来源                                                           |
|-----------------|------------------------------------------------------------------|
| Cargo           | <https://deps.dev/>                                              |
| Conan           | <https://github.com/conan-io/conan-center-index>                 |
| Go              | <https://index.golang.org/>                                      |
| Maven           | <https://storage.googleapis.com/maven-central>                   |
| npm             | <https://deps.dev/>                                              |
| NuGet           | <https://api.nuget.org/v3/catalog0/index.json>                   |
| Packagist       | <https://packagist.org/packages/list.json>                       |
| pub             | <https://pub.dev/>                                               |
| PyPI            | <https://warehouse.pypa.io/api-reference/bigquery-datasets.html> |
| RubyGems        | <https://rubygems.org/versions>                                  |

<a id="license-expressions"></a>

## 许可证表达式

极狐GitLab 从 CycloneDX SBOM 的 `expression` 字段中读取 SPDX [许可证表达式](https://spdx.github.io/spdx-spec/v2-draft/SPDX-license-expressions/)，包括用于自定义非 SPDX 许可证的 `LicenseRef-[NAME]` 语法。
当组件的 SBOM 条目包含 `expression` 时，极狐GitLab 会存储并评估完整的表达式。
以前，带有许可证表达式的组件会显示为 `unknown` 许可证。

[许可证批准策略](../license_approval_policies.md) 支持许可证表达式。
当策略针对的许可证在组件的表达式中作为一个项出现时，该策略会根据完整表达式正确评估。

<a id="blocking-merge-requests-based-on-detected-licenses"></a>

## 根据检测到的许可证阻止合并请求

用户可以通过配置[许可证批准策略](../license_approval_policies.md)，要求根据检测到的许可证批准合并请求。

<a id="running-in-an-offline-environment"></a>

## 在离线环境中运行

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

对于通过互联网访问外部资源有限、受限或不稳定的环境中的实例，需要进行一些调整才能成功扫描 CycloneDX 报告中的许可证。有关更多信息，请参阅离线[快速入门指南](../../../topics/offline/quick_start_guide.md#enabling-the-package-metadata-database)。

<a id="use-cyclonedx-report-as-a-source-of-license-information"></a>

## 使用 CycloneDX 报告作为许可证信息来源

许可证扫描在可用时使用 CycloneDX JSON SBOM 的 [licenses](https://cyclonedx.org/use-cases/#license-compliance) 字段。如果许可证信息不可用，则使用从外部许可证数据库导入的许可证信息。
许可证信息可以使用有效的 SPDX 标识符、许可证名称或 SPDX 许可证表达式提供。
有关许可证字段格式的更多信息，请参阅 [CycloneDX](https://cyclonedx.org/use-cases/#license-compliance) 规范。

提供 licenses 字段的兼容 CycloneDX SBOM 生成器可以在 [CycloneDX 工具中心](https://cyclonedx.org/tool-center/) 中找到。

<a id="configure-license-information-source"></a>

### 配置许可证信息来源

当两者都可用时，选择要使用的许可证信息来源。

要为项目配置首选的许可证信息来源：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **许可证信息来源** 部分，选择以下任一选项：
   - **SBOM**（默认）- 使用来自 CycloneDX 报告的许可证信息。
     - 扫描器会读取项目中位于 `/gl-sbom-*.cdx.json` 的报告中的许可证信息。
     - 要覆盖许可证，请直接更新此文件中的许可证数据。
   - **PMDB** - 使用来自外部许可证数据库的许可证信息。

<a id="enable-or-disable-license-scanning-for-cyclonedx-files"></a>

### 启用或禁用 CycloneDX 文件的许可证扫描

许可证扫描默认对所有摄入的 CycloneDX SBOM 文件运行。
您可以在安全配置页面按项目禁用许可证扫描。禁用后，来自 SBOM 摄入的许可证将在依赖项列表中显示为 `unknown`。

先决条件：

- 您必须具有项目的维护者、所有者或安全管理员角色。

要启用或禁用 CycloneDX 文件的许可证扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **CycloneDX 的许可证扫描** 部分，打开或关闭切换开关。

<a id="troubleshooting"></a>

## 故障排除

<a id="a-cyclonedx-file-is-not-being-scanned-and-appears-to-provide-no-results"></a>

### CycloneDX 文件未被扫描且似乎没有提供任何结果

确保 CycloneDX 文件符合 [CycloneDX JSON 规范](https://cyclonedx.org/docs/1.7/json/)。该规范[不允许重复条目](https://cyclonedx.org/docs/1.7/json/#components)。包含多个 SBOM 文件的项目应将每个 SBOM 文件作为单独的 CI 报告产物上报，或者如果 SBOM 作为 CI 流水线的一部分合并，则应确保删除重复项。

您可以按如下方式根据 `CycloneDX JSON specification` 验证 CycloneDX SBOM 文件：

```shell
$ docker run -it --rm -v "$PWD:/my-cyclonedx-sboms" -w /my-cyclonedx-sboms cyclonedx/cyclonedx-cli:latest cyclonedx validate --input-version v1_4 --input-file gl-sbom-all.cdx.json

Validating JSON BOM...
BOM validated successfully.
```

如果 JSON BOM 验证失败，例如，因为存在重复组件：

```shell
Validation failed: Found duplicates at the following index pairs: "(A, B), (C, D)"
#/properties/components/uniqueItems
```

此问题可以通过更新 CI 模板以使用 [jq](https://jqlang.github.io/jq/) 从 `gl-sbom-*.cdx.json` 报告中删除重复组件来解决，方法是覆盖生成重复组件的作业定义。例如，以下配置从 `gemnasium-dependency_scanning` 作业生成的 `gl-sbom-gem-bundler.cdx.json` 报告文件中删除重复组件：

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

gemnasium-dependency_scanning:
  after_script:
    - apk update && apk add jq
    - jq '.components |= unique' gl-sbom-gem-bundler.cdx.json > tmp.json && mv tmp.json gl-sbom-gem-bundler.cdx.json
```

<a id="remove-unused-license-data"></a>

### 删除未使用的许可证数据

许可证扫描更改（在极狐GitLab 15.9 中发布）需要在实例上提供大量额外的磁盘空间。此问题已在极狐GitLab 16.3 中通过[减少软件包元数据表的磁盘占用](https://gitlab.com/groups/gitlab-org/-/epics/10415) 史诗解决。但是，如果您的实例在极狐GitLab 15.9 和 16.3 之间运行了许可证扫描，您可能需要删除不需要的数据。

要删除不需要的数据：

1. 检查 [`package_metadata_synchronization`](https://about.gitlab.com/releases/2023/02/22/gitlab-15-9-released/#new-license-compliance-scanner) 功能标志当前是否已启用或之前已启用，如果是，请禁用它。使用 [Rails 控制台](../../../administration/operations/rails_console.md) 执行以下命令。

   ```ruby
   Feature.enabled?(:package_metadata_synchronization) && Feature.disable(:package_metadata_synchronization)
   ```

1. 检查数据库中是否有已弃用的数据：

   ```ruby
   PackageMetadata::PackageVersionLicense.count
   PackageMetadata::PackageVersion.count
   ```

1. 如果数据库中有已弃用的数据，请按顺序运行以下命令将其删除：

   ```ruby
   ActiveRecord::Base.connection.execute('SET statement_timeout TO 0')
   PackageMetadata::PackageVersionLicense.delete_all
   PackageMetadata::PackageVersion.delete_all
   ```

<a id="vulnerability-scanning-produces-no-results-for-a-cyclonedx-sbom"></a>

### 漏洞扫描对 CycloneDX SBOM 不产生任何结果

如果您的 CycloneDX 文件已扫描许可证，但漏洞扫描不产生任何结果，请参阅
[漏洞扫描对自定义或合并的 CycloneDX SBOM 不产生任何结果](../../application_security/dependency_scanning/legacy_dependency_scanning/troubleshooting_dependency_scanning.md#vulnerability-scanning-produces-no-results-for-custom-or-merged-cyclonedx-sboms)。

<a id="dependency-licenses-are-unknown"></a>

### 依赖项许可证未知

开源许可证信息存储在数据库中，用于解析项目依赖项的许可证。如果许可证信息不存在或该数据在数据库中尚不可用，则依赖项的许可证可能显示为 `unknown`。

依赖项许可证的查找在流水线完成时进行，因此如果当时该数据不可用，则会记录 `unknown` 许可证。此许可证会一直显示，直到后续执行流水线时进行另一次许可证查找。如果查找确认依赖项的许可证已更改，则此时会显示新的许可证。
