---
title: 自动将 Code Owners 分配为审查者
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Premium, Ultimate ]
stage: create
documentation_link: "../../../user/project/merge_requests/reviews/automatic_reviewer_assignment"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/20708
categories: [ Code Review Workflow ]
level: primary
---

以前，您需要为每个合并请求手动选择审查者，
即使 `CODEOWNERS` 文件已经定义了谁应审查每个文件。

现在，您可以配置项目，将 Code Owners 自动分配为审查者。
极狐GitLab 会分配与更改文件匹配的每个 Code Owner。当合并请求在就绪状态下创建，或草稿被标记为就绪时，就会发生此操作。如果您
已经分配了审查者，极狐GitLab 会跳过自动分配并保留您的选择。

要开启自动审查者分配，请转到**设置** > **合并请求** >
**自动审查者分配**，然后选择**自动将所有代码所有者分配为
审查者**。
