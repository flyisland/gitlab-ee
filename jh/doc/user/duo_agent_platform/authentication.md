---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 极狐GitLab Duo Agent Platform 身份验证
---

极狐GitLab Duo Agent Platform 在请求到达模型提供商之前，使用多令牌身份验证链。

下表列出了每种令牌的类型和生存时间（TTL）。

| 令牌  | 签发方 | TTL    | 刷新行为                                        |
|--------|--------|--------|---------------------------------------------------------|
| CustomersDot 服务访问令牌 | `customers.jihulab.com`    | 约三天 | 在每小时执行的 cron 中，当剩余时间少于 2 天时刷新。 |
| 极狐GitLab Duo Workflow Service 内部 JWT           | 极狐GitLab Duo Workflow Service | 1 小时 | 在每个工作流中通过 `GenerateToken` RPC 刷新。 |
| GLGO 交换 JWT                 | AI 网关                | 1 小时                              |  在每个请求中刷新。 |
