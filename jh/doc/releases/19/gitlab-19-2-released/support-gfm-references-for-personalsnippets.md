---
title: 个人代码片段中的极狐GitLab 风格 Markdown 引用
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: plan
documentation_link: "../../../user/markdown/#gitlab-specific-references"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/4185
categories: [ Markdown ]
level: secondary
weight: 50
ignore_in_report: true
---

<!-- categories: Markdown -->

现在，您可以通过两种方式在个人代码片段中使用极狐GitLab 风格 Markdown（GFM）引用：

- 极狐GitLab 会在个人代码片段描述和评论中处理 GFM 引用，就像在项目代码片段和极狐GitLab 其他区域中一样。
- 您可以在任何支持 GFM 的地方（例如评论、议题或合并请求描述）引用个人代码片段，使用已适用于项目代码片段的 `$<id>` 语法。

由于代码片段 ID 在个人和项目代码片段之间是唯一的，因此每个 ID 都解析为单个代码片段。
