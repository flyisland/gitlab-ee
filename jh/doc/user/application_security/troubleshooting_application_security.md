---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用安全故障排除
description: 如何对极狐GitLab 应用安全功能进行故障排除，包括如何获取更详细的日志记录。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用应用安全功能时，您可能会遇到以下问题。

<a id="logging-level"></a>

## 日志级别

极狐GitLab 分析器输出的日志详细程度由 `SECURE_LOG_LEVEL` 环境变量决定。将输出该日志级别或更高级别的消息。

从最高严重级别到最低严重级别，日志级别依次为：

- `fatal`
- `error`
- `warn`
- `info`（默认）
- `debug`

<a id="turn-on-debug-level-logging"></a>

### 开启 debug 级别日志记录

> [!warning]
> Debug 日志记录可能存在严重的安全风险。输出内容可能包含作业可访问的环境变量内容和其他密钥。输出内容会上传到极狐GitLab 服务器，并可在作业日志中查看。

先决条件：

- 项目的维护者或所有者角色。

要开启 debug 级别日志记录，请将以下内容添加到您的 `.gitlab-ci.yml` 文件中：

```yaml
variables:
  SECURE_LOG_LEVEL: "debug"
```

这会告知所有极狐GitLab 分析器输出所有消息。更多详情，请参见[日志级别](#logging-level)。

<!--
The below subsection (`### Secure job failing with exit code 1`) documentation URL is referred to
in the [`/gitlab-org/security-products/analyzers/command`](https://gitlab.com/gitlab-org/security-products/analyzers/command/-/blob/main/command.go#L19)
repository. If this section/subsection changes, ensure to update the corresponding URL in the mentioned
repository.
-->

<a id="secure-job-failing-with-exit-code-1"></a>

## Secure 作业失败并返回退出代码 1

如果某个 Secure 作业失败，且原因不明：

1. 启用 [debug 级别日志记录](#turn-on-debug-level-logging)。
1. 运行该作业。
1. 检查该作业的输出。
1. 移除 `debug` 日志级别，恢复为默认的 `info` 值。

<a id="outdated-security-reports"></a>

## 过期的安全报告

当为某个合并请求生成的安全报告过期时，该合并请求会在安全扫描报告中显示一条警告消息，并提示您采取适当的操作。

这可能在两种情况下发生：

- 您的[源分支落后于目标分支](#source-branch-is-behind-the-target-branch)。
- [目标分支安全报告已过期](#target-branch-security-report-is-out-of-date)。

<a id="source-branch-is-behind-the-target-branch"></a>

### 源分支落后于目标分支

当目标分支与源分支之间最近的共同祖先提交不是目标分支上的最新提交时，安全报告可能会过期。

要解决此问题，请执行变基或合并，以纳入目标分支的更改。

<a id="target-branch-security-report-is-out-of-date"></a>

### 目标分支安全报告已过期

这可能由多种原因导致，包括作业失败或新的安全公告。当合并请求显示安全报告已过期时，您必须在目标分支上运行新的流水线。选择 **新流水线**以运行新的流水线。

<a id="getting-warning-messages--reportjson-no-matching-files"></a>

## 收到警告消息 `… report.json: no matching files`

> [!warning]
> Debug 日志记录可能存在严重的安全风险。输出内容可能包含作业可访问的环境变量内容和其他密钥。输出内容会上传到极狐GitLab 服务器，并可在作业日志中查看。

此消息后面通常跟着[错误 `No files to upload`](../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)，前面则会有其他错误或警告，说明 JSON 报告未生成的原因。请检查整个作业日志中是否有此类消息。如果找不到这些消息，请在将 `SECURE_LOG_LEVEL: "debug"` 设置为[自定义 CI/CD 变量](../../ci/variables/_index.md#for-a-project)后重试失败的作业。这会提供额外信息，以便进一步调查。

<a id="getting-error-message-sast-job-config-key-may-not-be-used-with-rules-onlyexcept"></a>

## 收到错误消息 `sast job: config key may not be used with 'rules': only/except`

当[包含](../../ci/yaml/_index.md#includetemplate)诸如 [`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml) 之类的 `.gitlab-ci.yml` 模板时，根据您的极狐GitLab CI/CD 配置，可能会出现以下错误：

```plaintext
Unable to run pipeline

    jobs:sast config key may not be used with `rules`: only/except
```

当所包含作业的 `rules` 配置被[已弃用的 `only` 或 `except` 语法](../../ci/yaml/deprecated_keywords.md#only--except)[覆盖](sast/_index.md#override-sast-jobs)时，会出现此错误。要解决此问题，您必须执行以下任一操作：

- [将您的 `only/except` 语法转换为 `rules`](#transitioning-your-onlyexcept-syntax-to-rules)。
- （临时）[将模板固定到已弃用的版本](#pin-your-templates-to-the-deprecated-versions)

更多信息，请参见[覆盖 SAST 作业](sast/_index.md#override-sast-jobs)。

<a id="transitioning-your-onlyexcept-syntax-to-rules"></a>

### 将 `only/except` 语法转换为 `rules`

在覆盖模板以控制作业执行时，之前使用的 [`only` 或 `except`](../../ci/yaml/deprecated_keywords.md#only--except) 不再兼容，必须转换为 [`rules` 语法](../../ci/yaml/_index.md#rules)。

如果您的覆盖旨在将作业限制为仅在 `main` 上运行，之前的语法类似如下：

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

要将之前的配置转换为新的 `rules` 语法，覆盖应编写如下：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

# Ensure that the scanning is only executed on main or merge requests
spotbugs-sast:
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_MERGE_REQUEST_ID
```

如果您的覆盖旨在将作业限制为仅在分支上运行，而不在标签上运行，则类似如下：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

# Ensure that the scanning is not executed on tags
spotbugs-sast:
  except:
    - tags
```

要转换为新的 `rules` 语法，覆盖应重写为：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

# Ensure that the scanning is not executed on tags
spotbugs-sast:
  rules:
    - if: $CI_COMMIT_TAG == null
```

更多信息，请参见 [`rules`](../../ci/yaml/_index.md#rules)。

<a id="pin-your-templates-to-the-deprecated-versions"></a>

### 将模板固定到已弃用的版本

为确保获得最新支持，请迁移到 [`rules`](../../ci/yaml/_index.md#rules)。

如果您无法立即更新 CI/CD 配置，有几种变通方法可以将模板固定到之前的版本，例如：

  ```yaml
  include:
    remote: 'https://jihulab.com/gitlab-cn/gitlab/-/raw/12-10-stable-ee/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml'
  ```

此外，还有一个包含带版本号的旧版模板的专用项目。这可用于离线环境，或供任何希望使用 [Auto DevOps](../../topics/autodevops/_index.md)的用户使用。

相关说明请参见[旧版模板项目](https://gitlab.com/gitlab-org/auto-devops-v12-10)。

<a id="vulnerabilities-are-found-but-the-job-succeeds-how-can-you-have-a-pipeline-fail-instead"></a>

### 发现了漏洞，但作业却成功了。如何让流水线失败？

在这些情况下，作业成功是默认行为。作业的状态表示分析器本身成功或失败。分析器结果显示在[作业日志](../../ci/jobs/job_logs.md#expand-and-collapse-job-log-sections)、[合并请求报告](../project/merge_requests/reports.md)或[安全仪表板](security_dashboard/_index.md)中。

<a id="error-job-is-used-for-configuration-only-and-its-script-should-not-be-executed"></a>

## 错误：作业 `is used for configuration only, and its script should not be executed`

`Security/Dependency-Scanning.gitlab-ci.yml` 和 `Security/SAST.gitlab-ci.yml` 模板意味着，如果您通过设置 `rules` 属性来启用 `sast` 或 `dependency_scanning` 作业，它们会失败并报错 `(job) is used for configuration only, and its script should not be executed`。

`sast` 或 `dependency_scanning` 节可用于对所有 SAST 或依赖扫描进行更改，例如更改 `variables` 或 `stage`，但不能用于定义共享的 `rules`。

[有一个待解决的议题旨在改进可扩展性](https://gitlab.com/gitlab-org/gitlab/-/issues/218444)。您可以为该议题点赞以帮助确定优先级，也[欢迎贡献](https://about.gitlab.com/community/contribute/)。

<a id="empty-vulnerability-report-dependency-list-pages"></a>

## 漏洞报告、依赖列表页面为空

如果流水线包含手动步骤，并且其中设置了 `allow_failure: false` 选项的作业尚未完成，极狐GitLab 无法用安全报告中的数据填充所列页面。在这种情况下，[漏洞报告](vulnerability_report/_index.md)和[依赖列表](dependency_list/_index.md)页面为空。这些安全页面可以通过运行流水线手动步骤中的作业来填充。

[有一个待解决的议题旨在处理此场景](https://gitlab.com/gitlab-org/gitlab/-/issues/346843)。您可以为该议题点赞以帮助确定优先级，也[欢迎贡献](https://about.gitlab.com/community/contribute/)。
