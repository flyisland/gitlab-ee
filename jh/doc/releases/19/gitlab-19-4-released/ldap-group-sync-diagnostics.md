---
title: 诊断 LDAP 群组同步失败
tier: [ Premium, Ultimate ]
offering: [ self_managed ]
stage: software_supply_chain_security
co_create: true
documentation_link: "../../../administration/auth/ldap/#ldap-sync-configuration-settings"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/250622
categories: [ System Access ]
level: secondary
weight: 10
---

当 LDAP 群组同步失败时，现在您可以看到失败原因。失败会记录到相应群组上，导致失败的成员会被列出（最多五个），并且群组成员页面上会显示危险警告，因此因电子邮件域名限制而被阻止的同步可以直接从 UI 进行诊断。新增的 `group_filter` 设置让您可以缩小哪些 LDAP 条目算作群组的范围。审计日志还区分了此前共用同一条目的原因：LDAP 群组链接的创建和移除，以及被 LDAP 同步阻止的用户，现在各自拥有独立的审计事件类型。

感谢 [Sergey Pechenko](https://gitlab.com/tnt4brain)的这些贡献
（[合并请求 1](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/250622) [合并请求 2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/253816) [合并请求 3](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/252957) [合并请求 4](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/247146)）！
