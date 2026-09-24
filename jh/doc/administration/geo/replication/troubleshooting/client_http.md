---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Geo 客户端和 HTTP 响应码错误
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="fixing-client-errors"></a>

## 修复客户端错误

<a id="authorization-errors-from-lfs-https-client-requests"></a>

### LFS HTTP(S) 客户端请求的授权错误

如果您运行的是 2.4.2 版本之前的 [Git LFS](https://git-lfs.com/)，可能会遇到问题。
正如[此认证问题](https://github.com/git-lfs/git-lfs/issues/3025)中所指出的，
从次要站点重定向到主要站点的请求未能正确发送
Authorization 标头。这可能导致无限 `Authorization <-> Redirect`
循环，或 Authorization 错误消息。

<a id="error-netreadtimeout-when-pushing-through-ssh-on-a-geo-secondary"></a>

### 在 Geo 次要站点上通过 SSH 推送时出现 `Net::ReadTimeout` 错误

当您通过 SSH 在 Geo 次要站点上推送大型仓库时，可能会遇到超时。
这是因为 Rails 会将推送代理到主要站点，并且有 60 秒的默认超时。

当前的变通方案是：

- 改用 HTTP 推送，Workhorse 会将请求代理到主要站点（如果未启用 Geo 代理，则重定向到主要站点）。
- 直接推送到主要站点。

示例日志（`gitlab-shell.log`）：

```plaintext
Failed to contact primary https://primary.domain.com/namespace/push_test.git\\nError: Net::ReadTimeout\",\"result\":null}" code=500 method=POST pid=5483 url="http://127.0.0.1:3000/api/v4/geo/proxy_git_push_ssh/push"
```

<a id="repair-oauth-authorization-between-geo-sites"></a>

### 修复 Geo 站点之间的 OAuth 授权

升级 Geo 站点时，您可能无法登录仅使用 OAuth 进行身份验证的次要站点。在这种情况下，请在您的主要站点上启动一个 [Rails 控制台](../../../operations/rails_console.md) 会话，然后执行以下步骤：

1. 要找到受影响的节点，首先列出您拥有的所有 Geo 节点：

   ```ruby
   GeoNode.all
   ```

1. 通过指定 ID 修复受影响的 Geo 节点：

   ```ruby
   GeoNode.find(<id>).repair
   ```

<a id="http-response-code-errors"></a>

## HTTP 响应码错误

<a id="secondary-site-returns-502-errors-with-geo-proxying"></a>

### 次要站点启用 Geo 代理时返回 502 错误

当启用了 [次要站点的 Geo 代理](../../secondary_proxy/_index.md) 时，并且次要站点用户界面返回
502 错误，可能是从主要站点代理过来的响应头太大。

检查 NGINX 日志中是否有类似此示例的错误：

```plaintext
2022/01/26 00:02:13 [error] 26641#0: *829148 upstream sent too big header while reading response header from upstream, client: 10.0.2.2, server: geo.staging.gitlab.com, request: "POST /users/sign_in HTTP/2.0", upstream: "http://unix:/var/opt/gitlab/gitlab-workhorse/sockets/socket:/users/sign_in", host: "geo.staging.gitlab.com", referrer: "https://geo.staging.gitlab.com/users/sign_in"
```

要解决此问题：

1. 在次要站点所有 Web 节点上的 `/etc/gitlab.rb` 中设置 `nginx['proxy_custom_buffer_size'] = '8k'`。
1. 使用 `sudo gitlab-ctl reconfigure` 重新配置 **次要站点**。

如果仍然出现此错误，您可以通过重复前面的步骤并更改 `8k` 大小来进一步增大缓冲区大小，例如将大小加倍到 `16k`。

<a id="geo-admin-area-shows-unknown-for-health-status-and-request-failed-with-status-code-401"></a>

### Geo 管理区域显示健康状态为 `Unknown` 以及 '请求失败，状态码 401'

如果使用负载均衡器，请确保负载均衡器的 URL 被设置为负载均衡器后方节点的 `/etc/gitlab/gitlab.rb` 中的 `external_url`。

在主要站点上，转到 **管理员** > **Geo** > **设置** 并找到 **允许的 Geo IP** 字段。确保列出了次要站点的 IP 地址。

<a id="primary-site-returns-500-error-when-accessing-admin-geo-replication-projects"></a>

### 主要站点访问 `/admin/geo/replication/projects` 时返回 500 错误

在主要 Geo 站点上，导航到 **管理员** > **Geo** > **复制**（或 `/admin/geo/replication/projects`）会显示 500 错误，而次要站点上的相同链接则工作正常。主要站点的 `production.log` 中会有类似以下内容的条目：

```plaintext
Geo::TrackingBase::SecondaryNotConfigured: Geo secondary database is not configured
  from ee/app/models/geo/tracking_base.rb:26:in `connection'
  [..]
  from ee/app/views/admin/geo/projects/_all.html.haml:1
```

在 Geo 主要站点上，可以忽略此错误。
发生这种情况是因为 GitLab 尝试显示来自 [Geo 跟踪数据库](../../_index.md#geo-tracking-database) 的注册信息，该数据库在主要站点上不存在（主要站点上仅存在原始项目；没有复制的项目，因此不存在跟踪数据库）。

<a id="secondary-site-returns-400-error-request-header-or-cookie-too-large"></a>

### 次要站点返回 400 错误 `Request header or cookie too large`

当主要站点的内部 URL 不正确时，可能会发生此错误。
例如，当您使用统一 URL 且主要站点的内部 URL 也等于外部 URL 时。这会导致次要站点向主要站点的内部 URL 代理请求时出现循环。
要解决此问题，请将主要站点的内部 URL 设置为一个：
- 对主要站点唯一的 URL。
- 可从所有次要站点访问的 URL。

1. 访问主要站点。
1. [设置内部 URL](../../../geo_sites.md#set-up-the-internal-urls)。

<a id="geo-admin-area-returns-404-error-for-a-secondary-site"></a>

### Geo 管理区域返回次要站点的 404 错误

有时 `sudo gitlab-rake gitlab:geo:check` 会指示**次要站点的 Rails 节点**是
健康的，但在主要站点的 Web 界面的 Geo **管理** 区域中返回了针对**次要**站点的 404 Not Found 错误消息。

要解决此问题：

- 尝试使用 `sudo gitlab-ctl restart` 重启**次要站点上的每个 Rails、Sidekiq 和 Gitaly 节点**。
- 检查 Sidekiq 节点上的 `/var/log/gitlab/gitlab-rails/geo.log`，查看**次要**站点是否
  使用 IPv6 将其状态发送到**主要**站点。如果是，在 `/etc/hosts` 文件中为**主要**站点添加一个 IPv4 条目。或者，您应该
  [在**主要**站点上启用 IPv6](https://gitlab.cn/docs/omnibus/settings/nginx/#setting-the-nginx-listen-address-or-addresses)。

<a id="websocket-requests-fail-on-geo-secondary-sites"></a>

## Geo 次要站点上的 WebSocket 请求失败

当使用依赖 WebSocket 的功能（如极狐GitLab Duo Chat、实时议题更新或其他实时功能）时，Geo 次要站点上的连接可能会失败并出现 404 错误。
这是因为 WebSocket 请求从次要站点代理到主要站点。在主要站点上，必须配置 ActionCable 以允许来自所有 Geo 站点的 WebSocket 请求。默认情况下，ActionCable 仅允许来自本地站点的请求。

要解决此问题，请根据您的安装类型配置 `action_cable_allowed_origins`：

- [适用于 Linux 软件包的 Geo 文档](../configuration.md#add-primary-and-secondary-urls-as-allowed-actioncable-origins)
- [适用于 Helm chart 的 Geo 文档](https://gitlab.cn/docs/charts/advanced/geo/#configure-primary-database)