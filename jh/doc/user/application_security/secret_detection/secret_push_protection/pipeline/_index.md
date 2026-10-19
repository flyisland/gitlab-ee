---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 流水线密钥检测
---

<!-- markdownlint-disable MD025 -->

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐 GitLab 流水线密钥检测扫描文件在提交到 Git 仓库并推送到极狐 GitLab 后。

在您[启用流水线密钥检测](#enable-the-analyzer)后，扫描将在名为 `secret_detection` 的 CI/CD 作业中运行。您可以在任何极狐 GitLab 版本中运行扫描并查看[流水线密钥检测 JSON 报告产物](../../../../../ci/yaml/artifacts_reports.md#artifactsreportssecret_detection)。

使用极狐 GitLab 旗舰版时，流水线密钥检测结果也会被处理，因此您可以：

- 在[合并请求小部件](../../../detect/security_scan_results.md#merge-request)、[流水线安全报告](../../../vulnerability_report/pipeline.md)和[漏洞报告](../../../vulnerability_report/_index.md)中查看它们。
- 在审批工作流程中使用它们。
- 在安全仪表板中查看它们。
- [自动响应](../../automatic_response.md)公共仓库中的泄漏。
- 使用[安全策略](../../../policies/_index.md)在项目中实施一致的密钥检测规则。

<a id="availability"></a>

## 可用性

不同的功能在不同的[极狐 GitLab 版本](https://gitlab.cn/pricing/)中可用。

| 功能                                                                                               | 在基础版和专业版中       | 在旗舰版中                |
|:----------------------------------------------------------------------------------------------------|:------------------------|:------------------------|
| [自定义分析器行为](configure.md#customize-analyzer-behavior)                                        | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 |
| 下载[输出](#output)                                                                                | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 |
| 在合并请求小部件中查看新发现                                                                        | {{< icon name="dotted-circle" >}} 否 | {{< icon name="check-circle" >}} 是 |
| 在流水线的 **安全** 标签中查看识别的密钥                                                            | {{< icon name="dotted-circle" >}} 否 | {{< icon name="check-circle" >}} 是 |
| [管理漏洞](../../../vulnerability_report/_index.md)                                                     | {{< icon name="dotted-circle" >}} 否 | {{< icon name="check-circle" >}} 是 |
| [访问安全仪表板](../../../security_dashboard/_index.md)                                                | {{< icon name="dotted-circle" >}} 否 | {{< icon name="check-circle" >}} 是 |
| [自定义分析器规则集](configure.md#customize-analyzer-rulesets)                                      | {{< icon name="dotted-circle" >}} 否 | {{< icon name="check-circle" >}} 是 |
| [启用安全策略](../../../policies/_index.md)                                                            | {{< icon name="dotted-circle" >}} 否 | {{< icon name="check-circle" >}} 是 |

<a id="coverage"></a>

## 覆盖范围

流水线密钥检测经过优化，以平衡覆盖范围和运行时间。只有当前状态的仓库和未来提交会被扫描以检测密钥。为了识别仓库历史中已经存在的密钥，请在启用流水线密钥检测后运行一次历史扫描。扫描结果只有在流水线完成后才可用。

具体扫描什么类型的密钥取决于流水线的类型，以及是否设置了其他配置。

默认情况下，当您运行流水线时：

- 在分支上：
  - 在**默认分支**上，Git 工作树会被扫描。这意味着整个仓库会被扫描，就像它是一个典型的目录一样。
  - 在**新建的非默认分支**上，从父分支的最新提交到最新提交的所有提交的内容会被扫描。
  - 在**现有的非默认分支**上，从最后推送的提交到最新提交的所有提交的内容会被扫描。
- 在**合并请求**中，分支上的所有提交内容都会被扫描。如果分析器不能访问每个提交，则会扫描从父提交到最新提交的所有提交内容。要使用合并请求流水线，您必须使用[`最新`流水线密钥检测模板](../../../detect/roll_out_security_scanning.md#use-security-scanning-tools-with-merge-request-pipelines)。

要覆盖默认行为，请使用[可用的 CI/CD 变量](configure.md#available-cicd-variables)。

<a id="run-a-historic-scan"></a>

### 运行历史扫描

默认情况下，流水线密钥检测仅扫描 Git 仓库的当前状态。仓库历史中包含的任何密钥都不会被检测到。运行历史扫描以检查 Git 仓库中所有提交和分支中的密钥。

您应该在启用流水线密钥检测后仅运行一次历史扫描。历史扫描可能需要很长时间，尤其是对于大型仓库和冗长的 Git 历史记录。在完成初始历史扫描后，仅使用标准流水线密钥检测作为您的流水线的一部分。

要运行历史扫描：

1. 在左侧边栏，选择 **搜索或转到**，找到您的项目。
1. 选择 **构建 > 流水线**。
1. 选择 **新建流水线**。
1. 添加一个 CI/CD 变量：
   1. 从下拉列表中选择 **变量**。
   1. 在 **输入变量键** 框中输入 `SECRET_DETECTION_HISTORIC_SCAN`。
   1. 在 **输入变量值** 框中输入 `true`。
1. 选择 **新建流水线**。

<a id="advanced-vulnerability-tracking"></a>

### 高级漏洞追踪

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.0。

{{< /history >}}

当开发人员对包含已识别密钥的文件进行更改时，这些密钥的位置也可能会发生变化。流水线密钥检测可能已经将这些密钥标记为漏洞，并在[漏洞报告](../../../vulnerability_report/_index.md)中进行追踪。这些漏洞与特定的密钥相关联，以便于识别和采取行动。然而，如果检测到的密钥在其移动时没有得到准确的追踪，管理漏洞将变得困难，可能导致重复的漏洞报告。

流水线密钥检测使用高级漏洞追踪算法来更准确地识别同一密钥在文件中由于重构或不相关更改而移动时的情况。

<a id="unsupported-workflows"></a>

#### 不支持的工作流程

- 算法不支持现有发现缺乏追踪签名且与新检测到的发现不共享同一位置的工作流程。
- 对于某些规则类型，例如加密密钥，流水线密钥检测通过匹配密钥的前缀而不是整个密钥值来识别泄漏。在这种情况下，算法将文件中同一规则类型的不同密钥合并为一个发现，而不是将每个不同的密钥视为单独的发现。例如，SSH 私钥规则类型仅匹配值的 `-----BEGIN OPENSSH PRIVATE KEY-----` 前缀以确认 SSH 私钥的存在。如果同一文件中有两个不同的 SSH 私钥，算法会将这两个值视为相同，并只报告一个发现而不是两个。
- 算法的范围仅限于每个文件的基础上，这意味着在两个不同文件中出现的同一密钥被视为两个不同的发现。

<a id="detected-secrets"></a>

### 检测到的密钥

流水线密钥检测扫描仓库的内容以寻找特定模式。每个模式匹配特定类型的密钥，并使用 TOML 语法在规则中指定。极狐 GitLab 维护默认的规则集。

使用极狐 GitLab 旗舰版，您可以扩展这些规则以满足您的需求。例如，使用自定义前缀的个人访问令牌默认情况下不会被检测到，但您可以自定义规则以识别这些令牌。有关详细信息，请参阅[自定义分析器规则集](configure.md#customize-analyzer-rulesets)。

要确认哪些密钥是通过流水线密钥检测检测到的，请参阅[检测到的密钥](../../detected_secrets.md)。为了提供可靠的高置信度结果，流水线密钥检测仅在特定上下文中寻找密码或其他非结构化密钥，例如 URL。

当检测到密钥时，会为其创建一个漏洞。即使密钥从已扫描文件中移除并再次运行流水线密钥检测，该漏洞仍然保持为“仍然检测到”。这是因为密钥仍然存在于 Git 仓库的历史中。要从 Git 仓库的历史中移除密钥，请参阅[从仓库中删除文本](../../../../project/merge_requests/revert_changes.md#redact-text-from-repository)。

<a id="enable-the-analyzer"></a>

## 启用分析器

启用分析器以使用流水线密钥检测。启用后，您可以[自定义分析器设置](configure.md)。

先决条件：

- 基于 Linux 的极狐 GitLab Runner 使用 [`docker`](https://gitlab.cn/docs/runner/executors/docker.html) 或
  [`kubernetes`](https://gitlab.cn/docs/runner/install/kubernetes.html) 执行器。如果您使用的是
  极狐 GitLab.com 托管 runner，则默认启用。
  - 不支持 Windows Runner。
  - 不支持除 amd64 之外的 CPU 架构。
- 极狐 GitLab CI/CD 配置 (`.gitlab-ci.yml`) 必须包含 `test` 阶段。

要启用流水线密钥检测，可以：

- 启用[自动 DevOps](../../../../../topics/autodevops/_index.md)，其中包括[自动密钥检测](../../../../../topics/autodevops/stages.md#auto-secret-detection)。
- [手动编辑 `.gitlab-ci.yml` 文件](#edit-the-gitlab-ciyml-file-manually)。如果您的 `.gitlab-ci.yml` 文件复杂，请使用此方法。
- [使用自动配置的合并请求](#use-an-automatically-configured-merge-request)。

<a id="edit-the-gitlab-ciyml-file-manually"></a>

### 手动编辑 `.gitlab-ci.yml` 文件

此方法需要您手动编辑现有的 `.gitlab-ci.yml` 文件。如果您的极狐 GitLab CI/CD 配置文件复杂，请使用此方法。

1. 在左侧边栏，选择 **搜索或转到**，找到您的项目。
1. 选择 **构建 > 流水线编辑器**。
1. 复制并粘贴以下内容到 `.gitlab-ci.yml` 文件的底部：

   ```yaml
   include:
     - template: Jobs/Secret-Detection.gitlab-ci.yml
   ```

1. 选择 **验证** 标签，然后选择 **验证流水线**。
   **模拟成功完成** 消息表示文件有效。
1. 选择 **编辑** 标签。
1. 可选。在 **提交消息** 文本框中自定义提交消息。
1. 在 **分支** 文本框中输入默认分支的名称。
1. 选择 **提交更改**。

流水线现在包括一个流水线密钥检测作业。

<a id="use-an-automatically-configured-merge-request"></a>

### 使用自动配置的合并请求

{{< history >}}

- 引入于极狐GitLab 13.11，部署在功能标志后。默认启用。
- 在极狐GitLab 14.1 中，功能标志被移除。

{{< /history >}}

此方法自动准备一个合并请求，其中包含 `.gitlab-ci.yml` 文件中的流水线密钥检测模板。然后您合并该合并请求以启用流水线密钥检测。

{{< alert type="note" >}}

此方法在没有现有 `.gitlab-ci.yml` 文件或具有最小配置文件时效果最好。如果您有复杂的极狐 GitLab 配置文件，可能无法成功解析，并可能出现错误。在这种情况下，请使用[手动](#edit-the-gitlab-ciyml-file-manually)方法。

{{< /alert >}}

要启用流水线密钥检测：

1. 在左侧边栏，选择 **搜索或转到**，找到您的项目。
1. 选择 **安全 > 安全配置**。
1. 在 **流水线密钥检测** 行中选择 **通过合并请求配置**。
1. 可选。完成字段。
1. 选择 **创建合并请求**。
1. 查看并合并合并请求。

流水线现在包括一个流水线密钥检测作业。

<a id="output"></a>

## 输出

流水线密钥检测将文件 `gl-secret-detection-report.json` 作为作业产物输出。该文件包含检测到的密钥。您可以[下载](../../../../../ci/jobs/job_artifacts.md#download-job-artifacts)文件以便在极狐 GitLab 外部进行处理。

<a id="remediate-a-leaked-secret"></a>

## 修复泄漏的密钥

当检测到密钥时，您应立即轮换它。极狐 GitLab 尝试[自动撤销](../../automatic_response.md)某些类型的泄漏密钥。对于那些没有自动撤销的密钥，您必须手动撤销。

[从仓库历史中清除密钥](../../../../project/repository/repository_size.md#purge-files-from-repository-history)并不能完全解决泄漏问题。原始密钥仍然存在于仓库的任何现有分叉或克隆中。

有关如何响应泄漏密钥的说明，请在漏洞报告中选择漏洞。

<a id="fips-enabled-images"></a>

## FIPS 启用的镜像

{{< history >}}

- 引入于极狐GitLab 14.10。

{{< /history >}}

默认扫描器镜像是基于 Alpine 镜像构建的，以确保大小和可维护性。极狐 GitLab 提供 Red Hat UBI 版本的镜像，这些镜像是 FIPS 启用的。

要使用 FIPS 启用的镜像，可以：

- 设置 `SECRET_DETECTION_IMAGE_SUFFIX` CI/CD 变量为 `-fips`。
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

调试级别日志记录可以帮助进行故障排除。有关详细信息，请参阅[调试级别日志记录](../../../troubleshooting_application_security.md#debug-level-logging)。

<a id="warning-gl-secret-detection-reportjson-no-matching-files"></a>

#### 警告: `gl-secret-detection-report.json: no matching files`

有关此信息，请参阅[一般应用安全故障排除部分](../../../../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)。

<a id="error-couldnt-run-the-gitleaks-command-exit-status-2"></a>

#### 错误: `Couldn't run the gitleaks command: exit status 2`

流水线密钥检测分析器依赖于在提交之间生成补丁以扫描内容中的密钥。如果合并请求中的提交数量超过了[`GIT_DEPTH` CI/CD 变量](../../../../../ci/runners/configure_runners.md#shallow-cloning)的值，密钥检测将[无法检测到密钥](#error-couldnt-run-the-gitleaks-command-exit-status-2)。

例如，您可能有一个包含 60 个提交的合并请求触发的流水线，并且 `GIT_DEPTH` 变量设置为小于 60。在这种情况下，流水线密钥检测作业会失败，因为克隆深度不足以包含所有相关的提交。要验证当前值，请参阅[流水线配置](../../../../../ci/pipelines/settings.md#limit-the-number-of-changes-fetched-during-clone)。

要确认这是错误的原因，请启用[调试级别日志记录](../../../troubleshooting_application_security.md#debug-level-logging)，然后重新运行流水线。日志应类似于以下示例。文本“对象未找到”是此错误的症状。

```plaintext
ERRO[2020-11-18T18:05:52Z] object not found
[ERRO] [secrets] [2020-11-18T18:05:52Z] ▶ Couldn't run the gitleaks command: exit status 2
[ERRO] [secrets] [2020-11-18T18:05:52Z] ▶ Gitleaks analysis failed: exit status 2
```

要解决此问题，请将[`GIT_DEPTH` CI/CD 变量](../../../../../ci/runners/configure_runners.md#shallow-cloning)设置为更高的值。要仅对流水线密钥检测作业应用此设置，可以在您的 `.gitlab-ci.yml` 文件中添加以下内容：

```yaml
secret_detection:
  variables:
    GIT_DEPTH: 100
```

<a id="error-err-fatal-ambiguous-argument"></a>

#### 错误: `ERR fatal: ambiguous argument`

如果您的仓库默认分支与作业触发的分支无关，流水线密钥检测可能会失败并出现 `ERR fatal: ambiguous argument` 错误。

要解决此问题，请确保正确设置仓库中的[默认分支](../../../../project/repository/branches/default.md#change-the-default-branch-name-for-a-project)。您应该将其设置为与您运行 `secret-detection` 作业的分支具有相关历史的分支。

<a id="exec-bin-sh-exec-format-error-message-in-job-log"></a>

#### `exec /bin/sh: exec format error` 消息在作业日志中

极狐 GitLab 流水线密钥检测分析器[仅支持](#enable-the-analyzer)在 `amd64` CPU 架构上运行。此消息表示作业在不同的架构上运行，例如 `arm`。

<a id="error-fatal-detected-dubious-ownership-in-repository-at-builds-project-dir"></a>

#### 错误: `fatal: detected dubious ownership in repository at '/builds/<project dir>'`

密钥检测可能会失败并出现 128 状态码。这可能是由于 Docker 镜像上的用户更改导致的。

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

要解决此问题，请添加一个 `before_script`，内容如下：

```yaml
before_script:
    - git config --global --add safe.directory "$CI_PROJECT_DIR"
```

有关此问题的更多信息，请参阅[问题 465974](https://gitlab.com/gitlab-org/gitlab/-/issues/465974)。

<!-- markdownlint-enable MD025 -->
