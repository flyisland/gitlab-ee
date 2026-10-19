---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 分析安全漏洞，并根据业务影响确定修复优先级。
title: 分析安全漏洞并确定修复优先级
---

当您需要评估多个安全漏洞并确定哪些需要立即处理时，请遵循以下指南。

- 时间估算：15-25 分钟
- 级别：中级
- 先决条件：极狐GitLab Duo Enterprise 附加组件，漏洞报告中存在可用的漏洞

<a id="the-challenge"></a>

## 挑战

安全扫描通常会产生大量漏洞警报，导致难以识别误报，也难以确定哪些问题会带来最大的业务风险。

<a id="the-approach"></a>

## 方法

使用极狐GitLab Duo Chat、漏洞解释和漏洞解决功能，分析漏洞、评估业务影响并创建按优先级排序的修复计划。

<a id="step-1-explain-vulnerabilities"></a>

### 第 1 步：解释漏洞

转到项目的漏洞报告。对于每个高危或严重漏洞，使用漏洞解释来解释该问题。然后，使用极狐GitLab Duo Chat 提出后续问题。

```plaintext
Based on the earlier vulnerability explanation:

1. What specific security risk does this pose?
2. How could this be exploited in our [application_type]?
3. What data or systems could be compromised?
4. Is this a true positive or likely false positive?
5. What is the realistic business impact?

Consider our application stack: [technology_stack] and deployment environment: [environment_details].
```

预期结果：清晰说明每个漏洞的实际影响以及它可能如何被利用。

<a id="step-2-prioritize-risks"></a>

### 第 2 步：确定风险优先级

使用极狐GitLab Duo Chat 一起分析多个漏洞，并创建优先级矩阵。

```plaintext
Based on these vulnerability explanations, help me prioritize fixes:

[paste_vulnerability_summaries]

Create a priority matrix considering:
1. Exploitability (how easy to exploit)
2. Business impact (what gets compromised)
3. Exposure level (public-facing vs internal)
4. Fix complexity (simple patch vs major changes)

Rank as Critical/High/Medium/Low priority with justification.
```

预期结果：按优先级排序的漏洞列表，并附有以业务为重点的风险评估。

<a id="step-3-generate-fix-plans"></a>

### 第 3 步：生成修复计划

对于高优先级漏洞，使用漏洞解决或 Chat 获取具体的修复指导。

```plaintext
Provide a detailed remediation plan for this [vulnerability_type]:

1. Immediate steps to reduce risk
2. Code changes needed (with examples)
3. Configuration updates required
4. Testing approach to verify the fix
5. Timeline estimate for implementation

Focus on [security_framework] compliance and our [coding_standards].
```

预期结果：可操作的修复计划，包含具体的实施步骤。

<a id="tips"></a>

## 提示

- 首先从严重和高危漏洞开始。
- 在深入修复之前，使用漏洞解释来了解上下文。
- 在评估业务影响时，考虑您的具体应用架构。
- 请极狐GitLab Duo Chat 解释您不熟悉的技术术语或攻击途径。
- 将相似的漏洞分组，以便进行批量分析和一致的修复。
- 使用安全仪表板跟踪修复工作的进展。

<a id="verify"></a>

## 验证

确保：

- 优先级排序反映实际的业务风险，而不仅仅是 CVSS 评分。
- 修复计划包含具体的代码示例和测试步骤。
- 误报被清晰识别并记录。
- 严重漏洞已确定即时缓解策略。
- 修复时间表切合实际，并考虑到测试和部署流程。
