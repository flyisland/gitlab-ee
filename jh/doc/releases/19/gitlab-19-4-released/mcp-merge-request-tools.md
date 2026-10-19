---
title: MCP 服务器合并请求工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server_tools"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/627598
categories: [ Agent Tools ]
level: secondary
weight: 50
---

合并请求工具让 Agent 可以通过极狐GitLab MCP 服务器运行完整的合并请求循环：

- `save_merge_request` 打开并更新合并请求。
- `get_merge_request` 深入检查合并请求，并提供新的差异、冲突和审批方面。
- `save_merge_request_review` 留下行级评审评论，可在单次调用中批量提交差异评论和摘要。
- `accept_merge_request` 在检查通过后合并合并请求，还可以批准或取消批准该合并请求。
