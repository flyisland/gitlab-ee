---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全审查任务流
description: 使用 AI 识别合并请求中的业务逻辑漏洞。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

安全审查任务流可检测合并请求中的业务逻辑漏洞。
与扫描已知模式的静态分析工具不同，安全审查任务流会推理
您代码的意图。它可以识别因授权、数据暴露和控制流方面的错误假设
而产生的漏洞。

安全审查任务流是构建在极狐GitLab Duo Agent Platform 之上的[内置任务流](_index.md)。它与
[极狐GitLab Duo 代码评审](../../../gitlab_duo/code_review.md)协同工作，并将发现结果作为线程化差异评论发布，
每条评论都包含 CWE 分类、严重性评级、解释，并在可能的情况下提供
可一键应用的内联建议修复。

> [!note]
> 安全审查任务流的结果由 AI 生成，仅作为建议性输入，并非权威或
> 完整的安全评估。未报告任何发现结果的审查并不能证明合并请求
> 是安全的，且发现结果可能包含需要人工判断的误报。有关更多信息，
> 请参阅[已知限制](#known-limitations)。

在以下情况下使用安全审查任务流：

- 访问控制审查：识别对状态更改操作缺失或配置错误的授权检查。
- 授权缺口检测：发现对象级和功能级授权问题。
- 业务逻辑分析：检测应用程序工作流中可能被利用的缺陷，例如财务或有状态操作中的竞态条件。
- 信息泄露：识别可能向未经授权的调用者泄露敏感数据的代码路径。
- 批量赋值风险：标记可能向用户输入暴露意外字段的端点或模型。

<a id="prerequisites"></a>

## 先决条件

要使用安全审查任务流：

- 对项目具有开发者、维护者或所有者角色。
- 为顶级群组[开启](_index.md#turn-foundational-flows-on-or-off)内置任务流
  和 **安全审查**。
- 为群组或实例[开启极狐GitLab Duo](../../../gitlab_duo/turn_on_off.md)。
- 如果您没有极狐GitLab Duo Pro 或 Enterprise，
  请为顶级群组或实例[开启极狐GitLab Duo Core](../../../gitlab_duo/turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- 对于极狐GitLab 私有化部署，请为实例[配置极狐GitLab Duo](../../../../administration/gitlab_duo/configure/_index.md)。
- 在极狐GitLab 18.8 及更高版本中，为顶级群组[开启 Agent Platform](../../turn_on_off.md#turn-gitlab-duo-agent-platform-on-or-off)。在极狐GitLab 18.7 及更早版本中，
  [开启测试版和实验性功能](../../turn_on_off.md#turn-on-beta-and-experimental-features)。

<a id="cost"></a>

## 成本

安全审查任务流每次执行
审查时都会使用[极狐GitLab Credits](../../../../subscriptions/gitlab_credits.md)。Credits 用量随差异复杂度和您选择的模型而变化。

以下估算适用于[默认模型](../../model_selection.md#default-models)：

| 审查复杂度                        | 近似 LLM 调用次数 | 估算 Credits |
|------------------------------------------|-----------------------|-------------------|
| 小型差异或少量更改的文件        | ~16                   | ~8                |
| 标准功能分支                  | ~28                   | ~14               |
| 大型或逻辑密集的多文件更改   | ~40                   | ~20               |

在测试版发布期间，您始终手动启动审查。这使您可以在更广泛采用之前评估代码库中典型的 Credits
使用情况。

<a id="use-security-review-flow"></a>

## 使用安全审查任务流

<a id="request-a-review"></a>

### 请求审查

您可以在创建合并请求后的任何时间请求审查。当您请求审查时，该任务流
会分析合并请求的差异及其周边上下文。

当安全审查任务流开启时，**Duo Security Review** 服务账号会为您的顶级群组创建，
并可供其中的所有项目和子群组使用。每个服务账号名称都包含关联的
顶级群组，例如 `duo-security-review-gitlab-org`。

要请求审查：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **代码** > **合并请求** 并打开您的合并请求。
1. 在右侧边栏的 **审核人** 部分，选择 **编辑**。
1. 在搜索框中，输入 `Duo Security Review` 并从列表中选择该账号。

审查完成后，该任务流会发布一条内部评论。该评论总结任何发现结果和
审查范围。如果审查未产生任何发现结果，该任务流会在内部评论中说明。

对于每个发现结果，该任务流会在相关行打开一个差异线程。如果您
回复线程（例如，接受风险或不同意评估），该任务流会读取您的回复
并相应回复。在公共项目中，发现结果仅发布在内部评论中，不包含内联
差异评论。私下发布发现结果可避免暴露安全细节。

该任务流会根据发现结果的严重性设置审核人状态。即使未发现任何问题，该任务流也绝不会设置
**批准** 状态：

| 严重性             | 审核人状态 |
| -------------------- | -------------- |
| `critical` 或 `high` | **请求更改** |
| `medium` 或 `low`    | **评论**    |
| 无                 | **评论**    |

<a id="respond-to-a-finding"></a>

### 回复发现结果

在线程中提及该任务流，以询问有关发现结果的澄清问题、讨论修复方法，或
将发现结果标记为误报。被提及时，该任务流不会执行完整的重新审查。

要回复发现结果：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **代码** > **合并请求** 并打开您的合并请求。
1. 在任何评论线程中，输入 `@duo-security-review` 并从列表中选择 **Duo Security Review**。
1. 添加您的消息并选择 **评论**。

安全审查任务流会读取线程上下文并直接回复。

<a id="review-a-finding"></a>

### 审查发现结果

安全审查任务流专注于静态分析器经常遗漏的逻辑级漏洞。
每个发现结果都会作为更改代码上的差异线程发布。每个线程包括：

- 漏洞类型（CWE），带有指向 MITRE 定义的链接。
- 严重性评级：`critical`、`high`、`medium` 或 `low`。
- 层级分类：第 1 层（可利用）、第 2 层（逻辑缺陷）或第 3 层（设计问题）。
- 逻辑缺陷的解释。
- 建议修复（如有可能）。

> [!note]
> 发现结果不会在[漏洞报告](../../../application_security/vulnerability_report/_index.md)中跟踪，
> 也不计入[合并请求批准策略](../../../application_security/policies/merge_request_approval_policies.md)。
> 它们补充但不替代静态分析（SAST）发现结果。

发现结果中可能出现以下 CWE 分类：

| CWE | 描述 |
|-----|-------------|
| [CWE-639](https://cwe.mitre.org/data/definitions/639.html) | 通过用户控制的键绕过授权（BOLA / IDOR） |
| [CWE-862](https://cwe.mitre.org/data/definitions/862.html) | 缺少授权 |
| [CWE-284](https://cwe.mitre.org/data/definitions/284.html) | 访问控制不当 |
| [CWE-200](https://cwe.mitre.org/data/definitions/200.html) | 敏感信息暴露 |
| [CWE-840](https://cwe.mitre.org/data/definitions/840.html) | 业务逻辑错误 |
| [CWE-915](https://cwe.mitre.org/data/definitions/915.html) | 对动态确定的对象属性修改控制不当（批量赋值） |
| [CWE-362](https://cwe.mitre.org/data/definitions/362.html) | 竞态条件及检查时间/使用时间（TOCTOU） |

<a id="resolve-a-finding"></a>

### 解决发现结果

要解决发现结果：

- 要应用修复，请选择 **应用建议**。要改为将建议提交到新
  分支，请选择 **应用建议** 旁边的下拉列表。
- 要忽略该发现结果，如果您已审查该发现结果并
  确定其为误报或已接受的风险，请选择 **解决线程**。
- 要跟踪漏洞以供将来修复，请使用标准极狐GitLab
  [线程操作](../../../project/merge_requests/_index.md#move-open-threads-to-an-issue)
  从发现结果创建议题。
- 要评价发现结果的有用性，请选择 **点赞** 或 **点踩**。此
  反馈有助于改进模型。您也可以在
  [反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/600304)中分享详细反馈。

要在解决发现结果后请求另一次审查，请重新将任务流指派为审核人。该任务流会分析
更新后的差异，并根据发现结果的状态执行操作：

- 已解决的发现结果：该任务流确认修复并解决原始线程。
- 不正确或不完整的修复：该任务流会在原始线程中识别任何额外需要的更改。
- 未处理的发现结果：原始线程保持打开状态，不添加额外评论。
- 新发现结果：该任务流会检测修复引入的任何新漏洞，并为其创建新的评论线程。

<a id="known-limitations"></a>

## 已知限制

在依赖安全审查任务流的输出之前，请了解以下限制。

- 发现结果是建议性的，并非覆盖保证。安全审查任务流的结果由 AI 生成。
  该任务流可能无法发现更改中的每个漏洞：其分析在有限的
  搜索和读取预算内工作，因此非常大的文件或差异可能无法完全审查。未报告任何发现结果的审查
  并不能证明合并请求是安全的。
- 发现结果可能包含误报。请将发现结果视为需要人工判断的输入，而非
  最终结论。
- 安全审查任务流补充其他工具。它不能替代人工安全审查或
  其他极狐GitLab 安全工具，例如
  [SAST](../../../application_security/sast/_index.md) 和
  [极狐GitLab 高级 SAST](../../../application_security/sast/gitlab_advanced_sast.md)。

<a id="troubleshooting"></a>

## 故障排查

使用安全审查任务流时，您可能会遇到以下问题。

<a id="the-flow-is-not-available-to-assign"></a>

### 任务流无法指派

当安全审查任务流开启时，**Duo Security Review** 服务账号会为您的顶级群组创建。
服务账号名称包含顶级群组
名称，例如 `duo-security-review-gitlab-org`。

请确认安全审查任务流的状态。

<a id="the-flow-does-not-provide-findings"></a>

### 任务流未提供发现结果

确认您满足所有[先决条件](#prerequisites)，然后检查任务流是否正确指派。

- 验证您是否提及了 **Duo Security Review** 账号（其用户名以 `@duo-security-review-` 开头）。
- 验证顶级群组是否已开启 [**允许内置任务流**](_index.md#turn-foundational-flows-on-or-off)
  和 [**代码评审**](code_review/_index.md) 设置。
- 对于极狐GitLab 私有化部署，请验证您的实例已
  [为极狐GitLab Duo 配置](../../../../administration/gitlab_duo/configure/_index.md)。

<a id="the-flow-does-not-review-every-merge-request"></a>

### 任务流未审查每个合并请求

要运行此安全扫描，您必须在合并请求上手动触发该任务流。它不会
在每个合并请求上自动运行。如果您已指派任务流但未收到任何发现结果，请参阅
[任务流未提供发现结果](#the-flow-does-not-provide-findings)。

当任务流审查合并请求时，无发现结果的报告通常意味着：

- 未检测到安全问题：已分析代码逻辑，未识别到漏洞。
- 无安全相关逻辑：更改不包含影响安全的代码（例如，
  仅文档更新）。

关于大型更改的说明：对于大型合并请求，任务流在有限的搜索和读取
预算内运行。在这些情况下，任务流可能报告无发现结果，或仍输出发现结果但未能覆盖完整的
合并请求，这意味着可能遗漏重要漏洞。已完成的审查不保证完全
覆盖。有关更多信息，请参阅[已知限制](#known-limitations)。

<a id="suggested-changes-do-not-apply-cleanly"></a>

### 建议的更改无法干净地应用

建议是针对审查时的差异生成的。如果您在审查后推送了新提交，
行号可能已偏移。请请求新的审查，以获取针对
当前差异的更新建议。

<a id="i-received-an-error-about-gitlab-credits"></a>

### 我收到了关于极狐GitLab Credits 的错误

您的实例或群组可能已用尽当前计费周期的[极狐GitLab Credits](../../../../subscriptions/gitlab_credits.md)。
请联系您的管理员购买更多 Credits，或等待
Credits 在下一个计费周期开始时重置。
