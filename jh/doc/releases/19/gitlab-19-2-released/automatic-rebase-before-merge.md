---
title: 合并前自动变基
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Free, Premium, Ultimate ]
stage: ai_coding
documentation_link: "../../../user/project/merge_requests/methods/#automatic-rebase-before-merge"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/16803
categories: [ Code Review Workflow ]
---

在之前的极狐GitLab 版本中，如果您的项目使用半线性或快进合并方式，当源分支落后于目标分支时，您需要额外完成一个步骤才能合并。
要合并，您必须选择 **变基**，等待变基完成，然后返回合并请求选择 **合并**。
这种两步交接的方式给每次合并都增加了额外操作。

现在，您可以在项目的合并请求设置中选择 **启用合并前自动变基**。
启用该设置后，极狐GitLab 会在合并时将源分支变基到目标分支，您只需一次操作即可完成合并。
如果需要保留单个提交上的 GPG 签名，您可以保持该设置关闭。
