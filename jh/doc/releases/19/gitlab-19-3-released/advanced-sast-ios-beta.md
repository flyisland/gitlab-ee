---
title: 高级 SAST 对 iOS 的测试版支持
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: application_security_testin
documentation_link: "../../../user/application_security/sast/gitlab_advanced_sast"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/22353"
categories: [ SAST ]
level: secondary
---

<!-- Category: SAST -->

极狐GitLab 高级 SAST 现已支持 Objective-C 和 Swift，将为其他语言提供的跨过程污点分析能力引入 iOS 开发。该测试版自极狐GitLab 19.3 起，面向所有极狐GitLab 旗舰版客户开放。

该测试版可检测关键的 OWASP Mobile Top 10 漏洞类别，包括不安全的数据存储、加密实现缺陷、不安全的通信，以及身份验证和授权缺陷。当漏洞始于一种语言并在另一种语言中到达汇聚点时，高级 SAST 会检测完整的污点路径，包括跨越 Swift 和 Objective-C 语言边界的路径。

如需启用，请在您的流水线中设置 `GITLAB_ADVANCED_SAST_ENABLED: 'true'`。如果您的项目包含 Objective-C 或 Swift 文件，`gitlab-advanced-sast-ext` 作业将自动运行。有关完整的设置说明，请参阅
[高级 SAST 文档](../../../user/application_security/sast/gitlab_advanced_sast.md)。

请在 [测试版反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/607091) 中分享您的反馈。
