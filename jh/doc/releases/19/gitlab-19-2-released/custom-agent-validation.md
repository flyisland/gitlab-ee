---
title: 自定义 Agent 验证
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/duo_agent_platform/agents/custom"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/601986
categories: [ AI Catalog Creation ]
level: secondary
weight: 50
---

以前，您可以在 AI 目录中保存自定义 Agent，但其提示词在运行时可能失败。例如，触发安全规则的提示词会导致该 Agent 在使用时静默无响应。

现在，当您创建或更新自定义 Agent 时，极狐GitLab 会验证提示词配置，并在保存该 Agent 之前告知您所有错误。
