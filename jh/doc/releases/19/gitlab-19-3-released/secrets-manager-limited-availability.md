---
title: 极狐GitLab Secrets Manager 现已在 JihuLab.com 上推出
tier: [ Premium, Ultimate ]
add_ons: ["GitLab Secrets Manager"]
offering: [ gitlab_com ]
stage: software_supply_chain_security
documentation_link: "../../../ci/secrets/secrets_manager/"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/10723
categories: [ Secrets Management ]
level: primary
weight: 50
---

凭据泄露往往以相同的方式开始：开发者需要某个密钥，却没有合适的地方存放，于是将其放入权限过大的 CI/CD 变量或已提交的配置文件中。极狐GitLab Secrets Manager 现已在 JihuLab.com 上推出限量提供，让凭据更加安全，并使其与运行您的流水线保持在同一平台。

每个密钥都根据环境、分支和分支保护，限定在需要它的作业范围内，因此被泄露的凭据无法访问超出其授权范围的资源。Secrets Manager 使用您现有的群组和项目权限，因此无需维护单独的访问模型。每次创建、更新和读取操作都会记录到您的审计事件记录中，因此泄露调查无需再拼接来自多个系统的日志。
