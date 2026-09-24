---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Generate comprehensive tests for existing functions and classes.
title: 为现有代码生成测试
---

当您需要为现有函数或类创建全面的测试覆盖时，请遵循这些指南。

- 预计时间：10-20 分钟
- 级别：初学者
- 先决条件：在 IDE 中打开代码文件，可使用极狐GitLab Duo Chat，有要测试的现有代码

<a id="the-challenge"></a>

## 挑战

为现有代码创建全面的测试覆盖，而无需手动编写样板测试用例和设置代码。

<a id="the-approach"></a>

## 方法

通过使用极狐GitLab Duo Chat 和代码建议，选择代码、生成测试并优化覆盖。

<a id="step-1:-generate"></a>

### 步骤 1：生成

选择要测试的函数或类，然后使用极狐GitLab Duo Chat 生成测试。

```plaintext
使用 [test_framework] 为选定的 [function_name/ClassName] 生成测试：

1. 包括正常操作的测试用例
2. 添加边缘情况和错误条件
3. 测试边界值和无效输入
4. 遵循我们项目的 [testing_conventions]
5. 如果需要，包括设置和拆卸

使测试全面但可读。
```

预期结果：包含多个测试用例的完整测试文件，覆盖不同场景。

<a id="step-2:-refine"></a>

### 步骤 2：优化

审查生成的测试，并请求特定的改进。

```plaintext
审查生成的测试，并：
1. 为 [specific_functionality] 添加任何缺失的边缘情况
2. 改进测试名称，使其更具描述性
3. 添加解释复杂测试场景的注释
4. 确保测试遵循 [specific_style_guide]

专注于使测试可维护且清晰。
```

预期结果：经过打磨的测试文件，具有清晰、全面的覆盖。

<a id="step-3:-extend"></a>

### 步骤 3：扩展

使用代码建议添加额外的测试用例。在您的文件中输入以下文本。

```plaintext
// 测试 [specific_edge_case_scenario]
// 测试 [error_condition]
// 测试 [boundary_condition]
```

预期结果：代码建议帮助完成额外的测试用例。

<a id="tips"></a>

## 提示

- 选择特定的函数或类，而不是整个文件，以获得更好的结果。
- 明确指定您的测试框架（例如 Jest、pytest、RSpec）。
- 如果您正在学习，请让 Chat 解释测试用例背后的推理。
- 使用代码建议快速添加类似的测试模式。
- 要求同时提供正向和负向测试用例，以实现全面覆盖。

<a id="verify"></a>

## 验证

确保：

- 测试覆盖主要功能和常见边缘情况。
- 测试名称清楚地描述了正在测试的内容。
- 测试遵循项目的测试约定和风格。
- 所有测试在针对现有代码运行时均通过。

