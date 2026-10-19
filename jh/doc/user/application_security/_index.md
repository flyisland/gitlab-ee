---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '应用安全测试'
description: 扫描、漏洞、合规、自定义和报告。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 应用安全测试可在开发过程中以及更改部署后持续检测漏洞。

应用安全测试会扫描项目的源代码、依赖项、库和容器镜像。运行时漏洞则通过在测试环境中对已部署的应用进行模拟攻击和模糊测试来检测。

在开发过程中，当提交代码或创建合并请求时，扫描会作为 CI/CD 流水线的一部分自动运行。安全发现会直接显示在合并请求和 IDE 中，在代码合并前通知开发者。这种主动方式可降低在开发后期修复问题的成本和工作量。

在开发周期之外，您可以按需运行安全扫描，或将其安排在固定时间间隔运行。随着漏洞数据库更新新发现的威胁和零日漏洞利用，项目软件库和容器镜像面临的新风险会被识别出来。这些方法共同识别出原始开发周期中此前未知的风险。

如需查看点击式演示，请参阅[将安全集成到流水线](https://gitlab.navattic.com/gitlab-scans)。
<!-- Demo published on 2024-01-15 -->

<a id="vulnerability-management-cycle"></a>

## 漏洞管理周期

极狐GitLab 提供全面的漏洞管理工作流，帮助您持续改善应用安全态势。该工作流是一个由检测、排查、分析、修复和优化组成的持续循环。

1. 检测 - 通过自动化安全测试识别漏洞。
1. 排查 - 评估漏洞并确定优先级，以确定哪些需要立即处理，哪些可以稍后处理。
1. 分析 - 对已确认的漏洞进行详细分析，以了解其影响并确定适当的修复策略。
1. 修复 - 修复漏洞的根本原因，或实施适当的风险缓解措施。

利用每个阶段的结果来改进下一个周期。例如，调整检测规则以减少分析期间发现的误报。

```mermaid
%%{init: { "fontFamily": "GitLab Sans" }}%%
flowchart LR
    accTitle: Vulnerability management workflow
    accDescr: A circular workflow showing the continuous cycle of vulnerability management in GitLab

    Detect --> Triage
    Triage --> Analyze
    Analyze --> Remediate
    Remediate -->|Optimize| Detect
```

每次代码更改都会重复此循环，让您可以逐步改进应用安全和漏洞管理流程。这种持续改进意味着您的漏洞管理会随着时间的推移变得更加有效和高效。
