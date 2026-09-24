---
title: 极狐GitLab Runner 19.0
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
documentation_link: "https://docs.gitlab.com/runner"
work_item: "https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/?milestone_title=19.0&state=closed"
categories: [ GitLab Runner Core ]
level: secondary
weight: 150
---

今天，我们还发布了极狐GitLab Runner 19.0！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

**新增功能**

- [Runner 插桩：功能协商、OTLP 导出客户端和首个 `job_execution` span](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39231)
- [为 Runner 配置添加可配置的 prepare 阶段超时时间](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/26583)

**缺陷修复**

- [`FF_SCRIPTS_TO_STEPS` 功能标志实现的全面修复](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39403)
- [下载 S3 缓存时出现 `SignatureDoesNotMatch` 错误](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39402)
- [极狐GitLab Runner 在 AWS 上使用 S3 缓存时出现运行时错误](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39386)
- [极狐GitLab Runner 18.9.0 及更高版本中 `amd64`、`arm64`、`arm` 和 `armhf` 的 RPM S3 下载链接损坏](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39362)
- [Windows 上负退出代码报告不正确](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39292)
- [Kubernetes 执行器服务容器命名文档不正确](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39235)

所有更改的完整列表，请参阅极狐GitLab Runner 的 [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/19-0-stable/CHANGELOG.md)。
