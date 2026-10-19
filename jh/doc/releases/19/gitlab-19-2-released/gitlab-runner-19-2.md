---
title: GitLab Runner 19.2
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
documentation_link: https://docs.gitlab.com/runner
work_item: https://gitlab.com/gitlab-org/gitlab-runner/-/issues/?milestone_title=19.2&state=closed
categories: [ GitLab Runner Core ]
level: secondary
---

今天，我们还发布了 GitLab Runner 19.2！GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

**新增功能**

- [GitLab Runner 现在在作业完成的 PUT 请求中发送环境键](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39463)
- [GitLab Runner 现在包含一个断路器，当 KAS 作业请求连续失败时，会自动回退到 Rails](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39389)

**缺陷修复**

- [密钥解析失败被错误归类为 `runner_system_failure`](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39573)
- [当您将 GitLab Runner 更新到 19.1.0 时，作业失败并显示 `context deadline exceeded`](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39556)
- [在 Docker 执行器中，作业间歇性失败并显示 `context deadline exceeded`](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39555)
- [启用 `FF_CONCRETE` 时，产物下载失败](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39475)
- [KAS 作业路由器 `GetJob` 延迟直方图在预发布环境中不显示任何数据](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39388)
- [自动 Runner 令牌轮换导致 Docker Autoscaler 执行器清理活跃实例并导致正在运行的作业失败](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39380)

所有变更列表请参见 GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/19-2-stable/CHANGELOG.md)。
