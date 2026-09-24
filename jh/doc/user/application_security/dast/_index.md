---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 动态应用程序安全测试
description: 自动化渗透测试、漏洞检测、Web 应用扫描、安全评估以及 CI/CD 集成。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 基于代理的 DAST 分析器已于极狐GitLab 16.9 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/430966)，
> 并在极狐GitLab 17.3 中[移除](https://gitlab.com/groups/gitlab-org/-/epics/11986)。
> 此变更是一个重大变更。有关如何从基于代理的 DAST 分析器迁移到 DAST 版本 5 的说明，请参阅
> [基于代理的迁移指南](proxy_based_to_browser_based_migration_guide.md)。有关如何从基于浏览器的 DAST 版本 4 分析器迁移到 DAST 版本 5 的说明，请参阅
> [基于浏览器的迁移指南](browser_based_4_to_5_migration_guide.md)。

动态应用程序安全测试 (DAST) 运行自动化渗透测试，以便在你的 Web 应用和 API 运行时发现其中的漏洞。DAST 模拟黑客的攻击手法，并针对跨站脚本 (XSS)、SQL 注入 (SQLi) 和跨站请求伪造 (CSRF) 等严重威胁模拟真实世界的攻击，从而发现其他安全工具无法检测到的漏洞和错误配置。

DAST 是完全语言无关的，会从外部对你的应用程序进行检查。DAST 扫描可以在 CI/CD 流水线中运行、按计划执行或手动按需执行。在软件开发生命周期中使用 DAST，使你能够在部署到生产环境之前发现应用程序中的漏洞。DAST 是软件安全的基础组件，应与其他极狐GitLab 安全工具一起使用，以对应用程序进行全面安全评估。

## 极狐GitLab DAST

极狐GitLab DAST 和 API 安全分析器是专有的运行时工具，为现代 Web 应用和 API 提供广泛的安全覆盖。

根据你的需要使用 DAST 分析器：

- 要扫描基于 Web 的应用程序（包括单页 Web 应用程序）已知漏洞，请使用 [DAST](browser/_index.md) 分析器。
- 要扫描 API 已知漏洞，请使用 [API 安全](../api_security_testing/_index.md) 分析器。支持 GraphQL、REST 和 SOAP 等技术。

分析器遵循[保护你的应用程序](../_index.md)中描述的架构模式。每个分析器都可以使用 CI/CD 模板在流水线中进行配置，并在 Docker 容器中运行扫描。扫描会输出一个 [DAST 报告产物](../../../ci/yaml/artifacts_reports.md#artifactsreportsdast)，极狐GitLab 会根据源分支和目标分支上的扫描结果差异来确定发现的漏洞。

## 查看扫描结果

检测到的漏洞会显示在[合并请求](../detect/security_scanning_results.md)、[流水线安全选项卡](../detect/security_scanning_results.md) 和[漏洞报告](../vulnerability_report/_index.md)中。

> [!note]
> 流水线可能包含多个作业，包括 SAST 和 DAST 扫描。如果任何作业因任何原因未能完成，安全仪表盘将不会显示 DAST 扫描器的输出。例如，如果 DAST 作业完成但 SAST 作业失败，安全仪表盘就不会显示 DAST 结果。失败时，分析器会输出退出代码。

### 列出已扫描的 URL

当 DAST 完成扫描后，合并请求页面会显示已扫描的 URL 数量。选择 **查看详情** 查看 Web 控制台输出，其中包括已扫描的 URL 列表。