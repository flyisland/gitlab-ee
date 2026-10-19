---
title: 用于合并请求评审和部署审批的 Webhooks
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: create
co_create: true
documentation_link: "../../../user/project/integrations/webhook_events/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246562
categories: [ Code Review Workflow, Deployment Management ]
level: secondary
---

您可以使用 Webhooks 来处理合并请求评审和部署审批。当您以 **请求更改** 或 **已评审** 状态提交合并请求评审时，极狐GitLab 会触发一个携带 `changes.reviewers` 条目的 `merge_request` Webhook，以便外部工具能够对评审活动做出响应，而不仅仅是审批。

部署 Webhook 新增了 `blocked`、`approved` 和 `rejected` 状态，并带有顶层 `approver` 和 `approval` 字段，让您可以跟踪部署的完整审批生命周期。`blocked` 状态在所有层级均可用。`approved` 和 `rejected` 状态仅在专业版和旗舰版中可用，并且 `approver.email` 会被隐去。

感谢 [Messias Tayllan](https://gitlab.com/tayllanr)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/246562)）和 [Anvita Gupta](https://gitlab.com/arcesium-guptaanv)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/239337)）的这些贡献！
