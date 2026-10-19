---
title: 在极狐GitLab 中使用第三方扫描器结果
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: security_risk_management
documentation_link: "../../../user/application_security/detect/sarif"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/595060
categories: [ Security Testing Integrations ]
level: secondary
weight: 50
---

现在，您可以将任何符合 SARIF 2.1.0 标准的扫描器产生的安全发现与极狐GitLab 的漏洞管理功能结合使用。

定义一个 CI/CD 作业，运行您的扫描器并输出 SARIF 产物。极狐GitLab 会解析、验证并将这些发现导入到您的安全工作流中。结果会与极狐GitLab 原生扫描器的输出一同显示在流水线安全选项卡、漏洞报告、安全仪表板、合并请求安全小部件以及安全策略中。此功能为安全团队提供了统一的漏洞综合视图，无论这些漏洞由哪种工具产生。

极狐GitLab 会根据每个发现的标识符为其分配报告类型，将结果映射到诸如 `SAST`、`dependency scanning` 和 `secret detection` 等类别。支持的扫描器包括用于 SAST 的 Semgrep 和 Checkmarx，用于依赖项和容器扫描的 Trivy 和 Snyk，以及用于密钥检测的 Gitleaks。
