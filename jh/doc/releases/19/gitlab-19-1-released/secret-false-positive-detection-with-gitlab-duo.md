---
title: 极狐GitLab Duo 密钥误报检测
stage: software_supply_chain_security
level: primary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../user/application_security/vulnerabilities/secret_false_positive_detection/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/21233"
categories: [ Vulnerability Management ]
weight: 10
---

极狐GitLab Duo Agent Platform 的密钥误报检测已正式发布。

安全团队需要花费大量时间调查被错误标记为实际密钥的密钥检测结果。
这些误报会导致告警疲劳，削弱对扫描结果的信任，并分散对真正安全风险的关注。

当安全扫描运行时，极狐GitLab Duo 会自动分析每个严重级别和高危级别密钥检测漏洞，以判断其是否为误报。
AI 评估结果会显示在漏洞报告中，因此您可以立即获得上下文信息，从而更快、更自信地进行分类决策。

主要功能包括：

- **自动分析**：每次安全扫描后自动运行，无需手动触发。
- **手动触发**：在漏洞详情页面上，可针对单个漏洞触发误报检测，进行按需分析。
- **聚焦高影响结果**：仅分析严重级别和高危级别漏洞，以最大化信噪比提升。
- **上下文 AI 推理**：每项评估都包含对结果为何可能是真实正例的解释，基于代码上下文和漏洞特征。
- **置信度评分**：每项检测都包含置信度评分，帮助团队根据模型的确定性来优先安排审查。
- **无缝工作流集成**：结果直接显示在漏洞报告中，与现有的严重级别、状态和修复信息并列。

欢迎您在[议题 592861](https://gitlab.com/gitlab-org/gitlab/-/issues/592861) 中提供反馈。
