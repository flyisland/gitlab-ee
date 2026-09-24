---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
gitlab_dedicated: no
title: 入门 Agent
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

入门 Agent 可帮助您设置极狐GitLab DevSecOps 平台。该 Agent 会读取您的项目上下文和订阅层级，然后解释功能、推荐下一步采用步骤，并提供配置示例（例如，`.gitlab-ci.yml`）。

入门 Agent 仅在极狐GitLab Duo Chat 中提供响应。它不会修改您的文件、流水线或项目设置。该 Agent 可以创建和更新工作项、议题和史诗，并向议题和工作项添加评论。在执行每个操作之前，Agent 会向您显示确切内容并等待您的批准。

在以下情况下使用入门 Agent：

- 首次设置团队或项目。
- 从 GitHub、Bitbucket 或 Jenkins 迁移，并将您现有的工作流映射到极狐GitLab。
- 在平台中采用更多功能，例如安全扫描、合规性或 Agentic 工作流。
- 了解您的层级包含哪些功能，或接下来要配置什么。

<a id="prerequisites"></a>

## 先决条件

在使用入门 Agent 之前：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。
- [开启测试版和实验性功能](../../turn_on_off.md#turn-on-beta-and-experimental-features)

<a id="use-the-onboarding-agent"></a>

## 使用入门 Agent

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在极狐GitLab Duo 侧边栏中，选择 **添加新会话** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中，选择 **入门 Agent**。

   聊天会话将在屏幕右侧的极狐GitLab Duo 侧边栏中打开。
1. 描述您需要什么帮助。为获得最佳结果：
   - 在同一会话中提出后续问题。Agent 会记住您会话的上下文，并使用该上下文提供说明。
   - 明确说明您是否想探索特定阶段（例如安全或合规性）。
   - 在将配置建议应用到您自己的项目之前，先审阅 Agent 的配置建议。

Agent 在响应之前会从您当前的项目和层级收集上下文，并提供针对上下文的说明。

<a id="example-prompts"></a>

## 示例提示

使用这些提示开始：

- `Help me get started with GitLab.`
- `I'm migrating from GitHub — where should I begin?`
- `Set up security scanning for this project.`
- `What should I do next to get more value out of GitLab?`
- `What features am I missing on my current tier?`
- `Help me convert my Jenkins pipeline to GitLab CI/CD.`
- `Help me get started with compliance frameworks.` (旗舰版)

<a id="known-issues"></a>

## 已知问题

- 该 Agent 仅在极狐GitLab Duo Chat UI 和您的 IDE 中运行。您无法为此 Agent 创建[触发器](../../triggers/_index.md)。
- 该 Agent 不会创建、编辑或提交文件，修改流水线，或更改项目设置。在您批准每个操作后，它可以创建和更新工作项、议题和史诗，并向议题和工作项添加评论。
- 该 Agent 无法读取漏洞、安全发现、流水线错误或作业日志。它会向您询问相关输出，并可能引导您使用 Security Analyst Agent 或 CI Expert Agent。它无法委派给其他 Agent。
- 该 Agent 使用项目和页面上下文，但无法始终检测特定功能是否已为项目开启。
- Agent Platform 的使用情况会在 [极狐GitLab Duo 和 SDLC 趋势仪表板](../../../analytics/duo_and_sdlc_trends.md) 上汇总报告。您目前还无法查看单个 Agent 的使用情况。

<a id="give-feedback"></a>

## 提供反馈

此 Agent 是一个实验，您的反馈有助于我们改进它。
要分享您的体验或报告问题，请在
[议题 606350](https://gitlab.com/gitlab-org/gitlab/-/issues/606350) 中添加评论。
