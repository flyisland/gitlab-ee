---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件开发流程
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- LLM：国内 SOTA 大模型
- 可访问 [自部署模型的 极狐GitLab Duo](../../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.4 中作为私有 Beta 引入，带有一个名为 `duo_workflow` 的功能标志。仅对极狐GitLab 团队成员启用。
- 在极狐GitLab 18.2 中于 JihuLab.com 和私有化部署上启用，并更改为 Beta。
- 在极狐GitLab 18.8 中 GA。功能标志 `duo_workflow` 已移除。
- 在极狐GitLab 18.10 中于 JihuLab.com 的基础版上可用，使用极狐GitLab Credits。

{{< /history >}}

软件开发流程帮助你在整个软件开发生命周期中创建 AI 生成的解决方案。
以前称为 GitLab Duo Workflow，此流程：

- 根据你的提示创建并执行计划。
- 将建议的更改暂存到项目仓库中。你可以控制何时接受、修改或拒绝这些建议。
- 理解项目结构、代码库和历史的上下文。你还可以添加自己的上下文，例如相关的极狐GitLab 议题或合并请求。

<a id="supported-languages"></a>

## 支持的语言

软件开发流程正式支持以下语言：

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

## 流程可访问的 API

为了创建解决方案并理解问题的上下文，该流程会访问多个极狐GitLab API。

具体来说，具有 `ai_workflows` 范围的 OAuth 令牌可以访问以下 API：

- [项目 API](../../../../api/projects.md)
- [搜索 API](../../../../api/search.md)
- [CI 流水线 API](../../../../api/pipelines.md)
- [CI 作业 API](../../../../api/jobs.md)
- [合并请求 API](../../../../api/merge_requests.md)
- [史诗 API](../../../../api/epics.md)
- [议题 API](../../../../api/issues.md)
- [评论 API](../../../../api/notes.md)
- [使用数据 API](../../../../api/usage_data.md)
- [元数据 API](../../../../api/metadata.md)（包括已弃用的 `/version` 端点）

<a id="audit-log"></a>

## 审计日志

软件开发流程会为每个 API 请求生成审计事件。
在你的私有化部署实例上，你可以在[实例审计事件](../../../../administration/compliance/audit_event_reports.md#instance-audit-events)页面上查看这些事件。

<a id="risks"></a>

## 风险

软件开发流程使用 AI Agent，该代理可以使用你的极狐GitLab 帐户执行操作。
基于大语言模型的 AI 工具可能不可预测。使用前请审查潜在风险。

在启用此产品之前，请考虑所有已记录的风险。主要风险包括：

- 软件开发流程可以访问项目本地文件系统中的文件，包括未被 Git 跟踪或在 `.gitignore` 中排除的文件。这可能包括敏感信息，例如 `.env` 文件中的凭据。
- 软件开发流程被授予一个限时的极狐GitLab OAuth 令牌，具有 `ai_workflows` 范围，并与你的用户身份关联。此令牌允许在工作流程期间访问指定的极狐GitLab API。默认情况下，仅执行读取操作而无需明确批准，但根据你的权限，也可能执行写入操作。
- 不要向软件开发流程提供额外的凭据或密钥（例如，在消息或目标中），因为这些可能被无意中使用或在代码或 API 调用中暴露。