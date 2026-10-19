---
title: 管理员为 Agent Platform 远程任务流定义网络访问控制
stage: ai-powered
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/duo_agent_platform/environment_sandbox/#configure-a-network-policy"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/593149"
categories: [ Duo Agent Platform ]
weight: 110
---

管理员现在可以直接在设置中为极狐GitLab Duo Agent Platform 远程任务流定义集中式网络策略。
JihuLab.com 上的顶级群组管理员以及极狐GitLab 私有化部署上的实例管理员，可以配置组织范围的域名拒绝列表和允许列表，
项目会自动继承这些列表。另有一项设置用于控制项目是否可以通过自定义条目扩展已批准的域名列表。
策略在运行时对所有远程任务流强制执行，为安全和平台团队提供一致的 Agent 网络出口治理层。
