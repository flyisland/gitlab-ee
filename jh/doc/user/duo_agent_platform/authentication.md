---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 极狐GitLab Duo Agent Platform 认证
---

极狐GitLab Duo Agent Platform 在请求到达模型提供商之前使用多令牌认证链。

下表列出了每种令牌的类型和存活时间 (TTL)。

| 令牌 | 发行者 | TTL | 刷新行为 |
|--------|--------|--------|---------------------------------------------------------|
| CustomersDot 服务访问令牌 | `customers.jihulab.com` | 大约三天 | 当剩余时间少于 2 天时，每小时通过定时任务刷新。 |
| 极狐GitLab Duo Workflow Service 内部 JWT | 极狐GitLab Duo Workflow Service | 1 小时 | 在每次工作流程中通过 `GenerateToken` RPC。 |
| GLGO 交换 JWT | AI Gateway | 1 小时 | 每次请求。 |