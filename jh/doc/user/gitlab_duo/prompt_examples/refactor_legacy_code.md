---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Refactor legacy code in your repository.
title: 重构遗留代码
---

Follow these guidelines when you need to improve performance, readability, or maintainability of existing code.

- Time estimate: 15-30 minutes
- Level: Intermediate
- Prerequisites: Code file open in IDE, 极狐GitLab Duo Chat available

<a id="the-challenge"></a>

## 挑战

Transform complex, hard-to-maintain code into clean, testable components without breaking functionality.

<a id="the-approach"></a>

## 方法

Analyze, plan, and implement by using 极狐GitLab Duo Chat and 代码建议.

<a id="step-1-analyze"></a>

### 步骤 1：分析

Use 极狐GitLab Duo Chat to understand the current state. Select the code you want to refactor, then ask:

```plaintext
分析 [ClassName] 在 [file_path] 中的代码。重点关注：
1. 当前方法及其复杂度
2. 性能瓶颈
3. 可读性可以改进的地方
4. 可以应用的潜在设计模式

提供代码中的具体示例，并建议适用的重构模式。
```

Expected outcome: Detailed analysis with specific improvement suggestions.

<a id="step-2-plan"></a>

### 步骤 2：计划

Use 极狐GitLab Duo Chat to create a structured proposal.

```plaintext
根据你对 [ClassName] 的分析，创建一个重构计划：

1. 概述新的结构
2. 建议新的方法名称及其作用
3. 确定需要的新类或模块
4. 解释这将如何改进 [性能/可读性/可维护性]

格式为一个结构化的计划，并清楚地展示前后的对比。
```

Expected outcome: Step-by-step refactoring roadmap.

<a id="step-3-implement"></a>

### 步骤 3：实施

Use 极狐GitLab Duo Chat to generate the refactored code. Then apply the code and use 代码建议 to help with syntax.

```plaintext
实现针对 [ClassName] 的重构计划：

1. 按照我们的编码标准创建新的 [language] 文件
2. 包含详细的注释以解释更改
3. 更新 [related_file] 以使用新的结构
4. 为新的实现编写测试

遵循 [style_guide] 并记录任何设计决策。
```

Expected outcome: Complete refactored code with tests.

<a id="tips"></a>

## 提示

- Start with analysis before jumping to implementation.
- Select specific code sections when asking Chat for analysis.
- Ask Chat for specific examples from your actual code.
- Reference your existing codebase patterns for consistency.
- Use incremental prompts rather than trying to do everything at once.
- Let 代码建议 help with syntax as you implement the recommendations from Chat.

<a id="verify"></a>

## 验证

Ensure that:

- Generated code follows your team's style guide.
- New structure actually improves the identified issues.
- Tests cover the refactored functionality.
- No functionality was lost in the refactoring.
