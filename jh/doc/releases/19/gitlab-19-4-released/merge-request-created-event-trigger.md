---
title: 合并请求创建事件触发器
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_coding
documentation_link: "../../../user/duo_agent_platform/triggers/"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22279
categories: [ DAP Triggers ]
level: secondary
weight: 50
---

在之前的极狐GitLab 版本中， **合并请求**触发器事件类型仅支持**已批准**、**标记为就绪**和**合并冲突**操作。当有人打开合并请求时，如果不使用极狐GitLab 之外的工具，您无法立即运行任务流或外部 Agent。

现在，您可以选择**已创建**作为触发操作。当有人打开处于草稿或就绪状态的合并请求，并且极狐GitLab 生成差异后，您的任务流或外部 Agent 便会运行。您可以将其用于首轮评审，或从相关议题中补充上下文。

要配置此触发器，请转到项目中的 **AI > 触发器**，或在启用任务流时选择它。
