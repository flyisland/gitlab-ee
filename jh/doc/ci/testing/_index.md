---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用极狐GitLab CI/CD 进行测试
description: 生成测试报告、代码质量分析和安全扫描结果，并在合并请求中展示。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab CI/CD 测试特性分支中的变更。你可以直接在[合并请求](../../user/project/merge_requests/_index.md)中展示测试报告并链接到重要信息。

<a id="testing-and-quality-reports"></a>

## 测试和质量报告

你可以生成以下报告：

| 功能                                                                                 | 描述 |
| --------------------------------------------------------------------------------------- | ----------- |
| [可访问性测试](accessibility_testing.md)                                       | 检测变更页面的可访问性违规。 |
| [浏览器性能测试](browser_performance_testing.md)                           | 衡量代码更改对浏览器性能的影响。 |
| [代码覆盖率](code_coverage/_index.md)                                                | 查看测试覆盖率结果、差异中的逐行覆盖率和整体指标。 |
| [代码质量](code_quality.md)                                                         | 使用 Code Climate 分析源代码质量。 |
| [展示任意任务产物](../yaml/_index.md#artifactsexpose_as)                 | 使用 `artifacts:expose_as` 链接到选定的任务产物。 |
| [快速失败测试](fail_fast_testing.md)                                               | 当 RSpec 测试失败时尽早停止流水线。 |
| [许可证扫描](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md) | 扫描并管理依赖项的许可证。 |
| [负载性能测试](load_performance_testing.md)                                 | 衡量代码更改对服务器性能的影响。 |
| [指标报告](metrics_reports.md)                                                   | 追踪自定义指标，如内存使用和性能。 |
| [单元测试报告](unit_test_reports.md)                                               | 查看测试结果并识别失败，无需检查任务日志。 |

<a id="security-reports"></a>

## 安全报告

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

你可以通过扫描项目中的漏洞来生成[安全报告](../../user/application_security/_index.md)：

| 功能                                                                                       | 描述 |
| --------------------------------------------------------------------------------------------- | ----------- |
| [容器扫描](../../user/application_security/container_scanning/_index.md)            | 扫描 Docker 镜像中的漏洞。 |
| [动态应用程序安全测试 (DAST)](../../user/application_security/dast/_index.md) | 扫描正在运行的 Web 应用程序中的漏洞。 |
| [依赖项扫描](../../user/application_security/dependency_scanning/_index.md)          | 扫描依赖项中的漏洞。 |
| [静态应用程序安全测试 (SAST)](../../user/application_security/sast/_index.md)  | 扫描源代码中的漏洞。 |