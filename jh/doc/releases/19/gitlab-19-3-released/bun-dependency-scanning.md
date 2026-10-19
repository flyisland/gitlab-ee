---
title: "Bun 的依赖扫描支持"
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: application_security_testing
documentation_link: "../../../user/application_security/dependency_scanning/dependency_scanning_sbom/#supported-languages-and-files"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/592701
categories: [ Software Composition Analysis ]
level: secondary
---

在之前的极狐GitLab 版本中，使用 Bun JavaScript 运行时和软件包管理器的项目没有依赖扫描覆盖。

现在，极狐GitLab 依赖扫描通过解析 `bun.lock` 文件（Bun 1.2 中引入的基于文本的 JSONC 格式）来分析 Bun 项目。

由于 Bun 软件包来源于 npm 仓库，极狐GitLab 安全公告数据库已覆盖这些依赖，无需额外配置。使用 Bun 作为 npm、yarn 或 pnpm 替代方案的团队，现在可以在其标准 CI/CD 流水线中扫描项目以发现已知漏洞。符合条件的发现也受依赖扫描自动修复支持。
