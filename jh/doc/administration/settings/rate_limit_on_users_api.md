---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户 API 的速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 用户 API 的速率限制在极狐GitLab 17.1 中引入，带有一个名为 `rate_limiting_user_endpoints` 的功能标志。默认禁用。
- 在极狐GitLab 17.10 中新增了可自定义的速率限制。
- 在极狐GitLab 18.1 中正式发布（GA）。功能标志 `rate_limiting_user_endpoints` 已移除。

{{< /history >}}

> [!note]
> 升级到极狐GitLab 18.0 或更高版本时，此 API 的可配置速率限制将被设置为 `0`。管理员可根据需要调整速率限制。有关受影响速率限制的信息，请参阅[项目、群组和用户 API 的速率限制公告](https://gitlab.cn/blog/rate-limitations-announced-for-projects-groups-and-users-apis/#rate-limitation-details)。

您可以配置对以下 [用户 API](../../api/users.md) 请求的每个 IP 地址和每个用户每分钟的速率限制。

| 限制                                                           | 默认值 |
|-----------------------------------------------------------------|---------|
| [`GET /users/:id/followers`](../../api/user_follow_unfollow.md#list-all-accounts-that-follow-a-user) | 每分钟 100 次 |
| [`GET /users/:id/following`](../../api/user_follow_unfollow.md#list-all-accounts-followed-by-a-user) | 每分钟 100 次 |
| [`GET /users/:id/status`](../../api/users.md#retrieve-the-status-of-a-user)                               | 每分钟 240 次 |
| [`GET /users/:id/keys`](../../api/user_keys.md#list-all-ssh-keys-for-a-user)                         | 每分钟 120 次 |
| [`GET /users/:id/keys/:key_id`](../../api/user_keys.md#retrieve-an-ssh-key-for-a-user)                               | 每分钟 120 次 |
| [`GET /users/:id/gpg_keys`](../../api/user_keys.md#list-all-gpg-keys-for-a-user)                     | 每分钟 120 次 |
| [`GET /users/:id/gpg_keys/:key_id`](../../api/user_keys.md#retrieve-a-gpg-key-for-a-user)                 | 每分钟 120 次 |

先决条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **用户 API 速率限制**。
1. 设置任何可用速率限制的值。速率限制对已验证请求按每个用户每分钟计算，对未验证请求按每个 IP 地址每分钟计算。输入 `0` 可禁用速率限制。
1. 选择 **保存更改**。

每个速率限制：

- 如果请求已认证，则按用户应用。
- 如果请求未认证，则按 IP 地址应用。
- 可以设置为 `0` 以禁用速率限制。

日志：

- 超出速率限制的请求将记录在 `auth.log` 文件中。
- 速率限制修改将记录在 `audit_json.log` 文件中。

例如：

如果您将 `GET /users/:id/followers` 的速率限制设置为 150，并在一分钟内发送 155 个请求，则最后五个请求将被阻止。一分钟后，您可以继续发送请求，直到再次超出速率限制。

<end>