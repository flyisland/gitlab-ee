---
title: Gradle SBOM 扫描的依赖解析
stage: software_supply_chain_security
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../user/application_security/dependency_scanning/dependency_scanning_sbom/#dependency-resolution"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/590734"
categories: [ Software Composition Analysis ]
weight: 30
---

使用 SBOM 的极狐GitLab 依赖扫描现在会自动为 Gradle 项目生成依赖图（`gradle.graph.txt`）。此前，Gradle 依赖扫描要求您在构建过程中手动生成依赖图。现在，当图文件不可用时，分析器会自动生成一个，省去了使用 Gradle 的 Java 和 Kotlin 项目的这一手动步骤。
