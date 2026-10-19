---
title: 通过 API 实现更多筛选和管理方式
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: foundations
co_create: true
documentation_link: "../../../api/rest/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/244359
categories: [ System Access ]
level: secondary
---

REST 和 GraphQL API 现在提供六项改进：

- 群组查询支持 `visibilityLevel` 和 `includeSubgroups` 参数，并可通过 `aimed_for_deletion` 筛选计划删除的群组。
- 合并请求 REST API 支持 `merged_after` 和 `merged_before` 参数。
- 成就奖励消息在授予后可以编辑，而不仅仅是在授予时设置。
- 管理员可以通过管理员令牌 API 重置 SCIM 令牌。
- `CI_JOB_TOKEN` 现在可以获取代码仓库归档，这解决了因源回退弃用而中断的私有 Composer 软件包下载问题。

感谢以下用户做出的贡献！

- [Colin Jacob Boby](https://gitlab.com/jcb960) ([合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/249258))
- [nagraj raikar](https://gitlab.com/nraj0408) ([合并请求 1](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/244359) [合并请求 2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245378))
- [Niklas van Schrick](https://gitlab.com/Taucher2003) ([合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246614))
- [Nicholas Wittstruck](https://gitlab.com/nwittstruck) ([合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/243804))
- [Alessandro Lai](https://gitlab.com/Alessandro.Lai) ([合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246159))
