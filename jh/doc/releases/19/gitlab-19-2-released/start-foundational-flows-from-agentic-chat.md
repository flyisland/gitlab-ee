---
title: 从 Agentic Chat 启动内置任务流
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_clients
documentation_link: "../../../user/gitlab_duo_chat/agentic_chat"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/20484
categories: [ Web Chat ]
level: primary
weight: 20
---

在之前的极狐GitLab 版本中，您通过特定的 UI 操作、提及或指派来启动内置任务流。现在，您可以在极狐GitLab UI 中通过 Agentic Chat 启动它们，作为对话的一部分。

当您的请求与某个专业工作流匹配时，Agentic Chat 会将任务移交给以下任务流之一：

- [开发者任务流](../../../user/project/merge_requests/developer.md)：
  实施变更或创建合并请求
- [代码评审任务流](../../../user/duo_agent_platform/flows/foundational_flows/code_review/_index.md)：
  审查合并请求
- [修复 CI/CD 流水线任务流](../../../ci/pipelines/fix_pipeline.md)：
  诊断并修复失败的流水线

您在聊天中批准移交，然后通过对话或 **AI** > **会话** 跟踪进度。
