---
title: 从 Agentic Chat 启动基础 Flow
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_clients
documentation_link: "../../../user/gitlab_duo_chat/agentic_chat"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/20484
categories: [ Web Chat ]
level: primary
weight: 20
---

在之前的极狐GitLab 版本中，您通过特定的 UI 操作、提及或指派来启动基础 Flow。
现在您可以从极狐GitLab UI 中的 Agentic Chat 启动它们，作为对话的一部分。

当您的请求与某个专业工作流匹配时，Agentic Chat 会将任务移交给以下 Flow 之一：

- [开发者 Flow](../../../user/duo_agent_platform/flows/foundational_flows/developer.md)：实施变更或创建合并请求
- [代码审查 Flow](../../../user/duo_agent_platform/flows/foundational_flows/code_review.md)：审查合并请求
- [修复 CI/CD 流水线 Flow](../../../user/duo_agent_platform/flows/foundational_flows/fix_pipeline.md)：诊断并修复失败的流水线

您在聊天中批准移交，然后通过对话或 **AI** > **会话** 跟踪进度。
