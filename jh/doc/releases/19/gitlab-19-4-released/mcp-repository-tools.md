---
title: MCP 服务器代码仓库工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server_tools"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/627598
categories: [ Agent Tools ]
level: secondary
weight: 50
---

新的代码仓库工具让 Agent 能够通过极狐GitLab MCP 服务器浏览项目结构、读取提交历史并提出变更：

- `list_repository_tree` 浏览文件树。
- `list_tags` 枚举引用。
- `list_releases` 查看已发布的版本。
- `get_commit` 获取提交的元数据、差异或评论。
- `list_commits` 分页浏览分支的历史记录。
- `add_commit` 在单次调用中提交一个或多个文件操作，可选择提交到基于特定起始引用或源项目创建的新分支。
- `fork_repository` forks 项目，使 Agent 无需离开其客户端，即可从探索上游代码仓库转为提出变更。
