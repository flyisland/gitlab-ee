---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 检测
description: 漏洞检测与结果评估
---

在软件开发生命周期内，检测项目仓库和应用程序行为中的漏洞。

为了帮助您管理开发过程中的漏洞风险：

- 当您推送代码变更到分支时，安全扫描器会运行。
- 您可以查看分支中检测到的漏洞详情。开发人员可以在此阶段修复漏洞，在它们进入生产环境之前进行修复。
- 可选地，您可以对包含漏洞的合并请求强制执行额外审批。详情请参阅[合并请求审批策略](../policies/merge_request_approval_policies.md)。

为了帮助管理开发之外的漏洞：

- 安全扫描可以计划执行或手动运行。
- 在默认分支中检测到的漏洞会显示在[漏洞报告](../vulnerability_report/_index.md)中。使用该报告对漏洞分类、分析和修复。

<a id="security-scanning"></a>

## 安全扫描

为了充分利用安全扫描，了解以下几点很重要：

- 如何触发安全扫描。
- 应用程序或仓库的哪些方面会被扫描。
- 哪些因素决定哪些扫描器运行。
- 安全扫描如何发生。

<a id="triggers"></a>

### 触发条件

默认情况下，当变更推送到项目仓库时，CI/CD 流水线中的安全扫描会被触发。

您还可以通过以下方式运行安全扫描：

- [手动运行 CI/CD 流水线](../../../ci/pipelines/_index.md#run-a-pipeline-manually)。
- 使用[扫描执行策略](../policies/scan_execution_policies.md)计划安全扫描。
- 仅针对 DAST，手动运行[按需 DAST 扫描](../dast/on-demand_scan.md)或[按计划运行](../../../ci/pipelines/schedules.md)。

<a id="detection-coverage"></a>

### 检测覆盖

扫描项目仓库并测试应用程序行为的漏洞：

- 仓库扫描可以检测项目仓库中的漏洞。覆盖范围包括应用程序的源代码，以及它所依赖的库和容器镜像。
- 对应用程序及其 API 的行为测试可以检测仅运行时出现的漏洞。

<a id="repository-scanning"></a>

#### 仓库扫描

项目仓库可能包含源代码、依赖声明和基础设施定义。仓库扫描可以检测这些内容中的漏洞。

仓库扫描工具包括：

- 静态应用程序安全测试 (SAST)：分析源代码漏洞。
- 基础设施即代码 (IaC) 扫描：检测应用程序基础设施定义中的漏洞。
- 密钥检测：检测并阻止密钥提交到仓库。
- 依赖扫描：检测应用程序依赖项和容器镜像中的漏洞。

<a id="behavioral-testing"></a>

#### 行为测试

行为测试需要一个可部署的应用程序来测试已知漏洞和异常行为。

行为测试工具包括：

- 动态应用程序安全测试 (DAST)：测试应用程序的已知攻击向量。
- API 安全测试：测试应用程序 API 的已知攻击和输入漏洞。
- 覆盖率引导的模糊测试：测试应用程序的异常行为。

<a id="scanner-selection"></a>

### 扫描器选择

安全扫描器通过以下方式为项目启用：

- 将扫描器的 CI/CD 模板添加到 `.gitlab-ci.yml` 文件中，可以直接添加或通过使用 [AutoDevOps](../../../topics/autodevops/_index.md) 添加。
- 使用扫描执行策略、流水线执行策略或[合规框架](../../compliance/compliance_frameworks/_index.md)强制要求扫描器。此强制执行可以直接应用于项目，也可以从项目的父群组继承。

更多详情，请参阅[安全配置](security_configuration.md)。

<a id="security-scanning-process"></a>

### 安全扫描流程

安全扫描流程如下：

1. 根据 CI/CD 作业条件，那些已启用且打算在流水线中运行的扫描器将作为独立作业运行。

   每个成功的作业会输出一个或多个安全报告作为作业产物。这些报告包含分支中检测到的所有漏洞的详细信息，无论它们之前是否被发现、已消除还是新发现的。
1. 每个安全报告会被处理，包括[验证](security_report_validation.md)和[去重](vulnerability_deduplication.md)。
1. 当所有作业完成，包括手动作业，您可以下载或查看结果。

有关安全扫描输出的更多详情，请参阅[安全扫描结果](security_scanning_results.md)。

<a id="cicd-security-job-criteria"></a>

#### CI/CD 安全作业条件

CI/CD 流水线中的安全扫描作业由以下条件决定：

1. 包含安全扫描模板

   安全扫描作业的选择首先由包含或通过策略或合规框架强制要求的模板决定。

   安全扫描默认在分支流水线中运行。要在合并请求流水线中运行安全扫描，您必须[专门启用它](security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。
1. 规则评估

   每个模板定义了[规则](../../../ci/yaml/_index.md#rules)，用于决定分析器是否运行。

   例如，某些分析器只有在仓库中检测到特定类型的文件时才会运行。
1. 分析器逻辑

   如果模板的规则规定作业应运行，则会在模板指定的流水线阶段创建作业。然而，每个分析器有自己的逻辑来决定分析器本身是否运行。

   例如，如果依赖扫描在默认深度未检测到受支持的文件，则分析器不运行，也不输出产物。

如果作业完成了扫描，即使没有发现漏洞，作业也通过。唯一的例外是覆盖率模糊测试，如果发现结果则失败。所有作业都允许失败，以免导致整个流水线失败。不要更改作业 [`allow_failure` 设置](../../../ci/yaml/_index.md#allow_failure)，因为这会失败整个流水线。

<a id="data-privacy"></a>

## 数据隐私

极狐GitLab 处理源代码并在极狐GitLab Runner 本地进行分析。没有数据传输到极狐GitLab 基础设施（服务器和 Runner）之外。

安全分析器访问互联网仅用于下载最新的签名集、规则和补丁。如果您希望扫描器不访问互联网，请考虑使用[离线环境](../offline_deployments/_index.md)。