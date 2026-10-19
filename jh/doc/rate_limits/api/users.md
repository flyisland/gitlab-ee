---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Users API 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 升级到极狐GitLab 18.0 或更高版本时，此 API 的可配置速率限制设置为 `0`。管理员可以根据需要调整速率限制。有关受影响的速率限制的信息，请参阅[为 Projects、Groups 和 Users API 宣布的速率限制](https://about.gitlab.com/blog/rate-limitations-announced-for-projects-groups-and-users-apis/#rate-limitation-details)。

您可以为以下 [Users API](../../api/users.md) 的请求配置每个 IP 地址和每个用户的每分钟速率限制。

| 限制                                                           | 默认值 |
|-----------------------------------------------------------------|---------|
| [`GET /users/:id/followers`](../../api/user_follow_unfollow.md#list-all-accounts-that-follow-a-user) | 每分钟 100 次 |
| [`GET /users/:id/following`](../../api/user_follow_unfollow.md#list-all-accounts-followed-by-a-user) | 每分钟 100 次 |
| [`GET /users/:id/status`](../../api/users.md#retrieve-the-status-of-a-user)                               | 每分钟 240 次 |
| [`GET /users/:id/keys`](../../api/user_keys.md#list-all-ssh-keys-for-a-user)                         | 每分钟 120 次 |
| [`GET /users/:id/keys/:key_id`](../../api/user_keys.md#retrieve-an-ssh-key-for-a-user)                               | 每分钟 120 次 |
| [`GET /users/:id/gpg_keys`](../../api/user_keys.md#list-all-gpg-keys-for-a-user)                     | 每分钟 120 次 |
| [`GET /users/:id/gpg_keys/:key_id`](../../api/user_keys.md#retrieve-a-gpg-key-for-a-user)                 | 每分钟 120 次 |

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Users API 速率限制**。
1. 为任何可用的速率限制设置值。速率限制以每分钟为单位，针对经过身份验证的请求按用户计算，针对未经身份验证的请求按 IP 地址计算。输入 `0` 以禁用速率限制。
1. 选择 **保存更改**。

每个速率限制：

- 如果请求经过身份验证，则按用户应用。
- 如果请求未经身份验证，则按 IP 地址应用。
- 可以设置为 `0` 以禁用速率限制。

日志：

- 超过速率限制的请求会记录到 `auth.log` 文件中。
- 速率限制的修改会记录到 `audit_json.log` 文件中。

示例：

如果您为 `GET /users/:id/followers` 设置 150 的速率限制，并在 1 分钟内发送 155 个请求，则最后五个请求将被阻止。1 分钟后，您可以继续发送请求，直到再次超过速率限制。
