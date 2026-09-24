---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to evaluate GitLab SAST by selecting a test codebase, configuring scans, interpreting results, and comparing features with other security tools.
title: Evaluate 极狐GitLab SAST
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可能选择在使用极狐GitLab SAST 之前对其进行评估。
在规划和进行评估时，请参考以下指南。

<a id="important-concepts"></a>

## 重要概念

极狐GitLab SAST 旨在帮助团队协作提高所编写代码的安全性。
扫描代码和查看结果的步骤都围绕被扫描的源代码仓库展开。

<a id="scanning-process"></a>

### 扫描过程

极狐GitLab SAST 会根据项目中的编程语言自动选择合适的扫描技术。
除 Groovy 外，其他所有语言都无需编译或构建步骤，极狐GitLab SAST 直接扫描源代码。
这使得在多种项目中启用扫描变得更加简单。
详细信息请参阅[支持的语言和框架](_index.md#supported-languages-and-frameworks)。

<a id="when-vulnerabilities-are-reported"></a>

### 漏洞报告时机

极狐GitLab SAST [分析器](analyzers.md)及其[规则](rules.md)的设计宗旨是最大限度减少对开发团队和安全团队的干扰。

有关极狐GitLab Advanced SAST 分析器报告漏洞的详细信息，请参阅[漏洞检测标准](gitlab_advanced_sast.md#vulnerability-detection-criteria)。

<a id="other-platform-features"></a>

### 其他平台功能

SAST 已与极狐GitLab 旗舰版中的其他安全与合规功能集成。
如果您正在将极狐GitLab SAST 与其他产品进行比较，可能会发现某些功能归属于极狐GitLab 的其他功能领域，而非 SAST：

- [IaC 扫描](../iac_scanning/_index.md) 扫描您的基础设施即代码（IaC）定义中的安全问题。
- [密钥检测](../secret_detection/_index.md) 检测代码中泄露的密钥。
- [安全策略](../policies/_index.md) 允许您强制运行扫描或要求修复漏洞。
- [漏洞管理与报告](../vulnerability_report/_index.md) 管理代码库中存在的漏洞，并与议题跟踪器集成。
- 极狐GitLab Duo [漏洞解释](../analyze/duo.md) 和 [漏洞修复](../remediate/duo.md) 通过 AI 帮助您快速修复漏洞。

<a id="choose-a-test-codebase"></a>

## 选择一个测试代码库

在选择用于测试 SAST 的代码库时，您应该：

- 在一个可以安全地修改 CI/CD 配置且不影响正常开发活动的仓库中进行测试。
  SAST 扫描在 CI/CD 流水线中运行，因此您需要对 CI/CD 配置进行少量编辑来[启用 SAST](_index.md#configuration)。
  - 您可以 fork 或复制一个现有仓库用于测试。这样既能搭建测试环境，又不会中断正常开发。
- 使用与您组织典型技术栈相匹配的代码库。
- 使用[极狐GitLab Advanced SAST 支持](gitlab_advanced_sast.md#supported-languages)的语言。
  极狐GitLab Advanced SAST 能产生比其他[分析器](analyzers.md)更精确的结果。

您的测试项目必须使用极狐GitLab 旗舰版。只有旗舰版才包含以下[功能](_index.md#features)：

- 基于极狐GitLab Advanced SAST 的专有跨文件、跨函数扫描。
- 合并请求组件、流水线安全报告和默认分支漏洞报告，使扫描结果可见且可操作。

<a id="benchmarks-and-example-projects"></a>

### 基准和示例项目

如果您选择使用基准或故意存在漏洞的应用程序进行测试，请记住这些应用程序：

- 侧重于特定的漏洞类型。
  基准的关注点可能与贵组织优先发现和修复的漏洞类型不同。
- 以特定方式使用特定技术，这可能与贵组织构建软件的方式不同。
- 报告结果的方式可能隐式侧重某些标准而非其他标准。
  例如，您可能更看重精确率（更少的误报），而基准只基于召回率（更少的漏报）评分。

<a id="ai-generated-test-code"></a>

### AI 生成的测试代码

您不应使用 AI 工具创建存在漏洞的代码来测试 SAST。
AI 模型通常会返回非真正可利用的代码。

例如：

- AI 工具经常编写在敏感上下文（称为“sink”）中接受参数并使用该参数的小函数，但未实际接收任何用户输入。
  如果该函数仅由常量等程序控制值调用，这可能是安全的设计。
  除非允许用户输入在未经净化或验证的情况下流向这些 sink，否则代码并不存在漏洞。
- AI 工具可能会注释掉漏洞代码的一部分，以免您意外运行代码。

在这些不切实际的示例中报告漏洞会导致实际代码中的误报。
极狐GitLab SAST 不会设计为在这些情况下报告漏洞。

<a id="conduct-the-test"></a>

## 进行测试

先决条件：

- 对项目持有维护者或所有者角色。

选择好测试代码库后，即可开始测试。您可以按照以下步骤操作：

1. 创建一个在 CI/CD 配置中添加 SAST 的合并请求（MR）来[启用 SAST](_index.md#configuration)。
   - 请务必设置 CI/CD 变量以[打开极狐GitLab Advanced SAST](gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)，以获得更精确的结果。
1. 将 MR 合并到仓库的默认分支。
1. 打开[漏洞报告](../vulnerability_report/_index.md)，查看在默认分支上发现的漏洞。
   - 如果您使用极狐GitLab Advanced SAST，可以使用[扫描器筛选器](../vulnerability_report/_index.md#scanner-filter)仅显示来自该扫描器的结果。
1. 审查漏洞结果。
   - 对于涉及污点用户输入的极狐GitLab Advanced SAST 漏洞（如 SQL 注入或路径遍历），请查看[代码流视图](../vulnerabilities/_index.md#vulnerability-code-flow)。
   - 如果您拥有极狐GitLab Duo Enterprise，可以[解释](../analyze/duo.md)或[修复](../remediate/duo.md)漏洞。
1. 要了解新代码开发时的扫描工作方式，请创建一个新的合并请求，修改应用程序代码并引入新的漏洞或弱点。