---
title: 极狐GitLab 支持在引入的 CycloneDX SBOM 中使用 SPDX 许可证表达式
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: software_supply_chain_security
documentation_link: "../../../user/compliance/license_scanning_of_cyclonedx_files/#license-expressions"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/606225
categories: [ Software Composition Analysis ]
level: secondary
weight: 50
---

<!-- Category: Software Composition Analysis -->

极狐GitLab 19.3 支持在您引入极狐GitLab 的 CycloneDX 软件物料清单（SBOM）文件中使用软件包数据交换（SPDX）许可证表达式。
此前，使用 SPDX 表达式语法定义的复合或自定义许可证组件
会显示为未知。

现在，极狐GitLab 会读取并存储 CycloneDX
许可证条目中的 `expression` 字段，
包括类似 `MIT AND Apache-2.0` 的复杂表达式，以及使用
`LicenseRef-[NAME]` 语法的自定义许可证引用。

SPDX 表达式支持对于自行生成 SBOM 且包含复杂或自定义许可证表达式的组织尤其有用，可让您准确了解许可证暴露情况，而无需依赖极狐GitLab 生成的扫描。

有关更多信息，请参阅[引入您自己的 CycloneDX SBOM](../../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md)。
