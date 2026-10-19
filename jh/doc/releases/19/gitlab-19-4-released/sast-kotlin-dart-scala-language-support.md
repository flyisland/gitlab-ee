---
title: 高级 SAST 新增对 Kotlin、Dart 和 Scala 语言的支持
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: application_security_testing
documentation_link: ../../../user/application_security/sast/gitlab_advanced_sast/#supported-languages
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/23383
categories: [ SAST ]
level: primary
---

高级 SAST 现在可以扫描 Kotlin、Dart 和 Scala 代码库，采用与覆盖 Java、Python 及其他受支持语言相同的深度污点分析，全部通过 Software Factory 架构交付，并具备按语言划分的前端和框架感知的规则门控。

- Kotlin 检测针对 Android API，覆盖 SQL 注入、不安全的 WebView 使用、操作系统命令注入、硬编码凭据和弱加密。
- Dart 检测包含 Flutter 和 Dio 框架检测器，覆盖 SSRF、路径遍历、命令注入和明文 HTTP。
- Scala 检测覆盖 Play、Slick 和 Akka 框架，针对 SQL 注入、SSRF、开放重定向、路径遍历、命令注入和 XSS。

这三项新增功能均使用刻意构建的含漏洞真实代码仓库进行验证，发现的漏洞以从源到汇的代码流形式报告。
