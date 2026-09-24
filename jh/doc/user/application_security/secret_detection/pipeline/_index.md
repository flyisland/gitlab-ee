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

流水线密钥检测会在文件提交到 Git 仓库并推送至极狐GitLab 后对其进行扫描。

在[启用流水线密钥检测](#getting-started)后，扫描会在名为 `secret_detection` 的 CI/CD 作业中运行。你可以在任何极狐GitLab 版本中运行扫描并查看[流水线密钥检测 JSON 报告产物](../../../../ci/yaml/artifacts_reports.md#artifactsreportssecret_detection)。

在极狐GitLab 旗舰版中，流水线密钥检测结果还会被进一步处理，以便你可以：

- 在[合并请求部件](../../detect/security_scanning_results.md)、[流水线安全报告](../../detect/security_scanning_results.md)和[漏洞报告](../../vulnerability_report/_index.md)中查看它们。
- 在审批工作流中使用它们。
- 在安全仪表板中审查它们。
- 对公开仓库中的泄露[自动响应](../automatic_response.md)。
- 通过使用[安全策略](../../policies/_index.md)在项目间强制执行一致的密钥检测规则。

## 可用性

不同功能在不同的[极狐GitLab 版本](https://gitlab.cn/pricing/)中提供。

| 功能                                                              | 在基础版和专业版中 | 在旗舰版中 |
|:------------------------------------------------------------------------|:------------------|:------------|
| [自定义分析器行为](configure.md#customize-analyzer-behavior) | {{< yes >}}       | {{< yes >}} |
| 下载[输出](#secret-detection-results)                            | {{< yes >}}       | {{< yes >}} |
| 在合并请求部件中查看新发现                            | {{< no >}}        | {{< yes >}} |
| 在流水线的 **安全** 选项卡中查看已识别的密钥              | {{< no >}}        | {{< yes >}} |
| [管理漏洞](../../vulnerability_report/_index.md)          | {{< no >}}        | {{< yes >}} |
| [访问安全仪表板](../../security_dashboard/_index.md)     | {{< no >}}        | {{< yes >}} |
| [自定义分析器规则集](configure.md#customize-analyzer-rulesets) | {{< no >}}        | {{< yes >}} |
| [启用安全策略](../../policies/_index.md)                    | {{< no >}}        | {{< yes >}} |

<a id="getting-started"></a>

## 快速入门

要开始使用流水线密钥检测，请选择一个试点项目并启用分析器。

先决条件：

- 你有一个基于 Linux 的 Runner，并配置了 [`docker`](https://gitlab.cn/docs/runner/executors/docker/) 或 [`kubernetes`](https://gitlab.cn/docs/runner/install/kubernetes/) 执行器。如果你使用 JihuLab.com 的托管 Runner，则默认已启用此功能。
  - 不支持 Windows Runner。
  - 不支持 amd64 以外的 CPU 架构。
- 你有一个包含 `test` 阶段的 `.gitlab-ci.yml` 文件。

通过以下方式之一启用密钥检测分析器：

- 手动编辑 `.gitlab-ci.yml` 文件。如果你的 CI/CD 配置比较复杂，请使用此方法。
- 使用自动配置的合并请求。如果你没有 CI/CD 配置或配置很简单，请使用此方法。
- 在[扫描执行策略](../../policies/scan_execution_policies.md)中启用流水线密钥检测。

如果这是你第一次在项目上运行密钥检测扫描，你应该在启用分析器后立即运行一次历史扫描。

启用流水线密钥检测后，你可以[自定义分析器设置](configure.md)。

### 手动编辑 `.gitlab-ci.yml` 文件

此方法需要你手动编辑现有的 `.gitlab-ci.yml` 文件。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线编辑器**。
1. 将以下内容复制并粘贴到 `.gitlab-ci.yml` 文件的底部：

   ```yaml
   include:
     - template: Jobs/Secret-Detection.gitlab-ci.yml
   ```

1. 选择 **验证** 选项卡，然后选择 **验证流水线**。消息 **模拟完成，成功** 表示文件有效。
1. 选择 **编辑** 选项卡。
1. 可选。在 **提交信息** 文本框中，自定义提交信息。
1. 在 **分支** 文本框中，输入默认分支的名称。
1. 选择 **提交变更**。

现在流水线中包含一个流水线密钥检测作业。考虑在启用分析器后[运行一次历史扫描](#run-a-historic-scan)。

### 使用自动配置的合并请求

此方法会自动准备一个合并请求，以添加包含流水线密钥检测模板的 `.gitlab-ci.yml` 文件。合并该合并请求即可启用流水线密钥检测。

要启用流水线密钥检测：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **流水线密钥检测** 行中，选择 **通过合并请求配置**。
1. 可选。填写字段。
1. 选择 **创建合并请求**。
1. 审查并合并该合并请求。

现在流水线中包含一个流水线密钥检测作业。

<a id="coverage"></a>

## 覆盖范围

流水线密钥检测经过优化，以平衡覆盖范围和运行时间。默认情况下，仅扫描仓库的当前状态和未来的提交。要识别仓库历史中已存在的密钥，请在启用流水线密钥检测后运行一次历史扫描。扫描结果仅在流水线完成后可用。

具体扫描哪些内容取决于流水线的类型以及是否设置了其他配置。

默认情况下，当你运行流水线时：

- 在分支上：
  - 在 **默认分支** 上，会扫描 Git 工作树。这意味着当前仓库状态会像普通目录一样被扫描。
  - 在 **新的非默认分支** 上，仅扫描最新提交的内容。分支上更早的提交不会包含在扫描中。
  - 在 **现有的非默认分支** 上，会扫描从上一次推送的提交到最新提交之间的所有提交内容。
  - 要每次都扫描自分支分叉点以来的所有提交，请启用[合并请求流水线](../../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。
- 在 **合并请求** 上，会扫描分支上所有提交的内容。如果分析器无法访问每个提交，则会扫描从父提交到最新提交的所有内容。要扫描所有提交，你必须启用[合并请求流水线](../../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。

要覆盖默认行为，请使用[可用的 CI/CD 变量](configure.md#available-cicd-variables)。

### 分析器如何获取提交

默认情况下，当极狐GitLab 首次克隆仓库时，它仅获取最近的提交（“浅克隆”）。当需要超出初始克隆范围的额外提交时，分析器会使用优化策略自动获取它们：

- 对于合并请求，分析器仅检索在合并基准之后提交的变更，从而最大限度地减少数据传输。
- 如果指定了日志选项，如 `--since` 或 `--max-count`，分析器仅获取所需的提交。
- 在历史扫描期间，分析器会获取完整的仓库历史。如果仓库是浅克隆的，分析器会使用 `--unshallow` 选项。

如果分析器无法获取所需的提交，它会回退到扫描可用数据：

- 在强制推送后，分析器仅扫描仓库的当前状态。
- 如果存在网络故障，分析器会扫描初始克隆后可用的提交。
- 如果发生超时，分析器会使用部分提交历史继续扫描。

这些回退机制确保你的流水线即使在受限环境中也能成功完成。

### 初始仓库克隆深度

Runner 的 [`GIT_DEPTH`](../../../../ci/runners/configure_runners.md#shallow-cloning) 控制初始克隆的提交数量。流水线密钥检测会在需要时自动获取额外的提交，因此你通常不需要调整此设置。

如果你在受限网络环境中持续遇到缺少提交的问题，请参阅故障排除以获取解决方法。

<a id="run-a-historic-scan"></a>

### 运行历史扫描

默认情况下，流水线密钥检测仅扫描 Git 仓库的当前状态。仓库历史中包含的任何密钥都不会被检测到。运行历史扫描可以检查 Git 仓库中所有提交和分支的密钥。

你应该仅在启用流水线密钥检测后运行一次历史扫描。历史扫描可能需要很长时间，尤其是对于具有较长 Git 历史的大型仓库。在完成初始历史扫描后，仅将标准流水线密钥检测作为流水线的一部分使用。

如果你通过[扫描执行策略](../../policies/scan_execution_policies.md#scanner-behavior)启用流水线密钥检测，默认情况下第一次计划扫描是历史扫描。

要运行历史扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择 **新建流水线**。
1. 添加一个 CI/CD 变量：
   1. 从下拉列表中，选择 **变量**。
   1. 在 **输入变量键** 框中，输入 `SECRET_DETECTION_HISTORIC_SCAN`。
   1. 在 **输入变量值** 框中，输入 `true`。
1. 选择 **新建流水线**。

<a id="duplicate-vulnerability-tracking"></a>

## 重复漏洞追踪

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.0 中引入。

{{< /history >}}

密钥检测使用先进的漏洞追踪算法，以防止在文件重构或移动时创建重复的发现和漏洞。

在以下情况下不会创建新发现：

- 密钥在文件内移动。
- 文件中出现重复的密钥。

重复漏洞追踪基于每个文件进行。如果相同的密钥出现在两个不同的文件中，则会创建两个发现。

有关更多信息，请参阅机密项目 `https://gitlab.com/gitlab-org/security-products/post-analyzers/tracking-calculator`。此项目仅对极狐GitLab 团队成员可用。

### 不支持的工作流

重复漏洞追踪不支持以下工作流：

- 现有发现缺少追踪签名，并且与新发现的位置不同。
- 某些密钥是通过搜索其前缀而不是整个密钥值来检测的。对于这些密钥类型，同一类型和同一文件中的所有检测结果都会报告为一个发现。

  例如，SSH 私钥通过其前缀 `-----BEGIN OPENSSH PRIVATE KEY-----` 检测。如果同一文件中有多个 SSH 私钥，流水线密钥检测只会创建一个发现。
- 在运行历史扫描或在现有提交上启用流水线密钥检测时，如果密钥在一个提交中引入，然后在同一扫描的后续提交中被修改，则漏洞报告中只会显示最新的密钥值。

<a id="detected-secrets"></a>

## 检测到的密钥

流水线密钥检测会扫描仓库内容中的特定模式。每种模式匹配一种特定类型的密钥，并通过使用 TOML 语法的规则指定。极狐GitLab 维护默认的规则集。

在极狐GitLab 旗舰版中，你可以扩展这些规则以满足你的需求。例如，虽然使用自定义前缀的个人访问令牌默认不会被检测到，但你可以自定义规则来识别这些令牌。有关详细信息，请参阅[自定义分析器规则集](configure.md#customize-analyzer-rulesets)。

要确认流水线密钥检测会检测哪些密钥，请参阅[检测到的密钥](../detected_secrets.md)。为了提供可靠、高置信度的结果，流水线密钥检测仅在特定上下文（如 URL）中查找密码或其他非结构化密钥。

当检测到密钥时，会为其创建一个漏洞。即使密钥已从扫描的文件中移除，并且流水线密钥检测已再次运行，该漏洞仍会保持“仍检测到”状态。这是因为泄露的密钥在被撤销之前仍然是安全风险。已移除的密钥也会保留在 Git 历史中。要从 Git 仓库历史中删除密钥，请参阅[从仓库中编辑文本](../../../project/repository/repository_size.md#redact-text-from-repository)。

<a id="excluded-items"></a>

## 排除的项目

为了提高性能，流水线密钥检测会自动排除某些不太可能包含密钥的文件类型和目录。

以下项目会被排除：
| 类别 | 排除项 |
|-------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 配置文件 | 文件：`gitleaks.toml`、`verification-metadata.xml`、`Database.refactorlog`、`.editorconfig`、`.gitattributes` |
| 媒体和二进制文件 | 扩展名：`.bmp`、`.gif`、`.svg`、`.jpg/.jpeg`、`.png`、`.tiff/.tif`、`.webp`、`.ico`、`.heic`<br/>字体：`.eot`、`.otf`、`.ttf`、`.woff`、`.woff2`<br/>文档：`.doc/.docx`、`.xls/.xlsx`、`.ppt/.pptx`、`.pdf`<br/>音频/视频：`.mp3`、`.mp4`、`.wav`、`.flac`、`.aac`、`.ogg`、`.avi`、`.mkv`、`.mov`、`.wmv`、`.flv`、`.webm`<br/>归档文件：`.zip`、`.rar`、`.7z`、`.tar`、`.gz`、`.bz2`、`.xz`、`.dmg`、`.iso`<br/>可执行文件：`.exe`、`.gltf` |
| Visual Studio 文件 | 扩展名：`.socket`、`.vsidx`、`.suo`、`.wsuo`、`.dll`、`.pdb` |
| 软件包锁定文件 | 文件：`deno.lock`、`npm-shrinkwrap.json`、`package-lock.json`、`pnpm-lock.yaml`、`yarn.lock`、`Pipfile.lock`、`poetry.lock`、`gradle.lockfile`、`Cargo.lock`、`composer.lock` |
| Go 语言文件 | 扩展名：`go.mod`、`go.sum`、`go.work`、`go.work.sum`<br/>目录：`vendor/`（仅适用于来自 `github.com`、`golang.org`、`google.golang.org`、`gopkg.in`、`istio.io`、`k8s.io`、`sigs.k8s.io` 的 Go 模块）<br/>文件：`vendor/modules.txt` |
| Ruby 文件 | 目录：`.bundle/`、`gems/`、`specifications/`<br/>扩展名：`gems/` 目录中的 `.gem` 文件，`specifications/` 目录中的 `.gemspec` 文件 |
| 构建工具包装器 | 文件：`gradlew`、`gradlew.bat`、`mvnw`、`mvnw.cmd`<br/>目录：`.mvn/wrapper/`<br/>特定文件：Maven 包装器目录中的 `MavenWrapperDownloader.java` |
| 依赖目录 | 目录：`node_modules/`、`bower_components/`、`packages/` |
| 构建输出目录 | 目录：`target/`、`build/`、`bin/`、`obj/` |
| Vendor 目录 | 目录：`vendor/bundle/`、`vendor/ruby/`、`vendor/composer/` |
| Python 缓存文件 | 扩展名：`.pyc`、`.pyo`<br/>目录：`__pycache__/` |
| Python 工具缓存 | 目录：`.pytest_cache/`、`.mypy_cache/`、`.tox/` |
| Python 虚拟环境 | 目录：`venv/`、`virtualenv/`、`.venv/`、`env/` |
| Python 安装目录 | 目录：`lib/python[version]/`、`lib64/python[version]/`、`python[version]/lib/`、`python[version]/Lib/` |
| Python 软件包元数据 | 以版本和 `.dist-info` 结尾的软件包名称 |
| JavaScript 库 | 文件：`angular*.js`、`bootstrap*.js`、`jquery*.js`、`jquery-ui*.js`、`plotly*.js`、`swagger-ui*.js` <br/>源映射：对应的 `.js.map` 文件 |
| 压缩/打包的静态资源 | 扩展名：`.min.js`、`.min.css`、`.bundle.js`、`.bundle.css`、`.map`（源映射文件） |
| 编译文件 | 扩展名：`.class`、`.o`、`.obj`、`.jar`、`.war`（Web 归档）、`.ear` |
| 缓存目录 | 目录：`.cache/`、`.coverage/`、`.pytest_cache/`、`.mypy_cache/`、`.tox/` |
| 生成的文档 | 目录：`htmlcov/`、`coverage/`、`_build/`、`_site/`、`docs/_build/` |
| 版本控制和 IDE | 目录：`.git/`、`.svn/`、`.hg/`、`.bzr/`（版本控制），`.vscode/`、`.idea/`、`.eclipse/`、`.vs/`（IDE） |
| 操作系统文件 | 文件：`.DS_Store`、`Thumbs.db` |

<a id="secret-detection-results"></a>

## 机密检测结果

流水线机密检测会输出 `gl-secret-detection-report.json` 文件作为作业产物。该文件包含检测到的机密。您可以 [下载](../../../../ci/jobs/job_artifacts.md#download-job-artifacts) 该文件，以便在极狐GitLab 之外进行处理。

有关更多信息，请参见 [报告文件架构](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/blob/master/dist/secret-detection-report-format.json) 和 [示例报告文件](https://jihulab.com/gitlab-cn/security-products/analyzers/secrets/-/blob/master/qa/expect/secrets/gl-secret-detection-report.json)。

<a id="additional-output"></a>

### 额外输出

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

作业结果也会在以下位置展示：

- [合并请求部件](../../detect/security_scanning_results.md#merge-request-security-widget)：显示合并请求中新引入的发现项。
- [流水线安全报告](../../detect/security_scanning_results.md)：显示最新流水线运行中的所有发现项。
- [漏洞报告](../../vulnerability_report/_index.md)：提供对所有安全发现项的集中管理。
- 安全仪表盘：提供组织范围内、跨项目和群组的所有漏洞的可见性。

<a id="understanding-the-results"></a>

## 理解结果

流水线机密检测会提供有关仓库中发现的潜在机密的详细信息。每个机密都包含泄露的机密类型及其修复指南。

在审查结果时：

1. 查看周围的代码，判断检测到的模式是否确实是机密。
1. 测试检测到的值是否是有效凭据。
1. 考虑仓库的可见性和机密的权限范围。
1. 优先处理处于活跃状态的高权限机密。

<a id="common-detection-categories"></a>

### 常见检测类别

流水线机密检测的发现项通常属于以下三类之一：

- **真阳性**：应被轮换和删除的合法机密。例如：
  - 活跃的 API 密钥、数据库密码、认证令牌
  - 私钥和证书
  - 服务账号凭据
- **误报**：检测到的模式并非实际秘密。例如：
  - 文档中的示例值
  - 测试数据或模拟凭据
  - 带占位符值的配置模板
- **历史发现项**：之前已提交但可能已失效的机密。这些检测结果：
  - 需要进行调查以确定当前状态
  - 为防万一，仍应进行轮换

<a id="remediate-a-leaked-secret"></a>

## 修复泄露的机密

当检测到机密时，您应该立即进行轮换。极狐GitLab 会尝试
[自动撤销](../automatic_response.md) 某些类型的泄露机密。对于未自动撤销的，您必须手动处理。

[从仓库历史记录中清除机密](../../../project/repository/repository_size.md#purge-files-from-repository-history)
并不能完全解决泄露问题。原始的机密仍会留存在任何现有的仓库分支或克隆副本中。

有关如何响应泄露机密的说明，请在漏洞报告中选择相应的漏洞。

<a id="optimization"></a>

## 优化

在您的组织内部署流水线机密检测之前，请先优化配置，以减少误报并提高在特定环境下的准确性。

误报会导致警报疲劳，降低对工具的信任度。请考虑使用自定义规则集配置（仅限旗舰版）：

- 排除针对您代码库的已知安全模式。
- 对于经常在非机密信息上触发的规则，调整其敏感度。
- 为组织特有的机密格式添加自定义规则。

为了优化大型仓库或拥有众多项目的组织的性能，请审查您的：

- 扫描范围管理：
  - 在项目中运行历史扫描后，关闭历史扫描。
  - 将历史扫描安排在低使用量时段进行。
- 资源分配：
  - 为大型仓库分配足够的 runner 资源。
  - 考虑为安全扫描工作负载设置专用 runner。
  - 监控扫描持续时间，并根据仓库大小进行优化。

<a id="testing-optimization-changes"></a>

### 测试优化变更

在组织范围内应用优化之前：

1. 验证优化不会遗漏合法机密。
1. 跟踪误报减少情况和扫描性能改善情况。
1. 维护有效优化模式的记录。

<a id="roll-out"></a>

## 推广

您应该逐步实施流水线机密检测。
先从一个小规模的试点开始，了解该工具的行为，然后再将功能推广到整个组织。

在推广流水线机密检测时，请遵循以下指南：

1. 选择一个试点项目。合适的项目应具备：
   - 活跃的开发活动且定期提交代码。
   - 可管理的代码库大小。
   - 熟悉极狐GitLab CI/CD 的团队。
   - 愿意迭代调整配置。
1. 从简单开始。在试点项目中使用默认设置启用流水线机密检测。
1. 监控结果。运行分析器一两周，以了解典型的发现项。
1. 处理检测到的机密。修复任何发现的合法机密。
1. 调整配置。根据初始结果调整设置。
1. 记录实施情况。记录常见的误报和修复模式。

<a id="fips-enabled-images"></a>

## 已启用 FIPS 的镜像

{{< history >}}

- 在极狐GitLab 14.10 中引入。

{{< /history >}}

默认的扫描器镜像基于 Alpine 基础镜像构建，以优化大小和可维护性。极狐GitLab
提供 [Red Hat UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) 版本的镜像，这些镜像已启用 FIPS。

要使用已启用 FIPS 的镜像，您可以：

- 将 `SECRET_DETECTION_IMAGE_SUFFIX` CI/CD 变量设置为 `-fips`。
- 将 `-fips` 扩展名添加到默认镜像名称。

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

在进行故障排除时，调试级别日志记录会很有帮助。有关详细信息，请参阅
[调试级别日志记录](../../troubleshooting_application_security.md#turn-on-debug-level-logging)。

<a id="warning-gl-secret-detection-reportjson-no-matching-files"></a>

#### 警告：`gl-secret-detection-report.json: no matching files`

有关此问题的信息，请参阅 [通用应用安全故障排除部分](../../../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)。

<a id="error-couldnt-run-the-gitleaks-command-exit-status-2"></a>

#### 错误：`Couldn't run the gitleaks command: exit status 2`

此错误表示分析器无法访问所需的提交记录。虽然分析器在大多数情况下会自动获取缺失的提交记录，但在受限环境中可能会出现问题。

要诊断此问题，请启用 [调试级别日志记录](../../troubleshooting_application_security.md#turn-on-debug-level-logging) 并查找：

```plaintext
ERRO[2020-11-18T18:05:52Z] 未找到对象
[ERRO] [secrets] [2020-11-18T18:05:52Z] ▶ 无法运行 gitleaks 命令：退出状态 2
[ERRO] [secrets] [2020-11-18T18:05:52Z] ▶ Gitleaks 分析失败：退出状态 2
```

要解决此问题：

- 对于大多数情况，无需采取任何操作。让分析器自动处理获取过程。
- 对于受限网络，请增加初始克隆深度：

  ```yaml
  secret_detection:
    variables:
      GIT_DEPTH: 100  # 或者设为 0 以克隆所有内容
  ```

- 对于大型仓库，请限制扫描范围：

  ```yaml
  secret_detection:
    variables:
      SECRET_DETECTION_LOG_OPTIONS: "--max-count=50"
  ```

<a id="error-err-fatal-ambiguous-argument"></a>

#### 错误：`ERR fatal: ambiguous argument`

如果您的仓库默认分支与触发作业的分支没有关联，流水线机密检测可能会失败，并显示 `ERR fatal: ambiguous argument` 错误。
详情请参见议题 [!352014](https://jihulab.com/gitlab-cn/gitlab/-/issues/352014)。

要解决此问题，请确保在您的仓库中正确 [设置默认分支](../../../project/repository/branches/default.md#change-the-default-branch-name-for-a-project)。
您应将其设置为与运行 `secret-detection` 作业的分支存在关联历史记录的分支。

<a id="exec-binsh-exec-format-error-message-in-job-log"></a>

#### 作业日志中出现 `exec /bin/sh: exec format error` 消息

极狐GitLab 流水线机密检测分析器 [仅支持](#getting-started) 在 `amd64` CPU 架构上运行。
此消息表明作业正在其他架构上运行，例如 `arm`。

<a id="error-fatal-detected-dubious-ownership-in-repository-at-buildsproject-dir"></a>

#### 错误：`fatal: detected dubious ownership in repository at '/builds/<project dir>'`

机密检测可能失败，退出状态为 128。这可能是由于 Docker 镜像的用户变更引起的。

例如：

```shell
$ /analyzer run
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ 极狐GitLab 机密分析器 v6.0.1
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ 正在检测项目
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ 分析器将尝试分析仓库中的所有项目
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ 正在为 /builds.... 加载规则集
[WARN] [secrets] [2024-06-06T07:28:13Z] ▶ 未找到 /builds/....secret-detection-ruleset.toml，规则集支持将被禁用。
[INFO] [secrets] [2024-06-06T07:28:13Z] ▶ 正在运行分析器
[FATA] [secrets] [2024-06-06T07:28:13Z] ▶ 获取提交计数：退出状态 128
```

要解决此问题，请添加一个 `before_script`，内容如下：

```yaml
before_script:
    - git config --global --add safe.directory "$CI_PROJECT_DIR"
```

有关此问题的更多信息，请参见议题 465974。

<a id="adjusting-git-depth-doesnt-change-what-gets-scanned"></a>

#### 调整 `GIT_DEPTH` 不会改变扫描内容

这是预期行为。`GIT_DEPTH` 是用于初始克隆的 runner 变量。它不会改变分析器的行为。

机密检测分析器根据以下内容决定扫描范围：

- 流水线类型（推送、合并请求、计划）
- 分支上下文（默认、新建、现有）
- 您的配置（`SECRET_DETECTION_LOG_OPTIONS`、`SECRET_DETECTION_HISTORIC_SCAN`）

例如，若只扫描 30 个提交：

```yaml
secret_detection:
  variables:
    # 扫描最近 30 个提交
    SECRET_DETECTION_LOG_OPTIONS: "--max-count=30"
```

若只扫描最近两周的提交：

```yaml
secret_detection:
  variables:
    # 扫描过去两周内所做的提交
    SECRET_DETECTION_LOG_OPTIONS: "--since=2.weeks"
```

若只扫描从 `HEAD~10` 到 `HEAD` 的提交：

```yaml
secret_detection:
  variables:
    # 扫描从 HEAD~10 到 HEAD 的提交
    SECRET_DETECTION_LOG_OPTIONS: "HEAD~10..HEAD"
```

有关完整的选项列表，请查阅 [Git 日志选项](https://git-scm.com/docs/git-log) 文档。

<a id="force-push-detection"></a>

#### 强制推送检测

强制推送后，您可能会看到：

```plaintext
由于强制推送，无法从上次 Git 推送事件中检索所有提交
```

这是预期行为。扫描将继续使用当前的仓库状态。

<a id="repository-trust-configuration"></a>

#### 仓库信任配置

您可能会看到以下消息：

```plaintext
已将项目目录添加到 Git safe.directory 配置中
```

这表明容器化环境中存在典型的安全配置。无需执行任何操作。