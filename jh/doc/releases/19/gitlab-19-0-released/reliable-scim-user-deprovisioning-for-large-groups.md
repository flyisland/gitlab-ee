---
title: 大型群组的可靠 SCIM 用户取消预配
stage: tenant_scale
level: secondary
tier: [ Premium, Ultimate ]
offering: [ gitlab_com ]
documentation_link: "../../../development/internal_api/#group-scim-api"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/521324"
categories: [ User Management ]
weight: 90
---

对于通过 SCIM 管理大量用户的大型组织，取消预配群组成员可能会超时并返回 `500` 错误。SCIM `DELETE` 和 `PATCH` 请求现在会立即返回成功响应。成员移除以异步方式处理，因此身份提供商和 SCIM 客户端会收到一致的成功响应。
