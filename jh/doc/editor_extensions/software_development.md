---
stage: Agent Foundations
group: Agent Developer
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件开发任务流
---

{{< details >}}

- Tier: [基础版](../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- LLM: DeepSeek-V4-Pro-0813（JihuLab.com 默认模型）
- 适用于[自部署模型的极狐GitLab Duo](../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

软件开发任务流可帮助您为软件开发生命周期中的各项工作创建 AI 生成的解决方案。
该任务流原名极狐GitLab Duo Workflow，它可以：

- 在您的 IDE 中运行，因此您无需切换上下文或工具。
- 根据您的提示创建计划并逐步执行。
- 将建议的变更暂存到您项目的代码仓库中。
  您可以自行决定何时接受、修改或拒绝这些建议。
- 理解您的项目结构、代码库和历史的上下文。
  您还可以添加自己的上下文，例如相关的极狐GitLab 议题或合并请求。

该任务流可在 VS Code、Visual Studio 和 JetBrains 中使用。

<a id="prerequisites"></a>

## 先决条件

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../user/duo_agent_platform/_index.md#prerequisites)。
- 为您的 IDE 安装并配置[编辑器扩展](_index.md)。

<a id="flow-and-chat-comparison"></a>

## 任务流与 Chat 对比

软件开发任务流和极狐GitLab Duo Chat 都可在您的 IDE 中的不同标签页中使用。

使用软件开发任务流处理复杂的开发任务。

- 该任务流会收集全面的上下文，创建详细的计划供您审阅，并有条不紊地执行
  各项任务。
- 该任务流采用结构化方法，非常适合需要大型上下文窗口的较长、较深入的会话，
  并且对于需要迭代的代码生成能产生更好的结果。
- 每个任务流都有开始和结束。当您启动新任务流时，它会重新收集上下文，并根据项目的
  当前状态创建新计划。

使用极狐GitLab Duo Chat 进行由您引导方向的对话式交互。

- Chat 可以收集信息来回答问题、提供建议，并根据您的提示自主代表您执行
  操作。
- Chat 会保持连续对话，因此您可以返回任何正在进行的讨论，并从上次中断的地方
  继续。

虽然两者都能帮助处理类似的任务，但它们的工作方式不同。任务流会预先收集全面的上下文，并在极少人工干预的情况下运行。Chat 则与您保持持续的反馈循环，并在对话过程中按需收集上下文。例如，任务流会在提出方案之前考虑不同的解决方案，而 Chat 会直接采用第一个可行的路径以快速给出结果。

<a id="use-the-software-development-flow"></a>

## 使用软件开发任务流

要使用该任务流：

1. 在您的 IDE 中，选择**极狐GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）。
1. 选择 **Flows** 标签页。
1. 在文本框中，详细说明一项代码任务。
   - 该任务流可感知项目分支中 Git 可访问的所有文件。
   - 您可以为对话提供额外的[上下文](../user/duo_agent_platform/context.md#gitlab-duo-agentic-chat)。
   - 该任务流无法访问外部来源或网络。
   - 例如：

     ```plaintext
     I have a large Ruby class that is used in a few places and I want to break it down.
     Analyze this class and see what sub-methods or properties can be delegated to a
     separate class. Then, propose a transition plan to implement this new sub-class
     and update all of the required tests.
     ```

1. 选择 **开始**。

在您描述任务后，该任务流会生成并执行计划。您可以暂停或要求该任务流调整计划。

<a id="supported-languages"></a>

## 支持的语言

软件开发任务流正式支持以下语言：

- CSS
- Go
- HTML
- Java
- JavaScript
- Markdown
- Python
- Ruby
- TypeScript

<a id="apis-that-the-flow-has-access-to"></a>

## 该任务流可访问的 API

为了创建解决方案并理解问题的上下文，该任务流会访问多个极狐GitLab API。

具体来说，具有 `ai_workflows` 范围的 OAuth 令牌可以访问
以下 API：

- [项目 API](../api/projects.md)
- [搜索 API](../api/search.md)
- [CI 流水线 API](../api/pipelines.md)
- [CI 作业 API](../api/jobs.md)
- [合并请求 API](../api/merge_requests.md)
- [史诗 API](../api/epics.md)
- [议题 API](../api/issues.md)
- [评论 API](../api/notes.md)
- [使用数据 API](../api/usage_data.md)
- [元数据 API](../api/metadata.md)（包括已弃用的 `/version` 端点）

<a id="audit-log"></a>

## 审计日志

软件开发任务流会为每个 API 请求生成一个审计事件。在您的极狐GitLab 私有化部署实例上，您可以在[实例审计事件](../administration/compliance/audit_event_reports.md#instance-audit-events)页面查看这些事件。

<a id="risks"></a>

## 风险

软件开发任务流使用 AI Agent，该 Agent 可以使用您的极狐GitLab 账号执行操作。基于大语言模型的 AI 工具可能难以预测。使用前请审阅潜在风险。

VS Code、JetBrains IDE 和 Visual Studio 中的软件开发任务流会在您的
本地工作站上运行工作流。启用此产品前，请考虑所有已记录的风险。主要风险包括：

- 软件开发任务流可以访问项目本地文件系统中的文件，包括
  Git 未跟踪或已在 `.gitignore`中排除的文件。这可能包含敏感信息，
  例如 `.env` 文件中的凭据。
- 软件开发任务流会被授予一个有时限的极狐GitLab OAuth 令牌，其范围为 `ai_workflows`，
  并与您的用户身份关联。该令牌允许在工作流期间访问指定的极狐GitLab API。默认情况下，
  未经明确批准只会执行读取操作，但根据您的权限也可能执行写入操作。
- 不要向软件开发任务流提供额外的凭据或密钥（例如
  在消息或目标中），因为这些内容可能会被意外使用，或在代码或 API 调用中泄露。
