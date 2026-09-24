---
title: 基础 Flow 就绪检查
offering: [ self_managed, gitlab_dedicated_for_government ]
tier: [ Premium, Ultimate ]
stage: ai-powered
documentation_link: "../../../administration/gitlab_duo/configure/#run-a-health-check-for-gitlab-duo"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/599536
categories: [ Duo Agent Platform ]
level: secondary
---

极狐GitLab Duo 健康检查现在包含基础 Flow 就绪检查，用于验证：

- 实例级 Flow 执行设置已启用。
- 实例级基础 Flow 设置已启用。
- 至少有一个已注册并连接的活跃实例 Runner，且带有 `gitlab--duo` 标签，并使用 Docker 兼容执行器。
