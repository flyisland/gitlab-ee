---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖项列表
description: 漏洞、许可证、过滤和导出。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 依赖项列表在极狐GitLab 16.2 为群组引入，通过功能标志 `group_level_dependencies`，默认禁用。
- 依赖项列表在极狐GitLab 16.4 为群组在 JihuLab.com 和私有化部署上启用。
- 依赖项列表在极狐GitLab 16.5 为群组 GA，功能标志 `group_level_dependencies` 已移除。

{{< /history >}}

使用依赖项列表可以审查项目或群组的依赖项及其关键详细信息，包括已知漏洞。该列表是项目中依赖项的集合，包括现有和新发现。这些信息有时称为软件物料清单（Software Bill of Materials，SBOM 或 BOM）。

<a id="set-up-the-dependency-list"></a>

## 设置依赖项列表

要列出项目的依赖项，请在项目的默认分支上运行[依赖项扫描](../dependency_scanning/_index.md) 或 [容器扫描](../container_scanning/_index.md)。

依赖项列表还会显示从最新默认分支流水线上传的任何 [CycloneDX 报告](../../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 中获取的依赖项。CycloneDX 报告必须符合 [CycloneDX 规范](https://github.com/CycloneDX/specification) 的 `1.4`、`1.5` 或 `1.6` 版本。你可以使用 [CycloneDX Web 工具](https://cyclonedx.github.io/cyclonedx-web-tool/validate) 来验证 CycloneDX 报告。

> [!note]
> 尽管这并非填充依赖项列表的强制要求，但 SBOM 文档必须包含并遵循 极狐GitLab CycloneDX 属性分类，以提供某些属性并启用一些安全功能。

<a id="view-project-dependencies"></a>

## 查看项目依赖项

{{< history >}}

- 在极狐GitLab 17.2 中，当启用功能标志 `skip_sbom_occurrences_update_on_pipeline_id_change` 时，`location` 字段不再链接到最后检测到依赖项的提交。该标志默认禁用。
- 在极狐GitLab 17.3 中，`location` 字段始终链接到首次检测到依赖项的提交。功能标志 `skip_sbom_occurrences_update_on_pipeline_id_change` 已移除。
- 查看依赖路径选项在极狐GitLab 17.11 引入，通过功能标志 `dependency_paths`，默认禁用。
- 查看依赖路径选项在极狐GitLab 18.2 GA，功能标志 `dependency_paths` 已移除。

{{< /history >}}

先决条件：

- 项目或群组的 开发者、维护者 或 所有者 角色。

要查看项目或群组中所有项目的依赖项：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **安全** > **依赖项列表**。
1. 可选。如果存在传递依赖，你还可以查看所有依赖路径：
   - 对于项目，在 **位置** 列中，选择 **查看依赖路径**。
   - 对于群组，在 **位置** 列中，先选择具体位置，然后选择 **查看依赖路径**。

每个依赖项的详细信息都会列出，并按漏洞严重性递减排序（如果有）。你可以改为按组件名称、包管理器或许可证排序。

| 字段 | 描述 |
|------|------|
| 组件 | 依赖项的名称和版本。 |
| 包管理器 | 用于安装依赖项的包管理器。不支持的包管理器显示为“unknown”。 |
| 位置 | 对于系统依赖项，此字段列出已扫描的镜像。对于应用程序依赖项，此字段显示一个链接，指向项目中声明该依赖项的特定于包管理器的锁定文件。还会显示直接的[依赖项](#dependency-paths)（如果有）。如果有传递依赖，选择 **查看依赖路径** 可以显示所有依赖项的完整路径。传递依赖是具有直接依赖作为祖先的间接依赖项。 |
| 许可证（仅限项目） | 链接到依赖项的软件许可证。一个警告徽章，显示在依赖项中检测到的漏洞数量。 |
| 项目（仅限群组） | 链接到具有该依赖项的项目。如果多个项目具有相同的依赖项，则会显示这些项目的总数。要转到具有此依赖项的项目，请选择 **项目** 编号，然后搜索并选择其名称。 |

<a id="filter-dependency-list"></a>

## 过滤依赖项列表

{{< history >}}

- 在极狐GitLab 16.7 中，为群组引入了依赖项过滤功能，通过功能标志 `group_level_dependencies_filtering`，默认禁用。
- 在极狐GitLab 16.10 中，群组依赖项过滤功能 GA，功能标志 `group_level_dependencies_filtering` 已移除。
- 在极狐GitLab 17.9 中，为项目引入了依赖项过滤功能，通过功能标志 `project_component_filter`，默认启用。
- 在极狐GitLab 17.10 中 GA，功能标志 `project_component_filter` 已移除。
- 依赖项版本过滤在极狐GitLab 18.0 中引入，适用于项目和群组，通过功能标志 `version_filtering_on_project_level_dependency_list` 和 `version_filtering_on_group_level_dependency_list`，默认禁用。
- 依赖项版本过滤在极狐GitLab 18.1 中于 JihuLab.com 和私有化部署上启用。
- 功能标志 `version_filtering_on_project_level_dependency_list` 和 `version_filtering_on_group_level_dependency_list` 已移除。

{{< /history >}}

你可以过滤依赖项列表，以便只关注一部分依赖项。依赖项列表可用于群组和项目。

对于群组，你可以按以下条件过滤：

- 项目
- 许可证
- 组件
- 组件版本

对于项目，你可以按以下条件过滤：

- 组件
- 组件版本

要按组件版本过滤，必须先按恰好一个组件过滤。

先决条件：

- 项目或群组的 开发者、维护者 或 所有者 角色。

过滤依赖项列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **安全** > **依赖项列表**。
1. 选择过滤栏。
1. 选择一个过滤器，然后从下拉列表中选择一个或多个条件。要关闭下拉列表，请选择其外部。要添加更多过滤器，请重复此步骤。
1. 要应用所选过滤器，按 <kbd>Enter</kbd>。

依赖项列表仅显示符合过滤条件的依赖项。

<a id="vulnerabilities"></a>

## 漏洞

{{< history >}}

- 在极狐GitLab 17.9 中引入，通过功能标志 `update_sbom_occurrences_vulnerabilities_on_cvs`，默认禁用。
- 在极狐GitLab 17.9 于 JihuLab.com 和私有化部署上启用。
- 一项更改，使依赖项列表仅显示 `detected` 和 `confirmed` 状态，于极狐GitLab 18.5 引入。

{{< /history >}}

> [!flag]
> 对与 [基于 SBOM 的依赖项扫描](../dependency_scanning/dependency_scanning_sbom/_index.md) 相关的漏洞的支持可用性由功能标志控制。
> 更多信息，请参见历史记录。

如果依赖项有已知漏洞，你可以通过选择依赖项名称旁边的箭头或指示已知漏洞数量的徽章来查看。对于每个漏洞，其严重程度和描述会显示在下方。要查看漏洞的更多详细信息，请选择漏洞的描述。将打开[漏洞详情](../vulnerabilities/_index.md)页面。依赖项列表仅显示处于 `detected` 和 `confirmed` 状态的漏洞。当漏洞状态发生变化时，这些更改不会反映在依赖项列表上，直到在默认分支上运行包含 SBOM 的新流水线。

<a id="dependency-paths"></a>

## 依赖路径

{{< history >}}

- 来自 CycloneDX SBOM 的依赖路径信息在极狐GitLab 16.9 中引入，通过功能标志 `project_level_sbom_occurrences`，默认禁用。
- 来自 CycloneDX SBOM 的依赖路径信息在极狐GitLab 17.0 中于 JihuLab.com 和私有化部署上启用。
- 来自 CycloneDX SBOM 的依赖路径信息在极狐GitLab 17.4 中 GA，功能标志 `project_level_sbom_occurrences` 已移除。

{{< /history >}}

依赖路径显示了列出组件的直接依赖项，条件是组件是传递性的并且属于受支持的包管理器。依赖路径仅针对存在漏洞的依赖项显示。

以下包管理器支持依赖路径：

- [Conan](https://conan.io)
- [NuGet](https://www.nuget.org/)
- [sbt](https://www.scala-sbt.org)
- [Yarn 1.x](https://classic.yarnpkg.com/lang/en/)

只有在使用 [`dependency-scanning`](https://gitlab.com/components/dependency-scanning/-/tree/main/templates/main) 组件时，以下包管理器才支持依赖路径：

- [Gradle](https://gradle.org/)
- [Maven](https://maven.apache.org/)
- [NPM](https://www.npmjs.com/)
- [Pipenv](https://pipenv.pypa.io/en/latest/)
- [pip-tools](https://pip-tools.readthedocs.io/en/latest/)
- [pnpm](https://pnpm.io/)
- [Poetry](https://python-poetry.org/)

<a id="licenses"></a>

### 许可证

如果配置了[依赖项扫描](../dependency_scanning/_index.md) CI/CD 作业，则此页面上会显示[发现的许可证](../../compliance/license_scanning_of_cyclonedx_files/_index.md)。

<a id="export"></a>

## 导出

你可以将依赖项列表导出为：

- JSON
- CSV
- CycloneDX 格式（仅限项目）

先决条件：

- 项目或群组的 开发者、维护者 或 所有者 角色。

导出依赖项列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **安全** > **依赖项列表**。
1. 选择 **导出**，然后选择文件格式。

依赖项列表将发送到你的电子邮件地址。要下载依赖项列表，请选择电子邮件中的链接。

<a id="troubleshooting"></a>

## 故障排除

在使用依赖项列表时，你可能会遇到以下问题。

<a id="license-appears-as-unknown"></a>

### 许可证显示为‘未知’

特定依赖项的许可证可能因几种可能的原因而显示为 `unknown`。本节描述了如何确定特定依赖项的许可证是否因已知原因显示为 `unknown`。

<a id="license-is-unknown-upstream"></a>

#### 许可证在上游为‘未知’

检查依赖项上游指定的许可证：

- 对于 C/C++ 包，检查 [Conancenter](https://conan.io/center)。
- 对于 npm 包，检查 [npmjs.com](https://www.npmjs.com/)。
- 对于 Python 包，检查 [PyPI](https://pypi.org/)。
- 对于 NuGet 包，检查 [NuGet](https://www.nuget.org/packages)。
- 对于 Go 包，检查 [pkg.go.dev](https://pkg.go.dev/)。

如果许可证在上游显示为 `unknown`，则极狐GitLab 将该依赖项的 **许可证** 显示为 `unknown` 也是预期的情况。

<a id="license-includes-spdx-license-expression"></a>

#### 许可证包含 SPDX 许可证表达式

不支持 [SPDX 许可证表达式](https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions/)。具有 SPDX 许可证表达式的依赖项的 **许可证** 显示为 `unknown`。SPDX 许可证表达式的一个示例是 `(MIT OR CC0-1.0)`。

<a id="package-version-not-in-package-metadata-db"></a>

#### 包版本不在包元数据数据库中

特定版本的依赖包必须存在于[包元数据数据库](../../../topics/offline/quick_start_guide.md#enabling-the-package-metadata-database)中。如果不存在，则该依赖项的 **许可证** 将显示为 `unknown`。

<a id="package-name-contains-special-characters"></a>

#### 包名称包含特殊字符

如果依赖包名称包含连字符 (`-`)，则 **许可证** 可能显示为 `unknown`。当手动将包添加到 `requirements.txt` 或使用 `pip-compile` 时，可能会发生这种情况。这是因为极狐GitLab 在摄取依赖项信息时不会根据 [PEP 503 中规范化名称](https://peps.python.org/pep-0503/#normalized-names) 的指导规范化 Python 包名称。