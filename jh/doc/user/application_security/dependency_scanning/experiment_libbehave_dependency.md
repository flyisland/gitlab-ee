---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 分析依赖项的行为
description: Libbehave 会扫描合并请求中新增的依赖项是否存在有风险的行为，并为每个行为分配风险评分。结果会显示在作业输出、合并请求评论和作业产物中。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

Libbehave 是一项实验性功能，它会在合并请求流水线期间扫描您的依赖项，以识别新增的库及其可能存在的风险行为。传统的依赖项扫描会查找已知漏洞，而 Libbehave 则让您了解依赖项所展现的功能和行为。

Libbehave 检测到的每项功能都会被赋予一个“风险”评分，评分等级如下：

- 信息性：无风险，但可能有助于对依赖项的功能进行编目（例如使用
  JSON）。
- 低：风险较小，可提示依赖项正在执行安全敏感操作，例如使用
  加密。
- 中：中等风险，可能用于与文件系统交互或读取环境
  变量，其中可能存储或访问敏感数据。
- 高：最高风险，这些行为在安全漏洞中常被滥用，例如执行操作系统命令或动态求值代码。

Libbehave 检测到的功能包括：

- 执行操作系统命令
- 执行动态代码（eval）
- 读取/写入文件
- 打开网络套接字
- 读取/展开归档文件（ZIP/tar/Gzip）
- 通过使用 HTTP 客户端、Redis、Elastic Cache、关系管理数据库（RMDB）服务器、SSH 和 Git 与外部服务交互
- 以各种格式序列化数据：XML、YAML、MessagePack、Protocol Buffers、JSON 以及
  特定语言的格式
- 模板化
- 常用框架
- 文件上传/下载

如需查看针对每种受支持包管理器类型的 Libbehave 演示，请参阅
[我们的 Libbehave 演示项目](https://gitlab.com/gitlab-org/security-products/demos/experiments/libbehave)。

<a id="supported-languages-and-package-managers"></a>

## 支持的语言和包管理器

Libbehave 支持以下语言和包管理器：

- C#（[NuGet](https://www.nuget.org/)）
  - 读取 `Directory.Build.props` 文件（如果找到属性值则替换）
  - 读取 `*.deps.json` 文件
  - 读取 `**/*.dll` 和 `**/*.exe` 文件
- Go
  - 读取 `go.mod` 文件
- Java（[Maven](https://maven.org)）
  - 读取 `pom.xml` 文件（如果找到属性值则替换）
  - 读取 `**/gradle.lockfile*` 文件
- JavaScript/TypeScript（[npmjs](https://npmjs.com)）
  - 读取 `**/package-lock.json` 文件
  - 读取 `**/yarn.lock` 文件
  - 读取 `**/pnpm-lock.yaml` 文件
- Python（[pypi](https://pypi.org)）
  - 读取 `**/*requirements*.txt` 文件
  - 读取 `**/poetry.lock` 文件
  - 读取 `**/Pipfile.lock` 文件
  - 读取 `**/setup.py` 文件
  - 读取 egg 或 wheel 安装目录中的软件包：
    - 读取 `**/*dist-info/METADATA`、`**/*egg-info/PKG-INFO`、`**/*DIST-INFO/METADATA` 和
      `**/*EGG-INFO/PKG-INFO` 文件
- PHP（[Composer/Packagist](https://packagist.org/)）
  - 读取 `**/installed.json` 文件
  - 读取 `**/composer.lock` 文件
  - 读取 `**/php/.registry/.channel.*/*.reg` 文件
- Ruby（[RubyGems](https://rubygems.org)）
  - 读取 `**/Gemfile.lock` 文件
  - 读取 `**/specifications/**/*.gemspec` 文件
  - 读取 `**/*.gemspec` 文件

仅当上述文件在源分支中被修改时，才会分析这些文件以查找新增依赖项。

<a id="enable-libbehave"></a>

## 启用 Libbehave

先决条件：

- 项目的开发者、维护者或所有者角色。
- 流水线属于一个活跃的[合并请求流水线](../../../ci/pipelines/merge_request_pipelines.md)，且该流水线已定义源 Git 分支和目标 Git 分支。
- 项目包含[受支持的语言](#supported-languages-and-package-managers)之一。
- 项目正在向源分支或功能分支添加新增依赖项。

要启用 Libbehave：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 选择 `.gitlab-ci.yml` 文件。
1. 选择**编辑** > **编辑单个文件**。
1. 添加 Libbehave [CI/CD 组件](../../../ci/components/_index.md)：

   ```yaml
   include:
     - component: $CI_SERVER_FQDN/security-products/experiments/libbehave/libbehave@v0.1.0
       inputs:
         stage: test
   ```

1. 选择**提交更改**。

此配置会在测试阶段创建一个名为 `libbehave-experiment`的新作业。

<a id="configure-merge-request-comments"></a>

### 配置合并请求评论

要为 Libbehave 配置合并请求评论，请配置项目访问令牌。

先决条件：

- 项目的维护者或所有者角色。
- 已为项目启用 Libbehave。

要配置合并请求评论：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **访问令牌**。
1. 选择**添加新令牌**并填写字段：
   - **令牌名称**：输入一个名称，例如 `libbehave-bot`。
   - **角色**：选择**访客**。
   - **选择作用域**：选中 **API** 复选框。
1. 选择[**创建项目访问令牌**](../../project/settings/project_access_tokens.md)。

   将项目访问令牌复制到剪贴板。下一步需要用到它。
1. 选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**并填写字段：
   - **键**：输入 `BEHAVE_TOKEN`。
   - **值**：粘贴项目访问令牌。
   - **可见性**：选择**掩码**。
   - **标志**：清除**保护变量**复选框。
1. 选择**添加变量**。

CI/CD 组件会自动使用 `BEHAVE_TOKEN`，因此您无需在组件输入中指定它。

> [!note]
> 仅当源分支是受保护分支，或者为 `BEHAVE_TOKEN` 变量清除了**保护变量**选项时，才会显示合并请求评论。

<a id="available-cicd-inputs-and-variables"></a>

### 可用的 CI/CD 输入和变量

您可以使用 CI/CD 变量来自定义 Libbehave 的 [CI 组件](https://gitlab.com/security-products/experiments/libbehave)。

以下变量用于配置 Libbehave 的运行方式。

| CI/CD 变量                        | CLI 参数 | 默认值 | 描述                                                            |
|---------------------------------------|--------------|---------|------------------------------------------------------------------------|
| `CI_MERGE_REQUEST_SOURCE_BRANCH_NAME` | `-source`    | `""`    | 用于对比差异的源分支（例如 feature-branch）            |
| `CI_MERGE_REQUEST_TARGET_BRANCH_NAME` | `-target`    | `""`    | 用于对比差异的目标分支（例如 main）                      |
| `BEHAVE_TIMEOUT`                      | `-timeout`   | `"30m"` | 允许分析和下载软件包的最长时间（示例：30m）   |
| `BEHAVE_TOKEN`                        | `-token`     | `""`    | 可选。访问令牌（创建合并请求评论所必需）    |
| `CI_PROJECT_ID`                       | `-project`   | `""`    | 可选。用于创建包含结果的合并请求评论的项目 ID       |
| `CI_MERGE_REQUEST_IID`                | `-mrid`      | `""`    | 可选。用于创建包含结果的合并请求评论的合并请求 ID |

以下标志可用，但未经测试，应保留其默认值：

| CI/CD 变量         | CLI 参数     | 默认值       | 描述                 |
|------------------------|------------------|---------------|-----------------------------|
| `BEHAVE_RULE_PATHS`    | `-rules`         | `"/dist"`     | 规则文件的路径。 |
| `BEHAVE_TARGET_DIR`    | `-dir`           | `""`          | 要对其运行 behave 的目标目录。 |
| `BEHAVE_NO_GIT_IGNORE` | `-no-git-ignore` | `true`        | 是否扫描 `.gitignore`中的文件。提供该参数将不扫描它们。默认情况下会扫描。 |
| `BEHAVE_OUTPUT_PATH`   | `-output`        | `"behaveout"` | 用于存储扫描结果、提取的产物和报告结果的路径。 |
| `BEHAVE_INCLUDE_LANG`  | `-include-lang`  | `""`          | 包含一种语言，可选值：`csharp`、`go`、`java`、`js`、`php`、`python` 或 `ruby`，以 ',' 分隔，会排除所有未指定的其他语言。 |
| `BEHAVE_EXCLUDE_LANG`  | `-exclude-lang`  | `""`          | 排除一种语言，可选值：`csharp`、`go`、`java`、`js`、`php`、`python` 或 `ruby`，以 ',' 分隔，会包含所有未指定的其他语言。 |
| `BEHAVE_EXCLUDE_FILES` | `-exclude-`      | `""`          | 通过正则表达式排除文件或路径，各个正则表达式以 ',' 分隔。 |

由于所有变量都尚未经过测试，您可能会发现有些可用，有些不可用。如果您需要某个不可用的变量，
[提交功能请求](https://gitlab.com/gitlab-org/gitlab/-/work_items/new?description_template=Feature%20proposal%20-%20detailed&issue[title]=Docs%20feedback%20-%20feature%20proposal:%20Write%20your%20title)
或为代码做出贡献以使其可用。

<a id="dependency-detection-and-analysis"></a>

## 依赖项检测和分析

Libbehave 会分析并报告任何新增依赖项的发现结果，它旨在[合并请求流水线](../../../ci/pipelines/merge_request_pipelines.md)中运行。这意味着如果您的合并请求不包含任何新增依赖项，那么 Libbehave 会返回零结果。

检测的工作方式因所使用的语言和包管理器而异。默认情况下，这些受支持的包管理器会解析其包管理器相关文件，以识别正在添加哪些依赖项。收集这些信息后，会调用相应的包管理器 API 来下载所识别软件包的产物。

下载完成后，会使用基于 Semgrep 的静态分析方法，并配合一组配置好的检查，对依赖项进行提取和分析。

对于 Java 和 C#，在运行静态分析之前，还会额外执行一步来反编译二进制产物。

<a id="known-issues"></a>

### 已知问题

每种语言都有其各自的已知问题。

所有包文件（例如 `Gemfile.lock` 和 `requirements.txt`）都必须提供明确的版本。不支持版本范围。

<a id="c"></a>

#### C\#

- `.props` 或 `.csproj` 文件中的属性或变量替换不会考虑嵌套的项目文件。
  它会替换任何与全局提取变量集及其值匹配的变量。
- 会反编译下载的依赖项，因此源代码到行号的转换可能并非 1:1。
- Libbehave 会反编译 NuGet 包中存在的所有 .NET 版本。未来可能会对此进行优化。
  - 例如，某些依赖项会在单个归档中打包多个针对不同框架版本的 DLL
    （示例：net20/Some.dll、net45/Some.dll）。

<a id="java"></a>

#### Java

- 不支持 `pom.xml` 文件的[继承](https://maven.apache.org/pom.html#inheritance)。
- 仅支持 Maven，不支持自定义 JFrog 或其他产物仓库。
- 会反编译下载的依赖项，因此源代码到行号的转换可能并非 1:1。

<a id="python"></a>

#### Python

- 会尝试从 PyPI 下载源代码包进行分析。如果没有源代码包，
  Libbehave 会下载第一个可用的 `bdist_wheel` 包，该包可能与目标操作系统不匹配。

<a id="output"></a>

## 输出

Libbehave 会生成以下输出：

- **作业摘要**：发现结果的摘要会直接输出到 CI/CD 输出作业控制台中，
  以便快速查看依赖项检测到了哪些功能。
- **合并请求评论摘要**：发现结果的摘要会以合并请求评论的形式输出，以便更轻松地
  审阅。这需要配置访问令牌，以授予作业写入合并请求
  评论部分的权限。
- **HTML 产物**：一个 HTML 产物，其中包含可搜索的库和已识别
  功能集合，以及触发该发现结果的确切代码行。

<a id="job-summary"></a>

### 作业摘要

作业摘要无需额外配置，并且始终会在分析成功后呈现。

作业摘要输出示例如下：

```plaintext
# Job output #

[=== libbehave: New packages detected ===]
🔺 4 new packages have been detected in this MR.
[= java - open-vulnerability-clients 6.1.7 =]
The https://mvnrepository.com/artifact/io.github.jeremylong/open-vulnerability-clients package was found to exhibit the following behaviors:
    - 🟧 GzipReadArchive (Risk: Medium)
-----------------
[= java - jdiagnostics 1.0.7 =]
The https://mvnrepository.com/artifact/org.anarres.jdiagnostics/jdiagnostics package was found to exhibit the following behaviors:
    - 🟥 CryptoMD5 (Risk: High)
    - 🟧 WriteFile (Risk: Medium)
    - 🟧 ReadFile (Risk: Medium)
    - 🟧 ReadEnvVars (Risk: Medium)
-----------------
[= java - commons-dbcp2 2.12.0 =]
The https://mvnrepository.com/artifact/org.apache.commons/commons-dbcp2 package was found to exhibit the following behaviors:
    - 🟥 JavaObjectSerialization (Risk: High)
    - 🟧 Passwords (Risk: Medium)
-----------------
[= java - jmockit 1.49 =]
The https://mvnrepository.com/artifact/org.jmockit/jmockit package was found to exhibit the following behaviors:
    - 🟥 JavaObjectSerialization (Risk: High)
    - 🟧 WriteFile (Risk: Medium)
    - 🟧 ReadFile (Risk: Medium)
    - 🟨 CryptoRAND (Risk: Low)
-----------------
```

<a id="mr-comment-summary"></a>

### 合并请求评论摘要

**合并请求评论摘要**输出需要为已配置 Libbehave 组件的项目创建一个具有访客级别访问权限的访问令牌。然后应将该访问令牌[配置到项目中](../../../ci/variables/_index.md#for-a-project)。由于功能分支默认不受保护，请确保清除**保护变量**设置。否则，Libbehave 作业将无法读取访问令牌的值。

![合并请求评论摘要输出示例](img/libbehave_mr_comment_v17_4.png)

<a id="html-artifact"></a>

### HTML 产物

HTML 产物会出现在您的作业产物输出中（`behaveout/gl-libbehave.html`），并且应可在您的作业产物下载中访问。

![HTML 产物摘要输出](img/libbehave_html_artifact_v17_4.png)

<a id="offline-environment-not-supported"></a>

## 离线环境（不支持）

Libbehave 无法在离线环境中工作，因为它会直接从各种包管理器拉取依赖项。

<a id="troubleshooting"></a>

## 故障排除

<a id="job-is-not-run"></a>

### 作业未运行

如果 Libbehave 作业未运行，请确保您的项目已配置为运行[合并请求流水线](../../../ci/pipelines/merge_request_pipelines.md)。

<a id="merge-request-comment-is-not-being-added"></a>

### 未添加合并请求评论

这通常是由于未设置 `BEHAVE_TOKEN` 所致。请确保该访问令牌具有访客级别访问权限，并且在**设置** > **CI/CD** 变量设置中清除了**保护变量**选项。

<a id="error-401-permission-denied"></a>

#### 错误：`{401 Permission Denied}`

这通常是由于 `BEHAVE_TOKEN` 未包含正确的值所致。请确保该访问令牌具有访客级别访问权限。
