---
title: 安全清单中的聚合扫描器覆盖范围
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: security_risk_management
documentation_link: "../../../user/application_security/security_inventory/"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22124
categories: [ Security Asset Inventories ]
---

现在，您可以在一个页面上查看整个群组层级的扫描器覆盖范围。在之前的极狐GitLab 版本中， [安全清单](../../../user/application_security/security_inventory/_index.md)
按子群组显示覆盖范围，但没有整个群组的总计。现在，覆盖范围小组件会聚合群组及其子群组中每个项目的扫描器覆盖范围，并显示每个扫描器已启用、未启用、失败或过期的项目百分比和数量。要专注于某一个扫描器（例如 SAST 或依赖扫描），请使用扫描器下拉列表。然后选择一个状态来筛选项目列表，并为尚未覆盖的项目启用扫描器。

安全清单现在还允许您控制显示哪些列。要显示或隐藏**漏洞**、**工具覆盖范围**和**安全属性**列，请选择**显示**。
