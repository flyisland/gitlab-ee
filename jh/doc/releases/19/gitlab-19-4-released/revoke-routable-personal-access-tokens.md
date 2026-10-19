---
title: 可路由个人访问令牌的自动撤销
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: application_security_testing
documentation_link: "../../../user/application_security/secret_detection/automatic_response"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/623418
categories: [ Secret Detection ]
---

当密钥检测在公开项目中找到泄露的极狐GitLab 个人访问令牌时，自动响应会将其撤销。在 19.4 之前的极狐GitLab 版本中，撤销仅使用一条检测规则，并且只撤销旧版令牌格式。在极狐GitLab 18.3 及更高版本中创建的令牌使用可路由或带版本的可路由格式。极狐GitLab 检测并报告了这些令牌，但未将其撤销。

在极狐GitLab 19.4 及更高版本中，撤销可识别全部三条极狐GitLab 个人访问令牌检测规则：

- `gitlab_personal_access_token`
- `gitlab_personal_access_token_routable`
- `gitlab_personal_access_token_routable_versioned`

撤销还涵盖来自 [极狐GitLab 源代码密钥扫描](../../../user/application_security/secret_detection/gitlab_secret_scanner/_index.md) 和[基于 Gitleaks 的分析器](../../../user/application_security/secret_detection/pipeline/_index.md)的发现。
您无需更改任何配置。启用了自动响应的实例会立即获得这一更广泛的覆盖范围。
