---
title: 极狐GitLab Duo Developer 针对合并请求工作流的增强功能
stage: ai-powered
level: primary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/duo_agent_platform/flows/foundational_flows/developer/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/228817"
categories: [ Duo Agent Platform ]
weight: 40
---

极狐GitLab Duo Developer 现在支持多种触发方式：将其指派给议题，选择
**生成合并请求**，或在任意议题或合并请求讨论串中 `@mention` 它，即可将反馈、
待办事项和设计问题转化为代码变更、后续合并请求或研究摘要。

配置 `AGENTS.md` 和 `agent-config.yml`
后，极狐GitLab Duo Developer 会在提交前运行您的测试和检查。在顶级
群组或实例管理员启用开发者任务流后，极狐GitLab 会自动为符合条件的项目添加提及和指派触发器。
