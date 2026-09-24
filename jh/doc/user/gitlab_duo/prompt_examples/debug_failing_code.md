---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Identify and fix bugs in failing code or tests.
title: 调试失败代码
---

当你遇到代码未按预期运行或测试失败时，请遵循这些指南。

- 预计时间：10-25 分钟
- 级别：初学者
- 先决条件：可用的错误信息或失败代码，IDE 中可用的 极狐GitLab Duo Chat

<a id="the-challenge"></a>

## 挑战

快速识别错误或测试失败的根本原因，并实施有效的修复，无需花费数小时手动调试。

<a id="the-approach"></a>

## 方法

使用 极狐GitLab Duo Chat 分析错误、识别原因并实施修复。

<a id="step-1-analyze"></a>

### 步骤 1：分析

复制错误信息和相关代码。然后让 极狐GitLab Duo Chat 解释错误。

```plaintext
解释导致此错误的原因并帮助我修复它：

错误：[粘贴错误信息]

上下文：[简要描述你尝试执行的操作]

以下是相关代码：
[粘贴有问题的代码]
```

预期结果：清晰解释错误原因并提供具体的修复建议。

<a id="step-2-implement"></a>

### 步骤 2：实施

让 Chat 提供修正后的代码。

```plaintext
根据你的分析，请提供此代码的修正版本：

[粘贴原始代码]

确保修复解决了 [具体错误] 并遵循 [语言/框架] 的最佳实践。
```

预期结果：能够修复所识别问题的工作代码。

<a id="step-3-prevent"></a>

### 步骤 3：预防

寻求有关如何避免类似问题的指导。

```plaintext
如何防止将来出现此类错误？
在 [语言/框架] 中，对于 [错误类型] 需要注意哪些警告信号？
包括我应该遵循的任何最佳实践或常见模式。
```

预期结果：预防性指导和最佳实践，以避免类似错误。

<a id="tips"></a>

## 提示

- 包含完整的错误信息，而不仅仅是摘要。
- 提供你尝试完成的任务的上下文。
- 首先只复制失败的具体代码部分。如果 Chat 需要更多上下文，再从文件中添加更多代码。
- 让 Chat 解释修复方法，以便你理解根本问题。
- 如果第一个建议不起作用，告诉 Chat 你尝试时发生了什么。

<a id="verify"></a>

## 验证

确保：

- 运行代码时不再出现错误。
- 修复针对的是根本原因，而不仅仅是症状。
- 解决方案遵循项目的编码标准。
- 你理解错误发生的原因以及修复的工作原理。