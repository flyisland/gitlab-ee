---
title: "使用极狐GitLab Duo 解决评审讨论已正式可用"
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_coding
documentation_link: "../../../user/project/merge_requests/duo_in_merge_requests/#resolve-a-discussion-with-gitlab-duo"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22058
categories: [ DAP Code Review ]
level: secondary
weight: 20
---

在之前的极狐GitLab 版本中，要解决代码评审评论，您必须切换到编辑器、实施修复、提交并推送变更，然后手动关闭讨论串。

现在您可以选择 **使用极狐GitLab Duo 解决**，极狐GitLab Duo 将为您处理评审讨论。

极狐GitLab Duo 会读取评论及周围代码，在源分支上进行所请求的变更，回复讨论并总结变更内容，然后解决该讨论串。
如果变更未能正确解决评论，您或审核人可以重新打开该讨论串。
