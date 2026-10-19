---
title: 极狐GitLab Credits 用量上限已正式发布
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: fulfillment
documentation_link: "../../../subscriptions/gitlab_credits_dashboard/#usage-caps"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/607551
categories: [ Consumables Cost Management ]
level: secondary
---

按需使用可能会产生您未计划到的超额费用。极狐GitLab Credits 的用量上限已正式发布：在 Customers Portal 中设置订阅级别的按需 Credits 上限，并通过 GraphQL API 设置默认的每用户上限或每用户覆盖值。当消耗达到上限时，消耗极狐GitLab Credits 的功能（如极狐GitLab Duo Agent Platform）将暂停使用，直到下一个计费周期开始或管理员调整上限。用量上限在极狐GitLab 18.11 中引入，受 `budget_caps_graphql_api` 功能标志控制。在极狐GitLab 19.3 中，该功能标志已移除。
