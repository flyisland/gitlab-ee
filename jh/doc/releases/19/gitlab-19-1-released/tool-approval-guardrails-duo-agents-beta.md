---
title: "极狐GitLab Duo Agent 工具审批护栏（测试版）"
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
tier: [ Premium, Ultimate ]
stage: software_supply_chain_security
documentation_link: "../../../user/duo_agent_platform/agents/tool-governance/"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22381
categories: [ AI Governance ]
level: primary
---

管理员现在可以为极狐GitLab Duo Agent 配置工具级审批策略，在执行时通过人工审批来控制敏感操作。

此前，AI Agent 在获得项目授权后，可以调用其任何工具而无需进一步审查，包括写入和破坏性操作。
现在，您可以为群组和项目定义规则，将每个工具映射到以下三种模式之一：

- 允许（静默执行）。
- 询问（需要人工审批）。
- 拒绝（完全阻止）。

当 AI Agent 调用处于“询问”模式的工具时，系统会在执行前向用户显示内联审批卡片。

此测试版包含 Agentic Chat 和 Flow，并为每个审批决策生成审计事件。
