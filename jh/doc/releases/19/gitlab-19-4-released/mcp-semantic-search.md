---
title: MCP 服务器语义搜索工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server_tools"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/250372
categories: [ Agent Tools ]
level: secondary
weight: 50
---

`semantic_code_search` 现已更名为 `semantic_search`。该工具按含义查找代码，而不是按精确的符号或文件名，这一点与早期版本保持一致。此次更名新增了 `scope` 参数，以便将来版本中可以将更多已建立索引的内容类型并入同一工具。目前 `scope` 仅接受 `code`。

感谢 [arun kumar](https://gitlab.com/arunsdev)的贡献！
