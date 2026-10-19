---
title: 基于 SBOM 的依赖扫描已正式发布
stage: software_supply_chain_security
level: primary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/application_security/dependency_scanning/dependency_scanning_sbom/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/20456"
categories: [ Software Composition Analysis ]
weight: 50
---

基于 SBOM 的极狐GitLab 依赖扫描器已正式发布。Maven、Gradle 和 Python
项目现在可以完整查看其整个依赖树中的漏洞，包括通过传递引入的易受攻击的软件包，而不仅仅是直接声明的软件包。

该分析器现在包含对 Maven、Gradle 和 Python 项目的自动依赖解析。当不存在锁文件或已解析的依赖关系图时，分析器会在扫描前自动调用工具来解析完整的传递依赖关系图。依赖解析默认启用，除了包含 v2 依赖扫描模板外，几乎不需要额外配置。

对于无法进行依赖解析的项目，分析器会回退到清单扫描。它会解析 `pom.xml`、`requirements.txt`、`build.gradle` 和
`build.gradle.kts` 以识别直接依赖项。清单扫描确保团队
始终能获得漏洞覆盖的起点，即使项目没有锁文件或构建文件。

清单扫描默认启用，仅返回直接依赖项。要获得完整的传递依赖覆盖，请启用依赖解析或手动提供依赖锁文件或依赖关系图导出。
