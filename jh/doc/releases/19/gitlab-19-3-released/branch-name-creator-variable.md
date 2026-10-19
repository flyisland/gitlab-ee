---
title: 分支名称可以包含分支创建者的姓名
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: create
co_create: true
documentation_link: "../../../user/project/repository/branches/#configure-default-pattern-for-branch-names-from-issues"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/247356
categories: [ Source Code Management ]
level: secondary
---

您可以在分支名称模板中使用新的 `%{branch_creator}` 变量来包含创建者，
这样从议题创建的分支可以标识其创建者，而不是回退到通用名称。

感谢 [Radek Antoniuk](https://gitlab.com/rantoniuk) 的贡献！
