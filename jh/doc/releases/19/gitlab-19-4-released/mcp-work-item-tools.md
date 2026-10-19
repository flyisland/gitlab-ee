---
title: MCP 服务器工作项工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server_tools"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/627598
categories: [ Agent Tools ]
level: secondary
weight: 50
---

极狐GitLab MCP 服务器现已提供工作项工具，因此 Agent 和 MCP 客户端可以搜索、读取、创建和更新议题、史诗、任务、事件、目标和关键结果。

使用 `get_work_item` 深入读取单个项，使用 `list_work_items` 在群组或项目中搜索，使用 `save_work_item` 创建或更新任何工作项类型。

由于议题和史诗都是工作项类型，`get_work_item` 和 `save_work_item` 涵盖了 `get_issue` 和 `create_issue` 目前的功能。

`save_note` 让 Agent 可以对工作项或合并请求发表评论，并在现有讨论串中回复。引入此工具后，现有的 `create_merge_request_note` 和 `create_workitem_note` 已重命名。
