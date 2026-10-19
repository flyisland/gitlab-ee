---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 重构代码仓库中的遗留代码。
title: 重构遗留代码
---

当您需要改进现有代码的性能、可读性或可维护性时，请遵循以下准则。

- 时间预估：15-30 分钟
- 级别：中级
- 先决条件：在 IDE 中打开代码文件，极狐GitLab Duo Chat 可用

<a id="the-challenge"></a>

## 挑战

将复杂、难以维护的代码转变为整洁、可测试的组件，同时不破坏功能。

<a id="the-approach"></a>

## 方法

使用极狐GitLab Duo Chat 和代码建议进行分析、规划和实施。

<a id="step-1-analyze"></a>

### 第 1 步：分析

使用极狐GitLab Duo Chat 了解当前状态。选择您想要重构的代码，然后提问：

```plaintext
Analyze the [ClassName] in [file_path]. Focus on:
1. Current methods and their complexity
2. Performance bottlenecks
3. Areas where readability can be improved
4. Potential design patterns that could be applied

Provide specific examples from the code and suggest applicable refactoring patterns.
```

预期结果：包含具体改进建议的详细分析。

<a id="step-2-plan"></a>

### 第 2 步：规划

使用极狐GitLab Duo Chat 创建结构化方案。

```plaintext
Based on your analysis of [ClassName], create a refactoring plan:

1. Outline the new structure
2. Suggest new method names and their purposes
3. Identify any new classes or modules needed
4. Explain how this improves [performance/readability/maintainability]

Format as a structured plan with clear before/after comparisons.
```

预期结果：分步重构路线图。

<a id="step-3-implement"></a>

### 第 3 步：实施

使用极狐GitLab Duo Chat 生成重构后的代码。然后应用该代码，并使用代码建议来帮助处理语法。

```plaintext
Implement the refactoring plan for [ClassName]:

1. Create the new [language] file following our coding standards
2. Include detailed comments explaining changes
3. Update [related_file] to use the new structure
4. Write tests for the new implementation

Follow [style_guide] and document any design decisions.
```

预期结果：包含测试的完整重构代码。

<a id="tips"></a>

## 提示

- 先进行分析，再着手实施。
- 向 Chat 请求分析时，选择具体的代码段。
- 向 Chat 询问来自您实际代码的具体示例。
- 参考您现有代码库的模式以保持一致性。
- 使用增量提示，而不是试图一次性完成所有工作。
- 在实施 Chat 的建议时，让代码建议帮助处理语法。

<a id="verify"></a>

## 验证

确保：

- 生成的代码遵循您团队的风格指南。
- 新结构确实改进了已识别的问题。
- 测试覆盖重构后的功能。
- 重构过程中没有丢失任何功能。
