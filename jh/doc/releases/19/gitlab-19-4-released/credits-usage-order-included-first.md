---
title: 包含的 Credits 先于评估 Credits 使用
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: fulfillment
documentation_link: "../../../subscriptions/gitlab_credits/#usage-order"
work_item: https://gitlab.com/gitlab-org/customers-gitlab-com/-/issues/18961
categories: [ Consumables Cost Management ]
level: secondary
---

当订阅包含临时评估 Credits 时，所有用量都优先从该共享池中扣除。每位用户包含的月度 Credits 一直闲置，直到评估池用尽，然后在月末重置。

极狐GitLab 现在会先消耗每位用户包含的 Credits，只有当用户用完其包含的 Credits 后，才会从临时评估 Credits 的共享池中扣除。月度承诺池、一次性费用 Credits 和按需 Credits 仍按与之前相同的顺序消耗，因此您的账单不受影响。
