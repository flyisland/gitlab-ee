---
title: 极狐GitLab Duo CLI 插件和插件市场（实验）
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_clients
documentation_link: "../../../user/gitlab_duo_cli/customize/#plugins"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22497
categories: [ Duo CLI ]
level: secondary
weight: 50
---

极狐GitLab Duo CLI 现已支持插件和插件市场（实验），该功能在极狐GitLab Duo CLI 9.10.0 中引入。插件将 Agent Skills、自定义斜杠命令和模型上下文协议（MCP）服务器打包到一个目录中。市场是可用插件的目录，托管在 Git 代码仓库或本地目录中。

首次使用插件时，极狐GitLab Duo CLI 会自动注册官方 `gitlab-duo-plugins` 市场。

该市场包含三个用于常见极狐GitLab 工作流的 skills：

- `mr-review`：评审合并请求并发布评论。
- `stack-changes`：将大型本地变更拆分为堆叠的合并请求链。
- `create-issue`：根据自然语言描述起草极狐GitLab 议题。

要安装其中一个 skill，请根据您的环境运行 `glab duo cli plugin install <plugin>@gitlab-duo-plugins` 或 `duo plugin install <plugin>@gitlab-duo-plugins`。

为了与现有社区插件生态系统兼容，极狐GitLab Duo CLI 还会读取 `.claude-plugin/marketplace.json` 文件，因此现有的 Claude Code 插件市场无需修改即可与极狐GitLab Duo CLI 配合使用。
