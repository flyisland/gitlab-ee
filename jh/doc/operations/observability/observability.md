---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: 监控应用性能并排查性能问题。
ignore_in_report: true
title: 可观测性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

极狐GitLab 可观测性在一个平台中提供分布式追踪、指标和日志。没有基数限制。您的团队无需学习其他独立工具。

使用极狐GitLab 可观测性可以：

- 通过跨微服务的分布式追踪监控应用性能。
- 将代码变更与生产环境问题关联起来。
- 无需更改代码即可自动为 CI/CD 流水线插桩。
- 使用 OpenTelemetry 标准发送高基数指标，不受限制。

极狐GitLab 可观测性是一项正在积极演进的实验功能。您现在就可以开始发送追踪、日志和指标。为了熟悉工作流程，请先在非关键服务上试用，然后根据需要扩大使用范围。

极狐GitLab 可观测性对所有版本均可用且免费。[分享反馈或请求功能](#share-your-feedback)。

<a id="get-started"></a>

## 开始使用

1. 设置可观测性，可以在[您的极狐GitLab 私有化部署实例](setup_self_managed.md)上，也可以在 [JihuLab.com](setup_gitlab_com.md) 上。
1. 添加您的 OTLP 端点以[开始发送遥测数据](send.md)，或[查看 CI/CD 流水线遥测数据](ci_cd.md)。
1. 查看您的第一个追踪。
1. 调试一个缓慢的请求。
1. [访问 API](api_access.md) 以编程方式查询数据。
1. 通过 [MCP 服务器](mcp_server.md)连接 AI 助手。

<a id="real-world-usage"></a>

## 实际使用情况

世界各地的团队正在使用极狐GitLab 可观测性来监控其应用和基础设施。

<!-- TODO: Add usage demonstration video showing real debugging workflow
<i class="fa-youtube-play" aria-hidden="true"></i>
For a usage demonstration, see [How to Debug Production Issues with GitLab Observability](VIDEO_URL).
-->

我们的用户正在 JihuLab.com 上使用极狐GitLab 可观测性积极监控其系统（截至 2026 年 4 月 21 日当周）：

- 每天处理超过 5700 万条追踪。
- 超过 3,000 个服务正在被积极监控。

<a id="key-features"></a>

## 主要功能

<a id="monitor-performance-trace-issues"></a>

### 监控性能，追踪问题

更快地发现和调试问题。

- 增强的开发工作流程。将代码变更直接与应用性能指标关联起来，以识别部署何时引入问题。
- 简化的故障响应。在一个地方查看最近的部署、代码变更以及涉及的开发者。

当问题发生时，可以查看：

- 显示慢查询的性能追踪。
- 引入该变更的合并请求。
- 可以修复该问题的开发者。
- 推出该变更的部署。

<a id="unified-platform"></a>

### 统一平台

通过统一的仪表板监控应用性能，该仪表板结合了：

- 分布式追踪。跨微服务跟踪请求以识别瓶颈。
- 指标。随时间跟踪应用和基础设施性能。
- 日志。将日志条目与追踪和指标关联起来，以获得完整的上下文。

集中管理提供：

- 简化的访问管理。新工程师在获得代码仓库访问权限时，会自动获得生产可观测性数据的访问权限。
- 无需切换上下文。无需离开极狐GitLab 即可访问监控数据。

<a id="developer-friendly-integration"></a>

### 对开发者友好的集成

在评估极狐GitLab 可观测性时，将相同的 OpenTelemetry 数据发送到多个后端。

- 从 Datadog 或 New Relic 迁移。如果您正在使用 OpenTelemetry，只需更改您的 OTLP 端点。
- 无供应商锁定。使用标准的 OpenTelemetry 插桩库。随时通过更改 OTLP 端点来切换提供商。

<a id="fast-setup-and-instrumentation"></a>

### 快速设置和插桩

大多数团队在启用该功能后 5-10 分钟内就能看到他们的第一个追踪。

- 预构建的仪表板。从常见用例的模板开始。
- 自动 CI/CD 插桩。设置一个环境变量，极狐GitLab 就会自动为您的 CI/CD 流水线插桩。

<a id="cost-effective-and-scalable"></a>

### 经济高效且可扩展

- 所有版本均免费。没有按席位、按指标或按主机的费用。对追踪、指标或日志没有限制。
- 没有基数限制。发送高基数指标，无需担心成本。
- 开源模式。直接贡献功能和修复。
- 可预测的成本。不会因指标激增而产生意外账单。

<a id="compliance-and-audit-trails"></a>

### 合规和审计事件记录

该集成会创建全面的审计事件记录，将代码变更与系统行为关联起来。这些记录对于合规要求和事后分析很有价值。

<a id="learn-more"></a>

## 了解更多

- [访问可观测性 API](api_access.md)。以编程方式查询追踪、指标和日志。
- [可观测性 MCP 服务器](mcp_server.md)。使用自然语言从 AI 助手查询您的可观测性数据。
- [OpenTelemetry 文档](https://opentelemetry.io/docs/languages/)。特定语言的插桩指南。
- [GitLab 可观测性模板](https://gitlab.com/gitlab-org/embody-team/experimental-observability/o11y-templates/)。预构建的仪表板和示例。
- [提议的功能](https://gitlab.com/gitlab-org/embody-team/experimental-observability/gitlab_o11y/-/issues/8)

<a id="get-help"></a>

## 获取帮助

- [Discord 社区](https://discord.com/channels/778180511088640070/1379585187909861546)。与其他用户一起参与讨论。
- [GitLab 议题](https://gitlab.com/gitlab-org/embody-team/experimental-observability/gitlab_o11y/-/issues)。报告缺陷或请求功能。
- [故障排除信息](troubleshooting.md)。

<a id="share-your-feedback"></a>

## 分享您的反馈

极狐GitLab 可观测性会根据用户反馈不断改进。要提供反馈：

- 加入 [Discord 频道](https://discord.com/channels/778180511088640070/1379585187909861546)。
- [创建议题](https://gitlab.com/gitlab-org/embody-team/experimental-observability/gitlab_o11y/-/issues)以报告缺陷或请求功能。
