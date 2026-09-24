---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用安全故障排除
description: 如何对极狐GitLab应用安全功能进行故障排除，包括如何获取更详细的日志。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当使用应用安全功能时，您可能会遇到以下问题。

<a id="logging-level"></a>

## 日志记录级别

极狐GitLab 分析器输出的日志详细程度由 `SECURE_LOG_LEVEL` 环境变量决定。该及更高级别的日志消息均会被输出。

从最高严重性到最低严重性，日志级别依次为：

- `致命`
- `错误`
- `警告`
- `信息`（默认）
- `调试`

<a id="turn-on-debug-level-logging"></a>

### 开启调试级日志

> [!warning]
> 调试日志可能是严重的安全风险。输出内容可能包含环境变量及该作业可访问的其他密钥。输出内容会上传至极狐GitLab 服务器，并在作业日志中可见。

先决条件：

- 项目的维护者或所有者角色。

要开启调试级日志，请将以下内容添加到您的 `.gitlab-ci.yml` 文件中：

```yaml
variables:
  SECURE_LOG_LEVEL: "debug"
```

这指示所有极狐GitLab 分析器输出所有消息。更多详情，请参阅[日志记录级别](#logging-level)。

<!-- NOTE: The below subsection(`### Secure job failing with exit code 1`) documentation URL is referred in the [/gitlab-org/security-products/analyzers/command](https://jihulab.com/gitlab-cn/security-products/analyzers/command/-/blob/main/command.go#L19) repository. If this section/subsection changes, ensure to update the corresponding URL in the mentioned repository.
-->

<a id="secure-job-failing-with-exit-code-1"></a>

## 安全作业以退出代码 1 失败

如果一个安全作业失败且原因不明：

1. 启用[调试级日志](#turn-on-debug-level-logging)。
1. 运行作业。
1. 检查作业输出。
1. 移除 `debug` 日志级别以恢复默认的 `info` 级别。

<a id="outdated-security-reports"></a>

## 过时的安全报告

当一个为合并请求生成的安全报告变得过时时，该合并请求会在安全小组件中显示警告消息，并提示您采取适当操作。

这可能在两种场景下发生：

- [源分支落后于目标分支](#source-branch-is-behind-the-target-branch)。
- [目标分支安全报告已过时](#target-branch-security-report-is-out-of-date)。

<a id="source-branch-is-behind-the-target-branch"></a>

### 源分支落后于目标分支

当目标分支和源分支之间的最近共同祖先提交不是目标分支上的最新提交时，安全报告可能过时。

要修复此问题，请变基或合并以包含来自目标分支的更改。

<a id="target-branch-security-report-is-out-of-date"></a>

### 目标分支安全报告已过时

这可能是由多种原因引起，包括作业失败或出现新的安全通告。当合并请求显示安全报告已过时时，您必须在目标分支上运行新的流水线。选择 **新流水线** 以运行新的流水线。

<a id="getting-warning-messages-report-json-no-matching-files"></a>

## 收到警告消息 `… report.json: no matching files`

> [!warning]
> 调试日志可能是严重的安全风险。输出内容可能包含环境变量及该作业可访问的其他密钥。输出内容会上传至极狐GitLab 服务器，并在作业日志中可见。

该消息通常紧跟着[错误 `No files to upload`](../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)，并且前面还有其他错误或警告，这些错误或警告指示了未生成 JSON 报告的原因。检查整个作业日志以查找此类消息。如果未找到这些消息，请在设置 `SECURE_LOG_LEVEL: "debug"` 作为[自定义 CI/CD 变量](../../ci/variables/_index.md#for-a-project)后重试失败的作业。这为深入调查提供了额外信息。

<a id="getting-error-message-sast-job-config-key-may-not-be-used-with-rules-only-except"></a>

## 收到错误消息 `sast job: config key may not be used with 'rules': only/except`

当[包含](../../ci/yaml/_index.md#includetemplate)一个 `.gitlab-ci.yml` 模板，例如 [`SAST.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)，根据您的极狐GitLab CI/CD 配置，可能会出现以下错误：

```plaintext
Unable to run pipeline

    jobs:sast config key may not be used with `rules`: only/except
```

此错误在包含的作业的 `rules` 配置[被覆盖](sast/_index.md#override-sast-jobs)并且使用了[已弃用的 `only` 或 `except` 语法。](../../ci/yaml/deprecated_keywords.md#only--except)时出现。要修复此问题，您必须：

- [将您的 `only/except` 语法转换为 `rules`](#transitioning-your-onlyexcept-syntax-to-rules)。
- （临时）[将您的模板锁定到已弃用的版本](#pin-your-templates-to-the-deprecated-versions)

更多信息，请参阅[覆盖 SAST 作业](sast/_index.md#override-sast-jobs)。

<a id="transitioning-your-onlyexcept-syntax-to-rules"></a>

### 将您的 `only/except` 语法转换为 `rules`

在覆盖模板以控制作业执行时，先前使用的 [`only` 或 `except`](../../ci/yaml/deprecated_keywords.md#only--except) 实例不再兼容，必须转换为 [`rules` 语法](../../ci/yaml/_index.md#rules)。

如果您的覆盖旨在将作业限制为仅在 `main` 上运行，则先前的语法类似如下：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

# Ensure that the scanning is only executed on main or merge requests
spotbugs-sast:
  only:
    refs:
      - main
      - merge_requests
```

要将上述配置转换为新的 `rules` 语法，覆盖代码应编写如下：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

# Ensure that the scanning is only executed on main or merge requests
spotbugs-sast:
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_MERGE_REQUEST_ID
```

如果您的覆盖旨在将作业限制为仅在分支上运行，而非标签，则应类似如下：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

# Ensure that the scanning is not executed on tags
spotbugs-sast:
  except:
    - tags
```

要转换为新的 `rules` 语法，覆盖代码需改写为：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

# Ensure that the scanning is not executed on tags
spotbugs-sast:
  rules:
    - if: $CI_COMMIT_TAG == null
```

更多信息，请参阅 [`rules`](../../ci/yaml/_index.md#rules)。

<a id="pin-your-templates-to-the-deprecated-versions"></a>

### 将您的模板锁定到已弃用的版本

为确保最新支持，请迁移至 [`rules`](../../ci/yaml/_index.md#rules)。

如果您暂时无法更新 CI/CD 配置，存在一些变通方法，例如将模板锁定到先前的版本：

  ```yaml
  include:
    remote: 'https://jihulab.com/gitlab-cn/gitlab/-/raw/12-10-stable-ee/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml'
  ```

此外，还提供了一个包含已版本化旧模板的专用项目。这可用于离线设置或任何希望使用 [Auto DevOps](../../topics/autodevops/_index.md) 的用户。

相关说明可在[旧模板项目](https://jihulab.com/gitlab-cn/auto-devops-v12-10)中获取。

<a id="vulnerabilities-are-found-but-the-job-succeeds-how-can-you-have-a-pipeline-fail-instead"></a>

### 发现漏洞但作业成功。如何使得流水线失败？

在这种情况下，作业成功属于默认行为。作业的状态表示分析器本身的成功或失败。分析器结果显示在
[作业日志](../../ci/jobs/job_logs.md#expand-and-collapse-job-log-sections)、
[合并请求小组件](detect/security_scanning_results.md)或
[安全仪表板](security_dashboard/_index.md)中。

<a id="error-job-is-used-for-configuration-only-and-its-script-should-not-be-executed"></a>

## 错误：作业 `仅用于配置，其脚本不应被执行`

[在极狐GitLab 13.4 中所做的更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/41260)对 `Security/Dependency-Scanning.gitlab-ci.yml` 和 `Security/SAST.gitlab-ci.yml` 模板意味着，如果您通过设置 `rules` 属性启用了 `sast` 或 `dependency_scanning` 作业，它们将失败并报错 `(job) is used for configuration only, and its script should not be executed`。

`sast` 或 `dependency_scanning` 节可用于对所有 SAST 或依赖项扫描进行更改，例如更改 `variables` 或 `stage`，但不能用于定义共享的 `rules`。

<a id="empty-vulnerability-report-dependency-list-pages"></a>

## 漏洞报告、依赖项列表页面为空

如果流水线包含手动步骤，并且其中有设置了 `allow_failure: false` 选项的作业，且该作业尚未完成，极狐GitLab 无法使用安全报告数据填充所列页面。此时，[漏洞报告](vulnerability_report/_index.md)和[依赖项列表](dependency_list/_index.md)页面将为空。可通过运行流水线手动步骤中的作业来填充这些安全页面。