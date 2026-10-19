---
title: 改进功能分支流水线的密钥检测覆盖范围
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: application_security_testing
documentation_link: "../../../user/application_security/secret_detection/pipeline/#coverage"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/588910
categories: [ Secret Detection ]
level: primary
---

在早于 19.1 的极狐GitLab 版本中，您无法信任功能分支流水线能
检测出分支中的所有密钥。新分支仅扫描最新提交。
已有分支仅扫描最近一次推送。在较早提交中泄露的凭据可能未被发现，从而在标记前进入共享分支或生产环境。

现在，您可以在修复成本最低的阶段捕获这些密钥。在极狐GitLab 19.1 中，密钥
检测会扫描从分支与默认分支的分叉点到最新提交之间的每一次提交。这意味着更少的密钥会遗漏到后续阶段，减少事后轮换已泄露凭据的时间，并在各分支间实现一致、可预测的覆盖范围。
