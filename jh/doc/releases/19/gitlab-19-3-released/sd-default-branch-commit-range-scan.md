---
title: 密钥检测在默认分支推送时扫描提交历史
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: application_security_testing
documentation_link: "../../../user/application_security/secret_detection/pipeline"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/607941
categories: [ Secret Detection ]
level: secondary
weight: 30
---

默认分支上的密钥检测现在会在推送时扫描所有提交差异（如果存在先前提交引用），而不是仅扫描最新的目录内容。此变更弥补了一个缺口，即在同一推送中引入并移除的密钥此前无法被检测到。现在，该行为与合并请求和功能分支上的密钥检测方式保持一致。

此扫描能够捕获在代码仓库历史中短暂存在过的密钥，即使这些密钥在流水线完成之前已被移除。安全团队现在可以识别曾经提交过的密钥，而不仅仅是 HEAD 中存在的密钥。

如需更多信息，请参阅 [流水线密钥检测覆盖范围](../../../user/application_security/secret_detection/pipeline/_index.md#coverage)。
