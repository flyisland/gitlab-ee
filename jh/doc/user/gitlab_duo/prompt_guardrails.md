---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: AI-native features and functionality.
title: 极狐GitLab Duo 提示护栏
---

极狐GitLab Duo 具有基础的提示护栏。这些护栏依赖于结构化提示、强制上下文边界和过滤工具，有助于：

- 减少敏感数据暴露。
- 防止提示注入。
- 引导模型给出安全且有用的响应。

这些保护措施通过帮助最小化与 AI 驱动工作流相关的风险，支持符合 GDPR 等常见监管标准。

> [!note]
> 虽然这些护栏可以降低风险，但无法消除所有漏洞。没有任何系统能够保证完全防止所有滥用或复杂攻击。

<a id="general-guardrails"></a>

## 通用护栏

极狐GitLab Duo 使用的提示旨在：

- 避免不允许的内容：模型被指示要提供信息、礼貌，并避免仇恨或指责性语言。
- 严格遵守用户请求：模型被指示紧密遵循提示，避免角色扮演、冒充或偏离到无关内容。
- 使用标签隔离内容：标签指示模型专注于提供的片段，有助于降低提示注入的风险。
- 过滤密钥：代码建议会被扫描，以帮助避免无意中发送敏感信息。示例：包含敏感配置数据的客户作业日志被封装在 `<log>` 标签中，有助于确保模型仅关注提供的上下文，而不做出无关假设。

<a id="guardrails-by-job-role"></a>

## 按工作角色的护栏

根据您的角色，您可能对为极狐GitLab Duo 设置的护栏有不同的关注点。

<a id="for-technical-users"></a>

### 面向技术用户

- **代码隔离**：像 `<selected_code>`、`<git_diff>` 和 `<log>` 这样的标签鼓励模型严格专注于您提供的代码或内容，有助于降低提示注入的风险。
- **密钥过滤**：像 Gitleaks 这样的工具扫描代码建议，以帮助防止敏感数据（如 API 密钥或密码）被共享。
- **聚焦响应**：极狐GitLab Duo 专注于主题，有助于避免可能导致无用或意外输出的行为。
- **根因分析**：在进行故障排除时，极狐GitLab Duo 旨在分析作业日志，而不对提供的内容之外做出假设。

<a id="for-auditors-and-compliance-teams"></a>

### 面向审计和合规团队

- **法规对齐**：系统有助于降低数据泄露等风险，从而帮助组织保持与 GDPR 等标准的对齐。
- **透明度**：提示和上下文的构建方式有助于使极狐GitLab Duo 的操作可预测且可供审计。有关详细信息，请参见[功能护栏](#guardrails-for-features)。
- **内容控制**：对于像总结讨论或解决漏洞这样的任务，极狐GitLab Duo 仅使用提供的输入，有助于减少错误或意外输出的可能性。
- **防范恶意输入**：过滤器和标记机制有助于保护系统免受有害或格式不良的用户内容。

<a id="for-decision-makers"></a>

### 面向决策者

- **建立信心**：保护措施有助于确保极狐GitLab Duo 行为负责任，这对于对新工具的信任至关重要。
- **知情决策**：安全功能的清晰文档为您提供了评估极狐GitLab Duo 是否适合您的组织所需的信息。
- **降低风险**：通过解决围绕敏感数据和模型行为的常见问题，极狐GitLab Duo 为将 AI 集成到您的工作流中提供了一个安全、实用的解决方案。

<a id="guardrails-for-features"></a>

## 功能护栏

各个功能包含特定的提示指令，以帮助限制暴露。提示指令遵循以下原则。

<a id="gitlab-duo-agent-platform"></a>

### 极狐GitLab Duo Agent Platform

隔离不受信任的内容，以帮助防止提示注入。

在 AI 网关上，[检测提示注入尝试](../duo_agent_platform/security_threats.md#detect-prompt-injection-attempts) 并记录或阻止它们。

<a id="gitlab-duo-chat"></a>

### 极狐GitLab Duo Chat

响应应保持主题相关、建设性且非辱骂性。不鼓励个性转变、角色扮演或恶意指令。专注于用户提供的内容有助于降低注入风险。

<a id="discussion-summary"></a>

### 讨论总结

评论被总结，不鼓励与潜在恶意内容交互。应警告用户有关可疑评论，而不透露或复制它们。

<a id="code-explanation-test-generation-refactor-code-fix-code"></a>

### 代码解释、测试生成、重构代码、修复代码

使用标签包含代码并限制模型的焦点，这有助于防止模型考虑外部、未经验证的指令或内容。

<a id="gitlab-duo-for-cli"></a>

### 极狐GitLab Duo for CLI

将任务框架化为从自然语言生成 Git 命令，有助于限制范围并减少有害输出的风险。

<a id="merge-request-summary"></a>

### 合并请求总结

隔离代码以帮助防止提示注入。

<a id="code-review"></a>

### 代码审查

隔离代码以帮助防止提示注入。

<a id="merge-commit-message-generation"></a>

### 合并提交消息生成

使用标签帮助隔离和限制模型可以引用的内容。

<a id="root-cause-analysis"></a>

### 根因分析

使用标签帮助严格专注于提供的作业日志，并防止超出给定数据的假设。

<a id="vulnerability-resolution"></a>

### 漏洞解决

鼓励在不改变预期功能的情况下解决安全问题。模型被指示专注于提供的代码差异，以帮助防止更改代码。