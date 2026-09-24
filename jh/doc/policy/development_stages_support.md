---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Support details.
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

极狐GitLab 有时会发布处于不同开发阶段的功能，例如实验性或测试版。用户可以自主选择并测试新体验。这类功能发布的原因包括：

- 验证功能在当前形态下针对每个设计用例的规模、支持与维护负担的边界情况。
- 功能尚不完整，不足以被视为 MVC，但作为开发过程的一部分添加到代码库中。

某些功能可能不符合这些建议，如果它们是在这些建议实施之前开发的，或者团队确定需要采用替代的实现方法。

所有其他功能均视为已公开可用。

<a id="experiment"></a>

## 实验

实验性功能：

- 尚未准备好用于生产环境。
- [无可用支持](https://support.gitlab.com/hc/en-us/articles/11625911285404-Statement-of-Support#experiment-&-beta-features)。有关此类功能的问题应在[极狐GitLab 议题追踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues)中创建。
- 可能不稳定。
- 可能随时被移除。
- 可能存在数据丢失的风险。
- 可能没有文档，或者信息仅限于极狐GitLab 议题或博客。
- 可能没有最终确定的用户体验，并且可能仅能通过快速操作或 API 请求访问。

<a id="beta"></a>

## 测试版

测试版功能：

- 可能尚未准备好用于生产环境。
- 按照[商业上合理的努力提供支持](https://gitlab.cn/support/statement-of-support/#experiment-beta-features)，但预期问题可能需要额外的时间和开发人员的协助来排查。
- 可能不稳定。
- 配置和依赖项不太可能改变。
- 功能和特性不太可能改变。但是，破坏性变更可能发生在主要版本之外，或者比正式可用功能的通知时间更短。
- 数据丢失风险较低。
- 用户体验已完成或接近完成。
- 可以等同于合作伙伴的“公开预览”状态。

<a id="public-availability"></a>

## 公开可用

有两种类型的公开版本：

- 受限可用
- 正式可用

两者都可用于生产，但范围不同。

<a id="limited-availability"></a>

### 受限可用

受限可用功能：

- 可降低规模用于生产环境。
- 可先在一个或多个极狐GitLab 平台（JihuLab.com，私有化部署）上可用。
- 可能最初免费，然后在正式可用时变为付费。
- 可能在正式可用之前提供折扣。
- 正式可用时，商业条款可能对新合同发生变化。
- [完全支持](https://gitlab.cn/support/statement-of-support/)并有完整文档。
- 拥有符合极狐GitLab 设计标准的完整体验。

<a id="generally-available"></a>

### 正式可用

正式可用功能：

- 可支持任意规模的生产环境使用。
- [完全支持](https://gitlab.cn/support/statement-of-support/)并有完整文档。
- 拥有符合极狐GitLab 设计标准的完整体验。
- 必须在所有极狐GitLab 产品（JihuLab.com，JihuLab.com Cells，私有化部署）上可用。
- 使用极狐GitLab Duo Agent Platform 中的正式可用功能会消耗极狐GitLab 积分。当某个功能在最新的极狐GitLab 版本中变为正式可用时，该功能在所有版本和产品上的使用将开始消耗积分。测试版功能可随时变为正式可用并按使用计费。

<a id="feature-release-requirements"></a>

## 功能发布要求

在向用户提供功能之前，开发该功能的极狐GitLab 团队必须考虑上述状态指导以及每个开发阶段的要求。

<a id="terminology"></a>

### 术语

为了清晰起见，这些指南使用以下定义：

- **显式选择加入**：功能默认禁用，需要由授权用户（例如实例管理员、群组所有者或个人用户，取决于功能范围）执行明确的启用操作。可启用但除非激活否则仍处于禁用状态的功能视为需要显式选择加入。
- **默认启用**：功能无需选择加入操作即为用户或实例激活。在实验或测试版阶段，功能不得默认启用。
- **生产使用**：指以下两者：
  - 客户生产工作负载（用户依赖用于业务运营的功能）
  - 极狐GitLab 管理的生产基础设施（影响平台可靠性或安全的共享服务）支持 JihuLab.com。
- **内部测试**：极狐GitLab 团队成员为验证目的使用预发布功能，也称为客户零。

<a id="feature-maturity-transition-principle"></a>

### 功能成熟度过渡原则

在评估功能是否准备好进入下一个成熟度阶段时，应用**事件响应测试**：

> “如果该功能已达到目标成熟度水平，并且该风险显现，我们是否会宣布事件并推送紧急修复？”

功能不应以存在如果在正式发布后出现会触发事件响应的风险进入正式发布状态，包括：

- 严重（S1/S2）安全漏洞
- 会违反 SLA 承诺的性能下降
- 需要通知客户的数据完整性问题
- 影响平台稳定性的可用性影响

该原则确保功能以适当的风险态势达到生产成熟度，而不是制造可预见的未来事件。

<a id="experimental-features"></a>

### 实验性功能

- 必须默认禁用，并需要显式选择加入。不得在未经客户操作的情况下自动为用户或实例启用。
- 在多租户平台上，必须保持租户隔离，确保选择加入的用户不会给其他租户带来风险。
- 根据当前发布成熟度状态，安全修复可能以公开方式（在开源中）发布。标准漏洞修复 SLO 不适用于实验性功能。
- 在未满足所述测试版要求的情况下转向测试版，需要副总裁批准例外。

内部测试（客户零）可以使用实验性功能进行工程验证。影响公司范围业务流程（如入职、访问管理或合规工作流）的功能需要工程和安全领导层记录的风险接受。

<a id="beta-features"></a>

### 测试版功能

- 必须默认禁用，并需要显式选择加入。不得在未经客户操作的情况下自动为用户或实例启用。
- 在多租户平台上，必须保持租户隔离，确保选择加入的用户不会给其他租户带来风险。
- 必须拥有文档化且与利益相关者对齐的计划，以便在正式可用之前建立安全发布流程。该流程必须能够在不进行不当公开披露的情况下安全修复漏洞，包括如何识别、跟踪、优先级排序、修复以及通过协调披露进行沟通。
- 根据当前发布成熟度状态，安全修复可能以公开方式（在开源中）发布。标准漏洞修复 SLO 不适用于测试版功能。
- 必须拥有文档化且与利益相关者对齐的计划，以便在正式可用之前实施审计日志记录。该计划必须指定记录哪些事件、日志格式和保留期限、安全团队如何访问日志以及与现有审计系统的集成点。
- 在未满足所述正式可用要求的情况下转向正式可用，需要 e-group 批准例外。

<a id="limited-availability-features"></a>

### 受限可用功能

- 必须拥有可运行的的安全发布流程，能够在不进行不当公开披露的情况下安全修复漏洞。
- 必须拥有可运行的的审计日志记录，使安全团队（内部和客户）能够检测异常行为、调查安全事件并回答关于谁、做什么、在哪里以及何时发生的基本问题。审计日志记录不需要完善的 UI 体验，但必须提供对安全相关事件的编程访问。
- 必须拥有[可运行的 runbook 文档](https://gitlab.com/gitlab-com/runbooks/-/tree/master/docs)。

<a id="generally-available-features"></a>

### 正式可用功能

- 必须在正式可用之前完成安全审查。安全审查范围由功能特征（面向客户的功能、基础设施影响、数据访问模式）确定。以部分完成安全审查的状态进入正式可用的功能需要 E-Group 批准。
- 遵守漏洞修复 SLO，不得在未获得 E-Group 记录的风险接受的情况下发布任何 S1/S2 漏洞。应用事件响应测试：功能不得发布如果正式发布后发现会触发紧急修补的风险。
- 必须拥有可运行的的安全发布流程，能够在不进行不当公开披露的情况下安全修复漏洞。
- 必须拥有可运行的的审计日志记录，使安全团队（内部和客户）能够检测异常行为、调查安全事件并回答关于谁、做什么、在哪里以及何时发生的基本问题。审计日志记录不需要完善的 UI 体验，但必须提供对安全相关事件的编程访问。

<a id="exception-governance"></a>

## 异常治理

在业务需求需要偏离这些要求的特殊情况下，极狐GitLab 遵循经过执行审批和风险接受的记录化异常流程。