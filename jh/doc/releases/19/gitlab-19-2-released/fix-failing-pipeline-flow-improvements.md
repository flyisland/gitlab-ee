---
title: 修复 CI/CD 流水线 Flow 提供针对性修复
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
documentation_link: "../../../user/duo_agent_platform/flows/foundational_flows/fix_pipeline"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/21837
categories: [ Continuous Integration (CI) ]
level: secondary
weight: 10
---

极狐GitLab Duo 的修复 CI/CD 流水线 Flow 现在为您带来两项核心改进：

- 当相关文件已存在于您的合并请求差异中时，您可以直接在该合并请求上获得作为代码建议的修复。
- 该 Flow 在操作前会对流水线失败进行分类，因此您能获得更具针对性的诊断。

该 Flow 还会分析整个流水线层级结构中的子级流水线失败，
允许您通过 `AGENTS.md` 文件为其项目自定义行为，
并默认折叠 AI 推理内容，以保持您的合并请求评论整洁。

请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/601991)中分享您的反馈。
