---
title: "使用极狐GitLab Duo 解决合并冲突已正式可用"
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_coding
documentation_link: "../../../user/project/merge_requests/conflicts/#resolve-conflicts-with-gitlab-duo"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/20688
categories: [ DAP Code Review ]
level: secondary
weight: 20
---

在之前的极狐GitLab 版本中，您必须在极狐GitLab UI 中或通过命令行手动解决合并冲突，即使是简单的情况也是如此。

现在，您可以请极狐GitLab Duo 为您解决冲突。

从合并组件或**解决冲突**页面开始冲突解决。
极狐GitLab Duo 会分析冲突、编辑文件并将解决方案提交到源分支，然后在合并请求上发布摘要评论，说明更改内容。
