---
title: 密钥推送保护故障开放场景的审计事件
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: application_security_testing
documentation_link: "../../../user/application_security/secret_detection/secret_push_protection"
work_item: https://gitlab.com/gitlab-org/gitlab/-/issues/604787
categories: [ Secret Detection ]
---

在早期版本的极狐GitLab 中，当密钥推送保护无法完成扫描并允许未扫描的推送通过时，
极狐GitLab 不会提供客户可见的审计事件记录。安全和合规团队无法监控密钥推送保护何时静默允许推送进入其代码仓库。

极狐GitLab 19.3 及更高版本会为所有故障开放场景生成[审计事件](../../../user/compliance/audit_event_types.md#secret-detection)，
包括规则集错误、超出文件和行数限制、扫描超时以及意外错误。团队现在可以将这些事件转发到外部监控和告警工具，以保持对其安全态势的可见性。
