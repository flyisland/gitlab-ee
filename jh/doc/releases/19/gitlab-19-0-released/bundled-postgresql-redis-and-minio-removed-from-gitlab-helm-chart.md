---
title: 从 GitLab Helm chart 中移除内置的 PostgreSQL、Redis 和 MinIO
stage: gitlab_delivery
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ self_managed ]
documentation_link: "https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/590797"
categories: [ Cloud Native Installation ]
weight: 80
---

在极狐GitLab 19.0 中，内置的 Bitnami PostgreSQL、Bitnami Redis 和 MinIO chart 已从 GitLab Helm chart 和 GitLab Operator 中移除，且没有替代方案。这些组件仅用于概念验证和测试环境，不建议在生产环境中使用。如果您运行的实例使用了这些内置服务中的任何一个，请在升级到极狐GitLab 19.0 之前，按照[迁移指南](https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/)配置外部服务。
