---
title: 带管理员控制的按会话工具审批
stage: ai-powered
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/gitlab_duo_chat/agentic_chat/#tool-approvals"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/596366"
categories: [ Duo Agent Platform, Duo Chat ]
weight: 70
---

在极狐GitLab Duo Agentic Chat 代表您使用工具之前，需要获得您的批准。每次工具调用都需要单独批准。

现在，您可以一次性批准一个可信工具在整个会话中使用，从而简化工作流程。

管理员控制会话工具审批是否可用。以下设置从实例级联到群组再到项目：

- **默认开启**
- **默认关闭**
- **始终关闭**

群组和子群组可以修改该设置，除非管理员将其设置为**始终关闭**。

默认设置为**默认关闭**，确保每次工具调用都需要明确批准，除非管理员更改此设置。
