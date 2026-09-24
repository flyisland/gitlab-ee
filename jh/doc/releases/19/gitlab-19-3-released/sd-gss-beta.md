---
title: 极狐GitLab 源代码密钥扫描（测试版）
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed ]
stage: application_security_testing
documentation_link: "../../../user/application_security/secret_detection/gitlab_secret_scanner/"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/21902
categories: [ Secret Detection ]
level: secondary
weight: 20
---

极狐GitLab 源代码密钥扫描现已进入测试阶段，由全新的极狐GitLab 自研扫描引擎提供支持。与仅检测已知密钥模式的默认分析器不同，该分析器还能检测标准规则集覆盖范围之外的口令和其他非结构化密钥。它还使用多种启发式技术来减少误报。新分析器在同一个 `secret_detection` 作业中取代默认分析器，匹配现有漏洞发现结果，而不是创建重复项。

要开始使用，请参阅
[启用分析器](../../../user/application_security/secret_detection/gitlab_secret_scanner/_index.md#turn-on-the-analyzer)。
在测试阶段，仅报告高置信度的发现结果。

我们欢迎您在 [议题 609578](https://gitlab.com/gitlab-org/gitlab/-/work_items/609578) 中提供任何反馈。
