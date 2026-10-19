---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在客户端反复认证失败后，禁止其访问的封禁机制。
title: 滥用与认证失败封禁
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

某些保护机制会在一段时间内阻止客户端访问，而不是减慢请求速度。

<a id="failed-authentication-ban-for-git-and-container-registry"></a>

## Git 和容器镜像仓库的认证失败封禁

默认情况下，如果在一分钟内从单个 IP 地址收到 10 次失败的认证请求，极狐GitLab 会返回 HTTP 状态码 `403`，持续 1 小时。这三个值均可配置。
此限制仅适用于以下组合：

- Git 请求。
- 容器镜像仓库（`/jwt/auth`）请求。

此限制：

- 在封禁开始前，成功的认证请求会重置计数。例如，9 次失败的认证请求后跟 1 次成功的请求，再跟 9 次失败的认证请求，不会触发封禁。
- 一旦封禁开始，无法通过认证来清除。封禁检查在凭据检查之前进行，因此被封禁的 IP 即使使用有效凭据也会收到 `403`，直到封禁过期。
- 不适用于由 `gitlab-ci-token` 认证的 JWT 请求。
- 默认禁用。

不提供响应头。

为避免触发速率限制，您可以：

- 错开自动化流水线的执行时间。
- 为失败的认证尝试配置[指数退避和重试](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/retry-backoff.html)。
- 使用文档化的流程和[最佳实践](https://about.gitlab.com/blog/access-token-lifetime-limits/#how-to-minimize-the-impact)来管理令牌过期。

有关配置信息，请参阅
[Linux 软件包配置选项](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-a-failed-authentication-ban)。

<a id="troubleshooting"></a>

## 故障排查

<a id="rack-attack-is-denylisting-the-load-balancer"></a>

### Rack Attack 将负载均衡器加入拒绝列表

如果所有流量似乎都来自负载均衡器，Rack Attack 可能会阻止您的负载均衡器。在这种情况下，您必须：

1. [配置 `nginx[real_ip_trusted_addresses]`](https://gitlab.cn/docs/omnibus/settings/nginx/#configure-gitlab-trusted-proxies-and-nginx-real_ip-module)。
   这可以防止用户的 IP 被列为负载均衡器 IP。
1. 将负载均衡器的 IP 地址加入允许列表。
1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="remove-blocked-ips-from-rack-attack-with-redis"></a>

### 使用 Redis 从 Rack Attack 中移除被封禁的 IP

要移除被封禁的 IP：

1. 在生产日志中找到已被封禁的 IP：

   ```shell
   grep "Rack_Attack" /var/log/gitlab/gitlab-rails/auth.log
   ```

1. 拒绝列表存储在速率限制 Redis 实例中，因此您必须对其打开 `redis-cli`。在未分离实例的安装中，这是默认的 Redis：

   ```shell
   /opt/gitlab/embedded/bin/redis-cli -s /var/opt/gitlab/redis/redis.socket
   ```

   如果您已配置 `gitlab_rails['redis_rate_limiting_instance']`，请连接到该实例。
   从错误的实例中删除键看似成功，但封禁仍然有效。

1. 您可以使用以下语法移除封禁，将 `<ip>` 替换为实际被列入拒绝列表的 IP：

   ```plaintext
   del cache:gitlab:rack::attack:allow2ban:ban:<ip>
   ```

1. 确认包含该 IP 的键不再出现：

   ```plaintext
   keys *rack::attack*
   ```

   默认情况下，[`keys` 命令被禁用](https://gitlab.cn/docs/omnibus/settings/redis/#renamed-commands)。

1. 可选地，将 [该 IP 添加到允许列表](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-a-failed-authentication-ban)
   以防止其再次被加入拒绝列表。
