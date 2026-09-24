---
title: 实例级自定义审查指令
offering: [ self_managed, gitlab_dedicated ]
tier: [ Premium, Ultimate ]
stage: ai_coding
documentation_link: "../../../user/duo_agent_platform/customize/review_instructions#configure-custom-review-instructions-for-an-instance"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22616
categories: [ DAP Code Review ]
---

在之前的极狐GitLab 版本中，您只能在项目或群组级别为极狐GitLab Duo 定义自定义审查指令。希望在整个实例中应用一致审查指导（例如安全规则或内部编码标准）的管理员，必须在每个项目中重复相同的指令。

现在，您可以为整个实例配置自定义审查指令。

作为管理员，在您的实例中选择一个项目作为模板。当极狐GitLab Duo 执行代码审查时，它会将实例级 `.gitlab/duo/mr-review-instructions.yaml` 文件中的指令与任何群组级和项目级指令合并。这为组织提供了实例级审查标准的单一事实来源。

代码审查 Flow 和极狐GitLab Duo 代码审查均支持实例级自定义指令。
