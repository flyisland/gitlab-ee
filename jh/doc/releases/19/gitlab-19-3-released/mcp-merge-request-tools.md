---
title: 用于读取和搜索合并请求的新 MCP 工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server_tools"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/605878
categories: [ Agent Tools ]
level: secondary
weight: 50
---

您现在可以使用 `get_merge_request` 在单次调用中检索合并请求及其差异、提交、
评论、流水线或讨论，因此您的 AI Agent 无需再串联
多个请求即可全面了解合并请求。

您还可以使用新的 `list_merge_requests`
工具，按作者、指派人、审核人、状态、标记或
自由文本查询来搜索和筛选合并请求，从而无需离开工作流即可轻松找到您关心的确切合并请求。
