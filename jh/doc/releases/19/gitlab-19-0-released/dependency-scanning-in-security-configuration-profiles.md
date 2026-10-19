---
title: 安全配置文件中的依赖扫描
stage: security_risk_management
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../user/application_security/configuration/security_configuration_profiles/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/19952"
categories: [ Security Testing Configuration ]
weight: 20
---

极狐GitLab 18.11 为 SAST 和密钥检测引入了安全配置文件。
现在，依赖扫描也可通过**依赖扫描 - 默认**配置文件使用。
该配置文件为您提供统一控制面，可在所有项目中应用标准化的 SCA 覆盖范围，而无需编辑任何 CI/CD 配置文件。

该配置文件会激活两个扫描触发器：

- **合并请求流水线**：每次有新提交推送到存在未关闭合并请求的分支时，自动运行依赖扫描。结果仅包含该合并请求引入的新漏洞。
- **分支流水线（仅默认分支）**：当更改合并或推送到默认分支时自动运行，提供默认分支依赖状况的完整视图。
