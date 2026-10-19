---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 识别并修复失败代码或测试中的缺陷。
title: 调试失败的代码
---

当您遇到代码未按预期运行或测试失败的情况时，请遵循以下指南。

- 时间预估：10-25 分钟
- 级别：初学者
- 先决条件：可获取错误消息或失败代码，IDE 中可使用极狐GitLab Duo Chat

<a id="the-challenge"></a>

## 挑战

快速找出缺陷或测试失败的根本原因，并实施有效的修复，而无需花费数小时手动调试。

<a id="the-approach"></a>

## 方法

使用极狐GitLab Duo Chat 分析错误、找出原因并实施修复。

<a id="step-1-analyze"></a>

### 第 1 步：分析

复制错误消息和相关代码。然后请极狐GitLab Duo Chat 解释该错误。

```plaintext
Explain what's causing this error and help me fix it:

Error: [paste_error_message]

Context: [brief_description_of_what_you_were_trying_to_do]

Here's the relevant code:
[paste_problematic_code]
```

预期结果：对错误原因的清晰解释以及具体的修复建议。

<a id="step-2-implement"></a>

### 第 2 步：实施

请 Chat 提供修正后的代码。

```plaintext
Based on your analysis, please provide the corrected version of this code:

[paste_original_code]

Make sure the fix addresses [specific_error] and follows [language/framework] best practices.
```

预期结果：可修复所识别问题的可用代码。

<a id="step-3-prevent"></a>

### 第 3 步：预防

请 Chat 提供如何避免类似问题的指导。

```plaintext
How can I prevent this type of error in the future?
What are the warning signs to watch for with [error_type] in [language/framework]?
Include any best practices or common patterns I should follow.
```

预期结果：避免类似缺陷的预防性指导和最佳实践。

<a id="tips"></a>

## 提示

- 包含完整的错误消息，而不只是摘要。
- 提供您当时想要完成的任务的相关背景信息。
- 先只复制失败的那段具体代码。如果 Chat 需要更多上下文，再从文件中添加更多代码。
- 请 Chat 解释修复方案，以便您理解底层问题。
- 如果第一个建议不起作用，请告诉 Chat 您尝试后发生了什么。

<a id="verify"></a>

## 验证

确保：

- 运行代码时不再出现该错误。
- 修复针对的是根本原因，而不仅仅是表面症状。
- 解决方案符合您项目的编码规范。
- 您理解错误发生的原因以及修复方案的工作原理。
