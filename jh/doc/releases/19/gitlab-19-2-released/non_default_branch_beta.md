---
title: 非默认分支跟踪（测试版）
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: security_risk_management
documentation_link: "../../../user/application_security/remediate/dependency_scanning_auto_remediation/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/604799
categories: [ Vulnerability Management ]
level: primary
weight: 50
---

现在，您可以跟踪默认分支之外的其他分支上的漏洞。为获得最佳效果，请以少量长期存在的发布分支为目标，例如特定环境（`project-qa`、`project-prod`）或部署平台（`project-iOS`、`project-android`）的分支。

此测试版包含以下功能：

- 在安全配置页面上添加跟踪分支，最多可添加命名空间中项目数量的两倍。
- 在漏洞报告中按分支筛选。
- 在项目级安全仪表板上按分支筛选。
- 跟踪分支上的所有漏洞类型，包括之前不在范围内的 CVE。
- 当分支合并到默认分支时，保持漏洞状态元数据一致。
- 更新跟踪分支上的漏洞状态。
