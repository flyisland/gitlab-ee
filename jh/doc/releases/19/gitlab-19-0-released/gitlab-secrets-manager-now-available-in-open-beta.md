---
title: 极狐GitLab 密钥管理器现已开放公开测试版
stage: software_supply_chain_security
level: primary
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed ]
documentation_link: "../../../ci/secrets/secrets_manager/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/21731"
categories: [ Secrets Management ]
weight: 30
---

在之前的极狐GitLab 版本中，极狐GitLab 密钥管理器（Secrets Manager）仅向封闭测试版用户群体开放。大多数团队依赖 HashiCorp Vault 或 AWS Secrets Manager 等外部服务。

极狐GitLab 密钥管理器现已面向 JihuLab.com 上的专业版和旗舰版客户以及极狐GitLab 私有化部署开放公开测试版。启用极狐GitLab 密钥管理器后，项目和群组所有者可以在极狐GitLab 中存储、检索和引用 CI/CD 密钥。密钥的作用范围限定在项目或群组内，只有明确请求这些密钥的流水线作业才能访问。

在公开测试版期间，极狐GitLab 密钥管理器遵循
[测试版支持政策](../../../policy/development_stages_support.md#beta)，可能尚未准备好用于生产环境。

如需分享反馈，请参阅[议题 598100](https://gitlab.com/gitlab-org/gitlab/-/issues/598100)。
