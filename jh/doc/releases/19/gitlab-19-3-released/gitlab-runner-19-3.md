---
title: 极狐GitLab Runner 19.3
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
documentation_link: https://docs.gitlab.com/runner
work_item: https://gitlab.com/gitlab-org/gitlab-runner/-/issues/?milestone_title=19.3&state=closed
categories: [ GitLab Runner Core ]
level: secondary
---

我们今天还发布了极狐GitLab Runner 19.3！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

**新增功能**

- [记录 Job Router 版本兼容性矩阵](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39408)
- [验证 Workhorse 是否位于 Job Router 的 KAS 到 Rails 请求路径中](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39383)

**缺陷修复**

- [当 `IMAGE_FILTER_FLAGS` 为空时，`clear-docker-cache` 会清理所有未使用的镜像](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39621)
- [具体模式调度会跳过未设置 `When` 的步骤](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39539)
- [`PrintPodWarningEvents` 无法正常工作](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/38982)
- [当 `.git` 文件夹损坏时，自定义执行器会失败](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/27540)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/19-3-stable/CHANGELOG.md)。
