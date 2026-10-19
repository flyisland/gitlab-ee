---
title: GitLab Runner 19.1
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
documentation_link: https://docs.gitlab.com/runner
work_item: https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/?milestone_title=19.1&state=closed
categories: [ GitLab Runner Core ]
level: secondary
---

今天，我们还发布了极狐GitLab Runner 19.1！GitLab Runner 是一个高度可扩展的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。GitLab Runner 与极狐GitLab CI/CD（极狐GitLab 中包含的开源持续集成服务）协同工作。

**新增功能**

- [为 Runner 配置添加可配置的 `get_sources` 超时](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39426)

**缺陷修复**

- [具体执行 (`FF_CONCRETE`) 在多个行为领域与抽象 Shell 存在差异](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39473)
- [当 `FF_USE_GIT_PROACTIVE_AUTH` 和 `FF_USE_GIT_BUNDLE_URIS` 启用时，Bundle URI 下载因能力不足而失败](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39471)
- [防止因竞态条件通过 UI 取消作业时转储脚本](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39005)
- [修复 Kubernetes 执行器辅助容器内存使用导致 OOM 终止的问题](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/29026)

所有变更的完整列表请参见 GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/19-1-stable/CHANGELOG.md)。
