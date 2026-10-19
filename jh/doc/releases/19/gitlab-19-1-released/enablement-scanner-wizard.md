---
title: 使用扫描器启用向导缩小覆盖差距
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: security_risk_management
documentation_link: "../../../user/application_security/configuration/scanner_enablement_wizard"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/21626
categories: [ Security Asset Inventories ]
level: secondary
weight: 50
---

现在，您可以使用扫描器启用向导来缩小项目中扫描器的覆盖差距，无需手动识别哪些项目需要关注。

安全配置文件定义了哪些扫描器运行以及如何运行。安全清单显示项目中扫描器的覆盖情况，并允许您将配置文件批量应用到所选项目或子群组。该向导在此基础上增加了目标驱动的工作流：您设定目标，它会找到缺少覆盖的项目，并仅缩小这些差距。
