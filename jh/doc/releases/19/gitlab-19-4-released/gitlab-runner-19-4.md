---
title: 极狐GitLab Runner 19.4
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
documentation_link: https://gitlab.cn/docs/runner/
work_item: https://gitlab.com/gitlab-org/gitlab-runner/-/issues/?milestone_title=19.4&state=closed
categories: [ GitLab Runner Core ]
level: secondary
---

今天我们还发布了极狐GitLab Runner 19.4！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

**新增功能**

- [Fastzip 现在是缓存和产物的默认归档工具](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39681)
- [为 `gitlab_runner_job_router_get_job_duration_seconds` 添加 `runner` 和 `system_id` 标签](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39576)
- [为 Job Router 添加专用的 SLI、SLO 和告警集成](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39533)
- [为 Kubernetes executor 添加暂停和恢复支持](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39464)
- [在作业完成时的 `PUT` 请求中发送环境键](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39463)
- [可选择在作业日志中隐藏缓存上传和下载 URL](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39405)
- [为 Docker executor 配置添加 `services_cap_add` 和 `services_cap_drop` 选项](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/4748)

**缺陷修复**

- [Job router 的 `409` 响应会导致 runner manager 停用一小时](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39726)
- [logrotate 用量写入器修改共享的 runner 标签，可能导致 runner 发生 panic](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39723)
- [Windows 服务控制台恢复失败会强制终止正在正常停止的作业](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39720)
- [直方图中 `job_id` 和 `runner_controller_id` 属性的基数无上限](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39719)
- [对于有 TOML 标签但没有 JSON 标签的可为空字段，配置校验会警告 `got null`](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39688)
- [Git 版本检查中的 SIGPIPE 导致 `get_sources` 间歇性静默失败](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39680)
- [启用 `FF_USE_ADAPTIVE_REQUEST_CONCURRENCY` 时出现虚假的 `Request bottleneck` 警告](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39575)
- [AWS、GCP、Azure 和 极狐GitLab 密钥管理器的密钥解析失败现在会按原因分类](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39574)
- [当 runner 短 ID 以 `-` 开头时，Kubernetes 暂停 Pod 无法启动](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39456)
- [以 Windows 服务方式运行时，取消作业总是会导致进程被终止](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39297)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/19-4-stable/CHANGELOG.md)。
