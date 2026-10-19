---
title: 使用极狐GitLab Duo 解决合并冲突（测试版）
stage: ai_coding
level: secondary
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/project/merge_requests/conflicts/#resolve-conflicts-with-gitlab-duo"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/20688"
categories: [ Duo Agent Platform, Code Review Workflow ]
weight: 80
---

在之前的极狐GitLab 版本中，您必须在极狐GitLab UI 或命令行中手动解决合并冲突，即使是简单的情况也是如此。

现在，极狐GitLab Duo 可以自主分析合并冲突、编辑冲突文件、创建提交并推送到源分支。您可以从 **解决冲突** 页面或直接从合并请求小组件触发冲突解决。完成后，极狐GitLab Duo 会发布摘要评论，以便审核人了解更改内容。

极狐GitLab Duo 遵循分支保护规则，不会强制推送到受保护的分支。

此功能处于测试版，受 `mr_ai_resolve_conflicts` 功能标志控制，默认启用。
