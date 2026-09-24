---
title: 安全管理角色正式发布
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Free, Premium, Ultimate ]
stage: security_risk_management
documentation_link: "../../../user/permissions/"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/16399
categories: [ Permissions ]
level: secondary
weight: 50
---

安全管理角色已正式发布，提供对安全功能的全面访问权限，包括漏洞管理、安全仪表盘、策略配置和合规工具。安全团队不再需要开发者角色或维护者角色即可访问安全功能，从而在保持职责分离的同时消除过度授权问题。

拥有安全管理角色的用户具有以下访问权限：

- 漏洞管理：跨群组和项目查看、分类和管理漏洞。
- 安全策略：在群组级别查看和管理安全策略，并在项目级别贡献策略 YAML。
- 安全清单：查看群组中所有项目的扫描器覆盖范围。
- 安全配置文件：查看群组和项目的安全配置文件。
- 合规工具：在群组和项目级别查看和管理审计事件、合规中心、合规框架、合规状态报告和依赖项列表。
- 密钥推送保护：为群组和项目启用密钥推送保护。
- 按需 DAST：为项目创建和运行按需 DAST 扫描。
- Runner 可见性：查看群组和项目的 Runner。

要开始使用，请前往一个群组，选择 **管理 > 成员** 以邀请成员并为其分配安全管理角色。
