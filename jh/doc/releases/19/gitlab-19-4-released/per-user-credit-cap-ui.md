---
title: 无需 GraphQL API 即可设置 Credits 用量上限
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed ]
stage: fulfillment
documentation_link: "../../../subscriptions/gitlab_credits_dashboard/#manage-credit-caps"
work_item: https://gitlab.com/gitlab-org/gitlab/-/issues/628559
categories: [ Consumables Cost Management ]
level: secondary
---

Credits 用量上限限制每个用户可消耗的极狐GitLab Credits 数量，但在此之前，您只能通过 GraphQL API 进行配置。若要为少数几个用户设置不同的上限，就需要手动编写变更。

新增的 **Credits 用量上限**页面让您可以设置默认应用于每个用户的统一上限，并通过可搜索的选择器为单个用户添加按用户覆盖。该页面位于**极狐GitLab Credits**中，供 JihuLab.com 上的群组所有者以及极狐GitLab 私有化部署上的管理员使用。如果您更倾向于通过脚本更改上限，
GraphQL 变更仍然可用。
