---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Analyze security vulnerabilities and prioritize fixes based on business impact.
title: 分析安全漏洞并排定修复优先级
---

当您需要评估多个安全漏洞并确定哪些需要立即关注时，请遵循本指南。

- 预计时间：15-25 分钟
- 级别：中级
- 前提条件：极狐GitLab Duo Enterprise 插件，漏洞报告中存在漏洞

<a id="the-challenge"></a>

## 挑战

安全扫描经常产生大量漏洞警报，使得识别误报以及确定哪些问题带来最大业务风险变得困难。

<a id="the-approach"></a>

## 方法

使用极狐GitLab Duo Chat、漏洞解释和漏洞解决，分析漏洞、评估业务影响并创建按优先级排序的修复计划。

<a id="step-1-explain-vulnerabilities"></a>

### 步骤 1：解释漏洞

转到您项目的漏洞报告。对于每个高或严重漏洞，使用漏洞解释来解释问题。然后，使用极狐GitLab Duo Chat 提出后续问题。

```plaintext
基于之前的漏洞解释：

1. 这会带来哪些特定的安全风险？
2. 在我们的 [application_type] 中，如何利用这一漏洞？
3. 哪些数据或系统可能会遭到破坏？
4. 这是真阳性还是可能是误报？
5. 实际的业务影响是什么？

考虑我们的应用栈：[technology_stack] 和部署环境：[environment_details]。
```

预期成果：清晰解释每个漏洞的实际影响以及可能被利用的方式。

<a id="step-2-prioritize-risks"></a>

### 步骤 2：风险优先级排序

使用极狐GitLab Duo Chat 一起分析多个漏洞并创建优先级矩阵。

```plaintext
基于这些漏洞解释，帮我排定修复优先级：

[粘贴漏洞摘要]

创建优先级矩阵，考虑以下因素：
1. 可利用性（利用的难易程度）
2. 业务影响（被破坏的内容）
3. 暴露程度（面向公众 vs 内部）
4. 修复复杂性（简单补丁 vs 重大更改）

按严重/高/中/低优先级排序，并附上理由。
```

预期成果：按业务风险排序的漏洞列表，附带业务风险评估。

<a id="step-3-generate-fix-plans"></a>

### 步骤 3：生成修复计划

对于高优先级漏洞，使用漏洞解决或 Chat 获取具体的修复指导。

```plaintext
为此 [vulnerability_type] 提供详细的修复计划：

1. 立即降低风险的措施
2. 需要的代码更改（附示例）
3. 必需的配置更新
4. 验证修复的测试方法
5. 实施的时间表预估

重点关注 [security_framework] 合规性和我们的 [coding_standards]。
```

预期成果：具有具体实施步骤的可操作修复计划。

<a id="tips"></a>

## 提示

- 首先处理严重和高严重性漏洞。
- 在深入修复之前，使用漏洞解释了解上下文。
- 评估业务影响时考虑您的特定应用架构。
- 请极狐GitLab Duo Chat 解释您不熟悉的技术术语或攻击向量。
- 将相似的漏洞分组进行批量分析和一致的修复。
- 使用安全仪表板跟踪修复工作的进展。

<a id="verify"></a>

## 验证

确保：

- 优先级排序反映实际业务风险，而不仅仅是 CVSS 评分。
- 修复计划包括具体的代码示例和测试步骤。
- 误报被清楚识别并记录。
- 严重漏洞已确定立即缓解策略。
- 修复时间表是现实的，并考虑测试和部署流程。