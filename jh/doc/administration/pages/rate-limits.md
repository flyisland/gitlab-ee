---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以实施速率限制，以帮助降低拒绝服务（DoS）攻击的风险。GitLab Pages
使用令牌桶算法来实施速率限制。默认情况下，
超过指定限制的请求或 TLS 连接会被报告并拒绝。

GitLab Pages 支持以下类型的速率限制：

- 按 `source_ip`：限制来自单个客户端 IP 地址的请求或 TLS 连接。
- 按 `domain`：限制托管在 GitLab Pages 上的每个域的请求或 TLS 连接。这可以是
  自定义域，如 `example.com`，或群组域，如 `group.gitlab.io`。

基于 HTTP 请求的速率限制通过以下设置实施：

- `rate_limit_source_ip`：每个客户端 IP 每秒的最大请求数。设置为 `0` 以禁用。
- `rate_limit_source_ip_burst`：每个客户端 IP 在初始突发中允许的最大请求数，例如
  当页面同时加载多个资源时。
- `rate_limit_domain`：每个托管的 Pages 域每秒的最大请求数。设置为 `0` 以禁用。
- `rate_limit_domain_burst`：每个托管的 Pages 域在初始突发中允许的最大请求数。

基于 TLS 连接的速率限制通过以下设置实施：

- `rate_limit_tls_source_ip`：每个客户端 IP 每秒的最大 TLS 连接数。设置为 `0` 以
  禁用。
- `rate_limit_tls_source_ip_burst`：每个客户端 IP 在初始突发中允许的最大 TLS 连接数。
- `rate_limit_tls_domain`：每个托管的 Pages 域每秒的最大 TLS 连接数。设置为 `0`
  以禁用。
- `rate_limit_tls_domain_burst`：每个托管的 Pages 域在初始突发中允许的最大 TLS 连接数。

要允许某些 IP 范围（子网）绕过所有速率限制，请使用 `rate_limit_subnets_allow_list`。
例如，`['1.2.3.4/24', '2001:db8::1/32']`。可参考
[GitLab Pages chart 示例](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-pages/#configure-rate-limits-subnets-allow-list)。

如果客户端的 IP 地址是 IPv6，则限制应用于长度为 64 的 IPv6 前缀，
而不是整个地址。

<a id="enable-http-requests-rate-limits-by-source-ip"></a>

## 按源 IP 启用 HTTP 请求速率限制

要在 `/etc/gitlab/gitlab.rb` 中设置速率限制：

1. 添加以下内容：

   ```ruby
   gitlab_pages['rate_limit_source_ip'] = 20.0
   gitlab_pages['rate_limit_source_ip_burst'] = 600
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="enable-http-requests-rate-limits-by-domain"></a>

## 按域启用 HTTP 请求速率限制

要在 `/etc/gitlab/gitlab.rb` 中设置速率限制：

1. 添加：

   ```ruby
   gitlab_pages['rate_limit_domain'] = 1000
   gitlab_pages['rate_limit_domain_burst'] = 5000
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="enable-tls-connections-rate-limits-by-source-ip"></a>

## 按源 IP 启用 TLS 连接速率限制

要在 `/etc/gitlab/gitlab.rb` 中设置速率限制：

1. 添加：

   ```ruby
   gitlab_pages['rate_limit_tls_source_ip'] = 20.0
   gitlab_pages['rate_limit_tls_source_ip_burst'] = 600
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="enable-tls-connections-rate-limits-by-domain"></a>

## 按域启用 TLS 连接速率限制

要在 `/etc/gitlab/gitlab.rb` 中设置速率限制：

1. 添加：

   ```ruby
   gitlab_pages['rate_limit_tls_domain'] = 1000
   gitlab_pages['rate_limit_tls_domain_burst'] = 5000
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
