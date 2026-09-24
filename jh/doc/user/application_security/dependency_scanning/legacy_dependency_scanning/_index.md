---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖项扫描
description: Vulnerabilities, remediation, configuration, analyzers, and reports.
---

<style>
table.ds-table tr:nth-child(even) {
    background-color: transparent;
}

table.ds-table td {
    border-left: 1px solid #dbdbdb;
    border-right: 1px solid #dbdbdb;
    border-bottom: 1px solid #dbdbdb;
}

table.ds-table tr td:first-child {
    border-left: 0;
}

table.ds-table tr td:last-child {
    border-right: 0;
}

table.ds-table ul {
    font-size: 1em;
    list-style-type: none;
    padding-left: 0px;
    margin-bottom: 0px;
}

table.no-vertical-table-lines td {
    border-left: none;
    border-right: none;
    border-bottom: 1px solid #f0f0f0;
}

table.no-vertical-table-lines tr {
    border-top: none;
}
</style>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 基于 Gemnasium 分析器的依赖项扫描功能在 极狐GitLab 17.9 中已弃用，并计划在 极狐GitLab 20.0 中移除。但是，移除时间线尚未最终确定，您仍可以根据需要继续使用 Gemnasium。更多信息，请参见 [epic 15961](https://jihulab.com/groups/gitlab-cn/-/epics/15961)。

依赖项扫描集成到您的 CI/CD 流水线中，自动运行以识别应用程序依赖项中的安全漏洞。在合并前扫描分支，您可以在合并请求中即时了解安全问题，帮助您在合并代码之前就潜在漏洞做出明智决策。

默认情况下，依赖项扫描分析代码中的所有依赖项，包括运行时、开发以及传递性（嵌套）依赖项。您可以选择将开发依赖项排除在扫描之外。

对于流水线外依赖项的漏洞扫描，请参见[持续漏洞扫描](../../continuous_vulnerability_scanning/_index.md)。

## 开启依赖项扫描

遵循以下步骤在您的项目中开启依赖项扫描。

要启用分析器，可以：

- 启用 [Auto DevOps](../../../../topics/autodevops/_index.md)，其中包含依赖项扫描。
- 使用预配置的合并请求。
- 创建强制依赖项扫描的[扫描执行策略](../../policies/scan_execution_policies.md)。
- 手动编辑 `.gitlab-ci.yml` 文件。
- [使用 CI/CD 组件](#use-cicd-components)

### 使用预配置的合并请求

此方法会自动准备一个合并请求，其中包含 `.gitlab-ci.yml` 文件中的依赖项扫描模板。然后，您合并该合并请求即可启用依赖项扫描。

> [!note]
> 当不存在 `.gitlab-ci.yml` 文件或仅有极简配置文件时，此方法效果最佳。如果您有一个复杂的 极狐GitLab 配置文件，它可能无法被成功解析，并可能发生错误。在这种情况下，请改用[手动方法](#edit-the-gitlab-ciyml-file-manually)。

先决条件：

- 项目的维护者或所有者角色。
- `.gitlab-ci.yml` 文件中需要 `test` 阶段。
- 对于私有化部署 Runner，需要带有 [`docker`](https://gitlab.cn/docs/runner/executors/docker/) 或 [`kubernetes`](https://gitlab.cn/docs/runner/install/kubernetes/) 执行器的 极狐GitLab Runner。
- 对于 JihuLab.com 上的托管 Runner，默认已启用此配置。

开启依赖项扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **依赖项扫描** 行中，选择 **通过合并请求配置**。
1. 选择 **创建合并请求**。
1. 审查合并请求，然后选择 **合并**。

流水线现在包含依赖项扫描作业。

### 手动编辑 `.gitlab-ci.yml` 文件

此方法需要您手动编辑现有的 `.gitlab-ci.yml` 文件。如果您的 极狐GitLab CI/CD 配置文件较复杂，请使用此方法。

先决条件：

- 项目的维护者或所有者角色。
- `.gitlab-ci.yml` 文件中需要 `test` 阶段。
- 对于私有化部署 Runner，需要带有 [`docker`](https://gitlab.cn/docs/runner/executors/docker/) 或 [`kubernetes`](https://gitlab.cn/docs/runner/install/kubernetes/) 执行器的 极狐GitLab Runner。
- 对于 JihuLab.com 上的托管 Runner，默认已启用此配置。

开启依赖项扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线编辑器**。
1. 如果不存在 `.gitlab-ci.yml` 文件，选择 **配置流水线**，然后删除示例内容。
1. 将以下内容复制并粘贴到 `.gitlab-ci.yml` 文件的底部。如果已存在 `include` 行，只需在其下方添加 `template` 行。

   ```yaml
   include:
     - template: Jobs/Dependency-Scanning.gitlab-ci.yml
   ```

1. 选择 **验证** 选项卡，然后选择 **验证流水线**。

   消息 **模拟完成成功** 确认文件有效。
1. 选择 **编辑** 选项卡。
1. 填写字段。不要将 **分支** 字段使用默认分支。
1. 勾选 **以此更改启动新合并请求** 复选框，然后选择 **提交更改**。
1. 根据您的标准工作流填写字段，然后选择 **创建合并请求**。
1. 根据您的标准工作流审阅并编辑合并请求，然后选择 **合并**。

流水线现在包含依赖项扫描作业。

### 使用 CI/CD 组件

> [!note]
> 依赖项扫描 CI/CD 组件仅支持 Android 项目。

使用 [CI/CD 组件](../../../../ci/components/_index.md) 对您的应用程序执行依赖项扫描。有关说明，请参阅相应组件的 README 文件。

#### 可用的 CI/CD 组件

请参见 <https://gitlab.com/explore/catalog/components/dependency-scanning>

完成这些步骤后，您可以：

- 了解更多关于[理解结果](#understanding-the-results)的信息。
- 计划向更多项目[推广](#roll-out)。

## 理解结果

依赖项扫描结果以多种格式提供。您可以直接在流水线 UI 中查看，在详细的扫描报告中查看，或在扫描过程中生成的软件物料清单（SBOM）中查看。

### 在流水线中审查漏洞

审查流水线中检测到的漏洞，并在合并请求合并之前采取行动。

先决条件：

- 项目的开发者、维护者或所有者角色。

要在流水线中审查依赖项扫描结果：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 选项卡。
1. 选择一个漏洞以查看其详细信息，包括：
   - 状态：表明漏洞是否已分类或已解决。
   - 描述：解释漏洞的原因、潜在影响以及推荐的修复步骤。
   - 严重性：根据影响分为六个级别。[了解更多关于严重性级别](../../vulnerabilities/severities.md)的信息。
   - CVSS 评分：提供一个映射到严重性的数值。
   - EPSS：显示漏洞在野被利用的可能性。
   - 已知利用 (KEV)：表明给定漏洞已被利用。
   - 项目：高亮显示识别到漏洞的项目。
   - 报告类型 / 扫描器：解释用于生成输出的输出类型和扫描器。
   - 可达性：提供有关易受攻击的依赖项是否在代码中使用的指示。
   - 扫描器：识别哪个分析器检测到漏洞。
   - 位置：命名存有易受攻击依赖项的文件。
   - 链接：漏洞在各个咨询数据库中编目的证据。
   - 标识符：用于分类漏洞的引用列表，例如 CVE 标识符。

### 依赖项扫描报告

依赖项扫描输出一份包含所有漏洞详细信息的报告。该报告在内部处理，结果在 UI 中展示。该报告还作为依赖项扫描作业的产物输出，命名为 `gl-dependency-scanning-report.json`，始终在项目根目录生成。

有关依赖项扫描报告的更多详细信息，请参见[依赖项扫描报告架构](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/blob/master/dist/dependency-scanning-report-format.json)。

### CycloneDX 软件物料清单

依赖项扫描为它检测到的每个支持的锁定文件或构建文件输出一个 [CycloneDX](https://cyclonedx.org/) 软件物料清单（SBOM）。

CycloneDX SBOM 的特点：

- 命名为 `gl-sbom-<package-type>-<package-manager>.cdx.json`。
- 作为依赖项扫描作业的作业产物提供。
- 保存在与检测到的锁定文件或构建文件相同的目录中。

例如，如果您的项目具有以下结构：

```plaintext
.
├── ruby-project/
│   └── Gemfile.lock
├── ruby-project-2/
│   └── Gemfile.lock
├── php-project/
│   └── composer.lock
└── go-project/
    └── go.sum
```

那么 Gemnasium 扫描器会生成以下 CycloneDX SBOM：

```plaintext
.
├── ruby-project/
│   ├── Gemfile.lock
│   └── gl-sbom-gem-bundler.cdx.json
├── ruby-project-2/
│   ├── Gemfile.lock
│   └── gl-sbom-gem-bundler.cdx.json
├── php-project/
│   ├── composer.lock
│   └── gl-sbom-packagist-composer.cdx.json
└── go-project/
    ├── go.sum
    └── gl-sbom-go-go.cdx.json
```

## 推广

当您对单个项目的依赖项扫描结果感到有信心后，可以将其实现扩展到更多项目：

- 使用[强制扫描执行](../../detect/security_configuration.md#create-a-shared-configuration)将依赖项扫描设置应用于群组。
- 如果您有独特的需求，依赖项扫描与 SBOM 可以在[离线环境](../../offline_deployments/_index.md)中运行。

## 支持的语言和软件包管理器

> [!note]
> 依赖项扫描不支持编译器和解释器的运行时安装。

依赖项扫描支持以下语言和依赖项管理器：

<!-- markdownlint-disable MD044 -->
<table class="ds-table">
  <thead>
    <tr>
      <th>语言</th>
      <th>语言版本</th>
      <th>软件包管理器</th>
      <th>支持的文件</th>
      <th><a href="#how-multiple-files-are-processed">是否处理多个文件？</a></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>.NET</td>
      <td rowspan="2">所有版本</td>
      <td rowspan="2"><a href="https://www.nuget.org/">NuGet</a></td>
      <td rowspan="2"><a href="https://learn.microsoft.com/en-us/nuget/consume-packages/package-references-in-project-files#enabling-lock-file"><code>packages.lock.json</code></a></td>
      <td rowspan="2">是</td>
    </tr>
    <tr>
      <td>C#</td>
    </tr>
    <tr>
      <td>C</td>
      <td rowspan="2">所有版本</td>
      <td rowspan="2"><a href="https://conan.io/">Conan</a></td>
      <td rowspan="2"><a href="https://docs.conan.io/en/latest/versioning/lockfiles.html"><code>conan.lock</code></a></td>
      <td rowspan="2">是</td>
    </tr>
    <tr>
      <td>C++</td>
    </tr>
    <tr>
      <td>Go</td>
      <td>所有版本</td>
      <td><a href="https://go.dev/">Go</a></td>
      <td>
        <ul>
          <li><code>go.mod</code></li>
        </ul>
      </td>
      <td>是</td>
    </tr>
    <tr>
      <td rowspan="2">Java 和 Kotlin</td>
      <td rowspan="2">
        8 LTS，
        11 LTS，
        17 LTS，
        或 21 LTS<sup>1</sup>
      </td>
      <td><a href="https://gradle.org/">Gradle</a><sup>2</sup></td>
      <td>
        <ul>
            <li><code>build.gradle</code></li>
            <li><code>build.gradle.kts</code></li>
        </ul>
      </td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://maven.apache.org/">Maven</a><sup>6</sup></td>
      <td><code>pom.xml</code></td>
      <td>否</td>
    </tr>
    <tr>
      <td rowspan="3">JavaScript 和 TypeScript</td>
      <td rowspan="3">所有版本</td>
      <td><a href="https://www.npmjs.com/">npm</a></td>
      <td>
        <ul>
            <li><code>package-lock.json</code></li>
            <li><code>npm-shrinkwrap.json</code></li>
        </ul>
      </td>
      <td>是</td>
    </tr>
    <tr>
      <td><a href="https://classic.yarnpkg.com/en/">yarn</a></td>
      <td><code>yarn.lock</code></td>
      <td>是</td>
    </tr>
    <tr>
      <td><a href="https://pnpm.io/">pnpm</a><sup>3</sup></td>
      <td><code>pnpm-lock.yaml</code></td>
      <td>是</td>
    </tr>
    <tr>
      <td>PHP</td>
      <td>所有版本</td>
      <td><a href="https://getcomposer.org/">Composer</a></td>
      <td><code>composer.lock</code></td>
      <td>是</td>
    </tr>
    <tr>
      <td rowspan="5">Python</td>
      <td rowspan="5">3.11<sup>7</sup></td>
      <td><a href="https://setuptools.readthedocs.io/en/latest/">setuptools</a><sup>8</sup></td>
      <td><code>setup.py</code></td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://pip.pypa.io/en/stable/">pip</a></td>
      <td>
        <ul>
            <li><code>requirements.txt</code></li>
            <li><code>requirements.pip</code></li>
            <li><code>requires.txt</code></li>
        </ul>
      </td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://pipenv.pypa.io/en/latest/">Pipenv</a></td>
      <td>
        <ul>
            <li><a href="https://pipenv.pypa.io/en/latest/pipfile.html#example-pipfile"><code>Pipfile</code></a></li>
            <li><a href="https://pipenv.pypa.io/en/latest/pipfile.html#example-pipfile-lock"><code>Pipfile.lock</code></a></li>
        </ul>
      </td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://python-poetry.org/">Poetry</a><sup>4</sup></td>
      <td><code>poetry.lock</code></td>
      <td>否</td>
    </tr>
    <tr>
      <td><a href="https://docs.astral.sh/uv/">uv</a><sup>11</sup></td>
      <td><code>uv.lock</code></td>
      <td>是</td>
    </tr>
    <tr>
      <td>Ruby</td>
      <td>所有版本</td>
      <td><a href="https://bundler.io/">Bundler</a></td>
      <td>
        <ul>
            <li><code>Gemfile.lock</code></li>
            <li><code>gems.locked</code></li>
        </ul>
      </td>
      <td>是</td>
    </tr>
    <tr>
      <td>Scala</td>
      <td>所有版本</td>
      <td><a href="https://www.scala-sbt.org/">sbt</a><sup>5</sup></td>
      <td><code>build.sbt</code></td>
      <td>否</td>
    </tr>
    <tr>
      <td>Swift</td>
      <td>所有版本</td>
      <td><a href="https://swift.org/package-manager/">Swift Package Manager</a></td>
      <td><code>Package.resolved</code></td>
      <td>否</td>
    </tr>
    <tr>
      <td>CocoaPods<sup>9</sup></td>
      <td>所有版本</td>
      <td><a href="https://cocoapods.org/">CocoaPods</a></td>
      <td><code>Podfile.lock</code></td>
      <td>否</td>
    </tr>
    <tr>
      <td>Dart<sup>10</sup></td>
      <td>所有版本</td>
      <td><a href="https://pub.dev/">Pub</a></td>
      <td><code>pubspec.lock</code></td>
      <td>否</td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-disable MD029 -->

**脚注**：

1. 用于 [sbt](https://www.scala-sbt.org/) 的 Java 21 LTS 限制于版本 1.9.7。对更多 sbt 版本的支持可追踪 issue 430335。启用 FIPS 模式时不支持。
2. 启用 FIPS 模式时不支持 Gradle。
3. pnpm 锁定文件不存储捆绑的依赖项，因此报告的依赖项可能与 npm 或 yarn 不同。
4. 对没有 `poetry.lock` 文件的项目的支持可追踪 issue 32774。
5. 对 sbt 1.0.x 的支持在 极狐GitLab 16.8 中[弃用]，并在 极狐GitLab 17.0 中[移除]。
6. 对 Maven 3.8.8 以下版本的支持在 极狐GitLab 16.9 中[弃用]，并在 极狐GitLab 17.0 中移除。
7. 对先前 Python 版本的支持在 极狐GitLab 16.9 中[弃用]，并在 极狐GitLab 17.0 中[移除]。
8. 从报告中排除 `pip` 和 `setuptools`，因为它们是安装程序所需的。
9. 仅 SBOM，无安全通告。参见 issue 468764。
10. 无许可证检测。参见 epic 17037。
11. 如果锁定文件包含同一软件包的多个条目且具有不同的环境标记（例如，numpy==2.2.6 用于 Python <3.11 且 numpy==2.4.1 用于 Python ≥3.11），则仅解析并报告第一个条目。

<!-- markdownlint-enable MD029 -->
<!-- markdownlint-enable MD044 -->

## 支持的开发依赖项

对以下语言和软件包管理器支持检测开发依赖项：

<!-- vale gitlab_base.Substitutions = NO -->
<!-- markdownlint-disable MD044 -->

| 语言                     | 软件包管理器 | 文件 |
|--------------------------|--------------|------|
| C/C++/Fortran/Go/Python/R | conda        | `conda-lock.yml` |
| Java                     | Maven        | `maven.graph.json` |
| Java/Kotlin              | Gradle       | `dependencies.lock`, `dependencies.direct.lock`, `gradle-html-dependency-report.js`, `gradle.lockfile` |
| JavaScript/TypeScript    | npm          | `package-lock.json`, `npm-shrinkwrap.json` |
| JavaScript/TypeScript    | pnpm         | `pnpm-lock.yaml` |
| PHP                      | Composer     | `composer.lock` |
| Python                   | Pipenv       | `Pipfile.lock` |
| Python                   | Poetry       | `poetry.lock` |
| Python                   | uv           | `uv.lock` |

<!-- markdownlint-enable MD044 -->
<!-- vale gitlab_base.Substitutions = YES -->

## 在合并请求流水线中运行作业

参见[在合并请求流水线中使用安全扫描工具](../../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)

## 自定义分析器行为

要自定义依赖项扫描，请使用 [CI/CD 变量](#available-cicd-variables)。

> [!warning]
> 在将这些更改合并到默认分支之前，请务必在合并请求中测试所有 极狐GitLab 分析器的自定义设置。否则可能会产生意外结果，包括大量误报。

### 覆盖依赖项扫描作业

要覆盖作业定义（例如，更改 `variables` 或 `dependencies` 等属性），请声明一个与要覆盖的作业同名的新作业。将此新作业放在模板包含之后，并在其下指定任何额外的键。

例如，这将禁用 `gemnasium` 分析器对易受攻击依赖项的自动修复：

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

gemnasium-dependency_scanning:
  variables:
    DS_REMEDIATE: "false"
```

要覆盖 `dependencies: []` 属性，请按照上述方式添加一个覆盖作业，目标为该属性：

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

gemnasium-dependency_scanning:
  dependencies: ["build"]
```

### 可用的 CI/CD 变量

您可以使用 CI/CD 变量来[自定义](#customizing-analyzer-behavior)依赖项扫描行为。

#### 全局分析器设置

以下变量允许配置全局依赖项扫描设置。

| CI/CD 变量                | 描述 |
| -------------------------|------------ |
| `ADDITIONAL_CA_CERT_BUNDLE` | 要信任的 CA 证书包。此处提供的证书包也会被扫描过程中的其他工具使用，例如 `git`、`yarn` 或 `npm`。更多详情，请参见[自定义 TLS 证书颁发机构](#custom-tls-certificate-authority)。 |
| `DS_EXCLUDED_ANALYZERS`     | 指定要从依赖项扫描中排除的分析器（按名称）。更多信息，请参见[分析器](#analyzers)。 |
| `DS_EXCLUDED_PATHS`         | 根据路径从扫描中排除文件和目录。逗号分隔的模式列表。模式可以是 glob（参见[`doublestar.Match`](https://pkg.go.dev/github.com/bmatcuk/doublestar/v4@v4.0.2#Match)了解支持的模式），或者文件或文件夹路径（例如 `doc,spec`）。父目录也匹配模式。这是在扫描执行之前应用的预过滤。默认值：`"spec, test, tests, tmp"`。 |
| `DS_IMAGE_SUFFIX`           | 添加到镜像名称的后缀。（极狐GitLab 团队成员可以在以下机密议题中查看更多信息：`https://gitlab.com/gitlab-org/gitlab/-/issues/354796`）。启用 FIPS 模式时自动设置为 `"-fips"`。 |
| `DS_MAX_DEPTH`              | 定义分析器应搜索支持文件的目录深度级别。值为 `-1` 将扫描所有目录，无论深度如何。默认值：`2`。 |
| `SECURE_ANALYZERS_PREFIX`   | 覆盖提供官方默认镜像的 Docker 注册表名称（代理）。 |

#### 特定分析器设置

以下变量配置特定依赖项扫描分析器的行为。
| CI/CD 变量                         | 分析器            | 默认值                       | 描述 |
|--------------------------------------|--------------------|------------------------------|-------------|
| `GEMNASIUM_DB_LOCAL_PATH`            | `gemnasium`        | `/gemnasium-db`              | 本地 Gemnasium 数据库的路径。 |
| `GEMNASIUM_DB_UPDATE_DISABLED`       | `gemnasium`        | `"false"`                    | 禁用 `gemnasium-db` 安全公告数据库的自动更新。有关使用方法，请参见[访问极狐GitLab安全公告数据库](#access-to-the-gitlab-advisory-database)。 |
| `GEMNASIUM_DB_REMOTE_URL`            | `gemnasium`        | `https://jihulab.com/gitlab-cn/security-products/gemnasium-db.git` | 用于获取极狐GitLab安全公告数据库的仓库 URL。 |
| `GEMNASIUM_DB_REF_NAME`              | `gemnasium`        | `master`                     | 远程仓库数据库的分支名称。需要 `GEMNASIUM_DB_REMOTE_URL`。 |
| `GEMNASIUM_IGNORED_SCOPES`           | `gemnasium`        |                              | 要忽略的 Maven 依赖作用域的逗号分隔列表。更多详情，请参见 [Maven 依赖作用域文档](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#Dependency_Scope) |
| `DS_REMEDIATE`                       | `gemnasium`        | `"true"`, `"false"` en modo FIPS | 启用对存在漏洞的依赖项的自动修复。在 FIPS 模式下不受支持。 |
| `DS_REMEDIATE_TIMEOUT`               | `gemnasium`        | `5m`                         | 自动修复的超时时间。 |
| `GEMNASIUM_LIBRARY_SCAN_ENABLED`     | `gemnasium`        | `"true"`                     | 启用检测 vendored JavaScript 库（未由包管理器管理的库）中的漏洞。此功能需要提交中存在 JavaScript 锁定文件，否则依赖扫描不会执行，vendored文件也不会被扫描。<br>依赖扫描使用 [Retire.js](https://github.com/RetireJS/retire.js) 扫描器来检测有限的漏洞集。有关检测到哪些漏洞的详细信息，请参见 [Retire.js 仓库](https://github.com/RetireJS/retire.js/blob/master/repository/jsrepository.json)。 |
| `DS_INCLUDE_DEV_DEPENDENCIES`        | `gemnasium`        | `"true"`                     | 当设置为 `"false"` 时，不会报告开发依赖及其漏洞。仅支持使用 Composer、Maven、npm、pnpm、Pipenv 或 Poetry 的项目。在极狐GitLab 15.1 中引入。 |
| `GOOS`                               | `gemnasium`        | `"linux"`                    | 编译 Go 代码使用的操作系统。 |
| `GOARCH`                             | `gemnasium`        | `"amd64"`                    | 编译 Go 代码使用的处理器架构。 |
| `GOFLAGS`                            | `gemnasium`        |                              | 传递给 `go build` 工具的标记。 |
| `GOPRIVATE`                          | `gemnasium`        |                              | 应从源代码获取的 Glob 模式和前缀列表。更多信息，请参见 Go 私有模块[文档](https://go.dev/ref/mod#private-modules)。 |
| `DS_JAVA_VERSION`                    | `gemnasium-maven`  | `17`                         | Java 版本。可用版本：`8`、`11`、`17`、`21`。 |
| `MAVEN_CLI_OPTS`                     | `gemnasium-maven`  | `"-DskipTests --batch-mode"` | 分析器传递给 `maven` 的命令行参数列表。有关示例，请参阅[对私有 Maven 仓库进行身份验证](#authenticate-with-a-private-maven-repository)。 |
| `GRADLE_CLI_OPTS`                    | `gemnasium-maven`  |                              | 分析器传递给 `gradle` 的命令行参数列表。 |
| `GRADLE_PLUGIN_INIT_PATH`            | `gemnasium-maven`  | `"gemnasium-init.gradle"`    | 指定 Gradle 初始化脚本的路径。初始化脚本必须包含 `allprojects { apply plugin: 'project-report' }` 以确保兼容性。 |
| `DS_GRADLE_RESOLUTION_POLICY`        | `gemnasium-maven`  | `"failed"`                   | 控制 Gradle 依赖解析的严格程度。接受 `"none"` 允许部分结果，或 `"failed"` 在任一依赖解析失败时使扫描失败。 |
| `SBT_CLI_OPTS`                       | `gemnasium-maven`  |                              | 分析器传递给 `sbt` 的命令行参数列表。 |
| `PIP_INDEX_URL`                      | `gemnasium-python` | `https://pypi.org/simple`    | Python 包索引的基础 URL。 |
| `PIP_EXTRA_INDEX_URL`                | `gemnasium-python` |                              | 除 `PIP_INDEX_URL` 之外要使用的包索引的[额外 URL](https://pip.pypa.io/en/stable/reference/pip_install/#cmdoption-extra-index-url) 数组。以逗号分隔。**Warning**：使用此环境变量时，请阅读[以下安全注意事项](#python-projects)。 |
| `PIP_REQUIREMENTS_FILE`              | `gemnasium-python` |                              | 要扫描的 Pip 需求文件。这是一个文件名而非路径。设置此环境变量后，仅扫描指定的文件。 |
| `PIPENV_PYPI_MIRROR`                 | `gemnasium-python` |                              | 若设置，将使用[镜像](https://github.com/pypa/pipenv/blob/v2022.1.8/pipenv/environments.py#L263)覆盖 Pipenv 使用的 PyPi 索引。 |
| `DS_PIP_VERSION`                     | `gemnasium-python` |                              | 强制安装特定 pip 版本（例如：`"19.3"`），否则使用 Docker 镜像中安装的 pip。 |
| `DS_PIP_DEPENDENCY_PATH`             | `gemnasium-python` |                              | 从中加载 Python pip 依赖的路径。 |

<a id="other-variables"></a>

#### 其他变量

前面的表格并非可用变量的详尽列表。它们包含了所有经过支持和测试的特定极狐GitLab和分析器变量。许多其他变量，比如环境变量，也可以传入并正常工作。这个列表很大且没有完全文档化。

例如，要将非极狐GitLab环境变量 `HTTPS_PROXY` 传递到所有依赖扫描作业，可以像这样在你的 `.gitlab-ci.yml` 文件中将其设置为 [CI/CD 变量](../../../../ci/variables/_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)：

```yaml
variables:
  HTTPS_PROXY: "https://squid-proxy:3128"
```

> [!note]
> Gradle 项目需要[额外变量](#use-a-proxy-with-gradle-projects)设置才能使用代理。

或者，可以在特定作业中使用它，比如依赖扫描：

```yaml
dependency_scanning:
  variables:
    HTTPS_PROXY: $HTTPS_PROXY
```

由于并非所有变量都经过测试，你可能会发现有些能工作，有些不能。如果需要某个不能工作的变量，可以提交功能请求或贡献代码以使其可用。

<a id="custom-tls-certificate-authority"></a>

### 自定义 TLS 证书颁发机构

依赖扫描允许使用自定义 TLS 证书进行 SSL/TLS 连接，而不是使用分析器容器镜像中默认的证书。

对自定义证书颁发机构的支持在以下版本中引入。

| 分析器            | 版本                                                                                                |
|--------------------|--------------------------------------------------------------------------------------------------------|
| `gemnasium`        | [v2.8.0](https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/releases/v2.8.0)        |
| `gemnasium-maven`  | [v2.9.0](https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium-maven/-/releases/v2.9.0)  |
| `gemnasium-python` | [v2.7.0](https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium-python/-/releases/v2.7.0) |

<a id="use-a-custom-tls-certificate-authority"></a>

#### 使用自定义 TLS 证书颁发机构

先决条件：

- 项目中的维护者或所有者角色。

要使用自定义 TLS 证书颁发机构：

- 将 [X.509 PEM 公钥证书的文本表示](https://www.rfc-editor.org/rfc/rfc7468#section-5.1) 赋值给 CI/CD 变量 `ADDITIONAL_CA_CERT_BUNDLE`。

例如，在 `.gitlab-ci.yml` 文件中配置证书：

```yaml
variables:
  ADDITIONAL_CA_CERT_BUNDLE: |
      -----BEGIN CERTIFICATE-----
      MIIGqTCCBJGgAwIBAgIQI7AVxxVwg2kch4d56XNdDjANBgkqhkiG9w0BAQsFADCB
      ...
      jWgmPqF3vUbZE0EyScetPJquRFRKIesyJuBFMAs=
      -----END CERTIFICATE-----
```

<a id="authenticate-with-a-private-maven-repository"></a>

### 对私有 Maven 仓库进行身份验证

要允许依赖分析器对私有 Maven 仓库进行身份验证，必须在 CI/CD 流水线中配置凭据。如果没有身份验证，依赖分析器无法访问私有依赖，扫描将失败。

> [!warning]
> 不要将凭据添加到你的 `.gitlab-ci.yml` 文件中。

先决条件：

- 项目中的维护者或所有者角色。

要允许依赖分析器对私有 Maven 仓库进行身份验证：

1. [创建一个项目 CI/CD 变量](../../../../ci/variables/_index.md#for-a-project)，命名为 `MAVEN_CLI_OPTS`，并将其值设为包含你的凭据。

   例如，假设一个名为 `mysettings.xml` 的设置文件，用户名为 `myuser`，密码为 `verysecret`，你可以将 `MAVEN_CLI_OPTS` CI/CD 变量设置为：

   `--settings mysettings.xml -Drepository.password=verysecret -Drepository.user=myuser`
1. 创建包含服务器配置的 `mysettings.xml` Maven 设置文件。文件名必须与你在步骤 1 中为 `--settings` 选项指定的值匹配。

   ```xml
   <!-- mysettings.xml -->
   <settings>
       ...
       <servers>
           <server>
               <id>private_server</id>
               <username>${repository.user}</username>
               <password>${repository.password}</password>
           </server>
       </servers>
   </settings>
   ```

<a id="fips-enabled-images"></a>

### 启用 FIPS 的镜像

极狐GitLab 还提供了 Gemnasium 镜像的 [FIPS-enabled Red Hat UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) 版本。当极狐GitLab 实例中启用了 FIPS 模式时，Gemnasium 扫描作业会自动使用启用 FIPS 的镜像。要手动切换到启用 FIPS 的镜像，请将变量 `DS_IMAGE_SUFFIX` 设置为 `"-fips"`。

Gradle 项目的依赖扫描和 Yarn 项目的自动修复在 FIPS 模式下不受支持。

启用 FIPS 的镜像基于 RedHat 的 UBI micro。它们没有 `dnf` 或 `microdnf` 等包管理器，因此无法在运行时安装系统软件包。

<a id="offline-environment"></a>

### 离线环境

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

对于在受限、受限或间歇性访问外部资源的实例，为了让依赖扫描作业成功运行，需要进行一些调整。更多信息，请参见[离线环境](../../offline_deployments/_index.md)。

先决条件：

- 管理员权限。
- 具有 `docker` 或 `kubernetes` 执行器的 GitLab Runner
- 依赖扫描分析器镜像的本地副本
- 访问[极狐GitLab安全公告数据库](https://jihulab.com/gitlab-cn/security-products/gemnasium-db)
- 访问[软件包元数据数据库](../../../../topics/offline/quick_start_guide.md#enabling-the-package-metadata-database)

<a id="local-copies-of-analyzer-images"></a>

#### 分析器镜像的本地副本

要对所有[支持的语言和包管理器](#supported-languages-and-package-managers)使用依赖扫描：

1. 将以下默认依赖扫描分析器镜像从 `registry.gitlab.com` 导入到你的[本地 Docker 容器镜像仓库](../../../packages/container_registry/_index.md)：

   ```plaintext
   registry.gitlab.com/security-products/gemnasium:6
   registry.gitlab.com/security-products/gemnasium:6-fips
   registry.gitlab.com/security-products/gemnasium-maven:6
   registry.gitlab.com/security-products/gemnasium-maven:6-fips
   registry.gitlab.com/security-products/gemnasium-python:6
   registry.gitlab.com/security-products/gemnasium-python:6-fips
   ```

   将 Docker 镜像导入本地离线 Docker 仓库的过程取决于**你的网络安全策略**。请咨询你的 IT 人员，找到可接受且经批准的流程，以便能够导入或临时访问外部资源。
   这些扫描器会定期[更新](../../detect/vulnerability_scanner_maintenance.md)新定义，你可能需要定期下载它们。
1. 配置极狐GitLab CI/CD 使用本地分析器。

   将 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 的值设置为你的本地 Docker 仓库——在此示例中为 `docker-registry.example.com`。

   ```yaml
   include:
     - template: Jobs/Dependency-Scanning.gitlab-ci.yml

   variables:
     SECURE_ANALYZERS_PREFIX: "docker-registry.example.com/analyzers"
   ```

<a id="access-to-the-gitlab-advisory-database"></a>

#### 访问极狐GitLab安全公告数据库

[极狐GitLab安全公告数据库](https://jihulab.com/gitlab-cn/security-products/gemnasium-db) 是 `gemnasium`、`gemnasium-maven` 和 `gemnasium-python` 分析器使用的漏洞数据来源。这些分析器的 Docker 镜像中包含了该数据库的一个克隆。该克隆会在开始扫描前与数据库同步，以确保分析器拥有最新的漏洞数据。

在离线环境中，无法访问极狐GitLab安全公告数据库的默认主机。相反，你必须将该数据库托管在 GitLab Runner 可以访问的位置。你还必须按照自己的计划手动更新数据库。

托管数据库的可用选项有：

- [使用极狐GitLab安全公告数据库的克隆](#use-a-clone-of-the-gitlab-advisory-database)。
- [使用极狐GitLab安全公告数据库的副本](#use-a-copy-of-the-gitlab-advisory-database)。

<a id="use-a-clone-of-the-gitlab-advisory-database"></a>

##### 使用极狐GitLab安全公告数据库的克隆

建议使用极狐GitLab安全公告数据库的克隆，因为这是最有效的方法。

要托管极狐GitLab安全公告数据库的克隆：

1. 将极狐GitLab安全公告数据库克隆到一个可通过 HTTP 从 GitLab Runner 访问的主机。
1. 在你的 `.gitlab-ci.yml` 文件中，将 CI/CD 变量 `GEMNASIUM_DB_REMOTE_URL` 设置为该 Git 仓库的 URL。

例如：

```yaml
variables:
  GEMNASIUM_DB_REMOTE_URL: https://users-own-copy.example.com/gemnasium-db.git
```

<a id="use-a-copy-of-the-gitlab-advisory-database"></a>

##### 使用极狐GitLab安全公告数据库的副本

使用极狐GitLab安全公告数据库的副本需要你托管一个可由分析器下载的归档文件。

要使用极狐GitLab安全公告数据库的副本：

1. 将极狐GitLab安全公告数据库的归档文件下载到一个可通过 HTTP 从 GitLab Runner 访问的主机。归档文件位于
   `https://jihulab.com/gitlab-cn/security-products/gemnasium-db/-/archive/master/gemnasium-db-master.tar.gz`。
1. 更新你的 `.gitlab-ci.yml` 文件。

   - 设置 CI/CD 变量 `GEMNASIUM_DB_LOCAL_PATH` 使用数据库的本地副本。
   - 设置 CI/CD 变量 `GEMNASIUM_DB_UPDATE_DISABLED` 禁用数据库更新。
   - 在扫描开始前下载并解压安全公告数据库。

   ```yaml
   variables:
     GEMNASIUM_DB_LOCAL_PATH: ./gemnasium-db-local
     GEMNASIUM_DB_UPDATE_DISABLED: "true"

   dependency_scanning:
     before_script:
       - wget https://local.example.com/gemnasium_db.tar.gz
       - mkdir -p $GEMNASIUM_DB_LOCAL_PATH
       - tar -xzvf gemnasium_db.tar.gz --strip-components=1 -C $GEMNASIUM_DB_LOCAL_PATH
   ```

<a id="use-a-proxy-with-gradle-projects"></a>

### 在 Gradle 项目中使用代理

Gradle wrapper 脚本不会读取 `HTTP(S)_PROXY` 环境变量。更多详情，请参见 [Gradle issue 11065](https://github.com/gradle/gradle/issues/11065)。

先决条件：

- 项目中的维护者或所有者角色。

要使 Gradle wrapper 脚本使用代理：

- 通过 `GRADLE_CLI_OPTS` CI/CD 变量指定代理选项：

  ```yaml
  variables:
    GRADLE_CLI_OPTS: "-Dhttps.proxyHost=squid-proxy -Dhttps.proxyPort=3128 -Dhttp.proxyHost=squid-proxy -Dhttp.proxyPort=3128 -Dhttp.nonProxyHosts=localhost"
  ```

<a id="use-a-proxy-with-maven-projects"></a>

### 在 Maven 项目中使用代理

Maven 不会读取 `HTTP(S)_PROXY` 环境变量。你必须使用 Maven 设置文件。

先决条件：

- 项目中的维护者或所有者角色。

要配置 Maven 依赖扫描器使用代理：

1. 在项目的仓库中创建一个 `mysettings.xml` 文件。在该文件中配置 Maven 代理设置。

   有关如何指定代理配置的详细信息，请参见 [Maven 文档](https://maven.apache.org/guides/mini/guide-proxies.html)。
1. 在你的项目 `.gitlab-ci.yml` 文件中定义 `MAVEN_CLI_OPTS` CI/CD 变量，以引用设置文件 `mysettings.xml`。

   ```yaml
   variables:
     MAVEN_CLI_OPTS: "--settings mysettings.xml"
   ```

<a id="specific-settings-for-languages-and-package-managers"></a>

### 特定语言和包管理器的设置

请参见以下章节为特定语言和包管理器进行配置。

<a id="python-pip"></a>

#### Python (pip)

如果在分析器运行前需要安装 Python 包，你应该在扫描作业的 `before_script` 中使用 `pip install --user`。`--user` 标志会导致项目依赖被安装到用户目录中。如果不传递 `--user` 选项，包会被全局安装，它们不会被扫描且在列出项目依赖时不会显示。

<a id="python-setuptools"></a>

#### Python (setuptools)

如果在分析器运行前需要安装 Python 包，你应该在扫描作业的 `before_script` 中使用 `python setup.py install --user`。`--user` 标志会导致项目依赖被安装到用户目录中。如果不传递 `--user` 选项，包会被全局安装，它们不会被扫描且在列出项目依赖时不会显示。

当为私有 PyPi 仓库使用自签名证书时，不需要额外的作业配置（除了之前的 `.gitlab-ci.yml` 模板）。但是，你必须更新你的 `setup.py` 以确保它能访问你的私有仓库。以下是示例配置：

1. 更新 `setup.py` 为 `install_requires` 列表中的每个依赖创建一个指向你私有仓库的 `dependency_links` 属性：

   ```python
   install_requires=['pyparsing>=2.0.3'],
   dependency_links=['https://pypi.example.com/simple/pyparsing'],
   ```

1. 从你的仓库 URL 获取证书并将其添加到项目中：

   ```shell
   printf "\n" | openssl s_client -connect pypi.example.com:443 -servername pypi.example.com | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > internal.crt
   ```

1. 让 `setup.py` 指向刚下载的证书：

   ```python
   import setuptools.ssl_support
   setuptools.ssl_support.cert_paths = ['internal.crt']
   ```

<a id="python-pipenv"></a>

#### Python (Pipenv)

如果在有限的网络连接环境中运行，你必须配置 `PIPENV_PYPI_MIRROR` 变量以使用私有 PyPi 镜像。该镜像必须同时包含默认和开发依赖。

```yaml
variables:
  PIPENV_PYPI_MIRROR: https://pypi.example.com/simple
```

<!-- markdownlint-disable MD044 -->
或者，如果无法使用私有仓库，你可以将所需的包加载到 Pipenv 虚拟环境缓存中。对于此选项，项目必须将 `Pipfile.lock` 签入到仓库中，并将默认和开发包都加载到缓存中。请参见 [python-pipenv](https://jihulab.com/gitlab-cn/security-products/tests/python-pipenv/-/blob/41cc017bd1ed302f6edebcfa3bc2922f428e07b6/.gitlab-ci.yml#L20-42) 项目了解如何实现的示例。
<!-- markdownlint-enable MD044 -->

<a id="dependency-detection"></a>

## 依赖检测

依赖扫描会自动检测仓库中使用的语言。所有匹配检测到的语言的分析器都会运行。通常不需要自定义分析器的选择。不要指定分析器，以便自动使用完整的选择以获得最佳覆盖范围，并避免在分析器被弃用或移除时需要进行调整。但是，你可以使用变量 `DS_EXCLUDED_ANALYZERS` 来覆盖此选择。

语言检测依赖于 CI 作业 [`rules`](../../../../ci/yaml/_index.md#rules) 来检测[支持的依赖文件](#how-analyzers-are-triggered)。

对于 Java 和 Python，当检测到支持的依赖文件时，依赖扫描会尝试构建项目并执行一些 Java 或 Python 命令以获取依赖列表。对于所有其他项目，则会解析锁定文件来获取依赖列表，而无需先构建项目。

所有直接和传递依赖都会被分析，对传递依赖的深度没有限制。

<a id="analyzers"></a>

### 分析器

依赖扫描支持以下基于 [Gemnasium](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium) 的官方分析器：

- `gemnasium`
- `gemnasium-maven`
- `gemnasium-python`

分析器发布为 Docker 镜像，依赖扫描使用这些镜像为每个分析启动专用容器。你也可以集成自定义安全扫描器。

每个分析器会随着 Gemnasium 新版本的发布而更新。

<a id="how-analyzers-obtain-dependency-information"></a>

### 分析器如何获取依赖信息

极狐GitLab 分析器使用以下两种方法之一获取依赖信息：

1. [直接解析锁定文件。](#obtaining-dependency-information-by-parsing-lockfiles)
1. [运行包管理器或构建工具生成可被解析的依赖信息文件。](#obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file)

<a id="obtaining-dependency-information-by-parsing-lockfiles"></a>

#### 通过解析锁定文件获取依赖信息

以下包管理器使用极狐GitLab 分析器能够直接解析的锁定文件：
<table class="ds-table no-vertical-table-lines">
  <thead>
    <tr>
      <th>包管理器</th>
      <th>支持的文件格式版本</th>
      <th>测试过的包管理器版本</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Bundler</td>
      <td>不适用</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/ruby-bundler/default/Gemfile.lock#L118">1.17.3</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/ruby-bundler/default/Gemfile.lock#L118">2.1.4</a>
      </td>
    </tr>
    <tr>
      <td>Composer</td>
      <td>不适用</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/php-composer/default/composer.lock">1.x</a>
      </td>
    </tr>
    <tr>
      <td>Conan</td>
      <td>0.4</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/c-conan/default/conan.lock#L38">1.x</a>
      </td>
    </tr>
    <tr>
      <td>Go</td>
      <td>不适用</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/go-modules/gosum/default/go.sum">1.x</a>
      </td>
    </tr>
    <tr>
      <td>NuGet</td>
      <td>v1、v2<sup>1</sup></td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/csharp-nuget-dotnetcore/default/src/web.api/packages.lock.json#L2">4.9</a>
      </td>
    </tr>
    <tr>
      <td>npm</td>
      <td>v1、v2、v3</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/js-npm/default/package-lock.json#L4">6.x</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/js-npm/lockfileVersion2/package-lock.json#L4">7.x</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/scanner/parser/npm/fixtures/lockfile-v3/simple/package-lock.json#L4">9.x</a>
      </td>
    </tr>
    <tr>
      <td>pnpm</td>
      <td>v5、v6、v9</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/js-pnpm/default/pnpm-lock.yaml#L1">7.x</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/scanner/parser/pnpm/fixtures/v6/simple/pnpm-lock.yaml#L1">8.x</a>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/scanner/parser/pnpm/fixtures/v9/simple/pnpm-lock.yaml#L1">9.x</a>
      </td>
    </tr>
    <tr>
      <td>yarn</td>
      <td>版本 1、2、3、4<sup>2</sup></td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/js-yarn/classic/default/yarn.lock#L2">1.x</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/js-yarn/berry/v2/default/yarn.lock">2.x</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/js-yarn/berry/v3/default/yarn.lock">3.x</a>
      </td>
    </tr>
    <tr>
      <td>Poetry</td>
      <td>v1</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/qa/fixtures/python-poetry/default/poetry.lock">1.x</a>
      </td>
    </tr>
    <tr>
      <td>uv</td>
      <td>v0.x</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/master/scanner/parser/uv/fixtures/simple/uv.lock">0.x</a>
      </td>
    </tr>
  </tbody>
</table>

**脚注**：

1. 对 NuGet 第 2 版锁定文件的支持在极狐GitLab 16.2 中引入。
1. 对 Yarn 第 4 版的支持在极狐GitLab 16.11 中引入。

   以下特性对 Yarn Berry 不支持：

   - 工作区
   - `yarn patch`

   包含补丁或工作区或两者皆有的 Yarn 文件仍会被处理，但这些特性将被忽略。

<a id="obtaining-dependency-information-by-running-a-package-manager-to-generate-a-parsable-file"></a>

#### 通过运行包管理器生成可解析文件以获取依赖项信息

为了支持以下包管理器，极狐GitLab 分析器按两个步骤进行：

1. 执行包管理器或特定任务，导出依赖项信息。
1. 解析导出的依赖项信息。

<table class="ds-table no-vertical-table-lines">
  <thead>
    <tr>
      <th>包管理器</th>
      <th>预安装版本</th>
      <th>测试版本</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>sbt</td>
      <td><a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium-maven/debian/config/.tool-versions#L4">1.6.2</a></td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L794-798">1.1.6</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L800-805">1.2.8</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L722-725">1.3.12</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L722-725">1.4.6</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L742-746">1.5.8</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L748-762">1.6.2</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L764-768">1.7.3</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L770-774">1.8.3</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L776-781">1.9.6</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/.gitlab/ci/gemnasium-maven.gitlab-ci.yml#L111-121">1.9.7</a>
      </td>
    </tr>
    <tr>
      <td>maven</td>
      <td><a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.3.1/build/gemnasium-maven/debian/config/.tool-versions#L3">3.9.8</a></td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.3.1/spec/gemnasium-maven_image_spec.rb#L92-94">3.9.8</a><sup>1</sup>
      </td>
    </tr>
    <tr>
      <td>Gradle</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium-maven/debian/config/.tool-versions#L5">6.7.1</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium-maven/debian/config/.tool-versions#L5">7.6.4</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium-maven/debian/config/.tool-versions#L5">8.8</a><sup>2</sup>
      </td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L316-321">5.6</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L323-328">6.7</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L330-335">6.9</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L337-341">7.6</a>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-maven_image_spec.rb#L343-347">8.8</a>
      </td>
    </tr>
    <tr>
      <td>setuptools</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.4.1/build/gemnasium-python/requirements.txt#L41">70.3.0</a>
      </td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.4.1/spec/gemnasium-python_image_spec.rb#L294-316">&gt;= 70.3.0</a>
      </td>
    </tr>
    <tr>
      <td>pip</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium-python/debian/Dockerfile#L21">24</a>
      </td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-python_image_spec.rb#L77-90">24</a>
      </td>
    </tr>
    <tr>
      <td>Pipenv</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium-python/requirements.txt#L23">2023.11.15</a>
      </td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-python_image_spec.rb#L243-256">2023.11.15</a><sup>3</sup>,
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/spec/gemnasium-python_image_spec.rb#L219-241">2023.11.15</a>
      </td>
    </tr>
    <tr>
      <td>Go</td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium/alpine/Dockerfile#L91-93">1.21</a>
      </td>
      <td>
        <a href="https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium/-/blob/v5.2.14/build/gemnasium/alpine/Dockerfile#L91-93">1.21</a><sup>4</sup>
      </td>
    </tr>
  </tbody>
</table>

**脚注**：

1. 该测试使用 `.tool-versions` 文件指定的默认 maven 版本。
1. 不同版本的 Java 需要不同版本的 Gradle。上表中列出的 Gradle 版本已预装在分析器镜像中。分析器使用的 Gradle 版本取决于你的项目是否使用了 `gradlew`（Gradle wrapper）文件：
   - 如果你的项目未使用 `gradlew` 文件，分析器会根据 `DS_JAVA_VERSION` 变量指定的 Java 版本（默认版本为 17）自动切换到其中某个预装的 Gradle 版本。

     对于 Java 8 和 11，自动选择 Gradle 6.7.1；Java 17 使用 Gradle 7.6.4；Java 21 使用 Gradle 8.8。
   - 如果你的项目使用了 `gradlew` 文件，分析器镜像中预装的 Gradle 版本将被忽略，并使用你的 `gradlew` 文件中指定的版本。
1. 该测试确认如果找到了 `Pipfile.lock` 文件，Gemnasium 会使用它来扫描该文件中列出的确切包版本。
1. 由于 `go build` 的实现方式，Go 构建过程需要网络访问、使用 `go mod download` 预加载的模块缓存，或者使用 vendor 化的依赖。更多信息，请参阅[关于编译包和依赖的 Go 文档](https://pkg.go.dev/cmd/go#hdr-Compile_packages_and_dependencies)。

<a id="how-analyzers-are-triggered"></a>

## 分析器如何触发

极狐GitLab 依赖 [`rules:exists`](../../../../ci/yaml/_index.md#rulesexists) 来为根据仓库中[supported files](#supported-languages-and-package-managers)的存在而检测到的语言启动相应的分析器。
最多搜索仓库根目录下两级目录。例如，如果仓库包含 `Gemfile`、`api/Gemfile` 或 `api/client/Gemfile`，则启用 `gemnasium-dependency_scanning` Job，但如果唯一支持的依赖文件是 `api/v1/client/Gemfile`，则不会启用。

<a id="how-multiple-files-are-processed"></a>

## 如何处理多个文件

> [!note]
> 如果你在扫描多个文件时遇到问题，请贡献一条评论到
> 该议题。

<a id="python"></a>

### Python

极狐GitLab 仅在检测到 requirements 文件或锁定文件的目录中执行一次安装。依赖项仅由 `gemnasium-python` 针对检测到的第一个文件进行分析。按以下顺序搜索文件：

1. `requirements.txt`、`requirements.pip` 或 `requires.txt`，适用于使用 Pip 的项目。
1. `Pipfile` 或 `Pipfile.lock`，适用于使用 Pipenv 的项目。
1. `poetry.lock`，适用于使用 Poetry 的项目。
1. `setup.py`，适用于使用 Setuptools 的项目。

搜索从根目录开始，如果根目录中未发现构建文件，则继续在子目录中搜索。因此，根目录中的 Poetry 锁定文件会先于子目录中的 Pipenv 文件被检测到。

<a id="java-and-scala"></a>

### Java 和 Scala

极狐GitLab 仅在检测到构建文件的目录中执行一次构建。对于包含多个 Gradle、Maven 或 sbt 构建，或这些构建的任意组合的大型项目，`gemnasium-maven` 仅分析检测到的第一个构建文件的依赖项。按以下顺序搜索构建文件：

1. `pom.xml`，适用于单模块或[多模块](https://maven.apache.org/pom.html#Aggregation) Maven 项目。
1. `build.gradle` 或 `build.gradle.kts`，适用于单项目或[多项目](https://docs.gradle.org/current/userguide/intro_multi_project_builds.html) Gradle 构建。
1. `build.sbt`，适用于单项目或[多项目](https://www.scala-sbt.org/1.x/docs/Multi-Project.html) sbt 构建。

搜索从根目录开始，如果根目录中未发现构建文件，则继续在子目录中搜索。因此，根目录中的 sbt 构建文件会先于子目录中的 Gradle 构建文件被检测到。
对于[多模块](https://maven.apache.org/pom.html#Aggregation) Maven 项目，以及多项目 [Gradle](https://docs.gradle.org/current/userguide/intro_multi_project_builds.html) 和 [sbt](https://www.scala-sbt.org/1.x/docs/Multi-Project.html) 构建，如果在父构建文件中声明了子模块和子项目文件，则会对其进行分析。

<a id="javascript"></a>

### JavaScript

将执行以下分析器，它们在处理多个文件时有不同的行为：

- [Gemnasium](https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium)

  支持多个锁定文件
- [Retire.js](https://retirejs.github.io/retire.js/)

  不支持多个锁定文件。当存在多个锁定文件时，`Retire.js` 会分析在按字母顺序遍历目录树时发现的第一个锁定文件。

`gemnasium` 分析器会扫描 JavaScript 项目中的 vendor 化库（即签入项目但不由包管理器管理的库）。

<a id="go"></a>

### Go

支持多个文件。当检测到 `go.mod` 文件时，分析器会尝试使用[最小版本选择](https://go.dev/ref/mod#glos-minimal-version-selection)生成[构建列表](https://go.dev/ref/mod#glos-build-list)。如果失败，分析器会转而尝试解析 `go.mod` 文件中的依赖项。

作为必要条件，应使用 `go mod tidy` 命令清理 `go.mod` 文件，以确保依赖项得到正确管理。对每个检测到的 `go.mod` 文件重复此过程。

<a id="php-c-c++-net-c#-ruby-javascript"></a>

### PHP、C、C++、.NET、C#、Ruby、JavaScript

这些语言的分析器支持多个锁定文件。

<a id="support-for-additional-languages"></a>

### 对其他语言的支持

对其他语言、依赖管理器和依赖文件的支持跟踪在以下议题中：

| 包管理器    | 语言 | 支持的文件 | 扫描工具 | 议题 |
| ------------------- | --------- | --------------- | ---------- | ----- |
| [Poetry](https://python-poetry.org/) | Python | `pyproject.toml` | [Gemnasium](https://jihulab.com/gitlab-cn/security-products/analyzers/gemnasium) | GitLab#32774 |

<a id="warnings"></a>

## 警告

使用所有容器的最新版本，以及所有包管理器和语言的最新支持版本。使用旧版本会增加安全风险，因为不受支持的版本可能不再受益于主动的安全报告和安全修复的反向移植。

<a id="gradle-projects"></a>

### Gradle 项目

为 Gradle 项目生成 HTML 依赖报告时，请勿覆盖 `reports.html.destination` 或 `reports.html.outputLocation` 属性。这样做会导致依赖扫描无法正常运行。

<a id="maven-projects"></a>

### Maven 项目

在隔离网络中，如果中央仓库是私有镜像仓库（使用 `<mirror>` 指令显式设置），Maven 构建可能会找不到 `gemnasium-maven-plugin` 依赖。出现此问题是因为 Maven 默认不搜索本地仓库（`/root/.m2`），而是尝试从中央仓库获取。结果会报错缺少依赖项。

<a id="workaround"></a>

#### 变通方案

要解决此问题，请在 `settings.xml` 文件中添加一个 `<pluginRepositories>` 部分。这将允许 Maven 在本地仓库中查找插件。

在开始之前，请注意以下事项：

- 此变通方案仅适用于默认的 Maven 中央仓库被镜像到私有镜像仓库的环境。
- 应用此变通方案后，Maven 会在本地仓库中搜索插件，这在某些环境中可能带来安全影响。请确保这符合你的组织安全策略。

先决条件：

- 项目的维护者或所有者角色。

请按照以下步骤修改 `settings.xml` 文件：

1. 找到你的 Maven `settings.xml` 文件。该文件通常位于以下位置之一：

   - `/root/.m2/settings.xml`（root 用户）。
   - `~/.m2/settings.xml`（普通用户）。
   - `${maven.home}/conf/settings.xml` 全局设置。

1. 检查文件中是否已存在 `<pluginRepositories>` 部分。
1. 如果已存在 `<pluginRepositories>` 部分，只需在其中添加以下 `<pluginRepository>` 元素。
   否则，添加整个 `<pluginRepositories>` 部分：

   ```xml
     <pluginRepositories>
       <pluginRepository>
           <id>local2</id>
           <name>本地仓库</name>
           <url>file:///root/.m2/repository/</url>
       </pluginRepository>
     </pluginRepositories>
   ```

1. 再次运行 Maven 构建或依赖扫描过程。

<a id="python-projects"></a>

### Python 项目

使用 [`PIP_EXTRA_INDEX_URL`](https://pipenv.pypa.io/en/latest/indexes.html) 环境变量时需要格外小心，因为 [CVE-2018-20225](https://nvd.nist.gov/vuln/detail/CVE-2018-20225) 记录了一个可能的攻击：

> [!warning]
> 在 pip（所有版本）中发现了一个问题，因为它会安装版本号最高的版本，即使用户原本打算从私有索引获取私有包。这仅影响 `PIP_EXTRA_INDEX_URL` 选项的使用，并且攻击要求该包在公共索引中尚不存在（因此攻击者可以以任意版本号将其放在那里）。

<a id="version-number-parsing"></a>

### 版本号解析

在某些情况下，无法确定项目依赖的版本是否在安全公告的受影响范围内。

例如：

- 版本未知。
- 版本无效。
- 解析版本或将其与范围进行比较失败。
- 版本是分支，例如 `dev-master` 或 `1.5.x`。
- 比较的版本模糊不清。例如，`1.0.0-20241502` 无法与 `1.0.0-2` 比较，因为一个版本包含时间戳，而另一个不包含。

在这些情况下，分析器会跳过该依赖项，并在日志中输出一条消息。

极狐GitLab 分析器不做任何假设，因为这可能导致误报或漏报。相关讨论，请参见议题 442027。

<a id="build-swift-projects"></a>

## 构建 Swift 项目

Swift 包管理器（SPM）是用于管理 Swift 代码分发的官方工具。
它集成到 Swift 构建系统中，可自动执行下载、编译和链接依赖项的过程。

在使用 SPM 构建 Swift 项目时，请遵循以下最佳实践。

1. 包含一个 `Package.resolved` 文件。

   `Package.resolved` 文件将依赖项锁定到特定版本。
   始终将此文件提交到仓库，以确保跨不同环境的一致性。

   ```shell
   git add Package.resolved
   git commit -m "添加 Package.resolved 以锁定依赖项"
   ```

1. 要构建 Swift 项目，请使用以下命令：

   ```shell
   # 更新依赖项
   swift package update

   # 构建项目
   swift build
   ```

1. 要配置 CI/CD，请将这些步骤添加到 `.gitlab-ci.yml` 文件中：

   ```yaml
   swift-build:
     stage: build
     script:
       - swift package update
       - swift build
   ```

1. 可选。如果你使用带有自签名证书的私有 Swift 包仓库，
   你可能需要将证书添加到项目中，并配置 Swift 信任该证书：

   1. 获取证书：

      ```shell
      echo | openssl s_client -servername 你的.repo.url -connect 你的.repo.url:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END
      CERTIFICATE-/p' > repo-cert.crt
      ```

   1. 在 Swift 包清单文件（`Package.swift`）中添加以下行：

      ```swift
      import Foundation

      #if canImport(Security)
      import Security
      #endif

      extension Package {
          public static func addCustomCertificate() {
              guard let certPath = Bundle.module.path(forResource: "repo-cert", ofType: "crt") else {
                  fatalError("证书未找到")
              }
              SecCertificateAddToSystemStore(SecCertificateCreateWithData(nil, try! Data(contentsOf: URL(fileURLWithPath: certPath)) as CFData)!)
          }
      }

      // 在定义你的包之前调用此方法
      Package.addCustomCertificate()
      ```

始终在干净的环境中测试构建过程，以确保依赖项已正确指定并能自动解析。

<a id="build-cocoapods-projects"></a>

## 构建 CocoaPods 项目

CocoaPods 是 Swift 和 Objective-C Cocoa 项目的流行依赖管理器。它为管理 iOS、macOS、watchOS 和 tvOS 项目中的外部库提供了标准格式。

在使用 CocoaPods 进行依赖管理构建项目时，请遵循以下最佳实践。

1. 包含一个 `Podfile.lock` 文件。

   `Podfile.lock` 文件对于将依赖项锁定到特定版本至关重要。始终将此文件提交到仓库，以确保跨不同环境的一致性。

   ```shell
   git add Podfile.lock
   git commit -m "添加 Podfile.lock 以锁定 CocoaPods 依赖项"
   ```

1. 你可以使用以下方法之一构建项目：

   - `xcodebuild` 命令行工具：

     ```shell
     # 安装 CocoaPods 依赖项
     pod install

     # 构建项目
     xcodebuild -workspace YourWorkspace.xcworkspace -scheme YourScheme build
     ```

   - Xcode IDE：

     1. 在 Xcode 中打开 `.xcworkspace` 文件。
     1. 选择目标 scheme。
     1. 选择 **Product** > **Build**。你也可以按 <kbd>⌘</kbd>+<kbd>B</kbd>。
   - [fastlane](https://fastlane.tools/)，一款用于自动化 iOS 和 Android 应用构建和发布的工具：

     1. 安装 `fastlane`：

        ```shell
        sudo gem install fastlane
        ```

     1. 在项目中配置 `fastlane`：

        ```shell
        fastlane init
        ```

     1. 在 `fastfile` 中添加一个 lane：

        ```ruby
        lane :build do
          cocoapods
          gym(scheme: "YourScheme")
        end
        ```

     1. 运行构建：

        ```shell
        fastlane build
        ```

   - 如果你的项目同时使用了 CocoaPods 和 Carthage，你可以使用 Carthage 来构建依赖项：

     1. 创建一个包含 CocoaPods 依赖项的 `Cartfile`。
     1. 运行以下命令：

        ```shell
        carthage update --platform iOS
        ```

1. 根据你首选的方法配置 CI/CD 来构建项目。

   例如，使用 `xcodebuild`：

   ```yaml
   cocoapods-build:
     stage: build
     script:
       - pod install
       - xcodebuild -workspace YourWorkspace.xcworkspace -scheme YourScheme build
   ```

1. 可选。如果你使用私有 CocoaPods 仓库，
   你可能需要配置项目以访问它们：

   1. 添加私有 spec 仓库：

      ```shell
      pod repo add REPO_NAME SOURCE_URL
      ```

   1. 在 Podfile 中，指定源：
      ```ruby
      source 'https://github.com/CocoaPods/Specs.git'
      source 'SOURCE_URL'
      ```

1. 可选。如果你的私有 CocoaPods 仓库使用 SSL，请确保 SSL 证书配置正确：

   - 如果你使用自签名证书，请将其添加到系统的信任证书中。
     你也可以在 `.netrc` 文件中指定 SSL 配置：

     ```netrc
     machine your.private.repo.url
       login your_username
       password your_password
     ```

1. 更新 Podfile 后，运行 `pod install` 来安装依赖并更新工作空间。

请记住，在更新 Podfile 后务必运行 `pod install`，以确保所有依赖正确安装且工作空间已更新。

<a id="contributing-to-the-vulnerability-database"></a>

## 向漏洞数据库贡献

要查找漏洞，你可以搜索 [`极狐GitLab 安全公告数据库`](https://advisories.gitlab.com/)。
你也可以 [提交新漏洞](https://jihulab.com/gitlab-cn/security-products/gemnasium-db/blob/master/CONTRIBUTING.md)。