---
title: 定时流水线执行策略（测试版）
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: security_risk_management
documentation_link: "../../../user/application_security/policies/scheduled_pipeline_execution_policies/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/17875"
categories: [ Security Policy Management ]
level: secondary
weight: 50
---

定时流水线执行策略现已作为测试版功能提供，不再需要实验标志即可启用。您可以在项目中按每日、每周或每月的节奏强制执行自定义 CI/CD 作业，无需依赖提交活动。使用定时策略对可能没有定期代码变更的代码仓运行合规脚本、安全扫描或依赖项检查。

定时策略现在与常规流水线执行策略一致地强制执行变量优先级。每个安全策略项目最多支持五条定时策略，当策略被禁用或删除时，极狐GitLab 会自动取消正在运行的流水线。您可以在 YAML 或 UI 中配置计划，支持时区、时间窗口分布、分支定位和暂停功能。
