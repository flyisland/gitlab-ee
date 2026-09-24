---
stage: Production Engineering
group: Networking and Incident Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 受保护的路径
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

速率限制是一种提高 Web 应用程序安全性和持久性的技术。有关更多详细信息，请参阅[速率限制](../../security/rate_limits.md)。

您可以对指定路径进行速率限制（保护）。对于这些路径，如果 POST 请求和 GET 请求各自超过每个 IP 地址每分钟 10 次，极狐GitLab 将返回 HTTP 状态码 `429`。

例如，以下操作限制为每分钟最多 10 次请求：

- 用户登录
- 新用户账户创建（如果已启用）
- 用户密码重置

在发起 10 次请求后，客户端必须等待 60 秒才能重试。

另请参阅：

- [默认受保护的路径列表](../instance_limits.md#by-protected-path)。
- [用户和 IP 速率限制](user_and_ip_rate_limits.md#response-headers)，了解针对被阻止请求返回的响应头。

<a id="configure-protected-paths"></a>

## 配置受保护的路径

受保护路径的节流默认启用，并且可以禁用或自定义。

先决条件：

- 管理员权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **受保护的路径**。

超过速率限制的请求会记录在 `auth.log` 中。