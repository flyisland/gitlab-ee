---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 SAST 问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

以下故障排除场景来自客户支持案例。如果您遇到的问题未在此处解决，或者此处的信息无法解决您的问题，请参阅 [极狐GitLab 支持](https://gitlab.cn/support/) 页面以获取帮助。

<a id="debug-level-logging"></a>

## 调试级日志记录

调试级日志记录有助于故障排除。详情请参阅[调试级日志记录](../troubleshooting_application_security.md#turn-on-debug-level-logging)。

<a id="changes-in-the-cicd-template"></a>

## CI/CD 模板中的变更

极狐GitLab 管理的 SAST CI/CD 模板控制运行哪些[分析器](analyzers.md)作业以及它们的配置方式。在使用该模板时，您可能会遇到作业失败或其他流水线错误。例如，您可能会：

- 查看受影响的流水线时，看到类似 `'<your job>' needs 'spotbugs-sast' job, but 'spotbugs-sast' is not in any previous stage` 的错误消息。
- 遇到其他类型的与您的 CI/CD 流水线配置相关的意外问题。

如果您遇到作业失败或看到 SAST 相关的 `yaml invalid` 流水线状态，您可以暂时回退到模板的旧版本，以便在您调查问题期间流水线继续工作。要使用旧版本的模板，请更改 CI/CD YAML 文件中的现有 `include` 语句，使其指向特定的模板版本，例如 `v15.3.3-ee`：

```yaml
include:
  remote: 'https://jihulab.com/gitlab-cn/gitlab/-/raw/v15.3.3-ee/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml'
```

如果您的极狐GitLab 实例网络连接受限，您也可以下载该文件并将其托管在其他地方。

您应仅将此解决方案用作临时措施。请尽快恢复到标准模板。

<a id="errors-in-a-specific-analyzer-job"></a>

## 特定分析器作业中的错误

极狐GitLab SAST [分析器](analyzers.md) 以容器镜像形式发布。如果您看到的新错误似乎与极狐GitLab 管理的 SAST CI/CD 模板或您自身项目的更改无关，您可以尝试[将受影响的分析器固定到特定的旧版本](_index.md#pin-analyzer-image-version)。您应仅将此解决方案用作临时措施。请尽快恢复到标准模板。

每个[分析器项目](analyzers.md)都有一个 `CHANGELOG.md` 文件，列出了每个可用版本中所做的更改。

<a id="job-log-messages"></a>

## 作业日志消息

SAST 作业的日志可能包含有助于定位根本原因的错误消息。以下是部分错误消息及建议操作。

<a id="executable-format"></a>

### 可执行格式错误

```plaintext
作业日志中的 `exec /bin/sh: exec format error` 消息
```

极狐GitLab SAST 分析器[仅支持](_index.md#getting-started)在 `amd64` CPU 架构上运行。此消息表示作业正在不同的架构上运行，例如 `arm`。

<a id="docker-error"></a>

### Docker 错误

```plaintext
来自守护进程的错误响应：处理 tar 文件时出错：docker-tar：重定位错误
```

当运行 SAST 作业的 Docker 版本为 `19.03.0` 时会出现此错误。请考虑升级到 Docker `19.03.1` 或更高版本。旧版本不受影响。更多详情，请参见 issue 13830 - “当前 SAST 容器失败”。

<a id="no-matching-files"></a>

### 没有匹配的文件

```plaintext
gl-sast-report.json：没有匹配的文件
```

有关此问题的信息，请参见[通用应用程序安全故障排除部分](../../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)。

<a id="configuration-only"></a>

### 仅配置

```plaintext
sast 仅用于配置，其脚本不应被执行
```

有关此问题的信息，请参见[极狐GitLab Secure 故障排除部分](../troubleshooting_application_security.md#error-job-is-used-for-configuration-only-and-its-script-should-not-be-executed)。

<a id="error-an-error-occurred-while-creating-the-merge-request"></a>

## 错误：`An error occurred while creating the merge request`

尝试通过用户界面在项目上启用 SAST 时，操作可能会失败并显示以下警告：

```plaintext
创建合并请求时发生错误。
```

此问题可能是因为某些原因阻止了为合并请求创建分支。通过用户界面配置 SAST 时，会创建一个带数字后缀的分支，例如 `set-sast-config-1`。诸如[验证分支名称的推送规则](../../project/repository/push_rules.md#validate-branch-names)之类的功能可能因为命名格式而阻止分支的创建。

要解决此问题，请编辑推送规则，使其允许 SAST 所需的分支命名格式。

<a id="sast-jobs-run-unexpectedly"></a>

## SAST 作业意外运行

SAST CI 模板使用了 `rules:exists` 参数。出于性能原因，对给定的 glob 模式最多进行 10000 次匹配。如果匹配数量超过最大值，`rules:exists` 参数会返回 `true`。根据仓库中的文件数量，即使扫描器不支持您的项目，SAST 作业也可能被触发。有关此限制的更多详细信息，请参见 [`rules:exists` 文档](../../../ci/yaml/_index.md#rulesexists)。

<a id="spotbugs-errors"></a>

## SpotBugs 错误

以下是发生的最常见 SpotBugs 错误的详细信息及建议操作。

<a id="utf-8-unmappable-character-errors"></a>

### UTF-8 不可映射字符错误

当 SpotBugs 构建未启用 UTF-8 编码且源代码中包含 UTF-8 字符时，会出现这些错误。要修复此错误，请为项目的构建工具启用 UTF-8。

对于 Gradle 构建，将以下内容添加到您的 `build.gradle` 文件中：

```groovy
compileJava.options.encoding = 'UTF-8'
tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
}
```

对于 Maven 构建，将以下内容添加到您的 `pom.xml` 文件中：

```xml
<properties>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
```

<a id="project-couldnt-be-built"></a>

### 项目无法构建

如果您的 `spotbugs-sast` 作业在构建步骤失败，并显示消息“项目无法构建”，这很可能是因为：

- 您的项目要求 SpotBugs 使用不属于其默认工具的工具进行构建。有关 SpotBugs 默认工具的列表，请参见 [SpotBugs 的 asdf 依赖项](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs/-/blob/master/config/.gl-tool-versions)。
- 您的构建需要自定义配置或额外的依赖项，而分析器的自动构建过程无法满足。

基于 SpotBugs 的分析器仅用于扫描 Groovy 代码，但在其他情况下也可能会触发，例如[当所有 SAST 作业意外运行时](#sast-jobs-run-unexpectedly)。

解决方案取决于您是否需要扫描 Groovy 代码：

- 如果您没有任何 Groovy 代码，或者不需要扫描它，您应[禁用 SpotBugs 分析器](analyzers.md#disable-specific-default-analyzers)。
- 如果需要扫描 Groovy 代码，您应使用[预编译](_index.md#using-pre-compilation-with-spotbugs-analyzer)。预编译通过扫描您在流水线中已构建的制品来避免这些失败，而不是在 `spotbugs-sast` 作业中尝试编译它。

<a id="java-out-of-memory-error"></a>

### Java 内存不足错误

当 `spotbugs-sast` 作业运行时，您可能会收到一条错误，内容为 `java.lang.OutOfMemoryError`。当 Java 在扫描过程中内存耗尽时会出现此问题。

要尝试解决此问题，您可以：

- 选择较低的[努力程度](_index.md#security-scanner-configuration)。
- 设置 CI/CD 变量 `JAVA_OPTS` 以替换默认的 `-XX:MaxRAMPercentage=80`（例如：`-XX:MaxRAMPercentage=90`）。
- 在 `spotbugs-sast` 作业中[标记更大的 Runner](../../../ci/runners/hosted_runners/linux.md#machine-types-available-for-linux---x86-64)。

<a id="exception-analyzing"></a>

### 分析异常

如果您的作业日志包含形式为“Exception analyzing ... using detector ...”后跟 Java 堆栈跟踪的消息，这**不是** SAST 流水线的失败。SpotBugs 已确定该异常是[可恢复的](https://github.com/spotbugs/spotbugs/blob/5ebd4439f6f8f2c11246b79f58c44324718d39d8/spotbugs/src/main/java/edu/umd/cs/findbugs/FindBugs2.java#L1200)，已将其记录并继续分析。

消息中的第一个“...”部分是被分析的类——如果不是您项目的一部分，您很可能可以忽略该消息及其后面的堆栈跟踪。

另一方面，如果被分析的类是您项目的一部分，请考虑在 [GitHub](https://github.com/spotbugs/spotbugs/issues) 上的 SpotBugs 项目创建一个议题。

<a id="flawfinder-encoding-error"></a>

## Flawfinder 编码错误

当 Flawfinder 遇到无效的 UTF-8 字符时会出现此问题。要修复此问题，请将[他们的文档建议](https://github.com/david-a-wheeler/flawfinder#character-encoding-errors)应用到整个仓库，或者使用 [`before_script`](../../../ci/yaml/_index.md#before_script) 功能仅针对每个作业应用。

您可以在每个 `.gitlab-ci.yml` 文件中配置 `before_script` 部分，或使用[流水线执行策略](../policies/pipeline_execution_policies.md)来安装编码器并运行转换命令。例如，您可以向从安全扫描模板生成的 `flawfinder-sast` 作业添加 `before_script` 部分，以转换所有 `.cpp` 扩展名的文件。

<a id="example-pipeline-execution-policy-yaml"></a>

### 流水线执行策略 YAML 示例

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

## Semgrep 运行缓慢、意外结果或其他错误

如果 Semgrep 运行缓慢、报告过多误报或漏报、崩溃、失败或出现其他损坏，请参阅 Semgrep 文档了解[极狐GitLab SAST 故障排除](https://semgrep.dev/docs/troubleshooting/semgrep-app#troubleshooting-gitlab-sast)。