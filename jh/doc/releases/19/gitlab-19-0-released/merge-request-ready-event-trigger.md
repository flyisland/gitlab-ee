---
title: 合并请求就绪事件触发器
stage: ai-powered
level: secondary
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed ]
documentation_link: "../../../user/duo_agent_platform/triggers/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/592454"
categories: [ Duo Agent Platform ]
weight: 30
---

您现在可以配置任务流和外部 Agent，使其在**合并请求就绪**事件上运行。

当草稿合并请求被标记为可供评审时，极狐GitLab Duo 会自动运行该任务流或外部 Agent。

要配置触发器，请在您的项目中转到 **AI** > **触发器**。

此功能受 `merge_request_ready_flow_trigger` 功能标志控制，默认禁用。
