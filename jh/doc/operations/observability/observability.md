---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: Monitor application performance and troubleshoot performance issues.
ignore_in_report: true
title: 可观测性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

{{< history >}}

- 作为一项实验在 极狐GitLab 18.1 中引入，对所有用户可用。

{{< /history >}}

极狐GitLab 可观测性在一个平台上提供了分布式追踪、指标和日志。
没有基数限制。无需您的团队学习单独的工具。

使用 极狐GitLab 可观测性可以：

- 通过跨微服务的分布式追踪来监控应用程序性能。
- 将代码更改与生产问题关联起来。
- 无需更改代码即可自动插桩 CI/CD 流水线。
- 使用 OpenTelemetry 标准发送不受限的高基数指标。

极狐GitLab 可观测性是一项正在积极演进中的实验性功能。
您现在就可以开始发送追踪、日志和指标。为了熟悉工作流，
可以先在非关键服务上试用，然后根据需要扩大使用范围。

极狐GitLab 可观测性对所有版本均免费可用。[分享反馈或请求功能](#分享反馈)。

<a id="get-started"></a>

## 开始使用

1. 设置可观测性，可以通过[私有化部署实例](setup_self_managed.md) 或 [JihuLab.com](setup_gitlab_com.md) 进行。
1. 添加你的 OTLP 端点以[开始发送遥测数据](send.md) 或 [查看 CI/CD 流水线遥测](ci_cd.md)。
1. 查看你的第一个追踪。
1. 调试缓慢请求。

<a id="real-world-usage"></a>

## 真实世界使用情况

极狐GitLab 可观测性正被全球团队用于监控其应用程序和基础设施。

我们的用户正在 JihuLab.com 上使用 极狐GitLab 可观测性积极地监控他们的系统（截至 2026 年 4 月 21 日当周）：

- 每天处理超过 5700 万个追踪数据。
- 超过 3000 个服务正在被积极监控。

<a id="key-features"></a>

## 关键特性

<a id="monitor-performance-trace-issues"></a>

### 监控性能，追踪问题

更快地发现并调试问题。

- 增强的开发工作流。将代码更改直接与应用程序性能指标相关联，以识别部署何时引入了问题。
- 简化的故障响应。在一处查看近期部署、代码更改和相关的开发者。

当问题发生时，可以查看：

- 显示缓慢查询的性能追踪。
- 引入更改的合并请求。
- 可以修复此问题的开发者。
- 推出该更改的部署。

<a id="unified-platform"></a>

### 统一平台

通过一个集成了以下内容的统一仪表板监控应用程序性能：

- 分布式追踪。跨微服务跟踪请求以识别瓶颈。
- 指标。随时间跟踪应用程序和基础设施的性能。
- 日志。将日志条目与追踪和指标关联起来，获得完整的上下文。

集中化管理提供了：

- 简化的访问管理。新工程师在获得仓库访问权限时，会自动获得生产可观测性数据的访问权限。
- 无需上下文切换。无需离开 极狐GitLab 即可访问监控数据。

<a id="developer-friendly-integration"></a>

### 开发者友好集成

在评估 极狐GitLab 可观测性的同时，将相同的 OpenTelemetry 数据发送到多个后端。

- 从 Datadog 或 New Relic 迁移。如果您正在使用 OpenTelemetry，只需更改 OTLP 端点即可。
- 无供应商锁定。使用标准的 OpenTelemetry 插桩库。可以随时通过更改 OTLP 端点来切换提供商。

<a id="fast-setup-and-instrumentation"></a>

### 快速设置和插桩

大多数团队在启用此功能后的 5-10 分钟内就能看到第一批追踪数据。

- 预置仪表板。从常见用例模板开始。
- 自动 CI/CD 插桩。设置一个环境变量，极狐GitLab 就会自动对你的 CI/CD 流水线进行插桩。

<a id="cost-effective-and-scalable"></a>

### 高性价比且可扩展

- 对所有版本免费。没有按席位、按指标或按主机的收费。对追踪、指标或日志没有限制。
- 无基数限制。发送高基数指标而无需担心成本。
- 开源模式。可以直接贡献功能和修复。
- 可预测的成本。不会因指标爆炸而产生意外账单。

<a id="compliance-and-audit-trails"></a>

### 合规与审计追踪

这种集成创建了全面的审计跟踪，将代码更改与系统行为相关联，这对于合规要求和事故后分析非常有价值。

<a id="learn-more"></a>

## 了解更多

- [OpenTelemetry 文档](https://opentelemetry.io/docs/instrumentation/)：针对不同语言的插桩指南。
- [极狐GitLab 可观测性模板](https://gitlab.com/gitlab-org/embody-team/experimental-observability/o11y-templates/)：预置的仪表板和示例。
- [提议的功能](https://gitlab.com/gitlab-org/embody-team/experimental-observability/gitlab_o11y/-/issues/8)

<a id="get-help"></a>

## 获取帮助

- [Discord 社区](https://discord.com/channels/778180511088640070/1379585187909861546)：加入与其他用户的讨论。
- [极狐GitLab 议题](https://gitlab.com/gitlab-org/embody-team/experimental-observability/gitlab_o11y/-/issues)：报告错误或请求功能。
- [故障排除信息](troubleshooting.md)

<a id="share-your-feedback"></a>

## 分享反馈

极狐GitLab 可观测性会根据用户反馈进行增强。要提供反馈：

- 加入 [Discord 频道](https://discord.com/channels/778180511088640070/1379585187909861546)。
- [创建议题](https://gitlab.com/gitlab-org/embody-team/experimental-observability/gitlab_o11y/-/issues) 以报告错误或请求功能。

