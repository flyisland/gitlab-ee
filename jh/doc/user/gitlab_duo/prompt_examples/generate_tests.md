---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为现有函数和类生成全面的测试。
title: 为现有代码生成测试
---

当您需要为现有函数或类创建全面的测试覆盖时，请遵循以下指南。

- 时间预估：10-20 分钟
- 级别：初学者
- 先决条件：在 IDE 中打开代码文件、极狐GitLab Duo Chat 可用、有待测试的现有代码

<a id="the-challenge"></a>

## 挑战

为现有代码创建全面的测试覆盖，而无需手动编写样板测试用例和设置代码。

<a id="the-approach"></a>

## 方法

选择代码、生成测试，并使用极狐GitLab Duo Chat 和代码建议来完善覆盖范围。

<a id="step-1-generate"></a>

### 第 1 步：生成

选择您要测试的函数或类，然后使用极狐GitLab Duo Chat 生成测试。

```plaintext
Generate tests for the selected [function_name/ClassName] by using [test_framework]:

1. Include test cases for normal operation
2. Add edge cases and error conditions
3. Test boundary values and invalid inputs
4. Follow [testing_conventions] for our project
5. Include setup and teardown if needed

Make the tests comprehensive but readable.
```

预期结果：完整的测试文件，包含覆盖不同场景的多个测试用例。

<a id="step-2-refine"></a>

### 第 2 步：完善

审阅生成的测试，并要求进行具体改进。

```plaintext
Review the generated tests and:
1. Add any missing edge cases for [specific_functionality]
2. Improve test names to be more descriptive
3. Add comments explaining complex test scenarios
4. Ensure tests follow [specific_style_guide]

Focus on making tests maintainable and clear.
```

预期结果：经过打磨的测试文件，具有清晰、全面的覆盖范围。

<a id="step-3-extend"></a>

### 第 3 步：扩展

使用代码建议添加更多测试用例。在您的文件中输入以下文本。

```plaintext
// Test [specific_edge_case_scenario]
// Test [error_condition]
// Test [boundary_condition]
```

预期结果：代码建议帮助补全更多测试用例。

<a id="tips"></a>

## 提示

- 选择具体的函数或类，而不是整个文件，以获得更好的结果。
- 明确说明您的测试框架（例如 Jest、pytest、RSpec）。
- 如果您正在学习，可以请 Chat 解释测试用例背后的推理。
- 使用代码建议快速添加类似的测试模式。
- 同时请求正向和负向测试用例，以实现全面的覆盖。

<a id="verify"></a>

## 验证

确保：

- 测试覆盖主要功能和常见边缘情况。
- 测试名称清楚地描述所测试的内容。
- 测试遵循您项目的测试约定和风格。
- 针对现有代码运行时，所有测试均通过。
