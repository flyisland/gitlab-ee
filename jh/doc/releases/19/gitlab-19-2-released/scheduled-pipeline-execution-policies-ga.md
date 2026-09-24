---
title: 定时流水线执行策略已正式发布
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: security_risk_management
documentation_link: "../../../user/application_security/policies/scheduled_pipeline_execution_policies/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/17875"
categories: [ Security Policy Management ]
level: primary
weight: 10
---

定时流水线执行策略已正式发布。在安全策略项目中定义一次计划，即可在范围内的每个项目中强制执行，无需编辑每个项目的 `.gitlab-ci.yml`。如果需求发生变化，只需在一个位置更新策略，而无需协调多个 CI/CD 配置文件中的变更。

使用定时策略按每日、每周或每月的节奏运行合规性脚本、安全扫描或其他自定义 CI/CD 作业，与提交活动无关。这对于没有定期代码变更的代码仓非常有用，例如运行依赖项扫描以检测新发现的漏洞。每个策略作为独立的流水线运行，并带有时区支持、时间窗口分布和分支目标指定。
