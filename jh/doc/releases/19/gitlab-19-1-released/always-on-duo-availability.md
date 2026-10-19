---
title: 极狐GitLab Duo 始终可用模式
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
tier: [ Premium, Ultimate ]
stage: software_supply_chain_security
documentation_link: "../../../user/gitlab_duo/turn_on_off/#lock-gitlab-duo-on-for-all-users"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22382
categories: [ AI Abstraction Layer ]
level: primary
---

管理员现在可以将极狐GitLab Duo 设置为对整个实例或顶级群组中的所有项目始终可用。当极狐GitLab Duo 设置为始终可用时，
群组、子群组和项目所有者无法关闭极狐GitLab Duo，从而为企业提供集中式 AI 治理，以满足合规和
监管环境的要求。

此新设置与现有的[始终关闭](../../../user/gitlab_duo/turn_on_off.md)设置对称，弥补了极狐GitLab Duo 可以
被锁定关闭但无法锁定开启的空白。此新设置对于拥有自主部门或子公司、需要
确保整个业务中一致 AI 工具的组织尤其有价值。

要将极狐GitLab Duo 设置为始终可用，请转到实例或顶级群组的极狐GitLab Duo 设置，并将 **极狐GitLab Duo 可用性** 设置为 **始终可用**。
