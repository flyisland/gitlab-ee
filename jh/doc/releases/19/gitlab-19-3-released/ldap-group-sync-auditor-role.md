---
title: LDAP 群组同步现在可以管理审计员角色
tier: [ Premium, Ultimate ]
offering: [ self_managed ]
stage: software_supply_chain_security
co_create: true
documentation_link: "../../../administration/auth/ldap/ldap_synchronization/#assign-an-auditor-role-to-an-ldap-group"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/247042
categories: [ System Access ]
level: secondary
---

现在，您可以在极狐GitLab 私有化部署实例上使用 LDAP 群组同步来自动授予和撤销审计员角色。新增的 `audit_group` 设置可将 LDAP 群组映射到审计员角色，其工作方式与 `admin_group` 对管理员的作用相同，因此审计员的访问权限会跟随目录成员身份变化，而无需手动维护。

感谢 [Sergey Pechenko](https://gitlab.com/tnt4brain) 的贡献！
