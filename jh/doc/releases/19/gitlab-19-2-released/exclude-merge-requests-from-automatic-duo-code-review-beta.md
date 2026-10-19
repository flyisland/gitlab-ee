---
title: "从自动代码审查中排除合并请求（测试版）"
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Free, Premium, Ultimate ]
stage: ai_coding
documentation_link: "../../../user/duo_agent_platform/flows/foundational_flows/code_review/#exclude-merge-requests-from-automatic-reviews"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/21585
categories: [ DAP Code Review ]
---

在之前的极狐GitLab 版本中，当为项目或群组启用自动审查时，极狐GitLab Duo 会审查每一个符合条件的合并请求。
这包括机器人创建的依赖项更新、功能分支和实验性工作，而不仅仅是团队实际希望获得反馈的变更。

现在，您可以使用排除规则将特定的合并请求从自动审查中排除。
为项目或群组定义一个 `.gitlab/duo/mr-review-automated-rules.yaml` 文件，其中包含基于作者、源分支或目标分支的排除规则。
规则支持 glob 模式，例如 `dependabot/*` 或 `*-bot`。

您仍然可以手动请求审查任何被排除的合并请求。

此功能处于测试版，受 `duo_code_review_automated_rules` 功能标志控制，默认启用。
