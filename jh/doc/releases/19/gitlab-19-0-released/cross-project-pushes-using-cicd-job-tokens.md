---
title: 使用 CI/CD 作业令牌进行跨项目推送
stage: verify
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../ci/jobs/ci_job_token/#allow-cross-project-git-push-requests-from-allowlisted-projects"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/issues/479907"
categories: [ Continuous Integration (CI) ]
weight: 120
---

在之前的极狐GitLab 版本中，您只能使用 CI/CD 作业令牌 (`CI_JOB_TOKEN`) 推送到运行流水线的同一代码仓库。跨项目推送需要个人访问令牌或部署令牌。

现在，您可以在以下情况下使用作业令牌推送到另一个项目：

1. 目标项目选择启用。
1. 启动流水线的用户在目标项目中至少具有开发者角色。

此功能受 `allow_push_to_allowlisted_projects` 功能标志控制，在极狐GitLab 19.0 中默认禁用。请让您的管理员启用该功能。
