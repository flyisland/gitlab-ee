---
title: NGINX Ingress 被搭配 Envoy Gateway 的 Gateway API 取代
stage: gitlab_delivery
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ self_managed ]
documentation_link: "https://docs.gitlab.com/charts/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/590800"
categories: [ Cloud Native Installation ]
weight: 70
---

在极狐GitLab 19.0 中，搭配 Envoy Gateway 的 Gateway API 成为 GitLab Helm chart 的默认网络配置，
取代了已于 2026 年 3 月终止支持的 NGINX Ingress。如果无法立即迁移到
Envoy Gateway，您可以显式重新启用内置的 NGINX Ingress，
该功能在计划于极狐GitLab 20.0 中移除之前仍可使用。此更改不影响
Linux 软件包中使用的 NGINX，也不影响使用外部管理的 Ingress 或
Gateway API 控制器的 Helm chart 实例。
