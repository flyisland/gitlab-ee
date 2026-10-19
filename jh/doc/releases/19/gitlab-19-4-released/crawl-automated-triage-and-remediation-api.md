---
title: 自动排查与修复配置文件（GraphQL API）
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: security_risk_management
documentation_link: "../../../user/application_security/configuration/security_configuration_profiles/#automated-triage-and-remediation-profile"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/23191
categories: [ Vulnerability Management ]
weight: 50
---

在之前的极狐GitLab 版本中，您需要为每个项目单独开启 SAST 误报检测、极狐GitLab Duo 漏洞修复、密钥检测误报检测和依赖扫描自动修复。现在，您可以将自动排查与修复配置文件应用到群组或项目，通过一次操作设置严重级别和运行模式。您可以从预设开始，也可以自行配置每个任务流：

- 保守：按需运行，高严重级别。
- 标准：自动运行，中等严重级别及以上。
- 主动：自动运行，所有严重级别。

配置文件仅可通过 GraphQL API 使用，并且需要为顶级群组开启极狐GitLab Duo Agent Platform 及内置任务流。大多数任务流会消耗极狐GitLab Credits。
