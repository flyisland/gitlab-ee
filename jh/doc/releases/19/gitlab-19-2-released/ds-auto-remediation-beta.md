---
title: 依赖扫描自动修复（测试版）
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: software_supply_chain_security
documentation_link: "../../../user/application_security/remediate/dependency_scanning_auto_remediation/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/604799
categories: [ Software Composition Analysis ]
level: primary
weight: 50
---

<!-- Category: Software Composition Analysis -->

极狐GitLab 19.2 引入了依赖扫描自动修复（测试版）。该功能将自动化漏洞修复直接集成到依赖扫描工作流中，具备两项能力：

- 自动依赖版本升级，适用于 JihuLab.com 和极狐GitLab 私有化部署。
- Agentic 破坏性变更解决，适用于 JihuLab.com 和极狐GitLab 私有化部署。

自动依赖版本升级会自动创建合并请求，将有漏洞的依赖项更新到安全版本。启用后，极狐GitLab 会监控项目中的漏洞依赖项，并在无需人工干预的情况下创建修复合并请求。默认情况下，更新目标为补丁版本和次版本。

Agentic 破坏性变更解决扩展了修复流程，以处理复杂的更新。当用于升级依赖版本的合并请求因破坏性变更导致流水线失败时，极狐GitLab Duo 会分析流水线错误、依赖项的变更日志以及您的代码如何使用该依赖项。

极狐GitLab Duo 将修复提交到同一个合并请求，并重新运行流水线，直到流水线通过。当您启用 Agentic 破坏性变更解决时，版本升级将扩展到包含主版本。

这两项能力共同构成了一个完整的修复闭环：极狐GitLab 创建合并请求，当更新复杂时，极狐GitLab Duo 负责解决。

有关设置说明，请参阅[依赖扫描自动修复](../../../user/application_security/remediate/dependency_scanning_auto_remediation.md)。

在[测试版反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/605599)中分享反馈。
