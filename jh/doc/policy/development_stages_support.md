---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 支持详情。
title: 对不同开发阶段功能的支持
---

<!--
This page contains information targeting public users and customers of GitLab features.
The goal is to help users understand the risks of using features in various stages of development.

The user-targeted content has been approved by the GitLab legal team.
If you change this information, consider getting a legal team member to review it.

To add information about internal GitLab guidelines for developing and releasing features,
consider adding it to the handbook or to the '## Feature release requirements' section at the end of this page.
-->

极狐GitLab 有时会在不同的开发阶段发布功能，例如实验或测试版。用户可以选择启用并测试新体验。这类功能发布的一些原因包括：

- 针对每个设计用例，验证功能在当前形态下的规模、支持和维护负担等边缘情况。
- 功能尚未完整到可被视为 MVC，但作为开发过程的一部分已添加到代码库中。

如果某些功能在这些建议出台之前就已开发，或者团队确定需要采用其他实现方式，则这些功能可能不符合上述建议。

所有其他功能均视为公开可用。

<a id="experiment"></a>

## 实验

实验功能：

- 尚未准备好用于生产环境。
- [不提供支持](https://gitlab.cn/support)。
  与此类功能相关的议题应在 [GitLab 议题跟踪器](https://gitlab.com/gitlab-org/gitlab/-/issues)中创建。
- 可能不稳定。
- 可能随时被移除。
- 可能不会成熟到正式发布。
- 可能存在数据丢失的风险。
- 可能没有文档，或信息仅限于 GitLab 议题或博客。
- 可能没有最终确定的用户体验，并且可能只能通过快速操作或 API 请求访问。

<a id="beta"></a>

## 测试版

测试版功能：

- 可能尚未准备好用于生产环境。
- [在商业上合理努力的基础上提供支持](https://gitlab.cn/support)，
  但预期问题需要开发团队投入额外时间和协助进行排查。
- 可能不稳定。
- 其配置和依赖项不太可能发生变化。
- 其特性和功能不太可能发生变化。但是，破坏性变更可能发生在主要版本之外，
  或者通知时间比正式发布的功能更短。
- 数据丢失风险较低。
- 用户体验完整或接近完整。
- 可以等同于合作伙伴的“公开预览”状态。

<a id="public-availability"></a>

## 公开可用

提供两种类型的公开发布：

- 限量提供
- 正式发布

两种类型均可用于生产环境，但适用范围不同。

<a id="limited-availability"></a>

### 限量提供

限量提供功能遵循与正式发布功能相同的安全要求，但在初始推出期间可能仅部署在部分平台上，或存在规模限制。

限量提供功能：

- 已准备好以缩减的规模用于生产环境。
- 可能最初仅在一个或多个极狐GitLab 平台（JihuLab.com、极狐GitLab 私有化部署）上提供。
- 可能最初免费，在正式发布后变为付费。
- 可能在正式发布前以折扣价提供。
- 在正式发布时，新合同的商业条款可能发生变化。
- [获得全面支持](https://gitlab.cn/support)并有文档记录。
- 拥有符合极狐GitLab 设计标准的完整用户体验。

<a id="generally-available"></a>

### 正式发布

正式发布功能：

- 已准备好以任意规模用于生产环境。
- [获得全面支持](https://gitlab.cn/support)并有文档记录。
- 拥有符合极狐GitLab 设计标准的完整用户体验。
- 必须在所有极狐GitLab 产品形态（JihuLab.com、JihuLab.com Cells、极狐GitLab 私有化部署）上提供。

<a id="feature-release-requirements"></a>

## 功能发布要求

在向用户提供功能之前，开发该功能的极狐GitLab 团队必须考虑上述状态指南，以及每个开发阶段的要求。

<a id="terminology"></a>

### 术语

为清晰起见，这些指南使用以下定义：

- **显式选择启用**：功能默认禁用，需要授权用户（例如实例管理员、群组所有者或单个用户，具体取决于功能范围）执行主动启用操作。可以启用但除非激活否则保持禁用的功能，视为需要显式选择启用。
- **默认启用**：功能无需选择启用操作即可对用户或实例生效。在实验或测试版阶段，功能不得默认启用。
- **生产使用**：指以下两者：
  - 客户生产工作负载（用户依赖其进行业务运营的功能）
  - 支持 JihuLab.com、Dedicated 和 Dedicated for Federal 的极狐GitLab 托管生产基础设施（影响平台可靠性或安全性的共享服务）
- **内部测试**：GitLab 团队成员为验证目的而使用 GA 前的功能，也称为 Customer Zero。

<a id="feature-maturity-transition-principle"></a>

### 功能成熟度过渡原则

在评估功能是否准备好推进成熟度阶段时，请应用**事件响应测试**：

> “如果该功能已经处于目标成熟度级别，而此风险显现，我们是否会宣布事件并推送紧急修复？”

功能不应带着在 GA 后发生会触发事件响应的风险过渡到 GA，包括：

- 严重（S1/S2）安全漏洞
- 会违反 SLA 承诺的性能下降
- 需要通知客户的数据完整性问题
- 影响平台稳定性的可用性影响

此原则确保功能以适当的风险姿态达到生产成熟度，而不是制造可预见的未来事件。

<a id="experimental-features"></a>

### 实验功能

- 必须默认禁用，并要求显式选择启用。不得在客户未操作的情况下自动为用户或实例启用。
- 在多租户平台上，必须保持租户隔离，使选择启用的用户不会给其他租户带来风险。
- 根据当前发布成熟度状态，安全修复可能在规范渠道（公开）中发布。
  标准漏洞修复 SLO 不适用于实验功能。
- 未满足所述测试版要求而想移至测试版，需要获得 VP 批准作为例外。

内部测试（Customer Zero）可以使用实验功能进行工程验证。影响公司范围业务流程（例如入职、访问管理或合规工作流）的功能，需要获得工程和安全领导层书面记录的风险接受。

<a id="beta-features"></a>

### 测试版功能

- 必须默认禁用，并要求显式选择启用。不得在客户未操作的情况下自动为用户或实例启用。
- 在多租户平台上，必须保持租户隔离，使选择启用的用户不会给其他租户带来风险。
- 必须有一份记录在案且与利益相关方达成一致的方案，用于在正式发布前建立安全发布流程。该流程必须能够在不提前公开披露的情况下安全修复漏洞，包括如何识别、跟踪、确定优先级、修复漏洞，以及通过协调披露进行沟通。
- 根据当前发布成熟度状态，安全修复可能在规范渠道（公开）中发布。标准漏洞修复 SLO 不适用于测试版功能。
- 必须有一份记录在案且与利益相关方达成一致的方案，用于在正式发布前实施审计日志记录。该方案必须明确规定哪些事件会被记录、日志格式和保留策略、安全团队如何访问日志，以及与现有审计系统的集成点。
- 未满足所述 GA 要求而想移至 GA，需要获得 e-group 批准作为例外。

<a id="limited-availability-features"></a>

### 限量提供功能

- 必须有一个可运行的安全发布流程，能够在不提前公开披露的情况下安全修复漏洞。
- 必须有一个可运行的审计日志记录，使安全团队（内部和客户）能够检测异常行为、调查安全事件，并回答关于谁、什么、何地、何时的基本问题。审计日志记录不需要精美的 UI 体验，但必须提供对安全相关事件的编程访问。
- 必须有[可运行的 runbook 文档](https://gitlab.com/gitlab-com/runbooks/-/tree/master/docs)。

<a id="generally-available-features"></a>

### 正式发布功能

- 在移至 GA 之前必须完成安全审查。安全审查范围由功能特征（面向客户的功能、基础设施影响、数据访问模式）决定。以安全审查部分完成的状态移至 GA 的功能需要 E-Group 批准。
- 遵守漏洞修复 SLO，并且不得在未获得 E-Group 书面记录的风险接受的情况下发布任何 S1/S2 漏洞。应用事件响应测试：功能不得带着在 GA 后发现会触发紧急修补的风险发布。
- 必须有一个可运行的安全发布流程，能够在不提前公开披露的情况下安全修复漏洞。
- 必须有一个可运行的审计日志记录，使安全团队（内部和客户）能够检测异常行为、调查安全事件，并回答关于谁、什么、何地、何时的基本问题。审计日志记录不需要精美的 UI 体验，但必须提供对安全相关事件的编程访问。

<a id="exception-governance"></a>

## 例外治理

在业务需求要求偏离这些要求的特殊情况下，极狐GitLab 遵循记录在案的例外流程，并需要高管批准和风险接受。
