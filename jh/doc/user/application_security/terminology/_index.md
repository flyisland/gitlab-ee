---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全术语表
description: 极狐GitLab 中安全功能相关术语的定义。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本术语表提供了极狐GitLab 中安全功能相关术语的定义。虽然某些术语在其他语境中可能有不同含义，但这些定义是极狐GitLab 特有的。

<a id="analyzer"></a>

## 分析器

分析[扫描目标类型](#scan-target-type)以发现安全漏洞的软件。在内部，它负责收集所需的配置参数，并执行必要的数据转换，将目标转换为[扫描器](#scanner)执行扫描操作所需的标准格式。最后，它以调用方要求的格式生成报告。

基于 CI/CD 的分析器通过 CI/CD 作业集成到极狐GitLab。基于 CI/CD 的分析器生成的报告在作业完成后作为产物发布。极狐GitLab 摄取此报告，使用户能够可视化和管理已发现的漏洞。生成的报告遵循[安全报告格式](#secure-report-format)。

许多极狐GitLab 分析器采用标准方法，使用 Docker 运行包装的扫描器。例如，镜像 `semgrep` 是一个分析器，它包装了扫描器 `Semgrep`。但是，某些分析器直接在 GitLab Rails 或其他目标环境中运行，而不是在单独的容器中运行。

<a id="attack-surface"></a>

## 攻击面

应用程序中易受攻击的不同位置。安全产品在扫描期间发现并搜索攻击面。每个产品对攻击面的定义不同。例如，SAST 使用文件和行号，而 DAST 使用 URL。

<a id="component"></a>

## 组件

构成软件项目一部分的软件组件。示例包括库、驱动程序、数据和[更多](https://cyclonedx.org/docs/1.5/json/#components_items_type)。

<a id="corpus"></a>

## 语料库

在模糊测试器运行期间生成的一组有意义的测试用例。每个有意义的测试用例都会在被测程序中产生新的覆盖率。您应该重用语料库，并将其传递给后续运行。

<a id="cna"></a>

## CNA

[CVE](#cve) 编号授权机构（CNA）是来自世界各地的组织，经 [Mitre 公司](https://cve.mitre.org/) 授权，在其各自范围内为产品或服务中的漏洞分配 [CVE](#cve) 编号。[GitLab 是 CNA](https://about.gitlab.com/security/cve/)。

<a id="cve"></a>

## CVE

通用漏洞披露（CVE®）是公开已知网络安全漏洞的通用标识符列表。该列表由 [Mitre 公司](https://cve.mitre.org/) 管理。

<a id="cvss"></a>

## CVSS

通用漏洞评分系统（CVSS）是评估计算机系统安全漏洞严重性的免费开放行业标准。

<a id="cwe"></a>

## CWE

通用弱点枚举（CWE™）是一个由社区开发的常见软件和硬件弱点类型列表，这些弱点具有安全影响。弱点是软件或硬件实现、代码、设计或架构中的缺陷、故障、错误、漏洞或其他错误。如果未解决，弱点可能导致系统、网络或硬件易受攻击。CWE 列表及相关的分类法提供了一种语言，您可以使用它来识别和描述这些弱点（以 CWE 的形式）。

<a id="deduplication"></a>

## 去重

当某个类别的流程判定发现项相同，或相似到需要减少噪音时，只保留一个发现项，其余的被消除。阅读更多关于[去重流程](../detect/vulnerability_deduplication.md)的信息。

<a id="dependency-graph-export"></a>

## 依赖关系图导出

依赖关系图导出列出了项目使用的直接和间接依赖项及其之间的关系。它由包管理器命令（例如，`go mod graph` 或 `mvn dependency:tree`）生成，并输出为文件。

相关术语：[锁文件](#lockfile)。

<a id="dependency-version-conflict"></a>

## 依赖版本冲突

当依赖版本约束无法满足时，就会发生依赖版本冲突。

考虑以下情况：

- 依赖项 X 要求 `packageA` 的版本恰好为 1.0.0
- 依赖项 Y 要求 `packageA` 的版本为 1.0.1 或更高

在此示例中，没有版本的 `packageA` 能同时满足这两个约束，从而导致依赖版本冲突。

<a id="dependency-version-incompatibility"></a>

## 依赖版本不兼容

当软件包的版本不满足版本约束时，就会发生依赖版本不兼容。

考虑以下情况：

- `packageA` 有版本 `1.0.0` 和 `1.0.1`
- 依赖项 X 要求 `packageA` 的版本为 1.0.1 或更高

在此示例中，`packageA` 版本 `1.0.0` 不满足版本约束，因此不兼容。但是，`packageA` 版本 `1.0.1` 满足该约束。

<a id="duplicate-finding"></a>

## 重复发现项

被多次报告的合法发现项。当不同的扫描器发现相同的发现项，或单次扫描无意中多次报告同一发现项时，可能会发生这种情况。

<a id="false-positive"></a>

## 误报

不存在但被错误报告为存在的发现项。

<a id="finding"></a>

## 发现项

由分析器在项目中识别出的、可能易受攻击的资产。资产包括但不限于源代码、二进制包、容器、依赖项、网络、应用程序和基础设施。

发现项是扫描器在合并请求/功能分支中识别的所有潜在漏洞项。只有在合并到默认分支后，发现项才会成为[漏洞](#vulnerability)。

您可以通过两种方式与漏洞发现项交互。

1. 您可以为漏洞发现项创建议题或合并请求。
1. 您可以忽略漏洞发现项。忽略发现项会将其从默认视图中隐藏。

<a id="grouping"></a>

## 分组

当存在多个可能相关但不符合去重条件的发现项时，一种灵活且非破坏性的方式，以组的形式直观地组织漏洞。例如，您可以包括应一起评估、可通过相同操作修复或来自相同来源的发现项。

<a id="identifier"></a>

## 标识符

标识符是来自外部数据库（如通用漏洞披露（CVE）或通用弱点枚举（CWE））的漏洞 ID。一个漏洞可能有多个标识符。标识符由类型（如 `CVE`）和 ID（如 `CVE-2021-44228`）组成。

<a id="insignificant-finding"></a>

## 无关紧要的发现项

特定客户不关心的合法发现项。

<a id="known-affected-component"></a>

## 已知受影响组件

满足漏洞可利用要求的组件。例如，`packageA@1.0.3` 匹配 `FAKECVE-2023-0001` 的名称、包类型以及一个受影响版本或版本范围。

<a id="location-fingerprint"></a>

## 位置指纹

发现项的位置指纹是一个文本值，对于攻击面上的每个位置都是唯一的。每个安全产品根据其攻击面类型定义此值。例如，SAST 包含文件路径和行号。

<a id="lockfile"></a>

## 锁文件

列出应用程序的直接和间接依赖项及其版本号的文件。其目的是可重现性，确保任何安装应用程序依赖项的人都能获得完全相同的版本。某些锁文件（如 `Gemfile.lock`）还包含依赖关系信息，但这不是必需的。

相关术语：[依赖关系图导出](#dependency-graph-export)。

<a id="package-managers-and-package-types"></a>

## 包管理器和包类型

<a id="package-managers"></a>

### 包管理器

包管理器是管理项目依赖项的系统。

包管理器提供安装新依赖项（也称为“包”）的方法，管理包在文件系统上的存储位置，并提供发布您自己的包的功能。

<a id="package-types"></a>

### 包类型

每个包管理器、平台、类型或生态系统都有其自己的约定和协议来识别、定位和预配软件包。

下表列出了极狐GitLab 文档和软件工具中引用的一些包管理器和类型，但并非详尽无遗。

<style>
table.package-managers-and-types tr:nth-child(even) {
    background-color: transparent;
}

table.package-managers-and-types td {
    border-left: 1px solid #dbdbdb;
    border-right: 1px solid #dbdbdb;
    border-bottom: 1px solid #dbdbdb;
}

table.package-managers-and-types tr td:first-child {
    border-left: 0;
}

table.package-managers-and-types tr td:last-child {
    border-right: 0;
}

table.package-managers-and-types ul {
    font-size: 1em;
    list-style-type: none;
    padding-left: 0px;
    margin-bottom: 0px;
}
</style>

<table class="package-managers-and-types">
  <thead>
    <tr>
      <th>包类型</th>
      <th>包管理器</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>gem</td>
      <td><a href="https://bundler.io/">Bundler</a></td>
    </tr>
    <tr>
      <td>Packagist</td>
      <td><a href="https://getcomposer.org/">Composer</a></td>
    </tr>
    <tr>
      <td>Conan</td>
      <td><a href="https://conan.io/">Conan</a></td>
    </tr>
    <tr>
      <td>go</td>
      <td><a href="https://go.dev/blog/using-go-modules">go</a></td>
    </tr>
    <tr>
      <td rowspan="3">maven</td>
      <td><a href="https://gradle.org/">Gradle</a></td>
    </tr>
    <tr>
      <td><a href="https://maven.apache.org/">Maven</a></td>
    </tr>
    <tr>
      <td><a href="https://www.scala-sbt.org">sbt</a></td>
    </tr>
    <tr>
      <td rowspan="2">npm</td>
      <td><a href="https://www.npmjs.com">npm</a></td>
    </tr>
    <tr>
      <td><a href="https://classic.yarnpkg.com/en">yarn</a></td>
    </tr>
    <tr>
      <td>NuGet</td>
      <td><a href="https://www.nuget.org/">NuGet</a></td>
    </tr>
    <tr>
      <td rowspan="4">PyPI</td>
      <td><a href="https://setuptools.pypa.io/en/latest/">Setuptools</a></td>
    </tr>
    <tr>
      <td><a href="https://pip.pypa.io/en/stable/">pip</a></td>
    </tr>
    <tr>
      <td><a href="https://pipenv.pypa.io/en/latest/">Pipenv</a></td>
    </tr>
    <tr>
      <td><a href="https://python-poetry.org/">Poetry</a></td>
    </tr>
  </tbody>
</table>

<a id="pipeline-security-tab"></a>

## 流水线安全选项卡

显示在关联 CI 流水线中发现的发现项的页面。

<a id="possibly-affected-component"></a>

## 可能受影响组件

可能受漏洞影响的软件组件。例如，在扫描项目以查找已知漏洞时，首先评估组件是否匹配名称和[包类型](https://github.com/package-url/purl-spec/blob/main/PURL-TYPES.rst)。在此阶段，它们可能受漏洞影响，只有在确认它们属于受影响的版本范围后，才[已知受影响](#known-affected-component)。

<a id="post-filter"></a>

## 后过滤器

后过滤器有助于减少扫描器结果中的噪音并自动化手动任务。您可以指定基于扫描器结果更新或修改漏洞数据的标准。例如，您可以将发现项标记为可能的误报，并自动解决不再检测到的漏洞。这些不是永久性操作，可以更改。

自动解决发现项的支持在[史诗 7478](https://gitlab.com/groups/gitlab-org/-/epics/7478) 中跟踪，廉价扫描的支持在[史诗 7886](https://gitlab.com/groups/gitlab-org/-/epics/7886) 中提出。

<a id="pre-filter"></a>

## 预过滤器

在分析发生之前用于过滤目标的不可逆操作。这通常是为了让用户减少范围和噪音并加快分析速度。如果需要记录，则不应执行此操作，因为极狐GitLab 不存储与跳过/排除的代码或资产相关的任何内容。

示例：`DS_EXCLUDED_PATHS` 应 `Exclude files and directories from the scan based on the paths provided.`

<a id="primary-identifier"></a>

## 主要标识符

第一个[标识符](#identifier)是主要标识符。主要标识符必须稳定。后续扫描必须为同一发现项返回相同的值，即使漏洞的位置已更改。

<a id="processor"></a>

## 处理器

接受输入并根据指定标准进行转换的软件，通过修改输入数据或附加额外的元数据作为输出来实现。处理器用于支持扫描器操作，常用于扫描前和扫描后阶段。与[过滤器](#pre-filter)不同，处理器不具备基于业务逻辑控制工作流继续或终止的决策能力。相反，它们执行转换并无条件地将结果传递下去。

<a id="pre-processor"></a>

### 预处理器

预处理器通常执行数据准备任务，例如规范化输入格式、为扫描目标丰富附加上下文、应用特定于目标的转换或增强配置参数。它们确保扫描器接收到格式正确且增强的输入，以优化扫描操作。

<a id="post-processor"></a>

### 后处理器

后处理器在[扫描器](#scanner)完成操作后对扫描结果应用智能分析。后处理器通过漏洞分类、误报过滤、严重性调整和上下文丰富等操作增强原始扫描器输出。扫描器结果可以依次通过多个后处理器，然后将处理后的结果返回给[分析器](#analyzer)。

<a id="reachability"></a>

## 可达性

可达性指示项目中列为依赖项的[组件](#component)是否实际在代码库中使用。

<a id="report-finding"></a>

## 报告发现项

仅存在于分析器生成的报告中、尚未持久化到数据库的[发现项](#finding)。报告发现项在导入数据库后成为[漏洞发现项](#vulnerability-finding)。

<a id="scan-type-report-type"></a>

## 扫描类型（报告类型）

描述扫描的类型。必须是以下之一：

- `api_fuzzing`
- `container_scanning`
- `coverage_fuzzing`
- `dast`
- `dependency_scanning`
- `sast`
- `secret_detection`

此列表会随着扫描器的添加而变化。

<a id="scan-target-type"></a>

## 扫描目标类型

作为运行扫描范围边界的内容或产物的离散单元。每种扫描目标类型代表一个具有定义扫描约束的独立实体。扫描目标类型的特定实例（例如特定的 Git 代码仓库或容器镜像）称为“扫描目标”。扫描目标类型的示例包括 Git 代码仓库、文件系统、容器等。

<a id="scanner"></a>

## 扫描器

在扫描目标（[扫描目标类型](#scan-target-type)的实例）中扫描安全漏洞的软件。它通常是一个无状态组件，从分析器接收必要的扫描配置参数和扫描负载。生成的扫描报告不一定是[安全报告格式](#secure-report-format)。扫描器可以是一个复杂的组件，用额外的处理器包装一个或多个扫描引擎（例如，密钥检测扫描器），也可以简单到只是一个独立的扫描引擎（例如，Trivy）。

<a id="secure-product"></a>

## 安全产品

与极狐GitLab 提供一流支持的特定应用安全领域相关的一组功能。

产品包括容器扫描、依赖扫描、动态应用安全测试（DAST）、密钥检测、静态应用安全测试（SAST）和模糊测试。

这些产品中的每一个通常都包含一个或多个分析器。

<a id="secure-report-format"></a>

## 安全报告格式

安全产品在创建 JSON 报告时遵循的标准报告格式。该格式由 [JSON schema](https://gitlab.com/gitlab-org/security-products/security-report-schemas) 描述。

<a id="security-dashboard"></a>

## 安全仪表板

提供项目、群组或极狐GitLab 实例所有漏洞的概览。漏洞仅从项目默认分支上发现的发现项创建。

<a id="seed-corpus"></a>

## 种子语料库

作为模糊测试目标初始输入的一组测试用例。这通常会大大加快模糊测试目标的速度。这些测试用例可以是手动创建的，也可以使用模糊测试目标根据之前的运行自动生成。

<a id="vendor"></a>

## 供应商

维护分析器的一方。因此，供应商负责将扫描器集成到极狐GitLab，并使其在演进过程中保持兼容。供应商不一定是扫描器的作者或维护者，例如使用开放核心或 OSS 项目作为产品基础解决方案的情况。对于作为极狐GitLab 发行版或极狐GitLab 订阅一部分包含的扫描器，供应商列为极狐GitLab。

<a id="vulnerability"></a>

## 漏洞

对其环境安全产生负面影响的缺陷。漏洞描述错误或弱点，而不描述错误所在的位置（请参阅[发现项](#finding)）。

每个漏洞对应一个唯一的发现项。

漏洞存在于默认分支中。发现项（请参阅[发现项](#finding)）是扫描器在合并请求/功能分支中识别的所有潜在漏洞项。只有在合并到默认分支后，发现项才会成为漏洞。

<a id="vulnerability-finding"></a>

## 漏洞发现项

当[报告发现项](#report-finding)存储到数据库时，它就成为漏洞[发现项](#finding)。

<a id="vulnerability-tracking"></a>

## 漏洞跟踪

负责跨扫描匹配发现项，以便理解发现项的生命周期。工程师和安全团队使用此信息来决定是否合并代码更改，并查看未解决的发现项及其引入时间。

通过比较位置指纹、主要标识符和报告类型来跟踪漏洞。

<a id="vulnerability-occurrence"></a>

## 漏洞发生

已弃用，请参阅[发现项](#finding)。
