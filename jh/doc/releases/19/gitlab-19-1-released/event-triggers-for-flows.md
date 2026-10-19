---
title: Flow 和外部 Agent 的新事件触发器
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Premium, Ultimate ]
documentation_link: "../../../user/duo_agent_platform/triggers/#create-a-trigger"
categories: [ Duo Agent Platform ]
level: secondary
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/21997
stage: ai-powered
---

在极狐GitLab 的早期版本中，您只能在服务账户被提及、指派或添加为审查者时运行 Flow 和外部 Agent。围绕
合并请求生命周期其余部分或工作项创建来协调自动化，需要外部胶合代码。

现在，您可以为以下四个额外事件配置触发器：

- **合并请求就绪**：用户将草稿合并请求标记为可供审查。此事件触发器此前受功能标志控制，已正式发布。
- **合并请求代码冲突**：合并请求因代码冲突而无法再合并。
- **合并请求已批准**：合并请求已获得所有必需的批准。
- **工作项已创建**：用户在项目中创建工作项。

要配置触发器，请前往项目中的 **AI** > **触发器**，或在启用 Flow 时选择一个触发器。
