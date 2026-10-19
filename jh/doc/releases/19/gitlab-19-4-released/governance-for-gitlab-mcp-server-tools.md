---
title: 极狐GitLab MCP 服务器工具的治理
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
tier: [ Free, Premium, Ultimate ]
stage: software_supply_chain_security
documentation_link: "../../../user/ai-governance/tool-governance"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/628391
categories: [ AI Governance ]
level: primary
weight: 50
---

此前，您只能将 [AI Agent 工具治理](../../../user/ai-governance/tool-governance.md)
规则应用于内部极狐GitLab Duo Agent Platform 工具。通过极狐GitLab MCP 服务器提供给极狐GitLab Duo Agent Platform 和
第三方 Agent 使用的工具，则遵循无法更改的固定规则。

现在，您可以在与内部极狐GitLab Duo Agent Platform
工具相同的位置治理极狐GitLab MCP 服务器工具。它们会与内部工具一起显示在您的群组和项目 **极狐GitLab Duo** 设置中，您可以在其中为每个工具设置模式：

- 只读工具默认为**始终允许**，因此日常查询无需打断您的团队即可运行。
- 写入和删除工具默认为**始终询问**，在 Agent 更改任何内容之前为审核人提供一个检查点。
