---
title: Redis 6 支持已移除
stage: gitlab_delivery
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ self_managed ]
documentation_link: "../../../install/requirements/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/585839"
categories: [ Omnibus Package ]
weight: 30
---

极狐GitLab 19.0 已移除对 Redis 6 的支持。如果您使用外部 Redis 6 部署，请在升级前迁移到 Redis 7.2 或 Valkey 7.2。Linux 软件包内置的 Redis 自极狐GitLab 16.2 起已使用 Redis 7，不受影响。
