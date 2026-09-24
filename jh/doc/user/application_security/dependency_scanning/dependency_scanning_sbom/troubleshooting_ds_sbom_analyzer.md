---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖扫描 SBOM 分析器故障排查
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用依赖扫描 SBOM 分析器时，您可能会遇到以下问题。

<a id="403-forbidden-error-when-you-use-a-custom-ci_job_token"></a>

## 使用自定义 `CI_JOB_TOKEN` 时出现 `403 Forbidden` 错误

在扫描上传或下载阶段，依赖扫描 SBOM API 可能返回 `403 Forbidden` 错误。

这是因为依赖扫描 SBOM API 要求使用默认的 `CI_JOB_TOKEN` 进行身份验证。
如果您使用自定义令牌（例如项目访问令牌或个人访问令牌）覆盖了 `CI_JOB_TOKEN` 变量，
即使该自定义令牌具有 `api` 权限范围，API 也无法正确验证请求。

要解决此问题，请执行以下任一操作：

- 推荐。移除 `CI_JOB_TOKEN` 覆盖。覆盖预定义变量可能导致意外行为。
  有关更多信息，请参阅 [CI/CD 变量](../../../../ci/variables/_index.md#use-pipeline-variables)。
- 使用不同的变量名。如果您需要在流水线中将自定义令牌用于其他目的，请将其存储在另一个 CI/CD 变量中，例如 `CUSTOM_ACCESS_TOKEN`，
  而不是覆盖 `CI_JOB_TOKEN`。

极狐GitLab 不支持对依赖扫描 API 端点使用[细粒度作业权限](../../../../ci/jobs/fine_grained_permissions.md)，但[议题 578850](https://gitlab.com/gitlab-org/gitlab/-/issues/578850) 提议添加此功能。

<a id="warning-grep-command-not-found"></a>

## 警告：`grep: command not found`

分析器镜像包含最少的依赖项，以减小镜像的攻击面。
因此，其他镜像中常见的工具（如 `grep`）在镜像中缺失。
这可能导致作业日志中出现类似 `/usr/bin/bash: line 3: grep: command not found` 的警告。此警告不影响分析器的结果，可以忽略。

<a id="compliance-framework-compatibility"></a>

## 合规框架兼容性

在极狐GitLab 私有化部署实例上使用基于 SBOM 的依赖扫描时，与合规框架存在兼容性考虑：

- JihuLab.com：“依赖扫描正在运行”合规控制与基于 SBOM 的依赖扫描配合正常。
- 18.4 及更高版本的极狐GitLab 私有化部署：使用基于 SBOM 的依赖扫描（`DS_ENFORCE_NEW_ANALYZER: 'true'`）时，“依赖扫描正在运行”合规控制可能失败，因为不会生成传统的 `gl-dependency-scanning-report.json` 产物。

私有化部署实例的变通方法：如果您需要通过要求“依赖扫描正在运行”控制的合规框架检查，可以使用 `v2` 模板（`Jobs/Dependency-Scanning.v2.gitlab-ci.yml`），该模板会同时生成 SBOM 和依赖扫描报告。

有关合规控制的更多信息，请参阅 [极狐GitLab 合规控制](../../../compliance/compliance_frameworks/_index.md#gitlab-compliance-controls)。

<a id="resolution-job-fails-but-dependency-scanning-still-runs"></a>

## 解析作业失败但依赖扫描仍会运行

由于解析作业会自动运行，它们设置了 `allow_failure: true`。如果解析作业失败，
`dependency-scanning` 作业仍会运行。根据代码仓库中是否提交了锁文件，
扫描会使用已提交的文件，或者在启用时回退到[清单回退](_index.md#manifest-fallback)。

请查看[已知限制](_index.md#dependency-resolution-limitations)，以确认您的用例是否受支持。

要调查解析失败，请检查失败解析作业的 CI/CD 作业日志。
日志包含 DS 分析器服务容器执行的输出以及构建工具命令的输出。如果服务日志不可见，您可以将 `CI_DEBUG_SERVICES` 设置为 `"true"`
以[捕获服务容器日志](../../../../ci/services/_index.md#capturing-service-container-logs)。

如有必要，您可以[禁用依赖解析](_index.md#disable-dependency-resolution)，
并改用手动生成的锁文件。

<a id="dependency-scanning-job-succeeds-but-produces-no-reports"></a>

## 依赖扫描作业成功但未生成报告

如果依赖扫描作业成功完成，但未生成任何 SBOM 或依赖扫描报告产物，则项目可能不包含任何
[受支持的文件](_index.md#supported-languages-and-files)。

请检查 CI/CD 作业日志中是否有类似以下的警告消息：

```plaintext
No compatible file found in <directory>.
```

要解决此问题，请向项目添加受支持的锁文件或依赖关系图导出。有关说明，请参阅
[手动创建锁文件或依赖关系图导出](_index.md#create-lockfile-or-dependency-graph-export-manually)。

<a id="dependency-scanning-job-does-not-run-when-ds_skip_if_no_supported_files-is-set"></a>

## 设置 `DS_SKIP_IF_NO_SUPPORTED_FILES` 后依赖扫描作业不运行

如果 `DS_SKIP_IF_NO_SUPPORTED_FILES` 设置为 `"true"`，且 `dependency-scanning` 作业未出现在
流水线中，则表示未在项目中检测到[受支持的文件](_index.md#supported-languages-and-files)。

某些会触发[依赖解析](_index.md#dependency-resolution)作业的文件可能不会触发依赖扫描作业，因为它们不受支持。例如，`settings.gradle`、
`setup.cfg`、`pyproject.toml` 或 `requirements.in` 不受直接支持。

要解决此问题，请执行以下操作之一：

- 将 `DS_SKIP_IF_NO_SUPPORTED_FILES` 设置为 `"false"` 或保持未设置，以便依赖扫描作业无条件运行。
- 向代码仓库提交[受支持的文件](_index.md#supported-languages-and-files)，例如生成的锁文件或依赖关系图导出。

<a id="error-failed-to-verify-certificate-x509-certificate-signed-by-unknown-authority"></a>

## 错误：`failed to verify certificate: x509: certificate signed by unknown authority`

当依赖扫描分析器连接到主机时，可能会出现以下错误。此错误的原因是主机不信任依赖扫描分析器使用的证书。

```plaintext
failed to verify certificate: x509: certificate signed by unknown authority
```

要解决此问题，请在 `ADDITIONAL_CA_CERT_BUNDLE` CI/CD 变量中提供自签名证书。
之后，依赖扫描分析器在连接到主机时将使用此证书。

`ADDITIONAL_CA_CERT_BUNDLE` 环境变量的值必须是证书本身：

```yaml
include:
  - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml

dependency-scanning:
  variables:
    ADDITIONAL_CA_CERT_BUNDLE: |
      -----BEGIN CERTIFICATE-----
      <...>
      -----END CERTIFICATE-----
  before_script:
    - echo "$ADDITIONAL_CA_CERT_BUNDLE" > /tmp/cacert.pem
    - export SSL_CERT_FILE="/tmp/cacert.pem"
```

<a id="only-dependency-scanning-runs-in-merge-request-pipelines-other-jobs-appear-skipped"></a>

## 仅依赖扫描在合并请求流水线中运行，其他作业显示为跳过

默认情况下，`Dependency-Scanning.v2.gitlab-ci.yml` 模板会在合并请求流水线中运行依赖扫描作业。如果您的项目未对其他作业使用合并请求流水线，则会导致只有依赖扫描作业出现在合并请求流水线中，而所有其他作业在单独的分支流水线中运行。要禁用此行为，请参阅
[为依赖扫描禁用合并请求流水线](_index.md#disable-merge-request-pipelines-for-dependency-scanning)。

如果模板由流水线执行策略注入，即使项目或群组变量设置了 `AST_ENABLE_MR_PIPELINES: "false"`，也会出现此问题。流水线执行策略默认隔离运行，因此策略作业不会收到该值。未设置的变量默认为
`"true"`，作业将无视项目或群组设置，在合并请求流水线中运行。

变通方法是在策略 CI/CD 配置中直接设置 `AST_ENABLE_MR_PIPELINES: "false"`。有关更多信息（包括如何使用项目或群组值），请参阅
[CI/CD 变量](../../policies/pipeline_execution_policies.md#cicd-variables)。
