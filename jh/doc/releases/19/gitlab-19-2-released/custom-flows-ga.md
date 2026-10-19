---
title: 极狐GitLab Duo 自定义 Flow 已正式发布
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/duo_agent_platform/flows/custom"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/602415
categories: [ AI Catalog Creation ]
level: primary
weight: 10
---

自定义 Flow 是您创建和配置的 AI 驱动工作流，用于在极狐GitLab 项目中自动完成复杂的多步骤任务。它们让团队能够定义工作流步骤、组件和触发器，使重复性的开发和运维工作能够响应极狐GitLab 事件自动运行。在极狐GitLab UI 中，Flow 直接在极狐GitLab CI/CD 中运行，帮助团队在不离开极狐GitLab 的情况下自动完成常见任务。

主要功能包括：

- 基于 YAML 定义的可复用工作流，适用于团队特定的自动化场景
- 多 Agent 编排，用于复杂的多步骤任务
- 用户定义的人工介入（HITL）检查点，可在敏感步骤进行审批或反馈
- 原生极狐GitLab 触发器，包括提及、指派、流水线事件和合并请求生命周期事件
- 从项目或 AI 目录创建和管理 Flow
- 公开和私有可见性控制
- 使用服务账号和复合身份进行安全执行
- YAML 验证，可在运行前发现配置问题
