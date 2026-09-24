---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 静态可达性分析
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 有限可用性

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.5 中作为实验引入。
- 在极狐GitLab 17.11 中从实验更改为测试版。
- 在极狐GitLab 18.2 和依赖项扫描分析器 v0.32.0 中引入了对 JavaScript 和 TypeScript 的支持。
- 在极狐GitLab 18.5 和依赖项扫描分析器 v0.39.0 中引入了对 Java 的支持。
- 在极狐GitLab 18.5 中从测试版更改为有限可用性（LA）。
- Java 支持在极狐GitLab 18.8 中从实验更改为测试版。

{{< /history >}}

依赖项扫描会识别您项目中所有存在漏洞的依赖项。然而，并非所有漏洞的风险等级都相同。静态可达性分析通过确定哪些存在漏洞的软件包是可访问的（即被您的应用程序导入），帮助您确定修复的优先级。通过聚焦于可访问的漏洞，静态可达性分析使您能够基于实际的威胁暴露情况，而非理论风险来安排修复优先级。

静态可达性分析通过分析您项目的源代码，来确定 SBOM 中的哪些依赖项是可访问的。依赖项扫描会生成一个 SBOM 报告，标识出所有组件及其传递依赖项。然后，静态可达性分析会检查 SBOM 中的每个依赖项，并添加一个可达性值，用实际使用数据来丰富报告。该丰富后的 SBOM 随后被极狐GitLab 获取，以补充漏洞发现信息。

只有当 SBOM 文件和源代码文件属于同一个项目目录树时，SBOM 才会被丰富。当存在多个嵌套项目时，系统会选择最接近（最深）的项目路径来确定丰富范围。静态可达性分析依赖于[元数据](https://gitlab.com/gitlab-org/security-products/static-reachability-metadata/-/tree/v1?ref_type=heads)，这些元数据将 SBOM 中的 Python 和 Java 软件包名称映射到其相应的代码导入路径。此元数据每周更新一次。

> [!warning]
> 静态可达性分析已可投入生产。然而，其可用性有限，因为它依赖于[通过 SBOM 进行依赖项扫描](dependency_scanning_sbom/_index.md)，后者具有相同的状态。

<a id="turn-on-static-reachability-analysis"></a>

## 启用静态可达性分析

先决条件：

- 项目需具有开发者、维护者或所有者角色。
- 项目需使用[支持的语言和软件包管理器](#supported-languages-and-package-managers)。
- 依赖项扫描分析器版本 v0.39.0 或更高版本（更早的版本可能支持特定语言 - 请参阅上方的 `历史记录`）。
- 为项目开启[通过 SBOM 进行依赖项扫描](dependency_scanning_sbom/_index.md#turn-on-dependency-scanning)。不支持 [Gemnasium](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium) 分析器。
- 特定语言的先决条件：
  - Python：
    - 依赖图文件必须作为 `build` 阶段的 Job 产物提供。请参阅 [pip](dependency_scanning_sbom/_index.md#pip) 或 [pipenv](dependency_scanning_sbom/_index.md#pipenv) 的说明。对于其他支持的 Python 软件包管理器，请参阅[依赖项扫描分析器文档](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning#supported-files)。
  - JavaScript 和 TypeScript：
    - 仓库必须包含依赖项扫描分析器[支持](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning#supported-files)的锁文件。
  - Java：
    - 依赖图文件必须作为 `build` 阶段的 Job 产物提供。请参阅 [Maven](dependency_scanning_sbom/_index.md#maven) 或 [Gradle](dependency_scanning_sbom/_index.md#gradle) 的说明。

> [!warning]
> 静态可达性分析会增加 Job 的运行时间。

要在您的项目中开启静态可达性分析：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**代码** > **代码仓**。
1. 选择 `.gitlab-ci.yml` 文件。
1. 选择**编辑** > **编辑单个文件**。
1. 添加以下配置：

   ```yaml
   include:
   - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml

   variables:
     DS_STATIC_REACHABILITY_ENABLED: true
   ```

1. 选择**提交更改**。

当依赖项扫描运行并输出 SBOM 时，其结果将由静态可达性分析进行补充。

<a id="reachability-values"></a>

## 可达性值

一个依赖项可能具有以下可达性值之一。请优先分类和修复标记为**是**的依赖项，因为这些依赖项已被确认在代码中使用。

是
: 关联此漏洞的软件包已在代码中被确认可访问。当一个直接依赖项被标记为可访问时，其传递依赖项也将被标记为可访问。

未找到
: 静态可达性分析已成功运行，但未检测到存在漏洞的软件包的使用情况。

不可用
: 静态可达性分析未执行，因此不存在可达性数据。

要查找存在漏洞的依赖项的可达性值：

- 在漏洞报告中，将鼠标悬停在**严重性**值上。
- 在漏洞详情页面，检查**可访问**值。
- 使用 GraphQL 查询列出可访问的漏洞。

<a id="not-found-results"></a>

### “未找到”结果

**未找到**的可达性值并不能保证该依赖项未被使用，因为静态可达性分析并非总能确切地确定软件包的使用情况。

在以下情况下，依赖项会被标记为未找到：

- 它们出现在锁文件中，但并未在代码中导入。
- 它们位于被排除的目录中（例如，通过 `DS_EXCLUDED_PATHS` 配置）。
- 它们是仅供本地使用的工具，例如代码覆盖率测试或代码检查包。

考虑以下被排除目录的示例。您定义了 CI/CD 变量 `DS_EXCLUDED_PATHS="test"`。项目的仓库结构如下所示。

```plaintext
.
├── pipdeptree.json  // 包含 "requests" 依赖项
└── test/
    └── app.py       // 导入 "requests" 依赖项
```

在此示例中，图文件 `pipdeptree.json` 位于被排除的目录之外，并被分析以识别文件中列出的依赖项。然而，导入 `requests` 依赖项的源代码位于被排除的目录中，因此静态可达性分析不会检查其可达性。结果是，`requests` 依赖项被标记为**未找到**。换句话说，当锁文件在被排除目录之外，但导入该依赖项的代码在目录之内时，就会发生这种情况。

<a id="supported-languages-and-package-managers"></a>

## 支持的语言和软件包管理器

支持情况因语言成熟度而异，并包含每种语言的特定软件包管理器和文件类型。

| 语言                          | 成熟度 | 支持的软件包管理器                  | 支持的文件类型 |
|-----------------------------------|----------|---------------------------------------------|----------------------|
| Python<sup>1</sup>                | 测试版     | `pip`、`pipenv`<sup>2</sup>、`poetry`、`uv` | `.py`                |
| JavaScript/TypeScript<sup>3</sup> | 测试版     | `npm`、`pnpm`、`yarn`                       | `.js`、`.ts`         |
| Java<sup>4</sup>                  | 测试版     | `maven`<sup>5</sup>、`gradle`<sup>6</sup>   | `.java`              |

**脚注**：

1. 当使用 `pipdeptree` 进行依赖项扫描时，[可选依赖项](https://setuptools.pypa.io/en/latest/userguide/dependency_management.html#optional-dependencies)会被标记为直接依赖项，而非传递依赖项。静态可达性分析可能无法将这些软件包识别为正在使用中。例如，要求使用 `passlib[bcrypt]` 可能导致 `passlib` 被标记为 `in_use`，而 `bcrypt` 则被标记为 `not_found`。有关更多详情，请参阅 [pip](dependency_scanning_sbom/_index.md#pip)。
1. 对于 Python `pipenv`，静态可达性分析不支持 `Pipfile.lock` 文件。仅支持 `pipenv.graph.json`，因为它支持依赖图。
1. 不支持前端框架。
1. Java 的动态特性会导致以下问题，这可能导致使用现代框架的项目误报率更高：
   - 静态可达性分析通过直接导入、Java 反射模式以及源代码中的 Java Database Connectivity 连接字符串来检测显式使用情况。它无法识别在运行时动态加载的依赖项，例如那些使用像 Spring Boot 这样的依赖注入框架的依赖项。
   - 覆盖范围仅限于极狐GitLab 漏洞数据库中的软件包以及 Maven Central 中最广泛依赖的软件包。
1. 按照 [Maven](dependency_scanning_sbom/_index.md#maven) 说明中的描述使用 `maven.graph.json` 文件。
1. 按照 [Gradle](dependency_scanning_sbom/_index.md#gradle) 说明中的描述使用依赖锁文件。

<a id="offline-environment"></a>

## 离线环境

要在[离线环境](../offline_deployments/_index.md)中运行静态可达性分析，您必须进行初始设置并执行持续维护。

初始设置：

- 完成[依赖项扫描（SBOM）](dependency_scanning_sbom/_index.md#offline-environment)的离线环境要求。

持续维护：

- 每当有新的依赖项扫描（SBOM）镜像版本发布时，更新本地的镜像。

对于 Python 和 Java 软件包，静态可达性分析使用元数据将 SBOM 中的软件包名称映射到其相应的代码导入路径。此元数据包含在依赖项扫描分析器的镜像中。过时的元数据可能导致不完整或不准确的可达性分析。

{{< alert type="flag" >}}

该功能的可用性由一个功能标志控制。更多信息，请参见历史记录。

{{< /alert >}}