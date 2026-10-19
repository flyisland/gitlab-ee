---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何通过选择测试代码库、配置扫描、解读结果以及与其他安全工具比较功能来评估极狐GitLab SAST。
title: 评估极狐GitLab SAST
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可能会选择在组织中使用极狐GitLab SAST 之前先对其进行评估。在规划和开展评估时，请参考以下指导。

<a id="important-concepts"></a>

## 重要概念

极狐GitLab SAST 旨在帮助团队协作提升所编写代码的安全性。扫描代码和查看结果所采取的步骤都围绕被扫描的源代码仓库展开。

<a id="scanning-process"></a>

### 扫描过程

极狐GitLab SAST 会根据项目中发现的编程语言自动选择要使用的合适扫描技术。对于除 Groovy 之外的所有语言，极狐GitLab SAST 会直接扫描您的源代码，无需编译或构建步骤。这使得在各种项目中启用扫描变得更加容易。有关详情，请参阅[支持的编程语言和框架](_index.md#supported-languages-and-frameworks)。

<a id="when-vulnerabilities-are-reported"></a>

### 报告漏洞的时机

极狐GitLab SAST 的[分析器](analyzers.md)及其[规则](rules.md)旨在尽可能减少对开发团队和安全团队的干扰。

有关极狐GitLab 高级 SAST 分析器何时报告漏洞的详情，请参阅[漏洞检测标准](gitlab_advanced_sast.md#vulnerability-detection-criteria)。

<a id="other-platform-features"></a>

### 其他平台功能

SAST 与极狐GitLab 旗舰版中的其他安全与合规功能集成。如果您将极狐GitLab SAST 与其他产品进行比较，可能会发现它的某些功能实际上包含在极狐GitLab 的相关功能领域中，而不是 SAST 中：

- [IaC 扫描](../iac_scanning/_index.md)会扫描您的基础设施即代码（IaC）定义，以发现安全问题。
- [密钥检测](../secret_detection/_index.md)会查找代码中泄露的密钥。
- [安全策略](../policies/_index.md)允许您强制运行扫描，或要求必须修复漏洞。
- [漏洞管理与报告](../vulnerability_report/_index.md)管理代码库中存在的漏洞，并与议题跟踪器集成。
- 极狐GitLab Duo 的[漏洞解释](../analyze/duo.md)和[漏洞修复](../remediate/duo.md)可借助 AI 帮助您快速修复漏洞。

<a id="choose-a-test-codebase"></a>

## 选择测试代码库

在选择用于测试 SAST 的代码库时，您应该：

- 在可以安全修改 CI/CD 配置、且不会妨碍正常开发活动的代码仓库中进行测试。
  SAST 扫描在您的 CI/CD 流水线中运行，因此您需要对 CI/CD 配置做少量修改以[启用 SAST](_index.md#configuration)。
  - 您可以创建现有代码仓库的复刻或副本用于测试。这样，您就可以搭建测试环境，而不会干扰正常开发。
- 使用与您组织典型技术栈相匹配的代码库。
- 使用[极狐GitLab 高级 SAST 支持](gitlab_advanced_sast.md#supported-languages)的语言。
  极狐GitLab 高级 SAST 生成的结果比其他[分析器](analyzers.md)更准确。

您的测试项目必须拥有极狐GitLab 旗舰版。只有旗舰版才包含以下[功能](_index.md#features)：

- 使用极狐GitLab 高级 SAST 进行专有的跨文件、跨函数扫描。
- 合并请求的**报告**标签页、流水线安全报告以及默认分支漏洞报告，使扫描结果可见且可操作。

<a id="benchmarks-and-example-projects"></a>

### 基准测试和示例项目

如果您选择使用基准测试或故意存在漏洞的应用程序进行测试，请记住这些应用程序：

- 侧重于特定的漏洞类型。
  基准测试的关注点可能与您组织优先发现和修复的漏洞类型不同。
- 以特定方式使用特定技术，这可能与您组织构建软件的方式不同。
- 报告结果的方式可能会隐含地强调某些标准而忽略其他标准。
  例如，您可能优先考虑精确率（更少的误报结果），而基准测试仅根据召回率（更少的漏报结果）评分。

[史诗 15296](https://gitlab.com/groups/gitlab-org/-/epics/15296) 跟踪推荐特定测试项目的工作。

<a id="ai-generated-test-code"></a>

### AI 生成的测试代码

您不应使用 AI 工具创建存在漏洞的代码来测试 SAST。AI 模型返回的代码往往并非真正可利用。

例如：

- AI 工具常常编写接收参数并在敏感上下文（称为“汇聚点”）中使用该参数的小型函数，但实际上并未接收任何用户输入。
  如果该函数仅使用程序控制的值（如常量）调用，这可能是一种安全的设计。
  除非允许用户输入在未经清理或验证的情况下流向这些汇聚点，否则代码并不存在漏洞。
- AI 工具可能会注释掉部分漏洞，以防止您意外运行该代码。

在这些不切实际的示例中报告漏洞，会在真实代码中造成误报结果。极狐GitLab SAST 并非设计用于在这些情况下报告漏洞。

<a id="conduct-the-test"></a>

## 开展测试

先决条件：

- 项目的维护者或所有者角色。

选择好用于测试的代码库后，您就可以开展测试了。您可以按照以下步骤操作：

1. 通过创建一个将 SAST 添加到 CI/CD 配置的合并请求来[启用 SAST](_index.md#configuration)。
   - 请务必将 CI/CD 变量设置为[开启极狐GitLab 高级 SAST](gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)，以获得更准确的结果。
1. 将该合并请求合并到代码仓库的默认分支。
1. 打开[漏洞报告](../vulnerability_report/_index.md)，查看在默认分支上发现的漏洞。
   - 如果您使用的是极狐GitLab 高级 SAST，可以使用[扫描器筛选](../vulnerability_report/_index.md#scanner-filter)仅显示该扫描器的结果。
1. 查看漏洞结果。
   - 对于涉及受污染用户输入的极狐GitLab 高级 SAST 漏洞（如 SQL 注入或路径遍历），请查看[代码流视图](../vulnerabilities/_index.md#vulnerability-code-flow)。
   - 如果您拥有极狐GitLab Duo Enterprise，可以[解释](../analyze/duo.md)或[修复](../remediate/duo.md)漏洞。
1. 要了解在开发新代码时扫描如何工作，请创建一个新的合并请求，更改应用程序代码并添加新的漏洞或弱点。
