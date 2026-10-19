---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 检测
description: 漏洞检测与结果评估。
---

在软件开发生命周期中检测项目代码仓库和应用程序行为中的漏洞。

为帮助您在开发过程中管理漏洞风险：

- 当您将代码变更推送到分支时，安全扫描器会运行。
- 您可以查看分支中检测到的漏洞详情。开发者可以在此阶段修复漏洞，在漏洞进入生产环境之前将其解决。
- 您也可以选择对[包含漏洞的合并请求](../../project/merge_requests/widgets.md#application-security-scanning)强制执行额外的审批。详情请参见[合并请求审批策略](../policies/merge_request_approval_policies.md)。

为帮助管理开发之外的漏洞：

- 安全扫描可以按计划运行，也可以手动运行。
- 在默认分支中检测到的漏洞会显示在[漏洞报告](../vulnerability_report/_index.md)中。使用此报告排查、分析和修复漏洞。

<a id="security-scanning"></a>

## 安全扫描

要充分利用安全扫描，了解以下内容很重要：

- 如何触发安全扫描。
- 应用程序或代码仓库的哪些方面会被扫描。
- 哪些因素决定运行哪些扫描器。
- 安全扫描如何发生。

<a id="triggers"></a>

### 触发器

默认情况下，当变更被推送到项目的代码仓库时，会触发 CI/CD 流水线中的安全扫描。

您还可以通过以下方式运行安全扫描：

- [手动运行 CI/CD 流水线](../../../ci/pipelines/_index.md#run-a-pipeline-manually)。
- 使用[扫描执行策略](../policies/scan_execution_policies.md)安排安全扫描。
- 仅适用于 DAST：[手动运行按需 DAST 扫描](../dast/on-demand_scan.md)或[按计划运行](../../../ci/pipelines/schedules.md)。
- 仅适用于 SAST：使用 [GitLab for VS Code 扩展](../../../editor_extensions/visual_studio_code/security_scanning.md#perform-sast-scanning)运行扫描。

<a id="detection-coverage"></a>

### 检测覆盖范围

扫描项目的代码仓库并测试应用程序的行为，以发现漏洞：

- 代码仓库扫描可以检测项目代码仓库中的漏洞。覆盖范围包括应用程序的源代码，以及它所依赖的库和容器镜像。
- 对应用程序及其 API 的行为测试可以检测仅在运行时出现的漏洞。

<a id="repository-scanning"></a>

#### 代码仓库扫描

项目的代码仓库可能包含源代码、依赖声明和基础设施定义。代码仓库扫描可以检测其中每一项的漏洞。

代码仓库扫描工具包括：

- 静态应用程序安全测试（SAST）：分析源代码中的漏洞。
- 基础设施即代码（IaC）扫描：检测应用程序基础设施定义中的漏洞。
- 密钥检测：检测并阻止密钥被提交到代码仓库。
- 依赖扫描：检测应用程序依赖项和容器镜像中的漏洞。

<a id="behavioral-testing"></a>

#### 行为测试

行为测试需要可部署的应用程序，以测试已知漏洞和意外行为。

行为测试工具包括：

- 动态应用程序安全测试（DAST）：测试应用程序是否存在已知攻击向量。
- API 安全测试：测试应用程序的 API 是否存在已知攻击以及输入相关的漏洞。
- 覆盖率引导的模糊测试：测试应用程序是否存在意外行为。

<a id="scanner-selection"></a>

### 扫描器选择

为项目启用安全扫描器的方式有两种：

- 将扫描器的 CI/CD 模板添加到 `.gitlab-ci.yml` 文件中，可以直接添加，也可以通过 [AutoDevOps](../../../topics/autodevops/_index.md) 添加。
- 使用扫描执行策略、流水线执行策略或[合规框架](../../compliance/compliance_frameworks/_index.md)强制执行扫描器。此强制执行可以直接应用于项目，也可以从项目的父群组继承。

更多详情，请参见[安全配置](security_configuration.md)。

<a id="security-scanning-process"></a>

### 安全扫描流程

安全扫描流程如下：

1. 根据 CI/CD 作业条件，那些已启用并计划在流水线中运行的扫描器会作为单独的作业运行。

   每个成功的作业都会输出一个或多个安全报告作为作业产物。这些报告包含分支中检测到的所有漏洞的详情，无论这些漏洞是之前发现的、已忽略的，还是新发现的。
1. 每个安全报告都会被处理，包括[验证](security_report_validation.md)和[去重](vulnerability_deduplication.md)。
1. 当所有作业（包括手动作业）完成后，您可以下载或查看结果。

有关安全扫描输出的更多详情，请参见[安全扫描结果](security_scanning_results.md)。

<a id="cicd-security-job-criteria"></a>

#### CI/CD 安全作业条件

CI/CD 流水线中的安全扫描作业由以下条件决定：

1. 包含安全扫描模板

   安全扫描作业的选择首先取决于包含或由策略、合规框架强制执行的模板。

   安全扫描默认在分支流水线中运行。要在合并请求流水线中运行安全扫描，您必须专门[启用它](security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。
1. 规则评估

   每个模板都定义了[规则](../../../ci/yaml/_index.md#rules)，用于决定是否运行分析器。

   例如，某些分析器仅在代码仓库中检测到特定类型的文件时才运行。
1. 分析器逻辑

   如果模板的规则指示应运行该作业，则会在模板指定的流水线阶段中创建一个作业。但是，每个分析器都有自己的逻辑，用于决定是否运行分析器本身。

   例如，如果依赖扫描在默认深度下未检测到受支持的文件，则不会运行分析器，也不会输出任何产物。

如果作业完成扫描，即使未发现漏洞，作业也会通过。唯一的例外是覆盖率模糊测试，如果它发现了问题，则会失败。所有作业都允许失败，这样它们就不会导致整个流水线失败。请勿更改作业的 [`allow_failure` 设置](../../../ci/yaml/_index.md#allow_failure)，因为那会导致整个流水线失败。

<a id="data-privacy"></a>

## 数据隐私

极狐GitLab 在极狐GitLab Runner 上本地处理源代码并执行分析。不会将任何数据传输到极狐GitLab 基础设施（服务器和 Runner）之外。

安全分析器仅在下载最新的签名、规则和补丁集时访问互联网。如果您希望扫描器不访问互联网，请考虑使用[离线环境](../offline_deployments/_index.md)。
