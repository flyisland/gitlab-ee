---
title: 依赖项和许可证扫描中的 SPDX 许可证表达式支持
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: software_supply_chain_security
documentation_link: ../../../user/compliance/license_scanning_of_cyclonedx_files/
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/16801
categories: [ "Software Composition Analysis" ]
level: primary
---

极狐GitLab 许可证数据现在包含 SPDX 许可证表达式，包括复合声明，例如 `MIT OR Apache-2.0` 或 `GPL-2.0-only WITH Classpath-exception-2.0`。此前，这些表达式在依赖项列表中会报告为 `unknown`，并且对许可证审批策略不可见。

复合许可证现在会连同其运算符（`AND`、`OR`、
`WITH`）一起显示在依赖项列表中，许可证审批策略可以像处理
单许可证依赖项一样允许或拒绝它们。

自极狐GitLab 19.3 起，已支持在 CycloneDX SBOM 中声明的表达式。
此版本将它们添加到极狐GitLab 同步的许可证数据中。离线实例只有在
[下载 v3 许可证数据](../../../topics/offline/quick_start_guide.md#download-v3-license-data)后才会收到这些表达式。
