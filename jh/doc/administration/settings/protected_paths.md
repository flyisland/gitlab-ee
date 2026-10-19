---
stage: Production Engineering
group: Networking and Incident Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 受保护路径
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

速率限制是一种提升 Web 应用安全性和耐久性的技术。更多详情，请参见[速率限制](../../rate_limits/_index.md)。

您可以对指定的路径进行速率限制（保护）。对于这些路径，极狐GitLab 会对超过每个 IP 地址每分钟 10 个请求的 POST 请求，以及超过每个 IP 地址每分钟 10 个请求的 GET 请求，在受保护路径上返回 HTTP 状态码 `429`。

例如，以下操作被限制为每分钟最多 10 个请求：

- 用户登录
- 创建新用户账号（如果已启用）
- 用户密码重置

达到 10 个请求后，客户端必须等待 60 秒才能再次尝试。

另请参见：

- [默认受保护的路径列表](../instance_limits.md#by-protected-path)。
- [用户和 IP 速率限制](user_and_ip_rate_limits.md#response-headers)，
  了解返回给被阻止请求的响应头。

<a id="configure-protected-paths"></a>

## 配置受保护路径

受保护路径的限流默认启用，可以禁用或自定义。

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**受保护路径**。

超过速率限制的请求会记录在 `auth.log`中。
