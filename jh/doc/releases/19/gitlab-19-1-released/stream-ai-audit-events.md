---
title: 将 AI 审计事件流式传输到外部目标（测试版）
offering: [ self_managed, gitlab_dedicated ]
tier: [ Ultimate ]
stage: software_supply_chain_security
documentation_link: "../../../administration/compliance/audit_event_streaming/#ai-audit-event-streaming"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22383
categories: [ Audit Events ]
---

您现在可以通过极狐GitLab 审计事件流式传输基础设施，将 AI 审计事件流式传输到外部目标，使安全和合规团队能够实时了解 LLM 和 AI 交互。

启用 AI 审计事件流式传输后，极狐GitLab 会将这些事件转发到任何活跃的实例流式传输目标，包括您的 SIEM（安全信息和事件管理），以及其他审计事件。
