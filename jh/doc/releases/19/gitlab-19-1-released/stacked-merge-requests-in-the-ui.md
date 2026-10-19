---
title: 界面中的堆叠合并请求
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Free, Premium, Ultimate ]
stage: create
documentation_link: "../../../user/project/merge_requests/reviews/stacked_merge_requests"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22211
categories: [ Code Review Workflow ]
level: secondary
---

以前，当您将一个大型变更拆分为多个相互依赖的较小合并请求时，界面不会提示它们之间存在关联。作者和审阅者必须手动跟踪顺序。

极狐GitLab 现在会自动检测堆叠的合并请求，并将其显示在合并请求
标头中。当一个合并请求以另一个开放合并请求的源分支为目标，或另一个开放合并请求以其源分支为目标时，该合并请求会加入堆叠。源分支旁边的堆叠控件会显示当前位置（例如 **1/2**），并允许您跳转到堆叠中的任何其他合并请求。

要从命令行创建堆叠合并请求，请在极狐GitLab CLI 中使用堆叠差异。
