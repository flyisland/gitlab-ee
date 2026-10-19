---
title: AI 审计事件报告（测试版）
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
tier: [ Premium, Ultimate ]
stage: software_supply_chain_security
documentation_link: "../../../user/duo_agent_platform/ai-audit-events/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/20237"
categories: [ Compliance Management, Audit Events ]
level: primary
ignore_in_report: true
---

<!-- categories: Compliance Management, Audit Events -->

AI 审计事件报告现已进入测试版，为安全和合规团队提供极狐GitLab Duo Agent 活动的统一、可下载记录。

此前，Agent 活动分散在流水线作业和事件历史中，难以针对以下场景重建会话：

- 事件调查。
- 合规审查。
- AI 治理报告。

现在，每个 Agent 会话都会生成一份全面的审计产物，其中包含：

- 输入。
- 模型和配置上下文。
- 按时间顺序的事件时间线。
- 输出。

您可以从 **治理** 页面浏览 AI 审计事件，按 Agent 和会话详情进行筛选，深入查看单个事件，并下载底层会话产物。
