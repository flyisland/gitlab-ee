---
title: 来自社区的极狐GitLab MCP 服务器工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
co_create: true
documentation_link: "../../../user/model_context_protocol/mcp_server_tools/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/248155
categories: [ Agent Tools ]
level: secondary
weight: 30
---

社区贡献者为极狐GitLab MCP 服务器添加了新工具。Agent 现在可以使用 `get_project` 和 `list_project_members` 读取项目元数据和成员，使用 `list_branches` 列出代码仓库的分支，以及使用 `list_merge_requests` 列出整个群组中的合并请求。`get_duo_session` 可获取极狐GitLab Duo 会话，让您查看此前的运行做了什么。

这些工具与 19.4 中的其他新极狐GitLab MCP 服务器工具一同发布，并遵循相同的工具治理规则，因此使用它们的 Agent 会遵守您团队已设定的规则。

感谢以下用户做出的这些贡献！

- [Dhairya Majmudar](https://gitlab.com/DhairyaMajmudar)（[合并请求 1](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/248155) [合并请求 2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/250316)）
- [Giannis Kepas](https://gitlab.com/gkepas)（[合并请求 1](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/250430) [合并请求 2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/251379)）
- [Mahaveer A](https://gitlab.com/Mahaveer1013)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/252619)）
