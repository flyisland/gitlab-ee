---
title: 极狐GitLab Duo 的群组级自定义审查指令
stage: ai-powered
level: primary
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/gitlab_duo/customize_duo/review_instructions/#configure-custom-review-instructions-for-a-group"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/21504"
categories: [ Duo Code Review ]
add_ons: [ GitLab Duo Enterprise ]
weight: 10
---

在之前的极狐GitLab 版本中，您只能在项目级别为极狐GitLab Duo 定义自定义审查指令。在同一群组中跨多个项目工作的团队，必须在每个项目中重复相同的指令。

现在，您可以为整个群组及其子群组配置共享的自定义审查指令。

选择群组中的一个项目作为模板。当极狐GitLab Duo 执行代码评审时，它会将群组级 `.gitlab/duo/mr-review-instructions.yaml` 文件与单个项目中定义的任何指令结合使用。

代码评审任务流和极狐GitLab Duo 代码评审均支持群组级自定义指令。
