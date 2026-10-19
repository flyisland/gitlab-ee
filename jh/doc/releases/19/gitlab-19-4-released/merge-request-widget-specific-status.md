---
title: 合并请求小部件现在显示更具体的信息
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_coding
co_create: true
documentation_link: "../../../user/project/merge_requests/widgets/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/251657
categories: [ Code Review Workflow ]
level: secondary
weight: 20
---

当极狐GitLab 检查合并请求时，小部件现在会告知您。**必须解决合并冲突**
会变为 **正在检查合并冲突**，直到检查完成。当变基被拒绝时，您会
看到具体原因，例如 **源分支受到强制推送保护**，而不是
笼统的重试提示。您可以根据合并请求的当前状态采取操作。

在滚动合并请求时保持可见的粘性标题栏，现在在您将其标记为草稿或就绪时也会立即更新，而无需刷新页面。

感谢以下用户做出的这些贡献！

- [Amartya Mishra](https://gitlab.com/Gamezordd)（[合并请求 1](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/253806) [合并请求 2](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/251657)）
- [Gerardo Navarro](https://gitlab.com/gerardo-navarro)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/252050)）
- [Mahaveer A](https://gitlab.com/Mahaveer1013)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/251290)）
