---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线密钥检测
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

流水线密钥检测会在文件提交到 Git 代码仓库并推送到极狐GitLab 后扫描这些文件。

在您[启用流水线密钥检测](#getting-started)后，扫描会在名为 `secret_detection`的 CI/CD 作业中运行。您可以在任何极狐GitLab 版本中运行扫描并查看[流水线密钥检测 JSON 报告产物](../../../../ci/yaml/artifacts_reports.md#artifactsreportssecret_detection)。

使用极狐GitLab 旗舰版时，还会处理流水线密钥检测结果，以便您可以：

- 在[合并请求报告](../../../project/merge_requests/reports.md)、[流水线安全报告](../../detect/security_scanning_results.md)和[漏洞报告](../../vulnerability_report/_index.md)中查看这些结果。
- 在审批工作流中使用这些结果。
- 在安全仪表板中审查这些结果。
- [自动响应](../automatic_response.md)公共代码仓库中的泄露。
- 使用[安全策略](../../policies/_index.md)在各项目中强制执行一致的密钥检测规则。

<a id="availability"></a>

## 可用性

不同的功能在不同的[极狐GitLab 版本](https://gitlab.cn/pricing)中可用。

| 能力                                                              | 在基础版和专业版中 | 在旗舰版中 |
|:------------------------------------------------------------------------|:------------------|:------------|
| [自定义分析器行为](configure.md#customize-analyzer-behavior) | {{< yes >}}       | {{< yes >}} |
| 下载[输出](#secret-detection-results)                            | {{< yes >}}       | {{< yes >}} |
| 在合并请求报告中查看新发现                               | {{< no >}}        | {{< yes >}} |
| 在流水线的 **安全** 标签页中查看识别出的密钥              | {{< no >}}        | {{< yes >}} |
| [管理漏洞](../../vulnerability_report/_index.md)          | {{< no >}}        | {{< yes >}} |
| [访问安全仪表板](../../security_dashboard/_index.md)     | {{< no >}}        | {{< yes >}} |
| [自定义分析器规则集](configure.md#customize-analyzer-rulesets) | {{< no >}}        | {{< yes >}} |
| [启用安全策略](../../policies/_index.md)                    | {{< no >}}        | {{< yes >}} |

<a id="getting-started"></a>

## 开始使用

要开始使用流水线密钥检测，请选择一个试点项目并启用分析器。

先决条件：

- 您有一个基于 Linux 的 runner，使用 [`docker`](https://gitlab.cn/docs/runner/executors/docker/) 或
  [`kubernetes`](https://gitlab.cn/docs/runner/install/kubernetes/) executor。
  如果您为 JihuLab.com 使用托管 runner，则默认已启用。
  - 不支持 Windows runner。
  - 不支持 amd64 以外的 CPU 架构。
- 您有一个包含 `test` 阶段的 `.gitlab-ci.yml` 文件。

使用以下任一方式启用密钥检测分析器：

- 手动编辑 `.gitlab-ci.yml` 文件。如果您的 CI/CD 配置较为复杂，请使用此方法。
- 使用自动配置的合并请求。如果您没有 CI/CD 配置，或配置非常简单，请使用此方法。
- 在[扫描执行策略](../../policies/scan_execution_policies.md)中启用流水线密钥检测。

如果这是您首次在项目中运行密钥检测扫描，应在启用分析器后立即运行历史扫描。

启用流水线密钥检测后，您可以[自定义分析器设置](configure.md)。

<a id="edit-the-gitlab-ciyml-file-manually"></a>

### 手动编辑 `.gitlab-ci.yml` 文件

此方法要求您手动编辑现有的 `.gitlab-ci.yml` 文件。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线编辑器**。
1. 复制以下内容并粘贴到 `.gitlab-ci.yml` 文件的底部：

   ```yaml
   include:
     - template: Jobs/Secret-Detection.gitlab-ci.yml
   ```

1. 选择 **验证** 标签页，然后选择 **验证流水线**。
   消息 **模拟成功完成** 表示该文件有效。
1. 选择 **编辑** 标签页。
1. 可选。在 **提交信息** 文本框中，自定义提交消息。
1. 在 **分支** 文本框中，输入默认分支的名称。
1. 选择 **提交更改**。

流水线现在包含一个流水线密钥检测作业。启用分析器后，请考虑[运行历史扫描](#run-a-historic-scan)。

<a id="use-an-automatically-configured-merge-request"></a>

### 使用自动配置的合并请求

此方法会自动准备一个合并请求，以添加包含流水线密钥检测模板的 `.gitlab-ci.yml` 文件。合并该合并请求以启用流水线密钥检测。

要启用流水线密钥检测：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**流水线密钥检测**行中，选择**使用合并请求配置**。
1. 可选。填写各字段。
1. 选择**创建合并请求**。
1. 审查并合并该合并请求。

流水线现在包含一个流水线密钥检测作业。

<a id="coverage"></a>

## 覆盖范围

流水线密钥检测经过优化，以平衡覆盖范围和运行时间。仅扫描代码仓库的当前状态和未来的提交以查找密钥。要识别代码仓库历史中已存在的密钥，请在启用流水线密钥检测后运行一次历史扫描。扫描结果仅在流水线完成后才可用。

具体扫描哪些内容以查找密钥取决于流水线的类型，以及是否设置了任何附加配置。

默认情况下，当您运行流水线时：

- 在分支上：
  - 在**默认分支**上：
    - 在分析器版本 `v7.38.1` 及更高版本中，如果可以通过[预定义 CI/CD 变量](../../../../ci/variables/predefined_variables.md) `CI_COMMIT_BEFORE_SHA` 获取有效的先前提交，则会扫描从该先前提交到当前提交的所有提交的内容。
    - 如果没有可用的有效先前提交（例如，推送到新代码仓库的第一个提交），则扫描 Git 工作树的内容。
  - 在**功能分支**上：
    - 在分析器版本 `v7.35.0` 及更高版本中，会扫描从合并
      基点到最后一次提交的内容（分支分叉后该分支独有的所有提交）。
      当合并基点可用时，此行为适用于所有功能分支流水线。
    - 极狐GitLab 19.1 及更高版本通过[预定义 CI 变量](../../../../ci/variables/predefined_variables.md) `CI_COMMIT_DEFAULT_BRANCH_BASE_SHA` 公开合并基点 SHA。
    - 在低于 19.1 的极狐GitLab 版本上，或当合并基点不可用时，分析器
      会回退到之前的行为：
      - 在新的功能分支上，仅扫描最新的提交。该分支上更早的提交不会包含在扫描中。
      - 在现有的功能分支上，扫描从最后推送的提交之后到最新提交的所有提交。

    > [!note]
    > 要每次都扫描从分支分叉点开始的所有提交，请启用
    > [合并请求流水线](../../../../ci/pipelines/merge_request_pipelines.md)。
- 在**合并请求**上，会扫描该分支上所有提交的内容。如果分析器无法访问每个提交，
  则会扫描从父提交到最新提交的所有提交的内容。要扫描所有提交，您必须启用
  [合并请求流水线](../../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。

要覆盖默认行为，请使用[可用的 CI/CD 变量](configure.md#available-cicd-variables)。

<a id="how-the-analyzer-fetches-commits"></a>

### 分析器如何获取提交

默认情况下，当极狐GitLab 首次克隆代码仓库时，它仅获取最近的提交（“浅克隆”）。当在此初始克隆之外需要更多提交时，分析器会使用优化的策略自动获取它们：

- 对于合并请求，分析器仅检索合并基点之后提交的更改，从而最大限度地减少数据传输。
- 如果指定了日志选项，例如 `--since` 或 `--max-count`，分析器仅获取所需的提交。
- 在历史扫描期间，分析器会获取完整的代码仓库历史。如果代码仓库是浅克隆的，分析器会使用 `--unshallow` 选项。

如果分析器无法获取所需的提交，它会回退到扫描可用的数据：

- 在强制推送之后，分析器仅扫描代码仓库的当前状态。
- 如果出现网络故障，分析器会扫描初始克隆后可用的提交。
- 如果出现超时，分析器会使用部分提交历史继续扫描。

这些回退机制可确保您的流水线即使在受限环境中也能成功完成。

<a id="initial-repository-clone-depth"></a>

### 初始代码仓库克隆深度

runner 的 [`GIT_DEPTH`](../../../../ci/runners/configure_runners.md#shallow-cloning) 控制初始克隆多少个提交。流水线密钥检测会在需要时自动获取额外的提交，因此您通常无需调整此设置。

如果您在受限网络环境中遇到提交缺失的持续问题，请参阅故障排除部分了解变通方法。

<a id="run-a-historic-scan"></a>

### 运行历史扫描

默认情况下，流水线密钥检测仅扫描 Git 代码仓库的当前状态。代码仓库历史中包含的任何密钥都不会被检测到。运行历史扫描以检查 Git 代码仓库中所有提交和分支的密钥。

您应仅在启用流水线密钥检测后运行一次历史扫描。历史扫描可能耗时很长，尤其是对于具有冗长 Git 历史的大型代码仓库。在完成初始历史扫描后，仅将标准流水线密钥检测作为您流水线的一部分使用。

如果您使用[扫描执行策略](../../policies/scan_execution_policies.md#scanner-behavior)启用流水线密钥检测，则默认情况下第一次计划扫描就是历史扫描。

要运行历史扫描：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择**新建流水线**。
1. 添加一个 CI/CD 变量：
   1. 从下拉列表中，选择 **变量**。
   1. 在 **输入变量的名称** 框中，输入 `SECRET_DETECTION_HISTORIC_SCAN`。
   1. 在 **输入变量的值** 框中，输入 `true`。
1. 选择**新建流水线**。

<a id="duplicate-vulnerability-tracking"></a>

### 重复漏洞跟踪

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

密钥检测使用高级漏洞跟踪算法，以防止在文件被重构或移动时创建重复的发现和漏洞。

在以下情况下不会创建新的发现：

- 密钥在文件内被移动。
- 文件内出现重复的密钥。

重复漏洞跟踪基于每个文件进行。如果同一个密钥出现在两个不同的文件中，则会创建两个发现。

有关更多信息，请参阅机密项目 `https://gitlab.com/gitlab-org/security-products/post-analyzers/tracking-calculator`。该项目仅对 GitLab 团队成员可用。

<a id="unsupported-workflows"></a>

#### 不支持的工作流

重复漏洞跟踪不支持以下工作流：

- 现有发现缺少跟踪签名，且与新发现的位置不同。
- 某些密钥是通过搜索其前缀而非整个密钥值来检测的。对于这些密钥类型，同一文件中同一类型的所有检测结果都会报告为单个发现。

  例如，SSH 私钥是通过其前缀 `-----BEGIN OPENSSH PRIVATE KEY-----` 检测的。如果同一文件中有多个 SSH 私钥，
  流水线密钥检测只会创建一个发现。
- 在运行历史扫描或在现有提交上启用流水线密钥检测时，如果某个密钥在一个提交中引入，然后在同一次扫描的后续提交中被修改，则漏洞报告中只会显示最新的密钥值。

<a id="detected-secrets"></a>

### 检测到的密钥

流水线密钥检测会扫描代码仓库的内容以查找特定模式。每个模式匹配一种特定类型的密钥，并通过 TOML 语法在规则中指定。极狐GitLab 维护默认的规则集。

使用极狐GitLab 旗舰版，您可以扩展这些规则以满足您的需求。例如，虽然使用自定义前缀的个人访问令牌默认不会被检测到，但您可以自定义规则来识别这些令牌。有关详细信息，请参阅[自定义分析器规则集](configure.md#customize-analyzer-rulesets)。

要确认流水线密钥检测会检测哪些密钥，请参阅[检测到的密钥](../detected_secrets.md)。为了提供可靠、高置信度的结果，流水线密钥检测仅在特定上下文（如 URL）中查找密码或其他非结构化密钥。

当检测到密钥时，会为其创建一个漏洞。即使该密钥已从扫描的文件中移除，并且流水线密钥检测已再次运行，该漏洞仍会保持为“仍检测到”。这是因为泄露的密钥在被撤销之前仍然是安全风险。已移除的密钥也会保留在 Git 历史中。要从 Git 代码仓库的历史中移除密钥，请参阅[从代码仓库中删除文本](../../../project/repository/repository_size.md#redact-text-from-repository)。

<a id="excluded-items"></a>

### 排除的项

为了提高性能，流水线密钥检测会自动排除某些包含密钥可能性较低的文件类型和目录。

以下项会被排除：

| 类别                            | 排除的项                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|-------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 配置文件             | 文件：`gitleaks.toml`、`verification-metadata.xml`、`Database.refactorlog`、`.editorconfig`、`.gitattributes`                                                                                                                                                                                                                                                                                                                                             |
| 媒体和二进制文件           | 扩展名：`.bmp`、`.gif`、`.svg`、`.jpg/.jpeg`、`.png`、`.tiff/.tif`、`.webp`、`.ico`、`.heic`<br/>字体：`.eot`、`.otf`、`.ttf`、`.woff`、`.woff2`<br/>文档：`.doc/.docx`、`.xls/.xlsx`、`.ppt/.pptx`、`.pdf`<br/>音频/视频：`.mp3`、`.mp4`、`.wav`、`.flac`、`.aac`、`.ogg`、`.avi`、`.mkv`、`.mov`、`.wmv`、`.flv`、`.webm`<br/>归档文件：`.zip`、`.rar`、`.7z`、`.tar`、`.gz`、`.bz2`、`.xz`、`.dmg`、`.iso`<br/>可执行文件：`.exe`、`.gltf` |
| Visual Studio 文件             | 扩展名：`.socket`、`.vsidx`、`.suo`、`.wsuo`、`.dll`、`.pdb`                                                                                                                                                                                                                                                                                                                                                                                           |
| 软件包锁定文件              | 文件：`deno.lock`、`npm-shrinkwrap.json`、`package-lock.json`、`pnpm-lock.yaml`、`yarn.lock`、`Pipfile.lock`、`poetry.lock`、`gradle.lockfile`、`Cargo.lock`、`composer.lock`                                                                                                                                                                                                                                                                             |
| Go 语言文件               | 扩展名：`go.mod`、`go.sum`、`go.work`、`go.work.sum`<br/>目录：`vendor/`（仅适用于来自 `github.com`、`golang.org`、`google.golang.org`、`gopkg.in`、`istio.io`、`k8s.io`、`sigs.k8s.io`的 Go 模块）<br/>文件：`vendor/modules.txt`                                                                                                                                                                                                            |
| Ruby 文件                      | 目录：`.bundle/`、`gems/`、`specifications/`<br/>扩展名：`gems/` 目录中的 `.gem` 文件、`specifications/` 目录中的 `.gemspec` 文件                                                                                                                                                                                                                                                                                                     |
| 构建工具包装器             | 文件：`gradlew`、`gradlew.bat`、`mvnw`、`mvnw.cmd`<br/>目录：`.mvn/wrapper/`<br/>特定：Maven wrapper 目录中的 `MavenWrapperDownloader.java`                                                                                                                                                                                                                                                                                                |
| 依赖目录          | 目录：`node_modules/`、`bower_components/`、`packages/`                                                                                                                                                                                                                                                                                                                                                                                             |
| 构建输出目录        | 目录：`target/`、`build/`、`bin/`、`obj/`                                                                                                                                                                                                                                                                                                                                                                                                           |
| Vendor 目录             | 目录：`vendor/bundle/`、`vendor/ruby/`、`vendor/composer/`                                                                                                                                                                                                                                                                                                                                                                                          |
| Python 缓存文件              | 扩展名：`.pyc`、`.pyo`<br/>目录：`__pycache__/`                                                                                                                                                                                                                                                                                                                                                                                                 |
| Python 工具缓存              | 目录：`.pytest_cache/`、`.mypy_cache/`、`.tox/`                                                                                                                                                                                                                                                                                                                                                                                                     |
| Python 虚拟环境     | 目录：`venv/`、`virtualenv/`、`.venv/`、`env/`                                                                                                                                                                                                                                                                                                                                                                                                      |
| Python 安装目录 | 目录：`lib/python[version]/`、`lib64/python[version]/`、`python[version]/lib/`、`python[version]/Lib/`                                                                                                                                                                                                                                                                                                                                              |
| Python 软件包元数据        | 以版本号和 `.dist-info` 结尾的软件包名称                                                                                                                                                                                                                                                                                                                                                                                                         |
| JavaScript 库            | 文件：`angular*.js`、`bootstrap*.js`、`jquery*.js`、`jquery-ui*.js`、`plotly*.js`、`swagger-ui*.js` <br/>Source Map：对应的 `.js.map` 文件                                                                                                                                                                                                                                                                                                       |
| 压缩/打包的资源         | 扩展名：`.min.js`、`.min.css`、`.bundle.js`、`.bundle.css`、`.map`（source map 文件）                                                                                                                                                                                                                                                                                                                                                                  |
| 编译文件                  | 扩展名：`.class`、`.o`、`.obj`、`.jar`、`.war`（Web 归档）、`.ear`                                                                                                                                                                                                                                                                                                                                                                                   |
| 缓存目录             | 目录：`.cache/`、`.coverage/`、`.pytest_cache/`、`.mypy_cache/`、`.tox/`                                                                                                                                                                                                                                                                                                                                                                            |
| 生成的文档         | 目录：`htmlcov/`、`coverage/`、`_build/`、`_site/`、`docs/_build/`                                                                                                                                                                                                                                                                                                                                                                                  |
| 版本控制和 IDE           | 目录：`.git/`、`.svn/`、`.hg/`、`.bzr/`（版本控制）、`.vscode/`、`.idea/`、`.eclipse/`、`.vs/`（IDE）                                                                                                                                                                                                                                                                                                                                         |
| 操作系统文件          | 文件：`.DS_Store`、`Thumbs.db`                                                                                                                                                                                                                                                                                                                                                                                                                            |

<a id="secret-detection-results"></a>

## 密钥检测结果

流水线密钥检测会输出文件 `gl-secret-detection-report.json` 作为作业产物。该文件包含检测到的密钥。您可以[下载](../../../../ci/jobs/job_artifacts.md#download-job-artifacts)该文件以在极狐GitLab 之外进行处理。

有关更多信息，请参阅[报告文件架构](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/blob/master/dist/secret-detection-report-format.json)和[示例报告文件](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/blob/master/qa/expect/secrets/gl-secret-detection-report.json)。

<a id="additional-output"></a>

### 附加输出

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

作业结果还会报告在：

- [合并请求报告](../../../project/merge_requests/reports.md)：显示合并请求中引入的新发现。
- [流水线安全报告](../../detect/security_scanning_results.md)：显示最近一次流水线运行的所有发现。
- [漏洞报告](../../vulnerability_report/_index.md)：提供对所有安全发现的集中管理。
- 安全仪表板：提供跨项目和群组的所有漏洞的组织级可见性。

<a id="understanding-the-results"></a>

## 理解结果

流水线密钥检测会提供有关在您的代码仓库中发现的潜在密钥的详细信息。每个密钥都包含泄露的密钥类型和修复指南。

审查结果时：

1. 查看周围的代码，以确定检测到的模式是否确实是密钥。
1. 测试检测到的值是否是有效的凭据。
1. 考虑代码仓库的可见性和密钥的范围。
1. 优先处理活跃的、高权限的密钥。

<a id="common-detection-categories"></a>

### 常见检测类别

流水线密钥检测的检测结果通常分为以下三类之一：

- **真阳性**：应轮换并移除的合法密钥。例如：
  - 活跃的 API 密钥、数据库密码、认证令牌
  - 私钥和证书
  - 服务账号凭据
- **误报**：检测到的并非实际密钥的模式。例如：
  - 文档中的示例值
  - 测试数据或模拟凭据
  - 带有占位符值的配置模板
- **历史发现**：之前已提交但可能不再活跃的密钥。这些检测结果：
  - 需要调查以确定当前状态
  - 仍应作为预防措施进行轮换

<a id="remediate-a-leaked-secret"></a>

## 修复泄露的密钥

当检测到密钥时，您应立即轮换它。极狐GitLab 会尝试[自动撤销](../automatic_response.md)某些类型的泄露密钥。对于无法自动撤销的密钥，您必须手动撤销。

[从代码仓库历史中清除密钥](../../../project/repository/repository_size.md#purge-files-from-repository-history)并不能完全解决泄露问题。原始密钥仍会保留在代码仓库的任何现有复刻或克隆中。

有关如何响应泄露密钥的说明，请在漏洞报告中选择该漏洞。

<a id="optimization"></a>

## 优化

在您的组织中部署流水线密钥检测之前，请优化配置以减少误报并提高针对您特定环境的准确性。

误报会导致告警疲劳并降低对该工具的信任。请考虑使用自定义规则集配置（仅限旗舰版）：

- 排除特定于您代码库的已知安全模式。
- 调整经常在非密钥上触发的规则的敏感度。
- 为组织特定的密钥格式添加自定义规则。

要优化大型代码仓库或拥有众多项目的组织的性能，请审查您的：

- 扫描范围管理：
  - 在项目中运行历史扫描后，关闭历史扫描。
  - 在低使用率时段安排历史扫描。
- 资源分配：
  - 为较大的代码仓库分配足够的 runner 资源。
  - 考虑为安全扫描工作负载使用专用 runner。
  - 监控扫描时长并根据代码仓库大小进行优化。

<a id="testing-optimization-changes"></a>

### 测试优化更改

在组织范围内应用优化之前：

1. 验证优化不会遗漏合法密钥。
1. 跟踪误报减少情况和扫描性能改进。
1. 保留有效优化模式的记录。

<a id="roll-out"></a>

## 推广

您应逐步实施流水线密钥检测。先从小规模试点开始，以了解该工具的行为，然后再在整个组织中推广该功能。

在推广流水线密钥检测时，请遵循以下准则：

1. 选择一个试点项目。合适的项目应具备：
   - 有定期提交的活跃开发。
   - 代码库规模可控。
   - 有熟悉极狐GitLab CI/CD 的团队。
   - 愿意迭代配置。
1. 从简单开始。在您的试点项目上使用默认设置启用流水线密钥检测。
1. 监控结果。运行分析器一到两周，以了解典型的发现。
1. 处理检测到的密钥。修复发现的任何合法密钥。
1. 调整您的配置。根据初始结果调整设置。
1. 记录实施情况。记录常见的误报和修复模式。

<a id="fips-enabled-images"></a>

## 启用 FIPS 的镜像

默认扫描器镜像基于 Alpine 基础镜像构建，以兼顾大小和可维护性。极狐GitLab
提供启用 FIPS 的 [Red Hat UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)
版本的镜像。

要使用启用 FIPS 的镜像，请执行以下任一操作：

- 将 `SECRET_DETECTION_IMAGE_SUFFIX` CI/CD 变量设置为 `-fips`。
- 在默认镜像名称中添加 `-fips` 扩展名。

例如：

```yaml
variables:
  SECRET_DETECTION_IMAGE_SUFFIX: '-fips'

include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml
```

<a id="troubleshooting"></a>

## 故障排除

<a id="debug-level-logging"></a>

### 调试级别日志记录

调试级别日志记录在故障排除时可能会有所帮助。有关详细信息，请参阅[调试级别日志记录](../../troubleshooting_application_security.md#turn-on-debug-level-logging)。

<a id="warning-gl-secret-detection-reportjson-no-matching-files"></a>

#### 警告：`gl-secret-detection-report.json: no matching files`

有关此问题的信息，请参阅[通用应用程序安全故障排除部分](../../../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)。

<a id="error-couldnt-run-the-gitleaks-command-exit-status-2"></a>

#### 错误：`Couldn't run the gitleaks command: exit status 2`

此错误表示分析器无法访问所需的提交。虽然分析器在大多数情况下会自动获取缺失的提交，但在受限环境中可能会出现问题。

要诊断该问题，请启用[调试级别日志记录](../../troubleshooting_application_security.md#turn-on-debug-level-logging)并查找：

```plaintext
ERRO[2020-11-18T18:05:52Z] object not found
[ERRO] [secrets] [2020-11-18T18:05:52Z] ▶ Couldn't run the gitleaks command: exit status 2
[ERRO] [secrets] [2020-11-18T18:05:52Z] ▶ Gitleaks analysis failed: exit status 2
```

要解决此问题：

- 在大多数情况下，无需采取任何操作。让分析器自动处理获取。
- 对于受限网络，增加初始克隆深度：

  ```yaml
  secret_detection:
    variables:
      GIT_DEPTH: 100  # or 0 to clone everything
  ```

- 对于大型代码仓库，限制扫描范围：

  ```yaml
  secret_detection:
    variables:
      SECRET_DETECTION_LOG_OPTIONS: "--max-count=50"
  ```

<a id="error-err-fatal-ambiguous-argument"></a>

#### 错误：`ERR fatal: ambiguous argument`

如果您的代码仓库的默认分支与触发该作业的分支无关，流水线密钥检测可能会失败并显示消息 `ERR fatal: ambiguous argument`。有关更多详细信息，请参阅议题
[!352014](https://gitlab.com/gitlab-org/gitlab/-/issues/352014)。

要解决该问题，请确保在您的代码仓库上正确[设置默认分支](../../../project/repository/branches/default.md#change-the-default-branch-name-for-a-project)。您应将其设置为与您运行 `secret-detection` 作业的分支具有相关历史的分支。

<a id="exec-binsh-exec-format-error-message-in-job-log"></a>

#### 作业日志中的 `exec /bin/sh: exec format error` 消息

极狐GitLab 流水线密钥检测分析器[仅支持](#getting-started)在 `amd64` CPU 架构上运行。此消息表示该作业正在其他架构上运行，例如 `arm`。

<a id="error-fatal-detected-dubious-ownership-in-repository-at-builds"></a>

#### 错误：`fatal: detected dubious ownership in repository at '/builds/<project dir>'`

密钥检测可能会失败并返回退出状态 128。这可能是由 Docker 镜像上的用户更改引起的。

例如：

```shell
$ /analyzer run
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ GitLab secrets analyzer v6.0.1
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ Detecting project
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ Analyzer will attempt to analyze all projects in the repository
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ Loading ruleset for /builds....
[WARN] [secrets] [2024-06-06T07:28:13Z] ▶ /builds/....secret-detection-ruleset.toml not found, ruleset support will be disabled.
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ Running analyzer
[FATA] [secrets] [2024-06-06T07:28:13Z] ▶ get commit count: exit status 128
```

要变通解决此问题，请添加一个包含以下内容的 `before_script`：

```yaml
before_script:
    - git config --global --add safe.directory "$CI_PROJECT_DIR"
```

有关此问题的更多信息，请参阅[议题 465974](https://gitlab.com/gitlab-org/gitlab/-/issues/465974)。

<a id="adjusting-git_depth-doesnt-change-what-gets-scanned"></a>

#### 调整 `GIT_DEPTH` 不会改变扫描的内容

这是预期行为。`GIT_DEPTH` 是用于初始克隆的 runner 变量。它不会改变分析器的行为。

密钥检测分析器根据以下内容决定扫描什么：

- 流水线类型（推送、合并请求、计划）
- 分支上下文（默认、新、现有）
- 您的配置（`SECRET_DETECTION_LOG_OPTIONS`、`SECRET_DETECTION_HISTORIC_SCAN`）

例如，要仅扫描 30 个提交：

```yaml
secret_detection:
  variables:
    # Scan the last 30 commits
    SECRET_DETECTION_LOG_OPTIONS: "--max-count=30"
```

要仅扫描过去两周的提交：

```yaml
secret_detection:
  variables:
    # Scan commits made in the last two weeks
    SECRET_DETECTION_LOG_OPTIONS: "--since=2.weeks"
```

要仅扫描从 `HEAD~10` 到 `HEAD`的提交：

```yaml
secret_detection:
  variables:
    # Scan commits from HEAD~10 to HEAD
    SECRET_DETECTION_LOG_OPTIONS: "HEAD~10..HEAD"
```

有关选项的完整列表，请参阅 [Git log 选项](https://git-scm.com/docs/git-log)文档。

<a id="force-push-detection"></a>

#### 强制推送检测

在强制推送之后，您可能会看到：

```plaintext
Failed to retrieve all the commits from the last Git push event due to a force push
```

这是预期行为。扫描会使用当前代码仓库状态继续进行。

<a id="repository-trust-configuration"></a>

#### 代码仓库信任配置

您可能会看到以下消息：

```plaintext
Added project directory to Git safe.directory configuration
```

这表示容器化环境中的典型安全配置。无需采取任何操作。
