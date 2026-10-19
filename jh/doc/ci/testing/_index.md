---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用极狐GitLab CI/CD 进行测试
description: 生成测试报告、代码质量分析和安全扫描，并在合并请求中显示。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab CI/CD 在功能分支中测试变更。您可以直接在[合并请求](../../user/project/merge_requests/_index.md)中显示测试报告并链接到重要信息。

<a id="testing-and-quality-reports"></a>

## 测试和质量报告

您可以生成以下报告：

| 功能                                                                                 | 描述 |
| --------------------------------------------------------------------------------------- | ----------- |
| [无障碍测试](accessibility_testing.md)                                       | 检测已更改页面的无障碍违规问题。 |
| [浏览器性能测试](browser_performance_testing.md)                           | 衡量代码变更对浏览器性能的影响。 |
| [代码覆盖率](code_coverage/_index.md)                                                | 查看测试覆盖率结果、差异中的逐行覆盖率以及整体指标。 |
| [代码质量](code_quality.md)                                                         | 使用 Code Climate 分析源代码质量。 |
| [显示任意作业产物](../yaml/_index.md#artifactsexpose_as)                 | 使用 `artifacts:expose_as` 链接到选定的作业产物。 |
| [快速失败测试](fail_fast_testing.md)                                               | 当 RSpec 测试失败时提前停止流水线。 |
| [许可证扫描](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md) | 扫描并管理依赖项许可证。 |
| [负载性能测试](load_performance_testing.md)                                 | 衡量代码变更对服务器性能的影响。 |
| [指标报告](metrics_reports.md)                                                   | 跟踪内存使用率和性能等自定义指标。 |
| [单元测试报告](unit_test_reports.md)                                               | 查看测试结果并识别失败项，无需检查作业日志。 |

<a id="baseline-pipeline-selection"></a>

## 基线流水线选择

合并请求中的无障碍、代码质量、许可证扫描、指标和单元测试报告会将源分支结果与目标分支上的基线流水线进行比较。极狐GitLab 使用以下流程确定基线流水线：

1. 按顺序检查目标分支上是否存在与以下提交 SHA 匹配的流水线：
   1. 创建[合并结果流水线](../pipelines/merged_results_pipelines.md)时
      目标分支的顶端提交。
      此 SHA 仅适用于合并结果流水线。
   1. 合并基准提交（源分支和目标分支的共同祖先）。
   1. 合并请求差异的起始提交。
1. 为第一个存在匹配流水线的 SHA
   选择最近创建的流水线（按流水线 ID）。

基线流水线选择：

- 不按流水线状态进行筛选。
  任何状态的流水线，包括 `running` 或 `failed`，都可以被选为基线。
- 不检查基线流水线是否具有报告产物。

流水线的类型会影响首先匹配哪个提交 SHA：

- 合并结果流水线：基线通常是创建合并结果流水线时
  目标分支顶端的最新流水线。
- [合并请求流水线](../pipelines/merge_request_pipelines.md)和分支流水线：
  基线通常是合并基准提交处目标分支上的最新流水线。

为确保始终有可用于比较的基线：

- 在目标分支上运行流水线，生成您想要比较的报告产物。
- 如果您使用合并请求流水线或分支流水线，
  请确保合并基准提交在目标分支上有一个流水线。

<a id="security-reports"></a>

## 安全报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

您可以通过扫描项目中的漏洞来生成[安全报告](../../user/application_security/_index.md)：

| 功能                                                                                       | 描述 |
| --------------------------------------------------------------------------------------------- | ----------- |
| [容器扫描](../../user/application_security/container_scanning/_index.md)            | 扫描 Docker 镜像中的漏洞。 |
| [动态应用安全测试 (DAST)](../../user/application_security/dast/_index.md) | 扫描正在运行的 Web 应用中的漏洞。 |
| [依赖项扫描](../../user/application_security/dependency_scanning/_index.md)          | 扫描依赖项中的漏洞。 |
| [静态应用安全测试 (SAST)](../../user/application_security/sast/_index.md)  | 扫描源代码中的漏洞。 |
