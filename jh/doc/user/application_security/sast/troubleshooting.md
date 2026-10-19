---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 SAST
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

以下故障排除场景收集自客户支持案例。如果您遇到此处未涉及的问题，或者此处的信息无法解决您的问题，请参阅[极狐GitLab 支持](https://gitlab.cn/support)页面，了解获取帮助的方式。

<a id="debug-level-logging"></a>

## 调试级日志记录

调试级日志记录有助于故障排除。有关详情，请参阅[调试级日志记录](../troubleshooting_application_security.md#turn-on-debug-level-logging)。

<a id="changes-in-the-cicd-template"></a>

## CI/CD 模板中的变更

GitLab 维护的 SAST CI/CD 模板控制哪些[分析器](analyzers.md)作业运行以及如何配置它们。使用该模板时，您可能会遇到作业失败或其他流水线错误。例如，您可能会：

- 在查看受影响的流水线时，看到类似 `'<your job>' needs 'spotbugs-sast' job, but 'spotbugs-sast' is not in any previous stage`的错误消息。
- 在 CI/CD 流水线配置中遇到其他类型的意外问题。

如果您遇到作业失败，或看到与 SAST 相关的 `yaml invalid` 流水线状态，可以临时回退到较旧版本的模板，以便在调查问题期间让流水线继续运行。要使用较旧版本的模板，请将 CI/CD YAML 文件中现有的 `include` 语句改为引用特定模板版本，例如 `v19.2.0-ee`：

```yaml
include:
  remote: 'https://jihulab.com/gitlab-cn/gitlab/-/raw/v19.2.0-ee/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml'
```

如果您的极狐GitLab 实例网络连接受限，您也可以下载该文件并将其托管在其他位置。

您只应临时使用此解决方案。请尽快恢复使用标准模板。

<a id="errors-in-a-specific-analyzer-job"></a>

## 特定分析器作业中的错误

极狐GitLab SAST [分析器](analyzers.md)以容器镜像形式发布。如果您看到的新错误似乎与 GitLab 维护的 SAST CI/CD 模板或您自己项目中的变更无关，可以尝试[将受影响的分析器固定到特定的较旧版本](_index.md#pin-analyzer-image-version)。您只应临时使用此解决方案。请尽快恢复使用标准模板。

每个[分析器项目](analyzers.md)都有一个 `CHANGELOG.md` 文件，列出每个可用版本中所做的变更。

<a id="job-log-messages"></a>

## 作业日志消息

SAST 作业的日志可能包含有助于确定根本原因的错误消息。以下是一些错误消息及建议的操作。

<a id="executable-format"></a>

### 可执行文件格式

```plaintext
exec /bin/sh: exec format error` message in job log
```

极狐GitLab SAST 分析器[仅支持](_index.md#getting-started)在 `amd64` CPU 架构上运行。此消息表明该作业正在其他架构上运行，例如 `arm`。

<a id="docker-error"></a>

### Docker 错误

```plaintext
Error response from daemon: error processing tar file: docker-tar: relocation error
```

当运行 SAST 作业的 Docker 版本为 `19.03.0` 时，会出现此错误。请考虑更新到 Docker `19.03.1` 或更高版本。较旧版本不受影响。有关详情，请参阅[议题 13830](https://gitlab.com/gitlab-org/gitlab/-/issues/13830#note_211354992) - “Current SAST container fails”。

<a id="no-matching-files"></a>

### 没有匹配的文件

```plaintext
gl-sast-report.json: no matching files
```

有关此问题的信息，请参阅[应用安全通用故障排除部分](../../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)。

<a id="configuration-only"></a>

### 仅用于配置

```plaintext
sast is used for configuration only, and its script should not be executed
```

有关此问题的信息，请参阅[极狐GitLab Secure 故障排除部分](../troubleshooting_application_security.md#error-job-is-used-for-configuration-only-and-its-script-should-not-be-executed)。

<a id="error-an-error-occurred-while-creating-the-merge-request"></a>

## 错误：`An error occurred while creating the merge request`

尝试使用 UI 在项目上启用 SAST 时，该操作可能会失败并显示以下警告：

```plaintext
An error occurred while creating the merge request.
```

出现此问题可能是因为某些原因阻止了为合并请求创建分支。使用 UI 配置 SAST 时，会创建一个带数字后缀的分支，例如 `set-sast-config-1`。诸如[验证分支名称的推送规则](../../project/repository/push_rules.md#validate-branch-names)之类的功能可能会因命名格式而阻止创建该分支。

要解决此问题，请编辑推送规则，使其允许 SAST 所需的分支命名格式。

<a id="sast-jobs-run-unexpectedly"></a>

## SAST 作业意外运行

[SAST CI 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)使用 `rules:exists` 参数。出于性能原因，针对给定 glob 模式最多进行 10000 次匹配。如果匹配数超过最大值，`rules:exists` 参数会返回 `true`。根据代码仓库中的文件数量，即使扫描器不支持您的项目，也可能触发 SAST 作业。有关此限制的更多详情，请参阅 [`rules:exists` 文档](../../../ci/yaml/_index.md#rulesexists)。

<a id="spotbugs-errors"></a>

## SpotBugs 错误

以下是发生的最常见 SpotBugs 错误的详情及建议的操作。

<a id="utf-8-unmappable-character-errors"></a>

### UTF-8 无法映射字符错误

当 SpotBugs 构建未启用 UTF-8 编码且源代码中包含 UTF-8 字符时，会出现这些错误。要修复此错误，请为项目的构建工具启用 UTF-8。

对于 Gradle 构建，请将以下内容添加到您的 `build.gradle` 文件中：

```groovy
compileJava.options.encoding = 'UTF-8'
tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
}
```

对于 Maven 构建，请将以下内容添加到您的 `pom.xml` 文件中：

```xml
<properties>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
```

<a id="project-couldnt-be-built"></a>

### 项目无法构建

如果您的 `spotbugs-sast` 作业在构建步骤失败并显示消息“Project couldn't be built”，最可能的原因是：

- 您的项目要求 SpotBugs 使用不属于其默认工具的工具进行构建。有关 SpotBugs 默认工具的列表，请参阅 [SpotBugs 的 asdf 依赖项](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs/-/blob/master/config/.gl-tool-versions)。
- 您的构建需要自定义配置或额外依赖项，而分析器的自动构建过程无法满足这些需求。

基于 SpotBugs 的分析器仅用于扫描 Groovy 代码，但在其他情况下也可能触发，例如[当所有 SAST 作业意外运行时](#sast-jobs-run-unexpectedly)。

解决方案取决于您是否需要扫描 Groovy 代码：

- 如果您没有任何 Groovy 代码，或不需要扫描它，应[禁用 SpotBugs 分析器](analyzers.md#disable-specific-default-analyzers)。
- 如果您确实需要扫描 Groovy 代码，应使用[预编译](_index.md#using-pre-compilation-with-spotbugs-analyzer)。预编译通过扫描您已在流水线中构建的产物来避免这些失败，而不是尝试在 `spotbugs-sast` 作业中编译它。

<a id="java-out-of-memory-error"></a>

### Java 内存不足错误

当 `spotbugs-sast` 作业运行时，您可能会收到 `java.lang.OutOfMemoryError` 错误。此问题在 Java 扫描期间内存耗尽时发生。

要尝试解决此问题，您可以：

- 选择较低的[工作力度级别](_index.md#security-scanner-configuration)。
- 设置 CI/CD 变量 `JAVA_OPTS` 以替换默认的 `-XX:MaxRAMPercentage=80`（例如：`-XX:MaxRAMPercentage=90`）。
- 在您的 `spotbugs-sast` 作业中[标记更大的 runner](../../../ci/runners/hosted_runners/linux.md#machine-types-available-for-linux-x86-64)。

<a id="exception-analyzing"></a>

### 分析时出现异常

如果您的作业日志包含“Exception analyzing ... using detector ...”形式的消息，后跟 Java 堆栈跟踪，这并非 SAST 流水线的失败。SpotBugs 已确定该异常是[可恢复的](https://github.com/spotbugs/spotbugs/blob/5ebd4439f6f8f2c11246b79f58c44324718d39d8/spotbugs/src/main/java/edu/umd/cs/findbugs/FindBugs2.java#L1200)，已将其记录，并继续分析。

消息中第一个“...”部分是正在分析的类 - 如果它不属于您的项目，您很可能可以忽略该消息及其后的堆栈跟踪。

另一方面，如果正在分析的类属于您的项目，请考虑在 [GitHub](https://github.com/spotbugs/spotbugs/issues) 上向 SpotBugs 项目创建议题。

<a id="flawfinder-encoding-error"></a>

## Flawfinder 编码错误

当 Flawfinder 遇到无效的 UTF-8 字符时会出现此错误。要修复此问题，请将[其文档中的建议](https://github.com/david-a-wheeler/flawfinder#character-encoding-errors)应用于整个代码仓库，或仅使用 [`before_script`](../../../ci/yaml/_index.md#before_script) 功能按作业应用。

您可以在每个 `.gitlab-ci.yml` 文件中配置 `before_script` 部分，或使用[流水线执行策略](../policies/pipeline_execution_policies.md)来安装编码器并运行转换命令。例如，您可以将 `before_script` 部分添加到从安全扫描器模板生成的 `flawfinder-sast` 作业中，以转换所有扩展名为 `.cpp`的文件。

<a id="example-pipeline-execution-policy-yaml"></a>

### 示例流水线执行策略 YAML

```yaml
---
pipeline_execution_policy:
- name: SAST
  description: 'Run SAST on C++ application'
  enabled: true
  pipeline_config_strategy: inject_ci
  content:
    include:
    - project: my-group/compliance-project
      file: flawfinder.yml
      ref: main
```

`flawfinder.yml`：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

flawfinder-sast:
  before_script:
    - pip install cvt2utf
    - cvt2utf convert "$PWD" -i cpp
```

<a id="semgrep-slowness-unexpected-results-or-other-errors"></a>

## Semgrep 缓慢、结果异常或其他错误

如果 Semgrep 运行缓慢、报告过多误报或漏报、崩溃、失败或出现其他问题，请参阅 Semgrep 文档中关于[极狐GitLab SAST 故障排除](https://semgrep.dev/docs/troubleshooting/semgrep-app#troubleshooting-gitlab-sast)的内容。
