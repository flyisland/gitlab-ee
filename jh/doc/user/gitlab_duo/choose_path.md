---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Learn how to use GitLab Duo AI-native features to enhance your software development lifecycle.
title: 'GitLab Duo：选择你的路径'
---

GitLab Duo 是一套原生 AI 功能，在你在极狐GitLab 中工作时为你提供帮助。

选择最符合你目标的路径：

{{< tabs >}}

{{< tab title="开始使用" >}}

**适合**：首次探索 GitLab Duo 的新用户

按照此路径了解如何：

- 使用多种 GitLab Duo 功能
- 通过 GitLab Duo Chat 获得 AI 帮助
- 生成并改进代码

[从这里开始：GitLab Duo →](_index.md)

{{< /tab >}}

{{< tab title="提升我的编码效率" >}}

**适合**：希望提升生产力的开发者

按照此路径了解如何：

- 在 IDE 中使用 代码建议
- 生成、理解并重构代码
- 自动创建测试

[从这里开始：代码建议 →](../project/repository/code_suggestions/_index.md)

{{< /tab >}}

{{< tab title="改进代码评审" >}}

**适合**：评审者和团队负责人

按照此路径了解如何：

- 生成合并请求描述
- 获得原生 AI 代码评审
- 汇总评审评论并生成提交信息

[从这里开始：GitLab Duo 在合并请求中 →](../project/merge_requests/duo_in_merge_requests.md)

{{< /tab >}}

{{< tab title="保护我的应用" >}}

**适合**：安全与 DevSecOps 专业人士

按照此路径了解如何：

- 理解漏洞
- 自动生成修复建议
- 创建合并请求以解决安全问题

[从这里开始：漏洞解释与修复 →](../application_security/vulnerabilities/_index.md#vulnerability-explanation)

{{< /tab >}}

{{< /tabs >}}

<a id="quick-start"></a>

## 快速开始

想马上使用 GitLab Duo？步骤如下：

1. 通过在极狐GitLab UI 右上角选择 **GitLab Duo Chat** 打开 GitLab Duo Chat，或在你的 IDE 中打开。
2. 就你的项目、代码或如何使用 极狐GitLab 提出问题。
3. 试用一项原生 AI 功能，例如在 IDE 中使用 代码建议，或使用 Chat：
   - 在 UI 中总结冗长的议题。
   - 在 IDE 中重构部分现有代码。

[查看所有 GitLab Duo 的可能性 →](_index.md)

<a id="common-tasks"></a>

## 常见任务

需要完成特定事项？以下是一些常见任务：

| 任务            | 描述                                                 | 快速指南                                                                                                                |
| --------------- | ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 获得 AI 协助    | 向 GitLab Duo 提问有关代码、项目或 极狐GitLab 的问题 | [GitLab Duo Chat →](../gitlab_duo_chat/_index.md)                                                                       |
| 生成代码        | 在 IDE 中输入时获取代码建议                          | [代码建议 →](../project/repository/code_suggestions/_index.md)                                                          |
| 理解代码        | 用通俗语言解释代码                                   | [代码解释 →](../project/repository/code_explain.md)                                                                     |
| 修复 CI/CD 问题 | 分析并修复失败的作业                                 | [根因分析 →](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)                     |
| 汇总变更        | 为合并请求生成描述                                   | [合并请求摘要 →](../project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes) |

<a id="how-gitlab-duo-integrates-with-your-workflow"></a>

## GitLab Duo 如何与你的工作流集成

GitLab Duo 集成到你的开发流程，可在以下位置使用：

- 在极狐GitLab UI 中
- 通过 GitLab Duo Chat
- 在 CLI 中

<a id="experience-levels"></a>

## 使用经验等级

<a id="for-beginners"></a>

### 面向初学者

如果你是 GitLab Duo 新手，从这些功能开始：

- **[GitLab Duo Chat](../gitlab_duo_chat/_index.md)** - 询问有关 极狐GitLab 的问题并获得基础任务帮助
- **[代码建议](../project/repository/code_suggestions/_index.md)** - 在 IDE 中获取原生 AI 补全
- **[代码解释](../project/repository/code_explain.md)** - 理解文件或合并请求中的代码
- **[合并请求摘要](../project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes)** - 自动为你的变更生成描述

<a id="for-intermediate-users"></a>

### 面向进阶用户

在掌握基础后，尝试这些更高级的功能：

- **[测试生成](../gitlab_duo_chat/examples.md#write-tests-in-the-ide)** - 自动为你的代码创建测试
- **[根因分析](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)** - 排查失败的 CI/CD 作业

<a id="for-advanced-users"></a>

### 面向高级用户

当你准备好用 GitLab Duo 最大化生产力时：

- **[自部署模型的 GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)** - 在你自己的基础设施上托管 LLM
- **[GitLab Duo Agent Platform](../duo_agent_platform/_index.md)** - 在你的开发工作流中自动化任务
- **[漏洞修复](../application_security/vulnerabilities/_index.md#vulnerability-resolution)** - 自动生成合并请求以修复安全问题

<a id="best-practices"></a>

## 最佳实践

遵循以下提示以高效使用 GitLab Duo：

1. **在提示中尽量具体**
   - 提供清晰的上下文以获得更佳结果
   - 包含与你的代码与目标相关的细节
   - 在 Chat 中使用代码任务命令，如 `/explain`、`/refactor` 和 `/tests`

2. **负责任地改进代码**
   - 在使用前始终审查 AI 生成的代码
   - 测试生成的代码以确保其符合预期
   - 使用漏洞修复时配合适当的评审

3. **迭代优化**
   - 如果响应不够有用，优化你的问题
   - 尝试将复杂请求拆分为更小的部分
   - 提供更多细节以获得更好的上下文

4. **利用 Chat 学习**
   - 询问你不熟悉的 极狐GitLab 功能
   - 获取错误信息与问题的解释
   - 学习与你的特定技术相关的最佳实践

<a id="next-steps"></a>

## 后续步骤

准备更深入探索？试试这些资源：

- [GitLab Duo 使用场景](use_cases.md) - 实用示例与练习
- [设置 自部署模型的 GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) - 完全掌控你的数据

<a id="troubleshooting"></a>

## 故障排查

遇到问题？查看这些常见解决方案：

- [GitLab Duo 功能在 私有化部署 环境下无法工作](troubleshooting.md#gitlab-duo-features-do-not-work-on-self-managed)
- [用户无法使用 GitLab Duo 功能](troubleshooting.md#gitlab-duo-features-not-available-for-users)
- [运行健康检查](../../administration/gitlab_duo/setup.md#run-a-health-check-for-gitlab-duo) 以诊断你的 GitLab Duo 设置

需要更多帮助？搜索 极狐GitLab 文档，或 [咨询 极狐GitLab 社区](https://forum.gitlab.com/)。
