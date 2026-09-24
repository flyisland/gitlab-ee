---
title: "使用极狐GitLab Duo 解决审查讨论（测试版）"
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Premium, Ultimate ]
stage: ai_coding
documentation_link: "../../../user/project/merge_requests/duo_in_merge_requests/#resolve-a-discussion-with-gitlab-duo"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22117
categories: [ DAP Code Review ]
---

在之前的极狐GitLab 版本中，要解决代码审查评论，您必须切换到编辑器、实施修复、提交并推送更改，然后手动关闭线程。
您必须为每个未解决的讨论重复此循环，在繁忙的审查过程中，上下文切换的开销会不断累积。

现在，您可以在任何审查讨论中选择 **使用极狐GitLab Duo 解决**。
极狐GitLab Duo 会读取审查评论及其周围的代码，实施审查者描述的更改，并将其提交到您的分支。然后，极狐GitLab Duo 会在讨论中回复，简要说明更改了什么以及原因，并为您解决该线程。您可以查看更改，如果修复未能正确解决评论，还可以重新打开线程。
